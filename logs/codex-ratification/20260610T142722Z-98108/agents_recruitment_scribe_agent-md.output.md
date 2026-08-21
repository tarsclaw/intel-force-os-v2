Reading prompt from stdin...
OpenAI Codex v0.132.0
--------
workdir: /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
model: gpt-5.5
provider: openai
approval: never
sandbox: workspace-write [workdir, /tmp, $TMPDIR]
reasoning effort: none
reasoning summaries: none
session id: 019eb1ee-4720-7ea0-8a86-49695c95add3
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

Path: agents/recruitment/scribe/agent.md

--- BEGIN ARTEFACT ---

# Scribe — the data spine

**Status:** Proposed.
**Build state (post-W6 build slice, 2026-06-10):** the W6 build slice is BUILT on branch `worktree-agent-a59f16e915e384257`: `cycle.sh` (10-step, 4 modes), `validate.sh` (Gate A G1-G8), `context.sh`, `cleanup.sh`, `tools.yaml`, 5 `bin/` helpers, 3 fixtures + 3 deterministic DB-backed fixture suites — all green under `scripts/build-gate.sh`. This document was reconciled to the built Granola-poll reality in the round-2 fix pass (Codex round-1 findings 1-4). **What has NOT happened:** no live Bullhorn or Granola call — Bullhorn dev creds are EMPTY, the `@ifos/bullhorn` CLI bridge is the Janitor build slice's parallel deliverable (Scribe consumes it only through `bin/bh-bridge.sh`), the Granola IFOS-side OAuth token is not on disk, and `@ifos/granola` has no built CLI. Live smoke is founder-gated (see §8). Earlier history: Day-20 W4 bilateral pass + R19 substantive fixes; pre-pivot Fathom/Fireflies prose removed 2026-06-10 (see vendor note below).
**Vendor note (Day-29 pivot, founder-decided 2026-06-03):** the v1.0 transcript vendor is **Granola** (`@ifos/granola`; official MCP server mcp.granola.ai/mcp). The original W3 draft of this document specified a webhook-driven flow from Fathom/Fireflies; that is PRE-PIVOT history, not the v1.0 path (no Fathom/Fireflies signup, connector, or webhook contract exists in v1.0). Granola publishes no webhooks, so the operational trigger is a **poll-sweep**; a generic verified-webhook surface is retained as a secondary mode (§2). This reconciliation is contract-prose truth-up only — the §10 status flip remains founder-gated and is NOT exercised here.
**Per-component state (honest, verified 2026-06-10):** `cycle.sh`/`validate.sh`/`context.sh`/`cleanup.sh`/`bin/*` BUILT + fixture-proven; `context.sh` reads `tenant_adapters.config` (v0.4 keys `bullhorn_corporation_id` + `granola_workspace_id`) with `IFOS_FORCE_*` env fallbacks for fixtures; LLM extraction path EXISTS but is opt-in (`IFOS_SCRIBE_USE_LLM=1`) — fixtures run the deterministic extractor; the voice classifier is NOT built (notes carry honest `unscored/no_corpus` or `unscored/no_classifier`); `bin/bh-bridge.sh` conforms to the agreed `@ifos/bullhorn` CLI contract (review-scribe.md orchestrator ruling) and degrades honestly (exit 3 `unavailable`, no fake writes) until the Janitor bridge lands.
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
**Build complexity:** M (1 week) per ULTRAPLAN A3 line 526.
**Tier:** Tier 2 (event-driven — Granola poll-sweep cron + secondary webhook mode; not persistent PTY) per ULTRAPLAN A3 line 518 (drafted pre-pivot as "webhook-driven"; the tier classification is unchanged by the trigger swap).

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Scribe ingests a call transcript from Granola (`@ifos/granola`; discovered by a 5-minute poll-sweep of meetings since the last poll — Granola publishes no webhooks; Ringover deferred to v1.1+) and produces TWO outputs per meeting:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contact / brief / opportunity / placement per the call context; contractor is NOT a v1.0 resolution target — see §3), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS) **except for Opportunity, which is cache-only/vault-only at v1.0** (§3); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of the poll-sweep discovering the finished meeting, per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1 — with the honest `unscored` state while the classifier is unbuilt (§5 G3 warn-when-unscored).

---

## §2 — Invocation surface

### Granola poll-sweep (v1.0 PRIMARY operational trigger)

```bash
cycle.sh --mode poll-sweep        # 5-minute cron (default mode)
```

Granola publishes no webhooks, so the operational trigger is a 5-minute cron
that lists meetings since `CTX_GRANOLA_LAST_POLL` (`@ifos/granola`
`list-meetings --since <ISO>`; `granola_meetings_polled` discovery row) and
runs Steps 2-10 per new meeting. The Step-1 `webhook_verified` marker is
emitted honestly with `method:poll; signature:not_applicable` — there is no
external webhook input to verify in this mode, and Gate A G1 accepts
`{verified, not_applicable}` while hard-failing `{invalid, missing}`.
`--dry-run` runs the sweep through Step 7 only (no Step 8/9 writes;
`dry_run_writes_skipped` row).

### Generic verified webhook (v1.0 SECONDARY mode — supported, not the operational path)

```bash
cycle.sh --mode webhook --payload <json file> \
  ( --signature sha256=<hex> | --bearer <token> )
```

The implementation also carries a generic per-call webhook surface for any
future provider that does push: HMAC-SHA256 over the payload file (secret
`$SCRIBE_WEBHOOK_SECRET`, `openssl dgst`) or bearer-token compare. Signature
mismatch → `ESC_INPUT_VALIDATION_FAIL` + `webhook_verified` row with
`result:invalid; rejected:401` + exit 1 (the HTTP layer maps this to 401).
The payload carries the meeting metadata (`call_id`, `metadata.title`,
`metadata.end_time`, `duration_seconds`, `participants`,
`metadata.notes_markdown`). No v1.0 provider pushes to this surface —
Granola is poll-only.

### Manual trigger (v1.0 — debugging / replay)

```bash
ifosctl scribe replay --tenant <slug> --call-id <granola_meeting_id>
# implemented as: cycle.sh --mode replay --call-id <meeting_id>
```

Useful when a poll window was missed or a transcript needs reprocessing after
a taxonomy update.

### Pre-pivot note (historical)

The W3 draft of this section specified Fathom (HMAC) / Fireflies (bearer)
webhooks as the v1.0 primary path. That was superseded by the Day-29 Granola
pivot (founder, 2026-06-03); no Fathom/Fireflies connector, signup, or
contract exists in v1.0.

### v1.1+ surfaces (deferred)

- Telegram command (`@ifos_bot scribe replay <call-id>`)
- Brain UI per-call "Reprocess" button
- Brain UI "Confidence audit" view showing extraction confidence histograms

---

## §3 — Output shape

Two outputs per meeting. Both write atomically; Step-9 failure rolls back Step 8 (best-effort — §4 Step 9 + §9 Q5). The Gate-B `recent_edit` row is only inserted after Step 9 settles (the table is append-only for `ifos_app`), so a rolled-back write never enters the edit-rate denominator.

### Output 1 — Bullhorn structured-field writes (≥3 per call)

Target entity inferred from non-firm participant emails matched against the
RLS-scoped IFOS `entities` cache, most-context-specific entity first
(resolution priority: **placement > brief > opportunity > contact >
candidate** — a placed candidate's check-in resolves to the Placement, not
the Candidate):
- 1:1 call with candidate → Candidate entity update
- 1:1 call with client contact → Contact entity update
- Briefing call (consultant + client) → Brief entity update
- Placement check-in (consultant + placed candidate) → Placement entity update
- Opportunity scoping (consultant + prospect) → **cache-only path** (below)

**Contractor is NOT a v1.0 resolution target.** The built resolver's priority
set is exactly the five types above; `contractor` is not in the entity-cache
resolution shape and has no field table or Bullhorn write mapping in this
slice. v1.1+ may add it once the contractor entity lands in the cache + the
vertical schema defines its writable fields — until then it is excluded from
this contract rather than promised and papered over.

**Opportunity output contract (cache-only/vault-only at v1.0).** The Bullhorn
endpoint A3 row covers Candidate / ClientContact / JobOrder / Note /
Placement only at v1.0 — there is no Opportunity PATCH endpoint and no
Bullhorn Note target for it. For a resolved `opportunity` the contract is:
- Output 1 → IFOS-cached Postgres `entities` row update ONLY (the v0.3
  fields `headcount_growth_signal_text` + `hiring_velocity_band` +
  `decision_window_text` per v0.3 supplement §1); the
  `bullhorn_scribe_field_write` action row records
  `bullhorn_push:cache_only_by_design` — no Bullhorn PATCH is attempted.
- Output 2 → vault note ONLY (canonical per ADR-002). Step 9 is skipped with
  a `note_attach_deferred` output row,
  `reason:opportunity_cache_only_no_note_endpoint` — Opportunity is
  **excluded from the "note mirrored to Bullhorn" promise**; a consultant
  reads it in the vault/Brain UI until a v1.1+ Bullhorn surface exists.

Minimum 3 fields extracted per call (Gate A). Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):

| Entity | Canonical fields (schema-verified) |
|---|---|
| Candidate | `location`, `current_role`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (v0.3; enum per supplement §1), `key_skills` (v0.3; list) |
| Contact | `decision_authority` (enum per v0.1 Q5; R-only for Scribe per v0.3 §2 access matrix), `preferred_channel` (v0.3), `next_action_target_date` (v0.3) |
| Brief | `salary_min` + `salary_max`, `start_date_target` (R-only for Scribe; Bullhorn-sourced), `role_type`, `must_haves` (v0.3), `nice_to_haves` (v0.3), `deal_breakers` (v0.3) |
| Placement | `start_date`, `placement_status` (v0.3), `week_1_status_vault_path` (v0.3; vault pointer, not narrative), `satisfaction_signal` (v0.3) |
| Opportunity | `headcount_growth_signal_text` (v0.3), `hiring_velocity_band` (v0.3), `decision_window_text` (v0.3) |

Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Field-name accuracy is enforced at runtime, not by prose: `bin/validate-fields.sh` derives its per-entity allowlist + type/range checks from the schema files themselves (mirroring the `validate_entities_data_v0_3` DB trigger), so Gate A G4/G5 fail any drift between this table and the schema as actually deployed.

Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.

### Output 2 — Tacit-note Markdown attachment

One Markdown note per call, attached to the same Bullhorn entity as Output 1 via the `@ifos/bullhorn` `create-note` surface (through `bin/bh-bridge.sh`) — except Opportunity, which is vault-only at v1.0 (cache-only path above). Structure:

```markdown
# Tacit notes — <Call-context-summary>
**Date:** <ISO-date>  **Duration:** <N> min  **Participants:** <list>

## Things observed that don't fit a structured field

- <Observation 1 — bullet, 1-2 sentences, with transcript timestamp [MM:SS]>
- <Observation 2 — ...>
- ...

## Tone signals

- <Tone signal 1 — e.g., "client sounded frustrated about Bullhorn data quality">
- <Tone signal 2 — ...>

## Open questions for consultant follow-up

- <Open question 1>
- <Open question 2>
```

Length cap: 800 words. Voice-classified (≥0.75). Persistent classifier failure (after 3 retries) is a **hard Gate A failure** — fires `ESC_VOICE_DRIFT` + `validate_gate_a_fail`; the note is NOT attached to Bullhorn (Step 9 is skipped) and is held as a `/tmp`/vault draft flagged "needs consultant review" for manual handling. The placeholder is explicitly a non-success state, never a passing output.

Each tacit-note write emits its own `decision_log` rows: on vault render, `agent_name='scribe'`, `phase='output'`, `output_type='tacit_note_rendered'` carrying `{vault_path, body_sha256, voice_score}` (body NOT in payload per ADR-002 vault/Postgres split); on Bullhorn attach, `phase='action'`, `action_type='bullhorn_note_append_summary'`, `tier='yellow'`, payload carrying `note_payload_hash` + `payload_preview` + the resolved `<entity_type>:<bullhorn_id>` (per §4 Steps 6 + 9).

Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
1. Relationship signal (client warmth, candidate enthusiasm, prior friction)
2. Process friction (consultant complaint, tool gap, time waste)
3. Competitive intel (mentions of competitor agencies / candidates working with others)
4. Pricing/budget signal (off-record indications of room or constraint)
5. Decision-process insight (who actually decides; coffee-machine politics)
6. Calendar / availability nuance (vacation, life events affecting timeline)
7. Cultural fit observation (working style, communication preferences)
8. Risk flag (legal, IR35, compliance, reference concerns)

v1.1+: expand taxonomy based on first 3 pilot tenants' patterns.

---

## §4 — Workflow

10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Steps 0-2 are per-session; Steps 3-10 run per discovered meeting (the poll-sweep iterates; replay/webhook process one call).

```
0. Session start
   → context.sh hydrates: tenant config (tenant_adapters v0.4 keys) + voice
     corpus id + tone rules + recent_edits (drift) + granola plan_tier cache
   → hh_decision_trigger("session_start", "scribe mode=<mode> call_id=<id|NA>")

1. Discovery / webhook verification (mode-dependent)
   → poll-sweep (PRIMARY): @ifos/granola list-meetings --since
     <CTX_GRANOLA_LAST_POLL>; emits webhook_verified with
     "method:poll; signature:not_applicable" (honest — no external input to
     verify) + granola_meetings_polled discovery row (count, window,
     workspace_id)
   → webhook (SECONDARY): HMAC-SHA256 over payload file (secret
     $SCRIBE_WEBHOOK_SECRET) or bearer compare;
     ESC_INPUT_VALIDATION_FAIL on mismatch; reject with 401 (exit 1)
   → replay: single-meeting hydrate; "method:manual_replay;
     signature:not_applicable"
   → hh_decision_output("webhook_verified", "call:<id|sweep>", "provider:granola; …")

2. Bullhorn auth refresh (via bin/bh-bridge.sh refresh ONLY)
   → bridge runs the network-free check-auth probe first: creds/token not
     provisioned → result:unavailable (NO ESC — honest degrade; Gate A G7
     then blocks Bullhorn writes); genuine refresh failure after 2 retries →
     ESC_BULLHORN_AUTH (blocking)
   → hh_decision_output("bullhorn_auth_refreshed", "tenant:<slug>",
     "corporation_id:<id>; result:refreshed|fresh|unavailable|failed")

3. Granola transcript fetch (per meeting)
   → @ifos/granola get-transcript --meeting <id> (PAID-plan tool; pre-guarded
     by CTX_GRANOLA_PLAN_TIER — free tier degrades to notes-only ingest
     BEFORE any wire round-trip)
   → ESC_PROVIDER_FETCH_FAIL (upstream=granola) on failure; retry once 30s
     backoff, then degrade to notes_markdown ingest if present, else skip
   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
     (0600 from birth — umask 177)
   → DECLARED DEVIATION 10: the spec's transcript-side ESC_PII_LEAKAGE_RISK
     is NOT implemented — transcripts inherently contain third-party contact
     data; the /tmp copy is 0600 + purged ≤24h and never leaves the firm
     boundary; the control point for what DOES leave is Gate A G6's
     FULL-note-body scan (Step 7 → validate.sh)
   → hh_decision_output("transcript_fetched", "call:<id>",
     "provider:granola; bytes:<N>; tmp_path:<path>; ingest_mode:<m>; plan_tier:<t>")

4. Participant + entity inference
   → non-firm participant emails (CTX_FIRM_DOMAIN_WHITELIST) matched against
     the RLS-scoped IFOS entities cache; priority placement > brief >
     opportunity > contact > candidate (§3; contractor not in the v1.0 set)
   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
     a Scribe run with no resolvable target cannot produce structured writes)
   → hh_decision_output("entity_resolved", "<entity_type>:<bullhorn_id>",
     "call:<id>; confidence:<N>; match:email_exact")

5. Field extraction (deterministic default; LLM opt-in)
   → bin/extract-fields.sh: deterministic regex extraction
     (fixture-reproducible default) — or the LLM path when
     IFOS_SCRIBE_USE_LLM=1 + key present (json_schema output, deterministic
     fallback on any failure)
   → output = JSON with per-field confidence scores
   → discard fields confidence <0.6 (per Gate A)
   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
   → hh_decision_output("fields_extracted", "<entity_type>:<bullhorn_id>",
     "<N> fields ≥0.6 confidence; extractor:<deterministic|llm_with_deterministic_fallback>")

6. Tacit-note generation (deterministic renderer; voice scored HONESTLY)
   → bin/render-tacit-note.sh: §3 Output 2 shape + 8-category taxonomy +
     tone rules (≤12-word quote clip; no compensation in narrative;
     participant emails masked to local parts)
   → voice score resolution — never faked: numeric only via the test hook /
     future classifier wire-in; otherwise unscored/no_corpus or
     unscored/no_classifier (classifier microservice not built — §8)
   → numeric score <0.75 → note flagged needs_consultant_review; Gate A G3
     hard-fails it (ESC_VOICE_DRIFT); the 3-retry loop applies only to a
     future non-deterministic generator (retries:0 recorded today)
   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md mode 0600
   → hh_decision_output("tacit_note_rendered", "<vault_path>",
     "vault_path:<p>; body_sha256:<h>; voice_score:<s>; words:<N>; retries:<n>")
     — metadata ONLY per ADR-002; body never in payload

7. Field-extraction validation against vertical-schema
   → verify each extracted field name exists in target entity schema
   → verify each extracted value passes per-field type/range checks
   → drop invalid; require ≥3 valid (per Gate A; failure = ESC_SCHEMA_VIOLATION
     per catalogue line 163 — vertical-schema field-constraint violation at write time)
   → on success: hh_decision_output("fields_validated", "<entity_type>:<bullhorn_id>",
     "<N> valid of <M> extracted; dropped:<N-invalid>")
   → on Gate A failure (<3 valid): hh_decision_action("validate_gate_a_fail",
     "<entity_type>:<bullhorn_id>", payload_hash,
     "ESC_SCHEMA_VIOLATION; agent_name:scribe; valid:<N>") and exit 1
     (validate_gate_a_fail is the canonical green-tier action_type registered
     in agents/_shared/autosend-policy.yaml line 119; agent:all; Scribe uses
     the shared signature with agent_name in payload to distinguish.)

8. Bullhorn write — structured fields (yellow tier)
   → primary surface: RLS-scoped IFOS entities-cache UPDATE (the
     validate_entities_data_v0_3 DB trigger re-enforces shapes at write
     time); prior-data snapshot taken for rollback
   → Bullhorn PATCH push via bin/bh-bridge.sh
     update-entity --entity-type <T> --id <N> --patch <json>; push state
     recorded honestly on the action row
     (bullhorn_push:pushed|deferred_bridge_unavailable|cache_only_by_design)
   → opportunity: cache-only by design (§3) — no PATCH attempted
   → on success: hh_decision_action("bullhorn_scribe_field_write",
     "<entity_type>:<bullhorn_id>", payload_hash, payload_preview)
   → the Gate B recent_edit row (resolution='deferred') for this write is
     inserted only AFTER Step 9 settles — recent_edit is append-only for
     ifos_app, so the denominator stays honest by never writing the row for
     a write that gets rolled back
   → on PATCH hard-fail: roll the cache back; ESC_BULLHORN_WRITE_FAIL;
     do NOT proceed to Step 9

9. Bullhorn write — tacit-note attachment (yellow tier)
   → bin/bh-bridge.sh create-note --entity-type <T> --entity-id <N>
     --body-file <vault note> --title <s> (mirror of vault artefact from
     Step 6 — the FULL body, which is why Gate A G6 scans the full body)
   → CLI {ok:false, reason:"unsupported_entity"}: person-scoped fallback
     (create-note --person-id <N>) when the resolved entity IS a person
     (candidate/contact); otherwise honest defer (note_attach_deferred row,
     reason:unsupported_entity) — never faked
   → bridge unavailable: note_attach_deferred row (no yellow row — no
     Bullhorn state changed); opportunity: deferred by design (§3)
   → on success: hh_decision_action("bullhorn_note_append_summary",
     "<entity_type>:<bullhorn_id>", note_payload_hash, payload_preview)
   → on hard failure: rollback Step 8 (best-effort cache restore + reverse
     PATCH); no recent_edit row exists yet (inserted only after this step
     settles), so Gate B's denominator isn't inflated; ESC_BULLHORN_WRITE_FAIL

10. Session close + SLA metric
   → per-call elapsed_seconds anchored to MEETING END TIME (bin/sla-class.sh;
     declared note: stricter than "poll receipt" anchoring and consistent
     with the catalogue's "after call end" wording — poll-sweep latency
     counts against Scribe, honestly)
   → Master brief §8.2 line 597 Bullhorn SLA: "post-call note in Bullhorn within
     10 min". Catalogue ESC_SCRIBE_SLA_MISS triggers (line 443): "summary-render
     >30 min OR note-attach >1h after call end". The two thresholds are
     different scopes — master brief 10-min is the product UX promise; catalogue
     30-min/1h is the alerting threshold (less false alarms).
   → if elapsed > 3600 (1h): fire ESC_SCRIBE_SLA_MISS with `sla_type=note_attach` (per catalogue)
   → if elapsed > 1800 (30 min): fire ESC_SCRIBE_SLA_MISS with `sla_type=summary_render` (per catalogue)
   → if elapsed > 600 (10 min) but ≤ 1800: NO ESC fire — recorded as Gate B
     "10-min miss" in the day-30 report aggregation; counts against Gate B 90% target
   → if elapsed > 300 (5 min) but ≤ 600: info-level (still under product promise)
   → hh_decision_action("scribe_run_complete", "call:<last_id>",
     "mode; calls_processed/skipped; field_writes; note_attaches;
     sla_class:<WORST class across the sweep>")
   → exit 0 (poll-sweep/dry-run always; replay/webhook exit 1 on a per-call
     gate failure)
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` (BUILT — runs between cycle.sh Step 7 and Step 8) enforces:

