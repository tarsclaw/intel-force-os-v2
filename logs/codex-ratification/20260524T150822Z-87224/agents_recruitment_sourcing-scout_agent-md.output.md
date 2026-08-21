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
session id: 019e5a87-b137-7bd3-94ec-9fea88b126fb
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

> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).

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
     + DNC list from `tenant_adapters.config.blocked_recipients` (Postgres-
     backed per ADR-002 vault/Postgres split; canonical v0.1 + v0.2 + v0.3
     registered config key)
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
   → per-source auth FAILURE is BLOCKING per catalogue §2.3/§2.7:
     ESC_BULLHORN_AUTH | ESC_LINKEDIN_AUTH | ESC_REED_AUTH | ESC_CVLIBRARY_AUTH
     — each routes to operator + ifos_oncall. v1.0 v0.3 disposition: if
     ANY source is down, Sourcing Scout halts (any failed source = blocked
     run); waits for operator reauth before retry. Single-source-failure-
     soft-fallback would require a separate ESC_SOURCING_SOURCE_DEGRADED
     catalogue code (W4-polish; not v0.3).
   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
     "sources_ok:<N>/4; failed:<list>")

3. Bullhorn passive-match query
   → bullhorn.search_candidates(filter=brief_key_dimensions,
     status='active', date_last_modified_at < now() - interval '90 days')
     — "passive" is a derived state (active candidate not recently
     modified); NOT a vertical-schema enum value. The schema defines
     candidate.status as [active, archived, do_not_contact, placed,
     contractor_promoted] (line 84-88) and candidate.date_last_modified_at
     as the recency field (line 100). Passive-match queries filter on
     modification recency within the active set.
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

8. "Do not contact" filter (pre-outbound sourcing filter; NOT outbound refusal)
   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
     (already a registered config key per autosend-policy.yaml red-tier
     `send_to_blocked_recipient`; canonical Postgres-stored structured
     state per ADR-002 vault/Postgres split — NOT vault markdown)
   → remove any candidate matching any DNC identifier from the sourcing list
   → log dropped candidates to exception list in §3 output
   → NOTE: ESC_DNC_FILTER_HIT is catalogue §2.10 reserved for OUTBOUND SEND
     REFUSAL specifically. Sourcing Scout filters DNC matches AT SOURCING
     TIME (pre-outbound); no outbound send attempt occurs. v0.3 disposition:
     log DNC drops in exception list only; no ESC fire. W4-polish backlog:
     add ESC_SOURCING_DNC_FILTER for the pre-outbound case.
   → hh_decision_output("dnc_filter", "brief:<id>",
     "dropped:<N>; kept:<N>")

9. LLM ranking + rationale generation (per candidate)
   → for top 15 by source-aggregated confidence: generate per-candidate
     rationale ≥50 words
   → prompt = (brief context + candidate profile + voice corpus + tone rules)
   → voice classifier scores rationale (≥0.75)
   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
     from final list
   → hh_decision_output("candidate_proposed", "candidate:<bullhorn_id|external_ref>",
     "source:<bullhorn|linkedin|reed|cvlibrary>; confidence:<N>; voice_score:<N>; included:<bool>") — emitted PER CANDIDATE per §3 contract (one row per candidate proposed; dropped candidates also get a row with included=false + drop_reason)

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
- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
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
| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (per catalogue §2.3) | operator + ifos_oncall |
| `ESC_LINKEDIN_AUTH` | LinkedIn / Proxycurl session/OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | founder + operator |

Sourcing Scout does NOT use:

- `ESC_AUTOSEND_*` — no auto-send actions; pure read + report
- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
- `ESC_DNC_FILTER_HIT` — per catalogue §2.10 reserved for outbound send refusal specifically; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish backlog: add ESC_SOURCING_DNC_FILTER.

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
| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
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
| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
| Q5 | Gate B 6-of-10 metric — measured via consultant feedback. Brain UI v1.0 doesn't have feedback UX yet. Telegram reply? | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful". v1.1: Brain UI button. |
| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `last_activity_at < now() - 90 days` to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side activity-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |

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
I’ll verify the cited source files and catalogue entries against the artefact, then return only the required verdict format.
exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_AUTH|ESC_LINKEDIN_AUTH|ESC_REED_AUTH|ESC_CVLIBRARY_AUTH|ESC_RATE_LIMIT_HIT|ESC_BRIEF_AMBIGUITY|ESC_VOICE_DRIFT|ESC_PII_LEAKAGE_RISK|ESC_AGENT_OUTPUT_SHAPE|ESC_GATE_B_MISS|ESC_DNC_FILTER_HIT|ESC_VOICE_DRIFT_TENANT|ESC_SCHEMA_VIOLATION" agents/_shared/escalation-codes.md -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
97:#### `ESC_BULLHORN_AUTH`
120:#### `ESC_VOICE_DRIFT`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
184:#### `ESC_AGENT_OUTPUT_SHAPE`
186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
250:- **Trigger:** CV-Library API OAuth failure (same pattern as ESC_REED_AUTH)
256:#### `ESC_LINKEDIN_AUTH`
312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
377:#### `ESC_GATE_B_MISS`
424:#### `ESC_DNC_FILTER_HIT`
466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |

