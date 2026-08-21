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
session id: 019e5973-d7ff-78a2-b8da-f66d30948bce
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

> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least one evidence link (Companies House URL, LinkedIn URL, or careers-page URL) backing every factual claim — Gate A hard-fails on missing citations. The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).

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
   → ESC_SCHEMA_VIOLATION if firm name malformed

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

Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by tagging the report's outcome in `decision_log.payload.gate_b_outcome` when the consultant updates status (via Telegram or Brain UI v1.1).

Gate B doesn't block the agent — it's the v1.0 kill criterion §2 Trigger 5 metric. Below 30% sustained for 4 weeks → revisit Diagnostic's output quality.

---

## §6 — Escalation codes

Diagnostic uses these ESC codes from `agents/_shared/escalation-codes.md`:

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall |
| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn 429 | warn | operator_chat_id |
| `ESC_SCHEMA_VIOLATION` | Section count != 12 OR malformed input | warn | operator_chat_id |
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
- **`hh_load_recent_edits` last 30 days for `concierge` + `diagnostic`**: surfaces patterns of how consultant edits agent drafts. If drift is detected (edit-distance > 200 chars on >50% of recent_edit rows), `ESC_VOICE_DRIFT_TENANT` fires (per `escalation-codes.md` §2.5).

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
I’ll verify the artefact against the shared rules first, then sample the cited repository files for schema, ESC codes, autosend fields, and citation accuracy before deciding.
exec
/bin/zsh -lc "rg -n \"§8\\.2|§8\\.1|§5\\.3|§2\\.1|diagnostic|12 required sections|30%|Decision 7|cost target|execution-plan §3|kill-criterion|autosend-safety-policy §4|Change 2|Change 1|Rule 1\" docs agents .codex -S" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "rg --files | rg '("'^docs/|''^agents/_shared/|''^agents/recruitment/diagnostic/|vertical-schema.yaml|autosend|sequencing|Ultraplan|ultraplan|execution-plan|tenant-lifecycle)'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
agents/_shared/README.md
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/design-mockups/brain-ui-decisions-feed-light-v01.html
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md
docs/decisions/brain-ui-scope.md
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
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/decisions/sequencing-target.md
docs/decisions/bullhorn-integration-path.md
agents/recruitment/diagnostic/cleanup.sh
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
docs/runbooks/day-4-provisioning.md
docs/runbooks/operational-hygiene-protocol.md
docs/runbooks/tenant-lifecycle.md
docs/runbooks/pii-purge-operational-pattern.md
docs/architecture/tenancy-invariants.md
docs/architecture/architecture-cohesion-review.md
docs/architecture/agent-bundle-renderer-design.md
docs/architecture/cortexos-kb-surface-investigation.md
docs/architecture/cortexos-primitive-status.md
docs/architecture/vault-concurrency.md
docs/architecture/second-brain-design.md
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml
agents/recruitment/diagnostic/fixtures/01-primary.yaml
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml
agents/recruitment/diagnostic/cycle.sh
agents/recruitment/diagnostic/README.md
agents/recruitment/diagnostic/tools.yaml
agents/recruitment/diagnostic/validate.sh
agents/recruitment/diagnostic/context.sh
docs/build-brief/00-MASTER-BRIEF.md
agents/recruitment/diagnostic/agent.md
docs/operations/bullhorn-outreach-emails.md
docs/operations/codex-ratification-guide.md
docs/operations/codex-round-2-handoff.md
docs/operations/codex-round-2-remediation-prompt.md
docs/operations/codex-ratification-execution-plan.md
docs/operations/codex-round-2-autonomous-prompt.md
docs/operations/goal-week-3-polish-and-scaffold.md
docs/operations/seedlegals-engagement-queries.md
docs/operations/goal-option-c-diagnostic-end-to-end.md
docs/operations/founder-legal-setup-guide.md
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md
docs/artefacts/diagnostic-hays-plc-2026-05-24.md
logs/codex-ratification/round-2-autonomous/docs_decisions_sequencing-target-md.output.md
logs/codex-ratification/round-2-autonomous/docs_runbooks_tenant-lifecycle-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-approval-bridge-spec-md.output.md
logs/codex-ratification/round-3-remediation/docs_decisions_autosend-approval-bridge-spec-md.output.md
logs/codex-ratification/manual-run/docs_decisions_sequencing_target_md.output.md
logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md
docs/specs/ULTRAPLAN.md
docs/specs/_archive-build-handoff.md
docs/specs/PRODUCT-SPEC.md
docs/_supplementary/PRD-autonomous-agent.md
docs/_supplementary/build-plan-original.md
docs/_supplementary/README.md
docs/_supplementary/strategic-plan.md
docs/_supplementary/planning-phase-brief.md
docs/_supplementary/technical-strategy-v2.md
docs/_supplementary/execution-plan.md
legacy/v1/docs/phase-0-strategic/intelforce-execution-plan.md

 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:397:      - A: Single retry then escalate (current Ultraplan §5.3 default)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:400:    v0_2_default: A; matches Ultraplan §5.3 retry budget for green-path agents
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:419:    trigger_for_revisit: external advisor onboarding (kill-criterion §3.4 Week 1-2 must-fill) — legal/DPO review of retention posture
.codex/ratification/review-schema-change.md:34:- `v1_0_agent_access` — list of agents from master brief §8.2 with R / W / R+W disposition, OR explicit "none (v1.1+ exercise)"
.codex/ratification/review-schema-change.md:86:- `Diagnostic` must have `none` or `R` for all entities — Diagnostic doesn't write to Bullhorn per `sequencing-target.md` §2.1
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
agents/_shared/README.md:58:### 7 `autosend_*` helpers (autosend-safety-policy §4)
agents/_shared/README.md:70:## Auto-send tier dispatch (autosend-safety-policy §4)
agents/_shared/README.md:88:**Not tested:** the full 4h wall-clock timeout in production. First Diagnostic agent build (Week 3) is the natural place to exercise this — Diagnostic uses `diagnostic_email_send` (orange tier, PT4H timeout).
agents/_shared/README.md:98:### `voice-loader.sh` helpers (3, master brief §8.1 Change 1)
agents/_shared/README.md:123:4. Founder runs the kill-criterion Trigger 5 query (autosend-safety-policy §7):
agents/_shared/README.md:130:5. Report result back. If row count > 3 in a 7-day window, kill-criterion Trigger 5 fires (per `v1.0-kill-criterion.md` §2 Trigger 5).
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
agents/_shared/README.md:178:- `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 5 — red-tier breach kill criterion
agents/_shared/README.md:180:- `docs/build-brief/00-MASTER-BRIEF.md` §8.1 Changes 2+3 — decision-log + ESC vocabulary
.codex/ratification/SKILL.md:50:- **Citation accuracy** — section references like "§X.Y" MUST be verifiable. Open the cited file at the cited line/section; does the citation hold? Past violations: a Day-6 audit found 15 fabricated "master brief §10.4 cost target" references; §10.4 is actually the Codex exclusion list.
agents/_shared/autosend-policy.yaml:29:  diagnostic_report_render:
agents/_shared/autosend-policy.yaml:31:    agent: diagnostic
agents/_shared/autosend-policy.yaml:151:  diagnostic_email_send:
agents/_shared/autosend-policy.yaml:153:    agent: diagnostic
agents/_shared/autosend-policy.yaml:155:    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
agents/_shared/autosend-policy.yaml:158:  diagnostic_calendar_invite:
agents/_shared/autosend-policy.yaml:160:    agent: diagnostic
agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
.codex/ratification/review-architecture-decision.md:66:If even one citation is wrong, REJECT with the specific citation listed. Past pattern: `master brief §10.4 cost target` cited 15 times; §10.4 is actually the Codex exclusion list with no cost-target content.
.codex/ratification/review-architecture-decision.md:92:- Not contradict each other (gap §2.1-A resolution must not break gap §2.1-B resolution)
.codex/ratification/review-architecture-decision.md:112:## §7 — Decision_log audit fields (master brief §8.1 Change 2)
docs/verticals/recruitment/vertical-schema.yaml:14:#       + Day-5 v1.0-kill-criterion.md (Trigger 1 acquisition-by-2026-06-03)
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:132:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:43:### Decision 3 — Translation contract per design §2.1
docs/decisions/ADR-003-agent-bundle-renderer.md:54:The Concierge worked example in design §2.3 demonstrates end-to-end render: source bundle layout, CLAUDE.md preamble draft (resolves spec gap §2.1-A), materialised `config.json`, synthesised `.env`, hook files verbatim, `_shared/` symlink resolution.
docs/decisions/ADR-003-agent-bundle-renderer.md:60:Two alternatives rejected per design §3.4: merge-with-conflict-markers (premature complexity — master brief §1 Rule 1 "output before architecture" favours simple); refuse-if-exists (friction without benefit — Decision 1's marker-file check handles the actual risk).
docs/decisions/ADR-003-agent-bundle-renderer.md:70:Three edits per design §5.3. Edits A and B land in this ADR's commit (small wording adds; Edit A is needed live before Week-1 renderer implementation). Edit C joins the deferred atomic correction commit alongside ADR-001 + ADR-002 edits.
docs/decisions/ADR-003-agent-bundle-renderer.md:133:**Current** (master brief §8 lines 545-568): bundle file list followed immediately by §8.1 ("The three v2 changes"). No footnote between §8 and §8.1.
docs/decisions/ADR-003-agent-bundle-renderer.md:135:**Proposed:** insert a one-paragraph footnote at the end of §8 (before §8.1):
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
agents/_shared/tests/test-hook-helpers.sh:109:  hh_decision_output "diagnostic_report" "/vault/x/y.md"
agents/_shared/tests/test-hook-helpers.sh:113:    && _assert_contains "${row}" '"output_type":"diagnostic_report"'
agents/_shared/tests/test-hook-helpers.sh:118:test_lookup_green() { local t; t=$(autosend_policy_lookup "diagnostic_report_render"); _assert_eq "green" "${t}" "green"; }
agents/_shared/tests/test-hook-helpers.sh:132:  hh_decision_action "diagnostic_report_render" "candidate:test" "abc123" "test preview"
agents/_shared/tests/test-hook-helpers.sh:303:_test_run "kill-criterion Trigger 5: red-tier rows queryable by tier+phase" test_kill_criterion_trigger5
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:43:- `docs/decisions/v1.0-kill-criterion.md` §3.4 ("Week 1-2 must-fill")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:49:**Real issue:** v1.0 kill-criterion §3.4 names "external advisor" as a Week 1-2 must-fill. This is also the resolution path for autosend §10 pilot-agreement liability. Today = 2026-05-20 (Day 8 = Week 1 underway). No advisor identified.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:54:- **D2-C: Use boilerplate UK SaaS LOI template** (off-the-shelf) without lawyer engagement. Cheap but high risk for kill-criterion §3.4 explicit external-advisor requirement.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:58:**Cost of delay:** Trigger 1 fires 2026-06-03 if no LOI. If LOI lands but advisor isn't engaged, founder has to choose between violating kill-criterion §3.4 or delaying LOI past Trigger 1. Engage now to avoid the forced choice.
agents/_shared/hook-helpers.sh:4:# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
agents/_shared/hook-helpers.sh:163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
agents/_shared/hook-helpers.sh:259:# 7 autosend_* helpers (autosend-safety-policy §4)
agents/_shared/escalation-codes.md:4:**Mandated by:** master brief §8.1 Change 3 — "Build the catalogue in Week 0. New codes only when production demands one."
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:118:Source: master brief §8.1 Change 3 lines 585-592
agents/_shared/escalation-codes.md:122:- **Trigger:** Voice classifier score below `common-voice.json.voice_classifier_threshold` (default 0.75) after 3 retries per Ultraplan §5.3 retry budget
agents/_shared/escalation-codes.md:129:- **Trigger:** Dedup confidence `≥ 0.85` per Ultraplan §8.1 line 511 A2 Gate A; human-review-required cases
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:158:- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
agents/_shared/escalation-codes.md:231:| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
agents/_shared/escalation-codes.md:232:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
docs/decisions/brain-ui-scope.md:19:- **v1.2:** graph view (cytoscape force-directed, master brief §5.3 line 396).
docs/decisions/brain-ui-scope.md:41:- Shows recent `decision_log` entries with phase + outcome filtering (`trigger | output | action | gating_failed | agent_handoff` per `sequencing-target.md` §5.3 + §6.5 enum extension).
docs/decisions/brain-ui-scope.md:51:- No mobile-optimised layout (desktop-first per master brief §5.3 line 397 framework choice).
docs/decisions/brain-ui-scope.md:62:- Implements the `wiki-links.sh` backlinks read API per ADR-003 §"Decision 3" + design §2.1 — v1.1 release of the wrapper.
docs/decisions/brain-ui-scope.md:102:Add `/brain/*` routes to the existing cortextOS Next.js 14 dashboard at `packages/harness/cortextos/dashboard/`. Master brief §5.3 lines 380-403 already names this pattern: "**same Next.js app, additional routes in a sibling folder**, mounted via the dashboard's `dashboard-ext` integration point" at `packages/dashboard-ext/src/app/(dashboard)/brain/`.
docs/decisions/brain-ui-scope.md:112:- Needs IFOS-owned auth — WorkOS AuthKit per master brief §5.3 line 401 ("Auth: WorkOS AuthKit (per memory: founder already uses this)").
docs/decisions/brain-ui-scope.md:121:| Auth model | cortextOS dashboard auth | WorkOS AuthKit per master brief §5.3 line 401 |
docs/decisions/brain-ui-scope.md:123:| Mobile / responsive design | Inherits dashboard's responsive model | Owned by IFOS, designable for product spec §2.1.3 "looks stunning" requirement |
docs/decisions/brain-ui-scope.md:126:**Recommendation deferred to v1.1 planning.** Master brief §5.3 lines 379-380 currently favours Option α: "**The strategy: same Next.js app, additional routes in a sibling folder**, mounted via the dashboard's `dashboard-ext` integration point." That's the canonical-master-brief stance and is the default unless v1.0 ops surface a reason to deviate. This document does not bind the decision in v1.0 — it's revisited with v1.0-actual-usage evidence.
docs/decisions/brain-ui-scope.md:140:- **Obsidian** against `/vault/<tenant-slug>/wiki/` directly per `second-brain-design.md` §2.1 + §2.6.2 — primary read access; respects the `human_editing: true` flag concurrency mechanism per design §2.6.2.
docs/decisions/brain-ui-scope.md:218:| Mobile / responsive design support | v1.2+ — explicitly deferred per §2.1 "no mobile-optimised layout" |
agents/recruitment/cash-conductor/agent.md:6:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:9:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
agents/recruitment/cash-conductor/agent.md:15:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/cash-conductor/agent.md:137:14 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/cash-conductor/agent.md:240:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 539 verbatim):
agents/recruitment/cash-conductor/agent.md:260:This is THE FD-tier closer metric per master brief §8.2 line 597. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:300:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/cash-conductor/agent.md:355:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
agents/recruitment/cash-conductor/agent.md:372:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
docs/architecture/tenancy-invariants.md:132:- **Documentation source:** ADR-003 §2.1 row 3 + renderer source `packages/agent-renderer/src/renderer.ts` line ~150 (writeFileTracked call).
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:31:Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:68:build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
agents/recruitment/scribe/agent.md:6:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:14:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown attachment containing the consultant's "things I'd write down but there's no field for" observations. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:127:10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/scribe/agent.md:202:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:263:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/sourcing-scout/agent.md:6:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:14:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/sourcing-scout/agent.md:104:11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/sourcing-scout/agent.md:193:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 553 verbatim):
agents/recruitment/sourcing-scout/agent.md:258:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/_shared/voice-loader.sh:4:# §8.1 Change 1. Sourced by every agent's context.sh at session start; emits
agents/recruitment/janitor/README.md:9:| `agent.md` | Output-contract-first agent specification per master brief §1 Rule 1 | Proposed |
agents/recruitment/janitor/agent.md:6:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:8:**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.1.
agents/recruitment/janitor/agent.md:14:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/janitor/agent.md:59:| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:79:12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/janitor/agent.md:168:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:186:Gate B doesn't block the agent. It's the v1.0 kill-criterion §2 Trigger 8 supporting metric ("Gate-B revenue uplift" — Janitor's day-30 report is THE artefact that demonstrates "DSO drops" / "consultant time saved" claims to the FD-tier closer).
agents/recruitment/janitor/agent.md:226:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/janitor/agent.md:252:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
agents/recruitment/janitor/agent.md:290:- First production run against migration-test tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:32:| 17 | `docs/decisions/v1.0-kill-criterion.md` + Day-5 close commit `c6734d1` | Proposed + audit log | Verify 10 binary triggers; verify §3 founder-solo authority structure; verify live SQL migration (decision_log.phase 5→6) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:71:| 11 | `docs/decisions/v1.0-kill-criterion.md` | RATIFIED | Incorporated remediation verified clean. |
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
docs/decisions/2026-05-18-codex-ratification-manifest.md:158:| 8 | sequencing-target.md | REJECTED (2 issues) | Issue 1 (status drift) **incorporated** at `2b287d3`. Issue 2 (phase enum cite) implicitly addressed via ADR-004 Decision 7 cross-reference. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:167:| 17 | v1.0-kill-criterion.md | REJECTED (3 issues) | All three (Trigger 1 date / Trigger 2 CLI / Trigger 4 threshold) **incorporated** at `2b287d3`. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:249:| 5 | §8 renderer footnote (before §8.1) | ADR-003 Edit C | ✓ verbatim |
docs/decisions/2026-05-18-codex-ratification-manifest.md:272:| 17 | `v1.0-kill-criterion.md` §3.4 external advisor | TBD — Week 1-2 must-fill | Founder identifies + engages external advisor before first pilot LOI signs. Codex flags the TBD but cannot resolve. |
docs/architecture/architecture-cohesion-review.md:34:| **Helpers + storage** | vault-concurrency.md (locks + version), v0.1 schema, v0.2 supplement, kill-criterion.md (Trigger 5 audit) |
docs/architecture/architecture-cohesion-review.md:62:| ADR-003 | spec gap §2.1-A (preamble) | `packages/agent-renderer/templates/claude-md-preamble.md` | ✓ landed Phase 1 (a279226) |
docs/architecture/architecture-cohesion-review.md:63:| ADR-003 | spec gap §2.1-B (common schemas) | `packages/agents-runtime/_shared/common-*.json` | ✓ landed Phase 1 (a279226), 8 files |
docs/architecture/architecture-cohesion-review.md:64:| ADR-003 | spec gap §2.1-C (_secrets.env) | Day-4 §6.5 provisioning + renderer envFile.ts | ✓ landed Day-4 + Phase 2 |
docs/architecture/architecture-cohesion-review.md:68:| ADR-003 | phase enum for renderer | Day-4 §6.3 CHECK constraint | **✓ landed but with deviation per ADR-004 Decision 7** — phase='render' NOT in enum; uses agent_name='_renderer' + existing phase |
docs/architecture/architecture-cohesion-review.md:109:- **Resolution:** ADR-004 Decision 7 (Codex Round 1 RATIFIED) + Day-8-evening remediation `2b287d3` corrected both renderer-design + ADR-003 to use `agent_name='_renderer'` + existing `phase=gating_failed|action`. **RESOLVED.**
docs/architecture/architecture-cohesion-review.md:150:| G4 | **The agent runtime's `validate.sh` invocation contract is implicit.** ADR-003 §2.1 row 5 says it's a verbatim copy to `.claude/hooks/validate.sh`. But what does the runtime DO with it? Is it called before every tool use? Once per session? | Medium (every agent uses validate.sh) | Diagnostic W3 build's agent.md preamble names the invocation; pattern propagates. Add to tenant-lifecycle runbook. |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:5:**Companion:** `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 execution prompt)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:13:ULTRAPLAN.md §8.1 specifies the v1.0 build sequence:
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:19:| 4 | **Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint** per ULTRAPLAN line 753 |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:41:| W3 Days 13-20: Bullhorn MCP server build | W3 Days 13-20: Diagnostic end-to-end (per `goal-option-c-diagnostic-end-to-end.md`) |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:51:5. **Buffer on kill-criterion Trigger 2.** `v1.0-kill-criterion.md` Trigger 2 fires 2026-06-14 if Diagnostic doesn't render cleanly. Today is 2026-05-24 — 21 days of buffer. Building now beats the deadline by 3 weeks.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:58:- ✅ Web scraper + Companies House MCP connector + diagnostic-generator package shipped Day 13 (commits `800a265`, `860f29c`, `5614dcb`, `fd38254`)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:95:| diagnostic-generator package + cycle.sh wiring | ✅ | `fd38254` |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:106:- ULTRAPLAN §8.1 line 753-755 (Week-4 milestone definition)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:109:- `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render by 2026-06-14)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:111:- `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 execution prompt)
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:21:The subsequent design pass (`docs/architecture/second-brain-design.md`) went further. Q1.4 found that **no IFOS agent calls `kb-*`** — the IFOS Agent Bundle v2 (master brief §8.1) has no `MEMORY.md`, no heartbeat memory file, and uses Postgres `decision_log` for the persistence role cortextOS's KB fills. The §3.4 seam was designed to shadow calls our agents don't make. Q3 evaluated three interface options against the post-design constraints (§3.2 rubric) and recommended Option α — a parallel `packages/brain/bus-overrides/wiki-*.sh` surface with no shadowing of cortextOS's bus.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:62:- **Filesystem markdown** at `/vault/{tenant-slug}/wiki/` per design §2.1 (POSIX 0700 / 0644, per-tenant OS user `ifos-tenant-{slug}` per Ultraplan §5.1 line 218).
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:127:- **Future v1.1+ ADR (Brain UI implementation choice)** — Next.js routes extending the cortextOS dashboard per master brief §5.3 vs. standalone — out of scope for Q3.
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:142:| `diagnostic_email_send` | `external-comms` |
docs/decisions/autosend-approval-bridge-spec.md:143:| `diagnostic_calendar_invite` | `external-comms` |
agents/recruitment/diagnostic/cleanup.sh:79:hh_decision_action "diagnostic_cleanup" "agent:${CTX_AGENT_NAME:-diagnostic}" \
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:9:# Per kill-criterion §2 Trigger 5 + agent.md §6: voice drift is an
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:18:agent: diagnostic
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:22:  command: ifosctl diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:14:agent: diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:19:  command: ifosctl diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:85:  vault_path_template: "/vault/migration-test/diagnostic-reports/charterhouse-partners-{ISO_DATE}.md"
agents/recruitment/diagnostic/fixtures/01-primary.yaml:99:    agent_name: diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:102:    agent_name: diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:103:    payload_includes: {output_type: "diagnostic_draft"}
agents/recruitment/diagnostic/fixtures/01-primary.yaml:105:    agent_name: diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:106:    action_type: diagnostic_report_render
agents/recruitment/diagnostic/fixtures/01-primary.yaml:109:    agent_name: diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:110:    action_type: diagnostic_cleanup
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:15:agent: diagnostic
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:19:  command: ifosctl diagnostic
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:99:    payload_includes: {output_type: "diagnostic_draft"}
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:101:    action_type: diagnostic_report_render
docs/_supplementary/PRD-autonomous-agent.md:676:- Any pillar with 0 reels in last 14 days gets +30% priority boost
docs/decisions/autosend-safety-policy.md:6:**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:81:| Diagnostic | `diagnostic_report_render` | Internal artefact write; no external comms; idempotent (re-render overwrites) |
docs/decisions/autosend-safety-policy.md:108:| Diagnostic | `diagnostic_email_send` | Outbound diagnostic report to prospect; sales-stage outreach; reputation |
docs/decisions/autosend-safety-policy.md:109:| Diagnostic | `diagnostic_calendar_invite` | Books intro call with prospect; reputation + scheduling friction |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:235:Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.
docs/decisions/autosend-safety-policy.md:344:**Expected resolution:** IFOS oncall investigates within 1h during business hours; within 4h outside business hours. The affected tenant pilot may be PAUSED for that agent until policy is fixed (per `v1.0-kill-criterion.md` §2 trigger 5).
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:585:4. **Cyber insurance.** IFOS Limited needs cyber insurance covering policy miscategorisation events. Quote requests pending; budget impact on v1.0 founder-set cost budget (Day-4 runbook §1.4 — £20/mo for infrastructure at single-tenant pilot scale; master brief does not specify a numeric cost target).
docs/decisions/autosend-safety-policy.md:634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
docs/architecture/agent-bundle-renderer-design.md:43:| `agent.md` (line 552) | Output contract first; then workflow, gates, escalation. Master brief §1 Rule 1: "Every agent ships with its output contract written first, as a one-paragraph screenshot description." | the renderer (synthesises into `CLAUDE.md` per §2.1); humans for code review | **Static** — founder writes once; iterated per Codex ratification (master brief §10.5 names every new `agent.md` as always-ratify) |
docs/architecture/agent-bundle-renderer-design.md:44:| `config.schema.json` (line 553) | Per-tenant JSON Schema, extending `common-*.json` shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) | the renderer (materialises to `config.json` per §2.1); per-tenant onboarding wizard at Product Spec §5.2 Day 4 fills schema fields | **Static schema; dynamic materialisation** per tenant |
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:54:- **§1.1-A:** master brief §8.1 names `validate.sh` and `context.sh` at the bundle root but does not specify the **invocation mechanism** — i.e. how does the agent invoke them from within its Claude Code session? Claude Code's hooks convention is `.claude/hooks/*.sh`; cortextOS templates don't use that path (they use `.claude/skills/` for skill scripts but not `.claude/hooks/` for lifecycle hooks). Recommended resolution in §2.1: render the two scripts to `.claude/hooks/` so they integrate with Claude Code's hook discovery; CLAUDE.md preamble (synthesised from agent.md per §2.1) references them by name.
docs/architecture/agent-bundle-renderer-design.md:55:- **§1.1-B:** master brief §8.1 mentions `_shared/hook-helpers.sh` and `_shared/voice-loader.sh` but does not specify where `_shared/` lives in the rendered output. The bundle's `validate.sh` and `context.sh` `source` these helpers — the renderer needs to materialise the path. Recommended resolution: place `_shared/` at `${projectRoot}/orgs/<org>/agents/_shared/` (one per org, symlinked into every agent dir's `.claude/hooks/_shared/`); rendered hook scripts source via `${CTX_AGENT_DIR}/.claude/hooks/_shared/<helper>.sh`.
docs/architecture/agent-bundle-renderer-design.md:97:The two layouts share no files by name except `tools.yaml` (which the IFOS bundle uses for MCP servers and which Claude Code consumes at PTY spawn). cortextOS expects `config.json` (runtime config), `CLAUDE.md` (Claude Code's entry point), `.env` (Telegram credentials + secrets); IFOS provides `config.schema.json` (a *schema* for per-tenant config, not the materialised config itself), `agent.md` (the output contract + workflow, not a Claude Code entry point), and no `.env` (credentials live per-tenant). The bundle's `validate.sh` and `context.sh` have no cortextOS analogue — they implement IFOS-side Gate A and context-assembly per master brief §8.1 Changes 1+2, and need a defined invocation mechanism (Spec gap §1.1-A). The bundle's `tests/fixtures/` are CI-only and have no runtime counterpart in cortextOS. **Translation is required for three of the six bundle files** (`agent.md` → `CLAUDE.md` with cortextOS-required preamble synthesised in; `config.schema.json` → `config.json` materialised with per-tenant values from `/vault/{tenant}/_config.yaml`; `validate.sh` + `context.sh` → rendered into a hook location the agent can invoke). `README.md` and `tools.yaml` pass through. Fixtures stay in the source repo.
docs/architecture/agent-bundle-renderer-design.md:109:| `agents/recruitment/<name>/agent.md` | `orgs/<org>/agents/<name>/CLAUDE.md` | **Synthesis** | (1) `agent.md` body verbatim; (2) **cortextOS preamble template** — spec gap §2.1-A; (3) per-tenant footer (resolved tenant_slug, current `_voice/style-guide.md` path, decision_log Postgres role); (4) hook invocation block referencing `.claude/hooks/{validate,context}.sh` paths | Lint pass: no unresolved `{{tenant_slug}}` / `{{...}}` placeholders survive; preamble matches the renderer's canonical preamble version (hash check); CLAUDE.md is non-empty and parses as valid markdown |
docs/architecture/agent-bundle-renderer-design.md:110:| `agents/recruitment/<name>/config.schema.json` | `orgs/<org>/agents/<name>/config.json` | **Synthesis** | (1) `config.schema.json` (the JSON Schema itself, used for validation); (2) `/vault/{tenant-slug}/_config.yaml` per Ultraplan §5.1 line 220 (provides per-tenant values that fill schema fields); (3) bundle-level defaults from any `default` keys in the schema; (4) common-*.json shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) — spec gap §2.1-B on where common schemas live | Materialised JSON validates clean against the source schema using Ajv (or equivalent) before the renderer writes; required fields all populated; no extra fields beyond schema. Daemon-required fields (per §1.2): `enabled` defaults true, `runtime` defaults `claude-code`, `max_session_seconds` defaults 255600, `working_directory` defaults to the rendered agent dir |
docs/architecture/agent-bundle-renderer-design.md:116:| _(no IFOS source)_ | `orgs/<org>/agents/<name>/.env` | **Synthesis** | (1) `tools.yaml` MCP server list (declares which credentials are needed: `BULLHORN_OAUTH_TOKEN`, `MS_GRAPH_TOKEN`, etc.); (2) `/vault/{tenant-slug}/_secrets.env` — spec gap §2.1-C (Ultraplan §5.1 doesn't enumerate this file but it's the natural place for per-tenant credentials); (3) the agent's per-bot Telegram credentials from the same secrets file (`BOT_TOKEN`, `CHAT_ID`, `ALLOWED_USER`) per cortextOS Primitive 5 contract | All MCP server tokens declared in `tools.yaml` resolve to a non-empty value; `BOT_TOKEN` matches `/^\d+:[A-Za-z0-9_-]+$/` per `agent-manager.ts:218`; `ALLOWED_USER` is numeric per `agent-manager.ts:224`; file written `chmod 0600` (credentials) |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:121:**Spec gaps surfaced in §2.1:**
docs/architecture/agent-bundle-renderer-design.md:123:- **§2.1-A:** master brief §8.1 does not specify what the **cortextOS preamble template** looks like — the wrapper around `agent.md` that becomes `CLAUDE.md`. Recommended resolution: pin a canonical preamble at `packages/agent-renderer/templates/claude-md-preamble.md` (rendered with tenant + agent variables); preamble content must (a) tell Claude Code to source `.claude/hooks/context.sh` at session start, (b) tell Claude Code to call `.claude/hooks/validate.sh` before any tool invocation (Gate A), (c) list the env vars the agent should expect (`CTX_TENANT_SLUG`, `CTX_AGENT_NAME`, `CTX_ORCHESTRATOR_AGENT`, etc.), (d) reference `agent.md` body verbatim, (e) **not** reference IDENTITY.md / SOUL.md / MEMORY.md / GOALS.md / etc. because they will not exist. A draft preamble lives in §2.3 worked example below.
docs/architecture/agent-bundle-renderer-design.md:124:- **§2.1-B:** master brief §8.1 line 553 says `config.schema.json` extends "`common-*.json`" but doesn't say where the `common-*.json` shared schemas live. Recommended resolution: `packages/agents-runtime/_shared/common-{client, voice, notifications, vault, ats, accounting, target-patch}.json` per Ultraplan §5.3 line 357-364 enumeration. The renderer resolves `$ref` to these paths during schema materialisation.
docs/architecture/agent-bundle-renderer-design.md:125:- **§2.1-C:** Ultraplan §5.1 line 220 names `_voice/`, `_playbooks/`, `_decisions/`, `_config.yaml` under `/vault/{tenant}/` but does not enumerate `_secrets.env`. Recommended resolution: add `_secrets.env` to the per-tenant vault skeleton; created at tenant provisioning (Ultraplan §5.5 line 263 `provision-tenant.sh {slug}` step 2). Mode `0600` owned by `ifos-tenant-{slug}`. Per Master Brief §3.3 "structured data lives in Postgres" applies to entity data; per-tenant *secrets* are the canonical exception that lives on the filesystem.
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:149:`activity-channel`, `agent-browser`, `agent-management`, `auto-skill`, `autoresearch`, `bus-reference`, `comms`, `cron-management`, `env-management`, `event-logging`, `guardrails-reference`, `human-tasks`, `m2c1-worker`, `onboarding`, `soul-philosophy`, `system-diagnostics`, `tool-registration`, `worker-agents` — 18 above, plus the `memory-management` skill referenced from `agent/.claude/skills/onboarding/SKILL.md:42` that I haven't catalogued individually.
docs/architecture/agent-bundle-renderer-design.md:153:**Spec gap §2.2-A:** master brief §8.1 doesn't specify the opt-in syntax in `tools.yaml`. Recommended resolution: add a top-level `cortextos_skills:` block in `tools.yaml` with a list of skill names. Example:
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:351:**`CLAUDE.md` (~25 lines — draft cortextOS preamble per §2.1-A, then agent.md verbatim, then per-tenant footer):**
docs/architecture/agent-bundle-renderer-design.md:369:Decision-log calls are mandatory per master brief §8.1 Change 2:
docs/architecture/agent-bundle-renderer-design.md:397:The preamble is the §2.1-A spec-gap resolution draft — pin this verbatim (or revise) before Week 11.
docs/architecture/agent-bundle-renderer-design.md:539:- **Per-tenant secrets:** `/vault/<tenant>/_secrets.env` per spec gap §2.1-C resolution (added to `provision-tenant.sh` skeleton).
docs/architecture/agent-bundle-renderer-design.md:540:- **Schema refs:** `packages/agents-runtime/_shared/common-{client,voice,notifications,vault,ats,accounting,target-patch}.json` per spec gap §2.1-B and Ultraplan §5.3 line 357-364.
docs/architecture/agent-bundle-renderer-design.md:541:- **cortextOS preamble template:** `packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A.
docs/architecture/agent-bundle-renderer-design.md:567:- **Target directory:** `${frameworkRoot}/orgs/<org>/agents/<name>/`, contents per §2.1 file-by-file mapping.
docs/architecture/agent-bundle-renderer-design.md:597:- **Merge with conflict markers:** rejected for v1.0. Renderer doesn't have a three-way-merge semantic (source bundle, last-render, current rendered output). Building it adds substantial complexity for a workflow nobody asked for; the master brief §1 Rule 1 ("output before architecture") favours the simple overwrite model.
docs/architecture/agent-bundle-renderer-design.md:638:**Escalation:** `ESC_RENDERER_FAILED` row written to `decision_log` Postgres table with `agent_name='_renderer'`, `phase='gating_failed'`, `payload->>'reason'='schema-validation-failure'`. (`phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — see ADR-004 Decision 7; the 5-value enum is `trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 schema migration.) If `--notify-on-failure` (default true), Telegram message to the operator with the validation path.
docs/architecture/agent-bundle-renderer-design.md:702:New escalation code added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3:
docs/architecture/agent-bundle-renderer-design.md:708:- **Audit log:** Postgres `decision_log` row with `tenant_slug`, `agent_name='_renderer'`, `phase='gating_failed'` (failures) or `phase='action'` (successful renders), `payload->>'reason'` carries the reason code. RLS-isolated per tenant. Codex's Day-7 ratification report queries this table for all rows where `agent_name='_renderer' AND payload->>'reason' LIKE 'ESC_RENDERER_FAILED%'`. (Per ADR-004 Decision 7: `phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — use the 5-value enum from Day-4 §6.3 + Day-5 schema migration.)
docs/architecture/agent-bundle-renderer-design.md:761:| `packages/agents-runtime/_shared/common-{client,voice,notifications,vault,ats,accounting,target-patch}.json` (per spec gap §2.1-B) | Claude Code | Weeks 1-2 |
docs/architecture/agent-bundle-renderer-design.md:762:| `packages/agent-renderer/templates/claude-md-preamble.md` (per spec gap §2.1-A, draft in §2.3) | Claude Code | Week 1 (alongside renderer impl) |
docs/architecture/agent-bundle-renderer-design.md:763:| `_secrets.env` added to `provision-tenant.sh` skeleton (per spec gap §2.1-C) | Claude Code | Day 4 of Week 0 (alongside the Postgres provisioning) |
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/agent-bundle-renderer-design.md:800:**Edit C — Master brief §8.1 add renderer reference:**
docs/architecture/agent-bundle-renderer-design.md:804:**Proposed:** add a one-paragraph footnote at the end of §8 (before §8.1): "The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly. The renderer (`packages/agent-renderer/`, per ADR-003) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant)."
docs/architecture/agent-bundle-renderer-design.md:814:- **§1.1-A** (invocation mechanism for validate.sh / context.sh) — resolved in §2.1: render to `.claude/hooks/`; CLAUDE.md preamble (§2.3) references them.
docs/architecture/agent-bundle-renderer-design.md:816:- **§2.1-A** (cortextOS preamble template content) — resolved with draft preamble in §2.3 and pinned location in §3.3 (`packages/agent-renderer/templates/claude-md-preamble.md`).
docs/architecture/agent-bundle-renderer-design.md:817:- **§2.1-B** (where common-*.json shared schemas live) — resolved in §3.3.2: `packages/agents-runtime/_shared/common-*.json`.
docs/architecture/agent-bundle-renderer-design.md:820:**Master brief edits needed** (per §5.3 above):
docs/architecture/agent-bundle-renderer-design.md:829:- `packages/agents-runtime/_shared/common-*.json` (the schema $ref targets — seven files per Ultraplan §5.3 line 357-364).
docs/runbooks/day-4-provisioning.md:26:- **Rule 1 (Output before architecture):** the output of Day 4 is a working two-tenant RLS-isolated Postgres instance on an encrypted volume. The §9 verification checklist is the operational definition.
docs/runbooks/day-4-provisioning.md:40:**Master brief asserts (line 477 verbatim):** "Hetzner UK VPS provisioned, LUKS-encrypted volume mounted at `/vault/`". This is the single Hetzner reference in the master brief. §10 (Codex ratification loop) does not mention Hetzner or cost targets — earlier drafts of this runbook cited "master brief §10.4" for cost target and Hetzner location; both fabricated. Corrected in citation-audit pass 2026-05-18.
docs/runbooks/day-4-provisioning.md:70:- Master brief §8.1 Change 2: three values — `trigger`, `output`, `action`
docs/runbooks/day-4-provisioning.md:75:The runbook applies exactly these. **Do not invent additional phase values during execution** (e.g., `session_start`, `tool_call`, `escalation`) unless a Codex-ratified change to either master brief §8.1 or `sequencing-target.md` §5-A pre-dates the migration. Speculative additions break the schema-before-code rule.
docs/runbooks/day-4-provisioning.md:171:| Instance type | CX22 (2 vCPU, 4 GB RAM, 40 GB NVMe) | Fits v1.0 pilot scale per founder-set budget in this section §1.4; master brief does not specify a numeric cost target |
docs/runbooks/day-4-provisioning.md:178:Estimated monthly cost: ~€5/mo VPS + ~€2.40/mo (50 GB volume at €0.0476/GB/mo) ≈ €7.40/mo ≈ £6.40/mo. Well under the £20/mo founder-set budget for v1.0 pilot scale (this section §1.4; master brief does not specify a numeric cost target).
docs/runbooks/day-4-provisioning.md:186:### §2.1 — Create the project (if not already done in §1.1)
docs/runbooks/day-4-provisioning.md:592:### §5.3 — Configure Postgres
docs/runbooks/day-4-provisioning.md:806:Per `sequencing-target.md` §5-A + master brief §8.1 Change 2 + `current-priorities.md` line 16. **Exactly 5 values. No additions.**
docs/runbooks/day-4-provisioning.md:830:Per `current-priorities.md` line 15 + ADR-003 design §3.3 spec gap §2.1-C. Filesystem operations, not SQL.
docs/runbooks/day-4-provisioning.md:842:# Source: Day 4 runbook §6.5; consolidates Ultraplan §5.1 + ADR-003 §2.1-C
docs/runbooks/day-4-provisioning.md:871:# _secrets.env at mode 0600 — per ADR-003 §2.1-C
docs/runbooks/day-4-provisioning.md:1054:### §8.1 — Hetzner-level: enable automatic backups (already done in §2.3)
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1126:- [ ] §5.3 — `00-ifos.conf` applied; Postgres restart clean
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/runbooks/day-4-provisioning.md:1228:9. **§4 self-inflicted defensive check (Claude error):** Claude added `sudo file -s /dev/disk/by-id/...` defensive check not in runbook §4.1; `file` not installed on base image; `set -e` aborted before §4.2 install. Reverted to exact runbook commands. Lesson: stop adding defensive diagnostics beyond runbook spec when execution is in section-by-section gated mode.
docs/runbooks/day-4-provisioning.md:1242:15. **§5.3 `systemctl is-enabled` exit code (cosmetic):** `systemctl is-enabled postgresql` returns exit 1 when service is "disabled" (the desired state). `set -e` aborted on this; cosmetic — state is correct. v1.1 runbook revision: wrap `is-enabled` checks with `|| true` when desired state is "disabled".
docs/runbooks/day-4-provisioning.md:1276:7. §5.3 wrap `is-enabled` checks with `|| true` for desired-disabled states
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
agents/recruitment/diagnostic/cycle.sh:12:# Per ADR-003 + sequencing-target.md §2.1: Diagnostic is Tier 2 (request-
agents/recruitment/diagnostic/cycle.sh:19:#   - One Markdown file in /vault/<tenant_slug>/diagnostic-reports/<firm-slug>-<ISO-date>.md
agents/recruitment/diagnostic/cycle.sh:88:REPORT_DIR="${VAULT_ROOT}/${CTX_TENANT_SLUG}/diagnostic-reports"
agents/recruitment/diagnostic/cycle.sh:90:DRAFT_PATH="/tmp/diagnostic-draft-${FIRM_SLUG}-$$.md"
agents/recruitment/diagnostic/cycle.sh:102:  hh_decision_action "diagnostic_input_invalid" "firm:${FIRM_NAME}" \
agents/recruitment/diagnostic/cycle.sh:109:# Step 2-11 — Generate the 12 sections via @ifos/diagnostic-generator
agents/recruitment/diagnostic/cycle.sh:114:# CLI: packages/diagnostic-generator/dist/cli.js
agents/recruitment/diagnostic/cycle.sh:116:GENERATOR_CLI="${IFOS_REPO_ROOT:-${REPO_ROOT}}/packages/diagnostic-generator/dist/cli.js"
agents/recruitment/diagnostic/cycle.sh:119:  printf '  Run: cd packages/diagnostic-generator && pnpm build\n' >&2
agents/recruitment/diagnostic/cycle.sh:156:  hh_decision_action "diagnostic_generator_empty" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:166:hh_decision_output "diagnostic_draft" "${DRAFT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:182:hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
docs/decisions/v1.0-kill-criterion.md:8:**Path drift logged:** Master brief §6 Day 5 line 486 specifies `docs/v1-kill-criterion.md` (docs/ root). This artefact lives at `docs/decisions/v1.0-kill-criterion.md` per repo convention. Recorded as **Edit 10** in atomic-correction manifest (shared with autosend-safety-policy.md path drift).
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:134:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 pilot scale; master brief does not specify a numeric cost target); emerging from v1.0 pilot operations.
docs/decisions/v1.0-kill-criterion.md:148:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 single-tenant pilot; master brief does not specify a numeric cost target); Risk #4 in `docs/RISK-REGISTER.md` (Hire #1 delays compound infrastructure spend if architecture sprawls).
docs/decisions/v1.0-kill-criterion.md:156:**Recovery path:** Rescoped infrastructure plan; pivoted v1.0 continues with adjusted Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target; budget adjustment is a runbook revision, not a master-brief edit).
docs/decisions/v1.0-kill-criterion.md:204:**Day-5 restructure** (2026-05-18): Jack is high engagement on sales/commercial; founder is solo on product. This v1.0 kill criterion governs the **product domain**. Founder has SOLO authority for all trigger activations; Jack is informed-not-deciding. Commercial-domain kill criteria are deferred to a future artefact (placeholder: `v1.0-kill-criterion-commercial.md`).
docs/decisions/v1.0-kill-criterion.md:218:Commercial-side kill criteria — pilot pricing, customer acquisition strategy, sales pipeline kill thresholds — are out of scope for v1.0 product kill criterion. A future artefact (placeholder name: `v1.0-kill-criterion-commercial.md`) defines them with Jack as decision authority and founder informed. Scope boundary: anything that does not directly trigger product KILL/PAUSE/PIVOT belongs in the commercial document.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:124:**Risk if flaky:** Concierge loses cross-week candidate conversation context at the 71-hour boundary or at API overflow; rejection drafts lose the prior-state nuance that defines Gate A voice quality on the hardest test case (Ultraplan §8.1 A6 gotcha: "Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship"). Per Ultraplan §3.1 row 2, the documented contingency is: "Manual restart cadence acceptable for v1.0 pilots; flag as known limitation in pilot agreement."
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:96:| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:99:| 4. Commercial value | **Medium** | Internal sales tool per Product Spec §2.2 R13 ("Not on the customer pricing card"). Drives qualified discovery-call pipeline. Demoable to a prospect but not the closing demo. Ultraplan §8.1 line 499 Gate B target: "≥30% of diagnostics produced lead to a discovery call booked" |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:109:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 513 estimate **L (2 weeks)** — the Bullhorn MCP work is rate-limiting per Ultraplan §8.1 line 514 ("Bullhorn MCP server doesn't exist yet — this is the critical-path build"). One MCP server (Bullhorn) + Companies House for enrichment. Single primary output (cleanup report) but with continuous nightly cron pattern |
docs/decisions/sequencing-target.md:110:| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:122:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 526 estimate **M (1 week)**. Webhook-driven not always-on. Structured-field mapping is per-firm config not code per Ultraplan §8.1 line 526. Tacit-note extraction is the hard part per Ultraplan §8.1 line 527 ("Start with a small taxonomy (5-10 tacit-note types) and expand") |
docs/decisions/sequencing-target.md:123:| 2. Substrate exercise | **Medium-High** | Exercises Bullhorn W (smaller surface than Janitor's R+W). First agent with external webhook trigger (Fathom / Fireflies). First exercise of voice-loader for **tacit-note tone-detection** per Ultraplan §8.1 line 523. Reuses Janitor's Bullhorn auth refresh-loop |
docs/decisions/sequencing-target.md:124:| 3. Risk de-risking | **Medium** | Reuses Janitor's Bullhorn auth path (doesn't re-derisk Risk #2). Surfaces new failure mode: **webhook-arrival-to-Bullhorn-write SLA** (5-min target per Ultraplan §8.1 line 521). Doesn't directly touch Risk #5 (renderer already proven by Diagnostic) or Risk #1 (still Tier 2) |
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:127:| 6. Tenant-onboarding readiness | **Medium** | Needs Fathom or Fireflies OAuth + Bullhorn (already onboarded if Janitor shipped). Tacit-note taxonomy needs per-firm calibration in first 30 days of production per Ultraplan §8.1 line 527 |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:135:| 1. Implementation simplicity | **Medium-High** | Ultraplan §8.1 line 541 estimate **L (2 weeks)**. Three accounting integrations (Xero / QuickBooks / Sage — one per tenant per Ultraplan §8.1 line 537). Open Banking auth complexity (90-day token rotation per Ultraplan §8.1 line 542 gotcha). Tier 1 always-on (cortextOS Primitive 1 dependency) |
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:140:| 6. Tenant-onboarding readiness | **Medium** | Needs Xero/QuickBooks/Sage OAuth (one of, per tenant) + Open Banking auth (TrueLayer/Plaid UK per Ultraplan §8.1 line 539). Chase-cadence config per tenant. FD's mobile for Telegram approval per Ultraplan §8.1 line 540 |
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:150:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 554 estimate **L (2 weeks)** — multi-source aggregation logic is the work. Four data sources (Bullhorn read + LinkedIn via Proxycurl + Reed.co.uk + CV-Library). Bounded output (5-15 candidates per query per Ultraplan §8.1 line 552). Tier 2 request-response |
docs/decisions/sequencing-target.md:151:| 2. Substrate exercise | **Medium** | Reuses Bullhorn R from Janitor (no new Bullhorn substrate). New MCP integrations: LinkedIn via Proxycurl (rate-limited per Ultraplan §10 row #6), Reed, CV-Library. Source-abstraction layer per Ultraplan §8.1 line 555 designed to be reusable by Night Sourcer v1.1 |
docs/decisions/sequencing-target.md:154:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Night Sourcer (v1.1) reuses Sourcing Scout's multi-source layer per Ultraplan §8.1 line 555 ("Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it") | Medium criticality (v1.1 downstream) |
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:163:| 1. Implementation simplicity | **High complexity (Low simplicity)** | Ultraplan §8.1 line 568 estimate **XL (4 weeks)** — biggest v1.0 agent. Lifecycle state machine across 24+ months of candidate post-placement (week-1 / month-1 / month-3 / month-6 / month-12 / month-24 nurture per Product Spec §2.2 R7). Six-plus comms types (acknowledgement, prep, debrief, rejection, placement, multi-stage check-ins) |
docs/decisions/sequencing-target.md:165:| 3. Risk de-risking | **High (secondary)** | Second Tier-1 always-on agent (after Cash Conductor at W7-8) — provides Risk #1 secondary exercise. Exercises Bullhorn webhook coverage gaps per Ultraplan §8.1 line 569 verbatim ("Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks") |
docs/decisions/sequencing-target.md:166:| 4. Commercial value | **Highest** | Per master brief §8.2 line 606: "First Tier-1 always-on closing demo; 4-week build." Product Spec §2.2 R7: 15-25% lift in placement-driven referral revenue ("post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table"). The flagship v1.0 closing demo |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:176:Three orderings evaluated against §1.3 criteria. **Option Alpha is the master-brief §8.2 canonical sequence** (correcting the §1.5 founder-prompt drift); Options Beta and Gamma are tested as alternatives.
docs/decisions/sequencing-target.md:178:### 3.1 — Option Alpha (canonical, master-brief §8.2)
docs/decisions/sequencing-target.md:198:- Bullhorn webhook coverage gaps surface only at Concierge W10-13 (Ultraplan §8.1 line 569 caveat).
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:374:4. **If scope-cut activates twice in one v1.0 cycle, escalate to v1.0 kill criterion** — the Day 5 work (master brief §6 Day 5) defines the kill-criterion threshold; sequencing failures count toward that threshold.
docs/decisions/sequencing-target.md:389:- `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` per master brief §8.1 Changes 1+2.
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:399:- Smallest viable Diagnostic exercising renderer + `_shared/` + `decision_log` end-to-end per §2.1 substrate-exercise column.
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:401:- Output: 12-page audit per Ultraplan §8.1 line 489-496 against a real prospect's public footprint.
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:424:The `decision_log` schema must support `phase='gating_failed'` and `phase='agent_handoff'` per §5.3 Spec gap §5-A. Day 4 Postgres provisioning script needs the extended `CHECK` constraint:
docs/decisions/sequencing-target.md:432:Lands at Day 4 alongside the `entity_graph` → `entities` + `entity_links` split (ADR-002 Edit 3) and the `_secrets.env` skeleton addition (ADR-003 design §3.3 Spec gap §2.1-C). Three Day-4-tightenings consolidate into one provisioning task.
docs/decisions/sequencing-target.md:436:The Day 5 v1.0 kill criterion document must reference this sequencing for what "v1.0 fails" means. Concrete failure conditions implied by §4.3 + §5.3:
docs/decisions/sequencing-target.md:440:- **Scope-cut contingency activates twice in one v1.0 cycle** (per §5.3 step 4; signals structural product-market-fit problem)
docs/decisions/sequencing-target.md:442:Day 5 kill-criterion artefact bakes these into its threshold definition.
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:493:| Gating-failure escalation | §5.3 | 1-week-fix-window → scope-cut contingency → kill-criterion threshold |
docs/decisions/sequencing-target.md:509:| `decision_log.phase` enum extended to include `gating_failed` + `agent_handoff` per §5.3 / §6.5 | Claude Code | Day 4 Postgres provisioning | **NEW from this document** Spec gap §5-A |
docs/decisions/sequencing-target.md:517:| §5.3 1-week investigation window before scope-cut activation | Actual incident-triage time may be shorter or longer; adjust per first surfaced gating failure |
docs/build-brief/00-MASTER-BRIEF.md:340:    ├── (extends cortextos dashboard/ via additional routes — see §5.3)
docs/build-brief/00-MASTER-BRIEF.md:478:- [ ] `docs/decisions/v1.0-kill-criterion.md` — the explicit condition under which v1.0 stops shipping (e.g., "If after 3 pilots the average Gate B revenue uplift is <£20k/year per tenant, the wedge is dead and we pivot")
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:568:**Change 2 — Decision logging is enforced.** Three required calls per agent run:
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:21:**Sub-decision B — OAuth flow.** Master brief §6 Day 2 line 466 pre-states a recommendation: "browser dance for production, service-account for dev." This is the authorization-code grant (per-tenant browser dance, refresh-token cycle) for production tenants, plus client-credentials grant (service account) for IFOS-internal sandbox/dev work. Sub-decision B verifies that recommendation against Bullhorn's actual OAuth implementation and pins the per-tenant token storage path (per `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution: `/vault/<tenant>/_secrets.env`, mode `0600`).
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
docs/decisions/bullhorn-integration-path.md:37:| A5 Sourcing Scout | **Yes — read** (ATS passive-match lookup) | Ultraplan §8.1 A5 line 547-551 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:54:- Per-tenant credential storage location (resolved by `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C: `/vault/<tenant>/_secrets.env`).
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:104:| Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (`sequencing-target.md` §2.1) | Awaits Q1 LOI |
docs/decisions/bullhorn-integration-path.md:149:- **Per-tenant model.** Each tenant has its own `corpToken` and its own per-tenant `restUrl` returned by /login. Operations are scoped by the corpToken; IFOS must hold per-tenant token state. This maps cleanly to the per-tenant credential model already pinned in `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution (`/vault/<tenant>/_secrets.env`, mode `0600`).
docs/decisions/bullhorn-integration-path.md:230:- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
docs/decisions/bullhorn-integration-path.md:262:3. **The renderer's `_secrets.env` materialisation per Spec gap §2.1-C handles the credential storage cleanly.** No new persistence layer needed; the path was already specified in `agent-bundle-renderer-design.md` §3.3.2.
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:289:| **A1 Diagnostic** (no Bullhorn) | n/a | n/a | n/a | n/a | n/a | n/a — runs against public footprint per Ultraplan §8.1 line 489 |
docs/decisions/bullhorn-integration-path.md:290:| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:294:**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.
docs/decisions/bullhorn-integration-path.md:310:| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
docs/decisions/bullhorn-integration-path.md:317:Restated from `agent-bundle-renderer-design.md` §2.1 + §3.3.2 spec gap §2.1-C resolution + §3.1 of this document:
docs/decisions/bullhorn-integration-path.md:340:**Reserve 30% headroom** for error/retry overhead per §2.2 (429 + wait-1s retry pattern). Effective budget for first-attempt productive calls: ~280-700 req/hour/tenant.
docs/decisions/bullhorn-integration-path.md:353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
docs/decisions/bullhorn-integration-path.md:411:- **`ESC_BULLHORN_AUTH` escalation code wired** into `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3 line 587 — code already named in master brief; wiring lands with `_shared/hook-helpers.sh` Week-1 prereq.
docs/decisions/bullhorn-integration-path.md:486:| Rate-limit budget allocation | §4.4 | Conservative v1.0 defaults (400-1000 req/hour/tenant total; 30% reserve); revise when Bullhorn confirms actuals |
docs/decisions/bullhorn-integration-path.md:503:| Vault `_secrets.env` skeleton in `provision-tenant.sh` (per ADR-003 Spec gap §2.1-C) | Claude Code | Day 4 Week 0 (already scheduled) |
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |
docs/runbooks/operational-hygiene-protocol.md:37:### §2.1 — Path A (default for credential entry)
docs/runbooks/operational-hygiene-protocol.md:125:**Rule:** When executing a runbook, run exactly the commands in the runbook. Do not add defensive checks, verification probes, or "while we're here" diagnostics beyond what the runbook specifies.
docs/runbooks/operational-hygiene-protocol.md:150:- Day 5 autosend policy: estimated 300-500 lines; actual 648. **+30% to +116% overshoot.**
docs/runbooks/operational-hygiene-protocol.md:222:### §5.3 — Numerical claims discipline
docs/runbooks/operational-hygiene-protocol.md:260:Audit of citation accuracy across 4 main committed artefacts: Day-4 runbook, autosend-safety-policy.md, v1.0-kill-criterion.md, vertical-schema.yaml. Plus state files: RISK-REGISTER.md, current-priorities.md.
docs/runbooks/operational-hygiene-protocol.md:264:**Scope:** 15 references to "master brief §10.4" across 5 files, claiming §10.4 contains either (a) a Hetzner UK / FSN1 location reference or (b) a £20/mo cost target.
docs/runbooks/operational-hygiene-protocol.md:268:**Root cause:** Day-4 runbook §1.4 invented "master brief §10.4 cost target" during drafting. The citation propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1 instance), RISK-REGISTER (2 instances), current-priorities (1 instance) by trusting the Day-4 runbook citation rather than re-verifying against master brief. Citation transitivity, not master-brief drift.
docs/runbooks/operational-hygiene-protocol.md:274:| `docs/runbooks/day-4-provisioning.md` | 8 | "+§10.4" dropped from Edit 9 scope (was about Hetzner UK); "§10.4 cost target" replaced with "Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target)" |
docs/runbooks/operational-hygiene-protocol.md:276:| `docs/decisions/v1.0-kill-criterion.md` | 3 | Same cost-target replacement for Trigger 6/7 source citations |
docs/runbooks/operational-hygiene-protocol.md:292:**Fix:** no artefact change. Lesson captured in §5.3 numerical-claims discipline.
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
docs/runbooks/operational-hygiene-protocol.md:299:- `ADR-003 Decision 3` referencing "design §2.1" — ✅ verified Decision 3 exists; references `agent-bundle-renderer-design.md §2.1` correctly
docs/decisions/2026-05-18-day-7-single-sentence-test.md:36:- **Kill criterion linkage:** Trigger 1 in `docs/decisions/v1.0-kill-criterion.md` §2 (DESIGN-PARTNER-BY-WEEK-2) fires end-of-day **2026-06-03** if no signed LOI by then. That is the binding tripwire — currently **14 calendar days** out from today (2026-05-20).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:46:- Two-instance PATH conflict for bus commands → **Updated 2026-05-16 evening:** folds into the renderer's CLAUDE.md preamble responsibility (ADR-003 design §2.1-A). The preamble draft in design §2.3 sets `CTX_AGENT_DIR` explicitly; rendered hook scripts source `_shared/` helpers via `${CTX_AGENT_DIR}/.claude/hooks/_shared/` rather than relying on `PATH` resolution. Quirk 3 is no longer a Week-1 risk — it's a renderer test case.
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
agents/recruitment/diagnostic/README.md:9:| `agent.md` | Output-contract-first agent specification per master brief §1 Rule 1 | Proposed (Day-11 draft) |
agents/recruitment/diagnostic/README.md:29:Master brief §1 Rule 1 demands "Output before architecture." The agent.md output contract can be authored without any customer present — it's a self-contained description of what the agent produces. Pre-writing the output contract:
agents/recruitment/diagnostic/README.md:34:4. **Demonstrates Rule 1 discipline** — output contract IS the first artefact, not the last
agents/recruitment/diagnostic/README.md:38:Per `.codex/ratification/review-agent-bundle.md` (skill not yet built; lazy per execution-plan §3): this directory ratifies as a unit when the full 6-file + 3-fixture bundle exists.
docs/operations/bullhorn-outreach-emails.md:17:**These don't block today.** They block **Janitor W5 build** (per kill-criterion §2 Trigger 3). You have ~5 weeks of runway. But send today/Monday because Bullhorn's response time is 2-5 business days, and we want the answers before Diagnostic W3-4 completes so Janitor W5 starts unblocked.
docs/operations/bullhorn-outreach-emails.md:74:- If they require marketplace membership before production access → Sub-decision A is **Marketplace**; need cost + timeline to assess against kill-criterion §2 Trigger 3 (Janitor W5 deadline).
agents/recruitment/diagnostic/agent.md:6:**Build wave:** v1.0 W3-4 per master brief §8.2 row 1 (anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`.
agents/recruitment/diagnostic/agent.md:7:**Build complexity:** M (1 week) per Ultraplan §8.1 A1.
agents/recruitment/diagnostic/agent.md:8:**Tier:** 2 (request-driven; no persistent PTY) per sequencing-target.md §2.1.
agents/recruitment/diagnostic/agent.md:14:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/diagnostic/agent.md:16:> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least one evidence link (Companies House URL, LinkedIn URL, or careers-page URL) backing every factual claim — Gate A hard-fails on missing citations. The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
agents/recruitment/diagnostic/agent.md:26:ifosctl diagnostic \
agents/recruitment/diagnostic/agent.md:33:Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY) → exits within 10-15 min per Ultraplan §8.1 A1 turnaround target.
agents/recruitment/diagnostic/agent.md:39:- Bulk-mode (`ifosctl diagnostic --firm-list firms.csv`) — out of v1.0 scope
agents/recruitment/diagnostic/agent.md:43:## §3 — The 12 required sections
agents/recruitment/diagnostic/agent.md:73:Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/diagnostic/agent.md:76:0. Session start — invocation arrives via CLI ifosctl diagnostic
agents/recruitment/diagnostic/agent.md:137:    → write to /vault/{tenant_slug}/diagnostic-reports/{firm-slug}-{ISO-date}.md
agents/recruitment/diagnostic/agent.md:138:    → hh_decision_output("diagnostic_report", "<path>", "12-section report on {firm}")
agents/recruitment/diagnostic/agent.md:145:    → hh_decision_action("diagnostic_report_render", "firm:{slug}", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:156:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces:
agents/recruitment/diagnostic/agent.md:160:- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3)
agents/recruitment/diagnostic/agent.md:167:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by tagging the report's outcome in `decision_log.payload.gate_b_outcome` when the consultant updates status (via Telegram or Brain UI v1.1).
agents/recruitment/diagnostic/agent.md:169:Gate B doesn't block the agent — it's the v1.0 kill criterion §2 Trigger 5 metric. Below 30% sustained for 4 weeks → revisit Diagnostic's output quality.
agents/recruitment/diagnostic/agent.md:187:- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
agents/recruitment/diagnostic/agent.md:188:- `ESC_AUTOSEND_*` — Diagnostic's only action is `diagnostic_report_render` (green tier per autosend-policy.yaml)
agents/recruitment/diagnostic/agent.md:197:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:202:- **`hh_load_recent_edits` last 30 days for `concierge` + `diagnostic`**: surfaces patterns of how consultant edits agent drafts. If drift is detected (edit-distance > 200 chars on >50% of recent_edit rows), `ESC_VOICE_DRIFT_TENANT` fires (per `escalation-codes.md` §2.5).
agents/recruitment/diagnostic/agent.md:204:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/diagnostic/agent.md:217:| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
agents/recruitment/diagnostic/agent.md:242:| Q1 | Is "12 sections" the right number? Ultraplan §8.1 A1 says "12 required sections" but doesn't enumerate. This document proposes a 12-section list (§3); founder may want to revise. | Founder reviews §3 table; can split/merge sections. Lands as Edit in next commit. |
agents/recruitment/diagnostic/agent.md:245:| Q4 | Gate B (30% discovery-call-to-report ratio) measured how? Manual tagging by consultant OR auto-detection via Bullhorn calendar links? | v1.0 manual tagging via Telegram resolution; v1.1 auto-detection. |
agents/recruitment/diagnostic/agent.md:249:### Gotchas (carried forward from Ultraplan §8.1 A1)
agents/recruitment/diagnostic/agent.md:259:Per `.codex/ratification/review-agent-bundle.md` (skill not yet built; lazy per execution-plan §3): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.
agents/recruitment/diagnostic/agent.md:264:- First production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
agents/recruitment/diagnostic/agent.md:265:- Gate B baseline measurement begins (30% target; 4-week window)
docs/operations/codex-ratification-guide.md:200:2. Citation §10.4 incorrect — master brief §10.4 is the Codex exclusion list, not the cost target the ADR cites. Past pattern of 15 fabricated §10.4 references; verify line numbers before citing. Citation: ADR-001 line 47.
agents/recruitment/diagnostic/context.sh:10:# the first workflow step runs. Per master brief §8.1 Change 1: load voice
agents/recruitment/diagnostic/context.sh:19:#       CTX_AGENT_NAME=diagnostic
agents/recruitment/diagnostic/context.sh:35:CTX_AGENT_NAME="diagnostic"
agents/recruitment/diagnostic/context.sh:83:hh_decision_trigger "session_start" "diagnostic agent for firm: ${IFOS_DIAGNOSTIC_FIRM_NAME:-<unset>}" \
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:144:# 4 — Load tone rules (filtered to diagnostic agent)
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:173:printf '[diagnostic context.sh] tenant=%s corpus_id=%s tone_rules=%s recent_edits=%s target_patch=loaded\n' \
docs/_supplementary/technical-strategy-v2.md:406:- **They can resell.** See §5.3 below.
docs/specs/ULTRAPLAN.md:30:**Rule 1 — Output before architecture.** Every agent ships with its output contract written first. The architecture is downstream. If you can't write the output contract as a screenshot description in one paragraph, the agent isn't ready to start.
docs/specs/ULTRAPLAN.md:146:**Change 1 — Voice handling moves into a shared module.**
docs/specs/ULTRAPLAN.md:166:**Change 2 — Decision logging is enforced, not optional.**
docs/specs/ULTRAPLAN.md:417:| Inbound Triage | 95% of inbounds get response within 60s; consultant-edit rate <30% on auto-sent categories | Decision-log query over 30 days, per tenant |
docs/specs/ULTRAPLAN.md:419:| Client Hunter | ≥ 20 BD opportunities/month produced with ≥ 30% receiving consultant action | Decision-log query; action defined as "approved-and-sent" |
docs/specs/ULTRAPLAN.md:496:- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
docs/specs/ULTRAPLAN.md:497:- **Gate B target:** ≥30% of diagnostics produced lead to a discovery call booked
docs/specs/ULTRAPLAN.md:583:- **Gate B target:** 95% within 60s; consultant edit-rate <30% on auto-sent categories; <2% wrong-classification rate
docs/specs/ULTRAPLAN.md:603:Already specified in §8.1 A4 as v1.0. The v1.1 work is the reframe of pitch and any latency optimisations needed once we have 3+ tenants in production. Not a new build, ~3 days of polish.
docs/specs/ULTRAPLAN.md:753:- Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint
docs/specs/ULTRAPLAN.md:807:- Tenant isolation (Rule 1, §5)
docs/specs/ULTRAPLAN.md:865:- [ ] v1.0 kill criterion documented (Q12). **Owner:** Maddox. **Output:** `v1-kill-criterion.md`.
agents/recruitment/concierge/agent.md:6:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:14:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/concierge/agent.md:110:15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/concierge/agent.md:229:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 verbatim:
agents/recruitment/concierge/agent.md:301:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
docs/architecture/second-brain-design.md:52:**IFOS agents do not run cortextOS's heartbeat-memory pattern.** The IFOS Agent Bundle v2 (master brief §8.1) specifies six files per agent:
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:102:soul-philosophy  system-diagnostics  tasks  tool-registration
docs/architecture/second-brain-design.md:110:**But IFOS Agent Bundle v2 is a different shape.** Master brief §8.1 specifies six files plus three fixture directories:
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:450:- **Path:** `/vault/{tenant-slug}/` on the shared encrypted LUKS volume (Ultraplan §5.1 line 218). Sub-paths per §2.1 above.
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:701:- If the file lock times out (5 seconds), the operation fails with `ESC_VAULT_LOCK_TIMEOUT` per master brief §8.1 Change 3 vocabulary (new code; goes in `_shared/escalation-codes.md` v0.1).
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:907:2. **Master brief §8 (Agent Bundle v2 pattern + `tools.yaml` contract).** §8.1 specifies the bundle has `tools.yaml` for "MCP servers + scopes + degraded modes" — i.e. external MCP connectors (Bullhorn, Companies House, Xero). The wiki is **internal** to IFOS, not an external execution backend. Treating wiki ops as bus commands (Option α) keeps `tools.yaml` clean of internal-surface declarations; treating them as MCP tools (Option β) conflates internal-data-access with external-tool-invocation in the same `tools.yaml`.
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
docs/architecture/second-brain-design.md:967:| **2.1-A** | Master brief §5.1 lines 297-349 vs Ultraplan §5.1 line 220 disagree on vault layout | Two vault structures specified in different docs | Adopt the merged tree in §2.1 of this design: `/vault/{slug}/` top-level (`_voice/ _playbooks/ _decisions/ _config.yaml wiki/ temp/`) with the master brief's `wiki/{raw,compiled,.wiki}/` subtree underneath. Codex ratifies on Day 7 by reading §2.1. | No |
docs/runbooks/tenant-lifecycle.md:112:for agent in diagnostic; do
docs/runbooks/tenant-lifecycle.md:363:  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
agents/recruitment/diagnostic/tools.yaml:7:# Reading order: agent.md §3 (12 required sections) + §4 (10-step workflow) +
agents/recruitment/diagnostic/tools.yaml:14:agent: diagnostic
agents/recruitment/diagnostic/tools.yaml:15:tier: 2  # request-driven; no persistent PTY (per sequencing-target.md §2.1)
agents/recruitment/diagnostic/tools.yaml:170:  - bullhorn       # Diagnostic is sales-tool tier; no ATS touch per sequencing-target.md §2.1
docs/specs/PRODUCT-SPEC.md:95:- **Revenue story:** "We do a full evening of sourcing on every brief in your pipeline, every night. You walk in to a day of outreach already drafted instead of a day of sourcing." Modelled: time-to-shortlist drops from 5 days to 2 days; 30% more briefs run concurrently per consultant.
docs/specs/PRODUCT-SPEC.md:244:| **Growth** (11–25 fee earners) | £3,250 | All Boutique + Night Sourcer, Brief Decoder, Spec Pitcher, Real-Time Pulse, Competitor Interception, Recruitment Reporting | "5–10 net-new retainers/year from BD + Competitor Interception. 30%+ more briefs per consultant via Night Sourcer. 1–2 saved client relationships/year worth £30k–£100k each." |
agents/recruitment/diagnostic/validate.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
docs/_supplementary/build-plan-original.md:228:Total context per invocation: 10–25k tokens typical. With prompt caching on the Tier 1 + Tier 2 stuff that's shared across invocations, effective cost is ~10% of input rate. This is how the £80–180/mo per tenant cost target holds.
docs/_supplementary/build-plan-original.md:303:- **Escalate** — if source APIs return <30% of expected volume for 3 consecutive runs, flag ICP as possibly too narrow
docs/_supplementary/build-plan-original.md:1517:- Week 2: Agent template library structure (§1.1–1.4), context injection (§3), validation hooks (§2.1)
docs/specs/_archive-build-handoff.md:255:Also Day 3: confirm Brain UI v1.0 scope is "the minimal what-did-the-agents-do-today view" — not a full dashboard rebuild. Per Business Plan §5.3 this view extends CortexOS's existing Next.js dashboard rather than replaces it.
docs/specs/_archive-build-handoff.md:278:`docs/v1-kill-criterion.md` (Q12):
docs/_supplementary/planning-phase-brief.md:40:| **CC11** | **Agent Library Repo CI/CD** — pipelines that test, version, release agent bundles across all tenants | GitHub Actions / your agent bundles as inputs | §2.1 + all of Phase 2 bundles |
docs/_supplementary/execution-plan.md:494:  - *Prompt:* "Write the IntelForce AI OS Support Playbook: the 20 most likely client support tickets (agent produced bad output, integration disconnected, can't log in, need user added, billing question, want to pause agent, want to rename agent, want new capability, approval queue stuck, question about a log entry, invoice dispute, want to downgrade, want to upgrade, data export request, GDPR DSAR, cancellation request, 'it's not working' vague, hallucination complaint, proposal draft was wrong, voice is drifting). Per ticket: diagnostic questions, resolution steps, escalation path, expected resolution time, template response."
docs/_supplementary/execution-plan.md:503:  - *Prompt:* "Write the Monitoring & Alert Playbook: every alert the observability stack fires, with for each: the condition that triggers it, the likely root causes, the diagnostic commands, the resolution steps, the escalation rules. Organise by severity tier."
docs/operations/codex-round-2-handoff.md:82:| 11 | `docs/decisions/v1.0-kill-criterion.md` | Trigger 1 date + Trigger 2 CLI + Trigger 4 threshold | RATIFY (all three fixed) |
docs/operations/codex-round-2-handoff.md:216:  docs/decisions/v1.0-kill-criterion.md
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:8:**Builds on:** `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 Diagnostic v0 — completed at commit `97a57a2`).
docs/operations/goal-week-3-polish-and-scaffold.md:19:4. **`docs/specs/ULTRAPLAN.md`** §8.1 in full (per-agent A1-A6 specs, lines 495-572) + §9 (Bullhorn critical path, lines 720-770) + §10 (risk rows + contingencies)
docs/operations/goal-week-3-polish-and-scaffold.md:20:5. **`docs/specs/PRODUCT-SPEC.md`** §0-§4 (what we are building) + §5.3 (`_shared/` common schemas)
docs/operations/goal-week-3-polish-and-scaffold.md:22:7. **`docs/decisions/v1.0-kill-criterion.md`** §2 Triggers 1-10 (deadline awareness) + §3 (authority structure)
docs/operations/goal-week-3-polish-and-scaffold.md:26:11. **`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`** (today's sequencing change)
docs/operations/goal-week-3-polish-and-scaffold.md:27:12. **`agents/recruitment/diagnostic/agent.md`** in full (the gold-standard agent.md to model from)
docs/operations/goal-week-3-polish-and-scaffold.md:31:16. **`docs/operations/goal-option-c-diagnostic-end-to-end.md`** (Day-13 Diagnostic build; reference for Week-3 polish steps)
docs/operations/goal-week-3-polish-and-scaffold.md:33:After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Six v1.0 agents: [list with weeks]. ULTRAPLAN §8.1 agent line ranges: [A1 lines 495-505, A2 lines 507-514, ...]. Week-3 scope confirmed. Ready to begin Step 1."**
docs/operations/goal-week-3-polish-and-scaffold.md:43:1. **Companies House data flows end-to-end.** Founder has registered the API key (Step 2). Re-running cycle.sh against Hays plc produces §1 + §10 + §11 with REAL CH data (not "no registration found"). Updated artefact at `docs/artefacts/diagnostic-hays-plc-2026-05-2X.md`.
docs/operations/goal-week-3-polish-and-scaffold.md:50:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:51:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:52:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:53:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:57:- §1 Output contract (one-paragraph screenshot per master brief §1 Rule 1)
docs/operations/goal-week-3-polish-and-scaffold.md:93:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:111:| Building any new Codex ratification skill (e.g., `review-agent-bundle.md`) | Defer per execution-plan §3 lazy; agent.md ratification uses existing `review-architecture-decision.md` skill |
docs/operations/goal-week-3-polish-and-scaffold.md:150:(cd packages/diagnostic-generator && pnpm build)
docs/operations/goal-week-3-polish-and-scaffold.md:154:(cd packages/diagnostic-generator && pnpm test) | tail -3
docs/operations/goal-week-3-polish-and-scaffold.md:189:Edit `packages/diagnostic-generator/src/sections/online-footprint.ts`:
docs/operations/goal-week-3-polish-and-scaffold.md:196:pnpm test --filter @ifos/diagnostic-generator
docs/operations/goal-week-3-polish-and-scaffold.md:197:pnpm typecheck --filter @ifos/diagnostic-generator
docs/operations/goal-week-3-polish-and-scaffold.md:200:Commit: `fix(diagnostic): LinkedIn slug suffix-strip — Hays plc → linkedin.com/company/hays`
docs/operations/goal-week-3-polish-and-scaffold.md:204:Edit `packages/diagnostic-generator/src/sections/conversation-opener.ts`:
docs/operations/goal-week-3-polish-and-scaffold.md:208:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
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
docs/operations/goal-week-3-polish-and-scaffold.md:291:- ULTRAPLAN §8.1 A2 lines 507-514 (full Janitor spec)
docs/operations/goal-week-3-polish-and-scaffold.md:292:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:294:- `v1.0-kill-criterion.md` Trigger 3 (JANITOR-BULLHORN-AUTH-W5)
docs/operations/goal-week-3-polish-and-scaffold.md:301:- **Build wave:** W5 per master brief §8.2 line 596
docs/operations/goal-week-3-polish-and-scaffold.md:302:- **Tier:** Tier 1 (batch nightly cron; not request-driven) per `sequencing-target.md` §2.1
docs/operations/goal-week-3-polish-and-scaffold.md:320:- §1 reads as a complete one-paragraph screenshot per master brief §1 Rule 1
docs/operations/goal-week-3-polish-and-scaffold.md:322:Commit: `decision(pre-build): agents/recruitment/janitor/agent.md — output contract per ULTRAPLAN §8.1 A2`
docs/operations/goal-week-3-polish-and-scaffold.md:329:- ULTRAPLAN §8.1 A3 lines 518-527 (Scribe spec)
docs/operations/goal-week-3-polish-and-scaffold.md:330:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:336:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:337:- **Tier:** Tier 2 (request-driven, per-call invocation) per `sequencing-target.md` §2.1
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:350:Commit: `decision(pre-build): agents/recruitment/scribe/agent.md — output contract per ULTRAPLAN §8.1 A3`
docs/operations/goal-week-3-polish-and-scaffold.md:357:- ULTRAPLAN §8.1 A4 lines 533-545 (Cash Conductor spec — note Hire #1 anchor at line 766)
docs/operations/goal-week-3-polish-and-scaffold.md:358:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:359:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:365:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:379:Commit: `decision(pre-build): agents/recruitment/cash-conductor/agent.md — output contract per ULTRAPLAN §8.1 A4`
docs/operations/goal-week-3-polish-and-scaffold.md:386:- ULTRAPLAN §8.1 A5 lines 547-558 (Sourcing Scout spec)
docs/operations/goal-week-3-polish-and-scaffold.md:387:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:393:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:407:Commit: `decision(pre-build): agents/recruitment/sourcing-scout/agent.md — output contract per ULTRAPLAN §8.1 A5`
docs/operations/goal-week-3-polish-and-scaffold.md:412:- ULTRAPLAN §8.1 A6 lines 561-570 (Concierge spec)
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:420:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:423:- **§3 Output shape:** message drafts (email / Bullhorn note customer-visible / SMS as configured); decision-log audit row per send; orange-tier spot-check sampling at 1-in-N rate per autosend-safety-policy §4.
docs/operations/goal-week-3-polish-and-scaffold.md:434:Commit: `decision(pre-build): agents/recruitment/concierge/agent.md — output contract per ULTRAPLAN §8.1 A6`
docs/operations/goal-week-3-polish-and-scaffold.md:547:- packages/diagnostic-generator/ (as a whole package)
docs/operations/goal-week-3-polish-and-scaffold.md:555:bash scripts/run-codex-ratification.sh --round 4 --subset diagnostic
docs/operations/goal-week-3-polish-and-scaffold.md:580:- `review-agent-bundle.md` — NOT YET BUILT (per execution-plan §3 lazy); defer; use review-architecture-decision.md for each agent.md individually
docs/operations/goal-week-3-polish-and-scaffold.md:588:1. **Every claim cites a master plan section.** No bare assertions. Every paragraph either cites the master brief / ULTRAPLAN / sequencing-target / kill-criterion / specific ADR, OR is explicitly stated as "scaffold inference; founder review required."
docs/operations/goal-week-3-polish-and-scaffold.md:589:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:624:  <SHA>  fix(diagnostic): LinkedIn slug suffix-strip
docs/operations/goal-week-3-polish-and-scaffold.md:625:  <SHA>  feat(diagnostic): §12 LLM-driven conversation opener
docs/operations/goal-week-3-polish-and-scaffold.md:626:  <SHA>  milestone(diagnostic): Hays plc full-data re-run
docs/operations/goal-week-3-polish-and-scaffold.md:628:  <SHA>  decision(codex-round-4-diagnostic): N RATIFIED / M REJECTED
docs/operations/goal-week-3-polish-and-scaffold.md:639:  ✓ ULTRAPLAN §8.1 — all 6 agents have output contracts authored
docs/operations/goal-week-3-polish-and-scaffold.md:640:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:643:  ✓ v1.0-kill-criterion.md Trigger 2 — Diagnostic ratified ahead of
docs/operations/goal-week-3-polish-and-scaffold.md:683:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:18:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A1 (the 10-step workflow for Diagnostic, lines 495-526).
docs/operations/goal-option-c-diagnostic-end-to-end.md:19:5. **`agents/recruitment/diagnostic/agent.md`** — the existing output contract. Read in full.
docs/operations/goal-option-c-diagnostic-end-to-end.md:20:6. **`agents/recruitment/diagnostic/tools.yaml`** — MCP tool declarations the executor must implement.
docs/operations/goal-option-c-diagnostic-end-to-end.md:32:1. **One Markdown file exists at `/vault/migration-test/diagnostic-reports/<firm-slug>-2026-05-24.md`** containing a 12-section Diagnostic report for a real UK recruitment firm chosen by the founder.
docs/operations/goal-option-c-diagnostic-end-to-end.md:49:6. **A decision-log audit trail** for the smoke run: 3+ rows in `decision_log` (trigger + output + action), all under `agent_name='diagnostic'`, with `tenant_slug='migration-test'`.
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:195:Replace the stub `_section_1()` through `_section_11()` functions in `agents/recruitment/diagnostic/cycle.sh` with real connector calls:
docs/operations/goal-option-c-diagnostic-end-to-end.md:210:Acceptance: `bash agents/recruitment/diagnostic/cycle.sh --firm "Test Firm Name" --tenant migration-test` produces a draft at /tmp/... and Gate A passes (V3 warning only).
docs/operations/goal-option-c-diagnostic-end-to-end.md:212:Commit: `feat(diagnostic): wire web-scraper + companies-house into cycle.sh §1+§2+§6`
docs/operations/goal-option-c-diagnostic-end-to-end.md:227:ifosctl diagnostic --firm "<firm name>" --tenant migration-test
docs/operations/goal-option-c-diagnostic-end-to-end.md:232:export CTX_AGENT_DIR=$(pwd)/agents/recruitment/diagnostic
docs/operations/goal-option-c-diagnostic-end-to-end.md:235:bash agents/recruitment/diagnostic/cycle.sh --firm "<firm name>"
docs/operations/goal-option-c-diagnostic-end-to-end.md:238:Verify the report at `/vault/migration-test/diagnostic-reports/<slug>-2026-05-24.md`:
docs/operations/goal-option-c-diagnostic-end-to-end.md:244:Commit: `milestone(diagnostic): first end-to-end run — <firm name> report at <path>`
docs/operations/goal-option-c-diagnostic-end-to-end.md:248:Write `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` documenting:
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-option-c-diagnostic-end-to-end.md:381:Report path:       [/vault/migration-test/diagnostic-reports/<slug>-<date>.md]
docs/operations/goal-option-c-diagnostic-end-to-end.md:392:  5. [SHA] feat(diagnostic): wire web-scraper + companies-house into cycle.sh
docs/operations/goal-option-c-diagnostic-end-to-end.md:393:  6. [SHA] milestone(diagnostic): first end-to-end run
docs/operations/goal-option-c-diagnostic-end-to-end.md:398:Master plan alignment: ULTRAPLAN §8.1 Week-4 milestone hit on Day-13
docs/operations/codex-ratification-execution-plan.md:140:| 13 | v1.0-kill-criterion | `docs/decisions/v1.0-kill-criterion.md` | A |
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
docs/operations/codex-ratification-execution-plan.md:348:Per Day-7 manifest §4 + §6 of this plan: Codex ratification execution was deferred pending Week 0 close. Week 0 closes when single-sentence-test Q1 = YES (design partner LOI signed). **Current state:** Q1 = NO; Week 0 EXTENDING; kill-criterion Trigger 1 fires 2026-06-03.
docs/operations/seedlegals-engagement-queries.md:11:Per kill-criterion §3.4: external advisor is Week 1-2 must-fill. Per Risk #3: design partner LOI is 11 days from today (2026-06-03 trigger).
docs/operations/seedlegals-engagement-queries.md:128:| **D2** — External advisor identification | SeedLegals templates + delivered LOI + DPA become the "external advisor input" per kill-criterion §3.4. Founder retains right to escalate to a specialist firm for higher-stakes contracts. |
docs/operations/seedlegals-engagement-queries.md:166:- D2 + D3 stay open in current-priorities.md (D2 explicitly flagged as kill-criterion §3.4 Week 1-2 must-fill)
docs/operations/codex-round-2-remediation-prompt.md:205:      `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/operations/codex-round-2-remediation-prompt.md:218:  | Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (sequencing-target §2.1) | Awaits Q1 LOI |
docs/operations/codex-round-2-remediation-prompt.md:257:           diagnostic_email_send               → external-comms
docs/operations/codex-round-2-remediation-prompt.md:258:           diagnostic_calendar_invite          → external-comms

codex
The first pass already shows this is an agent artefact being reviewed with the architecture-decision skill, so I’m focusing on top-level load-bearing checks: schema support, gate semantics, shared helper reuse, and citation accuracy. A few cited mechanisms look likely to be mismatched, so I’m opening the exact files/lines now.
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
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
    16	> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least one evidence link (Companies House URL, LinkedIn URL, or careers-page URL) backing every factual claim — Gate A hard-fails on missing citations. The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
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
    84	   → ESC_SCHEMA_VIOLATION if firm name malformed
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
   167	Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by tagging the report's outcome in `decision_log.payload.gate_b_outcome` when the consultant updates status (via Telegram or Brain UI v1.1).
   168	
   169	Gate B doesn't block the agent — it's the v1.0 kill criterion §2 Trigger 5 metric. Below 30% sustained for 4 weeks → revisit Diagnostic's output quality.
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
   182	| `ESC_SCHEMA_VIOLATION` | Section count != 12 OR malformed input | warn | operator_chat_id |
   183	| `ESC_RENDERER_FAILED` | (not Diagnostic's concern; renderer escalation only) | — | — |
   184	
   185	Diagnostic does NOT use:
   186	
   187	- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
   188	- `ESC_AUTOSEND_*` — Diagnostic's only action is `diagnostic_report_render` (green tier per autosend-policy.yaml)
   189	- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention
   190	
   191	---
   192	
   193	## §7 — Voice + tone constraints
   194	
   195	Section 12 (conversation opener) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   196	
   197	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
   198	  - No "I hope this finds you well" or other generic openers
   199	  - No salary or commission anchors in cold outreach
   200	  - Specific evidence anchor required (not generic "great company")
   201	- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: top-5 chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker). Feeds LLM prompt as voice exemplars.
   202	- **`hh_load_recent_edits` last 30 days for `concierge` + `diagnostic`**: surfaces patterns of how consultant edits agent drafts. If drift is detected (edit-distance > 200 chars on >50% of recent_edit rows), `ESC_VOICE_DRIFT_TENANT` fires (per `escalation-codes.md` §2.5).
   203	
   204	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   205	
   206	---
   207	
   208	## §8 — Build dependencies (W3 prerequisites)
   209	
   210	Diagnostic build cannot start until ALL of the following are confirmed:
   211	
   212	| Dependency | Source | Status |
   213	|---|---|---|
   214	| Renderer + `_shared/` substrate | Day-8 + Round-3 commits | ✅ Ratified (Round 3) |
   215	| Live VPS migration applied | `bash scripts/run-live-migration.sh` | ⏸ Founder action |
   216	| Tenancy audit passes 12 invariants | `bash scripts/run-tenancy-audit.sh` | ⏸ Founder action |
   217	| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
   218	| `target_patch.json` for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI (per tenant-lifecycle.md §2) |
   219	| Voice corpus seeded for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI |
   220	| Companies House MCP connector | Build at W3 start (~1 day) | ⏸ Not built |
   221	| LinkedIn read-only MCP connector (or Proxycurl wrapper) | Build at W3 start (~2 days) | ⏸ Not built |
   222	| Web scraper utility (HEAD + first-N-lines) | Build at W3 start (~0.5 day) | ⏸ Not built |
   223	| `validate.sh` Gate A logic (12-section check) | Build at W3 start (~0.5 day) | ⏸ Not built |
   224	| `context.sh` hydration | Build at W3 start (~0.5 day) | ⏸ Not built |
   225	| 3 fixtures with golden outputs (01-primary + 02-edge-case-no-online-footprint + 99-voice-drift-canary) | Build at W3 start (~1 day) | ⏸ Not built |
   226	| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⏸ Skill not built yet (lazy per execution plan §3) |
   227	
   228	**Until ALL ratified items have ⏸ → ✅, W3 build slice does not start.**
   229	
   230	---
   231	
   232	## §9 — Status + open questions
   233	
   234	**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + W3 build slice start.
   235	
   236	**Recommended ratification path:** Author the agent.md draft (this document) Day 11 — frees W3 build to focus on the other 5 bundle files + 3 fixtures, not iterating on output contract under W3 deadline pressure. Founder reviews this draft when convenient; refinements drop in commits between Day 11 and W3 start.
   237	
   238	### Open questions for founder review
   239	
   240	| # | Question | Resolution path |
   241	|---|---|---|
   242	| Q1 | Is "12 sections" the right number? Ultraplan §8.1 A1 says "12 required sections" but doesn't enumerate. This document proposes a 12-section list (§3); founder may want to revise. | Founder reviews §3 table; can split/merge sections. Lands as Edit in next commit. |
   243	| Q2 | Should §11 (decision-maker map) be a separate section OR rolled into §3 + §4 + §5 + §7 as a sub-row? Currently named as a separate section. | Founder review at agent.md ratification. |
   244	| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | Resolved at W3 start before Companies House + LinkedIn MCP connectors authored. Founder + Claude decide together. |
   245	| Q4 | Gate B (30% discovery-call-to-report ratio) measured how? Manual tagging by consultant OR auto-detection via Bullhorn calendar links? | v1.0 manual tagging via Telegram resolution; v1.1 auto-detection. |
   246	| Q5 | What's the "firm-slug" canonical form for the output filename? Companies House registration number? URL-slugified firm name? | Recommend Companies House number for stability; canonical-slug fallback for non-UK firms (v1.1+). |
   247	| Q6 | Should §10 (recent activity) include Glassdoor reviews? ToS implications. | Per gotcha §6 below: caution; default OFF for v1.0; explicit founder enable for v1.1+. |
   248	
   249	### Gotchas (carried forward from Ultraplan §8.1 A1)
   250	
   251	1. **LinkedIn ToS — cannot store profile data beyond the audit.** Profile fetches are cached only for the duration of the report generation (typ. 10-15 min). After report writes to vault, raw profile data is dropped from agent memory + no persistence in Postgres.
   252	2. **Companies House rate limits — cache aggressively.** Free tier is 600 requests per 5-minute window per IP. Cache responses for 7 days per (company_number) key. Pre-emptive 60s backoff on first 429.
   253	3. **Glassdoor scraping — uncertain ToS compatibility.** Default OFF for v1.0. Per Q6 above.
   254	
   255	---
   256	
   257	## §10 — When this document ratifies
   258	
   259	Per `.codex/ratification/review-agent-bundle.md` (skill not yet built; lazy per execution-plan §3): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.
   260	

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
    28	## §2 — Catalogue (24 codes)
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
   177	### 2.6 — Cross-cutting infrastructure (6 codes)
   178	Source: derived from operational discipline + sequencing-target §5
   179	
   180	#### `ESC_HUMAN_EDITING_LOCK`
   181	- **Severity:** info
   182	- **Trigger:** Manual editing lock held by founder; agent backs off and reschedules
   183	- **Phase:** `gating_failed`
   184	- **Routing:** log-only (no Telegram noise)
   185	- **Payload fields:** `vault_path`, `lock_age_seconds`
   186	
   187	#### `ESC_VAULT_CONCURRENCY`
   188	- **Severity:** warn
   189	- **Trigger:** Generic vault concurrency anomaly not covered by ESC_VAULT_LOCK_TIMEOUT / ESC_VAULT_VERSION_MISMATCH / ESC_VAULT_HUMAN_EDIT_BLOCKED / ESC_VAULT_CASCADE_*
   190	- **Phase:** `gating_failed`
   191	- **Routing:** `operator_chat_id`
   192	- **Payload fields:** `vault_path`, `anomaly_class`, `freeform_reason`
   193	- **Note:** Catch-all; specific codes preferred. New patterns may justify a new code.
   194	
   195	#### `ESC_VAULT_RENAME_RACE`
   196	- **Severity:** warn
   197	- **Trigger:** Rename operation raced with another writer; per vault-concurrency §5
   198	- **Phase:** `gating_failed`
   199	- **Routing:** `operator_chat_id`
   200	- **Payload fields:** `from_path`, `to_path`, `racing_writer_pid`
   201	
   202	#### `ESC_CORTEXTOS_RESTART_REQUESTED`
   203	- **Severity:** info
   204	- **Trigger:** Agent self-requested restart per primitive 6 (`cortextos-ifos bus self-restart`) — typically post-degraded-mode recovery, post-context-overflow handoff
   205	- **Phase:** `agent_handoff`
   206	- **Routing:** log-only
   207	- **Payload fields:** `reason`, `next_session_token`
   208	
   209	#### `ESC_CORTEXTOS_HANDOFF`
   210	- **Severity:** info
   211	- **Trigger:** Context approaching `ctx_handoff_threshold` (default 80%); agent saves state and triggers fresh-session takeover per primitive 1+2 context-rotation
   212	- **Phase:** `agent_handoff`
   213	- **Routing:** log-only
   214	- **Payload fields:** `from_session_id`, `context_pct`, `handoff_summary_path`
   215	
   216	#### `ESC_CORTEXTOS_DEGRADED`
   217	- **Severity:** warn
   218	- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
   219	- **Phase:** `gating_failed`
   220	- **Routing:** `operator_chat_id`
   221	- **Payload fields:** `reason` (e.g. `bullhorn_auth_failed`, `mcp_connector_unreachable`), `degraded_since`, `recovery_condition`
   222	
   223	---
   224	
   225	## §3 — Reserved codes (not-yet-wired)
   226	
   227	These names are reserved by design documents but no agent fires them in v1.0. Listed here to prevent collision; do not invent codes overlapping these names.
   228	
   229	| Code | Reserved by | Earliest agent |
   230	|---|---|---|
   231	| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
   232	| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
   233	
   234	---
   235	
   236	## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
   237	
   238	`_shared/hook-helpers.sh` must:
   239	
   240	1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
   241	2. Validate `<ESC_CODE>` is a name from §2 above; unknown codes raise `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` (meta-escalation)
   242	3. Resolve `phase` from this catalogue's `Phase:` line (table-driven, not freeform)
   243	4. Default `agent_name` to `${CTX_AGENT_NAME}` or `_renderer` (renderer-only sentinel)
   244	
   245	The catalogue is read at process start via `_shared/escalation-codes-table.sh` (machine-readable companion; deferred to Phase 3 or first use, whichever lands first). If absent, helpers fall back to permissive write (log row only; no Telegram) + emit a one-shot operational warning.
   246	
   247	---
   248	
   249	## §5 — Change protocol
   250	
   251	New codes added here BEFORE wiring into helpers + before any agent references them. Code names case-sensitive (`ESC_[A-Z][A-Z0-9_]*`).
   252	
   253	The Codex Day-7 ratification queue includes this catalogue (item #20 placeholder per `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1). Updates after ratification = new commit + Codex re-review of the diff.
   254	
   255	*End of catalogue (24 active codes + 2 reserved).*

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '150,360p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   150	    "$(_hh_json_escape "${tenant}")" \
   151	    "$(_hh_json_escape "${agent}")" \
   152	    "$(_hh_json_escape "${phase}")" \
   153	    "$([ -z "${outcome}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${outcome}")")" \
   154	    "$([ -z "${reason}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${reason}")")" \
   155	    "${payload_json}" \
   156	    "${created_at}" \
   157	    "${_HH_HELPERS_VERSION}")
   158	
   159	  printf '%s\n' "${row}" >> "${fallback}"
   160	}
   161	
   162	# ────────────────────────────────────────────────────────────────────────
   163	# 3 hh_decision_* contracts (master brief §8.1 Change 2)
   164	# ────────────────────────────────────────────────────────────────────────
   165	
   166	# hh_decision_trigger <trigger_type> [<reason>]
   167	# Writes phase='trigger' row at session start. Required first call of every run.
   168	hh_decision_trigger() {
   169	  local trigger_type="${1:-session_start}"
   170	  local reason="${2:-}"
   171	  local payload
   172	  payload=$(printf '{"trigger_type":"%s","helpers_version":"%s"}' \
   173	    "$(_hh_json_escape "${trigger_type}")" "${_HH_HELPERS_VERSION}")
   174	  _hh_emit_row "trigger" "" "${reason}" "${payload}"
   175	}
   176	
   177	# hh_decision_output <output_type> <artefact_ref> [<reason>]
   178	# Writes phase='output' row per artefact produced. Required before producing
   179	# a customer-visible artefact (Gate B per master brief §1 Rule 4).
   180	hh_decision_output() {
   181	  local output_type="$1"
   182	  local artefact_ref="$2"
   183	  local reason="${3:-}"
   184	  local payload
   185	  payload=$(printf '{"output_type":"%s","artefact_ref":"%s"}' \
   186	    "$(_hh_json_escape "${output_type}")" "$(_hh_json_escape "${artefact_ref}")")
   187	  _hh_emit_row "output" "produced" "${reason}" "${payload}"
   188	}
   189	
   190	# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
   191	# Writes phase='action' or phase='gating_failed' row depending on tier.
   192	# Returns 0 if action allowed; 1 if blocked or approval rejected.
   193	hh_decision_action() {
   194	  local action_type="$1"
   195	  local target="$2"
   196	  local payload_hash="$3"
   197	  local payload_preview="$4"
   198	
   199	  local tenant tier
   200	  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   201	
   202	  if ! tier=$(autosend_policy_lookup "${action_type}"); then
   203	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   204	      "${target}" "${payload_hash}" "${payload_preview}" "policy_lookup_failed"
   205	    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   206	      "${target}" "${payload_hash}" "unknown_action_type"
   207	    return 1
   208	  fi
   209	
   210	  if ! tier=$(autosend_apply_tenant_override "${tier}" "${action_type}" "${tenant}"); then
   211	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   212	      "${target}" "${payload_hash}" "${payload_preview}" "override_resolution_failed"
   213	    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   214	      "${target}" "${payload_hash}" "override_resolution_failed"
   215	    return 1
   216	  fi
   217	
   218	  case "${tier}" in
   219	    green)
   220	      autosend_emit_decision_log "action" "green" "${action_type}" \
   221	        "${target}" "${payload_hash}" "${payload_preview}" ""
   222	      return 0
   223	      ;;
   224	    yellow)
   225	      autosend_emit_decision_log "action" "yellow" "${action_type}" \
   226	        "${target}" "${payload_hash}" "${payload_preview}" ""
   227	      if autosend_should_sample "${action_type}" "${tenant}"; then
   228	        autosend_spot_check_enqueue "${action_type}" "${target}" \
   229	          "${payload_hash}" "${payload_preview}" "${tenant}"
   230	      fi
   231	      return 0
   232	      ;;
   233	    orange)
   234	      autosend_emit_decision_log "action" "orange" "${action_type}" \
   235	        "${target}" "${payload_hash}" "${payload_preview}" "approval_pending"
   236	      autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
   237	        "${target}" "${payload_hash}" "${payload_preview}"
   238	      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
   239	      return $?
   240	      ;;
   241	    red)
   242	      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
   243	        "${target}" "${payload_hash}" "${payload_preview}" "red_tier_classification"
   244	      autosend_escalate "ESC_AUTOSEND_BLOCKED" "${action_type}" \
   245	        "${target}" "${payload_hash}" "red_tier_classification"
   246	      return 1
   247	      ;;
   248	    *)
   249	      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   250	        "${target}" "${payload_hash}" "${payload_preview}" "unknown_tier:${tier}"
   251	      autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   252	        "${target}" "${payload_hash}" "unknown_tier:${tier}"
   253	      return 1
   254	      ;;
   255	  esac
   256	}
   257	
   258	# ────────────────────────────────────────────────────────────────────────
   259	# 7 autosend_* helpers (autosend-safety-policy §4)
   260	# ────────────────────────────────────────────────────────────────────────
   261	
   262	# autosend_policy_lookup <action_type>
   263	# Prints the tier (green|yellow|orange|red) to stdout; returns 0 if found,
   264	# 1 if action_type missing from policy file.
   265	autosend_policy_lookup() {
   266	  local action_type="$1"
   267	  if [[ ! -f "${_HH_POLICY_FILE}" ]]; then
   268	    printf 'autosend_policy_lookup: policy file not found at %s\n' "${_HH_POLICY_FILE}" >&2
   269	    return 1
   270	  fi
   271	  # YAML lookup via awk — finds the action_type key, then reads tier:
   272	  # one line below. Safer than yq/python deps at agent runtime.
   273	  local tier
   274	  tier=$(awk -v key="${action_type}" '
   275	    $0 ~ "^  " key ":" { in_block = 1; next }
   276	    in_block && /^    tier: / { sub(/^    tier: /, ""); print; exit }
   277	    in_block && /^  [a-z]/ { in_block = 0 }
   278	  ' "${_HH_POLICY_FILE}")
   279	  if [[ -z "${tier}" ]]; then
   280	    return 1
   281	  fi
   282	  printf '%s' "${tier}"
   283	}
   284	
   285	# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
   286	# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
   287	# tenant override file at /vault/<tenant>/_config/autosend-overrides.yaml.
   288	# Tenants can ELEVATE only (green→yellow→orange→red); red is the floor.
   289	autosend_apply_tenant_override() {
   290	  local base_tier="$1"
   291	  local action_type="$2"
   292	  local tenant_slug="$3"
   293	
   294	  # Red is absolute — no override possible.
   295	  if [[ "${base_tier}" == "red" ]]; then
   296	    printf '%s' "red"
   297	    return 0
   298	  fi
   299	
   300	  local override_file="${IFOS_VAULT_ROOT:-/vault}/${tenant_slug}/_config/autosend-overrides.yaml"
   301	  if [[ ! -f "${override_file}" ]]; then
   302	    printf '%s' "${base_tier}"
   303	    return 0
   304	  fi
   305	
   306	  local override
   307	  override=$(awk -v key="${action_type}" '
   308	    $0 ~ "^  " key ":" { sub(/^  [^:]+: */, ""); print; exit }
   309	  ' "${override_file}")
   310	
   311	  if [[ -z "${override}" ]]; then
   312	    printf '%s' "${base_tier}"
   313	    return 0
   314	  fi
   315	
   316	  # Enforce elevation-only ordering.
   317	  local base_rank override_rank
   318	  case "${base_tier}" in green) base_rank=0;; yellow) base_rank=1;; orange) base_rank=2;; red) base_rank=3;; *) return 1;; esac
   319	  case "${override}" in green) override_rank=0;; yellow) override_rank=1;; orange) override_rank=2;; red) override_rank=3;; *) return 1;; esac
   320	
   321	  if (( override_rank < base_rank )); then
   322	    printf 'autosend_apply_tenant_override: refusing to demote %s → %s for %s/%s\n' \
   323	      "${base_tier}" "${override}" "${tenant_slug}" "${action_type}" >&2
   324	    return 1
   325	  fi
   326	  printf '%s' "${override}"
   327	}
   328	
   329	# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
   330	# Emits the standard autosend decision_log row with payload.tier set.
   331	autosend_emit_decision_log() {
   332	  local phase="$1"
   333	  local tier="$2"
   334	  local action_type="$3"
   335	  local target="$4"
   336	  local payload_hash="$5"
   337	  local payload_preview="$6"
   338	  local reason_or_status="${7:-}"
   339	
   340	  local payload
   341	  payload=$(printf '{"tier":"%s","action_type":"%s","target":"%s","payload_hash":"%s","payload_preview":"%s","approval_status":%s,"block_reason":%s,"policy_version_sha":"%s"}' \
   342	    "$(_hh_json_escape "${tier}")" \
   343	    "$(_hh_json_escape "${action_type}")" \
   344	    "$(_hh_json_escape "${target}")" \
   345	    "$(_hh_json_escape "${payload_hash}")" \
   346	    "$(_hh_json_escape "${payload_preview}")" \
   347	    "$([ -z "${reason_or_status}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${reason_or_status}")")" \
   348	    "$([ "${tier}" = "red" ] || [ "${tier}" = "fail-safe-red" ] && printf '"%s"' "$(_hh_json_escape "${reason_or_status}")" || echo "null")" \
   349	    "${HH_POLICY_VERSION_SHA:-unknown}")
   350	  _hh_emit_row "${phase}" "${tier}" "${reason_or_status}" "${payload}"
   351	}
   352	
   353	# autosend_escalate <ESC_CODE> [<key=value>...]
   354	# Writes the ESC row + dispatches Telegram via primitive-5 helper. Catalogue
   355	# lookup is permissive — unknown codes are emitted with phase='gating_failed'
   356	# + ESC_AUTOSEND_POLICY_LOOKUP_FAILED meta-escalation.
   357	autosend_escalate() {
   358	  local code="$1"
   359	  shift
   360	

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,280p'" in /Users/madsadmin/code/CortexOS
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
    65	  # ───────────────────────────────────────────────────────────
    66	  # YELLOW — auto-send with 1-in-N spot-check (5 action_types)
    67	  # ───────────────────────────────────────────────────────────
    68	
    69	  bullhorn_candidate_dedupe:
    70	    tier: yellow
    71	    agent: janitor
    72	    sample_rate: 10
    73	    reason: "Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review"
    74	    irreversible: false
    75	
    76	  bullhorn_note_append_summary:
    77	    tier: yellow
    78	    agent: scribe
    79	    sample_rate: 20
    80	    reason: "Appends to candidate record; consultant-only visibility; high-volume; format quality needs review"
    81	    irreversible: false
    82	
    83	  linkedin_connection_request:
    84	    tier: yellow
    85	    agent: sourcing-scout
    86	    sample_rate: 5
    87	    reason: "Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy"
    88	    irreversible: true
    89	
    90	  xero_reminder_draft_internal:
    91	    tier: yellow
    92	    agent: cash-conductor
    93	    sample_rate: 10
    94	    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
    95	    irreversible: false
    96	
    97	  bullhorn_note_draft_internal:
    98	    tier: yellow
    99	    agent: concierge
   100	    sample_rate: 10
   101	    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
   102	    irreversible: false
   103	
   104	  # ───────────────────────────────────────────────────────────
   105	  # ORANGE — per-action human approval (10 action_types)
   106	  # ───────────────────────────────────────────────────────────
   107	
   108	  bullhorn_note_customer_visible:
   109	    tier: orange
   110	    agent: concierge
   111	    timeout: PT4H
   112	    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"
   113	    irreversible: true
   114	    canonical: true
   115	
   116	  gmail_outlook_send_to_candidate:
   117	    tier: orange
   118	    agent: concierge
   119	    timeout: PT4H
   120	    reason: "Outbound email to candidate; customer-facing; reputation effects"
   121	    irreversible: true
   122	
   123	  twilio_sms_send:
   124	    tier: orange
   125	    agent: concierge
   126	    timeout: PT30M
   127	    reason: "Outbound SMS; high-trust channel; cost-per-send; irreversible"
   128	    irreversible: true
   129	
   130	  calendar_invite_send:
   131	    tier: orange
   132	    agent: concierge
   133	    timeout: PT4H
   134	    reason: "Creates calendar event with attendee notification; visible to attendee"
   135	    irreversible: true
   136	
   137	  email_summary_to_customer:
   138	    tier: orange
   139	    agent: scribe
   140	    timeout: PT4H
   141	    reason: "Outbound email summarising call to customer; customer-facing; format-sensitive"
   142	    irreversible: true
   143	
   144	  xero_reminder_send_customer:
   145	    tier: orange
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
   157	
   158	  diagnostic_calendar_invite:
   159	    tier: orange
   160	    agent: diagnostic
   161	    timeout: PT4H
   162	    reason: "Books intro call with prospect; reputation + scheduling friction"
   163	    irreversible: true
   164	
   165	  linkedin_inmail_send:
   166	    tier: orange
   167	    agent: sourcing-scout
   168	    timeout: PT4H
   169	    reason: "Outbound InMail (paid credit); cost-per-send; customer-facing"
   170	    irreversible: true
   171	
   172	  bullhorn_placement_terminate:
   173	    tier: orange
   174	    agent: janitor
   175	    timeout: PT4H
   176	    reason: "Marks placement as terminated; commercial/legal implications; reversible only via support ticket"
   177	    irreversible: false
   178	
   179	  # ───────────────────────────────────────────────────────────
   180	  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
   181	  # ───────────────────────────────────────────────────────────
   182	
   183	  xero_payment_initiate:
   184	    tier: red
   185	    agent: all
   186	    block_reason: payment_action
   187	    reason: "Payment transfer; financial-bearing; never auto-send in v1.0"
   188	    irreversible: true
   189	
   190	  stripe_charge_initiate:
   191	    tier: red
   192	    agent: all
   193	    block_reason: payment_action
   194	    reason: "Charges a card; financial-bearing"
   195	    irreversible: true
   196	
   197	  subscription_modify:
   198	    tier: red
   199	    agent: all
   200	    block_reason: billing_modification
   201	    reason: "Changes tenant's IFOS subscription; structurally distinct from agent work"
   202	    irreversible: false
   203	
   204	  legal_document_generate:
   205	    tier: red
   206	    agent: all
   207	    block_reason: legal_artefact
   208	    reason: "Offer letters, employment contracts; legal-binding"
   209	    irreversible: true
   210	
   211	  pii_export_outside_tenant_geography:
   212	    tier: red
   213	    agent: all
   214	    block_reason: pii_geographic_breach
   215	    reason: "PII transmitted outside tenant's declared data residency (GDPR boundary breach)"
   216	    irreversible: true
   217	
   218	  cross_tenant_data_send:
   219	    tier: red
   220	    agent: all
   221	    block_reason: cross_tenant_violation
   222	    reason: "Sending tenant-A data to tenant-B recipient; RLS-enforced + red-listed for defence-in-depth"
   223	    irreversible: true
   224	
   225	  unauthorised_adapter_send:
   226	    tier: red
   227	    agent: all
   228	    block_reason: unauthorized_adapter
   229	    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
   230	    irreversible: true
   231	
   232	  send_to_blocked_recipient:
   233	    tier: red
   234	    agent: all
   235	    block_reason: blocked_recipient
   236	    reason: "Recipient in tenant's blocked_recipients override list"
   237	    irreversible: true
   238	
   239	# ───────────────────────────────────────────────────────────
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
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/agent.md | sed -n '260,340p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '320,390p;480,520p;740,770p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	
   261	Status flips to Accepted when:
   262	- Codex Round-3+ ratifies the full bundle
   263	- Founder approves §3's 12-section list as canonical
   264	- First production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
   265	- Gate B baseline measurement begins (30% target; 4-week window)
   266	
   267	Until then: this document is a forward-looking scaffold. Conservative pre-build clarity — not a binding contract until ratification.
   268	
   269	*End of Diagnostic agent.md draft.*

 succeeded in 0ms:
   320	
   321	**Layer 2 — Runtime voice application (prompt assembly).**
   322	
   323	Every agent's `context.sh` calls `_shared/voice-loader.sh`, which:
   324	
   325	1. Loads `tone-rules.yaml` and injects it as structured constraints in the system prompt:
   326	   ```
   327	   You are writing in the voice of {firm name}. Hard rules:
   328	   - Never use these phrases: {banned list}
   329	   - Opening: {pattern}
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
   381	
   382	### 6.3 The sales-floor demo of voice quality
   383	
   384	This is the commercial corollary. On the sales call, the salesperson can:
   385	
   386	1. Take a sample email from the prospect (paste 5 of their own emails into a demo wizard).
   387	2. Run the demo Triage agent on a synthetic inbound.
   388	3. Show the voice classifier score live on the screen: "0.84. Here's the draft."
   389	
   390	Generic ChatGPT scores 0.4–0.5 on the same test. That delta is the close.
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
   511	- **Gate B target:** day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement
   512	- **Build complexity:** **L** (2 weeks) — the Bullhorn MCP work is the rate-limiting piece
   513	- **Gotchas:** Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0. Estimate 1 week for the MCP server, 1 week for the agent itself. Dedup is hard; start conservative (high-confidence merges only) and tune up.
   514	
   515	#### A3. The Scribe — the data spine
   516	
   517	- **Build wave:** v1.0 (week 6–7)
   518	- **Always-on?** Tier 2 — webhook-driven
   519	- **Trigger type:** Webhook from Fathom / Fireflies / Ringover when a call ends
   520	- **CortexOS primitives required:** None per call (stateless between calls)
   740	- Bullhorn integration path decided and documented
   741	- Hetzner UK VPS provisioned with Postgres + LUKS volume
   742	
   743	### Weeks 1–2 — Foundation
   744	
   745	- Week 1: Agent Bundle v2 pattern refactor; `_shared/` module build; voice loader; escalation codes catalogue; vertical schema v0.1
   746	- Week 2: Tenancy plumbing (Postgres RLS, tenant provisioning scripts, PM2 ecosystem generator); backup setup; first dry-run tenant provisioned end-to-end
   747	
   748	Milestone: a tenant can be provisioned in <30 minutes by a script.
   749	
   750	### Weeks 3–4 — Bullhorn + Diagnostic
   751	
   752	- Week 3: Bullhorn MCP server build (auth, read endpoints, write endpoints, webhook subscription)
   753	- Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint
   754	
   755	Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact.
   756	
   757	### Weeks 5–6 — Janitor + Scribe
   758	
   759	- Week 5: Janitor agent; day-30 before/after report template; CI fixtures
   760	- Week 6: Scribe agent; Fathom + Fireflies MCP; tacit-note taxonomy v0.1
   761	
   762	Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.
   763	
   764	### Weeks 7–8 — Cash Conductor + Hire #1 onboards
   765	
   766	- Week 7: Hire #1 onboards (assumed); Xero MCP + Open Banking integration
   767	- Week 8: Cash Conductor agent; chase-cadence config; tenant-level baseline DSO captured
   768	
   769	Milestone: Cash Conductor running in shadow mode against first pilot's accounting data.
   770	

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '1,70p;560,620p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Intel Force OS v2 — Master Brief for Claude Code
     2	
     3	**Drop location:** `~/code/CortexOS/CLAUDE.md` (the working repo) and `~/code/CortexOS/docs/build-brief/00-MASTER-BRIEF.md`.
     4	
     5	**Synthesis stance:** First principles. The build pack in `docs/build-pack/` is **ignored** per founder instruction. The CLAUDE.md currently in the repo describes paths, remotes, and red lines — those are kept. Everything else in this brief is rebuilt from the verified state of the two upstream repos (`grandamenium/cortextos`, `tarsclaw/intel-force-os-v2`), Karpathy's LLM-wiki pattern, and the recruitment product spec, ultraplan, and 24/7 directive.
     6	
     7	**Verified on:** 16 May 2026 against `cortextos@0.1.1` and the `intel-force-os-v2` repo HEAD.
     8	
     9	**Reading order in Claude Code:**
    10	1. This document — read in full at session start
    11	2. `docs/specs/PRODUCT-SPEC.md` — what gets built (the 18-agent suite)
    12	3. `docs/specs/ULTRAPLAN.md` — how, in what order
    13	4. The §-references below to other primary docs
    14	
    15	If anything in `docs/build-pack/` conflicts with this brief, **this brief wins**. The build pack stays in-tree as historical record; the master brief is operative.
    16	
    17	---
    18	
    19	## 0. The thirty-second version
    20	
    21	You are building **Intel Force OS v2 (IFOS)**, an operations product for UK recruitment agencies, on top of **cortextOS** — the persistent 24/7 Claude Code agent runtime by `grandamenium/cortextos`.
    22	
    23	Three repositories are in play:
    24	
    25	```
    26	~/code/CortexOS/                     ← v2 codebase (this one). The product.
    27	├── packages/harness/cortextos/      ← cortextOS vendored at a pinned SHA. READ-ONLY.
    28	│                                       Only the four bus/kb-*.sh files are overridable
    29	│                                       per §3.4. Everything else: hands off.
    30	├── packages/...                     ← Our product code lives here.
    31	└── docs/...
    32	
    33	~/code/intel-force-os/               ← v1 codebase. ALIVE, do not modify.
    34	                                       Source of inheritance only. Read it,
    35	                                       lift the artefacts named in §7.
    36	
    37	~/code/cortex-os-upstream/           ← Upstream cortextOS clone, read-only.
    38	                                       For reference grep when the vendored copy
    39	                                       isn't enough. Tracks main.
    40	```
    41	
    42	CortexOS gives us PM2 process supervision, persistent PTY agents, 71-hour context rotation, file-bus inter-agent handoff, a Telegram approval surface, an orchestrator template, and a Next.js dashboard. We **consume**, never modify.
    43	
    44	We add: a vertical schema for UK recruitment; 18 agents in the v2 bundle pattern; an Obsidian-style wiki + graphify second brain that **replaces** cortextOS's stock knowledge-base behind the `bus/kb-*.sh` boundary; MCP connectors for Bullhorn/Companies House/Xero/Microsoft Graph; an entity-graph + decision-log Postgres layer with RLS; a per-tenant LoRA pipeline (v2.0 work); and a five-day onboarding wizard.
    45	
    46	The five rules in §1 govern every decision. The boundary in §3 governs every file. The Week 0 list in §6 is the only thing to do this week. Read all three before writing any agent code.
    47	
    48	---
    49	
    50	## 1. The five rules (non-negotiable)
    51	
    52	If anything anywhere in this brief, in any other document, or in your own session reasoning violates one of these, the rule wins.
    53	
    54	1. **Output before architecture.** Every agent ships with its output contract written first, as a one-paragraph screenshot description. If you can't write it, the agent isn't ready to start.
    55	2. **Schema before code.** Anything that varies per customer lives in `docs/verticals/recruitment/vertical-schema.yaml`, the agent's `config.schema.json`, or the tenant's `/vault/{tenant}/`. Never in agent prompts. Never in agent code. A code review that finds a customer-specific string in code is rejected on that basis alone.
    56	3. **Reuse before build.** Every agent uses `agents/_shared/` modules: voice loader, decision-log writer, validate primitives, escalation router. No agent writes its own logging, voice handling, or approval gate. If the shared module is missing, build the module first, then the agent.
    57	4. **Quality gates before features.** Gate A (per-run `validate.sh`) working + decision-log writes (`hh_decision_trigger / output / action`) present > extra features. `validate.sh` hard-fails on missing decision-log calls. No exceptions.
    58	5. **Honest signal before optimistic projection.** When something doesn't work, log it in `.agents/learnings/` and re-plan. The risk register at `docs/RISK-REGISTER.md` is updated weekly with no hedging.
    59	
    60	Recite these on Monday morning before the standup. The rules drift first.
    61	
    62	---
    63	
    64	## 2. The verified state of cortextOS — what we actually depend on
    65	
    66	Everything in this section is verified against `grandamenium/cortextos@main` as of 16 May 2026. The handoff doc was right in spirit but had two assumptions that are wrong; corrections inlined.
    67	
    68	### 2.1 Package facts
    69	
    70	- **npm:** `cortextos@0.1.1`, CommonJS, MIT-licensed
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
/bin/zsh -lc "nl -ba docs/decisions/sequencing-target.md | sed -n '1,130p'" in /Users/madsadmin/code/CortexOS
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
   121	|---|---|---|
   122	| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 526 estimate **M (1 week)**. Webhook-driven not always-on. Structured-field mapping is per-firm config not code per Ultraplan §8.1 line 526. Tacit-note extraction is the hard part per Ultraplan §8.1 line 527 ("Start with a small taxonomy (5-10 tacit-note types) and expand") |
   123	| 2. Substrate exercise | **Medium-High** | Exercises Bullhorn W (smaller surface than Janitor's R+W). First agent with external webhook trigger (Fathom / Fireflies). First exercise of voice-loader for **tacit-note tone-detection** per Ultraplan §8.1 line 523. Reuses Janitor's Bullhorn auth refresh-loop |
   124	| 3. Risk de-risking | **Medium** | Reuses Janitor's Bullhorn auth path (doesn't re-derisk Risk #2). Surfaces new failure mode: **webhook-arrival-to-Bullhorn-write SLA** (5-min target per Ultraplan §8.1 line 521). Doesn't directly touch Risk #5 (renderer already proven by Diagnostic) or Risk #1 (still Tier 2) |
   125	| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
   126	| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Concierge consumes Scribe-generated Notes for context per `bullhorn-integration-path.md` §4.1 row 4 ("Note (prior-comms history)"). Scribe must ship before Concierge | Medium-High criticality |
   127	| 6. Tenant-onboarding readiness | **Medium** | Needs Fathom or Fireflies OAuth + Bullhorn (already onboarded if Janitor shipped). Tacit-note taxonomy needs per-firm calibration in first 30 days of production per Ultraplan §8.1 line 527 |
   128	
   129	**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
   130	

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/validate.sh | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
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
   233	  # Emit ESC_SCHEMA_VIOLATION row to decision_log with the failure list
   234	  ESC_PAYLOAD=$(printf '{"escalation_code":"ESC_SCHEMA_VIOLATION","draft_path":"%s","failures":%s}' \
   235	    "${DRAFT}" \
   236	    "$(printf '%s\n' "${FAILURES[@]}" | python3 -c "import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))" 2>/dev/null || echo '[]')")
   237	
   238	  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \
   239	    "$(echo "${ESC_PAYLOAD}" | shasum | awk '{print $1}')" \
   240	    "${ESC_PAYLOAD}" 2>/dev/null || true
   241	
   242	  exit 1
   243	fi

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
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/tools.yaml | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "rg --files | rg 'common-.*\\.json|target_patch|target-patch|voice\\.json|notifications\\.json'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/agents-runtime/_shared/common-accounting.json
packages/agents-runtime/_shared/common-client.json
packages/agents-runtime/_shared/common-notifications.json
packages/agents-runtime/_shared/common-voice.json
packages/agents-runtime/_shared/common-vault.json
packages/agents-runtime/_shared/common-base.json
packages/agents-runtime/_shared/common-ats.json
packages/agents-runtime/_shared/common-target-patch.json

exec
/bin/zsh -lc "nl -ba packages/agents-runtime/_shared/common-target-patch.json | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba packages/agents-runtime/_shared/common-voice.json | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc 'rg -n "diagnostic_report|target_patch|deal_size_band|voice_classifier_threshold|tone_rule|recent_edit|gate_b_outcome|validate_gate_a_fail|diagnostic" docs/verticals/recruitment packages/agents-runtime/_shared -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:26:DROP TABLE IF EXISTS recent_edit          CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:27:DROP TABLE IF EXISTS tone_rule            CASCADE;
packages/agents-runtime/_shared/common-voice.json:28:    "voice_classifier_threshold": {
packages/agents-runtime/_shared/common-voice.json:35:    "recent_edits_lookback_days": {
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
packages/agents-runtime/_shared/common-voice.json:42:    "tone_rules_severity_floor": {
packages/agents-runtime/_shared/common-voice.json:46:      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."
packages/agents-runtime/_shared/common-voice.json:49:  "required": ["voice_corpus_path", "voice_classifier_threshold"],
packages/agents-runtime/_shared/common-target-patch.json:5:  "description": "Tenant's commercial sweet spot: sectors, geography, deal sizes, allow/block lists. Read by Sourcing Scout (W9) + Diagnostic (W3-4). Per PRODUCT-SPEC §5.3 line 363.",
packages/agents-runtime/_shared/common-target-patch.json:30:    "deal_size_band_gbp": {
packages/agents-runtime/_shared/common-target-patch.json:38:      "description": "Bands surface in Diagnostic ICP scoring + Sourcing Scout shortlist filtering."
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:123:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:252:      tone_rules_triggered:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:257:          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:341:  voice_corpus_governs_tone_rules:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:343:    target: tone_rule
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:346:      One voice_corpus version logically governs the set of tone_rules active at that version. When voice_corpus rolls forward (new version, is_active flipped), tone_rules don't migrate automatically — but the linkage records WHICH rules were active under WHICH corpus for audit and rollback.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:350:  recent_edit_drives_retraining:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:393:  Q12_tone_rule_severity_block_path:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:405:      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:78:--   WHERE table_name='recent_edit' AND column_name='text_purged_at';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:82:--   WHERE table_name='recent_edit' AND column_name='original_text';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:86:--   WHERE table_name='recent_edit' AND constraint_name='recent_edit_text_purged_consistency';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:90:--   WHERE tablename='recent_edit' AND indexname='recent_edit_text_purged_idx';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:15:--   - 2 entity_links link_type values (voice_corpus_governs_tone_rules,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:16:--     recent_edit_drives_retraining); also JSONB-backed in entity_links.metadata
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
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:6:-- side effects on existing recent_edit data).
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:15:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:18:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:19:  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:21:DROP INDEX IF EXISTS recent_edit_text_purged_idx;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:23:ALTER TABLE recent_edit
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
docs/verticals/recruitment/vertical-schema.yaml:280:      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
docs/verticals/recruitment/vertical-schema.yaml:671:  Diagnostic:
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
docs/verticals/recruitment/vertical-schema.yaml:758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.

exec
/bin/zsh -lc 'rg -n "validate_gate_a_fail|diagnostic_report_render|action_types:" agents/_shared packages -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:8:# 29 v1.0 action_types: 6 green + 5 yellow + 10 orange + 8 red.
agents/_shared/autosend-policy.yaml:23:action_types:
agents/_shared/autosend-policy.yaml:29:  diagnostic_report_render:
agents/_shared/tests/test-hook-helpers.sh:118:test_lookup_green() { local t; t=$(autosend_policy_lookup "diagnostic_report_render"); _assert_eq "green" "${t}" "green"; }
agents/_shared/tests/test-hook-helpers.sh:132:  hh_decision_action "diagnostic_report_render" "candidate:test" "abc123" "test preview"

exec
/bin/zsh -lc "nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '1,170p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-004-renderer-implementation-deviations.md | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# ADR-004 — Renderer implementation deviations from ADR-003
     2	
     3	**Date:** 2026-05-20 (Week 0, Day 8 — Phase-2/3 follow-up)
     4	**Author:** Claude Code, with founder review pending
     5	**Surfaced by:** Phase-2 + Phase-3 of `~/.claude/plans/bubbly-snuggling-lantern.md` (commits `3c16d35` + `e6e9df1`)
     6	**Submodule SHA:** `c21fbfe991a0030ea055bd8e2389a0801a424383` (unchanged from ADR-003)
     7	**Predecessor:** [ADR-003 — Agent bundle v2 renderer](./ADR-003-agent-bundle-renderer.md) (Accepted)
     8	**Status:** Proposed
     9	
    10	---
    11	
    12	## Context
    13	
    14	ADR-003 ratified the renderer design on 2026-05-16 (Day 1 evening). Phase 2 of the Week-1 product-code slice (commit `3c16d35`) implemented the renderer per ADR-003 §3.1 — TypeScript Node, `tsup` + `vitest` + `commander`, 12-row file map, atomic-write protocol. Phase 3 (commit `e6e9df1`) implemented `agents/_shared/hook-helpers.sh` and triggered an end-to-end integration test against the rendered output.
    15	
    16	During implementation, three points of the ratified design did not survive contact with the live system. Each was resolved by deviating from the specification text; each is documented in commit messages + the renderer's `README.md`. This ADR ratifies the three deviations as deliberate decisions before they surface as REJECT items in Codex Day-7 ratification.
    17	
    18	The three deviations are individually small. The reason this ADR exists rather than three inline `errata` notes in ADR-003 is master brief §10.5 ("Always-ratify list"): renderer architectural decisions go through Codex review, and a single coherent ADR is the audit-trail-friendly path. Reading ADR-003 + ADR-004 together gives the full ratified renderer surface.
    19	
    20	---
    21	
    22	## Decision
    23	
    24	### Decision 1 — Standalone `ifos-render-agent` Node binary, NOT `cortextos-ifos render-agent` subcommand
    25	
    26	**ADR-003 §3.3.1 specified the CLI signature:** `cortextos-ifos render-agent <agent-name> --tenant <slug>`.
    27	
    28	**Implementation ships:** `ifos-render-agent <agent-name> --tenant <slug>` as a standalone Node binary declared in `packages/agent-renderer/package.json` `bin` field. Same arguments + flags as ADR-003 §3.3.1; different command name.
    29	
    30	**Why the deviation:** `cortextos-ifos` is the upstream CLI shipped from the cortextOS submodule at `/opt/homebrew/bin/cortextos-ifos`. Adding a `render-agent` subcommand to that binary requires modifying source in `packages/harness/cortextos/`, which violates master brief §3.1 boundary 1 (cortextOS submodule read-only). The boundary is non-negotiable per master brief §3.1 + the build-pack discipline that the submodule is a "reference pin, not the runtime."
    31	
    32	Three alternatives considered:
    33	
    34	- **Modify upstream cortextOS.** Rejected — violates §3.1 boundary 1. Also forks IFOS off the upstream maintenance line.
    35	- **`ifosctl` shim that multiplexes** (`.envrc` already declares `alias ifosctl="cortextos-ifos"`). Rejected for Phase 2 — would require building a routing shim that intercepts `render-agent` and forwards everything else. Real engineering cost; not a 10-minute alias swap. Founder can layer this on later if naming uniformity matters.
    36	- **Standalone binary** (chosen) — zero changes to upstream; CLI surface lives entirely under `packages/agent-renderer/`. Invocation pattern matches every other Node CLI in the IFOS ecosystem.
    37	
    38	**Consequences:**
    39	
    40	- ADR-003 §3.3.1 needs an erratum or this ADR's ratification, depending on how Codex treats the divergence.
    41	- Master brief §8.3 Edit B (the `cortextos-ifos render-agent {name} --tenant <slug>` invocation line in the agent-development working pattern) needs an update — see §"Master brief edits authorised" below.
    42	- `ifosctl render-agent` is **not** available; future shim work is a separate ADR (call it ADR-005 if/when it lands).
    43	
    44	### Decision 2 — Symlink target is `../../../_shared`, not `../../_shared`
    45	
    46	**ADR-003 §3.3.3 Option γ specified verbatim:** *"per-agent `.claude/hooks/_shared` symlink resolves to `../../_shared` (relative)."*
    47	
    48	**Implementation ships:** `../../../_shared` (3 `..` segments, not 2).
    49	
    50	**Why the deviation:** counting error in ADR-003. Starting from the symlink file at `<agent_dir>/.claude/hooks/_shared`, the canonical `_shared/` directory at `<org>/agents/_shared/` is **3 levels up**, not 2:
    51	
    52	```
    53	<agent_dir>/.claude/hooks/_shared       ← symlink lives here
    54	<agent_dir>/.claude/hooks/              ← `..`
    55	<agent_dir>/.claude/                    ← `../..`
    56	<agent_dir>/                            ← `../../..`
    57	<org>/agents/                           ← contains <agent_dir>/ AND _shared/
    58	<org>/agents/_shared/                   ← target
    59	```
    60	
    61	So the relative path from the symlink's containing directory is `../../../_shared`, NOT `../../_shared`. With the ADR-003 spec verbatim, the symlink resolves to `<agent_dir>/_shared/` (INSIDE the agent dir, where no `_shared` exists) and breaks at first source. This was caught during the Phase-3 end-to-end integration test when `source .claude/hooks/_shared/hook-helpers.sh` failed with `No such file or directory`.
    62	
    63	**No alternatives** — this is an off-by-one fix, not a design choice. The deviation is corrected in `packages/agent-renderer/src/renderer.ts` with an inline comment flagging the ADR-003 spec error.
    64	
    65	**Consequences:**
    66	
    67	- ADR-003 §3.3.3 should be updated to say `../../../_shared` (4 segments including `_shared`).
    68	- ADR-003 §2.3 worked-Concierge-example output diagram says `_shared/` lives at `orgs/acme/agents/_shared/` — that's correct, the bug is only in the symlink-target text. Diagram is right; symlink string is wrong.
    69	
    70	### Decision 3 — `_shared/` listed as phantom agent in `cortextos-ifos list-agents` is accepted as upstream concern
    71	
    72	**Observation:** `cortextos-ifos list-agents` (which calls into `packages/harness/cortextos/src/bus/agents.ts` `listAgents()`) scans `${frameworkRoot}/orgs/<org>/agents/*` and treats every immediate directory child as an agent. `_shared/` sits in that location per ADR-003 §3.3.3 Option γ. Result: `_shared` appears in the list-agents output as if it were an agent named `_shared` in org `<tenant>`, with no display name + no config + status `stopped`.
    73	
    74	**Decision:** **Accept as upstream limitation.** Do NOT modify the renderer to relocate `_shared/` outside the scanned directory. The placement matches ADR-003's design intent (one canonical `_shared/` per org reachable by all agents via relative symlink). Renderer correctness is unaffected — the daemon's own `discoverAndStart()` doesn't try to launch `_shared` because it has no `config.json`; PM2 + agent-manager skip it cleanly. Only the cosmetic `list-agents` output is affected.
    75	
    76	Three alternatives considered:
    77	
    78	- **Relocate `_shared/` outside `orgs/<org>/agents/`** — would break the relative-symlink semantics from `.claude/hooks/_shared → ../../../_shared`. Either we accept a longer relative path (`../../../../_shared` from outside `agents/`) or absolute path (loses portability). Both worse than the cosmetic phantom-listing issue.
    79	- **Prefix `_shared/` with a dotfile** (`.shared/`) to make the listAgents scan skip it. Rejected — Bash glob conventions + Postgres conventions both treat dot-prefix as "hidden", and we'd lose the discoverable convention that `_shared/` follows IFOS naming rules. Also drifts further from the master brief vocabulary.
    80	- **File an upstream issue / PR against cortextOS** to filter out `_shared/` (and other underscore-prefixed names) in `listAgents()`. **Recommended path** — open an issue on the cortextOS repo per master brief §3 boundary 1 ("the submodule is a reference pin, not the runtime; upstream changes go upstream"). Phase 2 ships the deviation as documented; founder + upstream maintainer fix it on their schedule.
    81	
    82	**Consequences:**
    83	
    84	- Cosmetic `list-agents` output has one extra row per tenant. Founder-side tooling that consumes `list-agents` JSON output must filter for `name !== '_shared'`.
    85	- File an upstream issue on cortextOS at next reasonable opportunity. Track in `.agents/learnings/00-cortextos-quirks.md` so future builds don't re-discover this.
    86	
    87	---
    88	
    89	## Master brief edits authorised by this ADR
    90	
    91	**Edit D — Master brief §8.3 working pattern line 121 (post-ADR-003 Edit B).**
    92	
    93	Current (post-ADR-003 Edit B at master brief §8.3 lines 614-630):
    94	
    95	```bash
    96	# After merge, render the bundle for each tenant that uses this agent:
    97	cortextos-ifos render-agent {name} --tenant <slug>
    98	# For all active tenants (v1.1+): cortextos-ifos render-agent {name} --all-tenants
    99	# Activate: pm2 restart ifos-daemon   (for new agents)
   100	#       OR: cortextos-ifos bus self-restart {name}   (for re-renders of running agents)
   101	```
   102	
   103	Proposed (Decision 1 ratifies the deviation):
   104	
   105	```bash
   106	# After merge, render the bundle for each tenant that uses this agent:
   107	ifos-render-agent {name} --tenant <slug>
   108	# (Or via the Node CLI in repo: `node packages/agent-renderer/dist/cli.js render {name} --tenant <slug>`.)
   109	# For all active tenants (v1.1+): the --all-tenants flag is deferred to a future ADR-005
   110	# Activate: pm2 restart ifos-daemon   (for new agents)
   111	#       OR: cortextos-ifos bus self-restart {name}   (for re-renders of running agents)
   112	```
   113	
   114	Lands in this ADR's commit if approved; otherwise queued for the next atomic-correction commit alongside ADR-003 spec-text fixes.
   115	
   116	**Edit E — ADR-003 §3.3.3 symlink target string.**
   117	
   118	Current (ADR-003 §3.3.3 — Option γ paragraph):
   119	
   120	> "per-agent `.claude/hooks/_shared` symlink resolves to `../../_shared` (relative)."
   121	
   122	Proposed (Decision 2 ratifies the off-by-one correction):
   123	
   124	> "per-agent `.claude/hooks/_shared` symlink resolves to `../../../_shared` (relative — three levels up from `.claude/hooks/` to `orgs/<org>/agents/`, then `_shared`)."
   125	
   126	Lands in ADR-003 itself as an inline erratum (small text fix), OR as a §5 entry in this ADR titled "Errata to ADR-003." Founder decision at ratification time.
   127	
   128	**Edit F — ADR-003 §3.3.1 CLI signature.**
   129	
   130	Current (ADR-003 Decision 1 paragraph, internal text):
   131	
   132	> "invoked via `cortextos-ifos render-agent <agent-name> --tenant <slug>` (CLI signature per design §3.3.1)."
   133	
   134	Proposed (Decision 1 ratifies the deviation):
   135	
   136	> "invoked via `ifos-render-agent <agent-name> --tenant <slug>` (CLI signature per design §3.3.1 + ADR-004 Decision 1; standalone Node binary per `packages/agent-renderer/package.json` `bin`. The `cortextos-ifos render-agent` form named in earlier drafts requires modifying the read-only submodule and was rejected per master brief §3.1 boundary 1)."
   137	
   138	Lands in ADR-003 itself OR as §5 in this ADR per Edit E's pattern.
   139	
   140	---
   141	
   142	## Consequences
   143	
   144	**For Risk #5 (renderer-not-built).** Severity unchanged at High per ADR-003 line 145 staged ladder ("Drops to Medium once renderer code is committed AND the Diagnostic agent renders cleanly (Week 4)"). The Phase-2 commit `3c16d35` satisfies the first condition; the second condition (Diagnostic render) is gated on Q1 design-partner LOI. ADR-004 closes a stylistic gap (3 deviations) but does not change risk severity.
   145	
   146	**For Codex Day-7 ratification.** ADR-004 joins the queue. The 3 deviations were pre-flagged in Phase-2 and Phase-3 commit messages + `packages/agent-renderer/README.md`; this ADR consolidates them into a single ratifiable artefact. Without ADR-004, Codex would likely REJECT each deviation individually as "implementation diverges from ADR-003"; with ADR-004, the deviations are deliberately-ratified design decisions Codex either RATIFIES or REJECTS as a coherent set.
   147	
   148	**For master brief drift.** Edit D + Edit E + Edit F enter the deferred atomic-correction queue (if not landed in this commit). Risk #7 (master-brief-drift-accumulation) is currently closed; reopening it for 3 small text edits is honest but tracked here. Founder decides at ratification time whether to land in this commit or queue for the next atomic correction.
   149	
   150	**For future Diagnostic builds.** Decision 1 means agents/runbooks/onboarding-wizard documentation references `ifos-render-agent`, not `cortextos-ifos render-agent`. Cheap to update everywhere because no documentation has shipped yet — only ADR-003 + master brief §8.3 reference the old name, and both are addressed in §"Master brief edits authorised."
   151	
   152	**For `.agents/learnings/00-cortextos-quirks.md`.** Add a Day-8 entry under "Quirks of cortextOS we've worked around" naming Decision 3's phantom-`_shared`-listing observation. Helps future agent builds avoid re-discovering it.
   153	
   154	---
   155	
   156	## Status
   157	
   158	**Proposed.** Founder review pending. Codex Day-7 queue position 34 (appended after the 33-item Day-8 close). If founder accepts:
   159	
   160	- Land ADR-004 commit with the three §"Master brief edits authorised" applied verbatim
   161	- Land erratum on ADR-003 §3.3.3 (Edit E) + §3.3.1 internal text (Edit F) in the same commit OR in next atomic-correction commit
   162	- Reopen Risk #7 with edit count = 3 (Edits D + E + F) for tracking
   163	- File upstream cortextOS issue against `bus/agents.ts:listAgents()` for Decision 3's phantom-listing fix
   164	
   165	If founder rejects any deviation:
   166	
   167	- Decision 1 reject = build `ifosctl` shim that multiplexes; ~2-3 days of work; new ADR-005
   168	- Decision 2 reject = impossible (off-by-one is a fact, not a choice); rejection means rebuilding the symlink topology, which means re-architecting `_shared/` placement, which means a new ADR
   169	- Decision 3 reject = relocate `_shared/` outside `orgs/<org>/agents/`; loses relative-symlink portability; new ADR
   170	
   171	Founder bias: accept all three. The deviations are small, well-justified, and the cost of un-deviating is disproportionate to the benefit.
   172	
   173	*End of ADR-004.*

exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-003-agent-bundle-renderer.md | sed -n '1,170p'" in /Users/madsadmin/code/CortexOS
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
    81	> mkdir -p agents/recruitment
    82	> mkdir -p infrastructure/{docker,terraform,pm2,postgres}
    83	> mkdir -p tests/{unit,integration,eval-sets}
    84	> mkdir -p .agents/{decisions,learnings,priorities}
    85	> mkdir -p .codex/{ratification,evals,scratch}
    86	> ```
    87	
    88	**Proposed:** add `agent-renderer` to the `packages/` enumeration. The line becomes:
    89	
    90	> ```bash
    91	> mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext,agent-renderer}
    92	> ```
    93	
    94	Lands in this ADR's commit. Edit A is the minimum required to make `packages/agent-renderer/` a canonical IFOS package per master brief §4.1; Week-1 renderer implementation depends on the path existing.
    95	
    96	### Edit B — Master brief §8.3 working pattern
    97	
    98	**Current** (master brief §8.3 lines 614-630):
    99	
   100	> ```bash
   101	> git checkout -b agent/{name}                       # e.g. agent/janitor
   102	> mkdir -p agents/recruitment/{name}/tests/fixtures/{01-primary,02-edge-case-{X},99-voice-drift-canary}
   103	>
   104	> # In Claude Code, work the bundle through 6 files in this order:
   105	> # 1. README.md (2-min overview)
   106	> # 2. agent.md (OUTPUT CONTRACT FIRST, then workflow, then gates, then escalation)
   107	> # 3. config.schema.json (what the wizard collects)
   108	> # 4. tools.yaml (MCP servers + scopes + degraded modes)
   109	> # 5. validate.sh (Gate A; sources _shared/hook-helpers.sh)
   110	> # 6. context.sh (hydrates CONTEXT via context-assembly API)
   111	>
   112	> # Then the three fixtures with golden outputs.
   113	> # Test against fixtures; iterate; commit; PR; merge.
   114	> ```
   115	
   116	**Proposed:** append a renderer step after merge:
   117	
   118	> ```bash
   119	> # Then the three fixtures with golden outputs.
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
   166	4. Day 7 Codex ratification reviews ADR-003 + design doc + the previously-queued artefacts together.

exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Auto-send safety policy
     2	
     3	**Status:** Proposed — pending Codex Day-7 ratification
     4	**Date:** 2026-05-18 (Week 0, Day 5)
     5	**Author:** Claude Code, with founder review pending
     6	**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
     7	**Surfaced by:** Master brief Day 5 spec; load-bearing for every `hh_decision_action` call across the v1.0 agent fleet.
     8	**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
     9	
    10	---
    11	
    12	## §1 — Scope
    13	
    14	This policy governs **every agent action that produces a side effect outside the IFOS-internal data layer**. The internal data layer is:
    15	
    16	- The vault (`/vault/<tenant>/`) — markdown + YAML, IFOS-controlled
    17	- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
    18	- The pgvector indexes over the above
    19	- The cortextOS file bus and PM2 process tree
    20	
    21	**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).
    22	
    23	**Actions that ARE governed:**
    24	
    25	1. Writes to any external system via MCP connector (Bullhorn, Companies House, Xero, Microsoft Graph, etc.) — every `tools.yaml`-declared write scope
    26	2. Sends to humans via any communication channel (email, SMS, Telegram, Slack, LinkedIn InMail, calendar invite, etc.) — both customer-facing and consultant-internal where the consultant is not the agent's directly-supervising user
    27	3. Reads from external systems that touch PII or have rate-limit/cost implications (LinkedIn profile lookups, Companies House director searches)
    28	4. Any action declared as side-effecting in `tools.yaml` for an agent, regardless of category
    29	
    30	**Out of scope:**
    31	
    32	- Read-only IFOS internal queries (entities, decision_log reads via context-assembly API)
    33	- Render-time renderer operations (writing rendered agent dirs to `${frameworkRoot}/orgs/<org>/agents/<name>/`)
    34	- Vault local writes by the agent's own validate.sh / context.sh / fixture runs
    35	- Codex ratification artefacts (read-only review)
    36	
    37	If an action's scope is ambiguous, default to **governed** and require classification.
    38	
    39	**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
    40	
    41	---
    42	
    43	## §2 — Tier model
    44	
    45	Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.
    46	
    47	### Green — auto-send allowed without review
    48	
    49	Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
    50	
    51	**Default characteristics:** idempotent OR internal-to-tenant OR read-only against external systems with rate-limit budget remaining OR low-cost-to-reverse (e.g., add a Bullhorn tag that can be removed in <30s).
    52	
    53	### Yellow — auto-send allowed with sampled spot-check
    54	
    55	Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
    56	
    57	**Default characteristics:** high-volume actions where systematic per-action review is too slow but where systematic blind trust is too risky; sampled review provides quality signal without operational drag.
    58	
    59	### Orange — requires human approval before send
    60	
    61	Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
    62	
    63	**Default characteristics:** moderate-to-high cost-to-reverse OR customer-facing comms OR irreversible state changes.
    64	
    65	### Red — blocked entirely
    66	
    67	Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
    68	
    69	**Default characteristics:** financial/legal/cross-tenant/PII boundaries; structural integrity of the IFOS multi-tenant model.
    70	
    71	---
    72	
    73	## §3 — Examples per tier across the v1.0 agent surface
    74	
    75	Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
    76	
    77	### Green examples (auto-send without review)
    78	
    79	| Agent | action_type | Why green |
    80	|---|---|---|
    81	| Diagnostic | `diagnostic_report_render` | Internal artefact write; no external comms; idempotent (re-render overwrites) |
    82	| Janitor | `bullhorn_candidate_tag` | Adds a tag with `checked_at` date; reversible in <30s; high volume |
    83	| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
    84	| Sourcing Scout | `linkedin_profile_cache` | Stores profile snapshot to `/vault/<tenant>/wiki/raw/`; no external send; no rate-limit cost |
    85	| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
    86	| Concierge | `bullhorn_brief_read` | Read of inbound brief; idempotent; no comms |
    87	
    88	### Yellow examples (auto-send with spot-check sampling)
    89	
    90	| Agent | action_type | Sample rate | Why yellow |
    91	|---|---|---|---|
    92	| Janitor | `bullhorn_candidate_dedupe` | 1-in-10 | Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review |
    93	| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
    94	| Sourcing Scout | `linkedin_connection_request` | 1-in-5 | Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy |
    95	| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
    96	| Concierge | `bullhorn_note_draft_internal` | 1-in-10 | Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate |
    97	
    98	### Orange examples (per-action human approval)
    99	
   100	| Agent | action_type | Why orange |
   101	|---|---|---|
   102	| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
   103	| Concierge | `gmail_outlook_send_to_candidate` | Outbound email to candidate; customer-facing; reputation effects |
   104	| Concierge | `twilio_sms_send` | Outbound SMS; high-trust channel; cost-per-send; irreversible |
   105	| Concierge | `calendar_invite_send` | Creates calendar event with attendee notification; visible to attendee |
   106	| Scribe | `email_summary_to_customer` | Outbound email summarising call to customer; customer-facing; format-sensitive |
   107	| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
   108	| Diagnostic | `diagnostic_email_send` | Outbound diagnostic report to prospect; sales-stage outreach; reputation |
   109	| Diagnostic | `diagnostic_calendar_invite` | Books intro call with prospect; reputation + scheduling friction |
   110	| Sourcing Scout | `linkedin_inmail_send` | Outbound InMail (paid credit); cost-per-send; customer-facing |
   111	| Janitor | `bullhorn_placement_terminate` | Marks placement as terminated; commercial/legal implications; reversible only via support ticket |
   112	
   113	### Red examples (blocked entirely; `ESC_AUTOSEND_BLOCKED`)
   114	
   115	| action_type | block_reason | Why red |
   116	|---|---|---|
   117	| `xero_payment_initiate` | `payment_action` | Payment transfer; financial-bearing; never auto-send in v1.0 |
   118	| `stripe_charge_initiate` | `payment_action` | Charges a card; financial-bearing |
   119	| `subscription_modify` | `billing_modification` | Changes tenant's IFOS subscription; structurally distinct from agent work |
   120	| `legal_document_generate` | `legal_artefact` | Offer letters, employment contracts; legal-binding |
   121	| `pii_export_outside_tenant_geography` | `pii_geographic_breach` | PII transmitted outside tenant's declared data residency (e.g., GDPR boundary breach) |
   122	| `cross_tenant_data_send` | `cross_tenant_violation` | Sending tenant-A data to tenant-B recipient; structurally enforced by RLS but red-listed for defence-in-depth |
   123	| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
   124	| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |
   125	
   126	---
   127	
   128	## §4 — Integration with the `hh_decision_action` contract
   129	
   130	Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
   131	
   132	- `hh_decision_trigger` — at session start; logs the trigger
   133	- `hh_decision_output` — when the agent produces its output artefact
   134	- `hh_decision_action` — when an action is taken (or blocked)
   135	
   136	The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.
   137	
   138	### Reference implementation (bash pseudocode for `_shared/hook-helpers.sh`)
   139	
   140	```bash
   141	# hh_decision_action — gate every side-effecting action through the policy
   142	# Args:
   143	#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
   144	#   $2 target        (entity reference, e.g., "candidate:john-smith")
   145	#   $3 payload_hash  (SHA-256 hex of the action payload)
   146	#   $4 payload_preview (human-readable summary, <=500 chars, NO raw PII)
   147	hh_decision_action() {
   148	  local action_type="$1"
   149	  local target="$2"
   150	  local payload_hash="$3"
   151	  local payload_preview="$4"
   152	
   153	  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
   154	  local tenant_slug="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   155	  local agent_name="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"
   156	
   157	  # 1. Policy lookup — read tier from the canonical policy table
   158	  local tier
   159	  tier=$(autosend_policy_lookup "$action_type") || {
   160	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
   161	    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
   162	    return 1
   163	  }
   164	
   165	  # 2. Apply tenant override (elevation only; red is floor)
   166	  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
   167	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
   168	    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
   169	    return 1
   170	  }
   171	
   172	  # 3. Tier dispatch
   173	  case "$tier" in
   174	    green)
   175	      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
   176	      return 0
   177	      ;;
   178	    yellow)
   179	      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
   180	      if autosend_should_sample "$action_type" "$tenant_slug"; then
   181	        autosend_spot_check_enqueue "$action_type" "$target" "$payload_hash" "$payload_preview" "$tenant_slug"
   182	      fi
   183	      return 0
   184	      ;;
   185	    orange)
   186	      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
   187	      autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW "$action_type" "$target" "$payload_hash" "$payload_preview"
   188	      # Blocks on cortextOS approval gate (master brief primitive 4). Returns 0 on approval, 1 on reject/timeout.
   189	      autosend_await_approval "$action_type" "$target" "$payload_hash"
   190	      return $?
   191	      ;;
   192	    red)
   193	      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
   194	      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
   195	      return 1
   196	      ;;
   197	    *)
   198	      # Fail-safe: unknown tier → red
   199	      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
   200	      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
   201	      return 1
   202	      ;;
   203	  esac
   204	}
   205	```
   206	
   207	### Where the policy check fires in the renderer pipeline
   208	
   209	The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
   210	
   211	**Policy hot-reload:** if the policy file changes mid-session (rare), the agent does NOT pick it up until the next session boundary (cortextOS PTY restart). Material policy changes must wait for the next 71-hour boundary or trigger a deliberate restart. Documented as an operational footgun in §11 open questions.
   212	
   213	### `tools.yaml` declaration
   214	
   215	Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
   216	
   217	```yaml
   218	# agents/recruitment/concierge/tools.yaml (excerpt)
   219	action_types:
   220	  - bullhorn_brief_read              # green

exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '220,360p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   220	  - bullhorn_brief_read              # green
   221	  - bullhorn_candidate_query         # green
   222	  - bullhorn_note_draft_internal     # yellow (sample 1-in-10)
   223	  - bullhorn_note_customer_visible   # orange (CANONICAL — bullhorn-integration-path §4.1)
   224	  - gmail_outlook_send_to_candidate  # orange
   225	  - calendar_invite_send             # orange
   226	  - twilio_sms_send                  # orange
   227	```
   228	
   229	Agents cannot invoke action_types not declared in their `tools.yaml`. Renderer validates this at render time per ADR-003 §4 (`ESC_RENDERER_FAILED` reason `bundle-malformed` if a declared action_type isn't in the policy).
   230	
   231	---
   232	
   233	## §5 — Escalation codes
   234	
   235	Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.
   236	
   237	### `ESC_AUTOSEND_NEEDS_REVIEW`
   238	
   239	**Tier:** orange
   240	**Fires when:** an orange-tier action is invoked; opens cortextOS approval gate (primitive 4)
   241	**Payload (JSONB into `decision_log.payload`):**
   242	
   243	```json
   244	{
   245	  "action_type": "<enum from autosend-policy.yaml>",
   246	  "target": "<entity ref, e.g., 'candidate:john-smith'>",
   247	  "payload_hash": "<SHA-256 hex>",
   248	  "payload_preview": "<human summary, <=500 chars, NO raw PII>",
   249	  "tenant_slug": "<slug>",
   250	  "agent_name": "<agent identifier>",
   251	  "approval_deadline_at": "<ISO 8601 UTC, default trigger_time + 4h>",
   252	  "approval_gate_id": "<cortextOS approval gate primary key>"
   253	}
   254	```
   255	
   256	**Escalation path:**
   257	
   258	1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
   259	2. `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` opens the cortextOS approval gate
   260	3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
   261	4. Operator responds via Telegram inline button: `approve` / `reject` / `escalate-up`
   262	5. On resolution, `decision_log` row is **appended** (not modified — append-only) with `phase='action'`, `payload.approval_status='approved'|'rejected'|'escalated'` and `payload.approval_resolution_at`
   263	
   264	**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
   265	
   266	**Telegram message template:**
   267	
   268	```
   269	🟠 IFOS approval needed
   270	Tenant: acme-fintech
   271	Agent: concierge
   272	Action: bullhorn_note_customer_visible
   273	Target: candidate:sarah-bowen
   274	Preview: "Following our call, I wanted to confirm the £85k 
   275	base + 15% bonus structure for the Senior PM role at Aragon Labs..."
   276	Approve | Reject | Escalate
   277	Deadline: 2026-05-18 18:42 UTC
   278	```
   279	
   280	### `ESC_AUTOSEND_BLOCKED`
   281	
   282	**Tier:** red
   283	**Fires when:** a red-tier action is invoked; blocked unconditionally
   284	**Payload:**
   285	
   286	```json
   287	{
   288	  "action_type": "<enum>",
   289	  "target": "<entity ref>",
   290	  "payload_hash": "<SHA-256 hex>",
   291	  "payload_preview": "<human summary, <=500 chars>",
   292	  "block_reason": "<enum: red_tier_classification | blocked_recipient | unauthorized_adapter | cross_tenant_violation | payment_action | billing_modification | legal_artefact | pii_geographic_breach>",
   293	  "tenant_slug": "<slug>",
   294	  "agent_name": "<agent identifier>"
   295	}
   296	```
   297	
   298	**Escalation path:**
   299	
   300	1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`
   301	2. `autosend_escalate ESC_AUTOSEND_BLOCKED` notifies tenant operator informationally (no action required)
   302	3. Operator may file a `false-block` feedback report via Brain UI if the tier classification seems wrong; report becomes input to next policy review
   303	
   304	**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).
   305	
   306	**Telegram message template (informational):**
   307	
   308	```
   309	🔴 IFOS auto-send blocked (no action required)
   310	Tenant: acme-fintech
   311	Agent: cash-conductor
   312	Action: xero_payment_initiate
   313	Target: invoice:INV-2026-0042
   314	Block reason: payment_action (red-tier; never auto-sent in v1.0)
   315	Block report: file via Brain UI if you believe this should be allowed
   316	```
   317	
   318	### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
   319	
   320	**Tier:** fail-safe-red (treated as red)
   321	**Fires when:** policy lookup raises an error; action defaults to blocked
   322	**Payload:**
   323	
   324	```json
   325	{
   326	  "action_type": "<enum, may be unknown>",
   327	  "target": "<entity ref>",
   328	  "payload_hash": "<SHA-256 hex>",
   329	  "payload_preview": "<human summary>",
   330	  "lookup_error": "<enum: unknown_action_type | policy_table_corrupt | override_resolution_failed | tenant_not_found | unknown_tier:<value>>",
   331	  "tenant_slug": "<slug>",
   332	  "agent_name": "<agent identifier>"
   333	}
   334	```
   335	
   336	**Escalation path:**
   337	
   338	1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
   339	2. `autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED` notifies tenant operator AND IFOS oncall
   340	3. Treated as a production incident — IFOS oncall investigates within 1h
   341	4. Root cause + fix applied (e.g., add missing `action_type` to policy, repair table corruption, fix override format)
   342	5. Agent resumed with corrected policy
   343	
   344	**Expected resolution:** IFOS oncall investigates within 1h during business hours; within 4h outside business hours. The affected tenant pilot may be PAUSED for that agent until policy is fixed (per `v1.0-kill-criterion.md` §2 trigger 5).
   345	
   346	---
   347	
   348	## §6 — Failure modes
   349	
   350	| Failure | Detection | Response | Recovery |
   351	|---|---|---|---|
   352	| Policy file `autosend-policy.yaml` corrupted (YAML parse error) | First `hh_decision_action` call returns parse error | Fail-safe red for ALL actions; `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` per action; agent halts | IFOS oncall restores from git history; renderer re-deploys; agent resumes |
   353	| Policy file references undefined tier | Tier dispatch hits `*)` default | `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` with `lookup_error='unknown_tier:<value>'` | Policy file fixed; Codex ratifies; redeploy |
   354	| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
   355	| `decision_log` table unreachable (Postgres down, RLS context unset, network partition) | INSERT raises error | **Hard blocking error**; agent halts entirely with non-zero exit; no actions taken at all | Postgres restored OR session restarted with valid context; agent resumes from last checkpoint |
   356	| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
   357	| Telegram primitive 5 unavailable (bot down, chat_id invalid) | `autosend_escalate` returns non-zero | Decision_log row still written; orange action falls back to **block-with-pending** state; agent halts at the action | IFOS oncall investigates Telegram primitive; once restored, pending approval gates resume |
   358	| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |
   359	
   360	---

exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '360,470p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   360	---
   361	
   362	## §7 — Audit
   363	
   364	**Every governed action emits exactly one `decision_log` row** at execution time. The append-only enforcement (Postgres grants on `decision_log` are SELECT + INSERT only for `ifos_app` per Day 4 §6.3) means rows cannot be modified or deleted post-write.
   365	
   366	### Row schema (within existing `decision_log` table from Day 4)
   367	
   368	```sql
   369	-- decision_log columns (Day 4 §6.3):
   370	--   id BIGSERIAL
   371	--   tenant_slug TEXT (RLS-isolated)
   372	--   agent_name TEXT
   373	--   phase TEXT CHECK IN ('trigger','output','action','gating_failed','agent_handoff')
   374	--   outcome TEXT (nullable)
   375	--   reason TEXT (nullable)
   376	--   payload JSONB
   377	--   created_at TIMESTAMPTZ
   378	
   379	-- For autosend audit:
   380	--   phase = 'action'         when allowed (green/yellow/orange-approved)
   381	--   phase = 'gating_failed'  when blocked (red/fail-safe-red/orange-rejected/orange-timeout-rejected)
   382	--   payload structure:
   383	--   {
   384	--     "tier": "green|yellow|orange|red|fail-safe-red",
   385	--     "action_type": "<enum>",
   386	--     "target": "<entity ref>",
   387	--     "payload_hash": "<SHA-256 hex>",
   388	--     "payload_preview": "<<=500 chars, NO raw PII>",
   389	--     "override_applied": "<none|tenant_elevated|tenant_blocked_recipient|...>",
   390	--     "approval_id": "<cortextOS approval gate id if orange>",
   391	--     "approval_status": "<pending|approved|rejected|timeout_rejected|escalated>",
   392	--     "approval_resolution_at": "<ISO 8601 if resolved>",
   393	--     "block_reason": "<enum if red/fail-safe-red>",
   394	--     "policy_version_sha": "<git SHA of autosend-policy.yaml at execution>"
   395	--   }
   396	```
   397	
   398	### What audit answers
   399	
   400	Audit queries answer two recurring questions:
   401	
   402	1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
   403	
   404	2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
   405	
   406	### Privacy of payload
   407	
   408	`payload_preview` is **explicitly required to exclude raw PII**. It is a human-readable summary that:
   409	
   410	- May reference entity types ("candidate", "client") and slugs
   411	- May reference action category ("payment reminder", "interview invite")
   412	- Must NOT contain: full message body, email addresses, phone numbers, names beyond first-name-only-first-character (e.g., "S. Bowen" rather than "Sarah Bowen"), salary figures, candidate notes content
   413	
   414	Full message content lives in the originating system (Bullhorn, Gmail, Twilio). Audit references the system's own audit log (e.g., Bullhorn note ID) via `payload.target`.
   415	
   416	### Retention
   417	
   418	`decision_log` rows are retained **indefinitely** for v1.0. v1.1+ may introduce retention policies (e.g., delete rows older than 7 years per UK statutory retention norms).
   419	
   420	---
   421	
   422	## §8 — Per-tenant override
   423	
   424	Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
   425	
   426	```sql
   427	INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
   428	VALUES (
   429	  'acme-fintech',
   430	  'autosend_policy',
   431	  '{
   432	    "tier_overrides": {
   433	      "bullhorn_note_internal": "yellow",
   434	      "linkedin_connection_request": "orange",
   435	      "bullhorn_candidate_dedupe": "orange"
   436	    },
   437	    "blocked_recipients": [
   438	      "competitor-employees@*",
   439	      "specific.email@example.com"
   440	    ],
   441	    "approval_routing": {
   442	      "default_recipient": "<telegram-chat-id-from-secrets-env>",
   443	      "escalation_chain": ["operator", "owner"]
   444	    },
   445	    "approval_timeouts": {
   446	      "default": "PT4H",
   447	      "twilio_sms_send": "PT30M",
   448	      "xero_reminder_send_customer": "PT24H"
   449	    },
   450	    "sampling_rates": {
   451	      "bullhorn_candidate_dedupe": 1,
   452	      "linkedin_connection_request": 3
   453	    }
   454	  }'::jsonb,
   455	  TRUE
   456	);
   457	```
   458	
   459	### Override rules
   460	
   461	1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
   462	2. **Red is absolute.** A red action_type cannot be elevated by tenant override (already at maximum) and cannot be relaxed (red is the floor).
   463	3. **`blocked_recipients`** is additive only. Recipients can be added; system-default red-list recipients cannot be removed. Pattern matching supported via `*` wildcards.
   464	4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
   465	5. **`approval_timeouts`** allow per-action_type customisation within range [PT30M, PT72H]. Defaults to PT4H if unspecified.
   466	6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
   467	
   468	### Override propagation
   469	
   470	Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.

codex
REJECTED

1. Gate A is weaker than the output contract. Line 16 requires an evidence link backing every factual claim, but lines 158-160 only require all sections and at least one markdown link per section. That allows uncited factual claims to pass Gate A, violating quality-gates-before-features. Fix by either implementing claim-level citation validation or narrowing the contract to “at least one citation per section.”

2. `ESC_SCHEMA_VIOLATION` is used for non-schema failures. Lines 84 and 182 use it for malformed firm input and section-count failures, but `agents/_shared/escalation-codes.md` lines 163-168 define it as vertical-schema field-constraint failure with payload fields like `entity_type`, `field_violated`, and `constraint_failed`. Fix by adding a catalogue-backed Diagnostic report-shape/input escalation code before referencing it, or amend the catalogue payload/trigger explicitly.

3. The `ESC_VOICE_DRIFT_TENANT` citation is wrong. Line 202 says it fires when edit-distance is >200 chars on >50% of recent_edit rows, citing `escalation-codes.md §2.5`; the catalogue instead says it fires on ≥N `ESC_VOICE_DRIFT` rows in a rolling window, and Ultraplan §6.2 lines 369-377 defines a 4-week average score drop. Fix line 202 to match the existing catalogue/Ultraplan trigger or create a new documented escalation.

4. Gate B audit fields and kill-criterion citation are unsupported. Line 167 invents `decision_log.payload.gate_b_outcome`, but autosend-safety-policy §7 lines 382-395 does not document that payload key; line 169 says this is kill-criterion §2 Trigger 5, but `v1.0-kill-criterion.md` lines 107-115 define Trigger 5 as autosend red-tier miscategorisation, not Diagnostic discovery-call conversion. Fix by documenting the Diagnostic outcome field in the relevant schema/audit spec and cite the correct kill criterion, or add a new one.
tokens used
199,886
REJECTED

1. Gate A is weaker than the output contract. Line 16 requires an evidence link backing every factual claim, but lines 158-160 only require all sections and at least one markdown link per section. That allows uncited factual claims to pass Gate A, violating quality-gates-before-features. Fix by either implementing claim-level citation validation or narrowing the contract to “at least one citation per section.”

2. `ESC_SCHEMA_VIOLATION` is used for non-schema failures. Lines 84 and 182 use it for malformed firm input and section-count failures, but `agents/_shared/escalation-codes.md` lines 163-168 define it as vertical-schema field-constraint failure with payload fields like `entity_type`, `field_violated`, and `constraint_failed`. Fix by adding a catalogue-backed Diagnostic report-shape/input escalation code before referencing it, or amend the catalogue payload/trigger explicitly.

3. The `ESC_VOICE_DRIFT_TENANT` citation is wrong. Line 202 says it fires when edit-distance is >200 chars on >50% of recent_edit rows, citing `escalation-codes.md §2.5`; the catalogue instead says it fires on ≥N `ESC_VOICE_DRIFT` rows in a rolling window, and Ultraplan §6.2 lines 369-377 defines a 4-week average score drop. Fix line 202 to match the existing catalogue/Ultraplan trigger or create a new documented escalation.

4. Gate B audit fields and kill-criterion citation are unsupported. Line 167 invents `decision_log.payload.gate_b_outcome`, but autosend-safety-policy §7 lines 382-395 does not document that payload key; line 169 says this is kill-criterion §2 Trigger 5, but `v1.0-kill-criterion.md` lines 107-115 define Trigger 5 as autosend red-tier miscategorisation, not Diagnostic discovery-call conversion. Fix by documenting the Diagnostic outcome field in the relevant schema/audit spec and cite the correct kill criterion, or add a new one.
