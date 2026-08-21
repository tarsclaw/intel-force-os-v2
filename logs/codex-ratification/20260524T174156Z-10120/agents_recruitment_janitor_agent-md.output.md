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
session id: 019e5b14-4fa0-7933-930e-8311e0b90169
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

**Status:** Proposed (Day-16 pre-W5-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice).
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
**Build complexity:** L (2 weeks) per ULTRAPLAN A2 line 512.
**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.1.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).

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
- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist)

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
| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
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
     tenant_adapters.config.janitor_last_run — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist)
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
     §1.3): SELECT FROM recent_edit WHERE resolved_at > now() - interval '30 days'
     AND resolution='approved_after_edit' AND tenant_slug=$tenant
   → join to decision_log only if action-context lookups needed
   → group by target_entity_type (candidate / contractor / contact / brief / etc.)
   → for each group, generate narrative summary via voice-classified LLM
     (voice corpus + tone rules; ESC_VOICE_DRIFT if classifier <0.75)

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
   → exit code 0 (or 1 if Gate-B missed for 3 consecutive runs → ESC_GATE_B_MISS)
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + autosend-safety-policy §4. Janitor's `validate.sh` enforces:

- Bullhorn auth refresh succeeded in Step 1 (no stale token writes)
- Every proposed merge has confidence ≥ 0.85 per ULTRAPLAN A2 line 510
- No merge proposal where EITHER candidate has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim)
- No field-backfill where source confidence <0.7 (CH 404 / LinkedIn empty / no derivation source)
- Tacit-note narratives pass voice classifier ≥ 0.75
- Bullhorn write batch size ≤ 100 per minute (rate-limit defensive)
- No PII outside firm boundary in tacit-note narratives (regex pass)

Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint per catalogue §2.5) — applicable to ALL Gate A conditions (per-merge confidence, voice classifier, PII, write-batch size). `ESC_DUPLICATE_DETECTED` (catalogue §2.5) is NOT fired for sub-threshold rejects: per catalogue trigger, that code is for dedup confidence ≥0.85 review-required cases (which is a SUCCESS path, not a Gate A failure). Sub-0.85 confidence pairs silently drop in Step 3 algorithm; no ESC fire. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (catalogue line 163) is NOT used by Janitor — reserved for vertical-schema field-constraint violations at write-time.

### Gate B — Outcome threshold (success metric, not block)

Per ULTRAPLAN A2 line 511 verbatim: **"day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement"**.

Two independent thresholds (both must pass): dedup improvement ≥15% AND field-completeness improvement ≥10%. NOT a composite — composite would let one cover the other.

Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.

