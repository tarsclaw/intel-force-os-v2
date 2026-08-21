Reading prompt from stdin...
OpenAI Codex v0.132.0
--------
workdir: /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
model: gpt-5.5
provider: openai
approval: never
sandbox: workspace-write [workdir, /tmp, $TMPDIR]
reasoning effort: none
reasoning summaries: none
session id: 019eb180-8e35-7e11-9094-d6dc50a406ae
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

**Status:** Proposed.
**Build state:** Day-20 W4 bilateral pass + R19 substantive fix applied. R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`. R19 (2026-05-24): adds `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Awaits Q1 LOI + Bullhorn Sub-decisions A+B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + Reed + CV-Library commercial signups + W9 build slice.
**Reading-discipline note (added 2026-06-03 per CC + Concierge + Janitor + Scribe precedent):** this `agent.md` is the **CONTRACT** that the W9 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `4e62d06` + `ebd9b40` + `6f1e07c` + `fe1423e` + `3be4bb5` per W5 Day-33); they carry `TODO(W9)` markers throughout that the W9 build slice replaces with live implementation matching the contract below. **VENDOR DELTA**: this `agent.md` §1 output contract describes "FOUR sources" (Bullhorn + LinkedIn + Reed + CV-Library); the deployed SKELETON operates against THREE active sources per the v1.0 LinkedIn caveat at lines 6-8. cycle.sh Step 4 is an explicit no-op audit row (`linkedin_search_skipped`) per the Janitor Step 7 NO-OP pattern. **REED + CV-LIBRARY PACKAGE DELTA**: tools.yaml declares `reed_*` + `cvlibrary_*` capabilities with `package_status:scaffold_pending_phase_8` — the `@ifos/reed` + `@ifos/cv-library` MCP packages don't exist yet; they land in Phase 8 of this marathon /goal (sibling phase). **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON `cycle.sh` emits only the minimal trigger/output markers (`session_start`, `brief_ingested`, `auth_refresh_complete`, `bullhorn_passive_query`, `linkedin_search_skipped`, `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `rationale_generation`, `scout_report`, `scout_run_complete`).** Pure read+report agent — no yellow/orange/red action_types; only state-changing action is `sourcing_scout_cleanup` (green; QUEUED for W9). The SKELETON `context.sh` uses **env-var fallbacks** today even though `bullhorn_corporation_id` is v0.4-allowlisted (LANDED + LIVE on VPS commit `a1bbcf6`) and `blocked_recipients` is v0.3-allowlisted (LIVE on VPS) — canonical SELECT path wiring lands W9 alongside `@ifos/bullhorn` + `@ifos/reed` + `@ifos/cv-library` refresh integrations. Don't read agent.md as a description of running code; read it as the spec the W9 build slice implements after the LinkedIn v1.0 deferral and the Reed/CV-Library package scaffolds are acknowledged.

**v1.0 readiness caveat — LinkedIn deep-data vendor (added 2026-06-02):** the original v1.0 design listed **Proxycurl** as the LinkedIn deep-data source (one of FOUR sources in the §1 output contract). **Proxycurl was shut down in 2025** following LinkedIn's January 2025 lawsuit against Nubela (Proxycurl's parent; ~50% of their revenue came from LinkedIn scraping; see https://nubela.co/blog/goodbye-proxycurl/). The successor product **NinjaPear** (same team) explicitly does NOT carry LinkedIn data — it is a B2B competitive-intelligence platform sourced from non-LinkedIn channels. Net: the LinkedIn-via-Proxycurl path described throughout §1 + §3 + §4 Step 4 + §6 ESC routing **does not have a legally-clear vendor as of 2026-06-02**.

**v1.0 disposition (per founder decision 2026-06-02):** LinkedIn deep-data is **DEFERRED to v1.1+**. v1.0 Sourcing Scout operates against **THREE active sources** (Bullhorn-candidate passive-match + Reed + CV-Library), not four. The §1 output contract's "5-15 candidates" Gate A target is preserved; Reed + CV-Library + Bullhorn passive-match combined are sufficient at v1.0 pilot scale (≤3 tenants). LinkedIn-vendor selection for v1.1+ takes place at W8-9 when the Sourcing Scout build slice forces the choice and we have more clarity on the post-lawsuit legal landscape (candidate vendors: Lix, Phantombuster, Apify with LinkedIn-aware contracts, or LinkedIn's own Sales Navigator enterprise API at much higher cost). Until that decision: §4 Step 4 (LinkedIn search via Proxycurl) is a NO-OP in v1.0; the ranked-list assembly at Step 6 weights the 3 active sources accordingly; the §3 output template still shows the LinkedIn row but populates it as "deferred to v1.1+; vendor pending" rather than a scraped result. Gate B target (≥6 of 10 advance per ULTRAPLAN A5 line 553) unchanged at v1.0 — the marginal contribution of LinkedIn deep-data is unknown until pilot data lands; v1.1+ vendor selection partly informed by whether Gate B underperforms without it.

