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
session id: 019e5ddb-c454-7750-bec0-5be20e3acff1
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

**Status:** Pre-Build-Round-9-Bilateral-Applied (Day-20; W4 bilateral pass applied). All 3 R8 residuals confirmed closed by post-R8 commit `d1f4c53` (canonical schema-key block + webhook deferred to v1.1+ + Accepted criteria expanded). R9 adds: §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill); §4 Step 8 + Schema-key block rewrite for `blocked_recipients` (correctly cites the migration allowlist as canonical; v0.4-pending applies only to `auto_source_on_brief_create`). Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice.

**Schema-key references:**
- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist (line 397); canonical Postgres-backed v1.0 DNC source per ADR-002. YAML schema declaration deferred to future schema-doc audit (covers all pre-v0.3 allowlist keys not yet declared in YAML).
- `tenant_adapters.config.auto_source_on_brief_create` — v0.4-supplement-pending (not yet in any allowlist); the Bullhorn-webhook auto-source trigger code path is blocked until v0.4 lands.
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).

---

## §2 — Invocation surface

### Brain UI (v1.0 primary)

Brain UI v1.0 "Source candidates" button on any brief detail page → POST internal API → Sourcing Scout webhook.

### Telegram command (v1.0)

```
@ifos_bot scout <brief-id-or-slug>
@ifos_bot scout --description "Senior React engineer, London, £120k, hybrid"
```

### Webhook (DEFERRED to v1.1+)

Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables `auto_source_on_brief_create`. v0.4-supplement-pending (config key not yet registered); webhook-trigger code path is BLOCKED until v0.4 supplement lands. v1.0 invocation is Brain UI button + Telegram only.

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
     §2.10; the config key IS registered in the canonical authority
     `migrations/v0.2-to-v0.3.sql §5` validator allowlist (line 397).
     v0.4-pending status applies ONLY to `auto_source_on_brief_create`
     (the webhook auto-source trigger config), NOT to `blocked_recipients`.
     Postgres-backed per ADR-002 vault/Postgres split — NOT vault markdown.
     Future schema-doc audit will land `blocked_recipients` declaration
     in the YAML schema files alongside other pre-v0.3 allowlist keys.)
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
- No PII outside firm boundary in rationale text → fires `ESC_PII_LEAKAGE_RISK` (BLOCKING per catalogue §2.5 lines 148-154; halts immediately, not warn-only output-shape)
- No enabled live source returns 0 candidates WITHOUT a recorded degradation exception note (sources in degraded mode per §4 Step 2 are expected to return 0 and don't trip Gate A)

Gate A failure routing by class:
- PII leakage → `ESC_PII_LEAKAGE_RISK` (blocking; operator + ifos_oncall)
- Output-shape failures (count not in 5-15, contact-method missing, rationale <50 words, voice classifier miss, all-source-failure-without-degradation) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)
Draft to `/tmp`; operator review.

**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.

### Gate B — Outcome threshold (success metric, not block)

Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.

Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply (v1.0). Aggregate over rolling 30-day window per tenant. NOTE: Bullhorn-note feedback is NOT a v1.0 path (Sourcing Scout is read-only on Bullhorn per §1 + §6 contracts; would require write capability not in v1.0 scope).

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

