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
session id: 019e5a13-5a82-79b1-b521-b6e290e57255
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

> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A's per-section citation subcheck hard-fails on any section missing its citation, per `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). ADR-006 establishes Gate A as per-section hard-fail; per-claim citation analysis is a separate post-launch quality metric outside Gate A (future W4 ADR + schema supplements). The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (target voice-classifier ≥ 0.75 per `common-voice.json`; v0 implementation warns + exits 0 when `IFOS_VOICE_CLASSIFIER_URL` is unreachable per §5 honesty note — W4 polish closes this to unconditional hard-fail) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).

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

**v0 source-coverage state:** Companies House data (§1, §10) is live via `@ifos/companies-house` MCP connector. Web-scraped pages (§2 footprint URLs, §8 careers-page pain signals) are live via `@ifos/web-scraper`. **LinkedIn deep-data sections (§3 job posts, §5 placement timeline, §7 employee skills, §9 competitor employee scan, §11 decision-maker profiles) currently use `@ifos/diagnostic-generator` stub-with-Companies-House-fallback citations** — Proxycurl integration deferred to W4 polish per ADR-005. Each LinkedIn-dependent section still emits ≥1 evidence link (per-section Gate A satisfied) by falling back to Companies House URLs, but the data depth is degraded vs the full-coverage W4 target.

| # | Section | What it contains | v0 source(s) | W4-polish source |
|---|---|---|---|---|
| 1 | **Firm signal** | Companies House data: registered name, company number, incorporation date, latest filed accounts (revenue band + headcount band), registered office, recent director changes, share-class moves | Companies House API ✅ | (no change) |
| 2 | **Online footprint** | Primary website URL + last-updated signal; LinkedIn company page URL + follower count + last-post recency; careers page URL + state (active / placeholder / 404) | Web-scraper (HEAD + first 200 lines) ✅ | + LinkedIn company-page Proxycurl fetch |
| 3 | **Sector + role-type mix** | Sectors actively recruiting for; ratio of permanent vs contract roles in last 90 days; technical-vs-commercial-vs-operational split | **v0: stub with Companies House fallback citation** | LinkedIn job posts + careers-page scrape |
| 4 | **Geography** | Office locations + current hiring locations + remote-vs-onsite-vs-hybrid mix | Companies House registered office ✅ | + LinkedIn job posts location field |
| 5 | **Deal-size band proxy** | Salary bands or day-rate ranges in job posts; level distribution; recent placements via LinkedIn timeline | **v0: stub with Companies House fallback** | LinkedIn job posts + Proxycurl employee timeline |
| 6 | **ICP fit vs target_patch** | Score 0-100 against tenant `target_patch.json` (sectors / geographies / size_bands / deal_size_band_gbp); per-dimension match/mismatch list | Tenant config + §1-§5 ✅ | (no change) |
| 7 | **Tech stack signals** | Technologies named in JDs + LinkedIn skills aggregated from current employees + tools mentioned in director posts | **v0: stub with Companies House fallback** | LinkedIn JDs + Proxycurl employee profiles |
| 8 | **Pain signals** | Phrases on careers page suggesting urgency / hiring pressure / workload concerns | Careers-page scrape ✅ | + LinkedIn director-post search + Glassdoor (opt-in) |
| 9 | **Competitor positioning** | Other recruitment firms visible in the candidate flow (previous-employer agencies; @firm tags; "Who's hiring this firm" inference) | **v0: stub with Companies House fallback** | LinkedIn profile + agency-tag search |
| 10 | **Recent activity** | LinkedIn company posts in last 90 days; press releases or news mentions; funding events visible on Companies House | Companies House filing history + web search ✅ | + LinkedIn company-page posts |
| 11 | **Decision-maker map** | Named people likely to be buyers: head of talent / CPO / hiring manager equivalents; LinkedIn profile URL per person; tenure | **v0: stub with Companies House director list** | LinkedIn employee search filtered by title |
| 12 | **Conversation opener** | 2-3 sentence cold outreach pitch tailored to §8 pain signals; written in consultant's voice (voice-classified); includes specific evidence anchor | LLM-generated; voice-classified ✅ (when classifier URL reachable; warn+exit 0 otherwise per §5) | (no change) |

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
- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.

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
I’ll verify the artefact against the live repo sources it cites: section order, bundle files, shared helpers, escalation catalogue, schema/policy references, and the claimed line anchors.
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
    16	> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A's per-section citation subcheck hard-fails on any section missing its citation, per `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). ADR-006 establishes Gate A as per-section hard-fail; per-claim citation analysis is a separate post-launch quality metric outside Gate A (future W4 ADR + schema supplements). The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (target voice-classifier ≥ 0.75 per `common-voice.json`; v0 implementation warns + exits 0 when `IFOS_VOICE_CLASSIFIER_URL` is unreachable per §5 honesty note — W4 polish closes this to unconditional hard-fail) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
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
    47	**v0 source-coverage state:** Companies House data (§1, §10) is live via `@ifos/companies-house` MCP connector. Web-scraped pages (§2 footprint URLs, §8 careers-page pain signals) are live via `@ifos/web-scraper`. **LinkedIn deep-data sections (§3 job posts, §5 placement timeline, §7 employee skills, §9 competitor employee scan, §11 decision-maker profiles) currently use `@ifos/diagnostic-generator` stub-with-Companies-House-fallback citations** — Proxycurl integration deferred to W4 polish per ADR-005. Each LinkedIn-dependent section still emits ≥1 evidence link (per-section Gate A satisfied) by falling back to Companies House URLs, but the data depth is degraded vs the full-coverage W4 target.
    48	
    49	| # | Section | What it contains | v0 source(s) | W4-polish source |
    50	|---|---|---|---|---|
    51	| 1 | **Firm signal** | Companies House data: registered name, company number, incorporation date, latest filed accounts (revenue band + headcount band), registered office, recent director changes, share-class moves | Companies House API ✅ | (no change) |
    52	| 2 | **Online footprint** | Primary website URL + last-updated signal; LinkedIn company page URL + follower count + last-post recency; careers page URL + state (active / placeholder / 404) | Web-scraper (HEAD + first 200 lines) ✅ | + LinkedIn company-page Proxycurl fetch |
    53	| 3 | **Sector + role-type mix** | Sectors actively recruiting for; ratio of permanent vs contract roles in last 90 days; technical-vs-commercial-vs-operational split | **v0: stub with Companies House fallback citation** | LinkedIn job posts + careers-page scrape |
    54	| 4 | **Geography** | Office locations + current hiring locations + remote-vs-onsite-vs-hybrid mix | Companies House registered office ✅ | + LinkedIn job posts location field |
    55	| 5 | **Deal-size band proxy** | Salary bands or day-rate ranges in job posts; level distribution; recent placements via LinkedIn timeline | **v0: stub with Companies House fallback** | LinkedIn job posts + Proxycurl employee timeline |
    56	| 6 | **ICP fit vs target_patch** | Score 0-100 against tenant `target_patch.json` (sectors / geographies / size_bands / deal_size_band_gbp); per-dimension match/mismatch list | Tenant config + §1-§5 ✅ | (no change) |
    57	| 7 | **Tech stack signals** | Technologies named in JDs + LinkedIn skills aggregated from current employees + tools mentioned in director posts | **v0: stub with Companies House fallback** | LinkedIn JDs + Proxycurl employee profiles |
    58	| 8 | **Pain signals** | Phrases on careers page suggesting urgency / hiring pressure / workload concerns | Careers-page scrape ✅ | + LinkedIn director-post search + Glassdoor (opt-in) |
    59	| 9 | **Competitor positioning** | Other recruitment firms visible in the candidate flow (previous-employer agencies; @firm tags; "Who's hiring this firm" inference) | **v0: stub with Companies House fallback** | LinkedIn profile + agency-tag search |
    60	| 10 | **Recent activity** | LinkedIn company posts in last 90 days; press releases or news mentions; funding events visible on Companies House | Companies House filing history + web search ✅ | + LinkedIn company-page posts |
    61	| 11 | **Decision-maker map** | Named people likely to be buyers: head of talent / CPO / hiring manager equivalents; LinkedIn profile URL per person; tenure | **v0: stub with Companies House director list** | LinkedIn employee search filtered by title |
    62	| 12 | **Conversation opener** | 2-3 sentence cold outreach pitch tailored to §8 pain signals; written in consultant's voice (voice-classified); includes specific evidence anchor | LLM-generated; voice-classified ✅ (when classifier URL reachable; warn+exit 0 otherwise per §5) | (no change) |
    63	
    64	**Gate A hard-fails** (per ADR-006 + §5 spec):
    65	
    66	- Fewer than 12 sections present
    67	- Any section with zero citation links (per-section citation subcheck; ADR-006-canonical)
    68	- Section 12 (conversation opener) failing voice-classifier with score < 0.75 *(v0 hard-fail when voice-classifier URL reachable; warn + exit 0 when URL unreachable per §5 honesty note; W4 polish closes to unconditional hard-fail with explicit `validate_check_skipped` audit row)*
    69	- Output exceeds 2000 words OR is under 400 words (length-discipline boundary)
    70	- PII (email-domain mismatch) detected outside firm boundary *(v0 hard-fail when firm-domain whitelist available; warn + exit 0 when whitelist absent per §5 honesty note; W4 polish closes to unconditional hard-fail. v0 PII regex covers emails only; phone-number PII detection deferred to W4 polish.)*
    71	
    72	**Per-step audit-row signatures** (per `decision_log`):
    73	- Step 10 report assembly → `hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")`
    74	- Step 11 (optional) operator notify → `hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)` — green tier per autosend-policy.yaml
    75	- Step 12 session close → `hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)` — green tier
    76	
    77	---
    78	
    79	## §4 — Workflow
    80	
    81	Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. The v0 cycle.sh implementation uses a generator-level pattern: a single call to `@ifos/diagnostic-generator` (`packages/diagnostic-generator/`) fetches all 12 sections in one process; cycle.sh emits decision-log rows at draft-write + report-write + render-action boundaries, not per-section. Per-section data acquisition is internal to the generator package and not separately audited at v0; W4 polish may add per-section telemetry.
    82	
    83	```
    84	0. Session start — invocation arrives via CLI ifosctl diagnostic
    85	   → context.sh hydrates: voice corpus + tone rules + recent edits + target_patch.json
    86	   → hh_decision_trigger("session_start", firm_name + sector_hint)
    87	
    88	1. Validate input (cycle.sh Step 1)
    89	   → cycle.sh checks: firm name length ≥ 2 chars
    90	   → on fail: hh_decision_action("diagnostic_input_invalid", ...) with
    91	     payload {escalation_code: ESC_INPUT_VALIDATION_FAIL, ...}
    92	   → exit 1 on validation failure
    93	
    94	2-11. Generator run (cycle.sh Steps 2-11 — single generator call)
    95	   → bash invokes @ifos/diagnostic-generator with firm + sector + target_patch flags
    96	   → generator fetches all 12 sections internally:
    97	     - §1 Companies House lookup (cached 7d per gotcha §6.2)
    98	     - §2 Online footprint via web-scraper + LinkedIn URL discovery
    99	     - §3-§5-§7 Job posts harvest + tech stack extraction
   100	     - §6 ICP fit scoring against tenant target_patch
   101	     - §7-§11 Director + employee scan
   102	     - §8 Pain signal extraction
   103	     - §10 Recent activity scan
   104	     - §12 Conversation opener (LLM-generated, voice-classified)
   105	   → generator writes complete draft Markdown to /tmp/diagnostic-<firm-slug>-<ISO-date>.draft.md
   106	   → on empty stdout: hh_decision_action("diagnostic_generator_empty", ...) with
   107	     payload {escalation_code: ESC_AGENT_OUTPUT_SHAPE, ...}; exit 1
   108	   → ESC_RATE_LIMIT_HIT raised internally by web-scraper / companies-house on 429
   109	   → ESC_VOICE_DRIFT raised internally by §12 LLM step if classifier <0.75 after 3 retries
   110	   → hh_decision_output("diagnostic_draft", "<draft_path>", "<firm> 12-section draft (pre-validate)")
   111	
   112	12. Validate (Gate A) (cycle.sh Step 12)
   113	   → bash invokes validate.sh against the draft path
   114	   → per-section citation hard-fail (ADR-006 Tier 1; no warn-only path)
   115	   → voice classifier + PII subchecks per §5 honesty note (warn-only on
   116	     upstream-unavailable in v0; W4 closes to hard-fail)
   117	   → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
   118	     with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE or
   119	     ESC_PII_LEAKAGE_RISK) and exit 1
   120	   → cycle.sh deletes draft on Gate A fail
   121	
   122	13. Atomic vault write + report-render audit row (cycle.sh Step 13)
   123	   → atomic mv -f /tmp/<draft> → /vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md
   124	   → chmod 600 on the report
   125	   → hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")
   126	   → hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)
   127	     — tier: green per autosend-policy.yaml (no external send; vault write only)
   128	
   129	14. Operator notification (optional, per --notify-via telegram flag) (cycle.sh Step 14)
   130	   → if telegram: send via curl to api.telegram.org with report path + 200-char summary
   131	     → hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)
   132	     → tier: green (operator-only Telegram; no customer-facing comms)
   133	   → if no flag: silent completion (consultant checks vault); no decision-log row
   134	   → cleanup.sh runs (drops transient LinkedIn cache per ToS gotcha §6.1)
   135	   → exit 0
   136	```
   137	
   138	---
   139	
   140	## §5 — Gates
   141	
   142	### Gate A — validate.sh (hard-fail before action)
   143	
   144	Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
   145	
   146	**Per ADR-006 (canonical interpretation of ULTRAPLAN §8.1 A1 line 496 Gate A clause "no claims unsupported by source data"):** Gate A's citation subcheck is per-section hard-fail (every one of the 12 sections has ≥1 evidence link). Per-claim citation analysis is a SEPARATE post-launch quality metric, NOT Gate A — to be authored as a future W4 ADR with schema supplements when the voice-classifier microservice ships + first pilot tenant accumulates ≥30 reports.
   147	
   148	**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
   149	
   150	- All 12 sections present in the assembled report (count + heading check) — **v0: hard-fails as specified**
   151	- Every section has ≥ 1 markdown link (regex `\[.+\]\(.+\)` per section) — **v0: hard-fails as specified**
   152	- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
   153	- Report length 400-2000 words — **v0: hard-fails as specified**
   154	- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
   155	- No PII (emails) outside the firm boundary. **v0 behavior:** validate.sh runs a generic email-regex pass and warns on any email found (no firm-domain whitelist implemented in v0; warn-only; exit 0). W4 polish adds the firm-domain whitelist + hard-fail behavior + `ESC_PII_LEAKAGE_RISK` emission. **v0 PII coverage:** emails only via regex; phone-number PII detection + whitelist enforcement deferred to W4 polish.
   156	
   157	### Gate B — Outcome threshold (success metric, not block)
   158	
   159	Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.
   160	
   161	Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
   162	
   163	---
   164	
   165	## §6 — Escalation codes
   166	
   167	Diagnostic uses these ESC codes from `agents/_shared/escalation-codes.md`:
   168	
   169	| Code | Trigger | Severity | Routing |
   170	|---|---|---|---|
   171	| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
   172	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall |
   173	| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn 429 | warn | operator_chat_id |
   174	| `ESC_INPUT_VALIDATION_FAIL` | Malformed firm name input (Step 1 validation) | warn | operator_chat_id |
   175	| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing OR generator produced empty stdout (Step 8 fallback) | warn | operator_chat_id |
   176	
   177	Diagnostic does NOT use:
   178	
   179	- `ESC_RENDERER_FAILED` — that code is owned by the `_renderer` sentinel (agent_name='_renderer') per catalogue §2.4; Diagnostic never fires it
   180	- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
   181	- `ESC_AUTOSEND_*` — Diagnostic's actions are `diagnostic_report_render` + `operator_notify_telegram` + `consultant_feedback` (all green tier per autosend-policy.yaml)
   182	- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention
   183	
   184	---
   185	
   186	## §7 — Voice + tone constraints
   187	
   188	Section 12 (conversation opener) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   189	
   190	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
   191	  - No "I hope this finds you well" or other generic openers
   192	  - No salary or commission anchors in cold outreach
   193	  - Specific evidence anchor required (not generic "great company")
   194	- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
   195	- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
   196	
   197	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   198	
   199	---
   200	
   201	## §8 — Production-readiness dependencies
   202	
   203	Full bundle (all 6 files + 3 fixtures) is built as of Day 19. Production readiness — i.e. running against a real pilot tenant — additionally requires the items below resolved to ✅.
   204	
   205	| Dependency | Source | Status |
   206	|---|---|---|
   207	| Renderer + `_shared/` substrate | Day-8 + Round-3 commits | ✅ Ratified (Round 3) |
   208	| Live VPS migration applied | `bash scripts/run-live-migration.sh` | ✅ Applied Day 12 |
   209	| Tenancy audit passes 12 invariants | `bash scripts/run-tenancy-audit.sh` | ✅ 24/24 invariants verified Day 12 |
   210	| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
   211	| `target_patch.json` for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI (per tenant-lifecycle.md §2) |
   212	| Voice corpus seeded for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI |
   213	| Companies House MCP connector | `packages/mcp-connectors/companies-house/` | ✅ Shipped Day 13; 13/13 tests passing |
   214	| LinkedIn read-only via web-scraper | `packages/utilities/web-scraper/` | ✅ Shipped Day 13; 12/12 tests passing (Proxycurl deferred to W4) |
   215	| Web scraper utility (HEAD + first-N-lines) | `packages/utilities/web-scraper/` | ✅ Shipped Day 13 |
   216	| `validate.sh` Gate A logic (12-section check) | `agents/recruitment/diagnostic/validate.sh` | ✅ Built; per-section subcheck hard-fail per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per §5 honesty note (W4 polish closes) |
   217	| `context.sh` hydration | `agents/recruitment/diagnostic/context.sh` | ✅ Built |
   218	| 3 fixtures with golden outputs | `agents/recruitment/diagnostic/fixtures/` | ✅ Built (01-primary + 02-edge-case + 99-voice-drift-canary) |
   219	| Other bundle files (cycle.sh, tools.yaml, cleanup.sh) | `agents/recruitment/diagnostic/` | ✅ All built |
   220	| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⚠ 10 rounds attempted; ADR-006 (Accepted) closed Cat-1 Gate A finding; residual mechanical findings tracked in disagreement doc Phase 4-5 |
   221	
   222	**Production-readiness gates:** all ⏸ items above must resolve to ✅ before first production render against a pilot tenant. Bundle code itself is complete.
   223	
   224	---
   225	
   226	## §9 — Status + open questions
   227	
   228	**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + Codex RATIFIED verdict + first production render.
   229	
   230	**Build state:** full bundle (cycle.sh, validate.sh, context.sh, tools.yaml, cleanup.sh, 3 fixtures) shipped Day 13-19. Codex review-agent-bundle ratification in progress (10+ rounds; ADR-006 closed the Cat-1/Cat-ζ Gate A finding; iterating on smaller mechanical findings).
   231	
   232	### Open questions for founder review
   233	
   234	| # | Question | Resolution path |
   235	|---|---|---|
   236	| Q1 | Is "12 sections" the right number? Ultraplan §8.1 A1 says "12 required sections" but doesn't enumerate. This document proposes a 12-section list (§3); founder may want to revise. | Founder reviews §3 table; can split/merge sections. Lands as Edit in next commit. |
   237	| Q2 | Should §11 (decision-maker map) be a separate section OR rolled into §3 + §4 + §5 + §7 as a sub-row? Currently named as a separate section. | Founder review at agent.md ratification. |
   238	| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | Resolved at W3 start before Companies House + LinkedIn MCP connectors authored. Founder + Claude decide together. |
   239	| Q4 | Gate B (30% discovery-call-to-report ratio) measured how? Manual tagging by consultant OR auto-detection via Bullhorn calendar links? | v1.0 manual tagging via Telegram resolution; v1.1 auto-detection. |
   240	| Q5 | What's the "firm-slug" canonical form for the output filename? Companies House registration number? URL-slugified firm name? | Recommend Companies House number for stability; canonical-slug fallback for non-UK firms (v1.1+). |
   241	| Q6 | Should §10 (recent activity) include Glassdoor reviews? ToS implications. | Per gotcha §6 below: caution; default OFF for v1.0; explicit founder enable for v1.1+. |
   242	
   243	### Gotchas (carried forward from Ultraplan §8.1 A1)
   244	
   245	1. **LinkedIn ToS — cannot store profile data beyond the audit.** Profile fetches are cached only for the duration of the report generation (typ. 10-15 min). After report writes to vault, raw profile data is dropped from agent memory + no persistence in Postgres.
   246	2. **Companies House rate limits — cache aggressively.** Free tier is 600 requests per 5-minute window per IP. Cache responses for 7 days per (company_number) key. Pre-emptive 60s backoff on first 429.
   247	3. **Glassdoor scraping — uncertain ToS compatibility.** Default OFF for v1.0. Per Q6 above.
   248	
   249	---
   250	
   251	## §10 — When this document ratifies
   252	
   253	Per `.codex/ratification/review-agent-bundle.md` (skill built Day 19; commit `825ebd4`): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.
   254	
   255	Status flips to Accepted when:
   256	- Codex Round-3+ ratifies the full bundle
   257	- Founder approves §3's 12-section list as canonical
   258	- First production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
   259	- Gate B baseline measurement begins (30% target; 4-week window)
   260	

exec
/bin/zsh -lc "rg --files agents/recruitment/diagnostic agents/_shared docs/decisions docs | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
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
docs/design-mockups/brain-ui-decisions-feed-light-v01.html
docs/architecture/tenancy-invariants.md
docs/architecture/architecture-cohesion-review.md
docs/architecture/agent-bundle-renderer-design.md
docs/architecture/cortexos-kb-surface-investigation.md
docs/architecture/cortexos-primitive-status.md
docs/architecture/vault-concurrency.md
docs/architecture/second-brain-design.md
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
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
agents/_shared/README.md
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
docs/runbooks/day-4-provisioning.md
docs/runbooks/operational-hygiene-protocol.md
docs/runbooks/tenant-lifecycle.md
docs/runbooks/pii-purge-operational-pattern.md
docs/build-brief/00-MASTER-BRIEF.md
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/decisions/sequencing-target.md
docs/decisions/bullhorn-integration-path.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
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
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md
docs/artefacts/diagnostic-hays-plc-2026-05-24.md
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md
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
agents/recruitment/diagnostic/cleanup.sh
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml
agents/recruitment/diagnostic/fixtures/01-primary.yaml
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml
agents/recruitment/diagnostic/cycle.sh
agents/recruitment/diagnostic/README.md
agents/recruitment/diagnostic/tools.yaml
agents/recruitment/diagnostic/validate.sh
agents/recruitment/diagnostic/context.sh
agents/recruitment/diagnostic/agent.md
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md
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