- G1 — webhook signature state: `verified` or `not_applicable` (poll/replay — no external input exists); `invalid`/`missing` hard-fail
- G2 — ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
- G3 — tacit-note voice classifier ≥0.75 — hard fail on a numeric score below threshold; **warn-when-unscored** (no corpus / no classifier ⇒ a score cannot be honestly computed; warned, never faked)
- G4 — field names exist in target entity per vertical-schema.yaml (+v0.3 supplement)
- G5 — per-field type + range validation passes; ≥3 valid after drops
- G6 — no PII outside firm boundary in the tacit-note narrative — scans the **FULL physical note body** resolved from `tacit_note.vault_path` (Step 9 exports the full body to Bullhorn; the 500-char preview is the audit-row artefact only); fail-closed when the body is unreadable
- G7 — Bullhorn auth refresh succeeded this session (fresh `bullhorn_auth_refreshed` row, result fresh|refreshed; `unavailable`/`failed`/absent blocks all Bullhorn writes)
- G8 — tacit-note word count ≤800 (§3 cap)

Gate A failures fire the per-check ESC class (`ESC_INPUT_VALIDATION_FAIL` / `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` / `ESC_VOICE_DRIFT` / `ESC_SCHEMA_VIOLATION` / `ESC_PII_LEAKAGE_RISK` / `ESC_BULLHORN_AUTH` / `ESC_AGENT_OUTPUT_SHAPE`) + a `validate_gate_a_fail` action row; transcript stays in `/tmp` (auto-purged 24h); operator notified.

### Gate B — Outcome thresholds (success metrics, not block)

Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.

Two metrics:
- **SLA:** ≥90% of webhooks-to-Bullhorn-write within 5 min
- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)

Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).

Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing; likely indicates LLM prompt drift or taxonomy mismatch).

---

