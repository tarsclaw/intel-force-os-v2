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
session id: 019e5ded-850a-7b93-8690-6b76850bb676
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

**Status:** Proposed.
**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority. R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4. R19 fixes (today): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice.
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
**Build complexity:** L (2 weeks) per ULTRAPLAN A2 line 512.
**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.1.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`.

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
| 2 | **Dedup pairs** | List of duplicate candidate pairs identified this run (confidence ≥0.85 only); for each pair: candidate `bullhorn_id` per vertical-schema.yaml candidate entity, match dimensions (name + email + phone + LinkedIn), confidence score, action taken (merged vs flagged-for-review) |
| 3 | **Field-completeness deltas** | Per entity-type table: which fields were filled in (e.g., candidate.location, contractor.day_rate); source of the backfill (Companies House lookup, LinkedIn enrichment, derivation from related entities) |
| 4 | **Tacit-note coverage** | Notes harvested from `recent_edit` table rows with `resolution='approved_after_edit'` (per v0.2-supplement.yaml recent_edit definition; v0.3 supplement §2a grants Janitor R access); attached to relevant Bullhorn entities; coverage rate over the 30-day window |
| 5 | **Agent vs. consultant attribution** | Rows attributed to Janitor automated work vs consultant manual entry; supports the day-30 before/after narrative |
| 6 | **Gate-B metric** | TWO independent thresholds per ULTRAPLAN A2 line 511 verbatim: dedup improvement ≥15% AND field-completeness improvement ≥10%. Both must pass. NOT a composite score — that would let one threshold cover for the other. |
| 7 | **Exception list** | Failed writes (Bullhorn 4xx/5xx, FK violations); rate-limit hits; dedup proposals flagged for review (confidence between 0.7-0.85); operator action items |
| 8 | **Executive summary** | 200-word narrative suitable for forwarding to the tenant's hiring leader; cites top-3 cleanup wins; quantifies time saved (hours of consultant data-entry work avoided) |

### Output 2 — Bullhorn writes (yellow tier)

Three write categories. Action types map to `agents/_shared/autosend-policy.yaml` — existing entries are used as-is; new entries are flagged for catalogue addition at W5 build (per `review-agent-bundle.md` §1 row §6 flag-for-addition pattern):

1. **Candidate merge** (`PUT /Candidate/{primary_id}` + cascade) — only when confidence ≥0.85 per Gate A; no merge if either candidate had Bullhorn activity in last 90 days without explicit review flag (per ULTRAPLAN A2 line 510 verbatim). Action type: **`bullhorn_candidate_dedupe`** (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW action_types; yellow tier; sample_rate: 10).
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
   → fuzzy-match across (name, email, phone, linkedin_url) tuples
   → compute confidence per pair: name × 0.3 + email × 0.4 + phone × 0.2 + linkedin × 0.1
   → discard pairs <0.85 confidence (per Gate A)
   → discard pairs where EITHER candidate has Bullhorn activity in last 90d
     (per ULTRAPLAN A2 line 510 verbatim)
   → batch into proposed-merge list (in-memory intermediate; not persisted —
     hh_decision_action emitted at Step 9 when each merge actually writes)

4. Dedup pass — contractor entity type
   → same algorithm as candidates; separate entity_type per Q1 Day-6 resolution
     (vertical-schema.yaml §1)

5. Field completeness audit (canonical field names per vertical-schema.yaml)
   → for each entity, check critical fields: candidate.location (line 124),
     client.industry (line 238), client.size_employees (line 243),
     contractor.day_rate_min/day_rate_max (lines 193-197),
     brief.salary_min/salary_max (lines 371-376)
   → identify missing-field rows
   → batch enrichment calls
   → hh_decision_output("field_completeness_audit", tenant, "<N> missing-field rows")

6. Companies House enrichment (clients only)
   → companies_house.search(client.name per vertical-schema.yaml line 235) → CRN →
     profile → fill canonical schema fields client.industry (line 238),
     client.companies_house_number (line 252)
   → 7-day cache per tools.yaml; rate-limit budget shared with Diagnostic
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

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Janitor's `validate.sh` enforces:

- Bullhorn auth refresh succeeded in Step 1 (no stale token writes)
- Every proposed merge has confidence ≥ 0.85 per ULTRAPLAN A2 line 510
- No merge proposal where EITHER candidate has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim)
- No field-backfill where source confidence <0.7 (CH 404 / LinkedIn empty / no derivation source)
- Tacit-note narratives pass voice classifier ≥ 0.75
- Bullhorn write batch size ≤ 100 per minute (rate-limit defensive)
- No PII outside firm boundary in tacit-note narratives (regex pass)

Gate A failure routing by class (per catalogue §2.5):
- PII detected outside firm boundary → `ESC_PII_LEAKAGE_RISK` (blocking; operator + ifos_oncall per catalogue routing)
- Tacit-note voice classifier <0.75 → `ESC_VOICE_DRIFT` (warn; operator_chat_id)
- Tone-rule violations → `ESC_TONE_RULE_VIOLATION` (warn; operator_chat_id per catalogue §2.10)
- Output-shape failures (section count, write-batch size, dedup confidence below threshold for action) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)

`ESC_DUPLICATE_DETECTED` (catalogue §2.5) is NOT a Gate A failure code — per catalogue trigger it's for dedup confidence ≥0.85 review-required cases (SUCCESS path; Telegram approval gate). Sub-0.85 confidence pairs silently drop in Step 3 algorithm; no ESC fire. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (catalogue line 163) is NOT used by Janitor — reserved for vertical-schema field-constraint violations at write-time.

### Gate B — Outcome threshold (success metric, not block)

Per ULTRAPLAN A2 line 511 verbatim: **"day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement"**.

Two independent thresholds (both must pass): dedup improvement ≥15% AND field-completeness improvement ≥10%. NOT a composite — composite would let one cover the other.

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
| `ESC_DUPLICATE_DETECTED` | Per catalogue §2.5 trigger: dedup confidence ≥0.85 review-required cases (SUCCESS path; Telegram approval gate fires). NOT a Gate A failure code. | warn | operator_chat_id (via Telegram approval gate per catalogue routing) |
| `ESC_GATE_B_MISS` | Per catalogue trigger: per-agent local Gate B metric threshold missed. For Janitor: BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND field-completeness-improvement <10%) per catalogue `ESC_GATE_B_MISS` Janitor example. Single-threshold misses do NOT fire (per §5 Gate B). Catalogue routing: operator_chat_id | warn | operator_chat_id |
| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |

Janitor does NOT use:

- `ESC_VOICE_DRIFT_TENANT` — fired by nightly voice-drift cron (per `escalation-codes.md` line 170-175 trigger: ≥N `ESC_VOICE_DRIFT` rows from same tenant in rolling 7d window). Janitor only fires the per-run `ESC_VOICE_DRIFT`; aggregate `_TENANT` rollup is handled by the canary not Janitor.
- `ESC_AUTOSEND_BLOCKED` — that's for red-tier blocks (`escalation-codes.md` line 41); Janitor writes are yellow tier only
- `ESC_BULLHORN_OAUTH_REVOKED` — escalated handling; Concierge owns the cross-agent escalation
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

## §8 — Build dependencies (W5 prerequisites)

Janitor build cannot start until ALL of the following are confirmed:

| Dependency | Source | Status |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ Week 3 in progress |
| First pilot tenant onboarded (provision-tenant.sh) | Post Q1-LOI | ⏸ Founder action; Trigger 1 fires 2026-06-03 if no LOI |
| **Bullhorn Sub-decision A Accepted** | Bullhorn partnerships response | ⏸ Form submitted 2026-05-24; 2-5 business days |
| **Bullhorn Sub-decision B Accepted** | Bullhorn developer support routing | ⏸ Same |
| Bullhorn MCP connector built | W3-W4 conditional (per ADR-005 sequencing) | ⏸ Not started |
| Bullhorn client_id + client_secret obtained | Tenant pilot OAuth ticket (or marketplace credentials if A=marketplace) | ⏸ Post-A+B Accept |
| Companies House MCP connector | Day-13 shipped (`@ifos/companies-house`) | ✅ |
| Tenant `target_patch.json` + `_secrets.env` provisioned | provision-tenant.sh ran for first pilot | ⏸ Post-LOI |
| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ Post-LOI |
| `validate.sh` Gate A logic | Build at W5 start (~0.5 day) | ⏸ |
| `context.sh` hydration | Build at W5 start (~0.5 day) | ⏸ |
| `cycle.sh` orchestration (12-step) | Build at W5 start (~2 days) | ⏸ |
| Dedup heuristic + confidence scorer | Build at W5 start (~3 days) | ⏸ |
| 3 fixtures with golden outputs | Build at W5 start (~1 day) | ⏸ |

**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.

---

## §9 — Status + open questions

**Status:** Proposed. Awaits Bullhorn A+B Accepted + Q1 LOI + W5 build slice start.

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

1. **Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0.** Estimate 1 week for the MCP server, 1 week for the agent itself (per ULTRAPLAN A2 line 513).
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
- W5 build slice produces all 5 sibling bundle files + 3 fixtures
- First production run against migration-test tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
- Day-30 baseline measured for first pilot tenant
- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)

Until then: this document is a forward-looking scaffold. Conservative pre-build clarity — not a binding contract until ratification.

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
I’ll verify the Janitor citations and catalogue/schema claims against the repo sources before giving the verdict.
exec
/bin/zsh -lc "nl -ba docs/ULTRAPLAN.md | sed -n '495,515p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/MASTER-BRIEF.md | sed -n '580,605p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
nl: docs/ULTRAPLAN.md: No such file or directory

 succeeded in 0ms:
nl: docs/MASTER-BRIEF.md: No such file or directory

exec
/bin/zsh -lc 'rg -n "A2|Janitor|janitor|Trigger 3|Trigger 8|bullhorn_candidate_dedupe|bullhorn_field_backfill|bullhorn_note_attach|ESC_GATE_B_MISS|ESC_DUPLICATE_DETECTED|ESC_AGENT_OUTPUT_SHAPE|ESC_AUTOSEND_SAMPLED_SPOT_CHECK|hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|candidate:|contractor:|day_rate|companies_house_number|janitor_dedup_threshold|janitor_last_run" docs agents migrations -S' in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: migrations: No such file or directory (os error 2)
agents/_shared/autosend-policy.yaml:37:    agent: janitor
agents/_shared/autosend-policy.yaml:71:  janitor_run_complete:
agents/_shared/autosend-policy.yaml:73:    agent: janitor
agents/_shared/autosend-policy.yaml:122:    reason: "Internal audit row written by validate.sh when Gate A enforcement fails. Carries the specific ESC code (e.g. ESC_AGENT_OUTPUT_SHAPE | ESC_PII_LEAKAGE_RISK) in the payload; the action itself is just the audit-row write, not an external send. Each agent's validate.sh emits this row before exit 1."
agents/_shared/autosend-policy.yaml:134:    reason: "Internal audit row written by cycle.sh when @ifos/diagnostic-generator produces empty stdout. Carries ESC_AGENT_OUTPUT_SHAPE payload."
agents/_shared/autosend-policy.yaml:153:  bullhorn_candidate_dedupe:
agents/_shared/autosend-policy.yaml:155:    agent: janitor
agents/_shared/autosend-policy.yaml:160:  bullhorn_field_backfill:
agents/_shared/autosend-policy.yaml:162:    agent: janitor
agents/_shared/autosend-policy.yaml:167:  bullhorn_note_attach:
agents/_shared/autosend-policy.yaml:169:    agent: janitor
agents/_shared/autosend-policy.yaml:235:  gmail_outlook_send_to_candidate:
agents/_shared/autosend-policy.yaml:293:    agent: janitor
agents/_shared/escalation-codes.md:127:#### `ESC_DUPLICATE_DETECTED`
agents/_shared/escalation-codes.md:128:- **Severity:** warn — Janitor dedup needs human approval
agents/_shared/escalation-codes.md:129:- **Trigger:** Dedup confidence `≥ 0.85` per Ultraplan §8.1 line 511 A2 Gate A; human-review-required cases
agents/_shared/escalation-codes.md:184:#### `ESC_AGENT_OUTPUT_SHAPE`
agents/_shared/escalation-codes.md:366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:377:#### `ESC_GATE_B_MISS`
agents/_shared/escalation-codes.md:379:- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
agents/_shared/escalation-codes.md:395:- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
agents/_shared/escalation-codes.md:451:  - **Janitor:** placement record has ambiguous lifecycle markers (e.g. start_date present but no end_date AND no `active` flag AND no recent activity); Janitor cannot safely tag or update
agents/_shared/escalation-codes.md:455:- **Payload fields:** `agent_name`, `entity_type` (`placement` | `candidate_lifecycle_event`), `entity_id`, `ambiguity_class` (Janitor: e.g. `missing_end_date`, `stale_activity`; Concierge: e.g. `unknown_transition`, `out_of_taxonomy`), plus class-specific fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:12:# (v0.3-supplement-0.1 amendment Day-20: original 3 v0.3 keys + 2 Janitor keys
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:13:# added closing Janitor R11 Finding 4 + blocked_recipients added closing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:57:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:61:        enum: [perm, contract, contract_inside_ir35, contract_outside_ir35, day_rate, hybrid]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:93:          Scout from match; Janitor uses for dedup (stronger match signal
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:96:        source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:99:          - Janitor: R   # W only via dedup-merge action
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:179:          confirming candidate started. Janitor flags ambiguous via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:181:        source: IFOS-derived (Scribe + Janitor)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:184:          - Janitor: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:275:#   - Janitor contact: R → R+W (dedup + field-backfill on contacts; same
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:277:#   - Janitor opportunity: none → R (reads opportunity context for cleanup)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:278:#   - Janitor placement: R → R+W (lifecycle-state cleanup writes —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:280:#   - Janitor timesheet: none → R (reads for placement-state inference)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:294:#   - Sourcing Scout candidate: R → R+W (writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:296:#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:298:#   - Concierge candidate: R → R+W (writes lifecycle-state-derived fields +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:300:#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:306:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:308:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:346:  #   Example: Scribe.candidate: R+W at entity level; per-field
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:348:  #   without reading it). Another example: Diagnostic.candidate: R at entity
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:367:    candidate: R           # reads for outreach context (§11 decision-maker map)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:368:    contractor: none       # not in scope at v1.0
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:376:  janitor:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:377:    candidate: R+W         # dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:378:    contractor: R+W        # dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:393:    candidate: R+W         # call-summary field extraction (Bullhorn endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:394:    contractor: R+W        # call-summary field extraction (Bullhorn endpoint A3 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:406:    # (populated by Janitor + Scribe + Concierge from their Bullhorn
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:408:    candidate: none        # no Bullhorn dependency
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:409:    contractor: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:420:    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:424:    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:425:    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:438:    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14 (Bullhorn endpoint A6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:439:    contractor: R+W        # writes lifecycle states for contractor placements too (Bullhorn endpoint A6 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:462:    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:465:      - Janitor (R+W)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:475:    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:478:      - Janitor (R+W)      # v0.3 UPGRADED — dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:484:      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:      preferred_channel + next_action_target_date; Janitor also dedup-merges).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:491:      - Janitor (R)        # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:501:    v0_1_v1_0_agent_access: [Janitor (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:504:      - Janitor (R)        # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:510:      v0.1 opportunity is sparsely accessed (Janitor only); v0.3 broadens
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:516:    v0_1_v1_0_agent_access: [Janitor (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:518:      - Janitor (R+W)      # v0.3 UPGRADED — lifecycle-state cleanup writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:523:      v0.3 upgrades Janitor + Concierge to R+W (lifecycle-state writes per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:529:      - Janitor (R)        # v0.3 NEW — reads for placement-state inference
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:534:      v0.1 timesheet is Cash Conductor only. v0.3 grants R to Janitor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:538:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:539:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:542:      - Janitor (R+W)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:551:  contractor:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:552:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:554:      - Janitor (R+W)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:566:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:569:      §12 conversation opener; Janitor for tacit-note narratives; Cash
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:576:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:578:      Janitor agent.md §7 calls hh_load_tone_rules filtered by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:579:      applies_to_agents containing 'janitor' for tacit-note narrative
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:580:      voice-classification. Per Round-8 Cat-β finding for Janitor.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:590:      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:597:      for retraining queue). Janitor adds R for tacit-note harvest per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:692:    janitor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:701:    janitor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:710:    janitor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:718:    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:721:    janitor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:728:    janitor: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:735:    janitor: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:795:  janitor_dedup_threshold:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:801:    read_by: [janitor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:804:      0.85 per ULTRAPLAN A2 line 510. Tenant-admin override range [0.75, 0.95]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:808:      added Day-20 W4 bilateral pass closing Janitor R11 Codex Finding 4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:816:    set_by: [tenant-admin, janitor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:817:    read_by: [concierge, sourcing-scout, cash-conductor, janitor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:829:  janitor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:832:    set_by: janitor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:833:    read_by: [janitor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:835:      Janitor nightly cron updates at session-close (Step 12). Next run queries
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:839:      (Day-20) closing Janitor R11 Codex Finding 4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:914:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:939:        contract_inside_ir35, contract_outside_ir35, day_rate, hybrid.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:962:      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1005:  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1008:  new + 2 Janitor + 1 blocked_recipients pre-v0.3 canonicalised). The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1027:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:296:  contractor:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
agents/_shared/README.md:161:Production rollout (other tenants) waits for Codex ratification of v0.2 + Diagnostic + Janitor verification of the schema against real Bullhorn data (master brief §6 Day 6 Q3 trigger from v0.1).
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:53:      - Janitor (R+W — sweep + normalisation + dedup-merge proposals per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:150:      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
docs/verticals/recruitment/vertical-schema.yaml:153:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:170:        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
docs/verticals/recruitment/vertical-schema.yaml:193:      day_rate_min:
docs/verticals/recruitment/vertical-schema.yaml:197:      day_rate_max:
docs/verticals/recruitment/vertical-schema.yaml:226:      - Janitor (R+W — orphan-link sweep + normalisation per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:252:      companies_house_number:
docs/verticals/recruitment/vertical-schema.yaml:261:        source: IFOS-derived (Janitor maintains)
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:347:      - Janitor (R — status drift sweep per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:380:      day_rate_min:
docs/verticals/recruitment/vertical-schema.yaml:384:      day_rate_max:
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:434:      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
docs/verticals/recruitment/vertical-schema.yaml:561:      approved_by_contractor:
docs/verticals/recruitment/vertical-schema.yaml:592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
docs/verticals/recruitment/vertical-schema.yaml:647:  opportunity_about_candidate:
docs/verticals/recruitment/vertical-schema.yaml:672:    candidate: none
docs/verticals/recruitment/vertical-schema.yaml:673:    contractor: none
docs/verticals/recruitment/vertical-schema.yaml:682:  Janitor:
docs/verticals/recruitment/vertical-schema.yaml:683:    candidate: R+W   # full sweep + normalisation + dedup proposals
docs/verticals/recruitment/vertical-schema.yaml:684:    contractor: R+W  # status normalisation
docs/verticals/recruitment/vertical-schema.yaml:693:    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
docs/verticals/recruitment/vertical-schema.yaml:694:    contractor: R+W  # contractor calls same pattern
docs/verticals/recruitment/vertical-schema.yaml:703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
docs/verticals/recruitment/vertical-schema.yaml:704:    contractor: none
docs/verticals/recruitment/vertical-schema.yaml:713:    candidate: R     # passive matching
docs/verticals/recruitment/vertical-schema.yaml:714:    contractor: R    # contractor pool
docs/verticals/recruitment/vertical-schema.yaml:723:    candidate: R+W   # lifecycle state on every event
docs/verticals/recruitment/vertical-schema.yaml:724:    contractor: R+W  # lifecycle state, contractor-specific cadence
docs/verticals/recruitment/vertical-schema.yaml:736:# Verifies against real Bullhorn data at Week 3-4 Janitor build per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:745:    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:747:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:757:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:763:    field_mapping_density: v0.1 covers 10 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. v1.1 Triage expands contact-side coverage.
docs/verticals/recruitment/vertical-schema.yaml:768:    field_mapping_density: v0.1 covers 17 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. Note Bullhorn customText1-25 fields are tenant-specific and require per-tenant adapter mapping not standard schema work.
docs/verticals/recruitment/vertical-schema.yaml:774:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
docs/verticals/recruitment/vertical-schema.yaml:811:    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
docs/verticals/recruitment/vertical-schema.yaml:890:    expected_date: post Week 3-4 (after Janitor build verifies against real Bullhorn data)
docs/verticals/recruitment/vertical-schema.yaml:892:      Codex-ratified version. Field sets expanded per Janitor's real-Bullhorn-data findings (Q3 trigger). Possibly Note entity promoted to entity_type if Janitor surfaces query patterns (Q2 trigger). 2-3 revisions expected from v0.1.
agents/_shared/tests/test-hook-helpers.sh:119:test_lookup_yellow() { local t; t=$(autosend_policy_lookup "bullhorn_candidate_dedupe"); _assert_eq "yellow" "${t}" "yellow"; }
agents/_shared/tests/test-hook-helpers.sh:132:  hh_decision_action "diagnostic_report_render" "candidate:test" "abc123" "test preview"
agents/_shared/tests/test-hook-helpers.sh:159:  HH_AWAIT_TEST_MODE=approve hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash1" "preview"
agents/_shared/tests/test-hook-helpers.sh:173:  HH_AWAIT_TEST_MODE=reject hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash2" "preview"
agents/_shared/tests/test-hook-helpers.sh:247:  # bullhorn_candidate_dedupe has sample_rate 10; over 200 draws we should get a sample
agents/_shared/tests/test-hook-helpers.sh:251:    if autosend_should_sample "bullhorn_candidate_dedupe" "${CTX_TENANT_SLUG}"; then
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:9:-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:213:        'perm', 'contract', 'contract_inside_ir35', 'contract_outside_ir35', 'day_rate', 'hybrid'
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:398:    'janitor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:455:  -- janitor_dedup_threshold: number in [0.75, 0.95] per supplement default 0.85
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:456:  IF c ? 'janitor_dedup_threshold' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:457:    IF jsonb_typeof(c->'janitor_dedup_threshold') != 'number' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:458:      RAISE EXCEPTION 'janitor_dedup_threshold must be number';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:460:    IF (c->>'janitor_dedup_threshold')::numeric < 0.75
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:461:       OR (c->>'janitor_dedup_threshold')::numeric > 0.95 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:462:      RAISE EXCEPTION 'janitor_dedup_threshold out of [0.75, 0.95] range: %', c->>'janitor_dedup_threshold';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:466:  -- janitor_last_run: ISO-8601 timestamp string or null
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:467:  IF c ? 'janitor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:468:    IF jsonb_typeof(c->'janitor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:469:      RAISE EXCEPTION 'janitor_last_run must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:79:-- is the indexed surface for hh_load_voice_samples semantic retrieval.
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 257; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 182-187 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 257-262; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:239:       `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint failure)
agents/recruitment/cash-conductor/agent.md:313:Gate A failures fire either `ESC_AGENT_OUTPUT_SHAPE` (invoice/amount/paid-precondition miss; output-shape constraint) OR `ESC_ADDRESSEE_MISMATCH` (client_contact_email mismatch; blocking per catalogue §2.10 — explicit Cash Conductor invoice/chase addressee case). Draft stays in `/tmp` (auto-purged 24h); operator notified per the specific ESC route.
agents/recruitment/cash-conductor/agent.md:325:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:344:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss on invoice_number / amount_due / paid-invoice-precondition (NOT addressee mismatch — that uses ESC_ADDRESSEE_MISMATCH) | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:346:| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
agents/recruitment/cash-conductor/agent.md:353:- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
agents/recruitment/cash-conductor/agent.md:363:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:367:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/scribe/agent.md:41:v1.0 supports Fathom (HMAC-SHA256 signed) and Fireflies (bearer token) providers; auth handled per-provider in `tools.yaml` capability declarations. Ringover (OAuth-protected) is deferred to v1.1+ — not in the v0 build dependencies and not registered in v1.0 `tools.yaml`.
agents/recruitment/scribe/agent.md:82:Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Scribe agent.md will re-verify field-name accuracy against the supplement-as-RATIFIED state at W6 Day-1.
agents/recruitment/scribe/agent.md:162:   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
agents/recruitment/scribe/agent.md:245:Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/scribe/agent.md:257:Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
agents/recruitment/scribe/agent.md:259:Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).
agents/recruitment/scribe/agent.md:276:| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:280:| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
agents/recruitment/scribe/agent.md:292:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:296:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:297:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:311:| Janitor ratified (Bullhorn auth substrate via W5 build) | W5 Codex Round | ⏸ |
agents/recruitment/sourcing-scout/agent.md:146:     sources cannot produce ≥5 candidates: ESC_AGENT_OUTPUT_SHAPE +
agents/recruitment/sourcing-scout/agent.md:189:     (LinkedIn URL) — same fuzzy matcher as Janitor (confidence ≥0.85)
agents/recruitment/sourcing-scout/agent.md:223:   → hh_decision_output("candidate_proposed", "candidate:<bullhorn_id|external_ref>",
agents/recruitment/sourcing-scout/agent.md:231:    → if any condition fails: ESC_AGENT_OUTPUT_SHAPE (output-shape violation
agents/recruitment/sourcing-scout/agent.md:264:- Output-shape failures (count not in 5-15, contact-method missing, rationale <50 words, voice classifier miss, all-source-failure-without-degradation) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)
agents/recruitment/sourcing-scout/agent.md:275:Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing) — operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
agents/recruitment/sourcing-scout/agent.md:295:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:296:| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
agents/recruitment/sourcing-scout/agent.md:302:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
agents/recruitment/sourcing-scout/agent.md:312:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:317:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:318:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
agents/recruitment/sourcing-scout/agent.md:332:| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
agents/recruitment/janitor/README.md:1:# Janitor — directory README
agents/recruitment/janitor/README.md:14:Full agent bundle per ADR-003: 6 files + 3 fixtures. Built at W5 start (~2 weeks per ULTRAPLAN A2 line 512):
agents/recruitment/janitor/README.md:27:Janitor W5 build slice gated on:
agents/recruitment/janitor/README.md:36:*End of Janitor README.*
agents/recruitment/janitor/agent.md:1:# Janitor — the wedge agent
agents/recruitment/janitor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority. R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4. R19 fixes (today): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice.
agents/recruitment/janitor/agent.md:7:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:8:**Build complexity:** L (2 weeks) per ULTRAPLAN A2 line 512.
agents/recruitment/janitor/agent.md:9:**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.1.
agents/recruitment/janitor/agent.md:17:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`.
agents/recruitment/janitor/agent.md:26:# /etc/cron.daily/ifos-janitor → calls this script per tenant
agents/recruitment/janitor/agent.md:27:0 2 * * * sudo -u ifos_user /usr/local/bin/ifos-janitor.sh --tenant <slug>
agents/recruitment/janitor/agent.md:30:Resolved by cortextOS daemon → spawns Janitor in Tier-2 batch mode (no persistent PTY). Typical runtime per tenant: 15-45 min depending on Bullhorn corpus size.
agents/recruitment/janitor/agent.md:35:ifosctl janitor --tenant <slug> [--dry-run] [--report-only]
agents/recruitment/janitor/agent.md:42:- Brain UI "Run Janitor now" button → triggers via internal API
agents/recruitment/janitor/agent.md:43:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold` — declared in `vertical-schema.v0.3-supplement.yaml §4 tenant_adapters_config_additions.janitor_dedup_threshold`; enforced by `migrations/v0.2-to-v0.3.sql §5` validator allowlist)
agents/recruitment/janitor/agent.md:53:Located at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`. Eight sections:
agents/recruitment/janitor/agent.md:59:| 3 | **Field-completeness deltas** | Per entity-type table: which fields were filled in (e.g., candidate.location, contractor.day_rate); source of the backfill (Companies House lookup, LinkedIn enrichment, derivation from related entities) |
agents/recruitment/janitor/agent.md:60:| 4 | **Tacit-note coverage** | Notes harvested from `recent_edit` table rows with `resolution='approved_after_edit'` (per v0.2-supplement.yaml recent_edit definition; v0.3 supplement §2a grants Janitor R access); attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:61:| 5 | **Agent vs. consultant attribution** | Rows attributed to Janitor automated work vs consultant manual entry; supports the day-30 before/after narrative |
agents/recruitment/janitor/agent.md:62:| 6 | **Gate-B metric** | TWO independent thresholds per ULTRAPLAN A2 line 511 verbatim: dedup improvement ≥15% AND field-completeness improvement ≥10%. Both must pass. NOT a composite score — that would let one threshold cover for the other. |
agents/recruitment/janitor/agent.md:70:1. **Candidate merge** (`PUT /Candidate/{primary_id}` + cascade) — only when confidence ≥0.85 per Gate A; no merge if either candidate had Bullhorn activity in last 90 days without explicit review flag (per ULTRAPLAN A2 line 510 verbatim). Action type: **`bullhorn_candidate_dedupe`** (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW action_types; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:71:2. **Field backfill** (`PATCH /Candidate/{id}` or `/Client/{id}`) — fills missing canonical schema fields (per `vertical-schema.yaml`): `candidate.location` (line 124), `client.industry` (line 238), `client.size_employees` (line 243), `client.companies_house_number` (line 252), `contractor.day_rate_min/day_rate_max` (lines 193-197), `brief.salary_min/salary_max` (lines 371-376) from Companies House (for clients) or LinkedIn/derivation (for candidates). Sources logged in payload. Action type: **`bullhorn_field_backfill`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:72:3. **Tacit-note attach** (`POST /Note` linked to entity) — narrative summary of consultant edits + decision-log resolutions over the 30-day window. Action type: **`bullhorn_note_attach`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 20).
agents/recruitment/janitor/agent.md:74:Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.
agents/recruitment/janitor/agent.md:86:   → hh_decision_trigger("session_start", "janitor nightly cron")
agents/recruitment/janitor/agent.md:95:     opportunities created/modified since last Janitor run (last_run_at in
agents/recruitment/janitor/agent.md:96:     tenant_adapters.config.janitor_last_run — declared in vertical-schema
agents/recruitment/janitor/agent.md:97:     v0.3 supplement §4 tenant_adapters_config_additions.janitor_last_run;
agents/recruitment/janitor/agent.md:99:   → hh_decision_output("janitor_scan", "tenant:<slug>", "<N> entities scanned")
agents/recruitment/janitor/agent.md:107:     (per ULTRAPLAN A2 line 510 verbatim)
agents/recruitment/janitor/agent.md:118:     contractor.day_rate_min/day_rate_max (lines 193-197),
agents/recruitment/janitor/agent.md:127:     client.companies_house_number (line 252)
agents/recruitment/janitor/agent.md:139:     recent_edit definition; v0.3 supplement §2a grants Janitor R access):
agents/recruitment/janitor/agent.md:146:   → hh_decision_output("janitor_tacit_note_harvest", "tenant:<slug>",
agents/recruitment/janitor/agent.md:159:   → SELECT from decision_log WHERE agent_name='janitor' AND created_at >
agents/recruitment/janitor/agent.md:163:   → write to /vault/<tenant>/janitor-reports/day-30-<ISO-date>.md
agents/recruitment/janitor/agent.md:174:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:175:   → hh_decision_action("janitor_run_complete", "tenant:<slug>", payload_hash, payload_preview)
agents/recruitment/janitor/agent.md:176:   → exit code 0 (or 1 if BOTH Gate-B thresholds missed for 3 consecutive runs per §5 + catalogue → ESC_GATE_B_MISS)
agents/recruitment/janitor/agent.md:185:Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:188:- Every proposed merge has confidence ≥ 0.85 per ULTRAPLAN A2 line 510
agents/recruitment/janitor/agent.md:189:- No merge proposal where EITHER candidate has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim)
agents/recruitment/janitor/agent.md:199:- Output-shape failures (section count, write-batch size, dedup confidence below threshold for action) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)
agents/recruitment/janitor/agent.md:201:`ESC_DUPLICATE_DETECTED` (catalogue §2.5) is NOT a Gate A failure code — per catalogue trigger it's for dedup confidence ≥0.85 review-required cases (SUCCESS path; Telegram approval gate). Sub-0.85 confidence pairs silently drop in Step 3 algorithm; no ESC fire. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (catalogue line 163) is NOT used by Janitor — reserved for vertical-schema field-constraint violations at write-time.
agents/recruitment/janitor/agent.md:205:Per ULTRAPLAN A2 line 511 verbatim: **"day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement"**.
agents/recruitment/janitor/agent.md:209:Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
agents/recruitment/janitor/agent.md:211:Per catalogue `escalation-codes.md` ESC_GATE_B_MISS trigger (Janitor example: "dedup confidence <15% AND field-completeness uplift <10%"): `ESC_GATE_B_MISS` fires only when BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND completeness-improvement <10%) → flag for operator review (heuristic tuning may be needed; not a kill). Single-threshold misses are tracked in the day-30 report (§3 Output 1 row 6) and inform tenant-level quality review but do NOT fire ESC. Sensitivity choice: strict AND-trigger reduces false alarms; tightening to OR-trigger requires a catalogue amendment + re-ratification.
agents/recruitment/janitor/agent.md:226:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (section count or per-section citation missing in day-30 report) | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:227:| `ESC_DUPLICATE_DETECTED` | Per catalogue §2.5 trigger: dedup confidence ≥0.85 review-required cases (SUCCESS path; Telegram approval gate fires). NOT a Gate A failure code. | warn | operator_chat_id (via Telegram approval gate per catalogue routing) |
agents/recruitment/janitor/agent.md:228:| `ESC_GATE_B_MISS` | Per catalogue trigger: per-agent local Gate B metric threshold missed. For Janitor: BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND field-completeness-improvement <10%) per catalogue `ESC_GATE_B_MISS` Janitor example. Single-threshold misses do NOT fire (per §5 Gate B). Catalogue routing: operator_chat_id | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:229:| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
agents/recruitment/janitor/agent.md:231:Janitor does NOT use:
agents/recruitment/janitor/agent.md:233:- `ESC_VOICE_DRIFT_TENANT` — fired by nightly voice-drift cron (per `escalation-codes.md` line 170-175 trigger: ≥N `ESC_VOICE_DRIFT` rows from same tenant in rolling 7d window). Janitor only fires the per-run `ESC_VOICE_DRIFT`; aggregate `_TENANT` rollup is handled by the canary not Janitor.
agents/recruitment/janitor/agent.md:234:- `ESC_AUTOSEND_BLOCKED` — that's for red-tier blocks (`escalation-codes.md` line 41); Janitor writes are yellow tier only
agents/recruitment/janitor/agent.md:236:- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction
agents/recruitment/janitor/agent.md:244:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/janitor/agent.md:248:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
agents/recruitment/janitor/agent.md:249:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:257:Janitor build cannot start until ALL of the following are confirmed:
agents/recruitment/janitor/agent.md:277:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
agents/recruitment/janitor/agent.md:289:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/janitor/agent.md:292:| Q4 | Tacit-note attribution — should notes attribute to "Intel Force OS Janitor" or just "Internal note"? Tenant brand preference. | Per-tenant config at first-pilot onboarding. |
agents/recruitment/janitor/agent.md:296:### Gotchas (carried forward from ULTRAPLAN A2 line 513)
agents/recruitment/janitor/agent.md:298:1. **Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0.** Estimate 1 week for the MCP server, 1 week for the agent itself (per ULTRAPLAN A2 line 513).
agents/recruitment/janitor/agent.md:300:3. **Bullhorn webhook coverage is patchy** (per ULTRAPLAN A6 line 569 — Concierge note applies cross-agent). Janitor relies on polling not webhooks; safer for nightly cron pattern.
agents/recruitment/janitor/agent.md:321:*End of Janitor agent.md draft.*
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
docs/architecture/architecture-cohesion-review.md:89:| A2 | **`SET LOCAL` scopes the setting to the current transaction.** A connection pool with auto-commit could leak `app.current_tenant` across requests if `SET LOCAL` is wrong scope. | hook-helpers.sh `_hh_emit_row` issues `SET LOCAL` inside the same psql invocation as the INSERT — single transaction. | If connection pool shares connections across requests, `SET LOCAL` rolls back at commit; `SET` (non-LOCAL) would persist and cause leak. Helpers correctly use LOCAL. |
docs/architecture/architecture-cohesion-review.md:95:| A8 | **Bullhorn OAuth refresh-loop fires before token expiry under load.** Per-agent 8-min cycle vs 10-min TTL. | bullhorn-integration-path.md §4.5 + common-ats.json `auth_refresh_interval_seconds` | If the 2-min buffer is insufficient under network latency or rate-limit backoff, agent loses Bullhorn auth mid-write. Untested at scale; flagged at first Janitor build. |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:152:| G6 | **vault-concurrency.md `entities.version` enforcement is one-directional.** The doc names optimistic-concurrency UPDATE pattern but the helpers don't yet implement it (hook-helpers.sh has no entity-update path; that lands when an agent needs to write to `entities`). | Low (Janitor W5 will be first writer) | First entity-write helper at Janitor build adds version-check pattern. New ADR if pattern surfaces decisions. |
docs/architecture/architecture-cohesion-review.md:235:| R9 | A8: Bullhorn OAuth refresh timing under load | Low | First Janitor build stress test | Claude Code | Janitor W5 |
docs/architecture/architecture-cohesion-review.md:238:| R12 | G6: entities.version optimistic-concurrency helper | Low | First entity-write helper at Janitor build | Claude Code | Janitor W5 |
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/architecture/cortexos-primitive-status.md:161:The bus is real, well-tested at unit and integration layers, with HMAC-SHA256 message signing and a documented 3-directory lifecycle. However, **two pieces of the master-brief description are wrong against the verified SHA `c21fbfe`** — flagged below; both affect the brain-replacement boundary (§3.4) and need founder review before Day 7.
docs/architecture/cortexos-primitive-status.md:169:- `src/bus/message.ts:19-44` — HMAC-SHA256 signing using `${ctxRoot}/config/bus-signing-key`. Quirk 5 in `.agents/learnings/00-cortextos-quirks.md` confirms each instance has its own key (IFOS and Personal have separate HMAC keys).
agents/recruitment/diagnostic/agent.md:114:     payload {escalation_code: ESC_AGENT_OUTPUT_SHAPE, ...}; exit 1
agents/recruitment/diagnostic/agent.md:125:     with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE for
agents/recruitment/diagnostic/agent.md:161:- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
agents/recruitment/diagnostic/agent.md:163:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
agents/recruitment/diagnostic/agent.md:170:Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
agents/recruitment/diagnostic/agent.md:182:| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn upstream 429 | warn | operator_chat_id | **v0: NOT implemented in `cycle.sh` (generator throws-and-exits on upstream errors; validate.sh catches downstream as `ESC_AGENT_OUTPUT_SHAPE`). W4-planned: 429 catch + retry-with-backoff in `cycle.sh` + explicit `ESC_RATE_LIMIT_HIT` emission.** |
agents/recruitment/diagnostic/agent.md:184:| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing OR generator produced empty stdout (Step 8 fallback) | warn | operator_chat_id | v0: implemented as specified. |
agents/recruitment/diagnostic/agent.md:199:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:203:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
agents/recruitment/diagnostic/agent.md:204:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. **v0: per-run `ESC_VOICE_DRIFT` fires when `validate.sh` V3 single-pass classifier call (no retries) returns score <0.75 AND `IFOS_VOICE_CLASSIFIER_URL` was reachable. W4-planned: 3-retry classifier loop in `@ifos/diagnostic-generator` §12 LLM step + unconditional hard-fail when URL unreachable.** Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:145:| `heartbeat` | cortextOS heartbeat cadence — periodic `update-heartbeat` writes to `${ctxRoot}/heartbeats/{name}.json` so the dashboard sees "alive" status | IFOS agents emit heartbeats too (the daemon's fast-checker writes them per `agent-process.ts:597-639` session timer), but the *cadence* and *what the agent does at each heartbeat* is specced per-agent in `agent.md` (Concierge always-on; Janitor cron-driven; etc.). The cortextOS-template `heartbeat/SKILL.md` is a default playbook — IFOS replaces with per-agent specifics |
docs/architecture/agent-bundle-renderer-design.md:221:  - ESC_DUPLICATE_DETECTED
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:322:hh_load_tone_rules
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
agents/recruitment/diagnostic/cycle.sh:163:    '{"escalation_code":"ESC_AGENT_OUTPUT_SHAPE","agent_name":"diagnostic","shape_rule_violated":"non_empty_output","expected_value":"non-empty stdout","actual_value":"empty"}' >/dev/null
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:185:The flock (§2) prevents two operations from racing the same file's read-then-write. The Postgres version check (§3) catches the rare case where flock acquisition succeeded sequentially but a *different* code path (e.g. cron-driven full-table update in Janitor's nightly sweep) updated the row without holding flock.
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
docs/build-brief/00-MASTER-BRIEF.md:348:1. **Ingest (`kb-add`).** An agent (Scribe, Triage, Janitor, etc.) drops a raw artefact into `raw/{category}/`. Ingest writes the file with provenance frontmatter (`source: scribe-agent`, `ingested_at: ...`, `tenant_id: ...`).
docs/build-brief/00-MASTER-BRIEF.md:358:   provenance: [scribe-agent:call-2026-05-16-1432, janitor:bullhorn-2026-05-15]
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:582:- `ESC_DUPLICATE_DETECTED` — high-confidence dedup needs human review
docs/build-brief/00-MASTER-BRIEF.md:596:| 2 | Janitor | 5 | Bullhorn MCP (R+W) | First demoable inside-ATS result; day-30 before/after closes deals |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:611:git checkout -b agent/{name}                       # e.g. agent/janitor
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
agents/recruitment/concierge/agent.md:156:   → ESC_AGENT_OUTPUT_SHAPE if critical Bullhorn context fields missing
agents/recruitment/concierge/agent.md:162:     "candidate:<bullhorn_id>", "fields_present:<N>")
agents/recruitment/concierge/agent.md:170:   → hh_decision_output("addressee_resolved", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:185:   → hh_decision_output("escalation_position_set", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:195:     "candidate:<bullhorn_id>:<event_type>", "vault_path:<path>; voice_score:<N>; words:<N>")
agents/recruitment/concierge/agent.md:225:    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:236:      "candidate:<bullhorn_id>:<event_type>", payload_hash,
agents/recruitment/concierge/agent.md:243:      "candidate:<bullhorn_id>", payload_hash, payload_preview)
agents/recruitment/concierge/agent.md:252:      "candidate:<bullhorn_id>", "event_type:<type>")
agents/recruitment/concierge/agent.md:258:    → hh_decision_action("concierge_send_complete", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:265:    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
agents/recruitment/concierge/agent.md:283:- All Bullhorn context fields present (no missing candidate name / no missing email) — hard-fail (ESC_AGENT_OUTPUT_SHAPE; ESC_CANDIDATE_DATA_INCOMPLETE is Sourcing Scout's per catalogue §2.10)
agents/recruitment/concierge/agent.md:287:Gate A failures fire `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` or `ESC_PII_LEAKAGE_RISK` or `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint — missing Bullhorn context OR voice threshold misses persistently) — all blocking; draft to `/tmp`; operator notified immediately.
agents/recruitment/concierge/agent.md:298:- **30-min SLA hit rate:** % of drafts generated within 30 minutes of lifecycle-event DETECTION. Target ≥90%. Per-draft misses fire `ESC_CONCIERGE_SLA_MISS`; rolling-window aggregate <90% fires `ESC_GATE_B_MISS`. (per ADR-007 + amended ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:300:Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
agents/recruitment/concierge/agent.md:315:| (Concierge does NOT use `ESC_CANDIDATE_DATA_INCOMPLETE` — per catalogue §2.10 that code is reserved for Sourcing Scout shortlist completeness. Concierge's missing-Bullhorn-context case fires `ESC_AGENT_OUTPUT_SHAPE` per Gate A discipline below.) | — | — |
agents/recruitment/concierge/agent.md:323:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:324:| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% for 30 consecutive days | warn | founder + operator |
agents/recruitment/concierge/agent.md:326:| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow/orange-tier sample row selected for audit | info | operator_chat_id |
agents/recruitment/concierge/agent.md:332:- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
agents/recruitment/concierge/agent.md:342:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
agents/recruitment/concierge/agent.md:349:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:350:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
agents/recruitment/concierge/agent.md:369:| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
docs/architecture/second-brain-design.md:198:| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:207:| `wiki/raw/ats-snapshots/` | one file per entity sync | JSON | `{epoch}-{bullhorn-entity-type}-{bullhorn-id}.json` | Janitor (v1.0) on nightly sweep | Janitor itself (diff vs previous), Concierge (v1.0) for entity reconciliation |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:210:| `wiki/compiled/clients/{slug}.md` | one per Client | same | same | Janitor (v1.0) on first contact | Cash Conductor + Concierge (v1.0) |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:236:| Client | **v1.0** | Janitor + Cash Conductor + Concierge all require it |
docs/architecture/second-brain-design.md:237:| Brief | **v1.0 (skeleton) / v1.1 (full)** | Sourcing Scout (v1.0 A5) needs to *read* a Brief to source against; Brief Decoder (v1.1 A8) is the producer. v1.0 writes minimal Briefs (manual entry or direct Bullhorn sync via Janitor); full lifecycle waits for v1.1 |
docs/architecture/second-brain-design.md:258:  - janitor:bullhorn-2026-05-15
docs/architecture/second-brain-design.md:263:bullhorn_id: 12345                                   # optional; external ATS reference (Janitor populates)
docs/architecture/second-brain-design.md:264:linkedin_url: https://linkedin.com/in/sarah-bowen    # optional; Janitor populates
docs/architecture/second-brain-design.md:274:{Janitor or Scribe one-paragraph summary, regenerated on each ingest}
docs/architecture/second-brain-design.md:305:companies_house_number: 12345678                     # optional; UK-specific; Janitor populates
docs/architecture/second-brain-design.md:424:| `search-by-relationship` | Janitor (v1.0): all Candidates linked to Brief X for dedup | v1.0 | `(from_id: str, link_type: str, tenant_id: str)` | `List[EntityRef]` | few seconds | Postgres `entity_graph` traversal; one-hop only in v1.0, multi-hop deferred to graph view v1.2 |
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:459:  - **Git:** **Spec gap 2.4-A.** Neither master brief nor Ultraplan specifies whether `/vault/{tenant}/` is also a git repo. Obsidian users typically git-init their vaults. **Recommendation:** yes — initialize `/vault/{tenant}/.git/` at tenant provisioning (Ultraplan §5.5 step 2). Founder gets free history, blame, and rollback via Obsidian Git plugin. Agents do NOT commit; the founder commits manually or via a scheduled cron run by Janitor's nightly sweep. **Blocks v1.0 build:** no — git init is one line in `provision-tenant.sh`; commit cadence can be decided in Week 1.
docs/architecture/second-brain-design.md:654:        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
docs/architecture/second-brain-design.md:709:- t=0+50ms: Janitor calls `update-entity(candidate_sarah_bowen, "right_to_work_status", "verified")`. Blocks on the flock.
docs/architecture/second-brain-design.md:711:- t=0+301ms: Janitor acquires flock. Reads file (now contains Concierge's append). Reads Postgres (`updated_at = T1`). Computes new frontmatter. Writes file atomically. Postgres UPDATE `WHERE updated_at = T1` succeeds (`updated_at = T2`).
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:761:- `ingest-entity` — Janitor's nightly sweep ingests thousands of records; batching is the model. Per-record latency 100ms-1s is fine.
docs/architecture/second-brain-design.md:775:| Janitor | 1:5 | reads each Bullhorn entity once; writes many cleanup updates per sweep |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/_supplementary/PRD-autonomous-agent.md:766:    candidate: c,
docs/specs/PRODUCT-SPEC.md:137:#### R9. The Janitor — the database becomes an asset
docs/specs/PRODUCT-SPEC.md:211:- **Revenue story:** "Inside-IR35 misclassification per contractor: £15k–£60k of back-claimed PAYE liability per HMRC enquiry. We avoid one of these per year per 30-contractor desk."
docs/specs/PRODUCT-SPEC.md:242:| **Solo** (1–4 fee earners) | £499 | Janitor + 1 always-on agent (drafts-only) + Scribe | "Pay back the year inside one extra placement. Save 10+ hours/week of inbox and admin drag." |
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:279:        │   The Scribe captures    │    │  The Janitor keeps it    │
docs/specs/PRODUCT-SPEC.md:344:- Janitor runs against the ATS — produces the day-1 cleanup report.
docs/specs/PRODUCT-SPEC.md:430:**1. Every agent now has a quantified revenue story, not just a time-saved story.** The internal business plan and the 24/7 directive had revenue stories for some agents (Cash Conductor, Client Hunter, T5) but not all. Triage was pitched on responsiveness; here it's pitched on "2–4 additional placements/year per consultant from never-lost candidates". Janitor was pitched on database hygiene; here it's pitched on "one reactivated dormant-but-clean candidate per month covers the tier price".
docs/specs/PRODUCT-SPEC.md:458:- **No free pilots beyond the structured 14-day Janitor cleanup trial.** Free pilots train customers to expect free.
docs/specs/PRODUCT-SPEC.md:472:- The Janitor (the wedge agent; lowest risk, highest visible value)
docs/specs/PRODUCT-SPEC.md:530:9. **The Janitor** — "Your sourcing runs become 3× more productive against clean data."
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:155:hh_load_tone_rules
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:184:- `ESC_DUPLICATE_DETECTED` — Janitor found a high-confidence dedup candidate requiring human review
docs/specs/ULTRAPLAN.md:239:- Scheduled agents (Janitor, Reporting, Spec Pitcher) run as cron jobs *also* under the tenant's OS user.
docs/specs/ULTRAPLAN.md:423:| Janitor | 30-day before/after report shows ≥15% dedup, ≥10% field-completeness improvement | The day-30 report IS the Gate B measurement |
docs/specs/ULTRAPLAN.md:501:#### A2. The Janitor — the wedge agent
docs/specs/ULTRAPLAN.md:566:- **Gate A:** voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82 per escalation_position); correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
docs/specs/ULTRAPLAN.md:686:| Janitor | | ✓ | | | | ✓ | | | | | |
docs/specs/ULTRAPLAN.md:757:### Weeks 5–6 — Janitor + Scribe
docs/specs/ULTRAPLAN.md:759:- Week 5: Janitor agent; day-30 before/after report template; CI fixtures
docs/specs/ULTRAPLAN.md:762:Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.
docs/specs/ULTRAPLAN.md:799:4. Janitor's Workflow F (the day-30 before/after report) — can be manually compiled for the first tenant
docs/specs/ULTRAPLAN.md:818:| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/specs/ULTRAPLAN.md:824:| 8 | First pilot's Bullhorn data is too messy for Janitor's dedup confidence threshold | Medium | Medium | <5% dedup proposed in week 6 trial run | Lower threshold to 0.7 for the initial cleanup; ship the day-30 report regardless |
docs/specs/ULTRAPLAN.md:829:| 13 | The Bullhorn API rate limits prevent Janitor from completing its initial sweep on day 1 | Medium | Medium | First sweep takes >24 hours | Initial sweep runs in batches over 3 days; communicate to tenant explicitly |
docs/operations/codex-ratification-execution-plan.md:73:| `review-mcp-connector.md` | New MCP connector checklist | ~200 | Pre-Janitor-W5 (not yet needed) |
docs/operations/codex-ratification-execution-plan.md:352:- **Option α** — Start immediately. Rationale: 33 items are already queued; Q1 turning YES will only ADD items (Diagnostic + Janitor + downstream). The 34-item queue is largely about Week 0 design artefacts that won't change post-LOI. Get them ratified now while context is fresh.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:49:**Codex says:** "Line 169 claims Diagnostic's 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:119:| Janitor | ~5-7 (count regex inflated; 56 numbered items including nested) | `logs/codex-ratification/20260524T102050Z-21293/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:155:## Janitor Round-5 (remediation) — empirical confirmation of bilateral pattern
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:157:After all 6 Round-4-v2 issues remediated on Janitor (commit `2392af8`), Round-5 ratification returned REJECTED with **5 NEW findings** — none of the original 6 reappeared. New issues at Janitor session `20260524T103757Z-37420`:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:160:2. **`bullhorn_field_backfill` unregistered, would fail-safe to red:** my flag-for-addition framing didn't satisfy because `hook-helpers.sh::autosend_policy_lookup` fails to red on unknown action types AT RUNTIME, regardless of flag prose. Real bug requires either (a) policy row added BEFORE ratification, OR (b) explicit "blocked W5 prerequisite" framing not "executable output."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:161:3. **§5 vs §6 ESC code contradiction:** §5 prose retains `ESC_SCHEMA_VIOLATION` reference even though §6 explicitly says Janitor doesn't use it. Mechanical fix missed by my Round-4-v2 remediation.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:184:## Janitor Round 6 (exceeds hard ceiling) — 4 more NEW findings, all different from Rounds 4-5
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:191:4. `ESC_DUPLICATE_DETECTED` semantics — catalogue defines it for ≥0.85 human-review-required, not <0.85 reject
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:210:## Janitor Round 7 — 23+ unique issues; pattern definitively closed
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:212:After all 4 Round-6 issues remediated on Janitor (commit `1939d9b`), Round 7 returned REJECTED with **4 more new findings**, none from Rounds 4-6:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:214:1. `operator_notify_telegram` + `janitor_run_complete` are unregistered hh_decision_action types — hook-helpers fails them to red via `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`. (Found because my Round-6 commit added those calls without registering them.)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:215:2. §5 vs §6 STILL contradict on `ESC_DUPLICATE_DETECTED` — my Round-6 fix updated §6 cell but missed the §5 prose that still cited the wrong mapping.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:216:3. `ESC_GATE_B_MISS` definition in §6 still says "Composite Gate-B score <12.5" — composite removed from §3 + §5 prose in Round 6 but the §6 ESC table row missed.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:261:- Cross-section consistency: removed (new — W-X catalogue add) annotations; ESC_AUTOSEND_BLOCKED kept red-tier-only; ESC_SCHEMA_VIOLATION kept schema-field-violation-only; ESC_VOICE_DRIFT_TENANT removed from direct firing across all agents; ESC_AUTOSEND_YELLOW_SPOT_CHECK → ESC_AUTOSEND_SAMPLED_SPOT_CHECK
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:273:| Janitor | 6 | `20260524T112807Z-81339` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:289:- Janitor: `candidate.linkedin_url` not in schema
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:299:- `ESC_LIFECYCLE_STATE_UNKNOWN` — Concierge uses for taxonomy misses; catalogue defines for Janitor placement ambiguity. Resolution: widen.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:315:  - Janitor Step 1 auth refresh emits ESC without decision row
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:324:**Cumulative empirical:** 9 Codex rounds total (Round 4-v1, 4-v2, 5, 6, 7 on Diagnostic/Janitor + Round 8 across all 6). **55+ unique findings catalogued across rounds, ~10-12 fixed via Cat-α mechanical disposition in this bilateral session; rest queued.**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:330:- Janitor: pre-build-scaffold; Round-8-reviewed; ~3 schema-supplement findings (Cat-β) + ~2 catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:357:- `ESC_LIFECYCLE_STATE_UNKNOWN` — both Janitor placement + Concierge taxonomy out-of-bounds
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:363:- `validate.sh` emits specific §6 ESC codes (ESC_PII_LEAKAGE_RISK or ESC_AGENT_OUTPUT_SHAPE) not generic ESC_SCHEMA_VIOLATION
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:371:| Janitor | 6 | 6 | 0 (different findings; 1 Cat-γ closed, 1 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:427:| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
docs/specs/_archive-build-handoff.md:253:Confirm or revise Ultraplan §9's assumption: **close the first three pilots fastest**. That means Janitor and Cash Conductor close demos before Triage absorbs the development heat. Revise only if a hire's signed or a different pilot dynamic emerges.
docs/specs/_archive-build-handoff.md:328:git checkout -b agent/bullhorn-mcp        # or agent/janitor, agent/scribe, etc.
docs/specs/_archive-build-handoff.md:331:mkdir -p agents/janitor/tests/fixtures/{01-primary,02-edge-case-merged-duplicates,99-voice-drift-canary}
docs/specs/_archive-build-handoff.md:378:| 2 | **Janitor** | 5 | Bullhorn MCP (read + write) | First demoable inside-the-ATS result; day-30 before/after report closes deals |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:43:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:121:- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
docs/operations/goal-option-c-diagnostic-end-to-end.md:253:- **Consequences:** Janitor W5 build conditional on Bullhorn A+B Accepted. If A+B answer arrives after 2026-06-03, Janitor slips to W6+; if no answer by 2026-06-10, force Direct-API fallback per `bullhorn-integration-path.md` §1.4.
docs/operations/goal-option-c-diagnostic-end-to-end.md:409:  - [Proceed to Week-4 polish OR wait on Bullhorn response before Janitor W5?]
docs/operations/goal-week-3-polish-and-scaffold.md:7:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:35:After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Six v1.0 agents: [list with weeks]. ULTRAPLAN §8.1 agent line ranges: [A1 lines 495-505, A2 lines 507-514, ...]. Week-3 scope confirmed. Ready to begin Step 1."**
docs/operations/goal-week-3-polish-and-scaffold.md:52:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:61:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:65:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:210:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:288:### DAY 16 — Janitor agent.md scaffold (Step 8)
docs/operations/goal-week-3-polish-and-scaffold.md:290:#### Step 8 — `agents/recruitment/janitor/agent.md` (~2-3 hours)
docs/operations/goal-week-3-polish-and-scaffold.md:293:- ULTRAPLAN §8.1 A2 lines 507-514 (full Janitor spec)
docs/operations/goal-week-3-polish-and-scaffold.md:294:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:295:- `bullhorn-integration-path.md` §4.1 (Janitor's Bullhorn entity surface)
docs/operations/goal-week-3-polish-and-scaffold.md:296:- `v1.0-kill-criterion.md` Trigger 3 (JANITOR-BULLHORN-AUTH-W5)
docs/operations/goal-week-3-polish-and-scaffold.md:297:- `vertical-schema.yaml` §3 agent_access_matrix Janitor row
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:311:- **§7 Voice + tone:** N/A (Janitor doesn't produce customer-facing output; all writes are internal data).
docs/operations/goal-week-3-polish-and-scaffold.md:324:Commit: `decision(pre-build): agents/recruitment/janitor/agent.md — output contract per ULTRAPLAN §8.1 A2`
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:618:  Janitor (W5):           <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:631:  <SHA>  decision(pre-build): agents/recruitment/janitor/agent.md
docs/operations/goal-week-3-polish-and-scaffold.md:657:    - Janitor build (depends on Bullhorn R+W)
docs/operations/goal-week-3-polish-and-scaffold.md:685:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/operations/w4-day-20-founder-runbook.md:109:2. Janitor (4 findings) — schema-citation cluster, mechanical
docs/operations/codex-round-2-remediation-prompt.md:204:      to Accepted before Janitor (W5) build starts per
docs/operations/codex-round-2-remediation-prompt.md:205:      `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/operations/codex-round-2-remediation-prompt.md:219:  | Janitor W5 build | A+B Accepted (commercial conversations complete) | Pending |
docs/operations/w4-bilateral-pass-6-agent-md.md:36:| 2 | Janitor | 4 | All mechanical schema-citation fixes; cleanest pass. |
docs/operations/w4-bilateral-pass-6-agent-md.md:62:  - **Codex says:** "Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature."
docs/operations/w4-bilateral-pass-6-agent-md.md:80:## 2. Janitor — `agents/recruitment/janitor/agent.md`
docs/operations/w4-bilateral-pass-6-agent-md.md:86:  - **Codex says:** "Line 187 says `ESC_AGENT_OUTPUT_SHAPE` applies to 'ALL Gate A conditions,' including voice classifier, PII, and write-batch size. The catalogue defines `ESC_VOICE_DRIFT` for classifier failures and `ESC_PII_LEAKAGE_RISK` as blocking for PII leakage; downgrading PII to `ESC_AGENT_OUTPUT_SHAPE` weakens Gate A routing. Fix §5 so each Gate A condition maps to its catalogue code, reserving `ESC_AGENT_OUTPUT_SHAPE` for report/output-shape failures only."
docs/operations/w4-bilateral-pass-6-agent-md.md:98:  - **Codex says:** "Lines 135-137 say Janitor queries the `recent_edit` v0.2 table directly, but v0.2 access lists only voice-drift-canary, Concierge, and LoRA; Janitor R access is added in v0.3 supplement §2. Fix the citation to v0.3 supplement and add v0.3 schema/migration ratification as a §8 prerequisite."
docs/operations/w4-bilateral-pass-6-agent-md.md:102:### Finding 4. `janitor_dedup_threshold` + `janitor_last_run` keys absent from schema supplement
docs/operations/w4-bilateral-pass-6-agent-md.md:104:  - **Codex says:** "Lines 42, 95, and 166 rely on `janitor_dedup_threshold` and `janitor_last_run`; `rg` finds these only in the v0.2-to-v0.3 migration allowlist, not in `vertical-schema.yaml` or the v0.3 supplement's `tenant_adapters_config_additions`. Fix by adding both keys with type/owner/read-write semantics to the schema supplement, then cite that schema section instead of only the migration allowlist."
docs/operations/w4-bilateral-pass-6-agent-md.md:117:  - **Likely:** FIX-IN-PLACE. Remove v0.4-pending claim for `blocked_recipients`; keep it only for `auto_source_on_brief_create`. (Verify: v0.3 migration line 397 does include `blocked_recipients` in allowlist? Confirmed in our earlier read: "tier_overrides, blocked_recipients, janitor_dedup_threshold..." — yes.)
docs/operations/w4-bilateral-pass-6-agent-md.md:230:2. **Schema-citation hygiene** (Janitor #2, #3, #4; Sourcing Scout #1; Scribe #1) — v0.2/v0.3 supplement boundary is the single most-failed cross-reference. After this pass, recommend a CI grep that flags any `agent.md` field reference whose name doesn't appear in `vertical-schema.yaml` OR `vertical-schema.v0.3-supplement.yaml`.
docs/operations/w4-bilateral-pass-6-agent-md.md:232:3. **Catalogue completeness** (Diagnostic #2, Janitor #1, Scribe #5) — `escalation-codes.md` is the canonical mapping; agent.md narratives drift from it. After this pass, recommend a CI grep verifying every `ESC_*` reference in `agent.md` exists in the catalogue with at least the agent_name in `used_by`.
docs/decisions/brain-ui-scope.md:43:- Highlights `ESC_*` escalations across all agents — `ESC_BULLHORN_AUTH`, `ESC_VOICE_DRIFT`, `ESC_DUPLICATE_DETECTED`, `ESC_RENDERER_FAILED`, etc.
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:20:| 5 | Janitor (Bullhorn R+W) |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:43:| W5 Day 28+: Janitor build start | W5 Day 28+: **Conditional on Bullhorn Sub-decisions A+B Accepted** |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:63:### Week 5 (Day 28+) — Janitor build conditional gating
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:65:| Bullhorn A+B state by Day 28 | Janitor action |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:69:| Bullhorn unresponsive past 2026-06-10 | Force Direct-API fallback per `bullhorn-integration-path.md` §1.4; Janitor scaffold begins; Bullhorn auth gated on first pilot raising support ticket |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:73:- Scribe (W6) depends on Bullhorn write; same gating as Janitor
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:40:Recommend a one-paragraph footnote in §2.4 that names the substrate: messages are JSON files under `${ctxRoot}/inbox/<to>/{pnum}-{epochMs}-from-{sender}-{rand5}.json`, three-directory lifecycle (`inbox → inflight → processed`), HMAC-SHA256 signed (Quirk 5), stale-inflight recovery at 5 minutes.
docs/decisions/autosend-approval-bridge-spec.md:159:Target: candidate:s.bowen
docs/decisions/autosend-approval-bridge-spec.md:240:| A2 | `.pending` marker triggers `createApproval` call within 200ms | Integration test: write marker → assert cortextOS pending file appears with correct payload |
agents/recruitment/diagnostic/validate.sh:239:  #     length) → ESC_AGENT_OUTPUT_SHAPE (warn)
agents/recruitment/diagnostic/validate.sh:258:    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:10:> 3. §4 Gate-A failure signature is incomplete. Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature.
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:14:Codex's quote stops at line 119 ("...carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`"), but the file's statement spans lines 117-121 — and ESC_VOICE_DRIFT IS listed at lines 119-120. The full text (verbatim from the file at R16 close commit `4854b37`, unchanged at R17):
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:18:118    with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE for
docs/decisions/sequencing-target.md:22:| A2 | Janitor | 5 | Bullhorn MCP (R+W) | "First demoable inside-ATS result; day-30 before/after closes deals" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:34:- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:71:- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
docs/decisions/sequencing-target.md:74:Recommended sequence in §4 must remain **operationally coherent under both contingencies.** A sequence that breaks (e.g. one that ships Concierge before Janitor) would lose the Risk #2 contingency because dropping Janitor would orphan the already-shipped Concierge's data flow. The §4 recommendation explicitly validates against both contingencies.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:105:### 2.2 — A2 Janitor
docs/decisions/sequencing-target.md:111:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #2** (Bullhorn auth path per RISK-REGISTER). Closes Risk #2 reduction trigger 2 from `bullhorn-integration-path.md` §6.7: "first Bullhorn write lands cleanly in Week 3-4 Janitor agent build" → Risk #2 Medium → Low |
docs/decisions/sequencing-target.md:113:| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
docs/decisions/sequencing-target.md:114:| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn `client_id` + `client_secret` (commercial action per Day 2 §6.1) + per-tenant Bullhorn admin OAuth authorisation (the browser dance per Day 2 §3.1). First-pilot onboarding wizard Day 2 step (Product Spec §5.2) is the moment Janitor can be enabled per tenant |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:123:| 2. Substrate exercise | **Medium-High** | Exercises Bullhorn W (smaller surface than Janitor's R+W). First agent with external webhook trigger (Fathom / Fireflies). First exercise of voice-loader for **tacit-note tone-detection** per Ultraplan §8.1 line 523. Reuses Janitor's Bullhorn auth refresh-loop |
docs/decisions/sequencing-target.md:124:| 3. Risk de-risking | **Medium** | Reuses Janitor's Bullhorn auth path (doesn't re-derisk Risk #2). Surfaces new failure mode: **webhook-arrival-to-Bullhorn-write SLA** (5-min target per Ultraplan §8.1 line 521). Doesn't directly touch Risk #5 (renderer already proven by Diagnostic) or Risk #1 (still Tier 2) |
docs/decisions/sequencing-target.md:126:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Concierge consumes Scribe-generated Notes for context per `bullhorn-integration-path.md` §4.1 row 4 ("Note (prior-comms history)"). Scribe must ship before Concierge | Medium-High criticality |
docs/decisions/sequencing-target.md:127:| 6. Tenant-onboarding readiness | **Medium** | Needs Fathom or Fireflies OAuth + Bullhorn (already onboarded if Janitor shipped). Tacit-note taxonomy needs per-firm calibration in first 30 days of production per Ultraplan §8.1 line 527 |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:151:| 2. Substrate exercise | **Medium** | Reuses Bullhorn R from Janitor (no new Bullhorn substrate). New MCP integrations: LinkedIn via Proxycurl (rate-limited per Ultraplan §10 row #6), Reed, CV-Library. Source-abstraction layer per Ultraplan §8.1 line 555 designed to be reusable by Night Sourcer v1.1 |
docs/decisions/sequencing-target.md:152:| 3. Risk de-risking | **Medium** | **First exercise of LinkedIn rate-limit budget** per Ultraplan §10 Risk #6 ("LinkedIn rate limits via Proxycurl are tighter than expected"). Reuses Bullhorn auth from Janitor (doesn't re-derisk Risk #2). Tier 2 so doesn't touch Risk #1 primitives |
docs/decisions/sequencing-target.md:153:| 4. Commercial value | **Medium** | Per Product Spec §2.2 R5: "Shortlist in 15 minutes instead of by end of week." Less commercially load-bearing than Janitor/Scribe/Concierge — request-response not always-on, so less of a closing-demo asset. Sales narrative is "cuts intake-call-to-first-shortlist time from same-week to same-hour" |
docs/decisions/sequencing-target.md:154:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Night Sourcer (v1.1) reuses Sourcing Scout's multi-source layer per Ultraplan §8.1 line 555 ("Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it") | Medium criticality (v1.1 downstream) |
docs/decisions/sequencing-target.md:155:| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn (already on if Janitor shipped) + LinkedIn (Proxycurl API key — single application-level key, not per-tenant) + Reed OAuth + CV-Library OAuth per tenant |
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:182:W5:   Janitor (A2)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:193:- W5: Risk #2 (Bullhorn auth) — Janitor first writes. Reduction trigger 2 fires (Medium → Low per `bullhorn-integration-path.md` §6.7).
docs/decisions/sequencing-target.md:209:W9:   Janitor (A2)
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:229:W5:   Janitor (A2) — Risk #2 derisk
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:256:| 5. Dependencies on other agents | **Wins** — Janitor's Bullhorn auth → Scribe reuses → Sourcing Scout reuses → Concierge reuses, all in dependency order | Loses — Concierge before Janitor + Scribe breaks the upstream chain | Loses — Concierge before Scribe breaks the upstream chain |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:314:**Trigger 3 — Hire #1 starts later than Week 7.** Per Ultraplan §9 line 766 verbatim caveat: "Hire #1 is assumed to start week 7 (verify, don't assume)":
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:408:First exercise is Janitor at W5 per §4.1 row 2. **If Day 2 Sub-decisions A and B haven't flipped from Proposed to Accepted by start of W4** (per `bullhorn-integration-path.md` §1.3 commercial-blocker table), this is the natural blocker. Founder Sunday/Monday commercial conversations must land before W4 start to keep the Janitor W5 slot intact. Sub-decision C is already Accepted so the endpoint surface is buildable; the gate is auth path (A) and client_credentials foreclosure (B).
docs/decisions/sequencing-target.md:439:- **Janitor's first Bullhorn auth refresh fails by W5** (Risk #2 unmitigated; commercial path broken)
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:82:| Janitor | `bullhorn_candidate_tag` | Adds a tag with `checked_at` date; reversible in <30s; high volume |
docs/decisions/autosend-safety-policy.md:92:| Janitor | `bullhorn_candidate_dedupe` | 1-in-10 | Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review |
docs/decisions/autosend-safety-policy.md:111:| Janitor | `bullhorn_placement_terminate` | Marks placement as terminated; commercial/legal implications; reversible only via support ticket |
docs/decisions/autosend-safety-policy.md:144:#   $2 target        (entity reference, e.g., "candidate:john-smith")
docs/decisions/autosend-safety-policy.md:246:  "target": "<entity ref, e.g., 'candidate:john-smith'>",
docs/decisions/autosend-safety-policy.md:273:Target: candidate:sarah-bowen
docs/decisions/autosend-safety-policy.md:435:      "bullhorn_candidate_dedupe": "orange"
docs/decisions/autosend-safety-policy.md:451:      "bullhorn_candidate_dedupe": 1,
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/ADR-003-agent-bundle-renderer.md:101:> git checkout -b agent/{name}                       # e.g. agent/janitor
docs/decisions/v1.0-kill-criterion.md:73:### Trigger 3 — JANITOR-BULLHORN-AUTH-W5 (PIVOT)
docs/decisions/v1.0-kill-criterion.md:75:**Threshold:** Janitor agent cannot authenticate to Bullhorn via the documented OAuth flow (per `bullhorn-integration-path.md` §4.5 refresh-loop architecture) by end of Week 5 (2026-06-28). Authentication failure modes that trigger: (a) OAuth token endpoint returns non-2xx persistently; (b) refresh-loop architecture fails at 10-minute TTL boundary; (c) Bullhorn rate-limits IFOS's auth endpoint preventing pilot operations; (d) Bullhorn partnership programme requirement blocks production-tenant access.
docs/decisions/v1.0-kill-criterion.md:85:- **Option C:** ATS-agnostic with manual data sync. Reduces v1.0 to read-only agent operation against ATS export files; loses much of the Janitor + Concierge value but unblocks pilot acquisition.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:158:### Trigger 8 — GATE-B-REVENUE-UPLIFT (KILL)
docs/decisions/v1.0-kill-criterion.md:227:- **Trigger 8 (Gate-B revenue) KILL:** founder decides KILL on revenue evidence; consults Jack on wind-down terms with existing pilots before 30-day notice goes out.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:49:- Aggregate failures fire `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) when sustained — same operational lever as ADR-006's per-claim quality metric
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:74:- ✅ All Bullhorn context fields present — Gate A hard-fail (`ESC_AGENT_OUTPUT_SHAPE`)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:80:- Rolling 30-day per-tenant aggregate <90% fires `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) — actionable signal
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:89:> - **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:131:| ADR-007-Q2 | Should `ESC_CONCIERGE_SLA_MISS` be a separate code, or should it reuse `ESC_GATE_B_MISS` with payload.metric='concierge_30min_sla'? | Recommend separate code for clean Telegram routing; `_GATE_B_MISS` is generic aggregate. Catalogue addition queued at W10-13 build start. |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:139:- `agents/_shared/escalation-codes.md` `ESC_CONCIERGE_SLA_MISS` (registered) + `ESC_GATE_B_MISS` (registered)
docs/operations/bullhorn-outreach-emails.md:5:**Purpose:** Drop-in email drafts the founder sends to Bullhorn partnerships + developer support to resolve Sub-decisions A + B in `docs/decisions/bullhorn-integration-path.md`. Closes Risk #2 mitigation path; unblocks Janitor W5 build gate.
docs/operations/bullhorn-outreach-emails.md:17:**These don't block today.** They block **Janitor W5 build** (per kill-criterion §2 Trigger 3). You have ~5 weeks of runway. But send today/Monday because Bullhorn's response time is 2-5 business days, and we want the answers before Diagnostic W3-4 completes so Janitor W5 starts unblocked.
docs/operations/bullhorn-outreach-emails.md:44:> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
docs/operations/bullhorn-outreach-emails.md:74:- If they require marketplace membership before production access → Sub-decision A is **Marketplace**; need cost + timeline to assess against kill-criterion §2 Trigger 3 (Janitor W5 deadline).
docs/operations/bullhorn-outreach-emails.md:151:2. **Monday 2026-06-01** — second nudge with explicit deadline reference ("we're targeting Janitor build W5; need clarity by then")
docs/operations/bullhorn-outreach-emails.md:160:**Reference.** Two drop-in email drafts ready for founder to send. Expected wall-clock: 1 week for both responses. Outcome: Sub-decisions A + B flip Accepted; Risk #2 mitigated; Janitor W5 build unblocked.
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:144:| 1 | `agents/recruitment/diagnostic/agent.md` | **REJECTED** | 5 real findings (Gate A strength + Step 11 decision-log + Trigger 8 mismap + sentinel + validate.sh gap) | `20260524T101934Z-19923` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:145:| 2 | `agents/recruitment/janitor/agent.md` | **REJECTED** | ~5-7 real findings (count regex 56 inflated by nested lists) | `20260524T102050Z-21293` |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:20:**Counter:** Codex is applying the Day-7 single-sentence-test Q3 quality gate ("ATS decided + auth cleared") as if it were a Week-1 implementation gate. The Q3 gate is correct as a closing-of-Week-0 gate per master brief §6 line 502, and Q3 = NO is exactly why Week 0 EXTENDS per the Day-7 single-sentence-test result. But the Q3 gate governs **named v1.0 agent-build slices** (Diagnostic W3-4, Janitor W5, etc.), NOT Week-1 prerequisite code.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:42:| Janitor build (W5) | A+B Accepted (commercial conversations complete) | Pending |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:67:which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:68:build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:86:**Resolution update (2026-05-22):** [x] Incorporated via "Counter-argued + sharpen wording." The source decision now encodes the prereq-code-only gate and the W5 Janitor auth gate explicitly.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:143:- Q1 = YES, Q3 = NO (accepted) → Week 0 closes by founder discretion; Week 1 starts with Risk #2 elevated; Diagnostic W3-4 begins under accepted risk; Janitor W5 contingent on Q3 clearing by then.
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:62:- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:105:| Janitor W5 build | A+B Accepted (commercial conversations complete) | Pending |
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:306:| Janitor Candidate sweep | Polling (full-table scan per sweep) | Nightly 02:00 | Initial sweep is bounded by per-tenant Candidate count; subsequent sweeps use `dateLastModified` filter to limit to changes-since-last-sweep |
docs/decisions/bullhorn-integration-path.md:307:| Janitor Note / ClientCorporation / JobOrder sweep | Polling | Nightly 02:00 | Same `dateLastModified` filter pattern |
docs/decisions/bullhorn-integration-path.md:334:| Janitor (nightly sweep) | 200-400 during active sweep window (concentrated 1-2 hour burst) | Burst-tolerant; bounded by tenant Candidate-count and `dateLastModified` filter efficiency |
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:460:**Reduction trigger 2 (Medium → Low):** first Bullhorn write lands cleanly in Week 3-4 Janitor agent build (the master brief §12 / Ultraplan §10 row #2 tripwire test "core read endpoints working" passes).
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |

exec
/bin/zsh -lc "rg --files | rg '("'^|/)(vertical-schema.*yaml|autosend.*yaml|escalation-codes.md|voice-loader.sh|v1.0-kill-criterion.md|sequencing-target.md|bullhorn-integration-path.md|ADR-003|ADR-004|ADR-005|v0.2-to-v0.3.sql)$'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/voice-loader.sh
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
docs/decisions/v1.0-kill-criterion.md
docs/decisions/sequencing-target.md
docs/decisions/bullhorn-integration-path.md
legacy/v1/docs/phase-2-agent-suite/_shared/escalation-codes.md

codex
The first pass found the core local files, but the master brief and ULTRAPLAN filenames differ from the cited names. I’m locating those now and checking line-level claims that could affect the verdict.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '115,130p;185,200p;232,255p;365,380p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   379	        source: Bullhorn.JobOrder.salaryUnit (range parsing)
   380	      day_rate_min:

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '120,135p;178,192p;360,385p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '145,175p;285,300p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   145	    agent: diagnostic
   146	    reason: "Internal audit row written by cleanup.sh at end of normal-completion run. Records cache-purge status + workspace cleanup; no external comms."
   147	    irreversible: false
   148	
   149	  # ───────────────────────────────────────────────────────────
   150	  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
   151	  # ───────────────────────────────────────────────────────────
   152	
   153	  bullhorn_candidate_dedupe:
   154	    tier: yellow
   155	    agent: janitor
   156	    sample_rate: 10
   157	    reason: "Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review"
   158	    irreversible: false
   159	
   160	  bullhorn_field_backfill:
   161	    tier: yellow
   162	    agent: janitor
   163	    sample_rate: 10
   164	    reason: "Fills missing canonical schema fields from Companies House or LinkedIn enrichment; reversible PATCH; high-volume; source provenance logged in payload"
   165	    irreversible: false
   166	
   167	  bullhorn_note_attach:
   168	    tier: yellow
   169	    agent: janitor
   170	    sample_rate: 20
   171	    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
   172	    irreversible: false
   173	
   174	  bullhorn_note_append_summary:
   175	    tier: yellow
   285	    tier: orange
   286	    agent: sourcing-scout
   287	    timeout: PT4H
   288	    reason: "Outbound InMail (paid credit); cost-per-send; customer-facing"
   289	    irreversible: true
   290	
   291	  bullhorn_placement_terminate:
   292	    tier: orange
   293	    agent: janitor
   294	    timeout: PT4H
   295	    reason: "Marks placement as terminated; commercial/legal implications; reversible only via support ticket"
   296	    irreversible: false
   297	
   298	  # ───────────────────────────────────────────────────────────
   299	  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
   300	  # ───────────────────────────────────────────────────────────

exec
/bin/zsh -lc "rg --files | rg -i '(master.*brief|ultraplan|ultra.*plan|brief.*md)"'$'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/build-brief/00-MASTER-BRIEF.md
docs/_supplementary/planning-phase-brief.md
legacy/v1/docs/phase-5-business-legal/marketing/trademark-filing-brief.md
legacy/v1/docs/phase-0-strategic/intelforce-planning-phase-brief.md

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
    77	  raw_payload        JSONB,
    78	
    79	  CONSTRAINT cct_match_status_valid CHECK (
    80	    match_status IN ('unmatched', 'matched', 'ambiguous')
    81	  ),
    82	  CONSTRAINT cct_bank_provider_valid CHECK (
    83	    bank_provider IN ('truelayer', 'plaid_uk', 'open_banking_direct')
    84	  ),
    85	  CONSTRAINT cct_match_confidence_range CHECK (
    86	    match_confidence IS NULL OR (match_confidence >= 0.00 AND match_confidence <= 1.00)
    87	  ),
    88	  CONSTRAINT cct_tenant_transaction_unique UNIQUE (tenant_slug, bank_provider, transaction_id)
    89	);
    90	
    91	CREATE INDEX IF NOT EXISTS idx_cct_tenant_posted
    92	  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
    93	
    94	CREATE INDEX IF NOT EXISTS idx_cct_tenant_unmatched
    95	  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
    96	  WHERE match_status IN ('unmatched', 'ambiguous');
    97	
    98	-- RLS isolation per Day-4 §6.3 pattern
    99	ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
   100	ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
   101	
   102	CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
   103	  FOR ALL TO ifos_app
   104	  USING (tenant_slug = current_setting('app.current_tenant', true));
   105	
   106	GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
   107	GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
   108	
   109	-- ----------------------------------------------------------------------------
   110	-- §3 — Create cash_conductor_invoices table (RLS-isolated)
   111	-- ----------------------------------------------------------------------------
   112	
   113	CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
   114	  id                       BIGSERIAL PRIMARY KEY,
   115	  tenant_slug              TEXT NOT NULL,
   116	  invoice_id               TEXT NOT NULL,
   117	  accounting_provider      TEXT NOT NULL,
   118	  invoice_number           TEXT,
   119	  issued_at                TIMESTAMPTZ NOT NULL,
   120	  due_at                   TIMESTAMPTZ NOT NULL,
   121	  amount_total             NUMERIC(15, 2) NOT NULL,
   122	  amount_paid              NUMERIC(15, 2) NOT NULL DEFAULT 0,
   123	  currency                 TEXT NOT NULL DEFAULT 'GBP',
   124	  status                   TEXT NOT NULL DEFAULT 'open',
   125	  client_contact_id        TEXT,
   126	  client_billing_email     TEXT,
   127	  last_chase_position      INT NOT NULL DEFAULT 0,
   128	  last_chase_sent_at       TIMESTAMPTZ,
   129	  ingested_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
   130	  raw_payload              JSONB,
   131	
   132	  CONSTRAINT cci_status_valid CHECK (
   133	    status IN ('open', 'partial', 'paid', 'overdue', 'cancelled', 'voided')
   134	  ),
   135	  CONSTRAINT cci_provider_valid CHECK (
   136	    accounting_provider IN ('xero', 'quickbooks', 'sage')
   137	  ),
   138	  CONSTRAINT cci_chase_position_range CHECK (
   139	    last_chase_position >= 0 AND last_chase_position <= 4
   140	  ),
   141	  CONSTRAINT cci_amount_paid_non_negative CHECK (
   142	    amount_paid >= 0 AND amount_paid <= amount_total
   143	  ),
   144	  CONSTRAINT cci_tenant_provider_invoice_unique UNIQUE (tenant_slug, accounting_provider, invoice_id)
   145	);
   146	
   147	CREATE INDEX IF NOT EXISTS idx_cci_tenant_due
   148	  ON cash_conductor_invoices (tenant_slug, due_at);
   149	
   150	CREATE INDEX IF NOT EXISTS idx_cci_tenant_overdue
   151	  ON cash_conductor_invoices (tenant_slug, status, due_at)
   152	  WHERE status IN ('open', 'partial', 'overdue');
   153	
   154	CREATE INDEX IF NOT EXISTS idx_cci_tenant_chase
   155	  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
   156	  WHERE last_chase_position BETWEEN 1 AND 3;
   157	
   158	ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
   159	ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
   160	
   161	CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
   162	  FOR ALL TO ifos_app
   163	  USING (tenant_slug = current_setting('app.current_tenant', true));
   164	
   165	GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
   166	GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
   167	
   168	-- ----------------------------------------------------------------------------
   169	-- §4 — Replace JSONB validation function for entities.data (adds v0.3 keys)
   170	-- ----------------------------------------------------------------------------
   171	--
   172	-- The v0.2 migration installed validate_voice_scores trigger which validates
   173	-- the 6 voice-score keys. v0.3 extends validation to cover the 14 new keys
   174	-- for candidate, contact, brief, placement, opportunity. We replace the
   175	-- function in place (CREATE OR REPLACE) so the v0.2 voice-score checks remain.
   176	
   177	CREATE OR REPLACE FUNCTION validate_entities_data_v0_3()
   178	RETURNS TRIGGER AS $$
   179	DECLARE
   180	  d JSONB := NEW.data;
   181	  et TEXT := NEW.entity_type;
   182	  arr_item JSONB;
   183	BEGIN
   184	  -- v0.2 voice-score keys (forwarded; preserves v0.2 [0.0, 1.0] range check)
   185	  IF d ? 'voice_classifier_score' THEN
   186	    IF jsonb_typeof(d->'voice_classifier_score') NOT IN ('number', 'null') THEN
   187	      RAISE EXCEPTION 'voice_classifier_score must be number or null';
   188	    END IF;
   189	    IF d->'voice_classifier_score' != 'null'::jsonb THEN
   190	      IF (d->>'voice_classifier_score')::numeric < 0.0
   191	         OR (d->>'voice_classifier_score')::numeric > 1.0 THEN
   192	        RAISE EXCEPTION 'voice_classifier_score out of [0.0, 1.0] range: %', d->>'voice_classifier_score';
   193	      END IF;
   194	    END IF;
   195	  END IF;
   196	
   197	  IF d ? 'voice_drift_at_close' THEN
   198	    IF jsonb_typeof(d->'voice_drift_at_close') NOT IN ('number', 'null') THEN
   199	      RAISE EXCEPTION 'voice_drift_at_close must be number or null';
   200	    END IF;
   201	    IF d->'voice_drift_at_close' != 'null'::jsonb THEN
   202	      IF (d->>'voice_drift_at_close')::numeric < 0.0
   203	         OR (d->>'voice_drift_at_close')::numeric > 1.0 THEN
   204	        RAISE EXCEPTION 'voice_drift_at_close out of [0.0, 1.0] range: %', d->>'voice_drift_at_close';
   205	      END IF;
   206	    END IF;
   207	  END IF;
   208	
   209	  -- v0.3 candidate fields
   210	  IF et = 'candidate' THEN
   211	    IF d ? 'employment_type' THEN
   212	      IF (d->>'employment_type') NOT IN (
   213	        'perm', 'contract', 'contract_inside_ir35', 'contract_outside_ir35', 'day_rate', 'hybrid'
   214	      ) THEN
   215	        RAISE EXCEPTION 'employment_type invalid: %', d->>'employment_type';
   216	      END IF;
   217	    END IF;
   218	
   219	    IF d ? 'key_skills' THEN
   220	      IF jsonb_typeof(d->'key_skills') != 'array' THEN

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,610p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '780,845p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   780	      timezone:
   781	        type: string
   782	        notes: IANA timezone identifier
   783	      weekday_start:
   784	        type: string
   785	        notes: HH:MM 24-hour format
   786	      weekday_end:
   787	        type: string
   788	        notes: HH:MM 24-hour format
   789	      weekend_send_enabled:
   790	        type: boolean
   791	    notes: |
   792	      Per-tenant outbound sending hours. Concierge respects when scheduling
   793	      orange-tier sends.
   794	
   795	  janitor_dedup_threshold:
   796	    type: number
   797	    required: false
   798	    default: 0.85
   799	    range: [0.75, 0.95]
   800	    set_by: [tenant-admin]
   801	    read_by: [janitor]
   802	    notes: |
   803	      Per-tenant dedup confidence threshold for candidate merges. v1.0 default
   804	      0.85 per ULTRAPLAN A2 line 510. Tenant-admin override range [0.75, 0.95]
   805	      via the wizard. The migration validator (v0.2-to-v0.3.sql §5 allowlist +
   806	      type-validation trigger extension added in R19) enforces both the
   807	      allowlist membership and the [0.75, 0.95] range. Schema declaration
   808	      added Day-20 W4 bilateral pass closing Janitor R11 Codex Finding 4.
   809	
   810	  blocked_recipients:
   811	    type: array
   812	    items:
   813	      type: string
   814	    required: false
   815	    default: []
   816	    set_by: [tenant-admin, janitor]
   817	    read_by: [concierge, sourcing-scout, cash-conductor, janitor]
   818	    notes: |
   819	      Per-tenant DNC (do not contact) list. v1.0 canonical source for outbound
   820	      send refusal (autosend-safety-policy §5 red-tier action_type
   821	      `send_to_blocked_recipient`) and pre-outbound sourcing filter (Sourcing
   822	      Scout §4 Step 8). Per ADR-002 vault/Postgres split — structured state in
   823	      Postgres, NOT vault markdown. Pre-v0.3 origin (the migration validator
   824	      `v0.2-to-v0.3.sql §5 allowlist` has accepted this key since v0.1); the
   825	      schema declaration in v0.3 supplement is added Day-20 W4 bilateral pass
   826	      closing Sourcing Scout R8 Codex Finding 1 (the key was load-bearing
   827	      across 4 agents but undeclared in any YAML).
   828	
   829	  janitor_last_run:
   830	    type: timestamp
   831	    required: false
   832	    set_by: janitor
   833	    read_by: [janitor]
   834	    notes: |
   835	      Janitor nightly cron updates at session-close (Step 12). Next run queries
   836	      Bullhorn for entities created/modified since this timestamp. The migration
   837	      validator (v0.2-to-v0.3.sql §5 allowlist) already accepts this key; this
   838	      declaration is the canonical schema authority added in W4 bilateral pass
   839	      (Day-20) closing Janitor R11 Codex Finding 4.
   840	
   841	  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   842	  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not
   843	  # declare this config key; the W4 ADR will introduce both the field
   844	  # and its consumer at the same time. Including it in v0.3 without an
   845	  # active consumer would be speculative schema.

exec
/bin/zsh -lc "rg --files | rg -i 'ultra'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/specs/ULTRAPLAN.md
packages/harness/cortextos/community/skills/local-ultrareview/SKILL.md

exec
/bin/zsh -lc "nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '70,82p;158,166p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '498,515p;525,545p;555,572p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '300,390p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '70,95p;135,165p;223,245p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   300	      END IF;
   301	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'deal_breakers') LOOP
   302	        IF jsonb_typeof(arr_item) != 'string' THEN
   303	          RAISE EXCEPTION 'deal_breakers items must be strings';
   304	        END IF;
   305	      END LOOP;
   306	    END IF;
   307	  END IF;
   308	
   309	  -- v0.3 placement fields
   310	  IF et = 'placement' THEN
   311	    IF d ? 'placement_status' THEN
   312	      IF (d->>'placement_status') NOT IN (
   313	        'pending_start', 'active', 'completed', 'terminated_early', 'on_hold', 'cancelled'
   314	      ) THEN
   315	        RAISE EXCEPTION 'placement_status invalid: %', d->>'placement_status';
   316	      END IF;
   317	    END IF;
   318	
   319	    IF d ? 'week_1_status_vault_path' THEN
   320	      IF jsonb_typeof(d->'week_1_status_vault_path') NOT IN ('string', 'null') THEN
   321	        RAISE EXCEPTION 'week_1_status_vault_path must be string or null';
   322	      END IF;
   323	      IF d->>'week_1_status_vault_path' IS NOT NULL
   324	         AND d->>'week_1_status_vault_path' !~ '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$' THEN
   325	        RAISE EXCEPTION 'week_1_status_vault_path must match vault-path pattern (got %)', d->>'week_1_status_vault_path';
   326	      END IF;
   327	      IF d->>'week_1_status_vault_path' IS NOT NULL
   328	         AND length(d->>'week_1_status_vault_path') > 200 THEN
   329	        RAISE EXCEPTION 'week_1_status_vault_path exceeds 200 chars';
   330	      END IF;
   331	    END IF;
   332	
   333	    IF d ? 'satisfaction_signal' THEN
   334	      IF (d->>'satisfaction_signal') NOT IN ('positive', 'neutral', 'negative', 'unclear') THEN
   335	        RAISE EXCEPTION 'satisfaction_signal invalid: %', d->>'satisfaction_signal';
   336	      END IF;
   337	    END IF;
   338	  END IF;
   339	
   340	  -- v0.3 opportunity fields
   341	  IF et = 'opportunity' THEN
   342	    IF d ? 'headcount_growth_signal_text' THEN
   343	      IF jsonb_typeof(d->'headcount_growth_signal_text') NOT IN ('string', 'null') THEN
   344	        RAISE EXCEPTION 'headcount_growth_signal_text must be string or null';
   345	      END IF;
   346	      IF d->>'headcount_growth_signal_text' IS NOT NULL
   347	         AND length(d->>'headcount_growth_signal_text') > 280 THEN
   348	        RAISE EXCEPTION 'headcount_growth_signal_text exceeds 280 chars';
   349	      END IF;
   350	    END IF;
   351	
   352	    IF d ? 'hiring_velocity_band' THEN
   353	      IF (d->>'hiring_velocity_band') NOT IN ('slow', 'moderate', 'fast', 'urgent', 'unknown') THEN
   354	        RAISE EXCEPTION 'hiring_velocity_band invalid: %', d->>'hiring_velocity_band';
   355	      END IF;
   356	    END IF;
   357	
   358	    IF d ? 'decision_window_text' THEN
   359	      IF jsonb_typeof(d->'decision_window_text') NOT IN ('string', 'null') THEN
   360	        RAISE EXCEPTION 'decision_window_text must be string or null';
   361	      END IF;
   362	      IF d->>'decision_window_text' IS NOT NULL
   363	         AND length(d->>'decision_window_text') > 280 THEN
   364	        RAISE EXCEPTION 'decision_window_text exceeds 280 chars';
   365	      END IF;
   366	    END IF;
   367	  END IF;
   368	
   369	  RETURN NEW;
   370	END;
   371	$$ LANGUAGE plpgsql;
   372	
   373	-- Rebind the trigger to the new function (drops + recreates)
   374	DROP TRIGGER IF EXISTS validate_voice_scores ON entities;
   375	DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
   376	
   377	CREATE TRIGGER validate_entities_data_v0_3
   378	  BEFORE INSERT OR UPDATE ON entities
   379	  FOR EACH ROW
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

 succeeded in 0ms:
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
   158	### Trigger 8 — GATE-B-REVENUE-UPLIFT (KILL)
   159	
   160	**Threshold:** After 3 completed pilots (defined as: pilot ran for ≥90 days with active agent fleet and quarterly Gate B revenue measurement), average Gate B revenue uplift per tenant <£20k/year.
   161	
   162	**Owner:** Founder; assessed at end of each pilot.
   163	
   164	**Source:** Master brief §6 Day 5 line 486 — canonical example trigger from master brief.
   165	
   166	**Action:** KILL. Rationale: the wedge does not produce demonstrable ROI at the threshold required to sustain v1.0 commercially. £20k/year/tenant is the breakeven floor — below this, IFOS cannot fund continued operation at v1.0 pricing.

 succeeded in 0ms:
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
   525	- **Gate B target:** 90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%
   526	- **Build complexity:** **M** (1 week) — the structured field mapping is per-firm config, not code
   527	- **Gotchas:** Tacit-note extraction is the hard part. Start with a small taxonomy (5–10 tacit-note types) and expand. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
   528	
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
   543	#### A5. Sourcing Scout (daytime form) — request-response sourcing
   544	
   545	- **Build wave:** v1.0 (week 8–9)
   555	- **Gotchas:** LinkedIn rate limits via Proxycurl. Reed/CV-Library have separate auth and separate result schemas. Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it.
   556	
   557	#### A6. The Concierge — no candidate ghosted
   558	
   559	- **Build wave:** v1.0 (week 9–10)
   560	- **Always-on?** Tier 1 — persistent state across the candidate lifecycle
   561	- **Trigger type:** ATS state changes (candidate moved to interview, rejected, placed, etc.) + cron sweep for time-elapsed nurture events
   562	- **CortexOS primitives required:** Persistent PTY (#1), context rotation (#2), approval gates (#4), Telegram surface (#5)
   563	- **MCP tools required:** Bullhorn (read for state, write for activity log), Microsoft Graph / Gmail (send), AgentMail (optional for agent-identity sends)
   564	- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
   565	- **External APIs:** Microsoft Graph or Google Workspace per tenant; AgentMail for v1.1+
   566	- **Gate A:** voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82 per escalation_position); correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
   567	- **Gate B target:** <5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate (per ADR-007)
   568	- **Build complexity:** **XL** (4 weeks) — this is the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)
   569	- **Gotchas:** Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks. Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship.
   570	
   571	### 8.2 v1.1 agents (seven, in build order)
   572	

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
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '35,75p;155,180p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "Composio|AgentMail|packages/harness/cortextos|kb-|brain system|stock KB|decision_log|recent_edit|Postgres|/vault" agents/recruitment/janitor/agent.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    35	#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
    36	#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
    37	#   - notes: anything entity-specific worth flagging
    38	#
    39	# Field types follow JSON Schema conventions: type = string | integer | number | boolean | array | object | (ISO 8601) timestamp / date
    40	# `required: true` means the entity cannot be persisted without this field set; `required: false` means nullable.
    41	# `source: Bullhorn.<Entity>.<field>` means sourced from Bullhorn at ingest;
    42	# `source: IFOS-derived` means computed/written by IFOS code (e.g., voice_classifier_score).
    43	# ============================================================================
    44	
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
   155	      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
   156	    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
   157	    v1_0_agent_access:
   158	      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
   159	      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
   160	      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
   161	      - Concierge (R+W — lifecycle state; week-1/month-1 check-ins differ for contractors per Product Spec §2.2 R7)
   162	    canonical_fields:
   163	      # Inherits candidate fields conceptually; below are the additional contractor-specific fields.
   164	      # Full implementation: adapter layer materialises both candidate-overlap fields AND contractor-specific fields in entities.data.
   165	      # Schema notes: see candidate canonical_fields for the shared base set.
   166	      bullhorn_id:
   167	        type: integer
   168	        required: true
   169	        source: Bullhorn.Candidate.id
   170	        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
   171	      first_name:
   172	        type: string
   173	        required: true
   174	        source: Bullhorn.Candidate.firstName
   175	      last_name:
   176	        type: string
   177	        required: true
   178	        source: Bullhorn.Candidate.lastName
   179	      email:
   180	        type: string

 succeeded in 0ms:
4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority. R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4. R19 fixes (today): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice.
17:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`.
53:Located at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`. Eight sections:
60:| 4 | **Tacit-note coverage** | Notes harvested from `recent_edit` table rows with `resolution='approved_after_edit'` (per v0.2-supplement.yaml recent_edit definition; v0.3 supplement §2a grants Janitor R access); attached to relevant Bullhorn entities; coverage rate over the 30-day window |
74:Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.
138:   → query the `recent_edit` v0.2 table directly (per vertical-schema.v0.2-supplement.yaml
139:     recent_edit definition; v0.3 supplement §2a grants Janitor R access):
140:     SELECT FROM recent_edit WHERE resolved_at > now() - interval '30 days'
142:   → join to decision_log only if action-context lookups needed
159:   → SELECT from decision_log WHERE agent_name='janitor' AND created_at >
163:   → write to /vault/<tenant>/janitor-reports/day-30-<ISO-date>.md
249:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '390,470p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   411	    RETURN NEW;
   412	  END IF;
   413	
   414	  FOR k IN SELECT jsonb_object_keys(c) LOOP
   415	    IF NOT (k = ANY(allowed_keys)) THEN
   416	      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
   417	    END IF;
   418	  END LOOP;
   419	
   420	  -- v0.3 type validations
   421	  -- diagnostic_per_claim_sample_rate DEFERRED to W4-polish ADR; not validated
   422	  -- in v0.3 (also not in allowlist above, so it would fail-fast anyway)
   423	
   424	  IF c ? 'concierge_send_window' THEN
   425	    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
   426	      RAISE EXCEPTION 'concierge_send_window must be object';
   427	    END IF;
   428	    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
   429	      RAISE EXCEPTION 'concierge_send_window must include timezone';
   430	    END IF;
   431	    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
   432	       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
   433	      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
   434	    END IF;
   435	    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
   436	       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
   437	      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
   438	    END IF;
   439	  END IF;
   440	
   441	  -- v0.3 timestamp-typed keys
   442	  IF c ? 'cash_conductor_last_run' THEN
   443	    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
   444	      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
   445	    END IF;
   446	  END IF;
   447	
   448	  IF c ? 'concierge_last_poll' THEN
   449	    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
   450	      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
   451	    END IF;
   452	  END IF;
   453	
   454	  -- v0.3.1 (Day-20 bilateral pass) — declarations canonicalised in supplement §4
   455	  -- janitor_dedup_threshold: number in [0.75, 0.95] per supplement default 0.85
   456	  IF c ? 'janitor_dedup_threshold' THEN
   457	    IF jsonb_typeof(c->'janitor_dedup_threshold') != 'number' THEN
   458	      RAISE EXCEPTION 'janitor_dedup_threshold must be number';
   459	    END IF;
   460	    IF (c->>'janitor_dedup_threshold')::numeric < 0.75
   461	       OR (c->>'janitor_dedup_threshold')::numeric > 0.95 THEN
   462	      RAISE EXCEPTION 'janitor_dedup_threshold out of [0.75, 0.95] range: %', c->>'janitor_dedup_threshold';
   463	    END IF;
   464	  END IF;
   465	
   466	  -- janitor_last_run: ISO-8601 timestamp string or null
   467	  IF c ? 'janitor_last_run' THEN
   468	    IF jsonb_typeof(c->'janitor_last_run') NOT IN ('string', 'null') THEN
   469	      RAISE EXCEPTION 'janitor_last_run must be ISO-8601 timestamp string or null';
   470	    END IF;

exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Janitor — the wedge agent
     2	
     3	**Status:** Proposed.
     4	**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority. R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4. R19 fixes (today): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice.
     5	**Date:** 2026-05-24.
     6	**Author:** Founder (Maddox) + Claude Code.
     7	**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
     8	**Build complexity:** L (2 weeks) per ULTRAPLAN A2 line 512.
     9	**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.1.
    10	
    11	---
    12	
    13	## §1 — Output contract (one-paragraph screenshot)
    14	
    15	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    16	
    17	> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`.
    18	
    19	---
    20	
    21	## §2 — Invocation surface
    22	
    23	### Cron (v1.0)
    24	
    25	```bash
    26	# /etc/cron.daily/ifos-janitor → calls this script per tenant
    27	0 2 * * * sudo -u ifos_user /usr/local/bin/ifos-janitor.sh --tenant <slug>
    28	```
    29	
    30	Resolved by cortextOS daemon → spawns Janitor in Tier-2 batch mode (no persistent PTY). Typical runtime per tenant: 15-45 min depending on Bullhorn corpus size.
    31	
    32	### Manual trigger (v1.0 — operator convenience)
    33	
    34	```bash
    35	ifosctl janitor --tenant <slug> [--dry-run] [--report-only]
    36	```
    37	
    38	`--dry-run` reports what WOULD be written without touching Bullhorn. `--report-only` regenerates the day-30 report without doing dedup/enrichment passes (used post-incident for manual report regeneration).
    39	
    40	### v1.1+ surfaces (deferred)
    41	
    42	- Brain UI "Run Janitor now" button → triggers via internal API
    43	- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold` — declared in `vertical-schema.v0.3-supplement.yaml §4 tenant_adapters_config_additions.janitor_dedup_threshold`; enforced by `migrations/v0.2-to-v0.3.sql §5` validator allowlist)
    44	
    45	---
    46	
    47	## §3 — Output shape
    48	
    49	Two outputs per run. Both are load-bearing artefacts.
    50	
    51	### Output 1 — Day-30 Markdown report
    52	
    53	Located at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`. Eight sections:
    54	
    55	| # | Section | Content |
    56	|---|---|---|
    57	| 1 | **Record counts** | Total candidates / contractors / clients / contacts / placements / opportunities before + after this run; deltas per entity type |
    58	| 2 | **Dedup pairs** | List of duplicate candidate pairs identified this run (confidence ≥0.85 only); for each pair: candidate `bullhorn_id` per vertical-schema.yaml candidate entity, match dimensions (name + email + phone + LinkedIn), confidence score, action taken (merged vs flagged-for-review) |
    59	| 3 | **Field-completeness deltas** | Per entity-type table: which fields were filled in (e.g., candidate.location, contractor.day_rate); source of the backfill (Companies House lookup, LinkedIn enrichment, derivation from related entities) |
    60	| 4 | **Tacit-note coverage** | Notes harvested from `recent_edit` table rows with `resolution='approved_after_edit'` (per v0.2-supplement.yaml recent_edit definition; v0.3 supplement §2a grants Janitor R access); attached to relevant Bullhorn entities; coverage rate over the 30-day window |
    61	| 5 | **Agent vs. consultant attribution** | Rows attributed to Janitor automated work vs consultant manual entry; supports the day-30 before/after narrative |
    62	| 6 | **Gate-B metric** | TWO independent thresholds per ULTRAPLAN A2 line 511 verbatim: dedup improvement ≥15% AND field-completeness improvement ≥10%. Both must pass. NOT a composite score — that would let one threshold cover for the other. |
    63	| 7 | **Exception list** | Failed writes (Bullhorn 4xx/5xx, FK violations); rate-limit hits; dedup proposals flagged for review (confidence between 0.7-0.85); operator action items |
    64	| 8 | **Executive summary** | 200-word narrative suitable for forwarding to the tenant's hiring leader; cites top-3 cleanup wins; quantifies time saved (hours of consultant data-entry work avoided) |
    65	
    66	### Output 2 — Bullhorn writes (yellow tier)
    67	
    68	Three write categories. Action types map to `agents/_shared/autosend-policy.yaml` — existing entries are used as-is; new entries are flagged for catalogue addition at W5 build (per `review-agent-bundle.md` §1 row §6 flag-for-addition pattern):
    69	
    70	1. **Candidate merge** (`PUT /Candidate/{primary_id}` + cascade) — only when confidence ≥0.85 per Gate A; no merge if either candidate had Bullhorn activity in last 90 days without explicit review flag (per ULTRAPLAN A2 line 510 verbatim). Action type: **`bullhorn_candidate_dedupe`** (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW action_types; yellow tier; sample_rate: 10).
    71	2. **Field backfill** (`PATCH /Candidate/{id}` or `/Client/{id}`) — fills missing canonical schema fields (per `vertical-schema.yaml`): `candidate.location` (line 124), `client.industry` (line 238), `client.size_employees` (line 243), `client.companies_house_number` (line 252), `contractor.day_rate_min/day_rate_max` (lines 193-197), `brief.salary_min/salary_max` (lines 371-376) from Companies House (for clients) or LinkedIn/derivation (for candidates). Sources logged in payload. Action type: **`bullhorn_field_backfill`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 10).
    72	3. **Tacit-note attach** (`POST /Note` linked to entity) — narrative summary of consultant edits + decision-log resolutions over the 30-day window. Action type: **`bullhorn_note_attach`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 20).
    73	
    74	Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.
    75	
    76	---
    77	
    78	## §4 — Workflow
    79	
    80	12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
    81	
    82	```
    83	0. Session start
    84	   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice corpus
    85	     (used for tacit-note attribution) + recent edits (for note harvest)
    86	   → hh_decision_trigger("session_start", "janitor nightly cron")
    87	
    88	1. Bullhorn auth refresh
    89	   → bullhorn.refresh_access_token() per per-agent 8-min refresh loop
    90	     (bullhorn-integration-path.md §4.5)
    91	   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
    92	
    93	2. Bullhorn entity scan (read-only)
    94	   → enumerate candidates + contractors + clients + contacts + placements +
    95	     opportunities created/modified since last Janitor run (last_run_at in
    96	     tenant_adapters.config.janitor_last_run — declared in vertical-schema
    97	     v0.3 supplement §4 tenant_adapters_config_additions.janitor_last_run;
    98	     enforced by migrations/v0.2-to-v0.3.sql §5 validator allowlist)
    99	   → hh_decision_output("janitor_scan", "tenant:<slug>", "<N> entities scanned")
   100	   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per ESC_RATE_LIMIT_HIT catalogue §2.5 standard handling)
   101	
   102	3. Dedup pass — candidate entity type
   103	   → fuzzy-match across (name, email, phone, linkedin_url) tuples
   104	   → compute confidence per pair: name × 0.3 + email × 0.4 + phone × 0.2 + linkedin × 0.1
   105	   → discard pairs <0.85 confidence (per Gate A)
   106	   → discard pairs where EITHER candidate has Bullhorn activity in last 90d
   107	     (per ULTRAPLAN A2 line 510 verbatim)
   108	   → batch into proposed-merge list (in-memory intermediate; not persisted —
   109	     hh_decision_action emitted at Step 9 when each merge actually writes)
   110	
   111	4. Dedup pass — contractor entity type
   112	   → same algorithm as candidates; separate entity_type per Q1 Day-6 resolution
   113	     (vertical-schema.yaml §1)
   114	
   115	5. Field completeness audit (canonical field names per vertical-schema.yaml)
   116	   → for each entity, check critical fields: candidate.location (line 124),
   117	     client.industry (line 238), client.size_employees (line 243),
   118	     contractor.day_rate_min/day_rate_max (lines 193-197),
   119	     brief.salary_min/salary_max (lines 371-376)
   120	   → identify missing-field rows
   121	   → batch enrichment calls
   122	   → hh_decision_output("field_completeness_audit", tenant, "<N> missing-field rows")
   123	
   124	6. Companies House enrichment (clients only)
   125	   → companies_house.search(client.name per vertical-schema.yaml line 235) → CRN →
   126	     profile → fill canonical schema fields client.industry (line 238),
   127	     client.companies_house_number (line 252)
   128	   → 7-day cache per tools.yaml; rate-limit budget shared with Diagnostic
   129	   → ESC_RATE_LIMIT_HIT on 429
   130	
   131	7. LinkedIn enrichment (candidates; v1.1 via Proxycurl)
   132	   → at v1.0: skipped (LinkedIn deep data deferred to W4 polish; Proxycurl
   133	     signup commercial decision)
   134	   → at v1.1: linkedin.profile_fetch(candidate.linkedin_url) → location +
   135	     current_company → write back
   136	
   137	8. Tacit-note harvest
   138	   → query the `recent_edit` v0.2 table directly (per vertical-schema.v0.2-supplement.yaml
   139	     recent_edit definition; v0.3 supplement §2a grants Janitor R access):
   140	     SELECT FROM recent_edit WHERE resolved_at > now() - interval '30 days'
   141	     AND resolution='approved_after_edit' AND tenant_slug=$tenant
   142	   → join to decision_log only if action-context lookups needed
   143	   → group by target_entity_type (candidate / contractor / contact / brief / etc.)
   144	   → for each group, generate narrative summary via voice-classified LLM
   145	     (voice corpus + tone rules; ESC_VOICE_DRIFT if classifier <0.75)
   146	   → hh_decision_output("janitor_tacit_note_harvest", "tenant:<slug>",
   147	     "harvested:<N> rows; groups:<M> entity-types; narrative_drafts:<K>")
   148	   → on classifier fail after retries: hh_decision_action("validate_gate_a_fail",
   149	     "tenant:<slug>", payload_hash, "ESC_VOICE_DRIFT; classifier_score:<N>")
   150	
   151	9. Bullhorn write batch (yellow tier — spot-check sampling)
   152	   → for each proposed merge / backfill / note: emit hh_decision_action with
   153	     tier='yellow'; spot-check sample rate per autosend-policy.yaml row
   154	   → atomic per-write transaction (BEGIN/COMMIT)
   155	   → on 4xx: emit ESC_BULLHORN_WRITE_FAIL; skip; continue
   156	   → on 5xx: emit ESC_BULLHORN_WRITE_FAIL; retry once with 30s backoff
   157	
   158	10. Day-30 report assembly
   159	   → SELECT from decision_log WHERE agent_name='janitor' AND created_at >
   160	     now() - interval '30 days' AND tenant_slug=$tenant
   161	   → group by action_type; tally success/fail; compute Gate-B metric
   162	   → 8-section Markdown report (per §3 above)
   163	   → write to /vault/<tenant>/janitor-reports/day-30-<ISO-date>.md
   164	   → hh_decision_output("day_30_report", "<path>", "Gate-B score: <N>")
   165	
   166	11. Operator notification (Telegram)
   167	   → if Gate-B target met: green-tier notification with summary
   168	   → if Gate-B target missed: yellow-tier notification + 200-char executive
   169	     summary suggesting consultant follow-up
   170	   → hh_decision_action("operator_notify_telegram", "tenant:<slug>",
   171	     notification_hash, "gate_b_state:met|missed; chars:<N>")
   172	
   173	12. Session close
   174	   → update tenant_adapters.config.janitor_last_run = now()
   175	   → hh_decision_action("janitor_run_complete", "tenant:<slug>", payload_hash, payload_preview)
   176	   → exit code 0 (or 1 if BOTH Gate-B thresholds missed for 3 consecutive runs per §5 + catalogue → ESC_GATE_B_MISS)
   177	```
   178	
   179	---
   180	
   181	## §5 — Gates
   182	
   183	### Gate A — validate.sh (hard-fail before action)
   184	
   185	Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Janitor's `validate.sh` enforces:
   186	
   187	- Bullhorn auth refresh succeeded in Step 1 (no stale token writes)
   188	- Every proposed merge has confidence ≥ 0.85 per ULTRAPLAN A2 line 510
   189	- No merge proposal where EITHER candidate has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim)
   190	- No field-backfill where source confidence <0.7 (CH 404 / LinkedIn empty / no derivation source)
   191	- Tacit-note narratives pass voice classifier ≥ 0.75
   192	- Bullhorn write batch size ≤ 100 per minute (rate-limit defensive)
   193	- No PII outside firm boundary in tacit-note narratives (regex pass)
   194	
   195	Gate A failure routing by class (per catalogue §2.5):
   196	- PII detected outside firm boundary → `ESC_PII_LEAKAGE_RISK` (blocking; operator + ifos_oncall per catalogue routing)
   197	- Tacit-note voice classifier <0.75 → `ESC_VOICE_DRIFT` (warn; operator_chat_id)
   198	- Tone-rule violations → `ESC_TONE_RULE_VIOLATION` (warn; operator_chat_id per catalogue §2.10)
   199	- Output-shape failures (section count, write-batch size, dedup confidence below threshold for action) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)
   200	
   201	`ESC_DUPLICATE_DETECTED` (catalogue §2.5) is NOT a Gate A failure code — per catalogue trigger it's for dedup confidence ≥0.85 review-required cases (SUCCESS path; Telegram approval gate). Sub-0.85 confidence pairs silently drop in Step 3 algorithm; no ESC fire. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (catalogue line 163) is NOT used by Janitor — reserved for vertical-schema field-constraint violations at write-time.
   202	
   203	### Gate B — Outcome threshold (success metric, not block)
   204	
   205	Per ULTRAPLAN A2 line 511 verbatim: **"day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement"**.
   206	
   207	Two independent thresholds (both must pass): dedup improvement ≥15% AND field-completeness improvement ≥10%. NOT a composite — composite would let one cover the other.
   208	
   209	Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
   210	
   211	Per catalogue `escalation-codes.md` ESC_GATE_B_MISS trigger (Janitor example: "dedup confidence <15% AND field-completeness uplift <10%"): `ESC_GATE_B_MISS` fires only when BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND completeness-improvement <10%) → flag for operator review (heuristic tuning may be needed; not a kill). Single-threshold misses are tracked in the day-30 report (§3 Output 1 row 6) and inform tenant-level quality review but do NOT fire ESC. Sensitivity choice: strict AND-trigger reduces false alarms; tightening to OR-trigger requires a catalogue amendment + re-ratification.
   212	
   213	---
   214	
   215	## §6 — Escalation codes
   216	
   217	All codes are registered in `agents/_shared/escalation-codes.md` (catalogue extended to 52 codes per `2026-05-24` bilateral disposition; see disagreement-doc + `catalogue(bilateral)` commit).
   218	
   219	| Code | Trigger | Severity | Routing |
   220	|---|---|---|---|
   221	| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   222	| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on merge/backfill/note write | warn | operator_chat_id |
   223	| `ESC_RATE_LIMIT_HIT` | Bullhorn or Companies House 429 | warn | operator_chat_id |
   224	| `ESC_VOICE_DRIFT` | Tacit-note narrative voice classifier <0.75 (after 3 retries) | warn | operator_chat_id |
   225	| `ESC_PII_LEAKAGE_RISK` | PII detected in tacit-note outside firm boundary | **blocking** | operator + ifos_oncall |
   226	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (section count or per-section citation missing in day-30 report) | warn | operator_chat_id |
   227	| `ESC_DUPLICATE_DETECTED` | Per catalogue §2.5 trigger: dedup confidence ≥0.85 review-required cases (SUCCESS path; Telegram approval gate fires). NOT a Gate A failure code. | warn | operator_chat_id (via Telegram approval gate per catalogue routing) |
   228	| `ESC_GATE_B_MISS` | Per catalogue trigger: per-agent local Gate B metric threshold missed. For Janitor: BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND field-completeness-improvement <10%) per catalogue `ESC_GATE_B_MISS` Janitor example. Single-threshold misses do NOT fire (per §5 Gate B). Catalogue routing: operator_chat_id | warn | operator_chat_id |
   229	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
   230	
   231	Janitor does NOT use:
   232	
   233	- `ESC_VOICE_DRIFT_TENANT` — fired by nightly voice-drift cron (per `escalation-codes.md` line 170-175 trigger: ≥N `ESC_VOICE_DRIFT` rows from same tenant in rolling 7d window). Janitor only fires the per-run `ESC_VOICE_DRIFT`; aggregate `_TENANT` rollup is handled by the canary not Janitor.
   234	- `ESC_AUTOSEND_BLOCKED` — that's for red-tier blocks (`escalation-codes.md` line 41); Janitor writes are yellow tier only
   235	- `ESC_BULLHORN_OAUTH_REVOKED` — escalated handling; Concierge owns the cross-agent escalation
   236	- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction
   237	
   238	---
   239	
   240	## §7 — Voice + tone constraints
   241	
   242	Step 8 (tacit-note narrative generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   243	
   244	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
   245	  - No identifying language about candidates beyond what's in their CV / Bullhorn record
   246	  - No commercial sensitive information (rates / placement fees / commission %)
   247	  - No external-party PII (clients of clients)
   248	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
   249	- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
   250	
   251	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   252	
   253	---
   254	
   255	## §8 — Build dependencies (W5 prerequisites)
   256	
   257	Janitor build cannot start until ALL of the following are confirmed:
   258	
   259	| Dependency | Source | Status |
   260	|---|---|---|

exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/agent.md | sed -n '260,360p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	|---|---|---|
   261	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   262	| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ Week 3 in progress |
   263	| First pilot tenant onboarded (provision-tenant.sh) | Post Q1-LOI | ⏸ Founder action; Trigger 1 fires 2026-06-03 if no LOI |
   264	| **Bullhorn Sub-decision A Accepted** | Bullhorn partnerships response | ⏸ Form submitted 2026-05-24; 2-5 business days |
   265	| **Bullhorn Sub-decision B Accepted** | Bullhorn developer support routing | ⏸ Same |
   266	| Bullhorn MCP connector built | W3-W4 conditional (per ADR-005 sequencing) | ⏸ Not started |
   267	| Bullhorn client_id + client_secret obtained | Tenant pilot OAuth ticket (or marketplace credentials if A=marketplace) | ⏸ Post-A+B Accept |
   268	| Companies House MCP connector | Day-13 shipped (`@ifos/companies-house`) | ✅ |
   269	| Tenant `target_patch.json` + `_secrets.env` provisioned | provision-tenant.sh ran for first pilot | ⏸ Post-LOI |
   270	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ Post-LOI |
   271	| `validate.sh` Gate A logic | Build at W5 start (~0.5 day) | ⏸ |
   272	| `context.sh` hydration | Build at W5 start (~0.5 day) | ⏸ |
   273	| `cycle.sh` orchestration (12-step) | Build at W5 start (~2 days) | ⏸ |
   274	| Dedup heuristic + confidence scorer | Build at W5 start (~3 days) | ⏸ |
   275	| 3 fixtures with golden outputs | Build at W5 start (~1 day) | ⏸ |
   276	
   277	**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
   278	
   279	---
   280	
   281	## §9 — Status + open questions
   282	
   283	**Status:** Proposed. Awaits Bullhorn A+B Accepted + Q1 LOI + W5 build slice start.
   284	
   285	### Open questions for founder review
   286	
   287	| # | Question | Resolution path |
   288	|---|---|---|
   289	| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
   290	| Q2 | Field-completeness priority order — which missing fields are highest-impact to backfill first? | Founder review with first pilot tenant; varies by tenant focus (perm vs contract). |
   291	| Q3 | Bullhorn write batch size — current default 100/min. Bullhorn published rate-limit isn't documented; we may need to negotiate. | Bullhorn commercial conversation Sub-decision B output. |
   292	| Q4 | Tacit-note attribution — should notes attribute to "Intel Force OS Janitor" or just "Internal note"? Tenant brand preference. | Per-tenant config at first-pilot onboarding. |
   293	| Q5 | Day-30 report distribution path — vault only OR also forwarded to tenant's hiring leader via email? | v1.0: vault only. v1.1: opt-in email forward via Concierge. |
   294	| Q6 | Gate B exception handling — what if a tenant's day-0 baseline is already exceptionally clean (low headroom for improvement)? | Founder review at first 3-tenant cohort; may need per-tenant Gate B calibration. |
   295	
   296	### Gotchas (carried forward from ULTRAPLAN A2 line 513)
   297	
   298	1. **Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0.** Estimate 1 week for the MCP server, 1 week for the agent itself (per ULTRAPLAN A2 line 513).
   299	2. **Dedup is hard; start conservative.** High-confidence merges only (≥0.85); tune up the threshold over time as data builds.
   300	3. **Bullhorn webhook coverage is patchy** (per ULTRAPLAN A6 line 569 — Concierge note applies cross-agent). Janitor relies on polling not webhooks; safer for nightly cron pattern.
   301	
   302	---
   303	
   304	## §10 — When this document ratifies
   305	
   306	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   307	
   308	Status flips Proposed → Accepted (pre-build) when:
   309	- Codex Round 4 Phase 2 ratifies
   310	- Founder approves §9 open questions Q1 + Q2 + Q4 + Q5 + Q6
   311	- Q3 resolves via Bullhorn Sub-decision B answer
   312	
   313	Status flips Accepted → In Force when:
   314	- W5 build slice produces all 5 sibling bundle files + 3 fixtures
   315	- First production run against migration-test tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
   316	- Day-30 baseline measured for first pilot tenant
   317	- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)
   318	
   319	Until then: this document is a forward-looking scaffold. Conservative pre-build clarity — not a binding contract until ratification.
   320	
   321	*End of Janitor agent.md draft.*

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '35,45p;155,176p;385,405p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_AUTH|ESC_BULLHORN_WRITE_FAIL|ESC_RATE_LIMIT_HIT|ESC_PII_LEAKAGE_RISK|ESC_TONE_RULE_VIOLATION|ESC_SCHEMA_VIOLATION|ESC_VOICE_DRIFT_TENANT" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
97:#### `ESC_BULLHORN_AUTH`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
310:#### `ESC_BULLHORN_WRITE_FAIL`
312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
385:#### `ESC_TONE_RULE_VIOLATION`

 succeeded in 0ms:
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

exec
/bin/zsh -lc 'rg -n "Risk #2|defer Janitor|Janitor.*Scribe|weeks 7-8|W7-8" docs/specs/ULTRAPLAN.md docs/build-brief/00-MASTER-BRIEF.md docs/decisions/sequencing-target.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/specs/ULTRAPLAN.md:757:### Weeks 5–6 — Janitor + Scribe
docs/specs/ULTRAPLAN.md:762:Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.
docs/specs/ULTRAPLAN.md:818:| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:34:- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:56:| 3 | **Risk de-risking** | Which named risks the agent's success/failure surfaces — Risk #1 (cortextOS primitives), Risk #2 (Bullhorn auth), Risk #5 (renderer-not-built) — per `docs/RISK-REGISTER.md` | Building risk-surfacing agents earlier converts known-unknowns into known-knowns; building risk-deferring agents earlier preserves optionality but pushes the surprise window later |
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:71:- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
docs/decisions/sequencing-target.md:74:Recommended sequence in §4 must remain **operationally coherent under both contingencies.** A sequence that breaks (e.g. one that ships Concierge before Janitor) would lose the Risk #2 contingency because dropping Janitor would orphan the already-shipped Concierge's data flow. The §4 recommendation explicitly validates against both contingencies.
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:111:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #2** (Bullhorn auth path per RISK-REGISTER). Closes Risk #2 reduction trigger 2 from `bullhorn-integration-path.md` §6.7: "first Bullhorn write lands cleanly in Week 3-4 Janitor agent build" → Risk #2 Medium → Low |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:124:| 3. Risk de-risking | **Medium** | Reuses Janitor's Bullhorn auth path (doesn't re-derisk Risk #2). Surfaces new failure mode: **webhook-arrival-to-Bullhorn-write SLA** (5-min target per Ultraplan §8.1 line 521). Doesn't directly touch Risk #5 (renderer already proven by Diagnostic) or Risk #1 (still Tier 2) |
docs/decisions/sequencing-target.md:126:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Concierge consumes Scribe-generated Notes for context per `bullhorn-integration-path.md` §4.1 row 4 ("Note (prior-comms history)"). Scribe must ship before Concierge | Medium-High criticality |
docs/decisions/sequencing-target.md:142:**Hire-#1 anchor (per Ultraplan §9 line 766 verbatim):** "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)." Cash Conductor's three-accounting-API + Open-Banking integration is the right scope for Hire #1's first sprint per Ultraplan §9 — this places Cash Conductor at W7-8 in the canonical sequence.
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:152:| 3. Risk de-risking | **Medium** | **First exercise of LinkedIn rate-limit budget** per Ultraplan §10 Risk #6 ("LinkedIn rate limits via Proxycurl are tighter than expected"). Reuses Bullhorn auth from Janitor (doesn't re-derisk Risk #2). Tier 2 so doesn't touch Risk #1 primitives |
docs/decisions/sequencing-target.md:153:| 4. Commercial value | **Medium** | Per Product Spec §2.2 R5: "Shortlist in 15 minutes instead of by end of week." Less commercially load-bearing than Janitor/Scribe/Concierge — request-response not always-on, so less of a closing-demo asset. Sales narrative is "cuts intake-call-to-first-shortlist time from same-week to same-hour" |
docs/decisions/sequencing-target.md:165:| 3. Risk de-risking | **High (secondary)** | Second Tier-1 always-on agent (after Cash Conductor at W7-8) — provides Risk #1 secondary exercise. Exercises Bullhorn webhook coverage gaps per Ultraplan §8.1 line 569 verbatim ("Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks") |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:184:W7-8: Cash Conductor (A4) — Hire-#1-anchored per Ultraplan §9 line 766
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:193:- W5: Risk #2 (Bullhorn auth) — Janitor first writes. Reduction trigger 2 fires (Medium → Low per `bullhorn-integration-path.md` §6.7).
docs/decisions/sequencing-target.md:194:- W7-8: Risk #1 (cortextOS Primitives 1+4+5) — Cash Conductor first Tier-1. Reduction trigger fires.
docs/decisions/sequencing-target.md:200:**Cost if deferred risk materialises late:** if Bullhorn webhook coverage is worse than expected (Risk #2 secondary), Concierge polling cadence increases (per Day 2 §4.2 fallback) — connector-internal change, no agent rework. Bounded.
docs/decisions/sequencing-target.md:202:**Hire-#1-onboarding fit:** **Excellent.** Cash Conductor at W7-8 matches Ultraplan §9 line 766 verbatim. Hire #1 (assumed W7) takes Cash Conductor's three-accounting-API + Open-Banking work as first sprint — well-scoped, independent of the Bullhorn track founder has been driving solo W3-W6.
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:229:W5:   Janitor (A2) — Risk #2 derisk
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:256:| 5. Dependencies on other agents | **Wins** — Janitor's Bullhorn auth → Scribe reuses → Sourcing Scout reuses → Concierge reuses, all in dependency order | Loses — Concierge before Janitor + Scribe breaks the upstream chain | Loses — Concierge before Scribe breaks the upstream chain |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:284:| 4 | W7-8 | **Cash Conductor** (A4) | Hire-#1-anchored per Ultraplan §9 line 766 verbatim ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7"); first Tier-1 (Risk #1 derisk) |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:294:The Hire-#1 anchor at W7-8 per Ultraplan §9 line 766 is load-bearing — Cash Conductor's three-accounting-API + Open-Banking work is well-scoped for Hire #1's first sprint. Beta and Gamma both displace Cash Conductor past W7-8 (W12-13 and W11 respectively), leaving Hire #1 with no first-sprint scope per §3.2 and §3.3 structural defects.
docs/decisions/sequencing-target.md:300:**Trigger 1 — Risk #2 materialises in Week 4-5.** If Bullhorn auth path breaks (Day 2 Sub-decisions A or B don't flip to Accepted, marketplace required but unobtainable, OAuth flow blocks deployment, or per-tenant client_id ticket cycle slows past 5 business days per `bullhorn-integration-path.md` §1.3 row 5):
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:311:- **Updates required:** same set as Trigger 1 plus founder's Q3 personal cadence (Cash Conductor's L/2-week build becomes founder solo at W7-8, slowing but not blocking).
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:325:- The 6-agent sequence per §4.1, including Cash Conductor's W7-8 Hire-#1 anchor.
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:373:3. **Either fix-and-retry (1 additional week)** or **scope-cut contingency activates** per §4.3 Trigger 1 (if Risk #2 derived) or §4.3 Trigger 2 (if Risk #4 derived).
docs/decisions/sequencing-target.md:406:### 6.3 — For Risk #2 (Bullhorn auth path)
docs/decisions/sequencing-target.md:439:- **Janitor's first Bullhorn auth refresh fails by W5** (Risk #2 unmitigated; commercial path broken)
docs/decisions/sequencing-target.md:449:- §4.3 revisit conditions name specific tripwires (Risk #2, Risk #4, Hire #1) and concrete activation actions (decider + updates required + cascade).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:491:| Revisit conditions | §4.3 | Three triggers named (Risk #2, Risk #4, Hire #1) with decider + activation + updates + cascade per trigger |
docs/decisions/sequencing-target.md:508:| Day 2 commercial conversations land by start of W4 (Risk #2 reduction triggers) | Founder | Sunday-Monday outreach; resolved by end of W3 | Already tracked from `bullhorn-integration-path.md` §1.3 |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |

exec
/bin/zsh -lc "nl -ba docs/decisions/sequencing-target.md | sed -n '90,120p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    90	Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
    91	
    92	### 2.1 — A1 Diagnostic
    93	
    94	| Criterion | Score | Rationale |
    95	|---|---|---|
    96	| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
    97	| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
    98	| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
    99	| 4. Commercial value | **Medium** | Internal sales tool per Product Spec §2.2 R13 ("Not on the customer pricing card"). Drives qualified discovery-call pipeline. Demoable to a prospect but not the closing demo. Ultraplan §8.1 line 499 Gate B target: "≥30% of diagnostics produced lead to a discovery call booked" |
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

codex
REJECTED

1. Line 4 uses a relative date in a status claim: `"R19 fixes (today)"`. The ratification brief requires absolute dates in artefacts; this makes the build-state signal time-dependent and unverifiable after 2026-05-24. Replace `today` with `2026-05-24`.

2. Line 9 cites the wrong sequencing section for Janitor tiering. `sequencing-target.md §2.1` is the Diagnostic section; Janitor is in `§2.2` lines 105-116. Change the citation to `sequencing-target.md §2.2` or remove it if ULTRAPLAN A2 line 504 is sufficient.

3. The contractor dedup output promised in §1 is missing from §3 output shape. Line 17 says Janitor merges duplicate candidate AND contractor records, but line 58 lists only duplicate candidate pairs and line 70 defines only `Candidate merge`. Add contractor pairs to the day-30 report and define the contractor merge/write path, including the action_type mapping.

4. Dedup approval semantics contradict the escalation catalogue. Lines 17 and 70 say Bullhorn dedupe writes are yellow-tier with no synchronous approval, but lines 201 and 227 say `ESC_DUPLICATE_DETECTED` is a success-path Telegram approval gate; the catalogue defines that code as “Janitor dedup needs human approval.” Either make dedupe approval-gated and update the autosend tier, or keep yellow autosend and remove/recatalogue `ESC_DUPLICATE_DETECTED` for Janitor.
tokens used
63,201
REJECTED

1. Line 4 uses a relative date in a status claim: `"R19 fixes (today)"`. The ratification brief requires absolute dates in artefacts; this makes the build-state signal time-dependent and unverifiable after 2026-05-24. Replace `today` with `2026-05-24`.

2. Line 9 cites the wrong sequencing section for Janitor tiering. `sequencing-target.md §2.1` is the Diagnostic section; Janitor is in `§2.2` lines 105-116. Change the citation to `sequencing-target.md §2.2` or remove it if ULTRAPLAN A2 line 504 is sufficient.

3. The contractor dedup output promised in §1 is missing from §3 output shape. Line 17 says Janitor merges duplicate candidate AND contractor records, but line 58 lists only duplicate candidate pairs and line 70 defines only `Candidate merge`. Add contractor pairs to the day-30 report and define the contractor merge/write path, including the action_type mapping.

4. Dedup approval semantics contradict the escalation catalogue. Lines 17 and 70 say Bullhorn dedupe writes are yellow-tier with no synchronous approval, but lines 201 and 227 say `ESC_DUPLICATE_DETECTED` is a success-path Telegram approval gate; the catalogue defines that code as “Janitor dedup needs human approval.” Either make dedupe approval-gated and update the autosend tier, or keep yellow autosend and remove/recatalogue `ESC_DUPLICATE_DETECTED` for Janitor.
