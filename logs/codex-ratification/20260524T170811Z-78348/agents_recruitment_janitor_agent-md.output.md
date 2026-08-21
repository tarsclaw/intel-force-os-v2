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
session id: 019e5af5-66ee-7ab2-92d7-195305e69014
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
I’ll verify the cited source files and bundle context against the supplied ratification rules, focusing on citation accuracy, schema/policy references, and boundary violations.
exec
/bin/zsh -lc "rg --files | rg '("'^agents/_shared/|docs/|vertical-schema|autosend|ULTRAPLAN|master|kill|sequencing|bullhorn|janitor/agent.md)'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
skills-lock.json
docs/runbooks/day-4-provisioning.md
docs/runbooks/operational-hygiene-protocol.md
docs/runbooks/tenant-lifecycle.md
docs/runbooks/pii-purge-operational-pattern.md
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md
docs/artefacts/diagnostic-hays-plc-2026-05-24.md
docs/build-brief/00-MASTER-BRIEF.md
docs/specs/ULTRAPLAN.md
docs/specs/_archive-build-handoff.md
docs/specs/PRODUCT-SPEC.md
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
agents/_shared/README.md
docs/_supplementary/PRD-autonomous-agent.md
docs/_supplementary/build-plan-original.md
docs/_supplementary/README.md
docs/_supplementary/strategic-plan.md
docs/_supplementary/planning-phase-brief.md
docs/_supplementary/technical-strategy-v2.md
docs/_supplementary/execution-plan.md
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
docs/architecture/tenancy-invariants.md
docs/architecture/architecture-cohesion-review.md
docs/architecture/agent-bundle-renderer-design.md
docs/architecture/cortexos-kb-surface-investigation.md
docs/architecture/cortexos-primitive-status.md
docs/architecture/vault-concurrency.md
docs/architecture/second-brain-design.md
agents/recruitment/janitor/agent.md
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
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/decisions/sequencing-target.md
docs/decisions/bullhorn-integration-path.md
docs/RISK-REGISTER.md
docs/design-mockups/brain-ui-decisions-feed-light-v01.html
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/operations/bullhorn-outreach-emails.md
docs/operations/codex-ratification-guide.md
docs/operations/codex-round-2-handoff.md
docs/operations/codex-round-2-remediation-prompt.md
docs/operations/codex-ratification-execution-plan.md
docs/operations/codex-round-2-autonomous-prompt.md
docs/operations/goal-week-3-polish-and-scaffold.md
docs/operations/seedlegals-engagement-queries.md
docs/operations/goal-option-c-diagnostic-end-to-end.md
docs/operations/founder-legal-setup-guide.md
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
logs/codex-ratification/20260524T133645Z-99130/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T133645Z-99130/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T133645Z-99130/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140718Z-31055/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T133053Z-92743/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T133053Z-92743/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T133053Z-92743/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134204Z-4775/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134012Z-2539/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135714Z-19096/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T141337Z-37011/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T141337Z-37011/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141337Z-37011/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140421Z-27988/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/manual-run/docs_decisions_sequencing_target_md.output.md
logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md
logs/codex-ratification/manual-run/docs_decisions_v1_0_kill_criterion_md.output.md
logs/codex-ratification/manual-run/docs_decisions_bullhorn_integration_path_md.output.md
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141157Z-35106/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
packages/harness/cortextos/src/cli/list-skills.ts
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T131901Z-80999/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
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
packages/harness/cortextos/tests/unit/skills/cron-management-skill.test.ts
packages/harness/cortextos/community/skills/delegation-matrix/SKILL.md
packages/harness/cortextos/community/skills/onboarding/SKILL.md
packages/harness/cortextos/dashboard/src/lib/actions/skills.ts
packages/harness/cortextos/community/skills/nighttime-mode/SKILL.md
packages/harness/cortextos/community/skills/theta-wave/SKILL.md
packages/harness/cortextos/community/skills/cron-management/SKILL.md
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T132739Z-89086/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
packages/harness/cortextos/community/skills/approvals/SKILL.md
packages/harness/cortextos/community/skills/activity-channel/SKILL.md
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135302Z-14058/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
packages/harness/cortextos/community/skills/community-publish/SKILL.md
packages/harness/cortextos/community/skills/catalog-browse/SKILL.md
packages/harness/cortextos/community/skills/goal-management/SKILL.md
packages/harness/cortextos/bus/list-skills.sh
packages/harness/cortextos/community/skills/event-logging/SKILL.md
packages/harness/cortextos/community/skills/worker-agents/SKILL.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T141652Z-40348/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135120Z-11731/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
packages/harness/cortextos/community/skills/opencli/SKILL.md
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135955Z-21837/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
packages/harness/cortextos/community/skills/knowledge-base/SKILL.md
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140156Z-24943/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/round-3-remediation/docs_decisions_bullhorn-integration-path-md.output.md
logs/codex-ratification/round-3-remediation/docs_decisions_codex-disagreement-2026-05-20-bullhorn-week-1-gate-md.output.md
logs/codex-ratification/round-3-remediation/docs_decisions_autosend-approval-bridge-spec-md.output.md
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134556Z-7679/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
packages/harness/cortextos/community/skills/heartbeat/SKILL.md
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md
packages/harness/cortextos/dashboard/src/components/skills/skills-grid.tsx
packages/harness/cortextos/dashboard/src/components/skills/skill-card.tsx
logs/codex-ratification/round-2-autonomous/docs_decisions_v1-0-kill-criterion-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_sequencing-target-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_bullhorn-integration-path-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_codex-disagreement-2026-05-20-bullhorn-week-1-gate-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-v0-2-supplement-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-approval-bridge-spec-md.output.md
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md
packages/harness/cortextos/community/skills/upstream-sync/SKILL.md
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T132441Z-86597/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T135534Z-17024/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T140933Z-33645/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
packages/harness/cortextos/community/skills/evening-review/SKILL.md
packages/harness/cortextos/community/skills/local-ultrareview/SKILL.md
packages/harness/cortextos/community/skills/local-version-control/SKILL.md
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T133407Z-96067/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.prompt.md
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.output.md
logs/codex-ratification/20260524T134900Z-9858/docs_verticals_recruitment_vertical-schema-v0-3-supplement-yaml.verdict.txt
packages/harness/cortextos/community/skills/comms/SKILL.md
packages/harness/cortextos/community/skills/.gitkeep
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md
packages/harness/cortextos/community/skills/weekly-review/SKILL.md
packages/harness/cortextos/community/skills/system-diagnostics/SKILL.md
packages/harness/cortextos/community/skills/memory/SKILL.md
packages/harness/cortextos/community/skills/agent-management/SKILL.md
packages/harness/cortextos/community/skills/morning-review/SKILL.md
legacy/v1/docs/phase-1-poc-stack/SESSION-SUMMARY.md
legacy/v1/docs/phase-1-poc-stack/platform-specs/webhook-receiver-spec.md
legacy/v1/docs/phase-1-poc-stack/platform-specs/tenant-container-spec.md
legacy/v1/docs/phase-1-poc-stack/platform-specs/minimal-vault-structure.md
packages/harness/cortextos/community/skills/tasks/SKILL.md
legacy/v1/docs/phase-1-poc-stack/runbooks/week-1-experiment-runbook.md
packages/harness/cortextos/community/skills/autoresearch/SKILL.md
packages/harness/cortextos/community/skills/officecli/SKILL.md
legacy/v1/docs/phase-1-poc-stack/proposal-builder/config.schema.json
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tools.yaml
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md
packages/harness/cortextos/community/skills/human-tasks/SKILL.md
legacy/v1/docs/phase-0-strategic/intelforce-dashboard.jsx
legacy/v1/docs/phase-0-strategic/intelforce-ai-os-strategic-plan.md
legacy/v1/docs/phase-0-strategic/ARCHITECTURE-OVERVIEW.md
legacy/v1/docs/phase-0-strategic/intelforce-build-plan.md
legacy/v1/docs/phase-0-strategic/intelforce-execution-plan.md
legacy/v1/docs/phase-0-strategic/intelforce-technical-strategy-v2.md
legacy/v1/docs/phase-0-strategic/intelforce-planning-phase-brief.md
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tests/fixtures/02-multi-service-ambiguous/transcript.json
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tests/fixtures/02-multi-service-ambiguous/expected.md
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tests/fixtures/03-budget-mismatch/transcript.json
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tests/fixtures/03-budget-mismatch/expected.md
legacy/v1/docs/phase-3-platform/services/vault-search-spec.md
legacy/v1/docs/phase-3-platform/services/escalation-notifier-spec.md
legacy/v1/docs/phase-3-platform/PHASE-3-SUMMARY.md
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tests/fixtures/01-dental-clear-fit/transcript.json
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tests/fixtures/01-dental-clear-fit/expected.md
legacy/v1/docs/phase-1-poc-stack/proposal-builder/validate.sh
legacy/v1/docs/phase-1-poc-stack/proposal-builder/context.sh
legacy/v1/docs/phase-1-poc-stack/proposal-builder/agent.md
legacy/v1/docs/phase-3-platform/postgres/schema-spec.md
legacy/v1/docs/build-kit/CLAUDE.md
legacy/v1/docs/build-kit/00-HOW-TO-PROCEED.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/onboarding/SKILL.md
legacy/v1/docs/phase-3-platform/postgres/migrations/20260422_001_initial.sql
legacy/v1/docs/phase-6-ops-runbooks/PHASE-6-SUMMARY.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/nighttime-mode/SKILL.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/theta-wave/SKILL.md
legacy/v1/docs/phase-6-ops-runbooks/routines/cost-governance-runbook.md
legacy/v1/docs/phase-6-ops-runbooks/routines/backup-verification-and-dr-drills.md
legacy/v1/docs/phase-6-ops-runbooks/routines/secret-rotation-runbook.md
legacy/v1/docs/phase-3-platform/observability/observability-spec.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/guardrails-reference/SKILL.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/cron-management/SKILL.md
legacy/v1/docs/phase-3-platform/provisioning/provisioning-system-spec.md
legacy/v1/docs/phase-5-business-legal/billing/stripe-integration-spec.md
legacy/v1/docs/phase-6-ops-runbooks/compliance/breach-response-runbook.md
legacy/v1/docs/phase-6-ops-runbooks/compliance/gdpr-dsar-and-deletion-runbook.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/approvals/SKILL.md
legacy/v1/docs/phase-5-business-legal/pricing/pricing-spec.md
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/crm-management/SKILL.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/activity-channel/SKILL.md
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/pending-items-summary/SKILL.md
legacy/v1/docs/phase-5-business-legal/legal/msa-template.md
legacy/v1/docs/phase-5-business-legal/legal/sla-spec.md
legacy/v1/docs/phase-5-business-legal/legal/privacy-and-terms-spec.md
legacy/v1/docs/phase-5-business-legal/legal/dpa-template.md
legacy/v1/docs/phase-5-business-legal/legal/acceptable-use-policy.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/goal-management/SKILL.md
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/tool-discovery/SKILL.md
legacy/v1/docs/phase-5-business-legal/marketing/trademark-filing-brief.md
legacy/v1/docs/phase-5-business-legal/marketing/brand-identity-spec.md
legacy/v1/docs/phase-5-business-legal/marketing/landing-page-spec.md
legacy/v1/docs/phase-3-platform/secrets/secrets-vault-spec.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/event-logging/SKILL.md
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/meeting-prep/SKILL.md
legacy/v1/docs/phase-5-business-legal/api/rest-api-spec.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/worker-agents/SKILL.md
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/email-triage/SKILL.md
legacy/v1/docs/phase-5-business-legal/playbooks/sales-playbook.md
legacy/v1/docs/phase-5-business-legal/playbooks/case-study-playbook.md
legacy/v1/docs/phase-5-business-legal/PHASE-5-SUMMARY.md
legacy/v1/docs/phase-3-platform/dr/backup-and-dr-runbook.md
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/calendar-management/SKILL.md
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/agentic-crm-setup/SKILL.md
legacy/v1/docs/phase-6-ops-runbooks/runbooks/platform-service-incidents.md
legacy/v1/docs/phase-6-ops-runbooks/runbooks/postgres-incidents.md
legacy/v1/docs/phase-6-ops-runbooks/runbooks/deploy-and-rollback.md
legacy/v1/docs/phase-6-ops-runbooks/runbooks/tenant-incidents.md
legacy/v1/docs/gtm-pack/04-outreach-templates.md
legacy/v1/docs/gtm-pack/03-prospect-tracker-template.csv
legacy/v1/docs/gtm-pack/06-pricing-sheet.md
legacy/v1/docs/gtm-pack/02-landing-page-hero-notes.md
legacy/v1/docs/gtm-pack/README.md
legacy/v1/docs/gtm-pack/01-demo-script.md
legacy/v1/docs/gtm-pack/02-landing-page-hero.html
legacy/v1/docs/gtm-pack/05-manual-service-runbook.md
legacy/v1/docs/gtm-pack/03-prospecting-framework.md
legacy/v1/docs/phase-6-ops-runbooks/incident-response/incident-response-runbook.md
legacy/v1/docs/phase-6-ops-runbooks/incident-response/on-call-handbook.md
legacy/v1/docs/phase-6-ops-runbooks/incident-response/severity-classification-and-comms.md
legacy/v1/docs/teams-hr-agent/04-deployment-guide.md
legacy/v1/docs/teams-hr-agent/05-productisation-playbook.md
legacy/v1/docs/teams-hr-agent/06-adaptive-card-examples.json
legacy/v1/docs/teams-hr-agent/01-architecture-overview.md
legacy/v1/docs/teams-hr-agent/03-azure-bootstrap-via-claude-code.md
legacy/v1/docs/teams-hr-agent/02-component-design.md
legacy/v1/docs/teams-hr-agent/README.md
legacy/v1/docs/teams-hr-agent/07-claude-code-prompts.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/env-management/SKILL.md
packages/harness/cortextos/dashboard/src/app/(dashboard)/skills/page.tsx
packages/harness/cortextos/templates/orchestrator/.claude/skills/knowledge-base/SKILL.md
legacy/v1/docs/phase-4-dashboard/views/operations-control-spec.md
legacy/v1/docs/phase-4-dashboard/views/settings-spec.md
legacy/v1/docs/phase-4-dashboard/views/agency-partner-portal-spec.md
legacy/v1/docs/phase-4-dashboard/views/brain-view-spec.md
legacy/v1/docs/phase-4-dashboard/views/activity-log-and-audit-spec.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/heartbeat/SKILL.md
legacy/v1/docs/phase-2-agent-suite/00-PATTERN-REFERENCE.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md
legacy/v1/docs/phase-4-dashboard/api/trpc-router-spec.md
legacy/v1/docs/phase-4-dashboard/PHASE-4-SUMMARY.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/bus-reference/SKILL.md
legacy/v1/docs/phase-2-agent-suite/reporting-engine/config.schema.json
legacy/v1/docs/phase-2-agent-suite/reporting-engine/README.md
legacy/v1/docs/phase-2-agent-suite/reporting-engine/tools.yaml
legacy/v1/docs/phase-4-dashboard/architecture/design-system-spec.md
legacy/v1/docs/phase-4-dashboard/architecture/dashboard-architecture-spec.md
legacy/v1/docs/phase-4-dashboard/architecture/auth-and-authorization-spec.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/evening-review/SKILL.md
legacy/v1/docs/phase-4-dashboard/wizard/configuration-wizard-spec.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/comms/SKILL.md
legacy/v1/docs/phase-2-agent-suite/repurposer/config.schema.json
legacy/v1/docs/phase-2-agent-suite/repurposer/README.md
legacy/v1/docs/phase-2-agent-suite/repurposer/tools.yaml
packages/harness/cortextos/templates/orchestrator/.claude/skills/tool-registration/SKILL.md
legacy/v1/docs/phase-2-agent-suite/reporting-engine/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/reporting-engine/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-2-agent-suite/reporting-engine/validate.sh
legacy/v1/docs/phase-2-agent-suite/reporting-engine/context.sh
legacy/v1/docs/phase-2-agent-suite/reporting-engine/agent.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/soul-philosophy/SKILL.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/weekly-review/SKILL.md
legacy/v1/docs/phase-2-agent-suite/_shared/escalation-codes.md
legacy/v1/docs/phase-2-agent-suite/_shared/hook-helpers.sh
legacy/v1/docs/phase-2-agent-suite/_shared/universal-banned-phrases.txt
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/relationship-review/SKILL.md
legacy/v1/docs/phase-2-agent-suite/repurposer/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/repurposer/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-2-agent-suite/repurposer/validate.sh
legacy/v1/docs/phase-2-agent-suite/repurposer/context.sh
legacy/v1/docs/phase-2-agent-suite/repurposer/agent.md
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/delegation-matrix/SKILL.md
legacy/v1/docs/phase-2-agent-suite/client-onboarder/config.schema.json
legacy/v1/docs/phase-2-agent-suite/client-onboarder/README.md
legacy/v1/docs/phase-2-agent-suite/client-onboarder/tools.yaml
packages/harness/cortextos/templates/orchestrator/.claude/skills/system-diagnostics/SKILL.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-management/SKILL.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/tasks/SKILL.md
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/config.schema.json
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/README.md
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/tools.yaml
packages/harness/cortextos/templates/analyst/.claude/skills/onboarding/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/guardrails-reference/SKILL.md
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/tests/fixtures/01-primary/expected.md
packages/harness/cortextos/templates/analyst/.claude/skills/cron-management/SKILL.md
legacy/v1/docs/phase-2-agent-suite/client-onboarder/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/client-onboarder/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-2-agent-suite/client-onboarder/validate.sh
legacy/v1/docs/phase-2-agent-suite/client-onboarder/context.sh
legacy/v1/docs/phase-2-agent-suite/client-onboarder/agent.md
legacy/v1/docs/phase-2-agent-suite/README.md
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/validate.sh
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/context.sh
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/agent.md
packages/harness/cortextos/templates/analyst/.claude/skills/approvals/SKILL.md
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/activity-channel/SKILL.md
legacy/v1/docs/phase-2-agent-suite/sop-writer/config.schema.json
legacy/v1/docs/phase-2-agent-suite/sop-writer/README.md
legacy/v1/docs/phase-2-agent-suite/sop-writer/tools.yaml
legacy/v1/docs/phase-2-agent-suite/caption-writer/config.schema.json
legacy/v1/docs/phase-2-agent-suite/caption-writer/README.md
legacy/v1/docs/phase-2-agent-suite/caption-writer/tools.yaml
packages/harness/cortextos/templates/analyst/.claude/skills/community-publish/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/catalog-browse/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/event-logging/SKILL.md
packages/harness/cortextos/community/agents/security/skills/drafts/.gitkeep
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-browser/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/worker-agents/SKILL.md
packages/harness/cortextos/community/agents/security/skills/archive/.gitkeep
packages/harness/cortextos/templates/orchestrator/.claude/skills/human-tasks/SKILL.md
legacy/v1/docs/phase-2-agent-suite/sop-writer/tests/fixtures/01-primary/input.json
packages/harness/cortextos/templates/analyst/.claude/skills/env-management/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/comms/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/knowledge-base/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/tool-registration/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/heartbeat/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/onboarding/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/soul-philosophy/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/guardrails-reference/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/cron-management/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/upstream-sync/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/system-diagnostics/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/approvals/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/bus-reference/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/memory/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/activity-channel/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/local-version-control/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/agent-management/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/event-logging/SKILL.md
legacy/v1/docs/phase-2-agent-suite/sop-writer/tests/fixtures/01-primary/expected.md
packages/harness/cortextos/community/agents/security/.claude/skills/worker-agents/SKILL.md
legacy/v1/docs/phase-2-agent-suite/sop-writer/validate.sh
legacy/v1/docs/phase-2-agent-suite/sop-writer/context.sh
legacy/v1/docs/phase-2-agent-suite/sop-writer/agent.md
packages/harness/cortextos/templates/analyst/.claude/skills/tasks/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/env-management/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/onboarding/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/knowledge-base/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/autoresearch/SKILL.md
legacy/v1/docs/phase-2-agent-suite/caption-writer/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/caption-writer/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-2-agent-suite/caption-writer/validate.sh
legacy/v1/docs/phase-2-agent-suite/caption-writer/context.sh
legacy/v1/docs/phase-2-agent-suite/caption-writer/agent.md
packages/harness/cortextos/community/agents/security/.claude/skills/agent-management/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/guardrails-reference/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/heartbeat/SKILL.md
legacy/v1/docs/phase-2-agent-suite/PHASE-2-SUMMARY.md
packages/harness/cortextos/community/agents/security/.claude/skills/tasks/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/cron-management/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/bus-reference/SKILL.md
legacy/v1/docs/phase-2-agent-suite/content-creator/config.schema.json
legacy/v1/docs/phase-2-agent-suite/content-creator/README.md
legacy/v1/docs/phase-2-agent-suite/content-creator/tools.yaml
packages/harness/cortextos/community/agents/security/.claude/skills/comms/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/approvals/SKILL.md
packages/harness/cortextos/skills/cron-management/SKILL.md
packages/harness/cortextos/templates/analyst/.claude/skills/agent-browser/SKILL.md
packages/harness/cortextos/skills/mcp-integration/SKILL.md
packages/harness/cortextos/dashboard/src/app/api/skills/route.ts
packages/harness/cortextos/templates/analyst/.claude/skills/human-tasks/SKILL.md
packages/harness/cortextos/skills/web-research/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/activity-channel/SKILL.md
packages/harness/cortextos/skills/comms/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/agent-management/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/event-logging/SKILL.md
legacy/v1/docs/phase-2-agent-suite/content-creator/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/content-creator/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-2-agent-suite/content-creator/validate.sh
legacy/v1/docs/phase-2-agent-suite/content-creator/context.sh
legacy/v1/docs/phase-2-agent-suite/content-creator/agent.md
packages/harness/cortextos/skills/tool-use-patterns/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/tasks/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/worker-agents/SKILL.md
packages/harness/cortextos/skills/prompt-engineering/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md
legacy/v1/docs/phase-2-agent-suite/lead-hunter/config.schema.json
legacy/v1/docs/phase-2-agent-suite/lead-hunter/README.md
legacy/v1/docs/phase-2-agent-suite/lead-hunter/tools.yaml
packages/harness/cortextos/skills/tasks/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/agent-browser/SKILL.md
packages/harness/cortextos/skills/claude-api-helper/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/human-tasks/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/auto-skill/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/bus-reference/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/system-diagnostics/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/soul-philosophy/SKILL.md
legacy/v1/docs/phase-2-agent-suite/lead-hunter/agent.md
packages/harness/cortextos/templates/agent/.claude/skills/heartbeat/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/env-management/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/comms/SKILL.md
legacy/v1/docs/phase-2-agent-suite/hr-agent/config.schema.json
legacy/v1/docs/phase-2-agent-suite/hr-agent/tools.yaml
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/onboarding/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/knowledge-base/SKILL.md
legacy/v1/docs/phase-2-agent-suite/lead-hunter/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/lead-hunter/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-2-agent-suite/lead-hunter/validate.sh
legacy/v1/docs/phase-2-agent-suite/lead-hunter/context.sh
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/guardrails-reference/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/human-tasks/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/tool-registration/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/cron-management/SKILL.md
legacy/v1/docs/phase-2-agent-suite/hr-agent/tests/fixtures/01-holiday-policy/input.json
legacy/v1/docs/phase-2-agent-suite/hr-agent/tests/fixtures/01-holiday-policy/expected.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/approvals/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/tool-registration/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/soul-philosophy/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/agent-browser/SKILL.md
legacy/v1/docs/phase-2-agent-suite/hr-agent/tests/fixtures/02-grievance-escalation/input.json
legacy/v1/docs/phase-2-agent-suite/hr-agent/tests/fixtures/02-grievance-escalation/expected.md
legacy/v1/docs/phase-2-agent-suite/hr-agent/agent.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/activity-channel/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/soul-philosophy/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/auto-skill/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/memory/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/event-logging/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md
legacy/v1/docs/phase-2-agent-suite/librarian/config.schema.json
legacy/v1/docs/phase-2-agent-suite/librarian/README.md
legacy/v1/docs/phase-2-agent-suite/librarian/tools.yaml
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/auto-skill/SKILL.md
packages/harness/cortextos/templates/agent/.claude/skills/system-diagnostics/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-browser/SKILL.md
legacy/v1/docs/phase-2-agent-suite/librarian/context.sh
legacy/v1/docs/phase-2-agent-suite/librarian/agent.md
legacy/v1/docs/phase-2-agent-suite/librarian/validate.sh
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/worker-agents/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/system-diagnostics/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/human-tasks/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/env-management/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/tasks/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md
legacy/v1/docs/phase-2-agent-suite/librarian/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/librarian/tests/fixtures/01-primary/expected.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/comms/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/knowledge-base/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/bus-reference/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/heartbeat/SKILL.md
packages/harness/cortextos/community/agents/security/.claude/skills/tool-registration/SKILL.md

