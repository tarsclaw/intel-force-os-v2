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
session id: 019e5979-74ba-7642-a9f2-7236a125bd3f
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

=== TYPE-SPECIFIC SKILL: architecture-decision ===

# Codex ratification skill — review-architecture-decision

Type-specific checks for: ADRs (`docs/decisions/ADR-*.md`), decision docs (`docs/decisions/*.md` other than ADRs), reference designs (`docs/architecture/*.md`), runbooks (`docs/runbooks/*.md`).

This skill ADDS to the top-level `SKILL.md`. Apply that first; everything below is incremental.

---

## §1 — Decision-doc shape requirements

Every artefact of this type MUST have:

1. **Status field** — one of `Proposed | Accepted | In Force | Reference | Superseded | Deprecated`. Match the file's content honestly:
   - `Proposed` = the decision exists but hasn't been ratified or actioned
   - `Accepted` = founder has approved + work is underway/done
   - `In Force` = the decision is binding operational policy right now
   - `Reference` = factual recording (audits, inventories, manifests)
   - `Superseded` = a later artefact replaces this one
   - `Deprecated` = the decision is no longer applied

   REJECT if status is missing, conflicts with content (e.g., "Accepted" but Sub-decisions are "Proposed pending commercial conversations"), or is "Accepted" without a Founder decision date.

2. **Context section** — explains the problem before the solution. Should be readable cold; if a new reader can't tell what this decision is about from the Context alone, REJECT. **Required for ALL statuses.**

3. **Decision section** — names the choice, not the deliberation. If the artefact is mostly deliberation with no clear decision, REJECT. **Required for `Proposed | Accepted`. EXEMPT for `Reference` (audits, inventories, manifests) and `In Force` (runbooks, operational standing policies) — those artefacts encode their "decisions" in the working content itself (audit findings table; runbook procedure steps); a separate Decision heading would be redundant ceremony.**

4. **Alternatives considered** — for ADRs, at least 2 alternatives MUST be named + rejected with reasons. If only one option is presented, REJECT — that's a memo, not a decision document. **Required for `Proposed | Accepted` ADRs only. EXEMPT for non-ADR Reference + In Force artefacts.**

5. **Consequences section** — what changes downstream. Includes risk register implications, master brief edits authorised (if any), downstream-artefact updates required. **Required for `Proposed | Accepted`. EXEMPT for `Reference` + `In Force` — downstream impact may be inline (e.g., "Day-7 single-sentence test Q2 references this audit") rather than under a dedicated heading; verify via cross-references in body text.**

6. **Status update line at end** — current state ("Accepted on 2026-05-16 by founder + Claude Code") OR ratification-pending note. **Required for ALL statuses.**

### §1-Exemption — Softening for Reference + In Force (Codex Round 1 D5)

The exemptions in items 3, 4, 5 above are the result of Founder Decision D5 (commit `2026-05-22`) resolving the disagreement at `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md`. Reference artefacts (e.g., `cortexos-primitive-status.md` audit, `architecture-cohesion-review.md`, `tenancy-invariants.md`) and In Force artefacts (e.g., `operational-hygiene-protocol.md` runbook, `tenant-lifecycle.md` runbook) legitimately do not have "decisions" or "alternatives weighed" — they document findings or procedures.

**The Context requirement (item 2) and Status update line (item 6) still apply to ALL artefacts under this skill.** Citation accuracy (§3) and boundary checks (top-level SKILL.md §2) also apply to all.

If a `Reference` or `In Force` artefact is making material architectural claims that warrant deliberation, RATIFY with an advisory note suggesting the author consider promoting parts to an ADR. Do not REJECT solely for the missing Decision/Consequences sections on these status types.

---

## §2 — ADR-specific structure (for files matching `ADR-*.md`)

In addition to §1, ADRs MUST:

- Have a numbered identifier in the filename matching the contents ("ADR-003" in filename → "# ADR-003 —" as the H1)
- Be sequentially numbered (no gaps — ADR-001 → 002 → 003 → 004)
- Link to predecessor ADRs if extending or referring to them
- Have at least one "Decision" heading + at least one explicit "Decision 1 — <terse summary>" subheading per distinct decision

REJECT if any of these are missing.

---

## §3 — Citation accuracy (heavily-tested area)

Past audits found 15 fabricated `§10.4` references in one batch. Recurrence is likely. Check:

For every cited section reference (e.g., "master brief §6 Day 7 line 502"):

1. Open the cited file
2. Find the cited section
3. Verify the citation matches the content the artefact claims it does

If even one citation is wrong, REJECT with the specific citation listed. Past pattern: `master brief §10.4 cost target` cited 15 times; §10.4 is actually the Codex exclusion list with no cost-target content.

For relative references ("per ADR-003 §3.3.3"), confirm the section exists in the predecessor.

For commit-SHA references (e.g., `c21fbfe`, `fec8872`), confirm the SHA matches the artefact's date + makes sense in context. Don't require running `git show` if the SHA is consistent with the narrative.

---

## §4 — Master brief edit authorisation

If the ADR authorises master brief edits (an "## Master brief edits authorised by this ADR" section):

1. The proposed text MUST be quoted verbatim — both current AND proposed.
2. The edit's line numbers MUST match the live master brief (sample-check at least one).
3. Edits MUST land in either (a) this commit, (b) the next atomic-correction commit, or (c) an explicit deferred queue. Vague "later" disposition = REJECT.
4. Risk #7 (master-brief-drift-accumulation) edit count MUST update if this ADR adds edits to the queue.

---

## §5 — Spec-gap surfacing

Reference design docs often surface spec gaps (`§N.M-A`, `§N.M-B` etc.). Each gap MUST:

