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
session id: 019e5a84-e87f-7131-8a92-beb4dd9fabcb
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
| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (per catalogue §2.3) | operator + ifos_oncall |
| `ESC_LINKEDIN_AUTH` | LinkedIn / Proxycurl session/OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
(Sourcing Scout does NOT use `ESC_DNC_FILTER_HIT` — per catalogue §2.10 that code is reserved for outbound send refusal; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops are logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish adds ESC_SOURCING_DNC_FILTER.)
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
I’ll verify the cited source files and catalogue entries against the agent-bundle rules, then return only the required verdict format.
exec
/bin/zsh -lc "rg --files | rg '("'^docs/.*(master|ULTRAPLAN|ultra|kill|schema|autosend|ADR)|agents/_shared/(escalation-codes.md|voice-loader.sh|hook-helpers.sh)|agents/recruitment/sourcing-scout/)'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
agents/recruitment/sourcing-scout/README.md
agents/recruitment/sourcing-scout/agent.md
docs/specs/ULTRAPLAN.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/decisions/autosend-safety-policy.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md
docs/decisions/autosend-approval-bridge-spec.md

exec
/bin/zsh -lc 'rg -n "Sourcing Scout|A5|ESC_BULLHORN_AUTH|ESC_LINKEDIN_AUTH|ESC_REED_AUTH|ESC_CVLIBRARY_AUTH|ESC_RATE_LIMIT_HIT|ESC_BRIEF_AMBIGUITY|ESC_VOICE_DRIFT|ESC_PII_LEAKAGE_RISK|ESC_AGENT_OUTPUT_SHAPE|ESC_GATE_B_MISS|ESC_DNC_FILTER_HIT|hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|send_to_blocked_recipient|blocked_recipients|candidate.status|date_last_modified_at|Build wave|W9|Trigger" docs agents packages -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/agent-renderer/templates/claude-md-preamble.md:58:- Cross-tenant PII is an `ESC_PII_LEAKAGE_RISK` escalation per `_shared/escalation-codes.md`.
packages/agent-renderer/README.md:104:| Code | Trigger |
agents/_shared/autosend-policy.yaml:116:    reason: "Internal audit row written by validate.sh when Gate A enforcement fails. Carries the specific ESC code (e.g. ESC_AGENT_OUTPUT_SHAPE | ESC_PII_LEAKAGE_RISK) in the payload; the action itself is just the audit-row write, not an external send. Each agent's validate.sh emits this row before exit 1."
agents/_shared/autosend-policy.yaml:128:    reason: "Internal audit row written by cycle.sh when @ifos/diagnostic-generator produces empty stdout. Carries ESC_AGENT_OUTPUT_SHAPE payload."
agents/_shared/autosend-policy.yaml:345:  send_to_blocked_recipient:
agents/_shared/autosend-policy.yaml:349:    reason: "Recipient in tenant's blocked_recipients override list"
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
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:417:    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:458:    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:464:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:477:      - Sourcing Scout (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:      - Sourcing Scout (R) # v0.1 unchanged
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
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:574:      Janitor agent.md §7 calls hh_load_tone_rules filtered by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:577:      Diagnostic + Sourcing Scout also read tone_rules for their
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:589:      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:855:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
packages/agents-runtime/_shared/common-target-patch.json:5:  "description": "Tenant's commercial sweet spot: sectors, geography, deal sizes, allow/block lists. Read by Sourcing Scout (W9) + Diagnostic (W3-4). Per PRODUCT-SPEC §5.3 line 363.",
packages/agents-runtime/_shared/common-target-patch.json:38:      "description": "Bands surface in Diagnostic ICP scoring + Sourcing Scout shortlist filtering."
agents/_shared/escalation-codes.md:35:- **Trigger:** Orange-tier action queued for tenant operator review
agents/_shared/escalation-codes.md:43:- **Trigger:** Red-tier action attempted; refused entirely (red is the tier-override floor per autosend §8)
agents/_shared/escalation-codes.md:50:- **Trigger:** `autosend_policy_lookup()` could not resolve a tier for the given `action_type` (unknown action_type, malformed `autosend-policy.yaml`, or tenant override resolution failed)
agents/_shared/escalation-codes.md:61:- **Trigger:** `flock` acquisition failed within `OP_LOCK_TIMEOUT_S = 5` seconds (per `common-vault.json.lock_timeout_seconds`)
agents/_shared/escalation-codes.md:68:- **Trigger:** Postgres optimistic-concurrency UPDATE found 0 rows after `OP_RETRY_BACKOFF_MS = 100` retry (per `common-vault.json.retry_backoff_ms`); per vault-concurrency §3 retry policy
agents/_shared/escalation-codes.md:75:- **Trigger:** Obsidian debounce hit `MAX_RETRIES = 5` (file mtime still recent after 30s of waiting) per vault-concurrency §4 + `common-vault.json.obsidian_debounce_max_retries`
agents/_shared/escalation-codes.md:82:- **Trigger:** Rewrite-backlinks cascade completed but ≥1 referencing entity failed to rewrite per vault-concurrency §5.4 v1.0 mitigation
agents/_shared/escalation-codes.md:89:- **Trigger:** Cascade exceeded `CASCADE_TIMEOUT_MS = 30_000` ms per vault-concurrency §5 + `common-vault.json.cascade_timeout_ms`
agents/_shared/escalation-codes.md:97:#### `ESC_BULLHORN_AUTH`
agents/_shared/escalation-codes.md:99:- **Trigger:** Bullhorn OAuth token refresh failed twice on the per-agent 8-minute cycle (per `common-ats.json.auth_refresh_interval_seconds`); or REST call returned 401 indefinitely (revoked token in Bullhorn admin UI)
agents/_shared/escalation-codes.md:110:- **Trigger:** Renderer exited non-zero. Mid-render atomic-rename per ADR-003 §3.3.4 means the prior agent dir at target is preserved (`.prev.<timestamp>/`) — no half-rendered state visible to daemon discovery
agents/_shared/escalation-codes.md:120:#### `ESC_VOICE_DRIFT`
agents/_shared/escalation-codes.md:122:- **Trigger:** Voice classifier score below `common-voice.json.voice_classifier_threshold` (default 0.75) after 3 retries per Ultraplan §5.3 retry budget
agents/_shared/escalation-codes.md:129:- **Trigger:** Dedup confidence `≥ 0.85` per Ultraplan §8.1 line 511 A2 Gate A; human-review-required cases
agents/_shared/escalation-codes.md:136:- **Trigger:** Supply Chain Auditor detected red flag (v1.0 placeholder; SCA agent in v1.1 backlog)
agents/_shared/escalation-codes.md:141:#### `ESC_BRIEF_AMBIGUITY`
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:148:#### `ESC_PII_LEAKAGE_RISK`
agents/_shared/escalation-codes.md:150:- **Trigger:** Agent output references PII outside the firm boundary (cross-tenant PII detected by `validate.sh` Gate A or RLS check)
agents/_shared/escalation-codes.md:156:#### `ESC_RATE_LIMIT_HIT`
agents/_shared/escalation-codes.md:158:- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
agents/_shared/escalation-codes.md:165:- **Trigger:** Agent produced output violating vertical-schema.yaml field constraints (e.g. wrote an unknown enum value, missing required field). Detected at write-time by adapter validation
agents/_shared/escalation-codes.md:170:#### `ESC_VOICE_DRIFT_TENANT`
agents/_shared/escalation-codes.md:172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
agents/_shared/escalation-codes.md:179:- **Trigger:** Agent rejected its input at the validation gate (e.g. malformed firm name, missing required CLI argument, brief description too short). Detected at Step 1 of the agent's workflow BEFORE any tool calls or LLM invocations
agents/_shared/escalation-codes.md:184:#### `ESC_AGENT_OUTPUT_SHAPE`
agents/_shared/escalation-codes.md:186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
agents/_shared/escalation-codes.md:196:- **Trigger:** Manual editing lock held by founder; agent backs off and reschedules
agents/_shared/escalation-codes.md:203:- **Trigger:** Generic vault concurrency anomaly not covered by ESC_VAULT_LOCK_TIMEOUT / ESC_VAULT_VERSION_MISMATCH / ESC_VAULT_HUMAN_EDIT_BLOCKED / ESC_VAULT_CASCADE_*
agents/_shared/escalation-codes.md:211:- **Trigger:** Rename operation raced with another writer; per vault-concurrency §5
agents/_shared/escalation-codes.md:218:- **Trigger:** Agent self-requested restart per primitive 6 (`cortextos-ifos bus self-restart`) — typically post-degraded-mode recovery, post-context-overflow handoff
agents/_shared/escalation-codes.md:225:- **Trigger:** Context approaching `ctx_handoff_threshold` (default 80%); agent saves state and triggers fresh-session takeover per primitive 1+2 context-rotation
agents/_shared/escalation-codes.md:232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
agents/_shared/escalation-codes.md:240:#### `ESC_REED_AUTH`
agents/_shared/escalation-codes.md:242:- **Trigger:** Reed jobs-board API OAuth token refresh failed twice OR REST call returned 401 indefinitely
agents/_shared/escalation-codes.md:248:#### `ESC_CVLIBRARY_AUTH`
agents/_shared/escalation-codes.md:250:- **Trigger:** CV-Library API OAuth failure (same pattern as ESC_REED_AUTH)
agents/_shared/escalation-codes.md:256:#### `ESC_LINKEDIN_AUTH`
agents/_shared/escalation-codes.md:257:- **Severity:** **blocking** — Sourcing Scout enters degraded mode (no profile fetches; cached only)
agents/_shared/escalation-codes.md:258:- **Trigger:** LinkedIn session cookie / OAuth token revoked or expired (LinkedIn has aggressive anti-bot session invalidation)
agents/_shared/escalation-codes.md:262:- **Recovery:** founder reauthenticates LinkedIn via Sourcing Scout admin flow
agents/_shared/escalation-codes.md:266:- **Trigger:** Google Workspace OAuth token refresh failed; Gmail send returns 401
agents/_shared/escalation-codes.md:274:- **Trigger:** Microsoft Graph OAuth refresh failed; Outlook sendMail returns 401
agents/_shared/escalation-codes.md:282:- **Trigger:** Xero (or alt accounting provider) OAuth token refresh failed; API returns 401
agents/_shared/escalation-codes.md:290:- **Trigger:** Open Banking PSD2 consent expired (90-day mandatory reauth) OR token refresh failed
agents/_shared/escalation-codes.md:298:- **Trigger:** Open Banking PSD2 consent approaching 90-day expiry. Three stages:
agents/_shared/escalation-codes.md:312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
agents/_shared/escalation-codes.md:319:- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
agents/_shared/escalation-codes.md:326:- **Trigger:** Generic upstream provider read failure (Companies House, web-scraper, any non-Bullhorn-non-Accounting GET) after retry budget exhausted; distinct from rate-limit
agents/_shared/escalation-codes.md:333:- **Trigger:** External send (Gmail / Outlook / Twilio / Telegram-to-customer) returned 5xx or transport error after retry budget
agents/_shared/escalation-codes.md:343:- **Trigger:** Orange-tier action has been pending operator response for ≥50% of declared `timeout` (heartbeat reminder before bridge timeout)
agents/_shared/escalation-codes.md:350:- **Trigger:** Orange-tier action exceeded its `timeout` (default PT4H) without operator approve/reject
agents/_shared/escalation-codes.md:358:- **Trigger:** A send is about to fire when the underlying state has changed in a way that should suppress it. Two canonical use cases:
agents/_shared/escalation-codes.md:368:- **Trigger:** Yellow-tier action was sampled per `sample_rate` (1-in-N) for post-hoc human review; sampling is informational + drives ongoing quality monitoring
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:377:#### `ESC_GATE_B_MISS`
agents/_shared/escalation-codes.md:379:- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
agents/_shared/escalation-codes.md:387:- **Trigger:** Output drafted by an agent matches a tenant-defined `tone_rule` violation pattern (e.g. tenant prohibits "absolutely" in customer-facing comms; output contained it)
agents/_shared/escalation-codes.md:395:- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
agents/_shared/escalation-codes.md:402:- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
agents/_shared/escalation-codes.md:409:- **Trigger:** Outbound recipient resolution failed — addressee does not match the entity whose lifecycle/event triggered the send. Two canonical use cases:
agents/_shared/escalation-codes.md:419:- **Trigger:** Bank-feed payment line cannot be matched to a single Xero invoice; multiple candidates within tolerance
agents/_shared/escalation-codes.md:424:#### `ESC_DNC_FILTER_HIT`
agents/_shared/escalation-codes.md:426:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
agents/_shared/escalation-codes.md:433:- **Trigger:** Concierge SLA breached. Three canonical sla_types:
agents/_shared/escalation-codes.md:443:- **Trigger:** Scribe SLA breached (default: call summary rendered within 30 min of call end; Bullhorn note attached within 1h)
agents/_shared/escalation-codes.md:450:- **Trigger:** Lifecycle state is ambiguous or outside the agent's known taxonomy. Two canonical use cases:
agents/_shared/escalation-codes.md:466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
packages/agents-runtime/_shared/common-voice.json:26:      "description": "Phrases that trigger ESC_VOICE_DRIFT before classifier scoring."
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
packages/agents-runtime/_shared/common-voice.json:46:      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."
docs/verticals/recruitment/vertical-schema.yaml:14:#       + Day-5 v1.0-kill-criterion.md (Trigger 1 acquisition-by-2026-06-03)
docs/verticals/recruitment/vertical-schema.yaml:55:      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:100:      date_last_modified_at:
docs/verticals/recruitment/vertical-schema.yaml:141:        source: IFOS-derived (set by Sourcing Scout at first-touch)
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:349:      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:420:      date_last_modified_at:
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
docs/verticals/recruitment/vertical-schema.yaml:526:      date_last_modified_at:
docs/verticals/recruitment/vertical-schema.yaml:637:    v1_0_exercise: Sourcing Scout captures at first-touch when relevant; not heavily exercised in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:841:    revisit_trigger: Skill-matching accuracy from Sourcing Scout's first 4 tenant-weeks of operation; if free-text matching produces <60% precision, canonical skill taxonomy lands as v1.1.
docs/verticals/recruitment/vertical-schema.yaml:893:    target: Week-4-end (~2026-06-21 if Week 1 starts 2026-05-21 per Day-5 kill criterion §2 Trigger 1 calendar).
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
packages/utilities/web-scraper/pnpm-lock.yaml:190:    resolution: {integrity: sha512-RVyzfb3FWsGA55n6WY0MEIEPURL1FcbhFE6BffZEMEekfCzCIMtB5yyDcFnVbTnwk+CLAgTujmV/Lgvih56W+A==}
packages/utilities/web-scraper/pnpm-lock.yaml:196:    resolution: {integrity: sha512-bPb5AHZtbeNGjCKVZ9UGqGwo8EUu4cLq68E95A53KlxAPRmUyYv2D6F0uUI65XisGOL1hBP5mTronbgo+0bFcA==}
packages/utilities/web-scraper/pnpm-lock.yaml:364:    resolution: {integrity: sha512-nU1yhmYutL+fQ71Kxnhg8uEOdC0pwEW9entHykTgEbna2pw2dkbFSMeqjjyHZoCmt8SBkOSvV+yNmm94aUrrqw==}
packages/utilities/web-scraper/pnpm-lock.yaml:533:    resolution: {integrity: sha512-J3Yh9PzzF1Ovah2At+lHiGQdsYgArxBbXv/zHfSyaiFQEqvNv7DcW98pCrmdjCZBrqBiKrKKe2V+aaSGWuBe/w==}
packages/utilities/web-scraper/pnpm-lock.yaml:557:    resolution: {integrity: sha512-nbJnQ8a3z1mtmrwImCYhc6BGpThAyYVRQxw9uKSKG4wR6aAYno9sVjJ0zaZcW9BPJX1GbrDPf+SvdWjgTuDmnw==}
packages/utilities/web-scraper/pnpm-lock.yaml:587:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:593:    resolution: {integrity: sha512-Boiz5+MsaROEWDf+GGEwF8VMHGhlUoQMtIPjOgA5fv4osupqTVnJteQNKJwUcnUog2G55jYXH7KZFFiJe0TEzQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:638:    resolution: {integrity: sha512-GhdPgy1el4/ImP05X05Uw4cw2/M93BCUmnEvWZNStlCzEKME4Fkk+YpoA5OiHNQmoS7Cafb8Xa3Pya8m1Qrzeg==}
packages/utilities/web-scraper/pnpm-lock.yaml:825:    resolution: {integrity: sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==}
packages/harness/cortextos/templates/orchestrator/GUARDRAILS.md:9:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/orchestrator/GUARDRAILS.md:19:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/orchestrator/GUARDRAILS.md:46:| Trigger | Red Flag Thought | Required Action |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:123:4. Founder runs the kill-criterion Trigger 5 query (autosend-safety-policy §7):
agents/_shared/README.md:130:5. Report result back. If row count > 3 in a 7-day window, kill-criterion Trigger 5 fires (per `v1.0-kill-criterion.md` §2 Trigger 5).
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
agents/_shared/README.md:178:- `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 5 — red-tier breach kill criterion
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
agents/_shared/tests/test-hook-helpers.sh:283:printf '\n[16] Kill-criterion Trigger 5 verification: red-tier audit query shape\n'
agents/_shared/tests/test-hook-helpers.sh:288:  # Kill-criterion Trigger 5 monitoring query filters by payload.tier='red'
agents/_shared/tests/test-hook-helpers.sh:303:_test_run "kill-criterion Trigger 5: red-tier rows queryable by tier+phase" test_kill_criterion_trigger5
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:79:-- is the indexed surface for hh_load_voice_samples semantic retrieval.
packages/harness/cortextos/scripts/install-windows-pm2-startup.ps1:70:# Trigger at the current user's logon. AtLogon (not AtStartup) avoids needing
packages/harness/cortextos/scripts/install-windows-pm2-startup.ps1:73:$trigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
packages/harness/cortextos/scripts/install-windows-pm2-startup.ps1:96:    -Trigger $trigger `
packages/harness/cortextos/scripts/install-windows-pm2-startup.ps1:103:Write-Host "      Trigger:   At logon ($env:USERDOMAIN\$env:USERNAME)"
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
packages/harness/cortextos/templates/hermes/GUARDRAILS.md:9:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/hermes/GUARDRAILS.md:19:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/hermes/GUARDRAILS.md:45:| Trigger | Red Flag Thought | Required Action |
docs/_archive-build-pack/06-BUILD-PLAN.md:227:- Trigger: when a tenant moves from PROVISIONING to ACTIVE, spawn its daemon
agents/recruitment/cash-conductor/agent.md:6:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:123:| Position | Trigger | Tone | Voice classifier minimum |
agents/recruitment/cash-conductor/agent.md:221:   → ESC_VOICE_DRIFT if classifier <threshold after 3 retries
agents/recruitment/cash-conductor/agent.md:232:       `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint failure)
agents/recruitment/cash-conductor/agent.md:306:Gate A failures fire either `ESC_AGENT_OUTPUT_SHAPE` (invoice/amount/paid-precondition miss; output-shape constraint) OR `ESC_ADDRESSEE_MISMATCH` (client_contact_email mismatch; blocking per catalogue §2.10 — explicit Cash Conductor invoice/chase addressee case). Draft stays in `/tmp` (auto-purged 24h); operator notified per the specific ESC route.
agents/recruitment/cash-conductor/agent.md:318:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:326:| Code | Trigger | Severity | Routing |
agents/recruitment/cash-conductor/agent.md:335:| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:336:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in chase body | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:337:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss on invoice_number / amount_due / paid-invoice-precondition (NOT addressee mismatch — that uses ESC_ADDRESSEE_MISMATCH) | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:339:| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
agents/recruitment/cash-conductor/agent.md:340:| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:346:- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
agents/recruitment/cash-conductor/agent.md:348:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Cash Conductor fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/cash-conductor/agent.md:356:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:360:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/cash-conductor/agent.md:361:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/guardrails-reference/SKILL.md:14:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/guardrails-reference/SKILL.md:50:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/src/daemon/fast-checker.ts:147:   * Trigger immediate wake from sleep.
packages/harness/cortextos/package-lock.json:1184:      "integrity": "sha512-HHMwmarRKvoFsJorqYlFeFRzXZqCt2ETQlEDOb9aqssrnVBB1/+xgTGtuTrIk5vzLNX1MjMtTf7W9z3tsSbrxw==",
packages/harness/cortextos/package-lock.json:1345:      "integrity": "sha512-4LqhUomJqwe641gsPp6xLfhqWMbQV04KtPp7/dIp0nzPxAkNY1AbwL5W0MQpcalLYk07vaW9Kp1PBhdpZYYcEw==",
packages/harness/cortextos/package-lock.json:2605:      "integrity": "sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==",
packages/harness/cortextos/package-lock.json:2640:      "integrity": "sha512-C8oWjPR3F81yljW9o5OxcWzfh6avkVwDD2VYdwIGqTkl+OGFISgypqzfu7dOe4QNLL2aqcWBmI3PMtLIK233lw==",
packages/harness/cortextos/templates/orchestrator/.claude/skills/guardrails-reference/SKILL.md:19:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/orchestrator/.claude/skills/guardrails-reference/SKILL.md:55:| Trigger | Red Flag Thought | Required Action |
agents/recruitment/scribe/agent.md:6:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:109:Length cap: 800 words. Voice-classified (≥0.75); falls back to "needs consultant review" placeholder if classifier persistently fails (ESC_VOICE_DRIFT).
agents/recruitment/scribe/agent.md:143:   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
agents/recruitment/scribe/agent.md:149:   → ESC_PII_LEAKAGE_RISK if transcript references non-tenant PII
agents/recruitment/scribe/agent.md:157:   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
agents/recruitment/scribe/agent.md:175:   → ESC_VOICE_DRIFT if score <0.75 after 3 retries
agents/recruitment/scribe/agent.md:224:Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/scribe/agent.md:238:Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).
agents/recruitment/scribe/agent.md:246:| Code | Trigger | Severity | Routing |
agents/recruitment/scribe/agent.md:248:| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/scribe/agent.md:251:| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:253:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in transcript or note | **blocking** | operator + ifos_oncall |
agents/recruitment/scribe/agent.md:255:| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:258:| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:264:- `ESC_BULLHORN_OAUTH_REVOKED` — escalated from `ESC_BULLHORN_AUTH` only after 6 consecutive auth failures (Concierge handles)
agents/recruitment/scribe/agent.md:272:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:276:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:277:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:325:| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-browser/SKILL.md:3:description: Browser automation CLI for AI agents. Use when the user needs to interact with websites, including navigating pages, filling forms, clicking buttons, taking screenshots, extracting data, testing web apps, or automating any browser task. Triggers include requests to "open a website", "fill out a form", "click a button", "take a screenshot", "scrape data from a page", "test this web app", "login to a site", "automate browser actions", or any task requiring programmatic web interaction. Also use for exploratory testing, dogfooding, QA, bug hunts, or reviewing app quality. Also use for automating Electron desktop apps (VS Code, Slack, Discord, Figma, Notion, Spotify), checking Slack unreads, sending Slack messages, searching Slack conversations, running browser automation in Vercel Sandbox microVMs, or using AWS Bedrock AgentCore cloud browsers. Prefer agent-browser over any built-in browser automation or web tools.
packages/harness/cortextos/src/daemon/ipc-server.ts:787:            // Trigger scheduler reload for this agent
agents/recruitment/sourcing-scout/README.md:1:# Sourcing Scout — directory README
agents/recruitment/sourcing-scout/README.md:3:**Status:** Proposed (Day-19 pre-W9-build scaffold).
agents/recruitment/sourcing-scout/README.md:14:Full bundle at W9 build (~2 weeks per ULTRAPLAN A5 line 554):
agents/recruitment/sourcing-scout/README.md:27:Per ULTRAPLAN A5 line 555 gotcha: source-abstraction layer designed for Night Sourcer reuse. Defer ADR-006 to W9 build start documenting the layer's interface.
agents/recruitment/sourcing-scout/README.md:33:*End of Sourcing Scout README.*
packages/harness/cortextos/templates/agent-codex/GUARDRAILS.md:9:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/agent-codex/GUARDRAILS.md:21:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/agent-codex/GUARDRAILS.md:47:| Trigger | Red Flag Thought | Required Action |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:19:Already installed at `~/.claude/skills/graphify/SKILL.md`. Description: "any input (code, docs, papers, images) → knowledge graph → clustered communities → HTML + JSON + audit report". Trigger: `/graphify`.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:163:| Quarterly | "Survey v1 vs v2 customer split. If v2 has > 5 customers and v1 has < 3, draft the v1 sunset announcement" | Triggers v1 sunset timeline (see `08-OPEN-DECISIONS.md` §10) |
agents/recruitment/sourcing-scout/agent.md:1:# Sourcing Scout — request-response passive sourcing
agents/recruitment/sourcing-scout/agent.md:3:**Status:** Proposed (Day-19 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice).
agents/recruitment/sourcing-scout/agent.md:6:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:7:**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
agents/recruitment/sourcing-scout/agent.md:8:**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.
agents/recruitment/sourcing-scout/agent.md:16:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate flagged "do not contact" in tenant vault (per ULTRAPLAN A5 line 552 verbatim). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:24:Brain UI v1.0 "Source candidates" button on any brief detail page → POST internal API → Sourcing Scout webhook.
agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
agents/recruitment/sourcing-scout/agent.md:57:# Sourcing Scout — <Brief title>
agents/recruitment/sourcing-scout/agent.md:98:Voice-classified content: only the per-candidate match rationale (Step 9). Voice classifier ≥0.75 against tenant style. Rationale that fails after 3 retries → ESC_VOICE_DRIFT → candidate dropped from list + flagged in exception list.
agents/recruitment/sourcing-scout/agent.md:116:   → ESC_BRIEF_AMBIGUITY if extraction yields <3 key dimensions (per
agents/recruitment/sourcing-scout/agent.md:124:     ESC_BULLHORN_AUTH | ESC_LINKEDIN_AUTH | ESC_REED_AUTH | ESC_CVLIBRARY_AUTH
agents/recruitment/sourcing-scout/agent.md:126:     ANY source is down, Sourcing Scout halts (any failed source = blocked
agents/recruitment/sourcing-scout/agent.md:135:     status='active', date_last_modified_at < now() - interval '90 days')
agents/recruitment/sourcing-scout/agent.md:138:     candidate.status as [active, archived, do_not_contact, placed,
agents/recruitment/sourcing-scout/agent.md:139:     contractor_promoted] (line 84-88) and candidate.date_last_modified_at
agents/recruitment/sourcing-scout/agent.md:143:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
agents/recruitment/sourcing-scout/agent.md:151:   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
agents/recruitment/sourcing-scout/agent.md:157:   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:164:   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:178:   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
agents/recruitment/sourcing-scout/agent.md:180:     `send_to_blocked_recipient`; canonical Postgres-stored structured
agents/recruitment/sourcing-scout/agent.md:184:   → NOTE: ESC_DNC_FILTER_HIT is catalogue §2.10 reserved for OUTBOUND SEND
agents/recruitment/sourcing-scout/agent.md:185:     REFUSAL specifically. Sourcing Scout filters DNC matches AT SOURCING
agents/recruitment/sourcing-scout/agent.md:197:   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
agents/recruitment/sourcing-scout/agent.md:207:    → if any condition fails: ESC_AGENT_OUTPUT_SHAPE (output-shape violation
agents/recruitment/sourcing-scout/agent.md:228:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
agents/recruitment/sourcing-scout/agent.md:238:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation per catalogue line 184); draft to `/tmp`; operator review.
agents/recruitment/sourcing-scout/agent.md:240:**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/sourcing-scout/agent.md:244:Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
agents/recruitment/sourcing-scout/agent.md:246:Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.
agents/recruitment/sourcing-scout/agent.md:248:Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
agents/recruitment/sourcing-scout/agent.md:250:Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
agents/recruitment/sourcing-scout/agent.md:256:Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/sourcing-scout/agent.md:258:| Code | Trigger | Severity | Routing |
agents/recruitment/sourcing-scout/agent.md:260:| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (per catalogue §2.3) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:261:| `ESC_LINKEDIN_AUTH` | LinkedIn / Proxycurl session/OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:262:| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:263:| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:264:| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:265:| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:266:| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:267:(Sourcing Scout does NOT use `ESC_DNC_FILTER_HIT` — per catalogue §2.10 that code is reserved for outbound send refusal; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops are logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish adds ESC_SOURCING_DNC_FILTER.)
agents/recruitment/sourcing-scout/agent.md:268:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:269:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:270:| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | founder + operator |
agents/recruitment/sourcing-scout/agent.md:272:Sourcing Scout does NOT use:
agents/recruitment/sourcing-scout/agent.md:276:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
agents/recruitment/sourcing-scout/agent.md:277:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/sourcing-scout/agent.md:285:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:290:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:291:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
agents/recruitment/sourcing-scout/agent.md:297:## §8 — Build dependencies (W9 prerequisites)
agents/recruitment/sourcing-scout/agent.md:299:Sourcing Scout build cannot start until ALL of the following are confirmed:
agents/recruitment/sourcing-scout/agent.md:312:| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:313:| Reed MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:314:| CV-Library MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:315:| Source-abstraction layer (Night Sourcer reuse) | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:319:| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:320:| `context.sh` hydration | Build at W9 start (~0.5 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:321:| `cycle.sh` orchestration (11-step) | Build at W9 start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:322:| 3 fixtures with golden outputs | Build at W9 start (~1 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:324:**Until ALL ⏸ items resolve to ✅, W9 build slice does not start.**
agents/recruitment/sourcing-scout/agent.md:330:**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:338:| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
agents/recruitment/sourcing-scout/agent.md:339:| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
agents/recruitment/sourcing-scout/agent.md:341:| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
agents/recruitment/sourcing-scout/agent.md:342:| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `last_activity_at < now() - 90 days` to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side activity-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |
agents/recruitment/sourcing-scout/agent.md:344:### Gotchas (carried forward from ULTRAPLAN A5 line 555)
agents/recruitment/sourcing-scout/agent.md:347:2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
agents/recruitment/sourcing-scout/agent.md:363:- W9 build slice produces all 5 sibling bundle files + 3 fixtures
agents/recruitment/sourcing-scout/agent.md:370:*End of Sourcing Scout agent.md draft.*
packages/harness/cortextos/templates/orchestrator/.claude/skills/goal-management/SKILL.md:3:description: "Daily goal lifecycle management. Use for: morning briefing goal cascade, setting daily focus, refreshing agent goals, reviewing goal progress. Triggered daily as part of morning review."
packages/harness/cortextos/templates/agent/.claude/skills/guardrails-reference/SKILL.md:19:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/agent/.claude/skills/guardrails-reference/SKILL.md:55:| Trigger | Red Flag Thought | Required Action |
agents/recruitment/janitor/agent.md:6:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:90:   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
agents/recruitment/janitor/agent.md:97:   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per §1.1.2 of v0.2 supplement)
agents/recruitment/janitor/agent.md:126:   → ESC_RATE_LIMIT_HIT on 429
agents/recruitment/janitor/agent.md:141:     (voice corpus + tone rules; ESC_VOICE_DRIFT if classifier <0.75)
agents/recruitment/janitor/agent.md:168:   → exit code 0 (or 1 if Gate-B missed for 3 consecutive runs → ESC_GATE_B_MISS)
agents/recruitment/janitor/agent.md:187:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint; per Day-19 catalogue add at `escalation-codes.md` line 184) OR `ESC_DUPLICATE_DETECTED` (merge-confidence reject; existing line 127) per the failed condition. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (line 163) is NOT used by Janitor — that code is reserved for vertical-schema field-constraint violations at write-time.
agents/recruitment/janitor/agent.md:195:Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
agents/recruitment/janitor/agent.md:197:Failing either threshold for 3 consecutive runs → fire `ESC_GATE_B_MISS` → flag for operator review (heuristic tuning may be needed; not a kill).
agents/recruitment/janitor/agent.md:205:| Code | Trigger | Severity | Routing |
agents/recruitment/janitor/agent.md:207:| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
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
agents/recruitment/janitor/agent.md:249:| First pilot tenant onboarded (provision-tenant.sh) | Post Q1-LOI | ⏸ Founder action; Trigger 1 fires 2026-06-03 if no LOI |
agents/recruitment/janitor/agent.md:263:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
packages/agent-renderer/pnpm-lock.yaml:202:    resolution: {integrity: sha512-RVyzfb3FWsGA55n6WY0MEIEPURL1FcbhFE6BffZEMEekfCzCIMtB5yyDcFnVbTnwk+CLAgTujmV/Lgvih56W+A==}
packages/agent-renderer/pnpm-lock.yaml:208:    resolution: {integrity: sha512-bPb5AHZtbeNGjCKVZ9UGqGwo8EUu4cLq68E95A53KlxAPRmUyYv2D6F0uUI65XisGOL1hBP5mTronbgo+0bFcA==}
packages/agent-renderer/pnpm-lock.yaml:376:    resolution: {integrity: sha512-nU1yhmYutL+fQ71Kxnhg8uEOdC0pwEW9entHykTgEbna2pw2dkbFSMeqjjyHZoCmt8SBkOSvV+yNmm94aUrrqw==}
packages/agent-renderer/pnpm-lock.yaml:545:    resolution: {integrity: sha512-J3Yh9PzzF1Ovah2At+lHiGQdsYgArxBbXv/zHfSyaiFQEqvNv7DcW98pCrmdjCZBrqBiKrKKe2V+aaSGWuBe/w==}
packages/agent-renderer/pnpm-lock.yaml:569:    resolution: {integrity: sha512-nbJnQ8a3z1mtmrwImCYhc6BGpThAyYVRQxw9uKSKG4wR6aAYno9sVjJ0zaZcW9BPJX1GbrDPf+SvdWjgTuDmnw==}
packages/agent-renderer/pnpm-lock.yaml:599:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}
packages/agent-renderer/pnpm-lock.yaml:605:    resolution: {integrity: sha512-Boiz5+MsaROEWDf+GGEwF8VMHGhlUoQMtIPjOgA5fv4osupqTVnJteQNKJwUcnUog2G55jYXH7KZFFiJe0TEzQ==}
packages/agent-renderer/pnpm-lock.yaml:650:    resolution: {integrity: sha512-GhdPgy1el4/ImP05X05Uw4cw2/M93BCUmnEvWZNStlCzEKME4Fkk+YpoA5OiHNQmoS7Cafb8Xa3Pya8m1Qrzeg==}
packages/agent-renderer/pnpm-lock.yaml:871:    resolution: {integrity: sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==}
agents/recruitment/diagnostic/cleanup.sh:57:    '{"escalation_code":"ESC_PII_LEAKAGE_RISK","reason":"LinkedIn cache purge incomplete"}' \
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
packages/harness/cortextos/templates/agent/.claude/skills/agent-browser/SKILL.md:3:description: Browser automation CLI for AI agents. Use when the user needs to interact with websites, including navigating pages, filling forms, clicking buttons, taking screenshots, extracting data, testing web apps, or automating any browser task. Triggers include requests to "open a website", "fill out a form", "click a button", "take a screenshot", "scrape data from a page", "test this web app", "login to a site", "automate browser actions", or any task requiring programmatic web interaction. Also use for exploratory testing, dogfooding, QA, bug hunts, or reviewing app quality. Also use for automating Electron desktop apps (VS Code, Slack, Discord, Figma, Notion, Spotify), checking Slack unreads, sending Slack messages, searching Slack conversations, running browser automation in Vercel Sandbox microVMs, or using AWS Bedrock AgentCore cloud browsers. Prefer agent-browser over any built-in browser automation or web tools.
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:7:# ESC_VOICE_DRIFT row emitted, draft NOT written to vault.
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:9:# Per kill-criterion §2 Trigger 5 + agent.md §6: voice drift is an
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:69:  - escalation_code: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:87:    - "ESC_VOICE_DRIFT"
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:739:            &middot; <a href="#">ESC_BRIEF_AMBIGUITY</a> raised to <a href="#">Sarah Whittaker</a>
packages/harness/cortextos/templates/orchestrator/.claude/skills/evening-review/SKILL.md:3:description: "End-of-day review workflow. Triggered by evening cron. Summarizes the day across all agents, evaluates orchestrator performance, prepares tomorrow, proposes overnight work for approval."
packages/harness/cortextos/templates/orchestrator/.claude/skills/evening-review/SKILL.md:272:## Manual Trigger
packages/harness/cortextos/templates/agent/GUARDRAILS.md:9:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/agent/GUARDRAILS.md:19:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/agent/GUARDRAILS.md:45:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-browser/SKILL.md:3:description: Browser automation CLI for AI agents. Use when the user needs to interact with websites, including navigating pages, filling forms, clicking buttons, taking screenshots, extracting data, testing web apps, or automating any browser task. Triggers include requests to "open a website", "fill out a form", "click a button", "take a screenshot", "scrape data from a page", "test this web app", "login to a site", "automate browser actions", or any task requiring programmatic web interaction. Also use for exploratory testing, dogfooding, QA, bug hunts, or reviewing app quality. Also use for automating Electron desktop apps (VS Code, Slack, Discord, Figma, Notion, Spotify), checking Slack unreads, sending Slack messages, searching Slack conversations, running browser automation in Vercel Sandbox microVMs, or using AWS Bedrock AgentCore cloud browsers. Prefer agent-browser over any built-in browser automation or web tools.
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:3:description: "Daily morning briefing workflow. Triggered by morning cron. Pulls overnight agent work, checks goals state, cascades goals to agents, schedules tasks, sends briefing to user."
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:313:## Manual Trigger
agents/recruitment/diagnostic/cycle.sh:163:    '{"escalation_code":"ESC_AGENT_OUTPUT_SHAPE","agent_name":"diagnostic","shape_rule_violated":"non_empty_output","expected_value":"non-empty stdout","actual_value":"empty"}' >/dev/null
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
docs/architecture/tenancy-invariants.md:247:| # | Question | Trigger to resolve |
packages/harness/cortextos/templates/analyst/.claude/skills/guardrails-reference/SKILL.md:19:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/analyst/.claude/skills/guardrails-reference/SKILL.md:38:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/analyst/.claude/skills/guardrails-reference/SKILL.md:63:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/orchestrator/.claude/skills/weekly-review/SKILL.md:203:## Manual Trigger
agents/recruitment/diagnostic/tools.yaml:42:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:77:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:137:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:140:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:165:        escalation: ESC_RATE_LIMIT_HIT
docs/architecture/architecture-cohesion-review.md:34:| **Helpers + storage** | vault-concurrency.md (locks + version), v0.1 schema, v0.2 supplement, kill-criterion.md (Trigger 5 audit) |
docs/architecture/architecture-cohesion-review.md:92:| A5 | **The cortextOS daemon `discoverAgents()` filters by directory pattern, not contents.** Means `.tmp.<pid>/` + `.prev.<ts>/` dirs are invisible. | ADR-003 §3.3.4 atomic-write protocol | If daemon scan ever changes to content-based discovery, the atomic-write protocol could expose half-rendered state. Verified against pinned SHA `c21fbfe`. |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:225:| # | Issue | Severity | Resolution path | Owner | Trigger |
agents/recruitment/diagnostic/validate.sh:234:  #   - PII detected outside firm boundary → ESC_PII_LEAKAGE_RISK (blocking)
agents/recruitment/diagnostic/validate.sh:235:  #   - Voice classifier score <0.75 (V3) → ESC_VOICE_DRIFT (warn, per
agents/recruitment/diagnostic/validate.sh:238:  #     length) → ESC_AGENT_OUTPUT_SHAPE (warn)
agents/recruitment/diagnostic/validate.sh:253:    ESC_CODE="ESC_PII_LEAKAGE_RISK"
agents/recruitment/diagnostic/validate.sh:255:    ESC_CODE="ESC_VOICE_DRIFT"
agents/recruitment/diagnostic/validate.sh:257:    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"
packages/mcp-connectors/companies-house/README.md:34:| 429 | Rate limited; back off 60s, retry once | ESC_RATE_LIMIT_HIT |
agents/recruitment/diagnostic/context.sh:29:#   - Missing voice corpus → exit 1 with ESC_VOICE_DRIFT (no fallback for
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:195:## Build wave: v1.0 weeks 10-13
docs/architecture/agent-bundle-renderer-design.md:219:  - ESC_VOICE_DRIFT
docs/architecture/agent-bundle-renderer-design.md:220:  - ESC_PII_LEAKAGE_RISK
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:270:        "ESC_VOICE_DRIFT": { "type": "string", "format": "telegram-chat-id" }
docs/architecture/agent-bundle-renderer-design.md:322:hh_load_tone_rules
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:392:PII is a `ESC_PII_LEAKAGE_RISK` escalation. Voice samples and tone rules in
docs/architecture/agent-bundle-renderer-design.md:423:    "ESC_VOICE_DRIFT": "<acme operator chat id from _secrets.env>"
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
agents/recruitment/diagnostic/agent.md:6:**Build wave:** v1.0 W3-4 per master brief §8.2 line 595 (row 1; anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`. **Drift flag:** Ultraplan §8.1 A1 (line 489) calls Diagnostic build wave 4-5; master brief line 595 calls it W3-4. Master brief is authoritative per CLAUDE.md (master brief wins on every conflict); W3-4 is the build wave for IFOS.
agents/recruitment/diagnostic/agent.md:107:     payload {escalation_code: ESC_AGENT_OUTPUT_SHAPE, ...}; exit 1
agents/recruitment/diagnostic/agent.md:108:   → v0 NOTE: rate-limit catches (429 → ESC_RATE_LIMIT_HIT) and per-section retry logic are NOT implemented at v0 cycle.sh; W4 polish adds 429 catch + retry-with-backoff to cycle.sh. v0 generator throws-and-exits on upstream errors; validate.sh catches Gate A failure downstream.
agents/recruitment/diagnostic/agent.md:109:   → v0 NOTE: per-§12 LLM voice classifier retry loop is NOT implemented in generator at v0 (§12 stub-via-Companies-House fallback). Voice classification happens at validate.sh V3 (single call to IFOS_VOICE_CLASSIFIER_URL when set; warn + exit 0 when unset/unreachable). W4 polish adds full LLM §12 pipeline with 3-retry classifier loop and explicit ESC_VOICE_DRIFT emission in the generator.
agents/recruitment/diagnostic/agent.md:118:     with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE for
agents/recruitment/diagnostic/agent.md:119:     section count / citation / length failures; ESC_VOICE_DRIFT for V3
agents/recruitment/diagnostic/agent.md:120:     voice-classifier-score-low failures; ESC_PII_LEAKAGE_RISK for PII
agents/recruitment/diagnostic/agent.md:154:- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
agents/recruitment/diagnostic/agent.md:156:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
agents/recruitment/diagnostic/agent.md:157:- No PII (emails) outside the firm boundary. **v0 behavior:** validate.sh runs a generic email-regex pass and warns on any email found (no firm-domain whitelist implemented in v0; warn-only; exit 0). W4 polish adds the firm-domain whitelist + hard-fail behavior + `ESC_PII_LEAKAGE_RISK` emission. **v0 PII coverage:** emails only via regex; phone-number PII detection + whitelist enforcement deferred to W4 polish.
agents/recruitment/diagnostic/agent.md:163:Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
agents/recruitment/diagnostic/agent.md:171:| Code | Trigger | Severity | Routing |
agents/recruitment/diagnostic/agent.md:173:| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:174:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/diagnostic/agent.md:175:| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn 429 | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:177:| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing OR generator produced empty stdout (Step 8 fallback) | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:182:- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
agents/recruitment/diagnostic/agent.md:192:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:196:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
agents/recruitment/diagnostic/agent.md:197:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
agents/recruitment/diagnostic/agent.md:212:| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
agents/recruitment/concierge/agent.md:6:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:153:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
agents/recruitment/concierge/agent.md:154:     ESC_BULLHORN_AUTH on auth fail
agents/recruitment/concierge/agent.md:190:   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries
agents/recruitment/concierge/agent.md:215:    → ESC_PII_LEAKAGE_RISK on hit (blocking)
agents/recruitment/concierge/agent.md:253:    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
agents/recruitment/concierge/agent.md:269:- No PII outside firm boundary — hard-fail (ESC_PII_LEAKAGE_RISK)
agents/recruitment/concierge/agent.md:275:Gate A failures fire `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` or `ESC_PII_LEAKAGE_RISK` or `ESC_CANDIDATE_DATA_INCOMPLETE` or `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint when voice threshold misses persistently) — all blocking; draft to `/tmp`; operator notified immediately.
agents/recruitment/concierge/agent.md:287:Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
agents/recruitment/concierge/agent.md:295:| Code | Trigger | Severity | Routing |
agents/recruitment/concierge/agent.md:297:| `ESC_BULLHORN_AUTH` | OAuth refresh fails (payload.failure_type='refresh_failed' or 'revoked_401' covers the 6+ consecutive failure case) | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:298:| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:304:| `ESC_VOICE_DRIFT` | Voice classifier below position-specific threshold after 3 retries | warn (position 1-2) or **blocking** (position 3) | operator_chat_id (1-2) / operator + ifos_oncall (position 3) |
agents/recruitment/concierge/agent.md:306:| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:310:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:311:| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% for 30 consecutive days | warn | founder + operator |
agents/recruitment/concierge/agent.md:319:- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
agents/recruitment/concierge/agent.md:321:- `ESC_VOICE_DRIFT_TENANT` (direct firing) — that's fired by the nightly voice-drift cron per catalogue §2.5; Concierge fires only per-run `ESC_VOICE_DRIFT`.
agents/recruitment/concierge/agent.md:329:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
agents/recruitment/concierge/agent.md:336:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:337:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
packages/harness/cortextos/src/utils/ws-unix-client.ts:80:      .update(key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')
docs/architecture/cortexos-primitive-status.md:150:# Trigger Tier 3 more than the threshold within 15 min; expect "Context circuit breaker reset after 30min pause"
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
docs/architecture/second-brain-design.md:319:v1.0 skeleton: only what Sourcing Scout (A5) needs to source against — role title, client, sector, must-haves. Full v1.1 schema waits for Brief Decoder.
docs/architecture/second-brain-design.md:429:| `list-by-type-and-tenant` | Sourcing Scout (v1.0): enumerate Candidates for filtering; Brief Decoder (v1.1): enumerate open Briefs | v1.0 (Candidate, Client, Placement, Contact); v1.1 (Brief full enumeration) | `(entity_type: str, tenant_id: str, filters?: dict, limit?: int)` | `List[EntityRef]` | few seconds | Postgres-indexed; filtering matches `search-by-attribute` |
docs/architecture/second-brain-design.md:654:        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:774:| Sourcing Scout | 50:1 | reads briefs + candidate pool to filter; writes only shortlists |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:890:| **Multi-tenancy enforcement** — how `tenant_slug` is validated at the entry point (master brief §3.5) | Wrapper reads `CTX_TENANT_SLUG` env var (set by PM2 ecosystem per-tenant process group); CLI handler validates that the arg `--tenant` matches the env or fails with `ESC_PII_LEAKAGE_RISK`. Kernel-enforced isolation underneath (POSIX 0700 per Ultraplan §5.1) means a wrong tenant fails at filesystem read. | Server receives `CTX_TENANT_SLUG` at connection setup via MCP server args; rejects any tool call whose `tenant_slug` mismatches the connection identity. Filesystem isolation underneath same as α. One enforcement site. | Library validates `tenant_slug` against env var. Same enforcement model as α, but agent-side discipline depends on skill docs being followed. |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:47:### Issue 3 (RE-RAISE) — Gate B kill-criterion Trigger reference
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:49:**Codex says:** "Line 169 claims Diagnostic's 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:57:Option B — **Add a new kill-criterion Trigger 11 (DIAGNOSTIC-CONVERSION-FAIL).** Threshold: <30% discovery-call rate sustained for 4 weeks across all live pilots. Owner: founder + Jack.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:59:**My recommendation:** **A** for v0 — remove the trigger reference; Diagnostic conversion is local-metric tracking. Add Trigger 11 in v1.1 if conversion-rate-driven scope-cut becomes operationally relevant.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:122:| Sourcing Scout | ~5-7 (count regex 50) | `logs/codex-ratification/20260524T1024...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:216:3. `ESC_GATE_B_MISS` definition in §6 still says "Composite Gate-B score <12.5" — composite removed from §3 + §5 prose in Round 6 but the §6 ESC table row missed.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:261:- Cross-section consistency: removed (new — W-X catalogue add) annotations; ESC_AUTOSEND_BLOCKED kept red-tier-only; ESC_SCHEMA_VIOLATION kept schema-field-violation-only; ESC_VOICE_DRIFT_TENANT removed from direct firing across all agents; ESC_AUTOSEND_YELLOW_SPOT_CHECK → ESC_AUTOSEND_SAMPLED_SPOT_CHECK
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
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:392:3. ESC_DNC_FILTER_HIT used for shortlist filtering (pre-outbound), catalogue defines for outbound refusal — Cat-γ widening needed (similar to other 5 widened)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:419:4. **Catalogue v2 widening for ESC_DNC_FILTER_HIT + Sourcing Scout auth severity** — Cat-γ continuations
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:430:| Sourcing Scout | Pre-Build-Round-9-Reviewed | 5 (Cat-α Q7 + bullhorn-path conflict + Cat-γ DNC + Cat-ε per-candidate row + auth severity disagreement) | Mechanical Q7 fix + Bullhorn-path realignment + ESC widening 2 |
packages/mcp-connectors/companies-house/pnpm-lock.yaml:186:    resolution: {integrity: sha512-RVyzfb3FWsGA55n6WY0MEIEPURL1FcbhFE6BffZEMEekfCzCIMtB5yyDcFnVbTnwk+CLAgTujmV/Lgvih56W+A==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:192:    resolution: {integrity: sha512-bPb5AHZtbeNGjCKVZ9UGqGwo8EUu4cLq68E95A53KlxAPRmUyYv2D6F0uUI65XisGOL1hBP5mTronbgo+0bFcA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:360:    resolution: {integrity: sha512-nU1yhmYutL+fQ71Kxnhg8uEOdC0pwEW9entHykTgEbna2pw2dkbFSMeqjjyHZoCmt8SBkOSvV+yNmm94aUrrqw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:529:    resolution: {integrity: sha512-J3Yh9PzzF1Ovah2At+lHiGQdsYgArxBbXv/zHfSyaiFQEqvNv7DcW98pCrmdjCZBrqBiKrKKe2V+aaSGWuBe/w==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:553:    resolution: {integrity: sha512-nbJnQ8a3z1mtmrwImCYhc6BGpThAyYVRQxw9uKSKG4wR6aAYno9sVjJ0zaZcW9BPJX1GbrDPf+SvdWjgTuDmnw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:583:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:589:    resolution: {integrity: sha512-Boiz5+MsaROEWDf+GGEwF8VMHGhlUoQMtIPjOgA5fv4osupqTVnJteQNKJwUcnUog2G55jYXH7KZFFiJe0TEzQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:634:    resolution: {integrity: sha512-GhdPgy1el4/ImP05X05Uw4cw2/M93BCUmnEvWZNStlCzEKME4Fkk+YpoA5OiHNQmoS7Cafb8Xa3Pya8m1Qrzeg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:821:    resolution: {integrity: sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==}
docs/operations/bullhorn-outreach-emails.md:17:**These don't block today.** They block **Janitor W5 build** (per kill-criterion §2 Trigger 3). You have ~5 weeks of runway. But send today/Monday because Bullhorn's response time is 2-5 business days, and we want the answers before Diagnostic W3-4 completes so Janitor W5 starts unblocked.
docs/operations/bullhorn-outreach-emails.md:74:- If they require marketplace membership before production access → Sub-decision A is **Marketplace**; need cost + timeline to assess against kill-criterion §2 Trigger 3 (Janitor W5 deadline).
docs/runbooks/day-4-provisioning.md:1212:3. **§2 location — NBG1 substituted for FSN1:** FSN1 unavailable at provisioning time. Substituted Nuremberg (NBG1) — same Hetzner eu-central zone, identical Schrems II EU jurisdiction (German court orders only), latency to UK ~25-30ms vs FSN1 ~20-25ms (functionally equivalent). **Triggers §11.4 master-brief Edit 9:** master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations". (Earlier drafts of Edit 9 also referenced master brief §10.4; verified during 2026-05-18 citation audit that §10.4 is the Codex exclusion list, not a Hetzner or cost-target section. §10.4 component dropped.)
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:401:| Code | Trigger | Decision_log phase | Operator surface |
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/architecture/vault-concurrency.md:438:| `_shared/hook-helpers.sh` wires 5 new `ESC_VAULT_*` codes (in addition to `ESC_BULLHORN_AUTH` + `ESC_RENDERER_FAILED`) | Week 1-2 | Claude Code | `current-priorities.md` Week-1 prereq #3 + §6 of this document |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:31:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:43:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:83:- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:121:- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:58:**Cost of delay:** Trigger 1 fires 2026-06-03 if no LOI. If LOI lands but advisor isn't engaged, founder has to choose between violating kill-criterion §3.4 or delaying LOI past Trigger 1. Engage now to avoid the forced choice.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:80:**Cost of delay:** Same as D2 — Trigger 1 fires 2026-06-03. If LOI lands before D3 resolves, founder ships v1.0 with D3-A indefinite retention, which is the worst legal posture. Bundle D2 + D3 resolution.
docs/runbooks/operational-hygiene-protocol.md:276:| `docs/decisions/v1.0-kill-criterion.md` | 3 | Same cost-target replacement for Trigger 6/7 source citations |
docs/operations/codex-round-2-handoff.md:82:| 11 | `docs/decisions/v1.0-kill-criterion.md` | Trigger 1 date + Trigger 2 CLI + Trigger 4 threshold | RATIFY (all three fixed) |
docs/build-brief/00-MASTER-BRIEF.md:119:| 7 | Multi-agent orchestrator | `orchestrator` template + file-bus handoff contract | Brief Decoder → Sourcing Scout → Concierge pipeline lives here |
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:580:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/build-brief/00-MASTER-BRIEF.md:581:- `ESC_BULLHORN_AUTH` — OAuth token expired/revoked
docs/build-brief/00-MASTER-BRIEF.md:584:- `ESC_BRIEF_AMBIGUITY` — Brief Decoder cannot confidently shortlist
docs/build-brief/00-MASTER-BRIEF.md:585:- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
docs/build-brief/00-MASTER-BRIEF.md:586:- `ESC_RATE_LIMIT_HIT` — upstream API rate-limited (esp. LinkedIn)
docs/build-brief/00-MASTER-BRIEF.md:599:| 5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
packages/harness/cortextos/templates/analyst/.claude/skills/agent-browser/SKILL.md:3:description: Browser automation CLI for AI agents. Use when the user needs to interact with websites, including navigating pages, filling forms, clicking buttons, taking screenshots, extracting data, testing web apps, or automating any browser task. Triggers include requests to "open a website", "fill out a form", "click a button", "take a screenshot", "scrape data from a page", "test this web app", "login to a site", "automate browser actions", or any task requiring programmatic web interaction. Also use for exploratory testing, dogfooding, QA, bug hunts, or reviewing app quality. Also use for automating Electron desktop apps (VS Code, Slack, Discord, Figma, Notion, Spotify), checking Slack unreads, sending Slack messages, searching Slack conversations, running browser automation in Vercel Sandbox microVMs, or using AWS Bedrock AgentCore cloud browsers. Prefer agent-browser over any built-in browser automation or web tools.
docs/runbooks/tenant-lifecycle.md:44:### Trigger
docs/runbooks/tenant-lifecycle.md:151:| Bullhorn OAuth refresh | Per-agent 8-min cycle per `bullhorn-integration-path.md` §4.5; ESC_BULLHORN_AUTH on failure | (No invariant violation; runtime concern) |
docs/runbooks/tenant-lifecycle.md:179:### Trigger
docs/runbooks/tenant-lifecycle.md:213:### Trigger
docs/runbooks/tenant-lifecycle.md:283:### Trigger
docs/runbooks/tenant-lifecycle.md:382:| # | Gap | Severity | Resolution path | Trigger |
docs/specs/ULTRAPLAN.md:72:- **The file bus.** Inter-agent handoff via shared filesystem directories. No queue, no API, no serialisation tax. Brief Decoder writes a parsed-brief file; Sourcing Scout's `FastChecker` polls it up at the configured cadence (default 1000ms `pollInterval`, configurable per agent); result lands in a sub-directory the Concierge is polling. Four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound.
docs/specs/ULTRAPLAN.md:155:hh_load_tone_rules
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:182:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/specs/ULTRAPLAN.md:183:- `ESC_BULLHORN_AUTH` — Bullhorn OAuth token expired or revoked
docs/specs/ULTRAPLAN.md:186:- `ESC_BRIEF_AMBIGUITY` — Brief Decoder found ambiguities that prevent confident shortlisting
docs/specs/ULTRAPLAN.md:187:- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
docs/specs/ULTRAPLAN.md:188:- `ESC_RATE_LIMIT_HIT` — upstream API (LinkedIn especially) rate limited
docs/specs/ULTRAPLAN.md:354:If any hard fail, the agent regenerates with the failure reason injected as additional context ("your previous draft used the banned phrase 'I hope this finds you well'; rewrite avoiding it"). After 3 retries with hard fails, escalate with `ESC_VOICE_DRIFT` or `ESC_SCHEMA_VIOLATION`.
docs/specs/ULTRAPLAN.md:376:If the rolling 4-week average drops by ≥5 percentage points: `ESC_VOICE_DRIFT_TENANT` fires. Email goes to the customer's primary contact AND to the internal CS Slack:
docs/specs/ULTRAPLAN.md:472:Build wave (v1.0 / v1.1 / v1.2 / v2.0)
docs/specs/ULTRAPLAN.md:474:Trigger type
docs/specs/ULTRAPLAN.md:489:- **Build wave:** v1.0 (week 4–5)
docs/specs/ULTRAPLAN.md:491:- **Trigger type:** Manual (run from CLI or sales-tool web page)
docs/specs/ULTRAPLAN.md:503:- **Build wave:** v1.0 (week 5–6)
docs/specs/ULTRAPLAN.md:505:- **Trigger type:** Cron 02:00 UTC daily; manual full-cleanup on demand
docs/specs/ULTRAPLAN.md:517:- **Build wave:** v1.0 (week 6–7)
docs/specs/ULTRAPLAN.md:519:- **Trigger type:** Webhook from Fathom / Fireflies / Ringover when a call ends
docs/specs/ULTRAPLAN.md:531:- **Build wave:** v1.0 (week 7–8)
docs/specs/ULTRAPLAN.md:533:- **Trigger type:** Webhook (payment received, invoice issued, invoice viewed) + cron sweep at 07:00 daily
docs/specs/ULTRAPLAN.md:543:#### A5. Sourcing Scout (daytime form) — request-response sourcing
docs/specs/ULTRAPLAN.md:545:- **Build wave:** v1.0 (week 8–9)
docs/specs/ULTRAPLAN.md:547:- **Trigger type:** Brain UI button, Telegram command, or webhook from a "new brief" event
docs/specs/ULTRAPLAN.md:559:- **Build wave:** v1.0 (week 9–10)
docs/specs/ULTRAPLAN.md:561:- **Trigger type:** ATS state changes (candidate moved to interview, rejected, placed, etc.) + cron sweep for time-elapsed nurture events
docs/specs/ULTRAPLAN.md:575:- **Build wave:** v1.1 (Q4 2026 weeks 1–4)
docs/specs/ULTRAPLAN.md:577:- **Trigger type:** Inbound email webhook (Microsoft Graph subscription or AgentMail webhook), LinkedIn InMail webhook, website contact form webhook
docs/specs/ULTRAPLAN.md:589:- **Build wave:** v1.1 (weeks 5–6)
docs/specs/ULTRAPLAN.md:591:- **Trigger type:** Inbound brief detected by Triage; file-bus handoff
docs/specs/ULTRAPLAN.md:593:- **MCP tools required:** Bullhorn (read for prior placements + candidates), shared with Sourcing Scout
docs/specs/ULTRAPLAN.md:594:- **Shared modules required:** Voice loader, decision log writer, the Brief Decoder→Sourcing Scout→Concierge orchestration template
docs/specs/ULTRAPLAN.md:595:- **External APIs:** Same as Sourcing Scout (reuses)
docs/specs/ULTRAPLAN.md:599:- **Gotchas:** Brief format varies hugely between clients. Build the parser as schema-driven, not pattern-matching. The orchestration handoff to Sourcing Scout is the load-bearing CortexOS test.
docs/specs/ULTRAPLAN.md:607:- **Build wave:** v1.1 (weeks 7–8)
docs/specs/ULTRAPLAN.md:609:- **Trigger type:** Broadbean / job-board scraper detects a target-patch company posted via a competitor agency
docs/specs/ULTRAPLAN.md:621:- **Build wave:** v1.1 (weeks 9–10)
docs/specs/ULTRAPLAN.md:623:- **Trigger type:** Cron 22:00 weeknights per tenant
docs/specs/ULTRAPLAN.md:626:- **Shared modules required:** Voice loader, decision log writer, the source-abstraction layer from Sourcing Scout
docs/specs/ULTRAPLAN.md:627:- **External APIs:** Same as Sourcing Scout + GitHub
docs/specs/ULTRAPLAN.md:629:- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared with Sourcing Scout)
docs/specs/ULTRAPLAN.md:630:- **Build complexity:** **M** (2 weeks) — reuses Sourcing Scout's source layer; the new work is the overnight scheduling + rate-limit budget allocation
docs/specs/ULTRAPLAN.md:635:- **Build wave:** v1.1 (parallel; weeks 1–8)
docs/specs/ULTRAPLAN.md:637:- **Trigger type:** Continuous (daily sweep) + event-driven on umbrella changes
docs/specs/ULTRAPLAN.md:649:- **Build wave:** v1.1 (parallel; weeks 4–10)
docs/specs/ULTRAPLAN.md:651:- **Trigger type:** Continuous state-machine; daily sweep + event-driven on contractor events
docs/specs/ULTRAPLAN.md:689:| Sourcing Scout | ✓ | ✓ | | | ✓ | | ✓ | | | ✓ | |
docs/specs/ULTRAPLAN.md:771:### Weeks 9–10 — Sourcing Scout + Concierge start
docs/specs/ULTRAPLAN.md:773:- Week 9: Sourcing Scout (daytime); LinkedIn + Reed + CV-Library integration
docs/specs/ULTRAPLAN.md:820:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
docs/specs/ULTRAPLAN.md:822:| 6 | LinkedIn rate limits via Proxycurl are tighter than expected | Medium | Medium | Sourcing Scout cost >£100/run | Negotiate Proxycurl enterprise plan; defer Night Sourcer to v1.2 if needed |
docs/operations/codex-round-2-remediation-prompt.md:205:      `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/operations/codex-round-2-remediation-prompt.md:215:  | Gate | Trigger | Status |
docs/runbooks/pii-purge-operational-pattern.md:195:| # | Gap | Trigger |
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
docs/decisions/brain-ui-scope.md:43:- Highlights `ESC_*` escalations across all agents — `ESC_BULLHORN_AUTH`, `ESC_VOICE_DRIFT`, `ESC_DUPLICATE_DETECTED`, `ESC_RENDERER_FAILED`, etc.
packages/harness/cortextos/community/skills/goal-management/SKILL.md:3:description: "Daily goal lifecycle management. Use for: morning briefing goal cascade, setting daily focus, refreshing agent goals, reviewing goal progress. Triggered daily as part of morning review."
docs/decisions/v1.0-kill-criterion.md:45:### Trigger 1 — DESIGN-PARTNER-BY-WEEK-2 (PAUSE)
docs/decisions/v1.0-kill-criterion.md:49:**Calendar:** Day 0 was 2026-05-13 (Wednesday). Week 0 runs Days 0-7, ending Wednesday 2026-05-20. Week 1 starts Thursday 2026-05-21. Week 2 ends Wednesday 2026-06-03. **Trigger fires end-of-day 2026-06-03 if criterion unmet.**
docs/decisions/v1.0-kill-criterion.md:61:### Trigger 2 — DIAGNOSTIC-NO-RENDER-W3 (KILL)
docs/decisions/v1.0-kill-criterion.md:73:### Trigger 3 — JANITOR-BULLHORN-AUTH-W5 (PIVOT)
docs/decisions/v1.0-kill-criterion.md:91:### Trigger 4 — TWO-SCOPE-CUT-ACTIVATIONS (PAUSE)
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:107:### Trigger 5 — AUTOSEND-RED-MISCATEGORISATIONS (PAUSE)
docs/decisions/v1.0-kill-criterion.md:119:### Trigger 6 — UNIT-ECONOMICS-COST-PER-ACTION (PIVOT)
docs/decisions/v1.0-kill-criterion.md:136:**Action:** PIVOT — likely vector: cheaper Claude model tier (Haiku 4.5 for routine actions, Sonnet for complex), or reduced agent run frequency (e.g., Sourcing Scout runs nightly batch instead of real-time), or per-tenant cost passthrough in pricing.
docs/decisions/v1.0-kill-criterion.md:140:### Trigger 7 — INFRASTRUCTURE-COST-MONTHLY (PIVOT)
docs/decisions/v1.0-kill-criterion.md:158:### Trigger 8 — GATE-B-REVENUE-UPLIFT (KILL)
docs/decisions/v1.0-kill-criterion.md:170:### Trigger 9 — CORTEXOS-PRIMITIVE-CHRONIC-FAILURE (PAUSE)
docs/decisions/v1.0-kill-criterion.md:186:### Trigger 10 — PII-LEAKAGE-INCIDENT (KILL)
docs/decisions/v1.0-kill-criterion.md:212:- For all KILL actions: founder decides; activates within 24h (within 4h for Trigger 10 PII per §3.5 emergency authority).
docs/decisions/v1.0-kill-criterion.md:224:- **Trigger 6 (Unit economics):** founder decides PIVOT direction (cheaper model tier, reduced agent frequency, etc.) → consults Jack on pricing implications before locking → updates Ultraplan pricing plan.
docs/decisions/v1.0-kill-criterion.md:225:- **Trigger 7 (Infrastructure cost):** founder decides PIVOT direction (self-host alternative, provider switch, architecture compaction) → consults Jack on commercial impact before locking.
docs/decisions/v1.0-kill-criterion.md:226:- **Trigger 1 (Design partner) PAUSE → KILL escalation:** if PAUSE extends 4 weeks without signed LOI, founder consults Jack on whether to escalate to KILL (commercial assessment of pipeline) or extend PAUSE.
docs/decisions/v1.0-kill-criterion.md:227:- **Trigger 8 (Gate-B revenue) KILL:** founder decides KILL on revenue evidence; consults Jack on wind-down terms with existing pilots before 30-day notice goes out.
docs/decisions/v1.0-kill-criterion.md:237:### §3.5 — Emergency authority (Trigger 10 PII-LEAKAGE-INCIDENT specifically)
docs/decisions/v1.0-kill-criterion.md:239:Trigger 10 escalates regulatory-clock-driven actions. UK GDPR Art. 33 mandates ICO notification within 72 hours of discovery; multi-person consultation cannot delay this clock.
docs/decisions/v1.0-kill-criterion.md:267:| T+0 (trigger detected) | Trigger detector (Claude Code, IFOS oncall, or Founder) writes incident report to `.agents/incidents/<date>-<trigger-id>.md`. Report includes: trigger name, threshold details, evidence (logs/queries/screenshots), preliminary KILL/PAUSE/PIVOT recommendation. |
docs/decisions/v1.0-kill-criterion.md:316:   - Trigger that activated KILL
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:371:**For Week 0 remaining.** Day 6 (vertical schema v0.1) and Day 7 (single-sentence test + Codex run) do not depend on this criterion directly. Day 7's question 1 (design partner LOI) is the structural Week-0 gate; this criterion's Trigger 1 (DESIGN-PARTNER-BY-WEEK-2) explicitly references that gap.
docs/decisions/v1.0-kill-criterion.md:373:**For Week 1-2.** All Week-1 work is conducted with awareness that Trigger 1 fires 2026-06-03 if no LOI (per §1 calendar — Wednesday end-of-Week-2). Founder allocates time accordingly: design-partner acquisition is a Week-1 sub-track, not an afterthought.
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
docs/decisions/v1.0-kill-criterion.md:377:**For Risk Register.** Triggers 1, 2, 3, 5, 6, 7, 9, 10 each correspond to existing register entries (Risks #1-#8 in some combination). Risk #3 is updated in this Day-5 commit to reflect the Day-5 status. Risk #4 (Hire #1) is implicitly linked to Trigger 4 (scope cuts). Codex Day-7 ratification reviews the alignment between kill criterion triggers and risk register entries.
docs/decisions/v1.0-kill-criterion.md:381:1. Trigger thresholds — are they measurable, achievable, honest signals?
docs/specs/_archive-build-handoff.md:381:| 5 | **Sourcing Scout** | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
docs/decisions/autosend-approval-bridge-spec.md:243:| A5 | Bridge crash + restart: state rebuilds from filesystem scan + Postgres state table | Restart test: kill PM2 process mid-flight, restart, verify pending approvals resume |
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
docs/decisions/2026-05-18-day-7-single-sentence-test.md:36:- **Kill criterion linkage:** Trigger 1 in `docs/decisions/v1.0-kill-criterion.md` §2 (DESIGN-PARTNER-BY-WEEK-2) fires end-of-day **2026-06-03** if no signed LOI by then. That is the binding tripwire — currently **14 calendar days** out from today (2026-05-20).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:90:| 1 | Design partner pilot Q3 2026 LOI? | **NO** | High — zero pipeline; Risk #3 High; Trigger 1 fires 2026-06-03 |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:148:- Trigger 1 (kill criterion DESIGN-PARTNER-BY-WEEK-2 PAUSE): fires end-of-day **2026-06-03** if no signed LOI.
docs/operations/codex-ratification-execution-plan.md:348:Per Day-7 manifest §4 + §6 of this plan: Codex ratification execution was deferred pending Week 0 close. Week 0 closes when single-sentence-test Q1 = YES (design partner LOI signed). **Current state:** Q1 = NO; Week 0 EXTENDING; kill-criterion Trigger 1 fires 2026-06-03.
docs/operations/codex-ratification-execution-plan.md:360:| Phase | Cluster | Trigger |
packages/harness/cortextos/templates/analyst/GUARDRAILS.md:9:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/analyst/GUARDRAILS.md:19:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/templates/analyst/GUARDRAILS.md:44:| Trigger | Red Flag Thought | Required Action |
docs/specs/PRODUCT-SPEC.md:101:#### R5. Sourcing Scout (daytime form) — request-response sourcing during the day
docs/specs/PRODUCT-SPEC.md:182:Triggered by the April 2026 regulatory window — Joint & Several Liability for umbrella PAYE, six-year holiday-pay record-keeping, Fair Work Agency standing up. Different buyer (FD / Compliance Officer / Operations Director), different sales conversation, separate SKU. Same Intel Force OS platform.
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:400:| 3 | Inter-agent file bus — agents hand work to each other via shared directories | Brief Decoder → Sourcing Scout → Concierge handoff; Triage → specialist-agent routing |
docs/specs/PRODUCT-SPEC.md:476:- Sourcing Scout (daytime form)
docs/specs/PRODUCT-SPEC.md:486:3. **Night Sourcer** (2 weeks) — overnight extension of Sourcing Scout
docs/specs/PRODUCT-SPEC.md:526:5. **Sourcing Scout (daytime)** — "Shortlist in 15 minutes instead of by end of week."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:23:| 9 | Sourcing Scout |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:51:5. **Buffer on kill-criterion Trigger 2.** `v1.0-kill-criterion.md` Trigger 2 fires 2026-06-14 if Diagnostic doesn't render cleanly. Today is 2026-05-24 — 21 days of buffer. Building now beats the deadline by 3 weeks.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:75:- Sourcing Scout (W9) touches Bullhorn read; same gating
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:85:- Q1 LOI gate (Jack's lane; Trigger 1 fires 2026-06-03 if no LOI)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:109:- `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render by 2026-06-14)
packages/harness/cortextos/community/skills/morning-review/SKILL.md:3:description: "Daily morning briefing workflow. Triggered by morning cron. Pulls overnight agent work, checks goals state, cascades goals to agents, schedules tasks, sends briefing to user."
packages/harness/cortextos/community/skills/morning-review/SKILL.md:316:## Manual Trigger
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:144:| 1 | `agents/recruitment/diagnostic/agent.md` | **REJECTED** | 5 real findings (Gate A strength + Step 11 decision-log + Trigger 8 mismap + sentinel + validate.sh gap) | `20260524T101934Z-19923` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:186:| 17 | v1.0-kill-criterion.md | REJECTED (3 issues) | All three (Trigger 1 date / Trigger 2 CLI / Trigger 4 threshold) **incorporated** at `2b287d3`. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:243:| Phase | Trigger | Estimated work |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/_supplementary/PRD-autonomous-agent.md:473:| `run --url [url]` | Trigger pipeline with specific reel |
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:22:7. **`docs/decisions/v1.0-kill-criterion.md`** §2 Triggers 1-10 (deadline awareness) + §3 (authority structure)
docs/operations/goal-week-3-polish-and-scaffold.md:50:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:53:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:63:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:208:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:212:   - **Retry:** if response shape malformed, retry once; if still bad, fall back to deterministic logic + emit `ESC_VOICE_DRIFT` warning row.
docs/operations/goal-week-3-polish-and-scaffold.md:217:   - Tone-rule violation in LLM output → retry then ESC_VOICE_DRIFT
docs/operations/goal-week-3-polish-and-scaffold.md:294:- `v1.0-kill-criterion.md` Trigger 3 (JANITOR-BULLHORN-AUTH-W5)
docs/operations/goal-week-3-polish-and-scaffold.md:301:- **Build wave:** W5 per master brief §8.2 line 596
docs/operations/goal-week-3-polish-and-scaffold.md:308:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_BULLHORN_WRITE_FAIL, ESC_SCHEMA_VIOLATION, ESC_RATE_LIMIT_HIT, ESC_AUTOSEND_YELLOW_SPOT_CHECK.
docs/operations/goal-week-3-polish-and-scaffold.md:336:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:343:- **§6 Escalation codes:** ESC_BULLHORN_WRITE_FAIL, ESC_VOICE_DRIFT, ESC_SCHEMA_VIOLATION, ESC_FIELD_EXTRACTION_LOW_CONFIDENCE.
docs/operations/goal-week-3-polish-and-scaffold.md:344:- **§7 Voice + tone:** tacit-note is consultant-voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:365:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:373:- **§7 Voice + tone:** chase drafts are voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:381:### DAY 19 — Sourcing Scout + Concierge agent.md scaffolds (Steps 11-12)
docs/operations/goal-week-3-polish-and-scaffold.md:386:- ULTRAPLAN §8.1 A5 lines 547-558 (Sourcing Scout spec)
docs/operations/goal-week-3-polish-and-scaffold.md:387:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:388:- `bullhorn-integration-path.md` §4.1 (Sourcing Scout's Bullhorn read surface)
docs/operations/goal-week-3-polish-and-scaffold.md:389:- `vertical-schema.yaml` §3 agent_access_matrix Sourcing Scout row
docs/operations/goal-week-3-polish-and-scaffold.md:393:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:400:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_LINKEDIN_AUTH, ESC_RATE_LIMIT_HIT, ESC_BRIEF_UNDERSPECIFIED.
docs/operations/goal-week-3-polish-and-scaffold.md:407:Commit: `decision(pre-build): agents/recruitment/sourcing-scout/agent.md — output contract per ULTRAPLAN §8.1 A5`
docs/operations/goal-week-3-polish-and-scaffold.md:420:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:427:- **§6 Escalation codes:** ESC_AUTOSEND_BLOCKED, ESC_VOICE_DRIFT, ESC_TONE_RULE_VIOLATION, ESC_APPROVAL_BRIDGE_TIMEOUT, ESC_BULLHORN_AUTH, ESC_LIFECYCLE_STATE_UNKNOWN.
docs/operations/goal-week-3-polish-and-scaffold.md:498:| LLM call rate-limited or 5xx (Step 4 runtime) | Built-in retry once; fall back to deterministic; emit ESC_VOICE_DRIFT warning |
docs/operations/goal-week-3-polish-and-scaffold.md:499:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:619:  Sourcing Scout (W9):    <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:643:  ✓ v1.0-kill-criterion.md Trigger 2 — Diagnostic ratified ahead of
docs/operations/goal-week-3-polish-and-scaffold.md:683:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/operations/goal-week-3-polish-and-scaffold.md:700:**Day 20 is the soft target. Day 22 is the hard cutoff** (Trigger 2 fires Day 21 if Diagnostic not ratified). If Day 22 hits without completion, escalate to founder review + scope-cut decision.
docs/_supplementary/technical-strategy-v2.md:17:3. **Headless mode + cron is a proven 24/7 pattern.** The `-p` flag runs Claude Code as a one-shot command, no terminal, exit when done. Triggered on a schedule, it behaves like any other cron job. Public example in the wild: *"OpenClaw has 140k GitHub stars. I built the same thing with Claude Code, cron, and ~200 lines of shell scripts."* That's the pattern.
packages/harness/cortextos/community/skills/evening-review/SKILL.md:3:description: "End-of-day review workflow. Triggered by evening cron. Summarizes the day across all agents, evaluates orchestrator performance, prepares tomorrow, proposes overnight work for approval."
packages/harness/cortextos/community/skills/evening-review/SKILL.md:273:## Manual Trigger
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
docs/decisions/sequencing-target.md:300:**Trigger 1 — Risk #2 materialises in Week 4-5.** If Bullhorn auth path breaks (Day 2 Sub-decisions A or B don't flip to Accepted, marketplace required but unobtainable, OAuth flow blocks deployment, or per-tenant client_id ticket cycle slows past 5 business days per `bullhorn-integration-path.md` §1.3 row 5):
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:307:**Trigger 2 — Risk #4 materialises (Hire #1 doesn't start by end of Week 4).** Per RISK-REGISTER #4 tripwire "No offer accepted by end of week 4":
docs/decisions/sequencing-target.md:310:- **Activation:** v1.0 scope cut from 6 to 4 agents per Ultraplan §10 row #4 — drop Concierge + Sourcing Scout to v1.1; founder solo through end of v1.0.
docs/decisions/sequencing-target.md:311:- **Updates required:** same set as Trigger 1 plus founder's Q3 personal cadence (Cash Conductor's L/2-week build becomes founder solo at W7-8, slowing but not blocking).
docs/decisions/sequencing-target.md:314:**Trigger 3 — Hire #1 starts later than Week 7.** Per Ultraplan §9 line 766 verbatim caveat: "Hire #1 is assumed to start week 7 (verify, don't assume)":
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:319:- **Cascade:** Sourcing Scout W10 (shifted right from W9), Concierge W11-14 (shifted right from W10-13).
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:373:3. **Either fix-and-retry (1 additional week)** or **scope-cut contingency activates** per §4.3 Trigger 1 (if Risk #2 derived) or §4.3 Trigger 2 (if Risk #4 derived).
docs/decisions/sequencing-target.md:410:§4.3 Trigger 1 activation point: end of W4 weekly review if Sub-decisions A and B still Proposed.
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:37:| Gate | Trigger | Status |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:68:build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md:16:Trigger this skill when you:
packages/harness/cortextos/community/skills/local-ultrareview/SKILL.md:5:**Trigger phrases:**
docs/operations/seedlegals-engagement-queries.md:167:- 2026-06-03 (Trigger 1) date approaches; LOI process accelerates without legal infrastructure
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md:10:## Trigger
packages/harness/cortextos/community/skills/weekly-review/SKILL.md:204:## Manual Trigger
docs/_supplementary/build-plan-original.md:226:- Trigger payload: variable (Fathom transcript = 5–15k tokens)
docs/_supplementary/build-plan-original.md:276:### Trigger
docs/_supplementary/build-plan-original.md:342:### Trigger
docs/_supplementary/build-plan-original.md:511:### Trigger
docs/_supplementary/build-plan-original.md:584:### Trigger
docs/_supplementary/build-plan-original.md:661:### Trigger
docs/_supplementary/build-plan-original.md:717:### Trigger
docs/_supplementary/build-plan-original.md:759:### Trigger
docs/_supplementary/build-plan-original.md:807:### Trigger
docs/_supplementary/build-plan-original.md:853:### Trigger
docs/_supplementary/build-plan-original.md:938:Claude Code sub-agent exposed as a Slack/Teams bot. Triggered by @mentions and DMs.
docs/_supplementary/build-plan-original.md:1021:### Trigger
docs/_supplementary/strategic-plan.md:326:- [ ] **Dev**: Trigger system (webhooks, cron via BullMQ)
packages/harness/cortextos/dashboard/src/components/layout/org-selector.tsx:8:  SelectTrigger,
packages/harness/cortextos/dashboard/src/components/layout/org-selector.tsx:40:      <SelectTrigger className="w-48">
packages/harness/cortextos/dashboard/src/components/layout/org-selector.tsx:42:      </SelectTrigger>
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:51:7. **All work committed** as atomic commits with clear messages. Final commit confirms Trigger 2 beat (2026-06-14 deadline cleared 21 days early).
docs/operations/goal-option-c-diagnostic-end-to-end.md:155:- `errors.ts` — 429 → ESC_RATE_LIMIT_HIT, 5xx → ESC_SCHEMA_VIOLATION
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-option-c-diagnostic-end-to-end.md:282:- Trigger 2 deadline cleared (X days early)
docs/operations/goal-option-c-diagnostic-end-to-end.md:309:| LLM generates §12 with banned phrase | V5 fails; retry up to 3x; if still failing, ESC_VOICE_DRIFT row + report blocked (matches fixture 99); record as known limitation, defer voice tuning to Week-4 polish. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:350:- [ ] Trigger 2 deadline cleared (≥7 days remaining)
docs/operations/goal-option-c-diagnostic-end-to-end.md:397:Trigger 2 deadline (2026-06-14): cleared by [N] days
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:37:| A5 Sourcing Scout | **Yes — read** (ATS passive-match lookup) | Ultraplan §8.1 A5 line 547-551 |
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:101:| Gate | Trigger | Status |
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:230:- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
docs/decisions/bullhorn-integration-path.md:283:| Agent | Entities Read | Entities Written | Read Cadence | Write Triggers | Error Handling | Per-tenant Scoping |
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:309:| Sourcing Scout passive-match read | Polling (on-demand search) | Per-consultant-request | No subscription needed — read-on-demand model |
docs/decisions/bullhorn-integration-path.md:336:| Sourcing Scout (read-on-demand) | 50-200 during consultant-active windows | Search-heavy; multiple paginated reads per consultant request |
docs/decisions/bullhorn-integration-path.md:353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:411:- **`ESC_BULLHORN_AUTH` escalation code wired** into `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3 line 587 — code already named in master brief; wiring lands with `_shared/hook-helpers.sh` Week-1 prereq.
docs/decisions/bullhorn-integration-path.md:415:No Postgres schema changes from this decision document. `_secrets.env` is filesystem (vault), not Postgres, per the design's vault/Postgres split (ADR-002 §3 + `second-brain-design.md` §2.4). `decision_log` columns already support per-tenant `ESC_BULLHORN_AUTH` rows per ADR-002 Decision 3 schema — no new columns needed.
docs/decisions/bullhorn-integration-path.md:484:| §4.5 (architectural emergence) | §4.5 | Access-token refresh-loop: per-agent background task, 8-minute cycle, retry-once-then-`ESC_BULLHORN_AUTH` |
docs/decisions/bullhorn-integration-path.md:502:| `ESC_BULLHORN_AUTH` escalation code wired into `agents/_shared/escalation-codes.md` | Claude Code | Week 1-2 (alongside `_shared/hook-helpers.sh` Week-1 prereq from ADR-002) |
packages/harness/cortextos/dashboard/src/components/layout/topbar.tsx:12:  DropdownMenuTrigger,
packages/harness/cortextos/dashboard/src/components/layout/topbar.tsx:68:          <DropdownMenuTrigger className="rounded-full outline-none focus-visible:ring-2 focus-visible:ring-ring cursor-pointer">
packages/harness/cortextos/dashboard/src/components/layout/topbar.tsx:72:          </DropdownMenuTrigger>
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:84:| Sourcing Scout | `linkedin_profile_cache` | Stores profile snapshot to `/vault/<tenant>/wiki/raw/`; no external send; no rate-limit cost |
docs/decisions/autosend-safety-policy.md:94:| Sourcing Scout | `linkedin_connection_request` | 1-in-5 | Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy |
docs/decisions/autosend-safety-policy.md:110:| Sourcing Scout | `linkedin_inmail_send` | Outbound InMail (paid credit); cost-per-send; customer-facing |
docs/decisions/autosend-safety-policy.md:124:| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |
docs/decisions/autosend-safety-policy.md:437:    "blocked_recipients": [
docs/decisions/autosend-safety-policy.md:463:3. **`blocked_recipients`** is additive only. Recipients can be added; system-default red-list recipients cannot be removed. Pattern matching supported via `*` wildcards.
docs/decisions/autosend-safety-policy.md:539:  (c) breaches of Tenant's configured blocked_recipients list by the
docs/decisions/autosend-safety-policy.md:599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
packages/harness/cortextos/dashboard/src/components/skills/skills-grid.tsx:4:import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
packages/harness/cortextos/dashboard/src/components/skills/skills-grid.tsx:65:        <TabsTrigger value="all">All ({skills.length})</TabsTrigger>
packages/harness/cortextos/dashboard/src/components/skills/skills-grid.tsx:66:        <TabsTrigger value="installed">Installed ({installed.length})</TabsTrigger>
packages/harness/cortextos/dashboard/src/components/skills/skills-grid.tsx:67:        <TabsTrigger value="available">Available ({available.length})</TabsTrigger>
packages/harness/cortextos/dashboard/src/components/activity/activity-filters.tsx:9:  SelectTrigger,
packages/harness/cortextos/dashboard/src/components/activity/activity-filters.tsx:95:            <SelectTrigger size="sm" className="w-[160px]">
packages/harness/cortextos/dashboard/src/components/activity/activity-filters.tsx:97:            </SelectTrigger>
packages/harness/cortextos/dashboard/src/components/activity/activity-filters.tsx:117:            <SelectTrigger size="sm" className="w-[160px]">
packages/harness/cortextos/dashboard/src/components/activity/activity-filters.tsx:119:            </SelectTrigger>
packages/harness/cortextos/dashboard/src/components/skills/skill-card.tsx:7:import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from '@/components/ui/select';
packages/harness/cortextos/dashboard/src/components/skills/skill-card.tsx:107:              <SelectTrigger className="flex-1">
packages/harness/cortextos/dashboard/src/components/skills/skill-card.tsx:109:              </SelectTrigger>
packages/harness/cortextos/dashboard/src/components/ui/tooltip.tsx:24:function TooltipTrigger({ ...props }: TooltipPrimitive.Trigger.Props) {
packages/harness/cortextos/dashboard/src/components/ui/tooltip.tsx:25:  return <TooltipPrimitive.Trigger data-slot="tooltip-trigger" {...props} />
packages/harness/cortextos/dashboard/src/components/ui/tooltip.tsx:66:export { Tooltip, TooltipTrigger, TooltipContent, TooltipProvider }
packages/harness/cortextos/dashboard/src/components/ui/sheet.tsx:14:function SheetTrigger({ ...props }: SheetPrimitive.Trigger.Props) {
packages/harness/cortextos/dashboard/src/components/ui/sheet.tsx:15:  return <SheetPrimitive.Trigger data-slot="sheet-trigger" {...props} />
packages/harness/cortextos/dashboard/src/components/ui/sheet.tsx:131:  SheetTrigger,
packages/harness/cortextos/dashboard/src/components/tasks/create-task-dialog.tsx:11:  DialogTrigger,
packages/harness/cortextos/dashboard/src/components/tasks/create-task-dialog.tsx:22:  SelectTrigger,
packages/harness/cortextos/dashboard/src/components/tasks/create-task-dialog.tsx:95:      <DialogTrigger render={<Button size="sm" />}>
packages/harness/cortextos/dashboard/src/components/tasks/create-task-dialog.tsx:98:      </DialogTrigger>
packages/harness/cortextos/dashboard/src/components/tasks/create-task-dialog.tsx:139:                <SelectTrigger>
packages/harness/cortextos/dashboard/src/components/tasks/create-task-dialog.tsx:141:                </SelectTrigger>
packages/harness/cortextos/dashboard/src/components/tasks/create-task-dialog.tsx:156:                <SelectTrigger>
packages/harness/cortextos/dashboard/src/components/tasks/create-task-dialog.tsx:158:                </SelectTrigger>
packages/harness/cortextos/dashboard/src/components/tasks/create-task-dialog.tsx:173:                <SelectTrigger>
packages/harness/cortextos/dashboard/src/components/tasks/create-task-dialog.tsx:175:                </SelectTrigger>
packages/harness/cortextos/community/agents/orchestrator/GUARDRAILS.md:9:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/community/agents/orchestrator/GUARDRAILS.md:19:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/community/agents/orchestrator/GUARDRAILS.md:46:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/dashboard/src/components/ui/select.tsx:31:function SelectTrigger({
packages/harness/cortextos/dashboard/src/components/ui/select.tsx:36:}: SelectPrimitive.Trigger.Props & {
packages/harness/cortextos/dashboard/src/components/ui/select.tsx:40:    <SelectPrimitive.Trigger
packages/harness/cortextos/dashboard/src/components/ui/select.tsx:55:    </SelectPrimitive.Trigger>
packages/harness/cortextos/dashboard/src/components/ui/select.tsx:66:  alignItemWithTrigger = true,
packages/harness/cortextos/dashboard/src/components/ui/select.tsx:71:    "align" | "alignOffset" | "side" | "sideOffset" | "alignItemWithTrigger"
packages/harness/cortextos/dashboard/src/components/ui/select.tsx:80:        alignItemWithTrigger={alignItemWithTrigger}
packages/harness/cortextos/dashboard/src/components/ui/select.tsx:85:          data-align-trigger={alignItemWithTrigger}
packages/harness/cortextos/dashboard/src/components/ui/select.tsx:199:  SelectTrigger,
packages/harness/cortextos/dashboard/src/components/ui/accordion.tsx:28:function AccordionTrigger({
packages/harness/cortextos/dashboard/src/components/ui/accordion.tsx:32:}: AccordionPrimitive.Trigger.Props) {
packages/harness/cortextos/dashboard/src/components/ui/accordion.tsx:35:      <AccordionPrimitive.Trigger
packages/harness/cortextos/dashboard/src/components/ui/accordion.tsx:46:      </AccordionPrimitive.Trigger>
packages/harness/cortextos/dashboard/src/components/ui/accordion.tsx:74:export { Accordion, AccordionItem, AccordionTrigger, AccordionContent }
packages/harness/cortextos/dashboard/src/components/knowledge-base/kb-client.tsx:4:import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
packages/harness/cortextos/dashboard/src/components/knowledge-base/kb-client.tsx:139:        <TabsTrigger value="search">
packages/harness/cortextos/dashboard/src/components/knowledge-base/kb-client.tsx:142:        </TabsTrigger>
packages/harness/cortextos/dashboard/src/components/knowledge-base/kb-client.tsx:143:        <TabsTrigger value="browse">
packages/harness/cortextos/dashboard/src/components/knowledge-base/kb-client.tsx:146:        </TabsTrigger>
packages/harness/cortextos/dashboard/src/components/knowledge-base/kb-client.tsx:147:        <TabsTrigger value="collections">
packages/harness/cortextos/dashboard/src/components/knowledge-base/kb-client.tsx:155:        </TabsTrigger>
packages/harness/cortextos/dashboard/src/components/ui/dropdown-menu.tsx:17:function DropdownMenuTrigger({ ...props }: MenuPrimitive.Trigger.Props) {
packages/harness/cortextos/dashboard/src/components/ui/dropdown-menu.tsx:18:  return <MenuPrimitive.Trigger data-slot="dropdown-menu-trigger" {...props} />
packages/harness/cortextos/dashboard/src/components/ui/dropdown-menu.tsx:103:function DropdownMenuSubTrigger({
packages/harness/cortextos/dashboard/src/components/ui/dropdown-menu.tsx:108:}: MenuPrimitive.SubmenuTrigger.Props & {
packages/harness/cortextos/dashboard/src/components/ui/dropdown-menu.tsx:112:    <MenuPrimitive.SubmenuTrigger
packages/harness/cortextos/dashboard/src/components/ui/dropdown-menu.tsx:123:    </MenuPrimitive.SubmenuTrigger>
packages/harness/cortextos/dashboard/src/components/ui/dropdown-menu.tsx:255:  DropdownMenuTrigger,
packages/harness/cortextos/dashboard/src/components/ui/dropdown-menu.tsx:266:  DropdownMenuSubTrigger,
packages/harness/cortextos/dashboard/src/components/ui/tabs.tsx:56:function TabsTrigger({ className, ...props }: TabsPrimitive.Tab.Props) {
packages/harness/cortextos/dashboard/src/components/ui/tabs.tsx:82:export { Tabs, TabsList, TabsTrigger, TabsContent, tabsListVariants }
packages/harness/cortextos/dashboard/src/components/ui/collapsible.tsx:9:function CollapsibleTrigger({ ...props }: CollapsiblePrimitive.Trigger.Props) {
packages/harness/cortextos/dashboard/src/components/ui/collapsible.tsx:11:    <CollapsiblePrimitive.Trigger data-slot="collapsible-trigger" {...props} />
packages/harness/cortextos/dashboard/src/components/ui/collapsible.tsx:21:export { Collapsible, CollapsibleTrigger, CollapsibleContent }
packages/harness/cortextos/dashboard/src/components/ui/dialog.tsx:14:function DialogTrigger({ ...props }: DialogPrimitive.Trigger.Props) {
packages/harness/cortextos/dashboard/src/components/ui/dialog.tsx:15:  return <DialogPrimitive.Trigger data-slot="dialog-trigger" {...props} />
packages/harness/cortextos/dashboard/src/components/ui/dialog.tsx:159:  DialogTrigger,
packages/harness/cortextos/dashboard/src/components/shared/time-ago.tsx:9:  TooltipTrigger,
packages/harness/cortextos/dashboard/src/components/shared/time-ago.tsx:50:      <TooltipTrigger
packages/harness/cortextos/dashboard/src/components/shared/time-ago.tsx:55:      </TooltipTrigger>
packages/harness/cortextos/dashboard/src/components/shared/health-dot.tsx:6:  TooltipTrigger,
packages/harness/cortextos/dashboard/src/components/shared/health-dot.tsx:26:      <TooltipTrigger
packages/harness/cortextos/dashboard/src/components/shared/health-dot.tsx:39:      </TooltipTrigger>
packages/harness/cortextos/dashboard/src/components/tasks/task-detail-sheet.tsx:21:  SelectTrigger,
packages/harness/cortextos/dashboard/src/components/tasks/task-detail-sheet.tsx:218:                <SelectTrigger className="w-28 h-7 text-xs">
packages/harness/cortextos/dashboard/src/components/tasks/task-detail-sheet.tsx:220:                </SelectTrigger>
packages/harness/cortextos/dashboard/src/components/agents/agent-actions.tsx:9:  DropdownMenuTrigger,
packages/harness/cortextos/dashboard/src/components/agents/agent-actions.tsx:112:        <DropdownMenuTrigger
packages/harness/cortextos/dashboard/src/components/agents/agent-actions.tsx:124:        </DropdownMenuTrigger>
packages/harness/cortextos/dashboard/src/components/agents/memory-tab.tsx:10:  AccordionTrigger,
packages/harness/cortextos/dashboard/src/components/agents/memory-tab.tsx:150:                  <AccordionTrigger
packages/harness/cortextos/dashboard/src/components/agents/memory-tab.tsx:165:                  </AccordionTrigger>
packages/harness/cortextos/dashboard/src/components/shared/filter-bar.tsx:8:  SelectTrigger,
packages/harness/cortextos/dashboard/src/components/shared/filter-bar.tsx:44:          <SelectTrigger size="sm">
packages/harness/cortextos/dashboard/src/components/shared/filter-bar.tsx:46:          </SelectTrigger>
packages/harness/cortextos/dashboard/src/components/agents/agent-detail-tabs.tsx:3:import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
packages/harness/cortextos/dashboard/src/components/agents/agent-detail-tabs.tsx:40:        <TabsTrigger value="profile">Profile</TabsTrigger>
packages/harness/cortextos/dashboard/src/components/agents/agent-detail-tabs.tsx:41:        <TabsTrigger value="tasks">Tasks</TabsTrigger>
packages/harness/cortextos/dashboard/src/components/agents/agent-detail-tabs.tsx:42:        <TabsTrigger value="crons">Crons</TabsTrigger>
packages/harness/cortextos/dashboard/src/components/agents/agent-detail-tabs.tsx:43:        <TabsTrigger value="memory">Memory</TabsTrigger>
packages/harness/cortextos/dashboard/src/components/agents/agent-detail-tabs.tsx:44:        <TabsTrigger value="logs">Logs</TabsTrigger>
packages/harness/cortextos/dashboard/src/components/agents/agent-detail-tabs.tsx:45:        <TabsTrigger value="goals">Goals</TabsTrigger>
packages/harness/cortextos/dashboard/src/components/agents/agent-detail-tabs.tsx:46:        <TabsTrigger value="settings">Settings</TabsTrigger>
packages/harness/cortextos/community/agents/agentic-crm-assistant/GUARDRAILS.md:5:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/dashboard/src/components/settings/appearance-tab.tsx:8:import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from '@/components/ui/select';
packages/harness/cortextos/dashboard/src/components/settings/appearance-tab.tsx:66:            <SelectTrigger className="w-40">
packages/harness/cortextos/dashboard/src/components/settings/appearance-tab.tsx:68:            </SelectTrigger>
packages/harness/cortextos/dashboard/src/components/agents/create-agent-dialog.tsx:19:  SelectTrigger,
packages/harness/cortextos/dashboard/src/components/agents/create-agent-dialog.tsx:183:              <SelectTrigger className="w-full">
packages/harness/cortextos/dashboard/src/components/agents/create-agent-dialog.tsx:185:              </SelectTrigger>
packages/harness/cortextos/tests/e2e/mock-codex.js:41:const WS_GUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
packages/harness/cortextos/dashboard/src/app/(dashboard)/approvals/page.tsx:5:import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
packages/harness/cortextos/dashboard/src/app/(dashboard)/approvals/page.tsx:125:          <TabsTrigger value="human">
packages/harness/cortextos/dashboard/src/app/(dashboard)/approvals/page.tsx:133:          </TabsTrigger>
packages/harness/cortextos/dashboard/src/app/(dashboard)/approvals/page.tsx:134:          <TabsTrigger value="pending">
packages/harness/cortextos/dashboard/src/app/(dashboard)/approvals/page.tsx:141:          </TabsTrigger>
packages/harness/cortextos/dashboard/src/app/(dashboard)/approvals/page.tsx:142:          <TabsTrigger value="history">History</TabsTrigger>
packages/harness/cortextos/dashboard/src/components/agents/logs-tab.tsx:9:  SelectTrigger,
packages/harness/cortextos/dashboard/src/components/agents/logs-tab.tsx:84:          <SelectTrigger size="sm">
packages/harness/cortextos/dashboard/src/components/agents/logs-tab.tsx:86:          </SelectTrigger>
packages/harness/cortextos/dashboard/src/components/charts/chart-theme.ts:19:  '#EA580C', // orange
packages/harness/cortextos/community/agents/security/.claude/skills/guardrails-reference/SKILL.md:19:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/community/agents/security/.claude/skills/guardrails-reference/SKILL.md:55:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/community/agents/agent/GUARDRAILS.md:9:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/community/agents/agent/GUARDRAILS.md:19:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/community/agents/agent/GUARDRAILS.md:45:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/dashboard/src/components/workflows/cron-form.tsx:24:  SelectTrigger,
packages/harness/cortextos/dashboard/src/components/workflows/cron-form.tsx:209:            <SelectTrigger id="cron-agent" className={touched.agent && errors.agent ? 'border-destructive' : ''}>
packages/harness/cortextos/dashboard/src/components/workflows/cron-form.tsx:211:            </SelectTrigger>
packages/harness/cortextos/community/agents/security/.claude/skills/agent-browser/SKILL.md:3:description: Browser automation CLI for AI agents. Use when the user needs to interact with websites, including navigating pages, filling forms, clicking buttons, taking screenshots, extracting data, testing web apps, or automating any browser task. Triggers include requests to "open a website", "fill out a form", "click a button", "take a screenshot", "scrape data from a page", "test this web app", "login to a site", "automate browser actions", or any task requiring programmatic web interaction. Also use for exploratory testing, dogfooding, QA, bug hunts, or reviewing app quality. Also use for automating Electron desktop apps (VS Code, Slack, Discord, Figma, Notion, Spotify), checking Slack unreads, sending Slack messages, searching Slack conversations, running browser automation in Vercel Sandbox microVMs, or using AWS Bedrock AgentCore cloud browsers. Prefer agent-browser over any built-in browser automation or web tools.
packages/harness/cortextos/dashboard/src/components/workflows/test-fire-button.tsx:31:  TooltipTrigger,
packages/harness/cortextos/dashboard/src/components/workflows/test-fire-button.tsx:169:          {/* base-ui Tooltip.Trigger wraps children directly — no asChild needed */}
packages/harness/cortextos/dashboard/src/components/workflows/test-fire-button.tsx:170:          <TooltipTrigger
packages/harness/cortextos/dashboard/src/app/(dashboard)/settings/page.tsx:3:import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
packages/harness/cortextos/dashboard/src/app/(dashboard)/settings/page.tsx:23:          <TabsTrigger value="organization">Organization</TabsTrigger>
packages/harness/cortextos/dashboard/src/app/(dashboard)/settings/page.tsx:24:          <TabsTrigger value="telegram">Telegram</TabsTrigger>
packages/harness/cortextos/dashboard/src/app/(dashboard)/settings/page.tsx:25:          <TabsTrigger value="system">System</TabsTrigger>
packages/harness/cortextos/dashboard/src/app/(dashboard)/settings/page.tsx:26:          <TabsTrigger value="users">Users</TabsTrigger>
packages/harness/cortextos/dashboard/src/app/(dashboard)/settings/page.tsx:27:          <TabsTrigger value="allowed-roots">Allowed Roots</TabsTrigger>
packages/harness/cortextos/dashboard/src/app/(dashboard)/settings/page.tsx:28:          <TabsTrigger value="appearance">Appearance</TabsTrigger>
packages/harness/cortextos/community/agents/security/GUARDRAILS.md:9:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/community/agents/security/GUARDRAILS.md:19:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/CHANGELOG.md:484:Triggers: push to `main`, `feat/*`, `fix/*` branches; all pull requests.
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:978:    // Trigger fires for both
packages/harness/cortextos/dashboard/src/app/(dashboard)/comms/page.tsx:4:import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
packages/harness/cortextos/dashboard/src/app/(dashboard)/comms/page.tsx:147:          <TabsTrigger value="meeting-room">
packages/harness/cortextos/dashboard/src/app/(dashboard)/comms/page.tsx:150:          </TabsTrigger>
packages/harness/cortextos/dashboard/src/app/(dashboard)/comms/page.tsx:151:          <TabsTrigger value="channels">
packages/harness/cortextos/dashboard/src/app/(dashboard)/comms/page.tsx:159:          </TabsTrigger>
packages/harness/cortextos/dashboard/src/app/api/approvals/[id]/route.ts:122:    // Trigger sync so subsequent reads reflect the resolution
packages/harness/cortextos/dashboard/src/app/(dashboard)/experiments/page.tsx:6:import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
packages/harness/cortextos/dashboard/src/app/(dashboard)/experiments/page.tsx:284:            <TabsTrigger value="by-agent">By Agent</TabsTrigger>
packages/harness/cortextos/dashboard/src/app/(dashboard)/experiments/page.tsx:285:            <TabsTrigger value="timeline">Timeline</TabsTrigger>
packages/harness/cortextos/dashboard/src/app/(dashboard)/experiments/page.tsx:286:            <TabsTrigger value="learnings">Learnings</TabsTrigger>
packages/harness/cortextos/community/agents/analyst/GUARDRAILS.md:9:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/community/agents/analyst/GUARDRAILS.md:19:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/community/agents/analyst/GUARDRAILS.md:44:| Trigger | Red Flag Thought | Required Action |
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:23: *   1. Triggers an action that should produce an audit trail.
packages/harness/cortextos/dashboard/src/app/api/tasks/[id]/route.ts:324:    // Trigger sync so subsequent reads reflect the update
packages/harness/cortextos/dashboard/src/app/api/tasks/route.ts:124:    // Trigger sync so subsequent reads reflect the new task
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:79:    // Trigger sync to all running agents — fire-and-forget so response is not blocked.

codex
The main risk areas are citation drift and schema/vault split consistency, so I’m narrowing onto the exact source lines rather than trusting the inline references.
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

exec
/bin/zsh -lc "rg --files docs | rg -i 'master|brief|product|operational|hygiene|ultraplan'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/_archive-build-pack/02-PRODUCT-VISION.md
docs/runbooks/operational-hygiene-protocol.md
docs/runbooks/pii-purge-operational-pattern.md
docs/build-brief/00-MASTER-BRIEF.md
docs/specs/ULTRAPLAN.md
docs/specs/PRODUCT-SPEC.md
docs/_supplementary/planning-phase-brief.md

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '70,110p'; nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '830,870p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '90,270p'; nl -ba agents/_shared/escalation-codes.md | sed -n '370,435p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   830	    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
   831	    - validate_voice_scores trigger active on entities table
   832	    - RLS + ifos_app grants from Day-4 §6.3 in place
   833	    - migration-test tenant row exists in tenants table
   834	
   835	  steps:
   836	    1: |
   837	      Verify v0.2 prerequisites (DO block in migration §1).
   838	    2: |
   839	      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
   840	      ifos_app grants + 2 indexes (migration §2).
   841	    3: |
   842	      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
   843	      (migration §3).
   844	    4: |
   845	      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
   846	      the v0.2 validate_voice_scores binding while forwarding v0.2 voice-
   847	      score checks. Adds JSONB key validations for 14 v0.3 fields across
   848	      candidate / contact / brief / placement / opportunity entity_types.
   849	      Re-attaches the trigger to entities table (migration §4).
   850	      NOTE: entities table itself is unchanged; entity.data is JSONB and
   851	      v0.3 keys are validated by the trigger, not via ALTER TABLE.
   852	    5: |
   853	      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
   854	      hard-fails on unknown config keys (Rule 2); type-validates the 3 new
   855	      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
   856	    6: |
   857	      Smoke verification DO block confirms both cash_conductor_*
   858	      tables exist (migration §6).
   859	    7: |
   860	      COMMIT; or ROLLBACK on any error.
   861	
   862	  post_migration_steps:
   863	    1: Run scripts/run-tenancy-audit.sh; expect 12/12 invariants pass (T1-T12)
   864	    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
   865	       to cite v0.3 supplement instead of "v0.3-supplement-pending"
   866	    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
   867	       Cat-β findings closed
   868	
   869	# ============================================================================
   870	# §7 — Codex ratification path

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

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '330,360p'; nl -ba agents/_shared/autosend-policy.yaml | sed -n '100,135p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '220,340p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   261	    return 0
   262	  fi
   263	
   264	  printf '{"edits":[],"lookback_days":%s,"source":"fallback","reason":"db_unavailable"}\n' "${lookback_days}"
   265	}
   266	
   267	# Internal: render psql TSV → JSON for recent edits.
   268	_vl_render_recent_edits_json() {
   269	  local rows="$1"
   270	  local lookback_days="$2"
   271	
   272	  if [[ -z "${rows}" ]]; then
   273	    printf '{"edits":[],"lookback_days":%s,"source":"db","count":0}\n' "${lookback_days}"
   274	    return 0
   275	  fi
   276	
   277	  printf '{"edits":['
   278	  local first=1
   279	  while IFS=$'\t' read -r id action_type edit_distance resolution tone_rules resolved_at; do
   280	    [[ -z "${id}" ]] && continue
   281	    if (( first )); then first=0; else printf ','; fi
   282	    printf '{"id":%s,"action_type":"%s","edit_distance":%s,"resolution":"%s","tone_rules_triggered":"%s","resolved_at":"%s"}' \
   283	      "${id}" \
   284	      "$(_hh_json_escape "${action_type}")" \
   285	      "$([[ -z "${edit_distance}" ]] && echo "null" || echo "${edit_distance}")" \
   286	      "$(_hh_json_escape "${resolution}")" \
   287	      "$(_hh_json_escape "${tone_rules}")" \
   288	      "$(_hh_json_escape "${resolved_at}")"
   289	  done <<<"${rows}"
   290	  printf '],"lookback_days":%s,"source":"db"}\n' "${lookback_days}"
   291	}
   292	
   293	# Exported so tests can introspect.
   294	export _VL_VERSION

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
   123	   → per-source auth FAILURE is BLOCKING per catalogue §2.3/§2.7:
   124	     ESC_BULLHORN_AUTH | ESC_LINKEDIN_AUTH | ESC_REED_AUTH | ESC_CVLIBRARY_AUTH
   125	     — each routes to operator + ifos_oncall. v1.0 v0.3 disposition: if
   126	     ANY source is down, Sourcing Scout halts (any failed source = blocked
   127	     run); waits for operator reauth before retry. Single-source-failure-
   128	     soft-fallback would require a separate ESC_SOURCING_SOURCE_DEGRADED
   129	     catalogue code (W4-polish; not v0.3).
   130	   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
   131	     "sources_ok:<N>/4; failed:<list>")
   132	
   133	3. Bullhorn passive-match query
   134	   → bullhorn.search_candidates(filter=brief_key_dimensions,
   135	     status='active', date_last_modified_at < now() - interval '90 days')
   136	     — "passive" is a derived state (active candidate not recently
   137	     modified); NOT a vertical-schema enum value. The schema defines
   138	     candidate.status as [active, archived, do_not_contact, placed,
   139	     contractor_promoted] (line 84-88) and candidate.date_last_modified_at
   140	     as the recency field (line 100). Passive-match queries filter on
   141	     modification recency within the active set.
   142	   → up to 30 candidates fetched (will rank+filter later)
   143	   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
   144	   → hh_decision_output("bullhorn_query", "brief:<id>", "results:<N>")
   145	
   146	4. LinkedIn search (via Proxycurl)
   147	   → proxycurl.search_people(query=brief_key_dimensions, location=brief_location,
   148	     industry=brief_sector)
   149	   → up to 30 profiles
   150	   → cache 1h per (query, location, sector) tuple
   151	   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
   152	   → hh_decision_output("linkedin_query", "brief:<id>", "results:<N>")
   153	
   154	5. Reed query
   155	   → reed.search_candidates(query=brief_dimensions, location, salary_band)
   156	   → up to 30 candidates
   157	   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
   158	     (payload.upstream='reed')
   159	   → hh_decision_output("reed_query", "brief:<id>", "results:<N>")
   160	
   161	6. CV-Library query
   162	   → cvlibrary.search_candidates(query, location, salary_band)
   163	   → up to 30 candidates
   164	   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
   165	     (payload.upstream='cv-library')
   166	   → hh_decision_output("cvlibrary_query", "brief:<id>", "results:<N>")
   167	
   168	7. Aggregate + dedupe
   169	   → merge all sources into single candidate set
   170	   → dedupe across sources by (name + email) OR (name + phone) OR
   171	     (LinkedIn URL) — same fuzzy matcher as Janitor (confidence ≥0.85)
   172	   → annotate each row with source provenance (e.g., "from Bullhorn + LinkedIn
   173	     match" if found in both)
   174	   → hh_decision_output("aggregate_dedupe", "brief:<id>",
   175	     "pre_dedupe:<N>; post_dedupe:<N>")
   176	
   177	8. "Do not contact" filter (pre-outbound sourcing filter; NOT outbound refusal)
   178	   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
   179	     (already a registered config key per autosend-policy.yaml red-tier
   180	     `send_to_blocked_recipient`; canonical Postgres-stored structured
   181	     state per ADR-002 vault/Postgres split — NOT vault markdown)
   182	   → remove any candidate matching any DNC identifier from the sourcing list
   183	   → log dropped candidates to exception list in §3 output
   184	   → NOTE: ESC_DNC_FILTER_HIT is catalogue §2.10 reserved for OUTBOUND SEND
   185	     REFUSAL specifically. Sourcing Scout filters DNC matches AT SOURCING
   186	     TIME (pre-outbound); no outbound send attempt occurs. v0.3 disposition:
   187	     log DNC drops in exception list only; no ESC fire. W4-polish backlog:
   188	     add ESC_SOURCING_DNC_FILTER for the pre-outbound case.
   189	   → hh_decision_output("dnc_filter", "brief:<id>",
   190	     "dropped:<N>; kept:<N>")
   191	
   192	9. LLM ranking + rationale generation (per candidate)
   193	   → for top 15 by source-aggregated confidence: generate per-candidate
   194	     rationale ≥50 words
   195	   → prompt = (brief context + candidate profile + voice corpus + tone rules)
   196	   → voice classifier scores rationale (≥0.75)
   197	   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
   198	     from final list
   199	   → hh_decision_output("candidate_proposed", "candidate:<bullhorn_id|external_ref>",
   200	     "source:<bullhorn|linkedin|reed|cvlibrary>; confidence:<N>; voice_score:<N>; included:<bool>") — emitted PER CANDIDATE per §3 contract (one row per candidate proposed; dropped candidates also get a row with included=false + drop_reason)
   201	
   202	10. Output assembly + Gate A validation
   203	    → ensure 5-15 candidates remaining after Step 9
   204	    → ensure each has working contact method (email validated via simple
   205	      regex + domain MX check; phone validated via E.164 format)
   206	    → ensure each rationale ≥50 words
   207	    → if any condition fails: ESC_AGENT_OUTPUT_SHAPE (output-shape violation
   208	      per catalogue line 184 — distinct from ESC_SCHEMA_VIOLATION which is
   209	      reserved for vertical-schema field-constraint violations at write time);
   210	      partial draft to /tmp; abort
   211	    → write Markdown report to vault path per §3
   212	    → hh_decision_output("scout_report", report_path, "N candidates from M sources")
   213	
   214	11. Session close + notification
   215	    → operator notification per invocation source (Brain UI: in-app
   216	      notification; Telegram: reply with report path; webhook: bus event back)
   217	    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
   218	      "N=<N> sources_used=<M>")
   219	    → exit code 0
   220	```
   221	
   222	---
   223	
   224	## §5 — Gates
   225	
   226	### Gate A — validate.sh (hard-fail before action)
   227	
   228	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
   229	
   230	- **"5–15 candidates returned per brief"** (count within range)
   231	- **"each has a working contact method"** (email format + MX check OR E.164 phone OR LinkedIn URL OR Bullhorn bullhorn_id-with-contact)
   232	- **"each has rationale ≥ 50 words"**
   233	- **"no candidate flagged 'do not contact' in tenant vault"** (DNC list scan)
   234	- All rationales pass voice classifier ≥0.75
   235	- No PII outside firm boundary in rationale text
   236	- No source contributed 0 candidates (suggests source auth failure undetected by Step 2)
   237	
   238	Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation per catalogue line 184); draft to `/tmp`; operator review.
   239	
   240	**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   241	
   242	### Gate B — Outcome threshold (success metric, not block)
   243	
   244	Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
   245	
   246	Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.
   247	
   248	Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
   249	
   250	Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
   251	
   252	---
   253	
   254	## §6 — Escalation codes
   255	
   256	Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
   257	
   258	| Code | Trigger | Severity | Routing |
   259	|---|---|---|---|
   260	| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (per catalogue §2.3) | operator + ifos_oncall |

exec
/bin/zsh -lc 'rg -n "sourcing_scout|sourcing-scout|scout_run_complete|sourcing|source candidates|consultant_feedback" agents/_shared/autosend-policy.yaml agents/recruitment -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:49:    agent: sourcing-scout
agents/_shared/autosend-policy.yaml:77:  scout_run_complete:
agents/_shared/autosend-policy.yaml:79:    agent: sourcing-scout
agents/_shared/autosend-policy.yaml:107:  consultant_feedback:
agents/_shared/autosend-policy.yaml:177:    agent: sourcing-scout
agents/_shared/autosend-policy.yaml:280:    agent: sourcing-scout
agents/recruitment/sourcing-scout/README.md:1:# Sourcing Scout — directory README
agents/recruitment/sourcing-scout/README.md:33:*End of Sourcing Scout README.*
agents/recruitment/sourcing-scout/agent.md:1:# Sourcing Scout — request-response passive sourcing
agents/recruitment/sourcing-scout/agent.md:16:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate flagged "do not contact" in tenant vault (per ULTRAPLAN A5 line 552 verbatim). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:24:Brain UI v1.0 "Source candidates" button on any brief detail page → POST internal API → Sourcing Scout webhook.
agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
agents/recruitment/sourcing-scout/agent.md:40:ifosctl sourcing-scout source --tenant <slug> --brief-id <id>
agents/recruitment/sourcing-scout/agent.md:41:ifosctl sourcing-scout source --tenant <slug> --description "<free-text>"
agents/recruitment/sourcing-scout/agent.md:54:One output per invocation. Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md`. Structure:
agents/recruitment/sourcing-scout/agent.md:57:# Sourcing Scout — <Brief title>
agents/recruitment/sourcing-scout/agent.md:126:     ANY source is down, Sourcing Scout halts (any failed source = blocked
agents/recruitment/sourcing-scout/agent.md:128:     soft-fallback would require a separate ESC_SOURCING_SOURCE_DEGRADED
agents/recruitment/sourcing-scout/agent.md:177:8. "Do not contact" filter (pre-outbound sourcing filter; NOT outbound refusal)
agents/recruitment/sourcing-scout/agent.md:182:   → remove any candidate matching any DNC identifier from the sourcing list
agents/recruitment/sourcing-scout/agent.md:185:     REFUSAL specifically. Sourcing Scout filters DNC matches AT SOURCING
agents/recruitment/sourcing-scout/agent.md:188:     add ESC_SOURCING_DNC_FILTER for the pre-outbound case.
agents/recruitment/sourcing-scout/agent.md:217:    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
agents/recruitment/sourcing-scout/agent.md:228:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
agents/recruitment/sourcing-scout/agent.md:240:**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/sourcing-scout/agent.md:246:Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.
agents/recruitment/sourcing-scout/agent.md:248:Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
agents/recruitment/sourcing-scout/agent.md:256:Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/sourcing-scout/agent.md:267:(Sourcing Scout does NOT use `ESC_DNC_FILTER_HIT` — per catalogue §2.10 that code is reserved for outbound send refusal; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops are logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish adds ESC_SOURCING_DNC_FILTER.)
agents/recruitment/sourcing-scout/agent.md:272:Sourcing Scout does NOT use:
agents/recruitment/sourcing-scout/agent.md:276:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
agents/recruitment/sourcing-scout/agent.md:277:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/sourcing-scout/agent.md:285:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:290:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:291:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
agents/recruitment/sourcing-scout/agent.md:299:Sourcing Scout build cannot start until ALL of the following are confirmed:
agents/recruitment/sourcing-scout/agent.md:342:| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `last_activity_at < now() - 90 days` to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side activity-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |
agents/recruitment/sourcing-scout/agent.md:370:*End of Sourcing Scout agent.md draft.*
agents/recruitment/diagnostic/agent.md:161:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.
agents/recruitment/diagnostic/agent.md:183:- `ESC_AUTOSEND_*` — Diagnostic's actions are `diagnostic_report_render` + `operator_notify_telegram` + `consultant_feedback` (all green tier per autosend-policy.yaml)
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:22:    - "Quietfield Resourcing"
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:32:      company_name: "Quietfield Resourcing Ltd"
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:47:      slug: "quietfield-resourcing"
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:63:      url: "https://quietfield-resourcing.com/"

exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '260,390p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (per catalogue §2.3) | operator + ifos_oncall |
   261	| `ESC_LINKEDIN_AUTH` | LinkedIn / Proxycurl session/OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   262	| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   263	| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   264	| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
   265	| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
   266	| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   267	(Sourcing Scout does NOT use `ESC_DNC_FILTER_HIT` — per catalogue §2.10 that code is reserved for outbound send refusal; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops are logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish adds ESC_SOURCING_DNC_FILTER.)
   268	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
   269	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
   270	| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | founder + operator |
   271	
   272	Sourcing Scout does NOT use:
   273	
   274	- `ESC_AUTOSEND_*` — no auto-send actions; pure read + report
   275	- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
   276	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
   277	- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
   278	
   279	---
   280	
   281	## §7 — Voice + tone constraints
   282	
   283	Step 9 (per-candidate rationale generation) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   284	
   285	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
   286	  - No demographic inference (age, gender, nationality, ethnicity, family status) — Equality Act 2010 compliance
   287	  - No salary-band reference unless explicitly supplied by candidate
   288	  - No claims about candidate intent ("looking to leave their role") without evidence in source data
   289	  - No mention of competing agency placements except in risk-flag context
   290	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
   291	- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
   292	
   293	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   294	
   295	---
   296	
   297	## §8 — Build dependencies (W9 prerequisites)
   298	
   299	Sourcing Scout build cannot start until ALL of the following are confirmed:
   300	
   301	| Dependency | Source | Status |
   302	|---|---|---|
   303	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   304	| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
   305	| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
   306	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   307	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   308	| Bullhorn MCP read capability | W3-W4-W5 build chain | ⏸ |
   309	| **Proxycurl commercial signup** + API access | Founder commercial; ~$39+/mo | ⏸ |
   310	| **Reed.co.uk commercial signup** + API access | Founder commercial | ⏸ |
   311	| **CV-Library commercial signup** + API access | Founder commercial | ⏸ |
   312	| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
   313	| Reed MCP connector | W9 build start (~2 days) | ⏸ |
   314	| CV-Library MCP connector | W9 build start (~2 days) | ⏸ |
   315	| Source-abstraction layer (Night Sourcer reuse) | W9 build start (~2 days) | ⏸ |
   316	| Per-tenant source credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   317	| Tenant DNC list at `/vault/<slug>/do-not-contact.list` | Tenant onboarding | ⏸ |
   318	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   319	| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
   320	| `context.sh` hydration | Build at W9 start (~0.5 day) | ⏸ |
   321	| `cycle.sh` orchestration (11-step) | Build at W9 start (~2 days) | ⏸ |
   322	| 3 fixtures with golden outputs | Build at W9 start (~1 day) | ⏸ |
   323	
   324	**Until ALL ⏸ items resolve to ✅, W9 build slice does not start.**
   325	
   326	---
   327	
   328	## §9 — Status + open questions
   329	
   330	**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
   331	
   332	### Open questions for founder review
   333	
   334	| # | Question | Resolution path |
   335	|---|---|---|
   336	| Q1 | All three external sources required for v1.0? Reed + CV-Library are UK-recruitment-specific; Proxycurl is LinkedIn-via-API. Could v1.0 ship with Bullhorn + Proxycurl only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
   337	| Q2 | Proxycurl pricing — ~$39/mo for 5,000 credits at low volume; scales with usage. Per pilot tenant budget? | ~5-10 briefs/day per consultant × 50 calls/brief = up to 2,500 credits/day per consultant. Cost: ~$20-50/day at peak. |
   338	| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
   339	| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
   340	| Q5 | Gate B 6-of-10 metric — measured via consultant feedback. Brain UI v1.0 doesn't have feedback UX yet. Telegram reply? | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful". v1.1: Brain UI button. |
   341	| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
   342	| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `last_activity_at < now() - 90 days` to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side activity-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |
   343	
   344	### Gotchas (carried forward from ULTRAPLAN A5 line 555)
   345	
   346	1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
   347	2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
   348	3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.
   349	
   350	---
   351	
   352	## §10 — When this document ratifies
   353	
   354	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   355	
   356	Status flips Proposed → Accepted when:
   357	- Codex Round 4 Phase 2 ratifies
   358	- Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B UX)
   359	- Q2 cost model approved with per-tenant budget cap
   360	- Q6: ADR-006 (source-abstraction layer) drafted + ratified
   361	
   362	Status flips Accepted → In Force when:
   363	- W9 build slice produces all 5 sibling bundle files + 3 fixtures
   364	- First production brief processed end-to-end against migration-test tenant
   365	- Gate B feedback loop operational (Telegram OR Brain UI)
   366	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   367	
   368	Until then: this document is a forward-looking scaffold.
   369	
   370	*End of Sourcing Scout agent.md draft.*

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '35,85p'; nl -ba agents/_shared/autosend-policy.yaml | sed -n '165,185p'; nl -ba agents/_shared/autosend-policy.yaml | sed -n '270,285p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc 'rg -n "blocked_recipients|tenant_adapters|config:" docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/vertical-schema.yaml migrations agents/_shared -S' in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: migrations: No such file or directory (os error 2)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 3 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:738:# §4 — tenant_adapters.config new keys (3 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:741:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:742:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:745:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:853:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:855:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:928:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:940:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:978:    - Concierge tenant_adapters.config field refs valid
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:342:    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
agents/_shared/autosend-policy.yaml:349:    reason: "Recipient in tenant's blocked_recipients override list"
agents/_shared/autosend-policy.yaml:353:# Defaults applied when override fields are absent in tenant_adapters
agents/_shared/escalation-codes.md:426:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
agents/_shared/hook-helpers.sh:286:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
agents/_shared/hook-helpers.sh:393:# tenant override via tenant_adapters.config.sampling_rates.

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '738,790p'" in /Users/madsadmin/code/CortexOS
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
   783	        type: string
   784	        notes: HH:MM 24-hour format
   785	      weekend_send_enabled:
   786	        type: boolean
   787	    notes: |
   788	      Per-tenant outbound sending hours. Concierge respects when scheduling
   789	      orange-tier sends.
   790	

exec
/bin/zsh -lc 'rg -n "consultant_feedback|scout-feedback|sourcing.*feedback|Gate B" agents/_shared/autosend-policy.yaml agents/recruitment/sourcing-scout/agent.md docs/verticals/recruitment -S' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "sourcing_scout|sourcing-scout|agent_name|applies_to_agents" docs/verticals/recruitment agents/recruitment agents/_shared -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:107:  consultant_feedback:
agents/_shared/autosend-policy.yaml:110:    reason: "Gate B feedback row written when consultant tags a Diagnostic report as booked|not-booked via Telegram (/diagnostic-feedback <report-id> ...) or Brain UI button. agent_name='diagnostic'; phase='action'; payload includes report_id + outcome. Internal-only; no external send."
agents/recruitment/sourcing-scout/agent.md:16:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate flagged "do not contact" in tenant vault (per ULTRAPLAN A5 line 552 verbatim). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:242:### Gate B — Outcome threshold (success metric, not block)
agents/recruitment/sourcing-scout/agent.md:248:Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
agents/recruitment/sourcing-scout/agent.md:340:| Q5 | Gate B 6-of-10 metric — measured via consultant feedback. Brain UI v1.0 doesn't have feedback UX yet. Telegram reply? | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful". v1.1: Brain UI button. |
agents/recruitment/sourcing-scout/agent.md:358:- Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B UX)
agents/recruitment/sourcing-scout/agent.md:365:- Gate B feedback loop operational (Telegram OR Brain UI)
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.

 succeeded in 0ms:
agents/recruitment/sourcing-scout/agent.md:16:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate flagged "do not contact" in tenant vault (per ULTRAPLAN A5 line 552 verbatim). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:40:ifosctl sourcing-scout source --tenant <slug> --brief-id <id>
agents/recruitment/sourcing-scout/agent.md:41:ifosctl sourcing-scout source --tenant <slug> --description "<free-text>"
agents/recruitment/sourcing-scout/agent.md:54:One output per invocation. Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md`. Structure:
agents/recruitment/sourcing-scout/agent.md:240:**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/sourcing-scout/agent.md:285:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:291:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
agents/_shared/escalation-codes.md:16:agent_name        — the agent firing the escalation (or '_renderer')
agents/_shared/escalation-codes.md:114:- **Payload fields:** `reason` (one of `schema-validation-failure`, `bundle-malformed`, `shared-helpers-missing`, `tenant-not-provisioned`, `atomic-rename-failed`, `non-rendered-target`), `agent_name_attempted`, `tenant_slug_attempted`
agents/_shared/escalation-codes.md:115:- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7
agents/_shared/escalation-codes.md:125:- **Payload fields:** `final_classifier_score`, `retry_count`, `agent_name`, `task_summary`
agents/_shared/escalation-codes.md:175:- **Payload fields:** `tenant_slug`, `drift_event_count`, `window_days`, `affected_agents` (list of agent_name)
agents/_shared/escalation-codes.md:189:- **Payload fields:** `agent_name`, `output_path`, `shape_rule_violated`, `expected_value`, `actual_value`
agents/_shared/escalation-codes.md:363:- **Payload fields:** `race_class` (`duplicate_payload` | `state_change_cancellation`), `payload_hash`, class-specific: duplicate → `first_agent_name`, `second_agent_name`, `time_delta_ms`, `action_type`; state-change → `entity_id`, `state_before`, `state_after`, `time_delta_ms`
agents/_shared/escalation-codes.md:382:- **Payload fields:** `agent_name`, `metric_name`, `actual_value`, `threshold`, `window`, `sample_size`
agents/_shared/escalation-codes.md:390:- **Payload fields:** `tone_rule_id`, `pattern_violated`, `output_snippet_redacted`, `agent_name`, `tenant_slug`
agents/_shared/escalation-codes.md:398:- **Payload fields:** `entity_type`, `field_name`, `extracted_value`, `confidence_score`, `source` (e.g. `companies-house`, `linkedin`, `cv-pdf`), `agent_name`
agents/_shared/escalation-codes.md:414:- **Payload fields:** `agent_name`, `mismatch_class` (one of `cash_conductor_xero_bullhorn` | `concierge_candidate_email` | future variant), plus class-specific fields: Cash Conductor → `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`); Concierge → `expected_candidate_bullhorn_id`, `actual_recipient_email`, `event_type`
agents/_shared/escalation-codes.md:455:- **Payload fields:** `agent_name`, `entity_type` (`placement` | `candidate_lifecycle_event`), `entity_id`, `ambiguity_class` (Janitor: e.g. `missing_end_date`, `stale_activity`; Concierge: e.g. `unknown_transition`, `out_of_taxonomy`), plus class-specific fields
agents/_shared/escalation-codes.md:477:4. Default `agent_name` to `${CTX_AGENT_NAME}` or `_renderer` (renderer-only sentinel)
agents/_shared/README.md:36:| `CTX_AGENT_NAME` | **yes** | Bundle agent name | — |
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:119:   CTX_AGENT_NAME="test-agent" \
agents/_shared/README.md:152:   CTX_AGENT_NAME=test-agent \
agents/_shared/hook-helpers.sh:113:  agent="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"
agents/_shared/hook-helpers.sh:121:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
agents/_shared/hook-helpers.sh:149:  row=$(printf '{"tenant_slug":"%s","agent_name":"%s","phase":"%s","outcome":%s,"reason":%s,"payload":%s,"created_at":"%s","_hh_version":"%s"}' \
agents/_shared/hook-helpers.sh:443:    printf -- '- **Agent:** %s\n' "${CTX_AGENT_NAME:-unknown}"
agents/recruitment/diagnostic/cleanup.sh:79:hh_decision_action "diagnostic_cleanup" "agent:${CTX_AGENT_NAME:-diagnostic}" \
agents/recruitment/scribe/agent.md:82:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:234:- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
agents/recruitment/scribe/agent.md:272:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/_shared/autosend-policy.yaml:49:    agent: sourcing-scout
agents/_shared/autosend-policy.yaml:79:    agent: sourcing-scout
agents/_shared/autosend-policy.yaml:110:    reason: "Gate B feedback row written when consultant tags a Diagnostic report as booked|not-booked via Telegram (/diagnostic-feedback <report-id> ...) or Brain UI button. agent_name='diagnostic'; phase='action'; payload includes report_id + outcome. Internal-only; no external send."
agents/_shared/autosend-policy.yaml:177:    agent: sourcing-scout
agents/_shared/autosend-policy.yaml:280:    agent: sourcing-scout
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:357:  # layer (cycle.sh + hh_decision_action) where the agent_name in the
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:414:  sourcing_scout:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:416:    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:575:      applies_to_agents containing 'janitor' for tacit-note narrative
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:691:    sourcing_scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:700:    sourcing_scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:709:    sourcing_scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:720:    sourcing_scout: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:727:    sourcing_scout: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:734:    sourcing_scout: none
agents/recruitment/cash-conductor/agent.md:93:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:114:Each draft produces TWO `decision_log` rows on the cash-conductor agent_name:
agents/recruitment/cash-conductor/agent.md:356:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/diagnostic/validate.sh:20:#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_VOICE_CORPUS_ID,
agents/recruitment/diagnostic/validate.sh:54:if [[ -z "${CTX_TENANT_SLUG:-}" || -z "${CTX_AGENT_NAME:-}" ]]; then
agents/recruitment/diagnostic/validate.sh:55:  printf 'validate.sh: CTX_TENANT_SLUG or CTX_AGENT_NAME unset\n' >&2
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:152:      applies_to_agents:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:202:      agent_name:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:205:        source: IFOS-derived (from CTX_AGENT_NAME at edit-capture time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:75:# Returns active tone_rule rows filtered to agent_name (or all rules if
agents/_shared/voice-loader.sh:76:# agent_name absent). JSON shape:
agents/_shared/voice-loader.sh:80:  local agent_name="${1:-${CTX_AGENT_NAME:-}}"
agents/_shared/voice-loader.sh:84:    if [[ -n "${agent_name}" ]]; then
agents/_shared/voice-loader.sh:88:             AND (cardinality(applies_to_agents) = 0 OR '$(_hh_json_escape "${agent_name}")' = ANY(applies_to_agents))
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:225:# Returns recent_edit rows from the last <lookback_days> for <agent_name>
agents/_shared/voice-loader.sh:235:  local agent_name="${2:-${CTX_AGENT_NAME:-}}"
agents/_shared/voice-loader.sh:244:    if [[ -n "${agent_name}" ]]; then
agents/_shared/voice-loader.sh:247:           WHERE agent_name = '$(_hh_json_escape "${agent_name}")'
agents/_shared/tests/test-hook-helpers.sh:78:export CTX_AGENT_NAME="test-agent"
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:73:Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.
agents/recruitment/janitor/agent.md:151:   → SELECT from decision_log WHERE agent_name='janitor' AND created_at >
agents/recruitment/janitor/agent.md:230:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/diagnostic/cycle.sh:163:    '{"escalation_code":"ESC_AGENT_OUTPUT_SHAPE","agent_name":"diagnostic","shape_rule_violated":"non_empty_output","expected_value":"non-empty stdout","actual_value":"empty"}' >/dev/null
agents/recruitment/diagnostic/context.sh:19:#       CTX_AGENT_NAME=diagnostic
agents/recruitment/diagnostic/context.sh:35:CTX_AGENT_NAME="diagnostic"
agents/recruitment/diagnostic/context.sh:36:export CTX_AGENT_NAME
agents/_shared/tests/test-voice-loader.sh:57:export CTX_AGENT_NAME="concierge"
agents/_shared/tests/test-voice-loader.sh:139:_test_run "recent_edits accepts 7-day lookback + agent_name" test_recent_edits_custom_lookback
agents/recruitment/diagnostic/fixtures/01-primary.yaml:99:    agent_name: diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:102:    agent_name: diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:105:    agent_name: diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:109:    agent_name: diagnostic
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:140:        enum: [linkedin, referral, bullhorn_existing, direct_application, sourcing_scout, other]
docs/verticals/recruitment/vertical-schema.yaml:712:  Sourcing_Scout:
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:872:      Codex Day-7 ratification reviews whether stricter source-field schema would improve machine-parseability. If accepted, v1.0 introduces structured source object — e.g., `source: {origin: bullhorn | ifos_derived, bullhorn_field?: <entity.field>, ifos_agent?: <agent_name>, citation?: <doc-ref>}`.
agents/recruitment/diagnostic/agent.md:161:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.
agents/recruitment/diagnostic/agent.md:181:- `ESC_RENDERER_FAILED` — that code is owned by the `_renderer` sentinel (agent_name='_renderer') per catalogue §2.4; Diagnostic never fires it
agents/recruitment/diagnostic/agent.md:192:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:197:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:119:  applies_to_agents   TEXT[]      NOT NULL DEFAULT '{}',
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:144:  agent_name             TEXT        NOT NULL,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:160:CREATE INDEX IF NOT EXISTS recent_edit_tenant_agent_idx ON recent_edit (tenant_slug, agent_name, resolved_at DESC);
agents/recruitment/concierge/agent.md:102:Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).
agents/recruitment/concierge/agent.md:329:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:

exec
/bin/zsh -lc 'find agents/recruitment/sourcing-scout -maxdepth 2 -type f -print' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/README.md | sed -n '1,80p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/sourcing-scout/agent.md
agents/recruitment/sourcing-scout/README.md

 succeeded in 0ms:
     1	# Sourcing Scout — directory README
     2	
     3	**Status:** Proposed (Day-19 pre-W9-build scaffold).
     4	
     5	## What's in this directory
     6	
     7	| File | Status |
     8	|---|---|
     9	| `agent.md` | Proposed |
    10	| `README.md` | Proposed |
    11	
    12	## What's NOT in this directory (yet)
    13	
    14	Full bundle at W9 build (~2 weeks per ULTRAPLAN A5 line 554):
    15	
    16	- `tools.yaml` — Bullhorn R + Proxycurl + Reed + CV-Library + source-abstraction layer
    17	- `context.sh` — multi-source auth refresh + voice corpus + DNC list load
    18	- `validate.sh` — Gate A (5-15 candidates + contact method + ≥50 words + DNC + voice ≥0.75)
    19	- `cycle.sh` — 11-step workflow
    20	- `cleanup.sh` — cache cleanup + per-source token rotation
    21	- `fixtures/01-primary-perm-fintech.yaml` — golden: perm role, ≥10 candidates from 4 sources
    22	- `fixtures/02-edge-case-niche-role.yaml` — niche role: only 5-7 candidates available
    23	- `fixtures/99-dnc-filter-canary.yaml` — adversarial: many candidates hit DNC list
    24	
    25	## Night Sourcer (v1.1) reuse
    26	
    27	Per ULTRAPLAN A5 line 555 gotcha: source-abstraction layer designed for Night Sourcer reuse. Defer ADR-006 to W9 build start documenting the layer's interface.
    28	
    29	## Ratification
    30	
    31	Codex Round 4 Phase 2 (Day 20) via `review-architecture-decision.md`.
    32	
    33	*End of Sourcing Scout README.*

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '400,430p'; nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '680,730p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   400	    # bullhorn-integration-path.md §1.2 A4 ("No direct Bullhorn"). All
   401	    # entity reads below are against IFOS-cached Postgres rows
   402	    # (populated by Janitor + Scribe + Concierge from their Bullhorn
   403	    # sync paths). Cash Conductor never calls Bullhorn endpoints directly.
   404	    candidate: none        # no Bullhorn dependency
   405	    contractor: none
   406	    client: R              # IFOS-cached read; client billing details
   407	    contact: R             # IFOS-cached read; invoice addressee resolution
   408	    brief: none
   409	    opportunity: R         # v0.3 NEW — IFOS-cached read; invoice-context (NOT a direct Bullhorn call; only cached rows)
   410	    placement: R           # IFOS-cached read; client linkage on invoice
   411	    timesheet: R           # IFOS-cached read; verify billable hours match invoice (NOT a direct Bullhorn call)
   412	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   413	
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
   701	    concierge: R
   702	  tone_rule:
   703	    # v0.2 auxiliary table — per-tenant tone constraints
   704	    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents
   705	    diagnostic: R
   706	    janitor: R
   707	    scribe: R
   708	    cash_conductor: R
   709	    sourcing_scout: R
   710	    concierge: R
   711	  recent_edit:
   712	    # v0.2 auxiliary table — consultant edits for retraining/drift detection
   713	    # Per §2a amendment: v0.3 expands access (Concierge R from v0.2;
   714	    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
   715	    # Scout add W to write own retraining edits; Diagnostic remains none)
   716	    diagnostic: none
   717	    janitor: R
   718	    scribe: W
   719	    cash_conductor: W
   720	    sourcing_scout: W
   721	    concierge: R
   722	  cash_conductor_transactions:
   723	    diagnostic: none
   724	    janitor: none
   725	    scribe: none
   726	    cash_conductor: R+W
   727	    sourcing_scout: none
   728	    concierge: none
   729	  cash_conductor_invoices:
   730	    diagnostic: none

exec
/bin/zsh -lc 'rg -n "cash_conductor_run_complete|cash-conductor|cash_conductor" agents/_shared/autosend-policy.yaml agents/recruitment/cash-conductor/agent.md -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:55:    agent: cash-conductor
agents/_shared/autosend-policy.yaml:101:  cash_conductor_run_complete:
agents/_shared/autosend-policy.yaml:103:    agent: cash-conductor
agents/_shared/autosend-policy.yaml:184:    agent: cash-conductor
agents/_shared/autosend-policy.yaml:205:    agent: cash-conductor
agents/_shared/autosend-policy.yaml:259:    agent: cash-conductor
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 257; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 182-187 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 257-262; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:26:POST https://<tenant>.ifos.app/agents/cash-conductor/webhook
agents/recruitment/cash-conductor/agent.md:42:0 7 * * * sudo -u ifos_user /usr/local/bin/ifos-cash-conductor.sh --tenant <slug> --mode daily-sweep
agents/recruitment/cash-conductor/agent.md:49:0 6 * * 1 sudo -u ifos_user /usr/local/bin/ifos-cash-conductor.sh --tenant <slug> --mode weekly-report
agents/recruitment/cash-conductor/agent.md:62:ifosctl cash-conductor reconcile --tenant <slug> [--invoice <id>]
agents/recruitment/cash-conductor/agent.md:63:ifosctl cash-conductor draft-chase --tenant <slug> --invoice <id>
agents/recruitment/cash-conductor/agent.md:64:ifosctl cash-conductor weekly-report --tenant <slug>
agents/recruitment/cash-conductor/agent.md:93:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:114:Each draft produces TWO `decision_log` rows on the cash-conductor agent_name:
agents/recruitment/cash-conductor/agent.md:119:When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml line 257; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).
agents/recruitment/cash-conductor/agent.md:134:Located at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md`. Generated Monday 06:00 UTC. Six sections:
agents/recruitment/cash-conductor/agent.md:174:   → store in Postgres table `cash_conductor_transactions` (RLS-isolated per
agents/recruitment/cash-conductor/agent.md:183:   → store in Postgres table `cash_conductor_invoices` (RLS-isolated;
agents/recruitment/cash-conductor/agent.md:207:     sent (read from `cash_conductor_invoices.last_chase_position` — v0.3
agents/recruitment/cash-conductor/agent.md:255:      action_type per autosend-policy.yaml line 257; agent: cash-conductor).
agents/recruitment/cash-conductor/agent.md:259:    → Cash Conductor updates `cash_conductor_invoices.last_chase_position`
agents/recruitment/cash-conductor/agent.md:261:    → hh_decision_output("cash_conductor_chase_sent_recorded",
agents/recruitment/cash-conductor/agent.md:277:    → write to /vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md
agents/recruitment/cash-conductor/agent.md:282:    → update tenant_adapters.config.cash_conductor_last_run = now()
agents/recruitment/cash-conductor/agent.md:283:    → hh_decision_action("cash_conductor_run_complete", "session:<session_id>",
agents/recruitment/cash-conductor/agent.md:308:**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/cash-conductor/agent.md:356:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:361:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.

exec
/bin/zsh -lc "ls -la .codex/ratification 2>/dev/null || true; rg --files .codex 2>/dev/null | rg 'review-agent-bundle|ratification'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
total 112
drwxr-xr-x@ 7 madsadmin  staff    224 May 24 11:19 .
drwxr-xr-x@ 3 madsadmin  staff     96 May 20 13:08 ..
-rw-r--r--@ 1 madsadmin  staff   7686 May 20 13:08 SKILL.md
-rw-r--r--@ 1 madsadmin  staff  11759 May 24 11:19 review-agent-bundle.md
-rw-r--r--@ 1 madsadmin  staff  11166 May 22 13:23 review-architecture-decision.md
-rw-r--r--@ 1 madsadmin  staff  11256 May 22 16:17 review-postgres-migration.md
-rw-r--r--@ 1 madsadmin  staff   9804 May 20 13:10 review-schema-change.md
.codex/ratification/review-agent-bundle.md
.codex/ratification/SKILL.md
.codex/ratification/review-postgres-migration.md
.codex/ratification/review-schema-change.md
.codex/ratification/review-architecture-decision.md

codex
REJECTED

1. DNC source violates the vault/Postgres split and is internally inconsistent. §1 line 16, §4 step 0 lines 107-109, §5 line 233, and §8 line 317 describe the DNC list as tenant vault content, while §4 step 8 lines 177-181 and §9 Q3 line 338 correctly make `tenant_adapters.config.blocked_recipients` the canonical Postgres-stored structured state. This mixes structured suppression state into markdown/vault and creates two competing sources of truth. Fix by making `tenant_adapters.config.blocked_recipients` the only v1.0 DNC source, removing `/vault/<slug>/do-not-contact.list`, and noting ULTRAPLAN line 552 as wording drift if needed.

2. Gate B feedback is not tied to a registered Sourcing Scout audit action. §5 lines 246-248 and §9 Q5 line 340 define consultant feedback via Brain UI/Telegram/Bullhorn note, but the only `consultant_feedback` action_type currently registered in `agents/_shared/autosend-policy.yaml` is Diagnostic-specific (`agent: diagnostic`, lines 107-110). That leaves the Gate B measurement path without a valid `decision_log` signature for Sourcing Scout. Fix by registering a Sourcing Scout feedback action_type, or by explicitly naming the future registration as a blocking prerequisite before Accepted.

3. §6 escalation-code table is malformed. Line 267 inserts a free-standing parenthetical note inside the Markdown table between `ESC_VOICE_DRIFT` and `ESC_PII_LEAKAGE_RISK`, so the final three escalation rows are no longer part of a well-formed table. This is load-bearing because the agent-bundle skill requires a clear subset of catalogue ESC codes. Fix by moving the DNC note below the table and keeping every ESC row pipe-delimited.
tokens used
126,924
REJECTED

1. DNC source violates the vault/Postgres split and is internally inconsistent. §1 line 16, §4 step 0 lines 107-109, §5 line 233, and §8 line 317 describe the DNC list as tenant vault content, while §4 step 8 lines 177-181 and §9 Q3 line 338 correctly make `tenant_adapters.config.blocked_recipients` the canonical Postgres-stored structured state. This mixes structured suppression state into markdown/vault and creates two competing sources of truth. Fix by making `tenant_adapters.config.blocked_recipients` the only v1.0 DNC source, removing `/vault/<slug>/do-not-contact.list`, and noting ULTRAPLAN line 552 as wording drift if needed.

2. Gate B feedback is not tied to a registered Sourcing Scout audit action. §5 lines 246-248 and §9 Q5 line 340 define consultant feedback via Brain UI/Telegram/Bullhorn note, but the only `consultant_feedback` action_type currently registered in `agents/_shared/autosend-policy.yaml` is Diagnostic-specific (`agent: diagnostic`, lines 107-110). That leaves the Gate B measurement path without a valid `decision_log` signature for Sourcing Scout. Fix by registering a Sourcing Scout feedback action_type, or by explicitly naming the future registration as a blocking prerequisite before Accepted.

3. §6 escalation-code table is malformed. Line 267 inserts a free-standing parenthetical note inside the Markdown table between `ESC_VOICE_DRIFT` and `ESC_PII_LEAKAGE_RISK`, so the final three escalation rows are no longer part of a well-formed table. This is load-bearing because the agent-bundle skill requires a clear subset of catalogue ESC codes. Fix by moving the DNC note below the table and keeping every ESC row pipe-delimited.