**Pre-W9-build prerequisites (must resolve to ✅ before W9 starts):** all items listed up to and including "Tenant DNC list populated", "Voice corpus seeded", and "Per-tenant source credentials in _secrets.env" — these are FOUNDER/TENANT-ADMIN actions that the W9 build cannot deliver itself. The four sibling-bundle items below (validate.sh, context.sh, cycle.sh, fixtures) ARE the W9 build slice itself — those are deliverables not prerequisites. Their completion is the W9-build-end Status-flip criterion (Proposed → Accepted), not the W9-build-start gate.

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
| Q5 | Gate B 6-of-10 metric — measured via consultant feedback (Brain UI v1.0 doesn't have feedback UX yet) | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful" → `decision_log` row via `consultant_feedback` green-tier action_type. v1.1: Brain UI button. NOTE: Bullhorn-note-based feedback is NOT a v1.0 path — Sourcing Scout is read-only on Bullhorn (no write capability); Bullhorn note creation would require tools.yaml write capability + autosend/decision logging which v1.0 explicitly excludes. |
| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `date_last_modified_at < now() - 90 days` (per schema line 100) to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side modification-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |

### Gotchas (carried forward from ULTRAPLAN A5 line 555)

1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-agent-bundle.md` skill (built 2026-05-24, commit `825ebd4`): this agent.md ratifies when Codex review-agent-bundle returns RATIFIED verdict on the SCAFFOLD shape (output contract + workflow + gates + escalation + dependencies). **Ratification of the scaffold does NOT make it Accepted.** Per the agent-bundle skill, Accepted means production-ready — which requires all sibling bundle files + fixtures + first production run.

**Three-state lifecycle:**

1. **Proposed → Ratified-as-Scaffold** when Codex review-agent-bundle returns RATIFIED on this agent.md alone. Pre-build scaffold confirmed shape-correct; the document is a binding contract for the W9 build slice.

2. **Ratified-as-Scaffold → Accepted** when ALL:
   - W9 build slice produces all 5 sibling bundle files (`tools.yaml`, `context.sh`, `validate.sh`, `cycle.sh`, `cleanup.sh`) + 3 fixtures with golden outputs
   - Codex re-ratifies the full bundle (agent.md + siblings + fixtures) post-build
   - Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B UX)
   - Q2 cost model approved with per-tenant budget cap
   - Q6: source-abstraction-layer ADR drafted + ratified (new ADR — not the same as ADR-006 which is Diagnostic Gate A; number assigned at authoring time)

3. **Accepted → In Force** when:
   - First production brief processed end-to-end against migration-test tenant
   - Gate B feedback loop operational (Telegram /scout-feedback path; Brain UI in v1.1)
   - First production render against a pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)

Until W9 build: this document is a forward-looking scaffold.

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
I’ll verify the cited source files directly: master brief, ULTRAPLAN, escalation catalogue, schema, autosend policy, voice helper, and relevant migrations/ADRs.
exec
/bin/zsh -lc "rg --files | rg '("'^docs/|''^agents/_shared/|''^migrations/|vertical-schema|autosend-safety-policy|voice-loader|master|ULTRAPLAN|ultraplan)'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
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
docs/design-mockups/brain-ui-decisions-feed-light-v01.html
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
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/decisions/sequencing-target.md
docs/decisions/bullhorn-integration-path.md
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md
docs/runbooks/day-4-provisioning.md
docs/runbooks/operational-hygiene-protocol.md
docs/runbooks/tenant-lifecycle.md
docs/runbooks/pii-purge-operational-pattern.md
docs/build-brief/00-MASTER-BRIEF.md
docs/operations/bullhorn-outreach-emails.md
docs/operations/w4-bilateral-pass-6-agent-md.md
docs/operations/w4-day-20-founder-runbook.md
docs/operations/codex-ratification-guide.md
docs/operations/codex-round-2-handoff.md
docs/operations/codex-round-2-remediation-prompt.md
docs/operations/codex-ratification-execution-plan.md
docs/operations/codex-round-2-autonomous-prompt.md
docs/operations/goal-week-3-polish-and-scaffold.md
docs/operations/seedlegals-engagement-queries.md
docs/operations/goal-option-c-diagnostic-end-to-end.md
docs/operations/founder-legal-setup-guide.md
docs/architecture/tenancy-invariants.md
docs/architecture/architecture-cohesion-review.md
docs/architecture/agent-bundle-renderer-design.md
docs/architecture/cortexos-kb-surface-investigation.md
docs/architecture/cortexos-primitive-status.md
docs/architecture/vault-concurrency.md
docs/architecture/second-brain-design.md
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md
docs/artefacts/diagnostic-hays-plc-2026-05-24.md
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
agents/_shared/README.md
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
logs/codex-ratification/20260524T133645Z-99130/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T133645Z-99130/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T133645Z-99130/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T133053Z-92743/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T133053Z-92743/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T133053Z-92743/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T141337Z-37011/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T141337Z-37011/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141337Z-37011/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-v0-2-supplement-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260525T063902Z-1836/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260525T063902Z-1836/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt

exec
/bin/zsh -lc "rg -n \"Sourcing Scout|A5|W9|8\\.2|blocked_recipients|auto_source_on_brief_create|ESC_LINKEDIN_AUTH|ESC_REED_AUTH|ESC_CVLIBRARY_AUTH|ESC_AGENT_OUTPUT_SHAPE|ESC_GATE_B_MISS|ESC_BRIEF_AMBIGUITY|ESC_PII_LEAKAGE_RISK|consultant_feedback|send_to_blocked_recipient|hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|candidate:|date_last_modified_at|tenant_adapters|ADR-002|ADR-003|ADR-004\" docs agents migrations packages -S" in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: migrations: No such file or directory (os error 2)
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:107:  consultant_feedback:
agents/_shared/autosend-policy.yaml:110:    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
agents/_shared/autosend-policy.yaml:116:    reason: "Internal audit row written by validate.sh when Gate A enforcement fails. Carries the specific ESC code (e.g. ESC_AGENT_OUTPUT_SHAPE | ESC_PII_LEAKAGE_RISK) in the payload; the action itself is just the audit-row write, not an external send. Each agent's validate.sh emits this row before exit 1."
agents/_shared/autosend-policy.yaml:128:    reason: "Internal audit row written by cycle.sh when @ifos/diagnostic-generator produces empty stdout. Carries ESC_AGENT_OUTPUT_SHAPE payload."
agents/_shared/autosend-policy.yaml:229:  gmail_outlook_send_to_candidate:
agents/_shared/autosend-policy.yaml:342:    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
agents/_shared/autosend-policy.yaml:345:  send_to_blocked_recipient:
agents/_shared/autosend-policy.yaml:349:    reason: "Recipient in tenant's blocked_recipients override list"
agents/_shared/autosend-policy.yaml:353:# Defaults applied when override fields are absent in tenant_adapters
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 3 tenant_adapters.config keys + v0.2 entity-access amendments).
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
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:189:          POINTER ONLY (per ADR-002 vault/Postgres split). The 7d check-in
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
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:608:      §4 Step 3 + ADR-002 vault/Postgres split.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:738:# §4 — tenant_adapters.config new keys (3 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:741:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:742:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:745:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:880:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:882:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:920:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:955:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:967:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:996:      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1005:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:55:      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:100:      date_last_modified_at:
docs/verticals/recruitment/vertical-schema.yaml:141:        source: IFOS-derived (set by Sourcing Scout at first-touch)
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
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
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:841:    revisit_trigger: Skill-matching accuracy from Sourcing Scout's first 4 tenant-weeks of operation; if free-text matching produces <60% precision, canonical skill taxonomy lands as v1.1.
packages/agents-runtime/_shared/common-accounting.json:5:  "description": "Accounting-system stub used by Cash Conductor (W7-8 v1.0). Xero-only in v1.0 per master brief §8.2 row 4; extensible later. Per PRODUCT-SPEC §5.3 line 362.",
packages/harness/cortextos/package-lock.json:24:        "@playwright/test": "^1.58.2",
packages/harness/cortextos/package-lock.json:1184:      "integrity": "sha512-HHMwmarRKvoFsJorqYlFeFRzXZqCt2ETQlEDOb9aqssrnVBB1/+xgTGtuTrIk5vzLNX1MjMtTf7W9z3tsSbrxw==",
packages/harness/cortextos/package-lock.json:1345:      "integrity": "sha512-4LqhUomJqwe641gsPp6xLfhqWMbQV04KtPp7/dIp0nzPxAkNY1AbwL5W0MQpcalLYk07vaW9Kp1PBhdpZYYcEw==",
packages/harness/cortextos/package-lock.json:1836:        "node": ">=18.20"
packages/harness/cortextos/package-lock.json:2455:      "version": "1.8.2",
packages/harness/cortextos/package-lock.json:2456:      "resolved": "https://registry.npmjs.org/mlly/-/mlly-1.8.2.tgz",
packages/harness/cortextos/package-lock.json:2605:      "integrity": "sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==",
packages/harness/cortextos/package-lock.json:2640:      "integrity": "sha512-C8oWjPR3F81yljW9o5OxcWzfh6avkVwDD2VYdwIGqTkl+OGFISgypqzfu7dOe4QNLL2aqcWBmI3PMtLIK233lw==",
packages/harness/cortextos/package-lock.json:2941:      "version": "8.2.0",
packages/harness/cortextos/package-lock.json:2942:      "resolved": "https://registry.npmjs.org/string-width/-/string-width-8.2.0.tgz",
packages/harness/cortextos/package-lock.json:3233:      "version": "7.18.2",
packages/harness/cortextos/package-lock.json:3234:      "resolved": "https://registry.npmjs.org/undici-types/-/undici-types-7.18.2.tgz",
agents/_shared/escalation-codes.md:110:- **Trigger:** Renderer exited non-zero. Mid-render atomic-rename per ADR-003 §3.3.4 means the prior agent dir at target is preserved (`.prev.<timestamp>/`) — no half-rendered state visible to daemon discovery
agents/_shared/escalation-codes.md:115:- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7
agents/_shared/escalation-codes.md:141:#### `ESC_BRIEF_AMBIGUITY`
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:148:#### `ESC_PII_LEAKAGE_RISK`
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
agents/_shared/escalation-codes.md:426:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
agents/_shared/escalation-codes.md:466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:383:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:390:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:416:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:458:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:460:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:461:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:463:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:79:-- is the indexed surface for hh_load_voice_samples semantic retrieval.
agents/_shared/hook-helpers.sh:8:# render time (ADR-003 §3.3.3 Option γ).
agents/_shared/hook-helpers.sh:286:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
agents/_shared/hook-helpers.sh:393:# tenant override via tenant_adapters.config.sampling_rates.
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
packages/agents-runtime/_shared/common-voice.json:46:      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."
packages/agents-runtime/_shared/common-vault.json:41:      "description": "chmod 0600; loaded by render-agent .env synthesis per ADR-003 §2.1 row 3 + Day-4 §6.5."
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:61:-- §3 — Per-tenant retention override storage (tenant_adapters extension)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
packages/agents-runtime/_shared/common-base.json:5:  "description": "Shared identity fields every agent config must include. Per ADR-003 §2.1-B + spec gap §2.1-B resolution.",
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:68:-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:71:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:72:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:74:-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:76:-- tenant_adapters config validation trigger.
agents/_shared/README.md:5:This directory is the **canonical source** for files the renderer copies into every per-tenant agent's runtime location at `${frameworkRoot}/orgs/<tenant>/agents/_shared/` per ADR-003 §3.3.3 Option γ. Each rendered agent reaches `_shared/` via a symlink at `.claude/hooks/_shared → ../../_shared`.
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:18:## Renderer-copies-not-symlinks contract (ADR-003 §3.3.3 Option γ)
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
agents/_shared/tests/test-hook-helpers.sh:132:  hh_decision_action "diagnostic_report_render" "candidate:test" "abc123" "test preview"
agents/_shared/tests/test-hook-helpers.sh:159:  HH_AWAIT_TEST_MODE=approve hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash1" "preview"
agents/_shared/tests/test-hook-helpers.sh:173:  HH_AWAIT_TEST_MODE=reject hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash2" "preview"
agents/_shared/tests/test-hook-helpers.sh:263:  autosend_spot_check_enqueue "bullhorn_candidate_dedupe" "candidate:foo" "abc123def456" "merge preview" "${CTX_TENANT_SLUG}"
agents/_shared/tests/test-hook-helpers.sh:273:  hh_decision_action "bullhorn_candidate_dedupe" "candidate:foo" "hash9" "preview"
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
agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
packages/agents-runtime/_shared/common-target-patch.json:5:  "description": "Tenant's commercial sweet spot: sectors, geography, deal sizes, allow/block lists. Read by Sourcing Scout (W9) + Diagnostic (W3-4). Per PRODUCT-SPEC §5.3 line 363.",
packages/agents-runtime/_shared/common-target-patch.json:38:      "description": "Bands surface in Diagnostic ICP scoring + Sourcing Scout shortlist filtering."
agents/recruitment/cash-conductor/agent.md:6:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:9:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
agents/recruitment/cash-conductor/agent.md:56:- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
agents/recruitment/cash-conductor/agent.md:149:14 steps. Per ADR-003 §3 agent-bundle pattern + the review-agent-bundle Codex ratification skill §4 ("every output/action step MUST call hh_decision_*"): every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Master brief §8.1 Change 2 mandates the three-call minimum per agent run (`trigger`, `output`, `action`); the per-step mandatory-write discipline is the agent-bundle contract extension.
agents/recruitment/cash-conductor/agent.md:176:     the table per ADR-002 vault/Postgres split — structured state in Postgres,
agents/recruitment/cash-conductor/agent.md:184:     W7 build slice creates per ADR-002 vault/Postgres split)
agents/recruitment/cash-conductor/agent.md:232:       `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint failure)
agents/recruitment/cash-conductor/agent.md:282:    → update tenant_adapters.config.cash_conductor_last_run = now()
agents/recruitment/cash-conductor/agent.md:306:Gate A failures fire either `ESC_AGENT_OUTPUT_SHAPE` (invoice/amount/paid-precondition miss; output-shape constraint) OR `ESC_ADDRESSEE_MISMATCH` (client_contact_email mismatch; blocking per catalogue §2.10 — explicit Cash Conductor invoice/chase addressee case). Draft stays in `/tmp` (auto-purged 24h); operator notified per the specific ESC route.
agents/recruitment/cash-conductor/agent.md:318:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:336:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in chase body | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:337:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss on invoice_number / amount_due / paid-invoice-precondition (NOT addressee mismatch — that uses ESC_ADDRESSEE_MISMATCH) | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:339:| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
agents/recruitment/cash-conductor/agent.md:346:- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
agents/recruitment/cash-conductor/agent.md:356:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:360:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/cash-conductor/agent.md:361:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
agents/recruitment/cash-conductor/agent.md:423:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
agents/recruitment/cash-conductor/agent.md:440:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
agents/recruitment/scribe/agent.md:6:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies (Ringover deferred to v1.1+ — not in v0 build dependencies; webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:151:   → ESC_PII_LEAKAGE_RISK if transcript references non-tenant PII
agents/recruitment/scribe/agent.md:161:   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
agents/recruitment/scribe/agent.md:233:Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/scribe/agent.md:247:Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).
agents/recruitment/scribe/agent.md:262:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in transcript or note | **blocking** | operator + ifos_oncall |
agents/recruitment/scribe/agent.md:264:| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:281:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:285:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:286:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:334:| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |
agents/recruitment/sourcing-scout/README.md:1:# Sourcing Scout — directory README
agents/recruitment/sourcing-scout/README.md:3:**Status:** Proposed (Day-19 pre-W9-build scaffold).
agents/recruitment/sourcing-scout/README.md:14:Full bundle at W9 build (~2 weeks per ULTRAPLAN A5 line 554):
agents/recruitment/sourcing-scout/README.md:27:Per ULTRAPLAN A5 line 555 gotcha: source-abstraction layer designed for Night Sourcer reuse. Defer ADR-006 to W9 build start documenting the layer's interface.
agents/recruitment/sourcing-scout/README.md:33:*End of Sourcing Scout README.*
agents/recruitment/sourcing-scout/agent.md:1:# Sourcing Scout — request-response passive sourcing
agents/recruitment/sourcing-scout/agent.md:3:**Status:** Pre-Build-Round-9-Bilateral-Applied (Day-20; W4 bilateral pass applied). All 3 R8 residuals confirmed closed by post-R8 commit `d1f4c53` (canonical schema-key block + webhook deferred to v1.1+ + Accepted criteria expanded). R9 adds: §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill); §4 Step 8 + Schema-key block rewrite for `blocked_recipients` (correctly cites the migration allowlist as canonical; v0.4-pending applies only to `auto_source_on_brief_create`). Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:6:- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist (line 397); canonical Postgres-backed v1.0 DNC source per ADR-002. YAML schema declaration deferred to future schema-doc audit (covers all pre-v0.3 allowlist keys not yet declared in YAML).
agents/recruitment/sourcing-scout/agent.md:7:- `tenant_adapters.config.auto_source_on_brief_create` — v0.4-supplement-pending (not yet in any allowlist); the Bullhorn-webhook auto-source trigger code path is blocked until v0.4 lands.
agents/recruitment/sourcing-scout/agent.md:10:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:11:**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
agents/recruitment/sourcing-scout/agent.md:12:**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.
agents/recruitment/sourcing-scout/agent.md:20:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:28:Brain UI v1.0 "Source candidates" button on any brief detail page → POST internal API → Sourcing Scout webhook.
agents/recruitment/sourcing-scout/agent.md:39:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables `auto_source_on_brief_create`. v0.4-supplement-pending (config key not yet registered); webhook-trigger code path is BLOCKED until v0.4 supplement lands. v1.0 invocation is Brain UI button + Telegram only.
agents/recruitment/sourcing-scout/agent.md:61:# Sourcing Scout — <Brief title>
agents/recruitment/sourcing-scout/agent.md:113:     + DNC list from `tenant_adapters.config.blocked_recipients` (Postgres-
agents/recruitment/sourcing-scout/agent.md:114:     backed per ADR-002 vault/Postgres split; canonical v0.1 + v0.2 + v0.3
agents/recruitment/sourcing-scout/agent.md:122:   → ESC_BRIEF_AMBIGUITY if extraction yields <3 key dimensions (per
agents/recruitment/sourcing-scout/agent.md:131:     - ESC_BULLHORN_AUTH (catalogue §2.3): blocking → Sourcing Scout
agents/recruitment/sourcing-scout/agent.md:134:       continue with other 3 sources, since Sourcing Scout has no
agents/recruitment/sourcing-scout/agent.md:137:     - ESC_LINKEDIN_AUTH (catalogue §2.7): blocking → degraded mode
agents/recruitment/sourcing-scout/agent.md:138:       (Sourcing Scout: cached LinkedIn search only; live profile fetches
agents/recruitment/sourcing-scout/agent.md:140:     - ESC_REED_AUTH (catalogue §2.7): blocking → degraded mode (cached
agents/recruitment/sourcing-scout/agent.md:142:     - ESC_CVLIBRARY_AUTH (catalogue §2.7): blocking → degraded mode
agents/recruitment/sourcing-scout/agent.md:145:     sources cannot produce ≥5 candidates: ESC_AGENT_OUTPUT_SHAPE +
agents/recruitment/sourcing-scout/agent.md:152:     status='active', date_last_modified_at < now() - interval '90 days')
agents/recruitment/sourcing-scout/agent.md:156:     contractor_promoted] (line 84-88) and candidate.date_last_modified_at
agents/recruitment/sourcing-scout/agent.md:174:   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:181:   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
agents/recruitment/sourcing-scout/agent.md:195:   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
agents/recruitment/sourcing-scout/agent.md:197:     `send_to_blocked_recipient` action_type + ESC_DNC_FILTER_HIT catalogue
agents/recruitment/sourcing-scout/agent.md:200:     v0.4-pending status applies ONLY to `auto_source_on_brief_create`
agents/recruitment/sourcing-scout/agent.md:201:     (the webhook auto-source trigger config), NOT to `blocked_recipients`.
agents/recruitment/sourcing-scout/agent.md:202:     Postgres-backed per ADR-002 vault/Postgres split — NOT vault markdown.
agents/recruitment/sourcing-scout/agent.md:203:     Future schema-doc audit will land `blocked_recipients` declaration
agents/recruitment/sourcing-scout/agent.md:208:     REFUSAL specifically. Sourcing Scout filters DNC matches AT SOURCING
agents/recruitment/sourcing-scout/agent.md:222:   → hh_decision_output("candidate_proposed", "candidate:<bullhorn_id|external_ref>",
agents/recruitment/sourcing-scout/agent.md:230:    → if any condition fails: ESC_AGENT_OUTPUT_SHAPE (output-shape violation
agents/recruitment/sourcing-scout/agent.md:251:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
agents/recruitment/sourcing-scout/agent.md:256:- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
agents/recruitment/sourcing-scout/agent.md:258:- No PII outside firm boundary in rationale text → fires `ESC_PII_LEAKAGE_RISK` (BLOCKING per catalogue §2.5 lines 148-154; halts immediately, not warn-only output-shape)
agents/recruitment/sourcing-scout/agent.md:262:- PII leakage → `ESC_PII_LEAKAGE_RISK` (blocking; operator + ifos_oncall)
agents/recruitment/sourcing-scout/agent.md:263:- Output-shape failures (count not in 5-15, contact-method missing, rationale <50 words, voice classifier miss, all-source-failure-without-degradation) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)
agents/recruitment/sourcing-scout/agent.md:266:**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/sourcing-scout/agent.md:270:Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
agents/recruitment/sourcing-scout/agent.md:272:Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply (v1.0). Aggregate over rolling 30-day window per tenant. NOTE: Bullhorn-note feedback is NOT a v1.0 path (Sourcing Scout is read-only on Bullhorn per §1 + §6 contracts; would require write capability not in v1.0 scope).
agents/recruitment/sourcing-scout/agent.md:274:Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing) — operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
agents/recruitment/sourcing-scout/agent.md:276:Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
agents/recruitment/sourcing-scout/agent.md:282:Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/sourcing-scout/agent.md:287:| `ESC_LINKEDIN_AUTH` | LinkedIn / Proxycurl session/OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:288:| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:289:| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:291:| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:293:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:294:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:295:| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
agents/recruitment/sourcing-scout/agent.md:297:Sourcing Scout does NOT use:
agents/recruitment/sourcing-scout/agent.md:301:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
agents/recruitment/sourcing-scout/agent.md:302:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/sourcing-scout/agent.md:303:- `ESC_DNC_FILTER_HIT` — per catalogue §2.10 reserved for outbound send refusal specifically; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish backlog: add ESC_SOURCING_DNC_FILTER.
agents/recruitment/sourcing-scout/agent.md:311:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:316:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:317:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
agents/recruitment/sourcing-scout/agent.md:323:## §8 — Build dependencies (W9 prerequisites)
agents/recruitment/sourcing-scout/agent.md:325:Sourcing Scout build cannot start until ALL of the following are confirmed:
agents/recruitment/sourcing-scout/agent.md:338:| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:339:| Reed MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:340:| CV-Library MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:341:| Source-abstraction layer (Night Sourcer reuse) | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:343:| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
agents/recruitment/sourcing-scout/agent.md:345:| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:346:| `context.sh` hydration | Build at W9 start (~0.5 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:347:| `cycle.sh` orchestration (11-step) | Build at W9 start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:348:| 3 fixtures with golden outputs | Build at W9 start (~1 day) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:350:**Pre-W9-build prerequisites (must resolve to ✅ before W9 starts):** all items listed up to and including "Tenant DNC list populated", "Voice corpus seeded", and "Per-tenant source credentials in _secrets.env" — these are FOUNDER/TENANT-ADMIN actions that the W9 build cannot deliver itself. The four sibling-bundle items below (validate.sh, context.sh, cycle.sh, fixtures) ARE the W9 build slice itself — those are deliverables not prerequisites. Their completion is the W9-build-end Status-flip criterion (Proposed → Accepted), not the W9-build-start gate.
agents/recruitment/sourcing-scout/agent.md:356:**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:364:| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
agents/recruitment/sourcing-scout/agent.md:365:| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
agents/recruitment/sourcing-scout/agent.md:366:| Q5 | Gate B 6-of-10 metric — measured via consultant feedback (Brain UI v1.0 doesn't have feedback UX yet) | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful" → `decision_log` row via `consultant_feedback` green-tier action_type. v1.1: Brain UI button. NOTE: Bullhorn-note-based feedback is NOT a v1.0 path — Sourcing Scout is read-only on Bullhorn (no write capability); Bullhorn note creation would require tools.yaml write capability + autosend/decision logging which v1.0 explicitly excludes. |
agents/recruitment/sourcing-scout/agent.md:367:| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
agents/recruitment/sourcing-scout/agent.md:368:| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `date_last_modified_at < now() - 90 days` (per schema line 100) to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side modification-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |
agents/recruitment/sourcing-scout/agent.md:370:### Gotchas (carried forward from ULTRAPLAN A5 line 555)
agents/recruitment/sourcing-scout/agent.md:373:2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
agents/recruitment/sourcing-scout/agent.md:384:1. **Proposed → Ratified-as-Scaffold** when Codex review-agent-bundle returns RATIFIED on this agent.md alone. Pre-build scaffold confirmed shape-correct; the document is a binding contract for the W9 build slice.
agents/recruitment/sourcing-scout/agent.md:387:   - W9 build slice produces all 5 sibling bundle files (`tools.yaml`, `context.sh`, `validate.sh`, `cycle.sh`, `cleanup.sh`) + 3 fixtures with golden outputs
agents/recruitment/sourcing-scout/agent.md:396:   - First production render against a pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
agents/recruitment/sourcing-scout/agent.md:398:Until W9 build: this document is a forward-looking scaffold.
agents/recruitment/sourcing-scout/agent.md:400:*End of Sourcing Scout agent.md draft.*
agents/recruitment/janitor/README.md:14:Full agent bundle per ADR-003: 6 files + 3 fixtures. Built at W5 start (~2 weeks per ULTRAPLAN A2 line 512):
agents/recruitment/janitor/agent.md:3:**Status:** Pre-Build-Round-12-Bilateral-Applied (Day-20; W4 bilateral pass closed all 4 R11 residuals: 3 closed by post-R11 commit `e5a2c74` (Gate A ESC routing per-condition split, recent_edit.resolution citation, v0.3 supplement §2a authority); Finding 4 closed today by adding `janitor_dedup_threshold` + `janitor_last_run` declarations to v0.3 supplement §4 tenant_adapters_config_additions + agent.md citations updated. v0.3 supplement edit is additive — re-ratification queued. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice).
agents/recruitment/janitor/agent.md:6:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:42:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold` — declared in `vertical-schema.v0.3-supplement.yaml §4 tenant_adapters_config_additions.janitor_dedup_threshold`; enforced by `migrations/v0.2-to-v0.3.sql §5` validator allowlist)
agents/recruitment/janitor/agent.md:95:     tenant_adapters.config.janitor_last_run — declared in vertical-schema
agents/recruitment/janitor/agent.md:96:     v0.3 supplement §4 tenant_adapters_config_additions.janitor_last_run;
agents/recruitment/janitor/agent.md:169:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:171:   → exit code 0 (or 1 if Gate-B missed for 3 consecutive runs → ESC_GATE_B_MISS)
agents/recruitment/janitor/agent.md:191:- PII detected outside firm boundary → `ESC_PII_LEAKAGE_RISK` (blocking; operator + ifos_oncall per catalogue routing)
agents/recruitment/janitor/agent.md:194:- Output-shape failures (section count, write-batch size, dedup confidence below threshold for action) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)
agents/recruitment/janitor/agent.md:206:Failing either threshold for 3 consecutive runs → fire `ESC_GATE_B_MISS` → flag for operator review (heuristic tuning may be needed; not a kill).
agents/recruitment/janitor/agent.md:220:| `ESC_PII_LEAKAGE_RISK` | PII detected in tacit-note outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/janitor/agent.md:221:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (section count or per-section citation missing in day-30 report) | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:223:| `ESC_GATE_B_MISS` | Per catalogue §2.10 trigger: per-agent local Gate B metric threshold missed for the per-agent window. For Janitor: dedup-improvement <15% OR field-completeness-improvement <10% (two independent thresholds; missing EITHER triggers; per §5 Gate B). Catalogue routing: operator_chat_id | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:231:- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction
agents/recruitment/janitor/agent.md:239:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/janitor/agent.md:243:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
agents/recruitment/janitor/agent.md:244:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:284:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/janitor/agent.md:310:- First production run against migration-test tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
agents/recruitment/diagnostic/cleanup.sh:9:# Per ADR-003 v2 bundle pattern: cleanup.sh runs after cycle.sh succeeds
agents/recruitment/diagnostic/cleanup.sh:57:    '{"escalation_code":"ESC_PII_LEAKAGE_RISK","reason":"LinkedIn cache purge incomplete"}' \
packages/utilities/web-scraper/pnpm-lock.yaml:190:    resolution: {integrity: sha512-RVyzfb3FWsGA55n6WY0MEIEPURL1FcbhFE6BffZEMEekfCzCIMtB5yyDcFnVbTnwk+CLAgTujmV/Lgvih56W+A==}
packages/utilities/web-scraper/pnpm-lock.yaml:196:    resolution: {integrity: sha512-bPb5AHZtbeNGjCKVZ9UGqGwo8EUu4cLq68E95A53KlxAPRmUyYv2D6F0uUI65XisGOL1hBP5mTronbgo+0bFcA==}
packages/utilities/web-scraper/pnpm-lock.yaml:364:    resolution: {integrity: sha512-nU1yhmYutL+fQ71Kxnhg8uEOdC0pwEW9entHykTgEbna2pw2dkbFSMeqjjyHZoCmt8SBkOSvV+yNmm94aUrrqw==}
packages/utilities/web-scraper/pnpm-lock.yaml:533:    resolution: {integrity: sha512-J3Yh9PzzF1Ovah2At+lHiGQdsYgArxBbXv/zHfSyaiFQEqvNv7DcW98pCrmdjCZBrqBiKrKKe2V+aaSGWuBe/w==}
packages/utilities/web-scraper/pnpm-lock.yaml:557:    resolution: {integrity: sha512-nbJnQ8a3z1mtmrwImCYhc6BGpThAyYVRQxw9uKSKG4wR6aAYno9sVjJ0zaZcW9BPJX1GbrDPf+SvdWjgTuDmnw==}
packages/utilities/web-scraper/pnpm-lock.yaml:587:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:593:    resolution: {integrity: sha512-Boiz5+MsaROEWDf+GGEwF8VMHGhlUoQMtIPjOgA5fv4osupqTVnJteQNKJwUcnUog2G55jYXH7KZFFiJe0TEzQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:638:    resolution: {integrity: sha512-GhdPgy1el4/ImP05X05Uw4cw2/M93BCUmnEvWZNStlCzEKME4Fkk+YpoA5OiHNQmoS7Cafb8Xa3Pya8m1Qrzeg==}
packages/utilities/web-scraper/pnpm-lock.yaml:793:  mlly@1.8.2:
packages/utilities/web-scraper/pnpm-lock.yaml:825:    resolution: {integrity: sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==}
packages/utilities/web-scraper/pnpm-lock.yaml:1535:      mlly: 1.8.2
packages/utilities/web-scraper/pnpm-lock.yaml:1555:  mlly@1.8.2:
packages/utilities/web-scraper/pnpm-lock.yaml:1589:      mlly: 1.8.2
packages/harness/cortextos/tests/e2e/mock-codex.js:41:const WS_GUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
agents/recruitment/diagnostic/cycle.sh:12:# Per ADR-003 + sequencing-target.md §2.1: Diagnostic is Tier 2 (request-
agents/recruitment/diagnostic/cycle.sh:163:    '{"escalation_code":"ESC_AGENT_OUTPUT_SHAPE","agent_name":"diagnostic","shape_rule_violated":"non_empty_output","expected_value":"non-empty stdout","actual_value":"empty"}' >/dev/null
agents/recruitment/diagnostic/cycle.sh:181:# Step 13 — Atomic vault write (per ADR-003 §3.3.4 atomic-write protocol)
agents/recruitment/diagnostic/README.md:14:Per master brief §3.1 boundary 1 + ADR-003 (agent bundle v2 pattern), a full agent bundle is 6 files + 3 fixtures:
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:23:| 7 | **Master-brief-drift-accumulation** — eight ADR-driven edits + one Day-4 Postgres-rename + multiple Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all nine edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Codex ratifies the commit alongside the ten+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 + `bullhorn-integration-path.md` + `sequencing-target.md` + `brain-ui-scope.md` + Day 4 runbook §0.1. **Updated Day 4 (2026-05-17):** edit count rose from 8 to 9 with Day-4 Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations" — verified from Day-4 execution against NBG1 because FSN1 was unavailable at provisioning time). **Citation audit 2026-05-18:** earlier drafts also cited master brief §10.4 as a Hetzner/cost-target section; verified §10.4 is the Codex exclusion list ("What never goes through ratification") and contains no Hetzner or cost-target content. Edit 9 scope corrected to line 477 only. |
docs/RISK-REGISTER.md:46:- Two-instance PATH conflict for bus commands → **Updated 2026-05-16 evening:** folds into the renderer's CLAUDE.md preamble responsibility (ADR-003 design §2.1-A). The preamble draft in design §2.3 sets `CTX_AGENT_DIR` explicitly; rendered hook scripts source `_shared/` helpers via `${CTX_AGENT_DIR}/.claude/hooks/_shared/` rather than relying on `PATH` resolution. Quirk 3 is no longer a Week-1 risk — it's a renderer test case.
docs/RISK-REGISTER.md:59:- 2026-05-16 (Day 1 evening extension) — Risk #5 severity revised from **Blocking** to **High** (ADR-003 + design doc Accepted; staged reductions to Medium and Low named). Risk #7 edit count revised from 3 to 5 (ADR-003 Edit C added). Day-0 quirk 3 (PATH conflict) updated: no longer a Week-1 risk — folds into renderer preamble responsibility per ADR-003 design §2.3. No new risks surfaced from renderer design work.
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:65:- 2026-05-20 (Day 9 evening) — **Architecture + tenancy verification slice complete.** 3 commits (`5c3fa66` + `c4348aa` + this commit). 4 new artefacts: tenancy-invariants.md (Reference; 12 invariants T1-T12 single source of truth), run-tenancy-audit.sh (multi-tenant adversarial smoke), architecture-cohesion-review.md (8-artefact cohesion + 14 remediation items + 4-boundary adversarial walk), tenant-lifecycle.md (Provision/Operate/Suspend/Offboard/Migrate). All 4 master-brief §3 boundaries verified HOLD at current artefact set. 3 of 5 contradictions in the ratified artefact set RESOLVED via ADR-004 + Day-8 remediation; 1 RESOLVED via consolidation in tenancy-invariants.md; 1 OPEN pending Founder Decision D3 (PII retention). 8 implicit assumptions documented; 3 catastrophic-if-false verified empirically. No new risks added — cohesion review's 14 remediation items + lifecycle's 8 gaps are all variance bounded by existing risks (#5 renderer + #10 PII + others) or low-severity lazy specs. Foundation deemed sound for Diagnostic build conditional on founder-decision bundle (D1+D2+D3) + Codex Round 2 closure + live tenancy audit pass.
docs/RISK-REGISTER.md:66:- 2026-05-20 (Day 8 evening) — **Codex ratification Round 1 complete + remediation landed.** 16 artefacts reviewed (Cluster A+B+C); 2 RATIFIED (ADR-004, brain-ui-scope); 14 REJECTED. Remediation commit `2b287d3` incorporates 13 of 14 rejections (Bucket 1 cosmetic + Bucket 2 ADR-004 back-propagation + Bucket 3 structural). 2 disagreement docs filed (`codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` + `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`). 5 founder decisions surfaced (D1-D5 in `2026-05-20-codex-round-1-founder-decisions.md`). **NEW Risk #10 candidate surfaced by Codex** (recent_edit raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation) — see Risk #10 below. Manifest queue updated with per-artefact Round-1 verdicts (`docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5). Round 2 expected to take 14 REJECTED → 0-2 REJECTED.
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
packages/agent-renderer/src/renderer.ts:172:    // (ADR-003 §3.3.3 Option γ specifies "../../_shared" which is incorrect:
packages/agent-renderer/src/renderer.ts:174:    // for ADR-004 ratification.)
agents/recruitment/diagnostic/validate.sh:235:  #   - PII detected outside firm boundary → ESC_PII_LEAKAGE_RISK (blocking)
agents/recruitment/diagnostic/validate.sh:239:  #     length) → ESC_AGENT_OUTPUT_SHAPE (warn)
agents/recruitment/diagnostic/validate.sh:254:    ESC_CODE="ESC_PII_LEAKAGE_RISK"
agents/recruitment/diagnostic/validate.sh:258:    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:739:            &middot; <a href="#">ESC_BRIEF_AMBIGUITY</a> raised to <a href="#">Sarah Whittaker</a>
agents/recruitment/diagnostic/context.sh:12:# Postgres + vault. Per ADR-003: context.sh is the second of six bundle
agents/recruitment/diagnostic/context.sh:48:# ${CTX_AGENT_DIR}/.claude/hooks/_shared/ (symlink per ADR-003). For
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
packages/agent-renderer/src/fileMap.ts:5:    { source: "agent.md", target: "CLAUDE.md", action: "synthesis", note: "agent.md body + preamble + tenant footer per ADR-003 §2.1 row 1" },
packages/agent-renderer/src/fileMap.ts:6:    { source: "config.schema.json", target: "config.json", action: "synthesis", note: "Schema + _config.yaml + common-*.json $refs per ADR-003 §2.1 row 2" },
packages/agent-renderer/src/fileMap.ts:7:    { source: null, target: ".env", action: "synthesis", note: "Synthesised from _secrets.env + tools.yaml MCP list per ADR-003 §2.1 row 3" },
packages/agent-renderer/src/fileMap.ts:14:    { source: null, target: null, action: "drop", note: ".claude/skills/ 24-skill tree (R2 commitment per ADR-003 Decision 1)" },
packages/agent-renderer/src/fileMap.ts:16:    { source: null, target: ".claude/hooks/_shared", action: "passthrough", note: "Symlink → ../../_shared/ resolved at runtime per ADR-003 §3.3.3 Option γ" },
agents/recruitment/diagnostic/agent.md:6:**Build wave:** v1.0 W3-4 per master brief §8.2 line 595 (row 1; anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`. **Drift flag:** Ultraplan §8.1 A1 (line 489) calls Diagnostic build wave 4-5; master brief line 595 calls it W3-4. Master brief is authoritative per CLAUDE.md (master brief wins on every conflict); W3-4 is the build wave for IFOS.
agents/recruitment/diagnostic/agent.md:107:     payload {escalation_code: ESC_AGENT_OUTPUT_SHAPE, ...}; exit 1
agents/recruitment/diagnostic/agent.md:118:     with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE for
agents/recruitment/diagnostic/agent.md:120:     voice-classifier-score-low failures; ESC_PII_LEAKAGE_RISK for PII
agents/recruitment/diagnostic/agent.md:154:- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
agents/recruitment/diagnostic/agent.md:156:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
agents/recruitment/diagnostic/agent.md:157:- No PII (emails) outside the firm boundary. **v0 behavior:** validate.sh runs a generic email-regex pass and warns on any email found (no firm-domain whitelist implemented in v0; warn-only; exit 0). W4 polish adds the firm-domain whitelist + hard-fail behavior + `ESC_PII_LEAKAGE_RISK` emission. **v0 PII coverage:** emails only via regex; phone-number PII detection + whitelist enforcement deferred to W4 polish.
agents/recruitment/diagnostic/agent.md:161:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.
agents/recruitment/diagnostic/agent.md:174:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall | v0: emails-only regex; warn + exit 0 when firm-domain whitelist absent. W4-planned: phone-number PII detection + hard-fail when whitelist absent. |
agents/recruitment/diagnostic/agent.md:175:| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn upstream 429 | warn | operator_chat_id | **v0: NOT implemented in `cycle.sh` (generator throws-and-exits on upstream errors; validate.sh catches downstream as `ESC_AGENT_OUTPUT_SHAPE`). W4-planned: 429 catch + retry-with-backoff in `cycle.sh` + explicit `ESC_RATE_LIMIT_HIT` emission.** |
agents/recruitment/diagnostic/agent.md:177:| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing OR generator produced empty stdout (Step 8 fallback) | warn | operator_chat_id | v0: implemented as specified. |
agents/recruitment/diagnostic/agent.md:183:- `ESC_AUTOSEND_*` — Diagnostic's actions are `diagnostic_report_render` + `operator_notify_telegram` + `consultant_feedback` (all green tier per autosend-policy.yaml)
agents/recruitment/diagnostic/agent.md:192:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:196:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
agents/recruitment/diagnostic/agent.md:197:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
agents/recruitment/diagnostic/agent.md:260:- First production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:24:- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/tenancy-invariants.md:103:- **Enforcement:** Provisioning script (`scripts/provision-tenant.sh`, currently scattered in Day-4 §6.5) creates dirs with `chmod 700`. Renderer (`packages/agent-renderer/src/renderer.ts`) never writes symlinks into vault. The only symlink IFOS creates is at `${frameworkRoot}/orgs/<tenant>/agents/<agent>/.claude/hooks/_shared → ../../../_shared/` (Decision 2 of ADR-004) — that's the org-agents dir, NOT vault.
docs/architecture/tenancy-invariants.md:104:- **Documentation source:** Day-4 §6.5 + ADR-003 §3.3.3 + ADR-004 Decision 2.
docs/architecture/tenancy-invariants.md:118:- **Documentation source:** ADR-003 §3.3.3 Option γ + ADR-004 Decision 2 + ADR-004 Decision 3.
docs/architecture/tenancy-invariants.md:132:- **Documentation source:** ADR-003 §2.1 row 3 + renderer source `packages/agent-renderer/src/renderer.ts` line ~150 (writeFileTracked call).
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
docs/architecture/tenancy-invariants.md:186:- **Documentation source:** ADR-003 §3.3.3 Option γ + `agents/_shared/README.md` §"Live mode vs fallback mode".
docs/architecture/tenancy-invariants.md:208:| T7 | Partial → Verified | ADR-003 §3.3.3 design + tenancy audit | ADR-003 + ADR-004 design; pending Day-9 functional test | Cross-tenant render isolation |
docs/architecture/tenancy-invariants.md:235:- **Pre-render**: ADR-003 §3.3.3 Option γ + ADR-004 Decision 2 + Decision 3 enforce T6, T7, T8 at render time.
packages/agent-renderer/src/synthesis/envFile.ts:62:    `# Generated by IFOS agent renderer (packages/agent-renderer/) per ADR-003 §2.1 row 3.`,
agents/recruitment/concierge/agent.md:6:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:129:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:155:   → ESC_AGENT_OUTPUT_SHAPE if critical Bullhorn context fields missing
agents/recruitment/concierge/agent.md:158:     NOTE: ESC_CANDIDATE_DATA_INCOMPLETE is reserved for Sourcing Scout
agents/recruitment/concierge/agent.md:161:     "candidate:<bullhorn_id>", "fields_present:<N>")
agents/recruitment/concierge/agent.md:169:   → hh_decision_output("addressee_resolved", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:184:   → hh_decision_output("escalation_position_set", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:194:     "candidate:<bullhorn_id>:<event_type>", "vault_path:<path>; voice_score:<N>; words:<N>")
agents/recruitment/concierge/agent.md:220:    → ESC_PII_LEAKAGE_RISK on hit (blocking)
agents/recruitment/concierge/agent.md:221:    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:232:      "candidate:<bullhorn_id>:<event_type>", payload_hash,
agents/recruitment/concierge/agent.md:239:      "candidate:<bullhorn_id>", payload_hash, payload_preview)
agents/recruitment/concierge/agent.md:248:      "candidate:<bullhorn_id>", "event_type:<type>")
agents/recruitment/concierge/agent.md:254:    → hh_decision_action("concierge_send_complete", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:261:    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
agents/recruitment/concierge/agent.md:277:- No PII outside firm boundary — hard-fail (ESC_PII_LEAKAGE_RISK)
agents/recruitment/concierge/agent.md:279:- All Bullhorn context fields present (no missing candidate name / no missing email) — hard-fail (ESC_AGENT_OUTPUT_SHAPE; ESC_CANDIDATE_DATA_INCOMPLETE is Sourcing Scout's per catalogue §2.10)
agents/recruitment/concierge/agent.md:283:Gate A failures fire `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` or `ESC_PII_LEAKAGE_RISK` or `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint — missing Bullhorn context OR voice threshold misses persistently) — all blocking; draft to `/tmp`; operator notified immediately.
agents/recruitment/concierge/agent.md:295:Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
agents/recruitment/concierge/agent.md:310:| (Concierge does NOT use `ESC_CANDIDATE_DATA_INCOMPLETE` — per catalogue §2.10 that code is reserved for Sourcing Scout shortlist completeness. Concierge's missing-Bullhorn-context case fires `ESC_AGENT_OUTPUT_SHAPE` per Gate A discipline below.) | — | — |
agents/recruitment/concierge/agent.md:314:| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:318:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:319:| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% for 30 consecutive days | warn | founder + operator |
agents/recruitment/concierge/agent.md:327:- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
agents/recruitment/concierge/agent.md:337:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
agents/recruitment/concierge/agent.md:344:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:345:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
agents/recruitment/concierge/agent.md:400:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
packages/agent-renderer/src/cli.ts:67:  .description("Render an IFOS agent bundle into a cortextOS-shaped per-tenant agent directory (ADR-003).")
docs/architecture/architecture-cohesion-review.md:32:| **Foundation** | ADR-001 (bus poll), ADR-002 (parallel brain), cortexos-primitive-status.md (audit), second-brain-design.md (vault/Postgres split) |
docs/architecture/architecture-cohesion-review.md:33:| **Build pipeline** | ADR-003 (agent renderer), agent-bundle-renderer-design.md (12-row file map) |
docs/architecture/architecture-cohesion-review.md:35:| **Implementation deviations** | ADR-004 (3 implementation deviations from ADR-003 corrected post-implementation) |
docs/architecture/architecture-cohesion-review.md:41:3. ADR-002 (ratifies parallel-brain decision)
docs/architecture/architecture-cohesion-review.md:45:7. ADR-003 (ratifies renderer design)
docs/architecture/architecture-cohesion-review.md:46:8. ADR-004 (3 implementation deviations from ADR-003 found during Phase 2-3 build)
docs/architecture/architecture-cohesion-review.md:59:| ADR-002 | brain replacement details | second-brain-design.md | ✓ second-brain-design §2.4 covers vault/Postgres split |
docs/architecture/architecture-cohesion-review.md:60:| ADR-002 | `_shared/` helpers contract | "Week 1 work" §"For Week 1 work" → vault-concurrency.md + hook-helpers.sh | ✓ landed Phase 1 + 3 commits |
docs/architecture/architecture-cohesion-review.md:61:| ADR-003 | renderer mechanism details | agent-bundle-renderer-design.md | ✓ design doc §3 covers all 12-row file map |
docs/architecture/architecture-cohesion-review.md:62:| ADR-003 | spec gap §2.1-A (preamble) | `packages/agent-renderer/templates/claude-md-preamble.md` | ✓ landed Phase 1 (a279226) |
docs/architecture/architecture-cohesion-review.md:63:| ADR-003 | spec gap §2.1-B (common schemas) | `packages/agents-runtime/_shared/common-*.json` | ✓ landed Phase 1 (a279226), 8 files |
docs/architecture/architecture-cohesion-review.md:64:| ADR-003 | spec gap §2.1-C (_secrets.env) | Day-4 §6.5 provisioning + renderer envFile.ts | ✓ landed Day-4 + Phase 2 |
docs/architecture/architecture-cohesion-review.md:65:| ADR-003 | renderer code | packages/agent-renderer/ | ✓ landed Phase 2 (3c16d35) |
docs/architecture/architecture-cohesion-review.md:66:| ADR-003 | `_shared/` Option γ | `agents/_shared/` + renderer copy logic | ✓ landed Phase 3 (e6e9df1) + renderer symlink |
docs/architecture/architecture-cohesion-review.md:67:| ADR-003 | failure modes / ESC catalogue | `agents/_shared/escalation-codes.md` | ✓ landed Phase 1 (a279226), 24 codes |
docs/architecture/architecture-cohesion-review.md:68:| ADR-003 | phase enum for renderer | Day-4 §6.3 CHECK constraint | **✓ landed but with deviation per ADR-004 Decision 7** — phase='render' NOT in enum; uses agent_name='_renderer' + existing phase |
docs/architecture/architecture-cohesion-review.md:69:| ADR-004 | CLI naming | `packages/agent-renderer/package.json` `bin` | ✓ landed Phase 2 |
docs/architecture/architecture-cohesion-review.md:70:| ADR-004 | symlink target | renderer.ts symlinkSync call | ✓ landed Phase 3 fix (e6e9df1) |
docs/architecture/architecture-cohesion-review.md:71:| ADR-004 | phase enum pattern | `agents/_shared/hook-helpers.sh::hh_decision_action` | ✓ landed Phase 3 |
docs/architecture/architecture-cohesion-review.md:92:| A5 | **The cortextOS daemon `discoverAgents()` filters by directory pattern, not contents.** Means `.tmp.<pid>/` + `.prev.<ts>/` dirs are invisible. | ADR-003 §3.3.4 atomic-write protocol | If daemon scan ever changes to content-based discovery, the atomic-write protocol could expose half-rendered state. Verified against pinned SHA `c21fbfe`. |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:109:- **Resolution:** ADR-004 Decision 7 (Codex Round 1 RATIFIED) + Day-8-evening remediation `2b287d3` corrected both renderer-design + ADR-003 to use `agent_name='_renderer'` + existing `phase=gating_failed|action`. **RESOLVED.**
docs/architecture/architecture-cohesion-review.md:113:- **ADR-003 §3.3.1 + agent-bundle-renderer-design.md** said `cortextos-ifos render-agent` (sub-command of upstream)
docs/architecture/architecture-cohesion-review.md:115:- **Resolution:** ADR-004 Decision 1 (RATIFIED) + Day-8-evening remediation corrected both to `ifos-render-agent` standalone binary. **RESOLVED.**
docs/architecture/architecture-cohesion-review.md:119:- **ADR-003 §3.3.3 Option γ** said `../../_shared` (2 levels up)
docs/architecture/architecture-cohesion-review.md:121:- **Resolution:** ADR-004 Decision 2 (RATIFIED) + Day-8-evening renderer.ts fix corrected to `../../../_shared` (3 levels up). **RESOLVED.**
docs/architecture/architecture-cohesion-review.md:137:**Summary: 3 of 5 contradictions RESOLVED (C1, C2, C3 via ADR-004 + Day-8-evening remediation). 1 RESOLVED via consolidation (C5). 1 OPEN (C4) pending founder decision D3.**
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:150:| G4 | **The agent runtime's `validate.sh` invocation contract is implicit.** ADR-003 §2.1 row 5 says it's a verbatim copy to `.claude/hooks/validate.sh`. But what does the runtime DO with it? Is it called before every tool use? Once per session? | Medium (every agent uses validate.sh) | Diagnostic W3 build's agent.md preamble names the invocation; pattern propagates. Add to tenant-lifecycle runbook. |
docs/architecture/architecture-cohesion-review.md:215:  - **A:** R2 commitment (ADR-003 Decision 1): tools.yaml can opt-in to cortextOS skills via `cortextos_skills:` block. If an agent opts in to `knowledge-base`, it gets the upstream KB. **This is the seam.** Currently no agent opts in. Recommend: add `review-agent-bundle.md` skill check to flag any `knowledge-base` opt-in for explicit founder review.
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
packages/agent-renderer/src/preflight.ts:54:      `Target directory exists without ${RENDERED_MARKER} marker. Likely created by 'cortextos-ifos add-agent'. Use --force-overwrite-non-rendered to override (ADR-003 Decision 1).`,
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:61:### Issue 4 (NEW) — `_consultant_feedback` sentinel undocumented
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:63:**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:69:Option A — **Add `_consultant_feedback` to the sentinel catalogue.** New entry in `agents/_shared/escalation-codes.md` documenting purpose, payload shape, and emit cadence.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:71:Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:79:**Disposition:** **Codex is correct about the skill requirement**, but the artefact type is wrong. `agent.md` files are NOT architecture-decision documents — they're agent specifications per ADR-003 v2 bundle pattern (6 files + 3 fixtures). They don't fit the Context/Decision/Consequences shape.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:122:| Sourcing Scout | ~5-7 (count regex 50) | `logs/codex-ratification/20260524T1024...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:130:4. **Sentinel agent_name usage** — _consultant_feedback (Diagnostic) is the clear case; other agents likely have similar invented sentinels. Disposition: prefer `agent_name='<agent>'` with `payload.action_type` markers; reserve sentinels for system actors (_renderer, _tenant_admin, _codex_ratifier).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:216:3. `ESC_GATE_B_MISS` definition in §6 still says "Composite Gate-B score <12.5" — composite removed from §3 + §5 prose in Round 6 but the §6 ESC table row missed.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:259:- Cat-4 (sentinel hygiene): Diagnostic `_consultant_feedback` → agent_name='diagnostic' + payload.action_type
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:276:| Sourcing Scout | 4 | `20260524T113139Z-84869` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:284:- Sourcing Scout ULTRAPLAN A5 line refs: Gate A 553→552, Gate B 554→553 (4 citation sites)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:318:  - Sourcing Scout per-candidate decision rows (claimed in §3 but not in §4 cycle)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:333:- Sourcing Scout: pre-build-scaffold; Round-8-reviewed; minimal residual (catalogue-widening + per-candidate decision rows)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:363:- `validate.sh` emits specific §6 ESC codes (ESC_PII_LEAKAGE_RISK or ESC_AGENT_OUTPUT_SHAPE) not generic ESC_SCHEMA_VIOLATION
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:374:| Sourcing Scout | 4 | 5 | +1 (Q7 enum claim missed by my Round-8 fix; Bullhorn webhook conflict newly surfaced) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:389:**Sourcing Scout R9:**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:391:2. ESC auth severity downgrade vs catalogue — Codex–founder disagreement (Sourcing Scout intentionally allows single-source auth failure as warn-only when 2+ sources remain; catalogue defines blocking. Real semantic divergence; needs catalogue widening OR Sourcing Scout agent.md realignment)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:419:4. **Catalogue v2 widening for ESC_DNC_FILTER_HIT + Sourcing Scout auth severity** — Cat-γ continuations
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:430:| Sourcing Scout | Pre-Build-Round-9-Reviewed | 5 (Cat-α Q7 + bullhorn-path conflict + Cat-γ DNC + Cat-ε per-candidate row + auth severity disagreement) | Mechanical Q7 fix + Bullhorn-path realignment + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/architecture/agent-bundle-renderer-design.md:4:**Status:** Reference. Recommendations become binding via ADR-003 (Accepted) + ADR-004 (errata on CLI name + symlink target).
docs/architecture/agent-bundle-renderer-design.md:5:**Surfaced by:** `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §"For Week 1 work" — declared the renderer the load-bearing Week-1 prerequisite.
docs/architecture/agent-bundle-renderer-design.md:9:**Reading order:** ADR-002 first, then this design, then ADR-003.
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:119:| _(no IFOS source — cortextOS templates ship 24 skills)_ | `.claude/skills/{activity-channel, agent-browser, ..., worker-agents}` (24 dirs) | **Drop** | n/a | n/a — the R2 commitment per design §1.7 + ADR-002 Decision 1. Detailed itemisation in §2.2 below |
docs/architecture/agent-bundle-renderer-design.md:133:- **ADR-002 Decision 1** — cortextOS KB stays untouched; IFOS agents don't call `kb-*`. Inheriting `knowledge-base` and `memory` skills would mean IFOS agents have on-disk documentation telling them to invoke commands that, per ADR-002, they must not invoke.
docs/architecture/agent-bundle-renderer-design.md:135:- **Master brief §3.1 (submodule boundary stays intact)** — the §3.1 exception for the four `bus/kb-*.sh` shadow points is already a dead clause per ADR-002. Inheriting cortextOS skills would introduce a new implicit "shadow" — IFOS agents would carry skill documentation that points back into cortextOS's surface — undoing the cleanliness ADR-002 established.
docs/architecture/agent-bundle-renderer-design.md:141:| `knowledge-base` | Calls `kb-query` / `kb-ingest` / `kb-collections` / `kb-setup` against cortextOS's mmrag/ChromaDB KB | IFOS uses `wiki-*` parallel bus wrappers against `/vault/{tenant}/wiki/` + Postgres `entities` / `entity_links` per ADR-002 Decision 2 and design §2.3 / §2.4 |
docs/architecture/agent-bundle-renderer-design.md:144:| `tasks` | cortextOS task management — `create-task` / `update-task` / `complete-task` against the `orgs/{org}/tasks/` directory | IFOS uses Postgres `decision_log` for the "what did this agent do" trail and the wiki for the "what's the state of this entity" view. The cortextOS task store is unused by IFOS agents (parallel to the KB-untouched decision per ADR-002 Decision 1) |
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:220:  - ESC_PII_LEAKAGE_RISK
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:298:Note: `wiki-*` bus operations are NOT declared in `tools.yaml` per ADR-002 Decision 2 — they're internal bus commands. `cortextos_skills:` is empty per the R2 default (§2.2).
docs/architecture/agent-bundle-renderer-design.md:322:hh_load_tone_rules
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:332:After `ifos-render-agent render concierge --tenant acme` (CLI name per ADR-004 Decision 1):
docs/architecture/agent-bundle-renderer-design.md:392:PII is a `ESC_PII_LEAKAGE_RISK` escalation. Voice samples and tone rules in
docs/architecture/agent-bundle-renderer-design.md:465:Rationale: matches existing IFOS package convention. Master brief §4.1 line 195-204 enumerates the operative package directories (`packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}/`); the renderer is a distinct concern (bundle → runtime translation) that doesn't belong inside any of those. It's not the brain (wiki content, per ADR-002), not the harness (read-only submodule per master brief §3.1), not agents-runtime/_shared/ (the shared helper *content*, not the *tooling* that materialises agents). Standalone `packages/agent-renderer/` keeps the surface clean.
docs/architecture/agent-bundle-renderer-design.md:475:- `packages/brain/agent-cli/` — extending the brain CLI; rejected because the brain CLI is wiki ops (per ADR-002 Decision 2), and bundle rendering is not a wiki concern. Coupling two distinct CLIs into one package raises lock-in cost.
docs/architecture/agent-bundle-renderer-design.md:503:(CLI name per ADR-004 Decision 1; earlier drafts of this design named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1. The corrected standalone `ifos-render-agent` Node binary ships from `packages/agent-renderer/package.json` `bin`.)
docs/architecture/agent-bundle-renderer-design.md:638:**Escalation:** `ESC_RENDERER_FAILED` row written to `decision_log` Postgres table with `agent_name='_renderer'`, `phase='gating_failed'`, `payload->>'reason'='schema-validation-failure'`. (`phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — see ADR-004 Decision 7; the 5-value enum is `trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 schema migration.) If `--notify-on-failure` (default true), Telegram message to the operator with the validation path.
docs/architecture/agent-bundle-renderer-design.md:646:**Recovery:** stderr lists missing paths. Founder scaffolds the missing helpers (Week-1 prerequisite per ADR-002). Re-runs.
docs/architecture/agent-bundle-renderer-design.md:708:- **Audit log:** Postgres `decision_log` row with `tenant_slug`, `agent_name='_renderer'`, `phase='gating_failed'` (failures) or `phase='action'` (successful renders), `payload->>'reason'` carries the reason code. RLS-isolated per tenant. Codex's Day-7 ratification report queries this table for all rows where `agent_name='_renderer' AND payload->>'reason' LIKE 'ESC_RENDERER_FAILED%'`. (Per ADR-004 Decision 7: `phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — use the 5-value enum from Day-4 §6.3 + Day-5 schema migration.)
docs/architecture/agent-bundle-renderer-design.md:718:The cortextOS `cortextos-ifos add-agent` command (`packages/harness/cortextos/src/cli/add-agent.ts:18-316`) is **unchanged**. IFOS does **not** use it for IFOS-owned agents. The R2 commitment per ADR-002 §1.7-A drives this.
docs/architecture/agent-bundle-renderer-design.md:752:Per `second-brain-design.md` §3.4 closing paragraph: "the renderer (ADR-003) must be live by start of week 11 so agents can actually be scaffolded against the wiki API."
docs/architecture/agent-bundle-renderer-design.md:758:| ADR-003 (this design ratified) | founder + Claude Code | **Week 1** |
docs/architecture/agent-bundle-renderer-design.md:759:| Renderer implementation under `packages/agent-renderer/` | Claude Code | **Weeks 1-2** (after ADR-003 lands) |
docs/architecture/agent-bundle-renderer-design.md:760:| `packages/agents-runtime/_shared/{voice-loader,hook-helpers}.sh` (per ADR-002 prerequisite) | Claude Code | Weeks 1-2 |
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/agent-bundle-renderer-design.md:771:Three edits flagged. The first two land in their own ADR-003 commit alongside the design and ADR-003 (this batch's session-close commit); the third joins the atomic correction commit that ADR-001 + ADR-002 already queue.
docs/architecture/agent-bundle-renderer-design.md:783:Plus a one-line footnote: "`agent-renderer/` — the IFOS Agent Bundle v2 → cortextOS-shaped per-agent directory renderer, per `docs/decisions/ADR-003-agent-bundle-renderer.md` and `docs/architecture/agent-bundle-renderer-design.md`."
docs/architecture/agent-bundle-renderer-design.md:798:(CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent`.)
docs/architecture/agent-bundle-renderer-design.md:804:**Proposed:** add a one-paragraph footnote at the end of §8 (before §8.1): "The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly. The renderer (`packages/agent-renderer/`, per ADR-003) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant)."
docs/architecture/agent-bundle-renderer-design.md:806:Edit A and Edit B land in this batch's commit alongside ADR-003. Edit C joins the atomic correction commit (it's a substantive wording change, parallel to ADR-002 Edit 1 and Edit 2; ratified together by Codex on Day 7).
docs/architecture/agent-bundle-renderer-design.md:830:- `_secrets.env` added to `provision-tenant.sh` skeleton — Day 4 of Week 0 (alongside the Postgres `entity_graph` rename per ADR-002 Edit 3).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:43:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:121:- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
docs/architecture/cortexos-kb-surface-investigation.md:6:**Surfaced by:** ADR-002 (in-progress, since superseded by the reframe — see "Why this document exists" below).
docs/architecture/cortexos-kb-surface-investigation.md:14:Drafting ADR-002 began with the plan to read all four real files and pick one of three outcomes (full shadow / mixed shadow + new wrappers / abandon shadow). After reading **only `kb-setup.sh`**, the substrate of cortextOS's KB became clear, and that substrate is incompatible with the IFOS wiki data model in master brief §5. The ADR's scope is too narrow to absorb that finding — it would be designing the second brain inside an architectural decision record, on the side of an audit.
docs/architecture/cortexos-kb-surface-investigation.md:109:3. **Claude writes `ADR-002` against the design.** The decision is binding; the design is the evidence.
packages/agent-renderer/templates/claude-md-preamble.md:58:- Cross-tenant PII is an `ESC_PII_LEAKAGE_RISK` escalation per `_shared/escalation-codes.md`.
packages/agent-renderer/templates/claude-md-preamble.md:69:This file was generated by the IFOS agent-bundle renderer (`packages/agent-renderer/`, ADR-003). Hand-edits will be lost on next `cortextos-ifos render-agent {{agent_name}} --tenant {{tenant_slug}}` invocation. Source bundle: `agents/recruitment/{{agent_name}}/`. Re-render after editing the source bundle.
packages/agent-renderer/templates/claude-md-preamble.md:71:Marker file present at `{{agent_dir_abs}}/.rendered-by-ifos-renderer`. Do not delete; the renderer's pre-flight check (ADR-003 Decision 1) refuses to overwrite directories missing this marker.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
packages/agent-renderer/package.json:5:  "description": "IFOS Agent Bundle v2 → cortextOS-shaped agent renderer per ADR-003.",
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:182:1. **No `chokidar` watcher in the bus.** The bus is poll-based, not push-based. `grep -rn chokidar src/` returns zero hits; `chokidar@^5.0.0` in `package.json:47` is used only by `dashboard/src/lib/watcher.ts:5` for the dashboard UI's file change feed, not for inter-agent message delivery. Master brief §2.4 row 3's "chokidar watcher in daemon" is incorrect against the verified SHA. The actual dispatcher is `FastChecker` polling at `pollInterval` (default 1000ms, configurable). Operational impact: message-delivery latency is bounded by the poll interval, not zero-latency event-driven; relevant for the Brief Decoder → Sourcing Scout → Concierge "four-agent pipelines complete in seconds" claim (Ultraplan §3.2). With 1s polling per hop and 3 hops, end-to-end is ≥3s, not sub-second.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
packages/harness/cortextos/dashboard/package.json:42:    "@playwright/test": "^1.58.2",
packages/agent-renderer/README.md:3:Translates IFOS Agent Bundle v2 (`agents/<vertical>/<name>/`) into a cortextOS-shaped per-tenant agent directory (`${frameworkRoot}/orgs/<org>/agents/<name>/`). Implements [ADR-003](../../docs/decisions/ADR-003-agent-bundle-renderer.md) and the 12-row file mapping at [`docs/architecture/agent-bundle-renderer-design.md` §2.1](../../docs/architecture/agent-bundle-renderer-design.md).
packages/agent-renderer/README.md:7:**Phase 2 scaffold (v0.1.0).** Phases 3-5 (helpers + voice schema + voice-loader) follow per `~/.claude/plans/bubbly-snuggling-lantern.md`. First production render: Diagnostic agent at Week 4 per master brief §8.2.
packages/agent-renderer/README.md:66:## CLI name divergence from ADR-003
packages/agent-renderer/README.md:68:ADR-003 §3.3.1 specifies `cortextos-ifos render-agent`. The upstream `cortextos-ifos` binary lives in the read-only submodule per master brief §3.1 boundary, so we can't add a subcommand there. Phase 2 ships the renderer as standalone `ifos-render-agent` (Node binary; `bin` field in package.json). The `.envrc` `alias ifosctl="cortextos-ifos"` is unchanged; a separate wrapper for `ifosctl render-agent <args>` is **not** in Phase 2 scope.
packages/agent-renderer/README.md:70:**Action item:** ADR-004 (Phase 2 follow-up) will ratify either (a) keeping `ifos-render-agent` as a standalone surface or (b) building an `ifosctl` shim that multiplexes. Founder + Codex review at first ratification round.
packages/agent-renderer/README.md:85:| `.claude/skills/` (24-skill tree) | — | Drop (R2 commitment per ADR-003 Decision 1) |
packages/agent-renderer/README.md:87:| (none) | `.claude/hooks/_shared → ../../_shared` | Symlink (Option γ per ADR-003 §3.3.3) |
packages/agent-renderer/README.md:91:## Atomicity (ADR-003 §3.3.4)
packages/agent-renderer/README.md:100:## Failure modes (ADR-003 §4)
packages/agent-renderer/README.md:117:- **`_shared/` copy-not-symlink staleness.** Renderer COPIES `agents/_shared/` to `${frameworkRoot}/orgs/<org>/agents/_shared/` per ADR-003 §3.3.3 Option γ — does NOT symlink. Mid-pilot edits to `agents/_shared/{voice-loader,hook-helpers}.sh` require re-running `render-agent` for each tenant. v1.0 acceptable (single-tenant pilot); v1.1 may add SHA-based skip-if-unchanged optimisation.
packages/agent-renderer/README.md:124:Hand-edits to the rendered output are **lost on next render** (Decision 4: overwrite-no-merge per ADR-003 §3.4). Edit the bundle, then re-render. Decision-log row written with `agent_name='_renderer'` + `phase='render'` per ADR-003 §4 audit policy (Phase 3 wires this via `hook-helpers.sh`).
packages/agent-renderer/README.md:162:- ADR-003 — Agent bundle v2 renderer (ratified)
docs/decisions/brain-ui-scope.md:6:**Surfaced by:** Master brief §6 Day 3 line 472 — "Brain UI v1.0 scope decision" + ADR-002 §3.4 closing paragraph (Brain UI explicitly forward-deferred to v1.1) + `second-brain-design.md` §3.4 ("Brain UI minimal v1 is built as a thin read-only page over `decision_log` — no new wiki API needed").
docs/decisions/brain-ui-scope.md:9:**Reading order:** master brief §5.5 (Brain UI build sequence stages) + ADR-002 (parallel-not-shadow + v1.0 brain build wording correction) + `second-brain-design.md` §3.4 closing paragraph (Brain UI v1.0+ scope) first; then this document end-to-end.
docs/decisions/brain-ui-scope.md:15:Per master brief §5.5 (lines 416-424) after ADR-002 Edit 2 applies in the atomic correction commit, the staged Brain UI build is:
docs/decisions/brain-ui-scope.md:34:Three features named in master brief §5.5 (post-ADR-002-Edit-2 wording) + `second-brain-design.md` §3.4. Each feature scoped here without implementation commitment.
docs/decisions/brain-ui-scope.md:44:- Per-tenant scoped via RLS per ADR-002 §3 Decision 3; multi-tenant founder view aggregates across tenant_slugs.
docs/decisions/brain-ui-scope.md:55:**Dependency on v1.0:** wiki API live + `decision_log` populated per ADR-002 §3 Decision 3 + extended phase enum per `sequencing-target.md` §6.5.
docs/decisions/brain-ui-scope.md:62:- Implements the `wiki-links.sh` backlinks read API per ADR-003 §"Decision 3" + design §2.1 — v1.1 release of the wrapper.
docs/decisions/brain-ui-scope.md:72:**Likely implementation surface:** Next.js route at `/brain/entity/<id>` with backlinks pane. Reads Postgres `entity_links` table per `second-brain-design.md` §2.4.2 schema. Reuses `wiki-links.sh` API (v1.1 wrapper per ADR-003).
docs/decisions/brain-ui-scope.md:80:- Graphical query builder for `wiki-find.sh` search-by-attribute API (v1.1 wrapper per ADR-003 §"Decision 3" + design §2.3 row 4).
docs/decisions/brain-ui-scope.md:92:**Dependency on v1.0:** `wiki-find.sh` shipped in v1.1 itself (the wrapper isn't a v1.0 deliverable per ADR-003 §"Decision 3" wrapper table); `decision_log` + `entities` populated in v1.0.
docs/decisions/brain-ui-scope.md:134:No UI work. Wiki API + Postgres + pgvector + filesystem is the v1.0 deliverable per ADR-002 Edit 2 + `second-brain-design.md` §3.4 closing paragraph. Master brief §5.5 already correctly scopes this (post-Edit-2). No new constraint from this document.
docs/decisions/brain-ui-scope.md:141:- **`wiki-*.sh` CLI** per ADR-003 §"Decision 3" wrapper table — programmatic queries for ad-hoc lookups.
docs/decisions/brain-ui-scope.md:176:> "- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation."
docs/decisions/brain-ui-scope.md:181:2. **`kb-*` shadow language** → `wiki-*` parallel system (corrects against ADR-002 Edit 1 §3.4 brain-replacement seam wording).
docs/decisions/brain-ui-scope.md:182:3. **`/brain` today-view as v1.0 deliverable** → today-view is v1.1 (corrects against ADR-002 Edit 2 §5.5 v1.0 brain build wording).
docs/decisions/brain-ui-scope.md:188:3. ADR-002 Edit 1 §3.4: shadow → parallel
docs/decisions/brain-ui-scope.md:189:4. ADR-002 Edit 2 §5.5: v1.0 brain build wording
docs/decisions/brain-ui-scope.md:190:5. ADR-003 Edit C §8: renderer footnote
docs/architecture/vault-concurrency.md:3:**Status:** Reference (no Proposed/Accepted lifecycle). Synthesis of `docs/architecture/second-brain-design.md` §2.6 + `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` Decisions 2-3 + `docs/decisions/sequencing-target.md` §5-A `decision_log.phase` extension.
docs/architecture/vault-concurrency.md:6:**Surfaced by:** `ADR-002` §"For Week 1 work" + `second-brain-design.md` Spec gap 2.6 + `sequencing-target.md` §6.5 (Day-4 Postgres provisioning consolidation).
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:21:- **Wiki library** (`packages/brain/wiki/lib/*.ts` per ADR-002 Decision 2) — the read/write API every agent invokes; serialises and coordinates the above.
docs/architecture/vault-concurrency.md:36:- Cross-tenant read consistency — RLS handles this at the Postgres layer per ADR-002 Decision 3; not a wiki-library concern.
docs/architecture/vault-concurrency.md:265:**Substrate:** discover all entities that reference the target via `entity_links` table per `second-brain-design.md` §2.4.2; iterate in deadlock-safe order; apply the rewrite under per-entity flock per §2; update `entity_links` rows in a single Postgres transaction per ADR-002 Decision 3.
docs/architecture/vault-concurrency.md:429:**None from this document.** The concurrency design was already authorised by `ADR-002` Decisions 2-3 + `second-brain-design.md` §2.6. This document is reference / specification, not a new decision — it does not surface fresh master-brief drifts.
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:159:Target: candidate:s.bowen
docs/decisions/autosend-approval-bridge-spec.md:243:| A5 | Bridge crash + restart: state rebuilds from filesystem scan + Postgres state table | Restart test: kill PM2 process mid-flight, restart, verify pending approvals resume |
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
packages/harness/cortextos/src/utils/ws-unix-client.ts:80:      .update(key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')
docs/architecture/second-brain-design.md:4:**Status:** Reference. Q3 recommendation non-binding; ADR-002 ratifies it.
docs/architecture/second-brain-design.md:5:**Surfaced by:** `docs/architecture/cortexos-kb-surface-investigation.md` — the cortextOS KB substrate is incompatible with the IFOS wiki data model, and the gap is large enough that the second brain needs its own design before ADR-002 can land.
docs/architecture/second-brain-design.md:8:**Reading order:** the investigation doc first, then this. Then ADR-002.
docs/architecture/second-brain-design.md:78:The exception in §3.1 becomes a dead clause: there are four `bus/kb-*.sh` files but we don't shadow them. The §3.4 wording needs to change to reflect this (ADR-002 will specify the replacement wording).
docs/architecture/second-brain-design.md:144:**Week-1 prerequisite, flagged for future sessions:** the renderer is a missing first-class artefact in the Week 1 plan. Without it, you cannot run an IFOS agent — the daemon's `AgentManager.discoverAndStart()` will not find a v2 bundle at `${repo}/agents/recruitment/<name>/` because it reads from `${projectRoot}/orgs/<org>/agents/<name>/`. The renderer's full design needs its own dedicated artefact (likely ADR-003 or `docs/architecture/agent-bundle-renderer-design.md`) before any v1.0 agent code can ship.
docs/architecture/second-brain-design.md:198:| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:205:| `wiki/raw/briefs/` | one file per brief intake | markdown with frontmatter | `{epoch}-{brief-id}.md` | Brief Decoder (v1.1) on inbound | Sourcing Scout (v1.0 reads only candidate-relevant); Brief Decoder (v1.1) |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:211:| `wiki/compiled/briefs/{slug}.md` | one per Brief | same | same | Brief Decoder (v1.1); manual at v1.0 if needed | Sourcing Scout (v1.0 reads only); Brief Decoder (v1.1) |
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:237:| Brief | **v1.0 (skeleton) / v1.1 (full)** | Sourcing Scout (v1.0 A5) needs to *read* a Brief to source against; Brief Decoder (v1.1 A8) is the producer. v1.0 writes minimal Briefs (manual entry or direct Bullhorn sync via Janitor); full lifecycle waits for v1.1 |
docs/architecture/second-brain-design.md:319:v1.0 skeleton: only what Sourcing Scout (A5) needs to source against — role title, client, sector, must-haves. Full v1.1 schema waits for Brief Decoder.
docs/architecture/second-brain-design.md:429:| `list-by-type-and-tenant` | Sourcing Scout (v1.0): enumerate Candidates for filtering; Brief Decoder (v1.1): enumerate open Briefs | v1.0 (Candidate, Client, Placement, Contact); v1.1 (Brief full enumeration) | `(entity_type: str, tenant_id: str, filters?: dict, limit?: int)` | `List[EntityRef]` | few seconds | Postgres-indexed; filtering matches `search-by-attribute` |
docs/architecture/second-brain-design.md:430:| `semantic-search-over-raw` | future Pulse (v1.2): "any inbox emails mentioning compliance risk in last 30 days" | **v1.2+ deferred** | `(query: str, raw_collection: str, tenant_id: str, date_range?: tuple)` | `List[RawChunkRef]` ranked by similarity | few seconds | The only operation where cortextOS's mmrag/ChromaDB substrate is a plausible candidate. v1.0/v1.1 don't need it — flagged in Q3 as the one place ADR-002 should leave a forward-compatible hook |
docs/architecture/second-brain-design.md:442:**The `semantic-search-over-raw` row is the bridge to ADR-002.** Q3 will recommend whether to use cortextOS's mmrag/ChromaDB for this future operation (which would require shadowing exactly the `bus/kb-ingest.sh` + `bus/kb-query.sh` pair against `raw/` content), or build an IFOS-native pgvector index over raw/ — both are tenable, both are v1.2+ work, neither needs a decision before Week 11.
docs/architecture/second-brain-design.md:600:1. **Forward-compatibility with semantic-search-over-raw (v1.2+).** If the eventual Pulse-like agent uses cortextOS's mmrag/ChromaDB for raw/ content, IFOS-side and cortextOS-side embeddings live in the same vector space and a query embedded once can search both indexes. ADR-002 will recommend keeping this hook open.
docs/architecture/second-brain-design.md:615:**v1.2+ forward-compatibility hook:** the semantic-search-over-raw operation (v1.2+) is the one place where cortextOS's substrate could come back into the picture. ADR-002 will recommend leaving the option open — i.e. don't dismantle cortextOS's KB tooling — without scoping the v1.2 work now.
docs/architecture/second-brain-design.md:654:        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
docs/architecture/second-brain-design.md:680:| `semantic-search-over-raw` | **v1.2+ deferred** — placeholder primary = either cortextOS mmrag/ChromaDB **OR** IFOS-native pgvector over chunked raw/ content | n/a | ADR-002 will recommend keeping cortextOS's substrate available as the v1.2+ implementation option without committing to it now. |
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:774:| Sourcing Scout | 50:1 | reads briefs + candidate pool to filter; writes only shortlists |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:890:| **Multi-tenancy enforcement** — how `tenant_slug` is validated at the entry point (master brief §3.5) | Wrapper reads `CTX_TENANT_SLUG` env var (set by PM2 ecosystem per-tenant process group); CLI handler validates that the arg `--tenant` matches the env or fails with `ESC_PII_LEAKAGE_RISK`. Kernel-enforced isolation underneath (POSIX 0700 per Ultraplan §5.1) means a wrong tenant fails at filesystem read. | Server receives `CTX_TENANT_SLUG` at connection setup via MCP server args; rejects any tool call whose `tenant_slug` mismatches the connection identity. Filesystem isolation underneath same as α. One enforcement site. | Library validates `tenant_slug` against env var. Same enforcement model as α, but agent-side discipline depends on skill docs being followed. |
docs/architecture/second-brain-design.md:922:- **v1.2+ semantic-search-over-raw:** ADR-002 will recommend keeping this hook open. Under Option α, the eventual implementation is a `wiki-semantic-search.sh` that internally chooses either cortextOS's mmrag (the v1.2+ option) or an IFOS-native pgvector-over-raw index — no agent-side change.
docs/architecture/second-brain-design.md:942:- **Week 11:** Postgres migrations + RLS tests; library scaffolding; `wiki/lib/{ingest,update,search,list}.ts`; one happy-path fixture per op. **Renderer (ADR-003) must be live by start of week 11** so agents can actually be scaffolded against the wiki API.
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:948:1. **Renderer design (ADR-003, Spec gap §1.7).** Without it, no IFOS agent can run. **Week 1.**
docs/architecture/second-brain-design.md:950:3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
docs/architecture/second-brain-design.md:966:| **§1.7-A** | Master brief §8 silent on renderer | No mechanism for translating the IFOS Agent Bundle v2 layout (`${repo}/agents/recruitment/<name>/`) into the cortextOS-shaped per-agent directory the daemon reads from (`${projectRoot}/orgs/<org>/agents/<name>/`) | ADR-003 in Week 1 + companion `docs/architecture/agent-bundle-renderer-design.md`. Adopt R2 (bundle-only, no `.claude/skills/` tree). | **Yes** — without it, no IFOS agent can run. Week 1 prerequisite. |
docs/architecture/second-brain-design.md:976:| **3.4-A** | Master brief §5.5 (lines 416-420) v1.0 brain wording | Says "shadow four files" — incorrect per Q1.5 | Rewrite per §3.4 of this design: "9 `wiki-*.sh` parallel wrappers + Postgres entities/entity_links/decision_log + pgvector voice." Bundles with ADR-002 atomic correction commit. | No — wording change, not work change. |
docs/architecture/second-brain-design.md:977:| **3.4-B** | Master brief §6 Day 4 (line 478) Postgres table list | Lists `entity_graph` as a single table | Update wording: "`tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`." Bundles with Day 4 provisioning. | **Tight** — Day 4 of Week 0 (this week). |
docs/architecture/second-brain-design.md:979:**Five gaps are already resolved inline in this design** (2.1-B, 2.1-C, 2.2-A, 2.2-B, 2.6 with mechanisms in §2.6.x). **Three need master-brief / Ultraplan edits in the atomic correction commit** (2.1-A wording reconciliation, 2.4-B / 3.4-B Postgres table-rename, 3.4-A v1.0 brain wording rewrite). **Two are Week-1 prerequisite artefacts** (§1.7-A renderer ADR-003 + `agent-bundle-renderer-design.md`; 2.6 companion `vault-concurrency.md`). **Two are operational defaults** that the founder can either ratify or override at any later point (2.4-A git init at provisioning; 2.4-C `gemini-embedding-001` model choice).
docs/architecture/second-brain-design.md:983:**Master brief §5.5's v1.0 minimum brain build stays at weeks 11-13, but the scope is materially clarified.** The "shadow four files + 2 .ts files" framing is replaced by "9 wiki-*.sh parallel wrappers + 9 wiki/lib/*.ts modules + 4 Postgres tables with RLS + pgvector for voice samples." Total v1.0 effort: ~11-13 person-days, fitting the 15-day budget. **Three Week-1 prerequisites move into focus:** ADR-003 renderer design (without it, no IFOS agent can run), `vault-concurrency.md` companion document (without it, the `flock`+Postgres-optimistic-concurrency code can't be reviewed), and `agents/_shared/{voice-loader,hook-helpers}.sh` (without these, the wiki library has no calling conventions). **One Day-4 (this week) tightening:** the Postgres schema migration from `entity_graph` (single table) to `entities` + `entity_links` (two tables) is part of the master brief §6 Day 4 infra task, not deferred. v1.2 graph view and v2.0 LoRA scale-tier are forward-compatible under the chosen Option α with no architectural changes.
docs/decisions/2026-05-18-codex-ratification-manifest.md:18:| 3 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | Accepted | Verify Option α reasoning + Edits 1+2+3 all applied (3, 4, 12 in atomic-correction manifest) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:19:| 4 | `docs/architecture/second-brain-design.md` | Reference (ADR-002 binding) | Cross-check against ADR-002 ratification |
docs/decisions/2026-05-18-codex-ratification-manifest.md:20:| 5 | `docs/architecture/agent-bundle-renderer-design.md` | Reference (ADR-003 binding) | Cross-check 22 spec gaps + 4 buckets against ADR-003 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:21:| 6 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | Accepted | Verify 4 decisions + Edits A+B+C applied (5 in atomic-correction; A+B landed Day 1 evening) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:51:**Cross-cutting reference:** these 4 artefacts ratify the layered defence model documented across Day-4 §7 (RLS isolation gate) + ADR-002 (parallel brain) + ADR-003 (renderer) + ADR-004 (deviations). They are downstream of, not redundant with, the existing 21+ queue items.
docs/decisions/2026-05-18-codex-ratification-manifest.md:62:| 2 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | RATIFIED | Incorporated remediation verified clean. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:63:| 3 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | RATIFIED | Incorporated remediation verified clean. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:172:| 3 | ADR-002 | REJECTED (2 issues) | Issue 1 (status drift) + Issue 2 (master-brief-edit disposition) both **incorporated** at `2b287d3` — disposition now cites commit `0e5b2b4`. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:175:| 6 | ADR-003 | REJECTED (2 issues) | Issue 1 (status drift) + Issue 2 (CLI surface drift) both **incorporated** at `2b287d3` with inline ADR-004 erratum reference. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:177:| 8 | sequencing-target.md | REJECTED (2 issues) | Issue 1 (status drift) **incorporated** at `2b287d3`. Issue 2 (phase enum cite) implicitly addressed via ADR-004 Decision 7 cross-reference. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:192:**Plus Round-1 ADR-004** (item not in original 21-queue but added Day 8): **RATIFIED**.
docs/decisions/2026-05-18-codex-ratification-manifest.md:194:**Round-1 totals:** 16 reviewed | **2 RATIFIED** (ADR-004 + brain-ui-scope) | **14 REJECTED** | **13 of 14 incorporated** at commit `2b287d3` | **2 disagreement docs filed** | **5 founder decisions surfaced** (D1-D5).
docs/decisions/2026-05-18-codex-ratification-manifest.md:266:| 3 | §3.4 shadow → parallel (full rewrite) | ADR-002 Edit 1 line 81 | ✓ verbatim |
docs/decisions/2026-05-18-codex-ratification-manifest.md:267:| 4 | §5.5 v1.0 minimum row + v1.0+/v1.1 row merge | ADR-002 Edit 2 line 91 | ✓ verbatim (with side effect documented) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:268:| 5 | §8 renderer footnote (before §8.1) | ADR-003 Edit C | ✓ verbatim |
docs/decisions/2026-05-18-codex-ratification-manifest.md:275:| 12 | §6 Day 4 line 478 table list (entity_graph split) | ADR-002 Edit 3 | ✓ verbatim |
docs/decisions/ADR-004-renderer-implementation-deviations.md:1:# ADR-004 — Renderer implementation deviations from ADR-003
docs/decisions/ADR-004-renderer-implementation-deviations.md:6:**Submodule SHA:** `c21fbfe991a0030ea055bd8e2389a0801a424383` (unchanged from ADR-003)
docs/decisions/ADR-004-renderer-implementation-deviations.md:7:**Predecessor:** [ADR-003 — Agent bundle v2 renderer](./ADR-003-agent-bundle-renderer.md) (Accepted)
docs/decisions/ADR-004-renderer-implementation-deviations.md:14:ADR-003 ratified the renderer design on 2026-05-16 (Day 1 evening). Phase 2 of the Week-1 product-code slice (commit `3c16d35`) implemented the renderer per ADR-003 §3.1 — TypeScript Node, `tsup` + `vitest` + `commander`, 12-row file map, atomic-write protocol. Phase 3 (commit `e6e9df1`) implemented `agents/_shared/hook-helpers.sh` and triggered an end-to-end integration test against the rendered output.
docs/decisions/ADR-004-renderer-implementation-deviations.md:18:The three deviations are individually small. The reason this ADR exists rather than three inline `errata` notes in ADR-003 is master brief §10.5 ("Always-ratify list"): renderer architectural decisions go through Codex review, and a single coherent ADR is the audit-trail-friendly path. Reading ADR-003 + ADR-004 together gives the full ratified renderer surface.
docs/decisions/ADR-004-renderer-implementation-deviations.md:26:**ADR-003 §3.3.1 specified the CLI signature:** `cortextos-ifos render-agent <agent-name> --tenant <slug>`.
docs/decisions/ADR-004-renderer-implementation-deviations.md:28:**Implementation ships:** `ifos-render-agent <agent-name> --tenant <slug>` as a standalone Node binary declared in `packages/agent-renderer/package.json` `bin` field. Same arguments + flags as ADR-003 §3.3.1; different command name.
docs/decisions/ADR-004-renderer-implementation-deviations.md:40:- ADR-003 §3.3.1 needs an erratum or this ADR's ratification, depending on how Codex treats the divergence.
docs/decisions/ADR-004-renderer-implementation-deviations.md:46:**ADR-003 §3.3.3 Option γ specified verbatim:** *"per-agent `.claude/hooks/_shared` symlink resolves to `../../_shared` (relative)."*
docs/decisions/ADR-004-renderer-implementation-deviations.md:50:**Why the deviation:** counting error in ADR-003. Starting from the symlink file at `<agent_dir>/.claude/hooks/_shared`, the canonical `_shared/` directory at `<org>/agents/_shared/` is **3 levels up**, not 2:
docs/decisions/ADR-004-renderer-implementation-deviations.md:61:So the relative path from the symlink's containing directory is `../../../_shared`, NOT `../../_shared`. With the ADR-003 spec verbatim, the symlink resolves to `<agent_dir>/_shared/` (INSIDE the agent dir, where no `_shared` exists) and breaks at first source. This was caught during the Phase-3 end-to-end integration test when `source .claude/hooks/_shared/hook-helpers.sh` failed with `No such file or directory`.
docs/decisions/ADR-004-renderer-implementation-deviations.md:63:**No alternatives** — this is an off-by-one fix, not a design choice. The deviation is corrected in `packages/agent-renderer/src/renderer.ts` with an inline comment flagging the ADR-003 spec error.
docs/decisions/ADR-004-renderer-implementation-deviations.md:67:- ADR-003 §3.3.3 should be updated to say `../../../_shared` (4 segments including `_shared`).
docs/decisions/ADR-004-renderer-implementation-deviations.md:68:- ADR-003 §2.3 worked-Concierge-example output diagram says `_shared/` lives at `orgs/acme/agents/_shared/` — that's correct, the bug is only in the symlink-target text. Diagram is right; symlink string is wrong.
docs/decisions/ADR-004-renderer-implementation-deviations.md:72:**Observation:** `cortextos-ifos list-agents` (which calls into `packages/harness/cortextos/src/bus/agents.ts` `listAgents()`) scans `${frameworkRoot}/orgs/<org>/agents/*` and treats every immediate directory child as an agent. `_shared/` sits in that location per ADR-003 §3.3.3 Option γ. Result: `_shared` appears in the list-agents output as if it were an agent named `_shared` in org `<tenant>`, with no display name + no config + status `stopped`.
docs/decisions/ADR-004-renderer-implementation-deviations.md:74:**Decision:** **Accept as upstream limitation.** Do NOT modify the renderer to relocate `_shared/` outside the scanned directory. The placement matches ADR-003's design intent (one canonical `_shared/` per org reachable by all agents via relative symlink). Renderer correctness is unaffected — the daemon's own `discoverAndStart()` doesn't try to launch `_shared` because it has no `config.json`; PM2 + agent-manager skip it cleanly. Only the cosmetic `list-agents` output is affected.
docs/decisions/ADR-004-renderer-implementation-deviations.md:91:**Edit D — Master brief §8.3 working pattern line 121 (post-ADR-003 Edit B).**
docs/decisions/ADR-004-renderer-implementation-deviations.md:93:Current (post-ADR-003 Edit B at master brief §8.3 lines 614-630):
docs/decisions/ADR-004-renderer-implementation-deviations.md:114:Lands in this ADR's commit if approved; otherwise queued for the next atomic-correction commit alongside ADR-003 spec-text fixes.
docs/decisions/ADR-004-renderer-implementation-deviations.md:116:**Edit E — ADR-003 §3.3.3 symlink target string.**
docs/decisions/ADR-004-renderer-implementation-deviations.md:118:Current (ADR-003 §3.3.3 — Option γ paragraph):
docs/decisions/ADR-004-renderer-implementation-deviations.md:126:Lands in ADR-003 itself as an inline erratum (small text fix), OR as a §5 entry in this ADR titled "Errata to ADR-003." Founder decision at ratification time.
docs/decisions/ADR-004-renderer-implementation-deviations.md:128:**Edit F — ADR-003 §3.3.1 CLI signature.**
docs/decisions/ADR-004-renderer-implementation-deviations.md:130:Current (ADR-003 Decision 1 paragraph, internal text):
docs/decisions/ADR-004-renderer-implementation-deviations.md:136:> "invoked via `ifos-render-agent <agent-name> --tenant <slug>` (CLI signature per design §3.3.1 + ADR-004 Decision 1; standalone Node binary per `packages/agent-renderer/package.json` `bin`. The `cortextos-ifos render-agent` form named in earlier drafts requires modifying the read-only submodule and was rejected per master brief §3.1 boundary 1)."
docs/decisions/ADR-004-renderer-implementation-deviations.md:138:Lands in ADR-003 itself OR as §5 in this ADR per Edit E's pattern.
docs/decisions/ADR-004-renderer-implementation-deviations.md:144:**For Risk #5 (renderer-not-built).** Severity unchanged at High per ADR-003 line 145 staged ladder ("Drops to Medium once renderer code is committed AND the Diagnostic agent renders cleanly (Week 4)"). The Phase-2 commit `3c16d35` satisfies the first condition; the second condition (Diagnostic render) is gated on Q1 design-partner LOI. ADR-004 closes a stylistic gap (3 deviations) but does not change risk severity.
docs/decisions/ADR-004-renderer-implementation-deviations.md:146:**For Codex Day-7 ratification.** ADR-004 joins the queue. The 3 deviations were pre-flagged in Phase-2 and Phase-3 commit messages + `packages/agent-renderer/README.md`; this ADR consolidates them into a single ratifiable artefact. Without ADR-004, Codex would likely REJECT each deviation individually as "implementation diverges from ADR-003"; with ADR-004, the deviations are deliberately-ratified design decisions Codex either RATIFIES or REJECTS as a coherent set.
docs/decisions/ADR-004-renderer-implementation-deviations.md:150:**For future Diagnostic builds.** Decision 1 means agents/runbooks/onboarding-wizard documentation references `ifos-render-agent`, not `cortextos-ifos render-agent`. Cheap to update everywhere because no documentation has shipped yet — only ADR-003 + master brief §8.3 reference the old name, and both are addressed in §"Master brief edits authorised."
docs/decisions/ADR-004-renderer-implementation-deviations.md:160:- Land ADR-004 commit with the three §"Master brief edits authorised" applied verbatim
docs/decisions/ADR-004-renderer-implementation-deviations.md:161:- Land erratum on ADR-003 §3.3.3 (Edit E) + §3.3.1 internal text (Edit F) in the same commit OR in next atomic-correction commit
docs/decisions/ADR-004-renderer-implementation-deviations.md:173:*End of ADR-004.*
packages/harness/cortextos/dashboard/package-lock.json:39:        "@playwright/test": "^1.58.2",
packages/harness/cortextos/dashboard/package-lock.json:101:      "integrity": "sha512-wajfB8KqzMCN2KGNFdLkReeHncd0AslUSrvHVvvYWuU8ghncRJoA50kT3zP9MVL0+9g4/67H+cdvBskj9THPzg==",
packages/harness/cortextos/dashboard/package-lock.json:242:      "integrity": "sha512-dTOdvsjnG3xNT9Y0AUg1wAl38y+4Rl4sf9caSQZOXdNqVn+H+HbbJ4IyyHaIqNR6SW9oJpA/RuRjsjCw2IdIow==",
packages/harness/cortextos/dashboard/package-lock.json:590:      "integrity": "sha512-yQ+qeuqohwhsNpoYDqqXaLllYAkPCP4vYdDrVo8FQXaAPfHWm1pG/Vm+jmGTA5JFS0BAIjookyapuJFY8F9PIw==",
packages/harness/cortextos/dashboard/package-lock.json:953:      "integrity": "sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==",
packages/harness/cortextos/dashboard/package-lock.json:1359:      "integrity": "sha512-zqjjo7RatFfFoP0MkQ51jfuFZBnVE2pRiaydKJ1G/rHZvnsrHAOcQALIi9sA5co5xenQdTugCvtb1cuf78Vf4g==",
packages/harness/cortextos/dashboard/package-lock.json:1752:      "integrity": "sha512-+29YMsqY2/9eFEiW93eqWnuLcWcufowXewwSNIT6UwZdUUCrM3oFjMWH/Z6/TMmb4hlFenmfAVbpWeup2jryCw==",
packages/harness/cortextos/dashboard/package-lock.json:1911:        "express-rate-limit": "^8.2.1",
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
packages/harness/cortextos/dashboard/package-lock.json:4868:      "version": "4.28.2",
packages/harness/cortextos/dashboard/package-lock.json:4869:      "resolved": "https://registry.npmjs.org/browserslist/-/browserslist-4.28.2.tgz",
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
packages/harness/cortextos/dashboard/package-lock.json:9257:        "react": "^18.2.0 || 19.0.0-rc-de68d2f4-20241204 || ^19.0.0",
packages/harness/cortextos/dashboard/package-lock.json:9258:        "react-dom": "^18.2.0 || 19.0.0-rc-de68d2f4-20241204 || ^19.0.0",
packages/harness/cortextos/dashboard/package-lock.json:9289:        "react": "^18.2.0 || ^19.0.0"
packages/harness/cortextos/dashboard/package-lock.json:9681:      "version": "8.2.0",
packages/harness/cortextos/dashboard/package-lock.json:9682:      "resolved": "https://registry.npmjs.org/ora/-/ora-8.2.0.tgz",
packages/harness/cortextos/dashboard/package-lock.json:9909:      "integrity": "sha512-C8oWjPR3F81yljW9o5OxcWzfh6avkVwDD2VYdwIGqTkl+OGFISgypqzfu7dOe4QNLL2aqcWBmI3PMtLIK233lw==",
packages/harness/cortextos/dashboard/package-lock.json:10004:      "integrity": "sha512-Z2dPnBnMUfyQfSQ+GBdsGa16hz35YmLmtTLhM169uW944hYL6xzTYkJjC07j+Wosz733pMWx0fgON3JNw1jJQA==",
packages/harness/cortextos/dashboard/package-lock.json:10060:      "integrity": "sha512-gjVS5hOP+M3wMm5nmNOucbIrqudzs9v/57bWRHQWLYklXqoXKrVfYW2W9+glfGsqtPgpiz5WwyEEB+ksXIx3gQ==",
packages/harness/cortextos/dashboard/package-lock.json:10266:        "@types/react": "^18.2.25 || ^19",
packages/harness/cortextos/dashboard/package-lock.json:10770:      "integrity": "sha512-eNv+WrVbKu1f3vbYJT/xtiF5syA5HPIMtf9IgY/nKg0sWqzAUEvqY/xm7OcZc/qafLx/iO9FgOmeSAp4v5ti/Q==",
packages/harness/cortextos/dashboard/package-lock.json:10910:        "ora": "^8.2.0",
packages/harness/cortextos/dashboard/package-lock.json:11291:      "integrity": "sha512-tsaTIkKW9b4N+AEj+SVA+WhJzV7/zMhcSu78mLKWSk7cXMOSHsBKFWUs0fWwq8QyK3MgJBQRX6Gbi4kYbdvGkQ==",
packages/harness/cortextos/dashboard/package-lock.json:11427:      "integrity": "sha512-zaJYxz2FtcMb4f+g60KsRNFOpVMUyuJgA51Zi5Z1DOTC3S59+OQiVOzE9GZt0x72uBGWKsQIuBKeF9iusmKFsg==",
packages/harness/cortextos/dashboard/package-lock.json:11683:      "integrity": "sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==",
packages/harness/cortextos/dashboard/package-lock.json:11944:      "integrity": "sha512-3KS2b+kL7fsuk/eJZ7EQdnEmQoaho/r6KUef7hxvltNA5DR8NAUM+8wJMbJyZ4G9/7i3v5zPBIMN5aybAh2/Jg==",
packages/harness/cortextos/dashboard/package-lock.json:12172:      "integrity": "sha512-Fedw0aZvkhynoPYlA5WXrMCAMm+nSWdZt6lzJQ7Ok8S6Q+VsHmHpRWndVRJ8Be0ZbkfPc5LRYH+5XrzXcEeLRQ==",
packages/harness/cortextos/dashboard/package-lock.json:12342:      "integrity": "sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==",
packages/harness/cortextos/dashboard/package-lock.json:12437:      "integrity": "sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==",
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/operations/w4-bilateral-pass-6-agent-md.md:37:| 3 | Sourcing Scout | 3 | Lowest residual; one scope question (webhook auto-source). |
docs/operations/w4-bilateral-pass-6-agent-md.md:62:  - **Codex says:** "Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature."
docs/operations/w4-bilateral-pass-6-agent-md.md:86:  - **Codex says:** "Line 187 says `ESC_AGENT_OUTPUT_SHAPE` applies to 'ALL Gate A conditions,' including voice classifier, PII, and write-batch size. The catalogue defines `ESC_VOICE_DRIFT` for classifier failures and `ESC_PII_LEAKAGE_RISK` as blocking for PII leakage; downgrading PII to `ESC_AGENT_OUTPUT_SHAPE` weakens Gate A routing. Fix §5 so each Gate A condition maps to its catalogue code, reserving `ESC_AGENT_OUTPUT_SHAPE` for report/output-shape failures only."
docs/operations/w4-bilateral-pass-6-agent-md.md:104:  - **Codex says:** "Lines 42, 95, and 166 rely on `janitor_dedup_threshold` and `janitor_last_run`; `rg` finds these only in the v0.2-to-v0.3 migration allowlist, not in `vertical-schema.yaml` or the v0.3 supplement's `tenant_adapters_config_additions`. Fix by adding both keys with type/owner/read-write semantics to the schema supplement, then cite that schema section instead of only the migration allowlist."
docs/operations/w4-bilateral-pass-6-agent-md.md:105:  - **Likely:** **REJECT-CODEX** with rationale, OR small schema supplement edit. The migration allowlist IS the v0.3 supplement enforcement (per ADR-006 + the v0.3 trigger). But Codex's point is that they should also appear in the YAML schema definition (`tenant_adapters_config_additions`) for documentation completeness. Founder call: edit the YAML supplement to declare them explicitly, OR write disagreement claiming migration-allowlist is sufficient single-source-of-truth.
docs/operations/w4-bilateral-pass-6-agent-md.md:110:## 3. Sourcing Scout — `agents/recruitment/sourcing-scout/agent.md`
docs/operations/w4-bilateral-pass-6-agent-md.md:114:### Finding 1. False schema-status claim for `blocked_recipients`
docs/operations/w4-bilateral-pass-6-agent-md.md:116:  - **Codex says:** "It says 'the actual config-key SCHEMA registration is v0.4-supplement-pending' and that v0.3 only registers other keys, but `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` §5 allowlists `blocked_recipients` at line 397. Fix by removing the v0.4-pending claim for `blocked_recipients`; keep v0.4-pending only for `auto_source_on_brief_create`."
docs/operations/w4-bilateral-pass-6-agent-md.md:117:  - **Likely:** FIX-IN-PLACE. Remove v0.4-pending claim for `blocked_recipients`; keep it only for `auto_source_on_brief_create`. (Verify: v0.3 migration line 397 does include `blocked_recipients` in allowlist? Confirmed in our earlier read: "tier_overrides, blocked_recipients, janitor_dedup_threshold..." — yes.)
docs/operations/w4-bilateral-pass-6-agent-md.md:122:  - **Codex says:** "It flips to Accepted on ratification/founder questions/ADR-006 before the W9 bundle exists, but the agent-bundle skill treats Accepted as production-ready after sibling files + fixtures exist and pass gates. Fix by keeping this scaffold Proposed after ratification, and make Proposed → Accepted depend on W9 build completion: `tools.yaml`, `context.sh`, `validate.sh`, `cycle.sh`, `cleanup.sh`, and 3 fixtures."
docs/operations/w4-bilateral-pass-6-agent-md.md:123:  - **Likely:** FIX-IN-PLACE. Edit §10 to gate Accepted on W9 bundle completion (sibling files + fixtures + gate A). Ratified scaffold stays at "Proposed (Ratified at Round-N)" until W9.
docs/operations/w4-bilateral-pass-6-agent-md.md:127:  - **Cite:** §1 + §2; cross-ref `auto_source_on_brief_create` v0.4-pending
docs/operations/w4-bilateral-pass-6-agent-md.md:128:  - **Codex says:** "The output contract lists the webhook trigger as an active trigger, and §2 labels it 'Webhook (v1.0)', but §2 also says `auto_source_on_brief_create` is v0.4-supplement-pending and the code path is blocked. Fix by either moving webhook auto-source to deferred/v0.4+ surfaces, or add the v0.4 schema supplement as a hard §8 prerequisite and make the §1 contract explicitly conditional."
docs/operations/w4-bilateral-pass-6-agent-md.md:230:2. **Schema-citation hygiene** (Janitor #2, #3, #4; Sourcing Scout #1; Scribe #1) — v0.2/v0.3 supplement boundary is the single most-failed cross-reference. After this pass, recommend a CI grep that flags any `agent.md` field reference whose name doesn't appear in `vertical-schema.yaml` OR `vertical-schema.v0.3-supplement.yaml`.
docs/operations/w4-bilateral-pass-6-agent-md.md:236:5. **Status semantics** (Sourcing Scout #2) — confirm with founder: "Ratified at Round-N" is not "Accepted"; Accepted requires bundle completion. Likely a one-line clarification in the agent-bundle skill or master brief §8 to prevent this drift in future agents.
docs/operations/w4-day-20-founder-runbook.md:72:- ✓ `validate_tenant_adapters_config_v0_3` trigger present on `tenant_adapters`
docs/operations/w4-day-20-founder-runbook.md:87:The 11 tables: `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`, `cash_conductor_transactions`, `cash_conductor_invoices`.
docs/operations/w4-day-20-founder-runbook.md:110:3. Sourcing Scout (3 findings) — fewest residuals
packages/harness/cortextos/dashboard/public/file.svg:1:<svg fill="none" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><path d="M14.5 13.5V5.41a1 1 0 0 0-.3-.7L9.8.29A1 1 0 0 0 9.08 0H1.5v13.5A2.5 2.5 0 0 0 4 16h8a2.5 2.5 0 0 0 2.5-2.5m-1.5 0v-7H8v-5H3v12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1M9.5 5V2.12L12.38 5zM5.13 5h-.62v1.25h2.12V5zm-.62 3h7.12v1.25H4.5zm.62 3h-.62v1.25h7.12V11z" clip-rule="evenodd" fill="#666" fill-rule="evenodd"/></svg>
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:84:| Sourcing Scout | `linkedin_profile_cache` | Stores profile snapshot to `/vault/<tenant>/wiki/raw/`; no external send; no rate-limit cost |
docs/decisions/autosend-safety-policy.md:94:| Sourcing Scout | `linkedin_connection_request` | 1-in-5 | Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy |
docs/decisions/autosend-safety-policy.md:110:| Sourcing Scout | `linkedin_inmail_send` | Outbound InMail (paid credit); cost-per-send; customer-facing |
docs/decisions/autosend-safety-policy.md:123:| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
docs/decisions/autosend-safety-policy.md:124:| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:136:The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.
docs/decisions/autosend-safety-policy.md:144:#   $2 target        (entity reference, e.g., "candidate:john-smith")
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:209:The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
docs/decisions/autosend-safety-policy.md:229:Agents cannot invoke action_types not declared in their `tools.yaml`. Renderer validates this at render time per ADR-003 §4 (`ESC_RENDERER_FAILED` reason `bundle-malformed` if a declared action_type isn't in the policy).
docs/decisions/autosend-safety-policy.md:246:  "target": "<entity ref, e.g., 'candidate:john-smith'>",
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:273:Target: candidate:sarah-bowen
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:358:| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:427:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/decisions/autosend-safety-policy.md:437:    "blocked_recipients": [
docs/decisions/autosend-safety-policy.md:463:3. **`blocked_recipients`** is additive only. Recipients can be added; system-default red-list recipients cannot be removed. Pattern matching supported via `*` wildcards.
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:539:  (c) breaches of Tenant's configured blocked_recipients list by the
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:632:**For Week 1-2.** The `_shared/voice-loader.sh` + `hook-helpers.sh` Week-1 prerequisite (per ADR-002 §"For Week 1 work" + ADR-003 Decision 3) now has its `hh_decision_action` specification. Implementation work is well-defined: §4 pseudocode + §5 escalation payloads + §7 audit row schema.
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:658:- v1.0 implementation prerequisite: this policy + the Week-1 `_shared/` helpers + ADR-003 renderer + Day-4 Postgres schema (all four are present after this commit lands).
docs/operations/codex-ratification-guide.md:173:brief §2.4 row 3 line reference holds; ADR-002 Edit 1 reference holds. Five-rule
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:67:**Source:** `sequencing-target.md` §6.6 failure condition (i); Risk #5 in `docs/RISK-REGISTER.md`; ADR-003 §"Consequences" line 141 (renderer is load-bearing Week-1 deliverable).
docs/decisions/v1.0-kill-criterion.md:69:**Action:** KILL state. Rationale: the renderer architecture (ADR-003) was ratified in Week 0 Day 1 evening as the load-bearing Week-1 prerequisite. If Week 3 ends with no clean Diagnostic render, the renderer has fundamental gaps that the design did not anticipate. The renderer cannot be "patched"; v1.0 cannot ship without working render. Continuing into Weeks 4+ without resolution is sunk-cost reasoning.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:136:**Action:** PIVOT — likely vector: cheaper Claude model tier (Haiku 4.5 for routine actions, Sonnet for complex), or reduced agent run frequency (e.g., Sourcing Scout runs nightly batch instead of real-time), or per-tenant cost passthrough in pricing.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:336:- The renderer architecture per ADR-003
docs/operations/codex-round-2-handoff.md:73:| 2 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | status drift + edit disposition | RATIFY (status + Edits 1+2+3 cite `0e5b2b4`) |
docs/operations/codex-round-2-handoff.md:74:| 3 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | status drift + CLI surface drift | RATIFY (status + ADR-004 erratum + CLI updated) |
docs/operations/codex-round-2-handoff.md:164:- Round 1 ran 16 artefacts; 2 RATIFIED (ADR-004 + brain-ui-scope); 14 REJECTED
docs/operations/codex-round-2-handoff.md:207:  docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/operations/codex-round-2-handoff.md:208:  docs/decisions/ADR-003-agent-bundle-renderer.md
packages/agent-renderer/tests/unit/fileMap.test.ts:5:  it("returns 12 rows per ADR-003 Decision 3", () => {
packages/harness/cortextos/dashboard/src/components/charts/chart-theme.ts:19:  '#EA580C', // orange
docs/operations/codex-round-2-remediation-prompt.md:333:    per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:67:- **Scoped:** `docs/decisions/ADR-003-agent-bundle-renderer.md` Accepted Day 1 evening with full design spec at `docs/architecture/agent-bundle-renderer-design.md`. 12-row file-by-file translation contract ratified per ADR-003 Decision 3.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:68:- **Sequencing:** `docs/decisions/sequencing-target.md` §4.1 ratifies the 6-agent build order; renderer is Week 1-2 prerequisite for the Diagnostic W3-4 first render per ADR-003 §5.2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:69:- **Effort estimate <5 days:** ADR-003 §5.2 names 8 prerequisite items for renderer scaffolding. Initial implementation effort estimated at <5 person-days for the renderer's core translation path. Full Week 1-2 (~5-10 days) covers prerequisites + tests + first-tenant render validation.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:71:- **Risk #5 (renderer-not-built)** in `docs/RISK-REGISTER.md` reduced from Blocking → High on Day 1 evening when ADR-003 + design doc Accepted. Three-stage ladder to Medium (W4 first Diagnostic render) → Low (W13 all 5 v1.0 bundles rendered).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:93:| 4 | Agent Bundle v2 refactor scoped + <5 days? | **YES** | High — ADR-003 + sequencing-target + design doc all Accepted |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:117:6. **Renderer implementation per ADR-003** — ALLOWED in code repo but agent-build slices (Diagnostic et al.) DO NOT start until Q1 turns YES. Renderer can scaffold independently.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/ADR-003-agent-bundle-renderer.md:1:# ADR-003 — Agent Bundle v2 renderer
docs/decisions/ADR-003-agent-bundle-renderer.md:5:**Surfaced by:** `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §"For Week 1 work" + `docs/architecture/agent-bundle-renderer-design.md` (full design)
docs/decisions/ADR-003-agent-bundle-renderer.md:13:ADR-002 §1.7-A surfaced the spec gap. Master brief §8 (lines 545-568) specifies the IFOS Agent Bundle v2 — six files plus three fixtures at `agents/recruitment/<name>/` — but is silent on how the bundle becomes a runnable cortextOS agent. The cortextOS daemon's `AgentManager.discoverAndStart()` (`packages/harness/cortextos/src/daemon/agent-manager.ts:906-941` `discoverAgents()`) reads from `${frameworkRoot}/orgs/<org>/agents/<name>/` with a cortextOS-shaped layout (`config.json`, `CLAUDE.md`, `.env`). The two layouts are incompatible without translation.
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:23:Per design §5.1: the cortextOS `cortextos-ifos add-agent` command is **unchanged**. IFOS does not use it for IFOS-owned agents. The renderer is a **new** command at `packages/agent-renderer/`, invoked via `ifos-render-agent <agent-name> --tenant <slug>` (standalone Node binary per `package.json` `bin`; **errata via ADR-004 Decision 1** — earlier drafts named this `cortextos-ifos render-agent` which would have required modifying the read-only submodule per master brief §3.1 boundary 1).
docs/decisions/ADR-003-agent-bundle-renderer.md:68:**Errata 2026-05-20 (ADR-004):** Edit B's CLI command text was revised post-ADR-004 from `cortextos-ifos render-agent` to `ifos-render-agent`. The proposed text block below reflects the corrected name. See ADR-004 §"Master brief edits authorised" Edit D for the full disposition.
docs/decisions/ADR-003-agent-bundle-renderer.md:70:Three edits per design §5.3. Edits A and B land in this ADR's commit (small wording adds; Edit A is needed live before Week-1 renderer implementation). Edit C joins the deferred atomic correction commit alongside ADR-001 + ADR-002 edits.
docs/decisions/ADR-003-agent-bundle-renderer.md:124:> # For all active tenants (v1.1+): the --all-tenants flag is deferred to a future ADR-005 (see ADR-004 Edit D)
docs/decisions/ADR-003-agent-bundle-renderer.md:137:> "The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly. The renderer (`packages/agent-renderer/`, per `docs/decisions/ADR-003-agent-bundle-renderer.md` and `docs/architecture/agent-bundle-renderer-design.md`) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant). The cortextos-ifos add-agent command is NOT the IFOS path — it inherits 24 cortextOS template skills the IFOS bundle does not want."
docs/decisions/ADR-003-agent-bundle-renderer.md:139:Joins the deferred atomic correction commit (parallel to ADR-002 Edit 1 + Edit 2). Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/ADR-003-agent-bundle-renderer.md:145:**For Week 0 remaining (Day 2 through Day 7).** ADR-003 doesn't unblock or block any remaining Week 0 work directly. Day 2 (Bullhorn integration path), Day 3 (sequencing + Brain UI scope), Day 4 (Postgres provisioning with `entities` + `entity_links` split per ADR-002 Edit 3 + `_secrets.env` skeleton), Day 5 (auto-send safety policy + kill criterion), Day 6 (vertical schema v0.1), Day 7 (single-sentence test + first Codex ratification) all proceed independently. The renderer is queued for Codex Day-7 review but does not gate Day 7's other reviews.
docs/decisions/ADR-003-agent-bundle-renderer.md:147:**For Risk #5 (renderer-not-built).** Severity drops from **Blocking** to **High** with ADR-003 Accepted — design exists, ratified; just needs implementing. Drops to **Medium** once renderer code is committed and the Diagnostic agent renders cleanly (Week 4). Drops to **Low** once all five v1.0 agent bundles render and pass validation. The risk register entry is updated in this session as part of the ADR-003 commit.
docs/decisions/ADR-003-agent-bundle-renderer.md:149:**For Codex Day-7 ratification queue.** ADR-003 + the design doc join the queue alongside `cortextos-primitive-status.md`, ADR-001, ADR-002, `second-brain-design.md`, the deferred atomic master-brief correction commit, and the Day-4 Postgres provisioning artefact. The 22-item spec gap consolidation in design §5.4 plus the four-bucket structure (resolved inline / master-brief edits / Week-1+ prerequisites / operational defaults) is the ratification-supporting evidence.
docs/decisions/ADR-003-agent-bundle-renderer.md:151:**For the master brief atomic correction commit.** Edit C (the §8 footnote) joins ADR-001 + ADR-002 edits in the deferred single commit at end of Week 0 / early Week 1. Edits A and B land in this batch's commit because (a) Edit A is needed live before Week-1 renderer implementation can scaffold the package path, (b) Edit B is a small wording add to a code block, (c) neither is substantive enough to warrant the atomic-correction overhead.
docs/decisions/ADR-003-agent-bundle-renderer.md:153:**For future ADRs.** ADR-003 explicitly defers three further decisions:
docs/decisions/ADR-003-agent-bundle-renderer.md:155:- **Renderer implementation details** (test coverage matrix, packaging strategy, schema-validator library choice between Ajv vs alternatives) — to ADR-004 in Week 1 if the implementation work surfaces architectural choices, or to the implementation PR itself if straightforward.
docs/decisions/ADR-003-agent-bundle-renderer.md:156:- **`_shared/` helper code authoring** (`voice-loader.sh`, `hook-helpers.sh` contents) — already on the Week-1 prerequisite list per ADR-002 §"For Week 1 work." Not an ADR; just implementation work.
docs/decisions/ADR-003-agent-bundle-renderer.md:157:- **`docs/architecture/vault-concurrency.md` companion document** — already on the Week-1 prerequisite list per ADR-002. Not an ADR; resolves design §2.6 spec gap.
docs/decisions/ADR-003-agent-bundle-renderer.md:164:2. Edit C (§8 footnote) joins ADR-001 + ADR-002 edits in the deferred atomic correction commit at end of Week 0 / early Week 1. Five-edit manifest for that commit confirmed: ADR-001 §2.4 row 3 + Ultraplan §3.2; ADR-002 Edit 1 §3.4 + Edit 2 §5.5; ADR-003 Edit C §8.
docs/decisions/ADR-003-agent-bundle-renderer.md:166:4. Day 7 Codex ratification reviews ADR-003 + design doc + the previously-queued artefacts together.
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:10:> 3. §4 Gate-A failure signature is incomplete. Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature.
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:14:Codex's quote stops at line 119 ("...carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`"), but the file's statement spans lines 117-121 — and ESC_VOICE_DRIFT IS listed at lines 119-120. The full text (verbatim from the file at R16 close commit `4854b37`, unchanged at R17):
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:18:118    with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE for
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:20:120    voice-classifier-score-low failures; ESC_PII_LEAKAGE_RISK for PII
docs/operations/codex-ratification-execution-plan.md:124:| 2 | ADR-002 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | A |
docs/operations/codex-ratification-execution-plan.md:125:| 3 | ADR-003 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | A |
docs/operations/codex-ratification-execution-plan.md:126:| 4 | ADR-004 (new) | `docs/decisions/ADR-004-renderer-implementation-deviations.md` | A |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:23:| 9 | Sourcing Scout |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:75:- Sourcing Scout (W9) touches Bullhorn read; same gating
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
packages/agent-renderer/pnpm-lock.yaml:13:        version: 8.20.0
packages/agent-renderer/pnpm-lock.yaml:16:        version: 3.0.1(ajv@8.20.0)
packages/agent-renderer/pnpm-lock.yaml:202:    resolution: {integrity: sha512-RVyzfb3FWsGA55n6WY0MEIEPURL1FcbhFE6BffZEMEekfCzCIMtB5yyDcFnVbTnwk+CLAgTujmV/Lgvih56W+A==}
packages/agent-renderer/pnpm-lock.yaml:208:    resolution: {integrity: sha512-bPb5AHZtbeNGjCKVZ9UGqGwo8EUu4cLq68E95A53KlxAPRmUyYv2D6F0uUI65XisGOL1hBP5mTronbgo+0bFcA==}
packages/agent-renderer/pnpm-lock.yaml:376:    resolution: {integrity: sha512-nU1yhmYutL+fQ71Kxnhg8uEOdC0pwEW9entHykTgEbna2pw2dkbFSMeqjjyHZoCmt8SBkOSvV+yNmm94aUrrqw==}
packages/agent-renderer/pnpm-lock.yaml:545:    resolution: {integrity: sha512-J3Yh9PzzF1Ovah2At+lHiGQdsYgArxBbXv/zHfSyaiFQEqvNv7DcW98pCrmdjCZBrqBiKrKKe2V+aaSGWuBe/w==}
packages/agent-renderer/pnpm-lock.yaml:569:    resolution: {integrity: sha512-nbJnQ8a3z1mtmrwImCYhc6BGpThAyYVRQxw9uKSKG4wR6aAYno9sVjJ0zaZcW9BPJX1GbrDPf+SvdWjgTuDmnw==}
packages/agent-renderer/pnpm-lock.yaml:599:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}
packages/agent-renderer/pnpm-lock.yaml:605:    resolution: {integrity: sha512-Boiz5+MsaROEWDf+GGEwF8VMHGhlUoQMtIPjOgA5fv4osupqTVnJteQNKJwUcnUog2G55jYXH7KZFFiJe0TEzQ==}
packages/agent-renderer/pnpm-lock.yaml:650:    resolution: {integrity: sha512-GhdPgy1el4/ImP05X05Uw4cw2/M93BCUmnEvWZNStlCzEKME4Fkk+YpoA5OiHNQmoS7Cafb8Xa3Pya8m1Qrzeg==}
packages/agent-renderer/pnpm-lock.yaml:700:  ajv@8.20.0:
packages/agent-renderer/pnpm-lock.yaml:839:  mlly@1.8.2:
packages/agent-renderer/pnpm-lock.yaml:871:    resolution: {integrity: sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==}
packages/agent-renderer/pnpm-lock.yaml:1447:  ajv-formats@3.0.1(ajv@8.20.0):
packages/agent-renderer/pnpm-lock.yaml:1449:      ajv: 8.20.0
packages/agent-renderer/pnpm-lock.yaml:1451:  ajv@8.20.0:
packages/agent-renderer/pnpm-lock.yaml:1602:      mlly: 1.8.2
packages/agent-renderer/pnpm-lock.yaml:1628:  mlly@1.8.2:
packages/agent-renderer/pnpm-lock.yaml:1662:      mlly: 1.8.2
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:1:# ADR-002 — Brain system as parallel, not shadow
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:69:The one operation where cortextOS's mmrag/ChromaDB substrate could still serve IFOS is **semantic-search-over-raw** against `/vault/{tenant}/wiki/raw/` content (per design §2.3 row 9). That operation is **v1.2+ deferred**. ADR-002 explicitly **does not commit** to either cortextOS-substrate or IFOS-pgvector-native for the eventual implementation. The decision is deferred to a future ADR (likely in v1.2 planning) so it can be made against then-current evidence: actual raw/ volume, actual query patterns, actual cost data on Gemini embeddings, and whether Anthropic or OpenAI has shipped a sharply better embedding model by then.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:99:> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:103:> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:105:This edit lands on **Day 4 of Week 0 (this week)** as part of the Postgres provisioning task per master brief §6 Day 4, **not** in the brain-ADR atomic commit. ADR-002 authorises the split; Day 4 implements it.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:111:**For Week 1 work.** ADR-002 makes three Week-1 prerequisites load-bearing:
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:113:1. **ADR-003 + `docs/architecture/agent-bundle-renderer-design.md`** — resolves Spec gap §1.7-A (no documented translation from IFOS Agent Bundle v2 layout to cortextOS-shaped per-agent directory). Without it, no IFOS agent can run. Design recommends R2 (bundle-only, no `.claude/skills/` inheritance) per design §1.7.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:117:**For Day 4 this week (Postgres provisioning).** The `entity_graph` → `entities` + `entity_links` split per Spec gap 2.4-B / 3.4-B must land in the Day 4 migration. This is the only immediate-week impact of ADR-002.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:121:**For the master brief atomic correction commit.** ADR-001 (Edit: `chokidar watcher` → `FastChecker poll loop` in §2.4 row 3 + §3.2 latency reframe in Ultraplan) and ADR-002 (Edits 1, 2, 3 above — §3.4 wording, §5.5 v1.0 brain build wording, §6 Day 4 Postgres table list) **all landed together in commit `0e5b2b4` on 2026-05-20** ("docs: master brief reconciliation — 11 edits batch-applied"). Ratified by Codex on Day 7 along with ADR-001 + ADR-003 per master brief §10.6.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:123:**For future ADRs.** ADR-002 explicitly defers three decisions:
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:125:- **ADR-003 (renderer, R1 vs R2)** — design recommends R2; binding choice deferred to a separate ADR in Week 1.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:133:1. ADR-001 + ADR-002 master-brief edits LANDED in atomic-correction commit `0e5b2b4` (Day 7 2026-05-20). Status: closed.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:135:3. Day 7 Codex ratification reviews ADR-001 + ADR-002 + the seven Week 0 artefacts together (per master brief §10.6).
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:72:- The brain-replacement seam (§3.4) is unaffected by this ADR. ADR-002 covers that separately.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:76:**Accepted — Option A.** Founder decision logged 2026-05-16. The master brief §2.4 row 3 + Ultraplan §3.2 edits are deferred to a single atomic "spec drift reconciliation" commit that lands alongside whatever ADR-002 dictates for §3.4. Codex ratifies the combined commit on Day 7 with the other Week 0 artefacts.
docs/operations/goal-week-3-polish-and-scaffold.md:7:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:27:10. **`docs/decisions/ADR-003-agent-bundle-renderer.md`** + **`docs/architecture/agent-bundle-renderer-design.md`** (bundle pattern: 6 files + 3 fixtures)
docs/operations/goal-week-3-polish-and-scaffold.md:52:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:53:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:54:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:55:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:56:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:61:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:65:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:95:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:210:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:294:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **Build wave:** W5 per master brief §8.2 line 596
docs/operations/goal-week-3-polish-and-scaffold.md:332:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:360:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:361:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:367:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:383:### DAY 19 — Sourcing Scout + Concierge agent.md scaffolds (Steps 11-12)
docs/operations/goal-week-3-polish-and-scaffold.md:388:- ULTRAPLAN §8.1 A5 lines 547-558 (Sourcing Scout spec)
docs/operations/goal-week-3-polish-and-scaffold.md:389:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:390:- `bullhorn-integration-path.md` §4.1 (Sourcing Scout's Bullhorn read surface)
docs/operations/goal-week-3-polish-and-scaffold.md:391:- `vertical-schema.yaml` §3 agent_access_matrix Sourcing Scout row
docs/operations/goal-week-3-polish-and-scaffold.md:395:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:402:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_LINKEDIN_AUTH, ESC_RATE_LIMIT_HIT, ESC_BRIEF_UNDERSPECIFIED.
docs/operations/goal-week-3-polish-and-scaffold.md:409:Commit: `decision(pre-build): agents/recruitment/sourcing-scout/agent.md — output contract per ULTRAPLAN §8.1 A5`
docs/operations/goal-week-3-polish-and-scaffold.md:415:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:591:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:621:  Sourcing Scout (W9):    <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:642:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:685:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/decisions/sequencing-target.md:6:**Surfaced by:** Master brief §6 Day 3 (lines 469-473) — "Confirm or revise Ultraplan §9's 'close first 3 pilots fastest' → `.agents/decisions/sequencing-target.md`" (note: master brief §6 names `.agents/decisions/`; this document lives at `docs/decisions/sequencing-target.md` matching the convention established by ADR-001 through ADR-003 + bullhorn-integration-path.md — **Spec gap §1-A** flagged for atomic correction).
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:25:| A5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | "First daytime always-on agent" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:32:- **A. First agent.** Which agent ships first in Week 3-4? Anchors the renderer (ADR-003) + `_shared/` helpers (Week-1-2 prereqs from ADR-002) + Postgres `decision_log` (Day 4 Week 0) end-to-end test. Affects how risk surfaces — first agent is the smoke test for every substrate dependency.
docs/decisions/sequencing-target.md:40:**Week 3 needs a starting agent.** The renderer (ADR-003) lands Week 1-2; `_shared/voice-loader.sh` + `hook-helpers.sh` land Week 1-2; Postgres `decision_log` lands Day 4 Week 0. By Week 3 the substrate is live and waiting for its first user. Without §A (first agent), Week 3 doesn't have a build target.
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
docs/decisions/sequencing-target.md:113:| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:146:### 2.5 — A5 Sourcing Scout (daytime)
docs/decisions/sequencing-target.md:154:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Night Sourcer (v1.1) reuses Sourcing Scout's multi-source layer per Ultraplan §8.1 line 555 ("Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it") | Medium criticality (v1.1 downstream) |
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:166:| 4. Commercial value | **Highest** | Per master brief §8.2 line 606: "First Tier-1 always-on closing demo; 4-week build." Product Spec §2.2 R7: 15-25% lift in placement-driven referral revenue ("post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table"). The flagship v1.0 closing demo |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:176:Three orderings evaluated against §1.3 criteria. **Option Alpha is the master-brief §8.2 canonical sequence** (correcting the §1.5 founder-prompt drift); Options Beta and Gamma are tested as alternatives.
docs/decisions/sequencing-target.md:178:### 3.1 — Option Alpha (canonical, master-brief §8.2)
docs/decisions/sequencing-target.md:185:W9:   Sourcing Scout (A5)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:209:W9:   Janitor (A2)
docs/decisions/sequencing-target.md:211:W11:  Sourcing Scout (A5)
docs/decisions/sequencing-target.md:233:W12:  Sourcing Scout (A5)
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:256:| 5. Dependencies on other agents | **Wins** — Janitor's Bullhorn auth → Scribe reuses → Sourcing Scout reuses → Concierge reuses, all in dependency order | Loses — Concierge before Janitor + Scribe breaks the upstream chain | Loses — Concierge before Scribe breaks the upstream chain |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:281:| 1 | W3-4 | **Diagnostic** (A1) | Substrate-proof agent; first renderer production render per ADR-003 design §5.2 |
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:285:| 5 | W9 | **Sourcing Scout** (A5) | Multi-source aggregation; first LinkedIn rate-limit exercise (Risk #6) |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:310:- **Activation:** v1.0 scope cut from 6 to 4 agents per Ultraplan §10 row #4 — drop Concierge + Sourcing Scout to v1.1; founder solo through end of v1.0.
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:319:- **Cascade:** Sourcing Scout W10 (shifted right from W9), Concierge W11-14 (shifted right from W10-13).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:376:**New `decision_log` `phase` values introduced by this document:** `gating_failed`, `agent_handoff`. The Postgres decision_log table column `phase` (per `second-brain-design.md` §2.4.2 schema) currently lists only `trigger | output | action` per ADR-002 Decision 3. **Spec gap §5-A** flagged for Day 4 Postgres provisioning: extend the `phase` column's accepted values to include the two new ones. Schema migration is a one-line `CHECK` constraint update.
docs/decisions/sequencing-target.md:388:- Renderer impl (`packages/agent-renderer/`) per ADR-003 design §5.2.
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:402:- First production render lands W4 per ADR-003 design §5.2 line "First production render is the Diagnostic agent at Week 4."
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:414:Diagnostic W3-W4 build window is the first production renderer exercise per ADR-003 design §5.2. The reduction-trigger cascade per `docs/RISK-REGISTER.md` Risk #5 fires:
docs/decisions/sequencing-target.md:416:- Risk #5 was **Blocking** at Day 1 morning, **High** at Day 1 evening extension (ADR-003 Accepted).
docs/decisions/sequencing-target.md:432:Lands at Day 4 alongside the `entity_graph` → `entities` + `entity_links` split (ADR-002 Edit 3) and the `_secrets.env` skeleton addition (ADR-003 design §3.3 Spec gap §2.1-C). Three Day-4-tightenings consolidate into one provisioning task.
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:465:Joins the atomic correction commit as the **7th edit**, alongside the 6 edits already queued (5 from ADR-001/ADR-002/ADR-003 + 1 from `bullhorn-integration-path.md` §6.6). Updated 7-edit manifest:
docs/decisions/sequencing-target.md:469:3. ADR-002 Edit 1 §3.4: shadow → parallel
docs/decisions/sequencing-target.md:470:4. ADR-002 Edit 2 §5.5: v1.0 brain build wording
docs/decisions/sequencing-target.md:471:5. ADR-003 Edit C §8: renderer footnote
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:500:| 7th edit | Master brief §6 Day 3 line 471 | `.agents/decisions/` → `docs/decisions/` (per §6.8) | Joins atomic correction commit at end of Week 0 / early Week 1, alongside ADR-001 + ADR-002 + ADR-003 Edit C + `bullhorn-integration-path.md` §6.6 |
docs/decisions/sequencing-target.md:507:| Substrate readiness for W3 Diagnostic build (renderer + `_shared/` + `decision_log`) | Claude Code | End of W2 | Already tracked from ADR-002 + ADR-003 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
packages/harness/cortextos/dashboard/src/app/api/media/[...filepath]/route.ts:115:  function tryResolve(candidate: string): boolean {
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:37:| A5 Sourcing Scout | **Yes — read** (ATS passive-match lookup) | Ultraplan §8.1 A5 line 547-551 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:252:- **Strict separation:** IFOS internal dev tooling never touches production tenant refresh tokens. The renderer (per `ADR-003`) materialises tenant-scoped tokens into per-tenant `_secrets.env`; dev tooling reads from a separate gitignored path that doesn't pass through the renderer at all.
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:309:| Sourcing Scout passive-match read | Polling (on-demand search) | Per-consultant-request | No subscription needed — read-on-demand model |
docs/decisions/bullhorn-integration-path.md:324:- **Postgres `decision_log` RLS:** every Bullhorn-derived `hh_decision_*` row is tenant-scoped per ADR-002 Decision 3 (`tenant_slug` column + RLS policy per `second-brain-design.md` §2.4.2).
docs/decisions/bullhorn-integration-path.md:336:| Sourcing Scout (read-on-demand) | 50-200 during consultant-active windows | Search-heavy; multiple paginated reads per consultant request |
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:410:- **`_secrets.env` vault structure provisioned** per renderer §3.3.2 — already on Week-1 prereq list from ADR-003.
docs/decisions/bullhorn-integration-path.md:415:No Postgres schema changes from this decision document. `_secrets.env` is filesystem (vault), not Postgres, per the design's vault/Postgres split (ADR-002 §3 + `second-brain-design.md` §2.4). `decision_log` columns already support per-tenant `ESC_BULLHORN_AUTH` rows per ADR-002 Decision 3 schema — no new columns needed.
docs/decisions/bullhorn-integration-path.md:442:§3.2 finding (Bullhorn does NOT support client_credentials grant for tenant-scoped data per public OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`) forecloses the master brief §6 Day 2 line 466 pre-statement. New sixth edit for the atomic correction commit alongside ADR-001 + ADR-002 + ADR-003 Edit C.
docs/decisions/bullhorn-integration-path.md:468:- **Bullhorn MCP connector implementation details** (TypeScript module layout, request-builder pattern, error-class hierarchy) — to ADR-004 in Week 1-2 if architectural choices surface, or to the implementation PR itself if straightforward.
docs/decisions/bullhorn-integration-path.md:492:| 6th edit | Master brief §6 Day 2 line 466 | `service-account for dev` → `authorization-code grant against an IFOS-owned Bullhorn dev tenant` (per §6.6) | Joins atomic correction commit at end of Week 0 / early Week 1, alongside ADR-001 + ADR-002 + ADR-003 Edit C |
docs/decisions/bullhorn-integration-path.md:500:| Bullhorn MCP connector scaffolded at `packages/mcp-connectors/bullhorn/` | Claude Code | Week 1-2 (after ADR-003 renderer impl) |
docs/decisions/bullhorn-integration-path.md:502:| `ESC_BULLHORN_AUTH` escalation code wired into `agents/_shared/escalation-codes.md` | Claude Code | Week 1-2 (alongside `_shared/hook-helpers.sh` Week-1 prereq from ADR-002) |
docs/decisions/bullhorn-integration-path.md:503:| Vault `_secrets.env` skeleton in `provision-tenant.sh` (per ADR-003 Spec gap §2.1-C) | Claude Code | Day 4 Week 0 (already scheduled) |
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:49:- Aggregate failures fire `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) when sustained — same operational lever as ADR-006's per-claim quality metric
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:60:- ✅ No PII outside firm boundary — Gate A hard-fail (`ESC_PII_LEAKAGE_RISK`)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:62:- ✅ All Bullhorn context fields present — Gate A hard-fail (`ESC_AGENT_OUTPUT_SHAPE`)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:68:- Rolling 30-day per-tenant aggregate <90% fires `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) — actionable signal
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:77:> - **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:125:| ADR-007-Q1 | Should the 90% threshold be per-tenant configurable, or is 90% a v1.0 fixed bar? | Recommend fixed at v1.0; v1.1 add per-tenant override via `tenant_adapters.config.concierge_sla_threshold` (new key, v0.4-pending). |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:126:| ADR-007-Q2 | Should `ESC_CONCIERGE_SLA_MISS` be a separate code, or should it reuse `ESC_GATE_B_MISS` with payload.metric='concierge_30min_sla'? | Recommend separate code for clean Telegram routing; `_GATE_B_MISS` is generic aggregate. Catalogue addition queued at W10-13 build start. |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:134:- `agents/_shared/escalation-codes.md` `ESC_CONCIERGE_SLA_MISS` (registered) + `ESC_GATE_B_MISS` (registered)
packages/mcp-connectors/companies-house/pnpm-lock.yaml:186:    resolution: {integrity: sha512-RVyzfb3FWsGA55n6WY0MEIEPURL1FcbhFE6BffZEMEekfCzCIMtB5yyDcFnVbTnwk+CLAgTujmV/Lgvih56W+A==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:192:    resolution: {integrity: sha512-bPb5AHZtbeNGjCKVZ9UGqGwo8EUu4cLq68E95A53KlxAPRmUyYv2D6F0uUI65XisGOL1hBP5mTronbgo+0bFcA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:360:    resolution: {integrity: sha512-nU1yhmYutL+fQ71Kxnhg8uEOdC0pwEW9entHykTgEbna2pw2dkbFSMeqjjyHZoCmt8SBkOSvV+yNmm94aUrrqw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:529:    resolution: {integrity: sha512-J3Yh9PzzF1Ovah2At+lHiGQdsYgArxBbXv/zHfSyaiFQEqvNv7DcW98pCrmdjCZBrqBiKrKKe2V+aaSGWuBe/w==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:553:    resolution: {integrity: sha512-nbJnQ8a3z1mtmrwImCYhc6BGpThAyYVRQxw9uKSKG4wR6aAYno9sVjJ0zaZcW9BPJX1GbrDPf+SvdWjgTuDmnw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:583:    resolution: {integrity: sha512-ynt3JxVd2w2buzoKDWIyiV1pJW93xlQic1THVLXilz429oijRpSHivZAgp65KBu+cMcgf1eVVjdnTLvPxgCuoQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:589:    resolution: {integrity: sha512-Boiz5+MsaROEWDf+GGEwF8VMHGhlUoQMtIPjOgA5fv4osupqTVnJteQNKJwUcnUog2G55jYXH7KZFFiJe0TEzQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:634:    resolution: {integrity: sha512-GhdPgy1el4/ImP05X05Uw4cw2/M93BCUmnEvWZNStlCzEKME4Fkk+YpoA5OiHNQmoS7Cafb8Xa3Pya8m1Qrzeg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:789:  mlly@1.8.2:
packages/mcp-connectors/companies-house/pnpm-lock.yaml:821:    resolution: {integrity: sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1527:      mlly: 1.8.2
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1547:  mlly@1.8.2:
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1581:      mlly: 1.8.2
docs/runbooks/day-4-provisioning.md:58:### §0.2 — DRIFT: master brief §6 Day 4 table list says `entity_graph`, ADR-002 Edit 3 split this to `entities` + `entity_links`
docs/runbooks/day-4-provisioning.md:60:**Master brief asserts (§6 Day 4 line 478):** "Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`"
docs/runbooks/day-4-provisioning.md:62:**ADR-002 Edit 3 + current-priorities.md (Open) state the corrected table list:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:690:**Tightening 1:** former `entity_graph` is split into `entities` + `entity_links` per ADR-002 Edit 3.
docs/runbooks/day-4-provisioning.md:706:-- entities (formerly entity_graph; split per ADR-002 Edit 3)
docs/runbooks/day-4-provisioning.md:726:-- entity_links (split from entity_graph adjacency per ADR-002 Edit 3)
docs/runbooks/day-4-provisioning.md:749:-- decision_log (per ADR-002 §3 Decision 3; phase enum per §6.4 below = Tightening 3)
docs/runbooks/day-4-provisioning.md:783:-- tenant_adapters (per master brief §6 Day 4 line 478; tracks per-tenant adapter binding)
docs/runbooks/day-4-provisioning.md:784:CREATE TABLE tenant_adapters (
docs/runbooks/day-4-provisioning.md:795:GRANT SELECT, INSERT, UPDATE, DELETE ON tenant_adapters TO ifos_app;
docs/runbooks/day-4-provisioning.md:796:GRANT USAGE, SELECT ON SEQUENCE tenant_adapters_id_seq TO ifos_app;
docs/runbooks/day-4-provisioning.md:801:# Expected: six tables listed (tenants, entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters)
docs/runbooks/day-4-provisioning.md:830:Per `current-priorities.md` line 15 + ADR-003 design §3.3 spec gap §2.1-C. Filesystem operations, not SQL.
docs/runbooks/day-4-provisioning.md:842:# Source: Day 4 runbook §6.5; consolidates Ultraplan §5.1 + ADR-003 §2.1-C
docs/runbooks/day-4-provisioning.md:871:# _secrets.env at mode 0600 — per ADR-003 §2.1-C
docs/runbooks/day-4-provisioning.md:908:\d tenant_adapters
docs/runbooks/day-4-provisioning.md:936:ALTER TABLE tenant_adapters ENABLE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:943:ALTER TABLE tenant_adapters FORCE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:971:CREATE POLICY tenant_isolation ON tenant_adapters
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1090:The vault per ADR-002 + master brief §3.3 is markdown, git-backed. Initial baseline:
docs/runbooks/day-4-provisioning.md:1127:- [ ] §6.3 — Six tables exist: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/runbooks/day-4-provisioning.md:1248:17. **§7 — RLS isolation gate passed clean (5 of 5).** No-context = 0 ✓, own-tenant insert+select = 1 ✓, cross-tenant = 0 ✓, WITH CHECK adversarial INSERT rejected ✓, own-tenant unaffected = 1 ✓. RLS + FORCE on entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters (5 tables). `tenant_isolation` policy on all 5 with USING + WITH CHECK on `current_setting('app.current_tenant', true)`. Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser, which would bypass RLS). Test data ROLLBACK'd; 2 seeded test tenants cleaned up.
docs/runbooks/day-4-provisioning.md:1286:- Not the wiki-brain provisioning (the `wiki-*` parallel scripts land Week 1-2 per ADR-002)
docs/runbooks/operational-hygiene-protocol.md:299:- `ADR-003 Decision 3` referencing "design §2.1" — ✅ verified Decision 3 exists; references `agent-bundle-renderer-design.md §2.1` correctly
docs/build-brief/00-MASTER-BRIEF.md:119:| 7 | Multi-agent orchestrator | `orchestrator` template + file-bus handoff contract | Brief Decoder → Sourcing Scout → Concierge pipeline lives here |
docs/build-brief/00-MASTER-BRIEF.md:167:IFOS implements its second brain as a **parallel system**, not by shadowing cortextOS's stock knowledge base. cortextOS's `bus/kb-*.sh` files (`kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh` at SHA `c21fbfe`) remain untouched and continue to serve cortextOS-template agents. IFOS agents invoke a parallel wrapper surface at `packages/brain/bus-overrides/wiki-*.sh` (9 v1.0 + 1 v1.1 stub) that dispatches to `packages/brain/wiki/lib/` against Postgres + filesystem markdown. The §3.1 "four `bus/kb-*.sh` shadow points" edit-exception is unused — IFOS does not edit any file under `packages/harness/cortextos/`. See `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` + `docs/architecture/second-brain-design.md` for the full design.
docs/build-brief/00-MASTER-BRIEF.md:464:- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation.
docs/build-brief/00-MASTER-BRIEF.md:470:- [ ] Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per ADR-002 Edit 3 + `docs/architecture/second-brain-design.md` §2.4.2).
docs/build-brief/00-MASTER-BRIEF.md:562:**The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly.** The renderer (`packages/agent-renderer/`, per `docs/decisions/ADR-003-agent-bundle-renderer.md` and `docs/architecture/agent-bundle-renderer-design.md`) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant). The `cortextos-ifos add-agent` command is **NOT** the IFOS path — it inherits 24 cortextOS template skills the IFOS bundle does not want.
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:584:- `ESC_BRIEF_AMBIGUITY` — Brief Decoder cannot confidently shortlist
docs/build-brief/00-MASTER-BRIEF.md:585:- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
docs/build-brief/00-MASTER-BRIEF.md:591:### 8.2 The build order — v1.0 only
docs/build-brief/00-MASTER-BRIEF.md:599:| 5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
docs/build-brief/00-MASTER-BRIEF.md:663:        │ (raw + compiled)│                  │ RLS-isolated           │                  │ tenant_adapters    │
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
docs/runbooks/tenant-lifecycle.md:5:**Authority:** Consolidates Day-4 §6.5 provisioning + tenancy-invariants.md + ADR-002 + ADR-003 + v0.2 supplement.
docs/runbooks/tenant-lifecycle.md:173:Per ADR-003 §"Master brief edits authorised" Edit B (post-ADR-004 corrected to `ifos-render-agent`).
docs/runbooks/tenant-lifecycle.md:250:  DELETE FROM tenant_adapters   WHERE tenant_slug='<slug>';
docs/runbooks/pii-purge-operational-pattern.md:33:Per-tenant override via `tenant_adapters.config.pii_retention_days` — range [30, 365]. Allows enterprise tenants to extend retention via TOS amendment + advisor signoff.
docs/runbooks/pii-purge-operational-pattern.md:134:Per-tenant override via `tenant_adapters.config.pii_retention_days`:
docs/runbooks/pii-purge-operational-pattern.md:137:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/runbooks/pii-purge-operational-pattern.md:198:| P2 | tenant_adapters override read not yet implemented in script (uses single --retention-days CLI arg) | First tenant requests extended retention |
docs/specs/ULTRAPLAN.md:72:- **The file bus.** Inter-agent handoff via shared filesystem directories. No queue, no API, no serialisation tax. Brief Decoder writes a parsed-brief file; Sourcing Scout's `FastChecker` polls it up at the configured cadence (default 1000ms `pollInterval`, configurable per agent); result lands in a sub-directory the Concierge is polling. Four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound.
docs/specs/ULTRAPLAN.md:155:hh_load_tone_rules
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:186:- `ESC_BRIEF_AMBIGUITY` — Brief Decoder found ambiguities that prevent confident shortlisting
docs/specs/ULTRAPLAN.md:187:- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
docs/specs/ULTRAPLAN.md:543:#### A5. Sourcing Scout (daytime form) — request-response sourcing
docs/specs/ULTRAPLAN.md:571:### 8.2 v1.1 agents (seven, in build order)
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
docs/specs/_archive-build-handoff.md:381:| 5 | **Sourcing Scout** | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
docs/specs/PRODUCT-SPEC.md:101:#### R5. Sourcing Scout (daytime form) — request-response sourcing during the day
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:400:| 3 | Inter-agent file bus — agents hand work to each other via shared directories | Brief Decoder → Sourcing Scout → Concierge handoff; Triage → specialist-agent routing |
docs/specs/PRODUCT-SPEC.md:476:- Sourcing Scout (daytime form)
docs/specs/PRODUCT-SPEC.md:486:3. **Night Sourcer** (2 weeks) — overnight extension of Sourcing Scout
docs/specs/PRODUCT-SPEC.md:526:5. **Sourcing Scout (daytime)** — "Shortlist in 15 minutes instead of by end of week."
docs/_supplementary/PRD-autonomous-agent.md:766:    candidate: c,
docs/_supplementary/PRD-autonomous-agent.md:1143:  "overall_score": 8.2,
packages/harness/cortextos/dashboard/src/app/api/comms/channels/route.ts:97:              const candidate: BusMessage = {
packages/harness/cortextos/dashboard/src/app/api/comms/channel/[pair]/route.ts:165:              const candidate: RawTelegramEntry = {
docs/_supplementary/strategic-plan.md:394:### 8.2 Channels, ranked by realistic ROI for you
packages/harness/cortextos/package.json:54:    "@playwright/test": "^1.58.2",

codex
The first pass found the expected source files and several relevant anchors. I’m narrowing to exact line ranges now so the verdict can cite concrete mismatches rather than inferred drift.
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '543,556p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '562,606p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '48,105p'; nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '380,410p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   380	  EXECUTE FUNCTION validate_entities_data_v0_3();
   381	
   382	-- ----------------------------------------------------------------------------
   383	-- §5 — tenant_adapters.config validation trigger (new keys)
   384	-- ----------------------------------------------------------------------------
   385	--
   386	-- v0.3 codifies 3 new config keys agents read. The validation trigger ensures
   387	-- only the documented keys are stored (hard-fail on unknown keys per Rule 2
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
   403	    'cash_conductor_last_run',
   404	    'concierge_last_poll',
   405	    'concierge_send_window'
   406	    -- diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   407	    -- (per ADR-006 Tier 2); v0.3 trigger does not allowlist this key
   408	  ];
   409	BEGIN
   410	  IF c IS NULL THEN

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '136,190p'; nl -ba agents/_shared/escalation-codes.md | sed -n '232,266p'; nl -ba agents/_shared/escalation-codes.md | sed -n '372,386p'; nl -ba agents/_shared/escalation-codes.md | sed -n '410,435p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '96,122p'; nl -ba agents/_shared/autosend-policy.yaml | sed -n '338,352p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   109	    agent: all
   110	    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
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

exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_AUTH|hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|function hh_|send_to_blocked_recipient|consultant_feedback|source_report|approval" agents/_shared docs/decisions -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/hook-helpers.sh:192:# Returns 0 if action allowed; 1 if blocked or approval rejected.
agents/_shared/hook-helpers.sh:235:        "${target}" "${payload_hash}" "${payload_preview}" "approval_pending"
agents/_shared/hook-helpers.sh:238:      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
agents/_shared/hook-helpers.sh:329:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
agents/_shared/hook-helpers.sh:341:  payload=$(printf '{"tier":"%s","action_type":"%s","target":"%s","payload_hash":"%s","payload_preview":"%s","approval_status":%s,"block_reason":%s,"policy_version_sha":"%s"}' \
agents/_shared/hook-helpers.sh:451:# autosend_await_approval <action_type> <target> <payload_hash>
agents/_shared/hook-helpers.sh:452:# Blocks until cortextOS approval gate resolves OR timeout fires.
agents/_shared/hook-helpers.sh:453:# Returns 0 on approval, 1 on rejection or timeout-rejection.
agents/_shared/hook-helpers.sh:455:# v0.1 implementation: writes pending-approval marker to vault + polls.
agents/_shared/hook-helpers.sh:457:autosend_await_approval() {
agents/_shared/hook-helpers.sh:481:  local pending_dir="${IFOS_VAULT_ROOT:-/vault}/${tenant}/pending-approvals"
agents/_shared/autosend-policy.yaml:107:  consultant_feedback:
agents/_shared/autosend-policy.yaml:218:  # ORANGE — per-action human approval (10 action_types)
agents/_shared/autosend-policy.yaml:345:  send_to_blocked_recipient:
agents/_shared/autosend-policy.yaml:357:  approval_timeout: PT4H        # Default orange-tier approval window per §8 rule 5
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:43:| `HH_AWAIT_TEST_MODE` | no (test only) | `approve` / `reject` / `timeout` — short-circuits `autosend_await_approval` poll loop | — |
agents/_shared/README.md:56:`hh_decision_action` is the **gated** call. Returns `0` if action allowed, `1` if blocked or approval rejected. All three write a `decision_log` row before returning.
agents/_shared/README.md:67:autosend_await_approval       <action_type> <target> <hash>                          # blocks until resolved
agents/_shared/README.md:78:| **orange** | Emit `phase=action` + escalate `ESC_AUTOSEND_NEEDS_REVIEW`, block on approval gate, return 0/1 | depends on approval |
agents/_shared/README.md:84:Per autosend-safety-policy §6 + plan §Phase 3 acceptance criterion #5: `autosend_await_approval` blocks for `timeout_seconds` (4h default from `autosend-policy.yaml` `defaults.approval_timeout`). PM2 + cortextOS primitive 1 keep the agent process alive during the block. Inter-agent bus-messaging to a 4h-blocked agent is fire-and-forget from the sender's perspective (cortextOS bus delivers asynchronously); blocked agent processes deferred messages when approval resolves.
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
agents/_shared/escalation-codes.md:34:- **Severity:** info → blocking-pending-approval
agents/_shared/escalation-codes.md:37:- **Routing:** `operator_chat_id` via Telegram approval gate (primitive 4)
agents/_shared/escalation-codes.md:38:- **Timeout:** 4h default per `common-notifications.json.default_approval_timeout_seconds`; on timeout, converts to manual reconciliation
agents/_shared/escalation-codes.md:39:- **Payload fields:** `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `approval_status='pending'`
agents/_shared/escalation-codes.md:97:#### `ESC_BULLHORN_AUTH`
agents/_shared/escalation-codes.md:128:- **Severity:** warn — Janitor dedup needs human approval
agents/_shared/escalation-codes.md:131:- **Routing:** `operator_chat_id` via Telegram approval gate
agents/_shared/escalation-codes.md:232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
agents/_shared/escalation-codes.md:312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
agents/_shared/escalation-codes.md:349:- **Severity:** warn — orange action's approval window expired without response
agents/_shared/escalation-codes.md:360:  - **State-change race (Cash Conductor):** payment received between chase-draft and chase-send window; the invoice is no longer overdue when the orange-tier approval fires; chase cancelled (do NOT send) per Cash Conductor §4 Step 12
agents/_shared/tests/test-hook-helpers.sh:165:    && _assert_contains "${row}" '"approval_status":"approval_pending"' \
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:118:| Does the Diagnostic v0 produce reports good enough to send Jack for Q1 pitch? | Iteration loop in W3 polish (Step 7 + follow-ups). Quality gate: founder approval after running against 5-10 real firms. |
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
docs/decisions/2026-05-18-day-7-single-sentence-test.md:44:- **Primitive 4 (Approval gates):** confirmed "shipped and tested" per `cortexos-primitive-status.md`. Active code citations: `src/bus/approval.ts:222-226` (activity-channel + per-agent-bot belt-and-braces pattern post-50h-stall incident), `src/daemon/fast-checker.ts:454-552` (callback handling with `ALLOWED_USER` enforcement at line 468 and 552, `appr_allow_<id>` / `appr_deny_<id>` callback routing for primitive 4 approval-gate UX).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:45:- **Primitive 5 (Telegram + iOS approval surface):** confirmed shipped per `cortexos-primitive-status.md` audit. Two-poller mechanism (`agent-manager.ts:478-575`, `maybeStartActivityChannelPoller()`) integrates with primitive 4 approval gates. Per master brief §12 Risk #1 framing: "Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5."
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:140:| 6. Tenant-onboarding readiness | **Medium** | Needs Xero/QuickBooks/Sage OAuth (one of, per tenant) + Open Banking auth (TrueLayer/Plaid UK per Ultraplan §8.1 line 539). Chase-cadence config per tenant. FD's mobile for Telegram approval per Ultraplan §8.1 line 540 |
docs/decisions/sequencing-target.md:168:| 6. Tenant-onboarding readiness | **Hardest** | Needs Bullhorn + Microsoft Graph (or Gmail) per tenant + full voice corpus loaded + nurture cadence config per stage + auto-send approval categories (Solo: drafts-only; Boutique+: candidate-acknowledgement auto-send) + do-not-contact flags. Full onboarding-wizard Day 4 work (Product Spec §5.2) |
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/autosend-safety-policy.md:39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
docs/decisions/autosend-safety-policy.md:59:### Orange — requires human approval before send
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:98:### Orange examples (per-action human approval)
docs/decisions/autosend-safety-policy.md:124:| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |
docs/decisions/autosend-safety-policy.md:186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
docs/decisions/autosend-safety-policy.md:188:      # Blocks on cortextOS approval gate (master brief primitive 4). Returns 0 on approval, 1 on reject/timeout.
docs/decisions/autosend-safety-policy.md:189:      autosend_await_approval "$action_type" "$target" "$payload_hash"
docs/decisions/autosend-safety-policy.md:240:**Fires when:** an orange-tier action is invoked; opens cortextOS approval gate (primitive 4)
docs/decisions/autosend-safety-policy.md:251:  "approval_deadline_at": "<ISO 8601 UTC, default trigger_time + 4h>",
docs/decisions/autosend-safety-policy.md:252:  "approval_gate_id": "<cortextOS approval gate primary key>"
docs/decisions/autosend-safety-policy.md:258:1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
docs/decisions/autosend-safety-policy.md:259:2. `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` opens the cortextOS approval gate
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:262:5. On resolution, `decision_log` row is **appended** (not modified — append-only) with `phase='action'`, `payload.approval_status='approved'|'rejected'|'escalated'` and `payload.approval_resolution_at`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:269:🟠 IFOS approval needed
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:357:| Telegram primitive 5 unavailable (bot down, chat_id invalid) | `autosend_escalate` returns non-zero | Decision_log row still written; orange action falls back to **block-with-pending** state; agent halts at the action | IFOS oncall investigates Telegram primitive; once restored, pending approval gates resume |
docs/decisions/autosend-safety-policy.md:390:--     "approval_id": "<cortextOS approval gate id if orange>",
docs/decisions/autosend-safety-policy.md:391:--     "approval_status": "<pending|approved|rejected|timeout_rejected|escalated>",
docs/decisions/autosend-safety-policy.md:392:--     "approval_resolution_at": "<ISO 8601 if resolved>",
docs/decisions/autosend-safety-policy.md:402:1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
docs/decisions/autosend-safety-policy.md:441:    "approval_routing": {
docs/decisions/autosend-safety-policy.md:445:    "approval_timeouts": {
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:465:5. **`approval_timeouts`** allow per-action_type customisation within range [PT30M, PT72H]. Defaults to PT4H if unspecified.
docs/decisions/autosend-safety-policy.md:480:- **Green and red** give the binary "allowed" vs "blocked" classification needed for a low-risk v1.0 launch. Every action is either fully auto-sent or fully blocked. No "needs approval" or "sampled" intermediate states.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:483:- v1.0 handles "needs approval" cases via **ad-hoc Telegram approval** outside the policy pipeline: agent emits a manual approval request via existing primitive 5, founder/operator resolves manually, agent proceeds. These cases are tracked as "would-be-orange" candidates for v1.1 prioritisation.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:495:- **Pre-action policy simulation:** Brain UI feature — operator types proposed action; system shows tier, override impact, approval routing, expected resolution time. Reduces accidental tier-aware design.
docs/decisions/autosend-safety-policy.md:496:- **Multi-channel approval:** routing to Slack, Discord, MS Teams in addition to Telegram.
docs/decisions/autosend-safety-policy.md:525:      designated approver via the approval gate;
docs/decisions/autosend-safety-policy.md:601:| 6 | v1.0 "would-be-orange" cases without orange tier implementation — how does the agent halt for ad-hoc Telegram approval without breaking the green/red binary? | §9 | Recommend a `hh_decision_action_ad_hoc_approval` helper that lives alongside `hh_decision_action`; agent explicitly calls it for known orange cases at v1.0; v1.1 deprecates as orange tier ships. |
docs/decisions/autosend-safety-policy.md:605:| 10 | Telegram bot reliability — primitive 5 is shipped but not battle-tested at v1.0 pilot scale. What's the SLA on approval gate notification? | §5 + §6 | Recommend instrumentation in Week 1-2 as part of `_shared/` helpers build. Target: 95th percentile notification latency <30s. Below-target events trigger v1.1 evaluation of alternate channels. |
docs/decisions/autosend-safety-policy.md:622:- **Q6 (v1.0 ad-hoc orange handling without orange tier shipped):** ACCEPTED. `hh_decision_action_ad_hoc_approval` helper sits alongside `hh_decision_action` in `_shared/hook-helpers.sh` (Week-1 prereq 3). Agent explicitly calls `_ad_hoc_approval` for known orange cases at v1.0; v1.1 deprecates the helper as full orange tier ships through `hh_decision_action`'s case-orange branch.
docs/decisions/autosend-safety-policy.md:634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/bullhorn-integration-path.md:131:- Application-to-approval timeline.
docs/decisions/bullhorn-integration-path.md:230:- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
docs/decisions/bullhorn-integration-path.md:411:- **`ESC_BULLHORN_AUTH` escalation code wired** into `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3 line 587 — code already named in master brief; wiring lands with `_shared/hook-helpers.sh` Week-1 prereq.
docs/decisions/bullhorn-integration-path.md:415:No Postgres schema changes from this decision document. `_secrets.env` is filesystem (vault), not Postgres, per the design's vault/Postgres split (ADR-002 §3 + `second-brain-design.md` §2.4). `decision_log` columns already support per-tenant `ESC_BULLHORN_AUTH` rows per ADR-002 Decision 3 schema — no new columns needed.
docs/decisions/bullhorn-integration-path.md:484:| §4.5 (architectural emergence) | §4.5 | Access-token refresh-loop: per-agent background task, 8-minute cycle, retry-once-then-`ESC_BULLHORN_AUTH` |
docs/decisions/bullhorn-integration-path.md:502:| `ESC_BULLHORN_AUTH` escalation code wired into `agents/_shared/escalation-codes.md` | Claude Code | Week 1-2 (alongside `_shared/hook-helpers.sh` Week-1 prereq from ADR-002) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:61:### Issue 4 (NEW) — `_consultant_feedback` sentinel undocumented
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:63:**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:69:Option A — **Add `_consultant_feedback` to the sentinel catalogue.** New entry in `agents/_shared/escalation-codes.md` documenting purpose, payload shape, and emit cadence.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:71:Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:130:4. **Sentinel agent_name usage** — _consultant_feedback (Diagnostic) is the clear case; other agents likely have similar invented sentinels. Disposition: prefer `agent_name='<agent>'` with `payload.action_type` markers; reserve sentinels for system actors (_renderer, _tenant_admin, _codex_ratifier).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:259:- Cat-4 (sentinel hygiene): Diagnostic `_consultant_feedback` → agent_name='diagnostic' + payload.action_type
docs/decisions/v1.0-kill-criterion.md:172:**Threshold:** cortextOS primitives 3 (file bus per `cortexos-primitive-status.md` line item 3) or 4 (approval gates per primitive 4) report >1 production incident per week across **2 consecutive weeks** for any single pilot.
docs/decisions/v1.0-kill-criterion.md:180:**Action:** PAUSE. Rationale: cortextOS primitive instability is a structural threat to every IFOS agent — every agent uses the file bus and most use approval gates. Chronic failure points to either (a) cortextOS regression upstream OR (b) IFOS usage pattern incompatible with cortextOS at scale.
docs/decisions/brain-ui-scope.md:42:- Highlights pending approvals (Concierge auto-send escalations per `bullhorn-integration-path.md` §4.1 row 4).
docs/decisions/brain-ui-scope.md:43:- Highlights `ESC_*` escalations across all agents — `ESC_BULLHORN_AUTH`, `ESC_VOICE_DRIFT`, `ESC_DUPLICATE_DETECTED`, `ESC_RENDERER_FAILED`, etc.
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/decisions/2026-05-18-codex-ratification-manifest.md:82:| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:99:| 6 | `docs/decisions/autosend-approval-bridge-spec.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
docs/decisions/autosend-approval-bridge-spec.md:1:# Autosend approval bridge — implementation spec
docs/decisions/autosend-approval-bridge-spec.md:14:Autosend-safety-policy §3 declares 10 v1.0 action_types as **orange tier** — most importantly the canonical orange `bullhorn_note_customer_visible` (Concierge's primary outbound action). Orange-tier actions require per-action human approval via Telegram before executing.
docs/decisions/autosend-approval-bridge-spec.md:16:The infrastructure for IFOS-side approval pending is **already shipped** in Phase 3 (commit `e6e9df1`):
docs/decisions/autosend-approval-bridge-spec.md:18:- `agents/_shared/hook-helpers.sh::autosend_await_approval` writes pending marker `/vault/<tenant>/pending-approvals/<hash>.pending`
docs/decisions/autosend-approval-bridge-spec.md:22:What's **missing**: the bridge that converts a `.pending` marker into a Telegram approval request, and a Telegram button-press back into a `.approved`/`.rejected` marker.
docs/decisions/autosend-approval-bridge-spec.md:30:`packages/harness/cortextos/src/bus/approval.ts` already implements the Telegram approval flow:
docs/decisions/autosend-approval-bridge-spec.md:44:// → writes ${approvalDir}/pending/approval_<epoch>_<rand5>.json
docs/decisions/autosend-approval-bridge-spec.md:46:// → returns approvalId
docs/decisions/autosend-approval-bridge-spec.md:52:  approvalId: string,
docs/decisions/autosend-approval-bridge-spec.md:62:The Telegram bot itself is `packages/harness/cortextos/src/telegram/*` — also shipped + tested. Inline-button presses → `updateApproval(approvalId, 'approved'|'denied')` is wired end-to-end per `src/bus/approval.ts:178-229` + `src/daemon/agent-manager.ts` activity-channel poller.
docs/decisions/autosend-approval-bridge-spec.md:68:A new IFOS package: `packages/autosend-approval-bridge/`. ~200-250 lines of TypeScript. Runs as a long-lived process (PM2-managed alongside the daemon).
docs/decisions/autosend-approval-bridge-spec.md:72:**Loop 1: IFOS pending → cortextOS approval**
docs/decisions/autosend-approval-bridge-spec.md:75:Watch /vault/<tenant>/pending-approvals/*.pending (across all tenants)
docs/decisions/autosend-approval-bridge-spec.md:81:  - Record mapping {ifos_payload_hash → cortextos_approval_id} in bridge state
docs/decisions/autosend-approval-bridge-spec.md:87:Watch ${CTX_FRAMEWORK_ROOT}/orgs/<org>/approvals/resolved/*.json
docs/decisions/autosend-approval-bridge-spec.md:90:  - Look up the IFOS payload_hash from bridge state via cortextos_approval_id
docs/decisions/autosend-approval-bridge-spec.md:92:  - If approved: write /vault/<tenant>/pending-approvals/<payload_hash>.approved
docs/decisions/autosend-approval-bridge-spec.md:93:  - If denied:   write /vault/<tenant>/pending-approvals/<payload_hash>.rejected
docs/decisions/autosend-approval-bridge-spec.md:98:The bridge's `autosend_await_approval` polling loop (already in `hook-helpers.sh`) sees the new marker → returns 0 (approved) or 1 (rejected) → agent proceeds or escalates.
docs/decisions/autosend-approval-bridge-spec.md:102:Mapping `{ifos_payload_hash, cortextos_approval_id, tenant_slug, action_type, created_at, resolved_at}` lives in a small SQLite database at `${CTX_FRAMEWORK_ROOT}/autosend-bridge.db` OR (cleaner) a new Postgres table `autosend_approval_mappings`:
docs/decisions/autosend-approval-bridge-spec.md:105:CREATE TABLE IF NOT EXISTS autosend_approval_mappings (
docs/decisions/autosend-approval-bridge-spec.md:107:  cortextos_approval_id TEXT NOT NULL UNIQUE,
docs/decisions/autosend-approval-bridge-spec.md:118:ALTER TABLE autosend_approval_mappings ENABLE ROW LEVEL SECURITY;
docs/decisions/autosend-approval-bridge-spec.md:119:CREATE POLICY tenant_isolation ON autosend_approval_mappings
docs/decisions/autosend-approval-bridge-spec.md:121:GRANT SELECT, INSERT, UPDATE ON autosend_approval_mappings TO ifos_app;
docs/decisions/autosend-approval-bridge-spec.md:128:`autosend_approval_mappings` becomes the 10th tenant-data table when the bridge implementation lands. The Week-9 bridge implementation slice MUST update `docs/architecture/tenancy-invariants.md` §1 and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` to include this table in T1-T3, T11, and audit coverage. This remediation corrects the spec only; the table does not exist yet, so the live invariant inventory remains the v0.2 nine-table set until the bridge migration ships.
docs/decisions/autosend-approval-bridge-spec.md:132:cortextOS Primitive 4 enumerates approval categories as `external-comms`, `financial`, `deployment`, `data-deletion`, and `other` per `packages/harness/cortextos/src/types/index.ts`. IFOS action_types from `agents/_shared/autosend-policy.yaml` map as follows:
docs/decisions/autosend-approval-bridge-spec.md:167:Operator taps button → cortextOS Telegram bot fires → `updateApproval(approvalId, 'approved'|'denied')` → resolved file → bridge writes marker → IFOS agent proceeds.
docs/decisions/autosend-approval-bridge-spec.md:171:`autosend_await_approval` already enforces 4h default timeout per action_type's `timeout` field in autosend-policy.yaml. If the timeout fires before operator responds:
docs/decisions/autosend-approval-bridge-spec.md:174:2. cortextOS-side: approval file stays in `pending/` indefinitely (no auto-timeout) — **THIS IS A LEAK**
docs/decisions/autosend-approval-bridge-spec.md:176:**Bridge fix:** on IFOS-side timeout, the bridge MUST call `updateApproval(approvalId, 'denied', note='ifos_timeout')` to clean up the pending file. Otherwise stale pending approvals accumulate in cortextOS.
docs/decisions/autosend-approval-bridge-spec.md:182:| cortextOS approval system down (createApproval throws) | Write `<hash>.bridge-error` marker; IFOS poll-loop times out at 4h; ESC_AUTOSEND_NEEDS_REVIEW fires with `reason='bridge_unavailable'` |
docs/decisions/autosend-approval-bridge-spec.md:199:packages/autosend-approval-bridge/
docs/decisions/autosend-approval-bridge-spec.md:200:├── package.json              ← @ifos/autosend-approval-bridge; Node 20+
docs/decisions/autosend-approval-bridge-spec.md:206:│   ├── ifosWatcher.ts        ← Loop 1: watch /vault/<tenant>/pending-approvals/
docs/decisions/autosend-approval-bridge-spec.md:207:│   ├── cortextosWatcher.ts   ← Loop 2: watch ${CTX_FRAMEWORK_ROOT}/orgs/<org>/approvals/resolved/
docs/decisions/autosend-approval-bridge-spec.md:215:    │   └── bridge.test.ts        ← integration with mock cortextOS approval surface
docs/decisions/autosend-approval-bridge-spec.md:217:        └── approval-flow/        ← golden inputs/outputs for the 2 loops
docs/decisions/autosend-approval-bridge-spec.md:226:Adding `autosend_approval_mappings` table requires:
docs/decisions/autosend-approval-bridge-spec.md:231:Total schema impact: 1 new table; tenancy-invariants.md grows from 12 to 13 invariants (T13: autosend_approval_mappings tenant_slug + RLS), or we count this as covered by T1-T3 already (cleaner).
docs/decisions/autosend-approval-bridge-spec.md:241:| A3 | Telegram inline-button approve → `.approved` marker appears in IFOS pending-approvals dir within 200ms of `updateApproval` call | Integration test: simulate cortextOS resolved/ write → assert IFOS marker appears |
docs/decisions/autosend-approval-bridge-spec.md:243:| A5 | Bridge crash + restart: state rebuilds from filesystem scan + Postgres state table | Restart test: kill PM2 process mid-flight, restart, verify pending approvals resume |
docs/decisions/autosend-approval-bridge-spec.md:244:| A6 | RLS: bridge writing tenant-A's approval cannot leak tenant-B's pending markers | Tenancy audit T11 extension: cross-tenant marker read returns 0 |
docs/decisions/autosend-approval-bridge-spec.md:246:| A8 | Bridge state row in `autosend_approval_mappings` exists for every pending approval | Audit query: count(pending markers) == count(pending bridge state rows) |
docs/decisions/autosend-approval-bridge-spec.md:248:| A10 | Live VPS smoke: real Telegram chat receives approval message + button press routes back to marker | Founder Path A manual test on migration-test tenant |
docs/decisions/autosend-approval-bridge-spec.md:268:- **Building the IFOS-side `autosend_await_approval` polling loop** — already exists in `hook-helpers.sh` (Phase 3)
docs/decisions/autosend-approval-bridge-spec.md:270:- **iOS approval surface** — aspirational per `cortexos-primitive-status.md` §"Primitive 5"; v1.1+ concern
docs/decisions/autosend-approval-bridge-spec.md:280:| 1 | cortextOS approval API signature changes upstream | Pinned SHA `c21fbfe` for v1.0; bridge tests catch any drift at submodule bump time |
docs/decisions/autosend-approval-bridge-spec.md:284:| 5 | Race: operator approves the SAME approval twice (double-tap) | cortextOS updateApproval is idempotent on `approvalId`; second call no-ops |
docs/decisions/autosend-approval-bridge-spec.md:285:| 6 | RLS on autosend_approval_mappings forgotten | Migration includes ENABLE ROW LEVEL SECURITY; tenancy audit T2 catches if missing |
docs/decisions/autosend-approval-bridge-spec.md:293:- Webhook approval surface (alternative to Telegram polling) → v1.1+
docs/decisions/autosend-approval-bridge-spec.md:295:- iOS native approval app → v1.2+ when iOS surface enabled
docs/decisions/autosend-approval-bridge-spec.md:306:- Adds 1 tenant-data table (`autosend_approval_mappings`) → tenancy-invariants.md update OR considered covered by T1-T3 patterns
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:18:**Codex's framing:** "v1.0 tier semantics are internally contradictory. Lines 41-68 define four tiers and line 43 says every governed action falls into exactly one tier at execution, but lines 474-481 say v1.0 ships green + red only while orange approval is handled outside the policy pipeline. ... Canonical orange actions are described as v1.0-mitigated, but orange is not implemented in v1.0."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:23:- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:24:- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:26:**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:28:**Claude's recommendation (Day-11 update, post implementation-spec investigation):** **D1-B.** Investigation surfaced that the "~1 week extra" cost was overestimated — cortextOS Primitive 4 (`createApproval` + `updateApproval` in `packages/harness/cortextos/src/bus/approval.ts`) already implements the Telegram fan-out + button-press routing. IFOS-side work is a thin bridge: 2 file watchers + a small Postgres state table. Realistic effort: 2-3 days. See `docs/decisions/autosend-approval-bridge-spec.md` for the full implementation surface (10 acceptance criteria, 6 risks, 600 lines TypeScript scaffold + tests).

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc 'rg -n "''^[[:space:]]{2}[a-z0-9_]+:" agents/_shared/autosend-policy.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
29:  diagnostic_report_render:
35:  bullhorn_candidate_tag:
41:  bullhorn_note_internal:
47:  linkedin_profile_cache:
53:  xero_query_invoices:
59:  bullhorn_brief_read:
65:  operator_notify_telegram:
71:  janitor_run_complete:
77:  scout_run_complete:
83:  scribe_run_complete:
89:  concierge_run_complete:
95:  concierge_send_complete:
101:  cash_conductor_run_complete:
107:  consultant_feedback:
113:  validate_gate_a_fail:
119:  diagnostic_input_invalid:
125:  diagnostic_generator_empty:
131:  linkedin_cache_purge_fail:
137:  diagnostic_cleanup:
147:  bullhorn_candidate_dedupe:
154:  bullhorn_field_backfill:
161:  bullhorn_note_attach:
168:  bullhorn_note_append_summary:
175:  linkedin_connection_request:
182:  xero_reminder_draft_internal:
189:  bullhorn_note_draft_internal:
196:  bullhorn_scribe_field_write:
203:  accounting_reconciliation_write:
210:  concierge_email_draft:
221:  bullhorn_note_customer_visible:
229:  gmail_outlook_send_to_candidate:
236:  twilio_sms_send:
243:  calendar_invite_send:
250:  email_summary_to_customer:
257:  xero_reminder_send_customer:
264:  diagnostic_email_send:
271:  diagnostic_calendar_invite:
278:  linkedin_inmail_send:
285:  bullhorn_placement_terminate:
296:  xero_payment_initiate:
303:  stripe_charge_initiate:
310:  subscription_modify:
317:  legal_document_generate:
324:  pii_export_outside_tenant_geography:
331:  cross_tenant_data_send:
338:  unauthorised_adapter_send:
345:  send_to_blocked_recipient:
357:  approval_timeout: PT4H        # Default orange-tier approval window per §8 rule 5
358:  min_sample_rate: 100          # Tenants cannot set sample rate above 1-in-100 per §8 rule 6
359:  spot_check_queue_path: /vault/{tenant_slug}/spot-checks/   # Where autosend_spot_check_enqueue writes

exec
/bin/zsh -lc 'rg -n "sourcing|scout|source|report" agents/_shared/autosend-policy.yaml agents/_shared/escalation-codes.md docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:222:        source: IFOS-derived (entity ID at edit time; Bullhorn ID or IFOS slug)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:227:        source: IFOS-derived (agent's draft as produced; capped at 8192 chars)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:233:        source: IFOS-derived (consultant's final version at approve time; null when approved verbatim)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:239:        source: IFOS-derived (Levenshtein computed at insert; null when edited_text null)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:245:        source: IFOS-derived (operator UX action at approve/reject time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:251:        source: IFOS-derived (timestamped at operator action)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:255:        source: IFOS-derived (Gate-A fires recorded by validate.sh + hh_decision_action)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:257:          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:292:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:300:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:307:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:315:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:323:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:331:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:333:        Snapshot of mean voice classifier score across all Concierge messages for the candidate during the 30 days BEFORE placement close. Captures voice quality at the moment of commercial success — drives "did voice quality predict deal close" reporting + v2.0 LoRA pipeline label generation.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:342:    source: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:386:      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:63:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:66:          - Sourcing Scout: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:78:        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:81:          - Sourcing Scout: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:88:          LinkedIn profile URL. Pattern enforced by trigger. Set by Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:89:          Scout from match; Janitor uses for dedup (stronger match signal
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
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:280:#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:290:#   - Sourcing Scout candidate: R → R+W (writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:291:#     from multi-source aggregation — v0.3 amendment)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:293:#   - Sourcing Scout opportunity: none → R (reads opportunity context for ICP)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:346:  #   gets R on linkedin_url (entity-level default), not the broader Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:347:  #   Scout R+W. Implementation: cycle.sh + hh_decision_action records which
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:414:  sourcing_scout:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:416:    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:417:    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
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
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:535:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:540:      - Sourcing Scout (R+W) # v0.3 UPGRADED — writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:543:      v0.3 upgrades Sourcing Scout (writes proposed-candidate rows from
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:544:      multi-source aggregation) + Concierge (writes lifecycle-state and
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:548:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:552:      - Sourcing Scout (R+W) # v0.3 UPGRADED — same pattern as candidate
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:562:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:566:      Conductor for chase drafts; Sourcing Scout for per-candidate
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:572:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:577:      Diagnostic + Sourcing Scout also read tone_rules for their
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
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:714:    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:715:    # Scout add W to write own retraining edits; Diagnostic remains none)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:720:    sourcing_scout: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:727:    sourcing_scout: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:734:    sourcing_scout: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:845:      accumulates ≥30 reports (W4-polish trigger). v0.3 is silent on the
agents/_shared/escalation-codes.md:3:**Status:** Reference — single source of truth for `ESC_*` codes used by any agent. Wired into `_shared/hook-helpers.sh` (Phase 3).
agents/_shared/escalation-codes.md:31:Source: `docs/decisions/autosend-safety-policy.md` §5
agents/_shared/escalation-codes.md:57:Source: `docs/architecture/vault-concurrency.md` §6
agents/_shared/escalation-codes.md:95:Source: `docs/decisions/bullhorn-integration-path.md` §4.5 + §6
agents/_shared/escalation-codes.md:106:Source: `docs/architecture/agent-bundle-renderer-design.md` §4
agents/_shared/escalation-codes.md:118:Source: master brief §8.1 Change 3 lines 585-592
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:158:- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
agents/_shared/escalation-codes.md:186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
agents/_shared/escalation-codes.md:192:Source: derived from operational discipline + sequencing-target §5
agents/_shared/escalation-codes.md:238:Source: derived from v1.0 agent.md adapter references (Bullhorn, Reed, CV-Library, LinkedIn, Gmail, Outlook/MS Graph, Xero, Open Banking)
agents/_shared/escalation-codes.md:257:- **Severity:** **blocking** — Sourcing Scout enters degraded mode (no profile fetches; cached only)
agents/_shared/escalation-codes.md:262:- **Recovery:** founder reauthenticates LinkedIn via Sourcing Scout admin flow
agents/_shared/escalation-codes.md:308:Source: derived from v1.0 agent.md adapter call sites
agents/_shared/escalation-codes.md:339:Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:395:- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
agents/_shared/escalation-codes.md:398:- **Payload fields:** `entity_type`, `field_name`, `extracted_value`, `confidence_score`, `source` (e.g. `companies-house`, `linkedin`, `cv-pdf`), `agent_name`
agents/_shared/escalation-codes.md:402:- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
agents/_shared/escalation-codes.md:429:- **Payload fields:** `recipient_id_hash`, `dnc_list_source`, `dnc_match_reason` (e.g. `explicit_opt_out`, `previous_complaint`, `gdpr_objection`), `action_type_attempted`
agents/_shared/escalation-codes.md:466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
agents/_shared/autosend-policy.yaml:3:# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
agents/_shared/autosend-policy.yaml:29:  diagnostic_report_render:
agents/_shared/autosend-policy.yaml:49:    agent: sourcing-scout
agents/_shared/autosend-policy.yaml:77:  scout_run_complete:
agents/_shared/autosend-policy.yaml:79:    agent: sourcing-scout
agents/_shared/autosend-policy.yaml:110:    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
agents/_shared/autosend-policy.yaml:158:    reason: "Fills missing canonical schema fields from Companies House or LinkedIn enrichment; reversible PATCH; high-volume; source provenance logged in payload"
agents/_shared/autosend-policy.yaml:177:    agent: sourcing-scout
agents/_shared/autosend-policy.yaml:268:    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
agents/_shared/autosend-policy.yaml:280:    agent: sourcing-scout

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '25,85p'; nl -ba agents/_shared/autosend-policy.yaml | sed -n '170,184p'; nl -ba agents/_shared/autosend-policy.yaml | sed -n '274,282p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   274	    timeout: PT4H
   275	    reason: "Books intro call with prospect; reputation + scheduling friction"
   276	    irreversible: true
   277	
   278	  linkedin_inmail_send:
   279	    tier: orange
   280	    agent: sourcing-scout
   281	    timeout: PT4H
   282	    reason: "Outbound InMail (paid credit); cost-per-send; customer-facing"

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '48,100p'; nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '414,424p'; nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '532,546p'; nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '738,790p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
    81	          - Sourcing Scout: R+W
    82	
    83	      linkedin_url:
    84	        type: string
    85	        pattern: '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$'
    86	        required: false
    87	        notes: |
    88	          LinkedIn profile URL. Pattern enforced by trigger. Set by Sourcing
    89	          Scout from match; Janitor uses for dedup (stronger match signal
    90	          than name+email); Concierge reads for outreach context (NOT for
    91	          outbound — outreach via candidate.email or candidate.phone only).
    92	        source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
    93	        v1_0_agent_access:
    94	          - Sourcing Scout: R+W
    95	          - Janitor: R   # W only via dedup-merge action
    96	          - Concierge: R
    97	
    98	  contact:
    99	    v0_3_new_keys:
   100	      preferred_channel:
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
   532	      placement-related workflows).
   533	
   534	  candidate:
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
   546	
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
/bin/zsh -lc 'rg -n "blocked_recipients|auto_source_on_brief_create" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql agents/recruitment/sourcing-scout/agent.md -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
agents/recruitment/sourcing-scout/agent.md:3:**Status:** Pre-Build-Round-9-Bilateral-Applied (Day-20; W4 bilateral pass applied). All 3 R8 residuals confirmed closed by post-R8 commit `d1f4c53` (canonical schema-key block + webhook deferred to v1.1+ + Accepted criteria expanded). R9 adds: §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill); §4 Step 8 + Schema-key block rewrite for `blocked_recipients` (correctly cites the migration allowlist as canonical; v0.4-pending applies only to `auto_source_on_brief_create`). Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:6:- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist (line 397); canonical Postgres-backed v1.0 DNC source per ADR-002. YAML schema declaration deferred to future schema-doc audit (covers all pre-v0.3 allowlist keys not yet declared in YAML).
agents/recruitment/sourcing-scout/agent.md:7:- `tenant_adapters.config.auto_source_on_brief_create` — v0.4-supplement-pending (not yet in any allowlist); the Bullhorn-webhook auto-source trigger code path is blocked until v0.4 lands.
agents/recruitment/sourcing-scout/agent.md:20:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:39:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables `auto_source_on_brief_create`. v0.4-supplement-pending (config key not yet registered); webhook-trigger code path is BLOCKED until v0.4 supplement lands. v1.0 invocation is Brain UI button + Telegram only.
agents/recruitment/sourcing-scout/agent.md:113:     + DNC list from `tenant_adapters.config.blocked_recipients` (Postgres-
agents/recruitment/sourcing-scout/agent.md:195:   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
agents/recruitment/sourcing-scout/agent.md:200:     v0.4-pending status applies ONLY to `auto_source_on_brief_create`
agents/recruitment/sourcing-scout/agent.md:201:     (the webhook auto-source trigger config), NOT to `blocked_recipients`.
agents/recruitment/sourcing-scout/agent.md:203:     Future schema-doc audit will land `blocked_recipients` declaration
agents/recruitment/sourcing-scout/agent.md:256:- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
agents/recruitment/sourcing-scout/agent.md:343:| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
agents/recruitment/sourcing-scout/agent.md:364:| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |

exec
/bin/zsh -lc 'rg -n "ESC_VOICE_DRIFT|ESC_BULLHORN_AUTH|ESC_FIELD_CONFIDENCE_LOW|ESC_PROFILE_INCOMPLETE" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
97:#### `ESC_BULLHORN_AUTH`
120:#### `ESC_VOICE_DRIFT`
170:#### `ESC_VOICE_DRIFT_TENANT`
172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)

codex
REJECTED

1. Schema-before-code violation for `tenant_adapters.config.blocked_recipients`. Lines 6, 20, 113, 195-203, 256, 343, and 364 make this key load-bearing, but it is not declared in `vertical-schema.yaml` or the v0.2/v0.3 supplements; it only appears in `migrations/v0.2-to-v0.3.sql` line 397 as an allowlist entry. Line 20 also claims this is “interpreted per v0.3 supplement,” but the supplement does not define it. Add a schema supplement entry for `blocked_recipients` before this agent reads it, or block the DNC path until that schema lands.

2. Header status is not an allowed honest-signal status and conflicts with §9. Line 3 says `Status: Pre-Build-Round-9-Bilateral-Applied`, while line 356 says `Status: Proposed`; the top-level skill requires status to be accurate as Proposed/Accepted/In Force, and the agent-bundle skill requires the header status to be consistent with content. Change the header to `Status: Proposed` and move round/remediation history into a separate note.
tokens used
76,711
REJECTED

1. Schema-before-code violation for `tenant_adapters.config.blocked_recipients`. Lines 6, 20, 113, 195-203, 256, 343, and 364 make this key load-bearing, but it is not declared in `vertical-schema.yaml` or the v0.2/v0.3 supplements; it only appears in `migrations/v0.2-to-v0.3.sql` line 397 as an allowlist entry. Line 20 also claims this is “interpreted per v0.3 supplement,” but the supplement does not define it. Add a schema supplement entry for `blocked_recipients` before this agent reads it, or block the DNC path until that schema lands.

2. Header status is not an allowed honest-signal status and conflicts with §9. Line 3 says `Status: Pre-Build-Round-9-Bilateral-Applied`, while line 356 says `Status: Proposed`; the top-level skill requires status to be accurate as Proposed/Accepted/In Force, and the agent-bundle skill requires the header status to be consistent with content. Change the header to `Status: Proposed` and move round/remediation history into a separate note.
