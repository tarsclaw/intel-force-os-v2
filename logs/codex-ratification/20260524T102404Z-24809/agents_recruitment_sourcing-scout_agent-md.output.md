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
session id: 019e5983-6961-7801-a9e2-ba3fed9f13fb
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

> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate flagged "do not contact" in tenant vault (per ULTRAPLAN A5 line 553 verbatim). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 554 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).

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
   → ESC_BRIEF_UNDERSPECIFIED if extraction yields <3 key dimensions

2. Multi-source auth refresh
   → bullhorn (read-only); LinkedIn/Proxycurl; Reed; CV-Library
   → per-source ESC_<SOURCE>_AUTH on refresh failure
   → if 2+ sources fail auth: ESC_SCHEMA_VIOLATION (abort early; insufficient
     coverage for Gate A 5-15 candidates)

3. Bullhorn passive-match query
   → bullhorn.search_candidates(filter=brief_key_dimensions, status=passive)
   → up to 30 candidates fetched (will rank+filter later)
   → ESC_RATE_LIMIT_HIT on 429

4. LinkedIn search (via Proxycurl)
   → proxycurl.search_people(query=brief_key_dimensions, location=brief_location,
     industry=brief_sector)
   → up to 30 profiles
   → cache 1h per (query, location, sector) tuple
   → ESC_LINKEDIN_RATE_LIMIT on Proxycurl quota hit

5. Reed query
   → reed.search_candidates(query=brief_dimensions, location, salary_band)
   → up to 30 candidates
   → ESC_REED_AUTH on auth fail; ESC_REED_RATE_LIMIT on quota

6. CV-Library query
   → cvlibrary.search_candidates(query, location, salary_band)
   → up to 30 candidates
   → ESC_CVLIBRARY_AUTH or _RATE_LIMIT

7. Aggregate + dedupe
   → merge all sources into single candidate set
   → dedupe across sources by (name + email) OR (name + phone) OR
     (LinkedIn URL) — same fuzzy matcher as Janitor (confidence ≥0.85)
   → annotate each row with source provenance (e.g., "from Bullhorn + LinkedIn
     match" if found in both)

8. "Do not contact" filter
   → load tenant /vault/<slug>/do-not-contact.list (one identifier per line:
     email / phone / LinkedIn URL / Bullhorn CRN)
   → remove any candidate matching any DNC identifier
   → log dropped candidates to exception list
   → ESC_DNC_FILTER_HIT if >5 candidates dropped (suggests over-eager
     search; brief may be poorly scoped)

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
    → if any condition fails: ESC_SCHEMA_VIOLATION; partial draft to /tmp;
      abort
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

Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 553 verbatim):

- **"5–15 candidates returned per brief"** (count within range)
- **"each has a working contact method"** (email format + MX check OR E.164 phone OR LinkedIn URL OR Bullhorn CRN-with-contact)
- **"each has rationale ≥ 50 words"**
- **"no candidate flagged 'do not contact' in tenant vault"** (DNC list scan)
- All rationales pass voice classifier ≥0.75
- No PII outside firm boundary in rationale text
- No source contributed 0 candidates (suggests source auth failure undetected by Step 2)

Gate A failures fire `ESC_SCHEMA_VIOLATION`; draft to `/tmp`; operator review.

### Gate B — Outcome threshold (success metric, not block)

Per ULTRAPLAN A5 line 554 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.

Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.

Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).

Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha §6.4 of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.

---

## §6 — Escalation codes

Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (2+ source fails abort) | operator |
| `ESC_LINKEDIN_AUTH` | Proxycurl API key invalid | warn (single-source fail OK if 2+ others succeed) | operator_chat_id |
| `ESC_LINKEDIN_RATE_LIMIT` | Proxycurl quota exceeded | warn | operator_chat_id |
| `ESC_REED_AUTH` | Reed API fail | warn | operator_chat_id |
| `ESC_REED_RATE_LIMIT` | Reed 429 | warn | operator_chat_id |
| `ESC_CVLIBRARY_AUTH` | CV-Library API fail | warn | operator_chat_id |
| `ESC_CVLIBRARY_RATE_LIMIT` | CV-Library 429 | warn | operator_chat_id |
| `ESC_BRIEF_UNDERSPECIFIED` | LLM brief-parse yields <3 key dimensions | warn | operator_chat_id |
| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
| `ESC_DNC_FILTER_HIT` | >5 candidates dropped by DNC list | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
| `ESC_SCHEMA_VIOLATION` | Gate A failure | **blocking** | operator + ifos_oncall |
| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | founder + operator |
| `ESC_RATE_LIMIT_HIT` | Any source 429 (general) | warn | operator_chat_id |

Sourcing Scout does NOT use:

- `ESC_AUTOSEND_*` — no auto-send actions; pure read + report
- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
- `ESC_VOICE_DRIFT_TENANT` — per-candidate drift detected at run time (above); no separate 30-day tenant drift signal

---

## §7 — Voice + tone constraints

Step 9 (per-candidate rationale generation) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
  - No demographic inference (age, gender, nationality, ethnicity, family status) — Equality Act 2010 compliance
  - No salary-band reference unless explicitly supplied by candidate
  - No claims about candidate intent ("looking to leave their role") without evidence in source data
  - No mention of competing agency placements except in risk-flag context
- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Edit-distance >100 chars on >40% of recent_edit rows fires `ESC_VOICE_DRIFT_TENANT`.

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
| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 553 says "≥ 50 words" — using as floor. |
| Q5 | Gate B 6-of-10 metric — measured via consultant feedback. Brain UI v1.0 doesn't have feedback UX yet. Telegram reply? | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful". v1.1: Brain UI button. |
| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Existing Bullhorn candidate-status enum has "passive" / "active" / "placed". | Founder + Bullhorn-rep clarification during Sub-decision B response. |

### Gotchas (carried forward from ULTRAPLAN A5 line 555)