## §6 — Escalation codes

Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on field write OR note attach | warn | operator_chat_id |
| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Granola; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream=granola`; also fired when a meeting has neither transcript nor notes to ingest | warn | operator_chat_id |
| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | <3 fields with confidence ≥0.6 | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary detected by Gate A G6's FULL-note-body scan (or the body is unreadable — fail-closed). Note-side only: the transcript-side scan is declared deviation 10 (§4 Step 3) — the note body is what leaves the firm boundary | **blocking** | operator + ifos_oncall |
| `ESC_INPUT_VALIDATION_FAIL` | Webhook signature mismatch (Step 1, mode=webhook only) | warn | operator_chat_id |
| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
| `ESC_SCHEMA_VIOLATION` | Vertical-schema field-constraint violation at write time (Step 7) per catalogue line 163 | warn | operator_chat_id |
| `ESC_SCRIBE_SLA_MISS` | Per catalogue §2.10: summary-render >30 min OR note-attach >1h after call end | warn | operator_chat_id (per catalogue routing); aggregated to Gate B metric |
| `ESC_GATE_B_MISS` | Both Gate B metrics (≥90% within-5-min SLA AND ≤20% structured-field edit-rate) below target for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |

Scribe does NOT use:

- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow

---

## §7 — Voice + tone constraints

Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
  - No identifying language about call participants beyond their professional context
  - No verbatim quotes longer than 12 words from candidate (paraphrase for privacy)
  - No compensation specifics in tacit notes (those go to structured fields only)
- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Build dependencies + live-smoke gates (post-build state, 2026-06-10)

The W6 build slice is BUILT (fixture-proven, no live calls). Remaining ⏸
items gate LIVE OPERATION, not the build:

| Dependency | Source | Status |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
| `validate.sh` Gate A logic (G1-G8) | W6 build slice (this branch) | ✅ built |
| `context.sh` hydration (tenant_adapters v0.4 keys + env fallbacks) | W6 build slice | ✅ built |
| `cycle.sh` orchestration (10-step, 4 modes) | W6 build slice | ✅ built |
| `cleanup.sh` + 5 `bin/` helpers | W6 build slice | ✅ built |
| 3 fixtures + 3 deterministic DB-backed fixture suites | W6 build slice | ✅ built (green in build-gate.sh) |
| Tacit-note taxonomy v0.1 (8 categories, deterministic cues) | §3; founder prune/expand with first pilot | ✅ implemented (v0.1) |
| **Granola: IFOS-side OAuth token on disk** (`@ifos/granola` reads its own token bundle, not the Claude-Code MCP keychain) | Founder OAuth dance | ⏸ |
| **Granola: `@ifos/granola` CLI built** (`list-meetings --since` / `get-transcript --meeting` — expected surface documented at the cycle.sh call sites) | Connector build slice | ⏸ |
| ≥1 recorded meeting in the test workspace | Founder | ⏸ |
| **Bullhorn dev creds provisioned** (BULLHORN_CLIENT_ID/SECRET — EMPTY as of 2026-06-10) | Founder commercial action | ⏸ |
| **`@ifos/bullhorn` CLI bridge** (Janitor build slice, parallel; agreed contract in review-scribe.md) | Janitor branch merge | ⏸ |
| Bullhorn Sub-decision B (write scope) Accepted | Bullhorn partnerships response | ⏸ (Sub-decision A RESOLVED 2026-06-02) |
| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
| Voice-classifier microservice (until then: honest `unscored`) | W4-5 polish — NOT built | ⏸ |
| LLM extraction live use (path built, opt-in `IFOS_SCRIBE_USE_LLM=1`) | Founder cost approval (§9 Q2) | ⏸ |

Pre-pivot rows removed 2026-06-10: Fathom/Fireflies commercial signup + connector + per-tenant provider routing (superseded by the Granola pivot; no longer dependencies of anything).

**Live smoke checklist (founder-gated):** provision Bullhorn sandbox creds → land the Janitor `@ifos/bullhorn` bridge → complete the Granola OAuth dance → record ≥1 meeting → run `cycle.sh --mode replay --call-id <meeting_id>` without `BH_BRIDGE_TEST_MODE`.

---

## §9 — Status + open questions

**Status:** Proposed. W6 build slice BUILT + fixture-proven (this branch); live smoke awaits the §8 ⏸ gates (Bullhorn creds + bridge merge + Granola token + recorded meeting) + Q1 LOI / pilot tenant.

### Open questions for founder review

| # | Question | Resolution path |
|---|---|---|
| Q1 | ~~Fathom vs Fireflies — first-mover provider for v1.0?~~ **RESOLVED 2026-06-03 (Day-29 pivot): Granola is the v1.0 vendor** (founder decision; poll-sweep trigger). Fathom/Fireflies are not in v1.0. | Closed. |
| Q2 | Per-call cost ceiling — LLM extraction + voice classification per call. Budget per pilot tenant? (v1.0 default is the zero-LLM deterministic extractor; this gates enabling `IFOS_SCRIBE_USE_LLM=1`.) | Cost model: ~$0.10-0.30 per call (Claude API + voice classifier). At 50 calls/day per consultant × 5 consultants per tenant = ~$25-75/day per tenant. |
| Q3 | Tacit-note taxonomy v0.1 — 8 categories implemented in §3 above. Founder confidence each is high-value? | Founder review with first pilot tenant's consultants during onboarding; can prune/expand based on actual consultant patterns. |
| Q4 | Webhook replay protection (SECONDARY mode only) — should Scribe reject webhook payloads >5 min old? Moot for the primary poll-sweep path (no inbound webhooks at v1.0). | Recommend yes when a push provider lands; timeout config in tools.yaml then. |
| Q5 | Bullhorn write atomicity — Step 9 rollback of Step 8 on note-attach failure is best-effort PATCH (cache restore + reverse PATCH; the Gate-B recent_edit row is insert-after-settle so it never needs unwinding). Could leave the Bullhorn entity in mid-state. | v1.0 accept; document risk. v1.1+: investigate Bullhorn transaction API if exposed. |
| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
| Q7 | What happens when a transcript references PII outside the tenant's Bullhorn data (e.g., a candidate's spouse's medical condition)? | Control point is the NOTE body (declared deviation 10, §4 Step 3): Gate A G6 full-body scan blocks the note write + fires ESC_PII_LEAKAGE_RISK; the transcript itself stays 0600 in /tmp and is purged ≤24h. Document tenant policy. |

### Gotchas (carried forward from ULTRAPLAN A3 line 527)

1. **Tacit-note extraction is the hard part.** Start with small taxonomy (8 categories above); expand based on consultant feedback. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
2. **Transcript availability varies by Granola plan tier.** `get-transcript` is a PAID-plan tool; free workspaces degrade to notes-only ingest (pre-guarded via plan_tier cache — no wasted wire call). IFOS workspace confirmed Paid (founder 2026-06-03).
3. **LLM hallucination on field extraction is the failure mode** (when the opt-in LLM path is enabled). Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks + deterministic fallback on any failure.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict. The status flip below is FOUNDER-GATED — the 2026-06-10 Granola/built-state reconciliation of this document deliberately did NOT exercise it.

Status flips Proposed → Accepted when:
- Codex Round 4 Phase 2 ratifies
- Founder approves §9 Q3 (taxonomy) — Q1 already RESOLVED by the Day-29 Granola pivot (founder 2026-06-03); Q4 (webhook replay timeout) deferred with the secondary-mode push provider
- Q2 cost model approved with budget cap (gates LLM-path enablement)

Status flips Accepted → In Force when:
- ~~W6 build slice produces all 5 sibling bundle files + 3 fixtures~~ ✅ done 2026-06-10 (this branch; fixture-proven, live smoke pending)
- First production transcript processed end-to-end against migration-test tenant (needs the §8 ⏸ live gates)
- SLA + edit-rate Gate-B metrics measurable
- Codex re-ratifies post-build via `review-agent-bundle.md` skill

Until then: this document is the post-build contract record — reconciled to what was built, with live operation still gated.

*End of Scribe agent.md draft.*

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
I’ll verify the cited local sources and the built bundle shape against the ratification rules, then return only the required verdict format.
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,520p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
     1	# Scribe — the data spine
     2	
     3	**Status:** Proposed.
     4	**Build state (post-W6 build slice, 2026-06-10):** the W6 build slice is BUILT on branch `worktree-agent-a59f16e915e384257`: `cycle.sh` (10-step, 4 modes), `validate.sh` (Gate A G1-G8), `context.sh`, `cleanup.sh`, `tools.yaml`, 5 `bin/` helpers, 3 fixtures + 3 deterministic DB-backed fixture suites — all green under `scripts/build-gate.sh`. This document was reconciled to the built Granola-poll reality in the round-2 fix pass (Codex round-1 findings 1-4). **What has NOT happened:** no live Bullhorn or Granola call — Bullhorn dev creds are EMPTY, the `@ifos/bullhorn` CLI bridge is the Janitor build slice's parallel deliverable (Scribe consumes it only through `bin/bh-bridge.sh`), the Granola IFOS-side OAuth token is not on disk, and `@ifos/granola` has no built CLI. Live smoke is founder-gated (see §8). Earlier history: Day-20 W4 bilateral pass + R19 substantive fixes; pre-pivot Fathom/Fireflies prose removed 2026-06-10 (see vendor note below).
     5	**Vendor note (Day-29 pivot, founder-decided 2026-06-03):** the v1.0 transcript vendor is **Granola** (`@ifos/granola`; official MCP server mcp.granola.ai/mcp). The original W3 draft of this document specified a webhook-driven flow from Fathom/Fireflies; that is PRE-PIVOT history, not the v1.0 path (no Fathom/Fireflies signup, connector, or webhook contract exists in v1.0). Granola publishes no webhooks, so the operational trigger is a **poll-sweep**; a generic verified-webhook surface is retained as a secondary mode (§2). This reconciliation is contract-prose truth-up only — the §10 status flip remains founder-gated and is NOT exercised here.
     6	**Per-component state (honest, verified 2026-06-10):** `cycle.sh`/`validate.sh`/`context.sh`/`cleanup.sh`/`bin/*` BUILT + fixture-proven; `context.sh` reads `tenant_adapters.config` (v0.4 keys `bullhorn_corporation_id` + `granola_workspace_id`) with `IFOS_FORCE_*` env fallbacks for fixtures; LLM extraction path EXISTS but is opt-in (`IFOS_SCRIBE_USE_LLM=1`) — fixtures run the deterministic extractor; the voice classifier is NOT built (notes carry honest `unscored/no_corpus` or `unscored/no_classifier`); `bin/bh-bridge.sh` conforms to the agreed `@ifos/bullhorn` CLI contract (review-scribe.md orchestrator ruling) and degrades honestly (exit 3 `unavailable`, no fake writes) until the Janitor bridge lands.
     7	**Date:** 2026-05-24.
     8	**Author:** Founder (Maddox) + Claude Code.
     9	**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
    10	**Build complexity:** M (1 week) per ULTRAPLAN A3 line 526.
    11	**Tier:** Tier 2 (event-driven — Granola poll-sweep cron + secondary webhook mode; not persistent PTY) per ULTRAPLAN A3 line 518 (drafted pre-pivot as "webhook-driven"; the tier classification is unchanged by the trigger swap).
    12	
    13	---
    14	
    15	## §1 — Output contract (one-paragraph screenshot)
    16	
    17	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    18	
    19	> **Scribe ingests a call transcript from Granola (`@ifos/granola`; discovered by a 5-minute poll-sweep of meetings since the last poll — Granola publishes no webhooks; Ringover deferred to v1.1+) and produces TWO outputs per meeting:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contact / brief / opportunity / placement per the call context; contractor is NOT a v1.0 resolution target — see §3), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS) **except for Opportunity, which is cache-only/vault-only at v1.0** (§3); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of the poll-sweep discovering the finished meeting, per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1 — with the honest `unscored` state while the classifier is unbuilt (§5 G3 warn-when-unscored).
    20	
    21	---
    22	
    23	## §2 — Invocation surface
    24	
    25	### Granola poll-sweep (v1.0 PRIMARY operational trigger)
    26	
    27	```bash
    28	cycle.sh --mode poll-sweep        # 5-minute cron (default mode)
    29	```
    30	
    31	Granola publishes no webhooks, so the operational trigger is a 5-minute cron
    32	that lists meetings since `CTX_GRANOLA_LAST_POLL` (`@ifos/granola`
    33	`list-meetings --since <ISO>`; `granola_meetings_polled` discovery row) and
    34	runs Steps 2-10 per new meeting. The Step-1 `webhook_verified` marker is
    35	emitted honestly with `method:poll; signature:not_applicable` — there is no
    36	external webhook input to verify in this mode, and Gate A G1 accepts
    37	`{verified, not_applicable}` while hard-failing `{invalid, missing}`.
    38	`--dry-run` runs the sweep through Step 7 only (no Step 8/9 writes;
    39	`dry_run_writes_skipped` row).
    40	
    41	### Generic verified webhook (v1.0 SECONDARY mode — supported, not the operational path)
    42	
    43	```bash
    44	cycle.sh --mode webhook --payload <json file> \
    45	  ( --signature sha256=<hex> | --bearer <token> )
    46	```
    47	
    48	The implementation also carries a generic per-call webhook surface for any
    49	future provider that does push: HMAC-SHA256 over the payload file (secret
    50	`$SCRIBE_WEBHOOK_SECRET`, `openssl dgst`) or bearer-token compare. Signature
    51	mismatch → `ESC_INPUT_VALIDATION_FAIL` + `webhook_verified` row with
    52	`result:invalid; rejected:401` + exit 1 (the HTTP layer maps this to 401).
    53	The payload carries the meeting metadata (`call_id`, `metadata.title`,
    54	`metadata.end_time`, `duration_seconds`, `participants`,
    55	`metadata.notes_markdown`). No v1.0 provider pushes to this surface —
    56	Granola is poll-only.
    57	
    58	### Manual trigger (v1.0 — debugging / replay)
    59	
    60	```bash
    61	ifosctl scribe replay --tenant <slug> --call-id <granola_meeting_id>
    62	# implemented as: cycle.sh --mode replay --call-id <meeting_id>
    63	```
    64	
    65	Useful when a poll window was missed or a transcript needs reprocessing after
    66	a taxonomy update.
    67	
    68	### Pre-pivot note (historical)
    69	
    70	The W3 draft of this section specified Fathom (HMAC) / Fireflies (bearer)
    71	webhooks as the v1.0 primary path. That was superseded by the Day-29 Granola
    72	pivot (founder, 2026-06-03); no Fathom/Fireflies connector, signup, or
    73	contract exists in v1.0.
    74	
    75	### v1.1+ surfaces (deferred)
    76	
    77	- Telegram command (`@ifos_bot scribe replay <call-id>`)
    78	- Brain UI per-call "Reprocess" button
    79	- Brain UI "Confidence audit" view showing extraction confidence histograms
    80	
    81	---
    82	
    83	## §3 — Output shape
    84	
    85	Two outputs per meeting. Both write atomically; Step-9 failure rolls back Step 8 (best-effort — §4 Step 9 + §9 Q5). The Gate-B `recent_edit` row is only inserted after Step 9 settles (the table is append-only for `ifos_app`), so a rolled-back write never enters the edit-rate denominator.
    86	
    87	### Output 1 — Bullhorn structured-field writes (≥3 per call)
    88	
    89	Target entity inferred from non-firm participant emails matched against the
    90	RLS-scoped IFOS `entities` cache, most-context-specific entity first
    91	(resolution priority: **placement > brief > opportunity > contact >
    92	candidate** — a placed candidate's check-in resolves to the Placement, not
    93	the Candidate):
    94	- 1:1 call with candidate → Candidate entity update
    95	- 1:1 call with client contact → Contact entity update
    96	- Briefing call (consultant + client) → Brief entity update
    97	- Placement check-in (consultant + placed candidate) → Placement entity update
    98	- Opportunity scoping (consultant + prospect) → **cache-only path** (below)
    99	
   100	**Contractor is NOT a v1.0 resolution target.** The built resolver's priority
   101	set is exactly the five types above; `contractor` is not in the entity-cache
   102	resolution shape and has no field table or Bullhorn write mapping in this
   103	slice. v1.1+ may add it once the contractor entity lands in the cache + the
   104	vertical schema defines its writable fields — until then it is excluded from
   105	this contract rather than promised and papered over.
   106	
   107	**Opportunity output contract (cache-only/vault-only at v1.0).** The Bullhorn
   108	endpoint A3 row covers Candidate / ClientContact / JobOrder / Note /
   109	Placement only at v1.0 — there is no Opportunity PATCH endpoint and no
   110	Bullhorn Note target for it. For a resolved `opportunity` the contract is:
   111	- Output 1 → IFOS-cached Postgres `entities` row update ONLY (the v0.3
   112	  fields `headcount_growth_signal_text` + `hiring_velocity_band` +
   113	  `decision_window_text` per v0.3 supplement §1); the
   114	  `bullhorn_scribe_field_write` action row records
   115	  `bullhorn_push:cache_only_by_design` — no Bullhorn PATCH is attempted.
   116	- Output 2 → vault note ONLY (canonical per ADR-002). Step 9 is skipped with
   117	  a `note_attach_deferred` output row,
   118	  `reason:opportunity_cache_only_no_note_endpoint` — Opportunity is
   119	  **excluded from the "note mirrored to Bullhorn" promise**; a consultant
   120	  reads it in the vault/Brain UI until a v1.1+ Bullhorn surface exists.
   121	
   122	Minimum 3 fields extracted per call (Gate A). Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):
   123	
   124	| Entity | Canonical fields (schema-verified) |
   125	|---|---|
   126	| Candidate | `location`, `current_role`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (v0.3; enum per supplement §1), `key_skills` (v0.3; list) |
   127	| Contact | `decision_authority` (enum per v0.1 Q5; R-only for Scribe per v0.3 §2 access matrix), `preferred_channel` (v0.3), `next_action_target_date` (v0.3) |
   128	| Brief | `salary_min` + `salary_max`, `start_date_target` (R-only for Scribe; Bullhorn-sourced), `role_type`, `must_haves` (v0.3), `nice_to_haves` (v0.3), `deal_breakers` (v0.3) |
   129	| Placement | `start_date`, `placement_status` (v0.3), `week_1_status_vault_path` (v0.3; vault pointer, not narrative), `satisfaction_signal` (v0.3) |
   130	| Opportunity | `headcount_growth_signal_text` (v0.3), `hiring_velocity_band` (v0.3), `decision_window_text` (v0.3) |
   131	
   132	Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Field-name accuracy is enforced at runtime, not by prose: `bin/validate-fields.sh` derives its per-entity allowlist + type/range checks from the schema files themselves (mirroring the `validate_entities_data_v0_3` DB trigger), so Gate A G4/G5 fail any drift between this table and the schema as actually deployed.
   133	
   134	Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
   135	
   136	### Output 2 — Tacit-note Markdown attachment
   137	
   138	One Markdown note per call, attached to the same Bullhorn entity as Output 1 via the `@ifos/bullhorn` `create-note` surface (through `bin/bh-bridge.sh`) — except Opportunity, which is vault-only at v1.0 (cache-only path above). Structure:
   139	
   140	```markdown
   141	# Tacit notes — <Call-context-summary>
   142	**Date:** <ISO-date>  **Duration:** <N> min  **Participants:** <list>
   143	
   144	## Things observed that don't fit a structured field
   145	
   146	- <Observation 1 — bullet, 1-2 sentences, with transcript timestamp [MM:SS]>
   147	- <Observation 2 — ...>
   148	- ...
   149	
   150	## Tone signals
   151	
   152	- <Tone signal 1 — e.g., "client sounded frustrated about Bullhorn data quality">
   153	- <Tone signal 2 — ...>
   154	
   155	## Open questions for consultant follow-up
   156	
   157	- <Open question 1>
   158	- <Open question 2>
   159	```
   160	
   161	Length cap: 800 words. Voice-classified (≥0.75). Persistent classifier failure (after 3 retries) is a **hard Gate A failure** — fires `ESC_VOICE_DRIFT` + `validate_gate_a_fail`; the note is NOT attached to Bullhorn (Step 9 is skipped) and is held as a `/tmp`/vault draft flagged "needs consultant review" for manual handling. The placeholder is explicitly a non-success state, never a passing output.
   162	
   163	Each tacit-note write emits its own `decision_log` rows: on vault render, `agent_name='scribe'`, `phase='output'`, `output_type='tacit_note_rendered'` carrying `{vault_path, body_sha256, voice_score}` (body NOT in payload per ADR-002 vault/Postgres split); on Bullhorn attach, `phase='action'`, `action_type='bullhorn_note_append_summary'`, `tier='yellow'`, payload carrying `note_payload_hash` + `payload_preview` + the resolved `<entity_type>:<bullhorn_id>` (per §4 Steps 6 + 9).
   164	
   165	Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
   166	1. Relationship signal (client warmth, candidate enthusiasm, prior friction)
   167	2. Process friction (consultant complaint, tool gap, time waste)
   168	3. Competitive intel (mentions of competitor agencies / candidates working with others)
   169	4. Pricing/budget signal (off-record indications of room or constraint)
   170	5. Decision-process insight (who actually decides; coffee-machine politics)
   171	6. Calendar / availability nuance (vacation, life events affecting timeline)
   172	7. Cultural fit observation (working style, communication preferences)
   173	8. Risk flag (legal, IR35, compliance, reference concerns)
   174	
   175	v1.1+: expand taxonomy based on first 3 pilot tenants' patterns.
   176	
   177	---
   178	
   179	## §4 — Workflow
   180	
   181	10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Steps 0-2 are per-session; Steps 3-10 run per discovered meeting (the poll-sweep iterates; replay/webhook process one call).
   182	
   183	```
   184	0. Session start
   185	   → context.sh hydrates: tenant config (tenant_adapters v0.4 keys) + voice
   186	     corpus id + tone rules + recent_edits (drift) + granola plan_tier cache
   187	   → hh_decision_trigger("session_start", "scribe mode=<mode> call_id=<id|NA>")
   188	
   189	1. Discovery / webhook verification (mode-dependent)
   190	   → poll-sweep (PRIMARY): @ifos/granola list-meetings --since
   191	     <CTX_GRANOLA_LAST_POLL>; emits webhook_verified with
   192	     "method:poll; signature:not_applicable" (honest — no external input to
   193	     verify) + granola_meetings_polled discovery row (count, window,
   194	     workspace_id)
   195	   → webhook (SECONDARY): HMAC-SHA256 over payload file (secret
   196	     $SCRIBE_WEBHOOK_SECRET) or bearer compare;
   197	     ESC_INPUT_VALIDATION_FAIL on mismatch; reject with 401 (exit 1)
   198	   → replay: single-meeting hydrate; "method:manual_replay;
   199	     signature:not_applicable"
   200	   → hh_decision_output("webhook_verified", "call:<id|sweep>", "provider:granola; …")
   201	
   202	2. Bullhorn auth refresh (via bin/bh-bridge.sh refresh ONLY)
   203	   → bridge runs the network-free check-auth probe first: creds/token not
   204	     provisioned → result:unavailable (NO ESC — honest degrade; Gate A G7
   205	     then blocks Bullhorn writes); genuine refresh failure after 2 retries →
   206	     ESC_BULLHORN_AUTH (blocking)
   207	   → hh_decision_output("bullhorn_auth_refreshed", "tenant:<slug>",
   208	     "corporation_id:<id>; result:refreshed|fresh|unavailable|failed")
   209	
   210	3. Granola transcript fetch (per meeting)
   211	   → @ifos/granola get-transcript --meeting <id> (PAID-plan tool; pre-guarded
   212	     by CTX_GRANOLA_PLAN_TIER — free tier degrades to notes-only ingest
   213	     BEFORE any wire round-trip)
   214	   → ESC_PROVIDER_FETCH_FAIL (upstream=granola) on failure; retry once 30s
   215	     backoff, then degrade to notes_markdown ingest if present, else skip
   216	   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
   217	     (0600 from birth — umask 177)
   218	   → DECLARED DEVIATION 10: the spec's transcript-side ESC_PII_LEAKAGE_RISK
   219	     is NOT implemented — transcripts inherently contain third-party contact
   220	     data; the /tmp copy is 0600 + purged ≤24h and never leaves the firm
   221	     boundary; the control point for what DOES leave is Gate A G6's
   222	     FULL-note-body scan (Step 7 → validate.sh)
   223	   → hh_decision_output("transcript_fetched", "call:<id>",
   224	     "provider:granola; bytes:<N>; tmp_path:<path>; ingest_mode:<m>; plan_tier:<t>")
   225	
   226	4. Participant + entity inference
   227	   → non-firm participant emails (CTX_FIRM_DOMAIN_WHITELIST) matched against
   228	     the RLS-scoped IFOS entities cache; priority placement > brief >
   229	     opportunity > contact > candidate (§3; contractor not in the v1.0 set)
   230	   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
   231	     a Scribe run with no resolvable target cannot produce structured writes)
   232	   → hh_decision_output("entity_resolved", "<entity_type>:<bullhorn_id>",
   233	     "call:<id>; confidence:<N>; match:email_exact")
   234	
   235	5. Field extraction (deterministic default; LLM opt-in)
   236	   → bin/extract-fields.sh: deterministic regex extraction
   237	     (fixture-reproducible default) — or the LLM path when
   238	     IFOS_SCRIBE_USE_LLM=1 + key present (json_schema output, deterministic
   239	     fallback on any failure)
   240	   → output = JSON with per-field confidence scores
   241	   → discard fields confidence <0.6 (per Gate A)
   242	   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
   243	   → hh_decision_output("fields_extracted", "<entity_type>:<bullhorn_id>",
   244	     "<N> fields ≥0.6 confidence; extractor:<deterministic|llm_with_deterministic_fallback>")
   245	
   246	6. Tacit-note generation (deterministic renderer; voice scored HONESTLY)
   247	   → bin/render-tacit-note.sh: §3 Output 2 shape + 8-category taxonomy +
   248	     tone rules (≤12-word quote clip; no compensation in narrative;
   249	     participant emails masked to local parts)
   250	   → voice score resolution — never faked: numeric only via the test hook /
   251	     future classifier wire-in; otherwise unscored/no_corpus or
   252	     unscored/no_classifier (classifier microservice not built — §8)
   253	   → numeric score <0.75 → note flagged needs_consultant_review; Gate A G3
   254	     hard-fails it (ESC_VOICE_DRIFT); the 3-retry loop applies only to a
   255	     future non-deterministic generator (retries:0 recorded today)
   256	   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md mode 0600
   257	   → hh_decision_output("tacit_note_rendered", "<vault_path>",
   258	     "vault_path:<p>; body_sha256:<h>; voice_score:<s>; words:<N>; retries:<n>")
   259	     — metadata ONLY per ADR-002; body never in payload
   260	

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
   129	- **Trigger:** Dedup pair held for human approval: confidence in the `0.70–0.85` review band, OR `≥ 0.85` where either record has Bullhorn activity in the last 90 days (recency hold) — per spec-001 §4 band→action table. _(Amended 2026-06-10: supersedes the original ≥0.85-only wording from Ultraplan §8.1 line 511 A2 — the W6-7 Janitor build implements the spec-001 dedup band model, which holds the review band and recency cases rather than auto-merging or silently dropping them. ≥0.85 with no 90d activity auto-merges (yellow) and does NOT fire this code; `< 0.70` silently drops.)_
   130	- **Phase:** `action`
   131	- **Routing:** `operator_chat_id` via Telegram approval gate
   132	- **Entity types:** `candidate`, `contractor` (same matcher, separate entity_type — spec-001 §4 Steps 3-4)
   133	- **Payload fields:** `entity_a_id`, `entity_b_id`, `entity_type` (`candidate`|`contractor`), `confidence_score`, `match_basis` (e.g. `email+phone`, `name+email`, `phone+linkedin`), `hold_reason` (`review_band` | `recency_hold_90d`). Legacy aliases `candidate_a_id`/`candidate_b_id` remain readable for pre-amendment candidate rows.
   134	
   135	#### `ESC_JSL_RED_FLAG`
   136	- **Severity:** warn — Supply Chain Auditor (placeholder for v1.1+ JSL extension)
   137	- **Trigger:** Supply Chain Auditor detected red flag (v1.0 placeholder; SCA agent in v1.1 backlog)
   138	- **Phase:** `gating_failed`
   139	- **Routing:** `operator_chat_id`
   140	- **Status:** v1.0 placeholder; no agent fires this yet. Reserved name.
   141	
   142	#### `ESC_BRIEF_AMBIGUITY`
   143	- **Severity:** warn — Brief Decoder cannot confidently shortlist
   144	- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
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
   191	
   192	### 2.6 — Cross-cutting infrastructure (6 codes)
   193	Source: derived from operational discipline + sequencing-target §5
   194	
   195	#### `ESC_HUMAN_EDITING_LOCK`
   196	- **Severity:** info
   197	- **Trigger:** Manual editing lock held by founder; agent backs off and reschedules
   198	- **Phase:** `gating_failed`
   199	- **Routing:** log-only (no Telegram noise)
   200	- **Payload fields:** `vault_path`, `lock_age_seconds`
   201	
   202	#### `ESC_VAULT_CONCURRENCY`
   203	- **Severity:** warn
   204	- **Trigger:** Generic vault concurrency anomaly not covered by ESC_VAULT_LOCK_TIMEOUT / ESC_VAULT_VERSION_MISMATCH / ESC_VAULT_HUMAN_EDIT_BLOCKED / ESC_VAULT_CASCADE_*
   205	- **Phase:** `gating_failed`
   206	- **Routing:** `operator_chat_id`
   207	- **Payload fields:** `vault_path`, `anomaly_class`, `freeform_reason`
   208	- **Note:** Catch-all; specific codes preferred. New patterns may justify a new code.
   209	
   210	#### `ESC_VAULT_RENAME_RACE`
   211	- **Severity:** warn
   212	- **Trigger:** Rename operation raced with another writer; per vault-concurrency §5
   213	- **Phase:** `gating_failed`
   214	- **Routing:** `operator_chat_id`
   215	- **Payload fields:** `from_path`, `to_path`, `racing_writer_pid`
   216	
   217	#### `ESC_CORTEXTOS_RESTART_REQUESTED`
   218	- **Severity:** info
   219	- **Trigger:** Agent self-requested restart per primitive 6 (`cortextos-ifos bus self-restart`) — typically post-degraded-mode recovery, post-context-overflow handoff
   220	- **Phase:** `agent_handoff`
   221	- **Routing:** log-only
   222	- **Payload fields:** `reason`, `next_session_token`
   223	
   224	#### `ESC_CORTEXTOS_HANDOFF`
   225	- **Severity:** info
   226	- **Trigger:** Context approaching `ctx_handoff_threshold` (default 80%); agent saves state and triggers fresh-session takeover per primitive 1+2 context-rotation
   227	- **Phase:** `agent_handoff`
   228	- **Routing:** log-only
   229	- **Payload fields:** `from_session_id`, `context_pct`, `handoff_summary_path`
   230	
   231	#### `ESC_CORTEXTOS_DEGRADED`
   232	- **Severity:** warn
   233	- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
   234	- **Phase:** `gating_failed`
   235	- **Routing:** `operator_chat_id`
   236	- **Payload fields:** `reason` (e.g. `bullhorn_auth_failed`, `mcp_connector_unreachable`), `degraded_since`, `recovery_condition`
   237	
   238	### 2.7 — Upstream provider auth (8 codes)
   239	Source: derived from v1.0 agent.md adapter references (Bullhorn, Reed, CV-Library, LinkedIn, Gmail, Outlook/MS Graph, Xero, Open Banking)
   240	
   241	#### `ESC_REED_AUTH`
   242	- **Severity:** **blocking** — agent enters degraded mode (cached search results only)
   243	- **Trigger:** Reed jobs-board API OAuth token refresh failed twice OR REST call returned 401 indefinitely
   244	- **Phase:** `gating_failed`
   245	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   246	- **Payload fields:** `failure_type` (`refresh_failed` | `revoked_401`), `last_attempt_at`, `consecutive_failures`
   247	- **Recovery:** founder rotates Reed API key via Reed admin → `_secrets.env` reload
   248	
   249	#### `ESC_CVLIBRARY_AUTH`
   250	- **Severity:** **blocking** — agent degraded (cached search only)
   251	- **Trigger:** CV-Library API OAuth failure (same pattern as ESC_REED_AUTH)
   252	- **Phase:** `gating_failed`
   253	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   254	- **Payload fields:** `failure_type`, `last_attempt_at`, `consecutive_failures`
   255	- **Recovery:** founder rotates CV-Library credentials
   256	
   257	#### `ESC_LINKEDIN_AUTH`
   258	- **Severity:** **blocking** — Sourcing Scout enters degraded mode (no profile fetches; cached only)
   259	- **Trigger:** LinkedIn session cookie / OAuth token revoked or expired (LinkedIn has aggressive anti-bot session invalidation)
   260	- **Phase:** `gating_failed`
   261	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   262	- **Payload fields:** `failure_type` (`session_expired` | `bot_detected_999` | `revoked_401`), `last_attempt_at`
   263	- **Recovery:** founder reauthenticates LinkedIn via Sourcing Scout admin flow
   264	
   265	#### `ESC_GMAIL_AUTH`
   266	- **Severity:** **blocking** — Concierge cannot send candidate emails; falls back to draft-only
   267	- **Trigger:** Google Workspace OAuth token refresh failed; Gmail send returns 401
   268	- **Phase:** `gating_failed`
   269	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   270	- **Payload fields:** `failure_type`, `last_attempt_at`, `affected_tenant_slug`
   271	- **Recovery:** founder reauthenticates Google Workspace OAuth
   272	
   273	#### `ESC_MS_GRAPH_AUTH`
   274	- **Severity:** **blocking** — Concierge Outlook send disabled; drafts-only
   275	- **Trigger:** Microsoft Graph OAuth refresh failed; Outlook sendMail returns 401
   276	- **Phase:** `gating_failed`
   277	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   278	- **Payload fields:** `failure_type`, `last_attempt_at`, `affected_tenant_slug`
   279	- **Recovery:** founder reauthenticates MS Graph OAuth
   280	
   281	#### `ESC_ACCOUNTING_AUTH`
   282	- **Severity:** **blocking** — Cash Conductor degraded (read-only Xero queries from cache; no reminders sent)
   283	- **Trigger:** Xero (or alt accounting provider) OAuth token refresh failed; API returns 401
   284	- **Phase:** `gating_failed`
   285	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   286	- **Payload fields:** `provider` (`xero` | `quickbooks` | `sage` | `freeagent`), `failure_type`, `last_attempt_at`
   287	- **Recovery:** founder reauthenticates accounting OAuth
   288	
   289	#### `ESC_OPEN_BANKING_AUTH`
   290	- **Severity:** **blocking** — Cash Conductor cannot fetch latest bank-feed; falls back to last-known balance
   291	- **Trigger:** Open Banking PSD2 consent expired (90-day mandatory reauth) OR token refresh failed
   292	- **Phase:** `gating_failed`
   293	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   294	- **Payload fields:** `failure_type` (`consent_expired_90d` | `refresh_failed`), `consent_expires_at`, `bank_provider`
   295	- **Recovery:** founder completes Open Banking SCA reauthentication flow
   296	
   297	#### `ESC_OPEN_BANKING_TOKEN_AGING`
   298	- **Severity:** staged — info → warn → blocking as expiry approaches (per Cash Conductor agent.md §6)
   299	- **Trigger:** Open Banking PSD2 consent approaching 90-day expiry. Three stages:
   300	  - **≤30 days remaining:** info — non-urgent operator awareness; nightly health check emits this
   301	  - **≤14 days remaining:** warn — operator nudge to schedule reauth this week
   302	  - **≤7 days remaining:** blocking — Cash Conductor enters degraded mode (cached balance only; no fresh bank-feed reads); operator must complete SCA reauth before token expires
   303	- **Phase:** `gating_failed`
   304	- **Routing:** `operator_chat_id` (info + warn stages); ADD `ifos_oncall_chat_id` at blocking stage
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
   391	- **Payload fields:** `tone_rule_id`, `pattern_violated`, `output_snippet_redacted`, `agent_name`, `tenant_slug`
   392	- **Recovery:** agent re-drafts with violation removed; if persistent, escalates to tone_rule review
   393	
   394	#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
   395	- **Severity:** warn
   396	- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
   397	- **Phase:** `gating_failed`
   398	- **Routing:** `operator_chat_id`
   399	- **Payload fields:** `entity_type`, `field_name`, `extracted_value`, `confidence_score`, `source` (e.g. `companies-house`, `linkedin`, `cv-pdf`), `agent_name`
   400	
   401	#### `ESC_CANDIDATE_DATA_INCOMPLETE`
   402	- **Severity:** warn
   403	- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
   404	- **Phase:** `gating_failed`
   405	- **Routing:** `operator_chat_id`
   406	- **Payload fields:** `candidate_id`, `missing_fields` (list), `shortlist_id`, `brief_id`
   407	
   408	#### `ESC_ADDRESSEE_MISMATCH`
   409	- **Severity:** **blocking** — outbound send refused (whichever agent firing)
   410	- **Trigger:** Outbound recipient resolution failed — addressee does not match the entity whose lifecycle/event triggered the send. Two canonical use cases:
   411	  - **Cash Conductor:** chase/reminder/invoice addressee does not match Bullhorn placement client OR Xero contact (cross-system reconciliation failure between accounting + ATS)
   412	  - **Concierge:** lifecycle-event email recipient does not match the candidate_id whose state is changing (per ULTRAPLAN A6 line 566 verbatim "no candidates emailed under another's name")
   413	- **Phase:** `gating_failed`
   414	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   415	- **Payload fields:** `agent_name`, `mismatch_class` (one of `cash_conductor_xero_bullhorn` | `concierge_candidate_email` | future variant), plus class-specific fields: Cash Conductor → `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`); Concierge → `expected_candidate_bullhorn_id`, `actual_recipient_email`, `event_type`
   416	- **Recovery:** operator reviews; either reconciles manually OR updates one system to match
   417	
   418	#### `ESC_RECONCILIATION_AMBIGUOUS`
   419	- **Severity:** warn — Cash Conductor cannot confidently match incoming payment to a specific invoice
   420	- **Trigger:** Bank-feed payment line cannot be matched to a single Xero invoice; multiple candidates within tolerance
   421	- **Phase:** `gating_failed`
   422	- **Routing:** `operator_chat_id`
   423	- **Payload fields:** `payment_id`, `amount`, `payee_name_raw`, `candidate_invoice_ids` (list), `match_basis` (e.g. `amount_only`, `payee_partial`)
   424	
   425	#### `ESC_DNC_FILTER_HIT`
   426	- **Severity:** **blocking** — outbound (email / SMS / call) refused
   427	- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
   428	- **Phase:** `gating_failed`
   429	- **Routing:** `operator_chat_id`
   430	- **Payload fields:** `recipient_id_hash`, `dnc_list_source`, `dnc_match_reason` (e.g. `explicit_opt_out`, `previous_complaint`, `gdpr_objection`), `action_type_attempted`
   431	
   432	#### `ESC_CONCIERGE_SLA_MISS`
   433	- **Severity:** warn — aggregated to Gate B (not a per-event block)
   434	- **Trigger:** Concierge SLA breached. Three canonical sla_types:
   435	  - `brief_ack`: inbound brief not acknowledged within 4h (default)
   436	  - `customer_reply`: customer reply not actioned within 24h (default)
   437	  - `draft_generation`: lifecycle event → draft generated >30 min (per ULTRAPLAN A6 line 566; aggregated to Gate B per Concierge §1 disposition rather than per-event hard fail)
   438	- **Phase:** `gating_failed`
   439	- **Routing:** `operator_chat_id`
   440	- **Payload fields:** `brief_id` or `candidate_bullhorn_id` or `lifecycle_event_id` (per sla_type), `sla_type` (one of the three above), `sla_threshold_seconds`, `actual_elapsed_seconds`, `tenant_slug`
   441	
   442	#### `ESC_SCRIBE_SLA_MISS`
   443	- **Severity:** warn
   444	- **Trigger:** Scribe SLA breached (default: call summary rendered within 30 min of call end; Bullhorn note attached within 1h)
   445	- **Phase:** `gating_failed`
   446	- **Routing:** `operator_chat_id`
   447	- **Payload fields:** `call_id`, `sla_type` (`summary_render` | `note_attach`), `sla_threshold_seconds`, `actual_elapsed_seconds`, `tenant_slug`
   448	
   449	#### `ESC_LIFECYCLE_STATE_UNKNOWN`
   450	- **Severity:** warn — agent cannot determine entity state for downstream action
   451	- **Trigger:** Lifecycle state is ambiguous or outside the agent's known taxonomy. Two canonical use cases:
   452	  - **Janitor:** placement record has ambiguous lifecycle markers (e.g. start_date present but no end_date AND no `active` flag AND no recent activity); Janitor cannot safely tag or update
   453	  - **Concierge:** Bullhorn state transition is outside the 12-event v1.0 taxonomy (acknowledgement / prep / debrief / placement / rejection / withdrawal / on-hold / start-confirm / 7d-checkin / 30d-checkin / 90d-checkin / nurture); handler logs + skips draft
   454	- **Phase:** `gating_failed`
   455	- **Routing:** `operator_chat_id`
   456	- **Payload fields:** `agent_name`, `entity_type` (`placement` | `candidate_lifecycle_event`), `entity_id`, `ambiguity_class` (Janitor: e.g. `missing_end_date`, `stale_activity`; Concierge: e.g. `unknown_transition`, `out_of_taxonomy`), plus class-specific fields
   457	
   458	---
   459	
   460	## §3 — Reserved codes (not-yet-wired)
   461	
   462	These names are reserved by design documents but no agent fires them in v1.0. Listed here to prevent collision; do not invent codes overlapping these names.
   463	
   464	| Code | Reserved by | Earliest agent |
   465	|---|---|---|
   466	| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
   467	| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
   468	
   469	---
   470	
   471	## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
   472	
   473	`_shared/hook-helpers.sh` must:
   474	
   475	1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
   476	2. Validate `<ESC_CODE>` is a name from §2 above; unknown codes raise `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` (meta-escalation)
   477	3. Resolve `phase` from this catalogue's `Phase:` line (table-driven, not freeform)
   478	4. Default `agent_name` to `${CTX_AGENT_NAME}` or `_renderer` (renderer-only sentinel)
   479	
   480	The catalogue is read at process start via `_shared/escalation-codes-table.sh` (machine-readable companion; deferred to Phase 3 or first use, whichever lands first). If absent, helpers fall back to permissive write (log row only; no Telegram) + emit a one-shot operational warning.
   481	
   482	---
   483	
   484	## §5 — Change protocol
   485	
   486	New codes added here BEFORE wiring into helpers + before any agent references them. Code names case-sensitive (`ESC_[A-Z][A-Z0-9_]*`).
   487	
   488	The Codex Day-7 ratification queue includes this catalogue (item #20 placeholder per `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1). Updates after ratification = new commit + Codex re-review of the diff.
   489	
   490	*End of catalogue (52 active codes + 2 reserved).*

exec
/bin/zsh -lc "rg --files agents/recruitment/scribe agents/_shared docs | sed -n '1,160p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml
agents/recruitment/scribe/cleanup.sh
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
agents/_shared/README.md
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml
agents/recruitment/scribe/fixtures/01-primary.yaml
agents/recruitment/scribe/cycle.sh
agents/recruitment/scribe/README.md
agents/recruitment/scribe/tools.yaml
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
agents/recruitment/scribe/bin/bh-bridge.sh
agents/recruitment/scribe/bin/render-tacit-note.sh
agents/recruitment/scribe/bin/sla-class.sh
agents/recruitment/scribe/bin/validate-fields.sh
agents/recruitment/scribe/bin/extract-fields.sh
agents/recruitment/scribe/validate.sh
agents/recruitment/scribe/context.sh
agents/recruitment/scribe/agent.md
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
docs/build-brief/00-MASTER-BRIEF.md
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
docs/incidents/2026-06-01-intelforce-ai-email-outage.md
docs/specs/ULTRAPLAN.md
docs/specs/_archive-build-handoff.md
docs/specs/PRODUCT-SPEC.md
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
docs/_supplementary/PRD-autonomous-agent.md
docs/_supplementary/build-plan-original.md
docs/_supplementary/README.md
docs/_supplementary/strategic-plan.md
docs/_supplementary/planning-phase-brief.md
docs/_supplementary/technical-strategy-v2.md
docs/_supplementary/execution-plan.md
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
docs/architecture/tenancy-invariants.md
docs/architecture/architecture-cohesion-review.md
docs/architecture/agent-bundle-renderer-design.md
docs/architecture/cortexos-kb-surface-investigation.md
docs/architecture/cortexos-primitive-status.md
docs/architecture/vault-concurrency.md
docs/architecture/second-brain-design.md
docs/runbooks/pii-purge-operational-pattern.md
docs/runbooks/day-4-provisioning.md
docs/runbooks/operational-hygiene-protocol.md
docs/runbooks/tenant-lifecycle.md
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md
docs/artefacts/diagnostic-hays-plc-2026-05-24.md
docs/features/agent-build/00-ORCHESTRATOR.md
docs/features/agent-build/01-LAUNCH.md
docs/features/agent-build/STATUS.md
docs/features/agent-build/02-specs/spec-001-janitor.md
docs/features/agent-build/02-specs/spec-004-concierge.md
docs/features/agent-build/02-specs/spec-002-scribe.md
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md
docs/features/agent-build/02-specs/_TEMPLATE.md
docs/features/agent-build/03-implementation/scribe-summary.md
docs/features/agent-build/04-reviews/review-sourcing-scout.md
docs/features/agent-build/04-reviews/review-scribe.md
docs/features/agent-build/04-reviews/review-janitor.md

codex
The bundle files exist. I’m now checking the high-risk citations and whether the prose matches the actual shared catalogues and policy files.
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '260,620p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
   260	
   261	7. Field-extraction validation against vertical-schema
   262	   → verify each extracted field name exists in target entity schema
   263	   → verify each extracted value passes per-field type/range checks
   264	   → drop invalid; require ≥3 valid (per Gate A; failure = ESC_SCHEMA_VIOLATION
   265	     per catalogue line 163 — vertical-schema field-constraint violation at write time)
   266	   → on success: hh_decision_output("fields_validated", "<entity_type>:<bullhorn_id>",
   267	     "<N> valid of <M> extracted; dropped:<N-invalid>")
   268	   → on Gate A failure (<3 valid): hh_decision_action("validate_gate_a_fail",
   269	     "<entity_type>:<bullhorn_id>", payload_hash,
   270	     "ESC_SCHEMA_VIOLATION; agent_name:scribe; valid:<N>") and exit 1
   271	     (validate_gate_a_fail is the canonical green-tier action_type registered
   272	     in agents/_shared/autosend-policy.yaml line 119; agent:all; Scribe uses
   273	     the shared signature with agent_name in payload to distinguish.)
   274	
   275	8. Bullhorn write — structured fields (yellow tier)
   276	   → primary surface: RLS-scoped IFOS entities-cache UPDATE (the
   277	     validate_entities_data_v0_3 DB trigger re-enforces shapes at write
   278	     time); prior-data snapshot taken for rollback
   279	   → Bullhorn PATCH push via bin/bh-bridge.sh
   280	     update-entity --entity-type <T> --id <N> --patch <json>; push state
   281	     recorded honestly on the action row
   282	     (bullhorn_push:pushed|deferred_bridge_unavailable|cache_only_by_design)
   283	   → opportunity: cache-only by design (§3) — no PATCH attempted
   284	   → on success: hh_decision_action("bullhorn_scribe_field_write",
   285	     "<entity_type>:<bullhorn_id>", payload_hash, payload_preview)
   286	   → the Gate B recent_edit row (resolution='deferred') for this write is
   287	     inserted only AFTER Step 9 settles — recent_edit is append-only for
   288	     ifos_app, so the denominator stays honest by never writing the row for
   289	     a write that gets rolled back
   290	   → on PATCH hard-fail: roll the cache back; ESC_BULLHORN_WRITE_FAIL;
   291	     do NOT proceed to Step 9
   292	
   293	9. Bullhorn write — tacit-note attachment (yellow tier)
   294	   → bin/bh-bridge.sh create-note --entity-type <T> --entity-id <N>
   295	     --body-file <vault note> --title <s> (mirror of vault artefact from
   296	     Step 6 — the FULL body, which is why Gate A G6 scans the full body)
   297	   → CLI {ok:false, reason:"unsupported_entity"}: person-scoped fallback
   298	     (create-note --person-id <N>) when the resolved entity IS a person
   299	     (candidate/contact); otherwise honest defer (note_attach_deferred row,
   300	     reason:unsupported_entity) — never faked
   301	   → bridge unavailable: note_attach_deferred row (no yellow row — no
   302	     Bullhorn state changed); opportunity: deferred by design (§3)
   303	   → on success: hh_decision_action("bullhorn_note_append_summary",
   304	     "<entity_type>:<bullhorn_id>", note_payload_hash, payload_preview)
   305	   → on hard failure: rollback Step 8 (best-effort cache restore + reverse
   306	     PATCH); no recent_edit row exists yet (inserted only after this step
   307	     settles), so Gate B's denominator isn't inflated; ESC_BULLHORN_WRITE_FAIL
   308	
   309	10. Session close + SLA metric
   310	   → per-call elapsed_seconds anchored to MEETING END TIME (bin/sla-class.sh;
   311	     declared note: stricter than "poll receipt" anchoring and consistent
   312	     with the catalogue's "after call end" wording — poll-sweep latency
   313	     counts against Scribe, honestly)
   314	   → Master brief §8.2 line 597 Bullhorn SLA: "post-call note in Bullhorn within
   315	     10 min". Catalogue ESC_SCRIBE_SLA_MISS triggers (line 443): "summary-render
   316	     >30 min OR note-attach >1h after call end". The two thresholds are
   317	     different scopes — master brief 10-min is the product UX promise; catalogue
   318	     30-min/1h is the alerting threshold (less false alarms).
   319	   → if elapsed > 3600 (1h): fire ESC_SCRIBE_SLA_MISS with `sla_type=note_attach` (per catalogue)
   320	   → if elapsed > 1800 (30 min): fire ESC_SCRIBE_SLA_MISS with `sla_type=summary_render` (per catalogue)
   321	   → if elapsed > 600 (10 min) but ≤ 1800: NO ESC fire — recorded as Gate B
   322	     "10-min miss" in the day-30 report aggregation; counts against Gate B 90% target
   323	   → if elapsed > 300 (5 min) but ≤ 600: info-level (still under product promise)
   324	   → hh_decision_action("scribe_run_complete", "call:<last_id>",
   325	     "mode; calls_processed/skipped; field_writes; note_attaches;
   326	     sla_class:<WORST class across the sweep>")
   327	   → exit 0 (poll-sweep/dry-run always; replay/webhook exit 1 on a per-call
   328	     gate failure)
   329	```
   330	
   331	---
   332	
   333	## §5 — Gates
   334	
   335	### Gate A — validate.sh (hard-fail before action)
   336	
   337	Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` (BUILT — runs between cycle.sh Step 7 and Step 8) enforces:
   338	
   339	- G1 — webhook signature state: `verified` or `not_applicable` (poll/replay — no external input exists); `invalid`/`missing` hard-fail
   340	- G2 — ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
   341	- G3 — tacit-note voice classifier ≥0.75 — hard fail on a numeric score below threshold; **warn-when-unscored** (no corpus / no classifier ⇒ a score cannot be honestly computed; warned, never faked)
   342	- G4 — field names exist in target entity per vertical-schema.yaml (+v0.3 supplement)
   343	- G5 — per-field type + range validation passes; ≥3 valid after drops
   344	- G6 — no PII outside firm boundary in the tacit-note narrative — scans the **FULL physical note body** resolved from `tacit_note.vault_path` (Step 9 exports the full body to Bullhorn; the 500-char preview is the audit-row artefact only); fail-closed when the body is unreadable
   345	- G7 — Bullhorn auth refresh succeeded this session (fresh `bullhorn_auth_refreshed` row, result fresh|refreshed; `unavailable`/`failed`/absent blocks all Bullhorn writes)
   346	- G8 — tacit-note word count ≤800 (§3 cap)
   347	
   348	Gate A failures fire the per-check ESC class (`ESC_INPUT_VALIDATION_FAIL` / `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` / `ESC_VOICE_DRIFT` / `ESC_SCHEMA_VIOLATION` / `ESC_PII_LEAKAGE_RISK` / `ESC_BULLHORN_AUTH` / `ESC_AGENT_OUTPUT_SHAPE`) + a `validate_gate_a_fail` action row; transcript stays in `/tmp` (auto-purged 24h); operator notified.
   349	
   350	### Gate B — Outcome thresholds (success metrics, not block)
   351	
   352	Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.
   353	
   354	Two metrics:
   355	- **SLA:** ≥90% of webhooks-to-Bullhorn-write within 5 min
   356	- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
   357	
   358	Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
   359	
   360	Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing; likely indicates LLM prompt drift or taxonomy mismatch).
   361	
   362	---
   363	
   364	## §6 — Escalation codes
   365	
   366	Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:
   367	
   368	| Code | Trigger | Severity | Routing |
   369	|---|---|---|---|
   370	| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   371	| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on field write OR note attach | warn | operator_chat_id |
   372	| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Granola; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream=granola`; also fired when a meeting has neither transcript nor notes to ingest | warn | operator_chat_id |
   373	| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   374	| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | <3 fields with confidence ≥0.6 | warn | operator_chat_id |
   375	| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary detected by Gate A G6's FULL-note-body scan (or the body is unreadable — fail-closed). Note-side only: the transcript-side scan is declared deviation 10 (§4 Step 3) — the note body is what leaves the firm boundary | **blocking** | operator + ifos_oncall |
   376	| `ESC_INPUT_VALIDATION_FAIL` | Webhook signature mismatch (Step 1, mode=webhook only) | warn | operator_chat_id |
   377	| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
   378	| `ESC_SCHEMA_VIOLATION` | Vertical-schema field-constraint violation at write time (Step 7) per catalogue line 163 | warn | operator_chat_id |
   379	| `ESC_SCRIBE_SLA_MISS` | Per catalogue §2.10: summary-render >30 min OR note-attach >1h after call end | warn | operator_chat_id (per catalogue routing); aggregated to Gate B metric |
   380	| `ESC_GATE_B_MISS` | Both Gate B metrics (≥90% within-5-min SLA AND ≤20% structured-field edit-rate) below target for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
   381	| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
   382	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
   383	
   384	Scribe does NOT use:
   385	
   386	- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
   387	
   388	---
   389	
   390	## §7 — Voice + tone constraints
   391	
   392	Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   393	
   394	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
   395	  - No identifying language about call participants beyond their professional context
   396	  - No verbatim quotes longer than 12 words from candidate (paraphrase for privacy)
   397	  - No compensation specifics in tacit notes (those go to structured fields only)
   398	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
   399	- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
   400	
   401	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   402	
   403	---
   404	
   405	## §8 — Build dependencies + live-smoke gates (post-build state, 2026-06-10)
   406	
   407	The W6 build slice is BUILT (fixture-proven, no live calls). Remaining ⏸
   408	items gate LIVE OPERATION, not the build:
   409	
   410	| Dependency | Source | Status |
   411	|---|---|---|
   412	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   413	| `validate.sh` Gate A logic (G1-G8) | W6 build slice (this branch) | ✅ built |
   414	| `context.sh` hydration (tenant_adapters v0.4 keys + env fallbacks) | W6 build slice | ✅ built |
   415	| `cycle.sh` orchestration (10-step, 4 modes) | W6 build slice | ✅ built |
   416	| `cleanup.sh` + 5 `bin/` helpers | W6 build slice | ✅ built |
   417	| 3 fixtures + 3 deterministic DB-backed fixture suites | W6 build slice | ✅ built (green in build-gate.sh) |
   418	| Tacit-note taxonomy v0.1 (8 categories, deterministic cues) | §3; founder prune/expand with first pilot | ✅ implemented (v0.1) |
   419	| **Granola: IFOS-side OAuth token on disk** (`@ifos/granola` reads its own token bundle, not the Claude-Code MCP keychain) | Founder OAuth dance | ⏸ |
   420	| **Granola: `@ifos/granola` CLI built** (`list-meetings --since` / `get-transcript --meeting` — expected surface documented at the cycle.sh call sites) | Connector build slice | ⏸ |
   421	| ≥1 recorded meeting in the test workspace | Founder | ⏸ |
   422	| **Bullhorn dev creds provisioned** (BULLHORN_CLIENT_ID/SECRET — EMPTY as of 2026-06-10) | Founder commercial action | ⏸ |
   423	| **`@ifos/bullhorn` CLI bridge** (Janitor build slice, parallel; agreed contract in review-scribe.md) | Janitor branch merge | ⏸ |
   424	| Bullhorn Sub-decision B (write scope) Accepted | Bullhorn partnerships response | ⏸ (Sub-decision A RESOLVED 2026-06-02) |
   425	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   426	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   427	| Voice-classifier microservice (until then: honest `unscored`) | W4-5 polish — NOT built | ⏸ |
   428	| LLM extraction live use (path built, opt-in `IFOS_SCRIBE_USE_LLM=1`) | Founder cost approval (§9 Q2) | ⏸ |
   429	
   430	Pre-pivot rows removed 2026-06-10: Fathom/Fireflies commercial signup + connector + per-tenant provider routing (superseded by the Granola pivot; no longer dependencies of anything).
   431	
   432	**Live smoke checklist (founder-gated):** provision Bullhorn sandbox creds → land the Janitor `@ifos/bullhorn` bridge → complete the Granola OAuth dance → record ≥1 meeting → run `cycle.sh --mode replay --call-id <meeting_id>` without `BH_BRIDGE_TEST_MODE`.
   433	
   434	---
   435	
   436	## §9 — Status + open questions
   437	
   438	**Status:** Proposed. W6 build slice BUILT + fixture-proven (this branch); live smoke awaits the §8 ⏸ gates (Bullhorn creds + bridge merge + Granola token + recorded meeting) + Q1 LOI / pilot tenant.
   439	
   440	### Open questions for founder review
   441	
   442	| # | Question | Resolution path |
   443	|---|---|---|
   444	| Q1 | ~~Fathom vs Fireflies — first-mover provider for v1.0?~~ **RESOLVED 2026-06-03 (Day-29 pivot): Granola is the v1.0 vendor** (founder decision; poll-sweep trigger). Fathom/Fireflies are not in v1.0. | Closed. |
   445	| Q2 | Per-call cost ceiling — LLM extraction + voice classification per call. Budget per pilot tenant? (v1.0 default is the zero-LLM deterministic extractor; this gates enabling `IFOS_SCRIBE_USE_LLM=1`.) | Cost model: ~$0.10-0.30 per call (Claude API + voice classifier). At 50 calls/day per consultant × 5 consultants per tenant = ~$25-75/day per tenant. |
   446	| Q3 | Tacit-note taxonomy v0.1 — 8 categories implemented in §3 above. Founder confidence each is high-value? | Founder review with first pilot tenant's consultants during onboarding; can prune/expand based on actual consultant patterns. |
   447	| Q4 | Webhook replay protection (SECONDARY mode only) — should Scribe reject webhook payloads >5 min old? Moot for the primary poll-sweep path (no inbound webhooks at v1.0). | Recommend yes when a push provider lands; timeout config in tools.yaml then. |
   448	| Q5 | Bullhorn write atomicity — Step 9 rollback of Step 8 on note-attach failure is best-effort PATCH (cache restore + reverse PATCH; the Gate-B recent_edit row is insert-after-settle so it never needs unwinding). Could leave the Bullhorn entity in mid-state. | v1.0 accept; document risk. v1.1+: investigate Bullhorn transaction API if exposed. |
   449	| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
   450	| Q7 | What happens when a transcript references PII outside the tenant's Bullhorn data (e.g., a candidate's spouse's medical condition)? | Control point is the NOTE body (declared deviation 10, §4 Step 3): Gate A G6 full-body scan blocks the note write + fires ESC_PII_LEAKAGE_RISK; the transcript itself stays 0600 in /tmp and is purged ≤24h. Document tenant policy. |
   451	
   452	### Gotchas (carried forward from ULTRAPLAN A3 line 527)
   453	
   454	1. **Tacit-note extraction is the hard part.** Start with small taxonomy (8 categories above); expand based on consultant feedback. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
   455	2. **Transcript availability varies by Granola plan tier.** `get-transcript` is a PAID-plan tool; free workspaces degrade to notes-only ingest (pre-guarded via plan_tier cache — no wasted wire call). IFOS workspace confirmed Paid (founder 2026-06-03).
   456	3. **LLM hallucination on field extraction is the failure mode** (when the opt-in LLM path is enabled). Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks + deterministic fallback on any failure.
   457	
   458	---
   459	
   460	## §10 — When this document ratifies
   461	
   462	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict. The status flip below is FOUNDER-GATED — the 2026-06-10 Granola/built-state reconciliation of this document deliberately did NOT exercise it.
   463	
   464	Status flips Proposed → Accepted when:
   465	- Codex Round 4 Phase 2 ratifies
   466	- Founder approves §9 Q3 (taxonomy) — Q1 already RESOLVED by the Day-29 Granola pivot (founder 2026-06-03); Q4 (webhook replay timeout) deferred with the secondary-mode push provider
   467	- Q2 cost model approved with budget cap (gates LLM-path enablement)
   468	
   469	Status flips Accepted → In Force when:
   470	- ~~W6 build slice produces all 5 sibling bundle files + 3 fixtures~~ ✅ done 2026-06-10 (this branch; fixture-proven, live smoke pending)
   471	- First production transcript processed end-to-end against migration-test tenant (needs the §8 ⏸ live gates)
   472	- SLA + edit-rate Gate-B metrics measurable
   473	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   474	
   475	Until then: this document is the post-build contract record — reconciled to what was built, with live operation still gated.
   476	
   477	*End of Scribe agent.md draft.*

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
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

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '500,535p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
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
   517	- **Build wave:** v1.0 (week 6–7)
   518	- **Always-on?** Tier 2 — webhook-driven
   519	- **Trigger type:** Webhook from Fathom / Fireflies / Ringover when a call ends
   520	- **CortexOS primitives required:** None per call (stateless between calls)
   521	- **MCP tools required:** Bullhorn (write), Fathom (read), Fireflies (read)
   522	- **Shared modules required:** Voice loader (for tone-detection of tacit notes), decision log writer
   523	- **External APIs:** Fathom webhook, Fireflies webhook, Bullhorn for write-back
   524	- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
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

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,610p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
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
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '180,320p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
   180	
   181	  bullhorn_activity_log_write:
   182	    tier: green
   183	    agent: concierge
   184	    reason: "Internal Bullhorn activity-log entry — NOT customer-visible (separate from bullhorn_note_customer_visible which is orange). Maintains the audit trail in Bullhorn itself so downstream consultant ops see Concierge actions on the candidate's record. Idempotent within payload_hash dedup window. Registered per Codex Fbis-R1 closure 2026-06-02 — Concierge agent.md §4 Step 13 needs this for tier classification of the external write."
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
   211	
   212	  bullhorn_note_append_summary:
   213	    tier: yellow
   214	    agent: scribe
   215	    sample_rate: 20
   216	    reason: "Appends to candidate record; consultant-only visibility; high-volume; format quality needs review"
   217	    irreversible: false
   218	
   219	  linkedin_connection_request:
   220	    tier: yellow
   221	    agent: sourcing-scout
   222	    sample_rate: 5
   223	    reason: "Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy"
   224	    irreversible: true
   225	
   226	  xero_reminder_draft_internal:
   227	    tier: yellow
   228	    agent: cash-conductor
   229	    sample_rate: 10
   230	    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
   231	    irreversible: false
   232	
   233	  bullhorn_note_draft_internal:
   234	    tier: yellow
   235	    agent: concierge
   236	    sample_rate: 10
   237	    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
   238	    irreversible: false
   239	
   240	  bullhorn_scribe_field_write:
   241	    tier: yellow
   242	    agent: scribe
   243	    sample_rate: 10
   244	    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
   245	    irreversible: false
   246	
   247	  accounting_reconciliation_write:
   248	    tier: yellow
   249	    agent: cash-conductor
   250	    sample_rate: 10
   251	    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
   252	    irreversible: false
   253	
   254	  concierge_email_draft:
   255	    tier: yellow
   256	    agent: concierge
   257	    sample_rate: 20
   258	    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
   259	    irreversible: false
   260	
   261	  # ───────────────────────────────────────────────────────────
   262	  # ORANGE — per-action human approval (10 action_types)
   263	  # ───────────────────────────────────────────────────────────
   264	
   265	  bullhorn_note_customer_visible:
   266	    tier: orange
   267	    agent: concierge
   268	    timeout: PT4H
   269	    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"
   270	    irreversible: true
   271	    canonical: true
   272	
   273	  gmail_outlook_send_to_candidate:
   274	    tier: orange
   275	    agent: concierge
   276	    timeout: PT4H
   277	    reason: "Outbound email to candidate; customer-facing; reputation effects"
   278	    irreversible: true
   279	
   280	  twilio_sms_send:
   281	    tier: orange
   282	    agent: concierge
   283	    timeout: PT30M
   284	    reason: "Outbound SMS; high-trust channel; cost-per-send; irreversible"
   285	    irreversible: true
   286	
   287	  calendar_invite_send:
   288	    tier: orange
   289	    agent: concierge
   290	    timeout: PT4H
   291	    reason: "Creates calendar event with attendee notification; visible to attendee"
   292	    irreversible: true
   293	
   294	  email_summary_to_customer:
   295	    tier: orange
   296	    agent: scribe
   297	    timeout: PT4H
   298	    reason: "Outbound email summarising call to customer; customer-facing; format-sensitive"
   299	    irreversible: true
   300	
   301	  xero_reminder_send_customer:
   302	    tier: orange
   303	    agent: cash-conductor
   304	    timeout: PT24H
   305	    reason: "Outbound payment reminder to customer; reputation + collection risk"
   306	    irreversible: true
   307	
   308	  diagnostic_email_send:
   309	    tier: orange
   310	    agent: diagnostic
   311	    timeout: PT4H
   312	    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
   313	    irreversible: true
   314	
   315	  diagnostic_calendar_invite:
   316	    tier: orange
   317	    agent: diagnostic
   318	    timeout: PT4H
   319	    reason: "Books intro call with prospect; reputation + scheduling friction"
   320	    irreversible: true

exec
/bin/zsh -lc 'rg -n "hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits" agents/_shared/voice-loader.sh' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
15:#   hh_load_recent_edits   — query recent_edit for last N days
73:# hh_load_tone_rules [<agent_name>]
79:hh_load_tone_rules() {
135:# hh_load_voice_samples <task_context> [<top_k>]
151:hh_load_voice_samples() {
223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
233:hh_load_recent_edits() {

exec
/bin/zsh -lc 'rg -n "decision_authority|employment_type|key_skills|headcount_growth_signal_text|week_1_status_vault_path|must_haves|preferred_channel|tenant_adapters|granola_workspace_id|bullhorn_corporation_id" docs/verticals/recruitment/vertical-schema*.yaml' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 6 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:59:      employment_type:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:72:      key_skills:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:107:      preferred_channel:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:134:      must_haves:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:190:      week_1_status_vault_path:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:225:      headcount_growth_signal_text:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:284:#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:285:#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:286:#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:352:  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:403:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:404:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:495:      preferred_channel + next_action_target_date; Janitor also dedup-merges).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:502:      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:755:# §4 — tenant_adapters.config keys (6 declarations: 5 v0.3-new + 1 pre-v0.3 canonicalised)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:758:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:759:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:762:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:916:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:918:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:947:  Q1_employment_type_enum_completeness:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:948:    question: Are 6 employment_type enum values sufficient for UK recruitment?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:951:        Keep 6 values as in §1.candidate.employment_type — perm, contract,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:956:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:962:  Q2_key_skills_max_length:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:991:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1003:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1028:      the v0.3-added fields (employment_type, key_skills, preferred_channel,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1029:      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1030:      placement_status, week_1_status_vault_path, satisfaction_signal,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1031:      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1042:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/vertical-schema.yaml:316:      decision_authority:
docs/verticals/recruitment/vertical-schema.yaml:819:  Q5_contact_decision_authority_granularity:
docs/verticals/recruitment/vertical-schema.yaml:821:    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:1:# IFOS recruitment vertical schema v0.4 — tenant_adapters.config keys for
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:9:# v0.4 is an ADDITIVE-ONLY tenant_adapters.config extension. It does NOT
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:15:# tenant_adapters at runtime, replacing the IFOS_FORCE_* env-var fallbacks
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:41:  v0.4 scope is INTENTIONALLY NARROW: 5 new tenant_adapters.config keys, no
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:60:  granola_workspace_id the higher-priority addition (W6 Scribe needs the
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:65:# §1 — tenant_adapters.config additions (5 new top-level keys)
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:68:# Each key is hard-fail-on-unknown via the validate_tenant_adapters_config_v0_4
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:72:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:85:      tenant_adapters WHERE tenant_slug=$1.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:117:      tenant_adapters read path. The TODO(W10-13) marker in context.sh
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:146:  granola_workspace_id:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:162:      (mode 0600); writes workspace_id to tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:172:  bullhorn_corporation_id:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:204:    None. The 14 v0.3 entity field additions (employment_type, key_skills,
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:205:    linkedin_url, preferred_channel, next_action_target_date, must_haves,
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:206:    nice_to_haves, deal_breakers, placement_status, week_1_status_vault_path,
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:207:    satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band,
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:237:    - v0.3 migration applied (validate_tenant_adapters_config_v0_3 trigger active)
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:246:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_4() —
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:249:      granola_workspace_id, bullhorn_corporation_id). Per-key type validation
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:252:      DROP TRIGGER validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:253:      CREATE TRIGGER validate_tenant_adapters_config_v0_4 (re-bind).
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:255:      DROP FUNCTION validate_tenant_adapters_config_v0_3() (no longer
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:298:        Yes — mirror tier into tenant_adapters.config so consumer code can
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:316:        services all tenant orgs. CURRENT v0.4 behavior (no tenant_adapters
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:328:    question: Should bullhorn_region be a tenant_adapters.config key?
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:352:  read per-tenant identifiers from tenant_adapters.config — but the v0.3
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:353:  validate_tenant_adapters_config_v0_3 trigger hard-fails on any of the
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:364:      granola_workspace_id without a second supplement.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:366:      from tenant_adapters at runtime.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.

exec
/bin/zsh -lc 'rg -n "Composio|AgentMail|packages/harness/cortextos|cortextOS|brain|kb-" agents/recruitment/scribe/agent.md' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 exited 1 in 0ms:
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/tools.yaml | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
     1	# Scribe agent — tools.yaml (capability declarations)
     2	#
     3	# Status: built (W6 build slice; cycle.sh/validate.sh/context.sh/cleanup.sh
     4	#         are LIVE against these declarations. Live Bullhorn + Granola smoke
     5	#         remains founder-gated: Bullhorn dev creds EMPTY + Granola IFOS-side
     6	#         OAuth token not on disk + 0 recorded meetings — spec-002 §8/§9).
     7	# Reading order: agent.md §1 (output contract) + §2 (invocation surface) +
     8	#         §4 (workflow + capability dependencies) first.
     9	#
    10	# BRIDGE NOTE (parallel-conflict rule): every @ifos/bullhorn invocation routes
    11	# through agents/recruitment/scribe/bin/bh-bridge.sh — the single
    12	# reconciliation point for the CLI bridge the Janitor build slice owns under
    13	# packages/mcp-connectors/bullhorn. The shim conforms to the AGREED CLI
    14	# contract (orchestrator ruling, review-scribe.md): check-auth (network-free
    15	# provisioned-probe) / refresh ({ok, oauth_expires_at_ms, token_state}) /
    16	# update-entity (--entity-type --id --patch) / create-note (--person-id |
    17	# --entity-type+--entity-id, --body-file, --title; unsupported_entity →
    18	# person-resolution fallback or honest defer). IFOS_TOKEN_DIR is the
    19	# per-tenant token-bundle override; ids are numeric.
    20	#
    21	# Per ADR-003 agent-bundle pattern: tools.yaml declares every external
    22	# capability cycle.sh invokes + the autosend-policy action_type each
    23	# state-changing call emits. cortextOS bus uses this to authorise capability
    24	# invocation per agent (no capability declared here = bus refuses the call).
    25	#
    26	# Scribe consumes BOTH @ifos/bullhorn (write surface) AND @ifos/granola
    27	# (read surface). Vendor delta from agent.md: agent.md describes Fathom /
    28	# Fireflies as the transcript provider; SKELETON uses Granola per Day-29
    29	# vendor pivot (founder confirmed 2026-06-03). cycle.sh Reading-discipline
    30	# note + scribe/agent.md Reading-discipline note document the delta.
    31	#
    32	# Action types referenced below MUST exist in agents/_shared/autosend-policy.yaml.
    33	# Scribe's 2 yellow-tier write action_types (bullhorn_scribe_field_write +
    34	# bullhorn_note_append_summary) are REGISTERED in autosend-policy.yaml
    35	# (re-verified 2026-06-10 — lines 240 + 212 respectively). scribe_cleanup /
    36	# bullhorn_oauth / granola_oauth remain QUEUED (registering them needs an
    37	# agents/_shared edit — outside this build slice's boundary; see the
    38	# registration-status footer for how each is recorded meanwhile).
    39	
    40	version: "0.1"
    41	agent: scribe
    42	
    43	capabilities:
    44	
    45	  # ────────────────────────────────────────────────────────────────────────
    46	  # Bullhorn ATS — invoked via bin/bh-bridge.sh (see BRIDGE NOTE above).
    47	  # cycle.sh Step 8 maps entity_type → Bullhorn type (candidate→Candidate,
    48	  # contact→ClientContact, brief→JobOrder, placement→Placement); opportunity
    49	  # is IFOS-cached-Postgres-only per agent.md §3 (no v1.0 Bullhorn endpoint).
    50	  # While the bridge CLI is unbuilt, Step 8 writes the IFOS entities cache and
    51	  # records bullhorn_push:deferred_bridge_unavailable on the action row;
    52	  # Step 9 defers the note attach (note_attach_deferred output row).
    53	  # Reference: bullhorn-integration-path.md §4.1 A3 (Scribe scope).
    54	  # Schema-clean post v0.4 supplement (LIVE on VPS 2026-06-03; commit a1bbcf6).
    55	  # ────────────────────────────────────────────────────────────────────────
    56	
    57	  - id: bullhorn_oauth
    58	    package: "@ifos/bullhorn"
    59	    purpose: "Bullhorn two-step OAuth refresh (Step A OAuth + Step B REST login per @ifos/bullhorn src/auth.ts); per-corporation_id Promise dedup + 401-force-refresh per cluster F R4 lesson"
    60	    action_type: bullhorn_oauth          # green tier; QUEUED for registration at W6
    61	    cycle_step: 2
    62	    secrets_required: [BULLHORN_CLIENT_ID, BULLHORN_CLIENT_SECRET]
    63	    rate_limit_hint: "per-corporation_id 600/min hard / 480/min soft (see @ifos/bullhorn README §Rate limits)"
    64	
    65	  - id: bullhorn_list_candidates
    66	    package: "@ifos/bullhorn"
    67	    purpose: "List candidates matching transcript participants (Step 4 entity resolution)"
    68	    cycle_step: 4
    69	    state_changing: false
    70	
    71	  - id: bullhorn_get_candidate
    72	    package: "@ifos/bullhorn"
    73	    purpose: "Single-entity candidate fetch (Step 4 entity hydration)"
    74	    cycle_step: 4
    75	    state_changing: false
    76	
    77	  - id: bullhorn_list_contacts
    78	    package: "@ifos/bullhorn"
    79	    purpose: "List contacts matching transcript participants (Step 4)"
    80	    cycle_step: 4
    81	    state_changing: false
    82	
    83	  - id: bullhorn_get_contact
    84	    package: "@ifos/bullhorn"
    85	    purpose: "Single-entity contact fetch (Step 4)"
    86	    cycle_step: 4
    87	    state_changing: false
    88	
    89	  - id: bullhorn_update_candidate
    90	    package: "@ifos/bullhorn"
    91	    purpose: "Write structured fields extracted from transcript onto Candidate entity (Step 8); v1.0 SUPPORTED capability"
    92	    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED in autosend-policy.yaml line 240
    93	    cycle_step: 8
    94	    state_changing: true
    95	
    96	  - id: bullhorn_update_contact
    97	    package: "@ifos/bullhorn"
    98	    purpose: "Write structured fields onto Contact entity (Step 8); v1.0 LIMITATION: requires @ifos/bullhorn v0.2+ (updateContact not yet exported); declared for ratification continuity"
    99	    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
   100	    cycle_step: 8
   101	    state_changing: true
   102	    # PENDING upstream: updateContact not yet exported by @ifos/bullhorn —
   103	    # bin/bh-bridge.sh `update-entity --entity-type ClientContact` is the call site
   104	    # to reconcile when the Janitor bridge lands
   105	
   106	  - id: bullhorn_update_brief
   107	    package: "@ifos/bullhorn"
   108	    purpose: "Write structured fields onto Brief/JobOrder entity (Step 8); v1.0 LIMITATION: requires @ifos/bullhorn v0.2+ (updateBrief not yet exported); declared for ratification continuity"
   109	    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
   110	    cycle_step: 8
   111	    state_changing: true
   112	    # PENDING upstream: updateBrief not yet exported by @ifos/bullhorn —
   113	    # bin/bh-bridge.sh `update-entity --entity-type JobOrder` is the call site
   114	
   115	  - id: bullhorn_update_placement
   116	    package: "@ifos/bullhorn"
   117	    purpose: "Write structured fields onto Placement entity (Step 8); v1.0 LIMITATION: requires @ifos/bullhorn v0.2+ (updatePlacement not yet exported); declared for ratification continuity"
   118	    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
   119	    cycle_step: 8
   120	    state_changing: true
   121	    # PENDING upstream: updatePlacement not yet exported by @ifos/bullhorn —
   122	    # bin/bh-bridge.sh `update-entity --entity-type Placement` is the call site
   123	
   124	  - id: bullhorn_create_note
   125	    package: "@ifos/bullhorn"
   126	    purpose: "Attach tacit-note narrative (mirror of vault artefact from Step 6) onto Bullhorn entity (Step 9)"
   127	    action_type: bullhorn_note_append_summary  # yellow tier; REGISTERED in autosend-policy.yaml line 212
   128	    cycle_step: 9
   129	    state_changing: true
   130	
   131	  # ────────────────────────────────────────────────────────────────────────
   132	  # Granola MCP wrapper (read surface; 5 of 6 official tools — listFolders
   133	  # NOT consumed by Scribe per agent.md §4 + Day-29 vendor pivot)
   134	  # Reference: @ifos/granola README §Scribe consumption pattern;
   135	  # mcp.granola.ai/mcp official server.
   136	  # ────────────────────────────────────────────────────────────────────────
   137	
   138	  - id: granola_oauth
   139	    package: "@ifos/granola"
   140	    purpose: "Granola OAuth 2.1 + PKCE + DCR refresh (per-workspace_id Promise dedup + atomic file write per @ifos/granola src/auth.ts); Scribe pre-cache plan_tier='paid' via getAccountInfo at session start"
   141	    action_type: granola_oauth   # green tier; QUEUED for registration at W6
   142	    cycle_step: 2
   143	    secrets_required: [GRANOLA_CLIENT_ID]   # PKCE flow has no client_secret
   144	    rate_limit_hint: "per-workspace_id 60/min hard / 48/min soft (see @ifos/granola README §Rate limits)"
   145	
   146	  - id: granola_list_meetings
   147	    package: "@ifos/granola"
   148	    purpose: "List meetings since CTX_GRANOLA_LAST_POLL (cycle.sh Step 1 poll-sweep loop discovery); free plan returns last 30d only per Granola docs — Scribe assumes Paid (founder 2026-06-03)"
   149	    cycle_step: 1
   150	    state_changing: false
   151	
   152	  - id: granola_get_meeting
   153	    package: "@ifos/granola"
   154	    purpose: "Single-meeting hydrate for replay mode (manual --call-id <meeting_id> invocation per agent.md §2)"
   155	    cycle_step: 3
   156	    state_changing: false
   157	
   158	  - id: granola_query_meetings
   159	    package: "@ifos/granola"
   160	    purpose: "Semantic search across meeting notes (v1.1+ for backfill of historical context; v1.0 unused by cycle.sh — declared for capability surface set-equality with @ifos/granola exports)"
   161	    cycle_step: null
   162	    state_changing: false
   163	    # NOTE: declared but not consumed at v1.0 — Scribe's poll-sweep uses
   164	    # list_meetings + getTranscript; queryMeetings is for v1.1+ retroactive
   165	    # taxonomy backfill (re-running extraction against historical transcripts).
   166	
   167	  - id: granola_get_transcript
   168	    package: "@ifos/granola"
   169	    purpose: "Fetch meeting transcript with speaker segments (Step 3 per-meeting fetch); PAID PLANS ONLY — Scribe pre-guards via CTX_GRANOLA_PLAN_TIER from getAccountInfo cache (Step 0); 10-min cache TTL per @ifos/granola"
   170	    cycle_step: 3
   171	    state_changing: false
   172	    plan_tier_required: paid   # Scribe gates this before invocation
   173	
   174	  - id: granola_get_account_info
   175	    package: "@ifos/granola"
   176	    purpose: "Workspace + plan_tier introspection (context.sh Step 3 pre-caches plan_tier='paid' for the cycle.sh session; 1h TTL per @ifos/granola)"
   177	    cycle_step: 0
   178	    state_changing: false
   179	
   180	  # ────────────────────────────────────────────────────────────────────────
   181	  # Voice classifier (Step 6 tacit-note narrative voice scoring)
   182	  # Reference: agent.md §7; _shared/voice-loader.sh + hh_load_tone_rules.
   183	  # ────────────────────────────────────────────────────────────────────────
   184	
   185	  - id: voice_classifier
   186	    package: "@ifos/voice-classifier"   # W4-5 polish microservice (per agent.md §8 build deps)
   187	    purpose: "Score tacit-note narrative against tenant voice corpus (≥0.75 required by Gate A G3); ESC_VOICE_DRIFT below threshold after 3 retries"
   188	    cycle_step: 6
   189	    state_changing: false
   190	    # NOTE: @ifos/voice-classifier microservice is W4-5 polish work per
   191	    # agent.md §8 — may not exist as a standalone package at this scaffold
   192	    # state; cycle.sh Step 6 will integrate with whatever shape that lands
   193	    # at W4-5 (likely an HTTP microservice OR an LLM-prompt-wrapper).
   194	
   195	  # ────────────────────────────────────────────────────────────────────────
   196	  # Cleanup (cleanup.sh)
   197	  # ────────────────────────────────────────────────────────────────────────
   198	
   199	  - id: scribe_cleanup
   200	    purpose: "Post-run cleanup (transient @ifos/bullhorn + @ifos/granola cache purge + /tmp transcript purge + last-poll cache file update)"
   201	    action_type: scribe_cleanup   # green tier; QUEUED for registration at W6
   202	    state_changing: false
   203	    cycle_step: 10
   204	
   205	# ──────────────────────────────────────────────────────────────────────────────
   206	# Failure-modes table (per cluster Fbis pattern; ESC mapping per agent.md §6)
   207	# ──────────────────────────────────────────────────────────────────────────────
   208	
   209	failure_modes:
   210	
   211	  - condition: "@ifos/bullhorn OAuth refresh fails after 2 retries (cycle.sh Step 2)"
   212	    surface: "BullhornAuthError thrown by @ifos/bullhorn"
   213	    escalation: ESC_BULLHORN_AUTH    # blocking; operator + ifos_oncall_chat_id per catalogue §2.5
   214	
   215	  - condition: "@ifos/granola OAuth refresh fails (cycle.sh Step 2; context.sh Step 5)"
   216	    surface: "GranolaAuthError thrown by @ifos/granola"
   217	    escalation: ESC_GRANOLA_AUTH     # blocking-equivalent; QUEUED for catalogue registration at W6
   218	    queued: true
   219	
   220	  - condition: "@ifos/bullhorn returns 4xx/5xx on Step 8 field write OR Step 9 note attach"
   221	    surface: "BullhornError (4xx skip; 5xx retry-once-then-skip)"
   222	    escalation: ESC_BULLHORN_WRITE_FAIL   # warn; operator_chat_id
   223	
   224	  - condition: "@ifos/granola returns 4xx/5xx on Step 1 listMeetings OR Step 3 getTranscript"
   225	    surface: "GranolaError; per agent.md §6 ESC_PROVIDER_FETCH_FAIL covers transcript-provider failures generically (v1.0 payload extension upstream='granola')"
   226	    escalation: ESC_PROVIDER_FETCH_FAIL   # warn; operator_chat_id
   227	
   228	  - condition: "@ifos/granola returns 403 on Step 3 getTranscript (Paid-plan tool on Free workspace)"
   229	    surface: "GranolaPlanTierInsufficientError"
   230	    escalation: ESC_GRANOLA_PLAN_TIER     # warn; QUEUED for catalogue registration at W6; consumer degrades to notes-only ingest
   231	
   232	  - condition: "@ifos/bullhorn OR @ifos/granola returns 429"
   233	    surface: "BullhornRateLimitError OR GranolaRateLimitError"
   234	    escalation: ESC_RATE_LIMIT_HIT   # warn; operator_chat_id; payload.upstream='bullhorn'|'granola'
   235	
   236	  - condition: "Tacit-note voice classifier <0.75 after 3 retries (Step 6 → validate.sh G3)"
   237	    surface: "validate.sh exit 1 with G3 failure"
   238	    escalation: ESC_VOICE_DRIFT      # warn; operator_chat_id
   239	
   240	  - condition: "PII detected outside firm boundary in tacit-note narrative (validate.sh G6)"
   241	    surface: "validate.sh exit 1 with G6 failure"
   242	    escalation: ESC_PII_LEAKAGE_RISK   # blocking; operator + ifos_oncall_chat_id
   243	
   244	  - condition: "<3 structured-field extractions with confidence ≥0.6 (Step 5 → validate.sh G2)"
   245	    surface: "validate.sh exit 1 with G2 failure"
   246	    escalation: ESC_FIELD_EXTRACTION_LOW_CONFIDENCE   # warn; operator_chat_id
   247	
   248	  - condition: "Field name not in vertical-schema OR per-field type/range validation fails (validate.sh G4 + G5)"
   249	    surface: "validate.sh exit 1 with G4 or G5 failure"
   250	    escalation: ESC_SCHEMA_VIOLATION   # warn; operator_chat_id per catalogue line 163
   251	
   252	  - condition: "Tacit-note word count >800 (validate.sh G8) — output-shape constraint"
   253	    surface: "validate.sh exit 1 with G8 failure (G7 is the Bullhorn-auth check)"
   254	    escalation: ESC_AGENT_OUTPUT_SHAPE   # warn; operator_chat_id per catalogue line 184
   255	
   256	  - condition: "No resolvable target entity at Step 4 (transcript participants don't match any Bullhorn contact/candidate)"
   257	    surface: "cycle.sh Step 4 emits validate_gate_a_fail + skips meeting"
   258	    escalation: ESC_AGENT_OUTPUT_SHAPE   # warn; operator_chat_id
   259	
   260	  - condition: "Summary-render >30 min OR note-attach >1h after meeting end (Step 10)"

exec
/bin/zsh -lc 'rg -n "bullhorn_scribe_field_write|bullhorn_note_append_summary|validate_gate_a_fail|scribe_run_complete|webhook_verified|tacit_note_rendered|note_attach_deferred|granola_meetings_polled|recent_edit|voice_score|unscored|G3" agents/recruitment/scribe -S' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
agents/recruitment/scribe/tools.yaml:33:# Scribe's 2 yellow-tier write action_types (bullhorn_scribe_field_write +
agents/recruitment/scribe/tools.yaml:34:# bullhorn_note_append_summary) are REGISTERED in autosend-policy.yaml
agents/recruitment/scribe/tools.yaml:52:  # Step 9 defers the note attach (note_attach_deferred output row).
agents/recruitment/scribe/tools.yaml:92:    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED in autosend-policy.yaml line 240
agents/recruitment/scribe/tools.yaml:99:    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
agents/recruitment/scribe/tools.yaml:109:    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
agents/recruitment/scribe/tools.yaml:118:    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
agents/recruitment/scribe/tools.yaml:127:    action_type: bullhorn_note_append_summary  # yellow tier; REGISTERED in autosend-policy.yaml line 212
agents/recruitment/scribe/tools.yaml:187:    purpose: "Score tacit-note narrative against tenant voice corpus (≥0.75 required by Gate A G3); ESC_VOICE_DRIFT below threshold after 3 retries"
agents/recruitment/scribe/tools.yaml:236:  - condition: "Tacit-note voice classifier <0.75 after 3 retries (Step 6 → validate.sh G3)"
agents/recruitment/scribe/tools.yaml:237:    surface: "validate.sh exit 1 with G3 failure"
agents/recruitment/scribe/tools.yaml:257:    surface: "cycle.sh Step 4 emits validate_gate_a_fail + skips meeting"
agents/recruitment/scribe/tools.yaml:273:#   bullhorn_scribe_field_write     line 240   yellow   (emitted by cycle.sh Step 8)
agents/recruitment/scribe/tools.yaml:274:#   bullhorn_note_append_summary    line 212   yellow   (emitted by cycle.sh Step 9)
agents/recruitment/scribe/tools.yaml:275:#   validate_gate_a_fail            line 119   green    (emitted by validate.sh + cycle.sh gates)
agents/recruitment/scribe/tools.yaml:276:#   scribe_run_complete             line  83   green    (emitted by cycle.sh Step 10)
agents/recruitment/scribe/context.sh:160:# records unscored/no_corpus, never a faked score).
agents/recruitment/scribe/fixtures/01-primary.yaml:9:#   Gate A G2) → Step 6 voice classifier scores 0.82 (passes G3) → vault
agents/recruitment/scribe/fixtures/01-primary.yaml:11:#   @ifos/bullhorn updateCandidate (yellow tier bullhorn_scribe_field_write)
agents/recruitment/scribe/fixtures/01-primary.yaml:13:#   bullhorn_note_append_summary) → Step 10 elapsed_seconds=240 (well under
agents/recruitment/scribe/fixtures/01-primary.yaml:21:#         downstream contract (bullhorn_auth_refreshed, webhook_verified, ...)
agents/recruitment/scribe/fixtures/01-primary.yaml:107:  voice_score: 0.82            # passes Gate A G3 (≥0.75 required)
agents/recruitment/scribe/fixtures/01-primary.yaml:124:    voice_score: 0.82
agents/recruitment/scribe/fixtures/01-primary.yaml:127:    - action_type: bullhorn_scribe_field_write
agents/recruitment/scribe/fixtures/01-primary.yaml:133:    - action_type: bullhorn_note_append_summary
agents/recruitment/scribe/fixtures/01-primary.yaml:147:      output_type: webhook_verified           # spec-002 §3; poll trigger → signature:not_applicable
agents/recruitment/scribe/fixtures/01-primary.yaml:149:      output_type: granola_meetings_polled    # poll-sweep discovery marker (Granola pivot; extra to the §3 set)
agents/recruitment/scribe/fixtures/01-primary.yaml:159:      output_type: tacit_note_rendered        # payload: {vault_path, body_sha256, voice_score} only (ADR-002)
agents/recruitment/scribe/fixtures/01-primary.yaml:163:      action_type: bullhorn_scribe_field_write
agents/recruitment/scribe/fixtures/01-primary.yaml:165:      action_type: bullhorn_note_append_summary
agents/recruitment/scribe/fixtures/01-primary.yaml:167:      action_type: scribe_run_complete
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:106:  voice_score: 0.78             # passes Gate A G3 (still ≥0.75)
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:123:    voice_score: 0.78
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:126:    - action_type: bullhorn_scribe_field_write
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:133:    - action_type: bullhorn_note_append_summary
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:157:      output_type: webhook_verified          # poll trigger → signature:not_applicable (spec-002 §3)
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:159:      output_type: granola_meetings_polled
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:171:      output_type: tacit_note_rendered
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:175:      action_type: bullhorn_scribe_field_write
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:178:      action_type: bullhorn_note_append_summary
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:180:      action_type: scribe_run_complete
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:6:# validate.sh G3 fails + cycle.sh skips Steps 8+9 (NO Bullhorn write).
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:25:#         unforced path records unscored/no_corpus and Gate A G3 warns instead
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:29:#         scripts/run-scribe-gate-a-test.sh (G3 fail class + ESC_VOICE_DRIFT).
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:35:expected_gate_a: FAIL   # G3 fails on voice score
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:106:  voice_score_attempts:
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:110:  voice_score_final: 0.61      # max of attempts; FAILS G3
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:124:    classifier_pass: false      # G3 FAILS (after 3 retries)
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:126:    g1_webhook_sig_pass: true    # G3 voice, G4 names, G5 types, G6 PII, G7 auth, G8 word cap
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:146:        voice_score_attempts: [0.62, 0.58, 0.61]
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:153:      output_type: webhook_verified          # poll trigger → signature:not_applicable (spec-002 §3)
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:155:      output_type: granola_meetings_polled
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:166:      output_type: tacit_note_rendered
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:167:      payload_contains: "voice_score:0.61"   # vault frontmatter carries needs_consultant_review: true
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:171:      outcome: ESC_VOICE_DRIFT               # emitted by validate.sh G3
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:173:      action_type: validate_gate_a_fail
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:176:      action_type: scribe_run_complete
agents/recruitment/scribe/bin/render-tacit-note.sh:8:# emits METADATA only ({vault_path, body_sha256, voice_score}) to decision_log
agents/recruitment/scribe/bin/render-tacit-note.sh:20:# score (forced test score | unscored/no_corpus | unscored/no_classifier) and
agents/recruitment/scribe/bin/render-tacit-note.sh:31:VOICE_SCORE="unscored" VOICE_REASON="no_corpus" NEEDS_REVIEW="false"
agents/recruitment/scribe/bin/render-tacit-note.sh:142:voice_score: ${VOICE_SCORE}
agents/recruitment/scribe/agent.md:6:**Per-component state (honest, verified 2026-06-10):** `cycle.sh`/`validate.sh`/`context.sh`/`cleanup.sh`/`bin/*` BUILT + fixture-proven; `context.sh` reads `tenant_adapters.config` (v0.4 keys `bullhorn_corporation_id` + `granola_workspace_id`) with `IFOS_FORCE_*` env fallbacks for fixtures; LLM extraction path EXISTS but is opt-in (`IFOS_SCRIBE_USE_LLM=1`) — fixtures run the deterministic extractor; the voice classifier is NOT built (notes carry honest `unscored/no_corpus` or `unscored/no_classifier`); `bin/bh-bridge.sh` conforms to the agreed `@ifos/bullhorn` CLI contract (review-scribe.md orchestrator ruling) and degrades honestly (exit 3 `unavailable`, no fake writes) until the Janitor bridge lands.
agents/recruitment/scribe/agent.md:19:> **Scribe ingests a call transcript from Granola (`@ifos/granola`; discovered by a 5-minute poll-sweep of meetings since the last poll — Granola publishes no webhooks; Ringover deferred to v1.1+) and produces TWO outputs per meeting:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contact / brief / opportunity / placement per the call context; contractor is NOT a v1.0 resolution target — see §3), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS) **except for Opportunity, which is cache-only/vault-only at v1.0** (§3); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of the poll-sweep discovering the finished meeting, per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1 — with the honest `unscored` state while the classifier is unbuilt (§5 G3 warn-when-unscored).
agents/recruitment/scribe/agent.md:33:`list-meetings --since <ISO>`; `granola_meetings_polled` discovery row) and
agents/recruitment/scribe/agent.md:34:runs Steps 2-10 per new meeting. The Step-1 `webhook_verified` marker is
agents/recruitment/scribe/agent.md:51:mismatch → `ESC_INPUT_VALIDATION_FAIL` + `webhook_verified` row with
agents/recruitment/scribe/agent.md:85:Two outputs per meeting. Both write atomically; Step-9 failure rolls back Step 8 (best-effort — §4 Step 9 + §9 Q5). The Gate-B `recent_edit` row is only inserted after Step 9 settles (the table is append-only for `ifos_app`), so a rolled-back write never enters the edit-rate denominator.
agents/recruitment/scribe/agent.md:114:  `bullhorn_scribe_field_write` action row records
agents/recruitment/scribe/agent.md:117:  a `note_attach_deferred` output row,
agents/recruitment/scribe/agent.md:134:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:161:Length cap: 800 words. Voice-classified (≥0.75). Persistent classifier failure (after 3 retries) is a **hard Gate A failure** — fires `ESC_VOICE_DRIFT` + `validate_gate_a_fail`; the note is NOT attached to Bullhorn (Step 9 is skipped) and is held as a `/tmp`/vault draft flagged "needs consultant review" for manual handling. The placeholder is explicitly a non-success state, never a passing output.
agents/recruitment/scribe/agent.md:163:Each tacit-note write emits its own `decision_log` rows: on vault render, `agent_name='scribe'`, `phase='output'`, `output_type='tacit_note_rendered'` carrying `{vault_path, body_sha256, voice_score}` (body NOT in payload per ADR-002 vault/Postgres split); on Bullhorn attach, `phase='action'`, `action_type='bullhorn_note_append_summary'`, `tier='yellow'`, payload carrying `note_payload_hash` + `payload_preview` + the resolved `<entity_type>:<bullhorn_id>` (per §4 Steps 6 + 9).
agents/recruitment/scribe/agent.md:186:     corpus id + tone rules + recent_edits (drift) + granola plan_tier cache
agents/recruitment/scribe/agent.md:191:     <CTX_GRANOLA_LAST_POLL>; emits webhook_verified with
agents/recruitment/scribe/agent.md:193:     verify) + granola_meetings_polled discovery row (count, window,
agents/recruitment/scribe/agent.md:200:   → hh_decision_output("webhook_verified", "call:<id|sweep>", "provider:granola; …")
agents/recruitment/scribe/agent.md:251:     future classifier wire-in; otherwise unscored/no_corpus or
agents/recruitment/scribe/agent.md:252:     unscored/no_classifier (classifier microservice not built — §8)
agents/recruitment/scribe/agent.md:253:   → numeric score <0.75 → note flagged needs_consultant_review; Gate A G3
agents/recruitment/scribe/agent.md:257:   → hh_decision_output("tacit_note_rendered", "<vault_path>",
agents/recruitment/scribe/agent.md:258:     "vault_path:<p>; body_sha256:<h>; voice_score:<s>; words:<N>; retries:<n>")
agents/recruitment/scribe/agent.md:268:   → on Gate A failure (<3 valid): hh_decision_action("validate_gate_a_fail",
agents/recruitment/scribe/agent.md:271:     (validate_gate_a_fail is the canonical green-tier action_type registered
agents/recruitment/scribe/agent.md:284:   → on success: hh_decision_action("bullhorn_scribe_field_write",
agents/recruitment/scribe/agent.md:286:   → the Gate B recent_edit row (resolution='deferred') for this write is
agents/recruitment/scribe/agent.md:287:     inserted only AFTER Step 9 settles — recent_edit is append-only for
agents/recruitment/scribe/agent.md:299:     (candidate/contact); otherwise honest defer (note_attach_deferred row,
agents/recruitment/scribe/agent.md:301:   → bridge unavailable: note_attach_deferred row (no yellow row — no
agents/recruitment/scribe/agent.md:303:   → on success: hh_decision_action("bullhorn_note_append_summary",
agents/recruitment/scribe/agent.md:306:     PATCH); no recent_edit row exists yet (inserted only after this step
agents/recruitment/scribe/agent.md:324:   → hh_decision_action("scribe_run_complete", "call:<last_id>",
agents/recruitment/scribe/agent.md:341:- G3 — tacit-note voice classifier ≥0.75 — hard fail on a numeric score below threshold; **warn-when-unscored** (no corpus / no classifier ⇒ a score cannot be honestly computed; warned, never faked)
agents/recruitment/scribe/agent.md:348:Gate A failures fire the per-check ESC class (`ESC_INPUT_VALIDATION_FAIL` / `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` / `ESC_VOICE_DRIFT` / `ESC_SCHEMA_VIOLATION` / `ESC_PII_LEAKAGE_RISK` / `ESC_BULLHORN_AUTH` / `ESC_AGENT_OUTPUT_SHAPE`) + a `validate_gate_a_fail` action row; transcript stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/scribe/agent.md:356:- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
agents/recruitment/scribe/agent.md:399:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:427:| Voice-classifier microservice (until then: honest `unscored`) | W4-5 polish — NOT built | ⏸ |
agents/recruitment/scribe/agent.md:448:| Q5 | Bullhorn write atomicity — Step 9 rollback of Step 8 on note-attach failure is best-effort PATCH (cache restore + reverse PATCH; the Gate-B recent_edit row is insert-after-settle so it never needs unwinding). Could leave the Bullhorn entity in mid-state. | v1.0 accept; document risk. v1.1+: investigate Bullhorn transaction API if exposed. |
agents/recruitment/scribe/agent.md:449:| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
agents/recruitment/scribe/cycle.sh:34:#   1  webhook signature verify / poll     webhook_verified (+ granola_meetings_polled)
agents/recruitment/scribe/cycle.sh:39:#   6  tacit-note → vault (0600)           tacit_note_rendered       ESC_VOICE_DRIFT (via Gate A)
agents/recruitment/scribe/cycle.sh:41:#   8  Bullhorn field write (yellow)       bullhorn_scribe_field_write  ESC_BULLHORN_WRITE_FAIL
agents/recruitment/scribe/cycle.sh:42:#   9  Bullhorn note attach (yellow)       bullhorn_note_append_summary ESC_BULLHORN_WRITE_FAIL (+rollback of 8)
agents/recruitment/scribe/cycle.sh:43:#   10 session close + SLA                 scribe_run_complete       ESC_SCRIBE_SLA_MISS
agents/recruitment/scribe/cycle.sh:54:#   1. ≥3 Bullhorn structured-field writes (yellow bullhorn_scribe_field_write;
agents/recruitment/scribe/cycle.sh:186:# Reference: spec-002 §4 Step 1 (marker webhook_verified; ESC_INPUT_VALIDATION_FAIL
agents/recruitment/scribe/cycle.sh:210:    hh_decision_output "webhook_verified" "call:${_wh_call_id}" \
agents/recruitment/scribe/cycle.sh:214:  hh_decision_output "webhook_verified" "call:${_wh_call_id}" \
agents/recruitment/scribe/cycle.sh:223:  hh_decision_output "webhook_verified" "call:${CALL_ID_ARG:-sweep}" \
agents/recruitment/scribe/cycle.sh:245:  hh_decision_output "granola_meetings_polled" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/scribe/cycle.sh:421:    hh_decision_action "validate_gate_a_fail" "call:${call_id}" "no-entity-${call_id}" \
agents/recruitment/scribe/cycle.sh:445:    hh_decision_action "validate_gate_a_fail" "${entity_type}:${bullhorn_id}" "lowconf-${call_id}" \
agents/recruitment/scribe/cycle.sh:456:  #   active voice_corpus     → unscored/no_classifier (corpus exists; the
agents/recruitment/scribe/cycle.sh:458:  #   no corpus               → unscored/no_corpus (CC precedent)
agents/recruitment/scribe/cycle.sh:462:  local voice_score voice_reason needs_review="" retries=0
agents/recruitment/scribe/cycle.sh:464:    voice_score="${IFOS_FORCE_VOICE_SCORE}"
agents/recruitment/scribe/cycle.sh:467:    if awk -v s="${voice_score}" 'BEGIN{exit !(s < 0.75)}'; then
agents/recruitment/scribe/cycle.sh:471:    voice_score="unscored"; voice_reason="no_classifier"
agents/recruitment/scribe/cycle.sh:473:    voice_score="unscored"; voice_reason="no_corpus"
agents/recruitment/scribe/cycle.sh:480:    --voice-score "${voice_score}" --voice-reason "${voice_reason}")
agents/recruitment/scribe/cycle.sh:495:  # ADR-002: metadata ONLY — {vault_path, body_sha256, voice_score}; body NEVER in payload.
agents/recruitment/scribe/cycle.sh:496:  hh_decision_output "tacit_note_rendered" "${vault_path_logical}" \
agents/recruitment/scribe/cycle.sh:497:    "vault_path:${vault_path_logical}; body_sha256:${body_sha}; voice_score:${voice_score}; voice_reason:${voice_reason}; words:${words}; retries:${retries}"
agents/recruitment/scribe/cycle.sh:507:    hh_decision_action "validate_gate_a_fail" "${entity_type}:${bullhorn_id}" "schema-${call_id}" \
agents/recruitment/scribe/cycle.sh:523:     --arg vp "${vault_path_logical}" --arg sha "${body_sha}" --arg vs "${voice_score}" \
agents/recruitment/scribe/cycle.sh:527:       tacit_note: { vault_path: $vp, body_sha256: $sha, voice_score: $vs,
agents/recruitment/scribe/cycle.sh:535:    # validate.sh already emitted the ESC + validate_gate_a_fail rows.
agents/recruitment/scribe/cycle.sh:616:  hh_decision_action "bullhorn_scribe_field_write" "${entity_type}:${bullhorn_id}" "${payload_hash}" \
agents/recruitment/scribe/cycle.sh:620:  # NOTE (review F6): the Gate B recent_edit 'deferred' row for this field
agents/recruitment/scribe/cycle.sh:621:  # write is inserted AFTER Step 9 settles (below) — recent_edit is
agents/recruitment/scribe/cycle.sh:647:      hh_decision_action "bullhorn_note_append_summary" "${entity_type}:${bullhorn_id}" "${body_sha}" \
agents/recruitment/scribe/cycle.sh:654:      hh_decision_output "note_attach_deferred" "${entity_type}:${bullhorn_id}" \
agents/recruitment/scribe/cycle.sh:657:      hh_decision_output "note_attach_deferred" "${entity_type}:${bullhorn_id}" \
agents/recruitment/scribe/cycle.sh:663:      hh_decision_output "note_attach_deferred" "${entity_type}:${bullhorn_id}" \
agents/recruitment/scribe/cycle.sh:683:      # Review F6: no recent_edit row was written yet (the insert is deferred
agents/recruitment/scribe/cycle.sh:693:  # Gate B edit-rate basis (spec-002 §3 downstream contract): one recent_edit
agents/recruitment/scribe/cycle.sh:695:  # reviews. Written only NOW — after Step 9 settled — because recent_edit is
agents/recruitment/scribe/cycle.sh:703:INSERT INTO recent_edit (tenant_slug, agent_name, action_type, target_entity_type,
agents/recruitment/scribe/cycle.sh:705:VALUES (:'tenant', 'scribe', 'bullhorn_scribe_field_write', :'et', :'eid', :'fm', 'deferred', now());
agents/recruitment/scribe/cycle.sh:758:hh_decision_action "scribe_run_complete" "call:${LAST_CALL_ID}" "${_run_hash}" \
agents/recruitment/scribe/validate.sh:11:# emits the ESC_* row + the validate_gate_a_fail action row to decision_log;
agents/recruitment/scribe/validate.sh:32:#             "voice_score": <0.0-1.0> | "unscored",
agents/recruitment/scribe/validate.sh:53:#   G3 — tacit-voice: classifier ≥0.75                      ESC_VOICE_DRIFT  hard (warn-when-unscored)
agents/recruitment/scribe/validate.sh:175:# G3 — Tacit-note voice classifier ≥0.75
agents/recruitment/scribe/validate.sh:178:# warn-when-unscored (spec-002 §5): with no tenant voice_corpus (or no
agents/recruitment/scribe/validate.sh:182:_voice="$(jq -r '.tacit_note.voice_score // "missing"' "${PROPOSAL}")"
agents/recruitment/scribe/validate.sh:186:    _ok "G3: tacit-note voice score ${_voice} ≥ ${VOICE_SCORE_THRESHOLD}"
agents/recruitment/scribe/validate.sh:188:    _fail "G3: tacit-note voice score ${_voice} < ${VOICE_SCORE_THRESHOLD} (after retries) — note NOT attached; vault draft held for consultant review"
agents/recruitment/scribe/validate.sh:192:  _warn "G3: voice unscored (${_vreason:-no_reason}) — cannot enforce threshold without a seeded voice_corpus + classifier (never faked)"
agents/recruitment/scribe/validate.sh:330:  # G2 → ESC_FIELD_EXTRACTION_LOW_CONFIDENCE; G3 → ESC_VOICE_DRIFT;
agents/recruitment/scribe/validate.sh:338:  hh_decision_action "validate_gate_a_fail" "${ENTITY_TYPE}:${BULLHORN_ID}" "${_gate_hash}" \

exec
/bin/zsh -lc 'rg -n "Fathom|Fireflies|Granola|@ifos/granola|mcp.granola|Ringover|AgentMail|Composio" agents/recruitment/scribe/agent.md agents/recruitment/scribe/tools.yaml agents/recruitment/scribe/fixtures/*.yaml' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
agents/recruitment/scribe/agent.md:4:**Build state (post-W6 build slice, 2026-06-10):** the W6 build slice is BUILT on branch `worktree-agent-a59f16e915e384257`: `cycle.sh` (10-step, 4 modes), `validate.sh` (Gate A G1-G8), `context.sh`, `cleanup.sh`, `tools.yaml`, 5 `bin/` helpers, 3 fixtures + 3 deterministic DB-backed fixture suites — all green under `scripts/build-gate.sh`. This document was reconciled to the built Granola-poll reality in the round-2 fix pass (Codex round-1 findings 1-4). **What has NOT happened:** no live Bullhorn or Granola call — Bullhorn dev creds are EMPTY, the `@ifos/bullhorn` CLI bridge is the Janitor build slice's parallel deliverable (Scribe consumes it only through `bin/bh-bridge.sh`), the Granola IFOS-side OAuth token is not on disk, and `@ifos/granola` has no built CLI. Live smoke is founder-gated (see §8). Earlier history: Day-20 W4 bilateral pass + R19 substantive fixes; pre-pivot Fathom/Fireflies prose removed 2026-06-10 (see vendor note below).
agents/recruitment/scribe/agent.md:5:**Vendor note (Day-29 pivot, founder-decided 2026-06-03):** the v1.0 transcript vendor is **Granola** (`@ifos/granola`; official MCP server mcp.granola.ai/mcp). The original W3 draft of this document specified a webhook-driven flow from Fathom/Fireflies; that is PRE-PIVOT history, not the v1.0 path (no Fathom/Fireflies signup, connector, or webhook contract exists in v1.0). Granola publishes no webhooks, so the operational trigger is a **poll-sweep**; a generic verified-webhook surface is retained as a secondary mode (§2). This reconciliation is contract-prose truth-up only — the §10 status flip remains founder-gated and is NOT exercised here.
agents/recruitment/scribe/agent.md:11:**Tier:** Tier 2 (event-driven — Granola poll-sweep cron + secondary webhook mode; not persistent PTY) per ULTRAPLAN A3 line 518 (drafted pre-pivot as "webhook-driven"; the tier classification is unchanged by the trigger swap).
agents/recruitment/scribe/agent.md:19:> **Scribe ingests a call transcript from Granola (`@ifos/granola`; discovered by a 5-minute poll-sweep of meetings since the last poll — Granola publishes no webhooks; Ringover deferred to v1.1+) and produces TWO outputs per meeting:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contact / brief / opportunity / placement per the call context; contractor is NOT a v1.0 resolution target — see §3), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS) **except for Opportunity, which is cache-only/vault-only at v1.0** (§3); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of the poll-sweep discovering the finished meeting, per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1 — with the honest `unscored` state while the classifier is unbuilt (§5 G3 warn-when-unscored).
agents/recruitment/scribe/agent.md:25:### Granola poll-sweep (v1.0 PRIMARY operational trigger)
agents/recruitment/scribe/agent.md:31:Granola publishes no webhooks, so the operational trigger is a 5-minute cron
agents/recruitment/scribe/agent.md:32:that lists meetings since `CTX_GRANOLA_LAST_POLL` (`@ifos/granola`
agents/recruitment/scribe/agent.md:56:Granola is poll-only.
agents/recruitment/scribe/agent.md:70:The W3 draft of this section specified Fathom (HMAC) / Fireflies (bearer)
agents/recruitment/scribe/agent.md:71:webhooks as the v1.0 primary path. That was superseded by the Day-29 Granola
agents/recruitment/scribe/agent.md:72:pivot (founder, 2026-06-03); no Fathom/Fireflies connector, signup, or
agents/recruitment/scribe/agent.md:190:   → poll-sweep (PRIMARY): @ifos/granola list-meetings --since
agents/recruitment/scribe/agent.md:210:3. Granola transcript fetch (per meeting)
agents/recruitment/scribe/agent.md:211:   → @ifos/granola get-transcript --meeting <id> (PAID-plan tool; pre-guarded
agents/recruitment/scribe/agent.md:372:| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Granola; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream=granola`; also fired when a meeting has neither transcript nor notes to ingest | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:419:| **Granola: IFOS-side OAuth token on disk** (`@ifos/granola` reads its own token bundle, not the Claude-Code MCP keychain) | Founder OAuth dance | ⏸ |
agents/recruitment/scribe/agent.md:420:| **Granola: `@ifos/granola` CLI built** (`list-meetings --since` / `get-transcript --meeting` — expected surface documented at the cycle.sh call sites) | Connector build slice | ⏸ |
agents/recruitment/scribe/agent.md:430:Pre-pivot rows removed 2026-06-10: Fathom/Fireflies commercial signup + connector + per-tenant provider routing (superseded by the Granola pivot; no longer dependencies of anything).
agents/recruitment/scribe/agent.md:432:**Live smoke checklist (founder-gated):** provision Bullhorn sandbox creds → land the Janitor `@ifos/bullhorn` bridge → complete the Granola OAuth dance → record ≥1 meeting → run `cycle.sh --mode replay --call-id <meeting_id>` without `BH_BRIDGE_TEST_MODE`.
agents/recruitment/scribe/agent.md:438:**Status:** Proposed. W6 build slice BUILT + fixture-proven (this branch); live smoke awaits the §8 ⏸ gates (Bullhorn creds + bridge merge + Granola token + recorded meeting) + Q1 LOI / pilot tenant.
agents/recruitment/scribe/agent.md:444:| Q1 | ~~Fathom vs Fireflies — first-mover provider for v1.0?~~ **RESOLVED 2026-06-03 (Day-29 pivot): Granola is the v1.0 vendor** (founder decision; poll-sweep trigger). Fathom/Fireflies are not in v1.0. | Closed. |
agents/recruitment/scribe/agent.md:455:2. **Transcript availability varies by Granola plan tier.** `get-transcript` is a PAID-plan tool; free workspaces degrade to notes-only ingest (pre-guarded via plan_tier cache — no wasted wire call). IFOS workspace confirmed Paid (founder 2026-06-03).
agents/recruitment/scribe/agent.md:462:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict. The status flip below is FOUNDER-GATED — the 2026-06-10 Granola/built-state reconciliation of this document deliberately did NOT exercise it.
agents/recruitment/scribe/agent.md:466:- Founder approves §9 Q3 (taxonomy) — Q1 already RESOLVED by the Day-29 Granola pivot (founder 2026-06-03); Q4 (webhook replay timeout) deferred with the secondary-mode push provider
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:3:# Edge case. Tests the Granola Paid-plan pre-guard — if the workspace's
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:6:# the wire. @ifos/granola's per-call PAID_PLAN_TOOLS pre-guard throws
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:7:# GranolaPlanTierInsufficientError before any HTTP round-trip; Scribe maps
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:17:# Per @ifos/granola PAID_PLAN_TOOLS the gated tools are list_meeting_folders
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:31:description: Granola Free workspace → getTranscript pre-guarded → ESC_GRANOLA_PLAN_TIER → degrade to notes-only ingest → 3 fields extracted from notes_markdown
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:60:# Meeting has_transcript:true reported by Granola (transcript exists on
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:61:# Granola's side) but PAID-only access blocks Scribe from fetching it.
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:182:  Tenant's Granola workspace is on Free plan; transcripts unavailable.
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:185:  confidence; relies on Granola's notes_markdown). v0.4 supplement does NOT
agents/recruitment/scribe/tools.yaml:4:#         are LIVE against these declarations. Live Bullhorn + Granola smoke
agents/recruitment/scribe/tools.yaml:5:#         remains founder-gated: Bullhorn dev creds EMPTY + Granola IFOS-side
agents/recruitment/scribe/tools.yaml:26:# Scribe consumes BOTH @ifos/bullhorn (write surface) AND @ifos/granola
agents/recruitment/scribe/tools.yaml:27:# (read surface). Vendor delta from agent.md: agent.md describes Fathom /
agents/recruitment/scribe/tools.yaml:28:# Fireflies as the transcript provider; SKELETON uses Granola per Day-29
agents/recruitment/scribe/tools.yaml:132:  # Granola MCP wrapper (read surface; 5 of 6 official tools — listFolders
agents/recruitment/scribe/tools.yaml:134:  # Reference: @ifos/granola README §Scribe consumption pattern;
agents/recruitment/scribe/tools.yaml:135:  # mcp.granola.ai/mcp official server.
agents/recruitment/scribe/tools.yaml:139:    package: "@ifos/granola"
agents/recruitment/scribe/tools.yaml:140:    purpose: "Granola OAuth 2.1 + PKCE + DCR refresh (per-workspace_id Promise dedup + atomic file write per @ifos/granola src/auth.ts); Scribe pre-cache plan_tier='paid' via getAccountInfo at session start"
agents/recruitment/scribe/tools.yaml:144:    rate_limit_hint: "per-workspace_id 60/min hard / 48/min soft (see @ifos/granola README §Rate limits)"
agents/recruitment/scribe/tools.yaml:147:    package: "@ifos/granola"
agents/recruitment/scribe/tools.yaml:148:    purpose: "List meetings since CTX_GRANOLA_LAST_POLL (cycle.sh Step 1 poll-sweep loop discovery); free plan returns last 30d only per Granola docs — Scribe assumes Paid (founder 2026-06-03)"
agents/recruitment/scribe/tools.yaml:153:    package: "@ifos/granola"
agents/recruitment/scribe/tools.yaml:159:    package: "@ifos/granola"
agents/recruitment/scribe/tools.yaml:160:    purpose: "Semantic search across meeting notes (v1.1+ for backfill of historical context; v1.0 unused by cycle.sh — declared for capability surface set-equality with @ifos/granola exports)"
agents/recruitment/scribe/tools.yaml:168:    package: "@ifos/granola"
agents/recruitment/scribe/tools.yaml:169:    purpose: "Fetch meeting transcript with speaker segments (Step 3 per-meeting fetch); PAID PLANS ONLY — Scribe pre-guards via CTX_GRANOLA_PLAN_TIER from getAccountInfo cache (Step 0); 10-min cache TTL per @ifos/granola"
agents/recruitment/scribe/tools.yaml:175:    package: "@ifos/granola"
agents/recruitment/scribe/tools.yaml:176:    purpose: "Workspace + plan_tier introspection (context.sh Step 3 pre-caches plan_tier='paid' for the cycle.sh session; 1h TTL per @ifos/granola)"
agents/recruitment/scribe/tools.yaml:200:    purpose: "Post-run cleanup (transient @ifos/bullhorn + @ifos/granola cache purge + /tmp transcript purge + last-poll cache file update)"
agents/recruitment/scribe/tools.yaml:215:  - condition: "@ifos/granola OAuth refresh fails (cycle.sh Step 2; context.sh Step 5)"
agents/recruitment/scribe/tools.yaml:216:    surface: "GranolaAuthError thrown by @ifos/granola"
agents/recruitment/scribe/tools.yaml:224:  - condition: "@ifos/granola returns 4xx/5xx on Step 1 listMeetings OR Step 3 getTranscript"
agents/recruitment/scribe/tools.yaml:225:    surface: "GranolaError; per agent.md §6 ESC_PROVIDER_FETCH_FAIL covers transcript-provider failures generically (v1.0 payload extension upstream='granola')"
agents/recruitment/scribe/tools.yaml:228:  - condition: "@ifos/granola returns 403 on Step 3 getTranscript (Paid-plan tool on Free workspace)"
agents/recruitment/scribe/tools.yaml:229:    surface: "GranolaPlanTierInsufficientError"
agents/recruitment/scribe/tools.yaml:232:  - condition: "@ifos/bullhorn OR @ifos/granola returns 429"
agents/recruitment/scribe/tools.yaml:233:    surface: "BullhornRateLimitError OR GranolaRateLimitError"
agents/recruitment/scribe/tools.yaml:299:# - No Composio / AgentMail references anywhere in this file.
agents/recruitment/scribe/tools.yaml:306:#   @ifos/granola READ SET (5 of 6 tools — listFolders explicitly omitted
agents/recruitment/scribe/tools.yaml:309:#   with @ifos/granola exports but cycle_step=null (v1.1+ retroactive
agents/recruitment/scribe/fixtures/01-primary.yaml:3:# Tests the canonical flow per agent.md §3 + §4 + Day-29 Granola pivot:
agents/recruitment/scribe/fixtures/01-primary.yaml:4:#   cycle.sh mode=poll-sweep → @ifos/granola listMeetings since last_poll
agents/recruitment/scribe/fixtures/01-primary.yaml:24:#         live Bullhorn/Granola founder-gated per spec-002 §8).
agents/recruitment/scribe/fixtures/01-primary.yaml:48:# Mocked Granola account info (pre-cached at context.sh Step 3)
agents/recruitment/scribe/fixtures/01-primary.yaml:57:# Mocked Granola listMeetings (Step 1 poll-sweep discovery)
agents/recruitment/scribe/fixtures/01-primary.yaml:73:# Mocked Granola getTranscript for meeting-001 (Step 3)
agents/recruitment/scribe/fixtures/01-primary.yaml:149:      output_type: granola_meetings_polled    # poll-sweep discovery marker (Granola pivot; extra to the §3 set)

codex
I found two load-bearing inconsistencies: one in the schema/access contract for Contact writes, and one in the Gate B timing anchor after the Granola poll pivot. I’m checking one more catalogue mismatch before finalizing the verdict.
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '390,400p;322,330p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
   322	- **Routing:** `operator_chat_id`
   323	- **Payload fields:** `provider`, `endpoint`, `entity_type`, `status_code`, `error_body_preview`
   324	
   325	#### `ESC_PROVIDER_FETCH_FAIL`
   326	- **Severity:** warn
   327	- **Trigger:** Generic upstream provider read failure (Companies House, web-scraper, any non-Bullhorn-non-Accounting GET) after retry budget exhausted; distinct from rate-limit
   328	- **Phase:** `gating_failed`
   329	- **Routing:** `operator_chat_id`
   330	- **Payload fields:** `upstream` (e.g. `companies-house`, `web-scraper`, `linkedin-cache`), `endpoint`, `status_code`, `consecutive_failures`
   390	- **Routing:** `operator_chat_id`
   391	- **Payload fields:** `tone_rule_id`, `pattern_violated`, `output_snippet_redacted`, `agent_name`, `tenant_slug`
   392	- **Recovery:** agent re-drafts with violation removed; if persistent, escalates to tone_rule review
   393	
   394	#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
   395	- **Severity:** warn
   396	- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
   397	- **Phase:** `gating_failed`
   398	- **Routing:** `operator_chat_id`
   399	- **Payload fields:** `entity_type`, `field_name`, `extracted_value`, `confidence_score`, `source` (e.g. `companies-house`, `linkedin`, `cv-pdf`), `agent_name`
   400	

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '270,292p;396,407p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
   270	# vertical-schema.yaml v0.1 §3, the cell is an EXPLICIT v0.3 amendment
   271	# with a marker comment in-line. Full list of v0.3 amendments:
   272	#
   273	# Cells changed from v0.1 baseline:
   274	#   - Diagnostic client: none → R (reads Companies House data via cached
   275	#     client entity; sales-tool source-of-truth context — v0.3 amendment)
   276	#   - Diagnostic contact: none → R (reads §11 decision-maker map context)
   277	#   - Diagnostic opportunity: none → R (reads prospect-firm opportunity if exists)
   278	#   - Janitor contact: R → R+W (dedup + field-backfill on contacts; same
   279	#     pattern as candidate/contractor — v0.3 amendment)
   280	#   - Janitor opportunity: none → R (reads opportunity context for cleanup)
   281	#   - Janitor placement: R → R+W (lifecycle-state cleanup writes —
   282	#     v0.3 amendment)
   283	#   - Janitor timesheet: none → R (reads for placement-state inference)
   284	#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
   285	#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
   286	#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
   287	#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
   288	#     R-only for Scribe)
   289	#   - Scribe Opportunity: none → R+W (writes 3 new prospecting-call fields)
   290	#   - Scribe timesheet: none → R (reads for placement-context resolution
   291	#     on check-in calls)
   292	#   - Cash Conductor contact: none → R (reads for invoice addressee resolution
   396	    # row A3. opportunity + timesheet access below is to IFOS-cached
   397	    # Postgres rows ONLY (not direct Bullhorn endpoint calls). Scribe
   398	    # uses Bullhorn endpoints for the 5 v1.0-supported entities; other
   399	    # entity access in this matrix is via Postgres cache.
   400	    candidate: R+W         # call-summary field extraction (Bullhorn endpoint A3)
   401	    contractor: R+W        # call-summary field extraction (Bullhorn endpoint A3 — candidate entity)
   402	    client: R              # IFOS-cached read (Bullhorn endpoint A3 — ClientCorporation)
   403	    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
   404	    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
   405	    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields written to IFOS-cached Postgres rows only (Bullhorn Opportunity endpoint NOT used at v1.0 per integration-path §4.1)
   406	    placement: R+W         # check-in field extraction (Bullhorn Placement endpoint A3)
   407	    timesheet: R           # IFOS-cached read; placement-context resolution (Bullhorn Timesheet endpoint NOT used at v1.0)

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '470,505p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
   470	
   471	  client:
   472	    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
   473	    v0_3_v1_0_agent_access:
   474	      - Diagnostic (R)     # v0.3 NEW — reads Companies House data for sales-tool context
   475	      - Janitor (R+W)      # v0.1 unchanged
   476	      - Scribe (R)         # v0.3 NEW — reads client context for call-context resolution
   477	      - Cash Conductor (R) # v0.3 NEW — reads client billing details for invoices
   478	      - Sourcing Scout (R) # v0.1 unchanged
   479	      - Concierge (R)      # v0.1 unchanged
   480	    rationale: |
   481	      v0.3 grants R to Diagnostic + Scribe + Cash Conductor (each reads
   482	      client billing/context for their respective workflows). No new W access.
   483	
   484	  contact:
   485	    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
   486	    v0_3_v1_0_agent_access:
   487	      - Diagnostic (R)     # v0.3 NEW — reads §11 decision-maker map context
   488	      - Janitor (R+W)      # v0.3 UPGRADED — dedup + field-backfill writes
   489	      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
   490	      - Cash Conductor (R) # v0.3 NEW — reads for invoice addressee resolution
   491	      - Sourcing Scout (R) # v0.1 unchanged
   492	      - Concierge (R)      # v0.1 unchanged
   493	    rationale: |
   494	      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
   495	      preferred_channel + next_action_target_date; Janitor also dedup-merges).
   496	      Diagnostic + Cash Conductor gain R for context.
   497	
   498	  brief:
   499	    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
   500	    v0_3_v1_0_agent_access:
   501	      - Janitor (R)        # v0.1 unchanged
   502	      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
   503	      - Sourcing Scout (R) # v0.1 unchanged
   504	      - Concierge (R)      # v0.1 unchanged
   505	    rationale: |

codex
REJECTED

1. Contact calls cannot satisfy the declared ≥3 structured-field write contract without violating schema access. Lines 122-134 require ≥3 extracted/written fields per call and list Contact fields including `decision_authority`; line 127 admits `decision_authority` is R-only for Scribe. The v0.3 schema grants Scribe Contact writes only for `preferred_channel` + `next_action_target_date`, so a contact call has only two writable fields. Fix by adding a third writable Contact field to the schema before use, or by making the per-entity Gate A minimum explicit and lower for Contact.

2. Gate B is still anchored to webhooks after the Granola poll-sweep pivot. Lines 31-37 state the v1.0 primary trigger is poll-sweep with no webhook, but lines 352-356 define Gate B as “within 5 minutes of webhook” / “webhooks-to-Bullhorn-write”. Step 10 then uses meeting end as the SLA anchor, creating three competing anchors: webhook, poll discovery, and meeting end. Fix §5 Gate B to use one measurable anchor for Granola v1.0 and flag the ULTRAPLAN webhook wording as pre-pivot drift.

3. `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` is repurposed beyond the catalogue definition. Line 374 defines it as “<3 fields with confidence ≥0.6”, but the catalogue defines the code as a per-field low-confidence condition at default 0.7 with payload fields like `field_name`, `extracted_value`, and `confidence_score`. This breaks the required ESC trigger-description match. Fix by amending the catalogue to include Scribe’s aggregate 0.6/three-field trigger, or use/register a separate aggregate extraction-shape code.
tokens used
87,364
REJECTED

1. Contact calls cannot satisfy the declared ≥3 structured-field write contract without violating schema access. Lines 122-134 require ≥3 extracted/written fields per call and list Contact fields including `decision_authority`; line 127 admits `decision_authority` is R-only for Scribe. The v0.3 schema grants Scribe Contact writes only for `preferred_channel` + `next_action_target_date`, so a contact call has only two writable fields. Fix by adding a third writable Contact field to the schema before use, or by making the per-entity Gate A minimum explicit and lower for Contact.

2. Gate B is still anchored to webhooks after the Granola poll-sweep pivot. Lines 31-37 state the v1.0 primary trigger is poll-sweep with no webhook, but lines 352-356 define Gate B as “within 5 minutes of webhook” / “webhooks-to-Bullhorn-write”. Step 10 then uses meeting end as the SLA anchor, creating three competing anchors: webhook, poll discovery, and meeting end. Fix §5 Gate B to use one measurable anchor for Granola v1.0 and flag the ULTRAPLAN webhook wording as pre-pivot drift.

3. `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` is repurposed beyond the catalogue definition. Line 374 defines it as “<3 fields with confidence ≥0.6”, but the catalogue defines the code as a per-field low-confidence condition at default 0.7 with payload fields like `field_name`, `extracted_value`, and `confidence_score`. This breaks the required ESC trigger-description match. Fix by amending the catalogue to include Scribe’s aggregate 0.6/three-field trigger, or use/register a separate aggregate extraction-shape code.
