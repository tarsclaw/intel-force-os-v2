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
