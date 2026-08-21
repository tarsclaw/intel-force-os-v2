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
session id: 019e5a80-5e29-7321-a547-8543f43bbb6a
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

Path: agents/recruitment/sourcing-scout/agent.md

--- BEGIN ARTEFACT ---

# Sourcing Scout — request-response passive sourcing

**Status:** Proposed (Day-19 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice).
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate flagged "do not contact" in tenant vault (per ULTRAPLAN A5 line 552 verbatim). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).

---

## §2 — Invocation surface

### Brain UI (v1.0 primary)

Brain UI v1.0 "Source candidates" button on any brief detail page → POST internal API → Sourcing Scout webhook.

### Telegram command (v1.0)

```
@ifos_bot scout <brief-id-or-slug>
@ifos_bot scout --description "Senior React engineer, London, £120k, hybrid"
```

### Webhook (v1.0)

Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.

### CLI (v1.0 — debugging)

```bash
ifosctl sourcing-scout source --tenant <slug> --brief-id <id>
ifosctl sourcing-scout source --tenant <slug> --description "<free-text>"
```

### v1.1+ surfaces (deferred)

- Night Sourcer Tier-1 always-on (Brain UI dashboard; cortextOS primitive #6)
- Bulk-source mode (`--brief-list briefs.csv`)
- Refresh-source mode (re-source against the same brief 30 days later)

---

## §3 — Output shape

One output per invocation. Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md`. Structure:

```markdown
# Sourcing Scout — <Brief title>
**Generated:** <ISO-date>  **Brief ID:** <Bullhorn-brief-id>  **Tenant:** <slug>
**Sources searched:** Bullhorn ATS + LinkedIn (Proxycurl) + Reed + CV-Library
**Aggregate candidates:** <N> (top 5-15 ranked)

## Brief context
<2-3 sentences summarising the role from the brief input>

## Ranked candidates

### 1. <Candidate name> — confidence 0.92
**Source:** Bullhorn (passive match) | **Contact:** <method + verified>
**Match rationale:**
<≥50 words explaining why this candidate is a match — references brief
requirements + candidate background; cites Bullhorn placement history,
LinkedIn current role, or other source-specific evidence.>
**Risk flags:** <e.g., "active with placement at competitor agency 2024";
"prefers contract not perm per Bullhorn note">
**Profile links:** [Bullhorn](url) | [LinkedIn](url)

### 2. <Candidate name> — confidence 0.88
...

(5-15 candidates total)

## Source breakdown
| Source | Candidates contributed | Avg confidence | Rate-limit budget remaining |
|---|---|---|---|
| Bullhorn ATS | <N> | <score> | n/a (no quota) |
| LinkedIn (Proxycurl) | <N> | <score> | <remaining> |
| Reed | <N> | <score> | <remaining> |
| CV-Library | <N> | <score> | <remaining> |

## Diagnostic + exception list
- <Any source failures (e.g., "Reed API 429; retried once; 3 candidates lost")>
- <Any "do not contact" filter hits>
- <Any low-confidence candidates discarded (below 0.5)>
```

Per `decision_log`: one row per source query + one row per candidate proposed + one final aggregate row.

Voice-classified content: only the per-candidate match rationale (Step 9). Voice classifier ≥0.75 against tenant style. Rationale that fails after 3 retries → ESC_VOICE_DRIFT → candidate dropped from list + flagged in exception list.

---

## §4 — Workflow

11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.

```
0. Session start
   → context.sh hydrates: tenant config + multi-source auth + voice corpus
     + "do not contact" list from tenant vault
   → hh_decision_trigger("session_start", "scout <brief-id-or-slug>")

1. Brief ingestion
   → if brief_id: bullhorn.get_brief(brief_id) → fetch fields
   → if free-text description: LLM parse → extract role / location / sector
     / seniority / day-rate-band / must-haves / nice-to-haves
   → ESC_BRIEF_AMBIGUITY if extraction yields <3 key dimensions (per
     escalation-codes.md §2.5 — canonical code for under-resolvable briefs)
   → hh_decision_output("brief_ingested", "<brief_id_or_slug>",
     "key_dims:<N>")

2. Multi-source auth refresh
   → bullhorn (read-only); LinkedIn/Proxycurl; Reed; CV-Library
   → per-source: ESC_BULLHORN_AUTH | ESC_LINKEDIN_AUTH | ESC_REED_AUTH |
     ESC_CVLIBRARY_AUTH on refresh failure (all now registered in
     escalation-codes.md §2.7)
   → if 2+ sources fail auth: ESC_AGENT_OUTPUT_SHAPE (Sourcing Scout cannot
     produce its declared output shape — 5-15 candidates aggregated across
     sources — when 2+ sources are down)
   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
     "sources_ok:<N>/4")

3. Bullhorn passive-match query
   → bullhorn.search_candidates(filter=brief_key_dimensions,
     status='active', last_activity_at < now() - interval '90 days')
     — "passive" is a derived state (active candidate with no recent
     activity); NOT a vertical-schema enum value. The schema defines
     candidate.status as [active, archived, do_not_contact, placed,
     contractor_promoted]; passive-match queries filter on activity recency
     within the active set.
   → up to 30 candidates fetched (will rank+filter later)
   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
   → hh_decision_output("bullhorn_query", "brief:<id>", "results:<N>")

4. LinkedIn search (via Proxycurl)
   → proxycurl.search_people(query=brief_key_dimensions, location=brief_location,
     industry=brief_sector)
   → up to 30 profiles
   → cache 1h per (query, location, sector) tuple
   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
   → hh_decision_output("linkedin_query", "brief:<id>", "results:<N>")

5. Reed query
   → reed.search_candidates(query=brief_dimensions, location, salary_band)
   → up to 30 candidates
   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
     (payload.upstream='reed')
   → hh_decision_output("reed_query", "brief:<id>", "results:<N>")

6. CV-Library query
   → cvlibrary.search_candidates(query, location, salary_band)
   → up to 30 candidates
   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
     (payload.upstream='cv-library')
   → hh_decision_output("cvlibrary_query", "brief:<id>", "results:<N>")

7. Aggregate + dedupe
   → merge all sources into single candidate set
   → dedupe across sources by (name + email) OR (name + phone) OR
     (LinkedIn URL) — same fuzzy matcher as Janitor (confidence ≥0.85)
   → annotate each row with source provenance (e.g., "from Bullhorn + LinkedIn
     match" if found in both)
   → hh_decision_output("aggregate_dedupe", "brief:<id>",
     "pre_dedupe:<N>; post_dedupe:<N>")

8. "Do not contact" filter
   → load tenant /vault/<slug>/do-not-contact.list (one identifier per line:
     email / phone / LinkedIn URL / Bullhorn bullhorn_id per canonical schema)
   → remove any candidate matching any DNC identifier
   → log dropped candidates to exception list
   → ESC_DNC_FILTER_HIT per blocked candidate (catalogue line: §2.10 — DNC
     hit is a blocking outbound refusal; fires per-candidate, not aggregate)
   → hh_decision_output("dnc_filter", "brief:<id>",
     "dropped:<N>; kept:<N>")

9. LLM ranking + rationale generation (per candidate)
   → for top 15 by source-aggregated confidence: generate per-candidate
     rationale ≥50 words
   → prompt = (brief context + candidate profile + voice corpus + tone rules)
   → voice classifier scores rationale (≥0.75)
   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
     from final list

10. Output assembly + Gate A validation
    → ensure 5-15 candidates remaining after Step 9
    → ensure each has working contact method (email validated via simple
      regex + domain MX check; phone validated via E.164 format)
    → ensure each rationale ≥50 words
    → if any condition fails: ESC_AGENT_OUTPUT_SHAPE (output-shape violation
      per catalogue line 184 — distinct from ESC_SCHEMA_VIOLATION which is
      reserved for vertical-schema field-constraint violations at write time);
      partial draft to /tmp; abort
    → write Markdown report to vault path per §3
    → hh_decision_output("scout_report", report_path, "N candidates from M sources")

11. Session close + notification
    → operator notification per invocation source (Brain UI: in-app
      notification; Telegram: reply with report path; webhook: bus event back)
    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
      "N=<N> sources_used=<M>")
    → exit code 0
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):

- **"5–15 candidates returned per brief"** (count within range)
- **"each has a working contact method"** (email format + MX check OR E.164 phone OR LinkedIn URL OR Bullhorn bullhorn_id-with-contact)
- **"each has rationale ≥ 50 words"**
- **"no candidate flagged 'do not contact' in tenant vault"** (DNC list scan)
- All rationales pass voice classifier ≥0.75
- No PII outside firm boundary in rationale text
- No source contributed 0 candidates (suggests source auth failure undetected by Step 2)

Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation per catalogue line 184); draft to `/tmp`; operator review.

**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.

### Gate B — Outcome threshold (success metric, not block)

Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.

Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.

Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).

Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.

---

## §6 — Escalation codes

Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (2+ source fails abort) | operator |
| `ESC_LINKEDIN_AUTH` | Proxycurl API key invalid | warn (single-source fail OK if 2+ others succeed) | operator_chat_id |
| `ESC_REED_AUTH` | Reed API fail | warn | operator_chat_id |
| `ESC_CVLIBRARY_AUTH` | CV-Library API fail | warn | operator_chat_id |
| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
| `ESC_DNC_FILTER_HIT` | Outbound candidate matches tenant DNC list (per-candidate; blocks the candidate's inclusion) | **blocking** (per-candidate) | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | founder + operator |

Sourcing Scout does NOT use:

- `ESC_AUTOSEND_*` — no auto-send actions; pure read + report
- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate

---

## §7 — Voice + tone constraints

Step 9 (per-candidate rationale generation) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
  - No demographic inference (age, gender, nationality, ethnicity, family status) — Equality Act 2010 compliance
  - No salary-band reference unless explicitly supplied by candidate
  - No claims about candidate intent ("looking to leave their role") without evidence in source data
  - No mention of competing agency placements except in risk-flag context
- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Build dependencies (W9 prerequisites)

Sourcing Scout build cannot start until ALL of the following are confirmed:

| Dependency | Source | Status |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
| Bullhorn MCP read capability | W3-W4-W5 build chain | ⏸ |
| **Proxycurl commercial signup** + API access | Founder commercial; ~$39+/mo | ⏸ |
| **Reed.co.uk commercial signup** + API access | Founder commercial | ⏸ |
| **CV-Library commercial signup** + API access | Founder commercial | ⏸ |
| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
| Reed MCP connector | W9 build start (~2 days) | ⏸ |
| CV-Library MCP connector | W9 build start (~2 days) | ⏸ |
| Source-abstraction layer (Night Sourcer reuse) | W9 build start (~2 days) | ⏸ |
| Per-tenant source credentials in `_secrets.env` | Tenant onboarding | ⏸ |
| Tenant DNC list at `/vault/<slug>/do-not-contact.list` | Tenant onboarding | ⏸ |
| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
| `context.sh` hydration | Build at W9 start (~0.5 day) | ⏸ |
| `cycle.sh` orchestration (11-step) | Build at W9 start (~2 days) | ⏸ |
| 3 fixtures with golden outputs | Build at W9 start (~1 day) | ⏸ |

**Until ALL ⏸ items resolve to ✅, W9 build slice does not start.**

---

## §9 — Status + open questions

**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.

### Open questions for founder review

| # | Question | Resolution path |
|---|---|---|
| Q1 | All three external sources required for v1.0? Reed + CV-Library are UK-recruitment-specific; Proxycurl is LinkedIn-via-API. Could v1.0 ship with Bullhorn + Proxycurl only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
| Q2 | Proxycurl pricing — ~$39/mo for 5,000 credits at low volume; scales with usage. Per pilot tenant budget? | ~5-10 briefs/day per consultant × 50 calls/brief = up to 2,500 credits/day per consultant. Cost: ~$20-50/day at peak. |
| Q3 | DNC list source — tenant uploads a list, or we derive from Bullhorn entity flag? | v1.0: tenant-uploaded text file at `/vault/<slug>/do-not-contact.list`. v1.1: derive from Bullhorn entity field. |
| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
| Q5 | Gate B 6-of-10 metric — measured via consultant feedback. Brain UI v1.0 doesn't have feedback UX yet. Telegram reply? | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful". v1.1: Brain UI button. |
| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Existing Bullhorn candidate-status enum has "passive" / "active" / "placed". | Founder + Bullhorn-rep clarification during Sub-decision B response. |

### Gotchas (carried forward from ULTRAPLAN A5 line 555)

1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.

Status flips Proposed → Accepted when:
- Codex Round 4 Phase 2 ratifies
- Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B UX)
- Q2 cost model approved with per-tenant budget cap
- Q6: ADR-006 (source-abstraction layer) drafted + ratified

Status flips Accepted → In Force when:
- W9 build slice produces all 5 sibling bundle files + 3 fixtures
- First production brief processed end-to-end against migration-test tenant
- Gate B feedback loop operational (Telegram OR Brain UI)
- Codex re-ratifies post-build via `review-agent-bundle.md` skill

Until then: this document is a forward-looking scaffold.

*End of Sourcing Scout agent.md draft.*

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
I’ll verify the cited project sources before judging the scaffold: master brief/ULTRAPLAN anchors, shared ESC catalogue, voice helper, schema, and any policy references that affect Gate A/B.
exec
/bin/zsh -lc "rg --files | rg '("'^|/)(vertical-schema.yaml|.*ULTRAPLAN.*|.*master.*brief.*|autosend-safety-policy.yaml|voice-loader.sh|hook-helpers.sh|escalation-codes.md|v1.0-kill-criterion.md)$|agents/recruitment/sourcing-scout'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml
docs/specs/ULTRAPLAN.md
docs/decisions/v1.0-kill-criterion.md
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
agents/recruitment/sourcing-scout/README.md
agents/recruitment/sourcing-scout/agent.md
legacy/v1/docs/phase-2-agent-suite/_shared/escalation-codes.md
legacy/v1/docs/phase-2-agent-suite/_shared/hook-helpers.sh

exec
/bin/zsh -lc "rg -n \"Sourcing Scout|A5|W9|Proxycurl|ESC_LINKEDIN_AUTH|ESC_DNC_FILTER_HIT|ESC_AGENT_OUTPUT_SHAPE|ESC_GATE_B_MISS|ESC_BRIEF_AMBIGUITY|ESC_VOICE_DRIFT|candidate.status|do_not_contact|autosend-safety-policy|Change 1|Change 2|§8\\.2|v1\\.0\" docs agents packages -S" in /Users/madsadmin/code/CortexOS
 succeeded in 1ms:
agents/_shared/autosend-policy.yaml:3:# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
agents/_shared/autosend-policy.yaml:8:# 47 v1.0 action_types: 19 green + 10 yellow + 10 orange + 8 red.
agents/_shared/autosend-policy.yaml:11:#   agent           v1.0 owning agent (or "all" if cross-cutting red rule)
agents/_shared/autosend-policy.yaml:21:version: "v1.0-2026-05-24"
agents/_shared/autosend-policy.yaml:116:    reason: "Internal audit row written by validate.sh when Gate A enforcement fails. Carries the specific ESC code (e.g. ESC_AGENT_OUTPUT_SHAPE | ESC_PII_LEAKAGE_RISK) in the payload; the action itself is just the audit-row write, not an external send. Each agent's validate.sh emits this row before exit 1."
agents/_shared/autosend-policy.yaml:128:    reason: "Internal audit row written by cycle.sh when @ifos/diagnostic-generator produces empty stdout. Carries ESC_AGENT_OUTPUT_SHAPE payload."
agents/_shared/autosend-policy.yaml:300:    reason: "Payment transfer; financial-bearing; never auto-send in v1.0"
agents/_shared/autosend-policy.yaml:372:  - "47 total action_types (19 green + 10 yellow + 10 orange + 8 red); v1.0 frozen as of 2026-05-24 bilateral-disposition extension"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:66:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:78:        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:81:          - Sourcing Scout: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:92:        source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:94:          - Sourcing Scout: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:134:          Hard requirements; Sourcing Scout filters candidates against this
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:139:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:147:          Soft preferences; Sourcing Scout uses for ranking, not hard filter.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:151:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:159:          Anti-requirements; Sourcing Scout EXCLUDES candidates matching any
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:164:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:224:          ("we're hiring 5 engineers this quarter"). Sourcing Scout reads
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:229:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:238:          ranking in Sourcing Scout's brief-to-candidate pipeline.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:242:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:260:# Per review-schema-change skill §5: full matrix across all v1.0 agents
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:290:#   - Sourcing Scout candidate: R → R+W (writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:293:#   - Sourcing Scout opportunity: none → R (reads opportunity context for ICP)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:364:    contractor: none       # not in scope at v1.0
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:387:    # uses Bullhorn endpoints for the 5 v1.0-supported entities; other
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:394:    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields written to IFOS-cached Postgres rows only (Bullhorn Opportunity endpoint NOT used at v1.0 per integration-path §4.1)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:396:    timesheet: R           # IFOS-cached read; placement-context resolution (Bullhorn Timesheet endpoint NOT used at v1.0)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:417:    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:439:    opportunity: R         # IFOS-cached read; outbound lifecycle-event context (Bullhorn Opportunity endpoint NOT used at v1.0)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:441:    timesheet: R           # IFOS-cached read; placement-progress for 7d/30d/90d nurture (Bullhorn Timesheet endpoint NOT used at v1.0)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:458:    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:464:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:477:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:503:      - Sourcing Scout (R) # v0.3 NEW — reads opportunity for ICP scoring
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:507:      to all v1.0 agents because the entity gains 3 new fields used across
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:508:      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:535:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:540:      - Sourcing Scout (R+W) # v0.3 UPGRADED — writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:543:      v0.3 upgrades Sourcing Scout (writes proposed-candidate rows from
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:548:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:552:      - Sourcing Scout (R+W) # v0.3 UPGRADED — same pattern as candidate
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:562:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:564:      All v1.0 agents that produce voice-classified output (Diagnostic for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:566:      Conductor for chase drafts; Sourcing Scout for per-candidate
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:572:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:577:      Diagnostic + Sourcing Scout also read tone_rules for their
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:589:      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:685:    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents that
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:695:    # All v1.0 agents producing voice-classified output need R for ANN-match retrieval
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:704:    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents
docs/verticals/recruitment/vertical-schema.yaml:12:#       + autosend-safety-policy.md §3 (action_type references)
docs/verticals/recruitment/vertical-schema.yaml:14:#       + Day-5 v1.0-kill-criterion.md (Trigger 1 acquisition-by-2026-06-03)
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:36:#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:55:      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:75:        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
docs/verticals/recruitment/vertical-schema.yaml:88:        enum: [active, archived, do_not_contact, placed, contractor_promoted]
docs/verticals/recruitment/vertical-schema.yaml:141:        source: IFOS-derived (set by Sourcing Scout at first-touch)
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:285:      A person at a client company. Decision-makers, hiring managers, HR, procurement. Bullhorn calls this `ClientContact`. v1.0 representation is thin (10 fields); v1.1 Triage agent expands decision-authority modelling.
docs/verticals/recruitment/vertical-schema.yaml:288:      - Concierge (R — decision-maker context per bullhorn §4.1 A6; thin in v1.0)
docs/verticals/recruitment/vertical-schema.yaml:331:      do_not_contact:
docs/verticals/recruitment/vertical-schema.yaml:337:      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
docs/verticals/recruitment/vertical-schema.yaml:349:      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:497:      A candidate-brief pairing in the submission/screening/interview/offer pipeline. Pre-placement state. v1.1+ exercised; v1.0 minimal.
docs/verticals/recruitment/vertical-schema.yaml:531:      - v1.0 schema captures shape for forward-compatibility but no v1.0 agent reads or writes Opportunity.
docs/verticals/recruitment/vertical-schema.yaml:580:#   - v1.0 vs v1.1+ exercise notes
docs/verticals/recruitment/vertical-schema.yaml:606:    v1_0_exercise: All 4 Bullhorn-touching v1.0 agents.
docs/verticals/recruitment/vertical-schema.yaml:630:    v1_0_exercise: Concierge reads for outbound-message addressee correctness; thin in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:637:    v1_0_exercise: Sourcing Scout captures at first-touch when relevant; not heavily exercised in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:644:    v1_0_exercise: None (Opportunity entity not v1.0-exercised).
docs/verticals/recruitment/vertical-schema.yaml:665:# Source-of-truth for who-touches-what across v1.0 agents.
docs/verticals/recruitment/vertical-schema.yaml:666:# Cross-referenced to bullhorn-integration-path.md §4.1 + autosend-safety-policy.md §3.
docs/verticals/recruitment/vertical-schema.yaml:716:    contact: none    # thin v1.0
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:810:    v0_1_decision: v0.1 ships minimal v1.0 working set (~10-20 fields per entity) covering what the 6 v1.0 agents actually touch per bullhorn §4.1.
docs/verticals/recruitment/vertical-schema.yaml:841:    revisit_trigger: Skill-matching accuracy from Sourcing Scout's first 4 tenant-weeks of operation; if free-text matching produces <60% precision, canonical skill taxonomy lands as v1.1.
docs/verticals/recruitment/vertical-schema.yaml:856:    rationale: v1.0 Concierge addressee-resolution uses primary-decision-maker; panel modelling adds value when v1.1 Triage handles inbound brief queries from multiple stakeholders.
docs/verticals/recruitment/vertical-schema.yaml:864:      Hardcoded enum is the lowest-friction v0.1 choice; alternative (lifecycle_stage as free-form string) loses query-time validation. Tradeoff: schema-migration-on-change vs runtime-validation-loss. v1.0 picks former.
docs/verticals/recruitment/vertical-schema.yaml:867:    status: DEFERRED to v1.0 Codex ratification
docs/verticals/recruitment/vertical-schema.yaml:872:      Codex Day-7 ratification reviews whether stricter source-field schema would improve machine-parseability. If accepted, v1.0 introduces structured source object — e.g., `source: {origin: bullhorn | ifos_derived, bullhorn_field?: <entity.field>, ifos_agent?: <agent_name>, citation?: <doc-ref>}`.
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:400:    -- autosend-safety-policy.md keys
docs/RISK-REGISTER.md:3:Updated weekly. Honest naming. No hedging. The four that could kill v1.0 are at
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:13:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 to 4 agents; founder solo through end of v1.0 | Active — not yet at trigger |
docs/RISK-REGISTER.md:22:| 6 | **Concurrency-document-prerequisite** — without `docs/architecture/vault-concurrency.md`, the wiki/lib/concurrency.ts code can't be reviewed; week-5 first multi-agent test runs against unreviewed concurrency machinery | ~~Medium~~ **Closed** | ~~Medium~~ **Closed** | (closed) | **Closed 2026-05-16 Day 3 evening:** `docs/architecture/vault-concurrency.md` shipped at 455 lines. 4 mechanisms specified with TypeScript worked examples (`flock(2)`, Postgres optimistic concurrency, mtime debounce, rewrite-backlinks cascade). 5 new `ESC_VAULT_*` codes consolidated for `_shared/hook-helpers.sh` Week-1 prereq. Surfaces 1 new Day-4 tightening (`entities.version` column per §3.1). v1.0 atomicity gap honestly documented; v1.2+ WAL pattern deferred. **Source:** Spec gap 2.6 in `second-brain-design.md`. |
docs/RISK-REGISTER.md:24:| 8 | **LUKS manual unlock single-point-of-failure** — `/dev/mapper/ifos_data` is `noauto` per Day-4 §4.7; every server reboot requires founder to SSH in and run `sudo /usr/local/bin/ifos-unlock` with the LUKS passphrase. Postgres + vault are unavailable until that happens. If founder is unavailable during an unplanned reboot, the server runs but no agent work can proceed. | Low | Medium-High (Postgres dead until founder unlocks; acceptable for pilot, unacceptable at scale) | Any unplanned reboot during pilot operations where the founder is unreachable for >30 minutes | **Documented mitigation in `ifos-unlock` script at `/usr/local/bin/ifos-unlock` (Day-4 §4.7) + this risk register entry.** v1.0 accepts the trade-off — reboots rare, founder solo, single-server. **v1.2+ improvement (named):** investigate TPM-bound LUKS unsealing OR key-server-based auto-unlock (cloud-init-style retrieval from an off-box keystore). Tripwire for v1.2 work: first pilot at >1 tenant scale, or any unplanned reboot incident where Postgres downtime hurt operations. **Owner:** founder for incident detection, Claude Code for v1.2+ design. **Source:** Day-4 §0.4 LUKS Option β decision; runbook §11.2 future-risk note. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:13:The payload template established by `agent-bundle-renderer-design.md` §4 + ratified in `autosend-safety-policy.md` §5:
agents/_shared/escalation-codes.md:31:Source: `docs/decisions/autosend-safety-policy.md` §5
agents/_shared/escalation-codes.md:82:- **Trigger:** Rewrite-backlinks cascade completed but ≥1 referencing entity failed to rewrite per vault-concurrency §5.4 v1.0 mitigation
agents/_shared/escalation-codes.md:120:#### `ESC_VOICE_DRIFT`
agents/_shared/escalation-codes.md:136:- **Trigger:** Supply Chain Auditor detected red flag (v1.0 placeholder; SCA agent in v1.1 backlog)
agents/_shared/escalation-codes.md:139:- **Status:** v1.0 placeholder; no agent fires this yet. Reserved name.
agents/_shared/escalation-codes.md:141:#### `ESC_BRIEF_AMBIGUITY`
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:158:- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
agents/_shared/escalation-codes.md:170:#### `ESC_VOICE_DRIFT_TENANT`
agents/_shared/escalation-codes.md:172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
agents/_shared/escalation-codes.md:184:#### `ESC_AGENT_OUTPUT_SHAPE`
agents/_shared/escalation-codes.md:238:Source: derived from v1.0 agent.md adapter references (Bullhorn, Reed, CV-Library, LinkedIn, Gmail, Outlook/MS Graph, Xero, Open Banking)
agents/_shared/escalation-codes.md:256:#### `ESC_LINKEDIN_AUTH`
agents/_shared/escalation-codes.md:257:- **Severity:** **blocking** — Sourcing Scout enters degraded mode (no profile fetches; cached only)
agents/_shared/escalation-codes.md:262:- **Recovery:** founder reauthenticates LinkedIn via Sourcing Scout admin flow
agents/_shared/escalation-codes.md:308:Source: derived from v1.0 agent.md adapter call sites
agents/_shared/escalation-codes.md:339:Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:377:#### `ESC_GATE_B_MISS`
agents/_shared/escalation-codes.md:383:- **Note:** Local Gate B is a leading metric for agent quality; consecutive misses inform per-agent quality review. Not tied to a kill-criterion trigger in v1.0 (per disagreement-doc Cat-3 disposition).
agents/_shared/escalation-codes.md:402:- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
agents/_shared/escalation-codes.md:424:#### `ESC_DNC_FILTER_HIT`
agents/_shared/escalation-codes.md:452:  - **Concierge:** Bullhorn state transition is outside the 12-event v1.0 taxonomy (acknowledgement / prep / debrief / placement / rejection / withdrawal / on-hold / start-confirm / 7d-checkin / 30d-checkin / 90d-checkin / nurture); handler logs + skips draft
agents/_shared/escalation-codes.md:461:These names are reserved by design documents but no agent fires them in v1.0. Listed here to prevent collision; do not invent codes overlapping these names.
agents/_shared/escalation-codes.md:466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:49:**Codex says:** "Line 169 claims Diagnostic's 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:106:Recommended next step (post-arbitration): Week-3-extension or W4-prio-1 build of `review-agent-bundle.md` skill; then re-run Codex Round 4 against all 6 v1.0 agent.md files with the proper skill.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:122:| Sourcing Scout | ~5-7 (count regex 50) | `logs/codex-ratification/20260524T1024...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:216:3. `ESC_GATE_B_MISS` definition in §6 still says "Composite Gate-B score <12.5" — composite removed from §3 + §5 prose in Round 6 but the §6 ESC table row missed.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:255:All 6 v1.0 agent.md files coordinated single-pass remediation:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:261:- Cross-section consistency: removed (new — W-X catalogue add) annotations; ESC_AUTOSEND_BLOCKED kept red-tier-only; ESC_SCHEMA_VIOLATION kept schema-field-violation-only; ESC_VOICE_DRIFT_TENANT removed from direct firing across all agents; ESC_AUTOSEND_YELLOW_SPOT_CHECK → ESC_AUTOSEND_SAMPLED_SPOT_CHECK
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:276:| Sourcing Scout | 4 | `20260524T113139Z-84869` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:284:- Sourcing Scout ULTRAPLAN A5 line refs: Gate A 553→552, Gate B 554→553 (4 citation sites)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:318:  - Sourcing Scout per-candidate decision rows (claimed in §3 but not in §4 cycle)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:333:- Sourcing Scout: pre-build-scaffold; Round-8-reviewed; minimal residual (catalogue-widening + per-candidate decision rows)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:363:- `validate.sh` emits specific §6 ESC codes (ESC_PII_LEAKAGE_RISK or ESC_AGENT_OUTPUT_SHAPE) not generic ESC_SCHEMA_VIOLATION
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:374:| Sourcing Scout | 4 | 5 | +1 (Q7 enum claim missed by my Round-8 fix; Bullhorn webhook conflict newly surfaced) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:389:**Sourcing Scout R9:**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:391:2. ESC auth severity downgrade vs catalogue — Codex–founder disagreement (Sourcing Scout intentionally allows single-source auth failure as warn-only when 2+ sources remain; catalogue defines blocking. Real semantic divergence; needs catalogue widening OR Sourcing Scout agent.md realignment)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:392:3. ESC_DNC_FILTER_HIT used for shortlist filtering (pre-outbound), catalogue defines for outbound refusal — Cat-γ widening needed (similar to other 5 widened)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:393:4. Bullhorn webhook v1.0 trigger conflicts with bullhorn-integration-path.md (webhooks v1.1+ only) — Cat-β-adjacent; agent.md should remove v1.0 webhook trigger
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:419:4. **Catalogue v2 widening for ESC_DNC_FILTER_HIT + Sourcing Scout auth severity** — Cat-γ continuations
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:430:| Sourcing Scout | Pre-Build-Round-9-Reviewed | 5 (Cat-α Q7 + bullhorn-path conflict + Cat-γ DNC + Cat-ε per-candidate row + auth severity disagreement) | Mechanical Q7 fix + Bullhorn-path realignment + ESC widening 2 |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:274:    index_type: hnsw                                 # HNSW preferred over IVFFlat for v1.0 corpus sizes (<10k chunks/tenant)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:325:        v1.1+ Triage exercises this; v1.0 sets to NULL. Tracks voice score for outbound messages within a specific candidate-brief opportunity pairing.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:357:      Recorded but not actively driving retraining in v1.0 (Brain UI v1.1 surfaces the queue; v2.0 LoRA pipeline reads it). v0.2 establishes the linkage schema so production data accumulates cleanly from W3 forward.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
agents/_shared/hook-helpers.sh:4:# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
agents/_shared/hook-helpers.sh:163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
agents/_shared/hook-helpers.sh:259:# 7 autosend_* helpers (autosend-safety-policy §4)
agents/_shared/hook-helpers.sh:286:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
packages/diagnostic-generator/src/generate.ts:49:    `**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).`,
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:43:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:49:The per-claim citation pipeline (NLP claim-extraction + per-claim evidence-link matching + aggregate quality metric) is **explicitly outside Gate A** in v1.0. It lands as:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:83:- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:120:- Aggregate metric writes to `decision_log.payload` via key landing in autosend-safety-policy §7 supplement (concrete key name specified there, not in this ADR)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:121:- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:739:            &middot; <a href="#">ESC_BRIEF_AMBIGUITY</a> raised to <a href="#">Sarah Whittaker</a>
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
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:43:- `docs/decisions/v1.0-kill-criterion.md` §3.4 ("Week 1-2 must-fill")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:44:- `docs/decisions/autosend-safety-policy.md` §10 ("Pilot-agreement liability language placeholder — counsel-reviewed")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:49:**Real issue:** v1.0 kill-criterion §3.4 names "external advisor" as a Week 1-2 must-fill. This is also the resolution path for autosend §10 pilot-agreement liability. Today = 2026-05-20 (Day 8 = Week 1 underway). No advisor identified.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:80:**Cost of delay:** Same as D2 — Trigger 1 fires 2026-06-03. If LOI lands before D3 resolves, founder ships v1.0 with D3-A indefinite retention, which is the worst legal posture. Bundle D2 + D3 resolution.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:142:| **D1** (autosend v1.0 tier) | This week | Concierge build scope (W10-13) |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:36:- **Kill criterion linkage:** Trigger 1 in `docs/decisions/v1.0-kill-criterion.md` §2 (DESIGN-PARTNER-BY-WEEK-2) fires end-of-day **2026-06-03** if no signed LOI by then. That is the binding tripwire — currently **14 calendar days** out from today (2026-05-20).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:45:- **Primitive 5 (Telegram + iOS approval surface):** confirmed shipped per `cortexos-primitive-status.md` audit. Two-poller mechanism (`agent-manager.ts:478-575`, `maybeStartActivityChannelPoller()`) integrates with primitive 4 approval gates. Per master brief §12 Risk #1 framing: "Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5."
docs/decisions/2026-05-18-day-7-single-sentence-test.md:46:- **Caveat:** primitive 1 (PTY/PM2) carries Risk #1 "shipped but flaky" status. Risk #1 was downgraded on Day 1 because primitives 3 and 4 were confirmed shipped-and-tested; primitive 1 retained the flaky-under-load designation. Operationally sound for the 6 v1.0 agents per Day-1 audit; v1.1+ scale (13+ agents) may require revisit.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:49:**YES because operationally sufficient for the v1.0 6-agent build window** that Week 1+ will exercise. Caveat documented above.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:71:- **Risk #5 (renderer-not-built)** in `docs/RISK-REGISTER.md` reduced from Blocking → High on Day 1 evening when ADR-003 + design doc Accepted. Three-stage ladder to Medium (W4 first Diagnostic render) → Low (W13 all 5 v1.0 bundles rendered).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:79:- **Depth:** 89 canonical fields, 10 entity_links relationships, agent × entity R/W matrix across all 6 v1.0 agents (cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3), Bullhorn mapping per entity, 12 open questions catalogued (Q1+Q4 resolved inline; Q2/Q3/Q5-Q12 deferred with named revisit triggers).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/ADR-003-agent-bundle-renderer.md:147:**For Risk #5 (renderer-not-built).** Severity drops from **Blocking** to **High** with ADR-003 Accepted — design exists, ratified; just needs implementing. Drops to **Medium** once renderer code is committed and the Diagnostic agent renders cleanly (Week 4). Drops to **Low** once all five v1.0 agent bundles render and pass validation. The risk register entry is updated in this session as part of the ADR-003 commit.
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:221:The 12 invariants above are the v1.0 set. Adding a new invariant (T13+) OR modifying an existing one requires:
packages/diagnostic-generator/README.md:36:1. **No LinkedIn deep data.** Page-existence check via HEAD only. Full data needs Proxycurl signup (~$39/mo).
packages/diagnostic-generator/README.md:50:| LinkedIn HEAD returns 999 (bot detection) | §2 treats as "page exists, deep data via Proxycurl"; not a failure |
docs/decisions/brain-ui-scope.md:4:**Status:** Proposed — revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch)
docs/decisions/brain-ui-scope.md:6:**Surfaced by:** Master brief §6 Day 3 line 472 — "Brain UI v1.0 scope decision" + ADR-002 §3.4 closing paragraph (Brain UI explicitly forward-deferred to v1.1) + `second-brain-design.md` §3.4 ("Brain UI minimal v1 is built as a thin read-only page over `decision_log` — no new wiki API needed").
docs/decisions/brain-ui-scope.md:9:**Reading order:** master brief §5.5 (Brain UI build sequence stages) + ADR-002 (parallel-not-shadow + v1.0 brain build wording correction) + `second-brain-design.md` §3.4 closing paragraph (Brain UI v1.0+ scope) first; then this document end-to-end.
docs/decisions/brain-ui-scope.md:17:- **v1.0 minimum (weeks 11-13):** wiki API + Postgres tables (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector voice samples + 9 `wiki-*.sh` parallel wrappers + 9 `wiki/lib/*.ts` modules. **No Brain UI** — operational access via Obsidian + CLI + psql.
docs/decisions/brain-ui-scope.md:22:This document scopes the **v1.1 Brain UI work without committing to implementation details.** The decision deferral is by design — at v1.1 phase start, founder + Claude Code will have observed v1.0 actual wiki usage patterns and can scope sub-features and implementation choices against real evidence rather than speculation.
docs/decisions/brain-ui-scope.md:24:**Revisit trigger:** start of v1.1 phase (estimated Q4 2026 post-v1.0 launch per Ultraplan §9 line 725 + Product Spec §9.2 v1.1 timing). Three v1.0 observations will inform the v1.1 scoping session:
docs/decisions/brain-ui-scope.md:26:1. Which wiki operations get hit hardest in v1.0 (decision_log queries vs entity reads vs entity_links traversals) — informs which feature lands first in v1.1.
docs/decisions/brain-ui-scope.md:27:2. How often founder accesses the vault via Obsidian vs CLI in v1.0 ops — informs whether founder-tooling or design-partner-facing-UI is the v1.1 priority.
docs/decisions/brain-ui-scope.md:28:3. What the first paying design partner asks for after Concierge ships in v1.0 — direct user-research input.
docs/decisions/brain-ui-scope.md:43:- Highlights `ESC_*` escalations across all agents — `ESC_BULLHORN_AUTH`, `ESC_VOICE_DRIFT`, `ESC_DUPLICATE_DETECTED`, `ESC_RENDERER_FAILED`, etc.
docs/decisions/brain-ui-scope.md:55:**Dependency on v1.0:** wiki API live + `decision_log` populated per ADR-002 §3 Decision 3 + extended phase enum per `sequencing-target.md` §6.5.
docs/decisions/brain-ui-scope.md:74:**Dependency on v1.0:** `entity_links` table live + populated by v1.0 wiki ingest paths (`wiki/lib/update.ts` rewrite-backlinks cascade per `second-brain-design.md` §2.6.3).
docs/decisions/brain-ui-scope.md:92:**Dependency on v1.0:** `wiki-find.sh` shipped in v1.1 itself (the wrapper isn't a v1.0 deliverable per ADR-003 §"Decision 3" wrapper table); `decision_log` + `entities` populated in v1.0.
docs/decisions/brain-ui-scope.md:98:Two options. **Neither chosen in v1.0.** Trade-offs documented for the v1.1 planning session.
docs/decisions/brain-ui-scope.md:126:**Recommendation deferred to v1.1 planning.** Master brief §5.3 lines 379-380 currently favours Option α: "**The strategy: same Next.js app, additional routes in a sibling folder**, mounted via the dashboard's `dashboard-ext` integration point." That's the canonical-master-brief stance and is the default unless v1.0 ops surface a reason to deviate. This document does not bind the decision in v1.0 — it's revisited with v1.0-actual-usage evidence.
docs/decisions/brain-ui-scope.md:132:### 4.1 — For v1.0 (weeks 11-13)
docs/decisions/brain-ui-scope.md:134:No UI work. Wiki API + Postgres + pgvector + filesystem is the v1.0 deliverable per ADR-002 Edit 2 + `second-brain-design.md` §3.4 closing paragraph. Master brief §5.5 already correctly scopes this (post-Edit-2). No new constraint from this document.
docs/decisions/brain-ui-scope.md:136:### 4.2 — For founder operations (v1.0 ops)
docs/decisions/brain-ui-scope.md:138:Founder accesses v1.0 wiki via three channels:
docs/decisions/brain-ui-scope.md:144:No UI needed for v1.0 internal ops. Acknowledged operational constraint; trades founder ergonomics for v1.0 ship speed.
docs/decisions/brain-ui-scope.md:146:### 4.3 — For first design partner (v1.0 sales)
docs/decisions/brain-ui-scope.md:148:The v1.0 demo per master brief §10.6 live-demo pattern + Product Spec §10 closing-demo asset shows:
docs/decisions/brain-ui-scope.md:154:**No Brain UI tour in v1.0 sales motion.** Brain UI is a forward-feature, not a v1.0 sales asset. The closing demo is the agent outputs landing in the design partner's existing tools — the wedge per master brief §0 paragraph 1. Brain UI joins the sales asset list at v1.1.
docs/decisions/brain-ui-scope.md:160:1. **Validate** that the three v1.1 features (today view, backlinks panel, wiki-find UI) are still the right priorities given v1.0 actual usage patterns.
docs/decisions/brain-ui-scope.md:161:2. **Decide α vs β** implementation surface based on (a) cortextOS submodule upgrade frequency observed in v1.0, (b) founder UX-preference signal from observed ops, (c) first design partner's UI requirements if any.
docs/decisions/brain-ui-scope.md:172:> "- [ ] **Brain UI v1.0 scope decision.** Per §5.5, v1.0 ships the `bus-overrides/kb-*.sh` shadow + ingest/search lib + the `/brain` today-view. The full wiki rendering is v1.1, the graph is v1.2. **Confirm this in `.agents/decisions/brain-ui-scope.md`** — or document the deviation."
docs/decisions/brain-ui-scope.md:176:> "- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation."
docs/decisions/brain-ui-scope.md:182:3. **`/brain` today-view as v1.0 deliverable** → today-view is v1.1 (corrects against ADR-002 Edit 2 §5.5 v1.0 brain build wording).
docs/decisions/brain-ui-scope.md:189:4. ADR-002 Edit 2 §5.5: v1.0 brain build wording
docs/decisions/brain-ui-scope.md:201:- §1 (forward-deferral framing — Status: Proposed is structurally appropriate because v1.0 actual-usage evidence is the input v1.1 planning needs).
docs/decisions/brain-ui-scope.md:211:All operational defaults below are revisited at v1.1 planning session start. None blocks v1.0; none requires master-brief edit beyond the 8th edit captured in §4.5.
docs/decisions/brain-ui-scope.md:217:| Real-time vs polling for today view refresh (default polling 30-60s) | v1.1 planning — based on observed v1.0 escalation frequency; if `ESC_*` rate is high, real-time may matter |
docs/decisions/brain-ui-scope.md:229:**Proposed.** Revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch per Ultraplan §9 line 725 + Product Spec §9.2). At revisit, founder + Claude Code:
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:13:ULTRAPLAN.md §8.1 specifies the v1.0 build sequence:
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:23:| 9 | Sourcing Scout |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:51:5. **Buffer on kill-criterion Trigger 2.** `v1.0-kill-criterion.md` Trigger 2 fires 2026-06-14 if Diagnostic doesn't render cleanly. Today is 2026-05-24 — 21 days of buffer. Building now beats the deadline by 3 weeks.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:75:- Sourcing Scout (W9) touches Bullhorn read; same gating
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:109:- `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render by 2026-06-14)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:119:| LinkedIn deep data via Proxycurl: now or W4? | Day-13 founder pick: Option A (free unauthenticated path) for v0; Proxycurl evaluated W4 polish |
agents/_shared/voice-loader.sh:4:# §8.1 Change 1. Sourced by every agent's context.sh at session start; emits
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:37:  'Per Founder Decision D3 (v1.0 default: 90-day window).';
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:33:Per `second-brain-design.md` §3.3, the agent-to-brain interface is shell wrappers that match cortextOS's existing 47-script `bus/` convention. v1.0 ships **9 wrappers + 1 v1.1 stub**, each a thin shim execing into a Node CLI at `packages/brain/wiki-cli/dist/cli.js`, which dispatches to a library at `packages/brain/wiki/lib/`.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:39:| `wiki-search.sh` | search-by-name | v1.0 |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:40:| `wiki-get.sh` | search-by-id | v1.0 |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:41:| `wiki-links.sh` | search-by-relationship + backlinks | v1.0 (relationship), v1.1 (backlinks read API) |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:42:| `wiki-ingest.sh` | ingest-entity | v1.0 |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:43:| `wiki-update.sh` | update-entity (+ rewrite-backlinks cascade per design §2.6.3) | v1.0 |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:44:| `wiki-append.sh` | append-to-narrative | v1.0 |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:45:| `wiki-list.sh` | list-by-type-and-tenant | v1.0 |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:63:- **Postgres tables (v1.0):** `tenants`, `entities`, `entity_links`, `decision_log` — schemas in design §2.4.2. RLS by tenant_slug on every table except `tenants`. The Ultraplan §5.1 line 227 single `entity_graph` table is **split** into `entities` (one row per entity) and `entity_links` (adjacency) — see Spec gap 2.4-B in the design doc.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:64:- **pgvector index (v1.0):** `voice_samples_embedded` only — embedding model `gemini-embedding-001` (3072 dimensions), matching cortextOS's KB substrate for forward-compatibility per design §2.4.3.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:83:**Proposed:** "IFOS implements its second brain as a **parallel system**, not by shadowing cortextOS's stock knowledge base. cortextOS's `bus/kb-*.sh` files (`kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh` at SHA `c21fbfe`) remain untouched and continue to serve cortextOS-template agents. IFOS agents invoke a parallel wrapper surface at `packages/brain/bus-overrides/wiki-*.sh` (9 v1.0 + 1 v1.1 stub) that dispatches to `packages/brain/wiki/lib/` against Postgres + filesystem markdown. The §3.1 'four `bus/kb-*.sh` shadow points' edit-exception is unused — IFOS does not edit any file under `packages/harness/cortextos/`. See `docs/architecture/second-brain-design.md` for the full design."
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:85:### Edit 2 — Master brief §5.5 v1.0 brain build wording
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:89:> "v1.0 minimum (weeks 11-13) — `bus-overrides/kb-*.sh` shadow + `wiki/lib/{ingest,search}.ts` — agents can write and search but no UI yet"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:93:> "v1.0 minimum (weeks 11-13) — 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; no Brain UI yet. Total v1.0 effort ~11-13 person-days. v1.1 adds `wiki-find.sh` + `wiki-history.sh` + Brain UI today-view and backlinks panel."
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:109:**For the v1.0 brain build (weeks 11-13).** Reference `second-brain-design.md` §3.4 closing paragraph. Weeks 11-13 hold; scope is materially clarified (9 wrappers + 9 library modules + 4 tables + pgvector voice index vs. the original "shadow four files + 2 .ts files" framing). v1.0 effort estimated at 11-13 person-days, fitting the 15-day budget.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:121:**For the master brief atomic correction commit.** ADR-001 (Edit: `chokidar watcher` → `FastChecker poll loop` in §2.4 row 3 + §3.2 latency reframe in Ultraplan) and ADR-002 (Edits 1, 2, 3 above — §3.4 wording, §5.5 v1.0 brain build wording, §6 Day 4 Postgres table list) **all landed together in commit `0e5b2b4` on 2026-05-20** ("docs: master brief reconciliation — 11 edits batch-applied"). Ratified by Codex on Day 7 along with ADR-001 + ADR-003 per master brief §10.6.
packages/diagnostic-generator/src/sections/online-footprint.ts:87:      `LinkedIn company page: [${data.linkedInUrl}](${data.linkedInUrl}) (page exists; LinkedIn bot-detection returned ${data.linkedInStatus}, full content needs authenticated fetch — Proxycurl integration v1.1).`,
docs/architecture/architecture-cohesion-review.md:92:| A5 | **The cortextOS daemon `discoverAgents()` filters by directory pattern, not contents.** Means `.tmp.<pid>/` + `.prev.<ts>/` dirs are invisible. | ADR-003 §3.3.4 atomic-write protocol | If daemon scan ever changes to content-based discovery, the atomic-write protocol could expose half-rendered state. Verified against pinned SHA `c21fbfe`. |
docs/architecture/architecture-cohesion-review.md:93:| A6 | **Voice corpus chunks fit in pgvector memory at v1.0 scale.** HNSW index assumes per-tenant chunk count < 10K. | Phase 4 v0.2 supplement + voice-loader.sh queries | At 1 tenant × 5K chunks = ~30MB. 100 tenants × 5K = 3GB. Within Hetzner VPS RAM. Above 1000 tenants this becomes a real constraint. |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:125:- **autosend-safety-policy.md** §7 says `payload_preview` MUST exclude raw PII (max 500 chars, no names/phones/emails)
docs/architecture/architecture-cohesion-review.md:147:| G1 | **Concierge "voice corpus refresh" cadence is undefined.** When does a tenant re-index? Operator triggers? Scheduled cron? Re-index on N% recent_edit drift? | Medium (Concierge W10 dependency) | New ADR at Concierge build time OR addendum to v0.2 supplement at v1.0 schema close. Owner: Claude Code, trigger: Week-9. |
docs/architecture/architecture-cohesion-review.md:151:| G5 | **Multi-tenant connection pool sizing is unspecified.** v1.0 has 1 tenant × 6 agents = 6 PTYs. v1.1 with 5 tenants = 30 PTYs. Each PTY's psql connection: ephemeral or pooled? Postgres `max_connections` default 100. | Low (single-tenant pilot has headroom) | v1.1+ scale exercise. Add to lifecycle runbook §"Operate" + RISK-REGISTER if scale risk surfaces. |
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
docs/architecture/architecture-cohesion-review.md:228:| R2 | G8: Autosend v1.0 tier enforcement | High | Founder Decision D1 | Founder | Pre-Concierge W10 |
docs/architecture/architecture-cohesion-review.md:233:| R7 | G1: Voice corpus refresh cadence | Medium | New ADR-006 at Concierge build OR addendum to v0.2 supplement at v1.0 schema close | Claude Code | Week-9 (pre-Concierge) |
agents/_shared/README.md:12:| `autosend-policy.yaml` | Runtime tier table — 29 action_types per autosend-safety-policy §3 | 3 |
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:20:The renderer COPIES this entire directory into every per-tenant rendered org-agents dir on every `render-agent` invocation. It does **not** symlink. Mid-pilot edits to `hook-helpers.sh` therefore require re-rendering every agent that uses it. v1.0 acceptable (single-tenant pilot); v1.1 may add SHA-based skip-if-unchanged optimisation per renderer README §Known Limitations.
agents/_shared/README.md:29:The dual-mode design is intentional. It means **agent processes are not blocked by Postgres unavailability** — they continue writing audit data locally + degrade gracefully. This is the v1.0 mitigation for Risk #1 (cortextOS primitive 1 flaky-under-load): even if the daemon stalls, individual agents still produce auditable output.
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
agents/_shared/README.md:58:### 7 `autosend_*` helpers (autosend-safety-policy §4)
agents/_shared/README.md:70:## Auto-send tier dispatch (autosend-safety-policy §4)
agents/_shared/README.md:84:Per autosend-safety-policy §6 + plan §Phase 3 acceptance criterion #5: `autosend_await_approval` blocks for `timeout_seconds` (4h default from `autosend-policy.yaml` `defaults.approval_timeout`). PM2 + cortextOS primitive 1 keep the agent process alive during the block. Inter-agent bus-messaging to a 4h-blocked agent is fire-and-forget from the sender's perspective (cortextOS bus delivers asynchronously); blocked agent processes deferred messages when approval resolves.
agents/_shared/README.md:98:### `voice-loader.sh` helpers (3, master brief §8.1 Change 1)
agents/_shared/README.md:123:4. Founder runs the kill-criterion Trigger 5 query (autosend-safety-policy §7):
agents/_shared/README.md:130:5. Report result back. If row count > 3 in a 7-day window, kill-criterion Trigger 5 fires (per `v1.0-kill-criterion.md` §2 Trigger 5).
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
agents/_shared/README.md:177:- `docs/decisions/autosend-safety-policy.md` — full tier model + §4 reference impl
agents/_shared/README.md:178:- `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 5 — red-tier breach kill criterion
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:14:Autosend-safety-policy §3 declares 10 v1.0 action_types as **orange tier** — most importantly the canonical orange `bullhorn_note_customer_visible` (Concierge's primary outbound action). Orange-tier actions require per-action human approval via Telegram before executing.
docs/decisions/autosend-approval-bridge-spec.md:165:(Format inherited from `postApprovalToActivityChannel` — no IFOS customisation needed for v1.0; might want a more recruiter-specific template at v1.1.)
docs/decisions/autosend-approval-bridge-spec.md:243:| A5 | Bridge crash + restart: state rebuilds from filesystem scan + Postgres state table | Restart test: kill PM2 process mid-flight, restart, verify pending approvals resume |
docs/decisions/autosend-approval-bridge-spec.md:245:| A7 | category mapping table covers all 10 v1.0 orange action_types | Lint test: every orange action_type in autosend-policy.yaml has a mapping entry |
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
docs/decisions/autosend-approval-bridge-spec.md:272:- **Re-authorisation flow** — if an operator approves but then changes their mind, action is in-flight; v1.0 ships forward-only
docs/decisions/autosend-approval-bridge-spec.md:280:| 1 | cortextOS approval API signature changes upstream | Pinned SHA `c21fbfe` for v1.0; bridge tests catch any drift at submodule bump time |
docs/decisions/autosend-approval-bridge-spec.md:289:## §10 — Out of scope for v1.0 → v1.1 reservations
packages/utilities/web-scraper/README.md:51:v0.1 — Diagnostic v1.0 dependency per `agents/recruitment/diagnostic/tools.yaml`.
packages/diagnostic-generator/src/sections/recent-activity.ts:55:    "**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.",
agents/recruitment/cash-conductor/README.md:14:**Most-independent v1.0 agent.** Zero Bullhorn dependency. Operates against accounting system + Open Banking only. Per ADR-005 §5.1: pull-forward candidate if Bullhorn paths delayed past 2026-06-10.
agents/recruitment/cash-conductor/README.md:23:- `cycle.sh` — 14-step workflow (most complex of v1.0 agents)
agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
packages/diagnostic-generator/src/sections/stubs.ts:26:    "**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.",
packages/diagnostic-generator/src/sections/stubs.ts:40:    "**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/stubs.ts:57:    "**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/stubs.ts:67:    "**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/stubs.ts:79:    "**v0 limitation:** competitor inference requires scanning LinkedIn employee employment-history for other-recruitment-agency names — needs Proxycurl-style profile data.",
packages/diagnostic-generator/src/sections/stubs.ts:100:      "**v0 limitation:** identifying _hiring_ decision-makers (head of talent / chief people officer / hiring manager) requires LinkedIn employee search filtered by title. Wire Proxycurl (W4 polish).",
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:24:| 9 | `docs/decisions/brain-ui-scope.md` | Proposed (pending v1.1) | Verify v1.0/v1.1/v1.2 phasing aligns with §5.5 post-Edit 4 table |
docs/decisions/2026-05-18-codex-ratification-manifest.md:31:| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
docs/decisions/2026-05-18-codex-ratification-manifest.md:32:| 17 | `docs/decisions/v1.0-kill-criterion.md` + Day-5 close commit `c6734d1` | Proposed + audit log | Verify 10 binary triggers; verify §3 founder-solo authority structure; verify live SQL migration (decision_log.phase 5→6) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:66:| 6 | `docs/decisions/autosend-safety-policy.md` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:71:| 11 | `docs/decisions/v1.0-kill-criterion.md` | RATIFIED | Incorporated remediation verified clean. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:95:| 2 | `docs/decisions/autosend-safety-policy.md` | FOUNDER-ESCALATED | Founder-escalated pending D1 / D2 / D3; annotations added only. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:185:| 16 | autosend-safety-policy.md | REJECTED (3 issues) | Issues 1+2 (tier contradiction) → **Founder Decision D1** in `2026-05-20-codex-round-1-founder-decisions.md`. Issue 3 (legal placeholder) → **Founder Decision D2 + D3** in same briefing. No inline incorporation; founder picks. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:186:| 17 | v1.0-kill-criterion.md | REJECTED (3 issues) | All three (Trigger 1 date / Trigger 2 CLI / Trigger 4 threshold) **incorporated** at `2b287d3`. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:267:| 4 | §5.5 v1.0 minimum row + v1.0+/v1.1 row merge | ADR-002 Edit 2 line 91 | ✓ verbatim (with side effect documented) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:290:| 16 | `autosend-safety-policy.md` §10 pilot-agreement liability | Placeholder — legal review required before first pilot LOI | Pre-LOI legal review (commercial / regulatory). Codex can ratify the placeholder shape but cannot substitute for legal counsel. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:291:| 17 | `v1.0-kill-criterion.md` §3.4 external advisor | TBD — Week 1-2 must-fill | Founder identifies + engages external advisor before first pilot LOI signs. Codex flags the TBD but cannot resolve. |
docs/decisions/sequencing-target.md:1:# v1.0 agent sequencing target — decision document
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:25:| A5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | "First daytime always-on agent" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:59:| 6 | **Tenant-onboarding readiness** | Can this agent be deployed to one tenant without all infrastructure being live? (E.g. does it need the wiki API in v1.0 weeks 11-13, or only the Week-1-2 substrate?) | Earlier-readiness agents can pilot in shadow mode against the first design partner before all v1.0 infra is complete |
docs/decisions/sequencing-target.md:63:### 1.4 — Scope cuts and v1.0 minimum
docs/decisions/sequencing-target.md:65:Per master brief §12 / Ultraplan §10 row #2 (the four-risks-that-kill-v1.0 table), the **documented v1.0 scope-cut contingency** is verbatim:
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:96:| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
docs/decisions/sequencing-target.md:113:| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:137:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #1** (cortextOS primitives 1, 4, 5 — the three flagged "shipped but flaky" per cortextos-primitive-status.md). Critical gate for the v1.0 always-on agents that follow (Concierge) — if Cash Conductor surfaces primitive flakiness, the v1.0 scope-cut contingency (Ultraplan §10 row #1: degraded-mode fallback) activates before Concierge invests 4 weeks |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:139:| 5. Dependencies | **Upstream:** none on other agents (Xero/QuickBooks/Sage + Open Banking infra independent of Bullhorn path). **Downstream:** none in v1.0 (Cash Conductor's outputs are tenant-internal chase emails + DSO reports, not consumed by other v1.0 agents) | Low cross-agent coupling |
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:146:### 2.5 — A5 Sourcing Scout (daytime)
docs/decisions/sequencing-target.md:150:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 554 estimate **L (2 weeks)** — multi-source aggregation logic is the work. Four data sources (Bullhorn read + LinkedIn via Proxycurl + Reed.co.uk + CV-Library). Bounded output (5-15 candidates per query per Ultraplan §8.1 line 552). Tier 2 request-response |
docs/decisions/sequencing-target.md:151:| 2. Substrate exercise | **Medium** | Reuses Bullhorn R from Janitor (no new Bullhorn substrate). New MCP integrations: LinkedIn via Proxycurl (rate-limited per Ultraplan §10 row #6), Reed, CV-Library. Source-abstraction layer per Ultraplan §8.1 line 555 designed to be reusable by Night Sourcer v1.1 |
docs/decisions/sequencing-target.md:152:| 3. Risk de-risking | **Medium** | **First exercise of LinkedIn rate-limit budget** per Ultraplan §10 Risk #6 ("LinkedIn rate limits via Proxycurl are tighter than expected"). Reuses Bullhorn auth from Janitor (doesn't re-derisk Risk #2). Tier 2 so doesn't touch Risk #1 primitives |
docs/decisions/sequencing-target.md:154:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Night Sourcer (v1.1) reuses Sourcing Scout's multi-source layer per Ultraplan §8.1 line 555 ("Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it") | Medium criticality (v1.1 downstream) |
docs/decisions/sequencing-target.md:155:| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn (already on if Janitor shipped) + LinkedIn (Proxycurl API key — single application-level key, not per-tenant) + Reed OAuth + CV-Library OAuth per tenant |
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:163:| 1. Implementation simplicity | **High complexity (Low simplicity)** | Ultraplan §8.1 line 568 estimate **XL (4 weeks)** — biggest v1.0 agent. Lifecycle state machine across 24+ months of candidate post-placement (week-1 / month-1 / month-3 / month-6 / month-12 / month-24 nurture per Product Spec §2.2 R7). Six-plus comms types (acknowledgement, prep, debrief, rejection, placement, multi-stage check-ins) |
docs/decisions/sequencing-target.md:166:| 4. Commercial value | **Highest** | Per master brief §8.2 line 606: "First Tier-1 always-on closing demo; 4-week build." Product Spec §2.2 R7: 15-25% lift in placement-driven referral revenue ("post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table"). The flagship v1.0 closing demo |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:176:Three orderings evaluated against §1.3 criteria. **Option Alpha is the master-brief §8.2 canonical sequence** (correcting the §1.5 founder-prompt drift); Options Beta and Gamma are tested as alternatives.
docs/decisions/sequencing-target.md:178:### 3.1 — Option Alpha (canonical, master-brief §8.2)
docs/decisions/sequencing-target.md:185:W9:   Sourcing Scout (A5)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:209:W9:   Janitor (A2)
docs/decisions/sequencing-target.md:211:W11:  Sourcing Scout (A5)
docs/decisions/sequencing-target.md:220:2. **Risk #1 derisk pushed to W12-13.** Cash Conductor's Tier-1 Primitives 1+4+5 first-exercise happens after Concierge's 4-week XL build. If Risk #1 materialises at W12-13, the entire v1.0 production-critical surface is at risk with no Hire-#1-takeover slot for Cash Conductor.
docs/decisions/sequencing-target.md:233:W12:  Sourcing Scout (A5)
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:256:| 5. Dependencies on other agents | **Wins** — Janitor's Bullhorn auth → Scribe reuses → Sourcing Scout reuses → Concierge reuses, all in dependency order | Loses — Concierge before Janitor + Scribe breaks the upstream chain | Loses — Concierge before Scribe breaks the upstream chain |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:285:| 5 | W9 | **Sourcing Scout** (A5) | Multi-source aggregation; first LinkedIn rate-limit exercise (Risk #6) |
docs/decisions/sequencing-target.md:288:**Status: Accepted** as the v1.0 plan of record. Binds Week 3-13 build cadence subject to §4.3 revisit conditions.
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:310:- **Activation:** v1.0 scope cut from 6 to 4 agents per Ultraplan §10 row #4 — drop Concierge + Sourcing Scout to v1.1; founder solo through end of v1.0.
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:319:- **Cascade:** Sourcing Scout W10 (shifted right from W9), Concierge W11-14 (shifted right from W10-13).
docs/decisions/sequencing-target.md:333:- v1.1 Triage agent's relationship to v1.0 Concierge's auto-send categories — deferred to v1.1 planning.
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:374:4. **If scope-cut activates twice in one v1.0 cycle, escalate to v1.0 kill criterion** — the Day 5 work (master brief §6 Day 5) defines the kill-criterion threshold; sequencing failures count toward that threshold.
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:418:- W13 Concierge final-render-clean → **Low** (all 5 v1.0 bundles render and pass validation per RISK-REGISTER #5 final reduction trigger).
docs/decisions/sequencing-target.md:436:The Day 5 v1.0 kill criterion document must reference this sequencing for what "v1.0 fails" means. Concrete failure conditions implied by §4.3 + §5.3:
docs/decisions/sequencing-target.md:440:- **Scope-cut contingency activates twice in one v1.0 cycle** (per §5.3 step 4; signals structural product-market-fit problem)
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:470:4. ADR-002 Edit 2 §5.5: v1.0 brain build wording
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:518:| §6.6 v1.0 kill criterion specifics | Formalised on Day 5 — this document's failure conditions are inputs to that work |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
packages/diagnostic-generator/src/sections/icp-fit.ts:77:    "**v0 limitation:** geography + deal_size_band scoring requires LinkedIn job-post data. Wire Proxycurl (W4 polish).",
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:195:## Build wave: v1.0 weeks 10-13
docs/architecture/agent-bundle-renderer-design.md:204:build_wave: v1.0
docs/architecture/agent-bundle-renderer-design.md:219:  - ESC_VOICE_DRIFT
docs/architecture/agent-bundle-renderer-design.md:270:        "ESC_VOICE_DRIFT": { "type": "string", "format": "telegram-chat-id" }
docs/architecture/agent-bundle-renderer-design.md:369:Decision-log calls are mandatory per master brief §8.1 Change 2:
docs/architecture/agent-bundle-renderer-design.md:379:- CTX_ORCHESTRATOR_AGENT=(none in v1.0)
docs/architecture/agent-bundle-renderer-design.md:423:    "ESC_VOICE_DRIFT": "<acme operator chat id from _secrets.env>"
docs/architecture/agent-bundle-renderer-design.md:481:**Decision for v1.0: manual developer invocation.** Command shape per §3.3.
docs/architecture/agent-bundle-renderer-design.md:587:- **No master log path.** v1.0 keeps everything in the org's `_meta/` directory; eliminates a per-machine logfile that would need its own rotation and permissions story. v1.2+ may add a global log if multi-org operational visibility becomes a need.
docs/architecture/agent-bundle-renderer-design.md:597:- **Merge with conflict markers:** rejected for v1.0. Renderer doesn't have a three-way-merge semantic (source bundle, last-render, current rendered output). Building it adds substantial complexity for a workflow nobody asked for; the master brief §1 Rule 1 ("output before architecture") favours the simple overwrite model.
docs/architecture/agent-bundle-renderer-design.md:613:**Decision for v1.0: per-tenant per-agent invocation only.**
docs/architecture/agent-bundle-renderer-design.md:617:v1.1+ ergonomic additions (out of v1.0 scope but planned; will be ratified via ADR-005):
docs/architecture/agent-bundle-renderer-design.md:622:The v1.0 minimum keeps the renderer's CLI surface small (one mode, two required args) and defers cross-tenant orchestration to bash. The Postgres `tenants` table dependency (v1.0 Day 4 per master brief §6) is what unblocks `--all-tenants`; until then there's no programmatic source of truth for "the list of active tenants."
docs/architecture/agent-bundle-renderer-design.md:709:- **Telegram:** if `--notify-on-failure` is set (default true for v1.0), single message to the founder's operator chat with structured fields: tenant, agent, exit code, reason, stderr first line.
docs/architecture/agent-bundle-renderer-design.md:750:### 5.2 — Renderer in the v1.0 build sequence
docs/architecture/agent-bundle-renderer-design.md:765:| 5 v1.0 agent bundles authored at `agents/recruitment/<name>/` | founder + Claude Code | Weeks 3-10 (in parallel with other work) |
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/agent-bundle-renderer-design.md:838:- Invocation mode: manual developer invocation (v1.0); auto-render and `--all-tenants` are v1.1+ additions.
docs/architecture/agent-bundle-renderer-design.md:841:- Multi-tenant loop: per-tenant per-agent for v1.0.
agents/recruitment/cash-conductor/agent.md:6:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:9:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
agents/recruitment/cash-conductor/agent.md:23:### Webhook (v1.0 primary path)
agents/recruitment/cash-conductor/agent.md:54:- **Webhook (v1.0 primary path):** per-provider HMAC / bearer token verified at the ingress per `tools.yaml` capability declarations (matching the Scribe webhook auth pattern).
agents/recruitment/cash-conductor/agent.md:56:- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
agents/recruitment/cash-conductor/agent.md:59:### Manual triggers (v1.0)
agents/recruitment/cash-conductor/agent.md:149:14 steps. Per ADR-003 §3 agent-bundle pattern + the review-agent-bundle Codex ratification skill §4 ("every output/action step MUST call hh_decision_*"): every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Master brief §8.1 Change 2 mandates the three-call minimum per agent run (`trigger`, `output`, `action`); the per-step mandatory-write discipline is the agent-bundle contract extension.
agents/recruitment/cash-conductor/agent.md:202:   → spot-check sampling per autosend-safety-policy.yaml yellow tier
agents/recruitment/cash-conductor/agent.md:221:   → ESC_VOICE_DRIFT if classifier <threshold after 3 retries
agents/recruitment/cash-conductor/agent.md:232:       `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint failure)
agents/recruitment/cash-conductor/agent.md:296:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
agents/recruitment/cash-conductor/agent.md:306:Gate A failures fire either `ESC_AGENT_OUTPUT_SHAPE` (invoice/amount/paid-precondition miss; output-shape constraint) OR `ESC_ADDRESSEE_MISMATCH` (client_contact_email mismatch; blocking per catalogue §2.10 — explicit Cash Conductor invoice/chase addressee case). Draft stays in `/tmp` (auto-purged 24h); operator notified per the specific ESC route.
agents/recruitment/cash-conductor/agent.md:318:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:335:| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:337:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss on invoice_number / amount_due / paid-invoice-precondition (NOT addressee mismatch — that uses ESC_ADDRESSEE_MISMATCH) | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:339:| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
agents/recruitment/cash-conductor/agent.md:346:- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
agents/recruitment/cash-conductor/agent.md:348:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Cash Conductor fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/cash-conductor/agent.md:361:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
agents/recruitment/cash-conductor/agent.md:363:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/cash-conductor/agent.md:381:| Sage MCP connector | W7 build start (~2 days; may defer if no pilot uses Sage v1.0) | ⏸ |
agents/recruitment/cash-conductor/agent.md:389:| `cycle.sh` orchestration (14-step) | Build at W7 start (~3 days; most complex of v1.0 agents) | ⏸ |
agents/recruitment/cash-conductor/agent.md:395:| Fallback: if D1 + bridge not ready by W7-8, Cash Conductor v1.0 downgrades to drafts-only (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` writes until D1 resolves + bridge ships) | v1.0 contingency | n/a |
agents/recruitment/cash-conductor/agent.md:410:| Q2 | Open Banking provider — TrueLayer or Plaid UK? Both have UK coverage; TrueLayer slightly cheaper at low volume; Plaid has broader US-EU coverage for v1.1+ expansion. | Founder commercial. Recommend TrueLayer for v1.0 UK-only pilots. |
agents/recruitment/cash-conductor/agent.md:413:| Q5 | Reconciliation Stage 3-4 (fuzzy / ambiguous matches) — consultant review queue UX. Brain UI workflow? Telegram? | v1.0: weekly report exception list. v1.1: Brain UI per-row review queue. |
agents/recruitment/cash-conductor/agent.md:416:| Q8 | Sage connector — defer if no v1.0 pilot uses Sage? Saves ~2 days. Risk: blocks future Sage-using pilots. | Recommend defer to v1.1; document in W7 build start review. |
agents/recruitment/cash-conductor/agent.md:422:3. **5 stages of match algorithm** is intentionally conservative for v1.0 to avoid false-positive reconciliation writes (which corrupt the tenant's accounting books).
agents/recruitment/cash-conductor/agent.md:423:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
agents/recruitment/cash-conductor/agent.md:440:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
packages/agent-renderer/src/synthesis/claudeMd.ts:23:    "{{orchestrator_agent_or_none}}": "(none in v1.0)",
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:27:Master brief §12 Risk #2 (Bullhorn auth path) — "Bullhorn MCP build takes longer than 1 week" — names this as one of the four risks that could kill v1.0. Tripwire: "End of week 3 status not 'core read endpoints working'" (master brief §12 row #2, Ultraplan §10 row #2). The mitigation is "Week 0 Day 2 on Bullhorn auth research" — i.e. this document. Without Sub-decisions A and B answered, Week 1 cannot begin scaffolding `packages/mcp-connectors/bullhorn/` because the connector's authentication path determines its scope and shape.
docs/decisions/bullhorn-integration-path.md:29:**Bullhorn dependency count for v1.0 agents:**
docs/decisions/bullhorn-integration-path.md:31:| Agent | Bullhorn dependency in v1.0 | Source |
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:37:| A5 Sourcing Scout | **Yes — read** (ATS passive-match lookup) | Ultraplan §8.1 A5 line 547-551 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:61:- Whether the marketplace-tier cost structure works at IFOS's volume (3-6 tenants v1.0; 100 by end of 2027 per Product Spec §5.4 line 369-373). Partner fees may be flat or per-tenant; this matters at scale.
docs/decisions/bullhorn-integration-path.md:69:| A | "What are the API rate-limit / scope deltas between marketplace tier and direct API at our expected 3-6 tenant pilot volume?" | Same Bullhorn partnerships team, or escalation to developer support | Same conversation | The answer determines whether direct-API can serve v1.0 or marketplace registration is a v1.0 blocker |
docs/decisions/bullhorn-integration-path.md:70:| A + C | "Which ATS does design partner #1 use — Bullhorn, Vincere, Voyager Infinity, or another?" | **Founder** — Sunday design-partner conversation 2 per master brief §6 Day 2 line 467 | Sunday/Monday | If Bullhorn: Sub-decision A path proceeds as analysed. If non-Bullhorn: the v1.0 ATS anchor changes, this document's Sub-decisions are scoped to "Bullhorn is the second-tenant ATS" rather than "v1.0 first-tenant ATS" |
docs/decisions/bullhorn-integration-path.md:83:  - Recommendation block (§5) names the technical preference, the commercial-answer conditions that flip Status to Accepted, and the documented v1.0-scope-cut contingency if commercial answers go badly.
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:143:- `https://bullhorn.github.io/docs` — Bullhorn's developer documentation landing. Names three API surfaces: REST API, OAuth, SOAP (legacy). The REST and OAuth links are the operative ones for v1.0.
docs/decisions/bullhorn-integration-path.md:179:**Recommendation: scaffold the Bullhorn MCP connector against direct API / Developer Program for v1.0 weeks 1-2; treat marketplace registration as a v1.1+ commercial track that the connector's auth module is designed to swap into without endpoint-surface changes.**
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:185:3. **Marketplace is a commercial decision, not a technical one, at v1.0 scale.** At 3-6 pilot tenants, the marketplace's primary benefit (co-marketing, listing visibility, possibly elevated rate limits) is dominated by the per-tenant pilot economics. The marketplace partnership is appropriate when IFOS has shippable product and 10+ tenants — i.e. v1.1+ commercial timing.
docs/decisions/bullhorn-integration-path.md:191:| Marketplace tier is **required** for production tenant onboarding (partnerships@bullhorn answer) | Connector scaffolds against direct-API on a Bullhorn-sandbox tenant for IFOS internal dev; marketplace registration becomes Week-1 critical-path commercial work; v1.0 build slips by the marketplace certification timeline (potentially 4-12 weeks per §2.3 row 1 inference). This is a v1.0 blocker scenario and feeds master brief §12 Risk #2 directly. |
docs/decisions/bullhorn-integration-path.md:192:| Marketplace adds material per-tenant cost above ~$1K/yr at 3-tenant scale (partnerships@bullhorn answer) AND direct-API scope is sufficient | Direct preferred for v1.0; marketplace deferred to v1.1+ when revenue funds the programme cost. Current recommendation stands. |
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:196:**Status: Proposed.** Status flips to Accepted on either: (a) partnerships@bullhorn confirms marketplace is not required for v1.0 production tenant access AND first design partner uses Bullhorn; OR (b) founder explicitly accepts the documented fallback if marketplace turns out required, and re-cuts the v1.0 timeline to absorb the marketplace certification window.
docs/decisions/bullhorn-integration-path.md:248:Pragmatic v1.0 hybrid given §3.1 and §3.2 findings:
docs/decisions/bullhorn-integration-path.md:275:## Section 4 — Sub-decision C: v1.0 endpoint surface
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:294:**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.
docs/decisions/bullhorn-integration-path.md:300:**Implication:** Bullhorn's public-tier REST API is **pull-only**. IFOS must poll for change detection at v1.0 unless commercial verification reveals a partner-tier event-subscription mechanism. **Commercially gated: §4.2-A** — confirm with Bullhorn developer support whether webhook/event-subscription capabilities exist at marketplace/partner tier that are not documented in the public REST docs.
docs/decisions/bullhorn-integration-path.md:302:**v1.0 default per integration point:**
docs/decisions/bullhorn-integration-path.md:304:| Integration point | v1.0 mechanism | Cadence | Notes |
docs/decisions/bullhorn-integration-path.md:309:| Sourcing Scout passive-match read | Polling (on-demand search) | Per-consultant-request | No subscription needed — read-on-demand model |
docs/decisions/bullhorn-integration-path.md:310:| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
docs/decisions/bullhorn-integration-path.md:330:**Conservative v1.0 budget allocation per tenant per hour** (anchored to typical enterprise REST API patterns of 100-500 req/min ceilings; revise once Bullhorn confirms):
docs/decisions/bullhorn-integration-path.md:336:| Sourcing Scout (read-on-demand) | 50-200 during consultant-active windows | Search-heavy; multiple paginated reads per consultant request |
docs/decisions/bullhorn-integration-path.md:346:**Emerged from §3.1 finding:** Bullhorn's 10-minute access token TTL is short enough that v1.0 needs an explicit refresh-loop pattern. Lazy refresh on 401 alone is insufficient for two reasons: (a) it would cause every 10-minute window's first call to take a refresh round-trip's worth of latency, breaking sub-second SLAs on Concierge real-time paths; (b) 401 detection on burst writes (Scribe's per-call sequence of 5-15 REST writes) means burst-mid-flight refresh failures lose write ordering.
docs/decisions/bullhorn-integration-path.md:359:This is a real architectural decision worth its own §4 sub-section because the 10-min TTL forced the refresh-loop into the v1.0 design — it's not just an implementation detail.
docs/decisions/bullhorn-integration-path.md:369:Recommendation: scaffold the Bullhorn MCP connector against direct API / Developer Program for v1.0 weeks 1-2; treat marketplace registration as a v1.1+ commercial track that the connector's auth module is designed to swap into without endpoint-surface changes (per §2.4 + §1.4 fallback architecture).
docs/decisions/bullhorn-integration-path.md:392:**Sub-decision C — v1.0 endpoint surface. Status: Accepted.**
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:423:Bullhorn entity field mapping (Candidate, JobOrder, Placement, Note, ClientCorporation) → IFOS wiki schema per `second-brain-design.md` §2.2 entity types. Out of scope for this Day-2 decision; flagged for Week 11-13 work. Concrete handoff: §4.1's per-agent read-entity list is the v1.0 minimum set the wiki ingest paths must handle.
docs/decisions/bullhorn-integration-path.md:486:| Rate-limit budget allocation | §4.4 | Conservative v1.0 defaults (400-1000 req/hour/tenant total; 30% reserve); revise when Bullhorn confirms actuals |
docs/decisions/bullhorn-integration-path.md:511:| §4.2-A: assume v1.0 pull-only (no webhook coverage) per public REST docs | Sub-decision A commercial verification reveals marketplace-tier event subscriptions — Concierge upgrades to webhook-primary in v1.1+ |
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |
agents/recruitment/scribe/agent.md:6:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:22:### Webhook (v1.0 primary path)
agents/recruitment/scribe/agent.md:41:### Manual trigger (v1.0 — debugging / replay)
agents/recruitment/scribe/agent.md:109:Length cap: 800 words. Voice-classified (≥0.75); falls back to "needs consultant review" placeholder if classifier persistently fails (ESC_VOICE_DRIFT).
agents/recruitment/scribe/agent.md:127:10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/scribe/agent.md:157:   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
agents/recruitment/scribe/agent.md:175:   → ESC_VOICE_DRIFT if score <0.75 after 3 retries
agents/recruitment/scribe/agent.md:214:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:224:Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/scribe/agent.md:238:Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).
agents/recruitment/scribe/agent.md:251:| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:255:| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:277:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:279:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/scribe/agent.md:319:| Q1 | Fathom vs Fireflies — first-mover provider for v1.0? Both have UK presence; Fathom has tighter Bullhorn ecosystem ties; Fireflies has broader transcript model coverage. | Commercial decision; depends on first pilot tenant's existing tooling. |
agents/recruitment/scribe/agent.md:323:| Q5 | Bullhorn write atomicity — Step 9 rollback of Step 8 on note-attach failure is best-effort PATCH. Could leave entity in mid-state. | v1.0 accept; document risk. v1.1+: investigate Bullhorn transaction API if exposed. |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:20:**Counter:** Codex is applying the Day-7 single-sentence-test Q3 quality gate ("ATS decided + auth cleared") as if it were a Week-1 implementation gate. The Q3 gate is correct as a closing-of-Week-0 gate per master brief §6 line 502, and Q3 = NO is exactly why Week 0 EXTENDS per the Day-7 single-sentence-test result. But the Q3 gate governs **named v1.0 agent-build slices** (Diagnostic W3-4, Janitor W5, etc.), NOT Week-1 prerequisite code.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:68:build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
agents/recruitment/sourcing-scout/README.md:1:# Sourcing Scout — directory README
agents/recruitment/sourcing-scout/README.md:3:**Status:** Proposed (Day-19 pre-W9-build scaffold).
agents/recruitment/sourcing-scout/README.md:14:Full bundle at W9 build (~2 weeks per ULTRAPLAN A5 line 554):
agents/recruitment/sourcing-scout/README.md:16:- `tools.yaml` — Bullhorn R + Proxycurl + Reed + CV-Library + source-abstraction layer
agents/recruitment/sourcing-scout/README.md:27:Per ULTRAPLAN A5 line 555 gotcha: source-abstraction layer designed for Night Sourcer reuse. Defer ADR-006 to W9 build start documenting the layer's interface.
agents/recruitment/sourcing-scout/README.md:33:*End of Sourcing Scout README.*
docs/architecture/cortexos-primitive-status.md:20:| # | Primitive | Status | v1.0 dependency |
docs/architecture/cortexos-primitive-status.md:24:| 3 | Inter-agent file bus | **shipped and tested** (with two master-brief drifts) | None in v1.0; load-bearing for v1.1 Brief Decoder |
docs/architecture/cortexos-primitive-status.md:27:| 6 | Overnight autoresearch (theta wave) | **shipped and tested** | None in v1.0; v1.1 Night Sourcer |
docs/architecture/cortexos-primitive-status.md:28:| 7 | Multi-agent orchestrator | **shipped and tested** | None in v1.0; v1.1 Brief Decoder |
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/architecture/cortexos-primitive-status.md:66:**Risk if flaky:** Tier-1 always-on agents collapse to scheduled cron with cold-start latency, eliminating the "sub-second to first useful action" claim that justifies pricing the Triage/Concierge/Pulse demos above point-tool parity (Ultraplan §3.2). Per Ultraplan §3.1 row 1, the documented contingency is: "Ship the v1.0 agents as scheduled cron with a documented migration path. Loses the Triage closing demo but keeps the build moving." Quirk 2 (`.agents/learnings/00-cortextos-quirks.md`) — `node-pty` requires `npm rebuild` on Node 25+ — is the most likely re-trip wire because the Mac Studio cluster nodes for the v2.0 Sovereign tier may not run Node 22 LTS by default.
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:124:**Risk if flaky:** Concierge loses cross-week candidate conversation context at the 71-hour boundary or at API overflow; rejection drafts lose the prior-state nuance that defines Gate A voice quality on the hardest test case (Ultraplan §8.1 A6 gotcha: "Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship"). Per Ultraplan §3.1 row 2, the documented contingency is: "Manual restart cadence acceptable for v1.0 pilots; flag as known limitation in pilot agreement."
docs/architecture/cortexos-primitive-status.md:182:1. **No `chokidar` watcher in the bus.** The bus is poll-based, not push-based. `grep -rn chokidar src/` returns zero hits; `chokidar@^5.0.0` in `package.json:47` is used only by `dashboard/src/lib/watcher.ts:5` for the dashboard UI's file change feed, not for inter-agent message delivery. Master brief §2.4 row 3's "chokidar watcher in daemon" is incorrect against the verified SHA. The actual dispatcher is `FastChecker` polling at `pollInterval` (default 1000ms, configurable). Operational impact: message-delivery latency is bounded by the poll interval, not zero-latency event-driven; relevant for the Brief Decoder → Sourcing Scout → Concierge "four-agent pipelines complete in seconds" claim (Ultraplan §3.2). With 1s polling per hop and 3 hops, end-to-end is ≥3s, not sub-second.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:256:- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:259:**Risk if flaky:** Every Tier-1 auto-send agent collapses to drafts-only — the documented v1.0 Risk-#1 contingency (Ultraplan §3.5: "Every Tier 1 agent has a 'degraded mode' fallback (drafts-only, no auto-send, scheduled retry) that runs if cortextOS state is unhealthy"). Loses the Triage and Cash Conductor closing demos but does NOT kill v1.0.
docs/architecture/cortexos-primitive-status.md:296:Telegram is mature, hardened, and well-tested. iOS is explicitly "coming soon" in the README and has no APNs/push-notification code path — only an `outbound-messages.jsonl` log shape that a future iOS app would consume. Ultraplan §3.1 row 5 already accepts iOS deferral to v1.2, so this is not a v1.0 blocker.
docs/architecture/cortexos-primitive-status.md:328:**Risk if flaky:** Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5 ("iOS in v1.2 is the marketing line, not a tech blocker"). Real risk is Telegram outage during a Cash Conductor escalation, which is exactly what the activity-channel + per-agent-bot belt-and-braces pattern (primitive 4 evidence, `approval.ts:222-226`) was built to mitigate after the "50h+ Repo-B-style stall" incident.
docs/architecture/cortexos-primitive-status.md:370:Full experiment lifecycle code, dedicated sprint-3 test file, fully-documented 8-phase theta-wave skill shipped in the `analyst` template. Approval-gate integration ties it back into primitive 4. Not on the v1.0 critical path — Ultraplan §3.1 row 6 already defers it to v1.1 Night Sourcer.
docs/architecture/cortexos-primitive-status.md:389:- v1.0: **No agent depends on this.** Ultraplan §3.1 row 6: "This is for the Night Sourcer in v1.1, not v1.0. Defer the question."
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:434:The orchestrator template ships in full (17 files), the daemon's `AgentManager` recognizes a per-org designated orchestrator and gives it special privileges (activity-channel callback poller, only-orchestrator-polls-Telegram opt-out via `telegram_polling: false`), and the file-bus handoff substrate is the same primitive-3 message bus already verified. Documented production trade-off but no Day-0 brittleness; not on the v1.0 critical path.
docs/architecture/cortexos-primitive-status.md:456:- v1.0: **No agent depends on this.** Ultraplan §3.1 row 7: "This is for v1.1+. Defer."
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
packages/agents-runtime/_shared/common-accounting.json:5:  "description": "Accounting-system stub used by Cash Conductor (W7-8 v1.0). Xero-only in v1.0 per master brief §8.2 row 4; extensible later. Per PRODUCT-SPEC §5.3 line 362.",
packages/agents-runtime/_shared/common-accounting.json:30:      "description": "Default Cash Conductor cadence; tenant-overridable per autosend-safety-policy §6 tenant-override discipline."
packages/agents-runtime/_shared/common-accounting.json:42:      "description": "v1.0 closes loop via Open Banking reconciliation per Ultraplan §8.1 A4; truelayer placeholder."
docs/runbooks/day-4-provisioning.md:44:**Recommendation:** Falkenstein (FSN1) for v1.0 pilot scale, with rationale:
docs/runbooks/day-4-provisioning.md:70:- Master brief §8.1 Change 2: three values — `trigger`, `output`, `action`
docs/runbooks/day-4-provisioning.md:77:### §0.4 — LUKS strategy: Option β (encrypted volume) for v1.0
docs/runbooks/day-4-provisioning.md:84:**Recommendation: Option β for v1.0.** Rationale:
docs/runbooks/day-4-provisioning.md:92:**Manual-unlock-on-boot trade-off (explicit):** every VPS reboot requires manual `cryptsetup luksOpen` because there is no TPM-bound key store on Hetzner CX-class VPS. v1.0 reboots are rare (security patches, kernel updates) and the founder is on-call during them. v1.2+ improvement: investigate TPM-bound or key-server-based automatic unlock.
docs/runbooks/day-4-provisioning.md:94:### §0.5 — Sudo policy: passwordless for v1.0
docs/runbooks/day-4-provisioning.md:129:- [ ] §0.5 decision confirmed: passwordless sudo acceptable for v1.0
docs/runbooks/day-4-provisioning.md:171:| Instance type | CX22 (2 vCPU, 4 GB RAM, 40 GB NVMe) | Fits v1.0 pilot scale per founder-set budget in this section §1.4; master brief does not specify a numeric cost target |
docs/runbooks/day-4-provisioning.md:175:| Networking | Public IPv4 + IPv6 | UFW restricts to 22/80/443; private network not required for v1.0 single-server |
docs/runbooks/day-4-provisioning.md:178:Estimated monthly cost: ~€5/mo VPS + ~€2.40/mo (50 GB volume at €0.0476/GB/mo) ≈ €7.40/mo ≈ £6.40/mo. Well under the £20/mo founder-set budget for v1.0 pilot scale (this section §1.4; master brief does not specify a numeric cost target).
docs/runbooks/day-4-provisioning.md:184:Execute these steps via the Hetzner Cloud web Console (`console.hetzner.cloud`). The Hetzner CLI is an alternative for v1.1+ automation but the manual Console flow is the recommended path for v1.0 single-server.
docs/runbooks/day-4-provisioning.md:210:10. Backups: enable (€1.20/mo, weekly snapshots — acceptable insurance for v1.0)
docs/runbooks/day-4-provisioning.md:648:# RLS (per §7), not separate roles, in v1.0.
docs/runbooks/day-4-provisioning.md:768:-- tenant_eval_sets (per master brief §6 Day 4 line 478; v1.0 placeholder)
docs/runbooks/day-4-provisioning.md:806:Per `sequencing-target.md` §5-A + master brief §8.1 Change 2 + `current-priorities.md` line 16. **Exactly 5 values. No additions.**
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1086:Retention policy: 14 daily backups on local volume. **The data volume IS the backups volume here** — for v1.0 single-server this is acceptable but flagged as a v1.1 improvement (off-host backup to S3-compatible object storage).
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/runbooks/day-4-provisioning.md:1214:4. **§2.5 SSH host-key handling:** Added `-o StrictHostKeyChecking=accept-new` to all SSH commands for non-interactive execution. v1.0 pilot threat model accepts trust-on-first-use against fresh Hetzner provisioning. v1.2+ improvement: compare host fingerprint against Hetzner Console rescue output.
docs/runbooks/day-4-provisioning.md:1289:- Not the brain-UI scaffold (v1.0 ships read-only `/brain` per `brain-ui-scope.md`)
docs/decisions/autosend-safety-policy.md:6:**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
docs/decisions/autosend-safety-policy.md:7:**Surfaced by:** Master brief Day 5 spec; load-bearing for every `hh_decision_action` call across the v1.0 agent fleet.
docs/decisions/autosend-safety-policy.md:8:**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
docs/decisions/autosend-safety-policy.md:39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
docs/decisions/autosend-safety-policy.md:73:## §3 — Examples per tier across the v1.0 agent surface
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:84:| Sourcing Scout | `linkedin_profile_cache` | Stores profile snapshot to `/vault/<tenant>/wiki/raw/`; no external send; no rate-limit cost |
docs/decisions/autosend-safety-policy.md:94:| Sourcing Scout | `linkedin_connection_request` | 1-in-5 | Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy |
docs/decisions/autosend-safety-policy.md:110:| Sourcing Scout | `linkedin_inmail_send` | Outbound InMail (paid credit); cost-per-send; customer-facing |
docs/decisions/autosend-safety-policy.md:117:| `xero_payment_initiate` | `payment_action` | Payment transfer; financial-bearing; never auto-send in v1.0 |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:143:#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:314:Block reason: payment_action (red-tier; never auto-sent in v1.0)
docs/decisions/autosend-safety-policy.md:344:**Expected resolution:** IFOS oncall investigates within 1h during business hours; within 4h outside business hours. The affected tenant pilot may be PAUSED for that agent until policy is fixed (per `v1.0-kill-criterion.md` §2 trigger 5).
docs/decisions/autosend-safety-policy.md:404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
docs/decisions/autosend-safety-policy.md:418:`decision_log` rows are retained **indefinitely** for v1.0. v1.1+ may introduce retention policies (e.g., delete rows older than 7 years per UK statutory retention norms).
docs/decisions/autosend-safety-policy.md:474:## §9 — v1.0 vs v1.1+ phasing
docs/decisions/autosend-safety-policy.md:476:### v1.0 ships with green + red only
docs/decisions/autosend-safety-policy.md:480:- **Green and red** give the binary "allowed" vs "blocked" classification needed for a low-risk v1.0 launch. Every action is either fully auto-sent or fully blocked. No "needs approval" or "sampled" intermediate states.
docs/decisions/autosend-safety-policy.md:481:- **Yellow** (sampled review) requires building the spot-check queue infrastructure (spot_check_queue table, Brain UI review interface, sampling-disagreement-feedback loop). Defers without operational risk: high-volume agent work can run as green at v1.0 without sampled review, with tier elevation to orange-in-v1.1 as a fallback if quality issues surface.
docs/decisions/autosend-safety-policy.md:483:- v1.0 handles "needs approval" cases via **ad-hoc Telegram approval** outside the policy pipeline: agent emits a manual approval request via existing primitive 5, founder/operator resolves manually, agent proceeds. These cases are tracked as "would-be-orange" candidates for v1.1 prioritisation.
docs/decisions/autosend-safety-policy.md:489:- Existing green and red actions remain unchanged. v1.0 → v1.1 transition is purely additive.
docs/decisions/autosend-safety-policy.md:510:docs/decisions/autosend-safety-policy.md in the IFOS code repository)
docs/decisions/autosend-safety-policy.md:554:of docs/decisions/autosend-safety-policy.md in the decision_log row's
docs/decisions/autosend-safety-policy.md:585:4. **Cyber insurance.** IFOS Limited needs cyber insurance covering policy miscategorisation events. Quote requests pending; budget impact on v1.0 founder-set cost budget (Day-4 runbook §1.4 — £20/mo for infrastructure at single-tenant pilot scale; master brief does not specify a numeric cost target).
docs/decisions/autosend-safety-policy.md:601:| 6 | v1.0 "would-be-orange" cases without orange tier implementation — how does the agent halt for ad-hoc Telegram approval without breaking the green/red binary? | §9 | Recommend a `hh_decision_action_ad_hoc_approval` helper that lives alongside `hh_decision_action`; agent explicitly calls it for known orange cases at v1.0; v1.1 deprecates as orange tier ships. |
docs/decisions/autosend-safety-policy.md:604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
docs/decisions/autosend-safety-policy.md:605:| 10 | Telegram bot reliability — primitive 5 is shipped but not battle-tested at v1.0 pilot scale. What's the SLA on approval gate notification? | §5 + §6 | Recommend instrumentation in Week 1-2 as part of `_shared/` helpers build. Target: 95th percentile notification latency <30s. Below-target events trigger v1.1 evaluation of alternate channels. |
docs/decisions/autosend-safety-policy.md:620:- **Q3 (lookup latency / 71-hour cache lifetime):** ACCEPTED for v1.0. Policy hot-reload deliberately deferred to v1.1+; v1.0 accepts up-to-71-hour delay on policy changes taking effect at agent layer. Material policy changes must wait for next 71-hour boundary (cortextOS context rotation per master brief §2.4 primitive 2) or trigger deliberate cortextOS PTY restart. Operational footgun documented in §4.
docs/decisions/autosend-safety-policy.md:621:- **Q5 (sampling rate defaults for yellow tier):** ACCEPTED for v1.0 with explicit operational-guess flag. Real sampling rates need pilot data; current defaults (1-in-5 to 1-in-20 per `action_type` in §3) are operational guesses calibrated by analogy to typical CRM audit-sampling practice. Refinement happens once first pilot generates 4+ tenant-weeks of yellow-tier action volume.
docs/decisions/autosend-safety-policy.md:622:- **Q6 (v1.0 ad-hoc orange handling without orange tier shipped):** ACCEPTED. `hh_decision_action_ad_hoc_approval` helper sits alongside `hh_decision_action` in `_shared/hook-helpers.sh` (Week-1 prereq 3). Agent explicitly calls `_ad_hoc_approval` for known orange cases at v1.0; v1.1 deprecates the helper as full orange tier ships through `hh_decision_action`'s case-orange branch.
docs/decisions/autosend-safety-policy.md:634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:657:- v1.0 ship date: tier coverage is green + red. Yellow + orange phase in v1.1.
docs/decisions/autosend-safety-policy.md:658:- v1.0 implementation prerequisite: this policy + the Week-1 `_shared/` helpers + ADR-003 renderer + Day-4 Postgres schema (all four are present after this commit lands).
packages/utilities/web-scraper/pnpm-lock.yaml:190:    resolution: {integrity: sha512-RVyzfb3FWsGA55n6WY0MEIEPURL1FcbhFE6BffZEMEekfCzCIMtB5yyDcFnVbTnwk+CLAgTujmV/Lgvih56W+A==}
packages/utilities/web-scraper/pnpm-lock.yaml:196:    resolution: {integrity: sha512-bPb5AHZtbeNGjCKVZ9UGqGwo8EUu4cLq68E95A53KlxAPRmUyYv2D6F0uUI65XisGOL1hBP5mTronbgo+0bFcA==}
packages/utilities/web-scraper/pnpm-lock.yaml:364:    resolution: {integrity: sha512-nU1yhmYutL+fQ71Kxnhg8uEOdC0pwEW9entHykTgEbna2pw2dkbFSMeqjjyHZoCmt8SBkOSvV+yNmm94aUrrqw==}
packages/utilities/web-scraper/pnpm-lock.yaml:533:    resolution: {integrity: sha512-J3Yh9PzzF1Ovah2At+lHiGQdsYgArxBbXv/zHfSyaiFQEqvNv7DcW98pCrmdjCZBrqBiKrKKe2V+aaSGWuBe/w==}
packages/utilities/web-scraper/pnpm-lock.yaml:557:    resolution: {integrity: sha512-nbJnQ8a3z1mtmrwImCYhc6BGpThAyYVRQxw9uKSKG4wR6aAYno9sVjJ0zaZcW9BPJX1GbrDPf+SvdWjgTuDmnw==}
packages/utilities/web-scraper/pnpm-lock.yaml:587:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:593:    resolution: {integrity: sha512-Boiz5+MsaROEWDf+GGEwF8VMHGhlUoQMtIPjOgA5fv4osupqTVnJteQNKJwUcnUog2G55jYXH7KZFFiJe0TEzQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:638:    resolution: {integrity: sha512-GhdPgy1el4/ImP05X05Uw4cw2/M93BCUmnEvWZNStlCzEKME4Fkk+YpoA5OiHNQmoS7Cafb8Xa3Pya8m1Qrzeg==}
packages/utilities/web-scraper/pnpm-lock.yaml:825:    resolution: {integrity: sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==}
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:30:Four mechanisms address these four failure modes in §2-§5. **All four mechanisms must be implemented in `wiki/lib/concurrency.ts`** for the wiki API to ship in v1.0 weeks 11-13 per `sequencing-target.md` §4.1 row 6 (Concierge, the heaviest concurrency stressor).
docs/architecture/vault-concurrency.md:383:**V1.2+ improvement deferred** — write-ahead-log pattern where filesystem writes go to `wiki/.tmp/cascade-<txn-id>/` first; commit moves them atomically (via batched renames inside a sentinel-marker pattern); rollback removes the `.tmp/cascade-<txn-id>/` directory. Eliminates the partial-failure surface at the cost of meaningful implementation complexity. Out of v1.0 scope.
docs/architecture/vault-concurrency.md:391:**V1.2+ improvement deferred** — async cascade with eventual consistency: rename completes synchronously at the Postgres + target-file layer; cascade-rewrite is queued as background tasks; consumers see the updated `entity_links` table immediately, and lagging markdown bodies are reconciled within minutes. Reduces user-visible rename latency. Out of v1.0 scope.
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/architecture/vault-concurrency.md:424:| Cascade atomicity gap (v1.0 mitigation via `ESC_VAULT_CASCADE_PARTIAL_FAILURE` + decision_log + manual reconciliation; full atomicity via write-ahead-log deferred to v1.2+) | §5.4 |
docs/architecture/vault-concurrency.md:425:| Cascade performance (30s timeout; v1.0 sequential; v1.2+ async with eventual consistency deferred) | §5.5 |
docs/architecture/vault-concurrency.md:450:| Retry policy on Postgres version-mismatch | 1 retry with 100ms backoff (`OP_RETRY_BACKOFF_MS`) | Hard-coded in v1.0; may surface to per-tenant config in v1.1+ if observed contention requires |
docs/architecture/vault-concurrency.md:453:All defaults are conservative for v1.0 pilot scale (3-6 tenants per Product Spec §5.4). Observed contention data in production may justify tightening (lower lock timeouts to surface contention faster) or loosening (higher cascade timeouts for batch operations). Revisit at first three pilots' month-3 review per Product Spec §3.
packages/agent-renderer/templates/claude-md-preamble.md:20:Decision-log calls are mandatory per master brief §8.1 Change 2:
packages/agent-renderer/templates/claude-md-preamble.md:63:Auto-send tier policy per `_shared/autosend-policy.yaml`. Tenant override file (if present): `/vault/{{tenant_slug}}/_config/autosend-overrides.yaml` — read by `autosend_apply_tenant_override` per `docs/decisions/autosend-safety-policy.md` §4.
packages/agents-runtime/_shared/common-notifications.json:25:      "description": "Primary surface for orange-tier approval gates per autosend-safety-policy §4."
packages/agents-runtime/_shared/common-notifications.json:49:      "description": "4h default per autosend-safety-policy §5 ESC_AUTOSEND_NEEDS_REVIEW; timeout converts orange-tier to ESC_AUTOSEND_NEEDS_REVIEW row."
docs/runbooks/operational-hygiene-protocol.md:164:| **Decision artefact** | Per tier/trigger/option × support | 30-60 lines (incl. examples + escalation) | autosend-safety-policy.md (4 tiers + 29 action_types + 3 ESC codes + 11 sections ≈ 650 lines) |
docs/runbooks/operational-hygiene-protocol.md:260:Audit of citation accuracy across 4 main committed artefacts: Day-4 runbook, autosend-safety-policy.md, v1.0-kill-criterion.md, vertical-schema.yaml. Plus state files: RISK-REGISTER.md, current-priorities.md.
docs/runbooks/operational-hygiene-protocol.md:275:| `docs/decisions/autosend-safety-policy.md` | 1 | Same cost-target replacement for the cyber-insurance budget reference |
docs/runbooks/operational-hygiene-protocol.md:276:| `docs/decisions/v1.0-kill-criterion.md` | 3 | Same cost-target replacement for Trigger 6/7 source citations |
docs/runbooks/operational-hygiene-protocol.md:290:Day-6 structural summary claimed "30+ action_types across 6 v1.0 agents" in autosend policy §3. Actual count: 29 (Green 6 + Yellow 5 + Orange 10 + Red 8). The artefact itself does not make this claim — only my summary message did.
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
docs/runbooks/operational-hygiene-protocol.md:330:| 3 | Should §5 citation discipline be enforced via pre-commit hook (mechanical grep + verify)? | Defer to Week 1-2. Hook would be valuable but is itself code-to-write. v1.0: discipline is mental; v1.1+: tool-enforced. |
agents/recruitment/sourcing-scout/agent.md:1:# Sourcing Scout — request-response passive sourcing
agents/recruitment/sourcing-scout/agent.md:3:**Status:** Proposed (Day-19 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice).
agents/recruitment/sourcing-scout/agent.md:6:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:7:**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
agents/recruitment/sourcing-scout/agent.md:8:**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.
agents/recruitment/sourcing-scout/agent.md:16:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate flagged "do not contact" in tenant vault (per ULTRAPLAN A5 line 552 verbatim). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:22:### Brain UI (v1.0 primary)
agents/recruitment/sourcing-scout/agent.md:24:Brain UI v1.0 "Source candidates" button on any brief detail page → POST internal API → Sourcing Scout webhook.
agents/recruitment/sourcing-scout/agent.md:26:### Telegram command (v1.0)
agents/recruitment/sourcing-scout/agent.md:33:### Webhook (v1.0)
agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
agents/recruitment/sourcing-scout/agent.md:37:### CLI (v1.0 — debugging)
agents/recruitment/sourcing-scout/agent.md:57:# Sourcing Scout — <Brief title>
agents/recruitment/sourcing-scout/agent.md:59:**Sources searched:** Bullhorn ATS + LinkedIn (Proxycurl) + Reed + CV-Library
agents/recruitment/sourcing-scout/agent.md:86:| LinkedIn (Proxycurl) | <N> | <score> | <remaining> |
agents/recruitment/sourcing-scout/agent.md:98:Voice-classified content: only the per-candidate match rationale (Step 9). Voice classifier ≥0.75 against tenant style. Rationale that fails after 3 retries → ESC_VOICE_DRIFT → candidate dropped from list + flagged in exception list.
agents/recruitment/sourcing-scout/agent.md:104:11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/sourcing-scout/agent.md:116:   → ESC_BRIEF_AMBIGUITY if extraction yields <3 key dimensions (per
agents/recruitment/sourcing-scout/agent.md:122:   → bullhorn (read-only); LinkedIn/Proxycurl; Reed; CV-Library
agents/recruitment/sourcing-scout/agent.md:123:   → per-source: ESC_BULLHORN_AUTH | ESC_LINKEDIN_AUTH | ESC_REED_AUTH |
agents/recruitment/sourcing-scout/agent.md:126:   → if 2+ sources fail auth: ESC_AGENT_OUTPUT_SHAPE (Sourcing Scout cannot
agents/recruitment/sourcing-scout/agent.md:137:     candidate.status as [active, archived, do_not_contact, placed,
agents/recruitment/sourcing-scout/agent.md:144:4. LinkedIn search (via Proxycurl)
agents/recruitment/sourcing-scout/agent.md:149:   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
agents/recruitment/sourcing-scout/agent.md:180:   → ESC_DNC_FILTER_HIT per blocked candidate (catalogue line: §2.10 — DNC
agents/recruitment/sourcing-scout/agent.md:190:   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
agents/recruitment/sourcing-scout/agent.md:198:    → if any condition fails: ESC_AGENT_OUTPUT_SHAPE (output-shape violation
agents/recruitment/sourcing-scout/agent.md:219:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
agents/recruitment/sourcing-scout/agent.md:229:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation per catalogue line 184); draft to `/tmp`; operator review.
agents/recruitment/sourcing-scout/agent.md:231:**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/sourcing-scout/agent.md:235:Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
agents/recruitment/sourcing-scout/agent.md:237:Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.
agents/recruitment/sourcing-scout/agent.md:239:Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
agents/recruitment/sourcing-scout/agent.md:241:Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
agents/recruitment/sourcing-scout/agent.md:247:Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/sourcing-scout/agent.md:252:| `ESC_LINKEDIN_AUTH` | Proxycurl API key invalid | warn (single-source fail OK if 2+ others succeed) | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:256:| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:257:| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:258:| `ESC_DNC_FILTER_HIT` | Outbound candidate matches tenant DNC list (per-candidate; blocks the candidate's inclusion) | **blocking** (per-candidate) | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:260:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:261:| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | founder + operator |
agents/recruitment/sourcing-scout/agent.md:263:Sourcing Scout does NOT use:
agents/recruitment/sourcing-scout/agent.md:267:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
agents/recruitment/sourcing-scout/agent.md:268:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/sourcing-scout/agent.md:282:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
agents/recruitment/sourcing-scout/agent.md:284:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/sourcing-scout/agent.md:288:## §8 — Build dependencies (W9 prerequisites)
agents/recruitment/sourcing-scout/agent.md:290:Sourcing Scout build cannot start until ALL of the following are confirmed:
agents/recruitment/sourcing-scout/agent.md:300:| **Proxycurl commercial signup** + API access | Founder commercial; ~$39+/mo | ⏸ |
agents/recruitment/sourcing-scout/agent.md:303:| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:304:| Reed MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:305:| CV-Library MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:306:| Source-abstraction layer (Night Sourcer reuse) | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:310:| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:311:| `context.sh` hydration | Build at W9 start (~0.5 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:312:| `cycle.sh` orchestration (11-step) | Build at W9 start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:313:| 3 fixtures with golden outputs | Build at W9 start (~1 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:315:**Until ALL ⏸ items resolve to ✅, W9 build slice does not start.**
agents/recruitment/sourcing-scout/agent.md:321:**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:327:| Q1 | All three external sources required for v1.0? Reed + CV-Library are UK-recruitment-specific; Proxycurl is LinkedIn-via-API. Could v1.0 ship with Bullhorn + Proxycurl only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
agents/recruitment/sourcing-scout/agent.md:328:| Q2 | Proxycurl pricing — ~$39/mo for 5,000 credits at low volume; scales with usage. Per pilot tenant budget? | ~5-10 briefs/day per consultant × 50 calls/brief = up to 2,500 credits/day per consultant. Cost: ~$20-50/day at peak. |
agents/recruitment/sourcing-scout/agent.md:329:| Q3 | DNC list source — tenant uploads a list, or we derive from Bullhorn entity flag? | v1.0: tenant-uploaded text file at `/vault/<slug>/do-not-contact.list`. v1.1: derive from Bullhorn entity field. |
agents/recruitment/sourcing-scout/agent.md:330:| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
agents/recruitment/sourcing-scout/agent.md:331:| Q5 | Gate B 6-of-10 metric — measured via consultant feedback. Brain UI v1.0 doesn't have feedback UX yet. Telegram reply? | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful". v1.1: Brain UI button. |
agents/recruitment/sourcing-scout/agent.md:332:| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
agents/recruitment/sourcing-scout/agent.md:333:| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Existing Bullhorn candidate-status enum has "passive" / "active" / "placed". | Founder + Bullhorn-rep clarification during Sub-decision B response. |
agents/recruitment/sourcing-scout/agent.md:335:### Gotchas (carried forward from ULTRAPLAN A5 line 555)
agents/recruitment/sourcing-scout/agent.md:337:1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
agents/recruitment/sourcing-scout/agent.md:338:2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
agents/recruitment/sourcing-scout/agent.md:354:- W9 build slice produces all 5 sibling bundle files + 3 fixtures
agents/recruitment/sourcing-scout/agent.md:361:*End of Sourcing Scout agent.md draft.*
docs/decisions/v1.0-kill-criterion.md:1:# v1.0 kill criterion
docs/decisions/v1.0-kill-criterion.md:8:**Path drift logged:** Master brief §6 Day 5 line 486 specifies `docs/v1-kill-criterion.md` (docs/ root). This artefact lives at `docs/decisions/v1.0-kill-criterion.md` per repo convention. Recorded as **Edit 10** in atomic-correction manifest (shared with autosend-safety-policy.md path drift).
docs/decisions/v1.0-kill-criterion.md:14:Three distinct end-states for v1.0:
docs/decisions/v1.0-kill-criterion.md:18:**Cease v1.0 development.** The wedge is invalidated by structural evidence. Existing pilots receive 30-day wind-down notice; assets liquidated or open-sourced; refund obligations honoured per pilot agreement. Founder pivots to next initiative.
docs/decisions/v1.0-kill-criterion.md:20:**KILL is reversible only as v1.1 or v2.0**: a wholly new initiative under different premises, with its own kill criterion. v1.0 itself does not resurrect.
docs/decisions/v1.0-kill-criterion.md:24:**Freeze v1.0 development for N weeks while data is gathered.** Existing pilots continue in read-only mode (agents that have shipped stay operational; no new agents ship). Founder + Jack conduct strategic review and define an unfreeze criterion.
docs/decisions/v1.0-kill-criterion.md:26:**PAUSE has a defined exit:** either unfreeze (resume v1.0 from the slice that was active when paused) OR escalate to KILL/PIVOT if the strategic review concludes the trigger is structural rather than temporary.
docs/decisions/v1.0-kill-criterion.md:30:**Rescope v1.0.** The wedge holds but its assumed shape is wrong. Common pivots:
docs/decisions/v1.0-kill-criterion.md:37:**v1.0 commitments to existing pilots are honoured under original scope.** New v1.0 contracts under rescoped terms. The master brief and Ultraplan are amended by atomic-correction commit; Codex ratifies before v1.0 resumption.
docs/decisions/v1.0-kill-criterion.md:57:**Unfreeze criterion:** **One signed pilot LOI** from a UK recruitment agency with stated pilot start date in Q3 2026. Unfreeze formal: Founder + Jack joint sign-off on the LOI; resume v1.0 from the slice that was active when paused.
docs/decisions/v1.0-kill-criterion.md:69:**Action:** KILL state. Rationale: the renderer architecture (ADR-003) was ratified in Week 0 Day 1 evening as the load-bearing Week-1 prerequisite. If Week 3 ends with no clean Diagnostic render, the renderer has fundamental gaps that the design did not anticipate. The renderer cannot be "patched"; v1.0 cannot ship without working render. Continuing into Weeks 4+ without resolution is sunk-cost reasoning.
docs/decisions/v1.0-kill-criterion.md:71:**Recovery path:** None within v1.0. Lessons logged to `.agents/learnings/v1.0-postmortem.md`. v1.1 may begin as new initiative with reconsidered renderer architecture (or no per-tenant render, or different bundle pattern).
docs/decisions/v1.0-kill-criterion.md:85:- **Option C:** ATS-agnostic with manual data sync. Reduces v1.0 to read-only agent operation against ATS export files; loses much of the Janitor + Concierge value but unblocks pilot acquisition.
docs/decisions/v1.0-kill-criterion.md:89:**Recovery path:** PIVOT is structural; resumption is via rescoped v1.0 under new ATS assumption. Pivoted v1.0 continues with adjusted master brief / Ultraplan; atomic-correction commit lands the rescope.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:99:**Action:** PAUSE state. Rationale: two scope cuts indicates either (a) the v1.0 wedge is structurally too narrow to be valuable, or (b) build velocity is fundamentally below the rate v1.0 requires. Either way, continuing to ship more agents is the wrong move; strategic review needed.
docs/decisions/v1.0-kill-criterion.md:104:2. **Escalate to PIVOT:** rescope vertical or customer-type; pivoted v1.0 has new agent fleet definition.
docs/decisions/v1.0-kill-criterion.md:109:**Threshold:** More than 3 confirmed red-tier autosend breaches per pilot per week from actions that should have been classified as green or yellow. "Confirmed" means: tenant operator files a `false-block` feedback report via Brain UI (or equivalent v1.0 manual channel) AND IFOS oncall agrees the tier classification was wrong. Threshold measured per individual pilot over rolling 7-day windows.
docs/decisions/v1.0-kill-criterion.md:113:**Source:** `docs/decisions/autosend-safety-policy.md` §5 + §10; Risk #3 in `docs/RISK-REGISTER.md` (LUKS manual unlock has higher impact but autosend miscategorisation has higher frequency).
docs/decisions/v1.0-kill-criterion.md:134:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 pilot scale; master brief does not specify a numeric cost target); emerging from v1.0 pilot operations.
docs/decisions/v1.0-kill-criterion.md:136:**Action:** PIVOT — likely vector: cheaper Claude model tier (Haiku 4.5 for routine actions, Sonnet for complex), or reduced agent run frequency (e.g., Sourcing Scout runs nightly batch instead of real-time), or per-tenant cost passthrough in pricing.
docs/decisions/v1.0-kill-criterion.md:138:**Recovery path:** Rescoped pricing/architecture; pivoted v1.0 continues.
docs/decisions/v1.0-kill-criterion.md:148:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 single-tenant pilot; master brief does not specify a numeric cost target); Risk #4 in `docs/RISK-REGISTER.md` (Hire #1 delays compound infrastructure spend if architecture sprawls).
docs/decisions/v1.0-kill-criterion.md:156:**Recovery path:** Rescoped infrastructure plan; pivoted v1.0 continues with adjusted Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target; budget adjustment is a runbook revision, not a master-brief edit).
docs/decisions/v1.0-kill-criterion.md:166:**Action:** KILL. Rationale: the wedge does not produce demonstrable ROI at the threshold required to sustain v1.0 commercially. £20k/year/tenant is the breakeven floor — below this, IFOS cannot fund continued operation at v1.0 pricing.
docs/decisions/v1.0-kill-criterion.md:168:**Recovery path:** None within v1.0. Lessons feed v1.1 if launched. The vertical assumption (UK recruitment) or product assumption (agent fleet vs. point tools) may need reconsidering for any next initiative.
docs/decisions/v1.0-kill-criterion.md:174:**Threshold tightened Day 5 (2026-05-18) from 4 weeks to 2 weeks.** Rationale: Risk #1 severity was downgraded Day 1 because primitives 3 + 4 confirmed "shipped and tested" per `cortexos-primitive-status.md`. If field evidence shows failure-rate spike for 2 consecutive weeks, that is an actionable signal — waiting 4 weeks delays remediation by 50% within the v1.0 build timeline (Weeks 1-13).
docs/decisions/v1.0-kill-criterion.md:196:**Action:** KILL. Rationale: multi-tenant trust is the structural foundation of v1.0. A single confirmed PII breach beyond the RLS + autosend boundary indicates the foundation is unsound. Continuing operation risks (a) further breaches, (b) regulatory action, (c) catastrophic loss of pilot trust. Wind-down protects existing pilots from further exposure.
docs/decisions/v1.0-kill-criterion.md:198:**Recovery path:** None within v1.0. Mandatory ICO notification per UK GDPR Art. 33 (within 72 hours of discovery). Lessons logged comprehensively. Any v1.1 must be architecturally distinct (e.g., per-tenant physically-isolated infrastructure rather than shared Postgres with RLS).
docs/decisions/v1.0-kill-criterion.md:204:**Day-5 restructure** (2026-05-18): Jack is high engagement on sales/commercial; founder is solo on product. This v1.0 kill criterion governs the **product domain**. Founder has SOLO authority for all trigger activations; Jack is informed-not-deciding. Commercial-domain kill criteria are deferred to a future artefact (placeholder: `v1.0-kill-criterion-commercial.md`).
docs/decisions/v1.0-kill-criterion.md:218:Commercial-side kill criteria — pilot pricing, customer acquisition strategy, sales pipeline kill thresholds — are out of scope for v1.0 product kill criterion. A future artefact (placeholder name: `v1.0-kill-criterion-commercial.md`) defines them with Jack as decision authority and founder informed. Scope boundary: anything that does not directly trigger product KILL/PAUSE/PIVOT belongs in the commercial document.
docs/decisions/v1.0-kill-criterion.md:233:External advisor name **TBD**. Slot reserved for future tie-break needs that may emerge from commercial decisions or post-pilot scale. **Rationale for deferral:** founder-solo authority in §3.1 means no tie-break is needed for v1.0 product decisions; advisor becomes useful only when joint authority structures emerge.
docs/decisions/v1.0-kill-criterion.md:235:**Must-fill before first pilot LOI signs.** The pilot agreement may reference an external advisor for dispute resolution per `autosend-safety-policy.md` §10 placeholder language. Founder identifies and engages within Weeks 1-2.
docs/decisions/v1.0-kill-criterion.md:296:4. v1.0 resumes from the slice that was active when paused (rather than restarting Week 1). Adjusted timeline reflects pause duration.
docs/decisions/v1.0-kill-criterion.md:307:2. Codex ratifies the rescope before v1.0 resumption (mandatory).
docs/decisions/v1.0-kill-criterion.md:309:4. New v1.0 contracts (post-pivot) under rescoped terms.
docs/decisions/v1.0-kill-criterion.md:314:1. **N/A — v1.0 is wound down.** No recovery into v1.0.
docs/decisions/v1.0-kill-criterion.md:315:2. Lessons comprehensively logged to `.agents/learnings/v1.0-postmortem.md`. Logging includes:
docs/decisions/v1.0-kill-criterion.md:322:4. v1.1 — if launched — is a wholly new initiative under different premises. Not a continuation of v1.0. Has its own master brief, Ultraplan, kill criterion.
docs/decisions/v1.0-kill-criterion.md:326:## §6 — v1.0 → v1.1 distinction
docs/decisions/v1.0-kill-criterion.md:328:**This kill criterion governs v1.0 only.**
docs/decisions/v1.0-kill-criterion.md:330:### What "v1.0" means
docs/decisions/v1.0-kill-criterion.md:332:v1.0 is defined by:
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:345:v1.1 begins when v1.0 is operationally stable with ≥1 pilot operational. v1.1 scope per master brief §9 build sequence + Product Spec:
docs/decisions/v1.0-kill-criterion.md:349:- Adds yellow + orange autosend tiers per `autosend-safety-policy.md` §9
docs/decisions/v1.0-kill-criterion.md:351:- Per-firm LoRA pipeline begins (deferred from v1.0)
docs/decisions/v1.0-kill-criterion.md:355:**Defined in Week 4+ once v1.0 has at least one pilot operational.** v1.1 kill criterion will incorporate v1.0 learnings + v1.1-specific triggers (e.g., wiki UI usability scores, voice classifier drift rates, LoRA training cost-per-tenant).
docs/decisions/v1.0-kill-criterion.md:357:This v1.0 kill criterion does NOT govern v1.1. A v1.0 KILL terminates v1.0 only; v1.1 — if launched — is a new initiative under its own framework.
docs/decisions/v1.0-kill-criterion.md:361:What happens if a v1.0 trigger fires during v1.1 build?
docs/decisions/v1.0-kill-criterion.md:363:- v1.0 triggers stop applying when v1.1 is in flight AND v1.0 pilots have been migrated to v1.1 commitments.
docs/decisions/v1.0-kill-criterion.md:364:- If v1.0 pilots are still on v1.0 commitments while v1.1 build proceeds, BOTH kill criteria apply to their respective scopes.
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
docs/decisions/v1.0-kill-criterion.md:387:**For atomic-correction manifest.** Edit 10 (shared with autosend-safety-policy.md) adds the path drift correction. Manifest grows from 9 to 10.
docs/decisions/v1.0-kill-criterion.md:395:- **Proposed** (this commit) → **Accepted** (post-Codex Day-7) → **In force** (immediately upon Acceptance; triggers active for v1.0 build)
docs/decisions/v1.0-kill-criterion.md:396:- This document is **the operational definition of "v1.0 still alive"** at every Week-1+ review.
docs/decisions/v1.0-kill-criterion.md:397:- Updates between v1.0 and v1.1: minor updates (threshold tuning, owner reassignment) via amendment commit; structural updates (new trigger, removal of trigger) via Codex ratification.
packages/agents-runtime/_shared/common-voice.json:5:  "description": "Per-tenant voice corpus reference. Read by agents/_shared/voice-loader.sh per master brief §8.1 Change 1. Schema substrate landed in vertical-schema.yaml v0.2 (Phase 4).",
packages/agents-runtime/_shared/common-voice.json:26:      "description": "Phrases that trigger ESC_VOICE_DRIFT before classifier scoring."
docs/specs/ULTRAPLAN.md:54:I do not have a status report on CortexOS readiness (this is Q1, deferred). The build plan assumes each primitive has the following minimum viable state by start of v1.0 Sprint 1. If reality is worse than this, the sprint plan in §9 slips and we say so honestly.
docs/specs/ULTRAPLAN.md:56:| # | Primitive | Minimum required state for v1.0 | What we do if it's not ready |
docs/specs/ULTRAPLAN.md:58:| 1 | **Persistent PTY via PM2** | Working for ≥1 agent in dev; documented config; auto-restart on crash | Ship the v1.0 agents as scheduled cron with a documented migration path. Loses the Triage closing demo but keeps the build moving. |
docs/specs/ULTRAPLAN.md:59:| 2 | **71-hour context rotation** | Working in principle; tested manually | Manual restart cadence acceptable for v1.0 pilots; flag as known limitation in pilot agreement. |
docs/specs/ULTRAPLAN.md:61:| 4 | **Approval gates with standing authorisations** | Telegram approval surface working; standing-auth config schema defined | If not ready, every auto-send becomes draft-only for v1.0. Hurts the Triage pitch but doesn't kill it. |
docs/specs/ULTRAPLAN.md:62:| 5 | **Telegram + iOS approval surface** | Telegram working; iOS deferred to v1.2 acceptable | Telegram-only is fine for v1.0. iOS in v1.2 is the marketing line, not a tech blocker. |
docs/specs/ULTRAPLAN.md:63:| 6 | **Overnight autoresearch** | Long-session capability documented; rate-limit handling tested | This is for the Night Sourcer in v1.1, not v1.0. Defer the question. |
docs/specs/ULTRAPLAN.md:72:- **The file bus.** Inter-agent handoff via shared filesystem directories. No queue, no API, no serialisation tax. Brief Decoder writes a parsed-brief file; Sourcing Scout's `FastChecker` polls it up at the configured cadence (default 1000ms `pollInterval`, configurable per agent); result lands in a sub-directory the Concierge is polling. Four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound.
docs/specs/ULTRAPLAN.md:146:**Change 1 — Voice handling moves into a shared module.**
docs/specs/ULTRAPLAN.md:166:**Change 2 — Decision logging is enforced, not optional.**
docs/specs/ULTRAPLAN.md:182:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/specs/ULTRAPLAN.md:186:- `ESC_BRIEF_AMBIGUITY` — Brief Decoder found ambiguities that prevent confident shortlisting
docs/specs/ULTRAPLAN.md:211:This is the answer to Q5 ("shared Postgres + per-tenant vault + per-tenant PM2 process group at v1.0; per-tenant Docker at v1.1; dedicated cluster slice at Sovereign v2.0"). Restated as a build specification.
docs/specs/ULTRAPLAN.md:221:- The agent process for tenant X runs as `ifos-tenant-{X}` and *cannot* read tenant Y's vault because the kernel stops it. POSIX permissions are the isolation boundary at v1.0.
docs/specs/ULTRAPLAN.md:243:### 5.2 Why this for v1.0 and not Docker-per-tenant
docs/specs/ULTRAPLAN.md:287:Tenancy plumbing for v1.0:
docs/specs/ULTRAPLAN.md:296:**Total: 7 engineering days.** This is week 2 of the v1.0 build, after the Agent Bundle v2 refactor in week 1.
docs/specs/ULTRAPLAN.md:354:If any hard fail, the agent regenerates with the failure reason injected as additional context ("your previous draft used the banned phrase 'I hope this finds you well'; rewrite avoiding it"). After 3 retries with hard fails, escalate with `ESC_VOICE_DRIFT` or `ESC_SCHEMA_VIOLATION`.
docs/specs/ULTRAPLAN.md:367:The training pipeline itself is the v2.0 work; the data capture starts at v1.0 with the decision log writes from §4.2.
docs/specs/ULTRAPLAN.md:376:If the rolling 4-week average drops by ≥5 percentage points: `ESC_VOICE_DRIFT_TENANT` fires. Email goes to the customer's primary contact AND to the internal CS Slack:
docs/specs/ULTRAPLAN.md:392:This demo capability is part of the v1.0 sales toolkit. ~3 days of engineering, built once.
docs/specs/ULTRAPLAN.md:455:- v1.0 (the first three pilots): Maddox sets bars calibrated to "good enough to keep paying", slightly more generous than feels comfortable.
docs/specs/ULTRAPLAN.md:466:The agents are ordered by build wave (v1.0 → v1.1 → v1.2 → v2.0), not by revenue priority.
docs/specs/ULTRAPLAN.md:472:Build wave (v1.0 / v1.1 / v1.2 / v2.0)
docs/specs/ULTRAPLAN.md:485:### 8.1 v1.0 agents (six)
docs/specs/ULTRAPLAN.md:489:- **Build wave:** v1.0 (week 4–5)
docs/specs/ULTRAPLAN.md:495:- **External APIs:** Companies House API (free), LinkedIn (via Proxycurl or similar), basic HTTP fetch
docs/specs/ULTRAPLAN.md:503:- **Build wave:** v1.0 (week 5–6)
docs/specs/ULTRAPLAN.md:513:- **Gotchas:** Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0. Estimate 1 week for the MCP server, 1 week for the agent itself. Dedup is hard; start conservative (high-confidence merges only) and tune up.
docs/specs/ULTRAPLAN.md:517:- **Build wave:** v1.0 (week 6–7)
docs/specs/ULTRAPLAN.md:531:- **Build wave:** v1.0 (week 7–8)
docs/specs/ULTRAPLAN.md:543:#### A5. Sourcing Scout (daytime form) — request-response sourcing
docs/specs/ULTRAPLAN.md:545:- **Build wave:** v1.0 (week 8–9)
docs/specs/ULTRAPLAN.md:549:- **MCP tools required:** Bullhorn (read for ATS passive matches), LinkedIn (via Proxycurl or similar), Reed.co.uk API, CV-Library API
docs/specs/ULTRAPLAN.md:551:- **External APIs:** Proxycurl, Reed, CV-Library
docs/specs/ULTRAPLAN.md:555:- **Gotchas:** LinkedIn rate limits via Proxycurl. Reed/CV-Library have separate auth and separate result schemas. Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it.
docs/specs/ULTRAPLAN.md:559:- **Build wave:** v1.0 (week 9–10)
docs/specs/ULTRAPLAN.md:568:- **Build complexity:** **XL** (4 weeks) — this is the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)
docs/specs/ULTRAPLAN.md:593:- **MCP tools required:** Bullhorn (read for prior placements + candidates), shared with Sourcing Scout
docs/specs/ULTRAPLAN.md:594:- **Shared modules required:** Voice loader, decision log writer, the Brief Decoder→Sourcing Scout→Concierge orchestration template
docs/specs/ULTRAPLAN.md:595:- **External APIs:** Same as Sourcing Scout (reuses)
docs/specs/ULTRAPLAN.md:599:- **Gotchas:** Brief format varies hugely between clients. Build the parser as schema-driven, not pattern-matching. The orchestration handoff to Sourcing Scout is the load-bearing CortexOS test.
docs/specs/ULTRAPLAN.md:603:Already specified in §8.1 A4 as v1.0. The v1.1 work is the reframe of pitch and any latency optimisations needed once we have 3+ tenants in production. Not a new build, ~3 days of polish.
docs/specs/ULTRAPLAN.md:626:- **Shared modules required:** Voice loader, decision log writer, the source-abstraction layer from Sourcing Scout
docs/specs/ULTRAPLAN.md:627:- **External APIs:** Same as Sourcing Scout + GitHub
docs/specs/ULTRAPLAN.md:629:- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared with Sourcing Scout)
docs/specs/ULTRAPLAN.md:630:- **Build complexity:** **M** (2 weeks) — reuses Sourcing Scout's source layer; the new work is the overnight scheduling + rate-limit budget allocation
docs/specs/ULTRAPLAN.md:663:Short specs only — these are downstream of v1.0+v1.1 and will benefit from the production lessons.
docs/specs/ULTRAPLAN.md:689:| Sourcing Scout | ✓ | ✓ | | | ✓ | | ✓ | | | ✓ | |
docs/specs/ULTRAPLAN.md:712:6. **LinkedIn (via Proxycurl)** — 6 of 18. Third-priority.
docs/specs/ULTRAPLAN.md:717:## 9. The 14-week v1.0 sprint plan
docs/specs/ULTRAPLAN.md:719:Targets: 3 paid pilots by end of Q3 2026 (per the internal business plan). v1.0 = the six v1.0 agents shippable in the Starter and Boutique tiers; Growth/Scale defer to v1.1.
docs/specs/ULTRAPLAN.md:771:### Weeks 9–10 — Sourcing Scout + Concierge start
docs/specs/ULTRAPLAN.md:773:- Week 9: Sourcing Scout (daytime); LinkedIn + Reed + CV-Library integration
docs/specs/ULTRAPLAN.md:820:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
docs/specs/ULTRAPLAN.md:821:| 5 | Open Banking integration takes more than 1 week | Medium | Medium | End of week 7 status not "Xero + first bank connected" | Cash Conductor ships with manual reconciliation in v1.0; webhook-driven mode at v1.1 |
docs/specs/ULTRAPLAN.md:822:| 6 | LinkedIn rate limits via Proxycurl are tighter than expected | Medium | Medium | Sourcing Scout cost >£100/run | Negotiate Proxycurl enterprise plan; defer Night Sourcer to v1.2 if needed |
docs/specs/ULTRAPLAN.md:823:| 7 | Voice classifier underperforms (false positives blocking valid drafts) | Medium | Medium | First pilot reports >5% block rate on legitimate drafts | Soften the threshold from 0.75 → 0.65 for v1.0; tune up as corpus grows |
docs/specs/ULTRAPLAN.md:832:Risks #1, #2, #3, #4 are the four that could kill v1.0. Everything below them is recoverable.
docs/specs/ULTRAPLAN.md:838:These are the questions and decisions that must be cleared before any code is written. Each has an owner and a deadline. If any are still open at end of day 7, the v1.0 build start slips by the same number of days.
docs/specs/ULTRAPLAN.md:853:- [ ] v1.0 sequence optimisation target: Maddox confirms (b) "close first 3 pilots fastest" or revises. **Owner:** Maddox.
docs/specs/ULTRAPLAN.md:854:- [ ] Brain UI v1.0 scope: confirm "minimal what-did-the-agents-do-today view" or revise. **Owner:** Maddox (after at least one pilot conversation).
docs/specs/ULTRAPLAN.md:865:- [ ] v1.0 kill criterion documented (Q12). **Owner:** Maddox. **Output:** `v1-kill-criterion.md`.
docs/specs/ULTRAPLAN.md:907:This document is authoritative on the v1.0 → v2.0 build sequence and the technical architecture for delivering the recruitment product. Where it conflicts with prior plans on *how to build*, this wins. The product spec wins on *what to build*. The Internal Business Plan wins on commercial trajectory and ICP.
docs/runbooks/tenant-lifecycle.md:55:| `deployment_preference` | Pricing | sovereign | cloud (v1.0 default cloud) |
docs/runbooks/tenant-lifecycle.md:57:| `ATS choice` | Onboarding | bullhorn (v1.0 only) |
docs/runbooks/tenant-lifecycle.md:111:# Step 8: Render each active v1.0 agent for this tenant (when fleet ships)
docs/runbooks/tenant-lifecycle.md:225:**v1.0 default:** 90-day legal hold + tenant-controlled retention beyond.
docs/runbooks/tenant-lifecycle.md:277:**No `scripts/offboard-tenant.sh` exists.** Workflow above is the runbook spec. Script written when first tenant churns. **Risk:** if first churn happens without script, ad-hoc workflow risks omitting steps. Acceptable for v1.0 (low probability in pilot phase); v1.1+ adds the script.
docs/runbooks/tenant-lifecycle.md:330:**Migration runner currently only handles `migration-test` tenant.** Multi-tenant migration loop is the script extension at v1.1+. v1.0 with 1-2 pilot tenants can run the loop manually.
docs/runbooks/tenant-lifecycle.md:363:  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
docs/runbooks/tenant-lifecycle.md:384:| L1 | `scripts/provision-tenant.sh` doesn't exist | Medium | Written at first real tenant LOI; v1.0 manual workflow acceptable | First pilot LOI signed |
docs/runbooks/tenant-lifecycle.md:393:**All 8 gaps tracked with named trigger.** v1.0 single-tenant pilot doesn't blocking on any.
docs/operations/bullhorn-outreach-emails.md:19:**Sub-decision C** (v1.0 endpoint surface) is already Accepted in the doc — no commercial dependency.
docs/operations/bullhorn-outreach-emails.md:44:> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
docs/runbooks/pii-purge-operational-pattern.md:31:**Proposed v1.0 default: 90 days, pending D2/D3 advisor confirmation.** This runbook is written for the recommended D3-B path, but D3 has not been confirmed by the founder and D2 SeedLegals/external-advisor input is still required. Recommend NOT shorter than 30 days (review-cycle floor) and NOT longer than 180 days (GDPR-compliance ceiling for un-consented retention).
packages/agent-renderer/README.md:7:**Phase 2 scaffold (v0.1.0).** Phases 3-5 (helpers + voice schema + voice-loader) follow per `~/.claude/plans/bubbly-snuggling-lantern.md`. First production render: Diagnostic agent at Week 4 per master brief §8.2.
packages/agent-renderer/README.md:37:| `--org` | `<tenant-slug>` | one-org-per-tenant in v1.0 |
packages/agent-renderer/README.md:117:- **`_shared/` copy-not-symlink staleness.** Renderer COPIES `agents/_shared/` to `${frameworkRoot}/orgs/<org>/agents/_shared/` per ADR-003 §3.3.3 Option γ — does NOT symlink. Mid-pilot edits to `agents/_shared/{voice-loader,hook-helpers}.sh` require re-running `render-agent` for each tenant. v1.0 acceptable (single-tenant pilot); v1.1 may add SHA-based skip-if-unchanged optimisation.
packages/agent-renderer/README.md:120:- **Telegram-down hang for orange-tier autosend** (autosend-safety-policy §5) is a Phase-3 concern in `hook-helpers.sh` `autosend_await_approval`, not a renderer concern. Documented for completeness.
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:144:**Week-1 prerequisite, flagged for future sessions:** the renderer is a missing first-class artefact in the Week 1 plan. Without it, you cannot run an IFOS agent — the daemon's `AgentManager.discoverAndStart()` will not find a v2 bundle at `${repo}/agents/recruitment/<name>/` because it reads from `${projectRoot}/orgs/<org>/agents/<name>/`. The renderer's full design needs its own dedicated artefact (likely ADR-003 or `docs/architecture/agent-bundle-renderer-design.md`) before any v1.0 agent code can ship.
docs/architecture/second-brain-design.md:158:**Canonical v1.0 layout:**
docs/architecture/second-brain-design.md:203:| `wiki/raw/inbox-emails/` | one file per email | markdown with frontmatter | `{epoch}-{from-domain}-{rand5}.md` | inbound email webhook handler (v1.0: Cash Conductor for AR-relevant; v1.1: Triage for everything) | Brief Decoder (v1.1), Cash Conductor (v1.0); future Pulse semantic-search-over-raw |
docs/architecture/second-brain-design.md:204:| `wiki/raw/calls/` | one file per call | markdown with frontmatter | `{epoch}-{call-id}.md` | Scribe (v1.0) on Fathom/Fireflies webhook | Brief Decoder (v1.1), Concierge (v1.0) |
docs/architecture/second-brain-design.md:205:| `wiki/raw/briefs/` | one file per brief intake | markdown with frontmatter | `{epoch}-{brief-id}.md` | Brief Decoder (v1.1) on inbound | Sourcing Scout (v1.0 reads only candidate-relevant); Brief Decoder (v1.1) |
docs/architecture/second-brain-design.md:207:| `wiki/raw/ats-snapshots/` | one file per entity sync | JSON | `{epoch}-{bullhorn-entity-type}-{bullhorn-id}.json` | Janitor (v1.0) on nightly sweep | Janitor itself (diff vs previous), Concierge (v1.0) for entity reconciliation |
docs/architecture/second-brain-design.md:208:| `wiki/compiled/index.md` | one file | markdown | fixed name | compile.ts (v1.1; manual at v1.0 if needed) | Brain UI (v1.1) |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:210:| `wiki/compiled/clients/{slug}.md` | one per Client | same | same | Janitor (v1.0) on first contact | Cash Conductor + Concierge (v1.0) |
docs/architecture/second-brain-design.md:211:| `wiki/compiled/briefs/{slug}.md` | one per Brief | same | same | Brief Decoder (v1.1); manual at v1.0 if needed | Sourcing Scout (v1.0 reads only); Brief Decoder (v1.1) |
docs/architecture/second-brain-design.md:212:| `wiki/compiled/placements/{slug}.md` | one per Placement | same | same | Concierge (v1.0) on placement event | Cash Conductor (v1.0) for invoice context; future Pulse |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:217:| `wiki/.wiki/manifest.json` | one file | JSON | fixed name | compile.ts (v1.1; bypass at v1.0) | compile.ts (v1.1), Brain UI (v1.1) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:225:### 2.2 — Entity types in v1.0
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:236:| Client | **v1.0** | Janitor + Cash Conductor + Concierge all require it |
docs/architecture/second-brain-design.md:237:| Brief | **v1.0 (skeleton) / v1.1 (full)** | Sourcing Scout (v1.0 A5) needs to *read* a Brief to source against; Brief Decoder (v1.1 A8) is the producer. v1.0 writes minimal Briefs (manual entry or direct Bullhorn sync via Janitor); full lifecycle waits for v1.1 |
docs/architecture/second-brain-design.md:238:| Placement | **v1.0** | Concierge (v1.0 A6) produces; Cash Conductor (v1.0 A4) reads for invoice context |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:241:| Opportunity | **v1.1+** | Client Hunter digest (v1.1) and Spec Pitcher (v1.2) produce these; no v1.0 agent uses them |
docs/architecture/second-brain-design.md:244:#### 2.2.1 — Candidate (v1.0)
docs/architecture/second-brain-design.md:246:**Frontmatter schema** (master brief §5.2 lines 357-369 starting example; extended for v1.0 completeness):
docs/architecture/second-brain-design.md:259:importance_score: 0.83                               # optional v1.0; populated by reflect.ts v1.1+
docs/architecture/second-brain-design.md:266:do_not_contact: false                                # required; defaults to false; respected by Concierge
docs/architecture/second-brain-design.md:270:**Body content** — hybrid structure. v1.0 expectation:
docs/architecture/second-brain-design.md:294:#### 2.2.2 — Client (v1.0)
docs/architecture/second-brain-design.md:306:sectors: [fintech, b2b-saas]                         # required v1.0; list of strings from firm taxonomy
docs/architecture/second-brain-design.md:310:relationship_tier: key-account                       # optional v1.0; one of {key-account, active, dormant, ex-client}
docs/architecture/second-brain-design.md:317:#### 2.2.3 — Brief (v1.0 skeleton / v1.1 full)
docs/architecture/second-brain-design.md:319:v1.0 skeleton: only what Sourcing Scout (A5) needs to source against — role title, client, sector, must-haves. Full v1.1 schema waits for Brief Decoder.
docs/architecture/second-brain-design.md:332:sector: fintech                                      # required v1.0
docs/architecture/second-brain-design.md:333:salary_range_gbp: [80000, 110000]                    # optional v1.0
docs/architecture/second-brain-design.md:334:must_haves: [ "5+ years B2B SaaS", "UK right-to-work" ]   # required v1.0; list of strings
docs/architecture/second-brain-design.md:335:nice_to_haves: []                                    # optional v1.0
docs/architecture/second-brain-design.md:341:#### 2.2.4 — Placement (v1.0)
docs/architecture/second-brain-design.md:357:fee_structure:                                       # required v1.0
docs/architecture/second-brain-design.md:366:#### 2.2.5 — Contact (v1.0, stored under `wiki/compiled/people/`)
docs/architecture/second-brain-design.md:383:do_not_contact: false                                # required
docs/architecture/second-brain-design.md:398:**Spec gap 2.2-A:** master brief §5 does not specify the rewrite-backlinks mechanism. Recommended resolution: implement as part of `update-entity` in `packages/brain/wiki/lib/update.ts` v1.0.
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:420:| Operation | Caller (v1.0/v1.1) | Release | Input | Output | Latency | Notes |
docs/architecture/second-brain-design.md:422:| `search-by-name` | Concierge (v1.0): name → Candidate page on inbound message | v1.0 | `(entity_type: str, name_query: str, tenant_id: str)` | `List[EntityRef]` ranked by match score | sub-second | Fuzzy match (Levenshtein + token set); falls through to `search-by-attribute(display_name=...)` for exact. Postgres `entity_graph` indexed read. |
docs/architecture/second-brain-design.md:423:| `search-by-id` | every agent: resume context from a known id | v1.0 | `(id: str, tenant_id: str)` | `EntityRef \| None` | sub-second | Direct filesystem read after Postgres id→path lookup. |
docs/architecture/second-brain-design.md:424:| `search-by-relationship` | Janitor (v1.0): all Candidates linked to Brief X for dedup | v1.0 | `(from_id: str, link_type: str, tenant_id: str)` | `List[EntityRef]` | few seconds | Postgres `entity_graph` traversal; one-hop only in v1.0, multi-hop deferred to graph view v1.2 |
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:427:| `update-entity` | Concierge (v1.0): append conversation note to Candidate page | v1.0 | `(id: str, section: str, content: str, tenant_id: str)` | `EntityRef` | few seconds | Targets the `<!-- BEGIN auto:{section} -->` block per §2.2.1; preserves frontmatter; rewrites backlinks if `display_name` changes; `hh_decision_*` called |
docs/architecture/second-brain-design.md:428:| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
docs/architecture/second-brain-design.md:429:| `list-by-type-and-tenant` | Sourcing Scout (v1.0): enumerate Candidates for filtering; Brief Decoder (v1.1): enumerate open Briefs | v1.0 (Candidate, Client, Placement, Contact); v1.1 (Brief full enumeration) | `(entity_type: str, tenant_id: str, filters?: dict, limit?: int)` | `List[EntityRef]` | few seconds | Postgres-indexed; filtering matches `search-by-attribute` |
docs/architecture/second-brain-design.md:430:| `semantic-search-over-raw` | future Pulse (v1.2): "any inbox emails mentioning compliance risk in last 30 days" | **v1.2+ deferred** | `(query: str, raw_collection: str, tenant_id: str, date_range?: tuple)` | `List[RawChunkRef]` ranked by similarity | few seconds | The only operation where cortextOS's mmrag/ChromaDB substrate is a plausible candidate. v1.0/v1.1 don't need it — flagged in Q3 as the one place ADR-002 should leave a forward-compatible hook |
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:435:**Operations explicitly NOT in v1.0/v1.1 design scope:**
docs/architecture/second-brain-design.md:440:- Hard-delete-per-entity — v1.2+; v1.0/v1.1 hard-delete is only at tenant offboarding (Ultraplan §5.5)
docs/architecture/second-brain-design.md:452:- **Writers (v1.0):**
docs/architecture/second-brain-design.md:454:  - **Agents** write to `wiki/raw/{inbox-emails,calls,ats-snapshots}/`, `wiki/compiled/{candidates,clients,placements,people}/`, and `wiki/compiled/briefs/` (minimal v1.0). Writes are atomic (write-to-temp-then-rename, matching cortextOS's `src/utils/atomic.ts`).
docs/architecture/second-brain-design.md:459:  - **Git:** **Spec gap 2.4-A.** Neither master brief nor Ultraplan specifies whether `/vault/{tenant}/` is also a git repo. Obsidian users typically git-init their vaults. **Recommendation:** yes — initialize `/vault/{tenant}/.git/` at tenant provisioning (Ultraplan §5.5 step 2). Founder gets free history, blame, and rollback via Obsidian Git plugin. Agents do NOT commit; the founder commits manually or via a scheduled cron run by Janitor's nightly sweep. **Blocks v1.0 build:** no — git init is one line in `provision-tenant.sh`; commit cadence can be decided in Week 1.
docs/architecture/second-brain-design.md:461:#### 2.4.2 Postgres tables (v1.0)
docs/architecture/second-brain-design.md:492:  body_summary      TEXT,                                -- optional v1.0; reflect.ts v1.1 populates
docs/architecture/second-brain-design.md:493:  importance_score  REAL,                                -- optional v1.0; reflect.ts populates
docs/architecture/second-brain-design.md:522:  link_type         TEXT NOT NULL DEFAULT 'reference',   -- one of {reference, parent, related} — v1.0 only 'reference'
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:571:**No `agent_runs` table for v1.0.** The `agent_run_id` column on `decision_log` is the join key; "what did this agent do this run" is a `SELECT * FROM decision_log WHERE agent_run_id = ...`. A separate `agent_runs` table can be derived as a materialised view if v1.1 dashboards need it.
docs/architecture/second-brain-design.md:575:**v1.0 use:** voice corpus only. Ultraplan §6.1 line 314 says "samples/{n}.md — raw samples indexed for RAG retrieval (embedded with pgvector at capture time)" and line 322 says voice-loader.sh retrieves "the 3 most semantically similar past samples to the current task via pgvector cosine similarity."
docs/architecture/second-brain-design.md:606:**Not in v1.0 pgvector index:**
docs/architecture/second-brain-design.md:613:Per Q1.5, **zero use of cortextOS's `kb-*` surface by IFOS-owned agents in v1.0 or v1.1.** cortextOS's mmrag.py + ChromaDB + Gemini-embedding stack stays in place under `$HOME/.cortextos/ifos-v2/orgs/<org>/knowledge-base/` for any cortextOS-template agent that happens to be scaffolded in `ifos-v2` (debug, probe, worker spawn).
docs/architecture/second-brain-design.md:617:#### 2.4.5 Storage decision diagram (v1.0)
docs/architecture/second-brain-design.md:658:        Out of scope for v1.0/v1.1 reads (parallel and untouched):
docs/architecture/second-brain-design.md:674:| `search-by-relationship` | Postgres `entity_links` reverse lookup by `to_id` (or forward by `from_id`) | None — if Postgres is down, this operation fails loudly rather than falling back | One-hop only in v1.0. The Postgres-only choice is deliberate: filesystem grep over frontmatter `linked_entities` arrays would be slow and brittle. |
docs/architecture/second-brain-design.md:682:| `entity-history` | Postgres `decision_log` SELECT by `(tenant_slug, entity_id)` ORDER BY `created_at DESC` | None | v1.1 read; v1.0 writes via `hh_decision_*`. No filesystem fallback — decision_log is unique source. |
docs/architecture/second-brain-design.md:684:**Special attention to `search-by-name`:** the trigram index on `entities.display_name` (PostgreSQL `pg_trgm` + GIN) handles fuzzy matching natively. Query: `SELECT id, display_name FROM entities WHERE tenant_slug = $1 AND entity_type = $2 AND display_name % $3 ORDER BY similarity(display_name, $3) DESC LIMIT 10;`. Sub-second on tables up to ~10M rows; the 100-customer × ~50k-candidates-each scale of v1.0 fits comfortably.
docs/architecture/second-brain-design.md:727:**Spec gap 2.6:** none of this is in the master brief. **Recommended resolution:** adopt the mechanism above verbatim; document in a `docs/architecture/vault-concurrency.md` companion file in Week 1 (before agent code starts). **Blocks v1.0 build:** no — concurrency code is a v1.0 build artefact, not a Week 0 prerequisite, but the design needs to land before the first multi-agent test in week 5.
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:767:**Read:write ratio per agent (rough estimate, v1.0):**
docs/architecture/second-brain-design.md:774:| Sourcing Scout | 50:1 | reads briefs + candidate pool to filter; writes only shortlists |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:780:**Peak concurrent tenants on shared infra (v1.0):** 3-6 (Product Spec §3 first three paid pilots target). The shared Postgres + RLS model (Ultraplan §5.1 line 226) handles this trivially.
docs/architecture/second-brain-design.md:782:**Decision-log volume:** every agent run produces 1-3 `decision_log` rows (`hh_decision_trigger`, `hh_decision_output`, optionally `hh_decision_action` when human responds). At 6 v1.0 agents × ~10 runs/agent/day × 3 tenants × 3 rows = ~540 rows/day per shared Postgres instance. Trivial volume; the table needs hash partitioning (per Ultraplan §5.1) primarily for query performance at v1.2+ scale, not v1.0 write throughput.
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:894:| **v1.0 minimum effort estimate** | ~11-13 days. Breakdown: 12 wrappers × 0.25 day = 3 days; Node CLI + dispatch = 1 day; library (12 ops, concurrency, frontmatter parse/write) = 4-5 days; Postgres migrations = 1 day; pgvector voice integration = 1 day; concurrency tests = 1-2 days. | ~14-17 days. Adds: MCP server scaffolding + tool registration + JSON-RPC handling + PM2 integration + multi-tenant connection-identity validation. The library effort is the same; the server adds ~3-4 days. | ~9-11 days **IF R1**. Under R2, **probably impossible without renderer changes** — adds ~5 days for renderer modification + skill injection logic + per-agent install path. Total under R2: ~14-16 days, **and** undermines R2's clean-separation promise. |
docs/architecture/second-brain-design.md:913:- **Persistent server state.** Option β's long-running process could cache hot reads, hold prepared statements, maintain pgvector connection pools. Option α pays a fresh Node startup per call (~80-200ms). For v1.0 expected volume (Concierge ~10 lifecycle events/day per tenant × 3 tenants × 5 wiki reads each = 150 calls/day per machine), the cumulative startup cost is ~30 seconds/day. Acceptable. **If hot-path latency becomes a constraint at v1.2+**, we can introduce a persistent CLI daemon (`wiki-cli --daemon`) that pre-warms — a future optimisation without changing the agent surface.
docs/architecture/second-brain-design.md:914:- **Streaming.** Not a v1.0 need; if ever needed, add an `wiki-stream-*.sh` wrapper with line-delimited JSON output. No interface change for existing ops.
docs/architecture/second-brain-design.md:924:**v1.0 build day estimate for Option α: 11-13 days.** Fits master brief §5.5's weeks 11-13 allocation. Detail in §3.4 below.
docs/architecture/second-brain-design.md:930:> v1.0 minimum (weeks 11-13) — `bus-overrides/kb-*.sh` shadow + `wiki/lib/{ingest,search}.ts` — agents can write and search but no UI yet
docs/architecture/second-brain-design.md:936:| "bus-overrides/`kb-*.sh` shadow" | "bus-overrides/`wiki-*.sh` parallel surface (9 wrappers v1.0 + 1 v1.1 stub)" |
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
docs/architecture/second-brain-design.md:954:**Does the v1.0 brain build shift in scope or timing?**
docs/architecture/second-brain-design.md:964:| ID | Where | What's missing | Recommended resolution | Blocks v1.0? |
docs/architecture/second-brain-design.md:973:| **2.4-B** | Ultraplan §5.1 line 227 groups entity index + adjacency under "`entity_graph`" | Single-table model insufficient for the JSONB GIN + trigram + adjacency mix v1.0 needs | Split into `entities` + `entity_links` per §2.4.2. Update master brief §3.3 / Ultraplan §5.1 wording. **Roll into Week 0 Day 4 Postgres provisioning.** | **Tight** — Day 4 of Week 0 (this week). |
docs/architecture/second-brain-design.md:976:| **3.4-A** | Master brief §5.5 (lines 416-420) v1.0 brain wording | Says "shadow four files" — incorrect per Q1.5 | Rewrite per §3.4 of this design: "9 `wiki-*.sh` parallel wrappers + Postgres entities/entity_links/decision_log + pgvector voice." Bundles with ADR-002 atomic correction commit. | No — wording change, not work change. |
docs/architecture/second-brain-design.md:979:**Five gaps are already resolved inline in this design** (2.1-B, 2.1-C, 2.2-A, 2.2-B, 2.6 with mechanisms in §2.6.x). **Three need master-brief / Ultraplan edits in the atomic correction commit** (2.1-A wording reconciliation, 2.4-B / 3.4-B Postgres table-rename, 3.4-A v1.0 brain wording rewrite). **Two are Week-1 prerequisite artefacts** (§1.7-A renderer ADR-003 + `agent-bundle-renderer-design.md`; 2.6 companion `vault-concurrency.md`). **Two are operational defaults** that the founder can either ratify or override at any later point (2.4-A git init at provisioning; 2.4-C `gemini-embedding-001` model choice).
docs/architecture/second-brain-design.md:983:**Master brief §5.5's v1.0 minimum brain build stays at weeks 11-13, but the scope is materially clarified.** The "shadow four files + 2 .ts files" framing is replaced by "9 wiki-*.sh parallel wrappers + 9 wiki/lib/*.ts modules + 4 Postgres tables with RLS + pgvector for voice samples." Total v1.0 effort: ~11-13 person-days, fitting the 15-day budget. **Three Week-1 prerequisites move into focus:** ADR-003 renderer design (without it, no IFOS agent can run), `vault-concurrency.md` companion document (without it, the `flock`+Postgres-optimistic-concurrency code can't be reviewed), and `agents/_shared/{voice-loader,hook-helpers}.sh` (without these, the wiki library has no calling conventions). **One Day-4 (this week) tightening:** the Postgres schema migration from `entity_graph` (single table) to `entities` + `entity_links` (two tables) is part of the master brief §6 Day 4 infra task, not deferred. v1.2 graph view and v2.0 LoRA scale-tier are forward-compatible under the chosen Option α with no architectural changes.
packages/agents-runtime/_shared/common-vault.json:36:      "description": "Queue directory written by autosend_spot_check_enqueue per autosend-safety-policy §4."
agents/recruitment/janitor/agent.md:6:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:22:### Cron (v1.0)
agents/recruitment/janitor/agent.md:31:### Manual trigger (v1.0 — operator convenience)
agents/recruitment/janitor/agent.md:59:| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:79:12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/janitor/agent.md:128:7. LinkedIn enrichment (candidates; v1.1 via Proxycurl)
agents/recruitment/janitor/agent.md:129:   → at v1.0: skipped (LinkedIn deep data deferred to W4 polish; Proxycurl
agents/recruitment/janitor/agent.md:141:     (voice corpus + tone rules; ESC_VOICE_DRIFT if classifier <0.75)
agents/recruitment/janitor/agent.md:168:   → exit code 0 (or 1 if Gate-B missed for 3 consecutive runs → ESC_GATE_B_MISS)
agents/recruitment/janitor/agent.md:177:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:187:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint; per Day-19 catalogue add at `escalation-codes.md` line 184) OR `ESC_DUPLICATE_DETECTED` (merge-confidence reject; existing line 127) per the failed condition. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (line 163) is NOT used by Janitor — that code is reserved for vertical-schema field-constraint violations at write-time.
agents/recruitment/janitor/agent.md:195:Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
agents/recruitment/janitor/agent.md:197:Failing either threshold for 3 consecutive runs → fire `ESC_GATE_B_MISS` → flag for operator review (heuristic tuning may be needed; not a kill).
agents/recruitment/janitor/agent.md:210:| `ESC_VOICE_DRIFT` | Tacit-note narrative voice classifier <0.75 (after 3 retries) | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:212:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (section count or per-section citation missing in day-30 report) | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:214:| `ESC_GATE_B_MISS` | Either independent Gate-B threshold (dedup <15% OR field-completeness <10%) missed for 3 consecutive runs. NOT a composite — see §5 Gate B for the two-threshold rule. | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:219:- `ESC_VOICE_DRIFT_TENANT` — fired by nightly voice-drift cron (per `escalation-codes.md` line 170-175 trigger: ≥N `ESC_VOICE_DRIFT` rows from same tenant in rolling 7d window). Janitor only fires the per-run `ESC_VOICE_DRIFT`; aggregate `_TENANT` rollup is handled by the canary not Janitor.
agents/recruitment/janitor/agent.md:222:- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction
agents/recruitment/janitor/agent.md:235:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:237:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/janitor/agent.md:279:| Q5 | Day-30 report distribution path — vault only OR also forwarded to tenant's hiring leader via email? | v1.0: vault only. v1.1: opt-in email forward via Concierge. |
agents/recruitment/janitor/agent.md:284:1. **Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0.** Estimate 1 week for the MCP server, 1 week for the agent itself (per ULTRAPLAN A2 line 513).
docs/specs/_archive-build-handoff.md:3:**Document type:** Operational handoff. Everything Claude Code needs to know to start the v1.0 build on top of CortexOS without re-deriving context.
docs/specs/_archive-build-handoff.md:185:See `docs/ULTRAPLAN.md` §9 for the 14-week v1.0 sprint plan.
docs/specs/_archive-build-handoff.md:239:**The Ultraplan assumes primitives 1, 4, 5 are working at v1.0 start; 2, 3, 6, 7 may land during the build window.** Your audit either confirms this or triggers a re-cut of §9 of the Ultraplan.
docs/specs/_archive-build-handoff.md:241:Also Day 1: have your first design-partner sales conversation. The Ultraplan §10 risk register lists "no signed LOI by end of week 0" as a v1.0-killer risk. Sales conversations start now.
docs/specs/_archive-build-handoff.md:255:Also Day 3: confirm Brain UI v1.0 scope is "the minimal what-did-the-agents-do-today view" — not a full dashboard rebuild. Per Business Plan §5.3 this view extends CortexOS's existing Next.js dashboard rather than replaces it.
docs/specs/_archive-build-handoff.md:279:- The explicit condition under which v1.0 stops shipping (e.g., "If after 3 pilots the average Gate B revenue uplift is <£20k/year per tenant, the wedge is dead and we pivot")
docs/specs/_archive-build-handoff.md:367:If you ever want to see what `/onboarding` does, run it inside `~/cortextos` in a sandbox session — but don't commit any of its output. The Intel Force OS repo has its own onboarding shape (per Business Plan §5.4 / Ultraplan §5.5) which is what you build into the wizard at v1.0.
docs/specs/_archive-build-handoff.md:371:## 5. The agent build order — v1.0 only
docs/specs/_archive-build-handoff.md:373:Per Ultraplan §9, v1.0 ships six agents in the Starter and Boutique tiers. In order:
docs/specs/_archive-build-handoff.md:381:| 5 | **Sourcing Scout** | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
packages/agents-runtime/_shared/common-base.json:26:      "description": "Vertical adapter pinned at bundle author time. Single value in v1.0."
packages/agents-runtime/_shared/common-base.json:41:      "description": "Anthropic model ID. Default sonnet for v1.0 6-agent fleet."
docs/operations/codex-round-2-handoff.md:77:| 6 | `docs/decisions/autosend-safety-policy.md` | tier contradiction + legal placeholder | LIKELY REJECT — these are founder-decision-bound (D1/D2/D3) and content unchanged |
docs/operations/codex-round-2-handoff.md:82:| 11 | `docs/decisions/v1.0-kill-criterion.md` | Trigger 1 date + Trigger 2 CLI + Trigger 4 threshold | RATIFY (all three fixed) |
docs/operations/codex-round-2-handoff.md:211:  docs/decisions/autosend-safety-policy.md
docs/operations/codex-round-2-handoff.md:216:  docs/decisions/v1.0-kill-criterion.md
docs/operations/codex-round-2-handoff.md:288:**Sub-case 2a: Same issue as Round 1** — incorporation didn't actually fix the root cause. Escalate to founder; reopen as a fresh issue. Likely candidates: autosend-safety-policy (D1 + D3 unresolved); v0.2 supplement (D3 unresolved).
docs/operations/codex-round-2-handoff.md:396:6. **Diagnostic agent build slice begins** — first ratified-foundation v1.0 agent
packages/agents-runtime/_shared/common-ats.json:5:  "description": "Generic ATS interface — Bullhorn-only in v1.0 per bullhorn-integration-path.md §4 Sub-decision C; extensible to other ATSes in v1.1+. Per PRODUCT-SPEC §5.3 line 361.",
packages/agents-runtime/_shared/common-ats.json:12:      "description": "Single value in v1.0 per Sub-decision C; v1.1+ may add jobadder/vincere/etc."
docs/specs/PRODUCT-SPEC.md:101:#### R5. Sourcing Scout (daytime form) — request-response sourcing during the day
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:400:| 3 | Inter-agent file bus — agents hand work to each other via shared directories | Brief Decoder → Sourcing Scout → Concierge handoff; Triage → specialist-agent routing |
docs/specs/PRODUCT-SPEC.md:467:### 9.1 v1.0 (now → end of Q3 2026) — the closeable front office
docs/specs/PRODUCT-SPEC.md:476:- Sourcing Scout (daytime form)
docs/specs/PRODUCT-SPEC.md:486:3. **Night Sourcer** (2 weeks) — overnight extension of Sourcing Scout
docs/specs/PRODUCT-SPEC.md:526:5. **Sourcing Scout (daytime)** — "Shortlist in 15 minutes instead of by end of week."
packages/agents-runtime/_shared/common-target-patch.json:5:  "description": "Tenant's commercial sweet spot: sectors, geography, deal sizes, allow/block lists. Read by Sourcing Scout (W9) + Diagnostic (W3-4). Per PRODUCT-SPEC §5.3 line 363.",
packages/agents-runtime/_shared/common-target-patch.json:38:      "description": "Bands surface in Diagnostic ICP scoring + Sourcing Scout shortlist filtering."
docs/build-brief/00-MASTER-BRIEF.md:119:| 7 | Multi-agent orchestrator | `orchestrator` template + file-bus handoff contract | Brief Decoder → Sourcing Scout → Concierge pipeline lives here |
docs/build-brief/00-MASTER-BRIEF.md:167:IFOS implements its second brain as a **parallel system**, not by shadowing cortextOS's stock knowledge base. cortextOS's `bus/kb-*.sh` files (`kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh` at SHA `c21fbfe`) remain untouched and continue to serve cortextOS-template agents. IFOS agents invoke a parallel wrapper surface at `packages/brain/bus-overrides/wiki-*.sh` (9 v1.0 + 1 v1.1 stub) that dispatches to `packages/brain/wiki/lib/` against Postgres + filesystem markdown. The §3.1 "four `bus/kb-*.sh` shadow points" edit-exception is unused — IFOS does not edit any file under `packages/harness/cortextos/`. See `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` + `docs/architecture/second-brain-design.md` for the full design.
docs/build-brief/00-MASTER-BRIEF.md:413:| **v1.0 minimum** | Weeks 11–13 (Ultraplan §9) | 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; **no Brain UI yet**. Total v1.0 effort ~11-13 person-days. |
docs/build-brief/00-MASTER-BRIEF.md:427:- **Humans write to `compiled/*.md`.** Via the Brain UI's markdown editor (v1.2+); via direct git for the founder in v1.0–v1.1.
docs/build-brief/00-MASTER-BRIEF.md:464:- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation.
docs/build-brief/00-MASTER-BRIEF.md:477:- [ ] `docs/decisions/autosend-safety-policy.md` — categorical list of what may auto-send vs draft-only per tier, standing-authorisation contract per agent, escalation cascade, pilot-agreement liability language
docs/build-brief/00-MASTER-BRIEF.md:478:- [ ] `docs/decisions/v1.0-kill-criterion.md` — the explicit condition under which v1.0 stops shipping (e.g., "If after 3 pilots the average Gate B revenue uplift is <£20k/year per tenant, the wedge is dead and we pivot")
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:568:**Change 2 — Decision logging is enforced.** Three required calls per agent run:
docs/build-brief/00-MASTER-BRIEF.md:580:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/build-brief/00-MASTER-BRIEF.md:584:- `ESC_BRIEF_AMBIGUITY` — Brief Decoder cannot confidently shortlist
docs/build-brief/00-MASTER-BRIEF.md:591:### 8.2 The build order — v1.0 only
docs/build-brief/00-MASTER-BRIEF.md:599:| 5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:698:        │  • Direct vendor API: Microsoft Graph delegated send, Proxycurl LinkedIn                   │
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/build-brief/00-MASTER-BRIEF.md:837:## 12. The risk register — the four that could kill v1.0
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
docs/build-brief/00-MASTER-BRIEF.md:862:6 in v1.0. Obsidian-style wiki + graph second brain replaces the stock cortextOS knowledge base
docs/build-brief/00-MASTER-BRIEF.md:960:From there, the build is just doing the work one day at a time: §6 this week, then Ultraplan §9 for the 14 weeks of v1.0, then Spec §9 for v1.0 → v2.0.
docs/operations/codex-round-2-remediation-prompt.md:205:      `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/operations/codex-round-2-remediation-prompt.md:282:       than "v1.0 default confirmed by Founder Decision D3".
docs/operations/codex-round-2-remediation-prompt.md:297:  FLAG 1 — autosend-safety-policy.md tier contradiction
docs/operations/codex-round-2-remediation-prompt.md:301:  > **Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0
docs/operations/codex-round-2-remediation-prompt.md:303:  > says v1.0 ships green + red only. These are contradictory until D1
docs/operations/codex-round-2-remediation-prompt.md:311:  FLAG 2 — autosend-safety-policy.md legal placeholder
docs/operations/codex-round-2-remediation-prompt.md:473:        docs/decisions/autosend-safety-policy.md \
docs/operations/codex-round-2-remediation-prompt.md:515:    - autosend-safety-policy.md §1 + §10: D1 + D2/D3 blocker annotations
docs/operations/codex-round-2-remediation-prompt.md:549:  - Resolve D1 autosend orange-tier v1.0 path
docs/operations/codex-round-2-remediation-prompt.md:626:- FLAG 1: autosend-safety-policy.md §1 D1 annotation
docs/operations/codex-round-2-remediation-prompt.md:627:- FLAG 2: autosend-safety-policy.md §10 D2+D3 annotation
docs/operations/seedlegals-engagement-queries.md:68:> 1. **Service scope:** SaaS-delivered AI agent fleet for UK recruitment agencies (Bullhorn ATS integration; bounded action set defined in autosend-safety-policy attached as Appendix A).
packages/agent-renderer/tests/fixtures/test-agent/README.md:4:tests. NOT a v1.0 production agent. Used only by `vitest` runs + manual
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:7:# ESC_VOICE_DRIFT row emitted, draft NOT written to vault.
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:69:  - escalation_code: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:87:    - "ESC_VOICE_DRIFT"
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:26:**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:34:**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:42:**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:54:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:68:**v0 limitation:** competitor inference requires scanning LinkedIn employee employment-history for other-recruitment-agency names — needs Proxycurl-style profile data.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:78:**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:26:**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:34:**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:42:**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:54:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:68:**v0 limitation:** competitor inference requires scanning LinkedIn employee employment-history for other-recruitment-agency names — needs Proxycurl-style profile data.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:78:**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.
docs/operations/codex-ratification-execution-plan.md:130:| 8 | autosend-safety-policy | `docs/decisions/autosend-safety-policy.md` | A |
docs/operations/codex-ratification-execution-plan.md:140:| 13 | v1.0-kill-criterion | `docs/decisions/v1.0-kill-criterion.md` | A |
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
docs/operations/codex-ratification-execution-plan.md:427:- **Multi-model ratification (e.g., adding Gemini)** — v1.0 is Claude + Codex per master brief §10. Multi-model is v2.0+ if signal justifies.
docs/operations/codex-ratification-execution-plan.md:428:- **Automated CI Codex review on PR** — manual founder-triggered for v1.0. CI integration is a v1.1+ optimisation; the manual loop is enough at this scale.
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:77:| LinkedIn integration (Proxycurl, etc.) | Requires founder commercial action (Proxycurl signup ~£50/mo); LinkedIn paths remain stubbed; fixture 02 verifies graceful degradation already |
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:90:- **Do NOT** sign up for any paid service (Proxycurl, etc.) — founder gates external spend
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-option-c-diagnostic-end-to-end.md:283:- Recommendations for Week-4 polish (weak sections, voice classifier wiring, LinkedIn integration if Proxycurl signed up)
docs/operations/goal-option-c-diagnostic-end-to-end.md:309:| LLM generates §12 with banned phrase | V5 fails; retry up to 3x; if still failing, ESC_VOICE_DRIFT row + report blocked (matches fixture 99); record as known limitation, defer voice tuning to Week-4 polish. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:330:- Any external service requiring paid signup (Proxycurl, OpenAI tier, etc.)
docs/operations/goal-option-c-diagnostic-end-to-end.md:402:  - [LinkedIn integration via Proxycurl signup]
docs/operations/codex-round-2-autonomous-prompt.md:97:For autosend-safety-policy.md (Tier 1 item #6) and v0.2 supplement (item 
agents/recruitment/diagnostic/cycle.sh:32:# Proxycurl deep-data integration deferred to W4 polish per ADR-005.
agents/recruitment/diagnostic/cycle.sh:118:# data deferred to W4 (Proxycurl). Voice classifier gate skipped at v0.
agents/recruitment/diagnostic/cycle.sh:163:    '{"escalation_code":"ESC_AGENT_OUTPUT_SHAPE","agent_name":"diagnostic","shape_rule_violated":"non_empty_output","expected_value":"non-empty stdout","actual_value":"empty"}' >/dev/null
docs/_supplementary/technical-strategy-v2.md:456:Technical lift to support this: the Configuration Center already handles tenants. White-label is a CSS/domain layer plus a "parent tenant" concept in the DB. Maybe two weeks of work. Do it in v1.2, pitch it at v1.0.
docs/operations/founder-legal-setup-guide.md:229:> Would you provide a quote? Happy to share more about our autosend-safety-policy on a call.
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:22:7. **`docs/decisions/v1.0-kill-criterion.md`** §2 Triggers 1-10 (deadline awareness) + §3 (authority structure)
docs/operations/goal-week-3-polish-and-scaffold.md:24:9. **`docs/decisions/autosend-safety-policy.md`** §2-§4 (4-tier model + 29 action types) + §10 (pilot-agreement liability)
docs/operations/goal-week-3-polish-and-scaffold.md:30:15. **`docs/verticals/recruitment/vertical-schema.yaml`** (8 v1.0 entities + agent R/W matrix)
docs/operations/goal-week-3-polish-and-scaffold.md:33:After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Six v1.0 agents: [list with weeks]. ULTRAPLAN §8.1 agent line ranges: [A1 lines 495-505, A2 lines 507-514, ...]. Week-3 scope confirmed. Ready to begin Step 1."**
docs/operations/goal-week-3-polish-and-scaffold.md:50:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:51:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:52:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:53:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:93:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:105:| Proxycurl signup | Founder commercial action; gated on founder decision (cost ~$39/mo); if founder approves mid-week, wire LinkedIn deep data into Diagnostic |
docs/operations/goal-week-3-polish-and-scaffold.md:212:   - **Retry:** if response shape malformed, retry once; if still bad, fall back to deterministic logic + emit `ESC_VOICE_DRIFT` warning row.
docs/operations/goal-week-3-polish-and-scaffold.md:217:   - Tone-rule violation in LLM output → retry then ESC_VOICE_DRIFT
docs/operations/goal-week-3-polish-and-scaffold.md:292:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:294:- `v1.0-kill-criterion.md` Trigger 3 (JANITOR-BULLHORN-AUTH-W5)
docs/operations/goal-week-3-polish-and-scaffold.md:301:- **Build wave:** W5 per master brief §8.2 line 596
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:330:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:336:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:343:- **§6 Escalation codes:** ESC_BULLHORN_WRITE_FAIL, ESC_VOICE_DRIFT, ESC_SCHEMA_VIOLATION, ESC_FIELD_EXTRACTION_LOW_CONFIDENCE.
docs/operations/goal-week-3-polish-and-scaffold.md:344:- **§7 Voice + tone:** tacit-note is consultant-voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:358:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:359:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:365:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:373:- **§7 Voice + tone:** chase drafts are voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:381:### DAY 19 — Sourcing Scout + Concierge agent.md scaffolds (Steps 11-12)
docs/operations/goal-week-3-polish-and-scaffold.md:386:- ULTRAPLAN §8.1 A5 lines 547-558 (Sourcing Scout spec)
docs/operations/goal-week-3-polish-and-scaffold.md:387:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:388:- `bullhorn-integration-path.md` §4.1 (Sourcing Scout's Bullhorn read surface)
docs/operations/goal-week-3-polish-and-scaffold.md:389:- `vertical-schema.yaml` §3 agent_access_matrix Sourcing Scout row
docs/operations/goal-week-3-polish-and-scaffold.md:393:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:397:- **§4 Workflow:** ~10 steps. Brief fetch → keyword extraction → Bullhorn candidate search (filtered) → LinkedIn search (via Proxycurl or equiv) → semantic ranking → confidence scoring → match rationale generation → report assembly.
docs/operations/goal-week-3-polish-and-scaffold.md:400:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_LINKEDIN_AUTH, ESC_RATE_LIMIT_HIT, ESC_BRIEF_UNDERSPECIFIED.
docs/operations/goal-week-3-polish-and-scaffold.md:402:- **§8 Build prerequisites:** Bullhorn MCP read + LinkedIn integration (Proxycurl signup OR LinkedIn API partner-tier) + ranking model (LLM-based or embedding-based).
docs/operations/goal-week-3-polish-and-scaffold.md:403:- **§9 Open questions:** 4-6 covering ranking model choice, max match list size, LinkedIn coverage at v1.0.
docs/operations/goal-week-3-polish-and-scaffold.md:407:Commit: `decision(pre-build): agents/recruitment/sourcing-scout/agent.md — output contract per ULTRAPLAN §8.1 A5`
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:414:- `autosend-safety-policy.md` §4 (orange-tier model) + §3 (29 action types — Concierge's are bullhorn_note_customer_visible, candidate_state_change_email, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:420:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:423:- **§3 Output shape:** message drafts (email / Bullhorn note customer-visible / SMS as configured); decision-log audit row per send; orange-tier spot-check sampling at 1-in-N rate per autosend-safety-policy §4.
docs/operations/goal-week-3-polish-and-scaffold.md:427:- **§6 Escalation codes:** ESC_AUTOSEND_BLOCKED, ESC_VOICE_DRIFT, ESC_TONE_RULE_VIOLATION, ESC_APPROVAL_BRIDGE_TIMEOUT, ESC_BULLHORN_AUTH, ESC_LIFECYCLE_STATE_UNKNOWN.
docs/operations/goal-week-3-polish-and-scaffold.md:498:| LLM call rate-limited or 5xx (Step 4 runtime) | Built-in retry once; fall back to deterministic; emit ESC_VOICE_DRIFT warning |
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Founder approves Proxycurl signup mid-week | Wire LinkedIn deep data into Diagnostic via a new `@ifos/linkedin-proxycurl` package (similar to companies-house pattern); commit as separate slice; out of scope for goal §1 but high-value |
docs/operations/goal-week-3-polish-and-scaffold.md:529:- Any external service requiring paid signup (Proxycurl, Fathom, Xero dev, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:589:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:619:  Sourcing Scout (W9):    <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:640:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:643:  ✓ v1.0-kill-criterion.md Trigger 2 — Diagnostic ratified ahead of
docs/operations/goal-week-3-polish-and-scaffold.md:651:    - Diagnostic LinkedIn deep data (if Proxycurl signed up)
docs/operations/goal-week-3-polish-and-scaffold.md:660:  - <Proxycurl signup if approved>
docs/operations/goal-week-3-polish-and-scaffold.md:670:  - Approve Proxycurl signup ($39/mo)?
docs/operations/goal-week-3-polish-and-scaffold.md:683:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
agents/recruitment/diagnostic/tools.yaml:3:# Status: Proposed (Day-19; @ifos/web-scraper + @ifos/companies-house MCP connectors shipped Day 13; LinkedIn via web-scraper page-fetch in v0; Proxycurl deferred to W4 polish).
agents/recruitment/diagnostic/tools.yaml:54:      Read-only LinkedIn API (provider TBD at W3 build start — Proxycurl
agents/recruitment/diagnostic/tools.yaml:61:      - LINKEDIN_API_KEY  # provider-specific; Proxycurl or alternative
agents/recruitment/diagnostic/tools.yaml:69:      per_window: 100  # Proxycurl default per second
agents/recruitment/diagnostic/tools.yaml:137:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:140:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:182:  - linkedin_readonly_mcp_connector  # ~2 days at W3 start (Proxycurl wrapper)
agents/recruitment/diagnostic/validate.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
agents/recruitment/diagnostic/validate.sh:235:  #   - Voice classifier score <0.75 (V3) → ESC_VOICE_DRIFT (warn, per
agents/recruitment/diagnostic/validate.sh:238:  #     length) → ESC_AGENT_OUTPUT_SHAPE (warn)
agents/recruitment/diagnostic/validate.sh:255:    ESC_CODE="ESC_VOICE_DRIFT"
agents/recruitment/diagnostic/validate.sh:257:    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"
packages/harness/cortextos/package-lock.json:1184:      "integrity": "sha512-HHMwmarRKvoFsJorqYlFeFRzXZqCt2ETQlEDOb9aqssrnVBB1/+xgTGtuTrIk5vzLNX1MjMtTf7W9z3tsSbrxw==",
packages/harness/cortextos/package-lock.json:1345:      "integrity": "sha512-4LqhUomJqwe641gsPp6xLfhqWMbQV04KtPp7/dIp0nzPxAkNY1AbwL5W0MQpcalLYk07vaW9Kp1PBhdpZYYcEw==",
packages/harness/cortextos/package-lock.json:2605:      "integrity": "sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==",
packages/harness/cortextos/package-lock.json:2640:      "integrity": "sha512-C8oWjPR3F81yljW9o5OxcWzfh6avkVwDD2VYdwIGqTkl+OGFISgypqzfu7dOe4QNLL2aqcWBmI3PMtLIK233lw==",
agents/recruitment/diagnostic/context.sh:10:# the first workflow step runs. Per master brief §8.1 Change 1: load voice
agents/recruitment/diagnostic/context.sh:29:#   - Missing voice corpus → exit 1 with ESC_VOICE_DRIFT (no fallback for
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:170:        description: 'Ready to deploy v1.0',
agents/recruitment/diagnostic/agent.md:6:**Build wave:** v1.0 W3-4 per master brief §8.2 line 595 (row 1; anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`. **Drift flag:** Ultraplan §8.1 A1 (line 489) calls Diagnostic build wave 4-5; master brief line 595 calls it W3-4. Master brief is authoritative per CLAUDE.md (master brief wins on every conflict); W3-4 is the build wave for IFOS.
agents/recruitment/diagnostic/agent.md:22:### CLI (v1.0)
agents/recruitment/diagnostic/agent.md:39:- Bulk-mode (`ifosctl diagnostic --firm-list firms.csv`) — out of v1.0 scope
agents/recruitment/diagnostic/agent.md:47:**v0 source-coverage state:** Companies House data (§1, §10) is live via `@ifos/companies-house` MCP connector. Web-scraped pages (§2 footprint URLs, §8 careers-page pain signals) are live via `@ifos/web-scraper`. **LinkedIn deep-data sections (§3 job posts, §5 placement timeline, §7 employee skills, §9 competitor employee scan, §11 decision-maker profiles) currently use `@ifos/diagnostic-generator` stub-with-Companies-House-fallback citations** — Proxycurl integration deferred to W4 polish per ADR-005. Each LinkedIn-dependent section still emits ≥1 evidence link (per-section Gate A satisfied) by falling back to Companies House URLs, but the data depth is degraded vs the full-coverage W4 target.
agents/recruitment/diagnostic/agent.md:52:| 2 | **Online footprint** | Primary website URL + last-updated signal; LinkedIn company page URL + follower count + last-post recency; careers page URL + state (active / placeholder / 404) | Web-scraper (HEAD + first 200 lines) ✅ | + LinkedIn company-page Proxycurl fetch |
agents/recruitment/diagnostic/agent.md:55:| 5 | **Deal-size band proxy** | Salary bands or day-rate ranges in job posts; level distribution; recent placements via LinkedIn timeline | **v0: stub with Companies House fallback** | LinkedIn job posts + Proxycurl employee timeline |
agents/recruitment/diagnostic/agent.md:57:| 7 | **Tech stack signals** | Technologies named in JDs + LinkedIn skills aggregated from current employees + tools mentioned in director posts | **v0: stub with Companies House fallback** | LinkedIn JDs + Proxycurl employee profiles |
agents/recruitment/diagnostic/agent.md:81:Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. The v0 cycle.sh implementation uses a generator-level pattern: a single call to `@ifos/diagnostic-generator` (`packages/diagnostic-generator/`) fetches all 12 sections in one process; cycle.sh emits decision-log rows at draft-write + report-write + render-action boundaries, not per-section. Per-section data acquisition is internal to the generator package and not separately audited at v0; W4 polish may add per-section telemetry.
agents/recruitment/diagnostic/agent.md:107:     payload {escalation_code: ESC_AGENT_OUTPUT_SHAPE, ...}; exit 1
agents/recruitment/diagnostic/agent.md:109:   → v0 NOTE: per-§12 LLM voice classifier retry loop is NOT implemented in generator at v0 (§12 stub-via-Companies-House fallback). Voice classification happens at validate.sh V3 (single call to IFOS_VOICE_CLASSIFIER_URL when set; warn + exit 0 when unset/unreachable). W4 polish adds full LLM §12 pipeline with 3-retry classifier loop and explicit ESC_VOICE_DRIFT emission in the generator.
agents/recruitment/diagnostic/agent.md:118:     with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE for
agents/recruitment/diagnostic/agent.md:119:     section count / citation / length failures; ESC_VOICE_DRIFT for V3
agents/recruitment/diagnostic/agent.md:146:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
agents/recruitment/diagnostic/agent.md:161:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.
agents/recruitment/diagnostic/agent.md:163:Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
agents/recruitment/diagnostic/agent.md:173:| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:177:| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing OR generator produced empty stdout (Step 8 fallback) | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:197:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
agents/recruitment/diagnostic/agent.md:199:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/diagnostic/agent.md:216:| LinkedIn read-only via web-scraper | `packages/utilities/web-scraper/` | ✅ Shipped Day 13; 12/12 tests passing (Proxycurl deferred to W4) |
agents/recruitment/diagnostic/agent.md:240:| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | v0 (Day 13 ship) skipped Proxycurl: LinkedIn deep-data sections (§3, §5, §7, §9, §11) use Companies House fallback citations per §3 table. W4 polish slice will commercially sign up for Proxycurl OR alternative (PhantomBuster, Bright Data, scraper.api) and wire it in. Cost: ~$39/mo at low volume per Proxycurl pricing. |
agents/recruitment/diagnostic/agent.md:241:| Q4 | Gate B (30% discovery-call-to-report ratio) measured how? Manual tagging by consultant OR auto-detection via Bullhorn calendar links? | v1.0 manual tagging via Telegram resolution; v1.1 auto-detection. |
agents/recruitment/diagnostic/agent.md:243:| Q6 | Should §10 (recent activity) include Glassdoor reviews? ToS implications. | Per gotcha §6 below: caution; default OFF for v1.0; explicit founder enable for v1.1+. |
agents/recruitment/diagnostic/agent.md:249:3. **Glassdoor scraping — uncertain ToS compatibility.** Default OFF for v1.0. Per Q6 above.
agents/recruitment/concierge/README.md:14:The customer-comms agent. Highest-stakes v1.0 agent (XL complexity, 4 weeks build). 12 lifecycle events × 2 recipient roles = 24+ comms-template variants per tenant. Orange-tier autosend per `autosend-safety-policy.yaml` — consultant approval mandatory before send.
agents/recruitment/concierge/README.md:22:- `validate.sh` — Gate A (SLA 30 min + voice ≥0.75 per-position + addressee + tone-rule + PII + anti-duplicate) — most complex validator of v1.0
agents/recruitment/concierge/README.md:37:- D1-B: lightweight Telegram shim (recommended for v1.0 ship; ~1 day dev)
packages/harness/cortextos/tests/e2e/mock-codex.js:41:const WS_GUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
packages/harness/cortextos/tests/e2e/mock-claude.js:11:  console.log('Claude Code v1.0 (mock)');
agents/recruitment/concierge/agent.md:6:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:7:**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier (`gmail_outlook_send_to_candidate` or `bullhorn_note_customer_visible` depending on channel per autosend-policy.yaml lines 122-149). Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is a Gate B leading metric (warning + aggregated; NOT a Gate A hard-fail) per the same ULTRAPLAN line — making it a hard-fail would block legitimate delayed drafts caused by Bullhorn polling fallbacks. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:22:### Lifecycle webhook (v1.0 primary)
agents/recruitment/concierge/agent.md:116:15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/concierge/agent.md:190:   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries
agents/recruitment/concierge/agent.md:223:      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
agents/recruitment/concierge/agent.md:253:    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
agents/recruitment/concierge/agent.md:264:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
agents/recruitment/concierge/agent.md:275:Gate A failures fire `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` or `ESC_PII_LEAKAGE_RISK` or `ESC_CANDIDATE_DATA_INCOMPLETE` or `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint when voice threshold misses persistently) — all blocking; draft to `/tmp`; operator notified immediately.
agents/recruitment/concierge/agent.md:287:Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
agents/recruitment/concierge/agent.md:304:| `ESC_VOICE_DRIFT` | Voice classifier below position-specific threshold after 3 retries | warn (position 1-2) or **blocking** (position 3) | operator_chat_id (1-2) / operator + ifos_oncall (position 3) |
agents/recruitment/concierge/agent.md:310:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:311:| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% for 30 consecutive days | warn | founder + operator |
agents/recruitment/concierge/agent.md:315:Concierge has the largest escalation surface of any v1.0 agent — appropriate for the highest-stakes customer-facing comms.
agents/recruitment/concierge/agent.md:319:- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
agents/recruitment/concierge/agent.md:321:- `ESC_VOICE_DRIFT_TENANT` (direct firing) — that's fired by the nightly voice-drift cron per catalogue §2.5; Concierge fires only per-run `ESC_VOICE_DRIFT`.
agents/recruitment/concierge/agent.md:327:Steps 7-8 (draft generation + voice/tone validation) are the load-bearing voice surface of v1.0. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/concierge/agent.md:337:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
agents/recruitment/concierge/agent.md:344:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/concierge/agent.md:371:| `validate.sh` Gate A logic | Build at W10 start (~2 days; most complex of v1.0 validators) | ⏸ |
agents/recruitment/concierge/agent.md:390:| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
agents/recruitment/concierge/agent.md:391:| Q2 | Lifecycle event taxonomy — 12 events proposed in §3. Founder confidence each is correct + complete? Missing: "candidate referred to another role internally"? "Client cancelled brief"? | Founder review with first pilot consultants. Recommend: ship 12-event v1.0; expand v1.1+ based on real patterns. |
agents/recruitment/concierge/agent.md:394:| Q5 | Comms-template customisation — every tenant edits these. Per-event-type, per-recipient-role × per-tenant = 24+ templates each. Authoring tool? | v1.0: Markdown files at `/vault/<slug>/concierge-templates/<event>-<role>.md`. v1.1: Brain UI WYSIWYG editor. |
agents/recruitment/concierge/agent.md:395:| Q6 | Send-as-is rate (Gate B ≥60%) — measurement requires consultant to differentiate "approve" from "edit-and-approve". Brain UI v1.0 has no such control yet. Telegram-based approval? | Telegram-based for v1.0: `/approve <draft-id>` vs `/approve-edit <draft-id> <revised-body>`. Brain UI v1.1+ adds inline edit UX. |
agents/recruitment/concierge/agent.md:397:| Q8 | agent-identity email adapter (deferred) (v1.1+) — agent-identity sends. Should Concierge use agent-identity email adapter (deferred) for rejection emails (less personal pressure on consultant approving) or always tenant-identity? | v1.0: tenant-identity (Microsoft Graph / Gmail). v1.1+: agent-identity email adapter (deferred) experiment per tenant opt-in. |
agents/recruitment/concierge/agent.md:398:| Q9 | Cross-tenant lifecycle handling — what if a candidate placed at Tenant A's client interviews at Tenant B 6 weeks later? Bullhorn has separate tenant slugs; no cross-tenant leak. But operator visibility? | v1.0: strict tenant isolation (no cross-tenant data visibility). v1.1+: separate agent for tenant-network-graph if commercial demand. |
agents/recruitment/concierge/agent.md:406:4. **Microsoft Graph vs Gmail per-tenant** — each tenant chooses based on their existing email stack. v1.0 supports both; v1.1+ may add agent-identity email adapter (deferred).
agents/recruitment/concierge/agent.md:428:Until then: this document is a forward-looking scaffold. Concierge is the most complex v1.0 agent; its ratification cycles may surface architectural decisions not visible at scaffold stage. Founder review at each iteration is expected.
packages/agent-renderer/pnpm-lock.yaml:202:    resolution: {integrity: sha512-RVyzfb3FWsGA55n6WY0MEIEPURL1FcbhFE6BffZEMEekfCzCIMtB5yyDcFnVbTnwk+CLAgTujmV/Lgvih56W+A==}
packages/agent-renderer/pnpm-lock.yaml:208:    resolution: {integrity: sha512-bPb5AHZtbeNGjCKVZ9UGqGwo8EUu4cLq68E95A53KlxAPRmUyYv2D6F0uUI65XisGOL1hBP5mTronbgo+0bFcA==}
packages/agent-renderer/pnpm-lock.yaml:376:    resolution: {integrity: sha512-nU1yhmYutL+fQ71Kxnhg8uEOdC0pwEW9entHykTgEbna2pw2dkbFSMeqjjyHZoCmt8SBkOSvV+yNmm94aUrrqw==}
packages/agent-renderer/pnpm-lock.yaml:545:    resolution: {integrity: sha512-J3Yh9PzzF1Ovah2At+lHiGQdsYgArxBbXv/zHfSyaiFQEqvNv7DcW98pCrmdjCZBrqBiKrKKe2V+aaSGWuBe/w==}
packages/agent-renderer/pnpm-lock.yaml:569:    resolution: {integrity: sha512-nbJnQ8a3z1mtmrwImCYhc6BGpThAyYVRQxw9uKSKG4wR6aAYno9sVjJ0zaZcW9BPJX1GbrDPf+SvdWjgTuDmnw==}
packages/agent-renderer/pnpm-lock.yaml:599:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}
packages/agent-renderer/pnpm-lock.yaml:605:    resolution: {integrity: sha512-Boiz5+MsaROEWDf+GGEwF8VMHGhlUoQMtIPjOgA5fv4osupqTVnJteQNKJwUcnUog2G55jYXH7KZFFiJe0TEzQ==}
packages/agent-renderer/pnpm-lock.yaml:650:    resolution: {integrity: sha512-GhdPgy1el4/ImP05X05Uw4cw2/M93BCUmnEvWZNStlCzEKME4Fkk+YpoA5OiHNQmoS7Cafb8Xa3Pya8m1Qrzeg==}
packages/agent-renderer/pnpm-lock.yaml:871:    resolution: {integrity: sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==}
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:745:      goals: ['Ship v1.0', 'Hire 2 engineers', 'Write docs'],
packages/harness/cortextos/src/utils/ws-unix-client.ts:80:      .update(key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')
packages/mcp-connectors/companies-house/README.md:66:v0.1 — Diagnostic v1.0 dependency per `agents/recruitment/diagnostic/tools.yaml`.
packages/mcp-connectors/companies-house/pnpm-lock.yaml:186:    resolution: {integrity: sha512-RVyzfb3FWsGA55n6WY0MEIEPURL1FcbhFE6BffZEMEekfCzCIMtB5yyDcFnVbTnwk+CLAgTujmV/Lgvih56W+A==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:192:    resolution: {integrity: sha512-bPb5AHZtbeNGjCKVZ9UGqGwo8EUu4cLq68E95A53KlxAPRmUyYv2D6F0uUI65XisGOL1hBP5mTronbgo+0bFcA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:360:    resolution: {integrity: sha512-nU1yhmYutL+fQ71Kxnhg8uEOdC0pwEW9entHykTgEbna2pw2dkbFSMeqjjyHZoCmt8SBkOSvV+yNmm94aUrrqw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:529:    resolution: {integrity: sha512-J3Yh9PzzF1Ovah2At+lHiGQdsYgArxBbXv/zHfSyaiFQEqvNv7DcW98pCrmdjCZBrqBiKrKKe2V+aaSGWuBe/w==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:553:    resolution: {integrity: sha512-nbJnQ8a3z1mtmrwImCYhc6BGpThAyYVRQxw9uKSKG4wR6aAYno9sVjJ0zaZcW9BPJX1GbrDPf+SvdWjgTuDmnw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:583:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:589:    resolution: {integrity: sha512-Boiz5+MsaROEWDf+GGEwF8VMHGhlUoQMtIPjOgA5fv4osupqTVnJteQNKJwUcnUog2G55jYXH7KZFFiJe0TEzQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:634:    resolution: {integrity: sha512-GhdPgy1el4/ImP05X05Uw4cw2/M93BCUmnEvWZNStlCzEKME4Fkk+YpoA5OiHNQmoS7Cafb8Xa3Pya8m1Qrzeg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:821:    resolution: {integrity: sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==}
packages/harness/cortextos/dashboard/src/components/charts/chart-theme.ts:19:  '#EA580C', // orange
packages/harness/cortextos/dashboard/package-lock.json:101:      "integrity": "sha512-wajfB8KqzMCN2KGNFdLkReeHncd0AslUSrvHVvvYWuU8ghncRJoA50kT3zP9MVL0+9g4/67H+cdvBskj9THPzg==",
packages/harness/cortextos/dashboard/package-lock.json:242:      "integrity": "sha512-dTOdvsjnG3xNT9Y0AUg1wAl38y+4Rl4sf9caSQZOXdNqVn+H+HbbJ4IyyHaIqNR6SW9oJpA/RuRjsjCw2IdIow==",
packages/harness/cortextos/dashboard/package-lock.json:590:      "integrity": "sha512-yQ+qeuqohwhsNpoYDqqXaLllYAkPCP4vYdDrVo8FQXaAPfHWm1pG/Vm+jmGTA5JFS0BAIjookyapuJFY8F9PIw==",
packages/harness/cortextos/dashboard/package-lock.json:953:      "integrity": "sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==",
packages/harness/cortextos/dashboard/package-lock.json:1359:      "integrity": "sha512-zqjjo7RatFfFoP0MkQ51jfuFZBnVE2pRiaydKJ1G/rHZvnsrHAOcQALIi9sA5co5xenQdTugCvtb1cuf78Vf4g==",
packages/harness/cortextos/dashboard/package-lock.json:1752:      "integrity": "sha512-+29YMsqY2/9eFEiW93eqWnuLcWcufowXewwSNIT6UwZdUUCrM3oFjMWH/Z6/TMmb4hlFenmfAVbpWeup2jryCw==",
packages/harness/cortextos/dashboard/package-lock.json:2199:      "integrity": "sha512-RkhPPp2zrqDAQA/2jNhnztcPAlv64XdhIp7a7454A5ovI7Bukxgt7MX7udwAu3zg1DcpPU0rz3VV1SeaqvY4+A==",
packages/harness/cortextos/dashboard/package-lock.json:2309:      "integrity": "sha512-jCi/QKUM2r1Ju5a3J64TH2A5SpKAgh0LpknyqdQ4m6DCV0xJ2HG1xARRwNGPQfi1SLdLWZ1OJz6F4OMBBNiGJA==",
packages/harness/cortextos/dashboard/package-lock.json:2433:      "integrity": "sha512-0rFg/Rj2Q62NCm62jZw0QX7a3sz6QCQU0LpZdNrJX8byRGaGVTqbrW9jAoIAHyMQqsNpeZ81YgSizOt5WXq0Pw==",
packages/harness/cortextos/dashboard/package-lock.json:2696:      "integrity": "sha512-Il0+boE7w/XebUHyBjroE+DbByORGR9KKmITzbR7MyQ4akpORYP/ZmbhAr0DG7RmmBqoOnZdy2QlvajJ2QA59g==",
packages/harness/cortextos/dashboard/package-lock.json:3039:      "integrity": "sha512-HHMwmarRKvoFsJorqYlFeFRzXZqCt2ETQlEDOb9aqssrnVBB1/+xgTGtuTrIk5vzLNX1MjMtTf7W9z3tsSbrxw==",
packages/harness/cortextos/dashboard/package-lock.json:3294:      "integrity": "sha512-XW3t3qwbIwiSyRCggeO2zxe3KWaEbM0/kW9e8+0XpBgyKU4ATYzcVSMKteZJ1iukJ3HgHBjbg9P5YPRCVUxlnQ==",
packages/harness/cortextos/dashboard/package-lock.json:3785:      "integrity": "sha512-aGsCQImkDIqMyx1u4PrVlbi/krmDsQUs4zAcCV6M7yPcPev+RqVlndsJy9kJ8TLihW9TZ0kbDAzctpLn5o+lOg==",
packages/harness/cortextos/dashboard/package-lock.json:3904:      "integrity": "sha512-RfeSqcFeHMHlAWzt4TBjWOAtoW9lnsAGiP3GbaX9uVgTYYrMbVnGONEfUCiSss+xMHFl+eHZiipmA8WkQ7FuNA==",
packages/harness/cortextos/dashboard/package-lock.json:4367:      "integrity": "sha512-rq9s+JNhf0IChjtDXxllJ7g41oZk5SlXtp0LHwyA5cejwn7vKmKp4pPri6YEePv2PU65sAsegbXtIinmDFDXgQ==",
packages/harness/cortextos/dashboard/package-lock.json:4732:      "integrity": "sha512-3oSeUO0TMV67hN1AmbXsK4yaqU7tjiHlbxRDZOpH0KW9+CeX4bRAaX0Anxt0tx2MrpRpWwQaPwIlISEJhYU5Pw==",
packages/harness/cortextos/dashboard/package-lock.json:4794:      "integrity": "sha512-RKshQI1R3YQ+n9YJz2QQ147P66ELpa1FQEg20Dk8oW9t2KgLbpDLLp9aGZ7y8WHSshDknG0bknqGw5/tyCs5tw==",
packages/harness/cortextos/dashboard/package-lock.json:4803:      "integrity": "sha512-p2q/t/mhvuOj/UeLlV6566GD/guowlr0hHxClI0W9m7MWYkL1F0hLo+0Aexs9HSPCtR1SXQ0TD3MMKrXZajbiQ==",
packages/harness/cortextos/dashboard/package-lock.json:4812:      "integrity": "sha512-1W07cM9gS6DcLperZfFSj+bWLtaPGSOHWhPiGzXmvVJbRLdG82sH/Kn8EtW1VqWVA54AKf2h5k5BbnIbwF3h6w==",
packages/harness/cortextos/dashboard/package-lock.json:5217:      "integrity": "sha512-Vsv7kFaXm+ptHDMZ7izaRsP70GgrW9NBNGswt9OZaVBLlE0SNpDq8eu/VGXyF9r7M0azK3Wy7OlYXsuyYLFzHg==",
packages/harness/cortextos/dashboard/package-lock.json:5401:      "integrity": "sha512-z1HGKcYy2xA8AGQfwrn0PAy+PB7X/GSj3UVJW9qKyn43xWa+gl5nXmU4qqLMRzWVLFC8KusUX8T/0kCiOYpAIQ==",
packages/harness/cortextos/dashboard/package-lock.json:5558:      "integrity": "sha512-EmKO5V3OLXh1rtK2wgXRansaK1/mtVdTUEiEI0W8RkvgT05kfxaH29PliLnpLP73yYO6142Q72QNa8Wx/A5CqQ==",
packages/harness/cortextos/dashboard/package-lock.json:5666:      "integrity": "sha512-WzMx3mW98SN+zn3hgemf4OzdmyNhhhKz5Ay0pUfQiMQ3e1g+xmTJWp/pKdwKVXhdSkAEGIIzqeuWrL3mV/AXbA==",
packages/harness/cortextos/dashboard/package-lock.json:6562:      "integrity": "sha512-Ap6G0WQwcU/LHsvLwON1fAQX9Zp0A2Y6Y/cJBl9r/JbW90Zyg4/zbG6zzKa2OTALELarYHmKu0GhpM5EO+7T0g==",
packages/harness/cortextos/dashboard/package-lock.json:6608:      "integrity": "sha512-kVscqXk4OCp68SZ0dkgEKVi6/8ij300KBWTJq32P/dYeWTSwK41WyTxalN1eRmA5Z9UU/LX9D7FWSmV9SAYx6g==",
packages/harness/cortextos/dashboard/package-lock.json:6991:      "integrity": "sha512-buRG0fpBtRHSTCOASe6hD258tEubFoRLb4ZNA6NxMVHNw2gOcwHo9wyablzMzOA5z9xA9L1KNjk/Nt6MT9aYow==",
packages/harness/cortextos/dashboard/package-lock.json:7234:      "integrity": "sha512-SyHy3T1v2NUXn29OsWdxmK6RwHD+vkj3v8en8AOBZ1wBQ/hCAQ5bAQTD02kW4W9tUp/3Qh6J8r9EvntiyCmOOw==",
packages/harness/cortextos/dashboard/package-lock.json:7415:      "integrity": "sha512-6pEjquH3rqaI6cYAXYPcz9MS4rY6R4ngRgrgfDshRptUZIc3lw0MCIJIGDj9++mfySOuPTHB4nrSW99BCvOPIA==",
packages/harness/cortextos/dashboard/package-lock.json:7434:      "integrity": "sha512-CV9TW3Y3f8/wT0BRFc1/KAVQ3TUHiXmaAb6VW9vtiMFf7SLoMd1PdAc4W3KFOFETBJUb90KatHqlsZMWV+R9Gg==",
packages/harness/cortextos/dashboard/package-lock.json:7836:      "integrity": "sha512-upqt1SkGkODW9tsGNG5mtXTXtECizwtS2kA161M+gJPc1xdb/Ax629af6YrTwcOeQHbewrPNlE5Dx7kzvXTizA==",
packages/harness/cortextos/dashboard/package-lock.json:8375:      "integrity": "sha512-XmOWe7eyHYH14cLdVPoyg+GOH3rYX++KpzrylJwSW98t3Nk+U8XOl8FWKOgwtzdb8lXGf6zYwDUzeHMWfxasyg==",
packages/harness/cortextos/dashboard/package-lock.json:8449:      "integrity": "sha512-hRF04fqJIP8Abbkq5NKGN0Bbr3JxlQ+qhZufXVr0DvujKy93ZCbXZMHDL4EOtodSbCWxOqR8MS1tXA5hwqCXDg==",
packages/harness/cortextos/dashboard/package-lock.json:8818:      "integrity": "sha512-DBwtEWN2caHQ9/imiNeEA5ys1JoRtRfY3d7V9wkqtbycnAmTvRRmbHKDV4a0EYc678/dia0jrte4tjYwVBaZUA==",
packages/harness/cortextos/dashboard/package-lock.json:8830:      "integrity": "sha512-oSXzaWypCMHkPC3NvBEaPHf0KsA5mvPrOPgQWDsbg8n7orZ290M0BmC/jgRZ4vcJ6DTAhjrsSYgdsW/F+MFOBA==",
packages/harness/cortextos/dashboard/package-lock.json:9909:      "integrity": "sha512-C8oWjPR3F81yljW9o5OxcWzfh6avkVwDD2VYdwIGqTkl+OGFISgypqzfu7dOe4QNLL2aqcWBmI3PMtLIK233lw==",
packages/harness/cortextos/dashboard/package-lock.json:10004:      "integrity": "sha512-Z2dPnBnMUfyQfSQ+GBdsGa16hz35YmLmtTLhM169uW944hYL6xzTYkJjC07j+Wosz733pMWx0fgON3JNw1jJQA==",
packages/harness/cortextos/dashboard/package-lock.json:10060:      "integrity": "sha512-gjVS5hOP+M3wMm5nmNOucbIrqudzs9v/57bWRHQWLYklXqoXKrVfYW2W9+glfGsqtPgpiz5WwyEEB+ksXIx3gQ==",
packages/harness/cortextos/dashboard/package-lock.json:10770:      "integrity": "sha512-eNv+WrVbKu1f3vbYJT/xtiF5syA5HPIMtf9IgY/nKg0sWqzAUEvqY/xm7OcZc/qafLx/iO9FgOmeSAp4v5ti/Q==",
packages/harness/cortextos/dashboard/package-lock.json:11291:      "integrity": "sha512-tsaTIkKW9b4N+AEj+SVA+WhJzV7/zMhcSu78mLKWSk7cXMOSHsBKFWUs0fWwq8QyK3MgJBQRX6Gbi4kYbdvGkQ==",
packages/harness/cortextos/dashboard/package-lock.json:11427:      "integrity": "sha512-zaJYxz2FtcMb4f+g60KsRNFOpVMUyuJgA51Zi5Z1DOTC3S59+OQiVOzE9GZt0x72uBGWKsQIuBKeF9iusmKFsg==",
packages/harness/cortextos/dashboard/package-lock.json:11683:      "integrity": "sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==",
packages/harness/cortextos/dashboard/package-lock.json:11944:      "integrity": "sha512-3KS2b+kL7fsuk/eJZ7EQdnEmQoaho/r6KUef7hxvltNA5DR8NAUM+8wJMbJyZ4G9/7i3v5zPBIMN5aybAh2/Jg==",
packages/harness/cortextos/dashboard/package-lock.json:12172:      "integrity": "sha512-Fedw0aZvkhynoPYlA5WXrMCAMm+nSWdZt6lzJQ7Ok8S6Q+VsHmHpRWndVRJ8Be0ZbkfPc5LRYH+5XrzXcEeLRQ==",
packages/harness/cortextos/dashboard/package-lock.json:12342:      "integrity": "sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==",
packages/harness/cortextos/dashboard/package-lock.json:12437:      "integrity": "sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==",
packages/harness/cortextos/community/skills/officecli/SKILL.md:17:curl -L https://github.com/iOfficeAI/OfficeCLI/releases/download/v1.0.47/officecli-mac-arm64 \

codex
The broad search found the local source files and the scaffold itself. I’m narrowing to the exact line ranges now because this review hinges on citation accuracy and whether the agent invents fields/codes.
exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '535,560p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   535	- **MCP tools required:** Xero / QuickBooks / Sage (one of, per tenant), bank-feed connector
   536	- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
   537	- **External APIs:** Xero API or QuickBooks API or Sage API; bank feed via Open Banking (TrueLayer / Plaid UK)
   538	- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
   539	- **Gate B target:** tenant DSO at month-3 ≥ 12 days lower than month-0 baseline
   540	- **Build complexity:** **L** (2 weeks) — three accounting integrations × Open Banking is the work
   541	- **Gotchas:** Open Banking auth is a 90-day token; rotation logic is non-trivial. Bank feed reconciliation against invoice register is the hard logic; start with exact-amount matches and expand to fuzzy.
   542	
   543	#### A5. Sourcing Scout (daytime form) — request-response sourcing
   544	
   545	- **Build wave:** v1.0 (week 8–9)
   546	- **Always-on?** Tier 2 — request-response
   547	- **Trigger type:** Brain UI button, Telegram command, or webhook from a "new brief" event
   548	- **CortexOS primitives required:** None for the daytime form (Night Sourcer in v1.1 will use #6)
   549	- **MCP tools required:** Bullhorn (read for ATS passive matches), LinkedIn (via Proxycurl or similar), Reed.co.uk API, CV-Library API
   550	- **Shared modules required:** Voice loader (for the rationale narrative), decision log writer
   551	- **External APIs:** Proxycurl, Reed, CV-Library
   552	- **Gate A:** 5–15 candidates returned per brief; each has a working contact method; each has rationale ≥ 50 words; no candidate flagged "do not contact" in tenant vault
   553	- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)
   554	- **Build complexity:** **L** (2 weeks) — the multi-source aggregation logic is the work
   555	- **Gotchas:** LinkedIn rate limits via Proxycurl. Reed/CV-Library have separate auth and separate result schemas. Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it.
   556	
   557	#### A6. The Concierge — no candidate ghosted
   558	
   559	- **Build wave:** v1.0 (week 9–10)
   560	- **Always-on?** Tier 1 — persistent state across the candidate lifecycle

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
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "rg --files docs | rg 'master|brief|MASTER|BRIEF|week|IFOS|cortext'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/operations/goal-week-3-polish-and-scaffold.md
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/build-brief/00-MASTER-BRIEF.md
docs/_supplementary/planning-phase-brief.md

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '237,380p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   261	- **Payload fields:** `failure_type` (`session_expired` | `bot_detected_999` | `revoked_401`), `last_attempt_at`
   262	- **Recovery:** founder reauthenticates LinkedIn via Sourcing Scout admin flow
   263	
   264	#### `ESC_GMAIL_AUTH`
   265	- **Severity:** **blocking** — Concierge cannot send candidate emails; falls back to draft-only
   266	- **Trigger:** Google Workspace OAuth token refresh failed; Gmail send returns 401
   267	- **Phase:** `gating_failed`
   268	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   269	- **Payload fields:** `failure_type`, `last_attempt_at`, `affected_tenant_slug`
   270	- **Recovery:** founder reauthenticates Google Workspace OAuth
   271	
   272	#### `ESC_MS_GRAPH_AUTH`
   273	- **Severity:** **blocking** — Concierge Outlook send disabled; drafts-only
   274	- **Trigger:** Microsoft Graph OAuth refresh failed; Outlook sendMail returns 401
   275	- **Phase:** `gating_failed`
   276	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   277	- **Payload fields:** `failure_type`, `last_attempt_at`, `affected_tenant_slug`
   278	- **Recovery:** founder reauthenticates MS Graph OAuth
   279	
   280	#### `ESC_ACCOUNTING_AUTH`
   281	- **Severity:** **blocking** — Cash Conductor degraded (read-only Xero queries from cache; no reminders sent)
   282	- **Trigger:** Xero (or alt accounting provider) OAuth token refresh failed; API returns 401
   283	- **Phase:** `gating_failed`
   284	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   285	- **Payload fields:** `provider` (`xero` | `quickbooks` | `sage` | `freeagent`), `failure_type`, `last_attempt_at`
   286	- **Recovery:** founder reauthenticates accounting OAuth
   287	
   288	#### `ESC_OPEN_BANKING_AUTH`
   289	- **Severity:** **blocking** — Cash Conductor cannot fetch latest bank-feed; falls back to last-known balance
   290	- **Trigger:** Open Banking PSD2 consent expired (90-day mandatory reauth) OR token refresh failed
   291	- **Phase:** `gating_failed`
   292	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   293	- **Payload fields:** `failure_type` (`consent_expired_90d` | `refresh_failed`), `consent_expires_at`, `bank_provider`
   294	- **Recovery:** founder completes Open Banking SCA reauthentication flow
   295	
   296	#### `ESC_OPEN_BANKING_TOKEN_AGING`
   297	- **Severity:** staged — info → warn → blocking as expiry approaches (per Cash Conductor agent.md §6)
   298	- **Trigger:** Open Banking PSD2 consent approaching 90-day expiry. Three stages:
   299	  - **≤30 days remaining:** info — non-urgent operator awareness; nightly health check emits this
   300	  - **≤14 days remaining:** warn — operator nudge to schedule reauth this week
   301	  - **≤7 days remaining:** blocking — Cash Conductor enters degraded mode (cached balance only; no fresh bank-feed reads); operator must complete SCA reauth before token expires
   302	- **Phase:** `gating_failed`
   303	- **Routing:** `operator_chat_id` (info + warn stages); ADD `ifos_oncall_chat_id` at blocking stage
   304	- **Payload fields:** `consent_expires_at`, `days_remaining`, `bank_provider`, `stage` (`info` | `warn` | `blocking`)
   305	- **Recovery:** founder schedules + completes Open Banking SCA reauth via tenant's bank login
   306	
   307	### 2.8 — Provider read/write failures (4 codes)
   308	Source: derived from v1.0 agent.md adapter call sites
   309	
   310	#### `ESC_BULLHORN_WRITE_FAIL`
   311	- **Severity:** warn
   312	- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
   313	- **Phase:** `gating_failed`
   314	- **Routing:** `operator_chat_id`
   315	- **Payload fields:** `endpoint`, `entity_type`, `entity_id`, `status_code`, `error_body_preview` (truncated 120 chars)
   316	
   317	#### `ESC_ACCOUNTING_WRITE_FAIL`
   318	- **Severity:** warn
   319	- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
   320	- **Phase:** `gating_failed`
   321	- **Routing:** `operator_chat_id`
   322	- **Payload fields:** `provider`, `endpoint`, `entity_type`, `status_code`, `error_body_preview`
   323	
   324	#### `ESC_PROVIDER_FETCH_FAIL`
   325	- **Severity:** warn
   326	- **Trigger:** Generic upstream provider read failure (Companies House, web-scraper, any non-Bullhorn-non-Accounting GET) after retry budget exhausted; distinct from rate-limit
   327	- **Phase:** `gating_failed`
   328	- **Routing:** `operator_chat_id`
   329	- **Payload fields:** `upstream` (e.g. `companies-house`, `web-scraper`, `linkedin-cache`), `endpoint`, `status_code`, `consecutive_failures`
   330	
   331	#### `ESC_SEND_FAIL`
   332	- **Severity:** warn — distinct from auth/rate-limit; the send itself failed at the protocol layer
   333	- **Trigger:** External send (Gmail / Outlook / Twilio / Telegram-to-customer) returned 5xx or transport error after retry budget
   334	- **Phase:** `gating_failed`
   335	- **Routing:** `operator_chat_id`
   336	- **Payload fields:** `channel` (`gmail` | `outlook` | `twilio` | `telegram`), `recipient_id_hash`, `error_class`, `attempts_made`
   337	
   338	### 2.9 — Auto-send orchestration (4 codes)
   339	Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics
   340	
   341	#### `ESC_AUTOSEND_ORANGE_PENDING`
   342	- **Severity:** info — distinct from ESC_AUTOSEND_NEEDS_REVIEW (which is the initial queue event)
   343	- **Trigger:** Orange-tier action has been pending operator response for ≥50% of declared `timeout` (heartbeat reminder before bridge timeout)
   344	- **Phase:** `action`
   345	- **Routing:** `operator_chat_id` (gentle reminder; no oncall)
   346	- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`
   347	
   348	#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
   349	- **Severity:** warn — orange action's approval window expired without response
   350	- **Trigger:** Orange-tier action exceeded its `timeout` (default PT4H) without operator approve/reject
   351	- **Phase:** `gating_failed`
   352	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (operator absent + commitment may need rerouting)
   353	- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
   354	- **Recovery:** action converts to manual reconciliation; operator handles offline
   355	
   356	#### `ESC_AUTOSEND_RACE`
   357	- **Severity:** warn — concurrency / state-change race
   358	- **Trigger:** A send is about to fire when the underlying state has changed in a way that should suppress it. Two canonical use cases:
   359	  - **Duplicate-payload race:** two agents attempted to send the same `payload_hash` within same tenant within `race_window_seconds` (default 60s); second attempt detected by `decision_log` UPSERT-conflict; second wins-suppressed (first sends; idempotency by payload_hash)
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

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '575,610p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '520,600p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

 succeeded in 0ms:
   520	|---|---|
   521	| The 9-agent consulting suite (Lead Hunter, Content Creator, Repurposer, etc.) | Different vertical, different prompts, different output contracts. Reference only. |
   522	| The v1 dashboard as a whole app | Replaced by `packages/dashboard-ext/` extending the cortextos dashboard. |
   523	| The v1 provisioning system | The 5-day onboarding wizard (Spec §5.2) is the new shape. |
   524	| `vault-syncer` (v1) | Needs to coordinate with the file-bus contract. Build fresh. |
   525	| `cc-invoke` | CortexOS PM2-supervised PTY replaces per-invocation-spawn. |
   526	
   527	### 7.3 The "skeleton-ready" principle
   528	
   529	Per founder pattern: build documentation at skeleton-ready level (SQL schemas, Python pseudocode, worked examples) before code.
   530	
   531	- Every agent bundle: `README.md` + `agent.md` (output contract first) before the four supporting files
   532	- Every MCP connector: `tools.yaml` + OpenAPI spec walkthrough before code
   533	- Every Postgres table: `CREATE TABLE` + RLS policy + indexes in `docs/architecture/postgres-schema.sql` before migration runs
   534	
   535	---
   536	
   537	## 8. The agent bundle v2 pattern
   538	
   539	Every agent — front-office and temp — is exactly these files. No exceptions.
   540	
   541	```
   542	agents/recruitment/{agent-name}/
   543	├── README.md                           # 2-min overview for humans
   544	├── agent.md                            # Output contract FIRST, then workflow, gates, escalation
   545	├── config.schema.json                  # Per-tenant config (extends common-*.json)
   546	├── tools.yaml                          # MCP servers + scopes + degraded modes
   547	├── validate.sh                         # Gate A — sources _shared/hook-helpers.sh
   548	├── context.sh                          # Hydrates CONTEXT via context-assembly API
   549	└── tests/
   550	    └── fixtures/
   551	        ├── 01-primary/                 # Happy path. The demo example.
   552	        │   ├── input.json
   553	        │   └── expected.md
   554	        ├── 02-edge-case-{name}/        # ≥1 required. From workflow analysis.
   555	        │   ├── input.json
   556	        │   └── expected.md
   557	        └── 99-voice-drift-canary/      # NEW IN V2 — every agent has one.
   558	            ├── input.json              # Same input, run weekly in CI
   559	            └── expected.md             # Output diffed against historical
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

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '374,470p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   391	- **Recovery:** agent re-drafts with violation removed; if persistent, escalates to tone_rule review
   392	
   393	#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
   394	- **Severity:** warn
   395	- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
   396	- **Phase:** `gating_failed`
   397	- **Routing:** `operator_chat_id`
   398	- **Payload fields:** `entity_type`, `field_name`, `extracted_value`, `confidence_score`, `source` (e.g. `companies-house`, `linkedin`, `cv-pdf`), `agent_name`
   399	
   400	#### `ESC_CANDIDATE_DATA_INCOMPLETE`
   401	- **Severity:** warn
   402	- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
   403	- **Phase:** `gating_failed`
   404	- **Routing:** `operator_chat_id`
   405	- **Payload fields:** `candidate_id`, `missing_fields` (list), `shortlist_id`, `brief_id`
   406	
   407	#### `ESC_ADDRESSEE_MISMATCH`
   408	- **Severity:** **blocking** — outbound send refused (whichever agent firing)
   409	- **Trigger:** Outbound recipient resolution failed — addressee does not match the entity whose lifecycle/event triggered the send. Two canonical use cases:
   410	  - **Cash Conductor:** chase/reminder/invoice addressee does not match Bullhorn placement client OR Xero contact (cross-system reconciliation failure between accounting + ATS)
   411	  - **Concierge:** lifecycle-event email recipient does not match the candidate_id whose state is changing (per ULTRAPLAN A6 line 566 verbatim "no candidates emailed under another's name")
   412	- **Phase:** `gating_failed`
   413	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   414	- **Payload fields:** `agent_name`, `mismatch_class` (one of `cash_conductor_xero_bullhorn` | `concierge_candidate_email` | future variant), plus class-specific fields: Cash Conductor → `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`); Concierge → `expected_candidate_bullhorn_id`, `actual_recipient_email`, `event_type`
   415	- **Recovery:** operator reviews; either reconciles manually OR updates one system to match
   416	
   417	#### `ESC_RECONCILIATION_AMBIGUOUS`
   418	- **Severity:** warn — Cash Conductor cannot confidently match incoming payment to a specific invoice
   419	- **Trigger:** Bank-feed payment line cannot be matched to a single Xero invoice; multiple candidates within tolerance
   420	- **Phase:** `gating_failed`
   421	- **Routing:** `operator_chat_id`
   422	- **Payload fields:** `payment_id`, `amount`, `payee_name_raw`, `candidate_invoice_ids` (list), `match_basis` (e.g. `amount_only`, `payee_partial`)
   423	
   424	#### `ESC_DNC_FILTER_HIT`
   425	- **Severity:** **blocking** — outbound (email / SMS / call) refused
   426	- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
   427	- **Phase:** `gating_failed`
   428	- **Routing:** `operator_chat_id`
   429	- **Payload fields:** `recipient_id_hash`, `dnc_list_source`, `dnc_match_reason` (e.g. `explicit_opt_out`, `previous_complaint`, `gdpr_objection`), `action_type_attempted`
   430	
   431	#### `ESC_CONCIERGE_SLA_MISS`
   432	- **Severity:** warn — aggregated to Gate B (not a per-event block)
   433	- **Trigger:** Concierge SLA breached. Three canonical sla_types:
   434	  - `brief_ack`: inbound brief not acknowledged within 4h (default)
   435	  - `customer_reply`: customer reply not actioned within 24h (default)
   436	  - `draft_generation`: lifecycle event → draft generated >30 min (per ULTRAPLAN A6 line 566; aggregated to Gate B per Concierge §1 disposition rather than per-event hard fail)
   437	- **Phase:** `gating_failed`
   438	- **Routing:** `operator_chat_id`
   439	- **Payload fields:** `brief_id` or `candidate_bullhorn_id` or `lifecycle_event_id` (per sla_type), `sla_type` (one of the three above), `sla_threshold_seconds`, `actual_elapsed_seconds`, `tenant_slug`
   440	
   441	#### `ESC_SCRIBE_SLA_MISS`
   442	- **Severity:** warn
   443	- **Trigger:** Scribe SLA breached (default: call summary rendered within 30 min of call end; Bullhorn note attached within 1h)
   444	- **Phase:** `gating_failed`
   445	- **Routing:** `operator_chat_id`
   446	- **Payload fields:** `call_id`, `sla_type` (`summary_render` | `note_attach`), `sla_threshold_seconds`, `actual_elapsed_seconds`, `tenant_slug`
   447	
   448	#### `ESC_LIFECYCLE_STATE_UNKNOWN`
   449	- **Severity:** warn — agent cannot determine entity state for downstream action
   450	- **Trigger:** Lifecycle state is ambiguous or outside the agent's known taxonomy. Two canonical use cases:
   451	  - **Janitor:** placement record has ambiguous lifecycle markers (e.g. start_date present but no end_date AND no `active` flag AND no recent activity); Janitor cannot safely tag or update
   452	  - **Concierge:** Bullhorn state transition is outside the 12-event v1.0 taxonomy (acknowledgement / prep / debrief / placement / rejection / withdrawal / on-hold / start-confirm / 7d-checkin / 30d-checkin / 90d-checkin / nurture); handler logs + skips draft
   453	- **Phase:** `gating_failed`
   454	- **Routing:** `operator_chat_id`
   455	- **Payload fields:** `agent_name`, `entity_type` (`placement` | `candidate_lifecycle_event`), `entity_id`, `ambiguity_class` (Janitor: e.g. `missing_end_date`, `stale_activity`; Concierge: e.g. `unknown_transition`, `out_of_taxonomy`), plus class-specific fields
   456	
   457	---
   458	
   459	## §3 — Reserved codes (not-yet-wired)
   460	
   461	These names are reserved by design documents but no agent fires them in v1.0. Listed here to prevent collision; do not invent codes overlapping these names.
   462	
   463	| Code | Reserved by | Earliest agent |
   464	|---|---|---|
   465	| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
   466	| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
   467	
   468	---
   469	
   470	## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '45,155p' && nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '410,470p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    45	entities:
    46	
    47	  # --------------------------------------------------------------------------
    48	  candidate:
    49	    description: |
    50	      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
    51	    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
    52	    v1_0_agent_access:
    53	      - Janitor (R+W — sweep + normalisation + dedup-merge proposals per bullhorn §4.1 A2)
    54	      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
    55	      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
    56	      - Concierge (R+W — lifecycle state per bullhorn §4.1 A6)
    57	    canonical_fields:
    58	      bullhorn_id:
    59	        type: integer
    60	        required: true
    61	        source: Bullhorn.Candidate.id
    62	        notes: Adapter-layer primary key for Bullhorn round-trip. Stable across ingests.
    63	      first_name:
    64	        type: string
    65	        required: true
    66	        source: Bullhorn.Candidate.firstName
    67	      last_name:
    68	        type: string
    69	        required: true
    70	        source: Bullhorn.Candidate.lastName
    71	      email:
    72	        type: string
    73	        required: false
    74	        source: Bullhorn.Candidate.email
    75	        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
    76	      phone:
    77	        type: string
    78	        required: false
    79	        source: Bullhorn.Candidate.phone
    80	      mobile:
    81	        type: string
    82	        required: false
    83	        source: Bullhorn.Candidate.mobile
    84	      status:
    85	        type: string
    86	        required: true
    87	        source: Bullhorn.Candidate.status
    88	        enum: [active, archived, do_not_contact, placed, contractor_promoted]
    89	        notes: |
    90	          "contractor_promoted" = candidate whose status flipped to contractor; row gets duplicated as entity_type="contractor" via adapter layer.
    91	      owner_user_id:
    92	        type: integer
    93	        required: false
    94	        source: Bullhorn.Candidate.owner.id
    95	        notes: Bullhorn user (consultant) who owns this candidate record.
    96	      date_added_at:
    97	        type: timestamp
    98	        required: true
    99	        source: Bullhorn.Candidate.dateAdded
   100	      date_last_modified_at:
   101	        type: timestamp
   102	        required: true
   103	        source: Bullhorn.Candidate.dateLastModified
   104	      current_role:
   105	        type: string
   106	        required: false
   107	        source: Bullhorn.Candidate.occupation
   108	      current_employer:
   109	        type: string
   110	        required: false
   111	        source: Bullhorn.Candidate.companyName
   112	      desired_role:
   113	        type: string
   114	        required: false
   115	        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
   116	      salary_expectation_min:
   117	        type: number
   118	        required: false
   119	        source: IFOS-derived (Scribe extraction; GBP annual)
   120	      salary_expectation_max:
   121	        type: number
   122	        required: false
   123	        source: IFOS-derived (GBP annual)
   124	      location:
   125	        type: string
   126	        required: false
   127	        source: Bullhorn.Candidate.address.city
   128	        notes: Free-text city/region for v0.1. Structured location pending v1.1.
   129	      willing_to_relocate:
   130	        type: boolean
   131	        required: false
   132	        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
   133	      notice_period_weeks:
   134	        type: integer
   135	        required: false
   136	        source: IFOS-derived (Scribe extracts)
   137	      source:
   138	        type: string
   139	        required: false
   140	        enum: [linkedin, referral, bullhorn_existing, direct_application, sourcing_scout, other]
   141	        source: IFOS-derived (set by Sourcing Scout at first-touch)
   142	      voice_classifier_score:
   143	        type: number
   144	        required: false
   145	        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
   146	        notes: |
   147	          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
   148	    notes:
   149	      - PII handling — fields email, phone, mobile, location are PII per UK GDPR Art. 4(1). Autosend-policy.md §7 `payload_preview` rules apply.
   150	      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
   151	
   152	  # --------------------------------------------------------------------------
   153	  contractor:
   154	    description: |
   155	      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
   410	        source: IFOS-derived (Concierge maintains based on client check-in cadence)
   411	      status:
   412	        type: string
   413	        required: true
   414	        enum: [open, on_hold, filled, closed_lost, closed_won, cancelled]
   415	        source: Bullhorn.JobOrder.status (with mapping)
   416	      date_added_at:
   417	        type: timestamp
   418	        required: true
   419	        source: Bullhorn.JobOrder.dateAdded
   420	      date_last_modified_at:
   421	        type: timestamp
   422	        required: true
   423	        source: Bullhorn.JobOrder.dateLastModified
   424	    notes:
   425	      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
   426	      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).
   427	
   428	  # --------------------------------------------------------------------------
   429	  placement:
   430	    description: |
   431	      A candidate placed into a client role. The commercial transaction unit — fees accrue per placement, lifecycle events (week-1, month-1, etc.) fire per placement per Product Spec §2.2 R7.
   432	    bullhorn_source: Bullhorn.Placement
   433	    v1_0_agent_access:
   434	      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
   435	      - Scribe (R+W — note links per bullhorn §4.1 A3)
   436	      - Concierge (R+W — lifecycle stage maintenance per bullhorn §4.1 A6)
   437	    canonical_fields:
   438	      bullhorn_id:
   439	        type: integer
   440	        required: true
   441	        source: Bullhorn.Placement.id
   442	      start_date:
   443	        type: date
   444	        required: true
   445	        source: Bullhorn.Placement.dateBegin
   446	      end_date:
   447	        type: date
   448	        required: false
   449	        source: Bullhorn.Placement.dateEnd
   450	        notes: Nullable for permanent placements; required for contract.
   451	      status:
   452	        type: string
   453	        required: true
   454	        enum: [active, completed, terminated, never_started]
   455	        source: Bullhorn.Placement.status (with mapping)
   456	      placement_type:
   457	        type: string
   458	        required: true
   459	        enum: [permanent, contract, temp, retained]
   460	        source: Bullhorn.Placement.employmentType (with mapping)
   461	      fee_amount:
   462	        type: number
   463	        required: false
   464	        source: Bullhorn.Placement.fee
   465	        notes: GBP. For permanent placements typically % of candidate_salary_at_placement; for contract typically per-day margin.
   466	      fee_percent:
   467	        type: number
   468	        required: false
   469	        source: Bullhorn.Placement.feeArrangement (parsed)
   470	        notes: For permanent; 15-25% typical UK range.

exec
/bin/zsh -lc 'rg -n "scout_run_complete|sourcing|source|report|decision_log|Gate A|sourcing_scout|agent_output" agents/_shared/autosend-policy.yaml docs/decisions/autosend-safety-policy.md -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:19:# Schema version stamps decision_log.payload.policy_version_sha at write time.
agents/_shared/autosend-policy.yaml:29:  diagnostic_report_render:
agents/_shared/autosend-policy.yaml:49:    agent: sourcing-scout
agents/_shared/autosend-policy.yaml:68:    reason: "Internal operator-only Telegram notification (escalations + run-complete markers); not customer-facing; idempotent within decision_log payload_hash dedup window"
agents/_shared/autosend-policy.yaml:74:    reason: "Internal run-complete status marker written to decision_log; no external comms; informational"
agents/_shared/autosend-policy.yaml:77:  scout_run_complete:
agents/_shared/autosend-policy.yaml:79:    agent: sourcing-scout
agents/_shared/autosend-policy.yaml:98:    reason: "Status marker recorded AFTER an external send completes (the send itself was a different orange/yellow action_type with its own decision_log row); this row closes the workflow trace"
agents/_shared/autosend-policy.yaml:110:    reason: "Gate B feedback row written when consultant tags a Diagnostic report as booked|not-booked via Telegram (/diagnostic-feedback <report-id> ...) or Brain UI button. agent_name='diagnostic'; phase='action'; payload includes report_id + outcome. Internal-only; no external send."
agents/_shared/autosend-policy.yaml:116:    reason: "Internal audit row written by validate.sh when Gate A enforcement fails. Carries the specific ESC code (e.g. ESC_AGENT_OUTPUT_SHAPE | ESC_PII_LEAKAGE_RISK) in the payload; the action itself is just the audit-row write, not an external send. Each agent's validate.sh emits this row before exit 1."
agents/_shared/autosend-policy.yaml:158:    reason: "Fills missing canonical schema fields from Companies House or LinkedIn enrichment; reversible PATCH; high-volume; source provenance logged in payload"
agents/_shared/autosend-policy.yaml:165:    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
agents/_shared/autosend-policy.yaml:177:    agent: sourcing-scout
agents/_shared/autosend-policy.yaml:268:    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
agents/_shared/autosend-policy.yaml:280:    agent: sourcing-scout
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:21:**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).
docs/decisions/autosend-safety-policy.md:32:- Read-only IFOS internal queries (entities, decision_log reads via context-assembly API)
docs/decisions/autosend-safety-policy.md:49:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
docs/decisions/autosend-safety-policy.md:55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:67:Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
docs/decisions/autosend-safety-policy.md:81:| Diagnostic | `diagnostic_report_render` | Internal artefact write; no external comms; idempotent (re-render overwrites) |
docs/decisions/autosend-safety-policy.md:108:| Diagnostic | `diagnostic_email_send` | Outbound diagnostic report to prospect; sales-stage outreach; reputation |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:160:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
docs/decisions/autosend-safety-policy.md:167:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:175:      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:179:      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
docs/decisions/autosend-safety-policy.md:193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:209:The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
docs/decisions/autosend-safety-policy.md:241:**Payload (JSONB into `decision_log.payload`):**
docs/decisions/autosend-safety-policy.md:258:1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
docs/decisions/autosend-safety-policy.md:262:5. On resolution, `decision_log` row is **appended** (not modified — append-only) with `phase='action'`, `payload.approval_status='approved'|'rejected'|'escalated'` and `payload.approval_resolution_at`
docs/decisions/autosend-safety-policy.md:300:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`
docs/decisions/autosend-safety-policy.md:302:3. Operator may file a `false-block` feedback report via Brain UI if the tier classification seems wrong; report becomes input to next policy review
docs/decisions/autosend-safety-policy.md:304:**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).
docs/decisions/autosend-safety-policy.md:315:Block report: file via Brain UI if you believe this should be allowed
docs/decisions/autosend-safety-policy.md:338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:355:| `decision_log` table unreachable (Postgres down, RLS context unset, network partition) | INSERT raises error | **Hard blocking error**; agent halts entirely with non-zero exit; no actions taken at all | Postgres restored OR session restarted with valid context; agent resumes from last checkpoint |
docs/decisions/autosend-safety-policy.md:364:**Every governed action emits exactly one `decision_log` row** at execution time. The append-only enforcement (Postgres grants on `decision_log` are SELECT + INSERT only for `ifos_app` per Day 4 §6.3) means rows cannot be modified or deleted post-write.
docs/decisions/autosend-safety-policy.md:366:### Row schema (within existing `decision_log` table from Day 4)
docs/decisions/autosend-safety-policy.md:369:-- decision_log columns (Day 4 §6.3):
docs/decisions/autosend-safety-policy.md:402:1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
docs/decisions/autosend-safety-policy.md:404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
docs/decisions/autosend-safety-policy.md:418:`decision_log` rows are retained **indefinitely** for v1.0. v1.1+ may introduce retention policies (e.g., delete rows older than 7 years per UK statutory retention norms).
docs/decisions/autosend-safety-policy.md:470:Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.
docs/decisions/autosend-safety-policy.md:513:recorded in the decision_log table by reference to the policy git SHA
docs/decisions/autosend-safety-policy.md:514:(decision_log.payload.policy_version_sha), is the authoritative record
docs/decisions/autosend-safety-policy.md:537:  (b) failure of the policy lookup mechanism (decision_log fail-safe-red
docs/decisions/autosend-safety-policy.md:544:The decision_log table within IFOS's Postgres instance, isolated to
docs/decisions/autosend-safety-policy.md:549:decision_log timestamps, payload_hash, and policy_version_sha.
docs/decisions/autosend-safety-policy.md:554:of docs/decisions/autosend-safety-policy.md in the decision_log row's
docs/decisions/autosend-safety-policy.md:586:5. **PII liability for `payload_preview` formatting.** If `payload_preview` accidentally leaks PII into `decision_log`, that's a Provider liability event. Tooling: linter on `payload_preview` strings at hook-helpers.sh layer.
docs/decisions/autosend-safety-policy.md:611:- **Whether decision_log captures both allowed and blocked sends:** Yes, §7.
docs/decisions/autosend-safety-policy.md:634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).

exec
/bin/zsh -lc 'rg -n "sourcing_scout|Sourcing Scout|source|candidate|do-not-contact|DNC|proposed" docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/vertical-schema.yaml -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:31:# No ALTER TABLE for the candidate / contact / brief / placement / opportunity
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:53:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:63:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:66:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:77:          per candidate enforced by validate_entities_data_v0_3.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:78:        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:81:          - Sourcing Scout: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:91:          outbound — outreach via candidate.email or candidate.phone only).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:92:        source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:94:          - Sourcing Scout: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:108:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:120:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:134:          Hard requirements; Sourcing Scout filters candidates against this
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:136:        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:139:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:147:          Soft preferences; Sourcing Scout uses for ranking, not hard filter.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:148:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:151:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:159:          Anti-requirements; Sourcing Scout EXCLUDES candidates matching any
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:161:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:164:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:175:          confirming candidate started. Janitor flags ambiguous via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:177:        source: IFOS-derived (Scribe + Janitor)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:197:        source: IFOS-derived (Scribe extracts from 7d check-in call; writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:211:        source: IFOS-derived (Scribe LLM extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:224:          ("we're hiring 5 engineers this quarter"). Sourcing Scout reads
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:226:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:229:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:238:          ranking in Sourcing Scout's brief-to-candidate pipeline.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:239:        source: IFOS-derived (Scribe LLM classification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:242:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:251:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:268:#     client entity; sales-tool source-of-truth context — v0.3 amendment)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:272:#     pattern as candidate/contractor — v0.3 amendment)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:280:#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:290:#   - Sourcing Scout candidate: R → R+W (writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:291:#     from multi-source aggregation — v0.3 amendment)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:293:#   - Sourcing Scout opportunity: none → R (reads opportunity context for ICP)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:294:#   - Concierge candidate: R → R+W (writes lifecycle-state-derived fields +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:314:  # (candidate, contractor, client, contact, brief, opportunity, placement,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:342:  #   Example: Scribe.candidate: R+W at entity level; per-field
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:343:  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:344:  #   without reading it). Another example: Diagnostic.candidate: R at entity
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:345:  #   level; candidate.linkedin_url has no Diagnostic field entry; Diagnostic
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:363:    candidate: R           # reads for outreach context (§11 decision-maker map)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:373:    candidate: R+W         # dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:377:    brief: R               # context for related candidate cleanup
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:389:    candidate: R+W         # call-summary field extraction (Bullhorn endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:390:    contractor: R+W        # call-summary field extraction (Bullhorn endpoint A3 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:404:    candidate: none        # no Bullhorn dependency
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:414:  sourcing_scout:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:416:    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:417:    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:418:    # writes its proposed-candidate rows + reads opportunity context. These
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:420:    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:424:    brief: R               # reads to filter candidates
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:434:    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14 (Bullhorn endpoint A6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:435:    contractor: R+W        # writes lifecycle states for contractor placements too (Bullhorn endpoint A6 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:454:  # is NOT edited; this supplement is the authoritative source for v0.3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:458:    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:464:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:477:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:493:      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:503:      - Sourcing Scout (R) # v0.3 NEW — reads opportunity for ICP scoring
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:508:      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:534:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:535:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:540:      - Sourcing Scout (R+W) # v0.3 UPGRADED — writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:543:      v0.3 upgrades Sourcing Scout (writes proposed-candidate rows from
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:544:      multi-source aggregation) + Concierge (writes lifecycle-state and
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:548:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:552:      - Sourcing Scout (R+W) # v0.3 UPGRADED — same pattern as candidate
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:555:      Parallel upgrades to candidate; contractor entities follow the same
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:562:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:566:      Conductor for chase drafts; Sourcing Scout for per-candidate
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:572:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:577:      Diagnostic + Sourcing Scout also read tone_rules for their
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:578:      voice-classified outputs (§12 opener, per-candidate rationale).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:589:      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:595:      supplement is the authoritative source for the expanded access list.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:611:      id: {type: integer, required: true, source: IFOS-internal, notes: BIGSERIAL primary key in SQL}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:612:      tenant_slug: {type: string, required: true, source: IFOS-internal, notes: RLS isolation key per Day-4 §6.3}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:613:      transaction_id: {type: string, required: true, source: Open Banking provider (TrueLayer / Plaid)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:614:      posted_at: {type: timestamp, required: true, source: Open Banking provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:615:      amount: {type: number, required: true, source: Open Banking provider, notes: NUMERIC(15,2) GBP; negative for outgoing}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:616:      currency: {type: string, required: true, default: GBP, source: Open Banking provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:617:      payee_name_raw: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:618:      description: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:619:      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct], source: IFOS-internal (per-tenant config)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:620:      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:621:      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:622:      match_confidence: {type: number, required: false, source: IFOS-derived (Cash Conductor algorithm), notes: "range [0.00, 1.00]"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:623:      match_dimensions: {type: array, items: {type: string}, required: false, source: IFOS-derived}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:624:      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:625:      raw_payload: {type: object, required: false, source: Open Banking provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific. Full Open Banking response cached for audit; pseudonymized at year 7"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:647:      id: {type: integer, required: true, source: IFOS-internal}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:648:      tenant_slug: {type: string, required: true, source: IFOS-internal}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:649:      invoice_id: {type: string, required: true, source: Accounting provider (Xero/QuickBooks/Sage)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:650:      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage], source: IFOS-internal (per-tenant config)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:651:      invoice_number: {type: string, required: false, source: Accounting provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:652:      issued_at: {type: timestamp, required: true, source: Accounting provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:653:      due_at: {type: timestamp, required: true, source: Accounting provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:654:      amount_total: {type: number, required: true, source: Accounting provider, notes: NUMERIC(15,2) GBP}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:655:      amount_paid: {type: number, required: true, default: 0, source: Accounting provider + IFOS-derived (Cash Conductor reconciliation updates)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:656:      currency: {type: string, required: true, default: GBP, source: Accounting provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:657:      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open, source: Accounting provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:658:      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor links to Bullhorn placement.client_contact_id)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:659:      client_billing_email: {type: string, required: false, source: Accounting provider, pii: true}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:660:      last_chase_position: {type: integer, required: true, default: 0, source: IFOS-derived (Cash Conductor escalation ladder), notes: 0-4 per Cash Conductor §3.2}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:661:      last_chase_sent_at: {type: timestamp, required: false, source: IFOS-derived}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:662:      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:663:      raw_payload: {type: object, required: false, source: Accounting provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific (Xero / QuickBooks / Sage). Full provider response cached for audit"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:691:    sourcing_scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:700:    sourcing_scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:709:    sourcing_scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:720:    sourcing_scout: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:727:    sourcing_scout: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:734:    sourcing_scout: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:848:      candidate / contact / brief / placement / opportunity entity_types.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:888:        Keep 6 values as in §1.candidate.employment_type — perm, contract,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:900:    question: Cap at 20 items per candidate adequate?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:903:      B: Increase to 50 (handles senior technical candidates with deep stacks).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:906:    trigger_for_revisit: First-pilot data after 30+ candidates indexed; if >5%
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:907:      of candidates hit the 20-item cap, escalate to B.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:976:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.yaml:5:#   - entity_links (..., source_entity_type, source_entity_id, target_entity_type, target_entity_id, link_type, ...)
docs/verticals/recruitment/vertical-schema.yaml:27:  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.
docs/verticals/recruitment/vertical-schema.yaml:34:#   - bullhorn_source: the Bullhorn entity (and any status filter) this maps from
docs/verticals/recruitment/vertical-schema.yaml:41:# `source: Bullhorn.<Entity>.<field>` means sourced from Bullhorn at ingest;
docs/verticals/recruitment/vertical-schema.yaml:42:# `source: IFOS-derived` means computed/written by IFOS code (e.g., voice_classifier_score).
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:51:    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
docs/verticals/recruitment/vertical-schema.yaml:55:      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:61:        source: Bullhorn.Candidate.id
docs/verticals/recruitment/vertical-schema.yaml:66:        source: Bullhorn.Candidate.firstName
docs/verticals/recruitment/vertical-schema.yaml:70:        source: Bullhorn.Candidate.lastName
docs/verticals/recruitment/vertical-schema.yaml:74:        source: Bullhorn.Candidate.email
docs/verticals/recruitment/vertical-schema.yaml:75:        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
docs/verticals/recruitment/vertical-schema.yaml:79:        source: Bullhorn.Candidate.phone
docs/verticals/recruitment/vertical-schema.yaml:83:        source: Bullhorn.Candidate.mobile
docs/verticals/recruitment/vertical-schema.yaml:87:        source: Bullhorn.Candidate.status
docs/verticals/recruitment/vertical-schema.yaml:90:          "contractor_promoted" = candidate whose status flipped to contractor; row gets duplicated as entity_type="contractor" via adapter layer.
docs/verticals/recruitment/vertical-schema.yaml:94:        source: Bullhorn.Candidate.owner.id
docs/verticals/recruitment/vertical-schema.yaml:95:        notes: Bullhorn user (consultant) who owns this candidate record.
docs/verticals/recruitment/vertical-schema.yaml:99:        source: Bullhorn.Candidate.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:103:        source: Bullhorn.Candidate.dateLastModified
docs/verticals/recruitment/vertical-schema.yaml:107:        source: Bullhorn.Candidate.occupation
docs/verticals/recruitment/vertical-schema.yaml:111:        source: Bullhorn.Candidate.companyName
docs/verticals/recruitment/vertical-schema.yaml:115:        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:119:        source: IFOS-derived (Scribe extraction; GBP annual)
docs/verticals/recruitment/vertical-schema.yaml:123:        source: IFOS-derived (GBP annual)
docs/verticals/recruitment/vertical-schema.yaml:127:        source: Bullhorn.Candidate.address.city
docs/verticals/recruitment/vertical-schema.yaml:132:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:136:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.yaml:137:      source:
docs/verticals/recruitment/vertical-schema.yaml:140:        enum: [linkedin, referral, bullhorn_existing, direct_application, sourcing_scout, other]
docs/verticals/recruitment/vertical-schema.yaml:141:        source: IFOS-derived (set by Sourcing Scout at first-touch)
docs/verticals/recruitment/vertical-schema.yaml:145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:156:    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
docs/verticals/recruitment/vertical-schema.yaml:159:      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:163:      # Inherits candidate fields conceptually; below are the additional contractor-specific fields.
docs/verticals/recruitment/vertical-schema.yaml:164:      # Full implementation: adapter layer materialises both candidate-overlap fields AND contractor-specific fields in entities.data.
docs/verticals/recruitment/vertical-schema.yaml:165:      # Schema notes: see candidate canonical_fields for the shared base set.
docs/verticals/recruitment/vertical-schema.yaml:169:        source: Bullhorn.Candidate.id
docs/verticals/recruitment/vertical-schema.yaml:170:        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
docs/verticals/recruitment/vertical-schema.yaml:174:        source: Bullhorn.Candidate.firstName
docs/verticals/recruitment/vertical-schema.yaml:178:        source: Bullhorn.Candidate.lastName
docs/verticals/recruitment/vertical-schema.yaml:182:        source: Bullhorn.Candidate.email
docs/verticals/recruitment/vertical-schema.yaml:186:        source: Bullhorn.Candidate.mobile
docs/verticals/recruitment/vertical-schema.yaml:191:        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
docs/verticals/recruitment/vertical-schema.yaml:196:        source: IFOS-derived (Scribe extracts from call; GBP per day)
docs/verticals/recruitment/vertical-schema.yaml:200:        source: IFOS-derived (GBP per day)
docs/verticals/recruitment/vertical-schema.yaml:204:        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
docs/verticals/recruitment/vertical-schema.yaml:205:        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
docs/verticals/recruitment/vertical-schema.yaml:209:        source: IFOS-derived (when can contractor start, in weeks from now)
docs/verticals/recruitment/vertical-schema.yaml:213:        source: IFOS-derived
docs/verticals/recruitment/vertical-schema.yaml:217:      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
docs/verticals/recruitment/vertical-schema.yaml:223:      A company that hires through the recruitment agency. Master brief canonical vocabulary at §3.2 line 155 ("candidate, placement, brief") implicitly assumes client as the holder of briefs. Bullhorn calls this `ClientCorporation`.
docs/verticals/recruitment/vertical-schema.yaml:224:    bullhorn_source: Bullhorn.ClientCorporation
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:233:        source: Bullhorn.ClientCorporation.id
docs/verticals/recruitment/vertical-schema.yaml:237:        source: Bullhorn.ClientCorporation.name
docs/verticals/recruitment/vertical-schema.yaml:241:        source: Bullhorn.ClientCorporation.industryList
docs/verticals/recruitment/vertical-schema.yaml:247:        source: Bullhorn.ClientCorporation.numEmployees (bucketed)
docs/verticals/recruitment/vertical-schema.yaml:251:        source: Bullhorn.ClientCorporation.companyURL
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:261:        source: IFOS-derived (Janitor maintains)
docs/verticals/recruitment/vertical-schema.yaml:265:        source: Bullhorn.ClientCorporation.owner.id
docs/verticals/recruitment/vertical-schema.yaml:269:        source: IFOS-derived (commercial framework; free text for v0.1; structured for v1.1+)
docs/verticals/recruitment/vertical-schema.yaml:273:        source: Bullhorn.ClientCorporation.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:277:        source: Bullhorn.ClientCorporation.address.city
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:286:    bullhorn_source: Bullhorn.ClientContact
docs/verticals/recruitment/vertical-schema.yaml:294:        source: Bullhorn.ClientContact.id
docs/verticals/recruitment/vertical-schema.yaml:298:        source: Bullhorn.ClientContact.firstName
docs/verticals/recruitment/vertical-schema.yaml:302:        source: Bullhorn.ClientContact.lastName
docs/verticals/recruitment/vertical-schema.yaml:306:        source: Bullhorn.ClientContact.email
docs/verticals/recruitment/vertical-schema.yaml:310:        source: Bullhorn.ClientContact.phone
docs/verticals/recruitment/vertical-schema.yaml:314:        source: Bullhorn.ClientContact.title
docs/verticals/recruitment/vertical-schema.yaml:320:        source: IFOS-derived (founder captures during intake; thin v0.1, expanded v1.1)
docs/verticals/recruitment/vertical-schema.yaml:326:        source: IFOS-derived
docs/verticals/recruitment/vertical-schema.yaml:330:        source: Bullhorn.ClientContact.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:334:        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:344:    bullhorn_source: Bullhorn.JobOrder
docs/verticals/recruitment/vertical-schema.yaml:349:      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:355:        source: Bullhorn.JobOrder.id
docs/verticals/recruitment/vertical-schema.yaml:359:        source: Bullhorn.JobOrder.title
docs/verticals/recruitment/vertical-schema.yaml:364:        source: Bullhorn.JobOrder.publicDescription
docs/verticals/recruitment/vertical-schema.yaml:370:        source: Bullhorn.JobOrder.employmentType (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:374:        source: Bullhorn.JobOrder.salary
docs/verticals/recruitment/vertical-schema.yaml:379:        source: Bullhorn.JobOrder.salaryUnit (range parsing)
docs/verticals/recruitment/vertical-schema.yaml:383:        source: IFOS-derived (extracted from JD; GBP per day for contract roles)
docs/verticals/recruitment/vertical-schema.yaml:387:        source: IFOS-derived
docs/verticals/recruitment/vertical-schema.yaml:391:        source: Bullhorn.JobOrder.address.city
docs/verticals/recruitment/vertical-schema.yaml:396:        source: IFOS-derived (extracted from JD)
docs/verticals/recruitment/vertical-schema.yaml:401:        source: IFOS-derived (extracted from JD; v0.1 free strings; v1.1+ canonicalised skill taxonomy)
docs/verticals/recruitment/vertical-schema.yaml:405:        source: IFOS-derived
docs/verticals/recruitment/vertical-schema.yaml:410:        source: IFOS-derived (Concierge maintains based on client check-in cadence)
docs/verticals/recruitment/vertical-schema.yaml:415:        source: Bullhorn.JobOrder.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:419:        source: Bullhorn.JobOrder.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:423:        source: Bullhorn.JobOrder.dateLastModified
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:426:      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).
docs/verticals/recruitment/vertical-schema.yaml:431:      A candidate placed into a client role. The commercial transaction unit — fees accrue per placement, lifecycle events (week-1, month-1, etc.) fire per placement per Product Spec §2.2 R7.
docs/verticals/recruitment/vertical-schema.yaml:432:    bullhorn_source: Bullhorn.Placement
docs/verticals/recruitment/vertical-schema.yaml:441:        source: Bullhorn.Placement.id
docs/verticals/recruitment/vertical-schema.yaml:445:        source: Bullhorn.Placement.dateBegin
docs/verticals/recruitment/vertical-schema.yaml:449:        source: Bullhorn.Placement.dateEnd
docs/verticals/recruitment/vertical-schema.yaml:455:        source: Bullhorn.Placement.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:460:        source: Bullhorn.Placement.employmentType (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:464:        source: Bullhorn.Placement.fee
docs/verticals/recruitment/vertical-schema.yaml:465:        notes: GBP. For permanent placements typically % of candidate_salary_at_placement; for contract typically per-day margin.
docs/verticals/recruitment/vertical-schema.yaml:469:        source: Bullhorn.Placement.feeArrangement (parsed)
docs/verticals/recruitment/vertical-schema.yaml:471:      candidate_salary_at_placement:
docs/verticals/recruitment/vertical-schema.yaml:474:        source: Bullhorn.Placement.salary
docs/verticals/recruitment/vertical-schema.yaml:480:        source: IFOS-derived (Concierge maintains per Product Spec §2.2 R7 lifecycle cadence)
docs/verticals/recruitment/vertical-schema.yaml:485:        source: IFOS-derived (free text for v0.1; v1.1+ structured)
docs/verticals/recruitment/vertical-schema.yaml:489:        source: Bullhorn.Placement.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:497:      A candidate-brief pairing in the submission/screening/interview/offer pipeline. Pre-placement state. v1.1+ exercised; v1.0 minimal.
docs/verticals/recruitment/vertical-schema.yaml:498:    bullhorn_source: Bullhorn.JobSubmission (or Bullhorn.Opportunity — tenant-config dependent; some tenants use one, some both)
docs/verticals/recruitment/vertical-schema.yaml:502:      - (v1.1) Inbound Triage — read for routing inbound candidate enquiries to active opportunities
docs/verticals/recruitment/vertical-schema.yaml:508:        source: Bullhorn.JobSubmission.id
docs/verticals/recruitment/vertical-schema.yaml:512:        enum: [submitted, screening, interview_scheduled, interview_completed, offer_pending, offer_accepted, rejected_by_client, rejected_by_candidate, withdrawn]
docs/verticals/recruitment/vertical-schema.yaml:513:        source: Bullhorn.JobSubmission.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:518:        source: IFOS-derived (event log; one entry per status transition)
docs/verticals/recruitment/vertical-schema.yaml:525:        source: Bullhorn.JobSubmission.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:529:        source: Bullhorn.JobSubmission.dateLastModified
docs/verticals/recruitment/vertical-schema.yaml:538:    bullhorn_source: Bullhorn.Timesheet (Bullhorn has a Timesheet entity; tenant-config dependent)
docs/verticals/recruitment/vertical-schema.yaml:548:        source: Bullhorn.Timesheet.id
docs/verticals/recruitment/vertical-schema.yaml:552:        source: Bullhorn.Timesheet.weekStartDate
docs/verticals/recruitment/vertical-schema.yaml:556:        source: Bullhorn.Timesheet.totalHours
docs/verticals/recruitment/vertical-schema.yaml:560:        source: Bullhorn.Timesheet.status (parsed)
docs/verticals/recruitment/vertical-schema.yaml:564:        source: IFOS-derived (T2 confirms; v2.0)
docs/verticals/recruitment/vertical-schema.yaml:568:        source: Bullhorn.Timesheet.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:577:#   - source → target entity_types
docs/verticals/recruitment/vertical-schema.yaml:578:#   - cardinality: 1:1 | 1:N (one source, many targets) | M:N
docs/verticals/recruitment/vertical-schema.yaml:585:  candidate_placed_in_role:
docs/verticals/recruitment/vertical-schema.yaml:586:    source: candidate
docs/verticals/recruitment/vertical-schema.yaml:589:    description: A candidate may have multiple placements over time (different clients, different roles). A placement has exactly one candidate.
docs/verticals/recruitment/vertical-schema.yaml:591:      Despite "M:N" cardinality, practically 1:N from placement → candidate (each placement has one candidate; each candidate has 0..N placements). Modelled as M:N for query symmetry.
docs/verticals/recruitment/vertical-schema.yaml:592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
docs/verticals/recruitment/vertical-schema.yaml:595:    source: placement
docs/verticals/recruitment/vertical-schema.yaml:602:    source: brief
docs/verticals/recruitment/vertical-schema.yaml:609:    source: brief
docs/verticals/recruitment/vertical-schema.yaml:619:    source: contact
docs/verticals/recruitment/vertical-schema.yaml:625:  candidate_engaged_with_contact:
docs/verticals/recruitment/vertical-schema.yaml:626:    source: candidate
docs/verticals/recruitment/vertical-schema.yaml:632:  candidate_referred_by_contact:
docs/verticals/recruitment/vertical-schema.yaml:633:    source: candidate
docs/verticals/recruitment/vertical-schema.yaml:636:    description: Some candidates are referred by a contact (a candidate's previous manager, peer, etc., who is in the IFOS contact registry).
docs/verticals/recruitment/vertical-schema.yaml:637:    v1_0_exercise: Sourcing Scout captures at first-touch when relevant; not heavily exercised in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:640:    source: opportunity
docs/verticals/recruitment/vertical-schema.yaml:643:    description: An opportunity is a candidate's progression toward a specific brief.
docs/verticals/recruitment/vertical-schema.yaml:647:  opportunity_about_candidate:
docs/verticals/recruitment/vertical-schema.yaml:648:    source: opportunity
docs/verticals/recruitment/vertical-schema.yaml:649:    target: candidate
docs/verticals/recruitment/vertical-schema.yaml:651:    description: Each opportunity is about exactly one candidate; a candidate may have multiple opportunities (different briefs).
docs/verticals/recruitment/vertical-schema.yaml:655:    source: timesheet
docs/verticals/recruitment/vertical-schema.yaml:672:    candidate: none
docs/verticals/recruitment/vertical-schema.yaml:683:    candidate: R+W   # full sweep + normalisation + dedup proposals
docs/verticals/recruitment/vertical-schema.yaml:693:    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
docs/verticals/recruitment/vertical-schema.yaml:695:    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
docs/verticals/recruitment/vertical-schema.yaml:698:    placement: R+W   # note links on placed-candidate calls
docs/verticals/recruitment/vertical-schema.yaml:703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
docs/verticals/recruitment/vertical-schema.yaml:713:    candidate: R     # passive matching
docs/verticals/recruitment/vertical-schema.yaml:723:    candidate: R+W   # lifecycle state on every event
docs/verticals/recruitment/vertical-schema.yaml:735:# Per-entity Bullhorn source + field-level mapping notes.
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:752:    notes: Adapter layer materialises both `candidate` and `contractor` entity_type rows from the same Bullhorn.Candidate record when status flips. See entity-level notes.
docs/verticals/recruitment/vertical-schema.yaml:758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
docs/verticals/recruitment/vertical-schema.yaml:769:    notes: Skills extraction (required_skills, nice_to_have_skills arrays) is IFOS-derived from JD body, not Bullhorn-sourced (Bullhorn does not consistently structure skill fields across tenants).
docs/verticals/recruitment/vertical-schema.yaml:799:    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
docs/verticals/recruitment/vertical-schema.yaml:800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
docs/verticals/recruitment/vertical-schema.yaml:805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
docs/verticals/recruitment/vertical-schema.yaml:841:    revisit_trigger: Skill-matching accuracy from Sourcing Scout's first 4 tenant-weeks of operation; if free-text matching produces <60% precision, canonical skill taxonomy lands as v1.1.
docs/verticals/recruitment/vertical-schema.yaml:866:  Q12_source_field_schema:
docs/verticals/recruitment/vertical-schema.yaml:870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.
docs/verticals/recruitment/vertical-schema.yaml:872:      Codex Day-7 ratification reviews whether stricter source-field schema would improve machine-parseability. If accepted, v1.0 introduces structured source object — e.g., `source: {origin: bullhorn | ifos_derived, bullhorn_field?: <entity.field>, ifos_agent?: <agent_name>, citation?: <doc-ref>}`.
docs/verticals/recruitment/vertical-schema.yaml:874:      Mixed-format is readable for v0.1; stricter is Codex review work. Machine-parseability matters if Week-1 prereq 3 (`_shared/hook-helpers.sh`) consumes source provenance for audit; if not consumed programmatically, free-text is fine.
docs/verticals/recruitment/vertical-schema.yaml:898:      Triage expansion (Q5 contact decision-authority granularity, Q10 panel hiring). Skill taxonomy decision (Q8). Multi-client contact decision (Q9). Umbrella company entity promotion candidate (Q7). Opportunity entity exercise begins.

exec
/bin/zsh -lc "nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '1,140p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Sourcing Scout — request-response passive sourcing
     2	
     3	**Status:** Proposed (Day-19 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice).
     4	**Date:** 2026-05-24.
     5	**Author:** Founder (Maddox) + Claude Code.
     6	**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
     7	**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
     8	**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.
     9	
    10	---
    11	
    12	## §1 — Output contract (one-paragraph screenshot)
    13	
    14	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    15	
    16	> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate flagged "do not contact" in tenant vault (per ULTRAPLAN A5 line 552 verbatim). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
    17	
    18	---
    19	
    20	## §2 — Invocation surface
    21	
    22	### Brain UI (v1.0 primary)
    23	
    24	Brain UI v1.0 "Source candidates" button on any brief detail page → POST internal API → Sourcing Scout webhook.
    25	
    26	### Telegram command (v1.0)
    27	
    28	```
    29	@ifos_bot scout <brief-id-or-slug>
    30	@ifos_bot scout --description "Senior React engineer, London, £120k, hybrid"
    31	```
    32	
    33	### Webhook (v1.0)
    34	
    35	Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
    36	
    37	### CLI (v1.0 — debugging)
    38	
    39	```bash
    40	ifosctl sourcing-scout source --tenant <slug> --brief-id <id>
    41	ifosctl sourcing-scout source --tenant <slug> --description "<free-text>"
    42	```
    43	
    44	### v1.1+ surfaces (deferred)
    45	
    46	- Night Sourcer Tier-1 always-on (Brain UI dashboard; cortextOS primitive #6)
    47	- Bulk-source mode (`--brief-list briefs.csv`)
    48	- Refresh-source mode (re-source against the same brief 30 days later)
    49	
    50	---
    51	
    52	## §3 — Output shape
    53	
    54	One output per invocation. Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md`. Structure:
    55	
    56	```markdown
    57	# Sourcing Scout — <Brief title>
    58	**Generated:** <ISO-date>  **Brief ID:** <Bullhorn-brief-id>  **Tenant:** <slug>
    59	**Sources searched:** Bullhorn ATS + LinkedIn (Proxycurl) + Reed + CV-Library
    60	**Aggregate candidates:** <N> (top 5-15 ranked)
    61	
    62	## Brief context
    63	<2-3 sentences summarising the role from the brief input>
    64	
    65	## Ranked candidates
    66	
    67	### 1. <Candidate name> — confidence 0.92
    68	**Source:** Bullhorn (passive match) | **Contact:** <method + verified>
    69	**Match rationale:**
    70	<≥50 words explaining why this candidate is a match — references brief
    71	requirements + candidate background; cites Bullhorn placement history,
    72	LinkedIn current role, or other source-specific evidence.>
    73	**Risk flags:** <e.g., "active with placement at competitor agency 2024";
    74	"prefers contract not perm per Bullhorn note">
    75	**Profile links:** [Bullhorn](url) | [LinkedIn](url)
    76	
    77	### 2. <Candidate name> — confidence 0.88
    78	...
    79	
    80	(5-15 candidates total)
    81	
    82	## Source breakdown
    83	| Source | Candidates contributed | Avg confidence | Rate-limit budget remaining |
    84	|---|---|---|---|
    85	| Bullhorn ATS | <N> | <score> | n/a (no quota) |
    86	| LinkedIn (Proxycurl) | <N> | <score> | <remaining> |
    87	| Reed | <N> | <score> | <remaining> |
    88	| CV-Library | <N> | <score> | <remaining> |
    89	
    90	## Diagnostic + exception list
    91	- <Any source failures (e.g., "Reed API 429; retried once; 3 candidates lost")>
    92	- <Any "do not contact" filter hits>
    93	- <Any low-confidence candidates discarded (below 0.5)>
    94	```
    95	
    96	Per `decision_log`: one row per source query + one row per candidate proposed + one final aggregate row.
    97	
    98	Voice-classified content: only the per-candidate match rationale (Step 9). Voice classifier ≥0.75 against tenant style. Rationale that fails after 3 retries → ESC_VOICE_DRIFT → candidate dropped from list + flagged in exception list.
    99	
   100	---
   101	
   102	## §4 — Workflow
   103	
   104	11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
   105	
   106	```
   107	0. Session start
   108	   → context.sh hydrates: tenant config + multi-source auth + voice corpus
   109	     + "do not contact" list from tenant vault
   110	   → hh_decision_trigger("session_start", "scout <brief-id-or-slug>")
   111	
   112	1. Brief ingestion
   113	   → if brief_id: bullhorn.get_brief(brief_id) → fetch fields
   114	   → if free-text description: LLM parse → extract role / location / sector
   115	     / seniority / day-rate-band / must-haves / nice-to-haves
   116	   → ESC_BRIEF_AMBIGUITY if extraction yields <3 key dimensions (per
   117	     escalation-codes.md §2.5 — canonical code for under-resolvable briefs)
   118	   → hh_decision_output("brief_ingested", "<brief_id_or_slug>",
   119	     "key_dims:<N>")
   120	
   121	2. Multi-source auth refresh
   122	   → bullhorn (read-only); LinkedIn/Proxycurl; Reed; CV-Library
   123	   → per-source: ESC_BULLHORN_AUTH | ESC_LINKEDIN_AUTH | ESC_REED_AUTH |
   124	     ESC_CVLIBRARY_AUTH on refresh failure (all now registered in
   125	     escalation-codes.md §2.7)
   126	   → if 2+ sources fail auth: ESC_AGENT_OUTPUT_SHAPE (Sourcing Scout cannot
   127	     produce its declared output shape — 5-15 candidates aggregated across
   128	     sources — when 2+ sources are down)
   129	   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
   130	     "sources_ok:<N>/4")
   131	
   132	3. Bullhorn passive-match query
   133	   → bullhorn.search_candidates(filter=brief_key_dimensions,
   134	     status='active', last_activity_at < now() - interval '90 days')
   135	     — "passive" is a derived state (active candidate with no recent
   136	     activity); NOT a vertical-schema enum value. The schema defines
   137	     candidate.status as [active, archived, do_not_contact, placed,
   138	     contractor_promoted]; passive-match queries filter on activity recency
   139	     within the active set.
   140	   → up to 30 candidates fetched (will rank+filter later)
   141	   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
   142	   → hh_decision_output("bullhorn_query", "brief:<id>", "results:<N>")
   143	
   144	4. LinkedIn search (via Proxycurl)
   145	   → proxycurl.search_people(query=brief_key_dimensions, location=brief_location,
   146	     industry=brief_sector)
   147	   → up to 30 profiles
   148	   → cache 1h per (query, location, sector) tuple
   149	   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
   150	   → hh_decision_output("linkedin_query", "brief:<id>", "results:<N>")
   151	
   152	5. Reed query
   153	   → reed.search_candidates(query=brief_dimensions, location, salary_band)
   154	   → up to 30 candidates
   155	   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
   156	     (payload.upstream='reed')
   157	   → hh_decision_output("reed_query", "brief:<id>", "results:<N>")
   158	
   159	6. CV-Library query
   160	   → cvlibrary.search_candidates(query, location, salary_band)
   161	   → up to 30 candidates
   162	   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
   163	     (payload.upstream='cv-library')
   164	   → hh_decision_output("cvlibrary_query", "brief:<id>", "results:<N>")
   165	
   166	7. Aggregate + dedupe
   167	   → merge all sources into single candidate set
   168	   → dedupe across sources by (name + email) OR (name + phone) OR
   169	     (LinkedIn URL) — same fuzzy matcher as Janitor (confidence ≥0.85)
   170	   → annotate each row with source provenance (e.g., "from Bullhorn + LinkedIn
   171	     match" if found in both)
   172	   → hh_decision_output("aggregate_dedupe", "brief:<id>",
   173	     "pre_dedupe:<N>; post_dedupe:<N>")
   174	
   175	8. "Do not contact" filter
   176	   → load tenant /vault/<slug>/do-not-contact.list (one identifier per line:
   177	     email / phone / LinkedIn URL / Bullhorn bullhorn_id per canonical schema)
   178	   → remove any candidate matching any DNC identifier
   179	   → log dropped candidates to exception list
   180	   → ESC_DNC_FILTER_HIT per blocked candidate (catalogue line: §2.10 — DNC
   181	     hit is a blocking outbound refusal; fires per-candidate, not aggregate)
   182	   → hh_decision_output("dnc_filter", "brief:<id>",
   183	     "dropped:<N>; kept:<N>")
   184	
   185	9. LLM ranking + rationale generation (per candidate)
   186	   → for top 15 by source-aggregated confidence: generate per-candidate
   187	     rationale ≥50 words
   188	   → prompt = (brief context + candidate profile + voice corpus + tone rules)
   189	   → voice classifier scores rationale (≥0.75)
   190	   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
   191	     from final list
   192	
   193	10. Output assembly + Gate A validation
   194	    → ensure 5-15 candidates remaining after Step 9
   195	    → ensure each has working contact method (email validated via simple
   196	      regex + domain MX check; phone validated via E.164 format)
   197	    → ensure each rationale ≥50 words
   198	    → if any condition fails: ESC_AGENT_OUTPUT_SHAPE (output-shape violation
   199	      per catalogue line 184 — distinct from ESC_SCHEMA_VIOLATION which is
   200	      reserved for vertical-schema field-constraint violations at write time);
   201	      partial draft to /tmp; abort
   202	    → write Markdown report to vault path per §3
   203	    → hh_decision_output("scout_report", report_path, "N candidates from M sources")
   204	
   205	11. Session close + notification
   206	    → operator notification per invocation source (Brain UI: in-app
   207	      notification; Telegram: reply with report path; webhook: bus event back)
   208	    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
   209	      "N=<N> sources_used=<M>")
   210	    → exit code 0
   211	```
   212	
   213	---
   214	
   215	## §5 — Gates
   216	
   217	### Gate A — validate.sh (hard-fail before action)
   218	
   219	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
   220	
   221	- **"5–15 candidates returned per brief"** (count within range)
   222	- **"each has a working contact method"** (email format + MX check OR E.164 phone OR LinkedIn URL OR Bullhorn bullhorn_id-with-contact)
   223	- **"each has rationale ≥ 50 words"**
   224	- **"no candidate flagged 'do not contact' in tenant vault"** (DNC list scan)
   225	- All rationales pass voice classifier ≥0.75
   226	- No PII outside firm boundary in rationale text
   227	- No source contributed 0 candidates (suggests source auth failure undetected by Step 2)
   228	
   229	Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation per catalogue line 184); draft to `/tmp`; operator review.
   230	
   231	**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   232	
   233	### Gate B — Outcome threshold (success metric, not block)
   234	
   235	Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
   236	
   237	Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.
   238	
   239	Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
   240	
   241	Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
   242	
   243	---
   244	
   245	## §6 — Escalation codes
   246	
   247	Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
   248	
   249	| Code | Trigger | Severity | Routing |
   250	|---|---|---|---|
   251	| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (2+ source fails abort) | operator |
   252	| `ESC_LINKEDIN_AUTH` | Proxycurl API key invalid | warn (single-source fail OK if 2+ others succeed) | operator_chat_id |
   253	| `ESC_REED_AUTH` | Reed API fail | warn | operator_chat_id |
   254	| `ESC_CVLIBRARY_AUTH` | CV-Library API fail | warn | operator_chat_id |
   255	| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
   256	| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
   257	| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   258	| `ESC_DNC_FILTER_HIT` | Outbound candidate matches tenant DNC list (per-candidate; blocks the candidate's inclusion) | **blocking** (per-candidate) | operator_chat_id |
   259	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
   260	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |

exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '260,460p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
   261	| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | founder + operator |
   262	
   263	Sourcing Scout does NOT use:
   264	
   265	- `ESC_AUTOSEND_*` — no auto-send actions; pure read + report
   266	- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
   267	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
   268	- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
   269	
   270	---
   271	
   272	## §7 — Voice + tone constraints
   273	
   274	Step 9 (per-candidate rationale generation) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   275	
   276	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
   277	  - No demographic inference (age, gender, nationality, ethnicity, family status) — Equality Act 2010 compliance
   278	  - No salary-band reference unless explicitly supplied by candidate
   279	  - No claims about candidate intent ("looking to leave their role") without evidence in source data
   280	  - No mention of competing agency placements except in risk-flag context
   281	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
   282	- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
   283	
   284	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   285	
   286	---
   287	
   288	## §8 — Build dependencies (W9 prerequisites)
   289	
   290	Sourcing Scout build cannot start until ALL of the following are confirmed:
   291	
   292	| Dependency | Source | Status |
   293	|---|---|---|
   294	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   295	| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
   296	| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
   297	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   298	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   299	| Bullhorn MCP read capability | W3-W4-W5 build chain | ⏸ |
   300	| **Proxycurl commercial signup** + API access | Founder commercial; ~$39+/mo | ⏸ |
   301	| **Reed.co.uk commercial signup** + API access | Founder commercial | ⏸ |
   302	| **CV-Library commercial signup** + API access | Founder commercial | ⏸ |
   303	| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
   304	| Reed MCP connector | W9 build start (~2 days) | ⏸ |
   305	| CV-Library MCP connector | W9 build start (~2 days) | ⏸ |
   306	| Source-abstraction layer (Night Sourcer reuse) | W9 build start (~2 days) | ⏸ |
   307	| Per-tenant source credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   308	| Tenant DNC list at `/vault/<slug>/do-not-contact.list` | Tenant onboarding | ⏸ |
   309	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   310	| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
   311	| `context.sh` hydration | Build at W9 start (~0.5 day) | ⏸ |
   312	| `cycle.sh` orchestration (11-step) | Build at W9 start (~2 days) | ⏸ |
   313	| 3 fixtures with golden outputs | Build at W9 start (~1 day) | ⏸ |
   314	
   315	**Until ALL ⏸ items resolve to ✅, W9 build slice does not start.**
   316	
   317	---
   318	
   319	## §9 — Status + open questions
   320	
   321	**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
   322	
   323	### Open questions for founder review
   324	
   325	| # | Question | Resolution path |
   326	|---|---|---|
   327	| Q1 | All three external sources required for v1.0? Reed + CV-Library are UK-recruitment-specific; Proxycurl is LinkedIn-via-API. Could v1.0 ship with Bullhorn + Proxycurl only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
   328	| Q2 | Proxycurl pricing — ~$39/mo for 5,000 credits at low volume; scales with usage. Per pilot tenant budget? | ~5-10 briefs/day per consultant × 50 calls/brief = up to 2,500 credits/day per consultant. Cost: ~$20-50/day at peak. |
   329	| Q3 | DNC list source — tenant uploads a list, or we derive from Bullhorn entity flag? | v1.0: tenant-uploaded text file at `/vault/<slug>/do-not-contact.list`. v1.1: derive from Bullhorn entity field. |
   330	| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
   331	| Q5 | Gate B 6-of-10 metric — measured via consultant feedback. Brain UI v1.0 doesn't have feedback UX yet. Telegram reply? | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful". v1.1: Brain UI button. |
   332	| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
   333	| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Existing Bullhorn candidate-status enum has "passive" / "active" / "placed". | Founder + Bullhorn-rep clarification during Sub-decision B response. |
   334	
   335	### Gotchas (carried forward from ULTRAPLAN A5 line 555)
   336	
   337	1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
   338	2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
   339	3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.
   340	
   341	---
   342	
   343	## §10 — When this document ratifies
   344	
   345	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   346	
   347	Status flips Proposed → Accepted when:
   348	- Codex Round 4 Phase 2 ratifies
   349	- Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B UX)
   350	- Q2 cost model approved with per-tenant budget cap
   351	- Q6: ADR-006 (source-abstraction layer) drafted + ratified
   352	
   353	Status flips Accepted → In Force when:
   354	- W9 build slice produces all 5 sibling bundle files + 3 fixtures
   355	- First production brief processed end-to-end against migration-test tenant
   356	- Gate B feedback loop operational (Telegram OR Brain UI)
   357	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   358	
   359	Until then: this document is a forward-looking scaffold.
   360	
   361	*End of Sourcing Scout agent.md draft.*

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '20,100p'; nl -ba agents/_shared/autosend-policy.yaml | sed -n '160,190p'; nl -ba agents/_shared/autosend-policy.yaml | sed -n '270,290p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   270	
   271	  diagnostic_calendar_invite:
   272	    tier: orange
   273	    agent: diagnostic
   274	    timeout: PT4H
   275	    reason: "Books intro call with prospect; reputation + scheduling friction"
   276	    irreversible: true
   277	
   278	  linkedin_inmail_send:
   279	    tier: orange
   280	    agent: sourcing-scout
   281	    timeout: PT4H
   282	    reason: "Outbound InMail (paid credit); cost-per-send; customer-facing"
   283	    irreversible: true
   284	
   285	  bullhorn_placement_terminate:
   286	    tier: orange
   287	    agent: janitor
   288	    timeout: PT4H
   289	    reason: "Marks placement as terminated; commercial/legal implications; reversible only via support ticket"
   290	    irreversible: false

codex
REJECTED

1. Step 9 violates the decision-log contract. §3 says “one row per candidate proposed” (lines 96-98) and §4 says every output/action step must call `hh_decision_*` (line 104), but Step 9 generates candidate rationales and drops candidates on `ESC_VOICE_DRIFT` without any `hh_decision_*` call (lines 185-191). Add a per-candidate `hh_decision_output` or equivalent audit row before candidates enter the final list/drop path.

2. Auth escalation severities and routing do not match the catalogue. §6 marks `ESC_LINKEDIN_AUTH`, `ESC_REED_AUTH`, and `ESC_CVLIBRARY_AUTH` as warn/operator-only single-source failures (lines 252-254), but the catalogue defines all three as blocking with `operator_chat_id AND ifos_oncall_chat_id` routing (escalation-codes.md lines 240-261). Align §6/Step 2 with the catalogue or add new degraded-source warning codes before referencing them.

3. `ESC_DNC_FILTER_HIT` is repurposed beyond its catalogue definition. §4 fires it per candidate removed from a sourcing report using `/vault/<slug>/do-not-contact.list` (lines 175-183), while the catalogue defines it as an outbound send refusal loaded from tenant adapter config with `action_type_attempted` payload (escalation-codes.md lines 424-429). Either use the catalogue code only at outbound refusal time, or add a separate sourcing-filter code and schema-backed DNC source.

4. The Bullhorn status question contradicts both the schema and this artefact’s own workflow. §4 correctly says passive is derived and not a vertical-schema enum (lines 135-138), but §9 Q7 claims the existing Bullhorn candidate-status enum has “passive / active / placed” (line 333); vertical-schema.yaml defines `candidate.status` as `[active, archived, do_not_contact, placed, contractor_promoted]` (lines 84-88). Rewrite Q7 as an activity-recency/search-filter clarification, not a status-enum question.
tokens used
128,238
REJECTED

1. Step 9 violates the decision-log contract. §3 says “one row per candidate proposed” (lines 96-98) and §4 says every output/action step must call `hh_decision_*` (line 104), but Step 9 generates candidate rationales and drops candidates on `ESC_VOICE_DRIFT` without any `hh_decision_*` call (lines 185-191). Add a per-candidate `hh_decision_output` or equivalent audit row before candidates enter the final list/drop path.

2. Auth escalation severities and routing do not match the catalogue. §6 marks `ESC_LINKEDIN_AUTH`, `ESC_REED_AUTH`, and `ESC_CVLIBRARY_AUTH` as warn/operator-only single-source failures (lines 252-254), but the catalogue defines all three as blocking with `operator_chat_id AND ifos_oncall_chat_id` routing (escalation-codes.md lines 240-261). Align §6/Step 2 with the catalogue or add new degraded-source warning codes before referencing them.

3. `ESC_DNC_FILTER_HIT` is repurposed beyond its catalogue definition. §4 fires it per candidate removed from a sourcing report using `/vault/<slug>/do-not-contact.list` (lines 175-183), while the catalogue defines it as an outbound send refusal loaded from tenant adapter config with `action_type_attempted` payload (escalation-codes.md lines 424-429). Either use the catalogue code only at outbound refusal time, or add a separate sourcing-filter code and schema-backed DNC source.

4. The Bullhorn status question contradicts both the schema and this artefact’s own workflow. §4 correctly says passive is derived and not a vertical-schema enum (lines 135-138), but §9 Q7 claims the existing Bullhorn candidate-status enum has “passive / active / placed” (line 333); vertical-schema.yaml defines `candidate.status` as `[active, archived, do_not_contact, placed, contractor_promoted]` (lines 84-88). Rewrite Q7 as an activity-recency/search-filter clarification, not a status-enum question.
