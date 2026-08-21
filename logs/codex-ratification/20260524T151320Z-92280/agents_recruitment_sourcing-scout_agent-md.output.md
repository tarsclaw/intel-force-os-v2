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
session id: 019e5a8c-3d21-73e0-8703-cf7af916696f
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

**Status:** Proposed (2026-05-24 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice + tenant_adapters.config v0.4-supplement adding blocked_recipients + auto_source_on_brief_create).
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
   → per-source auth failure fires the catalogue-specified ESC code with
     its catalogue-specified degraded-mode behavior:
     - ESC_BULLHORN_AUTH (catalogue §2.3): blocking → Sourcing Scout
       enters degraded mode per catalogue ("drafts-only, no auto-send" —
       Sourcing-Scout-specific interpretation: skip Bullhorn source +
       continue with other 3 sources, since Sourcing Scout has no
       auto-send path of its own; the "drafts-only" framing maps to
       "report-only with Bullhorn data omitted from the sourcing set")
     - ESC_LINKEDIN_AUTH (catalogue §2.7): blocking → degraded mode
       (Sourcing Scout: cached LinkedIn search only; live profile fetches
       skipped)
     - ESC_REED_AUTH (catalogue §2.7): blocking → degraded mode (cached
       Reed search results only)
     - ESC_CVLIBRARY_AUTH (catalogue §2.7): blocking → degraded mode
       (cached CV-Library search only)
   → if MULTIPLE sources are in degraded mode AND the remaining live
     sources cannot produce ≥5 candidates: ESC_AGENT_OUTPUT_SHAPE +
     return partial report with exception note (Gate A floor violated)
   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
     "sources_ok:<N>/4; degraded:<list>")

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
     (concept referenced by autosend-policy.yaml red-tier
     `send_to_blocked_recipient` action_type + ESC_DNC_FILTER_HIT catalogue
     §2.10; the actual config-key SCHEMA registration is v0.4-supplement-
     pending — v0.3 supplement §4 only registers cash_conductor_last_run +
     concierge_last_poll + concierge_send_window. Production-readiness
     gate: v0.4 supplement must land before Sourcing Scout's DNC filter
     path runs against real pilot data. Postgres-backed per ADR-002
     vault/Postgres split — NOT vault markdown.)
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

Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing) — operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).

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
| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |

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
| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `date_last_modified_at < now() - 90 days` (per schema line 100) to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side modification-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |

### Gotchas (carried forward from ULTRAPLAN A5 line 555)

1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-agent-bundle.md` skill (built 2026-05-24, commit `825ebd4`): this agent.md ratifies when Codex review-agent-bundle returns RATIFIED verdict.

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
I’ll verify the cited source files and catalogue entries directly, then return only the required ratification verdict.
exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Sourcing Scout — request-response passive sourcing
     2	
     3	**Status:** Proposed (2026-05-24 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice + tenant_adapters.config v0.4-supplement adding blocked_recipients + auto_source_on_brief_create).
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
   125	   → per-source auth failure fires the catalogue-specified ESC code with
   126	     its catalogue-specified degraded-mode behavior:
   127	     - ESC_BULLHORN_AUTH (catalogue §2.3): blocking → Sourcing Scout
   128	       enters degraded mode per catalogue ("drafts-only, no auto-send" —
   129	       Sourcing-Scout-specific interpretation: skip Bullhorn source +
   130	       continue with other 3 sources, since Sourcing Scout has no
   131	       auto-send path of its own; the "drafts-only" framing maps to
   132	       "report-only with Bullhorn data omitted from the sourcing set")
   133	     - ESC_LINKEDIN_AUTH (catalogue §2.7): blocking → degraded mode
   134	       (Sourcing Scout: cached LinkedIn search only; live profile fetches
   135	       skipped)
   136	     - ESC_REED_AUTH (catalogue §2.7): blocking → degraded mode (cached
   137	       Reed search results only)
   138	     - ESC_CVLIBRARY_AUTH (catalogue §2.7): blocking → degraded mode
   139	       (cached CV-Library search only)
   140	   → if MULTIPLE sources are in degraded mode AND the remaining live
   141	     sources cannot produce ≥5 candidates: ESC_AGENT_OUTPUT_SHAPE +
   142	     return partial report with exception note (Gate A floor violated)
   143	   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
   144	     "sources_ok:<N>/4; degraded:<list>")
   145	
   146	3. Bullhorn passive-match query
   147	   → bullhorn.search_candidates(filter=brief_key_dimensions,
   148	     status='active', date_last_modified_at < now() - interval '90 days')
   149	     — "passive" is a derived state (active candidate not recently
   150	     modified); NOT a vertical-schema enum value. The schema defines
   151	     candidate.status as [active, archived, do_not_contact, placed,
   152	     contractor_promoted] (line 84-88) and candidate.date_last_modified_at
   153	     as the recency field (line 100). Passive-match queries filter on
   154	     modification recency within the active set.
   155	   → up to 30 candidates fetched (will rank+filter later)
   156	   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
   157	   → hh_decision_output("bullhorn_query", "brief:<id>", "results:<N>")
   158	
   159	4. LinkedIn search (via Proxycurl)
   160	   → proxycurl.search_people(query=brief_key_dimensions, location=brief_location,
   161	     industry=brief_sector)
   162	   → up to 30 profiles
   163	   → cache 1h per (query, location, sector) tuple
   164	   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
   165	   → hh_decision_output("linkedin_query", "brief:<id>", "results:<N>")
   166	
   167	5. Reed query
   168	   → reed.search_candidates(query=brief_dimensions, location, salary_band)
   169	   → up to 30 candidates
   170	   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
   171	     (payload.upstream='reed')
   172	   → hh_decision_output("reed_query", "brief:<id>", "results:<N>")
   173	
   174	6. CV-Library query
   175	   → cvlibrary.search_candidates(query, location, salary_band)
   176	   → up to 30 candidates
   177	   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
   178	     (payload.upstream='cv-library')
   179	   → hh_decision_output("cvlibrary_query", "brief:<id>", "results:<N>")
   180	
   181	7. Aggregate + dedupe
   182	   → merge all sources into single candidate set
   183	   → dedupe across sources by (name + email) OR (name + phone) OR
   184	     (LinkedIn URL) — same fuzzy matcher as Janitor (confidence ≥0.85)
   185	   → annotate each row with source provenance (e.g., "from Bullhorn + LinkedIn
   186	     match" if found in both)
   187	   → hh_decision_output("aggregate_dedupe", "brief:<id>",
   188	     "pre_dedupe:<N>; post_dedupe:<N>")
   189	
   190	8. "Do not contact" filter (pre-outbound sourcing filter; NOT outbound refusal)
   191	   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
   192	     (concept referenced by autosend-policy.yaml red-tier
   193	     `send_to_blocked_recipient` action_type + ESC_DNC_FILTER_HIT catalogue
   194	     §2.10; the actual config-key SCHEMA registration is v0.4-supplement-
   195	     pending — v0.3 supplement §4 only registers cash_conductor_last_run +
   196	     concierge_last_poll + concierge_send_window. Production-readiness
   197	     gate: v0.4 supplement must land before Sourcing Scout's DNC filter
   198	     path runs against real pilot data. Postgres-backed per ADR-002
   199	     vault/Postgres split — NOT vault markdown.)
   200	   → remove any candidate matching any DNC identifier from the sourcing list
   201	   → log dropped candidates to exception list in §3 output
   202	   → NOTE: ESC_DNC_FILTER_HIT is catalogue §2.10 reserved for OUTBOUND SEND
   203	     REFUSAL specifically. Sourcing Scout filters DNC matches AT SOURCING
   204	     TIME (pre-outbound); no outbound send attempt occurs. v0.3 disposition:
   205	     log DNC drops in exception list only; no ESC fire. W4-polish backlog:
   206	     add ESC_SOURCING_DNC_FILTER for the pre-outbound case.
   207	   → hh_decision_output("dnc_filter", "brief:<id>",
   208	     "dropped:<N>; kept:<N>")
   209	
   210	9. LLM ranking + rationale generation (per candidate)
   211	   → for top 15 by source-aggregated confidence: generate per-candidate
   212	     rationale ≥50 words
   213	   → prompt = (brief context + candidate profile + voice corpus + tone rules)
   214	   → voice classifier scores rationale (≥0.75)
   215	   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
   216	     from final list
   217	   → hh_decision_output("candidate_proposed", "candidate:<bullhorn_id|external_ref>",
   218	     "source:<bullhorn|linkedin|reed|cvlibrary>; confidence:<N>; voice_score:<N>; included:<bool>") — emitted PER CANDIDATE per §3 contract (one row per candidate proposed; dropped candidates also get a row with included=false + drop_reason)
   219	
   220	10. Output assembly + Gate A validation
   221	    → ensure 5-15 candidates remaining after Step 9
   222	    → ensure each has working contact method (email validated via simple
   223	      regex + domain MX check; phone validated via E.164 format)
   224	    → ensure each rationale ≥50 words
   225	    → if any condition fails: ESC_AGENT_OUTPUT_SHAPE (output-shape violation
   226	      per catalogue line 184 — distinct from ESC_SCHEMA_VIOLATION which is
   227	      reserved for vertical-schema field-constraint violations at write time);
   228	      partial draft to /tmp; abort
   229	    → write Markdown report to vault path per §3
   230	    → hh_decision_output("scout_report", report_path, "N candidates from M sources")
   231	
   232	11. Session close + notification
   233	    → operator notification per invocation source (Brain UI: in-app
   234	      notification; Telegram: reply with report path; webhook: bus event back)
   235	    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
   236	      "N=<N> sources_used=<M>")
   237	    → exit code 0
   238	```
   239	
   240	---
   241	
   242	## §5 — Gates
   243	
   244	### Gate A — validate.sh (hard-fail before action)
   245	
   246	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
   247	
   248	- **"5–15 candidates returned per brief"** (count within range)
   249	- **"each has a working contact method"** (email format + MX check OR E.164 phone OR LinkedIn URL OR Bullhorn bullhorn_id-with-contact)
   250	- **"each has rationale ≥ 50 words"**
   251	- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
   252	- All rationales pass voice classifier ≥0.75
   253	- No PII outside firm boundary in rationale text
   254	- No source contributed 0 candidates (suggests source auth failure undetected by Step 2)
   255	
   256	Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation per catalogue line 184); draft to `/tmp`; operator review.
   257	
   258	**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   259	
   260	### Gate B — Outcome threshold (success metric, not block)