exec
/bin/zsh -lc 'git status --short' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
?? logs/codex-ratification.jsonl
?? logs/codex-ratification/20260524T100618Z-10709/
?? logs/codex-ratification/20260524T100618Z-10738/
?? logs/codex-ratification/20260524T100648Z-11041/
?? logs/codex-ratification/20260524T100704Z-11219/
?? logs/codex-ratification/20260524T101312Z-16031/
?? logs/codex-ratification/20260524T101934Z-19923/
?? logs/codex-ratification/20260524T102050Z-21293/
?? logs/codex-ratification/20260524T102202Z-22338/
?? logs/codex-ratification/20260524T102316Z-23548/
?? logs/codex-ratification/20260524T102404Z-24809/
?? logs/codex-ratification/20260524T102511Z-28420/
?? logs/codex-ratification/20260524T103757Z-37420/
?? logs/codex-ratification/20260524T104204Z-40927/
?? logs/codex-ratification/20260524T104642Z-44464/
?? logs/codex-ratification/20260524T112636Z-79455/
?? logs/codex-ratification/20260524T112807Z-81339/
?? logs/codex-ratification/20260524T112917Z-82352/
?? logs/codex-ratification/20260524T113038Z-83732/
?? logs/codex-ratification/20260524T113139Z-84869/
?? logs/codex-ratification/20260524T113247Z-86019/
?? logs/codex-ratification/20260524T115042Z-904/
?? logs/codex-ratification/20260524T115207Z-2587/
?? logs/codex-ratification/20260524T115355Z-4405/
?? logs/codex-ratification/20260524T115519Z-5641/
?? logs/codex-ratification/20260524T115626Z-6836/
?? logs/codex-ratification/20260524T115726Z-8181/
?? logs/codex-ratification/20260524T120906Z-15808/
?? logs/codex-ratification/20260524T121128Z-17565/
?? logs/codex-ratification/20260524T121347Z-19674/
?? logs/codex-ratification/20260524T121550Z-21533/
?? logs/codex-ratification/20260524T121805Z-24288/
?? logs/codex-ratification/20260524T121942Z-25986/
?? logs/codex-ratification/20260524T122200Z-28824/
?? logs/codex-ratification/20260524T122440Z-32123/
?? logs/codex-ratification/20260524T122624Z-33390/
?? logs/codex-ratification/20260524T122757Z-34820/
?? logs/codex-ratification/20260524T123001Z-37001/
?? logs/codex-ratification/20260524T124427Z-47109/
?? logs/codex-ratification/20260524T124738Z-50139/
?? logs/codex-ratification/20260524T125002Z-52329/
?? logs/codex-ratification/20260524T125346Z-55888/
?? logs/codex-ratification/20260524T125652Z-59039/
?? logs/codex-ratification/20260524T130117Z-63874/
?? logs/codex-ratification/20260524T131901Z-80999/
?? logs/codex-ratification/20260524T132441Z-86597/
?? logs/codex-ratification/20260524T132739Z-89086/
?? logs/codex-ratification/20260524T133053Z-92743/
?? logs/codex-ratification/20260524T133407Z-96067/
?? logs/codex-ratification/20260524T133645Z-99130/
?? logs/codex-ratification/20260524T134012Z-2539/
?? logs/codex-ratification/20260524T134204Z-4775/
?? logs/codex-ratification/20260524T134556Z-7679/
?? logs/codex-ratification/20260524T134900Z-9858/
?? logs/codex-ratification/20260524T135120Z-11731/
?? logs/codex-ratification/20260524T135302Z-14058/
?? logs/codex-ratification/20260524T135534Z-17024/
?? logs/codex-ratification/20260524T135714Z-19096/
?? logs/codex-ratification/20260524T135955Z-21837/
?? logs/codex-ratification/20260524T140156Z-24943/
?? logs/codex-ratification/20260524T140421Z-27988/
?? logs/codex-ratification/20260524T140718Z-31055/
?? logs/codex-ratification/20260524T140933Z-33645/
?? logs/codex-ratification/20260524T141157Z-35106/
?? logs/codex-ratification/20260524T141337Z-37011/
?? logs/codex-ratification/20260524T141652Z-40348/
?? logs/codex-ratification/20260524T143747Z-56811/
?? logs/codex-ratification/20260524T143957Z-58446/
?? logs/codex-ratification/20260524T144244Z-61554/
?? logs/codex-ratification/20260524T144455Z-63555/
?? logs/codex-ratification/20260524T144700Z-67035/
?? logs/codex-ratification/20260524T144919Z-68982/
?? logs/codex-ratification/20260524T145157Z-71687/
?? logs/codex-ratification/20260524T145439Z-74254/
?? logs/codex-ratification/20260524T150022Z-81292/
?? logs/codex-ratification/20260524T150247Z-82902/
?? logs/codex-ratification/20260524T150519Z-84855/
?? logs/codex-ratification/20260524T150822Z-87224/
?? logs/codex-ratification/20260524T151012Z-89382/
?? logs/codex-ratification/20260524T151320Z-92280/
?? logs/codex-ratification/20260524T151525Z-95136/
?? logs/codex-ratification/20260524T151757Z-97714/
?? logs/codex-ratification/20260524T170811Z-78348/
?? pnpm-lock.yaml