exec
/bin/zsh -lc 'rg -n "Sourcing Scout|A5|Proxycurl|Reed|CV-Library|Night Sourcer|5-15|6 of 10|6-of-10|source-abstraction|W9|Bullhorn" docs agents -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/operations/bullhorn-outreach-emails.md:1:# Bullhorn outreach — ready-to-send email drafts
docs/operations/bullhorn-outreach-emails.md:3:**Status:** Reference (operations playbook for Bullhorn commercial conversations)
docs/operations/bullhorn-outreach-emails.md:5:**Purpose:** Drop-in email drafts the founder sends to Bullhorn partnerships + developer support to resolve Sub-decisions A + B in `docs/decisions/bullhorn-integration-path.md`. Closes Risk #2 mitigation path; unblocks Janitor W5 build gate.
docs/operations/bullhorn-outreach-emails.md:15:- **Sub-decision B** (OAuth flow specifics): we've verified the structural shape from Bullhorn's public docs (authorization-code + refresh-token; per-tenant `corpToken` and `restUrl`). Need confirmation of specifics: refresh-token TTL behaviour, rate-limit caps, sandbox environment availability.
docs/operations/bullhorn-outreach-emails.md:17:**These don't block today.** They block **Janitor W5 build** (per kill-criterion §2 Trigger 3). You have ~5 weeks of runway. But send today/Monday because Bullhorn's response time is 2-5 business days, and we want the answers before Diagnostic W3-4 completes so Janitor W5 starts unblocked.
docs/operations/bullhorn-outreach-emails.md:23:## §2 — Submission 1: Bullhorn Partnerships (Sub-decision A)
docs/operations/bullhorn-outreach-emails.md:29:This is a Marketo form (`mktoForm_8918`) hosted on Bullhorn's site. Scroll down the page; you'll see a multi-field form with name / company / email / phone / message. Fill that out. It routes internally to Bullhorn's partnerships team.
docs/operations/bullhorn-outreach-emails.md:42:> Hi Bullhorn Partnerships team,
docs/operations/bullhorn-outreach-emails.md:44:> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
docs/operations/bullhorn-outreach-emails.md:49:> Is membership in the Marketplace Partner Programme required for production tenants to connect Intel Force OS to their Bullhorn instances? Or can pilot tenants authorise us as a connected app via the standard developer-tier path (support-ticket-issued client_id/client_secret per https://bullhorn.github.io/Getting-Started-with-REST)?
docs/operations/bullhorn-outreach-emails.md:75:- If they offer a Bullhorn Developer Program intermediate tier → that's likely the right path for 2026 H2 pilots; defer marketplace to v1.1+.
docs/operations/bullhorn-outreach-emails.md:80:## §3 — Email 2: Bullhorn Developer Support (Sub-decision B)
docs/operations/bullhorn-outreach-emails.md:82:**Don't send this independently.** Bullhorn's developer portal at `developer.bullhorn.com` is docs-only — no contact form. The "Bullhorn Resource Center" mentioned in their docs is customer-only (we're not a customer yet). The pragmatic path:
docs/operations/bullhorn-outreach-emails.md:89:If partnerships doesn't engage within 2 weeks, fallback: submit via the main corporate contact form at `https://www.bullhorn.com/contact-us/` with "Developer integration enquiry" in the message body, OR LinkedIn outreach to a Bullhorn developer advocate.
docs/operations/bullhorn-outreach-emails.md:93:> Hi Bullhorn Developer Support,
docs/operations/bullhorn-outreach-emails.md:97:> Our architecture: per-tenant OAuth (authorization-code grant) with refresh-token rotation. Each pilot tenant authorises Intel Force OS as a connected app via Bullhorn's standard OAuth flow. We store the refresh_token per-tenant, exchange it for access_tokens + BhRestToken on demand.
docs/operations/bullhorn-outreach-emails.md:102:> What is the documented refresh-token TTL? When a refresh_token is exchanged for a new access_token, does the refresh_token itself rotate (single-use) or remain valid (long-lived)? Our connector polls Bullhorn every 5 minutes per pilot tenant — we need to plan for graceful refresh-token renewal under that cadence.
docs/operations/bullhorn-outreach-emails.md:105:> If two parallel processes for the same pilot tenant attempt token refresh concurrently (race condition), what's the expected server behaviour? Does Bullhorn invalidate the older refresh_token on a successful exchange, or accept both?
docs/operations/bullhorn-outreach-emails.md:108:> Is there a sandbox / staging Bullhorn environment we can use for development without consuming production-tier API budget? If yes, what's the access path (separate credentials, sandbox-only client_id, or in-production with a "test corpToken")?
docs/operations/bullhorn-outreach-emails.md:111:> Does Bullhorn's OAuth 2.0 implementation support the client_credentials grant type for service-account-style access (against our own developer-tier tenant, not pilot tenants)? We want to use this for IFOS-internal CI testing and connector unit-test fixtures. The public docs reference only authorization-code grant.
docs/operations/bullhorn-outreach-emails.md:130:- Sandbox available → use it for CI tests + W5 build. Save credentials to your local 1Password as "IFOS Bullhorn Dev sandbox".
docs/operations/bullhorn-outreach-emails.md:141:2. **Tell Claude:** "Bullhorn partnerships responded — saved at `docs/operations/bullhorn-partnerships-response-2026-05-XX.md`"
docs/operations/bullhorn-outreach-emails.md:147:## §5 — If Bullhorn doesn't respond within a week
docs/operations/bullhorn-outreach-emails.md:152:3. **Wednesday 2026-06-03** — LinkedIn outreach to a named Bullhorn employee in partnerships or developer relations. Search "Bullhorn partnerships" or "Bullhorn developer advocacy" on LinkedIn; aim for a UK-based person if available.
docs/operations/bullhorn-outreach-emails.md:162:*End of Bullhorn outreach emails.*
agents/_shared/autosend-policy.yaml:44:    reason: "Internal-only Bullhorn note (isExternal: false); consultant-visible; non-customer-facing"
agents/_shared/autosend-policy.yaml:110:    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
agents/_shared/autosend-policy.yaml:193:    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
agents/_shared/autosend-policy.yaml:200:    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
agents/_shared/autosend-policy.yaml:225:    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"
agents/_shared/escalation-codes.md:94:### 2.3 — Bullhorn integration (1 code)
agents/_shared/escalation-codes.md:99:- **Trigger:** Bullhorn OAuth token refresh failed twice on the per-agent 8-minute cycle (per `common-ats.json.auth_refresh_interval_seconds`); or REST call returned 401 indefinitely (revoked token in Bullhorn admin UI)
agents/_shared/escalation-codes.md:103:- **Recovery:** agent stays in degraded mode until founder rotates token via Bullhorn admin → next `_secrets.env` reload picks up new token
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:158:- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
agents/_shared/escalation-codes.md:238:Source: derived from v1.0 agent.md adapter references (Bullhorn, Reed, CV-Library, LinkedIn, Gmail, Outlook/MS Graph, Xero, Open Banking)
agents/_shared/escalation-codes.md:242:- **Trigger:** Reed jobs-board API OAuth token refresh failed twice OR REST call returned 401 indefinitely
agents/_shared/escalation-codes.md:246:- **Recovery:** founder rotates Reed API key via Reed admin → `_secrets.env` reload
agents/_shared/escalation-codes.md:250:- **Trigger:** CV-Library API OAuth failure (same pattern as ESC_REED_AUTH)
agents/_shared/escalation-codes.md:254:- **Recovery:** founder rotates CV-Library credentials
agents/_shared/escalation-codes.md:257:- **Severity:** **blocking** — Sourcing Scout enters degraded mode (no profile fetches; cached only)
agents/_shared/escalation-codes.md:262:- **Recovery:** founder reauthenticates LinkedIn via Sourcing Scout admin flow
agents/_shared/escalation-codes.md:312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
agents/_shared/escalation-codes.md:326:- **Trigger:** Generic upstream provider read failure (Companies House, web-scraper, any non-Bullhorn-non-Accounting GET) after retry budget exhausted; distinct from rate-limit
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:402:- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
agents/_shared/escalation-codes.md:410:  - **Cash Conductor:** chase/reminder/invoice addressee does not match Bullhorn placement client OR Xero contact (cross-system reconciliation failure between accounting + ATS)
agents/_shared/escalation-codes.md:443:- **Trigger:** Scribe SLA breached (default: call summary rendered within 30 min of call end; Bullhorn note attached within 1h)
agents/_shared/escalation-codes.md:452:  - **Concierge:** Bullhorn state transition is outside the 12-event v1.0 taxonomy (acknowledgement / prep / debrief / placement / rejection / withdrawal / on-hold / start-confirm / 7d-checkin / 30d-checkin / 90d-checkin / nurture); handler logs + skips draft
agents/_shared/escalation-codes.md:466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
agents/_shared/README.md:161:Production rollout (other tenants) waits for Codex ratification of v0.2 + Diagnostic + Janitor verification of the schema against real Bullhorn data (master brief §6 Day 6 Q3 trigger from v0.1).
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
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:280:#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:290:#   - Sourcing Scout candidate: R → R+W (writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:293:#   - Sourcing Scout opportunity: none → R (reads opportunity context for ICP)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:298:#   - Concierge placement: R → R+W (writes Bullhorn state advancement per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:383:    # Scribe's Bullhorn endpoint access (Candidate / ClientCorporation /
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:386:    # Postgres rows ONLY (not direct Bullhorn endpoint calls). Scribe
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:387:    # uses Bullhorn endpoints for the 5 v1.0-supported entities; other
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:389:    candidate: R+W         # call-summary field extraction (Bullhorn endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:390:    contractor: R+W        # call-summary field extraction (Bullhorn endpoint A3 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:391:    client: R              # IFOS-cached read (Bullhorn endpoint A3 — ClientCorporation)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:392:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:393:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:394:    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields written to IFOS-cached Postgres rows only (Bullhorn Opportunity endpoint NOT used at v1.0 per integration-path §4.1)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:395:    placement: R+W         # check-in field extraction (Bullhorn Placement endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:396:    timesheet: R           # IFOS-cached read; placement-context resolution (Bullhorn Timesheet endpoint NOT used at v1.0)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:399:    # NOTE: Cash Conductor has NO direct Bullhorn endpoint access per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:400:    # bullhorn-integration-path.md §1.2 A4 ("No direct Bullhorn"). All
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:402:    # (populated by Janitor + Scribe + Concierge from their Bullhorn
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:403:    # sync paths). Cash Conductor never calls Bullhorn endpoints directly.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:404:    candidate: none        # no Bullhorn dependency
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:409:    opportunity: R         # v0.3 NEW — IFOS-cached read; invoice-context (NOT a direct Bullhorn call; only cached rows)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:411:    timesheet: R           # IFOS-cached read; verify billable hours match invoice (NOT a direct Bullhorn call)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:417:    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:430:    # Concierge's Bullhorn endpoint access (Candidate / ClientCorporation /
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:433:    # only (not Bullhorn endpoint calls).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:434:    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14 (Bullhorn endpoint A6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:435:    contractor: R+W        # writes lifecycle states for contractor placements too (Bullhorn endpoint A6 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:436:    client: R              # IFOS-cached read (Bullhorn endpoint A6 — ClientCorporation)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:437:    contact: R             # IFOS-cached read; outbound recipient resolution (Bullhorn endpoint A6 — Note context)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:438:    brief: R               # IFOS-cached read (Bullhorn endpoint A6 — JobOrder)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:439:    opportunity: R         # IFOS-cached read; outbound lifecycle-event context (Bullhorn Opportunity endpoint NOT used at v1.0)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:440:    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14 (Bullhorn endpoint A6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:441:    timesheet: R           # IFOS-cached read; placement-progress for 7d/30d/90d nurture (Bullhorn Timesheet endpoint NOT used at v1.0)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:458:    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:464:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:477:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:493:      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:503:      - Sourcing Scout (R) # v0.3 NEW — reads opportunity for ICP scoring
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:508:      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:517:      - Concierge (R+W)    # v0.3 UPGRADED — writes Bullhorn state advancement
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:535:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:540:      - Sourcing Scout (R+W) # v0.3 UPGRADED — writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:543:      v0.3 upgrades Sourcing Scout (writes proposed-candidate rows from
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:548:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:552:      - Sourcing Scout (R+W) # v0.3 UPGRADED — same pattern as candidate
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:562:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:566:      Conductor for chase drafts; Sourcing Scout for per-candidate
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:572:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:577:      Diagnostic + Sourcing Scout also read tone_rules for their
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:589:      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:658:      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor links to Bullhorn placement.client_contact_id)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:763:      Bullhorn for state transitions since this timestamp.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:910:    question: 6-state placement_status enum maps to Bullhorn's native state machine?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:912:      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:913:      B: Add Bullhorn-native states verbatim to the enum (likely 8-10 more).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:917:    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
agents/recruitment/cash-conductor/README.md:14:**Most-independent v1.0 agent.** Zero Bullhorn dependency. Operates against accounting system + Open Banking only. Per ADR-005 §5.1: pull-forward candidate if Bullhorn paths delayed past 2026-06-10.
docs/operations/founder-legal-setup-guide.md:18:2. **Takes autonomous actions** on behalf of recruitment agencies (LinkedIn messages, Bullhorn writes, payment reminders). This creates **professional liability** — if your AI sends a wrong payment chase to a settled invoice, the agency may be liable to the candidate; they may seek to pass that liability to you.
docs/operations/founder-legal-setup-guide.md:121:2. *"My AI agents make autonomous edits to candidate-facing communications and trigger autonomous actions (LinkedIn sends, Bullhorn writes, payment chases). Where does liability sit for AI mistakes? What's the standard liability split — and do SeedLegals or off-the-shelf templates capture it?"*
docs/operations/founder-legal-setup-guide.md:194:> Our specific risk profile includes autonomous AI agents making bounded edits to candidate communications and triggering actions in third-party systems (Bullhorn, LinkedIn, payment systems). I want to ensure liability is appropriately allocated.
docs/operations/founder-legal-setup-guide.md:219:> - AI agents make autonomous actions on behalf of pilot customers (LinkedIn messages, Bullhorn data writes, payment reminders)
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 257; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 182-187 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 257-262; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:345:- Bullhorn-specific codes (no Bullhorn dependency)
agents/recruitment/cash-conductor/agent.md:397:**ADR-005 framing:** ADR-005 (Week-3 Diagnostic acceleration) notes Cash Conductor is unaffected by Bullhorn slips because it has zero Bullhorn dependency. v0.3 supplement: Cash Conductor pull-forward (from W7-8 to W4-5) is NOT explicitly authorised by ADR-005 §5.1 (that section number doesn't exist; earlier draft mis-cited). Pull-forward would require a separate ADR (e.g. ADR-007 if/when needed); accounting + Open Banking commercial signups remain founder-action gates regardless of timing.
docs/operations/codex-ratification-guide.md:198:1. Status field says "Accepted" but §4 (Consequences) says "pending commercial conversations with Bullhorn partnerships team." Status drift. Either flip Status to "Proposed" with Sub-decision C as Accepted-only, or remove the "pending" caveat. Citation: ADR-001 line 7 vs §4.2.
docs/operations/codex-ratification-guide.md:247:Schema YAMLs. Uses `review-schema-change` skill — checks layering, agent matrix consistency, Bullhorn mapping alignment, open-question discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:222:        source: IFOS-derived (entity ID at edit time; Bullhorn ID or IFOS slug)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:436:      Bullhorn data (Q3 trigger from v0.1 §5).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
agents/recruitment/scribe/README.md:16:- `tools.yaml` — Bullhorn W + Fathom R + Fireflies R + voice classifier
agents/recruitment/scribe/README.md:17:- `context.sh` — webhook handler + Bullhorn auth refresh + voice corpus
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/specs/ULTRAPLAN.md:63:| 6 | **Overnight autoresearch** | Long-session capability documented; rate-limit handling tested | This is for the Night Sourcer in v1.1, not v1.0. Defer the question. |
docs/specs/ULTRAPLAN.md:72:- **The file bus.** Inter-agent handoff via shared filesystem directories. No queue, no API, no serialisation tax. Brief Decoder writes a parsed-brief file; Sourcing Scout's `FastChecker` polls it up at the configured cadence (default 1000ms `pollInterval`, configurable per agent); result lands in a sub-directory the Concierge is polling. Four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound.
docs/specs/ULTRAPLAN.md:90:- MCP connectors (Bullhorn, Vincere, Voyager Infinity, Companies House, Microsoft Graph, Xero, Fathom, LinkedIn, AgentMail)
docs/specs/ULTRAPLAN.md:183:- `ESC_BULLHORN_AUTH` — Bullhorn OAuth token expired or revoked
docs/specs/ULTRAPLAN.md:420:| Night Sourcer | ≥ 6 of 10 candidates per brief advance past first consultant review | Decision-log + ATS state query |
docs/specs/ULTRAPLAN.md:495:- **External APIs:** Companies House API (free), LinkedIn (via Proxycurl or similar), basic HTTP fetch
docs/specs/ULTRAPLAN.md:507:- **MCP tools required:** Bullhorn (read-write), Companies House (for entity enrichment)
docs/specs/ULTRAPLAN.md:509:- **External APIs:** Bullhorn REST API, Companies House
docs/specs/ULTRAPLAN.md:512:- **Build complexity:** **L** (2 weeks) — the Bullhorn MCP work is the rate-limiting piece
docs/specs/ULTRAPLAN.md:513:- **Gotchas:** Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0. Estimate 1 week for the MCP server, 1 week for the agent itself. Dedup is hard; start conservative (high-confidence merges only) and tune up.
docs/specs/ULTRAPLAN.md:521:- **MCP tools required:** Bullhorn (write), Fathom (read), Fireflies (read)
docs/specs/ULTRAPLAN.md:523:- **External APIs:** Fathom webhook, Fireflies webhook, Bullhorn for write-back
docs/specs/ULTRAPLAN.md:543:#### A5. Sourcing Scout (daytime form) — request-response sourcing
docs/specs/ULTRAPLAN.md:548:- **CortexOS primitives required:** None for the daytime form (Night Sourcer in v1.1 will use #6)
docs/specs/ULTRAPLAN.md:549:- **MCP tools required:** Bullhorn (read for ATS passive matches), LinkedIn (via Proxycurl or similar), Reed.co.uk API, CV-Library API
docs/specs/ULTRAPLAN.md:551:- **External APIs:** Proxycurl, Reed, CV-Library
docs/specs/ULTRAPLAN.md:553:- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)
docs/specs/ULTRAPLAN.md:555:- **Gotchas:** LinkedIn rate limits via Proxycurl. Reed/CV-Library have separate auth and separate result schemas. Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it.
docs/specs/ULTRAPLAN.md:563:- **MCP tools required:** Bullhorn (read for state, write for activity log), Microsoft Graph / Gmail (send), AgentMail (optional for agent-identity sends)
docs/specs/ULTRAPLAN.md:569:- **Gotchas:** Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks. Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship.
docs/specs/ULTRAPLAN.md:579:- **MCP tools required:** Microsoft Graph or Gmail (read + send), AgentMail (send, where agent-identity is needed), Bullhorn (read for candidate matching), LinkedIn (read)
docs/specs/ULTRAPLAN.md:593:- **MCP tools required:** Bullhorn (read for prior placements + candidates), shared with Sourcing Scout
docs/specs/ULTRAPLAN.md:594:- **Shared modules required:** Voice loader, decision log writer, the Brief Decoder→Sourcing Scout→Concierge orchestration template
docs/specs/ULTRAPLAN.md:595:- **External APIs:** Same as Sourcing Scout (reuses)
docs/specs/ULTRAPLAN.md:599:- **Gotchas:** Brief format varies hugely between clients. Build the parser as schema-driven, not pattern-matching. The orchestration handoff to Sourcing Scout is the load-bearing CortexOS test.
docs/specs/ULTRAPLAN.md:611:- **MCP tools required:** Bullhorn (read for prior relationships + matching candidates), LinkedIn (read for contact identification)
docs/specs/ULTRAPLAN.md:619:#### A11. The Night Sourcer (2 weeks)
docs/specs/ULTRAPLAN.md:625:- **MCP tools required:** Bullhorn, LinkedIn, Reed, CV-Library, GitHub (for tech briefs), Sector-specific (configurable per tenant)
docs/specs/ULTRAPLAN.md:626:- **Shared modules required:** Voice loader, decision log writer, the source-abstraction layer from Sourcing Scout
docs/specs/ULTRAPLAN.md:627:- **External APIs:** Same as Sourcing Scout + GitHub
docs/specs/ULTRAPLAN.md:629:- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared with Sourcing Scout)
docs/specs/ULTRAPLAN.md:630:- **Build complexity:** **M** (2 weeks) — reuses Sourcing Scout's source layer; the new work is the overnight scheduling + rate-limit budget allocation
docs/specs/ULTRAPLAN.md:653:- **MCP tools required:** Bullhorn (contractor data), Voyager Infinity / 3R (where used), Companies House
docs/specs/ULTRAPLAN.md:655:- **External APIs:** Same as Bullhorn + Voyager
docs/specs/ULTRAPLAN.md:669:| Recruitment Reporting | M (1 week) | Bullhorn + accounting + decision log | Mostly a SQL + templating job |
docs/specs/ULTRAPLAN.md:670:| T1 Onboarding Concierge | M (1 week) | Bullhorn (write), DocuSign, Microsoft Graph | Tracks onboarding tasks; less reasoning-heavy |
docs/specs/ULTRAPLAN.md:671:| T2 Sunday-Evening Timesheet Ranger | M (1 week) | Bullhorn/Voyager + Microsoft Graph | The voice quality on per-contractor history is the work |
docs/specs/ULTRAPLAN.md:683:| Agent | Voice | Bullhorn | MSGraph | Xero/Sage | LinkedIn | CoHouse | Reed/CVLib | Fathom | AgentMail | Telegram | Special |
docs/specs/ULTRAPLAN.md:689:| Sourcing Scout | ✓ | ✓ | | | ✓ | | ✓ | | | ✓ | |
docs/specs/ULTRAPLAN.md:694:| Night Sourcer | ✓ | ✓ | | | ✓ | | ✓ | | | ✓ | GitHub |
docs/specs/ULTRAPLAN.md:707:1. **Bullhorn** — 18 of 18 agents need it (or compatible ATS). Top priority.
docs/specs/ULTRAPLAN.md:712:6. **LinkedIn (via Proxycurl)** — 6 of 18. Third-priority.
docs/specs/ULTRAPLAN.md:724:- Bullhorn MCP server is the critical path; week 1 starts on it.
docs/specs/ULTRAPLAN.md:732:| Tue | Decision on Bullhorn integration path (marketplace vs direct); design partner conversation 1 |
docs/specs/ULTRAPLAN.md:735:| Fri | First MCP server scoped (Bullhorn); contract review with first design partner |
docs/specs/ULTRAPLAN.md:740:- Bullhorn integration path decided and documented
docs/specs/ULTRAPLAN.md:750:### Weeks 3–4 — Bullhorn + Diagnostic
docs/specs/ULTRAPLAN.md:752:- Week 3: Bullhorn MCP server build (auth, read endpoints, write endpoints, webhook subscription)
docs/specs/ULTRAPLAN.md:762:Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.
docs/specs/ULTRAPLAN.md:771:### Weeks 9–10 — Sourcing Scout + Concierge start
docs/specs/ULTRAPLAN.md:773:- Week 9: Sourcing Scout (daytime); LinkedIn + Reed + CV-Library integration
docs/specs/ULTRAPLAN.md:818:| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/specs/ULTRAPLAN.md:820:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
docs/specs/ULTRAPLAN.md:822:| 6 | LinkedIn rate limits via Proxycurl are tighter than expected | Medium | Medium | Sourcing Scout cost >£100/run | Negotiate Proxycurl enterprise plan; defer Night Sourcer to v1.2 if needed |
docs/specs/ULTRAPLAN.md:824:| 8 | First pilot's Bullhorn data is too messy for Janitor's dedup confidence threshold | Medium | Medium | <5% dedup proposed in week 6 trial run | Lower threshold to 0.7 for the initial cleanup; ship the day-30 report regardless |
docs/specs/ULTRAPLAN.md:829:| 13 | The Bullhorn API rate limits prevent Janitor from completing its initial sweep on day 1 | Medium | Medium | First sweep takes >24 hours | Initial sweep runs in batches over 3 days; communicate to tenant explicitly |
docs/specs/ULTRAPLAN.md:847:- [ ] Bullhorn integration path decision: marketplace vs direct API. **Owner:** Maddox. **Output:** decision documented in `decisions/bullhorn-integration-path.md`.
docs/specs/ULTRAPLAN.md:860:- [ ] First MCP server scoped: tools.yaml schema for Bullhorn integration documented.
docs/specs/ULTRAPLAN.md:878:- If ≥1 of: design-partner LOI signed + CortexOS primitives 1, 4, 5 working + Bullhorn auth working → proceed to week 1
docs/specs/ULTRAPLAN.md:891:3. Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?
agents/recruitment/scribe/agent.md:3:**Status:** Proposed (Day-17 pre-W6-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice).
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:61:### Output 1 — Bullhorn structured-field writes (≥3 per call)
agents/recruitment/scribe/agent.md:63:Bullhorn entity inferred from call participants + tenant Bullhorn lookup:
agents/recruitment/scribe/agent.md:86:One Markdown note per call, attached to the same Bullhorn entity as Output 1 via `POST /Note`. Structure:
agents/recruitment/scribe/agent.md:100:- <Tone signal 1 — e.g., "client sounded frustrated about Bullhorn data quality">
agents/recruitment/scribe/agent.md:131:   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice
agents/recruitment/scribe/agent.md:141:2. Bullhorn auth refresh
agents/recruitment/scribe/agent.md:152:   → match transcript participants against Bullhorn contacts + candidates
agents/recruitment/scribe/agent.md:155:   → resolve target Bullhorn entity (bullhorn_id + entity_type per
agents/recruitment/scribe/agent.md:186:8. Bullhorn write — structured fields (yellow tier)
agents/recruitment/scribe/agent.md:188:   → atomic transaction; rollback on Bullhorn 4xx/5xx
agents/recruitment/scribe/agent.md:193:9. Bullhorn write — tacit-note attachment (yellow tier)
agents/recruitment/scribe/agent.md:222:- Bullhorn auth refresh succeeded
agents/recruitment/scribe/agent.md:233:- **SLA:** ≥90% of webhooks-to-Bullhorn-write within 5 min
agents/recruitment/scribe/agent.md:249:| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on field write OR note attach | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:257:| `ESC_SCRIBE_SLA_MISS` | Webhook-to-Bullhorn-write >10 min (Gate B miss) | info | (logged; aggregated to Gate B metric) |
agents/recruitment/scribe/agent.md:258:| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:291:| Janitor ratified (Bullhorn auth substrate via W5 build) | W5 Codex Round | ⏸ |
agents/recruitment/scribe/agent.md:293:| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
agents/recruitment/scribe/agent.md:294:| Bullhorn MCP write capability | W3-W4-W5 build chain | ⏸ |
agents/recruitment/scribe/agent.md:313:**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
agents/recruitment/scribe/agent.md:319:| Q1 | Fathom vs Fireflies — first-mover provider for v1.0? Both have UK presence; Fathom has tighter Bullhorn ecosystem ties; Fireflies has broader transcript model coverage. | Commercial decision; depends on first pilot tenant's existing tooling. |
agents/recruitment/scribe/agent.md:323:| Q5 | Bullhorn write atomicity — Step 9 rollback of Step 8 on note-attach failure is best-effort PATCH. Could leave entity in mid-state. | v1.0 accept; document risk. v1.1+: investigate Bullhorn transaction API if exposed. |
agents/recruitment/scribe/agent.md:324:| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
agents/recruitment/scribe/agent.md:325:| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |
docs/architecture/architecture-cohesion-review.md:92:| A5 | **The cortextOS daemon `discoverAgents()` filters by directory pattern, not contents.** Means `.tmp.<pid>/` + `.prev.<ts>/` dirs are invisible. | ADR-003 §3.3.4 atomic-write protocol | If daemon scan ever changes to content-based discovery, the atomic-write protocol could expose half-rendered state. Verified against pinned SHA `c21fbfe`. |
docs/architecture/architecture-cohesion-review.md:95:| A8 | **Bullhorn OAuth refresh-loop fires before token expiry under load.** Per-agent 8-min cycle vs 10-min TTL. | bullhorn-integration-path.md §4.5 + common-ats.json `auth_refresh_interval_seconds` | If the 2-min buffer is insufficient under network latency or rate-limit backoff, agent loses Bullhorn auth mid-write. Untested at scale; flagged at first Janitor build. |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:235:| R9 | A8: Bullhorn OAuth refresh timing under load | Low | First Janitor build stress test | Claude Code | Janitor W5 |
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:23:| 7 | **Master-brief-drift-accumulation** — eight ADR-driven edits + one Day-4 Postgres-rename + multiple Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all nine edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Codex ratifies the commit alongside the ten+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 + `bullhorn-integration-path.md` + `sequencing-target.md` + `brain-ui-scope.md` + Day 4 runbook §0.1. **Updated Day 4 (2026-05-17):** edit count rose from 8 to 9 with Day-4 Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations" — verified from Day-4 execution against NBG1 because FSN1 was unavailable at provisioning time). **Citation audit 2026-05-18:** earlier drafts also cited master brief §10.4 as a Hetzner/cost-target section; verified §10.4 is the Codex exclusion list ("What never goes through ratification") and contains no Hetzner or cost-target content. Edit 9 scope corrected to line 477 only. |
docs/RISK-REGISTER.md:55:- 2026-05-22 (Day 11) — **Codex Round 2 autonomous ratification complete.** 26 artefacts reviewed; 17 RATIFIED / 9 REJECTED. Manifest §1.7 appended and full outputs written to `logs/codex-ratification/round-2-autonomous/`. D5 skill softening ratified. Bullhorn gate disagreement rejected because the promised source-doc sharpening did not land. Autosend policy, v0.2 supplement, approval bridge, PII purge runbook/script/forward migration, and tenancy audit script remain rejected. **New Risk #11** added for transactionless `SET LOCAL` usage across live DB scripts/helpers. **New Risk #12** added for the PII purge migration/script mismatch with `recent_edit.original_text NOT NULL`.
docs/RISK-REGISTER.md:60:- 2026-05-16 (Day 2) — Risk #2 status entry updated: Sub-decision C **Accepted** per `bullhorn-integration-path.md` §4 + §5; Sub-decisions A and B **Proposed** with named reduction triggers (Sunday/Monday commercial conversations). Two staged severity reductions specified (High → Medium on commercial answers; Medium → Low on first Week 3-4 Bullhorn write landing clean). Risk #7 edit count revised from 5 to 6 (Bullhorn decision §6.6 sixth edit added — master brief §6 Day 2 line 466 `service-account for dev` correction). No new risks surfaced from Day 2 — Sub-decisions A and B Proposed is the intended honest state pending commercial verification, not a new risk surface.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
agents/recruitment/sourcing-scout/README.md:1:# Sourcing Scout — directory README
agents/recruitment/sourcing-scout/README.md:3:**Status:** Proposed (Day-19 pre-W9-build scaffold).
agents/recruitment/sourcing-scout/README.md:14:Full bundle at W9 build (~2 weeks per ULTRAPLAN A5 line 554):
agents/recruitment/sourcing-scout/README.md:16:- `tools.yaml` — Bullhorn R + Proxycurl + Reed + CV-Library + source-abstraction layer
agents/recruitment/sourcing-scout/README.md:18:- `validate.sh` — Gate A (5-15 candidates + contact method + ≥50 words + DNC + voice ≥0.75)
agents/recruitment/sourcing-scout/README.md:25:## Night Sourcer (v1.1) reuse
agents/recruitment/sourcing-scout/README.md:27:Per ULTRAPLAN A5 line 555 gotcha: source-abstraction layer designed for Night Sourcer reuse. Defer ADR-006 to W9 build start documenting the layer's interface.
agents/recruitment/sourcing-scout/README.md:33:*End of Sourcing Scout README.*
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:122:| Sourcing Scout | ~5-7 (count regex 50) | `logs/codex-ratification/20260524T1024...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:159:1. **Autosend tier contradiction internal to artefact:** §1 says all Bullhorn writes yellow-tier; §3.Output 2 mapped tacit-note to `bullhorn_candidate_tag` which is GREEN. Internal §1/§3/§4 inconsistency.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:276:| Sourcing Scout | 4 | `20260524T113139Z-84869` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:284:- Sourcing Scout ULTRAPLAN A5 line refs: Gate A 553→552, Gate B 554→553 (4 citation sites)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:318:  - Sourcing Scout per-candidate decision rows (claimed in §3 but not in §4 cycle)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:333:- Sourcing Scout: pre-build-scaffold; Round-8-reviewed; minimal residual (catalogue-widening + per-candidate decision rows)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:374:| Sourcing Scout | 4 | 5 | +1 (Q7 enum claim missed by my Round-8 fix; Bullhorn webhook conflict newly surfaced) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:389:**Sourcing Scout R9:**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:391:2. ESC auth severity downgrade vs catalogue — Codex–founder disagreement (Sourcing Scout intentionally allows single-source auth failure as warn-only when 2+ sources remain; catalogue defines blocking. Real semantic divergence; needs catalogue widening OR Sourcing Scout agent.md realignment)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:393:4. Bullhorn webhook v1.0 trigger conflicts with bullhorn-integration-path.md (webhooks v1.1+ only) — Cat-β-adjacent; agent.md should remove v1.0 webhook trigger
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:419:4. **Catalogue v2 widening for ESC_DNC_FILTER_HIT + Sourcing Scout auth severity** — Cat-γ continuations
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:430:| Sourcing Scout | Pre-Build-Round-9-Reviewed | 5 (Cat-α Q7 + bullhorn-path conflict + Cat-γ DNC + Cat-ε per-candidate row + auth severity disagreement) | Mechanical Q7 fix + Bullhorn-path realignment + ESC widening 2 |
docs/verticals/recruitment/vertical-schema.yaml:34:#   - bullhorn_source: the Bullhorn entity (and any status filter) this maps from
docs/verticals/recruitment/vertical-schema.yaml:41:# `source: Bullhorn.<Entity>.<field>` means sourced from Bullhorn at ingest;
docs/verticals/recruitment/vertical-schema.yaml:51:    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
docs/verticals/recruitment/vertical-schema.yaml:55:      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:61:        source: Bullhorn.Candidate.id
docs/verticals/recruitment/vertical-schema.yaml:62:        notes: Adapter-layer primary key for Bullhorn round-trip. Stable across ingests.
docs/verticals/recruitment/vertical-schema.yaml:66:        source: Bullhorn.Candidate.firstName
docs/verticals/recruitment/vertical-schema.yaml:70:        source: Bullhorn.Candidate.lastName
docs/verticals/recruitment/vertical-schema.yaml:74:        source: Bullhorn.Candidate.email
docs/verticals/recruitment/vertical-schema.yaml:79:        source: Bullhorn.Candidate.phone
docs/verticals/recruitment/vertical-schema.yaml:83:        source: Bullhorn.Candidate.mobile
docs/verticals/recruitment/vertical-schema.yaml:87:        source: Bullhorn.Candidate.status
docs/verticals/recruitment/vertical-schema.yaml:94:        source: Bullhorn.Candidate.owner.id
docs/verticals/recruitment/vertical-schema.yaml:95:        notes: Bullhorn user (consultant) who owns this candidate record.
docs/verticals/recruitment/vertical-schema.yaml:99:        source: Bullhorn.Candidate.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:103:        source: Bullhorn.Candidate.dateLastModified
docs/verticals/recruitment/vertical-schema.yaml:107:        source: Bullhorn.Candidate.occupation
docs/verticals/recruitment/vertical-schema.yaml:111:        source: Bullhorn.Candidate.companyName
docs/verticals/recruitment/vertical-schema.yaml:127:        source: Bullhorn.Candidate.address.city
docs/verticals/recruitment/vertical-schema.yaml:141:        source: IFOS-derived (set by Sourcing Scout at first-touch)
docs/verticals/recruitment/vertical-schema.yaml:150:      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
docs/verticals/recruitment/vertical-schema.yaml:156:    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:169:        source: Bullhorn.Candidate.id
docs/verticals/recruitment/vertical-schema.yaml:170:        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
docs/verticals/recruitment/vertical-schema.yaml:174:        source: Bullhorn.Candidate.firstName
docs/verticals/recruitment/vertical-schema.yaml:178:        source: Bullhorn.Candidate.lastName
docs/verticals/recruitment/vertical-schema.yaml:182:        source: Bullhorn.Candidate.email
docs/verticals/recruitment/vertical-schema.yaml:186:        source: Bullhorn.Candidate.mobile
docs/verticals/recruitment/vertical-schema.yaml:218:      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
docs/verticals/recruitment/vertical-schema.yaml:223:      A company that hires through the recruitment agency. Master brief canonical vocabulary at §3.2 line 155 ("candidate, placement, brief") implicitly assumes client as the holder of briefs. Bullhorn calls this `ClientCorporation`.
docs/verticals/recruitment/vertical-schema.yaml:224:    bullhorn_source: Bullhorn.ClientCorporation
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:233:        source: Bullhorn.ClientCorporation.id
docs/verticals/recruitment/vertical-schema.yaml:237:        source: Bullhorn.ClientCorporation.name
docs/verticals/recruitment/vertical-schema.yaml:241:        source: Bullhorn.ClientCorporation.industryList
docs/verticals/recruitment/vertical-schema.yaml:242:        notes: Bullhorn stores as multi-value; v0.1 flattens to primary industry only.
docs/verticals/recruitment/vertical-schema.yaml:247:        source: Bullhorn.ClientCorporation.numEmployees (bucketed)
docs/verticals/recruitment/vertical-schema.yaml:251:        source: Bullhorn.ClientCorporation.companyURL
docs/verticals/recruitment/vertical-schema.yaml:265:        source: Bullhorn.ClientCorporation.owner.id
docs/verticals/recruitment/vertical-schema.yaml:273:        source: Bullhorn.ClientCorporation.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:277:        source: Bullhorn.ClientCorporation.address.city
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:285:      A person at a client company. Decision-makers, hiring managers, HR, procurement. Bullhorn calls this `ClientContact`. v1.0 representation is thin (10 fields); v1.1 Triage agent expands decision-authority modelling.
docs/verticals/recruitment/vertical-schema.yaml:286:    bullhorn_source: Bullhorn.ClientContact
docs/verticals/recruitment/vertical-schema.yaml:294:        source: Bullhorn.ClientContact.id
docs/verticals/recruitment/vertical-schema.yaml:298:        source: Bullhorn.ClientContact.firstName
docs/verticals/recruitment/vertical-schema.yaml:302:        source: Bullhorn.ClientContact.lastName
docs/verticals/recruitment/vertical-schema.yaml:306:        source: Bullhorn.ClientContact.email
docs/verticals/recruitment/vertical-schema.yaml:310:        source: Bullhorn.ClientContact.phone
docs/verticals/recruitment/vertical-schema.yaml:314:        source: Bullhorn.ClientContact.title
docs/verticals/recruitment/vertical-schema.yaml:330:        source: Bullhorn.ClientContact.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:343:      A role being recruited for. Master brief canonical vocabulary uses `brief`; §6 Day 6 line 490 lists "Role/Brief" — `brief` is the canonical entity_type slug; `role` is documented alias. Bullhorn calls this `JobOrder`.
docs/verticals/recruitment/vertical-schema.yaml:344:    bullhorn_source: Bullhorn.JobOrder
docs/verticals/recruitment/vertical-schema.yaml:349:      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:355:        source: Bullhorn.JobOrder.id
docs/verticals/recruitment/vertical-schema.yaml:359:        source: Bullhorn.JobOrder.title
docs/verticals/recruitment/vertical-schema.yaml:364:        source: Bullhorn.JobOrder.publicDescription
docs/verticals/recruitment/vertical-schema.yaml:370:        source: Bullhorn.JobOrder.employmentType (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:374:        source: Bullhorn.JobOrder.salary
docs/verticals/recruitment/vertical-schema.yaml:379:        source: Bullhorn.JobOrder.salaryUnit (range parsing)
docs/verticals/recruitment/vertical-schema.yaml:391:        source: Bullhorn.JobOrder.address.city
docs/verticals/recruitment/vertical-schema.yaml:415:        source: Bullhorn.JobOrder.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:419:        source: Bullhorn.JobOrder.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:423:        source: Bullhorn.JobOrder.dateLastModified
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:432:    bullhorn_source: Bullhorn.Placement
docs/verticals/recruitment/vertical-schema.yaml:441:        source: Bullhorn.Placement.id
docs/verticals/recruitment/vertical-schema.yaml:445:        source: Bullhorn.Placement.dateBegin
docs/verticals/recruitment/vertical-schema.yaml:449:        source: Bullhorn.Placement.dateEnd
docs/verticals/recruitment/vertical-schema.yaml:455:        source: Bullhorn.Placement.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:460:        source: Bullhorn.Placement.employmentType (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:464:        source: Bullhorn.Placement.fee
docs/verticals/recruitment/vertical-schema.yaml:469:        source: Bullhorn.Placement.feeArrangement (parsed)
docs/verticals/recruitment/vertical-schema.yaml:474:        source: Bullhorn.Placement.salary
docs/verticals/recruitment/vertical-schema.yaml:489:        source: Bullhorn.Placement.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:498:    bullhorn_source: Bullhorn.JobSubmission (or Bullhorn.Opportunity — tenant-config dependent; some tenants use one, some both)
docs/verticals/recruitment/vertical-schema.yaml:508:        source: Bullhorn.JobSubmission.id
docs/verticals/recruitment/vertical-schema.yaml:513:        source: Bullhorn.JobSubmission.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:525:        source: Bullhorn.JobSubmission.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:529:        source: Bullhorn.JobSubmission.dateLastModified
docs/verticals/recruitment/vertical-schema.yaml:538:    bullhorn_source: Bullhorn.Timesheet (Bullhorn has a Timesheet entity; tenant-config dependent)
docs/verticals/recruitment/vertical-schema.yaml:548:        source: Bullhorn.Timesheet.id
docs/verticals/recruitment/vertical-schema.yaml:552:        source: Bullhorn.Timesheet.weekStartDate
docs/verticals/recruitment/vertical-schema.yaml:556:        source: Bullhorn.Timesheet.totalHours
docs/verticals/recruitment/vertical-schema.yaml:560:        source: Bullhorn.Timesheet.status (parsed)
docs/verticals/recruitment/vertical-schema.yaml:568:        source: Bullhorn.Timesheet.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:570:      - v0.1 placeholder. T2 + T6 builds in v2.0 verify field set against real Bullhorn data.
docs/verticals/recruitment/vertical-schema.yaml:606:    v1_0_exercise: All 4 Bullhorn-touching v1.0 agents.
docs/verticals/recruitment/vertical-schema.yaml:637:    v1_0_exercise: Sourcing Scout captures at first-touch when relevant; not heavily exercised in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
docs/verticals/recruitment/vertical-schema.yaml:703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
docs/verticals/recruitment/vertical-schema.yaml:708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
docs/verticals/recruitment/vertical-schema.yaml:733:# §4 — Bullhorn mapping
docs/verticals/recruitment/vertical-schema.yaml:735:# Per-entity Bullhorn source + field-level mapping notes.
docs/verticals/recruitment/vertical-schema.yaml:736:# Verifies against real Bullhorn data at Week 3-4 Janitor build per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:742:    bullhorn_entity: Bullhorn.Candidate
docs/verticals/recruitment/vertical-schema.yaml:745:    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:748:    bullhorn_entity: Bullhorn.Candidate
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:752:    notes: Adapter layer materialises both `candidate` and `contractor` entity_type rows from the same Bullhorn.Candidate record when status flips. See entity-level notes.
docs/verticals/recruitment/vertical-schema.yaml:755:    bullhorn_entity: Bullhorn.ClientCorporation
docs/verticals/recruitment/vertical-schema.yaml:757:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
docs/verticals/recruitment/vertical-schema.yaml:761:    bullhorn_entity: Bullhorn.ClientContact
docs/verticals/recruitment/vertical-schema.yaml:763:    field_mapping_density: v0.1 covers 10 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. v1.1 Triage expands contact-side coverage.
docs/verticals/recruitment/vertical-schema.yaml:766:    bullhorn_entity: Bullhorn.JobOrder
docs/verticals/recruitment/vertical-schema.yaml:768:    field_mapping_density: v0.1 covers 17 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. Note Bullhorn customText1-25 fields are tenant-specific and require per-tenant adapter mapping not standard schema work.
docs/verticals/recruitment/vertical-schema.yaml:769:    notes: Skills extraction (required_skills, nice_to_have_skills arrays) is IFOS-derived from JD body, not Bullhorn-sourced (Bullhorn does not consistently structure skill fields across tenants).
docs/verticals/recruitment/vertical-schema.yaml:772:    bullhorn_entity: Bullhorn.Placement
docs/verticals/recruitment/vertical-schema.yaml:774:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:775:    notes: lifecycle_stage is IFOS-derived (Concierge maintains); Bullhorn does not natively store IFOS's nurture-cadence stages.
docs/verticals/recruitment/vertical-schema.yaml:778:    bullhorn_entity: Bullhorn.JobSubmission (or Bullhorn.Opportunity depending on tenant configuration)
docs/verticals/recruitment/vertical-schema.yaml:780:    field_mapping_density: v0.1 covers 5 fields (placeholder shape); full Bullhorn field-density TBD pending v1.1 Brief Decoder / Inbound Triage build.
docs/verticals/recruitment/vertical-schema.yaml:781:    notes: Tenant-config dependent — some Bullhorn tenants use JobSubmission, some use Opportunity, some both. Adapter layer resolves at ingest.
docs/verticals/recruitment/vertical-schema.yaml:784:    bullhorn_entity: Bullhorn.Timesheet
docs/verticals/recruitment/vertical-schema.yaml:786:    field_mapping_density: v0.1 covers 7 fields (placeholder shape); full Bullhorn field-density TBD pending v2.0 T2 Timesheet + T6 Pay & Bill builds.
docs/verticals/recruitment/vertical-schema.yaml:799:    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:811:    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
docs/verticals/recruitment/vertical-schema.yaml:828:    revisit_trigger: v2.0 T2 Timesheet agent build verifies against real Bullhorn data and expands.
docs/verticals/recruitment/vertical-schema.yaml:841:    revisit_trigger: Skill-matching accuracy from Sourcing Scout's first 4 tenant-weeks of operation; if free-text matching produces <60% precision, canonical skill taxonomy lands as v1.1.
docs/verticals/recruitment/vertical-schema.yaml:870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.
docs/verticals/recruitment/vertical-schema.yaml:886:      Structural cut. 8 entities + 10 relationships + agent-access matrix + Bullhorn mapping. Minimal field sets (10-20 per entity). 12 open questions catalogued (Q1, Q4 resolved at Day 6; Q2, Q3, Q5-Q12 deferred with named triggers).
docs/verticals/recruitment/vertical-schema.yaml:890:    expected_date: post Week 3-4 (after Janitor build verifies against real Bullhorn data)
docs/verticals/recruitment/vertical-schema.yaml:892:      Codex-ratified version. Field sets expanded per Janitor's real-Bullhorn-data findings (Q3 trigger). Possibly Note entity promoted to entity_type if Janitor surfaces query patterns (Q2 trigger). 2-3 revisions expected from v0.1.
docs/operations/codex-round-2-remediation-prompt.md:203:      voice-loader — none of which reference Bullhorn). A+B MUST flip
docs/operations/codex-round-2-remediation-prompt.md:213:  Three distinct gates govern Bullhorn-touching work, in temporal order:
docs/operations/codex-round-2-remediation-prompt.md:218:  | Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (sequencing-target §2.1) | Awaits Q1 LOI |
docs/architecture/agent-bundle-renderer-design.md:45:| `tools.yaml` (line 554) | MCP servers + scopes + degraded modes for external execution backends (Bullhorn, Companies House, Microsoft Graph etc. per master brief §3.2 first-party MCP list) | the renderer (passes through to rendered agent dir); agent uses it via Claude Code's MCP loading at PTY spawn time | **Static** — founder writes once per agent |
docs/architecture/agent-bundle-renderer-design.md:228:On every ATS state change (Bullhorn webhook) or scheduled lifecycle event
docs/architecture/agent-bundle-renderer-design.md:437:BULLHORN_OAUTH_TOKEN=<acme Bullhorn OAuth bearer>
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/specs/_archive-build-handoff.md:55:│  • MCP connectors (Bullhorn, MS Graph, Companies House) │
docs/specs/_archive-build-handoff.md:243:### Day 2 — Bullhorn integration path
docs/specs/_archive-build-handoff.md:246:- Bullhorn Marketplace (vetted, slower onboarding, may have revenue share) vs Direct API (faster, requires per-tenant OAuth setup)
docs/specs/_archive-build-handoff.md:249:Bullhorn is the critical path for 18-of-18 agents. Get this right.
docs/specs/_archive-build-handoff.md:266:Also Day 4: scope the first MCP server (Bullhorn) — document the `tools.yaml` shape per the Pattern Reference and the Composio/AgentMail adoption doc §3.5. Note: per the adoption doc, Bullhorn is **first-party MCP** (vertical-specific). Composio is *not* the path for it.
docs/specs/_archive-build-handoff.md:302:3. Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path? Y/N
docs/specs/_archive-build-handoff.md:360:- Negotiating Bullhorn marketplace terms — that's a phone call
docs/specs/_archive-build-handoff.md:378:| 2 | **Janitor** | 5 | Bullhorn MCP (read + write) | First demoable inside-the-ATS result; day-30 before/after report closes deals |
docs/specs/_archive-build-handoff.md:379:| 3 | **Scribe** | 6 | Fathom/Fireflies MCP + Bullhorn write | The post-call note that lands in Bullhorn within 10 min is the second-most-demoable result |
docs/specs/_archive-build-handoff.md:381:| 5 | **Sourcing Scout** | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
docs/specs/_archive-build-handoff.md:382:| 6 | **Concierge** | 10–13 | Bullhorn + Microsoft Graph + AgentMail | First Tier 1 always-on closing demo; 4-week build |
docs/specs/_archive-build-handoff.md:384:After Concierge ships, the first pilot converts to paid (Week 14 milestone). v1.1 then layers Triage, Brief Decoder, Competitor Interception, Night Sourcer, and the Temp agents T5 + T3.
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/specs/_archive-build-handoff.md:399:- Bullhorn, Vincere, Voyager Infinity, Acturis, Open GI, SSP, Applied Epic
docs/specs/_archive-build-handoff.md:409:**For Day 4 (first MCP scope):** Bullhorn is first-party. Composio is not the path. Build the connector at `packages/mcp-connectors/bullhorn/` per the Pattern Reference's `tools.yaml` shape.
docs/specs/_archive-build-handoff.md:450:| "Let me use Composio for the Bullhorn connector..." | §6 of this doc |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
agents/recruitment/janitor/README.md:3:**Status:** Proposed (Day-16 pre-W5-build scaffold; awaits Bullhorn A+B + Q1 LOI + W5 build slice).
agents/recruitment/janitor/README.md:16:- `tools.yaml` — MCP declarations: Bullhorn R+W, Companies House, voice classifier
agents/recruitment/janitor/README.md:17:- `context.sh` — Session hydration (Bullhorn auth refresh + voice corpus + recent edits)
agents/recruitment/janitor/README.md:18:- `validate.sh` — Gate A (dedup confidence ≥0.85 + activity-window 90d + field-source confidence ≥0.7 + voice ≥0.75 + PII boundary + Bullhorn batch ≤100/min)
agents/recruitment/janitor/README.md:20:- `cleanup.sh` — Post-run cleanup (rotate Bullhorn refresh token; flush stale cache)
agents/recruitment/janitor/README.md:28:- Bullhorn Sub-decisions A+B Accepted (per Bullhorn partnerships form submitted 2026-05-24)
agents/recruitment/janitor/README.md:30:- Bullhorn MCP connector built (W3-W4 conditional per ADR-005)
agents/recruitment/diagnostic/agent.md:47:**v0 source-coverage state:** Companies House data (§1, §10) is live via `@ifos/companies-house` MCP connector. Web-scraped pages (§2 footprint URLs, §8 careers-page pain signals) are live via `@ifos/web-scraper`. **LinkedIn deep-data sections (§3 job posts, §5 placement timeline, §7 employee skills, §9 competitor employee scan, §11 decision-maker profiles) currently use `@ifos/diagnostic-generator` stub-with-Companies-House-fallback citations** — Proxycurl integration deferred to W4 polish per ADR-005. Each LinkedIn-dependent section still emits ≥1 evidence link (per-section Gate A satisfied) by falling back to Companies House URLs, but the data depth is degraded vs the full-coverage W4 target.
agents/recruitment/diagnostic/agent.md:52:| 2 | **Online footprint** | Primary website URL + last-updated signal; LinkedIn company page URL + follower count + last-post recency; careers page URL + state (active / placeholder / 404) | Web-scraper (HEAD + first 200 lines) ✅ | + LinkedIn company-page Proxycurl fetch |
agents/recruitment/diagnostic/agent.md:55:| 5 | **Deal-size band proxy** | Salary bands or day-rate ranges in job posts; level distribution; recent placements via LinkedIn timeline | **v0: stub with Companies House fallback** | LinkedIn job posts + Proxycurl employee timeline |
agents/recruitment/diagnostic/agent.md:57:| 7 | **Tech stack signals** | Technologies named in JDs + LinkedIn skills aggregated from current employees + tools mentioned in director posts | **v0: stub with Companies House fallback** | LinkedIn JDs + Proxycurl employee profiles |
agents/recruitment/diagnostic/agent.md:182:- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
agents/recruitment/diagnostic/agent.md:216:| LinkedIn read-only via web-scraper | `packages/utilities/web-scraper/` | ✅ Shipped Day 13; 12/12 tests passing (Proxycurl deferred to W4) |
agents/recruitment/diagnostic/agent.md:240:| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | v0 (Day 13 ship) skipped Proxycurl: LinkedIn deep-data sections (§3, §5, §7, §9, §11) use Companies House fallback citations per §3 table. W4 polish slice will commercially sign up for Proxycurl OR alternative (PhantomBuster, Bright Data, scraper.api) and wire it in. Cost: ~$39/mo at low volume per Proxycurl pricing. |
agents/recruitment/diagnostic/agent.md:241:| Q4 | Gate B (30% discovery-call-to-report ratio) measured how? Manual tagging by consultant OR auto-detection via Bullhorn calendar links? | v1.0 manual tagging via Telegram resolution; v1.1 auto-detection. |
agents/recruitment/sourcing-scout/agent.md:1:# Sourcing Scout — request-response passive sourcing
agents/recruitment/sourcing-scout/agent.md:3:**Status:** Proposed (Day-19 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice).
agents/recruitment/sourcing-scout/agent.md:6:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:7:**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
agents/recruitment/sourcing-scout/agent.md:8:**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.
agents/recruitment/sourcing-scout/agent.md:16:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:24:Brain UI v1.0 "Source candidates" button on any brief detail page → POST internal API → Sourcing Scout webhook.
agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
agents/recruitment/sourcing-scout/agent.md:46:- Night Sourcer Tier-1 always-on (Brain UI dashboard; cortextOS primitive #6)
agents/recruitment/sourcing-scout/agent.md:57:# Sourcing Scout — <Brief title>
agents/recruitment/sourcing-scout/agent.md:58:**Generated:** <ISO-date>  **Brief ID:** <Bullhorn-brief-id>  **Tenant:** <slug>
agents/recruitment/sourcing-scout/agent.md:59:**Sources searched:** Bullhorn ATS + LinkedIn (Proxycurl) + Reed + CV-Library
agents/recruitment/sourcing-scout/agent.md:60:**Aggregate candidates:** <N> (top 5-15 ranked)
agents/recruitment/sourcing-scout/agent.md:68:**Source:** Bullhorn (passive match) | **Contact:** <method + verified>
agents/recruitment/sourcing-scout/agent.md:71:requirements + candidate background; cites Bullhorn placement history,
agents/recruitment/sourcing-scout/agent.md:74:"prefers contract not perm per Bullhorn note">
agents/recruitment/sourcing-scout/agent.md:75:**Profile links:** [Bullhorn](url) | [LinkedIn](url)
agents/recruitment/sourcing-scout/agent.md:80:(5-15 candidates total)
agents/recruitment/sourcing-scout/agent.md:85:| Bullhorn ATS | <N> | <score> | n/a (no quota) |
agents/recruitment/sourcing-scout/agent.md:86:| LinkedIn (Proxycurl) | <N> | <score> | <remaining> |
agents/recruitment/sourcing-scout/agent.md:87:| Reed | <N> | <score> | <remaining> |
agents/recruitment/sourcing-scout/agent.md:88:| CV-Library | <N> | <score> | <remaining> |
agents/recruitment/sourcing-scout/agent.md:91:- <Any source failures (e.g., "Reed API 429; retried once; 3 candidates lost")>
agents/recruitment/sourcing-scout/agent.md:124:   → bullhorn (read-only); LinkedIn/Proxycurl; Reed; CV-Library
agents/recruitment/sourcing-scout/agent.md:128:     ANY source is down, Sourcing Scout halts (any failed source = blocked
agents/recruitment/sourcing-scout/agent.md:135:3. Bullhorn passive-match query
agents/recruitment/sourcing-scout/agent.md:145:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
agents/recruitment/sourcing-scout/agent.md:148:4. LinkedIn search (via Proxycurl)
agents/recruitment/sourcing-scout/agent.md:153:   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
agents/recruitment/sourcing-scout/agent.md:156:5. Reed query
agents/recruitment/sourcing-scout/agent.md:163:6. CV-Library query
agents/recruitment/sourcing-scout/agent.md:174:   → annotate each row with source provenance (e.g., "from Bullhorn + LinkedIn
agents/recruitment/sourcing-scout/agent.md:187:     REFUSAL specifically. Sourcing Scout filters DNC matches AT SOURCING
agents/recruitment/sourcing-scout/agent.md:205:    → ensure 5-15 candidates remaining after Step 9
agents/recruitment/sourcing-scout/agent.md:230:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
agents/recruitment/sourcing-scout/agent.md:233:- **"each has a working contact method"** (email format + MX check OR E.164 phone OR LinkedIn URL OR Bullhorn bullhorn_id-with-contact)
agents/recruitment/sourcing-scout/agent.md:242:**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/sourcing-scout/agent.md:246:Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
agents/recruitment/sourcing-scout/agent.md:248:Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.
agents/recruitment/sourcing-scout/agent.md:250:Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
agents/recruitment/sourcing-scout/agent.md:252:Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
agents/recruitment/sourcing-scout/agent.md:258:Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/sourcing-scout/agent.md:262:| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (per catalogue §2.3) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:263:| `ESC_LINKEDIN_AUTH` | LinkedIn / Proxycurl session/OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:264:| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:265:| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:271:| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | founder + operator |
agents/recruitment/sourcing-scout/agent.md:273:Sourcing Scout does NOT use:
agents/recruitment/sourcing-scout/agent.md:276:- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
agents/recruitment/sourcing-scout/agent.md:277:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
agents/recruitment/sourcing-scout/agent.md:278:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/sourcing-scout/agent.md:279:- `ESC_DNC_FILTER_HIT` — per catalogue §2.10 reserved for outbound send refusal specifically; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish backlog: add ESC_SOURCING_DNC_FILTER.
agents/recruitment/sourcing-scout/agent.md:293:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
agents/recruitment/sourcing-scout/agent.md:299:## §8 — Build dependencies (W9 prerequisites)
agents/recruitment/sourcing-scout/agent.md:301:Sourcing Scout build cannot start until ALL of the following are confirmed:
agents/recruitment/sourcing-scout/agent.md:307:| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
agents/recruitment/sourcing-scout/agent.md:309:| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
agents/recruitment/sourcing-scout/agent.md:310:| Bullhorn MCP read capability | W3-W4-W5 build chain | ⏸ |
agents/recruitment/sourcing-scout/agent.md:311:| **Proxycurl commercial signup** + API access | Founder commercial; ~$39+/mo | ⏸ |
agents/recruitment/sourcing-scout/agent.md:312:| **Reed.co.uk commercial signup** + API access | Founder commercial | ⏸ |
agents/recruitment/sourcing-scout/agent.md:313:| **CV-Library commercial signup** + API access | Founder commercial | ⏸ |
agents/recruitment/sourcing-scout/agent.md:314:| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:315:| Reed MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:316:| CV-Library MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:317:| Source-abstraction layer (Night Sourcer reuse) | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:321:| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:322:| `context.sh` hydration | Build at W9 start (~0.5 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:323:| `cycle.sh` orchestration (11-step) | Build at W9 start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:324:| 3 fixtures with golden outputs | Build at W9 start (~1 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:326:**Until ALL ⏸ items resolve to ✅, W9 build slice does not start.**
agents/recruitment/sourcing-scout/agent.md:332:**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:338:| Q1 | All three external sources required for v1.0? Reed + CV-Library are UK-recruitment-specific; Proxycurl is LinkedIn-via-API. Could v1.0 ship with Bullhorn + Proxycurl only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
agents/recruitment/sourcing-scout/agent.md:339:| Q2 | Proxycurl pricing — ~$39/mo for 5,000 credits at low volume; scales with usage. Per pilot tenant budget? | ~5-10 briefs/day per consultant × 50 calls/brief = up to 2,500 credits/day per consultant. Cost: ~$20-50/day at peak. |
agents/recruitment/sourcing-scout/agent.md:340:| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
agents/recruitment/sourcing-scout/agent.md:341:| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
agents/recruitment/sourcing-scout/agent.md:342:| Q5 | Gate B 6-of-10 metric — measured via consultant feedback. Brain UI v1.0 doesn't have feedback UX yet. Telegram reply? | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful". v1.1: Brain UI button. |
agents/recruitment/sourcing-scout/agent.md:343:| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
agents/recruitment/sourcing-scout/agent.md:344:| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `last_activity_at < now() - 90 days` to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side activity-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |
agents/recruitment/sourcing-scout/agent.md:346:### Gotchas (carried forward from ULTRAPLAN A5 line 555)
agents/recruitment/sourcing-scout/agent.md:348:1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
agents/recruitment/sourcing-scout/agent.md:349:2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
agents/recruitment/sourcing-scout/agent.md:350:3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.
agents/recruitment/sourcing-scout/agent.md:362:- Q6: ADR-006 (source-abstraction layer) drafted + ratified
agents/recruitment/sourcing-scout/agent.md:365:- W9 build slice produces all 5 sibling bundle files + 3 fixtures
agents/recruitment/sourcing-scout/agent.md:372:*End of Sourcing Scout agent.md draft.*
agents/recruitment/diagnostic/cycle.sh:32:# Proxycurl deep-data integration deferred to W4 polish per ADR-005.
agents/recruitment/diagnostic/cycle.sh:118:# data deferred to W4 (Proxycurl). Voice classifier gate skipped at v0.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:34:**Cost of deferral:** Concierge W10 build risks slipping if bridge isn't ready. Concrete delay: ~3 days. Risk #2 (Bullhorn) is the bigger blocker for Concierge (auth path); D1 is downstream of that.
docs/operations/codex-ratification-execution-plan.md:353:- **Option β** — Wait for Q1 = YES. Rationale: master brief §10.6 framed first ratification run as Day 7; once-Week-0-closes implies the design-partner LOI exists. Some artefacts (Bullhorn integration Sub-decisions A+B) genuinely change post-commercial-conversations.
agents/recruitment/diagnostic/fixtures/01-primary.yaml:74:      last_updated_signal: "2026-05-15"
agents/recruitment/concierge/README.md:20:- `tools.yaml` — Bullhorn R+W + Microsoft Graph + Gmail + voice classifier + autosend bridge (per D1 outcome)
docs/specs/PRODUCT-SPEC.md:17:Intel Force OS is the always-on operating system for UK recruitment agencies. It runs on CortexOS as the persistent agent runtime, lives inside each firm's existing stack (Bullhorn / Vincere / Voyager Infinity, Xero / Sage, Microsoft 365 / Google Workspace), and ships as two coordinated product lines — **IntelForce Recruit** for the front office and **IntelForce Temp** for the back office. Together they replace the operational drag of an entire junior team and, more importantly, generate revenue: surfaced BD opportunities, intercepted competitor briefs, faster cash collection, dormant-candidate reactivation, and post-placement nurture that compounds into referrals. The firm pays £499–£6,950/month per front-office tier and a separate £1,950–£5,950/month for the temp sub-platform. Every agent is pitched against a single, quantified outcome the buyer can verify within 90 days. Configuration scales because the moat is the per-vertical schema, not per-customer plumbing — onboarding becomes a 5-day wizard, not a 5-week project.
docs/specs/PRODUCT-SPEC.md:92:#### R4. The Night Sourcer — overnight sourcing while you sleep
docs/specs/PRODUCT-SPEC.md:99:- **Per-tenant config:** sourcing playbook path, source budget (LinkedIn / Reed / CV Library / GitHub / sector-specific), candidate-rejection patterns, must-haves vs nice-to-haves taxonomy, draft tone overrides per role family.
docs/specs/PRODUCT-SPEC.md:101:#### R5. Sourcing Scout (daytime form) — request-response sourcing during the day
docs/specs/PRODUCT-SPEC.md:104:- **Revenue story:** Same as the Night Sourcer for daytime urgency. Modelled: cuts intake-call-to-first-shortlist time from same-week to same-hour for urgent briefs.
docs/specs/PRODUCT-SPEC.md:108:- **Per-tenant config:** shared with Night Sourcer (same playbook, same source budget).
docs/specs/PRODUCT-SPEC.md:139:- **Output contract:** Day-1 cleanup report (the closing artefact in sales): "Your Bullhorn has 47,000 records, 18% duplicates, 31% with stale contact details, 12% past your retention window, 23% with empty right-to-work fields." Day-30 before/after report. Then continuous: every new record cleaned, deduplicated, enriched, and compliance-checked as it lands.
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:244:| **Growth** (11–25 fee earners) | £3,250 | All Boutique + Night Sourcer, Brief Decoder, Spec Pitcher, Real-Time Pulse, Competitor Interception, Recruitment Reporting | "5–10 net-new retainers/year from BD + Competitor Interception. 30%+ more briefs per consultant via Night Sourcer. 1–2 saved client relationships/year worth £30k–£100k each." |
docs/specs/PRODUCT-SPEC.md:329:- Customer clicks 5 OAuth buttons in the wizard: ATS (Bullhorn / Vincere / Voyager), accounting (Xero / Sage / QuickBooks), Microsoft 365 or Google Workspace, transcript source (Fathom / Fireflies / Ringover), LinkedIn.
docs/specs/PRODUCT-SPEC.md:365:Each per-agent config then has only its agent-specific keys (e.g., the Night Sourcer's source budget allocation, Pulse's signal weights). This means a typical agent's `config.schema.json` is 30 lines, not 300. Scales.
docs/specs/PRODUCT-SPEC.md:400:| 3 | Inter-agent file bus — agents hand work to each other via shared directories | Brief Decoder → Sourcing Scout → Concierge handoff; Triage → specialist-agent routing |
docs/specs/PRODUCT-SPEC.md:403:| 6 | Overnight autoresearch — long sessions against rate-limited APIs | Night Sourcer, Spec Pitcher (batch overnight runs) |
docs/specs/PRODUCT-SPEC.md:453:- **No ATS replacement.** We sit on top of Bullhorn / Vincere / Voyager. We do not become the system of record. This is non-negotiable for two reasons: customer switching cost is too high to replace the ATS, and our defensible IP is the schema layer, not the data store.
docs/specs/PRODUCT-SPEC.md:476:- Sourcing Scout (daytime form)
docs/specs/PRODUCT-SPEC.md:486:3. **Night Sourcer** (2 weeks) — overnight extension of Sourcing Scout
docs/specs/PRODUCT-SPEC.md:525:4. **Night Sourcer** — "Walk in to 27 reviewed candidates across your live briefs every morning."
docs/specs/PRODUCT-SPEC.md:526:5. **Sourcing Scout (daytime)** — "Shortlist in 15 minutes instead of by end of week."
agents/recruitment/diagnostic/tools.yaml:3:# Status: Proposed (Day-19; @ifos/web-scraper + @ifos/companies-house MCP connectors shipped Day 13; LinkedIn via web-scraper page-fetch in v0; Proxycurl deferred to W4 polish).
agents/recruitment/diagnostic/tools.yaml:54:      Read-only LinkedIn API (provider TBD at W3 build start — Proxycurl
agents/recruitment/diagnostic/tools.yaml:61:      - LINKEDIN_API_KEY  # provider-specific; Proxycurl or alternative
agents/recruitment/diagnostic/tools.yaml:69:      per_window: 100  # Proxycurl default per second
agents/recruitment/diagnostic/tools.yaml:182:  - linkedin_readonly_mcp_connector  # ~2 days at W3 start (Proxycurl wrapper)
docs/architecture/cortexos-primitive-status.md:27:| 6 | Overnight autoresearch (theta wave) | **shipped and tested** | None in v1.0; v1.1 Night Sourcer |
docs/architecture/cortexos-primitive-status.md:64:- v1.1: A7 Inbound Triage, A10 Competitor Interception, A11 Night Sourcer (with primitive 6), A12 T5 Supply Chain Auditor, A13 T3 Compliance Watchtower all require it.
docs/architecture/cortexos-primitive-status.md:182:1. **No `chokidar` watcher in the bus.** The bus is poll-based, not push-based. `grep -rn chokidar src/` returns zero hits; `chokidar@^5.0.0` in `package.json:47` is used only by `dashboard/src/lib/watcher.ts:5` for the dashboard UI's file change feed, not for inter-agent message delivery. Master brief §2.4 row 3's "chokidar watcher in daemon" is incorrect against the verified SHA. The actual dispatcher is `FastChecker` polling at `pollInterval` (default 1000ms, configurable). Operational impact: message-delivery latency is bounded by the poll interval, not zero-latency event-driven; relevant for the Brief Decoder → Sourcing Scout → Concierge "four-agent pipelines complete in seconds" claim (Ultraplan §3.2). With 1s polling per hop and 3 hops, end-to-end is ≥3s, not sub-second.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:324:- Master brief §2.4 row 5: every Tier-1 agent's escalation path. Triage, Concierge, Cash Conductor, Pulse, Watchtower, Brief Decoder, Competitor Interception, Night Sourcer, T5, Timesheet Ranger — they all escalate via Telegram and approve via Telegram inline buttons.
docs/architecture/cortexos-primitive-status.md:370:Full experiment lifecycle code, dedicated sprint-3 test file, fully-documented 8-phase theta-wave skill shipped in the `analyst` template. Approval-gate integration ties it back into primitive 4. Not on the v1.0 critical path — Ultraplan §3.1 row 6 already defers it to v1.1 Night Sourcer.
docs/architecture/cortexos-primitive-status.md:388:- Master brief §2.4 row 6: Night Sourcer + Spec Pitcher (Product Spec R4 + R11).
docs/architecture/cortexos-primitive-status.md:389:- v1.0: **No agent depends on this.** Ultraplan §3.1 row 6: "This is for the Night Sourcer in v1.1, not v1.0. Defer the question."
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/operations/codex-round-2-autonomous-prompt.md:198:    - Bullhorn Week-1 gate (item 20): <RATIFIED|REJECTED>
docs/decisions/2026-05-18-day-7-single-sentence-test.md:18:> 3. Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?
docs/decisions/2026-05-18-day-7-single-sentence-test.md:34:- **Pipeline state:** zero design partners in pipeline as of 2026-05-18 Day 5; founder did not initiate the Sunday/Monday outreach paths queued in `bullhorn-integration-path.md` §1.3 (Bullhorn partnerships, Bullhorn dev support, design partner #1) because no named target existed for design-partner #1 path; warm-path strategy supersedes cold outreach.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:57:  - **Bullhorn partnerships outreach** (`partnerships@bullhorn.com`): not sent. Confirms marketplace-vs-direct cost delta at 3-tenant scale + production-tenant partnership requirement.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:58:  - **Bullhorn developer support outreach** (developer.bullhorn.com): not sent. Confirms auth-code flow specifics, sandbox / dev tenant model, per-entity OAuth scope granularity, refresh-token rotation atomicity.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:59:  - **Design partner #1 conversation 2** (ATS confirmation): not had. The design partner gap from Q1 means we cannot confirm pilot #1 actually uses Bullhorn vs a different ATS.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:60:- **Risk #2 in `docs/RISK-REGISTER.md`** carries Bullhorn auth path status: High while Sub-decisions A and B are Proposed. Reduction trigger to Medium requires the commercial conversations to land.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:79:- **Depth:** 89 canonical fields, 10 entity_links relationships, agent × entity R/W matrix across all 6 v1.0 agents (cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3), Bullhorn mapping per entity, 12 open questions catalogued (Q1+Q4 resolved inline; Q2/Q3/Q5-Q12 deferred with named revisit triggers).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:92:| 3 | ATS decided + auth cleared? | **NO** | Build decided YES (Bullhorn); auth path NOT cleared (Sub-decisions A+B Proposed, no commercial outreach) |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:116:5. **Bullhorn commercial conversations** — `partnerships@bullhorn.com`, Bullhorn dev support, design-partner #1 ATS confirmation. Flips Sub-decisions A+B Proposed → Accepted, reduces Risk #2 from High to Medium, resolves Q3 partially.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:133:- If re-run produces 4 of 5 YES (Q3 still NO because Bullhorn commercial conversations haven't completed), founder may accept Q3 as risk-noted and declare Week 0 closed with Week 1 starting under that accepted risk. This is a founder-discretion call, not automatic from the master brief test.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:134:- If re-run produces 5 of 5 YES (Q3 also turns YES because design partner #1 confirms Bullhorn and commercial gates align), Week 0 closes cleanly.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:138:Bullhorn commercial conversations (`partnerships@bullhorn.com`, Bullhorn dev support) flip Sub-decisions A+B Proposed → Accepted regardless of Q1 status. These conversations don't unblock Week 1 alone but they reduce Risk #2 from High to Medium and tighten the auth-path readiness.
agents/recruitment/janitor/agent.md:3:**Status:** Proposed (Day-16 pre-W5-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice).
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:29:Resolved by cortextOS daemon → spawns Janitor in Tier-2 batch mode (no persistent PTY). Typical runtime per tenant: 15-45 min depending on Bullhorn corpus size.
agents/recruitment/janitor/agent.md:37:`--dry-run` reports what WOULD be written without touching Bullhorn. `--report-only` regenerates the day-30 report without doing dedup/enrichment passes (used post-incident for manual report regeneration).
agents/recruitment/janitor/agent.md:59:| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:62:| 7 | **Exception list** | Failed writes (Bullhorn 4xx/5xx, FK violations); rate-limit hits; dedup proposals flagged for review (confidence between 0.7-0.85); operator action items |
agents/recruitment/janitor/agent.md:65:### Output 2 — Bullhorn writes (yellow tier)
agents/recruitment/janitor/agent.md:69:1. **Candidate merge** (`PUT /Candidate/{primary_id}` + cascade) — only when confidence ≥0.85 per Gate A; no merge if either candidate had Bullhorn activity in last 90 days without explicit review flag (per ULTRAPLAN A2 line 510 verbatim). Action type: **`bullhorn_candidate_dedupe`** (existing in autosend-policy.yaml line 69; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:83:   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice corpus
agents/recruitment/janitor/agent.md:87:1. Bullhorn auth refresh
agents/recruitment/janitor/agent.md:92:2. Bullhorn entity scan (read-only)
agents/recruitment/janitor/agent.md:97:   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per §1.1.2 of v0.2 supplement)
agents/recruitment/janitor/agent.md:103:   → discard pairs where EITHER candidate has Bullhorn activity in last 90d
agents/recruitment/janitor/agent.md:128:7. LinkedIn enrichment (candidates; v1.1 via Proxycurl)
agents/recruitment/janitor/agent.md:129:   → at v1.0: skipped (LinkedIn deep data deferred to W4 polish; Proxycurl
agents/recruitment/janitor/agent.md:143:9. Bullhorn write batch (yellow tier — spot-check sampling)
agents/recruitment/janitor/agent.md:179:- Bullhorn auth refresh succeeded in Step 1 (no stale token writes)
agents/recruitment/janitor/agent.md:184:- Bullhorn write batch size ≤ 100 per minute (rate-limit defensive)
agents/recruitment/janitor/agent.md:208:| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on merge/backfill/note write | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:209:| `ESC_RATE_LIMIT_HIT` | Bullhorn or Companies House 429 | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:231:  - No identifying language about candidates beyond what's in their CV / Bullhorn record
agents/recruitment/janitor/agent.md:250:| **Bullhorn Sub-decision A Accepted** | Bullhorn partnerships response | ⏸ Form submitted 2026-05-24; 2-5 business days |
agents/recruitment/janitor/agent.md:251:| **Bullhorn Sub-decision B Accepted** | Bullhorn developer support routing | ⏸ Same |
agents/recruitment/janitor/agent.md:252:| Bullhorn MCP connector built | W3-W4 conditional (per ADR-005 sequencing) | ⏸ Not started |
agents/recruitment/janitor/agent.md:253:| Bullhorn client_id + client_secret obtained | Tenant pilot OAuth ticket (or marketplace credentials if A=marketplace) | ⏸ Post-A+B Accept |
agents/recruitment/janitor/agent.md:263:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
agents/recruitment/janitor/agent.md:269:**Status:** Proposed. Awaits Bullhorn A+B Accepted + Q1 LOI + W5 build slice start.
agents/recruitment/janitor/agent.md:277:| Q3 | Bullhorn write batch size — current default 100/min. Bullhorn published rate-limit isn't documented; we may need to negotiate. | Bullhorn commercial conversation Sub-decision B output. |
agents/recruitment/janitor/agent.md:284:1. **Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0.** Estimate 1 week for the MCP server, 1 week for the agent itself (per ULTRAPLAN A2 line 513).
agents/recruitment/janitor/agent.md:286:3. **Bullhorn webhook coverage is patchy** (per ULTRAPLAN A6 line 569 — Concierge note applies cross-agent). Janitor relies on polling not webhooks; safer for nightly cron pattern.
agents/recruitment/janitor/agent.md:297:- Q3 resolves via Bullhorn Sub-decision B answer
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/decisions/ADR-003-agent-bundle-renderer.md:145:**For Week 0 remaining (Day 2 through Day 7).** ADR-003 doesn't unblock or block any remaining Week 0 work directly. Day 2 (Bullhorn integration path), Day 3 (sequencing + Brain UI scope), Day 4 (Postgres provisioning with `entities` + `entity_links` split per ADR-002 Edit 3 + `_secrets.env` skeleton), Day 5 (auto-send safety policy + kill criterion), Day 6 (vertical schema v0.1), Day 7 (single-sentence test + first Codex ratification) all proceed independently. The renderer is queued for Codex Day-7 review but does not gate Day 7's other reviews.
agents/recruitment/concierge/agent.md:3:**Status:** Proposed (Day-19 pre-W10-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice).
agents/recruitment/concierge/agent.md:6:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier (`gmail_outlook_send_to_candidate` or `bullhorn_note_customer_visible` depending on channel per autosend-policy.yaml lines 122-149). Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is a Gate B leading metric (warning + aggregated; NOT a Gate A hard-fail) per the same ULTRAPLAN line — making it a hard-fail would block legitimate delayed drafts caused by Bullhorn polling fallbacks. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:25:# Bullhorn placement state-change webhook → Concierge handler
agents/recruitment/concierge/agent.md:39:Bullhorn webhook coverage is patchy per ULTRAPLAN A6 line 570 gotcha — see Step 1 polling fallback.
agents/recruitment/concierge/agent.md:44:# Every 5 min: poll Bullhorn for missed state transitions
agents/recruitment/concierge/agent.md:106:- `bullhorn_note_customer_visible` (line 122) when channel=Bullhorn note with isExternal=true
agents/recruitment/concierge/agent.md:110:Consultant approves via autosend-bridge (D1 path) → orange-tier send executes → Bullhorn activity-log entry written post-send.
agents/recruitment/concierge/agent.md:120:   → context.sh hydrates: tenant config + Bullhorn auth refresh +
agents/recruitment/concierge/agent.md:127:   → mode=webhook: parse Bullhorn payload → resolve entity + state transition
agents/recruitment/concierge/agent.md:128:   → mode=poll: query Bullhorn for placements/candidates with state_changed_at
agents/recruitment/concierge/agent.md:131:   → mode=nurture-sweep: query Bullhorn placements for time-elapsed events
agents/recruitment/concierge/agent.md:148:3. Bullhorn context fetch
agents/recruitment/concierge/agent.md:153:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
agents/recruitment/concierge/agent.md:232:      [or `bullhorn_note_customer_visible` if channel=Bullhorn-note]
agents/recruitment/concierge/agent.md:235:13. Bullhorn activity-log write
agents/recruitment/concierge/agent.md:238:    → maintains audit trail in Bullhorn itself
agents/recruitment/concierge/agent.md:242:14. Lifecycle state advance (Bullhorn write, conditional)
agents/recruitment/concierge/agent.md:243:    → some events trigger Bullhorn state changes (e.g., interview-completed
agents/recruitment/concierge/agent.md:271:- All Bullhorn context fields present (no missing candidate name / no missing email) — hard-fail (ESC_CANDIDATE_DATA_INCOMPLETE)
agents/recruitment/concierge/agent.md:298:| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:301:| `ESC_LIFECYCLE_STATE_UNKNOWN` | Bullhorn state transition not in 12-event taxonomy | warn (handler logs + skips draft) | operator_chat_id |
agents/recruitment/concierge/agent.md:302:| `ESC_CANDIDATE_DATA_INCOMPLETE` | Missing email / name in Bullhorn entity | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:356:| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
agents/recruitment/concierge/agent.md:359:| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
agents/recruitment/concierge/agent.md:360:| Bullhorn MCP R+W capability | W3-W4-W5 build chain | ⏸ |
agents/recruitment/concierge/agent.md:374:| Lifecycle event-detection polling fallback | Build at W11-12 (~3 days; Bullhorn webhook coverage gaps) | ⏸ |
agents/recruitment/concierge/agent.md:384:**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + D1 founder decision + Q1 LOI + W10-13 build slice.
agents/recruitment/concierge/agent.md:398:| Q9 | Cross-tenant lifecycle handling — what if a candidate placed at Tenant A's client interviews at Tenant B 6 weeks later? Bullhorn has separate tenant slugs; no cross-tenant leak. But operator visibility? | v1.0: strict tenant isolation (no cross-tenant data visibility). v1.1+: separate agent for tenant-network-graph if commercial demand. |
agents/recruitment/concierge/agent.md:403:1. **Lifecycle event detection from Bullhorn is the unreliable bit.** Bullhorn's webhook coverage is patchy; polling fallbacks are required. Step 1 polling at 5-min cycle + anti-duplicate guard at Step 2 is the architecture.
agents/recruitment/concierge/agent.md:423:- 12-event taxonomy validated against first pilot tenant's actual Bullhorn state-change patterns
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
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:19:4. **`docs/specs/ULTRAPLAN.md`** §8.1 in full (per-agent A1-A6 specs, lines 495-572) + §9 (Bullhorn critical path, lines 720-770) + §10 (risk rows + contingencies)
docs/operations/goal-week-3-polish-and-scaffold.md:23:8. **`docs/decisions/bullhorn-integration-path.md`** §1.3 (commercial-blocker table) + §1.4 (fallback architecture) + §4.1 (per-agent Bullhorn surface)
docs/operations/goal-week-3-polish-and-scaffold.md:52:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:53:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:77:14. **`docs/RISK-REGISTER.md`** updated: Risk #2 (Bullhorn) blast radius confirmed reduced; Risk #5 (Renderer) state per Diagnostic ratification.
docs/operations/goal-week-3-polish-and-scaffold.md:101:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:102:| Bullhorn MCP connector wiring | Gated on Bullhorn Sub-decisions A+B response (sent 2026-05-24; expect 2-5 business days; if arrives mid-week, fold update into the relevant agent.md but do NOT start connector code) |
docs/operations/goal-week-3-polish-and-scaffold.md:105:| Proxycurl signup | Founder commercial action; gated on founder decision (cost ~$39/mo); if founder approves mid-week, wire LinkedIn deep data into Diagnostic |
docs/operations/goal-week-3-polish-and-scaffold.md:292:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:293:- `bullhorn-integration-path.md` §4.1 (Janitor's Bullhorn entity surface)
docs/operations/goal-week-3-polish-and-scaffold.md:300:- **Status:** Proposed (pre-W5-build; awaits Bullhorn A+B + first pilot LOI)
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
docs/operations/goal-week-3-polish-and-scaffold.md:310:- **§8 Build prerequisites:** Bullhorn MCP connector wired (W3 conditional; W4-5 if A+B answered) + first pilot tenant with Bullhorn corpToken in `_secrets.env`.
docs/operations/goal-week-3-polish-and-scaffold.md:311:- **§9 Open questions:** 4-6 questions covering dedup-heuristic confidence threshold, field-completeness priority order, Bullhorn write batch size, day-30 report distribution path.
docs/operations/goal-week-3-polish-and-scaffold.md:330:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:331:- `bullhorn-integration-path.md` §4.1 (Scribe's Bullhorn write surface)
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:339:- **§3 Output shape:** Bullhorn write payload (entity-type-specific JSON) + 1 tacit-note attachment + 1 audit row in decision_log.
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
docs/operations/goal-week-3-polish-and-scaffold.md:341:- **§5 Gate A:** validate.sh hard-fails on missing transcript, field-extraction confidence <0.6, Bullhorn write FK-violation, voice-classifier <0.75 on tacit note.
docs/operations/goal-week-3-polish-and-scaffold.md:345:- **§8 Build prerequisites:** Bullhorn MCP connector (R+W) + Fathom/Fireflies MCP connector (founder commercial signup) + LLM extraction prompt + voice classifier microservice (W5+).
docs/operations/goal-week-3-polish-and-scaffold.md:361:- ADR-005 §5.1 (Cash Conductor independence from Bullhorn — strategic value)
docs/operations/goal-week-3-polish-and-scaffold.md:365:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:367:- **§1 Output contract:** reconciles invoices against bank deposits; chases overdue payments via approved orange-tier email drafts (consultant approves before send); writes payment status updates to accounting system; generates weekly cash-flow report to `/vault/<tenant>/cash-conductor-reports/`. No Bullhorn dependency — operates entirely against Xero / QuickBooks / Sage + Open Banking.
docs/operations/goal-week-3-polish-and-scaffold.md:381:### DAY 19 — Sourcing Scout + Concierge agent.md scaffolds (Steps 11-12)
docs/operations/goal-week-3-polish-and-scaffold.md:386:- ULTRAPLAN §8.1 A5 lines 547-558 (Sourcing Scout spec)
docs/operations/goal-week-3-polish-and-scaffold.md:387:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:388:- `bullhorn-integration-path.md` §4.1 (Sourcing Scout's Bullhorn read surface)
docs/operations/goal-week-3-polish-and-scaffold.md:389:- `vertical-schema.yaml` §3 agent_access_matrix Sourcing Scout row
docs/operations/goal-week-3-polish-and-scaffold.md:393:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:395:- **§1 Output contract:** ingests brief description; ranks passive candidates from Bullhorn database + LinkedIn search; outputs ranked match list with explanation per candidate.
docs/operations/goal-week-3-polish-and-scaffold.md:396:- **§3 Output shape:** Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-id>-<ISO-date>.md` with ranked candidate list (typically 5-20 matches); per-candidate confidence score + match rationale + Bullhorn CRN + LinkedIn URL.
docs/operations/goal-week-3-polish-and-scaffold.md:397:- **§4 Workflow:** ~10 steps. Brief fetch → keyword extraction → Bullhorn candidate search (filtered) → LinkedIn search (via Proxycurl or equiv) → semantic ranking → confidence scoring → match rationale generation → report assembly.
docs/operations/goal-week-3-polish-and-scaffold.md:402:- **§8 Build prerequisites:** Bullhorn MCP read + LinkedIn integration (Proxycurl signup OR LinkedIn API partner-tier) + ranking model (LLM-based or embedding-based).
docs/operations/goal-week-3-polish-and-scaffold.md:407:Commit: `decision(pre-build): agents/recruitment/sourcing-scout/agent.md — output contract per ULTRAPLAN §8.1 A5`
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:416:- `bullhorn-integration-path.md` §4.1 (Concierge's Bullhorn write surface)
docs/operations/goal-week-3-polish-and-scaffold.md:421:- **Tier:** Tier 1 (continuous; lifecycle-event-driven via Bullhorn poll cycle)
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **§1 Output contract:** monitors Bullhorn placement-state transitions (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → day-7-check-in → day-30-check-in → day-90-check-in); generates customer-facing communication drafts at each lifecycle event; orange-tier autosend per Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:423:- **§3 Output shape:** message drafts (email / Bullhorn note customer-visible / SMS as configured); decision-log audit row per send; orange-tier spot-check sampling at 1-in-N rate per autosend-safety-policy §4.
docs/operations/goal-week-3-polish-and-scaffold.md:424:- **§4 Workflow:** ~15 steps. Bullhorn poll every 5 min → detect state transition → fetch context (candidate + client + placement entities) → identify message template → LLM draft → voice classifier ≥0.75 → tone-rule check → tier classification → autosend bridge call (per D1 decision) → audit row.
docs/operations/goal-week-3-polish-and-scaffold.md:429:- **§8 Build prerequisites:** D1 autosend orange-tier decision RESOLVED + Bullhorn MCP R+W + voice classifier microservice live + approval bridge built (per D1 outcome) + tenant tone_rule table seeded.
docs/operations/goal-week-3-polish-and-scaffold.md:459:1. **`.agents/current-priorities.md`** — Day-20 Week-3 close section. List shipped artefacts. Update Open backlog: Week 4 (Cash Conductor build OR Bullhorn-dependent agent depending on A+B status).
docs/operations/goal-week-3-polish-and-scaffold.md:460:2. **`docs/RISK-REGISTER.md`** — Risk #2 (Bullhorn) status per A+B response state; Risk #5 (Renderer) updated per Diagnostic ratification.
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Founder approves Proxycurl signup mid-week | Wire LinkedIn deep data into Diagnostic via a new `@ifos/linkedin-proxycurl` package (similar to companies-house pattern); commit as separate slice; out of scope for goal §1 but high-value |
docs/operations/goal-week-3-polish-and-scaffold.md:529:- Any external service requiring paid signup (Proxycurl, Fathom, Xero dev, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:619:  Sourcing Scout (W9):    <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:647:  Track 1 (Bullhorn-INDEPENDENT — proceed regardless of A+B response):
docs/operations/goal-week-3-polish-and-scaffold.md:651:    - Diagnostic LinkedIn deep data (if Proxycurl signed up)
docs/operations/goal-week-3-polish-and-scaffold.md:653:  Track 2 (Bullhorn-GATED — conditional on A+B Accepted):
docs/operations/goal-week-3-polish-and-scaffold.md:654:    - Bullhorn MCP connector (auth + read + write endpoints)
docs/operations/goal-week-3-polish-and-scaffold.md:655:    - Janitor build (depends on Bullhorn R+W)
docs/operations/goal-week-3-polish-and-scaffold.md:656:    - Scribe build (depends on Bullhorn W + Fathom MCP)
docs/operations/goal-week-3-polish-and-scaffold.md:660:  - <Proxycurl signup if approved>
docs/operations/goal-week-3-polish-and-scaffold.md:669:  - Approve Track 1 vs Track 2 priority (depends on Bullhorn A+B status)?
docs/operations/goal-week-3-polish-and-scaffold.md:670:  - Approve Proxycurl signup ($39/mo)?
docs/operations/goal-week-3-polish-and-scaffold.md:683:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:1:# ADR-005 — Week-3 Diagnostic acceleration (Bullhorn MCP deferred)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:18:| 3 | **Bullhorn MCP server build** (auth, read endpoints, write endpoints, webhook subscription) per ULTRAPLAN line 752 |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:20:| 5 | Janitor (Bullhorn R+W) |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:23:| 9 | Sourcing Scout |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:29:- **Bullhorn Sub-decisions A + B remain Proposed.** Founder submitted Bullhorn partnerships form 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (commit `dc15692`); response expected 2-5 business days.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:30:- **Without Sub-decision A answered, Week-3 Bullhorn-MCP work is structurally blocked:** we don't know whether marketplace registration is required for production OR whether direct-tier developer-program access suffices.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:35:**Week 3 (Days 13-20) is repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build. Week 4 (Days 21-27) is repurposed from Diagnostic-build to Diagnostic-polish + first-pilot-prep + (conditional) Bullhorn-MCP-build if A+B answered.**
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:41:| W3 Days 13-20: Bullhorn MCP server build | W3 Days 13-20: Diagnostic end-to-end (per `goal-option-c-diagnostic-end-to-end.md`) |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:42:| W4 Days 21-27: Diagnostic end-to-end | W4 Days 21-27: Diagnostic polish + first-pilot prep + Bullhorn MCP if A+B answered |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:43:| W5 Day 28+: Janitor build start | W5 Day 28+: **Conditional on Bullhorn Sub-decisions A+B Accepted** |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:48:2. **The Week-4 milestone is achievable today.** ULTRAPLAN line 755: *"Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."* Option C produces exactly this; the dependencies (LinkedIn + Companies House + scrape) are independent of Bullhorn.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:49:3. **Week-3 time is otherwise idle.** Bullhorn MCP build cannot proceed without commercial answer. Spending Week 3 on Diagnostic uses that time productively.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:65:| Bullhorn A+B state by Day 28 | Janitor action |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:69:| Bullhorn unresponsive past 2026-06-10 | Force Direct-API fallback per `bullhorn-integration-path.md` §1.4; Janitor scaffold begins; Bullhorn auth gated on first pilot raising support ticket |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:73:- Scribe (W6) depends on Bullhorn write; same gating as Janitor
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:75:- Sourcing Scout (W9) touches Bullhorn read; same gating
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:76:- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:86:- Founder commercial workstream (Bullhorn + SeedLegals + Q1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:107:- ULTRAPLAN §10 Risk #2 row contingency (defer Bullhorn-touching agents)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:110:- `bullhorn-integration-path.md` §1.4 (Direct-API fallback architecture for slow Bullhorn response)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:117:| When does Bullhorn respond? | 2-5 business days from submission (sent 2026-05-24); hard cutoff 2026-06-10 per §1.4 fallback |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:119:| LinkedIn deep data via Proxycurl: now or W4? | Day-13 founder pick: Option A (free unauthenticated path) for v0; Proxycurl evaluated W4 polish |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/runbooks/day-4-provisioning.md:1288:- Not the Bullhorn MCP connector (Week 1-2 per `bullhorn-integration-path.md` §6)
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:22:| A2 | Janitor | 5 | Bullhorn MCP (R+W) | "First demoable inside-ATS result; day-30 before/after closes deals" |
docs/decisions/sequencing-target.md:23:| A3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | "Post-call note in Bullhorn within 10 min — second-most-demoable" |
docs/decisions/sequencing-target.md:25:| A5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | "First daytime always-on agent" |
docs/decisions/sequencing-target.md:26:| A6 | Concierge | 10-13 | Bullhorn + MS Graph + AgentMail | "First Tier-1 always-on closing demo; 4-week build" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:42:**Weeks 5-13 planning is speculative without §B.** Each agent's prerequisites (Bullhorn MCP, Fathom/Fireflies, Xero, LinkedIn) have lead times. Bullhorn MCP work itself starts Week 1 per Ultraplan §9 line 724 ("Bullhorn MCP server is the critical path; week 1 starts on it"). Without knowing the agent build order, those infrastructure prereqs can't be sequenced.
docs/decisions/sequencing-target.md:50:Six criteria to evaluate each agent against in §2. Each criterion scored High / Medium / Low or with a concrete number; substantive cells in §2 must justify the score by reference to master brief / Ultraplan / Product Spec / Day-2 Bullhorn decision.
docs/decisions/sequencing-target.md:55:| 2 | **Substrate exercise** | Fraction of Week-1-2 substrate (renderer / `_shared/voice-loader.sh` / `_shared/hook-helpers.sh` / Postgres `decision_log` / `_secrets.env` / Bullhorn auth refresh-loop) the agent exercises | Higher substrate exercise = more value as smoke test for the substrate, but also higher risk of substrate-bug-attributed-to-agent confusion |
docs/decisions/sequencing-target.md:56:| 3 | **Risk de-risking** | Which named risks the agent's success/failure surfaces — Risk #1 (cortextOS primitives), Risk #2 (Bullhorn auth), Risk #5 (renderer-not-built) — per `docs/RISK-REGISTER.md` | Building risk-surfacing agents earlier converts known-unknowns into known-knowns; building risk-deferring agents earlier preserves optionality but pushes the surprise window later |
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:71:- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:96:| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:101:| 6. Tenant-onboarding readiness | **High** | Runnable from end of Week 2 with renderer + `_shared/` + Postgres decision_log. No vault `_secrets.env` complexity (no per-tenant Bullhorn OAuth needed), no wiki API needed. Single-tenant deployable immediately |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:109:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 513 estimate **L (2 weeks)** — the Bullhorn MCP work is rate-limiting per Ultraplan §8.1 line 514 ("Bullhorn MCP server doesn't exist yet — this is the critical-path build"). One MCP server (Bullhorn) + Companies House for enrichment. Single primary output (cleanup report) but with continuous nightly cron pattern |
docs/decisions/sequencing-target.md:110:| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
docs/decisions/sequencing-target.md:111:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #2** (Bullhorn auth path per RISK-REGISTER). Closes Risk #2 reduction trigger 2 from `bullhorn-integration-path.md` §6.7: "first Bullhorn write lands cleanly in Week 3-4 Janitor agent build" → Risk #2 Medium → Low |
docs/decisions/sequencing-target.md:113:| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
docs/decisions/sequencing-target.md:114:| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn `client_id` + `client_secret` (commercial action per Day 2 §6.1) + per-tenant Bullhorn admin OAuth authorisation (the browser dance per Day 2 §3.1). First-pilot onboarding wizard Day 2 step (Product Spec §5.2) is the moment Janitor can be enabled per tenant |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:123:| 2. Substrate exercise | **Medium-High** | Exercises Bullhorn W (smaller surface than Janitor's R+W). First agent with external webhook trigger (Fathom / Fireflies). First exercise of voice-loader for **tacit-note tone-detection** per Ultraplan §8.1 line 523. Reuses Janitor's Bullhorn auth refresh-loop |
docs/decisions/sequencing-target.md:124:| 3. Risk de-risking | **Medium** | Reuses Janitor's Bullhorn auth path (doesn't re-derisk Risk #2). Surfaces new failure mode: **webhook-arrival-to-Bullhorn-write SLA** (5-min target per Ultraplan §8.1 line 521). Doesn't directly touch Risk #5 (renderer already proven by Diagnostic) or Risk #1 (still Tier 2) |
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:126:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Concierge consumes Scribe-generated Notes for context per `bullhorn-integration-path.md` §4.1 row 4 ("Note (prior-comms history)"). Scribe must ship before Concierge | Medium-High criticality |
docs/decisions/sequencing-target.md:127:| 6. Tenant-onboarding readiness | **Medium** | Needs Fathom or Fireflies OAuth + Bullhorn (already onboarded if Janitor shipped). Tacit-note taxonomy needs per-firm calibration in first 30 days of production per Ultraplan §8.1 line 527 |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:139:| 5. Dependencies | **Upstream:** none on other agents (Xero/QuickBooks/Sage + Open Banking infra independent of Bullhorn path). **Downstream:** none in v1.0 (Cash Conductor's outputs are tenant-internal chase emails + DSO reports, not consumed by other v1.0 agents) | Low cross-agent coupling |
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:146:### 2.5 — A5 Sourcing Scout (daytime)
docs/decisions/sequencing-target.md:150:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 554 estimate **L (2 weeks)** — multi-source aggregation logic is the work. Four data sources (Bullhorn read + LinkedIn via Proxycurl + Reed.co.uk + CV-Library). Bounded output (5-15 candidates per query per Ultraplan §8.1 line 552). Tier 2 request-response |
docs/decisions/sequencing-target.md:151:| 2. Substrate exercise | **Medium** | Reuses Bullhorn R from Janitor (no new Bullhorn substrate). New MCP integrations: LinkedIn via Proxycurl (rate-limited per Ultraplan §10 row #6), Reed, CV-Library. Source-abstraction layer per Ultraplan §8.1 line 555 designed to be reusable by Night Sourcer v1.1 |
docs/decisions/sequencing-target.md:152:| 3. Risk de-risking | **Medium** | **First exercise of LinkedIn rate-limit budget** per Ultraplan §10 Risk #6 ("LinkedIn rate limits via Proxycurl are tighter than expected"). Reuses Bullhorn auth from Janitor (doesn't re-derisk Risk #2). Tier 2 so doesn't touch Risk #1 primitives |
docs/decisions/sequencing-target.md:154:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Night Sourcer (v1.1) reuses Sourcing Scout's multi-source layer per Ultraplan §8.1 line 555 ("Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it") | Medium criticality (v1.1 downstream) |
docs/decisions/sequencing-target.md:155:| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn (already on if Janitor shipped) + LinkedIn (Proxycurl API key — single application-level key, not per-tenant) + Reed OAuth + CV-Library OAuth per tenant |
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:164:| 2. Substrate exercise | **Maximum** | **All** of cortextOS Primitives 1+2+4+5 exercised. **First exercise of Primitive 2** (71-hour context rotation per Day 1 cortextos-primitive-status.md) — Concierge holds long-running state across 24+ months of candidate lifecycle. First Bullhorn webhook exercise per Day 2 §4.2 (with 5-minute polling fallback). Per `bullhorn-integration-path.md` §4.1 row 4: reads Candidate, ClientCorporation, JobOrder, Placement, Note + writes Note, Candidate state-fields, Placement state-fields |
docs/decisions/sequencing-target.md:165:| 3. Risk de-risking | **High (secondary)** | Second Tier-1 always-on agent (after Cash Conductor at W7-8) — provides Risk #1 secondary exercise. Exercises Bullhorn webhook coverage gaps per Ultraplan §8.1 line 569 verbatim ("Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks") |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:168:| 6. Tenant-onboarding readiness | **Hardest** | Needs Bullhorn + Microsoft Graph (or Gmail) per tenant + full voice corpus loaded + nurture cadence config per stage + auto-send approval categories (Solo: drafts-only; Boutique+: candidate-acknowledgement auto-send) + do-not-contact flags. Full onboarding-wizard Day 4 work (Product Spec §5.2) |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:185:W9:   Sourcing Scout (A5)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:193:- W5: Risk #2 (Bullhorn auth) — Janitor first writes. Reduction trigger 2 fires (Medium → Low per `bullhorn-integration-path.md` §6.7).
docs/decisions/sequencing-target.md:198:- Bullhorn webhook coverage gaps surface only at Concierge W10-13 (Ultraplan §8.1 line 569 caveat).
docs/decisions/sequencing-target.md:200:**Cost if deferred risk materialises late:** if Bullhorn webhook coverage is worse than expected (Risk #2 secondary), Concierge polling cadence increases (per Day 2 §4.2 fallback) — connector-internal change, no agent rework. Bounded.
docs/decisions/sequencing-target.md:202:**Hire-#1-onboarding fit:** **Excellent.** Cash Conductor at W7-8 matches Ultraplan §9 line 766 verbatim. Hire #1 (assumed W7) takes Cash Conductor's three-accounting-API + Open-Banking work as first sprint — well-scoped, independent of the Bullhorn track founder has been driving solo W3-W6.
docs/decisions/sequencing-target.md:209:W9:   Janitor (A2)
docs/decisions/sequencing-target.md:211:W11:  Sourcing Scout (A5)
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:233:W12:  Sourcing Scout (A5)
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:253:| 2. Substrate exercise (sequential build-up) | **Wins** — each agent extends the substrate of the prior (renderer → Bullhorn auth → voice → Tier-1 primitives → multi-source → full Tier-1 lifecycle) | Loses — Concierge has to build its own Bullhorn auth + voice substrate inline | Loses — Concierge built before its substrate dependencies (Scribe's Notes-for-context not yet available) |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:256:| 5. Dependencies on other agents | **Wins** — Janitor's Bullhorn auth → Scribe reuses → Sourcing Scout reuses → Concierge reuses, all in dependency order | Loses — Concierge before Janitor + Scribe breaks the upstream chain | Loses — Concierge before Scribe breaks the upstream chain |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:285:| 5 | W9 | **Sourcing Scout** (A5) | Multi-source aggregation; first LinkedIn rate-limit exercise (Risk #6) |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:300:**Trigger 1 — Risk #2 materialises in Week 4-5.** If Bullhorn auth path breaks (Day 2 Sub-decisions A or B don't flip to Accepted, marketplace required but unobtainable, OAuth flow blocks deployment, or per-tenant client_id ticket cycle slows past 5 business days per `bullhorn-integration-path.md` §1.3 row 5):
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:310:- **Activation:** v1.0 scope cut from 6 to 4 agents per Ultraplan §10 row #4 — drop Concierge + Sourcing Scout to v1.1; founder solo through end of v1.0.
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:319:- **Cascade:** Sourcing Scout W10 (shifted right from W9), Concierge W11-14 (shifted right from W10-13).
docs/decisions/sequencing-target.md:326:- The substrate-first principle (Diagnostic W3-4 before any Bullhorn-touching agent).
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:406:### 6.3 — For Risk #2 (Bullhorn auth path)
docs/decisions/sequencing-target.md:439:- **Janitor's first Bullhorn auth refresh fails by W5** (Risk #2 unmitigated; commercial path broken)
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
docs/operations/seedlegals-engagement-queries.md:68:> 1. **Service scope:** SaaS-delivered AI agent fleet for UK recruitment agencies (Bullhorn ATS integration; bounded action set defined in autosend-safety-policy attached as Appendix A).
docs/operations/seedlegals-engagement-queries.md:76:> 5. **PII jurisdiction:** UK only. SaaS vendor processes data within UK + EEA only; no transfer to US or other adequacy-decision-uncovered jurisdictions. Bullhorn data centre = UK per pilot agreement.
docs/operations/seedlegals-engagement-queries.md:157:- Bullhorn's own DPA terms — does our customer's DPA conflict with Bullhorn's processor agreement?
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/decisions/autosend-approval-bridge-spec.md:158:Action: write customer-visible Bullhorn Note
docs/decisions/autosend-approval-bridge-spec.md:243:| A5 | Bridge crash + restart: state rebuilds from filesystem scan + Postgres state table | Restart test: kill PM2 process mid-flight, restart, verify pending approvals resume |
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:14:> The document claims Week-1 implementation can proceed before the auth path is cleared. Lines 57-72 list commercial blockers for Sub-decisions A/B, but line 95 says those can remain Proposed without blocking Week-1 implementation. That weakens the Day-7 auth-path quality gate. Fix by making Bullhorn connector scaffolding explicitly conditional on A/B resolution or by narrowing Week-1 work to non-auth code only.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:29:**None of these reference Bullhorn at all.** They are tenant-agnostic + adapter-agnostic substrate. Sub-decisions A+B remaining Proposed (commercial questions about marketplace partnership + dev tenant access) does not block these.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:31:Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:41:| Diagnostic build (W3-4) | None — Diagnostic doesn't touch Bullhorn | Awaits Q1 LOI |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:44:Codex over-applied the Q3 gate from "Week-0 close" + "named agent-build slices" down to "Week-1 implementation generally" — a category error. Week-1 prereq code is upstream of all agent builds; it doesn't need Bullhorn auth resolved.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:67:which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:81:- **Tighten the gate (Codex's read)** — make all Week-1 implementation conditional on A+B Accepted. Forces all 5 Week-1 prereq commits to be re-classified as W5-prereq. Operationally complex + arguably wrong (renderer doesn't need Bullhorn auth to render).
docs/operations/goal-option-c-diagnostic-end-to-end.md:6:**Maps to:** Week-3 + Week-4 work pulled forward; Week-3 Bullhorn-MCP work deferred pending Sub-decisions A+B response.
docs/operations/goal-option-c-diagnostic-end-to-end.md:77:| LinkedIn integration (Proxycurl, etc.) | Requires founder commercial action (Proxycurl signup ~£50/mo); LinkedIn paths remain stubbed; fixture 02 verifies graceful degradation already |
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:90:- **Do NOT** sign up for any paid service (Proxycurl, etc.) — founder gates external spend
docs/operations/goal-option-c-diagnostic-end-to-end.md:166:- Search for a real UK firm ("Bullhorn UK" or similar — known to exist)
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:252:- **Decision:** Week 3 (Days 13-20) repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build. Week 4 (Days 21-27) repurposed from Diagnostic-build to Diagnostic-polish + Codex ratification + (conditional) Bullhorn-MCP-build if A+B answered.
docs/operations/goal-option-c-diagnostic-end-to-end.md:253:- **Consequences:** Janitor W5 build conditional on Bullhorn A+B Accepted. If A+B answer arrives after 2026-06-03, Janitor slips to W6+; if no answer by 2026-06-10, force Direct-API fallback per `bullhorn-integration-path.md` §1.4.
docs/operations/goal-option-c-diagnostic-end-to-end.md:257:Commit: `decision(ADR-005): Week 3 repurposed Bullhorn-MCP → Diagnostic acceleration`
docs/operations/goal-option-c-diagnostic-end-to-end.md:266:- Risk #2 (Bullhorn MCP build): note Diagnostic-doesn't-need-Bullhorn path explored Day-13; reduces blast radius if Bullhorn response delayed
docs/operations/goal-option-c-diagnostic-end-to-end.md:283:- Recommendations for Week-4 polish (weak sections, voice classifier wiring, LinkedIn integration if Proxycurl signed up)
docs/operations/goal-option-c-diagnostic-end-to-end.md:330:- Any external service requiring paid signup (Proxycurl, OpenAI tier, etc.)
docs/operations/goal-option-c-diagnostic-end-to-end.md:402:  - [LinkedIn integration via Proxycurl signup]
docs/operations/goal-option-c-diagnostic-end-to-end.md:409:  - [Proceed to Week-4 polish OR wait on Bullhorn response before Janitor W5?]
docs/runbooks/operational-hygiene-protocol.md:175:**Day-6 retrospective check:** vertical-schema.yaml estimated 300-500. Per §4.1: 8 entities × 50 = 400 lines, 10 relationships × 10 = 100 lines, agent matrix + Bullhorn mapping + open questions + versioning = ~200 lines, header overhead = ~50 lines. **True estimate: 750 lines.** Actual: 899. ±20% range: [600, 900]. **Actual is within range.** The Day-6 estimate was the wrong number, not the work.
docs/runbooks/operational-hygiene-protocol.md:284:Day-5 autosend policy §3 + §10 cited `bullhorn-integration-path.md §4.1` as the canonical-orange anchor for Concierge `bullhorn_note_customer_visible`. Verified §4.1 establishes the action exists but does not explicitly frame as sensitive auto-send. Sensitivity framing lives in §6.3 ("Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI").
docs/runbooks/tenant-lifecycle.md:58:| `Bullhorn tenant corp_id` | From tenant's Bullhorn admin | Per `common-ats.json` |
docs/runbooks/tenant-lifecycle.md:151:| Bullhorn OAuth refresh | Per-agent 8-min cycle per `bullhorn-integration-path.md` §4.5; ESC_BULLHORN_AUTH on failure | (No invariant violation; runtime concern) |
docs/build-brief/00-MASTER-BRIEF.md:44:We add: a vertical schema for UK recruitment; 18 agents in the v2 bundle pattern; an Obsidian-style wiki + graphify second brain that **replaces** cortextOS's stock knowledge-base behind the `bus/kb-*.sh` boundary; MCP connectors for Bullhorn/Companies House/Xero/Microsoft Graph; an entity-graph + decision-log Postgres layer with RLS; a per-tenant LoRA pipeline (v2.0 work); and a five-day onboarding wizard.
docs/build-brief/00-MASTER-BRIEF.md:118:| 6 | Overnight autoresearch (theta wave) | Analyst-template agents schedule overnight experiments | Night Sourcer + Spec Pitcher use this |
docs/build-brief/00-MASTER-BRIEF.md:119:| 7 | Multi-agent orchestrator | `orchestrator` template + file-bus handoff contract | Brief Decoder → Sourcing Scout → Concierge pipeline lives here |
docs/build-brief/00-MASTER-BRIEF.md:149:| Bullhorn, Vincere, Voyager Infinity | `packages/mcp-connectors/{name}/` first-party MCP | Vertical-specific; our moat |
docs/build-brief/00-MASTER-BRIEF.md:314:│       │   └── ats-snapshots/    ← Bullhorn entity snapshots
docs/build-brief/00-MASTER-BRIEF.md:358:   provenance: [scribe-agent:call-2026-05-16-1432, janitor:bullhorn-2026-05-15]
docs/build-brief/00-MASTER-BRIEF.md:456:### Day 2 — Tuesday — Bullhorn integration path
docs/build-brief/00-MASTER-BRIEF.md:458:- [ ] Decision: Bullhorn Marketplace vs Direct API. OAuth model: authorization-code grant for production tenants; authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (Bullhorn does not support `client_credentials` grant for tenant-scoped data per Bullhorn OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`). Document in `docs/decisions/bullhorn-integration-path.md`.
docs/build-brief/00-MASTER-BRIEF.md:490:3. Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?
docs/build-brief/00-MASTER-BRIEF.md:596:| 2 | Janitor | 5 | Bullhorn MCP (R+W) | First demoable inside-ATS result; day-30 before/after closes deals |
docs/build-brief/00-MASTER-BRIEF.md:597:| 3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | Post-call note in Bullhorn within 10 min — second-most-demoable |
docs/build-brief/00-MASTER-BRIEF.md:599:| 5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
docs/build-brief/00-MASTER-BRIEF.md:600:| 6 | Concierge | 10–13 | Bullhorn + MS Graph + AgentMail | First Tier-1 always-on closing demo; 4-week build |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:680:        │   v1.1 (+7): Inbound Triage, Brief Decoder, Night Sourcer, Competitor Interception,              │
docs/build-brief/00-MASTER-BRIEF.md:695:        │  • First-party MCP  packages/mcp-connectors/: Bullhorn, Companies House, Xero, etc.        │
docs/build-brief/00-MASTER-BRIEF.md:698:        │  • Direct vendor API: Microsoft Graph delegated send, Proxycurl LinkedIn                   │
docs/build-brief/00-MASTER-BRIEF.md:766:- Day 7: Codex reviews the seven Week 0 artefacts (primitive audit, Bullhorn path, Brain UI scope, infra checklist, safety policy, kill criterion, vertical schema v0.1) — first ratification run
docs/build-brief/00-MASTER-BRIEF.md:795:- Negotiating Bullhorn marketplace terms — phone call
docs/build-brief/00-MASTER-BRIEF.md:828:| "Let me use Composio for the Bullhorn connector..." | §3.2 |
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
docs/build-brief/00-MASTER-BRIEF.md:973:- Use Composio for Bullhorn because "the catalogue says they have it" (they don't, and even if they did, see §3.2)
docs/decisions/bullhorn-integration-path.md:1:# Bullhorn integration path — decision document
docs/decisions/bullhorn-integration-path.md:6:**Surfaced by:** Master brief §6 Day 2 (lines 466-467) — "Decision: Bullhorn Marketplace vs Direct API. OAuth model: browser dance for production, service-account for dev." Plus Ultraplan §11 Day 2 (lines 847-849).
docs/decisions/bullhorn-integration-path.md:19:**Sub-decision A — Bullhorn integration path.** Marketplace partner programme membership (with its access tier, scope, certification, ongoing fees) versus direct API access (per-tenant Bullhorn-account-admin authorisation of IFOS as a connected app). Master brief §6 Day 2 line 466 explicitly names this as the day's decision. The path chosen determines whether `packages/mcp-connectors/bullhorn/` ships as a marketplace-registered connector or a direct-API connector — the *code* in either case is similar OAuth + REST plumbing, but the *operational, commercial, and rate-limit* surfaces differ materially.
docs/decisions/bullhorn-integration-path.md:21:**Sub-decision B — OAuth flow.** Master brief §6 Day 2 line 466 pre-states a recommendation: "browser dance for production, service-account for dev." This is the authorization-code grant (per-tenant browser dance, refresh-token cycle) for production tenants, plus client-credentials grant (service account) for IFOS-internal sandbox/dev work. Sub-decision B verifies that recommendation against Bullhorn's actual OAuth implementation and pins the per-tenant token storage path (per `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution: `/vault/<tenant>/_secrets.env`, mode `0600`).
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:27:Master brief §12 Risk #2 (Bullhorn auth path) — "Bullhorn MCP build takes longer than 1 week" — names this as one of the four risks that could kill v1.0. Tripwire: "End of week 3 status not 'core read endpoints working'" (master brief §12 row #2, Ultraplan §10 row #2). The mitigation is "Week 0 Day 2 on Bullhorn auth research" — i.e. this document. Without Sub-decisions A and B answered, Week 1 cannot begin scaffolding `packages/mcp-connectors/bullhorn/` because the connector's authentication path determines its scope and shape.
docs/decisions/bullhorn-integration-path.md:29:**Bullhorn dependency count for v1.0 agents:**
docs/decisions/bullhorn-integration-path.md:31:| Agent | Bullhorn dependency in v1.0 | Source |
docs/decisions/bullhorn-integration-path.md:36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
docs/decisions/bullhorn-integration-path.md:37:| A5 Sourcing Scout | **Yes — read** (ATS passive-match lookup) | Ultraplan §8.1 A5 line 547-551 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:42:This is also the Day 2 critical-path artefact for the §6 Day 7 single-sentence test (master brief §6 lines 494-502, Ultraplan §12 lines 887-895), question 3: "Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?" A Yes answer requires this document plus the Sub-decision A and B confirmations to land before Sunday review.
docs/decisions/bullhorn-integration-path.md:48:**Technically grounded (Claude Code can analyse tonight from Bullhorn public documentation + master brief / Ultraplan / product spec context):**
docs/decisions/bullhorn-integration-path.md:50:- The structural shape of Bullhorn's OAuth flows (authorization code vs client credentials) and which scenarios each is suited to.
docs/decisions/bullhorn-integration-path.md:52:- Token lifecycle outline: short-lived REST sessions, long-lived refresh tokens, periodic re-auth dance via the Bullhorn login URL.
docs/decisions/bullhorn-integration-path.md:59:- Whether Intel Force Ltd is currently a member of the **Bullhorn Marketplace Partner Programme** (or what the application timeline + cost would be). The marketplace partner application process is publicly known to involve a technical review, security audit, and ongoing partner fees — but the specifics for IFOS's tier and tenant volume are commercial-confidential and need a direct conversation.
docs/decisions/bullhorn-integration-path.md:60:- Whether **marketplace-tier API access differs from direct-API access** in rate limits, available scopes (e.g. write to JobOrder, write to Note, webhook subscription), or sandbox availability. Bullhorn's public docs are sparse on the deltas; partner reps know the actuals.
docs/decisions/bullhorn-integration-path.md:62:- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
docs/decisions/bullhorn-integration-path.md:68:| A | "Is Intel Force Ltd in the Bullhorn Marketplace Partner Programme, or what's the application timeline + first-year cost?" | Bullhorn partnerships team — submit via Marketo form at `https://www.bullhorn.com/become-a-partner/` (verified 2026-05-23). Earlier draft cited `partnerships@bullhorn.com` which does NOT exist (mail bounced). | Submit any weekday; response 2-5 business days | Cold inbound via form; routes internally. UK office at 7 Devonshire Square, London EC2M 4YH for escalation. |
docs/decisions/bullhorn-integration-path.md:69:| A | "What are the API rate-limit / scope deltas between marketplace tier and direct API at our expected 3-6 tenant pilot volume?" | Same Bullhorn partnerships team, or escalation to developer support | Same conversation | The answer determines whether direct-API can serve v1.0 or marketplace registration is a v1.0 blocker |
docs/decisions/bullhorn-integration-path.md:70:| A + C | "Which ATS does design partner #1 use — Bullhorn, Vincere, Voyager Infinity, or another?" | **Founder** — Sunday design-partner conversation 2 per master brief §6 Day 2 line 467 | Sunday/Monday | If Bullhorn: Sub-decision A path proceeds as analysed. If non-Bullhorn: the v1.0 ATS anchor changes, this document's Sub-decisions are scoped to "Bullhorn is the second-tenant ATS" rather than "v1.0 first-tenant ATS" |
docs/decisions/bullhorn-integration-path.md:71:| B | "Does Bullhorn's OAuth implementation support client_credentials grant against the sandbox environment?" | Bullhorn developer support — `developer.bullhorn.com` portal contact form, or via the partnerships rep once Sub-decision A's contact path is open | Monday-Tuesday | Used to verify that the §6 Day 2 line 466 recommendation ("browser dance for production, service-account for dev") is implementable end-to-end |
docs/decisions/bullhorn-integration-path.md:72:| B | "Refresh-token TTL and rotation behaviour specifics" | Same | Same | Affects renderer §3.3.2 `.env` materialisation: how often does per-tenant `_secrets.env` need rotation? Documented Bullhorn behaviour varies by account; partner-rep gives the canonical numbers |
docs/decisions/bullhorn-integration-path.md:74:The Sunday design-partner conversation 2 is the most time-sensitive: it can flip the entire premise of Sub-decisions A and C. Founder cadence per master brief §6 Day 2 (line 467) and §11.2 line 791 ("Day 2 — Tuesday — Bullhorn integration path... — Design-partner conversation 2") puts this as a parallel-to-Claude-Code track.
docs/decisions/bullhorn-integration-path.md:86:  - Founder runs Bullhorn partnerships outreach — submission via Marketo form at `https://www.bullhorn.com/become-a-partner/` (verified 2026-05-23; the earlier `partnerships@bullhorn.com` draft was wrong — that mailbox does not exist). Result may not come back same-day.
docs/decisions/bullhorn-integration-path.md:88:  - Founder runs Bullhorn developer-support outreach for Sub-decision B specifics if not already covered by partnerships rep.
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:99:Three distinct gates govern Bullhorn-touching work, in temporal order:
docs/decisions/bullhorn-integration-path.md:104:| Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (`sequencing-target.md` §2.1) | Awaits Q1 LOI |
docs/decisions/bullhorn-integration-path.md:111:### 2.1 — Bullhorn marketplace partner programme
docs/decisions/bullhorn-integration-path.md:113:Bullhorn's public surfaces for the partner programme are deliberately thin. Three URLs surveyed Day 2 (2026-05-16 evening):
docs/decisions/bullhorn-integration-path.md:116:- `https://www.bullhorn.com/become-a-partner/` — landing page. Main CTA: **"Fill out the form to learn more about our partner programs."** References three external resources (FAQs, Bullhorn Developer Program, Fair Use Policy) but the page itself contains **no specific information** on application process, tiers, certification, security review, fees, ongoing costs, or timeline. The only substantive description on the page is: **"The Bullhorn Marketplace gives our customers the choice, confidence, and customization they need to innovate with agility."**
docs/decisions/bullhorn-integration-path.md:122:- Bullhorn Marketplace currently lists 300+ partner integrations (the headline number on the marketplace page).
docs/decisions/bullhorn-integration-path.md:123:- There is a separately-named **Bullhorn Developer Program** distinct from the Marketplace partner programme (linked from `/become-a-partner/`) — implying a possible two-tier structure: developer-tier access to APIs (lighter) vs marketplace-listed partner (heavier).
docs/decisions/bullhorn-integration-path.md:136:**Inference (clearly marked as inference, not Bullhorn's stated position):** the gap between "free developer account" and "marketplace-listed partner" is structurally common across enterprise SaaS platforms (Salesforce AppExchange, HubSpot Marketplace, ServiceNow Store all follow this pattern). The plausible IFOS path through this commercial space is: register for the Bullhorn Developer Program first (which usually grants API access for a tenant the developer controls or for sandbox dev), then apply for marketplace listing once an integration is shippable. Whether either path is required for IFOS production tenants — the actual gate — is the §1.3 partnerships@bullhorn conversation.
docs/decisions/bullhorn-integration-path.md:138:### 2.2 — Direct Bullhorn API access
docs/decisions/bullhorn-integration-path.md:143:- `https://bullhorn.github.io/docs` — Bullhorn's developer documentation landing. Names three API surfaces: REST API, OAuth, SOAP (legacy). The REST and OAuth links are the operative ones for v1.0.
docs/decisions/bullhorn-integration-path.md:145:**The technical model verified from Bullhorn's "Getting Started with REST" documentation (cited inline below):**
docs/decisions/bullhorn-integration-path.md:148:- **`BhRestToken` (REST session token)** is presented on each subsequent REST call in three accepted forms: URL query parameter, HTTP header (`BhRestToken` or `BHRestToken`), or cookie. On expiry, REST calls return 401 — application must re-run /login. (Bullhorn doc verbatim: "When the current session key expires, your query will return a 401 response.")
docs/decisions/bullhorn-integration-path.md:150:- **client_id / client_secret acquisition.** Bullhorn doc verbatim: **"Bullhorn customers can obtain OAuth keys for developing applications...by creating a support ticket via the Bullhorn Resource Center."** This is not a self-service developer signup — there is a Bullhorn-side gate even for the developer-tier path. Implication: every IFOS pilot tenant must open a support ticket with Bullhorn to authorise IFOS as a connected app, or IFOS must hold a single set of client credentials at the IFOS-application level and route per-tenant auth through it. The structural distinction here is exactly what Sub-decision A pivots on — partnerships@bullhorn confirms whether marketplace status grants application-level credentials.
docs/decisions/bullhorn-integration-path.md:151:- **Documented rate limit signal:** Bullhorn's REST docs name **HTTP 429** as "Rate Limited — Wait 1 second then retry request. Repeat until successful." That's the only rate-limit reference in the public docs surveyed; specifics (per-second/minute/day caps, per-corpToken or per-application) are not documented and are commercially gated to verification per §1.3.
docs/decisions/bullhorn-integration-path.md:166:| Time-to-first-call (greenlight → working API call against a tenant) | **CG.** Inference: marketplace certification + security review typically 4-12 weeks for enterprise SaaS programmes of this maturity. Bullhorn-specific timeline not stated publicly. | **CG.** Confirmed from public docs: customer raises Bullhorn support ticket per /Getting-Started-with-REST to obtain client_id/client_secret. ETA per ticket cycle — likely 1-5 business days per pilot tenant. |
docs/decisions/bullhorn-integration-path.md:167:| Per-tenant onboarding friction (admin auth, scope review) | **CG.** If marketplace tier grants IFOS application-level credentials, per-tenant friction may reduce to "tenant clicks Authorise from marketplace listing." | Each pilot tenant raises a Bullhorn support ticket + tenant admin authorises IFOS as a connected app via per-tenant OAuth screen. Per-tenant friction: 1 support ticket + 1 OAuth dance per pilot tenant. |
docs/decisions/bullhorn-integration-path.md:168:| Co-marketing benefit | Listed in the 300+ partner directory on bullhorn.com/marketplace; potentially Bullhorn-sales-rep co-selling motion. **CG** on specific benefit terms. | None. |
docs/decisions/bullhorn-integration-path.md:169:| Cost at 3-tenant pilot scale (2026 H2, Boutique tier per Product Spec §3.1) | **CG.** Public docs do not name partner fees. Inference based on comparable enterprise SaaS marketplace programmes: annual partner fee typically $5K-$25K + possibly per-listing or per-referral revenue-share. | **CG.** Public docs do not name developer-program fees. Inference: likely zero or nominal for the developer-tier API access. Per-tenant cost zero — the tenant pays Bullhorn, IFOS pays nothing per call. |
docs/decisions/bullhorn-integration-path.md:170:| Cost at 100-tenant target scale (Product Spec §5.4 end-2027 target) | **CG.** May or may not scale linearly with tenant count. Some marketplace programmes have flat annual fees; others meter on tenant or revenue volume. | **CG.** If developer-tier cost is zero or nominal, scales fine. Risk: per-tenant Bullhorn support tickets at 100 tenants become operational drag at IFOS-Customer-Success layer (Product Spec §5.4 line 373 names ≤8 hours of human time per customer onboarding — Bullhorn ticket may consume a meaningful fraction). |
docs/decisions/bullhorn-integration-path.md:172:| Founder operational overhead (per tenant + ongoing) | **CG.** If marketplace handles per-tenant auth: low per-tenant overhead. Annual partner-programme obligations: technical review responses, security questionnaire renewals, marketplace listing maintenance — non-trivial ongoing. | Per-tenant: one Bullhorn support ticket request from the tenant admin per pilot. Ongoing: zero programme obligations; only IFOS-side OAuth token refresh management. |
docs/decisions/bullhorn-integration-path.md:179:**Recommendation: scaffold the Bullhorn MCP connector against direct API / Developer Program for v1.0 weeks 1-2; treat marketplace registration as a v1.1+ commercial track that the connector's auth module is designed to swap into without endpoint-surface changes.**
docs/decisions/bullhorn-integration-path.md:183:1. **The §1.4 honest-signal fallback architecture demands it.** With Bullhorn commercial answers slow-rolling (likely Monday at earliest, possibly later), Week 1 connector scaffolding cannot block on partnerships@bullhorn responses. Scaffolding against the documented direct-API auth flow lets the connector progress; the §2.3 Switching-cost analysis shows the auth-module swap is bounded.
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:191:| Marketplace tier is **required** for production tenant onboarding (partnerships@bullhorn answer) | Connector scaffolds against direct-API on a Bullhorn-sandbox tenant for IFOS internal dev; marketplace registration becomes Week-1 critical-path commercial work; v1.0 build slips by the marketplace certification timeline (potentially 4-12 weeks per §2.3 row 1 inference). This is a v1.0 blocker scenario and feeds master brief §12 Risk #2 directly. |
docs/decisions/bullhorn-integration-path.md:193:| Direct-API requires per-tenant Bullhorn support ticket that slows pilot onboarding by >3 business days per tenant (Bullhorn dev support answer) | Marketplace may win on time-to-first-call even if costlier. Re-evaluate based on actual ticket-cycle data from first pilot's setup. |
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:196:**Status: Proposed.** Status flips to Accepted on either: (a) partnerships@bullhorn confirms marketplace is not required for v1.0 production tenant access AND first design partner uses Bullhorn; OR (b) founder explicitly accepts the documented fallback if marketplace turns out required, and re-cuts the v1.0 timeline to absorb the marketplace certification window.
docs/decisions/bullhorn-integration-path.md:204:The flow Bullhorn documents at `https://bullhorn.github.io/Getting-Started-with-REST`. Verified specifics:
docs/decisions/bullhorn-integration-path.md:210:The `{loginInfo}` placeholder is per-tenant-cluster — IFOS resolves it via the Bullhorn `loginInfo` lookup endpoint before kicking off OAuth. This is part of the connector's auth module.
docs/decisions/bullhorn-integration-path.md:213:1. Per-tenant Bullhorn admin (or IFOS-on-behalf-of-admin if marketplace path enables it) hits the authorise URL with `client_id`, `response_type=code`, `redirect_uri`, `state`, and per-Bullhorn-docs the `username` + `password` query parameters as well (Bullhorn-specific: their authorize endpoint accepts credentials inline rather than a separate consent screen).
docs/decisions/bullhorn-integration-path.md:214:2. Bullhorn returns auth code to `redirect_uri`.
docs/decisions/bullhorn-integration-path.md:218:**Token TTLs (Bullhorn doc verbatim):**
docs/decisions/bullhorn-integration-path.md:226:**Scope of permissions requested at first auth:** Bullhorn's OAuth docs surveyed do not specify per-scope strings (e.g. `read:candidate`, `write:note`). REST API access appears to be at-tenant-admin-discretion — the admin authorises the connected app for "API access" generally, and the corpToken-scoped session inherits whatever entity permissions the admin's account holds. **Spec gap §3.1-B:** confirm with Bullhorn developer support that there is no per-entity-type scope granularity at the OAuth layer — i.e. IFOS cannot request "read-only" auth and get a token that can't write. If this is correct, then Gate A in `validate.sh` (per master brief §1 Rule 4) becomes the only enforcement layer for "this agent should never write" — the OAuth token itself does not protect.
docs/decisions/bullhorn-integration-path.md:230:- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
docs/decisions/bullhorn-integration-path.md:232:- Bullhorn account suspended/cancelled — same 401 pathway; escalation routes to founder for tenant-relationship handling.
docs/decisions/bullhorn-integration-path.md:233:- Scope change by Bullhorn — unlikely without notice but possible; IFOS connector logs and escalates.
docs/decisions/bullhorn-integration-path.md:237:**Bullhorn does NOT document a client_credentials grant in their OAuth specification.** Specifically verified at `https://bullhorn.github.io/Getting-Started-with-REST` — the grant types section names only the authorization-code flow. Inference from this absence (not contradicted by other surveyed docs): Bullhorn does not support client_credentials grant for tenant-scoped data access.
docs/decisions/bullhorn-integration-path.md:241:- **IFOS holds a Bullhorn dev tenant** (separate from any production pilot) where IFOS performs authorization-code grant once against IFOS-internal admin credentials; the resulting access/refresh tokens serve as the "dev account" auth state. Tokens still rotate per §3.1; IFOS internal-dev tooling refreshes them.
docs/decisions/bullhorn-integration-path.md:242:- **Bullhorn sandbox tier** (if it exists — §2.2 noted sandbox availability is not publicly documented and is commercially gated). If Bullhorn offers a sandbox, the auth model against it is presumed identical to production: authorization-code grant. Just a different `loginInfo` cluster.
docs/decisions/bullhorn-integration-path.md:244:**Spec gap §3.2-A:** confirm with Bullhorn developer support whether (a) client_credentials is genuinely unsupported, or (b) it exists for specific partner-tier use cases not documented publicly. If (b), this changes the dev-loop ergonomics. Mark as **CG**.
docs/decisions/bullhorn-integration-path.md:251:- **IFOS internal dev / sandbox:** authorization-code grant against IFOS-owned Bullhorn dev tenant (or against Bullhorn sandbox if §3.2-A resolves favourably). Same flow as production; the only difference is the source tenant. Tokens stored at `packages/mcp-connectors/bullhorn/.dev-tokens/` (gitignored) for IFOS dev work.
docs/decisions/bullhorn-integration-path.md:256:**Recommendation:** authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement "browser dance for production"). For IFOS dev: authorization-code grant against an IFOS-owned Bullhorn dev tenant; service-account / client_credentials grant deferred (because Bullhorn doesn't document support for it per §3.2).
docs/decisions/bullhorn-integration-path.md:260:1. **It's the only documented Bullhorn-supported production OAuth path.** Section 3.1's verified Bullhorn documentation grounds this; Section 3.2's documented absence of client_credentials closes the alternative.
docs/decisions/bullhorn-integration-path.md:264:**Commercial verification gates** (per §1.3 table, Bullhorn developer support row):
docs/decisions/bullhorn-integration-path.md:266:- Confirm authorization-code grant is the correct production path (i.e. Bullhorn doesn't have a marketplace-tier-only managed-auth path that bypasses the browser dance).
docs/decisions/bullhorn-integration-path.md:267:- Confirm Bullhorn sandbox availability and auth model (Spec gap §3.2-A).
docs/decisions/bullhorn-integration-path.md:269:- Confirm refresh-token rotation atomicity requirements (any Bullhorn-side timeouts that affect persistence windows).
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:289:| **A1 Diagnostic** (no Bullhorn) | n/a | n/a | n/a | n/a | n/a | n/a — runs against public footprint per Ultraplan §8.1 line 489 |
docs/decisions/bullhorn-integration-path.md:290:| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:298:**Confirmed from Bullhorn public docs:** `https://bullhorn.github.io/rest-api-docs/` describes **no webhook, subscription, event-stream, or push-notification mechanism**. Operations covered: entity CRUD, query/search, file attachments, resume parsing, mass updates, entity metadata. Verified 2026-05-16.
docs/decisions/bullhorn-integration-path.md:300:**Implication:** Bullhorn's public-tier REST API is **pull-only**. IFOS must poll for change detection at v1.0 unless commercial verification reveals a partner-tier event-subscription mechanism. **Commercially gated: §4.2-A** — confirm with Bullhorn developer support whether webhook/event-subscription capabilities exist at marketplace/partner tier that are not documented in the public REST docs.
docs/decisions/bullhorn-integration-path.md:308:| Scribe transcript-to-Note write | Push from Fathom/Fireflies → IFOS → REST write to Bullhorn | Per-call (within 5-min SLA) | The Fathom/Fireflies webhook is the trigger; Bullhorn side is REST POST |
docs/decisions/bullhorn-integration-path.md:309:| Sourcing Scout passive-match read | Polling (on-demand search) | Per-consultant-request | No subscription needed — read-on-demand model |
docs/decisions/bullhorn-integration-path.md:310:| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
docs/decisions/bullhorn-integration-path.md:311:| Concierge time-based nurture cadence | Cron (week-1, month-1, month-3, month-6, month-12, month-24) | Per Placement-creation anchor date | No Bullhorn webhook needed — IFOS-side cron fires; IFOS reads Bullhorn for current state then writes the comm Note back |
docs/decisions/bullhorn-integration-path.md:324:- **Postgres `decision_log` RLS:** every Bullhorn-derived `hh_decision_*` row is tenant-scoped per ADR-002 Decision 3 (`tenant_slug` column + RLS policy per `second-brain-design.md` §2.4.2).
docs/decisions/bullhorn-integration-path.md:328:Bullhorn public docs name HTTP 429 + "wait 1 second then retry" per §2.2; specific per-second / per-minute / per-day caps **commercially gated to verification per §1.3** (Bullhorn dev support).
docs/decisions/bullhorn-integration-path.md:330:**Conservative v1.0 budget allocation per tenant per hour** (anchored to typical enterprise REST API patterns of 100-500 req/min ceilings; revise once Bullhorn confirms):
docs/decisions/bullhorn-integration-path.md:335:| Scribe (write-on-event) | 50-100 distributed | Event-rate-bounded; one call typically = 5-15 REST writes |
docs/decisions/bullhorn-integration-path.md:336:| Sourcing Scout (read-on-demand) | 50-200 during consultant-active windows | Search-heavy; multiple paginated reads per consultant request |
docs/decisions/bullhorn-integration-path.md:342:**Spec gap §4.4-A:** confirm actual Bullhorn rate limits per tenant during commercial conversation per §1.3 table (Bullhorn dev support row). Revise this budget table when actuals land.
docs/decisions/bullhorn-integration-path.md:346:**Emerged from §3.1 finding:** Bullhorn's 10-minute access token TTL is short enough that v1.0 needs an explicit refresh-loop pattern. Lazy refresh on 401 alone is insufficient for two reasons: (a) it would cause every 10-minute window's first call to take a refresh round-trip's worth of latency, breaking sub-second SLAs on Concierge real-time paths; (b) 401 detection on burst writes (Scribe's per-call sequence of 5-15 REST writes) means burst-mid-flight refresh failures lose write ordering.
docs/decisions/bullhorn-integration-path.md:353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
docs/decisions/bullhorn-integration-path.md:356:- **`BhRestToken` cache invalidation:** when access token refreshes, the `BhRestToken` is independently maintained (it persists across access-token refreshes per Bullhorn's two-step model). On 401 from a REST call, IFOS re-runs `/login` to get a new `BhRestToken` without needing to re-OAuth.
docs/decisions/bullhorn-integration-path.md:357:- **State location:** refresh-loop is a goroutine-equivalent (Node `setInterval` or similar) inside the Bullhorn MCP connector process, per-tenant scoped. Multiple agents on the same tenant share the connector's token cache.
docs/decisions/bullhorn-integration-path.md:369:Recommendation: scaffold the Bullhorn MCP connector against direct API / Developer Program for v1.0 weeks 1-2; treat marketplace registration as a v1.1+ commercial track that the connector's auth module is designed to swap into without endpoint-surface changes (per §2.4 + §1.4 fallback architecture).
docs/decisions/bullhorn-integration-path.md:373:1. Bullhorn partnerships team confirms whether marketplace is required for production tenant access (`partnerships@bullhorn.com` outreach, Sunday/Monday).
docs/decisions/bullhorn-integration-path.md:375:3. First design partner ATS confirmed as Bullhorn (Sunday design-partner conversation 2 per master brief §6 Day 2 line 467).
docs/decisions/bullhorn-integration-path.md:377:Reduction trigger for Risk #2 severity: this Status flip closes one of the two Bullhorn-auth-related gates.
docs/decisions/bullhorn-integration-path.md:381:Recommendation: authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement); authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (client_credentials grant **foreclosed** by Bullhorn OAuth docs per §3.2 — Bullhorn does not support client_credentials grant for tenant-scoped data). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:385:1. Bullhorn dev support confirms authorization-code grant is the correct production path.
docs/decisions/bullhorn-integration-path.md:390:Reduction trigger for Risk #2 severity: this Status flip closes the second of two Bullhorn-auth gates.
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:402:### 6.1 — For Week 1-2 (Bullhorn MCP connector scaffolding)
docs/decisions/bullhorn-integration-path.md:408:- **Bullhorn client_id + client_secret obtained** via support ticket per §2.2 verified path — commercial action, founder Sunday/Monday.
docs/decisions/bullhorn-integration-path.md:409:- **IFOS-owned Bullhorn dev tenant provisioned** (may require partnership conversation) — commercial action, founder Sunday/Monday.
docs/decisions/bullhorn-integration-path.md:419:Concierge's write capability to Bullhorn (Note auto-send, status updates per §4.1) interacts with Day 5's auto-send safety policy artefact. Day 5 should reference this document's §4.1 Concierge row for the specific entities Concierge will be writing — Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI.
docs/decisions/bullhorn-integration-path.md:423:Bullhorn entity field mapping (Candidate, JobOrder, Placement, Note, ClientCorporation) → IFOS wiki schema per `second-brain-design.md` §2.2 entity types. Out of scope for this Day-2 decision; flagged for Week 11-13 work. Concrete handoff: §4.1's per-agent read-entity list is the v1.0 minimum set the wiki ingest paths must handle.
docs/decisions/bullhorn-integration-path.md:436:- Sub-decision C Accepted status is justified by §4's technical analysis grounded in verified Bullhorn public-doc citations.
docs/decisions/bullhorn-integration-path.md:442:§3.2 finding (Bullhorn does NOT support client_credentials grant for tenant-scoped data per public OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`) forecloses the master brief §6 Day 2 line 466 pre-statement. New sixth edit for the atomic correction commit alongside ADR-001 + ADR-002 + ADR-003 Edit C.
docs/decisions/bullhorn-integration-path.md:446:> "- [ ] Decision: Bullhorn Marketplace vs Direct API. OAuth model: browser dance for production, service-account for dev. Document in `docs/decisions/bullhorn-integration-path.md`"
docs/decisions/bullhorn-integration-path.md:450:> "- [ ] Decision: Bullhorn Marketplace vs Direct API. OAuth model: authorization-code grant for production tenants; authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (Bullhorn does not support `client_credentials` grant for tenant-scoped data per Bullhorn OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`). Document in `docs/decisions/bullhorn-integration-path.md`."
docs/decisions/bullhorn-integration-path.md:454:### 6.7 — For Risk #2 (Bullhorn auth path)
docs/decisions/bullhorn-integration-path.md:460:**Reduction trigger 2 (Medium → Low):** first Bullhorn write lands cleanly in Week 3-4 Janitor agent build (the master brief §12 / Ultraplan §10 row #2 tripwire test "core read endpoints working" passes).
docs/decisions/bullhorn-integration-path.md:468:- **Bullhorn MCP connector implementation details** (TypeScript module layout, request-builder pattern, error-class hierarchy) — to ADR-004 in Week 1-2 if architectural choices surface, or to the implementation PR itself if straightforward.
docs/decisions/bullhorn-integration-path.md:471:- **Per-entity OAuth scope model** (Spec gap §3.1-B) — deferred to Bullhorn dev support verification; result folds into connector's auth-module implementation, not a new ADR.
docs/decisions/bullhorn-integration-path.md:486:| Rate-limit budget allocation | §4.4 | Conservative v1.0 defaults (400-1000 req/hour/tenant total; 30% reserve); revise when Bullhorn confirms actuals |
docs/decisions/bullhorn-integration-path.md:492:| 6th edit | Master brief §6 Day 2 line 466 | `service-account for dev` → `authorization-code grant against an IFOS-owned Bullhorn dev tenant` (per §6.6) | Joins atomic correction commit at end of Week 0 / early Week 1, alongside ADR-001 + ADR-002 + ADR-003 Edit C |
docs/decisions/bullhorn-integration-path.md:498:| Bullhorn client_id + client_secret obtained via support ticket per §2.2 | Founder (commercial action) | Sunday/Monday outreach; tickets typically resolve 1-5 business days |
docs/decisions/bullhorn-integration-path.md:499:| IFOS-owned Bullhorn dev tenant provisioned | Founder (commercial action) | Sunday/Monday; may bundle with the same partnerships conversation |
docs/decisions/bullhorn-integration-path.md:500:| Bullhorn MCP connector scaffolded at `packages/mcp-connectors/bullhorn/` | Claude Code | Week 1-2 (after ADR-003 renderer impl) |
docs/decisions/bullhorn-integration-path.md:509:| §3.1-B: assume no per-entity OAuth scope granularity → `validate.sh` Gate A is the only enforcement layer | Bullhorn dev support confirms different — adjust connector auth-module to request scoped tokens |
docs/decisions/bullhorn-integration-path.md:510:| §3.2-A: assume `client_credentials` genuinely unsupported (not partner-tier-only) | Bullhorn dev support reveals partner-tier-only support — dev-loop ergonomics improve; production path unchanged |
docs/decisions/bullhorn-integration-path.md:512:| §4.4-A: conservative 400-1000 req/hour/tenant rate-limit budget | Bullhorn dev support confirms actuals — revise budget table |
docs/decisions/2026-05-18-codex-ratification-manifest.md:33:| 18 | `docs/verticals/recruitment/vertical-schema.yaml` | Proposed | Verify 8 entities + 89 fields + 10 relationships + agent R/W matrix + 12 open_questions; cross-check Bullhorn mapping against §4.1 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:269:| 6 | §6 Day 2 line 466 OAuth wording | Bullhorn §6.6 | ✓ verbatim |
docs/decisions/2026-05-18-codex-ratification-manifest.md:287:| 7 | `bullhorn-integration-path.md` Sub-decisions A+B | Proposed pending commercial conversations | Either (a) run the Bullhorn outreach + design-partner #1 conversation during extension and flip to Accepted, OR (b) accept ratification of Sub-decision C only, with A+B explicitly marked "deferred to first pilot's actual ATS confirmation" |
docs/decisions/autosend-safety-policy.md:25:1. Writes to any external system via MCP connector (Bullhorn, Companies House, Xero, Microsoft Graph, etc.) — every `tools.yaml`-declared write scope
docs/decisions/autosend-safety-policy.md:51:**Default characteristics:** idempotent OR internal-to-tenant OR read-only against external systems with rate-limit budget remaining OR low-cost-to-reverse (e.g., add a Bullhorn tag that can be removed in <30s).
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:83:| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
docs/decisions/autosend-safety-policy.md:84:| Sourcing Scout | `linkedin_profile_cache` | Stores profile snapshot to `/vault/<tenant>/wiki/raw/`; no external send; no rate-limit cost |
docs/decisions/autosend-safety-policy.md:94:| Sourcing Scout | `linkedin_connection_request` | 1-in-5 | Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy |
docs/decisions/autosend-safety-policy.md:96:| Concierge | `bullhorn_note_draft_internal` | 1-in-10 | Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate |
docs/decisions/autosend-safety-policy.md:102:| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
docs/decisions/autosend-safety-policy.md:110:| Sourcing Scout | `linkedin_inmail_send` | Outbound InMail (paid credit); cost-per-send; customer-facing |
docs/decisions/autosend-safety-policy.md:414:Full message content lives in the originating system (Bullhorn, Gmail, Twilio). Audit references the system's own audit log (e.g., Bullhorn note ID) via `payload.target`.
docs/decisions/autosend-safety-policy.md:604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:642:1. Tier classifications per §3 (especially canonical orange = Concierge Bullhorn Note)
docs/architecture/second-brain-design.md:175:│   │   └── ats-snapshots/                          ← Bullhorn entity snapshots (master brief §5.1 line 321)
docs/architecture/second-brain-design.md:205:| `wiki/raw/briefs/` | one file per brief intake | markdown with frontmatter | `{epoch}-{brief-id}.md` | Brief Decoder (v1.1) on inbound | Sourcing Scout (v1.0 reads only candidate-relevant); Brief Decoder (v1.1) |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:211:| `wiki/compiled/briefs/{slug}.md` | one per Brief | same | same | Brief Decoder (v1.1); manual at v1.0 if needed | Sourcing Scout (v1.0 reads only); Brief Decoder (v1.1) |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:237:| Brief | **v1.0 (skeleton) / v1.1 (full)** | Sourcing Scout (v1.0 A5) needs to *read* a Brief to source against; Brief Decoder (v1.1 A8) is the producer. v1.0 writes minimal Briefs (manual entry or direct Bullhorn sync via Janitor); full lifecycle waits for v1.1 |
docs/architecture/second-brain-design.md:258:  - janitor:bullhorn-2026-05-15
docs/architecture/second-brain-design.md:319:v1.0 skeleton: only what Sourcing Scout (A5) needs to source against — role title, client, sector, must-haves. Full v1.1 schema waits for Brief Decoder.
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:429:| `list-by-type-and-tenant` | Sourcing Scout (v1.0): enumerate Candidates for filtering; Brief Decoder (v1.1): enumerate open Briefs | v1.0 (Candidate, Client, Placement, Contact); v1.1 (Brief full enumeration) | `(entity_type: str, tenant_id: str, filters?: dict, limit?: int)` | `List[EntityRef]` | few seconds | Postgres-indexed; filtering matches `search-by-attribute` |
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:774:| Sourcing Scout | 50:1 | reads briefs + candidate pool to filter; writes only shortlists |
docs/architecture/second-brain-design.md:775:| Janitor | 1:5 | reads each Bullhorn entity once; writes many cleanup updates per sweep |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:893:| **Consistency with cortextOS bus convention** | Identical pattern: 47 existing bus wrappers under `packages/harness/cortextos/bus/` all do `exec node dist/cli.js bus <command>`. Option α uses the same 3-line shim shape. Zero cognitive tax for an engineer who already understands cortextOS. | New surface (MCP). Aligns with the vertical-adapter pattern (master brief §3.2) where Bullhorn / Companies House etc. are MCP servers — so consistent with that pattern, not with the bus pattern. | Aligns with cortextOS's skill convention (each template ships `.claude/skills/` with kb / memory / tasks / heartbeat / etc.). Inconsistent with the bus pattern; consistent with the skill pattern; awkward under R2. |
docs/architecture/second-brain-design.md:907:2. **Master brief §8 (Agent Bundle v2 pattern + `tools.yaml` contract).** §8.1 specifies the bundle has `tools.yaml` for "MCP servers + scopes + degraded modes" — i.e. external MCP connectors (Bullhorn, Companies House, Xero). The wiki is **internal** to IFOS, not an external execution backend. Treating wiki ops as bus commands (Option α) keeps `tools.yaml` clean of internal-surface declarations; treating them as MCP tools (Option β) conflates internal-data-access with external-tool-invocation in the same `tools.yaml`.
docs/decisions/v1.0-kill-criterion.md:33:- **ATS pivot:** Bullhorn-first → Vincere-first, Voyager Infinity-first, or vertical-without-ATS
docs/decisions/v1.0-kill-criterion.md:75:**Threshold:** Janitor agent cannot authenticate to Bullhorn via the documented OAuth flow (per `bullhorn-integration-path.md` §4.5 refresh-loop architecture) by end of Week 5 (2026-06-28). Authentication failure modes that trigger: (a) OAuth token endpoint returns non-2xx persistently; (b) refresh-loop architecture fails at 10-minute TTL boundary; (c) Bullhorn rate-limits IFOS's auth endpoint preventing pilot operations; (d) Bullhorn partnership programme requirement blocks production-tenant access.
docs/decisions/v1.0-kill-criterion.md:81:**Action:** PIVOT state. Rescope from Bullhorn-first to alternate ATS-first:
docs/decisions/v1.0-kill-criterion.md:83:- **Option A:** Vincere-first. Mid-market UK recruitment ATS; smaller market than Bullhorn but more accessible API.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:128:- Bullhorn API call at <£0.001 per action (free tier)
docs/decisions/v1.0-kill-criterion.md:136:**Action:** PIVOT — likely vector: cheaper Claude model tier (Haiku 4.5 for routine actions, Sonnet for complex), or reduced agent run frequency (e.g., Sourcing Scout runs nightly batch instead of real-time), or per-tenant cost passthrough in pricing.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:339:- The ATS assumption: Bullhorn-first per `bullhorn-integration-path.md` Sub-decision C
docs/decisions/v1.0-kill-criterion.md:347:- Adds 7 agents: Inbound Triage, Brief Decoder, Night Sourcer, Competitor Interception, Client Hunter digest, T5 Supply Chain Auditor, T3 Compliance Watchtower

exec
/bin/zsh -lc 'rg -n "hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|hh_decision_|applies_to_agents|sourcing_scout|blocked_recipients|send_to_blocked_recipient|candidate.status|date_last_modified_at|last_activity_at" agents docs packages -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:5:# hh_decision_action() invocation. Per-tenant overrides live in Postgres
agents/_shared/autosend-policy.yaml:345:  send_to_blocked_recipient:
agents/_shared/autosend-policy.yaml:349:    reason: "Recipient in tenant's blocked_recipients override list"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:347:  #   Scout R+W. Implementation: cycle.sh + hh_decision_action records which
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:357:  # layer (cycle.sh + hh_decision_action) where the agent_name in the
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:414:  sourcing_scout:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:416:    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:574:      Janitor agent.md §7 calls hh_load_tone_rules filtered by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:575:      applies_to_agents containing 'janitor' for tacit-note narrative
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:691:    sourcing_scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:700:    sourcing_scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:709:    sourcing_scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:720:    sourcing_scout: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:727:    sourcing_scout: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:734:    sourcing_scout: none
agents/_shared/hook-helpers.sh:3:# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
agents/_shared/hook-helpers.sh:163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
agents/_shared/hook-helpers.sh:166:# hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/hook-helpers.sh:168:hh_decision_trigger() {
agents/_shared/hook-helpers.sh:177:# hh_decision_output <output_type> <artefact_ref> [<reason>]
agents/_shared/hook-helpers.sh:180:hh_decision_output() {
agents/_shared/hook-helpers.sh:190:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:193:hh_decision_action() {
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:152:      applies_to_agents:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:255:        source: IFOS-derived (Gate-A fires recorded by validate.sh + hh_decision_action)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:88:             AND (cardinality(applies_to_agents) = 0 OR '$(_hh_json_escape "${agent_name}")' = ANY(applies_to_agents))
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
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
docs/verticals/recruitment/vertical-schema.yaml:87:        source: Bullhorn.Candidate.status
docs/verticals/recruitment/vertical-schema.yaml:100:      date_last_modified_at:
docs/verticals/recruitment/vertical-schema.yaml:140:        enum: [linkedin, referral, bullhorn_existing, direct_application, sourcing_scout, other]
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:218:      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
docs/verticals/recruitment/vertical-schema.yaml:420:      date_last_modified_at:
docs/verticals/recruitment/vertical-schema.yaml:526:      date_last_modified_at:
docs/verticals/recruitment/vertical-schema.yaml:712:  Sourcing_Scout:
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:79:-- is the indexed surface for hh_load_voice_samples semantic retrieval.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:119:  applies_to_agents   TEXT[]      NOT NULL DEFAULT '{}',
agents/recruitment/cash-conductor/agent.md:97:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type per autosend-policy.yaml line 257) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
agents/recruitment/cash-conductor/agent.md:149:14 steps. Per ADR-003 §3 agent-bundle pattern + the review-agent-bundle Codex ratification skill §4 ("every output/action step MUST call hh_decision_*"): every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Master brief §8.1 Change 2 mandates the three-call minimum per agent run (`trigger`, `output`, `action`); the per-step mandatory-write discipline is the agent-bundle contract extension.
agents/recruitment/cash-conductor/agent.md:155:   → hh_decision_trigger("session_start", "<webhook|cron|manual>")
agents/recruitment/cash-conductor/agent.md:163:   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
agents/recruitment/cash-conductor/agent.md:178:   → hh_decision_output("transactions_ingested", "tenant:<slug>",
agents/recruitment/cash-conductor/agent.md:185:   → hh_decision_output("invoices_ingested", "tenant:<slug>", "<N> rows")
agents/recruitment/cash-conductor/agent.md:193:   → hh_decision_output("reconciliation_pass", "tenant:<slug>",
agents/recruitment/cash-conductor/agent.md:199:   → on success: hh_decision_action("accounting_reconciliation_write",
agents/recruitment/cash-conductor/agent.md:210:     hh_decision_output("chase_position_4_operator_review",
agents/recruitment/cash-conductor/agent.md:222:   → hh_decision_output("chase_draft_generated", "invoice:<id>",
agents/recruitment/cash-conductor/agent.md:238:   → hh_decision_output("chase_draft_validated", invoice_id, "passed")
agents/recruitment/cash-conductor/agent.md:242:    → hh_decision_action("xero_reminder_draft_internal", "invoice:<id>",
agents/recruitment/cash-conductor/agent.md:245:    → hh_decision_action("xero_reminder_send_customer", "invoice:<id>",
agents/recruitment/cash-conductor/agent.md:261:    → hh_decision_output("cash_conductor_chase_sent_recorded",
agents/recruitment/cash-conductor/agent.md:270:    → hh_decision_output("chase_cancellation_check", "invoice:<id>",
agents/recruitment/cash-conductor/agent.md:278:    → hh_decision_output("weekly_report", report_path,
agents/recruitment/cash-conductor/agent.md:283:    → hh_decision_action("cash_conductor_run_complete", "session:<session_id>",
agents/recruitment/cash-conductor/agent.md:285:      — hh_decision_action signature is (action_type, target, payload_hash,
agents/recruitment/cash-conductor/agent.md:356:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:360:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/cash-conductor/agent.md:361:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
agents/recruitment/scribe/agent.md:127:10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/scribe/agent.md:133:   → hh_decision_trigger("session_start", "scribe webhook for <call_id>")
agents/recruitment/scribe/agent.md:139:   → hh_decision_output("webhook_verified", "call:<id>", "provider:<name>")
agents/recruitment/scribe/agent.md:159:   → hh_decision_output("entity_resolved", "<entity_type>:<bullhorn_id>", confidence)
agents/recruitment/scribe/agent.md:167:   → hh_decision_output("fields_extracted", "<entity_type>:<bullhorn_id>",
agents/recruitment/scribe/agent.md:177:   → hh_decision_output("tacit_note_rendered", "<vault_path>",
agents/recruitment/scribe/agent.md:189:   → on success: hh_decision_action("bullhorn_scribe_field_write",
agents/recruitment/scribe/agent.md:195:   → on success: hh_decision_action("bullhorn_note_attach",
agents/recruitment/scribe/agent.md:204:   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
agents/recruitment/scribe/agent.md:272:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:276:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:277:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/sourcing-scout/agent.md:16:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:104:11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/sourcing-scout/agent.md:109:     + DNC list from `tenant_adapters.config.blocked_recipients` (Postgres-
agents/recruitment/sourcing-scout/agent.md:112:   → hh_decision_trigger("session_start", "scout <brief-id-or-slug>")
agents/recruitment/sourcing-scout/agent.md:120:   → hh_decision_output("brief_ingested", "<brief_id_or_slug>",
agents/recruitment/sourcing-scout/agent.md:132:   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
agents/recruitment/sourcing-scout/agent.md:137:     status='active', date_last_modified_at < now() - interval '90 days')
agents/recruitment/sourcing-scout/agent.md:140:     candidate.status as [active, archived, do_not_contact, placed,
agents/recruitment/sourcing-scout/agent.md:141:     contractor_promoted] (line 84-88) and candidate.date_last_modified_at
agents/recruitment/sourcing-scout/agent.md:146:   → hh_decision_output("bullhorn_query", "brief:<id>", "results:<N>")
agents/recruitment/sourcing-scout/agent.md:154:   → hh_decision_output("linkedin_query", "brief:<id>", "results:<N>")
agents/recruitment/sourcing-scout/agent.md:161:   → hh_decision_output("reed_query", "brief:<id>", "results:<N>")
agents/recruitment/sourcing-scout/agent.md:168:   → hh_decision_output("cvlibrary_query", "brief:<id>", "results:<N>")
agents/recruitment/sourcing-scout/agent.md:176:   → hh_decision_output("aggregate_dedupe", "brief:<id>",
agents/recruitment/sourcing-scout/agent.md:180:   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
agents/recruitment/sourcing-scout/agent.md:182:     `send_to_blocked_recipient`; canonical Postgres-stored structured
agents/recruitment/sourcing-scout/agent.md:191:   → hh_decision_output("dnc_filter", "brief:<id>",
agents/recruitment/sourcing-scout/agent.md:201:   → hh_decision_output("candidate_proposed", "candidate:<bullhorn_id|external_ref>",
agents/recruitment/sourcing-scout/agent.md:214:    → hh_decision_output("scout_report", report_path, "N candidates from M sources")
agents/recruitment/sourcing-scout/agent.md:219:    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
agents/recruitment/sourcing-scout/agent.md:235:- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
agents/recruitment/sourcing-scout/agent.md:287:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:292:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:293:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
agents/recruitment/sourcing-scout/agent.md:319:| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
agents/recruitment/sourcing-scout/agent.md:340:| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
agents/recruitment/sourcing-scout/agent.md:344:| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `last_activity_at < now() - 90 days` to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side activity-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |
agents/recruitment/janitor/agent.md:79:12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/janitor/agent.md:85:   → hh_decision_trigger("session_start", "janitor nightly cron")
agents/recruitment/janitor/agent.md:96:   → hh_decision_output("janitor_scan", "tenant:<slug>", "<N> entities scanned")
agents/recruitment/janitor/agent.md:106:     hh_decision_action emitted at Step 9 when each merge actually writes)
agents/recruitment/janitor/agent.md:119:   → hh_decision_output("field_completeness_audit", tenant, "<N> missing-field rows")
agents/recruitment/janitor/agent.md:144:   → for each proposed merge / backfill / note: emit hh_decision_action with
agents/recruitment/janitor/agent.md:156:   → hh_decision_output("day_30_report", "<path>", "Gate-B score: <N>")
agents/recruitment/janitor/agent.md:162:   → hh_decision_action("operator_notify_telegram", "tenant:<slug>",
agents/recruitment/janitor/agent.md:167:   → hh_decision_action("janitor_run_complete", "tenant:<slug>", payload_hash, payload_preview)
agents/recruitment/janitor/agent.md:230:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/janitor/agent.md:234:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
agents/recruitment/janitor/agent.md:235:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/diagnostic/cleanup.sh:55:  hh_decision_action "linkedin_cache_purge_fail" "cleanup:${CTX_TENANT_SLUG}" \
agents/recruitment/diagnostic/cleanup.sh:79:hh_decision_action "diagnostic_cleanup" "agent:${CTX_AGENT_NAME:-diagnostic}" \
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
agents/recruitment/concierge/agent.md:116:15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/concierge/agent.md:124:   → hh_decision_trigger("session_start", "<webhook|poll|cron-nurture>")
agents/recruitment/concierge/agent.md:134:   → hh_decision_output("lifecycle_event_detected",
agents/recruitment/concierge/agent.md:145:   → hh_decision_output("anti_duplicate_check", "<entity_type>:<bullhorn_id>",
agents/recruitment/concierge/agent.md:157:   → hh_decision_output("bullhorn_context_fetched",
agents/recruitment/concierge/agent.md:166:   → hh_decision_output("addressee_resolved", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:173:   → hh_decision_output("template_selected", "<event_type>:<recipient_role>",
agents/recruitment/concierge/agent.md:181:   → hh_decision_output("escalation_position_set", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:199:   → on success: hh_decision_action("concierge_email_draft",
agents/recruitment/concierge/agent.md:216:    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:230:    → hh_decision_action("gmail_outlook_send_to_candidate",
agents/recruitment/concierge/agent.md:239:    → hh_decision_output("bullhorn_activity_logged",
agents/recruitment/concierge/agent.md:246:    → hh_decision_action("concierge_send_complete", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:254:    → hh_decision_action("concierge_run_complete", session_id, run_mode)
agents/recruitment/concierge/agent.md:329:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
agents/recruitment/concierge/agent.md:336:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:337:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
agents/recruitment/diagnostic/cycle.sh:107:  hh_decision_action "diagnostic_input_invalid" "firm:${FIRM_NAME}" \
agents/recruitment/diagnostic/cycle.sh:161:  hh_decision_action "diagnostic_generator_empty" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:171:hh_decision_output "diagnostic_draft" "${DRAFT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:188:hh_decision_output "diagnostic_report" "${REPORT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:191:hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:214:    hh_decision_action "operator_notify_telegram" "operator:${TELEGRAM_OPERATOR_CHAT_ID}" \
agents/recruitment/diagnostic/validate.sh:265:  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
agents/recruitment/diagnostic/context.sh:25:#   - Emits hh_decision_trigger("session_start", ...) as first audit row
agents/recruitment/diagnostic/context.sh:83:hh_decision_trigger "session_start" "diagnostic agent for firm: ${IFOS_DIAGNOSTIC_FIRM_NAME:-<unset>}" \
agents/recruitment/diagnostic/context.sh:85:    printf 'context.sh: hh_decision_trigger failed; vault may be unwritable\n' >&2
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
agents/recruitment/diagnostic/agent.md:73:- Step 10 report assembly → `hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")`
agents/recruitment/diagnostic/agent.md:74:- Step 11 (optional) operator notify → `hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)` — green tier per autosend-policy.yaml
agents/recruitment/diagnostic/agent.md:75:- Step 12 session close → `hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)` — green tier
agents/recruitment/diagnostic/agent.md:81:Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. The v0 cycle.sh implementation uses a generator-level pattern: a single call to `@ifos/diagnostic-generator` (`packages/diagnostic-generator/`) fetches all 12 sections in one process; cycle.sh emits decision-log rows at draft-write + report-write + render-action boundaries, not per-section. Per-section data acquisition is internal to the generator package and not separately audited at v0; W4 polish may add per-section telemetry.
agents/recruitment/diagnostic/agent.md:86:   → hh_decision_trigger("session_start", firm_name + sector_hint)
agents/recruitment/diagnostic/agent.md:90:   → on fail: hh_decision_action("diagnostic_input_invalid", ...) with
agents/recruitment/diagnostic/agent.md:106:   → on empty stdout: hh_decision_action("diagnostic_generator_empty", ...) with
agents/recruitment/diagnostic/agent.md:110:   → hh_decision_output("diagnostic_draft", "<draft_path>", "<firm> 12-section draft (pre-validate)")
agents/recruitment/diagnostic/agent.md:117:   → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
agents/recruitment/diagnostic/agent.md:127:   → hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")
agents/recruitment/diagnostic/agent.md:128:   → hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:133:     → hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:154:- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
agents/recruitment/diagnostic/agent.md:156:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
agents/recruitment/diagnostic/agent.md:192:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:196:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
agents/recruitment/diagnostic/agent.md:197:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
docs/architecture/architecture-cohesion-review.md:71:| ADR-004 | phase enum pattern | `agents/_shared/hook-helpers.sh::hh_decision_action` | ✓ landed Phase 3 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:41:**Codex says:** "Lines 140-142 send an optional Telegram notification, but line 73 says every step that produces output or takes action MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:43:**Disposition:** **Codex is correct.** Real bug. Step 11 sends a Telegram notification (an action with external side-effect) but doesn't emit a `decision_log` row. Mechanical fix: add `hh_decision_action("operator_notify_telegram", ...)` call to Step 11.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:128:2. **Workflow steps missing decision-log calls** — most agent.md files have at least one Step (notification, operator alert, status update) that produces side-effects without `hh_decision_*` call. Same disposition as Diagnostic Issue 2 — mechanical fix during W4-13 build slices when cycle.sh is implemented.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:214:1. `operator_notify_telegram` + `janitor_run_complete` are unregistered hh_decision_action types — hook-helpers fails them to red via `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`. (Found because my Round-6 commit added those calls without registering them.)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:257:- Cat-2 (decision-log calls): added hh_decision_output / hh_decision_action calls across all §4 sections; pre-registered action_types via Phase 1
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:307:- Diagnostic cycle.sh: sends Telegram directly via curl with no `hh_decision_action` row
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:311:#### Category ε — Hh_decision_* still missing at some steps
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:364:- `cycle.sh` adds `hh_decision_action("operator_notify_telegram", ...)` call before Step 14 Telegram send
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/operations/goal-week-3-polish-and-scaffold.md:63:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:208:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:499:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:307:# Gate A: hard-fail on missing hh_decision_* calls in this run
docs/architecture/agent-bundle-renderer-design.md:322:hh_load_tone_rules
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:370:   `hh_decision_trigger` at start of every run
docs/architecture/agent-bundle-renderer-design.md:371:   `hh_decision_output` before producing the artefact
docs/architecture/agent-bundle-renderer-design.md:372:   `hh_decision_action` when the human resolves
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:198:| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:427:| `update-entity` | Concierge (v1.0): append conversation note to Candidate page | v1.0 | `(id: str, section: str, content: str, tenant_id: str)` | `EntityRef` | few seconds | Targets the `<!-- BEGIN auto:{section} -->` block per §2.2.1; preserves frontmatter; rewrites backlinks if `display_name` changes; `hh_decision_*` called |
docs/architecture/second-brain-design.md:428:| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:654:        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
docs/architecture/second-brain-design.md:676:| `ingest-entity` | Filesystem write (atomic) + Postgres UPSERT to `entities` + Postgres INSERTs to `entity_links` (all in one transaction per §2.6.1) | None — atomic or fail | Slug collision check via Postgres `SELECT 1 FROM entities WHERE tenant_slug = ? AND id = ?`. `hh_decision_trigger` + `hh_decision_output` calls insert to `decision_log` in the same transaction. |
docs/architecture/second-brain-design.md:682:| `entity-history` | Postgres `decision_log` SELECT by `(tenant_slug, entity_id)` ORDER BY `created_at DESC` | None | v1.1 read; v1.0 writes via `hh_decision_*`. No filesystem fallback — decision_log is unique source. |
docs/architecture/second-brain-design.md:712:- No corruption; both changes land; decision_log captures both `hh_decision_output` rows separately.
docs/architecture/second-brain-design.md:782:**Decision-log volume:** every agent run produces 1-3 `decision_log` rows (`hh_decision_trigger`, `hh_decision_output`, optionally `hh_decision_action` when human responds). At 6 v1.0 agents × ~10 runs/agent/day × 3 tenants × 3 rows = ~540 rows/day per shared Postgres instance. Trivial volume; the table needs hash partitioning (per Ultraplan §5.1) primarily for query performance at v1.2+ scale, not v1.0 write throughput.
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
packages/agent-renderer/templates/claude-md-preamble.md:22:- `hh_decision_trigger` at start of every run
packages/agent-renderer/templates/claude-md-preamble.md:23:- `hh_decision_output` before producing the artefact
packages/agent-renderer/templates/claude-md-preamble.md:24:- `hh_decision_action` when the human resolves
packages/agent-renderer/templates/claude-md-preamble.md:44:- `memory/` — replaced by Postgres `decision_log` (writes via `hh_decision_*` helpers).
docs/decisions/bullhorn-integration-path.md:324:- **Postgres `decision_log` RLS:** every Bullhorn-derived `hh_decision_*` row is tenant-scoped per ADR-002 Decision 3 (`tenant_slug` column + RLS policy per `second-brain-design.md` §2.4.2).
docs/decisions/autosend-safety-policy.md:6:**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
docs/decisions/autosend-safety-policy.md:7:**Surfaced by:** Master brief Day 5 spec; load-bearing for every `hh_decision_action` call across the v1.0 agent fleet.
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:124:| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |
docs/decisions/autosend-safety-policy.md:128:## §4 — Integration with the `hh_decision_action` contract
docs/decisions/autosend-safety-policy.md:132:- `hh_decision_trigger` — at session start; logs the trigger
docs/decisions/autosend-safety-policy.md:133:- `hh_decision_output` — when the agent produces its output artefact
docs/decisions/autosend-safety-policy.md:134:- `hh_decision_action` — when an action is taken (or blocked)
docs/decisions/autosend-safety-policy.md:136:The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.
docs/decisions/autosend-safety-policy.md:141:# hh_decision_action — gate every side-effecting action through the policy
docs/decisions/autosend-safety-policy.md:147:hh_decision_action() {
docs/decisions/autosend-safety-policy.md:209:The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
docs/decisions/autosend-safety-policy.md:352:| Policy file `autosend-policy.yaml` corrupted (YAML parse error) | First `hh_decision_action` call returns parse error | Fail-safe red for ALL actions; `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` per action; agent halts | IFOS oncall restores from git history; renderer re-deploys; agent resumes |
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:437:    "blocked_recipients": [
docs/decisions/autosend-safety-policy.md:463:3. **`blocked_recipients`** is additive only. Recipients can be added; system-default red-list recipients cannot be removed. Pattern matching supported via `*` wildcards.
docs/decisions/autosend-safety-policy.md:539:  (c) breaches of Tenant's configured blocked_recipients list by the
docs/decisions/autosend-safety-policy.md:598:| 3 | Policy lookup latency — must be <10ms per `hh_decision_action` call. Caching strategy needed (in-memory per session vs hot-reload). | §4 | Recommend in-memory cache per session (71h cache lifetime aligns with cortextOS context rotation). Hot-reload via PTY restart only. |
docs/decisions/autosend-safety-policy.md:599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:601:| 6 | v1.0 "would-be-orange" cases without orange tier implementation — how does the agent halt for ad-hoc Telegram approval without breaking the green/red binary? | §9 | Recommend a `hh_decision_action_ad_hoc_approval` helper that lives alongside `hh_decision_action`; agent explicitly calls it for known orange cases at v1.0; v1.1 deprecates as orange tier ships. |
docs/decisions/autosend-safety-policy.md:622:- **Q6 (v1.0 ad-hoc orange handling without orange tier shipped):** ACCEPTED. `hh_decision_action_ad_hoc_approval` helper sits alongside `hh_decision_action` in `_shared/hook-helpers.sh` (Week-1 prereq 3). Agent explicitly calls `_ad_hoc_approval` for known orange cases at v1.0; v1.1 deprecates the helper as full orange tier ships through `hh_decision_action`'s case-orange branch.
docs/decisions/autosend-safety-policy.md:632:**For Week 1-2.** The `_shared/voice-loader.sh` + `hook-helpers.sh` Week-1 prerequisite (per ADR-002 §"For Week 1 work" + ADR-003 Decision 3) now has its `hh_decision_action` specification. Implementation work is well-defined: §4 pseudocode + §5 escalation payloads + §7 audit row schema.
docs/decisions/autosend-safety-policy.md:643:2. `hh_decision_action` pseudocode per §4
docs/runbooks/tenant-lifecycle.md:148:| Agent draft + approve via Telegram | `hh_decision_action` writes to decision_log; orange-tier blocks on Telegram approval | T4 (every write sets SET LOCAL) |
docs/build-brief/00-MASTER-BRIEF.md:57:4. **Quality gates before features.** Gate A (per-run `validate.sh`) working + decision-log writes (`hh_decision_trigger / output / action`) present > extra features. `validate.sh` hard-fails on missing decision-log calls. No exceptions.
docs/build-brief/00-MASTER-BRIEF.md:508:| `phase-2-agent-suite/_shared/hook-helpers.sh` | Common validate/telemetry shell fns | `packages/agents-runtime/_shared/hooks/hook-helpers.sh` | Add `hh_decision_trigger/output/action` per Ultraplan §4.2 |
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:571:hh_decision_trigger   # at start; logs trigger
docs/build-brief/00-MASTER-BRIEF.md:572:hh_decision_output    # on output; logs the artefact
docs/build-brief/00-MASTER-BRIEF.md:573:hh_decision_action    # when human acts; logs the action
docs/build-brief/00-MASTER-BRIEF.md:672:                 │  → bus-overrides                    │   entity-graph svc                        │   hh_decision_*
docs/specs/ULTRAPLAN.md:155:hh_load_tone_rules
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:171:hh_decision_trigger     # Called at start of agent run; logs the trigger
docs/specs/ULTRAPLAN.md:172:hh_decision_output      # Called when agent produces output; logs the artefact
docs/specs/ULTRAPLAN.md:173:hh_decision_action      # Called when human acts on output; logs the action
docs/specs/_archive-build-handoff.md:431:- **Decision logging is required** (Ultraplan §4.2 change 2). Every agent run writes three log entries via `hh_decision_trigger`, `hh_decision_output`, `hh_decision_action`. Missing calls = hard fail in validate.sh. This is what enables the per-tenant LoRA pipeline at v2.0.
packages/agent-renderer/tests/fixtures/test-agent/agent.md:11:1. `hh_decision_trigger` at session start
packages/agent-renderer/tests/fixtures/test-agent/agent.md:13:3. Echo input + emit `hh_decision_output`
packages/agent-renderer/tests/fixtures/test-agent/agent.md:14:4. Wait for human resolve; emit `hh_decision_action`
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
packages/agents-runtime/_shared/common-voice.json:46:      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."

codex
The first pass found the relevant source files and a couple of likely pressure points: source-auth semantics, schema field naming, and whether cited sections actually say what the artefact claims. I’m checking exact line ranges now so the verdict can cite specific failures.
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,605p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '535,560p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '90,190p'; nl -ba agents/_shared/escalation-codes.md | sed -n '236,265p'; nl -ba agents/_shared/escalation-codes.md | sed -n '372,430p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   261	- **Payload fields:** `failure_type` (`session_expired` | `bot_detected_999` | `revoked_401`), `last_attempt_at`
   262	- **Recovery:** founder reauthenticates LinkedIn via Sourcing Scout admin flow
   263	
   264	#### `ESC_GMAIL_AUTH`
   265	- **Severity:** **blocking** — Concierge cannot send candidate emails; falls back to draft-only
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '80,105p'; nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '414,430p'; nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '535,545p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   414	  sourcing_scout:
   415	    # v0.3 EXPLICIT OVERRIDES (per Round-6 finding #2): v0.1 base says
   416	    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
   417	    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
   418	    # writes its proposed-candidate rows + reads opportunity context. These
   419	    # are entity-level access overrides codified here.
   420	    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
   421	    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
   422	    client: R
   423	    contact: R
   424	    brief: R               # reads to filter candidates
   425	    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
   426	    placement: none
   427	    timesheet: none
   428	
   429	  concierge:
   430	    # Concierge's Bullhorn endpoint access (Candidate / ClientCorporation /
   535	    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
   536	    v0_3_v1_0_agent_access:
   537	      - Diagnostic (R)     # v0.3 NEW — reads for outreach context (§11 decision-maker map)
   538	      - Janitor (R+W)      # v0.1 unchanged
   539	      - Scribe (R+W)       # v0.1 unchanged
   540	      - Sourcing Scout (R+W) # v0.3 UPGRADED — writes proposed-candidate rows
   541	      - Concierge (R+W)    # v0.3 UPGRADED — writes lifecycle-state-derived fields
   542	    rationale: |
   543	      v0.3 upgrades Sourcing Scout (writes proposed-candidate rows from
   544	      multi-source aggregation) + Concierge (writes lifecycle-state and
   545	      activity-log links per §4 Steps 13-14). Diagnostic gains R for context.

exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '260,520p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	| Code | Trigger | Severity | Routing |
   261	|---|---|---|---|
   262	| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (per catalogue §2.3) | operator + ifos_oncall |
   263	| `ESC_LINKEDIN_AUTH` | LinkedIn / Proxycurl session/OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   264	| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   265	| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   266	| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
   267	| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
   268	| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   269	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
   270	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
   271	| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | founder + operator |
   272	
   273	Sourcing Scout does NOT use:
   274	
   275	- `ESC_AUTOSEND_*` — no auto-send actions; pure read + report
   276	- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
   277	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
   278	- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
   279	- `ESC_DNC_FILTER_HIT` — per catalogue §2.10 reserved for outbound send refusal specifically; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish backlog: add ESC_SOURCING_DNC_FILTER.
   280	
   281	---
   282	
   283	## §7 — Voice + tone constraints
   284	
   285	Step 9 (per-candidate rationale generation) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   286	
   287	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
   288	  - No demographic inference (age, gender, nationality, ethnicity, family status) — Equality Act 2010 compliance
   289	  - No salary-band reference unless explicitly supplied by candidate
   290	  - No claims about candidate intent ("looking to leave their role") without evidence in source data
   291	  - No mention of competing agency placements except in risk-flag context
   292	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
   293	- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
   294	
   295	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   296	
   297	---
   298	
   299	## §8 — Build dependencies (W9 prerequisites)
   300	
   301	Sourcing Scout build cannot start until ALL of the following are confirmed:
   302	
   303	| Dependency | Source | Status |
   304	|---|---|---|
   305	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   306	| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
   307	| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
   308	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   309	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   310	| Bullhorn MCP read capability | W3-W4-W5 build chain | ⏸ |
   311	| **Proxycurl commercial signup** + API access | Founder commercial; ~$39+/mo | ⏸ |
   312	| **Reed.co.uk commercial signup** + API access | Founder commercial | ⏸ |
   313	| **CV-Library commercial signup** + API access | Founder commercial | ⏸ |
   314	| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
   315	| Reed MCP connector | W9 build start (~2 days) | ⏸ |
   316	| CV-Library MCP connector | W9 build start (~2 days) | ⏸ |
   317	| Source-abstraction layer (Night Sourcer reuse) | W9 build start (~2 days) | ⏸ |
   318	| Per-tenant source credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   319	| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
   320	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   321	| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
   322	| `context.sh` hydration | Build at W9 start (~0.5 day) | ⏸ |
   323	| `cycle.sh` orchestration (11-step) | Build at W9 start (~2 days) | ⏸ |
   324	| 3 fixtures with golden outputs | Build at W9 start (~1 day) | ⏸ |
   325	
   326	**Until ALL ⏸ items resolve to ✅, W9 build slice does not start.**
   327	
   328	---
   329	
   330	## §9 — Status + open questions
   331	
   332	**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
   333	
   334	### Open questions for founder review
   335	
   336	| # | Question | Resolution path |
   337	|---|---|---|
   338	| Q1 | All three external sources required for v1.0? Reed + CV-Library are UK-recruitment-specific; Proxycurl is LinkedIn-via-API. Could v1.0 ship with Bullhorn + Proxycurl only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
   339	| Q2 | Proxycurl pricing — ~$39/mo for 5,000 credits at low volume; scales with usage. Per pilot tenant budget? | ~5-10 briefs/day per consultant × 50 calls/brief = up to 2,500 credits/day per consultant. Cost: ~$20-50/day at peak. |
   340	| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
   341	| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
   342	| Q5 | Gate B 6-of-10 metric — measured via consultant feedback. Brain UI v1.0 doesn't have feedback UX yet. Telegram reply? | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful". v1.1: Brain UI button. |
   343	| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
   344	| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `last_activity_at < now() - 90 days` to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side activity-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |
   345	
   346	### Gotchas (carried forward from ULTRAPLAN A5 line 555)
   347	
   348	1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
   349	2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
   350	3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.
   351	
   352	---
   353	
   354	## §10 — When this document ratifies
   355	
   356	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   357	
   358	Status flips Proposed → Accepted when:
   359	- Codex Round 4 Phase 2 ratifies
   360	- Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B UX)
   361	- Q2 cost model approved with per-tenant budget cap
   362	- Q6: ADR-006 (source-abstraction layer) drafted + ratified
   363	
   364	Status flips Accepted → In Force when:
   365	- W9 build slice produces all 5 sibling bundle files + 3 fixtures
   366	- First production brief processed end-to-end against migration-test tenant
   367	- Gate B feedback loop operational (Telegram OR Brain UI)
   368	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   369	
   370	Until then: this document is a forward-looking scaffold.
   371	
   372	*End of Sourcing Scout agent.md draft.*

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
    16	> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
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
   109	     + DNC list from `tenant_adapters.config.blocked_recipients` (Postgres-
   110	     backed per ADR-002 vault/Postgres split; canonical v0.1 + v0.2 + v0.3
   111	     registered config key)
   112	   → hh_decision_trigger("session_start", "scout <brief-id-or-slug>")
   113	
   114	1. Brief ingestion
   115	   → if brief_id: bullhorn.get_brief(brief_id) → fetch fields
   116	   → if free-text description: LLM parse → extract role / location / sector
   117	     / seniority / day-rate-band / must-haves / nice-to-haves
   118	   → ESC_BRIEF_AMBIGUITY if extraction yields <3 key dimensions (per
   119	     escalation-codes.md §2.5 — canonical code for under-resolvable briefs)
   120	   → hh_decision_output("brief_ingested", "<brief_id_or_slug>",
   121	     "key_dims:<N>")
   122	
   123	2. Multi-source auth refresh
   124	   → bullhorn (read-only); LinkedIn/Proxycurl; Reed; CV-Library
   125	   → per-source auth FAILURE is BLOCKING per catalogue §2.3/§2.7:
   126	     ESC_BULLHORN_AUTH | ESC_LINKEDIN_AUTH | ESC_REED_AUTH | ESC_CVLIBRARY_AUTH
   127	     — each routes to operator + ifos_oncall. v1.0 v0.3 disposition: if
   128	     ANY source is down, Sourcing Scout halts (any failed source = blocked
   129	     run); waits for operator reauth before retry. Single-source-failure-
   130	     soft-fallback would require a separate ESC_SOURCING_SOURCE_DEGRADED
   131	     catalogue code (W4-polish; not v0.3).
   132	   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
   133	     "sources_ok:<N>/4; failed:<list>")
   134	
   135	3. Bullhorn passive-match query
   136	   → bullhorn.search_candidates(filter=brief_key_dimensions,
   137	     status='active', date_last_modified_at < now() - interval '90 days')
   138	     — "passive" is a derived state (active candidate not recently
   139	     modified); NOT a vertical-schema enum value. The schema defines
   140	     candidate.status as [active, archived, do_not_contact, placed,
   141	     contractor_promoted] (line 84-88) and candidate.date_last_modified_at
   142	     as the recency field (line 100). Passive-match queries filter on
   143	     modification recency within the active set.
   144	   → up to 30 candidates fetched (will rank+filter later)
   145	   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
   146	   → hh_decision_output("bullhorn_query", "brief:<id>", "results:<N>")
   147	
   148	4. LinkedIn search (via Proxycurl)
   149	   → proxycurl.search_people(query=brief_key_dimensions, location=brief_location,
   150	     industry=brief_sector)
   151	   → up to 30 profiles
   152	   → cache 1h per (query, location, sector) tuple
   153	   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
   154	   → hh_decision_output("linkedin_query", "brief:<id>", "results:<N>")
   155	
   156	5. Reed query
   157	   → reed.search_candidates(query=brief_dimensions, location, salary_band)
   158	   → up to 30 candidates
   159	   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
   160	     (payload.upstream='reed')
   161	   → hh_decision_output("reed_query", "brief:<id>", "results:<N>")
   162	
   163	6. CV-Library query
   164	   → cvlibrary.search_candidates(query, location, salary_band)
   165	   → up to 30 candidates
   166	   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
   167	     (payload.upstream='cv-library')
   168	   → hh_decision_output("cvlibrary_query", "brief:<id>", "results:<N>")
   169	
   170	7. Aggregate + dedupe
   171	   → merge all sources into single candidate set
   172	   → dedupe across sources by (name + email) OR (name + phone) OR
   173	     (LinkedIn URL) — same fuzzy matcher as Janitor (confidence ≥0.85)
   174	   → annotate each row with source provenance (e.g., "from Bullhorn + LinkedIn
   175	     match" if found in both)
   176	   → hh_decision_output("aggregate_dedupe", "brief:<id>",
   177	     "pre_dedupe:<N>; post_dedupe:<N>")
   178	
   179	8. "Do not contact" filter (pre-outbound sourcing filter; NOT outbound refusal)
   180	   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
   181	     (already a registered config key per autosend-policy.yaml red-tier
   182	     `send_to_blocked_recipient`; canonical Postgres-stored structured
   183	     state per ADR-002 vault/Postgres split — NOT vault markdown)
   184	   → remove any candidate matching any DNC identifier from the sourcing list
   185	   → log dropped candidates to exception list in §3 output
   186	   → NOTE: ESC_DNC_FILTER_HIT is catalogue §2.10 reserved for OUTBOUND SEND
   187	     REFUSAL specifically. Sourcing Scout filters DNC matches AT SOURCING
   188	     TIME (pre-outbound); no outbound send attempt occurs. v0.3 disposition:
   189	     log DNC drops in exception list only; no ESC fire. W4-polish backlog:
   190	     add ESC_SOURCING_DNC_FILTER for the pre-outbound case.
   191	   → hh_decision_output("dnc_filter", "brief:<id>",
   192	     "dropped:<N>; kept:<N>")
   193	
   194	9. LLM ranking + rationale generation (per candidate)
   195	   → for top 15 by source-aggregated confidence: generate per-candidate
   196	     rationale ≥50 words
   197	   → prompt = (brief context + candidate profile + voice corpus + tone rules)
   198	   → voice classifier scores rationale (≥0.75)
   199	   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
   200	     from final list
   201	   → hh_decision_output("candidate_proposed", "candidate:<bullhorn_id|external_ref>",
   202	     "source:<bullhorn|linkedin|reed|cvlibrary>; confidence:<N>; voice_score:<N>; included:<bool>") — emitted PER CANDIDATE per §3 contract (one row per candidate proposed; dropped candidates also get a row with included=false + drop_reason)
   203	
   204	10. Output assembly + Gate A validation
   205	    → ensure 5-15 candidates remaining after Step 9
   206	    → ensure each has working contact method (email validated via simple
   207	      regex + domain MX check; phone validated via E.164 format)
   208	    → ensure each rationale ≥50 words
   209	    → if any condition fails: ESC_AGENT_OUTPUT_SHAPE (output-shape violation
   210	      per catalogue line 184 — distinct from ESC_SCHEMA_VIOLATION which is
   211	      reserved for vertical-schema field-constraint violations at write time);
   212	      partial draft to /tmp; abort
   213	    → write Markdown report to vault path per §3
   214	    → hh_decision_output("scout_report", report_path, "N candidates from M sources")
   215	
   216	11. Session close + notification
   217	    → operator notification per invocation source (Brain UI: in-app
   218	      notification; Telegram: reply with report path; webhook: bus event back)
   219	    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
   220	      "N=<N> sources_used=<M>")
   221	    → exit code 0
   222	```
   223	
   224	---
   225	
   226	## §5 — Gates
   227	
   228	### Gate A — validate.sh (hard-fail before action)
   229	
   230	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
   231	
   232	- **"5–15 candidates returned per brief"** (count within range)
   233	- **"each has a working contact method"** (email format + MX check OR E.164 phone OR LinkedIn URL OR Bullhorn bullhorn_id-with-contact)
   234	- **"each has rationale ≥ 50 words"**
   235	- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
   236	- All rationales pass voice classifier ≥0.75
   237	- No PII outside firm boundary in rationale text
   238	- No source contributed 0 candidates (suggests source auth failure undetected by Step 2)
   239	
   240	Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation per catalogue line 184); draft to `/tmp`; operator review.
   241	
   242	**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   243	
   244	### Gate B — Outcome threshold (success metric, not block)
   245	
   246	Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
   247	
   248	Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.
   249	
   250	Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
   251	
   252	Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
   253	
   254	---
   255	
   256	## §6 — Escalation codes
   257	
   258	Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
   259	
   260	| Code | Trigger | Severity | Routing |

exec
/bin/zsh -lc 'find agents/recruitment/sourcing-scout -maxdepth 2 -type f -print | sort' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/sourcing-scout/README.md
agents/recruitment/sourcing-scout/agent.md

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '330,355p'; nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '388,402p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   330	
   331	  cross_tenant_data_send:
   332	    tier: red
   333	    agent: all
   334	    block_reason: cross_tenant_violation
   335	    reason: "Sending tenant-A data to tenant-B recipient; RLS-enforced + red-listed for defence-in-depth"
   336	    irreversible: true
   337	
   338	  unauthorised_adapter_send:
   339	    tier: red
   340	    agent: all
   341	    block_reason: unauthorized_adapter
   342	    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
   343	    irreversible: true
   344	
   345	  send_to_blocked_recipient:
   346	    tier: red
   347	    agent: all
   348	    block_reason: blocked_recipient
   349	    reason: "Recipient in tenant's blocked_recipients override list"
   350	    irreversible: true
   351	
   352	# ───────────────────────────────────────────────────────────
   353	# Defaults applied when override fields are absent in tenant_adapters
   354	# ───────────────────────────────────────────────────────────
   355	
   388	-- Schema before code).
   389	
   390	CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
   391	RETURNS TRIGGER AS $$
   392	DECLARE
   393	  c JSONB := NEW.config;
   394	  k TEXT;
   395	  allowed_keys TEXT[] := ARRAY[
   396	    -- v0.1 + v0.2 keys (forwarded; do not remove)
   397	    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
   398	    'janitor_last_run',
   399	    'pii_retention_days',  -- v0.2 PII purge runbook key
   400	    -- autosend-safety-policy.md keys
   401	    'approval_routing', 'approval_timeouts', 'sampling_rates',
   402	    -- v0.3 additions

codex
I’ve got enough to decide. The decisive failures are not stylistic: one undefined schema field is used as a proposed query key, and several escalation-code claims drift from the catalogue they cite.
codex
REJECTED

1. Undefined schema field in the Bullhorn passive-match open question. Line 344 says Sourcing Scout queries `last_activity_at < now() - 90 days`, but the cited schema field is `candidate.date_last_modified_at` at `vertical-schema.yaml` lines 100-103, and §4 Step 3 correctly uses `date_last_modified_at` at lines 136-143. This violates schema-before-code by introducing an unregistered field. Fix line 344 to use `date_last_modified_at`, or add/register `last_activity_at` in the schema supplement before referencing it.

2. Auth escalation semantics are stronger than the cited catalogue supports. Lines 125-130 claim any source auth failure makes the run halt until reauth, citing catalogue §2.3/§2.7, but `ESC_REED_AUTH`, `ESC_CVLIBRARY_AUTH`, and `ESC_LINKEDIN_AUTH` define blocking/degraded modes with cached-search/profile fallback in `escalation-codes.md` lines 240-262, not a mandatory full-run halt. Fix by aligning Sourcing Scout with the catalogue degraded-mode semantics, or explicitly flag a catalogue change for full-run halt behavior.

3. `ESC_GATE_B_MISS` routing is mis-cited. Line 271 routes it to “founder + operator” and line 250 repeats that behavior, but the catalogue defines routing as `operator_chat_id` only in `escalation-codes.md` lines 377-382. Fix the routing to `operator_chat_id`, or update the escalation catalogue before claiming founder routing.
tokens used
59,912
REJECTED

1. Undefined schema field in the Bullhorn passive-match open question. Line 344 says Sourcing Scout queries `last_activity_at < now() - 90 days`, but the cited schema field is `candidate.date_last_modified_at` at `vertical-schema.yaml` lines 100-103, and §4 Step 3 correctly uses `date_last_modified_at` at lines 136-143. This violates schema-before-code by introducing an unregistered field. Fix line 344 to use `date_last_modified_at`, or add/register `last_activity_at` in the schema supplement before referencing it.

2. Auth escalation semantics are stronger than the cited catalogue supports. Lines 125-130 claim any source auth failure makes the run halt until reauth, citing catalogue §2.3/§2.7, but `ESC_REED_AUTH`, `ESC_CVLIBRARY_AUTH`, and `ESC_LINKEDIN_AUTH` define blocking/degraded modes with cached-search/profile fallback in `escalation-codes.md` lines 240-262, not a mandatory full-run halt. Fix by aligning Sourcing Scout with the catalogue degraded-mode semantics, or explicitly flag a catalogue change for full-run halt behavior.

3. `ESC_GATE_B_MISS` routing is mis-cited. Line 271 routes it to “founder + operator” and line 250 repeats that behavior, but the catalogue defines routing as `operator_chat_id` only in `escalation-codes.md` lines 377-382. Fix the routing to `operator_chat_id`, or update the escalation catalogue before claiming founder routing.