exec
/bin/zsh -lc "rg --files docs agents | rg 'vertical-schema|autosend-safety-policy|escalation-codes|voice-loader|ULTRAPLAN|master|kill-criterion|operational-hygiene|ADR-002'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/escalation-codes.md
agents/_shared/voice-loader.sh
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
agents/_shared/tests/test-voice-loader.sh
docs/specs/ULTRAPLAN.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/autosend-safety-policy.md
docs/decisions/v1.0-kill-criterion.md
docs/runbooks/operational-hygiene-protocol.md

exec
/bin/zsh -lc 'rg -n "Sourcing Scout|A5|W9|blocked_recipients|auto_source|ESC_LINKEDIN_AUTH|ESC_REED_AUTH|ESC_CVLIBRARY_AUTH|ESC_AGENT_OUTPUT_SHAPE|ESC_GATE_B_MISS|ESC_BRIEF_AMBIGUITY|hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|candidate:|date_last_modified_at|do_not_contact|send_to_blocked_recipient" docs agents -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
agents/_shared/autosend-policy.yaml:110:    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
agents/_shared/autosend-policy.yaml:116:    reason: "Internal audit row written by validate.sh when Gate A enforcement fails. Carries the specific ESC code (e.g. ESC_AGENT_OUTPUT_SHAPE | ESC_PII_LEAKAGE_RISK) in the payload; the action itself is just the audit-row write, not an external send. Each agent's validate.sh emits this row before exit 1."
agents/_shared/autosend-policy.yaml:128:    reason: "Internal audit row written by cycle.sh when @ifos/diagnostic-generator produces empty stdout. Carries ESC_AGENT_OUTPUT_SHAPE payload."
agents/_shared/autosend-policy.yaml:229:  gmail_outlook_send_to_candidate:
agents/_shared/autosend-policy.yaml:345:  send_to_blocked_recipient:
agents/_shared/autosend-policy.yaml:349:    reason: "Recipient in tenant's blocked_recipients override list"
agents/_shared/tests/test-hook-helpers.sh:132:  hh_decision_action "diagnostic_report_render" "candidate:test" "abc123" "test preview"
agents/_shared/tests/test-hook-helpers.sh:159:  HH_AWAIT_TEST_MODE=approve hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash1" "preview"
agents/_shared/tests/test-hook-helpers.sh:173:  HH_AWAIT_TEST_MODE=reject hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash2" "preview"
agents/_shared/tests/test-hook-helpers.sh:263:  autosend_spot_check_enqueue "bullhorn_candidate_dedupe" "candidate:foo" "abc123def456" "merge preview" "${CTX_TENANT_SLUG}"
agents/_shared/tests/test-hook-helpers.sh:273:  hh_decision_action "bullhorn_candidate_dedupe" "candidate:foo" "hash9" "preview"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:53:  candidate:
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
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:290:#   - Sourcing Scout candidate: R → R+W (writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:293:#   - Sourcing Scout opportunity: none → R (reads opportunity context for ICP)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:294:#   - Concierge candidate: R → R+W (writes lifecycle-state-derived fields +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:342:  #   Example: Scribe.candidate: R+W at entity level; per-field
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:344:  #   without reading it). Another example: Diagnostic.candidate: R at entity
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:363:    candidate: R           # reads for outreach context (§11 decision-maker map)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:373:    candidate: R+W         # dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:389:    candidate: R+W         # call-summary field extraction (Bullhorn endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:404:    candidate: none        # no Bullhorn dependency
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:416:    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:417:    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:420:    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:434:    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14 (Bullhorn endpoint A6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:458:    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:464:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:477:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:503:      - Sourcing Scout (R) # v0.3 NEW — reads opportunity for ICP scoring
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:508:      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:534:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:535:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:540:      - Sourcing Scout (R+W) # v0.3 UPGRADED — writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:543:      v0.3 upgrades Sourcing Scout (writes proposed-candidate rows from
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:548:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:552:      - Sourcing Scout (R+W) # v0.3 UPGRADED — same pattern as candidate
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:562:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:566:      Conductor for chase drafts; Sourcing Scout for per-candidate
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:572:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:574:      Janitor agent.md §7 calls hh_load_tone_rules filtered by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:577:      Diagnostic + Sourcing Scout also read tone_rules for their
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:589:      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
agents/_shared/escalation-codes.md:141:#### `ESC_BRIEF_AMBIGUITY`
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:158:- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
agents/_shared/escalation-codes.md:184:#### `ESC_AGENT_OUTPUT_SHAPE`
agents/_shared/escalation-codes.md:240:#### `ESC_REED_AUTH`
agents/_shared/escalation-codes.md:248:#### `ESC_CVLIBRARY_AUTH`
agents/_shared/escalation-codes.md:250:- **Trigger:** CV-Library API OAuth failure (same pattern as ESC_REED_AUTH)
agents/_shared/escalation-codes.md:256:#### `ESC_LINKEDIN_AUTH`
agents/_shared/escalation-codes.md:257:- **Severity:** **blocking** — Sourcing Scout enters degraded mode (no profile fetches; cached only)
agents/_shared/escalation-codes.md:262:- **Recovery:** founder reauthenticates LinkedIn via Sourcing Scout admin flow
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:377:#### `ESC_GATE_B_MISS`
agents/_shared/escalation-codes.md:402:- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
agents/_shared/escalation-codes.md:466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
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
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
agents/recruitment/cash-conductor/agent.md:232:       `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint failure)
agents/recruitment/cash-conductor/agent.md:306:Gate A failures fire either `ESC_AGENT_OUTPUT_SHAPE` (invoice/amount/paid-precondition miss; output-shape constraint) OR `ESC_ADDRESSEE_MISMATCH` (client_contact_email mismatch; blocking per catalogue §2.10 — explicit Cash Conductor invoice/chase addressee case). Draft stays in `/tmp` (auto-purged 24h); operator notified per the specific ESC route.
agents/recruitment/cash-conductor/agent.md:318:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:337:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss on invoice_number / amount_due / paid-invoice-precondition (NOT addressee mismatch — that uses ESC_ADDRESSEE_MISMATCH) | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:339:| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
agents/recruitment/cash-conductor/agent.md:346:- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
agents/recruitment/cash-conductor/agent.md:356:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:360:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/cash-conductor/agent.md:361:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
docs/build-brief/00-MASTER-BRIEF.md:119:| 7 | Multi-agent orchestrator | `orchestrator` template + file-bus handoff contract | Brief Decoder → Sourcing Scout → Concierge pipeline lives here |
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:584:- `ESC_BRIEF_AMBIGUITY` — Brief Decoder cannot confidently shortlist
docs/build-brief/00-MASTER-BRIEF.md:599:| 5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
agents/recruitment/scribe/agent.md:157:   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
agents/recruitment/scribe/agent.md:224:Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/scribe/agent.md:238:Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).
agents/recruitment/scribe/agent.md:255:| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:272:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:276:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:277:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:55:      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:88:        enum: [active, archived, do_not_contact, placed, contractor_promoted]
docs/verticals/recruitment/vertical-schema.yaml:100:      date_last_modified_at:
docs/verticals/recruitment/vertical-schema.yaml:141:        source: IFOS-derived (set by Sourcing Scout at first-touch)
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:331:      do_not_contact:
docs/verticals/recruitment/vertical-schema.yaml:349:      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:420:      date_last_modified_at:
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:526:      date_last_modified_at:
docs/verticals/recruitment/vertical-schema.yaml:637:    v1_0_exercise: Sourcing Scout captures at first-touch when relevant; not heavily exercised in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:647:  opportunity_about_candidate:
docs/verticals/recruitment/vertical-schema.yaml:672:    candidate: none
docs/verticals/recruitment/vertical-schema.yaml:683:    candidate: R+W   # full sweep + normalisation + dedup proposals
docs/verticals/recruitment/vertical-schema.yaml:693:    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
docs/verticals/recruitment/vertical-schema.yaml:703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
docs/verticals/recruitment/vertical-schema.yaml:713:    candidate: R     # passive matching
docs/verticals/recruitment/vertical-schema.yaml:723:    candidate: R+W   # lifecycle state on every event
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:841:    revisit_trigger: Skill-matching accuracy from Sourcing Scout's first 4 tenant-weeks of operation; if free-text matching produces <60% precision, canonical skill taxonomy lands as v1.1.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/_supplementary/PRD-autonomous-agent.md:766:    candidate: c,
agents/recruitment/sourcing-scout/README.md:1:# Sourcing Scout — directory README
agents/recruitment/sourcing-scout/README.md:3:**Status:** Proposed (Day-19 pre-W9-build scaffold).
agents/recruitment/sourcing-scout/README.md:14:Full bundle at W9 build (~2 weeks per ULTRAPLAN A5 line 554):
agents/recruitment/sourcing-scout/README.md:27:Per ULTRAPLAN A5 line 555 gotcha: source-abstraction layer designed for Night Sourcer reuse. Defer ADR-006 to W9 build start documenting the layer's interface.
agents/recruitment/sourcing-scout/README.md:33:*End of Sourcing Scout README.*
agents/recruitment/sourcing-scout/agent.md:1:# Sourcing Scout — request-response passive sourcing
agents/recruitment/sourcing-scout/agent.md:3:**Status:** Proposed (2026-05-24 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice + tenant_adapters.config v0.4-supplement adding blocked_recipients + auto_source_on_brief_create).
agents/recruitment/sourcing-scout/agent.md:6:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:7:**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
agents/recruitment/sourcing-scout/agent.md:8:**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.
agents/recruitment/sourcing-scout/agent.md:16:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:24:Brain UI v1.0 "Source candidates" button on any brief detail page → POST internal API → Sourcing Scout webhook.
agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
agents/recruitment/sourcing-scout/agent.md:57:# Sourcing Scout — <Brief title>
agents/recruitment/sourcing-scout/agent.md:109:     + DNC list from `tenant_adapters.config.blocked_recipients` (Postgres-
agents/recruitment/sourcing-scout/agent.md:118:   → ESC_BRIEF_AMBIGUITY if extraction yields <3 key dimensions (per
agents/recruitment/sourcing-scout/agent.md:127:     - ESC_BULLHORN_AUTH (catalogue §2.3): blocking → Sourcing Scout
agents/recruitment/sourcing-scout/agent.md:130:       continue with other 3 sources, since Sourcing Scout has no
agents/recruitment/sourcing-scout/agent.md:133:     - ESC_LINKEDIN_AUTH (catalogue §2.7): blocking → degraded mode
agents/recruitment/sourcing-scout/agent.md:134:       (Sourcing Scout: cached LinkedIn search only; live profile fetches
agents/recruitment/sourcing-scout/agent.md:136:     - ESC_REED_AUTH (catalogue §2.7): blocking → degraded mode (cached
agents/recruitment/sourcing-scout/agent.md:138:     - ESC_CVLIBRARY_AUTH (catalogue §2.7): blocking → degraded mode
agents/recruitment/sourcing-scout/agent.md:141:     sources cannot produce ≥5 candidates: ESC_AGENT_OUTPUT_SHAPE +
agents/recruitment/sourcing-scout/agent.md:148:     status='active', date_last_modified_at < now() - interval '90 days')
agents/recruitment/sourcing-scout/agent.md:151:     candidate.status as [active, archived, do_not_contact, placed,
agents/recruitment/sourcing-scout/agent.md:152:     contractor_promoted] (line 84-88) and candidate.date_last_modified_at
agents/recruitment/sourcing-scout/agent.md:170:   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:177:   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:191:   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
agents/recruitment/sourcing-scout/agent.md:193:     `send_to_blocked_recipient` action_type + ESC_DNC_FILTER_HIT catalogue
agents/recruitment/sourcing-scout/agent.md:197:     gate: v0.4 supplement must land before Sourcing Scout's DNC filter
agents/recruitment/sourcing-scout/agent.md:203:     REFUSAL specifically. Sourcing Scout filters DNC matches AT SOURCING
agents/recruitment/sourcing-scout/agent.md:217:   → hh_decision_output("candidate_proposed", "candidate:<bullhorn_id|external_ref>",
agents/recruitment/sourcing-scout/agent.md:225:    → if any condition fails: ESC_AGENT_OUTPUT_SHAPE (output-shape violation
agents/recruitment/sourcing-scout/agent.md:246:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
agents/recruitment/sourcing-scout/agent.md:251:- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
agents/recruitment/sourcing-scout/agent.md:256:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation per catalogue line 184); draft to `/tmp`; operator review.
agents/recruitment/sourcing-scout/agent.md:258:**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/sourcing-scout/agent.md:262:Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
agents/recruitment/sourcing-scout/agent.md:264:Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.
agents/recruitment/sourcing-scout/agent.md:266:Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing) — operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
agents/recruitment/sourcing-scout/agent.md:268:Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
agents/recruitment/sourcing-scout/agent.md:274:Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/sourcing-scout/agent.md:279:| `ESC_LINKEDIN_AUTH` | LinkedIn / Proxycurl session/OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:280:| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:281:| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:283:| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:286:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:287:| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
agents/recruitment/sourcing-scout/agent.md:289:Sourcing Scout does NOT use:
agents/recruitment/sourcing-scout/agent.md:293:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
agents/recruitment/sourcing-scout/agent.md:294:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/sourcing-scout/agent.md:295:- `ESC_DNC_FILTER_HIT` — per catalogue §2.10 reserved for outbound send refusal specifically; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish backlog: add ESC_SOURCING_DNC_FILTER.
agents/recruitment/sourcing-scout/agent.md:303:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:308:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:309:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
agents/recruitment/sourcing-scout/agent.md:315:## §8 — Build dependencies (W9 prerequisites)
agents/recruitment/sourcing-scout/agent.md:317:Sourcing Scout build cannot start until ALL of the following are confirmed:
agents/recruitment/sourcing-scout/agent.md:330:| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:331:| Reed MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:332:| CV-Library MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:333:| Source-abstraction layer (Night Sourcer reuse) | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:335:| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
agents/recruitment/sourcing-scout/agent.md:337:| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:338:| `context.sh` hydration | Build at W9 start (~0.5 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:339:| `cycle.sh` orchestration (11-step) | Build at W9 start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:340:| 3 fixtures with golden outputs | Build at W9 start (~1 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:342:**Until ALL ⏸ items resolve to ✅, W9 build slice does not start.**
agents/recruitment/sourcing-scout/agent.md:348:**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:356:| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
agents/recruitment/sourcing-scout/agent.md:357:| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
agents/recruitment/sourcing-scout/agent.md:359:| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
agents/recruitment/sourcing-scout/agent.md:360:| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `date_last_modified_at < now() - 90 days` (per schema line 100) to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side modification-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |
agents/recruitment/sourcing-scout/agent.md:362:### Gotchas (carried forward from ULTRAPLAN A5 line 555)
agents/recruitment/sourcing-scout/agent.md:365:2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
agents/recruitment/sourcing-scout/agent.md:381:- W9 build slice produces all 5 sibling bundle files + 3 fixtures
agents/recruitment/sourcing-scout/agent.md:388:*End of Sourcing Scout agent.md draft.*
docs/specs/ULTRAPLAN.md:72:- **The file bus.** Inter-agent handoff via shared filesystem directories. No queue, no API, no serialisation tax. Brief Decoder writes a parsed-brief file; Sourcing Scout's `FastChecker` polls it up at the configured cadence (default 1000ms `pollInterval`, configurable per agent); result lands in a sub-directory the Concierge is polling. Four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound.
docs/specs/ULTRAPLAN.md:155:hh_load_tone_rules
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:186:- `ESC_BRIEF_AMBIGUITY` — Brief Decoder found ambiguities that prevent confident shortlisting
docs/specs/ULTRAPLAN.md:543:#### A5. Sourcing Scout (daytime form) — request-response sourcing
docs/specs/ULTRAPLAN.md:593:- **MCP tools required:** Bullhorn (read for prior placements + candidates), shared with Sourcing Scout
docs/specs/ULTRAPLAN.md:594:- **Shared modules required:** Voice loader, decision log writer, the Brief Decoder→Sourcing Scout→Concierge orchestration template
docs/specs/ULTRAPLAN.md:595:- **External APIs:** Same as Sourcing Scout (reuses)
docs/specs/ULTRAPLAN.md:599:- **Gotchas:** Brief format varies hugely between clients. Build the parser as schema-driven, not pattern-matching. The orchestration handoff to Sourcing Scout is the load-bearing CortexOS test.
docs/specs/ULTRAPLAN.md:626:- **Shared modules required:** Voice loader, decision log writer, the source-abstraction layer from Sourcing Scout
docs/specs/ULTRAPLAN.md:627:- **External APIs:** Same as Sourcing Scout + GitHub
docs/specs/ULTRAPLAN.md:629:- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared with Sourcing Scout)
docs/specs/ULTRAPLAN.md:630:- **Build complexity:** **M** (2 weeks) — reuses Sourcing Scout's source layer; the new work is the overnight scheduling + rate-limit budget allocation
docs/specs/ULTRAPLAN.md:689:| Sourcing Scout | ✓ | ✓ | | | ✓ | | ✓ | | | ✓ | |
docs/specs/ULTRAPLAN.md:771:### Weeks 9–10 — Sourcing Scout + Concierge start
docs/specs/ULTRAPLAN.md:773:- Week 9: Sourcing Scout (daytime); LinkedIn + Reed + CV-Library integration
docs/specs/ULTRAPLAN.md:820:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
docs/specs/ULTRAPLAN.md:822:| 6 | LinkedIn rate limits via Proxycurl are tighter than expected | Medium | Medium | Sourcing Scout cost >£100/run | Negotiate Proxycurl enterprise plan; defer Night Sourcer to v1.2 if needed |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:122:| Sourcing Scout | ~5-7 (count regex 50) | `logs/codex-ratification/20260524T1024...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:216:3. `ESC_GATE_B_MISS` definition in §6 still says "Composite Gate-B score <12.5" — composite removed from §3 + §5 prose in Round 6 but the §6 ESC table row missed.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:276:| Sourcing Scout | 4 | `20260524T113139Z-84869` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:284:- Sourcing Scout ULTRAPLAN A5 line refs: Gate A 553→552, Gate B 554→553 (4 citation sites)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:318:  - Sourcing Scout per-candidate decision rows (claimed in §3 but not in §4 cycle)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:333:- Sourcing Scout: pre-build-scaffold; Round-8-reviewed; minimal residual (catalogue-widening + per-candidate decision rows)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:363:- `validate.sh` emits specific §6 ESC codes (ESC_PII_LEAKAGE_RISK or ESC_AGENT_OUTPUT_SHAPE) not generic ESC_SCHEMA_VIOLATION
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:374:| Sourcing Scout | 4 | 5 | +1 (Q7 enum claim missed by my Round-8 fix; Bullhorn webhook conflict newly surfaced) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:389:**Sourcing Scout R9:**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:391:2. ESC auth severity downgrade vs catalogue — Codex–founder disagreement (Sourcing Scout intentionally allows single-source auth failure as warn-only when 2+ sources remain; catalogue defines blocking. Real semantic divergence; needs catalogue widening OR Sourcing Scout agent.md realignment)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:419:4. **Catalogue v2 widening for ESC_DNC_FILTER_HIT + Sourcing Scout auth severity** — Cat-γ continuations
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:430:| Sourcing Scout | Pre-Build-Round-9-Reviewed | 5 (Cat-α Q7 + bullhorn-path conflict + Cat-γ DNC + Cat-ε per-candidate row + auth severity disagreement) | Mechanical Q7 fix + Bullhorn-path realignment + ESC widening 2 |
docs/specs/PRODUCT-SPEC.md:101:#### R5. Sourcing Scout (daytime form) — request-response sourcing during the day
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:400:| 3 | Inter-agent file bus — agents hand work to each other via shared directories | Brief Decoder → Sourcing Scout → Concierge handoff; Triage → specialist-agent routing |
docs/specs/PRODUCT-SPEC.md:476:- Sourcing Scout (daytime form)
docs/specs/PRODUCT-SPEC.md:486:3. **Night Sourcer** (2 weeks) — overnight extension of Sourcing Scout
docs/specs/PRODUCT-SPEC.md:526:5. **Sourcing Scout (daytime)** — "Shortlist in 15 minutes instead of by end of week."
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:43:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:121:- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/operations/goal-week-3-polish-and-scaffold.md:53:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:63:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:208:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:381:### DAY 19 — Sourcing Scout + Concierge agent.md scaffolds (Steps 11-12)
docs/operations/goal-week-3-polish-and-scaffold.md:386:- ULTRAPLAN §8.1 A5 lines 547-558 (Sourcing Scout spec)
docs/operations/goal-week-3-polish-and-scaffold.md:387:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:388:- `bullhorn-integration-path.md` §4.1 (Sourcing Scout's Bullhorn read surface)
docs/operations/goal-week-3-polish-and-scaffold.md:389:- `vertical-schema.yaml` §3 agent_access_matrix Sourcing Scout row
docs/operations/goal-week-3-polish-and-scaffold.md:393:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:400:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_LINKEDIN_AUTH, ESC_RATE_LIMIT_HIT, ESC_BRIEF_UNDERSPECIFIED.
docs/operations/goal-week-3-polish-and-scaffold.md:407:Commit: `decision(pre-build): agents/recruitment/sourcing-scout/agent.md — output contract per ULTRAPLAN §8.1 A5`
docs/operations/goal-week-3-polish-and-scaffold.md:499:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:619:  Sourcing Scout (W9):    <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:683:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:79:-- is the indexed surface for hh_load_voice_samples semantic retrieval.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:136:**Action:** PIVOT — likely vector: cheaper Claude model tier (Haiku 4.5 for routine actions, Sonnet for complex), or reduced agent run frequency (e.g., Sourcing Scout runs nightly batch instead of real-time), or per-tenant cost passthrough in pricing.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/specs/_archive-build-handoff.md:381:| 5 | **Sourcing Scout** | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
agents/recruitment/janitor/agent.md:168:   → exit code 0 (or 1 if Gate-B missed for 3 consecutive runs → ESC_GATE_B_MISS)
agents/recruitment/janitor/agent.md:187:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint; per Day-19 catalogue add at `escalation-codes.md` line 184) OR `ESC_DUPLICATE_DETECTED` (merge-confidence reject; existing line 127) per the failed condition. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (line 163) is NOT used by Janitor — that code is reserved for vertical-schema field-constraint violations at write-time.
agents/recruitment/janitor/agent.md:197:Failing either threshold for 3 consecutive runs → fire `ESC_GATE_B_MISS` → flag for operator review (heuristic tuning may be needed; not a kill).
agents/recruitment/janitor/agent.md:212:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (section count or per-section citation missing in day-30 report) | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:214:| `ESC_GATE_B_MISS` | Either independent Gate-B threshold (dedup <15% OR field-completeness <10%) missed for 3 consecutive runs. NOT a composite — see §5 Gate B for the two-threshold rule. | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:222:- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction
agents/recruitment/janitor/agent.md:230:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/janitor/agent.md:234:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
agents/recruitment/janitor/agent.md:235:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:23:| 9 | Sourcing Scout |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:75:- Sourcing Scout (W9) touches Bullhorn read; same gating
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
agents/recruitment/diagnostic/validate.sh:238:  #     length) → ESC_AGENT_OUTPUT_SHAPE (warn)
agents/recruitment/diagnostic/validate.sh:257:    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"
docs/decisions/sequencing-target.md:25:| A5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | "First daytime always-on agent" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:113:| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:146:### 2.5 — A5 Sourcing Scout (daytime)
docs/decisions/sequencing-target.md:154:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Night Sourcer (v1.1) reuses Sourcing Scout's multi-source layer per Ultraplan §8.1 line 555 ("Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it") | Medium criticality (v1.1 downstream) |
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:185:W9:   Sourcing Scout (A5)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:209:W9:   Janitor (A2)
docs/decisions/sequencing-target.md:211:W11:  Sourcing Scout (A5)
docs/decisions/sequencing-target.md:233:W12:  Sourcing Scout (A5)
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:256:| 5. Dependencies on other agents | **Wins** — Janitor's Bullhorn auth → Scribe reuses → Sourcing Scout reuses → Concierge reuses, all in dependency order | Loses — Concierge before Janitor + Scribe breaks the upstream chain | Loses — Concierge before Scribe breaks the upstream chain |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:285:| 5 | W9 | **Sourcing Scout** (A5) | Multi-source aggregation; first LinkedIn rate-limit exercise (Risk #6) |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:310:- **Activation:** v1.0 scope cut from 6 to 4 agents per Ultraplan §10 row #4 — drop Concierge + Sourcing Scout to v1.1; founder solo through end of v1.0.
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:319:- **Cascade:** Sourcing Scout W10 (shifted right from W9), Concierge W11-14 (shifted right from W10-13).
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
agents/recruitment/diagnostic/cycle.sh:163:    '{"escalation_code":"ESC_AGENT_OUTPUT_SHAPE","agent_name":"diagnostic","shape_rule_violated":"non_empty_output","expected_value":"non-empty stdout","actual_value":"empty"}' >/dev/null
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:37:| A5 Sourcing Scout | **Yes — read** (ATS passive-match lookup) | Ultraplan §8.1 A5 line 547-551 |
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:309:| Sourcing Scout passive-match read | Polling (on-demand search) | Per-consultant-request | No subscription needed — read-on-demand model |
docs/decisions/bullhorn-integration-path.md:336:| Sourcing Scout (read-on-demand) | 50-200 during consultant-active windows | Search-heavy; multiple paginated reads per consultant request |
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:739:            &middot; <a href="#">ESC_BRIEF_AMBIGUITY</a> raised to <a href="#">Sarah Whittaker</a>
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
agents/recruitment/diagnostic/agent.md:107:     payload {escalation_code: ESC_AGENT_OUTPUT_SHAPE, ...}; exit 1
agents/recruitment/diagnostic/agent.md:118:     with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE for
agents/recruitment/diagnostic/agent.md:154:- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
agents/recruitment/diagnostic/agent.md:156:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
agents/recruitment/diagnostic/agent.md:177:| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing OR generator produced empty stdout (Step 8 fallback) | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:192:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:196:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
agents/recruitment/diagnostic/agent.md:197:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:84:| Sourcing Scout | `linkedin_profile_cache` | Stores profile snapshot to `/vault/<tenant>/wiki/raw/`; no external send; no rate-limit cost |
docs/decisions/autosend-safety-policy.md:94:| Sourcing Scout | `linkedin_connection_request` | 1-in-5 | Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy |
docs/decisions/autosend-safety-policy.md:110:| Sourcing Scout | `linkedin_inmail_send` | Outbound InMail (paid credit); cost-per-send; customer-facing |
docs/decisions/autosend-safety-policy.md:124:| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |
docs/decisions/autosend-safety-policy.md:144:#   $2 target        (entity reference, e.g., "candidate:john-smith")
docs/decisions/autosend-safety-policy.md:246:  "target": "<entity ref, e.g., 'candidate:john-smith'>",
docs/decisions/autosend-safety-policy.md:273:Target: candidate:sarah-bowen
docs/decisions/autosend-safety-policy.md:437:    "blocked_recipients": [
docs/decisions/autosend-safety-policy.md:463:3. **`blocked_recipients`** is additive only. Recipients can be added; system-default red-list recipients cannot be removed. Pattern matching supported via `*` wildcards.
docs/decisions/autosend-safety-policy.md:539:  (c) breaches of Tenant's configured blocked_recipients list by the
docs/decisions/autosend-safety-policy.md:599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
docs/architecture/architecture-cohesion-review.md:92:| A5 | **The cortextOS daemon `discoverAgents()` filters by directory pattern, not contents.** Means `.tmp.<pid>/` + `.prev.<ts>/` dirs are invisible. | ADR-003 §3.3.4 atomic-write protocol | If daemon scan ever changes to content-based discovery, the atomic-write protocol could expose half-rendered state. Verified against pinned SHA `c21fbfe`. |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
agents/recruitment/concierge/agent.md:6:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:158:     "candidate:<bullhorn_id>", "fields_present:<N>")
agents/recruitment/concierge/agent.md:166:   → hh_decision_output("addressee_resolved", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:181:   → hh_decision_output("escalation_position_set", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:216:    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:231:      "candidate:<bullhorn_id>", payload_hash, payload_preview)
agents/recruitment/concierge/agent.md:240:      "candidate:<bullhorn_id>", "event_type:<type>")
agents/recruitment/concierge/agent.md:246:    → hh_decision_action("concierge_send_complete", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:253:    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
agents/recruitment/concierge/agent.md:275:Gate A failures fire `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` or `ESC_PII_LEAKAGE_RISK` or `ESC_CANDIDATE_DATA_INCOMPLETE` or `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint when voice threshold misses persistently) — all blocking; draft to `/tmp`; operator notified immediately.
agents/recruitment/concierge/agent.md:287:Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
agents/recruitment/concierge/agent.md:310:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:311:| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% for 30 consecutive days | warn | founder + operator |
agents/recruitment/concierge/agent.md:319:- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
agents/recruitment/concierge/agent.md:329:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
agents/recruitment/concierge/agent.md:336:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:337:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
docs/decisions/autosend-approval-bridge-spec.md:159:Target: candidate:s.bowen
docs/decisions/autosend-approval-bridge-spec.md:243:| A5 | Bridge crash + restart: state rebuilds from filesystem scan + Postgres state table | Restart test: kill PM2 process mid-flight, restart, verify pending approvals resume |
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:322:hh_load_tone_rules
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/cortexos-primitive-status.md:182:1. **No `chokidar` watcher in the bus.** The bus is poll-based, not push-based. `grep -rn chokidar src/` returns zero hits; `chokidar@^5.0.0` in `package.json:47` is used only by `dashboard/src/lib/watcher.ts:5` for the dashboard UI's file change feed, not for inter-agent message delivery. Master brief §2.4 row 3's "chokidar watcher in daemon" is incorrect against the verified SHA. The actual dispatcher is `FastChecker` polling at `pollInterval` (default 1000ms, configurable). Operational impact: message-delivery latency is bounded by the poll interval, not zero-latency event-driven; relevant for the Brief Decoder → Sourcing Scout → Concierge "four-agent pipelines complete in seconds" claim (Ultraplan §3.2). With 1s polling per hop and 3 hops, end-to-end is ≥3s, not sub-second.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/architecture/second-brain-design.md:198:| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:205:| `wiki/raw/briefs/` | one file per brief intake | markdown with frontmatter | `{epoch}-{brief-id}.md` | Brief Decoder (v1.1) on inbound | Sourcing Scout (v1.0 reads only candidate-relevant); Brief Decoder (v1.1) |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:211:| `wiki/compiled/briefs/{slug}.md` | one per Brief | same | same | Brief Decoder (v1.1); manual at v1.0 if needed | Sourcing Scout (v1.0 reads only); Brief Decoder (v1.1) |
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:237:| Brief | **v1.0 (skeleton) / v1.1 (full)** | Sourcing Scout (v1.0 A5) needs to *read* a Brief to source against; Brief Decoder (v1.1 A8) is the producer. v1.0 writes minimal Briefs (manual entry or direct Bullhorn sync via Janitor); full lifecycle waits for v1.1 |
docs/architecture/second-brain-design.md:266:do_not_contact: false                                # required; defaults to false; respected by Concierge
docs/architecture/second-brain-design.md:319:v1.0 skeleton: only what Sourcing Scout (A5) needs to source against — role title, client, sector, must-haves. Full v1.1 schema waits for Brief Decoder.
docs/architecture/second-brain-design.md:383:do_not_contact: false                                # required
docs/architecture/second-brain-design.md:429:| `list-by-type-and-tenant` | Sourcing Scout (v1.0): enumerate Candidates for filtering; Brief Decoder (v1.1): enumerate open Briefs | v1.0 (Candidate, Client, Placement, Contact); v1.1 (Brief full enumeration) | `(entity_type: str, tenant_id: str, filters?: dict, limit?: int)` | `List[EntityRef]` | few seconds | Postgres-indexed; filtering matches `search-by-attribute` |
docs/architecture/second-brain-design.md:654:        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:774:| Sourcing Scout | 50:1 | reads briefs + candidate pool to filter; writes only shortlists |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,605p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '540,560p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '260,460p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   260	### Gate B — Outcome threshold (success metric, not block)
   261	
   262	Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
   263	
   264	Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.
   265	
   266	Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing) — operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
   267	
   268	Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
   269	
   270	---
   271	
   272	## §6 — Escalation codes
   273	
   274	Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
   275	
   276	| Code | Trigger | Severity | Routing |
   277	|---|---|---|---|
   278	| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (per catalogue §2.3) | operator + ifos_oncall |
   279	| `ESC_LINKEDIN_AUTH` | LinkedIn / Proxycurl session/OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   280	| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   281	| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   282	| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
   283	| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
   284	| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   285	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
   286	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
   287	| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
   288	
   289	Sourcing Scout does NOT use:
   290	
   291	- `ESC_AUTOSEND_*` — no auto-send actions; pure read + report
   292	- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
   293	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
   294	- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
   295	- `ESC_DNC_FILTER_HIT` — per catalogue §2.10 reserved for outbound send refusal specifically; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish backlog: add ESC_SOURCING_DNC_FILTER.
   296	
   297	---
   298	
   299	## §7 — Voice + tone constraints
   300	
   301	Step 9 (per-candidate rationale generation) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   302	
   303	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
   304	  - No demographic inference (age, gender, nationality, ethnicity, family status) — Equality Act 2010 compliance
   305	  - No salary-band reference unless explicitly supplied by candidate
   306	  - No claims about candidate intent ("looking to leave their role") without evidence in source data
   307	  - No mention of competing agency placements except in risk-flag context
   308	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
   309	- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
   310	
   311	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   312	
   313	---
   314	
   315	## §8 — Build dependencies (W9 prerequisites)
   316	
   317	Sourcing Scout build cannot start until ALL of the following are confirmed:
   318	
   319	| Dependency | Source | Status |
   320	|---|---|---|
   321	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   322	| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
   323	| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
   324	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   325	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   326	| Bullhorn MCP read capability | W3-W4-W5 build chain | ⏸ |
   327	| **Proxycurl commercial signup** + API access | Founder commercial; ~$39+/mo | ⏸ |
   328	| **Reed.co.uk commercial signup** + API access | Founder commercial | ⏸ |
   329	| **CV-Library commercial signup** + API access | Founder commercial | ⏸ |
   330	| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
   331	| Reed MCP connector | W9 build start (~2 days) | ⏸ |
   332	| CV-Library MCP connector | W9 build start (~2 days) | ⏸ |
   333	| Source-abstraction layer (Night Sourcer reuse) | W9 build start (~2 days) | ⏸ |
   334	| Per-tenant source credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   335	| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
   336	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   337	| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
   338	| `context.sh` hydration | Build at W9 start (~0.5 day) | ⏸ |
   339	| `cycle.sh` orchestration (11-step) | Build at W9 start (~2 days) | ⏸ |
   340	| 3 fixtures with golden outputs | Build at W9 start (~1 day) | ⏸ |
   341	
   342	**Until ALL ⏸ items resolve to ✅, W9 build slice does not start.**
   343	
   344	---
   345	
   346	## §9 — Status + open questions
   347	
   348	**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
   349	
   350	### Open questions for founder review
   351	
   352	| # | Question | Resolution path |
   353	|---|---|---|
   354	| Q1 | All three external sources required for v1.0? Reed + CV-Library are UK-recruitment-specific; Proxycurl is LinkedIn-via-API. Could v1.0 ship with Bullhorn + Proxycurl only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
   355	| Q2 | Proxycurl pricing — ~$39/mo for 5,000 credits at low volume; scales with usage. Per pilot tenant budget? | ~5-10 briefs/day per consultant × 50 calls/brief = up to 2,500 credits/day per consultant. Cost: ~$20-50/day at peak. |
   356	| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
   357	| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
   358	| Q5 | Gate B 6-of-10 metric — measured via consultant feedback. Brain UI v1.0 doesn't have feedback UX yet. Telegram reply? | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful". v1.1: Brain UI button. |
   359	| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
   360	| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `date_last_modified_at < now() - 90 days` (per schema line 100) to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side modification-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |
   361	
   362	### Gotchas (carried forward from ULTRAPLAN A5 line 555)
   363	
   364	1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
   365	2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
   366	3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.
   367	
   368	---
   369	
   370	## §10 — When this document ratifies
   371	
   372	Per `.codex/ratification/review-agent-bundle.md` skill (built 2026-05-24, commit `825ebd4`): this agent.md ratifies when Codex review-agent-bundle returns RATIFIED verdict.
   373	
   374	Status flips Proposed → Accepted when:
   375	- Codex Round 4 Phase 2 ratifies
   376	- Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B UX)
   377	- Q2 cost model approved with per-tenant budget cap
   378	- Q6: ADR-006 (source-abstraction layer) drafted + ratified
   379	
   380	Status flips Accepted → In Force when:
   381	- W9 build slice produces all 5 sibling bundle files + 3 fixtures
   382	- First production brief processed end-to-end against migration-test tenant
   383	- Gate B feedback loop operational (Telegram OR Brain UI)
   384	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   385	
   386	Until then: this document is a forward-looking scaffold.
   387	
   388	*End of Sourcing Scout agent.md draft.*

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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '78,105p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

codex
The first pass found a likely schema/status inconsistency around `tenant_adapters.config.blocked_recipients`; I’m checking the supplement and escalation catalogue now so the verdict can cite concrete lines.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,80p;600,700p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
     2	# ============================================================================
     3	# Status: Proposed (Codex Day-19 ratification queue addendum)
     4	# Date:   2026-05-24 (Day 19; post-Round-8 Cat-β unblock)
     5	# Author: Founder (Maddox) + Claude Code
     6	# Predecessor: docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
     7	#
     8	# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
     9	# Concierge schema gaps) per docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
    10	# Phase 4 Cat-β section. Closes the v0.3-scoped subset (14 entity JSONB keys + 2
    11	# auxiliary tables + 3 tenant_adapters.config keys + v0.2 entity-access amendments).
    12	# Residual Cat-β gaps require either (a) Scribe agent.md consistency-pass to align
    13	# its §3 narrative with canonical v0.1/v0.2/v0.3 field names (current_role vs
    14	# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
    15	# v0.4-supplement that adds the remaining Scribe-referenced fields (seniority,
    16	# opportunity.sector, current_role_title). v0.4 work is queued for W4-polish slice;
    17	# v0.3 ratification does not block on it.
    18	#
    19	# Companion migrations: migrations/v0.2-to-v0.3.sql + migrations/v0.3-to-v0.2.sql
    20	#   Both files drafted at commit alongside this supplement.
    21	#
    22	# Field types: per `review-schema-change` skill §2 allowed types only —
    23	# string | integer | number | boolean | array | object | timestamp | date.
    24	# Enums expressed as `type: string` + `enum: [...]`. Lists as `type: array`
    25	# with `items.type`. SQL-level types (NUMERIC(15,2), TIMESTAMPTZ etc.) appear
    26	# only in the companion migration SQL, not here.
    27	#
    28	# Schema layering: entities.data is JSONB per Day-4 §6.3 generic primitive.
    29	# v0.3 entity-field additions are JSONB key shapes validated via the
    30	# validate_entities_data_v0_3 trigger function in v0.2-to-v0.3.sql §4.
    31	# No ALTER TABLE for the candidate / contact / brief / placement / opportunity
    32	# tables — they're already JSONB-shaped.
    33	# ============================================================================
    34	
    35	vertical: recruitment
    36	version: v0.3
    37	supplements: v0.2
    38	status: Proposed
    39	date: 2026-05-24
    40	author: founder (Maddox) + Claude Code; bilateral Cat-β unblock
    41	codex_ratification_queue_position: 44
    42	
    43	# ============================================================================
    44	# §1 — New entity.data JSONB key shapes (14 across 5 entities)
    45	# ============================================================================
    46	#
    47	# All additions land as JSONB keys on the existing entities.data column
    48	# (Day-4 §6.3 generic primitive layer). Validation lives in
    49	# validate_entities_data_v0_3() trigger function (migration §4).
    50	
    51	entity_field_additions:
    52	
    53	  candidate:
    54	    v0_3_new_keys:
    55	      employment_type:
    56	        type: string
    57	        enum: [perm, contract, contract_inside_ir35, contract_outside_ir35, day_rate, hybrid]
    58	        required: false
    59	        notes: |
    60	          Candidate's preferred engagement model (distinct from role type).
    61	          IR35 distinction matters for UK contractors. Extracted by Scribe
    62	          from call context.
    63	        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
    64	        v1_0_agent_access:
    65	          - Scribe: W
    66	          - Sourcing Scout: R
    67	
    68	      key_skills:
    69	        type: array
    70	        items:
    71	          type: string
    72	        max_items: 20
    73	        required: false
    74	        notes: |
    75	          Aggregated skill tags from CV + transcripts. Free-text strings;
    76	          W4 polish may add controlled-vocabulary clustering. Max 20 items
    77	          per candidate enforced by validate_entities_data_v0_3.
    78	        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
    79	        v1_0_agent_access:
    80	          - Scribe: W
   600	
   601	auxiliary_tables:
   602	
   603	  cash_conductor_transactions:
   604	    rationale: |
   605	      Open Banking transactions are high-volume + time-series + don't model
   606	      as entity.data JSONB. v0.3 introduces a first-class table with
   607	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   608	      §4 Step 3 + ADR-002 vault/Postgres split.
   609	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2 (migration is authoritative; this section mirrors the SQL columns)
   610	    columns:
   611	      id: {type: integer, required: true, source: IFOS-internal, notes: BIGSERIAL primary key in SQL}
   612	      tenant_slug: {type: string, required: true, source: IFOS-internal, notes: RLS isolation key per Day-4 §6.3}
   613	      transaction_id: {type: string, required: true, source: Open Banking provider (TrueLayer / Plaid)}
   614	      posted_at: {type: timestamp, required: true, source: Open Banking provider}
   615	      amount: {type: number, required: true, source: Open Banking provider, notes: NUMERIC(15,2) GBP; negative for outgoing}
   616	      currency: {type: string, required: true, default: GBP, source: Open Banking provider}
   617	      payee_name_raw: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   618	      description: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   619	      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct], source: IFOS-internal (per-tenant config)}
   620	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}
   621	      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
   622	      match_confidence: {type: number, required: false, source: IFOS-derived (Cash Conductor algorithm), notes: "range [0.00, 1.00]"}
   623	      match_dimensions: {type: array, items: {type: string}, required: false, source: IFOS-derived}
   624	      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
   625	      raw_payload: {type: object, required: false, source: Open Banking provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific. Full Open Banking response cached for audit; pseudonymized at year 7"}
   626	    indexes:
   627	      - "(tenant_slug, posted_at DESC)"
   628	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   629	    retention: |
   630	      INTENT (W4-polish enforcement required): 7-year retention with
   631	      pseudonymization at year 7 for PII-bearing fields (payee_name_raw,
   632	      description, raw_payload). Aligned with Q4 v0_3_default. The
   633	      v0.2-to-v0.3 migration creates the table + indexes only; the
   634	      pseudonymization + purge implementation is a W4-polish slice (pg_cron
   635	      job or external scheduled job; not yet authored).
   636	    enforcement_gate: |
   637	      Production use of this table GATED until pseudonymization + purge
   638	      implementation lands as W4 polish. Per-tenant DPA addendum signed
   639	      by founder + tenant before go-live; migration-test tenant exempt.
   640	
   641	  cash_conductor_invoices:
   642	    rationale: |
   643	      Open invoice register cached from accounting provider. Same auxiliary-
   644	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   645	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3 (migration is authoritative)
   646	    columns:
   647	      id: {type: integer, required: true, source: IFOS-internal}
   648	      tenant_slug: {type: string, required: true, source: IFOS-internal}
   649	      invoice_id: {type: string, required: true, source: Accounting provider (Xero/QuickBooks/Sage)}
   650	      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage], source: IFOS-internal (per-tenant config)}
   651	      invoice_number: {type: string, required: false, source: Accounting provider}
   652	      issued_at: {type: timestamp, required: true, source: Accounting provider}
   653	      due_at: {type: timestamp, required: true, source: Accounting provider}
   654	      amount_total: {type: number, required: true, source: Accounting provider, notes: NUMERIC(15,2) GBP}
   655	      amount_paid: {type: number, required: true, default: 0, source: Accounting provider + IFOS-derived (Cash Conductor reconciliation updates)}
   656	      currency: {type: string, required: true, default: GBP, source: Accounting provider}
   657	      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open, source: Accounting provider}
   658	      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor links to Bullhorn placement.client_contact_id)}
   659	      client_billing_email: {type: string, required: false, source: Accounting provider, pii: true}
   660	      last_chase_position: {type: integer, required: true, default: 0, source: IFOS-derived (Cash Conductor escalation ladder), notes: 0-4 per Cash Conductor §3.2}
   661	      last_chase_sent_at: {type: timestamp, required: false, source: IFOS-derived}
   662	      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
   663	      raw_payload: {type: object, required: false, source: Accounting provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific (Xero / QuickBooks / Sage). Full provider response cached for audit"}
   664	    indexes:
   665	      - "(tenant_slug, due_at)"
   666	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   667	      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
   668	    retention: |
   669	      INTENT (W4-polish enforcement required): 7-year retention with
   670	      pseudonymization at year 7 per Q4 v0_3_default. Cancelled/voided rows
   671	      90d. The v0.2-to-v0.3 migration creates the table + indexes only; the
   672	      pseudonymization + purge implementation is a W4-polish slice
   673	      (pg_cron job or external scheduled job; not yet authored).
   674	    enforcement_gate: |
   675	      Until pseudonymization + 90d-cancelled-purge implementation lands as
   676	      W4 polish, production use of cash_conductor_invoices is GATED by
   677	      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
   678	      per §3 cash_conductor_transactions.retention). Migration-test tenant
   679	      data is exempt; pilot tenants require the DPA addendum signed before
   680	      go-live.
   681	
   682	auxiliary_table_access_matrix:
   683	  voice_corpus:
   684	    # v0.2 auxiliary table — voice exemplar corpus (per-tenant)
   685	    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents that
   686	    # produce voice-classified output
   687	    diagnostic: R
   688	    janitor: R
   689	    scribe: R
   690	    cash_conductor: R
   691	    sourcing_scout: R
   692	    concierge: R
   693	  voice_corpus_chunks:
   694	    # v0.2 auxiliary table holding pgvector HNSW index over voice corpus chunks
   695	    # All v1.0 agents producing voice-classified output need R for ANN-match retrieval
   696	    diagnostic: R
   697	    janitor: R
   698	    scribe: R
   699	    cash_conductor: R
   700	    sourcing_scout: R

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '120,205p;230,270p;370,390p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '70,95p;135,170p;223,245p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '330,360p'; nl -ba docs/decisions/autosend-safety-policy.md | sed -n '70,130p'" in /Users/madsadmin/code/CortexOS
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
   356	defaults:
   357	  approval_timeout: PT4H        # Default orange-tier approval window per §8 rule 5
   358	  min_sample_rate: 100          # Tenants cannot set sample rate above 1-in-100 per §8 rule 6
   359	  spot_check_queue_path: /vault/{tenant_slug}/spot-checks/   # Where autosend_spot_check_enqueue writes
   360	
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

exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_AUTH|ESC_DNC_FILTER_HIT|ESC_SOURCING_DNC|DNC|do not contact" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
97:#### `ESC_BULLHORN_AUTH`
232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
424:#### `ESC_DNC_FILTER_HIT`

exec
/bin/zsh -lc 'rg -n "tenant_adapters|blocked_recipients|auto_source_on_brief_create|cash_conductor_last_run|concierge_last_poll|concierge_send_window" docs/verticals/recruitment/vertical-schema*.yaml migrations -S' in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: migrations: No such file or directory (os error 2)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 3 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:738:# §4 — tenant_adapters.config new keys (3 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:741:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:742:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:745:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:747:  cash_conductor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:756:  concierge_last_poll:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:765:  concierge_send_window:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:853:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:855:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:928:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:940:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:978:    - Concierge tenant_adapters.config field refs valid

exec
/bin/zsh -lc 'rg -n "Proxycurl|Reed|CV-Library|source-abstraction|Sourcing Scout|candidate.status|brief" docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:48:#   v0.1 entities (candidate, contractor, contact, brief, opportunity, placement)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:75:          Semver tag (e.g. "v0.1", "v0.2-2026-06-15"). Bump on re-index. Live pack is the row with `is_active: true`; historical packs preserved for audit + rollback per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:168:          Provenance: "founder" (default tenant-onboarding rules), "tenant-admin" (added via Brain UI), "ifos-csm" (added during CSM intervention per master brief §10 CSM workflow).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:191:      Human edit to an agent's output captured at the point the consultant approves/edits/rejects a draft. Drives (a) the voice-drift-canary nightly cron, (b) future LoRA SFT pair generation per Ultraplan §6.1, (c) classifier retraining queue. Append-only per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:311:  brief:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:317:        Aggregate (last-7-day mean) voice classifier score across all Concierge messages about this brief. Drives "this brief is producing voice-drift messages — investigate" alerting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:325:        v1.1+ Triage exercises this; v1.0 sets to NULL. Tracks voice score for outbound messages within a specific candidate-brief opportunity pairing.
docs/verticals/recruitment/vertical-schema.yaml:10:# Source: master brief §6 Day 6 line 490 (8 core entities)
docs/verticals/recruitment/vertical-schema.yaml:26:  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
docs/verticals/recruitment/vertical-schema.yaml:27:  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:36:#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
docs/verticals/recruitment/vertical-schema.yaml:55:      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:141:        source: IFOS-derived (set by Sourcing Scout at first-touch)
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:216:      - IR35 classification is regulatory-bearing; v0.1 captures the field but T4 IR35 agent (v2.0 per master brief §9) is the canonical reasoner.
docs/verticals/recruitment/vertical-schema.yaml:223:      A company that hires through the recruitment agency. Master brief canonical vocabulary at §3.2 line 155 ("candidate, placement, brief") implicitly assumes client as the holder of briefs. Bullhorn calls this `ClientCorporation`.
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:289:      - (v1.1+) Inbound Triage — R+W expansion per master brief §9
docs/verticals/recruitment/vertical-schema.yaml:341:  brief:
docs/verticals/recruitment/vertical-schema.yaml:343:      A role being recruited for. Master brief canonical vocabulary uses `brief`; §6 Day 6 line 490 lists "Role/Brief" — `brief` is the canonical entity_type slug; `role` is documented alias. Bullhorn calls this `JobOrder`.
docs/verticals/recruitment/vertical-schema.yaml:349:      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:350:      - Concierge (R — linked-brief context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:497:      A candidate-brief pairing in the submission/screening/interview/offer pipeline. Pre-placement state. v1.1+ exercised; v1.0 minimal.
docs/verticals/recruitment/vertical-schema.yaml:537:      A contractor's weekly hours record. v2.0 entity — exercised by T2 Timesheet agent + T6 Pay & Bill agent per master brief §9. v0.1 captures placeholder shape only.
docs/verticals/recruitment/vertical-schema.yaml:594:  placement_for_brief:
docs/verticals/recruitment/vertical-schema.yaml:596:    target: brief
docs/verticals/recruitment/vertical-schema.yaml:598:    description: Each placement fills exactly one brief; a brief may have multiple placements over time (replacement hires, multiple seats).
docs/verticals/recruitment/vertical-schema.yaml:601:  brief_from_client:
docs/verticals/recruitment/vertical-schema.yaml:602:    source: brief
docs/verticals/recruitment/vertical-schema.yaml:605:    description: Each brief is owned by exactly one client (the hiring company).
docs/verticals/recruitment/vertical-schema.yaml:608:  brief_decision_maker:
docs/verticals/recruitment/vertical-schema.yaml:609:    source: brief
docs/verticals/recruitment/vertical-schema.yaml:612:    description: Each brief has a designated decision-maker contact at the client (the hiring manager).
docs/verticals/recruitment/vertical-schema.yaml:614:      v0.1 captures the PRIMARY decision-maker only. Real-world recruiting often has multiple decision-makers per brief (hiring manager + HR + occasionally CTO/CFO/CEO). The N:1 cardinality is the simplifying v0.1 assumption. Multi-decision-maker panels deferred to v1.1 Triage per Q10 — when v1.1 lands, brief_decision_maker may flip to M:N with role-in-panel metadata (chair, technical-evaluator, hr-lead, budget-approver, etc.) on entity_links.metadata.
docs/verticals/recruitment/vertical-schema.yaml:637:    v1_0_exercise: Sourcing Scout captures at first-touch when relevant; not heavily exercised in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:639:  opportunity_for_brief:
docs/verticals/recruitment/vertical-schema.yaml:641:    target: brief
docs/verticals/recruitment/vertical-schema.yaml:643:    description: An opportunity is a candidate's progression toward a specific brief.
docs/verticals/recruitment/vertical-schema.yaml:651:    description: Each opportunity is about exactly one candidate; a candidate may have multiple opportunities (different briefs).
docs/verticals/recruitment/vertical-schema.yaml:676:    brief: none
docs/verticals/recruitment/vertical-schema.yaml:687:    brief: R         # status drift sweep
docs/verticals/recruitment/vertical-schema.yaml:695:    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
docs/verticals/recruitment/vertical-schema.yaml:697:    brief: R         # write-context resolution
docs/verticals/recruitment/vertical-schema.yaml:707:    brief: none
docs/verticals/recruitment/vertical-schema.yaml:717:    brief: R         # active brief context for matching
docs/verticals/recruitment/vertical-schema.yaml:727:    brief: R         # linked-brief context
docs/verticals/recruitment/vertical-schema.yaml:765:  brief:
docs/verticals/recruitment/vertical-schema.yaml:822:    revisit_trigger: v1.1 Inbound Triage agent build per master brief §9 expands decision-authority modelling.
docs/verticals/recruitment/vertical-schema.yaml:829:    rationale: T2 + T6 builds are v2.0 per master brief §9; full schema requires pay/bill modelling not yet designed.
docs/verticals/recruitment/vertical-schema.yaml:840:    v0_1_decision: brief.required_skills + brief.nice_to_have_skills are free-string arrays in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:841:    revisit_trigger: Skill-matching accuracy from Sourcing Scout's first 4 tenant-weeks of operation; if free-text matching produces <60% precision, canonical skill taxonomy lands as v1.1.
docs/verticals/recruitment/vertical-schema.yaml:854:    v0_1_decision: brief_decision_maker is N:1 (each brief has one primary decision-maker contact in v0.1).
docs/verticals/recruitment/vertical-schema.yaml:855:    revisit_trigger: v1.1 Inbound Triage expands to panel modelling — multiple decision-maker contacts per brief with role-in-panel (chair, technical-evaluator, hr-lead, etc.).
docs/verticals/recruitment/vertical-schema.yaml:856:    rationale: v1.0 Concierge addressee-resolution uses primary-decision-maker; panel modelling adds value when v1.1 Triage handles inbound brief queries from multiple stakeholders.
docs/verticals/recruitment/vertical-schema.yaml:896:    expected_date: post first-pilot operations (Q4 2026 if pilot lands per master brief §6 Day 7 question 1)
docs/verticals/recruitment/vertical-schema.yaml:901:    expected_date: 2027+ per master brief §9 build sequence
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:14:# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:31:# No ALTER TABLE for the candidate / contact / brief / placement / opportunity
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:66:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:78:        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:81:          - Sourcing Scout: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:92:        source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:94:          - Sourcing Scout: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:125:  brief:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:134:          Hard requirements; Sourcing Scout filters candidates against this
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:136:        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:139:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:147:          Soft preferences; Sourcing Scout uses for ranking, not hard filter.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:151:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:159:          Anti-requirements; Sourcing Scout EXCLUDES candidates matching any
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:164:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:224:          ("we're hiring 5 engineers this quarter"). Sourcing Scout reads
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:229:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:238:          ranking in Sourcing Scout's brief-to-candidate pipeline.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:242:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:290:#   - Sourcing Scout candidate: R → R+W (writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:293:#   - Sourcing Scout opportunity: none → R (reads opportunity context for ICP)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:314:  # (candidate, contractor, client, contact, brief, opportunity, placement,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:367:    brief: none            # diagnostic is sales-tool not brief-driven
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:377:    brief: R               # context for related candidate cleanup
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:393:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:408:    brief: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:417:    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:421:    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:424:    brief: R               # reads to filter candidates
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:438:    brief: R               # IFOS-cached read (Bullhorn endpoint A6 — JobOrder)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:458:    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:464:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:477:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:484:  brief:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:492:      v0.3 upgrades Scribe to R+W for the 3 new brief fields only; existing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:503:      - Sourcing Scout (R) # v0.3 NEW — reads opportunity for ICP scoring
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:508:      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
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
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:848:      candidate / contact / brief / placement / opportunity entity_types.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:971:      seniority — not yet in schema; brief.start_date should be

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '90,108p;420,432p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '738,782p;936,946p'" in /Users/madsadmin/code/CortexOS
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

 succeeded in 0ms:
   738	# §4 — tenant_adapters.config new keys (3 keys)
   739	# ============================================================================
   740	#
   741	# tenant_adapters.config is JSONB; validation via
   742	# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
   743	# on unknown keys per Rule 2.
   744	
   745	tenant_adapters_config_additions:
   746	
   747	  cash_conductor_last_run:
   748	    type: timestamp
   749	    required: false
   750	    set_by: cash_conductor
   751	    read_by: [cash_conductor]
   752	    notes: |
   753	      Cash Conductor cron sweep updates at session-close. Next run queries
   754	      transactions/invoices since this timestamp.
   755	
   756	  concierge_last_poll:
   757	    type: timestamp
   758	    required: false
   759	    set_by: concierge
   760	    read_by: [concierge]
   761	    notes: |
   762	      Concierge polling cron updates at end of each cycle. Next poll queries
   763	      Bullhorn for state transitions since this timestamp.
   764	
   765	  concierge_send_window:
   766	    type: object
   767	    required: false
   768	    default:
   769	      timezone: Europe/London
   770	      weekday_start: '09:00'
   771	      weekday_end: '17:00'
   772	      weekend_send_enabled: false
   773	    set_by: [tenant-admin]
   774	    read_by: [concierge]
   775	    object_shape:
   776	      timezone:
   777	        type: string
   778	        notes: IANA timezone identifier
   779	      weekday_start:
   780	        type: string
   781	        notes: HH:MM 24-hour format
   782	      weekday_end:
   936	      DPA addendum signed by founder + tenant. Migration-test tenant data
   937	      is not subject to this gate.
   938	
   939	  Q5_unknown_config_keys_handling:
   940	    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
   941	    options:
   942	      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
   943	      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
   944	      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
   945	    v0_3_default: A
   946	    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need

exec
/bin/zsh -lc 'rg -n "seniority|day-rate-band|salary_band|brief_location|brief_sector|role title|sector|must_haves|nice_to_haves|deal_breakers" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:15:# v0.4-supplement that adds the remaining Scribe-referenced fields (seniority,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:16:# opportunity.sector, current_role_title). v0.4 work is queued for W4-polish slice;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:127:      must_haves:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:141:      nice_to_haves:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:153:      deal_breakers:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:279:#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:393:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:488:      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:965:      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:971:      seniority — not yet in schema; brief.start_date should be
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:972:      start_date_target; opportunity.sector — not yet in schema). These
docs/verticals/recruitment/vertical-schema.yaml:360:        notes: Role title as advertised; not internal IFOS-codified.

exec
/bin/zsh -lc 'rg -n "auto_source_on_brief_create|auto-source-on-brief-create" . -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
./logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.prompt.md:295:**Status:** Proposed (2026-05-24 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice + tenant_adapters.config v0.4-supplement adding blocked_recipients + auto_source_on_brief_create).
./logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.prompt.md:327:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.output.md:308:**Status:** Proposed (2026-05-24 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice + tenant_adapters.config v0.4-supplement adding blocked_recipients + auto_source_on_brief_create).
./logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.output.md:340:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.output.md:725:     3	**Status:** Proposed (2026-05-24 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice + tenant_adapters.config v0.4-supplement adding blocked_recipients + auto_source_on_brief_create).
./logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.output.md:757:    35	Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.output.md:1176:agents/recruitment/sourcing-scout/agent.md:3:**Status:** Proposed (2026-05-24 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice + tenant_adapters.config v0.4-supplement adding blocked_recipients + auto_source_on_brief_create).
./logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.output.md:1182:agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T151320Z-92280/agents_recruitment_sourcing-scout_agent-md.output.md:2222:/bin/zsh -lc 'rg -n "tenant_adapters|blocked_recipients|auto_source_on_brief_create|cash_conductor_last_run|concierge_last_poll|concierge_send_window" docs/verticals/recruitment/vertical-schema*.yaml migrations -S' in /Users/madsadmin/code/CortexOS
./agents/recruitment/sourcing-scout/agent.md:3:**Status:** Proposed (2026-05-24 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice + tenant_adapters.config v0.4-supplement adding blocked_recipients + auto_source_on_brief_create).
./agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.prompt.md:327:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.output.md:340:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.output.md:999:agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.output.md:2786:    35	Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150519Z-84855/agents_recruitment_sourcing-scout_agent-md.output.md:3027:agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.prompt.md:327:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.output.md:340:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.output.md:844:agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.output.md:2023:    35	Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T113139Z-84869/agents_recruitment_sourcing-scout_agent-md.output.md:4502:agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md:3906:agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.prompt.md:327:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150822Z-87224/agents_recruitment_sourcing-scout_agent-md.prompt.md:327:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.output.md:340:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.output.md:1049:agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.output.md:4146:    35	Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.output.md:4415:1. Undefined tenant config keys are assumed. Lines 16, 109-111, 187-190, 242, 326, and 347 rely on `tenant_adapters.config.blocked_recipients`, and line 35 relies on tenant config for `auto-source-on-brief-create`; `vertical-schema.v0.3-supplement.yaml` §4 lists only `cash_conductor_last_run`, `concierge_last_poll`, and `concierge_send_window` as tenant_adapters config additions. This violates Schema before code. Proposed fix: add these config keys to the schema supplement/migration, or remove the assumptions and cite an existing schema-defined source.
./logs/codex-ratification/20260524T151012Z-89382/agents_recruitment_sourcing-scout_agent-md.output.md:4424:1. Undefined tenant config keys are assumed. Lines 16, 109-111, 187-190, 242, 326, and 347 rely on `tenant_adapters.config.blocked_recipients`, and line 35 relies on tenant config for `auto-source-on-brief-create`; `vertical-schema.v0.3-supplement.yaml` §4 lists only `cash_conductor_last_run`, `concierge_last_poll`, and `concierge_send_window` as tenant_adapters config additions. This violates Schema before code. Proposed fix: add these config keys to the schema supplement/migration, or remove the assumptions and cite an existing schema-defined source.
./logs/codex-ratification/20260524T150822Z-87224/agents_recruitment_sourcing-scout_agent-md.output.md:340:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150822Z-87224/agents_recruitment_sourcing-scout_agent-md.output.md:1169:agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150822Z-87224/agents_recruitment_sourcing-scout_agent-md.output.md:2602:    35	Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T104204Z-40927/agents_recruitment_janitor_agent-md.output.md:1285:agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150247Z-82902/agents_recruitment_sourcing-scout_agent-md.prompt.md:327:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150247Z-82902/agents_recruitment_sourcing-scout_agent-md.output.md:340:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150022Z-81292/agents_recruitment_sourcing-scout_agent-md.prompt.md:327:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150022Z-81292/agents_recruitment_sourcing-scout_agent-md.output.md:340:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150022Z-81292/agents_recruitment_sourcing-scout_agent-md.output.md:1385:agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T150022Z-81292/agents_recruitment_sourcing-scout_agent-md.output.md:3886:    35	Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T115626Z-6836/agents_recruitment_sourcing-scout_agent-md.prompt.md:327:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T115626Z-6836/agents_recruitment_sourcing-scout_agent-md.output.md:340:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T115626Z-6836/agents_recruitment_sourcing-scout_agent-md.output.md:730:    35	Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T115626Z-6836/agents_recruitment_sourcing-scout_agent-md.output.md:1142:agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T102404Z-24809/agents_recruitment_sourcing-scout_agent-md.prompt.md:327:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T102404Z-24809/agents_recruitment_sourcing-scout_agent-md.output.md:340:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T102404Z-24809/agents_recruitment_sourcing-scout_agent-md.output.md:778:agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
./logs/codex-ratification/20260524T102404Z-24809/agents_recruitment_sourcing-scout_agent-md.output.md:2825:    35	Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.

codex
REJECTED

1. Undefined tenant config keys are treated as usable schema. Lines 16, 109-111, 251, 335, and 356 rely on `tenant_adapters.config.blocked_recipients`, while line 35 relies on `auto-source-on-brief-create`; `vertical-schema.v0.3-supplement.yaml` §4 lines 738-765 registers only `cash_conductor_last_run`, `concierge_last_poll`, and `concierge_send_window`, and lines 939-943 say unknown keys hard-fail. Proposed fix: add these keys in a v0.4 schema supplement/migration before referencing them as runnable config, or mark every use as blocked until that lands.

2. Gate A misroutes PII leakage as a warn-level output-shape failure. Lines 253 and 256 say “No PII outside firm boundary” is a Gate A condition but all Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE`; the catalogue defines `ESC_PII_LEAKAGE_RISK` as blocking at `agents/_shared/escalation-codes.md` lines 148-154, and the artefact itself lists that code at line 285. Proposed fix: split Gate A failure routing so PII leakage fires `ESC_PII_LEAKAGE_RISK` and halts immediately, while shape-only misses use `ESC_AGENT_OUTPUT_SHAPE`.

3. Gate A contradicts the documented degraded-mode workflow. Lines 127-142 allow individual source auth failures to enter degraded mode and continue with remaining sources, but line 254 hard-fails if any source contributes 0 candidates. That makes the stated degraded mode impossible whenever a skipped/degraded source contributes zero. Proposed fix: change the Gate A condition to “no enabled live source returns 0 candidates without a recorded degradation/exception,” or remove the per-source-zero hard-fail.
tokens used
62,648
REJECTED

1. Undefined tenant config keys are treated as usable schema. Lines 16, 109-111, 251, 335, and 356 rely on `tenant_adapters.config.blocked_recipients`, while line 35 relies on `auto-source-on-brief-create`; `vertical-schema.v0.3-supplement.yaml` §4 lines 738-765 registers only `cash_conductor_last_run`, `concierge_last_poll`, and `concierge_send_window`, and lines 939-943 say unknown keys hard-fail. Proposed fix: add these keys in a v0.4 schema supplement/migration before referencing them as runnable config, or mark every use as blocked until that lands.

2. Gate A misroutes PII leakage as a warn-level output-shape failure. Lines 253 and 256 say “No PII outside firm boundary” is a Gate A condition but all Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE`; the catalogue defines `ESC_PII_LEAKAGE_RISK` as blocking at `agents/_shared/escalation-codes.md` lines 148-154, and the artefact itself lists that code at line 285. Proposed fix: split Gate A failure routing so PII leakage fires `ESC_PII_LEAKAGE_RISK` and halts immediately, while shape-only misses use `ESC_AGENT_OUTPUT_SHAPE`.

3. Gate A contradicts the documented degraded-mode workflow. Lines 127-142 allow individual source auth failures to enter degraded mode and continue with remaining sources, but line 254 hard-fails if any source contributes 0 candidates. That makes the stated degraded mode impossible whenever a skipped/degraded source contributes zero. Proposed fix: change the Gate A condition to “no enabled live source returns 0 candidates without a recorded degradation/exception,” or remove the per-source-zero hard-fail.