**Schema-key references:**
- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 398; allowlist block lines 396-409); canonical Postgres-backed v1.0 DNC source per ADR-002. Declared in `vertical-schema.v0.3-supplement.yaml` lines 810-827 (R19 added this declaration; no longer deferred).
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
     `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 398; block lines 396-409).
     v0.4-pending status applies ONLY to `auto_source_on_brief_create`
     (the webhook auto-source trigger config), NOT to `blocked_recipients`.
     Postgres-backed per ADR-002 vault/Postgres split — NOT vault markdown.
     `blocked_recipients` is now declared in `vertical-schema.v0.3-supplement.yaml`
     lines 810-827.)
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
    → if any condition fails: write partial draft to /tmp, then emit the
      mandatory audit row hh_decision_action("validate_gate_a_fail",
      "brief:<id>", payload_hash, "ESC_AGENT_OUTPUT_SHAPE; <failed_condition>")
      — output-shape violation per catalogue line 184 (distinct from
      ESC_SCHEMA_VIOLATION, reserved for vertical-schema field-constraint
      violations at write time; audit row mandatory per master brief §8.1
      Change 2 + autosend-policy.yaml lines 119-123) — then abort (exit 1)
      BEFORE the scout_report row below
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
On any Gate A failure, `validate.sh` writes the partial draft to `/tmp` and emits the mandatory `hh_decision_action("validate_gate_a_fail", ...)` audit row carrying the ESC code (per master brief §8.1 Change 2 + autosend-policy.yaml lines 119-123) BEFORE aborting; operator review.

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
- **Voice-drift detection (classifier-only):** per `vertical-schema.v0.3-supplement.yaml` lines 584-593 + 715-724, Sourcing Scout has `recent_edit` access of **W** (writes its rationale drafts) but **not R**, so it does NOT read consultant edit history via `hh_load_recent_edits`. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. The cron — not Sourcing Scout — reads edit history for analytics + canary threshold tuning.

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
| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. A new ADR (number assigned at authoring time; not ADR-006 — that's Diagnostic Gate A) at W9 build start documenting the source-abstraction interface. |
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

exec
/bin/zsh -lc "rg --files | rg '("'^docs/|''^agents/_shared/|''^migrations/|autosend|vertical-schema|sourcing-scout)'"'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
packages/utilities/autosend-bridge-telegram/src/index.ts
packages/utilities/autosend-bridge-telegram/src/message-format.ts
packages/utilities/autosend-bridge-telegram/src/bridge.ts
packages/utilities/autosend-bridge-telegram/src/types.ts
packages/utilities/autosend-bridge-telegram/src/errors.ts
packages/utilities/autosend-bridge-telegram/vitest.config.ts
packages/utilities/autosend-bridge-telegram/tsconfig.json
packages/utilities/autosend-bridge-telegram/tsup.config.ts
packages/utilities/autosend-bridge-telegram/package.json
packages/utilities/autosend-bridge-telegram/README.md
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts
packages/utilities/autosend-bridge-telegram/tests/test-helpers.ts
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/verticals/recruitment/migrations/v0.4-to-v0.5.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.5-to-v0.4.sql
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
agents/_shared/README.md
docs/incidents/2026-06-01-intelforce-ai-email-outage.md
logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md
docs/specs/ULTRAPLAN.md
docs/specs/_archive-build-handoff.md
docs/specs/PRODUCT-SPEC.md
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
logs/codex-ratification/20260610T122729Z-36890/agents_recruitment_sourcing-scout_agent-md.prompt.md
logs/codex-ratification/20260610T122729Z-36890/agents_recruitment_sourcing-scout_agent-md.output.md
docs/runbooks/day-4-provisioning.md
docs/runbooks/operational-hygiene-protocol.md
docs/runbooks/tenant-lifecycle.md
docs/runbooks/pii-purge-operational-pattern.md
docs/_supplementary/PRD-autonomous-agent.md
docs/_supplementary/build-plan-original.md
docs/_supplementary/README.md
docs/_supplementary/strategic-plan.md
docs/_supplementary/planning-phase-brief.md
docs/_supplementary/technical-strategy-v2.md
docs/_supplementary/execution-plan.md
logs/codex-ratification/round-3-remediation/docs_decisions_autosend-approval-bridge-spec-md.output.md
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md
docs/artefacts/diagnostic-hays-plc-2026-05-24.md
docs/build-brief/00-MASTER-BRIEF.md
docs/architecture/tenancy-invariants.md
docs/architecture/architecture-cohesion-review.md
docs/architecture/agent-bundle-renderer-design.md
docs/architecture/cortexos-kb-surface-investigation.md
docs/architecture/cortexos-primitive-status.md
docs/architecture/vault-concurrency.md
docs/architecture/second-brain-design.md
docs/operations/goal-overnight-2026-05-31.md
docs/operations/handoff-2026-06-05-location-shift.md
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md
docs/operations/bullhorn-outreach-emails.md
docs/operations/goal-week-4-track-1.md
docs/operations/w4-bilateral-pass-6-agent-md.md
docs/operations/parallel-agent-build-method.md
docs/operations/w4-day-20-founder-runbook.md
docs/operations/oauth-sandbox-app-setup-runbook.md
docs/operations/goal-w4-day-26-2026-06-01.md
docs/operations/codex-ratification-guide.md
docs/operations/codex-round-2-handoff.md
docs/operations/codex-round-2-remediation-prompt.md
docs/operations/founder-api-signups-2026-06-03.md
docs/operations/local-dev-db-setup.md
docs/operations/pending-goal-w6-d36-cash-conductor-prep.md
docs/operations/goal-week-5-execution-plan.md
docs/operations/codex-ratification-execution-plan.md
docs/operations/session-retrospective-2026-06-03.md
docs/operations/codex-round-2-autonomous-prompt.md
docs/operations/goal-week-3-polish-and-scaffold.md
docs/operations/session-init-w7-p3-reconciliation.md
docs/operations/decision-log.md
docs/operations/goal-week-6-execution-plan.md
docs/operations/seedlegals-engagement-queries.md
docs/operations/goal-option-c-diagnostic-end-to-end.md
docs/operations/founder-manual-playbook-2026-05-31.md
docs/operations/founder-playbook-2026-06-03-granola-and-v04.md
docs/operations/founder-legal-setup-guide.md
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md
docs/decisions/brain-ui-scope.md
docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md
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
docs/decisions/2026-05-31-d1-founder-decision.md
docs/decisions/sequencing-target.md
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md
docs/decisions/bullhorn-integration-path.md
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md
docs/design-mockups/brain-ui-decisions-feed-light-v01.html
docs/RISK-REGISTER.md
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
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-v0-2-supplement-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-approval-bridge-spec-md.output.md
agents/recruitment/sourcing-scout/cleanup.sh
agents/recruitment/sourcing-scout/fixtures/99-dnc-bulk-filter.yaml
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml
agents/recruitment/sourcing-scout/fixtures/02-edge-case-degraded-sources.yaml
agents/recruitment/sourcing-scout/cycle.sh
agents/recruitment/sourcing-scout/README.md
agents/recruitment/sourcing-scout/tools.yaml
agents/recruitment/sourcing-scout/bin/render-rationale.sh
agents/recruitment/sourcing-scout/bin/parse-brief.sh
agents/recruitment/sourcing-scout/bin/render-scout-report.sh
agents/recruitment/sourcing-scout/bin/fuzzy-match.sh
agents/recruitment/sourcing-scout/validate.sh
agents/recruitment/sourcing-scout/context.sh
agents/recruitment/sourcing-scout/agent.md
docs/features/agent-build/00-ORCHESTRATOR.md
docs/features/agent-build/01-LAUNCH.md
docs/features/agent-build/STATUS.md
docs/features/agent-build/02-specs/spec-001-janitor.md
docs/features/agent-build/02-specs/spec-004-concierge.md
docs/features/agent-build/02-specs/spec-002-scribe.md
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md
docs/features/agent-build/02-specs/_TEMPLATE.md
docs/features/agent-build/03-implementation/sourcing-scout-summary.md

exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '1,430p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
     1	# Sourcing Scout — request-response passive sourcing
     2	
     3	**Status:** Proposed.
     4	**Build state:** Day-20 W4 bilateral pass + R19 substantive fix applied. R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`. R19 (2026-05-24): adds `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Awaits Q1 LOI + Bullhorn Sub-decisions A+B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + Reed + CV-Library commercial signups + W9 build slice.
     5	**Reading-discipline note (added 2026-06-03 per CC + Concierge + Janitor + Scribe precedent):** this `agent.md` is the **CONTRACT** that the W9 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `4e62d06` + `ebd9b40` + `6f1e07c` + `fe1423e` + `3be4bb5` per W5 Day-33); they carry `TODO(W9)` markers throughout that the W9 build slice replaces with live implementation matching the contract below. **VENDOR DELTA**: this `agent.md` §1 output contract describes "FOUR sources" (Bullhorn + LinkedIn + Reed + CV-Library); the deployed SKELETON operates against THREE active sources per the v1.0 LinkedIn caveat at lines 6-8. cycle.sh Step 4 is an explicit no-op audit row (`linkedin_search_skipped`) per the Janitor Step 7 NO-OP pattern. **REED + CV-LIBRARY PACKAGE DELTA**: tools.yaml declares `reed_*` + `cvlibrary_*` capabilities with `package_status:scaffold_pending_phase_8` — the `@ifos/reed` + `@ifos/cv-library` MCP packages don't exist yet; they land in Phase 8 of this marathon /goal (sibling phase). **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON `cycle.sh` emits only the minimal trigger/output markers (`session_start`, `brief_ingested`, `auth_refresh_complete`, `bullhorn_passive_query`, `linkedin_search_skipped`, `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `rationale_generation`, `scout_report`, `scout_run_complete`).** Pure read+report agent — no yellow/orange/red action_types; only state-changing action is `sourcing_scout_cleanup` (green; QUEUED for W9). The SKELETON `context.sh` uses **env-var fallbacks** today even though `bullhorn_corporation_id` is v0.4-allowlisted (LANDED + LIVE on VPS commit `a1bbcf6`) and `blocked_recipients` is v0.3-allowlisted (LIVE on VPS) — canonical SELECT path wiring lands W9 alongside `@ifos/bullhorn` + `@ifos/reed` + `@ifos/cv-library` refresh integrations. Don't read agent.md as a description of running code; read it as the spec the W9 build slice implements after the LinkedIn v1.0 deferral and the Reed/CV-Library package scaffolds are acknowledged.
     6	
     7	**v1.0 readiness caveat — LinkedIn deep-data vendor (added 2026-06-02):** the original v1.0 design listed **Proxycurl** as the LinkedIn deep-data source (one of FOUR sources in the §1 output contract). **Proxycurl was shut down in 2025** following LinkedIn's January 2025 lawsuit against Nubela (Proxycurl's parent; ~50% of their revenue came from LinkedIn scraping; see https://nubela.co/blog/goodbye-proxycurl/). The successor product **NinjaPear** (same team) explicitly does NOT carry LinkedIn data — it is a B2B competitive-intelligence platform sourced from non-LinkedIn channels. Net: the LinkedIn-via-Proxycurl path described throughout §1 + §3 + §4 Step 4 + §6 ESC routing **does not have a legally-clear vendor as of 2026-06-02**.
     8	
     9	**v1.0 disposition (per founder decision 2026-06-02):** LinkedIn deep-data is **DEFERRED to v1.1+**. v1.0 Sourcing Scout operates against **THREE active sources** (Bullhorn-candidate passive-match + Reed + CV-Library), not four. The §1 output contract's "5-15 candidates" Gate A target is preserved; Reed + CV-Library + Bullhorn passive-match combined are sufficient at v1.0 pilot scale (≤3 tenants). LinkedIn-vendor selection for v1.1+ takes place at W8-9 when the Sourcing Scout build slice forces the choice and we have more clarity on the post-lawsuit legal landscape (candidate vendors: Lix, Phantombuster, Apify with LinkedIn-aware contracts, or LinkedIn's own Sales Navigator enterprise API at much higher cost). Until that decision: §4 Step 4 (LinkedIn search via Proxycurl) is a NO-OP in v1.0; the ranked-list assembly at Step 6 weights the 3 active sources accordingly; the §3 output template still shows the LinkedIn row but populates it as "deferred to v1.1+; vendor pending" rather than a scraped result. Gate B target (≥6 of 10 advance per ULTRAPLAN A5 line 553) unchanged at v1.0 — the marginal contribution of LinkedIn deep-data is unknown until pilot data lands; v1.1+ vendor selection partly informed by whether Gate B underperforms without it.
    10	
    11	**Schema-key references:**
    12	- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 398; allowlist block lines 396-409); canonical Postgres-backed v1.0 DNC source per ADR-002. Declared in `vertical-schema.v0.3-supplement.yaml` lines 810-827 (R19 added this declaration; no longer deferred).
    13	- `tenant_adapters.config.auto_source_on_brief_create` — v0.4-supplement-pending (not yet in any allowlist); the Bullhorn-webhook auto-source trigger code path is blocked until v0.4 lands.
    14	**Date:** 2026-05-24.
    15	**Author:** Founder (Maddox) + Claude Code.
    16	**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
    17	**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
    18	**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.
    19	
    20	---
    21	
    22	## §1 — Output contract (one-paragraph screenshot)
    23	
    24	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    25	
    26	> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
    27	
    28	---
    29	
    30	## §2 — Invocation surface
    31	
    32	### Brain UI (v1.0 primary)
    33	
    34	Brain UI v1.0 "Source candidates" button on any brief detail page → POST internal API → Sourcing Scout webhook.
    35	
    36	### Telegram command (v1.0)
    37	
    38	```
    39	@ifos_bot scout <brief-id-or-slug>
    40	@ifos_bot scout --description "Senior React engineer, London, £120k, hybrid"
    41	```
    42	
    43	### Webhook (DEFERRED to v1.1+)
    44	
    45	Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables `auto_source_on_brief_create`. v0.4-supplement-pending (config key not yet registered); webhook-trigger code path is BLOCKED until v0.4 supplement lands. v1.0 invocation is Brain UI button + Telegram only.
    46	
    47	### CLI (v1.0 — debugging)
    48	
    49	```bash
    50	ifosctl sourcing-scout source --tenant <slug> --brief-id <id>
    51	ifosctl sourcing-scout source --tenant <slug> --description "<free-text>"
    52	```
    53	
    54	### v1.1+ surfaces (deferred)
    55	
    56	- Night Sourcer Tier-1 always-on (Brain UI dashboard; cortextOS primitive #6)
    57	- Bulk-source mode (`--brief-list briefs.csv`)
    58	- Refresh-source mode (re-source against the same brief 30 days later)
    59	
    60	---
    61	
    62	## §3 — Output shape
    63	
    64	One output per invocation. Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md`. Structure:
    65	
    66	```markdown
    67	# Sourcing Scout — <Brief title>
    68	**Generated:** <ISO-date>  **Brief ID:** <Bullhorn-brief-id>  **Tenant:** <slug>
    69	**Sources searched:** Bullhorn ATS + LinkedIn (Proxycurl) + Reed + CV-Library
    70	**Aggregate candidates:** <N> (top 5-15 ranked)
    71	
    72	## Brief context
    73	<2-3 sentences summarising the role from the brief input>
    74	
    75	## Ranked candidates
    76	
    77	### 1. <Candidate name> — confidence 0.92
    78	**Source:** Bullhorn (passive match) | **Contact:** <method + verified>
    79	**Match rationale:**
    80	<≥50 words explaining why this candidate is a match — references brief
    81	requirements + candidate background; cites Bullhorn placement history,
    82	LinkedIn current role, or other source-specific evidence.>
    83	**Risk flags:** <e.g., "active with placement at competitor agency 2024";
    84	"prefers contract not perm per Bullhorn note">
    85	**Profile links:** [Bullhorn](url) | [LinkedIn](url)
    86	
    87	### 2. <Candidate name> — confidence 0.88
    88	...
    89	
    90	(5-15 candidates total)
    91	
    92	## Source breakdown
    93	| Source | Candidates contributed | Avg confidence | Rate-limit budget remaining |
    94	|---|---|---|---|
    95	| Bullhorn ATS | <N> | <score> | n/a (no quota) |
    96	| LinkedIn (Proxycurl) | <N> | <score> | <remaining> |
    97	| Reed | <N> | <score> | <remaining> |
    98	| CV-Library | <N> | <score> | <remaining> |
    99	
   100	## Diagnostic + exception list
   101	- <Any source failures (e.g., "Reed API 429; retried once; 3 candidates lost")>
   102	- <Any "do not contact" filter hits>
   103	- <Any low-confidence candidates discarded (below 0.5)>
   104	```
   105	
   106	Per `decision_log`: one row per source query + one row per candidate proposed + one final aggregate row.
   107	
   108	Voice-classified content: only the per-candidate match rationale (Step 9). Voice classifier ≥0.75 against tenant style. Rationale that fails after 3 retries → ESC_VOICE_DRIFT → candidate dropped from list + flagged in exception list.
   109	
   110	---
   111	
   112	## §4 — Workflow
   113	
   114	11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
   115	
   116	```
   117	0. Session start
   118	   → context.sh hydrates: tenant config + multi-source auth + voice corpus
   119	     + DNC list from `tenant_adapters.config.blocked_recipients` (Postgres-
   120	     backed per ADR-002 vault/Postgres split; canonical v0.1 + v0.2 + v0.3
   121	     registered config key)
   122	   → hh_decision_trigger("session_start", "scout <brief-id-or-slug>")
   123	
   124	1. Brief ingestion
   125	   → if brief_id: bullhorn.get_brief(brief_id) → fetch fields
   126	   → if free-text description: LLM parse → extract role / location / sector
   127	     / seniority / day-rate-band / must-haves / nice-to-haves
   128	   → ESC_BRIEF_AMBIGUITY if extraction yields <3 key dimensions (per
   129	     escalation-codes.md §2.5 — canonical code for under-resolvable briefs)
   130	   → hh_decision_output("brief_ingested", "<brief_id_or_slug>",
   131	     "key_dims:<N>")
   132	
   133	2. Multi-source auth refresh
   134	   → bullhorn (read-only); LinkedIn/Proxycurl; Reed; CV-Library
   135	   → per-source auth failure fires the catalogue-specified ESC code with
   136	     its catalogue-specified degraded-mode behavior:
   137	     - ESC_BULLHORN_AUTH (catalogue §2.3): blocking → Sourcing Scout
   138	       enters degraded mode per catalogue ("drafts-only, no auto-send" —
   139	       Sourcing-Scout-specific interpretation: skip Bullhorn source +
   140	       continue with other 3 sources, since Sourcing Scout has no
   141	       auto-send path of its own; the "drafts-only" framing maps to
   142	       "report-only with Bullhorn data omitted from the sourcing set")
   143	     - ESC_LINKEDIN_AUTH (catalogue §2.7): blocking → degraded mode
   144	       (Sourcing Scout: cached LinkedIn search only; live profile fetches
   145	       skipped)
   146	     - ESC_REED_AUTH (catalogue §2.7): blocking → degraded mode (cached
   147	       Reed search results only)
   148	     - ESC_CVLIBRARY_AUTH (catalogue §2.7): blocking → degraded mode
   149	       (cached CV-Library search only)
   150	   → if MULTIPLE sources are in degraded mode AND the remaining live
   151	     sources cannot produce ≥5 candidates: ESC_AGENT_OUTPUT_SHAPE +
   152	     return partial report with exception note (Gate A floor violated)
   153	   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
   154	     "sources_ok:<N>/4; degraded:<list>")
   155	
   156	3. Bullhorn passive-match query
   157	   → bullhorn.search_candidates(filter=brief_key_dimensions,
   158	     status='active', date_last_modified_at < now() - interval '90 days')
   159	     — "passive" is a derived state (active candidate not recently
   160	     modified); NOT a vertical-schema enum value. The schema defines
   161	     candidate.status as [active, archived, do_not_contact, placed,
   162	     contractor_promoted] (line 84-88) and candidate.date_last_modified_at
   163	     as the recency field (line 100). Passive-match queries filter on
   164	     modification recency within the active set.
   165	   → up to 30 candidates fetched (will rank+filter later)
   166	   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
   167	   → hh_decision_output("bullhorn_query", "brief:<id>", "results:<N>")
   168	
   169	4. LinkedIn search (via Proxycurl)
   170	   → proxycurl.search_people(query=brief_key_dimensions, location=brief_location,
   171	     industry=brief_sector)
   172	   → up to 30 profiles
   173	   → cache 1h per (query, location, sector) tuple
   174	   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
   175	   → hh_decision_output("linkedin_query", "brief:<id>", "results:<N>")
   176	
   177	5. Reed query
   178	   → reed.search_candidates(query=brief_dimensions, location, salary_band)
   179	   → up to 30 candidates
   180	   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
   181	     (payload.upstream='reed')
   182	   → hh_decision_output("reed_query", "brief:<id>", "results:<N>")
   183	
   184	6. CV-Library query
   185	   → cvlibrary.search_candidates(query, location, salary_band)
   186	   → up to 30 candidates
   187	   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
   188	     (payload.upstream='cv-library')
   189	   → hh_decision_output("cvlibrary_query", "brief:<id>", "results:<N>")
   190	
   191	7. Aggregate + dedupe
   192	   → merge all sources into single candidate set
   193	   → dedupe across sources by (name + email) OR (name + phone) OR
   194	     (LinkedIn URL) — same fuzzy matcher as Janitor (confidence ≥0.85)
   195	   → annotate each row with source provenance (e.g., "from Bullhorn + LinkedIn
   196	     match" if found in both)
   197	   → hh_decision_output("aggregate_dedupe", "brief:<id>",
   198	     "pre_dedupe:<N>; post_dedupe:<N>")
   199	
   200	8. "Do not contact" filter (pre-outbound sourcing filter; NOT outbound refusal)
   201	   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
   202	     (concept referenced by autosend-policy.yaml red-tier
   203	     `send_to_blocked_recipient` action_type + ESC_DNC_FILTER_HIT catalogue
   204	     §2.10; the config key IS registered in the canonical authority
   205	     `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 398; block lines 396-409).
   206	     v0.4-pending status applies ONLY to `auto_source_on_brief_create`
   207	     (the webhook auto-source trigger config), NOT to `blocked_recipients`.
   208	     Postgres-backed per ADR-002 vault/Postgres split — NOT vault markdown.
   209	     `blocked_recipients` is now declared in `vertical-schema.v0.3-supplement.yaml`
   210	     lines 810-827.)
   211	   → remove any candidate matching any DNC identifier from the sourcing list
   212	   → log dropped candidates to exception list in §3 output
   213	   → NOTE: ESC_DNC_FILTER_HIT is catalogue §2.10 reserved for OUTBOUND SEND
   214	     REFUSAL specifically. Sourcing Scout filters DNC matches AT SOURCING
   215	     TIME (pre-outbound); no outbound send attempt occurs. v0.3 disposition:
   216	     log DNC drops in exception list only; no ESC fire. W4-polish backlog:
   217	     add ESC_SOURCING_DNC_FILTER for the pre-outbound case.
   218	   → hh_decision_output("dnc_filter", "brief:<id>",
   219	     "dropped:<N>; kept:<N>")
   220	
   221	9. LLM ranking + rationale generation (per candidate)
   222	   → for top 15 by source-aggregated confidence: generate per-candidate
   223	     rationale ≥50 words
   224	   → prompt = (brief context + candidate profile + voice corpus + tone rules)
   225	   → voice classifier scores rationale (≥0.75)
   226	   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
   227	     from final list
   228	   → hh_decision_output("candidate_proposed", "candidate:<bullhorn_id|external_ref>",
   229	     "source:<bullhorn|linkedin|reed|cvlibrary>; confidence:<N>; voice_score:<N>; included:<bool>") — emitted PER CANDIDATE per §3 contract (one row per candidate proposed; dropped candidates also get a row with included=false + drop_reason)
   230	
   231	10. Output assembly + Gate A validation
   232	    → ensure 5-15 candidates remaining after Step 9
   233	    → ensure each has working contact method (email validated via simple
   234	      regex + domain MX check; phone validated via E.164 format)
   235	    → ensure each rationale ≥50 words
   236	    → if any condition fails: write partial draft to /tmp, then emit the
   237	      mandatory audit row hh_decision_action("validate_gate_a_fail",
   238	      "brief:<id>", payload_hash, "ESC_AGENT_OUTPUT_SHAPE; <failed_condition>")
   239	      — output-shape violation per catalogue line 184 (distinct from
   240	      ESC_SCHEMA_VIOLATION, reserved for vertical-schema field-constraint
   241	      violations at write time; audit row mandatory per master brief §8.1
   242	      Change 2 + autosend-policy.yaml lines 119-123) — then abort (exit 1)
   243	      BEFORE the scout_report row below
   244	    → write Markdown report to vault path per §3
   245	    → hh_decision_output("scout_report", report_path, "N candidates from M sources")
   246	
   247	11. Session close + notification
   248	    → operator notification per invocation source (Brain UI: in-app
   249	      notification; Telegram: reply with report path; webhook: bus event back)
   250	    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
   251	      "N=<N> sources_used=<M>")
   252	    → exit code 0
   253	```
   254	
   255	---
   256	
   257	## §5 — Gates
   258	
   259	### Gate A — validate.sh (hard-fail before action)
   260	
   261	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
   262	
   263	- **"5–15 candidates returned per brief"** (count within range)
   264	- **"each has a working contact method"** (email format + MX check OR E.164 phone OR LinkedIn URL OR Bullhorn bullhorn_id-with-contact)
   265	- **"each has rationale ≥ 50 words"**
   266	- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
   267	- All rationales pass voice classifier ≥0.75
   268	- No PII outside firm boundary in rationale text → fires `ESC_PII_LEAKAGE_RISK` (BLOCKING per catalogue §2.5 lines 148-154; halts immediately, not warn-only output-shape)
   269	- No enabled live source returns 0 candidates WITHOUT a recorded degradation exception note (sources in degraded mode per §4 Step 2 are expected to return 0 and don't trip Gate A)
   270	
   271	Gate A failure routing by class:
   272	- PII leakage → `ESC_PII_LEAKAGE_RISK` (blocking; operator + ifos_oncall)
   273	- Output-shape failures (count not in 5-15, contact-method missing, rationale <50 words, voice classifier miss, all-source-failure-without-degradation) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)
   274	On any Gate A failure, `validate.sh` writes the partial draft to `/tmp` and emits the mandatory `hh_decision_action("validate_gate_a_fail", ...)` audit row carrying the ESC code (per master brief §8.1 Change 2 + autosend-policy.yaml lines 119-123) BEFORE aborting; operator review.
   275	
   276	**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   277	
   278	### Gate B — Outcome threshold (success metric, not block)
   279	
   280	Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
   281	
   282	Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply (v1.0). Aggregate over rolling 30-day window per tenant. NOTE: Bullhorn-note feedback is NOT a v1.0 path (Sourcing Scout is read-only on Bullhorn per §1 + §6 contracts; would require write capability not in v1.0 scope).
   283	
   284	Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing) — operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
   285	
   286	Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
   287	
   288	---
   289	
   290	## §6 — Escalation codes
   291	
   292	Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
   293	
   294	| Code | Trigger | Severity | Routing |
   295	|---|---|---|---|
   296	| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (per catalogue §2.3) | operator + ifos_oncall |
   297	| `ESC_LINKEDIN_AUTH` | LinkedIn / Proxycurl session/OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   298	| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   299	| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   300	| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
   301	| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
   302	| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   303	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
   304	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
   305	| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
   306	
   307	Sourcing Scout does NOT use:
   308	
   309	- `ESC_AUTOSEND_*` — no auto-send actions; pure read + report
   310	- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
   311	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
   312	- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
   313	- `ESC_DNC_FILTER_HIT` — per catalogue §2.10 reserved for outbound send refusal specifically; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish backlog: add ESC_SOURCING_DNC_FILTER.
   314	
   315	---
   316	
   317	## §7 — Voice + tone constraints
   318	
   319	Step 9 (per-candidate rationale generation) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   320	
   321	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
   322	  - No demographic inference (age, gender, nationality, ethnicity, family status) — Equality Act 2010 compliance
   323	  - No salary-band reference unless explicitly supplied by candidate
   324	  - No claims about candidate intent ("looking to leave their role") without evidence in source data
   325	  - No mention of competing agency placements except in risk-flag context
   326	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
   327	- **Voice-drift detection (classifier-only):** per `vertical-schema.v0.3-supplement.yaml` lines 584-593 + 715-724, Sourcing Scout has `recent_edit` access of **W** (writes its rationale drafts) but **not R**, so it does NOT read consultant edit history via `hh_load_recent_edits`. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. The cron — not Sourcing Scout — reads edit history for analytics + canary threshold tuning.
   328	
   329	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   330	
   331	---
   332	
   333	## §8 — Build dependencies (W9 prerequisites)
   334	
   335	Sourcing Scout build cannot start until ALL of the following are confirmed:
   336	
   337	| Dependency | Source | Status |
   338	|---|---|---|
   339	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   340	| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
   341	| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
   342	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   343	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   344	| Bullhorn MCP read capability | W3-W4-W5 build chain | ⏸ |
   345	| **Proxycurl commercial signup** + API access | Founder commercial; ~$39+/mo | ⏸ |
   346	| **Reed.co.uk commercial signup** + API access | Founder commercial | ⏸ |
   347	| **CV-Library commercial signup** + API access | Founder commercial | ⏸ |
   348	| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
   349	| Reed MCP connector | W9 build start (~2 days) | ⏸ |
   350	| CV-Library MCP connector | W9 build start (~2 days) | ⏸ |
   351	| Source-abstraction layer (Night Sourcer reuse) | W9 build start (~2 days) | ⏸ |
   352	| Per-tenant source credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   353	| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
   354	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   355	| `validate.sh` Gate A logic | Build at W9 start (~1 day) | ⏸ |
   356	| `context.sh` hydration | Build at W9 start (~0.5 day) | ⏸ |
   357	| `cycle.sh` orchestration (11-step) | Build at W9 start (~2 days) | ⏸ |
   358	| 3 fixtures with golden outputs | Build at W9 start (~1 day) | ⏸ |
   359	
   360	**Pre-W9-build prerequisites (must resolve to ✅ before W9 starts):** all items listed up to and including "Tenant DNC list populated", "Voice corpus seeded", and "Per-tenant source credentials in _secrets.env" — these are FOUNDER/TENANT-ADMIN actions that the W9 build cannot deliver itself. The four sibling-bundle items below (validate.sh, context.sh, cycle.sh, fixtures) ARE the W9 build slice itself — those are deliverables not prerequisites. Their completion is the W9-build-end Status-flip criterion (Proposed → Accepted), not the W9-build-start gate.
   361	
   362	---
   363	
   364	## §9 — Status + open questions
   365	
   366	**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
   367	
   368	### Open questions for founder review
   369	
   370	| # | Question | Resolution path |
   371	|---|---|---|
   372	| Q1 | All three external sources required for v1.0? Reed + CV-Library are UK-recruitment-specific; Proxycurl is LinkedIn-via-API. Could v1.0 ship with Bullhorn + Proxycurl only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
   373	| Q2 | Proxycurl pricing — ~$39/mo for 5,000 credits at low volume; scales with usage. Per pilot tenant budget? | ~5-10 briefs/day per consultant × 50 calls/brief = up to 2,500 credits/day per consultant. Cost: ~$20-50/day at peak. |
   374	| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
   375	| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
   376	| Q5 | Gate B 6-of-10 metric — measured via consultant feedback (Brain UI v1.0 doesn't have feedback UX yet) | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful" → `decision_log` row via `consultant_feedback` green-tier action_type. v1.1: Brain UI button. NOTE: Bullhorn-note-based feedback is NOT a v1.0 path — Sourcing Scout is read-only on Bullhorn (no write capability); Bullhorn note creation would require tools.yaml write capability + autosend/decision logging which v1.0 explicitly excludes. |
   377	| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. A new ADR (number assigned at authoring time; not ADR-006 — that's Diagnostic Gate A) at W9 build start documenting the source-abstraction interface. |
   378	| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `date_last_modified_at < now() - 90 days` (per schema line 100) to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side modification-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |
   379	
   380	### Gotchas (carried forward from ULTRAPLAN A5 line 555)
   381	
   382	1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
   383	2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
   384	3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.
   385	
   386	---
   387	
   388	## §10 — When this document ratifies
   389	
   390	Per `.codex/ratification/review-agent-bundle.md` skill (built 2026-05-24, commit `825ebd4`): this agent.md ratifies when Codex review-agent-bundle returns RATIFIED verdict on the SCAFFOLD shape (output contract + workflow + gates + escalation + dependencies). **Ratification of the scaffold does NOT make it Accepted.** Per the agent-bundle skill, Accepted means production-ready — which requires all sibling bundle files + fixtures + first production run.
   391	
   392	**Three-state lifecycle:**
   393	
   394	1. **Proposed → Ratified-as-Scaffold** when Codex review-agent-bundle returns RATIFIED on this agent.md alone. Pre-build scaffold confirmed shape-correct; the document is a binding contract for the W9 build slice.
   395	
   396	2. **Ratified-as-Scaffold → Accepted** when ALL:
   397	   - W9 build slice produces all 5 sibling bundle files (`tools.yaml`, `context.sh`, `validate.sh`, `cycle.sh`, `cleanup.sh`) + 3 fixtures with golden outputs
   398	   - Codex re-ratifies the full bundle (agent.md + siblings + fixtures) post-build
   399	   - Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B UX)
   400	   - Q2 cost model approved with per-tenant budget cap
   401	   - Q6: source-abstraction-layer ADR drafted + ratified (new ADR — not the same as ADR-006 which is Diagnostic Gate A; number assigned at authoring time)
   402	
   403	3. **Accepted → In Force** when:
   404	   - First production brief processed end-to-end against migration-test tenant
   405	   - Gate B feedback loop operational (Telegram /scout-feedback path; Brain UI in v1.1)
   406	   - First production render against a pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
   407	
   408	Until W9 build: this document is a forward-looking scaffold.
   409	
   410	*End of Sourcing Scout agent.md draft.*

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '580,610p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
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
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '535,560p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '130,275p;370,410p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
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
   271	
   272	#### `ESC_MS_GRAPH_AUTH`
   273	- **Severity:** **blocking** — Concierge Outlook send disabled; drafts-only
   274	- **Trigger:** Microsoft Graph OAuth refresh failed; Outlook sendMail returns 401
   275	- **Phase:** `gating_failed`
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

exec
/bin/zsh -lc 'ls -l agents/recruitment/sourcing-scout/validate.sh agents/recruitment/sourcing-scout/cycle.sh agents/recruitment/sourcing-scout/context.sh agents/recruitment/sourcing-scout/tools.yaml agents/recruitment/sourcing-scout/fixtures' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
-rwxr-xr-x@ 1 madsadmin  staff  16198 Jun 10 13:00 agents/recruitment/sourcing-scout/context.sh
-rwxr-xr-x@ 1 madsadmin  staff  38768 Jun 10 13:08 agents/recruitment/sourcing-scout/cycle.sh
-rw-r--r--@ 1 madsadmin  staff  16373 Jun 10 13:15 agents/recruitment/sourcing-scout/tools.yaml
-rwxr-xr-x@ 1 madsadmin  staff  19117 Jun 10 13:04 agents/recruitment/sourcing-scout/validate.sh

agents/recruitment/sourcing-scout/fixtures:
total 56
-rw-r--r--@ 1 madsadmin  staff  8906 Jun 10 13:15 01-primary.yaml
-rw-r--r--@ 1 madsadmin  staff  7917 Jun 10 13:16 02-edge-case-degraded-sources.yaml
-rw-r--r--@ 1 madsadmin  staff  8169 Jun 10 13:16 99-dnc-bulk-filter.yaml

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '100,125p;380,400p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
   100	
   101	  concierge_approval_routed:
   102	    tier: green
   103	    agent: concierge
   104	    reason: "Internal audit row recorded by Concierge cycle.sh Step 11 when an approval is routed via the autosend-bridge (per Founder Decision D1 path A/B/C). Payload carries d1_path + bridge_target (approval_id or vault path). Not an external send; the actual send is a downstream orange-tier action_type with its own row."
   105	    irreversible: false
   106	
   107	  cash_conductor_run_complete:
   108	    tier: green
   109	    agent: cash-conductor
   110	    reason: "Internal run-complete status marker; no external comms"
   111	    irreversible: false
   112	
   113	  consultant_feedback:
   114	    tier: green
   115	    agent: all
   116	    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
   117	    irreversible: false
   118	
   119	  validate_gate_a_fail:
   120	    tier: green
   121	    agent: all
   122	    reason: "Internal audit row written by validate.sh when Gate A enforcement fails. Carries the specific ESC code (e.g. ESC_AGENT_OUTPUT_SHAPE | ESC_PII_LEAKAGE_RISK) in the payload; the action itself is just the audit-row write, not an external send. Each agent's validate.sh emits this row before exit 1."
   123	    irreversible: false
   124	
   125	  diagnostic_input_invalid:
   380	    irreversible: true
   381	
   382	  unauthorised_adapter_send:
   383	    tier: red
   384	    agent: all
   385	    block_reason: unauthorized_adapter
   386	    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
   387	    irreversible: true
   388	
   389	  send_to_blocked_recipient:
   390	    tier: red
   391	    agent: all
   392	    block_reason: blocked_recipient
   393	    reason: "Recipient in tenant's blocked_recipients override list"
   394	    irreversible: true
   395	
   396	# ───────────────────────────────────────────────────────────
   397	# Defaults applied when override fields are absent in tenant_adapters
   398	# ───────────────────────────────────────────────────────────
   399	
   400	defaults:

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '390,412p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '575,610p;708,746p;810,830p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
   390	      END IF;
   391	    END IF;
   392	
   393	    IF d ? 'decision_window_text' THEN
   394	      IF jsonb_typeof(d->'decision_window_text') NOT IN ('string', 'null') THEN
   395	        RAISE EXCEPTION 'decision_window_text must be string or null';
   396	      END IF;
   397	      IF d->>'decision_window_text' IS NOT NULL
   398	         AND length(d->>'decision_window_text') > 280 THEN
   399	        RAISE EXCEPTION 'decision_window_text exceeds 280 chars';
   400	      END IF;
   401	    END IF;
   402	  END IF;
   403	
   404	  RETURN NEW;
   405	END;
   406	$$ LANGUAGE plpgsql;
   407	
   408	-- Rebind the trigger to the new function (drops + recreates)
   409	DROP TRIGGER IF EXISTS validate_voice_scores ON entities;
   410	DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
   411	
   412	CREATE TRIGGER validate_entities_data_v0_3

 succeeded in 0ms:
   575	v0_2_entity_access_amendments:
   576	
   577	  voice_corpus:
   578	    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
   579	    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
   580	    rationale: |
   581	      All v1.0 agents that produce voice-classified output (Diagnostic for
   582	      §12 conversation opener; Janitor for tacit-note narratives; Cash
   583	      Conductor for chase drafts; Sourcing Scout for per-candidate
   584	      rationale) read voice_corpus for ANN-match exemplars. v0.2 only
   585	      granted Scribe + Concierge; v0.3 extends to all 6.
   586	
   587	  tone_rule:
   588	    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
   589	    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
   590	    rationale: |
   591	      Janitor agent.md §7 calls hh_load_tone_rules filtered by
   592	      applies_to_agents containing 'janitor' for tacit-note narrative
   593	      voice-classification. Per Round-8 Cat-β finding for Janitor.
   594	      Diagnostic + Sourcing Scout also read tone_rules for their
   595	      voice-classified outputs (§12 opener, per-candidate rationale).
   596	
   597	  recent_edit:
   598	    v0_2_v1_0_agent_access: [voice-drift-canary (W), Concierge (R), LoRA (R)]
   599	    v0_3_v1_0_agent_access:
   600	      - voice-drift-canary (W)  # v0.2 unchanged
   601	      - Concierge (R)            # v0.2 unchanged
   602	      - LoRA (R)                 # v0.2 unchanged
   603	      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
   604	      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
   605	      - Cash Conductor (W)       # v0.3 NEW — writes own chase-draft edits
   606	      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
   607	    rationale: |
   608	      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
   609	      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
   610	      for retraining queue). Janitor adds R for tacit-note harvest per
   708	    sourcing_scout: R
   709	    concierge: R
   710	  voice_corpus_chunks:
   711	    # v0.2 auxiliary table holding pgvector HNSW index over voice corpus chunks
   712	    # All v1.0 agents producing voice-classified output need R for ANN-match retrieval
   713	    diagnostic: R
   714	    janitor: R
   715	    scribe: R
   716	    cash_conductor: R
   717	    sourcing_scout: R
   718	    concierge: R
   719	  tone_rule:
   720	    # v0.2 auxiliary table — per-tenant tone constraints
   721	    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents
   722	    diagnostic: R
   723	    janitor: R
   724	    scribe: R
   725	    cash_conductor: R
   726	    sourcing_scout: R
   727	    concierge: R
   728	  recent_edit:
   729	    # v0.2 auxiliary table — consultant edits for retraining/drift detection
   730	    # Per §2a amendment: v0.3 expands access (Concierge R from v0.2;
   731	    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
   732	    # Scout add W to write own retraining edits; Diagnostic remains none)
   733	    diagnostic: none
   734	    janitor: R
   735	    scribe: W
   736	    cash_conductor: W
   737	    sourcing_scout: W
   738	    concierge: R
   739	  cash_conductor_transactions:
   740	    diagnostic: none
   741	    janitor: none
   742	    scribe: none
   743	    cash_conductor: R+W
   744	    sourcing_scout: none
   745	    concierge: none
   746	  cash_conductor_invoices:
   810	    required: false
   811	    default: 0.85
   812	    range: [0.75, 0.95]
   813	    set_by: [tenant-admin]
   814	    read_by: [janitor]
   815	    notes: |
   816	      Per-tenant dedup confidence threshold for candidate merges. v1.0 default
   817	      0.85 per ULTRAPLAN A2 line 510. Tenant-admin override range [0.75, 0.95]
   818	      via the wizard. The migration validator (v0.2-to-v0.3.sql §5 allowlist +
   819	      type-validation trigger extension added in R19) enforces both the
   820	      allowlist membership and the [0.75, 0.95] range. Schema declaration
   821	      added Day-20 W4 bilateral pass closing Janitor R11 Codex Finding 4.
   822	
   823	  blocked_recipients:
   824	    type: array
   825	    items:
   826	      type: string
   827	    required: false
   828	    default: []
   829	    set_by: [tenant-admin, janitor]
   830	    read_by: [concierge, sourcing-scout, cash-conductor, janitor]

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '80,102p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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

exec
/bin/zsh -lc 'rg -n "blocked_recipients|allowed|allowlist|tenant_adapters" docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
419:-- §5 — tenant_adapters.config validation trigger (new keys)
426:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
432:  allowed_keys TEXT[] := ARRAY[
434:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
444:    -- (per ADR-006 Tier 2); v0.3 trigger does not allowlist this key
452:    IF NOT (k = ANY(allowed_keys)) THEN
453:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
459:  -- in v0.3 (also not in allowlist above, so it would fail-fast anyway)
510:  -- blocked_recipients: array of strings (pre-v0.3 origin; canonicalised here).
514:  IF c ? 'blocked_recipients' THEN
515:    IF jsonb_typeof(c->'blocked_recipients') != 'array' THEN
516:      RAISE EXCEPTION 'blocked_recipients must be array';
518:    FOR elem IN SELECT * FROM jsonb_array_elements(c->'blocked_recipients') LOOP
520:        RAISE EXCEPTION 'blocked_recipients items must be strings; got %', jsonb_typeof(elem);
529:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
531:CREATE TRIGGER validate_tenant_adapters_config_v0_3
532:  BEFORE INSERT OR UPDATE ON tenant_adapters
534:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();

exec
/bin/zsh -lc 'rg -n "auto_source_on_brief_create|bullhorn_corporation_id|sourcing_scout_cleanup|scout_run_complete|validate_gate_a_fail" agents/_shared/autosend-policy.yaml docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql agents/recruitment/sourcing-scout/tools.yaml' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:77:  scout_run_complete:
agents/_shared/autosend-policy.yaml:119:  validate_gate_a_fail:
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:15:--   - bullhorn_corporation_id    (per-tenant Bullhorn corporation identifier)
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:78:--   - bullhorn_corporation_id:   string matching '^[0-9]+$'
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:102:    'bullhorn_corporation_id'     -- per-tenant Bullhorn corporation
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:219:  -- bullhorn_corporation_id: string matching integer pattern
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:220:  IF c ? 'bullhorn_corporation_id' THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:221:    IF jsonb_typeof(c->'bullhorn_corporation_id') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:222:      RAISE EXCEPTION 'bullhorn_corporation_id must be string or null';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:224:    IF c->>'bullhorn_corporation_id' IS NOT NULL
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:225:       AND c->>'bullhorn_corporation_id' !~ '^[0-9]+$' THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:226:      RAISE EXCEPTION 'bullhorn_corporation_id must match ^[0-9]+$ (Bullhorn corporation ID format); got: %', c->>'bullhorn_corporation_id';
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:172:  bullhorn_corporation_id:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:249:      granola_workspace_id, bullhorn_corporation_id). Per-key type validation
agents/recruitment/sourcing-scout/tools.yaml:15:# The only action_type is sourcing_scout_cleanup (green; QUEUED for W9).
agents/recruitment/sourcing-scout/tools.yaml:148:  - id: sourcing_scout_cleanup
agents/recruitment/sourcing-scout/tools.yaml:150:    action_type: sourcing_scout_cleanup   # green tier; QUEUED for registration at W9
agents/recruitment/sourcing-scout/tools.yaml:211:#   sourcing_scout_cleanup          green

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '65,85p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '80,130p;410,455p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
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

 succeeded in 0ms:
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

exec
/bin/zsh -lc "rg -n \"ESC_BULLHORN_AUTH|ESC_VOICE_DRIFT|2\\.3|ESC_DNC_FILTER_HIT\" agents/_shared/escalation-codes.md" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
120:#### `ESC_VOICE_DRIFT`
170:#### `ESC_VOICE_DRIFT_TENANT`
172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
424:#### `ESC_DNC_FILTER_HIT`

exec
/bin/zsh -lc "find packages/mcp-connectors -maxdepth 2 -type f | sort | sed -n '1,80p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
packages/mcp-connectors/bullhorn/README.md
packages/mcp-connectors/bullhorn/package.json
packages/mcp-connectors/bullhorn/tsconfig.json
packages/mcp-connectors/bullhorn/tsup.config.ts
packages/mcp-connectors/bullhorn/vitest.config.ts
packages/mcp-connectors/companies-house/README.md
packages/mcp-connectors/companies-house/package.json
packages/mcp-connectors/companies-house/pnpm-lock.yaml
packages/mcp-connectors/companies-house/tsconfig.json
packages/mcp-connectors/companies-house/tsup.config.ts
packages/mcp-connectors/companies-house/vitest.config.ts
packages/mcp-connectors/cv-library/README.md
packages/mcp-connectors/cv-library/package.json
packages/mcp-connectors/cv-library/tsconfig.json
packages/mcp-connectors/cv-library/tsup.config.ts
packages/mcp-connectors/cv-library/vitest.config.ts
packages/mcp-connectors/granola/README.md
packages/mcp-connectors/granola/package.json
packages/mcp-connectors/granola/tsconfig.json
packages/mcp-connectors/granola/tsup.config.ts
packages/mcp-connectors/granola/vitest.config.ts
packages/mcp-connectors/open-banking/README.md
packages/mcp-connectors/open-banking/package.json
packages/mcp-connectors/open-banking/tsconfig.json
packages/mcp-connectors/open-banking/tsup.config.ts
packages/mcp-connectors/open-banking/vitest.config.ts
packages/mcp-connectors/quickbooks/README.md
packages/mcp-connectors/quickbooks/package.json
packages/mcp-connectors/quickbooks/tsconfig.json
packages/mcp-connectors/quickbooks/tsup.config.ts
packages/mcp-connectors/quickbooks/vitest.config.ts
packages/mcp-connectors/reed/README.md
packages/mcp-connectors/reed/package.json
packages/mcp-connectors/reed/tsconfig.json
packages/mcp-connectors/reed/tsup.config.ts
packages/mcp-connectors/reed/vitest.config.ts
packages/mcp-connectors/workos/README.md
packages/mcp-connectors/workos/package.json
packages/mcp-connectors/workos/tsconfig.json
packages/mcp-connectors/workos/tsup.config.ts
packages/mcp-connectors/workos/vitest.config.ts
packages/mcp-connectors/xero/README.md
packages/mcp-connectors/xero/package.json
packages/mcp-connectors/xero/tsconfig.json
packages/mcp-connectors/xero/tsup.config.ts
packages/mcp-connectors/xero/vitest.config.ts

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/reed/package.json | sed -n '1,20p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
     1	{
     2	  "name": "@ifos/reed",
     3	  "version": "0.1.0",
     4	  "private": true,
     5	  "description": "IFOS Reed.co.uk recruiter MCP connector — HTTP Basic auth with API key + Recruiter API surface (post jobs + search candidates + retrieve applications). Used by Sourcing Scout (W9) for source #2 in the 3-source v1.0 candidate pool. Reed Recruiter API auth verified 2026-06-03 via WebFetch reed.co.uk/developers/jobseeker (HTTP Basic with API key as username, empty password); recruiter endpoints inferred from same auth pattern.",
     6	  "license": "UNLICENSED",
     7	  "type": "module",
     8	  "engines": { "node": ">=20.0.0" },
     9	  "main": "./dist/index.js",
    10	  "types": "./dist/index.d.ts",
    11	  "scripts": {
    12	    "build": "tsup",
    13	    "test": "vitest run",
    14	    "test:watch": "vitest",
    15	    "typecheck": "tsc --noEmit"
    16	  },
    17	  "dependencies": {},
    18	  "devDependencies": {
    19	    "@types/node": "^20.14.0",
    20	    "tsup": "^8.3.0",

exec
/bin/zsh -lc "nl -ba packages/mcp-connectors/cv-library/package.json | sed -n '1,20p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
     1	{
     2	  "name": "@ifos/cv-library",
     3	  "version": "0.1.0",
     4	  "private": true,
     5	  "description": "IFOS CV-Library MCP connector — candidate-search surface for Sourcing Scout source #3 (W9). Auth model placeholder pending W6-live verification at commercial signup (per docs/operations/founder-api-signups-2026-06-03.md P3). v0.1.0 assumes HTTP Basic auth as the UK-job-board norm; consumer can override.",
     6	  "license": "UNLICENSED",
     7	  "type": "module",
     8	  "engines": { "node": ">=20.0.0" },
     9	  "main": "./dist/index.js",
    10	  "types": "./dist/index.d.ts",
    11	  "scripts": {
    12	    "build": "tsup",
    13	    "test": "vitest run",
    14	    "test:watch": "vitest",
    15	    "typecheck": "tsc --noEmit"
    16	  },
    17	  "dependencies": {},
    18	  "devDependencies": {
    19	    "@types/node": "^20.14.0",
    20	    "tsup": "^8.3.0",

codex
REJECTED

1. The output contract is internally contradictory about LinkedIn/Proxycurl. Lines 7-9 say Proxycurl has shut down, LinkedIn deep-data is deferred to v1.1+, and v1.0 uses three active sources; line 26 still defines the contract as FOUR sources including LinkedIn via Proxycurl, and lines 169-175 still specify a live Proxycurl workflow. Fix by rewriting §1, §3, §4, §6, §8, and §9 around the three-source v1.0 contract, with LinkedIn as an explicit no-op/deferred row only.

2. The `blocked_recipients` migration citation is false. Lines 12 and 204-210 cite `migrations/v0.2-to-v0.3.sql` line 398 and block 396-409 for `blocked_recipients`, but those lines are `decision_window_text`; the actual allowlist is lines 432-434 and validation is lines 510-520. Fix the citation anchors to the real migration lines.

3. The voice/recent_edit schema citation is false. Line 327 cites `vertical-schema.v0.3-supplement.yaml` lines 584-593 + 715-724 to prove Sourcing Scout has `recent_edit` W but not R; actual `recent_edit` W is at lines 597-606 and 728-737, while 715-724 are `voice_corpus_chunks` / `tone_rule`. Fix the cited ranges.

4. The build-state notes are stale and fail honest-signal. Line 5 says `@ifos/reed` and `@ifos/cv-library` “don't exist yet,” but `packages/mcp-connectors/reed/package.json` lines 1-5 and `packages/mcp-connectors/cv-library/package.json` lines 1-5 define those packages; line 276 also says `validate.sh` does not exist despite the sibling file existing. Fix the status/build-state language to distinguish scaffold, implemented connector package, and production readiness accurately.
tokens used
75,025
REJECTED

1. The output contract is internally contradictory about LinkedIn/Proxycurl. Lines 7-9 say Proxycurl has shut down, LinkedIn deep-data is deferred to v1.1+, and v1.0 uses three active sources; line 26 still defines the contract as FOUR sources including LinkedIn via Proxycurl, and lines 169-175 still specify a live Proxycurl workflow. Fix by rewriting §1, §3, §4, §6, §8, and §9 around the three-source v1.0 contract, with LinkedIn as an explicit no-op/deferred row only.

2. The `blocked_recipients` migration citation is false. Lines 12 and 204-210 cite `migrations/v0.2-to-v0.3.sql` line 398 and block 396-409 for `blocked_recipients`, but those lines are `decision_window_text`; the actual allowlist is lines 432-434 and validation is lines 510-520. Fix the citation anchors to the real migration lines.

3. The voice/recent_edit schema citation is false. Line 327 cites `vertical-schema.v0.3-supplement.yaml` lines 584-593 + 715-724 to prove Sourcing Scout has `recent_edit` W but not R; actual `recent_edit` W is at lines 597-606 and 728-737, while 715-724 are `voice_corpus_chunks` / `tone_rule`. Fix the cited ranges.

4. The build-state notes are stale and fail honest-signal. Line 5 says `@ifos/reed` and `@ifos/cv-library` “don't exist yet,” but `packages/mcp-connectors/reed/package.json` lines 1-5 and `packages/mcp-connectors/cv-library/package.json` lines 1-5 define those packages; line 276 also says `validate.sh` does not exist despite the sibling file existing. Fix the status/build-state language to distinguish scaffold, implemented connector package, and production readiness accurately.
