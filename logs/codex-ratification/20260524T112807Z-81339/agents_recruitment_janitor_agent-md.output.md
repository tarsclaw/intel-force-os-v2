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
session id: 019e59be-0a75-7ba1-a765-caaa7c485f9f
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
- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold`)

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

1. **Candidate merge** (`PUT /Candidate/{primary_id}` + cascade) — only when confidence ≥0.85 per Gate A; no merge if either candidate had Bullhorn activity in last 90 days without explicit review flag (per ULTRAPLAN A2 line 510 verbatim). Action type: **`bullhorn_candidate_dedupe`** (existing in autosend-policy.yaml line 69; yellow tier; sample_rate: 10).
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
     tenant_adapters.config.janitor_last_run)
   → hh_decision_output("janitor_scan", "tenant:<slug>", "<N> entities scanned")
   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per §1.1.2 of v0.2 supplement)

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

Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint; per Day-19 catalogue add at `escalation-codes.md` line 184) OR `ESC_DUPLICATE_DETECTED` (merge-confidence reject; existing line 127) per the failed condition. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (line 163) is NOT used by Janitor — that code is reserved for vertical-schema field-constraint violations at write-time.

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
| `ESC_DUPLICATE_DETECTED` | Per catalogue trigger: dedup confidence ≥0.85 cases requiring human review (NOT used for <0.85 reject cases — those silently drop per Step 3 algorithm) | warn | operator_chat_id |
| `ESC_GATE_B_MISS` | Either independent Gate-B threshold (dedup <15% OR field-completeness <10%) missed for 3 consecutive runs. NOT a composite — see §5 Gate B for the two-threshold rule. | warn | operator_chat_id |
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
I’m going to verify the cited catalogue, schema, policy, and source-line claims against the repo before deciding.
exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,230p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# IFOS auto-send policy (runtime table)
     2	#
     3	# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
     4	# Read by agents/_shared/hook-helpers.sh::autosend_policy_lookup() at every
     5	# hh_decision_action() invocation. Per-tenant overrides live in Postgres
     6	# tenant_adapters.config.tier_overrides (§8).
     7	#
     8	# 41 v1.0 action_types: 13 green + 10 yellow + 10 orange + 8 red.
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
   107	  # ───────────────────────────────────────────────────────────
   108	  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
   109	  # ───────────────────────────────────────────────────────────
   110	
   111	  bullhorn_candidate_dedupe:
   112	    tier: yellow
   113	    agent: janitor
   114	    sample_rate: 10
   115	    reason: "Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review"
   116	    irreversible: false
   117	
   118	  bullhorn_field_backfill:
   119	    tier: yellow
   120	    agent: janitor
   121	    sample_rate: 10
   122	    reason: "Fills missing canonical schema fields from Companies House or LinkedIn enrichment; reversible PATCH; high-volume; source provenance logged in payload"
   123	    irreversible: false
   124	
   125	  bullhorn_note_attach:
   126	    tier: yellow
   127	    agent: janitor
   128	    sample_rate: 20
   129	    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
   130	    irreversible: false
   131	
   132	  bullhorn_note_append_summary:
   133	    tier: yellow
   134	    agent: scribe
   135	    sample_rate: 20
   136	    reason: "Appends to candidate record; consultant-only visibility; high-volume; format quality needs review"
   137	    irreversible: false
   138	
   139	  linkedin_connection_request:
   140	    tier: yellow
   141	    agent: sourcing-scout
   142	    sample_rate: 5
   143	    reason: "Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy"
   144	    irreversible: true
   145	
   146	  xero_reminder_draft_internal:
   147	    tier: yellow
   148	    agent: cash-conductor
   149	    sample_rate: 10
   150	    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
   151	    irreversible: false
   152	
   153	  bullhorn_note_draft_internal:
   154	    tier: yellow
   155	    agent: concierge
   156	    sample_rate: 10
   157	    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
   158	    irreversible: false
   159	
   160	  bullhorn_scribe_field_write:
   161	    tier: yellow
   162	    agent: scribe
   163	    sample_rate: 10
   164	    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
   165	    irreversible: false
   166	
   167	  accounting_reconciliation_write:
   168	    tier: yellow
   169	    agent: cash-conductor
   170	    sample_rate: 10
   171	    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
   172	    irreversible: false
   173	
   174	  concierge_email_draft:
   175	    tier: yellow
   176	    agent: concierge
   177	    sample_rate: 20
   178	    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
   179	    irreversible: false
   180	

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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '1,430p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# IFOS recruitment vertical schema v0.1
     2	# ============================================================================
     3	# Layered above the Day-4 generic primitives:
     4	#   - entities (id, tenant_slug, entity_type, entity_id, data JSONB, version, ...)
     5	#   - entity_links (..., source_entity_type, source_entity_id, target_entity_type, target_entity_id, link_type, ...)
     6	#   - decision_log (..., agent_name, phase, payload JSONB, ...)
     7	# This file specifies the recruitment-domain entity_type + link_type slugs
     8	# and the JSON Schema shape of entities.data per entity_type.
     9	#
    10	# Source: master brief §6 Day 6 line 490 (8 core entities)
    11	#       + bullhorn-integration-path.md §4.1 (per-agent endpoint requirements)
    12	#       + autosend-safety-policy.md §3 (action_type references)
    13	#       + Day-4 runbook §6.3 (canonical Postgres schema)
    14	#       + Day-5 v1.0-kill-criterion.md (Trigger 1 acquisition-by-2026-06-03)
    15	# ============================================================================
    16	
    17	vertical: recruitment
    18	version: v0.1
    19	status: Proposed
    20	date: 2026-05-18
    21	author: founder (Maddox), Day-6 draft via Claude Code
    22	codex_ratification_queue_position: 18
    23	
    24	non_goals:
    25	  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
    26	  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
    27	  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.
    28	
    29	# ============================================================================
    30	# §1 — Entity definitions
    31	# ============================================================================
    32	# Each entity below specifies:
    33	#   - description: 1-2 sentence definition in the IFOS canonical vocabulary
    34	#   - bullhorn_source: the Bullhorn entity (and any status filter) this maps from
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
   261	        source: IFOS-derived (Janitor maintains)
   262	      account_owner_user_id:
   263	        type: integer
   264	        required: false
   265	        source: Bullhorn.ClientCorporation.owner.id
   266	      preferred_terms:
   267	        type: string
   268	        required: false
   269	        source: IFOS-derived (commercial framework; free text for v0.1; structured for v1.1+)
   270	      date_added_at:
   271	        type: timestamp
   272	        required: true
   273	        source: Bullhorn.ClientCorporation.dateAdded
   274	      hq_city:
   275	        type: string
   276	        required: false
   277	        source: Bullhorn.ClientCorporation.address.city
   278	    notes:
   279	      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
   280	      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
   281	
   282	  # --------------------------------------------------------------------------
   283	  contact:
   284	    description: |
   285	      A person at a client company. Decision-makers, hiring managers, HR, procurement. Bullhorn calls this `ClientContact`. v1.0 representation is thin (10 fields); v1.1 Triage agent expands decision-authority modelling.
   286	    bullhorn_source: Bullhorn.ClientContact
   287	    v1_0_agent_access:
   288	      - Concierge (R — decision-maker context per bullhorn §4.1 A6; thin in v1.0)
   289	      - (v1.1+) Inbound Triage — R+W expansion per master brief §9
   290	    canonical_fields:
   291	      bullhorn_id:
   292	        type: integer
   293	        required: true
   294	        source: Bullhorn.ClientContact.id
   295	      first_name:
   296	        type: string
   297	        required: true
   298	        source: Bullhorn.ClientContact.firstName
   299	      last_name:
   300	        type: string
   301	        required: true
   302	        source: Bullhorn.ClientContact.lastName
   303	      email:
   304	        type: string
   305	        required: false
   306	        source: Bullhorn.ClientContact.email
   307	      phone:
   308	        type: string
   309	        required: false
   310	        source: Bullhorn.ClientContact.phone
   311	      title:
   312	        type: string
   313	        required: false
   314	        source: Bullhorn.ClientContact.title
   315	        notes: Job title at client.
   316	      decision_authority:
   317	        type: string
   318	        required: false
   319	        enum: [yes, no, influencer, blocker, unknown]
   320	        source: IFOS-derived (founder captures during intake; thin v0.1, expanded v1.1)
   321	        notes: v0.1 is essentially a tag for Concierge addressee-resolution gating; v1.1 Triage agent owns expansion (sub-fields for decision-domain, budget authority, etc.).
   322	      preferred_contact_method:
   323	        type: string
   324	        required: false
   325	        enum: [email, phone, telegram, whatsapp, linkedin]
   326	        source: IFOS-derived
   327	      date_added_at:
   328	        type: timestamp
   329	        required: true
   330	        source: Bullhorn.ClientContact.dateAdded
   331	      do_not_contact:
   332	        type: boolean
   333	        required: true
   334	        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
   335	        notes: Hard gate for autosend orange-tier actions; default false; set true on opt-out.
   336	    notes:
   337	      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
   338	      - v1.1 Triage expands: structured decision-authority (budget tier, decision domain, escalation chain), engagement history aggregate, preferred-channel sentiment.
   339	
   340	  # --------------------------------------------------------------------------
   341	  brief:
   342	    description: |
   343	      A role being recruited for. Master brief canonical vocabulary uses `brief`; §6 Day 6 line 490 lists "Role/Brief" — `brief` is the canonical entity_type slug; `role` is documented alias. Bullhorn calls this `JobOrder`.
   344	    bullhorn_source: Bullhorn.JobOrder
   345	    aliases: [role]
   346	    v1_0_agent_access:
   347	      - Janitor (R — status drift sweep per bullhorn §4.1 A2)
   348	      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
   349	      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
   350	      - Concierge (R — linked-brief context per bullhorn §4.1 A6)
   351	    canonical_fields:
   352	      bullhorn_id:
   353	        type: integer
   354	        required: true
   355	        source: Bullhorn.JobOrder.id
   356	      title:
   357	        type: string
   358	        required: true
   359	        source: Bullhorn.JobOrder.title
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
   386	        required: false
   387	        source: IFOS-derived
   388	      location:
   389	        type: string
   390	        required: false
   391	        source: Bullhorn.JobOrder.address.city
   392	      remote_policy:
   393	        type: string
   394	        required: false
   395	        enum: [full_remote, hybrid_2_days_office, hybrid_3_days_office, on_site, flexible]
   396	        source: IFOS-derived (extracted from JD)
   397	      required_skills:
   398	        type: array
   399	        items: string
   400	        required: false
   401	        source: IFOS-derived (extracted from JD; v0.1 free strings; v1.1+ canonicalised skill taxonomy)
   402	      start_date_target:
   403	        type: date
   404	        required: false
   405	        source: IFOS-derived
   406	      urgency:
   407	        type: string
   408	        required: false
   409	        enum: [hot, warm, cold]
   410	        source: IFOS-derived (Concierge maintains based on client check-in cadence)
   411	      status:
   412	        type: string
   413	        required: true
   414	        enum: [open, on_hold, filled, closed_lost, closed_won, cancelled]
   415	        source: Bullhorn.JobOrder.status (with mapping)
   416	      date_added_at:
   417	        type: timestamp
   418	        required: true
   419	        source: Bullhorn.JobOrder.dateAdded
   420	      date_last_modified_at:
   421	        type: timestamp
   422	        required: true
   423	        source: Bullhorn.JobOrder.dateLastModified
   424	    notes:
   425	      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
   426	      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).
   427	
   428	  # --------------------------------------------------------------------------
   429	  placement:
   430	    description: |

codex
The first pass already shows the action types and schema fields mostly exist, but I’m checking the line-specific claims and helper/API names because this review requires citation accuracy, not just plausibility.
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '230,420p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   276	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   277	- **Payload fields:** `failure_type`, `last_attempt_at`, `affected_tenant_slug`
   278	- **Recovery:** founder reauthenticates MS Graph OAuth
   279	
   280	#### `ESC_ACCOUNTING_AUTH`
   281	- **Severity:** **blocking** — Cash Conductor degraded (read-only Xero queries from cache; no reminders sent)
   282	- **Trigger:** Xero (or alt accounting provider) OAuth token refresh failed; API returns 401
   283	- **Phase:** `gating_failed`
   284	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   285	- **Payload fields:** `provider` (`xero` | `quickbooks` | `freeagent`), `failure_type`, `last_attempt_at`
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
   297	- **Severity:** info — warning before blocking
   298	- **Trigger:** Open Banking PSD2 consent ≤14 days from 90-day expiry; emitted by nightly health check
   299	- **Phase:** `gating_failed`
   300	- **Routing:** `operator_chat_id` (no oncall CC — non-urgent)
   301	- **Payload fields:** `consent_expires_at`, `days_remaining`, `bank_provider`
   302	- **Recovery:** founder schedules reauth within remaining window
   303	
   304	### 2.8 — Provider read/write failures (4 codes)
   305	Source: derived from v1.0 agent.md adapter call sites
   306	
   307	#### `ESC_BULLHORN_WRITE_FAIL`
   308	- **Severity:** warn
   309	- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
   310	- **Phase:** `gating_failed`
   311	- **Routing:** `operator_chat_id`
   312	- **Payload fields:** `endpoint`, `entity_type`, `entity_id`, `status_code`, `error_body_preview` (truncated 120 chars)
   313	
   314	#### `ESC_ACCOUNTING_WRITE_FAIL`
   315	- **Severity:** warn
   316	- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
   317	- **Phase:** `gating_failed`
   318	- **Routing:** `operator_chat_id`
   319	- **Payload fields:** `provider`, `endpoint`, `entity_type`, `status_code`, `error_body_preview`
   320	
   321	#### `ESC_PROVIDER_FETCH_FAIL`
   322	- **Severity:** warn
   323	- **Trigger:** Generic upstream provider read failure (Companies House, web-scraper, any non-Bullhorn-non-Accounting GET) after retry budget exhausted; distinct from rate-limit
   324	- **Phase:** `gating_failed`
   325	- **Routing:** `operator_chat_id`
   326	- **Payload fields:** `upstream` (e.g. `companies-house`, `web-scraper`, `linkedin-cache`), `endpoint`, `status_code`, `consecutive_failures`
   327	
   328	#### `ESC_SEND_FAIL`
   329	- **Severity:** warn — distinct from auth/rate-limit; the send itself failed at the protocol layer
   330	- **Trigger:** External send (Gmail / Outlook / Twilio / Telegram-to-customer) returned 5xx or transport error after retry budget
   331	- **Phase:** `gating_failed`
   332	- **Routing:** `operator_chat_id`
   333	- **Payload fields:** `channel` (`gmail` | `outlook` | `twilio` | `telegram`), `recipient_id_hash`, `error_class`, `attempts_made`
   334	
   335	### 2.9 — Auto-send orchestration (4 codes)
   336	Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics
   337	
   338	#### `ESC_AUTOSEND_ORANGE_PENDING`
   339	- **Severity:** info — distinct from ESC_AUTOSEND_NEEDS_REVIEW (which is the initial queue event)
   340	- **Trigger:** Orange-tier action has been pending operator response for ≥50% of declared `timeout` (heartbeat reminder before bridge timeout)
   341	- **Phase:** `action`
   342	- **Routing:** `operator_chat_id` (gentle reminder; no oncall)
   343	- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`
   344	
   345	#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
   346	- **Severity:** warn — orange action's approval window expired without response
   347	- **Trigger:** Orange-tier action exceeded its `timeout` (default PT4H) without operator approve/reject
   348	- **Phase:** `gating_failed`
   349	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (operator absent + commitment may need rerouting)
   350	- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
   351	- **Recovery:** action converts to manual reconciliation; operator handles offline
   352	
   353	#### `ESC_AUTOSEND_RACE`
   354	- **Severity:** warn — concurrency violation
   355	- **Trigger:** Two agents attempted to send the same `payload_hash` within same tenant within `race_window_seconds` (default 60s); second attempt detected by `decision_log` UPSERT-conflict
   356	- **Phase:** `gating_failed`
   357	- **Routing:** `operator_chat_id`
   358	- **Payload fields:** `payload_hash`, `first_agent_name`, `second_agent_name`, `time_delta_ms`, `action_type`
   359	- **Recovery:** second attempt suppressed; first wins (idempotency by payload_hash)
   360	
   361	#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
   362	- **Severity:** info — quality sampling, not a failure
   363	- **Trigger:** Yellow-tier action was sampled per `sample_rate` (1-in-N) for post-hoc human review; sampling is informational + drives ongoing quality monitoring
   364	- **Phase:** `action`
   365	- **Routing:** `operator_chat_id`; sampled action is queued in `spot_check_queue_path` (`/vault/{tenant_slug}/spot-checks/`)
   366	- **Payload fields:** `action_type`, `original_decision_log_id`, `sample_rate`, `sampling_reason`, `target`, `payload_preview`
   367	- **Note:** Operator review of sampled rows is asynchronous (typically end-of-day batch); no SLA timer.
   368	
   369	### 2.10 — Agent workflow (10 codes)
   370	Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
   371	
   372	#### `ESC_GATE_B_MISS`
   373	- **Severity:** warn — post-send quality signal; not a hard failure
   374	- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
   375	- **Phase:** `gating_failed`
   376	- **Routing:** `operator_chat_id`
   377	- **Payload fields:** `agent_name`, `metric_name`, `actual_value`, `threshold`, `window`, `sample_size`
   378	- **Note:** Local Gate B is a leading metric for agent quality; consecutive misses inform per-agent quality review. Not tied to a kill-criterion trigger in v1.0 (per disagreement-doc Cat-3 disposition).
   379	
   380	#### `ESC_TONE_RULE_VIOLATION`
   381	- **Severity:** warn — voice/tone classifier flagged output as violating a tenant `tone_rule` row
   382	- **Trigger:** Output drafted by an agent matches a tenant-defined `tone_rule` violation pattern (e.g. tenant prohibits "absolutely" in customer-facing comms; output contained it)
   383	- **Phase:** `gating_failed`
   384	- **Routing:** `operator_chat_id`
   385	- **Payload fields:** `tone_rule_id`, `pattern_violated`, `output_snippet_redacted`, `agent_name`, `tenant_slug`
   386	- **Recovery:** agent re-drafts with violation removed; if persistent, escalates to tone_rule review
   387	
   388	#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
   389	- **Severity:** warn
   390	- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
   391	- **Phase:** `gating_failed`
   392	- **Routing:** `operator_chat_id`
   393	- **Payload fields:** `entity_type`, `field_name`, `extracted_value`, `confidence_score`, `source` (e.g. `companies-house`, `linkedin`, `cv-pdf`), `agent_name`
   394	
   395	#### `ESC_CANDIDATE_DATA_INCOMPLETE`
   396	- **Severity:** warn
   397	- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
   398	- **Phase:** `gating_failed`
   399	- **Routing:** `operator_chat_id`
   400	- **Payload fields:** `candidate_id`, `missing_fields` (list), `shortlist_id`, `brief_id`
   401	
   402	#### `ESC_ADDRESSEE_MISMATCH`
   403	- **Severity:** **blocking** — Cash Conductor refuses to send reminder/invoice
   404	- **Trigger:** Outbound reminder/invoice addressee does not match Bullhorn placement client OR Xero contact (cross-system reconciliation failure)
   405	- **Phase:** `gating_failed`
   406	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   407	- **Payload fields:** `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`)
   408	- **Recovery:** founder reviews; either reconciles manually OR updates one system to match
   409	
   410	#### `ESC_RECONCILIATION_AMBIGUOUS`
   411	- **Severity:** warn — Cash Conductor cannot confidently match incoming payment to a specific invoice
   412	- **Trigger:** Bank-feed payment line cannot be matched to a single Xero invoice; multiple candidates within tolerance
   413	- **Phase:** `gating_failed`
   414	- **Routing:** `operator_chat_id`
   415	- **Payload fields:** `payment_id`, `amount`, `payee_name_raw`, `candidate_invoice_ids` (list), `match_basis` (e.g. `amount_only`, `payee_partial`)
   416	
   417	#### `ESC_DNC_FILTER_HIT`
   418	- **Severity:** **blocking** — outbound (email / SMS / call) refused
   419	- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
   420	- **Phase:** `gating_failed`

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "rg -n \"Janitor|A2|week 5|day-30|15%|0.85|Trigger 3|Trigger 8|8\\.2|W5|kill\" docs agents -g '*.md' -g '*.yaml'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:171:    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:226:4. **Codex ratification** — invariant document is ratified via `review-architecture-decision.md` skill; updates re-ratify.
agents/_shared/README.md:123:4. Founder runs the kill-criterion Trigger 5 query (autosend-safety-policy §7):
agents/_shared/README.md:130:5. Report result back. If row count > 3 in a 7-day window, kill-criterion Trigger 5 fires (per `v1.0-kill-criterion.md` §2 Trigger 5).
agents/_shared/README.md:161:Production rollout (other tenants) waits for Codex ratification of v0.2 + Diagnostic + Janitor verification of the schema against real Bullhorn data (master brief §6 Day 6 Q3 trigger from v0.1).
agents/_shared/README.md:178:- `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 5 — red-tier breach kill criterion
agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
docs/operations/bullhorn-outreach-emails.md:5:**Purpose:** Drop-in email drafts the founder sends to Bullhorn partnerships + developer support to resolve Sub-decisions A + B in `docs/decisions/bullhorn-integration-path.md`. Closes Risk #2 mitigation path; unblocks Janitor W5 build gate.
docs/operations/bullhorn-outreach-emails.md:17:**These don't block today.** They block **Janitor W5 build** (per kill-criterion §2 Trigger 3). You have ~5 weeks of runway. But send today/Monday because Bullhorn's response time is 2-5 business days, and we want the answers before Diagnostic W3-4 completes so Janitor W5 starts unblocked.
docs/operations/bullhorn-outreach-emails.md:44:> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
docs/operations/bullhorn-outreach-emails.md:74:- If they require marketplace membership before production access → Sub-decision A is **Marketplace**; need cost + timeline to assess against kill-criterion §2 Trigger 3 (Janitor W5 deadline).
docs/operations/bullhorn-outreach-emails.md:130:- Sandbox available → use it for CI tests + W5 build. Save credentials to your local 1Password as "IFOS Bullhorn Dev sandbox".
docs/operations/bullhorn-outreach-emails.md:151:2. **Monday 2026-06-01** — second nudge with explicit deadline reference ("we're targeting Janitor build W5; need clarity by then")
docs/operations/bullhorn-outreach-emails.md:160:**Reference.** Two drop-in email drafts ready for founder to send. Expected wall-clock: 1 week for both responses. Outcome: Sub-decisions A + B flip Accepted; Risk #2 mitigated; Janitor W5 build unblocked.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:419:    trigger_for_revisit: external advisor onboarding (kill-criterion §3.4 Week 1-2 must-fill) — legal/DPO review of retention posture
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
docs/verticals/recruitment/vertical-schema.yaml:14:#       + Day-5 v1.0-kill-criterion.md (Trigger 1 acquisition-by-2026-06-03)
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:53:      - Janitor (R+W — sweep + normalisation + dedup-merge proposals per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:150:      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:226:      - Janitor (R+W — orphan-link sweep + normalisation per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:261:        source: IFOS-derived (Janitor maintains)
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:347:      - Janitor (R — status drift sweep per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:397:      required_skills:
docs/verticals/recruitment/vertical-schema.yaml:401:        source: IFOS-derived (extracted from JD; v0.1 free strings; v1.1+ canonicalised skill taxonomy)
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:426:      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).
docs/verticals/recruitment/vertical-schema.yaml:434:      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
docs/verticals/recruitment/vertical-schema.yaml:592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
docs/verticals/recruitment/vertical-schema.yaml:682:  Janitor:
docs/verticals/recruitment/vertical-schema.yaml:736:# Verifies against real Bullhorn data at Week 3-4 Janitor build per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:745:    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:757:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:763:    field_mapping_density: v0.1 covers 10 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. v1.1 Triage expands contact-side coverage.
docs/verticals/recruitment/vertical-schema.yaml:768:    field_mapping_density: v0.1 covers 17 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. Note Bullhorn customText1-25 fields are tenant-specific and require per-tenant adapter mapping not standard schema work.
docs/verticals/recruitment/vertical-schema.yaml:769:    notes: Skills extraction (required_skills, nice_to_have_skills arrays) is IFOS-derived from JD body, not Bullhorn-sourced (Bullhorn does not consistently structure skill fields across tenants).
docs/verticals/recruitment/vertical-schema.yaml:774:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
docs/verticals/recruitment/vertical-schema.yaml:805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
docs/verticals/recruitment/vertical-schema.yaml:811:    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
docs/verticals/recruitment/vertical-schema.yaml:837:  Q8_skill_taxonomy:
docs/verticals/recruitment/vertical-schema.yaml:840:    v0_1_decision: brief.required_skills + brief.nice_to_have_skills are free-string arrays in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:841:    revisit_trigger: Skill-matching accuracy from Sourcing Scout's first 4 tenant-weeks of operation; if free-text matching produces <60% precision, canonical skill taxonomy lands as v1.1.
docs/verticals/recruitment/vertical-schema.yaml:842:    rationale: Skill canonicalisation is well-trodden ground (ESCO taxonomy, O*NET, LinkedIn Skills API) but pulling a taxonomy in v0.1 is over-engineering for the first 3 pilots.
docs/verticals/recruitment/vertical-schema.yaml:890:    expected_date: post Week 3-4 (after Janitor build verifies against real Bullhorn data)
docs/verticals/recruitment/vertical-schema.yaml:892:      Codex-ratified version. Field sets expanded per Janitor's real-Bullhorn-data findings (Q3 trigger). Possibly Note entity promoted to entity_type if Janitor surfaces query patterns (Q2 trigger). 2-3 revisions expected from v0.1.
docs/verticals/recruitment/vertical-schema.yaml:893:    target: Week-4-end (~2026-06-21 if Week 1 starts 2026-05-21 per Day-5 kill criterion §2 Trigger 1 calendar).
docs/verticals/recruitment/vertical-schema.yaml:898:      Triage expansion (Q5 contact decision-authority granularity, Q10 panel hiring). Skill taxonomy decision (Q8). Multi-client contact decision (Q9). Umbrella company entity promotion candidate (Q7). Opportunity entity exercise begins.
agents/_shared/escalation-codes.md:128:- **Severity:** warn — Janitor dedup needs human approval
agents/_shared/escalation-codes.md:129:- **Trigger:** Dedup confidence `≥ 0.85` per Ultraplan §8.1 line 511 A2 Gate A; human-review-required cases
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:370:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:374:- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
agents/_shared/escalation-codes.md:378:- **Note:** Local Gate B is a leading metric for agent quality; consecutive misses inform per-agent quality review. Not tied to a kill-criterion trigger in v1.0 (per disagreement-doc Cat-3 disposition).
agents/_shared/escalation-codes.md:390:- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
agents/_shared/escalation-codes.md:439:- **Severity:** warn — Janitor cannot determine placement state for cleanup
agents/_shared/escalation-codes.md:440:- **Trigger:** Placement record has ambiguous lifecycle markers (e.g. start_date present but no end_date AND no `active` flag AND no recent activity); Janitor cannot safely tag or update
agents/_shared/escalation-codes.md:454:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
docs/RISK-REGISTER.md:3:Updated weekly. Honest naming. No hedging. The four that could kill v1.0 are at
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:55:- 2026-05-22 (Day 11) — **Codex Round 2 autonomous ratification complete.** 26 artefacts reviewed; 17 RATIFIED / 9 REJECTED. Manifest §1.7 appended and full outputs written to `logs/codex-ratification/round-2-autonomous/`. D5 skill softening ratified. Bullhorn gate disagreement rejected because the promised source-doc sharpening did not land. Autosend policy, v0.2 supplement, approval bridge, PII purge runbook/script/forward migration, and tenancy audit script remain rejected. **New Risk #11** added for transactionless `SET LOCAL` usage across live DB scripts/helpers. **New Risk #12** added for the PII purge migration/script mismatch with `recent_edit.original_text NOT NULL`.
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:3:**How to leverage Claude Code's features specifically for the Intel Force on cortextOS build. Skills, sub-agents, MCP servers, scheduled agents, project memory, slash commands. Each item below is concrete: when to use it, how to configure it, why it pays off for *this* build.**
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:15:## 1. Skills — the brain swap leverages two existing ones
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:17:### 1.1 `graphify` skill
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:19:Already installed at `~/.claude/skills/graphify/SKILL.md`. Description: "any input (code, docs, papers, images) → knowledge graph → clustered communities → HTML + JSON + audit report". Trigger: `/graphify`.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:21:**For this build:** `packages/brain/src/graphify.ts` is the heart of the brain swap. Rather than designing the entity+relationship extraction pipeline from scratch, **read the graphify skill's implementation first**. It already encodes:
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:27:The skill is a working reference for what to implement in `packages/brain/src/`. Even better, the wiki-brain skill (next item) is *built on top of* graphify — it's the proof that this approach works for a personal knowledge base.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:29:**During Phase 1 §P1.S3 (ingest pipeline):** open `~/.claude/skills/graphify/SKILL.md` first, then implement. Don't reinvent. Adapt.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:31:### 1.2 `wiki-brain` skill
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:33:Installed at `~/.claude/skills/wiki-brain/SKILL.md`. Description: "Turn Claude Code into a knowledge base that compounds. Every conversation ingests into a personal wiki you browse in Obsidian. Based on Andrej Karpathy's LLM Wiki pattern, powered by Graphify."
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:35:**For this build:** this is the *prior art* for what we're building. The wiki-brain skill turns Claude Code into a personal Obsidian-shaped knowledge base; we're turning cortextOS into a *tenant-shaped* Obsidian-shaped knowledge base for customers.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:37:**During Phase 1 §P1.S6 (wiki rendering):** read the wiki-brain skill's implementation. Adopt the markdown conventions, backlink computation, and folder structure. The customer-facing brain should look identical to wiki-brain visually because that's what the founder said "looks stunning" means.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:39:### 1.3 Other relevant skills already installed
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:41:| Skill | When useful in this build |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:51:### 1.4 New skills to create for this build
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:53:Put these in `~/.claude/skills/` (global) or `/Users/madsadmin/code/CortexOS/.claude/skills/` (project-local):
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:55:- **`cortextos-bus`** — the file-bus interface, all 47 scripts, when to override vs augment vs keep. Lives at `.claude/skills/cortextos-bus/SKILL.md`. Phase 0 deliverable.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:56:- **`brain-package`** — the wiki+graphify brain's architecture, ingest pipeline, query layer, vault layout. Lives at `.claude/skills/brain-package/SKILL.md`. Phase 1 deliverable.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:57:- **`v2-build-pack`** — pointer to `/Users/madsadmin/code/CortexOS/docs/build-pack/` and how to use it. Lives at `.claude/skills/v2-build-pack/SKILL.md`. Phase 0 deliverable.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:59:These give future sessions one-line invocations: `/skill cortextos-bus` and the right context loads.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:298:If you remember one thing from this file: **the wiki-brain skill at `~/.claude/skills/wiki-brain/SKILL.md` is the prior art for the entire Phase 1 brain swap.** Read it before Phase 1 §P1.S3 starts. It will save days of design.
docs/operations/codex-round-2-autonomous-prompt.md:39:  - The ratification skills to apply per artefact (§3 tables)
docs/operations/codex-round-2-autonomous-prompt.md:54:  2. .codex/ratification/SKILL.md  (top-level ratification skill)
docs/operations/codex-round-2-autonomous-prompt.md:78:  b) Apply top-level SKILL.md + the type-specific skill named in §3
docs/operations/codex-round-2-autonomous-prompt.md:93:correct. For doc #19 (D5 skill softening), evaluate the proposed skill 
docs/operations/codex-round-2-autonomous-prompt.md:119:  Columns: Tier | Path | Skill | Round-1 verdict | Round-2 verdict | 
docs/operations/codex-round-2-autonomous-prompt.md:125:  skill change.
docs/operations/codex-round-2-autonomous-prompt.md:197:    - D5 skill softening (item 19): <RATIFIED|REJECTED>
docs/operations/codex-round-2-autonomous-prompt.md:254:   D2 (external advisor), D3 (PII retention), D4 (Path B), D5 (skill 
docs/_archive-build-pack/01-RECOMMENDATION.md:52:    ├── skills/
docs/_archive-build-pack/01-RECOMMENDATION.md:87:├── skills/, community/, tests/, scripts/, hooks/
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:253:- **Consequences:** Janitor W5 build conditional on Bullhorn A+B Accepted. If A+B answer arrives after 2026-06-03, Janitor slips to W6+; if no answer by 2026-06-10, force Direct-API fallback per `bullhorn-integration-path.md` §1.4.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-option-c-diagnostic-end-to-end.md:255:- **Ratifies via:** review-architecture-decision.md Codex skill (next round).
docs/operations/goal-option-c-diagnostic-end-to-end.md:409:  - [Proceed to Week-4 polish OR wait on Bullhorn response before Janitor W5?]
docs/architecture/architecture-cohesion-review.md:34:| **Helpers + storage** | vault-concurrency.md (locks + version), v0.1 schema, v0.2 supplement, kill-criterion.md (Trigger 5 audit) |
docs/architecture/architecture-cohesion-review.md:89:| A2 | **`SET LOCAL` scopes the setting to the current transaction.** A connection pool with auto-commit could leak `app.current_tenant` across requests if `SET LOCAL` is wrong scope. | hook-helpers.sh `_hh_emit_row` issues `SET LOCAL` inside the same psql invocation as the INSERT — single transaction. | If connection pool shares connections across requests, `SET LOCAL` rolls back at commit; `SET` (non-LOCAL) would persist and cause leak. Helpers correctly use LOCAL. |
docs/architecture/architecture-cohesion-review.md:95:| A8 | **Bullhorn OAuth refresh-loop fires before token expiry under load.** Per-agent 8-min cycle vs 10-min TTL. | bullhorn-integration-path.md §4.5 + common-ats.json `auth_refresh_interval_seconds` | If the 2-min buffer is insufficient under network latency or rate-limit backoff, agent loses Bullhorn auth mid-write. Untested at scale; flagged at first Janitor build. |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:152:| G6 | **vault-concurrency.md `entities.version` enforcement is one-directional.** The doc names optimistic-concurrency UPDATE pattern but the helpers don't yet implement it (hook-helpers.sh has no entity-update path; that lands when an agent needs to write to `entities`). | Low (Janitor W5 will be first writer) | First entity-write helper at Janitor build adds version-check pattern. New ADR if pattern surfaces decisions. |
docs/architecture/architecture-cohesion-review.md:188:  - **A:** Codex review skill `review-agent-bundle.md` (not yet built) would catch this. Currently relies on grep audit + author discipline. Recommend: add this check to `scripts/run-tenancy-audit.sh` (Phase 1 enhancement OR Codex skill).
docs/architecture/architecture-cohesion-review.md:190:**Verdict: BOUNDARY HOLDS at current artefact set.** Future agents need automated guardrail; queue as Phase-1 extension OR `review-agent-bundle.md` skill at Diagnostic W3.
docs/architecture/architecture-cohesion-review.md:215:  - **A:** R2 commitment (ADR-003 Decision 1): tools.yaml can opt-in to cortextOS skills via `cortextos_skills:` block. If an agent opts in to `knowledge-base`, it gets the upstream KB. **This is the seam.** Currently no agent opts in. Recommend: add `review-agent-bundle.md` skill check to flag any `knowledge-base` opt-in for explicit founder review.
docs/architecture/architecture-cohesion-review.md:234:| R8 | Adapter + brain-replacement boundary automation | Medium | `review-agent-bundle.md` Codex skill at Diagnostic W3 | Claude Code | Diagnostic W3 |
docs/architecture/architecture-cohesion-review.md:235:| R9 | A8: Bullhorn OAuth refresh timing under load | Low | First Janitor build stress test | Claude Code | Janitor W5 |
docs/architecture/architecture-cohesion-review.md:238:| R12 | G6: entities.version optimistic-concurrency helper | Low | First entity-write helper at Janitor build | Claude Code | Janitor W5 |
docs/architecture/architecture-cohesion-review.md:268:**Reference.** Codex Day-7 manifest queue item #36; ratifies via `review-architecture-decision.md` skill. Companion to `docs/architecture/tenancy-invariants.md`.
agents/recruitment/cash-conductor/agent.md:6:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:9:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
agents/recruitment/cash-conductor/agent.md:79:| 2 | Exact amount + matching payee name | 0.85 |
agents/recruitment/cash-conductor/agent.md:118:Position 4 is the kill-switch: Cash Conductor never auto-drafts beyond position 3. Operator decides next step manually.
agents/recruitment/cash-conductor/agent.md:267:- Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
agents/recruitment/cash-conductor/agent.md:283:This is THE FD-tier closer metric per master brief §8.2 line 597 — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:381:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
agents/recruitment/cash-conductor/agent.md:387:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/cash-conductor/agent.md:398:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
agents/recruitment/cash-conductor/agent.md:399:- Codex re-ratifies post-build via `review-agent-bundle.md` skill
docs/operations/codex-ratification-guide.md:40:The SKILL.md files give Codex the IFOS-specific idiom. That's the load-bearing part of the loop — without good skills, Codex is just a generic reviewer.
docs/operations/codex-ratification-guide.md:51:4. **The SKILL.md files prime Codex** — when you run a ratification, the wrapper builds a prompt that says: "Here is the IFOS top-level skill. Here is the type-specific skill. Here is the artefact. Apply both skills."
docs/operations/codex-ratification-guide.md:107:### Step 3.3 — Verify the skills are in place
docs/operations/codex-ratification-guide.md:122:Three more skills (`review-agent-bundle.md`, `review-mcp-connector.md`, `review-harness-bump.md`) are deferred per the execution plan §3 — they're lazy, built at first need.
docs/operations/codex-ratification-guide.md:138:### Step 4.1 — Pick the artefact + skill
docs/operations/codex-ratification-guide.md:140:ADR-001 is at `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md`. It's an architecture decision, so the skill type is `architecture-decision`.
docs/operations/codex-ratification-guide.md:151:2. **Prompt assembly** — concatenates the top-level skill, the type-specific skill, the artefact content, and the output-contract instructions into a single prompt at `logs/codex-ratification/<session-id>/<artefact-slug>.prompt.md`.
docs/operations/codex-ratification-guide.md:152:3. **Codex invocation** — `codex exec < prompt > output.md`. Codex reads the prompt, applies the skill, returns its verdict.
docs/operations/codex-ratification-guide.md:154:5. **Audit row write** — inserts a row into `decision_log` with `tenant_slug='ifos-meta'`, `agent_name='_codex_ratifier'`, `phase='output'`, `outcome=<RATIFIED|REJECTED>`, `payload` includes the artefact path, skill used, issue count, session ID, and the full Codex response text. Falls back to `logs/codex-ratification.jsonl` if no live DB.
docs/operations/codex-ratification-guide.md:159:── Reviewing docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md (round 1, skill=architecture-decision) ──
docs/operations/codex-ratification-guide.md:185:── Reviewing docs/decisions/some-artefact.md (round 1, skill=architecture-decision) ──
docs/operations/codex-ratification-guide.md:237:Reference designs (audits, design docs, runbooks). Same skill as cluster A.
docs/operations/codex-ratification-guide.md:247:Schema YAMLs. Uses `review-schema-change` skill — checks layering, agent matrix consistency, Bullhorn mapping alignment, open-question discipline.
docs/operations/codex-ratification-guide.md:340:**Skill:** <skill file>
docs/operations/codex-ratification-guide.md:385:  payload->>'skill_used' AS skill,
docs/operations/codex-ratification-guide.md:404:  "skill_used": "architecture-decision",
docs/operations/codex-ratification-guide.md:446:You've found a skill-file weakness. The SKILL.md isn't asking Codex to check the right thing. Update the relevant `review-*.md` file to add the missing check, then re-run.
docs/operations/codex-ratification-guide.md:452:Same artefact, same skill, different invocations → different verdicts. This is real model nondeterminism. Two strategies:
docs/operations/codex-ratification-guide.md:471:# kill the tunnel
docs/operations/codex-ratification-guide.md:489:4. Read the response. Adjust skill if needed.
docs/operations/codex-ratification-guide.md:548:bash scripts/run-codex-ratification.sh <skill-type> <path>
docs/operations/seedlegals-engagement-queries.md:11:Per kill-criterion §3.4: external advisor is Week 1-2 must-fill. Per Risk #3: design partner LOI is 11 days from today (2026-06-03 trigger).
docs/operations/seedlegals-engagement-queries.md:128:| **D2** — External advisor identification | SeedLegals templates + delivered LOI + DPA become the "external advisor input" per kill-criterion §3.4. Founder retains right to escalate to a specialist firm for higher-stakes contracts. |
docs/operations/seedlegals-engagement-queries.md:166:- D2 + D3 stay open in current-priorities.md (D2 explicitly flagged as kill-criterion §3.4 Week 1-2 must-fill)
docs/build-brief/00-MASTER-BRIEF.md:84:├── community/                # community skills + agent catalog mount point
docs/build-brief/00-MASTER-BRIEF.md:90:├── skills/                   # core skills (per-runtime)
docs/build-brief/00-MASTER-BRIEF.md:348:1. **Ingest (`kb-add`).** An agent (Scribe, Triage, Janitor, etc.) drops a raw artefact into `raw/{category}/`. Ingest writes the file with provenance frontmatter (`source: scribe-agent`, `ingested_at: ...`, `tenant_id: ...`).
docs/build-brief/00-MASTER-BRIEF.md:364:3. **Reflect.** A weekly cron runs the reflect skill — Claude reads sample pages, flags contradictions, stale claims (older than threshold), orphan pages (no inbound links), and missing concepts (mentioned across pages but no canonical page exists). Output goes to `outputs/reflect-{date}.md` and surfaces in the Brain UI as a "wiki health" panel.
docs/build-brief/00-MASTER-BRIEF.md:475:### Day 5 — Friday — Safety policy + kill criterion
docs/build-brief/00-MASTER-BRIEF.md:478:- [ ] `docs/decisions/v1.0-kill-criterion.md` — the explicit condition under which v1.0 stops shipping (e.g., "If after 3 pilots the average Gate B revenue uplift is <£20k/year per tenant, the wedge is dead and we pivot")
docs/build-brief/00-MASTER-BRIEF.md:562:**The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly.** The renderer (`packages/agent-renderer/`, per `docs/decisions/ADR-003-agent-bundle-renderer.md` and `docs/architecture/agent-bundle-renderer-design.md`) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant). The `cortextos-ifos add-agent` command is **NOT** the IFOS path — it inherits 24 cortextOS template skills the IFOS bundle does not want.
docs/build-brief/00-MASTER-BRIEF.md:591:### 8.2 The build order — v1.0 only
docs/build-brief/00-MASTER-BRIEF.md:596:| 2 | Janitor | 5 | Bullhorn MCP (R+W) | First demoable inside-ATS result; day-30 before/after closes deals |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:718:Install Codex CLI as part of the dev environment, not cortextOS. Drop the ratification skills under `.codex/ratification/`:
docs/build-brief/00-MASTER-BRIEF.md:730:Each skill has the same shape: takes a diff or file set, checks against the five rules + the relevant spec doc, returns either `RATIFIED` (with optional minor notes) or `REJECTED` (with concrete issues numbered).
docs/build-brief/00-MASTER-BRIEF.md:737:2. **You** run: `codex review --skill .codex/ratification/review-{type}.md --target {path-or-diff}`
docs/build-brief/00-MASTER-BRIEF.md:765:- Day 1: build the `.codex/ratification/*.md` skills (Claude does this; we don't ratify the ratification skills until Day 7)
docs/build-brief/00-MASTER-BRIEF.md:766:- Day 7: Codex reviews the seven Week 0 artefacts (primitive audit, Bullhorn path, Brain UI scope, infra checklist, safety policy, kill criterion, vertical schema v0.1) — first ratification run
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/build-brief/00-MASTER-BRIEF.md:829:| "Let me ship without the kill criterion documented..." | §6 Day 5 |
docs/build-brief/00-MASTER-BRIEF.md:837:## 12. The risk register — the four that could kill v1.0
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/build-brief/00-MASTER-BRIEF.md:906:goes through `codex review --skill .codex/ratification/review-{type}.md --target {path}` before
docs/build-brief/00-MASTER-BRIEF.md:972:- Mark the kill criterion as "soft" because "the pilot is going well"
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:22:7. **`docs/decisions/v1.0-kill-criterion.md`** §2 Triggers 1-10 (deadline awareness) + §3 (authority structure)
docs/operations/goal-week-3-polish-and-scaffold.md:33:After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Six v1.0 agents: [list with weeks]. ULTRAPLAN §8.1 agent line ranges: [A1 lines 495-505, A2 lines 507-514, ...]. Week-3 scope confirmed. Ready to begin Step 1."**
docs/operations/goal-week-3-polish-and-scaffold.md:46:4. **Diagnostic bundle ratified by Codex.** Round 4 ratification run against agent.md + 5 siblings + 3 fixtures via `review-architecture-decision.md` skill. Verdict: RATIFIED (or remediation-pass if needed).
docs/operations/goal-week-3-polish-and-scaffold.md:50:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:51:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:52:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:53:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:66:- §10 When this document ratifies + Codex skill reference
docs/operations/goal-week-3-polish-and-scaffold.md:93:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:101:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:111:| Building any new Codex ratification skill (e.g., `review-agent-bundle.md`) | Defer per execution-plan §3 lazy; agent.md ratification uses existing `review-architecture-decision.md` skill |
docs/operations/goal-week-3-polish-and-scaffold.md:210:   - **Cache:** include `cache_control: { type: "ephemeral" }` on the system prompt + context blocks per claude-api skill conventions.
docs/operations/goal-week-3-polish-and-scaffold.md:262:5. `packages/diagnostic-generator/` (the package as a whole; ratifies via `review-architecture-decision.md` skill)
docs/operations/goal-week-3-polish-and-scaffold.md:265:Each entry: title + status + Codex skill + ratification date placeholder.
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
docs/operations/goal-week-3-polish-and-scaffold.md:307:- **§5 Gate B:** ≥15% dedup improvement + ≥10% field-completeness improvement per ULTRAPLAN line 512.
docs/operations/goal-week-3-polish-and-scaffold.md:309:- **§7 Voice + tone:** N/A (Janitor doesn't produce customer-facing output; all writes are internal data).
docs/operations/goal-week-3-polish-and-scaffold.md:311:- **§9 Open questions:** 4-6 questions covering dedup-heuristic confidence threshold, field-completeness priority order, Bullhorn write batch size, day-30 report distribution path.
docs/operations/goal-week-3-polish-and-scaffold.md:312:- **§10 Ratification:** via `review-architecture-decision.md` Codex skill; ratifies as part of Round 4 if scaffolded by Day 20.
docs/operations/goal-week-3-polish-and-scaffold.md:322:Commit: `decision(pre-build): agents/recruitment/janitor/agent.md — output contract per ULTRAPLAN §8.1 A2`
docs/operations/goal-week-3-polish-and-scaffold.md:330:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:336:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:345:- **§8 Build prerequisites:** Bullhorn MCP connector (R+W) + Fathom/Fireflies MCP connector (founder commercial signup) + LLM extraction prompt + voice classifier microservice (W5+).
docs/operations/goal-week-3-polish-and-scaffold.md:358:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:359:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:365:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:371:- **§5 Gate B:** ≥95% invoice match accuracy (vs human spot-check) + ≥15% reduction in days-sales-outstanding (DSO) after 60 days operation.
docs/operations/goal-week-3-polish-and-scaffold.md:387:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:393:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:420:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **§1 Output contract:** monitors Bullhorn placement-state transitions (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → day-7-check-in → day-30-check-in → day-90-check-in); generates customer-facing communication drafts at each lifecycle event; orange-tier autosend per Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:488:| **Codex skill output captured** | Each ratification round writes per-artefact `.output.md` files | `ls logs/codex-ratification/round-4/` |
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:550:Each entry: artefact + status + Codex skill + ratification date placeholder.
docs/operations/goal-week-3-polish-and-scaffold.md:575:### Existing skills available
docs/operations/goal-week-3-polish-and-scaffold.md:588:1. **Every claim cites a master plan section.** No bare assertions. Every paragraph either cites the master brief / ULTRAPLAN / sequencing-target / kill-criterion / specific ADR, OR is explicitly stated as "scaffold inference; founder review required."
docs/operations/goal-week-3-polish-and-scaffold.md:589:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:616:  Janitor (W5):           <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:640:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:643:  ✓ v1.0-kill-criterion.md Trigger 2 — Diagnostic ratified ahead of
docs/operations/goal-week-3-polish-and-scaffold.md:655:    - Janitor build (depends on Bullhorn R+W)
docs/operations/goal-week-3-polish-and-scaffold.md:683:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:47:### Issue 3 (RE-RAISE) — Gate B kill-criterion Trigger reference
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:49:**Codex says:** "Line 169 claims Diagnostic's 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:53:**Founder decision needed:** Diagnostic's Gate B metric doesn't map cleanly to ANY existing kill-criterion trigger.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:55:Option A — **Remove kill-criterion reference entirely.** Just describe Gate B as a local leading metric for Diagnostic; not part of any kill-criterion trigger. Honest.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:57:Option B — **Add a new kill-criterion Trigger 11 (DIAGNOSTIC-CONVERSION-FAIL).** Threshold: <30% discovery-call rate sustained for 4 weeks across all live pilots. Owner: founder + Jack.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:79:**Disposition:** **Codex is correct about the skill requirement**, but the artefact type is wrong. `agent.md` files are NOT architecture-decision documents — they're agent specifications per ADR-003 v2 bundle pattern (6 files + 3 fixtures). They don't fit the Context/Decision/Consequences shape.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:81:**Recommendation:** **Build `review-agent-bundle.md` Codex skill** (deferred per execution-plan §3 lazy; now needed). The Round-4 manifest used `review-architecture-decision.md` as a temporary skill because `review-agent-bundle.md` doesn't exist yet. The correct ratification path for agent.md files is the agent-bundle skill, not architecture-decision.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:83:**This is the load-bearing finding** — it surfaces that **the lazy-skill deferral is now blocking proper agent.md ratification.** Building `review-agent-bundle.md` is a Week-3-extension or W4 priority.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:92:4. **Authorise Week-3-extension OR W4-priority work** to build `review-agent-bundle.md` Codex skill (Issue 5)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:102:- Phase 2 full (5 new scaffolds): **deferred** pending Issue-5 resolution (review-agent-bundle.md skill build)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:106:Recommended next step (post-arbitration): Week-3-extension or W4-prio-1 build of `review-agent-bundle.md` skill; then re-run Codex Round 4 against all 6 v1.0 agent.md files with the proper skill.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:110:## Round-4-v2 results (post-skill-build, Day-19 13:25 UTC)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:112:After building `.codex/ratification/review-agent-bundle.md` (commit `825ebd4`) — the correct skill for agent.md ratification — all 6 agent.md files were re-ratified.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:119:| Janitor | ~5-7 (count regex inflated; 56 numbered items including nested) | `logs/codex-ratification/20260524T102050Z-21293/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:155:## Janitor Round-5 (remediation) — empirical confirmation of bilateral pattern
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:157:After all 6 Round-4-v2 issues remediated on Janitor (commit `2392af8`), Round-5 ratification returned REJECTED with **5 NEW findings** — none of the original 6 reappeared. New issues at Janitor session `20260524T103757Z-37420`:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:160:2. **`bullhorn_field_backfill` unregistered, would fail-safe to red:** my flag-for-addition framing didn't satisfy because `hook-helpers.sh::autosend_policy_lookup` fails to red on unknown action types AT RUNTIME, regardless of flag prose. Real bug requires either (a) policy row added BEFORE ratification, OR (b) explicit "blocked W5 prerequisite" framing not "executable output."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:161:3. **§5 vs §6 ESC code contradiction:** §5 prose retains `ESC_SCHEMA_VIOLATION` reference even though §6 explicitly says Janitor doesn't use it. Mechanical fix missed by my Round-4-v2 remediation.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:184:## Janitor Round 6 (exceeds hard ceiling) — 4 more NEW findings, all different from Rounds 4-5
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:188:1. Gate B composite score (≥12.5) weakens dual ULTRAPLAN thresholds (15% dedup AND 10% field-completeness independently)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:191:4. `ESC_DUPLICATE_DETECTED` semantics — catalogue defines it for ≥0.85 human-review-required, not <0.85 reject
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:195:| Round | Skill | Issues found | Unique issues so far |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:210:## Janitor Round 7 — 23+ unique issues; pattern definitively closed
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:212:After all 4 Round-6 issues remediated on Janitor (commit `1939d9b`), Round 7 returned REJECTED with **4 more new findings**, none from Rounds 4-6:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:223:| Round 4 v1 | 4 | 4 | Wrong skill |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:224:| Round 4 v2 | 6 | 10 | Right skill |
docs/operations/codex-round-2-handoff.md:16:Round 1 ran against the pre-remediation artefact set and rejected 14 of 16. Round 2 runs against the **post-remediation** artefact set + new artefacts that landed in commits `2b287d3` (Codex Round-1 remediation) + `5c3fa66`+`c4348aa`+`e1ff40f` (architecture+tenancy) + `783c496` (D5 skill softening) + `20e78d7`+`95e7d4a` (D1 + D3 preparation).
docs/operations/codex-round-2-handoff.md:21:2. **Skill softened (D5)** — `review-architecture-decision.md` §1 now exempts Reference + In Force from Decision/Consequences requirements. 2 artefacts that REJECTED on this in Round 1 (`cortexos-primitive-status.md` audit + `operational-hygiene-protocol.md` runbook) should RATIFY in Round 2.
docs/operations/codex-round-2-handoff.md:44:# Step 3: skills present + softening landed (D5)
docs/operations/codex-round-2-handoff.md:82:| 11 | `docs/decisions/v1.0-kill-criterion.md` | Trigger 1 date + Trigger 2 CLI + Trigger 4 threshold | RATIFY (all three fixed) |
docs/operations/codex-round-2-handoff.md:93:| # | Path | Skill | Expectation |
docs/operations/codex-round-2-handoff.md:102:| # | Path | Skill | Special handling |
docs/operations/codex-round-2-handoff.md:104:| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | `review-architecture-decision` | **Recursive ratification per master brief §10.5.** Codex either RATIFIES the disagreement (D5 was correct) OR REJECTS (insists on strict skill). Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:170:- Skill softening D5 landed in commit 783c496 — Reference + In Force status artefacts
docs/operations/codex-round-2-handoff.md:184:Use the type-specific skill named in the table below per artefact. Read the
docs/operations/codex-round-2-handoff.md:185:artefact + apply both skills + decide.
docs/operations/codex-round-2-handoff.md:202:doc proposes a skill change (D5), evaluate the proposed change itself, not
docs/operations/codex-round-2-handoff.md:205:TIER 1 — RE-RATIFY 14 ROUND-1 REJECTED (skill: review-architecture-decision):
docs/operations/codex-round-2-handoff.md:216:  docs/decisions/v1.0-kill-criterion.md
docs/operations/codex-round-2-handoff.md:218:  docs/verticals/recruitment/vertical-schema.yaml  (skill: review-schema-change)
docs/operations/codex-round-2-handoff.md:219:  docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml  (skill: review-schema-change)
docs/operations/codex-round-2-handoff.md:221:TIER 2 — DAY-9 NEW ARTEFACTS (skill: review-architecture-decision):
docs/operations/codex-round-2-handoff.md:253:disagrees with the proposed skill change.
docs/operations/codex-round-2-handoff.md:307:Best case: Codex agrees with Claude's counter-argument. Founder Decision stands as Claude proposed. For D5 disagreement doc → Codex confirms skill softening was correct. Close.
docs/operations/codex-round-2-handoff.md:311:Codex insists Round-1 rejection was correct OR insists the proposed skill change is wrong. **Founder escalation required.** Founder picks:
docs/operations/codex-round-2-handoff.md:312:- Accept Codex (revert skill softening; retrofit ceremony onto audit/runbook artefacts)
docs/operations/codex-round-2-handoff.md:313:- Accept Claude (skill softening stands; mark disagreement doc as "founder-overrode-Codex" and document)
docs/operations/codex-round-2-handoff.md:381:**Total floor: ~6h 50m.** Realistic with 10-15% rejection-handling overhead: **~8h.** Spread across 2 sessions if needed.
docs/architecture/agent-bundle-renderer-design.md:54:- **§1.1-A:** master brief §8.1 names `validate.sh` and `context.sh` at the bundle root but does not specify the **invocation mechanism** — i.e. how does the agent invoke them from within its Claude Code session? Claude Code's hooks convention is `.claude/hooks/*.sh`; cortextOS templates don't use that path (they use `.claude/skills/` for skill scripts but not `.claude/hooks/` for lifecycle hooks). Recommended resolution in §2.1: render the two scripts to `.claude/hooks/` so they integrate with Claude Code's hook discovery; CLAUDE.md preamble (synthesised from agent.md per §2.1) references them by name.
docs/architecture/agent-bundle-renderer-design.md:81:| `.claude/skills/` | Optional — cortextOS templates ship 24 skills here (per `docs/architecture/second-brain-design.md` §1.7) | Claude Code's skill discovery at session start | Daemon-agnostic |
docs/architecture/agent-bundle-renderer-design.md:117:| _(no IFOS source)_ | `orgs/<org>/agents/<name>/goals.json` | **Synthesis (empty placeholder)** | None | Materialised as `{ "focus": "", "goals": [], "bottleneck": "", "updated_at": "", "updated_by": "" }` per `add-agent.ts:131-140`. Rationale: cortextOS's analyst / orchestrator workflows may read this file via their own bootstrap; absent it, some cortextOS skills throw. Cost of creating it is zero. Per Q1.5 / §2.2 below, IFOS agents do NOT invoke those skills, so the file is dead weight — but harmless dead weight that maintains daemon-side compatibility |
docs/architecture/agent-bundle-renderer-design.md:119:| _(no IFOS source — cortextOS templates ship 24 skills)_ | `.claude/skills/{activity-channel, agent-browser, ..., worker-agents}` (24 dirs) | **Drop** | n/a | n/a — the R2 commitment per design §1.7 + ADR-002 Decision 1. Detailed itemisation in §2.2 below |
docs/architecture/agent-bundle-renderer-design.md:129:**The renderer does NOT copy `packages/harness/cortextos/templates/agent/.claude/skills/`.** None of the 24 cortextOS-template skills land in the IFOS agent's rendered directory.
docs/architecture/agent-bundle-renderer-design.md:133:- **ADR-002 Decision 1** — cortextOS KB stays untouched; IFOS agents don't call `kb-*`. Inheriting `knowledge-base` and `memory` skills would mean IFOS agents have on-disk documentation telling them to invoke commands that, per ADR-002, they must not invoke.
docs/architecture/agent-bundle-renderer-design.md:134:- **Master brief §1 Rule 3 (Reuse before build)** — "Every agent uses `agents/_shared/` modules… No agent writes its own logging, voice handling, or approval gate." `_shared/` is the IFOS reuse surface. Inheriting a parallel reuse surface (cortextOS's `.claude/skills/`) creates two reuse vocabularies — confusing and error-prone.
docs/architecture/agent-bundle-renderer-design.md:135:- **Master brief §3.1 (submodule boundary stays intact)** — the §3.1 exception for the four `bus/kb-*.sh` shadow points is already a dead clause per ADR-002. Inheriting cortextOS skills would introduce a new implicit "shadow" — IFOS agents would carry skill documentation that points back into cortextOS's surface — undoing the cleanliness ADR-002 established.
docs/architecture/agent-bundle-renderer-design.md:137:**Per-skill inheritance gap — the five highest-stakes:**
docs/architecture/agent-bundle-renderer-design.md:139:| cortextOS skill | What it does in cortextOS | IFOS equivalent |
docs/architecture/agent-bundle-renderer-design.md:143:| `approvals` | cortextOS's per-action approval-gate skill — agent creates an approval entry, blocks until human resolves via Telegram inline buttons | IFOS uses the same primitive 4 approval gates (cortextOS primitive — `src/bus/approval.ts`), but the approval *categories* and *escalation routing* are declared in `tools.yaml` + `agent.md` per master brief §3.2, not via inherited skill documentation |
docs/architecture/agent-bundle-renderer-design.md:145:| `heartbeat` | cortextOS heartbeat cadence — periodic `update-heartbeat` writes to `${ctxRoot}/heartbeats/{name}.json` so the dashboard sees "alive" status | IFOS agents emit heartbeats too (the daemon's fast-checker writes them per `agent-process.ts:597-639` session timer), but the *cadence* and *what the agent does at each heartbeat* is specced per-agent in `agent.md` (Concierge always-on; Janitor cron-driven; etc.). The cortextOS-template `heartbeat/SKILL.md` is a default playbook — IFOS replaces with per-agent specifics |
docs/architecture/agent-bundle-renderer-design.md:147:**The remaining 19 cortextOS skills also not inherited by default:**
docs/architecture/agent-bundle-renderer-design.md:149:`activity-channel`, `agent-browser`, `agent-management`, `auto-skill`, `autoresearch`, `bus-reference`, `comms`, `cron-management`, `env-management`, `event-logging`, `guardrails-reference`, `human-tasks`, `m2c1-worker`, `onboarding`, `soul-philosophy`, `system-diagnostics`, `tool-registration`, `worker-agents` — 18 above, plus the `memory-management` skill referenced from `agent/.claude/skills/onboarding/SKILL.md:42` that I haven't catalogued individually.
docs/architecture/agent-bundle-renderer-design.md:151:The blanket position: **per-skill opt-in is deferred to per-agent bundle authoring.** Each IFOS bundle's `tools.yaml` may reference cortextOS-template skills it wants to inherit explicitly; the renderer reads the opt-in list, materialises only those skills into `.claude/skills/<name>/` in the rendered output, and copies the source `SKILL.md` from `packages/harness/cortextos/templates/agent/.claude/skills/<name>/`. **Default is exclusion. Opt-in is the only mechanism.** This is the structural opposite of `cortextos-ifos add-agent`, which default-includes all 24.
docs/architecture/agent-bundle-renderer-design.md:153:**Spec gap §2.2-A:** master brief §8.1 doesn't specify the opt-in syntax in `tools.yaml`. Recommended resolution: add a top-level `cortextos_skills:` block in `tools.yaml` with a list of skill names. Example:
docs/architecture/agent-bundle-renderer-design.md:156:cortextos_skills:
docs/architecture/agent-bundle-renderer-design.md:161:Renderer reads this; copies named skills only; emits a Codex-ratifiable diff for each opt-in (since each one is a §3.1 boundary-near decision).
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:295:cortextos_skills: []
docs/architecture/agent-bundle-renderer-design.md:298:Note: `wiki-*` bus operations are NOT declared in `tools.yaml` per ADR-002 Decision 2 — they're internal bus commands. `cortextos_skills:` is empty per the R2 default (§2.2).
docs/architecture/agent-bundle-renderer-design.md:691:**Detection:** Renderer killed by SIGKILL (OOM, manual `kill -9`, container terminate) between writing the `.tmp.<pid>/` and the atomic rename. The `.tmp.<pid>/` directory is left orphaned.
docs/architecture/agent-bundle-renderer-design.md:725:2. Copies the entire `templates/agent/` tree, including all 24 `.claude/skills/` (per `copyTemplateFiles` at line 382-402).
docs/architecture/agent-bundle-renderer-design.md:729:6. The agent runs as a **cortextOS-template agent**, NOT as IFOS Concierge. It has `MEMORY.md`, `IDENTITY.md`, `knowledge-base` skill, etc. — none of which IFOS expects.
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/agent-bundle-renderer-design.md:818:- **§2.2-A** (`cortextos_skills:` opt-in syntax in tools.yaml) — resolved in §2.2 with YAML block example.
agents/recruitment/scribe/agent.md:6:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:39:Each provider has its own webhook signature scheme (Fathom HMAC-SHA256; Fireflies bearer token; Ringover OAuth-protected). Auth handled per-provider in `tools.yaml` capability declarations.
agents/recruitment/scribe/agent.md:74:| Candidate | `location`, `current_role_title`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (perm/contract/hybrid), `key_skills` (list) |
agents/recruitment/scribe/agent.md:236:Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
agents/recruitment/scribe/agent.md:291:| Janitor ratified (Bullhorn auth substrate via W5 build) | W5 Codex Round | ⏸ |
agents/recruitment/scribe/agent.md:294:| Bullhorn MCP write capability | W3-W4-W5 build chain | ⏸ |
agents/recruitment/scribe/agent.md:337:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/scribe/agent.md:348:- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:9:# Per kill-criterion §2 Trigger 5 + agent.md §6: voice drift is an
docs/operations/codex-round-2-remediation-prompt.md:204:      to Accepted before Janitor (W5) build starts per
docs/operations/codex-round-2-remediation-prompt.md:205:      `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/operations/codex-round-2-remediation-prompt.md:206:      A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate.
docs/operations/codex-round-2-remediation-prompt.md:219:  | Janitor W5 build | A+B Accepted (commercial conversations complete) | Pending |
docs/operations/codex-round-2-remediation-prompt.md:386:appropriate skill:
docs/operations/codex-round-2-remediation-prompt.md:634:**Round 3 ratification:** 10 corrected items re-ratified against appropriate skills. Hard-ceiling enforced per master brief §10.3 step 5.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:43:- `docs/decisions/v1.0-kill-criterion.md` §3.4 ("Week 1-2 must-fill")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:49:**Real issue:** v1.0 kill-criterion §3.4 names "external advisor" as a Week 1-2 must-fill. This is also the resolution path for autosend §10 pilot-agreement liability. Today = 2026-05-20 (Day 8 = Week 1 underway). No advisor identified.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:54:- **D2-C: Use boilerplate UK SaaS LOI template** (off-the-shelf) without lawyer engagement. Cheap but high risk for kill-criterion §3.4 explicit external-advisor requirement.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:58:**Cost of delay:** Trigger 1 fires 2026-06-03 if no LOI. If LOI lands but advisor isn't engaged, founder has to choose between violating kill-criterion §3.4 or delaying LOI past Trigger 1. Engage now to avoid the forced choice.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:106:## D5 — Decision-doc shape skill softening for Reference + In Force artefacts
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:110:**Real issue:** Codex Round 1 REJECTED `cortexos-primitive-status.md` (audit) and `operational-hygiene-protocol.md` (runbook) for lacking Decision + Consequences sections. The skill `.codex/ratification/review-architecture-decision.md` §1 requires these sections for all artefacts under this skill. But the skill ALSO allows Status=Reference and Status=In Force, which are legitimately non-decision artefacts. Contradiction in the skill itself.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:113:- **D5-A: Soften the skill** — exempt Status=Reference + Status=In Force from the Decision/Consequences requirement. Re-run Round 2; both artefacts expected to RATIFY without further changes. **Recommended.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:117:**Claude's recommendation:** D5-A. The skill should reflect what the artefact types actually are; audits + runbooks legitimately don't have decisions.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:121:If D5-A or D5-C: skill update is a separate small commit. Re-ratification runs from same `bash scripts/run-codex-ratification.sh --cluster B` command.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:125:Founder accepted **D5-A**. Skill softening landed in `.codex/ratification/review-architecture-decision.md §1` plus new §1-Exemption clause. Reference + In Force status artefacts now exempt from Decision + Alternatives + Consequences requirements (Context + Status line still required for ALL).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:130:- `architecture-cohesion-review.md` (Day-9; not yet ratified) → ratifiable under softened skill
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:131:- `tenant-lifecycle.md` (Day-9; not yet ratified) → ratifiable under softened skill
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:141:| **D5** (skill softening) | This week | Round 2 ratification of 2 artefacts |
agents/recruitment/janitor/README.md:1:# Janitor — directory README
agents/recruitment/janitor/README.md:3:**Status:** Proposed (Day-16 pre-W5-build scaffold; awaits Bullhorn A+B + Q1 LOI + W5 build slice).
agents/recruitment/janitor/README.md:14:Full agent bundle per ADR-003: 6 files + 3 fixtures. Built at W5 start (~2 weeks per ULTRAPLAN A2 line 512):
agents/recruitment/janitor/README.md:18:- `validate.sh` — Gate A (dedup confidence ≥0.85 + activity-window 90d + field-source confidence ≥0.7 + voice ≥0.75 + PII boundary + Bullhorn batch ≤100/min)
agents/recruitment/janitor/README.md:21:- `fixtures/01-primary-1000-candidates.yaml` — Golden case: clean tenant, ~15% expected dedup
agents/recruitment/janitor/README.md:23:- `fixtures/99-merge-confidence-canary.yaml` — Adversarial: confidence just below 0.85 — Gate A must reject
agents/recruitment/janitor/README.md:27:Janitor W5 build slice gated on:
agents/recruitment/janitor/README.md:34:Per `.codex/ratification/review-architecture-decision.md` skill. Queued for Codex Round 4 Phase 2 (Day 20).
agents/recruitment/janitor/README.md:36:*End of Janitor README.*
docs/architecture/cortexos-kb-surface-investigation.md:106:   - Q1: What does cortextOS itself depend on its KB for? (Analyst theta-wave skill, autoresearch, etc. — read template skills.)
docs/operations/codex-ratification-execution-plan.md:62:## §3 — Precondition 1: build the 7 `.codex/ratification/*.md` skills
docs/operations/codex-ratification-execution-plan.md:64:Master brief §10.2 lists 7 skill files. None exist yet (Day-7 manifest §3 gap). Build them before first ratification run.
docs/operations/codex-ratification-execution-plan.md:73:| `review-mcp-connector.md` | New MCP connector checklist | ~200 | Pre-Janitor-W5 (not yet needed) |
docs/operations/codex-ratification-execution-plan.md:78:### Skill shape (per master brief §10.2 last paragraph)
docs/operations/codex-ratification-execution-plan.md:80:Each skill takes a diff or file set, checks against the five rules + the relevant spec doc, returns either:
docs/operations/codex-ratification-execution-plan.md:85:**Template structure for each skill file:**
docs/operations/codex-ratification-execution-plan.md:88:# Codex ratification skill — review-{type}
docs/operations/codex-ratification-execution-plan.md:90:## What this skill checks
docs/operations/codex-ratification-execution-plan.md:91:[1-2 paragraphs: scope of artefacts this skill applies to]
docs/operations/codex-ratification-execution-plan.md:117:Per `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1 + the Day-8 additions in `.agents/current-priorities.md`. 34 items total, clustered by skill-type for efficient batching (run each skill against its batch before context-switching).
docs/operations/codex-ratification-execution-plan.md:121:| # | Artefact | Path | Skill |
docs/operations/codex-ratification-execution-plan.md:134:| # | Artefact | Path | Skill |
docs/operations/codex-ratification-execution-plan.md:140:| 13 | v1.0-kill-criterion | `docs/decisions/v1.0-kill-criterion.md` | A |
docs/operations/codex-ratification-execution-plan.md:145:| # | Artefact | Path | Skill |
docs/operations/codex-ratification-execution-plan.md:152:| # | Artefact | Path | Skill |
docs/operations/codex-ratification-execution-plan.md:158:### Cluster E — Runtime code + helpers (6 items — review against ADR shape, mostly via `review-architecture-decision.md` + skill-specific checklist)
docs/operations/codex-ratification-execution-plan.md:160:| # | Artefact | Path | Skill |
docs/operations/codex-ratification-execution-plan.md:173:| # | Artefact | Path | Skill |
docs/operations/codex-ratification-execution-plan.md:180:| # | Artefact | Path | Skill |
docs/operations/codex-ratification-execution-plan.md:188:| # | Artefact | Path | Skill |
docs/operations/codex-ratification-execution-plan.md:194:| # | Artefact | Path | Skill |
docs/operations/codex-ratification-execution-plan.md:236:  --skill .codex/ratification/review-{type}.md \
docs/operations/codex-ratification-execution-plan.md:245:### 6.2 — Cluster batch invocation (multiple artefacts, same skill)
docs/operations/codex-ratification-execution-plan.md:251:    --skill .codex/ratification/review-architecture-decision.md \
docs/operations/codex-ratification-execution-plan.md:271:    'skill_used', $2,
docs/operations/codex-ratification-execution-plan.md:297:**Skill:** <skill file>
docs/operations/codex-ratification-execution-plan.md:348:Per Day-7 manifest §4 + §6 of this plan: Codex ratification execution was deferred pending Week 0 close. Week 0 closes when single-sentence-test Q1 = YES (design partner LOI signed). **Current state:** Q1 = NO; Week 0 EXTENDING; kill-criterion Trigger 1 fires 2026-06-03.
docs/operations/codex-ratification-execution-plan.md:352:- **Option α** — Start immediately. Rationale: 33 items are already queued; Q1 turning YES will only ADD items (Diagnostic + Janitor + downstream). The 34-item queue is largely about Week 0 design artefacts that won't change post-LOI. Get them ratified now while context is fresh.
docs/operations/codex-ratification-execution-plan.md:362:| 1 | Build 4 skill files (SKILL.md + architecture-decision + schema-change + postgres-migration) | After codex CLI reinstall (Precondition 0) |
docs/operations/codex-ratification-execution-plan.md:371:| 10 | Build remaining 3 skills (agent-bundle + mcp-connector + harness-bump) | Lazy — at first invocation need |
docs/operations/codex-ratification-execution-plan.md:426:- **Custom Codex prompting beyond the SKILL.md** — the skill IS the prompt. If a skill needs tightening based on first-run feedback, update the skill + re-ratify the affected artefacts.
docs/operations/codex-ratification-execution-plan.md:429:- **Codex review of `agents/_shared/` runtime code via agent-bundle skill** — the 8-file `_shared/` set is reviewed under `review-architecture-decision.md` because it's not an agent bundle, it's the helper layer. Future agents (Diagnostic W3+) will be reviewed under `review-agent-bundle.md` once that skill exists.
docs/operations/codex-ratification-execution-plan.md:442:6. **This plan updated** — actual cost vs estimate; cadence retro; skill-file iterations.
docs/_archive-build-pack/README.md:77:| `09-CLAUDE-CODE-UTILITY.md` | How to maximise Claude Code for this build: skills, sub-agents, MCP, scheduled agents, project memory, slash commands. |
agents/recruitment/diagnostic/tools.yaml:5:# Ratifies as part of full bundle via review-agent-bundle.md skill.
agents/recruitment/diagnostic/README.md:38:Per `.codex/ratification/review-agent-bundle.md` (skill not yet built; lazy per execution-plan §3): this directory ratifies as a unit when the full 6-file + 3-fixture bundle exists.
agents/recruitment/diagnostic/README.md:40:Until then, individual files (this README + agent.md) ratify via `review-architecture-decision.md` skill on their own ratification queue position.
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:61:| 4 | **Approval gates with standing authorisations** | Telegram approval surface working; standing-auth config schema defined | If not ready, every auto-send becomes draft-only for v1.0. Hurts the Triage pitch but doesn't kill it. |
docs/specs/ULTRAPLAN.md:184:- `ESC_DUPLICATE_DETECTED` — Janitor found a high-confidence dedup candidate requiring human review
docs/specs/ULTRAPLAN.md:239:- Scheduled agents (Janitor, Reporting, Spec Pitcher) run as cron jobs *also* under the tenant's OS user.
docs/specs/ULTRAPLAN.md:423:| Janitor | 30-day before/after report shows ≥15% dedup, ≥10% field-completeness improvement | The day-30 report IS the Gate B measurement |
docs/specs/ULTRAPLAN.md:501:#### A2. The Janitor — the wedge agent
docs/specs/ULTRAPLAN.md:503:- **Build wave:** v1.0 (week 5–6)
docs/specs/ULTRAPLAN.md:510:- **Gate A:** dedup confidence score ≥ 0.85 on every merge proposal; no merge proposed where candidate has had activity in last 90 days without explicit review flag
docs/specs/ULTRAPLAN.md:511:- **Gate B target:** day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement
docs/specs/ULTRAPLAN.md:571:### 8.2 v1.1 agents (seven, in build order)
docs/specs/ULTRAPLAN.md:585:- **Gotchas:** This is the most dangerous auto-send agent. Auto-send categories must be gated tightly (acknowledge-new-candidate only at v1.1 launch, expand after 30 days of clean data). Misclassification of a complaint as a routine inbound is a relationship killer. The deliverability test for AgentMail vs Microsoft Graph is the rate-limiting research.
docs/specs/ULTRAPLAN.md:681:### 8.5 The complete tools-and-skills matrix
docs/specs/ULTRAPLAN.md:686:| Janitor | | ✓ | | | | ✓ | | | | | |
docs/specs/ULTRAPLAN.md:757:### Weeks 5–6 — Janitor + Scribe
docs/specs/ULTRAPLAN.md:759:- Week 5: Janitor agent; day-30 before/after report template; CI fixtures
docs/specs/ULTRAPLAN.md:762:Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.
docs/specs/ULTRAPLAN.md:799:4. Janitor's Workflow F (the day-30 before/after report) — can be manually compiled for the first tenant
docs/specs/ULTRAPLAN.md:818:| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/specs/ULTRAPLAN.md:824:| 8 | First pilot's Bullhorn data is too messy for Janitor's dedup confidence threshold | Medium | Medium | <5% dedup proposed in week 6 trial run | Lower threshold to 0.7 for the initial cleanup; ship the day-30 report regardless |
docs/specs/ULTRAPLAN.md:829:| 13 | The Bullhorn API rate limits prevent Janitor from completing its initial sweep on day 1 | Medium | Medium | First sweep takes >24 hours | Initial sweep runs in batches over 3 days; communicate to tenant explicitly |
docs/specs/ULTRAPLAN.md:832:Risks #1, #2, #3, #4 are the four that could kill v1.0. Everything below them is recoverable.
docs/specs/ULTRAPLAN.md:865:- [ ] v1.0 kill criterion documented (Q12). **Owner:** Maddox. **Output:** `v1-kill-criterion.md`.
docs/_archive-build-pack/05-MIGRATION-MAP.md:186:| `list-skills.sh` | KEEP | cortextOS-native |
docs/_archive-build-pack/05-MIGRATION-MAP.md:213:### 2.5 Skills + Community
docs/_archive-build-pack/05-MIGRATION-MAP.md:217:| `skills/` (claude-api-helper, comms, cron-management, mcp-integration, prompt-engineering, tasks, tool-use-patterns, web-research) | KEEP | These are cortextOS-native agent skills. Used by agents at runtime. Keep in vendored copy. |
docs/_archive-build-pack/03-ARCHITECTURE.md:43:│   ├── skills/                        (lift relevant skills from ~/.claude/skills/)
agents/recruitment/sourcing-scout/agent.md:6:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:169:     (LinkedIn URL) — same fuzzy matcher as Janitor (confidence ≥0.85)
agents/recruitment/sourcing-scout/agent.md:239:Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
agents/recruitment/sourcing-scout/agent.md:296:| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
agents/recruitment/sourcing-scout/agent.md:299:| Bullhorn MCP read capability | W3-W4-W5 build chain | ⏸ |
agents/recruitment/sourcing-scout/agent.md:345:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/sourcing-scout/agent.md:357:- Codex re-ratifies post-build via `review-agent-bundle.md` skill
agents/recruitment/janitor/agent.md:1:# Janitor — the wedge agent
agents/recruitment/janitor/agent.md:3:**Status:** Proposed (Day-16 pre-W5-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice).
agents/recruitment/janitor/agent.md:6:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:7:**Build complexity:** L (2 weeks) per ULTRAPLAN A2 line 512.
agents/recruitment/janitor/agent.md:8:**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.1.
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:29:Resolved by cortextOS daemon → spawns Janitor in Tier-2 batch mode (no persistent PTY). Typical runtime per tenant: 15-45 min depending on Bullhorn corpus size.
agents/recruitment/janitor/agent.md:37:`--dry-run` reports what WOULD be written without touching Bullhorn. `--report-only` regenerates the day-30 report without doing dedup/enrichment passes (used post-incident for manual report regeneration).
agents/recruitment/janitor/agent.md:41:- Brain UI "Run Janitor now" button → triggers via internal API
agents/recruitment/janitor/agent.md:42:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold`)
agents/recruitment/janitor/agent.md:52:Located at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`. Eight sections:
agents/recruitment/janitor/agent.md:57:| 2 | **Dedup pairs** | List of duplicate candidate pairs identified this run (confidence ≥0.85 only); for each pair: candidate `bullhorn_id` per vertical-schema.yaml candidate entity, match dimensions (name + email + phone + LinkedIn), confidence score, action taken (merged vs flagged-for-review) |
agents/recruitment/janitor/agent.md:60:| 5 | **Agent vs. consultant attribution** | Rows attributed to Janitor automated work vs consultant manual entry; supports the day-30 before/after narrative |
agents/recruitment/janitor/agent.md:61:| 6 | **Gate-B metric** | TWO independent thresholds per ULTRAPLAN A2 line 511 verbatim: dedup improvement ≥15% AND field-completeness improvement ≥10%. Both must pass. NOT a composite score — that would let one threshold cover for the other. |
agents/recruitment/janitor/agent.md:62:| 7 | **Exception list** | Failed writes (Bullhorn 4xx/5xx, FK violations); rate-limit hits; dedup proposals flagged for review (confidence between 0.7-0.85); operator action items |
agents/recruitment/janitor/agent.md:67:Three write categories. Action types map to `agents/_shared/autosend-policy.yaml` — existing entries are used as-is; new entries are flagged for catalogue addition at W5 build (per `review-agent-bundle.md` §1 row §6 flag-for-addition pattern):
agents/recruitment/janitor/agent.md:69:1. **Candidate merge** (`PUT /Candidate/{primary_id}` + cascade) — only when confidence ≥0.85 per Gate A; no merge if either candidate had Bullhorn activity in last 90 days without explicit review flag (per ULTRAPLAN A2 line 510 verbatim). Action type: **`bullhorn_candidate_dedupe`** (existing in autosend-policy.yaml line 69; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:94:     opportunities created/modified since last Janitor run (last_run_at in
agents/recruitment/janitor/agent.md:102:   → discard pairs <0.85 confidence (per Gate A)
agents/recruitment/janitor/agent.md:104:     (per ULTRAPLAN A2 line 510 verbatim)
agents/recruitment/janitor/agent.md:155:   → write to /vault/<tenant>/janitor-reports/day-30-<ISO-date>.md
agents/recruitment/janitor/agent.md:177:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:180:- Every proposed merge has confidence ≥ 0.85 per ULTRAPLAN A2 line 510
agents/recruitment/janitor/agent.md:181:- No merge proposal where EITHER candidate has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim)
agents/recruitment/janitor/agent.md:187:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint; per Day-19 catalogue add at `escalation-codes.md` line 184) OR `ESC_DUPLICATE_DETECTED` (merge-confidence reject; existing line 127) per the failed condition. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (line 163) is NOT used by Janitor — that code is reserved for vertical-schema field-constraint violations at write-time.
agents/recruitment/janitor/agent.md:191:Per ULTRAPLAN A2 line 511 verbatim: **"day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement"**.
agents/recruitment/janitor/agent.md:193:Two independent thresholds (both must pass): dedup improvement ≥15% AND field-completeness improvement ≥10%. NOT a composite — composite would let one cover the other.
agents/recruitment/janitor/agent.md:195:Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
agents/recruitment/janitor/agent.md:197:Failing either threshold for 3 consecutive runs → fire `ESC_GATE_B_MISS` → flag for operator review (heuristic tuning may be needed; not a kill).
agents/recruitment/janitor/agent.md:212:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (section count or per-section citation missing in day-30 report) | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:213:| `ESC_DUPLICATE_DETECTED` | Per catalogue trigger: dedup confidence ≥0.85 cases requiring human review (NOT used for <0.85 reject cases — those silently drop per Step 3 algorithm) | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:214:| `ESC_GATE_B_MISS` | Either independent Gate-B threshold (dedup <15% OR field-completeness <10%) missed for 3 consecutive runs. NOT a composite — see §5 Gate B for the two-threshold rule. | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:217:Janitor does NOT use:
agents/recruitment/janitor/agent.md:219:- `ESC_VOICE_DRIFT_TENANT` — fired by nightly voice-drift cron (per `escalation-codes.md` line 170-175 trigger: ≥N `ESC_VOICE_DRIFT` rows from same tenant in rolling 7d window). Janitor only fires the per-run `ESC_VOICE_DRIFT`; aggregate `_TENANT` rollup is handled by the canary not Janitor.
agents/recruitment/janitor/agent.md:220:- `ESC_AUTOSEND_BLOCKED` — that's for red-tier blocks (`escalation-codes.md` line 41); Janitor writes are yellow tier only
agents/recruitment/janitor/agent.md:222:- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction
agents/recruitment/janitor/agent.md:235:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:241:## §8 — Build dependencies (W5 prerequisites)
agents/recruitment/janitor/agent.md:243:Janitor build cannot start until ALL of the following are confirmed:
agents/recruitment/janitor/agent.md:257:| `validate.sh` Gate A logic | Build at W5 start (~0.5 day) | ⏸ |
agents/recruitment/janitor/agent.md:258:| `context.sh` hydration | Build at W5 start (~0.5 day) | ⏸ |
agents/recruitment/janitor/agent.md:259:| `cycle.sh` orchestration (12-step) | Build at W5 start (~2 days) | ⏸ |
agents/recruitment/janitor/agent.md:260:| Dedup heuristic + confidence scorer | Build at W5 start (~3 days) | ⏸ |
agents/recruitment/janitor/agent.md:261:| 3 fixtures with golden outputs | Build at W5 start (~1 day) | ⏸ |
agents/recruitment/janitor/agent.md:263:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
agents/recruitment/janitor/agent.md:269:**Status:** Proposed. Awaits Bullhorn A+B Accepted + Q1 LOI + W5 build slice start.
agents/recruitment/janitor/agent.md:275:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/janitor/agent.md:278:| Q4 | Tacit-note attribution — should notes attribute to "Intel Force OS Janitor" or just "Internal note"? Tenant brand preference. | Per-tenant config at first-pilot onboarding. |
agents/recruitment/janitor/agent.md:282:### Gotchas (carried forward from ULTRAPLAN A2 line 513)
agents/recruitment/janitor/agent.md:284:1. **Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0.** Estimate 1 week for the MCP server, 1 week for the agent itself (per ULTRAPLAN A2 line 513).
agents/recruitment/janitor/agent.md:285:2. **Dedup is hard; start conservative.** High-confidence merges only (≥0.85); tune up the threshold over time as data builds.
agents/recruitment/janitor/agent.md:286:3. **Bullhorn webhook coverage is patchy** (per ULTRAPLAN A6 line 569 — Concierge note applies cross-agent). Janitor relies on polling not webhooks; safer for nightly cron pattern.
agents/recruitment/janitor/agent.md:292:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/janitor/agent.md:300:- W5 build slice produces all 5 sibling bundle files + 3 fixtures
agents/recruitment/janitor/agent.md:303:- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)
agents/recruitment/janitor/agent.md:307:*End of Janitor agent.md draft.*
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:240:| A2 | `.pending` marker triggers `createApproval` call within 200ms | Integration test: write marker → assert cortextOS pending file appears with correct payload |
docs/decisions/autosend-approval-bridge-spec.md:243:| A5 | Bridge crash + restart: state rebuilds from filesystem scan + Postgres state table | Restart test: kill PM2 process mid-flight, restart, verify pending approvals resume |
docs/decisions/autosend-approval-bridge-spec.md:303:Codex Day-7 manifest queue position: TBD (will be ~#39 when filed). Ratifies via `review-architecture-decision.md` skill (with D5 softening applies if Status flipped to Reference after build complete).
docs/_supplementary/planning-phase-brief.md:183:**End state of week 5:** every platform spec ready. Claude Code has everything needed to start builds CC1–CC10 in parallel. **This is the single most important milestone.** At this point, build work starts even though planning continues.
docs/_supplementary/planning-phase-brief.md:228:Claude Code can start meaningful build work as soon as Phase 3 is complete (end of week 5 on this schedule). Phases 4–6 continue alongside the build.
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/architecture/cortexos-primitive-status.md:85:for i in 1 2 3; do kill -SIGUSR2 $(pm2 pid ifos-daemon); sleep 5; done
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:161:The bus is real, well-tested at unit and integration layers, with HMAC-SHA256 message signing and a documented 3-directory lifecycle. However, **two pieces of the master-brief description are wrong against the verified SHA `c21fbfe`** — flagged below; both affect the brain-replacement boundary (§3.4) and need founder review before Day 7.
docs/architecture/cortexos-primitive-status.md:169:- `src/bus/message.ts:19-44` — HMAC-SHA256 signing using `${ctxRoot}/config/bus-signing-key`. Quirk 5 in `.agents/learnings/00-cortextos-quirks.md` confirms each instance has its own key (IFOS and Personal have separate HMAC keys).
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:256:- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:259:**Risk if flaky:** Every Tier-1 auto-send agent collapses to drafts-only — the documented v1.0 Risk-#1 contingency (Ultraplan §3.5: "Every Tier 1 agent has a 'degraded mode' fallback (drafts-only, no auto-send, scheduled retry) that runs if cortextOS state is unhealthy"). Loses the Triage and Cash Conductor closing demos but does NOT kill v1.0.
docs/architecture/cortexos-primitive-status.md:370:Full experiment lifecycle code, dedicated sprint-3 test file, fully-documented 8-phase theta-wave skill shipped in the `analyst` template. Approval-gate integration ties it back into primitive 4. Not on the v1.0 critical path — Ultraplan §3.1 row 6 already defers it to v1.1 Night Sourcer.
docs/architecture/cortexos-primitive-status.md:376:- `templates/analyst/.claude/skills/theta-wave/SKILL.md` (156 lines) — fully fleshed-out 8-phase cycle (Initiate → Deep System Scan → Evaluate Previous → Evaluate Agent Cycles → External Research → Conversation with Orchestrator → Hypothesis and Action → Score+Log+Report). References `cortextos bus manage-cycle create/modify/remove` for cycle CRUD.
docs/architecture/cortexos-primitive-status.md:377:- `templates/analyst/.claude/skills/autoresearch/SKILL.md` (different file) — the per-agent autoresearch skill (hypothesis → change → measure → keep/discard).
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:415:  "Read .claude/skills/theta-wave/SKILL.md and run the cycle."
docs/architecture/cortexos-primitive-status.md:438:- `templates/orchestrator/` — 17 files including a 238-line `CLAUDE.md` plus `IDENTITY.md`, `SOUL.md`, `GOALS.md`, `GUARDRAILS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `ONBOARDING.md`, `AGENTS.md`, `config.json`, `goals.json`, plus `experiments/`, `memory/`, `skills/` directories. Mirror set for `agent`, `analyst`, `agent-codex`, `hermes`, `m2c1-worker` templates.
docs/architecture/cortexos-primitive-status.md:443:- `src/daemon/worker-process.ts` (126 lines) + the `m2c1-worker` template — supports the "spawn an ephemeral worker, monitor via bus, collect output" pattern referenced in the orchestrator skill set.
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
agents/recruitment/diagnostic/agent.md:6:**Build wave:** v1.0 W3-4 per master brief §8.2 row 1 (anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`.
agents/recruitment/diagnostic/agent.md:55:| 7 | **Tech stack signals** | Technologies named in JDs + LinkedIn skills aggregated from current employees + tools mentioned in director posts | LinkedIn JDs + LinkedIn employee profiles |
agents/recruitment/diagnostic/agent.md:171:Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
agents/recruitment/diagnostic/agent.md:220:| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
agents/recruitment/diagnostic/agent.md:229:| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ✅ Skill built Day 19 (`.codex/ratification/review-agent-bundle.md`) |
agents/recruitment/diagnostic/agent.md:262:Per `.codex/ratification/review-agent-bundle.md` (skill built Day 19; commit `825ebd4`): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.
docs/specs/PRODUCT-SPEC.md:137:#### R9. The Janitor — the database becomes an asset
docs/specs/PRODUCT-SPEC.md:158:- **Revenue story:** "Converts the candidate database from a storage cost to a revenue stream. Spec pitches generate 1–3 net-new briefs per month." Modelled: 8–15% of placement-ready candidates land roles via spec pitch in firms that do this well.
docs/specs/PRODUCT-SPEC.md:242:| **Solo** (1–4 fee earners) | £499 | Janitor + 1 always-on agent (drafts-only) + Scribe | "Pay back the year inside one extra placement. Save 10+ hours/week of inbox and admin drag." |
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:279:        │   The Scribe captures    │    │  The Janitor keeps it    │
docs/specs/PRODUCT-SPEC.md:344:- Janitor runs against the ATS — produces the day-1 cleanup report.
docs/specs/PRODUCT-SPEC.md:382:3. **"Genuinely new feature — let me see how many other customers want this."** This goes on the roadmap. We never build it for one customer unless they pay materially extra for it (typically Scale-tier customers only). ~15% of the time.
docs/specs/PRODUCT-SPEC.md:430:**1. Every agent now has a quantified revenue story, not just a time-saved story.** The internal business plan and the 24/7 directive had revenue stories for some agents (Cash Conductor, Client Hunter, T5) but not all. Triage was pitched on responsiveness; here it's pitched on "2–4 additional placements/year per consultant from never-lost candidates". Janitor was pitched on database hygiene; here it's pitched on "one reactivated dormant-but-clean candidate per month covers the tier price".
docs/specs/PRODUCT-SPEC.md:458:- **No free pilots beyond the structured 14-day Janitor cleanup trial.** Free pilots train customers to expect free.
docs/specs/PRODUCT-SPEC.md:472:- The Janitor (the wedge agent; lowest risk, highest visible value)
docs/specs/PRODUCT-SPEC.md:530:9. **The Janitor** — "Your sourcing runs become 3× more productive against clean data."
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:7:**Skill applied:** `.codex/ratification/review-architecture-decision.md` §1
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:31:The skill's enumeration of allowed Status values explicitly includes `Reference` and `In Force` alongside `Proposed | Accepted | Superseded | Deprecated`. By including those values, the skill implicitly accepts that artefacts ratified under `review-architecture-decision.md` may legitimately not be decisions. Enforcing ADR-shape (Context + Decision + Consequences) on audits + runbooks adds ceremony without value:
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:36:**The right fix is to soften the skill, not to retrofit ADR ceremony onto audit + runbook artefacts.** The skill's §1 requirement should exempt Status=Reference + Status=In Force artefacts from the explicit Decision/Consequences subheadings — Context still required (a reader must be able to tell what the artefact is about cold).
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:38:### Proposed skill softening (Founder Decision D5)
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:58:**Resolution detail (2026-05-22):** Founder accepted D5-A. Skill softening landed in `.codex/ratification/review-architecture-decision.md §1` — Reference + In Force status artefacts are now exempt from Decision + Alternatives + Consequences sections (Context + Status update line still required). The two REJECTED artefacts from Round 1 (`cortexos-primitive-status.md`, `operational-hygiene-protocol.md`) are expected to RATIFY in Round 2 without changes. Two new Day-9 artefacts (`architecture-cohesion-review.md` Reference, `tenant-lifecycle.md` In Force) are now ratifiable under the softened skill.
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:62:**D5-A accepted.** Skill softened. Cluster B re-ratification (Round 2) expected to RATIFY `cortexos-primitive-status.md` + `operational-hygiene-protocol.md` without artefact changes. Day-9 Reference + In Force artefacts (`architecture-cohesion-review.md`, `tenant-lifecycle.md`) ratifiable under softened skill.
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:66:- **D5-A** (chosen): Accept Claude's reasoning. Soften the skill per §2 above.
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:185:The flock (§2) prevents two operations from racing the same file's read-then-write. The Postgres version check (§3) catches the rare case where flock acquisition succeeded sequentially but a *different* code path (e.g. cron-driven full-table update in Janitor's nightly sweep) updated the row without holding flock.
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:25:**R2 commitment** per design §2.2: no `.claude/skills/` inheritance from cortextOS templates. Default is exclusion of all 24 cortextOS-template skills. Opt-in for specific skills only via the bundle's `tools.yaml` `cortextos_skills:` top-level block (syntax per design §2.2 spec gap §2.2-A resolution).
docs/decisions/ADR-003-agent-bundle-renderer.md:51:- **Drop (2):** cortextOS template files (IDENTITY.md / SOUL.md / GUARDRAILS.md / GOALS.md / HEARTBEAT.md / MEMORY.md / USER.md / SYSTEM.md / TOOLS.md / AGENTS.md / memory/ / experiments/) and the 24-skill `.claude/skills/` tree.
docs/decisions/ADR-003-agent-bundle-renderer.md:137:> "The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly. The renderer (`packages/agent-renderer/`, per `docs/decisions/ADR-003-agent-bundle-renderer.md` and `docs/architecture/agent-bundle-renderer-design.md`) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant). The cortextos-ifos add-agent command is NOT the IFOS path — it inherits 24 cortextOS template skills the IFOS bundle does not want."
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/ADR-003-agent-bundle-renderer.md:145:**For Week 0 remaining (Day 2 through Day 7).** ADR-003 doesn't unblock or block any remaining Week 0 work directly. Day 2 (Bullhorn integration path), Day 3 (sequencing + Brain UI scope), Day 4 (Postgres provisioning with `entities` + `entity_links` split per ADR-002 Edit 3 + `_secrets.env` skeleton), Day 5 (auto-send safety policy + kill criterion), Day 6 (vertical schema v0.1), Day 7 (single-sentence test + first Codex ratification) all proceed independently. The renderer is queued for Codex Day-7 review but does not gate Day 7's other reviews.
docs/_supplementary/PRD-autonomous-agent.md:561:tmux kill-session -t intelforce-director
docs/_supplementary/PRD-autonomous-agent.md:596:tmux kill-session -t $SESSION 2>/dev/null
docs/_supplementary/PRD-autonomous-agent.md:598:# Sleep to ensure clean kill
docs/_supplementary/PRD-autonomous-agent.md:1143:  "overall_score": 8.2,
docs/_supplementary/PRD-autonomous-agent.md:1479:        background: 'linear-gradient(transparent, rgba(0,0,0,0.85))',
docs/_supplementary/PRD-autonomous-agent.md:2307:- [ ] Test crash recovery: kill tmux session → verify launchd restarts it
docs/architecture/second-brain-design.md:16:### 1.1 — Inventory: every cortextOS template skill that touches kb-*
docs/architecture/second-brain-design.md:18:Discovery sweep: `grep -rn "kb-query\|kb-ingest\|kb-collections\|kb-setup\|knowledge-base\|knowledge\.md" packages/harness/cortextos/templates/` returned 34 files. Eliminating duplicates (the `knowledge-base` skill ships verbatim in `agent`, `analyst`, `orchestrator`, and `agent-codex` template trees), the operationally distinct use cases are:
docs/architecture/second-brain-design.md:24:| `analyst/.claude/skills/memory/SKILL.md:107` | `kb-ingest` | Same pattern — heartbeat re-ingest of `MEMORY.md` + daily memory files | **Yes**, same role as above. |
docs/architecture/second-brain-design.md:26:| `orchestrator/.claude/skills/morning-review/SKILL.md:120-122` | `kb-query "health check"` | Smoke test: confirm KB is configured. Explicitly marked: "**OK or empty results**: note 'KB configured'. **Not configured warning**: note 'KB not configured' (informational, not a failure)." | **No.** Explicitly informational, the morning briefing succeeds either way. |
docs/architecture/second-brain-design.md:27:| `orchestrator/.claude/skills/agent-migration/SKILL.md:214-218` | `kb-ingest` | One-time migration: bulk-ingest meeting notes, docs, `MEMORY.md`, `crm/contacts.json` for an adopted agent that has pre-existing data | **No** — a migration tool, not steady-state. Optional and one-time per agent. |
docs/architecture/second-brain-design.md:28:| `agent/.claude/skills/onboarding/SKILL.md:47` | `kb-ingest` | Onboarding checklist row: "KB initial ingestion done — `cortextos bus kb-ingest`" | **No.** It's one row in a checklist; surrounding rows are similarly optional and the agent boots without completing every row. |
docs/architecture/second-brain-design.md:30:### 1.2 — Skills that mention KB but do NOT call kb-*
docs/architecture/second-brain-design.md:34:- `analyst/.claude/skills/theta-wave/SKILL.md` (156 lines) — zero `kb-*` invocations. Phase 2 "Deep System Scan" reads `MEMORY.md`, experiment files, event logs, GOALS.md directly (lines 31-40).
docs/architecture/second-brain-design.md:35:- `analyst/.claude/skills/autoresearch/SKILL.md` — zero `kb-*` invocations.
docs/architecture/second-brain-design.md:36:- `m2c1-worker/.claude/skills/m2c1-worker/SKILL.md` — mentions KB only as a tool reference, doesn't call it.
docs/architecture/second-brain-design.md:37:- `hermes/HEARTBEAT.md`, `hermes/TOOLS.md` — KB listed as available, not invoked from skill flows.
docs/architecture/second-brain-design.md:84:### 1.7 — Do IFOS agents inherit cortextOS template skills?
docs/architecture/second-brain-design.md:86:The Q1 finding that "no IFOS-owned agent calls kb-*" assumed IFOS agents are NOT scaffolded from cortextOS's base template. That assumption needs verification, because if `cortextos-ifos add-agent` is the path IFOS uses, the inherited `.claude/skills/` tree pulls `knowledge-base` and `memory` skills in by default, and those skills DO call `kb-*`.
docs/architecture/second-brain-design.md:91:- For Claude-Code runtimes (the IFOS default), creates `.claude/skills/` (line 95-97).
docs/architecture/second-brain-design.md:93:- Calls `copyTemplateFiles(templateDir, agentDir, name, org)` (line 109, definition at line 382-402): recursive copy of the entire template tree, with `{{agent_name}}` / `{{org}}` / `{{current_timestamp}}` placeholder substitution. Excludes `node_modules`. **Copies `.claude/skills/` verbatim.**
docs/architecture/second-brain-design.md:95:**What the base `agent` template ships in `.claude/skills/`** (from `ls templates/agent/.claude/skills/`):
docs/architecture/second-brain-design.md:99:auto-skill  autoresearch  bus-reference  comms  cron-management
docs/architecture/second-brain-design.md:106:24 skills. Of these, **`knowledge-base/SKILL.md`** calls `kb-query / kb-ingest / kb-collections / kb-setup` (Q1.1 inventory), and **`memory/SKILL.md`** calls `kb-ingest` for heartbeat memory re-ingestion (analyst memory SKILL.md:107).
docs/architecture/second-brain-design.md:123:No `CLAUDE.md`, no `AGENTS.md`, no `MEMORY.md`, no `.claude/skills/` tree. The bundle lives at `${repo}/agents/recruitment/<name>/` (in the IFOS repo, not under cortextOS's `orgs/<org>/agents/`). Master brief §8.3 shows the working pattern is hand-`mkdir` of this layout in Claude Code, not `cortextos-ifos add-agent`.
docs/architecture/second-brain-design.md:129:| Design | Mechanism | Inherited cortextOS skills? | Net result |
docs/architecture/second-brain-design.md:131:| **R1. Bundle-on-top-of-template** | Renderer calls `cortextos-ifos add-agent --template agent`, then overlays IFOS files (`agent.md` → custom `CLAUDE.md`, `config.schema.json` → augmented `config.json`, `tools.yaml` references IFOS adapters). | **Yes by default.** All 24 base-template skills come along unless explicitly stripped. | IFOS agents call cortextOS's KB by inheritance, breaking the §1.5 "untouched" promise. |
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:136:1. **It honours the §3.1 boundary cleanly.** The §3.1 exception in master brief is "the four `bus/kb-*.sh` shadow points." If we don't shadow them (per §1.5), inheriting skills that call them invites confusion — the inherited skills point at cortextOS's KB, and we'd need to remember that IFOS-owned agents must not invoke them. R2 removes the question entirely.
docs/architecture/second-brain-design.md:137:2. **It matches the Rule 3 vocabulary.** Master brief §1 Rule 3 is "Reuse before build" — every agent uses `agents/_shared/` modules. R2 makes `_shared/` the only shared surface; the 24 inherited cortextOS skills would be a parallel shared surface in tension with the IFOS one.
docs/architecture/second-brain-design.md:138:3. **It defers cortextOS-template features cleanly.** If a future IFOS need genuinely benefits from one of cortextOS's 24 skills (e.g. `human-tasks`, `approvals`, `agent-browser`), the bundle's `tools.yaml` can opt in by referencing it explicitly. Explicit opt-in beats default inheritance for a multi-tenant product.
docs/architecture/second-brain-design.md:140:**Until the renderer is built** (Week 0 has no agent code per master brief §6 Day 7; the renderer is a Week 1+ concern), the inherited-skills risk only matters for any debug/probe agents scaffolded via `cortextos-ifos add-agent` during Week 0 verification. Those probe agents will inherit the kb-* calls and write to cortextOS's KB — which is fine, because cortextOS's KB stays in place per §1.5.
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
docs/architecture/second-brain-design.md:424:| `search-by-relationship` | Janitor (v1.0): all Candidates linked to Brief X for dedup | v1.0 | `(from_id: str, link_type: str, tenant_id: str)` | `List[EntityRef]` | few seconds | Postgres `entity_graph` traversal; one-hop only in v1.0, multi-hop deferred to graph view v1.2 |
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:459:  - **Git:** **Spec gap 2.4-A.** Neither master brief nor Ultraplan specifies whether `/vault/{tenant}/` is also a git repo. Obsidian users typically git-init their vaults. **Recommendation:** yes — initialize `/vault/{tenant}/.git/` at tenant provisioning (Ultraplan §5.5 step 2). Founder gets free history, blame, and rollback via Obsidian Git plugin. Agents do NOT commit; the founder commits manually or via a scheduled cron run by Janitor's nightly sweep. **Blocks v1.0 build:** no — git init is one line in `provision-tenant.sh`; commit cadence can be decided in Week 1.
docs/architecture/second-brain-design.md:709:- t=0+50ms: Janitor calls `update-entity(candidate_sarah_bowen, "right_to_work_status", "verified")`. Blocks on the flock.
docs/architecture/second-brain-design.md:711:- t=0+301ms: Janitor acquires flock. Reads file (now contains Concierge's append). Reads Postgres (`updated_at = T1`). Computes new frontmatter. Writes file atomically. Postgres UPDATE `WHERE updated_at = T1` succeeds (`updated_at = T2`).
docs/architecture/second-brain-design.md:727:**Spec gap 2.6:** none of this is in the master brief. **Recommended resolution:** adopt the mechanism above verbatim; document in a `docs/architecture/vault-concurrency.md` companion file in Week 1 (before agent code starts). **Blocks v1.0 build:** no — concurrency code is a v1.0 build artefact, not a Week 0 prerequisite, but the design needs to land before the first multi-agent test in week 5.
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:761:- `ingest-entity` — Janitor's nightly sweep ingests thousands of records; batching is the model. Per-record latency 100ms-1s is fine.
docs/architecture/second-brain-design.md:775:| Janitor | 1:5 | reads each Bullhorn entity once; writes many cleanup updates per sweep |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:793:- **§1.7:** R2 renderer recommended → IFOS agents have no `.claude/skills/` tree by default.
docs/architecture/second-brain-design.md:872:#### Option γ — Claude Code skill + library
docs/architecture/second-brain-design.md:876:├── wiki-skill/
docs/architecture/second-brain-design.md:877:│   └── SKILL.md                 ← documents the wiki API as a Claude Code skill
docs/architecture/second-brain-design.md:881:Skill installed into each agent's `.claude/skills/wiki/` at scaffold time. Agents read the SKILL.md as part of their context and invoke wiki ops via the documented usage pattern (typically by calling the library via `node -e` or a thin per-skill script).
docs/architecture/second-brain-design.md:883:**Critical constraint from §1.7:** if R2 wins (recommended renderer design — bundle-only, no `.claude/skills/` tree copied), the skill installation path **does not exist by default**. The renderer would have to be modified to inject the wiki skill specifically, contradicting R2's "no inherited skills" promise. **Option γ is operationally awkward under R2.** Under R1 (bundle-on-top-of-cortextos-template, NOT recommended), γ is operationally cheap but inherits the 24-skill default-on tax along with it.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:890:| **Multi-tenancy enforcement** — how `tenant_slug` is validated at the entry point (master brief §3.5) | Wrapper reads `CTX_TENANT_SLUG` env var (set by PM2 ecosystem per-tenant process group); CLI handler validates that the arg `--tenant` matches the env or fails with `ESC_PII_LEAKAGE_RISK`. Kernel-enforced isolation underneath (POSIX 0700 per Ultraplan §5.1) means a wrong tenant fails at filesystem read. | Server receives `CTX_TENANT_SLUG` at connection setup via MCP server args; rejects any tool call whose `tenant_slug` mismatches the connection identity. Filesystem isolation underneath same as α. One enforcement site. | Library validates `tenant_slug` against env var. Same enforcement model as α, but agent-side discipline depends on skill docs being followed. |
docs/architecture/second-brain-design.md:891:| **Operational complexity** — new infrastructure introduced | None new. 12 shell wrappers + a Node CLI binary + a library; same shape as `packages/harness/cortextos/bus/`. No new PM2 process. | One new PM2 process per machine (`ifos-wiki-mcp`). Adds to the operations surface: process supervision, restart policy, port allocation, logs to manage. At Sovereign tier (one cluster slice per tenant per Ultraplan §5.4) this is one extra process per tenant. | Skill files added to every agent at scaffold time. Under R2 renderer (recommended), the renderer must be extended to inject the wiki skill — additional renderer logic. Under R1, automatic. |
docs/architecture/second-brain-design.md:892:| **Agent ergonomics** — what `tools.yaml` / `agent.md` looks like | `agent.md` references wiki ops as bus commands: `cortextos-ifos bus wiki-search "..."`. No `tools.yaml` entry needed (bus commands are implicit). Pattern is identical to how `bus send-message`, `bus create-task` already work in cortextOS. | `tools.yaml` has a dedicated `mcp_servers.wiki` block + tool list (sketched in §3.1). Adds a section per agent. Aligns with how vertical-adapter MCP connectors work in master brief §3.2. | `agent.md` would have to reference the skill explicitly (e.g. "When you need to query the wiki, invoke `.claude/skills/wiki/SKILL.md`"). Under R2, agents don't have a `.claude/skills/` tree, so the agent.md has to describe a one-off invocation pattern. Awkward. |
docs/architecture/second-brain-design.md:893:| **Consistency with cortextOS bus convention** | Identical pattern: 47 existing bus wrappers under `packages/harness/cortextos/bus/` all do `exec node dist/cli.js bus <command>`. Option α uses the same 3-line shim shape. Zero cognitive tax for an engineer who already understands cortextOS. | New surface (MCP). Aligns with the vertical-adapter pattern (master brief §3.2) where Bullhorn / Companies House etc. are MCP servers — so consistent with that pattern, not with the bus pattern. | Aligns with cortextOS's skill convention (each template ships `.claude/skills/` with kb / memory / tasks / heartbeat / etc.). Inconsistent with the bus pattern; consistent with the skill pattern; awkward under R2. |
docs/architecture/second-brain-design.md:894:| **v1.0 minimum effort estimate** | ~11-13 days. Breakdown: 12 wrappers × 0.25 day = 3 days; Node CLI + dispatch = 1 day; library (12 ops, concurrency, frontmatter parse/write) = 4-5 days; Postgres migrations = 1 day; pgvector voice integration = 1 day; concurrency tests = 1-2 days. | ~14-17 days. Adds: MCP server scaffolding + tool registration + JSON-RPC handling + PM2 integration + multi-tenant connection-identity validation. The library effort is the same; the server adds ~3-4 days. | ~9-11 days **IF R1**. Under R2, **probably impossible without renderer changes** — adds ~5 days for renderer modification + skill injection logic + per-agent install path. Total under R2: ~14-16 days, **and** undermines R2's clean-separation promise. |
docs/architecture/second-brain-design.md:895:| **Failure mode if cortextOS daemon is unhealthy** | Wrappers don't depend on the daemon — they exec directly into Node. As long as Postgres is up and the filesystem is mounted, wiki ops succeed. Decision_log writes still go through (Postgres direct). Tracks per Ultraplan §3.5 "Tier 1 agents have degraded-mode fallbacks" — the wiki is part of the fallback substrate, not part of what fails. | If `ifos-wiki-mcp` crashes, every agent loses wiki access until it restarts. PM2 auto-restart bounds the outage to ~5s, but during the outage every wiki call fails. If `cortextos-daemon` is unhealthy, MCP connections from agents (which are in PTYs supervised by the daemon) may also be affected. Two-process dependency. | Same as α (library invoked directly, no daemon dependency) but adds skill-discovery path: if the agent's Claude Code session can't find the skill (e.g. corrupted scaffold), all wiki ops fail. |
docs/architecture/second-brain-design.md:896:| **Lock-in cost** — how hard to switch to a different option later | Low. Wrappers are 3-line shims; replace with calls to a different backend (MCP server, library) by changing the `exec` line. Library is reusable. Agents see the same `cortextos-ifos bus wiki-search` invocation regardless of backend — interface stable. | Medium. Agents have MCP `tools.yaml` entries committed; migration to α means rewriting `agent.md` and `tools.yaml` for every agent (18 in full strength per master brief §0). Library is reusable. | High. Skill-installation path is per-agent; migration requires per-agent skill removal + new wrapper/MCP declaration. Also under R2 the original installation path was a hack, which makes "switch away from γ" the cleanup of that hack. |
docs/architecture/second-brain-design.md:906:1. **Master brief §3.1 (submodule boundary).** The §3.1 exception is "shadow four `bus/kb-*.sh` points." Per Q1.5 we don't shadow those — but the **pattern** §3.1 authorises (parallel `bus-overrides/` directory housing shell wrappers that match cortextOS's bus convention) is exactly what Option α uses. We use the boundary's *vocabulary* without exercising its kb-* exception. Option β would require introducing a new vertical surface (MCP server alongside daemon and dashboard) that §3.1 doesn't anticipate. Option γ would require modifying the renderer's skill-installation path, contradicting §1.7's R2 recommendation.
docs/architecture/second-brain-design.md:916:**What's lost relative to Option γ:** the deep Claude-Code-native skill-discovery experience. Under R2 (recommended renderer), this path is operationally awkward anyway, so the loss is theoretical.
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:966:| **§1.7-A** | Master brief §8 silent on renderer | No mechanism for translating the IFOS Agent Bundle v2 layout (`${repo}/agents/recruitment/<name>/`) into the cortextOS-shaped per-agent directory the daemon reads from (`${projectRoot}/orgs/<org>/agents/<name>/`) | ADR-003 in Week 1 + companion `docs/architecture/agent-bundle-renderer-design.md`. Adopt R2 (bundle-only, no `.claude/skills/` tree). | **Yes** — without it, no IFOS agent can run. Week 1 prerequisite. |
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:54:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/specs/_archive-build-handoff.md:241:Also Day 1: have your first design-partner sales conversation. The Ultraplan §10 risk register lists "no signed LOI by end of week 0" as a v1.0-killer risk. Sales conversations start now.
docs/specs/_archive-build-handoff.md:253:Confirm or revise Ultraplan §9's assumption: **close the first three pilots fastest**. That means Janitor and Cash Conductor close demos before Triage absorbs the development heat. Revise only if a hire's signed or a different pilot dynamic emerges.
docs/specs/_archive-build-handoff.md:268:### Day 5 — Safety policy and kill criterion
docs/specs/_archive-build-handoff.md:278:`docs/v1-kill-criterion.md` (Q12):
docs/specs/_archive-build-handoff.md:378:| 2 | **Janitor** | 5 | Bullhorn MCP (read + write) | First demoable inside-the-ATS result; day-30 before/after report closes deals |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/specs/_archive-build-handoff.md:451:| "Let me ship without the kill criterion documented..." | Ultraplan §11 Day 5 |
docs/specs/_archive-build-handoff.md:480:- Mark the kill criterion as "soft" because "the pilot is going well"
docs/_supplementary/technical-strategy-v2.md:361:### 4.3 Why Obsidian specifically (and it's not overkill)
docs/_supplementary/technical-strategy-v2.md:373:### 4.4 Is it overkill? Here's the honest split
docs/_supplementary/technical-strategy-v2.md:377:**For agency owners, course sellers, consultants, knowledge workers:** hell no it's not overkill. These are people who already have Obsidian or Notion setups. They understand and value the graph. Sell it hard. Include it on the pricing page. *"Your AI workforce has a brain you own, in a format you control, that you can edit directly. Open it in Obsidian. Browse it on your phone. Export it any time."*
docs/_supplementary/technical-strategy-v2.md:532:### 6.6 The thing that actually kills the business
docs/_supplementary/technical-strategy-v2.md:589:5. **Obsidian:** yes, not overkill. Hidden behind dashboard for SMEs; sold hard to agencies/operators; always present on the backend.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:54:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:32:| 17 | `docs/decisions/v1.0-kill-criterion.md` + Day-5 close commit `c6734d1` | Proposed + audit log | Verify 10 binary triggers; verify §3 founder-solo authority structure; verify live SQL migration (decision_log.phase 5→6) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:42:Architecture+tenancy slice (commits `5c3fa66` + `c4348aa`) adds 4 new artefacts to the queue. These ratify against `review-architecture-decision.md` skill (with Founder Decision D5 softening for the lifecycle runbook):
docs/decisions/2026-05-18-codex-ratification-manifest.md:57:Autonomous Round 2 ratification reviewed 26 artefacts across the re-ratification, Day-9, and Day-11 queues. Remediation commits referenced by the protocol: `2b287d3` (Round-1 incorporation), `5c3fa66` + `c4348aa` (architecture+tenancy), `783c496` (D5 skill softening), and `20e78d7` + `95e7d4a` (D1/D3 prep). Result: **17 RATIFIED / 9 REJECTED**. Full report: `logs/codex-ratification/round-2-autonomous/SUMMARY.md`.
docs/decisions/2026-05-18-codex-ratification-manifest.md:71:| 11 | `docs/decisions/v1.0-kill-criterion.md` | RATIFIED | Incorporated remediation verified clean. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:115:**Phase 1 (Day 15) — Diagnostic-only mid-week ratification.** Reason: substrate must be verified before 5 new scaffolds reference it. 6 items, all `review-architecture-decision.md` skill except the package-as-a-whole.
docs/decisions/2026-05-18-codex-ratification-manifest.md:117:| # | Artefact | Status | Codex skill | Reason for re-ratify |
docs/decisions/2026-05-18-codex-ratification-manifest.md:126:**Phase 2 (Day 20) — Full Round 4: 5 new agent.md scaffolds.** Each authored Days 16-19 per goal-week-3 Steps 8-12. All `review-architecture-decision.md` skill.
docs/decisions/2026-05-18-codex-ratification-manifest.md:128:| # | Artefact | Status | Codex skill | Master plan citation |
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:138:**Day-19 update:** Initial Round-4 Phase-1 attempt used `review-architecture-decision.md` skill (the only available skill at the time). That returned REJECTED with a load-bearing finding (Issue 5 in `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`) — agent.md files require a different skill structure. **`review-agent-bundle.md` skill built in commit `825ebd4`.** Re-ratification of all 6 agent.md items with the new skill.
docs/decisions/2026-05-18-codex-ratification-manifest.md:140:**Round-4-v2 verdicts (post-skill-build, Day-19 13:25 UTC):**
docs/decisions/2026-05-18-codex-ratification-manifest.md:144:| 1 | `agents/recruitment/diagnostic/agent.md` | **REJECTED** | 5 real findings (Gate A strength + Step 11 decision-log + Trigger 8 mismap + sentinel + validate.sh gap) | `20260524T101934Z-19923` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:155:Remaining Phase-1 items (tools.yaml + cycle.sh + validate.sh + package + ADR-005) NOT yet attempted because they would have inherited the same skill-mismatch issue. ADR-005 should ratify cleanly under `review-architecture-decision.md` (it IS a decision doc); .sh + .yaml files may need their own skills built (defer).
docs/decisions/2026-05-18-codex-ratification-manifest.md:186:| 17 | v1.0-kill-criterion.md | REJECTED (3 issues) | All three (Trigger 1 date / Trigger 2 CLI / Trigger 4 threshold) **incorporated** at `2b287d3`. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:210:> 2. **You** run: `codex review --skill .codex/ratification/review-{type}.md --target {path-or-diff}`
docs/decisions/2026-05-18-codex-ratification-manifest.md:215:For Day-7 first ratification run, steps 1-2 require `.codex/ratification/*.md` skills to exist. They don't yet (see §3).
docs/decisions/2026-05-18-codex-ratification-manifest.md:219:## §3 — Gap: `.codex/ratification/` skills not yet built
docs/decisions/2026-05-18-codex-ratification-manifest.md:221:Master brief §10.2 (Day 0-1 task) specifies 7 skill files under `.codex/ratification/`:
docs/decisions/2026-05-18-codex-ratification-manifest.md:233:**Current state:** `.codex/ratification/` directory does not exist. Day 0-1 task was never executed during Days 0-6 (focus was on master brief §6 Day 0-6 critical path; `.codex/ratification/` slipped per master brief §10.6 framing "Claude does this; we don't ratify the ratification skills until Day 7" but skills themselves needed to be built first).
docs/decisions/2026-05-18-codex-ratification-manifest.md:235:**Codex CLI itself is installed** at `/opt/homebrew/bin/codex`. The gap is the IFOS-specific ratification skills, not the Codex tool.
docs/decisions/2026-05-18-codex-ratification-manifest.md:245:| **Build `.codex/ratification/*.md` skills** | Week 0 extension period (concurrent with Q1 design-partner work) | 2-3 person-days. 7 skill files per master brief §10.2; each follows the "RATIFIED / REJECTED with numbered issues" output contract. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:291:| 17 | `v1.0-kill-criterion.md` §3.4 external advisor | TBD — Week 1-2 must-fill | Founder identifies + engages external advisor before first pilot LOI signs. Codex flags the TBD but cannot resolve. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:302:2. **What's blocking** (`.codex/ratification/*.md` skills not built; Q1 design-partner gap → Week 0 extending).
docs/decisions/2026-05-18-codex-ratification-manifest.md:312:**Reference.** This manifest is itself queued for Codex ratification (item #20) — once `.codex/ratification/*.md` skills exist + Week 0 closes are achievable.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:7:**Ratifies via:** `review-architecture-decision.md` Codex skill (next round)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:20:| 5 | Janitor (Bullhorn R+W) |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:43:| W5 Day 28+: Janitor build start | W5 Day 28+: **Conditional on Bullhorn Sub-decisions A+B Accepted** |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:51:5. **Buffer on kill-criterion Trigger 2.** `v1.0-kill-criterion.md` Trigger 2 fires 2026-06-14 if Diagnostic doesn't render cleanly. Today is 2026-05-24 — 21 days of buffer. Building now beats the deadline by 3 weeks.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:63:### Week 5 (Day 28+) — Janitor build conditional gating
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:65:| Bullhorn A+B state by Day 28 | Janitor action |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:69:| Bullhorn unresponsive past 2026-06-10 | Force Direct-API fallback per `bullhorn-integration-path.md` §1.4; Janitor scaffold begins; Bullhorn auth gated on first pilot raising support ticket |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:73:- Scribe (W6) depends on Bullhorn write; same gating as Janitor
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:109:- `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render by 2026-06-14)
docs/_supplementary/strategic-plan.md:78:Every IntelForce AI OS deployment ships with the same nine agents. This is non-negotiable. **Variable scope kills productization.** Nick knows this. The nine are adapted from his blueprint but tightened for UK SME reality.
docs/_supplementary/strategic-plan.md:394:### 8.2 Channels, ranked by realistic ROI for you
docs/_supplementary/strategic-plan.md:445:- **You try to build everything** (voice + SEO + ads + HR + custom) — this kills you. **Ship 9 agents. Nothing else until month 4.** Write this on your wall.
docs/_supplementary/strategic-plan.md:450:### 10.3 The thing that will actually kill this
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:40:Recommend a one-paragraph footnote in §2.4 that names the substrate: messages are JSON files under `${ctxRoot}/inbox/<to>/{pnum}-{epochMs}-from-{sender}-{rand5}.json`, three-directory lifecycle (`inbox → inflight → processed`), HMAC-SHA256 signed (Quirk 5), stale-inflight recovery at 5 minutes.
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/runbooks/tenant-lifecycle.md:399:**In Force** for runbook procedures. **Codex Day-7 manifest queue item #37**; ratifies via `review-architecture-decision.md` skill (with Founder Decision D5 softening for runbook artefacts).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:36:- **Kill criterion linkage:** Trigger 1 in `docs/decisions/v1.0-kill-criterion.md` §2 (DESIGN-PARTNER-BY-WEEK-2) fires end-of-day **2026-06-03** if no signed LOI by then. That is the binding tripwire — currently **14 calendar days** out from today (2026-05-20).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:113:2. **`.codex/ratification/*.md` skills** — master brief §10.2 Day-1 task deferred during Days 0-6; surfaced as gap during Day-7 grounding. Build during extension period. 7 skill files (SKILL.md + 6 review-{type}.md per master brief §10.2). Estimated 2-3 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:124:4. **First Codex ratification run execution** — manifest produced today (see Deliverable 3); actual `codex review` against ratification skills waits for (a) skills built AND (b) Week 0 close achievable.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:143:- Q1 = YES, Q3 = NO (accepted) → Week 0 closes by founder discretion; Week 1 starts with Risk #2 elevated; Diagnostic W3-4 begins under accepted risk; Janitor W5 contingent on Q3 clearing by then.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:148:- Trigger 1 (kill criterion DESIGN-PARTNER-BY-WEEK-2 PAUSE): fires end-of-day **2026-06-03** if no signed LOI.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:6:**Skill applied:** `.codex/ratification/review-architecture-decision.md`
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:20:**Counter:** Codex is applying the Day-7 single-sentence-test Q3 quality gate ("ATS decided + auth cleared") as if it were a Week-1 implementation gate. The Q3 gate is correct as a closing-of-Week-0 gate per master brief §6 line 502, and Q3 = NO is exactly why Week 0 EXTENDS per the Day-7 single-sentence-test result. But the Q3 gate governs **named v1.0 agent-build slices** (Diagnostic W3-4, Janitor W5, etc.), NOT Week-1 prerequisite code.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:42:| Janitor build (W5) | A+B Accepted (commercial conversations complete) | Pending |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:67:which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:68:build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:69:A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:81:- **Tighten the gate (Codex's read)** — make all Week-1 implementation conditional on A+B Accepted. Forces all 5 Week-1 prereq commits to be re-classified as W5-prereq. Operationally complex + arguably wrong (renderer doesn't need Bullhorn auth to render).
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:82:- **Split the difference** — line 95 wording sharpens AND a new explicit "Week-1 prereq vs W5 agent-build gate hierarchy" subsection is added to bullhorn-integration-path.md §1.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:86:**Resolution update (2026-05-22):** [x] Incorporated via "Counter-argued + sharpen wording." The source decision now encodes the prereq-code-only gate and the W5 Janitor auth gate explicitly.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:58:Options β (MCP server) and γ (Claude Code skill) are rejected on the grounds documented in design §3.2 (rubric) and §3.3 (recommendation rationale).
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:113:1. **ADR-003 + `docs/architecture/agent-bundle-renderer-design.md`** — resolves Spec gap §1.7-A (no documented translation from IFOS Agent Bundle v2 layout to cortextOS-shaped per-agent directory). Without it, no IFOS agent can run. Design recommends R2 (bundle-only, no `.claude/skills/` inheritance) per design §1.7.
docs/runbooks/pii-purge-operational-pattern.md:234:Codex Day-7 manifest queue position: TBD (~#41 when filed). Ratifies via `review-architecture-decision.md` skill (In Force status; D5 softening applies).
agents/recruitment/concierge/agent.md:6:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:287:Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
agents/recruitment/concierge/agent.md:356:| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
agents/recruitment/concierge/agent.md:360:| Bullhorn MCP R+W capability | W3-W4-W5 build chain | ⏸ |
agents/recruitment/concierge/agent.md:412:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/concierge/agent.md:426:- Codex re-ratifies post-build via `review-agent-bundle.md` skill
docs/_supplementary/build-plan-original.md:334:This is your demo agent. Get this one perfect. Everything else can be 80% and you're fine. Proposal Builder at 80% kills your trust story.
docs/_supplementary/build-plan-original.md:928:**High.** Voice is its own skill. 3 weeks to do a production-ready Vapi setup with tight escalation logic. Hire or contract specifically for this. Do NOT ship until it's been through 100+ test calls across edge cases.
docs/_supplementary/build-plan-original.md:1327:Grafana for the operator dashboard. Tempo/Loki if you want full observability, but probably overkill v1.
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:22:| A2 | Janitor | 5 | Bullhorn MCP (R+W) | "First demoable inside-ATS result; day-30 before/after closes deals" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:34:- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:65:Per master brief §12 / Ultraplan §10 row #2 (the four-risks-that-kill-v1.0 table), the **documented v1.0 scope-cut contingency** is verbatim:
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:71:- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
docs/decisions/sequencing-target.md:74:Recommended sequence in §4 must remain **operationally coherent under both contingencies.** A sequence that breaks (e.g. one that ships Concierge before Janitor) would lose the Risk #2 contingency because dropping Janitor would orphan the already-shipped Concierge's data flow. The §4 recommendation explicitly validates against both contingencies.
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:105:### 2.2 — A2 Janitor
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
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:151:| 2. Substrate exercise | **Medium** | Reuses Bullhorn R from Janitor (no new Bullhorn substrate). New MCP integrations: LinkedIn via Proxycurl (rate-limited per Ultraplan §10 row #6), Reed, CV-Library. Source-abstraction layer per Ultraplan §8.1 line 555 designed to be reusable by Night Sourcer v1.1 |
docs/decisions/sequencing-target.md:152:| 3. Risk de-risking | **Medium** | **First exercise of LinkedIn rate-limit budget** per Ultraplan §10 Risk #6 ("LinkedIn rate limits via Proxycurl are tighter than expected"). Reuses Bullhorn auth from Janitor (doesn't re-derisk Risk #2). Tier 2 so doesn't touch Risk #1 primitives |
docs/decisions/sequencing-target.md:153:| 4. Commercial value | **Medium** | Per Product Spec §2.2 R5: "Shortlist in 15 minutes instead of by end of week." Less commercially load-bearing than Janitor/Scribe/Concierge — request-response not always-on, so less of a closing-demo asset. Sales narrative is "cuts intake-call-to-first-shortlist time from same-week to same-hour" |
docs/decisions/sequencing-target.md:154:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Night Sourcer (v1.1) reuses Sourcing Scout's multi-source layer per Ultraplan §8.1 line 555 ("Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it") | Medium criticality (v1.1 downstream) |
docs/decisions/sequencing-target.md:155:| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn (already on if Janitor shipped) + LinkedIn (Proxycurl API key — single application-level key, not per-tenant) + Reed OAuth + CV-Library OAuth per tenant |
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:166:| 4. Commercial value | **Highest** | Per master brief §8.2 line 606: "First Tier-1 always-on closing demo; 4-week build." Product Spec §2.2 R7: 15-25% lift in placement-driven referral revenue ("post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table"). The flagship v1.0 closing demo |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:176:Three orderings evaluated against §1.3 criteria. **Option Alpha is the master-brief §8.2 canonical sequence** (correcting the §1.5 founder-prompt drift); Options Beta and Gamma are tested as alternatives.
docs/decisions/sequencing-target.md:178:### 3.1 — Option Alpha (canonical, master-brief §8.2)
docs/decisions/sequencing-target.md:182:W5:   Janitor (A2)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:193:- W5: Risk #2 (Bullhorn auth) — Janitor first writes. Reduction trigger 2 fires (Medium → Low per `bullhorn-integration-path.md` §6.7).
docs/decisions/sequencing-target.md:208:W5-8: Concierge (A6) — front-load the flagship (XL/4 weeks)
docs/decisions/sequencing-target.md:209:W9:   Janitor (A2)
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:229:W5:   Janitor (A2) — Risk #2 derisk
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:255:| 4. Commercial value | Tied (Diagnostic substrate, then flagship Concierge last; closing demo at W12-13 per Ultraplan §9 line 781) | Wins on raw timing (Concierge W5-8 demoable earlier) — but loses on substrate quality (Concierge ships with degraded Notes-for-context) | Tied — Concierge W6-9 marginally earlier than Alpha but with same substrate gaps as Beta |
docs/decisions/sequencing-target.md:256:| 5. Dependencies on other agents | **Wins** — Janitor's Bullhorn auth → Scribe reuses → Sourcing Scout reuses → Concierge reuses, all in dependency order | Loses — Concierge before Janitor + Scribe breaks the upstream chain | Loses — Concierge before Scribe breaks the upstream chain |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:314:**Trigger 3 — Hire #1 starts later than Week 7.** Per Ultraplan §9 line 766 verbatim caveat: "Hire #1 is assumed to start week 7 (verify, don't assume)":
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:374:4. **If scope-cut activates twice in one v1.0 cycle, escalate to v1.0 kill criterion** — the Day 5 work (master brief §6 Day 5) defines the kill-criterion threshold; sequencing failures count toward that threshold.
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:408:First exercise is Janitor at W5 per §4.1 row 2. **If Day 2 Sub-decisions A and B haven't flipped from Proposed to Accepted by start of W4** (per `bullhorn-integration-path.md` §1.3 commercial-blocker table), this is the natural blocker. Founder Sunday/Monday commercial conversations must land before W4 start to keep the Janitor W5 slot intact. Sub-decision C is already Accepted so the endpoint surface is buildable; the gate is auth path (A) and client_credentials foreclosure (B).
docs/decisions/sequencing-target.md:434:### 6.6 — For Day 5 (auto-send safety policy + kill criterion)
docs/decisions/sequencing-target.md:436:The Day 5 v1.0 kill criterion document must reference this sequencing for what "v1.0 fails" means. Concrete failure conditions implied by §4.3 + §5.3:
docs/decisions/sequencing-target.md:439:- **Janitor's first Bullhorn auth refresh fails by W5** (Risk #2 unmitigated; commercial path broken)
docs/decisions/sequencing-target.md:442:Day 5 kill-criterion artefact bakes these into its threshold definition.
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:493:| Gating-failure escalation | §5.3 | 1-week-fix-window → scope-cut contingency → kill-criterion threshold |
docs/decisions/sequencing-target.md:518:| §6.6 v1.0 kill criterion specifics | Formalised on Day 5 — this document's failure conditions are inputs to that work |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
docs/runbooks/operational-hygiene-protocol.md:260:Audit of citation accuracy across 4 main committed artefacts: Day-4 runbook, autosend-safety-policy.md, v1.0-kill-criterion.md, vertical-schema.yaml. Plus state files: RISK-REGISTER.md, current-priorities.md.
docs/runbooks/operational-hygiene-protocol.md:268:**Root cause:** Day-4 runbook §1.4 invented "master brief §10.4 cost target" during drafting. The citation propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1 instance), RISK-REGISTER (2 instances), current-priorities (1 instance) by trusting the Day-4 runbook citation rather than re-verifying against master brief. Citation transitivity, not master-brief drift.
docs/runbooks/operational-hygiene-protocol.md:276:| `docs/decisions/v1.0-kill-criterion.md` | 3 | Same cost-target replacement for Trigger 6/7 source citations |
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:82:| Janitor | `bullhorn_candidate_tag` | Adds a tag with `checked_at` date; reversible in <30s; high volume |
docs/decisions/autosend-safety-policy.md:92:| Janitor | `bullhorn_candidate_dedupe` | 1-in-10 | Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review |
docs/decisions/autosend-safety-policy.md:111:| Janitor | `bullhorn_placement_terminate` | Marks placement as terminated; commercial/legal implications; reversible only via support ticket |
docs/decisions/autosend-safety-policy.md:275:base + 15% bonus structure for the Senior PM role at Aragon Labs..."
docs/decisions/autosend-safety-policy.md:344:**Expected resolution:** IFOS oncall investigates within 1h during business hours; within 4h outside business hours. The affected tenant pilot may be PAUSED for that agent until policy is fixed (per `v1.0-kill-criterion.md` §2 trigger 5).
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/v1.0-kill-criterion.md:1:# v1.0 kill criterion
docs/decisions/v1.0-kill-criterion.md:8:**Path drift logged:** Master brief §6 Day 5 line 486 specifies `docs/v1-kill-criterion.md` (docs/ root). This artefact lives at `docs/decisions/v1.0-kill-criterion.md` per repo convention. Recorded as **Edit 10** in atomic-correction manifest (shared with autosend-safety-policy.md path drift).
docs/decisions/v1.0-kill-criterion.md:20:**KILL is reversible only as v1.1 or v2.0**: a wholly new initiative under different premises, with its own kill criterion. v1.0 itself does not resurrect.
docs/decisions/v1.0-kill-criterion.md:43:Each trigger has: measurable threshold, owner (detects), action (kill/pause/pivot), source justification.
docs/decisions/v1.0-kill-criterion.md:73:### Trigger 3 — JANITOR-BULLHORN-AUTH-W5 (PIVOT)
docs/decisions/v1.0-kill-criterion.md:75:**Threshold:** Janitor agent cannot authenticate to Bullhorn via the documented OAuth flow (per `bullhorn-integration-path.md` §4.5 refresh-loop architecture) by end of Week 5 (2026-06-28). Authentication failure modes that trigger: (a) OAuth token endpoint returns non-2xx persistently; (b) refresh-loop architecture fails at 10-minute TTL boundary; (c) Bullhorn rate-limits IFOS's auth endpoint preventing pilot operations; (d) Bullhorn partnership programme requirement blocks production-tenant access.
docs/decisions/v1.0-kill-criterion.md:85:- **Option C:** ATS-agnostic with manual data sync. Reduces v1.0 to read-only agent operation against ATS export files; loses much of the Janitor + Concierge value but unblocks pilot acquisition.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:158:### Trigger 8 — GATE-B-REVENUE-UPLIFT (KILL)
docs/decisions/v1.0-kill-criterion.md:204:**Day-5 restructure** (2026-05-18): Jack is high engagement on sales/commercial; founder is solo on product. This v1.0 kill criterion governs the **product domain**. Founder has SOLO authority for all trigger activations; Jack is informed-not-deciding. Commercial-domain kill criteria are deferred to a future artefact (placeholder: `v1.0-kill-criterion-commercial.md`).
docs/decisions/v1.0-kill-criterion.md:208:**Founder has SOLO authority for kill/pause/pivot decisions** on every trigger in this document.
docs/decisions/v1.0-kill-criterion.md:218:Commercial-side kill criteria — pilot pricing, customer acquisition strategy, sales pipeline kill thresholds — are out of scope for v1.0 product kill criterion. A future artefact (placeholder name: `v1.0-kill-criterion-commercial.md`) defines them with Jack as decision authority and founder informed. Scope boundary: anything that does not directly trigger product KILL/PAUSE/PIVOT belongs in the commercial document.
docs/decisions/v1.0-kill-criterion.md:227:- **Trigger 8 (Gate-B revenue) KILL:** founder decides KILL on revenue evidence; consults Jack on wind-down terms with existing pilots before 30-day notice goes out.
docs/decisions/v1.0-kill-criterion.md:322:4. v1.1 — if launched — is a wholly new initiative under different premises. Not a continuation of v1.0. Has its own master brief, Ultraplan, kill criterion.
docs/decisions/v1.0-kill-criterion.md:328:**This kill criterion governs v1.0 only.**
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:353:### v1.1 kill criterion
docs/decisions/v1.0-kill-criterion.md:355:**Defined in Week 4+ once v1.0 has at least one pilot operational.** v1.1 kill criterion will incorporate v1.0 learnings + v1.1-specific triggers (e.g., wiki UI usability scores, voice classifier drift rates, LoRA training cost-per-tenant).
docs/decisions/v1.0-kill-criterion.md:357:This v1.0 kill criterion does NOT govern v1.1. A v1.0 KILL terminates v1.0 only; v1.1 — if launched — is a new initiative under its own framework.
docs/decisions/v1.0-kill-criterion.md:364:- If v1.0 pilots are still on v1.0 commitments while v1.1 build proceeds, BOTH kill criteria apply to their respective scopes.
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
docs/decisions/v1.0-kill-criterion.md:377:**For Risk Register.** Triggers 1, 2, 3, 5, 6, 7, 9, 10 each correspond to existing register entries (Risks #1-#8 in some combination). Risk #3 is updated in this Day-5 commit to reflect the Day-5 status. Risk #4 (Hire #1) is implicitly linked to Trigger 4 (scope cuts). Codex Day-7 ratification reviews the alignment between kill criterion triggers and risk register entries.
docs/decisions/v1.0-kill-criterion.md:401:*End of kill criterion.*
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:27:Master brief §12 Risk #2 (Bullhorn auth path) — "Bullhorn MCP build takes longer than 1 week" — names this as one of the four risks that could kill v1.0. Tripwire: "End of week 3 status not 'core read endpoints working'" (master brief §12 row #2, Ultraplan §10 row #2). The mitigation is "Week 0 Day 2 on Bullhorn auth research" — i.e. this document. Without Sub-decisions A and B answered, Week 1 cannot begin scaffolding `packages/mcp-connectors/bullhorn/` because the connector's authentication path determines its scope and shape.
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:62:- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:105:| Janitor W5 build | A+B Accepted (commercial conversations complete) | Pending |
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:306:| Janitor Candidate sweep | Polling (full-table scan per sweep) | Nightly 02:00 | Initial sweep is bounded by per-tenant Candidate count; subsequent sweeps use `dateLastModified` filter to limit to changes-since-last-sweep |
docs/decisions/bullhorn-integration-path.md:307:| Janitor Note / ClientCorporation / JobOrder sweep | Polling | Nightly 02:00 | Same `dateLastModified` filter pattern |
docs/decisions/bullhorn-integration-path.md:334:| Janitor (nightly sweep) | 200-400 during active sweep window (concentrated 1-2 hour burst) | Burst-tolerant; bounded by tenant Candidate-count and `dateLastModified` filter efficiency |
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:460:**Reduction trigger 2 (Medium → Low):** first Bullhorn write lands cleanly in Week 3-4 Janitor agent build (the master brief §12 / Ultraplan §10 row #2 tripwire test "core read endpoints working" passes).
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |

exec
/bin/zsh -lc "nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '70,170p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '223,330p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
/bin/zsh -lc "rg --files | rg 'master|ULTRAPLAN|ultraplan|MASTER|sequencing-target|v0.2-supplement|agent.md"'$'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/cash-conductor/agent.md
agents/recruitment/scribe/agent.md
agents/recruitment/sourcing-scout/agent.md
agents/recruitment/janitor/agent.md
agents/recruitment/diagnostic/agent.md
agents/recruitment/concierge/agent.md
packages/agent-renderer/tests/fixtures/test-agent/agent.md
logs/codex-ratification/round-2-autonomous/docs_decisions_sequencing-target-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-v0-2-supplement-yaml.output.md
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/decisions/sequencing-target.md
docs/build-brief/00-MASTER-BRIEF.md
docs/specs/ULTRAPLAN.md
docs/_supplementary/PRD-autonomous-agent.md
legacy/v1/MASTER-INDEX.md
legacy/v1/docs/phase-1-poc-stack/proposal-builder/agent.md
legacy/v1/docs/phase-2-agent-suite/reporting-engine/agent.md
legacy/v1/docs/phase-2-agent-suite/client-onboarder/agent.md
legacy/v1/docs/phase-2-agent-suite/sop-writer/agent.md
legacy/v1/docs/phase-2-agent-suite/repurposer/agent.md
legacy/v1/docs/phase-2-agent-suite/lead-hunter/agent.md
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/agent.md
legacy/v1/docs/phase-2-agent-suite/librarian/agent.md
legacy/v1/docs/phase-2-agent-suite/caption-writer/agent.md
legacy/v1/docs/phase-2-agent-suite/hr-agent/agent.md
legacy/v1/docs/phase-2-agent-suite/content-creator/agent.md

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '495,516p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   495	- **External APIs:** Companies House API (free), LinkedIn (via Proxycurl or similar), basic HTTP fetch
   496	- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
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

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '580,615p'" in /Users/madsadmin/code/CortexOS
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
   611	git checkout -b agent/{name}                       # e.g. agent/janitor
   612	mkdir -p agents/recruitment/{name}/tests/fixtures/{01-primary,02-edge-case-{X},99-voice-drift-canary}
   613	
   614	# In Claude Code, work the bundle through 6 files in this order:
   615	# 1. README.md (2-min overview)

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '1,190p'" in /Users/madsadmin/code/CortexOS
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
   181	        required: false
   182	        source: IFOS-derived (operator-curated at rule authoring)
   183	        notes: |
   184	          Items: short string phrases. Examples of non-compliant text (the typical drift the rule prevents). Surfaced to the agent.
   185	    notes: |
   186	      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
   187	
   188	  # --------------------------------------------------------------------------
   189	  recent_edit:
   190	    description: |

exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '70,125p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba docs/decisions/sequencing-target.md | sed -n '1,90p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# v1.0 agent sequencing target — decision document
     2	
     3	**Date:** 2026-05-16 (Week 0, Day 3)
     4	**Status:** Accepted (Day 3 session close, 2026-05-16). Single-pass technical decision, no commercial gating.
     5	**Author:** Claude Code, founder decision logged 2026-05-16
     6	**Surfaced by:** Master brief §6 Day 3 (lines 469-473) — "Confirm or revise Ultraplan §9's 'close first 3 pilots fastest' → `.agents/decisions/sequencing-target.md`" (note: master brief §6 names `.agents/decisions/`; this document lives at `docs/decisions/sequencing-target.md` matching the convention established by ADR-001 through ADR-003 + bullhorn-integration-path.md — **Spec gap §1-A** flagged for atomic correction).
     7	**Submodule SHA referenced:** `c21fbfe991a0030ea055bd8e2389a0801a424383`
     8	
     9	**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
    10	
    11	---
    12	
    13	## Section 1 — Context and sequencing criteria
    14	
    15	### 1.1 — What we're deciding
    16	
    17	Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
    18	
    19	| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
    20	|---|---|---|---|---|
    21	| A1 | Diagnostic | 3-4 | LinkedIn + Companies House + scrape | "Sales tool — needed before any other agent matters" |
    22	| A2 | Janitor | 5 | Bullhorn MCP (R+W) | "First demoable inside-ATS result; day-30 before/after closes deals" |
    23	| A3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | "Post-call note in Bullhorn within 10 min — second-most-demoable" |
    24	| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
    25	| A5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | "First daytime always-on agent" |
    26	| A6 | Concierge | 10-13 | Bullhorn + MS Graph + AgentMail | "First Tier-1 always-on closing demo; 4-week build" |
    27	
    28	Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
    29	
    30	**Three sub-decisions in this document:**
    31	
    32	- **A. First agent.** Which agent ships first in Week 3-4? Anchors the renderer (ADR-003) + `_shared/` helpers (Week-1-2 prereqs from ADR-002) + Postgres `decision_log` (Day 4 Week 0) end-to-end test. Affects how risk surfaces — first agent is the smoke test for every substrate dependency.
    33	- **B. Sequence for agents 2-6.** The remaining five agents in some order across Weeks 5-13. Three candidate orderings compared in §3.
    34	- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
    35	
    36	### 1.2 — Why this matters now
    37	
    38	Three reasons the sequencing decision lands this week, not later:
    39	
    40	**Week 3 needs a starting agent.** The renderer (ADR-003) lands Week 1-2; `_shared/voice-loader.sh` + `hook-helpers.sh` land Week 1-2; Postgres `decision_log` lands Day 4 Week 0. By Week 3 the substrate is live and waiting for its first user. Without §A (first agent), Week 3 doesn't have a build target.
    41	
    42	**Weeks 5-13 planning is speculative without §B.** Each agent's prerequisites (Bullhorn MCP, Fathom/Fireflies, Xero, LinkedIn) have lead times. Bullhorn MCP work itself starts Week 1 per Ultraplan §9 line 724 ("Bullhorn MCP server is the critical path; week 1 starts on it"). Without knowing the agent build order, those infrastructure prereqs can't be sequenced.
    43	
    44	**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
    45	
    46	The Day-7 single-sentence test (master brief §6 Day 7 / Ultraplan §12) doesn't directly test sequencing — but Q4 ("Have we scoped the Agent Bundle v2 refactor and is the work <5 days?") and the Week-0 deliverable list at Ultraplan §9 line 737-741 both assume a sequenced plan exists. The Day 7 review surfaces this document for Codex ratification.
    47	
    48	### 1.3 — Sequencing criteria
    49	
    50	Six criteria to evaluate each agent against in §2. Each criterion scored High / Medium / Low or with a concrete number; substantive cells in §2 must justify the score by reference to master brief / Ultraplan / Product Spec / Day-2 Bullhorn decision.
    51	
    52	| # | Criterion | What it measures | Why it informs sequencing |
    53	|---|---|---|---|
    54	| 1 | **Implementation simplicity** | Lines of agent code in `agent.md` workflow + number of MCP servers touched + complexity of output contract (single-output vs multi-stage vs lifecycle-state) | Simpler agents land faster and exercise less substrate at once — better first-agent candidates because failure modes are easier to isolate |
    55	| 2 | **Substrate exercise** | Fraction of Week-1-2 substrate (renderer / `_shared/voice-loader.sh` / `_shared/hook-helpers.sh` / Postgres `decision_log` / `_secrets.env` / Bullhorn auth refresh-loop) the agent exercises | Higher substrate exercise = more value as smoke test for the substrate, but also higher risk of substrate-bug-attributed-to-agent confusion |
    56	| 3 | **Risk de-risking** | Which named risks the agent's success/failure surfaces — Risk #1 (cortextOS primitives), Risk #2 (Bullhorn auth), Risk #5 (renderer-not-built) — per `docs/RISK-REGISTER.md` | Building risk-surfacing agents earlier converts known-unknowns into known-knowns; building risk-deferring agents earlier preserves optionality but pushes the surprise window later |
    57	| 4 | **Commercial value** | Whether the agent's output is demoable to a design partner / first paying customer per Product Spec §2.2 R-rows | Earlier commercial-value agents accelerate the first-pilot conversion (Ultraplan §9 line 725 target Week 12); but commercial-value agents are typically the more complex ones, conflicting with criterion 1 |
    58	| 5 | **Dependencies on other agents** | Does this agent's output feed another agent? Does this agent require another agent's output to function? | Agents with downstream dependents should ship before their dependents; agents with no upstream dependencies are good first candidates |
    59	| 6 | **Tenant-onboarding readiness** | Can this agent be deployed to one tenant without all infrastructure being live? (E.g. does it need the wiki API in v1.0 weeks 11-13, or only the Week-1-2 substrate?) | Earlier-readiness agents can pilot in shadow mode against the first design partner before all v1.0 infra is complete |
    60	
    61	The six criteria intentionally tension against each other — implementation simplicity (1) trades off against commercial value (4); substrate exercise (2) trades off against risk-isolation (3). The §2 per-agent assessments make the trade-offs visible per agent; the §3 sequencing options weight them differently; the §4 recommendation picks one weighting.
    62	
    63	### 1.4 — Scope cuts and v1.0 minimum
    64	
    65	Per master brief §12 / Ultraplan §10 row #2 (the four-risks-that-kill-v1.0 table), the **documented v1.0 scope-cut contingency** is verbatim:
    66	
    67	> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
    68	
    69	There are actually **two named contingency paths**, corresponding to two different failing risks:
    70	
    71	- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
    72	- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
    73	
    74	Recommended sequence in §4 must remain **operationally coherent under both contingencies.** A sequence that breaks (e.g. one that ships Concierge before Janitor) would lose the Risk #2 contingency because dropping Janitor would orphan the already-shipped Concierge's data flow. The §4 recommendation explicitly validates against both contingencies.
    75	
    76	The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
    77	
    78	### 1.5 — One small but real finding before §2 begins
    79	
    80	Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
    81	
    82	Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
    83	
    84	**Section 4's recommendation evaluates both orderings** (founder-prompt-Alpha and master-brief-Alpha) against the §1.3 criteria, picks whichever wins on the merits, and explicitly aligns with the master brief by default unless rationale exists to revise it. This document is the "confirm or revise" decision per master brief §6 Day 3 line 471 — both options are on the table.
    85	
    86	---
    87	
    88	## Section 2 — Per-agent readiness assessment
    89	
    90	Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '188,280p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   188	  # --------------------------------------------------------------------------
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
   261	# ============================================================================
   262	# §2 — Pgvector index (1)
   263	# ============================================================================
   264	
   265	pgvector_indexes:
   266	
   267	  voice_samples_embedded:
   268	    description: |
   269	      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
   270	    table: voice_corpus_chunks                       # auxiliary table; see §3 migration SQL
   271	    column: embedding
   272	    dimensions: 1536                                 # text-embedding-3-small
   273	    distance_metric: cosine
   274	    index_type: hnsw                                 # HNSW preferred over IVFFlat for v1.0 corpus sizes (<10k chunks/tenant)
   275	    index_params:
   276	      m: 16
   277	      ef_construction: 64
   278	    notes: |
   279	      Per-tenant query pattern via RLS: SELECT * FROM voice_corpus_chunks WHERE tenant_slug = current_setting('app.current_tenant') ORDER BY embedding <=> $query_vec LIMIT 10. RLS predicate ensures cross-tenant isolation even if a developer forgets the WHERE clause.
   280	    v1_0_query_volume_estimate: 10-50 queries per agent session × ~5 active agents × 24/7 = ~10k queries/day/tenant (well within pgvector + HNSW comfortable load).

codex
The main risk is no longer the basic bundle shape; it is mismatches between the Janitor scaffold and the registered v0.2 voice/edit schema plus missing bundle prerequisites. I’m checking the local Janitor file line numbers so the verdict can cite exact locations.
exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/agent.md | sed -n '260,420p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
    42	- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold`)
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
    69	1. **Candidate merge** (`PUT /Candidate/{primary_id}` + cascade) — only when confidence ≥0.85 per Gate A; no merge if either candidate had Bullhorn activity in last 90 days without explicit review flag (per ULTRAPLAN A2 line 510 verbatim). Action type: **`bullhorn_candidate_dedupe`** (existing in autosend-policy.yaml line 69; yellow tier; sample_rate: 10).
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
    95	     tenant_adapters.config.janitor_last_run)
    96	   → hh_decision_output("janitor_scan", "tenant:<slug>", "<N> entities scanned")
    97	   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per §1.1.2 of v0.2 supplement)
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
   187	Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint; per Day-19 catalogue add at `escalation-codes.md` line 184) OR `ESC_DUPLICATE_DETECTED` (merge-confidence reject; existing line 127) per the failed condition. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (line 163) is NOT used by Janitor — that code is reserved for vertical-schema field-constraint violations at write-time.
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
   213	| `ESC_DUPLICATE_DETECTED` | Per catalogue trigger: dedup confidence ≥0.85 cases requiring human review (NOT used for <0.85 reject cases — those silently drop per Step 3 algorithm) | warn | operator_chat_id |
   214	| `ESC_GATE_B_MISS` | Either independent Gate-B threshold (dedup <15% OR field-completeness <10%) missed for 3 consecutive runs. NOT a composite — see §5 Gate B for the two-threshold rule. | warn | operator_chat_id |
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

exec
/bin/zsh -lc "rg -n \"decision_log.*outcome|outcome=.*approved_after_edit|approved_after_edit|decision_log\" docs agents packages -g '*.md' -g '*.yaml' -g '*.sql' | head -80" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/agent-renderer/templates/claude-md-preamble.md:44:- `memory/` — replaced by Postgres `decision_log` (writes via `hh_decision_*` helpers).
agents/_shared/README.md:24:`hook-helpers.sh` writes to `decision_log` via two paths:
agents/_shared/README.md:44:| `HH_POLICY_VERSION_SHA` | no | Git SHA stamped into `decision_log.payload.policy_version_sha` per §7 | `unknown` |
agents/_shared/README.md:56:`hh_decision_action` is the **gated** call. Returns `0` if action allowed, `1` if blocked or approval rejected. All three write a `decision_log` row before returning.
agents/_shared/README.md:63:autosend_emit_decision_log    <phase> <tier> <action_type> <target> <hash> <preview> <reason>
agents/_shared/README.md:122:3. Founder verifies via `psql` that one new row landed in `decision_log` with `phase='trigger'` + `tenant_slug='migration-test'`.
agents/_shared/README.md:125:   SELECT count(*) FROM decision_log
agents/_shared/autosend-policy.yaml:19:# Schema version stamps decision_log.payload.policy_version_sha at write time.
agents/_shared/autosend-policy.yaml:68:    reason: "Internal operator-only Telegram notification (escalations + run-complete markers); not customer-facing; idempotent within decision_log payload_hash dedup window"
agents/_shared/autosend-policy.yaml:74:    reason: "Internal run-complete status marker written to decision_log; no external comms; informational"
agents/_shared/autosend-policy.yaml:98:    reason: "Status marker recorded AFTER an external send completes (the send itself was a different orange/yellow action_type with its own decision_log row); this row closes the workflow trace"
agents/_shared/autosend-policy.yaml:129:    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:247:          Enum: ["approved_verbatim", "approved_after_edit", "rejected", "deferred"]. `deferred` indicates operator returned to inbox without resolving (4h timeout case).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
agents/recruitment/cash-conductor/agent.md:86:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:107:Each draft: `decision_log` row `agent_name='cash_conductor'`, `phase='output'`, `action_type='xero_reminder_draft_internal'` (registered yellow tier — but Cash Conductor escalates to orange-tier `xero_reminder_send_customer` for the actual customer-facing send routed via Concierge; this row is the draft itself, not the send), payload includes the draft.
agents/recruitment/cash-conductor/agent.md:193:     sent (counted from decision_log decision_log.payload.position)
agents/recruitment/cash-conductor/agent.md:241:    → query decision_log + accounting + bank feed for the 7-day window
packages/agent-renderer/tests/fixtures/test-agent/agent.md:5:Test-agent emits one structured `decision_log` row per invocation with phase
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:18:phase             — one of {trigger, output, action, gating_failed, agent_handoff}; per decision_log CHECK constraint at Day-4 §6.3
agents/_shared/escalation-codes.md:115:- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7
agents/_shared/escalation-codes.md:343:- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`
agents/_shared/escalation-codes.md:350:- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:355:- **Trigger:** Two agents attempted to send the same `payload_hash` within same tenant within `race_window_seconds` (default 60s); second attempt detected by `decision_log` UPSERT-conflict
agents/_shared/escalation-codes.md:366:- **Payload fields:** `action_type`, `original_decision_log_id`, `sample_rate`, `sampling_reason`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:462:1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
agents/recruitment/scribe/agent.md:82:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:43:**Disposition:** **Codex is correct.** Real bug. Step 11 sends a Telegram notification (an action with external side-effect) but doesn't emit a `decision_log` row. Mechanical fix: add `hh_decision_action("operator_notify_telegram", ...)` call to Step 11.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:189:2. `recent_edit` schema confusion — it's a v0.2 separate table, not a decision_log field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:217:4. Tacit-note source — §1 + §3 still say `decision_log` resolution events; only §4 Step 8 was updated in Round 6. Same `recent_edit` table confusion in different sections.
agents/recruitment/sourcing-scout/agent.md:96:Per `decision_log`: one row per source query + one row per candidate proposed + one final aggregate row.
docs/decisions/brain-ui-scope.md:6:**Surfaced by:** Master brief §6 Day 3 line 472 — "Brain UI v1.0 scope decision" + ADR-002 §3.4 closing paragraph (Brain UI explicitly forward-deferred to v1.1) + `second-brain-design.md` §3.4 ("Brain UI minimal v1 is built as a thin read-only page over `decision_log` — no new wiki API needed").
docs/decisions/brain-ui-scope.md:17:- **v1.0 minimum (weeks 11-13):** wiki API + Postgres tables (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector voice samples + 9 `wiki-*.sh` parallel wrappers + 9 `wiki/lib/*.ts` modules. **No Brain UI** — operational access via Obsidian + CLI + psql.
docs/decisions/brain-ui-scope.md:26:1. Which wiki operations get hit hardest in v1.0 (decision_log queries vs entity reads vs entity_links traversals) — informs which feature lands first in v1.1.
docs/decisions/brain-ui-scope.md:41:- Shows recent `decision_log` entries with phase + outcome filtering (`trigger | output | action | gating_failed | agent_handoff` per `sequencing-target.md` §5.3 + §6.5 enum extension).
docs/decisions/brain-ui-scope.md:53:**Likely implementation surface:** Next.js route at `/brain/today` (or equivalent), reading Postgres `decision_log` + `entities` + filesystem mtime on `/vault/<tenant>/wiki/raw/`. Auth model deferred to §3.
docs/decisions/brain-ui-scope.md:55:**Dependency on v1.0:** wiki API live + `decision_log` populated per ADR-002 §3 Decision 3 + extended phase enum per `sequencing-target.md` §6.5.
docs/decisions/brain-ui-scope.md:92:**Dependency on v1.0:** `wiki-find.sh` shipped in v1.1 itself (the wrapper isn't a v1.0 deliverable per ADR-003 §"Decision 3" wrapper table); `decision_log` + `entities` populated in v1.0.
docs/decisions/brain-ui-scope.md:142:- **`psql` against Postgres `decision_log`** for escalation review + audit trail — direct SQL queries, no UI layer.
docs/decisions/brain-ui-scope.md:152:- **`decision_log` audit trail** if asked — `psql` query showing per-agent decisions over time.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:23:--   - RLS policies on entities + entity_links + decision_log already in place
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:151:  resolution             TEXT        NOT NULL CHECK (resolution IN ('approved_verbatim', 'approved_after_edit', 'rejected', 'deferred')),
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:173:-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:59:| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:73:Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.
agents/recruitment/janitor/agent.md:137:     AND resolution='approved_after_edit' AND tenant_slug=$tenant
agents/recruitment/janitor/agent.md:138:   → join to decision_log only if action-context lookups needed
agents/recruitment/janitor/agent.md:151:   → SELECT from decision_log WHERE agent_name='janitor' AND created_at >
docs/decisions/autosend-approval-bridge-spec.md:185:| Postgres unreachable | Write bridge state to fallback JSONL at `/vault/_meta/autosend-bridge.jsonl`; same replay pattern as decision_log fallback |
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:78:  decision_log_rows_min: 4  # trigger + output + validate_gate_a_fail action + cleanup
agents/recruitment/diagnostic/fixtures/01-primary.yaml:97:expected_decision_log_rows:
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:95:expected_decision_log_rows:
docs/decisions/2026-05-18-codex-ratification-manifest.md:26:| 11 | `docs/runbooks/day-4-provisioning.md` | Executed | Verify §12 execution log (20 deviations + 8 v1.1 revisions); cross-check schema migration against decision_log.phase enum (live SQL at `c6734d1`) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:29:| 14 | Day-4 Postgres provisioning artefact | Embedded in #12 | Same review as #12 + verify 4 consolidated tightenings (entity_graph split, _secrets.env, decision_log.phase, entities.version) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:32:| 17 | `docs/decisions/v1.0-kill-criterion.md` + Day-5 close commit `c6734d1` | Proposed + audit log | Verify 10 binary triggers; verify §3 founder-solo authority structure; verify live SQL migration (decision_log.phase 5→6) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:274:| **~~11~~** | **DROPPED** | (was decision_log.phase enum already executed at `c6734d1`) | n/a |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:21:The subsequent design pass (`docs/architecture/second-brain-design.md`) went further. Q1.4 found that **no IFOS agent calls `kb-*`** — the IFOS Agent Bundle v2 (master brief §8.1) has no `MEMORY.md`, no heartbeat memory file, and uses Postgres `decision_log` for the persistence role cortextOS's KB fills. The §3.4 seam was designed to shadow calls our agents don't make. Q3 evaluated three interface options against the post-design constraints (§3.2 rubric) and recommended Option α — a parallel `packages/brain/bus-overrides/wiki-*.sh` surface with no shadowing of cortextOS's bus.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:46:| `wiki-history.sh` | entity-history (reads `decision_log`) | v1.1 |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:63:- **Postgres tables (v1.0):** `tenants`, `entities`, `entity_links`, `decision_log` — schemas in design §2.4.2. RLS by tenant_slug on every table except `tenants`. The Ultraplan §5.1 line 227 single `entity_graph` table is **split** into `entities` (one row per entity) and `entity_links` (adjacency) — see Spec gap 2.4-B in the design doc.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:93:> "v1.0 minimum (weeks 11-13) — 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; no Brain UI yet. Total v1.0 effort ~11-13 person-days. v1.1 adds `wiki-find.sh` + `wiki-history.sh` + Brain UI today-view and backlinks panel."
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:99:> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:103:> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."
docs/decisions/sequencing-target.md:32:- **A. First agent.** Which agent ships first in Week 3-4? Anchors the renderer (ADR-003) + `_shared/` helpers (Week-1-2 prereqs from ADR-002) + Postgres `decision_log` (Day 4 Week 0) end-to-end test. Affects how risk surfaces — first agent is the smoke test for every substrate dependency.
docs/decisions/sequencing-target.md:40:**Week 3 needs a starting agent.** The renderer (ADR-003) lands Week 1-2; `_shared/voice-loader.sh` + `hook-helpers.sh` land Week 1-2; Postgres `decision_log` lands Day 4 Week 0. By Week 3 the substrate is live and waiting for its first user. Without §A (first agent), Week 3 doesn't have a build target.
docs/decisions/sequencing-target.md:55:| 2 | **Substrate exercise** | Fraction of Week-1-2 substrate (renderer / `_shared/voice-loader.sh` / `_shared/hook-helpers.sh` / Postgres `decision_log` / `_secrets.env` / Bullhorn auth refresh-loop) the agent exercises | Higher substrate exercise = more value as smoke test for the substrate, but also higher risk of substrate-bug-attributed-to-agent confusion |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |

codex
REJECTED

1. Schema-before-code violation for `candidate.linkedin_url`. Lines 99-101 and 128-132 use `candidate.linkedin_url`, but `vertical-schema.yaml` candidate fields list no `linkedin_url` field in lines 57-147. Add the field to the schema first or remove LinkedIn from the Janitor v1.0 matching/enrichment flow.

2. Tacit-note source is inconsistent with the v0.2 schema. Lines 16, 59, and 71 say tacit notes come from `decision_log` resolution events / `outcome='approved_after_edit'`, but `approved_after_edit` is a `recent_edit.resolution` value in `vertical-schema.v0.2-supplement.yaml` lines 242-248, not a `decision_log.outcome` field. Rewrite these sections to use `recent_edit.resolution='approved_after_edit'` consistently.

3. Janitor assumes access to v0.2 voice/edit tables that are not registered for Janitor. Line 230 uses `tone_rule` filtered for `janitor`, and lines 134-139 query `recent_edit`; the supplement’s `tone_rule.v1_0_agent_access` names Scribe/Cash Conductor/Concierge only, and `recent_edit.v1_0_agent_access` names voice-drift-canary/Concierge/LoRA only. Either add Janitor access in the v0.2 supplement or remove these reads from Janitor.

4. §8 omits required sibling bundle prerequisites. Lines 257-261 list `validate.sh`, `context.sh`, `cycle.sh`, and fixtures, but the agent-bundle skill requires pre-build scaffolds to name the sibling files, including `tools.yaml` and `cleanup.sh`. Add both to the W5 prerequisite table with status and build ownership.

5. Escalation code usage conflicts with the catalogue. Line 187 says Gate A failures can fire `ESC_DUPLICATE_DETECTED`, but the catalogue defines that code for dedup confidence `≥0.85` human-review cases, not sub-threshold rejects; line 213 then says Janitor does not use it for `<0.85`, contradicting line 187. Route low-confidence rejects to no-op/drop or a distinct registered code, and reserve `ESC_DUPLICATE_DETECTED` for the catalogue trigger.

6. Citation accuracy failure for autosend policy line references. Line 69 claims `bullhorn_candidate_dedupe` exists at `autosend-policy.yaml line 69`, but the actual action type is at `agents/_shared/autosend-policy.yaml` lines 111-116; line 69 is `irreversible: false` for `operator_notify_telegram`. Correct the cited line references for all autosend action types.
tokens used
77,459
REJECTED

1. Schema-before-code violation for `candidate.linkedin_url`. Lines 99-101 and 128-132 use `candidate.linkedin_url`, but `vertical-schema.yaml` candidate fields list no `linkedin_url` field in lines 57-147. Add the field to the schema first or remove LinkedIn from the Janitor v1.0 matching/enrichment flow.

2. Tacit-note source is inconsistent with the v0.2 schema. Lines 16, 59, and 71 say tacit notes come from `decision_log` resolution events / `outcome='approved_after_edit'`, but `approved_after_edit` is a `recent_edit.resolution` value in `vertical-schema.v0.2-supplement.yaml` lines 242-248, not a `decision_log.outcome` field. Rewrite these sections to use `recent_edit.resolution='approved_after_edit'` consistently.

3. Janitor assumes access to v0.2 voice/edit tables that are not registered for Janitor. Line 230 uses `tone_rule` filtered for `janitor`, and lines 134-139 query `recent_edit`; the supplement’s `tone_rule.v1_0_agent_access` names Scribe/Cash Conductor/Concierge only, and `recent_edit.v1_0_agent_access` names voice-drift-canary/Concierge/LoRA only. Either add Janitor access in the v0.2 supplement or remove these reads from Janitor.

4. §8 omits required sibling bundle prerequisites. Lines 257-261 list `validate.sh`, `context.sh`, `cycle.sh`, and fixtures, but the agent-bundle skill requires pre-build scaffolds to name the sibling files, including `tools.yaml` and `cleanup.sh`. Add both to the W5 prerequisite table with status and build ownership.

5. Escalation code usage conflicts with the catalogue. Line 187 says Gate A failures can fire `ESC_DUPLICATE_DETECTED`, but the catalogue defines that code for dedup confidence `≥0.85` human-review cases, not sub-threshold rejects; line 213 then says Janitor does not use it for `<0.85`, contradicting line 187. Route low-confidence rejects to no-op/drop or a distinct registered code, and reserve `ESC_DUPLICATE_DETECTED` for the catalogue trigger.

6. Citation accuracy failure for autosend policy line references. Line 69 claims `bullhorn_candidate_dedupe` exists at `autosend-policy.yaml line 69`, but the actual action type is at `agents/_shared/autosend-policy.yaml` lines 111-116; line 69 is `irreversible: false` for `operator_notify_telegram`. Correct the cited line references for all autosend action types.