1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-architecture-decision.md` skill: this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.

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
I’ll verify the cited project files and catalogue entries against the artefact, then return only the required ratification verdict.
exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_AUTH|ESC_LINKEDIN_AUTH|ESC_LINKEDIN_RATE_LIMIT|ESC_REED_AUTH|ESC_REED_RATE_LIMIT|ESC_CVLIBRARY_AUTH|ESC_CVLIBRARY_RATE_LIMIT|ESC_BRIEF_UNDERSPECIFIED|ESC_VOICE_DRIFT|ESC_DNC_FILTER_HIT|ESC_PII_LEAKAGE_RISK|ESC_SCHEMA_VIOLATION|ESC_GATE_B_MISS|ESC_RATE_LIMIT_HIT|ESC_VOICE_DRIFT_TENANT" agents/_shared/escalation-codes.md -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
97:#### `ESC_BULLHORN_AUTH`
120:#### `ESC_VOICE_DRIFT`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar

exec
/bin/zsh -lc 'rg -n "Sourcing Scout|A5|W9|Trigger 3|Change 1|Change 2|Proxycurl|review-agent-bundle|review-architecture-decision" docs agents packages -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/diagnostic-generator/src/generate.ts:49:    `**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).`,
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:158:- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
agents/_shared/escalation-codes.md:246:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
docs/verticals/recruitment/vertical-schema.yaml:55:      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:141:        source: IFOS-derived (set by Sourcing Scout at first-touch)
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:349:      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:637:    v1_0_exercise: Sourcing Scout captures at first-touch when relevant; not heavily exercised in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:841:    revisit_trigger: Skill-matching accuracy from Sourcing Scout's first 4 tenant-weeks of operation; if free-text matching produces <60% precision, canonical skill taxonomy lands as v1.1.
packages/agents-runtime/_shared/common-voice.json:5:  "description": "Per-tenant voice corpus reference. Read by agents/_shared/voice-loader.sh per master brief §8.1 Change 1. Schema substrate landed in vertical-schema.yaml v0.2 (Phase 4).",
agents/_shared/hook-helpers.sh:4:# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
agents/_shared/hook-helpers.sh:163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
packages/diagnostic-generator/src/sections/online-footprint.ts:87:      `LinkedIn company page: [${data.linkedInUrl}](${data.linkedInUrl}) (page exists; LinkedIn bot-detection returned ${data.linkedInStatus}, full content needs authenticated fetch — Proxycurl integration v1.1).`,
agents/_shared/voice-loader.sh:4:# §8.1 Change 1. Sourced by every agent's context.sh at session start; emits
packages/harness/cortextos/package-lock.json:1184:      "integrity": "sha512-HHMwmarRKvoFsJorqYlFeFRzXZqCt2ETQlEDOb9aqssrnVBB1/+xgTGtuTrIk5vzLNX1MjMtTf7W9z3tsSbrxw==",
packages/harness/cortextos/package-lock.json:1345:      "integrity": "sha512-4LqhUomJqwe641gsPp6xLfhqWMbQV04KtPp7/dIp0nzPxAkNY1AbwL5W0MQpcalLYk07vaW9Kp1PBhdpZYYcEw==",
packages/harness/cortextos/package-lock.json:2605:      "integrity": "sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==",
packages/harness/cortextos/package-lock.json:2640:      "integrity": "sha512-C8oWjPR3F81yljW9o5OxcWzfh6avkVwDD2VYdwIGqTkl+OGFISgypqzfu7dOe4QNLL2aqcWBmI3PMtLIK233lw==",
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
agents/_shared/README.md:98:### `voice-loader.sh` helpers (3, master brief §8.1 Change 1)
packages/agents-runtime/_shared/common-target-patch.json:5:  "description": "Tenant's commercial sweet spot: sectors, geography, deal sizes, allow/block lists. Read by Sourcing Scout (W9) + Diagnostic (W3-4). Per PRODUCT-SPEC §5.3 line 363.",
packages/agents-runtime/_shared/common-target-patch.json:38:      "description": "Bands surface in Diagnostic ICP scoring + Sourcing Scout shortlist filtering."
packages/diagnostic-generator/src/sections/recent-activity.ts:55:    "**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.",
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:226:4. **Codex ratification** — invariant document is ratified via `review-architecture-decision.md` skill; updates re-ratify.
docs/architecture/tenancy-invariants.md:259:**Reference (In Force on tenant-data write paths).** Codex ratification queue item #35; ratified via `.codex/ratification/review-architecture-decision.md`. Companion audit script at `scripts/run-tenancy-audit.sh` ratified as item #38. Both queued for Codex Round 3 after this commit ships.
packages/harness/cortextos/src/utils/ws-unix-client.ts:80:      .update(key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')
docs/architecture/architecture-cohesion-review.md:92:| A5 | **The cortextOS daemon `discoverAgents()` filters by directory pattern, not contents.** Means `.tmp.<pid>/` + `.prev.<ts>/` dirs are invisible. | ADR-003 §3.3.4 atomic-write protocol | If daemon scan ever changes to content-based discovery, the atomic-write protocol could expose half-rendered state. Verified against pinned SHA `c21fbfe`. |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:188:  - **A:** Codex review skill `review-agent-bundle.md` (not yet built) would catch this. Currently relies on grep audit + author discipline. Recommend: add this check to `scripts/run-tenancy-audit.sh` (Phase 1 enhancement OR Codex skill).
docs/architecture/architecture-cohesion-review.md:190:**Verdict: BOUNDARY HOLDS at current artefact set.** Future agents need automated guardrail; queue as Phase-1 extension OR `review-agent-bundle.md` skill at Diagnostic W3.
docs/architecture/architecture-cohesion-review.md:215:  - **A:** R2 commitment (ADR-003 Decision 1): tools.yaml can opt-in to cortextOS skills via `cortextos_skills:` block. If an agent opts in to `knowledge-base`, it gets the upstream KB. **This is the seam.** Currently no agent opts in. Recommend: add `review-agent-bundle.md` skill check to flag any `knowledge-base` opt-in for explicit founder review.
docs/architecture/architecture-cohesion-review.md:234:| R8 | Adapter + brain-replacement boundary automation | Medium | `review-agent-bundle.md` Codex skill at Diagnostic W3 | Claude Code | Diagnostic W3 |
docs/architecture/architecture-cohesion-review.md:268:**Reference.** Codex Day-7 manifest queue item #36; ratifies via `review-architecture-decision.md` skill. Companion to `docs/architecture/tenancy-invariants.md`.
packages/diagnostic-generator/src/sections/stubs.ts:26:    "**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.",
packages/diagnostic-generator/src/sections/stubs.ts:40:    "**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/stubs.ts:57:    "**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/stubs.ts:67:    "**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/stubs.ts:79:    "**v0 limitation:** competitor inference requires scanning LinkedIn employee employment-history for other-recruitment-agency names — needs Proxycurl-style profile data.",
packages/diagnostic-generator/src/sections/stubs.ts:100:      "**v0 limitation:** identifying _hiring_ decision-makers (head of talent / chief people officer / hiring manager) requires LinkedIn employee search filtered by title. Wire Proxycurl (W4 polish).",
agents/recruitment/cash-conductor/README.md:37:Codex Round 4 Phase 2 (Day 20) via `review-architecture-decision.md`.
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:369:Decision-log calls are mandatory per master brief §8.1 Change 2:
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
packages/agent-renderer/templates/claude-md-preamble.md:20:Decision-log calls are mandatory per master brief §8.1 Change 2:
agents/recruitment/cash-conductor/agent.md:137:14 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/cash-conductor/agent.md:240:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 539 verbatim):
agents/recruitment/cash-conductor/agent.md:300:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/cash-conductor/agent.md:361:Per `.codex/ratification/review-architecture-decision.md` skill: this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/cash-conductor/agent.md:373:- Codex re-ratifies post-build via `review-agent-bundle.md` skill
packages/diagnostic-generator/src/sections/icp-fit.ts:77:    "**v0 limitation:** geography + deal_size_band scoring requires LinkedIn job-post data. Wire Proxycurl (W4 polish).",
agents/recruitment/scribe/README.md:27:Codex Round 4 Phase 2 (Day 20) via `review-architecture-decision.md`.
docs/architecture/cortexos-primitive-status.md:182:1. **No `chokidar` watcher in the bus.** The bus is poll-based, not push-based. `grep -rn chokidar src/` returns zero hits; `chokidar@^5.0.0` in `package.json:47` is used only by `dashboard/src/lib/watcher.ts:5` for the dashboard UI's file change feed, not for inter-agent message delivery. Master brief §2.4 row 3's "chokidar watcher in daemon" is incorrect against the verified SHA. The actual dispatcher is `FastChecker` polling at `pollInterval` (default 1000ms, configurable). Operational impact: message-delivery latency is bounded by the poll interval, not zero-latency event-driven; relevant for the Brief Decoder → Sourcing Scout → Concierge "four-agent pipelines complete in seconds" claim (Ultraplan §3.2). With 1s polling per hop and 3 hops, end-to-end is ≥3s, not sub-second.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown attachment containing the consultant's "things I'd write down but there's no field for" observations. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:127:10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/scribe/agent.md:202:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:263:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/scribe/agent.md:321:Per `.codex/ratification/review-architecture-decision.md` skill: this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/scribe/agent.md:332:- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)
agents/recruitment/sourcing-scout/README.md:1:# Sourcing Scout — directory README
agents/recruitment/sourcing-scout/README.md:3:**Status:** Proposed (Day-19 pre-W9-build scaffold).
agents/recruitment/sourcing-scout/README.md:14:Full bundle at W9 build (~2 weeks per ULTRAPLAN A5 line 554):
agents/recruitment/sourcing-scout/README.md:16:- `tools.yaml` — Bullhorn R + Proxycurl + Reed + CV-Library + source-abstraction layer
agents/recruitment/sourcing-scout/README.md:27:Per ULTRAPLAN A5 line 555 gotcha: source-abstraction layer designed for Night Sourcer reuse. Defer ADR-006 to W9 build start documenting the layer's interface.
agents/recruitment/sourcing-scout/README.md:31:Codex Round 4 Phase 2 (Day 20) via `review-architecture-decision.md`.
agents/recruitment/sourcing-scout/README.md:33:*End of Sourcing Scout README.*
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
packages/diagnostic-generator/README.md:36:1. **No LinkedIn deep data.** Page-existence check via HEAD only. Full data needs Proxycurl signup (~$39/mo).
packages/diagnostic-generator/README.md:50:| LinkedIn HEAD returns 999 (bot detection) | §2 treats as "page exists, deep data via Proxycurl"; not a failure |
agents/recruitment/sourcing-scout/agent.md:1:# Sourcing Scout — request-response passive sourcing
agents/recruitment/sourcing-scout/agent.md:3:**Status:** Proposed (Day-19 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice).
agents/recruitment/sourcing-scout/agent.md:6:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:7:**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
agents/recruitment/sourcing-scout/agent.md:8:**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.
agents/recruitment/sourcing-scout/agent.md:16:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate flagged "do not contact" in tenant vault (per ULTRAPLAN A5 line 553 verbatim). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 554 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:24:Brain UI v1.0 "Source candidates" button on any brief detail page → POST internal API → Sourcing Scout webhook.
agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
agents/recruitment/sourcing-scout/agent.md:57:# Sourcing Scout — <Brief title>
agents/recruitment/sourcing-scout/agent.md:59:**Sources searched:** Bullhorn ATS + LinkedIn (Proxycurl) + Reed + CV-Library
agents/recruitment/sourcing-scout/agent.md:86:| LinkedIn (Proxycurl) | <N> | <score> | <remaining> |
agents/recruitment/sourcing-scout/agent.md:104:11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/sourcing-scout/agent.md:119:   → bullhorn (read-only); LinkedIn/Proxycurl; Reed; CV-Library
agents/recruitment/sourcing-scout/agent.md:129:4. LinkedIn search (via Proxycurl)
agents/recruitment/sourcing-scout/agent.md:134:   → ESC_LINKEDIN_RATE_LIMIT on Proxycurl quota hit
agents/recruitment/sourcing-scout/agent.md:193:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 553 verbatim):
agents/recruitment/sourcing-scout/agent.md:207:Per ULTRAPLAN A5 line 554 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
agents/recruitment/sourcing-scout/agent.md:209:Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.
agents/recruitment/sourcing-scout/agent.md:213:Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha §6.4 of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
agents/recruitment/sourcing-scout/agent.md:219:Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/sourcing-scout/agent.md:224:| `ESC_LINKEDIN_AUTH` | Proxycurl API key invalid | warn (single-source fail OK if 2+ others succeed) | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:225:| `ESC_LINKEDIN_RATE_LIMIT` | Proxycurl quota exceeded | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:238:Sourcing Scout does NOT use:
agents/recruitment/sourcing-scout/agent.md:258:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/sourcing-scout/agent.md:262:## §8 — Build dependencies (W9 prerequisites)
agents/recruitment/sourcing-scout/agent.md:264:Sourcing Scout build cannot start until ALL of the following are confirmed:
agents/recruitment/sourcing-scout/agent.md:274:| **Proxycurl commercial signup** + API access | Founder commercial; ~$39+/mo | ⏸ |
agents/recruitment/sourcing-scout/agent.md:277:| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:278:| Reed MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:279:| CV-Library MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:280:| Source-abstraction layer (Night Sourcer reuse) | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:284:| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:285:| `context.sh` hydration | Build at W9 start (~0.5 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:286:| `cycle.sh` orchestration (11-step) | Build at W9 start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:287:| 3 fixtures with golden outputs | Build at W9 start (~1 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:289:**Until ALL ⏸ items resolve to ✅, W9 build slice does not start.**
agents/recruitment/sourcing-scout/agent.md:295:**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:301:| Q1 | All three external sources required for v1.0? Reed + CV-Library are UK-recruitment-specific; Proxycurl is LinkedIn-via-API. Could v1.0 ship with Bullhorn + Proxycurl only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
agents/recruitment/sourcing-scout/agent.md:302:| Q2 | Proxycurl pricing — ~$39/mo for 5,000 credits at low volume; scales with usage. Per pilot tenant budget? | ~5-10 briefs/day per consultant × 50 calls/brief = up to 2,500 credits/day per consultant. Cost: ~$20-50/day at peak. |
agents/recruitment/sourcing-scout/agent.md:304:| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 553 says "≥ 50 words" — using as floor. |
agents/recruitment/sourcing-scout/agent.md:306:| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
agents/recruitment/sourcing-scout/agent.md:309:### Gotchas (carried forward from ULTRAPLAN A5 line 555)
agents/recruitment/sourcing-scout/agent.md:311:1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
agents/recruitment/sourcing-scout/agent.md:312:2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
agents/recruitment/sourcing-scout/agent.md:319:Per `.codex/ratification/review-architecture-decision.md` skill: this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/sourcing-scout/agent.md:328:- W9 build slice produces all 5 sibling bundle files + 3 fixtures
agents/recruitment/sourcing-scout/agent.md:331:- Codex re-ratifies post-build via `review-agent-bundle.md` skill
agents/recruitment/sourcing-scout/agent.md:335:*End of Sourcing Scout agent.md draft.*
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:205:| `wiki/raw/briefs/` | one file per brief intake | markdown with frontmatter | `{epoch}-{brief-id}.md` | Brief Decoder (v1.1) on inbound | Sourcing Scout (v1.0 reads only candidate-relevant); Brief Decoder (v1.1) |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:211:| `wiki/compiled/briefs/{slug}.md` | one per Brief | same | same | Brief Decoder (v1.1); manual at v1.0 if needed | Sourcing Scout (v1.0 reads only); Brief Decoder (v1.1) |
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:237:| Brief | **v1.0 (skeleton) / v1.1 (full)** | Sourcing Scout (v1.0 A5) needs to *read* a Brief to source against; Brief Decoder (v1.1 A8) is the producer. v1.0 writes minimal Briefs (manual entry or direct Bullhorn sync via Janitor); full lifecycle waits for v1.1 |
docs/architecture/second-brain-design.md:319:v1.0 skeleton: only what Sourcing Scout (A5) needs to source against — role title, client, sector, must-haves. Full v1.1 schema waits for Brief Decoder.
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:429:| `list-by-type-and-tenant` | Sourcing Scout (v1.0): enumerate Candidates for filtering; Brief Decoder (v1.1): enumerate open Briefs | v1.0 (Candidate, Client, Placement, Contact); v1.1 (Brief full enumeration) | `(entity_type: str, tenant_id: str, filters?: dict, limit?: int)` | `List[EntityRef]` | few seconds | Postgres-indexed; filtering matches `search-by-attribute` |
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:774:| Sourcing Scout | 50:1 | reads briefs + candidate pool to filter; writes only shortlists |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
agents/recruitment/janitor/README.md:34:Per `.codex/ratification/review-architecture-decision.md` skill. Queued for Codex Round 4 Phase 2 (Day 20).
docs/operations/bullhorn-outreach-emails.md:17:**These don't block today.** They block **Janitor W5 build** (per kill-criterion §2 Trigger 3). You have ~5 weeks of runway. But send today/Monday because Bullhorn's response time is 2-5 business days, and we want the answers before Diagnostic W3-4 completes so Janitor W5 starts unblocked.
docs/operations/bullhorn-outreach-emails.md:74:- If they require marketplace membership before production access → Sub-decision A is **Marketplace**; need cost + timeline to assess against kill-criterion §2 Trigger 3 (Janitor W5 deadline).
docs/operations/codex-ratification-guide.md:117:review-architecture-decision.md
docs/operations/codex-ratification-guide.md:122:Three more skills (`review-agent-bundle.md`, `review-mcp-connector.md`, `review-harness-bump.md`) are deferred per the execution plan §3 — they're lazy, built at first need.
docs/operations/codex-ratification-guide.md:227:This loops through all 8 cluster-A artefacts, runs each through `review-architecture-decision`, and prints a summary.
docs/operations/codex-ratification-guide.md:448:Example: if you noticed Codex RATIFIED an ADR with a status-drift problem, add a check in `review-architecture-decision.md §1` for status-content consistency. Re-ratify the affected artefacts.
docs/operations/codex-round-2-handoff.md:21:2. **Skill softened (D5)** — `review-architecture-decision.md` §1 now exempts Reference + In Force from Decision/Consequences requirements. 2 artefacts that REJECTED on this in Round 1 (`cortexos-primitive-status.md` audit + `operational-hygiene-protocol.md` runbook) should RATIFY in Round 2.
docs/operations/codex-round-2-handoff.md:46:# Expected: SKILL.md + review-architecture-decision.md + review-schema-change.md + review-postgres-migration.md
docs/operations/codex-round-2-handoff.md:48:grep -A 2 "§1-Exemption" .codex/ratification/review-architecture-decision.md | head -5
docs/operations/codex-round-2-handoff.md:95:| 15 | `docs/architecture/tenancy-invariants.md` | `review-architecture-decision` | RATIFY (Reference status under D5 softening; well-cited) |
docs/operations/codex-round-2-handoff.md:96:| 16 | `docs/architecture/architecture-cohesion-review.md` | `review-architecture-decision` | RATIFY (Reference; surfaces gaps with named paths) |
docs/operations/codex-round-2-handoff.md:97:| 17 | `docs/runbooks/tenant-lifecycle.md` | `review-architecture-decision` | RATIFY (In Force runbook; D5 softening applies) |
docs/operations/codex-round-2-handoff.md:98:| 18 | `scripts/run-tenancy-audit.sh` | `review-architecture-decision` (script-as-artefact) | RATIFY (12 invariants enumerated; mirrors run-live-migration pattern) |
docs/operations/codex-round-2-handoff.md:104:| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | `review-architecture-decision` | **Recursive ratification per master brief §10.5.** Codex either RATIFIES the disagreement (D5 was correct) OR REJECTS (insists on strict skill). Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:105:| 20 | `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | `review-architecture-decision` | **Recursive ratification.** Codex evaluates Claude's counter-argument re: Week-1 gate. Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:106:| 21 | `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` | `review-architecture-decision` | RATIFY-with-advisory (briefing doc; D5 softening applies as Reference) |
docs/operations/codex-round-2-handoff.md:107:| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | `review-architecture-decision` | RATIFY (Proposed spec; alternatives weighed; ratifies cortextOS primitive-4 reuse) |
docs/operations/codex-round-2-handoff.md:108:| 23 | `docs/runbooks/pii-purge-operational-pattern.md` | `review-architecture-decision` (Proposed runbook) | RATIFY (Proposed pending D3; comprehensive operational coverage) |
docs/operations/codex-round-2-handoff.md:109:| 24 | `scripts/ifos-pii-purge.sh` | `review-architecture-decision` (script-as-artefact) | RATIFY (small, single-purpose, shellcheck clean) |
docs/operations/codex-round-2-handoff.md:172:  required); see .codex/ratification/review-architecture-decision.md §1-Exemption
docs/operations/codex-round-2-handoff.md:205:TIER 1 — RE-RATIFY 14 ROUND-1 REJECTED (skill: review-architecture-decision):
docs/operations/codex-round-2-handoff.md:221:TIER 2 — DAY-9 NEW ARTEFACTS (skill: review-architecture-decision):
docs/operations/codex-round-2-handoff.md:228:  docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md  (review-architecture-decision; recursive)
docs/operations/codex-round-2-handoff.md:229:  docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md  (review-architecture-decision; recursive)
docs/operations/codex-round-2-handoff.md:230:  docs/decisions/2026-05-20-codex-round-1-founder-decisions.md  (review-architecture-decision)
docs/operations/codex-round-2-handoff.md:231:  docs/decisions/autosend-approval-bridge-spec.md  (review-architecture-decision)
docs/operations/codex-round-2-handoff.md:232:  docs/runbooks/pii-purge-operational-pattern.md  (review-architecture-decision)
docs/operations/codex-round-2-handoff.md:233:  scripts/ifos-pii-purge.sh  (review-architecture-decision)
docs/operations/codex-round-2-remediation-prompt.md:205:      `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/operations/codex-round-2-remediation-prompt.md:388:  Apply review-architecture-decision:
docs/operations/codex-round-2-remediation-prompt.md:399:  Apply review-architecture-decision (script-as-artefact):
docs/operations/codex-ratification-execution-plan.md:69:| `review-architecture-decision.md` | ADRs in `docs/decisions/` | ~200 | First (covers ADR-001/002/003/004 + decision artefacts) |
docs/operations/codex-ratification-execution-plan.md:72:| `review-agent-bundle.md` | The 6-file + 3-fixture pattern | ~250 | Pre-Diagnostic-W3 (not yet needed) |
docs/operations/codex-ratification-execution-plan.md:119:### Cluster A — Architecture decisions (8 items, `review-architecture-decision.md`)
docs/operations/codex-ratification-execution-plan.md:132:### Cluster B — Reference designs + standards (6 items, `review-architecture-decision.md` adapted)
docs/operations/codex-ratification-execution-plan.md:158:### Cluster E — Runtime code + helpers (6 items — review against ADR shape, mostly via `review-architecture-decision.md` + skill-specific checklist)
docs/operations/codex-ratification-execution-plan.md:251:    --skill .codex/ratification/review-architecture-decision.md \
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
docs/operations/codex-ratification-execution-plan.md:429:- **Codex review of `agents/_shared/` runtime code via agent-bundle skill** — the 8-file `_shared/` set is reviewed under `review-architecture-decision.md` because it's not an agent bundle, it's the helper layer. Future agents (Diagnostic W3+) will be reviewed under `review-agent-bundle.md` once that skill exists.
docs/operations/codex-round-2-autonomous-prompt.md:55:  3. .codex/ratification/review-architecture-decision.md  (with D5 softening
agents/recruitment/janitor/agent.md:59:| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:79:12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/janitor/agent.md:123:7. LinkedIn enrichment (candidates; v1.1 via Proxycurl)
agents/recruitment/janitor/agent.md:124:   → at v1.0: skipped (LinkedIn deep data deferred to W4 polish; Proxycurl
agents/recruitment/janitor/agent.md:168:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:226:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/janitor/agent.md:252:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
agents/recruitment/janitor/agent.md:281:Per `.codex/ratification/review-architecture-decision.md` skill: this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/janitor/agent.md:292:- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:46:4. **Diagnostic bundle ratified by Codex.** Round 4 ratification run against agent.md + 5 siblings + 3 fixtures via `review-architecture-decision.md` skill. Verdict: RATIFIED (or remediation-pass if needed).
docs/operations/goal-week-3-polish-and-scaffold.md:50:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:53:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:105:| Proxycurl signup | Founder commercial action; gated on founder decision (cost ~$39/mo); if founder approves mid-week, wire LinkedIn deep data into Diagnostic |
docs/operations/goal-week-3-polish-and-scaffold.md:111:| Building any new Codex ratification skill (e.g., `review-agent-bundle.md`) | Defer per execution-plan §3 lazy; agent.md ratification uses existing `review-architecture-decision.md` skill |
docs/operations/goal-week-3-polish-and-scaffold.md:262:5. `packages/diagnostic-generator/` (the package as a whole; ratifies via `review-architecture-decision.md` skill)
docs/operations/goal-week-3-polish-and-scaffold.md:294:- `v1.0-kill-criterion.md` Trigger 3 (JANITOR-BULLHORN-AUTH-W5)
docs/operations/goal-week-3-polish-and-scaffold.md:312:- **§10 Ratification:** via `review-architecture-decision.md` Codex skill; ratifies as part of Round 4 if scaffolded by Day 20.
docs/operations/goal-week-3-polish-and-scaffold.md:381:### DAY 19 — Sourcing Scout + Concierge agent.md scaffolds (Steps 11-12)
docs/operations/goal-week-3-polish-and-scaffold.md:386:- ULTRAPLAN §8.1 A5 lines 547-558 (Sourcing Scout spec)
docs/operations/goal-week-3-polish-and-scaffold.md:387:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:388:- `bullhorn-integration-path.md` §4.1 (Sourcing Scout's Bullhorn read surface)
docs/operations/goal-week-3-polish-and-scaffold.md:389:- `vertical-schema.yaml` §3 agent_access_matrix Sourcing Scout row
docs/operations/goal-week-3-polish-and-scaffold.md:393:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:397:- **§4 Workflow:** ~10 steps. Brief fetch → keyword extraction → Bullhorn candidate search (filtered) → LinkedIn search (via Proxycurl or equiv) → semantic ranking → confidence scoring → match rationale generation → report assembly.
docs/operations/goal-week-3-polish-and-scaffold.md:402:- **§8 Build prerequisites:** Bullhorn MCP read + LinkedIn integration (Proxycurl signup OR LinkedIn API partner-tier) + ranking model (LLM-based or embedding-based).
docs/operations/goal-week-3-polish-and-scaffold.md:407:Commit: `decision(pre-build): agents/recruitment/sourcing-scout/agent.md — output contract per ULTRAPLAN §8.1 A5`
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Founder approves Proxycurl signup mid-week | Wire LinkedIn deep data into Diagnostic via a new `@ifos/linkedin-proxycurl` package (similar to companies-house pattern); commit as separate slice; out of scope for goal §1 but high-value |
docs/operations/goal-week-3-polish-and-scaffold.md:529:- Any external service requiring paid signup (Proxycurl, Fathom, Xero dev, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:577:- `review-architecture-decision.md` — for agent.md scaffolds (each is an architectural decision; status=Proposed)
docs/operations/goal-week-3-polish-and-scaffold.md:580:- `review-agent-bundle.md` — NOT YET BUILT (per execution-plan §3 lazy); defer; use review-architecture-decision.md for each agent.md individually
docs/operations/goal-week-3-polish-and-scaffold.md:619:  Sourcing Scout (W9):    <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:651:    - Diagnostic LinkedIn deep data (if Proxycurl signed up)
docs/operations/goal-week-3-polish-and-scaffold.md:660:  - <Proxycurl signup if approved>
docs/operations/goal-week-3-polish-and-scaffold.md:670:  - Approve Proxycurl signup ($39/mo)?
docs/operations/goal-week-3-polish-and-scaffold.md:683:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/operations/goal-option-c-diagnostic-end-to-end.md:77:| LinkedIn integration (Proxycurl, etc.) | Requires founder commercial action (Proxycurl signup ~£50/mo); LinkedIn paths remain stubbed; fixture 02 verifies graceful degradation already |
docs/operations/goal-option-c-diagnostic-end-to-end.md:90:- **Do NOT** sign up for any paid service (Proxycurl, etc.) — founder gates external spend
docs/operations/goal-option-c-diagnostic-end-to-end.md:255:- **Ratifies via:** review-architecture-decision.md Codex skill (next round).
docs/operations/goal-option-c-diagnostic-end-to-end.md:283:- Recommendations for Week-4 polish (weak sections, voice classifier wiring, LinkedIn integration if Proxycurl signed up)
docs/operations/goal-option-c-diagnostic-end-to-end.md:330:- Any external service requiring paid signup (Proxycurl, OpenAI tier, etc.)
docs/operations/goal-option-c-diagnostic-end-to-end.md:402:  - [LinkedIn integration via Proxycurl signup]
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:77:**Codex says:** "The file has `Status: Proposed` at line 3, but no `Context`, `Decision`, or `Consequences` sections as required for Proposed artefacts by review-architecture-decision §1. Fix: either review this with `review-agent-bundle.md`, or add the required architecture-decision sections and a final status-update line."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:81:**Recommendation:** **Build `review-agent-bundle.md` Codex skill** (deferred per execution-plan §3 lazy; now needed). The Round-4 manifest used `review-architecture-decision.md` as a temporary skill because `review-agent-bundle.md` doesn't exist yet. The correct ratification path for agent.md files is the agent-bundle skill, not architecture-decision.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:83:**This is the load-bearing finding** — it surfaces that **the lazy-skill deferral is now blocking proper agent.md ratification.** Building `review-agent-bundle.md` is a Week-3-extension or W4 priority.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:92:4. **Authorise Week-3-extension OR W4-priority work** to build `review-agent-bundle.md` Codex skill (Issue 5)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:102:- Phase 2 full (5 new scaffolds): **deferred** pending Issue-5 resolution (review-agent-bundle.md skill build)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:106:Recommended next step (post-arbitration): Week-3-extension or W4-prio-1 build of `review-agent-bundle.md` skill; then re-run Codex Round 4 against all 6 v1.0 agent.md files with the proper skill.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:110:**Real issue:** Codex Round 1 REJECTED `cortexos-primitive-status.md` (audit) and `operational-hygiene-protocol.md` (runbook) for lacking Decision + Consequences sections. The skill `.codex/ratification/review-architecture-decision.md` §1 requires these sections for all artefacts under this skill. But the skill ALSO allows Status=Reference and Status=In Force, which are legitimately non-decision artefacts. Contradiction in the skill itself.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:125:Founder accepted **D5-A**. Skill softening landed in `.codex/ratification/review-architecture-decision.md §1` plus new §1-Exemption clause. Reference + In Force status artefacts now exempt from Decision + Alternatives + Consequences requirements (Context + Status line still required for ALL).
docs/decisions/autosend-approval-bridge-spec.md:243:| A5 | Bridge crash + restart: state rebuilds from filesystem scan + Postgres state table | Restart test: kill PM2 process mid-flight, restart, verify pending approvals resume |
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
docs/decisions/autosend-approval-bridge-spec.md:303:Codex Day-7 manifest queue position: TBD (will be ~#39 when filed). Ratifies via `review-architecture-decision.md` skill (with D5 softening applies if Status flipped to Reference after build complete).
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:7:**Skill applied:** `.codex/ratification/review-architecture-decision.md` §1
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:31:The skill's enumeration of allowed Status values explicitly includes `Reference` and `In Force` alongside `Proposed | Accepted | Superseded | Deprecated`. By including those values, the skill implicitly accepts that artefacts ratified under `review-architecture-decision.md` may legitimately not be decisions. Enforcing ADR-shape (Context + Decision + Consequences) on audits + runbooks adds ceremony without value:
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:40:Edit `.codex/ratification/review-architecture-decision.md` §1 to read:
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:58:**Resolution detail (2026-05-22):** Founder accepted D5-A. Skill softening landed in `.codex/ratification/review-architecture-decision.md §1` — Reference + In Force status artefacts are now exempt from Decision + Alternatives + Consequences sections (Context + Status update line still required). The two REJECTED artefacts from Round 1 (`cortexos-primitive-status.md`, `operational-hygiene-protocol.md`) are expected to RATIFY in Round 2 without changes. Two new Day-9 artefacts (`architecture-cohesion-review.md` Reference, `tenant-lifecycle.md` In Force) are now ratifiable under the softened skill.
docs/decisions/2026-05-18-codex-ratification-manifest.md:42:Architecture+tenancy slice (commits `5c3fa66` + `c4348aa`) adds 4 new artefacts to the queue. These ratify against `review-architecture-decision.md` skill (with Founder Decision D5 softening for the lifecycle runbook):
docs/decisions/2026-05-18-codex-ratification-manifest.md:46:| 35 | tenancy-invariants.md | `docs/architecture/tenancy-invariants.md` | review-architecture-decision | Queued for Round 2 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:47:| 36 | architecture-cohesion-review.md | `docs/architecture/architecture-cohesion-review.md` | review-architecture-decision (Reference; D5 softening applies) | Queued for Round 2 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:48:| 37 | tenant-lifecycle.md | `docs/runbooks/tenant-lifecycle.md` | review-architecture-decision (In Force; D5 softening applies) | Queued for Round 2 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:49:| 38 | run-tenancy-audit.sh | `scripts/run-tenancy-audit.sh` | review-architecture-decision (Reference) | Queued for Round 2 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:115:**Phase 1 (Day 15) — Diagnostic-only mid-week ratification.** Reason: substrate must be verified before 5 new scaffolds reference it. 6 items, all `review-architecture-decision.md` skill except the package-as-a-whole.
docs/decisions/2026-05-18-codex-ratification-manifest.md:119:| 1 | `agents/recruitment/diagnostic/agent.md` | Proposed → Accepted (post-W3 polish) | `review-architecture-decision.md` | Was Round-3 RATIFIED at scaffold form; re-ratify after Day-13 + Step-3 fixes (firm-slug, suffix-strip) + Step-4 LLM §12 wiring |
docs/decisions/2026-05-18-codex-ratification-manifest.md:120:| 2 | `agents/recruitment/diagnostic/tools.yaml` | Proposed | `review-architecture-decision.md` | First ratification (Day-12 scaffold) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:121:| 3 | `agents/recruitment/diagnostic/cycle.sh` | Proposed | `review-architecture-decision.md` | Post-Day-13 generator wiring (commit `fd38254`) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:122:| 4 | `agents/recruitment/diagnostic/validate.sh` | Proposed | `review-architecture-decision.md` | Post-Day-13 V2 awk-pass fix (commit `97a57a2`) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:123:| 5 | `packages/diagnostic-generator/` (package as a whole) | Proposed | `review-architecture-decision.md` | Day-13 ship; first ratification |
docs/decisions/2026-05-18-codex-ratification-manifest.md:124:| 6 | `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` | Accepted | `review-architecture-decision.md` | Day-13 sequencing decision; first ratification |
docs/decisions/2026-05-18-codex-ratification-manifest.md:126:**Phase 2 (Day 20) — Full Round 4: 5 new agent.md scaffolds.** Each authored Days 16-19 per goal-week-3 Steps 8-12. All `review-architecture-decision.md` skill.
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:138:**Day-19 update:** Initial Round-4 Phase-1 attempt used `review-architecture-decision.md` skill (the only available skill at the time). That returned REJECTED with a load-bearing finding (Issue 5 in `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`) — agent.md files require a different skill structure. **`review-agent-bundle.md` skill built in commit `825ebd4`.** Re-ratification of all 11 items uses the new skill. The 10 ESC codes / sentinel / Trigger references in agent.md files re-evaluated under the agent-bundle skill criteria (§1-§6 of the skill doc); the pure decision-doc-shape Issue 5 reject is reconsidered per §6 of the skill doc.
docs/decisions/2026-05-18-codex-ratification-manifest.md:209:| `review-agent-bundle.md` | Specific checklist for the 6 files + 3 fixtures of a new agent |
docs/decisions/2026-05-18-codex-ratification-manifest.md:213:| `review-architecture-decision.md` | Specific checklist for ADRs in `docs/decisions/` |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:6:**Skill applied:** `.codex/ratification/review-architecture-decision.md`
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:68:build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
packages/agent-renderer/pnpm-lock.yaml:202:    resolution: {integrity: sha512-RVyzfb3FWsGA55n6WY0MEIEPURL1FcbhFE6BffZEMEekfCzCIMtB5yyDcFnVbTnwk+CLAgTujmV/Lgvih56W+A==}
packages/agent-renderer/pnpm-lock.yaml:208:    resolution: {integrity: sha512-bPb5AHZtbeNGjCKVZ9UGqGwo8EUu4cLq68E95A53KlxAPRmUyYv2D6F0uUI65XisGOL1hBP5mTronbgo+0bFcA==}
packages/agent-renderer/pnpm-lock.yaml:376:    resolution: {integrity: sha512-nU1yhmYutL+fQ71Kxnhg8uEOdC0pwEW9entHykTgEbna2pw2dkbFSMeqjjyHZoCmt8SBkOSvV+yNmm94aUrrqw==}
packages/agent-renderer/pnpm-lock.yaml:545:    resolution: {integrity: sha512-J3Yh9PzzF1Ovah2At+lHiGQdsYgArxBbXv/zHfSyaiFQEqvNv7DcW98pCrmdjCZBrqBiKrKKe2V+aaSGWuBe/w==}
packages/agent-renderer/pnpm-lock.yaml:569:    resolution: {integrity: sha512-nbJnQ8a3z1mtmrwImCYhc6BGpThAyYVRQxw9uKSKG4wR6aAYno9sVjJ0zaZcW9BPJX1GbrDPf+SvdWjgTuDmnw==}
packages/agent-renderer/pnpm-lock.yaml:599:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}
packages/agent-renderer/pnpm-lock.yaml:605:    resolution: {integrity: sha512-Boiz5+MsaROEWDf+GGEwF8VMHGhlUoQMtIPjOgA5fv4osupqTVnJteQNKJwUcnUog2G55jYXH7KZFFiJe0TEzQ==}
packages/agent-renderer/pnpm-lock.yaml:650:    resolution: {integrity: sha512-GhdPgy1el4/ImP05X05Uw4cw2/M93BCUmnEvWZNStlCzEKME4Fkk+YpoA5OiHNQmoS7Cafb8Xa3Pya8m1Qrzeg==}
packages/agent-renderer/pnpm-lock.yaml:871:    resolution: {integrity: sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==}
docs/decisions/autosend-safety-policy.md:6:**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:84:| Sourcing Scout | `linkedin_profile_cache` | Stores profile snapshot to `/vault/<tenant>/wiki/raw/`; no external send; no rate-limit cost |
docs/decisions/autosend-safety-policy.md:94:| Sourcing Scout | `linkedin_connection_request` | 1-in-5 | Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy |
docs/decisions/autosend-safety-policy.md:110:| Sourcing Scout | `linkedin_inmail_send` | Outbound InMail (paid credit); cost-per-send; customer-facing |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/v1.0-kill-criterion.md:73:### Trigger 3 — JANITOR-BULLHORN-AUTH-W5 (PIVOT)
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:136:**Action:** PIVOT — likely vector: cheaper Claude model tier (Haiku 4.5 for routine actions, Sonnet for complex), or reduced agent run frequency (e.g., Sourcing Scout runs nightly batch instead of real-time), or per-tenant cost passthrough in pricing.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
agents/recruitment/diagnostic/cycle.sh:113:# data deferred to W4 (Proxycurl). Voice classifier gate skipped at v0.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:7:**Ratifies via:** `review-architecture-decision.md` Codex skill (next round)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:23:| 9 | Sourcing Scout |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:75:- Sourcing Scout (W9) touches Bullhorn read; same gating
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:119:| LinkedIn deep data via Proxycurl: now or W4? | Day-13 founder pick: Option A (free unauthenticated path) for v0; Proxycurl evaluated W4 polish |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
agents/recruitment/diagnostic/README.md:38:Per `.codex/ratification/review-agent-bundle.md` (skill not yet built; lazy per execution-plan §3): this directory ratifies as a unit when the full 6-file + 3-fixture bundle exists.
agents/recruitment/diagnostic/README.md:40:Until then, individual files (this README + agent.md) ratify via `review-architecture-decision.md` skill on their own ratification queue position.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/decisions/sequencing-target.md:25:| A5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | "First daytime always-on agent" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:96:| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
docs/decisions/sequencing-target.md:113:| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:146:### 2.5 — A5 Sourcing Scout (daytime)
docs/decisions/sequencing-target.md:150:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 554 estimate **L (2 weeks)** — multi-source aggregation logic is the work. Four data sources (Bullhorn read + LinkedIn via Proxycurl + Reed.co.uk + CV-Library). Bounded output (5-15 candidates per query per Ultraplan §8.1 line 552). Tier 2 request-response |
docs/decisions/sequencing-target.md:151:| 2. Substrate exercise | **Medium** | Reuses Bullhorn R from Janitor (no new Bullhorn substrate). New MCP integrations: LinkedIn via Proxycurl (rate-limited per Ultraplan §10 row #6), Reed, CV-Library. Source-abstraction layer per Ultraplan §8.1 line 555 designed to be reusable by Night Sourcer v1.1 |
docs/decisions/sequencing-target.md:152:| 3. Risk de-risking | **Medium** | **First exercise of LinkedIn rate-limit budget** per Ultraplan §10 Risk #6 ("LinkedIn rate limits via Proxycurl are tighter than expected"). Reuses Bullhorn auth from Janitor (doesn't re-derisk Risk #2). Tier 2 so doesn't touch Risk #1 primitives |
docs/decisions/sequencing-target.md:154:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Night Sourcer (v1.1) reuses Sourcing Scout's multi-source layer per Ultraplan §8.1 line 555 ("Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it") | Medium criticality (v1.1 downstream) |
docs/decisions/sequencing-target.md:155:| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn (already on if Janitor shipped) + LinkedIn (Proxycurl API key — single application-level key, not per-tenant) + Reed OAuth + CV-Library OAuth per tenant |
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
docs/decisions/sequencing-target.md:314:**Trigger 3 — Hire #1 starts later than Week 7.** Per Ultraplan §9 line 766 verbatim caveat: "Hire #1 is assumed to start week 7 (verify, don't assume)":
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:319:- **Cascade:** Sourcing Scout W10 (shifted right from W9), Concierge W11-14 (shifted right from W10-13).
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:37:| A5 Sourcing Scout | **Yes — read** (ATS passive-match lookup) | Ultraplan §8.1 A5 line 547-551 |
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:309:| Sourcing Scout passive-match read | Polling (on-demand search) | Per-consultant-request | No subscription needed — read-on-demand model |
docs/decisions/bullhorn-integration-path.md:336:| Sourcing Scout (read-on-demand) | 50-200 during consultant-active windows | Search-heavy; multiple paginated reads per consultant request |
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
agents/recruitment/diagnostic/tools.yaml:5:# Ratifies as part of full bundle via review-agent-bundle.md skill.
agents/recruitment/diagnostic/tools.yaml:54:      Read-only LinkedIn API (provider TBD at W3 build start — Proxycurl
agents/recruitment/diagnostic/tools.yaml:61:      - LINKEDIN_API_KEY  # provider-specific; Proxycurl or alternative
agents/recruitment/diagnostic/tools.yaml:69:      per_window: 100  # Proxycurl default per second
agents/recruitment/diagnostic/tools.yaml:182:  - linkedin_readonly_mcp_connector  # ~2 days at W3 start (Proxycurl wrapper)
docs/runbooks/day-4-provisioning.md:70:- Master brief §8.1 Change 2: three values — `trigger`, `output`, `action`
docs/runbooks/day-4-provisioning.md:806:Per `sequencing-target.md` §5-A + master brief §8.1 Change 2 + `current-priorities.md` line 16. **Exactly 5 values. No additions.**
agents/recruitment/diagnostic/validate.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
agents/recruitment/diagnostic/context.sh:10:# the first workflow step runs. Per master brief §8.1 Change 1: load voice
docs/runbooks/tenant-lifecycle.md:363:  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
docs/runbooks/tenant-lifecycle.md:399:**In Force** for runbook procedures. **Codex Day-7 manifest queue item #37**; ratifies via `review-architecture-decision.md` skill (with Founder Decision D5 softening for runbook artefacts).
docs/runbooks/pii-purge-operational-pattern.md:234:Codex Day-7 manifest queue position: TBD (~#41 when filed). Ratifies via `review-architecture-decision.md` skill (In Force status; D5 softening applies).
agents/recruitment/diagnostic/agent.md:73:Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/diagnostic/agent.md:95:   → LinkedIn company-page fetch (Proxycurl or similar)
agents/recruitment/diagnostic/agent.md:156:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces:
agents/recruitment/diagnostic/agent.md:205:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/diagnostic/agent.md:222:| LinkedIn read-only MCP connector (or Proxycurl wrapper) | Build at W3 start (~2 days) | ⏸ Not built |
agents/recruitment/diagnostic/agent.md:227:| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⏸ Skill not built yet (lazy per execution plan §3) |
agents/recruitment/diagnostic/agent.md:245:| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | Resolved at W3 start before Companies House + LinkedIn MCP connectors authored. Founder + Claude decide together. |
agents/recruitment/diagnostic/agent.md:260:Per `.codex/ratification/review-agent-bundle.md` (skill not yet built; lazy per execution-plan §3): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.
packages/mcp-connectors/companies-house/pnpm-lock.yaml:186:    resolution: {integrity: sha512-RVyzfb3FWsGA55n6WY0MEIEPURL1FcbhFE6BffZEMEekfCzCIMtB5yyDcFnVbTnwk+CLAgTujmV/Lgvih56W+A==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:192:    resolution: {integrity: sha512-bPb5AHZtbeNGjCKVZ9UGqGwo8EUu4cLq68E95A53KlxAPRmUyYv2D6F0uUI65XisGOL1hBP5mTronbgo+0bFcA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:360:    resolution: {integrity: sha512-nU1yhmYutL+fQ71Kxnhg8uEOdC0pwEW9entHykTgEbna2pw2dkbFSMeqjjyHZoCmt8SBkOSvV+yNmm94aUrrqw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:529:    resolution: {integrity: sha512-J3Yh9PzzF1Ovah2At+lHiGQdsYgArxBbXv/zHfSyaiFQEqvNv7DcW98pCrmdjCZBrqBiKrKKe2V+aaSGWuBe/w==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:553:    resolution: {integrity: sha512-nbJnQ8a3z1mtmrwImCYhc6BGpThAyYVRQxw9uKSKG4wR6aAYno9sVjJ0zaZcW9BPJX1GbrDPf+SvdWjgTuDmnw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:583:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:589:    resolution: {integrity: sha512-Boiz5+MsaROEWDf+GGEwF8VMHGhlUoQMtIPjOgA5fv4osupqTVnJteQNKJwUcnUog2G55jYXH7KZFFiJe0TEzQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:634:    resolution: {integrity: sha512-GhdPgy1el4/ImP05X05Uw4cw2/M93BCUmnEvWZNStlCzEKME4Fkk+YpoA5OiHNQmoS7Cafb8Xa3Pya8m1Qrzeg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:821:    resolution: {integrity: sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==}
agents/recruitment/concierge/README.md:42:Codex Round 4 Phase 2 (Day 20) via `review-architecture-decision.md`.
docs/build-brief/00-MASTER-BRIEF.md:119:| 7 | Multi-agent orchestrator | `orchestrator` template + file-bus handoff contract | Brief Decoder → Sourcing Scout → Concierge pipeline lives here |
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:568:**Change 2 — Decision logging is enforced.** Three required calls per agent run:
docs/build-brief/00-MASTER-BRIEF.md:599:| 5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:698:        │  • Direct vendor API: Microsoft Graph delegated send, Proxycurl LinkedIn                   │
docs/build-brief/00-MASTER-BRIEF.md:723:| `review-agent-bundle.md` | Specific checklist for the 6 files + 3 fixtures of a new agent |
docs/build-brief/00-MASTER-BRIEF.md:727:| `review-architecture-decision.md` | Specific checklist for ADRs in `docs/decisions/` |
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
agents/recruitment/concierge/agent.md:6:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:110:15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/concierge/agent.md:229:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 verbatim:
agents/recruitment/concierge/agent.md:301:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/concierge/agent.md:369:Per `.codex/ratification/review-architecture-decision.md` skill: this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/concierge/agent.md:383:- Codex re-ratifies post-build via `review-agent-bundle.md` skill
docs/specs/ULTRAPLAN.md:72:- **The file bus.** Inter-agent handoff via shared filesystem directories. No queue, no API, no serialisation tax. Brief Decoder writes a parsed-brief file; Sourcing Scout's `FastChecker` polls it up at the configured cadence (default 1000ms `pollInterval`, configurable per agent); result lands in a sub-directory the Concierge is polling. Four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound.
docs/specs/ULTRAPLAN.md:146:**Change 1 — Voice handling moves into a shared module.**
docs/specs/ULTRAPLAN.md:166:**Change 2 — Decision logging is enforced, not optional.**
docs/specs/ULTRAPLAN.md:495:- **External APIs:** Companies House API (free), LinkedIn (via Proxycurl or similar), basic HTTP fetch
docs/specs/ULTRAPLAN.md:543:#### A5. Sourcing Scout (daytime form) — request-response sourcing
docs/specs/ULTRAPLAN.md:549:- **MCP tools required:** Bullhorn (read for ATS passive matches), LinkedIn (via Proxycurl or similar), Reed.co.uk API, CV-Library API
docs/specs/ULTRAPLAN.md:551:- **External APIs:** Proxycurl, Reed, CV-Library
docs/specs/ULTRAPLAN.md:555:- **Gotchas:** LinkedIn rate limits via Proxycurl. Reed/CV-Library have separate auth and separate result schemas. Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it.
docs/specs/ULTRAPLAN.md:593:- **MCP tools required:** Bullhorn (read for prior placements + candidates), shared with Sourcing Scout
docs/specs/ULTRAPLAN.md:594:- **Shared modules required:** Voice loader, decision log writer, the Brief Decoder→Sourcing Scout→Concierge orchestration template
docs/specs/ULTRAPLAN.md:595:- **External APIs:** Same as Sourcing Scout (reuses)
docs/specs/ULTRAPLAN.md:599:- **Gotchas:** Brief format varies hugely between clients. Build the parser as schema-driven, not pattern-matching. The orchestration handoff to Sourcing Scout is the load-bearing CortexOS test.
docs/specs/ULTRAPLAN.md:626:- **Shared modules required:** Voice loader, decision log writer, the source-abstraction layer from Sourcing Scout
docs/specs/ULTRAPLAN.md:627:- **External APIs:** Same as Sourcing Scout + GitHub
docs/specs/ULTRAPLAN.md:629:- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared with Sourcing Scout)
docs/specs/ULTRAPLAN.md:630:- **Build complexity:** **M** (2 weeks) — reuses Sourcing Scout's source layer; the new work is the overnight scheduling + rate-limit budget allocation
docs/specs/ULTRAPLAN.md:689:| Sourcing Scout | ✓ | ✓ | | | ✓ | | ✓ | | | ✓ | |
docs/specs/ULTRAPLAN.md:712:6. **LinkedIn (via Proxycurl)** — 6 of 18. Third-priority.
docs/specs/ULTRAPLAN.md:771:### Weeks 9–10 — Sourcing Scout + Concierge start
docs/specs/ULTRAPLAN.md:773:- Week 9: Sourcing Scout (daytime); LinkedIn + Reed + CV-Library integration
docs/specs/ULTRAPLAN.md:820:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
docs/specs/ULTRAPLAN.md:822:| 6 | LinkedIn rate limits via Proxycurl are tighter than expected | Medium | Medium | Sourcing Scout cost >£100/run | Negotiate Proxycurl enterprise plan; defer Night Sourcer to v1.2 if needed |
docs/specs/_archive-build-handoff.md:381:| 5 | **Sourcing Scout** | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
docs/specs/PRODUCT-SPEC.md:101:#### R5. Sourcing Scout (daytime form) — request-response sourcing during the day
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:400:| 3 | Inter-agent file bus — agents hand work to each other via shared directories | Brief Decoder → Sourcing Scout → Concierge handoff; Triage → specialist-agent routing |
docs/specs/PRODUCT-SPEC.md:476:- Sourcing Scout (daytime form)
docs/specs/PRODUCT-SPEC.md:486:3. **Night Sourcer** (2 weeks) — overnight extension of Sourcing Scout
docs/specs/PRODUCT-SPEC.md:526:5. **Sourcing Scout (daytime)** — "Shortlist in 15 minutes instead of by end of week."
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
packages/harness/cortextos/tests/e2e/mock-codex.js:41:const WS_GUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
packages/utilities/web-scraper/pnpm-lock.yaml:190:    resolution: {integrity: sha512-RVyzfb3FWsGA55n6WY0MEIEPURL1FcbhFE6BffZEMEekfCzCIMtB5yyDcFnVbTnwk+CLAgTujmV/Lgvih56W+A==}
packages/utilities/web-scraper/pnpm-lock.yaml:196:    resolution: {integrity: sha512-bPb5AHZtbeNGjCKVZ9UGqGwo8EUu4cLq68E95A53KlxAPRmUyYv2D6F0uUI65XisGOL1hBP5mTronbgo+0bFcA==}
packages/utilities/web-scraper/pnpm-lock.yaml:364:    resolution: {integrity: sha512-nU1yhmYutL+fQ71Kxnhg8uEOdC0pwEW9entHykTgEbna2pw2dkbFSMeqjjyHZoCmt8SBkOSvV+yNmm94aUrrqw==}
packages/utilities/web-scraper/pnpm-lock.yaml:533:    resolution: {integrity: sha512-J3Yh9PzzF1Ovah2At+lHiGQdsYgArxBbXv/zHfSyaiFQEqvNv7DcW98pCrmdjCZBrqBiKrKKe2V+aaSGWuBe/w==}
packages/utilities/web-scraper/pnpm-lock.yaml:557:    resolution: {integrity: sha512-nbJnQ8a3z1mtmrwImCYhc6BGpThAyYVRQxw9uKSKG4wR6aAYno9sVjJ0zaZcW9BPJX1GbrDPf+SvdWjgTuDmnw==}
packages/utilities/web-scraper/pnpm-lock.yaml:587:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:593:    resolution: {integrity: sha512-Boiz5+MsaROEWDf+GGEwF8VMHGhlUoQMtIPjOgA5fv4osupqTVnJteQNKJwUcnUog2G55jYXH7KZFFiJe0TEzQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:638:    resolution: {integrity: sha512-GhdPgy1el4/ImP05X05Uw4cw2/M93BCUmnEvWZNStlCzEKME4Fkk+YpoA5OiHNQmoS7Cafb8Xa3Pya8m1Qrzeg==}
packages/utilities/web-scraper/pnpm-lock.yaml:825:    resolution: {integrity: sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==}

exec
/bin/zsh -lc 'rg -n "hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|hh_decision_|sourcing_scout|voice" agents/_shared packages docs -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/harness/cortextos/src/telegram/logging.ts:107:  const hasMedia = !!(msg.photo || msg.document || msg.voice || msg.audio || msg.video || msg.video_note);
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:19:DROP TRIGGER IF EXISTS validate_voice_scores ON entities;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:20:DROP FUNCTION IF EXISTS validate_voice_score_fields();
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:28:DROP TABLE IF EXISTS voice_corpus_chunks  CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:29:DROP TABLE IF EXISTS voice_corpus         CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:32:-- §3 — Optional: purge voice_classifier_score / voice_drift_at_close keys
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:39:-- SET data = data - 'voice_classifier_score' - 'voice_drift_at_close'
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:41:--   AND (data ? 'voice_classifier_score' OR data ? 'voice_drift_at_close');
agents/_shared/autosend-policy.yaml:5:# hh_decision_action() invocation. Per-tenant overrides live in Postgres
agents/_shared/autosend-policy.yaml:53:  xero_query_invoices:
agents/_shared/autosend-policy.yaml:101:    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:36:| 13 | **GUC name drift between executed Day-4 reality and Days-8-11 codebase** — Day-4 §6.3 provisioned live RLS policies using `current_setting('app.current_tenant', TRUE)` (verified Day-11 via `\dp entities`), but Days 8-11 code (hook-helpers.sh, voice-loader.sh, run-live-migration.sh, run-tenancy-audit.sh, ifos-pii-purge.sh, v0.1-to-v0.2.sql) + Day-9 ratified docs (tenancy-invariants.md, architecture-cohesion-review.md) wrote `ifos.tenant_slug` instead. Three rounds of Codex ratification + cohesion review didn't catch it because no artefact in Days 8-11 was ever executed end-to-end against live Postgres. Surfaced 2026-05-22 during first live migration attempt (CREATE TRIGGER failed for separate privilege reason; founder ran `\dp entities` while diagnosing; the GUC mismatch was visible in policy output). | ~~High~~ → Low post-remediation | High (every Days-8-11 write to live Postgres would have silently failed RLS or returned 0 rows — silent data leak risk if ever inverted) | Any helper / migration / script execution against live Postgres that uses an RLS-protected table and returns surprising row counts; first end-to-end live execution of any of the 6 affected scripts; future `\dp` audit revealing additional drift. | Day-11 remediation (this commit): mechanical rename `ifos.tenant_slug` → `app.current_tenant` across 15 files; 29/29 helper tests still pass; v0.1-to-v0.2 migration verified to use the corrected GUC. Future: run `bash scripts/run-tenancy-audit.sh` post-migration to verify all 12 invariants against the live database. | **Mitigated in this commit pending live re-run of v0.2 migration + tenancy audit verification.** |
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/specs/ULTRAPLAN.md:34:**Rule 3 — Reuse before build.** Every agent uses the shared `_shared/` modules (voice loader, decision log writer, validate primitives, escalation router). No agent writes its own logging, its own voice handling, its own approval gate. If a shared module is missing, build the module first, then the agent.
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:73:- **The persistent PTY.** Agent process is *already running* with firm voice profile, ATS state, current pipeline, recent context pre-loaded. Sub-second to first useful action. Lambda cold starts are 3–8 seconds before the first token; Triage at that latency stops being magical.
docs/specs/ULTRAPLAN.md:137:        └── 99-voice-drift-canary/
docs/specs/ULTRAPLAN.md:142:The 99-voice-drift-canary fixture is new in v2. Every agent has one — a fixture designed to expose voice drift over time. Run weekly in CI; output diffed against historical baselines.
docs/specs/ULTRAPLAN.md:146:**Change 1 — Voice handling moves into a shared module.**
docs/specs/ULTRAPLAN.md:148:Phase 2 has each `context.sh` `cat` the voice profile inline. That works for nine agents; it's brittle at eighteen. v2 introduces `_shared/voice-loader.sh`:
docs/specs/ULTRAPLAN.md:152:source /tenant/.claude/bin/_shared/voice-loader.sh
docs/specs/ULTRAPLAN.md:155:hh_load_tone_rules
docs/specs/ULTRAPLAN.md:157:# Retrieve top-N similar samples from voice corpus
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:164:Every agent's `context.sh` becomes 30 lines instead of 200. The voice loader is the canonical surface; agents never read the voice corpus directly.
docs/specs/ULTRAPLAN.md:171:hh_decision_trigger     # Called at start of agent run; logs the trigger
docs/specs/ULTRAPLAN.md:172:hh_decision_output      # Called when agent produces output; logs the artefact
docs/specs/ULTRAPLAN.md:173:hh_decision_action      # Called when human acts on output; logs the action
docs/specs/ULTRAPLAN.md:182:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
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
docs/specs/ULTRAPLAN.md:494:- **Shared modules required:** Voice loader (uses Maddox's voice for the audit narrative), decision log writer
docs/specs/ULTRAPLAN.md:522:- **Shared modules required:** Voice loader (for tone-detection of tacit notes), decision log writer
docs/specs/ULTRAPLAN.md:533:- **Trigger type:** Webhook (payment received, invoice issued, invoice viewed) + cron sweep at 07:00 daily
docs/specs/ULTRAPLAN.md:536:- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
docs/specs/ULTRAPLAN.md:538:- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
docs/specs/ULTRAPLAN.md:541:- **Gotchas:** Open Banking auth is a 90-day token; rotation logic is non-trivial. Bank feed reconciliation against invoice register is the hard logic; start with exact-amount matches and expand to fuzzy.
docs/specs/ULTRAPLAN.md:550:- **Shared modules required:** Voice loader (for the rationale narrative), decision log writer
docs/specs/ULTRAPLAN.md:564:- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
docs/specs/ULTRAPLAN.md:566:- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
docs/specs/ULTRAPLAN.md:569:- **Gotchas:** Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks. Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship.
docs/specs/ULTRAPLAN.md:580:- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate, escalation router
docs/specs/ULTRAPLAN.md:594:- **Shared modules required:** Voice loader, decision log writer, the Brief Decoder→Sourcing Scout→Concierge orchestration template
docs/specs/ULTRAPLAN.md:612:- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
docs/specs/ULTRAPLAN.md:626:- **Shared modules required:** Voice loader, decision log writer, the source-abstraction layer from Sourcing Scout
docs/specs/ULTRAPLAN.md:640:- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate, escalation router
docs/specs/ULTRAPLAN.md:654:- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
docs/specs/ULTRAPLAN.md:671:| T2 Sunday-Evening Timesheet Ranger | M (1 week) | Bullhorn/Voyager + Microsoft Graph | The voice quality on per-contractor history is the work |
docs/specs/ULTRAPLAN.md:683:| Agent | Voice | Bullhorn | MSGraph | Xero/Sage | LinkedIn | CoHouse | Reed/CVLib | Fathom | AgentMail | Telegram | Special |
docs/specs/ULTRAPLAN.md:708:2. **Voice loader / vault helpers** — 16 of 18. Build in week 1.
docs/specs/ULTRAPLAN.md:745:- Week 1: Agent Bundle v2 pattern refactor; `_shared/` module build; voice loader; escalation codes catalogue; vertical schema v0.1
docs/specs/ULTRAPLAN.md:806:- Voice classifier and Gate A enforcement (Rule 4)
docs/specs/ULTRAPLAN.md:823:| 7 | Voice classifier underperforms (false positives blocking valid drafts) | Medium | Medium | First pilot reports >5% block rate on legitimate drafts | Soften the threshold from 0.75 → 0.65 for v1.0; tune up as corpus grows |
agents/_shared/escalation-codes.md:120:#### `ESC_VOICE_DRIFT`
agents/_shared/escalation-codes.md:122:- **Trigger:** Voice classifier score below `common-voice.json.voice_classifier_threshold` (default 0.75) after 3 retries per Ultraplan §5.3 retry budget
agents/_shared/escalation-codes.md:170:#### `ESC_VOICE_DRIFT_TENANT`
agents/_shared/escalation-codes.md:172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
agents/_shared/escalation-codes.md:174:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (CSM may need to retrain voice corpus)
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:218:          Optional pointer to the entity the draft was about (e.g. "candidate", "client"). Enables linking voice drift to entity classes (some entity types correlate with more drift).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:255:        source: IFOS-derived (Gate-A fires recorded by validate.sh + hh_decision_action)
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
docs/verticals/recruitment/vertical-schema.yaml:42:# `source: IFOS-derived` means computed/written by IFOS code (e.g., voice_classifier_score).
docs/verticals/recruitment/vertical-schema.yaml:140:        enum: [linkedin, referral, bullhorn_existing, direct_application, sourcing_scout, other]
docs/verticals/recruitment/vertical-schema.yaml:142:      voice_classifier_score:
docs/verticals/recruitment/vertical-schema.yaml:145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
docs/verticals/recruitment/vertical-schema.yaml:147:          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
docs/verticals/recruitment/vertical-schema.yaml:615:    v1_0_exercise: Concierge reads for addressee-resolution per bullhorn §4.1 A6 Voice gate; addressee = primary decision-maker contact.
docs/verticals/recruitment/vertical-schema.yaml:708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
docs/verticals/recruitment/vertical-schema.yaml:712:  Sourcing_Scout:
packages/harness/cortextos/src/telegram/media.ts:3: * Downloads and processes photo, document, audio, voice, video, and video_note messages.
packages/harness/cortextos/src/telegram/media.ts:9:import { transcribeVoice } from './transcribe.js';
packages/harness/cortextos/src/telegram/media.ts:14:  type: 'photo' | 'document' | 'audio' | 'voice' | 'video' | 'video_note';
packages/harness/cortextos/src/telegram/media.ts:143:  // Voice
packages/harness/cortextos/src/telegram/media.ts:144:  if (msg.voice) {
packages/harness/cortextos/src/telegram/media.ts:145:    const fileName = `voice_${date}.ogg`;
packages/harness/cortextos/src/telegram/media.ts:146:    const fileResponse = await api.getFile(msg.voice.file_id);
packages/harness/cortextos/src/telegram/media.ts:154:    const transcript = await transcribeVoice(localFile);
packages/harness/cortextos/src/telegram/media.ts:157:      type: 'voice',
packages/harness/cortextos/src/telegram/media.ts:163:      duration: msg.voice.duration,
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:136:- `feedback_voice.md` (type: feedback) — lift from v1's voice rules
docs/_archive-build-pack/06-BUILD-PLAN.md:222:- Adapt steps for v2: tool connections, voice profile capture, agent selection (which of the 11 to enable), Telegram bot creation, first ingest
agents/_shared/hook-helpers.sh:3:# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
agents/_shared/hook-helpers.sh:163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
agents/_shared/hook-helpers.sh:166:# hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/hook-helpers.sh:168:hh_decision_trigger() {
agents/_shared/hook-helpers.sh:177:# hh_decision_output <output_type> <artefact_ref> [<reason>]
agents/_shared/hook-helpers.sh:180:hh_decision_output() {
agents/_shared/hook-helpers.sh:190:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:193:hh_decision_action() {
docs/specs/_archive-build-handoff.md:193:3. Reuse before build — agents use _shared/ modules. No agent writes its own logging, voice handling, or approval gate.
docs/specs/_archive-build-handoff.md:205:- tests/fixtures/01-primary/, 02-edge-case-*/, 99-voice-drift-canary/
docs/specs/_archive-build-handoff.md:331:mkdir -p agents/janitor/tests/fixtures/{01-primary,02-edge-case-merged-duplicates,99-voice-drift-canary}
docs/specs/_archive-build-handoff.md:341:# Then the fixtures (01-primary, 02-edge-case, 99-voice-drift-canary) with golden outputs.
docs/specs/_archive-build-handoff.md:351:- Implementing `_shared/hook-helpers.sh` extensions (voice loader, decision-log writer)
docs/specs/_archive-build-handoff.md:419:3. **Reuse before build** — every agent uses shared `_shared/` modules. No agent writes its own logging, its own voice handling, its own approval gate.
docs/specs/_archive-build-handoff.md:431:- **Decision logging is required** (Ultraplan §4.2 change 2). Every agent run writes three log entries via `hh_decision_trigger`, `hh_decision_output`, `hh_decision_action`. Missing calls = hard fail in validate.sh. This is what enables the per-tenant LoRA pipeline at v2.0.
docs/specs/_archive-build-handoff.md:432:- **The 99-voice-drift-canary fixture** is new in v2. Every agent has one. Run weekly in CI; output diffed against historical baselines. This is your structural early-warning for voice rot as the corpus grows.
docs/specs/_archive-build-handoff.md:478:- Ship an agent without a 99-voice-drift-canary fixture because "we'll add it later"
docs/_archive-build-pack/02-PRODUCT-VISION.md:100:> Most AI tools also can't be trusted. Intel Force OS escalates when it's uncertain — when policy is unclear, data is weak, or output might embarrass you. Sensitive HR matters never get AI-drafted. The four-objection rule applies to every output: nothing sends without you. UK-hosted, GDPR-ready, built on Claude. Your operations, in your voice, at your standard.
docs/_archive-build-pack/02-PRODUCT-VISION.md:116:- **Brand voice** — direct, specific, honest about limits, quiet confidence, British English
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:785:            &middot; brand voice would otherwise read as harassment
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:905:            &middot; auto-flagged before invoice generation
docs/_archive-build-pack/04-DATA-MODEL.md:310:├── voice/
docs/_archive-build-pack/04-DATA-MODEL.md:311:│   └── voice-profile.md
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
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:174:-- Voice corpus + tone_rule are mutable (re-index + rule revisions).
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
agents/_shared/voice-loader.sh:3:# IFOS voice-loader — implements the 3 hh_load_* helpers per master brief
agents/_shared/voice-loader.sh:5:# voice corpus, tone rules, and recent edits into the agent's context bundle.
agents/_shared/voice-loader.sh:10:#   - Falls back to /vault/<tenant>/_voice/ markdown files if DB unavailable
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:28:# (helpers may not be loaded yet if voice-loader is called standalone).
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
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
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
packages/harness/cortextos/src/telegram/transcribe.ts:2: * Voice transcription via local whisper.cpp (whisper-cli).
packages/harness/cortextos/src/telegram/transcribe.ts:36: * Transcribe a Telegram voice .ogg file. Returns the trimmed transcript
packages/harness/cortextos/src/telegram/transcribe.ts:39:export async function transcribeVoice(
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:16:| `tests/test-voice-loader.sh` | Offline test harness — 9 tests against fallback mode | 5 |
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
agents/_shared/README.md:51:hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/README.md:52:hh_decision_output  <output_type> <artefact_ref> [<reason>]
agents/_shared/README.md:53:hh_decision_action  <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/README.md:56:`hh_decision_action` is the **gated** call. Returns `0` if action allowed, `1` if blocked or approval rejected. All three write a `decision_log` row before returning.
agents/_shared/README.md:72:`hh_decision_action` dispatches per tier:
agents/_shared/README.md:98:### `voice-loader.sh` helpers (3, master brief §8.1 Change 1)
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:120:   bash -c 'source agents/_shared/hook-helpers.sh; hh_decision_trigger "manual_smoke_test"'
agents/_shared/README.md:134:Schema v0.2 voice corpus migration. Procedure:
agents/_shared/README.md:144:   - 4 new tables (`voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`)
agents/_shared/README.md:145:   - `voice_samples_embedded` HNSW index on `voice_corpus_chunks.embedding`
agents/_shared/README.md:146:   - `validate_voice_scores` trigger on `entities`
agents/_shared/README.md:147:   - 1 seed row in `voice_corpus` for `migration-test` with `version='v0.2-seed'`, `is_active=TRUE`
agents/_shared/README.md:148:4. Smoke `voice-loader.sh` against live DB:
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
agents/_shared/README.md:170:- `agents/_shared/voice-loader.sh` (Reference — voice corpus + tone rules + recent edits)
agents/_shared/README.md:171:- `agents/_shared/tests/test-voice-loader.sh` (Reference — test harness, 9 tests)
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:3:**Product knowledge v2 inherits without rethinking. ICP, pricing, brand voice, invariants, agent catalogue, integrations, compliance posture. So strategic work doesn't get re-relitigated during the build. Treat this file as canon — if v2 needs to deviate, that's a separate decision recorded in `08-OPEN-DECISIONS.md`.**
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:29:1. It uses YOUR data (handbook, past replies, voice profile — not a generic template)
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:129:### Voice pillars
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:228:ONBOARD (24-72h)  → wizard: tools connect, voice profile, integrations
docs/specs/PRODUCT-SPEC.md:66:- **Output contract:** Every email, LinkedIn InMail, and website contact-form submission gets a personalised reply within 60 seconds, in firm voice, at any hour. Draft for sensitive categories, auto-send for pre-approved categories. A single Telegram message at 09:00 surfaces overnight inbounds the consultant should look at first.
docs/specs/PRODUCT-SPEC.md:71:- **Per-tenant config:** mailbox OAuth list, auto-send approval categories, escalation thresholds, voice profile path, firm-specific suppressions (named recruiters whose emails always escalate).
docs/specs/PRODUCT-SPEC.md:75:- **Output contract:** Every invoice has a live status — sent, opened, escalating, paid. Payment lands → consultant gets the commission notification within minutes. Aged debt sweep runs at 07:00 with three drafted chase emails per debtor (soft, firm, escalation) ready for one-click approval.
docs/specs/PRODUCT-SPEC.md:84:- **Output contract (digest mode):** Monday 06:00 — 5–8 named BD opportunities with hiring signal, decision-maker identified, relationship history checked, salary benchmark, and drafted outreach in firm voice. Every Friday — a one-pager review of the week's BD outcomes.
docs/specs/PRODUCT-SPEC.md:112:- **Output contract:** Every call (Fathom, Fireflies, Ringover) gets parsed into ATS structured fields *and* tacit notes that don't fit any field: "client said they'd never hire from Bank X because of a 2019 grudge", "candidate's actual reason for leaving is the new line manager, not the salary". Tacit notes power every other agent's voice and judgement.
docs/specs/PRODUCT-SPEC.md:121:- **Output contract:** Every active candidate and every placed client gets the right comms at the right time, in firm voice, drafted (Solo/Boutique) or auto-sent (Growth+): post-interview chase, post-rejection care, post-placement check-ins at week 1 / month 1 / month 3 / month 6 / month 12 / month 24. Plus referral-extraction prompts every 6 months for the first 24 months post-placement.
docs/specs/PRODUCT-SPEC.md:126:- **Per-tenant config:** nurture cadence per stage, voice tone per stage, referral-prompt templates, lifecycle-stage to comms-template mapping, do-not-contact flags.
docs/specs/PRODUCT-SPEC.md:194:- **Output contract:** Friday 17:00 cutoff. Sunday 19:00–21:00 — Ranger sends soft, personalised nudges to outstanding contractors in firm voice. Monday 09:00 — harder sweep on the residual with client-approver Cc. Per-contractor history informs the tone (holiday vs serial offender vs slow-approver client).
docs/specs/PRODUCT-SPEC.md:226:- **Output contract:** Every day: hours-to-agency vs hours-to-umbrella vs hours-to-client, charge-rate vs pay-rate vs invoice-amount, employer-NIC vs margin. Flags discrepancies to FD with one-click correction draft.
docs/specs/PRODUCT-SPEC.md:245:| **Scale** (26–50 fee earners) | £6,950 | All Growth + per-firm LoRA adapter + Sovereign-tier inference (UK on-prem) + priority support | "Half a junior recruiter replaced per consultant in operational drag. Per-firm voice that's genuinely indistinguishable from your top performer. £820k–£1.4M of demonstrable annual value created." |
docs/specs/PRODUCT-SPEC.md:268:                  │  canonical entities, voice, escalations  │
docs/specs/PRODUCT-SPEC.md:274:       │  voice profile, playbooks, candidate/client/brief data   │
docs/specs/PRODUCT-SPEC.md:297:The story for the customer: **"Every agent makes every other agent smarter. The Scribe captures your senior consultant's judgement → the Concierge writes in that judgement's voice → the Client Hunter pitches BD using that judgement's framing → the Pulse watches relationships through that judgement's lens. After 6 months, the system writes in your firm's voice better than your second-best consultant does."**
docs/specs/PRODUCT-SPEC.md:299:This is the answer to "why not just use ChatGPT" — ChatGPT doesn't know your placements, your voice, your decisions, or your firm's specific judgement patterns. The Vault + Decision Log + per-firm LoRA stack does.
docs/specs/PRODUCT-SPEC.md:312:2. **The per-tenant `/vault/{tenant}/` directory** — voice profile, playbooks, ICP definition, target patch, brand templates, banned phrases, customer-specific suppression lists.
docs/specs/PRODUCT-SPEC.md:333:**Day 3 — Voice profile capture**
docs/specs/PRODUCT-SPEC.md:334:- AI-guided wizard: customer pastes 10–20 sample emails from their top performer; system extracts voice profile, tone rules, banned phrases.
docs/specs/PRODUCT-SPEC.md:336:- `/vault/{tenant}/_voice/style-guide.md` saved.
docs/specs/PRODUCT-SPEC.md:345:- Cash Conductor runs against historical invoices — produces the DSO baseline.
docs/specs/PRODUCT-SPEC.md:347:- End-of-day call: 30 minutes, walk through outputs, confirm voice quality.
docs/specs/PRODUCT-SPEC.md:358:- `common-voice.json` — paths to voice profile, banned phrases, tone rules
docs/specs/PRODUCT-SPEC.md:381:2. **"Add it to your vault as a markdown file — the agents will read it on next run."** This is the answer for tone, voice, playbook, suppression-list, and similar text-based asks. ~25% of the time.
docs/specs/PRODUCT-SPEC.md:398:| 1 | Persistent PTY via PM2 — agent process pre-loaded with firm voice, ATS state, recent context | Triage, Concierge, Pulse, Watchtower, Cash Conductor |
docs/specs/PRODUCT-SPEC.md:528:7. **Concierge** — "No candidate ghosted, no client check-in missed, every comms in your voice."
docs/operations/codex-round-2-handoff.md:84:| 13 | `docs/verticals/recruitment/vertical-schema.yaml` | voice_classifier_score CHECK + empty access + versioning count | RATIFY (all three fixed) |
docs/_archive-build-pack/03-ARCHITECTURE.md:325:├── voice/
docs/_archive-build-pack/03-ARCHITECTURE.md:326:│   └── voice-profile.md
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
docs/_archive-build-pack/05-MIGRATION-MAP.md:122:| Brand voice rules | KEEP | `WEBSITE-CONTEXT.md` §brand-identity-spec | `packages/agents/voice.md` — used by every agent that drafts customer-facing content |
docs/architecture/tenancy-invariants.md:24:- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/tenancy-invariants.md:77:- **Enforcement:** `agents/_shared/hook-helpers.sh::_hh_emit_row` sets it via `SET LOCAL app.current_tenant = '${tenant}';` before INSERT. `agents/_shared/voice-loader.sh::_vl_psql_query` sets it via wrapped SQL. `packages/agent-renderer/src/renderer.ts` doesn't write to tenant-data tables directly (it writes to vault).
docs/architecture/tenancy-invariants.md:78:- **Documentation source:** `agents/_shared/hook-helpers.sh` lines ~75-95 (`_hh_emit_row` live-mode SQL) + `agents/_shared/voice-loader.sh` lines ~60-70 (`_vl_psql_query`).
docs/architecture/tenancy-invariants.md:81:  grep -n "SET LOCAL app.current_tenant\|SET app.current_tenant" agents/_shared/hook-helpers.sh agents/_shared/voice-loader.sh packages/agent-renderer/src/*.ts
docs/architecture/tenancy-invariants.md:153:### T10 — Voice corpus `is_active=TRUE` enforced unique per tenant
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
docs/architecture/tenancy-invariants.md:156:- **Enforcement:** Partial unique index in v0.2 migration §2: `CREATE UNIQUE INDEX voice_corpus_one_active_per_tenant ON voice_corpus (tenant_slug) WHERE is_active=TRUE`. Postgres enforces — duplicate INSERT fails.
docs/architecture/tenancy-invariants.md:161:  WHERE tablename='voice_corpus' AND indexname='voice_corpus_one_active_per_tenant';
docs/architecture/tenancy-invariants.md:176:  SELECT count(*) FROM voice_corpus;            -- expect 0
docs/architecture/tenancy-invariants.md:211:| T10 | Partial → Verified | v0.2 migration §2 partial unique index + tenancy audit | v0.2 migration design; pending Day-9 functional verify (post live migration) | Single-active voice corpus per tenant |
docs/architecture/tenancy-invariants.md:237:- **At every agent runtime write**: hook-helpers.sh + voice-loader.sh enforce T4 via `SET LOCAL app.current_tenant` pattern; relies on T11 (Postgres RLS) as the structural backstop.
packages/agent-renderer/src/types.ts:49:  voice_threshold?: number;
agents/_shared/tests/test-voice-loader.sh:4:# Offline test harness for agents/_shared/voice-loader.sh.
agents/_shared/tests/test-voice-loader.sh:7:# Run: bash agents/_shared/tests/test-voice-loader.sh
agents/_shared/tests/test-voice-loader.sh:51:LOADER="${REPO_ROOT}/agents/_shared/voice-loader.sh"
agents/_shared/tests/test-voice-loader.sh:53:TMP_ROOT="$(mktemp -d -t voice-loader-test.XXXXXXXX)"
agents/_shared/tests/test-voice-loader.sh:63:mkdir -p "${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_voice"
agents/_shared/tests/test-voice-loader.sh:70:printf '\n[1] hh_load_tone_rules returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:73:  out=$(hh_load_tone_rules)
agents/_shared/tests/test-voice-loader.sh:78:printf '\n[2] hh_load_tone_rules reads tone-rules.yaml fallback path\n'
agents/_shared/tests/test-voice-loader.sh:80:  cat > "${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_voice/tone-rules.yaml" <<EOF
agents/_shared/tests/test-voice-loader.sh:86:  out=$(hh_load_tone_rules)
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
docs/operations/codex-round-2-remediation-prompt.md:162:    - agents/_shared/voice-loader.sh (every voice corpus read)
docs/operations/codex-round-2-remediation-prompt.md:172:  Specifically in voice-loader.sh::_vl_psql_query: wrap the wrapped SQL
docs/operations/codex-round-2-remediation-prompt.md:180:    bash agents/_shared/tests/test-voice-loader.sh
docs/operations/codex-round-2-remediation-prompt.md:187:                              agents/_shared/voice-loader.sh
docs/operations/codex-round-2-remediation-prompt.md:203:      voice-loader — none of which reference Bullhorn). A+B MUST flip
docs/operations/codex-round-2-remediation-prompt.md:402:    - hook-helpers.sh + voice-loader.sh + run-codex-ratification.sh  (FIX 5)
docs/operations/codex-round-2-remediation-prompt.md:429:     - All test suites still pass (hook-helpers 20/20 + voice-loader 9/9 +
docs/operations/codex-round-2-remediation-prompt.md:471:git add agents/_shared/hook-helpers.sh agents/_shared/voice-loader.sh \
docs/operations/codex-round-2-remediation-prompt.md:503:    - hook-helpers.sh + voice-loader.sh + run-codex-ratification.sh:
docs/operations/codex-round-2-remediation-prompt.md:584:7. Re-run agents/_shared/tests/test-hook-helpers.sh + test-voice-loader.sh
docs/operations/codex-round-2-remediation-prompt.md:622:5. hook-helpers.sh + voice-loader.sh + run-codex-ratification.sh transaction wrapping (Risk #11 mitigation across all runtime helpers)
packages/agent-renderer/src/synthesis/claudeMd.ts:26:    "{{voice_threshold}}": String(tenant.voice_threshold ?? 0.75),
packages/agent-renderer/src/synthesis/configJson.ts:26:    "common-voice.json",
docs/architecture/architecture-cohesion-review.md:71:| ADR-004 | phase enum pattern | `agents/_shared/hook-helpers.sh::hh_decision_action` | ✓ landed Phase 3 |
docs/architecture/architecture-cohesion-review.md:93:| A6 | **Voice corpus chunks fit in pgvector memory at v1.0 scale.** HNSW index assumes per-tenant chunk count < 10K. | Phase 4 v0.2 supplement + voice-loader.sh queries | At 1 tenant × 5K chunks = ~30MB. 100 tenants × 5K = 3GB. Within Hetzner VPS RAM. Above 1000 tenants this becomes a real constraint. |
docs/architecture/architecture-cohesion-review.md:147:| G1 | **Concierge "voice corpus refresh" cadence is undefined.** When does a tenant re-index? Operator triggers? Scheduled cron? Re-index on N% recent_edit drift? | Medium (Concierge W10 dependency) | New ADR at Concierge build time OR addendum to v0.2 supplement at v1.0 schema close. Owner: Claude Code, trigger: Week-9. |
docs/architecture/architecture-cohesion-review.md:199:  - **A:** Helpers write to `/vault/<tenant>/decision-log.jsonl` (fallback mode) — that's structured. BUT it's an audit trail that replays into Postgres, not the source of truth. Vault `_voice/`, `_config/`, `_brand/`, `_playbooks/` are content (markdown). Vault `spot-checks/` is markdown notes. Vault `_secrets.env` is config (Path D). ✓ Mostly clean.
docs/architecture/architecture-cohesion-review.md:202:  - **A:** `recent_edit.original_text` + `edited_text` are narrative (raw text). `tone_rule.rule_text` is natural language. `voice_corpus_chunks.text_chunk` is text. **These ARE narrative content in Postgres** — but they're indexed for retrieval, not for primary storage. The vault remains the source of truth for the original docs; Postgres holds the indexable chunked + classified copy. ✓ Acceptable hybrid.
docs/architecture/architecture-cohesion-review.md:213:  - **A:** `packages/agent-renderer/`, `agents/_shared/`, hook-helpers, voice-loader — none reference cortextOS KB at all. They write to IFOS-side Postgres + vault. ✓
docs/architecture/architecture-cohesion-review.md:233:| R7 | G1: Voice corpus refresh cadence | Medium | New ADR-006 at Concierge build OR addendum to v0.2 supplement at v1.0 schema close | Claude Code | Week-9 (pre-Concierge) |
docs/_supplementary/PRD-autonomous-agent.md:257:**Niche**: AI business automation (voice agents, chatbots, automation workflows)  
docs/_supplementary/PRD-autonomous-agent.md:309:- Voice agents: 0 reels
docs/_supplementary/PRD-autonomous-agent.md:637:  topic_priority: 'voice_agents' | 'chatbots' | 'automation' | 'business_results' | 'industry_insights' | 'personal_brand';
docs/_supplementary/PRD-autonomous-agent.md:673:- Rotate through pillars: voice_agents, chatbots, automation, business_results, industry_insights
docs/_supplementary/PRD-autonomous-agent.md:680:  "topic_priority": "voice_agents|chatbots|automation|business_results|industry_insights|personal_brand",
docs/_supplementary/PRD-autonomous-agent.md:1035:- Niche: AI business automation (voice agents, chatbots, workflows)
docs/_supplementary/PRD-autonomous-agent.md:1036:- Voice: Direct, practitioner, specific results, British English
docs/_supplementary/PRD-autonomous-agent.md:1244:  voiceId: string;         // Angela or Hope (ElevenLabs V3 native)
docs/_supplementary/PRD-autonomous-agent.md:1268:        voice: {
docs/_supplementary/PRD-autonomous-agent.md:1271:          voice_id: config.voiceId,
docs/_supplementary/PRD-autonomous-agent.md:1571:      "key": "screen_voiceagent_booking_01",
docs/_supplementary/PRD-autonomous-agent.md:1573:      "path": "workspace/assets/videos/screen_voiceagent_booking_01.mp4",
docs/_supplementary/PRD-autonomous-agent.md:1574:      "description": "Voice agent demo: booking appointment via phone",
docs/_supplementary/PRD-autonomous-agent.md:1576:      "topics": ["voice_agents", "booking", "automation"],
docs/_supplementary/PRD-autonomous-agent.md:1785:- "Reject text_card template when topic is voice_agents"
docs/_supplementary/PRD-autonomous-agent.md:2121:- [ ] Record 5+ screen recordings: chatbot demo, voice agent, workflow builder, dashboard, client call
docs/_supplementary/PRD-autonomous-agent.md:2485:HEYGEN_VOICE_ID=...         # Angela or Hope voice ID
docs/_supplementary/planning-phase-brief.md:34:| **CC5** | **Voice Ingestion Pipeline** — document → voice profile extraction service | Python or TypeScript | §3.3 |
docs/_supplementary/planning-phase-brief.md:79:| 3.3 | Voice Ingestion Pipeline Spec | **P** → CC5 builds |
docs/_supplementary/planning-phase-brief.md:173:- Session 20: Voice Ingestion Pipeline Spec (3.3)
docs/operations/codex-ratification-execution-plan.md:168:| 26 | voice-loader.sh + tests | `agents/_shared/voice-loader.sh` + `tests/test-voice-loader.sh` | A |
docs/_supplementary/technical-strategy-v2.md:108:- Voice/tone guidelines (extracted from brand docs at onboarding)
docs/_supplementary/technical-strategy-v2.md:215:    /voice-receptionist
docs/_supplementary/technical-strategy-v2.md:244:End-to-end under 15 minutes of compute time. Your human time: approve the voice profile in the wizard, review smoke-test outputs, kickoff call. Target: under 4 hours of your time per client.
docs/_supplementary/technical-strategy-v2.md:326:| **CLAUDE.md (brain stem)** | Client identity, voice, key people, pointers into the vault | Auto-loaded every session | Project root |
docs/_supplementary/technical-strategy-v2.md:355:    voice-profile.md          ← core doc; referenced in CLAUDE.md
docs/_supplementary/technical-strategy-v2.md:365:1. **The graph view.** Clients can open their vault in Obsidian and literally *see* their business brain. Notes linked by `[[wikilinks]]` render as a force-directed graph. A new proposal auto-links to the client, which links to past deals, which links to brand voice. The graph grows visibly over time. This is a pure wow-factor feature for sophisticated buyers.
docs/_supplementary/technical-strategy-v2.md:538:Mitigation: **human-in-the-loop at the trust boundary.** Every proposal gets reviewed by the sales lead before it sends. Every invoice-adjacent action requires a human click. Every external-facing piece of content goes to a "review" inbox before posting. Agents draft and queue. Humans approve. This is not a limitation — it's a feature. You are augmenting the team, not replacing them. Sell it that way from day one.
docs/_supplementary/build-plan-original.md:28:14. Voice Receptionist
docs/_supplementary/build-plan-original.md:167:- Tone matches brand voice profile? (0–5)
docs/_supplementary/build-plan-original.md:188:| Voice Receptionist | No gate — live calls (but with strict scope + escalation triggers) |
docs/_supplementary/build-plan-original.md:200:- **Tier 1 (always present)** — `CLAUDE.md` (4KB max). Client name, industry, voice summary, key people, brand do/don'ts. This is the brain stem.
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
docs/_supplementary/build-plan-original.md:625:- Voice match (against 3 retrieved pieces) 0–5
docs/_supplementary/build-plan-original.md:643:- Voice-drift score over time (the LLM-as-judge score trending)
docs/_supplementary/build-plan-original.md:649:Medium. The integrations are light; the voice profile ingestion (§19.3) is where the real engineering goes.
docs/_supplementary/build-plan-original.md:671:- Brand voice profile
docs/_supplementary/build-plan-original.md:727:- Brand voice
docs/_supplementary/build-plan-original.md:760:DocuSign webhook `envelope-completed` or Stripe webhook `invoice.paid` (whichever signals "new client" in this client's workflow, configured in wizard).
docs/_supplementary/build-plan-original.md:889:## 14. Voice Receptionist
docs/_supplementary/build-plan-original.md:895:**Not a Claude Code sub-agent.** Voice-first systems have hard real-time constraints (sub-500ms response) that Claude Code isn't built for. Use a dedicated voice platform:
docs/_supplementary/build-plan-original.md:896:- **Vapi** (best-in-class developer voice platform, supports Claude via proxy, ~$0.05/min)
docs/_supplementary/build-plan-original.md:914:- Out-of-hours behaviour (voicemail? emergency line?)
docs/_supplementary/build-plan-original.md:928:**High.** Voice is its own skill. 3 weeks to do a production-ready Vapi setup with tight escalation logic. Hire or contract specifically for this. Do NOT ship until it's been through 100+ test calls across edge cases.
docs/_supplementary/build-plan-original.md:1004:4. Optional: analyze past ad performance for voice/structure that worked
docs/_supplementary/build-plan-original.md:1069:[Voice Profile Ingester] — processes uploaded brand docs → voice-profile.md
docs/_supplementary/build-plan-original.md:1115:- Brand voice quick-capture: 3 adjectives + 3 banned adjectives + one-sentence "we would never say..."
docs/_supplementary/build-plan-original.md:1129:**Step 4 — Voice & context training (30 min)** *The magic step*
docs/_supplementary/build-plan-original.md:1133:  - Generates draft voice profile
docs/_supplementary/build-plan-original.md:1147:- **Voice ingestion** — background job, triggered on Step 4 upload, runs for 3–7 minutes
docs/_supplementary/build-plan-original.md:1174:7. Billing — current month, forecast, invoice history
docs/_supplementary/build-plan-original.md:1350:- Third-party APIs (Prospeo, Cognism, etc.): track per-tenant calls in your own DB, reconcile monthly with provider invoices.
docs/_supplementary/build-plan-original.md:1358:- Next invoice date
docs/_supplementary/build-plan-original.md:1369:- Setup fees (one-off invoice)
docs/_supplementary/build-plan-original.md:1439:- **Approve with edits** — inline edit, then fire. Edits feed back into the voice profile.
docs/_supplementary/build-plan-original.md:1535:- Voice profile ingestion pipeline
docs/_supplementary/build-plan-original.md:1559:- Voice Receptionist add-on (Vapi integration)
docs/architecture/agent-bundle-renderer-design.md:35:        └── 99-voice-drift-canary/      # NEW IN V2 — every agent has one.
docs/architecture/agent-bundle-renderer-design.md:44:| `config.schema.json` (line 553) | Per-tenant JSON Schema, extending `common-*.json` shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) | the renderer (materialises to `config.json` per §2.1); per-tenant onboarding wizard at Product Spec §5.2 Day 4 fills schema fields | **Static schema; dynamic materialisation** per tenant |
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:55:- **§1.1-B:** master brief §8.1 mentions `_shared/hook-helpers.sh` and `_shared/voice-loader.sh` but does not specify where `_shared/` lives in the rendered output. The bundle's `validate.sh` and `context.sh` `source` these helpers — the renderer needs to materialise the path. Recommended resolution: place `_shared/` at `${projectRoot}/orgs/<org>/agents/_shared/` (one per org, symlinked into every agent dir's `.claude/hooks/_shared/`); rendered hook scripts source via `${CTX_AGENT_DIR}/.claude/hooks/_shared/<helper>.sh`.
docs/architecture/agent-bundle-renderer-design.md:109:| `agents/recruitment/<name>/agent.md` | `orgs/<org>/agents/<name>/CLAUDE.md` | **Synthesis** | (1) `agent.md` body verbatim; (2) **cortextOS preamble template** — spec gap §2.1-A; (3) per-tenant footer (resolved tenant_slug, current `_voice/style-guide.md` path, decision_log Postgres role); (4) hook invocation block referencing `.claude/hooks/{validate,context}.sh` paths | Lint pass: no unresolved `{{tenant_slug}}` / `{{...}}` placeholders survive; preamble matches the renderer's canonical preamble version (hash check); CLAUDE.md is non-empty and parses as valid markdown |
docs/architecture/agent-bundle-renderer-design.md:110:| `agents/recruitment/<name>/config.schema.json` | `orgs/<org>/agents/<name>/config.json` | **Synthesis** | (1) `config.schema.json` (the JSON Schema itself, used for validation); (2) `/vault/{tenant-slug}/_config.yaml` per Ultraplan §5.1 line 220 (provides per-tenant values that fill schema fields); (3) bundle-level defaults from any `default` keys in the schema; (4) common-*.json shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) — spec gap §2.1-B on where common schemas live | Materialised JSON validates clean against the source schema using Ajv (or equivalent) before the renderer writes; required fields all populated; no extra fields beyond schema. Daemon-required fields (per §1.2): `enabled` defaults true, `runtime` defaults `claude-code`, `max_session_seconds` defaults 255600, `working_directory` defaults to the rendered agent dir |
docs/architecture/agent-bundle-renderer-design.md:115:| `agents/recruitment/<name>/tests/fixtures/{01-primary,02-edge-case-*,99-voice-drift-canary}/` | **Not rendered** | **Stays in source** | n/a | n/a — fixtures live in the IFOS repo at `agents/recruitment/<name>/tests/fixtures/`; CI fixture runner (master brief §8.3 line 628) reads them there; runtime does not need them |
docs/architecture/agent-bundle-renderer-design.md:124:- **§2.1-B:** master brief §8.1 line 553 says `config.schema.json` extends "`common-*.json`" but doesn't say where the `common-*.json` shared schemas live. Recommended resolution: `packages/agents-runtime/_shared/common-{client, voice, notifications, vault, ats, accounting, target-patch}.json` per Ultraplan §5.3 line 357-364 enumeration. The renderer resolves `$ref` to these paths during schema materialisation.
docs/architecture/agent-bundle-renderer-design.md:125:- **§2.1-C:** Ultraplan §5.1 line 220 names `_voice/`, `_playbooks/`, `_decisions/`, `_config.yaml` under `/vault/{tenant}/` but does not enumerate `_secrets.env`. Recommended resolution: add `_secrets.env` to the per-tenant vault skeleton; created at tenant provisioning (Ultraplan §5.5 line 263 `provision-tenant.sh {slug}` step 2). Mode `0600` owned by `ifos-tenant-{slug}`. Per Master Brief §3.3 "structured data lives in Postgres" applies to entity data; per-tenant *secrets* are the canonical exception that lives on the filesystem.
docs/architecture/agent-bundle-renderer-design.md:134:- **Master brief §1 Rule 3 (Reuse before build)** — "Every agent uses `agents/_shared/` modules… No agent writes its own logging, voice handling, or approval gate." `_shared/` is the IFOS reuse surface. Inheriting a parallel reuse surface (cortextOS's `.claude/skills/`) creates two reuse vocabularies — confusing and error-prone.
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:180:    └── 99-voice-drift-canary/
docs/architecture/agent-bundle-renderer-design.md:189:check-in missed, every comms in firm voice.
docs/architecture/agent-bundle-renderer-design.md:192:Every lifecycle event → draft within 30 minutes, voice score ≥ 0.75, correct
docs/architecture/agent-bundle-renderer-design.md:207:  within 30 minutes in firm voice (classifier score ≥ 0.75), addressed to
docs/architecture/agent-bundle-renderer-design.md:209:voice_anchors:
docs/architecture/agent-bundle-renderer-design.md:210:  - "_voice/style-guide.md"
docs/architecture/agent-bundle-renderer-design.md:211:  - "_voice/samples (3 nearest neighbors via voice-loader)"
docs/architecture/agent-bundle-renderer-design.md:215:  - voice_classifier_score >= 0.75
docs/architecture/agent-bundle-renderer-design.md:219:  - ESC_VOICE_DRIFT
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:245:    { "$ref": "common-voice.json" },
docs/architecture/agent-bundle-renderer-design.md:270:        "ESC_VOICE_DRIFT": { "type": "string", "format": "telegram-chat-id" }
docs/architecture/agent-bundle-renderer-design.md:307:# Gate A: hard-fail on missing hh_decision_* calls in this run
docs/architecture/agent-bundle-renderer-design.md:311:# Banned-phrase + length + voice classifier + schema + PII checks
docs/architecture/agent-bundle-renderer-design.md:320:source "${CTX_AGENT_DIR}/.claude/hooks/_shared/voice-loader.sh"
docs/architecture/agent-bundle-renderer-design.md:322:hh_load_tone_rules
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:349:The org-level `_shared/` resolves to `orgs/acme/agents/_shared/`, containing `hook-helpers.sh`, `voice-loader.sh`, `escalation-codes.md`, `common-*.json` schemas. The `_shared/` origination question (founder's carry-forward from §1) is addressed in §3.3.
docs/architecture/agent-bundle-renderer-design.md:370:   `hh_decision_trigger` at start of every run
docs/architecture/agent-bundle-renderer-design.md:371:   `hh_decision_output` before producing the artefact
docs/architecture/agent-bundle-renderer-design.md:372:   `hh_decision_action` when the human resolves
docs/architecture/agent-bundle-renderer-design.md:381:- Voice anchor: /vault/acme/_voice/style-guide.md (importance threshold 0.75)
docs/architecture/agent-bundle-renderer-design.md:392:PII is a `ESC_PII_LEAKAGE_RISK` escalation. Voice samples and tone rules in
docs/architecture/agent-bundle-renderer-design.md:393:`/vault/acme/_voice/`. Decision log writes go to Postgres role
docs/architecture/agent-bundle-renderer-design.md:423:    "ESC_VOICE_DRIFT": "<acme operator chat id from _secrets.env>"
docs/architecture/agent-bundle-renderer-design.md:465:Rationale: matches existing IFOS package convention. Master brief §4.1 line 195-204 enumerates the operative package directories (`packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}/`); the renderer is a distinct concern (bundle → runtime translation) that doesn't belong inside any of those. It's not the brain (wiki content, per ADR-002), not the harness (read-only submodule per master brief §3.1), not agents-runtime/_shared/ (the shared helper *content*, not the *tooling* that materialises agents). Standalone `packages/agent-renderer/` keeps the surface clean.
docs/architecture/agent-bundle-renderer-design.md:540:- **Schema refs:** `packages/agents-runtime/_shared/common-{client,voice,notifications,vault,ats,accounting,target-patch}.json` per spec gap §2.1-B and Ultraplan §5.3 line 357-364.
docs/architecture/agent-bundle-renderer-design.md:550:1. IFOS repo is the canonical source: `agents/_shared/{voice-loader.sh, hook-helpers.sh, escalation-codes.md, common-*.json, ...}`.
docs/architecture/agent-bundle-renderer-design.md:642:**Detection:** Preflight check — before any writes, renderer verifies the source paths referenced by `agents/_shared/` are present and contain expected entry points (`voice-loader.sh`, `hook-helpers.sh`, `common-*.json`).
docs/architecture/agent-bundle-renderer-design.md:760:| `packages/agents-runtime/_shared/{voice-loader,hook-helpers}.sh` (per ADR-002 prerequisite) | Claude Code | Weeks 1-2 |
docs/architecture/agent-bundle-renderer-design.md:761:| `packages/agents-runtime/_shared/common-{client,voice,notifications,vault,ats,accounting,target-patch}.json` (per spec gap §2.1-B) | Claude Code | Weeks 1-2 |
docs/architecture/agent-bundle-renderer-design.md:775:**Current** (master brief §4.1 line 195-204): "Create the operative directory structure" followed by an `mkdir -p` command listing `packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}`.
docs/architecture/agent-bundle-renderer-design.md:780:mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext,agent-renderer}
packages/agent-renderer/templates/claude-md-preamble.md:22:- `hh_decision_trigger` at start of every run
packages/agent-renderer/templates/claude-md-preamble.md:23:- `hh_decision_output` before producing the artefact
packages/agent-renderer/templates/claude-md-preamble.md:24:- `hh_decision_action` when the human resolves
packages/agent-renderer/templates/claude-md-preamble.md:36:- Voice anchor: `/vault/{{tenant_slug}}/_voice/style-guide.md` (importance threshold {{voice_threshold}})
packages/agent-renderer/templates/claude-md-preamble.md:44:- `memory/` — replaced by Postgres `decision_log` (writes via `hh_decision_*` helpers).
packages/agent-renderer/templates/claude-md-preamble.md:59:- Voice samples and tone rules live under `/vault/{{tenant_slug}}/_voice/`.
packages/agent-renderer/README.md:7:**Phase 2 scaffold (v0.1.0).** Phases 3-5 (helpers + voice schema + voice-loader) follow per `~/.claude/plans/bubbly-snuggling-lantern.md`. First production render: Diagnostic agent at Week 4 per master brief §8.2.
packages/agent-renderer/README.md:117:- **`_shared/` copy-not-symlink staleness.** Renderer COPIES `agents/_shared/` to `${frameworkRoot}/orgs/<org>/agents/_shared/` per ADR-003 §3.3.3 Option γ — does NOT symlink. Mid-pilot edits to `agents/_shared/{voice-loader,hook-helpers}.sh` require re-running `render-agent` for each tenant. v1.0 acceptable (single-tenant pilot); v1.1 may add SHA-based skip-if-unchanged optimisation.
docs/_supplementary/execution-plan.md:47:The wizard flow (five steps, with copy), the provisioning orchestrator (state machine, rollback paths), the voice ingestion pipeline (past proposals → voice profile). These are IP-critical — worth extra engineering depth.
docs/_supplementary/execution-plan.md:65:Logo + variants, colour + typography lock, brand voice guide (yours, not clients'), marketing site copy (homepage, pricing, about, case studies stub), social media presence plan.
docs/_supplementary/execution-plan.md:154:  - *Purpose:* SessionStart hook that hydrates CLAUDE.md with retrieved past proposals + pricing framework + voice profile.
docs/_supplementary/execution-plan.md:157:  - *Prompt:* "Write `proposal-builder/context.sh` — the SessionStart hook that: (1) parses the trigger payload to identify the prospect, (2) queries the pgvector index for 3 most similar past winning proposals, (3) loads the brand voice profile and pricing framework, (4) appends all this into CLAUDE.md's Context section. Assume the vault is at /tenant/vault and pgvector is accessible via a simple CLI wrapper `vault-search`."
docs/_supplementary/execution-plan.md:181:  - *Prompt:* "Write the Minimal Vault Structure Specification: the starting directory tree for a new tenant's Obsidian vault (/vault/clients, /vault/brand, /vault/sops, /vault/content, /vault/daily, /vault/archive), the seed files with templates (CLAUDE.md, brand/voice-profile.md, brand/pricing.md — all with `[INSERT-FROM-WIZARD]` tokens), the frontmatter conventions (required tags, date formats), and the initial .gitignore + README.md explaining the vault to the client."
docs/_supplementary/execution-plan.md:213:- [ ] **2.4 — Content Creator full bundle** (6 files) — Build Plan §8. *Effort: 3C (voice profile integration is heavier)*
docs/_supplementary/execution-plan.md:249:  - *Prompt:* "Write the Provisioning System Engineering Specification per Build Plan §19: the full state machine (every step as a state with entry/exit conditions), the exact data flow from `wizard.config.json` through template rendering → secret encryption → vault initialisation → voice ingestion trigger → embedding index → container start → cron install → webhook register → smoke tests → dashboard go-live. Cover: idempotency, atomic rollback on any failure, versioning of every output, observability hooks, the exact CLI commands. Target: a senior dev can implement in 2 weeks from this spec alone."
docs/_supplementary/execution-plan.md:255:  - *Prompt:* "Write the Configuration Centre Wizard Full UX Specification: each of the 5 steps (Company Profile, Integrations, Agent Selection, Voice & Context Training, Go-Live) as its own section covering: every field on the screen with label + placeholder + help text + validation rules, the interaction flow, the error states, the empty states, the progress indicators, autosave behaviour, the resume-mid-flow behaviour, the step-to-step navigation logic. Include the copy voice — warm, confident, never condescending, UK-English spellings. This doc feeds a designer and a dev in parallel."
docs/_supplementary/execution-plan.md:257:- [ ] **3.3 — Voice Ingestion Pipeline Spec**
docs/_supplementary/execution-plan.md:258:  - *Purpose:* the critical pipeline where uploaded past proposals → structured voice profile. Quietly one of the highest-leverage components.
docs/_supplementary/execution-plan.md:261:  - *Prompt:* "Write the Voice Ingestion Pipeline Specification: the pipeline that takes client-uploaded documents (PDFs of past proposals, brand guidelines, sample emails — up to 50MB mixed formats) and produces: (1) a structured `voice-profile.md` with tone descriptors + banned phrases + rhythm analysis + signature turns-of-phrase, (2) a `pricing-framework.md` extracted from past proposals, (3) chunked + embedded vault entries for retrieval. Cover: document parsing (mammoth for docx, pypdf for PDF, plaintext for rest), chunking strategy (semantic not fixed-size), embedding call batching, the LLM pipeline that produces the voice profile (Sonnet 4.6 reading 5–20 samples and writing the profile), validation checkpoint where client reviews and edits before approving. Include edge cases (document in non-English, mixed formats in one upload, corrupt PDFs)."
docs/_supplementary/execution-plan.md:303:  - *Prompt:* "Write the Cost & Billing System Engineering Specification per Build Plan §27: the Anthropic API metadata tagging pattern for per-tenant attribution, the third-party API cost tracking table schema, the infra cost allocation formula, Stripe subscription setup (price IDs per tier, metered overages, setup fees as one-off invoices), the dashboard view that shows clients their current usage against allowance, the operator view that shows gross margin per tenant + anomaly detection."
docs/_supplementary/execution-plan.md:373:  - *Prompt:* "Write the Billing View Specification: current plan + next invoice, current-month usage against allowance with forecast, invoice history + download, payment method management (Stripe Customer Portal link), plan upgrade/downgrade flow, overage projection alerts."
docs/_supplementary/execution-plan.md:386:  - *Prompt:* "Write the Settings View Specification: tenant-wide config (brand voice re-training trigger, notification preferences, approval policies, working hours, data residency info), danger-zone (pause all agents, archive tenant, delete data)."
docs/_supplementary/execution-plan.md:409:  - *Prompt:* "Draft an MSA template for IntelForce AI OS: parties, scope of services referencing the 9 core agents + add-ons, service levels (uptime target, response time targets), fees + payment terms (monthly retainer + setup + overages), term + termination (rolling monthly with 30 day notice, immediate for material breach), IP (client retains their data + voice profile; IntelForce retains the platform + agent templates), confidentiality, warranties, liability caps, indemnification, UK law + England jurisdiction. Mark solicitor-review-required clauses clearly. Written in plain English with legal precision, not dense legalese."
docs/_supplementary/execution-plan.md:490:  - *Prompt:* "Write the Client Onboarding Human-Hours Playbook: the exact 4-hour breakdown across the 72-hour window: pre-wizard 30-min kickoff call script, mid-wizard voice-profile review (60 min), smoke-test review (30 min), go-live call (90 min), week-1 check-in (30 min). Each with: objectives, agenda, artefacts produced, what 'success' looks like."
docs/_supplementary/execution-plan.md:494:  - *Prompt:* "Write the IntelForce AI OS Support Playbook: the 20 most likely client support tickets (agent produced bad output, integration disconnected, can't log in, need user added, billing question, want to pause agent, want to rename agent, want new capability, approval queue stuck, question about a log entry, invoice dispute, want to downgrade, want to upgrade, data export request, GDPR DSAR, cancellation request, 'it's not working' vague, hallucination complaint, proposal draft was wrong, voice is drifting). Per ticket: diagnostic questions, resolution steps, escalation path, expected resolution time, template response."
docs/_supplementary/execution-plan.md:538:- [ ] **7.3 — Voice Receptionist Full Spec (Vapi architecture)**
docs/_supplementary/execution-plan.md:541:  - *Prompt:* "Write the Voice Receptionist Full Specification: the Vapi platform configuration (assistants, tools, actions), the pre-call context injection (practice info, FAQs, protocols), the in-call escalation triggers, the post-call Claude Code agent that processes the call outcome, the Calendly/Cal.com booking flow, the FAQ training pipeline, the edge cases (accents, complaints, emergencies, out-of-hours), the testing framework (100+ test calls before launch)."
docs/_supplementary/execution-plan.md:560:  - *Prompt:* "Produce the complete Hospitality Vertical Pack for boutique hotels and Eden-adjacent properties: booking engine integrations (Mews, Cloudbeds), hospitality-specific agents (concierge assistant, guest-experience reporter), voice receptionist tuning, luxury brand voice patterns."
docs/_supplementary/execution-plan.md:566:**Phase 7 Done When:** first vertical pack deployed to 3+ clients. Voice Receptionist live with first dental client. Agency Partner program has closed its first partner.
docs/_supplementary/execution-plan.md:596:- **Human professionals:** solicitor reviews MSA/DPA (5.1, 5.2), designer polishes the dashboard specs (4.1, 4.6), voice-over artist records the Voice Receptionist greetings (7.3).
docs/_supplementary/execution-plan.md:603:- **Voice profile** — takes real past proposals. If you don't have 3+ from a founding customer, the voice profile is speculative. Do the founding customer discovery first.
packages/agent-renderer/tests/fixtures/test-tenant-vault/test-tenant-b/_config.yaml:5:voice_threshold: 0.80
docs/operations/goal-week-3-polish-and-scaffold.md:45:3. **§12 conversation opener is LLM-driven, not deterministic.** Calls Claude API (or OpenAI fallback) with §1-§11 context + tenant voice corpus + tone rules. Voice classifier microservice STUB in place (real classifier W4-5; for now: skip-with-warning preserved).
docs/operations/goal-week-3-polish-and-scaffold.md:63:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:106:| Voice classifier microservice | Reserved for W4-5 polish; for Week 3, §12 LLM call skips voice-classifier gate (V3 stays as a skipped-with-warning) |
docs/operations/goal-week-3-polish-and-scaffold.md:110:| Modifying `_shared/hook-helpers.sh` or `_shared/voice-loader.sh` beyond bug fixes | These are foundational substrate; 29/29 tests pass; treat as stable |
docs/operations/goal-week-3-polish-and-scaffold.md:156:bash agents/_shared/tests/test-voice-loader.sh | tail -3
docs/operations/goal-week-3-polish-and-scaffold.md:208:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:212:   - **Retry:** if response shape malformed, retry once; if still bad, fall back to deterministic logic + emit `ESC_VOICE_DRIFT` warning row.
docs/operations/goal-week-3-polish-and-scaffold.md:213:3. Voice classifier integration: STUB — `IFOS_VOICE_CLASSIFIER_URL` unset means skip-with-warning (preserves V3 behaviour). Real classifier wires up at W4-5.
docs/operations/goal-week-3-polish-and-scaffold.md:217:   - Tone-rule violation in LLM output → retry then ESC_VOICE_DRIFT
docs/operations/goal-week-3-polish-and-scaffold.md:226:Commit: `feat(diagnostic): §12 LLM-driven conversation opener with voice-corpus context`
docs/operations/goal-week-3-polish-and-scaffold.md:309:- **§7 Voice + tone:** N/A (Janitor doesn't produce customer-facing output; all writes are internal data).
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
docs/operations/goal-week-3-polish-and-scaffold.md:341:- **§5 Gate A:** validate.sh hard-fails on missing transcript, field-extraction confidence <0.6, Bullhorn write FK-violation, voice-classifier <0.75 on tacit note.
docs/operations/goal-week-3-polish-and-scaffold.md:343:- **§6 Escalation codes:** ESC_BULLHORN_WRITE_FAIL, ESC_VOICE_DRIFT, ESC_SCHEMA_VIOLATION, ESC_FIELD_EXTRACTION_LOW_CONFIDENCE.
docs/operations/goal-week-3-polish-and-scaffold.md:344:- **§7 Voice + tone:** tacit-note is consultant-voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:345:- **§8 Build prerequisites:** Bullhorn MCP connector (R+W) + Fathom/Fireflies MCP connector (founder commercial signup) + LLM extraction prompt + voice classifier microservice (W5+).
docs/operations/goal-week-3-polish-and-scaffold.md:367:- **§1 Output contract:** reconciles invoices against bank deposits; chases overdue payments via approved orange-tier email drafts (consultant approves before send); writes payment status updates to accounting system; generates weekly cash-flow report to `/vault/<tenant>/cash-conductor-reports/`. No Bullhorn dependency — operates entirely against Xero / QuickBooks / Sage + Open Banking.
docs/operations/goal-week-3-polish-and-scaffold.md:368:- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
docs/operations/goal-week-3-polish-and-scaffold.md:369:- **§4 Workflow:** ~14 steps. Cron daily 06:00 UTC. Fetch open invoices (Xero/QB/Sage rotation per tenant config) → fetch bank transactions (Open Banking) → match invoices ↔ deposits → identify unmatched + overdue → generate chase drafts → write reconciliation rows → weekly report assembly (Mondays).
docs/operations/goal-week-3-polish-and-scaffold.md:370:- **§5 Gate A:** validate.sh hard-fails on accounting API auth failure, bank API auth failure, reconciliation false-positive rate >2%, chase-draft content failing voice classifier.
docs/operations/goal-week-3-polish-and-scaffold.md:371:- **§5 Gate B:** ≥95% invoice match accuracy (vs human spot-check) + ≥15% reduction in days-sales-outstanding (DSO) after 60 days operation.
docs/operations/goal-week-3-polish-and-scaffold.md:373:- **§7 Voice + tone:** chase drafts are voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:401:- **§7 Voice + tone:** N/A (internal output; no customer-facing voice).
docs/operations/goal-week-3-polish-and-scaffold.md:424:- **§4 Workflow:** ~15 steps. Bullhorn poll every 5 min → detect state transition → fetch context (candidate + client + placement entities) → identify message template → LLM draft → voice classifier ≥0.75 → tone-rule check → tier classification → autosend bridge call (per D1 decision) → audit row.
docs/operations/goal-week-3-polish-and-scaffold.md:425:- **§5 Gate A:** validate.sh hard-fails on missing approval-bridge auth (if D1-A bridge), voice classifier <0.75, tone-rule block-severity hit, schema violation, orange-tier-spot-check sample selected.
docs/operations/goal-week-3-polish-and-scaffold.md:427:- **§6 Escalation codes:** ESC_AUTOSEND_BLOCKED, ESC_VOICE_DRIFT, ESC_TONE_RULE_VIOLATION, ESC_APPROVAL_BRIDGE_TIMEOUT, ESC_BULLHORN_AUTH, ESC_LIFECYCLE_STATE_UNKNOWN.
docs/operations/goal-week-3-polish-and-scaffold.md:428:- **§7 Voice + tone:** highest stakes of any agent — customer-facing sends. Voice classifier required (no skip). Tone rules strict (block-severity hit = ESC_TONE_RULE_VIOLATION).
docs/operations/goal-week-3-polish-and-scaffold.md:429:- **§8 Build prerequisites:** D1 autosend orange-tier decision RESOLVED + Bullhorn MCP R+W + voice classifier microservice live + approval bridge built (per D1 outcome) + tenant tone_rule table seeded.
docs/operations/goal-week-3-polish-and-scaffold.md:498:| LLM call rate-limited or 5xx (Step 4 runtime) | Built-in retry once; fall back to deterministic; emit ESC_VOICE_DRIFT warning |
docs/operations/goal-week-3-polish-and-scaffold.md:499:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/operations/goal-week-3-polish-and-scaffold.md:594:7. **Voice + tone (§7) integrates with `_shared/voice-loader.sh`.** No alternative voice system invented.
docs/operations/goal-week-3-polish-and-scaffold.md:611:  Voice classifier:   <skipped per scaffold | live at score X>
docs/operations/goal-week-3-polish-and-scaffold.md:650:    - Diagnostic voice classifier microservice
docs/operations/goal-week-3-polish-and-scaffold.md:685:| 6 | LLM-driven §12 produces opener that fails voice classifier consistently | Medium | Deterministic fallback already in place; flag as W4 polish (real voice classifier wires up later) |
docs/operations/goal-week-3-polish-and-scaffold.md:686:| 7 | The 5 agent.md scaffolds drift in style across days (different writing voice on different days) | Medium | Each scaffold re-reads Diagnostic's agent.md FIRST as the structural template; commit message references the structural anchor |
docs/_supplementary/strategic-plan.md:70:| Voice layer | Not shown in reel | Native voice receptionist agent |
docs/_supplementary/strategic-plan.md:86:4. **Content Creator** — trained on client voice docs, produces long-form content from one-line briefs
docs/_supplementary/strategic-plan.md:101:| Voice Receptionist (Vapi / Retell, trained on practice FAQs) | £400–800/mo | £750 |
docs/_supplementary/strategic-plan.md:253:  - Brand voice (upload docs or paste examples)
docs/_supplementary/strategic-plan.md:268:Step 4: Voice & Context Training
docs/_supplementary/strategic-plan.md:272:  - Client reviews auto-generated "Voice Profile" summary
docs/_supplementary/strategic-plan.md:281:Your role: review the Voice Profile approval and do a 30-minute kickoff call. That's it. The system does the rest.
docs/_supplementary/strategic-plan.md:295:      voice-profile.json
docs/_supplementary/strategic-plan.md:338:- [ ] **You**: Voice ingestion pipeline (upload docs → vector store → voice profile)
docs/_supplementary/strategic-plan.md:366:- Voice Receptionist add-on (Vapi integration)
docs/_supplementary/strategic-plan.md:407:| **Growth** | £7,500 | £1,500 | Full 9 agents, dashboard, all integrations, voice training |
docs/_supplementary/strategic-plan.md:420:2. **Vertical context libraries** — every dental client you onboard improves your dental voice profile, your dental SOP templates, your dental integration library. Network effect per-vertical.
docs/_supplementary/strategic-plan.md:445:- **You try to build everything** (voice + SEO + ads + HR + custom) — this kills you. **Ship 9 agents. Nothing else until month 4.** Write this on your wall.
packages/harness/cortextos/src/daemon/fast-checker.ts:349:   * Format a Telegram voice/audio message for injection.
packages/harness/cortextos/src/daemon/fast-checker.ts:357:  static formatTelegramVoiceMessage(
packages/harness/cortextos/src/daemon/fast-checker.ts:368:    return `=== TELEGRAM VOICE from ${from} (chat_id:${chatId}) ===
packages/harness/cortextos/dashboard/src/lib/data/organization.ts:2:// Reads context.json and brand-voice.md from the framework root org directory.
packages/harness/cortextos/dashboard/src/lib/data/organization.ts:5:import { getOrgContextPath, getOrgBrandVoicePath } from '@/lib/config';
packages/harness/cortextos/dashboard/src/lib/data/organization.ts:47: * Read brand-voice.md for an org. Returns empty string if missing.
packages/harness/cortextos/dashboard/src/lib/data/organization.ts:49:export function getBrandVoice(org: string): string {
packages/harness/cortextos/dashboard/src/lib/data/organization.ts:50:  const filePath = getOrgBrandVoicePath(org);
packages/agent-renderer/tests/fixtures/test-tenant-vault/migration-test/_config.yaml:5:voice_threshold: 0.75
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:94:**Generation:** deterministic anchor-based fallback (ANTHROPIC_API_KEY not set OR LLM call failed). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0; W4-5 polish wires both LLM key + classifier.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:94:**v0 limitation:** voice classifier ≥ 0.75 gate (per agent.md §5 V3) skipped at v0; opener is deterministic anchor-based composition. Wire LLM + per-tenant voice classifier at W4 polish.
docs/architecture/cortexos-primitive-status.md:124:**Risk if flaky:** Concierge loses cross-week candidate conversation context at the 71-hour boundary or at API overflow; rejection drafts lose the prior-state nuance that defines Gate A voice quality on the hardest test case (Ultraplan §8.1 A6 gotcha: "Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship"). Per Ultraplan §3.1 row 2, the documented contingency is: "Manual restart cadence acceptable for v1.0 pilots; flag as known limitation in pilot agreement."
docs/architecture/cortexos-primitive-status.md:303:- `src/telegram/transcribe.ts` (137 lines) + `src/telegram/media.ts` (217 lines) — voice-note transcription and image/document handling — past the "approval surface" minimum but indicates the surface is production-grade for general agent comms.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:41:**Codex says:** "Lines 140-142 send an optional Telegram notification, but line 73 says every step that produces output or takes action MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:43:**Disposition:** **Codex is correct.** Real bug. Step 11 sends a Telegram notification (an action with external side-effect) but doesn't emit a `decision_log` row. Mechanical fix: add `hh_decision_action("operator_notify_telegram", ...)` call to Step 11.
docs/operations/seedlegals-engagement-queries.md:45:>    - **Voice quality drift detection** via aggregated metadata only (`edit_distance`, `tone_rule_matches`, `approval_resolution`)
docs/operations/seedlegals-engagement-queries.md:46:>    - **AI model training corpus** for the SaaS vendor's voice fine-tuning pipeline (per-tenant fine-tuning, not cross-tenant)
docs/operations/seedlegals-engagement-queries.md:74:> 4. **Auto-send liability allocation:** SaaS vendor responsible for false-positive auto-sends (e.g., a payment reminder sent to a settled invoice); tenant responsible for content of approved sends (e.g., consultant approved a draft that contained an error).
docs/operations/seedlegals-engagement-queries.md:95:>   - SaaS vendor: source code, fine-tuning data, voice corpus, customer pipeline
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:26:**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.
docs/decisions/v1.0-kill-criterion.md:355:**Defined in Week 4+ once v1.0 has at least one pilot operational.** v1.1 kill criterion will incorporate v1.0 learnings + v1.1-specific triggers (e.g., wiki UI usability scores, voice classifier drift rates, LoRA training cost-per-tenant).
docs/architecture/vault-concurrency.md:19:- **Founder via Obsidian** — writes `_voice/`, `_playbooks/`, `_decisions/`, free-form `## Notes` sections of any compiled entity (§2.4.1).
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/operations/goal-option-c-diagnostic-end-to-end.md:34:2. **The report passes Gate A (validate.sh)** clean: 12 sections present, ≥1 citation per section, word count 400-2000, no banned phrases (V3 voice classifier passes OR skipped with explicit warning if `IFOS_VOICE_CLASSIFIER_URL` unset for v0).
docs/operations/goal-option-c-diagnostic-end-to-end.md:68:| §12 conversation opener — LLM-generated, minimal voice gate | Sufficient for v0 demo; full voice classifier in W4 polish |
docs/operations/goal-option-c-diagnostic-end-to-end.md:78:| Voice classifier microservice | Defer to Week 4 polish; v0 skips V3 with explicit warning |
docs/operations/goal-option-c-diagnostic-end-to-end.md:89:- **Do NOT** modify `_shared/hook-helpers.sh` or `_shared/voice-loader.sh` beyond fixing genuine bugs (29/29 tests pass; treat as stable substrate)
docs/operations/goal-option-c-diagnostic-end-to-end.md:202:- `_section_12` calls a minimal LLM (Claude or local) with §1-§11 context to produce 2-3 sentence opener; voice classifier SKIPPED (warn, don't fail)
docs/operations/goal-option-c-diagnostic-end-to-end.md:206:Section §12: LLM-generated, voice-classification skipped.
docs/operations/goal-option-c-diagnostic-end-to-end.md:283:- Recommendations for Week-4 polish (weak sections, voice classifier wiring, LinkedIn integration if Proxycurl signed up)
docs/operations/goal-option-c-diagnostic-end-to-end.md:309:| LLM generates §12 with banned phrase | V5 fails; retry up to 3x; if still failing, ESC_VOICE_DRIFT row + report blocked (matches fixture 99); record as known limitation, defer voice tuning to Week-4 polish. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:312:| Real run reveals Gate A V3 voice classifier was actually needed (skipped warning was too lenient) | Surface as W4 polish item; do not block the milestone. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:364:4. **Have a §12 conversation opener that's not generic** — even if voice classifier skipped, the opener should anchor to a specific evidence point from §1-§11 (filings, headcount, hiring posts)
docs/operations/goal-option-c-diagnostic-end-to-end.md:384:Gate A:            PASS (V3 warning — voice classifier skipped per scaffold)
docs/operations/goal-option-c-diagnostic-end-to-end.md:403:  - [Voice classifier microservice wiring]
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
packages/harness/cortextos/src/daemon/agent-manager.ts:344:        // Check for media messages (photo, document, voice, audio, video, video_note)
packages/harness/cortextos/src/daemon/agent-manager.ts:345:        const isMedia = !!(msg.photo || msg.document || msg.voice || msg.audio || msg.video || msg.video_note);
packages/harness/cortextos/src/daemon/agent-manager.ts:374:            } else if (media.type === 'voice' || media.type === 'audio') {
packages/harness/cortextos/src/daemon/agent-manager.ts:375:              formatted = FastChecker.formatTelegramVoiceMessage(from, effectiveChatId, relFilePath, media.duration, media.transcript);
packages/harness/cortextos/src/daemon/agent-manager.ts:966: * checked, so replies to videos/photos/voice arrived as bare text with no
packages/harness/cortextos/src/daemon/agent-manager.ts:978:  if (replyMsg.voice) return '[voice message]';
docs/decisions/ADR-003-agent-bundle-renderer.md:78:> mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext}
docs/decisions/ADR-003-agent-bundle-renderer.md:91:> mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext,agent-renderer}
docs/decisions/ADR-003-agent-bundle-renderer.md:102:> mkdir -p agents/recruitment/{name}/tests/fixtures/{01-primary,02-edge-case-{X},99-voice-drift-canary}
docs/decisions/ADR-003-agent-bundle-renderer.md:156:- **`_shared/` helper code authoring** (`voice-loader.sh`, `hook-helpers.sh` contents) — already on the Week-1 prerequisite list per ADR-002 §"For Week 1 work." Not an ADR; just implementation work.
docs/operations/founder-legal-setup-guide.md:18:2. **Takes autonomous actions** on behalf of recruitment agencies (LinkedIn messages, Bullhorn writes, payment reminders). This creates **professional liability** — if your AI sends a wrong payment chase to a settled invoice, the agency may be liable to the candidate; they may seek to pass that liability to you.
packages/harness/cortextos/dashboard/src/lib/config.ts:84:export function getOrgBrandVoicePath(org: string): string {
packages/harness/cortextos/dashboard/src/lib/config.ts:85:  return path.join(CTX_FRAMEWORK_ROOT, 'orgs', org, 'brand-voice.md');
docs/decisions/brain-ui-scope.md:17:- **v1.0 minimum (weeks 11-13):** wiki API + Postgres tables (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector voice samples + 9 `wiki-*.sh` parallel wrappers + 9 `wiki/lib/*.ts` modules. **No Brain UI** — operational access via Obsidian + CLI + psql.
docs/decisions/brain-ui-scope.md:20:- **v2.0:** second-brain-at-scale features (reflect-driven hygiene, voice-trend analytics, LoRA-version comparison views per master brief §5.5).
docs/decisions/brain-ui-scope.md:43:- Highlights `ESC_*` escalations across all agents — `ESC_BULLHORN_AUTH`, `ESC_VOICE_DRIFT`, `ESC_DUPLICATE_DETECTED`, `ESC_RENDERER_FAILED`, etc.
docs/decisions/brain-ui-scope.md:176:> "- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation."
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:120:└── tests/fixtures/{01-primary, 02-edge-case-X, 99-voice-drift-canary}/
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:162:├── _voice/                                         ← voice profile (Ultraplan §5.1 line 220)
docs/architecture/second-brain-design.md:197:| `_voice/style-guide.md` | one file | markdown | fixed name | Onboarding wizard Day 3 (founder); Concierge edits via Brain UI v1.1+ | every agent's `context.sh` via `_shared/voice-loader.sh` (Ultraplan §6.1 line 322) |
docs/architecture/second-brain-design.md:198:| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:212:| `wiki/compiled/placements/{slug}.md` | one per Placement | same | same | Concierge (v1.0) on placement event | Cash Conductor (v1.0) for invoice context; future Pulse |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:238:| Placement | **v1.0** | Concierge (v1.0 A6) produces; Cash Conductor (v1.0 A4) reads for invoice context |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:362:invoice_id: inv_2026_0042                            # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:427:| `update-entity` | Concierge (v1.0): append conversation note to Candidate page | v1.0 | `(id: str, section: str, content: str, tenant_id: str)` | `EntityRef` | few seconds | Targets the `<!-- BEGIN auto:{section} -->` block per §2.2.1; preserves frontmatter; rewrites backlinks if `display_name` changes; `hh_decision_*` called |
docs/architecture/second-brain-design.md:428:| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
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
docs/architecture/second-brain-design.md:676:| `ingest-entity` | Filesystem write (atomic) + Postgres UPSERT to `entities` + Postgres INSERTs to `entity_links` (all in one transaction per §2.6.1) | None — atomic or fail | Slug collision check via Postgres `SELECT 1 FROM entities WHERE tenant_slug = ? AND id = ?`. `hh_decision_trigger` + `hh_decision_output` calls insert to `decision_log` in the same transaction. |
docs/architecture/second-brain-design.md:682:| `entity-history` | Postgres `decision_log` SELECT by `(tenant_slug, entity_id)` ORDER BY `created_at DESC` | None | v1.1 read; v1.0 writes via `hh_decision_*`. No filesystem fallback — decision_log is unique source. |
docs/architecture/second-brain-design.md:712:- No corruption; both changes land; decision_log captures both `hh_decision_output` rows separately.
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:773:| Cash Conductor | 10:1 | reads invoice + placement + client on every chase; writes only on event |
docs/architecture/second-brain-design.md:782:**Decision-log volume:** every agent run produces 1-3 `decision_log` rows (`hh_decision_trigger`, `hh_decision_output`, optionally `hh_decision_action` when human responds). At 6 v1.0 agents × ~10 runs/agent/day × 3 tenants × 3 rows = ~540 rows/day per shared Postgres instance. Trivial volume; the table needs hash partitioning (per Ultraplan §5.1) primarily for query performance at v1.2+ scale, not v1.0 write throughput.
docs/architecture/second-brain-design.md:784:These assumptions inform §2.4 and §2.5: hot reads go through Postgres-indexed paths (trigram for fuzzy names, GIN for JSONB attributes, plain indexed columns for id/type lookups); write hot-paths use the atomic-file + Postgres-row pattern; pgvector is reserved for voice (low-latency-tolerant retrieval, not transactional) and stays out of the hot agent paths.
docs/architecture/second-brain-design.md:795:- **§2.4:** four Postgres tables + pgvector voice index + filesystem markdown.
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:894:| **v1.0 minimum effort estimate** | ~11-13 days. Breakdown: 12 wrappers × 0.25 day = 3 days; Node CLI + dispatch = 1 day; library (12 ops, concurrency, frontmatter parse/write) = 4-5 days; Postgres migrations = 1 day; pgvector voice integration = 1 day; concurrency tests = 1-2 days. | ~14-17 days. Adds: MCP server scaffolding + tool registration + JSON-RPC handling + PM2 integration + multi-tenant connection-identity validation. The library effort is the same; the server adds ~3-4 days. | ~9-11 days **IF R1**. Under R2, **probably impossible without renderer changes** — adds ~5 days for renderer modification + skill injection logic + per-agent install path. Total under R2: ~14-16 days, **and** undermines R2's clean-separation promise. |
docs/architecture/second-brain-design.md:938:| Implied: cortextOS KB is the substrate | Explicit: parallel system. cortextOS KB untouched, IFOS owns Postgres entities/links/decision_log + pgvector voice + filesystem markdown |
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
docs/architecture/second-brain-design.md:967:| **2.1-A** | Master brief §5.1 lines 297-349 vs Ultraplan §5.1 line 220 disagree on vault layout | Two vault structures specified in different docs | Adopt the merged tree in §2.1 of this design: `/vault/{slug}/` top-level (`_voice/ _playbooks/ _decisions/ _config.yaml wiki/ temp/`) with the master brief's `wiki/{raw,compiled,.wiki}/` subtree underneath. Codex ratifies on Day 7 by reading §2.1. | No |
docs/architecture/second-brain-design.md:974:| **2.4-C** | Master brief / Ultraplan silent on embedding model | No model specified for voice_samples_embedded or future compiled/ embeddings | Adopt `gemini-embedding-001` (3072 dims) — matches cortextOS's KB substrate per kb-setup.sh migration target. Same `GEMINI_API_KEY` serves both. Revisit if a sharply better model ships before Week 11. | No |
docs/architecture/second-brain-design.md:976:| **3.4-A** | Master brief §5.5 (lines 416-420) v1.0 brain wording | Says "shadow four files" — incorrect per Q1.5 | Rewrite per §3.4 of this design: "9 `wiki-*.sh` parallel wrappers + Postgres entities/entity_links/decision_log + pgvector voice." Bundles with ADR-002 atomic correction commit. | No — wording change, not work change. |
docs/architecture/second-brain-design.md:983:**Master brief §5.5's v1.0 minimum brain build stays at weeks 11-13, but the scope is materially clarified.** The "shadow four files + 2 .ts files" framing is replaced by "9 wiki-*.sh parallel wrappers + 9 wiki/lib/*.ts modules + 4 Postgres tables with RLS + pgvector for voice samples." Total v1.0 effort: ~11-13 person-days, fitting the 15-day budget. **Three Week-1 prerequisites move into focus:** ADR-003 renderer design (without it, no IFOS agent can run), `vault-concurrency.md` companion document (without it, the `flock`+Postgres-optimistic-concurrency code can't be reviewed), and `agents/_shared/{voice-loader,hook-helpers}.sh` (without these, the wiki library has no calling conventions). **One Day-4 (this week) tightening:** the Postgres schema migration from `entity_graph` (single table) to `entities` + `entity_links` (two tables) is part of the master brief §6 Day 4 infra task, not deferred. v1.2 graph view and v2.0 LoRA scale-tier are forward-compatible under the chosen Option α with no architectural changes.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:17:| 1-2 | Renderer + `_shared/` + voice corpus + schema v0.2 |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:28:- **Week 1-2 work landed early** (Day 8, commits a279226 → fe56e93). Renderer + `_shared/` + v0.2 schema + voice corpus all live + ratified.
packages/agent-renderer/tests/fixtures/test-agent/agent.md:11:1. `hh_decision_trigger` at session start
packages/agent-renderer/tests/fixtures/test-agent/agent.md:13:3. Echo input + emit `hh_decision_output`
packages/agent-renderer/tests/fixtures/test-agent/agent.md:14:4. Wait for human resolve; emit `hh_decision_action`
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:64:- **pgvector index (v1.0):** `voice_samples_embedded` only — embedding model `gemini-embedding-001` (3072 dimensions), matching cortextOS's KB substrate for forward-compatibility per design §2.4.3.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:93:> "v1.0 minimum (weeks 11-13) — 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; no Brain UI yet. Total v1.0 effort ~11-13 person-days. v1.1 adds `wiki-find.sh` + `wiki-history.sh` + Brain UI today-view and backlinks panel."
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:109:**For the v1.0 brain build (weeks 11-13).** Reference `second-brain-design.md` §3.4 closing paragraph. Weeks 11-13 hold; scope is materially clarified (9 wrappers + 9 library modules + 4 tables + pgvector voice index vs. the original "shadow four files + 2 .ts files" framing). v1.0 effort estimated at 11-13 person-days, fitting the 15-day budget.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
packages/agent-renderer/tests/fixtures/test-agent/tests/fixtures/99-voice-drift-canary/input.txt:1:voice drift canary
docs/decisions/2026-05-18-codex-ratification-manifest.md:105:| 12 | `agents/_shared/hook-helpers.sh` + `agents/_shared/voice-loader.sh` + `scripts/run-codex-ratification.sh` | RATIFIED | Cross-cutting Risk #11 remediation incorporated in this commit; Round-3 RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:170:| 18 | vertical-schema.yaml v0.1 | REJECTED (3 issues) | Issue 1 (voice_classifier_score CHECK) **incorporated** with v0.2 trigger reference. Issue 2 (empty access arrays) **incorporated**. Issue 3 (versioning count) **incorporated**. Plus pre-existing YAML parse errors fixed. |
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
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
packages/agents-runtime/_shared/common-voice.json:46:      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."
packages/agents-runtime/_shared/common-voice.json:49:  "required": ["voice_corpus_path", "voice_classifier_threshold"],
packages/agents-runtime/_shared/common-vault.json:13:    "voice_subdir": {
packages/agents-runtime/_shared/common-vault.json:15:      "default": "_voice/",
packages/agents-runtime/_shared/common-vault.json:16:      "description": "Relative to vault_root; holds style-guide.md + banned-phrases.md + voice samples."
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:7:import { CTX_ROOT, getOrgs, getAgentsForOrg, getAgentDir, getOrgContextPath, getOrgBrandVoicePath, getAllowedRootsConfigPath } from '@/lib/config';
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:291:    return { context: { name: '', description: '', industry: '', icp: '', value_prop: '' }, brandVoice: '' };
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:295:  let brandVoice = '';
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:314:    const bvPath = getOrgBrandVoicePath(org);
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:316:      brandVoice = fs.readFileSync(bvPath, 'utf-8');
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:322:  return { context, brandVoice };
packages/diagnostic-generator/src/sections/conversation-opener.ts:4:// context + tenant voice corpus (when wired via voice-loader.sh) + tone
packages/diagnostic-generator/src/sections/conversation-opener.ts:5:// rules. Voice classifier microservice still skipped per W3 scaffold spec
packages/diagnostic-generator/src/sections/conversation-opener.ts:25:  // Voice corpus context (optional; W4-5 polish wires real corpus)
packages/diagnostic-generator/src/sections/conversation-opener.ts:26:  voiceCorpusSamples?: string[];
packages/diagnostic-generator/src/sections/conversation-opener.ts:128:  const voiceContext = (input.voiceCorpusSamples ?? []).slice(0, 5).join("\n---\n");
packages/diagnostic-generator/src/sections/conversation-opener.ts:134:  const systemPrompt = `You are writing the §12 "Conversation opener" section of a UK recruitment-firm diagnostic report. Output: a 2-3 sentence cold outreach opener written in the consultant's voice. Must be evidence-anchored to a specific signal from the report's §1-§11 evidence (Companies House data, careers-page quotes, LinkedIn signals, recent filings). NOT generic.
packages/diagnostic-generator/src/sections/conversation-opener.ts:144:${voiceContext ? `Voice corpus exemplars (write in this style):\n${voiceContext}\n\n` : ""}${toneRulesText ? `Tone rules to respect:\n${toneRulesText}\n\n` : ""}`;
packages/diagnostic-generator/src/sections/conversation-opener.ts:259:      "**Generation:** LLM-driven (Claude API + evidence context). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0 scaffold; W4-5 polish wires real classifier.",
packages/diagnostic-generator/src/sections/conversation-opener.ts:263:      "**Generation:** deterministic anchor-based fallback (ANTHROPIC_API_KEY not set OR LLM call failed). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0; W4-5 polish wires both LLM key + classifier.",
packages/agent-renderer/tests/unit/synthesis.test.ts:58:      tenant: { tenant_slug: "migration-test", tenant_legal_name: "Migration Test Ltd", tier: "boutique", operating_window: "business-hours", voice_threshold: 0.75 } as TenantConfig,
packages/diagnostic-generator/README.md:37:2. **No LLM-driven §12.** Conversation opener is deterministic anchor-based. W4 wires an LLM + voice classifier.
packages/diagnostic-generator/README.md:38:3. **No voice classifier gate.** validate.sh V3 skipped at v0 with explicit warning.
docs/decisions/sequencing-target.md:40:**Week 3 needs a starting agent.** The renderer (ADR-003) lands Week 1-2; `_shared/voice-loader.sh` + `hook-helpers.sh` land Week 1-2; Postgres `decision_log` lands Day 4 Week 0. By Week 3 the substrate is live and waiting for its first user. Without §A (first agent), Week 3 doesn't have a build target.
docs/decisions/sequencing-target.md:55:| 2 | **Substrate exercise** | Fraction of Week-1-2 substrate (renderer / `_shared/voice-loader.sh` / `_shared/hook-helpers.sh` / Postgres `decision_log` / `_secrets.env` / Bullhorn auth refresh-loop) the agent exercises | Higher substrate exercise = more value as smoke test for the substrate, but also higher risk of substrate-bug-attributed-to-agent confusion |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:123:| 2. Substrate exercise | **Medium-High** | Exercises Bullhorn W (smaller surface than Janitor's R+W). First agent with external webhook trigger (Fathom / Fireflies). First exercise of voice-loader for **tacit-note tone-detection** per Ultraplan §8.1 line 523. Reuses Janitor's Bullhorn auth refresh-loop |
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:168:| 6. Tenant-onboarding readiness | **Hardest** | Needs Bullhorn + Microsoft Graph (or Gmail) per tenant + full voice corpus loaded + nurture cadence config per stage + auto-send approval categories (Solo: drafts-only; Boutique+: candidate-acknowledgement auto-send) + do-not-contact flags. Full onboarding-wizard Day 4 work (Product Spec §5.2) |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:253:| 2. Substrate exercise (sequential build-up) | **Wins** — each agent extends the substrate of the prior (renderer → Bullhorn auth → voice → Tier-1 primitives → multi-source → full Tier-1 lifecycle) | Loses — Concierge has to build its own Bullhorn auth + voice substrate inline | Loses — Concierge built before its substrate dependencies (Scribe's Notes-for-context not yet available) |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
docs/decisions/sequencing-target.md:283:| 3 | W6 | **Scribe** (A3) | voice-loader-for-tacit-notes first exercise; Concierge-upstream Notes-for-context |
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:389:- `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` per master brief §8.1 Changes 1+2.
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:4:triggers: ["buy", "purchase", "pay for", "subscribe to", "need a credit card", "make a payment", "sign up for paid plan", "buy a domain", "purchase API credits", "pay invoice", "need to pay", "financial transaction", "virtual card", "agentcard"]
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:22:- Pay an invoice that was sent to the org
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:27:- `agents/_shared/voice-loader.sh` (Phase 5, commit `fe56e93`)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:66:PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of
docs/decisions/autosend-safety-policy.md:6:**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
docs/decisions/autosend-safety-policy.md:7:**Surfaced by:** Master brief Day 5 spec; load-bearing for every `hh_decision_action` call across the v1.0 agent fleet.
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:85:| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
docs/decisions/autosend-safety-policy.md:96:| Concierge | `bullhorn_note_draft_internal` | 1-in-10 | Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate |
docs/decisions/autosend-safety-policy.md:128:## §4 — Integration with the `hh_decision_action` contract
docs/decisions/autosend-safety-policy.md:132:- `hh_decision_trigger` — at session start; logs the trigger
docs/decisions/autosend-safety-policy.md:133:- `hh_decision_output` — when the agent produces its output artefact
docs/decisions/autosend-safety-policy.md:134:- `hh_decision_action` — when an action is taken (or blocked)
docs/decisions/autosend-safety-policy.md:136:The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.
docs/decisions/autosend-safety-policy.md:141:# hh_decision_action — gate every side-effecting action through the policy
docs/decisions/autosend-safety-policy.md:147:hh_decision_action() {
docs/decisions/autosend-safety-policy.md:209:The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
docs/decisions/autosend-safety-policy.md:313:Target: invoice:INV-2026-0042
docs/decisions/autosend-safety-policy.md:352:| Policy file `autosend-policy.yaml` corrupted (YAML parse error) | First `hh_decision_action` call returns parse error | Fail-safe red for ALL actions; `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` per action; agent halts | IFOS oncall restores from git history; renderer re-deploys; agent resumes |
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:598:| 3 | Policy lookup latency — must be <10ms per `hh_decision_action` call. Caching strategy needed (in-memory per session vs hot-reload). | §4 | Recommend in-memory cache per session (71h cache lifetime aligns with cortextOS context rotation). Hot-reload via PTY restart only. |
docs/decisions/autosend-safety-policy.md:601:| 6 | v1.0 "would-be-orange" cases without orange tier implementation — how does the agent halt for ad-hoc Telegram approval without breaking the green/red binary? | §9 | Recommend a `hh_decision_action_ad_hoc_approval` helper that lives alongside `hh_decision_action`; agent explicitly calls it for known orange cases at v1.0; v1.1 deprecates as orange tier ships. |
docs/decisions/autosend-safety-policy.md:622:- **Q6 (v1.0 ad-hoc orange handling without orange tier shipped):** ACCEPTED. `hh_decision_action_ad_hoc_approval` helper sits alongside `hh_decision_action` in `_shared/hook-helpers.sh` (Week-1 prereq 3). Agent explicitly calls `_ad_hoc_approval` for known orange cases at v1.0; v1.1 deprecates the helper as full orange tier ships through `hh_decision_action`'s case-orange branch.
docs/decisions/autosend-safety-policy.md:632:**For Week 1-2.** The `_shared/voice-loader.sh` + `hook-helpers.sh` Week-1 prerequisite (per ADR-002 §"For Week 1 work" + ADR-003 Decision 3) now has its `hh_decision_action` specification. Implementation work is well-defined: §4 pseudocode + §5 escalation payloads + §7 audit row schema.
docs/decisions/autosend-safety-policy.md:643:2. `hh_decision_action` pseudocode per §4
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:324:- **Postgres `decision_log` RLS:** every Bullhorn-derived `hh_decision_*` row is tenant-scoped per ADR-002 Decision 3 (`tenant_slug` column + RLS policy per `second-brain-design.md` §2.4.2).
docs/runbooks/day-4-provisioning.md:1287:- Not the `_shared/voice-loader.sh` + `hook-helpers.sh` build (the remaining Week-1 prereq)
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
packages/harness/cortextos/tests/sprint1-templates.test.ts:283:        'context.json', 'goals.json', 'brand-voice.md',
docs/runbooks/tenant-lifecycle.md:60:| `Voice corpus seed docs` | Setup call upload | Operator-curated examples + recent consultant drafts |
docs/runbooks/tenant-lifecycle.md:80:mkdir -p /vault/${SLUG}/{_voice,_config,_brand,_playbooks,spot-checks,pending-approvals,wiki/raw}
docs/runbooks/tenant-lifecycle.md:101:voice_threshold: 0.75
docs/runbooks/tenant-lifecycle.md:104:# Step 7: Seed initial voice corpus row (empty — operator uploads docs separately)
docs/runbooks/tenant-lifecycle.md:106:  INSERT INTO voice_corpus (tenant_slug, version, source_doc_count, source_doc_origin,
docs/runbooks/tenant-lifecycle.md:133:- Initial voice_corpus row with `is_active=TRUE` (T10 invariant)
docs/runbooks/tenant-lifecycle.md:148:| Agent draft + approve via Telegram | `hh_decision_action` writes to decision_log; orange-tier blocks on Telegram approval | T4 (every write sets SET LOCAL) |
docs/runbooks/tenant-lifecycle.md:149:| Voice corpus re-index | Operator uploads new docs to `/vault/<slug>/_voice/`; `ifosctl reindex-voice --tenant <slug>` runs ingest pipeline + flips `is_active` atomically | T10 (single-active per tenant) |
docs/runbooks/tenant-lifecycle.md:150:| Tone rule add/edit | Tenant operator edits `/vault/<slug>/_voice/tone-rules.yaml` OR Brain UI v1.1; sync to Postgres `tone_rule` table | T1-T3 (RLS isolation) |
docs/runbooks/tenant-lifecycle.md:247:  DELETE FROM voice_corpus_chunks WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:248:  DELETE FROM voice_corpus      WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:343:- **T10**: voice_corpus is_active=TRUE single-per-tenant (Migrate transition needs atomic flip)
docs/runbooks/tenant-lifecycle.md:351:- **Voice corpus re-index** (Active sub-state): new `voice_corpus` row inserted with `is_active=TRUE`; old row updated to `is_active=FALSE` in same transaction. Partial unique index (T10) enforces no two `is_active=TRUE` rows simultaneously.
docs/runbooks/tenant-lifecycle.md:391:| L8 | Voice corpus re-index ergonomic command (currently manual SQL + ingest) | Medium | `ifosctl reindex-voice --tenant <slug>` v1.1+ | First tenant requests re-index |
docs/runbooks/pii-purge-operational-pattern.md:22:- **Purpose 2: Voice drift detection** — needs aggregated metadata (`edit_distance`, `tone_rules_triggered`, `resolution`) not the raw text.
docs/runbooks/pii-purge-operational-pattern.md:121:- Voice-drift detection nightly cron (operates on `edit_distance` + `tone_rules_triggered` + `resolution`)
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:560:  test('processes voice message', async () => {
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:561:    mock.storeFile('voice_id', Buffer.from('ogg-data'));
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:569:      voice: { file_id: 'voice_id', duration: 5 },
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:574:    expect(result!.type).toBe('voice');
packages/harness/cortextos/src/cli/install.ts:258:    // Voice transcription deps — whisper-cli + ffmpeg + GGML model.
packages/harness/cortextos/src/cli/install.ts:259:    // Best-effort: failures degrade voice messages to path-only (no transcript)
packages/harness/cortextos/src/cli/install.ts:271:        console.log('    Voice messages will be delivered without transcripts until installed.');
docs/build-brief/00-MASTER-BRIEF.md:56:3. **Reuse before build.** Every agent uses `agents/_shared/` modules: voice loader, decision-log writer, validate primitives, escalation router. No agent writes its own logging, voice handling, or approval gate. If the shared module is missing, build the module first, then the agent.
docs/build-brief/00-MASTER-BRIEF.md:57:4. **Quality gates before features.** Gate A (per-run `validate.sh`) working + decision-log writes (`hh_decision_trigger / output / action`) present > extra features. `validate.sh` hard-fails on missing decision-log calls. No exceptions.
docs/build-brief/00-MASTER-BRIEF.md:159:- **Markdown lives in the vault.** Anything human-readable, voice-related, narrative, playbook-like, or that an agent edits and a human reviews.
docs/build-brief/00-MASTER-BRIEF.md:161:- **pgvector indexes over both.** Voice corpus, playbook chunks, decision-log retrieved-context — all embedded.
docs/build-brief/00-MASTER-BRIEF.md:163:The vault is the source of truth for voice and playbooks. Postgres is the source of truth for state and provenance. The Brain UI reads both via the `context-assembly` API (the single audit-logged surface).
docs/build-brief/00-MASTER-BRIEF.md:189:mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext,agent-renderer}
docs/build-brief/00-MASTER-BRIEF.md:350:2. **Compile.** A scheduled compile job (per-tenant nightly cron via cortextos `bus add-cron`) reads `raw/*` newer than the last compile, calls Claude (via the runtime; voice-loaded for the tenant), and either creates new pages in `compiled/{type}/{slug}.md` or extends existing ones. Every compiled page has wiki-link backrefs (`[[Candidate: Sarah Bowen]]`) and YAML frontmatter:
docs/build-brief/00-MASTER-BRIEF.md:406:- **The voice-quality strip.** Persistent footer showing the rolling 4-week voice classifier score. Green ≥ 0.80, amber 0.70–0.80, red < 0.70. Click for trend graph + recent-edit-pattern callouts. **Voice quality is structurally visible, never hidden.**
docs/build-brief/00-MASTER-BRIEF.md:413:| **v1.0 minimum** | Weeks 11–13 (Ultraplan §9) | 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; **no Brain UI yet**. Total v1.0 effort ~11-13 person-days. |
docs/build-brief/00-MASTER-BRIEF.md:416:| **v2.0 — the second brain at scale** | Q3 2027 | Reflect-driven hygiene, voice-trend analytics, LoRA-version comparison views |
docs/build-brief/00-MASTER-BRIEF.md:464:- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation.
docs/build-brief/00-MASTER-BRIEF.md:508:| `phase-2-agent-suite/_shared/hook-helpers.sh` | Common validate/telemetry shell fns | `packages/agents-runtime/_shared/hooks/hook-helpers.sh` | Add `hh_decision_trigger/output/action` per Ultraplan §4.2 |
docs/build-brief/00-MASTER-BRIEF.md:513:| `00-PATTERN-REFERENCE.md` | 6-file agent bundle pattern | `docs/architecture/PATTERN-REFERENCE.md` | Update to v2: `99-voice-drift-canary` fixture required |
docs/build-brief/00-MASTER-BRIEF.md:557:        └── 99-voice-drift-canary/      # NEW IN V2 — every agent has one.
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:571:hh_decision_trigger   # at start; logs trigger
docs/build-brief/00-MASTER-BRIEF.md:572:hh_decision_output    # on output; logs the artefact
docs/build-brief/00-MASTER-BRIEF.md:573:hh_decision_action    # when human acts; logs the action
docs/build-brief/00-MASTER-BRIEF.md:580:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/build-brief/00-MASTER-BRIEF.md:612:mkdir -p agents/recruitment/{name}/tests/fixtures/{01-primary,02-edge-case-{X},99-voice-drift-canary}
docs/build-brief/00-MASTER-BRIEF.md:672:                 │  → bus-overrides                    │   entity-graph svc                        │   hh_decision_*
docs/build-brief/00-MASTER-BRIEF.md:780:- `_shared/` shell helpers (voice loader, decision-log writer, validate primitives)
docs/build-brief/00-MASTER-BRIEF.md:955:> 5. You understand the agent bundle v2 pattern (6 files + 3 fixtures, incl. 99-voice-drift-canary)
docs/build-brief/00-MASTER-BRIEF.md:970:- Ship an agent without a 99-voice-drift-canary because "we'll add it later"
docs/build-brief/00-MASTER-BRIEF.md:986:6. **The quality gates** — Gate A binary per-run, Gate B 90-day, Gate C weekly voice classifier
packages/harness/cortextos/dashboard/src/components/comms/channel-view.tsx:28:  /** Optional: set by the channel API when the message origin is a voice note. */
packages/harness/cortextos/dashboard/src/components/comms/channel-view.tsx:343:            const isVoice = msg.media_type === 'voice';
packages/harness/cortextos/dashboard/src/components/comms/channel-view.tsx:358:                    {isVoice && (
packages/harness/cortextos/dashboard/src/components/comms/channel-view.tsx:359:                      <IconMicrophone size={11} className="text-muted-foreground" aria-label="voice message" />
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:5:import { transcribeVoice } from '../../../src/telegram/transcribe';
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:7:describe('transcribeVoice', () => {
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:35:    const oggPath = join(workDir, 'voice.ogg');
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:37:    expect(await transcribeVoice(oggPath)).toBeNull();
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:41:    expect(await transcribeVoice(join(workDir, 'missing.ogg'))).toBeNull();
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:45:    expect(await transcribeVoice('')).toBeNull();
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:49:    const oggPath = join(workDir, 'voice.ogg');
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:52:    expect(await transcribeVoice(oggPath)).toBeNull();
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:56:    const oggPath = join(workDir, 'voice.ogg');
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:62:    expect(await transcribeVoice(oggPath)).toBeNull();
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:66:    const oggPath = join(workDir, 'voice.ogg');
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:76:    expect(await transcribeVoice(oggPath)).toBeNull();
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:80:    const oggPath = join(workDir, 'voice.ogg');
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:87:    const result = await transcribeVoice(oggPath, { timeoutMs: 100 });
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
packages/harness/cortextos/community/agents/orchestrator/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/community/agents/orchestrator/SOUL.md:56:- External: org brand voice, professional, opinionated when asked
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:264:    const headerMatch = content.match(/^=== TELEGRAM(?:\s+(PHOTO|DOCUMENT|VOICE|AUDIO|VIDEO|VIDEO_NOTE))?\s+from/);
packages/harness/cortextos/src/types/index.ts:496:  voice?: TelegramVoice;
packages/harness/cortextos/src/types/index.ts:534:export interface TelegramVoice {
packages/harness/cortextos/templates/orchestrator/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/templates/orchestrator/SOUL.md:56:- External: org brand voice, professional, opinionated when asked
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:243:Then proceed with cortextOS onboarding (/onboarding), but treat it as a migration-aware onboarding: skip or fast-track any steps that are already handled by the pre-loaded files (identity, role, voice, goals). Focus onboarding on: tool access verification, API key setup, cron confirmation, and any gaps specific to your domain.'
packages/harness/cortextos/templates/orchestrator/.claude/skills/soul-philosophy/SKILL.md:26:The bus is not bureaucracy. The bus is your voice.
packages/harness/cortextos/templates/orchestrator/.claude/skills/soul-philosophy/SKILL.md:124:- Use the org's brand voice
packages/harness/cortextos/templates/hermes/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/templates/hermes/SOUL.md:54:- External: org brand voice, professional, opinionated when asked
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:315:  it('returns [voice message] for voice messages', () => {
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:316:    const msg = { message_id: 5, chat: { id: 1 }, voice: { file_id: 'vc1', duration: 5 } };
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:317:    expect(buildReplyContext(msg)).toBe('[voice message]');
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:17:  brandVoice: string;
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:185:  if (!data || (!data.context.name && !data.brandVoice)) {
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:223:      {data.brandVoice && (
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:226:            <CardTitle>Brand Voice</CardTitle>
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:229:            {renderMarkdown(data.brandVoice)}
packages/harness/cortextos/templates/agent/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/templates/agent/SOUL.md:54:- External: org brand voice, professional, opinionated when asked
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:743:  describe('formatTelegramVoiceMessage', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:744:    it('formats voice message with duration', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:745:      const result = FastChecker.formatTelegramVoiceMessage(
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:748:        '/tmp/telegram-images/voice_1743718313.ogg',
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:752:      expect(result).toContain('=== TELEGRAM VOICE from Alice (chat_id:123456789) ===');
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:754:      expect(result).toContain('local_file: /tmp/telegram-images/voice_1743718313.ogg');
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:759:      const result = FastChecker.formatTelegramVoiceMessage('Alice', '123', '/tmp/voice.ogg', undefined);
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:765:      const result = FastChecker.formatTelegramVoiceMessage(
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:768:        '/tmp/voice.ogg',
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:773:      expect(result).toContain('=== TELEGRAM VOICE from Alice (chat_id:123) ===');
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:775:      expect(result).toContain('local_file: /tmp/voice.ogg');
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:780:      const noArg = FastChecker.formatTelegramVoiceMessage('Alice', '123', '/tmp/voice.ogg', 5);
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:781:      const empty = FastChecker.formatTelegramVoiceMessage('Alice', '123', '/tmp/voice.ogg', 5, '   ');
packages/harness/cortextos/templates/agent/.claude/skills/soul-philosophy/SKILL.md:26:The bus is not bureaucracy. The bus is your voice.
packages/harness/cortextos/templates/agent/.claude/skills/soul-philosophy/SKILL.md:124:- Use the org's brand voice
packages/harness/cortextos/templates/agent-codex/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/templates/agent-codex/SOUL.md:56:- Org brand voice, professional, opinionated when asked
packages/harness/cortextos/community/agents/agent/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/community/agents/agent/SOUL.md:54:- External: org brand voice, professional, opinionated when asked
packages/harness/cortextos/templates/org/brand-voice.md:1:# Brand Voice
packages/harness/cortextos/dashboard/src/app/api/messages/upload/route.ts:22: *   type    - 'photo' | 'voice' | 'document' | 'video'
packages/harness/cortextos/dashboard/src/app/api/messages/upload/route.ts:84:  const typeLabel = type === 'photo' ? 'photo' : type === 'voice' ? 'voice message' : type === 'video' ? 'video' : 'document';
packages/harness/cortextos/community/agents/security/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/community/agents/security/SOUL.md:54:- External: org brand voice, professional, opinionated when asked
packages/harness/cortextos/templates/analyst/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/templates/analyst/SOUL.md:53:- External: org brand voice, professional, opinionated when asked
packages/harness/cortextos/scripts/install-whisper-model.sh:3:# Telegram voice transcription. Idempotent. Skips the download if the model
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:547:  it('voice without transcript: surfaces local_file + duration but no transcript line', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:548:    const inject = `=== TELEGRAM VOICE from James (chat_id:7940429114) ===
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:550:local_file: telegram-images/voice_1234.ogg
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:554:    expect(out).toContain('[VOICE]');
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:555:    expect(out).toContain('local_file: telegram-images/voice_1234.ogg');
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:560:  it('voice with transcript: surfaces transcript text', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:561:    const inject = `=== TELEGRAM VOICE from James (chat_id:7940429114) ===
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:563:local_file: telegram-images/voice_1234.ogg
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:571:    expect(out).toContain('[VOICE]');
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:573:    expect(out).toContain('local_file: telegram-images/voice_1234.ogg');
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:731:    it('VOICE turn appends bus reply directive', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:732:      const inject = `=== TELEGRAM VOICE from James (chat_id:7940429114) ===
packages/harness/cortextos/dashboard/src/app/api/comms/channels/route.ts:78:    // Voice transcript dedup — two-pass bestByMsgId map so transcript
packages/harness/cortextos/templates/analyst/.claude/skills/soul-philosophy/SKILL.md:26:The bus is not bureaucracy. The bus is your voice.
packages/harness/cortextos/templates/analyst/.claude/skills/soul-philosophy/SKILL.md:106:- Use the org's brand voice
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/soul-philosophy/SKILL.md:18:The bus is not bureaucracy. The bus is your voice.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/soul-philosophy/SKILL.md:116:- Use the org's brand voice
packages/harness/cortextos/dashboard/src/app/api/comms/channel/[pair]/route.ts:17:  /** Optional origin marker — set when the message came from a Telegram voice
packages/harness/cortextos/dashboard/src/app/api/comms/channel/[pair]/route.ts:118:  // Voice transcript dedup — Telegram voice notes produce two log entries
packages/harness/cortextos/community/agents/analyst/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/community/agents/analyst/SOUL.md:53:- External: org brand voice, professional, opinionated when asked
packages/harness/cortextos/community/agents/security/.claude/skills/soul-philosophy/SKILL.md:26:The bus is not bureaucracy. The bus is your voice.
packages/harness/cortextos/community/agents/security/.claude/skills/soul-philosophy/SKILL.md:124:- Use the org's brand voice

codex
The first pass shows likely catalogue and citation drift, especially around escalation codes and the ratification skill named in §10. I’m pulling the exact source lines now so the verdict can cite concrete locations.
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '90,195p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '543,556p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,605p'" in /Users/madsadmin/code/CortexOS
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

 succeeded in 0ms:
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
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '220,360p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,140p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '1,420p'" in /Users/madsadmin/code/CortexOS
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
    16	> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate flagged "do not contact" in tenant vault (per ULTRAPLAN A5 line 553 verbatim). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 554 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
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
   116	   → ESC_BRIEF_UNDERSPECIFIED if extraction yields <3 key dimensions
   117	
   118	2. Multi-source auth refresh
   119	   → bullhorn (read-only); LinkedIn/Proxycurl; Reed; CV-Library
   120	   → per-source ESC_<SOURCE>_AUTH on refresh failure
   121	   → if 2+ sources fail auth: ESC_SCHEMA_VIOLATION (abort early; insufficient
   122	     coverage for Gate A 5-15 candidates)
   123	
   124	3. Bullhorn passive-match query
   125	   → bullhorn.search_candidates(filter=brief_key_dimensions, status=passive)
   126	   → up to 30 candidates fetched (will rank+filter later)
   127	   → ESC_RATE_LIMIT_HIT on 429
   128	
   129	4. LinkedIn search (via Proxycurl)
   130	   → proxycurl.search_people(query=brief_key_dimensions, location=brief_location,
   131	     industry=brief_sector)
   132	   → up to 30 profiles
   133	   → cache 1h per (query, location, sector) tuple
   134	   → ESC_LINKEDIN_RATE_LIMIT on Proxycurl quota hit
   135	
   136	5. Reed query
   137	   → reed.search_candidates(query=brief_dimensions, location, salary_band)
   138	   → up to 30 candidates
   139	   → ESC_REED_AUTH on auth fail; ESC_REED_RATE_LIMIT on quota
   140	
   141	6. CV-Library query
   142	   → cvlibrary.search_candidates(query, location, salary_band)
   143	   → up to 30 candidates
   144	   → ESC_CVLIBRARY_AUTH or _RATE_LIMIT
   145	
   146	7. Aggregate + dedupe
   147	   → merge all sources into single candidate set
   148	   → dedupe across sources by (name + email) OR (name + phone) OR
   149	     (LinkedIn URL) — same fuzzy matcher as Janitor (confidence ≥0.85)
   150	   → annotate each row with source provenance (e.g., "from Bullhorn + LinkedIn
   151	     match" if found in both)
   152	
   153	8. "Do not contact" filter
   154	   → load tenant /vault/<slug>/do-not-contact.list (one identifier per line:
   155	     email / phone / LinkedIn URL / Bullhorn CRN)
   156	   → remove any candidate matching any DNC identifier
   157	   → log dropped candidates to exception list
   158	   → ESC_DNC_FILTER_HIT if >5 candidates dropped (suggests over-eager
   159	     search; brief may be poorly scoped)
   160	
   161	9. LLM ranking + rationale generation (per candidate)
   162	   → for top 15 by source-aggregated confidence: generate per-candidate
   163	     rationale ≥50 words
   164	   → prompt = (brief context + candidate profile + voice corpus + tone rules)
   165	   → voice classifier scores rationale (≥0.75)
   166	   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
   167	     from final list
   168	
   169	10. Output assembly + Gate A validation
   170	    → ensure 5-15 candidates remaining after Step 9
   171	    → ensure each has working contact method (email validated via simple
   172	      regex + domain MX check; phone validated via E.164 format)
   173	    → ensure each rationale ≥50 words
   174	    → if any condition fails: ESC_SCHEMA_VIOLATION; partial draft to /tmp;
   175	      abort
   176	    → write Markdown report to vault path per §3
   177	    → hh_decision_output("scout_report", report_path, "N candidates from M sources")
   178	
   179	11. Session close + notification
   180	    → operator notification per invocation source (Brain UI: in-app
   181	      notification; Telegram: reply with report path; webhook: bus event back)
   182	    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
   183	      "N=<N> sources_used=<M>")
   184	    → exit code 0
   185	```
   186	
   187	---
   188	
   189	## §5 — Gates
   190	
   191	### Gate A — validate.sh (hard-fail before action)
   192	
   193	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 553 verbatim):
   194	
   195	- **"5–15 candidates returned per brief"** (count within range)
   196	- **"each has a working contact method"** (email format + MX check OR E.164 phone OR LinkedIn URL OR Bullhorn CRN-with-contact)
   197	- **"each has rationale ≥ 50 words"**
   198	- **"no candidate flagged 'do not contact' in tenant vault"** (DNC list scan)
   199	- All rationales pass voice classifier ≥0.75
   200	- No PII outside firm boundary in rationale text
   201	- No source contributed 0 candidates (suggests source auth failure undetected by Step 2)
   202	
   203	Gate A failures fire `ESC_SCHEMA_VIOLATION`; draft to `/tmp`; operator review.
   204	
   205	### Gate B — Outcome threshold (success metric, not block)
   206	
   207	Per ULTRAPLAN A5 line 554 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
   208	
   209	Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.
   210	
   211	Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
   212	
   213	Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha §6.4 of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
   214	
   215	---
   216	
   217	## §6 — Escalation codes
   218	
   219	Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
   220	
   221	| Code | Trigger | Severity | Routing |
   222	|---|---|---|---|
   223	| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (2+ source fails abort) | operator |
   224	| `ESC_LINKEDIN_AUTH` | Proxycurl API key invalid | warn (single-source fail OK if 2+ others succeed) | operator_chat_id |
   225	| `ESC_LINKEDIN_RATE_LIMIT` | Proxycurl quota exceeded | warn | operator_chat_id |
   226	| `ESC_REED_AUTH` | Reed API fail | warn | operator_chat_id |
   227	| `ESC_REED_RATE_LIMIT` | Reed 429 | warn | operator_chat_id |
   228	| `ESC_CVLIBRARY_AUTH` | CV-Library API fail | warn | operator_chat_id |
   229	| `ESC_CVLIBRARY_RATE_LIMIT` | CV-Library 429 | warn | operator_chat_id |
   230	| `ESC_BRIEF_UNDERSPECIFIED` | LLM brief-parse yields <3 key dimensions | warn | operator_chat_id |
   231	| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   232	| `ESC_DNC_FILTER_HIT` | >5 candidates dropped by DNC list | warn | operator_chat_id |
   233	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
   234	| `ESC_SCHEMA_VIOLATION` | Gate A failure | **blocking** | operator + ifos_oncall |
   235	| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | founder + operator |
   236	| `ESC_RATE_LIMIT_HIT` | Any source 429 (general) | warn | operator_chat_id |
   237	
   238	Sourcing Scout does NOT use:
   239	
   240	- `ESC_AUTOSEND_*` — no auto-send actions; pure read + report
   241	- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
   242	- `ESC_VOICE_DRIFT_TENANT` — per-candidate drift detected at run time (above); no separate 30-day tenant drift signal
   243	
   244	---
   245	
   246	## §7 — Voice + tone constraints
   247	
   248	Step 9 (per-candidate rationale generation) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   249	
   250	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
   251	  - No demographic inference (age, gender, nationality, ethnicity, family status) — Equality Act 2010 compliance
   252	  - No salary-band reference unless explicitly supplied by candidate
   253	  - No claims about candidate intent ("looking to leave their role") without evidence in source data
   254	  - No mention of competing agency placements except in risk-flag context
   255	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
   256	- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Edit-distance >100 chars on >40% of recent_edit rows fires `ESC_VOICE_DRIFT_TENANT`.
   257	
   258	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   259	
   260	---
   261	
   262	## §8 — Build dependencies (W9 prerequisites)
   263	
   264	Sourcing Scout build cannot start until ALL of the following are confirmed:
   265	
   266	| Dependency | Source | Status |
   267	|---|---|---|
   268	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   269	| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
   270	| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
   271	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   272	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   273	| Bullhorn MCP read capability | W3-W4-W5 build chain | ⏸ |
   274	| **Proxycurl commercial signup** + API access | Founder commercial; ~$39+/mo | ⏸ |
   275	| **Reed.co.uk commercial signup** + API access | Founder commercial | ⏸ |
   276	| **CV-Library commercial signup** + API access | Founder commercial | ⏸ |
   277	| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
   278	| Reed MCP connector | W9 build start (~2 days) | ⏸ |
   279	| CV-Library MCP connector | W9 build start (~2 days) | ⏸ |
   280	| Source-abstraction layer (Night Sourcer reuse) | W9 build start (~2 days) | ⏸ |
   281	| Per-tenant source credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   282	| Tenant DNC list at `/vault/<slug>/do-not-contact.list` | Tenant onboarding | ⏸ |
   283	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   284	| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
   285	| `context.sh` hydration | Build at W9 start (~0.5 day) | ⏸ |
   286	| `cycle.sh` orchestration (11-step) | Build at W9 start (~2 days) | ⏸ |
   287	| 3 fixtures with golden outputs | Build at W9 start (~1 day) | ⏸ |
   288	
   289	**Until ALL ⏸ items resolve to ✅, W9 build slice does not start.**
   290	
   291	---
   292	
   293	## §9 — Status + open questions
   294	
   295	**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
   296	
   297	### Open questions for founder review
   298	
   299	| # | Question | Resolution path |
   300	|---|---|---|
   301	| Q1 | All three external sources required for v1.0? Reed + CV-Library are UK-recruitment-specific; Proxycurl is LinkedIn-via-API. Could v1.0 ship with Bullhorn + Proxycurl only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
   302	| Q2 | Proxycurl pricing — ~$39/mo for 5,000 credits at low volume; scales with usage. Per pilot tenant budget? | ~5-10 briefs/day per consultant × 50 calls/brief = up to 2,500 credits/day per consultant. Cost: ~$20-50/day at peak. |
   303	| Q3 | DNC list source — tenant uploads a list, or we derive from Bullhorn entity flag? | v1.0: tenant-uploaded text file at `/vault/<slug>/do-not-contact.list`. v1.1: derive from Bullhorn entity field. |
   304	| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 553 says "≥ 50 words" — using as floor. |
   305	| Q5 | Gate B 6-of-10 metric — measured via consultant feedback. Brain UI v1.0 doesn't have feedback UX yet. Telegram reply? | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful". v1.1: Brain UI button. |
   306	| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
   307	| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Existing Bullhorn candidate-status enum has "passive" / "active" / "placed". | Founder + Bullhorn-rep clarification during Sub-decision B response. |
   308	
   309	### Gotchas (carried forward from ULTRAPLAN A5 line 555)
   310	
   311	1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
   312	2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
   313	3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.
   314	
   315	---
   316	
   317	## §10 — When this document ratifies
   318	
   319	Per `.codex/ratification/review-architecture-decision.md` skill: this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   320	
   321	Status flips Proposed → Accepted when:
   322	- Codex Round 4 Phase 2 ratifies
   323	- Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B UX)
   324	- Q2 cost model approved with per-tenant budget cap
   325	- Q6: ADR-006 (source-abstraction layer) drafted + ratified
   326	
   327	Status flips Accepted → In Force when:
   328	- W9 build slice produces all 5 sibling bundle files + 3 fixtures
   329	- First production brief processed end-to-end against migration-test tenant
   330	- Gate B feedback loop operational (Telegram OR Brain UI)
   331	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   332	
   333	Until then: this document is a forward-looking scaffold.
   334	
   335	*End of Sourcing Scout agent.md draft.*

exec
/bin/zsh -lc 'rg -n "sourcing_scout|brief_id|confidence_score|source|contact|candidate|Brief|do-not-contact|do_not_contact|DNC|status: passive|passive" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:48:#   v0.1 entities (candidate, contractor, contact, brief, opportunity, placement)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:59:    bullhorn_source: none (IFOS-derived from /vault/<tenant>/_voice/ ingest)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:68:        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:73:        source: IFOS-derived (operator names at re-index time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:76:      source_doc_count:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:79:        source: IFOS-derived (counted by ingest pipeline)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:80:        notes: Number of source documents ingested into this version (emails + notes + marketing). Sanity check during re-index.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:81:      source_doc_origin:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:84:        source: IFOS-derived (vault _voice/ subdirectory enumeration)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:90:        source: IFOS-derived (computed by chunking pass)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:91:        notes: Number of text chunks produced from the source corpus after the chunking pass. One chunk = one row in the pgvector index.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:95:        source: IFOS-derived (config; v0.2 default "paragraph")
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:101:        source: IFOS-derived (config; default text-embedding-3-small)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:107:        source: IFOS-derived (timestamped at ingest completion)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:112:        source: IFOS-derived (atomic flip on version rollover)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:117:        source: IFOS-derived (observability counter; pipeline timing)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:126:    bullhorn_source: none (IFOS-derived; authored in /vault/<tenant>/_voice/tone-rules.yaml then synced to Postgres)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:135:        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:139:        source: IFOS-derived (operator names at rule authoring time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:144:        source: IFOS-derived (operator natural-language description)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:149:        source: IFOS-derived (operator picks at rule authoring)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:161:        source: IFOS-derived (default true; operator toggles via Brain UI)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:166:        source: IFOS-derived (enum from rule provenance — onboarding-flow / Brain-UI / CSM-intervention)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:172:        source: IFOS-derived (timestamped at insert)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:176:        source: IFOS-derived (operator-curated at rule authoring)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:182:        source: IFOS-derived (operator-curated at rule authoring)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:192:    bullhorn_source: none (IFOS-derived from operator's approve/edit UX)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:201:        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:205:        source: IFOS-derived (from CTX_AGENT_NAME at edit-capture time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:211:        source: IFOS-derived (lookup against autosend-policy.yaml at edit time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:216:        source: IFOS-derived (entity context at edit time; nullable for system-level edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:218:          Optional pointer to the entity the draft was about (e.g. "candidate", "client"). Enables linking voice drift to entity classes (some entity types correlate with more drift).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:222:        source: IFOS-derived (entity ID at edit time; Bullhorn ID or IFOS slug)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:227:        source: IFOS-derived (agent's draft as produced; capped at 8192 chars)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:233:        source: IFOS-derived (consultant's final version at approve time; null when approved verbatim)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:239:        source: IFOS-derived (Levenshtein computed at insert; null when edited_text null)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:245:        source: IFOS-derived (operator UX action at approve/reject time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:251:        source: IFOS-derived (timestamped at operator action)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:255:        source: IFOS-derived (Gate-A fires recorded by validate.sh + hh_decision_action)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:292:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:300:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:301:      notes: Same as candidate.voice_classifier_score, scoped to contractor sub-case.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:303:  contact:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:307:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:309:        Most-recent voice classifier score from Concierge outbound messages addressed to this contact. Drives addressee-specific drift detection (some contacts' tone preferences may differ from firm baseline).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:315:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:323:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:325:        v1.1+ Triage exercises this; v1.0 sets to NULL. Tracks voice score for outbound messages within a specific candidate-brief opportunity pairing.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:331:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:333:        Snapshot of mean voice classifier score across all Concierge messages for the candidate during the 30 days BEFORE placement close. Captures voice quality at the moment of commercial success — drives "did voice quality predict deal close" reporting + v2.0 LoRA pipeline label generation.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:342:    source: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:386:      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
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
docs/verticals/recruitment/vertical-schema.yaml:88:        enum: [active, archived, do_not_contact, placed, contractor_promoted]
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
docs/verticals/recruitment/vertical-schema.yaml:283:  contact:
docs/verticals/recruitment/vertical-schema.yaml:286:    bullhorn_source: Bullhorn.ClientContact
docs/verticals/recruitment/vertical-schema.yaml:294:        source: Bullhorn.ClientContact.id
docs/verticals/recruitment/vertical-schema.yaml:298:        source: Bullhorn.ClientContact.firstName
docs/verticals/recruitment/vertical-schema.yaml:302:        source: Bullhorn.ClientContact.lastName
docs/verticals/recruitment/vertical-schema.yaml:306:        source: Bullhorn.ClientContact.email
docs/verticals/recruitment/vertical-schema.yaml:310:        source: Bullhorn.ClientContact.phone
docs/verticals/recruitment/vertical-schema.yaml:314:        source: Bullhorn.ClientContact.title
docs/verticals/recruitment/vertical-schema.yaml:320:        source: IFOS-derived (founder captures during intake; thin v0.1, expanded v1.1)
docs/verticals/recruitment/vertical-schema.yaml:322:      preferred_contact_method:
docs/verticals/recruitment/vertical-schema.yaml:326:        source: IFOS-derived
docs/verticals/recruitment/vertical-schema.yaml:330:        source: Bullhorn.ClientContact.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:331:      do_not_contact:
docs/verticals/recruitment/vertical-schema.yaml:334:        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:343:      A role being recruited for. Master brief canonical vocabulary uses `brief`; §6 Day 6 line 490 lists "Role/Brief" — `brief` is the canonical entity_type slug; `role` is documented alias. Bullhorn calls this `JobOrder`.
docs/verticals/recruitment/vertical-schema.yaml:344:    bullhorn_source: Bullhorn.JobOrder
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
docs/verticals/recruitment/vertical-schema.yaml:503:      - (v1.1) Brief Decoder — write submission events
docs/verticals/recruitment/vertical-schema.yaml:508:        source: Bullhorn.JobSubmission.id
docs/verticals/recruitment/vertical-schema.yaml:512:        enum: [submitted, screening, interview_scheduled, interview_completed, offer_pending, offer_accepted, rejected_by_client, rejected_by_candidate, withdrawn]
docs/verticals/recruitment/vertical-schema.yaml:513:        source: Bullhorn.JobSubmission.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:518:        source: IFOS-derived (event log; one entry per status transition)
docs/verticals/recruitment/vertical-schema.yaml:525:        source: Bullhorn.JobSubmission.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:529:        source: Bullhorn.JobSubmission.dateLastModified
docs/verticals/recruitment/vertical-schema.yaml:532:      - v1.1 Brief Decoder + Inbound Triage agents exercise. Schema may revise based on v1.1 build needs.
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
docs/verticals/recruitment/vertical-schema.yaml:610:    target: contact
docs/verticals/recruitment/vertical-schema.yaml:612:    description: Each brief has a designated decision-maker contact at the client (the hiring manager).
docs/verticals/recruitment/vertical-schema.yaml:615:    v1_0_exercise: Concierge reads for addressee-resolution per bullhorn §4.1 A6 Voice gate; addressee = primary decision-maker contact.
docs/verticals/recruitment/vertical-schema.yaml:616:    v1_1_plus_notes: v1.1 Inbound Triage expands to multi-contact panel modelling per Q10.
docs/verticals/recruitment/vertical-schema.yaml:618:  contact_works_for_client:
docs/verticals/recruitment/vertical-schema.yaml:619:    source: contact
docs/verticals/recruitment/vertical-schema.yaml:622:    description: Each contact works at one client (the simplifying v0.1 assumption — multi-employer contacts deferred to v1.1+).
docs/verticals/recruitment/vertical-schema.yaml:625:  candidate_engaged_with_contact:
docs/verticals/recruitment/vertical-schema.yaml:626:    source: candidate
docs/verticals/recruitment/vertical-schema.yaml:627:    target: contact
docs/verticals/recruitment/vertical-schema.yaml:629:    description: Candidates engage with multiple contacts during the interview process (panel interviews, multiple stakeholders). Captures the relationship for autosend-policy `payload_preview` addressee verification.
docs/verticals/recruitment/vertical-schema.yaml:632:  candidate_referred_by_contact:
docs/verticals/recruitment/vertical-schema.yaml:633:    source: candidate
docs/verticals/recruitment/vertical-schema.yaml:634:    target: contact
docs/verticals/recruitment/vertical-schema.yaml:636:    description: Some candidates are referred by a contact (a candidate's previous manager, peer, etc., who is in the IFOS contact registry).
docs/verticals/recruitment/vertical-schema.yaml:640:    source: opportunity
docs/verticals/recruitment/vertical-schema.yaml:643:    description: An opportunity is a candidate's progression toward a specific brief.
docs/verticals/recruitment/vertical-schema.yaml:645:    v1_1_plus_notes: Brief Decoder + Inbound Triage primary readers.
docs/verticals/recruitment/vertical-schema.yaml:647:  opportunity_about_candidate:
docs/verticals/recruitment/vertical-schema.yaml:648:    source: opportunity
docs/verticals/recruitment/vertical-schema.yaml:649:    target: candidate
docs/verticals/recruitment/vertical-schema.yaml:651:    description: Each opportunity is about exactly one candidate; a candidate may have multiple opportunities (different briefs).
docs/verticals/recruitment/vertical-schema.yaml:655:    source: timesheet
docs/verticals/recruitment/vertical-schema.yaml:672:    candidate: none
docs/verticals/recruitment/vertical-schema.yaml:675:    contact: none
docs/verticals/recruitment/vertical-schema.yaml:683:    candidate: R+W   # full sweep + normalisation + dedup proposals
docs/verticals/recruitment/vertical-schema.yaml:686:    contact: R       # read-only (Concierge owns writes)
docs/verticals/recruitment/vertical-schema.yaml:693:    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
docs/verticals/recruitment/vertical-schema.yaml:695:    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
docs/verticals/recruitment/vertical-schema.yaml:696:    contact: none
docs/verticals/recruitment/vertical-schema.yaml:698:    placement: R+W   # note links on placed-candidate calls
docs/verticals/recruitment/vertical-schema.yaml:703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
docs/verticals/recruitment/vertical-schema.yaml:706:    contact: none
docs/verticals/recruitment/vertical-schema.yaml:713:    candidate: R     # passive matching
docs/verticals/recruitment/vertical-schema.yaml:716:    contact: none    # thin v1.0
docs/verticals/recruitment/vertical-schema.yaml:723:    candidate: R+W   # lifecycle state on every event
docs/verticals/recruitment/vertical-schema.yaml:726:    contact: R       # decision-maker resolution for orange-tier sends
docs/verticals/recruitment/vertical-schema.yaml:735:# Per-entity Bullhorn source + field-level mapping notes.
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:752:    notes: Adapter layer materialises both `candidate` and `contractor` entity_type rows from the same Bullhorn.Candidate record when status flips. See entity-level notes.
docs/verticals/recruitment/vertical-schema.yaml:758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
docs/verticals/recruitment/vertical-schema.yaml:760:  contact:
docs/verticals/recruitment/vertical-schema.yaml:763:    field_mapping_density: v0.1 covers 10 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. v1.1 Triage expands contact-side coverage.
docs/verticals/recruitment/vertical-schema.yaml:769:    notes: Skills extraction (required_skills, nice_to_have_skills arrays) is IFOS-derived from JD body, not Bullhorn-sourced (Bullhorn does not consistently structure skill fields across tenants).
docs/verticals/recruitment/vertical-schema.yaml:780:    field_mapping_density: v0.1 covers 5 fields (placeholder shape); full Bullhorn field-density TBD pending v1.1 Brief Decoder / Inbound Triage build.
docs/verticals/recruitment/vertical-schema.yaml:799:    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
docs/verticals/recruitment/vertical-schema.yaml:800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
docs/verticals/recruitment/vertical-schema.yaml:805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
docs/verticals/recruitment/vertical-schema.yaml:819:  Q5_contact_decision_authority_granularity:
docs/verticals/recruitment/vertical-schema.yaml:821:    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:844:  Q9_multi_client_contact:
docs/verticals/recruitment/vertical-schema.yaml:847:    v0_1_decision: contact_works_for_client is N:1 (each contact at exactly one client). Contacts who change employer get a new contact entity per IFOS.
docs/verticals/recruitment/vertical-schema.yaml:848:    revisit_trigger: If pilot tenants surface frequent contact-employer-changes (>5% of contacts change employer over 90 days), revise to M:N (contact_history) with current-employer flag.
docs/verticals/recruitment/vertical-schema.yaml:854:    v0_1_decision: brief_decision_maker is N:1 (each brief has one primary decision-maker contact in v0.1).
docs/verticals/recruitment/vertical-schema.yaml:855:    revisit_trigger: v1.1 Inbound Triage expands to panel modelling — multiple decision-maker contacts per brief with role-in-panel (chair, technical-evaluator, hr-lead, etc.).
docs/verticals/recruitment/vertical-schema.yaml:866:  Q12_source_field_schema:
docs/verticals/recruitment/vertical-schema.yaml:870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.
docs/verticals/recruitment/vertical-schema.yaml:872:      Codex Day-7 ratification reviews whether stricter source-field schema would improve machine-parseability. If accepted, v1.0 introduces structured source object — e.g., `source: {origin: bullhorn | ifos_derived, bullhorn_field?: <entity.field>, ifos_agent?: <agent_name>, citation?: <doc-ref>}`.
docs/verticals/recruitment/vertical-schema.yaml:874:      Mixed-format is readable for v0.1; stricter is Codex review work. Machine-parseability matters if Week-1 prereq 3 (`_shared/hook-helpers.sh`) consumes source provenance for audit; if not consumed programmatically, free-text is fine.
docs/verticals/recruitment/vertical-schema.yaml:898:      Triage expansion (Q5 contact decision-authority granularity, Q10 panel hiring). Skill taxonomy decision (Q8). Multi-client contact decision (Q9). Umbrella company entity promotion candidate (Q7). Opportunity entity exercise begins.

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '80,150p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc 'rg -n "ESC_LINKEDIN_AUTH|ESC_REED_AUTH|ESC_CVLIBRARY_AUTH|ESC_BRIEF_UNDERSPECIFIED|ESC_DNC_FILTER_HIT|ESC_GATE_B_MISS" agents/_shared/escalation-codes.md -S' in /Users/madsadmin/code/CortexOS
 exited 1 in 0ms:
exec
/bin/zsh -lc "rg -n \"passive|do_not_contact|do-not-contact|candidate.*status|status:|enum: \\[active\" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:19:status: Proposed
docs/verticals/recruitment/vertical-schema.yaml:51:    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
docs/verticals/recruitment/vertical-schema.yaml:55:      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:84:      status:
docs/verticals/recruitment/vertical-schema.yaml:87:        source: Bullhorn.Candidate.status
docs/verticals/recruitment/vertical-schema.yaml:88:        enum: [active, archived, do_not_contact, placed, contractor_promoted]
docs/verticals/recruitment/vertical-schema.yaml:90:          "contractor_promoted" = candidate whose status flipped to contractor; row gets duplicated as entity_type="contractor" via adapter layer.
docs/verticals/recruitment/vertical-schema.yaml:156:    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:187:      ir35_status:
docs/verticals/recruitment/vertical-schema.yaml:218:      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
docs/verticals/recruitment/vertical-schema.yaml:257:      status:
docs/verticals/recruitment/vertical-schema.yaml:260:        enum: [active, dormant, churned, prospect]
docs/verticals/recruitment/vertical-schema.yaml:331:      do_not_contact:
docs/verticals/recruitment/vertical-schema.yaml:411:      status:
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:451:      status:
docs/verticals/recruitment/vertical-schema.yaml:454:        enum: [active, completed, terminated, never_started]
docs/verticals/recruitment/vertical-schema.yaml:509:      status:
docs/verticals/recruitment/vertical-schema.yaml:713:    candidate: R     # passive matching
docs/verticals/recruitment/vertical-schema.yaml:752:    notes: Adapter layer materialises both `candidate` and `contractor` entity_type rows from the same Bullhorn.Candidate record when status flips. See entity-level notes.
docs/verticals/recruitment/vertical-schema.yaml:798:    status: RESOLVED (Day 6 founder decision)
docs/verticals/recruitment/vertical-schema.yaml:799:    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
docs/verticals/recruitment/vertical-schema.yaml:800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
docs/verticals/recruitment/vertical-schema.yaml:803:    status: DEFERRED to v1.1
docs/verticals/recruitment/vertical-schema.yaml:809:    status: DEFERRED to Week 3-4
docs/verticals/recruitment/vertical-schema.yaml:815:    status: RESOLVED (Day 6 founder decision)
docs/verticals/recruitment/vertical-schema.yaml:820:    status: DEFERRED to v1.1
docs/verticals/recruitment/vertical-schema.yaml:826:    status: DEFERRED to v2.0
docs/verticals/recruitment/vertical-schema.yaml:832:    status: DEFERRED to v1.1
docs/verticals/recruitment/vertical-schema.yaml:838:    status: DEFERRED to v1.1 / ADR-006
docs/verticals/recruitment/vertical-schema.yaml:845:    status: DEFERRED to v1.1
docs/verticals/recruitment/vertical-schema.yaml:852:    status: DEFERRED to v1.1
docs/verticals/recruitment/vertical-schema.yaml:859:    status: DEFERRED with explicit migration trigger
docs/verticals/recruitment/vertical-schema.yaml:867:    status: DEFERRED to v1.0 Codex ratification
docs/verticals/recruitment/vertical-schema.yaml:883:    status: This document — Proposed
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:3:# Status: Proposed (Codex Day-7 ratification queue addendum)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:24:status: Proposed
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:366:  status: drafted (Phase 4); execution against migration-test tenant scheduled for Phase 5
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:428:    status: This document — Proposed

codex
REJECTED

1. §10 cites the wrong ratification skill. Line 319 says this agent.md ratifies via `.codex/ratification/review-architecture-decision.md`, but the type-specific contract requires `review-agent-bundle.md` for agent bundles, and line 331 only uses that skill for post-build re-ratification. Replace the §10 ratification reference with `review-agent-bundle.md`.

2. §6 claims invented escalation codes are in the shared catalogue. Lines 219-236 list `ESC_LINKEDIN_AUTH`, `ESC_LINKEDIN_RATE_LIMIT`, `ESC_REED_AUTH`, `ESC_REED_RATE_LIMIT`, `ESC_CVLIBRARY_AUTH`, `ESC_CVLIBRARY_RATE_LIMIT`, `ESC_BRIEF_UNDERSPECIFIED`, `ESC_DNC_FILTER_HIT`, and `ESC_GATE_B_MISS`, but `agents/_shared/escalation-codes.md` does not define them; the nearest defined brief code is `ESC_BRIEF_AMBIGUITY`. Either replace these with existing catalogue codes or explicitly flag new codes for catalogue addition.

3. `ESC_SCHEMA_VIOLATION` is repurposed beyond its catalogue definition. Lines 121, 174, 203, and 234 use it for auth coverage and Gate A report-shape failures, but the catalogue defines it as vertical-schema field-constraint validation at write time. Use `ESC_AGENT_OUTPUT_SHAPE` for output validation failures and a catalogue-backed auth/degraded-mode code for source coverage.

4. The workflow does not implement its own decision-log contract. Line 96 promises one `decision_log` row per source query, per candidate proposed, and final aggregate row, and line 104 says output/action steps must call `hh_decision_*`; however, source queries and candidate proposal/drop steps at lines 124-167 have no `hh_decision_*` calls before the single final output call at line 177. Add explicit decision-log calls for each source query, candidate proposal, and filtered/drop event.

5. The artefact assumes a candidate status value not present in schema. Line 125 uses `status=passive`, and line 307 says the Bullhorn candidate-status enum has `"passive" / "active" / "placed"`, but `vertical-schema.yaml` defines candidate.status as `[active, archived, do_not_contact, placed, contractor_promoted]`. Map passive matching through a schema-defined field/status or add the field in a schema supplement before the agent relies on it.
tokens used
69,578
REJECTED

1. §10 cites the wrong ratification skill. Line 319 says this agent.md ratifies via `.codex/ratification/review-architecture-decision.md`, but the type-specific contract requires `review-agent-bundle.md` for agent bundles, and line 331 only uses that skill for post-build re-ratification. Replace the §10 ratification reference with `review-agent-bundle.md`.

2. §6 claims invented escalation codes are in the shared catalogue. Lines 219-236 list `ESC_LINKEDIN_AUTH`, `ESC_LINKEDIN_RATE_LIMIT`, `ESC_REED_AUTH`, `ESC_REED_RATE_LIMIT`, `ESC_CVLIBRARY_AUTH`, `ESC_CVLIBRARY_RATE_LIMIT`, `ESC_BRIEF_UNDERSPECIFIED`, `ESC_DNC_FILTER_HIT`, and `ESC_GATE_B_MISS`, but `agents/_shared/escalation-codes.md` does not define them; the nearest defined brief code is `ESC_BRIEF_AMBIGUITY`. Either replace these with existing catalogue codes or explicitly flag new codes for catalogue addition.

3. `ESC_SCHEMA_VIOLATION` is repurposed beyond its catalogue definition. Lines 121, 174, 203, and 234 use it for auth coverage and Gate A report-shape failures, but the catalogue defines it as vertical-schema field-constraint validation at write time. Use `ESC_AGENT_OUTPUT_SHAPE` for output validation failures and a catalogue-backed auth/degraded-mode code for source coverage.

4. The workflow does not implement its own decision-log contract. Line 96 promises one `decision_log` row per source query, per candidate proposed, and final aggregate row, and line 104 says output/action steps must call `hh_decision_*`; however, source queries and candidate proposal/drop steps at lines 124-167 have no `hh_decision_*` calls before the single final output call at line 177. Add explicit decision-log calls for each source query, candidate proposal, and filtered/drop event.

5. The artefact assumes a candidate status value not present in schema. Line 125 uses `status=passive`, and line 307 says the Bullhorn candidate-status enum has `"passive" / "active" / "placed"`, but `vertical-schema.yaml` defines candidate.status as `[active, archived, do_not_contact, placed, contractor_promoted]`. Map passive matching through a schema-defined field/status or add the field in a schema supplement before the agent relies on it.
