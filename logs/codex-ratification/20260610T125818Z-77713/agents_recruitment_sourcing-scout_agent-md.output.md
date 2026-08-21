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
session id: 019eb19c-c0d3-7c01-89a3-697d03068aec
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
**Build state:** W9 build slice COMPLETE (spec-003; branch `worktree-agent-a45354564e8f66257`, 2026-06-10) — all 6 sibling bundle files + 3 fixtures LIVE; build-gate GREEN; three deterministic DB-backed fixture suites green. Prior contract history: Day-20 W4 bilateral pass + R19 substantive fix; R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`; R19 (2026-05-24) added the `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Still awaits: Q1 LOI + Bullhorn Sub-decision B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + Reed + CV-Library commercial signups (creds EMPTY; live smoke founder-gated) + Codex re-ratification of the built bundle + founder approvals per §10.
**Reading-discipline note (updated 2026-06-10 at W9 build; originally added 2026-06-03 per CC + Concierge + Janitor + Scribe precedent):** this `agent.md` is the **CONTRACT** that the W9 build slice implemented against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml` + `README.md`) + 3 fixtures are **LIVE** — the W9 build slice (spec-003, this branch) replaced every `TODO(W9)` marker with live implementation; three deterministic DB-backed fixture suites (`scripts/run-scout-{dedupe,gate-a,degraded}-test.sh`) are green under build-gate. **Per-component build state, honestly stated:** `@ifos/bullhorn` — implemented connector package (`packages/mcp-connectors/bullhorn`); the Sourcing-Scout OAuth CLI bridge is not built and creds are EMPTY → cycle.sh Step 2 degraded-skip. `@ifos/reed` — implemented connector package (`packages/mcp-connectors/reed`, v0.1.0, tests green); creds EMPTY → degraded-skip until founder signup. `@ifos/cv-library` — implemented connector package + built `dist/cli.js` bridge (`packages/mcp-connectors/cv-library`, v0.1.0); the designated v1.0 live source, but creds EMPTY at last names-only verification → live smoke founder-gated. None of the three is production-proven: no live API call has been made by this bundle; all coverage is fixture-driven (`IFOS_SCOUT_FIXTURE_*`). **VENDOR NOTE:** the v1.0 contract is THREE active sources (Bullhorn + Reed + CV-Library); LinkedIn is structurally present as an explicit NO-OP only — cycle.sh Step 4 emits `linkedin_query` (`results:0; no_op`) per the Janitor Step 7 NO-OP pattern; vendor selection deferred to v1.1+ per the caveat at lines 6-8. **Live audit-marker set emitted by cycle.sh:** `session_start`, `brief_ingested`, `auth_refresh_complete`, `bullhorn_query`, `linkedin_query` (no-op), `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `candidate_proposed` (one row PER candidate), `scout_report`, `scout_run_complete`, plus `validate_gate_a_fail` (Gate A failure only) and `operator_notify_telegram` (when configured). Pure read+report agent — no yellow/orange/red action_types; the cleanup action name `sourcing_scout_cleanup` is NOT a registered autosend-policy action_type — registration is a founder-gated policy decision (a `future_registration` entry in tools.yaml, not an action_type claim); `cleanup.sh` emits `hh_decision_output` until it lands. `context.sh` uses the canonical `tenant_adapters` SELECT path (with `IFOS_FORCE_*` fixture fallbacks retained for tests) — `bullhorn_corporation_id` v0.4-allowlisted (LIVE on VPS commit `a1bbcf6`) + `blocked_recipients` v0.3-allowlisted (LIVE on VPS). §10 lifecycle status remains **Proposed** pending Codex re-ratification of the built bundle + founder approvals — the status flip is founder-gated.

**v1.0 readiness caveat — LinkedIn deep-data vendor (added 2026-06-02):** the original v1.0 design listed **Proxycurl** as the LinkedIn deep-data source (one of FOUR sources in the §1 output contract). **Proxycurl was shut down in 2025** following LinkedIn's January 2025 lawsuit against Nubela (Proxycurl's parent; ~50% of their revenue came from LinkedIn scraping; see https://nubela.co/blog/goodbye-proxycurl/). The successor product **NinjaPear** (same team) explicitly does NOT carry LinkedIn data — it is a B2B competitive-intelligence platform sourced from non-LinkedIn channels. Net: the LinkedIn-via-Proxycurl path in the original four-source design **does not have a legally-clear vendor as of 2026-06-02**; §1 + §3 + §4 Step 4 + §6 below are written to the three-source v1.0 contract with LinkedIn as an explicit NO-OP row.

**v1.0 disposition (per founder decision 2026-06-02):** LinkedIn deep-data is **DEFERRED to v1.1+**. v1.0 Sourcing Scout operates against **THREE active sources** (Bullhorn-candidate passive-match + Reed + CV-Library), not four. The §1 output contract's "5-15 candidates" Gate A target is preserved; Reed + CV-Library + Bullhorn passive-match combined are sufficient at v1.0 pilot scale (≤3 tenants). LinkedIn-vendor selection for v1.1+ takes place at W8-9 when the Sourcing Scout build slice forces the choice and we have more clarity on the post-lawsuit legal landscape (candidate vendors: Lix, Phantombuster, Apify with LinkedIn-aware contracts, or LinkedIn's own Sales Navigator enterprise API at much higher cost). Until that decision: §4 Step 4 (LinkedIn search) is an explicit structurally-present NO-OP in v1.0; the ranked-list assembly at Step 6 weights the 3 active sources accordingly; the §3 output template still shows the LinkedIn row but populates it as "deferred to v1.1+; vendor pending" rather than a scraped result. Gate B target (≥6 of 10 advance per ULTRAPLAN A5 line 553) unchanged at v1.0 — the marginal contribution of LinkedIn deep-data is unknown until pilot data lands; v1.1+ vendor selection partly informed by whether Gate B underperforms without it.

**Schema-key references:**
- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 434; `allowed_keys` array lines 432-445; element-type validation block lines 510-523); canonical Postgres-backed v1.0 DNC source per ADR-002. Declared in `vertical-schema.v0.3-supplement.yaml` lines 823-840 (R19 added this declaration; no longer deferred).
- `tenant_adapters.config.auto_source_on_brief_create` — v0.4-supplement-pending (not yet in any allowlist); the Bullhorn-webhook auto-source trigger code path is blocked until v0.4 lands.
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from THREE active v1.0 sources** (Bullhorn ATS passive-match read; Reed.co.uk API; CV-Library API) — LinkedIn is structurally present as an explicit NO-OP row only (deferred to v1.1+ per the vendor caveat above; §4 Step 4 emits `linkedin_query` with `results:0; no_op`). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).

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
**Sources searched:** Bullhorn ATS + LinkedIn (deferred to v1.1+; vendor pending) + Reed + CV-Library
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
| LinkedIn | 0 (NO-OP; deferred to v1.1+; vendor pending) | — | — |
| Reed | <N> | <score> | <remaining> |
| CV-Library | <N> | <score> | <remaining> |

## Diagnostic + exception list
- <Any source failures (e.g., "Reed API 429; retried once; 3 candidates lost")>
- <Any "do not contact" filter hits>
- <Any low-confidence candidates discarded (below 0.5)>
```

Per `decision_log`: one row per source query + one row per candidate proposed + one final aggregate row.

Voice-classified content: only the per-candidate match rationale (Step 9). Voice classifier ≥0.75 against tenant style — **hard-enforced WHEN a tenant voice corpus exists**. When the tenant `voice_corpus` is empty, a score cannot be honestly computed: the rationale is recorded as `unscored`/`no_corpus` (never a faked score) and `validate.sh` G4 warns-and-passes. **Warn-when-unscored is the accepted v1.0 gate behaviour** (spec-003 §5 "hard (warn-when-unscored)" + the Cash Conductor honesty precedent); the gate becomes hard-scoring automatically once a corpus is loaded. A rationale with a computed score that fails after 3 retries → ESC_VOICE_DRIFT → candidate dropped from list + flagged in exception list.

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
   → bullhorn (read-only); Reed; CV-Library. LinkedIn: NO auth at v1.0
     (Step 4 is a NO-OP; vendor deferred to v1.1+)
   → per-source auth failure fires the catalogue-specified ESC code with
     its catalogue-specified degraded-mode behavior:
     - ESC_BULLHORN_AUTH (catalogue §2.3): blocking → Sourcing Scout
       enters degraded mode per catalogue ("drafts-only, no auto-send" —
       Sourcing-Scout-specific interpretation: skip Bullhorn source +
       continue with the other 2 active sources, since Sourcing Scout has
       no auto-send path of its own; the "drafts-only" framing maps to
       "report-only with Bullhorn data omitted from the sourcing set")
     - ESC_REED_AUTH (catalogue §2.7): blocking → degraded mode (cached
       Reed search results only)
     - ESC_CVLIBRARY_AUTH (catalogue §2.7): blocking → degraded mode
       (cached CV-Library search only)
     - ESC_LINKEDIN_AUTH (catalogue §2.7): NOT fired at v1.0 — reserved
       for the v1.1+ LinkedIn vendor integration
   → if MULTIPLE sources are in degraded mode AND the remaining live
     sources cannot produce ≥5 candidates: ESC_AGENT_OUTPUT_SHAPE +
     return partial report with exception note (Gate A floor violated)
   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
     "sources_ok:<N>/4; degraded:<list>; linkedin:v1.0_no_op")

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

4. LinkedIn search — explicit NO-OP at v1.0 (deferred to v1.1+)
   → structurally present per the Janitor Step 7 NO-OP pattern: emits an
     empty result set into the Step 7 aggregate; the §3 report shows the
     LinkedIn row as "deferred to v1.1+; vendor pending"
   → no vendor call, no cache, no auth, no ESC at v1.0 (Proxycurl shut
     down 2025 per the v1.0 readiness caveat; v1.1+ vendor selection
     pending — Lix / Phantombuster / Apify / Sales Navigator)
   → hh_decision_output("linkedin_query", "brief:<id>",
     "results:0; no_op; reason:v1.0_caveat_proxycurl_shutdown;
      vendor_selection:v1.1_deferred")

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
   → annotate each row with source provenance (e.g., "from Bullhorn + Reed
     match" if found in both)
   → hh_decision_output("aggregate_dedupe", "brief:<id>",
     "pre_dedupe:<N>; post_dedupe:<N>")

8. "Do not contact" filter (pre-outbound sourcing filter; NOT outbound refusal)
   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
     (concept referenced by autosend-policy.yaml red-tier
     `send_to_blocked_recipient` action_type + ESC_DNC_FILTER_HIT catalogue
     §2.10; the config key IS registered in the canonical authority
     `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 434;
     `allowed_keys` array lines 432-445; element-type validation block
     lines 510-523).
     v0.4-pending status applies ONLY to `auto_source_on_brief_create`
     (the webhook auto-source trigger config), NOT to `blocked_recipients`.
     Postgres-backed per ADR-002 vault/Postgres split — NOT vault markdown.
     `blocked_recipients` is now declared in `vertical-schema.v0.3-supplement.yaml`
     lines 823-840.)
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
   → voice classifier scores rationale (≥0.75 — hard-enforced when a tenant
     voice corpus exists; empty voice_corpus → voice_score recorded as
     "unscored"/no_corpus, never faked — warn-when-unscored is the accepted
     v1.0 gate behaviour per spec-003 §5)
   → ESC_VOICE_DRIFT if a computed classifier score <0.75 after 3 retries;
     drop candidate from final list
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
- All rationales pass voice classifier ≥0.75 — **hard-enforced WHEN a tenant voice corpus exists**. Empty `voice_corpus` → rationales carry `unscored`/`no_corpus` (a score is never faked) and G4 warns-and-passes: **warn-when-unscored is the accepted v1.0 gate behaviour** (spec-003 §5 "hard (warn-when-unscored)" + the Cash Conductor honesty precedent); G4 becomes hard-scoring once a corpus is loaded
- No PII outside firm boundary in rationale text → fires `ESC_PII_LEAKAGE_RISK` (BLOCKING per catalogue §2.5 lines 148-154; halts immediately, not warn-only output-shape)
- No enabled live source returns 0 candidates WITHOUT a recorded degradation exception note (sources in degraded mode per §4 Step 2 are expected to return 0 and don't trip Gate A)

Gate A failure routing by class:
- PII leakage → `ESC_PII_LEAKAGE_RISK` (blocking; operator + ifos_oncall)
- Output-shape failures (count not in 5-15, contact-method missing, rationale <50 words, voice classifier miss, all-source-failure-without-degradation) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)
On any Gate A failure, `validate.sh` writes the partial draft to `/tmp` and emits the mandatory `hh_decision_action("validate_gate_a_fail", ...)` audit row carrying the ESC code (per master brief §8.1 Change 2 + autosend-policy.yaml lines 119-123) BEFORE aborting; operator review.

**Build note (updated 2026-06-10; the original Cat-5 honesty note said `validate.sh` did not exist yet):** `agents/recruitment/sourcing-scout/validate.sh` is now LIVE — delivered by the W9 build slice (spec-003 §5) implementing G1-G7 against the contract above, exercised by `scripts/run-scout-gate-a-test.sh` (PASS + 9 fail classes; deterministic DB-backed fixtures). Not yet production-proven: no live run has occurred (creds EMPTY; live smoke founder-gated).

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
| `ESC_LINKEDIN_AUTH` | v1.1+ LinkedIn vendor session/OAuth fail — NOT fired at v1.0 (§4 Step 4 is an explicit NO-OP; no vendor) | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / reed / cv-library; linkedin reserved for v1.1+) | warn | operator_chat_id |
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
- **Voice-drift detection (classifier-only):** per `vertical-schema.v0.3-supplement.yaml` lines 597-606 (§2a access-list amendment) + 728-737 (access matrix), Sourcing Scout has `recent_edit` access of **W** (writes its rationale drafts) but **not R**, so it does NOT read consultant edit history via `hh_load_recent_edits`. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries; scores are only computed when the tenant voice corpus is non-empty — empty corpus → `unscored`/`no_corpus` recorded and `validate.sh` G4 warns-and-passes (the accepted v1.0 warn-when-unscored gate behaviour per spec-003 §5; hard-scoring resumes once a corpus is loaded). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. The cron — not Sourcing Scout — reads edit history for analytics + canary threshold tuning.

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Build dependencies (W9 prerequisites — table updated 2026-06-10 post-W9-build)

| Dependency | Source | Status |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
| **Bullhorn Sub-decisions A+B Accepted** | Sub-decision A RESOLVED 2026-06-02; B pending | ⏸ |
| Bullhorn MCP read capability | `packages/mcp-connectors/bullhorn` package exists; Sourcing-Scout OAuth CLI bridge + creds pending → Step 2 degraded-skip | ⏸ (partial) |
| **LinkedIn vendor selection + commercial signup** (Proxycurl shut down 2025) | Founder commercial, v1.1+ | DEFERRED v1.1+ |
| **Reed.co.uk commercial signup** + API access | Founder commercial (creds EMPTY) | ⏸ |
| **CV-Library commercial signup** + API access | Founder commercial (creds EMPTY at last names-only verification) | ⏸ |
| LinkedIn vendor MCP connector | v1.1+ after vendor selection | DEFERRED v1.1+ |
| Reed MCP connector | `packages/mcp-connectors/reed` v0.1.0, tests green | ✅ (creds EMPTY) |
| CV-Library MCP connector | `packages/mcp-connectors/cv-library` v0.1.0 + `dist/cli.js` bridge | ✅ (creds EMPTY; live smoke founder-gated) |
| Source-abstraction layer (Night Sourcer reuse) | `_scout_query_source()` in cycle.sh (W9 build slice) | ✅ (ADR per §9 Q6 still to be authored) |
| Per-tenant source credentials in `_secrets.env` | Tenant onboarding | ⏸ |
| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
| `validate.sh` Gate A logic | W9 build slice (spec-003 §5; G1-G7) | ✅ |
| `context.sh` hydration | W9 build slice (canonical `tenant_adapters` SELECTs) | ✅ |
| `cycle.sh` orchestration (11-step) | W9 build slice (spec-003 §4) | ✅ |
| 3 fixtures with golden outputs | W9 build slice + 3 DB-backed test suites | ✅ |

**Post-W9-build note:** the four sibling-bundle deliverables (validate.sh, context.sh, cycle.sh, fixtures) WERE the W9 build slice and are delivered on this branch; the W9 build proceeded against deterministic fixtures per spec-003 §8 honest scope. The remaining ⏸ rows are FOUNDER/TENANT-ADMIN actions (commercial signups, creds, DNC population, voice corpus, ratifications) — they gate the first LIVE run and the §10 lifecycle transitions (Proposed → Accepted → In Force per the rewritten §10), not the fixture-backed build.

---

## §9 — Status + open questions

**Status:** Proposed (W9 build slice COMPLETE on this branch — bundle LIVE per the build-state header; §10 status flip is founder-gated). Awaits Bullhorn Sub-decision B + 2 commercial signups (Reed + CV-Library; LinkedIn vendor deferred to v1.1+) + Q1 LOI + Codex re-ratification + founder approvals per §10.

### Open questions for founder review

| # | Question | Resolution path |
|---|---|---|
| Q1 | All three v1.0 sources required? Reed + CV-Library are UK-recruitment-specific; LinkedIn deep-data is deferred to v1.1+ post-Proxycurl-shutdown. Could v1.0 ship with Bullhorn + one job board only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
| Q2 | LinkedIn vendor pricing (v1.1+) — the original Proxycurl model (~$39/mo for 5,000 credits, ~$20-50/day at peak per consultant) is void post-shutdown. Per-tenant budget cap for the v1.1+ vendor? | Deferred to v1.1+ vendor selection (Lix / Phantombuster / Apify / Sales Navigator); cost ceiling per brief remains the design constraint whichever vendor is chosen. |
| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
| Q5 | Gate B 6-of-10 metric — measured via consultant feedback (Brain UI v1.0 doesn't have feedback UX yet) | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful" → `decision_log` row via `consultant_feedback` green-tier action_type. v1.1: Brain UI button. NOTE: Bullhorn-note-based feedback is NOT a v1.0 path — Sourcing Scout is read-only on Bullhorn (no write capability); Bullhorn note creation would require tools.yaml write capability + autosend/decision logging which v1.0 explicitly excludes. |
| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. A new ADR (number assigned at authoring time; not ADR-006 — that's Diagnostic Gate A) at W9 build start documenting the source-abstraction interface. |
| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `date_last_modified_at < now() - 90 days` (per schema line 100) to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side modification-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |

### Gotchas (carried forward from ULTRAPLAN A5 line 555)

1. **LinkedIn vendor rate limits (v1.1+).** The original Proxycurl per-credit quota model is void post-shutdown; the underlying constraint stands — deep profile fetches cost more than searches, so plan a cost ceiling per brief for whichever v1.1+ vendor is selected.
2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-agent-bundle.md` skill (built 2026-05-24, commit `825ebd4`). **Single post-W9 criteria set (rewritten 2026-06-10).** The pre-build "Ratified-as-Scaffold" intermediate state (introduced at R9) applied to the scaffold-only document; the W9 build slice is COMPLETE on this branch, so the unit that ratifies now is the BUILT bundle (this agent.md + 6 sibling files + 3 fixtures), not the scaffold. Lifecycle:

1. **Proposed** — CURRENT state. W9 build slice complete; build-gate GREEN; three deterministic DB-backed fixture suites green. No live API call has been made by this bundle; creds EMPTY.

2. **Proposed → Accepted** when ALL of:
   - Codex review-agent-bundle returns RATIFIED on the built bundle (this agent.md + `tools.yaml` + `context.sh` + `validate.sh` + `cycle.sh` + `cleanup.sh` + `README.md` + 3 fixtures)
   - Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B feedback UX)
   - Q6: source-abstraction-layer ADR drafted + ratified (new ADR — not the same as ADR-006 which is Diagnostic Gate A; number assigned at authoring time)

   **No production-run requirement at this state** — Accepted certifies the built, Codex-ratified, founder-approved bundle. (Q2 — LinkedIn vendor cost model — is deferred to v1.1+ vendor selection per §9 and does not gate Accepted.)

3. **Accepted → In Force** when ALL of:
   - First production brief processed end-to-end against the migration-test tenant, with live-smoke evidence (live smoke is founder-gated: Reed + CV-Library commercial signups + Bullhorn Sub-decision B + creds provisioned)
   - Gate B feedback loop operational (Telegram /scout-feedback path; Brain UI in v1.1)
   - First production render against a pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)

The **Status** field at the top of this document remains **Proposed** — every lifecycle flip is founder-gated.

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
I’ll verify the cited local authorities first: the agent bundle file, shared ESC catalogue, schema supplements, autosend policy, and the sibling scripts so the verdict is grounded in the repository rather than the pasted text alone.
exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
     1	# Sourcing Scout — request-response passive sourcing
     2	
     3	**Status:** Proposed.
     4	**Build state:** W9 build slice COMPLETE (spec-003; branch `worktree-agent-a45354564e8f66257`, 2026-06-10) — all 6 sibling bundle files + 3 fixtures LIVE; build-gate GREEN; three deterministic DB-backed fixture suites green. Prior contract history: Day-20 W4 bilateral pass + R19 substantive fix; R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`; R19 (2026-05-24) added the `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Still awaits: Q1 LOI + Bullhorn Sub-decision B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + Reed + CV-Library commercial signups (creds EMPTY; live smoke founder-gated) + Codex re-ratification of the built bundle + founder approvals per §10.
     5	**Reading-discipline note (updated 2026-06-10 at W9 build; originally added 2026-06-03 per CC + Concierge + Janitor + Scribe precedent):** this `agent.md` is the **CONTRACT** that the W9 build slice implemented against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml` + `README.md`) + 3 fixtures are **LIVE** — the W9 build slice (spec-003, this branch) replaced every `TODO(W9)` marker with live implementation; three deterministic DB-backed fixture suites (`scripts/run-scout-{dedupe,gate-a,degraded}-test.sh`) are green under build-gate. **Per-component build state, honestly stated:** `@ifos/bullhorn` — implemented connector package (`packages/mcp-connectors/bullhorn`); the Sourcing-Scout OAuth CLI bridge is not built and creds are EMPTY → cycle.sh Step 2 degraded-skip. `@ifos/reed` — implemented connector package (`packages/mcp-connectors/reed`, v0.1.0, tests green); creds EMPTY → degraded-skip until founder signup. `@ifos/cv-library` — implemented connector package + built `dist/cli.js` bridge (`packages/mcp-connectors/cv-library`, v0.1.0); the designated v1.0 live source, but creds EMPTY at last names-only verification → live smoke founder-gated. None of the three is production-proven: no live API call has been made by this bundle; all coverage is fixture-driven (`IFOS_SCOUT_FIXTURE_*`). **VENDOR NOTE:** the v1.0 contract is THREE active sources (Bullhorn + Reed + CV-Library); LinkedIn is structurally present as an explicit NO-OP only — cycle.sh Step 4 emits `linkedin_query` (`results:0; no_op`) per the Janitor Step 7 NO-OP pattern; vendor selection deferred to v1.1+ per the caveat at lines 6-8. **Live audit-marker set emitted by cycle.sh:** `session_start`, `brief_ingested`, `auth_refresh_complete`, `bullhorn_query`, `linkedin_query` (no-op), `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `candidate_proposed` (one row PER candidate), `scout_report`, `scout_run_complete`, plus `validate_gate_a_fail` (Gate A failure only) and `operator_notify_telegram` (when configured). Pure read+report agent — no yellow/orange/red action_types; the cleanup action name `sourcing_scout_cleanup` is NOT a registered autosend-policy action_type — registration is a founder-gated policy decision (a `future_registration` entry in tools.yaml, not an action_type claim); `cleanup.sh` emits `hh_decision_output` until it lands. `context.sh` uses the canonical `tenant_adapters` SELECT path (with `IFOS_FORCE_*` fixture fallbacks retained for tests) — `bullhorn_corporation_id` v0.4-allowlisted (LIVE on VPS commit `a1bbcf6`) + `blocked_recipients` v0.3-allowlisted (LIVE on VPS). §10 lifecycle status remains **Proposed** pending Codex re-ratification of the built bundle + founder approvals — the status flip is founder-gated.
     6	
     7	**v1.0 readiness caveat — LinkedIn deep-data vendor (added 2026-06-02):** the original v1.0 design listed **Proxycurl** as the LinkedIn deep-data source (one of FOUR sources in the §1 output contract). **Proxycurl was shut down in 2025** following LinkedIn's January 2025 lawsuit against Nubela (Proxycurl's parent; ~50% of their revenue came from LinkedIn scraping; see https://nubela.co/blog/goodbye-proxycurl/). The successor product **NinjaPear** (same team) explicitly does NOT carry LinkedIn data — it is a B2B competitive-intelligence platform sourced from non-LinkedIn channels. Net: the LinkedIn-via-Proxycurl path in the original four-source design **does not have a legally-clear vendor as of 2026-06-02**; §1 + §3 + §4 Step 4 + §6 below are written to the three-source v1.0 contract with LinkedIn as an explicit NO-OP row.
     8	
     9	**v1.0 disposition (per founder decision 2026-06-02):** LinkedIn deep-data is **DEFERRED to v1.1+**. v1.0 Sourcing Scout operates against **THREE active sources** (Bullhorn-candidate passive-match + Reed + CV-Library), not four. The §1 output contract's "5-15 candidates" Gate A target is preserved; Reed + CV-Library + Bullhorn passive-match combined are sufficient at v1.0 pilot scale (≤3 tenants). LinkedIn-vendor selection for v1.1+ takes place at W8-9 when the Sourcing Scout build slice forces the choice and we have more clarity on the post-lawsuit legal landscape (candidate vendors: Lix, Phantombuster, Apify with LinkedIn-aware contracts, or LinkedIn's own Sales Navigator enterprise API at much higher cost). Until that decision: §4 Step 4 (LinkedIn search) is an explicit structurally-present NO-OP in v1.0; the ranked-list assembly at Step 6 weights the 3 active sources accordingly; the §3 output template still shows the LinkedIn row but populates it as "deferred to v1.1+; vendor pending" rather than a scraped result. Gate B target (≥6 of 10 advance per ULTRAPLAN A5 line 553) unchanged at v1.0 — the marginal contribution of LinkedIn deep-data is unknown until pilot data lands; v1.1+ vendor selection partly informed by whether Gate B underperforms without it.
    10	
    11	**Schema-key references:**
    12	- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 434; `allowed_keys` array lines 432-445; element-type validation block lines 510-523); canonical Postgres-backed v1.0 DNC source per ADR-002. Declared in `vertical-schema.v0.3-supplement.yaml` lines 823-840 (R19 added this declaration; no longer deferred).
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
    26	> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from THREE active v1.0 sources** (Bullhorn ATS passive-match read; Reed.co.uk API; CV-Library API) — LinkedIn is structurally present as an explicit NO-OP row only (deferred to v1.1+ per the vendor caveat above; §4 Step 4 emits `linkedin_query` with `results:0; no_op`). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
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
    69	**Sources searched:** Bullhorn ATS + LinkedIn (deferred to v1.1+; vendor pending) + Reed + CV-Library
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
    96	| LinkedIn | 0 (NO-OP; deferred to v1.1+; vendor pending) | — | — |
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
   108	Voice-classified content: only the per-candidate match rationale (Step 9). Voice classifier ≥0.75 against tenant style — **hard-enforced WHEN a tenant voice corpus exists**. When the tenant `voice_corpus` is empty, a score cannot be honestly computed: the rationale is recorded as `unscored`/`no_corpus` (never a faked score) and `validate.sh` G4 warns-and-passes. **Warn-when-unscored is the accepted v1.0 gate behaviour** (spec-003 §5 "hard (warn-when-unscored)" + the Cash Conductor honesty precedent); the gate becomes hard-scoring automatically once a corpus is loaded. A rationale with a computed score that fails after 3 retries → ESC_VOICE_DRIFT → candidate dropped from list + flagged in exception list.
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
   134	   → bullhorn (read-only); Reed; CV-Library. LinkedIn: NO auth at v1.0
   135	     (Step 4 is a NO-OP; vendor deferred to v1.1+)
   136	   → per-source auth failure fires the catalogue-specified ESC code with
   137	     its catalogue-specified degraded-mode behavior:
   138	     - ESC_BULLHORN_AUTH (catalogue §2.3): blocking → Sourcing Scout
   139	       enters degraded mode per catalogue ("drafts-only, no auto-send" —
   140	       Sourcing-Scout-specific interpretation: skip Bullhorn source +
   141	       continue with the other 2 active sources, since Sourcing Scout has
   142	       no auto-send path of its own; the "drafts-only" framing maps to
   143	       "report-only with Bullhorn data omitted from the sourcing set")
   144	     - ESC_REED_AUTH (catalogue §2.7): blocking → degraded mode (cached
   145	       Reed search results only)
   146	     - ESC_CVLIBRARY_AUTH (catalogue §2.7): blocking → degraded mode
   147	       (cached CV-Library search only)
   148	     - ESC_LINKEDIN_AUTH (catalogue §2.7): NOT fired at v1.0 — reserved
   149	       for the v1.1+ LinkedIn vendor integration
   150	   → if MULTIPLE sources are in degraded mode AND the remaining live
   151	     sources cannot produce ≥5 candidates: ESC_AGENT_OUTPUT_SHAPE +
   152	     return partial report with exception note (Gate A floor violated)
   153	   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
   154	     "sources_ok:<N>/4; degraded:<list>; linkedin:v1.0_no_op")
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
   169	4. LinkedIn search — explicit NO-OP at v1.0 (deferred to v1.1+)
   170	   → structurally present per the Janitor Step 7 NO-OP pattern: emits an
   171	     empty result set into the Step 7 aggregate; the §3 report shows the
   172	     LinkedIn row as "deferred to v1.1+; vendor pending"
   173	   → no vendor call, no cache, no auth, no ESC at v1.0 (Proxycurl shut
   174	     down 2025 per the v1.0 readiness caveat; v1.1+ vendor selection
   175	     pending — Lix / Phantombuster / Apify / Sales Navigator)
   176	   → hh_decision_output("linkedin_query", "brief:<id>",
   177	     "results:0; no_op; reason:v1.0_caveat_proxycurl_shutdown;
   178	      vendor_selection:v1.1_deferred")
   179	
   180	5. Reed query
   181	   → reed.search_candidates(query=brief_dimensions, location, salary_band)
   182	   → up to 30 candidates
   183	   → ESC_REED_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
   184	     (payload.upstream='reed')
   185	   → hh_decision_output("reed_query", "brief:<id>", "results:<N>")
   186	
   187	6. CV-Library query
   188	   → cvlibrary.search_candidates(query, location, salary_band)
   189	   → up to 30 candidates
   190	   → ESC_CVLIBRARY_AUTH on auth fail; ESC_RATE_LIMIT_HIT on quota
   191	     (payload.upstream='cv-library')
   192	   → hh_decision_output("cvlibrary_query", "brief:<id>", "results:<N>")
   193	
   194	7. Aggregate + dedupe
   195	   → merge all sources into single candidate set
   196	   → dedupe across sources by (name + email) OR (name + phone) OR
   197	     (LinkedIn URL) — same fuzzy matcher as Janitor (confidence ≥0.85)
   198	   → annotate each row with source provenance (e.g., "from Bullhorn + Reed
   199	     match" if found in both)
   200	   → hh_decision_output("aggregate_dedupe", "brief:<id>",
   201	     "pre_dedupe:<N>; post_dedupe:<N>")
   202	
   203	8. "Do not contact" filter (pre-outbound sourcing filter; NOT outbound refusal)
   204	   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
   205	     (concept referenced by autosend-policy.yaml red-tier
   206	     `send_to_blocked_recipient` action_type + ESC_DNC_FILTER_HIT catalogue
   207	     §2.10; the config key IS registered in the canonical authority
   208	     `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 434;
   209	     `allowed_keys` array lines 432-445; element-type validation block
   210	     lines 510-523).
   211	     v0.4-pending status applies ONLY to `auto_source_on_brief_create`
   212	     (the webhook auto-source trigger config), NOT to `blocked_recipients`.
   213	     Postgres-backed per ADR-002 vault/Postgres split — NOT vault markdown.
   214	     `blocked_recipients` is now declared in `vertical-schema.v0.3-supplement.yaml`
   215	     lines 823-840.)
   216	   → remove any candidate matching any DNC identifier from the sourcing list
   217	   → log dropped candidates to exception list in §3 output
   218	   → NOTE: ESC_DNC_FILTER_HIT is catalogue §2.10 reserved for OUTBOUND SEND
   219	     REFUSAL specifically. Sourcing Scout filters DNC matches AT SOURCING
   220	     TIME (pre-outbound); no outbound send attempt occurs. v0.3 disposition:
   221	     log DNC drops in exception list only; no ESC fire. W4-polish backlog:
   222	     add ESC_SOURCING_DNC_FILTER for the pre-outbound case.
   223	   → hh_decision_output("dnc_filter", "brief:<id>",
   224	     "dropped:<N>; kept:<N>")
   225	
   226	9. LLM ranking + rationale generation (per candidate)
   227	   → for top 15 by source-aggregated confidence: generate per-candidate
   228	     rationale ≥50 words
   229	   → prompt = (brief context + candidate profile + voice corpus + tone rules)
   230	   → voice classifier scores rationale (≥0.75 — hard-enforced when a tenant
   231	     voice corpus exists; empty voice_corpus → voice_score recorded as
   232	     "unscored"/no_corpus, never faked — warn-when-unscored is the accepted
   233	     v1.0 gate behaviour per spec-003 §5)
   234	   → ESC_VOICE_DRIFT if a computed classifier score <0.75 after 3 retries;
   235	     drop candidate from final list
   236	   → hh_decision_output("candidate_proposed", "candidate:<bullhorn_id|external_ref>",
   237	     "source:<bullhorn|linkedin|reed|cvlibrary>; confidence:<N>; voice_score:<N>; included:<bool>") — emitted PER CANDIDATE per §3 contract (one row per candidate proposed; dropped candidates also get a row with included=false + drop_reason)
   238	
   239	10. Output assembly + Gate A validation
   240	    → ensure 5-15 candidates remaining after Step 9
   241	    → ensure each has working contact method (email validated via simple
   242	      regex + domain MX check; phone validated via E.164 format)
   243	    → ensure each rationale ≥50 words
   244	    → if any condition fails: write partial draft to /tmp, then emit the
   245	      mandatory audit row hh_decision_action("validate_gate_a_fail",
   246	      "brief:<id>", payload_hash, "ESC_AGENT_OUTPUT_SHAPE; <failed_condition>")
   247	      — output-shape violation per catalogue line 184 (distinct from
   248	      ESC_SCHEMA_VIOLATION, reserved for vertical-schema field-constraint
   249	      violations at write time; audit row mandatory per master brief §8.1
   250	      Change 2 + autosend-policy.yaml lines 119-123) — then abort (exit 1)
   251	      BEFORE the scout_report row below
   252	    → write Markdown report to vault path per §3
   253	    → hh_decision_output("scout_report", report_path, "N candidates from M sources")
   254	
   255	11. Session close + notification
   256	    → operator notification per invocation source (Brain UI: in-app
   257	      notification; Telegram: reply with report path; webhook: bus event back)
   258	    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
   259	      "N=<N> sources_used=<M>")
   260	    → exit code 0