codex
I found the expected source files. Next I’m checking the Janitor lines against master brief, ULTRAPLAN, autosend policy, schema, escalation catalogue, and helper functions so the verdict is grounded in actual anchors.
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,620p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '495,516p;525,545p;555,572p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   566	- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
   567	- **Gate B target:** <5% candidate-ghosted rate; ≥60% send-as-is rate on drafts
   568	- **Build complexity:** **XL** (4 weeks) — this is the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)
   569	- **Gotchas:** Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks. Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship.
   570	
   571	### 8.2 v1.1 agents (seven, in build order)
   572	

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,130p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,230p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '110,135p;185,202p;232,256p;365,380p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '1,160p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '130,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   221	  bullhorn_note_customer_visible:
   222	    tier: orange
   223	    agent: concierge
   224	    timeout: PT4H
   225	    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"
   226	    irreversible: true
   227	    canonical: true
   228	
   229	  gmail_outlook_send_to_candidate:
   230	    tier: orange
   231	    agent: concierge
   232	    timeout: PT4H
   233	    reason: "Outbound email to candidate; customer-facing; reputation effects"
   234	    irreversible: true
   235	
   236	  twilio_sms_send:
   237	    tier: orange
   238	    agent: concierge
   239	    timeout: PT30M
   240	    reason: "Outbound SMS; high-trust channel; cost-per-send; irreversible"
   241	    irreversible: true
   242	
   243	  calendar_invite_send:
   244	    tier: orange
   245	    agent: concierge
   246	    timeout: PT4H
   247	    reason: "Creates calendar event with attendee notification; visible to attendee"
   248	    irreversible: true
   249	
   250	  email_summary_to_customer:
   251	    tier: orange
   252	    agent: scribe
   253	    timeout: PT4H
   254	    reason: "Outbound email summarising call to customer; customer-facing; format-sensitive"
   255	    irreversible: true
   256	
   257	  xero_reminder_send_customer:
   258	    tier: orange
   259	    agent: cash-conductor
   260	    timeout: PT24H