Failing either threshold for 3 consecutive runs → fire `ESC_GATE_B_MISS` → flag for operator review (heuristic tuning may be needed; not a kill).

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
| `ESC_GATE_B_MISS` | Per catalogue §2.10 trigger: per-agent local Gate B metric threshold missed for the per-agent window. For Janitor: dedup-improvement <15% OR field-completeness-improvement <10% (two independent thresholds; missing EITHER triggers; per §5 Gate B). Catalogue routing: operator_chat_id | warn | operator_chat_id |
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
I’ll verify the cited source files directly before deciding, focusing on hard blockers: section structure, schema/action-type claims, ESC catalogue entries, and boundary/gate consistency.
exec
/bin/zsh -lc "rg --files | rg '("'^|/)(master|ULTRAPLAN|ultraplan|escalation-codes|autosend|voice-loader|vertical-schema|v0.2|kill-criterion|sequencing-target|bullhorn-integration-path|ADR-003|ADR-004|v0.2-to-v0.3)'"'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 129ms:
     1	# Janitor — the wedge agent
     2	
     3	**Status:** Proposed (Day-16 pre-W5-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice).
     4	**Date:** 2026-05-24.
     5	**Author:** Founder (Maddox) + Claude Code.
     6	**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
     7	**Build complexity:** L (2 weeks) per ULTRAPLAN A2 line 512.
     8	**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.1.
     9	
    10	---
    11	
    12	## §1 — Output contract (one-paragraph screenshot)
    13	
    14	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    15	
    16	> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
    17	
    18	---
    19	
    20	## §2 — Invocation surface
    21	
    22	### Cron (v1.0)
    23	
    24	```bash
    25	# /etc/cron.daily/ifos-janitor → calls this script per tenant
    26	0 2 * * * sudo -u ifos_user /usr/local/bin/ifos-janitor.sh --tenant <slug>
    27	```
    28	
    29	Resolved by cortextOS daemon → spawns Janitor in Tier-2 batch mode (no persistent PTY). Typical runtime per tenant: 15-45 min depending on Bullhorn corpus size.
    30	
    31	### Manual trigger (v1.0 — operator convenience)
    32	
    33	```bash
    34	ifosctl janitor --tenant <slug> [--dry-run] [--report-only]
    35	```
    36	
    37	`--dry-run` reports what WOULD be written without touching Bullhorn. `--report-only` regenerates the day-30 report without doing dedup/enrichment passes (used post-incident for manual report regeneration).
    38	
    39	### v1.1+ surfaces (deferred)
    40	
    41	- Brain UI "Run Janitor now" button → triggers via internal API
    42	- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist)
    43	
    44	---
    45	
    46	## §3 — Output shape
    47	
    48	Two outputs per run. Both are load-bearing artefacts.
    49	
    50	### Output 1 — Day-30 Markdown report
    51	
    52	Located at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`. Eight sections:
    53	
    54	| # | Section | Content |
    55	|---|---|---|
    56	| 1 | **Record counts** | Total candidates / contractors / clients / contacts / placements / opportunities before + after this run; deltas per entity type |
    57	| 2 | **Dedup pairs** | List of duplicate candidate pairs identified this run (confidence ≥0.85 only); for each pair: candidate `bullhorn_id` per vertical-schema.yaml candidate entity, match dimensions (name + email + phone + LinkedIn), confidence score, action taken (merged vs flagged-for-review) |
    58	| 3 | **Field-completeness deltas** | Per entity-type table: which fields were filled in (e.g., candidate.location, contractor.day_rate); source of the backfill (Companies House lookup, LinkedIn enrichment, derivation from related entities) |
    59	| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
    60	| 5 | **Agent vs. consultant attribution** | Rows attributed to Janitor automated work vs consultant manual entry; supports the day-30 before/after narrative |
    61	| 6 | **Gate-B metric** | TWO independent thresholds per ULTRAPLAN A2 line 511 verbatim: dedup improvement ≥15% AND field-completeness improvement ≥10%. Both must pass. NOT a composite score — that would let one threshold cover for the other. |
    62	| 7 | **Exception list** | Failed writes (Bullhorn 4xx/5xx, FK violations); rate-limit hits; dedup proposals flagged for review (confidence between 0.7-0.85); operator action items |
    63	| 8 | **Executive summary** | 200-word narrative suitable for forwarding to the tenant's hiring leader; cites top-3 cleanup wins; quantifies time saved (hours of consultant data-entry work avoided) |
    64	
    65	### Output 2 — Bullhorn writes (yellow tier)
    66	
    67	Three write categories. Action types map to `agents/_shared/autosend-policy.yaml` — existing entries are used as-is; new entries are flagged for catalogue addition at W5 build (per `review-agent-bundle.md` §1 row §6 flag-for-addition pattern):
    68	
    69	1. **Candidate merge** (`PUT /Candidate/{primary_id}` + cascade) — only when confidence ≥0.85 per Gate A; no merge if either candidate had Bullhorn activity in last 90 days without explicit review flag (per ULTRAPLAN A2 line 510 verbatim). Action type: **`bullhorn_candidate_dedupe`** (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW action_types; yellow tier; sample_rate: 10).
    70	2. **Field backfill** (`PATCH /Candidate/{id}` or `/Client/{id}`) — fills missing canonical schema fields (per `vertical-schema.yaml`): `candidate.location` (line 124), `client.industry` (line 238), `client.size_employees` (line 243), `client.companies_house_number` (line 252), `contractor.day_rate_min/day_rate_max` (lines 193-197), `brief.salary_min/salary_max` (lines 371-376) from Companies House (for clients) or LinkedIn/derivation (for candidates). Sources logged in payload. Action type: **`bullhorn_field_backfill`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 10).
    71	3. **Tacit-note attach** (`POST /Note` linked to entity) — narrative summary of consultant edits + decision-log resolutions over the 30-day window. Action type: **`bullhorn_note_attach`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 20).
    72	
    73	Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.
    74	
    75	---
    76	
    77	## §4 — Workflow
    78	
    79	12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
    80	
    81	```
    82	0. Session start
    83	   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice corpus
    84	     (used for tacit-note attribution) + recent edits (for note harvest)
    85	   → hh_decision_trigger("session_start", "janitor nightly cron")
    86	
    87	1. Bullhorn auth refresh
    88	   → bullhorn.refresh_access_token() per per-agent 8-min refresh loop
    89	     (bullhorn-integration-path.md §4.5)
    90	   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
    91	
    92	2. Bullhorn entity scan (read-only)
    93	   → enumerate candidates + contractors + clients + contacts + placements +
    94	     opportunities created/modified since last Janitor run (last_run_at in
    95	     tenant_adapters.config.janitor_last_run — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist)
    96	   → hh_decision_output("janitor_scan", "tenant:<slug>", "<N> entities scanned")
    97	   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per ESC_RATE_LIMIT_HIT catalogue §2.5 standard handling)
    98	
    99	3. Dedup pass — candidate entity type
   100	   → fuzzy-match across (name, email, phone, linkedin_url) tuples
   101	   → compute confidence per pair: name × 0.3 + email × 0.4 + phone × 0.2 + linkedin × 0.1
   102	   → discard pairs <0.85 confidence (per Gate A)
   103	   → discard pairs where EITHER candidate has Bullhorn activity in last 90d
   104	     (per ULTRAPLAN A2 line 510 verbatim)
   105	   → batch into proposed-merge list (in-memory intermediate; not persisted —
   106	     hh_decision_action emitted at Step 9 when each merge actually writes)
   107	
   108	4. Dedup pass — contractor entity type
   109	   → same algorithm as candidates; separate entity_type per Q1 Day-6 resolution
   110	     (vertical-schema.yaml §1)
   111	
   112	5. Field completeness audit (canonical field names per vertical-schema.yaml)
   113	   → for each entity, check critical fields: candidate.location (line 124),
   114	     client.industry (line 238), client.size_employees (line 243),
   115	     contractor.day_rate_min/day_rate_max (lines 193-197),
   116	     brief.salary_min/salary_max (lines 371-376)
   117	   → identify missing-field rows
   118	   → batch enrichment calls
   119	   → hh_decision_output("field_completeness_audit", tenant, "<N> missing-field rows")
   120	
   121	6. Companies House enrichment (clients only)
   122	   → companies_house.search(client.name per vertical-schema.yaml line 235) → CRN →
   123	     profile → fill canonical schema fields client.industry (line 238),
   124	     client.companies_house_number (line 252)
   125	   → 7-day cache per tools.yaml; rate-limit budget shared with Diagnostic
   126	   → ESC_RATE_LIMIT_HIT on 429
   127	
   128	7. LinkedIn enrichment (candidates; v1.1 via Proxycurl)
   129	   → at v1.0: skipped (LinkedIn deep data deferred to W4 polish; Proxycurl
   130	     signup commercial decision)
   131	   → at v1.1: linkedin.profile_fetch(candidate.linkedin_url) → location +
   132	     current_company → write back
   133	
   134	8. Tacit-note harvest
   135	   → query the `recent_edit` v0.2 table directly (per vertical-schema.v0.2-supplement.yaml
   136	     §1.3): SELECT FROM recent_edit WHERE resolved_at > now() - interval '30 days'
   137	     AND resolution='approved_after_edit' AND tenant_slug=$tenant
   138	   → join to decision_log only if action-context lookups needed
   139	   → group by target_entity_type (candidate / contractor / contact / brief / etc.)
   140	   → for each group, generate narrative summary via voice-classified LLM
   141	     (voice corpus + tone rules; ESC_VOICE_DRIFT if classifier <0.75)
   142	
   143	9. Bullhorn write batch (yellow tier — spot-check sampling)
   144	   → for each proposed merge / backfill / note: emit hh_decision_action with
   145	     tier='yellow'; spot-check sample rate per autosend-policy.yaml row
   146	   → atomic per-write transaction (BEGIN/COMMIT)
   147	   → on 4xx: emit ESC_BULLHORN_WRITE_FAIL; skip; continue
   148	   → on 5xx: emit ESC_BULLHORN_WRITE_FAIL; retry once with 30s backoff
   149	
   150	10. Day-30 report assembly
   151	   → SELECT from decision_log WHERE agent_name='janitor' AND created_at >
   152	     now() - interval '30 days' AND tenant_slug=$tenant
   153	   → group by action_type; tally success/fail; compute Gate-B metric
   154	   → 8-section Markdown report (per §3 above)
   155	   → write to /vault/<tenant>/janitor-reports/day-30-<ISO-date>.md
   156	   → hh_decision_output("day_30_report", "<path>", "Gate-B score: <N>")
   157	
   158	11. Operator notification (Telegram)
   159	   → if Gate-B target met: green-tier notification with summary
   160	   → if Gate-B target missed: yellow-tier notification + 200-char executive
   161	     summary suggesting consultant follow-up
   162	   → hh_decision_action("operator_notify_telegram", "tenant:<slug>",
   163	     notification_hash, "gate_b_state:met|missed; chars:<N>")
   164	
   165	12. Session close
   166	   → update tenant_adapters.config.janitor_last_run = now()
   167	   → hh_decision_action("janitor_run_complete", "tenant:<slug>", payload_hash, payload_preview)
   168	   → exit code 0 (or 1 if Gate-B missed for 3 consecutive runs → ESC_GATE_B_MISS)
   169	```
   170	
   171	---
   172	
   173	## §5 — Gates
   174	
   175	### Gate A — validate.sh (hard-fail before action)
   176	
   177	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Janitor's `validate.sh` enforces:
   178	
   179	- Bullhorn auth refresh succeeded in Step 1 (no stale token writes)
   180	- Every proposed merge has confidence ≥ 0.85 per ULTRAPLAN A2 line 510
   181	- No merge proposal where EITHER candidate has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim)
   182	- No field-backfill where source confidence <0.7 (CH 404 / LinkedIn empty / no derivation source)
   183	- Tacit-note narratives pass voice classifier ≥ 0.75
   184	- Bullhorn write batch size ≤ 100 per minute (rate-limit defensive)
   185	- No PII outside firm boundary in tacit-note narratives (regex pass)
   186	
   187	Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint per catalogue §2.5) — applicable to ALL Gate A conditions (per-merge confidence, voice classifier, PII, write-batch size). `ESC_DUPLICATE_DETECTED` (catalogue §2.5) is NOT fired for sub-threshold rejects: per catalogue trigger, that code is for dedup confidence ≥0.85 review-required cases (which is a SUCCESS path, not a Gate A failure). Sub-0.85 confidence pairs silently drop in Step 3 algorithm; no ESC fire. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (catalogue line 163) is NOT used by Janitor — reserved for vertical-schema field-constraint violations at write-time.
   188	
   189	### Gate B — Outcome threshold (success metric, not block)
   190	
   191	Per ULTRAPLAN A2 line 511 verbatim: **"day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement"**.
   192	
   193	Two independent thresholds (both must pass): dedup improvement ≥15% AND field-completeness improvement ≥10%. NOT a composite — composite would let one cover the other.
   194	
   195	Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
   196	
   197	Failing either threshold for 3 consecutive runs → fire `ESC_GATE_B_MISS` → flag for operator review (heuristic tuning may be needed; not a kill).
   198	
   199	---
   200	
   201	## §6 — Escalation codes
   202	
   203	All codes are registered in `agents/_shared/escalation-codes.md` (catalogue extended to 52 codes per `2026-05-24` bilateral disposition; see disagreement-doc + `catalogue(bilateral)` commit).
   204	
   205	| Code | Trigger | Severity | Routing |
   206	|---|---|---|---|
   207	| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   208	| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on merge/backfill/note write | warn | operator_chat_id |
   209	| `ESC_RATE_LIMIT_HIT` | Bullhorn or Companies House 429 | warn | operator_chat_id |
   210	| `ESC_VOICE_DRIFT` | Tacit-note narrative voice classifier <0.75 (after 3 retries) | warn | operator_chat_id |
   211	| `ESC_PII_LEAKAGE_RISK` | PII detected in tacit-note outside firm boundary | **blocking** | operator + ifos_oncall |
   212	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (section count or per-section citation missing in day-30 report) | warn | operator_chat_id |
   213	| `ESC_DUPLICATE_DETECTED` | Per catalogue §2.5 trigger: dedup confidence ≥0.85 review-required cases (SUCCESS path; Telegram approval gate fires). NOT a Gate A failure code. | warn | operator_chat_id (via Telegram approval gate per catalogue routing) |
   214	| `ESC_GATE_B_MISS` | Per catalogue §2.10 trigger: per-agent local Gate B metric threshold missed for the per-agent window. For Janitor: dedup-improvement <15% OR field-completeness-improvement <10% (two independent thresholds; missing EITHER triggers; per §5 Gate B). Catalogue routing: operator_chat_id | warn | operator_chat_id |
   215	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
   216	
   217	Janitor does NOT use:
   218	
   219	- `ESC_VOICE_DRIFT_TENANT` — fired by nightly voice-drift cron (per `escalation-codes.md` line 170-175 trigger: ≥N `ESC_VOICE_DRIFT` rows from same tenant in rolling 7d window). Janitor only fires the per-run `ESC_VOICE_DRIFT`; aggregate `_TENANT` rollup is handled by the canary not Janitor.
   220	- `ESC_AUTOSEND_BLOCKED` — that's for red-tier blocks (`escalation-codes.md` line 41); Janitor writes are yellow tier only
   221	- `ESC_BULLHORN_OAUTH_REVOKED` — escalated handling; Concierge owns the cross-agent escalation
   222	- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction
   223	
   224	---
   225	
   226	## §7 — Voice + tone constraints
   227	
   228	Step 8 (tacit-note narrative generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   229	
   230	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
   231	  - No identifying language about candidates beyond what's in their CV / Bullhorn record
   232	  - No commercial sensitive information (rates / placement fees / commission %)
   233	  - No external-party PII (clients of clients)
   234	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
   235	- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
   236	
   237	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   238	
   239	---
   240	
   241	## §8 — Build dependencies (W5 prerequisites)
   242	
   243	Janitor build cannot start until ALL of the following are confirmed:
   244	
   245	| Dependency | Source | Status |
   246	|---|---|---|
   247	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   248	| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ Week 3 in progress |
   249	| First pilot tenant onboarded (provision-tenant.sh) | Post Q1-LOI | ⏸ Founder action; Trigger 1 fires 2026-06-03 if no LOI |
   250	| **Bullhorn Sub-decision A Accepted** | Bullhorn partnerships response | ⏸ Form submitted 2026-05-24; 2-5 business days |
   251	| **Bullhorn Sub-decision B Accepted** | Bullhorn developer support routing | ⏸ Same |
   252	| Bullhorn MCP connector built | W3-W4 conditional (per ADR-005 sequencing) | ⏸ Not started |
   253	| Bullhorn client_id + client_secret obtained | Tenant pilot OAuth ticket (or marketplace credentials if A=marketplace) | ⏸ Post-A+B Accept |
   254	| Companies House MCP connector | Day-13 shipped (`@ifos/companies-house`) | ✅ |
   255	| Tenant `target_patch.json` + `_secrets.env` provisioned | provision-tenant.sh ran for first pilot | ⏸ Post-LOI |
   256	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ Post-LOI |
   257	| `validate.sh` Gate A logic | Build at W5 start (~0.5 day) | ⏸ |
   258	| `context.sh` hydration | Build at W5 start (~0.5 day) | ⏸ |
   259	| `cycle.sh` orchestration (12-step) | Build at W5 start (~2 days) | ⏸ |
   260	| Dedup heuristic + confidence scorer | Build at W5 start (~3 days) | ⏸ |

 succeeded in 208ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/specs/ULTRAPLAN.md
docs/decisions/autosend-approval-bridge-spec.md
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/autosend-safety-policy.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/sequencing-target.md
docs/decisions/bullhorn-integration-path.md
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/voice-loader.sh
legacy/v1/docs/phase-2-agent-suite/_shared/escalation-codes.md

exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/agent.md | sed -n '260,360p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	| Dedup heuristic + confidence scorer | Build at W5 start (~3 days) | ⏸ |
   261	| 3 fixtures with golden outputs | Build at W5 start (~1 day) | ⏸ |
   262	
   263	**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
   264	
   265	---
   266	
   267	## §9 — Status + open questions
   268	
   269	**Status:** Proposed. Awaits Bullhorn A+B Accepted + Q1 LOI + W5 build slice start.
   270	
   271	### Open questions for founder review
   272	
   273	| # | Question | Resolution path |
   274	|---|---|---|
   275	| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
   276	| Q2 | Field-completeness priority order — which missing fields are highest-impact to backfill first? | Founder review with first pilot tenant; varies by tenant focus (perm vs contract). |
   277	| Q3 | Bullhorn write batch size — current default 100/min. Bullhorn published rate-limit isn't documented; we may need to negotiate. | Bullhorn commercial conversation Sub-decision B output. |
   278	| Q4 | Tacit-note attribution — should notes attribute to "Intel Force OS Janitor" or just "Internal note"? Tenant brand preference. | Per-tenant config at first-pilot onboarding. |
   279	| Q5 | Day-30 report distribution path — vault only OR also forwarded to tenant's hiring leader via email? | v1.0: vault only. v1.1: opt-in email forward via Concierge. |
   280	| Q6 | Gate B exception handling — what if a tenant's day-0 baseline is already exceptionally clean (low headroom for improvement)? | Founder review at first 3-tenant cohort; may need per-tenant Gate B calibration. |
   281	
   282	### Gotchas (carried forward from ULTRAPLAN A2 line 513)
   283	
   284	1. **Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0.** Estimate 1 week for the MCP server, 1 week for the agent itself (per ULTRAPLAN A2 line 513).
   285	2. **Dedup is hard; start conservative.** High-confidence merges only (≥0.85); tune up the threshold over time as data builds.
   286	3. **Bullhorn webhook coverage is patchy** (per ULTRAPLAN A6 line 569 — Concierge note applies cross-agent). Janitor relies on polling not webhooks; safer for nightly cron pattern.
   287	
   288	---
   289	
   290	## §10 — When this document ratifies
   291	
   292	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   293	
   294	Status flips Proposed → Accepted (pre-build) when:
   295	- Codex Round 4 Phase 2 ratifies
   296	- Founder approves §9 open questions Q1 + Q2 + Q4 + Q5 + Q6
   297	- Q3 resolves via Bullhorn Sub-decision B answer
   298	
   299	Status flips Accepted → In Force when:
   300	- W5 build slice produces all 5 sibling bundle files + 3 fixtures
   301	- First production run against migration-test tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
   302	- Day-30 baseline measured for first pilot tenant
   303	- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)
   304	
   305	Until then: this document is a forward-looking scaffold. Conservative pre-build clarity — not a binding contract until ratification.
   306	
   307	*End of Janitor agent.md draft.*

codex
The agent structure is present and in order. I’m now checking whether the cited policy/schema/catalogue claims actually exist, because those are the highest-risk ratification failures for a pre-build scaffold.
exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '110,260p'; nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '360,385p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# IFOS auto-send policy (runtime table)
     2	#
     3	# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
     4	# Read by agents/_shared/hook-helpers.sh::autosend_policy_lookup() at every
     5	# hh_decision_action() invocation. Per-tenant overrides live in Postgres
     6	# tenant_adapters.config.tier_overrides (§8).
     7	#
     8	# 47 v1.0 action_types: 19 green + 10 yellow + 10 orange + 8 red.
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
   136	
   137	  diagnostic_cleanup:
   138	    tier: green
   139	    agent: diagnostic
   140	    reason: "Internal audit row written by cleanup.sh at end of normal-completion run. Records cache-purge status + workspace cleanup; no external comms."
   141	    irreversible: false
   142	
   143	  # ───────────────────────────────────────────────────────────
   144	  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
   145	  # ───────────────────────────────────────────────────────────
   146	
   147	  bullhorn_candidate_dedupe:
   148	    tier: yellow
   149	    agent: janitor
   150	    sample_rate: 10
   151	    reason: "Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review"
   152	    irreversible: false
   153	
   154	  bullhorn_field_backfill:
   155	    tier: yellow
   156	    agent: janitor
   157	    sample_rate: 10
   158	    reason: "Fills missing canonical schema fields from Companies House or LinkedIn enrichment; reversible PATCH; high-volume; source provenance logged in payload"
   159	    irreversible: false
   160	
   161	  bullhorn_note_attach:
   162	    tier: yellow
   163	    agent: janitor
   164	    sample_rate: 20
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
   186	    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
   187	    irreversible: false
   188	
   189	  bullhorn_note_draft_internal:
   190	    tier: yellow
   191	    agent: concierge
   192	    sample_rate: 10
   193	    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
   194	    irreversible: false
   195	
   196	  bullhorn_scribe_field_write:
   197	    tier: yellow
   198	    agent: scribe
   199	    sample_rate: 10
   200	    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
   201	    irreversible: false
   202	
   203	  accounting_reconciliation_write:
   204	    tier: yellow
   205	    agent: cash-conductor
   206	    sample_rate: 10
   207	    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
   208	    irreversible: false
   209	
   210	  concierge_email_draft:
   211	    tier: yellow
   212	    agent: concierge
   213	    sample_rate: 20
   214	    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
   215	    irreversible: false
   216	
   217	  # ───────────────────────────────────────────────────────────
   218	  # ORANGE — per-action human approval (10 action_types)
   219	  # ───────────────────────────────────────────────────────────
   220	

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
   151	
   152	  # --------------------------------------------------------------------------
   153	  contractor:
   154	    description: |
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
   181	        required: false
   182	        source: Bullhorn.Candidate.email
   183	      mobile:
   184	        type: string
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
   201	      umbrella_company:
   202	        type: string
   203	        required: false
   204	        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
   205	        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
   206	      availability_weeks:
   207	        type: integer
   208	        required: false
   209	        source: IFOS-derived (when can contractor start, in weeks from now)
   210	      current_engagement_end_date:
   211	        type: date
   212	        required: false
   213	        source: IFOS-derived
   214	        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
   215	    notes:
   216	      - IR35 classification is regulatory-bearing; v0.1 captures the field but T4 IR35 agent (v2.0 per master brief §9) is the canonical reasoner.
   217	      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
   218	      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
   219	
   220	  # --------------------------------------------------------------------------
   221	  client:
   222	    description: |
   223	      A company that hires through the recruitment agency. Master brief canonical vocabulary at §3.2 line 155 ("candidate, placement, brief") implicitly assumes client as the holder of briefs. Bullhorn calls this `ClientCorporation`.
   224	    bullhorn_source: Bullhorn.ClientCorporation
   225	    v1_0_agent_access:
   226	      - Janitor (R+W — orphan-link sweep + normalisation per bullhorn §4.1 A2)
   227	      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
   228	      - Concierge (R — relationship context per bullhorn §4.1 A6)
   229	    canonical_fields:
   230	      bullhorn_id:
   231	        type: integer
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
   256	        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
   257	      status:
   258	        type: string
   259	        required: true
   260	        enum: [active, dormant, churned, prospect]
   360	        notes: Role title as advertised; not internal IFOS-codified.
   361	      description:
   362	        type: string
   363	        required: false
   364	        source: Bullhorn.JobOrder.publicDescription
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
   381	        type: number
   382	        required: false
   383	        source: IFOS-derived (extracted from JD; GBP per day for contract roles)
   384	      day_rate_max:
   385	        type: number

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
/bin/zsh -lc "rg -n \"§8\\.2|Janitor|A2|day-30|Bullhorn|dedup|field completeness|Trigger 3|Trigger 8|Change 1|Change 2\" docs -g '*.md' -g '*.yaml'" in /Users/madsadmin/code/CortexOS
 succeeded in 132ms:
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:90:- MCP connectors (Bullhorn, Vincere, Voyager Infinity, Companies House, Microsoft Graph, Xero, Fathom, LinkedIn, AgentMail)
docs/specs/ULTRAPLAN.md:146:**Change 1 — Voice handling moves into a shared module.**
docs/specs/ULTRAPLAN.md:166:**Change 2 — Decision logging is enforced, not optional.**
docs/specs/ULTRAPLAN.md:183:- `ESC_BULLHORN_AUTH` — Bullhorn OAuth token expired or revoked
docs/specs/ULTRAPLAN.md:184:- `ESC_DUPLICATE_DETECTED` — Janitor found a high-confidence dedup candidate requiring human review
docs/specs/ULTRAPLAN.md:239:- Scheduled agents (Janitor, Reporting, Spec Pitcher) run as cron jobs *also* under the tenant's OS user.
docs/specs/ULTRAPLAN.md:423:| Janitor | 30-day before/after report shows ≥15% dedup, ≥10% field-completeness improvement | The day-30 report IS the Gate B measurement |
docs/specs/ULTRAPLAN.md:501:#### A2. The Janitor — the wedge agent
docs/specs/ULTRAPLAN.md:507:- **MCP tools required:** Bullhorn (read-write), Companies House (for entity enrichment)
docs/specs/ULTRAPLAN.md:509:- **External APIs:** Bullhorn REST API, Companies House
docs/specs/ULTRAPLAN.md:510:- **Gate A:** dedup confidence score ≥ 0.85 on every merge proposal; no merge proposed where candidate has had activity in last 90 days without explicit review flag
docs/specs/ULTRAPLAN.md:511:- **Gate B target:** day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement
docs/specs/ULTRAPLAN.md:512:- **Build complexity:** **L** (2 weeks) — the Bullhorn MCP work is the rate-limiting piece
docs/specs/ULTRAPLAN.md:513:- **Gotchas:** Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0. Estimate 1 week for the MCP server, 1 week for the agent itself. Dedup is hard; start conservative (high-confidence merges only) and tune up.
docs/specs/ULTRAPLAN.md:521:- **MCP tools required:** Bullhorn (write), Fathom (read), Fireflies (read)
docs/specs/ULTRAPLAN.md:523:- **External APIs:** Fathom webhook, Fireflies webhook, Bullhorn for write-back
docs/specs/ULTRAPLAN.md:549:- **MCP tools required:** Bullhorn (read for ATS passive matches), LinkedIn (via Proxycurl or similar), Reed.co.uk API, CV-Library API
docs/specs/ULTRAPLAN.md:563:- **MCP tools required:** Bullhorn (read for state, write for activity log), Microsoft Graph / Gmail (send), AgentMail (optional for agent-identity sends)
docs/specs/ULTRAPLAN.md:569:- **Gotchas:** Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks. Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship.
docs/specs/ULTRAPLAN.md:579:- **MCP tools required:** Microsoft Graph or Gmail (read + send), AgentMail (send, where agent-identity is needed), Bullhorn (read for candidate matching), LinkedIn (read)
docs/specs/ULTRAPLAN.md:593:- **MCP tools required:** Bullhorn (read for prior placements + candidates), shared with Sourcing Scout
docs/specs/ULTRAPLAN.md:611:- **MCP tools required:** Bullhorn (read for prior relationships + matching candidates), LinkedIn (read for contact identification)
docs/specs/ULTRAPLAN.md:625:- **MCP tools required:** Bullhorn, LinkedIn, Reed, CV-Library, GitHub (for tech briefs), Sector-specific (configurable per tenant)
docs/specs/ULTRAPLAN.md:653:- **MCP tools required:** Bullhorn (contractor data), Voyager Infinity / 3R (where used), Companies House
docs/specs/ULTRAPLAN.md:655:- **External APIs:** Same as Bullhorn + Voyager
docs/specs/ULTRAPLAN.md:669:| Recruitment Reporting | M (1 week) | Bullhorn + accounting + decision log | Mostly a SQL + templating job |
docs/specs/ULTRAPLAN.md:670:| T1 Onboarding Concierge | M (1 week) | Bullhorn (write), DocuSign, Microsoft Graph | Tracks onboarding tasks; less reasoning-heavy |
docs/specs/ULTRAPLAN.md:671:| T2 Sunday-Evening Timesheet Ranger | M (1 week) | Bullhorn/Voyager + Microsoft Graph | The voice quality on per-contractor history is the work |
docs/specs/ULTRAPLAN.md:683:| Agent | Voice | Bullhorn | MSGraph | Xero/Sage | LinkedIn | CoHouse | Reed/CVLib | Fathom | AgentMail | Telegram | Special |
docs/specs/ULTRAPLAN.md:686:| Janitor | | ✓ | | | | ✓ | | | | | |
docs/specs/ULTRAPLAN.md:707:1. **Bullhorn** — 18 of 18 agents need it (or compatible ATS). Top priority.
docs/specs/ULTRAPLAN.md:724:- Bullhorn MCP server is the critical path; week 1 starts on it.
docs/specs/ULTRAPLAN.md:732:| Tue | Decision on Bullhorn integration path (marketplace vs direct); design partner conversation 1 |
docs/specs/ULTRAPLAN.md:735:| Fri | First MCP server scoped (Bullhorn); contract review with first design partner |
docs/specs/ULTRAPLAN.md:740:- Bullhorn integration path decided and documented
docs/specs/ULTRAPLAN.md:750:### Weeks 3–4 — Bullhorn + Diagnostic
docs/specs/ULTRAPLAN.md:752:- Week 3: Bullhorn MCP server build (auth, read endpoints, write endpoints, webhook subscription)
docs/specs/ULTRAPLAN.md:757:### Weeks 5–6 — Janitor + Scribe
docs/specs/ULTRAPLAN.md:759:- Week 5: Janitor agent; day-30 before/after report template; CI fixtures
docs/specs/ULTRAPLAN.md:762:Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.
docs/specs/ULTRAPLAN.md:799:4. Janitor's Workflow F (the day-30 before/after report) — can be manually compiled for the first tenant
docs/specs/ULTRAPLAN.md:818:| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/specs/ULTRAPLAN.md:824:| 8 | First pilot's Bullhorn data is too messy for Janitor's dedup confidence threshold | Medium | Medium | <5% dedup proposed in week 6 trial run | Lower threshold to 0.7 for the initial cleanup; ship the day-30 report regardless |
docs/specs/ULTRAPLAN.md:829:| 13 | The Bullhorn API rate limits prevent Janitor from completing its initial sweep on day 1 | Medium | Medium | First sweep takes >24 hours | Initial sweep runs in batches over 3 days; communicate to tenant explicitly |
docs/specs/ULTRAPLAN.md:847:- [ ] Bullhorn integration path decision: marketplace vs direct API. **Owner:** Maddox. **Output:** decision documented in `decisions/bullhorn-integration-path.md`.
docs/specs/ULTRAPLAN.md:860:- [ ] First MCP server scoped: tools.yaml schema for Bullhorn integration documented.
docs/specs/ULTRAPLAN.md:878:- If ≥1 of: design-partner LOI signed + CortexOS primitives 1, 4, 5 working + Bullhorn auth working → proceed to week 1
docs/specs/ULTRAPLAN.md:891:3. Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?
docs/specs/PRODUCT-SPEC.md:17:Intel Force OS is the always-on operating system for UK recruitment agencies. It runs on CortexOS as the persistent agent runtime, lives inside each firm's existing stack (Bullhorn / Vincere / Voyager Infinity, Xero / Sage, Microsoft 365 / Google Workspace), and ships as two coordinated product lines — **IntelForce Recruit** for the front office and **IntelForce Temp** for the back office. Together they replace the operational drag of an entire junior team and, more importantly, generate revenue: surfaced BD opportunities, intercepted competitor briefs, faster cash collection, dormant-candidate reactivation, and post-placement nurture that compounds into referrals. The firm pays £499–£6,950/month per front-office tier and a separate £1,950–£5,950/month for the temp sub-platform. Every agent is pitched against a single, quantified outcome the buyer can verify within 90 days. Configuration scales because the moat is the per-vertical schema, not per-customer plumbing — onboarding becomes a 5-day wizard, not a 5-week project.
docs/specs/PRODUCT-SPEC.md:137:#### R9. The Janitor — the database becomes an asset
docs/specs/PRODUCT-SPEC.md:139:- **Output contract:** Day-1 cleanup report (the closing artefact in sales): "Your Bullhorn has 47,000 records, 18% duplicates, 31% with stale contact details, 12% past your retention window, 23% with empty right-to-work fields." Day-30 before/after report. Then continuous: every new record cleaned, deduplicated, enriched, and compliance-checked as it lands.
docs/specs/PRODUCT-SPEC.md:144:- **Per-tenant config:** ATS connector, retention-policy rules, dedup-confidence threshold, field-completeness targets, deletion approval flow (always human-in-loop for v1).
docs/specs/PRODUCT-SPEC.md:242:| **Solo** (1–4 fee earners) | £499 | Janitor + 1 always-on agent (drafts-only) + Scribe | "Pay back the year inside one extra placement. Save 10+ hours/week of inbox and admin drag." |
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:279:        │   The Scribe captures    │    │  The Janitor keeps it    │
docs/specs/PRODUCT-SPEC.md:329:- Customer clicks 5 OAuth buttons in the wizard: ATS (Bullhorn / Vincere / Voyager), accounting (Xero / Sage / QuickBooks), Microsoft 365 or Google Workspace, transcript source (Fathom / Fireflies / Ringover), LinkedIn.
docs/specs/PRODUCT-SPEC.md:344:- Janitor runs against the ATS — produces the day-1 cleanup report.
docs/specs/PRODUCT-SPEC.md:430:**1. Every agent now has a quantified revenue story, not just a time-saved story.** The internal business plan and the 24/7 directive had revenue stories for some agents (Cash Conductor, Client Hunter, T5) but not all. Triage was pitched on responsiveness; here it's pitched on "2–4 additional placements/year per consultant from never-lost candidates". Janitor was pitched on database hygiene; here it's pitched on "one reactivated dormant-but-clean candidate per month covers the tier price".
docs/specs/PRODUCT-SPEC.md:453:- **No ATS replacement.** We sit on top of Bullhorn / Vincere / Voyager. We do not become the system of record. This is non-negotiable for two reasons: customer switching cost is too high to replace the ATS, and our defensible IP is the schema layer, not the data store.
docs/specs/PRODUCT-SPEC.md:458:- **No free pilots beyond the structured 14-day Janitor cleanup trial.** Free pilots train customers to expect free.
docs/specs/PRODUCT-SPEC.md:472:- The Janitor (the wedge agent; lowest risk, highest visible value)
docs/specs/PRODUCT-SPEC.md:530:9. **The Janitor** — "Your sourcing runs become 3× more productive against clean data."
docs/runbooks/day-4-provisioning.md:70:- Master brief §8.1 Change 2: three values — `trigger`, `output`, `action`
docs/runbooks/day-4-provisioning.md:806:Per `sequencing-target.md` §5-A + master brief §8.1 Change 2 + `current-priorities.md` line 16. **Exactly 5 values. No additions.**
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/runbooks/day-4-provisioning.md:1288:- Not the Bullhorn MCP connector (Week 1-2 per `bullhorn-integration-path.md` §6)
docs/specs/_archive-build-handoff.md:55:│  • MCP connectors (Bullhorn, MS Graph, Companies House) │
docs/specs/_archive-build-handoff.md:243:### Day 2 — Bullhorn integration path
docs/specs/_archive-build-handoff.md:246:- Bullhorn Marketplace (vetted, slower onboarding, may have revenue share) vs Direct API (faster, requires per-tenant OAuth setup)
docs/specs/_archive-build-handoff.md:249:Bullhorn is the critical path for 18-of-18 agents. Get this right.
docs/specs/_archive-build-handoff.md:253:Confirm or revise Ultraplan §9's assumption: **close the first three pilots fastest**. That means Janitor and Cash Conductor close demos before Triage absorbs the development heat. Revise only if a hire's signed or a different pilot dynamic emerges.
docs/specs/_archive-build-handoff.md:266:Also Day 4: scope the first MCP server (Bullhorn) — document the `tools.yaml` shape per the Pattern Reference and the Composio/AgentMail adoption doc §3.5. Note: per the adoption doc, Bullhorn is **first-party MCP** (vertical-specific). Composio is *not* the path for it.
docs/specs/_archive-build-handoff.md:302:3. Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path? Y/N
docs/specs/_archive-build-handoff.md:360:- Negotiating Bullhorn marketplace terms — that's a phone call
docs/specs/_archive-build-handoff.md:378:| 2 | **Janitor** | 5 | Bullhorn MCP (read + write) | First demoable inside-the-ATS result; day-30 before/after report closes deals |
docs/specs/_archive-build-handoff.md:379:| 3 | **Scribe** | 6 | Fathom/Fireflies MCP + Bullhorn write | The post-call note that lands in Bullhorn within 10 min is the second-most-demoable result |
docs/specs/_archive-build-handoff.md:382:| 6 | **Concierge** | 10–13 | Bullhorn + Microsoft Graph + AgentMail | First Tier 1 always-on closing demo; 4-week build |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/specs/_archive-build-handoff.md:399:- Bullhorn, Vincere, Voyager Infinity, Acturis, Open GI, SSP, Applied Epic
docs/specs/_archive-build-handoff.md:409:**For Day 4 (first MCP scope):** Bullhorn is first-party. Composio is not the path. Build the connector at `packages/mcp-connectors/bullhorn/` per the Pattern Reference's `tools.yaml` shape.
docs/specs/_archive-build-handoff.md:450:| "Let me use Composio for the Bullhorn connector..." | §6 of this doc |
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:23:| 7 | **Master-brief-drift-accumulation** — eight ADR-driven edits + one Day-4 Postgres-rename + multiple Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all nine edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Codex ratifies the commit alongside the ten+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 + `bullhorn-integration-path.md` + `sequencing-target.md` + `brain-ui-scope.md` + Day 4 runbook §0.1. **Updated Day 4 (2026-05-17):** edit count rose from 8 to 9 with Day-4 Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations" — verified from Day-4 execution against NBG1 because FSN1 was unavailable at provisioning time). **Citation audit 2026-05-18:** earlier drafts also cited master brief §10.4 as a Hetzner/cost-target section; verified §10.4 is the Codex exclusion list ("What never goes through ratification") and contains no Hetzner or cost-target content. Edit 9 scope corrected to line 477 only. |
docs/RISK-REGISTER.md:55:- 2026-05-22 (Day 11) — **Codex Round 2 autonomous ratification complete.** 26 artefacts reviewed; 17 RATIFIED / 9 REJECTED. Manifest §1.7 appended and full outputs written to `logs/codex-ratification/round-2-autonomous/`. D5 skill softening ratified. Bullhorn gate disagreement rejected because the promised source-doc sharpening did not land. Autosend policy, v0.2 supplement, approval bridge, PII purge runbook/script/forward migration, and tenancy audit script remain rejected. **New Risk #11** added for transactionless `SET LOCAL` usage across live DB scripts/helpers. **New Risk #12** added for the PII purge migration/script mismatch with `recent_edit.original_text NOT NULL`.
docs/RISK-REGISTER.md:60:- 2026-05-16 (Day 2) — Risk #2 status entry updated: Sub-decision C **Accepted** per `bullhorn-integration-path.md` §4 + §5; Sub-decisions A and B **Proposed** with named reduction triggers (Sunday/Monday commercial conversations). Two staged severity reductions specified (High → Medium on commercial answers; Medium → Low on first Week 3-4 Bullhorn write landing clean). Risk #7 edit count revised from 5 to 6 (Bullhorn decision §6.6 sixth edit added — master brief §6 Day 2 line 466 `service-account for dev` correction). No new risks surfaced from Day 2 — Sub-decisions A and B Proposed is the intended honest state pending commercial verification, not a new risk surface.
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:89:          Scout from match; Janitor uses for dedup (stronger match signal
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:92:        source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:95:          - Janitor: R   # W only via dedup-merge action
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:175:          confirming candidate started. Janitor flags ambiguous via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:177:        source: IFOS-derived (Scribe + Janitor)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:180:          - Janitor: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:271:#   - Janitor contact: R → R+W (dedup + field-backfill on contacts; same
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:273:#   - Janitor opportunity: none → R (reads opportunity context for cleanup)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:274:#   - Janitor placement: R → R+W (lifecycle-state cleanup writes —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:276:#   - Janitor timesheet: none → R (reads for placement-state inference)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:280:#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:298:#   - Concierge placement: R → R+W (writes Bullhorn state advancement per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:302:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:304:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:373:    candidate: R+W         # dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:374:    contractor: R+W        # dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:376:    contact: R+W           # dedup + field-backfill writes
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
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:461:      - Janitor (R+W)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:474:      - Janitor (R+W)      # v0.3 UPGRADED — dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:480:      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:481:      preferred_channel + next_action_target_date; Janitor also dedup-merges).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:487:      - Janitor (R)        # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:493:      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:497:    v0_1_v1_0_agent_access: [Janitor (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:500:      - Janitor (R)        # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:506:      v0.1 opportunity is sparsely accessed (Janitor only); v0.3 broadens
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:512:    v0_1_v1_0_agent_access: [Janitor (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:514:      - Janitor (R+W)      # v0.3 UPGRADED — lifecycle-state cleanup writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:517:      - Concierge (R+W)    # v0.3 UPGRADED — writes Bullhorn state advancement
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:519:      v0.3 upgrades Janitor + Concierge to R+W (lifecycle-state writes per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:525:      - Janitor (R)        # v0.3 NEW — reads for placement-state inference
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:530:      v0.1 timesheet is Cash Conductor only. v0.3 grants R to Janitor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:535:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:538:      - Janitor (R+W)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:548:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:550:      - Janitor (R+W)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:562:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:565:      §12 conversation opener; Janitor for tacit-note narratives; Cash
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:572:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:574:      Janitor agent.md §7 calls hh_load_tone_rules filtered by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:576:      voice-classification. Per Round-8 Cat-β finding for Janitor.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:586:      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:593:      for retraining queue). Janitor adds R for tacit-note harvest per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:658:      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor links to Bullhorn placement.client_contact_id)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:714:    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:763:      Bullhorn for state transitions since this timestamp.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:864:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:910:    question: 6-state placement_status enum maps to Bullhorn's native state machine?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:912:      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:913:      B: Add Bullhorn-native states verbatim to the enum (likely 8-10 more).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:917:    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:955:  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:976:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/_supplementary/technical-strategy-v2.md:328:| **Structured DB (working memory)** | Per-agent state, job queues, deduplication keys, tenant metadata | Read/written by the control plane | Postgres (shared, tenant-scoped) |
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
docs/operations/bullhorn-outreach-emails.md:74:- If they require marketplace membership before production access → Sub-decision A is **Marketplace**; need cost + timeline to assess against kill-criterion §2 Trigger 3 (Janitor W5 deadline).
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
docs/operations/bullhorn-outreach-emails.md:151:2. **Monday 2026-06-01** — second nudge with explicit deadline reference ("we're targeting Janitor build W5; need clarity by then")
docs/operations/bullhorn-outreach-emails.md:152:3. **Wednesday 2026-06-03** — LinkedIn outreach to a named Bullhorn employee in partnerships or developer relations. Search "Bullhorn partnerships" or "Bullhorn developer advocacy" on LinkedIn; aim for a UK-based person if available.
docs/operations/bullhorn-outreach-emails.md:160:**Reference.** Two drop-in email drafts ready for founder to send. Expected wall-clock: 1 week for both responses. Outcome: Sub-decisions A + B flip Accepted; Risk #2 mitigated; Janitor W5 build unblocked.
docs/operations/bullhorn-outreach-emails.md:162:*End of Bullhorn outreach emails.*
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:222:        source: IFOS-derived (entity ID at edit time; Bullhorn ID or IFOS slug)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:436:      Bullhorn data (Q3 trigger from v0.1 §5).
docs/_supplementary/build-plan-original.md:299:- **Workflow** — (1) pull candidate list from source, (2) dedupe against CRM, (3) score against ICP rubric, (4) enrich top 10, (5) write to CRM with tags
docs/_supplementary/build-plan-original.md:862:- Existing SOP library in vault (for consistency of format + dedupe)
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/verticals/recruitment/vertical-schema.yaml:34:#   - bullhorn_source: the Bullhorn entity (and any status filter) this maps from
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:41:# `source: Bullhorn.<Entity>.<field>` means sourced from Bullhorn at ingest;
docs/verticals/recruitment/vertical-schema.yaml:51:    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
docs/verticals/recruitment/vertical-schema.yaml:53:      - Janitor (R+W — sweep + normalisation + dedup-merge proposals per bullhorn §4.1 A2)
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
docs/verticals/recruitment/vertical-schema.yaml:150:      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
docs/verticals/recruitment/vertical-schema.yaml:156:    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:169:        source: Bullhorn.Candidate.id
docs/verticals/recruitment/vertical-schema.yaml:170:        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
docs/verticals/recruitment/vertical-schema.yaml:174:        source: Bullhorn.Candidate.firstName
docs/verticals/recruitment/vertical-schema.yaml:178:        source: Bullhorn.Candidate.lastName
docs/verticals/recruitment/vertical-schema.yaml:182:        source: Bullhorn.Candidate.email
docs/verticals/recruitment/vertical-schema.yaml:186:        source: Bullhorn.Candidate.mobile
docs/verticals/recruitment/vertical-schema.yaml:218:      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
docs/verticals/recruitment/vertical-schema.yaml:223:      A company that hires through the recruitment agency. Master brief canonical vocabulary at §3.2 line 155 ("candidate, placement, brief") implicitly assumes client as the holder of briefs. Bullhorn calls this `ClientCorporation`.
docs/verticals/recruitment/vertical-schema.yaml:224:    bullhorn_source: Bullhorn.ClientCorporation
docs/verticals/recruitment/vertical-schema.yaml:226:      - Janitor (R+W — orphan-link sweep + normalisation per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:233:        source: Bullhorn.ClientCorporation.id
docs/verticals/recruitment/vertical-schema.yaml:237:        source: Bullhorn.ClientCorporation.name
docs/verticals/recruitment/vertical-schema.yaml:241:        source: Bullhorn.ClientCorporation.industryList
docs/verticals/recruitment/vertical-schema.yaml:242:        notes: Bullhorn stores as multi-value; v0.1 flattens to primary industry only.
docs/verticals/recruitment/vertical-schema.yaml:247:        source: Bullhorn.ClientCorporation.numEmployees (bucketed)
docs/verticals/recruitment/vertical-schema.yaml:251:        source: Bullhorn.ClientCorporation.companyURL
docs/verticals/recruitment/vertical-schema.yaml:261:        source: IFOS-derived (Janitor maintains)
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
docs/verticals/recruitment/vertical-schema.yaml:347:      - Janitor (R — status drift sweep per bullhorn §4.1 A2)
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
docs/verticals/recruitment/vertical-schema.yaml:434:      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:441:        source: Bullhorn.Placement.id
docs/verticals/recruitment/vertical-schema.yaml:445:        source: Bullhorn.Placement.dateBegin
docs/verticals/recruitment/vertical-schema.yaml:449:        source: Bullhorn.Placement.dateEnd
docs/verticals/recruitment/vertical-schema.yaml:455:        source: Bullhorn.Placement.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:460:        source: Bullhorn.Placement.employmentType (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:464:        source: Bullhorn.Placement.fee
docs/verticals/recruitment/vertical-schema.yaml:469:        source: Bullhorn.Placement.feeArrangement (parsed)
docs/verticals/recruitment/vertical-schema.yaml:474:        source: Bullhorn.Placement.salary
docs/verticals/recruitment/vertical-schema.yaml:489:        source: Bullhorn.Placement.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
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
docs/verticals/recruitment/vertical-schema.yaml:592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
docs/verticals/recruitment/vertical-schema.yaml:606:    v1_0_exercise: All 4 Bullhorn-touching v1.0 agents.
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
docs/verticals/recruitment/vertical-schema.yaml:682:  Janitor:
docs/verticals/recruitment/vertical-schema.yaml:683:    candidate: R+W   # full sweep + normalisation + dedup proposals
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
docs/verticals/recruitment/vertical-schema.yaml:805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
docs/verticals/recruitment/vertical-schema.yaml:811:    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
docs/verticals/recruitment/vertical-schema.yaml:828:    revisit_trigger: v2.0 T2 Timesheet agent build verifies against real Bullhorn data and expands.
docs/verticals/recruitment/vertical-schema.yaml:870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.
docs/verticals/recruitment/vertical-schema.yaml:886:      Structural cut. 8 entities + 10 relationships + agent-access matrix + Bullhorn mapping. Minimal field sets (10-20 per entity). 12 open questions catalogued (Q1, Q4 resolved at Day 6; Q2, Q3, Q5-Q12 deferred with named triggers).
docs/verticals/recruitment/vertical-schema.yaml:890:    expected_date: post Week 3-4 (after Janitor build verifies against real Bullhorn data)
docs/verticals/recruitment/vertical-schema.yaml:892:      Codex-ratified version. Field sets expanded per Janitor's real-Bullhorn-data findings (Q3 trigger). Possibly Note entity promoted to entity_type if Janitor surfaces query patterns (Q2 trigger). 2-3 revisions expected from v0.1.
docs/runbooks/operational-hygiene-protocol.md:175:**Day-6 retrospective check:** vertical-schema.yaml estimated 300-500. Per §4.1: 8 entities × 50 = 400 lines, 10 relationships × 10 = 100 lines, agent matrix + Bullhorn mapping + open questions + versioning = ~200 lines, header overhead = ~50 lines. **True estimate: 750 lines.** Actual: 899. ±20% range: [600, 900]. **Actual is within range.** The Day-6 estimate was the wrong number, not the work.
docs/runbooks/operational-hygiene-protocol.md:284:Day-5 autosend policy §3 + §10 cited `bullhorn-integration-path.md §4.1` as the canonical-orange anchor for Concierge `bullhorn_note_customer_visible`. Verified §4.1 establishes the action exists but does not explicitly frame as sensitive auto-send. Sensitivity framing lives in §6.3 ("Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI").
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
docs/runbooks/tenant-lifecycle.md:58:| `Bullhorn tenant corp_id` | From tenant's Bullhorn admin | Per `common-ats.json` |
docs/runbooks/tenant-lifecycle.md:151:| Bullhorn OAuth refresh | Per-agent 8-min cycle per `bullhorn-integration-path.md` §4.5; ESC_BULLHORN_AUTH on failure | (No invariant violation; runtime concern) |
docs/runbooks/tenant-lifecycle.md:363:  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
docs/_supplementary/execution-plan.md:209:  - *Prompt:* "Produce the full Lead Hunter agent bundle per Build Plan §5: `agent.md` (Haiku-targeted, ICP-rubric-driven prompt), `config.schema.json` (ICP definition schema with industry SIC codes, employee bands, geography, revenue, disqualifiers), `tools.yaml` (Companies House, Prospeo, Kaspr, HubSpot — declare as UK-context stack, NOT Apollo), `validate.sh` (JSON schema + dedup + completeness checks), `context.sh` (no heavy retrieval — inject current CRM record hashes for dedup), 3 test fixtures + golden lead outputs."
docs/operations/codex-ratification-guide.md:198:1. Status field says "Accepted" but §4 (Consequences) says "pending commercial conversations with Bullhorn partnerships team." Status drift. Either flip Status to "Proposed" with Sub-decision C as Accepted-only, or remove the "pending" caveat. Citation: ADR-001 line 7 vs §4.2.
docs/operations/codex-ratification-guide.md:247:Schema YAMLs. Uses `review-schema-change` skill — checks layering, agent matrix consistency, Bullhorn mapping alignment, open-question discipline.
docs/architecture/architecture-cohesion-review.md:89:| A2 | **`SET LOCAL` scopes the setting to the current transaction.** A connection pool with auto-commit could leak `app.current_tenant` across requests if `SET LOCAL` is wrong scope. | hook-helpers.sh `_hh_emit_row` issues `SET LOCAL` inside the same psql invocation as the INSERT — single transaction. | If connection pool shares connections across requests, `SET LOCAL` rolls back at commit; `SET` (non-LOCAL) would persist and cause leak. Helpers correctly use LOCAL. |
docs/architecture/architecture-cohesion-review.md:95:| A8 | **Bullhorn OAuth refresh-loop fires before token expiry under load.** Per-agent 8-min cycle vs 10-min TTL. | bullhorn-integration-path.md §4.5 + common-ats.json `auth_refresh_interval_seconds` | If the 2-min buffer is insufficient under network latency or rate-limit backoff, agent loses Bullhorn auth mid-write. Untested at scale; flagged at first Janitor build. |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:152:| G6 | **vault-concurrency.md `entities.version` enforcement is one-directional.** The doc names optimistic-concurrency UPDATE pattern but the helpers don't yet implement it (hook-helpers.sh has no entity-update path; that lands when an agent needs to write to `entities`). | Low (Janitor W5 will be first writer) | First entity-write helper at Janitor build adds version-check pattern. New ADR if pattern surfaces decisions. |
docs/architecture/architecture-cohesion-review.md:235:| R9 | A8: Bullhorn OAuth refresh timing under load | Low | First Janitor build stress test | Claude Code | Janitor W5 |
docs/architecture/architecture-cohesion-review.md:238:| R12 | G6: entities.version optimistic-concurrency helper | Low | First entity-write helper at Janitor build | Claude Code | Janitor W5 |
docs/operations/codex-ratification-execution-plan.md:73:| `review-mcp-connector.md` | New MCP connector checklist | ~200 | Pre-Janitor-W5 (not yet needed) |
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
docs/operations/codex-ratification-execution-plan.md:352:- **Option α** — Start immediately. Rationale: 33 items are already queued; Q1 turning YES will only ADD items (Diagnostic + Janitor + downstream). The 34-item queue is largely about Week 0 design artefacts that won't change post-LOI. Get them ratified now while context is fresh.
docs/operations/codex-ratification-execution-plan.md:353:- **Option β** — Wait for Q1 = YES. Rationale: master brief §10.6 framed first ratification run as Day 7; once-Week-0-closes implies the design-partner LOI exists. Some artefacts (Bullhorn integration Sub-decisions A+B) genuinely change post-commercial-conversations.
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:19:4. **`docs/specs/ULTRAPLAN.md`** §8.1 in full (per-agent A1-A6 specs, lines 495-572) + §9 (Bullhorn critical path, lines 720-770) + §10 (risk rows + contingencies)
docs/operations/goal-week-3-polish-and-scaffold.md:23:8. **`docs/decisions/bullhorn-integration-path.md`** §1.3 (commercial-blocker table) + §1.4 (fallback architecture) + §4.1 (per-agent Bullhorn surface)
docs/operations/goal-week-3-polish-and-scaffold.md:33:After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Six v1.0 agents: [list with weeks]. ULTRAPLAN §8.1 agent line ranges: [A1 lines 495-505, A2 lines 507-514, ...]. Week-3 scope confirmed. Ready to begin Step 1."**
docs/operations/goal-week-3-polish-and-scaffold.md:50:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:51:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:52:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:53:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:77:14. **`docs/RISK-REGISTER.md`** updated: Risk #2 (Bullhorn) blast radius confirmed reduced; Risk #5 (Renderer) state per Diagnostic ratification.
docs/operations/goal-week-3-polish-and-scaffold.md:93:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:101:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:102:| Bullhorn MCP connector wiring | Gated on Bullhorn Sub-decisions A+B response (sent 2026-05-24; expect 2-5 business days; if arrives mid-week, fold update into the relevant agent.md but do NOT start connector code) |
docs/operations/goal-week-3-polish-and-scaffold.md:286:### DAY 16 — Janitor agent.md scaffold (Step 8)
docs/operations/goal-week-3-polish-and-scaffold.md:291:- ULTRAPLAN §8.1 A2 lines 507-514 (full Janitor spec)
docs/operations/goal-week-3-polish-and-scaffold.md:292:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:293:- `bullhorn-integration-path.md` §4.1 (Janitor's Bullhorn entity surface)
docs/operations/goal-week-3-polish-and-scaffold.md:294:- `v1.0-kill-criterion.md` Trigger 3 (JANITOR-BULLHORN-AUTH-W5)
docs/operations/goal-week-3-polish-and-scaffold.md:295:- `vertical-schema.yaml` §3 agent_access_matrix Janitor row
docs/operations/goal-week-3-polish-and-scaffold.md:300:- **Status:** Proposed (pre-W5-build; awaits Bullhorn A+B + first pilot LOI)
docs/operations/goal-week-3-polish-and-scaffold.md:301:- **Build wave:** W5 per master brief §8.2 line 596
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:304:- **§3 Output shape:** day-30 report has 8 sections per ULTRAPLAN line 511 (record counts, dedup pairs, field-completeness deltas, tacit-note coverage, agent vs. consultant attribution, gate-B metric, exception list, executive summary).
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
docs/operations/goal-week-3-polish-and-scaffold.md:306:- **§5 Gate A:** validate.sh hard-fails on missing CTX env, dedup-rate >20% (suggests bad heuristic), field-write-error-rate >5%, schema-violation rows.
docs/operations/goal-week-3-polish-and-scaffold.md:307:- **§5 Gate B:** ≥15% dedup improvement + ≥10% field-completeness improvement per ULTRAPLAN line 512.
docs/operations/goal-week-3-polish-and-scaffold.md:309:- **§7 Voice + tone:** N/A (Janitor doesn't produce customer-facing output; all writes are internal data).
docs/operations/goal-week-3-polish-and-scaffold.md:310:- **§8 Build prerequisites:** Bullhorn MCP connector wired (W3 conditional; W4-5 if A+B answered) + first pilot tenant with Bullhorn corpToken in `_secrets.env`.
docs/operations/goal-week-3-polish-and-scaffold.md:311:- **§9 Open questions:** 4-6 questions covering dedup-heuristic confidence threshold, field-completeness priority order, Bullhorn write batch size, day-30 report distribution path.
docs/operations/goal-week-3-polish-and-scaffold.md:322:Commit: `decision(pre-build): agents/recruitment/janitor/agent.md — output contract per ULTRAPLAN §8.1 A2`
docs/operations/goal-week-3-polish-and-scaffold.md:330:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:331:- `bullhorn-integration-path.md` §4.1 (Scribe's Bullhorn write surface)
docs/operations/goal-week-3-polish-and-scaffold.md:336:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:339:- **§3 Output shape:** Bullhorn write payload (entity-type-specific JSON) + 1 tacit-note attachment + 1 audit row in decision_log.
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
docs/operations/goal-week-3-polish-and-scaffold.md:341:- **§5 Gate A:** validate.sh hard-fails on missing transcript, field-extraction confidence <0.6, Bullhorn write FK-violation, voice-classifier <0.75 on tacit note.
docs/operations/goal-week-3-polish-and-scaffold.md:345:- **§8 Build prerequisites:** Bullhorn MCP connector (R+W) + Fathom/Fireflies MCP connector (founder commercial signup) + LLM extraction prompt + voice classifier microservice (W5+).
docs/operations/goal-week-3-polish-and-scaffold.md:358:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:359:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:361:- ADR-005 §5.1 (Cash Conductor independence from Bullhorn — strategic value)
docs/operations/goal-week-3-polish-and-scaffold.md:365:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:367:- **§1 Output contract:** reconciles invoices against bank deposits; chases overdue payments via approved orange-tier email drafts (consultant approves before send); writes payment status updates to accounting system; generates weekly cash-flow report to `/vault/<tenant>/cash-conductor-reports/`. No Bullhorn dependency — operates entirely against Xero / QuickBooks / Sage + Open Banking.
docs/operations/goal-week-3-polish-and-scaffold.md:387:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:388:- `bullhorn-integration-path.md` §4.1 (Sourcing Scout's Bullhorn read surface)
docs/operations/goal-week-3-polish-and-scaffold.md:393:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:395:- **§1 Output contract:** ingests brief description; ranks passive candidates from Bullhorn database + LinkedIn search; outputs ranked match list with explanation per candidate.
docs/operations/goal-week-3-polish-and-scaffold.md:396:- **§3 Output shape:** Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-id>-<ISO-date>.md` with ranked candidate list (typically 5-20 matches); per-candidate confidence score + match rationale + Bullhorn CRN + LinkedIn URL.
docs/operations/goal-week-3-polish-and-scaffold.md:397:- **§4 Workflow:** ~10 steps. Brief fetch → keyword extraction → Bullhorn candidate search (filtered) → LinkedIn search (via Proxycurl or equiv) → semantic ranking → confidence scoring → match rationale generation → report assembly.
docs/operations/goal-week-3-polish-and-scaffold.md:402:- **§8 Build prerequisites:** Bullhorn MCP read + LinkedIn integration (Proxycurl signup OR LinkedIn API partner-tier) + ranking model (LLM-based or embedding-based).
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:416:- `bullhorn-integration-path.md` §4.1 (Concierge's Bullhorn write surface)
docs/operations/goal-week-3-polish-and-scaffold.md:420:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:421:- **Tier:** Tier 1 (continuous; lifecycle-event-driven via Bullhorn poll cycle)
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **§1 Output contract:** monitors Bullhorn placement-state transitions (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → day-7-check-in → day-30-check-in → day-90-check-in); generates customer-facing communication drafts at each lifecycle event; orange-tier autosend per Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:423:- **§3 Output shape:** message drafts (email / Bullhorn note customer-visible / SMS as configured); decision-log audit row per send; orange-tier spot-check sampling at 1-in-N rate per autosend-safety-policy §4.
docs/operations/goal-week-3-polish-and-scaffold.md:424:- **§4 Workflow:** ~15 steps. Bullhorn poll every 5 min → detect state transition → fetch context (candidate + client + placement entities) → identify message template → LLM draft → voice classifier ≥0.75 → tone-rule check → tier classification → autosend bridge call (per D1 decision) → audit row.
docs/operations/goal-week-3-polish-and-scaffold.md:429:- **§8 Build prerequisites:** D1 autosend orange-tier decision RESOLVED + Bullhorn MCP R+W + voice classifier microservice live + approval bridge built (per D1 outcome) + tenant tone_rule table seeded.
docs/operations/goal-week-3-polish-and-scaffold.md:459:1. **`.agents/current-priorities.md`** — Day-20 Week-3 close section. List shipped artefacts. Update Open backlog: Week 4 (Cash Conductor build OR Bullhorn-dependent agent depending on A+B status).
docs/operations/goal-week-3-polish-and-scaffold.md:460:2. **`docs/RISK-REGISTER.md`** — Risk #2 (Bullhorn) status per A+B response state; Risk #5 (Renderer) updated per Diagnostic ratification.
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:589:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:616:  Janitor (W5):           <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:640:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:647:  Track 1 (Bullhorn-INDEPENDENT — proceed regardless of A+B response):
docs/operations/goal-week-3-polish-and-scaffold.md:653:  Track 2 (Bullhorn-GATED — conditional on A+B Accepted):
docs/operations/goal-week-3-polish-and-scaffold.md:654:    - Bullhorn MCP connector (auth + read + write endpoints)
docs/operations/goal-week-3-polish-and-scaffold.md:655:    - Janitor build (depends on Bullhorn R+W)
docs/operations/goal-week-3-polish-and-scaffold.md:656:    - Scribe build (depends on Bullhorn W + Fathom MCP)
docs/operations/goal-week-3-polish-and-scaffold.md:669:  - Approve Track 1 vs Track 2 priority (depends on Bullhorn A+B status)?
docs/operations/goal-week-3-polish-and-scaffold.md:683:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/operations/seedlegals-engagement-queries.md:68:> 1. **Service scope:** SaaS-delivered AI agent fleet for UK recruitment agencies (Bullhorn ATS integration; bounded action set defined in autosend-safety-policy attached as Appendix A).
docs/operations/seedlegals-engagement-queries.md:76:> 5. **PII jurisdiction:** UK only. SaaS vendor processes data within UK + EEA only; no transfer to US or other adequacy-decision-uncovered jurisdictions. Bullhorn data centre = UK per pilot agreement.
docs/operations/seedlegals-engagement-queries.md:157:- Bullhorn's own DPA terms — does our customer's DPA conflict with Bullhorn's processor agreement?
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:49:**Codex says:** "Line 169 claims Diagnostic's 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:119:| Janitor | ~5-7 (count regex inflated; 56 numbered items including nested) | `logs/codex-ratification/20260524T102050Z-21293/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:155:## Janitor Round-5 (remediation) — empirical confirmation of bilateral pattern
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:157:After all 6 Round-4-v2 issues remediated on Janitor (commit `2392af8`), Round-5 ratification returned REJECTED with **5 NEW findings** — none of the original 6 reappeared. New issues at Janitor session `20260524T103757Z-37420`:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:159:1. **Autosend tier contradiction internal to artefact:** §1 says all Bullhorn writes yellow-tier; §3.Output 2 mapped tacit-note to `bullhorn_candidate_tag` which is GREEN. Internal §1/§3/§4 inconsistency.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:161:3. **§5 vs §6 ESC code contradiction:** §5 prose retains `ESC_SCHEMA_VIOLATION` reference even though §6 explicitly says Janitor doesn't use it. Mechanical fix missed by my Round-4-v2 remediation.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:184:## Janitor Round 6 (exceeds hard ceiling) — 4 more NEW findings, all different from Rounds 4-5
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:188:1. Gate B composite score (≥12.5) weakens dual ULTRAPLAN thresholds (15% dedup AND 10% field-completeness independently)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:210:## Janitor Round 7 — 23+ unique issues; pattern definitively closed
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:212:After all 4 Round-6 issues remediated on Janitor (commit `1939d9b`), Round 7 returned REJECTED with **4 more new findings**, none from Rounds 4-6:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:273:| Janitor | 6 | `20260524T112807Z-81339` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:289:- Janitor: `candidate.linkedin_url` not in schema
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:299:- `ESC_LIFECYCLE_STATE_UNKNOWN` — Concierge uses for taxonomy misses; catalogue defines for Janitor placement ambiguity. Resolution: widen.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:315:  - Janitor Step 1 auth refresh emits ESC without decision row
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:324:**Cumulative empirical:** 9 Codex rounds total (Round 4-v1, 4-v2, 5, 6, 7 on Diagnostic/Janitor + Round 8 across all 6). **55+ unique findings catalogued across rounds, ~10-12 fixed via Cat-α mechanical disposition in this bilateral session; rest queued.**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:330:- Janitor: pre-build-scaffold; Round-8-reviewed; ~3 schema-supplement findings (Cat-β) + ~2 catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:357:- `ESC_LIFECYCLE_STATE_UNKNOWN` — both Janitor placement + Concierge taxonomy out-of-bounds
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:371:| Janitor | 6 | 6 | 0 (different findings; 1 Cat-γ closed, 1 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:374:| Sourcing Scout | 4 | 5 | +1 (Q7 enum claim missed by my Round-8 fix; Bullhorn webhook conflict newly surfaced) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:393:4. Bullhorn webhook v1.0 trigger conflicts with bullhorn-integration-path.md (webhooks v1.1+ only) — Cat-β-adjacent; agent.md should remove v1.0 webhook trigger
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:427:| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:430:| Sourcing Scout | Pre-Build-Round-9-Reviewed | 5 (Cat-α Q7 + bullhorn-path conflict + Cat-γ DNC + Cat-ε per-candidate row + auth severity disagreement) | Mechanical Q7 fix + Bullhorn-path realignment + ESC widening 2 |
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:6:**Maps to:** Week-3 + Week-4 work pulled forward; Week-3 Bullhorn-MCP work deferred pending Sub-decisions A+B response.
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:166:- Search for a real UK firm ("Bullhorn UK" or similar — known to exist)
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:252:- **Decision:** Week 3 (Days 13-20) repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build. Week 4 (Days 21-27) repurposed from Diagnostic-build to Diagnostic-polish + Codex ratification + (conditional) Bullhorn-MCP-build if A+B answered.
docs/operations/goal-option-c-diagnostic-end-to-end.md:253:- **Consequences:** Janitor W5 build conditional on Bullhorn A+B Accepted. If A+B answer arrives after 2026-06-03, Janitor slips to W6+; if no answer by 2026-06-10, force Direct-API fallback per `bullhorn-integration-path.md` §1.4.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-option-c-diagnostic-end-to-end.md:257:Commit: `decision(ADR-005): Week 3 repurposed Bullhorn-MCP → Diagnostic acceleration`
docs/operations/goal-option-c-diagnostic-end-to-end.md:266:- Risk #2 (Bullhorn MCP build): note Diagnostic-doesn't-need-Bullhorn path explored Day-13; reduces blast radius if Bullhorn response delayed
docs/operations/goal-option-c-diagnostic-end-to-end.md:409:  - [Proceed to Week-4 polish OR wait on Bullhorn response before Janitor W5?]
docs/build-brief/00-MASTER-BRIEF.md:44:We add: a vertical schema for UK recruitment; 18 agents in the v2 bundle pattern; an Obsidian-style wiki + graphify second brain that **replaces** cortextOS's stock knowledge-base behind the `bus/kb-*.sh` boundary; MCP connectors for Bullhorn/Companies House/Xero/Microsoft Graph; an entity-graph + decision-log Postgres layer with RLS; a per-tenant LoRA pipeline (v2.0 work); and a five-day onboarding wizard.
docs/build-brief/00-MASTER-BRIEF.md:135:1. **Build it in our product layer.** Recruitment-specific (a candidate-deduplication helper, an SDS-adequacy parser) → `packages/<our-package>/`. Done.
docs/build-brief/00-MASTER-BRIEF.md:149:| Bullhorn, Vincere, Voyager Infinity | `packages/mcp-connectors/{name}/` first-party MCP | Vertical-specific; our moat |
docs/build-brief/00-MASTER-BRIEF.md:314:│       │   └── ats-snapshots/    ← Bullhorn entity snapshots
docs/build-brief/00-MASTER-BRIEF.md:348:1. **Ingest (`kb-add`).** An agent (Scribe, Triage, Janitor, etc.) drops a raw artefact into `raw/{category}/`. Ingest writes the file with provenance frontmatter (`source: scribe-agent`, `ingested_at: ...`, `tenant_id: ...`).
docs/build-brief/00-MASTER-BRIEF.md:456:### Day 2 — Tuesday — Bullhorn integration path
docs/build-brief/00-MASTER-BRIEF.md:458:- [ ] Decision: Bullhorn Marketplace vs Direct API. OAuth model: authorization-code grant for production tenants; authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (Bullhorn does not support `client_credentials` grant for tenant-scoped data per Bullhorn OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`). Document in `docs/decisions/bullhorn-integration-path.md`.
docs/build-brief/00-MASTER-BRIEF.md:490:3. Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:568:**Change 2 — Decision logging is enforced.** Three required calls per agent run:
docs/build-brief/00-MASTER-BRIEF.md:582:- `ESC_DUPLICATE_DETECTED` — high-confidence dedup needs human review
docs/build-brief/00-MASTER-BRIEF.md:596:| 2 | Janitor | 5 | Bullhorn MCP (R+W) | First demoable inside-ATS result; day-30 before/after closes deals |
docs/build-brief/00-MASTER-BRIEF.md:597:| 3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | Post-call note in Bullhorn within 10 min — second-most-demoable |
docs/build-brief/00-MASTER-BRIEF.md:600:| 6 | Concierge | 10–13 | Bullhorn + MS Graph + AgentMail | First Tier-1 always-on closing demo; 4-week build |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:695:        │  • First-party MCP  packages/mcp-connectors/: Bullhorn, Companies House, Xero, etc.        │
docs/build-brief/00-MASTER-BRIEF.md:766:- Day 7: Codex reviews the seven Week 0 artefacts (primitive audit, Bullhorn path, Brain UI scope, infra checklist, safety policy, kill criterion, vertical schema v0.1) — first ratification run
docs/build-brief/00-MASTER-BRIEF.md:795:- Negotiating Bullhorn marketplace terms — phone call
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/build-brief/00-MASTER-BRIEF.md:828:| "Let me use Composio for the Bullhorn connector..." | §3.2 |
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/build-brief/00-MASTER-BRIEF.md:973:- Use Composio for Bullhorn because "the catalogue says they have it" (they don't, and even if they did, see §3.2)
docs/operations/founder-legal-setup-guide.md:18:2. **Takes autonomous actions** on behalf of recruitment agencies (LinkedIn messages, Bullhorn writes, payment reminders). This creates **professional liability** — if your AI sends a wrong payment chase to a settled invoice, the agency may be liable to the candidate; they may seek to pass that liability to you.
docs/operations/founder-legal-setup-guide.md:121:2. *"My AI agents make autonomous edits to candidate-facing communications and trigger autonomous actions (LinkedIn sends, Bullhorn writes, payment chases). Where does liability sit for AI mistakes? What's the standard liability split — and do SeedLegals or off-the-shelf templates capture it?"*
docs/operations/founder-legal-setup-guide.md:194:> Our specific risk profile includes autonomous AI agents making bounded edits to candidate communications and triggering actions in third-party systems (Bullhorn, LinkedIn, payment systems). I want to ensure liability is appropriately allocated.
docs/operations/founder-legal-setup-guide.md:219:> - AI agents make autonomous actions on behalf of pilot customers (LinkedIn messages, Bullhorn data writes, payment reminders)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/architecture/agent-bundle-renderer-design.md:45:| `tools.yaml` (line 554) | MCP servers + scopes + degraded modes for external execution backends (Bullhorn, Companies House, Microsoft Graph etc. per master brief §3.2 first-party MCP list) | the renderer (passes through to rendered agent dir); agent uses it via Claude Code's MCP loading at PTY spawn time | **Static** — founder writes once per agent |
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:145:| `heartbeat` | cortextOS heartbeat cadence — periodic `update-heartbeat` writes to `${ctxRoot}/heartbeats/{name}.json` so the dashboard sees "alive" status | IFOS agents emit heartbeats too (the daemon's fast-checker writes them per `agent-process.ts:597-639` session timer), but the *cadence* and *what the agent does at each heartbeat* is specced per-agent in `agent.md` (Concierge always-on; Janitor cron-driven; etc.). The cortextOS-template `heartbeat/SKILL.md` is a default playbook — IFOS replaces with per-agent specifics |
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:228:On every ATS state change (Bullhorn webhook) or scheduled lifecycle event
docs/architecture/agent-bundle-renderer-design.md:369:Decision-log calls are mandatory per master brief §8.1 Change 2:
docs/architecture/agent-bundle-renderer-design.md:437:BULLHORN_OAUTH_TOKEN=<acme Bullhorn OAuth bearer>
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/operations/codex-round-2-autonomous-prompt.md:198:    - Bullhorn Week-1 gate (item 20): <RATIFIED|REJECTED>
docs/operations/codex-round-2-remediation-prompt.md:203:      voice-loader — none of which reference Bullhorn). A+B MUST flip
docs/operations/codex-round-2-remediation-prompt.md:204:      to Accepted before Janitor (W5) build starts per
docs/operations/codex-round-2-remediation-prompt.md:205:      `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/operations/codex-round-2-remediation-prompt.md:213:  Three distinct gates govern Bullhorn-touching work, in temporal order:
docs/operations/codex-round-2-remediation-prompt.md:218:  | Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (sequencing-target §2.1) | Awaits Q1 LOI |
docs/operations/codex-round-2-remediation-prompt.md:219:  | Janitor W5 build | A+B Accepted (commercial conversations complete) | Pending |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:34:**Cost of deferral:** Concierge W10 build risks slipping if bridge isn't ready. Concrete delay: ~3 days. Risk #2 (Bullhorn) is the bigger blocker for Concierge (auth path); D1 is downstream of that.
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:185:The flock (§2) prevents two operations from racing the same file's read-then-write. The Postgres version check (§3) catches the rare case where flock acquisition succeeded sequentially but a *different* code path (e.g. cron-driven full-table update in Janitor's nightly sweep) updated the row without holding flock.
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/ADR-003-agent-bundle-renderer.md:145:**For Week 0 remaining (Day 2 through Day 7).** ADR-003 doesn't unblock or block any remaining Week 0 work directly. Day 2 (Bullhorn integration path), Day 3 (sequencing + Brain UI scope), Day 4 (Postgres provisioning with `entities` + `entity_links` split per ADR-002 Edit 3 + `_secrets.env` skeleton), Day 5 (auto-send safety policy + kill criterion), Day 6 (vertical schema v0.1), Day 7 (single-sentence test + first Codex ratification) all proceed independently. The renderer is queued for Codex Day-7 review but does not gate Day 7's other reviews.
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:175:│   │   └── ats-snapshots/                          ← Bullhorn entity snapshots (master brief §5.1 line 321)
docs/architecture/second-brain-design.md:207:| `wiki/raw/ats-snapshots/` | one file per entity sync | JSON | `{epoch}-{bullhorn-entity-type}-{bullhorn-id}.json` | Janitor (v1.0) on nightly sweep | Janitor itself (diff vs previous), Concierge (v1.0) for entity reconciliation |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:210:| `wiki/compiled/clients/{slug}.md` | one per Client | same | same | Janitor (v1.0) on first contact | Cash Conductor + Concierge (v1.0) |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:236:| Client | **v1.0** | Janitor + Cash Conductor + Concierge all require it |
docs/architecture/second-brain-design.md:237:| Brief | **v1.0 (skeleton) / v1.1 (full)** | Sourcing Scout (v1.0 A5) needs to *read* a Brief to source against; Brief Decoder (v1.1 A8) is the producer. v1.0 writes minimal Briefs (manual entry or direct Bullhorn sync via Janitor); full lifecycle waits for v1.1 |
docs/architecture/second-brain-design.md:263:bullhorn_id: 12345                                   # optional; external ATS reference (Janitor populates)
docs/architecture/second-brain-design.md:264:linkedin_url: https://linkedin.com/in/sarah-bowen    # optional; Janitor populates
docs/architecture/second-brain-design.md:274:{Janitor or Scribe one-paragraph summary, regenerated on each ingest}
docs/architecture/second-brain-design.md:305:companies_house_number: 12345678                     # optional; UK-specific; Janitor populates
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:424:| `search-by-relationship` | Janitor (v1.0): all Candidates linked to Brief X for dedup | v1.0 | `(from_id: str, link_type: str, tenant_id: str)` | `List[EntityRef]` | few seconds | Postgres `entity_graph` traversal; one-hop only in v1.0, multi-hop deferred to graph view v1.2 |
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:459:  - **Git:** **Spec gap 2.4-A.** Neither master brief nor Ultraplan specifies whether `/vault/{tenant}/` is also a git repo. Obsidian users typically git-init their vaults. **Recommendation:** yes — initialize `/vault/{tenant}/.git/` at tenant provisioning (Ultraplan §5.5 step 2). Founder gets free history, blame, and rollback via Obsidian Git plugin. Agents do NOT commit; the founder commits manually or via a scheduled cron run by Janitor's nightly sweep. **Blocks v1.0 build:** no — git init is one line in `provision-tenant.sh`; commit cadence can be decided in Week 1.
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:607:- compiled/ entity pages — searched by `search-by-name` (trigram) and `search-by-attribute` (JSONB GIN). Embedding compiled/ pages is v1.1+ if reflect.ts wants semantic dedup.
docs/architecture/second-brain-design.md:709:- t=0+50ms: Janitor calls `update-entity(candidate_sarah_bowen, "right_to_work_status", "verified")`. Blocks on the flock.
docs/architecture/second-brain-design.md:711:- t=0+301ms: Janitor acquires flock. Reads file (now contains Concierge's append). Reads Postgres (`updated_at = T1`). Computes new frontmatter. Writes file atomically. Postgres UPDATE `WHERE updated_at = T1` succeeds (`updated_at = T2`).
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:761:- `ingest-entity` — Janitor's nightly sweep ingests thousands of records; batching is the model. Per-record latency 100ms-1s is fine.
docs/architecture/second-brain-design.md:775:| Janitor | 1:5 | reads each Bullhorn entity once; writes many cleanup updates per sweep |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:893:| **Consistency with cortextOS bus convention** | Identical pattern: 47 existing bus wrappers under `packages/harness/cortextos/bus/` all do `exec node dist/cli.js bus <command>`. Option α uses the same 3-line shim shape. Zero cognitive tax for an engineer who already understands cortextOS. | New surface (MCP). Aligns with the vertical-adapter pattern (master brief §3.2) where Bullhorn / Companies House etc. are MCP servers — so consistent with that pattern, not with the bus pattern. | Aligns with cortextOS's skill convention (each template ships `.claude/skills/` with kb / memory / tasks / heartbeat / etc.). Inconsistent with the bus pattern; consistent with the skill pattern; awkward under R2. |
docs/architecture/second-brain-design.md:907:2. **Master brief §8 (Agent Bundle v2 pattern + `tools.yaml` contract).** §8.1 specifies the bundle has `tools.yaml` for "MCP servers + scopes + degraded modes" — i.e. external MCP connectors (Bullhorn, Companies House, Xero). The wiki is **internal** to IFOS, not an external execution backend. Treating wiki ops as bus commands (Option α) keeps `tools.yaml` clean of internal-surface declarations; treating them as MCP tools (Option β) conflates internal-data-access with external-tool-invocation in the same `tools.yaml`.
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:161:The bus is real, well-tested at unit and integration layers, with HMAC-SHA256 message signing and a documented 3-directory lifecycle. However, **two pieces of the master-brief description are wrong against the verified SHA `c21fbfe`** — flagged below; both affect the brain-replacement boundary (§3.4) and need founder review before Day 7.
docs/architecture/cortexos-primitive-status.md:169:- `src/bus/message.ts:19-44` — HMAC-SHA256 signing using `${ctxRoot}/config/bus-signing-key`. Quirk 5 in `.agents/learnings/00-cortextos-quirks.md` confirms each instance has its own key (IFOS and Personal have separate HMAC keys).
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/decisions/2026-05-18-day-7-single-sentence-test.md:18:> 3. Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?
docs/decisions/2026-05-18-day-7-single-sentence-test.md:34:- **Pipeline state:** zero design partners in pipeline as of 2026-05-18 Day 5; founder did not initiate the Sunday/Monday outreach paths queued in `bullhorn-integration-path.md` §1.3 (Bullhorn partnerships, Bullhorn dev support, design partner #1) because no named target existed for design-partner #1 path; warm-path strategy supersedes cold outreach.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:57:  - **Bullhorn partnerships outreach** (`partnerships@bullhorn.com`): not sent. Confirms marketplace-vs-direct cost delta at 3-tenant scale + production-tenant partnership requirement.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:58:  - **Bullhorn developer support outreach** (developer.bullhorn.com): not sent. Confirms auth-code flow specifics, sandbox / dev tenant model, per-entity OAuth scope granularity, refresh-token rotation atomicity.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:59:  - **Design partner #1 conversation 2** (ATS confirmation): not had. The design partner gap from Q1 means we cannot confirm pilot #1 actually uses Bullhorn vs a different ATS.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:60:- **Risk #2 in `docs/RISK-REGISTER.md`** carries Bullhorn auth path status: High while Sub-decisions A and B are Proposed. Reduction trigger to Medium requires the commercial conversations to land.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:79:- **Depth:** 89 canonical fields, 10 entity_links relationships, agent × entity R/W matrix across all 6 v1.0 agents (cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3), Bullhorn mapping per entity, 12 open questions catalogued (Q1+Q4 resolved inline; Q2/Q3/Q5-Q12 deferred with named revisit triggers).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:92:| 3 | ATS decided + auth cleared? | **NO** | Build decided YES (Bullhorn); auth path NOT cleared (Sub-decisions A+B Proposed, no commercial outreach) |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:116:5. **Bullhorn commercial conversations** — `partnerships@bullhorn.com`, Bullhorn dev support, design-partner #1 ATS confirmation. Flips Sub-decisions A+B Proposed → Accepted, reduces Risk #2 from High to Medium, resolves Q3 partially.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:133:- If re-run produces 4 of 5 YES (Q3 still NO because Bullhorn commercial conversations haven't completed), founder may accept Q3 as risk-noted and declare Week 0 closed with Week 1 starting under that accepted risk. This is a founder-discretion call, not automatic from the master brief test.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:134:- If re-run produces 5 of 5 YES (Q3 also turns YES because design partner #1 confirms Bullhorn and commercial gates align), Week 0 closes cleanly.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:138:Bullhorn commercial conversations (`partnerships@bullhorn.com`, Bullhorn dev support) flip Sub-decisions A+B Proposed → Accepted regardless of Q1 status. These conversations don't unblock Week 1 alone but they reduce Risk #2 from High to Medium and tighten the auth-path readiness.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:143:- Q1 = YES, Q3 = NO (accepted) → Week 0 closes by founder discretion; Week 1 starts with Risk #2 elevated; Diagnostic W3-4 begins under accepted risk; Janitor W5 contingent on Q3 clearing by then.
docs/decisions/v1.0-kill-criterion.md:33:- **ATS pivot:** Bullhorn-first → Vincere-first, Voyager Infinity-first, or vertical-without-ATS
docs/decisions/v1.0-kill-criterion.md:73:### Trigger 3 — JANITOR-BULLHORN-AUTH-W5 (PIVOT)
docs/decisions/v1.0-kill-criterion.md:75:**Threshold:** Janitor agent cannot authenticate to Bullhorn via the documented OAuth flow (per `bullhorn-integration-path.md` §4.5 refresh-loop architecture) by end of Week 5 (2026-06-28). Authentication failure modes that trigger: (a) OAuth token endpoint returns non-2xx persistently; (b) refresh-loop architecture fails at 10-minute TTL boundary; (c) Bullhorn rate-limits IFOS's auth endpoint preventing pilot operations; (d) Bullhorn partnership programme requirement blocks production-tenant access.
docs/decisions/v1.0-kill-criterion.md:81:**Action:** PIVOT state. Rescope from Bullhorn-first to alternate ATS-first:
docs/decisions/v1.0-kill-criterion.md:83:- **Option A:** Vincere-first. Mid-market UK recruitment ATS; smaller market than Bullhorn but more accessible API.
docs/decisions/v1.0-kill-criterion.md:85:- **Option C:** ATS-agnostic with manual data sync. Reduces v1.0 to read-only agent operation against ATS export files; loses much of the Janitor + Concierge value but unblocks pilot acquisition.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:128:- Bullhorn API call at <£0.001 per action (free tier)
docs/decisions/v1.0-kill-criterion.md:158:### Trigger 8 — GATE-B-REVENUE-UPLIFT (KILL)
docs/decisions/v1.0-kill-criterion.md:227:- **Trigger 8 (Gate-B revenue) KILL:** founder decides KILL on revenue evidence; consults Jack on wind-down terms with existing pilots before 30-day notice goes out.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:339:- The ATS assumption: Bullhorn-first per `bullhorn-integration-path.md` Sub-decision C
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:1:# ADR-005 — Week-3 Diagnostic acceleration (Bullhorn MCP deferred)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:18:| 3 | **Bullhorn MCP server build** (auth, read endpoints, write endpoints, webhook subscription) per ULTRAPLAN line 752 |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:20:| 5 | Janitor (Bullhorn R+W) |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:29:- **Bullhorn Sub-decisions A + B remain Proposed.** Founder submitted Bullhorn partnerships form 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (commit `dc15692`); response expected 2-5 business days.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:30:- **Without Sub-decision A answered, Week-3 Bullhorn-MCP work is structurally blocked:** we don't know whether marketplace registration is required for production OR whether direct-tier developer-program access suffices.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:35:**Week 3 (Days 13-20) is repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build. Week 4 (Days 21-27) is repurposed from Diagnostic-build to Diagnostic-polish + first-pilot-prep + (conditional) Bullhorn-MCP-build if A+B answered.**
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:41:| W3 Days 13-20: Bullhorn MCP server build | W3 Days 13-20: Diagnostic end-to-end (per `goal-option-c-diagnostic-end-to-end.md`) |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:42:| W4 Days 21-27: Diagnostic end-to-end | W4 Days 21-27: Diagnostic polish + first-pilot prep + Bullhorn MCP if A+B answered |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:43:| W5 Day 28+: Janitor build start | W5 Day 28+: **Conditional on Bullhorn Sub-decisions A+B Accepted** |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:48:2. **The Week-4 milestone is achievable today.** ULTRAPLAN line 755: *"Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."* Option C produces exactly this; the dependencies (LinkedIn + Companies House + scrape) are independent of Bullhorn.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:49:3. **Week-3 time is otherwise idle.** Bullhorn MCP build cannot proceed without commercial answer. Spending Week 3 on Diagnostic uses that time productively.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:63:### Week 5 (Day 28+) — Janitor build conditional gating
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:65:| Bullhorn A+B state by Day 28 | Janitor action |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:69:| Bullhorn unresponsive past 2026-06-10 | Force Direct-API fallback per `bullhorn-integration-path.md` §1.4; Janitor scaffold begins; Bullhorn auth gated on first pilot raising support ticket |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:73:- Scribe (W6) depends on Bullhorn write; same gating as Janitor
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:75:- Sourcing Scout (W9) touches Bullhorn read; same gating
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:76:- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:86:- Founder commercial workstream (Bullhorn + SeedLegals + Q1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:107:- ULTRAPLAN §10 Risk #2 row contingency (defer Bullhorn-touching agents)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:110:- `bullhorn-integration-path.md` §1.4 (Direct-API fallback architecture for slow Bullhorn response)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:117:| When does Bullhorn respond? | 2-5 business days from submission (sent 2026-05-24); hard cutoff 2026-06-10 per §1.4 fallback |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:14:> The document claims Week-1 implementation can proceed before the auth path is cleared. Lines 57-72 list commercial blockers for Sub-decisions A/B, but line 95 says those can remain Proposed without blocking Week-1 implementation. That weakens the Day-7 auth-path quality gate. Fix by making Bullhorn connector scaffolding explicitly conditional on A/B resolution or by narrowing Week-1 work to non-auth code only.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:20:**Counter:** Codex is applying the Day-7 single-sentence-test Q3 quality gate ("ATS decided + auth cleared") as if it were a Week-1 implementation gate. The Q3 gate is correct as a closing-of-Week-0 gate per master brief §6 line 502, and Q3 = NO is exactly why Week 0 EXTENDS per the Day-7 single-sentence-test result. But the Q3 gate governs **named v1.0 agent-build slices** (Diagnostic W3-4, Janitor W5, etc.), NOT Week-1 prerequisite code.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:29:**None of these reference Bullhorn at all.** They are tenant-agnostic + adapter-agnostic substrate. Sub-decisions A+B remaining Proposed (commercial questions about marketplace partnership + dev tenant access) does not block these.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:31:Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:41:| Diagnostic build (W3-4) | None — Diagnostic doesn't touch Bullhorn | Awaits Q1 LOI |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:42:| Janitor build (W5) | A+B Accepted (commercial conversations complete) | Pending |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:44:Codex over-applied the Q3 gate from "Week-0 close" + "named agent-build slices" down to "Week-1 implementation generally" — a category error. Week-1 prereq code is upstream of all agent builds; it doesn't need Bullhorn auth resolved.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:67:which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:68:build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:81:- **Tighten the gate (Codex's read)** — make all Week-1 implementation conditional on A+B Accepted. Forces all 5 Week-1 prereq commits to be re-classified as W5-prereq. Operationally complex + arguably wrong (renderer doesn't need Bullhorn auth to render).
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:86:**Resolution update (2026-05-22):** [x] Incorporated via "Counter-argued + sharpen wording." The source decision now encodes the prereq-code-only gate and the W5 Janitor auth gate explicitly.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:40:Recommend a one-paragraph footnote in §2.4 that names the substrate: messages are JSON files under `${ctxRoot}/inbox/<to>/{pnum}-{epochMs}-from-{sender}-{rand5}.json`, three-directory lifecycle (`inbox → inflight → processed`), HMAC-SHA256 signed (Quirk 5), stale-inflight recovery at 5 minutes.
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:33:| 18 | `docs/verticals/recruitment/vertical-schema.yaml` | Proposed | Verify 8 entities + 89 fields + 10 relationships + agent R/W matrix + 12 open_questions; cross-check Bullhorn mapping against §4.1 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:144:| 1 | `agents/recruitment/diagnostic/agent.md` | **REJECTED** | 5 real findings (Gate A strength + Step 11 decision-log + Trigger 8 mismap + sentinel + validate.sh gap) | `20260524T101934Z-19923` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:269:| 6 | §6 Day 2 line 466 OAuth wording | Bullhorn §6.6 | ✓ verbatim |
docs/decisions/2026-05-18-codex-ratification-manifest.md:287:| 7 | `bullhorn-integration-path.md` Sub-decisions A+B | Proposed pending commercial conversations | Either (a) run the Bullhorn outreach + design-partner #1 conversation during extension and flip to Accepted, OR (b) accept ratification of Sub-decision C only, with A+B explicitly marked "deferred to first pilot's actual ATS confirmation" |
docs/decisions/bullhorn-integration-path.md:1:# Bullhorn integration path — decision document
docs/decisions/bullhorn-integration-path.md:6:**Surfaced by:** Master brief §6 Day 2 (lines 466-467) — "Decision: Bullhorn Marketplace vs Direct API. OAuth model: browser dance for production, service-account for dev." Plus Ultraplan §11 Day 2 (lines 847-849).
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:19:**Sub-decision A — Bullhorn integration path.** Marketplace partner programme membership (with its access tier, scope, certification, ongoing fees) versus direct API access (per-tenant Bullhorn-account-admin authorisation of IFOS as a connected app). Master brief §6 Day 2 line 466 explicitly names this as the day's decision. The path chosen determines whether `packages/mcp-connectors/bullhorn/` ships as a marketplace-registered connector or a direct-API connector — the *code* in either case is similar OAuth + REST plumbing, but the *operational, commercial, and rate-limit* surfaces differ materially.
docs/decisions/bullhorn-integration-path.md:21:**Sub-decision B — OAuth flow.** Master brief §6 Day 2 line 466 pre-states a recommendation: "browser dance for production, service-account for dev." This is the authorization-code grant (per-tenant browser dance, refresh-token cycle) for production tenants, plus client-credentials grant (service account) for IFOS-internal sandbox/dev work. Sub-decision B verifies that recommendation against Bullhorn's actual OAuth implementation and pins the per-tenant token storage path (per `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution: `/vault/<tenant>/_secrets.env`, mode `0600`).
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:27:Master brief §12 Risk #2 (Bullhorn auth path) — "Bullhorn MCP build takes longer than 1 week" — names this as one of the four risks that could kill v1.0. Tripwire: "End of week 3 status not 'core read endpoints working'" (master brief §12 row #2, Ultraplan §10 row #2). The mitigation is "Week 0 Day 2 on Bullhorn auth research" — i.e. this document. Without Sub-decisions A and B answered, Week 1 cannot begin scaffolding `packages/mcp-connectors/bullhorn/` because the connector's authentication path determines its scope and shape.
docs/decisions/bullhorn-integration-path.md:29:**Bullhorn dependency count for v1.0 agents:**
docs/decisions/bullhorn-integration-path.md:31:| Agent | Bullhorn dependency in v1.0 | Source |
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:42:This is also the Day 2 critical-path artefact for the §6 Day 7 single-sentence test (master brief §6 lines 494-502, Ultraplan §12 lines 887-895), question 3: "Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?" A Yes answer requires this document plus the Sub-decision A and B confirmations to land before Sunday review.
docs/decisions/bullhorn-integration-path.md:48:**Technically grounded (Claude Code can analyse tonight from Bullhorn public documentation + master brief / Ultraplan / product spec context):**
docs/decisions/bullhorn-integration-path.md:50:- The structural shape of Bullhorn's OAuth flows (authorization code vs client credentials) and which scenarios each is suited to.
docs/decisions/bullhorn-integration-path.md:52:- Token lifecycle outline: short-lived REST sessions, long-lived refresh tokens, periodic re-auth dance via the Bullhorn login URL.
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
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
docs/decisions/bullhorn-integration-path.md:105:| Janitor W5 build | A+B Accepted (commercial conversations complete) | Pending |
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
docs/decisions/bullhorn-integration-path.md:306:| Janitor Candidate sweep | Polling (full-table scan per sweep) | Nightly 02:00 | Initial sweep is bounded by per-tenant Candidate count; subsequent sweeps use `dateLastModified` filter to limit to changes-since-last-sweep |
docs/decisions/bullhorn-integration-path.md:307:| Janitor Note / ClientCorporation / JobOrder sweep | Polling | Nightly 02:00 | Same `dateLastModified` filter pattern |
docs/decisions/bullhorn-integration-path.md:308:| Scribe transcript-to-Note write | Push from Fathom/Fireflies → IFOS → REST write to Bullhorn | Per-call (within 5-min SLA) | The Fathom/Fireflies webhook is the trigger; Bullhorn side is REST POST |
docs/decisions/bullhorn-integration-path.md:310:| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
docs/decisions/bullhorn-integration-path.md:311:| Concierge time-based nurture cadence | Cron (week-1, month-1, month-3, month-6, month-12, month-24) | Per Placement-creation anchor date | No Bullhorn webhook needed — IFOS-side cron fires; IFOS reads Bullhorn for current state then writes the comm Note back |
docs/decisions/bullhorn-integration-path.md:324:- **Postgres `decision_log` RLS:** every Bullhorn-derived `hh_decision_*` row is tenant-scoped per ADR-002 Decision 3 (`tenant_slug` column + RLS policy per `second-brain-design.md` §2.4.2).
docs/decisions/bullhorn-integration-path.md:328:Bullhorn public docs name HTTP 429 + "wait 1 second then retry" per §2.2; specific per-second / per-minute / per-day caps **commercially gated to verification per §1.3** (Bullhorn dev support).
docs/decisions/bullhorn-integration-path.md:330:**Conservative v1.0 budget allocation per tenant per hour** (anchored to typical enterprise REST API patterns of 100-500 req/min ceilings; revise once Bullhorn confirms):
docs/decisions/bullhorn-integration-path.md:334:| Janitor (nightly sweep) | 200-400 during active sweep window (concentrated 1-2 hour burst) | Burst-tolerant; bounded by tenant Candidate-count and `dateLastModified` filter efficiency |
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
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |
docs/decisions/autosend-safety-policy.md:6:**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
docs/decisions/autosend-safety-policy.md:25:1. Writes to any external system via MCP connector (Bullhorn, Companies House, Xero, Microsoft Graph, etc.) — every `tools.yaml`-declared write scope
docs/decisions/autosend-safety-policy.md:51:**Default characteristics:** idempotent OR internal-to-tenant OR read-only against external systems with rate-limit budget remaining OR low-cost-to-reverse (e.g., add a Bullhorn tag that can be removed in <30s).
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:82:| Janitor | `bullhorn_candidate_tag` | Adds a tag with `checked_at` date; reversible in <30s; high volume |
docs/decisions/autosend-safety-policy.md:83:| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
docs/decisions/autosend-safety-policy.md:92:| Janitor | `bullhorn_candidate_dedupe` | 1-in-10 | Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review |
docs/decisions/autosend-safety-policy.md:96:| Concierge | `bullhorn_note_draft_internal` | 1-in-10 | Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate |
docs/decisions/autosend-safety-policy.md:102:| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
docs/decisions/autosend-safety-policy.md:111:| Janitor | `bullhorn_placement_terminate` | Marks placement as terminated; commercial/legal implications; reversible only via support ticket |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:414:Full message content lives in the originating system (Bullhorn, Gmail, Twilio). Audit references the system's own audit log (e.g., Bullhorn note ID) via `payload.target`.
docs/decisions/autosend-safety-policy.md:435:      "bullhorn_candidate_dedupe": "orange"
docs/decisions/autosend-safety-policy.md:451:      "bullhorn_candidate_dedupe": 1,
docs/decisions/autosend-safety-policy.md:604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:642:1. Tier classifications per §3 (especially canonical orange = Concierge Bullhorn Note)
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:158:Action: write customer-visible Bullhorn Note
docs/decisions/autosend-approval-bridge-spec.md:240:| A2 | `.pending` marker triggers `createApproval` call within 200ms | Integration test: write marker → assert cortextOS pending file appears with correct payload |
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:22:| A2 | Janitor | 5 | Bullhorn MCP (R+W) | "First demoable inside-ATS result; day-30 before/after closes deals" |
docs/decisions/sequencing-target.md:23:| A3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | "Post-call note in Bullhorn within 10 min — second-most-demoable" |
docs/decisions/sequencing-target.md:26:| A6 | Concierge | 10-13 | Bullhorn + MS Graph + AgentMail | "First Tier-1 always-on closing demo; 4-week build" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:34:- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
docs/decisions/sequencing-target.md:42:**Weeks 5-13 planning is speculative without §B.** Each agent's prerequisites (Bullhorn MCP, Fathom/Fireflies, Xero, LinkedIn) have lead times. Bullhorn MCP work itself starts Week 1 per Ultraplan §9 line 724 ("Bullhorn MCP server is the critical path; week 1 starts on it"). Without knowing the agent build order, those infrastructure prereqs can't be sequenced.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:50:Six criteria to evaluate each agent against in §2. Each criterion scored High / Medium / Low or with a concrete number; substantive cells in §2 must justify the score by reference to master brief / Ultraplan / Product Spec / Day-2 Bullhorn decision.
docs/decisions/sequencing-target.md:55:| 2 | **Substrate exercise** | Fraction of Week-1-2 substrate (renderer / `_shared/voice-loader.sh` / `_shared/hook-helpers.sh` / Postgres `decision_log` / `_secrets.env` / Bullhorn auth refresh-loop) the agent exercises | Higher substrate exercise = more value as smoke test for the substrate, but also higher risk of substrate-bug-attributed-to-agent confusion |
docs/decisions/sequencing-target.md:56:| 3 | **Risk de-risking** | Which named risks the agent's success/failure surfaces — Risk #1 (cortextOS primitives), Risk #2 (Bullhorn auth), Risk #5 (renderer-not-built) — per `docs/RISK-REGISTER.md` | Building risk-surfacing agents earlier converts known-unknowns into known-knowns; building risk-deferring agents earlier preserves optionality but pushes the surprise window later |
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:71:- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
docs/decisions/sequencing-target.md:74:Recommended sequence in §4 must remain **operationally coherent under both contingencies.** A sequence that breaks (e.g. one that ships Concierge before Janitor) would lose the Risk #2 contingency because dropping Janitor would orphan the already-shipped Concierge's data flow. The §4 recommendation explicitly validates against both contingencies.
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:96:| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:101:| 6. Tenant-onboarding readiness | **High** | Runnable from end of Week 2 with renderer + `_shared/` + Postgres decision_log. No vault `_secrets.env` complexity (no per-tenant Bullhorn OAuth needed), no wiki API needed. Single-tenant deployable immediately |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:105:### 2.2 — A2 Janitor
docs/decisions/sequencing-target.md:109:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 513 estimate **L (2 weeks)** — the Bullhorn MCP work is rate-limiting per Ultraplan §8.1 line 514 ("Bullhorn MCP server doesn't exist yet — this is the critical-path build"). One MCP server (Bullhorn) + Companies House for enrichment. Single primary output (cleanup report) but with continuous nightly cron pattern |
docs/decisions/sequencing-target.md:110:| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
docs/decisions/sequencing-target.md:111:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #2** (Bullhorn auth path per RISK-REGISTER). Closes Risk #2 reduction trigger 2 from `bullhorn-integration-path.md` §6.7: "first Bullhorn write lands cleanly in Week 3-4 Janitor agent build" → Risk #2 Medium → Low |
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
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
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:139:| 5. Dependencies | **Upstream:** none on other agents (Xero/QuickBooks/Sage + Open Banking infra independent of Bullhorn path). **Downstream:** none in v1.0 (Cash Conductor's outputs are tenant-internal chase emails + DSO reports, not consumed by other v1.0 agents) | Low cross-agent coupling |
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:150:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 554 estimate **L (2 weeks)** — multi-source aggregation logic is the work. Four data sources (Bullhorn read + LinkedIn via Proxycurl + Reed.co.uk + CV-Library). Bounded output (5-15 candidates per query per Ultraplan §8.1 line 552). Tier 2 request-response |
docs/decisions/sequencing-target.md:151:| 2. Substrate exercise | **Medium** | Reuses Bullhorn R from Janitor (no new Bullhorn substrate). New MCP integrations: LinkedIn via Proxycurl (rate-limited per Ultraplan §10 row #6), Reed, CV-Library. Source-abstraction layer per Ultraplan §8.1 line 555 designed to be reusable by Night Sourcer v1.1 |
docs/decisions/sequencing-target.md:152:| 3. Risk de-risking | **Medium** | **First exercise of LinkedIn rate-limit budget** per Ultraplan §10 Risk #6 ("LinkedIn rate limits via Proxycurl are tighter than expected"). Reuses Bullhorn auth from Janitor (doesn't re-derisk Risk #2). Tier 2 so doesn't touch Risk #1 primitives |
docs/decisions/sequencing-target.md:153:| 4. Commercial value | **Medium** | Per Product Spec §2.2 R5: "Shortlist in 15 minutes instead of by end of week." Less commercially load-bearing than Janitor/Scribe/Concierge — request-response not always-on, so less of a closing-demo asset. Sales narrative is "cuts intake-call-to-first-shortlist time from same-week to same-hour" |
docs/decisions/sequencing-target.md:154:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Night Sourcer (v1.1) reuses Sourcing Scout's multi-source layer per Ultraplan §8.1 line 555 ("Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it") | Medium criticality (v1.1 downstream) |
docs/decisions/sequencing-target.md:155:| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn (already on if Janitor shipped) + LinkedIn (Proxycurl API key — single application-level key, not per-tenant) + Reed OAuth + CV-Library OAuth per tenant |
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:164:| 2. Substrate exercise | **Maximum** | **All** of cortextOS Primitives 1+2+4+5 exercised. **First exercise of Primitive 2** (71-hour context rotation per Day 1 cortextos-primitive-status.md) — Concierge holds long-running state across 24+ months of candidate lifecycle. First Bullhorn webhook exercise per Day 2 §4.2 (with 5-minute polling fallback). Per `bullhorn-integration-path.md` §4.1 row 4: reads Candidate, ClientCorporation, JobOrder, Placement, Note + writes Note, Candidate state-fields, Placement state-fields |
docs/decisions/sequencing-target.md:165:| 3. Risk de-risking | **High (secondary)** | Second Tier-1 always-on agent (after Cash Conductor at W7-8) — provides Risk #1 secondary exercise. Exercises Bullhorn webhook coverage gaps per Ultraplan §8.1 line 569 verbatim ("Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks") |
docs/decisions/sequencing-target.md:166:| 4. Commercial value | **Highest** | Per master brief §8.2 line 606: "First Tier-1 always-on closing demo; 4-week build." Product Spec §2.2 R7: 15-25% lift in placement-driven referral revenue ("post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table"). The flagship v1.0 closing demo |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:168:| 6. Tenant-onboarding readiness | **Hardest** | Needs Bullhorn + Microsoft Graph (or Gmail) per tenant + full voice corpus loaded + nurture cadence config per stage + auto-send approval categories (Solo: drafts-only; Boutique+: candidate-acknowledgement auto-send) + do-not-contact flags. Full onboarding-wizard Day 4 work (Product Spec §5.2) |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:176:Three orderings evaluated against §1.3 criteria. **Option Alpha is the master-brief §8.2 canonical sequence** (correcting the §1.5 founder-prompt drift); Options Beta and Gamma are tested as alternatives.
docs/decisions/sequencing-target.md:178:### 3.1 — Option Alpha (canonical, master-brief §8.2)
docs/decisions/sequencing-target.md:182:W5:   Janitor (A2)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:193:- W5: Risk #2 (Bullhorn auth) — Janitor first writes. Reduction trigger 2 fires (Medium → Low per `bullhorn-integration-path.md` §6.7).
docs/decisions/sequencing-target.md:198:- Bullhorn webhook coverage gaps surface only at Concierge W10-13 (Ultraplan §8.1 line 569 caveat).
docs/decisions/sequencing-target.md:200:**Cost if deferred risk materialises late:** if Bullhorn webhook coverage is worse than expected (Risk #2 secondary), Concierge polling cadence increases (per Day 2 §4.2 fallback) — connector-internal change, no agent rework. Bounded.
docs/decisions/sequencing-target.md:202:**Hire-#1-onboarding fit:** **Excellent.** Cash Conductor at W7-8 matches Ultraplan §9 line 766 verbatim. Hire #1 (assumed W7) takes Cash Conductor's three-accounting-API + Open-Banking work as first sprint — well-scoped, independent of the Bullhorn track founder has been driving solo W3-W6.
docs/decisions/sequencing-target.md:209:W9:   Janitor (A2)
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:229:W5:   Janitor (A2) — Risk #2 derisk
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:253:| 2. Substrate exercise (sequential build-up) | **Wins** — each agent extends the substrate of the prior (renderer → Bullhorn auth → voice → Tier-1 primitives → multi-source → full Tier-1 lifecycle) | Loses — Concierge has to build its own Bullhorn auth + voice substrate inline | Loses — Concierge built before its substrate dependencies (Scribe's Notes-for-context not yet available) |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:256:| 5. Dependencies on other agents | **Wins** — Janitor's Bullhorn auth → Scribe reuses → Sourcing Scout reuses → Concierge reuses, all in dependency order | Loses — Concierge before Janitor + Scribe breaks the upstream chain | Loses — Concierge before Scribe breaks the upstream chain |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:300:**Trigger 1 — Risk #2 materialises in Week 4-5.** If Bullhorn auth path breaks (Day 2 Sub-decisions A or B don't flip to Accepted, marketplace required but unobtainable, OAuth flow blocks deployment, or per-tenant client_id ticket cycle slows past 5 business days per `bullhorn-integration-path.md` §1.3 row 5):
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:314:**Trigger 3 — Hire #1 starts later than Week 7.** Per Ultraplan §9 line 766 verbatim caveat: "Hire #1 is assumed to start week 7 (verify, don't assume)":
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:326:- The substrate-first principle (Diagnostic W3-4 before any Bullhorn-touching agent).
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:406:### 6.3 — For Risk #2 (Bullhorn auth path)
docs/decisions/sequencing-target.md:408:First exercise is Janitor at W5 per §4.1 row 2. **If Day 2 Sub-decisions A and B haven't flipped from Proposed to Accepted by start of W4** (per `bullhorn-integration-path.md` §1.3 commercial-blocker table), this is the natural blocker. Founder Sunday/Monday commercial conversations must land before W4 start to keep the Janitor W5 slot intact. Sub-decision C is already Accepted so the endpoint surface is buildable; the gate is auth path (A) and client_credentials foreclosure (B).
docs/decisions/sequencing-target.md:439:- **Janitor's first Bullhorn auth refresh fails by W5** (Risk #2 unmitigated; commercial path broken)
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |

exec
/bin/zsh -lc "rg --files | rg -i 'master.*brief|brief.*master|kill-criterion|codex-disagreement|operational-hygiene'" in /Users/madsadmin/code/CortexOS
 succeeded in 159ms:
docs/runbooks/operational-hygiene-protocol.md
docs/build-brief/00-MASTER-BRIEF.md
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
docs/decisions/v1.0-kill-criterion.md
logs/codex-ratification/round-2-autonomous/docs_decisions_v1-0-kill-criterion-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_codex-disagreement-2026-05-20-bullhorn-week-1-gate-md.output.md
logs/codex-ratification/round-2-autonomous/docs_runbooks_operational-hygiene-protocol-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_codex-disagreement-2026-05-20-decision-doc-shape-on-audits-md.output.md
logs/codex-ratification/round-3-remediation/docs_decisions_codex-disagreement-2026-05-20-bullhorn-week-1-gate-md.output.md

exec
/bin/zsh -lc "nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,620p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '1,180p'; nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
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
   611	git checkout -b agent/{name}                       # e.g. agent/janitor
   612	mkdir -p agents/recruitment/{name}/tests/fixtures/{01-primary,02-edge-case-{X},99-voice-drift-canary}
   613	
   614	# In Claude Code, work the bundle through 6 files in this order:
   615	# 1. README.md (2-min overview)
   616	# 2. agent.md (OUTPUT CONTRACT FIRST, then workflow, then gates, then escalation)
   617	# 3. config.schema.json (what the wizard collects)
   618	# 4. tools.yaml (MCP servers + scopes + degraded modes)
   619	# 5. validate.sh (Gate A; sources _shared/hook-helpers.sh)
   620	# 6. context.sh (hydrates CONTEXT via context-assembly API)

 succeeded in 0ms:
     1	# IFOS recruitment vertical schema v0.2 — voice corpus supplement
     2	# ============================================================================
     3	# Status: Proposed (Codex Day-7 ratification queue addendum)
     4	# Date:   2026-05-20 (Day 8 of Week 0 extension)
     5	# Author: Founder (Maddox), Phase-4 of bubbly-snuggling-lantern.md plan
     6	# Predecessor: docs/verticals/recruitment/vertical-schema.yaml v0.1 (`fec8872`)
     7	#
     8	# Closes Day-7-honest-read gap #1 (voice corpus schema undefined). Required by
     9	# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
    10	# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
    11	# helpers need data substrate; this supplement defines it.
    12	#
    13	# Companion: docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
    14	#   Drafted alongside; executed against migration-test tenant in Phase 5.
    15	#
    16	# Layer over v0.1 generic primitives (entities + entity_links + decision_log
    17	# from Day-4 §6.3). Three new entity_types + one pgvector index over
    18	# voice_corpus.text_chunks + per-entity voice classifier score fields.
    19	# ============================================================================
    20	
    21	vertical: recruitment
    22	version: v0.2
    23	supplements: v0.1
    24	status: Proposed
    25	date: 2026-05-20
    26	author: founder (Maddox), Phase-4 voice-corpus-substrate via Claude Code
    27	codex_ratification_queue_position: 29  # appended after Phase-3 items
    28	
    29	# ============================================================================
    30	# §1 — New entities (3) — auxiliary Postgres tables, NOT entities.data entity_types
    31	# ============================================================================
    32	#
    33	# LAYERING DISCLOSURE (Codex Round 1 — issue 2 incorporation):
    34	#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
    35	#   as **auxiliary Postgres tables** (real CREATE TABLE statements in
    36	#   `migrations/v0.1-to-v0.2.sql`), NOT as entity_types in the entities/entity_links
    37	#   generic primitive layer from Day-4 §6.3. The voice corpus requires (a) pgvector
    38	#   HNSW indexes which need real columns + indexes, not JSONB blobs, and (b) RLS
    39	#   policies on per-table tenant_slug — both of which are simpler with first-class
    40	#   tables.
    41	#
    42	#   The label `entities:` below is a YAML key (the schema-document convention from
    43	#   v0.1) — read it as "new domain entities introduced in v0.2", not as "rows in the
    44	#   Postgres `entities` table". The Postgres-level shape lives in
    45	#   `migrations/v0.1-to-v0.2.sql` §2-§5.
    46	#
    47	#   The 6 voice_classifier_score / voice_drift_at_close fields added to existing
    48	#   v0.1 entities (candidate, contractor, contact, brief, opportunity, placement)
    49	#   in §3 below DO land as `entities.data` JSONB keys per the Day-4 §6.3 generic
    50	#   primitive layer; they are validated by the `validate_voice_scores` trigger
    51	#   in `migrations/v0.1-to-v0.2.sql` §7.
    52	
    53	entities:
    54	
    55	  # --------------------------------------------------------------------------
    56	  voice_corpus:
    57	    description: |
    58	      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
    59	    bullhorn_source: none (IFOS-derived from /vault/<tenant>/_voice/ ingest)
    60	    v1_0_agent_access:
    61	      - Scribe (R — voice samples for note-summary tone matching)
    62	      - Concierge (R — voice samples for outbound message generation)
    63	      - voice-drift-canary nightly cron (R — drift detection input)
    64	    canonical_fields:
    65	      tenant_slug:
    66	        type: string
    67	        required: true
    68	        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
    69	        notes: RLS-isolated per tenant. Maps to entities.tenant_slug at row level.
    70	      version:
    71	        type: string
    72	        required: true
    73	        source: IFOS-derived (operator names at re-index time)
    74	        notes: |
    75	          Semver tag (e.g. "v0.1", "v0.2-2026-06-15"). Bump on re-index. Live pack is the row with `is_active: true`; historical packs preserved for audit + rollback per master brief §3.3 audit discipline.
    76	      source_doc_count:
    77	        type: integer
    78	        required: true
    79	        source: IFOS-derived (counted by ingest pipeline)
    80	        notes: Number of source documents ingested into this version (emails + notes + marketing). Sanity check during re-index.
    81	      source_doc_origin:
    82	        type: array
    83	        required: true
    84	        source: IFOS-derived (vault _voice/ subdirectory enumeration)
    85	        notes: |
    86	          Items enum: ["vault_emails", "bullhorn_notes", "marketing_copy", "founder_curated", "consultant_drafts"]. Order documents provenance for the LoRA pipeline (v2.0 Scale tier).
    87	      chunk_count:
    88	        type: integer
    89	        required: true
    90	        source: IFOS-derived (computed by chunking pass)
    91	        notes: Number of text chunks produced from the source corpus after the chunking pass. One chunk = one row in the pgvector index.
    92	      chunking_strategy:
    93	        type: string
    94	        required: true
    95	        source: IFOS-derived (config; v0.2 default "paragraph")
    96	        notes: |
    97	          Enum: ["paragraph", "sentence-window-5", "semantic-segment-v1"]. v0.2 ships with "paragraph" (simplest, deterministic). Other values reserved for v1.1 experimentation per Q5 voice gate research.
    98	      embedding_model:
    99	        type: string
   100	        required: true
   101	        source: IFOS-derived (config; default text-embedding-3-small)
   102	        notes: |
   103	          Identifier of the embedding model used to populate the pgvector column. v0.2 ships with "text-embedding-3-small" (1536 dimensions); revising model triggers re-index + new version row.
   104	      last_indexed_at:
   105	        type: timestamp
   106	        required: true
   107	        source: IFOS-derived (timestamped at ingest completion)
   108	        notes: When the indexing pipeline last completed for this version. Set on row insert; never updated post-insert (immutability of versioned packs).
   109	      is_active:
   110	        type: boolean
   111	        required: true
   112	        source: IFOS-derived (atomic flip on version rollover)
   113	        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
   114	      ingest_completion_ms:
   115	        type: integer
   116	        required: false
   117	        source: IFOS-derived (observability counter; pipeline timing)
   118	        notes: How long the ingest+chunk+embed pipeline took. Observability only.
   119	    notes: |
   120	      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
   121	
   122	  # --------------------------------------------------------------------------
   123	  tone_rule:
   124	    description: |
   125	      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
   126	    bullhorn_source: none (IFOS-derived; authored in /vault/<tenant>/_voice/tone-rules.yaml then synced to Postgres)
   127	    v1_0_agent_access:
   128	      - Scribe (R — note format constraints)
   129	      - Cash Conductor (R — payment reminder tone)
   130	      - Concierge (R — every outbound message)
   131	    canonical_fields:
   132	      tenant_slug:
   133	        type: string
   134	        required: true
   135	        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
   136	      rule_id:
   137	        type: string
   138	        required: true
   139	        source: IFOS-derived (operator names at rule authoring time)
   140	        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
   141	      rule_text:
   142	        type: string
   143	        required: true
   144	        source: IFOS-derived (operator natural-language description)
   145	        notes: Natural-language description of the rule. Surfaced verbatim to the agent.
   146	      severity:
   147	        type: string
   148	        required: true
   149	        source: IFOS-derived (operator picks at rule authoring)
   150	        notes: |
   151	          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
   152	      applies_to_agents:
   153	        type: array
   154	        required: true
   155	        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
   156	        notes: |
   157	          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
   158	      enabled:
   159	        type: boolean
   160	        required: true
   161	        source: IFOS-derived (default true; operator toggles via Brain UI)
   162	        notes: Soft-delete pattern. Tenant can disable a rule without deleting the row; preserves history for audit.
   163	      created_by:
   164	        type: string
   165	        required: true
   166	        source: IFOS-derived (enum from rule provenance — onboarding-flow / Brain-UI / CSM-intervention)
   167	        notes: |
   168	          Provenance: "founder" (default tenant-onboarding rules), "tenant-admin" (added via Brain UI), "ifos-csm" (added during CSM intervention per master brief §10 CSM workflow).
   169	      created_at:
   170	        type: timestamp
   171	        required: true
   172	        source: IFOS-derived (timestamped at insert)
   173	      examples_positive:
   174	        type: array
   175	        required: false
   176	        source: IFOS-derived (operator-curated at rule authoring)
   177	        notes: |
   178	          Items: short string phrases. Examples of compliant text. Surfaced to the agent in the context bundle.
   179	      examples_negative:
   180	        type: array
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

 succeeded in 0ms:
     1	# v1.0 kill criterion
     2	
     3	**Status:** Proposed — pending Codex Day-7 ratification
     4	**Date:** 2026-05-18 (Week 0, Day 5)
     5	**Author:** Claude Code, with founder review pending
     6	**Master brief §:** §6 Day 5 (line 486) + §12 Risk Register + §1 Rule 5 (honest signal before optimistic projection)
     7	**Surfaced by:** Master brief Day 5 spec; folds carry-forwards from `sequencing-target.md` §6.6 + `bullhorn-integration-path.md` §4.1 + Day-4 §11 closing-commit work.
     8	**Path drift logged:** Master brief §6 Day 5 line 486 specifies `docs/v1-kill-criterion.md` (docs/ root). This artefact lives at `docs/decisions/v1.0-kill-criterion.md` per repo convention. Recorded as **Edit 10** in atomic-correction manifest (shared with autosend-safety-policy.md path drift).
     9	
    10	---
    11	
    12	## §1 — Definitions
    13	
    14	Three distinct end-states for v1.0:
    15	
    16	### KILL
    17	
    18	**Cease v1.0 development.** The wedge is invalidated by structural evidence. Existing pilots receive 30-day wind-down notice; assets liquidated or open-sourced; refund obligations honoured per pilot agreement. Founder pivots to next initiative.
    19	
    20	**KILL is reversible only as v1.1 or v2.0**: a wholly new initiative under different premises, with its own kill criterion. v1.0 itself does not resurrect.
    21	
    22	### PAUSE
    23	
    24	**Freeze v1.0 development for N weeks while data is gathered.** Existing pilots continue in read-only mode (agents that have shipped stay operational; no new agents ship). Founder + Jack conduct strategic review and define an unfreeze criterion.
    25	
    26	**PAUSE has a defined exit:** either unfreeze (resume v1.0 from the slice that was active when paused) OR escalate to KILL/PIVOT if the strategic review concludes the trigger is structural rather than temporary.
    27	
    28	### PIVOT
    29	
    30	**Rescope v1.0.** The wedge holds but its assumed shape is wrong. Common pivots:
    31	
    32	- **Vertical pivot:** recruitment → accountancy, insurance, or another UK SME services domain
    33	- **ATS pivot:** Bullhorn-first → Vincere-first, Voyager Infinity-first, or vertical-without-ATS
    34	- **Deployment pivot:** SaaS → self-hosted, or vice-versa
    35	- **Customer pivot:** consultant-facing → operations-team-facing → owner-facing
    36	
    37	**v1.0 commitments to existing pilots are honoured under original scope.** New v1.0 contracts under rescoped terms. The master brief and Ultraplan are amended by atomic-correction commit; Codex ratifies before v1.0 resumption.
    38	
    39	---
    40	
    41	## §2 — Binary triggers
    42	
    43	Each trigger has: measurable threshold, owner (detects), action (kill/pause/pivot), source justification.
    44	
    45	### Trigger 1 — DESIGN-PARTNER-BY-WEEK-2 (PAUSE)
    46	
    47	**Threshold:** No design partner has confirmed pilot intent (signed LOI or equivalent written commitment to pilot in Q3 2026 per master brief §6 Day 7 question 1) by end of Week 2.
    48	
    49	**Calendar:** Day 0 was 2026-05-13 (Wednesday). Week 0 runs Days 0-7, ending Wednesday 2026-05-20. Week 1 starts Thursday 2026-05-21. Week 2 ends Wednesday 2026-06-03. **Trigger fires end-of-day 2026-06-03 if criterion unmet.**
    50	
    51	**Owner:** Founder; daily check during Weeks 1-2.
    52	
    53	**Source:** Risk #3 in `docs/RISK-REGISTER.md` (escalating status); Day-5 Risk #3 update reflects "zero design partners in pipeline" as of this commit; master brief §6 Day 7 question 1.
    54	
    55	**Action:** PAUSE state activated immediately. Agent code halts at end of current week's slice (rather than mid-slice). Founder pivots to full-time design-partner acquisition. Claude Code work limited to design-partner-supporting artefacts (sales decks, demo agents, pricing models).
    56	
    57	**Unfreeze criterion:** **One signed pilot LOI** from a UK recruitment agency with stated pilot start date in Q3 2026. Unfreeze formal: Founder + Jack joint sign-off on the LOI; resume v1.0 from the slice that was active when paused.
    58	
    59	**Escalation path if PAUSE extends:** if unfreeze not achieved within 4 weeks of PAUSE activation, strategic review reconvenes. Outcomes: (a) continue PAUSE if pipeline is materially active; (b) escalate to KILL if no pipeline activity; (c) escalate to PIVOT if pipeline rejection signals point to a different vertical/ATS.
    60	
    61	### Trigger 2 — DIAGNOSTIC-NO-RENDER-W3 (KILL)
    62	
    63	**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
    64	
    65	**Owner:** Claude Code (technical detection); founder review (decision authority). Weekly check during Weeks 1-3.
    66	
    67	**Source:** `sequencing-target.md` §6.6 failure condition (i); Risk #5 in `docs/RISK-REGISTER.md`; ADR-003 §"Consequences" line 141 (renderer is load-bearing Week-1 deliverable).
    68	
    69	**Action:** KILL state. Rationale: the renderer architecture (ADR-003) was ratified in Week 0 Day 1 evening as the load-bearing Week-1 prerequisite. If Week 3 ends with no clean Diagnostic render, the renderer has fundamental gaps that the design did not anticipate. The renderer cannot be "patched"; v1.0 cannot ship without working render. Continuing into Weeks 4+ without resolution is sunk-cost reasoning.
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
    83	- **Option A:** Vincere-first. Mid-market UK recruitment ATS; smaller market than Bullhorn but more accessible API.
    84	- **Option B:** Voyager Infinity-first. UK-native ATS; smaller market; alternative auth model.
    85	- **Option C:** ATS-agnostic with manual data sync. Reduces v1.0 to read-only agent operation against ATS export files; loses much of the Janitor + Concierge value but unblocks pilot acquisition.
    86	
    87	Rescope plan attached to PIVOT decision; existing pilots receive 14-day notice with rescope explanation.
    88	
    89	**Recovery path:** PIVOT is structural; resumption is via rescoped v1.0 under new ATS assumption. Pivoted v1.0 continues with adjusted master brief / Ultraplan; atomic-correction commit lands the rescope.
    90	
    91	### Trigger 4 — TWO-SCOPE-CUT-ACTIVATIONS (PAUSE)
    92	
    93	**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
    94	
    95	**Owner:** Founder; logged in `.agents/decisions/` when activated.
    96	
    97	**Source:** `sequencing-target.md` §6.6 failure condition (iii); master brief §12 Risk #4 (Hire #1 mitigation calls for scope cut from 6 → 4 agents but explicitly warns against further cuts).
    98	
    99	**Action:** PAUSE state. Rationale: two scope cuts indicates either (a) the v1.0 wedge is structurally too narrow to be valuable, or (b) build velocity is fundamentally below the rate v1.0 requires. Either way, continuing to ship more agents is the wrong move; strategic review needed.
   100	
   101	**Unfreeze criterion:** Strategic review by Founder + Jack within 2 weeks of PAUSE activation produces one of three outcomes:
   102	
   103	1. **Unfreeze with scope:** restored to 4 agents (no further cuts); resume with adjusted timeline.
   104	2. **Escalate to PIVOT:** rescope vertical or customer-type; pivoted v1.0 has new agent fleet definition.
   105	3. **Escalate to KILL:** the wedge as designed cannot ship even at reduced scope.
   106	
   107	### Trigger 5 — AUTOSEND-RED-MISCATEGORISATIONS (PAUSE)
   108	
   109	**Threshold:** More than 3 confirmed red-tier autosend breaches per pilot per week from actions that should have been classified as green or yellow. "Confirmed" means: tenant operator files a `false-block` feedback report via Brain UI (or equivalent v1.0 manual channel) AND IFOS oncall agrees the tier classification was wrong. Threshold measured per individual pilot over rolling 7-day windows.
   110	
   111	**Owner:** IFOS oncall + tenant operator. Daily check via `decision_log` queries: `SELECT COUNT(*) FROM decision_log WHERE phase='gating_failed' AND payload->>'tier'='red' AND payload->>'block_reason'='red_tier_classification' AND tenant_slug=? AND created_at > NOW() - INTERVAL '7 days'`.
   112	
   113	**Source:** `docs/decisions/autosend-safety-policy.md` §5 + §10; Risk #3 in `docs/RISK-REGISTER.md` (LUKS manual unlock has higher impact but autosend miscategorisation has higher frequency).
   114	
   115	**Action:** PAUSE for the affected pilot. The agent that produced the miscategorisations halts at next session boundary. Founder + Jack review the policy tier classifications within 48 hours. Policy revision (via Codex ratification) lands as a new commit; affected pilot receives incident report. Pilot resumes after policy revision.
   116	
   117	**Escalation path:** If three pilots experience this trigger within one quarter, escalate to system-wide PAUSE while structural autosend policy redesign happens (potential v1.1 advancement of orange tier).
   118	
   119	### Trigger 6 — UNIT-ECONOMICS-COST-PER-ACTION (PIVOT)
   120	
   121	**Threshold:** Cost-per-completed-action (defined as: total IFOS infrastructure + API + Claude inference cost ÷ count of `decision_log` rows with `phase='action'` and `payload.tier IN ('green','yellow','orange-approved')`) exceeds **£0.50 per action** after 4 tenant-weeks of operation.
   122	
   123	**Operational-guess threshold; pilot data overrides.** Tune after first 100 pilot actions provide real cost-per-action data. Pre-pilot rationale: £0.50/action × ~200 actions/tenant-month = £100/tenant-month gross cost; viable only above £500/tenant-month revenue. If first-pilot data shows on-target spend, tighten threshold to ~£0.10/action (current £0.005 estimate × 20x safety margin).
   124	
   125	The £0.50 figure assumes:
   126	
   127	- Claude Sonnet 4.6 inference at ~£0.003 per action (small prompt, output cached)
   128	- Bullhorn API call at <£0.001 per action (free tier)
   129	- Hetzner infrastructure at ~£8/mo / ~10k actions/mo ≈ £0.0008 per action
   130	- Total: ~£0.005 per action would be on-track; £0.50 is 100x over-target
   131	
   132	**Owner:** Founder; monthly check.
   133	
   134	**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 pilot scale; master brief does not specify a numeric cost target); emerging from v1.0 pilot operations.
   135	
   136	**Action:** PIVOT — likely vector: cheaper Claude model tier (Haiku 4.5 for routine actions, Sonnet for complex), or reduced agent run frequency (e.g., Sourcing Scout runs nightly batch instead of real-time), or per-tenant cost passthrough in pricing.
   137	
   138	**Recovery path:** Rescoped pricing/architecture; pivoted v1.0 continues.
   139	
   140	### Trigger 7 — INFRASTRUCTURE-COST-MONTHLY (PIVOT)
   141	
   142	**Threshold:** Total Hetzner monthly infrastructure cost exceeds **£100/month at 3 active tenants**.
   143	
   144	**Rationale:** 15x headroom from the current £6.40/month single-tenant baseline (per Day-4 runbook §1.4: CX22 + 50 GB volume + backups = €5 + €1.20 + €2.40 ≈ £6.40). At 3 tenants on shared single-server architecture, expected cost should remain near baseline. If Postgres + LUKS-volume growth + vector-index growth pushes >£100/month at 3 tenants, infrastructure approach needs pivot.
   145	
   146	**Owner:** Founder; monthly check via Hetzner billing.
   147	
   148	**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 single-tenant pilot; master brief does not specify a numeric cost target); Risk #4 in `docs/RISK-REGISTER.md` (Hire #1 delays compound infrastructure spend if architecture sprawls).
   149	
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
   171	
   172	**Threshold:** cortextOS primitives 3 (file bus per `cortexos-primitive-status.md` line item 3) or 4 (approval gates per primitive 4) report >1 production incident per week across **2 consecutive weeks** for any single pilot.
   173	
   174	**Threshold tightened Day 5 (2026-05-18) from 4 weeks to 2 weeks.** Rationale: Risk #1 severity was downgraded Day 1 because primitives 3 + 4 confirmed "shipped and tested" per `cortexos-primitive-status.md`. If field evidence shows failure-rate spike for 2 consecutive weeks, that is an actionable signal — waiting 4 weeks delays remediation by 50% within the v1.0 build timeline (Weeks 1-13).
   175	
   176	**Owner:** IFOS oncall; weekly check via `decision_log` + cortextOS daemon logs.
   177	
   178	**Source:** Master brief §12 Risk #1; Day-1 audit results in `cortexos-primitive-status.md` (primitive 1 PTY/PM2 is "shipped but flaky"; primitives 3 + 4 confirmed "shipped and tested" but field evidence may diverge).
   179	
   180	**Action:** PAUSE. Rationale: cortextOS primitive instability is a structural threat to every IFOS agent — every agent uses the file bus and most use approval gates. Chronic failure points to either (a) cortextOS regression upstream OR (b) IFOS usage pattern incompatible with cortextOS at scale.
   181	
   182	**Unfreeze criterion:** Either (1) cortextOS upstream PR lands the fix (per master brief §3.1 cross-vertical primitive process), OR (2) IFOS vendor-patches via `packages/harness-patches/` per master brief §3.1 fallback path. Unfreeze after **2 consecutive incident-free weeks** (matched to tightened threshold).
   183	
   184	**Escalation path:** Persistent failure after both PR and patch attempts triggers structural review — potential PIVOT to alternative runtime (different harness).
   185	
   186	### Trigger 10 — PII-LEAKAGE-INCIDENT (KILL)
   187	
   188	**Threshold:** ANY confirmed incident in which agent action results in PII (personally-identifiable information per UK GDPR Art. 4(1)) transmitted to an unauthorised party (cross-tenant recipient, unauthorised external recipient, or recipient outside tenant's declared data residency) AND not blocked by the RLS + autosend policy combination.
   189	
   190	**"Confirmed" means:** the incident is documented in `.agents/incidents/<date>-pii-leakage-<n>.md` with: recipient identity, data classes transmitted, attack vector (or accidental cause), and reproduction steps. False alarms (e.g., recipient was authorised but operator was unaware) do not trigger.
   191	
   192	**Owner:** Founder + IFOS oncall. Immediate (within 1 hour of detection).
   193	
   194	**Source:** Master brief §1 Rule 5 (honest signal before optimistic projection); UK GDPR statutory obligations; Risk #3 in `docs/RISK-REGISTER.md` (multi-tenant trust foundation).
   195	
   196	**Action:** KILL. Rationale: multi-tenant trust is the structural foundation of v1.0. A single confirmed PII breach beyond the RLS + autosend boundary indicates the foundation is unsound. Continuing operation risks (a) further breaches, (b) regulatory action, (c) catastrophic loss of pilot trust. Wind-down protects existing pilots from further exposure.
   197	
   198	**Recovery path:** None within v1.0. Mandatory ICO notification per UK GDPR Art. 33 (within 72 hours of discovery). Lessons logged comprehensively. Any v1.1 must be architecturally distinct (e.g., per-tenant physically-isolated infrastructure rather than shared Postgres with RLS).
   199	
   200	---
   201	
   202	## §3 — Decision authority
   203	
   204	**Day-5 restructure** (2026-05-18): Jack is high engagement on sales/commercial; founder is solo on product. This v1.0 kill criterion governs the **product domain**. Founder has SOLO authority for all trigger activations; Jack is informed-not-deciding. Commercial-domain kill criteria are deferred to a future artefact (placeholder: `v1.0-kill-criterion-commercial.md`).
   205	
   206	### §3.1 — Product domain (all 10 triggers in this document)
   207	
   208	**Founder has SOLO authority for kill/pause/pivot decisions** on every trigger in this document.
   209	
   210	- For all PAUSE actions: founder decides; activates within 24h of trigger detection.
   211	- For all PIVOT actions: founder decides; activates within 24h.
   212	- For all KILL actions: founder decides; activates within 24h (within 4h for Trigger 10 PII per §3.5 emergency authority).
   213	- Jack is **informed-not-deciding** via written brief within 24h of any trigger fire. Jack's input may inform follow-on commercial decisions but does not gate the product decision.
   214	- All decisions logged in `.agents/decisions/<date>-trigger-<n>-decision.md` per existing convention.
   215	
   216	### §3.2 — Commercial domain (out of scope for this document)
   217	
   218	Commercial-side kill criteria — pilot pricing, customer acquisition strategy, sales pipeline kill thresholds — are out of scope for v1.0 product kill criterion. A future artefact (placeholder name: `v1.0-kill-criterion-commercial.md`) defines them with Jack as decision authority and founder informed. Scope boundary: anything that does not directly trigger product KILL/PAUSE/PIVOT belongs in the commercial document.
   219	
   220	### §3.3 — Crossover scenarios (product trigger with commercial implications)

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '146,175p'; nl -ba docs/specs/ULTRAPLAN.md | sed -n '500,515p'; nl -ba docs/specs/ULTRAPLAN.md | sed -n '535,545p'; nl -ba docs/specs/ULTRAPLAN.md | sed -n '565,572p'; nl -ba docs/specs/ULTRAPLAN.md | sed -n '750,765p'; nl -ba docs/specs/ULTRAPLAN.md | sed -n '815,822p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   146	**Change 1 — Voice handling moves into a shared module.**
   147	
   148	Phase 2 has each `context.sh` `cat` the voice profile inline. That works for nine agents; it's brittle at eighteen. v2 introduces `_shared/voice-loader.sh`:
   149	
   150	```bash
   151	# Sourced from every agent's context.sh
   152	source /tenant/.claude/bin/_shared/voice-loader.sh
   153	
   154	# Load tone rules YAML
   155	hh_load_tone_rules
   156	
   157	# Retrieve top-N similar samples from voice corpus
   158	hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
   159	
   160	# Load last-5 consultant-edited drafts of this type
   161	hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
   162	```
   163	
   164	Every agent's `context.sh` becomes 30 lines instead of 200. The voice loader is the canonical surface; agents never read the voice corpus directly.
   165	
   166	**Change 2 — Decision logging is enforced, not optional.**
   167	
   168	Phase 2's `hook-helpers.sh` has `hh_log` available but agents use it inconsistently. v2 enforces three writes via wrapper functions:
   169	
   170	```bash
   171	hh_decision_trigger     # Called at start of agent run; logs the trigger
   172	hh_decision_output      # Called when agent produces output; logs the artefact
   173	hh_decision_action      # Called when human acts on output; logs the action
   174	```
   175	
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
   565	- **External APIs:** Microsoft Graph or Google Workspace per tenant; AgentMail for v1.1+
   566	- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
   567	- **Gate B target:** <5% candidate-ghosted rate; ≥60% send-as-is rate on drafts
   568	- **Build complexity:** **XL** (4 weeks) — this is the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)
   569	- **Gotchas:** Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks. Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship.
   570	
   571	### 8.2 v1.1 agents (seven, in build order)
   572	
   750	### Weeks 3–4 — Bullhorn + Diagnostic
   751	
   752	- Week 3: Bullhorn MCP server build (auth, read endpoints, write endpoints, webhook subscription)
   753	- Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint
   754	
   755	Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact.
   756	
   757	### Weeks 5–6 — Janitor + Scribe
   758	
   759	- Week 5: Janitor agent; day-30 before/after report template; CI fixtures
   760	- Week 6: Scribe agent; Fathom + Fireflies MCP; tacit-note taxonomy v0.1
   761	
   762	Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.
   763	
   764	### Weeks 7–8 — Cash Conductor + Hire #1 onboards
   765	
   815	| # | Risk | Probability | Impact | Tripwire | Mitigation |
   816	|---|---|---|---|---|---|
   817	| 1 | CortexOS primitives 3 or 4 are flaky in production | High | High | Daily orchestrator health check flags >1 incident/week | Degraded-mode fallbacks per agent (§3.5); the file bus contract is documented and we can manually trigger handoffs if needed |
   818	| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
   819	| 3 | First design partner not signed by end of week 0 | Medium | High | Week 0 ends without LOI | Sales conversations start before week 0; do NOT begin code until first LOI lands |
   820	| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
   821	| 5 | Open Banking integration takes more than 1 week | Medium | Medium | End of week 7 status not "Xero + first bank connected" | Cash Conductor ships with manual reconciliation in v1.0; webhook-driven mode at v1.1 |
   822	| 6 | LinkedIn rate limits via Proxycurl are tighter than expected | Medium | Medium | Sourcing Scout cost >£100/run | Negotiate Proxycurl enterprise plan; defer Night Sourcer to v1.2 if needed |

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "rg -n \"hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|applies_to_agents|--agent|VOICE_CLASSIFIER|0\\.75\" agents/_shared/voice-loader.sh" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
15:#   hh_load_recent_edits   — query recent_edit for last N days
73:# hh_load_tone_rules [<agent_name>]
79:hh_load_tone_rules() {
88:             AND (cardinality(applies_to_agents) = 0 OR '$(_hh_json_escape "${agent_name}")' = ANY(applies_to_agents))
135:# hh_load_voice_samples <task_context> [<top_k>]
151:hh_load_voice_samples() {
223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
233:hh_load_recent_edits() {

exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_WRITE_FAIL|ESC_GATE_B_MISS|ESC_AUTOSEND_SAMPLED_SPOT_CHECK|ESC_BULLHORN_OAUTH_REVOKED|ESC_AUTOSEND" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
24:The Telegram message is templated via `common-notifications.json` `escalation_routes.<ESC_CODE>` if present; otherwise routed to `operator_chat_id`. `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` additionally CCs `ifos_oncall_chat_id`.
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
310:#### `ESC_BULLHORN_WRITE_FAIL`
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
342:- **Severity:** info — distinct from ESC_AUTOSEND_NEEDS_REVIEW (which is the initial queue event)
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
377:#### `ESC_GATE_B_MISS`
475:2. Validate `<ESC_CODE>` is a name from §2 above; unknown codes raise `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` (meta-escalation)

exec
/bin/zsh -lc 'rg -n "recent_edit|janitor_dedup_threshold|janitor_last_run|tenant_adapters|resolved_at|approved_after_edit|resolution" docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/*.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:26:DROP TABLE IF EXISTS recent_edit          CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:52:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:53:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:383:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:390:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:398:    'janitor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:416:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:458:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:460:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:461:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:463:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:52:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:53:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:383:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:390:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:398:    'janitor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:416:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:458:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:460:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:461:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:463:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:242:      resolution:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:247:          Enum: ["approved_verbatim", "approved_after_edit", "rejected", "deferred"]. `deferred` indicates operator returned to inbox without resolving (4h timeout case).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:248:      resolved_at:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:350:  recent_edit_drives_retraining:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:405:      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:411:      Pending D2/D3 resolution. v0.2 ships with text fields stored verbatim
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 3 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:196:          via its path resolution.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:283:#   - Scribe timesheet: none → R (reads for placement-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:285:#   - Cash Conductor contact: none → R (reads for invoice addressee resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:302:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:318:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:326:  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:396:    timesheet: R           # IFOS-cached read; placement-context resolution (Bullhorn Timesheet endpoint NOT used at v1.0)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:407:    contact: R             # IFOS-cached read; invoice addressee resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:437:    contact: R             # IFOS-cached read; outbound recipient resolution (Bullhorn endpoint A6 — Note context)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:462:      - Scribe (R)         # v0.3 NEW — reads client context for call-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:476:      - Cash Conductor (R) # v0.3 NEW — reads for invoice addressee resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:580:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:711:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:738:# §4 — tenant_adapters.config new keys (3 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:741:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:742:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:745:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:830:    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:853:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:855:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:928:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:940:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:976:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:978:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:6:-- side effects on existing recent_edit data).
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:15:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:18:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:19:  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:21:DROP INDEX IF EXISTS recent_edit_text_purged_idx;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:23:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:6:-- Status:       DRAFTED; awaits D3 founder resolution + D2 SeedLegals advisor
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:12:-- Risk register: #10 (recent_edit raw PII retention vs UK GDPR Art. 5(1)(e))
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:14:-- This migration is ADDITIVE. Adds one nullable column to recent_edit for
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:25:-- §1 — Add text_purged_at audit column to recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:28:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:31:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:34:COMMENT ON COLUMN recent_edit.text_purged_at IS
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:39:CREATE INDEX IF NOT EXISTS recent_edit_text_purged_idx
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:40:  ON recent_edit (text_purged_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:51:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:52:  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:54:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:55:  ADD CONSTRAINT recent_edit_text_purged_consistency CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:61:-- §3 — Per-tenant retention override storage (tenant_adapters extension)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:78:--   WHERE table_name='recent_edit' AND column_name='text_purged_at';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:82:--   WHERE table_name='recent_edit' AND column_name='original_text';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:86:--   WHERE table_name='recent_edit' AND constraint_name='recent_edit_text_purged_consistency';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:90:--   WHERE tablename='recent_edit' AND indexname='recent_edit_text_purged_idx';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:68:-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:71:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:72:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:74:-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:76:-- tenant_adapters config validation trigger.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:16:--     recent_edit_drives_retraining); also JSONB-backed in entity_links.metadata
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:138:-- §5 — Create recent_edit table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:141:CREATE TABLE IF NOT EXISTS recent_edit (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:151:  resolution             TEXT        NOT NULL CHECK (resolution IN ('approved_verbatim', 'approved_after_edit', 'rejected', 'deferred')),
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:152:  resolved_at            TIMESTAMPTZ NOT NULL,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:160:CREATE INDEX IF NOT EXISTS recent_edit_tenant_agent_idx ON recent_edit (tenant_slug, agent_name, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:161:CREATE INDEX IF NOT EXISTS recent_edit_tenant_action_idx ON recent_edit (tenant_slug, action_type, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:162:CREATE INDEX IF NOT EXISTS recent_edit_lookback_idx ON recent_edit (tenant_slug, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:164:ALTER TABLE recent_edit ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:165:ALTER TABLE recent_edit FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:166:DROP POLICY IF EXISTS recent_edit_tenant_isolation ON recent_edit;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:167:CREATE POLICY recent_edit_tenant_isolation ON recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:173:-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:180:GRANT SELECT, INSERT                 ON recent_edit         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:185:GRANT USAGE, SELECT ON SEQUENCE recent_edit_id_seq         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:202:--   ALTER TABLE recent_edit OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:206:--   ALTER SEQUENCE recent_edit_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:318:-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '300,385p'; nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '189,260p'; nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '738,805p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   189	  recent_edit:
   190	    description: |
   191	      Human edit to an agent's output captured at the point the consultant approves/edits/rejects a draft. Drives (a) the voice-drift-canary nightly cron, (b) future LoRA SFT pair generation per Ultraplan §6.1, (c) classifier retraining queue. Append-only per master brief §3.3 audit discipline.
   192	    bullhorn_source: none (IFOS-derived from operator's approve/edit UX)
   193	    v1_0_agent_access:
   194	      - voice-drift-canary cron (R — drift detection)
   195	      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
   196	      - LoRA pipeline v2.0 (R — SFT pair generation)
   197	    canonical_fields:
   198	      tenant_slug:
   199	        type: string
   200	        required: true
   201	        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
   202	      agent_name:
   203	        type: string
   204	        required: true
   205	        source: IFOS-derived (from CTX_AGENT_NAME at edit-capture time)
   206	        notes: |
   207	          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
   208	      action_type:
   209	        type: string
   210	        required: true
   211	        source: IFOS-derived (lookup against autosend-policy.yaml at edit time)
   212	        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
   213	      target_entity_type:
   214	        type: string
   215	        required: false
   216	        source: IFOS-derived (entity context at edit time; nullable for system-level edits)
   217	        notes: |
   218	          Optional pointer to the entity the draft was about (e.g. "candidate", "client"). Enables linking voice drift to entity classes (some entity types correlate with more drift).
   219	      target_entity_id:
   220	        type: string
   221	        required: false
   222	        source: IFOS-derived (entity ID at edit time; Bullhorn ID or IFOS slug)
   223	        notes: bullhorn_id or IFOS slug. Used in the entity_links join below.
   224	      original_text:
   225	        type: string
   226	        required: true
   227	        source: IFOS-derived (agent's draft as produced; capped at 8192 chars)
   228	        notes: |
   229	          The agent's draft as produced. **Stored verbatim** (privacy posture: this is the agent's own output, not external PII). Length-capped at 8192 chars; if longer, suffix truncated with "[...]" marker.
   230	      edited_text:
   231	        type: string
   232	        required: false
   233	        source: IFOS-derived (consultant's final version at approve time; null when approved verbatim)
   234	        notes: |
   235	          The consultant's final version. Nullable when the consultant approved verbatim (no edit). Length-capped at 8192 chars.
   236	      edit_distance:
   237	        type: integer
   238	        required: false
   239	        source: IFOS-derived (Levenshtein computed at insert; null when edited_text null)
   240	        notes: |
   241	          Computed Levenshtein distance between original_text and edited_text. NULL when edited_text is NULL (approved verbatim). Computed at insert time by the operator UX; not derived at query time.
   242	      resolution:
   243	        type: string
   244	        required: true
   245	        source: IFOS-derived (operator UX action at approve/reject time)
   246	        notes: |
   247	          Enum: ["approved_verbatim", "approved_after_edit", "rejected", "deferred"]. `deferred` indicates operator returned to inbox without resolving (4h timeout case).
   248	      resolved_at:
   249	        type: timestamp
   250	        required: true
   251	        source: IFOS-derived (timestamped at operator action)
   252	      tone_rules_triggered:
   253	        type: array
   254	        required: false
   255	        source: IFOS-derived (Gate-A fires recorded by validate.sh + hh_decision_action)
   256	        notes: |
   257	          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
   258	    notes: |
   259	      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
   260	
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
   791	  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   792	  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not
   793	  # declare this config key; the W4 ADR will introduce both the field
   794	  # and its consumer at the same time. Including it in v0.3 without an
   795	  # active consumer would be speculative schema.
   796	
   797	# ============================================================================
   798	# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
   799	# ============================================================================
   800	
   801	decision_log_payload_extension:
   802	  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
   803	  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
   804	  # explicitly DEFERRED to the future W4-polish ADR + schema supplement
   805	  # that ships alongside Tier 2 activation. v0.3 introducing the payload

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '383,455p'; nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '560,620p'; nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '950,985p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   454	  RETURN NEW;
   455	END;
   560	  voice_corpus:
   561	    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
   562	    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
   563	    rationale: |
   564	      All v1.0 agents that produce voice-classified output (Diagnostic for
   565	      §12 conversation opener; Janitor for tacit-note narratives; Cash
   566	      Conductor for chase drafts; Sourcing Scout for per-candidate
   567	      rationale) read voice_corpus for ANN-match exemplars. v0.2 only
   568	      granted Scribe + Concierge; v0.3 extends to all 6.
   569	
   570	  tone_rule:
   571	    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
   572	    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
   573	    rationale: |
   574	      Janitor agent.md §7 calls hh_load_tone_rules filtered by
   575	      applies_to_agents containing 'janitor' for tacit-note narrative
   576	      voice-classification. Per Round-8 Cat-β finding for Janitor.
   577	      Diagnostic + Sourcing Scout also read tone_rules for their
   578	      voice-classified outputs (§12 opener, per-candidate rationale).
   579	
   580	  recent_edit:
   581	    v0_2_v1_0_agent_access: [voice-drift-canary (W), Concierge (R), LoRA (R)]
   582	    v0_3_v1_0_agent_access:
   583	      - voice-drift-canary (W)  # v0.2 unchanged
   584	      - Concierge (R)            # v0.2 unchanged
   585	      - LoRA (R)                 # v0.2 unchanged
   586	      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
   587	      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
   588	      - Cash Conductor (W)       # v0.3 NEW — writes own chase-draft edits
   589	      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
   590	    rationale: |
   591	      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
   592	      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
   593	      for retraining queue). Janitor adds R for tacit-note harvest per
   594	      §4 Step 8. The v0.2 supplement file remains unchanged; this v0.3
   595	      supplement is the authoritative source for the expanded access list.
   596	
   597	# ============================================================================
   598	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   599	# ============================================================================
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
   950	# §9 — Why v0.3 is the right unblock
   951	# ============================================================================
   952	
   953	rationale: |
   954	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
   955	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
   956	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
   957	  adds 14 entity JSONB keys + 2 auxiliary tables + 3 config keys. The
   958	  per_claim_confidence_distribution payload key originally planned for
   959	  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
   960	  §5 of this supplement); v0.3 is silent on payload schema extensions.
   961	
   962	  After v0.3 ratifies + migration applies:
   963	    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
   964	      the v0.3-added fields (employment_type, key_skills, preferred_channel,
   965	      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
   966	      placement_status, week_1_status_vault_path, satisfaction_signal,
   967	      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
   968	      are now schema-backed. (Note: week_1_status_note narrative now lives
   969	      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
   970	      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
   971	      seniority — not yet in schema; brief.start_date should be
   972	      start_date_target; opportunity.sector — not yet in schema). These
   973	      residual gaps are tracked in W4-polish-schema-extension backlog;
   974	      they do not block v0.3 ratification but do require a Scribe agent.md
   975	      consistency-pass before Scribe ratifies.
   976	    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
   977	    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
   978	    - Concierge tenant_adapters.config field refs valid
   979	    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
   980	
   981	  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
   982	  ~3-5 residual mechanical findings per agent (down from current 4-6) —
   983	  those are per-agent specifics (workflow, validate.sh/cycle.sh build slices),
   984	  not schema gaps.
   985	

exec
/bin/zsh -lc 'rg -n "linkedin_url|phone:|mobile:|email:|first_name|last_name|bullhorn_id" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | head -80' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:58:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:63:      first_name:
docs/verticals/recruitment/vertical-schema.yaml:67:      last_name:
docs/verticals/recruitment/vertical-schema.yaml:71:      email:
docs/verticals/recruitment/vertical-schema.yaml:76:      phone:
docs/verticals/recruitment/vertical-schema.yaml:80:      mobile:
docs/verticals/recruitment/vertical-schema.yaml:166:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:171:      first_name:
docs/verticals/recruitment/vertical-schema.yaml:175:      last_name:
docs/verticals/recruitment/vertical-schema.yaml:179:      email:
docs/verticals/recruitment/vertical-schema.yaml:183:      mobile:
docs/verticals/recruitment/vertical-schema.yaml:230:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:291:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:295:      first_name:
docs/verticals/recruitment/vertical-schema.yaml:299:      last_name:
docs/verticals/recruitment/vertical-schema.yaml:303:      email:
docs/verticals/recruitment/vertical-schema.yaml:307:      phone:
docs/verticals/recruitment/vertical-schema.yaml:352:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:438:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:505:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:545:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:83:      linkedin_url:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:345:  #   level; candidate.linkedin_url has no Diagnostic field entry; Diagnostic
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:346:  #   gets R on linkedin_url (entity-level default), not the broader Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:659:      client_billing_email: {type: string, required: false, source: Accounting provider, pii: true}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:976:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '70,92p'; nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '50,85p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

codex
I found one schema-access inconsistency around `recent_edit` and one probable non-schema field claim in `decision_log`. I’m checking the base Postgres shape now so the rejection, if needed, cites the right source instead of guessing.
exec
/bin/zsh -lc 'rg -n "AgentMail|Composio|packages/harness/cortextos|kb-|brain system|stock KB|cortextOS" agents/recruitment/janitor/agent.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
29:Resolved by cortextOS daemon → spawns Janitor in Tier-2 batch mode (no persistent PTY). Typical runtime per tenant: 15-45 min depending on Bullhorn corpus size.

exec
/bin/zsh -lc 'rg -n "decision_log|outcome|phase|human_action" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/*.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:17:--   - decision_log.payload extension is DEFERRED to a future W4-polish ADR
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:23:--   - RLS policies on entities + entity_links + decision_log already in place
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:173:-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:348:  #   agent + which fields were touched in decision_log payload; reviewers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:358:  # decision_log row records who wrote. Entity-level RLS enforces TENANT
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:798:# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:801:decision_log_payload_extension:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:802:  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The

exec
/bin/zsh -lc "rg -n \"CREATE TABLE.*decision_log|decision_log|outcome|human_action|phase\" docs -g '*.md' -g '*.sql' -g '*.yaml' | head -120" in /Users/madsadmin/code/CortexOS
 succeeded in 1ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:348:  #   agent + which fields were touched in decision_log payload; reviewers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:358:  # decision_log row records who wrote. Entity-level RLS enforces TENANT
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:798:# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:801:decision_log_payload_extension:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:802:  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:17:--   - decision_log.payload extension is DEFERRED to a future W4-polish ADR
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:23:--   - RLS policies on entities + entity_links + decision_log already in place
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:173:-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
docs/_supplementary/planning-phase-brief.md:2:**The split between what you produce in chat with me (planning) and what Claude Code builds against the plans (building), plus the exact sequence for completing the planning phase.**
docs/_supplementary/planning-phase-brief.md:10:**Planning phase (you + me, in chat) produces 89 of the 95 artifacts:**
docs/_supplementary/planning-phase-brief.md:18:**Building phase (Claude Code + dev hire) takes those specs and writes ~11 substantial codebases.** Claude Code doesn't write the agent prompts or the legal contracts; it writes the *software that runs the prompts and enforces the contracts*.
docs/_supplementary/planning-phase-brief.md:48:## 3. The 95-artifact bucket (per phase)
docs/_supplementary/planning-phase-brief.md:133:**Total from now to first paying client:** ~5–6 months of serious work. That aligns with your 14-week build target *if* you parallelise: planning runs ahead 4–5 weeks, then build starts while planning continues for later-phase artifacts.
docs/_supplementary/planning-phase-brief.md:137:## 5. The planning phase, session by session
docs/_supplementary/planning-phase-brief.md:222:**End state of week 10:** planning phase 100% complete for v1 launch. Phase 7 (post-launch) produced as needed.
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:33:| 11 | **Tenant-context guard failure due transactionless `SET LOCAL` usage** — scripts and helpers used `SET LOCAL ifos.tenant_slug` in psql heredocs/strings without visible `BEGIN/COMMIT`. If PostgreSQL treats the setting as transaction-local with no active transaction, RLS-protected reads/writes can return zero rows, fail audit inserts, or silently fall back to JSONL. | ~~High~~ → Low post-remediation | High | Any psql call with `SET LOCAL` not bracketed by `BEGIN/COMMIT`, or a successful operation whose decision_log row falls back because RLS rejected the insert. | Round-2 remediation Fix 3-5 wraps every `SET LOCAL` psql call in a transaction. Verified by shellcheck + 29 helper tests + Round 3. | **Mitigated in this commit; Round-3 verified.** |
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/specs/ULTRAPLAN.md:227:- Three relevant tables: `tenants`, `entity_graph`, `decision_log`.
docs/specs/ULTRAPLAN.md:228:- Both `entity_graph` and `decision_log` partitioned by `tenant_id` (hash partitioning, 32 partitions to start).
docs/specs/ULTRAPLAN.md:413:Each agent has its outcome targets pinned. Restated from §3 of the product spec, with monthly measurement protocols.
docs/specs/PRODUCT-SPEC.md:17:Intel Force OS is the always-on operating system for UK recruitment agencies. It runs on CortexOS as the persistent agent runtime, lives inside each firm's existing stack (Bullhorn / Vincere / Voyager Infinity, Xero / Sage, Microsoft 365 / Google Workspace), and ships as two coordinated product lines — **IntelForce Recruit** for the front office and **IntelForce Temp** for the back office. Together they replace the operational drag of an entire junior team and, more importantly, generate revenue: surfaced BD opportunities, intercepted competitor briefs, faster cash collection, dormant-candidate reactivation, and post-placement nurture that compounds into referrals. The firm pays £499–£6,950/month per front-office tier and a separate £1,950–£5,950/month for the temp sub-platform. Every agent is pitched against a single, quantified outcome the buyer can verify within 90 days. Configuration scales because the moat is the per-vertical schema, not per-customer plumbing — onboarding becomes a 5-day wizard, not a 5-week project.
docs/specs/PRODUCT-SPEC.md:58:- **Revenue story** — the one quantified outcome the buyer signs against
docs/specs/PRODUCT-SPEC.md:84:- **Output contract (digest mode):** Monday 06:00 — 5–8 named BD opportunities with hiring signal, decision-maker identified, relationship history checked, salary benchmark, and drafted outreach in firm voice. Every Friday — a one-pager review of the week's BD outcomes.
docs/specs/PRODUCT-SPEC.md:292:       │     human override, every outcome) → SFT corpus →        │
docs/architecture/tenancy-invariants.md:24:- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/tenancy-invariants.md:86:### T5 — `ifos_app` role has no DELETE on `decision_log` or `recent_edit` (append-only audit tables)
docs/architecture/tenancy-invariants.md:88:- **Definition:** The two audit tables (`decision_log` from Day-4 + `recent_edit` from v0.2) are structurally append-only. Even if app code attempted DELETE, the role lacks permission.
docs/architecture/tenancy-invariants.md:90:- **Documentation source:** Day-4 §6.3 line 764 (`GRANT SELECT, INSERT ON decision_log TO ifos_app`) + v0.2 §6 line 172 (`GRANT SELECT, INSERT ON recent_edit TO ifos_app`).
docs/architecture/tenancy-invariants.md:94:  WHERE grantee='ifos_app' AND table_name IN ('decision_log','recent_edit')
docs/architecture/tenancy-invariants.md:97:  Expected: 4 rows total — `decision_log` × {SELECT, INSERT}, `recent_edit` × {SELECT, INSERT}. No UPDATE or DELETE.
docs/architecture/tenancy-invariants.md:177:  SELECT count(*) FROM decision_log WHERE agent_name='test-agent';  -- expect 0
docs/_supplementary/execution-plan.md:2:**Every document you still need, sequenced into phases you can tick off until Claude Code has everything it needs to build.**
docs/_supplementary/execution-plan.md:13:- **Part D** — Phased Execution Plan: seven phases, every artifact as a checklist item with a prompt to generate it
docs/_supplementary/execution-plan.md:115:Seven phases. Each has a goal, a checklist of artifacts, and a "done when" criterion. For each artifact: purpose, dependency, estimated effort (C = Claude session count, a single focused session), and a suggested prompt to generate it.
docs/_supplementary/execution-plan.md:352:  - *Prompt:* "Write the Agents View Specification: the list layout, per-agent detail page (config editor with diff-view vs template defaults, run history with outcome filters, cost trend chart, test-run button with sandbox execution, version pinning UI, pause/resume controls), changes-require-approval flow when editing config."
docs/_supplementary/execution-plan.md:472:  - *Prompt:* "Write the Case Study Template: structure for future case studies (problem, before-state, the implementation, results in numbers, client quote, duration, agents-enabled, outcome hero). Written to be filled in within 90 minutes of a 1-hour founding customer interview."
docs/_supplementary/execution-plan.md:541:  - *Prompt:* "Write the Voice Receptionist Full Specification: the Vapi platform configuration (assistants, tools, actions), the pre-call context injection (practice info, FAQs, protocols), the in-call escalation triggers, the post-call Claude Code agent that processes the call outcome, the Calendly/Cal.com booking flow, the FAQ training pipeline, the edge cases (accents, complaints, emergencies, out-of-hours), the testing framework (100+ test calls before launch)."
docs/_supplementary/execution-plan.md:575:Then work **phases in strict order.** Phase 2 cannot start productively before Phase 1 proves the runtime. Phase 3 can't be finalised without Phase 2's agents being real.
docs/_supplementary/execution-plan.md:577:Within a phase, order items by the dependency markers. 1.1 before 1.4 before 1.6. Unblock parallel tracks where the *Depends on* line has nothing upstream.
docs/_supplementary/execution-plan.md:582:Total effort estimate across all 7 phases: **~135 C sessions.**
docs/_supplementary/execution-plan.md:648:You have strategy, architecture, and a working prototype. You are missing the *stuff a developer actually reads* — 95 discrete documents and decisions, organised into 7 sequenced phases. Start with the 18 Open Decisions this week. Then Phase 1's 10 artifacts until one real Proposal Builder works end-to-end. Then Phase 2's 12 agent bundles. Then Phase 3's 12 platform specs. By week 7 you have everything Claude Code needs to build; Phases 4–7 happen in parallel with and after the build. Tick boxes. Resist scope creep. Ship.
docs/_supplementary/PRD-autonomous-agent.md:40:18. [Build Phases & Task Checklist](#18-build-phases--task-checklist)
docs/_archive-build-pack/08-OPEN-DECISIONS.md:3:**Questions only the founder can answer. Each has a recommendation, a recommended decision deadline (relative to Phase 0 start), and a "what blocks if undecided" note. Resolve these before the corresponding phase starts.**
docs/_archive-build-pack/08-OPEN-DECISIONS.md:158:**Recommendation:** Update the sub-processor list in `intel-force-os/docs/phase-5-business-legal/legal/dpa-template.md` before v2 launches. Notify all v1 customers in writing (email is fine — DPA standard practice).
docs/_archive-build-pack/08-OPEN-DECISIONS.md:218:1. At each phase boundary, bundle the phase's git diff + the relevant build-pack files
docs/_archive-build-pack/08-OPEN-DECISIONS.md:219:2. Hand to Codex with the prompt: *"Pressure-test this phase's implementation against the build pack. Surface deviations, weak abstractions, missing tests, latent bugs. Return a delta document."*
docs/_archive-build-pack/08-OPEN-DECISIONS.md:220:3. Apply Codex's delta as a final commit on the phase (with a co-author tag)
docs/_archive-build-pack/08-OPEN-DECISIONS.md:221:4. Move to the next phase
docs/_archive-build-pack/08-OPEN-DECISIONS.md:233:- `08-OPEN-DECISIONS.md` (this file) — append "✅ RESOLVED" status with date + outcome
docs/_archive-build-pack/08-OPEN-DECISIONS.md:235:- `~/.claude/projects/-Users-madsadmin-code-CortexOS/memory/MEMORY.md` — the Claude Code project memory index for v2 picks up the headline outcomes as `project_*.md` memories
docs/_archive-build-pack/03-ARCHITECTURE.md:44:│   ├── agents/                        (Plan, Explore, phase-architect subagent specs)
docs/_archive-build-pack/03-ARCHITECTURE.md:45:│   └── commands/                      (slash commands — /load-phase, /search-specs, etc.)
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:77:### Founding-phase (first 10 customers)
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:247:- The MSA, DPA, SLA, AUP, Privacy Policy, Terms of Service templates from `intel-force-os/docs/phase-5-business-legal/legal/`
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:248:- The pricing FAQ from `intel-force-os/docs/phase-5-business-legal/pricing/pricing-spec.md`
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:249:- The sales playbook from `intel-force-os/docs/phase-5-business-legal/playbooks/sales-playbook.md`
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:250:- The case-study playbook from `intel-force-os/docs/phase-5-business-legal/playbooks/case-study-playbook.md`
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:260:From `intel-force-os/docs/phase-0-strategic/intelforce-ai-os-strategic-plan.md`:
docs/build-brief/00-MASTER-BRIEF.md:396:| Realtime | SSE from `decision_log` writes | No websocket complexity |
docs/build-brief/00-MASTER-BRIEF.md:413:| **v1.0 minimum** | Weeks 11–13 (Ultraplan §9) | 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; **no Brain UI yet**. Total v1.0 effort ~11-13 person-days. |
docs/build-brief/00-MASTER-BRIEF.md:428:- **The decision log is append-only** from agents (and from `human_action` telemetry). The Brain UI surfaces it; it does not modify it.
docs/build-brief/00-MASTER-BRIEF.md:470:- [ ] Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per ADR-002 Edit 3 + `docs/architecture/second-brain-design.md` §2.4.2).
docs/build-brief/00-MASTER-BRIEF.md:508:| `phase-2-agent-suite/_shared/hook-helpers.sh` | Common validate/telemetry shell fns | `packages/agents-runtime/_shared/hooks/hook-helpers.sh` | Add `hh_decision_trigger/output/action` per Ultraplan §4.2 |
docs/build-brief/00-MASTER-BRIEF.md:509:| `phase-2-agent-suite/_shared/escalation-codes.md` | Escalation codes | `packages/agents-runtime/_shared/escalation-codes.md` | Expand to recruitment vocabulary |
docs/build-brief/00-MASTER-BRIEF.md:510:| `phase-2-agent-suite/_shared/universal-banned-phrases.txt` | AI-tell phrases | `packages/agents-runtime/_shared/universal-banned-phrases.txt` | Verbatim |
docs/build-brief/00-MASTER-BRIEF.md:511:| `phase-1-poc-stack/platform-specs/minimal-vault-structure.md` | Vault layout | `docs/architecture/vault-structure.md` | Update to recruitment frontmatter schema |
docs/build-brief/00-MASTER-BRIEF.md:512:| `phase-1-poc-stack/platform-specs/webhook-receiver-spec.md` | Fastify webhook router | `packages/webhook-receiver/` | Routing logic adapted to bus-drop instead of Unix socket |
docs/build-brief/00-MASTER-BRIEF.md:932:- Don't skip Codex ratification at phase boundaries
docs/architecture/architecture-cohesion-review.md:68:| ADR-003 | phase enum for renderer | Day-4 §6.3 CHECK constraint | **✓ landed but with deviation per ADR-004 Decision 7** — phase='render' NOT in enum; uses agent_name='_renderer' + existing phase |
docs/architecture/architecture-cohesion-review.md:71:| ADR-004 | phase enum pattern | `agents/_shared/hook-helpers.sh::hh_decision_action` | ✓ landed Phase 3 |
docs/architecture/architecture-cohesion-review.md:105:### C1 — Renderer phase enum (RESOLVED post-Round-1)
docs/architecture/architecture-cohesion-review.md:107:- **agent-bundle-renderer-design.md** (pre-Round-1) said `phase='render'` written to decision_log on renderer failure
docs/architecture/architecture-cohesion-review.md:109:- **Resolution:** ADR-004 Decision 7 (Codex Round 1 RATIFIED) + Day-8-evening remediation `2b287d3` corrected both renderer-design + ADR-003 to use `agent_name='_renderer'` + existing `phase=gating_failed|action`. **RESOLVED.**
docs/architecture/architecture-cohesion-review.md:236:| R10 | G5: Multi-tenant connection pool sizing | Low | v1.1+ scale exercise | Claude Code | v1.1 design phase |
docs/_archive-build-pack/06-BUILD-PLAN.md:3:**Phased slices, A/B/C-style. Each phase has a focused goal, a stack of slices, acceptance criteria, and a ratification step through Codex. The plan optimises for "ship a thing each phase that the founder can see working", not for breadth.**
docs/_archive-build-pack/06-BUILD-PLAN.md:7:## The phases at a glance
docs/_archive-build-pack/06-BUILD-PLAN.md:32:- Commit: `chore(phase-0): monorepo scaffold`
docs/_archive-build-pack/06-BUILD-PLAN.md:40:- Commit: `chore(phase-0): vendor cortextos at <SHA>`
docs/_archive-build-pack/06-BUILD-PLAN.md:46:- Commit: `feat(phase-0): daemon wrapper boots cortextos`
docs/_archive-build-pack/06-BUILD-PLAN.md:53:- Commit: `feat(phase-0): orchestrator sends hello message`
docs/_archive-build-pack/06-BUILD-PLAN.md:59:- Commit: `feat(phase-0): db scaffold + tenants`
docs/_archive-build-pack/06-BUILD-PLAN.md:271:## How phases interact with Codex
docs/_archive-build-pack/06-BUILD-PLAN.md:276:2. Hand to Codex with the prompt: *"Pressure-test this phase's implementation against the build pack. Surface deviations, weak abstractions, missing tests, latent bugs. Return a delta document."*
docs/_archive-build-pack/06-BUILD-PLAN.md:277:3. Apply Codex's delta as a final commit on the phase
docs/_archive-build-pack/06-BUILD-PLAN.md:278:4. Move to the next phase
docs/_archive-build-pack/06-BUILD-PLAN.md:286:- **One phase at a time.** No starting Phase 2 work while Phase 1 is in flight.
docs/_archive-build-pack/06-BUILD-PLAN.md:290:- **Update CLAUDE.md at phase boundaries.** Future Claude Code sessions need to see "Phase X complete" to orient.
docs/_archive-build-pack/05-MIGRATION-MAP.md:106:| Phase 0 strategic | KEEP (reference) | `docs/phase-0-strategic/` | Reference from `07-V1-INHERITED-CONTEXT.md`; don't copy |
docs/_archive-build-pack/05-MIGRATION-MAP.md:107:| Phase 1 POC stack | DROP | `docs/phase-1-poc-stack/` | Already retired |
docs/_archive-build-pack/05-MIGRATION-MAP.md:108:| Phase 2 agent suite (10 agent specs) | KEEP (mine for prompts) | `docs/phase-2-agent-suite/` | Source for `packages/agents/templates/<key>/prompt.md` |
docs/_archive-build-pack/05-MIGRATION-MAP.md:109:| Phase 3 platform | KEEP (lifts informed) | `docs/phase-3-platform/` | Informs `03-ARCHITECTURE.md` decisions on multi-tenancy, secrets, observability |
docs/_archive-build-pack/05-MIGRATION-MAP.md:110:| Phase 4 dashboard | KEEP (lifts informed) | `docs/phase-4-dashboard/` | Informs the dashboard rebuild |
docs/_archive-build-pack/05-MIGRATION-MAP.md:111:| Phase 5 business/legal | KEEP (as-is) | `docs/phase-5-business-legal/` | Intel Force Ltd legal docs unchanged; v2 reuses MSA/DPA/SLA/AUP/Privacy/ToS |
docs/_archive-build-pack/05-MIGRATION-MAP.md:112:| Phase 6 ops runbooks | KEEP (adapt) | `docs/phase-6-ops-runbooks/` | Adapt incident + DR runbooks for v2 topology |
docs/_archive-build-pack/05-MIGRATION-MAP.md:123:| Logo, palette, typography | KEEP | `WEBSITE-CONTEXT.md` §6 + `intel-force-os/docs/phase-5-business-legal/marketing/brand-identity-spec.md` | `packages/ui/tailwind.tokens.css` |
docs/_supplementary/build-plan-original.md:94:<2–3 sentences: who this agent is, what outcome they own>
docs/architecture/agent-bundle-renderer-design.md:109:| `agents/recruitment/<name>/agent.md` | `orgs/<org>/agents/<name>/CLAUDE.md` | **Synthesis** | (1) `agent.md` body verbatim; (2) **cortextOS preamble template** — spec gap §2.1-A; (3) per-tenant footer (resolved tenant_slug, current `_voice/style-guide.md` path, decision_log Postgres role); (4) hook invocation block referencing `.claude/hooks/{validate,context}.sh` paths | Lint pass: no unresolved `{{tenant_slug}}` / `{{...}}` placeholders survive; preamble matches the renderer's canonical preamble version (hash check); CLAUDE.md is non-empty and parses as valid markdown |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:144:| `tasks` | cortextOS task management — `create-task` / `update-task` / `complete-task` against the `orgs/{org}/tasks/` directory | IFOS uses Postgres `decision_log` for the "what did this agent do" trail and the wiki for the "what's the state of this entity" view. The cortextOS task store is unused by IFOS agents (parallel to the KB-untouched decision per ADR-002 Decision 1) |
docs/architecture/agent-bundle-renderer-design.md:518:- **structured log:** one JSONL line per render appended to `${frameworkRoot}/orgs/<org>/_meta/render-log.jsonl`. Fields: `timestamp`, `agent`, `tenant`, `bundle_sha` (git SHA of the source bundle dir, computed via `git hash-object -t tree`), `render_outcome` (one of `success | no-op | failed`), `exit_code`, `duration_ms`, optional `error` string on failure.
docs/architecture/agent-bundle-renderer-design.md:606:   - JSONL line appended with `render_outcome: no-op`.
docs/architecture/agent-bundle-renderer-design.md:638:**Escalation:** `ESC_RENDERER_FAILED` row written to `decision_log` Postgres table with `agent_name='_renderer'`, `phase='gating_failed'`, `payload->>'reason'='schema-validation-failure'`. (`phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — see ADR-004 Decision 7; the 5-value enum is `trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 schema migration.) If `--notify-on-failure` (default true), Telegram message to the operator with the validation path.
docs/architecture/agent-bundle-renderer-design.md:708:- **Audit log:** Postgres `decision_log` row with `tenant_slug`, `agent_name='_renderer'`, `phase='gating_failed'` (failures) or `phase='action'` (successful renders), `payload->>'reason'` carries the reason code. RLS-isolated per tenant. Codex's Day-7 ratification report queries this table for all rows where `agent_name='_renderer' AND payload->>'reason' LIKE 'ESC_RENDERER_FAILED%'`. (Per ADR-004 Decision 7: `phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — use the 5-value enum from Day-4 §6.3 + Day-5 schema migration.)

exec
/bin/zsh -lc "rg -n \"janitor_dedup_threshold|janitor_last_run\" docs agents -g '*.md' -g '*.yaml' -g '*.sql'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:398:    'janitor_last_run',
agents/recruitment/janitor/agent.md:42:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist)
agents/recruitment/janitor/agent.md:95:     tenant_adapters.config.janitor_last_run — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist)
agents/recruitment/janitor/agent.md:166:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:275:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |

codex
REJECTED

1. §5 misroutes hard Gate A failures to the wrong escalation code. Line 187 says `ESC_AGENT_OUTPUT_SHAPE` applies to “ALL Gate A conditions,” including voice classifier, PII, and write-batch size. The catalogue defines `ESC_VOICE_DRIFT` for classifier failures and `ESC_PII_LEAKAGE_RISK` as blocking for PII leakage; downgrading PII to `ESC_AGENT_OUTPUT_SHAPE` weakens Gate A routing. Fix §5 so each Gate A condition maps to its catalogue code, reserving `ESC_AGENT_OUTPUT_SHAPE` for report/output-shape failures only.

2. §3 assumes a non-schema-backed `decision_log.outcome` field. Line 59 says tacit notes are harvested from `decision_log` rows with `outcome='approved_after_edit'`, but the schema only documents `decision_log` as `agent_name`, `phase`, and `payload JSONB`; `approved_after_edit` is the `recent_edit.resolution` enum in v0.2 supplement §1.3. Fix §3 to harvest from `recent_edit.resolution='approved_after_edit'` and use `decision_log` only for action-context joins.

3. §4 cites the wrong schema authority for Janitor’s `recent_edit` access. Lines 135-137 say Janitor queries the `recent_edit` v0.2 table directly, but v0.2 access lists only voice-drift-canary, Concierge, and LoRA; Janitor R access is added in v0.3 supplement §2. Fix the citation to v0.3 supplement and add v0.3 schema/migration ratification as a §8 prerequisite.

4. §2/§4 use undocumented `tenant_adapters.config` keys. Lines 42, 95, and 166 rely on `janitor_dedup_threshold` and `janitor_last_run`; `rg` finds these only in the v0.2-to-v0.3 migration allowlist, not in `vertical-schema.yaml` or the v0.3 supplement’s `tenant_adapters_config_additions`. Fix by adding both keys with type/owner/read-write semantics to the schema supplement, then cite that schema section instead of only the migration allowlist.
tokens used
95,601
REJECTED

1. §5 misroutes hard Gate A failures to the wrong escalation code. Line 187 says `ESC_AGENT_OUTPUT_SHAPE` applies to “ALL Gate A conditions,” including voice classifier, PII, and write-batch size. The catalogue defines `ESC_VOICE_DRIFT` for classifier failures and `ESC_PII_LEAKAGE_RISK` as blocking for PII leakage; downgrading PII to `ESC_AGENT_OUTPUT_SHAPE` weakens Gate A routing. Fix §5 so each Gate A condition maps to its catalogue code, reserving `ESC_AGENT_OUTPUT_SHAPE` for report/output-shape failures only.

2. §3 assumes a non-schema-backed `decision_log.outcome` field. Line 59 says tacit notes are harvested from `decision_log` rows with `outcome='approved_after_edit'`, but the schema only documents `decision_log` as `agent_name`, `phase`, and `payload JSONB`; `approved_after_edit` is the `recent_edit.resolution` enum in v0.2 supplement §1.3. Fix §3 to harvest from `recent_edit.resolution='approved_after_edit'` and use `decision_log` only for action-context joins.

3. §4 cites the wrong schema authority for Janitor’s `recent_edit` access. Lines 135-137 say Janitor queries the `recent_edit` v0.2 table directly, but v0.2 access lists only voice-drift-canary, Concierge, and LoRA; Janitor R access is added in v0.3 supplement §2. Fix the citation to v0.3 supplement and add v0.3 schema/migration ratification as a §8 prerequisite.

4. §2/§4 use undocumented `tenant_adapters.config` keys. Lines 42, 95, and 166 rely on `janitor_dedup_threshold` and `janitor_last_run`; `rg` finds these only in the v0.2-to-v0.3 migration allowlist, not in `vertical-schema.yaml` or the v0.3 supplement’s `tenant_adapters_config_additions`. Fix by adding both keys with type/owner/read-write semantics to the schema supplement, then cite that schema section instead of only the migration allowlist.
