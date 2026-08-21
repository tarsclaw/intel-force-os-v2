Reading prompt from stdin...
OpenAI Codex v0.132.0
--------
workdir: /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
model: gpt-5.5
provider: openai
approval: never
sandbox: workspace-write [workdir, /tmp, $TMPDIR]
reasoning effort: none
reasoning summaries: none
session id: 019eb1ea-6931-73a2-95dc-753edc8ab9a0
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

Path: agents/recruitment/janitor/agent.md

--- BEGIN ARTEFACT ---

# Janitor — the wedge agent

**Status:** Proposed (W6-7 build slice COMPLETE on this branch; status flip founder-gated per §10).
**Build state:** W6-7 build slice COMPLETE (spec-001; branch `worktree-agent-abb2ffb971bb471ba`, 2026-06-10) — all 6 sibling bundle files (`cycle.sh` 12 steps + `validate.sh` Gate A G1-G7 + `context.sh` + `cleanup.sh` + `tools.yaml` + `README.md`) + 3 fixtures LIVE/BUILT; build-gate GREEN; three deterministic DB-backed fixture suites green (`scripts/run-janitor-{dedup,gate-a,report}-test.sh`). Fixture-proven only: zero live Bullhorn calls have ever been made by this bundle (all six `BULLHORN_*` creds EMPTY per names-only re-verification 2026-06-10; live smoke founder-gated). Companies House is the one live-capable path (key SET; live-smoked once, read-only). Prior contract history: Day-20 W4 bilateral pass; R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority; R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4; R19 (2026-05-25): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Still awaits: Q1 LOI + Bullhorn Sub-decision B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + live Bullhorn credentials + Codex re-ratification of the built bundle + founder approvals per §10.
**Reading-discipline note (updated 2026-06-10 at W6-7 build; originally added 2026-06-03 per Codex Fbis-R3 closure pattern + CC + Concierge precedent):** this `agent.md` is the **CONTRACT** that the W6-7 build slice implemented against. The 6 sibling bundle files + 3 fixtures are **LIVE** — the W6-7 build slice (spec-001, this branch; commits `184a2bf` + `4ceccbc` + `2938b20` + `30bdff8`) replaced every `TODO(W6-7)` marker with live implementation; the three DB-backed fixture suites are green under build-gate. **Per-component build state, honestly stated:** `@ifos/bullhorn` — implemented connector package + built `dist/cli.js` bridge (`packages/mcp-connectors/bullhorn`, v0.1.0; typecheck clean; vitest 52/52; generic `update-entity` for Candidate|ClientContact|JobOrder|Placement + extended `create-note` per the agreed CLI contract). Live credentials are the ONLY gap on that path: with creds EMPTY the agent runs DEGRADED — Step 2 scans the Postgres `entities` Bullhorn cache instead of the live API; all coverage is fixture-driven (`IFOS_JANITOR_FIXTURE_*`). `@ifos/companies-house` — live-capable (key SET); smoked once read-only via `bin/ch-lookup.mjs` (HAYS PLC → CRN 02150950, source_confidence 0.9). **Runtime-audit truth (W6-7 behaviour):** the three yellow-tier action rows the contract names (`bullhorn_candidate_dedupe` + `bullhorn_field_backfill` + `bullhorn_note_attach`) ARE emitted at runtime — cycle.sh Step 9 validates each proposal through validate.sh, then emits `hh_decision_action "${_jn_atype}"` (cycle.sh lines 703-704) with per-type tallies at lines 705-709 and the `bullhorn_write_batch` summary row at lines 711-712. Until creds land, each row carries `write_state:deferred` in its reason (the batch summary tallies them as `deferred_no_creds:<N>`); the Gate-A-validated decision is real and audited, the transport is honestly deferred, never faked — post-creds the same rows carry `write_state:applied`. `context.sh` uses the canonical RLS-scoped `SELECT config->>'<key>' FROM tenant_adapters` path (v0.4 supplement LIVE on VPS per commit `a1bbcf6`), with `IFOS_FORCE_*` env fallbacks retained for fixtures/local-dev only. **Voice honesty:** no embedding classifier ships at v1.0 — Step 8 emits `unscored/no_corpus` (or `classifier_unavailable` when a corpus is active) rather than a faked score; validate.sh G5 is hard-when-scored / warn-when-unscored. LinkedIn (§4 Step 7) is an explicit NO-OP audit row (`linkedin_enrichment_skipped`). §10 lifecycle status remains **Proposed** pending Codex re-ratification of the built bundle + founder approvals — the status flip is founder-gated.
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
**Build complexity:** L (2 weeks) per ULTRAPLAN A2 line 512.
**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.2 (lines 105-116; §2.1 is the Diagnostic section).

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any AUTO-MERGE proposal with confidence <0.85 (per ULTRAPLAN A2 line 510) — Gate A's merge-confidence check applies to auto-merge proposals ONLY; held and dropped pairs are classified upstream at §4 Steps 3-4 per the spec-001 band→action table (≥0.85 + no 90d activity → auto-merge; 0.70–0.85 OR ≥0.85-with-recency → held via ESC_DUPLICATE_DETECTED; <0.70 → silent drop) and never reach Gate A. Gate B success threshold: ≥15% dedup AND ≥10% field-completeness — two independent thresholds, both must pass. SHIPPED v1.0 metric (cycle.sh Step 10, header lines 716-724 + computation lines 755-762): deterministic in-run `decision_log`-derived ratios — `dedup_pct = 100·merges/(merges + review-band pairs)`, `completeness_pct = 100·backfills/(backfills + still-missing rows)`. Explicit limitation: this is NOT yet measured against the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511) — no day-0 baseline exists yet; baseline-relative measurement is the documented post-pilot enhancement (accepted build deviation 6; captured at pilot onboarding per §9 Q6). Auto-band Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks, no synchronous approval; review-band dedup merges (0.70–0.85 confidence, or ≥0.85 with Bullhorn activity in the last 90 days) are instead held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before write. Every write emits a per-write audit row to `decision_log` with `agent_name='janitor'`.

---

## §2 — Invocation surface

### Cron (v1.0)

```bash
# /etc/cron.daily/ifos-janitor → calls this script per tenant
0 2 * * * sudo -u ifos_user /usr/local/bin/ifos-janitor.sh --tenant <slug>
```

Resolved by cortextOS daemon → spawns Janitor in Tier-2 batch mode (no persistent PTY). Typical runtime per tenant: 15-45 min depending on Bullhorn corpus size.

### Manual trigger (v1.0 — operator convenience)

```bash
ifosctl janitor --tenant <slug> [--dry-run] [--report-only]
```

`--dry-run` reports what WOULD be written without touching Bullhorn. `--report-only` regenerates the day-30 report without doing dedup/enrichment passes (used post-incident for manual report regeneration).

### v1.1+ surfaces (deferred)

- Brain UI "Run Janitor now" button → triggers via internal API
- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold` — declared in `vertical-schema.v0.3-supplement.yaml §4 tenant_adapters_config_additions.janitor_dedup_threshold`; enforced by `migrations/v0.2-to-v0.3.sql §5` validator allowlist)

---

## §3 — Output shape

Two outputs per run. Both are load-bearing artefacts.

### Output 1 — Day-30 Markdown report

Located at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`. Eight sections:

| # | Section | Content |
|---|---|---|
| 1 | **Record counts** | Total candidates / contractors / clients / contacts / placements / opportunities before + after this run; deltas per entity type |
| 2 | **Dedup pairs** | List of duplicate candidate AND contractor pairs identified this run; for each pair: entity type (candidate / contractor — separate types per vertical-schema.yaml §1), `bullhorn_id`, match dimensions (name + email + phone + LinkedIn), confidence score, action taken (auto-merged ≥0.85 / approval-gated 0.70–0.85 via ESC_DUPLICATE_DETECTED / dropped <0.70) |
| 3 | **Field-completeness deltas** | Per entity-type table: which fields were filled in (e.g., candidate.location, contractor.day_rate); source of the backfill (Companies House lookup, LinkedIn enrichment, derivation from related entities) |
| 4 | **Tacit-note coverage** | Notes harvested from `recent_edit` table rows with `resolution='approved_after_edit'` (per v0.2-supplement.yaml recent_edit definition; v0.3 supplement §2a grants Janitor R access); attached to relevant Bullhorn entities; coverage rate over the 30-day window |
| 5 | **Agent vs. consultant attribution** | Rows attributed to Janitor automated work vs consultant manual entry; supports the day-30 before/after narrative |
| 6 | **Gate-B metric** | TWO independent thresholds per ULTRAPLAN A2 line 511 verbatim: dedup improvement ≥15% AND field-completeness improvement ≥10%. Both must pass. NOT a composite score — that would let one threshold cover for the other. |
| 7 | **Exception list** | Failed writes (Bullhorn 4xx/5xx, FK violations); rate-limit hits; dedup proposals flagged for review (confidence between 0.7-0.85); operator action items |
| 8 | **Executive summary** | 200-word narrative suitable for forwarding to the tenant's hiring leader; cites top-3 cleanup wins; quantifies time saved (hours of consultant data-entry work avoided) |

### Output 2 — Bullhorn writes (yellow tier)

Three write categories. Action types map to existing entries in `agents/_shared/autosend-policy.yaml` (all three below are already registered there as yellow-tier):

1. **Candidate / contractor merge** (`PUT /Candidate/{primary_id}` + cascade; candidate and contractor are separate entity types per vertical-schema.yaml §1 but share the §4 Steps 3-4 fuzzy-matcher) — auto-merged only when confidence ≥0.85 AND neither record had Bullhorn activity in the last 90 days (per ULTRAPLAN A2 line 510 verbatim); pairs in the 0.70–0.85 review band, or ≥0.85 with recent activity, are held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before any write. Action type: **`bullhorn_candidate_dedupe`** with `payload.entity_type ∈ {candidate, contractor}` discriminating the two — reused rather than a separate contractor action_type (same yellow tier + matcher; registered in `agents/_shared/autosend-policy.yaml` under §YELLOW action_types; yellow tier; sample_rate: 10).
2. **Field backfill** (`PATCH /Candidate/{id}` or `/Client/{id}`) — fills missing canonical schema fields (per `vertical-schema.yaml`): `candidate.location` (line 124), `client.industry` (line 238), `client.size_employees` (line 243), `client.companies_house_number` (line 252), `contractor.day_rate_min/day_rate_max` (lines 193-197), `brief.salary_min/salary_max` (lines 371-376) from Companies House (for clients) or LinkedIn/derivation (for candidates). Sources logged in payload. Action type: **`bullhorn_field_backfill`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 10).
3. **Tacit-note attach** (`POST /Note` linked to entity) — narrative summary of consultant edits + decision-log resolutions over the 30-day window. Action type: **`bullhorn_note_attach`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 20).

Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.

---

## §4 — Workflow

12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.

```
0. Session start
   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice corpus
     (used for tacit-note attribution) + recent edits (for note harvest)
   → hh_decision_trigger("session_start", "janitor nightly cron")

1. Bullhorn auth refresh
   → bullhorn.refresh_access_token() per per-agent 8-min refresh loop
     (bullhorn-integration-path.md §4.5)
   → ESC_BULLHORN_AUTH if refresh fails after 2 retries

2. Bullhorn entity scan (read-only)
   → enumerate candidates + contractors + clients + contacts + placements +
     opportunities created/modified since last Janitor run (last_run_at in
     tenant_adapters.config.janitor_last_run — declared in vertical-schema
     v0.3 supplement §4 tenant_adapters_config_additions.janitor_last_run;
     enforced by migrations/v0.2-to-v0.3.sql §5 validator allowlist)
   → hh_decision_output("janitor_scan", "tenant:<slug>", "<N> entities scanned")
   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per ESC_RATE_LIMIT_HIT catalogue §2.5 standard handling)

3. Dedup pass — candidate entity type
   → matcher: bin/dedup-pairs.sh (pure-jq deterministic helper; declared in
     tools.yaml as capability `janitor_dedup_matcher`)
   → fuzzy-match across (name, email, phone, linkedin_url) tuples
   → compute confidence per pair: name × 0.3 + email × 0.4 + phone × 0.2 + linkedin × 0.1
     (comparable-weight normalisation + required strong identifier per build
     deviation 1)
   → classify per the spec-001 §4 band→action table (the ONE model §1/§5/§6 cite):
     · ≥0.85 AND no Bullhorn activity on EITHER record in last 90d (per
       ULTRAPLAN A2 line 510) → AUTO-MERGE proposal (yellow tier; written at
       Step 9 behind Gate A)
     · 0.70–0.85, OR ≥0.85 with recent (or unknown) 90d activity → HELD for
       synchronous Telegram approval via ESC_DUPLICATE_DETECTED (SUCCESS-path
       approval gate, NOT a Gate A failure)
     · <0.70 → silent drop (tallied in the dedup_candidate_pass marker reason)
   → batch auto-band pairs into proposed-merge list (in-memory intermediate;
     not persisted — hh_decision_action emitted at Step 9 when each merge
     actually writes)

4. Dedup pass — contractor entity type
   → same algorithm as candidates (same bin/dedup-pairs.sh matcher + band
     table); separate entity_type per Q1 Day-6 resolution (vertical-schema.yaml §1)

5. Field completeness audit (canonical field names per vertical-schema.yaml)
   → for each entity, check critical fields: candidate.location (line 124),
     client.industry (line 238), client.size_employees (line 243),
     contractor.day_rate_min/day_rate_max (lines 193-197),
     brief.salary_min/salary_max (lines 371-376)
   → identify missing-field rows
   → batch enrichment calls
   → hh_decision_output("field_completeness_audit", tenant, "<N> missing-field rows")

6. Companies House enrichment (clients only)
   → tools.yaml capabilities `companies_house_search` (client.name per
     vertical-schema.yaml line 235 → CRN) + `companies_house_get_company`
     (CRN → profile) on @ifos/companies-house, invoked via bin/ch-lookup.mjs
     → fill canonical schema fields client.industry (line 238),
     client.companies_house_number (line 252)
   → 7-day cache + shared 600/5min rate budget live INSIDE the connector
     (Diagnostic precedent); budget shared with Diagnostic
   → ESC_RATE_LIMIT_HIT on 429

7. LinkedIn enrichment (candidates; v1.1 via Proxycurl)
   → at v1.0: skipped (LinkedIn deep data deferred to W4 polish; Proxycurl
     signup commercial decision)
   → at v1.1: linkedin.profile_fetch(candidate.linkedin_url) → location +
     current_company → write back

8. Tacit-note harvest
   → query the `recent_edit` v0.2 table directly (per vertical-schema.v0.2-supplement.yaml
     recent_edit definition; v0.3 supplement §2a grants Janitor R access):
     SELECT FROM recent_edit WHERE resolved_at > now() - interval '30 days'
     AND resolution='approved_after_edit' AND tenant_slug=$tenant
   → join to decision_log only if action-context lookups needed
   → group by target_entity_type (candidate / contractor / contact / brief / etc.)
   → for each group, generate narrative summary via voice-classified LLM
     (voice corpus + tone rules; ESC_VOICE_DRIFT if classifier <0.75)
   → hh_decision_output("janitor_tacit_note_harvest", "tenant:<slug>",
     "harvested:<N> rows; groups:<M> entity-types; narrative_drafts:<K>")
   → on classifier fail after retries: hh_decision_action("validate_gate_a_fail",
     "tenant:<slug>", payload_hash, "ESC_VOICE_DRIFT; classifier_score:<N>")

9. Bullhorn write batch (yellow tier — spot-check sampling)
   → for each proposed merge / backfill / note: emit hh_decision_action with
     tier='yellow'; spot-check sample rate per autosend-policy.yaml row
   → atomic per-write transaction (BEGIN/COMMIT)
   → on 4xx: emit ESC_BULLHORN_WRITE_FAIL; skip; continue
   → on 5xx: emit ESC_BULLHORN_WRITE_FAIL; retry once with 30s backoff

10. Day-30 report assembly
   → SELECT from decision_log WHERE agent_name='janitor' AND created_at >
     now() - interval '30 days' AND tenant_slug=$tenant
   → group by action_type; tally success/fail; compute Gate-B metric
   → 8-section Markdown report (per §3 above)
   → write to /vault/<tenant>/janitor-reports/day-30-<ISO-date>.md
   → hh_decision_output("day_30_report", "<path>", "Gate-B score: <N>")

11. Operator notification (Telegram)
   → if Gate-B target met: green-tier notification with summary
   → if Gate-B target missed: yellow-tier notification + 200-char executive
     summary suggesting consultant follow-up
   → hh_decision_action("operator_notify_telegram", "tenant:<slug>",
     notification_hash, "gate_b_state:met|missed; chars:<N>")

12. Session close
   → update tenant_adapters.config.janitor_last_run = now()
   → hh_decision_action("janitor_run_complete", "tenant:<slug>", payload_hash, payload_preview)
   → exit code 0 (or 1 if BOTH Gate-B thresholds missed for 3 consecutive runs per §5 + catalogue → ESC_GATE_B_MISS)
```

### Audit coverage — consolidated model (per master brief §8.1 Change 2)

Every step that produces output or takes action audits to `decision_log` — but
not every step carries its OWN `hh_decision_*` row; two clusters consolidate
(deliberate, one model):

- **Step 1 failures** audit via the per-run `bullhorn_auth_refresh` output row
  (token state recorded every run) plus the `ESC_BULLHORN_AUTH` gating row on
  refresh failure or creds absence. There is no separate Step-1
  `hh_decision_action` row.
- **Steps 3-4 outcomes** audit downstream: AUTO-band pairs become the Step 9
  `bullhorn_candidate_dedupe` yellow action rows when each merge actually
  writes; HELD pairs each emit an `ESC_DUPLICATE_DETECTED` gating row at
  Steps 3-4 (catalogue §2.5 payload shape; also listed in the day-30 report §7
  exception list); DROPPED (<0.70) pairs are tallied in the
  `dedup_candidate_pass` / `dedup_contractor_pass` marker reasons
  (`dropped:<N>`) with batch outcomes summarised in `bullhorn_write_batch`.
  No held or dropped outcome is traceless.

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Janitor's `validate.sh` enforces:

- Bullhorn auth refresh succeeded in Step 1 (no stale token writes)
- Every AUTO-MERGE proposal has confidence ≥ 0.85 per ULTRAPLAN A2 line 510 (G2 — applies to auto-merge proposals ONLY; review-band pairs are held upstream at §4 Steps 3-4 and never reach Step 9, so this check is defence-in-depth against a band-classification bug, not the band mechanism itself)
- No auto-merge proposal where EITHER record has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim; G3 — same defence-in-depth scope as G2)
- No field-backfill where source confidence <0.7 (CH 404 / LinkedIn empty / no derivation source)
- Tacit-note narratives pass voice classifier ≥ 0.75
- Bullhorn write batch size ≤ 100 per minute (rate-limit defensive)
- No PII outside firm boundary in tacit-note narratives (regex pass)

Gate A failure routing by class (per catalogue §2.5):
- PII detected outside firm boundary → `ESC_PII_LEAKAGE_RISK` (blocking; operator + ifos_oncall per catalogue routing)
- Tacit-note voice classifier <0.75 → `ESC_VOICE_DRIFT` (warn; operator_chat_id)
- Tone-rule violations → `ESC_TONE_RULE_VIOLATION` (warn; operator_chat_id per catalogue §2.10)
- Output-shape failures (section count, write-batch size, dedup confidence below threshold for action) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)

`ESC_DUPLICATE_DETECTED` (catalogue §2.5) is NOT a Gate A failure code — per catalogue trigger it's the SUCCESS-path Telegram approval gate for dedup pairs that need human approval before merge: the 0.70–0.85 review band, plus any ≥0.85 pair where a record has Bullhorn activity in the last 90 days. Pairs ≥0.85 with no recent activity auto-merge (yellow tier, spot-check) and do NOT fire it. Sub-0.70 confidence pairs silently drop in the Step 3 algorithm; no ESC fire. `ESC_SCHEMA_VIOLATION` (catalogue line 163) is NOT used by Janitor — reserved for vertical-schema field-constraint violations at write-time.

### Gate B — Outcome threshold (success metric, not block)

Per ULTRAPLAN A2 line 511 verbatim: **"day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement"**.

Two independent thresholds (both must pass): dedup improvement ≥15% AND field-completeness improvement ≥10%. NOT a composite — composite would let one cover the other.

**Shipped v1.0 measurement (W6-7 build; accepted deviation 6):** the live cycle.sh computes the two thresholds as deterministic in-run `decision_log`-derived ratios, not against a day-0 baseline — `dedup_pct = 100·merges/(merges + review-band pairs)` and `completeness_pct = 100·backfills/(backfills + still-missing rows)` (cycle.sh Step 10: header comment lines 716-724, computation lines 755-762; definitions printed in report §6). **Limitation, explicit:** ULTRAPLAN's "before/after vs day-0 baseline" semantics are NOT implemented yet because no day-0 baseline exists pre-pilot — the baseline is captured at first pilot onboarding (per §9 Q6), and baseline-relative Gate B measurement is the documented post-pilot enhancement. The thresholds (≥15% / ≥10%), the AND-logic, and the 3-consecutive-both-missed → `ESC_GATE_B_MISS` trigger are unchanged.

Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.

Per catalogue `escalation-codes.md` ESC_GATE_B_MISS trigger (Janitor example: "dedup confidence <15% AND field-completeness uplift <10%"): `ESC_GATE_B_MISS` fires only when BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND completeness-improvement <10%) → flag for operator review (heuristic tuning may be needed; not a kill). Single-threshold misses are tracked in the day-30 report (§3 Output 1 row 6) and inform tenant-level quality review but do NOT fire ESC. Sensitivity choice: strict AND-trigger reduces false alarms; tightening to OR-trigger requires a catalogue amendment + re-ratification.

---

## §6 — Escalation codes

All codes are registered in `agents/_shared/escalation-codes.md` (catalogue extended to 52 codes per `2026-05-24` bilateral disposition; see disagreement-doc + `catalogue(bilateral)` commit).

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on merge/backfill/note write | warn | operator_chat_id |
| `ESC_RATE_LIMIT_HIT` | Bullhorn or Companies House 429 | warn | operator_chat_id |
| `ESC_VOICE_DRIFT` | Tacit-note narrative voice classifier <0.75 (after 3 retries) | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII detected in tacit-note outside firm boundary | **blocking** | operator + ifos_oncall |
| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (section count or per-section citation missing in day-30 report) | warn | operator_chat_id |
| `ESC_DUPLICATE_DETECTED` | Per catalogue §2.5 (amended 2026-06-10): dedup pairs needing human approval before merge — the 0.70–0.85 review band, plus ≥0.85 pairs with recent Bullhorn activity (SUCCESS path; Telegram approval gate fires). NOT a Gate A failure code. Payload per catalogue: `entity_a_id` / `entity_b_id` / `entity_type` (`candidate`\|`contractor`) / `confidence_score` / `match_basis` (e.g. `email+phone`) / `hold_reason` (`review_band` \| `recency_hold_90d`). | warn | operator_chat_id (via Telegram approval gate per catalogue routing) |
| `ESC_GATE_B_MISS` | Per catalogue trigger: per-agent local Gate B metric threshold missed. For Janitor: BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND field-completeness-improvement <10%) per catalogue `ESC_GATE_B_MISS` Janitor example. Single-threshold misses do NOT fire (per §5 Gate B). Catalogue routing: operator_chat_id | warn | operator_chat_id |
| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |

Janitor does NOT use:

- `ESC_VOICE_DRIFT_TENANT` — fired by nightly voice-drift cron (per `escalation-codes.md` line 170-175 trigger: ≥N `ESC_VOICE_DRIFT` rows from same tenant in rolling 7d window). Janitor only fires the per-run `ESC_VOICE_DRIFT`; aggregate `_TENANT` rollup is handled by the canary not Janitor.
- `ESC_AUTOSEND_BLOCKED` — that's for red-tier blocks (`escalation-codes.md` line 41); Janitor writes are yellow tier only
- **OAuth-token revocation** — there is no separate `ESC_BULLHORN_OAUTH_REVOKED` catalogue code; revocation is folded into `ESC_BULLHORN_AUTH` via `payload.failure_type='revoked_401'` (per concierge §6 + catalogue). Janitor fires `ESC_BULLHORN_AUTH` (listed above) on any refresh/revocation failure
- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction

---

## §7 — Voice + tone constraints

Step 8 (tacit-note narrative generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
  - No identifying language about candidates beyond what's in their CV / Bullhorn record
  - No commercial sensitive information (rates / placement fees / commission %)
  - No external-party PII (clients of clients)
- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Build dependencies — actual state (refreshed 2026-06-10 post-W6-7 build)

The W6-7 build slice is COMPLETE on this branch. The table below distinguishes three states precisely: **BUILT** (code exists, tests green), **fixture-proven** (behaviour verified against deterministic fixtures/DB suites, no live API call), and **live-credential-gated** (everything but the credential is in place; founder action).

| Dependency | Source | Status (2026-06-10) |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ ratified |
| Diagnostic first-agent precedent | `agents/recruitment/diagnostic/` | ✅ v0 BUILT + wired (its own lifecycle tracked in its agent.md) |
| First pilot tenant onboarded (provision-tenant.sh) | Post Q1-LOI | ⏸ Founder action |
| **Bullhorn Sub-decision A** | `docs/decisions/bullhorn-integration-path.md` | ✅ RESOLVED 2026-06-02 — direct API per-tenant OAuth; marketplace deferred to v1.1+ |
| **Bullhorn Sub-decision B** | Bullhorn developer-support route (`developer.bullhorn.com`) | ⏸ in flight; founder submitted 2026-06-02 |
| `@ifos/bullhorn` connector + CLI bridge | `packages/mcp-connectors/bullhorn` (v0.1.0, `dist/cli.js`) | ✅ BUILT — typecheck clean; vitest 52/52; `update-entity` (Candidate\|ClientContact\|JobOrder\|Placement) + extended `create-note` per the agreed CLI contract; zero live API calls made |
| Bullhorn live credentials (client_id + client_secret + tenant OAuth) | Tenant pilot OAuth ticket | ⏸ EMPTY — all six `BULLHORN_*` keys (names-only re-verified 2026-06-10); founder-gated; **the ONLY gap between fixture-proven and live on the Bullhorn path** |
| Companies House MCP connector | Day-13 shipped (`@ifos/companies-house`) | ✅ BUILT + live-capable (key SET); live-smoked once read-only via `bin/ch-lookup.mjs` (HAYS PLC → CRN 02150950) |
| Tenant `target_patch.json` + `_secrets.env` provisioned | provision-tenant.sh ran for first pilot | ⏸ Post-LOI |
| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ Post-LOI. No embedding classifier ships at v1.0 — Step 8 emits honest `unscored/no_corpus`; G5 warn-when-unscored (never a faked score) |
| `validate.sh` Gate A logic (G1-G7) | This branch (commit `184a2bf`) | ✅ LIVE — all 7 checks enforced; gate-a suite green (4 pass + 8 fail classes) |
| `context.sh` hydration | This branch (commit `184a2bf`) | ✅ LIVE — canonical RLS-scoped `tenant_adapters` SELECT path; `IFOS_FORCE_*` fallbacks retained for fixtures only |
| `cycle.sh` orchestration (12-step) | This branch (commit `184a2bf`) | ✅ LIVE — all 12 steps; fixture-proven end-to-end against the local dev DB (full smoke under a throwaway tenant) |
| Dedup heuristic + confidence scorer | `bin/dedup-pairs.sh` | ✅ LIVE — deterministic pure-jq; dedup suite green |
| 3 fixtures + DB-backed suites | `fixtures/` + `scripts/run-janitor-{dedup,gate-a,report}-test.sh` | ✅ green (`01-primary`, `02-edge-case-fuzzy-match`, `99-recent-activity-blocked`) |
| LinkedIn enrichment | §4 Step 7 | — NO-OP at v1.0 (explicit `linkedin_enrichment_skipped` audit row; vendor selection deferred to v1.1+) |

**The remaining ⏸ items no longer gate the build (done); they gate LIVE operation:** the Bullhorn live smoke (refresh → scan → one sandbox write through Steps 1-2-9) and pilot onboarding are founder-gated post-creds steps. Kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) context preserved for history: Bullhorn auth was not cleared in W5; the build proceeded fixture-first in W6-7 per spec-001 §8's honest-scope disposition (creds EMPTY, founder-gated; writes recorded as deferred, never faked) rather than deferring the agent.

---

## §9 — Status + open questions

**Status:** Proposed (W6-7 build slice COMPLETE on this branch; status flip founder-gated per §10). Still awaits: Bullhorn Sub-decision B (A RESOLVED 2026-06-02) + live Bullhorn credentials + Q1 LOI + Codex re-ratification of the built bundle + founder approvals below.

### Open questions for founder review

| # | Question | Resolution path |
|---|---|---|
| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
| Q2 | Field-completeness priority order — which missing fields are highest-impact to backfill first? | Founder review with first pilot tenant; varies by tenant focus (perm vs contract). |
| Q3 | Bullhorn write batch size — current default 100/min. Bullhorn published rate-limit isn't documented; we may need to negotiate. | Bullhorn commercial conversation Sub-decision B output. |
| Q4 | Tacit-note attribution — should notes attribute to "Intel Force OS Janitor" or just "Internal note"? Tenant brand preference. | Per-tenant config at first-pilot onboarding. |
| Q5 | Day-30 report distribution path — vault only OR also forwarded to tenant's hiring leader via email? | v1.0: vault only. v1.1: opt-in email forward via Concierge. |
| Q6 | Gate B exception handling — what if a tenant's day-0 baseline is already exceptionally clean (low headroom for improvement)? | Founder review at first 3-tenant cohort; may need per-tenant Gate B calibration. |

### Gotchas (carried forward from ULTRAPLAN A2 line 513)

1. **Bullhorn MCP server — RESOLVED at W6-7.** Originally "doesn't exist yet; critical-path build for v1.0" (per ULTRAPLAN A2 line 513). The `@ifos/bullhorn` connector package + `dist/cli.js` bridge are now BUILT (vitest 52/52); the remaining critical-path item is live credentials (founder-gated), not code.
2. **Dedup is hard; start conservative.** High-confidence merges only (≥0.85); tune up the threshold over time as data builds.
3. **Bullhorn webhook coverage is patchy** (per ULTRAPLAN A6 line 569 — Concierge note applies cross-agent). Janitor relies on polling not webhooks; safer for nightly cron pattern.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.

Status flips Proposed → Accepted (pre-build) when:
- Codex Round 4 Phase 2 ratifies
- Founder approves §9 open questions Q1 + Q2 + Q4 + Q5 + Q6
- Q3 resolves via Bullhorn Sub-decision B answer

Status flips Accepted → In Force when:
- ~~W5 build slice produces all 5 sibling bundle files + 3 fixtures~~ **SATISFIED 2026-06-10** — the W6-7 build slice (spec-001, this branch) shipped all 6 sibling bundle files + 3 fixtures LIVE; build-gate GREEN
- First production run against migration-test tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row) — pending; blocked on live Bullhorn credentials (founder-gated)
- Day-30 baseline measured for first pilot tenant — pending; post-LOI
- Codex re-ratifies post-build via `review-agent-bundle.md` skill — in progress on this branch

Current position (2026-06-10): the contract below is IMPLEMENTED — the bundle is built and fixture-proven, not production-proven (zero live Bullhorn calls). The §10 status field stays **Proposed** until the founder flips it; the flip is founder-gated, not Claude's call.

*End of Janitor agent.md draft.*

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
I’m going to verify the Janitor contract against the referenced source files and sibling bundle, focusing on citations, gates, escalation codes, and boundary rules before deciding ratify/reject.
exec
/bin/zsh -lc 'rg -n "bullhorn_candidate_dedupe|bullhorn_field_backfill|bullhorn_note_attach|operator_notify_telegram|janitor_run_complete|validate_gate_a_fail|sample_rate|yellow" agents/_shared/autosend-policy.yaml docs/decisions/autosend-safety-policy.md' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:8:# 47 v1.0 action_types: 19 green + 10 yellow + 10 orange + 8 red.
agents/_shared/autosend-policy.yaml:10:#   tier            green|yellow|orange|red
agents/_shared/autosend-policy.yaml:13:#   sample_rate     yellow only: 1-in-N for spot-check sampling
agents/_shared/autosend-policy.yaml:65:  operator_notify_telegram:
agents/_shared/autosend-policy.yaml:71:  janitor_run_complete:
agents/_shared/autosend-policy.yaml:98:    reason: "Status marker recorded AFTER an external send completes (the send itself was a different orange/yellow action_type with its own decision_log row); this row closes the workflow trace"
agents/_shared/autosend-policy.yaml:119:  validate_gate_a_fail:
agents/_shared/autosend-policy.yaml:191:  bullhorn_candidate_dedupe:
agents/_shared/autosend-policy.yaml:192:    tier: yellow
agents/_shared/autosend-policy.yaml:194:    sample_rate: 10
agents/_shared/autosend-policy.yaml:198:  bullhorn_field_backfill:
agents/_shared/autosend-policy.yaml:199:    tier: yellow
agents/_shared/autosend-policy.yaml:201:    sample_rate: 10
agents/_shared/autosend-policy.yaml:205:  bullhorn_note_attach:
agents/_shared/autosend-policy.yaml:206:    tier: yellow
agents/_shared/autosend-policy.yaml:208:    sample_rate: 20
agents/_shared/autosend-policy.yaml:213:    tier: yellow
agents/_shared/autosend-policy.yaml:215:    sample_rate: 20
agents/_shared/autosend-policy.yaml:220:    tier: yellow
agents/_shared/autosend-policy.yaml:222:    sample_rate: 5
agents/_shared/autosend-policy.yaml:227:    tier: yellow
agents/_shared/autosend-policy.yaml:229:    sample_rate: 10
agents/_shared/autosend-policy.yaml:234:    tier: yellow
agents/_shared/autosend-policy.yaml:236:    sample_rate: 10
agents/_shared/autosend-policy.yaml:241:    tier: yellow
agents/_shared/autosend-policy.yaml:243:    sample_rate: 10
agents/_shared/autosend-policy.yaml:248:    tier: yellow
agents/_shared/autosend-policy.yaml:250:    sample_rate: 10
agents/_shared/autosend-policy.yaml:255:    tier: yellow
agents/_shared/autosend-policy.yaml:257:    sample_rate: 20
agents/_shared/autosend-policy.yaml:402:  min_sample_rate: 100          # Tenants cannot set sample rate above 1-in-100 per §8 rule 6
agents/_shared/autosend-policy.yaml:411:  - "tier ∈ {green, yellow, orange, red}"
agents/_shared/autosend-policy.yaml:412:  - "yellow action_types MUST declare sample_rate (positive integer)"
agents/_shared/autosend-policy.yaml:415:  - "tenant overrides may only ELEVATE tier (green→yellow→orange→red); red is floor"
agents/_shared/autosend-policy.yaml:416:  - "47 total action_types (19 green + 10 yellow + 10 orange + 8 red); v1.0 frozen as of 2026-05-24 bilateral-disposition extension"
docs/decisions/autosend-safety-policy.md:55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
docs/decisions/autosend-safety-policy.md:90:| Agent | action_type | Sample rate | Why yellow |
docs/decisions/autosend-safety-policy.md:92:| Janitor | `bullhorn_candidate_dedupe` | 1-in-10 | Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review |
docs/decisions/autosend-safety-policy.md:178:    yellow)
docs/decisions/autosend-safety-policy.md:179:      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:222:  - bullhorn_note_draft_internal     # yellow (sample 1-in-10)
docs/decisions/autosend-safety-policy.md:380:--   phase = 'action'         when allowed (green/yellow/orange-approved)
docs/decisions/autosend-safety-policy.md:384:--     "tier": "green|yellow|orange|red|fail-safe-red",
docs/decisions/autosend-safety-policy.md:433:      "bullhorn_note_internal": "yellow",
docs/decisions/autosend-safety-policy.md:435:      "bullhorn_candidate_dedupe": "orange"
docs/decisions/autosend-safety-policy.md:451:      "bullhorn_candidate_dedupe": 1,
docs/decisions/autosend-safety-policy.md:461:1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
docs/decisions/autosend-safety-policy.md:466:6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
docs/decisions/autosend-safety-policy.md:493:- **Adaptive tiering:** ML-driven tier adjustment based on incident history. E.g., if `linkedin_connection_request` shows 0 false-blocks over 90 days, automatically propose downgrade from orange to yellow.
docs/decisions/autosend-safety-policy.md:511:classifies each agent action into one of four tiers: green, yellow,
docs/decisions/autosend-safety-policy.md:522:  (b) any action classified as yellow that passed spot-check review or
docs/decisions/autosend-safety-policy.md:600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
docs/decisions/autosend-safety-policy.md:621:- **Q5 (sampling rate defaults for yellow tier):** ACCEPTED for v1.0 with explicit operational-guess flag. Real sampling rates need pilot data; current defaults (1-in-5 to 1-in-20 per `action_type` in §3) are operational guesses calibrated by analogy to typical CRM audit-sampling practice. Refinement happens once first pilot generates 4+ tenant-weeks of yellow-tier action volume.

exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_AUTH|ESC_BULLHORN_WRITE_FAIL|ESC_RATE_LIMIT_HIT|ESC_VOICE_DRIFT|ESC_PII_LEAKAGE_RISK|ESC_AGENT_OUTPUT_SHAPE|ESC_DUPLICATE_DETECTED|ESC_GATE_B_MISS|ESC_AUTOSEND_SAMPLED_SPOT_CHECK|ESC_SCHEMA_VIOLATION|ESC_TONE_RULE_VIOLATION|ESC_VOICE_DRIFT_TENANT" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
97:#### `ESC_BULLHORN_AUTH`
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
149:#### `ESC_PII_LEAKAGE_RISK`
157:#### `ESC_RATE_LIMIT_HIT`
164:#### `ESC_SCHEMA_VIOLATION`
171:#### `ESC_VOICE_DRIFT_TENANT`
173:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
185:#### `ESC_AGENT_OUTPUT_SHAPE`
187:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
233:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
311:#### `ESC_BULLHORN_WRITE_FAIL`
313:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
367:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
378:#### `ESC_GATE_B_MISS`
386:#### `ESC_TONE_RULE_VIOLATION`

exec
/bin/zsh -lc "pwd && rg --files | rg '("'^agents/recruitment/janitor/|agents/_shared/|docs/.*(master|ULTRAPLAN|kill|sequencing|bullhorn|autosend|vertical-schema)|vertical-schema|migrations/v0.2-to-v0.3.sql|ADR-003|ADR-004)'"'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
/Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
agents/_shared/README.md
docs/specs/ULTRAPLAN.md
docs/decisions/autosend-approval-bridge-spec.md
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
docs/decisions/autosend-safety-policy.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/sequencing-target.md
docs/decisions/bullhorn-integration-path.md
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
logs/codex-ratification/round-2-autonomous/docs_decisions_ADR-003-agent-bundle-renderer-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-v0-2-supplement-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md
docs/operations/bullhorn-outreach-emails.md
agents/recruitment/janitor/sql/day30-report-metrics.sql
agents/recruitment/janitor/sql/field-completeness.sql
agents/recruitment/janitor/cleanup.sh
agents/recruitment/janitor/fixtures/02-edge-case-fuzzy-match.yaml
agents/recruitment/janitor/fixtures/99-recent-activity-blocked.yaml
agents/recruitment/janitor/fixtures/01-primary.yaml
agents/recruitment/janitor/cycle.sh
agents/recruitment/janitor/README.md
agents/recruitment/janitor/tools.yaml
agents/recruitment/janitor/bin/ch-lookup.mjs
agents/recruitment/janitor/bin/render-tacit-note.sh
agents/recruitment/janitor/bin/dedup-pairs.sh
agents/recruitment/janitor/validate.sh
agents/recruitment/janitor/context.sh
agents/recruitment/janitor/agent.md

codex
The bundle files exist, so I’m treating this as a built-but-not-production-proven agent rather than a pre-build scaffold. I’m checking whether the documented Gate A/Gate B and action audit claims match the actual scripts, because those are load-bearing here.
exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/agent.md | sed -n '260,560p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
   260	| `ESC_PII_LEAKAGE_RISK` | PII detected in tacit-note outside firm boundary | **blocking** | operator + ifos_oncall |
   261	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (section count or per-section citation missing in day-30 report) | warn | operator_chat_id |
   262	| `ESC_DUPLICATE_DETECTED` | Per catalogue §2.5 (amended 2026-06-10): dedup pairs needing human approval before merge — the 0.70–0.85 review band, plus ≥0.85 pairs with recent Bullhorn activity (SUCCESS path; Telegram approval gate fires). NOT a Gate A failure code. Payload per catalogue: `entity_a_id` / `entity_b_id` / `entity_type` (`candidate`\|`contractor`) / `confidence_score` / `match_basis` (e.g. `email+phone`) / `hold_reason` (`review_band` \| `recency_hold_90d`). | warn | operator_chat_id (via Telegram approval gate per catalogue routing) |
   263	| `ESC_GATE_B_MISS` | Per catalogue trigger: per-agent local Gate B metric threshold missed. For Janitor: BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND field-completeness-improvement <10%) per catalogue `ESC_GATE_B_MISS` Janitor example. Single-threshold misses do NOT fire (per §5 Gate B). Catalogue routing: operator_chat_id | warn | operator_chat_id |
   264	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
   265	
   266	Janitor does NOT use:
   267	
   268	- `ESC_VOICE_DRIFT_TENANT` — fired by nightly voice-drift cron (per `escalation-codes.md` line 170-175 trigger: ≥N `ESC_VOICE_DRIFT` rows from same tenant in rolling 7d window). Janitor only fires the per-run `ESC_VOICE_DRIFT`; aggregate `_TENANT` rollup is handled by the canary not Janitor.
   269	- `ESC_AUTOSEND_BLOCKED` — that's for red-tier blocks (`escalation-codes.md` line 41); Janitor writes are yellow tier only
   270	- **OAuth-token revocation** — there is no separate `ESC_BULLHORN_OAUTH_REVOKED` catalogue code; revocation is folded into `ESC_BULLHORN_AUTH` via `payload.failure_type='revoked_401'` (per concierge §6 + catalogue). Janitor fires `ESC_BULLHORN_AUTH` (listed above) on any refresh/revocation failure
   271	- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction
   272	
   273	---
   274	
   275	## §7 — Voice + tone constraints
   276	
   277	Step 8 (tacit-note narrative generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   278	
   279	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
   280	  - No identifying language about candidates beyond what's in their CV / Bullhorn record
   281	  - No commercial sensitive information (rates / placement fees / commission %)
   282	  - No external-party PII (clients of clients)
   283	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
   284	- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
   285	
   286	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   287	
   288	---
   289	
   290	## §8 — Build dependencies — actual state (refreshed 2026-06-10 post-W6-7 build)
   291	
   292	The W6-7 build slice is COMPLETE on this branch. The table below distinguishes three states precisely: **BUILT** (code exists, tests green), **fixture-proven** (behaviour verified against deterministic fixtures/DB suites, no live API call), and **live-credential-gated** (everything but the credential is in place; founder action).
   293	
   294	| Dependency | Source | Status (2026-06-10) |
   295	|---|---|---|
   296	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ ratified |
   297	| Diagnostic first-agent precedent | `agents/recruitment/diagnostic/` | ✅ v0 BUILT + wired (its own lifecycle tracked in its agent.md) |
   298	| First pilot tenant onboarded (provision-tenant.sh) | Post Q1-LOI | ⏸ Founder action |
   299	| **Bullhorn Sub-decision A** | `docs/decisions/bullhorn-integration-path.md` | ✅ RESOLVED 2026-06-02 — direct API per-tenant OAuth; marketplace deferred to v1.1+ |
   300	| **Bullhorn Sub-decision B** | Bullhorn developer-support route (`developer.bullhorn.com`) | ⏸ in flight; founder submitted 2026-06-02 |
   301	| `@ifos/bullhorn` connector + CLI bridge | `packages/mcp-connectors/bullhorn` (v0.1.0, `dist/cli.js`) | ✅ BUILT — typecheck clean; vitest 52/52; `update-entity` (Candidate\|ClientContact\|JobOrder\|Placement) + extended `create-note` per the agreed CLI contract; zero live API calls made |
   302	| Bullhorn live credentials (client_id + client_secret + tenant OAuth) | Tenant pilot OAuth ticket | ⏸ EMPTY — all six `BULLHORN_*` keys (names-only re-verified 2026-06-10); founder-gated; **the ONLY gap between fixture-proven and live on the Bullhorn path** |
   303	| Companies House MCP connector | Day-13 shipped (`@ifos/companies-house`) | ✅ BUILT + live-capable (key SET); live-smoked once read-only via `bin/ch-lookup.mjs` (HAYS PLC → CRN 02150950) |
   304	| Tenant `target_patch.json` + `_secrets.env` provisioned | provision-tenant.sh ran for first pilot | ⏸ Post-LOI |
   305	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ Post-LOI. No embedding classifier ships at v1.0 — Step 8 emits honest `unscored/no_corpus`; G5 warn-when-unscored (never a faked score) |
   306	| `validate.sh` Gate A logic (G1-G7) | This branch (commit `184a2bf`) | ✅ LIVE — all 7 checks enforced; gate-a suite green (4 pass + 8 fail classes) |
   307	| `context.sh` hydration | This branch (commit `184a2bf`) | ✅ LIVE — canonical RLS-scoped `tenant_adapters` SELECT path; `IFOS_FORCE_*` fallbacks retained for fixtures only |
   308	| `cycle.sh` orchestration (12-step) | This branch (commit `184a2bf`) | ✅ LIVE — all 12 steps; fixture-proven end-to-end against the local dev DB (full smoke under a throwaway tenant) |
   309	| Dedup heuristic + confidence scorer | `bin/dedup-pairs.sh` | ✅ LIVE — deterministic pure-jq; dedup suite green |
   310	| 3 fixtures + DB-backed suites | `fixtures/` + `scripts/run-janitor-{dedup,gate-a,report}-test.sh` | ✅ green (`01-primary`, `02-edge-case-fuzzy-match`, `99-recent-activity-blocked`) |
   311	| LinkedIn enrichment | §4 Step 7 | — NO-OP at v1.0 (explicit `linkedin_enrichment_skipped` audit row; vendor selection deferred to v1.1+) |
   312	
   313	**The remaining ⏸ items no longer gate the build (done); they gate LIVE operation:** the Bullhorn live smoke (refresh → scan → one sandbox write through Steps 1-2-9) and pilot onboarding are founder-gated post-creds steps. Kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) context preserved for history: Bullhorn auth was not cleared in W5; the build proceeded fixture-first in W6-7 per spec-001 §8's honest-scope disposition (creds EMPTY, founder-gated; writes recorded as deferred, never faked) rather than deferring the agent.
   314	
   315	---
   316	
   317	## §9 — Status + open questions
   318	
   319	**Status:** Proposed (W6-7 build slice COMPLETE on this branch; status flip founder-gated per §10). Still awaits: Bullhorn Sub-decision B (A RESOLVED 2026-06-02) + live Bullhorn credentials + Q1 LOI + Codex re-ratification of the built bundle + founder approvals below.
   320	
   321	### Open questions for founder review
   322	
   323	| # | Question | Resolution path |
   324	|---|---|---|
   325	| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
   326	| Q2 | Field-completeness priority order — which missing fields are highest-impact to backfill first? | Founder review with first pilot tenant; varies by tenant focus (perm vs contract). |
   327	| Q3 | Bullhorn write batch size — current default 100/min. Bullhorn published rate-limit isn't documented; we may need to negotiate. | Bullhorn commercial conversation Sub-decision B output. |
   328	| Q4 | Tacit-note attribution — should notes attribute to "Intel Force OS Janitor" or just "Internal note"? Tenant brand preference. | Per-tenant config at first-pilot onboarding. |
   329	| Q5 | Day-30 report distribution path — vault only OR also forwarded to tenant's hiring leader via email? | v1.0: vault only. v1.1: opt-in email forward via Concierge. |
   330	| Q6 | Gate B exception handling — what if a tenant's day-0 baseline is already exceptionally clean (low headroom for improvement)? | Founder review at first 3-tenant cohort; may need per-tenant Gate B calibration. |
   331	
   332	### Gotchas (carried forward from ULTRAPLAN A2 line 513)
   333	
   334	1. **Bullhorn MCP server — RESOLVED at W6-7.** Originally "doesn't exist yet; critical-path build for v1.0" (per ULTRAPLAN A2 line 513). The `@ifos/bullhorn` connector package + `dist/cli.js` bridge are now BUILT (vitest 52/52); the remaining critical-path item is live credentials (founder-gated), not code.
   335	2. **Dedup is hard; start conservative.** High-confidence merges only (≥0.85); tune up the threshold over time as data builds.
   336	3. **Bullhorn webhook coverage is patchy** (per ULTRAPLAN A6 line 569 — Concierge note applies cross-agent). Janitor relies on polling not webhooks; safer for nightly cron pattern.
   337	
   338	---
   339	
   340	## §10 — When this document ratifies
   341	
   342	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   343	
   344	Status flips Proposed → Accepted (pre-build) when:
   345	- Codex Round 4 Phase 2 ratifies
   346	- Founder approves §9 open questions Q1 + Q2 + Q4 + Q5 + Q6
   347	- Q3 resolves via Bullhorn Sub-decision B answer
   348	
   349	Status flips Accepted → In Force when:
   350	- ~~W5 build slice produces all 5 sibling bundle files + 3 fixtures~~ **SATISFIED 2026-06-10** — the W6-7 build slice (spec-001, this branch) shipped all 6 sibling bundle files + 3 fixtures LIVE; build-gate GREEN
   351	- First production run against migration-test tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row) — pending; blocked on live Bullhorn credentials (founder-gated)
   352	- Day-30 baseline measured for first pilot tenant — pending; post-LOI
   353	- Codex re-ratifies post-build via `review-agent-bundle.md` skill — in progress on this branch
   354	
   355	Current position (2026-06-10): the contract below is IMPLEMENTED — the bundle is built and fixture-proven, not production-proven (zero live Bullhorn calls). The §10 status field stays **Proposed** until the founder flips it; the flip is founder-gated, not Claude's call.
   356	
   357	*End of Janitor agent.md draft.*

exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
     1	# Janitor — the wedge agent
     2	
     3	**Status:** Proposed (W6-7 build slice COMPLETE on this branch; status flip founder-gated per §10).
     4	**Build state:** W6-7 build slice COMPLETE (spec-001; branch `worktree-agent-abb2ffb971bb471ba`, 2026-06-10) — all 6 sibling bundle files (`cycle.sh` 12 steps + `validate.sh` Gate A G1-G7 + `context.sh` + `cleanup.sh` + `tools.yaml` + `README.md`) + 3 fixtures LIVE/BUILT; build-gate GREEN; three deterministic DB-backed fixture suites green (`scripts/run-janitor-{dedup,gate-a,report}-test.sh`). Fixture-proven only: zero live Bullhorn calls have ever been made by this bundle (all six `BULLHORN_*` creds EMPTY per names-only re-verification 2026-06-10; live smoke founder-gated). Companies House is the one live-capable path (key SET; live-smoked once, read-only). Prior contract history: Day-20 W4 bilateral pass; R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority; R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4; R19 (2026-05-25): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Still awaits: Q1 LOI + Bullhorn Sub-decision B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + live Bullhorn credentials + Codex re-ratification of the built bundle + founder approvals per §10.
     5	**Reading-discipline note (updated 2026-06-10 at W6-7 build; originally added 2026-06-03 per Codex Fbis-R3 closure pattern + CC + Concierge precedent):** this `agent.md` is the **CONTRACT** that the W6-7 build slice implemented against. The 6 sibling bundle files + 3 fixtures are **LIVE** — the W6-7 build slice (spec-001, this branch; commits `184a2bf` + `4ceccbc` + `2938b20` + `30bdff8`) replaced every `TODO(W6-7)` marker with live implementation; the three DB-backed fixture suites are green under build-gate. **Per-component build state, honestly stated:** `@ifos/bullhorn` — implemented connector package + built `dist/cli.js` bridge (`packages/mcp-connectors/bullhorn`, v0.1.0; typecheck clean; vitest 52/52; generic `update-entity` for Candidate|ClientContact|JobOrder|Placement + extended `create-note` per the agreed CLI contract). Live credentials are the ONLY gap on that path: with creds EMPTY the agent runs DEGRADED — Step 2 scans the Postgres `entities` Bullhorn cache instead of the live API; all coverage is fixture-driven (`IFOS_JANITOR_FIXTURE_*`). `@ifos/companies-house` — live-capable (key SET); smoked once read-only via `bin/ch-lookup.mjs` (HAYS PLC → CRN 02150950, source_confidence 0.9). **Runtime-audit truth (W6-7 behaviour):** the three yellow-tier action rows the contract names (`bullhorn_candidate_dedupe` + `bullhorn_field_backfill` + `bullhorn_note_attach`) ARE emitted at runtime — cycle.sh Step 9 validates each proposal through validate.sh, then emits `hh_decision_action "${_jn_atype}"` (cycle.sh lines 703-704) with per-type tallies at lines 705-709 and the `bullhorn_write_batch` summary row at lines 711-712. Until creds land, each row carries `write_state:deferred` in its reason (the batch summary tallies them as `deferred_no_creds:<N>`); the Gate-A-validated decision is real and audited, the transport is honestly deferred, never faked — post-creds the same rows carry `write_state:applied`. `context.sh` uses the canonical RLS-scoped `SELECT config->>'<key>' FROM tenant_adapters` path (v0.4 supplement LIVE on VPS per commit `a1bbcf6`), with `IFOS_FORCE_*` env fallbacks retained for fixtures/local-dev only. **Voice honesty:** no embedding classifier ships at v1.0 — Step 8 emits `unscored/no_corpus` (or `classifier_unavailable` when a corpus is active) rather than a faked score; validate.sh G5 is hard-when-scored / warn-when-unscored. LinkedIn (§4 Step 7) is an explicit NO-OP audit row (`linkedin_enrichment_skipped`). §10 lifecycle status remains **Proposed** pending Codex re-ratification of the built bundle + founder approvals — the status flip is founder-gated.
     6	**Date:** 2026-05-24.
     7	**Author:** Founder (Maddox) + Claude Code.
     8	**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
     9	**Build complexity:** L (2 weeks) per ULTRAPLAN A2 line 512.
    10	**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.2 (lines 105-116; §2.1 is the Diagnostic section).
    11	
    12	---
    13	
    14	## §1 — Output contract (one-paragraph screenshot)
    15	
    16	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    17	
    18	> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any AUTO-MERGE proposal with confidence <0.85 (per ULTRAPLAN A2 line 510) — Gate A's merge-confidence check applies to auto-merge proposals ONLY; held and dropped pairs are classified upstream at §4 Steps 3-4 per the spec-001 band→action table (≥0.85 + no 90d activity → auto-merge; 0.70–0.85 OR ≥0.85-with-recency → held via ESC_DUPLICATE_DETECTED; <0.70 → silent drop) and never reach Gate A. Gate B success threshold: ≥15% dedup AND ≥10% field-completeness — two independent thresholds, both must pass. SHIPPED v1.0 metric (cycle.sh Step 10, header lines 716-724 + computation lines 755-762): deterministic in-run `decision_log`-derived ratios — `dedup_pct = 100·merges/(merges + review-band pairs)`, `completeness_pct = 100·backfills/(backfills + still-missing rows)`. Explicit limitation: this is NOT yet measured against the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511) — no day-0 baseline exists yet; baseline-relative measurement is the documented post-pilot enhancement (accepted build deviation 6; captured at pilot onboarding per §9 Q6). Auto-band Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks, no synchronous approval; review-band dedup merges (0.70–0.85 confidence, or ≥0.85 with Bullhorn activity in the last 90 days) are instead held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before write. Every write emits a per-write audit row to `decision_log` with `agent_name='janitor'`.
    19	
    20	---
    21	
    22	## §2 — Invocation surface
    23	
    24	### Cron (v1.0)
    25	
    26	```bash
    27	# /etc/cron.daily/ifos-janitor → calls this script per tenant
    28	0 2 * * * sudo -u ifos_user /usr/local/bin/ifos-janitor.sh --tenant <slug>
    29	```
    30	
    31	Resolved by cortextOS daemon → spawns Janitor in Tier-2 batch mode (no persistent PTY). Typical runtime per tenant: 15-45 min depending on Bullhorn corpus size.
    32	
    33	### Manual trigger (v1.0 — operator convenience)
    34	
    35	```bash
    36	ifosctl janitor --tenant <slug> [--dry-run] [--report-only]
    37	```
    38	
    39	`--dry-run` reports what WOULD be written without touching Bullhorn. `--report-only` regenerates the day-30 report without doing dedup/enrichment passes (used post-incident for manual report regeneration).
    40	
    41	### v1.1+ surfaces (deferred)
    42	
    43	- Brain UI "Run Janitor now" button → triggers via internal API
    44	- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold` — declared in `vertical-schema.v0.3-supplement.yaml §4 tenant_adapters_config_additions.janitor_dedup_threshold`; enforced by `migrations/v0.2-to-v0.3.sql §5` validator allowlist)
    45	
    46	---
    47	
    48	## §3 — Output shape
    49	
    50	Two outputs per run. Both are load-bearing artefacts.
    51	
    52	### Output 1 — Day-30 Markdown report
    53	
    54	Located at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`. Eight sections:
    55	
    56	| # | Section | Content |
    57	|---|---|---|
    58	| 1 | **Record counts** | Total candidates / contractors / clients / contacts / placements / opportunities before + after this run; deltas per entity type |
    59	| 2 | **Dedup pairs** | List of duplicate candidate AND contractor pairs identified this run; for each pair: entity type (candidate / contractor — separate types per vertical-schema.yaml §1), `bullhorn_id`, match dimensions (name + email + phone + LinkedIn), confidence score, action taken (auto-merged ≥0.85 / approval-gated 0.70–0.85 via ESC_DUPLICATE_DETECTED / dropped <0.70) |
    60	| 3 | **Field-completeness deltas** | Per entity-type table: which fields were filled in (e.g., candidate.location, contractor.day_rate); source of the backfill (Companies House lookup, LinkedIn enrichment, derivation from related entities) |
    61	| 4 | **Tacit-note coverage** | Notes harvested from `recent_edit` table rows with `resolution='approved_after_edit'` (per v0.2-supplement.yaml recent_edit definition; v0.3 supplement §2a grants Janitor R access); attached to relevant Bullhorn entities; coverage rate over the 30-day window |
    62	| 5 | **Agent vs. consultant attribution** | Rows attributed to Janitor automated work vs consultant manual entry; supports the day-30 before/after narrative |
    63	| 6 | **Gate-B metric** | TWO independent thresholds per ULTRAPLAN A2 line 511 verbatim: dedup improvement ≥15% AND field-completeness improvement ≥10%. Both must pass. NOT a composite score — that would let one threshold cover for the other. |
    64	| 7 | **Exception list** | Failed writes (Bullhorn 4xx/5xx, FK violations); rate-limit hits; dedup proposals flagged for review (confidence between 0.7-0.85); operator action items |
    65	| 8 | **Executive summary** | 200-word narrative suitable for forwarding to the tenant's hiring leader; cites top-3 cleanup wins; quantifies time saved (hours of consultant data-entry work avoided) |
    66	
    67	### Output 2 — Bullhorn writes (yellow tier)
    68	
    69	Three write categories. Action types map to existing entries in `agents/_shared/autosend-policy.yaml` (all three below are already registered there as yellow-tier):
    70	
    71	1. **Candidate / contractor merge** (`PUT /Candidate/{primary_id}` + cascade; candidate and contractor are separate entity types per vertical-schema.yaml §1 but share the §4 Steps 3-4 fuzzy-matcher) — auto-merged only when confidence ≥0.85 AND neither record had Bullhorn activity in the last 90 days (per ULTRAPLAN A2 line 510 verbatim); pairs in the 0.70–0.85 review band, or ≥0.85 with recent activity, are held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before any write. Action type: **`bullhorn_candidate_dedupe`** with `payload.entity_type ∈ {candidate, contractor}` discriminating the two — reused rather than a separate contractor action_type (same yellow tier + matcher; registered in `agents/_shared/autosend-policy.yaml` under §YELLOW action_types; yellow tier; sample_rate: 10).
    72	2. **Field backfill** (`PATCH /Candidate/{id}` or `/Client/{id}`) — fills missing canonical schema fields (per `vertical-schema.yaml`): `candidate.location` (line 124), `client.industry` (line 238), `client.size_employees` (line 243), `client.companies_house_number` (line 252), `contractor.day_rate_min/day_rate_max` (lines 193-197), `brief.salary_min/salary_max` (lines 371-376) from Companies House (for clients) or LinkedIn/derivation (for candidates). Sources logged in payload. Action type: **`bullhorn_field_backfill`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 10).
    73	3. **Tacit-note attach** (`POST /Note` linked to entity) — narrative summary of consultant edits + decision-log resolutions over the 30-day window. Action type: **`bullhorn_note_attach`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 20).
    74	
    75	Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.
    76	
    77	---
    78	
    79	## §4 — Workflow
    80	
    81	12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
    82	
    83	```
    84	0. Session start
    85	   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice corpus
    86	     (used for tacit-note attribution) + recent edits (for note harvest)
    87	   → hh_decision_trigger("session_start", "janitor nightly cron")
    88	
    89	1. Bullhorn auth refresh
    90	   → bullhorn.refresh_access_token() per per-agent 8-min refresh loop
    91	     (bullhorn-integration-path.md §4.5)
    92	   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
    93	
    94	2. Bullhorn entity scan (read-only)
    95	   → enumerate candidates + contractors + clients + contacts + placements +
    96	     opportunities created/modified since last Janitor run (last_run_at in
    97	     tenant_adapters.config.janitor_last_run — declared in vertical-schema
    98	     v0.3 supplement §4 tenant_adapters_config_additions.janitor_last_run;
    99	     enforced by migrations/v0.2-to-v0.3.sql §5 validator allowlist)
   100	   → hh_decision_output("janitor_scan", "tenant:<slug>", "<N> entities scanned")
   101	   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per ESC_RATE_LIMIT_HIT catalogue §2.5 standard handling)
   102	
   103	3. Dedup pass — candidate entity type
   104	   → matcher: bin/dedup-pairs.sh (pure-jq deterministic helper; declared in
   105	     tools.yaml as capability `janitor_dedup_matcher`)
   106	   → fuzzy-match across (name, email, phone, linkedin_url) tuples
   107	   → compute confidence per pair: name × 0.3 + email × 0.4 + phone × 0.2 + linkedin × 0.1
   108	     (comparable-weight normalisation + required strong identifier per build
   109	     deviation 1)
   110	   → classify per the spec-001 §4 band→action table (the ONE model §1/§5/§6 cite):
   111	     · ≥0.85 AND no Bullhorn activity on EITHER record in last 90d (per
   112	       ULTRAPLAN A2 line 510) → AUTO-MERGE proposal (yellow tier; written at
   113	       Step 9 behind Gate A)
   114	     · 0.70–0.85, OR ≥0.85 with recent (or unknown) 90d activity → HELD for
   115	       synchronous Telegram approval via ESC_DUPLICATE_DETECTED (SUCCESS-path
   116	       approval gate, NOT a Gate A failure)
   117	     · <0.70 → silent drop (tallied in the dedup_candidate_pass marker reason)
   118	   → batch auto-band pairs into proposed-merge list (in-memory intermediate;
   119	     not persisted — hh_decision_action emitted at Step 9 when each merge
   120	     actually writes)
   121	
   122	4. Dedup pass — contractor entity type
   123	   → same algorithm as candidates (same bin/dedup-pairs.sh matcher + band
   124	     table); separate entity_type per Q1 Day-6 resolution (vertical-schema.yaml §1)
   125	
   126	5. Field completeness audit (canonical field names per vertical-schema.yaml)
   127	   → for each entity, check critical fields: candidate.location (line 124),
   128	     client.industry (line 238), client.size_employees (line 243),
   129	     contractor.day_rate_min/day_rate_max (lines 193-197),
   130	     brief.salary_min/salary_max (lines 371-376)
   131	   → identify missing-field rows
   132	   → batch enrichment calls
   133	   → hh_decision_output("field_completeness_audit", tenant, "<N> missing-field rows")
   134	
   135	6. Companies House enrichment (clients only)
   136	   → tools.yaml capabilities `companies_house_search` (client.name per
   137	     vertical-schema.yaml line 235 → CRN) + `companies_house_get_company`
   138	     (CRN → profile) on @ifos/companies-house, invoked via bin/ch-lookup.mjs
   139	     → fill canonical schema fields client.industry (line 238),
   140	     client.companies_house_number (line 252)
   141	   → 7-day cache + shared 600/5min rate budget live INSIDE the connector
   142	     (Diagnostic precedent); budget shared with Diagnostic
   143	   → ESC_RATE_LIMIT_HIT on 429
   144	
   145	7. LinkedIn enrichment (candidates; v1.1 via Proxycurl)
   146	   → at v1.0: skipped (LinkedIn deep data deferred to W4 polish; Proxycurl
   147	     signup commercial decision)
   148	   → at v1.1: linkedin.profile_fetch(candidate.linkedin_url) → location +
   149	     current_company → write back
   150	
   151	8. Tacit-note harvest
   152	   → query the `recent_edit` v0.2 table directly (per vertical-schema.v0.2-supplement.yaml
   153	     recent_edit definition; v0.3 supplement §2a grants Janitor R access):
   154	     SELECT FROM recent_edit WHERE resolved_at > now() - interval '30 days'
   155	     AND resolution='approved_after_edit' AND tenant_slug=$tenant
   156	   → join to decision_log only if action-context lookups needed
   157	   → group by target_entity_type (candidate / contractor / contact / brief / etc.)
   158	   → for each group, generate narrative summary via voice-classified LLM
   159	     (voice corpus + tone rules; ESC_VOICE_DRIFT if classifier <0.75)
   160	   → hh_decision_output("janitor_tacit_note_harvest", "tenant:<slug>",
   161	     "harvested:<N> rows; groups:<M> entity-types; narrative_drafts:<K>")
   162	   → on classifier fail after retries: hh_decision_action("validate_gate_a_fail",
   163	     "tenant:<slug>", payload_hash, "ESC_VOICE_DRIFT; classifier_score:<N>")
   164	
   165	9. Bullhorn write batch (yellow tier — spot-check sampling)
   166	   → for each proposed merge / backfill / note: emit hh_decision_action with
   167	     tier='yellow'; spot-check sample rate per autosend-policy.yaml row
   168	   → atomic per-write transaction (BEGIN/COMMIT)
   169	   → on 4xx: emit ESC_BULLHORN_WRITE_FAIL; skip; continue
   170	   → on 5xx: emit ESC_BULLHORN_WRITE_FAIL; retry once with 30s backoff
   171	
   172	10. Day-30 report assembly
   173	   → SELECT from decision_log WHERE agent_name='janitor' AND created_at >
   174	     now() - interval '30 days' AND tenant_slug=$tenant
   175	   → group by action_type; tally success/fail; compute Gate-B metric
   176	   → 8-section Markdown report (per §3 above)
   177	   → write to /vault/<tenant>/janitor-reports/day-30-<ISO-date>.md
   178	   → hh_decision_output("day_30_report", "<path>", "Gate-B score: <N>")
   179	
   180	11. Operator notification (Telegram)
   181	   → if Gate-B target met: green-tier notification with summary
   182	   → if Gate-B target missed: yellow-tier notification + 200-char executive
   183	     summary suggesting consultant follow-up
   184	   → hh_decision_action("operator_notify_telegram", "tenant:<slug>",
   185	     notification_hash, "gate_b_state:met|missed; chars:<N>")
   186	
   187	12. Session close
   188	   → update tenant_adapters.config.janitor_last_run = now()
   189	   → hh_decision_action("janitor_run_complete", "tenant:<slug>", payload_hash, payload_preview)
   190	   → exit code 0 (or 1 if BOTH Gate-B thresholds missed for 3 consecutive runs per §5 + catalogue → ESC_GATE_B_MISS)
   191	```
   192	
   193	### Audit coverage — consolidated model (per master brief §8.1 Change 2)
   194	
   195	Every step that produces output or takes action audits to `decision_log` — but
   196	not every step carries its OWN `hh_decision_*` row; two clusters consolidate
   197	(deliberate, one model):
   198	
   199	- **Step 1 failures** audit via the per-run `bullhorn_auth_refresh` output row
   200	  (token state recorded every run) plus the `ESC_BULLHORN_AUTH` gating row on
   201	  refresh failure or creds absence. There is no separate Step-1
   202	  `hh_decision_action` row.
   203	- **Steps 3-4 outcomes** audit downstream: AUTO-band pairs become the Step 9
   204	  `bullhorn_candidate_dedupe` yellow action rows when each merge actually
   205	  writes; HELD pairs each emit an `ESC_DUPLICATE_DETECTED` gating row at
   206	  Steps 3-4 (catalogue §2.5 payload shape; also listed in the day-30 report §7
   207	  exception list); DROPPED (<0.70) pairs are tallied in the
   208	  `dedup_candidate_pass` / `dedup_contractor_pass` marker reasons
   209	  (`dropped:<N>`) with batch outcomes summarised in `bullhorn_write_batch`.
   210	  No held or dropped outcome is traceless.
   211	
   212	---
   213	
   214	## §5 — Gates
   215	
   216	### Gate A — validate.sh (hard-fail before action)
   217	
   218	Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Janitor's `validate.sh` enforces:
   219	
   220	- Bullhorn auth refresh succeeded in Step 1 (no stale token writes)
   221	- Every AUTO-MERGE proposal has confidence ≥ 0.85 per ULTRAPLAN A2 line 510 (G2 — applies to auto-merge proposals ONLY; review-band pairs are held upstream at §4 Steps 3-4 and never reach Step 9, so this check is defence-in-depth against a band-classification bug, not the band mechanism itself)
   222	- No auto-merge proposal where EITHER record has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim; G3 — same defence-in-depth scope as G2)
   223	- No field-backfill where source confidence <0.7 (CH 404 / LinkedIn empty / no derivation source)
   224	- Tacit-note narratives pass voice classifier ≥ 0.75
   225	- Bullhorn write batch size ≤ 100 per minute (rate-limit defensive)
   226	- No PII outside firm boundary in tacit-note narratives (regex pass)
   227	
   228	Gate A failure routing by class (per catalogue §2.5):
   229	- PII detected outside firm boundary → `ESC_PII_LEAKAGE_RISK` (blocking; operator + ifos_oncall per catalogue routing)
   230	- Tacit-note voice classifier <0.75 → `ESC_VOICE_DRIFT` (warn; operator_chat_id)
   231	- Tone-rule violations → `ESC_TONE_RULE_VIOLATION` (warn; operator_chat_id per catalogue §2.10)
   232	- Output-shape failures (section count, write-batch size, dedup confidence below threshold for action) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)
   233	
   234	`ESC_DUPLICATE_DETECTED` (catalogue §2.5) is NOT a Gate A failure code — per catalogue trigger it's the SUCCESS-path Telegram approval gate for dedup pairs that need human approval before merge: the 0.70–0.85 review band, plus any ≥0.85 pair where a record has Bullhorn activity in the last 90 days. Pairs ≥0.85 with no recent activity auto-merge (yellow tier, spot-check) and do NOT fire it. Sub-0.70 confidence pairs silently drop in the Step 3 algorithm; no ESC fire. `ESC_SCHEMA_VIOLATION` (catalogue line 163) is NOT used by Janitor — reserved for vertical-schema field-constraint violations at write-time.
   235	
   236	### Gate B — Outcome threshold (success metric, not block)
   237	
   238	Per ULTRAPLAN A2 line 511 verbatim: **"day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement"**.
   239	
   240	Two independent thresholds (both must pass): dedup improvement ≥15% AND field-completeness improvement ≥10%. NOT a composite — composite would let one cover the other.
   241	
   242	**Shipped v1.0 measurement (W6-7 build; accepted deviation 6):** the live cycle.sh computes the two thresholds as deterministic in-run `decision_log`-derived ratios, not against a day-0 baseline — `dedup_pct = 100·merges/(merges + review-band pairs)` and `completeness_pct = 100·backfills/(backfills + still-missing rows)` (cycle.sh Step 10: header comment lines 716-724, computation lines 755-762; definitions printed in report §6). **Limitation, explicit:** ULTRAPLAN's "before/after vs day-0 baseline" semantics are NOT implemented yet because no day-0 baseline exists pre-pilot — the baseline is captured at first pilot onboarding (per §9 Q6), and baseline-relative Gate B measurement is the documented post-pilot enhancement. The thresholds (≥15% / ≥10%), the AND-logic, and the 3-consecutive-both-missed → `ESC_GATE_B_MISS` trigger are unchanged.
   243	
   244	Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
   245	
   246	Per catalogue `escalation-codes.md` ESC_GATE_B_MISS trigger (Janitor example: "dedup confidence <15% AND field-completeness uplift <10%"): `ESC_GATE_B_MISS` fires only when BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND completeness-improvement <10%) → flag for operator review (heuristic tuning may be needed; not a kill). Single-threshold misses are tracked in the day-30 report (§3 Output 1 row 6) and inform tenant-level quality review but do NOT fire ESC. Sensitivity choice: strict AND-trigger reduces false alarms; tightening to OR-trigger requires a catalogue amendment + re-ratification.
   247	
   248	---
   249	
   250	## §6 — Escalation codes
   251	
   252	All codes are registered in `agents/_shared/escalation-codes.md` (catalogue extended to 52 codes per `2026-05-24` bilateral disposition; see disagreement-doc + `catalogue(bilateral)` commit).
   253	
   254	| Code | Trigger | Severity | Routing |
   255	|---|---|---|---|
   256	| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   257	| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on merge/backfill/note write | warn | operator_chat_id |
   258	| `ESC_RATE_LIMIT_HIT` | Bullhorn or Companies House 429 | warn | operator_chat_id |
   259	| `ESC_VOICE_DRIFT` | Tacit-note narrative voice classifier <0.75 (after 3 retries) | warn | operator_chat_id |
   260	| `ESC_PII_LEAKAGE_RISK` | PII detected in tacit-note outside firm boundary | **blocking** | operator + ifos_oncall |

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '487,516p'; nl -ba docs/specs/ULTRAPLAN.md | sed -n '529,542p'; nl -ba docs/decisions/sequencing-target.md | sed -n '100,120p'; nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '150,170p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
   487	#### A1. The Diagnostic — the sales tool
   488	
   489	- **Build wave:** v1.0 (week 4–5)
   490	- **Always-on?** No — invoked on demand
   491	- **Trigger type:** Manual (run from CLI or sales-tool web page)
   492	- **CortexOS primitives required:** None — runs as a one-shot batch job
   493	- **MCP tools required:** Companies House, LinkedIn (read-only), web scraper for careers pages
   494	- **Shared modules required:** Voice loader (uses Maddox's voice for the audit narrative), decision log writer
   495	- **External APIs:** Companies House API (free), LinkedIn (via Proxycurl or similar), basic HTTP fetch
   496	- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
   497	- **Gate B target:** ≥30% of diagnostics produced lead to a discovery call booked
   498	- **Build complexity:** **M** (1 week)
   499	- **Gotchas:** LinkedIn ToS — we cannot store profile data beyond the audit. Companies House rate limits — cache aggressively.
   500	
   501	#### A2. The Janitor — the wedge agent
   502	
   503	- **Build wave:** v1.0 (week 5–6)
   504	- **Always-on?** Tier 2 — scheduled nightly cron
   505	- **Trigger type:** Cron 02:00 UTC daily; manual full-cleanup on demand
   506	- **CortexOS primitives required:** None (scheduled batch)
   507	- **MCP tools required:** Bullhorn (read-write), Companies House (for entity enrichment)
   508	- **Shared modules required:** Decision log writer, escalation router
   509	- **External APIs:** Bullhorn REST API, Companies House
   510	- **Gate A:** dedup confidence score ≥ 0.85 on every merge proposal; no merge proposed where candidate has had activity in last 90 days without explicit review flag
   511	- **Gate B target:** day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement
   512	- **Build complexity:** **L** (2 weeks) — the Bullhorn MCP work is the rate-limiting piece
   513	- **Gotchas:** Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0. Estimate 1 week for the MCP server, 1 week for the agent itself. Dedup is hard; start conservative (high-confidence merges only) and tune up.
   514	
   515	#### A3. The Scribe — the data spine
   516	
   529	#### A4. Cash Conductor (real-time mode) — the FD's evenings back
   530	
   531	- **Build wave:** v1.0 (week 7–8)
   532	- **Always-on?** Tier 1 — persistent watcher on accounting + bank webhooks
   533	- **Trigger type:** Webhook (payment received, invoice issued, invoice viewed) + cron sweep at 07:00 daily
   534	- **CortexOS primitives required:** Persistent PTY (#1), Telegram approval surface (#5), standing authorisations (#4)
   535	- **MCP tools required:** Xero / QuickBooks / Sage (one of, per tenant), bank-feed connector
   536	- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
   537	- **External APIs:** Xero API or QuickBooks API or Sage API; bank feed via Open Banking (TrueLayer / Plaid UK)
   538	- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
   539	- **Gate B target:** tenant DSO at month-3 ≥ 12 days lower than month-0 baseline
   540	- **Build complexity:** **L** (2 weeks) — three accounting integrations × Open Banking is the work
   541	- **Gotchas:** Open Banking auth is a 90-day token; rotation logic is non-trivial. Bank feed reconciliation against invoice register is the hard logic; start with exact-amount matches and expand to fuzzy.
   542	
   100	| 5. Dependencies on other agents | **None** | Standalone. No upstream agent dependency; no downstream agent consumes Diagnostic output |
   101	| 6. Tenant-onboarding readiness | **High** | Runnable from end of Week 2 with renderer + `_shared/` + Postgres decision_log. No vault `_secrets.env` complexity (no per-tenant Bullhorn OAuth needed), no wiki API needed. Single-tenant deployable immediately |
   102	
   103	**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
   104	
   105	### 2.2 — A2 Janitor
   106	
   107	| Criterion | Score | Rationale |
   108	|---|---|---|
   109	| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 513 estimate **L (2 weeks)** — the Bullhorn MCP work is rate-limiting per Ultraplan §8.1 line 514 ("Bullhorn MCP server doesn't exist yet — this is the critical-path build"). One MCP server (Bullhorn) + Companies House for enrichment. Single primary output (cleanup report) but with continuous nightly cron pattern |
   110	| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
   111	| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #2** (Bullhorn auth path per RISK-REGISTER). Closes Risk #2 reduction trigger 2 from `bullhorn-integration-path.md` §6.7: "first Bullhorn write lands cleanly in Week 3-4 Janitor agent build" → Risk #2 Medium → Low |
   112	| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
   113	| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
   114	| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn `client_id` + `client_secret` (commercial action per Day 2 §6.1) + per-tenant Bullhorn admin OAuth authorisation (the browser dance per Day 2 §3.1). First-pilot onboarding wizard Day 2 step (Product Spec §5.2) is the moment Janitor can be enabled per tenant |
   115	
   116	**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
   117	
   118	### 2.3 — A3 Scribe
   119	
   120	| Criterion | Score | Rationale |
   150	**Action:** PIVOT — likely vectors:
   151	
   152	- **Self-host:** founder's Mac Studio cluster from prior research as primary; Hetzner as backup. Saves money but adds maintenance.
   153	- **Provider switch:** alternate eu-central provider (Mythic Beasts, OVH, Scaleway) with better price-per-tenant economics.
   154	- **Architecture compaction:** per-tenant resource pooling rather than per-tenant servers.
   155	
   156	**Recovery path:** Rescoped infrastructure plan; pivoted v1.0 continues with adjusted Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target; budget adjustment is a runbook revision, not a master-brief edit).
   157	
   158	### Trigger 8 — GATE-B-REVENUE-UPLIFT (KILL)
   159	
   160	**Threshold:** After 3 completed pilots (defined as: pilot ran for ≥90 days with active agent fleet and quarterly Gate B revenue measurement), average Gate B revenue uplift per tenant <£20k/year.
   161	
   162	**Owner:** Founder; assessed at end of each pilot.
   163	
   164	**Source:** Master brief §6 Day 5 line 486 — canonical example trigger from master brief.
   165	
   166	**Action:** KILL. Rationale: the wedge does not produce demonstrable ROI at the threshold required to sustain v1.0 commercially. £20k/year/tenant is the breakeven floor — below this, IFOS cannot fund continued operation at v1.0 pricing.
   167	
   168	**Recovery path:** None within v1.0. Lessons feed v1.1 if launched. The vertical assumption (UK recruitment) or product assumption (agent fleet vs. point tools) may need reconsidering for any next initiative.
   169	
   170	### Trigger 9 — CORTEXOS-PRIMITIVE-CHRONIC-FAILURE (PAUSE)

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '110,130p;185,200p;232,255p;365,378p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
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
   185	        required: false
   186	        source: Bullhorn.Candidate.mobile
   187	      ir35_status:
   188	        type: string
   189	        required: true
   190	        enum: [inside_ir35, outside_ir35, undetermined, exempt_small_business]
   191	        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
   192	        notes: Pilot-agreement liability per autosend-policy.md §10 — incorrect IR35 classification is a tenant liability event. T4 IR35 agent (v2.0) is the canonical owner.
   193	      day_rate_min:
   194	        type: number
   195	        required: false
   196	        source: IFOS-derived (Scribe extracts from call; GBP per day)
   197	      day_rate_max:
   198	        type: number
   199	        required: false
   200	        source: IFOS-derived (GBP per day)
   232	        required: true
   233	        source: Bullhorn.ClientCorporation.id
   234	      name:
   235	        type: string
   236	        required: true
   237	        source: Bullhorn.ClientCorporation.name
   238	      industry:
   239	        type: string
   240	        required: false
   241	        source: Bullhorn.ClientCorporation.industryList
   242	        notes: Bullhorn stores as multi-value; v0.1 flattens to primary industry only.
   243	      size_employees:
   244	        type: string
   245	        required: false
   246	        enum: [1-10, 11-50, 51-200, 201-500, 501-1000, 1001-5000, 5000+]
   247	        source: Bullhorn.ClientCorporation.numEmployees (bucketed)
   248	      website:
   249	        type: string
   250	        required: false
   251	        source: Bullhorn.ClientCorporation.companyURL
   252	      companies_house_number:
   253	        type: string
   254	        required: false
   255	        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
   365	        notes: Free-text JD body. Subject to autosend-policy.md §7 — payload_preview must summarise, not embed full JD.
   366	      role_type:
   367	        type: string
   368	        required: true
   369	        enum: [permanent, contract, temp, retained_search]
   370	        source: Bullhorn.JobOrder.employmentType (with mapping)
   371	      salary_min:
   372	        type: number
   373	        required: false
   374	        source: Bullhorn.JobOrder.salary
   375	        notes: GBP annual for permanent roles.
   376	      salary_max:
   377	        type: number
   378	        required: false

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,160p'; nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
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
    11	# auxiliary tables + 6 tenant_adapters.config keys + v0.2 entity-access amendments).
    12	# (v0.3-supplement-0.1 amendment Day-20: original 3 v0.3 keys + 2 Janitor keys
    13	# added closing Janitor R11 Finding 4 + blocked_recipients added closing
    14	# Sourcing Scout R8 Finding 1. blocked_recipients is pre-v0.3 origin
    15	# canonicalised here. Total: 6 declarations in §4.)
    16	# Residual Cat-β gaps require either (a) Scribe agent.md consistency-pass to align
    17	# its §3 narrative with canonical v0.1/v0.2/v0.3 field names (current_role vs
    18	# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
    19	# v0.4-supplement that adds the remaining Scribe-referenced fields (seniority,
    20	# opportunity.sector, current_role_title). v0.4 work is queued for W4-polish slice;
    21	# v0.3 ratification does not block on it.
    22	#
    23	# Companion migrations: migrations/v0.2-to-v0.3.sql + migrations/v0.3-to-v0.2.sql
    24	#   Both files drafted at commit alongside this supplement.
    25	#
    26	# Field types: per `review-schema-change` skill §2 allowed types only —
    27	# string | integer | number | boolean | array | object | timestamp | date.
    28	# Enums expressed as `type: string` + `enum: [...]`. Lists as `type: array`
    29	# with `items.type`. SQL-level types (NUMERIC(15,2), TIMESTAMPTZ etc.) appear
    30	# only in the companion migration SQL, not here.
    31	#
    32	# Schema layering: entities.data is JSONB per Day-4 §6.3 generic primitive.
    33	# v0.3 entity-field additions are JSONB key shapes validated via the
    34	# validate_entities_data_v0_3 trigger function in v0.2-to-v0.3.sql §4.
    35	# No ALTER TABLE for the candidate / contact / brief / placement / opportunity
    36	# tables — they're already JSONB-shaped.
    37	# ============================================================================
    38	
    39	vertical: recruitment
    40	version: v0.3
    41	supplements: v0.2
    42	status: Proposed
    43	date: 2026-05-24
    44	author: founder (Maddox) + Claude Code; bilateral Cat-β unblock
    45	codex_ratification_queue_position: 44
    46	
    47	# ============================================================================
    48	# §1 — New entity.data JSONB key shapes (14 across 5 entities)
    49	# ============================================================================
    50	#
    51	# All additions land as JSONB keys on the existing entities.data column
    52	# (Day-4 §6.3 generic primitive layer). Validation lives in
    53	# validate_entities_data_v0_3() trigger function (migration §4).
    54	
    55	entity_field_additions:
    56	
    57	  candidate:
    58	    v0_3_new_keys:
    59	      employment_type:
    60	        type: string
    61	        enum: [perm, contract, contract_inside_ir35, contract_outside_ir35, day_rate, hybrid]
    62	        required: false
    63	        notes: |
    64	          Candidate's preferred engagement model (distinct from role type).
    65	          IR35 distinction matters for UK contractors. Extracted by Scribe
    66	          from call context.
    67	        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
    68	        v1_0_agent_access:
    69	          - Scribe: W
    70	          - Sourcing Scout: R
    71	
    72	      key_skills:
    73	        type: array
    74	        items:
    75	          type: string
    76	        max_items: 20
    77	        required: false
    78	        notes: |
    79	          Aggregated skill tags from CV + transcripts. Free-text strings;
    80	          W4 polish may add controlled-vocabulary clustering. Max 20 items
    81	          per candidate enforced by validate_entities_data_v0_3.
    82	        source: IFOS-derived (Scribe writes from CV/transcripts; Sourcing Scout surfaces CV-Library + Reed search-result skills in its shortlist artefact only, NOT into the Bullhorn-backed candidate entity)
    83	        v1_0_agent_access:
    84	          - Scribe: W
    85	          - Sourcing Scout: R   # R-only per bullhorn-integration-path §4.1 A5 + sourcing-scout/agent.md §6; proposed-match skills live in the shortlist artefact, never written to the candidate entity
    86	
    87	      linkedin_url:
    88	        type: string
    89	        pattern: '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$'
    90	        required: false
    91	        notes: |
    92	          LinkedIn profile URL. Pattern enforced by trigger. Surfaced by
    93	          Sourcing Scout in its shortlist artefact (R-only on the candidate
    94	          entity); written to the Bullhorn-backed candidate entity by
    95	          Janitor/Scribe (which hold W) if a sourced candidate is promoted;
    96	          Janitor uses for dedup (stronger match signal than name+email);
    97	          Concierge reads for outreach context (NOT for outbound — outreach
    98	          via candidate.email or candidate.phone only).
    99	        source: IFOS-derived (Scribe/Janitor write to the candidate entity; Sourcing Scout surfaces match URLs in its shortlist artefact only; Janitor uses for dedup verification)
   100	        v1_0_agent_access:
   101	          - Sourcing Scout: R   # R-only per bullhorn-integration-path §4.1 A5 + sourcing-scout/agent.md §6; proposed-match URLs live in the shortlist artefact
   102	          - Janitor: R   # W only via dedup-merge action
   103	          - Concierge: R
   104	
   105	  contact:
   106	    v0_3_new_keys:
   107	      preferred_channel:
   108	        type: string
   109	        enum: [email, phone, sms, teams, slack, in_person, unknown]
   110	        default: unknown
   111	        required: false
   112	        notes: |
   113	          Contact's stated preference; extracted by Scribe from call context.
   114	          Concierge reads to route outbound lifecycle comms.
   115	        source: IFOS-derived (Scribe extraction)
   116	        v1_0_agent_access:
   117	          - Scribe: R+W
   118	          - Concierge: R
   119	
   120	      next_action_target_date:
   121	        type: date
   122	        required: false
   123	        notes: |
   124	          ISO-8601 date set by Scribe at call-end when "I'll follow up by X"
   125	          is in transcript. Concierge respects this when scheduling lifecycle
   126	          nurture.
   127	        source: IFOS-derived (Scribe extraction)
   128	        v1_0_agent_access:
   129	          - Scribe: R+W
   130	          - Concierge: R
   131	
   132	  brief:
   133	    v0_3_new_keys:
   134	      must_haves:
   135	        type: array
   136	        items:
   137	          type: string
   138	        max_items: 15
   139	        required: false
   140	        notes: |
   141	          Hard requirements; Sourcing Scout filters candidates against this
   142	          list. Free-text strings; max 15 items enforced by trigger.
   143	        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
   144	        v1_0_agent_access:
   145	          - Scribe: R+W
   146	          - Sourcing Scout: R
   147	
   148	      nice_to_haves:
   149	        type: array
   150	        items:
   151	          type: string
   152	        required: false
   153	        notes: |
   154	          Soft preferences; Sourcing Scout uses for ranking, not hard filter.
   155	        source: IFOS-derived (Scribe extracts)
   156	        v1_0_agent_access:
   157	          - Scribe: R+W
   158	          - Sourcing Scout: R
   159	
   160	      deal_breakers:
     1	-- ============================================================================
     2	-- IFOS recruitment vertical schema — v0.2 → v0.3 migration
     3	-- ============================================================================
     4	-- Companion to: docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
     5	-- Authored:     2026-05-24 (Day 19; post-bilateral Cat-β unblock)
     6	-- Status:       DRAFTED; NOT executed against production Hetzner Postgres yet.
     7	--               Execute against migration-test tenant first via run-live-migration.sh.
     8	--
     9	-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
    10	-- Concierge). v0.3 additions:
    11	--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
    12	--     (both RLS-isolated per tenant_slug)
    13	--   - JSONB validation trigger updates for entities.data: validate new keys on
    14	--     candidate, contact, brief, placement, opportunity (14 fields across 5
    15	--     entity_types)
    16	--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
    17	--   - decision_log.payload extension is DEFERRED to a future W4-polish ADR
    18	--     + schema supplement (per ADR-006 Tier 2 + v0.3 supplement §5). v0.3
    19	--     does NOT extend the payload shape; the W4 ADR will add both the new
    20	--     payload key and its enforcement (CHECK constraint or trigger).
    21	--
    22	-- All v0.3 additions are STRICTLY ADDITIVE. Rollback path: companion
    23	-- v0.3-to-v0.2.sql.
    24	--
    25	-- Prerequisites:
    26	--   - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule +
    27	--     recent_edit tables exist; validate_voice_scores trigger active)
    28	--   - RLS policies + ifos_app grants from Day-4 §6.3 in place
    29	--   - migration-test tenant row exists in tenants table
    30	--
    31	-- Execution order: BEGIN; <each block>; COMMIT;   on success.
    32	--                  BEGIN; <each block>; ROLLBACK; on any error.
    33	-- ============================================================================
    34	
    35	BEGIN;
    36	
    37	-- ----------------------------------------------------------------------------
    38	-- §1 — Verify prerequisite v0.2 state
    39	-- ----------------------------------------------------------------------------
    40	
    41	DO $$
    42	BEGIN
    43	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus') THEN
    44	    RAISE EXCEPTION 'v0.2 voice_corpus table missing; run v0.1-to-v0.2.sql first';
    45	  END IF;
    46	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus_chunks') THEN
    47	    RAISE EXCEPTION 'v0.2 voice_corpus_chunks table missing; run v0.1-to-v0.2.sql first';
    48	  END IF;
    49	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'tone_rule') THEN
    50	    RAISE EXCEPTION 'v0.2 tone_rule table missing; run v0.1-to-v0.2.sql first';
    51	  END IF;
    52	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
    53	    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
    54	  END IF;
    55	  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
    56	END $$;
    57	
    58	-- ----------------------------------------------------------------------------
    59	-- §2 — Create cash_conductor_transactions table (RLS-isolated)
    60	-- ----------------------------------------------------------------------------
    61	
    62	CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
    63	  id                 BIGSERIAL PRIMARY KEY,
    64	  tenant_slug        TEXT NOT NULL,
    65	  transaction_id     TEXT NOT NULL,
    66	  posted_at          TIMESTAMPTZ NOT NULL,
    67	  amount             NUMERIC(15, 2) NOT NULL,
    68	  currency           TEXT NOT NULL DEFAULT 'GBP',
    69	  payee_name_raw     TEXT,
    70	  description        TEXT,
    71	  bank_provider      TEXT NOT NULL,
    72	  match_status       TEXT NOT NULL DEFAULT 'unmatched',
    73	  matched_invoice_id TEXT,
    74	  match_confidence   NUMERIC(3, 2),
    75	  match_dimensions   TEXT[],
    76	  ingested_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    77	  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    78	  raw_payload        JSONB,
    79	
    80	  CONSTRAINT cct_match_status_valid CHECK (
    81	    match_status IN ('unmatched', 'matched', 'ambiguous')
    82	  ),
    83	  CONSTRAINT cct_bank_provider_valid CHECK (
    84	    bank_provider IN ('truelayer', 'plaid_uk', 'open_banking_direct')
    85	  ),
    86	  CONSTRAINT cct_match_confidence_range CHECK (
    87	    match_confidence IS NULL OR (match_confidence >= 0.00 AND match_confidence <= 1.00)
    88	  ),
    89	  CONSTRAINT cct_tenant_transaction_unique UNIQUE (tenant_slug, bank_provider, transaction_id)
    90	);
    91	
    92	CREATE INDEX IF NOT EXISTS idx_cct_tenant_posted
    93	  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
    94	
    95	CREATE INDEX IF NOT EXISTS idx_cct_tenant_unmatched
    96	  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
    97	  WHERE match_status IN ('unmatched', 'ambiguous');
    98	
    99	-- RLS isolation per Day-4 §6.3 pattern
   100	ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
   101	ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
   102	
   103	-- Idempotent: drop the policy if a prior partial/successful apply created it,
   104	-- then re-create. CREATE POLICY has no IF NOT EXISTS clause in Postgres.
   105	DROP POLICY IF EXISTS cct_tenant_isolation ON cash_conductor_transactions;
   106	CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
   107	  FOR ALL TO ifos_app
   108	  USING (tenant_slug = current_setting('app.current_tenant', true));
   109	
   110	GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
   111	GRANT USAGE, SELECT ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
   112	
   113	-- ----------------------------------------------------------------------------
   114	-- §3 — Create cash_conductor_invoices table (RLS-isolated)
   115	-- ----------------------------------------------------------------------------
   116	
   117	CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
   118	  id                       BIGSERIAL PRIMARY KEY,
   119	  tenant_slug              TEXT NOT NULL,
   120	  invoice_id               TEXT NOT NULL,
   121	  accounting_provider      TEXT NOT NULL,
   122	  invoice_number           TEXT,
   123	  issued_at                TIMESTAMPTZ NOT NULL,
   124	  due_at                   TIMESTAMPTZ NOT NULL,
   125	  amount_total             NUMERIC(15, 2) NOT NULL,
   126	  amount_paid              NUMERIC(15, 2) NOT NULL DEFAULT 0,
   127	  currency                 TEXT NOT NULL DEFAULT 'GBP',
   128	  status                   TEXT NOT NULL DEFAULT 'open',
   129	  client_contact_id        TEXT,
   130	  client_billing_email     TEXT,
   131	  last_chase_position      INT NOT NULL DEFAULT 0,
   132	  last_chase_sent_at       TIMESTAMPTZ,
   133	  ingested_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
   134	  updated_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
   135	  raw_payload              JSONB,
   136	
   137	  CONSTRAINT cci_status_valid CHECK (
   138	    status IN ('open', 'partial', 'paid', 'overdue', 'cancelled', 'voided')
   139	  ),
   140	  CONSTRAINT cci_provider_valid CHECK (
   141	    accounting_provider IN ('xero', 'quickbooks', 'sage')
   142	  ),
   143	  CONSTRAINT cci_chase_position_range CHECK (
   144	    last_chase_position >= 0 AND last_chase_position <= 4
   145	  ),
   146	  CONSTRAINT cci_amount_paid_non_negative CHECK (
   147	    amount_paid >= 0 AND amount_paid <= amount_total
   148	  ),
   149	  CONSTRAINT cci_tenant_provider_invoice_unique UNIQUE (tenant_slug, accounting_provider, invoice_id)
   150	);
   151	
   152	CREATE INDEX IF NOT EXISTS idx_cci_tenant_due
   153	  ON cash_conductor_invoices (tenant_slug, due_at);
   154	
   155	CREATE INDEX IF NOT EXISTS idx_cci_tenant_overdue
   156	  ON cash_conductor_invoices (tenant_slug, status, due_at)
   157	  WHERE status IN ('open', 'partial', 'overdue');
   158	
   159	CREATE INDEX IF NOT EXISTS idx_cci_tenant_chase
   160	  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
   161	  WHERE last_chase_position BETWEEN 1 AND 3;
   162	
   163	ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
   164	ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
   165	
   166	-- Idempotent (see cct_tenant_isolation note above).
   167	DROP POLICY IF EXISTS cci_tenant_isolation ON cash_conductor_invoices;
   168	CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
   169	  FOR ALL TO ifos_app
   170	  USING (tenant_slug = current_setting('app.current_tenant', true));
   171	
   172	GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
   173	GRANT USAGE, SELECT ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
   174	
   175	-- ----------------------------------------------------------------------------
   176	-- §3.5 — updated_at maintenance for the two Cash Conductor tables
   177	-- ----------------------------------------------------------------------------
   178	--
   179	-- ifos_app has UPDATE on both tables; updated_at lets the audit/diagnostic
   180	-- queries (Cash Conductor §10 weekly report; tenancy audit T-class checks)
   181	-- distinguish row mutations from ingestion. Idempotent.
   182	
   183	CREATE OR REPLACE FUNCTION set_updated_at()
   184	RETURNS TRIGGER AS $$
   185	BEGIN
   186	  NEW.updated_at = now();
   187	  RETURN NEW;
   188	END;
   189	$$ LANGUAGE plpgsql;
   190	
   191	DROP TRIGGER IF EXISTS set_updated_at_cct ON cash_conductor_transactions;
   192	CREATE TRIGGER set_updated_at_cct
   193	  BEFORE UPDATE ON cash_conductor_transactions
   194	  FOR EACH ROW
   195	  EXECUTE FUNCTION set_updated_at();
   196	
   197	DROP TRIGGER IF EXISTS set_updated_at_cci ON cash_conductor_invoices;
   198	CREATE TRIGGER set_updated_at_cci
   199	  BEFORE UPDATE ON cash_conductor_invoices
   200	  FOR EACH ROW
   201	  EXECUTE FUNCTION set_updated_at();
   202	
   203	-- ----------------------------------------------------------------------------
   204	-- §4 — Replace JSONB validation function for entities.data (adds v0.3 keys)
   205	-- ----------------------------------------------------------------------------
   206	--
   207	-- The v0.2 migration installed validate_voice_scores trigger which validates
   208	-- the 6 voice-score keys. v0.3 extends validation to cover the 14 new keys
   209	-- for candidate, contact, brief, placement, opportunity. We replace the
   210	-- function in place (CREATE OR REPLACE) so the v0.2 voice-score checks remain.
   211	
   212	CREATE OR REPLACE FUNCTION validate_entities_data_v0_3()
   213	RETURNS TRIGGER AS $$
   214	DECLARE
   215	  d JSONB := NEW.data;
   216	  et TEXT := NEW.entity_type;
   217	  arr_item JSONB;
   218	BEGIN
   219	  -- v0.2 voice-score keys (forwarded; preserves v0.2 [0.0, 1.0] range check)
   220	  IF d ? 'voice_classifier_score' THEN