exec
/bin/zsh -lc "nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '120,180p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '220,360p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "nl -ba docs/decisions/bullhorn-integration-path.md | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/sequencing-target.md | sed -n '1,120p'" in /Users/madsadmin/code/CortexOS
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

 succeeded in 0ms:
     1	# Bullhorn integration path — decision document
     2	
     3	**Date:** 2026-05-16 evening / 2026-05-17 (Week 0, Day 2)
     4	**Status:** Proposed (Sub-decision C Accepted technically; Sub-decisions A + B Proposed pending commercial verification per §1.3)
     5	**Author:** Claude Code, founder commercial verification pending for A + B
     6	**Surfaced by:** Master brief §6 Day 2 (lines 466-467) — "Decision: Bullhorn Marketplace vs Direct API. OAuth model: browser dance for production, service-account for dev." Plus Ultraplan §11 Day 2 (lines 847-849).
     7	**Submodule SHA referenced:** `c21fbfe991a0030ea055bd8e2389a0801a424383`
     8	
     9	**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
    10	
    11	---
    12	
    13	## Section 1 — Context and commercial blockers
    14	
    15	### 1.1 — What we're deciding
    16	
    17	Three sub-decisions, named in master brief §6 Day 2 line 466 and extended in Ultraplan §11 Day 2 lines 847-849.
    18	
    19	**Sub-decision A — Bullhorn integration path.** Marketplace partner programme membership (with its access tier, scope, certification, ongoing fees) versus direct API access (per-tenant Bullhorn-account-admin authorisation of IFOS as a connected app). Master brief §6 Day 2 line 466 explicitly names this as the day's decision. The path chosen determines whether `packages/mcp-connectors/bullhorn/` ships as a marketplace-registered connector or a direct-API connector — the *code* in either case is similar OAuth + REST plumbing, but the *operational, commercial, and rate-limit* surfaces differ materially.
    20	
    21	**Sub-decision B — OAuth flow.** Master brief §6 Day 2 line 466 pre-states a recommendation: "browser dance for production, service-account for dev." This is the authorization-code grant (per-tenant browser dance, refresh-token cycle) for production tenants, plus client-credentials grant (service account) for IFOS-internal sandbox/dev work. Sub-decision B verifies that recommendation against Bullhorn's actual OAuth implementation and pins the per-tenant token storage path (per `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution: `/vault/<tenant>/_secrets.env`, mode `0600`).
    22	
    23	**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
    24	
    25	### 1.2 — Why this matters now
    26	
    27	Master brief §12 Risk #2 (Bullhorn auth path) — "Bullhorn MCP build takes longer than 1 week" — names this as one of the four risks that could kill v1.0. Tripwire: "End of week 3 status not 'core read endpoints working'" (master brief §12 row #2, Ultraplan §10 row #2). The mitigation is "Week 0 Day 2 on Bullhorn auth research" — i.e. this document. Without Sub-decisions A and B answered, Week 1 cannot begin scaffolding `packages/mcp-connectors/bullhorn/` because the connector's authentication path determines its scope and shape.
    28	
    29	**Bullhorn dependency count for v1.0 agents:**
    30	
    31	| Agent | Bullhorn dependency in v1.0 | Source |
    32	|---|---|---|
    33	| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
    34	| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
    35	| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
    36	| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
    37	| A5 Sourcing Scout | **Yes — read** (ATS passive-match lookup) | Ultraplan §8.1 A5 line 547-551 |
    38	| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
    39	
    40	**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
    41	
    42	This is also the Day 2 critical-path artefact for the §6 Day 7 single-sentence test (master brief §6 lines 494-502, Ultraplan §12 lines 887-895), question 3: "Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?" A Yes answer requires this document plus the Sub-decision A and B confirmations to land before Sunday review.
    43	
    44	### 1.3 — What we know vs what we don't
    45	
    46	Honest accounting of which sub-decisions can land tonight from technical analysis alone versus which require commercial verification before the Status flips from Proposed to Accepted.
    47	
    48	**Technically grounded (Claude Code can analyse tonight from Bullhorn public documentation + master brief / Ultraplan / product spec context):**
    49	
    50	- The structural shape of Bullhorn's OAuth flows (authorization code vs client credentials) and which scenarios each is suited to.
    51	- The endpoint surface area available via the public REST API at `https://rest.bullhornstaffing.com/rest-services/<corpToken>/` (the documented entry pattern).
    52	- Token lifecycle outline: short-lived REST sessions, long-lived refresh tokens, periodic re-auth dance via the Bullhorn login URL.
    53	- Pagination / rate-limit *shape* (per-second + per-minute + per-day caps in some accounts).
    54	- Per-tenant credential storage location (resolved by `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C: `/vault/<tenant>/_secrets.env`).
    55	- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
    56	
    57	**Commercially gated (founder must verify before final Status flip to Accepted on Sub-decisions A and B):**
    58	
    59	- Whether Intel Force Ltd is currently a member of the **Bullhorn Marketplace Partner Programme** (or what the application timeline + cost would be). The marketplace partner application process is publicly known to involve a technical review, security audit, and ongoing partner fees — but the specifics for IFOS's tier and tenant volume are commercial-confidential and need a direct conversation.
    60	- Whether **marketplace-tier API access differs from direct-API access** in rate limits, available scopes (e.g. write to JobOrder, write to Note, webhook subscription), or sandbox availability. Bullhorn's public docs are sparse on the deltas; partner reps know the actuals.
    61	- Whether the marketplace-tier cost structure works at IFOS's volume (3-6 tenants v1.0; 100 by end of 2027 per Product Spec §5.4 line 369-373). Partner fees may be flat or per-tenant; this matters at scale.
    62	- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
    63	
    64	**Commercial-blocker table** — specific question, specific contact path, specific timing:
    65	
    66	| Sub-decision | Commercial gate question | Who answers | When | Notes |
    67	|---|---|---|---|---|
    68	| A | "Is Intel Force Ltd in the Bullhorn Marketplace Partner Programme, or what's the application timeline + first-year cost?" | Bullhorn partnerships team — submit via Marketo form at `https://www.bullhorn.com/become-a-partner/` (verified 2026-05-23). Earlier draft cited `partnerships@bullhorn.com` which does NOT exist (mail bounced). | Submit any weekday; response 2-5 business days | Cold inbound via form; routes internally. UK office at 7 Devonshire Square, London EC2M 4YH for escalation. |
    69	| A | "What are the API rate-limit / scope deltas between marketplace tier and direct API at our expected 3-6 tenant pilot volume?" | Same Bullhorn partnerships team, or escalation to developer support | Same conversation | The answer determines whether direct-API can serve v1.0 or marketplace registration is a v1.0 blocker |
    70	| A + C | "Which ATS does design partner #1 use — Bullhorn, Vincere, Voyager Infinity, or another?" | **Founder** — Sunday design-partner conversation 2 per master brief §6 Day 2 line 467 | Sunday/Monday | If Bullhorn: Sub-decision A path proceeds as analysed. If non-Bullhorn: the v1.0 ATS anchor changes, this document's Sub-decisions are scoped to "Bullhorn is the second-tenant ATS" rather than "v1.0 first-tenant ATS" |
    71	| B | "Does Bullhorn's OAuth implementation support client_credentials grant against the sandbox environment?" | Bullhorn developer support — `developer.bullhorn.com` portal contact form, or via the partnerships rep once Sub-decision A's contact path is open | Monday-Tuesday | Used to verify that the §6 Day 2 line 466 recommendation ("browser dance for production, service-account for dev") is implementable end-to-end |
    72	| B | "Refresh-token TTL and rotation behaviour specifics" | Same | Same | Affects renderer §3.3.2 `.env` materialisation: how often does per-tenant `_secrets.env` need rotation? Documented Bullhorn behaviour varies by account; partner-rep gives the canonical numbers |
    73	
    74	The Sunday design-partner conversation 2 is the most time-sensitive: it can flip the entire premise of Sub-decisions A and C. Founder cadence per master brief §6 Day 2 (line 467) and §11.2 line 791 ("Day 2 — Tuesday — Bullhorn integration path... — Design-partner conversation 2") puts this as a parallel-to-Claude-Code track.
    75	
    76	### 1.4 — Tonight's scope
    77	
    78	Stated explicitly so the founder knows what's landable tonight vs what waits for commercial answers:
    79	
    80	- **Tonight (this document):**
    81	  - Sub-decision C in full — technical analysis, per-agent endpoint table, webhook-vs-poll decisions, rate-limit budget allocation. **Status: Accepted** on Sub-decision C alone, no commercial gating.
    82	  - Sub-decisions A and B — full technical analysis (Sections 2 and 3 of this document), with explicit Status: Proposed flags pointing at the §1.3 commercial-blocker table.
    83	  - Recommendation block (§5) names the technical preference, the commercial-answer conditions that flip Status to Accepted, and the documented v1.0-scope-cut contingency if commercial answers go badly.
    84	- **Sunday (2026-05-17):**
    85	  - Founder runs design-partner conversation 2 — primary gate is "which ATS does the first pilot use?". Result lands as a one-line update to this document's §1.3 row 3.
    86	  - Founder runs Bullhorn partnerships outreach — submission via Marketo form at `https://www.bullhorn.com/become-a-partner/` (verified 2026-05-23; the earlier `partnerships@bullhorn.com` draft was wrong — that mailbox does not exist). Result may not come back same-day.
    87	- **Monday (2026-05-18):**
    88	  - Founder runs Bullhorn developer-support outreach for Sub-decision B specifics if not already covered by partnerships rep.
    89	  - Final Status flip on Sub-decisions A and B based on commercial answers landed.
    90	  - Document is re-committed with Status: Accepted on A and B once founder logs the decision.
    91	- **Day 7 review (master brief §6 Day 7 Sunday):**
    92	  - Single-sentence test Q3 ("Have we cleared the auth path?") answered Yes iff Sub-decisions A and B are Accepted.
    93	  - This document joins the first Codex ratification run alongside the other Week 0 artefacts per master brief §10.6.
    94	
    95	**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
    96	
    97	### 1.5 — Gate hierarchy (Day-11 clarification)
    98	
    99	Three distinct gates govern Bullhorn-touching work, in temporal order:
   100	
   101	| Gate | Trigger | Status |
   102	|---|---|---|
   103	| Week-1 prereq code | None — substrate is ATS-agnostic | DONE (Phases 1-5 landed Day 8) |
   104	| Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (`sequencing-target.md` §2.1) | Awaits Q1 LOI |
   105	| Janitor W5 build | A+B Accepted (commercial conversations complete) | Pending |
   106	
   107	---
   108	
   109	## Section 2 — Sub-decision A: marketplace vs direct API
   110	
   111	### 2.1 — Bullhorn marketplace partner programme
   112	
   113	Bullhorn's public surfaces for the partner programme are deliberately thin. Three URLs surveyed Day 2 (2026-05-16 evening):
   114	
   115	- `https://www.bullhorn.com/marketplace/` — consumer-facing directory of "300+ pre-integrated technology partners" filterable by category / location / platform. The only partner-programme reference on the page is the line: **"Become a partner — Are you a supplier to the recruitment space? Join the Marketplace today."** This routes to `/become-a-partner/`.
   116	- `https://www.bullhorn.com/become-a-partner/` — landing page. Main CTA: **"Fill out the form to learn more about our partner programs."** References three external resources (FAQs, Bullhorn Developer Program, Fair Use Policy) but the page itself contains **no specific information** on application process, tiers, certification, security review, fees, ongoing costs, or timeline. The only substantive description on the page is: **"The Bullhorn Marketplace gives our customers the choice, confidence, and customization they need to innovate with agility."**
   117	- `https://www.bullhorn.com/marketplace/partners/` — returns HTTP 404 (verified 2026-05-16).
   118	
   119	**What is publicly stated:**
   120	
   121	- The programme exists and admits "suppliers to the recruitment space."
   122	- Bullhorn Marketplace currently lists 300+ partner integrations (the headline number on the marketplace page).
   123	- There is a separately-named **Bullhorn Developer Program** distinct from the Marketplace partner programme (linked from `/become-a-partner/`) — implying a possible two-tier structure: developer-tier access to APIs (lighter) vs marketplace-listed partner (heavier).
   124	
   125	**What is NOT publicly stated** (confirmed commercially gated to founder verification per §1.3):
   126	
   127	- The application process (forms to fill, technical review steps, security audit requirements).
   128	- Whether the programme has tiers (e.g. Standard / Premier / Strategic) and what gates each tier.
   129	- Whether marketplace-tier partners get different API scope, rate-limit ceilings, or webhook access vs direct-API/developer-tier.
   130	- Annual partner fees, certification costs, MRR thresholds, revenue-share or referral economics.
   131	- Application-to-approval timeline.
   132	- Co-marketing benefits, listing visibility on the marketplace page, lead-routing programmes.
   133	
   134	**Source citation for this section:** the three URLs above, all accessed 2026-05-16.
   135	
   136	**Inference (clearly marked as inference, not Bullhorn's stated position):** the gap between "free developer account" and "marketplace-listed partner" is structurally common across enterprise SaaS platforms (Salesforce AppExchange, HubSpot Marketplace, ServiceNow Store all follow this pattern). The plausible IFOS path through this commercial space is: register for the Bullhorn Developer Program first (which usually grants API access for a tenant the developer controls or for sandbox dev), then apply for marketplace listing once an integration is shippable. Whether either path is required for IFOS production tenants — the actual gate — is the §1.3 partnerships@bullhorn conversation.
   137	
   138	### 2.2 — Direct Bullhorn API access
   139	
   140	Two URLs surveyed:
   141	
   142	- `https://developer.bullhorn.com/` — redirects to `https://bullhorn.github.io/docs` (301 Moved Permanently).
   143	- `https://bullhorn.github.io/docs` — Bullhorn's developer documentation landing. Names three API surfaces: REST API, OAuth, SOAP (legacy). The REST and OAuth links are the operative ones for v1.0.
   144	
   145	**The technical model verified from Bullhorn's "Getting Started with REST" documentation (cited inline below):**
   146	
   147	- **Two-step auth.** Step 1: OAuth 2.0 authorization-code grant against `https://auth-{loginInfo}.bullhornstaffing.com/oauth/authorize` returns an auth code; POST to `/oauth/token` exchanges code for an access_token + refresh_token. Step 2: REST login at the per-tenant `restUrl` exchanges the access_token for a `BhRestToken` (the REST session token) plus a per-tenant base URL.
   148	- **`BhRestToken` (REST session token)** is presented on each subsequent REST call in three accepted forms: URL query parameter, HTTP header (`BhRestToken` or `BHRestToken`), or cookie. On expiry, REST calls return 401 — application must re-run /login. (Bullhorn doc verbatim: "When the current session key expires, your query will return a 401 response.")
   149	- **Per-tenant model.** Each tenant has its own `corpToken` and its own per-tenant `restUrl` returned by /login. Operations are scoped by the corpToken; IFOS must hold per-tenant token state. This maps cleanly to the per-tenant credential model already pinned in `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution (`/vault/<tenant>/_secrets.env`, mode `0600`).
   150	- **client_id / client_secret acquisition.** Bullhorn doc verbatim: **"Bullhorn customers can obtain OAuth keys for developing applications...by creating a support ticket via the Bullhorn Resource Center."** This is not a self-service developer signup — there is a Bullhorn-side gate even for the developer-tier path. Implication: every IFOS pilot tenant must open a support ticket with Bullhorn to authorise IFOS as a connected app, or IFOS must hold a single set of client credentials at the IFOS-application level and route per-tenant auth through it. The structural distinction here is exactly what Sub-decision A pivots on — partnerships@bullhorn confirms whether marketplace status grants application-level credentials.
   151	- **Documented rate limit signal:** Bullhorn's REST docs name **HTTP 429** as "Rate Limited — Wait 1 second then retry request. Repeat until successful." That's the only rate-limit reference in the public docs surveyed; specifics (per-second/minute/day caps, per-corpToken or per-application) are not documented and are commercially gated to verification per §1.3.
   152	- **Sandbox environment availability:** not addressed in any public doc surveyed. Commercially gated.
   153	
   154	**Citations:**
   155	
   156	- `https://bullhorn.github.io/docs` — landing page naming REST/OAuth/SOAP API surfaces.
   157	- `https://bullhorn.github.io/rest-api-docs/` — REST API reference, named two-step auth and 429 rate-limit handling.
   158	- `https://bullhorn.github.io/Getting-Started-with-REST` — auth flow specifics (endpoint URLs, token TTLs, refresh-token rotation, credential acquisition path).
   159	
   160	### 2.3 — Comparison rubric
   161	
   162	Eight criteria. Cells marked **CG** (commercially gated) require founder verification per §1.3 before flipping from inference to confirmed.
   163	
   164	| Criterion | Marketplace | Direct (Developer Program) |
   165	|---|---|---|
   166	| Time-to-first-call (greenlight → working API call against a tenant) | **CG.** Inference: marketplace certification + security review typically 4-12 weeks for enterprise SaaS programmes of this maturity. Bullhorn-specific timeline not stated publicly. | **CG.** Confirmed from public docs: customer raises Bullhorn support ticket per /Getting-Started-with-REST to obtain client_id/client_secret. ETA per ticket cycle — likely 1-5 business days per pilot tenant. |
   167	| Per-tenant onboarding friction (admin auth, scope review) | **CG.** If marketplace tier grants IFOS application-level credentials, per-tenant friction may reduce to "tenant clicks Authorise from marketplace listing." | Each pilot tenant raises a Bullhorn support ticket + tenant admin authorises IFOS as a connected app via per-tenant OAuth screen. Per-tenant friction: 1 support ticket + 1 OAuth dance per pilot tenant. |
   168	| Co-marketing benefit | Listed in the 300+ partner directory on bullhorn.com/marketplace; potentially Bullhorn-sales-rep co-selling motion. **CG** on specific benefit terms. | None. |
   169	| Cost at 3-tenant pilot scale (2026 H2, Boutique tier per Product Spec §3.1) | **CG.** Public docs do not name partner fees. Inference based on comparable enterprise SaaS marketplace programmes: annual partner fee typically $5K-$25K + possibly per-listing or per-referral revenue-share. | **CG.** Public docs do not name developer-program fees. Inference: likely zero or nominal for the developer-tier API access. Per-tenant cost zero — the tenant pays Bullhorn, IFOS pays nothing per call. |
   170	| Cost at 100-tenant target scale (Product Spec §5.4 end-2027 target) | **CG.** May or may not scale linearly with tenant count. Some marketplace programmes have flat annual fees; others meter on tenant or revenue volume. | **CG.** If developer-tier cost is zero or nominal, scales fine. Risk: per-tenant Bullhorn support tickets at 100 tenants become operational drag at IFOS-Customer-Success layer (Product Spec §5.4 line 373 names ≤8 hours of human time per customer onboarding — Bullhorn ticket may consume a meaningful fraction). |
   171	| Scope / rate-limit deltas | **CG.** Marketplace tier may grant elevated rate limits, write access to additional entities (e.g. JobOrder write), webhook subscription endpoints not available to direct-tier. Public docs do not state. | Public REST API documentation lists all REST endpoints uniformly — no tier-gated endpoints stated in public docs. Inference: all entity reads/writes are available to authenticated direct-tier callers, subject to per-corpToken scope at the tenant-account-admin level. Rate limit ceiling **CG**. |
   172	| Founder operational overhead (per tenant + ongoing) | **CG.** If marketplace handles per-tenant auth: low per-tenant overhead. Annual partner-programme obligations: technical review responses, security questionnaire renewals, marketplace listing maintenance — non-trivial ongoing. | Per-tenant: one Bullhorn support ticket request from the tenant admin per pilot. Ongoing: zero programme obligations; only IFOS-side OAuth token refresh management. |
   173	| **Switching cost later** (start direct, move to marketplace at v1.1+) | n/a (this is the destination) | **Low if the connector code treats auth as a swap-point per §1.4 fallback architecture.** The connector's REST endpoint calls (Sub-decision C surface) are identical between paths. The auth module — `packages/mcp-connectors/bullhorn/src/auth.ts` and the `_secrets.env` materialisation in the renderer — is the only differing surface. Bounded to ~200-400 lines of code per the design in `agent-bundle-renderer-design.md` §3.3.4. |
   174	
   175	The **Switching cost** row is the load-bearing design constraint. It validates the §1.4 fallback architecture: the connector can scaffold against direct-API in Week 1-2 without locking in the wrong long-term path. If Sub-decision A lands as marketplace-required in Week 1-2 founder commercial verification, the swap is a Week-2-3 task scoped to the auth module.
   176	
   177	### 2.4 — Technical recommendation (Proposed)
   178	
   179	**Recommendation: scaffold the Bullhorn MCP connector against direct API / Developer Program for v1.0 weeks 1-2; treat marketplace registration as a v1.1+ commercial track that the connector's auth module is designed to swap into without endpoint-surface changes.**
   180	

exec
/bin/zsh -lc "nl -ba agents/recruitment/janitor/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc 'rg -n "recent_edit|candidate|contractor|client|brief|agent_name|tenant_slug|decision_log|tenant_adapters" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:4:#   - entities (id, tenant_slug, entity_type, entity_id, data JSONB, version, ...)
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:10:# Source: master brief §6 Day 6 line 490 (8 core entities)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:26:  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
docs/verticals/recruitment/vertical-schema.yaml:27:  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:36:#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:51:    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
docs/verticals/recruitment/vertical-schema.yaml:75:        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
docs/verticals/recruitment/vertical-schema.yaml:88:        enum: [active, archived, do_not_contact, placed, contractor_promoted]
docs/verticals/recruitment/vertical-schema.yaml:90:          "contractor_promoted" = candidate whose status flipped to contractor; row gets duplicated as entity_type="contractor" via adapter layer.
docs/verticals/recruitment/vertical-schema.yaml:95:        notes: Bullhorn user (consultant) who owns this candidate record.
docs/verticals/recruitment/vertical-schema.yaml:153:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:156:    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:159:      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:161:      - Concierge (R+W — lifecycle state; week-1/month-1 check-ins differ for contractors per Product Spec §2.2 R7)
docs/verticals/recruitment/vertical-schema.yaml:163:      # Inherits candidate fields conceptually; below are the additional contractor-specific fields.
docs/verticals/recruitment/vertical-schema.yaml:164:      # Full implementation: adapter layer materialises both candidate-overlap fields AND contractor-specific fields in entities.data.
docs/verticals/recruitment/vertical-schema.yaml:165:      # Schema notes: see candidate canonical_fields for the shared base set.
docs/verticals/recruitment/vertical-schema.yaml:170:        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
docs/verticals/recruitment/vertical-schema.yaml:204:        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
docs/verticals/recruitment/vertical-schema.yaml:205:        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
docs/verticals/recruitment/vertical-schema.yaml:209:        source: IFOS-derived (when can contractor start, in weeks from now)
docs/verticals/recruitment/vertical-schema.yaml:214:        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
docs/verticals/recruitment/vertical-schema.yaml:216:      - IR35 classification is regulatory-bearing; v0.1 captures the field but T4 IR35 agent (v2.0 per master brief §9) is the canonical reasoner.
docs/verticals/recruitment/vertical-schema.yaml:217:      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
docs/verticals/recruitment/vertical-schema.yaml:218:      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
docs/verticals/recruitment/vertical-schema.yaml:221:  client:
docs/verticals/recruitment/vertical-schema.yaml:223:      A company that hires through the recruitment agency. Master brief canonical vocabulary at §3.2 line 155 ("candidate, placement, brief") implicitly assumes client as the holder of briefs. Bullhorn calls this `ClientCorporation`.
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:285:      A person at a client company. Decision-makers, hiring managers, HR, procurement. Bullhorn calls this `ClientContact`. v1.0 representation is thin (10 fields); v1.1 Triage agent expands decision-authority modelling.
docs/verticals/recruitment/vertical-schema.yaml:289:      - (v1.1+) Inbound Triage — R+W expansion per master brief §9
docs/verticals/recruitment/vertical-schema.yaml:315:        notes: Job title at client.
docs/verticals/recruitment/vertical-schema.yaml:341:  brief:
docs/verticals/recruitment/vertical-schema.yaml:343:      A role being recruited for. Master brief canonical vocabulary uses `brief`; §6 Day 6 line 490 lists "Role/Brief" — `brief` is the canonical entity_type slug; `role` is documented alias. Bullhorn calls this `JobOrder`.
docs/verticals/recruitment/vertical-schema.yaml:349:      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:350:      - Concierge (R — linked-brief context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:410:        source: IFOS-derived (Concierge maintains based on client check-in cadence)
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:426:      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).
docs/verticals/recruitment/vertical-schema.yaml:431:      A candidate placed into a client role. The commercial transaction unit — fees accrue per placement, lifecycle events (week-1, month-1, etc.) fire per placement per Product Spec §2.2 R7.
docs/verticals/recruitment/vertical-schema.yaml:465:        notes: GBP. For permanent placements typically % of candidate_salary_at_placement; for contract typically per-day margin.
docs/verticals/recruitment/vertical-schema.yaml:471:      candidate_salary_at_placement:
docs/verticals/recruitment/vertical-schema.yaml:497:      A candidate-brief pairing in the submission/screening/interview/offer pipeline. Pre-placement state. v1.1+ exercised; v1.0 minimal.
docs/verticals/recruitment/vertical-schema.yaml:502:      - (v1.1) Inbound Triage — read for routing inbound candidate enquiries to active opportunities
docs/verticals/recruitment/vertical-schema.yaml:512:        enum: [submitted, screening, interview_scheduled, interview_completed, offer_pending, offer_accepted, rejected_by_client, rejected_by_candidate, withdrawn]
docs/verticals/recruitment/vertical-schema.yaml:537:      A contractor's weekly hours record. v2.0 entity — exercised by T2 Timesheet agent + T6 Pay & Bill agent per master brief §9. v0.1 captures placeholder shape only.
docs/verticals/recruitment/vertical-schema.yaml:557:      approved_by_client:
docs/verticals/recruitment/vertical-schema.yaml:561:      approved_by_contractor:
docs/verticals/recruitment/vertical-schema.yaml:585:  candidate_placed_in_role:
docs/verticals/recruitment/vertical-schema.yaml:586:    source: candidate
docs/verticals/recruitment/vertical-schema.yaml:589:    description: A candidate may have multiple placements over time (different clients, different roles). A placement has exactly one candidate.
docs/verticals/recruitment/vertical-schema.yaml:591:      Despite "M:N" cardinality, practically 1:N from placement → candidate (each placement has one candidate; each candidate has 0..N placements). Modelled as M:N for query symmetry.
docs/verticals/recruitment/vertical-schema.yaml:592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
docs/verticals/recruitment/vertical-schema.yaml:594:  placement_for_brief:
docs/verticals/recruitment/vertical-schema.yaml:596:    target: brief
docs/verticals/recruitment/vertical-schema.yaml:598:    description: Each placement fills exactly one brief; a brief may have multiple placements over time (replacement hires, multiple seats).
docs/verticals/recruitment/vertical-schema.yaml:601:  brief_from_client:
docs/verticals/recruitment/vertical-schema.yaml:602:    source: brief
docs/verticals/recruitment/vertical-schema.yaml:603:    target: client
docs/verticals/recruitment/vertical-schema.yaml:605:    description: Each brief is owned by exactly one client (the hiring company).
docs/verticals/recruitment/vertical-schema.yaml:608:  brief_decision_maker:
docs/verticals/recruitment/vertical-schema.yaml:609:    source: brief
docs/verticals/recruitment/vertical-schema.yaml:612:    description: Each brief has a designated decision-maker contact at the client (the hiring manager).
docs/verticals/recruitment/vertical-schema.yaml:614:      v0.1 captures the PRIMARY decision-maker only. Real-world recruiting often has multiple decision-makers per brief (hiring manager + HR + occasionally CTO/CFO/CEO). The N:1 cardinality is the simplifying v0.1 assumption. Multi-decision-maker panels deferred to v1.1 Triage per Q10 — when v1.1 lands, brief_decision_maker may flip to M:N with role-in-panel metadata (chair, technical-evaluator, hr-lead, budget-approver, etc.) on entity_links.metadata.
docs/verticals/recruitment/vertical-schema.yaml:618:  contact_works_for_client:
docs/verticals/recruitment/vertical-schema.yaml:620:    target: client
docs/verticals/recruitment/vertical-schema.yaml:622:    description: Each contact works at one client (the simplifying v0.1 assumption — multi-employer contacts deferred to v1.1+).
docs/verticals/recruitment/vertical-schema.yaml:625:  candidate_engaged_with_contact:
docs/verticals/recruitment/vertical-schema.yaml:626:    source: candidate
docs/verticals/recruitment/vertical-schema.yaml:632:  candidate_referred_by_contact:
docs/verticals/recruitment/vertical-schema.yaml:633:    source: candidate
docs/verticals/recruitment/vertical-schema.yaml:636:    description: Some candidates are referred by a contact (a candidate's previous manager, peer, etc., who is in the IFOS contact registry).
docs/verticals/recruitment/vertical-schema.yaml:639:  opportunity_for_brief:
docs/verticals/recruitment/vertical-schema.yaml:641:    target: brief
docs/verticals/recruitment/vertical-schema.yaml:643:    description: An opportunity is a candidate's progression toward a specific brief.
docs/verticals/recruitment/vertical-schema.yaml:647:  opportunity_about_candidate:
docs/verticals/recruitment/vertical-schema.yaml:649:    target: candidate
docs/verticals/recruitment/vertical-schema.yaml:651:    description: Each opportunity is about exactly one candidate; a candidate may have multiple opportunities (different briefs).
docs/verticals/recruitment/vertical-schema.yaml:672:    candidate: none
docs/verticals/recruitment/vertical-schema.yaml:673:    contractor: none
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:676:    brief: none
docs/verticals/recruitment/vertical-schema.yaml:683:    candidate: R+W   # full sweep + normalisation + dedup proposals
docs/verticals/recruitment/vertical-schema.yaml:684:    contractor: R+W  # status normalisation
docs/verticals/recruitment/vertical-schema.yaml:685:    client: R+W      # orphan-link sweep + normalisation
docs/verticals/recruitment/vertical-schema.yaml:687:    brief: R         # status drift sweep
docs/verticals/recruitment/vertical-schema.yaml:693:    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
docs/verticals/recruitment/vertical-schema.yaml:694:    contractor: R+W  # contractor calls same pattern
docs/verticals/recruitment/vertical-schema.yaml:695:    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
docs/verticals/recruitment/vertical-schema.yaml:697:    brief: R         # write-context resolution
docs/verticals/recruitment/vertical-schema.yaml:698:    placement: R+W   # note links on placed-candidate calls
docs/verticals/recruitment/vertical-schema.yaml:703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
docs/verticals/recruitment/vertical-schema.yaml:704:    contractor: none
docs/verticals/recruitment/vertical-schema.yaml:705:    client: none
docs/verticals/recruitment/vertical-schema.yaml:707:    brief: none
docs/verticals/recruitment/vertical-schema.yaml:713:    candidate: R     # passive matching
docs/verticals/recruitment/vertical-schema.yaml:714:    contractor: R    # contractor pool
docs/verticals/recruitment/vertical-schema.yaml:715:    client: R        # target-firm context
docs/verticals/recruitment/vertical-schema.yaml:717:    brief: R         # active brief context for matching
docs/verticals/recruitment/vertical-schema.yaml:723:    candidate: R+W   # lifecycle state on every event
docs/verticals/recruitment/vertical-schema.yaml:724:    contractor: R+W  # lifecycle state, contractor-specific cadence
docs/verticals/recruitment/vertical-schema.yaml:725:    client: R        # relationship context
docs/verticals/recruitment/vertical-schema.yaml:727:    brief: R         # linked-brief context
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:744:    status_filter: status != 'contractor'
docs/verticals/recruitment/vertical-schema.yaml:747:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:750:    status_filter: status='contractor'
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:752:    notes: Adapter layer materialises both `candidate` and `contractor` entity_type rows from the same Bullhorn.Candidate record when status flips. See entity-level notes.
docs/verticals/recruitment/vertical-schema.yaml:754:  client:
docs/verticals/recruitment/vertical-schema.yaml:765:  brief:
docs/verticals/recruitment/vertical-schema.yaml:797:  Q1_contractor_entity_type:
docs/verticals/recruitment/vertical-schema.yaml:799:    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
docs/verticals/recruitment/vertical-schema.yaml:800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
docs/verticals/recruitment/vertical-schema.yaml:822:    revisit_trigger: v1.1 Inbound Triage agent build per master brief §9 expands decision-authority modelling.
docs/verticals/recruitment/vertical-schema.yaml:827:    v0_1_decision: Timesheet entity has placeholder 7-field shape (id, week_starting, hours_worked, approved_by_client, approved_by_contractor, date_submitted, primary key).
docs/verticals/recruitment/vertical-schema.yaml:829:    rationale: T2 + T6 builds are v2.0 per master brief §9; full schema requires pay/bill modelling not yet designed.
docs/verticals/recruitment/vertical-schema.yaml:834:    v0_1_decision: contractor.umbrella_company is free-text field in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:835:    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.
docs/verticals/recruitment/vertical-schema.yaml:840:    v0_1_decision: brief.required_skills + brief.nice_to_have_skills are free-string arrays in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:844:  Q9_multi_client_contact:
docs/verticals/recruitment/vertical-schema.yaml:847:    v0_1_decision: contact_works_for_client is N:1 (each contact at exactly one client). Contacts who change employer get a new contact entity per IFOS.
docs/verticals/recruitment/vertical-schema.yaml:854:    v0_1_decision: brief_decision_maker is N:1 (each brief has one primary decision-maker contact in v0.1).
docs/verticals/recruitment/vertical-schema.yaml:855:    revisit_trigger: v1.1 Inbound Triage expands to panel modelling — multiple decision-maker contacts per brief with role-in-panel (chair, technical-evaluator, hr-lead, etc.).
docs/verticals/recruitment/vertical-schema.yaml:856:    rationale: v1.0 Concierge addressee-resolution uses primary-decision-maker; panel modelling adds value when v1.1 Triage handles inbound brief queries from multiple stakeholders.
docs/verticals/recruitment/vertical-schema.yaml:872:      Codex Day-7 ratification reviews whether stricter source-field schema would improve machine-parseability. If accepted, v1.0 introduces structured source object — e.g., `source: {origin: bullhorn | ifos_derived, bullhorn_field?: <entity.field>, ifos_agent?: <agent_name>, citation?: <doc-ref>}`.
docs/verticals/recruitment/vertical-schema.yaml:896:    expected_date: post first-pilot operations (Q4 2026 if pilot lands per master brief §6 Day 7 question 1)
docs/verticals/recruitment/vertical-schema.yaml:898:      Triage expansion (Q5 contact decision-authority granularity, Q10 panel hiring). Skill taxonomy decision (Q8). Multi-client contact decision (Q9). Umbrella company entity promotion candidate (Q7). Opportunity entity exercise begins.
docs/verticals/recruitment/vertical-schema.yaml:901:    expected_date: 2027+ per master brief §9 build sequence
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:39:#   policies on per-table tenant_slug — both of which are simpler with first-class
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:48:#   v0.1 entities (candidate, contractor, contact, brief, opportunity, placement)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:65:      tenant_slug:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:69:        notes: RLS-isolated per tenant. Maps to entities.tenant_slug at row level.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:75:          Semver tag (e.g. "v0.1", "v0.2-2026-06-15"). Bump on re-index. Live pack is the row with `is_active: true`; historical packs preserved for audit + rollback per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:132:      tenant_slug:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:168:          Provenance: "founder" (default tenant-onboarding rules), "tenant-admin" (added via Brain UI), "ifos-csm" (added during CSM intervention per master brief §10 CSM workflow).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:191:      Human edit to an agent's output captured at the point the consultant approves/edits/rejects a draft. Drives (a) the voice-drift-canary nightly cron, (b) future LoRA SFT pair generation per Ultraplan §6.1, (c) classifier retraining queue. Append-only per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:198:      tenant_slug:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:202:      agent_name:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:218:          Optional pointer to the entity the draft was about (e.g. "candidate", "client"). Enables linking voice drift to entity classes (some entity types correlate with more drift).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:279:      Per-tenant query pattern via RLS: SELECT * FROM voice_corpus_chunks WHERE tenant_slug = current_setting('app.current_tenant') ORDER BY embedding <=> $query_vec LIMIT 10. RLS predicate ensures cross-tenant isolation even if a developer forgets the WHERE clause.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:296:  contractor:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:301:      notes: Same as candidate.voice_classifier_score, scoped to contractor sub-case.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:311:  brief:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:317:        Aggregate (last-7-day mean) voice classifier score across all Concierge messages about this brief. Drives "this brief is producing voice-drift messages — investigate" alerting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:325:        v1.1+ Triage exercises this; v1.0 sets to NULL. Tracks voice score for outbound messages within a specific candidate-brief opportunity pairing.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:333:        Snapshot of mean voice classifier score across all Concierge messages for the candidate during the 30 days BEFORE placement close. Captures voice quality at the moment of commercial success — drives "did voice quality predict deal close" reporting + v2.0 LoRA pipeline label generation.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:350:  recent_edit_drives_retraining:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 3 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:14:# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:31:# No ALTER TABLE for the candidate / contact / brief / placement / opportunity
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:53:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:61:          IR35 distinction matters for UK contractors. Extracted by Scribe
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:77:          per candidate enforced by validate_entities_data_v0_3.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:91:          outbound — outreach via candidate.email or candidate.phone only).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:125:  brief:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:134:          Hard requirements; Sourcing Scout filters candidates against this
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:136:        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:159:          Anti-requirements; Sourcing Scout EXCLUDES candidates matching any
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:175:          confirming candidate started. Janitor flags ambiguous via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:238:          ranking in Sourcing Scout's brief-to-candidate pipeline.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:267:#   - Diagnostic client: none → R (reads Companies House data via cached
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:268:#     client entity; sales-tool source-of-truth context — v0.3 amendment)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:272:#     pattern as candidate/contractor — v0.3 amendment)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:287:#   - Cash Conductor placement: none → R (reads for client linkage on invoice)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:290:#   - Sourcing Scout candidate: R → R+W (writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:294:#   - Concierge candidate: R → R+W (writes lifecycle-state-derived fields +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:296:#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:302:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:314:  # (candidate, contractor, client, contact, brief, opportunity, placement,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:318:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:326:  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:342:  #   Example: Scribe.candidate: R+W at entity level; per-field
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:343:  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:344:  #   without reading it). Another example: Diagnostic.candidate: R at entity
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:345:  #   level; candidate.linkedin_url has no Diagnostic field entry; Diagnostic
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:348:  #   agent + which fields were touched in decision_log payload; reviewers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:357:  # layer (cycle.sh + hh_decision_action) where the agent_name in the
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:358:  # decision_log row records who wrote. Entity-level RLS enforces TENANT
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:363:    candidate: R           # reads for outreach context (§11 decision-maker map)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:364:    contractor: none       # not in scope at v1.0
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:365:    client: R              # reads via Companies House lookup (entity-shape if cached)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:367:    brief: none            # diagnostic is sales-tool not brief-driven
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:373:    candidate: R+W         # dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:374:    contractor: R+W        # dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:375:    client: R+W            # Companies House enrichment writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:377:    brief: R               # context for related candidate cleanup
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:389:    candidate: R+W         # call-summary field extraction (Bullhorn endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:390:    contractor: R+W        # call-summary field extraction (Bullhorn endpoint A3 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:391:    client: R              # IFOS-cached read (Bullhorn endpoint A3 — ClientCorporation)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:393:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:404:    candidate: none        # no Bullhorn dependency
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:405:    contractor: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:406:    client: R              # IFOS-cached read; client billing details
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:408:    brief: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:410:    placement: R           # IFOS-cached read; client linkage on invoice
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:416:    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:418:    # writes its proposed-candidate rows + reads opportunity context. These
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:420:    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:421:    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:422:    client: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:424:    brief: R               # reads to filter candidates
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:434:    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14 (Bullhorn endpoint A6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:435:    contractor: R+W        # writes lifecycle states for contractor placements too (Bullhorn endpoint A6 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:436:    client: R              # IFOS-cached read (Bullhorn endpoint A6 — ClientCorporation)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:438:    brief: R               # IFOS-cached read (Bullhorn endpoint A6 — JobOrder)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:457:  client:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:462:      - Scribe (R)         # v0.3 NEW — reads client context for call-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:463:      - Cash Conductor (R) # v0.3 NEW — reads client billing details for invoices
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:468:      client billing/context for their respective workflows). No new W access.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:484:  brief:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:492:      v0.3 upgrades Scribe to R+W for the 3 new brief fields only; existing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:534:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:540:      - Sourcing Scout (R+W) # v0.3 UPGRADED — writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:543:      v0.3 upgrades Sourcing Scout (writes proposed-candidate rows from
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:547:  contractor:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:552:      - Sourcing Scout (R+W) # v0.3 UPGRADED — same pattern as candidate
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:553:      - Concierge (R+W)    # v0.3 UPGRADED — lifecycle states for contractor placements
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:555:      Parallel upgrades to candidate; contractor entities follow the same
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:566:      Conductor for chase drafts; Sourcing Scout for per-candidate
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:578:      voice-classified outputs (§12 opener, per-candidate rationale).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:580:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:612:      tenant_slug: {type: string, required: true, source: IFOS-internal, notes: RLS isolation key per Day-4 §6.3}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:627:      - "(tenant_slug, posted_at DESC)"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:628:      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:648:      tenant_slug: {type: string, required: true, source: IFOS-internal}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:658:      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor links to Bullhorn placement.client_contact_id)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:659:      client_billing_email: {type: string, required: false, source: Accounting provider, pii: true}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:665:      - "(tenant_slug, due_at)"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:666:      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:667:      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:711:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:738:# §4 — tenant_adapters.config new keys (3 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:741:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:742:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:745:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:798:# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:801:decision_log_payload_extension:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:802:  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:830:    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:848:      candidate / contact / brief / placement / opportunity entity_types.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:853:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:855:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:888:        Keep 6 values as in §1.candidate.employment_type — perm, contract,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:900:    question: Cap at 20 items per candidate adequate?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:903:      B: Increase to 50 (handles senior technical candidates with deep stacks).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:906:    trigger_for_revisit: First-pilot data after 30+ candidates indexed; if >5%
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:907:      of candidates hit the 20-item cap, escalate to B.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:915:         (bullhorn_state TEXT, ifos_state TEXT, tenant_slug TEXT).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:928:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:940:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:971:      seniority — not yet in schema; brief.start_date should be
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:976:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:978:    - Concierge tenant_adapters.config field refs valid

exec
/bin/zsh -lc 'rg -n "hh_decision_|autosend_policy_lookup|function hh_decision|hh_decision" agents/_shared/hook-helpers.sh' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
3:# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
166:# hh_decision_trigger <trigger_type> [<reason>]
168:hh_decision_trigger() {
177:# hh_decision_output <output_type> <artefact_ref> [<reason>]
180:hh_decision_output() {
190:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
193:hh_decision_action() {
202:  if ! tier=$(autosend_policy_lookup "${action_type}"); then
262:# autosend_policy_lookup <action_type>
265:autosend_policy_lookup() {
268:    printf 'autosend_policy_lookup: policy file not found at %s\n' "${_HH_POLICY_FILE}" >&2

exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_WRITE_FAIL|ESC_GATE_B_MISS|ESC_AUTOSEND_SAMPLED_SPOT_CHECK|bullhorn_candidate_dedupe|bullhorn_field_backfill|bullhorn_note_attach|candidate_dedupe" agents/_shared/escalation-codes.md agents/_shared/autosend-policy.yaml docs/decisions/autosend-safety-policy.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:147:  bullhorn_candidate_dedupe:
agents/_shared/autosend-policy.yaml:154:  bullhorn_field_backfill:
agents/_shared/autosend-policy.yaml:161:  bullhorn_note_attach:
agents/_shared/escalation-codes.md:310:#### `ESC_BULLHORN_WRITE_FAIL`
agents/_shared/escalation-codes.md:366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
agents/_shared/escalation-codes.md:377:#### `ESC_GATE_B_MISS`
docs/decisions/autosend-safety-policy.md:92:| Janitor | `bullhorn_candidate_dedupe` | 1-in-10 | Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review |
docs/decisions/autosend-safety-policy.md:435:      "bullhorn_candidate_dedupe": "orange"
docs/decisions/autosend-safety-policy.md:451:      "bullhorn_candidate_dedupe": 1,

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '160,220p;260,310p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   260	# ────────────────────────────────────────────────────────────────────────
   261	
   262	# autosend_policy_lookup <action_type>
   263	# Prints the tier (green|yellow|orange|red) to stdout; returns 0 if found,
   264	# 1 if action_type missing from policy file.
   265	autosend_policy_lookup() {
   266	  local action_type="$1"
   267	  if [[ ! -f "${_HH_POLICY_FILE}" ]]; then
   268	    printf 'autosend_policy_lookup: policy file not found at %s\n' "${_HH_POLICY_FILE}" >&2
   269	    return 1
   270	  fi
   271	  # YAML lookup via awk — finds the action_type key, then reads tier:
   272	  # one line below. Safer than yq/python deps at agent runtime.
   273	  local tier
   274	  tier=$(awk -v key="${action_type}" '
   275	    $0 ~ "^  " key ":" { in_block = 1; next }
   276	    in_block && /^    tier: / { sub(/^    tier: /, ""); print; exit }
   277	    in_block && /^  [a-z]/ { in_block = 0 }
   278	  ' "${_HH_POLICY_FILE}")
   279	  if [[ -z "${tier}" ]]; then
   280	    return 1
   281	  fi
   282	  printf '%s' "${tier}"
   283	}
   284	
   285	# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
   286	# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
   287	# tenant override file at /vault/<tenant>/_config/autosend-overrides.yaml.
   288	# Tenants can ELEVATE only (green→yellow→orange→red); red is the floor.
   289	autosend_apply_tenant_override() {
   290	  local base_tier="$1"
   291	  local action_type="$2"
   292	  local tenant_slug="$3"
   293	
   294	  # Red is absolute — no override possible.
   295	  if [[ "${base_tier}" == "red" ]]; then
   296	    printf '%s' "red"
   297	    return 0
   298	  fi
   299	
   300	  local override_file="${IFOS_VAULT_ROOT:-/vault}/${tenant_slug}/_config/autosend-overrides.yaml"
   301	  if [[ ! -f "${override_file}" ]]; then
   302	    printf '%s' "${base_tier}"
   303	    return 0
   304	  fi
   305	
   306	  local override
   307	  override=$(awk -v key="${action_type}" '
   308	    $0 ~ "^  " key ":" { sub(/^  [^:]+: */, ""); print; exit }
   309	  ' "${override_file}")
   310	

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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '302,315p;580,720p;738,790p;940,980p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   302	#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
   303	#     extended)
   304	#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
   305	#     — v0.2 extended)
   306	#
   307	# All other access levels carry forward unchanged from v0.1 + v0.2.
   308	
   309	agent_access_matrix:
   310	
   311	  # Disposition tokens: R | W | R+W | none
   312	  #
   313	  # SCOPE: This matrix is rectangular across `entities:` entity_types ONLY
   314	  # (candidate, contractor, client, contact, brief, opportunity, placement,
   315	  # timesheet — 8 v0.1 entity_types).
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
   621	      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
   622	      match_confidence: {type: number, required: false, source: IFOS-derived (Cash Conductor algorithm), notes: "range [0.00, 1.00]"}
   623	      match_dimensions: {type: array, items: {type: string}, required: false, source: IFOS-derived}
   624	      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
   625	      raw_payload: {type: object, required: false, source: Open Banking provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific. Full Open Banking response cached for audit; pseudonymized at year 7"}
   626	    indexes:
   627	      - "(tenant_slug, posted_at DESC)"
   628	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   629	    retention: |
   630	      INTENT (W4-polish enforcement required): 7-year retention with
   631	      pseudonymization at year 7 for PII-bearing fields (payee_name_raw,
   632	      description, raw_payload). Aligned with Q4 v0_3_default. The
   633	      v0.2-to-v0.3 migration creates the table + indexes only; the
   634	      pseudonymization + purge implementation is a W4-polish slice (pg_cron
   635	      job or external scheduled job; not yet authored).
   636	    enforcement_gate: |
   637	      Production use of this table GATED until pseudonymization + purge
   638	      implementation lands as W4 polish. Per-tenant DPA addendum signed
   639	      by founder + tenant before go-live; migration-test tenant exempt.
   640	
   641	  cash_conductor_invoices:
   642	    rationale: |
   643	      Open invoice register cached from accounting provider. Same auxiliary-
   644	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   645	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3 (migration is authoritative)
   646	    columns:
   647	      id: {type: integer, required: true, source: IFOS-internal}
   648	      tenant_slug: {type: string, required: true, source: IFOS-internal}
   649	      invoice_id: {type: string, required: true, source: Accounting provider (Xero/QuickBooks/Sage)}
   650	      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage], source: IFOS-internal (per-tenant config)}
   651	      invoice_number: {type: string, required: false, source: Accounting provider}
   652	      issued_at: {type: timestamp, required: true, source: Accounting provider}
   653	      due_at: {type: timestamp, required: true, source: Accounting provider}
   654	      amount_total: {type: number, required: true, source: Accounting provider, notes: NUMERIC(15,2) GBP}
   655	      amount_paid: {type: number, required: true, default: 0, source: Accounting provider + IFOS-derived (Cash Conductor reconciliation updates)}
   656	      currency: {type: string, required: true, default: GBP, source: Accounting provider}
   657	      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open, source: Accounting provider}
   658	      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor links to Bullhorn placement.client_contact_id)}
   659	      client_billing_email: {type: string, required: false, source: Accounting provider, pii: true}
   660	      last_chase_position: {type: integer, required: true, default: 0, source: IFOS-derived (Cash Conductor escalation ladder), notes: 0-4 per Cash Conductor §3.2}
   661	      last_chase_sent_at: {type: timestamp, required: false, source: IFOS-derived}
   662	      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
   663	      raw_payload: {type: object, required: false, source: Accounting provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific (Xero / QuickBooks / Sage). Full provider response cached for audit"}
   664	    indexes:
   665	      - "(tenant_slug, due_at)"
   666	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   667	      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
   668	    retention: |
   669	      INTENT (W4-polish enforcement required): 7-year retention with
   670	      pseudonymization at year 7 per Q4 v0_3_default. Cancelled/voided rows
   671	      90d. The v0.2-to-v0.3 migration creates the table + indexes only; the
   672	      pseudonymization + purge implementation is a W4-polish slice
   673	      (pg_cron job or external scheduled job; not yet authored).
   674	    enforcement_gate: |
   675	      Until pseudonymization + 90d-cancelled-purge implementation lands as
   676	      W4 polish, production use of cash_conductor_invoices is GATED by
   677	      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
   678	      per §3 cash_conductor_transactions.retention). Migration-test tenant
   679	      data is exempt; pilot tenants require the DPA addendum signed before
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
   940	    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
   941	    options:
   942	      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
   943	      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
   944	      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
   945	    v0_3_default: A
   946	    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
   947	      for forward-compat, escalate to B or C with explicit ADR.
   948	
   949	# ============================================================================
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

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '300,390p'" in /Users/madsadmin/code/CortexOS
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
   386	- **Severity:** warn — voice/tone classifier flagged output as violating a tenant `tone_rule` row
   387	- **Trigger:** Output drafted by an agent matches a tenant-defined `tone_rule` violation pattern (e.g. tenant prohibits "absolutely" in customer-facing comms; output contained it)
   388	- **Phase:** `gating_failed`
   389	- **Routing:** `operator_chat_id`
   390	- **Payload fields:** `tone_rule_id`, `pattern_violated`, `output_snippet_redacted`, `agent_name`, `tenant_slug`

exec
/bin/zsh -lc "nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '1,80p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '160,270p;360,380p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   360	# §5 — Migration approach (cross-reference to companion SQL)
   361	# ============================================================================
   362	
   363	migration:
   364	  sql_file: docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
   365	  rollback_sql_file: docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
   366	  status: drafted (Phase 4); execution against migration-test tenant scheduled for Phase 5
   367	  rollback_strategy: |
   368	    All v0.2 additions are nullable columns + new tables. Rollback = DROP TABLE on the 3 new tables + DROP COLUMN on the 6 added fields. No v0.1 data is mutated; v0.1 reads continue working after rollback. Migration SQL ships with companion v0.2-to-v0.1.sql (Phase 4 deliverable; landed in same commit).
   369	
   370	  prerequisite_extensions:
   371	    - pgvector (already enabled at Day-4 §6.5; verify version >= 0.8.0 for HNSW support)
   372	
   373	  decision_log_phase_implication: |
   374	    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
   375	
   376	# ============================================================================
   377	# §6 — Open questions added in v0.2
   378	# ============================================================================
   379	# Three new questions; resolved at Codex ratification OR at first pilot data.
   380	# ============================================================================

exec
/bin/zsh -lc 'rg -n "janitor_last_run|janitor_dedup_threshold|dedup_threshold" docs/verticals/recruitment/vertical-schema*.yaml docs/verticals/recruitment/migrations/*.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:398:    'janitor_last_run',

exec
/bin/zsh -lc "rg -n \"1\\.1\\.2|60s|429|rate-limit|rate limit|backoff|recent_edit|approved_after_edit|outcome\" docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:52:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:53:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:247:          Enum: ["approved_verbatim", "approved_after_edit", "rejected", "deferred"]. `deferred` indicates operator returned to inbox without resolving (4h timeout case).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:350:  recent_edit_drives_retraining:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:302:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:318:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:326:  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:580:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:711:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:830:    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:976:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:16:--     recent_edit_drives_retraining); also JSONB-backed in entity_links.metadata
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:138:-- §5 — Create recent_edit table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:141:CREATE TABLE IF NOT EXISTS recent_edit (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:151:  resolution             TEXT        NOT NULL CHECK (resolution IN ('approved_verbatim', 'approved_after_edit', 'rejected', 'deferred')),
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

codex
I’ve found multiple load-bearing citation and policy mismatches. The strongest ones are in autosend line anchors, Gate A/ESC routing, and a rate-limit citation that points to a section that does not exist.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '380,410p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
/bin/zsh -lc 'rg -n "janitor_dedup_threshold|janitor_last_run|tenant_adapters_config_additions" docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:745:tenant_adapters_config_additions:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:398:    'janitor_last_run',

exec
/bin/zsh -lc 'rg -n "AgentMail|Composio|packages/harness/cortextos|stock KB|kb-|cortextOS.*brain|Brain UI" agents/recruitment/janitor/agent.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
41:- Brain UI "Run Janitor now" button → triggers via internal API

exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '80,105p;420,455p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   420	---
   421	
   422	## §8 — Per-tenant override
   423	
   424	Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
   425	
   426	```sql
   427	INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
   428	VALUES (
   429	  'acme-fintech',
   430	  'autosend_policy',
   431	  '{
   432	    "tier_overrides": {
   433	      "bullhorn_note_internal": "yellow",
   434	      "linkedin_connection_request": "orange",
   435	      "bullhorn_candidate_dedupe": "orange"
   436	    },
   437	    "blocked_recipients": [
   438	      "competitor-employees@*",
   439	      "specific.email@example.com"
   440	    ],
   441	    "approval_routing": {
   442	      "default_recipient": "<telegram-chat-id-from-secrets-env>",
   443	      "escalation_chain": ["operator", "owner"]
   444	    },
   445	    "approval_timeouts": {
   446	      "default": "PT4H",
   447	      "twilio_sms_send": "PT30M",
   448	      "xero_reminder_send_customer": "PT24H"
   449	    },
   450	    "sampling_rates": {
   451	      "bullhorn_candidate_dedupe": 1,
   452	      "linkedin_connection_request": 3
   453	    }
   454	  }'::jsonb,
   455	  TRUE

codex
REJECTED

1. Incorrect autosend citation for `bullhorn_candidate_dedupe`. Line 69 claims `bullhorn_candidate_dedupe` exists in `autosend-policy.yaml` line 69, but line 69 is `irreversible: false` for `operator_notify_telegram`; the action type is actually at `agents/_shared/autosend-policy.yaml` lines 147-152. Fix the citation to the real runtime policy line range.

2. Gate A escalation routing contradicts the escalation catalogue and the artefact itself. Line 187 says merge-confidence Gate A failures fire `ESC_DUPLICATE_DETECTED`, but the catalogue defines that code for confidence `≥ 0.85` human-review cases, not `<0.85` rejects, and line 213 says Janitor does not use it for `<0.85` rejects. Fix §5 so low-confidence pairs are silently discarded or logged under the correct Gate A failure code, and reserve `ESC_DUPLICATE_DETECTED` for catalogue-defined review cases.

3. Fabricated rate-limit citation. Line 97 cites “§1.1.2 of v0.2 supplement” for a 60s Bullhorn 429 backoff, but `vertical-schema.v0.2-supplement.yaml` has no §1.1.2 and contains no 60s/429 backoff rule. Replace with a valid Bullhorn/rate-limit source or remove the claimed backoff.

4. Undocumented tenant config keys violate schema-before-code. Lines 42, 95, 166, and 275 depend on `tenant_adapters.config.janitor_dedup_threshold` and `janitor_last_run`, but `vertical-schema.v0.3-supplement.yaml` §4 documents only `cash_conductor_last_run`, `concierge_last_poll`, and `concierge_send_window`; the Janitor keys only appear as migration allowlist entries. Add canonical schema/supplement definitions for the Janitor config keys before agent.md relies on them.

5. Gate B miss trigger is misstated against the catalogue. Line 214 says `ESC_GATE_B_MISS` fires when either independent threshold is missed for 3 consecutive runs, but the catalogue trigger at `escalation-codes.md` lines 377-383 describes a per-window local Gate B miss and even gives an inaccurate “AND” example. Align the agent.md and catalogue on the exact Janitor trigger semantics before ratification.
tokens used
101,109
REJECTED

1. Incorrect autosend citation for `bullhorn_candidate_dedupe`. Line 69 claims `bullhorn_candidate_dedupe` exists in `autosend-policy.yaml` line 69, but line 69 is `irreversible: false` for `operator_notify_telegram`; the action type is actually at `agents/_shared/autosend-policy.yaml` lines 147-152. Fix the citation to the real runtime policy line range.

2. Gate A escalation routing contradicts the escalation catalogue and the artefact itself. Line 187 says merge-confidence Gate A failures fire `ESC_DUPLICATE_DETECTED`, but the catalogue defines that code for confidence `≥ 0.85` human-review cases, not `<0.85` rejects, and line 213 says Janitor does not use it for `<0.85` rejects. Fix §5 so low-confidence pairs are silently discarded or logged under the correct Gate A failure code, and reserve `ESC_DUPLICATE_DETECTED` for catalogue-defined review cases.

3. Fabricated rate-limit citation. Line 97 cites “§1.1.2 of v0.2 supplement” for a 60s Bullhorn 429 backoff, but `vertical-schema.v0.2-supplement.yaml` has no §1.1.2 and contains no 60s/429 backoff rule. Replace with a valid Bullhorn/rate-limit source or remove the claimed backoff.

4. Undocumented tenant config keys violate schema-before-code. Lines 42, 95, 166, and 275 depend on `tenant_adapters.config.janitor_dedup_threshold` and `janitor_last_run`, but `vertical-schema.v0.3-supplement.yaml` §4 documents only `cash_conductor_last_run`, `concierge_last_poll`, and `concierge_send_window`; the Janitor keys only appear as migration allowlist entries. Add canonical schema/supplement definitions for the Janitor config keys before agent.md relies on them.

5. Gate B miss trigger is misstated against the catalogue. Line 214 says `ESC_GATE_B_MISS` fires when either independent threshold is missed for 3 consecutive runs, but the catalogue trigger at `escalation-codes.md` lines 377-383 describes a per-window local Gate B miss and even gives an inaccurate “AND” example. Align the agent.md and catalogue on the exact Janitor trigger semantics before ratification.