exec
/bin/zsh -lc "pwd && rg --files | rg '("'^agents/recruitment/sourcing-scout/|agents/_shared/escalation-codes.md|agents/_shared/voice-loader.sh|agents/_shared/hook-helpers.sh|autosend-safety-policy.yaml|vertical-schema|ULTRAPLAN|master|v1.0-kill|migrations/v0.2-to-v0.3.sql|docs/decisions/ADR-002|docs/decisions/ADR-003|docs/decisions/ADR-004)'"'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
/Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
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
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/specs/ULTRAPLAN.md
logs/codex-ratification/round-2-autonomous/docs_decisions_v1-0-kill-criterion-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-v0-2-supplement-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md

codex
The document is a built-bundle contract rather than a pure scaffold, so I’m checking both the written contract and whether the live sibling files match the load-bearing gate and audit claims.
exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '261,520p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '540,560p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
   261	```
   262	
   263	---
   264	
   265	## §5 — Gates
   266	
   267	### Gate A — validate.sh (hard-fail before action)
   268	
   269	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
   270	
   271	- **"5–15 candidates returned per brief"** (count within range)
   272	- **"each has a working contact method"** (email format + MX check OR E.164 phone OR LinkedIn URL OR Bullhorn bullhorn_id-with-contact)
   273	- **"each has rationale ≥ 50 words"**
   274	- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
   275	- All rationales pass voice classifier ≥0.75 — **hard-enforced WHEN a tenant voice corpus exists**. Empty `voice_corpus` → rationales carry `unscored`/`no_corpus` (a score is never faked) and G4 warns-and-passes: **warn-when-unscored is the accepted v1.0 gate behaviour** (spec-003 §5 "hard (warn-when-unscored)" + the Cash Conductor honesty precedent); G4 becomes hard-scoring once a corpus is loaded
   276	- No PII outside firm boundary in rationale text → fires `ESC_PII_LEAKAGE_RISK` (BLOCKING per catalogue §2.5 lines 148-154; halts immediately, not warn-only output-shape)
   277	- No enabled live source returns 0 candidates WITHOUT a recorded degradation exception note (sources in degraded mode per §4 Step 2 are expected to return 0 and don't trip Gate A)
   278	
   279	Gate A failure routing by class:
   280	- PII leakage → `ESC_PII_LEAKAGE_RISK` (blocking; operator + ifos_oncall)
   281	- Output-shape failures (count not in 5-15, contact-method missing, rationale <50 words, voice classifier miss, all-source-failure-without-degradation) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)
   282	On any Gate A failure, `validate.sh` writes the partial draft to `/tmp` and emits the mandatory `hh_decision_action("validate_gate_a_fail", ...)` audit row carrying the ESC code (per master brief §8.1 Change 2 + autosend-policy.yaml lines 119-123) BEFORE aborting; operator review.
   283	
   284	**Build note (updated 2026-06-10; the original Cat-5 honesty note said `validate.sh` did not exist yet):** `agents/recruitment/sourcing-scout/validate.sh` is now LIVE — delivered by the W9 build slice (spec-003 §5) implementing G1-G7 against the contract above, exercised by `scripts/run-scout-gate-a-test.sh` (PASS + 9 fail classes; deterministic DB-backed fixtures). Not yet production-proven: no live run has occurred (creds EMPTY; live smoke founder-gated).
   285	
   286	### Gate B — Outcome threshold (success metric, not block)
   287	
   288	Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
   289	
   290	Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply (v1.0). Aggregate over rolling 30-day window per tenant. NOTE: Bullhorn-note feedback is NOT a v1.0 path (Sourcing Scout is read-only on Bullhorn per §1 + §6 contracts; would require write capability not in v1.0 scope).
   291	
   292	Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing) — operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
   293	
   294	Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
   295	
   296	---
   297	
   298	## §6 — Escalation codes
   299	
   300	Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
   301	
   302	| Code | Trigger | Severity | Routing |
   303	|---|---|---|---|
   304	| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (per catalogue §2.3) | operator + ifos_oncall |
   305	| `ESC_LINKEDIN_AUTH` | v1.1+ LinkedIn vendor session/OAuth fail — NOT fired at v1.0 (§4 Step 4 is an explicit NO-OP; no vendor) | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   306	| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   307	| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   308	| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / reed / cv-library; linkedin reserved for v1.1+) | warn | operator_chat_id |
   309	| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
   310	| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   311	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
   312	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
   313	| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
   314	
   315	Sourcing Scout does NOT use:
   316	
   317	- `ESC_AUTOSEND_*` — no auto-send actions; pure read + report
   318	- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
   319	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
   320	- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
   321	- `ESC_DNC_FILTER_HIT` — per catalogue §2.10 reserved for outbound send refusal specifically; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish backlog: add ESC_SOURCING_DNC_FILTER.
   322	
   323	---
   324	
   325	## §7 — Voice + tone constraints
   326	
   327	Step 9 (per-candidate rationale generation) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   328	
   329	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
   330	  - No demographic inference (age, gender, nationality, ethnicity, family status) — Equality Act 2010 compliance
   331	  - No salary-band reference unless explicitly supplied by candidate
   332	  - No claims about candidate intent ("looking to leave their role") without evidence in source data
   333	  - No mention of competing agency placements except in risk-flag context
   334	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
   335	- **Voice-drift detection (classifier-only):** per `vertical-schema.v0.3-supplement.yaml` lines 597-606 (§2a access-list amendment) + 728-737 (access matrix), Sourcing Scout has `recent_edit` access of **W** (writes its rationale drafts) but **not R**, so it does NOT read consultant edit history via `hh_load_recent_edits`. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries; scores are only computed when the tenant voice corpus is non-empty — empty corpus → `unscored`/`no_corpus` recorded and `validate.sh` G4 warns-and-passes (the accepted v1.0 warn-when-unscored gate behaviour per spec-003 §5; hard-scoring resumes once a corpus is loaded). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. The cron — not Sourcing Scout — reads edit history for analytics + canary threshold tuning.
   336	
   337	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   338	
   339	---
   340	
   341	## §8 — Build dependencies (W9 prerequisites — table updated 2026-06-10 post-W9-build)
   342	
   343	| Dependency | Source | Status |
   344	|---|---|---|
   345	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   346	| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
   347	| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
   348	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   349	| **Bullhorn Sub-decisions A+B Accepted** | Sub-decision A RESOLVED 2026-06-02; B pending | ⏸ |
   350	| Bullhorn MCP read capability | `packages/mcp-connectors/bullhorn` package exists; Sourcing-Scout OAuth CLI bridge + creds pending → Step 2 degraded-skip | ⏸ (partial) |
   351	| **LinkedIn vendor selection + commercial signup** (Proxycurl shut down 2025) | Founder commercial, v1.1+ | DEFERRED v1.1+ |
   352	| **Reed.co.uk commercial signup** + API access | Founder commercial (creds EMPTY) | ⏸ |
   353	| **CV-Library commercial signup** + API access | Founder commercial (creds EMPTY at last names-only verification) | ⏸ |
   354	| LinkedIn vendor MCP connector | v1.1+ after vendor selection | DEFERRED v1.1+ |
   355	| Reed MCP connector | `packages/mcp-connectors/reed` v0.1.0, tests green | ✅ (creds EMPTY) |
   356	| CV-Library MCP connector | `packages/mcp-connectors/cv-library` v0.1.0 + `dist/cli.js` bridge | ✅ (creds EMPTY; live smoke founder-gated) |
   357	| Source-abstraction layer (Night Sourcer reuse) | `_scout_query_source()` in cycle.sh (W9 build slice) | ✅ (ADR per §9 Q6 still to be authored) |
   358	| Per-tenant source credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   359	| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
   360	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   361	| `validate.sh` Gate A logic | W9 build slice (spec-003 §5; G1-G7) | ✅ |
   362	| `context.sh` hydration | W9 build slice (canonical `tenant_adapters` SELECTs) | ✅ |
   363	| `cycle.sh` orchestration (11-step) | W9 build slice (spec-003 §4) | ✅ |
   364	| 3 fixtures with golden outputs | W9 build slice + 3 DB-backed test suites | ✅ |
   365	
   366	**Post-W9-build note:** the four sibling-bundle deliverables (validate.sh, context.sh, cycle.sh, fixtures) WERE the W9 build slice and are delivered on this branch; the W9 build proceeded against deterministic fixtures per spec-003 §8 honest scope. The remaining ⏸ rows are FOUNDER/TENANT-ADMIN actions (commercial signups, creds, DNC population, voice corpus, ratifications) — they gate the first LIVE run and the §10 lifecycle transitions (Proposed → Accepted → In Force per the rewritten §10), not the fixture-backed build.
   367	
   368	---
   369	
   370	## §9 — Status + open questions
   371	
   372	**Status:** Proposed (W9 build slice COMPLETE on this branch — bundle LIVE per the build-state header; §10 status flip is founder-gated). Awaits Bullhorn Sub-decision B + 2 commercial signups (Reed + CV-Library; LinkedIn vendor deferred to v1.1+) + Q1 LOI + Codex re-ratification + founder approvals per §10.
   373	
   374	### Open questions for founder review
   375	
   376	| # | Question | Resolution path |
   377	|---|---|---|
   378	| Q1 | All three v1.0 sources required? Reed + CV-Library are UK-recruitment-specific; LinkedIn deep-data is deferred to v1.1+ post-Proxycurl-shutdown. Could v1.0 ship with Bullhorn + one job board only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
   379	| Q2 | LinkedIn vendor pricing (v1.1+) — the original Proxycurl model (~$39/mo for 5,000 credits, ~$20-50/day at peak per consultant) is void post-shutdown. Per-tenant budget cap for the v1.1+ vendor? | Deferred to v1.1+ vendor selection (Lix / Phantombuster / Apify / Sales Navigator); cost ceiling per brief remains the design constraint whichever vendor is chosen. |
   380	| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
   381	| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
   382	| Q5 | Gate B 6-of-10 metric — measured via consultant feedback (Brain UI v1.0 doesn't have feedback UX yet) | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful" → `decision_log` row via `consultant_feedback` green-tier action_type. v1.1: Brain UI button. NOTE: Bullhorn-note-based feedback is NOT a v1.0 path — Sourcing Scout is read-only on Bullhorn (no write capability); Bullhorn note creation would require tools.yaml write capability + autosend/decision logging which v1.0 explicitly excludes. |
   383	| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. A new ADR (number assigned at authoring time; not ADR-006 — that's Diagnostic Gate A) at W9 build start documenting the source-abstraction interface. |
   384	| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `date_last_modified_at < now() - 90 days` (per schema line 100) to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side modification-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |
   385	
   386	### Gotchas (carried forward from ULTRAPLAN A5 line 555)
   387	
   388	1. **LinkedIn vendor rate limits (v1.1+).** The original Proxycurl per-credit quota model is void post-shutdown; the underlying constraint stands — deep profile fetches cost more than searches, so plan a cost ceiling per brief for whichever v1.1+ vendor is selected.
   389	2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
   390	3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.
   391	
   392	---
   393	
   394	## §10 — When this document ratifies
   395	
   396	Per `.codex/ratification/review-agent-bundle.md` skill (built 2026-05-24, commit `825ebd4`). **Single post-W9 criteria set (rewritten 2026-06-10).** The pre-build "Ratified-as-Scaffold" intermediate state (introduced at R9) applied to the scaffold-only document; the W9 build slice is COMPLETE on this branch, so the unit that ratifies now is the BUILT bundle (this agent.md + 6 sibling files + 3 fixtures), not the scaffold. Lifecycle:
   397	
   398	1. **Proposed** — CURRENT state. W9 build slice complete; build-gate GREEN; three deterministic DB-backed fixture suites green. No live API call has been made by this bundle; creds EMPTY.
   399	
   400	2. **Proposed → Accepted** when ALL of:
   401	   - Codex review-agent-bundle returns RATIFIED on the built bundle (this agent.md + `tools.yaml` + `context.sh` + `validate.sh` + `cycle.sh` + `cleanup.sh` + `README.md` + 3 fixtures)
   402	   - Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B feedback UX)
   403	   - Q6: source-abstraction-layer ADR drafted + ratified (new ADR — not the same as ADR-006 which is Diagnostic Gate A; number assigned at authoring time)
   404	
   405	   **No production-run requirement at this state** — Accepted certifies the built, Codex-ratified, founder-approved bundle. (Q2 — LinkedIn vendor cost model — is deferred to v1.1+ vendor selection per §9 and does not gate Accepted.)
   406	
   407	3. **Accepted → In Force** when ALL of:
   408	   - First production brief processed end-to-end against the migration-test tenant, with live-smoke evidence (live smoke is founder-gated: Reed + CV-Library commercial signups + Bullhorn Sub-decision B + creds provisioned)
   409	   - Gate B feedback loop operational (Telegram /scout-feedback path; Brain UI in v1.1)
   410	   - First production render against a pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
   411	
   412	The **Status** field at the top of this document remains **Proposed** — every lifecycle flip is founder-gated.
   413	
   414	*End of Sourcing Scout agent.md draft.*

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

exec
/bin/zsh -lc "rg -n \"Sourcing Scout|W9|sourcing|Scout\" docs agents -g '*.md' | head -80" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:122:| Sourcing Scout | ~5-7 (count regex 50) | `logs/codex-ratification/20260524T1024...` |
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
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:419:4. **Catalogue v2 widening for ESC_DNC_FILTER_HIT + Sourcing Scout auth severity** — Cat-γ continuations
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:430:| Sourcing Scout | Pre-Build-Round-9-Reviewed | 5 (Cat-α Q7 + bullhorn-path conflict + Cat-γ DNC + Cat-ε per-candidate row + auth severity disagreement) | Mechanical Q7 fix + Bullhorn-path realignment + ESC widening 2 |
docs/specs/ULTRAPLAN.md:72:- **The file bus.** Inter-agent handoff via shared filesystem directories. No queue, no API, no serialisation tax. Brief Decoder writes a parsed-brief file; Sourcing Scout's `FastChecker` polls it up at the configured cadence (default 1000ms `pollInterval`, configurable per agent); result lands in a sub-directory the Concierge is polling. Four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound.
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
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:158:- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
agents/_shared/escalation-codes.md:257:- **Severity:** **blocking** — Sourcing Scout enters degraded mode (no profile fetches; cached only)
agents/_shared/escalation-codes.md:262:- **Recovery:** founder reauthenticates LinkedIn via Sourcing Scout admin flow
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:402:- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
agents/_shared/escalation-codes.md:466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/RISK-REGISTER.md:37:| 14 | **Proxycurl shutdown (LinkedIn lawsuit Jan 2025) breaks the Sourcing Scout v1.0 LinkedIn deep-data path** — original v1.0 Sourcing Scout listed 4 sources (Bullhorn + LinkedIn/Proxycurl + Reed + CV-Library). Proxycurl shut down following LinkedIn's January 2025 lawsuit against Nubela (~50% of revenue was LinkedIn scraping; see nubela.co/blog/goodbye-proxycurl/). Successor product NinjaPear (same team) does NOT carry LinkedIn data. No legally-clear LinkedIn-scraping vendor identified as of 2026-06-02. | Materialised 2026-06-02 (vendor gone) | Low → Medium (depends on whether Gate B ≥6 of 10 advance holds without LinkedIn data; unknown until pilot data lands) | Sourcing Scout Gate B underperforms (<6 of 10 advance per ULTRAPLAN A5 line 553) at first-pilot deployment AND analysis attributes gap to missing LinkedIn deep-data. | **v1.0 disposition** (per founder 2026-06-02 + `agents/recruitment/sourcing-scout/agent.md` v1.0 caveat at commit `622a2e7`): defer LinkedIn deep-data to v1.1+; v1.0 Sourcing Scout operates against 3 active sources (Bullhorn passive-match + Reed + CV-Library). v1.1+ vendor selection at W8-9 build-slice decision; candidate vendors named: Lix, Phantombuster, Apify (LinkedIn-aware contracts), or LinkedIn Sales Navigator enterprise API (much higher cost). §4 Step 4 (LinkedIn search) is a NO-OP in v1.0; §3 output template shows LinkedIn row as "deferred to v1.1+; vendor pending". | **Mitigated by deferral; v1.1+ vendor decision queued for W8-9 build slice.** |
docs/RISK-REGISTER.md:70:- 2026-06-03 (W5 Day 34) — **W5 CLOSED.** All 5 v1.0 agent bundles (CC + Concierge + Janitor + Scribe + Sourcing Scout) at SKELETON tier (6 files + 3 fixtures each); 3 new MCP scaffolds (@ifos/bullhorn + @ifos/workos + @ifos/granola); v0.4 schema supplement LIVE on production VPS (peer-auth migration apply 2026-06-03; 6/6 trigger acceptance tests passed). No new risks materialised from W5. **Risk #3 update:** founder confirmed Jack lane "on track" 2026-06-03; Trigger 1 fires today (calendar gate), founder closes LOI directly — Risk #3 status unchanged at HIGH/MATERIALISED pending actual signature. **Pre-existing test flake surfaced (NOT a new risk):** `@ifos/diagnostic-generator` `tests/generate.test.ts` § "composes a §12 conversation opener that anchors to a real signal" failing since 2026-06-01 commit `2688b6a` — LLM non-determinism (test fixture "Test Anchor Firm" triggers legitimate disclaimer pattern from the LLM; test regex `/Hi.*?Test Anchor Firm|Hi —/` doesn't match). Doesn't affect production behaviour (production uses real firm names with real Companies House data). Three fix paths queued for a future session (relax regex / mock LLM / use real firm name); deferred per Karpathy surgical-changes discipline + /goal STOP rule (out of W5 marathon scope). **W6+ external dependencies:** Bullhorn dev-support reply (~by 2026-06-09); Reed + CV-Library + Xero + QB + TrueLayer commercial signups per `docs/operations/founder-api-signups-2026-06-03.md`; Granola browser OAuth dance (requires Claude Code restart); WorkOS staging key; Cluster F-tris Codex ratification (manifest entry added). vitest at W5 close: 259/260 (99.6%) across 11 packages.
docs/specs/_archive-build-handoff.md:381:| 5 | **Sourcing Scout** | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
agents/recruitment/sourcing-scout/README.md:1:# Sourcing Scout — directory README
agents/recruitment/sourcing-scout/README.md:3:**Status:** W9 build slice COMPLETE (spec-003) — full bundle LIVE, pending Codex
agents/recruitment/sourcing-scout/README.md:6:Request-response passive sourcing: brief in → ranked 5-15 candidate Markdown
agents/recruitment/sourcing-scout/README.md:39:- DNC drops at sourcing time → exception list only; no ESC fire
agents/recruitment/sourcing-scout/README.md:49:*End of Sourcing Scout README.*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/specs/PRODUCT-SPEC.md:49:| **IntelForce Recruit** | Front office — sales, sourcing, candidate comms, BD, cash | 13 agents | Solo £499 → Scale £6,950 |
docs/specs/PRODUCT-SPEC.md:92:#### R4. The Night Sourcer — overnight sourcing while you sleep
docs/specs/PRODUCT-SPEC.md:95:- **Revenue story:** "We do a full evening of sourcing on every brief in your pipeline, every night. You walk in to a day of outreach already drafted instead of a day of sourcing." Modelled: time-to-shortlist drops from 5 days to 2 days; 30% more briefs run concurrently per consultant.
docs/specs/PRODUCT-SPEC.md:96:- **Time saved:** 8–15 hours/week per consultant of sourcing drag.
docs/specs/PRODUCT-SPEC.md:99:- **Per-tenant config:** sourcing playbook path, source budget (LinkedIn / Reed / CV Library / GitHub / sector-specific), candidate-rejection patterns, must-haves vs nice-to-haves taxonomy, draft tone overrides per role family.
docs/specs/PRODUCT-SPEC.md:101:#### R5. Sourcing Scout (daytime form) — request-response sourcing during the day
docs/specs/PRODUCT-SPEC.md:103:- **Output contract:** Consultant pings "find me 5 candidates for this brief" via the Brain UI or Telegram → 10–15 minute turnaround → ranked shortlist with sourcing rationale, source link, and any prior interaction history with each candidate.
docs/specs/PRODUCT-SPEC.md:140:- **Revenue story:** "Your sourcing runs become 3× more productive against clean data. One reactivated dormant-but-clean candidate per month covers the tier price." Plus: removes the compliance liability of stale records.
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:400:| 3 | Inter-agent file bus — agents hand work to each other via shared directories | Brief Decoder → Sourcing Scout → Concierge handoff; Triage → specialist-agent routing |
docs/specs/PRODUCT-SPEC.md:476:- Sourcing Scout (daytime form)
docs/specs/PRODUCT-SPEC.md:486:3. **Night Sourcer** (2 weeks) — overnight extension of Sourcing Scout
docs/specs/PRODUCT-SPEC.md:526:5. **Sourcing Scout (daytime)** — "Shortlist in 15 minutes instead of by end of week."
docs/specs/PRODUCT-SPEC.md:530:9. **The Janitor** — "Your sourcing runs become 3× more productive against clean data."
agents/recruitment/sourcing-scout/agent.md:1:# Sourcing Scout — request-response passive sourcing
agents/recruitment/sourcing-scout/agent.md:4:**Build state:** W9 build slice COMPLETE (spec-003; branch `worktree-agent-a45354564e8f66257`, 2026-06-10) — all 6 sibling bundle files + 3 fixtures LIVE; build-gate GREEN; three deterministic DB-backed fixture suites green. Prior contract history: Day-20 W4 bilateral pass + R19 substantive fix; R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`; R19 (2026-05-24) added the `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Still awaits: Q1 LOI + Bullhorn Sub-decision B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + Reed + CV-Library commercial signups (creds EMPTY; live smoke founder-gated) + Codex re-ratification of the built bundle + founder approvals per §10.
agents/recruitment/sourcing-scout/agent.md:5:**Reading-discipline note (updated 2026-06-10 at W9 build; originally added 2026-06-03 per CC + Concierge + Janitor + Scribe precedent):** this `agent.md` is the **CONTRACT** that the W9 build slice implemented against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml` + `README.md`) + 3 fixtures are **LIVE** — the W9 build slice (spec-003, this branch) replaced every `TODO(W9)` marker with live implementation; three deterministic DB-backed fixture suites (`scripts/run-scout-{dedupe,gate-a,degraded}-test.sh`) are green under build-gate. **Per-component build state, honestly stated:** `@ifos/bullhorn` — implemented connector package (`packages/mcp-connectors/bullhorn`); the Sourcing-Scout OAuth CLI bridge is not built and creds are EMPTY → cycle.sh Step 2 degraded-skip. `@ifos/reed` — implemented connector package (`packages/mcp-connectors/reed`, v0.1.0, tests green); creds EMPTY → degraded-skip until founder signup. `@ifos/cv-library` — implemented connector package + built `dist/cli.js` bridge (`packages/mcp-connectors/cv-library`, v0.1.0); the designated v1.0 live source, but creds EMPTY at last names-only verification → live smoke founder-gated. None of the three is production-proven: no live API call has been made by this bundle; all coverage is fixture-driven (`IFOS_SCOUT_FIXTURE_*`). **VENDOR NOTE:** the v1.0 contract is THREE active sources (Bullhorn + Reed + CV-Library); LinkedIn is structurally present as an explicit NO-OP only — cycle.sh Step 4 emits `linkedin_query` (`results:0; no_op`) per the Janitor Step 7 NO-OP pattern; vendor selection deferred to v1.1+ per the caveat at lines 6-8. **Live audit-marker set emitted by cycle.sh:** `session_start`, `brief_ingested`, `auth_refresh_complete`, `bullhorn_query`, `linkedin_query` (no-op), `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `candidate_proposed` (one row PER candidate), `scout_report`, `scout_run_complete`, plus `validate_gate_a_fail` (Gate A failure only) and `operator_notify_telegram` (when configured). Pure read+report agent — no yellow/orange/red action_types; the cleanup action name `sourcing_scout_cleanup` is NOT a registered autosend-policy action_type — registration is a founder-gated policy decision (a `future_registration` entry in tools.yaml, not an action_type claim); `cleanup.sh` emits `hh_decision_output` until it lands. `context.sh` uses the canonical `tenant_adapters` SELECT path (with `IFOS_FORCE_*` fixture fallbacks retained for tests) — `bullhorn_corporation_id` v0.4-allowlisted (LIVE on VPS commit `a1bbcf6`) + `blocked_recipients` v0.3-allowlisted (LIVE on VPS). §10 lifecycle status remains **Proposed** pending Codex re-ratification of the built bundle + founder approvals — the status flip is founder-gated.
agents/recruitment/sourcing-scout/agent.md:9:**v1.0 disposition (per founder decision 2026-06-02):** LinkedIn deep-data is **DEFERRED to v1.1+**. v1.0 Sourcing Scout operates against **THREE active sources** (Bullhorn-candidate passive-match + Reed + CV-Library), not four. The §1 output contract's "5-15 candidates" Gate A target is preserved; Reed + CV-Library + Bullhorn passive-match combined are sufficient at v1.0 pilot scale (≤3 tenants). LinkedIn-vendor selection for v1.1+ takes place at W8-9 when the Sourcing Scout build slice forces the choice and we have more clarity on the post-lawsuit legal landscape (candidate vendors: Lix, Phantombuster, Apify with LinkedIn-aware contracts, or LinkedIn's own Sales Navigator enterprise API at much higher cost). Until that decision: §4 Step 4 (LinkedIn search) is an explicit structurally-present NO-OP in v1.0; the ranked-list assembly at Step 6 weights the 3 active sources accordingly; the §3 output template still shows the LinkedIn row but populates it as "deferred to v1.1+; vendor pending" rather than a scraped result. Gate B target (≥6 of 10 advance per ULTRAPLAN A5 line 553) unchanged at v1.0 — the marginal contribution of LinkedIn deep-data is unknown until pilot data lands; v1.1+ vendor selection partly informed by whether Gate B underperforms without it.
agents/recruitment/sourcing-scout/agent.md:16:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:26:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from THREE active v1.0 sources** (Bullhorn ATS passive-match read; Reed.co.uk API; CV-Library API) — LinkedIn is structurally present as an explicit NO-OP row only (deferred to v1.1+ per the vendor caveat above; §4 Step 4 emits `linkedin_query` with `results:0; no_op`). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:34:Brain UI v1.0 "Source candidates" button on any brief detail page → POST internal API → Sourcing Scout webhook.
agents/recruitment/sourcing-scout/agent.md:45:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables `auto_source_on_brief_create`. v0.4-supplement-pending (config key not yet registered); webhook-trigger code path is BLOCKED until v0.4 supplement lands. v1.0 invocation is Brain UI button + Telegram only.
agents/recruitment/sourcing-scout/agent.md:50:ifosctl sourcing-scout source --tenant <slug> --brief-id <id>
agents/recruitment/sourcing-scout/agent.md:51:ifosctl sourcing-scout source --tenant <slug> --description "<free-text>"
agents/recruitment/sourcing-scout/agent.md:64:One output per invocation. Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md`. Structure:
agents/recruitment/sourcing-scout/agent.md:67:# Sourcing Scout — <Brief title>
agents/recruitment/sourcing-scout/agent.md:138:     - ESC_BULLHORN_AUTH (catalogue §2.3): blocking → Sourcing Scout
agents/recruitment/sourcing-scout/agent.md:140:       Sourcing-Scout-specific interpretation: skip Bullhorn source +
agents/recruitment/sourcing-scout/agent.md:141:       continue with the other 2 active sources, since Sourcing Scout has
agents/recruitment/sourcing-scout/agent.md:143:       "report-only with Bullhorn data omitted from the sourcing set")
agents/recruitment/sourcing-scout/agent.md:203:8. "Do not contact" filter (pre-outbound sourcing filter; NOT outbound refusal)
agents/recruitment/sourcing-scout/agent.md:216:   → remove any candidate matching any DNC identifier from the sourcing list
agents/recruitment/sourcing-scout/agent.md:219:     REFUSAL specifically. Sourcing Scout filters DNC matches AT SOURCING

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '237,430p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '590,610p;720,742p;818,844p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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

 succeeded in 0ms:
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
   831	    notes: |
   832	      Per-tenant DNC (do not contact) list. v1.0 canonical source for outbound
   833	      send refusal (autosend-safety-policy §5 red-tier action_type
   834	      `send_to_blocked_recipient`) and pre-outbound sourcing filter (Sourcing
   835	      Scout §4 Step 8). Per ADR-002 vault/Postgres split — structured state in
   836	      Postgres, NOT vault markdown. Pre-v0.3 origin (the migration validator
   837	      `v0.2-to-v0.3.sql §5 allowlist` has accepted this key since v0.1); the
   838	      schema declaration in v0.3 supplement is added Day-20 W4 bilateral pass
   839	      closing Sourcing Scout R8 Codex Finding 1 (the key was load-bearing
   840	      across 4 agents but undeclared in any YAML).
   841	
   842	  janitor_last_run:
   843	    type: timestamp
   844	    required: false

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '70,110p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '428,446p;506,524p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
   428	DECLARE
   429	  c JSONB := NEW.config;
   430	  k TEXT;
   431	  elem JSONB;
   432	  allowed_keys TEXT[] := ARRAY[
   433	    -- v0.1 + v0.2 keys (forwarded; do not remove)
   434	    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
   435	    'janitor_last_run',
   436	    'pii_retention_days',  -- v0.2 PII purge runbook key
   437	    -- autosend-safety-policy.md keys
   438	    'approval_routing', 'approval_timeouts', 'sampling_rates',
   439	    -- v0.3 additions
   440	    'cash_conductor_last_run',
   441	    'concierge_last_poll',
   442	    'concierge_send_window'
   443	    -- diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   444	    -- (per ADR-006 Tier 2); v0.3 trigger does not allowlist this key
   445	  ];
   446	BEGIN
   506	      RAISE EXCEPTION 'janitor_last_run must be ISO-8601 timestamp string or null';
   507	    END IF;
   508	  END IF;
   509	
   510	  -- blocked_recipients: array of strings (pre-v0.3 origin; canonicalised here).
   511	  -- Safety-critical outbound DNC blocklist — the trigger hard-fails on non-string
   512	  -- elements rather than deferring to the tenant-admin wizard, matching the YAML
   513	  -- schema (items.type=string) and the key_skills/must_haves element checks above.
   514	  IF c ? 'blocked_recipients' THEN
   515	    IF jsonb_typeof(c->'blocked_recipients') != 'array' THEN
   516	      RAISE EXCEPTION 'blocked_recipients must be array';
   517	    END IF;
   518	    FOR elem IN SELECT * FROM jsonb_array_elements(c->'blocked_recipients') LOOP
   519	      IF jsonb_typeof(elem) != 'string' THEN
   520	        RAISE EXCEPTION 'blocked_recipients items must be strings; got %', jsonb_typeof(elem);
   521	      END IF;
   522	    END LOOP;
   523	  END IF;
   524	