exec
/bin/zsh -lc "rg --files docs | rg -i 'master|brief|baseline|product|vertical'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
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
docs/_archive-build-pack/02-PRODUCT-VISION.md
docs/build-brief/00-MASTER-BRIEF.md
docs/specs/PRODUCT-SPEC.md
docs/_supplementary/planning-phase-brief.md

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,610p'; nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '520,550p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '90,135p;145,190p;305,390p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
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
   129	- **Trigger:** Dedup pair held for human approval: confidence in the `0.70–0.85` review band, OR `≥ 0.85` where either record has Bullhorn activity in the last 90 days (recency hold) — per spec-001 §4 band→action table. _(Amended 2026-06-10: supersedes the original ≥0.85-only wording from Ultraplan §8.1 line 511 A2 — the W6-7 Janitor build implements the spec-001 dedup band model, which holds the review band and recency cases rather than auto-merging or silently dropping them. ≥0.85 with no 90d activity auto-merges (yellow) and does NOT fire this code; `< 0.70` silently drops.)_
   130	- **Phase:** `action`
   131	- **Routing:** `operator_chat_id` via Telegram approval gate
   132	- **Entity types:** `candidate`, `contractor` (same matcher, separate entity_type — spec-001 §4 Steps 3-4)
   133	- **Payload fields:** `entity_a_id`, `entity_b_id`, `entity_type` (`candidate`|`contractor`), `confidence_score`, `match_basis` (e.g. `email+phone`, `name+email`, `phone+linkedin`), `hold_reason` (`review_band` | `recency_hold_90d`). Legacy aliases `candidate_a_id`/`candidate_b_id` remain readable for pre-amendment candidate rows.
   134	
   135	#### `ESC_JSL_RED_FLAG`
   145	- **Phase:** `agent_handoff`
   146	- **Routing:** `operator_chat_id`
   147	- **Payload fields:** `brief_id`, `ambiguity_dimensions` (list of {`field`, `confidence`}), `proposed_clarifying_questions`
   148	
   149	#### `ESC_PII_LEAKAGE_RISK`
   150	- **Severity:** **blocking** — agent halts immediately, no retry
   151	- **Trigger:** Agent output references PII outside the firm boundary (cross-tenant PII detected by `validate.sh` Gate A or RLS check)
   152	- **Phase:** `gating_failed`
   153	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` — potential GDPR incident
   154	- **Payload fields:** `detected_pii_type` (one of `email`, `phone`, `name`, `address`, `nin`, `passport`), `boundary_violated` (the tenant_slug whose data leaked), `output_snippet_redacted_hash`
   155	- **Recovery:** Agent restart required after operator review; founder must determine whether DPO notification is needed per UK GDPR Art. 33
   156	
   157	#### `ESC_RATE_LIMIT_HIT`
   158	- **Severity:** warn
   159	- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
   160	- **Phase:** `gating_failed`
   161	- **Routing:** `operator_chat_id`
   162	- **Payload fields:** `upstream` (e.g. `bullhorn`, `linkedin`, `reed`, `cv-library`), `retry_after_seconds`, `consecutive_429s`
   163	
   164	#### `ESC_SCHEMA_VIOLATION`
   165	- **Severity:** warn
   166	- **Trigger:** Agent produced output violating vertical-schema.yaml field constraints (e.g. wrote an unknown enum value, missing required field). Detected at write-time by adapter validation
   167	- **Phase:** `gating_failed`
   168	- **Routing:** `operator_chat_id`
   169	- **Payload fields:** `entity_type` (from vertical-schema.yaml entities), `field_violated`, `value_attempted`, `constraint_failed`
   170	
   171	#### `ESC_VOICE_DRIFT_TENANT`
   172	- **Severity:** warn (info-level — single-tenant pattern, not just one drift event)
   173	- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
   174	- **Phase:** `gating_failed`
   175	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (CSM may need to retrain voice corpus)
   176	- **Payload fields:** `tenant_slug`, `drift_event_count`, `window_days`, `affected_agents` (list of agent_name)
   177	
   178	#### `ESC_INPUT_VALIDATION_FAIL`
   179	- **Severity:** warn
   180	- **Trigger:** Agent rejected its input at the validation gate (e.g. malformed firm name, missing required CLI argument, brief description too short). Detected at Step 1 of the agent's workflow BEFORE any tool calls or LLM invocations
   181	- **Phase:** `gating_failed`
   182	- **Routing:** `operator_chat_id`
   183	- **Payload fields:** `input_field`, `input_value_preview` (truncated to 80 chars), `validation_rule_violated`
   184	
   185	#### `ESC_AGENT_OUTPUT_SHAPE`
   186	- **Severity:** warn
   187	- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
   188	- **Phase:** `gating_failed`
   189	- **Routing:** `operator_chat_id`
   190	- **Payload fields:** `agent_name`, `output_path`, `shape_rule_violated`, `expected_value`, `actual_value`
   305	- **Payload fields:** `consent_expires_at`, `days_remaining`, `bank_provider`, `stage` (`info` | `warn` | `blocking`)
   306	- **Recovery:** founder schedules + completes Open Banking SCA reauth via tenant's bank login
   307	
   308	### 2.8 — Provider read/write failures (4 codes)
   309	Source: derived from v1.0 agent.md adapter call sites
   310	
   311	#### `ESC_BULLHORN_WRITE_FAIL`
   312	- **Severity:** warn
   313	- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
   314	- **Phase:** `gating_failed`
   315	- **Routing:** `operator_chat_id`
   316	- **Payload fields:** `endpoint`, `entity_type`, `entity_id`, `status_code`, `error_body_preview` (truncated 120 chars)
   317	
   318	#### `ESC_ACCOUNTING_WRITE_FAIL`
   319	- **Severity:** warn
   320	- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
   321	- **Phase:** `gating_failed`
   322	- **Routing:** `operator_chat_id`
   323	- **Payload fields:** `provider`, `endpoint`, `entity_type`, `status_code`, `error_body_preview`
   324	
   325	#### `ESC_PROVIDER_FETCH_FAIL`
   326	- **Severity:** warn
   327	- **Trigger:** Generic upstream provider read failure (Companies House, web-scraper, any non-Bullhorn-non-Accounting GET) after retry budget exhausted; distinct from rate-limit
   328	- **Phase:** `gating_failed`
   329	- **Routing:** `operator_chat_id`
   330	- **Payload fields:** `upstream` (e.g. `companies-house`, `web-scraper`, `linkedin-cache`), `endpoint`, `status_code`, `consecutive_failures`
   331	
   332	#### `ESC_SEND_FAIL`
   333	- **Severity:** warn — distinct from auth/rate-limit; the send itself failed at the protocol layer
   334	- **Trigger:** External send (Gmail / Outlook / Twilio / Telegram-to-customer) returned 5xx or transport error after retry budget
   335	- **Phase:** `gating_failed`
   336	- **Routing:** `operator_chat_id`
   337	- **Payload fields:** `channel` (`gmail` | `outlook` | `twilio` | `telegram`), `recipient_id_hash`, `error_class`, `attempts_made`
   338	
   339	### 2.9 — Auto-send orchestration (4 codes)
   340	Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics
   341	
   342	#### `ESC_AUTOSEND_ORANGE_PENDING`
   343	- **Severity:** info — distinct from ESC_AUTOSEND_NEEDS_REVIEW (which is the initial queue event)
   344	- **Trigger:** Orange-tier action has been pending operator response for ≥50% of declared `timeout` (heartbeat reminder before bridge timeout)
   345	- **Phase:** `action`
   346	- **Routing:** `operator_chat_id` (gentle reminder; no oncall)
   347	- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`
   348	
   349	#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
   350	- **Severity:** warn — orange action's approval window expired without response
   351	- **Trigger:** Orange-tier action exceeded its `timeout` (default PT4H) without operator approve/reject
   352	- **Phase:** `gating_failed`
   353	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (operator absent + commitment may need rerouting)
   354	- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
   355	- **Recovery:** action converts to manual reconciliation; operator handles offline
   356	
   357	#### `ESC_AUTOSEND_RACE`
   358	- **Severity:** warn — concurrency / state-change race
   359	- **Trigger:** A send is about to fire when the underlying state has changed in a way that should suppress it. Two canonical use cases:
   360	  - **Duplicate-payload race:** two agents attempted to send the same `payload_hash` within same tenant within `race_window_seconds` (default 60s); second attempt detected by `decision_log` UPSERT-conflict; second wins-suppressed (first sends; idempotency by payload_hash)
   361	  - **State-change race (Cash Conductor):** payment received between chase-draft and chase-send window; the invoice is no longer overdue when the orange-tier approval fires; chase cancelled (do NOT send) per Cash Conductor §4 Step 12
   362	- **Phase:** `gating_failed`
   363	- **Routing:** `operator_chat_id`
   364	- **Payload fields:** `race_class` (`duplicate_payload` | `state_change_cancellation`), `payload_hash`, class-specific: duplicate → `first_agent_name`, `second_agent_name`, `time_delta_ms`, `action_type`; state-change → `entity_id`, `state_before`, `state_after`, `time_delta_ms`
   365	- **Recovery:** duplicate → second suppressed; state-change → cancelled draft logged; no operator action required beyond informational review
   366	
   367	#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
   368	- **Severity:** info — quality sampling, not a failure
   369	- **Trigger:** Yellow-tier action was sampled per `sample_rate` (1-in-N) for post-hoc human review; sampling is informational + drives ongoing quality monitoring
   370	- **Phase:** `action`
   371	- **Routing:** `operator_chat_id`; sampled action is queued in `spot_check_queue_path` (`/vault/{tenant_slug}/spot-checks/`)
   372	- **Payload fields:** `action_type`, `original_decision_log_id`, `sample_rate`, `sampling_reason`, `target`, `payload_preview`
   373	- **Note:** Operator review of sampled rows is asynchronous (typically end-of-day batch); no SLA timer.
   374	
   375	### 2.10 — Agent workflow (10 codes)
   376	Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
   377	
   378	#### `ESC_GATE_B_MISS`
   379	- **Severity:** warn — post-send quality signal; not a hard failure
   380	- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
   381	- **Phase:** `gating_failed`
   382	- **Routing:** `operator_chat_id`
   383	- **Payload fields:** `agent_name`, `metric_name`, `actual_value`, `threshold`, `window`, `sample_size`
   384	- **Note:** Local Gate B is a leading metric for agent quality; consecutive misses inform per-agent quality review. Not tied to a kill-criterion trigger in v1.0 (per disagreement-doc Cat-3 disposition).
   385	
   386	#### `ESC_TONE_RULE_VIOLATION`
   387	- **Severity:** warn — voice/tone classifier flagged output as violating a tenant `tone_rule` row
   388	- **Trigger:** Output drafted by an agent matches a tenant-defined `tone_rule` violation pattern (e.g. tenant prohibits "absolutely" in customer-facing comms; output contained it)
   389	- **Phase:** `gating_failed`
   390	- **Routing:** `operator_chat_id`

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
   606	### 8.3 The working pattern in Claude Code
   607	
   608	For any new agent:
   609	
   610	```bash
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

exec
/bin/zsh -lc 'rg -n "janitor_dedup_threshold|janitor_last_run|tenant_adapters_config_additions|recent_edit|Janitor" docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:12:# (v0.3-supplement-0.1 amendment Day-20: original 3 v0.3 keys + 2 Janitor keys
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:13:# added closing Janitor R11 Finding 4 + blocked_recipients added closing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:95:          Janitor/Scribe (which hold W) if a sourced candidate is promoted;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:96:          Janitor uses for dedup (stronger match signal than name+email);
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:99:        source: IFOS-derived (Scribe/Janitor write to the candidate entity; Sourcing Scout surfaces match URLs in its shortlist artefact only; Janitor uses for dedup verification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:102:          - Janitor: R   # W only via dedup-merge action
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:182:          confirming candidate started. Janitor flags ambiguous via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:184:        source: IFOS-derived (Scribe + Janitor)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:187:          - Janitor: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:278:#   - Janitor contact: R → R+W (dedup + field-backfill on contacts; same
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:280:#   - Janitor opportunity: none → R (reads opportunity context for cleanup)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:281:#   - Janitor placement: R → R+W (lifecycle-state cleanup writes —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:283:#   - Janitor timesheet: none → R (reads for placement-state inference)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:311:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:313:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:327:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:335:  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:355:  #   gets R on linkedin_url (entity-level default), not the broader Janitor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:356:  #   R+W on candidate.linkedin_url (Janitor.candidate is R+W at entity level
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:413:    # (populated by Janitor + Scribe + Concierge from their Bullhorn
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:472:    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:475:      - Janitor (R+W)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:488:      - Janitor (R+W)      # v0.3 UPGRADED — dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:494:      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:495:      preferred_channel + next_action_target_date; Janitor also dedup-merges).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:499:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:501:      - Janitor (R)        # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:511:    v0_1_v1_0_agent_access: [Janitor (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:514:      - Janitor (R)        # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:520:      v0.1 opportunity is sparsely accessed (Janitor only); v0.3 broadens
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:526:    v0_1_v1_0_agent_access: [Janitor (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:528:      - Janitor (R+W)      # v0.3 UPGRADED — lifecycle-state cleanup writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:533:      v0.3 upgrades Janitor + Concierge to R+W (lifecycle-state writes per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:539:      - Janitor (R)        # v0.3 NEW — reads for placement-state inference
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:544:      v0.1 timesheet is Cash Conductor only. v0.3 grants R to Janitor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:549:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:552:      - Janitor (R+W)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:565:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:567:      - Janitor (R+W)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:579:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:582:      §12 conversation opener; Janitor for tacit-note narratives; Cash
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:589:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:591:      Janitor agent.md §7 calls hh_load_tone_rules filtered by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:593:      voice-classification. Per Round-8 Cat-β finding for Janitor.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:597:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:603:      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:609:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:610:      for retraining queue). Janitor adds R for tacit-note harvest per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:728:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:731:    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:762:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:808:  janitor_dedup_threshold:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:821:      added Day-20 W4 bilateral pass closing Janitor R11 Codex Finding 4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:842:  janitor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:848:      Janitor nightly cron updates at session-close (Step 12). Next run queries
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:852:      (Day-20) closing Janitor R11 Codex Finding 4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:927:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:975:      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1018:  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1021:  new + 2 Janitor + 1 blocked_recipients pre-v0.3 canonicalised). The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1040:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:350:  recent_edit_drives_retraining:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:9:-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:52:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:53:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:434:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:435:    'janitor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:492:  -- janitor_dedup_threshold: number in [0.75, 0.95] per supplement default 0.85
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:493:  IF c ? 'janitor_dedup_threshold' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:494:    IF jsonb_typeof(c->'janitor_dedup_threshold') != 'number' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:495:      RAISE EXCEPTION 'janitor_dedup_threshold must be number';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:497:    IF (c->>'janitor_dedup_threshold')::numeric < 0.75
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:498:       OR (c->>'janitor_dedup_threshold')::numeric > 0.95 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:499:      RAISE EXCEPTION 'janitor_dedup_threshold out of [0.75, 0.95] range: %', c->>'janitor_dedup_threshold';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:503:  -- janitor_last_run: ISO-8601 timestamp string or null
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:504:  IF c ? 'janitor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:505:    IF jsonb_typeof(c->'janitor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:506:      RAISE EXCEPTION 'janitor_last_run must be ISO-8601 timestamp string or null';

codex
The source citations for the build wave, ULTRAPLAN A2 rows, schema field line numbers, and the listed escalation catalogue entries are mostly landing where the artefact says they do. I’m now comparing a few specific implementation claims against `cycle.sh`, `validate.sh`, and `tools.yaml`.
exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/validate.sh | sed -n '1,260p;260,560p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/cycle.sh | sed -n '1,140p;650,780p;780,860p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Janitor agent — validate.sh (Gate A enforcement; W6-7 LIVE)
     3	#
     4	# Status: LIVE per spec-001 §5 (W6-7 build slice) — all 7 checks enforced.
     5	# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
     6	#
     7	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
     8	# hard-fail gate that runs BETWEEN write batch generation (cycle.sh Step 9
     9	# proposal phase) and the actual @ifos/bullhorn write call. If any check fails,
    10	# validate.sh exits non-zero + emits the mandatory validate_gate_a_fail action
    11	# row + the per-class ESC_* escalation row to decision_log; the proposed write
    12	# does NOT execute; cycle.sh skips that proposal + continues.
    13	#
    14	# Invocation contract:
    15	#   bash validate.sh <write_proposal_json>
    16	#
    17	# Inputs:
    18	#   - $1: path to a JSON file describing the proposed Bullhorn write. Shape:
    19	#         {
    20	#           "action_type": "bullhorn_candidate_dedupe" | "bullhorn_field_backfill" |
    21	#                          "bullhorn_note_attach",
    22	#           "entity_type": "candidate" | "contractor" | "contact" | "client",
    23	#           "primary_id": <bullhorn_id>,
    24	#           "merge_target_id": <bullhorn_id>,    // only for dedupe action_type
    25	#           "confidence": <float 0.0-1.0>,       // only for dedupe action_type
    26	#           "match_dimensions": ["name", "email", "phone", "linkedin"],
    27	#           "last_activity_days": <int>,         // dedupe: MIN(days) across the pair
    28	#           "voice_score": <float|"unscored">,   // only for note_attach action_type
    29	#           "narrative_body": "...",             // only for note_attach action_type
    30	#           "field_changes": { "<field>": "<new_value>" },  // backfill
    31	#           "source": "companies_house" | "linkedin" | "derivation",  // backfill
    32	#           "source_confidence": <float 0.0-1.0> // backfill
    33	#         }
    34	#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_AGENT_DIR,
    35	#          CTX_JANITOR_DEDUP_THRESHOLD (default 0.85),
    36	#          CTX_FIRM_DOMAIN_WHITELIST (G6 boundary; conservative default),
    37	#          CTX_JANITOR_BATCH_INDEX (G7; 1-based position in this run's batch)
    38	#
    39	# Exit codes:
    40	#   0  All Gate A checks pass; cycle.sh proceeds to actual write
    41	#   1  At least one check failed; validate_gate_a_fail + ESC_* rows emitted;
    42	#      cycle.sh skips this write
    43	#   2  validate.sh invocation error (bad args, missing file, etc.)
    44	#
    45	# Checks (per agent.md §5 Gate A + spec-001 §5):
    46	#   G1 — Bullhorn auth refresh succeeded in Step 1 (no stale-token writes).
    47	#         Hard-fails on token_state:failed; a degraded/absent state (creds
    48	#         founder-gated → no live write possible; cycle.sh defers transport)
    49	#         is a WARN — there is no stale-token risk when no token exists.
    50	#   G2 — Dedup proposal: confidence ≥ CTX_JANITOR_DEDUP_THRESHOLD (default 0.85;
    51	#         per ULTRAPLAN A2 line 510 + tenant override range [0.75, 0.95])
    52	#         → ESC_AGENT_OUTPUT_SHAPE
    53	#   G3 — Dedup proposal: NEITHER record has Bullhorn activity in last 90 days
    54	#         (per ULTRAPLAN A2 line 510 verbatim). Recent (or UNKNOWN) activity →
    55	#         REJECT the auto-write + ESC_DUPLICATE_DETECTED (SUCCESS-path Telegram
    56	#         approval gate per catalogue §2.5; NOT a Gate A failure code).
    57	#   G4 — Field-backfill: source_confidence ≥0.7 (CH 404 / LinkedIn empty / no
    58	#         derivation source → fail) → ESC_AGENT_OUTPUT_SHAPE
    59	#   G5 — Tacit-note narrative: voice classifier ≥0.75. Hard-when-scored;
    60	#         warn-when-unscored (empty voice_corpus → unscored/no_corpus per CC
    61	#         honesty precedent) → ESC_VOICE_DRIFT
    62	#   G6 — No PII outside firm boundary in tacit-note narratives (regex pass)
    63	#         → ESC_PII_LEAKAGE_RISK (BLOCKING; precedence over all other classes)
    64	#   G7 — Write batch size: this proposal's batch index ≤ 100/min defensive cap
    65	#         (per agent.md §5) → ESC_AGENT_OUTPUT_SHAPE (spec-001 §5 routing)
    66	
    67	set -uo pipefail
    68	
    69	# ────────────────────────────────────────────────────────────────────────
    70	# Pre-flight
    71	# ────────────────────────────────────────────────────────────────────────
    72	
    73	if [[ $# -lt 1 ]]; then
    74	  printf 'janitor/validate.sh: usage: validate.sh <write_proposal_json>\n' >&2
    75	  exit 2
    76	fi
    77	
    78	readonly PROPOSAL="$1"
    79	
    80	if [[ ! -f "${PROPOSAL}" ]]; then
    81	  printf 'validate.sh: proposal not found at %s\n' "${PROPOSAL}" >&2
    82	  exit 2
    83	fi
    84	
    85	if [[ -z "${CTX_TENANT_SLUG:-}" || -z "${CTX_AGENT_NAME:-}" ]]; then
    86	  printf 'validate.sh: CTX_TENANT_SLUG or CTX_AGENT_NAME unset\n' >&2
    87	  exit 2
    88	fi
    89	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    90	  printf 'validate.sh: CTX_AGENT_DIR unset\n' >&2
    91	  exit 2
    92	fi
    93	command -v jq >/dev/null 2>&1 || { printf 'validate.sh: jq required\n' >&2; exit 2; }
    94	jq -e . "${PROPOSAL}" >/dev/null 2>&1 || { printf 'validate.sh: proposal is not valid JSON\n' >&2; exit 2; }
    95	
    96	# Resolve _shared/ helpers (4-candidate fallback; matches sibling agents
    97	# per smoke-hotfix commit d7d52c5).
    98	_SHARED_DIR=""
    99	for _candidate in \
   100	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
   101	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
   102	  "${CTX_AGENT_DIR}/../../_shared" \
   103	  "${CTX_AGENT_DIR}/../_shared" ; do
   104	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
   105	    _SHARED_DIR="${_candidate}"
   106	    break
   107	  fi
   108	done
   109	if [[ -z "${_SHARED_DIR}" ]]; then
   110	  printf 'validate.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
   111	  exit 2
   112	fi
   113	# shellcheck source=/dev/null
   114	source "${_SHARED_DIR}/hook-helpers.sh"
   115	
   116	# Track failures + warnings across all checks (collect all before exit for richer audit)
   117	declare -a FAILURES=()
   118	declare -a WARNINGS=()
   119	
   120	_fail() {
   121	  FAILURES+=("$1")
   122	  printf '  ✗ %s\n' "$1" >&2
   123	}
   124	_warn() {
   125	  WARNINGS+=("$1")
   126	  printf '  ! %s\n' "$1" >&2
   127	}
   128	_ok() {
   129	  printf '  ✓ %s\n' "$1"
   130	}
   131	
   132	# Dominant failure class for ESC routing. First hard fail sets it;
   133	# ESC_PII_LEAKAGE_RISK (blocking) takes precedence over every other class
   134	# (Scout Gate A precedence precedent).
   135	ESC_CLASS=""
   136	_set_esc() {
   137	  if [[ "$1" == "ESC_PII_LEAKAGE_RISK" ]]; then
   138	    ESC_CLASS="ESC_PII_LEAKAGE_RISK"
   139	  else
   140	    ESC_CLASS="${ESC_CLASS:-$1}"
   141	  fi
   142	}
   143	
   144	# Dedup threshold env (default per ULTRAPLAN A2 line 510 verbatim; per-tenant
   145	# override range [0.75, 0.95] enforced by validate_tenant_adapters_config_v0_3
   146	# trigger on tenant_adapters.config.janitor_dedup_threshold)
   147	readonly DEDUP_THRESHOLD="${CTX_JANITOR_DEDUP_THRESHOLD:-0.85}"
   148	
   149	_p() { jq -r "$1 // empty" "${PROPOSAL}" 2>/dev/null; }
   150	ACTION_TYPE="$(_p '.action_type')"
   151	PRIMARY_ID="$(_p '.primary_id')"
   152	
   153	case "${ACTION_TYPE}" in
   154	  bullhorn_candidate_dedupe|bullhorn_field_backfill|bullhorn_note_attach) : ;;
   155	  *)
   156	    printf 'validate.sh: unknown proposal action_type %s\n' "${ACTION_TYPE:-<empty>}" >&2
   157	    exit 2 ;;
   158	esac
   159	
   160	# ────────────────────────────────────────────────────────────────────────
   161	# G1 — Bullhorn auth refresh succeeded in Step 1 (no stale-token writes)
   162	# Re-queries decision_log for this session's bullhorn_auth_refresh row.
   163	# token_state failed → HARD FAIL (stale-token write risk) + ESC_BULLHORN_AUTH.
   164	# token_state absent/degraded (creds founder-gated) → WARN: no live Bullhorn
   165	# write can occur (cycle.sh records write_state:deferred), so there is no
   166	# stale-token risk to gate.
   167	# ────────────────────────────────────────────────────────────────────────
   168	
   169	_g1_state=""
   170	if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   171	  _g1_row="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
   172	    --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1 || true
   173	BEGIN;
   174	SET LOCAL app.current_tenant = :'tenant';
   175	SELECT reason FROM decision_log
   176	WHERE tenant_slug = :'tenant' AND agent_name = 'janitor'
   177	  AND phase = 'output' AND payload->>'output_type' = 'bullhorn_auth_refresh'
   178	  AND created_at > now() - interval '10 minutes'
   179	ORDER BY id DESC LIMIT 1;
   180	COMMIT;
   181	SQL
   182	)"
   183	  _g1_state="$(printf '%s' "${_g1_row}" | grep -oE 'bullhorn_token_state:[a-z_]+' | cut -d: -f2 || true)"
   184	fi
   185	if [[ "${_g1_state}" == "failed" ]]; then
   186	  _fail "G1: Bullhorn auth refresh FAILED this session — stale-token write blocked"
   187	  _set_esc "ESC_BULLHORN_AUTH"
   188	elif [[ "${_g1_state}" == "ok" || "${_g1_state}" == "fixture" ]]; then
   189	  _ok "G1: Bullhorn auth refresh fresh (token_state:${_g1_state})"
   190	else
   191	  _warn "G1: Bullhorn auth state '${_g1_state:-no_recent_row}' — no live token (creds founder-gated); write transport defers, no stale-token risk"
   192	fi
   193	
   194	# ────────────────────────────────────────────────────────────────────────
   195	# G2 — Dedup confidence ≥ threshold (default 0.85; per-tenant override range)
   196	# Per ULTRAPLAN A2 line 510. Sub-0.70 silently drops in the Step 3 matcher
   197	# (no proposal reaches here). 0.70-0.85 → review-band (held upstream, never
   198	# proposed for auto-write); a proposal below threshold reaching this gate is
   199	# an output-shape violation.
   200	# ────────────────────────────────────────────────────────────────────────
   201	
   202	if [[ "${ACTION_TYPE}" == "bullhorn_candidate_dedupe" ]]; then
   203	  _g2_conf="$(_p '.confidence')"
   204	  if [[ "${_g2_conf}" =~ ^[0-9]+(\.[0-9]+)?$ ]] \
   205	     && awk -v c="${_g2_conf}" -v t="${DEDUP_THRESHOLD}" 'BEGIN{exit !(c>=t)}'; then
   206	    _ok "G2: dedup confidence ${_g2_conf} ≥ ${DEDUP_THRESHOLD}"
   207	  else
   208	    _fail "G2: dedup confidence '${_g2_conf:-missing}' < ${DEDUP_THRESHOLD}"
   209	    _set_esc "ESC_AGENT_OUTPUT_SHAPE"
   210	  fi
   211	else
   212	  _ok "G2: N/A (not a dedupe proposal)"
   213	fi
   214	
   215	# ────────────────────────────────────────────────────────────────────────
   216	# G3 — No Bullhorn activity in last 90 days (per ULTRAPLAN A2 line 510 verbatim)
   217	# Recent activity = placement / interview / note in last 90d on EITHER side
   218	# (proposal carries the pair MIN as last_activity_days). Recent OR UNKNOWN →
   219	# REJECT this auto-write + ESC_DUPLICATE_DETECTED (SUCCESS-path Telegram
   220	# approval gate per catalogue §2.5 — the proposal is not erroneous; the
   221	# operator decides).
   222	# ────────────────────────────────────────────────────────────────────────
   223	
   224	if [[ "${ACTION_TYPE}" == "bullhorn_candidate_dedupe" ]]; then
   225	  _g3_days="$(_p '.last_activity_days')"
   226	  if [[ "${_g3_days}" =~ ^[0-9]+$ && "${_g3_days}" -ge 90 ]]; then
   227	    _ok "G3: no Bullhorn activity in last 90d (min ${_g3_days}d)"
   228	  else
   229	    _fail "G3: pair has recent/unknown Bullhorn activity (last_activity_days='${_g3_days:-unknown}') — auto-write rejected; operator approval gate fires"
   230	    _set_esc "ESC_DUPLICATE_DETECTED"
   231	  fi
   232	else
   233	  _ok "G3: N/A (not a dedupe proposal)"
   234	fi
   235	
   236	# ────────────────────────────────────────────────────────────────────────
   237	# G4 — Field-backfill source confidence ≥0.7
   238	# CH 404 / LinkedIn empty / no derivation source → low-confidence; reject.
   239	# ────────────────────────────────────────────────────────────────────────
   240	
   241	if [[ "${ACTION_TYPE}" == "bullhorn_field_backfill" ]]; then
   242	  _g4_conf="$(_p '.source_confidence')"
   243	  _g4_src="$(_p '.source')"
   244	  if [[ "${_g4_conf}" =~ ^[0-9]+(\.[0-9]+)?$ ]] \
   245	     && awk -v c="${_g4_conf}" 'BEGIN{exit !(c>=0.7)}'; then
   246	    _ok "G4: backfill source_confidence ${_g4_conf} ≥ 0.7 (source:${_g4_src:-unknown})"
   247	  else
   248	    _fail "G4: backfill source_confidence '${_g4_conf:-missing}' < 0.7 (source:${_g4_src:-unknown})"
   249	    _set_esc "ESC_AGENT_OUTPUT_SHAPE"
   250	  fi
   251	else
   252	  _ok "G4: N/A (not a backfill proposal)"
   253	fi
   254	
   255	# ────────────────────────────────────────────────────────────────────────
   256	# G5 — Tacit-note voice classifier ≥0.75
   257	# Per agent.md §7. Hard-when-scored; warn-when-unscored (empty tenant
   258	# voice_corpus → unscored/no_corpus, never a faked number — CC precedent).
   259	# ────────────────────────────────────────────────────────────────────────
   260	
   260	
   261	if [[ "${ACTION_TYPE}" == "bullhorn_note_attach" ]]; then
   262	  _g5_score="$(_p '.voice_score')"
   263	  if [[ "${_g5_score}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
   264	    if awk -v s="${_g5_score}" 'BEGIN{exit !(s>=0.75)}'; then
   265	      _ok "G5: tacit-note voice score ${_g5_score} ≥ 0.75"
   266	    else
   267	      _fail "G5: tacit-note voice score ${_g5_score} < 0.75 (after retries)"
   268	      _set_esc "ESC_VOICE_DRIFT"
   269	    fi
   270	  else
   271	    _warn "G5: voice unscored (${_g5_score:-none}) — no tenant voice_corpus; threshold unenforceable (documented enhancement)"
   272	  fi
   273	else
   274	  _ok "G5: N/A (not a note proposal)"
   275	fi
   276	
   277	# ────────────────────────────────────────────────────────────────────────
   278	# G6 — No PII outside firm boundary in tacit-note narrative
   279	# Regex pass against narrative_body; email addresses NOT on the tenant
   280	# firm-domain whitelist → fail + ESC_PII_LEAKAGE_RISK (blocking; operator +
   281	# ifos_oncall routing; precedence over every other failure class).
   282	# ────────────────────────────────────────────────────────────────────────
   283	
   284	if [[ "${ACTION_TYPE}" == "bullhorn_note_attach" ]]; then
   285	  _g6_body="$(_p '.narrative_body')"
   286	  _g6_emails="$(printf '%s' "${_g6_body}" \
   287	    | grep -oiE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' | sort -u || true)"
   288	  _g6_ext=0
   289	  if [[ -n "${_g6_emails}" ]]; then
   290	    _g6_allow="${CTX_FIRM_DOMAIN_WHITELIST:-}"
   291	    while IFS= read -r _em; do
   292	      [[ -z "${_em}" ]] && continue
   293	      _dom="$(printf '%s' "${_em##*@}" | tr '[:upper:]' '[:lower:]')"
   294	      _hit=0
   295	      for _allowed in ${_g6_allow//,/ }; do
   296	        [[ -n "${_allowed}" && "${_dom}" == "$(printf '%s' "${_allowed}" | tr '[:upper:]' '[:lower:]')" ]] && _hit=1
   297	      done
   298	      [[ "${_hit}" -eq 0 ]] && _g6_ext=1
   299	    done <<<"${_g6_emails}"
   300	  fi
   301	  if [[ "${_g6_ext}" -eq 1 ]]; then
   302	    _fail "G6: narrative contains email address(es) outside the firm boundary (whitelist: ${CTX_FIRM_DOMAIN_WHITELIST:-<unset>})"
   303	    _set_esc "ESC_PII_LEAKAGE_RISK"
   304	  else
   305	    _ok "G6: no PII outside firm boundary in narrative"
   306	  fi
   307	else
   308	  _ok "G6: N/A (not a note proposal)"
   309	fi
   310	
   311	# ────────────────────────────────────────────────────────────────────────
   312	# G7 — Write batch size sanity (this proposal's batch index ≤ 100/min cap)
   313	# Defensive per agent.md §5; routing ESC_AGENT_OUTPUT_SHAPE per spec-001 §5.
   314	# Cross-checks @ifos/bullhorn's own per-corp 600/min hard limiter — the agent
   315	# cap (100/min) is deliberately far inside it (agent.md §9 Q3: Bullhorn's
   316	# published limit is undocumented; conservative until Sub-decision B answers).
   317	# ────────────────────────────────────────────────────────────────────────
   318	
   319	_g7_idx="${CTX_JANITOR_BATCH_INDEX:-1}"
   320	if [[ "${_g7_idx}" =~ ^[0-9]+$ && "${_g7_idx}" -le 100 ]]; then
   321	  _ok "G7: batch index ${_g7_idx} ≤ 100/min cap"
   322	else
   323	  _fail "G7: batch index '${_g7_idx}' exceeds the 100/min defensive cap — remainder defers to the next run"
   324	  _set_esc "ESC_AGENT_OUTPUT_SHAPE"
   325	fi
   326	
   327	# ────────────────────────────────────────────────────────────────────────
   328	# Verdict + audit-row emission
   329	# ────────────────────────────────────────────────────────────────────────
   330	
   331	printf '\nJanitor validate Gate A: '
   332	if [[ ${#FAILURES[@]} -gt 0 ]]; then
   333	  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
   334	  # Per-failure-class routing (agent.md §5/§6):
   335	  #   G1 → ESC_BULLHORN_AUTH (blocking) · G2/G4/G7 → ESC_AGENT_OUTPUT_SHAPE
   336	  #   G3 → ESC_DUPLICATE_DETECTED (SUCCESS-path approval gate)
   337	  #   G5 → ESC_VOICE_DRIFT · G6 → ESC_PII_LEAKAGE_RISK (blocking; precedence)
   338	  _v_hash="$(shasum -a 256 "${PROPOSAL}" 2>/dev/null | cut -c1-16)"
   339	  [[ -z "${_v_hash}" ]] && _v_hash="proposal-${PRIMARY_ID:-unknown}"
   340	  hh_decision_action "validate_gate_a_fail" "tenant:${CTX_TENANT_SLUG}" "${_v_hash}" \
   341	    "${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}; agent_name:janitor; action_type:${ACTION_TYPE}; primary_id:${PRIMARY_ID:-unknown}; failures:${#FAILURES[@]}; first:${FAILURES[0]}" || true
   342	  if [[ "${ESC_CLASS:-}" == "ESC_DUPLICATE_DETECTED" ]]; then
   343	    # G3 hold — emit the amended catalogue §2.5 payload shape (entity ids,
   344	    # confidence, match basis, hold reason). G3 only fires on recent/unknown
   345	    # activity, so hold_reason is always the recency class here.
   346	    autosend_escalate "ESC_DUPLICATE_DETECTED" "agent=janitor" \
   347	      "tenant=${CTX_TENANT_SLUG}" "action_type=${ACTION_TYPE}" \
   348	      "entity_a_id=${PRIMARY_ID:-unknown}" "entity_b_id=$(_p '.merge_target_id')" \
   349	      "entity_type=$(_p '.entity_type')" "confidence_score=$(_p '.confidence')" \
   350	      "match_basis=$(jq -r '(.match_dimensions // []) | join("+")' "${PROPOSAL}" 2>/dev/null)" \
   351	      "hold_reason=recency_hold_90d" "failures=${#FAILURES[@]}" \
   352	      "proposal=${PROPOSAL}"
   353	  else
   354	    autosend_escalate "${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}" "agent=janitor" \
   355	      "tenant=${CTX_TENANT_SLUG}" "action_type=${ACTION_TYPE}" \
   356	      "primary_id=${PRIMARY_ID:-unknown}" "failures=${#FAILURES[@]}" \
   357	      "proposal=${PROPOSAL}"
   358	  fi
   359	  exit 1
   360	fi
   361	printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
   362	exit 0

 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Janitor agent — cycle.sh (12-step nightly cron orchestration; W6-7 LIVE)
     3	#
     4	# Status: LIVE per spec-001 §4 (W6-7 build slice) — every step wired.
     5	# Reading order: agent.md §1 (output contract) + §3 (2 outputs: day-30 report
     6	#         + Bullhorn yellow-tier writes) + §4 (this workflow's 12 steps) +
     7	#         §5 (Gate A + Gate B) first.
     8	#
     9	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
    10	# produces output OR takes action MUST call hh_decision_* from
    11	# agents/_shared/hook-helpers.sh.
    12	#
    13	# v1.0 Bullhorn disposition (spec-001 §8 honest scope): Bullhorn creds are
    14	# EMPTY today (founder-gated; dev-support enquiry pending). The @ifos/bullhorn
    15	# dist/cli.js bridge is BUILT and wired below; until creds land the agent runs
    16	# in DEGRADED mode — Step 2 scans the Postgres `entities` Bullhorn cache,
    17	# Step 9 validates every write through Gate A and records the yellow action
    18	# row with write_state:deferred_no_bullhorn_creds (transport executes when
    19	# creds land; never faked). Companies House (Step 6) is live-capable (key SET).
    20	#
    21	# Invocation modes (per agent.md §2):
    22	#   mode=full-cleanup   — nightly cron 02:00 UTC: all 12 steps (default)
    23	#   mode=incremental    — cron catch-up: Steps 1-4 + 8-9 + 12 (skip enrichment +
    24	#                         day-30 report assembly; the next full-cleanup picks them up)
    25	#   mode=report-only    — Steps 1 + 10 + 12 only (regenerate day-30 report without
    26	#                         writes; used post-incident per agent.md §2 manual trigger)
    27	#   mode=dry-run        — Steps 1-8 + 10 + 12 only (no Bullhorn writes; report
    28	#                         shows what WOULD have been written)
    29	#
    30	# Deterministic test hooks (fixtures; documented, never used in production):
    31	#   IFOS_JANITOR_FIXTURE_BULLHORN_AUTH = ok|failed — force the Step 1 token
    32	#       state without creds (context.sh consumes; cycle.sh re-reads CTX var)
    33	#   IFOS_JANITOR_FIXTURE_CH = <path.json> — array of {query, crn, industry,
    34	#       source_confidence} rows; Step 6 resolves client names against it
    35	#       instead of the live Companies House API (zero network in tests)
    36	#   IFOS_JANITOR_FIXTURE_WRITE_RESULT = ok|4xx|5xx — simulate the Step 9
    37	#       Bullhorn write outcome (exercises ESC_BULLHORN_WRITE_FAIL routes)
    38	#   IFOS_JANITOR_FORCE_VOICE_SCORE = <0..1> — numeric voice score for Step 8
    39	#       narratives (exercises the G5 ESC_VOICE_DRIFT route; corpus-empty runs
    40	#       record unscored/no_corpus, never a faked number)
    41	#   IFOS_JANITOR_NO_LLM = 1 — pin Step 8 narratives to the deterministic
    42	#       template (no Anthropic call even when ANTHROPIC_API_KEY is set)
    43	#   IFOS_JANITOR_RETRY_DELAY_S — overrides the 30s/60s backoff sleeps (tests: 0)
    44	#
    45	# Package dependencies:
    46	#   @ifos/bullhorn        — dist/cli.js bridge (check-auth/refresh/list-*/
    47	#                           update-candidate/update-client/create-note)
    48	#   @ifos/companies-house — client enrichment via bin/ch-lookup.mjs (7d cache
    49	#                           + shared 600/5min budget inside the connector)
    50	#
    51	# Output contract per agent.md §1 (READ THAT FIRST). Two outputs:
    52	#   1. Day-30 Markdown report → /vault/<tenant>/janitor-reports/day-30-<ISO>.md
    53	#   2. Yellow-tier Bullhorn writes (3 action_types REGISTERED in autosend-policy.yaml):
    54	#      bullhorn_candidate_dedupe + bullhorn_field_backfill + bullhorn_note_attach
    55	#
    56	# Per agent.md §5 Gate A: hard-fail any merge proposal with confidence <0.85;
    57	# review-band pairs (0.70–0.85 OR ≥0.85 with recent activity) held for synchronous
    58	# Telegram approval via ESC_DUPLICATE_DETECTED (SUCCESS path; fired at Steps 3-4).
    59	
    60	set -euo pipefail
    61	
    62	# ────────────────────────────────────────────────────────────────────────
    63	# Pre-flight: hydrate context + resolve _shared/ helpers
    64	# ────────────────────────────────────────────────────────────────────────
    65	
    66	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    67	  printf 'janitor/cycle.sh: CTX_AGENT_DIR unset\n' >&2
    68	  exit 2
    69	fi
    70	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    71	  printf 'janitor/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
    72	  exit 2
    73	fi
    74	: "${CTX_AGENT_NAME:=janitor}"
    75	export CTX_AGENT_NAME CTX_AGENT_DIR CTX_TENANT_SLUG   # inherited by validate.sh subprocess (Step 9)
    76	
    77	command -v jq >/dev/null 2>&1 || { printf 'cycle.sh: jq required\n' >&2; exit 2; }
    78	
    79	# Resolve _shared/ helpers (4-candidate chain per smoke-hotfix commit d7d52c5
    80	# mirrored from sibling agent bundles).
    81	_SHARED_DIR=""
    82	for _candidate in \
    83	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    84	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    85	  "${CTX_AGENT_DIR}/../../_shared" \
    86	  "${CTX_AGENT_DIR}/../_shared" ; do
    87	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    88	    _SHARED_DIR="${_candidate}"
    89	    break
    90	  fi
    91	done
    92	if [[ -z "${_SHARED_DIR}" ]]; then
    93	  printf 'cycle.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
    94	  exit 1
    95	fi
    96	# shellcheck source=/dev/null
    97	source "${_SHARED_DIR}/hook-helpers.sh"
    98	
    99	# bin/ helper resolution (agent dir first, repo source-tree fallback).
   100	_jn_bin() {
   101	  local helper="$1"
   102	  if [[ -f "${CTX_AGENT_DIR}/bin/${helper}" ]]; then
   103	    printf '%s' "${CTX_AGENT_DIR}/bin/${helper}"
   104	  else
   105	    printf '%s' "${IFOS_REPO_ROOT:-}/agents/recruitment/janitor/bin/${helper}"
   106	  fi
   107	}
   108	# sql/ helper resolution (same chain).
   109	_jn_sql() {
   110	  local f="$1"
   111	  if [[ -f "${CTX_AGENT_DIR}/sql/${f}" ]]; then
   112	    printf '%s' "${CTX_AGENT_DIR}/sql/${f}"
   113	  else
   114	    printf '%s' "${IFOS_REPO_ROOT:-}/agents/recruitment/janitor/sql/${f}"
   115	  fi
   116	}
   117	
   118	# Connector base + secrets (Path A: values sourced into env, never printed —
   119	# mirrors cash-conductor/cycle.sh Step 1).
   120	_JN_CONN_BASE="${IFOS_REPO_ROOT:+${IFOS_REPO_ROOT}/packages/mcp-connectors}"
   121	if [[ -z "${_JN_CONN_BASE}" || ! -d "${_JN_CONN_BASE}" ]]; then
   122	  _JN_CONN_BASE="${_SHARED_DIR}/../../packages/mcp-connectors"
   123	fi
   124	_JN_SECRETS="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
   125	if [[ -f "${_JN_SECRETS}" ]]; then
   126	  set -a
   127	  # shellcheck source=/dev/null
   128	  source "${_JN_SECRETS}"
   129	  set +a
   130	fi
   131	_JN_BH_CLI="${_JN_CONN_BASE}/bullhorn/dist/cli.js"
   132	_JN_DELAY="${IFOS_JANITOR_RETRY_DELAY_S:-30}"
   133	
   134	# Defensive defaults when run standalone (context.sh exports these in the harness).
   135	: "${CTX_JANITOR_DEDUP_THRESHOLD:=0.85}"
   136	: "${CTX_BULLHORN_CORPORATION_ID:=unset}"
   137	: "${CTX_OPERATOR_TELEGRAM_CHAT_ID:=unset}"
   138	: "${CTX_VOICE_CORPUS_STATE:=absent}"
   139	export CTX_JANITOR_DEDUP_THRESHOLD
   140	
   650	    if printf '%s' "${cmd_out}" | jq -e '.ok == true' >/dev/null 2>&1; then
   651	      echo "applied"; return 0
   652	    fi
   653	    http_class="$(printf '%s' "${cmd_out}" | grep -oE 'HTTP (4|5)[0-9][0-9]' | head -1 | grep -oE '^HTTP [45]' | grep -oE '[45]' || echo 4)"
   654	    [[ "${http_class}" == "5" ]] && echo "fail5xx" || echo "fail4xx"
   655	  }
   656	
   657	  for _prop in "${_JN_TMPD}"/proposals/*.json; do
   658	    [[ -f "${_prop}" ]] || continue
   659	    _jn_batch_idx=$((_jn_batch_idx + 1))
   660	    if [[ "${_jn_batch_idx}" -gt 100 ]]; then
   661	      _jn_exception "Write batch hit the 100/min defensive cap — $((_jn_batch_idx - 100))+ proposals deferred to the next run"
   662	      break
   663	    fi
   664	    if ! CTX_JANITOR_BATCH_INDEX="${_jn_batch_idx}" bash "${_jn_validate}" "${_prop}" >/dev/null 2>&1; then
   665	      JN_GATE_REJECTS=$((JN_GATE_REJECTS + 1))   # validate.sh emitted the ESC + audit rows
   666	      continue
   667	    fi
   668	    _jn_atype="$(jq -r '.action_type' "${_prop}")"
   669	    _jn_pid="$(jq -r '.primary_id' "${_prop}")"
   670	    _jn_etype="$(jq -r '.entity_type' "${_prop}")"
   671	    _jn_wstate="$(_jn_bh_write "${_prop}")"
   672	    if [[ "${_jn_wstate}" == "fail5xx" ]]; then
   673	      sleep "${_JN_DELAY}"   # retry once with 30s backoff per agent.md §4 Step 9
   674	      _jn_wstate="$(_jn_bh_write "${_prop}")"
   675	      # Fixture-ONLY coercion: the 5xx fixture simulates a persistent 5xx, so
   676	      # the retry outcome stays 5xx. On the LIVE path the retry's real class
   677	      # stands (a genuine 4xx-on-retry must not be mislabelled class=5xx).
   678	      if [[ "${IFOS_JANITOR_FIXTURE_WRITE_RESULT:-}" == "5xx" ]]; then
   679	        _jn_wstate="fail5xx"
   680	      fi
   681	    fi
   682	    case "${_jn_wstate}" in
   683	      fail4xx)
   684	        autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
   685	          "action_type=${_jn_atype}" "entity=${_jn_etype}:${_jn_pid}" "class=4xx" "disposition=skip_continue"
   686	        JN_WFAILS=$((JN_WFAILS + 1)); continue ;;
   687	      fail5xx)
   688	        autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
   689	          "action_type=${_jn_atype}" "entity=${_jn_etype}:${_jn_pid}" "class=5xx" "disposition=retried_once_then_skip"
   690	        JN_WFAILS=$((JN_WFAILS + 1)); continue ;;
   691	      deferred)
   692	        JN_DEFERRED=$((JN_DEFERRED + 1)) ;;
   693	    esac
   694	    _jn_phash="$(shasum -a 256 "${_prop}" 2>/dev/null | cut -c1-16)"
   695	    [[ -z "${_jn_phash}" ]] && _jn_phash="${_jn_etype}-${_jn_pid}"
   696	    _jn_preview="$(jq -r '
   697	      if .action_type == "bullhorn_candidate_dedupe"
   698	      then "merge_target_id:\(.merge_target_id); confidence:\(.confidence); dims:\(.match_dimensions | join("+"))"
   699	      elif .action_type == "bullhorn_field_backfill"
   700	      then "fields:\(.field_changes | keys | join(",")); source:\(.source); source_confidence:\(.source_confidence)"
   701	      else "narrative_sha:none; voice_score:\(.voice_score); voice_reason:\(.voice_reason // "n/a")"
   702	      end' "${_prop}")"
   703	    hh_decision_action "${_jn_atype}" "entity:${_jn_etype}:${_jn_pid}" "${_jn_phash}" \
   704	      "${_jn_preview}; write_state:${_jn_wstate}" || true
   705	    case "${_jn_atype}" in
   706	      bullhorn_candidate_dedupe) JN_MERGES=$((JN_MERGES + 1)) ;;
   707	      bullhorn_field_backfill)   JN_BACKFILLS=$((JN_BACKFILLS + 1)) ;;
   708	      bullhorn_note_attach)      JN_NOTES=$((JN_NOTES + 1)) ;;
   709	    esac
   710	  done
   711	  hh_decision_output "bullhorn_write_batch" "tenant:${CTX_TENANT_SLUG}" \
   712	    "merges_written:${JN_MERGES}; backfills_written:${JN_BACKFILLS}; notes_attached:${JN_NOTES}; deferred_no_creds:${JN_DEFERRED}; failures:${JN_WFAILS}; gate_a_rejected:${JN_GATE_REJECTS}"
   713	fi
   714	
   715	# ────────────────────────────────────────────────────────────────────────
   716	# Step 10 — Day-30 report assembly
   717	# Reference: agent.md §4 Step 10 + §3 Output 1 (8-section Markdown report).
   718	# Reusable RLS-scoped sql/day30-report-metrics.sql (shared with the report
   719	# test). Gate B (agent.md §5): TWO independent thresholds — dedup ≥15% AND
   720	# completeness ≥10%; both must pass; NOT a composite. v1.0 metric definitions
   721	# (deterministic; baseline-relative measure is the post-pilot enhancement):
   722	#   dedup_pct        = 100·merges / (merges + review-band pairs)
   723	#   completeness_pct = 100·backfills / (backfills + still-missing rows)
   724	# ────────────────────────────────────────────────────────────────────────
   725	
   726	JN_GATE_B_MET="false"
   727	JN_BOTH_MISSED="true"
   728	if _step_planned 10; then
   729	  REPORT_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/janitor-reports/day-30-$(date -u +%Y-%m-%d).md"
   730	  mkdir -p "$(dirname "${REPORT_PATH}")" 2>/dev/null || true
   731	  chmod 0700 "$(dirname "${REPORT_PATH}")" 2>/dev/null || true
   732	  _jn_metrics_sql="$(_jn_sql day30-report-metrics.sql)"
   733	  METRICS=""
   734	  if [[ "${_jn_db_up}" -eq 1 && -f "${_jn_metrics_sql}" ]]; then
   735	    METRICS="$(_jn_psql <<SQL 2>/dev/null || true
   736	BEGIN;
   737	SET LOCAL app.current_tenant = :'tenant';
   738	\\i ${_jn_metrics_sql}
   739	COMMIT;
   740	SQL
   741	)"
   742	  fi
   743	  _m() { printf '%s\n' "${METRICS}" | grep -m1 "^$1|" | cut -d'|' -f2; }
   744	  _jn_m_merges="$(_m merges_30d)";        _jn_m_merges="${_jn_m_merges:-0}"
   745	  _jn_m_backfills="$(_m backfills_30d)";  _jn_m_backfills="${_jn_m_backfills:-0}"
   746	  _jn_m_notes="$(_m notes_30d)";          _jn_m_notes="${_jn_m_notes:-0}"
   747	  _jn_m_review="$(_m review_band_30d)";   _jn_m_review="${_jn_m_review:-0}"
   748	  _jn_m_missing="$(_m missing_now)";      _jn_m_missing="${_jn_m_missing:-0}"
   749	  _jn_m_wfails="$(_m write_fails_30d)";   _jn_m_wfails="${_jn_m_wfails:-0}"
   750	  _jn_m_rl="$(_m rate_limit_30d)";        _jn_m_rl="${_jn_m_rl:-0}"
   751	  _jn_m_gafails="$(_m gate_a_fails_30d)"; _jn_m_gafails="${_jn_m_gafails:-0}"
   752	  _jn_m_edits="$(_m consultant_edits_30d)";   _jn_m_edits="${_jn_m_edits:-0}"
   753	  _jn_m_appr="$(_m approved_after_edit_30d)"; _jn_m_appr="${_jn_m_appr:-0}"
   754	
   755	  _jn_dedup_pct="$(awk -v m="${_jn_m_merges}" -v r="${_jn_m_review}" \
   756	    'BEGIN{ d=m+r; if(d>0) printf "%.1f", (m/d)*100; else printf "0.0" }')"
   757	  _jn_comp_pct="$(awk -v b="${_jn_m_backfills}" -v miss="${_jn_m_missing}" \
   758	    'BEGIN{ d=b+miss; if(d>0) printf "%.1f", (b/d)*100; else printf "0.0" }')"
   759	  _jn_dedup_met="$(awk -v p="${_jn_dedup_pct}" 'BEGIN{print (p>=15) ? "true" : "false"}')"
   760	  _jn_comp_met="$(awk -v p="${_jn_comp_pct}" 'BEGIN{print (p>=10) ? "true" : "false"}')"
   761	  if [[ "${_jn_dedup_met}" == "true" && "${_jn_comp_met}" == "true" ]]; then JN_GATE_B_MET="true"; fi
   762	  if [[ "${_jn_dedup_met}" == "false" && "${_jn_comp_met}" == "false" ]]; then JN_BOTH_MISSED="true"; else JN_BOTH_MISSED="false"; fi
   763	
   764	  {
   765	    printf '# Janitor day-30 cleanup report — %s\n\n' "$(date -u +%Y-%m-%d)"
   766	    printf '_Tenant: %s · generated %sZ · mode: %s · agent.md §3 Output 1 (8 sections)_\n\n' \
   767	      "${CTX_TENANT_SLUG}" "$(date -u +%Y-%m-%dT%H:%M:%S)" "${MODE}"
   768	    printf '## 1. Record counts\n\n| Entity type | Records |\n|---|---|\n'
   769	    printf '| Candidates | %s |\n| Contractors | %s |\n| Clients | %s |\n| Contacts | %s |\n| Placements | %s |\n| Opportunities | %s |\n\n' \
   770	      "$(_m count_candidate)" "$(_m count_contractor)" "$(_m count_client)" \
   771	      "$(_m count_contact)" "$(_m count_placement)" "$(_m count_opportunity)"
   772	    printf '## 2. Dedup pairs (30d)\n\n- Auto-merged (≥%s confidence, no 90d activity): %s\n- Held for approval (review band via ESC_DUPLICATE_DETECTED): %s\n- Per-pair detail: see decision_log action rows (action_type=bullhorn_candidate_dedupe) + gating rows (ESC_DUPLICATE_DETECTED)\n\n' \
   773	      "${CTX_JANITOR_DEDUP_THRESHOLD}" "${_jn_m_merges}" "${_jn_m_review}"
   774	    printf '## 3. Field-completeness deltas (30d)\n\n- Backfills applied: %s (source provenance in each action row payload)\n- Missing-field rows remaining: %s\n- Sources: Companies House (clients; live); LinkedIn (v1.1+ deferred); derivation (enhancement)\n\n' \
   775	      "${_jn_m_backfills}" "${_jn_m_missing}"
   776	    printf '## 4. Tacit-note coverage (30d)\n\n- Consultant approved-after-edit rows harvested: %s\n- Narrative notes attached: %s\n- Voice posture: %s\n\n' \
   777	      "${_jn_m_appr}" "${_jn_m_notes}" \
   778	      "$([[ "${CTX_VOICE_CORPUS_STATE:-absent}" == "active" ]] && echo "corpus active; classifier = documented enhancement" || echo "unscored/no_corpus (empty tenant voice_corpus — honest, never faked)")"
   779	    printf '## 5. Agent vs. consultant attribution (30d)\n\n- Janitor automated writes (merges + backfills + notes): %s\n- Consultant manual edits (recent_edit, all resolutions): %s\n\n' \
   780	      "$((_jn_m_merges + _jn_m_backfills + _jn_m_notes))" "${_jn_m_edits}"
   780	      "$((_jn_m_merges + _jn_m_backfills + _jn_m_notes))" "${_jn_m_edits}"
   781	    printf '## 6. Gate-B metric (two independent thresholds; both must pass — NOT a composite)\n\n| Threshold | Value | Target | Met |\n|---|---|---|---|\n| Dedup improvement | %s%% | ≥15%% | %s |\n| Field-completeness improvement | %s%% | ≥10%% | %s |\n\n**Gate B: %s** _(v1.0 decision_log-derived metrics; day-0-baseline-relative measure lands at pilot onboarding)_\n\n' \
   782	      "${_jn_dedup_pct}" "${_jn_dedup_met}" "${_jn_comp_pct}" "${_jn_comp_met}" \
   783	      "$([[ "${JN_GATE_B_MET}" == "true" ]] && echo MET || echo MISSED)"
   784	    printf '## 7. Exception list\n\n- Failed Bullhorn writes (30d): %s\n- Rate-limit hits (30d): %s\n- Gate A rejections (30d): %s\n' \
   785	      "${_jn_m_wfails}" "${_jn_m_rl}" "${_jn_m_gafails}"
   786	    if [[ -s "${_JN_EXCEPTIONS}" ]]; then
   787	      printf -- '- This run:\n'
   788	      while IFS= read -r _ex; do printf '  - %s\n' "${_ex}"; done < "${_JN_EXCEPTIONS}"
   789	    else
   790	      printf -- '- This run: none\n'
   791	    fi
   792	    printf '\n## 8. Executive summary\n\nOver the last 30 days the Janitor agent ran nightly data hygiene across this Bullhorn corpus: %s duplicate pairs auto-merged at ≥%s confidence with a 90-day activity guard, %s held for consultant approval rather than risking an unwanted merge, %s missing canonical fields backfilled from Companies House with source provenance logged, and %s tacit-knowledge notes folded back from consultant-approved edits. Every write passed a seven-check hard gate (auth freshness, confidence floors, activity recency, source confidence, voice, PII boundary, batch cap) and carries a per-write audit row. Estimated consultant data-entry time avoided: ~%s minutes (at 5 min/record action). Gate B stands %s this window.\n' \
   793	      "${_jn_m_merges}" "${CTX_JANITOR_DEDUP_THRESHOLD}" "${_jn_m_review}" \
   794	      "${_jn_m_backfills}" "${_jn_m_notes}" \
   795	      "$(( (_jn_m_merges + _jn_m_backfills + _jn_m_notes) * 5 ))" \
   796	      "$([[ "${JN_GATE_B_MET}" == "true" ]] && echo MET || echo MISSED)"
   797	  } > "${REPORT_PATH}" 2>/dev/null || true
   798	  chmod 0600 "${REPORT_PATH}" 2>/dev/null || true
   799	  hh_decision_output "day_30_report" "${REPORT_PATH}" \
   800	    "Gate-B: dedup_pct:${_jn_dedup_pct}; completeness_pct:${_jn_comp_pct}; gate_b_met:${JN_GATE_B_MET}; gate_b_both_missed:${JN_BOTH_MISSED}; sections:8"
   801	fi
   802	
   803	# ────────────────────────────────────────────────────────────────────────
   804	# Step 11 — Operator notification (Telegram)
   805	# Reference: agent.md §4 Step 11; green action row if Gate B met, missed-state
   806	# + ≤200-char executive summary in the payload when missed (the registered
   807	# operator_notify_telegram action_type is green tier in autosend-policy.yaml;
   808	# urgency is conveyed in payload.gate_b_state — tier is policy-owned).
   809	# Transport: live Telegram sendMessage when TELEGRAM_BOT_TOKEN + chat id are
   810	# configured; stdout degrade otherwise (Scout precedent; token EMPTY today).
   811	# ────────────────────────────────────────────────────────────────────────
   812	
   813	if _step_planned 11; then
   814	  if [[ "${JN_GATE_B_MET}" == "true" ]]; then
   815	    _jn_gb_state="met"
   816	    _jn_msg="Janitor nightly (${CTX_TENANT_SLUG}): Gate B MET. Merges:${JN_MERGES} backfills:${JN_BACKFILLS} notes:${JN_NOTES} deferred:${JN_DEFERRED}."
   817	  else
   818	    _jn_gb_state="missed"
   819	    # awk (not `grep -c || echo 0`): zero matches → grep prints "0" AND exits 1,
   820	    # so the || arm doubled the 0 with a newline inside the message.
   821	    _jn_msg="Janitor nightly (${CTX_TENANT_SLUG}): Gate B MISSED. Merges:${JN_MERGES} backfills:${JN_BACKFILLS} review-held:$(awk '/Review-band/{n++} END{print n+0}' "${_JN_EXCEPTIONS}" 2>/dev/null || echo 0). Consultant follow-up suggested on held pairs + remaining missing fields."
   822	  fi
   823	  _jn_msg="${_jn_msg:0:200}"
   824	  _jn_channel="stdout_degraded"
   825	  if [[ -n "${TELEGRAM_BOT_TOKEN:-}" && "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" != "unset" ]] && command -v curl >/dev/null 2>&1; then
   826	    if curl -sS --max-time 15 "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
   827	         -d "chat_id=${CTX_OPERATOR_TELEGRAM_CHAT_ID}" --data-urlencode "text=${_jn_msg}" \
   828	         >/dev/null 2>&1; then
   829	      _jn_channel="telegram"
   830	    fi
   831	  fi
   832	  [[ "${_jn_channel}" == "stdout_degraded" ]] && printf '[janitor notify] %s\n' "${_jn_msg}"
   833	  _jn_nhash="$(printf '%s' "${_jn_msg}" | shasum -a 256 2>/dev/null | cut -c1-16)"
   834	  [[ -z "${_jn_nhash}" ]] && _jn_nhash="notify-${MODE}"
   835	  hh_decision_action "operator_notify_telegram" "tenant:${CTX_TENANT_SLUG}" "${_jn_nhash}" \
   836	    "gate_b_state:${_jn_gb_state}; chars:${#_jn_msg}; channel:${_jn_channel}" || true
   837	fi
   838	
   839	# ────────────────────────────────────────────────────────────────────────
   840	# Step 12 — Session close
   841	# Update tenant_adapters.config.janitor_last_run (v0.3-allowlisted; validated
   842	# by the v0.4 trigger). ESC_GATE_B_MISS fires ONLY when BOTH Gate B thresholds
   843	# missed for 3 consecutive runs (agent.md §5 + catalogue trigger; single-run
   844	# or single-threshold misses are tracked in the report, no ESC) → exit 1.
   845	# ────────────────────────────────────────────────────────────────────────
   846	
   847	# Stamp janitor_last_run ONLY when Step 2 actually ran this invocation —
   848	# --report-only (Steps 10+12) must not silently narrow the next live scan
   849	# window to a period nothing actually scanned.
   850	if _step_planned 2 && [[ "${_jn_db_up}" -eq 1 ]]; then
   851	  _jn_psql -q <<'SQL' >/dev/null 2>&1 || true
   852	BEGIN;
   853	SET LOCAL app.current_tenant = :'tenant';
   854	UPDATE tenant_adapters
   855	SET config = jsonb_set(coalesce(config, '{}'::jsonb), '{janitor_last_run}', to_jsonb(to_char(now() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')))
   856	WHERE tenant_slug = :'tenant';
   857	COMMIT;
   858	SQL
   859	fi
   860	

exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/tools.yaml | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
     1	# Janitor agent — tools.yaml (capability declarations)
     2	#
     3	# Status: BUILT (W6-7 build slice; spec-001) — cycle.sh 12 steps + validate.sh
     4	#         Gate A G1-G7 LIVE; Bullhorn capabilities wired through the
     5	#         @ifos/bullhorn dist/cli.js bridge. Live Bullhorn calls are
     6	#         founder-gated (creds EMPTY per spec-001 §8) — until creds land the
     7	#         agent scans the Postgres entities cache and records Step 9 writes
     8	#         with write_state:deferred_no_bullhorn_creds. Companies House is the
     9	#         live-capable enrichment path (key SET).
    10	# Reading order: agent.md §1 (output contract) + §2 (invocation surface) +
    11	#         §4 (workflow + capability dependencies) first.
    12	#
    13	# Per ADR-003 agent-bundle pattern: tools.yaml declares every external
    14	# capability cycle.sh invokes + the autosend-policy action_type each
    15	# state-changing call emits. cortextOS bus uses this to authorise capability
    16	# invocation per agent (no capability declared here = bus refuses the call).
    17	#
    18	# Action types referenced below MUST exist in agents/_shared/autosend-policy.yaml.
    19	# Janitor's 3 yellow-tier write action_types (bullhorn_candidate_dedupe +
    20	# bullhorn_field_backfill + bullhorn_note_attach) are all already REGISTERED
    21	# in autosend-policy.yaml (verified 2026-06-03 — see status table at bottom).
    22	# janitor_cleanup is QUEUED for registration at W6-7 build start (matches
    23	# the cash_conductor_cleanup pattern).
    24	
    25	version: "0.1"
    26	agent: janitor
    27	
    28	capabilities:
    29	
    30	  # ────────────────────────────────────────────────────────────────────────
    31	  # Bullhorn ATS (R+W on Candidate/Contractor/Contact/Client; W only on Note)
    32	  # Reference: bullhorn-integration-path.md §4.1 A2 (Janitor scope).
    33	  # Schema-clean post v0.4 supplement (LIVE on VPS 2026-06-03; commit a1bbcf6)
    34	  # — bullhorn_corporation_id is top-level allowlisted in
    35	  # validate_tenant_adapters_config_v0_4.
    36	  # ────────────────────────────────────────────────────────────────────────
    37	
    38	  - id: bullhorn_oauth
    39	    package: "@ifos/bullhorn"
    40	    purpose: "Bullhorn two-step OAuth refresh (Step A OAuth at auth-{region}.bullhornstaffing.com + Step B REST login at rest.bullhornstaffing.com/rest-services/login → BhRestToken + per-corp restUrl) per @ifos/bullhorn src/auth.ts; per-corporation_id Promise dedup + 401-force-refresh per cluster F R4 lesson. Invoked via dist/cli.js refresh (CLI bridge built this slice)"
    41	    action_type: bullhorn_oauth          # green tier; QUEUED for registration (substrate-owner change to autosend-policy.yaml; agents/_shared/ frozen this slice)
    42	    cycle_step: 1
    43	    secrets_required: [BULLHORN_CLIENT_ID, BULLHORN_CLIENT_SECRET]
    44	    rate_limit_hint: "per-corporation_id 600/min hard / 480/min soft (see @ifos/bullhorn README §Rate limits)"
    45	
    46	  - id: bullhorn_list_candidates
    47	    package: "@ifos/bullhorn"
    48	    purpose: "List candidates modified since janitor_last_run (Step 2 scan); query support via Lucene-style filter"
    49	    cycle_step: 2
    50	    state_changing: false
    51	
    52	  - id: bullhorn_get_candidate
    53	    package: "@ifos/bullhorn"
    54	    purpose: "Single-entity candidate fetch (Step 3 dedup pair hydration + Gate A G3 recent-activity check)"
    55	    cycle_step: 3
    56	    state_changing: false
    57	
    58	  - id: bullhorn_update_candidate
    59	    package: "@ifos/bullhorn"
    60	    purpose: "Merge dedup pair (Step 9) OR backfill missing canonical fields (Step 9); action_type discriminates by mutation type"
    61	    action_type: bullhorn_candidate_dedupe  # yellow tier; REGISTERED in autosend-policy.yaml line 191 (sample_rate 10) for merge mutations
    62	    # NOTE: when this capability fires for a field-backfill rather than a merge,
    63	    # the emitting action_type is bullhorn_field_backfill (yellow tier; REGISTERED
    64	    # line 198; sample_rate 10) — cycle.sh Step 9 selects the action_type per
    65	    # mutation type. Both action_types share this single bullhorn_update_candidate
    66	    # capability (the autosend-policy tier discriminator + audit row records which).
    67	    cycle_step: 9
    68	    state_changing: true
    69	
    70	  - id: bullhorn_list_contacts
    71	    package: "@ifos/bullhorn"
    72	    purpose: "List contacts modified since janitor_last_run (Step 2); fed into Step 3-4 dedup pair candidate pool"
    73	    cycle_step: 2
    74	    state_changing: false
    75	
    76	  - id: bullhorn_get_contact
    77	    package: "@ifos/bullhorn"
    78	    purpose: "Single-entity contact fetch (Step 3-4 dedup pair hydration)"
    79	    cycle_step: 3
    80	    state_changing: false
    81	
    82	  - id: bullhorn_list_clients
    83	    package: "@ifos/bullhorn"
    84	    purpose: "List ClientCorporation rows modified since janitor_last_run (Step 2); fed into Step 5 field completeness audit + Step 6 Companies House enrichment"
    85	    cycle_step: 2
    86	    state_changing: false
    87	
    88	  - id: bullhorn_get_client
    89	    package: "@ifos/bullhorn"
    90	    purpose: "Single-entity ClientCorporation fetch (Step 5-6)"
    91	    cycle_step: 5
    92	    state_changing: false
    93	
    94	  - id: bullhorn_update_client
    95	    package: "@ifos/bullhorn"
    96	    purpose: "Backfill missing canonical client fields (client.industry / client.companies_house_number / client.size_employees) from Step 6 Companies House enrichment (Step 9 write; updateClient added to @ifos/bullhorn this slice)"
    97	    action_type: bullhorn_field_backfill  # yellow tier; REGISTERED in autosend-policy.yaml line 198 (sample_rate 10)
    98	    cycle_step: 9
    99	    state_changing: true
   100	
   101	  - id: bullhorn_create_note
   102	    package: "@ifos/bullhorn"
   103	    purpose: "Attach tacit-note narrative from recent_edit harvest (Step 8 → Step 9); marker janitor_tacit_note_harvest per spec-001 §3 contract"
   104	    action_type: bullhorn_note_attach   # yellow tier; REGISTERED in autosend-policy.yaml line 205 (sample_rate 20)
   105	    cycle_step: 9
   106	    state_changing: true
   107	
   108	  # ────────────────────────────────────────────────────────────────────────
   109	  # Dedup matcher (agent.md §4 Steps 3-4; local bin/ helper — no external
   110	  # package, zero network; declared so the §4 capability citation resolves)
   111	  # ────────────────────────────────────────────────────────────────────────
   112	
   113	  - id: janitor_dedup_matcher
   114	    purpose: "Deterministic duplicate-pair fuzzy matcher bin/dedup-pairs.sh (pure jq over stdin; zero network) — spec-001 weights name·0.3 + email·0.4 + phone·0.2 + linkedin·0.1 with comparable-weight normalisation + required strong identifier (build deviation 1); classifies every pair into the spec-001 §4 band→action table (auto ≥0.85+no-90d-activity / review 0.70–0.85 or recency-hold / silent drop <0.70). Shared by Step 3 (candidate) AND Step 4 (contractor — same matcher, separate entity_type)"
   115	    cycle_step: 3
   116	    state_changing: false
   117	
   118	  # ────────────────────────────────────────────────────────────────────────
   119	  # Companies House enrichment (clients only; agent.md §4 Step 6)
   120	  # ────────────────────────────────────────────────────────────────────────
   121	
   122	  - id: companies_house_search
   123	    package: "@ifos/companies-house"
   124	    purpose: "Lookup client CRN via name search; feeds Step 6 backfill of client.industry + client.companies_house_number"
   125	    cycle_step: 6
   126	    state_changing: false
   127	    rate_limit_hint: "600/5min per IFOS API key; 7-day cache TTL per agent.md §4 Step 6; shared budget with Diagnostic"
   128	
   129	  - id: companies_house_get_company
   130	    package: "@ifos/companies-house"
   131	    purpose: "Hydrate full company profile by CRN (post-search resolution); industry + size_employees fields"
   132	    cycle_step: 6
   133	    state_changing: false
   134	
   135	  # ────────────────────────────────────────────────────────────────────────
   136	  # Operator notification (Telegram operator-chat-id; not customer-facing)
   137	  # ────────────────────────────────────────────────────────────────────────
   138	
   139	  - id: telegram_notify
   140	    package: "@ifos/telegram"
   141	    purpose: "Operator-channel Telegram notifications (NOT customer-facing; green tier) — Step 11 nightly summary + ESC_DUPLICATE_DETECTED approval gate trigger"
   142	    action_type: operator_notify_telegram  # green tier; REGISTERED in autosend-policy.yaml
   143	    cycle_step: 11
   144	    state_changing: false  # write to Telegram is an external side-effect but not on tenant data
   145	    secrets_required: [TELEGRAM_BOT_TOKEN]
   146	
   147	  # ────────────────────────────────────────────────────────────────────────
   148	  # Cleanup (cleanup.sh)
   149	  # ────────────────────────────────────────────────────────────────────────
   150	
   151	  - id: janitor_cleanup
   152	    purpose: "Post-run cleanup (transient @ifos/bullhorn 24h + @ifos/companies-house 7d cache purge + stale run workspaces)"
   153	    action_type: janitor_cleanup    # green tier; QUEUED for registration (substrate-owner change; cleanup.sh emits hh_decision_output until registered — CC/Scout precedent)
   154	    state_changing: false
   155	    cycle_step: 12
   156	
   157	# ──────────────────────────────────────────────────────────────────────────────
   158	# Failure-modes table (per cluster Fbis pattern; ESC mapping per agent.md §6)
   159	# ──────────────────────────────────────────────────────────────────────────────
   160	
   161	failure_modes:
   162	
   163	  - condition: "@ifos/bullhorn OAuth refresh fails after 2 retries (cycle.sh Step 1)"
   164	    surface: "BullhornAuthError thrown by @ifos/bullhorn"
   165	    escalation: ESC_BULLHORN_AUTH    # blocking; operator + ifos_oncall_chat_id per catalogue §2.5
   166	
   167	  - condition: "@ifos/bullhorn returns 4xx/5xx on merge/backfill/note write (Step 9)"
   168	    surface: "BullhornError (4xx skip; 5xx retry-once-then-skip)"
   169	    escalation: ESC_BULLHORN_WRITE_FAIL   # warn; operator_chat_id
   170	
   171	  - condition: "@ifos/bullhorn OR @ifos/companies-house returns 429 (Step 2/3/4/6)"
   172	    surface: "BullhornRateLimitError OR CHRateLimitError"
   173	    escalation: ESC_RATE_LIMIT_HIT   # warn; operator_chat_id; payload.upstream='bullhorn'|'companies-house'
   174	
   175	  - condition: "Tacit-note narrative voice classifier <0.75 after 3 retries (Step 8 → validate.sh G5)"
   176	    surface: "validate.sh exit 1 with G5 failure"
   177	    escalation: ESC_VOICE_DRIFT      # warn; operator_chat_id
   178	
   179	  - condition: "PII detected outside firm boundary in tacit-note narrative (validate.sh G6)"
   180	    surface: "validate.sh exit 1 with G6 failure"
   181	    escalation: ESC_PII_LEAKAGE_RISK   # blocking; operator + ifos_oncall_chat_id
   182	
   183	  - condition: "Dedup proposal confidence below CTX_JANITOR_DEDUP_THRESHOLD (validate.sh G2) — output-shape constraint"
   184	    surface: "validate.sh exit 1 with G2 failure"
   185	    escalation: ESC_AGENT_OUTPUT_SHAPE   # warn; operator_chat_id
   186	
   187	  - condition: "Dedup pair in the review band — confidence 0.70-0.85 OR ≥0.85 with 90d activity (cycle.sh Steps 3-4 classification; validate.sh G3 defence-in-depth) — SUCCESS-path approval gate, NOT Gate A failure code"
   188	    surface: "cycle.sh Steps 3-4 emit per review pair; validate.sh exit 1 with G3 failure rejects any auto-write that slips through"
   189	    escalation: ESC_DUPLICATE_DETECTED   # warn; operator_chat_id (via Telegram approval gate per catalogue §2.5)
   190	
   191	  - condition: "Write batch exceeds the 100/min defensive cap (validate.sh G7; remainder defers to the next run)"
   192	    surface: "validate.sh exit 1 with G7 failure"
   193	    escalation: ESC_AGENT_OUTPUT_SHAPE   # warn; operator_chat_id (spec-001 §5 routing)
   194	
   195	  - condition: "BOTH Gate B thresholds miss for 3 consecutive runs (cycle.sh Step 12 exit-code path; per agent.md §5 ESC_GATE_B_MISS row + catalogue trigger)"
   196	    surface: "cycle.sh exit 1 with ESC_GATE_B_MISS"
   197	    escalation: ESC_GATE_B_MISS       # warn; operator_chat_id (heuristic tuning may be needed; not a kill)
   198	
   199	# ──────────────────────────────────────────────────────────────────────────────
   200	# Action-type registration status (cross-reference autosend-policy.yaml)
   201	# ──────────────────────────────────────────────────────────────────────────────
   202	#
   203	# Already REGISTERED in agents/_shared/autosend-policy.yaml (re-verified
   204	# 2026-06-10 during the W6-7 build slice):
   205	#   bullhorn_candidate_dedupe       line 191   yellow (sample_rate 10)
   206	#   bullhorn_field_backfill         line 198   yellow (sample_rate 10)
   207	#   bullhorn_note_attach            line 205   yellow (sample_rate 20)
   208	#   operator_notify_telegram        green                  (shared)
   209	#   janitor_run_complete            green
   210	#   validate_gate_a_fail            green                  (shared)
   211	#
   212	# QUEUED for registration (substrate-owner change to agents/_shared/
   213	# autosend-policy.yaml — frozen for this build slice per the parallel-conflict
   214	# rule; cleanup.sh + Step 1 stay on hh_decision_output until then):
   215	#   bullhorn_oauth                  green
   216	#   janitor_cleanup                 green
   217	
   218	# ──────────────────────────────────────────────────────────────────────────────
   219	# Boundary check (per master brief §3 + review-mcp-connector.md §8)
   220	# ──────────────────────────────────────────────────────────────────────────────
   221	#
   222	# - No Composio / AgentMail references anywhere in this file.
   223	# - All packages declared are @ifos/* — no third-party adapters with policy
   224	#   semantics smuggled in via tools.yaml.
   225	# - Action types all map to autosend-policy.yaml tiers (or are explicitly
   226	#   marked QUEUED above for W6-7 build-start registration).
   227	# - Capability ID set = SUBSET of @ifos/bullhorn capability exports per
   228	#   bullhorn-integration-path.md §4.1 A2 (Janitor scope — R+W on Candidate
   229	#   + Contact + ClientCorporation; W only on Note; NO Placement/Opportunity
   230	#   write at v1.0).

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '55,75p;185,210p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
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
   185	    irreversible: false
   186	
   187	  # ───────────────────────────────────────────────────────────
   188	  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
   189	  # ───────────────────────────────────────────────────────────
   190	
   191	  bullhorn_candidate_dedupe:
   192	    tier: yellow
   193	    agent: janitor
   194	    sample_rate: 10
   195	    reason: "Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review"
   196	    irreversible: false
   197	
   198	  bullhorn_field_backfill:
   199	    tier: yellow
   200	    agent: janitor
   201	    sample_rate: 10
   202	    reason: "Fills missing canonical schema fields from Companies House or LinkedIn enrichment; reversible PATCH; high-volume; source provenance logged in payload"
   203	    irreversible: false
   204	
   205	  bullhorn_note_attach:
   206	    tier: yellow
   207	    agent: janitor
   208	    sample_rate: 20
   209	    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
   210	    irreversible: false

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
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
/bin/zsh -lc 'rg -n "Composio|AgentMail|packages/harness/cortextos|cortextOS.*brain|stock KB|kb-" agents/recruitment/janitor/agent.md agents/recruitment/janitor/tools.yaml agents/recruitment/janitor/*.sh agents/recruitment/janitor/fixtures/*.yaml' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
agents/recruitment/janitor/tools.yaml:222:# - No Composio / AgentMail references anywhere in this file.

exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/cycle.sh | sed -n '140,360p;360,650p;860,910p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
   140	
   141	# Mode dispatch (default = full-cleanup; cron passes --mode full-cleanup at 02:00 UTC)
   142	MODE="full-cleanup"
   143	TENANT_ARG=""
   144	while [[ $# -gt 0 ]]; do
   145	  case "$1" in
   146	    --mode)    MODE="${2:-}"; shift 2 ;;
   147	    --tenant)  TENANT_ARG="${2:-}"; shift 2 ;;
   148	    --dry-run) MODE="dry-run"; shift ;;
   149	    --report-only) MODE="report-only"; shift ;;
   150	    *)         shift ;;
   151	  esac
   152	done
   153	# Manual-trigger consistency guard (ADR-003: the bus sets CTX_TENANT_SLUG;
   154	# --tenant is operator convenience — a mismatch is a mis-invocation).
   155	if [[ -n "${TENANT_ARG}" && "${TENANT_ARG}" != "${CTX_TENANT_SLUG}" ]]; then
   156	  printf 'cycle.sh: --tenant %s does not match CTX_TENANT_SLUG %s — refusing mismatched invocation\n' \
   157	    "${TENANT_ARG}" "${CTX_TENANT_SLUG}" >&2
   158	  exit 2
   159	fi
   160	
   161	# Run-scoped workspace (purged on exit).
   162	_JN_TMPD="$(mktemp -d -t janitor-run-XXXXXX 2>/dev/null || echo "/tmp/janitor-run-$$")"
   163	mkdir -p "${_JN_TMPD}/proposals"
   164	# shellcheck disable=SC2329  # invoked indirectly via trap
   165	_jn_cleanup_tmpd() { rm -rf "${_JN_TMPD}" 2>/dev/null || true; }
   166	trap _jn_cleanup_tmpd EXIT
   167	
   168	# Exceptions accumulate across steps → day-30 report §7 exception list.
   169	_JN_EXCEPTIONS="${_JN_TMPD}/exceptions.txt"
   170	: > "${_JN_EXCEPTIONS}"
   171	_jn_exception() { printf '%s\n' "$1" >> "${_JN_EXCEPTIONS}"; }
   172	
   173	# RLS-scoped psql (stdin carries the SQL; :'tenant' bound).
   174	_jn_psql() {
   175	  psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" "$@"
   176	}
   177	_jn_db_up=0
   178	if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then _jn_db_up=1; fi
   179	
   180	# ────────────────────────────────────────────────────────────────────────
   181	# Step 0 — Session start
   182	# ────────────────────────────────────────────────────────────────────────
   183	
   184	hh_decision_trigger "session_start" "janitor mode=${MODE}"
   185	
   186	# ────────────────────────────────────────────────────────────────────────
   187	# Step 1 — Bullhorn auth refresh (runs in every mode)
   188	# Reference: agent.md §4 Step 1; @ifos/bullhorn two-step refresh (Step A OAuth
   189	# + Step B REST login per src/auth.ts) via dist/cli.js. 2 retries; failure →
   190	# ESC_BULLHORN_AUTH (blocking; operator + ifos_oncall routing) + exit 1.
   191	# Creds absent (founder-gated today) → honest DEGRADED state: ESC fires with
   192	# reason=credentials_absent, run continues against the entities cache
   193	# (Scout degraded-skip precedent; writes defer at Step 9).
   194	# ────────────────────────────────────────────────────────────────────────
   195	
   196	_jn_token_state="absent"
   197	if [[ -n "${IFOS_JANITOR_FIXTURE_BULLHORN_AUTH:-}" ]]; then
   198	  case "${IFOS_JANITOR_FIXTURE_BULLHORN_AUTH}" in
   199	    ok)     _jn_token_state="fixture" ;;
   200	    failed) _jn_token_state="failed" ;;
   201	  esac
   202	elif [[ -n "${BULLHORN_CLIENT_ID:-}" && -n "${BULLHORN_CLIENT_SECRET:-}" && -f "${_JN_BH_CLI}" ]]; then
   203	  _jn_token_state="failed"
   204	  for _attempt in 1 2 3; do   # initial + 2 retries per agent.md §4 Step 1
   205	    if node "${_JN_BH_CLI}" refresh 2>/dev/null | jq -e '.ok == true' >/dev/null 2>&1; then
   206	      _jn_token_state="ok"
   207	      break
   208	    fi
   209	    [[ "${_attempt}" -lt 3 ]] && sleep "${_JN_DELAY}"
   210	  done
   211	fi
   212	
   213	hh_decision_output "bullhorn_auth_refresh" "tenant:${CTX_TENANT_SLUG}" \
   214	  "corporation_id:${CTX_BULLHORN_CORPORATION_ID}; bullhorn_token_state:${_jn_token_state}"
   215	
   216	case "${_jn_token_state}" in
   217	  failed)
   218	    autosend_escalate "ESC_BULLHORN_AUTH" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
   219	      "corporation_id=${CTX_BULLHORN_CORPORATION_ID}" "reason=refresh_failed_after_2_retries"
   220	    printf 'cycle.sh: Bullhorn auth refresh failed after 2 retries — blocking (ESC_BULLHORN_AUTH)\n' >&2
   221	    exit 1 ;;
   222	  absent)
   223	    autosend_escalate "ESC_BULLHORN_AUTH" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
   224	      "reason=credentials_absent_founder_gated" "degraded_mode=entities_cache_scan_writes_deferred"
   225	    _jn_exception "Bullhorn creds absent (founder-gated) — scan ran against the entities cache; Step 9 writes recorded as deferred" ;;
   226	esac
   227	export CTX_BULLHORN_TOKEN_STATE="${_jn_token_state}"
   228	
   229	# ────────────────────────────────────────────────────────────────────────
   230	# Step routing — full-cleanup runs all steps; incremental + dry-run skip
   231	# enrichment; report-only skips scan entirely. Word-boundary matching (a
   232	# bare *2* glob would mis-match "12" — latent skeleton bug fixed here).
   233	# ────────────────────────────────────────────────────────────────────────
   234	
   235	case "${MODE}" in
   236	  full-cleanup) STEPS_TO_RUN="2 3 4 5 6 7 8 9 10 11 12" ;;
   237	  incremental)  STEPS_TO_RUN="2 3 4 8 9 12" ;;
   238	  dry-run)      STEPS_TO_RUN="2 3 4 5 6 7 8 10 12" ;;  # No Step 9 (writes); no Step 11
   239	  report-only)  STEPS_TO_RUN="10 12" ;;
   240	  *)            printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
   241	esac
   242	_step_planned() { [[ " ${STEPS_TO_RUN} " == *" $1 "* ]]; }
   243	hh_decision_output "mode_routed" "tenant:${CTX_TENANT_SLUG}" \
   244	  "mode:${MODE}; steps_planned:${STEPS_TO_RUN}"
   245	
   246	# ────────────────────────────────────────────────────────────────────────
   247	# Step 2 — Entity scan since janitor_last_run
   248	# Reference: agent.md §4 Step 2 + spec-001 §4 (marker: janitor_scan).
   249	# Live (token ok): @ifos/bullhorn CLI list-candidates/contacts/clients
   250	# --since <watermark> → upsert into the entities cache; 429 → 60s backoff +
   251	# one retry + ESC_RATE_LIMIT_HIT. Degraded (creds absent): the entities cache
   252	# IS the scan surface (rows arrive via seeds today, webhooks/sync later).
   253	# Count is taken from the cache in both modes — one honest code path.
   254	# ────────────────────────────────────────────────────────────────────────
   255	
   256	JN_SINCE=""
   257	if _step_planned 2; then
   258	  if [[ "${_jn_db_up}" -eq 1 ]]; then
   259	    JN_SINCE="$(_jn_psql <<'SQL' 2>/dev/null | head -1 || true
   260	BEGIN;
   261	SET LOCAL app.current_tenant = :'tenant';
   262	SELECT coalesce(config->>'janitor_last_run', '') FROM tenant_adapters
   263	WHERE tenant_slug = :'tenant' AND config ? 'janitor_last_run'
   264	ORDER BY id LIMIT 1;
   265	COMMIT;
   266	SQL
   267	)"
   268	  fi
   269	
   270	  # Live Bullhorn pull (only when the token is genuinely live).
   271	  if [[ "${_jn_token_state}" == "ok" && "${_jn_db_up}" -eq 1 ]]; then
   272	    for _jn_kind in candidates contacts clients; do
   273	      _jn_pull_args=("list-${_jn_kind}")
   274	      [[ -n "${JN_SINCE}" ]] && _jn_pull_args+=(--since "${JN_SINCE}")
   275	      _jn_rows=""
   276	      if ! _jn_rows="$(node "${_JN_BH_CLI}" "${_jn_pull_args[@]}" 2>&1)"; then
   277	        if printf '%s' "${_jn_rows}" | grep -qi 'rate.limit'; then
   278	          autosend_escalate "ESC_RATE_LIMIT_HIT" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
   279	            "upstream=bullhorn" "step=2" "backoff_s=60"
   280	          sleep "${IFOS_JANITOR_RETRY_DELAY_S:-60}"
   281	          _jn_rows="$(node "${_JN_BH_CLI}" "${_jn_pull_args[@]}" 2>/dev/null || echo '[]')"
   282	        else
   283	          _jn_rows="[]"
   284	        fi
   285	      fi
   286	      if printf '%s' "${_jn_rows}" | jq -e 'type=="array" and length > 0' >/dev/null 2>&1; then
   287	        _jn_psql -q --set=js="${_jn_rows}" <<'SQL' >/dev/null 2>&1 || true
   288	BEGIN;
   289	SET LOCAL app.current_tenant = :'tenant';
   290	INSERT INTO entities (tenant_slug, entity_type, entity_id, data)
   291	SELECT :'tenant', t.entity_type, t.entity_id, t.data
   292	FROM jsonb_to_recordset(:'js'::jsonb) AS t(entity_type text, entity_id text, data jsonb)
   293	ON CONFLICT (tenant_slug, entity_type, entity_id)
   294	DO UPDATE SET data = EXCLUDED.data, updated_at = now();
   295	COMMIT;
   296	SQL
   297	      fi
   298	    done
   299	  fi
   300	
   301	  _jn_scanned=0
   302	  _jn_bytype=""
   303	  if [[ "${_jn_db_up}" -eq 1 ]]; then
   304	    _jn_scan_out="$(_jn_psql --set=since="${JN_SINCE}" <<'SQL' 2>/dev/null || true
   305	BEGIN;
   306	SET LOCAL app.current_tenant = :'tenant';
   307	SELECT entity_type || '|' || count(*)::text
   308	FROM entities
   309	WHERE updated_at > coalesce(nullif(:'since', '')::timestamptz, '-infinity'::timestamptz)
   310	  AND entity_type IN ('candidate','contractor','client','contact','placement','opportunity')
   311	GROUP BY entity_type ORDER BY entity_type;
   312	COMMIT;
   313	SQL
   314	)"
   315	    while IFS='|' read -r _t _n; do
   316	      [[ -z "${_t}" ]] && continue
   317	      _jn_scanned=$((_jn_scanned + _n))
   318	      _jn_bytype="${_jn_bytype:+${_jn_bytype},}${_t}:${_n}"
   319	    done <<<"${_jn_scan_out}"
   320	  fi
   321	  hh_decision_output "janitor_scan" "tenant:${CTX_TENANT_SLUG}" \
   322	    "${_jn_scanned} entities scanned; since:${JN_SINCE:-epoch}; by_type:${_jn_bytype:-none}; source:$([[ "${_jn_token_state}" == "ok" ]] && echo bullhorn_live || echo entities_cache_degraded)"
   323	fi
   324	
   325	# ────────────────────────────────────────────────────────────────────────
   326	# Dedup helper (Steps 3 + 4 share this; same matcher, separate entity_type
   327	# per vertical-schema.yaml §1 + Q1 Day-6 resolution).
   328	# Pool = ALL cached records of the type (pair-finding needs the full pool,
   329	# not just the incremental slice). Review-band pairs fire the
   330	# ESC_DUPLICATE_DETECTED SUCCESS-path Telegram approval gate here (per
   331	# agent.md §5 + catalogue §2.5); auto pairs queue write proposals for Step 9.
   332	# ────────────────────────────────────────────────────────────────────────
   333	
   334	_jn_dedup_pass() {  # <entity_type> <marker_name>
   335	  local etype="$1" marker="$2"
   336	  local pool pairs_json auto review dropped
   337	  pool="[]"
   338	  if [[ "${_jn_db_up}" -eq 1 ]]; then
   339	    pool="$(_jn_psql --set=etype="${etype}" <<'SQL' 2>/dev/null | head -1 || echo '[]'
   340	BEGIN;
   341	SET LOCAL app.current_tenant = :'tenant';
   342	SELECT coalesce(jsonb_agg(jsonb_build_object(
   343	  'entity_id', entity_id,
   344	  'name', coalesce(nullif(data->>'name',''), trim(concat(data->>'first_name',' ',data->>'last_name'))),
   345	  'email', data->>'email',
   346	  'phone', data->>'phone',
   347	  'linkedin_url', data->>'linkedin_url',
   348	  'last_activity_days', (CASE WHEN data->>'last_activity_days' ~ '^[0-9]+$'
   349	                              THEN (data->>'last_activity_days')::int ELSE NULL END)
   350	)), '[]'::jsonb)::text
   351	FROM entities WHERE entity_type = :'etype';
   352	COMMIT;
   353	SQL
   354	)"
   355	  fi
   356	  [[ -z "${pool}" ]] && pool="[]"
   357	  pairs_json="$(printf '%s' "${pool}" \
   358	    | bash "$(_jn_bin dedup-pairs.sh)" --threshold "${CTX_JANITOR_DEDUP_THRESHOLD}" 2>/dev/null \
   359	    || echo '{"auto":0,"review":0,"dropped":0,"pairs":[]}')"
   360	  auto="$(printf '%s' "${pairs_json}" | jq -r '.auto')"
   360	  auto="$(printf '%s' "${pairs_json}" | jq -r '.auto')"
   361	  review="$(printf '%s' "${pairs_json}" | jq -r '.review')"
   362	  dropped="$(printf '%s' "${pairs_json}" | jq -r '.dropped')"
   363	
   364	  # Review band → ESC_DUPLICATE_DETECTED per pair (SUCCESS-path approval gate).
   365	  # Payload per the amended catalogue §2.5 entry (2026-06-10): entity_a_id /
   366	  # entity_b_id / entity_type / confidence_score / match_basis / hold_reason
   367	  # (review_band | recency_hold_90d); the matcher's verbatim reason rides in
   368	  # hold_detail for operator debuggability.
   369	  while IFS=$'\t' read -r _ra _rb _rc _rm _rr; do
   370	    [[ -z "${_ra}" ]] && continue
   371	    _rh="review_band"
   372	    case "${_rr}" in
   373	      recent_activity_days:*|activity_unknown*) _rh="recency_hold_90d" ;;
   374	    esac
   375	    autosend_escalate "ESC_DUPLICATE_DETECTED" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
   376	      "entity_a_id=${_ra}" "entity_b_id=${_rb}" "entity_type=${etype}" \
   377	      "confidence_score=${_rc}" "match_basis=${_rm}" "hold_reason=${_rh}" \
   378	      "hold_detail=${_rr}" "routing=operator_telegram_approval_gate"
   379	    _jn_exception "Review-band ${etype} pair ${_ra}/${_rb} (conf ${_rc}; ${_rr}) — held for operator approval (ESC_DUPLICATE_DETECTED)"
   380	  done < <(printf '%s' "${pairs_json}" \
   381	    | jq -r '.pairs[] | select(.band == "review") | [.primary_id, .target_id, (.confidence|tostring), (.dims | join("+")), .reason] | @tsv')
   382	
   383	  # Auto band → Step 9 write proposals (validate.sh contract shape).
   384	  while IFS= read -r _ap; do
   385	    [[ -z "${_ap}" ]] && continue
   386	    printf '%s' "${_ap}" | jq --arg et "${etype}" '
   387	      {action_type: "bullhorn_candidate_dedupe", entity_type: $et,
   388	       primary_id: .primary_id, merge_target_id: .target_id,
   389	       confidence: .confidence, match_dimensions: .dims,
   390	       last_activity_days: ([.a_act, .b_act] | map(select(. >= 0)) | min // 0)}' \
   391	      > "${_JN_TMPD}/proposals/dedupe-${etype}-$(printf '%s' "${_ap}" | jq -r '.primary_id').json"
   392	  done < <(printf '%s' "${pairs_json}" | jq -c '.pairs[] | select(.band == "auto")')
   393	
   394	  hh_decision_output "${marker}" "tenant:${CTX_TENANT_SLUG}" \
   395	    "auto_merges:${auto}; review_band:${review}; dropped:${dropped}"
   396	}
   397	
   398	# ────────────────────────────────────────────────────────────────────────
   399	# Step 3 — Dedup pass: candidate entity
   400	# Reference: agent.md §4 Step 3; weights name·0.3 + email·0.4 + phone·0.2 +
   401	# linkedin·0.1 with comparable-weight normalisation + required strong
   402	# identifier (Scout-reviewed semantics; see bin/dedup-pairs.sh header) vs the
   403	# ≥0.85 threshold. Band→action per spec-001 §4: ≥0.85 + no-90d-activity →
   404	# auto (yellow); 0.70-0.85 OR 90d-activity → hold via ESC_DUPLICATE_DETECTED;
   405	# <0.70 → silent drop. hh_decision_action rows land at Step 9 on write.
   406	# ────────────────────────────────────────────────────────────────────────
   407	
   408	if _step_planned 3; then
   409	  _jn_dedup_pass "candidate" "dedup_candidate_pass"
   410	fi
   411	
   412	# ────────────────────────────────────────────────────────────────────────
   413	# Step 4 — Dedup pass: contractor entity (same matcher; separate entity_type
   414	# per vertical-schema.yaml §1 + Q1 Day-6 resolution).
   415	# ────────────────────────────────────────────────────────────────────────
   416	
   417	if _step_planned 4; then
   418	  _jn_dedup_pass "contractor" "dedup_contractor_pass"
   419	fi
   420	
   421	# ────────────────────────────────────────────────────────────────────────
   422	# Step 5 — Field completeness audit (canonical field names per vertical-schema.yaml)
   423	# Reference: agent.md §4 Step 5 + spec-001 §4 (marker: field_completeness_audit).
   424	# Reusable RLS-scoped sql/field-completeness.sql (shared with the report test).
   425	# ────────────────────────────────────────────────────────────────────────
   426	
   427	JN_CLIENT_QUEUE="${_JN_TMPD}/client-queue.txt"
   428	: > "${JN_CLIENT_QUEUE}"
   429	if _step_planned 5; then
   430	  _jn_missing_total=0
   431	  _jn_fc_sql="$(_jn_sql field-completeness.sql)"
   432	  if [[ "${_jn_db_up}" -eq 1 && -f "${_jn_fc_sql}" ]]; then
   433	    _jn_fc_out="$(_jn_psql <<SQL 2>/dev/null || true
   434	BEGIN;
   435	SET LOCAL app.current_tenant = :'tenant';
   436	\\i ${_jn_fc_sql}
   437	COMMIT;
   438	SQL
   439	)"
   440	    while IFS='|' read -r _kind _f2 _f3 _f4; do
   441	      case "${_kind}" in
   442	        summary)      _jn_missing_total=$((_jn_missing_total + _f4)) ;;
   443	        client_queue) printf '%s|%s|%s\n' "${_f2}" "${_f3}" "${_f4}" >> "${JN_CLIENT_QUEUE}" ;;
   444	      esac
   445	    done <<<"${_jn_fc_out}"
   446	  fi
   447	  # awk (not `grep -c || echo 0`): grep prints "0" AND fails on an empty file,
   448	  # so the || arm appended a second 0 → newline-corrupted marker reason.
   449	  _jn_enrichable="$(awk 'END{print NR}' "${JN_CLIENT_QUEUE}" 2>/dev/null || echo 0)"
   450	  hh_decision_output "field_completeness_audit" "tenant:${CTX_TENANT_SLUG}" \
   451	    "${_jn_missing_total} missing-field rows; enrichable_via_companies_house:${_jn_enrichable}"
   452	fi
   453	
   454	# ────────────────────────────────────────────────────────────────────────
   455	# Step 6 — Companies House enrichment (clients only)
   456	# Reference: agent.md §4 Step 6. bin/ch-lookup.mjs over @ifos/companies-house
   457	# dist (7d cache + shared rate budget INSIDE the connector — Diagnostic
   458	# precedent). Live-capable this cycle (key SET). Fixture override
   459	# IFOS_JANITOR_FIXTURE_CH keeps tests offline. Per-client cap 25/run keeps
   460	# the shared 600/5min budget safe. rate_limited → ESC_RATE_LIMIT_HIT + stop.
   461	# Backfill writes land at Step 9 (bullhorn_field_backfill action rows).
   462	# ────────────────────────────────────────────────────────────────────────
   463	
   464	if _step_planned 6; then
   465	  _jn_lookups=0
   466	  _jn_backfill_props=0
   467	  _jn_ch_cap=25
   468	  while IFS='|' read -r _cq_id _cq_name _cq_missing; do
   469	    [[ -z "${_cq_id}" || "${_jn_lookups}" -ge "${_jn_ch_cap}" ]] && continue
   470	    _jn_lookups=$((_jn_lookups + 1))
   471	    _jn_ch_row=""
   472	    if [[ -n "${IFOS_JANITOR_FIXTURE_CH:-}" && -f "${IFOS_JANITOR_FIXTURE_CH}" ]]; then
   473	      _jn_ch_row="$(jq -c --arg q "${_cq_name}" \
   474	        '[.[] | select((.query | ascii_downcase) == ($q | ascii_downcase))] | first // empty' \
   475	        "${IFOS_JANITOR_FIXTURE_CH}" 2>/dev/null || true)"
   476	      if [[ -n "${_jn_ch_row}" ]]; then
   477	        _jn_ch_row="$(printf '%s' "${_jn_ch_row}" | jq -c '. + {ok: true, source_confidence: (.source_confidence // 0.9)}')"
   478	      else
   479	        _jn_ch_row='{"ok":false,"not_found":true,"source_confidence":0}'
   480	      fi
   481	    elif [[ -n "${COMPANIES_HOUSE_API_KEY:-}" ]]; then
   482	      _jn_ch_row="$(node "$(_jn_bin ch-lookup.mjs)" --name "${_cq_name}" \
   483	        --conn-base "${_JN_CONN_BASE}" 2>/dev/null || echo '{"ok":false,"error":"lookup_failed","source_confidence":0}')"
   484	    else
   485	      _jn_ch_row='{"ok":false,"error":"companies_house_key_absent","source_confidence":0}'
   486	    fi
   487	    if printf '%s' "${_jn_ch_row}" | jq -e '.error == "rate_limited"' >/dev/null 2>&1; then
   488	      autosend_escalate "ESC_RATE_LIMIT_HIT" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
   489	        "upstream=companies-house" "step=6" "lookups_done=${_jn_lookups}"
   490	      _jn_exception "Companies House rate limit hit after ${_jn_lookups} lookups — enrichment stopped this run"
   491	      break
   492	    fi
   493	    if printf '%s' "${_jn_ch_row}" | jq -e '.ok == true' >/dev/null 2>&1; then
   494	      _jn_crn="$(printf '%s' "${_jn_ch_row}" | jq -r '.crn // empty')"
   495	      _jn_ind="$(printf '%s' "${_jn_ch_row}" | jq -r '.industry // empty')"
   496	      _jn_conf="$(printf '%s' "${_jn_ch_row}" | jq -r '.source_confidence')"
   497	      _jn_changes="$(jq -nc --arg crn "${_jn_crn}" --arg ind "${_jn_ind}" --arg miss "${_cq_missing}" '
   498	        ($miss | split(",")) as $m
   499	        | ( if ($m | index("companies_house_number")) != null and $crn != "" then {companies_house_number: $crn} else {} end )
   500	          + ( if ($m | index("industry")) != null and $ind != "" then {industry: $ind} else {} end )')"
   501	      if [[ "$(printf '%s' "${_jn_changes}" | jq 'length')" -gt 0 ]]; then
   502	        jq -nc --arg id "${_cq_id}" --argjson fc "${_jn_changes}" --argjson sc "${_jn_conf}" '
   503	          {action_type: "bullhorn_field_backfill", entity_type: "client",
   504	           primary_id: $id, field_changes: $fc,
   505	           source: "companies_house", source_confidence: $sc}' \
   506	          > "${_JN_TMPD}/proposals/backfill-client-${_cq_id}.json"
   507	        _jn_backfill_props=$((_jn_backfill_props + 1))
   508	      fi
   509	    else
   510	      _jn_exception "Companies House: no confident match for client '${_cq_name}' (id ${_cq_id}) — no backfill proposed (G4 honest)"
   511	    fi
   512	  done < "${JN_CLIENT_QUEUE}"
   513	  hh_decision_output "companies_house_enrichment" "tenant:${CTX_TENANT_SLUG}" \
   514	    "lookups:${_jn_lookups}; backfill_proposals:${_jn_backfill_props}; cache:connector_managed_7d_ttl"
   515	fi
   516	
   517	# ────────────────────────────────────────────────────────────────────────
   518	# Step 7 — LinkedIn enrichment (v1.0 NO-OP per agent.md §4 Step 7)
   519	# v1.0 caveat: Proxycurl shut down 2025 (LinkedIn lawsuit; nubela.co/blog/
   520	# goodbye-proxycurl/); NinjaPear successor doesn't carry LinkedIn data.
   521	# v1.1+ vendor selection deferred to W8-9 (Lix / Phantombuster / Apify /
   522	# Sales Navigator per .agents/current-priorities.md action board item 8).
   523	# ────────────────────────────────────────────────────────────────────────
   524	
   525	if _step_planned 7; then
   526	  # NO-OP at v1.0; explicit no-op audit row so the day-30 report can reference
   527	  # "LinkedIn enrichment: v1.1+ scope" rather than a silent skip.
   528	  hh_decision_output "linkedin_enrichment_skipped" "tenant:${CTX_TENANT_SLUG}" \
   529	    "reason:v1.0_caveat_proxycurl_shutdown; vendor_selection:W8-9_deferred"
   530	fi
   531	
   532	# ────────────────────────────────────────────────────────────────────────
   533	# Step 8 — Tacit-note harvest (from recent_edit; v0.3 supplement §2a grants Janitor R)
   534	# Reference: agent.md §4 Step 8 + spec-001 §4 (marker: janitor_tacit_note_harvest).
   535	# SELECT … WHERE resolution='approved_after_edit' AND resolved_at > now()-30d;
   536	# group by target_entity_type; per-group narrative via bin/render-tacit-note.sh
   537	# (deterministic template; LLM polish active when ANTHROPIC_API_KEY set —
   538	# aggregate facts only, raw edit text NEVER leaves Postgres). Voice honesty:
   539	# empty voice_corpus → unscored/no_corpus (never a faked score; CC precedent);
   540	# IFOS_JANITOR_FORCE_VOICE_SCORE exercises the scored ESC_VOICE_DRIFT route
   541	# (G5 enforces at Step 9; agent.md fires it after the 3-retry budget).
   542	# ────────────────────────────────────────────────────────────────────────
   543	
   544	if _step_planned 8; then
   545	  _jn_harvested=0
   546	  _jn_groups=0
   547	  _jn_drafts=0
   548	  _jn_voice="unscored"
   549	  _jn_voice_reason="no_corpus"
   550	  if [[ -n "${IFOS_JANITOR_FORCE_VOICE_SCORE:-}" ]]; then
   551	    _jn_voice="${IFOS_JANITOR_FORCE_VOICE_SCORE}"
   552	    _jn_voice_reason="forced_fixture_score"
   553	  elif [[ "${CTX_VOICE_CORPUS_STATE:-absent}" == "active" ]]; then
   554	    # Corpus exists but no embedding classifier ships at v1.0 — still honest.
   555	    _jn_voice_reason="classifier_unavailable"
   556	  fi
   557	  if [[ "${_jn_db_up}" -eq 1 ]]; then
   558	    _jn_h_out="$(_jn_psql <<'SQL' 2>/dev/null || true
   559	BEGIN;
   560	SET LOCAL app.current_tenant = :'tenant';
   561	SELECT coalesce(target_entity_type, 'unattributed') || '|' || count(*)::text || '|' ||
   562	       string_agg(DISTINCT action_type, ',' ORDER BY action_type) || '|' ||
   563	       coalesce(min(target_entity_id), '0')
   564	FROM recent_edit
   565	WHERE tenant_slug = :'tenant' AND resolution = 'approved_after_edit'
   566	  AND resolved_at > now() - interval '30 days'
   567	GROUP BY coalesce(target_entity_type, 'unattributed')
   568	ORDER BY 1;
   569	COMMIT;
   570	SQL
   571	)"
   572	    while IFS='|' read -r _hg_type _hg_count _hg_actions _hg_first_id; do
   573	      [[ -z "${_hg_type}" ]] && continue
   574	      _jn_groups=$((_jn_groups + 1))
   575	      _jn_harvested=$((_jn_harvested + _hg_count))
   576	      _jn_narrative="$(bash "$(_jn_bin render-tacit-note.sh)" \
   577	        --entity-type "${_hg_type}" --edit-count "${_hg_count}" \
   578	        --action-types "${_hg_actions}" --window-days 30 2>/dev/null || true)"
   579	      [[ -z "${_jn_narrative}" ]] && continue
   580	      _jn_note_id="${_hg_first_id:-0}"
   581	      [[ "${_jn_note_id}" =~ ^[0-9]+$ ]] || _jn_note_id="0"
   582	      jq -nc --arg et "${_hg_type}" --arg id "${_jn_note_id}" \
   583	        --arg body "${_jn_narrative}" --arg vs "${_jn_voice}" --arg vr "${_jn_voice_reason}" '
   584	        {action_type: "bullhorn_note_attach", entity_type: $et,
   585	         primary_id: $id, narrative_body: $body,
   586	         voice_score: (if ($vs | test("^[0-9.]+$")) then ($vs | tonumber) else $vs end),
   587	         voice_reason: $vr}' \
   588	        > "${_JN_TMPD}/proposals/note-${_hg_type}.json"
   589	      _jn_drafts=$((_jn_drafts + 1))
   590	    done <<<"${_jn_h_out}"
   591	  fi
   592	  hh_decision_output "janitor_tacit_note_harvest" "tenant:${CTX_TENANT_SLUG}" \
   593	    "harvested:${_jn_harvested} rows; groups:${_jn_groups} entity-types; narrative_drafts:${_jn_drafts}; voice_score:${_jn_voice}; voice_reason:${_jn_voice_reason}"
   594	fi
   595	
   596	# ────────────────────────────────────────────────────────────────────────
   597	# Step 9 — Bullhorn write batch (yellow tier — 3 action_types per agent.md §3 Output 2)
   598	# Reference: agent.md §4 Step 9. Per proposal: Gate A (validate.sh) →
   599	# write via @ifos/bullhorn CLI when live → hh_decision_action yellow row
   600	# (autosend-policy.yaml: bullhorn_candidate_dedupe rate=10;
   601	# bullhorn_field_backfill rate=10; bullhorn_note_attach rate=20).
   602	# 4xx → ESC_BULLHORN_WRITE_FAIL + skip + continue; 5xx → retry once with 30s
   603	# backoff then ESC + skip. Degraded (creds founder-gated) → the validated
   604	# yellow action row is recorded with write_state:deferred_no_bullhorn_creds —
   605	# the audit decision is real, the transport is honestly deferred, never faked.
   606	# ≤100/min defensive cap; remainder defers to the next run. NEVER runs in
   607	# dry-run / report-only modes.
   608	# ────────────────────────────────────────────────────────────────────────
   609	
   610	JN_MERGES=0; JN_BACKFILLS=0; JN_NOTES=0; JN_DEFERRED=0; JN_WFAILS=0; JN_GATE_REJECTS=0
   611	if _step_planned 9; then
   612	  _jn_validate="${CTX_AGENT_DIR}/validate.sh"
   613	  [[ -f "${_jn_validate}" ]] || _jn_validate="${IFOS_REPO_ROOT:-}/agents/recruitment/janitor/validate.sh"
   614	  _jn_batch_idx=0
   615	
   616	  _jn_bh_write() {  # <proposal_json_path> ; echoes applied|applied_fixture|deferred|fail4xx|fail5xx
   617	    local prop="$1" atype cmd_out http_class
   618	    atype="$(jq -r '.action_type' "${prop}")"
   619	    if [[ -n "${IFOS_JANITOR_FIXTURE_WRITE_RESULT:-}" ]]; then
   620	      case "${IFOS_JANITOR_FIXTURE_WRITE_RESULT}" in
   621	        ok)  echo "applied_fixture"; return 0 ;;
   622	        4xx) echo "fail4xx"; return 0 ;;
   623	        5xx) echo "fail5xx"; return 0 ;;
   624	      esac
   625	    fi
   626	    if [[ "${_jn_token_state}" != "ok" ]]; then
   627	      echo "deferred"; return 0
   628	    fi
   629	    local id patch
   630	    id="$(jq -r '.primary_id' "${prop}")"
   631	    case "${atype}" in
   632	      bullhorn_candidate_dedupe)
   633	        # v1.0 merge write: stamp the primary with the merge provenance; full
   634	        # field-cascade merge is the post-sandbox enhancement (agent.md §9 Q3
   635	        # gotcha — Bullhorn has no single-call merge API).
   636	        patch="$(jq -c '{customText1: ("ifos:merged_from:" + (.merge_target_id|tostring))}' "${prop}")"
   637	        cmd_out="$(node "${_JN_BH_CLI}" update-candidate --id "${id}" --patch "${patch}" 2>&1)" ;;
   638	      bullhorn_field_backfill)
   639	        patch="$(jq -c '.field_changes' "${prop}")"
   640	        if [[ "$(jq -r '.entity_type' "${prop}")" == "client" ]]; then
   641	          cmd_out="$(node "${_JN_BH_CLI}" update-client --id "${id}" --patch "${patch}" 2>&1)"
   642	        else
   643	          cmd_out="$(node "${_JN_BH_CLI}" update-candidate --id "${id}" --patch "${patch}" 2>&1)"
   644	        fi ;;
   645	      bullhorn_note_attach)
   646	        cmd_out="$(node "${_JN_BH_CLI}" create-note --person-id "${id}" \
   647	          --comments "$(jq -r '.narrative_body' "${prop}")" 2>&1)" ;;
   648	      *) echo "fail4xx"; return 0 ;;
   649	    esac
   650	    if printf '%s' "${cmd_out}" | jq -e '.ok == true' >/dev/null 2>&1; then
   860	
   861	_jn_triple_miss=0
   862	if [[ "${_jn_db_up}" -eq 1 ]]; then
   863	  _jn_last3="$(_jn_psql <<'SQL' 2>/dev/null || true
   864	BEGIN;
   865	SET LOCAL app.current_tenant = :'tenant';
   866	SELECT coalesce((reason LIKE '%gate_b_both_missed:true%')::text, 'false')
   867	FROM decision_log
   868	WHERE tenant_slug = :'tenant' AND agent_name = 'janitor'
   869	  AND phase = 'output' AND payload->>'output_type' = 'day_30_report'
   870	ORDER BY id DESC LIMIT 3;
   871	COMMIT;
   872	SQL
   873	)"
   874	  _jn_miss_rows=0; _jn_total_rows=0
   875	  while IFS= read -r _r; do
   876	    [[ -z "${_r}" ]] && continue
   877	    _jn_total_rows=$((_jn_total_rows + 1))
   878	    [[ "${_r}" == "true" ]] && _jn_miss_rows=$((_jn_miss_rows + 1))
   879	  done <<<"${_jn_last3}"
   880	  [[ "${_jn_total_rows}" -eq 3 && "${_jn_miss_rows}" -eq 3 ]] && _jn_triple_miss=1
   881	fi
   882	
   883	if _step_planned 11; then NOTIFIED="true"; else NOTIFIED="false"; fi
   884	_jn_run_hash="$(printf '%s' "${CTX_TENANT_SLUG}|${MODE}|$(date -u +%s)" | shasum -a 256 2>/dev/null | cut -c1-16)"
   885	[[ -z "${_jn_run_hash}" ]] && _jn_run_hash="run-${MODE}"
   886	hh_decision_action "janitor_run_complete" "session:${CTX_TENANT_SLUG}" "${_jn_run_hash}" \
   887	  "mode:${MODE}; corporation_id:${CTX_BULLHORN_CORPORATION_ID}; bullhorn_token:${_jn_token_state}; merges:${JN_MERGES}; backfills:${JN_BACKFILLS}; notes:${JN_NOTES}; deferred:${JN_DEFERRED}; notified:${NOTIFIED}; gate_b_met:${JN_GATE_B_MET}" || true
   888	
   889	if [[ "${_jn_triple_miss}" -eq 1 ]]; then
   890	  autosend_escalate "ESC_GATE_B_MISS" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
   891	    "consecutive_runs=3" "trigger=both_thresholds_missed" \
   892	    "disposition=operator_heuristic_review_not_a_kill"
   893	  printf 'cycle.sh: Gate B BOTH thresholds missed 3 consecutive runs — ESC_GATE_B_MISS (exit 1)\n' >&2
   894	  exit 1
   895	fi
   896	
   897	exit 0

exec
/bin/zsh -lc 'rg -n "hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|bullhorn_auth_refresh|linkedin_enrichment_skipped|dedup_candidate_pass|dedup_contractor_pass|ESC_DUPLICATE_DETECTED|ESC_GATE_B_MISS|janitor_run_complete|hh_decision_action|hh_decision_output|hh_decision_trigger|autosend_escalate" agents/recruitment/janitor/cycle.sh agents/recruitment/janitor/context.sh agents/recruitment/janitor/cleanup.sh' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
agents/recruitment/janitor/cycle.sh:58:# Telegram approval via ESC_DUPLICATE_DETECTED (SUCCESS path; fired at Steps 3-4).
agents/recruitment/janitor/cycle.sh:184:hh_decision_trigger "session_start" "janitor mode=${MODE}"
agents/recruitment/janitor/cycle.sh:213:hh_decision_output "bullhorn_auth_refresh" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:218:    autosend_escalate "ESC_BULLHORN_AUTH" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:223:    autosend_escalate "ESC_BULLHORN_AUTH" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:243:hh_decision_output "mode_routed" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:278:          autosend_escalate "ESC_RATE_LIMIT_HIT" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:321:  hh_decision_output "janitor_scan" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:330:# ESC_DUPLICATE_DETECTED SUCCESS-path Telegram approval gate here (per
agents/recruitment/janitor/cycle.sh:364:  # Review band → ESC_DUPLICATE_DETECTED per pair (SUCCESS-path approval gate).
agents/recruitment/janitor/cycle.sh:375:    autosend_escalate "ESC_DUPLICATE_DETECTED" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:379:    _jn_exception "Review-band ${etype} pair ${_ra}/${_rb} (conf ${_rc}; ${_rr}) — held for operator approval (ESC_DUPLICATE_DETECTED)"
agents/recruitment/janitor/cycle.sh:394:  hh_decision_output "${marker}" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:404:# auto (yellow); 0.70-0.85 OR 90d-activity → hold via ESC_DUPLICATE_DETECTED;
agents/recruitment/janitor/cycle.sh:405:# <0.70 → silent drop. hh_decision_action rows land at Step 9 on write.
agents/recruitment/janitor/cycle.sh:409:  _jn_dedup_pass "candidate" "dedup_candidate_pass"
agents/recruitment/janitor/cycle.sh:418:  _jn_dedup_pass "contractor" "dedup_contractor_pass"
agents/recruitment/janitor/cycle.sh:450:  hh_decision_output "field_completeness_audit" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:488:      autosend_escalate "ESC_RATE_LIMIT_HIT" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:513:  hh_decision_output "companies_house_enrichment" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:528:  hh_decision_output "linkedin_enrichment_skipped" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:592:  hh_decision_output "janitor_tacit_note_harvest" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:599:# write via @ifos/bullhorn CLI when live → hh_decision_action yellow row
agents/recruitment/janitor/cycle.sh:684:        autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:688:        autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:703:    hh_decision_action "${_jn_atype}" "entity:${_jn_etype}:${_jn_pid}" "${_jn_phash}" \
agents/recruitment/janitor/cycle.sh:711:  hh_decision_output "bullhorn_write_batch" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:772:    printf '## 2. Dedup pairs (30d)\n\n- Auto-merged (≥%s confidence, no 90d activity): %s\n- Held for approval (review band via ESC_DUPLICATE_DETECTED): %s\n- Per-pair detail: see decision_log action rows (action_type=bullhorn_candidate_dedupe) + gating rows (ESC_DUPLICATE_DETECTED)\n\n' \
agents/recruitment/janitor/cycle.sh:799:  hh_decision_output "day_30_report" "${REPORT_PATH}" \
agents/recruitment/janitor/cycle.sh:835:  hh_decision_action "operator_notify_telegram" "tenant:${CTX_TENANT_SLUG}" "${_jn_nhash}" \
agents/recruitment/janitor/cycle.sh:842:# by the v0.4 trigger). ESC_GATE_B_MISS fires ONLY when BOTH Gate B thresholds
agents/recruitment/janitor/cycle.sh:886:hh_decision_action "janitor_run_complete" "session:${CTX_TENANT_SLUG}" "${_jn_run_hash}" \
agents/recruitment/janitor/cycle.sh:890:  autosend_escalate "ESC_GATE_B_MISS" "agent=janitor" "tenant=${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:893:  printf 'cycle.sh: Gate B BOTH thresholds missed 3 consecutive runs — ESC_GATE_B_MISS (exit 1)\n' >&2
agents/recruitment/janitor/context.sh:182:# Reference: agent.md §7. hh_load_tone_rules filtered by applies_to_agents
agents/recruitment/janitor/context.sh:206:if command -v jq >/dev/null 2>&1 && declare -F hh_load_tone_rules >/dev/null 2>&1; then
agents/recruitment/janitor/context.sh:207:  CTX_TONE_RULES_COUNT="$(hh_load_tone_rules "janitor" 2>/dev/null \
agents/recruitment/janitor/context.sh:235:# ESC_DUPLICATE_DETECTED approval gate). v0.4-allowlisted canonical path;
agents/recruitment/janitor/context.sh:260:hh_decision_trigger "session_start" \
agents/recruitment/janitor/cleanup.sh:15:# hh_decision_output; switch to hh_decision_action once registered
agents/recruitment/janitor/cleanup.sh:109:# Stays hh_decision_output until janitor_cleanup is registered in
agents/recruitment/janitor/cleanup.sh:111:hh_decision_output "janitor_cleanup" "tenant:${CTX_TENANT_SLUG}" \

exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/context.sh | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Janitor agent — context.sh (pre-cycle hydration; W6-7 LIVE)
     3	#
     4	# Status: LIVE per spec-001 §4 Step 0 (W6-7 build slice).
     5	# Reading order: agent.md §2 (invocation surface) + §4 Step 0 (session start) +
     6	#         §7 (voice + tone constraints) first.
     7	#
     8	# Per ADR-003 v2 agent-bundle pattern: bus invokes context.sh BEFORE cycle.sh
     9	# at session start. context.sh hydrates session-scoped CTX_* env vars that
    10	# cycle.sh + validate.sh read, then emits the mandatory session_start trigger
    11	# row to anchor the session in decision_log.
    12	#
    13	# Invocation contract:
    14	#   bash context.sh
    15	#
    16	# Inputs (env from bus):
    17	#   CTX_AGENT_DIR    — agent's directory (this file's dirname)
    18	#   CTX_TENANT_SLUG  — tenant the run targets
    19	#
    20	# Side effects:
    21	#   - Canonical tenant_adapters.config reads (RLS SET LOCAL app.current_tenant)
    22	#     for janitor_dedup_threshold (v0.3-allowlisted), bullhorn_corporation_id +
    23	#     operator_telegram_chat_id (v0.4-allowlisted; LIVE on VPS per commit a1bbcf6)
    24	#   - Bullhorn auth state probe via @ifos/bullhorn dist/cli.js (check-auth is
    25	#     network-free; refresh only attempted when creds + token bundle present —
    26	#     Bullhorn creds are founder-gated today per spec-001 §8, so the honest
    27	#     state is 'absent' and cycle.sh runs in degraded mode against the
    28	#     Postgres entities cache)
    29	#   - Voice corpus presence + tone-rule count (for Step 8 tacit-note narrative
    30	#     per agent.md §7); empty corpus → Step 8 records unscored/no_corpus
    31	#   - recent_edit 30d lookback count (Step 8 harvest input; v0.3 supplement
    32	#     §2a grants Janitor R access)
    33	#
    34	# Outputs (exported CTX_* vars; cycle.sh + validate.sh consume):
    35	#   CTX_AGENT_NAME                       — "janitor"
    36	#   CTX_BULLHORN_CORPORATION_ID          — per-tenant Bullhorn corp identifier
    37	#   CTX_OPERATOR_TELEGRAM_CHAT_ID        — tenant operator's Telegram chat ID (Step 11)
    38	#   CTX_BULLHORN_TOKEN_STATE             — ok | failed | configured_no_tokens | absent | fixture
    39	#   CTX_VOICE_CORPUS_ID                  — voice_corpus row id (Step 8) or "none"
    40	#   CTX_VOICE_CORPUS_STATE               — active | absent
    41	#   CTX_TONE_RULES_COUNT                 — number of tone_rule rows loaded
    42	#   CTX_JANITOR_DEDUP_THRESHOLD          — default 0.85; per-tenant override [0.75, 0.95]
    43	#   CTX_RECENT_EDITS_WINDOW_DAYS         — 30 (Step 8 lookback window per agent.md §4)
    44	#   CTX_RECENT_EDITS_COUNT               — approved_after_edit rows in the window
    45	#   CTX_FIRM_DOMAIN_WHITELIST            — firm-boundary domain for validate.sh G6
    46	
    47	set -euo pipefail
    48	
    49	# ────────────────────────────────────────────────────────────────────────
    50	# Pre-flight: CTX env + _shared/ helper resolution
    51	# ────────────────────────────────────────────────────────────────────────
    52	
    53	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    54	  printf 'janitor/context.sh: CTX_AGENT_DIR unset (bus must set this)\n' >&2
    55	  exit 2
    56	fi
    57	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    58	  printf 'janitor/context.sh: CTX_TENANT_SLUG unset\n' >&2
    59	  exit 2
    60	fi
    61	export CTX_AGENT_NAME="janitor"
    62	
    63	# 4-candidate _shared/ helper fallback (matches sibling agents post commit d7d52c5).
    64	_SHARED_DIR=""
    65	for _candidate in \
    66	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    67	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    68	  "${CTX_AGENT_DIR}/../../_shared" \
    69	  "${CTX_AGENT_DIR}/../_shared" ; do
    70	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    71	    _SHARED_DIR="${_candidate}"
    72	    break
    73	  fi
    74	done
    75	if [[ -z "${_SHARED_DIR}" ]]; then
    76	  printf 'context.sh: cannot locate _shared/ helpers\n' >&2
    77	  exit 1
    78	fi
    79	# shellcheck source=/dev/null
    80	source "${_SHARED_DIR}/hook-helpers.sh"
    81	# shellcheck source=/dev/null
    82	source "${_SHARED_DIR}/voice-loader.sh" 2>/dev/null || true
    83	
    84	# Connector base + secrets (Path A: values sourced into env, never printed —
    85	# mirrors cash-conductor/context.sh).
    86	_JN_CONN_BASE="${IFOS_REPO_ROOT:+${IFOS_REPO_ROOT}/packages/mcp-connectors}"
    87	if [[ -z "${_JN_CONN_BASE}" || ! -d "${_JN_CONN_BASE}" ]]; then
    88	  _JN_CONN_BASE="${_SHARED_DIR}/../../packages/mcp-connectors"
    89	fi
    90	_JN_SECRETS="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
    91	if [[ -f "${_JN_SECRETS}" ]]; then
    92	  set -a
    93	  # shellcheck source=/dev/null
    94	  source "${_JN_SECRETS}"
    95	  set +a
    96	fi
    97	
    98	# Canonical tenant_adapters config read (RLS-scoped; first row carrying the key).
    99	# Empty string when DB unreachable OR no row carries the key.
   100	_jn_tenant_config() {
   101	  local key="$1"
   102	  if [[ -z "${IFOS_DB_URL:-}" ]] || ! command -v psql >/dev/null 2>&1; then
   103	    return 0
   104	  fi
   105	  psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
   106	    --set=tenant="${CTX_TENANT_SLUG}" --set=key="${key}" <<'SQL' 2>/dev/null | head -1 || true
   107	BEGIN;
   108	SET LOCAL app.current_tenant = :'tenant';
   109	SELECT config->>:'key' FROM tenant_adapters
   110	WHERE tenant_slug = :'tenant' AND config ? :'key'
   111	ORDER BY id LIMIT 1;
   112	COMMIT;
   113	SQL
   114	}
   115	
   116	# ────────────────────────────────────────────────────────────────────────
   117	# Step 1 — Dedup confidence threshold (per-tenant override; default 0.85)
   118	# Reference: ULTRAPLAN A2 line 510 verbatim. v0.3 supplement §4
   119	# tenant_adapters_config_additions.janitor_dedup_threshold; validator allowed
   120	# range [0.75, 0.95] per migrations/v0.2-to-v0.3.sql §5 (trigger LIVE).
   121	# IFOS_FORCE_JANITOR_DEDUP_THRESHOLD retained for fixture + local-dev use.
   122	# ────────────────────────────────────────────────────────────────────────
   123	
   124	if [[ -n "${IFOS_FORCE_JANITOR_DEDUP_THRESHOLD:-}" ]]; then
   125	  CTX_JANITOR_DEDUP_THRESHOLD="${IFOS_FORCE_JANITOR_DEDUP_THRESHOLD}"
   126	else
   127	  CTX_JANITOR_DEDUP_THRESHOLD="$(_jn_tenant_config janitor_dedup_threshold)"
   128	fi
   129	export CTX_JANITOR_DEDUP_THRESHOLD="${CTX_JANITOR_DEDUP_THRESHOLD:-0.85}"
   130	
   131	# ────────────────────────────────────────────────────────────────────────
   132	# Step 2 — Bullhorn corporation_id resolution (v0.4-allowlisted canonical path;
   133	# LIVE on VPS per commit a1bbcf6). IFOS_FORCE_BULLHORN_CORPORATION_ID retained
   134	# for fixture + local-dev use per established pattern.
   135	# ────────────────────────────────────────────────────────────────────────
   136	
   137	if [[ -n "${IFOS_FORCE_BULLHORN_CORPORATION_ID:-}" ]]; then
   138	  CTX_BULLHORN_CORPORATION_ID="${IFOS_FORCE_BULLHORN_CORPORATION_ID}"
   139	else
   140	  CTX_BULLHORN_CORPORATION_ID="$(_jn_tenant_config bullhorn_corporation_id)"
   141	fi
   142	export CTX_BULLHORN_CORPORATION_ID="${CTX_BULLHORN_CORPORATION_ID:-unset}"
   143	
   144	# ────────────────────────────────────────────────────────────────────────
   145	# Step 3 — Bullhorn auth state (two-step Step A + Step B per @ifos/bullhorn
   146	# src/auth.ts; surfaced via dist/cli.js). Honest state model (spec-001 §8):
   147	# creds EMPTY today (founder-gated) → 'absent' → cycle.sh degraded mode
   148	# (scan from the Postgres entities cache; writes deferred). When creds land:
   149	# creds + token bundle → live refresh here; refresh failure → cycle.sh Step 1
   150	# retries then ESC_BULLHORN_AUTH (blocking).
   151	# IFOS_JANITOR_FIXTURE_BULLHORN_AUTH=ok|failed forces the state for fixtures.
   152	# ────────────────────────────────────────────────────────────────────────
   153	
   154	if [[ -n "${IFOS_JANITOR_FIXTURE_BULLHORN_AUTH:-}" ]]; then
   155	  case "${IFOS_JANITOR_FIXTURE_BULLHORN_AUTH}" in
   156	    ok)     CTX_BULLHORN_TOKEN_STATE="fixture" ;;
   157	    failed) CTX_BULLHORN_TOKEN_STATE="failed" ;;
   158	    *)      CTX_BULLHORN_TOKEN_STATE="absent" ;;
   159	  esac
   160	elif [[ -n "${BULLHORN_CLIENT_ID:-}" && -n "${BULLHORN_CLIENT_SECRET:-}" ]]; then
   161	  _jn_bh_cli="${_JN_CONN_BASE}/bullhorn/dist/cli.js"
   162	  if [[ -f "${_jn_bh_cli}" ]]; then
   163	    if node "${_jn_bh_cli}" check-auth 2>/dev/null | jq -e '.tokens_present == true' >/dev/null 2>&1; then
   164	      if node "${_jn_bh_cli}" refresh 2>/dev/null | jq -e '.ok == true' >/dev/null 2>&1; then
   165	        CTX_BULLHORN_TOKEN_STATE="ok"
   166	      else
   167	        CTX_BULLHORN_TOKEN_STATE="failed"
   168	      fi
   169	    else
   170	      CTX_BULLHORN_TOKEN_STATE="configured_no_tokens"   # consent flow not yet run
   171	    fi
   172	  else
   173	    CTX_BULLHORN_TOKEN_STATE="configured_no_tokens"     # CLI not built
   174	  fi
   175	else
   176	  CTX_BULLHORN_TOKEN_STATE="absent"
   177	fi
   178	export CTX_BULLHORN_TOKEN_STATE
   179	
   180	# ────────────────────────────────────────────────────────────────────────
   181	# Step 4 — Voice corpus + tone rules (for Step 8 tacit-note narrative)
   182	# Reference: agent.md §7. hh_load_tone_rules filtered by applies_to_agents
   183	# containing 'janitor'. Empty voice_corpus → CTX_VOICE_CORPUS_STATE=absent →
   184	# Step 8 records unscored/no_corpus (never a faked score; CC precedent).
   185	# ────────────────────────────────────────────────────────────────────────
   186	
   187	CTX_VOICE_CORPUS_ID="none"
   188	CTX_VOICE_CORPUS_STATE="absent"
   189	if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   190	  _jn_vc="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
   191	    --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1 || true
   192	BEGIN;
   193	SET LOCAL app.current_tenant = :'tenant';
   194	SELECT id FROM voice_corpus WHERE tenant_slug = :'tenant' AND is_active = true LIMIT 1;
   195	COMMIT;
   196	SQL
   197	)"
   198	  if [[ -n "${_jn_vc}" ]]; then
   199	    CTX_VOICE_CORPUS_ID="${_jn_vc}"
   200	    CTX_VOICE_CORPUS_STATE="active"
   201	  fi
   202	fi
   203	export CTX_VOICE_CORPUS_ID CTX_VOICE_CORPUS_STATE
   204	
   205	CTX_TONE_RULES_COUNT=0
   206	if command -v jq >/dev/null 2>&1 && declare -F hh_load_tone_rules >/dev/null 2>&1; then
   207	  CTX_TONE_RULES_COUNT="$(hh_load_tone_rules "janitor" 2>/dev/null \
   208	    | jq -r '.rules | length' 2>/dev/null || echo 0)"
   209	  [[ "${CTX_TONE_RULES_COUNT}" =~ ^[0-9]+$ ]] || CTX_TONE_RULES_COUNT=0
   210	fi
   211	export CTX_TONE_RULES_COUNT
   212	
   213	# Recent edits lookback window (Step 8 tacit-note harvest) — fixed at 30 days
   214	# per agent.md §4 Step 8 (30-day rolling window). Count loaded here as the
   215	# drift/coverage signal; the full rows are read by cycle.sh Step 8 under RLS.
   216	export CTX_RECENT_EDITS_WINDOW_DAYS="30"
   217	CTX_RECENT_EDITS_COUNT=0
   218	if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   219	  _jn_re="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
   220	    --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1 || true
   221	BEGIN;
   222	SET LOCAL app.current_tenant = :'tenant';
   223	SELECT count(*) FROM recent_edit
   224	WHERE tenant_slug = :'tenant' AND resolution = 'approved_after_edit'
   225	  AND resolved_at > now() - interval '30 days';
   226	COMMIT;
   227	SQL
   228	)"
   229	  [[ "${_jn_re}" =~ ^[0-9]+$ ]] && CTX_RECENT_EDITS_COUNT="${_jn_re}"
   230	fi
   231	export CTX_RECENT_EDITS_COUNT
   232	
   233	# ────────────────────────────────────────────────────────────────────────
   234	# Step 5 — Operator routing (Telegram chat ID for Step 11 + the
   235	# ESC_DUPLICATE_DETECTED approval gate). v0.4-allowlisted canonical path;
   236	# IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID retained per Concierge precedent.
   237	# ────────────────────────────────────────────────────────────────────────
   238	
   239	if [[ -n "${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-}" ]]; then
   240	  CTX_OPERATOR_TELEGRAM_CHAT_ID="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID}"
   241	else
   242	  CTX_OPERATOR_TELEGRAM_CHAT_ID="$(_jn_tenant_config operator_telegram_chat_id)"
   243	fi
   244	export CTX_OPERATOR_TELEGRAM_CHAT_ID="${CTX_OPERATOR_TELEGRAM_CHAT_ID:-unset}"
   245	
   246	# ────────────────────────────────────────────────────────────────────────
   247	# Step 6 — Firm-domain whitelist (validate.sh G6 PII firm-boundary regex).
   248	# Not a tenant_adapters allowlisted key at v0.4 — env-driven with a
   249	# conservative default (Scout precedent): unset → <tenant>.test, meaning any
   250	# real-world email in a narrative fails G6 until the tenant's firm domain is
   251	# configured. Conservative-by-default per agent.md §9 gotcha 2.
   252	# ────────────────────────────────────────────────────────────────────────
   253	
   254	export CTX_FIRM_DOMAIN_WHITELIST="${IFOS_FORCE_FIRM_DOMAIN_WHITELIST:-${CTX_TENANT_SLUG}.test}"
   255	
   256	# ────────────────────────────────────────────────────────────────────────
   257	# Step 7 — Session-start trigger row (mandatory; anchors session in decision_log)
   258	# ────────────────────────────────────────────────────────────────────────
   259	
   260	hh_decision_trigger "session_start" \

codex
I’ve found one hard bundle-boundary problem in `tools.yaml`, plus a likely contract/implementation mismatch in Gate A auth semantics. I’m doing one final pass for exact line references so the verdict can stay tight.
exec
/bin/zsh -lc 'rg -n "janitor_cleanup|bullhorn_oauth|operator_notify_telegram|janitor_run_complete|validate_gate_a_fail" agents/_shared/autosend-policy.yaml agents/recruitment/janitor/tools.yaml agents/recruitment/janitor/cleanup.sh agents/recruitment/janitor/agent.md' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/context.sh | sed -n '260,280p'; nl -ba agents/recruitment/janitor/tools.yaml | sed -n '218,226p'; nl -ba agents/recruitment/janitor/validate.sh | sed -n '45,65p;185,192p'; nl -ba agents/recruitment/janitor/agent.md | sed -n '216,226p;180,185p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
agents/recruitment/janitor/cleanup.sh:8:# `janitor_cleanup` (green tier — internal-only audit row recording
agents/recruitment/janitor/cleanup.sh:11:# Per agents/_shared/autosend-policy.yaml: `janitor_cleanup` is NOT yet
agents/recruitment/janitor/cleanup.sh:109:# Stays hh_decision_output until janitor_cleanup is registered in
agents/recruitment/janitor/cleanup.sh:111:hh_decision_output "janitor_cleanup" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/tools.yaml:22:# janitor_cleanup is QUEUED for registration at W6-7 build start (matches
agents/recruitment/janitor/tools.yaml:38:  - id: bullhorn_oauth
agents/recruitment/janitor/tools.yaml:41:    action_type: bullhorn_oauth          # green tier; QUEUED for registration (substrate-owner change to autosend-policy.yaml; agents/_shared/ frozen this slice)
agents/recruitment/janitor/tools.yaml:142:    action_type: operator_notify_telegram  # green tier; REGISTERED in autosend-policy.yaml
agents/recruitment/janitor/tools.yaml:151:  - id: janitor_cleanup
agents/recruitment/janitor/tools.yaml:153:    action_type: janitor_cleanup    # green tier; QUEUED for registration (substrate-owner change; cleanup.sh emits hh_decision_output until registered — CC/Scout precedent)
agents/recruitment/janitor/tools.yaml:208:#   operator_notify_telegram        green                  (shared)
agents/recruitment/janitor/tools.yaml:209:#   janitor_run_complete            green
agents/recruitment/janitor/tools.yaml:210:#   validate_gate_a_fail            green                  (shared)
agents/recruitment/janitor/tools.yaml:215:#   bullhorn_oauth                  green
agents/recruitment/janitor/tools.yaml:216:#   janitor_cleanup                 green
agents/recruitment/janitor/agent.md:162:   → on classifier fail after retries: hh_decision_action("validate_gate_a_fail",
agents/recruitment/janitor/agent.md:184:   → hh_decision_action("operator_notify_telegram", "tenant:<slug>",
agents/recruitment/janitor/agent.md:189:   → hh_decision_action("janitor_run_complete", "tenant:<slug>", payload_hash, payload_preview)
agents/_shared/autosend-policy.yaml:65:  operator_notify_telegram:
agents/_shared/autosend-policy.yaml:71:  janitor_run_complete:
agents/_shared/autosend-policy.yaml:119:  validate_gate_a_fail:

 succeeded in 0ms:
   260	hh_decision_trigger "session_start" \
   261	  "agent:janitor; tenant:${CTX_TENANT_SLUG}; corporation_id:${CTX_BULLHORN_CORPORATION_ID}; dedup_threshold:${CTX_JANITOR_DEDUP_THRESHOLD}; bullhorn_token:${CTX_BULLHORN_TOKEN_STATE}; voice_corpus:${CTX_VOICE_CORPUS_STATE}; recent_edits_30d:${CTX_RECENT_EDITS_COUNT}"
   262	
   263	# Operator-readable trace (NOT a decision_log row; just stdout for the bus log)
   264	printf '[janitor context.sh] tenant=%s corp=%s dedup_threshold=%s bullhorn_token=%s voice_corpus=%s tone_rules=%s recent_edits_30d=%s\n' \
   265	  "${CTX_TENANT_SLUG}" "${CTX_BULLHORN_CORPORATION_ID}" "${CTX_JANITOR_DEDUP_THRESHOLD}" \
   266	  "${CTX_BULLHORN_TOKEN_STATE}" "${CTX_VOICE_CORPUS_STATE}" "${CTX_TONE_RULES_COUNT}" \
   267	  "${CTX_RECENT_EDITS_COUNT}"
   268	
   269	exit 0
   218	# ──────────────────────────────────────────────────────────────────────────────
   219	# Boundary check (per master brief §3 + review-mcp-connector.md §8)
   220	# ──────────────────────────────────────────────────────────────────────────────
   221	#
   222	# - No Composio / AgentMail references anywhere in this file.
   223	# - All packages declared are @ifos/* — no third-party adapters with policy
   224	#   semantics smuggled in via tools.yaml.
   225	# - Action types all map to autosend-policy.yaml tiers (or are explicitly
   226	#   marked QUEUED above for W6-7 build-start registration).
    45	# Checks (per agent.md §5 Gate A + spec-001 §5):
    46	#   G1 — Bullhorn auth refresh succeeded in Step 1 (no stale-token writes).
    47	#         Hard-fails on token_state:failed; a degraded/absent state (creds
    48	#         founder-gated → no live write possible; cycle.sh defers transport)
    49	#         is a WARN — there is no stale-token risk when no token exists.
    50	#   G2 — Dedup proposal: confidence ≥ CTX_JANITOR_DEDUP_THRESHOLD (default 0.85;
    51	#         per ULTRAPLAN A2 line 510 + tenant override range [0.75, 0.95])
    52	#         → ESC_AGENT_OUTPUT_SHAPE
    53	#   G3 — Dedup proposal: NEITHER record has Bullhorn activity in last 90 days
    54	#         (per ULTRAPLAN A2 line 510 verbatim). Recent (or UNKNOWN) activity →
    55	#         REJECT the auto-write + ESC_DUPLICATE_DETECTED (SUCCESS-path Telegram
    56	#         approval gate per catalogue §2.5; NOT a Gate A failure code).
    57	#   G4 — Field-backfill: source_confidence ≥0.7 (CH 404 / LinkedIn empty / no
    58	#         derivation source → fail) → ESC_AGENT_OUTPUT_SHAPE
    59	#   G5 — Tacit-note narrative: voice classifier ≥0.75. Hard-when-scored;
    60	#         warn-when-unscored (empty voice_corpus → unscored/no_corpus per CC
    61	#         honesty precedent) → ESC_VOICE_DRIFT
    62	#   G6 — No PII outside firm boundary in tacit-note narratives (regex pass)
    63	#         → ESC_PII_LEAKAGE_RISK (BLOCKING; precedence over all other classes)
    64	#   G7 — Write batch size: this proposal's batch index ≤ 100/min defensive cap
    65	#         (per agent.md §5) → ESC_AGENT_OUTPUT_SHAPE (spec-001 §5 routing)
   185	if [[ "${_g1_state}" == "failed" ]]; then
   186	  _fail "G1: Bullhorn auth refresh FAILED this session — stale-token write blocked"
   187	  _set_esc "ESC_BULLHORN_AUTH"
   188	elif [[ "${_g1_state}" == "ok" || "${_g1_state}" == "fixture" ]]; then
   189	  _ok "G1: Bullhorn auth refresh fresh (token_state:${_g1_state})"
   190	else
   191	  _warn "G1: Bullhorn auth state '${_g1_state:-no_recent_row}' — no live token (creds founder-gated); write transport defers, no stale-token risk"
   192	fi
   180	11. Operator notification (Telegram)
   181	   → if Gate-B target met: green-tier notification with summary
   182	   → if Gate-B target missed: yellow-tier notification + 200-char executive
   183	     summary suggesting consultant follow-up
   184	   → hh_decision_action("operator_notify_telegram", "tenant:<slug>",
   185	     notification_hash, "gate_b_state:met|missed; chars:<N>")
   216	### Gate A — validate.sh (hard-fail before action)
   217	
   218	Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Janitor's `validate.sh` enforces:
   219	
   220	- Bullhorn auth refresh succeeded in Step 1 (no stale token writes)
   221	- Every AUTO-MERGE proposal has confidence ≥ 0.85 per ULTRAPLAN A2 line 510 (G2 — applies to auto-merge proposals ONLY; review-band pairs are held upstream at §4 Steps 3-4 and never reach Step 9, so this check is defence-in-depth against a band-classification bug, not the band mechanism itself)
   222	- No auto-merge proposal where EITHER record has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim; G3 — same defence-in-depth scope as G2)
   223	- No field-backfill where source confidence <0.7 (CH 404 / LinkedIn empty / no derivation source)
   224	- Tacit-note narratives pass voice classifier ≥ 0.75
   225	- Bullhorn write batch size ≤ 100 per minute (rate-limit defensive)
   226	- No PII outside firm boundary in tacit-note narratives (regex pass)

exec
/bin/zsh -lc "rg -n \"hh_decision_trigger \\\"session_start\\\"|Session start|context.sh hydrates|cycle.sh\" agents/recruitment/janitor/agent.md agents/recruitment/janitor/context.sh agents/recruitment/janitor/cycle.sh" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
agents/recruitment/janitor/context.sh:8:# Per ADR-003 v2 agent-bundle pattern: bus invokes context.sh BEFORE cycle.sh
agents/recruitment/janitor/context.sh:9:# at session start. context.sh hydrates session-scoped CTX_* env vars that
agents/recruitment/janitor/context.sh:10:# cycle.sh + validate.sh read, then emits the mandatory session_start trigger
agents/recruitment/janitor/context.sh:27:#     state is 'absent' and cycle.sh runs in degraded mode against the
agents/recruitment/janitor/context.sh:34:# Outputs (exported CTX_* vars; cycle.sh + validate.sh consume):
agents/recruitment/janitor/context.sh:147:# creds EMPTY today (founder-gated) → 'absent' → cycle.sh degraded mode
agents/recruitment/janitor/context.sh:149:# creds + token bundle → live refresh here; refresh failure → cycle.sh Step 1
agents/recruitment/janitor/context.sh:215:# drift/coverage signal; the full rows are read by cycle.sh Step 8 under RLS.
agents/recruitment/janitor/context.sh:260:hh_decision_trigger "session_start" \
agents/recruitment/janitor/agent.md:4:**Build state:** W6-7 build slice COMPLETE (spec-001; branch `worktree-agent-abb2ffb971bb471ba`, 2026-06-10) — all 6 sibling bundle files (`cycle.sh` 12 steps + `validate.sh` Gate A G1-G7 + `context.sh` + `cleanup.sh` + `tools.yaml` + `README.md`) + 3 fixtures LIVE/BUILT; build-gate GREEN; three deterministic DB-backed fixture suites green (`scripts/run-janitor-{dedup,gate-a,report}-test.sh`). Fixture-proven only: zero live Bullhorn calls have ever been made by this bundle (all six `BULLHORN_*` creds EMPTY per names-only re-verification 2026-06-10; live smoke founder-gated). Companies House is the one live-capable path (key SET; live-smoked once, read-only). Prior contract history: Day-20 W4 bilateral pass; R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority; R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4; R19 (2026-05-25): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Still awaits: Q1 LOI + Bullhorn Sub-decision B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + live Bullhorn credentials + Codex re-ratification of the built bundle + founder approvals per §10.
agents/recruitment/janitor/agent.md:5:**Reading-discipline note (updated 2026-06-10 at W6-7 build; originally added 2026-06-03 per Codex Fbis-R3 closure pattern + CC + Concierge precedent):** this `agent.md` is the **CONTRACT** that the W6-7 build slice implemented against. The 6 sibling bundle files + 3 fixtures are **LIVE** — the W6-7 build slice (spec-001, this branch; commits `184a2bf` + `4ceccbc` + `2938b20` + `30bdff8`) replaced every `TODO(W6-7)` marker with live implementation; the three DB-backed fixture suites are green under build-gate. **Per-component build state, honestly stated:** `@ifos/bullhorn` — implemented connector package + built `dist/cli.js` bridge (`packages/mcp-connectors/bullhorn`, v0.1.0; typecheck clean; vitest 52/52; generic `update-entity` for Candidate|ClientContact|JobOrder|Placement + extended `create-note` per the agreed CLI contract). Live credentials are the ONLY gap on that path: with creds EMPTY the agent runs DEGRADED — Step 2 scans the Postgres `entities` Bullhorn cache instead of the live API; all coverage is fixture-driven (`IFOS_JANITOR_FIXTURE_*`). `@ifos/companies-house` — live-capable (key SET); smoked once read-only via `bin/ch-lookup.mjs` (HAYS PLC → CRN 02150950, source_confidence 0.9). **Runtime-audit truth (W6-7 behaviour):** the three yellow-tier action rows the contract names (`bullhorn_candidate_dedupe` + `bullhorn_field_backfill` + `bullhorn_note_attach`) ARE emitted at runtime — cycle.sh Step 9 validates each proposal through validate.sh, then emits `hh_decision_action "${_jn_atype}"` (cycle.sh lines 703-704) with per-type tallies at lines 705-709 and the `bullhorn_write_batch` summary row at lines 711-712. Until creds land, each row carries `write_state:deferred` in its reason (the batch summary tallies them as `deferred_no_creds:<N>`); the Gate-A-validated decision is real and audited, the transport is honestly deferred, never faked — post-creds the same rows carry `write_state:applied`. `context.sh` uses the canonical RLS-scoped `SELECT config->>'<key>' FROM tenant_adapters` path (v0.4 supplement LIVE on VPS per commit `a1bbcf6`), with `IFOS_FORCE_*` env fallbacks retained for fixtures/local-dev only. **Voice honesty:** no embedding classifier ships at v1.0 — Step 8 emits `unscored/no_corpus` (or `classifier_unavailable` when a corpus is active) rather than a faked score; validate.sh G5 is hard-when-scored / warn-when-unscored. LinkedIn (§4 Step 7) is an explicit NO-OP audit row (`linkedin_enrichment_skipped`). §10 lifecycle status remains **Proposed** pending Codex re-ratification of the built bundle + founder approvals — the status flip is founder-gated.
agents/recruitment/janitor/agent.md:18:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any AUTO-MERGE proposal with confidence <0.85 (per ULTRAPLAN A2 line 510) — Gate A's merge-confidence check applies to auto-merge proposals ONLY; held and dropped pairs are classified upstream at §4 Steps 3-4 per the spec-001 band→action table (≥0.85 + no 90d activity → auto-merge; 0.70–0.85 OR ≥0.85-with-recency → held via ESC_DUPLICATE_DETECTED; <0.70 → silent drop) and never reach Gate A. Gate B success threshold: ≥15% dedup AND ≥10% field-completeness — two independent thresholds, both must pass. SHIPPED v1.0 metric (cycle.sh Step 10, header lines 716-724 + computation lines 755-762): deterministic in-run `decision_log`-derived ratios — `dedup_pct = 100·merges/(merges + review-band pairs)`, `completeness_pct = 100·backfills/(backfills + still-missing rows)`. Explicit limitation: this is NOT yet measured against the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511) — no day-0 baseline exists yet; baseline-relative measurement is the documented post-pilot enhancement (accepted build deviation 6; captured at pilot onboarding per §9 Q6). Auto-band Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks, no synchronous approval; review-band dedup merges (0.70–0.85 confidence, or ≥0.85 with Bullhorn activity in the last 90 days) are instead held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before write. Every write emits a per-write audit row to `decision_log` with `agent_name='janitor'`.
agents/recruitment/janitor/agent.md:84:0. Session start
agents/recruitment/janitor/agent.md:85:   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice corpus
agents/recruitment/janitor/agent.md:242:**Shipped v1.0 measurement (W6-7 build; accepted deviation 6):** the live cycle.sh computes the two thresholds as deterministic in-run `decision_log`-derived ratios, not against a day-0 baseline — `dedup_pct = 100·merges/(merges + review-band pairs)` and `completeness_pct = 100·backfills/(backfills + still-missing rows)` (cycle.sh Step 10: header comment lines 716-724, computation lines 755-762; definitions printed in report §6). **Limitation, explicit:** ULTRAPLAN's "before/after vs day-0 baseline" semantics are NOT implemented yet because no day-0 baseline exists pre-pilot — the baseline is captured at first pilot onboarding (per §9 Q6), and baseline-relative Gate B measurement is the documented post-pilot enhancement. The thresholds (≥15% / ≥10%), the AND-logic, and the 3-consecutive-both-missed → `ESC_GATE_B_MISS` trigger are unchanged.
agents/recruitment/janitor/agent.md:308:| `cycle.sh` orchestration (12-step) | This branch (commit `184a2bf`) | ✅ LIVE — all 12 steps; fixture-proven end-to-end against the local dev DB (full smoke under a throwaway tenant) |
agents/recruitment/janitor/cycle.sh:2:# Janitor agent — cycle.sh (12-step nightly cron orchestration; W6-7 LIVE)
agents/recruitment/janitor/cycle.sh:32:#       state without creds (context.sh consumes; cycle.sh re-reads CTX var)
agents/recruitment/janitor/cycle.sh:67:  printf 'janitor/cycle.sh: CTX_AGENT_DIR unset\n' >&2
agents/recruitment/janitor/cycle.sh:71:  printf 'janitor/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
agents/recruitment/janitor/cycle.sh:77:command -v jq >/dev/null 2>&1 || { printf 'cycle.sh: jq required\n' >&2; exit 2; }
agents/recruitment/janitor/cycle.sh:93:  printf 'cycle.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
agents/recruitment/janitor/cycle.sh:119:# mirrors cash-conductor/cycle.sh Step 1).
agents/recruitment/janitor/cycle.sh:156:  printf 'cycle.sh: --tenant %s does not match CTX_TENANT_SLUG %s — refusing mismatched invocation\n' \
agents/recruitment/janitor/cycle.sh:181:# Step 0 — Session start
agents/recruitment/janitor/cycle.sh:184:hh_decision_trigger "session_start" "janitor mode=${MODE}"
agents/recruitment/janitor/cycle.sh:220:    printf 'cycle.sh: Bullhorn auth refresh failed after 2 retries — blocking (ESC_BULLHORN_AUTH)\n' >&2
agents/recruitment/janitor/cycle.sh:240:  *)            printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
agents/recruitment/janitor/cycle.sh:893:  printf 'cycle.sh: Gate B BOTH thresholds missed 3 consecutive runs — ESC_GATE_B_MISS (exit 1)\n' >&2

exec
/bin/zsh -lc 'ls -la .codex/ratification 2>/dev/null || true; rg -n "Round 4 Phase 2|review-agent-bundle|Day 20" .codex docs agents/recruitment/janitor/agent.md 2>/dev/null' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
total 136
drwxr-xr-x@ 8 madsadmin  staff    256 Jun 10 13:35 .
drwxr-xr-x@ 3 madsadmin  staff     96 Jun 10 13:35 ..
-rw-r--r--@ 1 madsadmin  staff   7686 Jun 10 13:35 SKILL.md
-rw-r--r--@ 1 madsadmin  staff  11759 Jun 10 13:35 review-agent-bundle.md
-rw-r--r--@ 1 madsadmin  staff  11166 Jun 10 13:35 review-architecture-decision.md
-rw-r--r--@ 1 madsadmin  staff   8966 Jun 10 13:35 review-mcp-connector.md
-rw-r--r--@ 1 madsadmin  staff  11256 Jun 10 13:35 review-postgres-migration.md
-rw-r--r--@ 1 madsadmin  staff   9804 Jun 10 13:35 review-schema-change.md
agents/recruitment/janitor/agent.md:342:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/janitor/agent.md:345:- Codex Round 4 Phase 2 ratifies
agents/recruitment/janitor/agent.md:353:- Codex re-ratifies post-build via `review-agent-bundle.md` skill — in progress on this branch
.codex/ratification/review-agent-bundle.md:1:# Codex ratification skill — review-agent-bundle
.codex/ratification/review-agent-bundle.md:147:*End of review-agent-bundle skill.*
.codex/ratification/SKILL.md:100:- `review-agent-bundle.md` — for new agents under `agents/<vertical>/<name>/`
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:929:    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
docs/architecture/architecture-cohesion-review.md:188:  - **A:** Codex review skill `review-agent-bundle.md` (not yet built) would catch this. Currently relies on grep audit + author discipline. Recommend: add this check to `scripts/run-tenancy-audit.sh` (Phase 1 enhancement OR Codex skill).
docs/architecture/architecture-cohesion-review.md:190:**Verdict: BOUNDARY HOLDS at current artefact set.** Future agents need automated guardrail; queue as Phase-1 extension OR `review-agent-bundle.md` skill at Diagnostic W3.
docs/architecture/architecture-cohesion-review.md:215:  - **A:** R2 commitment (ADR-003 Decision 1): tools.yaml can opt-in to cortextOS skills via `cortextos_skills:` block. If an agent opts in to `knowledge-base`, it gets the upstream KB. **This is the seam.** Currently no agent opts in. Recommend: add `review-agent-bundle.md` skill check to flag any `knowledge-base` opt-in for explicit founder review.
docs/architecture/architecture-cohesion-review.md:234:| R8 | Adapter + brain-replacement boundary automation | Medium | `review-agent-bundle.md` Codex skill at Diagnostic W3 | Claude Code | Diagnostic W3 |
docs/build-brief/00-MASTER-BRIEF.md:723:| `review-agent-bundle.md` | Specific checklist for the 6 files + 3 fixtures of a new agent |
docs/operations/goal-overnight-2026-05-31.md:18:4. `.codex/ratification/review-agent-bundle.md` (skill structure template)
docs/operations/goal-overnight-2026-05-31.md:28:Author modeled on `review-agent-bundle.md`. 7 checks layered on top of `SKILL.md`:
docs/operations/goal-week-4-track-1.md:65:13. **`.codex/ratification/review-mcp-connector.md`** exists. Type-specific skill for MCP connector packages. Adds checks on top of SKILL.md: OAuth refresh idempotency; rate-limit budget declared; explicit retry policy; secrets never logged; fixture-first tests; integration with `_shared/hook-helpers.sh` for decision_log emissions. Modeled on `review-agent-bundle.md` length + structure.
docs/operations/goal-week-4-track-1.md:161:Create `.codex/ratification/review-mcp-connector.md` modeled on `review-agent-bundle.md`. The skill ADDS these checks on top of `SKILL.md`:
docs/operations/goal-week-3-polish-and-scaffold.md:39:## §1 — Success state (what "done" looks like at end of Day 20)
docs/operations/goal-week-3-polish-and-scaffold.md:70:### Codex ratification (Day 20)
docs/operations/goal-week-3-polish-and-scaffold.md:76:### State + audit (Day 20)
docs/operations/goal-week-3-polish-and-scaffold.md:113:| Building any new Codex ratification skill (e.g., `review-agent-bundle.md`) | Defer per execution-plan §3 lazy; agent.md ratification uses existing `review-architecture-decision.md` skill |
docs/operations/goal-week-3-polish-and-scaffold.md:314:- **§10 Ratification:** via `review-architecture-decision.md` Codex skill; ratifies as part of Round 4 if scaffolded by Day 20.
docs/operations/goal-week-3-polish-and-scaffold.md:582:- `review-agent-bundle.md` — NOT YET BUILT (per execution-plan §3 lazy); defer; use review-architecture-decision.md for each agent.md individually
docs/operations/goal-week-3-polish-and-scaffold.md:702:**Day 20 is the soft target. Day 22 is the hard cutoff** (Trigger 2 fires Day 21 if Diagnostic not ratified). If Day 22 hits without completion, escalate to founder review + scope-cut decision.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:77:**Codex says:** "The file has `Status: Proposed` at line 3, but no `Context`, `Decision`, or `Consequences` sections as required for Proposed artefacts by review-architecture-decision §1. Fix: either review this with `review-agent-bundle.md`, or add the required architecture-decision sections and a final status-update line."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:81:**Recommendation:** **Build `review-agent-bundle.md` Codex skill** (deferred per execution-plan §3 lazy; now needed). The Round-4 manifest used `review-architecture-decision.md` as a temporary skill because `review-agent-bundle.md` doesn't exist yet. The correct ratification path for agent.md files is the agent-bundle skill, not architecture-decision.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:83:**This is the load-bearing finding** — it surfaces that **the lazy-skill deferral is now blocking proper agent.md ratification.** Building `review-agent-bundle.md` is a Week-3-extension or W4 priority.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:92:4. **Authorise Week-3-extension OR W4-priority work** to build `review-agent-bundle.md` Codex skill (Issue 5)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:102:- Phase 2 full (5 new scaffolds): **deferred** pending Issue-5 resolution (review-agent-bundle.md skill build)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:106:Recommended next step (post-arbitration): Week-3-extension or W4-prio-1 build of `review-agent-bundle.md` skill; then re-run Codex Round 4 against all 6 v1.0 agent.md files with the proper skill.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:112:After building `.codex/ratification/review-agent-bundle.md` (commit `825ebd4`) — the correct skill for agent.md ratification — all 6 agent.md files were re-ratified.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:198:| Round 4 v2 | review-agent-bundle (correct) | 6 | 10 (6 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:199:| Round 5 (remediation of R4-v2) | review-agent-bundle | 5 | 15 (5 new; none from R4-v2) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:200:| Round 6 (remediation of R5) | review-agent-bundle | 4 | 19 (4 new; none from R5) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:268:Ran all 6 against `review-agent-bundle.md`. **All 6 returned REJECTED**, with the following actual top-level finding counts (the script's regex inflates because of nested sub-bullets):
docs/operations/decision-log.md:285:- Today: 2026-05-25 (Day 20); **20 days runway**
docs/operations/decision-log.md:349:- [ ] **R8**: Adapter + brain-replacement boundary automation — `review-agent-bundle.md` Codex skill at Diagnostic W3
docs/operations/decision-log.md:416:- `825ebd4` review-agent-bundle.md skill built (closes Issue 5; unblocks Phase 2)
docs/operations/decision-log.md:493:- **Step 13** ⏸ — Codex Round 4 Phase 2 (full): founder runs `bash scripts/run-codex-ratification.sh --round 4 --full`
docs/operations/decision-log.md:500:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: Proposed; ready for Codex Round 4 Phase 2
docs/operations/decision-log.md:534:4. **Step 13 (~2 hours):** Run Codex Round 4 Phase 2 (full ratification of 5 new scaffolds)
docs/operations/decision-log.md:661:- Codex bundle ratification via `review-agent-bundle.md` (skill not yet built; lazy per execution plan)
docs/operations/decision-log.md:667:**Codex Day-7 ratification queue:** grows by 1 (agent.md draft); ratifies individually via `review-architecture-decision.md` skill OR as part of full bundle via `review-agent-bundle.md` at W3 build close.
docs/operations/codex-ratification-guide.md:122:Three more skills (`review-agent-bundle.md`, `review-mcp-connector.md`, `review-harness-bump.md`) are deferred per the execution plan §3 — they're lazy, built at first need.
docs/operations/w4-bilateral-pass-6-agent-md.md:3:**Date:** 2026-05-25 (Day 20)
docs/operations/codex-ratification-execution-plan.md:72:| `review-agent-bundle.md` | The 6-file + 3-fixture pattern | ~250 | Pre-Diagnostic-W3 (not yet needed) |
docs/operations/codex-ratification-execution-plan.md:429:- **Codex review of `agents/_shared/` runtime code via agent-bundle skill** — the 8-file `_shared/` set is reviewed under `review-architecture-decision.md` because it's not an agent bundle, it's the helper layer. Future agents (Diagnostic W3+) will be reviewed under `review-agent-bundle.md` once that skill exists.
docs/operations/w4-day-20-founder-runbook.md:3:**Date:** 2026-05-25 (Day 20)
docs/operations/parallel-agent-build-method.md:64:2. **Review-subagent** — uses the existing `.codex/ratification/review-agent-bundle.md`
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:3:**Date:** 2026-05-25 (Day 20)
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:88:- **A new fact contradicting these disagreements emerges** — e.g. Codex skill `review-agent-bundle.md` gets hardened to be less interpretive on what counts as "drift" vs "scaffold-acceptable divergence"; or the master brief explicitly defines a `Proposed-with-bundle-drift` state separate from `Proposed`.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:97:- Consider hardening `review-agent-bundle.md` skill to explicitly accept "agent.md describes target W-X build-slice behavior; SKELETON files exist with TODO(W-X) markers" as a non-rejection state. The skill currently treats agent.md ↔ code drift as a structural issue when in reality scaffolding inherently has this property.
docs/decisions/2026-05-18-codex-ratification-manifest.md:111:Round 4 scheduled across Week 3 (Days 14-20) per `docs/operations/goal-week-3-polish-and-scaffold.md` Steps 7 (Diagnostic-only, Day 15) + 13 (full run, Day 20). Per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 remediation max).
docs/decisions/2026-05-18-codex-ratification-manifest.md:126:**Phase 2 (Day 20) — Full Round 4: 5 new agent.md scaffolds.** Each authored Days 16-19 per goal-week-3 Steps 8-12. All `review-architecture-decision.md` skill.
docs/decisions/2026-05-18-codex-ratification-manifest.md:138:**Day-19 update:** Initial Round-4 Phase-1 attempt used `review-architecture-decision.md` skill (the only available skill at the time). That returned REJECTED with a load-bearing finding (Issue 5 in `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`) — agent.md files require a different skill structure. **`review-agent-bundle.md` skill built in commit `825ebd4`.** Re-ratification of all 6 agent.md items with the new skill.
docs/decisions/2026-05-18-codex-ratification-manifest.md:226:| `review-agent-bundle.md` | Specific checklist for the 6 files + 3 fixtures of a new agent |

exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/agent.md | sed -n '340,355p'; nl -ba agents/recruitment/janitor/cycle.sh | sed -n '803,837p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-abb2ffb971bb471ba
 succeeded in 0ms:
   340	## §10 — When this document ratifies
   341	
   342	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   343	
   344	Status flips Proposed → Accepted (pre-build) when:
   345	- Codex Round 4 Phase 2 ratifies
   346	- Founder approves §9 open questions Q1 + Q2 + Q4 + Q5 + Q6
   347	- Q3 resolves via Bullhorn Sub-decision B answer
   348	
   349	Status flips Accepted → In Force when:
   350	- ~~W5 build slice produces all 5 sibling bundle files + 3 fixtures~~ **SATISFIED 2026-06-10** — the W6-7 build slice (spec-001, this branch) shipped all 6 sibling bundle files + 3 fixtures LIVE; build-gate GREEN
   351	- First production run against migration-test tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row) — pending; blocked on live Bullhorn credentials (founder-gated)
   352	- Day-30 baseline measured for first pilot tenant — pending; post-LOI
   353	- Codex re-ratifies post-build via `review-agent-bundle.md` skill — in progress on this branch
   354	
   355	Current position (2026-06-10): the contract below is IMPLEMENTED — the bundle is built and fixture-proven, not production-proven (zero live Bullhorn calls). The §10 status field stays **Proposed** until the founder flips it; the flip is founder-gated, not Claude's call.
   803	# ────────────────────────────────────────────────────────────────────────
   804	# Step 11 — Operator notification (Telegram)
   805	# Reference: agent.md §4 Step 11; green action row if Gate B met, missed-state
   806	# + ≤200-char executive summary in the payload when missed (the registered
   807	# operator_notify_telegram action_type is green tier in autosend-policy.yaml;
   808	# urgency is conveyed in payload.gate_b_state — tier is policy-owned).
   809	# Transport: live Telegram sendMessage when TELEGRAM_BOT_TOKEN + chat id are
   810	# configured; stdout degrade otherwise (Scout precedent; token EMPTY today).
   811	# ────────────────────────────────────────────────────────────────────────
   812	
   813	if _step_planned 11; then
   814	  if [[ "${JN_GATE_B_MET}" == "true" ]]; then
   815	    _jn_gb_state="met"
   816	    _jn_msg="Janitor nightly (${CTX_TENANT_SLUG}): Gate B MET. Merges:${JN_MERGES} backfills:${JN_BACKFILLS} notes:${JN_NOTES} deferred:${JN_DEFERRED}."
   817	  else
   818	    _jn_gb_state="missed"
   819	    # awk (not `grep -c || echo 0`): zero matches → grep prints "0" AND exits 1,
   820	    # so the || arm doubled the 0 with a newline inside the message.
   821	    _jn_msg="Janitor nightly (${CTX_TENANT_SLUG}): Gate B MISSED. Merges:${JN_MERGES} backfills:${JN_BACKFILLS} review-held:$(awk '/Review-band/{n++} END{print n+0}' "${_JN_EXCEPTIONS}" 2>/dev/null || echo 0). Consultant follow-up suggested on held pairs + remaining missing fields."
   822	  fi
   823	  _jn_msg="${_jn_msg:0:200}"
   824	  _jn_channel="stdout_degraded"
   825	  if [[ -n "${TELEGRAM_BOT_TOKEN:-}" && "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" != "unset" ]] && command -v curl >/dev/null 2>&1; then
   826	    if curl -sS --max-time 15 "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
   827	         -d "chat_id=${CTX_OPERATOR_TELEGRAM_CHAT_ID}" --data-urlencode "text=${_jn_msg}" \
   828	         >/dev/null 2>&1; then
   829	      _jn_channel="telegram"
   830	    fi
   831	  fi
   832	  [[ "${_jn_channel}" == "stdout_degraded" ]] && printf '[janitor notify] %s\n' "${_jn_msg}"
   833	  _jn_nhash="$(printf '%s' "${_jn_msg}" | shasum -a 256 2>/dev/null | cut -c1-16)"
   834	  [[ -z "${_jn_nhash}" ]] && _jn_nhash="notify-${MODE}"
   835	  hh_decision_action "operator_notify_telegram" "tenant:${CTX_TENANT_SLUG}" "${_jn_nhash}" \
   836	    "gate_b_state:${_jn_gb_state}; chars:${#_jn_msg}; channel:${_jn_channel}" || true
   837	fi

codex
The decisive failures are concrete enough now: one forbidden adapter-name reference in a sibling bundle file, and two places where `agent.md` no longer matches the implemented/policy-owned behavior. I’m going to return the ratification verdict in the required format.
codex
REJECTED

1. Forbidden adapter names appear in a prohibited bundle location. `agents/recruitment/janitor/tools.yaml` line 222 says `"No Composio / AgentMail references anywhere in this file"`; the agent-bundle boundary says Composio and AgentMail must never be referenced in `tools.yaml`, even as a negative assertion. Remove the names from `tools.yaml` and replace with a generic boundary note like "No forbidden third-party adapter references".

2. Gate A auth semantics in `agent.md` do not match `validate.sh`. `agent.md` lines 216-220 frame Gate A as a hard-fail gate and say `validate.sh` enforces "Bullhorn auth refresh succeeded"; `validate.sh` lines 45-49 and 185-192 only hard-fail `token_state:failed` and warn/proceed for degraded or absent creds. Either update `agent.md` §5 to state the actual G1 rule, or make `validate.sh` hard-fail absent/degraded auth.

3. Step 11 claims a yellow-tier missed-Gate-B notification that is not registered or implemented. `agent.md` lines 180-184 say Gate-B misses send a yellow-tier Telegram notification, but `autosend-policy.yaml` lines 65-69 registers `operator_notify_telegram` as green, `tools.yaml` line 142 says green, and `cycle.sh` lines 805-808 explicitly says missed-state remains green with urgency in payload. Align `agent.md` §4 Step 11 to green-tier `operator_notify_telegram`, or register and implement a separate yellow action type.
tokens used
102,696
REJECTED

1. Forbidden adapter names appear in a prohibited bundle location. `agents/recruitment/janitor/tools.yaml` line 222 says `"No Composio / AgentMail references anywhere in this file"`; the agent-bundle boundary says Composio and AgentMail must never be referenced in `tools.yaml`, even as a negative assertion. Remove the names from `tools.yaml` and replace with a generic boundary note like "No forbidden third-party adapter references".

2. Gate A auth semantics in `agent.md` do not match `validate.sh`. `agent.md` lines 216-220 frame Gate A as a hard-fail gate and say `validate.sh` enforces "Bullhorn auth refresh succeeded"; `validate.sh` lines 45-49 and 185-192 only hard-fail `token_state:failed` and warn/proceed for degraded or absent creds. Either update `agent.md` §5 to state the actual G1 rule, or make `validate.sh` hard-fail absent/degraded auth.

3. Step 11 claims a yellow-tier missed-Gate-B notification that is not registered or implemented. `agent.md` lines 180-184 say Gate-B misses send a yellow-tier Telegram notification, but `autosend-policy.yaml` lines 65-69 registers `operator_notify_telegram` as green, `tools.yaml` line 142 says green, and `cycle.sh` lines 805-808 explicitly says missed-state remains green with urgency in payload. Align `agent.md` §4 Step 11 to green-tier `operator_notify_telegram`, or register and implement a separate yellow action type.
