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

**Status:** Pre-Build-Round-17-Bilateral-Applied (Day-20; W4 bilateral pass applied). Full bundle built — agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures all present. R17 closes 4 of 5 R16 residuals via direct edits (§6 ESC table v0-vs-W4 status column added; §3 validate.sh citation aligned + validate.sh comment updated W3→W4; §9 Q3 cross-linked to §8 dependencies). R16 Finding 3 (Gate A failure signature missing ESC_VOICE_DRIFT) was already addressed at R15 commit `23f8c14` — Codex misread the multi-line statement at lines 117-121; ESC_VOICE_DRIFT IS listed at lines 119-120. Disagreement filed at `docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md`. **Next:** founder authorizes Codex R18 ratification (`bash scripts/run-codex-ratification.sh agent-bundle agents/recruitment/diagnostic/agent.md`); if RATIFIED, Status flips Pre-Build → Accepted when ALL: (a) bilateral founder review confirmed, AND (b) founder approves §3's 12-section list as canonical, AND (c) first production render against the first pilot tenant succeeds, AND (d) Gate B baseline measurement begins.
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

Every report MUST contain these 12 sections. The generator (`@ifos/diagnostic-generator`) emits them in the order listed below. Gate A at v0 enforces (a) ≥12 `##` headings present in the rendered draft AND (b) per-section citation coverage. v0 `validate.sh` V1 counts `##` headings without enforcing exact section titles or order — see `validate.sh` lines 89-91 comment ("Section labels documented for reference; not currently regex-matched individually... At W4 polish: tighten to enforce exact-heading match per EXPECTED_SECTIONS"). The comment was authored as "At W3 build" but W3 closed without the tightening; it is now W4 polish. Both the agent.md and `validate.sh` comment are updated to "W4 polish" in this round.

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
   → v0 NOTE: rate-limit catches (429 → ESC_RATE_LIMIT_HIT) and per-section retry logic are NOT implemented at v0 cycle.sh; W4 polish adds 429 catch + retry-with-backoff to cycle.sh. v0 generator throws-and-exits on upstream errors; validate.sh catches Gate A failure downstream.
   → v0 NOTE: per-§12 LLM voice classifier retry loop is NOT implemented in generator at v0 (§12 stub-via-Companies-House fallback). Voice classification happens at validate.sh V3 (single call to IFOS_VOICE_CLASSIFIER_URL when set; warn + exit 0 when unset/unreachable). W4 polish adds full LLM §12 pipeline with 3-retry classifier loop and explicit ESC_VOICE_DRIFT emission in the generator.
   → hh_decision_output("diagnostic_draft", "<draft_path>", "<firm> 12-section draft (pre-validate)")

12. Validate (Gate A) (cycle.sh Step 12)
   → bash invokes validate.sh against the draft path
   → per-section citation hard-fail (ADR-006 Tier 1; no warn-only path)
   → voice classifier + PII subchecks per §5 honesty note (warn-only on
     upstream-unavailable in v0; W4 closes to hard-fail)
   → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
     with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE for
     section count / citation / length failures; ESC_VOICE_DRIFT for V3
     voice-classifier-score-low failures; ESC_PII_LEAKAGE_RISK for PII
     boundary breaches) and exit 1
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

| Code | Trigger | Severity | Routing | v0 implementation status |
|---|---|---|---|---|
| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 | warn | operator_chat_id | **v0: single-pass via `validate.sh` V3 (no in-generator retries); W4-planned: 3-retry classifier loop in `@ifos/diagnostic-generator` §12 LLM step.** Aggregate-tenant `ESC_VOICE_DRIFT_TENANT` is per `_shared/escalation-codes.md` (nightly cron). |
| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall | v0: emails-only regex; warn + exit 0 when firm-domain whitelist absent. W4-planned: phone-number PII detection + hard-fail when whitelist absent. |
| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn upstream 429 | warn | operator_chat_id | **v0: NOT implemented in `cycle.sh` (generator throws-and-exits on upstream errors; validate.sh catches downstream as `ESC_AGENT_OUTPUT_SHAPE`). W4-planned: 429 catch + retry-with-backoff in `cycle.sh` + explicit `ESC_RATE_LIMIT_HIT` emission.** |
| `ESC_INPUT_VALIDATION_FAIL` | Malformed firm name input (Step 1 validation) | warn | operator_chat_id | v0: implemented as specified. |
| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing OR generator produced empty stdout (Step 8 fallback) | warn | operator_chat_id | v0: implemented as specified. |

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
| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | v0 (Day 13 ship) skipped Proxycurl: LinkedIn deep-data sections (§3, §5, §7, §9, §11) use Companies House fallback citations per §3 table (status confirmed in §8 dependencies row "LinkedIn read-only via web-scraper" — Proxycurl deferred to W4). W4 polish decision path: founder evaluates commercial Proxycurl signup ($39/mo Proxycurl pricing low-volume) vs alternative (PhantomBuster, Bright Data, scraper.api) vs continued Companies House fallback. Resolution due before first pilot tenant onboarding (Risk #3 LOI close). |
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