codex
The main citations for ULTRAPLAN, schema keys, and ESC catalogue mostly resolve. I’m now checking the master brief line anchor and the executable bundle, because production-ready review rejects if `agent.md` promises more than the scripts enforce.
exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/validate.sh | sed -n '1,280p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Sourcing Scout agent — validate.sh (Gate A enforcement; W9 build slice LIVE)
     3	#
     4	# Status: LIVE per spec-003 §5 (W9 build slice).
     5	# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
     6	#
     7	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
     8	# hard-fail gate that runs BETWEEN cycle.sh Step 9 (rationale generation) and
     9	# Step 10's vault write. If any check fails, validate.sh emits the mandatory
    10	# hh_decision_action("validate_gate_a_fail", ...) audit row carrying the
    11	# dominant ESC class + the autosend_escalate ESC row, then exits non-zero;
    12	# cycle.sh holds the draft at /tmp instead of /vault and exits 1.
    13	#
    14	# Invocation contract:
    15	#   bash validate.sh <proposal_json>
    16	#
    17	# Inputs:
    18	#   - $1: path to JSON describing the proposed Sourcing Scout output. Shape:
    19	#         {
    20	#           "brief_id": "<bullhorn_brief_id_or_slug>",
    21	#           "tenant_slug": "<slug>",
    22	#           "candidates": [
    23	#             {
    24	#               "candidate_id": "<bullhorn_id_or_external_ref>",
    25	#               "source": "bullhorn | reed | cvlibrary",
    26	#               "name": "...",
    27	#               "contact_method": { "type": "email"|"phone"|"linkedin"|"bullhorn_internal",
    28	#                                   "value": "..." },
    29	#               "confidence": <0.0-1.0>,
    30	#               "voice_score": <0.0-1.0> | "unscored",
    31	#               "rationale_word_count": <int>,
    32	#               "rationale_body_preview": "..."   // first 500 chars for PII regex pass
    33	#             }
    34	#           ],
    35	#           "sources_active": <int>,    // count of sources NOT in degraded mode
    36	#           "sources_degraded": ["bullhorn"|"reed"|"cvlibrary"],
    37	#           "source_stats": { "<source>": {queried, returned, note}, ... }
    38	#         }
    39	#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_AGENT_DIR,
    40	#          CTX_FIRM_DOMAIN_WHITELIST (comma-separated),
    41	#          CTX_DNC_BLOCKED_RECIPIENTS (JSON array; loaded by context.sh from
    42	#          tenant_adapters.config.blocked_recipients)
    43	#
    44	# Exit codes:
    45	#   0  All Gate A checks pass; cycle.sh proceeds to the Step 10 vault write
    46	#   1  At least one check failed; validate_gate_a_fail + ESC_* rows emitted;
    47	#      cycle.sh writes partial draft to /tmp + exits 1
    48	#   2  validate.sh invocation error (bad args, missing file, etc.)
    49	#
    50	# Checks (per agent.md §5 Gate A + ULTRAPLAN A5 line 552 verbatim):
    51	#   G1 — Candidate count within [5, 15] inclusive
    52	#   G2 — Every candidate has a working contact method (email regex [+ MX
    53	#         best-effort] OR E.164 phone OR LinkedIn URL OR bullhorn_internal)
    54	#   G3 — Every candidate rationale ≥50 words
    55	#   G4 — Every candidate rationale voice classifier ≥0.75
    56	#         (hard when scored; WARN when unscored/no_corpus — spec-003 §5)
    57	#   G5 — No candidate matches tenant DNC list (defence-in-depth re-check)
    58	#   G6 — No PII outside firm boundary in any rationale (BLOCKING)
    59	#   G7 — No enabled live source returned 0 WITHOUT a degradation note; and at
    60	#         least one source contributed or recorded a degradation
    61	
    62	set -uo pipefail
    63	
    64	# ────────────────────────────────────────────────────────────────────────
    65	# Pre-flight
    66	# ────────────────────────────────────────────────────────────────────────
    67	
    68	if [[ $# -lt 1 ]]; then
    69	  printf 'sourcing-scout/validate.sh: usage: validate.sh <proposal_json>\n' >&2
    70	  exit 2
    71	fi
    72	
    73	readonly PROPOSAL="$1"
    74	
    75	if [[ ! -f "${PROPOSAL}" ]]; then
    76	  printf 'validate.sh: proposal not found at %s\n' "${PROPOSAL}" >&2
    77	  exit 2
    78	fi
    79	
    80	if [[ -z "${CTX_TENANT_SLUG:-}" || -z "${CTX_AGENT_NAME:-}" ]]; then
    81	  printf 'validate.sh: CTX_TENANT_SLUG or CTX_AGENT_NAME unset\n' >&2
    82	  exit 2
    83	fi
    84	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    85	  printf 'validate.sh: CTX_AGENT_DIR unset\n' >&2
    86	  exit 2
    87	fi
    88	command -v jq >/dev/null 2>&1 || { printf 'validate.sh: jq required\n' >&2; exit 2; }
    89	if ! jq -e . "${PROPOSAL}" >/dev/null 2>&1; then
    90	  printf 'validate.sh: proposal is not valid JSON\n' >&2
    91	  exit 2
    92	fi
    93	
    94	# Resolve _shared/ helpers (4-candidate fallback; matches sibling agents
    95	# per smoke-hotfix commit d7d52c5).
    96	_SHARED_DIR=""
    97	for _candidate in \
    98	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    99	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
   100	  "${CTX_AGENT_DIR}/../../_shared" \
   101	  "${CTX_AGENT_DIR}/../_shared" ; do
   102	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
   103	    _SHARED_DIR="${_candidate}"
   104	    break
   105	  fi
   106	done
   107	if [[ -z "${_SHARED_DIR}" ]]; then
   108	  printf 'validate.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
   109	  exit 2
   110	fi
   111	# shellcheck source=/dev/null
   112	source "${_SHARED_DIR}/hook-helpers.sh"
   113	
   114	# Track failures + warnings across all checks (collect all before exit for richer audit)
   115	declare -a FAILURES=()
   116	declare -a WARNINGS=()
   117	
   118	_fail() {
   119	  FAILURES+=("$1")
   120	  printf '  ✗ %s\n' "$1" >&2
   121	}
   122	_warn() {
   123	  WARNINGS+=("$1")
   124	  printf '  ! %s\n' "$1" >&2
   125	}
   126	_ok() {
   127	  printf '  ✓ %s\n' "$1"
   128	}
   129	
   130	# Dominant failure class for ESC routing (first hard fail wins, EXCEPT
   131	# G6 PII which is blocking and always takes precedence).
   132	ESC_CLASS=""
   133	_set_class() {
   134	  if [[ "$1" == "ESC_PII_LEAKAGE_RISK" ]]; then
   135	    ESC_CLASS="ESC_PII_LEAKAGE_RISK"
   136	  else
   137	    ESC_CLASS="${ESC_CLASS:-$1}"
   138	  fi
   139	}
   140	
   141	# Thresholds (per ULTRAPLAN A5 line 552)
   142	readonly MIN_CANDIDATES="5"
   143	readonly MAX_CANDIDATES="15"
   144	readonly MIN_RATIONALE_WORDS="50"
   145	readonly VOICE_SCORE_THRESHOLD="0.75"
   146	
   147	BRIEF_ID="$(jq -r '.brief_id // "unknown"' "${PROPOSAL}")"
   148	N_CANDIDATES="$(jq -r '.candidates | length' "${PROPOSAL}")"
   149	
   150	# ────────────────────────────────────────────────────────────────────────
   151	# G1 — Candidate count within [5, 15]
   152	# Below 5 → insufficient match diversity; above 15 → consultant cognitive
   153	# overload. Both → ESC_AGENT_OUTPUT_SHAPE (warn-tier; catalogue line 184).
   154	# ────────────────────────────────────────────────────────────────────────
   155	
   156	if [[ "${N_CANDIDATES}" -lt "${MIN_CANDIDATES}" || "${N_CANDIDATES}" -gt "${MAX_CANDIDATES}" ]]; then
   157	  _fail "G1: candidate count ${N_CANDIDATES} outside [${MIN_CANDIDATES}, ${MAX_CANDIDATES}]"
   158	  _set_class "ESC_AGENT_OUTPUT_SHAPE"
   159	else
   160	  _ok "G1: candidate count ${N_CANDIDATES} within [${MIN_CANDIDATES}, ${MAX_CANDIDATES}]"
   161	fi
   162	
   163	# ────────────────────────────────────────────────────────────────────────
   164	# G2 — Every candidate has a working contact method
   165	# email: RFC-5322-simplified regex (+ best-effort MX when IFOS_SCOUT_MX_CHECK=1
   166	#        and `host` is available — DNS lookups are skipped by default so the
   167	#        gate stays deterministic offline; documented honest scope)
   168	# phone: E.164 '^\+[1-9][0-9]{1,14}$'
   169	# linkedin: '^https://([a-z]{2,3}\.)?linkedin\.com/in/...'
   170	# bullhorn_internal: bullhorn_id resolves a contact server-side → accepted
   171	# ────────────────────────────────────────────────────────────────────────
   172	
   173	_g2_bad=0
   174	while IFS=$'\t' read -r _c_id _c_type _c_value; do
   175	  [[ -z "${_c_id}" ]] && continue
   176	  case "${_c_type}" in
   177	    email)
   178	      if [[ "${_c_value}" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
   179	        if [[ "${IFOS_SCOUT_MX_CHECK:-0}" == "1" ]] && command -v host >/dev/null 2>&1; then
   180	          _dom="${_c_value##*@}"
   181	          if ! host -t MX "${_dom}" >/dev/null 2>&1; then
   182	            _g2_bad=$((_g2_bad + 1))
   183	            _fail "G2: ${_c_id} email domain '${_dom}' has no MX record"
   184	          fi
   185	        fi
   186	      else
   187	        _g2_bad=$((_g2_bad + 1))
   188	        _fail "G2: ${_c_id} email fails format check"
   189	      fi ;;
   190	    phone)
   191	      if [[ ! "${_c_value}" =~ ^\+[1-9][0-9]{1,14}$ ]]; then
   192	        _g2_bad=$((_g2_bad + 1))
   193	        _fail "G2: ${_c_id} phone not E.164"
   194	      fi ;;
   195	    linkedin)
   196	      if [[ ! "${_c_value}" =~ ^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9_-]+/?$ ]]; then
   197	        _g2_bad=$((_g2_bad + 1))
   198	        _fail "G2: ${_c_id} linkedin URL fails format check"
   199	      fi ;;
   200	    bullhorn_internal)
   201	      if [[ -z "${_c_value}" ]]; then
   202	        _g2_bad=$((_g2_bad + 1))
   203	        _fail "G2: ${_c_id} bullhorn_internal with empty bullhorn id"
   204	      fi ;;
   205	    *)
   206	      _g2_bad=$((_g2_bad + 1))
   207	      _fail "G2: ${_c_id} has no working contact method (type='${_c_type}')" ;;
   208	  esac
   209	done < <(jq -r '.candidates[] | [.candidate_id, (.contact_method.type // "missing"), (.contact_method.value // "")] | @tsv' "${PROPOSAL}")
   210	if [[ "${_g2_bad}" -gt 0 ]]; then
   211	  _set_class "ESC_AGENT_OUTPUT_SHAPE"
   212	else
   213	  _ok "G2: every candidate has a working contact method"
   214	fi
   215	
   216	# ────────────────────────────────────────────────────────────────────────
   217	# G3 — Every rationale ≥50 words
   218	# Recomputes from rationale_body_preview when present (never trusts the
   219	# self-reported count alone); falls back to rationale_word_count.
   220	# ────────────────────────────────────────────────────────────────────────
   221	
   222	_g3_bad=0
   223	while IFS=$'\t' read -r _c_id _c_count; do
   224	  [[ -z "${_c_id}" ]] && continue
   225	  if [[ ! "${_c_count}" =~ ^[0-9]+$ ]] || [[ "${_c_count}" -lt "${MIN_RATIONALE_WORDS}" ]]; then
   226	    _g3_bad=$((_g3_bad + 1))
   227	    _fail "G3: ${_c_id} rationale ${_c_count:-0} words < ${MIN_RATIONALE_WORDS}"
   228	  fi
   229	done < <(jq -r '
   230	  .candidates[]
   231	  | [ .candidate_id,
   232	      ( if (.rationale_body // .rationale_body_preview // "") != ""
   233	        then ((.rationale_body // .rationale_body_preview) | [splits("\\s+") | select(. != "")] | length)
   234	        else (.rationale_word_count // 0) end ) ]
   235	  | @tsv' "${PROPOSAL}")
   236	if [[ "${_g3_bad}" -gt 0 ]]; then
   237	  _set_class "ESC_AGENT_OUTPUT_SHAPE"
   238	else
   239	  _ok "G3: every candidate rationale ≥${MIN_RATIONALE_WORDS} words"
   240	fi
   241	
   242	# ────────────────────────────────────────────────────────────────────────
   243	# G4 — Every rationale voice classifier ≥0.75
   244	# Hard when a numeric score is present; WARN when unscored (empty tenant
   245	# voice_corpus → a score cannot be honestly computed; spec-003 §5
   246	# "hard (warn-when-unscored)" + §8 never-fake disposition).
   247	# ────────────────────────────────────────────────────────────────────────
   248	
   249	_g4_bad=0
   250	_g4_unscored=0
   251	while IFS=$'\t' read -r _c_id _c_voice; do
   252	  [[ -z "${_c_id}" ]] && continue
   253	  if [[ "${_c_voice}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
   254	    if ! awk -v s="${_c_voice}" -v t="${VOICE_SCORE_THRESHOLD}" 'BEGIN{exit !(s>=t)}'; then
   255	      _g4_bad=$((_g4_bad + 1))
   256	      _fail "G4: ${_c_id} voice_score ${_c_voice} < ${VOICE_SCORE_THRESHOLD}"
   257	    fi
   258	  else
   259	    _g4_unscored=$((_g4_unscored + 1))
   260	  fi
   261	done < <(jq -r '.candidates[] | [.candidate_id, (.voice_score | tostring)] | @tsv' "${PROPOSAL}")
   262	if [[ "${_g4_bad}" -gt 0 ]]; then
   263	  _set_class "ESC_VOICE_DRIFT"
   264	elif [[ "${_g4_unscored}" -gt 0 ]]; then
   265	  _warn "G4: ${_g4_unscored} rationale(s) unscored (no tenant voice_corpus) — threshold not enforceable (documented enhancement)"
   266	else
   267	  _ok "G4: every rationale voice classifier ≥${VOICE_SCORE_THRESHOLD}"
   268	fi
   269	
   270	# ────────────────────────────────────────────────────────────────────────
   271	# G5 — No candidate matches tenant DNC list (defence-in-depth)
   272	# Step 8 already filtered against tenant_adapters.config.blocked_recipients;
   273	# re-check the FINAL list against CTX_DNC_BLOCKED_RECIPIENTS (email lowercase,
   274	# phone digits-normalised, name lowercase — same matching as Step 8).
   275	# ────────────────────────────────────────────────────────────────────────
   276	
   277	_DNC_JSON="${CTX_DNC_BLOCKED_RECIPIENTS:-[]}"
   278	if ! printf '%s' "${_DNC_JSON}" | jq -e 'type == "array"' >/dev/null 2>&1; then
   279	  _DNC_JSON="[]"
   280	fi

exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/cycle.sh | sed -n '1,340p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Sourcing Scout agent — cycle.sh (11-step per-brief orchestration; W9 LIVE)
     3	#
     4	# Status: LIVE per spec-003 §4 (W9 build slice).
     5	# Reading order: agent.md §1 (output contract) + §3 (Markdown report shape) +
     6	#         §4 (this workflow's 11 steps) + §5 (Gate A + Gate B) first.
     7	#
     8	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
     9	# produces output OR takes action MUST call hh_decision_* from
    10	# agents/_shared/hook-helpers.sh.
    11	#
    12	# v1.0 source disposition (spec-003 §8 honest scope):
    13	#   Bullhorn  — READ-ONLY agent; creds EMPTY today → per-source degraded-skip
    14	#               (ESC_BULLHORN_AUTH; never faked). Live path wired behind the
    15	#               @ifos/bullhorn CLI surface (lands with creds).
    16	#   LinkedIn  — NO-OP at v1.0 (Proxycurl shut down 2025; vendor selection
    17	#               deferred to v1.1+). Step 4 emits an explicit no-op audit row.
    18	#   Reed      — creds EMPTY today → degraded-skip (ESC_REED_AUTH).
    19	#   CV-Library— the live source. Wired through @ifos/cv-library dist/cli.js
    20	#               search-candidates; the orchestrator runs the live smoke
    21	#               post-build. Fixture override (IFOS_SCOUT_FIXTURE_CVLIBRARY)
    22	#               keeps every test deterministic without network/LLM.
    23	#
    24	# Source-abstraction layer (ULTRAPLAN A5 line 555 gotcha): Steps 3/5/6 all go
    25	# through ONE _scout_query_source() path over per-source mapping config; the
    26	# downstream aggregate/dedupe/rank/report logic is source-agnostic. Night
    27	# Sourcer (v1.1) reuses this shape.
    28	#
    29	# Deterministic test hooks (fixtures; documented, never used in production):
    30	#   IFOS_SCOUT_FIXTURE_BULLHORN / _REED / _CVLIBRARY — path to a JSON file
    31	#       carrying a unified-candidate array (or {ok, candidates}) for that
    32	#       source; marks the source live for the run without network.
    33	#   IFOS_SCOUT_FORCE_429_<SOURCE> = 1 — simulate a 429 on an otherwise-live
    34	#       source (ESC_RATE_LIMIT_HIT route; degraded cached_only).
    35	#   IFOS_SCOUT_FORCE_VOICE_SCORE — numeric voice score override for the Step 9
    36	#       voice-drift drop route (no classifier exists yet; corpus-empty runs
    37	#       record unscored/no_corpus, never a faked number).
    38	#
    39	# Invocation modes (per agent.md §2):
    40	#   mode=brain-ui | telegram | cli (default)  — take --brief-id OR --description
    41	#   mode=webhook — DEFERRED to v1.1+ (auto_source_on_brief_create not allowlisted)
    42	#
    43	# Output contract per agent.md §1 (READ THAT FIRST). One output per brief:
    44	#   Markdown report → /vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO>.md
    45	#   with ranked 5-15 candidates + per-candidate ≥50-word rationale +
    46	#   source breakdown + diagnostic exception list. Gate A failure → partial
    47	#   draft held at /tmp + exit 1 BEFORE the scout_report row.
    48	
    49	set -euo pipefail
    50	
    51	# ────────────────────────────────────────────────────────────────────────
    52	# Pre-flight: hydrate context + resolve _shared/ helpers
    53	# ────────────────────────────────────────────────────────────────────────
    54	
    55	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    56	  printf 'sourcing-scout/cycle.sh: CTX_AGENT_DIR unset\n' >&2
    57	  exit 2
    58	fi
    59	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    60	  printf 'sourcing-scout/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
    61	  exit 2
    62	fi
    63	: "${CTX_AGENT_NAME:=sourcing-scout}"
    64	export CTX_AGENT_NAME CTX_AGENT_DIR CTX_TENANT_SLUG   # inherited by validate.sh subprocess (Step 10)
    65	
    66	command -v jq >/dev/null 2>&1 || { printf 'cycle.sh: jq required\n' >&2; exit 2; }
    67	
    68	# Resolve _shared/ helpers (4-candidate chain per smoke-hotfix commit d7d52c5
    69	# mirrored from sibling agent bundles).
    70	_SHARED_DIR=""
    71	for _candidate in \
    72	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    73	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    74	  "${CTX_AGENT_DIR}/../../_shared" \
    75	  "${CTX_AGENT_DIR}/../_shared" ; do
    76	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    77	    _SHARED_DIR="${_candidate}"
    78	    break
    79	  fi
    80	done
    81	if [[ -z "${_SHARED_DIR}" ]]; then
    82	  printf 'cycle.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
    83	  exit 1
    84	fi
    85	# shellcheck source=/dev/null
    86	source "${_SHARED_DIR}/hook-helpers.sh"
    87	
    88	# bin/ helper resolution (agent dir first, repo source-tree fallback).
    89	_ss_bin() {
    90	  local helper="$1"
    91	  if [[ -f "${CTX_AGENT_DIR}/bin/${helper}" ]]; then
    92	    printf '%s' "${CTX_AGENT_DIR}/bin/${helper}"
    93	  else
    94	    printf '%s' "${IFOS_REPO_ROOT:-}/agents/recruitment/sourcing-scout/bin/${helper}"
    95	  fi
    96	}
    97	
    98	# Connector base + secrets (Path A: values sourced into env, never printed —
    99	# mirrors cash-conductor/cycle.sh Step 1).
   100	_SS_CONN_BASE="${IFOS_REPO_ROOT:+${IFOS_REPO_ROOT}/packages/mcp-connectors}"
   101	if [[ -z "${_SS_CONN_BASE}" || ! -d "${_SS_CONN_BASE}" ]]; then
   102	  _SS_CONN_BASE="${_SHARED_DIR}/../../packages/mcp-connectors"
   103	fi
   104	_SS_SECRETS="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
   105	if [[ -f "${_SS_SECRETS}" ]]; then
   106	  set -a
   107	  # shellcheck source=/dev/null
   108	  source "${_SS_SECRETS}"
   109	  set +a
   110	fi
   111	
   112	# Mode dispatch (default = cli; brain-ui/telegram pass --mode + --brief-id)
   113	MODE="cli"
   114	BRIEF_ID_ARG=""
   115	DESCRIPTION_ARG=""
   116	while [[ $# -gt 0 ]]; do
   117	  case "$1" in
   118	    --mode)        MODE="${2:-}"; shift 2 ;;
   119	    --brief-id)    BRIEF_ID_ARG="${2:-}"; shift 2 ;;
   120	    --description) DESCRIPTION_ARG="${2:-}"; shift 2 ;;
   121	    --tenant)      shift 2 ;;  # tenant set via CTX_TENANT_SLUG by bus
   122	    *)             shift ;;
   123	  esac
   124	done
   125	export BRIEF_ID_ARG DESCRIPTION_ARG
   126	
   127	# Validate mode + brief-input args
   128	case "${MODE}" in
   129	  brain-ui|telegram|cli)
   130	    if [[ -z "${BRIEF_ID_ARG}" && -z "${DESCRIPTION_ARG}" ]]; then
   131	      printf 'cycle.sh: either --brief-id or --description required\n' >&2
   132	      exit 2
   133	    fi ;;
   134	  webhook)
   135	    printf 'cycle.sh: webhook mode DEFERRED to v1.1+ (auto_source_on_brief_create config not yet allowlisted)\n' >&2
   136	    exit 2 ;;
   137	  *) printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
   138	esac
   139	
   140	# Run-scoped workspace (purged on exit; partial drafts go to /tmp separately).
   141	_SS_TMPD="$(mktemp -d -t scout-run-XXXXXX 2>/dev/null || echo "/tmp/scout-run-$$")"
   142	mkdir -p "${_SS_TMPD}"
   143	# shellcheck disable=SC2329  # invoked indirectly via trap
   144	_ss_cleanup_tmpd() { rm -rf "${_SS_TMPD}" 2>/dev/null || true; }
   145	trap _ss_cleanup_tmpd EXIT
   146	
   147	# Exceptions accumulate across steps → §3 diagnostic + exception list.
   148	_SS_EXCEPTIONS="${_SS_TMPD}/exceptions.txt"
   149	: > "${_SS_EXCEPTIONS}"
   150	_ss_exception() { printf '%s\n' "$1" >> "${_SS_EXCEPTIONS}"; }
   151	
   152	# ────────────────────────────────────────────────────────────────────────
   153	# Step 0 — Session start
   154	# ────────────────────────────────────────────────────────────────────────
   155	
   156	# Filesystem-safe brief slug for vault paths + markers.
   157	BRIEF_SLUG="$(printf '%s' "${BRIEF_ID_ARG:-${DESCRIPTION_ARG:0:30}}" \
   158	  | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//; s/-*$//')"
   159	[[ -z "${BRIEF_SLUG}" ]] && BRIEF_SLUG="untitled"
   160	hh_decision_trigger "session_start" "sourcing-scout mode=${MODE} brief=${BRIEF_SLUG}"
   161	
   162	# ────────────────────────────────────────────────────────────────────────
   163	# Step 1 — Brief ingestion (per agent.md §4 Step 1)
   164	# brief_id → Postgres entities read (entity_type='brief'; the Bullhorn-synced
   165	# brief record per spec-003 §2 upstream contract). Free-text → deterministic
   166	# bin/parse-brief.sh (LLM parse = documented enhancement; same JSON contract).
   167	# <3 key dimensions → ESC_BRIEF_AMBIGUITY + validate_gate_a_fail + exit 1.
   168	# ────────────────────────────────────────────────────────────────────────
   169	
   170	BRIEF_JSON="${_SS_TMPD}/brief.json"
   171	_ss_input_type=""
   172	if [[ -n "${BRIEF_ID_ARG}" ]]; then
   173	  _ss_input_type="brief_id"
   174	  _ss_brief_row=""
   175	  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   176	    _ss_brief_row="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
   177	      --set=tenant="${CTX_TENANT_SLUG}" --set=bid="${BRIEF_ID_ARG}" <<'SQL' 2>/dev/null | head -1 || true
   178	BEGIN;
   179	SET LOCAL app.current_tenant = :'tenant';
   180	SELECT data::text FROM entities
   181	WHERE tenant_slug = :'tenant' AND entity_type = 'brief' AND entity_id = :'bid'
   182	LIMIT 1;
   183	COMMIT;
   184	SQL
   185	)"
   186	  fi
   187	  if [[ -n "${_ss_brief_row}" ]] && printf '%s' "${_ss_brief_row}" | jq -e . >/dev/null 2>&1; then
   188	    # Map the brief entity onto the parse-brief.sh JSON contract.
   189	    printf '%s' "${_ss_brief_row}" | jq '
   190	      { role:        (.title // .role // ""),
   191	        location:    (.location // ""),
   192	        salary_band: ( if .salary_band then .salary_band
   193	                       elif .salary_min and .salary_max then "£\(.salary_min)-£\(.salary_max)"
   194	                       elif .salary_min then "£\(.salary_min)+"
   195	                       else "" end ),
   196	        work_mode:   (.work_mode // .role_type // ""),
   197	        seniority:   (.seniority // ""),
   198	        sector:      (.sector // ""),
   199	        source:      "entities_brief_read" }
   200	      | .key_dims = ([.role, .location, .salary_band, .work_mode, .seniority, .sector]
   201	                     | map(select(. != "")) | length)' > "${BRIEF_JSON}"
   202	  elif [[ -n "${DESCRIPTION_ARG}" ]]; then
   203	    # brief_id unresolvable but a free-text description was also supplied.
   204	    _ss_input_type="brief_id_fallback_free_text"
   205	    bash "$(_ss_bin parse-brief.sh)" --description "${DESCRIPTION_ARG}" > "${BRIEF_JSON}"
   206	  else
   207	    # Audit trail: autosend_escalate writes the gating_failed decision_log row.
   208	    # No validate_gate_a_fail action row here — that action_type is reserved
   209	    # for Gate A itself (deviation 4, sourcing-scout-summary.md).
   210	    autosend_escalate "ESC_BRIEF_AMBIGUITY" "agent=sourcing-scout" \
   211	      "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_SLUG}" "reason=brief_id_not_found_in_entities"
   212	    exit 1
   213	  fi
   214	else
   215	  _ss_input_type="free_text"
   216	  bash "$(_ss_bin parse-brief.sh)" --description "${DESCRIPTION_ARG}" > "${BRIEF_JSON}"
   217	fi
   218	
   219	_ss_key_dims="$(jq -r '.key_dims // 0' "${BRIEF_JSON}")"
   220	if [[ "${_ss_key_dims}" -lt 3 ]]; then
   221	  # Audit trail via autosend_escalate only; validate_gate_a_fail is reserved
   222	  # for Gate A itself (deviation 4, sourcing-scout-summary.md).
   223	  autosend_escalate "ESC_BRIEF_AMBIGUITY" "agent=sourcing-scout" \
   224	    "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_SLUG}" "key_dims=${_ss_key_dims}"
   225	  exit 1
   226	fi
   227	hh_decision_output "brief_ingested" "brief:${BRIEF_SLUG}" \
   228	  "input_type:${_ss_input_type}; key_dims:${_ss_key_dims}"
   229	
   230	BRIEF_ROLE="$(jq -r '.role // ""' "${BRIEF_JSON}")"
   231	BRIEF_LOCATION="$(jq -r '.location // ""' "${BRIEF_JSON}")"
   232	BRIEF_SALARY="$(jq -r '.salary_band // ""' "${BRIEF_JSON}")"
   233	
   234	# ────────────────────────────────────────────────────────────────────────
   235	# Step 2 — Multi-source auth refresh; per-source degraded mode on fail
   236	# Per-source state: fixture override → live; else creds presence + CLI
   237	# surface (long-lived keys for Reed/CV-Library; Bullhorn OAuth refresh needs
   238	# the not-yet-built @ifos/bullhorn CLI). Degraded source → catalogue ESC +
   239	# skip, NEVER exit 1 (Sourcing-Scout-specific interpretation, agent.md §4
   240	# Step 2). All live sources gone → ESC_AGENT_OUTPUT_SHAPE (<5 obtainable).
   241	# ────────────────────────────────────────────────────────────────────────
   242	
   243	declare -A SOURCE_STATE SOURCE_NOTE
   244	_ss_resolve_source() {  # <source> <fixture_env_value> <creds_present 0|1> <cli_path> <esc_code>
   245	  local src="$1" fixture="$2" creds="$3" cli="$4" esc="$5"
   246	  if [[ -n "${fixture}" && -f "${fixture}" ]]; then
   247	    SOURCE_STATE[${src}]="live"
   248	    SOURCE_NOTE[${src}]="fixture"
   249	    return 0
   250	  fi
   251	  if [[ "${creds}" -eq 1 && -f "${cli}" ]]; then
   252	    SOURCE_STATE[${src}]="live"
   253	    SOURCE_NOTE[${src}]="live_cli"
   254	    return 0
   255	  fi
   256	  SOURCE_STATE[${src}]="degraded"
   257	  if [[ "${creds}" -eq 0 ]]; then
   258	    SOURCE_NOTE[${src}]="degraded: credentials absent"
   259	  else
   260	    SOURCE_NOTE[${src}]="degraded: connector CLI not built"
   261	  fi
   262	  autosend_escalate "${esc}" "agent=sourcing-scout" "tenant=${CTX_TENANT_SLUG}" \
   263	    "brief=${BRIEF_SLUG}" "reason=${SOURCE_NOTE[${src}]// /_}" "degraded_mode=skip_${src}_source"
   264	  _ss_exception "Source '${src}' degraded (${SOURCE_NOTE[${src}]}) — skipped this run (${esc})"
   265	}
   266	
   267	_ss_bh_creds=0
   268	[[ -n "${BULLHORN_CLIENT_ID:-}" && -n "${BULLHORN_CLIENT_SECRET:-}" ]] && _ss_bh_creds=1
   269	_ss_reed_creds=0
   270	[[ -n "${REED_API_KEY:-}" ]] && _ss_reed_creds=1
   271	_ss_cvl_creds=0
   272	[[ -n "${CVLIBRARY_API_KEY:-}" || -n "${CVLIBRARY_ACCESS_TOKEN:-}" ]] && _ss_cvl_creds=1
   273	
   274	_ss_resolve_source "bullhorn"  "${IFOS_SCOUT_FIXTURE_BULLHORN:-}"  "${_ss_bh_creds}"   "${_SS_CONN_BASE}/bullhorn/dist/cli.js"   "ESC_BULLHORN_AUTH"
   275	_ss_resolve_source "reed"      "${IFOS_SCOUT_FIXTURE_REED:-}"      "${_ss_reed_creds}" "${_SS_CONN_BASE}/reed/dist/cli.js"       "ESC_REED_AUTH"
   276	_ss_resolve_source "cvlibrary" "${IFOS_SCOUT_FIXTURE_CVLIBRARY:-}" "${_ss_cvl_creds}"  "${_SS_CONN_BASE}/cv-library/dist/cli.js" "ESC_CVLIBRARY_AUTH"
   277	
   278	SOURCES_DEGRADED=""
   279	_ss_live_count=0
   280	for _src in bullhorn reed cvlibrary; do
   281	  if [[ "${SOURCE_STATE[${_src}]}" == "live" ]]; then
   282	    _ss_live_count=$((_ss_live_count + 1))
   283	  else
   284	    SOURCES_DEGRADED="${SOURCES_DEGRADED:+${SOURCES_DEGRADED},}${_src}"
   285	  fi
   286	done
   287	hh_decision_output "auth_refresh_complete" "tenant:${CTX_TENANT_SLUG}" \
   288	  "sources_ok:${_ss_live_count}/4; degraded:${SOURCES_DEGRADED:-none}; linkedin:v1.0_no_op"
   289	
   290	if [[ "${_ss_live_count}" -eq 0 ]]; then
   291	  # No live source can contribute → the Gate A 5-candidate floor is already
   292	  # unobtainable. Escalate now; continue so the run still produces the
   293	  # partial report + Gate A audit trail (agent.md §4 Step 2).
   294	  autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=sourcing-scout" \
   295	    "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_SLUG}" \
   296	    "reason=all_sources_degraded_floor_unobtainable" "required_min=5"
   297	  _ss_exception "All sources degraded — Gate A 5-candidate floor unobtainable this run"
   298	fi
   299	
   300	# ────────────────────────────────────────────────────────────────────────
   301	# Source-abstraction query layer (Steps 3/5/6 share this; ULTRAPLAN A5
   302	# line 555). Per-source mapping config lives in the CLI normalisation +
   303	# fixture files; this function is source-agnostic.
   304	# Writes ${_SS_TMPD}/<source>.json (unified-candidate array, ≤30) and sets
   305	# _SS_QUERIED / _SS_RETURNED for the caller's marker.
   306	# ────────────────────────────────────────────────────────────────────────
   307	
   308	_scout_query_source() {  # <source> <fixture_path> <force_429 0|1> <cli_path> <cli_args...>
   309	  local src="$1" fixture="$2" force429="$3" cli="$4"
   310	  shift 4
   311	  local out="${_SS_TMPD}/${src}.json"
   312	  printf '[]' > "${out}"
   313	  _SS_QUERIED="false"
   314	  _SS_RETURNED=0
   315	
   316	  if [[ "${SOURCE_STATE[${src}]}" != "live" ]]; then
   317	    return 0   # degraded-skip; Step 2 already escalated + recorded the note
   318	  fi
   319	  _SS_QUERIED="true"
   320	
   321	  if [[ "${force429}" -eq 1 ]]; then
   322	    # Simulated/observed 429 → ESC_RATE_LIMIT_HIT (warn) + cached-only
   323	    # degraded mode. v1.0 ships without a warm cache → 0 results.
   324	    autosend_escalate "ESC_RATE_LIMIT_HIT" "agent=sourcing-scout" \
   325	      "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_SLUG}" "upstream=${src}" \
   326	      "degraded_mode=cached_only"
   327	    SOURCE_STATE[${src}]="degraded"
   328	    SOURCE_NOTE[${src}]="degraded: 429 rate-limit; cached_only (cold cache → 0 results)"
   329	    SOURCES_DEGRADED="${SOURCES_DEGRADED:+${SOURCES_DEGRADED},}${src}"
   330	    _ss_exception "Source '${src}' hit a 429 rate limit — cached-only degraded mode; 0 results (cold cache)"
   331	    return 0
   332	  fi
   333	
   334	  if [[ -n "${fixture}" && -f "${fixture}" ]]; then
   335	    # Deterministic fixture path (no network/LLM; spec-003 honest scope).
   336	    if jq -e 'type == "array"' "${fixture}" >/dev/null 2>&1; then
   337	      jq '.[0:30]' "${fixture}" > "${out}"
   338	    else
   339	      jq '(.candidates // [])[0:30]' "${fixture}" > "${out}"
   340	    fi

exec
/bin/zsh -lc "rg --files | rg '(MASTER|master|brief|BRIEF|autosend-safety-policy)'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
docs/_supplementary/planning-phase-brief.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
docs/build-brief/00-MASTER-BRIEF.md
docs/decisions/autosend-safety-policy.md
agents/recruitment/sourcing-scout/bin/parse-brief.sh
legacy/v1/MASTER-INDEX.md
legacy/v1/docs/phase-0-strategic/intelforce-planning-phase-brief.md
legacy/v1/docs/phase-5-business-legal/marketing/trademark-filing-brief.md

exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/tools.yaml | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
     1	# Sourcing Scout agent — tools.yaml (capability declarations)
     2	#
     3	# Status: LIVE (W9 build slice, spec-003) — capability set implemented by the
     4	#         live cycle.sh; per-tenant overrides + cost ceilings + per-step authz
     5	#         remain backlog. The agent.md §10 lifecycle status (Proposed) is
     6	#         founder-gated and separate from this bundle-internal build state.
     7	# Reading order: agent.md §1 (output contract) + §2 (invocation surface) +
     8	#         §4 (workflow + capability dependencies) first.
     9	#
    10	# Per ADR-003 agent-bundle pattern: tools.yaml declares every external
    11	# capability cycle.sh invokes + the autosend-policy action_type each
    12	# state-changing call emits. cortextOS bus uses this to authorise capability
    13	# invocation per agent (no capability declared here = bus refuses the call).
    14	#
    15	# Sourcing Scout has NO state-changing capabilities — pure read + report agent.
    16	# All write operations are vault file creation (not gated by autosend-policy).
    17	# The only registered action_type declared here is operator_notify_telegram;
    18	# four candidate names (bullhorn_oauth, reed_oauth, cvlibrary_oauth,
    19	# sourcing_scout_cleanup) are future_registration entries only — see the
    20	# cross-reference block at the bottom of this file.
    21	#
    22	# v1.0 capability set (3 active sources per agent.md §"v1.0 readiness caveat"):
    23	# - @ifos/bullhorn read-only (passive-match query)
    24	# - @ifos/reed (package scaffolded v0.1.0; creds EMPTY → degraded-skip until founder signup)
    25	# - @ifos/cv-library (package scaffolded v0.1.0 + CLI bridge built; the v1.0 live source)
    26	# - LinkedIn vendor DEFERRED to v1.1+ (Proxycurl shut down 2025;
    27	#   vendor selection W8-9 — Lix / Phantombuster / Apify / Sales Navigator)
    28	
    29	version: "0.1"
    30	agent: sourcing-scout
    31	
    32	capabilities:
    33	
    34	  # ────────────────────────────────────────────────────────────────────────
    35	  # Bullhorn ATS (R only; passive-match query per agent.md §4 Step 3)
    36	  # Reference: bullhorn-integration-path.md §4.1 A5 (Sourcing Scout READ-ONLY
    37	  # — no candidate/contractor writes; shortlist artefact is the output).
    38	  # Schema-clean post v0.4 supplement (LIVE on VPS 2026-06-03; commit a1bbcf6).
    39	  # ────────────────────────────────────────────────────────────────────────
    40	
    41	  - id: bullhorn_oauth
    42	    package: "@ifos/bullhorn"
    43	    purpose: "Bullhorn two-step OAuth refresh (Step A OAuth + Step B REST login per @ifos/bullhorn src/auth.ts); per-corporation_id Promise dedup + 401-force-refresh per cluster F R4 lesson"
    44	    future_registration: bullhorn_oauth  # NOT a registered autosend-policy action_type yet; registration is a founder-gated policy decision; until then the code path emits hh_decision_output / degraded-skip only
    45	    cycle_step: 2
    46	    secrets_required: [BULLHORN_CLIENT_ID, BULLHORN_CLIENT_SECRET]
    47	    rate_limit_hint: "per-corporation_id 600/min hard / 480/min soft"
    48	
    49	  - id: bullhorn_list_candidates
    50	    package: "@ifos/bullhorn"
    51	    purpose: "Passive-match query: status='active' + dateLastModified<90d (derived 'passive' per agent.md §4 Step 3; not a vertical-schema enum value); up to 30 hits per brief"
    52	    cycle_step: 3
    53	    state_changing: false
    54	
    55	  - id: bullhorn_get_candidate
    56	    package: "@ifos/bullhorn"
    57	    purpose: "Single-candidate hydrate for rationale generation context (Step 9)"
    58	    cycle_step: 9
    59	    state_changing: false
    60	
    61	  - id: bullhorn_get_brief
    62	    package: "@ifos/bullhorn"
    63	    purpose: "Brief hydrate when invoked via --brief-id (Step 1). W9 disposition: cycle.sh reads the Bullhorn-synced brief from the Postgres `entities` mirror (entity_type='brief'; spec-003 §2 upstream contract) — no direct Bullhorn call at v1.0. A direct getBrief/JobOrder endpoint on @ifos/bullhorn remains the v1.1 enhancement for tenants without an entities sync."
    64	    cycle_step: 1
    65	    state_changing: false
    66	
    67	  # ────────────────────────────────────────────────────────────────────────
    68	  # Reed.co.uk recruiter API (@ifos/reed scaffolded v0.1.0; creds pending signup)
    69	  # Reference: agent.md §4 Step 5. v1.0 source #2; W6+ commercial signup
    70	  # required (per founder-api-signups-2026-06-03.md P2).
    71	  # ────────────────────────────────────────────────────────────────────────
    72	
    73	  - id: reed_oauth
    74	    package: "@ifos/reed"
    75	    purpose: "Reed.co.uk recruiter API auth — long-lived API key presence check (Basic auth per @ifos/reed v0.1.0); creds EMPTY today → cycle.sh Step 2 degraded-skip (ESC_REED_AUTH)"
    76	    future_registration: reed_oauth  # NOT a registered autosend-policy action_type yet; registration is a founder-gated policy decision; until then the code path emits hh_decision_output / degraded-skip only
    77	    cycle_step: 2
    78	    secrets_required: [REED_API_KEY]   # placeholder — actual secret name from Phase 8 verification
    79	    rate_limit_hint: "per-account_id budget per @ifos/reed rate-limit.ts"
    80	    package_status: scaffolded_v0.1.0_creds_pending
    81	
    82	  - id: reed_search_candidates
    83	    package: "@ifos/reed"
    84	    purpose: "Reed candidate search by brief dimensions (location + salary band + role); up to 30 hits per brief; degraded-skip until creds land"
    85	    cycle_step: 5
    86	    state_changing: false
    87	    package_status: scaffolded_v0.1.0
    88	
    89	  # ────────────────────────────────────────────────────────────────────────
    90	  # CV-Library API (@ifos/cv-library scaffolded v0.1.0 + dist/cli.js bridge — the v1.0 live source)
    91	  # Reference: agent.md §4 Step 6. v1.0 source #3; W6+ commercial signup
    92	  # required (per founder-api-signups-2026-06-03.md P3).
    93	  # ────────────────────────────────────────────────────────────────────────
    94	
    95	  - id: cvlibrary_oauth
    96	    package: "@ifos/cv-library"
    97	    purpose: "CV-Library auth — network-free check-auth via dist/cli.js (long-lived key; Basic/Bearer dual-mode per CVLibraryConfig; exact mode verified at commercial signup)"
    98	    future_registration: cvlibrary_oauth  # NOT a registered autosend-policy action_type yet; registration is a founder-gated policy decision; until then the code path emits hh_decision_output / degraded-skip only
    99	    cycle_step: 2
   100	    secrets_required: [CVLIBRARY_API_KEY]   # placeholder per Phase 8 verification
   101	    rate_limit_hint: "per-account_id budget per @ifos/cv-library rate-limit.ts"
   102	    package_status: scaffolded_v0.1.0_cli_built
   103	
   104	  - id: cvlibrary_search_candidates
   105	    package: "@ifos/cv-library"
   106	    purpose: "CV-Library candidate search by brief dimensions via dist/cli.js search-candidates (normalised unified candidate shape); up to 30 hits per brief"
   107	    cycle_step: 6
   108	    state_changing: false
   109	    package_status: scaffolded_v0.1.0_cli_built
   110	
   111	  # ────────────────────────────────────────────────────────────────────────
   112	  # LinkedIn — NO-OP at v1.0
   113	  # Reference: agent.md §"v1.0 readiness caveat — LinkedIn deep-data vendor"
   114	  # lines 6-8. Proxycurl shut down 2025; NinjaPear doesn't carry LinkedIn
   115	  # data. v1.1+ vendor selection W8-9 (Lix / Phantombuster / Apify / Sales
   116	  # Navigator). No capability declaration at v1.0 — cycle.sh Step 4 is an
   117	  # explicit no-op audit row.
   118	  # ────────────────────────────────────────────────────────────────────────
   119	
   120	  # NOTE: linkedin_* capabilities deliberately NOT declared at v1.0. cycle.sh
   121	  # Step 4 emits a "linkedin_query" no-op audit row ("results:0; no_op")
   122	  # instead. v1.1+ supplement adds the chosen vendor's capability set when
   123	  # commercial signup + MCP package land.
   124	
   125	  # ────────────────────────────────────────────────────────────────────────
   126	  # Voice classifier (Step 9 per-candidate rationale voice scoring)
   127	  # Reference: agent.md §7; _shared/voice-loader.sh + hh_load_tone_rules.
   128	  # ────────────────────────────────────────────────────────────────────────
   129	
   130	  - id: voice_classifier
   131	    package: "@ifos/voice-classifier"   # W4-5 polish microservice (per agent.md §8 build deps)
   132	    purpose: "Score per-candidate rationale against tenant voice corpus (≥0.75 required by Gate A G4); ESC_VOICE_DRIFT below threshold after 3 retries; per-run only (aggregate _TENANT is canary cron territory per agent.md §7)"
   133	    cycle_step: 9
   134	    state_changing: false
   135	
   136	  # ────────────────────────────────────────────────────────────────────────
   137	  # Operator notification (Telegram OR Brain UI in-app)
   138	  # Reference: agent.md §4 Step 11; per-invocation-source notification.
   139	  # ────────────────────────────────────────────────────────────────────────
   140	
   141	  - id: telegram_notify
   142	    package: "@ifos/telegram"
   143	    purpose: "Operator-channel Telegram notifications (NOT customer-facing; green tier) — Step 11 sourcing report completion notification when invoked via Telegram mode; Brain UI mode uses internal API instead"
   144	    action_type: operator_notify_telegram  # green tier; REGISTERED in autosend-policy.yaml
   145	    cycle_step: 11
   146	    state_changing: false
   147	    secrets_required: [TELEGRAM_BOT_TOKEN]
   148	
   149	  # ────────────────────────────────────────────────────────────────────────
   150	  # Cleanup (cleanup.sh)
   151	  # ────────────────────────────────────────────────────────────────────────
   152	
   153	  - id: sourcing_scout_cleanup
   154	    purpose: "Post-run cleanup (transient @ifos/{bullhorn,reed,cv-library} cache purge + /tmp draft purge)"
   155	    future_registration: sourcing_scout_cleanup  # NOT a registered autosend-policy action_type yet; registration is a founder-gated policy decision; until then cleanup.sh emits hh_decision_output only (verified: no hh_decision_action call in cleanup.sh)
   156	    state_changing: false
   157	    cycle_step: 11
   158	
   159	# ──────────────────────────────────────────────────────────────────────────────
   160	# Failure-modes table (per cluster Fbis pattern; ESC mapping per agent.md §6)
   161	# ──────────────────────────────────────────────────────────────────────────────
   162	
   163	failure_modes:
   164	
   165	  - condition: "@ifos/bullhorn OAuth refresh fails after 2 retries (cycle.sh Step 2)"
   166	    surface: "BullhornAuthError thrown by @ifos/bullhorn"
   167	    escalation: ESC_BULLHORN_AUTH    # blocking per catalogue §2.3 — but Sourcing-Scout-specific degraded mode = skip Bullhorn source + continue with Reed + CV-Library (NOT exit 1)
   168	
   169	  - condition: "@ifos/reed OAuth/API-key auth fails (cycle.sh Step 2)"
   170	    surface: "ReedAuthError per @ifos/reed v0.1.0 errors.ts; today: creds-absent degraded-skip at cycle.sh Step 2"
   171	    escalation: ESC_REED_AUTH        # blocking per catalogue §2.7 — Sourcing-Scout degraded mode = cached Reed search only (effectively skip Reed if no warm cache)
   172	
   173	  - condition: "@ifos/cv-library OAuth/API-key auth fails (cycle.sh Step 2)"
   174	    surface: "CVLibraryAuthError per @ifos/cv-library v0.1.0 errors.ts (CLI maps to {ok:false,error:\"auth\"})"
   175	    escalation: ESC_CVLIBRARY_AUTH   # blocking per catalogue §2.7 — same degraded-mode pattern as Reed
   176	
   177	  - condition: "Multiple sources in degraded mode AND remaining live can't produce ≥5 candidates (cycle.sh Step 2 + Step 10)"
   178	    surface: "validate.sh G1 fail with ESC_AGENT_OUTPUT_SHAPE"
   179	    escalation: ESC_AGENT_OUTPUT_SHAPE   # warn; Gate A floor violated
   180	
   181	  - condition: "Bullhorn / Reed / CV-Library returns 429 (cycle.sh Steps 3/5/6)"
   182	    surface: "*RateLimitError thrown by per-package client"
   183	    escalation: ESC_RATE_LIMIT_HIT       # warn; operator_chat_id; payload.upstream identifies bullhorn / reed / cv-library
   184	
   185	  - condition: "LLM brief parse yields <3 key dimensions (cycle.sh Step 1)"
   186	    surface: "Brief decoder returns insufficient dimensions"
   187	    escalation: ESC_BRIEF_AMBIGUITY      # warn per catalogue §2.5; operator_chat_id
   188	
   189	  - condition: "Per-candidate rationale voice classifier <0.75 after 3 retries (cycle.sh Step 9)"
   190	    surface: "Candidate dropped from final list + flagged in exception list"
   191	    escalation: ESC_VOICE_DRIFT          # warn per catalogue lines 120-125; operator_chat_id
   192	
   193	  - condition: "PII detected outside firm boundary in any rationale (validate.sh G6)"
   194	    surface: "validate.sh exit 1 with G6 failure"
   195	    escalation: ESC_PII_LEAKAGE_RISK     # blocking per catalogue §2.5; operator + ifos_oncall_chat_id
   196	
   197	  - condition: "Candidate count not in [5, 15] OR missing contact method OR rationale <50 words OR DNC match OR no source contributed (validate.sh G1+G2+G3+G5+G7)"
   198	    surface: "validate.sh exit 1 with output-shape failure"
   199	    escalation: ESC_AGENT_OUTPUT_SHAPE   # warn per catalogue line 184; operator_chat_id
   200	
   201	  - condition: "Below 6-of-10 advance rate for 30 consecutive days (monthly aggregate)"
   202	    surface: "monthly metrics roll-up; consultant feedback Telegram path"
   203	    escalation: ESC_GATE_B_MISS          # warn per catalogue routing; operator_chat_id; likely ranking heuristic drift OR source-mix imbalance
   204	
   205	# ──────────────────────────────────────────────────────────────────────────────
   206	# Action-type registration status (cross-reference autosend-policy.yaml)
   207	# ──────────────────────────────────────────────────────────────────────────────
   208	#
   209	# Already REGISTERED in agents/_shared/autosend-policy.yaml:
   210	#   operator_notify_telegram        green
   211	# (cycle.sh also emits the shared registered action_types scout_run_complete
   212	# + validate_gate_a_fail — substrate rows, not capability declarations here.)
   213	#
   214	# future_registration ONLY — NOT registered autosend-policy action_types yet;
   215	# registration is a founder-gated substrate/policy decision. Until it lands,
   216	# the code paths emit hh_decision_output (auth steps / cleanup.sh) or
   217	# degraded-skip — NO unregistered action_type row is ever emitted:
   218	#   bullhorn_oauth                  (proposed green)
   219	#   reed_oauth                      (proposed green)
   220	#   cvlibrary_oauth                 (proposed green)
   221	#   sourcing_scout_cleanup          (proposed green)
   222	#
   223	# NOTE: Sourcing Scout has NO yellow- or orange- or red-tier action_types.
   224	# Pure read + report agent; outputs go to vault Markdown only. No autosend
   225	# of customer-facing comms; no Bullhorn writes. Per agent.md §6: "ESC_AUTOSEND_*
   226	# explicitly NOT used — no auto-send actions; pure read + report."
   227	
   228	# ──────────────────────────────────────────────────────────────────────────────
   229	# Boundary check (per master brief §3 + review-mcp-connector.md §8)
   230	# ──────────────────────────────────────────────────────────────────────────────
   231	#
   232	# - No forbidden third-party adapter references anywhere in this file
   233	#   (adapter boundary, CLAUDE.md boundary 2).
   234	# - All packages declared are @ifos/* — no third-party adapters with policy
   235	#   semantics smuggled in via tools.yaml.
   236	# - Every action_type declared maps to a registered autosend-policy.yaml tier;
   237	#   future_registration entries above are explicitly NOT action_type claims
   238	#   (founder-gated registration pending).
   239	# - Capability ID set = @ifos/bullhorn READ subset per integration-path
   240	#   §4.1 A5 (Sourcing Scout READ-ONLY on Bullhorn; shortlist artefact is the

exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/cycle.sh | sed -n '340,760p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/validate.sh | sed -n '280,520p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
   280	fi
   281	_g5_hits="$(jq -r --argjson dnc "${_DNC_JSON}" '
   282	  def nphone: gsub("[^0-9]"; "") | if length > 10 then .[-10:] else . end;
   283	  ($dnc | map(ascii_downcase)) as $dl
   284	  | ($dnc | map(nphone) | map(select(. != ""))) as $dp
   285	  | [ .candidates[]
   286	      | select(
   287	          (((.contact_method.value // "") | ascii_downcase) as $v | ($dl | index($v)) != null)
   288	          or ((((.email // "") | ascii_downcase) as $e | $e != "" and ($dl | index($e)) != null))
   289	          or ((((.phone // "") | nphone) as $p | $p != "" and ($dp | index($p)) != null))
   290	          or ((((.name // "") | ascii_downcase) as $n | $n != "" and ($dl | index($n)) != null)) )
   291	      | .candidate_id ]
   292	  | length' "${PROPOSAL}" 2>/dev/null || echo 0)"
   293	if [[ "${_g5_hits}" =~ ^[0-9]+$ && "${_g5_hits}" -gt 0 ]]; then
   294	  _fail "G5: ${_g5_hits} candidate(s) match the tenant DNC list (post-Step-8 re-check)"
   295	  _set_class "ESC_AGENT_OUTPUT_SHAPE"
   296	else
   297	  _ok "G5: no candidate in DNC list (defence-in-depth re-check)"
   298	fi
   299	
   300	# ────────────────────────────────────────────────────────────────────────
   301	# G6 — No PII outside firm boundary in any rationale (BLOCKING per
   302	# catalogue §2.5). Regex pass: any email address in a rationale whose domain
   303	# is not in CTX_FIRM_DOMAIN_WHITELIST → ESC_PII_LEAKAGE_RISK.
   304	# ────────────────────────────────────────────────────────────────────────
   305	
   306	_g6_bad=0
   307	_FIRM_DOMAINS=",$(printf '%s' "${CTX_FIRM_DOMAIN_WHITELIST:-}" | tr '[:upper:]' '[:lower:]' | tr -d ' '),"
   308	while IFS=$'\t' read -r _c_id _c_body; do
   309	  [[ -z "${_c_id}" || -z "${_c_body}" ]] && continue
   310	  while IFS= read -r _em; do
   311	    [[ -z "${_em}" ]] && continue
   312	    _em_dom="$(printf '%s' "${_em##*@}" | tr '[:upper:]' '[:lower:]')"
   313	    if [[ "${_FIRM_DOMAINS}" != *",${_em_dom},"* ]]; then
   314	      _g6_bad=$((_g6_bad + 1))
   315	      _fail "G6: ${_c_id} rationale contains an email outside the firm boundary (domain '${_em_dom}')"
   316	    fi
   317	  done < <(printf '%s' "${_c_body}" | grep -oiE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' | sort -u || true)
   318	done < <(jq -r '.candidates[] | [.candidate_id, ((.rationale_body // .rationale_body_preview // "") | gsub("[\\n\\t]"; " "))] | @tsv' "${PROPOSAL}")
   319	if [[ "${_g6_bad}" -gt 0 ]]; then
   320	  _set_class "ESC_PII_LEAKAGE_RISK"
   321	else
   322	  _ok "G6: no PII outside firm boundary in any rationale"
   323	fi
   324	
   325	# ────────────────────────────────────────────────────────────────────────
   326	# G7 — Source floor: no enabled live source returned 0 WITHOUT a degradation
   327	# note, and at least one source contributed or recorded a degradation
   328	# (defence against silent all-source-failure producing an empty report).
   329	# ────────────────────────────────────────────────────────────────────────
   330	
   331	_g7_bad="$(jq -r '
   332	  (.sources_degraded // []) as $deg
   333	  | [ (.source_stats // {}) | to_entries[]
   334	      | select(.key != "linkedin")                       # v1.0 NO-OP, never live
   335	      | select(.value.queried == true)
   336	      | select((.value.returned // 0) == 0)
   337	      | select(((.value.note // "") | test("degrad|429|rate[_-]?limit|cached"; "i")) | not)
   338	      | select((.key as $k | $deg | index($k)) == null)
   339	      | .key ]
   340	  | length' "${PROPOSAL}" 2>/dev/null || echo 0)"
   341	_g7_any="$(jq -r '
   342	  ([ (.source_stats // {}) | to_entries[] | select((.value.returned // 0) > 0) ] | length) as $contrib
   343	  | ((.sources_degraded // []) | length) as $deg
   344	  | if ($contrib > 0 or $deg > 0) then "yes" else "no" end' "${PROPOSAL}" 2>/dev/null || echo no)"
   345	if [[ "${_g7_bad}" =~ ^[0-9]+$ && "${_g7_bad}" -gt 0 ]]; then
   346	  _fail "G7: ${_g7_bad} enabled live source(s) returned 0 without a recorded degradation note"
   347	  _set_class "ESC_AGENT_OUTPUT_SHAPE"
   348	elif [[ "${_g7_any}" == "no" ]]; then
   349	  _fail "G7: no source contributed and no degradation was recorded (silent all-source failure)"
   350	  _set_class "ESC_AGENT_OUTPUT_SHAPE"
   351	else
   352	  _ok "G7: source floor honoured (contributions or degradation notes present)"
   353	fi
   354	
   355	# ────────────────────────────────────────────────────────────────────────
   356	# Verdict + audit-row emission
   357	# ────────────────────────────────────────────────────────────────────────
   358	
   359	printf '\nSourcing Scout validate Gate A: '
   360	if [[ ${#FAILURES[@]} -gt 0 ]]; then
   361	  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
   362	  # Per-failure-class ESC routing (agent.md §5):
   363	  #   G1/G2/G3/G5/G7 → ESC_AGENT_OUTPUT_SHAPE (warn; operator_chat_id)
   364	  #   G4             → ESC_VOICE_DRIFT (warn; operator_chat_id)
   365	  #   G6             → ESC_PII_LEAKAGE_RISK (BLOCKING; operator + ifos_oncall)
   366	  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
   367	  _ss_phash="$(printf '%s' "${BRIEF_ID}|${N_CANDIDATES}|${FAILURES[0]}" | shasum -a 256 2>/dev/null | cut -c1-16)"
   368	  [[ -z "${_ss_phash}" ]] && _ss_phash="gate-a-${BRIEF_ID}"
   369	  # Mandatory audit row per master brief §8.1 Change 2 + autosend-policy.yaml
   370	  # validate_gate_a_fail (green tier, registered).
   371	  hh_decision_action "validate_gate_a_fail" "brief:${BRIEF_ID}" "${_ss_phash}" \
   372	    "${ESC_CLASS}; agent_name:sourcing-scout; failures:${#FAILURES[@]}; first:${FAILURES[0]}" || true
   373	  autosend_escalate "${ESC_CLASS}" "agent=sourcing-scout" \
   374	    "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_ID}" \
   375	    "candidate_count=${N_CANDIDATES}" "failures=${#FAILURES[@]}"
   376	  exit 1
   377	fi
   378	printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
   379	exit 0

 succeeded in 0ms:
   340	    fi
   341	  elif [[ -f "${cli}" ]]; then
   342	    # Live CLI path (the orchestrator's post-build smoke exercises this).
   343	    local cli_out
   344	    if cli_out="$(node "${cli}" "$@" 2>/dev/null)" \
   345	         && printf '%s' "${cli_out}" | jq -e '.ok == true' >/dev/null 2>&1; then
   346	      printf '%s' "${cli_out}" | jq '(.candidates // [])[0:30]' > "${out}"
   347	    else
   348	      local cli_err
   349	      cli_err="$(printf '%s' "${cli_out:-}" | jq -r '.error // "query_failed"' 2>/dev/null || echo query_failed)"
   350	      if [[ "${cli_err}" == "rate_limit" ]]; then
   351	        autosend_escalate "ESC_RATE_LIMIT_HIT" "agent=sourcing-scout" \
   352	          "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_SLUG}" "upstream=${src}" \
   353	          "degraded_mode=cached_only"
   354	        SOURCE_NOTE[${src}]="degraded: 429 rate-limit; cached_only"
   355	      else
   356	        SOURCE_NOTE[${src}]="degraded: query failed (${cli_err})"
   357	      fi
   358	      SOURCE_STATE[${src}]="degraded"
   359	      SOURCES_DEGRADED="${SOURCES_DEGRADED:+${SOURCES_DEGRADED},}${src}"
   360	      _ss_exception "Source '${src}' query failed (${cli_err}) — 0 results this run"
   361	    fi
   362	  fi
   363	  _SS_RETURNED="$(jq 'length' "${out}")"
   364	  if [[ "${SOURCE_STATE[${src}]}" == "live" ]]; then
   365	    SOURCE_NOTE[${src}]="${SOURCE_NOTE[${src}]}: ${_SS_RETURNED} candidates"
   366	  fi
   367	}
   368	
   369	# ────────────────────────────────────────────────────────────────────────
   370	# Step 3 — Bullhorn passive-match query (READ-ONLY; agent.md §4 Step 3)
   371	# Filter contract: status='active' AND date_last_modified_at < now()-90d
   372	# ("passive" is derived, not a schema enum). ≤30 hits.
   373	# ────────────────────────────────────────────────────────────────────────
   374	
   375	_scout_query_source "bullhorn" "${IFOS_SCOUT_FIXTURE_BULLHORN:-}" \
   376	  "${IFOS_SCOUT_FORCE_429_BULLHORN:-0}" "${_SS_CONN_BASE}/bullhorn/dist/cli.js" \
   377	  search-candidates --query "status:active AND dateLastModified:<now-90d" \
   378	  --keywords "${BRIEF_ROLE}" --location "${BRIEF_LOCATION}" --limit 30
   379	hh_decision_output "bullhorn_query" "brief:${BRIEF_SLUG}" \
   380	  "results:${_SS_RETURNED}; queried:${_SS_QUERIED}; filter:'status:active+modified<90d'"
   381	
   382	# ────────────────────────────────────────────────────────────────────────
   383	# Step 4 — LinkedIn search — NO-OP at v1.0 (Proxycurl shutdown caveat)
   384	# Explicit no-op audit row per the Janitor Step 7 pattern; v1.1+ vendor
   385	# selection (Lix / Phantombuster / Apify / Sales Navigator) pending.
   386	# ────────────────────────────────────────────────────────────────────────
   387	
   388	printf '[]' > "${_SS_TMPD}/linkedin.json"
   389	hh_decision_output "linkedin_query" "brief:${BRIEF_SLUG}" \
   390	  "results:0; no_op; reason:v1.0_caveat_proxycurl_shutdown; vendor_selection:v1.1_deferred"
   391	
   392	# ────────────────────────────────────────────────────────────────────────
   393	# Step 5 — Reed query (≤30; ESC_REED_AUTH / ESC_RATE_LIMIT_HIT)
   394	# ────────────────────────────────────────────────────────────────────────
   395	
   396	_scout_query_source "reed" "${IFOS_SCOUT_FIXTURE_REED:-}" \
   397	  "${IFOS_SCOUT_FORCE_429_REED:-0}" "${_SS_CONN_BASE}/reed/dist/cli.js" \
   398	  search-candidates --keywords "${BRIEF_ROLE}" --location "${BRIEF_LOCATION}" \
   399	  --salary-band "${BRIEF_SALARY}" --limit 30
   400	hh_decision_output "reed_query" "brief:${BRIEF_SLUG}" \
   401	  "results:${_SS_RETURNED}; queried:${_SS_QUERIED}"
   402	
   403	# ────────────────────────────────────────────────────────────────────────
   404	# Step 6 — CV-Library query (≤30; the v1.0 live source)
   405	# Live path via @ifos/cv-library dist/cli.js search-candidates (normalised
   406	# unified shape). No live call is made in this build slice — fixture path in
   407	# tests; creds + orchestrator smoke gate the live call.
   408	# ────────────────────────────────────────────────────────────────────────
   409	
   410	_scout_query_source "cvlibrary" "${IFOS_SCOUT_FIXTURE_CVLIBRARY:-}" \
   411	  "${IFOS_SCOUT_FORCE_429_CVLIBRARY:-0}" "${_SS_CONN_BASE}/cv-library/dist/cli.js" \
   412	  search-candidates --keywords "${BRIEF_ROLE}" --location "${BRIEF_LOCATION}" --limit 30
   413	hh_decision_output "cvlibrary_query" "brief:${BRIEF_SLUG}" \
   414	  "results:${_SS_RETURNED}; queried:${_SS_QUERIED}"
   415	
   416	# ────────────────────────────────────────────────────────────────────────
   417	# Step 7 — Aggregate + dedupe across sources (bin/fuzzy-match.sh — carried
   418	# Janitor matcher: name·0.3+email·0.4+phone·0.2+linkedin·0.1; ≥0.85) +
   419	# source provenance annotation.
   420	# ────────────────────────────────────────────────────────────────────────
   421	
   422	AGGREGATE_JSON="${_SS_TMPD}/aggregate.json"
   423	jq -s 'add' "${_SS_TMPD}/bullhorn.json" "${_SS_TMPD}/reed.json" \
   424	  "${_SS_TMPD}/cvlibrary.json" "${_SS_TMPD}/linkedin.json" \
   425	  | bash "$(_ss_bin fuzzy-match.sh)" > "${AGGREGATE_JSON}"
   426	_ss_pre="$(jq -r '.pre_dedupe' "${AGGREGATE_JSON}")"
   427	_ss_post="$(jq -r '.post_dedupe' "${AGGREGATE_JSON}")"
   428	_ss_xsrc="$(jq -r '[.candidates[] | select((.sources | length) > 1)] | length' "${AGGREGATE_JSON}")"
   429	hh_decision_output "aggregate_dedupe" "brief:${BRIEF_SLUG}" \
   430	  "pre:${_ss_pre}; post:${_ss_post}; cross_source_matches:${_ss_xsrc}"
   431	
   432	# ────────────────────────────────────────────────────────────────────────
   433	# Step 8 — DNC filter (pre-outbound sourcing filter; NOT outbound refusal)
   434	# tenant_adapters.config.blocked_recipients (v0.3-allowlisted) via
   435	# CTX_DNC_BLOCKED_RECIPIENTS (context.sh; IFOS_FORCE_* fixture fallback).
   436	# Drops → exception list ONLY; no ESC fire (catalogue §2.10 reserves
   437	# ESC_DNC_FILTER_HIT for outbound send refusal; W4-polish backlog:
   438	# ESC_SOURCING_DNC_FILTER). Dropped candidates still get their
   439	# candidate_proposed row (included=false) at Step 9 per spec-003 §3.
   440	# ────────────────────────────────────────────────────────────────────────
   441	
   442	_DNC_JSON="${CTX_DNC_BLOCKED_RECIPIENTS:-${IFOS_FORCE_DNC_BLOCKED_RECIPIENTS:-[]}}"
   443	if ! printf '%s' "${_DNC_JSON}" | jq -e 'type == "array"' >/dev/null 2>&1; then
   444	  _DNC_JSON="[]"
   445	fi
   446	KEPT_JSON="${_SS_TMPD}/kept.json"
   447	DNC_DROPPED_JSON="${_SS_TMPD}/dnc-dropped.json"
   448	jq --argjson dnc "${_DNC_JSON}" '
   449	  def nphone: gsub("[^0-9]"; "") | if length > 10 then .[-10:] else . end;
   450	  ($dnc | map(ascii_downcase)) as $dl
   451	  | ($dnc | map(nphone) | map(select(. != ""))) as $dp
   452	  | def hit:
   453	      ((((.email // "") | ascii_downcase) as $e | $e != "" and ($dl | index($e)) != null))
   454	      or ((((.phone // "") | nphone) as $p | $p != "" and ($dp | index($p)) != null))
   455	      or ((((.name // "") | ascii_downcase) as $n | $n != "" and ($dl | index($n)) != null));
   456	  .candidates | map(select(hit | not))' "${AGGREGATE_JSON}" > "${KEPT_JSON}"
   457	jq --argjson dnc "${_DNC_JSON}" '
   458	  def nphone: gsub("[^0-9]"; "") | if length > 10 then .[-10:] else . end;
   459	  ($dnc | map(ascii_downcase)) as $dl
   460	  | ($dnc | map(nphone) | map(select(. != ""))) as $dp
   461	  | def hit:
   462	      ((((.email // "") | ascii_downcase) as $e | $e != "" and ($dl | index($e)) != null))
   463	      or ((((.phone // "") | nphone) as $p | $p != "" and ($dp | index($p)) != null))
   464	      or ((((.name // "") | ascii_downcase) as $n | $n != "" and ($dl | index($n)) != null));
   465	  .candidates | map(select(hit))' "${AGGREGATE_JSON}" > "${DNC_DROPPED_JSON}"
   466	_ss_dropped="$(jq 'length' "${DNC_DROPPED_JSON}")"
   467	_ss_kept="$(jq 'length' "${KEPT_JSON}")"
   468	if [[ "${_ss_dropped}" -gt 0 ]]; then
   469	  _ss_exception "${_ss_dropped} candidate(s) filtered against the tenant DNC list (blocked_recipients) at Step 8"
   470	fi
   471	hh_decision_output "dnc_filter" "brief:${BRIEF_SLUG}" \
   472	  "dropped:${_ss_dropped}; kept:${_ss_kept}; source:tenant_adapters.config.blocked_recipients"
   473	
   474	# ────────────────────────────────────────────────────────────────────────
   475	# Step 9 — Ranking + per-candidate rationale generation (top 15)
   476	# Deterministic templated rationale (bin/render-rationale.sh — the CC Step 8
   477	# templated-draft pattern; LLM polish = documented enhancement). Voice
   478	# honesty (spec-003 §8): empty voice_corpus → unscored/no_corpus, never a
   479	# faked score; a real numeric score <0.75 after 3 retries → drop +
   480	# ESC_VOICE_DRIFT. ONE candidate_proposed row PER candidate, including
   481	# dropped (included=false + drop_reason).
   482	# ────────────────────────────────────────────────────────────────────────
   483	
   484	RANKED_JSON="${_SS_TMPD}/ranked.json"
   485	jq 'sort_by(-(.confidence // 0))' "${KEPT_JSON}" > "${RANKED_JSON}"
   486	FINAL_JSON="${_SS_TMPD}/final.json"
   487	printf '[]' > "${FINAL_JSON}"
   488	
   489	_ss_voice_state="${CTX_VOICE_CORPUS_STATE:-absent}"
   490	_ss_force_voice="${IFOS_SCOUT_FORCE_VOICE_SCORE:-}"
   491	_ss_voice_drops=0
   492	_ss_rank=0
   493	_ss_total_ranked="$(jq 'length' "${RANKED_JSON}")"
   494	
   495	while IFS= read -r _cand_b64; do
   496	  [[ -z "${_cand_b64}" ]] && continue
   497	  _cand="$(printf '%s' "${_cand_b64}" | base64 -d)"
   498	  _c_ref="$(printf '%s' "${_cand}" | jq -r '.ref // .refs[0] // "unknown"')"
   499	  _c_name="$(printf '%s' "${_cand}" | jq -r '.name // "unknown"')"
   500	  _c_sources="$(printf '%s' "${_cand}" | jq -r '(.sources // [.source]) | join(",")')"
   501	  _c_conf="$(printf '%s' "${_cand}" | jq -r '.confidence // 0')"
   502	  _ss_rank=$((_ss_rank + 1))
   503	
   504	  if [[ "${_ss_rank}" -gt 15 ]]; then
   505	    hh_decision_output "candidate_proposed" "candidate:${_c_ref}" \
   506	      "source:${_c_sources}; confidence:${_c_conf}; voice_score:n/a; included:false; drop_reason:rank_cutoff_top15"
   507	    continue
   508	  fi
   509	
   510	  # Rationale (deterministic ≥50 words; tone-rule compliant; no PII).
   511	  _c_headline="$(printf '%s' "${_cand}" | jq -r '.headline // ""')"
   512	  _c_location="$(printf '%s' "${_cand}" | jq -r '.location // ""')"
   513	  _c_rationale="$(bash "$(_ss_bin render-rationale.sh)" \
   514	    --name "${_c_name}" --sources "${_c_sources}" --confidence "${_c_conf}" \
   515	    --brief-role "${BRIEF_ROLE:-the brief role}" --brief-location "${BRIEF_LOCATION}" \
   516	    --brief-salary "${BRIEF_SALARY}" --headline "${_c_headline}" \
   517	    --candidate-location "${_c_location}")"
   518	  _c_words="$(printf '%s' "${_c_rationale}" | wc -w | tr -d ' ')"
   519	
   520	  # Voice scoring honesty (spec-003 §8).
   521	  _c_voice="unscored"
   522	  _c_voice_reason="no_corpus"
   523	  if [[ -n "${_ss_force_voice}" ]]; then
   524	    _c_voice="${_ss_force_voice}"
   525	    _c_voice_reason="forced_test_hook"
   526	  elif [[ "${_ss_voice_state}" == "active" ]]; then
   527	    # Corpus exists but the embedding classifier microservice is not built
   528	    # yet — recording unscored is the honest signal (never fake a number).
   529	    _c_voice_reason="classifier_unavailable"
   530	  fi
   531	  if [[ "${_c_voice}" =~ ^[0-9]+(\.[0-9]+)?$ ]] \
   532	       && ! awk -v s="${_c_voice}" 'BEGIN{exit !(s>=0.75)}'; then
   533	    # 3 deterministic retries of a templated rationale produce the same
   534	    # score → drop after retry budget per agent.md §4 Step 9.
   535	    _ss_voice_drops=$((_ss_voice_drops + 1))
   536	    autosend_escalate "ESC_VOICE_DRIFT" "agent=sourcing-scout" \
   537	      "tenant=${CTX_TENANT_SLUG}" "brief=${BRIEF_SLUG}" \
   538	      "candidate=${_c_ref}" "voice_score=${_c_voice}" "retries=3"
   539	    _ss_exception "Candidate ${_c_name} dropped: rationale voice score ${_c_voice} < 0.75 after 3 retries (ESC_VOICE_DRIFT)"
   540	    hh_decision_output "candidate_proposed" "candidate:${_c_ref}" \
   541	      "source:${_c_sources}; confidence:${_c_conf}; voice_score:${_c_voice}; included:false; drop_reason:voice_drift"
   542	    continue
   543	  fi
   544	
   545	  # Contact method preference: email > phone > linkedin > bullhorn_internal.
   546	  _c_entry="$(printf '%s' "${_cand}" | jq \
   547	    --arg rationale "${_c_rationale}" --arg words "${_c_words}" \
   548	    --arg voice "${_c_voice}" --arg voice_reason "${_c_voice_reason}" '
   549	    . + {
   550	      candidate_id: (.ref // .refs[0] // "unknown"),
   551	      contact_method:
   552	        ( if ((.email // "") != "")        then {type: "email",    value: .email}
   553	          elif ((.phone // "") != "")       then {type: "phone",    value: .phone}
   554	          elif ((.linkedin_url // "") != "") then {type: "linkedin", value: .linkedin_url}
   555	          elif ((.ref // "") | startswith("bullhorn:")) then {type: "bullhorn_internal", value: .ref}
   556	          else {type: "missing", value: ""} end ),
   557	      voice_score: (if ($voice | test("^[0-9.]+$")) then ($voice | tonumber) else $voice end),
   558	      voice_reason: $voice_reason,
   559	      rationale_body: $rationale,
   560	      rationale_body_preview: ($rationale | .[0:500]),
   561	      rationale_word_count: ($words | tonumber)
   562	    }')"
   563	  jq --argjson c "${_c_entry}" '. + [$c]' "${FINAL_JSON}" > "${FINAL_JSON}.tmp" \
   564	    && mv "${FINAL_JSON}.tmp" "${FINAL_JSON}"
   565	  hh_decision_output "candidate_proposed" "candidate:${_c_ref}" \
   566	    "source:${_c_sources}; confidence:${_c_conf}; voice_score:${_c_voice}; included:true"
   567	done < <(jq -r '.[] | @base64' "${RANKED_JSON}")
   568	
   569	# candidate_proposed rows for the Step 8 DNC drops (included=false per spec-003 §3).
   570	while IFS= read -r _d_b64; do
   571	  [[ -z "${_d_b64}" ]] && continue
   572	  _d="$(printf '%s' "${_d_b64}" | base64 -d)"
   573	  hh_decision_output "candidate_proposed" \
   574	    "candidate:$(printf '%s' "${_d}" | jq -r '.ref // .refs[0] // "unknown"')" \
   575	    "source:$(printf '%s' "${_d}" | jq -r '(.sources // [.source]) | join(",")'); confidence:$(printf '%s' "${_d}" | jq -r '.confidence // 0'); voice_score:n/a; included:false; drop_reason:dnc_filter"
   576	done < <(jq -r '.[] | @base64' "${DNC_DROPPED_JSON}")
   577	
   578	[[ "${_ss_total_ranked}" -gt 15 ]] \
   579	  && _ss_exception "$((_ss_total_ranked - 15)) candidate(s) below the top-15 rank cutoff (logged with included=false)"
   580	
   581	# ────────────────────────────────────────────────────────────────────────
   582	# Step 10 — Output assembly + Gate A validation (validate.sh) → vault report
   583	# Gate A failure: partial draft to /tmp + validate_gate_a_fail + ESC row
   584	# (validate.sh emits both) + exit 1 BEFORE the scout_report row.
   585	# ────────────────────────────────────────────────────────────────────────
   586	
   587	PROPOSAL_JSON="${_SS_TMPD}/proposal.json"
   588	_ss_bh_stats="$(jq -c -n --arg note "${SOURCE_NOTE[bullhorn]}" \
   589	  --argjson queried "$([[ "${SOURCE_STATE[bullhorn]}" == "live" || "${SOURCE_NOTE[bullhorn]}" == *429* ]] && echo true || echo false)" \
   590	  --argjson returned "$(jq 'length' "${_SS_TMPD}/bullhorn.json")" \
   591	  '{queried: $queried, returned: $returned, note: $note}')"
   592	_ss_reed_stats="$(jq -c -n --arg note "${SOURCE_NOTE[reed]}" \
   593	  --argjson queried "$([[ "${SOURCE_STATE[reed]}" == "live" || "${SOURCE_NOTE[reed]}" == *429* ]] && echo true || echo false)" \
   594	  --argjson returned "$(jq 'length' "${_SS_TMPD}/reed.json")" \
   595	  '{queried: $queried, returned: $returned, note: $note}')"
   596	_ss_cvl_stats="$(jq -c -n --arg note "${SOURCE_NOTE[cvlibrary]}" \
   597	  --argjson queried "$([[ "${SOURCE_STATE[cvlibrary]}" == "live" || "${SOURCE_NOTE[cvlibrary]}" == *429* ]] && echo true || echo false)" \
   598	  --argjson returned "$(jq 'length' "${_SS_TMPD}/cvlibrary.json")" \
   599	  '{queried: $queried, returned: $returned, note: $note}')"
   600	
   601	_ss_live_now=0
   602	for _src in bullhorn reed cvlibrary; do
   603	  [[ "${SOURCE_STATE[${_src}]}" == "live" ]] && _ss_live_now=$((_ss_live_now + 1))
   604	done
   605	
   606	jq -n \
   607	  --arg brief_id "${BRIEF_ID_ARG:-${BRIEF_SLUG}}" \
   608	  --arg tenant "${CTX_TENANT_SLUG}" \
   609	  --slurpfile brief "${BRIEF_JSON}" \
   610	  --slurpfile candidates "${FINAL_JSON}" \
   611	  --argjson sources_active "${_ss_live_now}" \
   612	  --arg degraded "${SOURCES_DEGRADED}" \
   613	  --argjson bh "${_ss_bh_stats}" --argjson reed "${_ss_reed_stats}" --argjson cvl "${_ss_cvl_stats}" \
   614	  --rawfile exceptions "${_SS_EXCEPTIONS}" \
   615	  '{ brief_id: $brief_id, tenant_slug: $tenant, brief: $brief[0],
   616	     candidates: $candidates[0],
   617	     sources_active: $sources_active,
   618	     sources_degraded: ($degraded | if . == "" then [] else split(",") end | unique),
   619	     source_stats: {
   620	       bullhorn: $bh,
   621	       linkedin: {queried: false, returned: 0, note: "deferred to v1.1+; vendor pending"},
   622	       reed: $reed,
   623	       cvlibrary: $cvl },
   624	     exceptions: ($exceptions | split("\n") | map(select(. != ""))) }' \
   625	  > "${PROPOSAL_JSON}"
   626	
   627	_ss_final_count="$(jq '.candidates | length' "${PROPOSAL_JSON}")"
   628	_ss_sources_used="$(jq '[.source_stats | to_entries[] | select(.value.returned > 0)] | length' "${PROPOSAL_JSON}")"
   629	
   630	_ss_validate="${CTX_AGENT_DIR}/validate.sh"
   631	[[ -f "${_ss_validate}" ]] || _ss_validate="${IFOS_REPO_ROOT:-}/agents/recruitment/sourcing-scout/validate.sh"
   632	
   633	GATE_A="FAIL"
   634	if bash "${_ss_validate}" "${PROPOSAL_JSON}"; then
   635	  GATE_A="PASS"
   636	fi
   637	
   638	if [[ "${GATE_A}" != "PASS" ]]; then
   639	  # Partial draft to /tmp (NOT the vault) with the partial banner +
   640	  # degradation notes; validate.sh already emitted validate_gate_a_fail +
   641	  # the ESC row. Exit 1 BEFORE the scout_report row (agent.md §4 Step 10).
   642	  PARTIAL_PATH="/tmp/sourcing-scout-${CTX_TENANT_SLUG}-${BRIEF_SLUG}-partial.md"
   643	  bash "$(_ss_bin render-scout-report.sh)" "${PROPOSAL_JSON}" --partial > "${PARTIAL_PATH}" 2>/dev/null || true
   644	  chmod 0600 "${PARTIAL_PATH}" 2>/dev/null || true
   645	  printf 'cycle.sh: Gate A FAIL — partial draft at %s\n' "${PARTIAL_PATH}" >&2
   646	  hh_decision_action "scout_run_complete" "brief:${BRIEF_SLUG}" \
   647	    "$(printf '%s' "${CTX_TENANT_SLUG}|${BRIEF_SLUG}|fail" | shasum -a 256 2>/dev/null | cut -c1-16)" \
   648	    "mode:${MODE}; tenant:${CTX_TENANT_SLUG}; gate_a:FAIL; candidates_final:${_ss_final_count}; sources_used:${_ss_sources_used}; partial_draft:${PARTIAL_PATH}" || true
   649	  exit 1
   650	fi
   651	
   652	REPORT_DIR="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/sourcing-scout-reports"
   653	REPORT_PATH="${REPORT_DIR}/${BRIEF_SLUG}-$(date -u +%Y-%m-%d).md"
   654	mkdir -p "${REPORT_DIR}" 2>/dev/null || true
   655	chmod 0700 "${REPORT_DIR}" 2>/dev/null || true
   656	bash "$(_ss_bin render-scout-report.sh)" "${PROPOSAL_JSON}" > "${REPORT_PATH}"
   657	chmod 0600 "${REPORT_PATH}" 2>/dev/null || true
   658	hh_decision_output "scout_report" "${REPORT_PATH}" \
   659	  "${_ss_final_count} candidates from ${_ss_sources_used} sources; gate_a:PASS"
   660	
   661	# ────────────────────────────────────────────────────────────────────────
   662	# Step 11 — Session close + operator notification (per invocation source)
   663	# Telegram when configured (green-tier operator_notify_telegram); Brain UI
   664	# mode notifies via the internal API (stdout note until the Brain UI in-app
   665	# channel lands); cli mode → stdout.
   666	# ────────────────────────────────────────────────────────────────────────
   667	
   668	_ss_notified="stdout"
   669	if [[ "${MODE}" == "telegram" && -n "${TELEGRAM_BOT_TOKEN:-}" \
   670	      && -n "${CTX_OPERATOR_TELEGRAM_CHAT_ID:-}" && "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" != "unset" ]] \
   671	     && command -v curl >/dev/null 2>&1; then
   672	  if curl -fsS -m 10 "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
   673	       --data-urlencode "chat_id=${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
   674	       --data-urlencode "text=Sourcing Scout: ${_ss_final_count} candidates for brief ${BRIEF_SLUG} → ${REPORT_PATH}" \
   675	       >/dev/null 2>&1; then
   676	    _ss_notified="telegram"
   677	    hh_decision_action "operator_notify_telegram" "chat:${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
   678	      "$(printf '%s' "${REPORT_PATH}" | shasum -a 256 2>/dev/null | cut -c1-16)" \
   679	      "scout report complete; brief:${BRIEF_SLUG}; report:${REPORT_PATH}" || true
   680	  fi
   681	fi
   682	printf '[sourcing-scout cycle.sh] gate_a=PASS candidates=%s sources_used=%s report=%s notify=%s\n' \
   683	  "${_ss_final_count}" "${_ss_sources_used}" "${REPORT_PATH}" "${_ss_notified}"
   684	
   685	_ss_run_hash="$(printf '%s' "${CTX_TENANT_SLUG}|${BRIEF_SLUG}|$(date -u +%s)" | shasum -a 256 2>/dev/null | cut -c1-16)"
   686	[[ -z "${_ss_run_hash}" ]] && _ss_run_hash="run-${BRIEF_SLUG}"
   687	hh_decision_action "scout_run_complete" "brief:${BRIEF_SLUG}" "${_ss_run_hash}" \
   688	  "mode:${MODE}; tenant:${CTX_TENANT_SLUG}; gate_a:PASS; candidates_final:${_ss_final_count}; sources_used:${_ss_sources_used}; report_path:${REPORT_PATH}; notify:${_ss_notified}" || true
   689	
   690	exit 0

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '585,605p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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

exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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

codex
One material mismatch has surfaced: the written Gate A says voice scoring is hard once a corpus exists, but the live cycle currently records `unscored` when the corpus is active and the classifier is unavailable. I’m checking whether the shared policy/action registrations create an additional gate failure or whether this is the only blocker.
exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '1,280p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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
    31	
    32	# Resolve the autosend-policy + escalation-codes paths through a fallback
    33	# chain (rendered → repo source-tree → computed relatives). Mirrors the
    34	# pattern used in agents/*/context.sh + validate.sh. Without this, direct
    35	# source-tree execution (Day-13 + Day-25 Hays smoke) prints "policy file
    36	# not found" warnings even though Gate A passes via deterministic fallback.
    37	_hh_resolve_shared_path() {
    38	  local filename="$1" override_val="$2" candidate
    39	  if [[ -n "${override_val}" ]]; then
    40	    printf '%s' "${override_val}"
    41	    return 0
    42	  fi
    43	  for candidate in \
    44	    "${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/${filename}" \
    45	    "${IFOS_REPO_ROOT:-}/agents/_shared/${filename}" \
    46	    "${CTX_AGENT_DIR:-.}/../../_shared/${filename}" \
    47	    "${CTX_AGENT_DIR:-.}/../_shared/${filename}" ; do
    48	    if [[ -n "${candidate}" && -f "${candidate}" ]]; then
    49	      printf '%s' "${candidate}"
    50	      return 0
    51	    fi
    52	  done
    53	  # Nothing resolved — fall back to legacy default so downstream consumers
    54	  # fail loudly at use-time with a clear path in the error message.
    55	  printf '%s' "${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/${filename}"
    56	}
    57	
    58	_HH_POLICY_FILE="$(_hh_resolve_shared_path "autosend-policy.yaml" "${HH_POLICY_FILE:-}")"
    59	_HH_ESC_CATALOGUE="$(_hh_resolve_shared_path "escalation-codes.md" "${HH_ESC_CATALOGUE:-}")"
    60	
    61	# Fallback file used when IFOS_DB_URL is unset OR psql is unavailable.
    62	# Resolved at first call to _hh_emit_row().
    63	_hh_resolve_fallback_path() {
    64	  if [[ -n "${IFOS_DECISION_LOG_FALLBACK:-}" ]]; then
    65	    printf '%s' "${IFOS_DECISION_LOG_FALLBACK}"
    66	    return 0
    67	  fi
    68	  local tenant="${CTX_TENANT_SLUG:-unknown}"
    69	  local vault_root="${IFOS_VAULT_ROOT:-/vault}"
    70	  printf '%s/%s/decision-log.jsonl' "${vault_root}" "${tenant}"
    71	}
    72	
    73	# JSON escape a single string for inclusion in a JSON value.
    74	# Use this when BUILDING a JSON document from plain text.
    75	_hh_json_escape() {
    76	  local input="$1"
    77	  input="${input//\\/\\\\}"
    78	  input="${input//\"/\\\"}"
    79	  input="${input//$'\n'/\\n}"
    80	  input="${input//$'\r'/\\r}"
    81	  input="${input//$'\t'/\\t}"
    82	  printf '%s' "${input}"
    83	}
    84	
    85	# SQL escape a string for inclusion in a single-quoted SQL string literal.
    86	# Use this when EMBEDDING values in psql SQL. Doubles single quotes;
    87	# leaves everything else (incl. backslashes, JSON internal " characters)
    88	# alone — Postgres standard_conforming_strings=on (default since 9.1)
    89	# treats backslash as literal.
    90	_hh_sql_escape() {
    91	  local input="$1"
    92	  printf '%s' "${input//\'/\'\'}"
    93	}
    94	
    95	# Current ISO-8601 UTC timestamp with millisecond precision where available.
    96	# GNU date supports %3N (3-digit nanoseconds → milliseconds). BSD date
    97	# (macOS default) does NOT error on the spec but outputs the literal
    98	# string "3N" instead, which Postgres rejects as invalid timestamptz.
    99	# Detect by checking that %3N produced exactly 3 digits.
   100	_hh_now_iso() {
   101	  local ms
   102	  ms=$(date -u +"%3N" 2>/dev/null)
   103	  if [[ "${ms}" =~ ^[0-9]{3}$ ]]; then
   104	    date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
   105	  else
   106	    date -u +"%Y-%m-%dT%H:%M:%SZ"
   107	  fi
   108	}
   109	
   110	# Validate that ESC code exists in the catalogue.
   111	# Returns 0 if known, 1 otherwise. Catalogue absent → permissive (return 0).
   112	_hh_validate_esc_code() {
   113	  local code="$1"
   114	  if [[ ! -f "${_HH_ESC_CATALOGUE}" ]]; then
   115	    return 0
   116	  fi
   117	  if grep -Fq "\`${code}\`" "${_HH_ESC_CATALOGUE}"; then
   118	    return 0
   119	  fi
   120	  return 1
   121	}
   122	
   123	# ────────────────────────────────────────────────────────────────────────
   124	# Core decision-log writer
   125	# ────────────────────────────────────────────────────────────────────────
   126	
   127	# _hh_emit_row <phase> <outcome> <reason> <payload_json>
   128	#
   129	# Writes one row to decision_log. Live mode (IFOS_DB_URL set + psql available):
   130	# INSERT via psql -v ON_ERROR_STOP=1. Offline mode: append JSON line to
   131	# fallback file. The two formats are reconcilable by the sync worker.
   132	_hh_emit_row() {
   133	  local phase="$1"
   134	  local outcome="${2:-}"
   135	  local reason="${3:-}"
   136	  local payload_json="${4:-{\}}"
   137	
   138	  local tenant agent created_at
   139	  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   140	  agent="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"
   141	  created_at="$(_hh_now_iso)"
   142	
   143	  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   144	    local sql
   145	    sql=$(cat <<EOF
   146	BEGIN;
   147	SET LOCAL app.current_tenant = '$(_hh_sql_escape "${tenant}")';
   148	INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
   149	VALUES (
   150	  '$(_hh_sql_escape "${tenant}")',
   151	  '$(_hh_sql_escape "${agent}")',
   152	  '$(_hh_sql_escape "${phase}")',
   153	  $([ -z "${outcome}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${outcome}")"),
   154	  $([ -z "${reason}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${reason}")"),
   155	  '$(_hh_sql_escape "${payload_json}")'::jsonb,
   156	  '${created_at}'::timestamptz
   157	);
   158	COMMIT;
   159	EOF
   160	)
   161	    local psql_err
   162	    if psql_err=$(printf '%s\n' "${sql}" | psql -v ON_ERROR_STOP=1 -q "${IFOS_DB_URL}" 2>&1); then
   163	      return 0
   164	    fi
   165	    # psql failed — fall through to fallback append + emit warning to stderr
   166	    printf 'hh_emit_row: psql write failed; appending to fallback\n' >&2
   167	    printf 'hh_emit_row: psql error: %s\n' "${psql_err}" >&2
   168	  fi
   169	
   170	  local fallback
   171	  fallback="$(_hh_resolve_fallback_path)"
   172	  mkdir -p "$(dirname "${fallback}")" 2>/dev/null || true
   173	
   174	  local row
   175	  row=$(printf '{"tenant_slug":"%s","agent_name":"%s","phase":"%s","outcome":%s,"reason":%s,"payload":%s,"created_at":"%s","_hh_version":"%s"}' \
   176	    "$(_hh_json_escape "${tenant}")" \
   177	    "$(_hh_json_escape "${agent}")" \
   178	    "$(_hh_json_escape "${phase}")" \
   179	    "$([ -z "${outcome}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${outcome}")")" \
   180	    "$([ -z "${reason}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${reason}")")" \
   181	    "${payload_json}" \
   182	    "${created_at}" \
   183	    "${_HH_HELPERS_VERSION}")
   184	
   185	  printf '%s\n' "${row}" >> "${fallback}"
   186	}
   187	
   188	# ────────────────────────────────────────────────────────────────────────
   189	# 3 hh_decision_* contracts (master brief §8.1 Change 2)
   190	# ────────────────────────────────────────────────────────────────────────
   191	
   192	# hh_decision_trigger <trigger_type> [<reason>]
   193	# Writes phase='trigger' row at session start. Required first call of every run.
   194	hh_decision_trigger() {
   195	  local trigger_type="${1:-session_start}"
   196	  local reason="${2:-}"
   197	  local payload
   198	  payload=$(printf '{"trigger_type":"%s","helpers_version":"%s"}' \
   199	    "$(_hh_json_escape "${trigger_type}")" "${_HH_HELPERS_VERSION}")
   200	  _hh_emit_row "trigger" "" "${reason}" "${payload}"
   201	}
   202	
   203	# hh_decision_output <output_type> <artefact_ref> [<reason>]
   204	# Writes phase='output' row per artefact produced. Required before producing
   205	# a customer-visible artefact (Gate B per master brief §1 Rule 4).
   206	hh_decision_output() {
   207	  local output_type="$1"
   208	  local artefact_ref="$2"
   209	  local reason="${3:-}"
   210	  local payload
   211	  payload=$(printf '{"output_type":"%s","artefact_ref":"%s"}' \
   212	    "$(_hh_json_escape "${output_type}")" "$(_hh_json_escape "${artefact_ref}")")
   213	  _hh_emit_row "output" "produced" "${reason}" "${payload}"
   214	}
   215	
   216	# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
   217	# Writes phase='action' or phase='gating_failed' row depending on tier.
   218	# Returns 0 if action allowed; 1 if blocked or approval rejected.
   219	hh_decision_action() {
   220	  local action_type="$1"
   221	  local target="$2"
   222	  local payload_hash="$3"
   223	  local payload_preview="$4"
   224	
   225	  local tenant tier
   226	  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   227	
   228	  if ! tier=$(autosend_policy_lookup "${action_type}"); then
   229	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   230	      "${target}" "${payload_hash}" "${payload_preview}" "policy_lookup_failed"
   231	    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   232	      "${target}" "${payload_hash}" "unknown_action_type"
   233	    return 1
   234	  fi
   235	
   236	  if ! tier=$(autosend_apply_tenant_override "${tier}" "${action_type}" "${tenant}"); then
   237	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   238	      "${target}" "${payload_hash}" "${payload_preview}" "override_resolution_failed"
   239	    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   240	      "${target}" "${payload_hash}" "override_resolution_failed"
   241	    return 1
   242	  fi
   243	
   244	  case "${tier}" in
   245	    green)
   246	      autosend_emit_decision_log "action" "green" "${action_type}" \
   247	        "${target}" "${payload_hash}" "${payload_preview}" ""
   248	      return 0
   249	      ;;
   250	    yellow)
   251	      autosend_emit_decision_log "action" "yellow" "${action_type}" \
   252	        "${target}" "${payload_hash}" "${payload_preview}" ""
   253	      if autosend_should_sample "${action_type}" "${tenant}"; then
   254	        autosend_spot_check_enqueue "${action_type}" "${target}" \
   255	          "${payload_hash}" "${payload_preview}" "${tenant}"
   256	      fi
   257	      return 0
   258	      ;;
   259	    orange)
   260	      autosend_emit_decision_log "action" "orange" "${action_type}" \
   261	        "${target}" "${payload_hash}" "${payload_preview}" "approval_pending"
   262	      autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
   263	        "${target}" "${payload_hash}" "${payload_preview}"
   264	      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
   265	      return $?
   266	      ;;
   267	    red)
   268	      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
   269	        "${target}" "${payload_hash}" "${payload_preview}" "red_tier_classification"
   270	      autosend_escalate "ESC_AUTOSEND_BLOCKED" "${action_type}" \
   271	        "${target}" "${payload_hash}" "red_tier_classification"
   272	      return 1
   273	      ;;
   274	    *)
   275	      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   276	        "${target}" "${payload_hash}" "${payload_preview}" "unknown_tier:${tier}"
   277	      autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   278	        "${target}" "${payload_hash}" "unknown_tier:${tier}"
   279	      return 1
   280	      ;;

exec
/bin/zsh -lc "rg -n \"operator_notify_telegram|validate_gate_a_fail|scout_run_complete|consultant_feedback|action_type\" agents/_shared docs agents/recruitment/sourcing-scout -g '*.{md,yaml,yml,sh}'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
exec
/bin/zsh -lc "find agents/recruitment/sourcing-scout -maxdepth 2 -type f | sort | while read f; do printf '%s\\n' \""'$f"; done' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
agents/recruitment/sourcing-scout/validate.sh:10:# hh_decision_action("validate_gate_a_fail", ...) audit row carrying the
agents/recruitment/sourcing-scout/validate.sh:46:#   1  At least one check failed; validate_gate_a_fail + ESC_* rows emitted;
agents/recruitment/sourcing-scout/validate.sh:370:  # validate_gate_a_fail (green tier, registered).
agents/recruitment/sourcing-scout/validate.sh:371:  hh_decision_action "validate_gate_a_fail" "brief:${BRIEF_ID}" "${_ss_phash}" \
agents/_shared/autosend-policy.yaml:8:# 47 v1.0 action_types: 19 green + 10 yellow + 10 orange + 8 red.
agents/_shared/autosend-policy.yaml:23:action_types:
agents/_shared/autosend-policy.yaml:26:  # GREEN — auto-send without review (19 action_types)
agents/_shared/autosend-policy.yaml:65:  operator_notify_telegram:
agents/_shared/autosend-policy.yaml:77:  scout_run_complete:
agents/_shared/autosend-policy.yaml:98:    reason: "Status marker recorded AFTER an external send completes (the send itself was a different orange/yellow action_type with its own decision_log row); this row closes the workflow trace"
agents/_shared/autosend-policy.yaml:104:    reason: "Internal audit row recorded by Concierge cycle.sh Step 11 when an approval is routed via the autosend-bridge (per Founder Decision D1 path A/B/C). Payload carries d1_path + bridge_target (approval_id or vault path). Not an external send; the actual send is a downstream orange-tier action_type with its own row."
agents/_shared/autosend-policy.yaml:113:  consultant_feedback:
agents/_shared/autosend-policy.yaml:119:  validate_gate_a_fail:
agents/_shared/autosend-policy.yaml:150:  # MCP-connector OAuth refresh action_types (added 2026-06-01
agents/_shared/autosend-policy.yaml:152:  # documented action_types to exist in this policy with matching
agents/_shared/autosend-policy.yaml:166:    reason: "QuickBooks Online OAuth 2.0 refresh — idempotent token rotation against oauth.platform.intuit.com; @ifos/quickbooks connector handles concurrent-refresh dedup per-realm; QB refresh tokens have ~100-day TTL so operator alerting on refreshTokenNearExpiry() is the consumer's responsibility, not this action_type's."
agents/_shared/autosend-policy.yaml:172:    reason: "TrueLayer OAuth 2.0 refresh — idempotent token rotation against auth.truelayer.com; @ifos/open-banking connector handles concurrent-refresh dedup per-connection; PSD2 90-day consent expiry surfaces via ESC_OPEN_BANKING_TOKEN_AGING (separate aging signal, not this action_type)."
agents/_shared/autosend-policy.yaml:188:  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
agents/_shared/autosend-policy.yaml:258:    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
agents/_shared/autosend-policy.yaml:262:  # ORANGE — per-action human approval (10 action_types)
agents/_shared/autosend-policy.yaml:337:  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
agents/_shared/autosend-policy.yaml:412:  - "yellow action_types MUST declare sample_rate (positive integer)"
agents/_shared/autosend-policy.yaml:413:  - "orange action_types MUST declare timeout (ISO-8601 duration)"
agents/_shared/autosend-policy.yaml:414:  - "red action_types MUST declare block_reason"
agents/_shared/autosend-policy.yaml:416:  - "47 total action_types (19 green + 10 yellow + 10 orange + 8 red); v1.0 frozen as of 2026-05-24 bilateral-disposition extension"
agents/recruitment/sourcing-scout/cleanup.sh:7:# Per agent.md §3 actions list: Sourcing Scout's cleanup action_type is
agents/recruitment/sourcing-scout/cleanup.sh:114:# NOTE: sourcing_scout_cleanup action_type is still QUEUED (not yet in
agents/recruitment/sourcing-scout/cleanup.sh:115:# autosend-policy.yaml — spec-003 §2 registers only scout_run_complete +
agents/recruitment/sourcing-scout/cleanup.sh:116:# validate_gate_a_fail for this agent). Until the policy row lands, the
agents/recruitment/sourcing-scout/README.md:18:| `validate.sh` | LIVE — Gate A G1-G7 per spec-003 §5 (validate_gate_a_fail + per-class ESC routing) |
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:833:      send refusal (autosend-safety-policy §5 red-tier action_type
agents/recruitment/sourcing-scout/fixtures/99-dnc-bulk-filter.yaml:136:      action_type: session_start
agents/recruitment/sourcing-scout/fixtures/99-dnc-bulk-filter.yaml:148:      action_type: validate_gate_a_fail
agents/recruitment/sourcing-scout/fixtures/99-dnc-bulk-filter.yaml:151:      action_type: scout_run_complete
agents/_shared/escalation-codes.md:20:payload           — JSON object: {tier?, action_type?, target?, payload_hash?, reason, ...code-specific fields}
agents/_shared/escalation-codes.md:39:- **Payload fields:** `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `approval_status='pending'`
agents/_shared/escalation-codes.md:46:- **Payload fields:** `tier='red'`, `action_type`, `target`, `payload_hash`, `reason='red_tier_classification'`
agents/_shared/escalation-codes.md:50:- **Trigger:** `autosend_policy_lookup()` could not resolve a tier for the given `action_type` (unknown action_type, malformed `autosend-policy.yaml`, or tenant override resolution failed)
agents/_shared/escalation-codes.md:53:- **Payload fields:** `tier='fail-safe-red'`, `action_type`, `target`, `reason` (one of `unknown_action_type`, `override_resolution_failed`, `unknown_tier:<value>`)
agents/_shared/escalation-codes.md:346:- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`
agents/_shared/escalation-codes.md:353:- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:363:- **Payload fields:** `race_class` (`duplicate_payload` | `state_change_cancellation`), `payload_hash`, class-specific: duplicate → `first_agent_name`, `second_agent_name`, `time_delta_ms`, `action_type`; state-change → `entity_id`, `state_before`, `state_after`, `time_delta_ms`
agents/_shared/escalation-codes.md:371:- **Payload fields:** `action_type`, `original_decision_log_id`, `sample_rate`, `sampling_reason`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:429:- **Payload fields:** `recipient_id_hash`, `dnc_list_source`, `dnc_match_reason` (e.g. `explicit_opt_out`, `previous_complaint`, `gdpr_objection`), `action_type_attempted`
agents/recruitment/sourcing-scout/tools.yaml:11:# capability cycle.sh invokes + the autosend-policy action_type each
agents/recruitment/sourcing-scout/tools.yaml:17:# The only registered action_type declared here is operator_notify_telegram;
agents/recruitment/sourcing-scout/tools.yaml:44:    future_registration: bullhorn_oauth  # NOT a registered autosend-policy action_type yet; registration is a founder-gated policy decision; until then the code path emits hh_decision_output / degraded-skip only
agents/recruitment/sourcing-scout/tools.yaml:76:    future_registration: reed_oauth  # NOT a registered autosend-policy action_type yet; registration is a founder-gated policy decision; until then the code path emits hh_decision_output / degraded-skip only
agents/recruitment/sourcing-scout/tools.yaml:98:    future_registration: cvlibrary_oauth  # NOT a registered autosend-policy action_type yet; registration is a founder-gated policy decision; until then the code path emits hh_decision_output / degraded-skip only
agents/recruitment/sourcing-scout/tools.yaml:144:    action_type: operator_notify_telegram  # green tier; REGISTERED in autosend-policy.yaml
agents/recruitment/sourcing-scout/tools.yaml:155:    future_registration: sourcing_scout_cleanup  # NOT a registered autosend-policy action_type yet; registration is a founder-gated policy decision; until then cleanup.sh emits hh_decision_output only (verified: no hh_decision_action call in cleanup.sh)
agents/recruitment/sourcing-scout/tools.yaml:210:#   operator_notify_telegram        green
agents/recruitment/sourcing-scout/tools.yaml:211:# (cycle.sh also emits the shared registered action_types scout_run_complete
agents/recruitment/sourcing-scout/tools.yaml:212:# + validate_gate_a_fail — substrate rows, not capability declarations here.)
agents/recruitment/sourcing-scout/tools.yaml:214:# future_registration ONLY — NOT registered autosend-policy action_types yet;
agents/recruitment/sourcing-scout/tools.yaml:217:# degraded-skip — NO unregistered action_type row is ever emitted:
agents/recruitment/sourcing-scout/tools.yaml:223:# NOTE: Sourcing Scout has NO yellow- or orange- or red-tier action_types.
agents/recruitment/sourcing-scout/tools.yaml:236:# - Every action_type declared maps to a registered autosend-policy.yaml tier;
agents/recruitment/sourcing-scout/tools.yaml:237:#   future_registration entries above are explicitly NOT action_type claims
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:156:      action_type: session_start
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:179:      action_type: scout_run_complete
agents/_shared/hook-helpers.sh:216:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:220:  local action_type="$1"
agents/_shared/hook-helpers.sh:228:  if ! tier=$(autosend_policy_lookup "${action_type}"); then
agents/_shared/hook-helpers.sh:229:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:231:    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:232:      "${target}" "${payload_hash}" "unknown_action_type"
agents/_shared/hook-helpers.sh:236:  if ! tier=$(autosend_apply_tenant_override "${tier}" "${action_type}" "${tenant}"); then
agents/_shared/hook-helpers.sh:237:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:239:    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:246:      autosend_emit_decision_log "action" "green" "${action_type}" \
agents/_shared/hook-helpers.sh:251:      autosend_emit_decision_log "action" "yellow" "${action_type}" \
agents/_shared/hook-helpers.sh:253:      if autosend_should_sample "${action_type}" "${tenant}"; then
agents/_shared/hook-helpers.sh:254:        autosend_spot_check_enqueue "${action_type}" "${target}" \
agents/_shared/hook-helpers.sh:260:      autosend_emit_decision_log "action" "orange" "${action_type}" \
agents/_shared/hook-helpers.sh:262:      autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:264:      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
agents/_shared/hook-helpers.sh:268:      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
agents/_shared/hook-helpers.sh:270:      autosend_escalate "ESC_AUTOSEND_BLOCKED" "${action_type}" \
agents/_shared/hook-helpers.sh:275:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:277:      autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:288:# autosend_policy_lookup <action_type>
agents/_shared/hook-helpers.sh:290:# 1 if action_type missing from policy file.
agents/_shared/hook-helpers.sh:292:  local action_type="$1"
agents/_shared/hook-helpers.sh:297:  # YAML lookup via awk — finds the action_type key, then reads tier:
agents/_shared/hook-helpers.sh:300:  tier=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:311:# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:317:  local action_type="$2"
agents/_shared/hook-helpers.sh:333:  override=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:349:      "${base_tier}" "${override}" "${tenant_slug}" "${action_type}" >&2
agents/_shared/hook-helpers.sh:355:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
agents/_shared/hook-helpers.sh:360:  local action_type="$3"
agents/_shared/hook-helpers.sh:367:  payload=$(printf '{"tier":"%s","action_type":"%s","target":"%s","payload_hash":"%s","payload_preview":"%s","approval_status":%s,"block_reason":%s,"policy_version_sha":"%s"}' \
agents/_shared/hook-helpers.sh:369:    "$(_hh_json_escape "${action_type}")" \
agents/_shared/hook-helpers.sh:416:# autosend_should_sample <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:421:  local action_type="$1"
agents/_shared/hook-helpers.sh:424:  rate=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:442:# autosend_spot_check_enqueue <action_type> <target> <payload_hash> <payload_preview> <tenant_slug>
agents/_shared/hook-helpers.sh:446:  local action_type="$1"
agents/_shared/hook-helpers.sh:460:  local outfile="${spot_dir}/${timestamp}-${action_type}-${payload_hash:0:12}.md"
agents/_shared/hook-helpers.sh:467:    printf '# Spot check — %s\n\n' "${action_type}"
agents/_shared/hook-helpers.sh:477:# autosend_await_approval <action_type> <target> <payload_hash>
agents/_shared/hook-helpers.sh:484:  local action_type="$1"
agents/_shared/hook-helpers.sh:489:  timeout_iso=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:514:    printf 'action_type=%s\n' "${action_type}"
agents/_shared/hook-helpers.sh:537:        autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:565:  autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:208:      action_type:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:212:        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
agents/recruitment/sourcing-scout/fixtures/02-edge-case-degraded-sources.yaml:9:# validate_gate_a_fail action rows are reserved for Gate A itself.
agents/recruitment/sourcing-scout/fixtures/02-edge-case-degraded-sources.yaml:147:      action_type: session_start
agents/recruitment/sourcing-scout/fixtures/02-edge-case-degraded-sources.yaml:170:      action_type: validate_gate_a_fail
agents/recruitment/sourcing-scout/fixtures/02-edge-case-degraded-sources.yaml:173:      action_type: scout_run_complete
agents/recruitment/sourcing-scout/agent.md:5:**Reading-discipline note (updated 2026-06-10 at W9 build; originally added 2026-06-03 per CC + Concierge + Janitor + Scribe precedent):** this `agent.md` is the **CONTRACT** that the W9 build slice implemented against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml` + `README.md`) + 3 fixtures are **LIVE** — the W9 build slice (spec-003, this branch) replaced every `TODO(W9)` marker with live implementation; three deterministic DB-backed fixture suites (`scripts/run-scout-{dedupe,gate-a,degraded}-test.sh`) are green under build-gate. **Per-component build state, honestly stated:** `@ifos/bullhorn` — implemented connector package (`packages/mcp-connectors/bullhorn`); the Sourcing-Scout OAuth CLI bridge is not built and creds are EMPTY → cycle.sh Step 2 degraded-skip. `@ifos/reed` — implemented connector package (`packages/mcp-connectors/reed`, v0.1.0, tests green); creds EMPTY → degraded-skip until founder signup. `@ifos/cv-library` — implemented connector package + built `dist/cli.js` bridge (`packages/mcp-connectors/cv-library`, v0.1.0); the designated v1.0 live source, but creds EMPTY at last names-only verification → live smoke founder-gated. None of the three is production-proven: no live API call has been made by this bundle; all coverage is fixture-driven (`IFOS_SCOUT_FIXTURE_*`). **VENDOR NOTE:** the v1.0 contract is THREE active sources (Bullhorn + Reed + CV-Library); LinkedIn is structurally present as an explicit NO-OP only — cycle.sh Step 4 emits `linkedin_query` (`results:0; no_op`) per the Janitor Step 7 NO-OP pattern; vendor selection deferred to v1.1+ per the caveat at lines 6-8. **Live audit-marker set emitted by cycle.sh:** `session_start`, `brief_ingested`, `auth_refresh_complete`, `bullhorn_query`, `linkedin_query` (no-op), `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `candidate_proposed` (one row PER candidate), `scout_report`, `scout_run_complete`, plus `validate_gate_a_fail` (Gate A failure only) and `operator_notify_telegram` (when configured). Pure read+report agent — no yellow/orange/red action_types; the cleanup action name `sourcing_scout_cleanup` is NOT a registered autosend-policy action_type — registration is a founder-gated policy decision (a `future_registration` entry in tools.yaml, not an action_type claim); `cleanup.sh` emits `hh_decision_output` until it lands. `context.sh` uses the canonical `tenant_adapters` SELECT path (with `IFOS_FORCE_*` fixture fallbacks retained for tests) — `bullhorn_corporation_id` v0.4-allowlisted (LIVE on VPS commit `a1bbcf6`) + `blocked_recipients` v0.3-allowlisted (LIVE on VPS). §10 lifecycle status remains **Proposed** pending Codex re-ratification of the built bundle + founder approvals — the status flip is founder-gated.
agents/recruitment/sourcing-scout/agent.md:206:     `send_to_blocked_recipient` action_type + ESC_DNC_FILTER_HIT catalogue
agents/recruitment/sourcing-scout/agent.md:245:      mandatory audit row hh_decision_action("validate_gate_a_fail",
agents/recruitment/sourcing-scout/agent.md:258:    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
agents/recruitment/sourcing-scout/agent.md:282:On any Gate A failure, `validate.sh` writes the partial draft to `/tmp` and emits the mandatory `hh_decision_action("validate_gate_a_fail", ...)` audit row carrying the ESC code (per master brief §8.1 Change 2 + autosend-policy.yaml lines 119-123) BEFORE aborting; operator review.
agents/recruitment/sourcing-scout/agent.md:382:| Q5 | Gate B 6-of-10 metric — measured via consultant feedback (Brain UI v1.0 doesn't have feedback UX yet) | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful" → `decision_log` row via `consultant_feedback` green-tier action_type. v1.1: Brain UI button. NOTE: Bullhorn-note-based feedback is NOT a v1.0 path — Sourcing Scout is read-only on Bullhorn (no write capability); Bullhorn note creation would require tools.yaml write capability + autosend/decision logging which v1.0 explicitly excludes. |
docs/operations/goal-overnight-2026-05-31.md:35:7. `decision_log` integration via `_shared/hook-helpers.sh`; action_types match `autosend-policy.yaml`.
agents/_shared/voice-loader.sh:229:#   { "edits": [ { "id": N, "action_type": "...", "edit_distance": N,
agents/_shared/voice-loader.sh:245:      sql="SELECT id, action_type, COALESCE(edit_distance::text, ''), resolution, COALESCE(array_to_string(tone_rules_triggered, ','), ''), resolved_at::text
agents/_shared/voice-loader.sh:252:      sql="SELECT id, action_type, COALESCE(edit_distance::text, ''), resolution, COALESCE(array_to_string(tone_rules_triggered, ','), ''), resolved_at::text
agents/_shared/voice-loader.sh:279:  while IFS=$'\t' read -r id action_type edit_distance resolution tone_rules resolved_at; do
agents/_shared/voice-loader.sh:282:    printf '{"id":%s,"action_type":"%s","edit_distance":%s,"resolution":"%s","tone_rules_triggered":"%s","resolved_at":"%s"}' \
agents/_shared/voice-loader.sh:284:      "$(_hh_json_escape "${action_type}")" \
docs/verticals/recruitment/vertical-schema.yaml:12:#       + autosend-safety-policy.md §3 (action_type references)
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
agents/recruitment/sourcing-scout/cycle.sh:167:# <3 key dimensions → ESC_BRIEF_AMBIGUITY + validate_gate_a_fail + exit 1.
agents/recruitment/sourcing-scout/cycle.sh:208:    # No validate_gate_a_fail action row here — that action_type is reserved
agents/recruitment/sourcing-scout/cycle.sh:221:  # Audit trail via autosend_escalate only; validate_gate_a_fail is reserved
agents/recruitment/sourcing-scout/cycle.sh:583:# Gate A failure: partial draft to /tmp + validate_gate_a_fail + ESC row
agents/recruitment/sourcing-scout/cycle.sh:640:  # degradation notes; validate.sh already emitted validate_gate_a_fail +
agents/recruitment/sourcing-scout/cycle.sh:646:  hh_decision_action "scout_run_complete" "brief:${BRIEF_SLUG}" \
agents/recruitment/sourcing-scout/cycle.sh:663:# Telegram when configured (green-tier operator_notify_telegram); Brain UI
agents/recruitment/sourcing-scout/cycle.sh:677:    hh_decision_action "operator_notify_telegram" "chat:${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
agents/recruitment/sourcing-scout/cycle.sh:687:hh_decision_action "scout_run_complete" "brief:${BRIEF_SLUG}" "${_ss_run_hash}" \
agents/_shared/README.md:12:| `autosend-policy.yaml` | Runtime tier table — 29 action_types per autosend-safety-policy §3 | 3 |
agents/_shared/README.md:53:hh_decision_action  <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/README.md:61:autosend_policy_lookup        <action_type>                                          # prints tier
agents/_shared/README.md:62:autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>               # prints possibly-elevated tier
agents/_shared/README.md:63:autosend_emit_decision_log    <phase> <tier> <action_type> <target> <hash> <preview> <reason>
agents/_shared/README.md:65:autosend_should_sample        <action_type> <tenant_slug>                            # returns 0 if sampled
agents/_shared/README.md:66:autosend_spot_check_enqueue   <action_type> <target> <hash> <preview> <tenant_slug>
agents/_shared/README.md:67:autosend_await_approval       <action_type> <target> <hash>                          # blocks until resolved
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:6:Morning goal + this goal's §1 · `agents/recruitment/cash-conductor/agent.md` §3+§4+§5 (consumer spec) · `packages/mcp-connectors/{xero,quickbooks,open-banking}/` (pattern) · `docs/decisions/2026-05-31-d1-founder-decision.md` §"Implementation surface" (bridge contract) · `agents/_shared/{hook-helpers.sh,autosend-policy.yaml}` (existing helpers + action_type registry) · `agents/recruitment/diagnostic/{context,cleanup}.sh` (sibling pattern for Phase A files).
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:21:- `proposeApproval({action_type, target, draft_preview, vault_path, timeout?}) → {approval_id}` — posts to operator's tenant Telegram chat with `[ID:<approval_id>]` prefix + draft preview + vault path + `/approve <id>` / `/reject <id>` instructions
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
agents/_shared/tests/test-hook-helpers.sh:179:printf '\n[8] hh_decision_action — unknown action_type → ESC_AUTOSEND_POLICY_LOOKUP_FAILED\n'
docs/operations/goal-week-4-track-1.md:169:7. **decision_log integration** — every state-changing capability emits via `_shared/hook-helpers.sh hh_decision_action` with the registered `action_type` from `autosend-policy.yaml`.
docs/operations/goal-week-4-track-1.md:426:1. **Every capability documented.** README lists all exported functions with input/output Zod schemas + which `autosend-policy.yaml` action_type they correspond to.
docs/operations/goal-week-4-track-1.md:431:6. **Integration with `_shared/hook-helpers.sh`** — every state-changing capability emits `hh_decision_action` with the correct `action_type` per `autosend-policy.yaml`.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:43:**Disposition:** **Codex is correct.** Real bug. Step 11 sends a Telegram notification (an action with external side-effect) but doesn't emit a `decision_log` row. Mechanical fix: add `hh_decision_action("operator_notify_telegram", ...)` call to Step 11.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:61:### Issue 4 (NEW) — `_consultant_feedback` sentinel undocumented
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:63:**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:69:Option A — **Add `_consultant_feedback` to the sentinel catalogue.** New entry in `agents/_shared/escalation-codes.md` documenting purpose, payload shape, and emit cadence.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:71:Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:73:**My recommendation:** **B** — cleaner, avoids sentinel proliferation. Feedback events are conceptually Diagnostic's domain (they validate Diagnostic outputs), so the agent_name should be Diagnostic with a specific action_type marker.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:91:3. **Accept Issue 4 fix per Option B** (use `agent_name='diagnostic'` with payload.action_type)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:130:4. **Sentinel agent_name usage** — _consultant_feedback (Diagnostic) is the clear case; other agents likely have similar invented sentinels. Disposition: prefer `agent_name='<agent>'` with `payload.action_type` markers; reserve sentinels for system actors (_renderer, _tenant_admin, _codex_ratifier).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:146:- Sentinel hygiene (Issue 4) is a real architectural concern; agent_name=agent + payload.action_type is the cleaner pattern; no reason to proliferate sentinels.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:214:1. `operator_notify_telegram` + `janitor_run_complete` are unregistered hh_decision_action types — hook-helpers fails them to red via `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`. (Found because my Round-6 commit added those calls without registering them.)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:227:| Round 7 | 4 | 23 | All different from R6 — many caused BY R6 fixes (added action_types without registering) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:250:- autosend-policy.yaml: 29 → 41 action_types (8 status markers + 1 Cash Conductor reconciliation + 1 Concierge email draft + 2 added during Phase 2)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:257:- Cat-2 (decision-log calls): added hh_decision_output / hh_decision_action calls across all §4 sections; pre-registered action_types via Phase 1
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:259:- Cat-4 (sentinel hygiene): Diagnostic `_consultant_feedback` → agent_name='diagnostic' + payload.action_type
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:364:- `cycle.sh` adds `hh_decision_action("operator_notify_telegram", ...)` call before Step 14 Telegram send
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:387:5. §6 says only one action_type but cycle.sh now has operator_notify_telegram (Round-9 introduced by Cat-δ commit) — Cat-α; align §6
docs/operations/w4-bilateral-pass-6-agent-md.md:62:  - **Codex says:** "Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature."
docs/operations/w4-bilateral-pass-6-agent-md.md:150:### Finding 3. Impossible draft audit-row shape (output phase with action_type)
docs/operations/w4-bilateral-pass-6-agent-md.md:152:  - **Codex says:** "Line 114 says each draft writes `phase='output'` with `action_type='xero_reminder_draft_internal'`, but `xero_reminder_draft_internal` is an autosend action type and §4 line 237 correctly routes it through `hh_decision_action`; `hh_decision_output` rows use output-type payloads, not autosend tier dispatch. Change §3 so draft generation is an output row such as `output_type='chase_draft_generated'`, and the queued draft is a separate `phase='action'` row with `action_type='xero_reminder_draft_internal'`."
docs/operations/w4-bilateral-pass-6-agent-md.md:153:  - **Likely:** FIX-IN-PLACE. Split §3 line 114 into two rows: (a) `phase='output'` with `output_type='chase_draft_generated'`; (b) `phase='action'` with `action_type='xero_reminder_draft_internal'`.
docs/operations/parallel-agent-build-method.md:104:**Substrate freeze (§3 step 0):** ✅ DONE 2026-06-10 — all 17 spec action_types verified registered in `agents/_shared/autosend-policy.yaml`; `blocked_recipients` confirmed a validated `tenant_adapters.config` key (migration chain v0.2→v0.4); all 9 Scribe v0.3-supplement field names confirmed in the schema supplements; no new migration needed; `scripts/build-gate.sh` PASS on main; CV-Library creds re-verified SET (Bullhorn/Reed EMPTY → degraded mode as specced).
docs/operations/decision-log.md:185:   - **Scribe (4):** Output-2 decision_log signature; validate_gate_a_fail 113→119; classifier-fail→hard Gate A **[DECISION]**; ESC_GATE_B_MISS in §6
docs/operations/decision-log.md:197:**Verified:** v0.3 supplement YAML parses; migration FOR/LOOP balanced + `elem` declared; shellcheck clean on the harness; all cited line numbers (autosend-policy 188/263/235-239, escalation-codes 120-125/348-353/431-439, validate_gate_a_fail 119) confirmed against source.
docs/operations/decision-log.md:214:| action_types referenced ∈ autosend-policy.yaml | ✓ 0 missing |
docs/operations/decision-log.md:250:- **Catalogue extended:** 24 → 52 ESC codes; 29 → 47 action_types; 2 new Postgres tables (cash_conductor_transactions + cash_conductor_invoices); 3 new tenant_adapters config keys
docs/operations/decision-log.md:269:- [ ] **Diagnostic validate.sh + cycle.sh polish (W3-W4)** — emit specific ESC codes per §6; write validate_check_skipped row; add operator_notify_telegram hh_decision_action call.
docs/operations/decision-log.md:437:4. Sentinel agent_name invention → use agent_name='<agent>' + payload.action_type
docs/operations/decision-log.md:785:- `agents/_shared/autosend-policy.yaml` (259 lines) — 29 v1.0 action_types: 6 green / 5 yellow / 10 orange / 8 red. Each row with tier + agent + reason + (sample_rate | timeout | block_reason).
docs/operations/decision-log.md:942:- **Contractor as separate entity_type** (not status flag on candidate) — adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor'. Rationale: autosend policy distinguishes contractor vs candidate action_types; IR35 first-class; queryability beats status-flag filtering
docs/operations/decision-log.md:964:  - 29 action_types across 6 v1.0 agents
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:14:- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:20:**Real issue:** 10 action_types (including the canonical orange `bullhorn_note_customer_visible` — Concierge's primary outbound action) are classified as orange. v1.0 ships green+red only. In v1.0, those orange action_types must either:
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:24:- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:10:> 3. §4 Gate-A failure signature is incomplete. Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature.
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:17:117  → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
docs/decisions/2026-05-18-codex-ratification-manifest.md:31:| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
docs/decisions/autosend-approval-bridge-spec.md:14:Autosend-safety-policy §3 declares 10 v1.0 action_types as **orange tier** — most importantly the canonical orange `bullhorn_note_customer_visible` (Concierge's primary outbound action). Orange-tier actions require per-action human approval via Telegram before executing.
docs/decisions/autosend-approval-bridge-spec.md:78:  - Read action_type, target, payload_hash, payload_preview from the marker
docs/decisions/autosend-approval-bridge-spec.md:79:  - Map IFOS action_type → cortextOS ApprovalCategory (autosend taxonomy)
docs/decisions/autosend-approval-bridge-spec.md:102:Mapping `{ifos_payload_hash, cortextos_approval_id, tenant_slug, action_type, created_at, resolved_at}` lives in a small SQLite database at `${CTX_FRAMEWORK_ROOT}/autosend-bridge.db` OR (cleaner) a new Postgres table `autosend_approval_mappings`:
docs/decisions/autosend-approval-bridge-spec.md:110:  action_type          TEXT NOT NULL,
docs/decisions/autosend-approval-bridge-spec.md:130:### §3.3 — IFOS action_type → cortextOS ApprovalCategory mapping
docs/decisions/autosend-approval-bridge-spec.md:132:cortextOS Primitive 4 enumerates approval categories as `external-comms`, `financial`, `deployment`, `data-deletion`, and `other` per `packages/harness/cortextos/src/types/index.ts`. IFOS action_types from `agents/_shared/autosend-policy.yaml` map as follows:
docs/decisions/autosend-approval-bridge-spec.md:134:| IFOS action_type | cortextOS category |
docs/decisions/autosend-approval-bridge-spec.md:147:`bullhorn_placement_terminate` maps to `data-deletion` because placement termination destroys/closes a placement record; `other` remains only an explicit fallback for future action_types without a clean cortextOS category. The category is metadata for cortextOS's audit; IFOS-side semantics are preserved via the action_type field in our state table.
docs/decisions/autosend-approval-bridge-spec.md:171:`autosend_await_approval` already enforces 4h default timeout per action_type's `timeout` field in autosend-policy.yaml. If the timeout fires before operator responds:
docs/decisions/autosend-approval-bridge-spec.md:208:│   ├── categoryMapper.ts     ← IFOS action_type → cortextOS ApprovalCategory
docs/decisions/autosend-approval-bridge-spec.md:245:| A7 | category mapping table covers all 10 v1.0 orange action_types | Lint test: every orange action_type in autosend-policy.yaml has a mapping entry |
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:73:| Fbis R1 | `bullhorn_activity_log_write` action_type missing from autosend-policy | `e32344e` |
docs/decisions/2026-05-31-d1-founder-decision.md:15:Per `docs/decisions/autosend-safety-policy.md` §4, orange-tier action_types (customer-facing sends like `xero_reminder_send_customer`, `gmail_outlook_send_to_candidate`, `bullhorn_note_customer_visible`) require **synchronous consultant approval** before the send executes. The agent drafts; the consultant says yes; the transport fires; an audit row records the full chain.
docs/decisions/2026-05-31-d1-founder-decision.md:45:   - `proposeApproval(action_type, target, draft_preview, vault_path, timeout=PT4H) → approval_id`
docs/decisions/autosend-safety-policy.md:45:Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.
docs/decisions/autosend-safety-policy.md:55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:79:| Agent | action_type | Why green |
docs/decisions/autosend-safety-policy.md:90:| Agent | action_type | Sample rate | Why yellow |
docs/decisions/autosend-safety-policy.md:100:| Agent | action_type | Why orange |
docs/decisions/autosend-safety-policy.md:115:| action_type | block_reason | Why red |
docs/decisions/autosend-safety-policy.md:143:#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
docs/decisions/autosend-safety-policy.md:148:  local action_type="$1"
docs/decisions/autosend-safety-policy.md:159:  tier=$(autosend_policy_lookup "$action_type") || {
docs/decisions/autosend-safety-policy.md:160:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
docs/decisions/autosend-safety-policy.md:161:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
docs/decisions/autosend-safety-policy.md:166:  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
docs/decisions/autosend-safety-policy.md:167:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:168:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:175:      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:179:      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:180:      if autosend_should_sample "$action_type" "$tenant_slug"; then
docs/decisions/autosend-safety-policy.md:181:        autosend_spot_check_enqueue "$action_type" "$target" "$payload_hash" "$payload_preview" "$tenant_slug"
docs/decisions/autosend-safety-policy.md:186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
docs/decisions/autosend-safety-policy.md:187:      autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW "$action_type" "$target" "$payload_hash" "$payload_preview"
docs/decisions/autosend-safety-policy.md:189:      autosend_await_approval "$action_type" "$target" "$payload_hash"
docs/decisions/autosend-safety-policy.md:193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:194:      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:200:      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:215:Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
docs/decisions/autosend-safety-policy.md:219:action_types:
docs/decisions/autosend-safety-policy.md:229:Agents cannot invoke action_types not declared in their `tools.yaml`. Renderer validates this at render time per ADR-003 §4 (`ESC_RENDERER_FAILED` reason `bundle-malformed` if a declared action_type isn't in the policy).
docs/decisions/autosend-safety-policy.md:245:  "action_type": "<enum from autosend-policy.yaml>",
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:288:  "action_type": "<enum>",
docs/decisions/autosend-safety-policy.md:304:**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).
docs/decisions/autosend-safety-policy.md:326:  "action_type": "<enum, may be unknown>",
docs/decisions/autosend-safety-policy.md:330:  "lookup_error": "<enum: unknown_action_type | policy_table_corrupt | override_resolution_failed | tenant_not_found | unknown_tier:<value>>",
docs/decisions/autosend-safety-policy.md:341:4. Root cause + fix applied (e.g., add missing `action_type` to policy, repair table corruption, fix override format)
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:358:| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |
docs/decisions/autosend-safety-policy.md:385:--     "action_type": "<enum>",
docs/decisions/autosend-safety-policy.md:402:1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
docs/decisions/autosend-safety-policy.md:404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
docs/decisions/autosend-safety-policy.md:461:1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
docs/decisions/autosend-safety-policy.md:462:2. **Red is absolute.** A red action_type cannot be elevated by tenant override (already at maximum) and cannot be relaxed (red is the floor).
docs/decisions/autosend-safety-policy.md:465:5. **`approval_timeouts`** allow per-action_type customisation within range [PT30M, PT72H]. Defaults to PT4H if unspecified.
docs/decisions/autosend-safety-policy.md:466:6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
docs/decisions/autosend-safety-policy.md:596:| 1 | Formal `action_type` taxonomy enum — should this live in autosend-policy.yaml only, or also in a typed schema for tools.yaml validation? | §3 + §4 | Defer to ADR-005 in Week 1; recommend typed enum in JSON Schema mirrored to YAML |
docs/decisions/autosend-safety-policy.md:600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
docs/decisions/autosend-safety-policy.md:603:| 8 | Spot-check disagreement feedback loop — what's the mechanism for spot-check reviewer disagreement to elevate an action_type's tier? | §2 + §11 | Recommend a `spot_check_disagreement` table; >3 disagreements over 30 days triggers a tier-elevation proposal that goes through Codex ratification. v1.1 builds this. |
docs/decisions/autosend-safety-policy.md:621:- **Q5 (sampling rate defaults for yellow tier):** ACCEPTED for v1.0 with explicit operational-guess flag. Real sampling rates need pilot data; current defaults (1-in-5 to 1-in-20 per `action_type` in §3) are operational guesses calibrated by analogy to typical CRM audit-sampling practice. Refinement happens once first pilot generates 4+ tenant-weeks of yellow-tier action volume.
docs/decisions/autosend-safety-policy.md:624:Remaining open questions (Q1 action_type enum format, Q2 policy file format, Q4 multi-recipient batching, Q7 policy version pinning, Q8 spot-check disagreement feedback, Q9 cross-action coupling, Q10 Telegram SLA instrumentation) deferred for ADR-005 + Week-1+ work.
docs/decisions/autosend-safety-policy.md:634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/runbooks/operational-hygiene-protocol.md:27:- **Citation accuracy B** — Day 5 §4.1 should have been §4.1 + §6.3 (caught in review); Day 6 "30+" action_type claim was actually 29 (caught in review); **15 fabricated "master brief §10.4" references propagated across 5 files** (caught in Day-6-evening citation audit; see §7 below)
docs/runbooks/operational-hygiene-protocol.md:164:| **Decision artefact** | Per tier/trigger/option × support | 30-60 lines (incl. examples + escalation) | autosend-safety-policy.md (4 tiers + 29 action_types + 3 ESC codes + 11 sections ≈ 650 lines) |
docs/runbooks/operational-hygiene-protocol.md:202:3. **Numerical claims:** count. "29 action_types" not "30+". "10 entity_links" not "~10". If counting is hard, write the counting query (grep, wc -l, SQL) and run it.
docs/runbooks/operational-hygiene-protocol.md:217:grep -nE "\b[0-9]+ (entities|fields|action_types|relationships|triggers|tiers|sections|edits|items)" <artefact>
docs/runbooks/operational-hygiene-protocol.md:224:- "30+ action_types" → forbidden. Count: 29. Write "29 action_types".
docs/runbooks/operational-hygiene-protocol.md:288:### §7.3 — Finding: Day-6 "30+ action_types" inflation (caught in founder review)
docs/runbooks/operational-hygiene-protocol.md:290:Day-6 structural summary claimed "30+ action_types across 6 v1.0 agents" in autosend policy §3. Actual count: 29 (Green 6 + Yellow 5 + Orange 10 + Red 8). The artefact itself does not make this claim — only my summary message did.
docs/features/agent-build/00-ORCHESTRATOR.md:41:substrate element (a new `autosend-policy` action_type, a new migration, a new `_shared`
docs/features/agent-build/02-specs/spec-001-janitor.md:19:- **autosend-policy action_types (already registered, yellow):** `bullhorn_candidate_dedupe` (payload.entity_type ∈ {candidate,contractor}), `bullhorn_field_backfill`, `bullhorn_note_attach`, `operator_notify_telegram`, `janitor_run_complete`. Verify each with `grep '^  <name>:' agents/_shared/autosend-policy.yaml` before use.
docs/features/agent-build/02-specs/spec-001-janitor.md:25:- decision_log markers: `janitor_scan`, `field_completeness_audit`, `janitor_tacit_note_harvest`, `day_30_report`, + action rows `bullhorn_candidate_dedupe`/`bullhorn_field_backfill`/`bullhorn_note_attach`/`operator_notify_telegram`/`janitor_run_complete`. These feed the day-30 report aggregation (Step 10) + kill-criterion Trigger 8 evidence.
docs/features/agent-build/02-specs/spec-001-janitor.md:42:| 11 | Operator Telegram notify (green if Gate-B met, yellow if missed) | `operator_notify_telegram` | — | (autosend bridge — drafts-only until W10-13) |
docs/features/agent-build/01-LAUNCH.md:28:0. Freeze substrate on main: confirm each spec's Upstream-contract needs exist (action_types verified registered; confirm no missing migration); build-gate.sh green on main. Verify subagent/worktree mechanics + the Fable model id first (method §8; via claude-code-guide).
docs/features/agent-build/01-LAUNCH.md:38:- Missing substrate (unregistered action_type / missing migration) -> land it on main first, then continue.
docs/runbooks/pii-purge-operational-pattern.md:113:| `action_type` | populated | populated (preserved) |
docs/features/agent-build/02-specs/spec-004-concierge.md:19:- **autosend-policy action_types:** `concierge_email_draft` (yellow), `concierge_approval_routed`, `gmail_outlook_send_to_candidate` (orange), `bullhorn_note_customer_visible` (orange), `bullhorn_activity_log_write` (green), `concierge_send_complete`, `concierge_run_complete` (green). Verify each via grep.
docs/features/agent-build/STATUS.md:6:**Phase:** 1 (PROVE-ONE). Substrate frozen 2026-06-10 (all action_types + schema fields verified; build-gate PASS on main; CV-Library creds re-verified SET). Sourcing Scout pilot in flight.
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:20:- **autosend-policy action_types:** `scout_run_complete` + green `validate_gate_a_fail`. **No write action_types** (read-only agent). Verify via grep.
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:26:- decision_log markers: `brief_ingested`, `auth_refresh_complete`, `bullhorn_query`, `linkedin_query`, `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `candidate_proposed` (ONE row PER candidate, incl. dropped with `included=false`+drop_reason), `scout_report`, `scout_run_complete`.
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:42:| 10 | Output assembly + Gate A (5-15; contact method; rationale ≥50w) → vault report | `scout_report` | `ESC_AGENT_OUTPUT_SHAPE` + `validate_gate_a_fail`, exit 1 | CC Step 13 report assembler |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:43:| 11 | Session close + notify (Brain UI / Telegram / bus per source) | `scout_run_complete` | — | CC Step 14 |
docs/features/agent-build/02-specs/_TEMPLATE.md:22:- autosend-policy action_types this agent owns (must be registered): <list + tier>.
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:12:| 1 | Brief ingestion: `--brief-id` → Postgres `entities` read (`entity_type='brief'`; spec §2 upstream contract); `--description` → deterministic `bin/parse-brief.sh` (role/location/salary/work-mode/seniority/sector) | `brief_ingested` ("input_type; key_dims:N") | `ESC_BRIEF_AMBIGUITY` (<3 dims OR brief_id unresolvable) via `autosend_escalate` + exit 1 (no `validate_gate_a_fail` row — reserved for Gate A per deviation 4; aligned in the Round-2 fix pass) |
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:21:| 10 | Proposal JSON assembly → `validate.sh` Gate A → PASS: §3 Markdown report to `/vault/<tenant>/sourcing-scout-reports/<slug>-<ISO>.md` (0600); FAIL: partial draft (`--partial` banner + degradation notes) to `/tmp/sourcing-scout-<tenant>-<slug>-partial.md`, exit 1 BEFORE `scout_report` | `scout_report` ("N candidates from M sources") | `ESC_AGENT_OUTPUT_SHAPE` + `validate_gate_a_fail` (emitted by validate.sh) |
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:22:| 11 | Session close: Telegram operator notify when configured (green `operator_notify_telegram`), stdout otherwise; run-complete row on BOTH pass and fail paths (fail carries `gate_a:FAIL` + partial path) | `scout_run_complete` (action; green) | — |
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:24:`cleanup.sh`: live TTL purges (Bullhorn 24h; Reed/CV-Library 1h; /tmp partial drafts 24h); token files, vault reports, decision_log untouched; audit row stays `hh_decision_output` because `sourcing_scout_cleanup` is not yet registered in autosend-policy.yaml (spec §2 registers only `scout_run_complete` + `validate_gate_a_fail`).
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:28:G1 count [5,15] · G2 contact method (email regex + opt-in MX via `IFOS_SCOUT_MX_CHECK=1`; E.164; LinkedIn URL; bullhorn_internal) · G3 ≥50 words (recomputed from the body, never trusting the self-reported count) · G4 voice ≥0.75 hard-when-scored / **warn-when-unscored** · G5 DNC defence-in-depth re-check · G6 PII firm-boundary regex (BLOCKING; class precedence over all others) · G7 source floor (no live source returns 0 without a degradation note + at least one contribution or degradation recorded). Failure → mandatory `validate_gate_a_fail` action row + `autosend_escalate` with per-class routing (`ESC_AGENT_OUTPUT_SHAPE` / `ESC_VOICE_DRIFT` / `ESC_PII_LEAKAGE_RISK`), exit 1.
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:35:| `scripts/run-scout-gate-a-test.sh` | **GREEN** (PASS + 9 fail classes) | exit codes + ESC routing for G1 low/high, G2 missing-contact + non-E.164, G3, G4 scored-voice → `ESC_VOICE_DRIFT`, G5 DNC re-check, G6 PII → `ESC_PII_LEAKAGE_RISK` (precedence verified with a simultaneous G1 fail), G7 source-floor; `validate_gate_a_fail` action row asserted for all 9 failures |
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:36:| `scripts/run-scout-degraded-test.sh` | **GREEN** (18/18) | fixture-02 scenario: `ESC_BULLHORN_AUTH` degraded-skip; Reed live-at-refresh then 429 → `ESC_RATE_LIMIT_HIT` + 0 results; `sources_ok:2/4; degraded:bullhorn`; 3 < 5 floor → Gate A FAIL exit 1 + /tmp partial draft with degradation notes + NO vault write + `scout_run_complete gate_a:FAIL`; plus the all-sources-degraded Step-2 `<5 obtainable` floor escalation (`sources_ok:0/4`) |
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:45:4. **Per-source ESC rows use the CC `autosend_escalate` idiom** (phase=`gating_failed`, outcome=ESC code) rather than the skeleton-fixture idea of `validate_gate_a_fail` action rows for Step-2/Step-5 source failures; `validate_gate_a_fail` is reserved for Gate A itself (master brief §8.1 Change 2 reading).
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:52:- **Bullhorn READ-ONLY honoured**: zero Bullhorn writes anywhere in the bundle; no write capabilities in tools.yaml; the only action_types emitted are green (`scout_run_complete`, `validate_gate_a_fail`, `operator_notify_telegram`).
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:71:- Registration of `sourcing_scout_cleanup` (+ the three `*_oauth` names) in autosend-policy.yaml is a FOUNDER-GATED policy decision (per Codex R2 finding 3 — declared as `future_registration` in tools.yaml, not action_type claims); if/when approved, switch cleanup.sh to `hh_decision_action`.
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:85:| A5 | Advisory: cycle.sh Step-1 ESC_BRIEF_AMBIGUITY paths emitted `validate_gate_a_fail` action rows, contradicting deviation 4 (reserved for Gate A) | Code aligned to the `autosend_escalate`-only idiom (the escalation itself writes the `gating_failed` decision_log row, so the audit trail stands); no fixture/test asserted the removed rows; gate re-run GREEN |
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:93:| R2-3 | tools.yaml declared `bullhorn_oauth`/`reed_oauth`/`cvlibrary_oauth`/`sourcing_scout_cleanup` as `action_type:` though none is registered in autosend-policy.yaml | Re-declared as `future_registration:` entries — explicitly NOT action_type claims; registration is a founder-gated policy decision; until then the code paths use hh_decision_output / degraded-skip. Header + cross-reference block + boundary bullet aligned; agent.md reading-discipline note aligned. VERIFIED in code: cycle.sh's only `hh_decision_action` rows are `scout_run_complete` + `operator_notify_telegram` + `validate_gate_a_fail` (all REGISTERED); cleanup.sh emits `hh_decision_output` only — no unregistered action_type row is emitted anywhere |
docs/features/agent-build/02-specs/spec-002-scribe.md:19:- **autosend-policy action_types (registered, yellow):** `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`; + green `validate_gate_a_fail`, `scribe_run_complete`. Verify via grep.
docs/features/agent-build/02-specs/spec-002-scribe.md:38:| 7 | Field validation vs vertical-schema (name + type/range; need ≥3 valid) | `fields_validated` | `ESC_SCHEMA_VIOLATION` + `validate_gate_a_fail`, exit 1 | CC Gate A G1 |

 succeeded in 0ms:
agents/recruitment/sourcing-scout/README.md
agents/recruitment/sourcing-scout/agent.md
agents/recruitment/sourcing-scout/bin/fuzzy-match.sh
agents/recruitment/sourcing-scout/bin/parse-brief.sh
agents/recruitment/sourcing-scout/bin/render-rationale.sh
agents/recruitment/sourcing-scout/bin/render-scout-report.sh
agents/recruitment/sourcing-scout/cleanup.sh
agents/recruitment/sourcing-scout/context.sh
agents/recruitment/sourcing-scout/cycle.sh
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml
agents/recruitment/sourcing-scout/fixtures/02-edge-case-degraded-sources.yaml
agents/recruitment/sourcing-scout/fixtures/99-dnc-bulk-filter.yaml
agents/recruitment/sourcing-scout/tools.yaml
agents/recruitment/sourcing-scout/validate.sh

exec
/bin/zsh -lc 'rg -n "Composio|AgentMail|packages/harness/cortextos|cortextOS.*brain|stock KB|kb-" agents/recruitment/sourcing-scout docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 exited 1 in 0ms:
codex
The action types used by `cycle.sh` and `validate.sh` are registered in the shared YAML, and the obvious boundary searches came back clean for this bundle. I’m doing one last pass over context/voice helper claims before deciding whether the voice-gate mismatch alone warrants rejection.
exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '20,135p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,170p;170,320p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/context.sh | sed -n '1,280p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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
   126	    tier: green
   127	    agent: diagnostic
   128	    reason: "Internal audit row written by cycle.sh Step 1 when firm-name validation fails. Carries ESC_INPUT_VALIDATION_FAIL payload; just the audit-row write, not external send."
   129	    irreversible: false
   130	
   131	  diagnostic_generator_empty:
   132	    tier: green
   133	    agent: diagnostic
   134	    reason: "Internal audit row written by cycle.sh when @ifos/diagnostic-generator produces empty stdout. Carries ESC_AGENT_OUTPUT_SHAPE payload."
   135	    irreversible: false

 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Sourcing Scout agent — context.sh (pre-cycle hydration; W9 build slice LIVE)
     3	#
     4	# Status: LIVE per spec-003 (W9 build slice). v0.4 schema supplement LANDED
     5	#         2026-06-03 (commit a1bbcf6 + LIVE on VPS) — bullhorn_corporation_id
     6	#         is top-level allowlisted. v0.3 supplement (LIVE on VPS) allowlists
     7	#         blocked_recipients; operator_telegram_chat_id is the v0.4 addition.
     8	# Reading order: agent.md §2 (invocation surface) + §4 Step 0 (session start) +
     9	#         §7 (voice + tone constraints) first.
    10	#
    11	# Per ADR-003 v2 agent-bundle pattern: bus invokes context.sh BEFORE cycle.sh
    12	# at session start. context.sh hydrates session-scoped CTX_* env vars that
    13	# cycle.sh + validate.sh read, then emits the mandatory session_start trigger
    14	# row to anchor the session in decision_log.
    15	#
    16	# Invocation contract:
    17	#   bash context.sh
    18	#
    19	# Inputs (env from bus):
    20	#   CTX_AGENT_DIR    — agent's directory (this file's dirname)
    21	#   CTX_TENANT_SLUG  — tenant the run targets
    22	#
    23	# Side effects:
    24	#   - Per-source auth-state resolution (Bullhorn READ-ONLY + Reed + CV-Library;
    25	#     LinkedIn excluded per the v1.0 Proxycurl-shutdown caveat). Reed +
    26	#     CV-Library use long-lived keys (no refresh op); "refresh" = key presence
    27	#     + CLI check-auth where the connector CLI is built. Bullhorn OAuth refresh
    28	#     needs the @ifos/bullhorn CLI surface which does not exist yet — with
    29	#     creds EMPTY today the honest state is 'absent' → cycle.sh Step 2 degraded
    30	#     skip (spec-003 §8; never faked).
    31	#   - Resolve bullhorn_corporation_id via canonical tenant_adapters SELECT
    32	#     (v0.4-allowlisted) with IFOS_FORCE_* fixture fallback.
    33	#   - Load tenant DNC list from tenant_adapters.config.blocked_recipients
    34	#     (v0.3-allowlisted; array<string>) → CTX_DNC_BLOCKED_RECIPIENTS.
    35	#   - Load voice corpus state + tone-rule count for Step 9 rationale honesty
    36	#     (empty corpus → unscored/no_corpus per spec-003 §8).
    37	#   - Load firm-domain whitelist (validate.sh G6 PII regex pass).
    38	#
    39	# Outputs (exported CTX_* vars; cycle.sh + validate.sh consume):
    40	#   CTX_AGENT_NAME                — "sourcing-scout"
    41	#   CTX_BULLHORN_CORPORATION_ID   — per-tenant Bullhorn corp identifier
    42	#   CTX_BULLHORN_TOKEN_STATE      — ok | configured_no_refresh_surface | absent
    43	#   CTX_REED_TOKEN_STATE          — ok | configured_no_cli | absent
    44	#   CTX_CVLIBRARY_TOKEN_STATE     — ok | configured_no_cli | failed | absent
    45	#   CTX_VOICE_CORPUS_ID           — active voice_corpus row id (or "none")
    46	#   CTX_VOICE_CORPUS_STATE        — active | absent
    47	#   CTX_TONE_RULES_COUNT          — number of tone_rule rows loaded
    48	#   CTX_FIRM_DOMAIN_WHITELIST     — comma-separated tenant firm domains (G6 PII)
    49	#   CTX_DNC_BLOCKED_RECIPIENTS    — JSON array string of DNC identifiers
    50	#   CTX_OPERATOR_TELEGRAM_CHAT_ID — Step 11 notification recipient
    51	#   CTX_SOURCES_ACTIVE_COUNT      — declared v1.0 source count (=3; Bullhorn +
    52	#                                   Reed + CV-Library; LinkedIn excluded)
    53	
    54	set -euo pipefail
    55	
    56	# ────────────────────────────────────────────────────────────────────────
    57	# Pre-flight: CTX env + _shared/ helper resolution
    58	# ────────────────────────────────────────────────────────────────────────
    59	
    60	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    61	  printf 'sourcing-scout/context.sh: CTX_AGENT_DIR unset (bus must set this)\n' >&2
    62	  exit 2
    63	fi
    64	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    65	  printf 'sourcing-scout/context.sh: CTX_TENANT_SLUG unset\n' >&2
    66	  exit 2
    67	fi
    68	export CTX_AGENT_NAME="sourcing-scout"
    69	
    70	# 4-candidate _shared/ helper fallback (matches sibling agents post commit d7d52c5).
    71	_SHARED_DIR=""
    72	for _candidate in \
    73	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    74	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    75	  "${CTX_AGENT_DIR}/../../_shared" \
    76	  "${CTX_AGENT_DIR}/../_shared" ; do
    77	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    78	    _SHARED_DIR="${_candidate}"
    79	    break
    80	  fi
    81	done
    82	if [[ -z "${_SHARED_DIR}" ]]; then
    83	  printf 'context.sh: cannot locate _shared/ helpers\n' >&2
    84	  exit 1
    85	fi
    86	# shellcheck source=/dev/null
    87	source "${_SHARED_DIR}/hook-helpers.sh"
    88	# shellcheck source=/dev/null
    89	source "${_SHARED_DIR}/voice-loader.sh" 2>/dev/null || true
    90	
    91	# Connector base + secrets (Path A: values sourced into env, never printed).
    92	_SS_CONN_BASE="${IFOS_REPO_ROOT:+${IFOS_REPO_ROOT}/packages/mcp-connectors}"
    93	if [[ -z "${_SS_CONN_BASE}" || ! -d "${_SS_CONN_BASE}" ]]; then
    94	  _SS_CONN_BASE="${_SHARED_DIR}/../../packages/mcp-connectors"
    95	fi
    96	_SS_SECRETS="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
    97	if [[ -f "${_SS_SECRETS}" ]]; then
    98	  set -a
    99	  # shellcheck source=/dev/null
   100	  source "${_SS_SECRETS}"
   101	  set +a
   102	fi
   103	
   104	# Canonical tenant_adapters config read (RLS-scoped; first row carrying the key).
   105	# Empty string when DB unreachable OR no row carries the key.
   106	_ss_tenant_config() {
   107	  local key="$1"
   108	  if [[ -z "${IFOS_DB_URL:-}" ]] || ! command -v psql >/dev/null 2>&1; then
   109	    return 0
   110	  fi
   111	  psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
   112	    --set=tenant="${CTX_TENANT_SLUG}" --set=key="${key}" <<'SQL' 2>/dev/null | head -1 || true
   113	BEGIN;
   114	SET LOCAL app.current_tenant = :'tenant';
   115	SELECT config->>:'key' FROM tenant_adapters
   116	WHERE tenant_slug = :'tenant' AND config ? :'key'
   117	ORDER BY id LIMIT 1;
   118	COMMIT;
   119	SQL
   120	}
   121	
   122	# ────────────────────────────────────────────────────────────────────────
   123	# Step 1 — Bullhorn corporation_id resolution (v0.4-allowlisted canonical path)
   124	# IFOS_FORCE_BULLHORN_CORPORATION_ID retained for fixture + local-dev use.
   125	# ────────────────────────────────────────────────────────────────────────
   126	
   127	if [[ -n "${IFOS_FORCE_BULLHORN_CORPORATION_ID:-}" ]]; then
   128	  CTX_BULLHORN_CORPORATION_ID="${IFOS_FORCE_BULLHORN_CORPORATION_ID}"
   129	else
   130	  CTX_BULLHORN_CORPORATION_ID="$(_ss_tenant_config bullhorn_corporation_id)"
   131	fi
   132	export CTX_BULLHORN_CORPORATION_ID="${CTX_BULLHORN_CORPORATION_ID:-unset}"
   133	
   134	# ────────────────────────────────────────────────────────────────────────
   135	# Step 2 — Bullhorn auth state (read-only; per agent.md §1 + §6)
   136	# Honest state model (spec-003 §8): creds EMPTY today → 'absent' → cycle.sh
   137	# degraded-skip + ESC_BULLHORN_AUTH. When creds land, the @ifos/bullhorn CLI
   138	# refresh surface is the follow-up — until it exists, creds-present reports
   139	# 'configured_no_refresh_surface' (still live-queryable once the CLI lands).
   140	# ────────────────────────────────────────────────────────────────────────
   141	
   142	if [[ -n "${BULLHORN_CLIENT_ID:-}" && -n "${BULLHORN_CLIENT_SECRET:-}" ]]; then
   143	  if [[ -f "${_SS_CONN_BASE}/bullhorn/dist/cli.js" ]]; then
   144	    if node "${_SS_CONN_BASE}/bullhorn/dist/cli.js" refresh 2>/dev/null \
   145	         | jq -e '.ok == true' >/dev/null 2>&1; then
   146	      CTX_BULLHORN_TOKEN_STATE="ok"
   147	    else
   148	      CTX_BULLHORN_TOKEN_STATE="failed"
   149	    fi
   150	  else
   151	    CTX_BULLHORN_TOKEN_STATE="configured_no_refresh_surface"
   152	  fi
   153	else
   154	  CTX_BULLHORN_TOKEN_STATE="absent"
   155	fi
   156	export CTX_BULLHORN_TOKEN_STATE
   157	
   158	# ────────────────────────────────────────────────────────────────────────
   159	# Step 3 — Reed auth state (long-lived API key; no refresh op)
   160	# Creds EMPTY today (spec-003 §8) → 'absent' → degraded-skip + ESC_REED_AUTH.
   161	# ────────────────────────────────────────────────────────────────────────
   162	
   163	if [[ -n "${REED_API_KEY:-}" ]]; then
   164	  if [[ -f "${_SS_CONN_BASE}/reed/dist/cli.js" ]]; then
   165	    CTX_REED_TOKEN_STATE="ok"
   166	  else
   167	    CTX_REED_TOKEN_STATE="configured_no_cli"
   168	  fi
   169	else
   170	  CTX_REED_TOKEN_STATE="absent"
   171	fi
   172	export CTX_REED_TOKEN_STATE
   173	
   174	# ────────────────────────────────────────────────────────────────────────
   175	# Step 4 — CV-Library auth state (long-lived key; check-auth is network-free)
   176	# Creds SET today (spec-003 §8 — the live source). check-auth via the
   177	# @ifos/cv-library CLI when built; live API calls are the orchestrator's
   178	# post-build smoke, never made here.
   179	# ────────────────────────────────────────────────────────────────────────
   180	
   181	if [[ -n "${CVLIBRARY_API_KEY:-}" || -n "${CVLIBRARY_ACCESS_TOKEN:-}" ]]; then
   182	  if [[ -f "${_SS_CONN_BASE}/cv-library/dist/cli.js" ]]; then
   183	    if node "${_SS_CONN_BASE}/cv-library/dist/cli.js" check-auth 2>/dev/null \
   184	         | jq -e '.ok == true' >/dev/null 2>&1; then
   185	      CTX_CVLIBRARY_TOKEN_STATE="ok"
   186	    else
   187	      CTX_CVLIBRARY_TOKEN_STATE="failed"
   188	    fi
   189	  else
   190	    CTX_CVLIBRARY_TOKEN_STATE="configured_no_cli"
   191	  fi
   192	else
   193	  CTX_CVLIBRARY_TOKEN_STATE="absent"
   194	fi
   195	export CTX_CVLIBRARY_TOKEN_STATE
   196	
   197	# ────────────────────────────────────────────────────────────────────────
   198	# Step 5 — Voice corpus + tone rules (for Step 9 per-candidate rationale)
   199	# Empty voice_corpus → CTX_VOICE_CORPUS_STATE=absent → Step 9 records
   200	# unscored/no_corpus (never a faked score; spec-003 §8).
   201	# ────────────────────────────────────────────────────────────────────────
   202	
   203	CTX_VOICE_CORPUS_ID="none"
   204	CTX_VOICE_CORPUS_STATE="absent"
   205	if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   206	  _ss_vc="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
   207	    --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1 || true
   208	BEGIN;
   209	SET LOCAL app.current_tenant = :'tenant';
   210	SELECT id FROM voice_corpus WHERE tenant_slug = :'tenant' AND is_active = true LIMIT 1;
   211	COMMIT;
   212	SQL
   213	)"
   214	  if [[ -n "${_ss_vc}" ]]; then
   215	    CTX_VOICE_CORPUS_ID="${_ss_vc}"
   216	    CTX_VOICE_CORPUS_STATE="active"
   217	  fi
   218	fi
   219	export CTX_VOICE_CORPUS_ID CTX_VOICE_CORPUS_STATE
   220	
   221	CTX_TONE_RULES_COUNT=0
   222	if command -v jq >/dev/null 2>&1 && declare -F hh_load_tone_rules >/dev/null 2>&1; then
   223	  CTX_TONE_RULES_COUNT="$(hh_load_tone_rules "sourcing_scout" 2>/dev/null \
   224	    | jq -r '.rules | length' 2>/dev/null || echo 0)"
   225	  [[ "${CTX_TONE_RULES_COUNT}" =~ ^[0-9]+$ ]] || CTX_TONE_RULES_COUNT=0
   226	fi
   227	export CTX_TONE_RULES_COUNT
   228	
   229	# ────────────────────────────────────────────────────────────────────────
   230	# Step 6 — DNC list load (tenant_adapters.config.blocked_recipients;
   231	# v0.3-allowlisted; array<string>). Loaded once; reused at Step 8 (cycle.sh
   232	# filter) + G5 (validate.sh defence-in-depth).
   233	# ────────────────────────────────────────────────────────────────────────
   234	
   235	if [[ -n "${IFOS_FORCE_DNC_BLOCKED_RECIPIENTS:-}" ]]; then
   236	  CTX_DNC_BLOCKED_RECIPIENTS="${IFOS_FORCE_DNC_BLOCKED_RECIPIENTS}"
   237	else
   238	  CTX_DNC_BLOCKED_RECIPIENTS="$(_ss_tenant_config blocked_recipients)"
   239	fi
   240	# Guarantee valid JSON array downstream.
   241	if ! printf '%s' "${CTX_DNC_BLOCKED_RECIPIENTS:-}" | jq -e 'type == "array"' >/dev/null 2>&1; then
   242	  CTX_DNC_BLOCKED_RECIPIENTS="[]"
   243	fi
   244	export CTX_DNC_BLOCKED_RECIPIENTS
   245	
   246	# ────────────────────────────────────────────────────────────────────────
   247	# Step 7 — Firm-domain whitelist (validate.sh G6 PII regex pass)
   248	# ────────────────────────────────────────────────────────────────────────
   249	
   250	if [[ -n "${IFOS_FORCE_FIRM_DOMAIN_WHITELIST:-}" ]]; then
   251	  CTX_FIRM_DOMAIN_WHITELIST="${IFOS_FORCE_FIRM_DOMAIN_WHITELIST}"
   252	else
   253	  CTX_FIRM_DOMAIN_WHITELIST="$(_ss_tenant_config firm_domains)"
   254	fi
   255	export CTX_FIRM_DOMAIN_WHITELIST="${CTX_FIRM_DOMAIN_WHITELIST:-${CTX_TENANT_SLUG}.test}"
   256	
   257	# ────────────────────────────────────────────────────────────────────────
   258	# Step 8 — Operator routing (Telegram chat ID for Step 11 notification;
   259	# v0.4-allowlisted operator_telegram_chat_id).
   260	# ────────────────────────────────────────────────────────────────────────
   261	
   262	if [[ -n "${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-}" ]]; then
   263	  CTX_OPERATOR_TELEGRAM_CHAT_ID="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID}"
   264	else
   265	  CTX_OPERATOR_TELEGRAM_CHAT_ID="$(_ss_tenant_config operator_telegram_chat_id)"
   266	fi
   267	export CTX_OPERATOR_TELEGRAM_CHAT_ID="${CTX_OPERATOR_TELEGRAM_CHAT_ID:-unset}"
   268	
   269	# ────────────────────────────────────────────────────────────────────────
   270	# Step 9 — Active source count (v1.0 = 3 per Proxycurl shutdown caveat)
   271	# ────────────────────────────────────────────────────────────────────────
   272	
   273	export CTX_SOURCES_ACTIVE_COUNT="3"   # Bullhorn passive + Reed + CV-Library
   274	                                       # (LinkedIn excluded per agent.md v1.0 caveat)
   275	
   276	# ────────────────────────────────────────────────────────────────────────
   277	# Step 10 — Session-start trigger row (mandatory; anchors session in decision_log)
   278	# ────────────────────────────────────────────────────────────────────────
   279	
   280	hh_decision_trigger "session_start" \

exec
/bin/zsh -lc 'rg -n "hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|voice" agents/recruitment/sourcing-scout agents/_shared/voice-loader.sh' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
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
agents/recruitment/sourcing-scout/fixtures/99-dnc-bulk-filter.yaml:97:    voice_pass: 3
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:9:# recorded unscored/no_corpus at v1.0 (empty tenant voice_corpus; honest
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:21:#   Step 9 produces 13 rationales all ≥50 words (voice: unscored/no_corpus
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:28:# voice scores ≥0.75 (G4 PASS); no DNC matches (G5 PASS); no PII (G6 PASS);
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:106:# Mocked LLM rationale generation (Step 9) — 12 candidates above voice threshold
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:108:  candidates_with_voice_above_threshold: 12
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:109:  candidates_voice_dropped: 0
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:110:  average_voice_score: 0.84
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:133:    voice_state: unscored_no_corpus   # v1.0 honesty; G4 warns, never fails on unscored
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:134:    voice_drift_drops: 0
agents/recruitment/sourcing-scout/bin/render-rationale.sh:8:# (brief context + candidate profile + voice corpus + tone rules prompt) is
agents/recruitment/sourcing-scout/fixtures/02-edge-case-degraded-sources.yaml:88:# Step 9 rationale generation runs on 3 candidates (all pass voice)
agents/recruitment/sourcing-scout/fixtures/02-edge-case-degraded-sources.yaml:90:  candidates_with_voice_above_threshold: 3
agents/recruitment/sourcing-scout/fixtures/02-edge-case-degraded-sources.yaml:91:  candidates_voice_dropped: 0
agents/recruitment/sourcing-scout/fixtures/02-edge-case-degraded-sources.yaml:108:    voice_pass: 3
agents/recruitment/sourcing-scout/bin/render-scout-report.sh:62:    "**Voice score:** \($c.voice_score)\(if $c.voice_reason then " (\($c.voice_reason))" else "" end)\n" +
agents/recruitment/sourcing-scout/cycle.sh:35:#   IFOS_SCOUT_FORCE_VOICE_SCORE — numeric voice score override for the Step 9
agents/recruitment/sourcing-scout/cycle.sh:36:#       voice-drift drop route (no classifier exists yet; corpus-empty runs
agents/recruitment/sourcing-scout/cycle.sh:478:# honesty (spec-003 §8): empty voice_corpus → unscored/no_corpus, never a
agents/recruitment/sourcing-scout/cycle.sh:489:_ss_voice_state="${CTX_VOICE_CORPUS_STATE:-absent}"
agents/recruitment/sourcing-scout/cycle.sh:490:_ss_force_voice="${IFOS_SCOUT_FORCE_VOICE_SCORE:-}"
agents/recruitment/sourcing-scout/cycle.sh:491:_ss_voice_drops=0
agents/recruitment/sourcing-scout/cycle.sh:506:      "source:${_c_sources}; confidence:${_c_conf}; voice_score:n/a; included:false; drop_reason:rank_cutoff_top15"
agents/recruitment/sourcing-scout/cycle.sh:521:  _c_voice="unscored"
agents/recruitment/sourcing-scout/cycle.sh:522:  _c_voice_reason="no_corpus"
agents/recruitment/sourcing-scout/cycle.sh:523:  if [[ -n "${_ss_force_voice}" ]]; then
agents/recruitment/sourcing-scout/cycle.sh:524:    _c_voice="${_ss_force_voice}"
agents/recruitment/sourcing-scout/cycle.sh:525:    _c_voice_reason="forced_test_hook"
agents/recruitment/sourcing-scout/cycle.sh:526:  elif [[ "${_ss_voice_state}" == "active" ]]; then
agents/recruitment/sourcing-scout/cycle.sh:529:    _c_voice_reason="classifier_unavailable"
agents/recruitment/sourcing-scout/cycle.sh:531:  if [[ "${_c_voice}" =~ ^[0-9]+(\.[0-9]+)?$ ]] \
agents/recruitment/sourcing-scout/cycle.sh:532:       && ! awk -v s="${_c_voice}" 'BEGIN{exit !(s>=0.75)}'; then
agents/recruitment/sourcing-scout/cycle.sh:535:    _ss_voice_drops=$((_ss_voice_drops + 1))
agents/recruitment/sourcing-scout/cycle.sh:538:      "candidate=${_c_ref}" "voice_score=${_c_voice}" "retries=3"
agents/recruitment/sourcing-scout/cycle.sh:539:    _ss_exception "Candidate ${_c_name} dropped: rationale voice score ${_c_voice} < 0.75 after 3 retries (ESC_VOICE_DRIFT)"
agents/recruitment/sourcing-scout/cycle.sh:541:      "source:${_c_sources}; confidence:${_c_conf}; voice_score:${_c_voice}; included:false; drop_reason:voice_drift"
agents/recruitment/sourcing-scout/cycle.sh:548:    --arg voice "${_c_voice}" --arg voice_reason "${_c_voice_reason}" '
agents/recruitment/sourcing-scout/cycle.sh:557:      voice_score: (if ($voice | test("^[0-9.]+$")) then ($voice | tonumber) else $voice end),
agents/recruitment/sourcing-scout/cycle.sh:558:      voice_reason: $voice_reason,
agents/recruitment/sourcing-scout/cycle.sh:566:    "source:${_c_sources}; confidence:${_c_conf}; voice_score:${_c_voice}; included:true"
agents/recruitment/sourcing-scout/cycle.sh:575:    "source:$(printf '%s' "${_d}" | jq -r '(.sources // [.source]) | join(",")'); confidence:$(printf '%s' "${_d}" | jq -r '.confidence // 0'); voice_score:n/a; included:false; drop_reason:dnc_filter"
agents/recruitment/sourcing-scout/README.md:16:| `context.sh` | LIVE — canonical tenant_adapters SELECTs + per-source auth state + voice/DNC/firm-domain hydration |
agents/recruitment/sourcing-scout/README.md:37:- Voice: empty `voice_corpus` → rationales recorded `unscored/no_corpus`;
agents/recruitment/sourcing-scout/validate.sh:30:#               "voice_score": <0.0-1.0> | "unscored",
agents/recruitment/sourcing-scout/validate.sh:55:#   G4 — Every candidate rationale voice classifier ≥0.75
agents/recruitment/sourcing-scout/validate.sh:243:# G4 — Every rationale voice classifier ≥0.75
agents/recruitment/sourcing-scout/validate.sh:245:# voice_corpus → a score cannot be honestly computed; spec-003 §5
agents/recruitment/sourcing-scout/validate.sh:251:while IFS=$'\t' read -r _c_id _c_voice; do
agents/recruitment/sourcing-scout/validate.sh:253:  if [[ "${_c_voice}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
agents/recruitment/sourcing-scout/validate.sh:254:    if ! awk -v s="${_c_voice}" -v t="${VOICE_SCORE_THRESHOLD}" 'BEGIN{exit !(s>=t)}'; then
agents/recruitment/sourcing-scout/validate.sh:256:      _fail "G4: ${_c_id} voice_score ${_c_voice} < ${VOICE_SCORE_THRESHOLD}"
agents/recruitment/sourcing-scout/validate.sh:261:done < <(jq -r '.candidates[] | [.candidate_id, (.voice_score | tostring)] | @tsv' "${PROPOSAL}")
agents/recruitment/sourcing-scout/validate.sh:265:  _warn "G4: ${_g4_unscored} rationale(s) unscored (no tenant voice_corpus) — threshold not enforceable (documented enhancement)"
agents/recruitment/sourcing-scout/validate.sh:267:  _ok "G4: every rationale voice classifier ≥${VOICE_SCORE_THRESHOLD}"
agents/recruitment/sourcing-scout/context.sh:9:#         §7 (voice + tone constraints) first.
agents/recruitment/sourcing-scout/context.sh:35:#   - Load voice corpus state + tone-rule count for Step 9 rationale honesty
agents/recruitment/sourcing-scout/context.sh:45:#   CTX_VOICE_CORPUS_ID           — active voice_corpus row id (or "none")
agents/recruitment/sourcing-scout/context.sh:89:source "${_SHARED_DIR}/voice-loader.sh" 2>/dev/null || true
agents/recruitment/sourcing-scout/context.sh:199:# Empty voice_corpus → CTX_VOICE_CORPUS_STATE=absent → Step 9 records
agents/recruitment/sourcing-scout/context.sh:210:SELECT id FROM voice_corpus WHERE tenant_slug = :'tenant' AND is_active = true LIMIT 1;
agents/recruitment/sourcing-scout/context.sh:222:if command -v jq >/dev/null 2>&1 && declare -F hh_load_tone_rules >/dev/null 2>&1; then
agents/recruitment/sourcing-scout/context.sh:223:  CTX_TONE_RULES_COUNT="$(hh_load_tone_rules "sourcing_scout" 2>/dev/null \
agents/recruitment/sourcing-scout/context.sh:281:  "agent:sourcing-scout; tenant:${CTX_TENANT_SLUG}; corp:${CTX_BULLHORN_CORPORATION_ID}; sources_active:${CTX_SOURCES_ACTIVE_COUNT}; voice_corpus:${CTX_VOICE_CORPUS_STATE}"
agents/recruitment/sourcing-scout/context.sh:284:printf '[sourcing-scout context.sh] tenant=%s corp=%s sources_active=%s bullhorn_token=%s reed=%s cvlibrary=%s voice_corpus=%s tone_rules=%s firm_domains=%s dnc_entries=%s\n' \
agents/recruitment/sourcing-scout/tools.yaml:126:  # Voice classifier (Step 9 per-candidate rationale voice scoring)
agents/recruitment/sourcing-scout/tools.yaml:127:  # Reference: agent.md §7; _shared/voice-loader.sh + hh_load_tone_rules.
agents/recruitment/sourcing-scout/tools.yaml:130:  - id: voice_classifier
agents/recruitment/sourcing-scout/tools.yaml:131:    package: "@ifos/voice-classifier"   # W4-5 polish microservice (per agent.md §8 build deps)
agents/recruitment/sourcing-scout/tools.yaml:132:    purpose: "Score per-candidate rationale against tenant voice corpus (≥0.75 required by Gate A G4); ESC_VOICE_DRIFT below threshold after 3 retries; per-run only (aggregate _TENANT is canary cron territory per agent.md §7)"
agents/recruitment/sourcing-scout/tools.yaml:189:  - condition: "Per-candidate rationale voice classifier <0.75 after 3 retries (cycle.sh Step 9)"
agents/recruitment/sourcing-scout/agent.md:108:Voice-classified content: only the per-candidate match rationale (Step 9). Voice classifier ≥0.75 against tenant style — **hard-enforced WHEN a tenant voice corpus exists**. When the tenant `voice_corpus` is empty, a score cannot be honestly computed: the rationale is recorded as `unscored`/`no_corpus` (never a faked score) and `validate.sh` G4 warns-and-passes. **Warn-when-unscored is the accepted v1.0 gate behaviour** (spec-003 §5 "hard (warn-when-unscored)" + the Cash Conductor honesty precedent); the gate becomes hard-scoring automatically once a corpus is loaded. A rationale with a computed score that fails after 3 retries → ESC_VOICE_DRIFT → candidate dropped from list + flagged in exception list.
agents/recruitment/sourcing-scout/agent.md:118:   → context.sh hydrates: tenant config + multi-source auth + voice corpus
agents/recruitment/sourcing-scout/agent.md:229:   → prompt = (brief context + candidate profile + voice corpus + tone rules)
agents/recruitment/sourcing-scout/agent.md:230:   → voice classifier scores rationale (≥0.75 — hard-enforced when a tenant
agents/recruitment/sourcing-scout/agent.md:231:     voice corpus exists; empty voice_corpus → voice_score recorded as
agents/recruitment/sourcing-scout/agent.md:237:     "source:<bullhorn|linkedin|reed|cvlibrary>; confidence:<N>; voice_score:<N>; included:<bool>") — emitted PER CANDIDATE per §3 contract (one row per candidate proposed; dropped candidates also get a row with included=false + drop_reason)
agents/recruitment/sourcing-scout/agent.md:275:- All rationales pass voice classifier ≥0.75 — **hard-enforced WHEN a tenant voice corpus exists**. Empty `voice_corpus` → rationales carry `unscored`/`no_corpus` (a score is never faked) and G4 warns-and-passes: **warn-when-unscored is the accepted v1.0 gate behaviour** (spec-003 §5 "hard (warn-when-unscored)" + the Cash Conductor honesty precedent); G4 becomes hard-scoring once a corpus is loaded
agents/recruitment/sourcing-scout/agent.md:281:- Output-shape failures (count not in 5-15, contact-method missing, rationale <50 words, voice classifier miss, all-source-failure-without-degradation) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)
agents/recruitment/sourcing-scout/agent.md:310:| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:320:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/sourcing-scout/agent.md:327:Step 9 (per-candidate rationale generation) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/sourcing-scout/agent.md:329:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:334:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:335:- **Voice-drift detection (classifier-only):** per `vertical-schema.v0.3-supplement.yaml` lines 597-606 (§2a access-list amendment) + 728-737 (access matrix), Sourcing Scout has `recent_edit` access of **W** (writes its rationale drafts) but **not R**, so it does NOT read consultant edit history via `hh_load_recent_edits`. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries; scores are only computed when the tenant voice corpus is non-empty — empty corpus → `unscored`/`no_corpus` recorded and `validate.sh` G4 warns-and-passes (the accepted v1.0 warn-when-unscored gate behaviour per spec-003 §5; hard-scoring resumes once a corpus is loaded). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. The cron — not Sourcing Scout — reads edit history for analytics + canary threshold tuning.
agents/recruitment/sourcing-scout/agent.md:337:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/sourcing-scout/agent.md:366:**Post-W9-build note:** the four sibling-bundle deliverables (validate.sh, context.sh, cycle.sh, fixtures) WERE the W9 build slice and are delivered on this branch; the W9 build proceeded against deterministic fixtures per spec-003 §8 honest scope. The remaining ⏸ rows are FOUNDER/TENANT-ADMIN actions (commercial signups, creds, DNC population, voice corpus, ratifications) — they gate the first LIVE run and the §10 lifecycle transitions (Proposed → Accepted → In Force per the rewritten §10), not the fixture-backed build.

exec
/bin/zsh -lc 'rg -n "hh_load_voice_samples|CTX_VOICE|voice_corpus" agents/recruitment/sourcing-scout/context.sh agents/recruitment/sourcing-scout/cycle.sh agents/recruitment/sourcing-scout/validate.sh agents/recruitment/sourcing-scout/tools.yaml' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
agents/recruitment/sourcing-scout/validate.sh:245:# voice_corpus → a score cannot be honestly computed; spec-003 §5
agents/recruitment/sourcing-scout/validate.sh:265:  _warn "G4: ${_g4_unscored} rationale(s) unscored (no tenant voice_corpus) — threshold not enforceable (documented enhancement)"
agents/recruitment/sourcing-scout/cycle.sh:478:# honesty (spec-003 §8): empty voice_corpus → unscored/no_corpus, never a
agents/recruitment/sourcing-scout/cycle.sh:489:_ss_voice_state="${CTX_VOICE_CORPUS_STATE:-absent}"
agents/recruitment/sourcing-scout/context.sh:45:#   CTX_VOICE_CORPUS_ID           — active voice_corpus row id (or "none")
agents/recruitment/sourcing-scout/context.sh:46:#   CTX_VOICE_CORPUS_STATE        — active | absent
agents/recruitment/sourcing-scout/context.sh:199:# Empty voice_corpus → CTX_VOICE_CORPUS_STATE=absent → Step 9 records
agents/recruitment/sourcing-scout/context.sh:203:CTX_VOICE_CORPUS_ID="none"
agents/recruitment/sourcing-scout/context.sh:204:CTX_VOICE_CORPUS_STATE="absent"
agents/recruitment/sourcing-scout/context.sh:210:SELECT id FROM voice_corpus WHERE tenant_slug = :'tenant' AND is_active = true LIMIT 1;
agents/recruitment/sourcing-scout/context.sh:215:    CTX_VOICE_CORPUS_ID="${_ss_vc}"
agents/recruitment/sourcing-scout/context.sh:216:    CTX_VOICE_CORPUS_STATE="active"
agents/recruitment/sourcing-scout/context.sh:219:export CTX_VOICE_CORPUS_ID CTX_VOICE_CORPUS_STATE
agents/recruitment/sourcing-scout/context.sh:281:  "agent:sourcing-scout; tenant:${CTX_TENANT_SLUG}; corp:${CTX_BULLHORN_CORPORATION_ID}; sources_active:${CTX_SOURCES_ACTIVE_COUNT}; voice_corpus:${CTX_VOICE_CORPUS_STATE}"
agents/recruitment/sourcing-scout/context.sh:284:printf '[sourcing-scout context.sh] tenant=%s corp=%s sources_active=%s bullhorn_token=%s reed=%s cvlibrary=%s voice_corpus=%s tone_rules=%s firm_domains=%s dnc_entries=%s\n' \
agents/recruitment/sourcing-scout/context.sh:287:  "${CTX_VOICE_CORPUS_STATE}" "${CTX_TONE_RULES_COUNT}" "${CTX_FIRM_DOMAIN_WHITELIST}" \

exec
/bin/zsh -lc 'test -d packages/mcp-connectors/voice-classifier || test -d packages/voice-classifier || rg -n "@ifos/voice-classifier|voice_classifier" packages agents docs | head -80' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
agents/_shared/escalation-codes.md:122:- **Trigger:** Voice classifier score below `common-voice.json.voice_classifier_threshold` (default 0.75) after 3 retries per Ultraplan §5.3 retry budget
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:47:#   The 6 voice_classifier_score / voice_drift_at_close fields added to existing
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:289:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:297:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:301:      notes: Same as candidate.voice_classifier_score, scoped to contractor sub-case.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:304:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:312:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:320:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.yaml:42:# `source: IFOS-derived` means computed/written by IFOS code (e.g., voice_classifier_score).
docs/verticals/recruitment/vertical-schema.yaml:142:      voice_classifier_score:
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:32:-- §3 — Optional: purge voice_classifier_score / voice_drift_at_close keys
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:39:-- SET data = data - 'voice_classifier_score' - 'voice_drift_at_close'
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:41:--   AND (data ? 'voice_classifier_score' OR data ? 'voice_drift_at_close');
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:220:  IF d ? 'voice_classifier_score' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:221:    IF jsonb_typeof(d->'voice_classifier_score') NOT IN ('number', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:222:      RAISE EXCEPTION 'voice_classifier_score must be number or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:224:    IF d->'voice_classifier_score' != 'null'::jsonb THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:225:      IF (d->>'voice_classifier_score')::numeric < 0.0
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:226:         OR (d->>'voice_classifier_score')::numeric > 1.0 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:227:        RAISE EXCEPTION 'voice_classifier_score out of [0.0, 1.0] range: %', d->>'voice_classifier_score';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:224:  score_keys TEXT[] := ARRAY['voice_classifier_score', 'voice_drift_at_close'];
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:86:    - "voice_classifier_score"
agents/recruitment/diagnostic/fixtures/01-primary.yaml:84:  voice_classifier_score_min: 0.78
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:72:  voice_classifier_score_min: 0.75
packages/agents-runtime/_shared/common-voice.json:28:    "voice_classifier_threshold": {
packages/agents-runtime/_shared/common-voice.json:49:  "required": ["voice_corpus_path", "voice_classifier_threshold"],
agents/recruitment/diagnostic/tools.yaml:117:  - name: voice_classifier
agents/recruitment/diagnostic/tools.yaml:184:  - voice_classifier_microservice  # ~2 days at W3 start (OR LLM fallback)
agents/recruitment/scribe/tools.yaml:162:  - id: voice_classifier
agents/recruitment/scribe/tools.yaml:163:    package: "@ifos/voice-classifier"   # W4-5 polish microservice (per agent.md §8 build deps)
agents/recruitment/scribe/tools.yaml:167:    # NOTE: @ifos/voice-classifier microservice is W4-5 polish work per
agents/recruitment/concierge/tools.yaml:151:  - id: voice_classifier
agents/recruitment/concierge/tools.yaml:152:    package: "@ifos/voice-classifier"
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:73:mocked_voice_classifier:
agents/recruitment/concierge/fixtures/01-primary.yaml:65:mocked_voice_classifier:
docs/architecture/agent-bundle-renderer-design.md:215:  - voice_classifier_score >= 0.75
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:75:mocked_voice_classifier:
agents/recruitment/sourcing-scout/tools.yaml:130:  - id: voice_classifier
agents/recruitment/sourcing-scout/tools.yaml:131:    package: "@ifos/voice-classifier"   # W4-5 polish microservice (per agent.md §8 build deps)
agents/recruitment/concierge/cycle.sh:25:#   @ifos/voice-classifier       — voice scoring per position threshold
docs/decisions/2026-05-18-codex-ratification-manifest.md:187:| 18 | vertical-schema.yaml v0.1 | REJECTED (3 issues) | Issue 1 (voice_classifier_score CHECK) **incorporated** with v0.2 trigger reference. Issue 2 (empty access arrays) **incorporated**. Issue 3 (versioning count) **incorporated**. Plus pre-existing YAML parse errors fixed. |
docs/operations/decision-log.md:759:- vertical-schema v0.1: voice_classifier_score trigger reference to v0.2 migration §7
docs/operations/decision-log.md:1226:1. **Phase 6 — Sourcing Scout bundle** (Day 33 in plan-doc terms; landed Day 34 in marathon): 6 atomic commits `4e62d06` → `acb6d09`. 11-step cycle.sh with LinkedIn NO-OP at Step 4 per Proxycurl shutdown caveat; validate.sh G1-G7; multi-source context.sh + dual cache cleanup.sh; tools.yaml with 12 capabilities (4 Bullhorn READ + 2 Reed scaffold-pending + 2 CV-Library scaffold-pending + voice_classifier + telegram_notify + sourcing_scout_cleanup); 3 fixtures (01-primary happy / 02-edge-degraded-sources / 99-dnc-bulk-filter); agent.md Reading-discipline note with vendor + package deltas documented.
docs/operations/codex-round-2-handoff.md:84:| 13 | `docs/verticals/recruitment/vertical-schema.yaml` | voice_classifier_score CHECK + empty access + versioning count | RATIFY (all three fixed) |

exec
/bin/zsh -lc 'rg -n "action_type:|hh_decision_action" agents/recruitment/sourcing-scout/*.sh agents/recruitment/sourcing-scout/tools.yaml' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
agents/recruitment/sourcing-scout/cleanup.sh:118:# hh_decision_action before registration would fail policy lookup → a
agents/recruitment/sourcing-scout/cycle.sh:646:  hh_decision_action "scout_run_complete" "brief:${BRIEF_SLUG}" \
agents/recruitment/sourcing-scout/cycle.sh:677:    hh_decision_action "operator_notify_telegram" "chat:${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
agents/recruitment/sourcing-scout/cycle.sh:687:hh_decision_action "scout_run_complete" "brief:${BRIEF_SLUG}" "${_ss_run_hash}" \
agents/recruitment/sourcing-scout/tools.yaml:144:    action_type: operator_notify_telegram  # green tier; REGISTERED in autosend-policy.yaml
agents/recruitment/sourcing-scout/tools.yaml:155:    future_registration: sourcing_scout_cleanup  # NOT a registered autosend-policy action_type yet; registration is a founder-gated policy decision; until then cleanup.sh emits hh_decision_output only (verified: no hh_decision_action call in cleanup.sh)
agents/recruitment/sourcing-scout/validate.sh:10:# hh_decision_action("validate_gate_a_fail", ...) audit row carrying the
agents/recruitment/sourcing-scout/validate.sh:371:  hh_decision_action "validate_gate_a_fail" "brief:${BRIEF_ID}" "${_ss_phash}" \

codex
REJECTED

1. Gate A voice enforcement is weaker than the contract. `agent.md` lines 108, 230-235, and 275 say voice score ≥0.75 is hard-enforced when a tenant voice corpus exists, but `cycle.sh` lines 526-530 records `classifier_unavailable` as `unscored` even when `CTX_VOICE_CORPUS_STATE=active`, and `validate.sh` lines 253-265 only warns on any non-numeric voice score. Fix by making unscored voice a Gate A failure when a corpus exists, or explicitly downgrade the contract and lifecycle status until the classifier exists.

2. The claimed voice-corpus integration is not implemented. `agent.md` lines 327-335 says Sourcing Scout uses `hh_load_voice_samples` for top-5 tenant voice-corpus chunks, but `context.sh` lines 221-224 only calls `hh_load_tone_rules`, and the bundle has no `hh_load_voice_samples` call in `context.sh` or `cycle.sh`. Fix by loading voice samples into context and using them in Step 9 rationale generation, or remove the claim and mark the voice-corpus path as pending.
tokens used
130,939
REJECTED

1. Gate A voice enforcement is weaker than the contract. `agent.md` lines 108, 230-235, and 275 say voice score ≥0.75 is hard-enforced when a tenant voice corpus exists, but `cycle.sh` lines 526-530 records `classifier_unavailable` as `unscored` even when `CTX_VOICE_CORPUS_STATE=active`, and `validate.sh` lines 253-265 only warns on any non-numeric voice score. Fix by making unscored voice a Gate A failure when a corpus exists, or explicitly downgrade the contract and lifecycle status until the classifier exists.

2. The claimed voice-corpus integration is not implemented. `agent.md` lines 327-335 says Sourcing Scout uses `hh_load_voice_samples` for top-5 tenant voice-corpus chunks, but `context.sh` lines 221-224 only calls `hh_load_tone_rules`, and the bundle has no `hh_load_voice_samples` call in `context.sh` or `cycle.sh`. Fix by loading voice samples into context and using them in Step 9 rationale generation, or remove the claim and mark the voice-corpus path as pending.
