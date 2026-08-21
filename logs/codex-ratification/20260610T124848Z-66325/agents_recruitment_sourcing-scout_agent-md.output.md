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
session id: 019eb194-0c0a-7f60-b613-8fe14f37cf68
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
**Reading-discipline note (updated 2026-06-10 at W9 build; originally added 2026-06-03 per CC + Concierge + Janitor + Scribe precedent):** this `agent.md` is the **CONTRACT** that the W9 build slice implemented against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml` + `README.md`) + 3 fixtures are **LIVE** — the W9 build slice (spec-003, this branch) replaced every `TODO(W9)` marker with live implementation; three deterministic DB-backed fixture suites (`scripts/run-scout-{dedupe,gate-a,degraded}-test.sh`) are green under build-gate. **Per-component build state, honestly stated:** `@ifos/bullhorn` — implemented connector package (`packages/mcp-connectors/bullhorn`); the Sourcing-Scout OAuth CLI bridge is not built and creds are EMPTY → cycle.sh Step 2 degraded-skip. `@ifos/reed` — implemented connector package (`packages/mcp-connectors/reed`, v0.1.0, tests green); creds EMPTY → degraded-skip until founder signup. `@ifos/cv-library` — implemented connector package + built `dist/cli.js` bridge (`packages/mcp-connectors/cv-library`, v0.1.0); the designated v1.0 live source, but creds EMPTY at last names-only verification → live smoke founder-gated. None of the three is production-proven: no live API call has been made by this bundle; all coverage is fixture-driven (`IFOS_SCOUT_FIXTURE_*`). **VENDOR NOTE:** the v1.0 contract is THREE active sources (Bullhorn + Reed + CV-Library); LinkedIn is structurally present as an explicit NO-OP only — cycle.sh Step 4 emits `linkedin_query` (`results:0; no_op`) per the Janitor Step 7 NO-OP pattern; vendor selection deferred to v1.1+ per the caveat at lines 6-8. **Live audit-marker set emitted by cycle.sh:** `session_start`, `brief_ingested`, `auth_refresh_complete`, `bullhorn_query`, `linkedin_query` (no-op), `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `candidate_proposed` (one row PER candidate), `scout_report`, `scout_run_complete`, plus `validate_gate_a_fail` (Gate A failure only) and `operator_notify_telegram` (when configured). Pure read+report agent — no yellow/orange/red action_types; the only cleanup action_type is `sourcing_scout_cleanup` (green; still QUEUED for autosend-policy registration — `cleanup.sh` emits `hh_decision_output` until it lands). `context.sh` uses the canonical `tenant_adapters` SELECT path (with `IFOS_FORCE_*` fixture fallbacks retained for tests) — `bullhorn_corporation_id` v0.4-allowlisted (LIVE on VPS commit `a1bbcf6`) + `blocked_recipients` v0.3-allowlisted (LIVE on VPS). §10 lifecycle status remains **Proposed** pending Codex re-ratification of the built bundle + founder approvals — the status flip is founder-gated.

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
- **Voice-drift detection (classifier-only):** per `vertical-schema.v0.3-supplement.yaml` lines 597-606 (§2a access-list amendment) + 728-737 (access matrix), Sourcing Scout has `recent_edit` access of **W** (writes its rationale drafts) but **not R**, so it does NOT read consultant edit history via `hh_load_recent_edits`. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. The cron — not Sourcing Scout — reads edit history for analytics + canary threshold tuning.

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

**Post-W9-build note:** the four sibling-bundle deliverables (validate.sh, context.sh, cycle.sh, fixtures) WERE the W9 build slice and are delivered on this branch; the W9 build proceeded against deterministic fixtures per spec-003 §8 honest scope. The remaining ⏸ rows are FOUNDER/TENANT-ADMIN actions (commercial signups, creds, DNC population, voice corpus, ratifications) — they gate the first LIVE run and the §10 lifecycle transitions (Ratified-as-Scaffold → Accepted), not the fixture-backed build.

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
I’ll verify the cited source files and the sibling bundle shape before deciding. The load-bearing checks here are citation accuracy, status honesty, Gate A alignment, and whether the built-bundle claims match the workspace.
exec
/bin/zsh -lc 'find agents/recruitment/sourcing-scout -maxdepth 2 -type f | sort' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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
/bin/zsh -lc "pwd && rg --files | rg '("'^agents/recruitment/sourcing-scout/|agents/_shared/escalation-codes.md|voice-loader.sh|hook-helpers.sh|autosend-safety-policy.yaml|vertical-schema|ULTRAPLAN|master|v1.0-kill|migrations/v0.2-to-v0.3.sql|bullhorn-integration-path.md|ADR-002|ADR-003|ADR-004)'"'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
/Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
logs/codex-ratification/round-3-remediation/docs_decisions_bullhorn-integration-path-md.output.md
docs/specs/ULTRAPLAN.md
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/bullhorn-integration-path.md
logs/codex-ratification/round-2-autonomous/docs_decisions_v1-0-kill-criterion-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_bullhorn-integration-path-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_ADR-002-brain-system-as-parallel-not-shadow-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_ADR-003-agent-bundle-renderer-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-v0-2-supplement-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
agents/_shared/tests/test-voice-loader.sh
agents/_shared/tests/test-hook-helpers.sh
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
legacy/v1/docs/phase-2-agent-suite/_shared/hook-helpers.sh

codex
The bundle files and three fixtures are present. I’m checking the specific citation anchors now, especially the master brief and ULTRAPLAN lines because this skill treats fabricated or drifted references as blocking.
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '540,560p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '75,105p' && nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '590,610p' && nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '720,742p' && nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '820,842p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
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