exec
/bin/zsh -lc 'rg -n "Diagnostic|A1|W3-4|W4-5|30%|12 required|Gate A|no claims|Trigger 8|Trigger 1|consultant_feedback|diagnostic_report_render|operator_notify_telegram|ESC_VOICE_DRIFT|ESC_PII_LEAKAGE_RISK|ESC_RATE_LIMIT_HIT|ESC_INPUT_VALIDATION_FAIL|ESC_AGENT_OUTPUT_SHAPE|ESC_VOICE_DRIFT_TENANT|hh_load_recent_edits|hh_load_voice_samples|hh_load_tone_rules|diagnostic|Gate B|IFOS_VOICE_CLASSIFIER_URL|validate_check_skipped" docs agents packages scripts .codex CLAUDE.md 2>/dev/null' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
scripts/run-live-migration.sh:319:hh_decision_action "diagnostic_report_render" "candidate:test" "hash-live-1" "live smoke green" && _pass "green action returned 0"
scripts/run-live-migration.sh:368:# hh_load_tone_rules — should return empty rules + source=db
scripts/run-live-migration.sh:369:TONE_OUT=$(hh_load_tone_rules concierge 2>&1)
scripts/run-live-migration.sh:371:  _pass "hh_load_tone_rules returns empty rules from DB"
scripts/run-live-migration.sh:373:  _fail "hh_load_tone_rules unexpected shape" "got: ${TONE_OUT}"
scripts/run-live-migration.sh:376:# hh_load_voice_samples — no IFOS_VL_QUERY_VECTOR set, falls back
scripts/run-live-migration.sh:377:VOICE_OUT=$(hh_load_voice_samples "candidate-outreach" 5 2>&1)
scripts/run-live-migration.sh:379:  _pass "hh_load_voice_samples fallback path works (no embedded vector)"
scripts/run-live-migration.sh:381:  _fail "hh_load_voice_samples unexpected shape" "got: ${VOICE_OUT}"
scripts/run-live-migration.sh:384:# hh_load_recent_edits — empty in fresh tenant
scripts/run-live-migration.sh:385:EDITS_OUT=$(hh_load_recent_edits 30 concierge 2>&1)
scripts/run-live-migration.sh:387:  _pass "hh_load_recent_edits returns empty edits from DB"
scripts/run-live-migration.sh:389:  _fail "hh_load_recent_edits unexpected shape" "got: ${EDITS_OUT}"
agents/_shared/autosend-policy.yaml:29:  diagnostic_report_render:
agents/_shared/autosend-policy.yaml:31:    agent: diagnostic
agents/_shared/autosend-policy.yaml:65:  operator_notify_telegram:
agents/_shared/autosend-policy.yaml:107:  consultant_feedback:
agents/_shared/autosend-policy.yaml:109:    agent: diagnostic
agents/_shared/autosend-policy.yaml:110:    reason: "Gate B feedback row written when consultant tags a Diagnostic report as booked|not-booked via Telegram (/diagnostic-feedback <report-id> ...) or Brain UI button. agent_name='diagnostic'; phase='action'; payload includes report_id + outcome. Internal-only; no external send."
agents/_shared/autosend-policy.yaml:116:    reason: "Internal audit row written by validate.sh when Gate A enforcement fails. Carries the specific ESC code (e.g. ESC_AGENT_OUTPUT_SHAPE | ESC_PII_LEAKAGE_RISK) in the payload; the action itself is just the audit-row write, not an external send. Each agent's validate.sh emits this row before exit 1."
agents/_shared/autosend-policy.yaml:119:  diagnostic_input_invalid:
agents/_shared/autosend-policy.yaml:121:    agent: diagnostic
agents/_shared/autosend-policy.yaml:122:    reason: "Internal audit row written by cycle.sh Step 1 when firm-name validation fails. Carries ESC_INPUT_VALIDATION_FAIL payload; just the audit-row write, not external send."
agents/_shared/autosend-policy.yaml:125:  diagnostic_generator_empty:
agents/_shared/autosend-policy.yaml:127:    agent: diagnostic
agents/_shared/autosend-policy.yaml:128:    reason: "Internal audit row written by cycle.sh when @ifos/diagnostic-generator produces empty stdout. Carries ESC_AGENT_OUTPUT_SHAPE payload."
agents/_shared/autosend-policy.yaml:137:  diagnostic_cleanup:
agents/_shared/autosend-policy.yaml:139:    agent: diagnostic
agents/_shared/autosend-policy.yaml:264:  diagnostic_email_send:
agents/_shared/autosend-policy.yaml:266:    agent: diagnostic
agents/_shared/autosend-policy.yaml:268:    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
agents/_shared/autosend-policy.yaml:271:  diagnostic_calendar_invite:
agents/_shared/autosend-policy.yaml:273:    agent: diagnostic
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:257:          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
.codex/ratification/review-schema-change.md:80:`agent_access_matrix:` must list every v1.0 agent (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) + state R / W / R+W / none for every entity_type.
.codex/ratification/review-schema-change.md:86:- `Diagnostic` must have `none` or `R` for all entities — Diagnostic doesn't write to Bullhorn per `sequencing-target.md` §2.1
.codex/ratification/review-agent-bundle.md:11:## §1 — agent.md required-section structure (per ADR-003 + Diagnostic precedent)
.codex/ratification/review-agent-bundle.md:18:| §1 | Output contract | One-paragraph screenshot per master brief §1 Rule 1. Names WHAT the agent produces in a single paragraph, readable cold | Missing; >3 paragraphs; doesn't name vault write path; doesn't name Gate A + Gate B thresholds |
.codex/ratification/review-agent-bundle.md:20:| §3 | Output shape | Specific to agent. Diagnostic: 12 sections. Janitor: day-30 report + Bullhorn writes. Cash Conductor: reconciliation rows + chase drafts + weekly report | Missing; doesn't name the artefact paths; doesn't name the decision_log audit-row signature for each output |
.codex/ratification/review-agent-bundle.md:22:| §5 | Gates | Gate A: validate.sh hard-fail conditions. Gate B: outcome success threshold + measurement mechanism | Missing; Gate A conditions not testable; Gate B threshold not cited to ULTRAPLAN/master brief; Gate A weaker than §1 output contract |
.codex/ratification/review-agent-bundle.md:38:2. **ULTRAPLAN §8.1 A-N lines X-Y** for spec detail (Diagnostic = A1 lines 487+; Janitor = A2 lines 501+; Scribe = A3 lines 515+; Cash Conductor = A4 lines 529+; Sourcing Scout = A5 lines 543+; Concierge = A6 lines 557+). Verify the cited lines contain the cited content.
.codex/ratification/review-agent-bundle.md:50:- Sentinel agent_names invented without registering in the catalogue (e.g. `_consultant_feedback` without an entry in escalation-codes.md or a documented sentinel registry)
.codex/ratification/review-agent-bundle.md:51:- Kill-criterion Trigger references swapped (Trigger 5 cited when content describes Trigger 8 territory)
.codex/ratification/review-agent-bundle.md:59:agent.md files come in two flavours per the Diagnostic precedent:
.codex/ratification/review-agent-bundle.md:75:**Production-ready (Status: Accepted OR In Force)** — written AFTER bundle files exist + pass tests. Diagnostic at Day-13 + Day-19 polish is production-ready. Additional requirements:
.codex/ratification/review-agent-bundle.md:84:- §5 Gate A conditions don't match validate.sh implementation
.codex/ratification/review-agent-bundle.md:121:- Output contract doesn't name vault path OR Gate A/B thresholds
.codex/ratification/review-agent-bundle.md:124:- Gate A weaker than §1 output contract claims
.codex/ratification/review-agent-bundle.md:128:- "ESC code list omits ESC_RATE_LIMIT_HIT which Step N implies — suggest adding"
.codex/ratification/review-agent-bundle.md:129:- "§8 prereq list missing the voice classifier microservice as W4-5 dependency"
.codex/ratification/review-agent-bundle.md:135:## §6 — Special case: Diagnostic agent.md
.codex/ratification/review-agent-bundle.md:137:Diagnostic was scaffold-ratified at Day-11 (Round 3 RATIFIED) + production-shape polished at Day-13 (commits `97a57a2` + `2688b6a`) + Day-19 remediation (commit `6e0cb86`). Codex Round 4 Phase 1 hit hard ceiling — see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` for the 5-issue disposition.
.codex/ratification/review-agent-bundle.md:139:When re-ratifying Diagnostic agent.md with THIS skill (not review-architecture-decision):
.codex/ratification/review-agent-bundle.md:143:- If Issues 1-4 resolve via the founder arbitration recommendations in the disagreement doc (which I'd accept as the right framing for v0), then Diagnostic agent.md should RATIFY under this skill.
.codex/ratification/SKILL.md:26:4. **Quality gates before features** — Gate A (`validate.sh` hard-fails) + Gate B (`decision_log` mandatory writes) + autosend-safety-policy tier dispatch. Does this artefact bypass or weaken any gate?
packages/diagnostic-generator/src/generate.ts:1:// Top-level Diagnostic report generator. Composes the 12 sections,
packages/diagnostic-generator/src/generate.ts:44:    `# Diagnostic report — ${firmName}`,
packages/diagnostic-generator/src/generate.ts:46:    `**Generated:** ${isoDate} by Intel Force OS Diagnostic agent (v0 — pre-W3 build).`,
packages/diagnostic-generator/src/cli.ts:12:  .name("ifos-diagnostic-generate")
packages/diagnostic-generator/src/cli.ts:13:  .description("Generate a 12-section Diagnostic report for a UK recruitment firm")
packages/diagnostic-generator/src/cli.ts:53:  process.stderr.write(`ifos-diagnostic-generate: ${(err as Error).message}\n`);
agents/_shared/escalation-codes.md:120:#### `ESC_VOICE_DRIFT`
agents/_shared/escalation-codes.md:129:- **Trigger:** Dedup confidence `≥ 0.85` per Ultraplan §8.1 line 511 A2 Gate A; human-review-required cases
agents/_shared/escalation-codes.md:148:#### `ESC_PII_LEAKAGE_RISK`
agents/_shared/escalation-codes.md:150:- **Trigger:** Agent output references PII outside the firm boundary (cross-tenant PII detected by `validate.sh` Gate A or RLS check)
agents/_shared/escalation-codes.md:156:#### `ESC_RATE_LIMIT_HIT`
agents/_shared/escalation-codes.md:170:#### `ESC_VOICE_DRIFT_TENANT`
agents/_shared/escalation-codes.md:172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
agents/_shared/escalation-codes.md:177:#### `ESC_INPUT_VALIDATION_FAIL`
agents/_shared/escalation-codes.md:184:#### `ESC_AGENT_OUTPUT_SHAPE`
agents/_shared/escalation-codes.md:186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
agents/_shared/escalation-codes.md:312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:379:- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
agents/_shared/escalation-codes.md:383:- **Note:** Local Gate B is a leading metric for agent quality; consecutive misses inform per-agent quality review. Not tied to a kill-criterion trigger in v1.0 (per disagreement-doc Cat-3 disposition).
agents/_shared/escalation-codes.md:432:- **Severity:** warn — aggregated to Gate B (not a per-event block)
agents/_shared/escalation-codes.md:436:  - `draft_generation`: lifecycle event → draft generated >30 min (per ULTRAPLAN A6 line 566; aggregated to Gate B per Concierge §1 disposition rather than per-event hard fail)
agents/_shared/hook-helpers.sh:179:# a customer-visible artefact (Gate B per master brief §1 Rule 4).
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
docs/verticals/recruitment/vertical-schema.yaml:14:#       + Day-5 v1.0-kill-criterion.md (Trigger 1 acquisition-by-2026-06-03)
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
docs/verticals/recruitment/vertical-schema.yaml:280:      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
docs/verticals/recruitment/vertical-schema.yaml:671:  Diagnostic:
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
docs/verticals/recruitment/vertical-schema.yaml:758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
docs/verticals/recruitment/vertical-schema.yaml:893:    target: Week-4-end (~2026-06-21 if Week 1 starts 2026-05-21 per Day-5 kill criterion §2 Trigger 1 calendar).
scripts/run-tenancy-audit.sh:585:printf 'Foundation is correct. Diagnostic agent build can proceed with confidence.\n'
packages/diagnostic-generator/src/sections/online-footprint.ts:62:      // Remember the LAST status seen for diagnostic reporting if nothing matches
packages/diagnostic-generator/src/sections/stubs.ts:4:// Gate A V2 (≥1 link per section) passes.
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:88:**Not tested:** the full 4h wall-clock timeout in production. First Diagnostic agent build (Week 3) is the natural place to exercise this — Diagnostic uses `diagnostic_email_send` (orange tier, PT4H timeout).
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
agents/_shared/README.md:161:Production rollout (other tenants) waits for Codex ratification of v0.2 + Diagnostic + Janitor verification of the schema against real Bullhorn data (master brief §6 Day 6 Q3 trigger from v0.1).
packages/diagnostic-generator/src/sections/firm-signal.ts:83:      `No active Companies House registration found for **${firmName}**. Diagnostic proceeded against publicly visible non-CH signals only.`,
packages/utilities/web-scraper/package.json:5:  "description": "IFOS web scraper utility — HTTP HEAD + first-N-lines fetch + cache + robots.txt. Used by Diagnostic agent §4 Step 3+6+8 per agents/recruitment/diagnostic/tools.yaml.",
packages/diagnostic-generator/src/sections/conversation-opener.ts:6:// (W4-5 polish wires it; for now §12 ships LLM-generated text without
packages/diagnostic-generator/src/sections/conversation-opener.ts:25:  // Voice corpus context (optional; W4-5 polish wires real corpus)
packages/diagnostic-generator/src/sections/conversation-opener.ts:134:  const systemPrompt = `You are writing the §12 "Conversation opener" section of a UK recruitment-firm diagnostic report. Output: a 2-3 sentence cold outreach opener written in the consultant's voice. Must be evidence-anchored to a specific signal from the report's §1-§11 evidence (Companies House data, careers-page quotes, LinkedIn signals, recent filings). NOT generic.
packages/diagnostic-generator/src/sections/conversation-opener.ts:178:  // section still has a Markdown link (Gate A V2 requirement)
packages/diagnostic-generator/src/sections/conversation-opener.ts:259:      "**Generation:** LLM-driven (Claude API + evidence context). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0 scaffold; W4-5 polish wires real classifier.",
packages/diagnostic-generator/src/sections/conversation-opener.ts:263:      "**Generation:** deterministic anchor-based fallback (ANTHROPIC_API_KEY not set OR LLM call failed). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0; W4-5 polish wires both LLM key + classifier.",
packages/utilities/web-scraper/src/client.ts:9:// as an automated client via the more specific "IFOS-Diagnostic/0.1"
packages/utilities/web-scraper/src/client.ts:12:  "IFOS-Diagnostic/0.1 (+https://intelforce.io/contact)";
packages/diagnostic-generator/package.json:2:  "name": "@ifos/diagnostic-generator",
packages/diagnostic-generator/package.json:5:  "description": "Diagnostic agent report generator — composes web-scraper + companies-house into a 12-section Markdown report for a UK recruitment firm.",
packages/diagnostic-generator/package.json:10:    "ifos-diagnostic-generate": "./dist/cli.js"
packages/utilities/web-scraper/README.md:3:IFOS web scraper utility for Diagnostic agent §4 Step 3 + 6 + 8 per `agents/recruitment/diagnostic/tools.yaml`.
packages/utilities/web-scraper/README.md:13:- **No JavaScript execution.** Lightweight HTTP only. JS-heavy sites return their server-rendered HTML (often a "JavaScript required" placeholder) — graceful degradation per Diagnostic gotcha §6.1.
packages/utilities/web-scraper/README.md:18:- **User agent:** `Mozilla/5.0 (compatible; IFOS-Diagnostic/0.1; +https://intelforce.io/bot)`. Identifies us; not deceptive.
packages/utilities/web-scraper/README.md:22:- **Timeout / connection refused** → returns `null`; logs warning; caller treats as "no signal" per Diagnostic gotcha §6.1.
packages/utilities/web-scraper/README.md:51:v0.1 — Diagnostic v1.0 dependency per `agents/recruitment/diagnostic/tools.yaml`.
packages/diagnostic-generator/README.md:1:# @ifos/diagnostic-generator
packages/diagnostic-generator/README.md:3:Composes `@ifos/web-scraper` + `@ifos/companies-house` into a 12-section Markdown report for a UK recruitment firm. Called by `agents/recruitment/diagnostic/cycle.sh` after context.sh hydrates the session and before validate.sh runs Gate A.
packages/diagnostic-generator/README.md:8:node packages/diagnostic-generator/dist/cli.js \
packages/diagnostic-generator/README.md:15:Writes the Markdown report to stdout. `cycle.sh` captures it to `/tmp/diagnostic-draft-<slug>-<pid>.md`.
packages/diagnostic-generator/README.md:34:This is the **Day-13 v0 build** per `docs/operations/goal-option-c-diagnostic-end-to-end.md`. Limitations:
packages/diagnostic-generator/README.md:64:v0.1 — Diagnostic W3 pre-build per `agents/recruitment/diagnostic/agent.md` + `docs/operations/goal-option-c-diagnostic-end-to-end.md`.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:79:-- is the indexed surface for hh_load_voice_samples semantic retrieval.
agents/_shared/tests/test-hook-helpers.sh:109:  hh_decision_output "diagnostic_report" "/vault/x/y.md"
agents/_shared/tests/test-hook-helpers.sh:113:    && _assert_contains "${row}" '"output_type":"diagnostic_report"'
agents/_shared/tests/test-hook-helpers.sh:118:test_lookup_green() { local t; t=$(autosend_policy_lookup "diagnostic_report_render"); _assert_eq "green" "${t}" "green"; }
agents/_shared/tests/test-hook-helpers.sh:132:  hh_decision_action "diagnostic_report_render" "candidate:test" "abc123" "test preview"
packages/diagnostic-generator/tests/conversation-opener.test.ts:48:    // Has evidence link (Gate A V2)
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
packages/harness/cortextos/community/catalog.json:222:      "name": "system-diagnostics",
packages/harness/cortextos/community/catalog.json:227:      "tags": ["diagnostics", "debug", "troubleshooting", "health"],
packages/harness/cortextos/community/catalog.json:230:      "install_path": "community/skills/system-diagnostics",
packages/diagnostic-generator/tests/online-footprint.test.ts:20:describe("@ifos/diagnostic-generator — online-footprint slug fallback", () => {
packages/harness/cortextos/src/telegram/api.ts:87:  // diagnostic emitted at most once per chat_id per process lifetime.
agents/recruitment/cash-conductor/README.md:22:- `validate.sh` — Gate A (invoice + amount + contact triple check + paid-in-24h block per ULTRAPLAN A4 line 539)
agents/recruitment/cash-conductor/README.md:27:- `fixtures/99-chase-paid-canary.yaml` — adversarial: chase proposed for invoice paid 12h ago — Gate A must reject (per ULTRAPLAN A4 line 539 verbatim)
packages/diagnostic-generator/tests/generate.test.ts:25:describe("@ifos/diagnostic-generator", () => {
packages/diagnostic-generator/tests/generate.test.ts:68:      expect(md).toMatch(/^# Diagnostic report — Charterhouse Partners/m);
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) consultant-approved orange-tier payment-chase email drafts queued to Concierge for send (Concierge handles the actual send; Cash Conductor only drafts), and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO Bullhorn dependency — Cash Conductor operates entirely against the tenant's accounting + Open Banking stack, making it the most-independent v1.0 agent (per ADR-005 §5.1: this independence is its strategic value when Bullhorn paths are delayed). Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are orange-tier (`xero_reminder_draft_internal` per `autosend-safety-policy.yaml` line 104; consultant approval required before send via Concierge); reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:127:| 2 | **DSO trend** | Days-Sales-Outstanding metric this week vs prior-week vs month-0 baseline; Gate B tracking |
agents/recruitment/cash-conductor/agent.md:203:   → ESC_VOICE_DRIFT if classifier <threshold after 3 retries
agents/recruitment/cash-conductor/agent.md:205:9. Chase-draft validation (Gate A specifics)
agents/recruitment/cash-conductor/agent.md:210:   → ESC_AGENT_OUTPUT_SHAPE on any miss (output-shape violation: chase cannot
agents/recruitment/cash-conductor/agent.md:211:     conform to its Gate A contract — invoice/amount/contact mismatch OR paid-
agents/recruitment/cash-conductor/agent.md:214:     pipeline is orange-tier, so a Gate A miss is output-shape failure, not
agents/recruitment/cash-conductor/agent.md:242:    → compute DSO metric (Gate B tracking)
agents/recruitment/cash-conductor/agent.md:259:### Gate A — validate.sh (hard-fail before action)
agents/recruitment/cash-conductor/agent.md:271:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint: chase cannot meet its Gate A contract); draft stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/cash-conductor/agent.md:273:**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/cash-conductor/agent.md:275:### Gate B — Outcome threshold (FD-tier closer metric)
agents/recruitment/cash-conductor/agent.md:283:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:299:| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:300:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in chase body | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:301:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss (invoice/amount/contact validation OR paid-invoice precondition violated) — output-shape constraint per catalogue line 184 | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:303:| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:309:- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
agents/recruitment/cash-conductor/agent.md:310:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Cash Conductor's Gate A misses are output-shape failures, not schema-field violations
agents/recruitment/cash-conductor/agent.md:311:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Cash Conductor fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/cash-conductor/agent.md:319:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:323:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/cash-conductor/agent.md:324:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
agents/recruitment/cash-conductor/agent.md:337:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
agents/recruitment/cash-conductor/agent.md:350:| `validate.sh` Gate A logic | Build at W7 start (~1 day; complex due to 4 validators) | ⏸ |
agents/recruitment/cash-conductor/agent.md:355:**Per ADR-005 §5.1 pull-forward provision:** if Bullhorn Sub-decisions A+B answers delay past 2026-06-10, Cash Conductor may be pulled forward from W7-8 to W4-5 because it has zero Bullhorn dependency. The other prerequisites (accounting + Open Banking commercial signups) remain founder-action gates regardless.
agents/recruitment/scribe/README.md:18:- `validate.sh` — Gate A (≥3 fields × confidence ≥0.6 + voice ≥0.75 + PII boundary)
packages/harness/cortextos/package-lock.json:415:      "integrity": "sha512-+A1NJmfM8WNDv5CLVQYJ5PshuRm/4cI6WMZRg1by1GwPIQPCTs1GLEUHwiiQGT5zDdyLiRM/l1G0Pv54gvtKIg==",
packages/harness/cortextos/package-lock.json:1401:      "integrity": "sha512-RAjXjP/8c6ZtzatZcA1RaQr6O1TRhzC+adn8YZDnChliZHviqIjmvFwHcxi4JKPSDAt6Uhf/7vqcBzQJy0PDJg==",
packages/harness/cortextos/package-lock.json:1818:      "integrity": "sha512-aCj4O5wKyszjMmDT4tZj93kxyydN/K5zPWSCe6/0AV/AA1pqe5ZBIw0a2ZfPQV7lL5/yb5HsUreJ6UFAF1tEQw==",
packages/harness/cortextos/package-lock.json:2065:      "integrity": "sha512-7tN6rFgBlMgpBML5j8typ92BKFi2sFQvIdpAqLA2beia5avZDrMs0FLZiM5etShWq5irVyGcGMEA1jcDaK7A/Q==",
packages/harness/cortextos/package-lock.json:2885:      "integrity": "sha512-bzyZ1e88w9O1iNJbKnOlvYTrWPDl46O1bG0D3XInv+9tkPrxrN8jUUTiFlDkkmKWgn1M6CfIA13SuGqOa9Korw==",
packages/utilities/web-scraper/pnpm-lock.yaml:388:    resolution: {integrity: sha512-+A1NJmfM8WNDv5CLVQYJ5PshuRm/4cI6WMZRg1by1GwPIQPCTs1GLEUHwiiQGT5zDdyLiRM/l1G0Pv54gvtKIg==}
packages/utilities/web-scraper/pnpm-lock.yaml:575:    resolution: {integrity: sha512-FJHFfqpKUI3A10WrWKiFbBZ7yVbGT4q4B5o1qKFFojqpaYoh9LrQgqWCmmcxQzVSXYtyB5bzkXrYzlHTs21MYA==}
packages/utilities/web-scraper/pnpm-lock.yaml:630:    resolution: {integrity: sha512-QVTUovf40zgTqlFVrKA1uXMVvU2QWEFWfAH8Wdc48IxLvrJMQVMBRjuQyUpzZCDkakImib9eVazbWlC6ksWtJw==}
packages/utilities/web-scraper/pnpm-lock.yaml:818:    resolution: {integrity: sha512-//nshmD55c46FuFw26xV/xFAaB5HF9Xdap7HJBBnrKdAd6/GxDBaNA1870O79+9ueg61cZLSVc+OaFlfmObYVQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:973:    resolution: {integrity: sha512-o5a9xKjbtuhY6Bi5S3+HvbRERmouabWbyUcpXXUA1u+GNUKoROi9byOJ8M0nHbHYHkYICiMlqxkg1KkYmm25Sw==}
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:70:Minimum 3 fields extracted per call (Gate A). Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):
agents/recruitment/scribe/agent.md:109:Length cap: 800 words. Voice-classified (≥0.75); falls back to "needs consultant review" placeholder if classifier persistently fails (ESC_VOICE_DRIFT).
agents/recruitment/scribe/agent.md:137:   → ESC_INPUT_VALIDATION_FAIL on signature mismatch; reject with 401
agents/recruitment/scribe/agent.md:149:   → ESC_PII_LEAKAGE_RISK if transcript references non-tenant PII
agents/recruitment/scribe/agent.md:157:   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
agents/recruitment/scribe/agent.md:165:   → discard fields confidence <0.6 (per Gate A)
agents/recruitment/scribe/agent.md:175:   → ESC_VOICE_DRIFT if score <0.75 after 3 retries
agents/recruitment/scribe/agent.md:183:   → drop invalid; require ≥3 valid (per Gate A; failure = ESC_SCHEMA_VIOLATION
agents/recruitment/scribe/agent.md:203:   → if elapsed > 300 (5 min): info-level (counted against Gate B 90%)
agents/recruitment/scribe/agent.md:212:### Gate A — validate.sh (hard-fail before action)
agents/recruitment/scribe/agent.md:224:Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/scribe/agent.md:226:**Honesty note (per bilateral-disposition Cat-5):** Scribe `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W6 build slice. The W6 build delivers `agents/recruitment/scribe/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/scribe/agent.md:228:### Gate B — Outcome thresholds (success metrics, not block)
agents/recruitment/scribe/agent.md:236:Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
agents/recruitment/scribe/agent.md:251:| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:253:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in transcript or note | **blocking** | operator + ifos_oncall |
agents/recruitment/scribe/agent.md:254:| `ESC_INPUT_VALIDATION_FAIL` | Webhook signature mismatch (Step 1) | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:255:| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:257:| `ESC_SCRIBE_SLA_MISS` | Webhook-to-Bullhorn-write >10 min (Gate B miss) | info | (logged; aggregated to Gate B metric) |
agents/recruitment/scribe/agent.md:258:| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:272:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:276:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:277:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:290:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
agents/recruitment/scribe/agent.md:301:| `validate.sh` Gate A logic | Build at W6 start (~0.5 day) | ⏸ |
agents/recruitment/scribe/agent.md:305:| LLM extraction + voice-classifier microservice | W4-5 polish | ⏸ |
agents/recruitment/scribe/agent.md:325:| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |
packages/harness/cortextos/dashboard/src/lib/db.ts:205:/** Get row counts for all tables (useful for diagnostics) */
packages/agents-runtime/_shared/common-voice.json:26:      "description": "Phrases that trigger ESC_VOICE_DRIFT before classifier scoring."
packages/agents-runtime/_shared/common-voice.json:33:      "description": "Per bullhorn-integration-path.md §4.1 A6 Concierge gate; voice classifier scores below this fail Gate A."
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
packages/agents-runtime/_shared/common-voice.json:46:      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."
agents/recruitment/sourcing-scout/README.md:18:- `validate.sh` — Gate A (5-15 candidates + contact method + ≥50 words + DNC + voice ≥0.75)
agents/recruitment/sourcing-scout/agent.md:16:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate flagged "do not contact" in tenant vault (per ULTRAPLAN A5 line 552 verbatim). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:90:## Diagnostic + exception list
agents/recruitment/sourcing-scout/agent.md:98:Voice-classified content: only the per-candidate match rationale (Step 9). Voice classifier ≥0.75 against tenant style. Rationale that fails after 3 retries → ESC_VOICE_DRIFT → candidate dropped from list + flagged in exception list.
agents/recruitment/sourcing-scout/agent.md:126:   → if 2+ sources fail auth: ESC_AGENT_OUTPUT_SHAPE (Sourcing Scout cannot
agents/recruitment/sourcing-scout/agent.md:141:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
agents/recruitment/sourcing-scout/agent.md:149:   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
agents/recruitment/sourcing-scout/agent.md:155:   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:162:   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:190:   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
agents/recruitment/sourcing-scout/agent.md:193:10. Output assembly + Gate A validation
agents/recruitment/sourcing-scout/agent.md:198:    → if any condition fails: ESC_AGENT_OUTPUT_SHAPE (output-shape violation
agents/recruitment/sourcing-scout/agent.md:217:### Gate A — validate.sh (hard-fail before action)
agents/recruitment/sourcing-scout/agent.md:229:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation per catalogue line 184); draft to `/tmp`; operator review.
agents/recruitment/sourcing-scout/agent.md:231:**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/sourcing-scout/agent.md:233:### Gate B — Outcome threshold (success metric, not block)
agents/recruitment/sourcing-scout/agent.md:239:Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
agents/recruitment/sourcing-scout/agent.md:255:| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:257:| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:259:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:260:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:267:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
agents/recruitment/sourcing-scout/agent.md:268:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/sourcing-scout/agent.md:276:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:281:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:282:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
agents/recruitment/sourcing-scout/agent.md:295:| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
agents/recruitment/sourcing-scout/agent.md:310:| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:327:| Q1 | All three external sources required for v1.0? Reed + CV-Library are UK-recruitment-specific; Proxycurl is LinkedIn-via-API. Could v1.0 ship with Bullhorn + Proxycurl only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
agents/recruitment/sourcing-scout/agent.md:331:| Q5 | Gate B 6-of-10 metric — measured via consultant feedback. Brain UI v1.0 doesn't have feedback UX yet. Telegram reply? | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful". v1.1: Brain UI button. |
agents/recruitment/sourcing-scout/agent.md:349:- Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B UX)
agents/recruitment/sourcing-scout/agent.md:356:- Gate B feedback loop operational (Telegram OR Brain UI)
packages/agents-runtime/_shared/common-target-patch.json:5:  "description": "Tenant's commercial sweet spot: sectors, geography, deal sizes, allow/block lists. Read by Sourcing Scout (W9) + Diagnostic (W3-4). Per PRODUCT-SPEC §5.3 line 363.",
packages/agents-runtime/_shared/common-target-patch.json:38:      "description": "Bands surface in Diagnostic ICP scoring + Sourcing Scout shortlist filtering."
packages/harness/cortextos/community/skills/system-diagnostics/SKILL.md:2:name: system-diagnostics
packages/harness/cortextos/community/skills/system-diagnostics/SKILL.md:3:description: "Something in the system feels stuck or wrong — tasks are not moving, an agent has gone quiet, goals have not been updated in days, or the orchestrator has asked for a system health report. You need to run a structured check: stale tasks, stale goals, overdue human tasks, fleet heartbeat status, and metrics. This is your diagnostic toolkit. Run it on every heartbeat (orchestrator) and whenever something seems off."
packages/harness/cortextos/community/skills/system-diagnostics/SKILL.md:8:# System Diagnostics
agents/recruitment/janitor/README.md:18:- `validate.sh` — Gate A (dedup confidence ≥0.85 + activity-window 90d + field-source confidence ≥0.7 + voice ≥0.75 + PII boundary + Bullhorn batch ≤100/min)
agents/recruitment/janitor/README.md:23:- `fixtures/99-merge-confidence-canary.yaml` — Adversarial: confidence just below 0.85 — Gate A must reject
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:69:1. **Candidate merge** (`PUT /Candidate/{primary_id}` + cascade) — only when confidence ≥0.85 per Gate A; no merge if either candidate had Bullhorn activity in last 90 days without explicit review flag (per ULTRAPLAN A2 line 510 verbatim). Action type: **`bullhorn_candidate_dedupe`** (existing in autosend-policy.yaml line 69; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:97:   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per §1.1.2 of v0.2 supplement)
agents/recruitment/janitor/agent.md:102:   → discard pairs <0.85 confidence (per Gate A)
agents/recruitment/janitor/agent.md:125:   → 7-day cache per tools.yaml; rate-limit budget shared with Diagnostic
agents/recruitment/janitor/agent.md:126:   → ESC_RATE_LIMIT_HIT on 429
agents/recruitment/janitor/agent.md:141:     (voice corpus + tone rules; ESC_VOICE_DRIFT if classifier <0.75)
agents/recruitment/janitor/agent.md:162:   → hh_decision_action("operator_notify_telegram", "tenant:<slug>",
agents/recruitment/janitor/agent.md:175:### Gate A — validate.sh (hard-fail before action)
agents/recruitment/janitor/agent.md:187:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint; per Day-19 catalogue add at `escalation-codes.md` line 184) OR `ESC_DUPLICATE_DETECTED` (merge-confidence reject; existing line 127) per the failed condition. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (line 163) is NOT used by Janitor — that code is reserved for vertical-schema field-constraint violations at write-time.
agents/recruitment/janitor/agent.md:189:### Gate B — Outcome threshold (success metric, not block)
agents/recruitment/janitor/agent.md:195:Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
agents/recruitment/janitor/agent.md:209:| `ESC_RATE_LIMIT_HIT` | Bullhorn or Companies House 429 | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:210:| `ESC_VOICE_DRIFT` | Tacit-note narrative voice classifier <0.75 (after 3 retries) | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:211:| `ESC_PII_LEAKAGE_RISK` | PII detected in tacit-note outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/janitor/agent.md:212:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (section count or per-section citation missing in day-30 report) | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:214:| `ESC_GATE_B_MISS` | Either independent Gate-B threshold (dedup <15% OR field-completeness <10%) missed for 3 consecutive runs. NOT a composite — see §5 Gate B for the two-threshold rule. | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:219:- `ESC_VOICE_DRIFT_TENANT` — fired by nightly voice-drift cron (per `escalation-codes.md` line 170-175 trigger: ≥N `ESC_VOICE_DRIFT` rows from same tenant in rolling 7d window). Janitor only fires the per-run `ESC_VOICE_DRIFT`; aggregate `_TENANT` rollup is handled by the canary not Janitor.
agents/recruitment/janitor/agent.md:222:- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction
agents/recruitment/janitor/agent.md:230:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/janitor/agent.md:234:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
agents/recruitment/janitor/agent.md:235:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:248:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ Week 3 in progress |
agents/recruitment/janitor/agent.md:249:| First pilot tenant onboarded (provision-tenant.sh) | Post Q1-LOI | ⏸ Founder action; Trigger 1 fires 2026-06-03 if no LOI |
agents/recruitment/janitor/agent.md:257:| `validate.sh` Gate A logic | Build at W5 start (~0.5 day) | ⏸ |
agents/recruitment/janitor/agent.md:280:| Q6 | Gate B exception handling — what if a tenant's day-0 baseline is already exceptionally clean (low headroom for improvement)? | Founder review at first 3-tenant cohort; may need per-tenant Gate B calibration. |
agents/recruitment/diagnostic/cleanup.sh:3:# Diagnostic agent — cleanup.sh
agents/recruitment/diagnostic/cleanup.sh:57:    '{"escalation_code":"ESC_PII_LEAKAGE_RISK","reason":"LinkedIn cache purge incomplete"}' \
agents/recruitment/diagnostic/cleanup.sh:79:hh_decision_action "diagnostic_cleanup" "agent:${CTX_AGENT_NAME:-diagnostic}" \
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:1:# Diagnostic fixture — 99-voice-drift-canary
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:3:# Adversarial case. Tests Gate A V3 (voice classifier ≥ 0.75) hard-fail
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:7:# ESC_VOICE_DRIFT row emitted, draft NOT written to vault.
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:16:description: Adversarial — force voice classifier below 0.75; expect Gate A V3 failure
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:18:agent: diagnostic
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:22:  command: ifosctl diagnostic
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:69:  - escalation_code: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:76:  vault_write: false  # NOTHING written to vault — Gate A blocked it
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:87:    - "ESC_VOICE_DRIFT"
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:35:| 14 | **Scripts authored Days 8+ never executed end-to-end against live until 2026-05-23** — Day-9 cohesion review claimed "foundation is sound for Diagnostic build" based on code+docs review, but no helper / migration / script had been exercised against live Postgres. Day-12 first execution surfaced 6 distinct drifts (password, DB name, TRIGGER grant, GUC rename, missing tenants row, table ownership/RLS-bypass). | High (now historical; mitigated) | High at time of discovery — any of the 6 could have manifested at first pilot LOI as silent failure or data leak. | Future script/migration authoring without an explicit "first live execution against migration-test tenant" milestone listed in the plan. | Day-12 closed loop: live migration 24/24 + tenancy audit 24/24. Future: every new script touching live Postgres must include a verified-on-VPS milestone in its acceptance criteria, not just unit-test-layer green. Day-9 cohesion review template updated to require live verification before "foundation verified" verdict. | **Mitigated.** Discovery surfaces a class lesson: ratification at code-and-docs layer is necessary but not sufficient; live execution is the third leg. |
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:65:- 2026-05-20 (Day 9 evening) — **Architecture + tenancy verification slice complete.** 3 commits (`5c3fa66` + `c4348aa` + this commit). 4 new artefacts: tenancy-invariants.md (Reference; 12 invariants T1-T12 single source of truth), run-tenancy-audit.sh (multi-tenant adversarial smoke), architecture-cohesion-review.md (8-artefact cohesion + 14 remediation items + 4-boundary adversarial walk), tenant-lifecycle.md (Provision/Operate/Suspend/Offboard/Migrate). All 4 master-brief §3 boundaries verified HOLD at current artefact set. 3 of 5 contradictions in the ratified artefact set RESOLVED via ADR-004 + Day-8 remediation; 1 RESOLVED via consolidation in tenancy-invariants.md; 1 OPEN pending Founder Decision D3 (PII retention). 8 implicit assumptions documented; 3 catastrophic-if-false verified empirically. No new risks added — cohesion review's 14 remediation items + lifecycle's 8 gaps are all variance bounded by existing risks (#5 renderer + #10 PII + others) or low-severity lazy specs. Foundation deemed sound for Diagnostic build conditional on founder-decision bundle (D1+D2+D3) + Codex Round 2 closure + live tenancy audit pass.
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
agents/recruitment/diagnostic/fixtures/01-primary.yaml:1:# Diagnostic fixture — 01-primary
agents/recruitment/diagnostic/fixtures/01-primary.yaml:6:# Gate A clean.
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
packages/agent-renderer/templates/claude-md-preamble.md:18:A non-zero exit from `validate.sh` blocks the action (Gate A; master brief §1 Rule 4).
packages/agent-renderer/templates/claude-md-preamble.md:58:- Cross-tenant PII is an `ESC_PII_LEAKAGE_RISK` escalation per `_shared/escalation-codes.md`.
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:1:# Diagnostic fixture — 02-edge-case-no-online-footprint
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:15:agent: diagnostic
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:16:expected_gate_a: PASS  # Gate A passes; just thinner content
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:19:  command: ifosctl diagnostic
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:99:    payload_includes: {output_type: "diagnostic_draft"}
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:101:    action_type: diagnostic_report_render
packages/agent-renderer/README.md:7:**Phase 2 scaffold (v0.1.0).** Phases 3-5 (helpers + voice schema + voice-loader) follow per `~/.claude/plans/bubbly-snuggling-lantern.md`. First production render: Diagnostic agent at Week 4 per master brief §8.2.
agents/recruitment/diagnostic/cycle.sh:3:# Diagnostic agent — cycle.sh (workflow orchestration)
agents/recruitment/diagnostic/cycle.sh:5:# Status: Proposed (Day-19; v0 implementation using @ifos/diagnostic-generator + web-scraper + companies-house MCP connectors all wired).
agents/recruitment/diagnostic/cycle.sh:9:# workflow steps from agent.md §4, calls validate.sh for Gate A, writes
agents/recruitment/diagnostic/cycle.sh:12:# Per ADR-003 + sequencing-target.md §2.1: Diagnostic is Tier 2 (request-
agents/recruitment/diagnostic/cycle.sh:19:#   - One Markdown file in /vault/<tenant_slug>/diagnostic-reports/<firm-slug>-<ISO-date>.md
agents/recruitment/diagnostic/cycle.sh:27:#   3  Gate A validation failed
agents/recruitment/diagnostic/cycle.sh:35:#     @ifos/diagnostic-generator package call that composes all 12 sections
agents/recruitment/diagnostic/cycle.sh:38:#   - Uses validate.sh for Gate A enforcement (per-section citation hard-fail
agents/recruitment/diagnostic/cycle.sh:93:REPORT_DIR="${VAULT_ROOT}/${CTX_TENANT_SLUG}/diagnostic-reports"
agents/recruitment/diagnostic/cycle.sh:95:DRAFT_PATH="/tmp/diagnostic-draft-${FIRM_SLUG}-$$.md"
agents/recruitment/diagnostic/cycle.sh:107:  hh_decision_action "diagnostic_input_invalid" "firm:${FIRM_NAME}" \
agents/recruitment/diagnostic/cycle.sh:109:    '{"escalation_code":"ESC_INPUT_VALIDATION_FAIL","input_field":"firm","input_value_preview":"<malformed>","validation_rule_violated":"min_length_2"}' >/dev/null
agents/recruitment/diagnostic/cycle.sh:114:# Step 2-11 — Generate the 12 sections via @ifos/diagnostic-generator
agents/recruitment/diagnostic/cycle.sh:119:# CLI: packages/diagnostic-generator/dist/cli.js
agents/recruitment/diagnostic/cycle.sh:121:GENERATOR_CLI="${IFOS_REPO_ROOT:-${REPO_ROOT}}/packages/diagnostic-generator/dist/cli.js"
agents/recruitment/diagnostic/cycle.sh:124:  printf '  Run: cd packages/diagnostic-generator && pnpm build\n' >&2
agents/recruitment/diagnostic/cycle.sh:161:  hh_decision_action "diagnostic_generator_empty" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:163:    '{"escalation_code":"ESC_AGENT_OUTPUT_SHAPE","agent_name":"diagnostic","shape_rule_violated":"non_empty_output","expected_value":"non-empty stdout","actual_value":"empty"}' >/dev/null
agents/recruitment/diagnostic/cycle.sh:168:# Step 12 — Validate (Gate A)
agents/recruitment/diagnostic/cycle.sh:171:hh_decision_output "diagnostic_draft" "${DRAFT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:175:  printf 'cycle.sh: Gate A failed; draft NOT moved to vault\n' >&2
agents/recruitment/diagnostic/cycle.sh:188:hh_decision_output "diagnostic_report" "${REPORT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:191:hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:196:printf '\n\033[1;32mDiagnostic report written:\033[0m %s\n' "${REPORT_PATH}"
agents/recruitment/diagnostic/cycle.sh:207:    # operator_notify_telegram is green-tier per autosend-policy.yaml so the
agents/recruitment/diagnostic/cycle.sh:214:    hh_decision_action "operator_notify_telegram" "operator:${TELEGRAM_OPERATOR_CHAT_ID}" \
agents/recruitment/diagnostic/cycle.sh:220:      -d "text=Diagnostic report ready: ${FIRM_NAME} → ${REPORT_PATH}%0A%0A${SUMMARY}..." \
packages/harness/cortextos/community/skills/officecli/SKILL.md:43:Path addressing uses 1-based indexing: `/body/p[1]`, `/slide[2]/shape[3]`, `/$Sheet:A1`
packages/harness/cortextos/community/skills/officecli/SKILL.md:102:officecli set $XLS 'Summary!A1' --prop value="Total Open"
packages/harness/cortextos/community/skills/officecli/SKILL.md:110:officecli set report.xlsx 'Sheet1!A1' --prop value="Property"
packages/harness/cortextos/community/skills/officecli/SKILL.md:132:  --prop background=1A1A2E
agents/recruitment/diagnostic/README.md:1:# Diagnostic — directory README
agents/recruitment/diagnostic/README.md:3:**Status:** Proposed (Day-11 pre-build scaffold; awaits W3-4 build slice).
agents/recruitment/diagnostic/README.md:20:| `validate.sh` | Gate A enforcement (12 sections + per-section citation + voice ≥ 0.75 + PII boundary) | W3 build start |
agents/recruitment/diagnostic/README.md:53:- ⏸ `validate.sh` Gate A logic built
docs/architecture/tenancy-invariants.md:4:**Date:** 2026-05-20 (Day 9 evening — pre-Diagnostic-build architecture audit).
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
agents/recruitment/diagnostic/tools.yaml:1:# Diagnostic agent — MCP tool declarations
agents/recruitment/diagnostic/tools.yaml:7:# Reading order: agent.md §3 (12 required sections) + §4 (10-step workflow) +
agents/recruitment/diagnostic/tools.yaml:14:agent: diagnostic
agents/recruitment/diagnostic/tools.yaml:42:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:77:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:121:      Scores §12 output against tenant's voice corpus + tone rules. Gate A
agents/recruitment/diagnostic/tools.yaml:125:      - IFOS_VOICE_CLASSIFIER_URL  # local microservice; OR fallback to LLM
agents/recruitment/diagnostic/tools.yaml:137:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:140:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:165:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:168:# Tools NOT in this manifest that Diagnostic must NEVER call:
agents/recruitment/diagnostic/tools.yaml:170:  - bullhorn       # Diagnostic is sales-tool tier; no ATS touch per sequencing-target.md §2.1
packages/harness/cortextos/tests/integration/concurrent-cron-mutations.test.ts:132:    // Diagnostic for debugging:
agents/recruitment/diagnostic/validate.sh:4:# Diagnostic agent — validate.sh (Gate A enforcement)
agents/recruitment/diagnostic/validate.sh:24:#   0  All Gate A checks pass; cycle.sh proceeds to vault write
agents/recruitment/diagnostic/validate.sh:28:# Checks (per agent.md §5 Gate A):
agents/recruitment/diagnostic/validate.sh:138:  # For scaffold: assume IFOS_VOICE_CLASSIFIER_URL set; fail gracefully if not
agents/recruitment/diagnostic/validate.sh:139:  if [[ -n "${IFOS_VOICE_CLASSIFIER_URL:-}" ]]; then
agents/recruitment/diagnostic/validate.sh:140:    SCORE=$(curl -sS -X POST "${IFOS_VOICE_CLASSIFIER_URL}/classify" \
agents/recruitment/diagnostic/validate.sh:153:    _warn "V3: IFOS_VOICE_CLASSIFIER_URL unset; voice classification SKIPPED (W3 build wires this)"
agents/recruitment/diagnostic/validate.sh:227:  printf '\nValidate Gate A: \033[1;32mPASS\033[0m (warnings=%d)\n' "${#WARNINGS[@]}"
agents/recruitment/diagnostic/validate.sh:230:  printf '\nValidate Gate A: \033[1;31mFAIL\033[0m (%d failures, %d warnings)\n' \
agents/recruitment/diagnostic/validate.sh:234:  #   - PII detected outside firm boundary → ESC_PII_LEAKAGE_RISK (blocking)
agents/recruitment/diagnostic/validate.sh:235:  #   - Voice classifier score <0.75 (V3) → ESC_VOICE_DRIFT (warn, per
agents/recruitment/diagnostic/validate.sh:238:  #     length) → ESC_AGENT_OUTPUT_SHAPE (warn)
agents/recruitment/diagnostic/validate.sh:240:  # violations at write time per catalogue line 163 — not for Diagnostic's
agents/recruitment/diagnostic/validate.sh:253:    ESC_CODE="ESC_PII_LEAKAGE_RISK"
agents/recruitment/diagnostic/validate.sh:255:    ESC_CODE="ESC_VOICE_DRIFT"
agents/recruitment/diagnostic/validate.sh:257:    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"
docs/architecture/architecture-cohesion-review.md:3:**Date:** 2026-05-20 (Day 9 — pre-Diagnostic-build foundation audit).
docs/architecture/architecture-cohesion-review.md:88:| A1 | **Postgres `current_setting('app.current_tenant', TRUE)` returns NULL when unset, never empty string.** RLS predicate `tenant_slug = current_setting(...)` relies on NULL≠'anything' semantics. | Every RLS policy on every tenant-data table | If empty string is returned, an INSERT with `tenant_slug=''` could leak across tenants. Postgres docs confirm NULL behaviour; assumption holds. |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:150:| G4 | **The agent runtime's `validate.sh` invocation contract is implicit.** ADR-003 §2.1 row 5 says it's a verbatim copy to `.claude/hooks/validate.sh`. But what does the runtime DO with it? Is it called before every tool use? Once per session? | Medium (every agent uses validate.sh) | Diagnostic W3 build's agent.md preamble names the invocation; pattern propagates. Add to tenant-lifecycle runbook. |
docs/architecture/architecture-cohesion-review.md:190:**Verdict: BOUNDARY HOLDS at current artefact set.** Future agents need automated guardrail; queue as Phase-1 extension OR `review-agent-bundle.md` skill at Diagnostic W3.
docs/architecture/architecture-cohesion-review.md:217:**Verdict: BOUNDARY HOLDS at current artefact set.** Same pattern as adapter boundary — needs automated guardrail at Diagnostic W3.
docs/architecture/architecture-cohesion-review.md:231:| R5 | G4: validate.sh invocation contract | Medium | Document in tenant-lifecycle.md OR Diagnostic agent.md preamble | Claude Code | Diagnostic W3 build |
docs/architecture/architecture-cohesion-review.md:234:| R8 | Adapter + brain-replacement boundary automation | Medium | `review-agent-bundle.md` Codex skill at Diagnostic W3 | Claude Code | Diagnostic W3 |
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
docs/architecture/architecture-cohesion-review.md:254:**All 4 boundaries (submodule, adapter, vault/Postgres, brain-replacement) hold at current artefact set.** Two need automated guardrails at Diagnostic W3 (adapter + brain-replacement).
docs/architecture/architecture-cohesion-review.md:256:**The foundation is sound for Diagnostic build, conditional on:**
docs/architecture/architecture-cohesion-review.md:258:2. R4-R8 documented during this slice (Phase 2.2 + Diagnostic W3)
docs/architecture/architecture-cohesion-review.md:262:If those four hold, **Diagnostic agent build can begin with high confidence.**
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:270:      title: 'A1',
agents/recruitment/diagnostic/context.sh:4:# Diagnostic agent — context.sh
agents/recruitment/diagnostic/context.sh:19:#       CTX_AGENT_NAME=diagnostic
agents/recruitment/diagnostic/context.sh:29:#   - Missing voice corpus → exit 1 with ESC_VOICE_DRIFT (no fallback for
agents/recruitment/diagnostic/context.sh:35:CTX_AGENT_NAME="diagnostic"
agents/recruitment/diagnostic/context.sh:83:hh_decision_trigger "session_start" "diagnostic agent for firm: ${IFOS_DIAGNOSTIC_FIRM_NAME:-<unset>}" \
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:144:# 4 — Load tone rules (filtered to diagnostic agent)
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:173:printf '[diagnostic context.sh] tenant=%s corpus_id=%s tone_rules=%s recent_edits=%s target_patch=loaded\n' \
agents/recruitment/diagnostic/agent.md:1:# Diagnostic — the sales tool
agents/recruitment/diagnostic/agent.md:3:**Status:** Proposed (Day-19; full bundle built — agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures all present. Status flips Proposed → Accepted when ALL of these complete: (a) Codex RATIFIED verdict on this agent.md via review-agent-bundle.md skill, AND (b) founder approves §3's 12-section list as canonical, AND (c) first production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row), AND (d) Gate B baseline measurement begins (30% target; 4-week window). See §10 for the same checklist.)
agents/recruitment/diagnostic/agent.md:6:**Build wave:** v1.0 W3-4 per master brief §8.2 line 595 (row 1; anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`. **Drift flag:** Ultraplan §8.1 A1 (line 489) calls Diagnostic build wave 4-5; master brief line 595 calls it W3-4. Master brief is authoritative per CLAUDE.md (master brief wins on every conflict); W3-4 is the build wave for IFOS.
agents/recruitment/diagnostic/agent.md:7:**Build complexity:** M (1 week) per Ultraplan §8.1 A1 line 489.
agents/recruitment/diagnostic/agent.md:16:> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A's per-section citation subcheck hard-fails on any section missing its citation, per `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). ADR-006 establishes Gate A as per-section hard-fail; per-claim citation analysis is a separate post-launch quality metric outside Gate A (future W4 ADR + schema supplements). The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (target voice-classifier ≥ 0.75 per `common-voice.json`; v0 implementation warns + exits 0 when `IFOS_VOICE_CLASSIFIER_URL` is unreachable per §5 honesty note — W4 polish closes this to unconditional hard-fail) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
agents/recruitment/diagnostic/agent.md:26:ifosctl diagnostic \
agents/recruitment/diagnostic/agent.md:33:Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY). Typical wall-clock: 10-15 minutes (empirical Day-13 measurement against Hays plc + Charterhouse fixtures); not specified in upstream master brief or Ultraplan.
agents/recruitment/diagnostic/agent.md:39:- Bulk-mode (`ifosctl diagnostic --firm-list firms.csv`) — out of v1.0 scope
agents/recruitment/diagnostic/agent.md:43:## §3 — The 12 required sections
agents/recruitment/diagnostic/agent.md:45:Every report MUST contain these 12 sections. The generator (`@ifos/diagnostic-generator`) emits them in the order listed below. Gate A at v0 enforces (a) ≥12 `##` headings present in the rendered draft AND (b) per-section citation coverage; exact-heading-title-and-order matching is W4 polish (validate.sh §1.3 currently counts `##` headings without exact-title matching, per `validate.sh` lines 89-97 "exact-heading matching not implemented at v0; W4 polish adds title + order check").
agents/recruitment/diagnostic/agent.md:47:**v0 source-coverage state:** Companies House data (§1, §10) is live via `@ifos/companies-house` MCP connector. Web-scraped pages (§2 footprint URLs, §8 careers-page pain signals) are live via `@ifos/web-scraper`. **LinkedIn deep-data sections (§3 job posts, §5 placement timeline, §7 employee skills, §9 competitor employee scan, §11 decision-maker profiles) currently use `@ifos/diagnostic-generator` stub-with-Companies-House-fallback citations** — Proxycurl integration deferred to W4 polish per ADR-005. Each LinkedIn-dependent section still emits ≥1 evidence link (per-section Gate A satisfied) by falling back to Companies House URLs, but the data depth is degraded vs the full-coverage W4 target.
agents/recruitment/diagnostic/agent.md:64:**Gate A hard-fails** (per ADR-006 + §5 spec):
agents/recruitment/diagnostic/agent.md:68:- Section 12 (conversation opener) failing voice-classifier with score < 0.75 *(v0 hard-fail when voice-classifier URL reachable; warn + exit 0 when URL unreachable per §5 honesty note; W4 polish closes to unconditional hard-fail with explicit `validate_check_skipped` audit row)*
agents/recruitment/diagnostic/agent.md:73:- Step 10 report assembly → `hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")`
agents/recruitment/diagnostic/agent.md:74:- Step 11 (optional) operator notify → `hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)` — green tier per autosend-policy.yaml
agents/recruitment/diagnostic/agent.md:75:- Step 12 session close → `hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)` — green tier
agents/recruitment/diagnostic/agent.md:81:Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. The v0 cycle.sh implementation uses a generator-level pattern: a single call to `@ifos/diagnostic-generator` (`packages/diagnostic-generator/`) fetches all 12 sections in one process; cycle.sh emits decision-log rows at draft-write + report-write + render-action boundaries, not per-section. Per-section data acquisition is internal to the generator package and not separately audited at v0; W4 polish may add per-section telemetry.
agents/recruitment/diagnostic/agent.md:84:0. Session start — invocation arrives via CLI ifosctl diagnostic
agents/recruitment/diagnostic/agent.md:90:   → on fail: hh_decision_action("diagnostic_input_invalid", ...) with
agents/recruitment/diagnostic/agent.md:91:     payload {escalation_code: ESC_INPUT_VALIDATION_FAIL, ...}
agents/recruitment/diagnostic/agent.md:95:   → bash invokes @ifos/diagnostic-generator with firm + sector + target_patch flags
agents/recruitment/diagnostic/agent.md:105:   → generator writes complete draft Markdown to /tmp/diagnostic-<firm-slug>-<ISO-date>.draft.md
agents/recruitment/diagnostic/agent.md:106:   → on empty stdout: hh_decision_action("diagnostic_generator_empty", ...) with
agents/recruitment/diagnostic/agent.md:107:     payload {escalation_code: ESC_AGENT_OUTPUT_SHAPE, ...}; exit 1
agents/recruitment/diagnostic/agent.md:108:   → ESC_RATE_LIMIT_HIT raised internally by web-scraper / companies-house on 429
agents/recruitment/diagnostic/agent.md:109:   → ESC_VOICE_DRIFT raised internally by §12 LLM step if classifier <0.75 after 3 retries
agents/recruitment/diagnostic/agent.md:110:   → hh_decision_output("diagnostic_draft", "<draft_path>", "<firm> 12-section draft (pre-validate)")
agents/recruitment/diagnostic/agent.md:112:12. Validate (Gate A) (cycle.sh Step 12)
agents/recruitment/diagnostic/agent.md:118:     with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE or
agents/recruitment/diagnostic/agent.md:119:     ESC_PII_LEAKAGE_RISK) and exit 1
agents/recruitment/diagnostic/agent.md:120:   → cycle.sh deletes draft on Gate A fail
agents/recruitment/diagnostic/agent.md:123:   → atomic mv -f /tmp/<draft> → /vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md
agents/recruitment/diagnostic/agent.md:125:   → hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")
agents/recruitment/diagnostic/agent.md:126:   → hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:131:     → hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:142:### Gate A — validate.sh (hard-fail before action)
agents/recruitment/diagnostic/agent.md:144:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
agents/recruitment/diagnostic/agent.md:146:**Per ADR-006 (canonical interpretation of ULTRAPLAN §8.1 A1 line 496 Gate A clause "no claims unsupported by source data"):** Gate A's citation subcheck is per-section hard-fail (every one of the 12 sections has ≥1 evidence link). Per-claim citation analysis is a SEPARATE post-launch quality metric, NOT Gate A — to be authored as a future W4 ADR with schema supplements when the voice-classifier microservice ships + first pilot tenant accumulates ≥30 reports.
agents/recruitment/diagnostic/agent.md:148:**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
agents/recruitment/diagnostic/agent.md:152:- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
agents/recruitment/diagnostic/agent.md:154:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
agents/recruitment/diagnostic/agent.md:155:- No PII (emails) outside the firm boundary. **v0 behavior:** validate.sh runs a generic email-regex pass and warns on any email found (no firm-domain whitelist implemented in v0; warn-only; exit 0). W4 polish adds the firm-domain whitelist + hard-fail behavior + `ESC_PII_LEAKAGE_RISK` emission. **v0 PII coverage:** emails only via regex; phone-number PII detection + whitelist enforcement deferred to W4 polish.
agents/recruitment/diagnostic/agent.md:157:### Gate B — Outcome threshold (success metric, not block)
agents/recruitment/diagnostic/agent.md:159:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.
agents/recruitment/diagnostic/agent.md:161:Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
agents/recruitment/diagnostic/agent.md:167:Diagnostic uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/diagnostic/agent.md:171:| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:172:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/diagnostic/agent.md:173:| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn 429 | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:174:| `ESC_INPUT_VALIDATION_FAIL` | Malformed firm name input (Step 1 validation) | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:175:| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing OR generator produced empty stdout (Step 8 fallback) | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:177:Diagnostic does NOT use:
agents/recruitment/diagnostic/agent.md:179:- `ESC_RENDERER_FAILED` — that code is owned by the `_renderer` sentinel (agent_name='_renderer') per catalogue §2.4; Diagnostic never fires it
agents/recruitment/diagnostic/agent.md:180:- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
agents/recruitment/diagnostic/agent.md:181:- `ESC_AUTOSEND_*` — Diagnostic's actions are `diagnostic_report_render` + `operator_notify_telegram` + `consultant_feedback` (all green tier per autosend-policy.yaml)
agents/recruitment/diagnostic/agent.md:182:- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention
agents/recruitment/diagnostic/agent.md:190:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:194:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
agents/recruitment/diagnostic/agent.md:195:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
agents/recruitment/diagnostic/agent.md:210:| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
agents/recruitment/diagnostic/agent.md:216:| `validate.sh` Gate A logic (12-section check) | `agents/recruitment/diagnostic/validate.sh` | ✅ Built; per-section subcheck hard-fail per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per §5 honesty note (W4 polish closes) |
agents/recruitment/diagnostic/agent.md:217:| `context.sh` hydration | `agents/recruitment/diagnostic/context.sh` | ✅ Built |
agents/recruitment/diagnostic/agent.md:218:| 3 fixtures with golden outputs | `agents/recruitment/diagnostic/fixtures/` | ✅ Built (01-primary + 02-edge-case + 99-voice-drift-canary) |
agents/recruitment/diagnostic/agent.md:219:| Other bundle files (cycle.sh, tools.yaml, cleanup.sh) | `agents/recruitment/diagnostic/` | ✅ All built |
agents/recruitment/diagnostic/agent.md:220:| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⚠ 10 rounds attempted; ADR-006 (Accepted) closed Cat-1 Gate A finding; residual mechanical findings tracked in disagreement doc Phase 4-5 |
agents/recruitment/diagnostic/agent.md:230:**Build state:** full bundle (cycle.sh, validate.sh, context.sh, tools.yaml, cleanup.sh, 3 fixtures) shipped Day 13-19. Codex review-agent-bundle ratification in progress (10+ rounds; ADR-006 closed the Cat-1/Cat-ζ Gate A finding; iterating on smaller mechanical findings).
agents/recruitment/diagnostic/agent.md:236:| Q1 | Is "12 sections" the right number? Ultraplan §8.1 A1 says "12 required sections" but doesn't enumerate. This document proposes a 12-section list (§3); founder may want to revise. | Founder reviews §3 table; can split/merge sections. Lands as Edit in next commit. |
agents/recruitment/diagnostic/agent.md:239:| Q4 | Gate B (30% discovery-call-to-report ratio) measured how? Manual tagging by consultant OR auto-detection via Bullhorn calendar links? | v1.0 manual tagging via Telegram resolution; v1.1 auto-detection. |
agents/recruitment/diagnostic/agent.md:243:### Gotchas (carried forward from Ultraplan §8.1 A1)
agents/recruitment/diagnostic/agent.md:259:- Gate B baseline measurement begins (30% target; 4-week window)
agents/recruitment/diagnostic/agent.md:263:*End of Diagnostic agent.md draft.*
agents/recruitment/concierge/README.md:22:- `validate.sh` — Gate A (SLA 30 min + voice ≥0.75 per-position + addressee + tone-rule + PII + anti-duplicate) — most complex validator of v1.0
agents/recruitment/concierge/README.md:29:- `fixtures/99-addressee-mismatch-canary.yaml` — Gate A blocker (wrong recipient)
docs/architecture/agent-bundle-renderer-design.md:25:├── validate.sh                         # Gate A — sources _shared/hook-helpers.sh
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:97:The two layouts share no files by name except `tools.yaml` (which the IFOS bundle uses for MCP servers and which Claude Code consumes at PTY spawn). cortextOS expects `config.json` (runtime config), `CLAUDE.md` (Claude Code's entry point), `.env` (Telegram credentials + secrets); IFOS provides `config.schema.json` (a *schema* for per-tenant config, not the materialised config itself), `agent.md` (the output contract + workflow, not a Claude Code entry point), and no `.env` (credentials live per-tenant). The bundle's `validate.sh` and `context.sh` have no cortextOS analogue — they implement IFOS-side Gate A and context-assembly per master brief §8.1 Changes 1+2, and need a defined invocation mechanism (Spec gap §1.1-A). The bundle's `tests/fixtures/` are CI-only and have no runtime counterpart in cortextOS. **Translation is required for three of the six bundle files** (`agent.md` → `CLAUDE.md` with cortextOS-required preamble synthesised in; `config.schema.json` → `config.json` materialised with per-tenant values from `/vault/{tenant}/_config.yaml`; `validate.sh` + `context.sh` → rendered into a hook location the agent can invoke). `README.md` and `tools.yaml` pass through. Fixtures stay in the source repo.
docs/architecture/agent-bundle-renderer-design.md:123:- **§2.1-A:** master brief §8.1 does not specify what the **cortextOS preamble template** looks like — the wrapper around `agent.md` that becomes `CLAUDE.md`. Recommended resolution: pin a canonical preamble at `packages/agent-renderer/templates/claude-md-preamble.md` (rendered with tenant + agent variables); preamble content must (a) tell Claude Code to source `.claude/hooks/context.sh` at session start, (b) tell Claude Code to call `.claude/hooks/validate.sh` before any tool invocation (Gate A), (c) list the env vars the agent should expect (`CTX_TENANT_SLUG`, `CTX_AGENT_NAME`, `CTX_ORCHESTRATOR_AGENT`, etc.), (d) reference `agent.md` body verbatim, (e) **not** reference IDENTITY.md / SOUL.md / MEMORY.md / GOALS.md / etc. because they will not exist. A draft preamble lives in §2.3 worked example below.
docs/architecture/agent-bundle-renderer-design.md:149:`activity-channel`, `agent-browser`, `agent-management`, `auto-skill`, `autoresearch`, `bus-reference`, `comms`, `cron-management`, `env-management`, `event-logging`, `guardrails-reference`, `human-tasks`, `m2c1-worker`, `onboarding`, `soul-philosophy`, `system-diagnostics`, `tool-registration`, `worker-agents` — 18 above, plus the `memory-management` skill referenced from `agent/.claude/skills/onboarding/SKILL.md:42` that I haven't catalogued individually.
docs/architecture/agent-bundle-renderer-design.md:219:  - ESC_VOICE_DRIFT
docs/architecture/agent-bundle-renderer-design.md:220:  - ESC_PII_LEAKAGE_RISK
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:270:        "ESC_VOICE_DRIFT": { "type": "string", "format": "telegram-chat-id" }
docs/architecture/agent-bundle-renderer-design.md:307:# Gate A: hard-fail on missing hh_decision_* calls in this run
docs/architecture/agent-bundle-renderer-design.md:322:hh_load_tone_rules
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:367:A non-zero exit from validate.sh blocks the action (Gate A; master brief §1 Rule 4).
docs/architecture/agent-bundle-renderer-design.md:392:PII is a `ESC_PII_LEAKAGE_RISK` escalation. Voice samples and tone rules in
docs/architecture/agent-bundle-renderer-design.md:423:    "ESC_VOICE_DRIFT": "<acme operator chat id from _secrets.env>"
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier (`gmail_outlook_send_to_candidate` or `bullhorn_note_customer_visible` depending on channel per autosend-policy.yaml lines 122-149). Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is a Gate B leading metric (warning + aggregated; NOT a Gate A hard-fail) per the same ULTRAPLAN line — making it a hard-fail would block legitimate delayed drafts caused by Bullhorn polling fallbacks. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:153:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
agents/recruitment/concierge/agent.md:160:4. Addressee resolution (Gate A critical)
agents/recruitment/concierge/agent.md:190:   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries
agents/recruitment/concierge/agent.md:203:9. SLA timing check (Gate B leading metric — NOT Gate A hard-fail)
agents/recruitment/concierge/agent.md:205:   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
agents/recruitment/concierge/agent.md:207:     generated within 30 minutes" — interpreted as a Gate B leading metric
agents/recruitment/concierge/agent.md:215:    → ESC_PII_LEAKAGE_RISK on hit (blocking)
agents/recruitment/concierge/agent.md:249:15. Session close + Gate B metric
agents/recruitment/concierge/agent.md:250:    → compute elapsed (event → send) for Gate B SLA tracking
agents/recruitment/concierge/agent.md:262:### Gate A — validate.sh (hard-fail before action)
agents/recruitment/concierge/agent.md:269:- No PII outside firm boundary — hard-fail (ESC_PII_LEAKAGE_RISK)
agents/recruitment/concierge/agent.md:273:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
agents/recruitment/concierge/agent.md:275:Gate A failures fire `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` or `ESC_PII_LEAKAGE_RISK` or `ESC_CANDIDATE_DATA_INCOMPLETE` or `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint when voice threshold misses persistently) — all blocking; draft to `/tmp`; operator notified immediately.
agents/recruitment/concierge/agent.md:277:**Honesty note (per bilateral-disposition Cat-5):** Concierge `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W10-13 build slice. The W10-13 build delivers `agents/recruitment/concierge/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/concierge/agent.md:279:### Gate B — Outcome thresholds (success metrics, not block)
agents/recruitment/concierge/agent.md:287:Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
agents/recruitment/concierge/agent.md:298:| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:304:| `ESC_VOICE_DRIFT` | Voice classifier below position-specific threshold after 3 retries | warn (position 1-2) or **blocking** (position 3) | operator_chat_id (1-2) / operator + ifos_oncall (position 3) |
agents/recruitment/concierge/agent.md:306:| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:307:| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |
agents/recruitment/concierge/agent.md:310:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:319:- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
agents/recruitment/concierge/agent.md:320:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Concierge's Gate A failures are output-shape or addressee-resolution failures.
agents/recruitment/concierge/agent.md:321:- `ESC_VOICE_DRIFT_TENANT` (direct firing) — that's fired by the nightly voice-drift cron per catalogue §2.5; Concierge fires only per-run `ESC_VOICE_DRIFT`.
agents/recruitment/concierge/agent.md:329:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
agents/recruitment/concierge/agent.md:336:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:337:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
agents/recruitment/concierge/agent.md:355:| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
agents/recruitment/concierge/agent.md:367:| Voice classifier microservice live | W4-5 polish | ⏸ |
agents/recruitment/concierge/agent.md:371:| `validate.sh` Gate A logic | Build at W10 start (~2 days; most complex of v1.0 validators) | ⏸ |
agents/recruitment/concierge/agent.md:395:| Q6 | Send-as-is rate (Gate B ≥60%) — measurement requires consultant to differentiate "approve" from "edit-and-approve". Brain UI v1.0 has no such control yet. Telegram-based approval? | Telegram-based for v1.0: `/approve <draft-id>` vs `/approve-edit <draft-id> <revised-body>`. Brain UI v1.1+ adds inline edit UX. |
agents/recruitment/concierge/agent.md:417:- Founder approves §9 Q2 (lifecycle taxonomy) + Q3 (send window) + Q4 (rejection routing) + Q5 (template authoring UX) + Q6 (Gate B UX)
agents/recruitment/concierge/agent.md:425:- Gate B feedback loop operational (consultant approve/edit distinguishable)
docs/architecture/cortexos-primitive-status.md:64:- v1.1: A7 Inbound Triage, A10 Competitor Interception, A11 Night Sourcer (with primitive 6), A12 T5 Supply Chain Auditor, A13 T3 Compliance Watchtower all require it.
docs/architecture/cortexos-primitive-status.md:122:- v1.1+: A7 Inbound Triage, A12 T5 Supply Chain Auditor, A13 T3 Compliance Watchtower all carry per-entity state across many days.
docs/architecture/cortexos-primitive-status.md:124:**Risk if flaky:** Concierge loses cross-week candidate conversation context at the 71-hour boundary or at API overflow; rejection drafts lose the prior-state nuance that defines Gate A voice quality on the hardest test case (Ultraplan §8.1 A6 gotcha: "Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship"). Per Ultraplan §3.1 row 2, the documented contingency is: "Manual restart cadence acceptable for v1.0 pilots; flag as known limitation in pilot agreement."
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/runbooks/day-4-provisioning.md:1228:9. **§4 self-inflicted defensive check (Claude error):** Claude added `sudo file -s /dev/disk/by-id/...` defensive check not in runbook §4.1; `file` not installed on base image; `set -e` aborted before §4.2 install. Reverted to exact runbook commands. Lesson: stop adding defensive diagnostics beyond runbook spec when execution is in section-by-section gated mode.
docs/runbooks/day-4-provisioning.md:1254:19. **§9 verification script bugs (Claude error, no state impact):** Initial run reported 4 FAILs of 22 checks. Diagnosis showed all were script bugs, not state failures: (a) `sshd -T` requires root to read host keys (`sudo sshd -T` works correctly); (b) `findmnt --verify` output format simpler post-LUKS-open (`Success, no errors or warnings detected`) than my regex expected. Diagnostic re-run confirmed all 22 of 22 actual state checks pass. State is verified clean.
docs/architecture/second-brain-design.md:102:soul-philosophy  system-diagnostics  tasks  tool-registration
docs/architecture/second-brain-design.md:198:| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:654:        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:776:| Diagnostic | N/A | doesn't touch the per-tenant vault |
docs/architecture/second-brain-design.md:890:| **Multi-tenancy enforcement** — how `tenant_slug` is validated at the entry point (master brief §3.5) | Wrapper reads `CTX_TENANT_SLUG` env var (set by PM2 ecosystem per-tenant process group); CLI handler validates that the arg `--tenant` matches the env or fails with `ESC_PII_LEAKAGE_RISK`. Kernel-enforced isolation underneath (POSIX 0700 per Ultraplan §5.1) means a wrong tenant fails at filesystem read. | Server receives `CTX_TENANT_SLUG` at connection setup via MCP server args; rejects any tool call whose `tenant_slug` mismatches the connection identity. Filesystem isolation underneath same as α. One enforcement site. | Library validates `tenant_slug` against env var. Same enforcement model as α, but agent-side discipline depends on skill docs being followed. |
docs/runbooks/operational-hygiene-protocol.md:125:**Rule:** When executing a runbook, run exactly the commands in the runbook. Do not add defensive checks, verification probes, or "while we're here" diagnostics beyond what the runbook specifies.
docs/runbooks/operational-hygiene-protocol.md:131:- §9 verification script had `sshd -T` without `sudo`. Without root, sshd cannot read host keys and exits with "no hostkeys available". The check appeared to fail though state was correct. Diagnostic re-run needed.
docs/runbooks/operational-hygiene-protocol.md:132:- §9 verification script had `findmnt --verify` regex matching old output format. Post-LUKS-open, output simplified to "Success, no errors or warnings detected" which the regex missed. Diagnostic re-run needed.
docs/runbooks/operational-hygiene-protocol.md:150:- Day 5 autosend policy: estimated 300-500 lines; actual 648. **+30% to +116% overshoot.**
docs/operations/bullhorn-outreach-emails.md:17:**These don't block today.** They block **Janitor W5 build** (per kill-criterion §2 Trigger 3). You have ~5 weeks of runway. But send today/Monday because Bullhorn's response time is 2-5 business days, and we want the answers before Diagnostic W3-4 completes so Janitor W5 starts unblocked.
docs/runbooks/tenant-lifecycle.md:4:**Date:** 2026-05-20 (Day 9 — pre-Diagnostic-build foundation)
docs/runbooks/tenant-lifecycle.md:112:for agent in diagnostic; do
packages/agent-renderer/tests/fixtures/test-agent/validate.sh:2:# Gate A — test-agent renderer fixture. Hard-fail if CTX env not present.
packages/agent-renderer/tests/fixtures/test-agent/agent.md:18:Gate A: `validate.sh` enforces tenant_slug matches CTX env var.
docs/operations/codex-round-2-handoff.md:82:| 11 | `docs/decisions/v1.0-kill-criterion.md` | Trigger 1 date + Trigger 2 CLI + Trigger 4 threshold | RATIFY (all three fixed) |
docs/operations/codex-round-2-handoff.md:174:  audit + verification artefacts before Diagnostic agent build begins
docs/operations/codex-round-2-handoff.md:353:- **Foundation is fully double-reviewed** — Diagnostic agent build can begin with maximum confidence
docs/operations/codex-round-2-handoff.md:396:6. **Diagnostic agent build slice begins** — first ratified-foundation v1.0 agent
docs/build-brief/00-MASTER-BRIEF.md:57:4. **Quality gates before features.** Gate A (per-run `validate.sh`) working + decision-log writes (`hh_decision_trigger / output / action`) present > extra features. `validate.sh` hard-fails on missing decision-log calls. No exceptions.
docs/build-brief/00-MASTER-BRIEF.md:478:- [ ] `docs/decisions/v1.0-kill-criterion.md` — the explicit condition under which v1.0 stops shipping (e.g., "If after 3 pilots the average Gate B revenue uplift is <£20k/year per tenant, the wedge is dead and we pivot")
docs/build-brief/00-MASTER-BRIEF.md:547:├── validate.sh                         # Gate A — sources _shared/hook-helpers.sh
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:580:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/build-brief/00-MASTER-BRIEF.md:585:- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
docs/build-brief/00-MASTER-BRIEF.md:586:- `ESC_RATE_LIMIT_HIT` — upstream API rate-limited (esp. LinkedIn)
docs/build-brief/00-MASTER-BRIEF.md:595:| 1 | Diagnostic | 3–4 | LinkedIn + Companies House + scrape | Sales tool — needed before any other agent matters |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:619:# 5. validate.sh (Gate A; sources _shared/hook-helpers.sh)
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:986:6. **The quality gates** — Gate A binary per-run, Gate B 90-day, Gate C weekly voice classifier
docs/operations/codex-round-2-remediation-prompt.md:218:  | Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (sequencing-target §2.1) | Awaits Q1 LOI |
docs/operations/codex-round-2-remediation-prompt.md:257:           diagnostic_email_send               → external-comms
docs/operations/codex-round-2-remediation-prompt.md:258:           diagnostic_calendar_invite          → external-comms
docs/operations/codex-ratification-execution-plan.md:72:| `review-agent-bundle.md` | The 6-file + 3-fixture pattern | ~250 | Pre-Diagnostic-W3 (not yet needed) |
docs/operations/codex-ratification-execution-plan.md:348:Per Day-7 manifest §4 + §6 of this plan: Codex ratification execution was deferred pending Week 0 close. Week 0 closes when single-sentence-test Q1 = YES (design partner LOI signed). **Current state:** Q1 = NO; Week 0 EXTENDING; kill-criterion Trigger 1 fires 2026-06-03.
docs/operations/codex-ratification-execution-plan.md:352:- **Option α** — Start immediately. Rationale: 33 items are already queued; Q1 turning YES will only ADD items (Diagnostic + Janitor + downstream). The 34-item queue is largely about Week 0 design artefacts that won't change post-LOI. Get them ratified now while context is fresh.
docs/operations/codex-ratification-execution-plan.md:429:- **Codex review of `agents/_shared/` runtime code via agent-bundle skill** — the 8-file `_shared/` set is reviewed under `review-architecture-decision.md` because it's not an agent bundle, it's the helper layer. Future agents (Diagnostic W3+) will be reviewed under `review-agent-bundle.md` once that skill exists.
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:630:    // Must prescribe list-crons as first diagnostic
docs/operations/codex-round-2-autonomous-prompt.md:305:- A blocker on Diagnostic build — that runs separately after Round 2 + founder actions
docs/operations/codex-round-2-autonomous-prompt.md:318:**If SUMMARY.md shows clean (0 REJECTED OR all REJECTED are founder-decision-bound):** Round 2 done. Move to founder action sequence items 5-8 (live migration + tenancy audit + SeedLegals + Diagnostic build).
docs/_supplementary/PRD-autonomous-agent.md:676:- Any pillar with 0 reels in last 14 days gets +30% priority boost
docs/operations/goal-week-3-polish-and-scaffold.md:1:# /goal — Week 3: Diagnostic polish + 5 agent.md scaffolds + Codex ratification
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:8:**Builds on:** `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 Diagnostic v0 — completed at commit `97a57a2`).
docs/operations/goal-week-3-polish-and-scaffold.md:19:4. **`docs/specs/ULTRAPLAN.md`** §8.1 in full (per-agent A1-A6 specs, lines 495-572) + §9 (Bullhorn critical path, lines 720-770) + §10 (risk rows + contingencies)
docs/operations/goal-week-3-polish-and-scaffold.md:26:11. **`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`** (today's sequencing change)
docs/operations/goal-week-3-polish-and-scaffold.md:27:12. **`agents/recruitment/diagnostic/agent.md`** in full (the gold-standard agent.md to model from)
docs/operations/goal-week-3-polish-and-scaffold.md:31:16. **`docs/operations/goal-option-c-diagnostic-end-to-end.md`** (Day-13 Diagnostic build; reference for Week-3 polish steps)
docs/operations/goal-week-3-polish-and-scaffold.md:33:After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Six v1.0 agents: [list with weeks]. ULTRAPLAN §8.1 agent line ranges: [A1 lines 495-505, A2 lines 507-514, ...]. Week-3 scope confirmed. Ready to begin Step 1."**
docs/operations/goal-week-3-polish-and-scaffold.md:41:### Diagnostic polish (Days 14-15)
docs/operations/goal-week-3-polish-and-scaffold.md:43:1. **Companies House data flows end-to-end.** Founder has registered the API key (Step 2). Re-running cycle.sh against Hays plc produces §1 + §10 + §11 with REAL CH data (not "no registration found"). Updated artefact at `docs/artefacts/diagnostic-hays-plc-2026-05-2X.md`.
docs/operations/goal-week-3-polish-and-scaffold.md:45:3. **§12 conversation opener is LLM-driven, not deterministic.** Calls Claude API (or OpenAI fallback) with §1-§11 context + tenant voice corpus + tone rules. Voice classifier microservice STUB in place (real classifier W4-5; for now: skip-with-warning preserved).
docs/operations/goal-week-3-polish-and-scaffold.md:46:4. **Diagnostic bundle ratified by Codex.** Round 4 ratification run against agent.md + 5 siblings + 3 fixtures via `review-architecture-decision.md` skill. Verdict: RATIFIED (or remediation-pass if needed).
docs/operations/goal-week-3-polish-and-scaffold.md:50:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:56:Each agent.md has the same 10-section structure as Diagnostic:
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:63:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:70:10. **Round 4 ratification run executed** via `bash scripts/run-codex-ratification.sh` with the manifest extended to include 6 new artefacts (Diagnostic agent.md re-ratify + 5 new agent.md scaffolds).
docs/operations/goal-week-3-polish-and-scaffold.md:77:14. **`docs/RISK-REGISTER.md`** updated: Risk #2 (Bullhorn) blast radius confirmed reduced; Risk #5 (Renderer) state per Diagnostic ratification.
docs/operations/goal-week-3-polish-and-scaffold.md:89:| Diagnostic CH integration with real key | Goal §1 criterion 1; brings §1/§10/§11 from degraded → full |
docs/operations/goal-week-3-polish-and-scaffold.md:92:| Diagnostic Codex ratification | Master brief §10.5 always-ratify |
docs/operations/goal-week-3-polish-and-scaffold.md:101:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:105:| Proxycurl signup | Founder commercial action; gated on founder decision (cost ~$39/mo); if founder approves mid-week, wire LinkedIn deep data into Diagnostic |
docs/operations/goal-week-3-polish-and-scaffold.md:106:| Voice classifier microservice | Reserved for W4-5 polish; for Week 3, §12 LLM call skips voice-classifier gate (V3 stays as a skipped-with-warning) |
docs/operations/goal-week-3-polish-and-scaffold.md:139:### DAY 14 — Diagnostic polish substrate (Steps 1-5)
docs/operations/goal-week-3-polish-and-scaffold.md:150:(cd packages/diagnostic-generator && pnpm build)
docs/operations/goal-week-3-polish-and-scaffold.md:154:(cd packages/diagnostic-generator && pnpm test) | tail -3
docs/operations/goal-week-3-polish-and-scaffold.md:189:Edit `packages/diagnostic-generator/src/sections/online-footprint.ts`:
docs/operations/goal-week-3-polish-and-scaffold.md:196:pnpm test --filter @ifos/diagnostic-generator
docs/operations/goal-week-3-polish-and-scaffold.md:197:pnpm typecheck --filter @ifos/diagnostic-generator
docs/operations/goal-week-3-polish-and-scaffold.md:200:Commit: `fix(diagnostic): LinkedIn slug suffix-strip — Hays plc → linkedin.com/company/hays`
docs/operations/goal-week-3-polish-and-scaffold.md:204:Edit `packages/diagnostic-generator/src/sections/conversation-opener.ts`:
docs/operations/goal-week-3-polish-and-scaffold.md:208:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:212:   - **Retry:** if response shape malformed, retry once; if still bad, fall back to deterministic logic + emit `ESC_VOICE_DRIFT` warning row.
docs/operations/goal-week-3-polish-and-scaffold.md:213:3. Voice classifier integration: STUB — `IFOS_VOICE_CLASSIFIER_URL` unset means skip-with-warning (preserves V3 behaviour). Real classifier wires up at W4-5.
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
docs/operations/goal-week-3-polish-and-scaffold.md:251:### DAY 15 — Diagnostic Codex ratification (Steps 6-7)
docs/operations/goal-week-3-polish-and-scaffold.md:258:1. `agents/recruitment/diagnostic/agent.md` — re-ratify (was Round-3 RATIFIED at scaffold; now production-shape)
docs/operations/goal-week-3-polish-and-scaffold.md:259:2. `agents/recruitment/diagnostic/tools.yaml`
docs/operations/goal-week-3-polish-and-scaffold.md:260:3. `agents/recruitment/diagnostic/cycle.sh` (post-Day-13 generator wiring)
docs/operations/goal-week-3-polish-and-scaffold.md:261:4. `agents/recruitment/diagnostic/validate.sh` (post-Day-13 V2 fix)
docs/operations/goal-week-3-polish-and-scaffold.md:262:5. `packages/diagnostic-generator/` (the package as a whole; ratifies via `review-architecture-decision.md` skill)
docs/operations/goal-week-3-polish-and-scaffold.md:263:6. `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` (Day-13 sequencing decision)
docs/operations/goal-week-3-polish-and-scaffold.md:267:Commit: `ops(codex-round-4): Diagnostic bundle + ADR-005 queue addition`
docs/operations/goal-week-3-polish-and-scaffold.md:269:#### Step 7 — Codex Round 4 Diagnostic-only run (~45 min)
docs/operations/goal-week-3-polish-and-scaffold.md:274:bash scripts/run-codex-ratification.sh --round 4 --subset diagnostic
docs/operations/goal-week-3-polish-and-scaffold.md:277:Captures verdicts in `logs/codex-ratification/round-4/diagnostic/`. Each artefact: RATIFIED | NEEDS-REMEDIATION | REJECTED.
docs/operations/goal-week-3-polish-and-scaffold.md:279:If all RATIFIED → mark Diagnostic ratified in manifest §1.10; proceed to Step 8.
docs/operations/goal-week-3-polish-and-scaffold.md:284:Commit: `decision(codex-round-4): diagnostic verdicts — <N> RATIFIED / <M> REJECTED`
docs/operations/goal-week-3-polish-and-scaffold.md:296:- Diagnostic's `agent.md` as the gold-standard structure
docs/operations/goal-week-3-polish-and-scaffold.md:298:Author the agent.md following Diagnostic's 10-section template. Specifics:
docs/operations/goal-week-3-polish-and-scaffold.md:306:- **§5 Gate A:** validate.sh hard-fails on missing CTX env, dedup-rate >20% (suggests bad heuristic), field-write-error-rate >5%, schema-violation rows.
docs/operations/goal-week-3-polish-and-scaffold.md:307:- **§5 Gate B:** ≥15% dedup improvement + ≥10% field-completeness improvement per ULTRAPLAN line 512.
docs/operations/goal-week-3-polish-and-scaffold.md:308:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_BULLHORN_WRITE_FAIL, ESC_SCHEMA_VIOLATION, ESC_RATE_LIMIT_HIT, ESC_AUTOSEND_YELLOW_SPOT_CHECK.
docs/operations/goal-week-3-polish-and-scaffold.md:310:- **§8 Build prerequisites:** Bullhorn MCP connector wired (W3 conditional; W4-5 if A+B answered) + first pilot tenant with Bullhorn corpToken in `_secrets.env`.
docs/operations/goal-week-3-polish-and-scaffold.md:314:Target: ~400 lines. Follows Diagnostic's structure verbatim. Every claim cites a specific master plan section + line number.
docs/operations/goal-week-3-polish-and-scaffold.md:334:Author following Diagnostic's template. Specifics:
docs/operations/goal-week-3-polish-and-scaffold.md:341:- **§5 Gate A:** validate.sh hard-fails on missing transcript, field-extraction confidence <0.6, Bullhorn write FK-violation, voice-classifier <0.75 on tacit note.
docs/operations/goal-week-3-polish-and-scaffold.md:342:- **§5 Gate B:** ≥80% field-extraction accuracy (per consultant spot-check) + ≥90% within-10-min SLA.
docs/operations/goal-week-3-polish-and-scaffold.md:343:- **§6 Escalation codes:** ESC_BULLHORN_WRITE_FAIL, ESC_VOICE_DRIFT, ESC_SCHEMA_VIOLATION, ESC_FIELD_EXTRACTION_LOW_CONFIDENCE.
docs/operations/goal-week-3-polish-and-scaffold.md:344:- **§7 Voice + tone:** tacit-note is consultant-voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:363:Author following Diagnostic's template. Specifics:
docs/operations/goal-week-3-polish-and-scaffold.md:365:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:370:- **§5 Gate A:** validate.sh hard-fails on accounting API auth failure, bank API auth failure, reconciliation false-positive rate >2%, chase-draft content failing voice classifier.
docs/operations/goal-week-3-polish-and-scaffold.md:371:- **§5 Gate B:** ≥95% invoice match accuracy (vs human spot-check) + ≥15% reduction in days-sales-outstanding (DSO) after 60 days operation.
docs/operations/goal-week-3-polish-and-scaffold.md:373:- **§7 Voice + tone:** chase drafts are voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:398:- **§5 Gate A:** validate.sh hard-fails on empty match list, low average confidence (<0.5), schema violation.
docs/operations/goal-week-3-polish-and-scaffold.md:399:- **§5 Gate B:** ≥3 high-confidence (>0.7) matches per brief.
docs/operations/goal-week-3-polish-and-scaffold.md:400:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_LINKEDIN_AUTH, ESC_RATE_LIMIT_HIT, ESC_BRIEF_UNDERSPECIFIED.
docs/operations/goal-week-3-polish-and-scaffold.md:425:- **§5 Gate A:** validate.sh hard-fails on missing approval-bridge auth (if D1-A bridge), voice classifier <0.75, tone-rule block-severity hit, schema violation, orange-tier-spot-check sample selected.
docs/operations/goal-week-3-polish-and-scaffold.md:426:- **§5 Gate B:** <5% incorrect-send rate (per consultant feedback loop) + ≥90% lifecycle-event coverage (no missed transitions).
docs/operations/goal-week-3-polish-and-scaffold.md:427:- **§6 Escalation codes:** ESC_AUTOSEND_BLOCKED, ESC_VOICE_DRIFT, ESC_TONE_RULE_VIOLATION, ESC_APPROVAL_BRIDGE_TIMEOUT, ESC_BULLHORN_AUTH, ESC_LIFECYCLE_STATE_UNKNOWN.
docs/operations/goal-week-3-polish-and-scaffold.md:440:Manifest now includes 6 new items (5 agent.md scaffolds + Diagnostic re-ratify). Founder runs:
docs/operations/goal-week-3-polish-and-scaffold.md:460:2. **`docs/RISK-REGISTER.md`** — Risk #2 (Bullhorn) status per A+B response state; Risk #5 (Renderer) updated per Diagnostic ratification.
docs/operations/goal-week-3-polish-and-scaffold.md:498:| LLM call rate-limited or 5xx (Step 4 runtime) | Built-in retry once; fall back to deterministic; emit ESC_VOICE_DRIFT warning |
docs/operations/goal-week-3-polish-and-scaffold.md:499:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Founder approves Proxycurl signup mid-week | Wire LinkedIn deep data into Diagnostic via a new `@ifos/linkedin-proxycurl` package (similar to companies-house pattern); commit as separate slice; out of scope for goal §1 but high-value |
docs/operations/goal-week-3-polish-and-scaffold.md:525:- Step 7: Codex Round 4 Diagnostic-only run (founder runs the script)
docs/operations/goal-week-3-polish-and-scaffold.md:531:- Any reduction in Gate A strictness
docs/operations/goal-week-3-polish-and-scaffold.md:543:- Diagnostic agent.md (re-ratify; was Round-3 RATIFIED at scaffold form)
docs/operations/goal-week-3-polish-and-scaffold.md:544:- Diagnostic tools.yaml
docs/operations/goal-week-3-polish-and-scaffold.md:545:- Diagnostic cycle.sh (post-Day-13 generator wiring)
docs/operations/goal-week-3-polish-and-scaffold.md:546:- Diagnostic validate.sh (post-Day-13 V2 fix)
docs/operations/goal-week-3-polish-and-scaffold.md:547:- packages/diagnostic-generator/ (as a whole package)
docs/operations/goal-week-3-polish-and-scaffold.md:552:### Round 4 Diagnostic-only run (Step 7)
docs/operations/goal-week-3-polish-and-scaffold.md:555:bash scripts/run-codex-ratification.sh --round 4 --subset diagnostic
docs/operations/goal-week-3-polish-and-scaffold.md:558:Mid-week early ratification of Diagnostic ensures: (a) the substrate is verified before 5 new scaffolds reference it; (b) any architectural concerns surface before the 5 new agent.md contracts are committed.
docs/operations/goal-week-3-polish-and-scaffold.md:592:5. **Every Gate A condition is operationally testable.** A future validate.sh implementer can read §5 and write the bash logic without inventing rules.
docs/operations/goal-week-3-polish-and-scaffold.md:593:6. **Every Gate B target is measurable.** Cite the master plan section or ULTRAPLAN line that establishes the metric. No invented numbers.
docs/operations/goal-week-3-polish-and-scaffold.md:608:Diagnostic state:
docs/operations/goal-week-3-polish-and-scaffold.md:612:  Gate A:             PASS (V1-V6 green; V3 warning per scaffold)
docs/operations/goal-week-3-polish-and-scaffold.md:624:  <SHA>  fix(diagnostic): LinkedIn slug suffix-strip
docs/operations/goal-week-3-polish-and-scaffold.md:625:  <SHA>  feat(diagnostic): §12 LLM-driven conversation opener
docs/operations/goal-week-3-polish-and-scaffold.md:626:  <SHA>  milestone(diagnostic): Hays plc full-data re-run
docs/operations/goal-week-3-polish-and-scaffold.md:627:  <SHA>  ops(codex-round-4): Diagnostic bundle queue addition
docs/operations/goal-week-3-polish-and-scaffold.md:628:  <SHA>  decision(codex-round-4-diagnostic): N RATIFIED / M REJECTED
docs/operations/goal-week-3-polish-and-scaffold.md:641:  ✓ sequencing-target.md §3.1 — Build Wave 1 (Diagnostic) ratified;
docs/operations/goal-week-3-polish-and-scaffold.md:643:  ✓ v1.0-kill-criterion.md Trigger 2 — Diagnostic ratified ahead of
docs/operations/goal-week-3-polish-and-scaffold.md:650:    - Diagnostic voice classifier microservice
docs/operations/goal-week-3-polish-and-scaffold.md:651:    - Diagnostic LinkedIn deep data (if Proxycurl signed up)
docs/operations/goal-week-3-polish-and-scaffold.md:686:| 7 | The 5 agent.md scaffolds drift in style across days (different writing voice on different days) | Medium | Each scaffold re-reads Diagnostic's agent.md FIRST as the structural template; commit message references the structural anchor |
docs/operations/goal-week-3-polish-and-scaffold.md:700:**Day 20 is the soft target. Day 22 is the hard cutoff** (Trigger 2 fires Day 21 if Diagnostic not ratified). If Day 22 hits without completion, escalate to founder review + scope-cut decision.
packages/agent-renderer/pnpm-lock.yaml:400:    resolution: {integrity: sha512-+A1NJmfM8WNDv5CLVQYJ5PshuRm/4cI6WMZRg1by1GwPIQPCTs1GLEUHwiiQGT5zDdyLiRM/l1G0Pv54gvtKIg==}
packages/agent-renderer/pnpm-lock.yaml:587:    resolution: {integrity: sha512-FJHFfqpKUI3A10WrWKiFbBZ7yVbGT4q4B5o1qKFFojqpaYoh9LrQgqWCmmcxQzVSXYtyB5bzkXrYzlHTs21MYA==}
packages/agent-renderer/pnpm-lock.yaml:642:    resolution: {integrity: sha512-QVTUovf40zgTqlFVrKA1uXMVvU2QWEFWfAH8Wdc48IxLvrJMQVMBRjuQyUpzZCDkakImib9eVazbWlC6ksWtJw==}
packages/agent-renderer/pnpm-lock.yaml:864:    resolution: {integrity: sha512-//nshmD55c46FuFw26xV/xFAaB5HF9Xdap7HJBBnrKdAd6/GxDBaNA1870O79+9ueg61cZLSVc+OaFlfmObYVQ==}
packages/agent-renderer/pnpm-lock.yaml:1019:    resolution: {integrity: sha512-o5a9xKjbtuhY6Bi5S3+HvbRERmouabWbyUcpXXUA1u+GNUKoROi9byOJ8M0nHbHYHkYICiMlqxkg1KkYmm25Sw==}
docs/operations/seedlegals-engagement-queries.md:167:- 2026-06-03 (Trigger 1) date approaches; LOI process accelerates without legal infrastructure
docs/specs/ULTRAPLAN.md:36:**Rule 4 — Quality gates before features.** An agent that ships with a working Gate A and a measurement plan for Gate B/C is shippable. An agent that ships with extra features but a flaky Gate A is not. Every weekly review checks gates before features.
docs/specs/ULTRAPLAN.md:97:- The Diagnostic agent (sales tool)
docs/specs/ULTRAPLAN.md:127:├── validate.sh                    # Output validation hook (Gate A)
docs/specs/ULTRAPLAN.md:155:hh_load_tone_rules
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:182:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/specs/ULTRAPLAN.md:187:- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
docs/specs/ULTRAPLAN.md:188:- `ESC_RATE_LIMIT_HIT` — upstream API (LinkedIn especially) rate limited
docs/specs/ULTRAPLAN.md:265:4. Run a single dry-run agent invocation (the Diagnostic) to validate the path end-to-end.
docs/specs/ULTRAPLAN.md:352:Total Gate A latency: <500ms. Acceptable.
docs/specs/ULTRAPLAN.md:354:If any hard fail, the agent regenerates with the failure reason injected as additional context ("your previous draft used the banned phrase 'I hope this finds you well'; rewrite avoiding it"). After 3 retries with hard fails, escalate with `ESC_VOICE_DRIFT` or `ESC_SCHEMA_VIOLATION`.
docs/specs/ULTRAPLAN.md:376:If the rolling 4-week average drops by ≥5 percentage points: `ESC_VOICE_DRIFT_TENANT` fires. Email goes to the customer's primary contact AND to the internal CS Slack:
docs/specs/ULTRAPLAN.md:400:### 7.1 Gate A — Output gate (per single run, automated, binary)
docs/specs/ULTRAPLAN.md:402:Already specified in §4 and §6. Every agent's `validate.sh` enforces Gate A. Pass = output ships. Fail = output quarantined, retry up to 3 times, then escalate.
docs/specs/ULTRAPLAN.md:404:Gate A measurements stored in `gate_a_results` Postgres table:
docs/specs/ULTRAPLAN.md:409:Dashboard query: per-agent Gate A pass rate, weekly trend.
docs/specs/ULTRAPLAN.md:411:### 7.2 Gate B — Outcome gate (per 100 runs in a real tenant, statistical, monthly)
docs/specs/ULTRAPLAN.md:415:| Agent | Gate B target | Measurement protocol |
docs/specs/ULTRAPLAN.md:417:| Inbound Triage | 95% of inbounds get response within 60s; consultant-edit rate <30% on auto-sent categories | Decision-log query over 30 days, per tenant |
docs/specs/ULTRAPLAN.md:419:| Client Hunter | ≥ 20 BD opportunities/month produced with ≥ 30% receiving consultant action | Decision-log query; action defined as "approved-and-sent" |
docs/specs/ULTRAPLAN.md:423:| Janitor | 30-day before/after report shows ≥15% dedup, ≥10% field-completeness improvement | The day-30 report IS the Gate B measurement |
docs/specs/ULTRAPLAN.md:428:Gate B failures in month 3: the agent goes into tuning mode. The engineer pairs with the tenant for 2 weeks. Re-measure at month 4. If still failing, escalate to product review — is this config, schema, or genuine product weakness?
docs/specs/ULTRAPLAN.md:447:- Gate A pass rate (target: 100%; alert at <99%)
docs/specs/ULTRAPLAN.md:448:- Gate B trend (target: monotone-improving; alert at any monthly regression)
docs/specs/ULTRAPLAN.md:479:Gate A specifics
docs/specs/ULTRAPLAN.md:480:Gate B target (restated from §7.2)
docs/specs/ULTRAPLAN.md:487:#### A1. The Diagnostic — the sales tool
docs/specs/ULTRAPLAN.md:496:- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/specs/ULTRAPLAN.md:497:- **Gate B target:** ≥30% of diagnostics produced lead to a discovery call booked
docs/specs/ULTRAPLAN.md:510:- **Gate A:** dedup confidence score ≥ 0.85 on every merge proposal; no merge proposed where candidate has had activity in last 90 days without explicit review flag
docs/specs/ULTRAPLAN.md:511:- **Gate B target:** day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement
docs/specs/ULTRAPLAN.md:524:- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
docs/specs/ULTRAPLAN.md:525:- **Gate B target:** 90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%
docs/specs/ULTRAPLAN.md:538:- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
docs/specs/ULTRAPLAN.md:539:- **Gate B target:** tenant DSO at month-3 ≥ 12 days lower than month-0 baseline
docs/specs/ULTRAPLAN.md:552:- **Gate A:** 5–15 candidates returned per brief; each has a working contact method; each has rationale ≥ 50 words; no candidate flagged "do not contact" in tenant vault
docs/specs/ULTRAPLAN.md:553:- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)
docs/specs/ULTRAPLAN.md:566:- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
docs/specs/ULTRAPLAN.md:567:- **Gate B target:** <5% candidate-ghosted rate; ≥60% send-as-is rate on drafts
docs/specs/ULTRAPLAN.md:582:- **Gate A:** draft generated within 60s of webhook receipt; classification has confidence ≥ 0.8; no auto-send on uncategorised messages
docs/specs/ULTRAPLAN.md:583:- **Gate B target:** 95% within 60s; consultant edit-rate <30% on auto-sent categories; <2% wrong-classification rate
docs/specs/ULTRAPLAN.md:596:- **Gate A:** every brief produces 3 ambiguity flags OR an "unambiguous" signal; pre-shortlist contains 3–10 candidates; intake-call agenda has 5–8 items
docs/specs/ULTRAPLAN.md:597:- **Gate B target:** brief-to-first-shortlist <90 minutes for ≥80% of inbound briefs
docs/specs/ULTRAPLAN.md:605:#### A10. Competitor Interception (2 weeks)
docs/specs/ULTRAPLAN.md:614:- **Gate A:** detection latency <5 min from competitor posting; outreach references the specific role title AND the competitor agency by name (the firm needs to know we're not making this up)
docs/specs/ULTRAPLAN.md:615:- **Gate B target:** ≥1 competitor interception per tenant per month converts to a meeting
docs/specs/ULTRAPLAN.md:619:#### A11. The Night Sourcer (2 weeks)
docs/specs/ULTRAPLAN.md:628:- **Gate A:** 8–12 candidates per brief; each has rationale ≥ 50 words; drafts for each are valid (Gate A on the draft itself); no rate-limit exceptions raised
docs/specs/ULTRAPLAN.md:629:- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared with Sourcing Scout)
docs/specs/ULTRAPLAN.md:633:#### A12. T5 Supply Chain Auditor (parallel to v1.1 front-office work)
docs/specs/ULTRAPLAN.md:642:- **Gate A:** every red-flag pattern (e.g., FCSA accreditation lapsed, complaint volume spike, director change) produces an alert within 24 hours; quarterly audit pack contains all required sections
docs/specs/ULTRAPLAN.md:643:- **Gate B target:** zero JSL-incident-eligible patterns missed (verified retrospectively)
docs/specs/ULTRAPLAN.md:647:#### A13. T3 Compliance Watchtower (parallel to v1.1 front-office work)
docs/specs/ULTRAPLAN.md:656:- **Gate A:** every active contractor has a live state with AWR week counter, RTW expiry, contract end, holiday pay year-to-date; deadline-imminent alerts fire ≥7 days ahead
docs/specs/ULTRAPLAN.md:657:- **Gate B target:** zero compliance deadlines missed in the tenant; <2 false-positive alerts per tenant per month
docs/specs/ULTRAPLAN.md:685:| Diagnostic | ✓ | | | | ✓ | ✓ | | | | | Web scraper |
docs/specs/ULTRAPLAN.md:750:### Weeks 3–4 — Bullhorn + Diagnostic
docs/specs/ULTRAPLAN.md:753:- Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint
docs/specs/ULTRAPLAN.md:755:Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact.
docs/specs/ULTRAPLAN.md:806:- Voice classifier and Gate A enforcement (Rule 4)
docs/specs/ULTRAPLAN.md:828:| 12 | A pilot churns within 90 days | Medium | High | Gate B failure at month 2 OR Gate C reject rate >10% sustained 2 weeks | Engineer pairs with tenant; if not recoverable by month 3, churn-with-grace and capture learnings |
docs/_supplementary/build-plan-original.md:303:- **Escalate** — if source APIs return <30% of expected volume for 3 consecutive runs, flag ICP as possibly too narrow
docs/specs/_archive-build-handoff.md:194:4. Quality gates before features — Gate A working > extra features.
docs/specs/_archive-build-handoff.md:279:- The explicit condition under which v1.0 stops shipping (e.g., "If after 3 pilots the average Gate B revenue uplift is <£20k/year per tenant, the wedge is dead and we pivot")
docs/specs/_archive-build-handoff.md:338:# 5. validate.sh (Gate A structural checks; sources _shared/hook-helpers.sh)
docs/specs/_archive-build-handoff.md:377:| 1 | **Diagnostic** | 3–4 | LinkedIn + Companies House + web scrape | Sales tool — needed for pitch before any other agent matters |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/specs/_archive-build-handoff.md:420:4. **Quality gates before features** — an agent that ships with a working Gate A and a measurement plan for Gate B/C is shippable. An agent that ships with extra features but a flaky Gate A is not.
docs/operations/goal-option-c-diagnostic-end-to-end.md:1:# /goal — Option C: Diagnostic agent end-to-end against a real UK recruitment firm
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:18:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A1 (the 10-step workflow for Diagnostic, lines 495-526).
docs/operations/goal-option-c-diagnostic-end-to-end.md:19:5. **`agents/recruitment/diagnostic/agent.md`** — the existing output contract. Read in full.
docs/operations/goal-option-c-diagnostic-end-to-end.md:20:6. **`agents/recruitment/diagnostic/tools.yaml`** — MCP tool declarations the executor must implement.
docs/operations/goal-option-c-diagnostic-end-to-end.md:32:1. **One Markdown file exists at `/vault/migration-test/diagnostic-reports/<firm-slug>-2026-05-24.md`** containing a 12-section Diagnostic report for a real UK recruitment firm chosen by the founder.
docs/operations/goal-option-c-diagnostic-end-to-end.md:34:2. **The report passes Gate A (validate.sh)** clean: 12 sections present, ≥1 citation per section, word count 400-2000, no banned phrases (V3 voice classifier passes OR skipped with explicit warning if `IFOS_VOICE_CLASSIFIER_URL` unset for v0).
docs/operations/goal-option-c-diagnostic-end-to-end.md:49:6. **A decision-log audit trail** for the smoke run: 3+ rows in `decision_log` (trigger + output + action), all under `agent_name='diagnostic'`, with `tenant_slug='migration-test'`.
docs/operations/goal-option-c-diagnostic-end-to-end.md:55:9. **State files updated:** `current-priorities.md` Shipped section + `RISK-REGISTER.md` Risk #2 status (Diagnostic ratification path proven).
docs/operations/goal-option-c-diagnostic-end-to-end.md:65:| Web scraper utility | Diagnostic §4 Step 3 + 6 + 8 |
docs/operations/goal-option-c-diagnostic-end-to-end.md:66:| Companies House connector | Diagnostic §4 Step 2 + 10 |
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:155:- `errors.ts` — 429 → ESC_RATE_LIMIT_HIT, 5xx → ESC_SCHEMA_VIOLATION
docs/operations/goal-option-c-diagnostic-end-to-end.md:195:Replace the stub `_section_1()` through `_section_11()` functions in `agents/recruitment/diagnostic/cycle.sh` with real connector calls:
docs/operations/goal-option-c-diagnostic-end-to-end.md:210:Acceptance: `bash agents/recruitment/diagnostic/cycle.sh --firm "Test Firm Name" --tenant migration-test` produces a draft at /tmp/... and Gate A passes (V3 warning only).
docs/operations/goal-option-c-diagnostic-end-to-end.md:212:Commit: `feat(diagnostic): wire web-scraper + companies-house into cycle.sh §1+§2+§6`
docs/operations/goal-option-c-diagnostic-end-to-end.md:227:ifosctl diagnostic --firm "<firm name>" --tenant migration-test
docs/operations/goal-option-c-diagnostic-end-to-end.md:232:export CTX_AGENT_DIR=$(pwd)/agents/recruitment/diagnostic
docs/operations/goal-option-c-diagnostic-end-to-end.md:235:bash agents/recruitment/diagnostic/cycle.sh --firm "<firm name>"
docs/operations/goal-option-c-diagnostic-end-to-end.md:238:Verify the report at `/vault/migration-test/diagnostic-reports/<slug>-2026-05-24.md`:
docs/operations/goal-option-c-diagnostic-end-to-end.md:241:- Confirm Gate A passed
docs/operations/goal-option-c-diagnostic-end-to-end.md:244:Commit: `milestone(diagnostic): first end-to-end run — <firm name> report at <path>`
docs/operations/goal-option-c-diagnostic-end-to-end.md:248:Write `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` documenting:
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:252:- **Decision:** Week 3 (Days 13-20) repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build. Week 4 (Days 21-27) repurposed from Diagnostic-build to Diagnostic-polish + Codex ratification + (conditional) Bullhorn-MCP-build if A+B answered.
docs/operations/goal-option-c-diagnostic-end-to-end.md:257:Commit: `decision(ADR-005): Week 3 repurposed Bullhorn-MCP → Diagnostic acceleration`
docs/operations/goal-option-c-diagnostic-end-to-end.md:262:- Move Diagnostic agent.md scaffold from "Shipped" Day-11 to "shipped + extended" pointing at today's commits
docs/operations/goal-option-c-diagnostic-end-to-end.md:266:- Risk #2 (Bullhorn MCP build): note Diagnostic-doesn't-need-Bullhorn path explored Day-13; reduces blast radius if Bullhorn response delayed
docs/operations/goal-option-c-diagnostic-end-to-end.md:267:- Risk #3 (Q1 LOI): note that Diagnostic-as-sales-tool now has empirical artefact for the Q1 pitch
docs/operations/goal-option-c-diagnostic-end-to-end.md:281:- Gate A verdict
docs/operations/goal-option-c-diagnostic-end-to-end.md:308:| Web scraper hits a JS-heavy site that returns no text | Expected (gotcha §6.1); §2 reports "site requires JS, signal unavailable"; counts as graceful degradation (fixture 02 already verifies this); no Gate A impact. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:309:| LLM generates §12 with banned phrase | V5 fails; retry up to 3x; if still failing, ESC_VOICE_DRIFT row + report blocked (matches fixture 99); record as known limitation, defer voice tuning to Week-4 polish. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:310:| Diagnostic report word count <400 | V4 fails; cycle.sh detects + retries with longer prompt; if still failing, surface as Diagnostic-spec issue (revisit agent.md §3 section count vs word budget). |
docs/operations/goal-option-c-diagnostic-end-to-end.md:312:| Real run reveals Gate A V3 voice classifier was actually needed (skipped warning was too lenient) | Surface as W4 polish item; do not block the milestone. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:332:- Any reduction in Gate A strictness
docs/operations/goal-option-c-diagnostic-end-to-end.md:341:- [ ] Gate A passes (V3 warning only, all others pass)
docs/operations/goal-option-c-diagnostic-end-to-end.md:357:ULTRAPLAN line 755 sets the bar: "Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."
docs/operations/goal-option-c-diagnostic-end-to-end.md:381:Report path:       [/vault/migration-test/diagnostic-reports/<slug>-<date>.md]
docs/operations/goal-option-c-diagnostic-end-to-end.md:384:Gate A:            PASS (V3 warning — voice classifier skipped per scaffold)
docs/operations/goal-option-c-diagnostic-end-to-end.md:392:  5. [SHA] feat(diagnostic): wire web-scraper + companies-house into cycle.sh
docs/operations/goal-option-c-diagnostic-end-to-end.md:393:  6. [SHA] milestone(diagnostic): first end-to-end run
docs/specs/PRODUCT-SPEC.md:95:- **Revenue story:** "We do a full evening of sourcing on every brief in your pipeline, every night. You walk in to a day of outreach already drafted instead of a day of sourcing." Modelled: time-to-shortlist drops from 5 days to 2 days; 30% more briefs run concurrently per consultant.
docs/specs/PRODUCT-SPEC.md:173:#### R13. The Diagnostic — the sales motion, productised
docs/specs/PRODUCT-SPEC.md:244:| **Growth** (11–25 fee earners) | £3,250 | All Boutique + Night Sourcer, Brief Decoder, Spec Pitcher, Real-Time Pulse, Competitor Interception, Recruitment Reporting | "5–10 net-new retainers/year from BD + Competitor Interception. 30%+ more briefs per consultant via Night Sourcer. 1–2 saved client relationships/year worth £30k–£100k each." |
docs/specs/PRODUCT-SPEC.md:324:- 90-minute discovery call (driven by the Diagnostic output).
docs/specs/PRODUCT-SPEC.md:471:- The Diagnostic (sales tool; already drafted)
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:81:| Diagnostic | `diagnostic_report_render` | Internal artefact write; no external comms; idempotent (re-render overwrites) |
docs/decisions/autosend-safety-policy.md:108:| Diagnostic | `diagnostic_email_send` | Outbound diagnostic report to prospect; sales-stage outreach; reputation |
docs/decisions/autosend-safety-policy.md:109:| Diagnostic | `diagnostic_calendar_invite` | Books intro call with prospect; reputation + scheduling friction |
docs/decisions/autosend-safety-policy.md:634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:1:# Codex disagreement — Diagnostic Gate A citation requirement + 4 follow-on findings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:6:**Artefact:** `agents/recruitment/diagnostic/agent.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:8:- Round 4: `logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.output.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:9:- Round 5: `logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.output.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:15:Week 3 goal at `docs/operations/goal-week-3-polish-and-scaffold.md` Step 7 (Codex Round 4 Phase 1) ratified `agents/recruitment/diagnostic/agent.md`. Codex found 4 issues; mechanical remediation applied (commit `6e0cb86`); Round 5 re-ratification found 5 new issues — 2 re-raises (Codex disagreed with my remediation framing), 3 new findings not visible at Round 4.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:23:### Issue 1 (RE-RAISE) — Gate A citation requirement strength
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:25:**Codex says:** "Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires 'no claims unsupported by source data.' This lowers a stated Gate A constraint."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:31:Option A — **Tighten Gate A to per-claim citation** (matches Ultraplan). Requires implementing per-claim citation validation in `validate.sh` (significant logic; W4 polish item but Codex says it should be Gate A v0).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:33:Option B — **Amend Ultraplan §8.1 A1 line 497** to read "no unsupported claims at section level" (loosens upstream to match v0 implementation).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:35:Option C — **Hybrid:** v0 Gate A = per-section (current); Gate B (post-launch quality signal) = per-claim spot-check sampling. Document this two-tier policy explicitly.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:41:**Codex says:** "Lines 140-142 send an optional Telegram notification, but line 73 says every step that produces output or takes action MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:43:**Disposition:** **Codex is correct.** Real bug. Step 11 sends a Telegram notification (an action with external side-effect) but doesn't emit a `decision_log` row. Mechanical fix: add `hh_decision_action("operator_notify_telegram", ...)` call to Step 11.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:47:### Issue 3 (RE-RAISE) — Gate B kill-criterion Trigger reference
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:49:**Codex says:** "Line 169 claims Diagnostic's 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:53:**Founder decision needed:** Diagnostic's Gate B metric doesn't map cleanly to ANY existing kill-criterion trigger.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:55:Option A — **Remove kill-criterion reference entirely.** Just describe Gate B as a local leading metric for Diagnostic; not part of any kill-criterion trigger. Honest.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:57:Option B — **Add a new kill-criterion Trigger 11 (DIAGNOSTIC-CONVERSION-FAIL).** Threshold: <30% discovery-call rate sustained for 4 weeks across all live pilots. Owner: founder + Jack.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:59:**My recommendation:** **A** for v0 — remove the trigger reference; Diagnostic conversion is local-metric tracking. Add Trigger 11 in v1.1 if conversion-rate-driven scope-cut becomes operationally relevant.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:61:### Issue 4 (NEW) — `_consultant_feedback` sentinel undocumented
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:63:**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:69:Option A — **Add `_consultant_feedback` to the sentinel catalogue.** New entry in `agents/_shared/escalation-codes.md` documenting purpose, payload shape, and emit cadence.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:71:Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:73:**My recommendation:** **B** — cleaner, avoids sentinel proliferation. Feedback events are conceptually Diagnostic's domain (they validate Diagnostic outputs), so the agent_name should be Diagnostic with a specific action_type marker.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:91:3. **Accept Issue 4 fix per Option B** (use `agent_name='diagnostic'` with payload.action_type)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:101:- Phase 1 Diagnostic-only: **1 of 6 artefacts attempted**; result is **REJECTED-after-hard-ceiling** awaiting founder arbitration via this disagreement doc
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:118:| Diagnostic | 5 (same as Round 5 but with Issue-5-validate-impl-gap replacing Issue-5-doc-shape) | `logs/codex-ratification/20260524T101934Z-19923/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:127:1. **Gate A vs ULTRAPLAN source-data citation strength** — every agent.md narrowed Gate A to per-section citation; ULTRAPLAN-equivalent requirements expect per-claim. Same issue, same disposition recommendation as Diagnostic Issue 1 — hybrid v0 per-section + W4 polish per-claim spot-check.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:128:2. **Workflow steps missing decision-log calls** — most agent.md files have at least one Step (notification, operator alert, status update) that produces side-effects without `hh_decision_*` call. Same disposition as Diagnostic Issue 2 — mechanical fix during W4-13 build slices when cycle.sh is implemented.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:130:4. **Sentinel agent_name usage** — _consultant_feedback (Diagnostic) is the clear case; other agents likely have similar invented sentinels. Disposition: prefer `agent_name='<agent>'` with `payload.action_type` markers; reserve sentinels for system actors (_renderer, _tenant_admin, _codex_ratifier).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:131:5. **§5 honesty about validate.sh implementation** — agent.md §5 sections describe Gate A behaviour that may not be implemented in the corresponding `validate.sh`. For Diagnostic, validate.sh exists + has gaps (Issue 5). For the 5 new scaffolds, validate.sh DOESN'T exist yet — §5 describes intent. Disposition: explicitly mark "intended behaviour; cycle.sh + validate.sh implementation at W-X build will deliver this" in §5 of each pre-build scaffold.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:144:- Per-claim Gate A validation is genuinely hard to automate (NLP claim-extraction + per-claim evidence linkage); the hybrid v0+W4 path is the industry-standard approach.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:147:- §5 honesty (Issue 5) is exactly the kind of "honest signal" the master brief §1 Rule 5 demands; framing §5 as "intended behaviour, build slice will deliver" is more honest than asserting Gate A as already-implemented.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:188:1. Gate B composite score (≥12.5) weakens dual ULTRAPLAN thresholds (15% dedup AND 10% field-completeness independently)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:214:1. `operator_notify_telegram` + `janitor_run_complete` are unregistered hh_decision_action types — hook-helpers fails them to red via `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`. (Found because my Round-6 commit added those calls without registering them.)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:256:- Cat-1 (Gate A hybrid): Diagnostic §1 verified already correct
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:259:- Cat-4 (sentinel hygiene): Diagnostic `_consultant_feedback` → agent_name='diagnostic' + payload.action_type
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:260:- Cat-5 (§5 honesty): 5 pre-build scaffolds gained explicit "validate.sh does NOT exist yet — W-X build slice delivers this contract" framing; Diagnostic gained warn-only-paths honesty note
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:261:- Cross-section consistency: removed (new — W-X catalogue add) annotations; ESC_AUTOSEND_BLOCKED kept red-tier-only; ESC_SCHEMA_VIOLATION kept schema-field-violation-only; ESC_VOICE_DRIFT_TENANT removed from direct firing across all agents; ESC_AUTOSEND_YELLOW_SPOT_CHECK → ESC_AUTOSEND_SAMPLED_SPOT_CHECK
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:272:| Diagnostic | 5 | `20260524T112636Z-79455` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:284:- Sourcing Scout ULTRAPLAN A5 line refs: Gate A 553→552, Gate B 554→553 (4 citation sites)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:306:- Diagnostic validate.sh: emits `ESC_SCHEMA_VIOLATION` not the specific codes declared in §6; doesn't write skip rows when honesty-flagging
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:307:- Diagnostic cycle.sh: sends Telegram directly via curl with no `hh_decision_action` row
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:314:  - Diagnostic Step 11 cycle.sh-vs-agent.md mismatch (above)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:324:**Cumulative empirical:** 9 Codex rounds total (Round 4-v1, 4-v2, 5, 6, 7 on Diagnostic/Janitor + Round 8 across all 6). **55+ unique findings catalogued across rounds, ~10-12 fixed via Cat-α mechanical disposition in this bilateral session; rest queued.**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:329:- Diagnostic: pre-build-with-honesty-notes; Round-8-reviewed; ~3 implementation-gap findings (Cat-δ) queued for W3-4 polish slice
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:348:## Phase 4 — Cat-γ widening + Cat-δ Diagnostic polish + Round 9 (2026-05-24, founder "proceed" instruction)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:361:### Cat-δ Diagnostic polish (commit `cbef6b5`)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:363:- `validate.sh` emits specific §6 ESC codes (ESC_PII_LEAKAGE_RISK or ESC_AGENT_OUTPUT_SHAPE) not generic ESC_SCHEMA_VIOLATION
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:364:- `cycle.sh` adds `hh_decision_action("operator_notify_telegram", ...)` call before Step 14 Telegram send
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:370:| Diagnostic | 5 | 5 | 0 (different findings; 2 Cat-δ closed, 2 new internal-consistency surfaced) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:382:**Diagnostic R9:**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:383:1. Gate A per-claim vs per-section: STILL flagged despite Cat-1 hybrid disposition; this is a Codex–founder disagreement, not relitigation of Cat-1 (founder's hybrid stance documented but Codex doesn't accept the bilateral-disposition framing as an in-band acceptance of weakening). **Disposition: founder-decision; flagged as Cat-ζ "Cat-1 framing not auto-accepted by Codex".**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:384:2. §1/§3 vs §5 internal inconsistency on Gate A hard-fail vs warn+skip — Cat-α (Diagnostic's hybrid framing introduced §1/§5 contradictions that need explicit reconciliation)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:386:4. §6 includes ESC_RENDERER_FAILED in "Diagnostic uses" table — Cat-α; remove
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:387:5. §6 says only one action_type but cycle.sh now has operator_notify_telegram (Round-9 introduced by Cat-δ commit) — Cat-α; align §6
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:398:**Cat-ζ — Codex does not accept bilateral-disposition framings as in-band Gate A acceptances.**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:400:When founder authorizes a Cat-1 hybrid disposition (per-section v0 + per-claim W4), the agent.md prose explicitly documents this. Codex re-flags it as "Gate A weakens upstream requirement" regardless. This is structural — Codex reviews agent.md against ULTRAPLAN/master brief, and bilateral disposition documents at `docs/decisions/codex-disagreement-*.md` are downstream artefacts Codex doesn't auto-trust.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:403:- **A) Amend ULTRAPLAN §8.1 A1 line 497** — change "no claims unsupported by source data" to "no claims unsupported at section level" to match v0 reality. Aggressive; rewrites upstream spec.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:413:**Stopping condition met:** founder's "proceed" → Cat-γ widening + Cat-δ Diagnostic polish + Round 9 + this categorization is the conclusive "RATIFY-or-document-disagreement" outcome per the bilateral disposition. No further autonomous remediation will be attempted.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/_supplementary/execution-plan.md:494:  - *Prompt:* "Write the IntelForce AI OS Support Playbook: the 20 most likely client support tickets (agent produced bad output, integration disconnected, can't log in, need user added, billing question, want to pause agent, want to rename agent, want new capability, approval queue stuck, question about a log entry, invoice dispute, want to downgrade, want to upgrade, data export request, GDPR DSAR, cancellation request, 'it's not working' vague, hallucination complaint, proposal draft was wrong, voice is drifting). Per ticket: diagnostic questions, resolution steps, escalation path, expected resolution time, template response."
docs/_supplementary/execution-plan.md:503:  - *Prompt:* "Write the Monitoring & Alert Playbook: every alert the observability stack fires, with for each: the condition that triggers it, the likely root causes, the diagnostic commands, the resolution steps, the escalation rules. Organise by severity tier."
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:1:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:5:**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:7:**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:13:ULTRAPLAN §8.1 A1 line 496 (pre-amendment wording — before this ADR's in-band edit landed in commit `aed9d3b`):
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:15:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:19:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:21:The "no claims unsupported by source data" clause implies **per-claim citation validation** — every factual claim in the report must have a backing source link. The Diagnostic v0 implementation at `agents/recruitment/diagnostic/validate.sh` enforces **per-section citation** (regex `\[.+\]\(.+\)` requires ≥1 markdown link per section); per-claim validation is NOT implemented at v0.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:23:(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract. Their v0 implementation in `validate.sh` is partial — `validate.sh` warns and emits `validate_check_skipped=true` when the voice-classifier URL is unreachable or the firm-domain whitelist is absent, rather than hard-failing; W4-polish closes these to hard-fail per `agents/recruitment/diagnostic/agent.md` §5 honesty note. These warn-only-paths exist in v0 but are not affected by this ADR; this ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:25:This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:31:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:41:### Decision 1 — Diagnostic Gate A citation validation is per-section coverage ONLY (hard-fail)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:43:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:45:The OTHER Gate A subchecks (voice classifier ≥ 0.75 and PII boundary) have v0 warn-only paths when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these are honesty-flagged with `validate_check_skipped=true` per the Context section above. W4-polish closes those subchecks to hard-fail. This ADR addresses only the per-section citation subcheck of Gate A; it does NOT modify the voice classifier or PII subchecks.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:47:### Decision 2 — Per-claim citation validation is a SEPARATE post-launch quality metric (NOT Gate A)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:49:The per-claim citation pipeline (NLP claim-extraction + per-claim evidence-link matching + aggregate quality metric) is **explicitly outside Gate A** in v1.0. It lands as:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:51:- A separate post-launch Diagnostic quality signal — analogous to Gate B's outcome threshold (30% discovery-call conversion) but for citation quality
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:54:- Activates after voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:56:**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:58:**Rule 4 (Quality gates before features) satisfied for the per-section citation subcheck:** it is hard-fail at v0 with no warn-only paths. (Other Gate A subchecks — voice classifier + PII — retain v0 warn-only paths when upstream services are unreachable per Context note; W4-polish closes those. ADR-006 addresses only the per-section subcheck.) Per-claim quality is a separate signal, not a weakening of Gate A's per-section subcheck.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:64:`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:66:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:70:> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — per-section citation subcheck is hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (a W4 ADR to be authored at first-pilot polish time).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:74:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:76:This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:83:- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:84:- A working v0 with per-section validation has measurable Gate A coverage; deferring means no Gate A at all in the meantime, which is strictly worse
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:85:- The 30%-discovery-call Gate B target is independent of per-claim validation; pilot value is reachable without it
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:95:- Pilot tenants reading Gate A spec see the v0 contract clearly + the W4 expansion plan
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:103:- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:104:- `agents/recruitment/diagnostic/validate.sh` retains current per-section enforcement (no implementation change)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:108:- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:113:- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the original ULTRAPLAN line 496 prose alone)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:121:- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:125:- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:126:- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:127:- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:150:- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:1:# Diagnostic report — Hays plc
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:3:**Generated:** 2026-05-24 by Intel Force OS Diagnostic agent (v0 — pre-W3 build).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:11:No active Companies House registration found for **Hays plc**. Diagnostic proceeded against publicly visible non-CH signals only.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:94:**Generation:** deterministic anchor-based fallback (ANTHROPIC_API_KEY not set OR LLM call failed). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0; W4-5 polish wires both LLM key + classifier.
docs/decisions/v1.0-kill-criterion.md:45:### Trigger 1 — DESIGN-PARTNER-BY-WEEK-2 (PAUSE)
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:69:**Action:** KILL state. Rationale: the renderer architecture (ADR-003) was ratified in Week 0 Day 1 evening as the load-bearing Week-1 prerequisite. If Week 3 ends with no clean Diagnostic render, the renderer has fundamental gaps that the design did not anticipate. The renderer cannot be "patched"; v1.0 cannot ship without working render. Continuing into Weeks 4+ without resolution is sunk-cost reasoning.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:158:### Trigger 8 — GATE-B-REVENUE-UPLIFT (KILL)
docs/decisions/v1.0-kill-criterion.md:160:**Threshold:** After 3 completed pilots (defined as: pilot ran for ≥90 days with active agent fleet and quarterly Gate B revenue measurement), average Gate B revenue uplift per tenant <£20k/year.
docs/decisions/v1.0-kill-criterion.md:186:### Trigger 10 — PII-LEAKAGE-INCIDENT (KILL)
docs/decisions/v1.0-kill-criterion.md:212:- For all KILL actions: founder decides; activates within 24h (within 4h for Trigger 10 PII per §3.5 emergency authority).
docs/decisions/v1.0-kill-criterion.md:226:- **Trigger 1 (Design partner) PAUSE → KILL escalation:** if PAUSE extends 4 weeks without signed LOI, founder consults Jack on whether to escalate to KILL (commercial assessment of pipeline) or extend PAUSE.
docs/decisions/v1.0-kill-criterion.md:227:- **Trigger 8 (Gate-B revenue) KILL:** founder decides KILL on revenue evidence; consults Jack on wind-down terms with existing pilots before 30-day notice goes out.
docs/decisions/v1.0-kill-criterion.md:237:### §3.5 — Emergency authority (Trigger 10 PII-LEAKAGE-INCIDENT specifically)
docs/decisions/v1.0-kill-criterion.md:239:Trigger 10 escalates regulatory-clock-driven actions. UK GDPR Art. 33 mandates ICO notification within 72 hours of discovery; multi-person consultation cannot delay this clock.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:371:**For Week 0 remaining.** Day 6 (vertical schema v0.1) and Day 7 (single-sentence test + Codex run) do not depend on this criterion directly. Day 7's question 1 (design partner LOI) is the structural Week-0 gate; this criterion's Trigger 1 (DESIGN-PARTNER-BY-WEEK-2) explicitly references that gap.
docs/decisions/v1.0-kill-criterion.md:373:**For Week 1-2.** All Week-1 work is conducted with awareness that Trigger 1 fires 2026-06-03 if no LOI (per §1 calendar — Wednesday end-of-Week-2). Founder allocates time accordingly: design-partner acquisition is a Week-1 sub-track, not an afterthought.
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:32:**Alternative timing:** Insert as next IFOS Claude slice now (post-Diagnostic-build, ~Week 8). Marginal benefit: D1 becomes a closed item earlier; bridge gets stress-tested before Concierge needs it. Cost: 2-3 days inserted before Concierge.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:58:**Cost of delay:** Trigger 1 fires 2026-06-03 if no LOI. If LOI lands but advisor isn't engaged, founder has to choose between violating kill-criterion §3.4 or delaying LOI past Trigger 1. Engage now to avoid the forced choice.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:80:**Cost of delay:** Same as D2 — Trigger 1 fires 2026-06-03. If LOI lands before D3 resolves, founder ships v1.0 with D3-A indefinite retention, which is the worst legal posture. Bundle D2 + D3 resolution.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:1:# Diagnostic report — Hays plc
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:3:**Generated:** 2026-05-24 by Intel Force OS Diagnostic agent (v0 — pre-W3 build).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:11:No active Companies House registration found for **Hays plc**. Diagnostic proceeded against publicly visible non-CH signals only.
packages/harness/cortextos/dashboard/src/app/globals.css:172:  --foreground: oklch(0.187 0 0);                /* #1A1A1A */
packages/harness/cortextos/dashboard/src/app/globals.css:222:  --secondary: oklch(0.187 0 0);                 /* #1A1A1A */
packages/harness/cortextos/dashboard/src/app/globals.css:224:  --muted: oklch(0.187 0 0);                    /* #1A1A1A */
docs/decisions/brain-ui-scope.md:43:- Highlights `ESC_*` escalations across all agents — `ESC_BULLHORN_AUTH`, `ESC_VOICE_DRIFT`, `ESC_DUPLICATE_DETECTED`, `ESC_RENDERER_FAILED`, etc.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:36:- **Kill criterion linkage:** Trigger 1 in `docs/decisions/v1.0-kill-criterion.md` §2 (DESIGN-PARTNER-BY-WEEK-2) fires end-of-day **2026-06-03** if no signed LOI by then. That is the binding tripwire — currently **14 calendar days** out from today (2026-05-20).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:68:- **Sequencing:** `docs/decisions/sequencing-target.md` §4.1 ratifies the 6-agent build order; renderer is Week 1-2 prerequisite for the Diagnostic W3-4 first render per ADR-003 §5.2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:71:- **Risk #5 (renderer-not-built)** in `docs/RISK-REGISTER.md` reduced from Blocking → High on Day 1 evening when ADR-003 + design doc Accepted. Three-stage ladder to Medium (W4 first Diagnostic render) → Low (W13 all 5 v1.0 bundles rendered).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:90:| 1 | Design partner pilot Q3 2026 LOI? | **NO** | High — zero pipeline; Risk #3 High; Trigger 1 fires 2026-06-03 |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:117:6. **Renderer implementation per ADR-003** — ALLOWED in code repo but agent-build slices (Diagnostic et al.) DO NOT start until Q1 turns YES. Renderer can scaffold independently.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:121:1. **Diagnostic W3-4 agent build** — blocked; requires Q1=YES.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:142:- Q1 + Q3 = YES → Week 0 cleanly closes; Week 1 starts; Diagnostic W3-4 build begins.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:143:- Q1 = YES, Q3 = NO (accepted) → Week 0 closes by founder discretion; Week 1 starts with Risk #2 elevated; Diagnostic W3-4 begins under accepted risk; Janitor W5 contingent on Q3 clearing by then.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:148:- Trigger 1 (kill criterion DESIGN-PARTNER-BY-WEEK-2 PAUSE): fires end-of-day **2026-06-03** if no signed LOI.
docs/decisions/ADR-003-agent-bundle-renderer.md:109:> # 5. validate.sh (Gate A; sources _shared/hook-helpers.sh)
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/ADR-003-agent-bundle-renderer.md:147:**For Risk #5 (renderer-not-built).** Severity drops from **Blocking** to **High** with ADR-003 Accepted — design exists, ratified; just needs implementing. Drops to **Medium** once renderer code is committed and the Diagnostic agent renders cleanly (Week 4). Drops to **Low** once all five v1.0 agent bundles render and pass validation. The risk register entry is updated in this session as part of the ADR-003 commit.
packages/mcp-connectors/companies-house/package.json:5:  "description": "IFOS Companies House MCP connector — search + profile + officers + filing history. Used by Diagnostic agent §4 Step 2 + 10 per agents/recruitment/diagnostic/tools.yaml.",
docs/decisions/autosend-approval-bridge-spec.md:142:| `diagnostic_email_send` | `external-comms` |
docs/decisions/autosend-approval-bridge-spec.md:143:| `diagnostic_calendar_invite` | `external-comms` |
docs/decisions/autosend-approval-bridge-spec.md:239:| A1 | Bridge process starts via PM2 + connects to Postgres + reads bridge state | `pm2 status ifos-autosend-bridge` shows online; bridge starts fresh on empty DB |
docs/decisions/autosend-approval-bridge-spec.md:248:| A10 | Live VPS smoke: real Telegram chat receives approval message + button press routes back to marker | Founder Path A manual test on migration-test tenant |
docs/decisions/autosend-approval-bridge-spec.md:259:**Alternative:** as the next IFOS Claude slice (now). Pre-builds the prerequisite before Diagnostic W3-4 starts, so it's not blocking Concierge. ~2-3 days inserted before Diagnostic.
docs/decisions/autosend-approval-bridge-spec.md:261:**Founder decision:** schedule for Week 9 (sequential with master brief) OR insert now (parallel with Diagnostic prep).
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:1:# ADR-005 — Week-3 Diagnostic acceleration (Bullhorn MCP deferred)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:5:**Companion:** `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 execution prompt)
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
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:58:- ✅ Web scraper + Companies House MCP connector + diagnostic-generator package shipped Day 13 (commits `800a265`, `860f29c`, `5614dcb`, `fd38254`)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:59:- ✅ Real end-to-end pipeline verified Day 13 (Gate A PASS on fake-firm smoke test)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:61:- ⏸ Iteration on Diagnostic output quality across 10-20 real UK firms
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:85:- Q1 LOI gate (Jack's lane; Trigger 1 fires 2026-06-03 if no LOI)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:95:| diagnostic-generator package + cycle.sh wiring | ✅ | `fd38254` |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:108:- `sequencing-target.md` §3.1 (Build Wave 1 = Diagnostic)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:109:- `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render by 2026-06-14)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:111:- `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 execution prompt)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:118:| Does the Diagnostic v0 produce reports good enough to send Jack for Q1 pitch? | Iteration loop in W3 polish (Step 7 + follow-ups). Quality gate: founder approval after running against 5-10 real firms. |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:120:| Does this break the master plan's "do not build out of order" rule? | No: ordering of agents (Diagnostic first) is preserved; only the substrate-vs-agent ordering within Weeks 3-4 is swapped, which §1.4 fallback architecture explicitly anticipates |
docs/decisions/sequencing-target.md:21:| A1 | Diagnostic | 3-4 | LinkedIn + Companies House + scrape | "Sales tool — needed before any other agent matters" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:92:### 2.1 — A1 Diagnostic
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:99:| 4. Commercial value | **Medium** | Internal sales tool per Product Spec §2.2 R13 ("Not on the customer pricing card"). Drives qualified discovery-call pipeline. Demoable to a prospect but not the closing demo. Ultraplan §8.1 line 499 Gate B target: "≥30% of diagnostics produced lead to a discovery call booked" |
docs/decisions/sequencing-target.md:100:| 5. Dependencies on other agents | **None** | Standalone. No upstream agent dependency; no downstream agent consumes Diagnostic output |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:110:| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
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
docs/decisions/sequencing-target.md:300:**Trigger 1 — Risk #2 materialises in Week 4-5.** If Bullhorn auth path breaks (Day 2 Sub-decisions A or B don't flip to Accepted, marketplace required but unobtainable, OAuth flow blocks deployment, or per-tenant client_id ticket cycle slows past 5 business days per `bullhorn-integration-path.md` §1.3 row 5):
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:311:- **Updates required:** same set as Trigger 1 plus founder's Q3 personal cadence (Cash Conductor's L/2-week build becomes founder solo at W7-8, slowing but not blocking).
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:326:- The substrate-first principle (Diagnostic W3-4 before any Bullhorn-touching agent).
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:373:3. **Either fix-and-retry (1 additional week)** or **scope-cut contingency activates** per §4.3 Trigger 1 (if Risk #2 derived) or §4.3 Trigger 2 (if Risk #4 derived).
docs/decisions/sequencing-target.md:395:### 6.2 — For Week 3 (Diagnostic build start)
docs/decisions/sequencing-target.md:399:- Smallest viable Diagnostic exercising renderer + `_shared/` + `decision_log` end-to-end per §2.1 substrate-exercise column.
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:402:- First production render lands W4 per ADR-003 design §5.2 line "First production render is the Diagnostic agent at Week 4."
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:410:§4.3 Trigger 1 activation point: end of W4 weekly review if Sub-decisions A and B still Proposed.
docs/decisions/sequencing-target.md:414:Diagnostic W3-W4 build window is the first production renderer exercise per ADR-003 design §5.2. The reduction-trigger cascade per `docs/RISK-REGISTER.md` Risk #5 fires:
docs/decisions/sequencing-target.md:417:- W4 Diagnostic first-render-clean → **Medium** (renderer code proven against one production bundle).
docs/decisions/sequencing-target.md:438:- **Diagnostic doesn't render by end of W3** (Risk #5 unmitigated; renderer impl Week 1-2 didn't ship)
docs/decisions/sequencing-target.md:450:- §5 gating criteria N values are calibrated to agent-specific risk profile (Cash Conductor's 24h sustained-operation vs Diagnostic's 3 ad-hoc runs).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:494:| W3 vs W4 framing | §6.2 + §6.4 | Build-window-vs-completion-week distinction: Diagnostic build W3-W4, first production render W4. Not a true discrepancy. |
docs/decisions/sequencing-target.md:507:| Substrate readiness for W3 Diagnostic build (renderer + `_shared/` + `decision_log`) | Claude Code | End of W2 | Already tracked from ADR-002 + ADR-003 |
docs/decisions/sequencing-target.md:520:| Diagnostic W3 build start (vs W4 first render) | If renderer impl slips past end of W2, Diagnostic build start slips correspondingly |
packages/mcp-connectors/companies-house/README.md:3:IFOS Companies House MCP connector for Diagnostic agent §4 Step 2 + 10 per `agents/recruitment/diagnostic/tools.yaml`.
packages/mcp-connectors/companies-house/README.md:34:| 429 | Rate limited; back off 60s, retry once | ESC_RATE_LIMIT_HIT |
packages/mcp-connectors/companies-house/README.md:66:v0.1 — Diagnostic v1.0 dependency per `agents/recruitment/diagnostic/tools.yaml`.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:20:**Counter:** Codex is applying the Day-7 single-sentence-test Q3 quality gate ("ATS decided + auth cleared") as if it were a Week-1 implementation gate. The Q3 gate is correct as a closing-of-Week-0 gate per master brief §6 line 502, and Q3 = NO is exactly why Week 0 EXTENDS per the Day-7 single-sentence-test result. But the Q3 gate governs **named v1.0 agent-build slices** (Diagnostic W3-4, Janitor W5, etc.), NOT Week-1 prerequisite code.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:31:Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:41:| Diagnostic build (W3-4) | None — Diagnostic doesn't touch Bullhorn | Awaits Q1 LOI |
docs/decisions/2026-05-18-codex-ratification-manifest.md:109:## §1.10 — Codex Round 4 queue (Week 3 Diagnostic + 5 agent.md scaffolds)
docs/decisions/2026-05-18-codex-ratification-manifest.md:111:Round 4 scheduled across Week 3 (Days 14-20) per `docs/operations/goal-week-3-polish-and-scaffold.md` Steps 7 (Diagnostic-only, Day 15) + 13 (full run, Day 20). Per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 remediation max).
docs/decisions/2026-05-18-codex-ratification-manifest.md:115:**Phase 1 (Day 15) — Diagnostic-only mid-week ratification.** Reason: substrate must be verified before 5 new scaffolds reference it. 6 items, all `review-architecture-decision.md` skill except the package-as-a-whole.
docs/decisions/2026-05-18-codex-ratification-manifest.md:119:| 1 | `agents/recruitment/diagnostic/agent.md` | Proposed → Accepted (post-W3 polish) | `review-architecture-decision.md` | Was Round-3 RATIFIED at scaffold form; re-ratify after Day-13 + Step-3 fixes (firm-slug, suffix-strip) + Step-4 LLM §12 wiring |
docs/decisions/2026-05-18-codex-ratification-manifest.md:120:| 2 | `agents/recruitment/diagnostic/tools.yaml` | Proposed | `review-architecture-decision.md` | First ratification (Day-12 scaffold) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:121:| 3 | `agents/recruitment/diagnostic/cycle.sh` | Proposed | `review-architecture-decision.md` | Post-Day-13 generator wiring (commit `fd38254`) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:122:| 4 | `agents/recruitment/diagnostic/validate.sh` | Proposed | `review-architecture-decision.md` | Post-Day-13 V2 awk-pass fix (commit `97a57a2`) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:123:| 5 | `packages/diagnostic-generator/` (package as a whole) | Proposed | `review-architecture-decision.md` | Day-13 ship; first ratification |
docs/decisions/2026-05-18-codex-ratification-manifest.md:124:| 6 | `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` | Accepted | `review-architecture-decision.md` | Day-13 sequencing decision; first ratification |
docs/decisions/2026-05-18-codex-ratification-manifest.md:138:**Day-19 update:** Initial Round-4 Phase-1 attempt used `review-architecture-decision.md` skill (the only available skill at the time). That returned REJECTED with a load-bearing finding (Issue 5 in `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`) — agent.md files require a different skill structure. **`review-agent-bundle.md` skill built in commit `825ebd4`.** Re-ratification of all 6 agent.md items with the new skill.
docs/decisions/2026-05-18-codex-ratification-manifest.md:144:| 1 | `agents/recruitment/diagnostic/agent.md` | **REJECTED** | 5 real findings (Gate A strength + Step 11 decision-log + Trigger 8 mismap + sentinel + validate.sh gap) | `20260524T101934Z-19923` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:186:| 17 | v1.0-kill-criterion.md | REJECTED (3 issues) | All three (Trigger 1 date / Trigger 2 CLI / Trigger 4 threshold) **incorporated** at `2b287d3`. |
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:104:| Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (`sequencing-target.md` §2.1) | Awaits Q1 LOI |
docs/decisions/bullhorn-integration-path.md:226:**Scope of permissions requested at first auth:** Bullhorn's OAuth docs surveyed do not specify per-scope strings (e.g. `read:candidate`, `write:note`). REST API access appears to be at-tenant-admin-discretion — the admin authorises the connected app for "API access" generally, and the corpToken-scoped session inherits whatever entity permissions the admin's account holds. **Spec gap §3.1-B:** confirm with Bullhorn developer support that there is no per-entity-type scope granularity at the OAuth layer — i.e. IFOS cannot request "read-only" auth and get a token that can't write. If this is correct, then Gate A in `validate.sh` (per master brief §1 Rule 4) becomes the only enforcement layer for "this agent should never write" — the OAuth token itself does not protect.
docs/decisions/bullhorn-integration-path.md:268:- Confirm there is no per-entity-type OAuth scope granularity at the OAuth layer (Spec gap §3.1-B) — required so IFOS's Gate A enforcement model (validate.sh) is the correct safeguard.
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:289:| **A1 Diagnostic** (no Bullhorn) | n/a | n/a | n/a | n/a | n/a | n/a — runs against public footprint per Ultraplan §8.1 line 489 |
docs/decisions/bullhorn-integration-path.md:340:**Reserve 30% headroom** for error/retry overhead per §2.2 (429 + wait-1s retry pattern). Effective budget for first-attempt productive calls: ~280-700 req/hour/tenant.
docs/decisions/bullhorn-integration-path.md:486:| Rate-limit budget allocation | §4.4 | Conservative v1.0 defaults (400-1000 req/hour/tenant total; 30% reserve); revise when Bullhorn confirms actuals |
docs/decisions/bullhorn-integration-path.md:509:| §3.1-B: assume no per-entity OAuth scope granularity → `validate.sh` Gate A is the only enforcement layer | Bullhorn dev support confirms different — adjust connector auth-module to request scoped tokens |
docs/decisions/ADR-004-renderer-implementation-deviations.md:144:**For Risk #5 (renderer-not-built).** Severity unchanged at High per ADR-003 line 145 staged ladder ("Drops to Medium once renderer code is committed AND the Diagnostic agent renders cleanly (Week 4)"). The Phase-2 commit `3c16d35` satisfies the first condition; the second condition (Diagnostic render) is gated on Q1 design-partner LOI. ADR-004 closes a stylistic gap (3 deviations) but does not change risk severity.
docs/decisions/ADR-004-renderer-implementation-deviations.md:150:**For future Diagnostic builds.** Decision 1 means agents/runbooks/onboarding-wizard documentation references `ifos-render-agent`, not `cortextos-ifos render-agent`. Cheap to update everywhere because no documentation has shipped yet — only ADR-003 + master brief §8.3 reference the old name, and both are addressed in §"Master brief edits authorised."
packages/mcp-connectors/companies-house/pnpm-lock.yaml:384:    resolution: {integrity: sha512-+A1NJmfM8WNDv5CLVQYJ5PshuRm/4cI6WMZRg1by1GwPIQPCTs1GLEUHwiiQGT5zDdyLiRM/l1G0Pv54gvtKIg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:571:    resolution: {integrity: sha512-FJHFfqpKUI3A10WrWKiFbBZ7yVbGT4q4B5o1qKFFojqpaYoh9LrQgqWCmmcxQzVSXYtyB5bzkXrYzlHTs21MYA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:626:    resolution: {integrity: sha512-QVTUovf40zgTqlFVrKA1uXMVvU2QWEFWfAH8Wdc48IxLvrJMQVMBRjuQyUpzZCDkakImib9eVazbWlC6ksWtJw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:814:    resolution: {integrity: sha512-//nshmD55c46FuFw26xV/xFAaB5HF9Xdap7HJBBnrKdAd6/GxDBaNA1870O79+9ueg61cZLSVc+OaFlfmObYVQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:965:    resolution: {integrity: sha512-o5a9xKjbtuhY6Bi5S3+HvbRERmouabWbyUcpXXUA1u+GNUKoROi9byOJ8M0nHbHYHkYICiMlqxkg1KkYmm25Sw==}
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
packages/harness/cortextos/tests/unit/bus/oauth.test.ts:230:    writeStore(); // primary at 30%/20% — below thresholds
packages/harness/cortextos/dashboard/public/file.svg:1:<svg fill="none" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><path d="M14.5 13.5V5.41a1 1 0 0 0-.3-.7L9.8.29A1 1 0 0 0 9.08 0H1.5v13.5A2.5 2.5 0 0 0 4 16h8a2.5 2.5 0 0 0 2.5-2.5m-1.5 0v-7H8v-5H3v12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1M9.5 5V2.12L12.38 5zM5.13 5h-.62v1.25h2.12V5zm-.62 3h7.12v1.25H4.5zm.62 3h-.62v1.25h7.12V11z" clip-rule="evenodd" fill="#666" fill-rule="evenodd"/></svg>
packages/harness/cortextos/community/agents/security/.claude/skills/system-diagnostics/SKILL.md:2:name: system-diagnostics
packages/harness/cortextos/community/agents/security/.claude/skills/system-diagnostics/SKILL.md:3:description: "Something in the system feels stuck or wrong — tasks are not moving, an agent has gone quiet, goals have not been updated in days, or the orchestrator has asked for a system health report. You need to run a structured check: stale tasks, stale goals, overdue human tasks, fleet heartbeat status, and metrics. This is your diagnostic toolkit. Run it on every heartbeat (orchestrator) and whenever something seems off."
packages/harness/cortextos/community/agents/security/.claude/skills/system-diagnostics/SKILL.md:7:# System Diagnostics
packages/harness/cortextos/templates/analyst/.claude/skills/system-diagnostics/SKILL.md:2:name: system-diagnostics
packages/harness/cortextos/templates/analyst/.claude/skills/system-diagnostics/SKILL.md:3:description: "Something in the system feels stuck or wrong — tasks are not moving, an agent has gone quiet, goals have not been updated in days, or the orchestrator has asked for a system health report. You need to run a structured check: stale tasks, stale goals, overdue human tasks, fleet heartbeat status, and metrics. This is your diagnostic toolkit. Run it on every heartbeat (orchestrator) and whenever something seems off."
packages/harness/cortextos/templates/analyst/.claude/skills/system-diagnostics/SKILL.md:7:# System Diagnostics
packages/harness/cortextos/templates/orchestrator/.claude/skills/system-diagnostics/SKILL.md:2:name: system-diagnostics
packages/harness/cortextos/templates/orchestrator/.claude/skills/system-diagnostics/SKILL.md:3:description: "Something in the system feels stuck or wrong — tasks are not moving, an agent has gone quiet, goals have not been updated in days, or the orchestrator has asked for a system health report. You need to run a structured check: stale tasks, stale goals, overdue human tasks, fleet heartbeat status, and metrics. This is your diagnostic toolkit. Run it on every heartbeat (orchestrator) and whenever something seems off."
packages/harness/cortextos/templates/orchestrator/.claude/skills/system-diagnostics/SKILL.md:7:# System Diagnostics
packages/harness/cortextos/templates/agent/.claude/skills/system-diagnostics/SKILL.md:2:name: system-diagnostics
packages/harness/cortextos/templates/agent/.claude/skills/system-diagnostics/SKILL.md:3:description: "Something in the system feels stuck or wrong — tasks are not moving, an agent has gone quiet, goals have not been updated in days, or the orchestrator has asked for a system health report. You need to run a structured check: stale tasks, stale goals, overdue human tasks, fleet heartbeat status, and metrics. This is your diagnostic toolkit. Run it on every heartbeat (orchestrator) and whenever something seems off."
packages/harness/cortextos/templates/agent/.claude/skills/system-diagnostics/SKILL.md:7:# System Diagnostics
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/system-diagnostics/SKILL.md:2:name: system-diagnostics
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/system-diagnostics/SKILL.md:3:description: "Something in the system feels stuck or wrong — tasks are not moving, an agent has gone quiet, goals have not been updated in days, or the orchestrator has asked for a system health report. You need to run a structured check: stale tasks, stale goals, overdue human tasks, fleet heartbeat status, and metrics. This is your diagnostic toolkit. Run it on every heartbeat (orchestrator) and whenever something seems off."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/system-diagnostics/SKILL.md:6:# System Diagnostics

codex
The section structure is present and ordered. I’m narrowing on verifiable blockers now: policy file name/citations, live bundle behavior, escalation definitions, and whether the text claims capabilities the actual files don’t implement.
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '480,505p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,615p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   496	- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
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
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '110,195p' && nl -ba agents/_shared/escalation-codes.md | sed -n '360,390p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,150p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/tools.yaml | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/cycle.sh | sed -n '1,280p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/validate.sh | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
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
   235	  #   - Voice classifier score <0.75 (V3) → ESC_VOICE_DRIFT (warn, per
   236	  #     fixture 99-voice-drift-canary.yaml expectation)
   237	  #   - Output-shape violation (section count, per-section citation,
   238	  #     length) → ESC_AGENT_OUTPUT_SHAPE (warn)
   239	  # ESC_SCHEMA_VIOLATION is reserved for vertical-schema field-constraint
   240	  # violations at write time per catalogue line 163 — not for Diagnostic's
   241	  # output-shape failures.
   242	  PII_FAILURE_PRESENT=0
   243	  VOICE_FAILURE_PRESENT=0
   244	  for failure in "${FAILURES[@]}"; do
   245	    if [[ "${failure}" == *"PII"* || "${failure}" == *"pii"* ]]; then
   246	      PII_FAILURE_PRESENT=1
   247	    elif [[ "${failure}" == *"voice"* || "${failure}" == *"Voice"* || "${failure}" == *"V3"* ]]; then
   248	      VOICE_FAILURE_PRESENT=1
   249	    fi
   250	  done
   251	
   252	  if (( PII_FAILURE_PRESENT == 1 )); then
   253	    ESC_CODE="ESC_PII_LEAKAGE_RISK"
   254	  elif (( VOICE_FAILURE_PRESENT == 1 )); then
   255	    ESC_CODE="ESC_VOICE_DRIFT"
   256	  else
   257	    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"
   258	  fi
   259	
   260	  ESC_PAYLOAD=$(printf '{"escalation_code":"%s","draft_path":"%s","failures":%s}' \

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/context.sh | sed -n '130,175p' && nl -ba agents/_shared/voice-loader.sh | sed -n '70,245p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/validate.sh | sed -n '260,340p' && nl -ba agents/_shared/hook-helpers.sh | sed -n '1,230p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	  ESC_PAYLOAD=$(printf '{"escalation_code":"%s","draft_path":"%s","failures":%s}' \
   261	    "${ESC_CODE}" \
   262	    "${DRAFT}" \
   263	    "$(printf '%s\n' "${FAILURES[@]}" | python3 -c "import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))" 2>/dev/null || echo '[]')")
   264	
   265	  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \
   266	    "$(echo "${ESC_PAYLOAD}" | shasum | awk '{print $1}')" \
   267	    "${ESC_PAYLOAD}" 2>/dev/null || true
   268	
   269	  exit 1
   270	fi
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
    31	_HH_POLICY_FILE="${HH_POLICY_FILE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/autosend-policy.yaml}"
    32	_HH_ESC_CATALOGUE="${HH_ESC_CATALOGUE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/escalation-codes.md}"
    33	
    34	# Fallback file used when IFOS_DB_URL is unset OR psql is unavailable.
    35	# Resolved at first call to _hh_emit_row().
    36	_hh_resolve_fallback_path() {
    37	  if [[ -n "${IFOS_DECISION_LOG_FALLBACK:-}" ]]; then
    38	    printf '%s' "${IFOS_DECISION_LOG_FALLBACK}"
    39	    return 0
    40	  fi
    41	  local tenant="${CTX_TENANT_SLUG:-unknown}"
    42	  local vault_root="${IFOS_VAULT_ROOT:-/vault}"
    43	  printf '%s/%s/decision-log.jsonl' "${vault_root}" "${tenant}"
    44	}
    45	
    46	# JSON escape a single string for inclusion in a JSON value.
    47	# Use this when BUILDING a JSON document from plain text.
    48	_hh_json_escape() {
    49	  local input="$1"
    50	  input="${input//\\/\\\\}"
    51	  input="${input//\"/\\\"}"
    52	  input="${input//$'\n'/\\n}"
    53	  input="${input//$'\r'/\\r}"
    54	  input="${input//$'\t'/\\t}"
    55	  printf '%s' "${input}"
    56	}
    57	
    58	# SQL escape a string for inclusion in a single-quoted SQL string literal.
    59	# Use this when EMBEDDING values in psql SQL. Doubles single quotes;
    60	# leaves everything else (incl. backslashes, JSON internal " characters)
    61	# alone — Postgres standard_conforming_strings=on (default since 9.1)
    62	# treats backslash as literal.
    63	_hh_sql_escape() {
    64	  local input="$1"
    65	  printf '%s' "${input//\'/\'\'}"
    66	}
    67	
    68	# Current ISO-8601 UTC timestamp with millisecond precision where available.
    69	# GNU date supports %3N (3-digit nanoseconds → milliseconds). BSD date
    70	# (macOS default) does NOT error on the spec but outputs the literal
    71	# string "3N" instead, which Postgres rejects as invalid timestamptz.
    72	# Detect by checking that %3N produced exactly 3 digits.
    73	_hh_now_iso() {
    74	  local ms
    75	  ms=$(date -u +"%3N" 2>/dev/null)
    76	  if [[ "${ms}" =~ ^[0-9]{3}$ ]]; then
    77	    date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
    78	  else
    79	    date -u +"%Y-%m-%dT%H:%M:%SZ"
    80	  fi
    81	}
    82	
    83	# Validate that ESC code exists in the catalogue.
    84	# Returns 0 if known, 1 otherwise. Catalogue absent → permissive (return 0).
    85	_hh_validate_esc_code() {
    86	  local code="$1"
    87	  if [[ ! -f "${_HH_ESC_CATALOGUE}" ]]; then
    88	    return 0
    89	  fi
    90	  if grep -Fq "\`${code}\`" "${_HH_ESC_CATALOGUE}"; then
    91	    return 0
    92	  fi
    93	  return 1
    94	}
    95	
    96	# ────────────────────────────────────────────────────────────────────────
    97	# Core decision-log writer
    98	# ────────────────────────────────────────────────────────────────────────
    99	
   100	# _hh_emit_row <phase> <outcome> <reason> <payload_json>
   101	#
   102	# Writes one row to decision_log. Live mode (IFOS_DB_URL set + psql available):
   103	# INSERT via psql -v ON_ERROR_STOP=1. Offline mode: append JSON line to
   104	# fallback file. The two formats are reconcilable by the sync worker.
   105	_hh_emit_row() {
   106	  local phase="$1"
   107	  local outcome="${2:-}"
   108	  local reason="${3:-}"
   109	  local payload_json="${4:-{\}}"
   110	
   111	  local tenant agent created_at
   112	  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   113	  agent="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"
   114	  created_at="$(_hh_now_iso)"
   115	
   116	  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   117	    local sql
   118	    sql=$(cat <<EOF
   119	BEGIN;
   120	SET LOCAL app.current_tenant = '$(_hh_sql_escape "${tenant}")';
   121	INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
   122	VALUES (
   123	  '$(_hh_sql_escape "${tenant}")',
   124	  '$(_hh_sql_escape "${agent}")',
   125	  '$(_hh_sql_escape "${phase}")',
   126	  $([ -z "${outcome}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${outcome}")"),
   127	  $([ -z "${reason}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${reason}")"),
   128	  '$(_hh_sql_escape "${payload_json}")'::jsonb,
   129	  '${created_at}'::timestamptz
   130	);
   131	COMMIT;
   132	EOF
   133	)
   134	    local psql_err
   135	    psql_err=$(printf '%s\n' "${sql}" | psql -v ON_ERROR_STOP=1 -q "${IFOS_DB_URL}" 2>&1)
   136	    if [[ $? -eq 0 ]]; then
   137	      return 0
   138	    fi
   139	    # psql failed — fall through to fallback append + emit warning to stderr
   140	    printf 'hh_emit_row: psql write failed; appending to fallback\n' >&2
   141	    printf 'hh_emit_row: psql error: %s\n' "${psql_err}" >&2
   142	  fi
   143	
   144	  local fallback
   145	  fallback="$(_hh_resolve_fallback_path)"
   146	  mkdir -p "$(dirname "${fallback}")" 2>/dev/null || true
   147	
   148	  local row
   149	  row=$(printf '{"tenant_slug":"%s","agent_name":"%s","phase":"%s","outcome":%s,"reason":%s,"payload":%s,"created_at":"%s","_hh_version":"%s"}' \
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

codex
One load-bearing mismatch has surfaced: the document claims a session-start `hh_decision_trigger` row, but the actual `cycle.sh` path I read does not emit one before generation. I’m checking whether there are additional independent blockers before returning the verdict.
exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md | sed -n '1,220p' && nl -ba docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '1,140p' && nl -ba docs/decisions/sequencing-target.md | sed -n '1,95p' && nl -ba docs/runbooks/operational-hygiene-protocol.md | sed -n '1,130p'" in /Users/madsadmin/code/CortexOS
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
     1	# Operational hygiene protocol — A-grade discipline rules
     2	
     3	**Status:** In force (Day 6, 2026-05-18). All sections from Week 0 onwards reference this document at section-gate moments.
     4	**Author:** Claude Code + founder (Maddox), Day-6 evening 2026-05-18
     5	**Source:** Lessons from Days 0-6 execution. Bumps three operational-grade dimensions from B+/C+/B → A by codifying what was previously implicit.
     6	**Audience:** This session and every future session. Reference at the start of any work that involves credentials, runbooks, drafts, or citations.
     7	
     8	---
     9	
    10	## §1 — Why this document exists
    11	
    12	Days 0-6 self-grade on Week-0 retrospective (Day-6 evening):
    13	
    14	| Dimension | Day-6 grade | A-grade target |
    15	|---|---|---|
    16	| Architectural rigour | A | maintain |
    17	| Honest signal | A | maintain |
    18	| Process discipline | A− | maintain |
    19	| **Operational hygiene** | **B+** | A |
    20	| **Length discipline** | **C+** | A |
    21	| **Citation accuracy** | **B** | A |
    22	
    23	The B+/C+/B grades reflect specific lapses where the discipline was implicit rather than written down:
    24	
    25	- **Operational hygiene B+** — Path B was allowed mid-Day-4 (LUKS passphrase entered chat); Day 4 execution had self-inflicted deviations (defensive `sudo file -s` check; missing `sudo` on `sshd -T`; outdated `findmnt` regex)
    26	- **Length discipline C+** — Day 5 autosend policy 658 lines vs 300-500 estimate; Day 6 vertical schema 899 lines vs same estimate
    27	- **Citation accuracy B** — Day 5 §4.1 should have been §4.1 + §6.3 (caught in review); Day 6 "30+" action_type claim was actually 29 (caught in review); **15 fabricated "master brief §10.4" references propagated across 5 files** (caught in Day-6-evening citation audit; see §7 below)
    28	
    29	This document codifies the rules to bring all three to A. Reference it at the section-gate moment of any future work that touches the relevant surface.
    30	
    31	---
    32	
    33	## §2 — Credential-bearing operations: Path A / Path D protocols
    34	
    35	Three named protocols for handling credentials in IFOS operations. Path A is the default for entering existing credentials; Path D is the default for generating new credentials. **Path B is forbidden absent explicit per-session founder waiver.**
    36	
    37	### §2.1 — Path A (default for credential entry)
    38	
    39	**Definition:** Founder enters credentials in their own local terminal session. Credentials never appear in Claude Code chat context, tool input, tool output, or anywhere a transcript could capture them.
    40	
    41	**Use cases:**
    42	- LUKS passphrase entry at `cryptsetup luksFormat` / `luksOpen` / `luksChangeKey`
    43	- Postgres role passwords typed into `psql` prompts
    44	- API tokens entered into Console UIs
    45	- Any password prompt that the application requests interactively
    46	
    47	**Mechanism:**
    48	1. Claude Code prepares the command and surfaces it to the founder
    49	2. Founder opens a fresh local terminal (or uses an existing one outside Claude Code's tool scope)
    50	3. Founder runs the command interactively
    51	4. Founder reports back: success / failure + relevant non-credential output
    52	
    53	**Trade-off:** ~30-90 seconds of founder time per interactive step vs. zero credential exposure.
    54	
    55	**Day-4 lesson:** Path A was the initial agreed protocol for §4.2 luksFormat + §4.3 luksOpen + §4.8 ifos-unlock end-to-end test. Path B was authorised mid-Day-4 for the ifos-unlock test specifically; the operational friction of Path A was found acceptable for first-use (luksFormat) but unacceptable for repeated use (ifos-unlock). Mitigation: Path D pattern (§2.3) eliminates many would-be-Path-B cases by generating credentials on-VPS where they never need to be re-entered.
    56	
    57	### §2.2 — Path B (FORBIDDEN absent explicit waiver)
    58	
    59	**Definition:** Credential enters Claude Code chat context, then gets piped via stdin or written to a temporary file for command execution.
    60	
    61	**Why forbidden:**
    62	- Chat transcript captures the credential
    63	- Future transcript export, search history, or harness telemetry retains it
    64	- Cannot be scrubbed retroactively
    65	- Required to rotate the credential post-use to invalidate the transcript-captured copy
    66	
    67	**Waiver process if Path B is genuinely needed:**
    68	1. Founder types literally: `Path B: protocol override authorised` followed by the credential on a new line
    69	2. Claude Code uses the credential once, immediately
    70	3. Founder **MUST rotate the credential within 24 hours** — non-negotiable. `cryptsetup luksChangeKey` for LUKS; equivalent rotation API for Postgres/OAuth/etc.
    71	4. Rotation **MUST be verified** — for LUKS, `cryptsetup luksChangeKey --test-passphrase` confirms OLD rejected + NEW accepted; for Postgres, `psql -c "SELECT 1;"` with OLD credentials fails and with NEW succeeds
    72	5. Rotation logged in `.agents/decisions/<date>-path-b-rotation-<n>.md` with the original need, the rotation evidence, AND the cryptographic verification output
    73	
    74	**Codex Round 1 strengthening (2026-05-20):** the waiver text above is the *escape hatch*, not the default. **Any Path B use without same-session rotation is a protocol violation that counts as a Risk #1 strike** (operational hygiene degraded). Founder may invoke Path B exactly once per emergency context (e.g., boot-time `ifos-unlock` when Path A is impossible because no interactive terminal is available). Repeated Path B use in a single session indicates Path A/Path D pattern is insufficient — escalate to a new ADR rather than authorise repeatedly.
    75	
    76	**Day-4 incident (reference example of a correctly-handled Path B use):** Path B was authorised once for §4.8 ifos-unlock end-to-end test. Founder rotated WITHIN THE SAME SESSION via `cryptsetup luksChangeKey`; `--test-passphrase` verified OLD rejected + NEW accepted. The leaked passphrase in the transcript became cryptographically invalid against the LUKS volume. **Cost:** ~30 minutes of rotation work + permanent transcript-history annotation. Audit record: Day-4 close commit `98c79b2` + `.agents/decisions/2026-05-17-path-b-rotation-1.md`.
    77	
    78	**Path B was the right call for Day 4 ONLY because the protocol violation was acknowledged and the rotation was committed in the same session.** The Day-4 close commit (`98c79b2`) is the audit record. **Future sessions MUST avoid Path B by defaulting to Path A or Path D.** If Path B is invoked, the same-session-rotation discipline above is non-negotiable.
    79	
    80	### §2.3 — Path D (default for credential generation)
    81	
    82	**Definition:** Credential generated on the remote VPS (or other target system) via `openssl rand` or equivalent. Never echoed to stdout. Stored in a file with mode 0600 root:root. Founder retrieves separately via `sudo cat` in their own terminal, saves to 1Password, then deletes the temp file.
    83	
    84	**Use cases:**
    85	- Postgres role passwords (Day-5 §5.4 `ifos_app` role)
    86	- LUKS passphrase rotation (Day-5 §11 LUKS rotation post-Path-B)
    87	- Future API token generation
    88	- Any random-generated credential
    89	
    90	**Mechanism (worked example from Day-5 §5.4):**
    91	
    92	```bash
    93	# Inside an SSH session as maddox on the VPS:
    94	PASSWORD=$(openssl rand -base64 24)                              # generate; not echoed
    95	printf '%s' "$PASSWORD" | sudo tee /vault/.<name>.tmp >/dev/null # write file; tee output discarded
    96	sudo chmod 600 /vault/.<name>.tmp                                # restrict access
    97	sudo chown root:root /vault/.<name>.tmp                          # root-only
    98	sudo -u postgres psql <<SQL                                      # use via stdin heredoc (not ps-visible)
    99	ALTER ROLE <role> WITH PASSWORD '$PASSWORD';
   100	SQL
   101	unset PASSWORD                                                    # clear from shell env
   102	```
   103	
   104	Founder retrieval (separate terminal, separate SSH session):
   105	
   106	```bash
   107	ssh ... 'sudo cat /vault/.<name>.tmp'   # founder views password
   108	# (founder copies to 1Password)
   109	ssh ... 'sudo rm /vault/.<name>.tmp'    # founder deletes temp file
   110	```
   111	
   112	**Properties:**
   113	- Password never appears in Claude Code's output stream
   114	- `ps auxf` cannot show the password (stdin heredoc, not command-line argument)
   115	- Temp file is on the LUKS-encrypted volume (encrypted at rest)
   116	- Founder retrieves at their convenience; no blocking handoff
   117	- Rotation NOT required because password was never in chat context
   118	
   119	**Trade-off:** ~2-minute founder retrieval at convenience vs. zero chat exposure.
   120	
   121	---
   122	
   123	## §3 — No-defensive-additions rule
   124	
   125	**Rule:** When executing a runbook, run exactly the commands in the runbook. Do not add defensive checks, verification probes, or "while we're here" diagnostics beyond what the runbook specifies.
   126	
   127	**Why:** Defensive additions introduce failure modes the runbook author didn't anticipate. They risk aborting the script via `set -e` on a check that wasn't part of the contract. They create the false impression of robustness while actually reducing it.
   128	
   129	**Day-4 lessons:**
   130	- Added `sudo file -s /dev/disk/by-id/...` defensive check not in runbook §4.1. `file` was not installed on the base Ubuntu image; `set -e` aborted the script before §4.2 install. Reverted to exact runbook commands.

exec
/bin/zsh -lc 'rg -n "hh_decision_trigger|hh_decision_output|hh_decision_action|consultant_feedback|diagnostic_report_render|operator_notify_telegram|validate_check_skipped|ESC_|AgentMail|Composio|packages/harness/cortextos|kb-" agents/recruitment/diagnostic/agent.md agents/recruitment/diagnostic/cycle.sh agents/recruitment/diagnostic/validate.sh agents/recruitment/diagnostic/context.sh agents/recruitment/diagnostic/cleanup.sh agents/recruitment/diagnostic/tools.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/diagnostic/context.sh:25:#   - Emits hh_decision_trigger("session_start", ...) as first audit row
agents/recruitment/diagnostic/context.sh:28:#   - Missing tenant_slug → exit 1 with ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/context.sh:29:#   - Missing voice corpus → exit 1 with ESC_VOICE_DRIFT (no fallback for
agents/recruitment/diagnostic/context.sh:31:#   - target_patch unreachable → exit 1 with ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/context.sh:83:hh_decision_trigger "session_start" "diagnostic agent for firm: ${IFOS_DIAGNOSTIC_FIRM_NAME:-<unset>}" \
agents/recruitment/diagnostic/context.sh:85:    printf 'context.sh: hh_decision_trigger failed; vault may be unwritable\n' >&2
agents/recruitment/diagnostic/agent.md:68:- Section 12 (conversation opener) failing voice-classifier with score < 0.75 *(v0 hard-fail when voice-classifier URL reachable; warn + exit 0 when URL unreachable per §5 honesty note; W4 polish closes to unconditional hard-fail with explicit `validate_check_skipped` audit row)*
agents/recruitment/diagnostic/agent.md:73:- Step 10 report assembly → `hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")`
agents/recruitment/diagnostic/agent.md:74:- Step 11 (optional) operator notify → `hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)` — green tier per autosend-policy.yaml
agents/recruitment/diagnostic/agent.md:75:- Step 12 session close → `hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)` — green tier
agents/recruitment/diagnostic/agent.md:86:   → hh_decision_trigger("session_start", firm_name + sector_hint)
agents/recruitment/diagnostic/agent.md:90:   → on fail: hh_decision_action("diagnostic_input_invalid", ...) with
agents/recruitment/diagnostic/agent.md:91:     payload {escalation_code: ESC_INPUT_VALIDATION_FAIL, ...}
agents/recruitment/diagnostic/agent.md:106:   → on empty stdout: hh_decision_action("diagnostic_generator_empty", ...) with
agents/recruitment/diagnostic/agent.md:107:     payload {escalation_code: ESC_AGENT_OUTPUT_SHAPE, ...}; exit 1
agents/recruitment/diagnostic/agent.md:108:   → ESC_RATE_LIMIT_HIT raised internally by web-scraper / companies-house on 429
agents/recruitment/diagnostic/agent.md:109:   → ESC_VOICE_DRIFT raised internally by §12 LLM step if classifier <0.75 after 3 retries
agents/recruitment/diagnostic/agent.md:110:   → hh_decision_output("diagnostic_draft", "<draft_path>", "<firm> 12-section draft (pre-validate)")
agents/recruitment/diagnostic/agent.md:117:   → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
agents/recruitment/diagnostic/agent.md:118:     with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE or
agents/recruitment/diagnostic/agent.md:119:     ESC_PII_LEAKAGE_RISK) and exit 1
agents/recruitment/diagnostic/agent.md:125:   → hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")
agents/recruitment/diagnostic/agent.md:126:   → hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:131:     → hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:148:**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
agents/recruitment/diagnostic/agent.md:155:- No PII (emails) outside the firm boundary. **v0 behavior:** validate.sh runs a generic email-regex pass and warns on any email found (no firm-domain whitelist implemented in v0; warn-only; exit 0). W4 polish adds the firm-domain whitelist + hard-fail behavior + `ESC_PII_LEAKAGE_RISK` emission. **v0 PII coverage:** emails only via regex; phone-number PII detection + whitelist enforcement deferred to W4 polish.
agents/recruitment/diagnostic/agent.md:159:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.
agents/recruitment/diagnostic/agent.md:171:| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:172:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/diagnostic/agent.md:173:| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn 429 | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:174:| `ESC_INPUT_VALIDATION_FAIL` | Malformed firm name input (Step 1 validation) | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:175:| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing OR generator produced empty stdout (Step 8 fallback) | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:179:- `ESC_RENDERER_FAILED` — that code is owned by the `_renderer` sentinel (agent_name='_renderer') per catalogue §2.4; Diagnostic never fires it
agents/recruitment/diagnostic/agent.md:180:- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
agents/recruitment/diagnostic/agent.md:181:- `ESC_AUTOSEND_*` — Diagnostic's actions are `diagnostic_report_render` + `operator_notify_telegram` + `consultant_feedback` (all green tier per autosend-policy.yaml)
agents/recruitment/diagnostic/agent.md:182:- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention
agents/recruitment/diagnostic/agent.md:195:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
agents/recruitment/diagnostic/validate.sh:12:# validate.sh exits non-zero and emits an ESC_* escalation row to
agents/recruitment/diagnostic/validate.sh:25:#   1  At least one check failed; ESC_* row emitted; cycle.sh aborts
agents/recruitment/diagnostic/validate.sh:234:  #   - PII detected outside firm boundary → ESC_PII_LEAKAGE_RISK (blocking)
agents/recruitment/diagnostic/validate.sh:235:  #   - Voice classifier score <0.75 (V3) → ESC_VOICE_DRIFT (warn, per
agents/recruitment/diagnostic/validate.sh:238:  #     length) → ESC_AGENT_OUTPUT_SHAPE (warn)
agents/recruitment/diagnostic/validate.sh:239:  # ESC_SCHEMA_VIOLATION is reserved for vertical-schema field-constraint
agents/recruitment/diagnostic/validate.sh:253:    ESC_CODE="ESC_PII_LEAKAGE_RISK"
agents/recruitment/diagnostic/validate.sh:255:    ESC_CODE="ESC_VOICE_DRIFT"
agents/recruitment/diagnostic/validate.sh:257:    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"
agents/recruitment/diagnostic/validate.sh:260:  ESC_PAYLOAD=$(printf '{"escalation_code":"%s","draft_path":"%s","failures":%s}' \
agents/recruitment/diagnostic/validate.sh:261:    "${ESC_CODE}" \
agents/recruitment/diagnostic/validate.sh:265:  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \
agents/recruitment/diagnostic/validate.sh:266:    "$(echo "${ESC_PAYLOAD}" | shasum | awk '{print $1}')" \
agents/recruitment/diagnostic/validate.sh:267:    "${ESC_PAYLOAD}" 2>/dev/null || true
agents/recruitment/diagnostic/tools.yaml:42:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:48:        escalation: ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/tools.yaml:77:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:80:        escalation: ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/tools.yaml:83:        escalation: ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/tools.yaml:137:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:140:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:162:        escalation: ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/tools.yaml:165:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/cleanup.sh:55:  hh_decision_action "linkedin_cache_purge_fail" "cleanup:${CTX_TENANT_SLUG}" \
agents/recruitment/diagnostic/cleanup.sh:57:    '{"escalation_code":"ESC_PII_LEAKAGE_RISK","reason":"LinkedIn cache purge incomplete"}' \
agents/recruitment/diagnostic/cleanup.sh:79:hh_decision_action "diagnostic_cleanup" "agent:${CTX_AGENT_NAME:-diagnostic}" \
agents/recruitment/diagnostic/cycle.sh:25:#   1  Workflow failure (specific step failed; ESC_* row emitted)
agents/recruitment/diagnostic/cycle.sh:107:  hh_decision_action "diagnostic_input_invalid" "firm:${FIRM_NAME}" \
agents/recruitment/diagnostic/cycle.sh:109:    '{"escalation_code":"ESC_INPUT_VALIDATION_FAIL","input_field":"firm","input_value_preview":"<malformed>","validation_rule_violated":"min_length_2"}' >/dev/null
agents/recruitment/diagnostic/cycle.sh:161:  hh_decision_action "diagnostic_generator_empty" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:163:    '{"escalation_code":"ESC_AGENT_OUTPUT_SHAPE","agent_name":"diagnostic","shape_rule_violated":"non_empty_output","expected_value":"non-empty stdout","actual_value":"empty"}' >/dev/null
agents/recruitment/diagnostic/cycle.sh:171:hh_decision_output "diagnostic_draft" "${DRAFT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:188:hh_decision_output "diagnostic_report" "${REPORT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:191:hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:207:    # operator_notify_telegram is green-tier per autosend-policy.yaml so the
agents/recruitment/diagnostic/cycle.sh:214:    hh_decision_action "operator_notify_telegram" "operator:${TELEGRAM_OPERATOR_CHAT_ID}" \

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/context.sh | sed -n '1,115p' && nl -ba agents/recruitment/diagnostic/cleanup.sh | sed -n '1,115p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "rg -n \"ESC_RATE_LIMIT_HIT|ESC_VOICE_DRIFT|hh_decision_action|RATE_LIMIT|429|voice classifier|classify|tone\" packages/diagnostic-generator packages/mcp-connectors/companies-house packages/utilities/web-scraper agents/recruitment/diagnostic -g '"'!**/node_modules/**'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 154ms:
packages/diagnostic-generator/README.md:37:2. **No LLM-driven §12.** Conversation opener is deterministic anchor-based. W4 wires an LLM + voice classifier.
packages/diagnostic-generator/README.md:38:3. **No voice classifier gate.** validate.sh V3 skipped at v0 with explicit warning.
agents/recruitment/diagnostic/cleanup.sh:55:  hh_decision_action "linkedin_cache_purge_fail" "cleanup:${CTX_TENANT_SLUG}" \
agents/recruitment/diagnostic/cleanup.sh:79:hh_decision_action "diagnostic_cleanup" "agent:${CTX_AGENT_NAME:-diagnostic}" \
agents/recruitment/diagnostic/README.md:19:| `context.sh` | Session hydration (voice corpus + target_patch + tone rules) | W3 build start |
agents/recruitment/diagnostic/README.md:25:| `fixtures/99-voice-drift-canary.yaml` | Adversarial: forces voice classifier near threshold | W3 build start |
agents/recruitment/diagnostic/cycle.sh:107:  hh_decision_action "diagnostic_input_invalid" "firm:${FIRM_NAME}" \
agents/recruitment/diagnostic/cycle.sh:161:  hh_decision_action "diagnostic_generator_empty" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:191:hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:214:    hh_decision_action "operator_notify_telegram" "operator:${TELEGRAM_OPERATOR_CHAT_ID}" \
agents/recruitment/diagnostic/tools.yaml:40:      - code: 429
agents/recruitment/diagnostic/tools.yaml:42:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:75:      - code: 429
agents/recruitment/diagnostic/tools.yaml:77:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:116:  # ── §4 Step 9 + §7 voice classifier ───────────────────────────────────
agents/recruitment/diagnostic/tools.yaml:120:      Per-tenant voice classifier for the §12 conversation opener.
agents/recruitment/diagnostic/tools.yaml:121:      Scores §12 output against tenant's voice corpus + tone rules. Gate A
agents/recruitment/diagnostic/tools.yaml:123:      voice-loader.sh for tenant corpus + tone rules + recent_edits.
agents/recruitment/diagnostic/tools.yaml:127:      - voice.classify  # text + tenant_slug → score in [0,1]
agents/recruitment/diagnostic/tools.yaml:128:      - voice.tone_rule_check  # text + tone_rule_set → list of violations
agents/recruitment/diagnostic/tools.yaml:137:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:140:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:163:      - code: 429
agents/recruitment/diagnostic/tools.yaml:165:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/validate.sh:31:#   V3 — Section 12 voice classifier score ≥ 0.75
agents/recruitment/diagnostic/validate.sh:33:#   V5 — No banned phrases per tone_rule table
agents/recruitment/diagnostic/validate.sh:128:# V3 — §12 voice classifier ≥ 0.75
agents/recruitment/diagnostic/validate.sh:140:    SCORE=$(curl -sS -X POST "${IFOS_VOICE_CLASSIFIER_URL}/classify" \
agents/recruitment/diagnostic/validate.sh:148:      _pass "V3: §12 voice classifier score=${SCORE} (≥ 0.75)"
agents/recruitment/diagnostic/validate.sh:150:      _fail "V3: §12 voice classifier score=${SCORE} (< 0.75)"
agents/recruitment/diagnostic/validate.sh:171:# V5 — Banned phrases per tone_rule
agents/recruitment/diagnostic/validate.sh:235:  #   - Voice classifier score <0.75 (V3) → ESC_VOICE_DRIFT (warn, per
agents/recruitment/diagnostic/validate.sh:255:    ESC_CODE="ESC_VOICE_DRIFT"
agents/recruitment/diagnostic/validate.sh:265:  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \
packages/mcp-connectors/companies-house/src/client.ts:60:    if (res.status === 429) throw new CHRateLimitError(path);
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:31:      company_number: "06542987"
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:3:# Adversarial case. Tests Gate A V3 (voice classifier ≥ 0.75) hard-fail
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:7:# ESC_VOICE_DRIFT row emitted, draft NOT written to vault.
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:16:description: Adversarial — force voice classifier below 0.75; expect Gate A V3 failure
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:31:# Forces the voice classifier into a known-low-scoring path by injecting
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:69:  - escalation_code: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:87:    - "ESC_VOICE_DRIFT"
agents/recruitment/diagnostic/context.sh:6:# Status: Proposed (Day-19; voice + tone + recent_edits + target_patch hydration via voice-loader.sh + tone-loader + Postgres).
agents/recruitment/diagnostic/context.sh:7:# Reading order: agent.md §4 Step 0 (session start) + §7 (voice + tone) first.
agents/recruitment/diagnostic/context.sh:11:# corpus + tone rules + recent edits + target_patch from the tenant's
agents/recruitment/diagnostic/context.sh:29:#   - Missing voice corpus → exit 1 with ESC_VOICE_DRIFT (no fallback for
agents/recruitment/diagnostic/context.sh:144:# 4 — Load tone rules (filtered to diagnostic agent)
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:173:printf '[diagnostic context.sh] tenant=%s corpus_id=%s tone_rules=%s recent_edits=%s target_patch=loaded\n' \
packages/mcp-connectors/companies-house/src/capabilities.ts:32:    // Soft-budget hit; throw immediately rather than risk a 429.
packages/mcp-connectors/companies-house/README.md:34:| 429 | Rate limited; back off 60s, retry once | ESC_RATE_LIMIT_HIT |
packages/mcp-connectors/companies-house/src/errors.ts:25:    super("rate limit exceeded; back off 60s and retry", endpoint, 429);
agents/recruitment/diagnostic/agent.md:74:- Step 11 (optional) operator notify → `hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)` — green tier per autosend-policy.yaml
agents/recruitment/diagnostic/agent.md:75:- Step 12 session close → `hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)` — green tier
agents/recruitment/diagnostic/agent.md:85:   → context.sh hydrates: voice corpus + tone rules + recent edits + target_patch.json
agents/recruitment/diagnostic/agent.md:90:   → on fail: hh_decision_action("diagnostic_input_invalid", ...) with
agents/recruitment/diagnostic/agent.md:106:   → on empty stdout: hh_decision_action("diagnostic_generator_empty", ...) with
agents/recruitment/diagnostic/agent.md:108:   → ESC_RATE_LIMIT_HIT raised internally by web-scraper / companies-house on 429
agents/recruitment/diagnostic/agent.md:109:   → ESC_VOICE_DRIFT raised internally by §12 LLM step if classifier <0.75 after 3 retries
agents/recruitment/diagnostic/agent.md:115:   → voice classifier + PII subchecks per §5 honesty note (warn-only on
agents/recruitment/diagnostic/agent.md:117:   → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
agents/recruitment/diagnostic/agent.md:126:   → hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:131:     → hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:148:**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
agents/recruitment/diagnostic/agent.md:152:- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
agents/recruitment/diagnostic/agent.md:154:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
agents/recruitment/diagnostic/agent.md:171:| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:173:| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn 429 | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:186:## §7 — Voice + tone constraints
agents/recruitment/diagnostic/agent.md:190:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:195:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
agents/recruitment/diagnostic/agent.md:246:2. **Companies House rate limits — cache aggressively.** Free tier is 600 requests per 5-minute window per IP. Cache responses for 7 days per (company_number) key. Pre-emptive 60s backoff on first 429.
packages/diagnostic-generator/src/sections/conversation-opener.ts:4:// context + tenant voice corpus (when wired via voice-loader.sh) + tone
packages/diagnostic-generator/src/sections/conversation-opener.ts:27:  toneRules?: { rule_id: string; rule_text: string; severity: string }[];
packages/diagnostic-generator/src/sections/conversation-opener.ts:129:  const toneRulesText = (input.toneRules ?? [])
packages/diagnostic-generator/src/sections/conversation-opener.ts:144:${voiceContext ? `Voice corpus exemplars (write in this style):\n${voiceContext}\n\n` : ""}${toneRulesText ? `Tone rules to respect:\n${toneRulesText}\n\n` : ""}`;
packages/mcp-connectors/companies-house/tests/unit.test.ts:72:  it("maps 429 → CHRateLimitError", async () => {
packages/mcp-connectors/companies-house/tests/unit.test.ts:73:    const fetchImpl = mockFetch(() => new Response("nope", { status: 429 }));
packages/mcp-connectors/companies-house/pnpm-lock.yaml:583:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:587:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/companies-house/src/client.ts | sed -n '1,120p' && nl -ba packages/mcp-connectors/companies-house/src/errors.ts | sed -n '1,80p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	// HTTP client for Companies House REST API.
     2	// Auth: HTTP Basic with API key as username, empty password.
     3	
     4	import { CHAuthError, CHError, CHNotFoundError, CHRateLimitError } from "./errors.js";
     5	
     6	export const CH_BASE_URL = "https://api.company-information.service.gov.uk";
     7	export const DEFAULT_TIMEOUT_MS = 8_000;
     8	
     9	export type FetchFn = typeof globalThis.fetch;
    10	
    11	export interface CHClientOptions {
    12	  readonly apiKey?: string;
    13	  readonly baseUrl?: string;
    14	  readonly fetchImpl?: FetchFn;
    15	  readonly timeoutMs?: number;
    16	}
    17	
    18	export class CHClient {
    19	  private readonly apiKey: string;
    20	  private readonly baseUrl: string;
    21	  private readonly fetchImpl: FetchFn;
    22	  private readonly timeoutMs: number;
    23	
    24	  constructor(opts: CHClientOptions = {}) {
    25	    const apiKey = opts.apiKey ?? process.env.COMPANIES_HOUSE_API_KEY ?? "";
    26	    if (!apiKey) {
    27	      throw new CHAuthError("(client init)");
    28	    }
    29	    this.apiKey = apiKey;
    30	    this.baseUrl = opts.baseUrl ?? CH_BASE_URL;
    31	    this.fetchImpl = opts.fetchImpl ?? globalThis.fetch;
    32	    this.timeoutMs = opts.timeoutMs ?? DEFAULT_TIMEOUT_MS;
    33	  }
    34	
    35	  async getJson<T>(path: string, query?: Record<string, string>): Promise<T> {
    36	    const url = new URL(this.baseUrl + path);
    37	    if (query) {
    38	      for (const [k, v] of Object.entries(query)) url.searchParams.set(k, v);
    39	    }
    40	
    41	    const authHeader = "Basic " + Buffer.from(`${this.apiKey}:`).toString("base64");
    42	
    43	    const controller = new AbortController();
    44	    const timer = setTimeout(() => controller.abort(), this.timeoutMs);
    45	    let res: Response;
    46	    try {
    47	      res = await this.fetchImpl(url.toString(), {
    48	        method: "GET",
    49	        headers: { Authorization: authHeader, Accept: "application/json" },
    50	        signal: controller.signal,
    51	      });
    52	    } catch (err) {
    53	      throw new CHError(`fetch failed: ${(err as Error).message}`, path, undefined, err);
    54	    } finally {
    55	      clearTimeout(timer);
    56	    }
    57	
    58	    if (res.status === 401 || res.status === 403) throw new CHAuthError(path);
    59	    if (res.status === 404) throw new CHNotFoundError(path);
    60	    if (res.status === 429) throw new CHRateLimitError(path);
    61	    if (res.status >= 500) {
    62	      throw new CHError(`server error ${res.status}`, path, res.status);
    63	    }
    64	    if (res.status >= 400) {
    65	      throw new CHError(`unexpected status ${res.status}`, path, res.status);
    66	    }
    67	
    68	    try {
    69	      return (await res.json()) as T;
    70	    } catch (err) {
    71	      throw new CHError(`response not JSON: ${(err as Error).message}`, path, res.status, err);
    72	    }
    73	  }
    74	}
     1	// Error types for Companies House connector. Maps to escalation codes per
     2	// agents/_shared/escalation-codes.md and tools.yaml §2 failure_modes.
     3	
     4	export class CHError extends Error {
     5	  constructor(
     6	    message: string,
     7	    public readonly endpoint: string,
     8	    public readonly status?: number,
     9	    public readonly cause?: unknown,
    10	  ) {
    11	    super(message);
    12	    this.name = "CHError";
    13	  }
    14	}
    15	
    16	export class CHAuthError extends CHError {
    17	  constructor(endpoint: string) {
    18	    super("Companies House API key invalid or missing", endpoint, 401);
    19	    this.name = "CHAuthError";
    20	  }
    21	}
    22	
    23	export class CHRateLimitError extends CHError {
    24	  constructor(endpoint: string) {
    25	    super("rate limit exceeded; back off 60s and retry", endpoint, 429);
    26	    this.name = "CHRateLimitError";
    27	  }
    28	}
    29	
    30	export class CHNotFoundError extends CHError {
    31	  constructor(endpoint: string) {
    32	    super("resource not found", endpoint, 404);
    33	    this.name = "CHNotFoundError";
    34	  }
    35	}

exec
/bin/zsh -lc "nl -ba packages/diagnostic-generator/src/generate.ts | sed -n '1,220p' && nl -ba packages/diagnostic-generator/src/cli.ts | sed -n '1,120p'" in /Users/madsadmin/code/CortexOS
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
     1	// CLI entry point. Parses args, loads tenant target_patch if available,
     2	// generates the report, writes to stdout. cycle.sh redirects stdout
     3	// to /tmp draft path before validate.sh + vault move.
     4	
     5	import { Command } from "commander";
     6	import { promises as fs } from "node:fs";
     7	import { generateReport } from "./generate.js";
     8	import type { TargetPatch } from "./sections/icp-fit.js";
     9	
    10	const program = new Command();
    11	program
    12	  .name("ifos-diagnostic-generate")
    13	  .description("Generate a 12-section Diagnostic report for a UK recruitment firm")
    14	  .requiredOption("--firm <name>", "Firm name (free-text; used for Companies House search)")
    15	  .requiredOption("--tenant <slug>", "Tenant slug (per common-base.json pattern)")
    16	  .option("--sector <hint>", "Sector hint (free-text)", "")
    17	  .option("--target-patch <path>", "Path to tenant target_patch.json", "")
    18	  .option("--iso-date <date>", "Override report date (default: today UTC)", "");
    19	
    20	program.parse(process.argv);
    21	const opts = program.opts<{
    22	  firm: string;
    23	  tenant: string;
    24	  sector: string;
    25	  targetPatch: string;
    26	  isoDate: string;
    27	}>();
    28	
    29	async function loadTargetPatch(path: string): Promise<TargetPatch | null> {
    30	  if (!path) return null;
    31	  try {
    32	    const raw = await fs.readFile(path, "utf8");
    33	    return JSON.parse(raw) as TargetPatch;
    34	  } catch (err) {
    35	    process.stderr.write(`warning: could not load target_patch from ${path}: ${(err as Error).message}\n`);
    36	    return null;
    37	  }
    38	}
    39	
    40	async function main(): Promise<void> {
    41	  const targetPatch = await loadTargetPatch(opts.targetPatch);
    42	  const md = await generateReport({
    43	    firmName: opts.firm,
    44	    tenantSlug: opts.tenant,
    45	    sectorHint: opts.sector,
    46	    targetPatch,
    47	    isoDate: opts.isoDate || undefined,
    48	  });
    49	  process.stdout.write(md);
    50	}
    51	
    52	main().catch((err) => {
    53	  process.stderr.write(`ifos-diagnostic-generate: ${(err as Error).message}\n`);
    54	  process.exit(1);
    55	});

exec
/bin/zsh -lc "nl -ba packages/diagnostic-generator/README.md | sed -n '1,80p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# @ifos/diagnostic-generator
     2	
     3	Composes `@ifos/web-scraper` + `@ifos/companies-house` into a 12-section Markdown report for a UK recruitment firm. Called by `agents/recruitment/diagnostic/cycle.sh` after context.sh hydrates the session and before validate.sh runs Gate A.
     4	
     5	## CLI
     6	
     7	```bash
     8	node packages/diagnostic-generator/dist/cli.js \
     9	  --firm "Charterhouse Partners" \
    10	  --tenant migration-test \
    11	  --sector fintech \
    12	  --target-patch /vault/migration-test/target_patch.json
    13	```
    14	
    15	Writes the Markdown report to stdout. `cycle.sh` captures it to `/tmp/diagnostic-draft-<slug>-<pid>.md`.
    16	
    17	## Architecture
    18	
    19	- **§1 Firm signal** — `companies-house` profile + officers + filing-history.
    20	- **§2 Online footprint** — `web-scraper` HEAD check on `{slug}.com`, `{slug}.co.uk`, LinkedIn page.
    21	- **§3 Sector mix** — stub with Companies House SIC codes; LinkedIn jobs at W4.
    22	- **§4 Geography** — Companies House registered office; LinkedIn job-post locations at W4.
    23	- **§5 Deal-size band** — firm-age proxy from Companies House; LinkedIn salary bands at W4.
    24	- **§6 ICP fit** — composite score from §1/§5 vs tenant `target_patch.json`.
    25	- **§7 Tech stack** — stub; LinkedIn skills + JD parsing at W4.
    26	- **§8 Pain signals** — `web-scraper` careers page + 10-pattern urgency regex.
    27	- **§9 Competitor positioning** — stub; LinkedIn profile employment-history at W4.
    28	- **§10 Recent activity** — Companies House filings last 90 days; LinkedIn posts + Google news at W4.
    29	- **§11 Decision-maker map** — Companies House directors as proxy; LinkedIn employee search at W4.
    30	- **§12 Conversation opener** — deterministic anchor-based composition (LLM at W4).
    31	
    32	## v0 limitations (explicit)
    33	
    34	This is the **Day-13 v0 build** per `docs/operations/goal-option-c-diagnostic-end-to-end.md`. Limitations:
    35	
    36	1. **No LinkedIn deep data.** Page-existence check via HEAD only. Full data needs Proxycurl signup (~$39/mo).
    37	2. **No LLM-driven §12.** Conversation opener is deterministic anchor-based. W4 wires an LLM + voice classifier.
    38	3. **No voice classifier gate.** validate.sh V3 skipped at v0 with explicit warning.
    39	4. **No Google news search.** §10 only sees Companies House filings.
    40	
    41	These are pre-baked into the report text so prospects + operators know what's real vs deferred.
    42	
    43	## Failure modes
    44	
    45	| Failure | Behaviour |
    46	|---|---|
    47	| Companies House API key missing | Throws CHAuthError at module init; cycle.sh exits non-zero |
    48	| Companies House 404 (firm not registered) | Section §1 reports "no registration found"; §6+§10+§11 degrade gracefully |
    49	| Web scraper times out / blocked | Section §2 + §8 report "no signal"; report still produces |
    50	| LinkedIn HEAD returns 999 (bot detection) | §2 treats as "page exists, deep data via Proxycurl"; not a failure |
    51	| Network down | All Companies House + web-scraper calls fail; report degrades to "no-data" path but still 12 sections + ≥1 citation each (V1+V2 pass) |
    52	
    53	## Tests
    54	
    55	```bash
    56	pnpm test       # 3 unit tests with mocked globalThis.fetch
    57	pnpm typecheck  # strict
    58	```
    59	
    60	Tests use `globalThis.fetch` replacement; no real network calls. Real-firm integration testing happens at goal Step 7 with the founder picking a firm name.
    61	
    62	## Status
    63	
    64	v0.1 — Diagnostic W3 pre-build per `agents/recruitment/diagnostic/agent.md` + `docs/operations/goal-option-c-diagnostic-end-to-end.md`.

codex
REJECTED

1. §4 falsely claims generator-level voice escalation. Line 109 says `ESC_VOICE_DRIFT` is “raised internally by §12 LLM step if classifier <0.75 after 3 retries,” but the generator README says v0 has “No LLM-driven §12” and “No voice classifier gate,” and `validate.sh` only calls the classifier once when `IFOS_VOICE_CLASSIFIER_URL` is set. Fix §4 to say voice drift is a `validate.sh` V3 concern in v0, with retries deferred to W4 if intended.

2. §4/§6 claim rate-limit escalation that is not implemented. Lines 108 and 173 say `ESC_RATE_LIMIT_HIT` is raised for Companies House or LinkedIn 429s, but `cycle.sh` has no 429 catch or `hh_decision_action` path for that code; the generator CLI just exits generic on thrown errors. Fix by either implementing a 429 catch that emits `ESC_RATE_LIMIT_HIT`, or marking this as a W4/planned tools.yaml mapping rather than current v0 behaviour.

3. §4 Gate-A failure signature is incomplete. Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature.

4. Citation drift in §3. Line 45 cites `validate.sh` lines 89-97 as saying “W4 polish adds title + order check,” but those lines say only that exact heading matching is not implemented and “At W3 build” it should tighten. Fix the citation wording to match the live file or remove the quoted claim.

5. §9 contains a stale open-question resolution path. Line 238 says Proxycurl/API choice is “Resolved at W3 start before Companies House + LinkedIn MCP connectors authored,” while this Day-19 artefact and §8 lines 213-215 say the connector/web-scraper work is already shipped and Proxycurl is deferred. Fix Q3 to describe the current W4 Proxycurl/commercial decision path.
tokens used
108,714
REJECTED

1. §4 falsely claims generator-level voice escalation. Line 109 says `ESC_VOICE_DRIFT` is “raised internally by §12 LLM step if classifier <0.75 after 3 retries,” but the generator README says v0 has “No LLM-driven §12” and “No voice classifier gate,” and `validate.sh` only calls the classifier once when `IFOS_VOICE_CLASSIFIER_URL` is set. Fix §4 to say voice drift is a `validate.sh` V3 concern in v0, with retries deferred to W4 if intended.

2. §4/§6 claim rate-limit escalation that is not implemented. Lines 108 and 173 say `ESC_RATE_LIMIT_HIT` is raised for Companies House or LinkedIn 429s, but `cycle.sh` has no 429 catch or `hh_decision_action` path for that code; the generator CLI just exits generic on thrown errors. Fix by either implementing a 429 catch that emits `ESC_RATE_LIMIT_HIT`, or marking this as a W4/planned tools.yaml mapping rather than current v0 behaviour.

3. §4 Gate-A failure signature is incomplete. Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature.

4. Citation drift in §3. Line 45 cites `validate.sh` lines 89-97 as saying “W4 polish adds title + order check,” but those lines say only that exact heading matching is not implemented and “At W3 build” it should tighten. Fix the citation wording to match the live file or remove the quoted claim.

5. §9 contains a stale open-question resolution path. Line 238 says Proxycurl/API choice is “Resolved at W3 start before Companies House + LinkedIn MCP connectors authored,” while this Day-19 artefact and §8 lines 213-215 say the connector/web-scraper work is already shipped and Proxycurl is deferred. Fix Q3 to describe the current W4 Proxycurl/commercial decision path.