- Be numbered uniquely within the design doc
- State the gap (what's missing in the upstream spec)
- Recommend a resolution OR be explicitly deferred to a named owner + week
- Not contradict each other (gap §2.1-A resolution must not break gap §2.1-B resolution)

REJECT if a gap is stated without a resolution path AND not explicitly deferred with owner + trigger.

---

## §6 — Implementation deviation acknowledgement

If the ADR ratifies deviations from a predecessor ADR (e.g., ADR-004 deviates from ADR-003):

1. Predecessor MUST be linked
2. Each deviation MUST be numbered + reasoned individually
3. Predecessor's text MUST be quoted to show what's being deviated from
4. Reason for deviation MUST be concrete (citing a boundary, a runtime constraint, a discovered bug — not "felt cleaner")
5. Rollback or alternative path MUST be named ("if rejected: build X shim instead")

REJECT if deviations are listed without quoting the predecessor or without concrete reasoning.

---

## §7 — Decision_log audit fields (master brief §8.1 Change 2)

Architecture decisions don't directly write to `decision_log` (the agent runtime does), but they MAY constrain what the runtime writes. Check:

- If the decision adds a `decision_log.phase` value: confirm Day-4 §6.3 schema CHECK constraint includes it (`trigger | output | action | gating_failed | agent_handoff`)
- If the decision adds a new ESC code: confirm `agents/_shared/escalation-codes.md` (Phase 1 of Day 8) has the code listed
- If the decision references `payload.tier` or `payload.<key>`: confirm autosend-safety-policy §7 documents the field shape
- If the decision restricts `agent_name` values: confirm sentinel names (`_renderer`, `_tenant_admin`, `_codex_ratifier`, `_shared`) are consistent with usage

REJECT if a decision adds an enum value or column to `decision_log` without confirming the schema supports it.

---

## §8 — Boundary-specific rejections for this artefact type

In addition to the four boundaries in `SKILL.md` §2:

- **Submodule reference** — decision docs MAY name cortextOS files for reference (e.g., `add-agent.ts:131-140`); they MUST NOT propose modifying them. If the ADR proposes a modification to `packages/harness/cortextos/*` outside the shadow points, REJECT.

- **Adapter boundary** — `Composio` and `AgentMail` may appear in INTERNAL discussion text (e.g., "we considered Composio") but MUST NOT appear in `tools.yaml` shape definitions, agent.md examples, or schema fixtures. If the ADR proposes including either in any of those locations, REJECT.

- **v1 source code** — `~/code/intel-force-os/` (the v1 codebase) MUST NOT be modified. ADRs MAY reference v1 for prior-art lessons; MUST NOT instruct edits.

---

## §9 — Common false-RATIFY traps to watch for

Past patterns that look RATIFIABLE but should REJECT:

- **"Trust me" architecture** — the artefact asserts a design works without alternatives weighed. Even simple decisions need at least one weighted alternative.

- **Over-elaborated worked examples** — a 200-line "Concierge worked example" inside an architecture decision is a red flag for masking a thin decision underneath. Skim the worked example; if the decision itself is < 50 lines, REJECT and demand more decision-content.

- **Status drift** — file says `Accepted` but content includes `TODO`, `pending`, `to be decided`. REJECT.

- **Hidden caveats** — major limitations buried at the bottom in a "Notes" section. Surface to the Decision or Consequences section. REJECT.

- **Cross-cite hallucination** — references "as documented in §X" but §X doesn't actually document it. Check.

- **Numbered options that omit the chosen one's reasoning** — "Options: A, B, C. Chose B." but no reasoning for WHY B. REJECT.

---

## §10 — When to RATIFY-with-notes

Use this sparingly. RATIFIED-with-notes is appropriate when:

- The artefact passes all required checks but has typos or wording suboptimalities
- A genuinely advisory observation worth surfacing but not blocking
- The author should fix-up at next touch but the merge is fine

Anything load-bearing — citation errors, spec gaps without resolution, status drift, boundary violations — is REJECTED, not RATIFIED-with-notes. If you find yourself adding more than 5 lines of notes, the artefact has structural issues and should be REJECTED.

---

## §11 — Quick checklist (run this for every ADR-type artefact)

- [ ] Has Status field with valid value matching content
- [ ] Has Context, Decision, Consequences sections
- [ ] (If ADR) Numbered + sequentially located + has alternatives weighed
- [ ] All citations verifiable (sample at least 3)
- [ ] No fabricated section references
- [ ] No submodule modifications proposed outside shadow points
- [ ] No Composio/AgentMail in `tools.yaml`/`agent.md` examples
- [ ] No v1-source modifications proposed
- [ ] Any master-brief edits include current+proposed text + line numbers + disposition
- [ ] Spec gaps (if any) have named resolution or deferred owner
- [ ] Status field matches content honesty (no Accepted-with-pending-sub-decisions unless explicitly noted)

If all clear: RATIFIED.
If any fail: REJECTED with numbered issues citing specifics.

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

codex
I’ll verify the artefact against the supplied ratification rules and spot-check the referenced schema/shared artefacts so the verdict is grounded in the repo, not just the pasted text.
exec
/bin/zsh -lc 'rg -n "target_patch|voice_corpus|tone_rule|decision_log|agent_name|phase|firm|diagnostic|company_number|deal_size_band|size_bands" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment 2>/dev/null' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "ESC_INPUT_VALIDATION_FAIL|ESC_RATE_LIMIT_HIT|ESC_AGENT_OUTPUT_SHAPE|ESC_VOICE_DRIFT_TENANT|ESC_PII_LEAKAGE_RISK|ESC_VOICE_DRIFT" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
 succeeded in 1ms:
120:#### `ESC_VOICE_DRIFT`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
170:#### `ESC_VOICE_DRIFT_TENANT`
172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`

 succeeded in 1ms:
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:564:        source: IFOS-derived (T2 confirms; v2.0)
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:715:    client: R        # target-firm context
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
docs/verticals/recruitment/vertical-schema.yaml:872:      Codex Day-7 ratification reviews whether stricter source-field schema would improve machine-parseability. If accepted, v1.0 introduces structured source object — e.g., `source: {origin: bullhorn | ifos_derived, bullhorn_field?: <entity.field>, ifos_agent?: <agent_name>, citation?: <doc-ref>}`.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:11:--   - 1 auxiliary table: voice_corpus_chunks (holds the pgvector index)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:15:--   - 2 entity_links link_type values (voice_corpus_governs_tone_rules,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:23:--   - RLS policies on entities + entity_links + decision_log already in place
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
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:82:CREATE TABLE IF NOT EXISTS voice_corpus_chunks (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:85:  voice_corpus_id   BIGINT      NOT NULL REFERENCES voice_corpus (id) ON DELETE CASCADE,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:91:  CONSTRAINT voice_corpus_chunks_corpus_chunk_unique UNIQUE (voice_corpus_id, chunk_index)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:94:CREATE INDEX IF NOT EXISTS voice_corpus_chunks_tenant_idx ON voice_corpus_chunks (tenant_slug);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:95:CREATE INDEX IF NOT EXISTS voice_corpus_chunks_corpus_idx ON voice_corpus_chunks (voice_corpus_id);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:99:  ON voice_corpus_chunks
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:103:ALTER TABLE voice_corpus_chunks ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:104:ALTER TABLE voice_corpus_chunks FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:105:DROP POLICY IF EXISTS voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:106:CREATE POLICY voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:110:-- §4 — Create tone_rule table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:113:CREATE TABLE IF NOT EXISTS tone_rule (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:126:  CONSTRAINT tone_rule_tenant_rule_id_unique UNIQUE (tenant_slug, rule_id)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:129:CREATE INDEX IF NOT EXISTS tone_rule_tenant_enabled_idx ON tone_rule (tenant_slug, enabled);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:131:ALTER TABLE tone_rule ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:132:ALTER TABLE tone_rule FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:133:DROP POLICY IF EXISTS tone_rule_tenant_isolation ON tone_rule;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:134:CREATE POLICY tone_rule_tenant_isolation ON tone_rule
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:144:  agent_name             TEXT        NOT NULL,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:153:  tone_rules_triggered   TEXT[]      NOT NULL DEFAULT '{}',
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:160:CREATE INDEX IF NOT EXISTS recent_edit_tenant_agent_idx ON recent_edit (tenant_slug, agent_name, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:173:-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:174:-- Voice corpus + tone_rule are mutable (re-index + rule revisions).
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:177:GRANT SELECT, INSERT, UPDATE        ON voice_corpus        TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:178:GRANT SELECT, INSERT, UPDATE, DELETE ON voice_corpus_chunks TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:179:GRANT SELECT, INSERT, UPDATE, DELETE ON tone_rule           TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:182:GRANT USAGE, SELECT ON SEQUENCE voice_corpus_id_seq        TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:183:GRANT USAGE, SELECT ON SEQUENCE voice_corpus_chunks_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:184:GRANT USAGE, SELECT ON SEQUENCE tone_rule_id_seq           TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:199:--   ALTER TABLE voice_corpus OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:200:--   ALTER TABLE voice_corpus_chunks OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:201:--   ALTER TABLE tone_rule OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:203:--   ALTER SEQUENCE voice_corpus_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:204:--   ALTER SEQUENCE voice_corpus_chunks_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:205:--   ALTER SEQUENCE tone_rule_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:280:-- §9 — Reference rows: seed migration-test tenant with a starter voice_corpus
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:282:-- Inserts a single empty active voice_corpus row for migration-test only.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:289:INSERT INTO voice_corpus (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:309:-- These are SELECTs for the operator to run post-migration to confirm shape.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:313:-- SELECT count(*) FROM voice_corpus WHERE tenant_slug = 'migration-test';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:315:-- SELECT indexname FROM pg_indexes WHERE tablename = 'voice_corpus_chunks';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:316:--   → expect: voice_corpus_chunks_pkey, voice_corpus_chunks_tenant_idx,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:317:--             voice_corpus_chunks_corpus_idx, voice_samples_embedded
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:318:-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:27:DROP TABLE IF EXISTS tone_rule            CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:28:DROP TABLE IF EXISTS voice_corpus_chunks  CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:29:DROP TABLE IF EXISTS voice_corpus         CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:17:-- founder confirms retention window from D2 advisor input).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:56:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:123:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:202:      agent_name:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:252:      tone_rules_triggered:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:257:          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:270:    table: voice_corpus_chunks                       # auxiliary table; see §3 migration SQL
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:279:      Per-tenant query pattern via RLS: SELECT * FROM voice_corpus_chunks WHERE tenant_slug = current_setting('app.current_tenant') ORDER BY embedding <=> $query_vec LIMIT 10. RLS predicate ensures cross-tenant isolation even if a developer forgets the WHERE clause.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:309:        Most-recent voice classifier score from Concierge outbound messages addressed to this contact. Drives addressee-specific drift detection (some contacts' tone preferences may differ from firm baseline).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:341:  voice_corpus_governs_tone_rules:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:342:    source: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:343:    target: tone_rule
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:346:      One voice_corpus version logically governs the set of tone_rules active at that version. When voice_corpus rolls forward (new version, is_active flipped), tone_rules don't migrate automatically — but the linkage records WHICH rules were active under WHICH corpus for audit and rollback.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:352:    target: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:384:  Q11_voice_corpus_chunk_storage:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:386:      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:393:  Q12_tone_rule_severity_block_path:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:405:      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:564:        source: IFOS-derived (T2 confirms; v2.0)
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:715:    client: R        # target-firm context
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
docs/verticals/recruitment/vertical-schema.yaml:872:      Codex Day-7 ratification reviews whether stricter source-field schema would improve machine-parseability. If accepted, v1.0 introduces structured source object — e.g., `source: {origin: bullhorn | ifos_derived, bullhorn_field?: <entity.field>, ifos_agent?: <agent_name>, citation?: <doc-ref>}`.

exec
/bin/zsh -lc "rg -n \"8\\.1|8\\.2|A1|Diagnostic|30%|12 required sections|Change 2|Change 1|§8\\.1|§8\\.2\" docs .codex agents packages -g '"'!node_modules'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 112ms:
docs/_supplementary/build-plan-original.md:303:- **Escalate** — if source APIs return <30% of expected volume for 3 consecutive runs, flag ICP as possibly too narrow
docs/specs/PRODUCT-SPEC.md:95:- **Revenue story:** "We do a full evening of sourcing on every brief in your pipeline, every night. You walk in to a day of outreach already drafted instead of a day of sourcing." Modelled: time-to-shortlist drops from 5 days to 2 days; 30% more briefs run concurrently per consultant.
docs/specs/PRODUCT-SPEC.md:173:#### R13. The Diagnostic — the sales motion, productised
docs/specs/PRODUCT-SPEC.md:244:| **Growth** (11–25 fee earners) | £3,250 | All Boutique + Night Sourcer, Brief Decoder, Spec Pitcher, Real-Time Pulse, Competitor Interception, Recruitment Reporting | "5–10 net-new retainers/year from BD + Competitor Interception. 30%+ more briefs per consultant via Night Sourcer. 1–2 saved client relationships/year worth £30k–£100k each." |
docs/specs/PRODUCT-SPEC.md:324:- 90-minute discovery call (driven by the Diagnostic output).
docs/specs/PRODUCT-SPEC.md:471:- The Diagnostic (sales tool; already drafted)
docs/_supplementary/strategic-plan.md:375:### 8.1 The sales motion
docs/_supplementary/strategic-plan.md:394:### 8.2 Channels, ranked by realistic ROI for you
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:1:# Diagnostic report — Hays plc
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:3:**Generated:** 2026-05-24 by Intel Force OS Diagnostic agent (v0 — pre-W3 build).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:11:No active Companies House registration found for **Hays plc**. Diagnostic proceeded against publicly visible non-CH signals only.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:1:# Diagnostic report — Hays plc
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:3:**Generated:** 2026-05-24 by Intel Force OS Diagnostic agent (v0 — pre-W3 build).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:11:No active Companies House registration found for **Hays plc**. Diagnostic proceeded against publicly visible non-CH signals only.
packages/harness/cortextos/tests/unit/bus/oauth.test.ts:230:    writeStore(); // primary at 30%/20% — below thresholds
packages/harness/cortextos/dashboard/package.json:42:    "@playwright/test": "^1.58.2",
packages/harness/cortextos/dashboard/public/next.svg:1:<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 394 80"><path fill="#000" d="M262 0h68.5v12.7h-27.2v66.6h-13.6V12.7H262V0ZM149 0v12.7H94v20.4h44.3v12.6H94v21h55v12.6H80.5V0h68.7zm34.3 0h-17.8l63.8 79.4h17.9l-32-39.7 32-39.6h-17.9l-23 28.6-23-28.6zm18.3 56.7-9-11-27.1 33.7h17.8l18.3-22.7z"/><path fill="#000" d="M81 79.3 17 0H0v79.3h13.6V17l50.2 62.3H81Zm252.6-.4c-1 0-1.8-.4-2.5-1s-1.1-1.6-1.1-2.6.3-1.8 1-2.5 1.6-1 2.6-1 1.8.3 2.5 1a3.4 3.4 0 0 1 .6 4.3 3.7 3.7 0 0 1-3 1.8zm23.2-33.5h6v23.3c0 2.1-.4 4-1.3 5.5a9.1 9.1 0 0 1-3.8 3.5c-1.6.8-3.5 1.3-5.7 1.3-2 0-3.7-.4-5.3-1s-2.8-1.8-3.7-3.2c-.9-1.3-1.4-3-1.4-5h6c.1.8.3 1.6.7 2.2s1 1.2 1.6 1.5c.7.4 1.5.5 2.4.5 1 0 1.8-.2 2.4-.6a4 4 0 0 0 1.6-1.8c.3-.8.5-1.8.5-3V45.5zm30.9 9.1a4.4 4.4 0 0 0-2-3.3 7.5 7.5 0 0 0-4.3-1.1c-1.3 0-2.4.2-3.3.5-.9.4-1.6 1-2 1.6a3.5 3.5 0 0 0-.3 4c.3.5.7.9 1.3 1.2l1.8 1 2 .5 3.2.8c1.3.3 2.5.7 3.7 1.2a13 13 0 0 1 3.2 1.8 8.1 8.1 0 0 1 3 6.5c0 2-.5 3.7-1.5 5.1a10 10 0 0 1-4.4 3.5c-1.8.8-4.1 1.2-6.8 1.2-2.6 0-4.9-.4-6.8-1.2-2-.8-3.4-2-4.5-3.5a10 10 0 0 1-1.7-5.6h6a5 5 0 0 0 3.5 4.6c1 .4 2.2.6 3.4.6 1.3 0 2.5-.2 3.5-.6 1-.4 1.8-1 2.4-1.7a4 4 0 0 0 .8-2.4c0-.9-.2-1.6-.7-2.2a11 11 0 0 0-2.1-1.4l-3.2-1-3.8-1c-2.8-.7-5-1.7-6.6-3.2a7.2 7.2 0 0 1-2.4-5.7 8 8 0 0 1 1.7-5 10 10 0 0 1 4.3-3.5c2-.8 4-1.2 6.4-1.2 2.3 0 4.4.4 6.2 1.2 1.8.8 3.2 2 4.3 3.4 1 1.4 1.5 3 1.5 5h-5.8z"/></svg>
packages/harness/cortextos/dashboard/public/file.svg:1:<svg fill="none" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><path d="M14.5 13.5V5.41a1 1 0 0 0-.3-.7L9.8.29A1 1 0 0 0 9.08 0H1.5v13.5A2.5 2.5 0 0 0 4 16h8a2.5 2.5 0 0 0 2.5-2.5m-1.5 0v-7H8v-5H3v12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1M9.5 5V2.12L12.38 5zM5.13 5h-.62v1.25h2.12V5zm-.62 3h7.12v1.25H4.5zm.62 3h-.62v1.25h7.12V11z" clip-rule="evenodd" fill="#666" fill-rule="evenodd"/></svg>
packages/harness/cortextos/dashboard/src/app/globals.css:172:  --foreground: oklch(0.187 0 0);                /* #1A1A1A */
packages/harness/cortextos/dashboard/src/app/globals.css:222:  --secondary: oklch(0.187 0 0);                 /* #1A1A1A */
packages/harness/cortextos/dashboard/src/app/globals.css:224:  --muted: oklch(0.187 0 0);                    /* #1A1A1A */
packages/harness/cortextos/dashboard/package-lock.json:39:        "@playwright/test": "^1.58.2",
packages/harness/cortextos/dashboard/package-lock.json:905:      "integrity": "sha512-hFoiJiTl63nn+kstHGBtewWSKnQLpyb155KHheA1l39uvtO9nWIop1p3udqPcUd/xbF1VLMO4n7OI6p7RbngDg==",
packages/harness/cortextos/dashboard/package-lock.json:1093:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:1106:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:1119:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:1140:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:1153:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:1166:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:1180:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:1244:        "node": ">=18.14.1"
packages/harness/cortextos/dashboard/package-lock.json:1257:        "node": ">=18.18.0"
packages/harness/cortextos/dashboard/package-lock.json:1271:        "node": ">=18.18.0"
packages/harness/cortextos/dashboard/package-lock.json:1295:        "node": ">=18.18"
packages/harness/cortextos/dashboard/package-lock.json:1325:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1347:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1503:      "integrity": "sha512-+LpyBk7L44ZIXwz/VYfglaX/okxezESc6UxDSoyo2Ks6Jxc4Y7sGjpgU9s4PMgqgjj1gZCylTieNamqA1MF7Dg==",
packages/harness/cortextos/dashboard/package-lock.json:1529:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1551:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1573:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1595:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1617:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1639:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1661:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1683:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1705:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1724:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1743:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1762:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:1903:        "ajv": "^8.17.1",
packages/harness/cortextos/dashboard/package-lock.json:1911:        "express-rate-limit": "^8.2.1",
packages/harness/cortextos/dashboard/package-lock.json:1937:      "version": "8.18.0",
packages/harness/cortextos/dashboard/package-lock.json:1938:      "resolved": "https://registry.npmjs.org/ajv/-/ajv-8.18.0.tgz",
packages/harness/cortextos/dashboard/package-lock.json:2741:        "react-redux": "^7.2.1 || ^8.1.3 || ^9.0.0"
packages/harness/cortextos/dashboard/package-lock.json:3327:        "@emnapi/core": "^1.8.1",
packages/harness/cortextos/dashboard/package-lock.json:3328:        "@emnapi/runtime": "^1.8.1",
packages/harness/cortextos/dashboard/package-lock.json:3332:        "tslib": "^2.8.1"
packages/harness/cortextos/dashboard/package-lock.json:3678:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:3714:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:3737:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:3758:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:3772:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:3796:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:3814:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:3839:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:3914:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:3936:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:3987:      "integrity": "sha512-gPVA1UjRu1Y/IsB/dQEsp2V1pm44Of6+LWvbLc9SDk1c2KhhDRDBUkQCYVWe6f26uJb3fOK8saWMgtX8IrMk3g==",
packages/harness/cortextos/dashboard/package-lock.json:4043:      "integrity": "sha512-cINaoY2z7LVCrfHkIcmvj7osTOtm6VVT16b5oQdS4beibX2SYBwgYLmqhBjA1t51CarSaBuX5YNsWLjsqfW5Cw==",
packages/harness/cortextos/dashboard/package-lock.json:4352:      "version": "8.16.0",
packages/harness/cortextos/dashboard/package-lock.json:4353:      "resolved": "https://registry.npmjs.org/acorn/-/acorn-8.16.0.tgz",
packages/harness/cortextos/dashboard/package-lock.json:4418:      "version": "8.18.0",
packages/harness/cortextos/dashboard/package-lock.json:4419:      "resolved": "https://registry.npmjs.org/ajv/-/ajv-8.18.0.tgz",
packages/harness/cortextos/dashboard/package-lock.json:4868:      "version": "4.28.2",
packages/harness/cortextos/dashboard/package-lock.json:4869:      "resolved": "https://registry.npmjs.org/browserslist/-/browserslist-4.28.2.tgz",
packages/harness/cortextos/dashboard/package-lock.json:4927:      "integrity": "sha512-zRpUiDwd/xk6ADqPMATG8vc9VPrkck7T07OIx0gnjmJAnHnTVXNQG3vfvWNuiZIkwu9KrKdA1iJKfsfTVxE6NA==",
packages/harness/cortextos/dashboard/package-lock.json:5094:      "integrity": "sha512-aCj4O5wKyszjMmDT4tZj93kxyydN/K5zPWSCe6/0AV/AA1pqe5ZBIw0a2ZfPQV7lL5/yb5HsUreJ6UFAF1tEQw==",
packages/harness/cortextos/dashboard/package-lock.json:5408:      "integrity": "sha512-tdQAmyA18i4J7wprpYq8ClcxZy3SC31QMeByyCFyRt7BVHdREQZ5lpzoe5mFEYZUWe+oq8HBvk9JjpibyEV4Jg==",
packages/harness/cortextos/dashboard/package-lock.json:6056:      "integrity": "sha512-zWwRvqWiuBPr0muUG/78cW3aHROFCNIQ3zpmYDpwdbnt2m+xlNyRWpHBpa2lJjSBit7BQ+RXA1iwbSmu5yJ/EQ==",
packages/harness/cortextos/dashboard/package-lock.json:6232:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:6249:      "integrity": "sha512-qhabwjQZ1Mk53XzXvmogf8KQ0tG0CQXF0CZ56+2/lVhmObgmaqj7x5A1DSrWdZd3kwI7GTPGUjFne+krRxYmFg==",
packages/harness/cortextos/dashboard/package-lock.json:6311:      "integrity": "sha512-A1rHYb06zjMGAxdLSkN2fXPBwuSaQ0iO5M/hdyS0Ajj1VBaRp0sPD3dn1FhME3c/JluGFbwSxyCfqdSbtQLAHQ==",
packages/harness/cortextos/dashboard/package-lock.json:6465:        "prop-types": "^15.8.1",
packages/harness/cortextos/dashboard/package-lock.json:6509:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:6522:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:6535:        "acorn": "^8.15.0",
packages/harness/cortextos/dashboard/package-lock.json:6540:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:6616:      "version": "1.8.1",
packages/harness/cortextos/dashboard/package-lock.json:6617:      "resolved": "https://registry.npmjs.org/etag/-/etag-1.8.1.tgz",
packages/harness/cortextos/dashboard/package-lock.json:6671:        "node": "^18.19.0 || >=20.5.0"
packages/harness/cortextos/dashboard/package-lock.json:6712:        "etag": "^1.8.1",
packages/harness/cortextos/dashboard/package-lock.json:7037:        "node": "^8.16.0 || ^10.6.0 || >=11.0.0"
packages/harness/cortextos/dashboard/package-lock.json:7221:      "integrity": "sha512-7tN6rFgBlMgpBML5j8typ92BKFi2sFQvIdpAqLA2beia5avZDrMs0FLZiM5etShWq5irVyGcGMEA1jcDaK7A/Q==",
packages/harness/cortextos/dashboard/package-lock.json:7482:        "node": ">=18.18.0"
packages/harness/cortextos/dashboard/package-lock.json:7563:        "node": ">=0.8.19"
packages/harness/cortextos/dashboard/package-lock.json:7836:      "integrity": "sha512-upqt1SkGkODW9tsGNG5mtXTXtECizwtS2kA161M+gJPc1xdb/Ax629af6YrTwcOeQHbewrPNlE5Dx7kzvXTizA==",
packages/harness/cortextos/dashboard/package-lock.json:7992:      "integrity": "sha512-bCYeRA2rVibKZd+s2625gGnGF/t7DSqDs4dP7CrLA1m7jKWz6pps0LpYLJN8Q64HtmPKJ1hrN3nzPNKFEKOUiQ==",
packages/harness/cortextos/dashboard/package-lock.json:9164:        "node": "^18.17.0 || >=20.5.0"
packages/harness/cortextos/dashboard/package-lock.json:9210:      "integrity": "sha512-OWND8ei3VtNC9h7V60qff3SVobHr996CTwgxubgyQYEpg290h9J0buyECNNJexkFm5sOajh5G116RYA1c8ZMSw==",
packages/harness/cortextos/dashboard/package-lock.json:9257:        "react": "^18.2.0 || 19.0.0-rc-de68d2f4-20241204 || ^19.0.0",
packages/harness/cortextos/dashboard/package-lock.json:9258:        "react-dom": "^18.2.0 || 19.0.0-rc-de68d2f4-20241204 || ^19.0.0",
packages/harness/cortextos/dashboard/package-lock.json:9289:        "react": "^18.2.0 || ^19.0.0"
packages/harness/cortextos/dashboard/package-lock.json:9681:      "version": "8.2.0",
packages/harness/cortextos/dashboard/package-lock.json:9682:      "resolved": "https://registry.npmjs.org/ora/-/ora-8.2.0.tgz",
packages/harness/cortextos/dashboard/package-lock.json:9979:      "integrity": "sha512-orRsuYpJVw8LdAwqqLykBj9ecS5/cRHlI5+nvTo8LcCKmzDmqVORXtOIYEEQuL9D4BxtA1lm5isAqzQZCoQ6Eg==",
packages/harness/cortextos/dashboard/package-lock.json:10023:      "integrity": "sha512-8Mf2cbV7x1cXPUILADGI3wuhfqWvtiLA1iclTDbFRZkgRQS0NqsPZphna9V+HyTEadheuPmjaJMsbzKQFOzLug==",
packages/harness/cortextos/dashboard/package-lock.json:10095:      "version": "15.8.1",
packages/harness/cortextos/dashboard/package-lock.json:10096:      "resolved": "https://registry.npmjs.org/prop-types/-/prop-types-15.8.1.tgz",
packages/harness/cortextos/dashboard/package-lock.json:10266:        "@types/react": "^18.2.25 || ^19",
packages/harness/cortextos/dashboard/package-lock.json:10392:      "version": "3.8.1",
packages/harness/cortextos/dashboard/package-lock.json:10393:      "resolved": "https://registry.npmjs.org/recharts/-/recharts-3.8.1.tgz",
packages/harness/cortextos/dashboard/package-lock.json:10531:      "integrity": "sha512-pb/MYmXstAkysRFx8piNI1tGFNQIFA3vkE3Gq4EuA1dF6gHp/+vgZqsCGJapvy8N3Q+4o7FwvquPJcnZ7RYy4g==",
packages/harness/cortextos/dashboard/package-lock.json:10791:        "etag": "^1.8.1",
packages/harness/cortextos/dashboard/package-lock.json:10910:        "ora": "^8.2.0",
packages/harness/cortextos/dashboard/package-lock.json:10991:        "node": "^18.17.0 || ^20.3.0 || >=21.0.0"
packages/harness/cortextos/dashboard/package-lock.json:11139:      "integrity": "sha512-bzyZ1e88w9O1iNJbKnOlvYTrWPDl46O1bG0D3XInv+9tkPrxrN8jUUTiFlDkkmKWgn1M6CfIA13SuGqOa9Korw==",
packages/harness/cortextos/dashboard/package-lock.json:11459:      "integrity": "sha512-vavAMRXOgBVNF6nyEEmL3DBK19iRpDcoIwW+swQ+CbGiu7lju6t+JklA1MHweoWtadgt4ISVUsXLyDq34ddcwA==",
packages/harness/cortextos/dashboard/package-lock.json:11773:        "node": ">=18.12"
packages/harness/cortextos/dashboard/package-lock.json:11816:      "version": "2.8.1",
packages/harness/cortextos/dashboard/package-lock.json:11817:      "resolved": "https://registry.npmjs.org/tslib/-/tslib-2.8.1.tgz",
packages/harness/cortextos/dashboard/package-lock.json:11989:        "node": "^18.18.0 || ^20.9.0 || >=21.1.0"
packages/harness/cortextos/dashboard/package-lock.json:12025:        "node": ">=20.18.1"
packages/harness/cortextos/dashboard/package-lock.json:12282:        "tsx": "^4.8.1",
packages/harness/cortextos/dashboard/package-lock.json:12336:        "node": "^8.16.0 || ^10.6.0 || >=11.0.0"
packages/harness/cortextos/dashboard/package-lock.json:12828:        "node": ">=18.19"
packages/harness/cortextos/community/agents/security/.claude/skills/system-diagnostics/SKILL.md:7:# System Diagnostics

codex
The shared ESC catalogue and schema are present, and the first pass already shows this is an agent bundle artefact being judged with an architecture-decision skill. I’m checking the live file lines and the cited master/spec sections now, because citation accuracy is load-bearing in this review.
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '485,505p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,620p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/README.md | sed -n '80,92p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    80	| _unknown_ | Emit `phase=gating_failed` (`fail-safe-red`) + escalate `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`, return 1 | 1 |
    81	
    82	## Telegram-down failure mode
    83	
    84	Per autosend-safety-policy §6 + plan §Phase 3 acceptance criterion #5: `autosend_await_approval` blocks for `timeout_seconds` (4h default from `autosend-policy.yaml` `defaults.approval_timeout`). PM2 + cortextOS primitive 1 keep the agent process alive during the block. Inter-agent bus-messaging to a 4h-blocked agent is fire-and-forget from the sender's perspective (cortextOS bus delivers asynchronously); blocked agent processes deferred messages when approval resolves.
    85	
    86	**Tested:** `HH_AWAIT_TEST_MODE=timeout` short-circuits the poll loop and exercises the timeout path; verified in `tests/test-hook-helpers.sh` test #7.
    87	
    88	**Not tested:** the full 4h wall-clock timeout in production. First Diagnostic agent build (Week 3) is the natural place to exercise this — Diagnostic uses `diagnostic_email_send` (orange tier, PT4H timeout).
    89	
    90	## Testing
    91	
    92	```bash

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
/bin/zsh -lc "rg --files | rg 'common-(voice|target|target-patch)|autosend.*policy|sequencing-target|tenant-lifecycle|ADR-003|ADR-004|v1.0-kill'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml
packages/agents-runtime/_shared/common-voice.json
packages/agents-runtime/_shared/common-target-patch.json
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/autosend-safety-policy.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/sequencing-target.md
docs/runbooks/tenant-lifecycle.md
logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_v1-0-kill-criterion-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_sequencing-target-md.output.md
logs/codex-ratification/round-2-autonomous/docs_runbooks_tenant-lifecycle-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_ADR-003-agent-bundle-renderer-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md

exec
/bin/zsh -lc "rg -n \"diagnostic_email_send|diagnostic_report_render|green|orange|PT4H|approval_timeout|tier\" docs agents packages -g '*autosend*' -g '*.yaml' -g '*.md'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:86:          Items enum: ["vault_emails", "bullhorn_notes", "marketing_copy", "founder_curated", "consultant_drafts"]. Order documents provenance for the LoRA pipeline (v2.0 Scale tier).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:400:    v0_2_default: A; matches Ultraplan §5.3 retry budget for green-path agents
agents/_shared/README.md:12:| `autosend-policy.yaml` | Runtime tier table — 29 action_types per autosend-safety-policy §3 | 3 |
agents/_shared/README.md:61:autosend_policy_lookup        <action_type>                                          # prints tier
agents/_shared/README.md:62:autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>               # prints possibly-elevated tier
agents/_shared/README.md:63:autosend_emit_decision_log    <phase> <tier> <action_type> <target> <hash> <preview> <reason>
agents/_shared/README.md:70:## Auto-send tier dispatch (autosend-safety-policy §4)
agents/_shared/README.md:72:`hh_decision_action` dispatches per tier:
agents/_shared/README.md:76:| **green** | Emit `phase=action`, return 0 immediately | 0 |
agents/_shared/README.md:78:| **orange** | Emit `phase=action` + escalate `ESC_AUTOSEND_NEEDS_REVIEW`, block on approval gate, return 0/1 | depends on approval |
agents/_shared/README.md:84:Per autosend-safety-policy §6 + plan §Phase 3 acceptance criterion #5: `autosend_await_approval` blocks for `timeout_seconds` (4h default from `autosend-policy.yaml` `defaults.approval_timeout`). PM2 + cortextOS primitive 1 keep the agent process alive during the block. Inter-agent bus-messaging to a 4h-blocked agent is fire-and-forget from the sender's perspective (cortextOS bus delivers asynchronously); blocked agent processes deferred messages when approval resolves.
agents/_shared/README.md:88:**Not tested:** the full 4h wall-clock timeout in production. First Diagnostic agent build (Week 3) is the natural place to exercise this — Diagnostic uses `diagnostic_email_send` (orange tier, PT4H timeout).
agents/_shared/README.md:127:     AND payload->>'tier' = 'red'
agents/_shared/README.md:177:- `docs/decisions/autosend-safety-policy.md` — full tier model + §4 reference impl
agents/_shared/README.md:178:- `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 5 — red-tier breach kill criterion
agents/_shared/escalation-codes.md:20:payload           — JSON object: {tier?, action_type?, target?, payload_hash?, reason, ...code-specific fields}
agents/_shared/escalation-codes.md:35:- **Trigger:** Orange-tier action queued for tenant operator review
agents/_shared/escalation-codes.md:38:- **Timeout:** 4h default per `common-notifications.json.default_approval_timeout_seconds`; on timeout, converts to manual reconciliation
agents/_shared/escalation-codes.md:39:- **Payload fields:** `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `approval_status='pending'`
agents/_shared/escalation-codes.md:43:- **Trigger:** Red-tier action attempted; refused entirely (red is the tier-override floor per autosend §8)
agents/_shared/escalation-codes.md:46:- **Payload fields:** `tier='red'`, `action_type`, `target`, `payload_hash`, `reason='red_tier_classification'`
agents/_shared/escalation-codes.md:50:- **Trigger:** `autosend_policy_lookup()` could not resolve a tier for the given `action_type` (unknown action_type, malformed `autosend-policy.yaml`, or tenant override resolution failed)
agents/_shared/escalation-codes.md:53:- **Payload fields:** `tier='fail-safe-red'`, `action_type`, `target`, `reason` (one of `unknown_action_type`, `override_resolution_failed`, `unknown_tier:<value>`)
agents/_shared/escalation-codes.md:54:- **Fail-safe behaviour:** Action refused regardless of declared tier
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) consultant-approved orange-tier payment-chase email drafts queued to Concierge for send (Concierge handles the actual send; Cash Conductor only drafts), and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO Bullhorn dependency — Cash Conductor operates entirely against the tenant's accounting + Open Banking stack, making it the most-independent v1.0 agent (per ADR-005 §5.1: this independence is its strategic value when Bullhorn paths are delayed). Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 539). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 539 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 540) — the FD-tier closer metric. Chase drafts are orange-tier per `autosend-safety-policy.yaml` (consultant approval required before send via Concierge); reconciliation writes are yellow-tier.
agents/recruitment/cash-conductor/agent.md:72:### Output 1 — Reconciliation rows (yellow tier)
agents/recruitment/cash-conductor/agent.md:84:Stages 1-2 auto-write reconciliation to accounting system (yellow tier; spot-check sampled). Stages 3-4 queue for consultant review. Stage 5 flagged in weekly report.
agents/recruitment/cash-conductor/agent.md:86:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:88:### Output 2 — Payment-chase drafts (orange tier)
agents/recruitment/cash-conductor/agent.md:90:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. Output is a queued draft, NOT a send. Drafts route to Concierge (which handles the actual send pipeline + consultant approval per autosend §4 orange tier).
agents/recruitment/cash-conductor/agent.md:104:expected_send_window: orange-tier approval expected within 24h
agents/recruitment/cash-conductor/agent.md:107:Each draft: `decision_log` row `agent_name='cash_conductor'`, `phase='output'`, `action_type='chase_draft'`, `tier='orange'`, payload includes the draft.
agents/recruitment/cash-conductor/agent.md:169:   → write Stage 1-2 matches to accounting (yellow tier) atomically
agents/recruitment/cash-conductor/agent.md:173:6. Reconciliation write (yellow tier; per match)
agents/recruitment/cash-conductor/agent.md:177:   → spot-check sampling per autosend-safety-policy.yaml yellow tier
agents/recruitment/cash-conductor/agent.md:202:10. Chase-draft queue to Concierge (orange tier)
agents/recruitment/cash-conductor/agent.md:207:      tier=orange; awaiting operator approval
agents/recruitment/cash-conductor/agent.md:252:### Gate B — Outcome threshold (FD-tier closer metric)
agents/recruitment/cash-conductor/agent.md:260:This is THE FD-tier closer metric per master brief §8.2 line 597. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:8:# 29 v1.0 action_types: 6 green + 5 yellow + 10 orange + 8 red.
agents/_shared/autosend-policy.yaml:10:#   tier            green|yellow|orange|red
agents/_shared/autosend-policy.yaml:15:#   timeout         orange only: ISO-8601 duration; default PT4H if absent
agents/_shared/autosend-policy.yaml:29:  diagnostic_report_render:
agents/_shared/autosend-policy.yaml:30:    tier: green
agents/_shared/autosend-policy.yaml:36:    tier: green
agents/_shared/autosend-policy.yaml:42:    tier: green
agents/_shared/autosend-policy.yaml:48:    tier: green
agents/_shared/autosend-policy.yaml:54:    tier: green
agents/_shared/autosend-policy.yaml:60:    tier: green
agents/_shared/autosend-policy.yaml:70:    tier: yellow
agents/_shared/autosend-policy.yaml:77:    tier: yellow
agents/_shared/autosend-policy.yaml:84:    tier: yellow
agents/_shared/autosend-policy.yaml:91:    tier: yellow
agents/_shared/autosend-policy.yaml:98:    tier: yellow
agents/_shared/autosend-policy.yaml:109:    tier: orange
agents/_shared/autosend-policy.yaml:111:    timeout: PT4H
agents/_shared/autosend-policy.yaml:117:    tier: orange
agents/_shared/autosend-policy.yaml:119:    timeout: PT4H
agents/_shared/autosend-policy.yaml:124:    tier: orange
agents/_shared/autosend-policy.yaml:131:    tier: orange
agents/_shared/autosend-policy.yaml:133:    timeout: PT4H
agents/_shared/autosend-policy.yaml:138:    tier: orange
agents/_shared/autosend-policy.yaml:140:    timeout: PT4H
agents/_shared/autosend-policy.yaml:145:    tier: orange
agents/_shared/autosend-policy.yaml:151:  diagnostic_email_send:
agents/_shared/autosend-policy.yaml:152:    tier: orange
agents/_shared/autosend-policy.yaml:154:    timeout: PT4H
agents/_shared/autosend-policy.yaml:159:    tier: orange
agents/_shared/autosend-policy.yaml:161:    timeout: PT4H
agents/_shared/autosend-policy.yaml:166:    tier: orange
agents/_shared/autosend-policy.yaml:168:    timeout: PT4H
agents/_shared/autosend-policy.yaml:173:    tier: orange
agents/_shared/autosend-policy.yaml:175:    timeout: PT4H
agents/_shared/autosend-policy.yaml:184:    tier: red
agents/_shared/autosend-policy.yaml:191:    tier: red
agents/_shared/autosend-policy.yaml:198:    tier: red
agents/_shared/autosend-policy.yaml:205:    tier: red
agents/_shared/autosend-policy.yaml:212:    tier: red
agents/_shared/autosend-policy.yaml:219:    tier: red
agents/_shared/autosend-policy.yaml:226:    tier: red
agents/_shared/autosend-policy.yaml:233:    tier: red
agents/_shared/autosend-policy.yaml:244:  approval_timeout: PT4H        # Default orange-tier approval window per §8 rule 5
agents/_shared/autosend-policy.yaml:254:  - "tier ∈ {green, yellow, orange, red}"
agents/_shared/autosend-policy.yaml:256:  - "orange action_types MUST declare timeout (ISO-8601 duration)"
agents/_shared/autosend-policy.yaml:258:  - "tenant overrides may only ELEVATE tier (green→yellow→orange→red); red is floor"
agents/_shared/autosend-policy.yaml:259:  - "29 total action_types (6 green + 5 yellow + 10 orange + 8 red); v1.0 frozen"
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:11:## D1 — Auto-send v1.0 tier enforcement (orange-tier behavior)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:14:- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:15:- `docs/decisions/autosend-safety-policy.md` §9 (says "v1.0 ships green + red only")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:18:**Codex's framing:** "v1.0 tier semantics are internally contradictory. Lines 41-68 define four tiers and line 43 says every governed action falls into exactly one tier at execution, but lines 474-481 say v1.0 ships green + red only while orange approval is handled outside the policy pipeline. ... Canonical orange actions are described as v1.0-mitigated, but orange is not implemented in v1.0."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:20:**Real issue:** 10 action_types (including the canonical orange `bullhorn_note_customer_visible` — Concierge's primary outbound action) are classified as orange. v1.0 ships green+red only. In v1.0, those orange action_types must either:
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:23:- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:24:- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:26:**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:142:| **D1** (autosend v1.0 tier) | This week | Concierge build scope (W10-13) |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:160:Founder picks D1-C: ship orange-as-red default + manual override.
docs/verticals/recruitment/vertical-schema.yaml:335:        notes: Hard gate for autosend orange-tier actions; default false; set true on opt-out.
docs/verticals/recruitment/vertical-schema.yaml:337:      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
docs/verticals/recruitment/vertical-schema.yaml:338:      - v1.1 Triage expands: structured decision-authority (budget tier, decision domain, escalation chain), engagement history aggregate, preferred-channel sentiment.
docs/verticals/recruitment/vertical-schema.yaml:492:      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
docs/verticals/recruitment/vertical-schema.yaml:726:    contact: R       # decision-maker resolution for orange-tier sends
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:823:    v1_1_plus_expansion: Sub-fields for decision-domain (technical/budget/strategic), authority tier (final/recommend/influence/observer), engagement history aggregate, preferred-channel sentiment.
docs/architecture/architecture-cohesion-review.md:148:| G2 | **The `tenants` table life-cycle states.** `tenants.metadata` JSONB has no documented shape. What goes in: `status` enum? `tier` cache? `provisioned_at`? `last_offboard_warning_at`? | Medium (tenant-lifecycle runbook depends on it) | Surfaced in tenant-lifecycle.md (same commit). Real implementation lands at first tenant onboarding. |
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
docs/architecture/architecture-cohesion-review.md:228:| R2 | G8: Autosend v1.0 tier enforcement | High | Founder Decision D1 | Founder | Pre-Concierge W10 |
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:65:### Output 2 — Bullhorn writes (yellow tier)
agents/recruitment/janitor/agent.md:73:Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type='bullhorn_candidate_merge' | 'bullhorn_field_backfill' | 'bullhorn_note_attach'`, `tier='yellow'`, payload includes source confidence + provenance.
agents/recruitment/janitor/agent.md:136:9. Bullhorn write batch (yellow tier — spot-check sampling)
agents/recruitment/janitor/agent.md:138:     tier='yellow'; spot-check sample rate per autosend-policy.yaml row
agents/recruitment/janitor/agent.md:152:   → if Gate-B target met: green-tier notification with summary
agents/recruitment/janitor/agent.md:153:   → if Gate-B target missed: yellow-tier notification + 200-char executive
agents/recruitment/janitor/agent.md:186:Gate B doesn't block the agent. It's the v1.0 kill-criterion §2 Trigger 8 supporting metric ("Gate-B revenue uplift" — Janitor's day-30 report is THE artefact that demonstrates "DSO drops" / "consultant time saved" claims to the FD-tier closer).
agents/recruitment/janitor/agent.md:205:| `ESC_AUTOSEND_YELLOW_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
agents/recruitment/janitor/agent.md:210:- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Janitor doesn't do red writes
docs/architecture/agent-bundle-renderer-design.md:203:tier: 1
agents/recruitment/concierge/README.md:14:The customer-comms agent. Highest-stakes v1.0 agent (XL complexity, 4 weeks build). 12 lifecycle events × 2 recipient roles = 24+ comms-template variants per tenant. Orange-tier autosend per `autosend-safety-policy.yaml` — consultant approval mandatory before send.
agents/recruitment/concierge/README.md:35:**Founder Decision D1 (autosend orange-tier path) MUST be resolved before W10 build starts.** Per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Three options:
docs/architecture/cortexos-primitive-status.md:66:**Risk if flaky:** Tier-1 always-on agents collapse to scheduled cron with cold-start latency, eliminating the "sub-second to first useful action" claim that justifies pricing the Triage/Concierge/Pulse demos above point-tool parity (Ultraplan §3.2). Per Ultraplan §3.1 row 1, the documented contingency is: "Ship the v1.0 agents as scheduled cron with a documented migration path. Loses the Triage closing demo but keeps the build moving." Quirk 2 (`.agents/learnings/00-cortextos-quirks.md`) — `node-pty` requires `npm rebuild` on Node 25+ — is the most likely re-trip wire because the Mac Studio cluster nodes for the v2.0 Sovereign tier may not run Node 22 LTS by default.
docs/architecture/cortexos-primitive-status.md:101:Two complementary mechanisms ship: a wall-clock session timer at exactly 71 hours (255600s) plus a context-percentage tiered handoff system that fires earlier when actual token usage crosses configurable thresholds. Both have regression-named bug fixes and dedicated test files. No Day-0 brittleness evidence.
docs/architecture/cortexos-primitive-status.md:107:- `src/daemon/fast-checker.ts:899-1003` — `checkContextStatus()` polls `${stateDir}/context_status.json` written by the `hook-context-status` statusLine bridge. Three tiers: Tier 1 warning at `ctx_warning_threshold` default 70% injects `[CONTEXT] Window at X%`, Tier 2 handoff at `ctx_handoff_threshold` default 80% writes the handoff prompt and `.force-fresh` marker (line 996-1000), Tier 3 force-restart 5 minutes after Tier 2 if the agent didn't comply (line 962-967).
docs/architecture/cortexos-primitive-status.md:256:- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
docs/architecture/cortexos-primitive-status.md:460:**Risk if flaky:** Brief Decoder slips to v1.2 — the documented contingency in Ultraplan §3.1 row 3. Loses the "shortlist in 90 minutes" demo for the Growth tier. The "orchestrator-coupled Telegram polling" trade-off (`agent-manager.ts:465-472`) means if the orchestrator agent itself crashes, the activity-channel callbacks stop until restart — primitive 1's crash-loop alert covers that case.
docs/architecture/cortexos-primitive-status.md:503:- **Q2 (primitives 1, 4, 5):** all three present and tested. Primitive 1 carries Day-0 brittleness (quirks 2 + 3, prior restart storm) — closes when the verification commands above run green on `ifos-v2`. Primitive 4 + 5 are green now subject to a live round-trip.
packages/agent-renderer/templates/claude-md-preamble.md:35:- Operating window: {{operating_window}} ({{tier}})
packages/agent-renderer/templates/claude-md-preamble.md:63:Auto-send tier policy per `_shared/autosend-policy.yaml`. Tenant override file (if present): `/vault/{{tenant_slug}}/_config/autosend-overrides.yaml` — read by `autosend_apply_tenant_override` per `docs/decisions/autosend-safety-policy.md` §4.
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown attachment containing the consultant's "things I'd write down but there's no field for" observations. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:82:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:176:8. Bullhorn write — structured fields (yellow tier)
agents/recruitment/scribe/agent.md:181:9. Bullhorn write — tacit-note attachment (yellow tier)
agents/recruitment/scribe/agent.md:243:| `ESC_AUTOSEND_YELLOW_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
agents/recruitment/scribe/agent.md:247:- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
agents/recruitment/diagnostic/tools.yaml:15:tier: 2  # request-driven; no persistent PTY (per sequencing-target.md §2.1)
agents/recruitment/diagnostic/tools.yaml:170:  - bullhorn       # Diagnostic is sales-tool tier; no ATS touch per sequencing-target.md §2.1
docs/decisions/autosend-approval-bridge-spec.md:14:Autosend-safety-policy §3 declares 10 v1.0 action_types as **orange tier** — most importantly the canonical orange `bullhorn_note_customer_visible` (Concierge's primary outbound action). Orange-tier actions require per-action human approval via Telegram before executing.
docs/decisions/autosend-approval-bridge-spec.md:142:| `diagnostic_email_send` | `external-comms` |
docs/decisions/autosend-approval-bridge-spec.md:245:| A7 | category mapping table covers all 10 v1.0 orange action_types | Lint test: every orange action_type in autosend-policy.yaml has a mapping entry |
agents/recruitment/diagnostic/agent.md:145:    → hh_decision_action("diagnostic_report_render", "firm:{slug}", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:146:    → action tier per autosend-policy.yaml: green (no external send; vault write only)
agents/recruitment/diagnostic/agent.md:189:- `ESC_AUTOSEND_*` — Diagnostic's only action is `diagnostic_report_render` (green tier per autosend-policy.yaml)
agents/recruitment/diagnostic/agent.md:253:2. **Companies House rate limits — cache aggressively.** Free tier is 600 requests per 5-minute window per IP. Cache responses for 7 days per (company_number) key. Pre-emptive 60s backoff on first 429.
agents/recruitment/diagnostic/fixtures/01-primary.yaml:106:    action_type: diagnostic_report_render
packages/agent-renderer/README.md:120:- **Telegram-down hang for orange-tier autosend** (autosend-safety-policy §5) is a Phase-3 concern in `hook-helpers.sh` `autosend_await_approval`, not a renderer concern. Documented for completeness.
docs/decisions/2026-05-18-codex-ratification-manifest.md:31:| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:166:| 16 | autosend-safety-policy.md | REJECTED (3 issues) | Issues 1+2 (tier contradiction) → **Founder Decision D1** in `2026-05-20-codex-round-1-founder-decisions.md`. Issue 3 (legal placeholder) → **Founder Decision D2 + D3** in same briefing. No inline incorporation; founder picks. |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:30:- **Without Sub-decision A answered, Week-3 Bullhorn-MCP work is structurally blocked:** we don't know whether marketplace registration is required for production OR whether direct-tier developer-program access suffices.
agents/recruitment/concierge/agent.md:3:**Status:** Proposed (Day-19 pre-W10-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice).
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Drafts are orange-tier per `autosend-safety-policy.yaml` — consultant approval required before send via the autosend-bridge mechanism (Founder Decision D1 path A bridge OR D1-B shim OR D1-C manual; W10 design selects). Sends route via tenant's Microsoft Graph OR Gmail (per-tenant config; AgentMail deferred to v1.1+). Gate A hard-fails any draft generated >30 minutes after lifecycle event, any draft with voice classifier <0.75, or any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). Gate B success threshold: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:67:One output per lifecycle event: an email draft (orange tier). 12 lifecycle events × per-tenant comms-template variants:
agents/recruitment/concierge/agent.md:102:Each draft: `decision_log` row with `agent_name='concierge'`, `phase='action'`, `action_type='concierge_draft_<event_type>'`, `tier='orange'`, payload includes voice_score + recipient + escalation_position.
agents/recruitment/concierge/agent.md:160:   → else: escalation_position=1 (standard orange tier)
agents/recruitment/concierge/agent.md:194:    → per autosend-policy.yaml: orange-tier; consultant approves
agents/recruitment/concierge/agent.md:272:| `ESC_AUTOSEND_BLOCKED` | Send attempted on red-tier action OR Gate A failed | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:276:| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Orange-tier sample row selected for audit | info | operator_chat_id |
agents/recruitment/concierge/agent.md:322:| **Founder Decision D1 (autosend orange-tier path)** RESOLVED | Founder decision; awaits review of D1-A/B/C spec | ⏸ |
agents/recruitment/concierge/agent.md:347:| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
packages/agent-renderer/tests/fixtures/test-tenant-vault/test-tenant-b/_config.yaml:4:tier: "growth"
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:101:    action_type: diagnostic_report_render
packages/agent-renderer/tests/fixtures/test-tenant-vault/migration-test/_config.yaml:4:tier: "boutique"
docs/decisions/v1.0-kill-criterion.md:109:**Threshold:** More than 3 confirmed red-tier autosend breaches per pilot per week from actions that should have been classified as green or yellow. "Confirmed" means: tenant operator files a `false-block` feedback report via Brain UI (or equivalent v1.0 manual channel) AND IFOS oncall agrees the tier classification was wrong. Threshold measured per individual pilot over rolling 7-day windows.
docs/decisions/v1.0-kill-criterion.md:111:**Owner:** IFOS oncall + tenant operator. Daily check via `decision_log` queries: `SELECT COUNT(*) FROM decision_log WHERE phase='gating_failed' AND payload->>'tier'='red' AND payload->>'block_reason'='red_tier_classification' AND tenant_slug=? AND created_at > NOW() - INTERVAL '7 days'`.
docs/decisions/v1.0-kill-criterion.md:115:**Action:** PAUSE for the affected pilot. The agent that produced the miscategorisations halts at next session boundary. Founder + Jack review the policy tier classifications within 48 hours. Policy revision (via Codex ratification) lands as a new commit; affected pilot receives incident report. Pilot resumes after policy revision.
docs/decisions/v1.0-kill-criterion.md:117:**Escalation path:** If three pilots experience this trigger within one quarter, escalate to system-wide PAUSE while structural autosend policy redesign happens (potential v1.1 advancement of orange tier).
docs/decisions/v1.0-kill-criterion.md:121:**Threshold:** Cost-per-completed-action (defined as: total IFOS infrastructure + API + Claude inference cost ÷ count of `decision_log` rows with `phase='action'` and `payload.tier IN ('green','yellow','orange-approved')`) exceeds **£0.50 per action** after 4 tenant-weeks of operation.
docs/decisions/v1.0-kill-criterion.md:128:- Bullhorn API call at <£0.001 per action (free tier)
docs/decisions/v1.0-kill-criterion.md:136:**Action:** PIVOT — likely vector: cheaper Claude model tier (Haiku 4.5 for routine actions, Sonnet for complex), or reduced agent run frequency (e.g., Sourcing Scout runs nightly batch instead of real-time), or per-tenant cost passthrough in pricing.
docs/decisions/v1.0-kill-criterion.md:224:- **Trigger 6 (Unit economics):** founder decides PIVOT direction (cheaper model tier, reduced agent frequency, etc.) → consults Jack on pricing implications before locking → updates Ultraplan pricing plan.
docs/decisions/v1.0-kill-criterion.md:337:- The autosend safety policy per this Day 5 commit (green + red tiers only)
docs/decisions/v1.0-kill-criterion.md:349:- Adds yellow + orange autosend tiers per `autosend-safety-policy.md` §9
docs/architecture/second-brain-design.md:190:└── temp/                                           ← if Temp tier active (Ultraplan §5.1 line 220) — v1.1+ deferred for IFOS Temp launch
docs/architecture/second-brain-design.md:310:relationship_tier: key-account                       # optional v1.0; one of {key-account, active, dormant, ex-client}
docs/architecture/second-brain-design.md:471:  tier              TEXT NOT NULL,                       -- one of {solo, boutique, growth, scale, compliance-core, compliance-ops, full-temp}
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:891:| **Operational complexity** — new infrastructure introduced | None new. 12 shell wrappers + a Node CLI binary + a library; same shape as `packages/harness/cortextos/bus/`. No new PM2 process. | One new PM2 process per machine (`ifos-wiki-mcp`). Adds to the operations surface: process supervision, restart policy, port allocation, logs to manage. At Sovereign tier (one cluster slice per tenant per Ultraplan §5.4) this is one extra process per tenant. | Skill files added to every agent at scaffold time. Under R2 renderer (recommended), the renderer must be extended to inject the wiki skill — additional renderer logic. Under R1, automatic. |
docs/architecture/second-brain-design.md:908:3. **Master brief §3.5 + §5.5 (multi-tenancy + onboarding wizard 5-day flow).** §3.5's "100 customers by end of 2027" stress test (Product Spec §5.4) demands zero per-customer operational drag. Option α adds no per-customer infrastructure. Option β at Sovereign tier (Ultraplan §5.4 per-tenant cluster slice) means one `ifos-wiki-mcp` process per Sovereign tenant — a new operational surface to monitor at scale.
docs/architecture/second-brain-design.md:983:**Master brief §5.5's v1.0 minimum brain build stays at weeks 11-13, but the scope is materially clarified.** The "shadow four files + 2 .ts files" framing is replaced by "9 wiki-*.sh parallel wrappers + 9 wiki/lib/*.ts modules + 4 Postgres tables with RLS + pgvector for voice samples." Total v1.0 effort: ~11-13 person-days, fitting the 15-day budget. **Three Week-1 prerequisites move into focus:** ADR-003 renderer design (without it, no IFOS agent can run), `vault-concurrency.md` companion document (without it, the `flock`+Postgres-optimistic-concurrency code can't be reviewed), and `agents/_shared/{voice-loader,hook-helpers}.sh` (without these, the wiki library has no calling conventions). **One Day-4 (this week) tightening:** the Postgres schema migration from `entity_graph` (single table) to `entities` + `entity_links` (two tables) is part of the master brief §6 Day 4 infra task, not deferred. v1.2 graph view and v2.0 LoRA scale-tier are forward-compatible under the chosen Option α with no architectural changes.
docs/decisions/sequencing-target.md:24:| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/runbooks/operational-hygiene-protocol.md:164:| **Decision artefact** | Per tier/trigger/option × support | 30-60 lines (incl. examples + escalation) | autosend-safety-policy.md (4 tiers + 29 action_types + 3 ESC codes + 11 sections ≈ 650 lines) |
docs/runbooks/operational-hygiene-protocol.md:170:1. Count sub-units (decisions, mechanisms, sections, tiers, entities, etc.)
docs/runbooks/operational-hygiene-protocol.md:217:grep -nE "\b[0-9]+ (entities|fields|action_types|relationships|triggers|tiers|sections|edits|items)" <artefact>
docs/runbooks/operational-hygiene-protocol.md:284:Day-5 autosend policy §3 + §10 cited `bullhorn-integration-path.md §4.1` as the canonical-orange anchor for Concierge `bullhorn_note_customer_visible`. Verified §4.1 establishes the action exists but does not explicitly frame as sensitive auto-send. Sensitivity framing lives in §6.3 ("Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI").
docs/runbooks/operational-hygiene-protocol.md:302:- `bullhorn-integration-path.md §4.1 + §6.3` (canonical-orange anchor) — ✅ verified both sections exist and contain claimed content
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:4:description: "Framework protocol for responding to Claude Max API usage thresholds. Three-tier wind-down and recovery. Agent-specific behavior belongs in deployment config, not here."
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:10:> Framework-level protocol. Defines tiers and check mechanism only.
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:11:> Agent-specific behavior at each tier belongs in your deployment's CLAUDE.md or config.json.
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:64:- Report status to user via Telegram if transitioning into this tier from normal operations
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:102:Check usage every 15 minutes and apply tier logic:
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:112:**Configurable thresholds:** The `--warn-7day` and `--warn-5h` flags on `check-usage-api` are independent early-warning alerts sent to Telegram. They fire below the tier thresholds defined above and serve as a heads-up before tier behavior kicks in.
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:123:- The tier thresholds (85 / 95 / 20%)
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:125:- The generic behavior description for each tier
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:129:- Which specific crons to suspend at each tier
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:130:- Whether to notify Dane, the user, or other agents on tier transitions
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:148:*Framework protocol — no AscendOps-specific content. Agent behavior at each tier is deployment-defined.*
docs/operations/bullhorn-outreach-emails.md:49:> Is membership in the Marketplace Partner Programme required for production tenants to connect Intel Force OS to their Bullhorn instances? Or can pilot tenants authorise us as a connected app via the standard developer-tier path (support-ticket-issued client_id/client_secret per https://bullhorn.github.io/Getting-Started-with-REST)?
docs/operations/bullhorn-outreach-emails.md:55:> Are there API rate-limit, scope, or endpoint deltas between marketplace-tier and direct-tier access at small pilot volume? Specifically: do marketplace partners get elevated rate limits, write access to entity types not available to direct-tier, or webhook subscription endpoints that the documented REST API doesn't expose?
docs/operations/bullhorn-outreach-emails.md:58:> If marketplace tier grants Intel Force OS application-level credentials (one client_id per IFOS app), per-tenant onboarding could be reduced to a single OAuth dance per pilot tenant. Confirming this is the marketplace model (vs each tenant raising their own support ticket as documented for direct-tier).
docs/operations/bullhorn-outreach-emails.md:73:- If they confirm direct-tier works for pilot scale → Sub-decision A flips to **Direct API**; Status: Accepted. Update `bullhorn-integration-path.md` §5.
docs/operations/bullhorn-outreach-emails.md:75:- If they offer a Bullhorn Developer Program intermediate tier → that's likely the right path for 2026 H2 pilots; defer marketplace to v1.1+.
docs/operations/bullhorn-outreach-emails.md:108:> Is there a sandbox / staging Bullhorn environment we can use for development without consuming production-tier API budget? If yes, what's the access path (separate credentials, sandbox-only client_id, or in-production with a "test corpToken")?
docs/operations/bullhorn-outreach-emails.md:111:> Does Bullhorn's OAuth 2.0 implementation support the client_credentials grant type for service-account-style access (against our own developer-tier tenant, not pilot tenants)? We want to use this for IFOS-internal CI testing and connector unit-test fixtures. The public docs reference only authorization-code grant.
docs/operations/bullhorn-outreach-emails.md:126:**Expected response time:** 2-5 business days (often faster for technical-tier developer support than partnerships).
docs/runbooks/tenant-lifecycle.md:54:| `tier` | Pricing decision | solo | boutique | growth | scale |
docs/runbooks/tenant-lifecycle.md:72:  VALUES ('${SLUG}', '<legal_name>', '{\"status\":\"provisioning\",\"tier\":\"<tier>\",\"provisioned_at\":\"$(date -u +%FT%TZ)\"}'::jsonb);"
docs/runbooks/tenant-lifecycle.md:100:tier: <tier>
docs/runbooks/tenant-lifecycle.md:148:| Agent draft + approve via Telegram | `hh_decision_action` writes to decision_log; orange-tier blocks on Telegram approval | T4 (every write sets SET LOCAL) |
docs/decisions/autosend-safety-policy.md:39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
docs/decisions/autosend-safety-policy.md:45:Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.
docs/decisions/autosend-safety-policy.md:49:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
docs/decisions/autosend-safety-policy.md:55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:67:Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
docs/decisions/autosend-safety-policy.md:73:## §3 — Examples per tier across the v1.0 agent surface
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:79:| Agent | action_type | Why green |
docs/decisions/autosend-safety-policy.md:81:| Diagnostic | `diagnostic_report_render` | Internal artefact write; no external comms; idempotent (re-render overwrites) |
docs/decisions/autosend-safety-policy.md:100:| Agent | action_type | Why orange |
docs/decisions/autosend-safety-policy.md:108:| Diagnostic | `diagnostic_email_send` | Outbound diagnostic report to prospect; sales-stage outreach; reputation |
docs/decisions/autosend-safety-policy.md:157:  # 1. Policy lookup — read tier from the canonical policy table
docs/decisions/autosend-safety-policy.md:158:  local tier
docs/decisions/autosend-safety-policy.md:159:  tier=$(autosend_policy_lookup "$action_type") || {
docs/decisions/autosend-safety-policy.md:166:  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
docs/decisions/autosend-safety-policy.md:173:  case "$tier" in
docs/decisions/autosend-safety-policy.md:174:    green)
docs/decisions/autosend-safety-policy.md:175:      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:185:    orange)
docs/decisions/autosend-safety-policy.md:186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
docs/decisions/autosend-safety-policy.md:193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:194:      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:198:      # Fail-safe: unknown tier → red
docs/decisions/autosend-safety-policy.md:199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:200:      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:215:Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
docs/decisions/autosend-safety-policy.md:220:  - bullhorn_brief_read              # green
docs/decisions/autosend-safety-policy.md:221:  - bullhorn_candidate_query         # green
docs/decisions/autosend-safety-policy.md:223:  - bullhorn_note_customer_visible   # orange (CANONICAL — bullhorn-integration-path §4.1)
docs/decisions/autosend-safety-policy.md:224:  - gmail_outlook_send_to_candidate  # orange
docs/decisions/autosend-safety-policy.md:225:  - calendar_invite_send             # orange
docs/decisions/autosend-safety-policy.md:226:  - twilio_sms_send                  # orange
docs/decisions/autosend-safety-policy.md:239:**Tier:** orange
docs/decisions/autosend-safety-policy.md:240:**Fires when:** an orange-tier action is invoked; opens cortextOS approval gate (primitive 4)
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:283:**Fires when:** a red-tier action is invoked; blocked unconditionally
docs/decisions/autosend-safety-policy.md:292:  "block_reason": "<enum: red_tier_classification | blocked_recipient | unauthorized_adapter | cross_tenant_violation | payment_action | billing_modification | legal_artefact | pii_geographic_breach>",
docs/decisions/autosend-safety-policy.md:302:3. Operator may file a `false-block` feedback report via Brain UI if the tier classification seems wrong; report becomes input to next policy review
docs/decisions/autosend-safety-policy.md:304:**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).
docs/decisions/autosend-safety-policy.md:314:Block reason: payment_action (red-tier; never auto-sent in v1.0)
docs/decisions/autosend-safety-policy.md:330:  "lookup_error": "<enum: unknown_action_type | policy_table_corrupt | override_resolution_failed | tenant_not_found | unknown_tier:<value>>",
docs/decisions/autosend-safety-policy.md:338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
docs/decisions/autosend-safety-policy.md:353:| Policy file references undefined tier | Tier dispatch hits `*)` default | `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` with `lookup_error='unknown_tier:<value>'` | Policy file fixed; Codex ratifies; redeploy |
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:357:| Telegram primitive 5 unavailable (bot down, chat_id invalid) | `autosend_escalate` returns non-zero | Decision_log row still written; orange action falls back to **block-with-pending** state; agent halts at the action | IFOS oncall investigates Telegram primitive; once restored, pending approval gates resume |
docs/decisions/autosend-safety-policy.md:380:--   phase = 'action'         when allowed (green/yellow/orange-approved)
docs/decisions/autosend-safety-policy.md:381:--   phase = 'gating_failed'  when blocked (red/fail-safe-red/orange-rejected/orange-timeout-rejected)
docs/decisions/autosend-safety-policy.md:384:--     "tier": "green|yellow|orange|red|fail-safe-red",
docs/decisions/autosend-safety-policy.md:390:--     "approval_id": "<cortextOS approval gate id if orange>",
docs/decisions/autosend-safety-policy.md:402:1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
docs/decisions/autosend-safety-policy.md:404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:432:    "tier_overrides": {
docs/decisions/autosend-safety-policy.md:434:      "linkedin_connection_request": "orange",
docs/decisions/autosend-safety-policy.md:435:      "bullhorn_candidate_dedupe": "orange"
docs/decisions/autosend-safety-policy.md:445:    "approval_timeouts": {
docs/decisions/autosend-safety-policy.md:446:      "default": "PT4H",
docs/decisions/autosend-safety-policy.md:461:1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:465:5. **`approval_timeouts`** allow per-action_type customisation within range [PT30M, PT72H]. Defaults to PT4H if unspecified.
docs/decisions/autosend-safety-policy.md:466:6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
docs/decisions/autosend-safety-policy.md:476:### v1.0 ships with green + red only
docs/decisions/autosend-safety-policy.md:481:- **Yellow** (sampled review) requires building the spot-check queue infrastructure (spot_check_queue table, Brain UI review interface, sampling-disagreement-feedback loop). Defers without operational risk: high-volume agent work can run as green at v1.0 without sampled review, with tier elevation to orange-in-v1.1 as a fallback if quality issues surface.
docs/decisions/autosend-safety-policy.md:483:- v1.0 handles "needs approval" cases via **ad-hoc Telegram approval** outside the policy pipeline: agent emits a manual approval request via existing primitive 5, founder/operator resolves manually, agent proceeds. These cases are tracked as "would-be-orange" candidates for v1.1 prioritisation.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:488:- **Yellow tier:** spot-check sampling. Implementation tasks: `spot_check_queue` table, `autosend_should_sample` function, Brain UI spot-check review interface, sampling-disagreement feedback loop into policy review.
docs/decisions/autosend-safety-policy.md:489:- Existing green and red actions remain unchanged. v1.0 → v1.1 transition is purely additive.
docs/decisions/autosend-safety-policy.md:493:- **Adaptive tiering:** ML-driven tier adjustment based on incident history. E.g., if `linkedin_connection_request` shows 0 false-blocks over 90 days, automatically propose downgrade from orange to yellow.
docs/decisions/autosend-safety-policy.md:494:- **Per-recipient reputation:** recipients with high engagement may be in implicit "always-orange" zone; recipients with prior unsubscribes may be elevated to red.
docs/decisions/autosend-safety-policy.md:495:- **Pre-action policy simulation:** Brain UI feature — operator types proposed action; system shows tier, override impact, approval routing, expected resolution time. Reduces accidental tier-aware design.
docs/decisions/autosend-safety-policy.md:511:classifies each agent action into one of four tiers: green, yellow,
docs/decisions/autosend-safety-policy.md:512:orange, or red. The classification in effect at the moment of send, as
docs/decisions/autosend-safety-policy.md:521:  (a) any action classified as green by the policy at time of send;
docs/decisions/autosend-safety-policy.md:524:  (c) any action classified as orange that was approved by Tenant's
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:527:      that elevates or otherwise alters the policy default tier
docs/decisions/autosend-safety-policy.md:536:      tier;
docs/decisions/autosend-safety-policy.md:555:payload.policy_version_sha field. Material changes to tier classification
docs/decisions/autosend-safety-policy.md:599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
docs/decisions/autosend-safety-policy.md:601:| 6 | v1.0 "would-be-orange" cases without orange tier implementation — how does the agent halt for ad-hoc Telegram approval without breaking the green/red binary? | §9 | Recommend a `hh_decision_action_ad_hoc_approval` helper that lives alongside `hh_decision_action`; agent explicitly calls it for known orange cases at v1.0; v1.1 deprecates as orange tier ships. |
docs/decisions/autosend-safety-policy.md:603:| 8 | Spot-check disagreement feedback loop — what's the mechanism for spot-check reviewer disagreement to elevate an action_type's tier? | §2 + §11 | Recommend a `spot_check_disagreement` table; >3 disagreements over 30 days triggers a tier-elevation proposal that goes through Codex ratification. v1.1 builds this. |
docs/decisions/autosend-safety-policy.md:604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
docs/decisions/autosend-safety-policy.md:621:- **Q5 (sampling rate defaults for yellow tier):** ACCEPTED for v1.0 with explicit operational-guess flag. Real sampling rates need pilot data; current defaults (1-in-5 to 1-in-20 per `action_type` in §3) are operational guesses calibrated by analogy to typical CRM audit-sampling practice. Refinement happens once first pilot generates 4+ tenant-weeks of yellow-tier action volume.
docs/decisions/autosend-safety-policy.md:622:- **Q6 (v1.0 ad-hoc orange handling without orange tier shipped):** ACCEPTED. `hh_decision_action_ad_hoc_approval` helper sits alongside `hh_decision_action` in `_shared/hook-helpers.sh` (Week-1 prereq 3). Agent explicitly calls `_ad_hoc_approval` for known orange cases at v1.0; v1.1 deprecates the helper as full orange tier ships through `hh_decision_action`'s case-orange branch.
docs/decisions/autosend-safety-policy.md:634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:642:1. Tier classifications per §3 (especially canonical orange = Concierge Bullhorn Note)
docs/decisions/autosend-safety-policy.md:657:- v1.0 ship date: tier coverage is green + red. Yellow + orange phase in v1.1.
docs/operations/codex-round-2-handoff.md:64:## §3 — Round-2 queue (3 tiers)
docs/operations/codex-round-2-handoff.md:77:| 6 | `docs/decisions/autosend-safety-policy.md` | tier contradiction + legal placeholder | LIKELY REJECT — these are founder-decision-bound (D1/D2/D3) and content unchanged |
docs/operations/codex-round-2-handoff.md:87:**Likely outcomes:** 11-12 of 14 RATIFY. Items #6 (autosend tier contradiction) and #14 (PII retention) are founder-decision-bound (D1/D3); Codex may RATIFY-with-advisory or REJECT pending decisions.
docs/operations/codex-round-2-handoff.md:161:across 3 tiers.
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:84:### Post-founding tiers (customers 11+)
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:93:v2 preserves the pricing model. Migration of founding customers to v2 happens at their existing £400/mo rate; new customers signed up to v2 use the post-founding tiers.
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:227:                  → £400/mo (founding) or tier price
docs/operations/codex-round-2-remediation-prompt.md:257:           diagnostic_email_send               → external-comms
docs/operations/codex-round-2-remediation-prompt.md:297:  FLAG 1 — autosend-safety-policy.md tier contradiction
docs/operations/codex-round-2-remediation-prompt.md:302:  > tier semantics in this document define orange as approval-gated. §9
docs/operations/codex-round-2-remediation-prompt.md:303:  > says v1.0 ships green + red only. These are contradictory until D1
docs/operations/codex-round-2-remediation-prompt.md:308:  > In Force for green + red only".
docs/operations/codex-round-2-remediation-prompt.md:549:  - Resolve D1 autosend orange-tier v1.0 path
docs/build-brief/00-MASTER-BRIEF.md:404:- **The graph view as the closing-demo asset.** Open `/brain/graph` filtered to "everyone we've placed in fintech in the last 12 months". Filter by entity type, time window, importance score. Hover reveals entity cards. Click selects + filters to ego-graph. This is what justifies the Scale tier visually.
docs/build-brief/00-MASTER-BRIEF.md:477:- [ ] `docs/decisions/autosend-safety-policy.md` — categorical list of what may auto-send vs draft-only per tier, standing-authorisation contract per agent, escalation cascade, pilot-agreement liability language
docs/build-brief/00-MASTER-BRIEF.md:576:`validate.sh` hard-fails on missing calls. This is what enables the v2.0 LoRA pipeline — no decision log, no SFT corpus, no Scale-tier moat.
docs/build-brief/00-MASTER-BRIEF.md:598:| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
docs/build-brief/00-MASTER-BRIEF.md:983:3. **The decision log + per-firm LoRA pipeline** — Scale-tier defensibility
docs/build-brief/00-MASTER-BRIEF.md:985:5. **The wiki + graph brain** — the visible "second brain" that closes Scale-tier deals
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:220:- Inside: `_voice/`, `_playbooks/`, `_decisions/`, `candidates/`, `clients/`, `opportunities/`, `temp/` (if Temp tier active), `_config.yaml`.
docs/specs/ULTRAPLAN.md:255:### 5.4 The Sovereign tier (v2.0)
docs/specs/ULTRAPLAN.md:257:Per the sovereign compute plan. Sovereign-tier tenants run on a dedicated slice of the Mac Studio cluster, with inference routed exclusively to local hardware. Their vault may be mirrored to local NVMe on the cluster nodes rather than the shared Hetzner volume. This is a deployment configuration, not a code path — same agent bundles, different physical placement.
docs/specs/ULTRAPLAN.md:268:1. Update `tenants.tier` column.
docs/specs/ULTRAPLAN.md:269:2. Run `pm2-ecosystem-generate.sh {slug}` again — adds the new tier's agents to the process group.
docs/specs/ULTRAPLAN.md:319:- The growing corpus is the SFT seed for the Scale-tier LoRA adapter at v2.0.
docs/specs/ULTRAPLAN.md:356:**Layer 4 — The Scale-tier LoRA upgrade (v2.0).**
docs/specs/ULTRAPLAN.md:361:2. Train a LoRA adapter (rank 8–16) on a base model — Qwen3 70B for the cluster, or Claude/Anthropic API with similar fine-tuning if cloud-tier.
docs/specs/ULTRAPLAN.md:365:The LoRA improves voice score from ~80% (RAG + scaffolding) to ~90%+. This is what justifies the Scale tier at £6,950/mo.
docs/specs/ULTRAPLAN.md:471:Agent name + tier
docs/specs/ULTRAPLAN.md:719:Targets: 3 paid pilots by end of Q3 2026 (per the internal business plan). v1.0 = the six v1.0 agents shippable in the Starter and Boutique tiers; Growth/Scale defer to v1.1.
docs/specs/ULTRAPLAN.md:798:3. Sovereign-tier setup (deferred to v2.0 regardless)
docs/specs/ULTRAPLAN.md:800:5. Cash Conductor's escalation-tier-3 (bad debt write-off draft) — manual until 6 months in
docs/decisions/bullhorn-integration-path.md:19:**Sub-decision A — Bullhorn integration path.** Marketplace partner programme membership (with its access tier, scope, certification, ongoing fees) versus direct API access (per-tenant Bullhorn-account-admin authorisation of IFOS as a connected app). Master brief §6 Day 2 line 466 explicitly names this as the day's decision. The path chosen determines whether `packages/mcp-connectors/bullhorn/` ships as a marketplace-registered connector or a direct-API connector — the *code* in either case is similar OAuth + REST plumbing, but the *operational, commercial, and rate-limit* surfaces differ materially.
docs/decisions/bullhorn-integration-path.md:59:- Whether Intel Force Ltd is currently a member of the **Bullhorn Marketplace Partner Programme** (or what the application timeline + cost would be). The marketplace partner application process is publicly known to involve a technical review, security audit, and ongoing partner fees — but the specifics for IFOS's tier and tenant volume are commercial-confidential and need a direct conversation.
docs/decisions/bullhorn-integration-path.md:60:- Whether **marketplace-tier API access differs from direct-API access** in rate limits, available scopes (e.g. write to JobOrder, write to Note, webhook subscription), or sandbox availability. Bullhorn's public docs are sparse on the deltas; partner reps know the actuals.
docs/decisions/bullhorn-integration-path.md:61:- Whether the marketplace-tier cost structure works at IFOS's volume (3-6 tenants v1.0; 100 by end of 2027 per Product Spec §5.4 line 369-373). Partner fees may be flat or per-tenant; this matters at scale.
docs/decisions/bullhorn-integration-path.md:69:| A | "What are the API rate-limit / scope deltas between marketplace tier and direct API at our expected 3-6 tenant pilot volume?" | Same Bullhorn partnerships team, or escalation to developer support | Same conversation | The answer determines whether direct-API can serve v1.0 or marketplace registration is a v1.0 blocker |
docs/decisions/bullhorn-integration-path.md:116:- `https://www.bullhorn.com/become-a-partner/` — landing page. Main CTA: **"Fill out the form to learn more about our partner programs."** References three external resources (FAQs, Bullhorn Developer Program, Fair Use Policy) but the page itself contains **no specific information** on application process, tiers, certification, security review, fees, ongoing costs, or timeline. The only substantive description on the page is: **"The Bullhorn Marketplace gives our customers the choice, confidence, and customization they need to innovate with agility."**
docs/decisions/bullhorn-integration-path.md:123:- There is a separately-named **Bullhorn Developer Program** distinct from the Marketplace partner programme (linked from `/become-a-partner/`) — implying a possible two-tier structure: developer-tier access to APIs (lighter) vs marketplace-listed partner (heavier).
docs/decisions/bullhorn-integration-path.md:128:- Whether the programme has tiers (e.g. Standard / Premier / Strategic) and what gates each tier.
docs/decisions/bullhorn-integration-path.md:129:- Whether marketplace-tier partners get different API scope, rate-limit ceilings, or webhook access vs direct-API/developer-tier.
docs/decisions/bullhorn-integration-path.md:150:- **client_id / client_secret acquisition.** Bullhorn doc verbatim: **"Bullhorn customers can obtain OAuth keys for developing applications...by creating a support ticket via the Bullhorn Resource Center."** This is not a self-service developer signup — there is a Bullhorn-side gate even for the developer-tier path. Implication: every IFOS pilot tenant must open a support ticket with Bullhorn to authorise IFOS as a connected app, or IFOS must hold a single set of client credentials at the IFOS-application level and route per-tenant auth through it. The structural distinction here is exactly what Sub-decision A pivots on — partnerships@bullhorn confirms whether marketplace status grants application-level credentials.
docs/decisions/bullhorn-integration-path.md:166:| Time-to-first-call (greenlight → working API call against a tenant) | **CG.** Inference: marketplace certification + security review typically 4-12 weeks for enterprise SaaS programmes of this maturity. Bullhorn-specific timeline not stated publicly. | **CG.** Confirmed from public docs: customer raises Bullhorn support ticket per /Getting-Started-with-REST to obtain client_id/client_secret. ETA per ticket cycle — likely 1-5 business days per pilot tenant. |
docs/decisions/bullhorn-integration-path.md:167:| Per-tenant onboarding friction (admin auth, scope review) | **CG.** If marketplace tier grants IFOS application-level credentials, per-tenant friction may reduce to "tenant clicks Authorise from marketplace listing." | Each pilot tenant raises a Bullhorn support ticket + tenant admin authorises IFOS as a connected app via per-tenant OAuth screen. Per-tenant friction: 1 support ticket + 1 OAuth dance per pilot tenant. |
docs/decisions/bullhorn-integration-path.md:169:| Cost at 3-tenant pilot scale (2026 H2, Boutique tier per Product Spec §3.1) | **CG.** Public docs do not name partner fees. Inference based on comparable enterprise SaaS marketplace programmes: annual partner fee typically $5K-$25K + possibly per-listing or per-referral revenue-share. | **CG.** Public docs do not name developer-program fees. Inference: likely zero or nominal for the developer-tier API access. Per-tenant cost zero — the tenant pays Bullhorn, IFOS pays nothing per call. |
docs/decisions/bullhorn-integration-path.md:170:| Cost at 100-tenant target scale (Product Spec §5.4 end-2027 target) | **CG.** May or may not scale linearly with tenant count. Some marketplace programmes have flat annual fees; others meter on tenant or revenue volume. | **CG.** If developer-tier cost is zero or nominal, scales fine. Risk: per-tenant Bullhorn support tickets at 100 tenants become operational drag at IFOS-Customer-Success layer (Product Spec §5.4 line 373 names ≤8 hours of human time per customer onboarding — Bullhorn ticket may consume a meaningful fraction). |
docs/decisions/bullhorn-integration-path.md:171:| Scope / rate-limit deltas | **CG.** Marketplace tier may grant elevated rate limits, write access to additional entities (e.g. JobOrder write), webhook subscription endpoints not available to direct-tier. Public docs do not state. | Public REST API documentation lists all REST endpoints uniformly — no tier-gated endpoints stated in public docs. Inference: all entity reads/writes are available to authenticated direct-tier callers, subject to per-corpToken scope at the tenant-account-admin level. Rate limit ceiling **CG**. |
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:191:| Marketplace tier is **required** for production tenant onboarding (partnerships@bullhorn answer) | Connector scaffolds against direct-API on a Bullhorn-sandbox tenant for IFOS internal dev; marketplace registration becomes Week-1 critical-path commercial work; v1.0 build slips by the marketplace certification timeline (potentially 4-12 weeks per §2.3 row 1 inference). This is a v1.0 blocker scenario and feeds master brief §12 Risk #2 directly. |
docs/decisions/bullhorn-integration-path.md:242:- **Bullhorn sandbox tier** (if it exists — §2.2 noted sandbox availability is not publicly documented and is commercially gated). If Bullhorn offers a sandbox, the auth model against it is presumed identical to production: authorization-code grant. Just a different `loginInfo` cluster.
docs/decisions/bullhorn-integration-path.md:244:**Spec gap §3.2-A:** confirm with Bullhorn developer support whether (a) client_credentials is genuinely unsupported, or (b) it exists for specific partner-tier use cases not documented publicly. If (b), this changes the dev-loop ergonomics. Mark as **CG**.
docs/decisions/bullhorn-integration-path.md:261:2. **It composes with the §1.4 fallback architecture and §2.4 Sub-decision A recommendation.** The auth-code flow works identically against direct-API and marketplace-tier (only the `loginInfo` cluster and client_id may differ). The auth module's job is the per-tenant browser-dance kickoff and refresh-token persistence; both are path-independent.
docs/decisions/bullhorn-integration-path.md:266:- Confirm authorization-code grant is the correct production path (i.e. Bullhorn doesn't have a marketplace-tier-only managed-auth path that bypasses the browser dance).
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:300:**Implication:** Bullhorn's public-tier REST API is **pull-only**. IFOS must poll for change detection at v1.0 unless commercial verification reveals a partner-tier event-subscription mechanism. **Commercially gated: §4.2-A** — confirm with Bullhorn developer support whether webhook/event-subscription capabilities exist at marketplace/partner tier that are not documented in the public REST docs.
docs/decisions/bullhorn-integration-path.md:310:| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
docs/decisions/bullhorn-integration-path.md:313:**v1.1+ upgrade path:** if Sub-decision A commercial verification reveals marketplace-tier event subscriptions, Concierge upgrades from 5-minute polling to webhook-primary with polling fallback. The polling cycle becomes a heartbeat-style consistency check. No agent-bundle-content changes; only `tools.yaml` MCP scope declaration and the connector's auth/subscription module.
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:470:- **Webhook / event-subscription model** — deferred to v1.1+ pending Sub-decision A commercial verification (whether marketplace tier grants subscription endpoints not in public REST docs).
docs/decisions/bullhorn-integration-path.md:510:| §3.2-A: assume `client_credentials` genuinely unsupported (not partner-tier-only) | Bullhorn dev support reveals partner-tier-only support — dev-loop ergonomics improve; production path unchanged |
docs/decisions/bullhorn-integration-path.md:511:| §4.2-A: assume v1.0 pull-only (no webhook coverage) per public REST docs | Sub-decision A commercial verification reveals marketplace-tier event subscriptions — Concierge upgrades to webhook-primary in v1.1+ |
docs/operations/codex-round-2-autonomous-prompt.md:38:  - The 26 artefacts in 3 tiers (§3)
docs/operations/codex-round-2-autonomous-prompt.md:73:STEP 3 — Ratify 26 artefacts in 3 tiers (~6h)
docs/operations/codex-round-2-autonomous-prompt.md:118:  ## §2 — Per-tier per-artefact table
docs/operations/codex-round-2-autonomous-prompt.md:253:4. **DO NOT make founder decisions.** Items like D1 (autosend orange tier), 
docs/operations/goal-week-3-polish-and-scaffold.md:24:9. **`docs/decisions/autosend-safety-policy.md`** §2-§4 (4-tier model + 29 action types) + §10 (pilot-agreement liability)
docs/operations/goal-week-3-polish-and-scaffold.md:29:14. **`agents/_shared/autosend-policy.yaml`** (29 action types; tier classifications)
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:151:# Verify Day-13 test counts still green
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
docs/operations/goal-week-3-polish-and-scaffold.md:367:- **§1 Output contract:** reconciles invoices against bank deposits; chases overdue payments via approved orange-tier email drafts (consultant approves before send); writes payment status updates to accounting system; generates weekly cash-flow report to `/vault/<tenant>/cash-conductor-reports/`. No Bullhorn dependency — operates entirely against Xero / QuickBooks / Sage + Open Banking.
docs/operations/goal-week-3-polish-and-scaffold.md:368:- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
docs/operations/goal-week-3-polish-and-scaffold.md:402:- **§8 Build prerequisites:** Bullhorn MCP read + LinkedIn integration (Proxycurl signup OR LinkedIn API partner-tier) + ranking model (LLM-based or embedding-based).
docs/operations/goal-week-3-polish-and-scaffold.md:409:#### Step 12 — `agents/recruitment/concierge/agent.md` (~3-4 hours; most complex due to autosend orange-tier)
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:414:- `autosend-safety-policy.md` §4 (orange-tier model) + §3 (29 action types — Concierge's are bullhorn_note_customer_visible, candidate_state_change_email, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:415:- `2026-05-20-codex-round-1-founder-decisions.md` §D1 (autosend orange-tier decision)
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **§1 Output contract:** monitors Bullhorn placement-state transitions (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → day-7-check-in → day-30-check-in → day-90-check-in); generates customer-facing communication drafts at each lifecycle event; orange-tier autosend per Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:423:- **§3 Output shape:** message drafts (email / Bullhorn note customer-visible / SMS as configured); decision-log audit row per send; orange-tier spot-check sampling at 1-in-N rate per autosend-safety-policy §4.
docs/operations/goal-week-3-polish-and-scaffold.md:424:- **§4 Workflow:** ~15 steps. Bullhorn poll every 5 min → detect state transition → fetch context (candidate + client + placement entities) → identify message template → LLM draft → voice classifier ≥0.75 → tone-rule check → tier classification → autosend bridge call (per D1 decision) → audit row.
docs/operations/goal-week-3-polish-and-scaffold.md:425:- **§5 Gate A:** validate.sh hard-fails on missing approval-bridge auth (if D1-A bridge), voice classifier <0.75, tone-rule block-severity hit, schema violation, orange-tier-spot-check sample selected.
docs/operations/goal-week-3-polish-and-scaffold.md:429:- **§8 Build prerequisites:** D1 autosend orange-tier decision RESOLVED + Bullhorn MCP R+W + voice classifier microservice live + approval bridge built (per D1 outcome) + tenant tone_rule table seeded.
docs/operations/goal-week-3-polish-and-scaffold.md:505:| Disk full / VPS unreachable mid-execution | Pause; founder investigates; resume from last green commit |
docs/operations/goal-week-3-polish-and-scaffold.md:612:  Gate A:             PASS (V1-V6 green; V3 warning per scaffold)
docs/specs/_archive-build-handoff.md:188:See `docs/PRODUCT-SPEC.md` — the agent suite, output contracts, tier mapping.
docs/specs/_archive-build-handoff.md:273:- The full categorical list of what may auto-send vs what is draft-only per tier
docs/specs/_archive-build-handoff.md:293:- Timesheet (Temp tier only)
docs/specs/_archive-build-handoff.md:373:Per Ultraplan §9, v1.0 ships six agents in the Starter and Boutique tiers. In order:
docs/specs/_archive-build-handoff.md:380:| 4 | **Cash Conductor** | 7–8 | Xero + Open Banking | FD-tier closer; the "DSO drops by 15 days" pitch |
docs/operations/seedlegals-engagement-queries.md:78:> 6. **Dispute forum:** English courts; tier 1 = direct negotiation between founders; tier 2 = LCIA mediation if unresolved 30 days.
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:35:| 14 | **Scripts authored Days 8+ never executed end-to-end against live until 2026-05-23** — Day-9 cohesion review claimed "foundation is sound for Diagnostic build" based on code+docs review, but no helper / migration / script had been exercised against live Postgres. Day-12 first execution surfaced 6 distinct drifts (password, DB name, TRIGGER grant, GUC rename, missing tenants row, table ownership/RLS-bypass). | High (now historical; mitigated) | High at time of discovery — any of the 6 could have manifested at first pilot LOI as silent failure or data leak. | Future script/migration authoring without an explicit "first live execution against migration-test tenant" milestone listed in the plan. | Day-12 closed loop: live migration 24/24 + tenancy audit 24/24. Future: every new script touching live Postgres must include a verified-on-VPS milestone in its acceptance criteria, not just unit-test-layer green. Day-9 cohesion review template updated to require live verification before "foundation verified" verdict. | **Mitigated.** Discovery surfaces a class lesson: ratification at code-and-docs layer is necessary but not sufficient; live execution is the third leg. |
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/specs/PRODUCT-SPEC.md:17:Intel Force OS is the always-on operating system for UK recruitment agencies. It runs on CortexOS as the persistent agent runtime, lives inside each firm's existing stack (Bullhorn / Vincere / Voyager Infinity, Xero / Sage, Microsoft 365 / Google Workspace), and ships as two coordinated product lines — **IntelForce Recruit** for the front office and **IntelForce Temp** for the back office. Together they replace the operational drag of an entire junior team and, more importantly, generate revenue: surfaced BD opportunities, intercepted competitor briefs, faster cash collection, dormant-candidate reactivation, and post-placement nurture that compounds into referrals. The firm pays £499–£6,950/month per front-office tier and a separate £1,950–£5,950/month for the temp sub-platform. Every agent is pitched against a single, quantified outcome the buyer can verify within 90 days. Configuration scales because the moat is the per-vertical schema, not per-customer plumbing — onboarding becomes a 5-day wizard, not a 5-week project.
docs/specs/PRODUCT-SPEC.md:35:We lead with revenue because that's what gets the contract signed at a £3,250/mo Growth tier. Time savings close the deal at Solo (£499/mo). Both numbers are quantified in the agent spec; both are measured in the customer's first 90 days.
docs/specs/PRODUCT-SPEC.md:61:- **Tier availability** — which subscription tier unlocks it
docs/specs/PRODUCT-SPEC.md:116:- **Tier availability:** All tiers including Solo. This is the data spine.
docs/specs/PRODUCT-SPEC.md:135:- **Per-tenant config:** client portfolio scope, signal-weighting overrides, account-team routing rules, escalation thresholds per client tier (key account vs occasional).
docs/specs/PRODUCT-SPEC.md:140:- **Revenue story:** "Your sourcing runs become 3× more productive against clean data. One reactivated dormant-but-clean candidate per month covers the tier price." Plus: removes the compliance liability of stale records.
docs/specs/PRODUCT-SPEC.md:234:## 3. The revenue case — pinned per tier
docs/specs/PRODUCT-SPEC.md:245:| **Scale** (26–50 fee earners) | £6,950 | All Growth + per-firm LoRA adapter + Sovereign-tier inference (UK on-prem) + priority support | "Half a junior recruiter replaced per consultant in operational drag. Per-firm voice that's genuinely indistinguishable from your top performer. £820k–£1.4M of demonstrable annual value created." |
docs/specs/PRODUCT-SPEC.md:293:       │     per-firm LoRA adapter → Scale-tier moat              │
docs/specs/PRODUCT-SPEC.md:357:- `common-client.json` — firm slug, legal name, primary contact, tier, sovereign-vs-cloud preference
docs/specs/PRODUCT-SPEC.md:374:- **Per-customer compute cost: ~£200/month for full Tier 1 deployment** (per the CortexOS directive's unit-economics work). At Boutique £1,495/mo this is 13% COGS; at Growth £3,250/mo this is 6%; healthy at every tier above Solo's three-agent gate.
docs/specs/PRODUCT-SPEC.md:382:3. **"Genuinely new feature — let me see how many other customers want this."** This goes on the roadmap. We never build it for one customer unless they pay materially extra for it (typically Scale-tier customers only). ~15% of the time.
docs/specs/PRODUCT-SPEC.md:421:- **Sovereign tier:** inference routed to the on-prem Mac Studio cluster (per the sovereign compute plan); cloud APIs (Anthropic, Moonshot) handle non-Sovereign tiers and overflow.
docs/specs/PRODUCT-SPEC.md:422:- **Per-firm LoRA adapter (Scale tier only):** trained on cloud GPUs, served from the cluster at inference time.
docs/specs/PRODUCT-SPEC.md:430:**1. Every agent now has a quantified revenue story, not just a time-saved story.** The internal business plan and the 24/7 directive had revenue stories for some agents (Cash Conductor, Client Hunter, T5) but not all. Triage was pitched on responsiveness; here it's pitched on "2–4 additional placements/year per consultant from never-lost candidates". Janitor was pitched on database hygiene; here it's pitched on "one reactivated dormant-but-clean candidate per month covers the tier price".
docs/specs/PRODUCT-SPEC.md:434:**3. The single ROI promise per tier is pinned.** Previous docs had pricing and had value modelling but the "single sentence the salesperson uses" was scattered. Section 3 fixes this.
docs/specs/PRODUCT-SPEC.md:457:- **No three-year contracts in v1.** Six and twelve-month terms with auto-renewal. Three-year is a Stage 5 lever once Sovereign tier exists and the data-sovereignty story is the close.
docs/specs/PRODUCT-SPEC.md:478:Six agents. The Solo tier is fully shippable. The Boutique tier is fully shippable. Growth and Scale come in v1.1.
docs/specs/PRODUCT-SPEC.md:495:The Growth tier becomes fully shippable. Compliance Core SKU launches.
docs/specs/PRODUCT-SPEC.md:505:Scale tier becomes fully shippable. Full Temp Sub-Platform launches.
docs/specs/PRODUCT-SPEC.md:511:- The per-firm LoRA adapter pipeline (Scale tier unlock)
docs/specs/PRODUCT-SPEC.md:512:- The Sovereign-tier on-prem cluster (Scale tier unlock)
docs/operations/goal-option-c-diagnostic-end-to-end.md:41:   - `pnpm test` returns green (≥10 vitest unit tests per package; integration test against live Companies House API marked `.skipIf(!process.env.COMPANIES_HOUSE_API_KEY)`)
docs/operations/goal-option-c-diagnostic-end-to-end.md:189:Acceptance: integration tests green; one log line per endpoint showing response time + cache state.
docs/operations/goal-option-c-diagnostic-end-to-end.md:330:- Any external service requiring paid signup (Proxycurl, OpenAI tier, etc.)
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md:102:When a bugfix batch is successfully applied and the build + tests are green:
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md:104:cortextos bus send-message [ORCHESTRATOR] normal 'Framework upstream auto-update YYYY-MM-DD: applied N commits. Build + test green. Details: ...'
docs/operations/founder-legal-setup-guide.md:86:- **Ashfords LLP** (ashfords.co.uk) — tech sector group; mid-tier firm with startup-friendly hourly rates. Verified 2026-05-23.
docs/operations/founder-legal-setup-guide.md:220:> - All bounded by tier-based safety policies; high-risk actions require human approval; lowest-risk actions can be unsupervised
docs/operations/founder-legal-setup-guide.md:245:On that page, click through to the self-assessment tool. You'll answer a few questions, pick the right tier (small SaaS = tier 1 typically; £52/year as of 2026), and pay online. Save the confirmation as `docs/operations/ico-registration-2026-05-XX.md`.
docs/_supplementary/technical-strategy-v2.md:63:- **Opus 4.7** — SOP Writer (complex extraction from Loom), reserved tier — only when the output visibly needs it
docs/_supplementary/technical-strategy-v2.md:130:Keep both in the back pocket for a future "IntelForce Cloud" tier where you can charge a premium for fully-managed scheduled execution with no client infrastructure.
docs/_supplementary/technical-strategy-v2.md:431:Pricing: £5k setup + £1.5k/mo (they lean content-heavy so the Marketing trio plus Reporting Engine plus Client Onboarder is the core value). Some will go Growth tier for the full 9.
docs/_supplementary/technical-strategy-v2.md:439:Build this as a formal tier: **Agency Partner**.
docs/_supplementary/technical-strategy-v2.md:460:### 5.4 Revised ICP tiers
docs/_supplementary/technical-strategy-v2.md:576:- **Enterprise tier:** the Rigby Group / government-adjacent pitch is where OpenClaw as *infrastructure* makes sense. SCC won't deploy on Claude Code; they'll deploy on a governance-wrapped orchestration layer that happens to route to Claude models. That's the OpenClaw story.
docs/_supplementary/PRD-autonomous-agent.md:2007:- [ ] Install dev tools: `npm i -D vitest @vitest/coverage-v8 eslint prettier`
docs/_supplementary/PRD-autonomous-agent.md:2517:4. Refactor, keep tests green
docs/_supplementary/execution-plan.md:84:- [ ] **C1e.** Pricing lock: confirm the four tiers in Strategic Plan §8.3 are the ones you go to market with, or adjust now.
docs/_supplementary/execution-plan.md:136:  - *Purpose:* JSON schema for what the wizard collects to configure this agent per tenant (pricing framework, sales lead email, sign-off block, tier thresholds, disqualifiers).
docs/_supplementary/execution-plan.md:303:  - *Prompt:* "Write the Cost & Billing System Engineering Specification per Build Plan §27: the Anthropic API metadata tagging pattern for per-tenant attribution, the third-party API cost tracking table schema, the infra cost allocation formula, Stripe subscription setup (price IDs per tier, metered overages, setup fees as one-off invoices), the dashboard view that shows clients their current usage against allowance, the operator view that shows gross margin per tenant + anomaly detection."
docs/_supplementary/execution-plan.md:421:- [ ] **5.4 — Terms of Service (self-serve tier)**
docs/_supplementary/execution-plan.md:437:  - *Prompt:* "Write the IntelForce AI OS Pricing Page Copy: four tiers (Starter, Growth, Scale, Enterprise) with the exact price, the 'what's included' bullet list, the addons table, the FAQ section (10 questions), the comparison table, the 'not sure which tier?' CTA → audit call. Tone: confident, specific, never needs to shout. UK English."
docs/_supplementary/execution-plan.md:503:  - *Prompt:* "Write the Monitoring & Alert Playbook: every alert the observability stack fires, with for each: the condition that triggers it, the likely root causes, the diagnostic commands, the resolution steps, the escalation rules. Organise by severity tier."
docs/_supplementary/strategic-plan.md:69:| Pricing | $5–15k + retainer | £3–20k + retainer (tiered, transparent) |
docs/_supplementary/strategic-plan.md:166:│   - Heavy reasoning: Claude Opus 4.7 (reserved tier)       │
docs/_supplementary/strategic-plan.md:351:- [ ] **Dev**: Stripe subscriptions wired to dashboard tiers
packages/harness/cortextos/README.md:1:![npm version](https://img.shields.io/npm/v/cortextos) ![License](https://img.shields.io/badge/license-MIT-green) ![Node](https://img.shields.io/badge/node-20%2B-brightgreen) ![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)
docs/_supplementary/build-plan-original.md:198:### 3.1 Three context tiers
docs/_supplementary/build-plan-original.md:291:- **Cognism MCP** — only for Agency Partner and Enterprise tiers (£20k+/year; bakes into their pricing, not yours)
docs/_supplementary/build-plan-original.md:406:3. Propose scope. Three tiers allowed MAX (Good/Better/Best). Don't invent new 
docs/_supplementary/build-plan-original.md:426:4. **Scope** (bullet list per tier if tiered, else flat). Specific deliverables.
docs/_supplementary/build-plan-original.md:428:6. **Investment** (clear price per tier, payment structure).
docs/_supplementary/build-plan-original.md:446:- Deal value in discussion >£50k (partner-tier decisions always human)
docs/_supplementary/build-plan-original.md:474:- Call transcript has no price discussion → produce proposal at the client's "standard" package tier, flag clearly
docs/_supplementary/build-plan-original.md:694:- Pillar piece is evergreen → derivatives should match lifespan, not reference "this week's"
docs/_supplementary/build-plan-original.md:977:- **Ahrefs / SEMrush API** (paid, passed through to client — OR build against free DataForSEO tier for Tier 1)
docs/_supplementary/build-plan-original.md:1034:7. **Stale content check** — notes tagged as "evergreen" that haven't been edited/viewed in 6+ months → flag for refresh.
docs/_supplementary/build-plan-original.md:1499:The Agency Partner tier is structured so you earn per sub-tenant:
docs/_supplementary/build-plan-original.md:1562:- OpenClaw migration path for Enterprise tier
packages/harness/cortextos/scripts/self-healing/README.md:13:| `usage-monitor.sh` | Cost. Calls `ccusage blocks --json`, computes USD/hr for the active 5-hour Claude Code session window, sends Telegram alerts on tier transitions (default GREEN <$15, YELLOW $15–$30, RED >$30). | every 30 min |
packages/harness/cortextos/scripts/self-healing/README.md:73:- `YELLOW_THRESHOLD` (default `15`) and `RED_THRESHOLD` (default `30`) — USD/hr tier boundaries

exec
/bin/zsh -lc 'rg -n "hh_load_voice_samples|classifier|score|voice" agents/_shared/voice-loader.sh docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml packages/agents-runtime/_shared/common-voice.json' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:438:      Phase 5 — execute migration SQL against migration-test tenant; verify pgvector HNSW index builds clean; voice-loader.sh queries return expected shape; commit.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:440:  v1_0_voice:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:441:    expected_date: post-Concierge build (W10-13) — first agent to heavily exercise voice corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:445:  v1_1_voice:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:446:    expected_date: post-first-pilot voice corpus mature (Q4 2026 if pilot lands)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:450:  v2_0_voice:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
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

exec
/bin/zsh -lc "rg -n \"_consultant_feedback|consultant_feedback|_renderer|_tenant_admin|_codex_ratifier|sentinel\" docs agents packages -g '"'!node_modules'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
agents/_shared/escalation-codes.md:16:agent_name        — the agent firing the escalation (or '_renderer')
agents/_shared/escalation-codes.md:113:- **Agent name:** `_renderer` (sentinel; not a real agent)
agents/_shared/escalation-codes.md:115:- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7
agents/_shared/escalation-codes.md:257:4. Default `agent_name` to `${CTX_AGENT_NAME}` or `_renderer` (renderer-only sentinel)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/architecture/architecture-cohesion-review.md:68:| ADR-003 | phase enum for renderer | Day-4 §6.3 CHECK constraint | **✓ landed but with deviation per ADR-004 Decision 7** — phase='render' NOT in enum; uses agent_name='_renderer' + existing phase |
docs/architecture/architecture-cohesion-review.md:109:- **Resolution:** ADR-004 Decision 7 (Codex Round 1 RATIFIED) + Day-8-evening remediation `2b287d3` corrected both renderer-design + ADR-003 to use `agent_name='_renderer'` + existing `phase=gating_failed|action`. **RESOLVED.**
docs/decisions/autosend-safety-policy.md:470:Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.
docs/architecture/agent-bundle-renderer-design.md:638:**Escalation:** `ESC_RENDERER_FAILED` row written to `decision_log` Postgres table with `agent_name='_renderer'`, `phase='gating_failed'`, `payload->>'reason'='schema-validation-failure'`. (`phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — see ADR-004 Decision 7; the 5-value enum is `trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 schema migration.) If `--notify-on-failure` (default true), Telegram message to the operator with the validation path.
docs/architecture/agent-bundle-renderer-design.md:708:- **Audit log:** Postgres `decision_log` row with `tenant_slug`, `agent_name='_renderer'`, `phase='gating_failed'` (failures) or `phase='action'` (successful renders), `payload->>'reason'` carries the reason code. RLS-isolated per tenant. Codex's Day-7 ratification report queries this table for all rows where `agent_name='_renderer' AND payload->>'reason' LIKE 'ESC_RENDERER_FAILED%'`. (Per ADR-004 Decision 7: `phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — use the 5-value enum from Day-4 §6.3 + Day-5 schema migration.)
docs/runbooks/tenant-lifecycle.md:207:- Decision_log shows audit row with `agent_name='_tenant_admin'`, `phase='trigger'`, `payload.action='suspend|resume'`
docs/runbooks/tenant-lifecycle.md:274:- Audit row in decision_log: `agent_name='_tenant_admin'`, `phase='gating_failed'`, `payload.action='tenant_purged'`, `payload.tenant_slug=<slug>` (written PRE-DELETE so the audit row survives)
docs/runbooks/tenant-lifecycle.md:363:  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:44:      const stateDir = join(ctxRoot, 'state', 'sentinel');
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:48:        agent: 'sentinel',
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:58:      expect(parsed.agent).toBe('sentinel');
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:69:        sentinel: { enabled: true, status: 'configured', org: 'acme' },
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:77:      expect(parsed.sentinel.enabled).toBe(true);
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:88:          sentinel: {
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:107:      expect(parsed.agents.sentinel.tasks_completed).toBe(5);
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:121:        assigned_to: 'sentinel',
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:138:      expect(parsed.assigned_to).toBe('sentinel');
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:142:      const eventsDir = join(ctxRoot, 'analytics', 'events', 'sentinel');
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:146:        { id: 'evt1', agent: 'sentinel', org: 'acme', timestamp: '2026-03-29T10:00:00Z', category: 'heartbeat', event: 'heartbeat_complete', severity: 'info', metadata: {} },
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:147:        { id: 'evt2', agent: 'sentinel', org: 'acme', timestamp: '2026-03-29T10:01:00Z', category: 'task', event: 'task_completed', severity: 'info', metadata: { task_id: 'task_123' } },
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:155:      expect(evt.agent).toBe('sentinel');
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:166:        requesting_agent: 'sentinel',
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:180:      expect(parsed.requesting_agent).toBe('sentinel');
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:208:        agent: 'sentinel',
docs/architecture/vault-concurrency.md:383:**V1.2+ improvement deferred** — write-ahead-log pattern where filesystem writes go to `wiki/.tmp/cascade-<txn-id>/` first; commit moves them atomically (via batched renames inside a sentinel-marker pattern); rollback removes the `.tmp/cascade-<txn-id>/` directory. Eliminates the partial-failure surface at the cost of meaningful implementation complexity. Out of v1.0 scope.
agents/recruitment/diagnostic/agent.md:167:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='_consultant_feedback'` + `phase='action'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field).
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:158:      const sentinelPaths = makePaths('sentinel');
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:188:      // Paul asks sentinel to verify
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:189:      sendMessage(paulPaths, 'paul', 'sentinel', 'normal', 'Verify API endpoint health');
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:192:      const sentinelMessages = checkInbox(sentinelPaths);
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:193:      expect(sentinelMessages.length).toBe(1);
docs/operations/codex-ratification-guide.md:154:5. **Audit row write** — inserts a row into `decision_log` with `tenant_slug='ifos-meta'`, `agent_name='_codex_ratifier'`, `phase='output'`, `outcome=<RATIFIED|REJECTED>`, `payload` includes the artefact path, skill used, issue count, session ID, and the full Codex response text. Falls back to `logs/codex-ratification.jsonl` if no live DB.
docs/operations/codex-ratification-guide.md:390:WHERE agent_name = '_codex_ratifier'
docs/operations/codex-ratification-guide.md:513:- **16+ audit rows** in `decision_log` under `agent_name='_codex_ratifier'`
docs/operations/codex-ratification-guide.md:554:psql -c "SELECT created_at, payload->>'artefact_path', outcome FROM decision_log WHERE agent_name='_codex_ratifier' ORDER BY created_at DESC LIMIT 20;"
packages/harness/cortextos/tests/sprint7-environment.test.ts:25:        orchestrator: 'sentinel',
packages/harness/cortextos/tests/sprint7-environment.test.ts:38:        orchestrator: 'sentinel',
packages/harness/cortextos/tests/sprint7-environment.test.ts:42:      expect(ctx.orchestrator).toBe('sentinel');
packages/harness/cortextos/tests/sprint7-environment.test.ts:81:        sentinel: {
packages/harness/cortextos/tests/sprint7-environment.test.ts:106:      expect(parsed.sentinel.template).toBe('orchestrator');
docs/operations/codex-round-2-handoff.md:270:  'ifos-meta', '_codex_ratifier', 'output', 'RATIFIED-round-2',
packages/agent-renderer/README.md:124:Hand-edits to the rendered output are **lost on next render** (Decision 4: overwrite-no-merge per ADR-003 §3.4). Edit the bundle, then re-render. Decision-log row written with `agent_name='_renderer'` + `phase='render'` per ADR-003 §4 audit policy (Phase 3 wires this via `hook-helpers.sh`).
packages/harness/cortextos/src/daemon/ipc-server.ts:145:  // Unparseable schedule — return a sentinel so callers can detect it
docs/operations/codex-ratification-execution-plan.md:266:  '_codex_ratifier',                      -- sentinel agent name
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:83:  it('skips a whole file when the m2c1-worker sentinel marker is present', () => {
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:160:  it('scans top files + skills, separates sentinel-skipped files', () => {
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:180:  it('honors per-file sentinel marker — files opted out are skipped', () => {
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:114:- **Per-file sentinel marker.** A file containing the literal string `/loop is intentionally used` is skipped wholesale. This is the m2c1-worker carve-out: m2c1 worker agents legitimately use short-lived `/loop` for in-session task queueing, not for persistent crons.
packages/harness/cortextos/src/cli/add-agent.ts:49:      console.error(`Examples of valid names: paul, sentinel, cortext-designer, m2c1-worker, agent_1`);
packages/harness/cortextos/community/skills/activity-channel/SKILL.md:54:cortextos bus post-activity "analyst (sentinel) is online and running nightly metrics."
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:398:  it('returns "unknown" for unknown sentinel', async () => {
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:77://   sentinel: health(15m)=288, gap-detect(1h)=72, upstream(12h)=6                    → 366
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:117:    name: 'sentinel',
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:169:  // sentinel
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:170:  'sentinel/system-health-check':                { min: 287, max: 289 },
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:171:  'sentinel/cron-gap-detector':                  { min: 71, max: 73  },
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:172:  'sentinel/upstream-sync':                      { min: 5,  max: 7   },
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:371:    expect(results[2].cronsMigrated, 'sentinel: 3 crons').toBe(3); // sentinel
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:388:    const sentinelKnown = new Set(AGENT_FIXTURES[2].crons.map(c => c.name));
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:393:      boris: borisKnown, paul: paulKnown, sentinel: sentinelKnown, donna: donnaKnown, nick: nickKnown,
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:448:      boris: 4, paul: 6, sentinel: 3, donna: 2, nick: 3,
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:558:    const sentinelEvents = eventLog.filter(e => e.agent === 'sentinel');
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:570:    for (const e of sentinelEvents) {
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:614:  it('sendMessage from sentinel to donna also works (verifying bus not stomped by any cron module)', () => {
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:615:    const sentinelPaths = buildBusPaths('sentinel');
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:620:    const msgId = sendMessage(sentinelPaths, 'sentinel', 'donna', 'high', 'system-alert: cron gap detected');
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:799:    // Choose 3 agents (boris, paul sentinel) and give each agent one cron
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:801:    const agentsUnderTest = ['boris-conc', 'paul-conc', 'sentinel-conc'] as const;
packages/harness/cortextos/tests/integration/migration-guide-references-upgrade-cmd.test.ts:14: *   - The whitelist mechanics (sentinel marker + negation tokens) are noted
packages/harness/cortextos/community/skills/agent-management/SKILL.md:186:AGENT="sentinel"
packages/harness/cortextos/community/skills/agent-management/SKILL.md:284:AGENT="sentinel"
packages/harness/cortextos/src/cli/bus.ts:2351:        console.log(`  (skipped ${result.skippedSentinelFiles.length} sentinel-marked file(s): ${result.skippedSentinelFiles.map((f) => f.replace(result.agentDir + '/', '')).join(', ')})`);
packages/harness/cortextos/tests/unit/bus/crons-schema.test.ts:27:    expect(cronsPathFor('sentinel')).toBe(
packages/harness/cortextos/tests/unit/bus/crons-schema.test.ts:28:      join(CRONS_DIRECTORY, 'sentinel', CRONS_FILENAME)
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:19: *   - Files containing the m2c1-worker sentinel comment
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:52:  /** Whether the file was skipped entirely because of the sentinel marker. */
packages/harness/cortextos/src/bus/crons.ts:106: *     is a degraded sentinel, not a real schedule.  Callers that maintain
packages/harness/cortextos/community/agents/security/.claude/skills/activity-channel/SKILL.md:53:cortextos bus post-activity "analyst (sentinel) is online and running nightly metrics."
packages/harness/cortextos/community/agents/security/.claude/skills/agent-management/SKILL.md:184:AGENT="sentinel"
packages/harness/cortextos/community/agents/security/.claude/skills/agent-management/SKILL.md:287:# Example: cortextos bus add-cron sentinel new-cron 2h "Do the thing"
packages/harness/cortextos/templates/analyst/.claude/skills/agent-management/SKILL.md:185:AGENT="sentinel"
packages/harness/cortextos/templates/analyst/.claude/skills/agent-management/SKILL.md:288:# Example: cortextos bus add-cron sentinel new-cron 2h "Do the thing"
packages/harness/cortextos/templates/analyst/.claude/skills/activity-channel/SKILL.md:53:cortextos bus post-activity "analyst (sentinel) is online and running nightly metrics."
packages/harness/cortextos/templates/agent/.claude/skills/activity-channel/SKILL.md:53:cortextos bus post-activity "analyst (sentinel) is online and running nightly metrics."
packages/harness/cortextos/templates/orchestrator/.claude/skills/activity-channel/SKILL.md:53:cortextos bus post-activity "analyst (sentinel) is online and running nightly metrics."
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-management/SKILL.md:196:AGENT="sentinel"
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-management/SKILL.md:299:# Example: cortextos bus add-cron sentinel new-cron 2h "Do the thing"
packages/harness/cortextos/templates/agent/.claude/skills/agent-management/SKILL.md:185:AGENT="sentinel"
packages/harness/cortextos/templates/agent/.claude/skills/agent-management/SKILL.md:288:# Example: cortextos bus add-cron sentinel new-cron 2h "Do the thing"
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/activity-channel/SKILL.md:52:cortextos bus post-activity "analyst (sentinel) is online and running nightly metrics."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:184:AGENT="sentinel"
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:287:# Example: cortextos bus add-cron sentinel new-cron 2h "Do the thing"

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '24,34p;146,156p;240,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   146	    agent: cash-conductor
   147	    timeout: PT24H
   148	    reason: "Outbound payment reminder to customer; reputation + collection risk"
   149	    irreversible: true
   150	
   151	  diagnostic_email_send:
   152	    tier: orange
   153	    agent: diagnostic
   154	    timeout: PT4H
   155	    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
   156	    irreversible: true
   240	# Defaults applied when override fields are absent in tenant_adapters
   241	# ───────────────────────────────────────────────────────────
   242	
   243	defaults:
   244	  approval_timeout: PT4H        # Default orange-tier approval window per §8 rule 5
   245	  min_sample_rate: 100          # Tenants cannot set sample rate above 1-in-100 per §8 rule 6
   246	  spot_check_queue_path: /vault/{tenant_slug}/spot-checks/   # Where autosend_spot_check_enqueue writes
   247	
   248	# ───────────────────────────────────────────────────────────
   249	# Compile-time consistency assertions (enforced by Phase-3 validator script,
   250	# not by YAML itself — documented here so Codex can verify)
   251	# ───────────────────────────────────────────────────────────
   252	
   253	invariants:
   254	  - "tier ∈ {green, yellow, orange, red}"
   255	  - "yellow action_types MUST declare sample_rate (positive integer)"
   256	  - "orange action_types MUST declare timeout (ISO-8601 duration)"
   257	  - "red action_types MUST declare block_reason"
   258	  - "tenant overrides may only ELEVATE tier (green→yellow→orange→red); red is floor"
   259	  - "29 total action_types (6 green + 5 yellow + 10 orange + 8 red); v1.0 frozen"

exec
/bin/zsh -lc "nl -ba docs/decisions/sequencing-target.md | sed -n '1,80p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc 'nl -ba docs/decisions/v1.0-kill-criterion.md | rg -n "Trigger 8|Gate-B|Diagnostic|30%" -C 3' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
60-    60	
61-    61	### Trigger 2 — DIAGNOSTIC-NO-RENDER-W3 (KILL)
62-    62	
63:    63	**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
64-    64	
65-    65	**Owner:** Claude Code (technical detection); founder review (decision authority). Weekly check during Weeks 1-3.
66-    66	
67-    67	**Source:** `sequencing-target.md` §6.6 failure condition (i); Risk #5 in `docs/RISK-REGISTER.md`; ADR-003 §"Consequences" line 141 (renderer is load-bearing Week-1 deliverable).
68-    68	
69:    69	**Action:** KILL state. Rationale: the renderer architecture (ADR-003) was ratified in Week 0 Day 1 evening as the load-bearing Week-1 prerequisite. If Week 3 ends with no clean Diagnostic render, the renderer has fundamental gaps that the design did not anticipate. The renderer cannot be "patched"; v1.0 cannot ship without working render. Continuing into Weeks 4+ without resolution is sunk-cost reasoning.
70-    70	
71-    71	**Recovery path:** None within v1.0. Lessons logged to `.agents/learnings/v1.0-postmortem.md`. v1.1 may begin as new initiative with reconsidered renderer architecture (or no per-tenant render, or different bundle pattern).
72-    72	
--
90-    90	
91-    91	### Trigger 4 — TWO-SCOPE-CUT-ACTIVATIONS (PAUSE)
92-    92	
93:    93	**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
94-    94	
95-    95	**Owner:** Founder; logged in `.agents/decisions/` when activated.
96-    96	
--
155-   155	
156-   156	**Recovery path:** Rescoped infrastructure plan; pivoted v1.0 continues with adjusted Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target; budget adjustment is a runbook revision, not a master-brief edit).
157-   157	
158:   158	### Trigger 8 — GATE-B-REVENUE-UPLIFT (KILL)
159-   159	
160-   160	**Threshold:** After 3 completed pilots (defined as: pilot ran for ≥90 days with active agent fleet and quarterly Gate B revenue measurement), average Gate B revenue uplift per tenant <£20k/year.
161-   161	
--
224-   224	- **Trigger 6 (Unit economics):** founder decides PIVOT direction (cheaper model tier, reduced agent frequency, etc.) → consults Jack on pricing implications before locking → updates Ultraplan pricing plan.
225-   225	- **Trigger 7 (Infrastructure cost):** founder decides PIVOT direction (self-host alternative, provider switch, architecture compaction) → consults Jack on commercial impact before locking.
226-   226	- **Trigger 1 (Design partner) PAUSE → KILL escalation:** if PAUSE extends 4 weeks without signed LOI, founder consults Jack on whether to escalate to KILL (commercial assessment of pipeline) or extend PAUSE.
227:   227	- **Trigger 8 (Gate-B revenue) KILL:** founder decides KILL on revenue evidence; consults Jack on wind-down terms with existing pilots before 30-day notice goes out.
228-   228	
229-   229	The consultation is **binding-on-direction, not binding-on-occurrence**: founder may activate PAUSE/PIVOT/KILL state immediately without Jack's prior input, then refine direction with Jack's commercial input within the 48h window.
230-   230	
--
331-   331	
332-   332	v1.0 is defined by:
333-   333	
334:   334	- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
335-   335	- The infrastructure stack landed in Day 4 (Hetzner NBG1, LUKS, Postgres 16 + pgvector, RLS-isolated multi-tenancy)
336-   336	- The renderer architecture per ADR-003
337-   337	- The autosend safety policy per this Day 5 commit (green + red tiers only)
--
372-   372	
373-   373	**For Week 1-2.** All Week-1 work is conducted with awareness that Trigger 1 fires 2026-06-03 if no LOI (per §1 calendar — Wednesday end-of-Week-2). Founder allocates time accordingly: design-partner acquisition is a Week-1 sub-track, not an afterthought.
374-   374	
375:   375	**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
376-   376	
377-   377	**For Risk Register.** Triggers 1, 2, 3, 5, 6, 7, 9, 10 each correspond to existing register entries (Risks #1-#8 in some combination). Risk #3 is updated in this Day-5 commit to reflect the Day-5 status. Risk #4 (Hire #1) is implicitly linked to Trigger 4 (scope cuts). Codex Day-7 ratification reviews the alignment between kill criterion triggers and risk register entries.
378-   378	

exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-003-agent-bundle-renderer.md | sed -n '1,80p;120,165p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# ADR-003 — Agent Bundle v2 renderer
     2	
     3	**Date:** 2026-05-16 (Week 0, Day 1 evening — Week-1-prerequisite pull-forward)
     4	**Author:** Claude Code, founder decision logged 2026-05-16
     5	**Surfaced by:** `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §"For Week 1 work" + `docs/architecture/agent-bundle-renderer-design.md` (full design)
     6	**Submodule SHA:** `c21fbfe991a0030ea055bd8e2389a0801a424383`
     7	**Status:** Accepted. Founder decision logged 2026-05-16.
     8	
     9	---
    10	
    11	## Context
    12	
    13	ADR-002 §1.7-A surfaced the spec gap. Master brief §8 (lines 545-568) specifies the IFOS Agent Bundle v2 — six files plus three fixtures at `agents/recruitment/<name>/` — but is silent on how the bundle becomes a runnable cortextOS agent. The cortextOS daemon's `AgentManager.discoverAndStart()` (`packages/harness/cortextos/src/daemon/agent-manager.ts:906-941` `discoverAgents()`) reads from `${frameworkRoot}/orgs/<org>/agents/<name>/` with a cortextOS-shaped layout (`config.json`, `CLAUDE.md`, `.env`). The two layouts are incompatible without translation.
    14	
    15	The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
    16	
    17	The design document (`docs/architecture/agent-bundle-renderer-design.md`) specified the renderer across five sections: source vs target layout (§1), the 12-row file mapping + R2 commitment + Concierge worked example (§2), six concrete mechanism decisions including TypeScript Node at `packages/agent-renderer/` (§3.1), manual developer invocation (§3.2), Option γ for `_shared/` origination (§3.3.3), and overwrite-no-merge re-render policy (§3.4), seven failure modes with exit codes (§4), and integration with the broader build (§5). 22 spec gaps surfaced and bucketed. This ADR ratifies the design's recommendations.
    18	
    19	## Decision
    20	
    21	### Decision 1 — Renderer is a new command, not a wrapper around `cortextos-ifos add-agent`
    22	
    23	Per design §5.1: the cortextOS `cortextos-ifos add-agent` command is **unchanged**. IFOS does not use it for IFOS-owned agents. The renderer is a **new** command at `packages/agent-renderer/`, invoked via `ifos-render-agent <agent-name> --tenant <slug>` (standalone Node binary per `package.json` `bin`; **errata via ADR-004 Decision 1** — earlier drafts named this `cortextos-ifos render-agent` which would have required modifying the read-only submodule per master brief §3.1 boundary 1).
    24	
    25	**R2 commitment** per design §2.2: no `.claude/skills/` inheritance from cortextOS templates. Default is exclusion of all 24 cortextOS-template skills. Opt-in for specific skills only via the bundle's `tools.yaml` `cortextos_skills:` top-level block (syntax per design §2.2 spec gap §2.2-A resolution).
    26	
    27	**Protection against accidental `cortextos-ifos add-agent` scaffolding** per design §5.1: marker file `.rendered-by-ifos-renderer` written as the **last** step of every successful render. Renderer preflight refuses with exit code 7 if the target directory exists without this marker; overridable via `--force-overwrite-non-rendered`. This fires before any writes; no partial damage possible.
    28	
    29	### Decision 2 — Renderer lives at `packages/agent-renderer/`
    30	
    31	Per design §3.1: TypeScript Node. Tooling matched against `packages/harness/cortextos/package.json:11-13` for consistency:
    32	
    33	- Build: `tsup`
    34	- Tests: `vitest`
    35	- CLI: `commander`
    36	
    37	Three alternatives rejected per design §3.1: `packages/brain/agent-cli/` (wrong cohesion — brain is wiki, renderer is not a wiki concern); `scripts/render-agent.sh` (JSON Schema validation + YAML parsing harder in shell); new top-level directory (loses master brief §4.1 line 195-204 `packages/` convention).
    38	
    39	**Invocation mode** per design §3.2: manual developer invocation. Day-1 cadence (founder + Claude Code), per-tenant scope explicit, hand-off boundary clean. Three alternatives rejected per design §3.2: pre-push hook (wrong filesystem — tenant vault on Hetzner UK VPS, hook on dev laptop), CI on merge (same reachability problem), daemon auto-watcher (wrong coupling — daemon is read-only on submodule per master brief §3.1).
    40	
    41	**`_shared/` origination** per design §3.3.3 Option γ (hybrid): IFOS repo at `agents/_shared/` is canonical source; renderer copies to `${frameworkRoot}/orgs/<org>/agents/_shared/` once per render invocation (SHA-skip when unchanged); per-agent `.claude/hooks/_shared` symlink resolves to `../../_shared` (relative).
    42	
    43	### Decision 3 — Translation contract per design §2.1
    44	
    45	12-row file-by-file mapping ratified verbatim:
    46	
    47	- **Synthesis (3):** `agent.md` → `CLAUDE.md` (with cortextOS preamble wrapper); `config.schema.json` → `config.json` (materialised via per-tenant `_config.yaml` + common-*.json $refs); `(no source)` → `.env` (from `_secrets.env` + tools.yaml MCP server list).
    48	- **Passthrough (1):** `tools.yaml` → `tools.yaml` (verbatim).
    49	- **Verbatim copy (3):** `validate.sh` → `.claude/hooks/validate.sh`; `context.sh` → `.claude/hooks/context.sh`; `README.md` → `README.md`.
    50	- **Stays in source (1):** `tests/fixtures/` — never copied to runtime; CI fixture runner reads from IFOS repo.
    51	- **Drop (2):** cortextOS template files (IDENTITY.md / SOUL.md / GUARDRAILS.md / GOALS.md / HEARTBEAT.md / MEMORY.md / USER.md / SYSTEM.md / TOOLS.md / AGENTS.md / memory/ / experiments/) and the 24-skill `.claude/skills/` tree.
    52	- **Empty placeholder (1):** `goals.json` materialised as `{focus:"",goals:[],bottleneck:"",updated_at:"",updated_by:""}` per `add-agent.ts:131-140` for daemon-side compatibility.
    53	
    54	The Concierge worked example in design §2.3 demonstrates end-to-end render: source bundle layout, CLAUDE.md preamble draft (resolves spec gap §2.1-A), materialised `config.json`, synthesised `.env`, hook files verbatim, `_shared/` symlink resolution.
    55	
    56	### Decision 4 — Re-render policy: overwrite, no merge
    57	
    58	Per design §3.4: re-render replaces target directory verbatim. Hand-edits to rendered output are lost. Discipline: hand-edits go to source bundle, then re-render. Warning banner in stdout: `WARN: This will overwrite ${target}; any hand-edits will be lost.`
    59	
    60	Two alternatives rejected per design §3.4: merge-with-conflict-markers (premature complexity — master brief §1 Rule 1 "output before architecture" favours simple); refuse-if-exists (friction without benefit — Decision 1's marker-file check handles the actual risk).
    61	
    62	**No-op detection** per design §3.4: four-condition check (bundle SHA `git hash-object -t tree` + render log + `/vault/<tenant>/_config.yaml` mtime + `agents/_shared/` SHA). If all four match the last successful render, renderer exits 0 with `No-op:` stdout and a `render_outcome: no-op` JSONL line.
    63	
    64	**Atomicity** per design §3.3.4: write to `<name>.tmp.<pid>/`, rename existing target to `<name>.prev.<timestamp>/`, atomic rename `<name>.tmp.<pid>/` → `<name>/`, clean up older `.prev`. The daemon's `discoverAgents()` filters by directory name pattern; the `.tmp.<pid>/` and `.prev.<timestamp>/` directories are invisible to discovery.
    65	
    66	## Master brief edits authorised by this ADR
    67	
    68	**Errata 2026-05-20 (ADR-004):** Edit B's CLI command text was revised post-ADR-004 from `cortextos-ifos render-agent` to `ifos-render-agent`. The proposed text block below reflects the corrected name. See ADR-004 §"Master brief edits authorised" Edit D for the full disposition.
    69	
    70	Three edits per design §5.3. Edits A and B land in this ADR's commit (small wording adds; Edit A is needed live before Week-1 renderer implementation). Edit C joins the deferred atomic correction commit alongside ADR-001 + ADR-002 edits.
    71	
    72	### Edit A — Master brief §4.1 directory list
    73	
    74	**Current** (master brief §4.1 lines 195-204):
    75	
    76	> ```bash
    77	> mkdir -p docs/{specs,architecture,verticals/recruitment,verticals/_future,decisions,runbooks,build-brief,risk}
    78	> mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext}
    79	> mkdir -p packages/brain/{bus-overrides,wiki,graphify,brain-ui}
    80	> mkdir -p packages/agents-runtime/_shared/{hooks,fixtures}
   120	> # Test against fixtures; iterate; commit; PR; merge.
   121	>
   122	> # After merge, render the bundle for each tenant that uses this agent:
   123	> ifos-render-agent {name} --tenant <slug>
   124	> # For all active tenants (v1.1+): the --all-tenants flag is deferred to a future ADR-005 (see ADR-004 Edit D)
   125	> # Activate: pm2 restart ifos-daemon   (for new agents)
   126	> #       OR: cortextos-ifos bus self-restart {name}   (for re-renders of running agents)
   127	> ```
   128	
   129	Lands in this ADR's commit.
   130	
   131	### Edit C — Master brief §8 footnote referencing the renderer
   132	
   133	**Current** (master brief §8 lines 545-568): bundle file list followed immediately by §8.1 ("The three v2 changes"). No footnote between §8 and §8.1.
   134	
   135	**Proposed:** insert a one-paragraph footnote at the end of §8 (before §8.1):
   136	
   137	> "The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly. The renderer (`packages/agent-renderer/`, per `docs/decisions/ADR-003-agent-bundle-renderer.md` and `docs/architecture/agent-bundle-renderer-design.md`) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant). The cortextos-ifos add-agent command is NOT the IFOS path — it inherits 24 cortextOS template skills the IFOS bundle does not want."
   138	
   139	Joins the deferred atomic correction commit (parallel to ADR-002 Edit 1 + Edit 2). Codex ratifies the combined commit on Day 7 per master brief §10.6.
   140	
   141	## Consequences
   142	
   143	**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
   144	
   145	**For Week 0 remaining (Day 2 through Day 7).** ADR-003 doesn't unblock or block any remaining Week 0 work directly. Day 2 (Bullhorn integration path), Day 3 (sequencing + Brain UI scope), Day 4 (Postgres provisioning with `entities` + `entity_links` split per ADR-002 Edit 3 + `_secrets.env` skeleton), Day 5 (auto-send safety policy + kill criterion), Day 6 (vertical schema v0.1), Day 7 (single-sentence test + first Codex ratification) all proceed independently. The renderer is queued for Codex Day-7 review but does not gate Day 7's other reviews.
   146	
   147	**For Risk #5 (renderer-not-built).** Severity drops from **Blocking** to **High** with ADR-003 Accepted — design exists, ratified; just needs implementing. Drops to **Medium** once renderer code is committed and the Diagnostic agent renders cleanly (Week 4). Drops to **Low** once all five v1.0 agent bundles render and pass validation. The risk register entry is updated in this session as part of the ADR-003 commit.
   148	
   149	**For Codex Day-7 ratification queue.** ADR-003 + the design doc join the queue alongside `cortextos-primitive-status.md`, ADR-001, ADR-002, `second-brain-design.md`, the deferred atomic master-brief correction commit, and the Day-4 Postgres provisioning artefact. The 22-item spec gap consolidation in design §5.4 plus the four-bucket structure (resolved inline / master-brief edits / Week-1+ prerequisites / operational defaults) is the ratification-supporting evidence.
   150	
   151	**For the master brief atomic correction commit.** Edit C (the §8 footnote) joins ADR-001 + ADR-002 edits in the deferred single commit at end of Week 0 / early Week 1. Edits A and B land in this batch's commit because (a) Edit A is needed live before Week-1 renderer implementation can scaffold the package path, (b) Edit B is a small wording add to a code block, (c) neither is substantive enough to warrant the atomic-correction overhead.
   152	
   153	**For future ADRs.** ADR-003 explicitly defers three further decisions:
   154	
   155	- **Renderer implementation details** (test coverage matrix, packaging strategy, schema-validator library choice between Ajv vs alternatives) — to ADR-004 in Week 1 if the implementation work surfaces architectural choices, or to the implementation PR itself if straightforward.
   156	- **`_shared/` helper code authoring** (`voice-loader.sh`, `hook-helpers.sh` contents) — already on the Week-1 prerequisite list per ADR-002 §"For Week 1 work." Not an ADR; just implementation work.
   157	- **`docs/architecture/vault-concurrency.md` companion document** — already on the Week-1 prerequisite list per ADR-002. Not an ADR; resolves design §2.6 spec gap.
   158	
   159	## Status
   160	
   161	**Accepted.** Founder decision logged 2026-05-16. Next steps:
   162	
   163	1. Edits A and B applied to master brief §4.1 and §8.3 in this batch's commit.
   164	2. Edit C (§8 footnote) joins ADR-001 + ADR-002 edits in the deferred atomic correction commit at end of Week 0 / early Week 1. Five-edit manifest for that commit confirmed: ADR-001 §2.4 row 3 + Ultraplan §3.2; ADR-002 Edit 1 §3.4 + Edit 2 §5.5; ADR-003 Edit C §8.
   165	3. Renderer implementation begins Week 1.

codex
REJECTED

1. The artefact weakens Gate A citation requirements. Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires “no claims unsupported by source data.” This lowers a stated Gate A constraint. Fix: make v1.0 Gate A reject unsupported claims, or explicitly amend the upstream Ultraplan requirement before this artefact relies on the weaker gate.

2. Workflow Step 11 performs an action without the required decision-log call. Lines 140-142 send an optional Telegram notification, but line 73 says every step that produces output or takes action MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146. Fix: add a `hh_decision_action` call for the notification action, or remove the notification from v1.0.

3. The Gate-B kill-criterion citation is inaccurate. Line 169 claims Diagnostic’s 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but `docs/decisions/v1.0-kill-criterion.md` Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion. Fix: describe Diagnostic conversion as a local leading metric, or update the kill criterion with a cited amendment.

4. The artefact introduces an undeclared sentinel `agent_name`. Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers. Fix: define `_consultant_feedback` in the decision-log/sentinel catalogue, or log feedback under `agent_name='diagnostic'` with a payload action.

5. Under the supplied architecture-decision review skill, the document is missing required decision-doc shape. The file has `Status: Proposed` at line 3, but no `Context`, `Decision`, or `Consequences` sections as required for Proposed artefacts by review-architecture-decision §1. Fix: either review this with `review-agent-bundle.md`, or add the required architecture-decision sections and a final status-update line.
tokens used
81,626
REJECTED

1. The artefact weakens Gate A citation requirements. Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires “no claims unsupported by source data.” This lowers a stated Gate A constraint. Fix: make v1.0 Gate A reject unsupported claims, or explicitly amend the upstream Ultraplan requirement before this artefact relies on the weaker gate.

2. Workflow Step 11 performs an action without the required decision-log call. Lines 140-142 send an optional Telegram notification, but line 73 says every step that produces output or takes action MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146. Fix: add a `hh_decision_action` call for the notification action, or remove the notification from v1.0.

3. The Gate-B kill-criterion citation is inaccurate. Line 169 claims Diagnostic’s 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but `docs/decisions/v1.0-kill-criterion.md` Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion. Fix: describe Diagnostic conversion as a local leading metric, or update the kill criterion with a cited amendment.

4. The artefact introduces an undeclared sentinel `agent_name`. Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers. Fix: define `_consultant_feedback` in the decision-log/sentinel catalogue, or log feedback under `agent_name='diagnostic'` with a payload action.

5. Under the supplied architecture-decision review skill, the document is missing required decision-doc shape. The file has `Status: Proposed` at line 3, but no `Context`, `Decision`, or `Consequences` sections as required for Proposed artefacts by review-architecture-decision §1. Fix: either review this with `review-agent-bundle.md`, or add the required architecture-decision sections and a final status-update line.