exec
/bin/zsh -lc "rg -n \"W9|Sourcing Scout|Night Sourcer|§8\\.2|8\\.2|599\" docs -g '*.md'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:37:| 14 | **Proxycurl shutdown (LinkedIn lawsuit Jan 2025) breaks the Sourcing Scout v1.0 LinkedIn deep-data path** — original v1.0 Sourcing Scout listed 4 sources (Bullhorn + LinkedIn/Proxycurl + Reed + CV-Library). Proxycurl shut down following LinkedIn's January 2025 lawsuit against Nubela (~50% of revenue was LinkedIn scraping; see nubela.co/blog/goodbye-proxycurl/). Successor product NinjaPear (same team) does NOT carry LinkedIn data. No legally-clear LinkedIn-scraping vendor identified as of 2026-06-02. | Materialised 2026-06-02 (vendor gone) | Low → Medium (depends on whether Gate B ≥6 of 10 advance holds without LinkedIn data; unknown until pilot data lands) | Sourcing Scout Gate B underperforms (<6 of 10 advance per ULTRAPLAN A5 line 553) at first-pilot deployment AND analysis attributes gap to missing LinkedIn deep-data. | **v1.0 disposition** (per founder 2026-06-02 + `agents/recruitment/sourcing-scout/agent.md` v1.0 caveat at commit `622a2e7`): defer LinkedIn deep-data to v1.1+; v1.0 Sourcing Scout operates against 3 active sources (Bullhorn passive-match + Reed + CV-Library). v1.1+ vendor selection at W8-9 build-slice decision; candidate vendors named: Lix, Phantombuster, Apify (LinkedIn-aware contracts), or LinkedIn Sales Navigator enterprise API (much higher cost). §4 Step 4 (LinkedIn search) is a NO-OP in v1.0; §3 output template shows LinkedIn row as "deferred to v1.1+; vendor pending". | **Mitigated by deferral; v1.1+ vendor decision queued for W8-9 build slice.** |
docs/RISK-REGISTER.md:62:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:70:- 2026-06-03 (W5 Day 34) — **W5 CLOSED.** All 5 v1.0 agent bundles (CC + Concierge + Janitor + Scribe + Sourcing Scout) at SKELETON tier (6 files + 3 fixtures each); 3 new MCP scaffolds (@ifos/bullhorn + @ifos/workos + @ifos/granola); v0.4 schema supplement LIVE on production VPS (peer-auth migration apply 2026-06-03; 6/6 trigger acceptance tests passed). No new risks materialised from W5. **Risk #3 update:** founder confirmed Jack lane "on track" 2026-06-03; Trigger 1 fires today (calendar gate), founder closes LOI directly — Risk #3 status unchanged at HIGH/MATERIALISED pending actual signature. **Pre-existing test flake surfaced (NOT a new risk):** `@ifos/diagnostic-generator` `tests/generate.test.ts` § "composes a §12 conversation opener that anchors to a real signal" failing since 2026-06-01 commit `2688b6a` — LLM non-determinism (test fixture "Test Anchor Firm" triggers legitimate disclaimer pattern from the LLM; test regex `/Hi.*?Test Anchor Firm|Hi —/` doesn't match). Doesn't affect production behaviour (production uses real firm names with real Companies House data). Three fix paths queued for a future session (relax regex / mock LLM / use real firm name); deferred per Karpathy surgical-changes discipline + /goal STOP rule (out of W5 marathon scope). **W6+ external dependencies:** Bullhorn dev-support reply (~by 2026-06-09); Reed + CV-Library + Xero + QB + TrueLayer commercial signups per `docs/operations/founder-api-signups-2026-06-03.md`; Granola browser OAuth dance (requires Claude Code restart); WorkOS staging key; Cluster F-tris Codex ratification (manifest entry added). vitest at W5 close: 259/260 (99.6%) across 11 packages.
docs/architecture/cortexos-primitive-status.md:27:| 6 | Overnight autoresearch (theta wave) | **shipped and tested** | None in v1.0; v1.1 Night Sourcer |
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:64:- v1.1: A7 Inbound Triage, A10 Competitor Interception, A11 Night Sourcer (with primitive 6), A12 T5 Supply Chain Auditor, A13 T3 Compliance Watchtower all require it.
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:182:1. **No `chokidar` watcher in the bus.** The bus is poll-based, not push-based. `grep -rn chokidar src/` returns zero hits; `chokidar@^5.0.0` in `package.json:47` is used only by `dashboard/src/lib/watcher.ts:5` for the dashboard UI's file change feed, not for inter-agent message delivery. Master brief §2.4 row 3's "chokidar watcher in daemon" is incorrect against the verified SHA. The actual dispatcher is `FastChecker` polling at `pollInterval` (default 1000ms, configurable). Operational impact: message-delivery latency is bounded by the poll interval, not zero-latency event-driven; relevant for the Brief Decoder → Sourcing Scout → Concierge "four-agent pipelines complete in seconds" claim (Ultraplan §3.2). With 1s polling per hop and 3 hops, end-to-end is ≥3s, not sub-second.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:324:- Master brief §2.4 row 5: every Tier-1 agent's escalation path. Triage, Concierge, Cash Conductor, Pulse, Watchtower, Brief Decoder, Competitor Interception, Night Sourcer, T5, Timesheet Ranger — they all escalate via Telegram and approve via Telegram inline buttons.
docs/architecture/cortexos-primitive-status.md:370:Full experiment lifecycle code, dedicated sprint-3 test file, fully-documented 8-phase theta-wave skill shipped in the `analyst` template. Approval-gate integration ties it back into primitive 4. Not on the v1.0 critical path — Ultraplan §3.1 row 6 already defers it to v1.1 Night Sourcer.
docs/architecture/cortexos-primitive-status.md:388:- Master brief §2.4 row 6: Night Sourcer + Spec Pitcher (Product Spec R4 + R11).
docs/architecture/cortexos-primitive-status.md:389:- v1.0: **No agent depends on this.** Ultraplan §3.1 row 6: "This is for the Night Sourcer in v1.1, not v1.0. Defer the question."
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/_supplementary/PRD-autonomous-agent.md:1143:  "overall_score": 8.2,
docs/specs/ULTRAPLAN.md:63:| 6 | **Overnight autoresearch** | Long-session capability documented; rate-limit handling tested | This is for the Night Sourcer in v1.1, not v1.0. Defer the question. |
docs/specs/ULTRAPLAN.md:72:- **The file bus.** Inter-agent handoff via shared filesystem directories. No queue, no API, no serialisation tax. Brief Decoder writes a parsed-brief file; Sourcing Scout's `FastChecker` polls it up at the configured cadence (default 1000ms `pollInterval`, configurable per agent); result lands in a sub-directory the Concierge is polling. Four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound.
docs/specs/ULTRAPLAN.md:420:| Night Sourcer | ≥ 6 of 10 candidates per brief advance past first consultant review | Decision-log + ATS state query |
docs/specs/ULTRAPLAN.md:543:#### A5. Sourcing Scout (daytime form) — request-response sourcing
docs/specs/ULTRAPLAN.md:548:- **CortexOS primitives required:** None for the daytime form (Night Sourcer in v1.1 will use #6)
docs/specs/ULTRAPLAN.md:553:- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)
docs/specs/ULTRAPLAN.md:555:- **Gotchas:** LinkedIn rate limits via Proxycurl. Reed/CV-Library have separate auth and separate result schemas. Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it.
docs/specs/ULTRAPLAN.md:571:### 8.2 v1.1 agents (seven, in build order)
docs/specs/ULTRAPLAN.md:593:- **MCP tools required:** Bullhorn (read for prior placements + candidates), shared with Sourcing Scout
docs/specs/ULTRAPLAN.md:594:- **Shared modules required:** Voice loader, decision log writer, the Brief Decoder→Sourcing Scout→Concierge orchestration template
docs/specs/ULTRAPLAN.md:595:- **External APIs:** Same as Sourcing Scout (reuses)
docs/specs/ULTRAPLAN.md:599:- **Gotchas:** Brief format varies hugely between clients. Build the parser as schema-driven, not pattern-matching. The orchestration handoff to Sourcing Scout is the load-bearing CortexOS test.
docs/specs/ULTRAPLAN.md:619:#### A11. The Night Sourcer (2 weeks)
docs/specs/ULTRAPLAN.md:626:- **Shared modules required:** Voice loader, decision log writer, the source-abstraction layer from Sourcing Scout
docs/specs/ULTRAPLAN.md:627:- **External APIs:** Same as Sourcing Scout + GitHub
docs/specs/ULTRAPLAN.md:629:- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared with Sourcing Scout)
docs/specs/ULTRAPLAN.md:630:- **Build complexity:** **M** (2 weeks) — reuses Sourcing Scout's source layer; the new work is the overnight scheduling + rate-limit budget allocation
docs/specs/ULTRAPLAN.md:689:| Sourcing Scout | ✓ | ✓ | | | ✓ | | ✓ | | | ✓ | |
docs/specs/ULTRAPLAN.md:694:| Night Sourcer | ✓ | ✓ | | | ✓ | | ✓ | | | ✓ | GitHub |
docs/specs/ULTRAPLAN.md:771:### Weeks 9–10 — Sourcing Scout + Concierge start
docs/specs/ULTRAPLAN.md:773:- Week 9: Sourcing Scout (daytime); LinkedIn + Reed + CV-Library integration
docs/specs/ULTRAPLAN.md:820:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
docs/specs/ULTRAPLAN.md:822:| 6 | LinkedIn rate limits via Proxycurl are tighter than expected | Medium | Medium | Sourcing Scout cost >£100/run | Negotiate Proxycurl enterprise plan; defer Night Sourcer to v1.2 if needed |
docs/architecture/second-brain-design.md:205:| `wiki/raw/briefs/` | one file per brief intake | markdown with frontmatter | `{epoch}-{brief-id}.md` | Brief Decoder (v1.1) on inbound | Sourcing Scout (v1.0 reads only candidate-relevant); Brief Decoder (v1.1) |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:211:| `wiki/compiled/briefs/{slug}.md` | one per Brief | same | same | Brief Decoder (v1.1); manual at v1.0 if needed | Sourcing Scout (v1.0 reads only); Brief Decoder (v1.1) |
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:237:| Brief | **v1.0 (skeleton) / v1.1 (full)** | Sourcing Scout (v1.0 A5) needs to *read* a Brief to source against; Brief Decoder (v1.1 A8) is the producer. v1.0 writes minimal Briefs (manual entry or direct Bullhorn sync via Janitor); full lifecycle waits for v1.1 |
docs/architecture/second-brain-design.md:319:v1.0 skeleton: only what Sourcing Scout (A5) needs to source against — role title, client, sector, must-haves. Full v1.1 schema waits for Brief Decoder.
docs/architecture/second-brain-design.md:429:| `list-by-type-and-tenant` | Sourcing Scout (v1.0): enumerate Candidates for filtering; Brief Decoder (v1.1): enumerate open Briefs | v1.0 (Candidate, Client, Placement, Contact); v1.1 (Brief full enumeration) | `(entity_type: str, tenant_id: str, filters?: dict, limit?: int)` | `List[EntityRef]` | few seconds | Postgres-indexed; filtering matches `search-by-attribute` |
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:774:| Sourcing Scout | 50:1 | reads briefs + candidate pool to filter; writes only shortlists |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/build-brief/00-MASTER-BRIEF.md:118:| 6 | Overnight autoresearch (theta wave) | Analyst-template agents schedule overnight experiments | Night Sourcer + Spec Pitcher use this |
docs/build-brief/00-MASTER-BRIEF.md:119:| 7 | Multi-agent orchestrator | `orchestrator` template + file-bus handoff contract | Brief Decoder → Sourcing Scout → Concierge pipeline lives here |
docs/build-brief/00-MASTER-BRIEF.md:591:### 8.2 The build order — v1.0 only
docs/build-brief/00-MASTER-BRIEF.md:599:| 5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:680:        │   v1.1 (+7): Inbound Triage, Brief Decoder, Night Sourcer, Competitor Interception,              │
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
docs/specs/PRODUCT-SPEC.md:92:#### R4. The Night Sourcer — overnight sourcing while you sleep
docs/specs/PRODUCT-SPEC.md:101:#### R5. Sourcing Scout (daytime form) — request-response sourcing during the day
docs/specs/PRODUCT-SPEC.md:104:- **Revenue story:** Same as the Night Sourcer for daytime urgency. Modelled: cuts intake-call-to-first-shortlist time from same-week to same-hour for urgent briefs.
docs/specs/PRODUCT-SPEC.md:108:- **Per-tenant config:** shared with Night Sourcer (same playbook, same source budget).
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:244:| **Growth** (11–25 fee earners) | £3,250 | All Boutique + Night Sourcer, Brief Decoder, Spec Pitcher, Real-Time Pulse, Competitor Interception, Recruitment Reporting | "5–10 net-new retainers/year from BD + Competitor Interception. 30%+ more briefs per consultant via Night Sourcer. 1–2 saved client relationships/year worth £30k–£100k each." |
docs/specs/PRODUCT-SPEC.md:365:Each per-agent config then has only its agent-specific keys (e.g., the Night Sourcer's source budget allocation, Pulse's signal weights). This means a typical agent's `config.schema.json` is 30 lines, not 300. Scales.
docs/specs/PRODUCT-SPEC.md:400:| 3 | Inter-agent file bus — agents hand work to each other via shared directories | Brief Decoder → Sourcing Scout → Concierge handoff; Triage → specialist-agent routing |
docs/specs/PRODUCT-SPEC.md:403:| 6 | Overnight autoresearch — long sessions against rate-limited APIs | Night Sourcer, Spec Pitcher (batch overnight runs) |
docs/specs/PRODUCT-SPEC.md:476:- Sourcing Scout (daytime form)
docs/specs/PRODUCT-SPEC.md:486:3. **Night Sourcer** (2 weeks) — overnight extension of Sourcing Scout
docs/specs/PRODUCT-SPEC.md:525:4. **Night Sourcer** — "Walk in to 27 reviewed candidates across your live briefs every morning."
docs/specs/PRODUCT-SPEC.md:526:5. **Sourcing Scout (daytime)** — "Shortlist in 15 minutes instead of by end of week."
docs/specs/_archive-build-handoff.md:381:| 5 | **Sourcing Scout** | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
docs/specs/_archive-build-handoff.md:384:After Concierge ships, the first pilot converts to paid (Week 14 milestone). v1.1 then layers Triage, Brief Decoder, Competitor Interception, Night Sourcer, and the Temp agents T5 + T3.
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/_supplementary/strategic-plan.md:394:### 8.2 Channels, ranked by realistic ROI for you
docs/operations/goal-week-4-track-1.md:5:**Master plan citations:** Master brief §8.2 (build wave W4 Cash Conductor MCP connectors) + ULTRAPLAN §8.1 A4 (Cash Conductor spec lines 531-545) + ADR-005 (Week-3 acceleration → Cash Conductor pulled forward to W4 substrate) + `agents/recruitment/cash-conductor/agent.md` §8 build dependencies + `docs/decisions/2026-05-31-d1-founder-decision.md` (D1-B resolved) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic live render by 2026-06-14).
docs/operations/goal-week-4-track-1.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (boundaries) + §8.2 W4-W7 rows + §10 (ratification cadence + always-ratify list) + §10.5
docs/operations/goal-week-4-track-1.md:488:  ✓ master brief §8.2 W4 row — Cash Conductor MCP connectors
docs/operations/goal-week-4-track-1.md:539:**Day 7 (2026-06-05) is the soft target. Day 9 (2026-06-07) is the hard cutoff** (W5 Janitor build starts then per master brief §8.2 if Bullhorn A+B has Accepted). If Day 9 hits without completion, escalate to founder review + scope-cut decision.
docs/features/agent-build/00-ORCHESTRATOR.md:45:### Phase 1 — Prove ONE (Sourcing Scout) end-to-end
docs/features/agent-build/00-ORCHESTRATOR.md:46:Spawn a single worktree sub-agent for `02-specs/spec-003-sourcing-scout.md`. **Sourcing Scout is
docs/features/agent-build/STATUS.md:6:**Phase:** 1 (PROVE-ONE). Substrate frozen 2026-06-10 (all action_types + schema fields verified; build-gate PASS on main; CV-Library creds re-verified SET). Sourcing Scout pilot in flight.
docs/features/agent-build/STATUS.md:12:| Sourcing Scout | `spec-003-sourcing-scout.md` | 1 (PROVE-ONE) | ⚪ not started | — | **YES via CV-Library** (degraded mode) — the live pilot; Reed/Bullhorn blocked |
docs/features/agent-build/STATUS.md:28:2. **Sourcing Scout is the only fully live-smokeable remaining agent now** (CV-Library creds SET,
docs/features/agent-build/STATUS.md:35:- Bullhorn dev sandbox creds (unblocks Janitor/Scribe/Concierge + Sourcing Scout source #1).
docs/features/agent-build/STATUS.md:36:- Reed API creds (unblocks Sourcing Scout source #2).
docs/operations/session-retrospective-2026-06-03.md:21:- **Day 33 Phase 6 — Sourcing Scout bundle** (6 atomic commits `4e62d06` → `acb6d09`)
docs/operations/session-retrospective-2026-06-03.md:67:3. **Reading-discipline note pattern + vendor-delta documentation.** All 3 Day 31-33 bundles (Janitor + Scribe + Sourcing Scout) landed with Reading-discipline notes documenting the SKELETON-vs-CONTRACT deltas (Scribe: webhook → polling per Granola pivot; Sourcing Scout: 4 sources → 3 active per Proxycurl shutdown + reed/cvlibrary `package_status:scaffold_pending_phase_8`). W6 wiring naturally resolves these deltas; the notes mean W6 doesn't need to re-derive context.
docs/operations/session-retrospective-2026-06-03.md:83:4. **agent.md ratification-status ambiguity.** Scribe + Sourcing Scout agent.md both say "Status: Proposed" in their banners but were ratified at W3 cluster E (per file metadata + commit history). Reading-discipline note pattern documents this ambiguity; W6 ratification update flips both Proposed → Accepted explicitly.
docs/operations/session-retrospective-2026-06-03.md:117:e9cad16 feat(mcp/reed): scaffold @ifos/reed — Recruiter API for Sourcing Scout
docs/features/agent-build/01-LAUNCH.md:29:1. PROVE-ONE = Sourcing Scout (spec-003) — the only live-smokeable agent (CV-Library). Full implement→review→gate→live CV-Library smoke→green branch. Validates the machine before 3x.
docs/operations/w4-bilateral-pass-6-agent-md.md:37:| 3 | Sourcing Scout | 3 | Lowest residual; one scope question (webhook auto-source). |
docs/operations/w4-bilateral-pass-6-agent-md.md:110:## 3. Sourcing Scout — `agents/recruitment/sourcing-scout/agent.md`
docs/operations/w4-bilateral-pass-6-agent-md.md:122:  - **Codex says:** "It flips to Accepted on ratification/founder questions/ADR-006 before the W9 bundle exists, but the agent-bundle skill treats Accepted as production-ready after sibling files + fixtures exist and pass gates. Fix by keeping this scaffold Proposed after ratification, and make Proposed → Accepted depend on W9 build completion: `tools.yaml`, `context.sh`, `validate.sh`, `cycle.sh`, `cleanup.sh`, and 3 fixtures."
docs/operations/w4-bilateral-pass-6-agent-md.md:123:  - **Likely:** FIX-IN-PLACE. Edit §10 to gate Accepted on W9 bundle completion (sibling files + fixtures + gate A). Ratified scaffold stays at "Proposed (Ratified at Round-N)" until W9.
docs/operations/w4-bilateral-pass-6-agent-md.md:230:2. **Schema-citation hygiene** (Janitor #2, #3, #4; Sourcing Scout #1; Scribe #1) — v0.2/v0.3 supplement boundary is the single most-failed cross-reference. After this pass, recommend a CI grep that flags any `agent.md` field reference whose name doesn't appear in `vertical-schema.yaml` OR `vertical-schema.v0.3-supplement.yaml`.
docs/operations/w4-bilateral-pass-6-agent-md.md:236:5. **Status semantics** (Sourcing Scout #2) — confirm with founder: "Ratified at Round-N" is not "Accepted"; Accepted requires bundle completion. Likely a one-line clarification in the agent-bundle skill or master brief §8 to prevent this drift in future agents.
docs/operations/founder-manual-playbook-2026-05-31.md:254:When the response arrives, paste their answer (full body OK; no need to redact). I'll fold it into Janitor / Scribe / Sourcing Scout / Concierge §8 build-prerequisite rows.
docs/operations/founder-manual-playbook-2026-05-31.md:305:### 6.3 Proxycurl (~10 min) — unblocks Sourcing Scout W9 + Diagnostic LinkedIn deep data
docs/operations/founder-manual-playbook-2026-05-31.md:317:### 6.4 Reed + CV-Library (~15 min each) — unblocks W9 Sourcing Scout multi-source
docs/operations/founder-manual-playbook-2026-05-31.md:333:into our v1.0 Sourcing Scout agent, alongside Bullhorn + LinkedIn.
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-week-6-execution-plan.md:6:**Master plan citations:** Master brief §8.2 (build sequence; W6 = Scribe primary build week per line 597; W5+ Janitor + Scribe + Sourcing Scout transitions from SKELETON to LIVE) + ULTRAPLAN §8.1 A3 (Scribe build complexity M = 1 week per line 526) + W5 close state in `docs/operations/decision-log.md` Day 34.
docs/operations/goal-week-6-execution-plan.md:48:### C — Sourcing Scout MCP package wiring (Days 40-41; PARTIAL build slice)
docs/operations/goal-week-6-execution-plan.md:50:W6 partial because Sourcing Scout's W9 build slice per master brief §8.2 line 599 — Day 40+ is preparation, not the full Sourcing Scout production wiring. Specifically:
docs/operations/goal-week-6-execution-plan.md:55:14. **Sourcing Scout `cycle.sh` Step 4 LinkedIn NO-OP confirmed as W1.1+ scope** — no change; W6 acknowledges deferred status; W8-9 vendor selection precedes any wiring.
docs/operations/goal-week-6-execution-plan.md:59:15. All 5 v1.0 agent bundles in some live-wired state (full LIVE = Scribe + Janitor; PARTIAL = Sourcing Scout MCP packages ready, agent wait for W9).
docs/operations/goal-week-6-execution-plan.md:154:- Sourcing Scout tools.yaml: flip `package_status:scaffold_pending_phase_8` → `package_status:live` for reed_* + cvlibrary_*
docs/operations/goal-week-6-execution-plan.md:211:- Sourcing Scout: still partial (W9 build slice owns full close); package-delta disagreement persists at W6 close
docs/operations/goal-week-6-execution-plan.md:213:W7+ window for founder-triggered cluster F-tris run remains; expect partial-ratification at the Sourcing Scout layer only.
docs/operations/goal-week-6-execution-plan.md:223:- **LinkedIn vendor selection for Sourcing Scout v1.1+** — W8-9 decision per agent.md §"v1.1+ disposition"
docs/operations/goal-week-6-execution-plan.md:224:- **Sourcing Scout full agent live wiring** — W9 build slice per master brief §8.2 line 599
docs/operations/goal-week-6-execution-plan.md:233:Every agent.md Reading-discipline note added in W5 (CC + Concierge + Janitor + Scribe + Sourcing Scout) documents the SKELETON-vs-CONTRACT gap. W6 live wiring naturally REDUCES this gap as TODO(W6+) markers get replaced with real implementation. By W6 close, the Reading-discipline notes for Scribe + Janitor should flip from "SKELETON state today; W6+ build slice wires" to "LIVE state per Phase X commit Y; agent.md Status flipped Proposed → Accepted".
docs/operations/goal-week-6-execution-plan.md:235:Sourcing Scout's Reading-discipline note may remain in SKELETON state at W6 close since its full agent wiring is W9 — but the package-delta portion of the note (reed/cvlibrary `package_status:scaffold_pending_phase_8`) DOES close at Phase 7 of W6.
docs/features/agent-build/02-specs/spec-001-janitor.md:79:- Can run in parallel with: Scribe, Sourcing Scout (disjoint files) once proven.
docs/operations/parallel-agent-build-method.md:48:2. FAN OUT (parallel background worktrees) — Janitor ║ Scribe ║ Sourcing Scout.
docs/operations/parallel-agent-build-method.md:101:| Sourcing Scout | ⚪ SKELETON (~15 TODOs) | parallel fan-out (§3 step 2) | LinkedIn NO-OP (Proxycurl shutdown) |
docs/operations/parallel-agent-build-method.md:107:**Key constraint:** Bullhorn dev creds unobtainable → Janitor/Scribe/Concierge build to gate-green + fixture-proven; live-Bullhorn-smoke is founder-gated post-creds. Sourcing Scout is live-capable now (CV-Library). See `STATUS.md`.
docs/operations/goal-week-3-polish-and-scaffold.md:7:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:52:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:53:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:54:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:55:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:56:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:61:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:95:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
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
docs/operations/goal-week-3-polish-and-scaffold.md:415:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:591:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:621:  Sourcing Scout (W9):    <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:642:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:685:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/operations/decision-log.md:91:- **The tenant_adapters config validator** enforces the allowlist including `blocked_recipients`, `janitor_dedup_threshold`, `concierge_send_window` — Sourcing Scout / Janitor / Concierge build slices land on a verified config surface.
docs/operations/decision-log.md:141:| v0.3 supplement | 1 (Sourcing Scout R+W contradiction at lines 421-428 — extended R-only reconciliation to a 3rd stale site at 297-299) | `f6641c3` |
docs/operations/decision-log.md:147:**Verified after closure:** v0.3 YAML parses; migration structurally balanced (BEGIN/COMMIT, DROP/CREATE policy + trigger, GRANT USAGE,SELECT × 2, updated_at × 2, WHEN clause × 1); shellcheck clean; 65 vitest + hook-helpers + voice-loader all pass; adapter boundary 0 hits; no remaining Sourcing Scout R+W on candidate/contractor anywhere in the supplement.
docs/operations/decision-log.md:168:| v0.3 supplement | REJECTED 1 (stale "broader Sourcing Scout R+W" example in field-narrowing doc block lines 351-356) | `4e49458` |
docs/operations/decision-log.md:183:   - **Sourcing Scout (3):** blocked_recipients now-declared cite; recent_edit read removed (W-only); Gate A decision-log write
docs/operations/decision-log.md:188:   - **v0.3 supplement (3):** Sourcing Scout candidate/contractor R+W→R **[DECISION]**; client_contact_id derivation via entity_links; blocked_recipients element-string validation in migration
docs/operations/decision-log.md:193:2. **Sourcing Scout candidate/contractor access reverted R+W → R** — proposed matches live in the shortlist artefact, not Bullhorn writes. Aligns to ratified `bullhorn-integration-path §4.1 A5` + `sourcing-scout/agent.md §6` ("Bullhorn read-only"). Removes a v0.3-supplement drift, not a relitigation.
docs/operations/decision-log.md:238:| Sourcing Scout | Pre-Build-Round-9-Bilateral-Applied | 3 | 0 (all in `d1f4c53` + R9 polish) | Codex R10 re-ratification |
docs/operations/decision-log.md:255:  - Sourcing Scout: R1-R8 post-v0.3 (Pre-Build-Round-8-Reviewed; 3 last-mile)
docs/operations/decision-log.md:375:- ❌ Diagnostic W3-4 agent build (and all named v1.0 agent builds: Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/operations/decision-log.md:409:- `1472e04` (Step 11) Sourcing Scout agent.md (335 lines)
docs/operations/decision-log.md:429:| Sourcing Scout agent.md | REJECTED ~5-7 issues | Same |
docs/operations/decision-log.md:452:- ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/decision-log.md:465:- ADR-006 source-abstraction layer (per Sourcing Scout §9 Q6)
docs/operations/decision-log.md:484:- **Step 11** (`1472e04`) — Sourcing Scout agent.md (335 lines) per ULTRAPLAN §8.1 A5 (W9 build wave)
docs/operations/decision-log.md:500:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: Proposed; ready for Codex Round 4 Phase 2
docs/operations/decision-log.md:502:Per master brief §8.2 + ULTRAPLAN §8.1, each scaffold cites verbatim:
docs/operations/decision-log.md:509:| Sourcing Scout | W9 | A5 lines 543-555 |
docs/operations/decision-log.md:512:Drift flags surfaced for Sourcing Scout (master brief W9 vs ULTRAPLAN W8-9) and Concierge (master brief W10-13 = 4w vs ULTRAPLAN W9-10 = 2w). Master brief authoritative per project hierarchy; XL complexity in ULTRAPLAN A6 line 568 corroborates 4-week duration for Concierge.
docs/operations/decision-log.md:520:- ADR-006 source-abstraction layer (per Sourcing Scout §9 Q6)
docs/operations/decision-log.md:936:  - Agent × Entity R/W matrix across all 6 v1.0 agents (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) — cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3
docs/operations/decision-log.md:1007:- Postgres 16.14 + pgvector 0.8.2 on the LUKS volume; data directory on `/dev/mapper/ifos_data`; service `is-enabled: disabled` at boot (LUKS-noauto conflict per §5.2 deviation 14); `ifos-unlock` starts it post-mount.
docs/operations/decision-log.md:1062:- `docs/decisions/sequencing-target.md` — 522 lines, 7 sections. **Accepted** Option Alpha (master brief §8.2 ratified)
docs/operations/decision-log.md:1159:- **Day 3 ratification**: master brief §8.2 sequence ratified verbatim — Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 (Hire-#1-anchored) → Sourcing Scout W9 → Concierge W10-13
docs/operations/decision-log.md:1180:3. **Proxycurl→NinjaPear shutdown handling for Sourcing Scout v1.0.** Proxycurl shut down 2025 following LinkedIn's Jan 2025 lawsuit against Nubela (~50% of Proxycurl revenue was LinkedIn scraping). Successor product NinjaPear (same team) explicitly does NOT carry LinkedIn data. v1.0 Sourcing Scout's original 4-source design (Bullhorn passive-match + LinkedIn/Proxycurl + Reed + CV-Library) drops to 3 active sources at v1.0; LinkedIn deep-data deferred to v1.1+ when a legally-clear vendor lands. v1.1+ candidate vendors named: Lix, Phantombuster, Apify (LinkedIn-aware contracts), or LinkedIn's Sales Navigator enterprise API (much higher cost). Gate B target (≥6 of 10 advance per ULTRAPLAN A5 line 553) unchanged; the marginal contribution of LinkedIn data is unknown until pilot data informs the v1.1+ vendor decision. NEW Risk 14 added to RISK-REGISTER. See `agents/recruitment/sourcing-scout/agent.md` v1.0 caveat (commit `622a2e7`).
docs/operations/decision-log.md:1192:7. Sourcing Scout v1.0 caveat re Proxycurl→NinjaPear (commit `622a2e7`)
docs/operations/decision-log.md:1212:W5 closed today after a 7-phase marathon /goal session. All 5 v1.0 agent bundles (Cash Conductor + Concierge + Janitor + Scribe + Sourcing Scout) now have full SKELETON tiers landed (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures + agent.md Reading-discipline note). v0.4 schema supplement LIVE on production VPS. 3 new MCP packages scaffolded (@ifos/bullhorn + @ifos/workos + @ifos/granola). W5 deliverables match `docs/operations/goal-week-5-execution-plan.md` §1 success-state criteria.
docs/operations/decision-log.md:1220:3. **Vendor delta documentation pattern for agent.md ↔ deployed-reality drift.** Three agent bundles (Scribe + Sourcing Scout + earlier Concierge) have explicit deltas between their RATIFIED agent.md (CONTRACT) and the deployed SKELETON (vendor pivots, deferred sources, env-var fallbacks). The Reading-discipline note pattern (originated 2026-06-02 per Codex Fbis-R3 closure for CC + Concierge) extended in this session to document not just the SKELETON-vs-CONTRACT gap but the specific deltas (Scribe: webhook → polling per Granola pivot; Sourcing Scout: 4 sources → 3 active per Proxycurl shutdown; both: env-var fallbacks vs canonical SELECT path even though v0.4 supplement made the schema-clean paths available). W6+ ratification updates each agent.md to match deployed reality.
docs/operations/decision-log.md:1226:1. **Phase 6 — Sourcing Scout bundle** (Day 33 in plan-doc terms; landed Day 34 in marathon): 6 atomic commits `4e62d06` → `acb6d09`. 11-step cycle.sh with LinkedIn NO-OP at Step 4 per Proxycurl shutdown caveat; validate.sh G1-G7; multi-source context.sh + dual cache cleanup.sh; tools.yaml with 12 capabilities (4 Bullhorn READ + 2 Reed scaffold-pending + 2 CV-Library scaffold-pending + voice_classifier + telegram_notify + sourcing_scout_cleanup); 3 fixtures (01-primary happy / 02-edge-degraded-sources / 99-dnc-bulk-filter); agent.md Reading-discipline note with vendor + package deltas documented.
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:1:# Spec 003 — Sourcing Scout build
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:4:Conductor template + CLAUDE.md has everything it needs to build Sourcing Scout autonomously.**
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:9:- **Wave/tier:** v1.0 W9; request-response passive sourcing. **READ-ONLY on Bullhorn — no writes, no auto-send.**
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:66:- **🟢 MOST LIVE-CAPABLE of the 4 agents.** CV-Library creds are SET → Step 6 + the full rank→report path can be **live-smoked end-to-end in degraded mode (CV-Library only)** producing a real ranked report. Strongly consider Sourcing Scout (not Janitor) as the live prove-one demo — it needs no Bullhorn write + has a live source.
docs/operations/founder-api-signups-2026-06-03.md:77:**Why:** unblocks live tests on the `@ifos/reed` MCP package Claude will scaffold in marathon Phase 8. Sourcing Scout v1.0 = 3 sources; Reed is source #2 (Bullhorn passive-match is #1).
docs/operations/founder-api-signups-2026-06-03.md:109:**Why:** parallel to Reed. CV-Library is source #3 of Sourcing Scout's v1.0 trio.
docs/operations/founder-api-signups-2026-06-03.md:288:- **Don't sign up for Proxycurl / NinjaPear / LinkedIn deep-data vendors** — v1.1+ scope per Sourcing Scout caveat (action board item 8); current v1.0 = 3 sources without LinkedIn deep-data
docs/features/agent-build/02-specs/spec-002-scribe.md:71:- Can run in parallel with: Janitor, Sourcing Scout (disjoint files). Spawn after Janitor proves the build machine + the `@ifos/bullhorn` CLI-bridge pattern (which Scribe reuses).
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:1:# Sourcing Scout — W9 build-slice summary (spec-003)
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:82:| 4 | Stale build-state language: "@ifos/reed + @ifos/cv-library don't exist yet"; "validate.sh does NOT exist yet" | Build-state header + reading-discipline note rewritten to the W9 live bundle with per-component states (bullhorn: package exists, no CLI bridge, creds EMPTY → degraded-skip; reed: package v0.1.0, creds EMPTY; cv-library: package + dist/cli.js, creds EMPTY, live smoke founder-gated; nothing production-proven — zero live API calls); §5 Cat-5 note updated (validate.sh LIVE, not production-proven); §8 table statuses updated. §10 status field NOT flipped (founder-gated) |
docs/features/agent-build/03-implementation/sourcing-scout-summary.md:84:| 6 | tools.yaml header "Status: Proposed (W5 Day-33 SKELETON…)" vs README LIVE | Header now "Status: LIVE (W9 build slice, spec-003)" with explicit note that the agent.md §10 lifecycle flip is founder-gated and separate |
docs/operations/w4-day-20-founder-runbook.md:110:3. Sourcing Scout (3 findings) — fewest residuals
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:122:| Sourcing Scout | ~5-7 (count regex 50) | `logs/codex-ratification/20260524T1024...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:276:| Sourcing Scout | 4 | `20260524T113139Z-84869` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:284:- Sourcing Scout ULTRAPLAN A5 line refs: Gate A 553→552, Gate B 554→553 (4 citation sites)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:318:  - Sourcing Scout per-candidate decision rows (claimed in §3 but not in §4 cycle)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:333:- Sourcing Scout: pre-build-scaffold; Round-8-reviewed; minimal residual (catalogue-widening + per-candidate decision rows)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:374:| Sourcing Scout | 4 | 5 | +1 (Q7 enum claim missed by my Round-8 fix; Bullhorn webhook conflict newly surfaced) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:389:**Sourcing Scout R9:**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:391:2. ESC auth severity downgrade vs catalogue — Codex–founder disagreement (Sourcing Scout intentionally allows single-source auth failure as warn-only when 2+ sources remain; catalogue defines blocking. Real semantic divergence; needs catalogue widening OR Sourcing Scout agent.md realignment)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:419:4. **Catalogue v2 widening for ESC_DNC_FILTER_HIT + Sourcing Scout auth severity** — Cat-γ continuations
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:430:| Sourcing Scout | Pre-Build-Round-9-Reviewed | 5 (Cat-α Q7 + bullhorn-path conflict + Cat-γ DNC + Cat-ε per-candidate row + auth severity disagreement) | Mechanical Q7 fix + Bullhorn-path realignment + ESC widening 2 |
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
docs/operations/goal-week-5-execution-plan.md:6:**Master plan citations:** Master brief §8.2 line 596 (Janitor = W5; key dependency Bullhorn MCP R+W) + ULTRAPLAN §8.1 A2 (Janitor spec) + master brief §5.3 line 401 (WorkOS AuthKit is the v1.0 auth substrate; "don't add a second auth system") + ADR-005 (W3 Diagnostic acceleration → builds non-Bullhorn first when Bullhorn is slow) + `docs/decisions/bullhorn-integration-path.md` Sub-decision A RESOLVED 2026-06-02 (direct API per-tenant OAuth = v1.0 path; marketplace deferred to v1.1+).
docs/operations/goal-week-5-execution-plan.md:20:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (four boundaries) + §5.3 (`_shared/` substrate; **WorkOS AuthKit at line 401**) + §6 (Day 7 single-sentence test) + §8.2 (build sequence — Janitor at line 596) + §10.5 (always-ratify artefacts)
docs/operations/goal-week-5-execution-plan.md:21:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A2 (Janitor; lines 507-514) + A3 (Scribe; lines 518-527) + A5 (Sourcing Scout; lines 547-558) + §9 (Bullhorn critical path)
docs/operations/goal-week-5-execution-plan.md:26:9. **`docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md`** (cluster Fbis + G partial-ratification framework — Janitor + Scribe + Sourcing Scout bundles will land at the same partial-ratification shape; no expectation of Codex round-N clean ratification at the bundle layer)
docs/operations/goal-week-5-execution-plan.md:35:After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Janitor build dependency per master brief §8.2 line 596: Bullhorn MCP (R+W). ULTRAPLAN A2 build complexity: L (2 weeks; 1 week MCP + 1 week agent). Bullhorn Sub-decision A status: RESOLVED 2026-06-02 (direct API per-tenant OAuth = v1.0). WorkOS AuthKit per master brief §5.3 line 401 is the v1.0 auth substrate. Ready to begin Phase 1."**
docs/operations/goal-week-5-execution-plan.md:66:13. **Cluster F-tris ratification manifest entry** added — Janitor + Scribe + Sourcing Scout agent-bundles + Bullhorn MCP + WorkOS MCP + v0.4 supplement + Granola MCP (vendor pivoted from Fathom/Fireflies 2026-06-03). Founder triggers when ready (expected partial-ratification outcome per Fbis + G precedent; same disagreement-doc framework applies if rounds blow out).
docs/operations/goal-week-5-execution-plan.md:72:- Reed + CV-Library commercial signups → enables live Sourcing Scout tests
docs/operations/goal-week-5-execution-plan.md:158:### Phase 6 — Day 33: Sourcing Scout bundle
docs/operations/goal-week-5-execution-plan.md:168:- Add cluster F-tris entry to `scripts/run-codex-ratification.sh` (Janitor + Scribe + Sourcing Scout agent-bundles + 3 new MCP packages + v0.4 supplement)
docs/operations/goal-week-5-execution-plan.md:184:| 6 (Sourcing Scout bundle) | 33 | 4h | tools.yaml grew beyond CC + Concierge size | pause + verify against agent.md §3 contract |
docs/operations/goal-week-5-execution-plan.md:214:Per `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` precedent: expect **partial-ratification with disagreement docs** at the bundle layer for Janitor + Scribe + Sourcing Scout. The pattern:
docs/operations/goal-week-5-execution-plan.md:230:- **LinkedIn vendor selection for Sourcing Scout v1.1+** — W8-9 decision per `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` Risk 14
docs/operations/goal-week-5-execution-plan.md:232:- **Janitor + Scribe + Sourcing Scout LIVE deployment** — W7+ once Bullhorn dev-support reply + commercial signups land
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:84:| Sourcing Scout | `linkedin_profile_cache` | Stores profile snapshot to `/vault/<tenant>/wiki/raw/`; no external send; no rate-limit cost |
docs/decisions/autosend-safety-policy.md:94:| Sourcing Scout | `linkedin_connection_request` | 1-in-5 | Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy |
docs/decisions/autosend-safety-policy.md:110:| Sourcing Scout | `linkedin_inmail_send` | Outbound InMail (paid credit); cost-per-send; customer-facing |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:136:**Action:** PIVOT — likely vector: cheaper Claude model tier (Haiku 4.5 for routine actions, Sonnet for complex), or reduced agent run frequency (e.g., Sourcing Scout runs nightly batch instead of real-time), or per-tenant cost passthrough in pricing.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:347:- Adds 7 agents: Inbound Triage, Brief Decoder, Night Sourcer, Competitor Interception, Client Hunter digest, T5 Supply Chain Auditor, T3 Compliance Watchtower
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:25:| A5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | "First daytime always-on agent" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
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
docs/decisions/sequencing-target.md:151:| 2. Substrate exercise | **Medium** | Reuses Bullhorn R from Janitor (no new Bullhorn substrate). New MCP integrations: LinkedIn via Proxycurl (rate-limited per Ultraplan §10 row #6), Reed, CV-Library. Source-abstraction layer per Ultraplan §8.1 line 555 designed to be reusable by Night Sourcer v1.1 |
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
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:285:| 5 | W9 | **Sourcing Scout** (A5) | Multi-source aggregation; first LinkedIn rate-limit exercise (Risk #6) |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:310:- **Activation:** v1.0 scope cut from 6 to 4 agents per Ultraplan §10 row #4 — drop Concierge + Sourcing Scout to v1.1; founder solo through end of v1.0.
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:319:- **Cascade:** Sourcing Scout W10 (shifted right from W9), Concierge W11-14 (shifted right from W10-13).
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:23:| 9 | Sourcing Scout |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:75:- Sourcing Scout (W9) touches Bullhorn read; same gating
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:37:| A5 Sourcing Scout | **Yes — read** (ATS passive-match lookup) | Ultraplan §8.1 A5 line 547-551 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:309:| Sourcing Scout passive-match read | Polling (on-demand search) | Per-consultant-request | No subscription needed — read-on-demand model |
docs/decisions/bullhorn-integration-path.md:336:| Sourcing Scout (read-on-demand) | 50-200 during consultant-active windows | Search-heavy; multiple paginated reads per consultant request |
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '426,446p' && nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '506,526p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
   426	CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
   427	RETURNS TRIGGER AS $$
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
   525	  RETURN NEW;
   526	END;

codex
The core line anchors for the master brief, ULTRAPLAN A5, schema fields, and the `blocked_recipients` migration are mostly real. I’m checking the escalation catalogue and the live scripts next because this artifact now claims a built production bundle, so the contract has to match implementation.
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '584,604p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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

exec
/bin/zsh -lc 'rg -n "hh_decision|validate_gate_a_fail|candidate_proposed|scout_report|sourcing_scout_cleanup|consultant_feedback|action_type|tier|voice|blocked_recipients|Gate A|G[1-7]" agents/recruitment/sourcing-scout/{cycle.sh,validate.sh,cleanup.sh,tools.yaml,context.sh}' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
agents/recruitment/sourcing-scout/validate.sh:2:# Sourcing Scout agent — validate.sh (Gate A enforcement; W9 build slice LIVE)
agents/recruitment/sourcing-scout/validate.sh:5:# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
agents/recruitment/sourcing-scout/validate.sh:10:# hh_decision_action("validate_gate_a_fail", ...) audit row carrying the
agents/recruitment/sourcing-scout/validate.sh:30:#               "voice_score": <0.0-1.0> | "unscored",
agents/recruitment/sourcing-scout/validate.sh:42:#          tenant_adapters.config.blocked_recipients)
agents/recruitment/sourcing-scout/validate.sh:45:#   0  All Gate A checks pass; cycle.sh proceeds to the Step 10 vault write
agents/recruitment/sourcing-scout/validate.sh:46:#   1  At least one check failed; validate_gate_a_fail + ESC_* rows emitted;
agents/recruitment/sourcing-scout/validate.sh:50:# Checks (per agent.md §5 Gate A + ULTRAPLAN A5 line 552 verbatim):
agents/recruitment/sourcing-scout/validate.sh:51:#   G1 — Candidate count within [5, 15] inclusive
agents/recruitment/sourcing-scout/validate.sh:52:#   G2 — Every candidate has a working contact method (email regex [+ MX
agents/recruitment/sourcing-scout/validate.sh:54:#   G3 — Every candidate rationale ≥50 words
agents/recruitment/sourcing-scout/validate.sh:55:#   G4 — Every candidate rationale voice classifier ≥0.75
agents/recruitment/sourcing-scout/validate.sh:57:#   G5 — No candidate matches tenant DNC list (defence-in-depth re-check)
agents/recruitment/sourcing-scout/validate.sh:58:#   G6 — No PII outside firm boundary in any rationale (BLOCKING)
agents/recruitment/sourcing-scout/validate.sh:59:#   G7 — No enabled live source returned 0 WITHOUT a degradation note; and at
agents/recruitment/sourcing-scout/validate.sh:131:# G6 PII which is blocking and always takes precedence).
agents/recruitment/sourcing-scout/validate.sh:151:# G1 — Candidate count within [5, 15]
agents/recruitment/sourcing-scout/validate.sh:153:# overload. Both → ESC_AGENT_OUTPUT_SHAPE (warn-tier; catalogue line 184).
agents/recruitment/sourcing-scout/validate.sh:157:  _fail "G1: candidate count ${N_CANDIDATES} outside [${MIN_CANDIDATES}, ${MAX_CANDIDATES}]"
agents/recruitment/sourcing-scout/validate.sh:160:  _ok "G1: candidate count ${N_CANDIDATES} within [${MIN_CANDIDATES}, ${MAX_CANDIDATES}]"
agents/recruitment/sourcing-scout/validate.sh:164:# G2 — Every candidate has a working contact method
agents/recruitment/sourcing-scout/validate.sh:183:            _fail "G2: ${_c_id} email domain '${_dom}' has no MX record"
agents/recruitment/sourcing-scout/validate.sh:188:        _fail "G2: ${_c_id} email fails format check"
agents/recruitment/sourcing-scout/validate.sh:193:        _fail "G2: ${_c_id} phone not E.164"
agents/recruitment/sourcing-scout/validate.sh:198:        _fail "G2: ${_c_id} linkedin URL fails format check"
agents/recruitment/sourcing-scout/validate.sh:203:        _fail "G2: ${_c_id} bullhorn_internal with empty bullhorn id"
agents/recruitment/sourcing-scout/validate.sh:207:      _fail "G2: ${_c_id} has no working contact method (type='${_c_type}')" ;;
agents/recruitment/sourcing-scout/validate.sh:213:  _ok "G2: every candidate has a working contact method"
agents/recruitment/sourcing-scout/validate.sh:217:# G3 — Every rationale ≥50 words
agents/recruitment/sourcing-scout/validate.sh:227:    _fail "G3: ${_c_id} rationale ${_c_count:-0} words < ${MIN_RATIONALE_WORDS}"
agents/recruitment/sourcing-scout/validate.sh:239:  _ok "G3: every candidate rationale ≥${MIN_RATIONALE_WORDS} words"
agents/recruitment/sourcing-scout/validate.sh:243:# G4 — Every rationale voice classifier ≥0.75
agents/recruitment/sourcing-scout/validate.sh:245:# voice_corpus → a score cannot be honestly computed; spec-003 §5
agents/recruitment/sourcing-scout/validate.sh:251:while IFS=$'\t' read -r _c_id _c_voice; do
agents/recruitment/sourcing-scout/validate.sh:253:  if [[ "${_c_voice}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
agents/recruitment/sourcing-scout/validate.sh:254:    if ! awk -v s="${_c_voice}" -v t="${VOICE_SCORE_THRESHOLD}" 'BEGIN{exit !(s>=t)}'; then
agents/recruitment/sourcing-scout/validate.sh:256:      _fail "G4: ${_c_id} voice_score ${_c_voice} < ${VOICE_SCORE_THRESHOLD}"
agents/recruitment/sourcing-scout/validate.sh:261:done < <(jq -r '.candidates[] | [.candidate_id, (.voice_score | tostring)] | @tsv' "${PROPOSAL}")
agents/recruitment/sourcing-scout/validate.sh:265:  _warn "G4: ${_g4_unscored} rationale(s) unscored (no tenant voice_corpus) — threshold not enforceable (documented enhancement)"
agents/recruitment/sourcing-scout/validate.sh:267:  _ok "G4: every rationale voice classifier ≥${VOICE_SCORE_THRESHOLD}"
agents/recruitment/sourcing-scout/validate.sh:271:# G5 — No candidate matches tenant DNC list (defence-in-depth)
agents/recruitment/sourcing-scout/validate.sh:272:# Step 8 already filtered against tenant_adapters.config.blocked_recipients;
agents/recruitment/sourcing-scout/validate.sh:294:  _fail "G5: ${_g5_hits} candidate(s) match the tenant DNC list (post-Step-8 re-check)"
agents/recruitment/sourcing-scout/validate.sh:297:  _ok "G5: no candidate in DNC list (defence-in-depth re-check)"
agents/recruitment/sourcing-scout/validate.sh:301:# G6 — No PII outside firm boundary in any rationale (BLOCKING per
agents/recruitment/sourcing-scout/validate.sh:315:      _fail "G6: ${_c_id} rationale contains an email outside the firm boundary (domain '${_em_dom}')"
agents/recruitment/sourcing-scout/validate.sh:322:  _ok "G6: no PII outside firm boundary in any rationale"
agents/recruitment/sourcing-scout/validate.sh:326:# G7 — Source floor: no enabled live source returned 0 WITHOUT a degradation
agents/recruitment/sourcing-scout/validate.sh:346:  _fail "G7: ${_g7_bad} enabled live source(s) returned 0 without a recorded degradation note"
agents/recruitment/sourcing-scout/validate.sh:349:  _fail "G7: no source contributed and no degradation was recorded (silent all-source failure)"
agents/recruitment/sourcing-scout/validate.sh:352:  _ok "G7: source floor honoured (contributions or degradation notes present)"
agents/recruitment/sourcing-scout/validate.sh:359:printf '\nSourcing Scout validate Gate A: '
agents/recruitment/sourcing-scout/validate.sh:363:  #   G1/G2/G3/G5/G7 → ESC_AGENT_OUTPUT_SHAPE (warn; operator_chat_id)
agents/recruitment/sourcing-scout/validate.sh:364:  #   G4             → ESC_VOICE_DRIFT (warn; operator_chat_id)
agents/recruitment/sourcing-scout/validate.sh:365:  #   G6             → ESC_PII_LEAKAGE_RISK (BLOCKING; operator + ifos_oncall)
agents/recruitment/sourcing-scout/validate.sh:370:  # validate_gate_a_fail (green tier, registered).
agents/recruitment/sourcing-scout/validate.sh:371:  hh_decision_action "validate_gate_a_fail" "brief:${BRIEF_ID}" "${_ss_phash}" \
agents/recruitment/sourcing-scout/cleanup.sh:7:# Per agent.md §3 actions list: Sourcing Scout's cleanup action_type is
agents/recruitment/sourcing-scout/cleanup.sh:8:# `sourcing_scout_cleanup` (green tier — internal-only audit row recording
agents/recruitment/sourcing-scout/cleanup.sh:11:# Per agents/_shared/autosend-policy.yaml: `sourcing_scout_cleanup` is QUEUED
agents/recruitment/sourcing-scout/cleanup.sh:14:# the action row + green-tier classification.
agents/recruitment/sourcing-scout/cleanup.sh:29:#     (cycle.sh Step 10 writes partial drafts to /tmp on Gate A failure;
agents/recruitment/sourcing-scout/cleanup.sh:36:#   - tenant_adapters.config.blocked_recipients (loaded read-only by context.sh)
agents/recruitment/sourcing-scout/cleanup.sh:86:# /tmp partial drafts (cycle.sh Step 10 Gate A failures): 24h TTL — auto-purge
agents/recruitment/sourcing-scout/cleanup.sh:109:# Step 2 — Emit green-tier audit row (per agent.md §3 actions list)
agents/recruitment/sourcing-scout/cleanup.sh:114:# NOTE: sourcing_scout_cleanup action_type is still QUEUED (not yet in
agents/recruitment/sourcing-scout/cleanup.sh:116:# validate_gate_a_fail for this agent). Until the policy row lands, the
agents/recruitment/sourcing-scout/cleanup.sh:117:# audit row stays hh_decision_output (phase='output'); switching to
agents/recruitment/sourcing-scout/cleanup.sh:118:# hh_decision_action before registration would fail policy lookup → a
agents/recruitment/sourcing-scout/cleanup.sh:120:hh_decision_output "sourcing_scout_cleanup" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/sourcing-scout/context.sh:7:#         blocked_recipients; operator_telegram_chat_id is the v0.4 addition.
agents/recruitment/sourcing-scout/context.sh:9:#         §7 (voice + tone constraints) first.
agents/recruitment/sourcing-scout/context.sh:33:#   - Load tenant DNC list from tenant_adapters.config.blocked_recipients
agents/recruitment/sourcing-scout/context.sh:35:#   - Load voice corpus state + tone-rule count for Step 9 rationale honesty
agents/recruitment/sourcing-scout/context.sh:37:#   - Load firm-domain whitelist (validate.sh G6 PII regex pass).
agents/recruitment/sourcing-scout/context.sh:45:#   CTX_VOICE_CORPUS_ID           — active voice_corpus row id (or "none")
agents/recruitment/sourcing-scout/context.sh:48:#   CTX_FIRM_DOMAIN_WHITELIST     — comma-separated tenant firm domains (G6 PII)
agents/recruitment/sourcing-scout/context.sh:89:source "${_SHARED_DIR}/voice-loader.sh" 2>/dev/null || true
agents/recruitment/sourcing-scout/context.sh:199:# Empty voice_corpus → CTX_VOICE_CORPUS_STATE=absent → Step 9 records
agents/recruitment/sourcing-scout/context.sh:210:SELECT id FROM voice_corpus WHERE tenant_slug = :'tenant' AND is_active = true LIMIT 1;
agents/recruitment/sourcing-scout/context.sh:230:# Step 6 — DNC list load (tenant_adapters.config.blocked_recipients;
agents/recruitment/sourcing-scout/context.sh:232:# filter) + G5 (validate.sh defence-in-depth).
agents/recruitment/sourcing-scout/context.sh:238:  CTX_DNC_BLOCKED_RECIPIENTS="$(_ss_tenant_config blocked_recipients)"
agents/recruitment/sourcing-scout/context.sh:247:# Step 7 — Firm-domain whitelist (validate.sh G6 PII regex pass)
agents/recruitment/sourcing-scout/context.sh:280:hh_decision_trigger "session_start" \
agents/recruitment/sourcing-scout/context.sh:281:  "agent:sourcing-scout; tenant:${CTX_TENANT_SLUG}; corp:${CTX_BULLHORN_CORPORATION_ID}; sources_active:${CTX_SOURCES_ACTIVE_COUNT}; voice_corpus:${CTX_VOICE_CORPUS_STATE}"
agents/recruitment/sourcing-scout/context.sh:284:printf '[sourcing-scout context.sh] tenant=%s corp=%s sources_active=%s bullhorn_token=%s reed=%s cvlibrary=%s voice_corpus=%s tone_rules=%s firm_domains=%s dnc_entries=%s\n' \
agents/recruitment/sourcing-scout/cycle.sh:6:#         §4 (this workflow's 11 steps) + §5 (Gate A + Gate B) first.
agents/recruitment/sourcing-scout/cycle.sh:9:# produces output OR takes action MUST call hh_decision_* from
agents/recruitment/sourcing-scout/cycle.sh:35:#   IFOS_SCOUT_FORCE_VOICE_SCORE — numeric voice score override for the Step 9
agents/recruitment/sourcing-scout/cycle.sh:36:#       voice-drift drop route (no classifier exists yet; corpus-empty runs
agents/recruitment/sourcing-scout/cycle.sh:46:#   source breakdown + diagnostic exception list. Gate A failure → partial
agents/recruitment/sourcing-scout/cycle.sh:47:#   draft held at /tmp + exit 1 BEFORE the scout_report row.
agents/recruitment/sourcing-scout/cycle.sh:160:hh_decision_trigger "session_start" "sourcing-scout mode=${MODE} brief=${BRIEF_SLUG}"
agents/recruitment/sourcing-scout/cycle.sh:167:# <3 key dimensions → ESC_BRIEF_AMBIGUITY + validate_gate_a_fail + exit 1.
agents/recruitment/sourcing-scout/cycle.sh:208:    # No validate_gate_a_fail action row here — that action_type is reserved
agents/recruitment/sourcing-scout/cycle.sh:209:    # for Gate A itself (deviation 4, sourcing-scout-summary.md).
agents/recruitment/sourcing-scout/cycle.sh:221:  # Audit trail via autosend_escalate only; validate_gate_a_fail is reserved
agents/recruitment/sourcing-scout/cycle.sh:222:  # for Gate A itself (deviation 4, sourcing-scout-summary.md).
agents/recruitment/sourcing-scout/cycle.sh:227:hh_decision_output "brief_ingested" "brief:${BRIEF_SLUG}" \
agents/recruitment/sourcing-scout/cycle.sh:287:hh_decision_output "auth_refresh_complete" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/sourcing-scout/cycle.sh:291:  # No live source can contribute → the Gate A 5-candidate floor is already
agents/recruitment/sourcing-scout/cycle.sh:293:  # partial report + Gate A audit trail (agent.md §4 Step 2).
agents/recruitment/sourcing-scout/cycle.sh:297:  _ss_exception "All sources degraded — Gate A 5-candidate floor unobtainable this run"
agents/recruitment/sourcing-scout/cycle.sh:379:hh_decision_output "bullhorn_query" "brief:${BRIEF_SLUG}" \
agents/recruitment/sourcing-scout/cycle.sh:389:hh_decision_output "linkedin_query" "brief:${BRIEF_SLUG}" \
agents/recruitment/sourcing-scout/cycle.sh:400:hh_decision_output "reed_query" "brief:${BRIEF_SLUG}" \
agents/recruitment/sourcing-scout/cycle.sh:413:hh_decision_output "cvlibrary_query" "brief:${BRIEF_SLUG}" \
agents/recruitment/sourcing-scout/cycle.sh:429:hh_decision_output "aggregate_dedupe" "brief:${BRIEF_SLUG}" \
agents/recruitment/sourcing-scout/cycle.sh:434:# tenant_adapters.config.blocked_recipients (v0.3-allowlisted) via
agents/recruitment/sourcing-scout/cycle.sh:439:# candidate_proposed row (included=false) at Step 9 per spec-003 §3.
agents/recruitment/sourcing-scout/cycle.sh:469:  _ss_exception "${_ss_dropped} candidate(s) filtered against the tenant DNC list (blocked_recipients) at Step 8"
agents/recruitment/sourcing-scout/cycle.sh:471:hh_decision_output "dnc_filter" "brief:${BRIEF_SLUG}" \
agents/recruitment/sourcing-scout/cycle.sh:472:  "dropped:${_ss_dropped}; kept:${_ss_kept}; source:tenant_adapters.config.blocked_recipients"
agents/recruitment/sourcing-scout/cycle.sh:478:# honesty (spec-003 §8): empty voice_corpus → unscored/no_corpus, never a
agents/recruitment/sourcing-scout/cycle.sh:480:# ESC_VOICE_DRIFT. ONE candidate_proposed row PER candidate, including
agents/recruitment/sourcing-scout/cycle.sh:489:_ss_voice_state="${CTX_VOICE_CORPUS_STATE:-absent}"
agents/recruitment/sourcing-scout/cycle.sh:490:_ss_force_voice="${IFOS_SCOUT_FORCE_VOICE_SCORE:-}"
agents/recruitment/sourcing-scout/cycle.sh:491:_ss_voice_drops=0
agents/recruitment/sourcing-scout/cycle.sh:505:    hh_decision_output "candidate_proposed" "candidate:${_c_ref}" \
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
agents/recruitment/sourcing-scout/cycle.sh:540:    hh_decision_output "candidate_proposed" "candidate:${_c_ref}" \
agents/recruitment/sourcing-scout/cycle.sh:541:      "source:${_c_sources}; confidence:${_c_conf}; voice_score:${_c_voice}; included:false; drop_reason:voice_drift"
agents/recruitment/sourcing-scout/cycle.sh:548:    --arg voice "${_c_voice}" --arg voice_reason "${_c_voice_reason}" '
agents/recruitment/sourcing-scout/cycle.sh:557:      voice_score: (if ($voice | test("^[0-9.]+$")) then ($voice | tonumber) else $voice end),
agents/recruitment/sourcing-scout/cycle.sh:558:      voice_reason: $voice_reason,
agents/recruitment/sourcing-scout/cycle.sh:565:  hh_decision_output "candidate_proposed" "candidate:${_c_ref}" \
agents/recruitment/sourcing-scout/cycle.sh:566:    "source:${_c_sources}; confidence:${_c_conf}; voice_score:${_c_voice}; included:true"
agents/recruitment/sourcing-scout/cycle.sh:569:# candidate_proposed rows for the Step 8 DNC drops (included=false per spec-003 §3).
agents/recruitment/sourcing-scout/cycle.sh:573:  hh_decision_output "candidate_proposed" \
agents/recruitment/sourcing-scout/cycle.sh:575:    "source:$(printf '%s' "${_d}" | jq -r '(.sources // [.source]) | join(",")'); confidence:$(printf '%s' "${_d}" | jq -r '.confidence // 0'); voice_score:n/a; included:false; drop_reason:dnc_filter"
agents/recruitment/sourcing-scout/cycle.sh:582:# Step 10 — Output assembly + Gate A validation (validate.sh) → vault report
agents/recruitment/sourcing-scout/cycle.sh:583:# Gate A failure: partial draft to /tmp + validate_gate_a_fail + ESC row
agents/recruitment/sourcing-scout/cycle.sh:584:# (validate.sh emits both) + exit 1 BEFORE the scout_report row.
agents/recruitment/sourcing-scout/cycle.sh:640:  # degradation notes; validate.sh already emitted validate_gate_a_fail +
agents/recruitment/sourcing-scout/cycle.sh:641:  # the ESC row. Exit 1 BEFORE the scout_report row (agent.md §4 Step 10).
agents/recruitment/sourcing-scout/cycle.sh:645:  printf 'cycle.sh: Gate A FAIL — partial draft at %s\n' "${PARTIAL_PATH}" >&2
agents/recruitment/sourcing-scout/cycle.sh:646:  hh_decision_action "scout_run_complete" "brief:${BRIEF_SLUG}" \
agents/recruitment/sourcing-scout/cycle.sh:658:hh_decision_output "scout_report" "${REPORT_PATH}" \
agents/recruitment/sourcing-scout/cycle.sh:663:# Telegram when configured (green-tier operator_notify_telegram); Brain UI
agents/recruitment/sourcing-scout/cycle.sh:677:    hh_decision_action "operator_notify_telegram" "chat:${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
agents/recruitment/sourcing-scout/cycle.sh:687:hh_decision_action "scout_run_complete" "brief:${BRIEF_SLUG}" "${_ss_run_hash}" \
agents/recruitment/sourcing-scout/tools.yaml:11:# capability cycle.sh invokes + the autosend-policy action_type each
agents/recruitment/sourcing-scout/tools.yaml:17:# The only action_type is sourcing_scout_cleanup (green; QUEUED for W9).
agents/recruitment/sourcing-scout/tools.yaml:41:    action_type: bullhorn_oauth          # green tier; QUEUED for registration at W9
agents/recruitment/sourcing-scout/tools.yaml:73:    action_type: reed_oauth      # green tier; QUEUED for registration at W9
agents/recruitment/sourcing-scout/tools.yaml:95:    action_type: cvlibrary_oauth   # green tier; QUEUED for registration at W9
agents/recruitment/sourcing-scout/tools.yaml:123:  # Voice classifier (Step 9 per-candidate rationale voice scoring)
agents/recruitment/sourcing-scout/tools.yaml:124:  # Reference: agent.md §7; _shared/voice-loader.sh + hh_load_tone_rules.
agents/recruitment/sourcing-scout/tools.yaml:127:  - id: voice_classifier
agents/recruitment/sourcing-scout/tools.yaml:128:    package: "@ifos/voice-classifier"   # W4-5 polish microservice (per agent.md §8 build deps)
agents/recruitment/sourcing-scout/tools.yaml:129:    purpose: "Score per-candidate rationale against tenant voice corpus (≥0.75 required by Gate A G4); ESC_VOICE_DRIFT below threshold after 3 retries; per-run only (aggregate _TENANT is canary cron territory per agent.md §7)"
agents/recruitment/sourcing-scout/tools.yaml:140:    purpose: "Operator-channel Telegram notifications (NOT customer-facing; green tier) — Step 11 sourcing report completion notification when invoked via Telegram mode; Brain UI mode uses internal API instead"
agents/recruitment/sourcing-scout/tools.yaml:141:    action_type: operator_notify_telegram  # green tier; REGISTERED in autosend-policy.yaml
agents/recruitment/sourcing-scout/tools.yaml:150:  - id: sourcing_scout_cleanup
agents/recruitment/sourcing-scout/tools.yaml:152:    action_type: sourcing_scout_cleanup   # green tier; QUEUED for registration at W9
agents/recruitment/sourcing-scout/tools.yaml:175:    surface: "validate.sh G1 fail with ESC_AGENT_OUTPUT_SHAPE"
agents/recruitment/sourcing-scout/tools.yaml:176:    escalation: ESC_AGENT_OUTPUT_SHAPE   # warn; Gate A floor violated
agents/recruitment/sourcing-scout/tools.yaml:186:  - condition: "Per-candidate rationale voice classifier <0.75 after 3 retries (cycle.sh Step 9)"
agents/recruitment/sourcing-scout/tools.yaml:190:  - condition: "PII detected outside firm boundary in any rationale (validate.sh G6)"
agents/recruitment/sourcing-scout/tools.yaml:191:    surface: "validate.sh exit 1 with G6 failure"
agents/recruitment/sourcing-scout/tools.yaml:194:  - condition: "Candidate count not in [5, 15] OR missing contact method OR rationale <50 words OR DNC match OR no source contributed (validate.sh G1+G2+G3+G5+G7)"
agents/recruitment/sourcing-scout/tools.yaml:213:#   sourcing_scout_cleanup          green
agents/recruitment/sourcing-scout/tools.yaml:215:# NOTE: Sourcing Scout has NO yellow- or orange- or red-tier action_types.
agents/recruitment/sourcing-scout/tools.yaml:227:# - Action types all map to autosend-policy.yaml tiers (or explicitly QUEUED

exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_AUTH|ESC_LINKEDIN_AUTH|ESC_REED_AUTH|ESC_CVLIBRARY_AUTH|ESC_RATE_LIMIT_HIT|ESC_BRIEF_AMBIGUITY|ESC_VOICE_DRIFT|ESC_PII_LEAKAGE_RISK|ESC_AGENT_OUTPUT_SHAPE|ESC_GATE_B_MISS|ESC_DNC_FILTER_HIT|ESC_SCHEMA_VIOLATION|ESC_VOICE_DRIFT_TENANT" agents/_shared/escalation-codes.md agents/recruitment/sourcing-scout/cycle.sh agents/recruitment/sourcing-scout/validate.sh' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
agents/recruitment/sourcing-scout/validate.sh:134:  if [[ "$1" == "ESC_PII_LEAKAGE_RISK" ]]; then
agents/recruitment/sourcing-scout/validate.sh:135:    ESC_CLASS="ESC_PII_LEAKAGE_RISK"
agents/recruitment/sourcing-scout/validate.sh:153:# overload. Both → ESC_AGENT_OUTPUT_SHAPE (warn-tier; catalogue line 184).
agents/recruitment/sourcing-scout/validate.sh:158:  _set_class "ESC_AGENT_OUTPUT_SHAPE"
agents/recruitment/sourcing-scout/validate.sh:211:  _set_class "ESC_AGENT_OUTPUT_SHAPE"
agents/recruitment/sourcing-scout/validate.sh:237:  _set_class "ESC_AGENT_OUTPUT_SHAPE"
agents/recruitment/sourcing-scout/validate.sh:263:  _set_class "ESC_VOICE_DRIFT"
agents/recruitment/sourcing-scout/validate.sh:295:  _set_class "ESC_AGENT_OUTPUT_SHAPE"
agents/recruitment/sourcing-scout/validate.sh:303:# is not in CTX_FIRM_DOMAIN_WHITELIST → ESC_PII_LEAKAGE_RISK.
agents/recruitment/sourcing-scout/validate.sh:320:  _set_class "ESC_PII_LEAKAGE_RISK"
agents/recruitment/sourcing-scout/validate.sh:347:  _set_class "ESC_AGENT_OUTPUT_SHAPE"
agents/recruitment/sourcing-scout/validate.sh:350:  _set_class "ESC_AGENT_OUTPUT_SHAPE"
agents/recruitment/sourcing-scout/validate.sh:363:  #   G1/G2/G3/G5/G7 → ESC_AGENT_OUTPUT_SHAPE (warn; operator_chat_id)
agents/recruitment/sourcing-scout/validate.sh:364:  #   G4             → ESC_VOICE_DRIFT (warn; operator_chat_id)
agents/recruitment/sourcing-scout/validate.sh:365:  #   G6             → ESC_PII_LEAKAGE_RISK (BLOCKING; operator + ifos_oncall)
agents/recruitment/sourcing-scout/validate.sh:366:  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
agents/recruitment/sourcing-scout/cycle.sh:14:#               (ESC_BULLHORN_AUTH; never faked). Live path wired behind the
agents/recruitment/sourcing-scout/cycle.sh:18:#   Reed      — creds EMPTY today → degraded-skip (ESC_REED_AUTH).
agents/recruitment/sourcing-scout/cycle.sh:34:#       source (ESC_RATE_LIMIT_HIT route; degraded cached_only).
agents/recruitment/sourcing-scout/cycle.sh:167:# <3 key dimensions → ESC_BRIEF_AMBIGUITY + validate_gate_a_fail + exit 1.
agents/recruitment/sourcing-scout/cycle.sh:210:    autosend_escalate "ESC_BRIEF_AMBIGUITY" "agent=sourcing-scout" \
agents/recruitment/sourcing-scout/cycle.sh:223:  autosend_escalate "ESC_BRIEF_AMBIGUITY" "agent=sourcing-scout" \
agents/recruitment/sourcing-scout/cycle.sh:240:# Step 2). All live sources gone → ESC_AGENT_OUTPUT_SHAPE (<5 obtainable).
agents/recruitment/sourcing-scout/cycle.sh:274:_ss_resolve_source "bullhorn"  "${IFOS_SCOUT_FIXTURE_BULLHORN:-}"  "${_ss_bh_creds}"   "${_SS_CONN_BASE}/bullhorn/dist/cli.js"   "ESC_BULLHORN_AUTH"
agents/recruitment/sourcing-scout/cycle.sh:275:_ss_resolve_source "reed"      "${IFOS_SCOUT_FIXTURE_REED:-}"      "${_ss_reed_creds}" "${_SS_CONN_BASE}/reed/dist/cli.js"       "ESC_REED_AUTH"
agents/recruitment/sourcing-scout/cycle.sh:276:_ss_resolve_source "cvlibrary" "${IFOS_SCOUT_FIXTURE_CVLIBRARY:-}" "${_ss_cvl_creds}"  "${_SS_CONN_BASE}/cv-library/dist/cli.js" "ESC_CVLIBRARY_AUTH"
agents/recruitment/sourcing-scout/cycle.sh:294:  autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=sourcing-scout" \
agents/recruitment/sourcing-scout/cycle.sh:322:    # Simulated/observed 429 → ESC_RATE_LIMIT_HIT (warn) + cached-only
agents/recruitment/sourcing-scout/cycle.sh:324:    autosend_escalate "ESC_RATE_LIMIT_HIT" "agent=sourcing-scout" \
agents/recruitment/sourcing-scout/cycle.sh:351:        autosend_escalate "ESC_RATE_LIMIT_HIT" "agent=sourcing-scout" \
agents/recruitment/sourcing-scout/cycle.sh:393:# Step 5 — Reed query (≤30; ESC_REED_AUTH / ESC_RATE_LIMIT_HIT)
agents/recruitment/sourcing-scout/cycle.sh:437:# ESC_DNC_FILTER_HIT for outbound send refusal; W4-polish backlog:
agents/recruitment/sourcing-scout/cycle.sh:480:# ESC_VOICE_DRIFT. ONE candidate_proposed row PER candidate, including
agents/recruitment/sourcing-scout/cycle.sh:536:    autosend_escalate "ESC_VOICE_DRIFT" "agent=sourcing-scout" \
agents/recruitment/sourcing-scout/cycle.sh:539:    _ss_exception "Candidate ${_c_name} dropped: rationale voice score ${_c_voice} < 0.75 after 3 retries (ESC_VOICE_DRIFT)"
agents/_shared/escalation-codes.md:97:#### `ESC_BULLHORN_AUTH`
agents/_shared/escalation-codes.md:120:#### `ESC_VOICE_DRIFT`
agents/_shared/escalation-codes.md:141:#### `ESC_BRIEF_AMBIGUITY`
agents/_shared/escalation-codes.md:148:#### `ESC_PII_LEAKAGE_RISK`
agents/_shared/escalation-codes.md:156:#### `ESC_RATE_LIMIT_HIT`
agents/_shared/escalation-codes.md:163:#### `ESC_SCHEMA_VIOLATION`
agents/_shared/escalation-codes.md:170:#### `ESC_VOICE_DRIFT_TENANT`
agents/_shared/escalation-codes.md:172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
agents/_shared/escalation-codes.md:184:#### `ESC_AGENT_OUTPUT_SHAPE`
agents/_shared/escalation-codes.md:186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
agents/_shared/escalation-codes.md:232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
agents/_shared/escalation-codes.md:240:#### `ESC_REED_AUTH`
agents/_shared/escalation-codes.md:248:#### `ESC_CVLIBRARY_AUTH`
agents/_shared/escalation-codes.md:250:- **Trigger:** CV-Library API OAuth failure (same pattern as ESC_REED_AUTH)
agents/_shared/escalation-codes.md:256:#### `ESC_LINKEDIN_AUTH`
agents/_shared/escalation-codes.md:312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
agents/_shared/escalation-codes.md:377:#### `ESC_GATE_B_MISS`
agents/_shared/escalation-codes.md:424:#### `ESC_DNC_FILTER_HIT`
agents/_shared/escalation-codes.md:466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |

codex
One implementation mismatch has appeared: the document says Gate A requires voice classification, while the live validator explicitly lets unscored rationales pass when no tenant voice corpus exists. I’m checking whether that is documented as an allowed caveat elsewhere or whether it weakens the stated gate.
exec
/bin/zsh -lc "rg -n \"hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|voice_classifier_threshold|0\\.75\" agents/_shared/voice-loader.sh agents/_shared/common-voice.json 2>/dev/null || true" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '237,265p' && nl -ba agents/_shared/escalation-codes.md | sed -n '370,385p' && nl -ba agents/_shared/escalation-codes.md | sed -n '418,432p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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

exec
/bin/zsh -lc "rg --files | rg 'autosend.*policy.*ya?ml|autosend-safety-policy' && for f in "'$(rg --files | rg '"'autosend.*policy.*ya?ml|autosend-safety-policy'); do echo "'$f; rg -n "validate_gate_a_fail|operator_notify_telegram|consultant_feedback|sourcing_scout_cleanup|send_to_blocked_recipient|tier|action_type" $f; done' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml
docs/decisions/autosend-safety-policy.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
3:1. The v1.0 tier semantics remain contradictory. The policy says every governed action falls into exactly one tier at execution (lines 41-43) and orange requires a cortextOS approval gate before send (lines 57-60), but §9 still says v1.0 ships "green + red only" and handles "needs approval" outside the policy pipeline (lines 474-481). The later Q6 note accepts an ad-hoc helper (lines 612-618), but that does not reconcile the binding tier model.
4:   Proposed fix: choose and encode one v1.0 behavior. Either D1-A: mark all orange action_types red in v1.0; D1-B: update §9 to say orange approval is in scope via the bridge; or D1-C: model ad-hoc approval as a named v1.0 tier/policy path with exact helper semantics.
agents/_shared/autosend-policy.yaml
6:# tenant_adapters.config.tier_overrides (§8).
8:# 47 v1.0 action_types: 19 green + 10 yellow + 10 orange + 8 red.
10:#   tier            green|yellow|orange|red
23:action_types:
26:  # GREEN — auto-send without review (19 action_types)
30:    tier: green
36:    tier: green
42:    tier: green
48:    tier: green
54:    tier: green
60:    tier: green
65:  operator_notify_telegram:
66:    tier: green
72:    tier: green
78:    tier: green
84:    tier: green
90:    tier: green
96:    tier: green
98:    reason: "Status marker recorded AFTER an external send completes (the send itself was a different orange/yellow action_type with its own decision_log row); this row closes the workflow trace"
102:    tier: green
104:    reason: "Internal audit row recorded by Concierge cycle.sh Step 11 when an approval is routed via the autosend-bridge (per Founder Decision D1 path A/B/C). Payload carries d1_path + bridge_target (approval_id or vault path). Not an external send; the actual send is a downstream orange-tier action_type with its own row."
108:    tier: green
113:  consultant_feedback:
114:    tier: green
119:  validate_gate_a_fail:
120:    tier: green
126:    tier: green
132:    tier: green
138:    tier: green
144:    tier: green
150:  # MCP-connector OAuth refresh action_types (added 2026-06-01
152:  # documented action_types to exist in this policy with matching
153:  # tier; round-1 REJECT cited all 4 as missing). All green: OAuth
158:    tier: green
164:    tier: green
166:    reason: "QuickBooks Online OAuth 2.0 refresh — idempotent token rotation against oauth.platform.intuit.com; @ifos/quickbooks connector handles concurrent-refresh dedup per-realm; QB refresh tokens have ~100-day TTL so operator alerting on refreshTokenNearExpiry() is the consumer's responsibility, not this action_type's."
170:    tier: green
172:    reason: "TrueLayer OAuth 2.0 refresh — idempotent token rotation against auth.truelayer.com; @ifos/open-banking connector handles concurrent-refresh dedup per-connection; PSD2 90-day consent expiry surfaces via ESC_OPEN_BANKING_TOKEN_AGING (separate aging signal, not this action_type)."
176:    tier: green
182:    tier: green
184:    reason: "Internal Bullhorn activity-log entry — NOT customer-visible (separate from bullhorn_note_customer_visible which is orange). Maintains the audit trail in Bullhorn itself so downstream consultant ops see Concierge actions on the candidate's record. Idempotent within payload_hash dedup window. Registered per Codex Fbis-R1 closure 2026-06-02 — Concierge agent.md §4 Step 13 needs this for tier classification of the external write."
188:  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
192:    tier: yellow
199:    tier: yellow
206:    tier: yellow
213:    tier: yellow
220:    tier: yellow
227:    tier: yellow
234:    tier: yellow
241:    tier: yellow
248:    tier: yellow
255:    tier: yellow
258:    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
262:  # ORANGE — per-action human approval (10 action_types)
266:    tier: orange
274:    tier: orange
281:    tier: orange
288:    tier: orange
295:    tier: orange
302:    tier: orange
309:    tier: orange
316:    tier: orange
323:    tier: orange
330:    tier: orange
337:  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
341:    tier: red
348:    tier: red
355:    tier: red
362:    tier: red
369:    tier: red
376:    tier: red
383:    tier: red
389:  send_to_blocked_recipient:
390:    tier: red
401:  approval_timeout: PT4H        # Default orange-tier approval window per §8 rule 5
411:  - "tier ∈ {green, yellow, orange, red}"
412:  - "yellow action_types MUST declare sample_rate (positive integer)"
413:  - "orange action_types MUST declare timeout (ISO-8601 duration)"
414:  - "red action_types MUST declare block_reason"
415:  - "tenant overrides may only ELEVATE tier (green→yellow→orange→red); red is floor"
416:  - "47 total action_types (19 green + 10 yellow + 10 orange + 8 red); v1.0 frozen as of 2026-05-24 bilateral-disposition extension"
docs/decisions/autosend-safety-policy.md
39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
45:Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.
49:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
67:Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
73:## §3 — Examples per tier across the v1.0 agent surface
75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
79:| Agent | action_type | Why green |
90:| Agent | action_type | Sample rate | Why yellow |
100:| Agent | action_type | Why orange |
115:| action_type | block_reason | Why red |
124:| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |
143:#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
148:  local action_type="$1"
157:  # 1. Policy lookup — read tier from the canonical policy table
158:  local tier
159:  tier=$(autosend_policy_lookup "$action_type") || {
160:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
161:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
166:  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
167:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
168:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
173:  case "$tier" in
175:      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
179:      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
180:      if autosend_should_sample "$action_type" "$tenant_slug"; then
181:        autosend_spot_check_enqueue "$action_type" "$target" "$payload_hash" "$payload_preview" "$tenant_slug"
186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
187:      autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW "$action_type" "$target" "$payload_hash" "$payload_preview"
189:      autosend_await_approval "$action_type" "$target" "$payload_hash"
193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
194:      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
198:      # Fail-safe: unknown tier → red
199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
200:      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
215:Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
219:action_types:
229:Agents cannot invoke action_types not declared in their `tools.yaml`. Renderer validates this at render time per ADR-003 §4 (`ESC_RENDERER_FAILED` reason `bundle-malformed` if a declared action_type isn't in the policy).
240:**Fires when:** an orange-tier action is invoked; opens cortextOS approval gate (primitive 4)
245:  "action_type": "<enum from autosend-policy.yaml>",
264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
283:**Fires when:** a red-tier action is invoked; blocked unconditionally
288:  "action_type": "<enum>",
292:  "block_reason": "<enum: red_tier_classification | blocked_recipient | unauthorized_adapter | cross_tenant_violation | payment_action | billing_modification | legal_artefact | pii_geographic_breach>",
302:3. Operator may file a `false-block` feedback report via Brain UI if the tier classification seems wrong; report becomes input to next policy review
304:**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).
314:Block reason: payment_action (red-tier; never auto-sent in v1.0)
326:  "action_type": "<enum, may be unknown>",
330:  "lookup_error": "<enum: unknown_action_type | policy_table_corrupt | override_resolution_failed | tenant_not_found | unknown_tier:<value>>",
338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
341:4. Root cause + fix applied (e.g., add missing `action_type` to policy, repair table corruption, fix override format)
353:| Policy file references undefined tier | Tier dispatch hits `*)` default | `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` with `lookup_error='unknown_tier:<value>'` | Policy file fixed; Codex ratifies; redeploy |
356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
358:| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |
384:--     "tier": "green|yellow|orange|red|fail-safe-red",
385:--     "action_type": "<enum>",
402:1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
432:    "tier_overrides": {
461:1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
462:2. **Red is absolute.** A red action_type cannot be elevated by tenant override (already at maximum) and cannot be relaxed (red is the floor).
464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
465:5. **`approval_timeouts`** allow per-action_type customisation within range [PT30M, PT72H]. Defaults to PT4H if unspecified.
466:6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
481:- **Yellow** (sampled review) requires building the spot-check queue infrastructure (spot_check_queue table, Brain UI review interface, sampling-disagreement-feedback loop). Defers without operational risk: high-volume agent work can run as green at v1.0 without sampled review, with tier elevation to orange-in-v1.1 as a fallback if quality issues surface.
487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
488:- **Yellow tier:** spot-check sampling. Implementation tasks: `spot_check_queue` table, `autosend_should_sample` function, Brain UI spot-check review interface, sampling-disagreement feedback loop into policy review.
493:- **Adaptive tiering:** ML-driven tier adjustment based on incident history. E.g., if `linkedin_connection_request` shows 0 false-blocks over 90 days, automatically propose downgrade from orange to yellow.
495:- **Pre-action policy simulation:** Brain UI feature — operator types proposed action; system shows tier, override impact, approval routing, expected resolution time. Reduces accidental tier-aware design.
511:classifies each agent action into one of four tiers: green, yellow,
526:  (d) any tier override defined in Tenant's tenant_adapters configuration
527:      that elevates or otherwise alters the policy default tier
536:      tier;
555:payload.policy_version_sha field. Material changes to tier classification
596:| 1 | Formal `action_type` taxonomy enum — should this live in autosend-policy.yaml only, or also in a typed schema for tools.yaml validation? | §3 + §4 | Defer to ADR-005 in Week 1; recommend typed enum in JSON Schema mirrored to YAML |
599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
601:| 6 | v1.0 "would-be-orange" cases without orange tier implementation — how does the agent halt for ad-hoc Telegram approval without breaking the green/red binary? | §9 | Recommend a `hh_decision_action_ad_hoc_approval` helper that lives alongside `hh_decision_action`; agent explicitly calls it for known orange cases at v1.0; v1.1 deprecates as orange tier ships. |
603:| 8 | Spot-check disagreement feedback loop — what's the mechanism for spot-check reviewer disagreement to elevate an action_type's tier? | §2 + §11 | Recommend a `spot_check_disagreement` table; >3 disagreements over 30 days triggers a tier-elevation proposal that goes through Codex ratification. v1.1 builds this. |
604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
621:- **Q5 (sampling rate defaults for yellow tier):** ACCEPTED for v1.0 with explicit operational-guess flag. Real sampling rates need pilot data; current defaults (1-in-5 to 1-in-20 per `action_type` in §3) are operational guesses calibrated by analogy to typical CRM audit-sampling practice. Refinement happens once first pilot generates 4+ tenant-weeks of yellow-tier action volume.
622:- **Q6 (v1.0 ad-hoc orange handling without orange tier shipped):** ACCEPTED. `hh_decision_action_ad_hoc_approval` helper sits alongside `hh_decision_action` in `_shared/hook-helpers.sh` (Week-1 prereq 3). Agent explicitly calls `_ad_hoc_approval` for known orange cases at v1.0; v1.1 deprecates the helper as full orange tier ships through `hh_decision_action`'s case-orange branch.
624:Remaining open questions (Q1 action_type enum format, Q2 policy file format, Q4 multi-recipient batching, Q7 policy version pinning, Q8 spot-check disagreement feedback, Q9 cross-action coupling, Q10 Telegram SLA instrumentation) deferred for ADR-005 + Week-1+ work.
634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
657:- v1.0 ship date: tier coverage is green + red. Yellow + orange phase in v1.1.

exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '1,140p' && nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '360,460p' && nl -ba agents/recruitment/sourcing-scout/validate.sh | sed -n '243,268p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
     1	# Sourcing Scout — request-response passive sourcing
     2	
     3	**Status:** Proposed.
     4	**Build state:** W9 build slice COMPLETE (spec-003; branch `worktree-agent-a45354564e8f66257`, 2026-06-10) — all 6 sibling bundle files + 3 fixtures LIVE; build-gate GREEN; three deterministic DB-backed fixture suites green. Prior contract history: Day-20 W4 bilateral pass + R19 substantive fix; R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`; R19 (2026-05-24) added the `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Still awaits: Q1 LOI + Bullhorn Sub-decision B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + Reed + CV-Library commercial signups (creds EMPTY; live smoke founder-gated) + Codex re-ratification of the built bundle + founder approvals per §10.
     5	**Reading-discipline note (updated 2026-06-10 at W9 build; originally added 2026-06-03 per CC + Concierge + Janitor + Scribe precedent):** this `agent.md` is the **CONTRACT** that the W9 build slice implemented against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml` + `README.md`) + 3 fixtures are **LIVE** — the W9 build slice (spec-003, this branch) replaced every `TODO(W9)` marker with live implementation; three deterministic DB-backed fixture suites (`scripts/run-scout-{dedupe,gate-a,degraded}-test.sh`) are green under build-gate. **Per-component build state, honestly stated:** `@ifos/bullhorn` — implemented connector package (`packages/mcp-connectors/bullhorn`); the Sourcing-Scout OAuth CLI bridge is not built and creds are EMPTY → cycle.sh Step 2 degraded-skip. `@ifos/reed` — implemented connector package (`packages/mcp-connectors/reed`, v0.1.0, tests green); creds EMPTY → degraded-skip until founder signup. `@ifos/cv-library` — implemented connector package + built `dist/cli.js` bridge (`packages/mcp-connectors/cv-library`, v0.1.0); the designated v1.0 live source, but creds EMPTY at last names-only verification → live smoke founder-gated. None of the three is production-proven: no live API call has been made by this bundle; all coverage is fixture-driven (`IFOS_SCOUT_FIXTURE_*`). **VENDOR NOTE:** the v1.0 contract is THREE active sources (Bullhorn + Reed + CV-Library); LinkedIn is structurally present as an explicit NO-OP only — cycle.sh Step 4 emits `linkedin_query` (`results:0; no_op`) per the Janitor Step 7 NO-OP pattern; vendor selection deferred to v1.1+ per the caveat at lines 6-8. **Live audit-marker set emitted by cycle.sh:** `session_start`, `brief_ingested`, `auth_refresh_complete`, `bullhorn_query`, `linkedin_query` (no-op), `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `candidate_proposed` (one row PER candidate), `scout_report`, `scout_run_complete`, plus `validate_gate_a_fail` (Gate A failure only) and `operator_notify_telegram` (when configured). Pure read+report agent — no yellow/orange/red action_types; the only cleanup action_type is `sourcing_scout_cleanup` (green; still QUEUED for autosend-policy registration — `cleanup.sh` emits `hh_decision_output` until it lands). `context.sh` uses the canonical `tenant_adapters` SELECT path (with `IFOS_FORCE_*` fixture fallbacks retained for tests) — `bullhorn_corporation_id` v0.4-allowlisted (LIVE on VPS commit `a1bbcf6`) + `blocked_recipients` v0.3-allowlisted (LIVE on VPS). §10 lifecycle status remains **Proposed** pending Codex re-ratification of the built bundle + founder approvals — the status flip is founder-gated.
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
   134	   → bullhorn (read-only); Reed; CV-Library. LinkedIn: NO auth at v1.0
   135	     (Step 4 is a NO-OP; vendor deferred to v1.1+)
   136	   → per-source auth failure fires the catalogue-specified ESC code with
   137	     its catalogue-specified degraded-mode behavior:
   138	     - ESC_BULLHORN_AUTH (catalogue §2.3): blocking → Sourcing Scout
   139	       enters degraded mode per catalogue ("drafts-only, no auto-send" —
   140	       Sourcing-Scout-specific interpretation: skip Bullhorn source +
   360	| `cycle.sh` orchestration (11-step) | W9 build slice (spec-003 §4) | ✅ |
   361	| 3 fixtures with golden outputs | W9 build slice + 3 DB-backed test suites | ✅ |
   362	
   363	**Post-W9-build note:** the four sibling-bundle deliverables (validate.sh, context.sh, cycle.sh, fixtures) WERE the W9 build slice and are delivered on this branch; the W9 build proceeded against deterministic fixtures per spec-003 §8 honest scope. The remaining ⏸ rows are FOUNDER/TENANT-ADMIN actions (commercial signups, creds, DNC population, voice corpus, ratifications) — they gate the first LIVE run and the §10 lifecycle transitions (Ratified-as-Scaffold → Accepted), not the fixture-backed build.
   364	
   365	---
   366	
   367	## §9 — Status + open questions
   368	
   369	**Status:** Proposed (W9 build slice COMPLETE on this branch — bundle LIVE per the build-state header; §10 status flip is founder-gated). Awaits Bullhorn Sub-decision B + 2 commercial signups (Reed + CV-Library; LinkedIn vendor deferred to v1.1+) + Q1 LOI + Codex re-ratification + founder approvals per §10.
   370	
   371	### Open questions for founder review
   372	
   373	| # | Question | Resolution path |
   374	|---|---|---|
   375	| Q1 | All three v1.0 sources required? Reed + CV-Library are UK-recruitment-specific; LinkedIn deep-data is deferred to v1.1+ post-Proxycurl-shutdown. Could v1.0 ship with Bullhorn + one job board only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
   376	| Q2 | LinkedIn vendor pricing (v1.1+) — the original Proxycurl model (~$39/mo for 5,000 credits, ~$20-50/day at peak per consultant) is void post-shutdown. Per-tenant budget cap for the v1.1+ vendor? | Deferred to v1.1+ vendor selection (Lix / Phantombuster / Apify / Sales Navigator); cost ceiling per brief remains the design constraint whichever vendor is chosen. |
   377	| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
   378	| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
   379	| Q5 | Gate B 6-of-10 metric — measured via consultant feedback (Brain UI v1.0 doesn't have feedback UX yet) | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful" → `decision_log` row via `consultant_feedback` green-tier action_type. v1.1: Brain UI button. NOTE: Bullhorn-note-based feedback is NOT a v1.0 path — Sourcing Scout is read-only on Bullhorn (no write capability); Bullhorn note creation would require tools.yaml write capability + autosend/decision logging which v1.0 explicitly excludes. |
   380	| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. A new ADR (number assigned at authoring time; not ADR-006 — that's Diagnostic Gate A) at W9 build start documenting the source-abstraction interface. |
   381	| Q7 | Bullhorn passive-match query — what's the right SEARCH filter? Per §4 Step 3 + vertical-schema candidate.status enum (`[active, archived, do_not_contact, placed, contractor_promoted]` — line 84-88 of vertical-schema.yaml; "passive" is NOT a canonical enum value), Sourcing Scout queries Bullhorn for `status='active'` candidates with `date_last_modified_at < now() - 90 days` (per schema line 100) to derive "passive" semantically. The question is whether Bullhorn's native search API supports this composite filter efficiently, or whether we need a 2-stage query (status=active first, then client-side modification-recency filter). | Founder + Bullhorn-rep clarification during Sub-decision B response. |
   382	
   383	### Gotchas (carried forward from ULTRAPLAN A5 line 555)
   384	
   385	1. **LinkedIn vendor rate limits (v1.1+).** The original Proxycurl per-credit quota model is void post-shutdown; the underlying constraint stands — deep profile fetches cost more than searches, so plan a cost ceiling per brief for whichever v1.1+ vendor is selected.
   386	2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
   387	3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.
   388	
   389	---
   390	
   391	## §10 — When this document ratifies
   392	
   393	Per `.codex/ratification/review-agent-bundle.md` skill (built 2026-05-24, commit `825ebd4`): this agent.md ratifies when Codex review-agent-bundle returns RATIFIED verdict on the SCAFFOLD shape (output contract + workflow + gates + escalation + dependencies). **Ratification of the scaffold does NOT make it Accepted.** Per the agent-bundle skill, Accepted means production-ready — which requires all sibling bundle files + fixtures + first production run.
   394	
   395	**Three-state lifecycle:**
   396	
   397	1. **Proposed → Ratified-as-Scaffold** when Codex review-agent-bundle returns RATIFIED on this agent.md alone. Pre-build scaffold confirmed shape-correct; the document is a binding contract for the W9 build slice.
   398	
   399	2. **Ratified-as-Scaffold → Accepted** when ALL:
   400	   - W9 build slice produces all 5 sibling bundle files (`tools.yaml`, `context.sh`, `validate.sh`, `cycle.sh`, `cleanup.sh`) + 3 fixtures with golden outputs
   401	   - Codex re-ratifies the full bundle (agent.md + siblings + fixtures) post-build
   402	   - Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B UX)
   403	   - Q2 cost model approved with per-tenant budget cap
   404	   - Q6: source-abstraction-layer ADR drafted + ratified (new ADR — not the same as ADR-006 which is Diagnostic Gate A; number assigned at authoring time)
   405	
   406	3. **Accepted → In Force** when:
   407	   - First production brief processed end-to-end against migration-test tenant
   408	   - Gate B feedback loop operational (Telegram /scout-feedback path; Brain UI in v1.1)
   409	   - First production render against a pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
   410	
   411	Until W9 build: this document is a forward-looking scaffold.
   412	
   413	*End of Sourcing Scout agent.md draft.*
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

exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/agent.md | sed -n '220,330p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
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
   230	   → voice classifier scores rationale (≥0.75)
   231	   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
   232	     from final list
   233	   → hh_decision_output("candidate_proposed", "candidate:<bullhorn_id|external_ref>",
   234	     "source:<bullhorn|linkedin|reed|cvlibrary>; confidence:<N>; voice_score:<N>; included:<bool>") — emitted PER CANDIDATE per §3 contract (one row per candidate proposed; dropped candidates also get a row with included=false + drop_reason)
   235	
   236	10. Output assembly + Gate A validation
   237	    → ensure 5-15 candidates remaining after Step 9
   238	    → ensure each has working contact method (email validated via simple
   239	      regex + domain MX check; phone validated via E.164 format)
   240	    → ensure each rationale ≥50 words
   241	    → if any condition fails: write partial draft to /tmp, then emit the
   242	      mandatory audit row hh_decision_action("validate_gate_a_fail",
   243	      "brief:<id>", payload_hash, "ESC_AGENT_OUTPUT_SHAPE; <failed_condition>")
   244	      — output-shape violation per catalogue line 184 (distinct from
   245	      ESC_SCHEMA_VIOLATION, reserved for vertical-schema field-constraint
   246	      violations at write time; audit row mandatory per master brief §8.1
   247	      Change 2 + autosend-policy.yaml lines 119-123) — then abort (exit 1)
   248	      BEFORE the scout_report row below
   249	    → write Markdown report to vault path per §3
   250	    → hh_decision_output("scout_report", report_path, "N candidates from M sources")
   251	
   252	11. Session close + notification
   253	    → operator notification per invocation source (Brain UI: in-app
   254	      notification; Telegram: reply with report path; webhook: bus event back)
   255	    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
   256	      "N=<N> sources_used=<M>")
   257	    → exit code 0
   258	```
   259	
   260	---
   261	
   262	## §5 — Gates
   263	
   264	### Gate A — validate.sh (hard-fail before action)
   265	
   266	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
   267	
   268	- **"5–15 candidates returned per brief"** (count within range)
   269	- **"each has a working contact method"** (email format + MX check OR E.164 phone OR LinkedIn URL OR Bullhorn bullhorn_id-with-contact)
   270	- **"each has rationale ≥ 50 words"**
   271	- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
   272	- All rationales pass voice classifier ≥0.75
   273	- No PII outside firm boundary in rationale text → fires `ESC_PII_LEAKAGE_RISK` (BLOCKING per catalogue §2.5 lines 148-154; halts immediately, not warn-only output-shape)
   274	- No enabled live source returns 0 candidates WITHOUT a recorded degradation exception note (sources in degraded mode per §4 Step 2 are expected to return 0 and don't trip Gate A)
   275	
   276	Gate A failure routing by class:
   277	- PII leakage → `ESC_PII_LEAKAGE_RISK` (blocking; operator + ifos_oncall)
   278	- Output-shape failures (count not in 5-15, contact-method missing, rationale <50 words, voice classifier miss, all-source-failure-without-degradation) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)
   279	On any Gate A failure, `validate.sh` writes the partial draft to `/tmp` and emits the mandatory `hh_decision_action("validate_gate_a_fail", ...)` audit row carrying the ESC code (per master brief §8.1 Change 2 + autosend-policy.yaml lines 119-123) BEFORE aborting; operator review.
   280	
   281	**Build note (updated 2026-06-10; the original Cat-5 honesty note said `validate.sh` did not exist yet):** `agents/recruitment/sourcing-scout/validate.sh` is now LIVE — delivered by the W9 build slice (spec-003 §5) implementing G1-G7 against the contract above, exercised by `scripts/run-scout-gate-a-test.sh` (PASS + 9 fail classes; deterministic DB-backed fixtures). Not yet production-proven: no live run has occurred (creds EMPTY; live smoke founder-gated).
   282	
   283	### Gate B — Outcome threshold (success metric, not block)
   284	
   285	Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
   286	
   287	Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply (v1.0). Aggregate over rolling 30-day window per tenant. NOTE: Bullhorn-note feedback is NOT a v1.0 path (Sourcing Scout is read-only on Bullhorn per §1 + §6 contracts; would require write capability not in v1.0 scope).
   288	
   289	Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing) — operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
   290	
   291	Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
   292	
   293	---
   294	
   295	## §6 — Escalation codes
   296	
   297	Sourcing Scout uses these ESC codes from `agents/_shared/escalation-codes.md`:
   298	
   299	| Code | Trigger | Severity | Routing |
   300	|---|---|---|---|
   301	| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (per catalogue §2.3) | operator + ifos_oncall |
   302	| `ESC_LINKEDIN_AUTH` | v1.1+ LinkedIn vendor session/OAuth fail — NOT fired at v1.0 (§4 Step 4 is an explicit NO-OP; no vendor) | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   303	| `ESC_REED_AUTH` | Reed API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   304	| `ESC_CVLIBRARY_AUTH` | CV-Library API OAuth fail | **blocking** (per catalogue §2.7) | operator + ifos_oncall |
   305	| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / reed / cv-library; linkedin reserved for v1.1+) | warn | operator_chat_id |
   306	| `ESC_BRIEF_AMBIGUITY` | LLM brief-parse yields <3 key dimensions (canonical code per catalogue §2.5) | warn | operator_chat_id |
   307	| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   308	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
   309	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
   310	| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
   311	
   312	Sourcing Scout does NOT use:
   313	
   314	- `ESC_AUTOSEND_*` — no auto-send actions; pure read + report
   315	- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
   316	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
   317	- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Sourcing Scout fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
   318	- `ESC_DNC_FILTER_HIT` — per catalogue §2.10 reserved for outbound send refusal specifically; Sourcing Scout's DNC filter is a sourcing-time pre-outbound filter. Drops logged in §3 exception list without ESC fire. v0.3 disposition; W4-polish backlog: add ESC_SOURCING_DNC_FILTER.
   319	
   320	---
   321	
   322	## §7 — Voice + tone constraints
   323	
   324	Step 9 (per-candidate rationale generation) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   325	
   326	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
   327	  - No demographic inference (age, gender, nationality, ethnicity, family status) — Equality Act 2010 compliance
   328	  - No salary-band reference unless explicitly supplied by candidate
   329	  - No claims about candidate intent ("looking to leave their role") without evidence in source data
   330	  - No mention of competing agency placements except in risk-flag context

exec
/bin/zsh -lc "nl -ba agents/recruitment/sourcing-scout/cycle.sh | sed -n '582,692p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
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
/bin/zsh -lc 'rg -n "auto_source_on_brief_create|bullhorn_corporation_id|operator_telegram_chat_id" docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/*.sql agents/recruitment/sourcing-scout/agent.md' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:14:-- keys (operator_telegram_chat_id, email_channel, workos_org_id,
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:15:-- granola_workspace_id, bullhorn_corporation_id) WILL BE BLOCKED at next
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:40:        'operator_telegram_chat_id',
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:44:        'bullhorn_corporation_id'
agents/recruitment/sourcing-scout/agent.md:5:**Reading-discipline note (updated 2026-06-10 at W9 build; originally added 2026-06-03 per CC + Concierge + Janitor + Scribe precedent):** this `agent.md` is the **CONTRACT** that the W9 build slice implemented against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml` + `README.md`) + 3 fixtures are **LIVE** — the W9 build slice (spec-003, this branch) replaced every `TODO(W9)` marker with live implementation; three deterministic DB-backed fixture suites (`scripts/run-scout-{dedupe,gate-a,degraded}-test.sh`) are green under build-gate. **Per-component build state, honestly stated:** `@ifos/bullhorn` — implemented connector package (`packages/mcp-connectors/bullhorn`); the Sourcing-Scout OAuth CLI bridge is not built and creds are EMPTY → cycle.sh Step 2 degraded-skip. `@ifos/reed` — implemented connector package (`packages/mcp-connectors/reed`, v0.1.0, tests green); creds EMPTY → degraded-skip until founder signup. `@ifos/cv-library` — implemented connector package + built `dist/cli.js` bridge (`packages/mcp-connectors/cv-library`, v0.1.0); the designated v1.0 live source, but creds EMPTY at last names-only verification → live smoke founder-gated. None of the three is production-proven: no live API call has been made by this bundle; all coverage is fixture-driven (`IFOS_SCOUT_FIXTURE_*`). **VENDOR NOTE:** the v1.0 contract is THREE active sources (Bullhorn + Reed + CV-Library); LinkedIn is structurally present as an explicit NO-OP only — cycle.sh Step 4 emits `linkedin_query` (`results:0; no_op`) per the Janitor Step 7 NO-OP pattern; vendor selection deferred to v1.1+ per the caveat at lines 6-8. **Live audit-marker set emitted by cycle.sh:** `session_start`, `brief_ingested`, `auth_refresh_complete`, `bullhorn_query`, `linkedin_query` (no-op), `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `candidate_proposed` (one row PER candidate), `scout_report`, `scout_run_complete`, plus `validate_gate_a_fail` (Gate A failure only) and `operator_notify_telegram` (when configured). Pure read+report agent — no yellow/orange/red action_types; the only cleanup action_type is `sourcing_scout_cleanup` (green; still QUEUED for autosend-policy registration — `cleanup.sh` emits `hh_decision_output` until it lands). `context.sh` uses the canonical `tenant_adapters` SELECT path (with `IFOS_FORCE_*` fixture fallbacks retained for tests) — `bullhorn_corporation_id` v0.4-allowlisted (LIVE on VPS commit `a1bbcf6`) + `blocked_recipients` v0.3-allowlisted (LIVE on VPS). §10 lifecycle status remains **Proposed** pending Codex re-ratification of the built bundle + founder approvals — the status flip is founder-gated.
agents/recruitment/sourcing-scout/agent.md:13:- `tenant_adapters.config.auto_source_on_brief_create` — v0.4-supplement-pending (not yet in any allowlist); the Bullhorn-webhook auto-source trigger code path is blocked until v0.4 lands.
agents/recruitment/sourcing-scout/agent.md:26:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from THREE active v1.0 sources** (Bullhorn ATS passive-match read; Reed.co.uk API; CV-Library API) — LinkedIn is structurally present as an explicit NO-OP row only (deferred to v1.1+ per the vendor caveat above; §4 Step 4 emits `linkedin_query` with `results:0; no_op`). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:45:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables `auto_source_on_brief_create`. v0.4-supplement-pending (config key not yet registered); webhook-trigger code path is BLOCKED until v0.4 supplement lands. v1.0 invocation is Brain UI button + Telegram only.
agents/recruitment/sourcing-scout/agent.md:211:     v0.4-pending status applies ONLY to `auto_source_on_brief_create`
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:74:  operator_telegram_chat_id:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:84:      context.sh: SELECT config->>'operator_telegram_chat_id' FROM
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:172:  bullhorn_corporation_id:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:248:      (operator_telegram_chat_id, email_channel, workos_org_id,
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:249:      granola_workspace_id, bullhorn_corporation_id). Per-key type validation
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:362:      operator_telegram_chat_id) BOTH become schema-clean.
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:11:--   - operator_telegram_chat_id  (D1-B Path B; Telegram chat ID for autosend approvals)
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:15:--   - bullhorn_corporation_id    (per-tenant Bullhorn corporation identifier)
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:74:--   - operator_telegram_chat_id: string matching '^-?[0-9]+$'
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:78:--   - bullhorn_corporation_id:   string matching '^[0-9]+$'
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:98:    'operator_telegram_chat_id',  -- D1-B Path B; autosend-bridge consumer
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:102:    'bullhorn_corporation_id'     -- per-tenant Bullhorn corporation
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:179:  -- operator_telegram_chat_id: string matching signed integer pattern
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:180:  IF c ? 'operator_telegram_chat_id' THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:181:    IF jsonb_typeof(c->'operator_telegram_chat_id') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:182:      RAISE EXCEPTION 'operator_telegram_chat_id must be string or null';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:184:    IF c->>'operator_telegram_chat_id' IS NOT NULL
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:185:       AND c->>'operator_telegram_chat_id' !~ '^-?[0-9]+$' THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:186:      RAISE EXCEPTION 'operator_telegram_chat_id must match ^-?[0-9]+$ (Telegram chat ID format); got: %', c->>'operator_telegram_chat_id';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:219:  -- bullhorn_corporation_id: string matching integer pattern
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:220:  IF c ? 'bullhorn_corporation_id' THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:221:    IF jsonb_typeof(c->'bullhorn_corporation_id') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:222:      RAISE EXCEPTION 'bullhorn_corporation_id must be string or null';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:224:    IF c->>'bullhorn_corporation_id' IS NOT NULL
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:225:       AND c->>'bullhorn_corporation_id' !~ '^[0-9]+$' THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:226:      RAISE EXCEPTION 'bullhorn_corporation_id must match ^[0-9]+$ (Bullhorn corporation ID format); got: %', c->>'bullhorn_corporation_id';

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
    17	# The only action_type is sourcing_scout_cleanup (green; QUEUED for W9).
    18	#
    19	# v1.0 capability set (3 active sources per agent.md §"v1.0 readiness caveat"):
    20	# - @ifos/bullhorn read-only (passive-match query)
    21	# - @ifos/reed (package scaffolded v0.1.0; creds EMPTY → degraded-skip until founder signup)
    22	# - @ifos/cv-library (package scaffolded v0.1.0 + CLI bridge built; the v1.0 live source)
    23	# - LinkedIn vendor DEFERRED to v1.1+ (Proxycurl shut down 2025;
    24	#   vendor selection W8-9 — Lix / Phantombuster / Apify / Sales Navigator)
    25	
    26	version: "0.1"
    27	agent: sourcing-scout
    28	
    29	capabilities:
    30	
    31	  # ────────────────────────────────────────────────────────────────────────
    32	  # Bullhorn ATS (R only; passive-match query per agent.md §4 Step 3)
    33	  # Reference: bullhorn-integration-path.md §4.1 A5 (Sourcing Scout READ-ONLY
    34	  # — no candidate/contractor writes; shortlist artefact is the output).
    35	  # Schema-clean post v0.4 supplement (LIVE on VPS 2026-06-03; commit a1bbcf6).
    36	  # ────────────────────────────────────────────────────────────────────────
    37	
    38	  - id: bullhorn_oauth
    39	    package: "@ifos/bullhorn"
    40	    purpose: "Bullhorn two-step OAuth refresh (Step A OAuth + Step B REST login per @ifos/bullhorn src/auth.ts); per-corporation_id Promise dedup + 401-force-refresh per cluster F R4 lesson"
    41	    action_type: bullhorn_oauth          # green tier; QUEUED for registration at W9
    42	    cycle_step: 2
    43	    secrets_required: [BULLHORN_CLIENT_ID, BULLHORN_CLIENT_SECRET]
    44	    rate_limit_hint: "per-corporation_id 600/min hard / 480/min soft"
    45	
    46	  - id: bullhorn_list_candidates
    47	    package: "@ifos/bullhorn"
    48	    purpose: "Passive-match query: status='active' + dateLastModified<90d (derived 'passive' per agent.md §4 Step 3; not a vertical-schema enum value); up to 30 hits per brief"
    49	    cycle_step: 3
    50	    state_changing: false
    51	
    52	  - id: bullhorn_get_candidate
    53	    package: "@ifos/bullhorn"
    54	    purpose: "Single-candidate hydrate for rationale generation context (Step 9)"
    55	    cycle_step: 9
    56	    state_changing: false
    57	
    58	  - id: bullhorn_get_brief
    59	    package: "@ifos/bullhorn"
    60	    purpose: "Brief hydrate when invoked via --brief-id (Step 1). W9 disposition: cycle.sh reads the Bullhorn-synced brief from the Postgres `entities` mirror (entity_type='brief'; spec-003 §2 upstream contract) — no direct Bullhorn call at v1.0. A direct getBrief/JobOrder endpoint on @ifos/bullhorn remains the v1.1 enhancement for tenants without an entities sync."
    61	    cycle_step: 1
    62	    state_changing: false
    63	
    64	  # ────────────────────────────────────────────────────────────────────────
    65	  # Reed.co.uk recruiter API (@ifos/reed scaffolded v0.1.0; creds pending signup)
    66	  # Reference: agent.md §4 Step 5. v1.0 source #2; W6+ commercial signup
    67	  # required (per founder-api-signups-2026-06-03.md P2).
    68	  # ────────────────────────────────────────────────────────────────────────
    69	
    70	  - id: reed_oauth
    71	    package: "@ifos/reed"
    72	    purpose: "Reed.co.uk recruiter API auth — long-lived API key presence check (Basic auth per @ifos/reed v0.1.0); creds EMPTY today → cycle.sh Step 2 degraded-skip (ESC_REED_AUTH)"
    73	    action_type: reed_oauth      # green tier; QUEUED for registration at W9
    74	    cycle_step: 2
    75	    secrets_required: [REED_API_KEY]   # placeholder — actual secret name from Phase 8 verification
    76	    rate_limit_hint: "per-account_id budget per @ifos/reed rate-limit.ts"
    77	    package_status: scaffolded_v0.1.0_creds_pending
    78	
    79	  - id: reed_search_candidates
    80	    package: "@ifos/reed"
    81	    purpose: "Reed candidate search by brief dimensions (location + salary band + role); up to 30 hits per brief; degraded-skip until creds land"
    82	    cycle_step: 5
    83	    state_changing: false
    84	    package_status: scaffolded_v0.1.0
    85	
    86	  # ────────────────────────────────────────────────────────────────────────
    87	  # CV-Library API (@ifos/cv-library scaffolded v0.1.0 + dist/cli.js bridge — the v1.0 live source)
    88	  # Reference: agent.md §4 Step 6. v1.0 source #3; W6+ commercial signup
    89	  # required (per founder-api-signups-2026-06-03.md P3).
    90	  # ────────────────────────────────────────────────────────────────────────
    91	
    92	  - id: cvlibrary_oauth
    93	    package: "@ifos/cv-library"
    94	    purpose: "CV-Library auth — network-free check-auth via dist/cli.js (long-lived key; Basic/Bearer dual-mode per CVLibraryConfig; exact mode verified at commercial signup)"
    95	    action_type: cvlibrary_oauth   # green tier; QUEUED for registration at W9
    96	    cycle_step: 2
    97	    secrets_required: [CVLIBRARY_API_KEY]   # placeholder per Phase 8 verification
    98	    rate_limit_hint: "per-account_id budget per @ifos/cv-library rate-limit.ts"
    99	    package_status: scaffolded_v0.1.0_cli_built
   100	
   101	  - id: cvlibrary_search_candidates
   102	    package: "@ifos/cv-library"
   103	    purpose: "CV-Library candidate search by brief dimensions via dist/cli.js search-candidates (normalised unified candidate shape); up to 30 hits per brief"
   104	    cycle_step: 6
   105	    state_changing: false
   106	    package_status: scaffolded_v0.1.0_cli_built
   107	
   108	  # ────────────────────────────────────────────────────────────────────────
   109	  # LinkedIn — NO-OP at v1.0
   110	  # Reference: agent.md §"v1.0 readiness caveat — LinkedIn deep-data vendor"
   111	  # lines 6-8. Proxycurl shut down 2025; NinjaPear doesn't carry LinkedIn
   112	  # data. v1.1+ vendor selection W8-9 (Lix / Phantombuster / Apify / Sales
   113	  # Navigator). No capability declaration at v1.0 — cycle.sh Step 4 is an
   114	  # explicit no-op audit row.
   115	  # ────────────────────────────────────────────────────────────────────────
   116	
   117	  # NOTE: linkedin_* capabilities deliberately NOT declared at v1.0. cycle.sh
   118	  # Step 4 emits a "linkedin_query" no-op audit row ("results:0; no_op")
   119	  # instead. v1.1+ supplement adds the chosen vendor's capability set when
   120	  # commercial signup + MCP package land.
   121	
   122	  # ────────────────────────────────────────────────────────────────────────
   123	  # Voice classifier (Step 9 per-candidate rationale voice scoring)
   124	  # Reference: agent.md §7; _shared/voice-loader.sh + hh_load_tone_rules.
   125	  # ────────────────────────────────────────────────────────────────────────
   126	
   127	  - id: voice_classifier
   128	    package: "@ifos/voice-classifier"   # W4-5 polish microservice (per agent.md §8 build deps)
   129	    purpose: "Score per-candidate rationale against tenant voice corpus (≥0.75 required by Gate A G4); ESC_VOICE_DRIFT below threshold after 3 retries; per-run only (aggregate _TENANT is canary cron territory per agent.md §7)"
   130	    cycle_step: 9
   131	    state_changing: false
   132	
   133	  # ────────────────────────────────────────────────────────────────────────
   134	  # Operator notification (Telegram OR Brain UI in-app)
   135	  # Reference: agent.md §4 Step 11; per-invocation-source notification.
   136	  # ────────────────────────────────────────────────────────────────────────
   137	
   138	  - id: telegram_notify
   139	    package: "@ifos/telegram"
   140	    purpose: "Operator-channel Telegram notifications (NOT customer-facing; green tier) — Step 11 sourcing report completion notification when invoked via Telegram mode; Brain UI mode uses internal API instead"
   141	    action_type: operator_notify_telegram  # green tier; REGISTERED in autosend-policy.yaml
   142	    cycle_step: 11
   143	    state_changing: false
   144	    secrets_required: [TELEGRAM_BOT_TOKEN]
   145	
   146	  # ────────────────────────────────────────────────────────────────────────
   147	  # Cleanup (cleanup.sh)
   148	  # ────────────────────────────────────────────────────────────────────────
   149	
   150	  - id: sourcing_scout_cleanup
   151	    purpose: "Post-run cleanup (transient @ifos/{bullhorn,reed,cv-library} cache purge + /tmp draft purge)"
   152	    action_type: sourcing_scout_cleanup   # green tier; QUEUED for registration at W9
   153	    state_changing: false
   154	    cycle_step: 11
   155	
   156	# ──────────────────────────────────────────────────────────────────────────────
   157	# Failure-modes table (per cluster Fbis pattern; ESC mapping per agent.md §6)
   158	# ──────────────────────────────────────────────────────────────────────────────
   159	
   160	failure_modes:
   161	
   162	  - condition: "@ifos/bullhorn OAuth refresh fails after 2 retries (cycle.sh Step 2)"
   163	    surface: "BullhornAuthError thrown by @ifos/bullhorn"
   164	    escalation: ESC_BULLHORN_AUTH    # blocking per catalogue §2.3 — but Sourcing-Scout-specific degraded mode = skip Bullhorn source + continue with Reed + CV-Library (NOT exit 1)
   165	
   166	  - condition: "@ifos/reed OAuth/API-key auth fails (cycle.sh Step 2)"
   167	    surface: "ReedAuthError per @ifos/reed v0.1.0 errors.ts; today: creds-absent degraded-skip at cycle.sh Step 2"
   168	    escalation: ESC_REED_AUTH        # blocking per catalogue §2.7 — Sourcing-Scout degraded mode = cached Reed search only (effectively skip Reed if no warm cache)
   169	
   170	  - condition: "@ifos/cv-library OAuth/API-key auth fails (cycle.sh Step 2)"
   171	    surface: "CVLibraryAuthError per @ifos/cv-library v0.1.0 errors.ts (CLI maps to {ok:false,error:\"auth\"})"
   172	    escalation: ESC_CVLIBRARY_AUTH   # blocking per catalogue §2.7 — same degraded-mode pattern as Reed
   173	
   174	  - condition: "Multiple sources in degraded mode AND remaining live can't produce ≥5 candidates (cycle.sh Step 2 + Step 10)"
   175	    surface: "validate.sh G1 fail with ESC_AGENT_OUTPUT_SHAPE"
   176	    escalation: ESC_AGENT_OUTPUT_SHAPE   # warn; Gate A floor violated
   177	
   178	  - condition: "Bullhorn / Reed / CV-Library returns 429 (cycle.sh Steps 3/5/6)"
   179	    surface: "*RateLimitError thrown by per-package client"
   180	    escalation: ESC_RATE_LIMIT_HIT       # warn; operator_chat_id; payload.upstream identifies bullhorn / reed / cv-library
   181	
   182	  - condition: "LLM brief parse yields <3 key dimensions (cycle.sh Step 1)"
   183	    surface: "Brief decoder returns insufficient dimensions"
   184	    escalation: ESC_BRIEF_AMBIGUITY      # warn per catalogue §2.5; operator_chat_id
   185	
   186	  - condition: "Per-candidate rationale voice classifier <0.75 after 3 retries (cycle.sh Step 9)"
   187	    surface: "Candidate dropped from final list + flagged in exception list"
   188	    escalation: ESC_VOICE_DRIFT          # warn per catalogue lines 120-125; operator_chat_id
   189	
   190	  - condition: "PII detected outside firm boundary in any rationale (validate.sh G6)"
   191	    surface: "validate.sh exit 1 with G6 failure"
   192	    escalation: ESC_PII_LEAKAGE_RISK     # blocking per catalogue §2.5; operator + ifos_oncall_chat_id
   193	
   194	  - condition: "Candidate count not in [5, 15] OR missing contact method OR rationale <50 words OR DNC match OR no source contributed (validate.sh G1+G2+G3+G5+G7)"
   195	    surface: "validate.sh exit 1 with output-shape failure"
   196	    escalation: ESC_AGENT_OUTPUT_SHAPE   # warn per catalogue line 184; operator_chat_id
   197	
   198	  - condition: "Below 6-of-10 advance rate for 30 consecutive days (monthly aggregate)"
   199	    surface: "monthly metrics roll-up; consultant feedback Telegram path"
   200	    escalation: ESC_GATE_B_MISS          # warn per catalogue routing; operator_chat_id; likely ranking heuristic drift OR source-mix imbalance
   201	
   202	# ──────────────────────────────────────────────────────────────────────────────
   203	# Action-type registration status (cross-reference autosend-policy.yaml)
   204	# ──────────────────────────────────────────────────────────────────────────────
   205	#
   206	# Already REGISTERED in agents/_shared/autosend-policy.yaml:
   207	#   operator_notify_telegram        green
   208	#
   209	# QUEUED for registration at W9 build start:
   210	#   bullhorn_oauth                  green
   211	#   reed_oauth                      green
   212	#   cvlibrary_oauth                 green
   213	#   sourcing_scout_cleanup          green
   214	#
   215	# NOTE: Sourcing Scout has NO yellow- or orange- or red-tier action_types.
   216	# Pure read + report agent; outputs go to vault Markdown only. No autosend
   217	# of customer-facing comms; no Bullhorn writes. Per agent.md §6: "ESC_AUTOSEND_*
   218	# explicitly NOT used — no auto-send actions; pure read + report."
   219	
   220	# ──────────────────────────────────────────────────────────────────────────────
   221	# Boundary check (per master brief §3 + review-mcp-connector.md §8)
   222	# ──────────────────────────────────────────────────────────────────────────────
   223	#
   224	# - No Composio / AgentMail references anywhere in this file.
   225	# - All packages declared are @ifos/* — no third-party adapters with policy
   226	#   semantics smuggled in via tools.yaml.
   227	# - Action types all map to autosend-policy.yaml tiers (or explicitly QUEUED
   228	#   above for W9 build-start registration).
   229	# - Capability ID set = @ifos/bullhorn READ subset per integration-path
   230	#   §4.1 A5 (Sourcing Scout READ-ONLY on Bullhorn; shortlist artefact is the
   231	#   output, NOT a Bullhorn candidate write) + @ifos/reed + @ifos/cv-library
   232	#   (both scaffolded v0.1.0; CV-Library additionally carries the dist/cli.js
   233	#   bridge — the v1.0 live source; Reed creds pending founder signup).
   234	# - LinkedIn capabilities deliberately NOT declared at v1.0 per Proxycurl
   235	#   shutdown caveat; v1.1+ supplement adds when vendor selection lands.

exec
/bin/zsh -lc 'rg -n "bullhorn_oauth|reed_oauth|cvlibrary_oauth|sourcing_scout_cleanup|operator_notify_telegram|scout_run_complete|validate_gate_a_fail" agents/_shared/autosend-policy.yaml agents/_shared/hook-helpers.sh agents/recruitment/sourcing-scout/cycle.sh agents/recruitment/sourcing-scout/cleanup.sh' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
agents/recruitment/sourcing-scout/cleanup.sh:8:# `sourcing_scout_cleanup` (green tier — internal-only audit row recording
agents/recruitment/sourcing-scout/cleanup.sh:11:# Per agents/_shared/autosend-policy.yaml: `sourcing_scout_cleanup` is QUEUED
agents/recruitment/sourcing-scout/cleanup.sh:114:# NOTE: sourcing_scout_cleanup action_type is still QUEUED (not yet in
agents/recruitment/sourcing-scout/cleanup.sh:115:# autosend-policy.yaml — spec-003 §2 registers only scout_run_complete +
agents/recruitment/sourcing-scout/cleanup.sh:116:# validate_gate_a_fail for this agent). Until the policy row lands, the
agents/recruitment/sourcing-scout/cleanup.sh:120:hh_decision_output "sourcing_scout_cleanup" "tenant:${CTX_TENANT_SLUG}" \
agents/_shared/autosend-policy.yaml:65:  operator_notify_telegram:
agents/_shared/autosend-policy.yaml:77:  scout_run_complete:
agents/_shared/autosend-policy.yaml:119:  validate_gate_a_fail:
agents/recruitment/sourcing-scout/cycle.sh:167:# <3 key dimensions → ESC_BRIEF_AMBIGUITY + validate_gate_a_fail + exit 1.
agents/recruitment/sourcing-scout/cycle.sh:208:    # No validate_gate_a_fail action row here — that action_type is reserved
agents/recruitment/sourcing-scout/cycle.sh:221:  # Audit trail via autosend_escalate only; validate_gate_a_fail is reserved
agents/recruitment/sourcing-scout/cycle.sh:583:# Gate A failure: partial draft to /tmp + validate_gate_a_fail + ESC row
agents/recruitment/sourcing-scout/cycle.sh:640:  # degradation notes; validate.sh already emitted validate_gate_a_fail +
agents/recruitment/sourcing-scout/cycle.sh:646:  hh_decision_action "scout_run_complete" "brief:${BRIEF_SLUG}" \
agents/recruitment/sourcing-scout/cycle.sh:663:# Telegram when configured (green-tier operator_notify_telegram); Brain UI
agents/recruitment/sourcing-scout/cycle.sh:677:    hh_decision_action "operator_notify_telegram" "chat:${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
agents/recruitment/sourcing-scout/cycle.sh:687:hh_decision_action "scout_run_complete" "brief:${BRIEF_SLUG}" "${_ss_run_hash}" \

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
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

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '24,185p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
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
   136	
   137	  linkedin_cache_purge_fail:
   138	    tier: green
   139	    agent: all
   140	    reason: "Internal audit row written by cleanup.sh when the transient LinkedIn /tmp cache cannot be purged (defense-in-depth per LinkedIn ToS gotcha; tools.yaml sets ttl=0 but explicit purge can still fail). Operator must manually verify cache cleared."
   141	    irreversible: false
   142	
   143	  diagnostic_cleanup:
   144	    tier: green
   145	    agent: diagnostic
   146	    reason: "Internal audit row written by cleanup.sh at end of normal-completion run. Records cache-purge status + workspace cleanup; no external comms."
   147	    irreversible: false
   148	
   149	  # ───────────────────────────────────────────────────────────
   150	  # MCP-connector OAuth refresh action_types (added 2026-06-01
   151	  # per Codex cluster F Round 1 — review-mcp-connector §7 requires
   152	  # documented action_types to exist in this policy with matching
   153	  # tier; round-1 REJECT cited all 4 as missing). All green: OAuth
   154	  # refresh is idempotent token rotation, not external send.
   155	  # ───────────────────────────────────────────────────────────
   156	
   157	  xero_oauth:
   158	    tier: green
   159	    agent: cash-conductor
   160	    reason: "Xero OAuth 2.0 refresh — idempotent token rotation against identity.xero.com; @ifos/xero connector handles concurrent-refresh dedup per-tenant; no external send."
   161	    irreversible: false
   162	
   163	  quickbooks_oauth:
   164	    tier: green
   165	    agent: cash-conductor
   166	    reason: "QuickBooks Online OAuth 2.0 refresh — idempotent token rotation against oauth.platform.intuit.com; @ifos/quickbooks connector handles concurrent-refresh dedup per-realm; QB refresh tokens have ~100-day TTL so operator alerting on refreshTokenNearExpiry() is the consumer's responsibility, not this action_type's."
   167	    irreversible: false
   168	
   169	  open_banking_truelayer:
   170	    tier: green
   171	    agent: cash-conductor
   172	    reason: "TrueLayer OAuth 2.0 refresh — idempotent token rotation against auth.truelayer.com; @ifos/open-banking connector handles concurrent-refresh dedup per-connection; PSD2 90-day consent expiry surfaces via ESC_OPEN_BANKING_TOKEN_AGING (separate aging signal, not this action_type)."
   173	    irreversible: false
   174	
   175	  open_banking_plaid_uk:
   176	    tier: green
   177	    agent: cash-conductor
   178	    reason: "Plaid UK OAuth 2.0 refresh — v1.1+ stub; never fires v1.0. Registered now so the README + tools.yaml capability declarations have a matching policy entry per review-mcp-connector §7 set-equality."
   179	    irreversible: false
   180	
   181	  bullhorn_activity_log_write:
   182	    tier: green
   183	    agent: concierge
   184	    reason: "Internal Bullhorn activity-log entry — NOT customer-visible (separate from bullhorn_note_customer_visible which is orange). Maintains the audit trail in Bullhorn itself so downstream consultant ops see Concierge actions on the candidate's record. Idempotent within payload_hash dedup window. Registered per Codex Fbis-R1 closure 2026-06-02 — Concierge agent.md §4 Step 13 needs this for tier classification of the external write."
   185	    irreversible: false

codex
A second blocking issue is the autosend/action-type story: the contract claims all state-changing paths are policy-safe, but the live tools file declares several queued action_types that do not exist in the shared policy. That is exactly the kind of Gate A/Gate B and autosend-policy drift this review is meant to catch.
exec
/bin/zsh -lc "rg -n \"TODO\\(|TODO|W9|forward-looking scaffold|QUEUED|hh_load_voice_samples|hh_load_tone_rules|voice_classifier|unscored|no_corpus|classifier_unavailable\" agents/recruitment/sourcing-scout agents/_shared/autosend-policy.yaml" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
agents/recruitment/sourcing-scout/cleanup.sh:2:# Sourcing Scout agent — cleanup.sh (post-run state purge; W9 build slice LIVE)
agents/recruitment/sourcing-scout/cleanup.sh:4:# Status: LIVE per spec-003 (W9 build slice).
agents/recruitment/sourcing-scout/cleanup.sh:11:# Per agents/_shared/autosend-policy.yaml: `sourcing_scout_cleanup` is QUEUED
agents/recruitment/sourcing-scout/cleanup.sh:12:# for registration at W9 build start (per tools.yaml status table). Once
agents/recruitment/sourcing-scout/cleanup.sh:13:# registered + the W9 build wires the real purge logic, this script emits
agents/recruitment/sourcing-scout/cleanup.sh:77:# Exported so the W9 build-slice can extend the find -delete logic via
agents/recruitment/sourcing-scout/cleanup.sh:84:# W9 LIVE: per-provider TTL purge. Bullhorn transient HTTP cache: 24h TTL.
agents/recruitment/sourcing-scout/cleanup.sh:114:# NOTE: sourcing_scout_cleanup action_type is still QUEUED (not yet in
agents/recruitment/sourcing-scout/cleanup.sh:119:# spurious fail-safe-red row. Queued for the W9 review pass.
agents/recruitment/sourcing-scout/context.sh:2:# Sourcing Scout agent — context.sh (pre-cycle hydration; W9 build slice LIVE)
agents/recruitment/sourcing-scout/context.sh:4:# Status: LIVE per spec-003 (W9 build slice). v0.4 schema supplement LANDED
agents/recruitment/sourcing-scout/context.sh:36:#     (empty corpus → unscored/no_corpus per spec-003 §8).
agents/recruitment/sourcing-scout/context.sh:200:# unscored/no_corpus (never a faked score; spec-003 §8).
agents/recruitment/sourcing-scout/context.sh:222:if command -v jq >/dev/null 2>&1 && declare -F hh_load_tone_rules >/dev/null 2>&1; then
agents/recruitment/sourcing-scout/context.sh:223:  CTX_TONE_RULES_COUNT="$(hh_load_tone_rules "sourcing_scout" 2>/dev/null \
agents/recruitment/sourcing-scout/validate.sh:2:# Sourcing Scout agent — validate.sh (Gate A enforcement; W9 build slice LIVE)
agents/recruitment/sourcing-scout/validate.sh:4:# Status: LIVE per spec-003 §5 (W9 build slice).
agents/recruitment/sourcing-scout/validate.sh:30:#               "voice_score": <0.0-1.0> | "unscored",
agents/recruitment/sourcing-scout/validate.sh:56:#         (hard when scored; WARN when unscored/no_corpus — spec-003 §5)
agents/recruitment/sourcing-scout/validate.sh:244:# Hard when a numeric score is present; WARN when unscored (empty tenant
agents/recruitment/sourcing-scout/validate.sh:246:# "hard (warn-when-unscored)" + §8 never-fake disposition).
agents/recruitment/sourcing-scout/validate.sh:250:_g4_unscored=0
agents/recruitment/sourcing-scout/validate.sh:259:    _g4_unscored=$((_g4_unscored + 1))
agents/recruitment/sourcing-scout/validate.sh:264:elif [[ "${_g4_unscored}" -gt 0 ]]; then
agents/recruitment/sourcing-scout/validate.sh:265:  _warn "G4: ${_g4_unscored} rationale(s) unscored (no tenant voice_corpus) — threshold not enforceable (documented enhancement)"
agents/recruitment/sourcing-scout/fixtures/99-dnc-bulk-filter.yaml:3:# W9 BUILD-SLICE ALIGNMENT (spec-003): marker names follow spec-003 §3
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:3:# W9 BUILD-SLICE ALIGNMENT (spec-003): marker names follow the spec-003 §3
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:9:# recorded unscored/no_corpus at v1.0 (empty tenant voice_corpus; honest
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:21:#   Step 9 produces 13 rationales all ≥50 words (voice: unscored/no_corpus
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:31:# Status: Proposed (W5 Day-33 SKELETON; W9 build slice wires the real
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:86:# Mocked Reed search (Step 5; TODO Phase 8 — fixture pre-encodes expected shape)
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:97:# Mocked CV-Library search (Step 6; TODO Phase 8 — fixture pre-encodes expected shape)
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:133:    voice_state: unscored_no_corpus   # v1.0 honesty; G4 warns, never fails on unscored
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:139:    g4_pass: true          # warn-when-unscored (no corpus); hard once classifier lands
agents/recruitment/sourcing-scout/fixtures/02-edge-case-degraded-sources.yaml:3:# W9 BUILD-SLICE ALIGNMENT (spec-003): the auth_refresh_complete marker uses
agents/recruitment/sourcing-scout/README.md:3:**Status:** W9 build slice COMPLETE (spec-003) — full bundle LIVE, pending Codex
agents/recruitment/sourcing-scout/README.md:37:- Voice: empty `voice_corpus` → rationales recorded `unscored/no_corpus`;
agents/recruitment/sourcing-scout/README.md:38:  Gate A G4 warns-when-unscored, hard once the classifier lands.
agents/recruitment/sourcing-scout/tools.yaml:3:# Status: LIVE (W9 build slice, spec-003) — capability set implemented by the
agents/recruitment/sourcing-scout/tools.yaml:17:# The only action_type is sourcing_scout_cleanup (green; QUEUED for W9).
agents/recruitment/sourcing-scout/tools.yaml:41:    action_type: bullhorn_oauth          # green tier; QUEUED for registration at W9
agents/recruitment/sourcing-scout/tools.yaml:60:    purpose: "Brief hydrate when invoked via --brief-id (Step 1). W9 disposition: cycle.sh reads the Bullhorn-synced brief from the Postgres `entities` mirror (entity_type='brief'; spec-003 §2 upstream contract) — no direct Bullhorn call at v1.0. A direct getBrief/JobOrder endpoint on @ifos/bullhorn remains the v1.1 enhancement for tenants without an entities sync."
agents/recruitment/sourcing-scout/tools.yaml:73:    action_type: reed_oauth      # green tier; QUEUED for registration at W9
agents/recruitment/sourcing-scout/tools.yaml:95:    action_type: cvlibrary_oauth   # green tier; QUEUED for registration at W9
agents/recruitment/sourcing-scout/tools.yaml:124:  # Reference: agent.md §7; _shared/voice-loader.sh + hh_load_tone_rules.
agents/recruitment/sourcing-scout/tools.yaml:127:  - id: voice_classifier
agents/recruitment/sourcing-scout/tools.yaml:152:    action_type: sourcing_scout_cleanup   # green tier; QUEUED for registration at W9
agents/recruitment/sourcing-scout/tools.yaml:209:# QUEUED for registration at W9 build start:
agents/recruitment/sourcing-scout/tools.yaml:227:# - Action types all map to autosend-policy.yaml tiers (or explicitly QUEUED
agents/recruitment/sourcing-scout/tools.yaml:228:#   above for W9 build-start registration).
agents/recruitment/sourcing-scout/cycle.sh:2:# Sourcing Scout agent — cycle.sh (11-step per-brief orchestration; W9 LIVE)
agents/recruitment/sourcing-scout/cycle.sh:4:# Status: LIVE per spec-003 §4 (W9 build slice).
agents/recruitment/sourcing-scout/cycle.sh:37:#       record unscored/no_corpus, never a faked number).
agents/recruitment/sourcing-scout/cycle.sh:478:# honesty (spec-003 §8): empty voice_corpus → unscored/no_corpus, never a
agents/recruitment/sourcing-scout/cycle.sh:521:  _c_voice="unscored"
agents/recruitment/sourcing-scout/cycle.sh:522:  _c_voice_reason="no_corpus"
agents/recruitment/sourcing-scout/cycle.sh:528:    # yet — recording unscored is the honest signal (never fake a number).
agents/recruitment/sourcing-scout/cycle.sh:529:    _c_voice_reason="classifier_unavailable"
agents/recruitment/sourcing-scout/agent.md:4:**Build state:** W9 build slice COMPLETE (spec-003; branch `worktree-agent-a45354564e8f66257`, 2026-06-10) — all 6 sibling bundle files + 3 fixtures LIVE; build-gate GREEN; three deterministic DB-backed fixture suites green. Prior contract history: Day-20 W4 bilateral pass + R19 substantive fix; R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`; R19 (2026-05-24) added the `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Still awaits: Q1 LOI + Bullhorn Sub-decision B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + Reed + CV-Library commercial signups (creds EMPTY; live smoke founder-gated) + Codex re-ratification of the built bundle + founder approvals per §10.
agents/recruitment/sourcing-scout/agent.md:5:**Reading-discipline note (updated 2026-06-10 at W9 build; originally added 2026-06-03 per CC + Concierge + Janitor + Scribe precedent):** this `agent.md` is the **CONTRACT** that the W9 build slice implemented against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml` + `README.md`) + 3 fixtures are **LIVE** — the W9 build slice (spec-003, this branch) replaced every `TODO(W9)` marker with live implementation; three deterministic DB-backed fixture suites (`scripts/run-scout-{dedupe,gate-a,degraded}-test.sh`) are green under build-gate. **Per-component build state, honestly stated:** `@ifos/bullhorn` — implemented connector package (`packages/mcp-connectors/bullhorn`); the Sourcing-Scout OAuth CLI bridge is not built and creds are EMPTY → cycle.sh Step 2 degraded-skip. `@ifos/reed` — implemented connector package (`packages/mcp-connectors/reed`, v0.1.0, tests green); creds EMPTY → degraded-skip until founder signup. `@ifos/cv-library` — implemented connector package + built `dist/cli.js` bridge (`packages/mcp-connectors/cv-library`, v0.1.0); the designated v1.0 live source, but creds EMPTY at last names-only verification → live smoke founder-gated. None of the three is production-proven: no live API call has been made by this bundle; all coverage is fixture-driven (`IFOS_SCOUT_FIXTURE_*`). **VENDOR NOTE:** the v1.0 contract is THREE active sources (Bullhorn + Reed + CV-Library); LinkedIn is structurally present as an explicit NO-OP only — cycle.sh Step 4 emits `linkedin_query` (`results:0; no_op`) per the Janitor Step 7 NO-OP pattern; vendor selection deferred to v1.1+ per the caveat at lines 6-8. **Live audit-marker set emitted by cycle.sh:** `session_start`, `brief_ingested`, `auth_refresh_complete`, `bullhorn_query`, `linkedin_query` (no-op), `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `candidate_proposed` (one row PER candidate), `scout_report`, `scout_run_complete`, plus `validate_gate_a_fail` (Gate A failure only) and `operator_notify_telegram` (when configured). Pure read+report agent — no yellow/orange/red action_types; the only cleanup action_type is `sourcing_scout_cleanup` (green; still QUEUED for autosend-policy registration — `cleanup.sh` emits `hh_decision_output` until it lands). `context.sh` uses the canonical `tenant_adapters` SELECT path (with `IFOS_FORCE_*` fixture fallbacks retained for tests) — `bullhorn_corporation_id` v0.4-allowlisted (LIVE on VPS commit `a1bbcf6`) + `blocked_recipients` v0.3-allowlisted (LIVE on VPS). §10 lifecycle status remains **Proposed** pending Codex re-ratification of the built bundle + founder approvals — the status flip is founder-gated.
agents/recruitment/sourcing-scout/agent.md:16:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:281:**Build note (updated 2026-06-10; the original Cat-5 honesty note said `validate.sh` did not exist yet):** `agents/recruitment/sourcing-scout/validate.sh` is now LIVE — delivered by the W9 build slice (spec-003 §5) implementing G1-G7 against the contract above, exercised by `scripts/run-scout-gate-a-test.sh` (PASS + 9 fail classes; deterministic DB-backed fixtures). Not yet production-proven: no live run has occurred (creds EMPTY; live smoke founder-gated).
agents/recruitment/sourcing-scout/agent.md:326:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:331:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:338:## §8 — Build dependencies (W9 prerequisites — table updated 2026-06-10 post-W9-build)
agents/recruitment/sourcing-scout/agent.md:354:| Source-abstraction layer (Night Sourcer reuse) | `_scout_query_source()` in cycle.sh (W9 build slice) | ✅ (ADR per §9 Q6 still to be authored) |
agents/recruitment/sourcing-scout/agent.md:358:| `validate.sh` Gate A logic | W9 build slice (spec-003 §5; G1-G7) | ✅ |
agents/recruitment/sourcing-scout/agent.md:359:| `context.sh` hydration | W9 build slice (canonical `tenant_adapters` SELECTs) | ✅ |
agents/recruitment/sourcing-scout/agent.md:360:| `cycle.sh` orchestration (11-step) | W9 build slice (spec-003 §4) | ✅ |
agents/recruitment/sourcing-scout/agent.md:361:| 3 fixtures with golden outputs | W9 build slice + 3 DB-backed test suites | ✅ |
agents/recruitment/sourcing-scout/agent.md:363:**Post-W9-build note:** the four sibling-bundle deliverables (validate.sh, context.sh, cycle.sh, fixtures) WERE the W9 build slice and are delivered on this branch; the W9 build proceeded against deterministic fixtures per spec-003 §8 honest scope. The remaining ⏸ rows are FOUNDER/TENANT-ADMIN actions (commercial signups, creds, DNC population, voice corpus, ratifications) — they gate the first LIVE run and the §10 lifecycle transitions (Ratified-as-Scaffold → Accepted), not the fixture-backed build.
agents/recruitment/sourcing-scout/agent.md:369:**Status:** Proposed (W9 build slice COMPLETE on this branch — bundle LIVE per the build-state header; §10 status flip is founder-gated). Awaits Bullhorn Sub-decision B + 2 commercial signups (Reed + CV-Library; LinkedIn vendor deferred to v1.1+) + Q1 LOI + Codex re-ratification + founder approvals per §10.
agents/recruitment/sourcing-scout/agent.md:380:| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. A new ADR (number assigned at authoring time; not ADR-006 — that's Diagnostic Gate A) at W9 build start documenting the source-abstraction interface. |
agents/recruitment/sourcing-scout/agent.md:397:1. **Proposed → Ratified-as-Scaffold** when Codex review-agent-bundle returns RATIFIED on this agent.md alone. Pre-build scaffold confirmed shape-correct; the document is a binding contract for the W9 build slice.
agents/recruitment/sourcing-scout/agent.md:400:   - W9 build slice produces all 5 sibling bundle files (`tools.yaml`, `context.sh`, `validate.sh`, `cycle.sh`, `cleanup.sh`) + 3 fixtures with golden outputs
agents/recruitment/sourcing-scout/agent.md:411:Until W9 build: this document is a forward-looking scaffold.

exec
/bin/zsh -lc 'rg -n "Composio|AgentMail|packages/harness/cortextos|cortextos/.+brain|kb-|stock KB|vault.*decision_log|decision_log.*Markdown|Postgres.*Markdown" agents/recruitment/sourcing-scout/agent.md agents/recruitment/sourcing-scout/tools.yaml agents/recruitment/sourcing-scout/*.sh' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
agents/recruitment/sourcing-scout/tools.yaml:224:# - No Composio / AgentMail references anywhere in this file.

exec
/bin/zsh -lc 'for f in agents/recruitment/sourcing-scout/*.sh agents/recruitment/sourcing-scout/bin/*.sh; do bash -n "$f" || exit 1; done; echo bash-n-ok' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
bash-n-ok

exec
/bin/zsh -lc 'rg -n "''^## §|''^# |''^'"\\*\\*Status|"'^'"\\*\\*Build state|"'^'"\\*\\*Date|"'^'"\\*\\*Author|"'^'"\\*\\*Build wave|"'^'"\\*\\*Build complexity|"'^'"\\*\\*Tier\" agents/recruitment/sourcing-scout/agent.md" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a45354564e8f66257
 succeeded in 0ms:
1:# Sourcing Scout — request-response passive sourcing
3:**Status:** Proposed.
4:**Build state:** W9 build slice COMPLETE (spec-003; branch `worktree-agent-a45354564e8f66257`, 2026-06-10) — all 6 sibling bundle files + 3 fixtures LIVE; build-gate GREEN; three deterministic DB-backed fixture suites green. Prior contract history: Day-20 W4 bilateral pass + R19 substantive fix; R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`; R19 (2026-05-24) added the `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Still awaits: Q1 LOI + Bullhorn Sub-decision B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + Reed + CV-Library commercial signups (creds EMPTY; live smoke founder-gated) + Codex re-ratification of the built bundle + founder approvals per §10.
14:**Date:** 2026-05-24.
15:**Author:** Founder (Maddox) + Claude Code.
16:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
17:**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
18:**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.
22:## §1 — Output contract (one-paragraph screenshot)
30:## §2 — Invocation surface
62:## §3 — Output shape
67:# Sourcing Scout — <Brief title>
112:## §4 — Workflow
262:## §5 — Gates
295:## §6 — Escalation codes
322:## §7 — Voice + tone constraints
338:## §8 — Build dependencies (W9 prerequisites — table updated 2026-06-10 post-W9-build)
367:## §9 — Status + open questions
369:**Status:** Proposed (W9 build slice COMPLETE on this branch — bundle LIVE per the build-state header; §10 status flip is founder-gated). Awaits Bullhorn Sub-decision B + 2 commercial signups (Reed + CV-Library; LinkedIn vendor deferred to v1.1+) + Q1 LOI + Codex re-ratification + founder approvals per §10.
391:## §10 — When this document ratifies

codex
REJECTED

1. Adapter-boundary violation in the surrounding bundle. `agents/recruitment/sourcing-scout/tools.yaml` line 224 directly names `Composio / AgentMail`, even as a negative assertion. The top-level adapter boundary says those names are never referenced in `tools.yaml`. Remove the product names and replace with generic wording such as "forbidden third-party adapters".

2. Gate A voice enforcement is weaker than the contract. `agent.md` lines 108, 230-232, and 272-279 say rationale voice classification is enforced at ≥0.75 and failures drop/abort, but `validate.sh` lines 243-267 only warns when rationales are unscored/no corpus and still passes Gate A. Make unscored voice a hard Gate A failure, or explicitly amend §1/§5/§7 to state "warn-when-unscored" as the accepted v1.0 gate.

3. Autosend action-type registration is not clean for the live bundle. `agent.md` line 5 claims the only cleanup action_type is `sourcing_scout_cleanup` and it is still queued, while `tools.yaml` lines 41, 73, 95, and 152 declare `bullhorn_oauth`, `reed_oauth`, `cvlibrary_oauth`, and `sourcing_scout_cleanup` as action_types that are queued/not registered. The review skill requires autosend-policy action_types to exist with matching tiers. Register these in `agents/_shared/autosend-policy.yaml` or remove the action_type declarations until they are real policy-governed actions.

4. §10 lifecycle status is internally stale and contradictory. `agent.md` line 393 says Accepted requires "first production run", but lines 399-404 omit that condition and lines 406-409 move first production evidence to In Force; line 411 also says "Until W9 build" despite lines 4-5 and 363 saying W9 is complete. Rewrite §10 so Proposed → Accepted → In Force has one non-conflicting set of criteria matching the current post-W9 state.
tokens used
104,074
REJECTED

1. Adapter-boundary violation in the surrounding bundle. `agents/recruitment/sourcing-scout/tools.yaml` line 224 directly names `Composio / AgentMail`, even as a negative assertion. The top-level adapter boundary says those names are never referenced in `tools.yaml`. Remove the product names and replace with generic wording such as "forbidden third-party adapters".

2. Gate A voice enforcement is weaker than the contract. `agent.md` lines 108, 230-232, and 272-279 say rationale voice classification is enforced at ≥0.75 and failures drop/abort, but `validate.sh` lines 243-267 only warns when rationales are unscored/no corpus and still passes Gate A. Make unscored voice a hard Gate A failure, or explicitly amend §1/§5/§7 to state "warn-when-unscored" as the accepted v1.0 gate.

3. Autosend action-type registration is not clean for the live bundle. `agent.md` line 5 claims the only cleanup action_type is `sourcing_scout_cleanup` and it is still queued, while `tools.yaml` lines 41, 73, 95, and 152 declare `bullhorn_oauth`, `reed_oauth`, `cvlibrary_oauth`, and `sourcing_scout_cleanup` as action_types that are queued/not registered. The review skill requires autosend-policy action_types to exist with matching tiers. Register these in `agents/_shared/autosend-policy.yaml` or remove the action_type declarations until they are real policy-governed actions.

4. §10 lifecycle status is internally stale and contradictory. `agent.md` line 393 says Accepted requires "first production run", but lines 399-404 omit that condition and lines 406-409 move first production evidence to In Force; line 411 also says "Until W9 build" despite lines 4-5 and 363 saying W9 is complete. Rewrite §10 so Proposed → Accepted → In Force has one non-conflicting set of criteria matching the current post-W9 state.
