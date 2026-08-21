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
session id: 019eb234-e992-7e03-9d27-fb69feb57e69
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

> **Scribe ingests a call transcript from Granola (`@ifos/granola`; discovered by a 5-minute poll-sweep of meetings since the last poll — Granola publishes no webhooks; Ringover deferred to v1.1+) and produces TWO outputs per meeting:** (1) a structured Bullhorn write payload populating the per-entity Gate A minimum of placement-relevant fields on the appropriate entity (≥3 for candidate / brief / opportunity / placement; ≥2 for contact, whose Scribe-writable v0.3 set is exactly two fields — §3; contractor is NOT a v1.0 resolution target — see §3), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS) **except for Opportunity, which is cache-only/vault-only at v1.0** (§3); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of the poll-sweep discovering the finished meeting, per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce the per-entity minimum of structured-field extractions (Contact 2, others 3 — §5 G2) AND 1 tacit-note with confidence ≥0.6 (ULTRAPLAN A3 line 524's ≥3 predates the v0.3 Contact write scope). Gate B success threshold: 90% of calls completing their Bullhorn write within 5 minutes of meeting end (§5 — the single timing anchor); consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1 — with the honest `unscored` state while the classifier is unbuilt (§5 G3 warn-when-unscored).

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

### Output 1 — Bullhorn structured-field writes (per-entity Gate A minimum: Contact 2, others 3)

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

**Per-entity Gate A minimum (Codex R2-1).** The Gate A field-count bar is per entity, set by the size of each entity's Scribe-writable schema: **Contact = 2** (`preferred_channel` + `next_action_target_date` are its ONLY Scribe-writable v0.3 fields — `decision_authority` is R-only per the v0.3 §2 access matrix), **all other entities = 3** (ULTRAPLAN A3 line 524's ≥3, which predates the v0.3 Contact write scope). A blanket ≥3 would hard-fail every legitimate Contact-resolved call, since at most 2 writable fields can survive G4/G5. Extraction may surface MORE than the minimum (including R-only fields like `decision_authority`); R-only material flows to the tacit-note narrative only — it never enters the structured-write payload. Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):

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
   → require ≥ the per-entity Gate A minimum (contact 2, others 3 — §3) of
     fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
     (catalogue aggregate form — payload: entity_type, fields_extracted_count,
     confidence_floor 0.6, required_minimum, agent_name)
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
   → drop invalid; require ≥ per-entity minimum valid (contact 2, others 3 —
     §3; failure = ESC_SCHEMA_VIOLATION per catalogue line 163 —
     vertical-schema field-constraint violation at write time)
   → on success: hh_decision_output("fields_validated", "<entity_type>:<bullhorn_id>",
     "<N> valid of <M> extracted; dropped:<N-invalid>")
   → on Gate A failure (< per-entity minimum valid): hh_decision_action("validate_gate_a_fail",
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
- G2 — structured-field extractions with confidence ≥0.6 meet the **per-entity minimum: Contact 2, all other entities 3** (§3; ULTRAPLAN A3 line 524's ≥3 applies to the 3-field entities — it predates the v0.3 Contact write scope of exactly two Scribe-writable fields)
- G3 — tacit-note voice classifier ≥0.75 — hard fail on a numeric score below threshold; **warn-when-unscored** (no corpus / no classifier ⇒ a score cannot be honestly computed; warned, never faked)
- G4 — field names exist in target entity per vertical-schema.yaml (+v0.3 supplement)
- G5 — per-field type + range validation passes; ≥ per-entity minimum valid after drops (Contact 2, others 3)
- G6 — no PII outside firm boundary in the tacit-note narrative — scans the **FULL physical note body** resolved from `tacit_note.vault_path` (Step 9 exports the full body to Bullhorn; the 500-char preview is the audit-row artefact only); fail-closed when the body is unreadable
- G7 — Bullhorn auth refresh succeeded this session (fresh `bullhorn_auth_refreshed` row, result fresh|refreshed; `unavailable`/`failed`/absent blocks all Bullhorn writes)
- G8 — tacit-note word count ≤800 (§3 cap)

Gate A failures fire the per-check ESC class (`ESC_INPUT_VALIDATION_FAIL` / `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` / `ESC_VOICE_DRIFT` / `ESC_SCHEMA_VIOLATION` / `ESC_PII_LEAKAGE_RISK` / `ESC_BULLHORN_AUTH` / `ESC_AGENT_OUTPUT_SHAPE`) + a `validate_gate_a_fail` action row; transcript stays in `/tmp` (auto-purged 24h); operator notified.

### Gate B — Outcome thresholds (success metrics, not block)

Two metrics, **ONE timing anchor: meeting end (`ended_at`)** — as implemented (cycle.sh Step 10 computes `elapsed` from the meeting's `end_time`; `bin/sla-class.sh` buckets it; §4 Step 10):

- **SLA:** ≥90% of calls have their Bullhorn write completed within 5 minutes of **meeting end**. Poll-discovery latency (the 5-minute sweep cadence, §2) is a *component* of that elapsed time and counts against Scribe — there is no separate "webhook receipt" anchor at v1.0.
- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)

**ULTRAPLAN drift note (pre-pivot wording; noted only — ULTRAPLAN not edited):** ULTRAPLAN A3 line 525 reads "90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%". The "of webhook" anchor predates the Day-29 Granola pivot (§2: Granola publishes no webhooks; the poll-sweep is the primary trigger and the secondary webhook mode has no v1.0 provider). The implemented anchor — meeting end — is at least as strict as any receipt-time anchor; the 90%/5-min and ≤20% numbers are unchanged.

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
| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | Catalogue **aggregate form** (escalation-codes.md, amended 2026-06-10): extracted fields with confidence ≥0.6 below the per-entity Gate A minimum (Contact 2, others 3 — §3). Payload: `entity_type`, `fields_extracted_count`, `confidence_floor` (0.6), `required_minimum`, `agent_name` | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary detected by Gate A G6's FULL-note-body scan (or the body is unreadable — fail-closed). Note-side only: the transcript-side scan is declared deviation 10 (§4 Step 3) — the note body is what leaves the firm boundary | **blocking** | operator + ifos_oncall |
| `ESC_INPUT_VALIDATION_FAIL` | Webhook signature mismatch (Step 1, mode=webhook only) | warn | operator_chat_id |
| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
| `ESC_SCHEMA_VIOLATION` | Vertical-schema field-constraint violation at write time (Step 7) per catalogue line 163 | warn | operator_chat_id |
| `ESC_SCRIBE_SLA_MISS` | Per catalogue §2.10: summary-render >30 min OR note-attach >1h after call end | warn | operator_chat_id (per catalogue routing); aggregated to Gate B metric |
| `ESC_GATE_B_MISS` | Both Gate B metrics (≥90% within-5-min-of-meeting-end SLA AND ≤20% structured-field edit-rate — §5) below target for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
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
I’ll verify the Scribe bundle against the local source files first: section structure, cited policy/catalogue/schema claims, and the built sibling files where the document says they exist.
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
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
    19	> **Scribe ingests a call transcript from Granola (`@ifos/granola`; discovered by a 5-minute poll-sweep of meetings since the last poll — Granola publishes no webhooks; Ringover deferred to v1.1+) and produces TWO outputs per meeting:** (1) a structured Bullhorn write payload populating the per-entity Gate A minimum of placement-relevant fields on the appropriate entity (≥3 for candidate / brief / opportunity / placement; ≥2 for contact, whose Scribe-writable v0.3 set is exactly two fields — §3; contractor is NOT a v1.0 resolution target — see §3), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS) **except for Opportunity, which is cache-only/vault-only at v1.0** (§3); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of the poll-sweep discovering the finished meeting, per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce the per-entity minimum of structured-field extractions (Contact 2, others 3 — §5 G2) AND 1 tacit-note with confidence ≥0.6 (ULTRAPLAN A3 line 524's ≥3 predates the v0.3 Contact write scope). Gate B success threshold: 90% of calls completing their Bullhorn write within 5 minutes of meeting end (§5 — the single timing anchor); consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1 — with the honest `unscored` state while the classifier is unbuilt (§5 G3 warn-when-unscored).
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
    87	### Output 1 — Bullhorn structured-field writes (per-entity Gate A minimum: Contact 2, others 3)
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
   122	**Per-entity Gate A minimum (Codex R2-1).** The Gate A field-count bar is per entity, set by the size of each entity's Scribe-writable schema: **Contact = 2** (`preferred_channel` + `next_action_target_date` are its ONLY Scribe-writable v0.3 fields — `decision_authority` is R-only per the v0.3 §2 access matrix), **all other entities = 3** (ULTRAPLAN A3 line 524's ≥3, which predates the v0.3 Contact write scope). A blanket ≥3 would hard-fail every legitimate Contact-resolved call, since at most 2 writable fields can survive G4/G5. Extraction may surface MORE than the minimum (including R-only fields like `decision_authority`); R-only material flows to the tacit-note narrative only — it never enters the structured-write payload. Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):
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
   242	   → require ≥ the per-entity Gate A minimum (contact 2, others 3 — §3) of
   243	     fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
   244	     (catalogue aggregate form — payload: entity_type, fields_extracted_count,
   245	     confidence_floor 0.6, required_minimum, agent_name)
   246	   → hh_decision_output("fields_extracted", "<entity_type>:<bullhorn_id>",
   247	     "<N> fields ≥0.6 confidence; extractor:<deterministic|llm_with_deterministic_fallback>")
   248	
   249	6. Tacit-note generation (deterministic renderer; voice scored HONESTLY)
   250	   → bin/render-tacit-note.sh: §3 Output 2 shape + 8-category taxonomy +
   251	     tone rules (≤12-word quote clip; no compensation in narrative;
   252	     participant emails masked to local parts)
   253	   → voice score resolution — never faked: numeric only via the test hook /
   254	     future classifier wire-in; otherwise unscored/no_corpus or
   255	     unscored/no_classifier (classifier microservice not built — §8)
   256	   → numeric score <0.75 → note flagged needs_consultant_review; Gate A G3
   257	     hard-fails it (ESC_VOICE_DRIFT); the 3-retry loop applies only to a
   258	     future non-deterministic generator (retries:0 recorded today)
   259	   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md mode 0600
   260	   → hh_decision_output("tacit_note_rendered", "<vault_path>",

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
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

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,520p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
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
   396	- **Trigger:** EITHER (a) per-field: field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data — OR (b) aggregate (Scribe Gate A field-count, per spec-002 §5): a call yields fewer than 3 extracted fields at ≥0.6 confidence, so the per-call structured-write contract cannot be met. _(Amended 2026-06-10: aggregate trigger added — spec-002 §4 Step 5/§5 mandates it for the W6 Scribe build; the catalogue predated the spec.)_
   397	- **Phase:** `gating_failed`
   398	- **Routing:** `operator_chat_id`
   399	- **Payload fields:** per-field form: `entity_type`, `field_name`, `extracted_value`, `confidence_score`, `source` (e.g. `companies-house`, `linkedin`, `cv-pdf`), `agent_name`. Aggregate form: `entity_type`, `fields_extracted_count`, `confidence_floor` (0.6), `required_minimum`, `agent_name`.
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
/bin/zsh -lc 'rg --files agents/recruitment/scribe agents/_shared docs | sort' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
agents/_shared/README.md
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
agents/_shared/voice-loader.sh
agents/recruitment/scribe/README.md
agents/recruitment/scribe/agent.md
agents/recruitment/scribe/bin/bh-bridge.sh
agents/recruitment/scribe/bin/extract-fields.sh
agents/recruitment/scribe/bin/render-tacit-note.sh
agents/recruitment/scribe/bin/sla-class.sh
agents/recruitment/scribe/bin/validate-fields.sh
agents/recruitment/scribe/cleanup.sh
agents/recruitment/scribe/context.sh
agents/recruitment/scribe/cycle.sh
agents/recruitment/scribe/fixtures/01-primary.yaml
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml
agents/recruitment/scribe/tools.yaml
agents/recruitment/scribe/validate.sh
docs/RISK-REGISTER.md
docs/_archive-build-pack/01-RECOMMENDATION.md
docs/_archive-build-pack/02-PRODUCT-VISION.md
docs/_archive-build-pack/03-ARCHITECTURE.md
docs/_archive-build-pack/04-DATA-MODEL.md
docs/_archive-build-pack/05-MIGRATION-MAP.md
docs/_archive-build-pack/06-BUILD-PLAN.md
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md
docs/_archive-build-pack/08-OPEN-DECISIONS.md
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md
docs/_archive-build-pack/README.md
docs/_supplementary/PRD-autonomous-agent.md
docs/_supplementary/README.md
docs/_supplementary/build-plan-original.md
docs/_supplementary/execution-plan.md
docs/_supplementary/planning-phase-brief.md
docs/_supplementary/strategic-plan.md
docs/_supplementary/technical-strategy-v2.md
docs/architecture/agent-bundle-renderer-design.md
docs/architecture/architecture-cohesion-review.md
docs/architecture/cortexos-kb-surface-investigation.md
docs/architecture/cortexos-primitive-status.md
docs/architecture/second-brain-design.md
docs/architecture/tenancy-invariants.md
docs/architecture/vault-concurrency.md
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md
docs/artefacts/diagnostic-hays-plc-2026-05-24.md
docs/build-brief/00-MASTER-BRIEF.md
docs/decisions/2026-05-18-codex-ratification-manifest.md
docs/decisions/2026-05-18-day-7-single-sentence-test.md
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md
docs/decisions/2026-05-31-d1-founder-decision.md
docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md
docs/decisions/README.md
docs/decisions/autosend-approval-bridge-spec.md
docs/decisions/autosend-safety-policy.md
docs/decisions/brain-ui-scope.md
docs/decisions/bullhorn-integration-path.md
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md
docs/decisions/sequencing-target.md
docs/decisions/v1.0-kill-criterion.md
docs/design-mockups/brain-ui-decisions-feed-light-v01.html
docs/features/agent-build/00-ORCHESTRATOR.md
docs/features/agent-build/01-LAUNCH.md
docs/features/agent-build/02-specs/_TEMPLATE.md
docs/features/agent-build/02-specs/spec-001-janitor.md
docs/features/agent-build/02-specs/spec-002-scribe.md
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md
docs/features/agent-build/02-specs/spec-004-concierge.md
docs/features/agent-build/03-implementation/scribe-summary.md
docs/features/agent-build/04-reviews/review-janitor.md
docs/features/agent-build/04-reviews/review-scribe.md
docs/features/agent-build/04-reviews/review-sourcing-scout.md
docs/features/agent-build/STATUS.md
docs/incidents/2026-06-01-intelforce-ai-email-outage.md
docs/operations/bullhorn-outreach-emails.md
docs/operations/codex-ratification-execution-plan.md
docs/operations/codex-ratification-guide.md
docs/operations/codex-round-2-autonomous-prompt.md
docs/operations/codex-round-2-handoff.md
docs/operations/codex-round-2-remediation-prompt.md
docs/operations/decision-log.md
docs/operations/founder-api-signups-2026-06-03.md
docs/operations/founder-legal-setup-guide.md
docs/operations/founder-manual-playbook-2026-05-31.md
docs/operations/founder-playbook-2026-06-03-granola-and-v04.md
docs/operations/goal-option-c-diagnostic-end-to-end.md
docs/operations/goal-overnight-2026-05-31.md
docs/operations/goal-w4-day-26-2026-06-01.md
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md
docs/operations/goal-week-3-polish-and-scaffold.md
docs/operations/goal-week-4-track-1.md
docs/operations/goal-week-5-execution-plan.md
docs/operations/goal-week-6-execution-plan.md
docs/operations/handoff-2026-06-05-location-shift.md
docs/operations/local-dev-db-setup.md
docs/operations/oauth-sandbox-app-setup-runbook.md
docs/operations/parallel-agent-build-method.md
docs/operations/pending-goal-w6-d36-cash-conductor-prep.md
docs/operations/seedlegals-engagement-queries.md
docs/operations/session-init-w7-p3-reconciliation.md
docs/operations/session-retrospective-2026-06-03.md
docs/operations/w4-bilateral-pass-6-agent-md.md
docs/operations/w4-day-20-founder-runbook.md
docs/runbooks/day-4-provisioning.md
docs/runbooks/operational-hygiene-protocol.md
docs/runbooks/pii-purge-operational-pattern.md
docs/runbooks/tenant-lifecycle.md
docs/specs/PRODUCT-SPEC.md
docs/specs/ULTRAPLAN.md
docs/specs/_archive-build-handoff.md
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.4-to-v0.5.sql
docs/verticals/recruitment/migrations/v0.5-to-v0.4.sql
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml

codex
The first pass found the document’s self-described built files are present. I’m now checking the specific citations and schema/action claims that could make or break ratification.
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '260,620p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,615p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
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

 succeeded in 0ms:
   260	   → hh_decision_output("tacit_note_rendered", "<vault_path>",
   261	     "vault_path:<p>; body_sha256:<h>; voice_score:<s>; words:<N>; retries:<n>")
   262	     — metadata ONLY per ADR-002; body never in payload
   263	
   264	7. Field-extraction validation against vertical-schema
   265	   → verify each extracted field name exists in target entity schema
   266	   → verify each extracted value passes per-field type/range checks
   267	   → drop invalid; require ≥ per-entity minimum valid (contact 2, others 3 —
   268	     §3; failure = ESC_SCHEMA_VIOLATION per catalogue line 163 —
   269	     vertical-schema field-constraint violation at write time)
   270	   → on success: hh_decision_output("fields_validated", "<entity_type>:<bullhorn_id>",
   271	     "<N> valid of <M> extracted; dropped:<N-invalid>")
   272	   → on Gate A failure (< per-entity minimum valid): hh_decision_action("validate_gate_a_fail",
   273	     "<entity_type>:<bullhorn_id>", payload_hash,
   274	     "ESC_SCHEMA_VIOLATION; agent_name:scribe; valid:<N>") and exit 1
   275	     (validate_gate_a_fail is the canonical green-tier action_type registered
   276	     in agents/_shared/autosend-policy.yaml line 119; agent:all; Scribe uses
   277	     the shared signature with agent_name in payload to distinguish.)
   278	
   279	8. Bullhorn write — structured fields (yellow tier)
   280	   → primary surface: RLS-scoped IFOS entities-cache UPDATE (the
   281	     validate_entities_data_v0_3 DB trigger re-enforces shapes at write
   282	     time); prior-data snapshot taken for rollback
   283	   → Bullhorn PATCH push via bin/bh-bridge.sh
   284	     update-entity --entity-type <T> --id <N> --patch <json>; push state
   285	     recorded honestly on the action row
   286	     (bullhorn_push:pushed|deferred_bridge_unavailable|cache_only_by_design)
   287	   → opportunity: cache-only by design (§3) — no PATCH attempted
   288	   → on success: hh_decision_action("bullhorn_scribe_field_write",
   289	     "<entity_type>:<bullhorn_id>", payload_hash, payload_preview)
   290	   → the Gate B recent_edit row (resolution='deferred') for this write is
   291	     inserted only AFTER Step 9 settles — recent_edit is append-only for
   292	     ifos_app, so the denominator stays honest by never writing the row for
   293	     a write that gets rolled back
   294	   → on PATCH hard-fail: roll the cache back; ESC_BULLHORN_WRITE_FAIL;
   295	     do NOT proceed to Step 9
   296	
   297	9. Bullhorn write — tacit-note attachment (yellow tier)
   298	   → bin/bh-bridge.sh create-note --entity-type <T> --entity-id <N>
   299	     --body-file <vault note> --title <s> (mirror of vault artefact from
   300	     Step 6 — the FULL body, which is why Gate A G6 scans the full body)
   301	   → CLI {ok:false, reason:"unsupported_entity"}: person-scoped fallback
   302	     (create-note --person-id <N>) when the resolved entity IS a person
   303	     (candidate/contact); otherwise honest defer (note_attach_deferred row,
   304	     reason:unsupported_entity) — never faked
   305	   → bridge unavailable: note_attach_deferred row (no yellow row — no
   306	     Bullhorn state changed); opportunity: deferred by design (§3)
   307	   → on success: hh_decision_action("bullhorn_note_append_summary",
   308	     "<entity_type>:<bullhorn_id>", note_payload_hash, payload_preview)
   309	   → on hard failure: rollback Step 8 (best-effort cache restore + reverse
   310	     PATCH); no recent_edit row exists yet (inserted only after this step
   311	     settles), so Gate B's denominator isn't inflated; ESC_BULLHORN_WRITE_FAIL
   312	
   313	10. Session close + SLA metric
   314	   → per-call elapsed_seconds anchored to MEETING END TIME (bin/sla-class.sh;
   315	     declared note: stricter than "poll receipt" anchoring and consistent
   316	     with the catalogue's "after call end" wording — poll-sweep latency
   317	     counts against Scribe, honestly)
   318	   → Master brief §8.2 line 597 Bullhorn SLA: "post-call note in Bullhorn within
   319	     10 min". Catalogue ESC_SCRIBE_SLA_MISS triggers (line 443): "summary-render
   320	     >30 min OR note-attach >1h after call end". The two thresholds are
   321	     different scopes — master brief 10-min is the product UX promise; catalogue
   322	     30-min/1h is the alerting threshold (less false alarms).
   323	   → if elapsed > 3600 (1h): fire ESC_SCRIBE_SLA_MISS with `sla_type=note_attach` (per catalogue)
   324	   → if elapsed > 1800 (30 min): fire ESC_SCRIBE_SLA_MISS with `sla_type=summary_render` (per catalogue)
   325	   → if elapsed > 600 (10 min) but ≤ 1800: NO ESC fire — recorded as Gate B
   326	     "10-min miss" in the day-30 report aggregation; counts against Gate B 90% target
   327	   → if elapsed > 300 (5 min) but ≤ 600: info-level (still under product promise)
   328	   → hh_decision_action("scribe_run_complete", "call:<last_id>",
   329	     "mode; calls_processed/skipped; field_writes; note_attaches;
   330	     sla_class:<WORST class across the sweep>")
   331	   → exit 0 (poll-sweep/dry-run always; replay/webhook exit 1 on a per-call
   332	     gate failure)
   333	```
   334	
   335	---
   336	
   337	## §5 — Gates
   338	
   339	### Gate A — validate.sh (hard-fail before action)
   340	
   341	Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` (BUILT — runs between cycle.sh Step 7 and Step 8) enforces:
   342	
   343	- G1 — webhook signature state: `verified` or `not_applicable` (poll/replay — no external input exists); `invalid`/`missing` hard-fail
   344	- G2 — structured-field extractions with confidence ≥0.6 meet the **per-entity minimum: Contact 2, all other entities 3** (§3; ULTRAPLAN A3 line 524's ≥3 applies to the 3-field entities — it predates the v0.3 Contact write scope of exactly two Scribe-writable fields)
   345	- G3 — tacit-note voice classifier ≥0.75 — hard fail on a numeric score below threshold; **warn-when-unscored** (no corpus / no classifier ⇒ a score cannot be honestly computed; warned, never faked)
   346	- G4 — field names exist in target entity per vertical-schema.yaml (+v0.3 supplement)
   347	- G5 — per-field type + range validation passes; ≥ per-entity minimum valid after drops (Contact 2, others 3)
   348	- G6 — no PII outside firm boundary in the tacit-note narrative — scans the **FULL physical note body** resolved from `tacit_note.vault_path` (Step 9 exports the full body to Bullhorn; the 500-char preview is the audit-row artefact only); fail-closed when the body is unreadable
   349	- G7 — Bullhorn auth refresh succeeded this session (fresh `bullhorn_auth_refreshed` row, result fresh|refreshed; `unavailable`/`failed`/absent blocks all Bullhorn writes)
   350	- G8 — tacit-note word count ≤800 (§3 cap)
   351	
   352	Gate A failures fire the per-check ESC class (`ESC_INPUT_VALIDATION_FAIL` / `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` / `ESC_VOICE_DRIFT` / `ESC_SCHEMA_VIOLATION` / `ESC_PII_LEAKAGE_RISK` / `ESC_BULLHORN_AUTH` / `ESC_AGENT_OUTPUT_SHAPE`) + a `validate_gate_a_fail` action row; transcript stays in `/tmp` (auto-purged 24h); operator notified.
   353	
   354	### Gate B — Outcome thresholds (success metrics, not block)
   355	
   356	Two metrics, **ONE timing anchor: meeting end (`ended_at`)** — as implemented (cycle.sh Step 10 computes `elapsed` from the meeting's `end_time`; `bin/sla-class.sh` buckets it; §4 Step 10):
   357	
   358	- **SLA:** ≥90% of calls have their Bullhorn write completed within 5 minutes of **meeting end**. Poll-discovery latency (the 5-minute sweep cadence, §2) is a *component* of that elapsed time and counts against Scribe — there is no separate "webhook receipt" anchor at v1.0.
   359	- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
   360	
   361	**ULTRAPLAN drift note (pre-pivot wording; noted only — ULTRAPLAN not edited):** ULTRAPLAN A3 line 525 reads "90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%". The "of webhook" anchor predates the Day-29 Granola pivot (§2: Granola publishes no webhooks; the poll-sweep is the primary trigger and the secondary webhook mode has no v1.0 provider). The implemented anchor — meeting end — is at least as strict as any receipt-time anchor; the 90%/5-min and ≤20% numbers are unchanged.
   362	
   363	Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
   364	
   365	Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing; likely indicates LLM prompt drift or taxonomy mismatch).
   366	
   367	---
   368	
   369	## §6 — Escalation codes
   370	
   371	Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:
   372	
   373	| Code | Trigger | Severity | Routing |
   374	|---|---|---|---|
   375	| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   376	| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on field write OR note attach | warn | operator_chat_id |
   377	| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Granola; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream=granola`; also fired when a meeting has neither transcript nor notes to ingest | warn | operator_chat_id |
   378	| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   379	| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | Catalogue **aggregate form** (escalation-codes.md, amended 2026-06-10): extracted fields with confidence ≥0.6 below the per-entity Gate A minimum (Contact 2, others 3 — §3). Payload: `entity_type`, `fields_extracted_count`, `confidence_floor` (0.6), `required_minimum`, `agent_name` | warn | operator_chat_id |
   380	| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary detected by Gate A G6's FULL-note-body scan (or the body is unreadable — fail-closed). Note-side only: the transcript-side scan is declared deviation 10 (§4 Step 3) — the note body is what leaves the firm boundary | **blocking** | operator + ifos_oncall |
   381	| `ESC_INPUT_VALIDATION_FAIL` | Webhook signature mismatch (Step 1, mode=webhook only) | warn | operator_chat_id |
   382	| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
   383	| `ESC_SCHEMA_VIOLATION` | Vertical-schema field-constraint violation at write time (Step 7) per catalogue line 163 | warn | operator_chat_id |
   384	| `ESC_SCRIBE_SLA_MISS` | Per catalogue §2.10: summary-render >30 min OR note-attach >1h after call end | warn | operator_chat_id (per catalogue routing); aggregated to Gate B metric |
   385	| `ESC_GATE_B_MISS` | Both Gate B metrics (≥90% within-5-min-of-meeting-end SLA AND ≤20% structured-field edit-rate — §5) below target for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
   386	| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
   387	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
   388	
   389	Scribe does NOT use:
   390	
   391	- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
   392	
   393	---
   394	
   395	## §7 — Voice + tone constraints
   396	
   397	Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   398	
   399	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
   400	  - No identifying language about call participants beyond their professional context
   401	  - No verbatim quotes longer than 12 words from candidate (paraphrase for privacy)
   402	  - No compensation specifics in tacit notes (those go to structured fields only)
   403	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
   404	- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
   405	
   406	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   407	
   408	---
   409	
   410	## §8 — Build dependencies + live-smoke gates (post-build state, 2026-06-10)
   411	
   412	The W6 build slice is BUILT (fixture-proven, no live calls). Remaining ⏸
   413	items gate LIVE OPERATION, not the build:
   414	
   415	| Dependency | Source | Status |
   416	|---|---|---|
   417	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   418	| `validate.sh` Gate A logic (G1-G8) | W6 build slice (this branch) | ✅ built |
   419	| `context.sh` hydration (tenant_adapters v0.4 keys + env fallbacks) | W6 build slice | ✅ built |
   420	| `cycle.sh` orchestration (10-step, 4 modes) | W6 build slice | ✅ built |
   421	| `cleanup.sh` + 5 `bin/` helpers | W6 build slice | ✅ built |
   422	| 3 fixtures + 3 deterministic DB-backed fixture suites | W6 build slice | ✅ built (green in build-gate.sh) |
   423	| Tacit-note taxonomy v0.1 (8 categories, deterministic cues) | §3; founder prune/expand with first pilot | ✅ implemented (v0.1) |
   424	| **Granola: IFOS-side OAuth token on disk** (`@ifos/granola` reads its own token bundle, not the Claude-Code MCP keychain) | Founder OAuth dance | ⏸ |
   425	| **Granola: `@ifos/granola` CLI built** (`list-meetings --since` / `get-transcript --meeting` — expected surface documented at the cycle.sh call sites) | Connector build slice | ⏸ |
   426	| ≥1 recorded meeting in the test workspace | Founder | ⏸ |
   427	| **Bullhorn dev creds provisioned** (BULLHORN_CLIENT_ID/SECRET — EMPTY as of 2026-06-10) | Founder commercial action | ⏸ |
   428	| **`@ifos/bullhorn` CLI bridge** (Janitor build slice, parallel; agreed contract in review-scribe.md) | Janitor branch merge | ⏸ |
   429	| Bullhorn Sub-decision B (write scope) Accepted | Bullhorn partnerships response | ⏸ (Sub-decision A RESOLVED 2026-06-02) |
   430	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   431	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   432	| Voice-classifier microservice (until then: honest `unscored`) | W4-5 polish — NOT built | ⏸ |
   433	| LLM extraction live use (path built, opt-in `IFOS_SCRIBE_USE_LLM=1`) | Founder cost approval (§9 Q2) | ⏸ |
   434	
   435	Pre-pivot rows removed 2026-06-10: Fathom/Fireflies commercial signup + connector + per-tenant provider routing (superseded by the Granola pivot; no longer dependencies of anything).
   436	
   437	**Live smoke checklist (founder-gated):** provision Bullhorn sandbox creds → land the Janitor `@ifos/bullhorn` bridge → complete the Granola OAuth dance → record ≥1 meeting → run `cycle.sh --mode replay --call-id <meeting_id>` without `BH_BRIDGE_TEST_MODE`.
   438	
   439	---
   440	
   441	## §9 — Status + open questions
   442	
   443	**Status:** Proposed. W6 build slice BUILT + fixture-proven (this branch); live smoke awaits the §8 ⏸ gates (Bullhorn creds + bridge merge + Granola token + recorded meeting) + Q1 LOI / pilot tenant.
   444	
   445	### Open questions for founder review
   446	
   447	| # | Question | Resolution path |
   448	|---|---|---|
   449	| Q1 | ~~Fathom vs Fireflies — first-mover provider for v1.0?~~ **RESOLVED 2026-06-03 (Day-29 pivot): Granola is the v1.0 vendor** (founder decision; poll-sweep trigger). Fathom/Fireflies are not in v1.0. | Closed. |
   450	| Q2 | Per-call cost ceiling — LLM extraction + voice classification per call. Budget per pilot tenant? (v1.0 default is the zero-LLM deterministic extractor; this gates enabling `IFOS_SCRIBE_USE_LLM=1`.) | Cost model: ~$0.10-0.30 per call (Claude API + voice classifier). At 50 calls/day per consultant × 5 consultants per tenant = ~$25-75/day per tenant. |
   451	| Q3 | Tacit-note taxonomy v0.1 — 8 categories implemented in §3 above. Founder confidence each is high-value? | Founder review with first pilot tenant's consultants during onboarding; can prune/expand based on actual consultant patterns. |
   452	| Q4 | Webhook replay protection (SECONDARY mode only) — should Scribe reject webhook payloads >5 min old? Moot for the primary poll-sweep path (no inbound webhooks at v1.0). | Recommend yes when a push provider lands; timeout config in tools.yaml then. |
   453	| Q5 | Bullhorn write atomicity — Step 9 rollback of Step 8 on note-attach failure is best-effort PATCH (cache restore + reverse PATCH; the Gate-B recent_edit row is insert-after-settle so it never needs unwinding). Could leave the Bullhorn entity in mid-state. | v1.0 accept; document risk. v1.1+: investigate Bullhorn transaction API if exposed. |
   454	| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
   455	| Q7 | What happens when a transcript references PII outside the tenant's Bullhorn data (e.g., a candidate's spouse's medical condition)? | Control point is the NOTE body (declared deviation 10, §4 Step 3): Gate A G6 full-body scan blocks the note write + fires ESC_PII_LEAKAGE_RISK; the transcript itself stays 0600 in /tmp and is purged ≤24h. Document tenant policy. |
   456	
   457	### Gotchas (carried forward from ULTRAPLAN A3 line 527)
   458	
   459	1. **Tacit-note extraction is the hard part.** Start with small taxonomy (8 categories above); expand based on consultant feedback. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
   460	2. **Transcript availability varies by Granola plan tier.** `get-transcript` is a PAID-plan tool; free workspaces degrade to notes-only ingest (pre-guarded via plan_tier cache — no wasted wire call). IFOS workspace confirmed Paid (founder 2026-06-03).
   461	3. **LLM hallucination on field extraction is the failure mode** (when the opt-in LLM path is enabled). Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks + deterministic fallback on any failure.
   462	
   463	---
   464	
   465	## §10 — When this document ratifies
   466	
   467	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict. The status flip below is FOUNDER-GATED — the 2026-06-10 Granola/built-state reconciliation of this document deliberately did NOT exercise it.
   468	
   469	Status flips Proposed → Accepted when:
   470	- Codex Round 4 Phase 2 ratifies
   471	- Founder approves §9 Q3 (taxonomy) — Q1 already RESOLVED by the Day-29 Granola pivot (founder 2026-06-03); Q4 (webhook replay timeout) deferred with the secondary-mode push provider
   472	- Q2 cost model approved with budget cap (gates LLM-path enablement)
   473	
   474	Status flips Accepted → In Force when:
   475	- ~~W6 build slice produces all 5 sibling bundle files + 3 fixtures~~ ✅ done 2026-06-10 (this branch; fixture-proven, live smoke pending)
   476	- First production transcript processed end-to-end against migration-test tenant (needs the §8 ⏸ live gates)
   477	- SLA + edit-rate Gate-B metrics measurable
   478	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   479	
   480	Until then: this document is the post-build contract record — reconciled to what was built, with live operation still gated.
   481	
   482	*End of Scribe agent.md draft.*

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
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '1,260p' && nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
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
   161	        type: array
   162	        items:
   163	          type: string
   164	        required: false
   165	        notes: |
   166	          Anti-requirements; Sourcing Scout EXCLUDES candidates matching any
   167	          item.
   168	        source: IFOS-derived (Scribe extracts)
   169	        v1_0_agent_access:
   170	          - Scribe: R+W
   171	          - Sourcing Scout: R
   172	
   173	  placement:
   174	    v0_3_new_keys:
   175	      placement_status:
   176	        type: string
   177	        enum: [pending_start, active, completed, terminated_early, on_hold, cancelled]
   178	        default: pending_start
   179	        required: false
   180	        notes: |
   181	          Lifecycle state tracking. Scribe sets 'active' at 7d check-in
   182	          confirming candidate started. Janitor flags ambiguous via
   183	          ESC_LIFECYCLE_STATE_UNKNOWN.
   184	        source: IFOS-derived (Scribe + Janitor)
   185	        v1_0_agent_access:
   186	          - Scribe: R+W
   187	          - Janitor: R+W
   188	          - Concierge: R
   189	
   190	      week_1_status_vault_path:
   191	        type: string
   192	        max_length: 200
   193	        pattern: '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$'
   194	        required: false
   195	        notes: |
   196	          POINTER ONLY (per ADR-002 vault/Postgres split). The 7d check-in
   197	          narrative itself lives in vault at `/vault/<tenant>/scribe-notes/
   198	          <call_id>-<ISO-date>.md` (canonical Scribe tacit-note pattern).
   199	          Pattern accepts call_ids + ISO dates (hyphens + underscores +
   200	          alphanumerics). This field stores the vault path; narrative does
   201	          NOT enter Postgres. Voice-classifier review at write time applies
   202	          to the vault file content; Concierge reads the vault file directly
   203	          via its path resolution.
   204	        source: IFOS-derived (Scribe extracts from 7d check-in call; writes
   205	          to vault then stores pointer here)
   206	        v1_0_agent_access:
   207	          - Scribe: R+W
   208	          - Concierge: R
   209	
   210	      satisfaction_signal:
   211	        type: string
   212	        enum: [positive, neutral, negative, unclear]
   213	        default: unclear
   214	        required: false
   215	        notes: |
   216	          Scribe's LLM-sentiment inference from 7d/30d/90d check-in call.
   217	          Concierge reads to adjust nurture tone.
   218	        source: IFOS-derived (Scribe LLM extraction)
   219	        v1_0_agent_access:
   220	          - Scribe: R+W
   221	          - Concierge: R
   222	
   223	  opportunity:
   224	    v0_3_new_keys:
   225	      headcount_growth_signal_text:
   226	        type: string
   227	        max_length: 280
   228	        required: false
   229	        notes: |
   230	          Free-text capture of growth-signal phrases from prospecting calls
   231	          ("we're hiring 5 engineers this quarter"). Sourcing Scout reads
   232	          to ICP-fit-score opportunities.
   233	        source: IFOS-derived (Scribe extraction)
   234	        v1_0_agent_access:
   235	          - Scribe: R+W
   236	          - Sourcing Scout: R
   237	
   238	      hiring_velocity_band:
   239	        type: string
   240	        enum: [slow, moderate, fast, urgent, unknown]
   241	        default: unknown
   242	        required: false
   243	        notes: |
   244	          Scribe LLM inference from prospecting-call urgency cues. Drives
   245	          ranking in Sourcing Scout's brief-to-candidate pipeline.
   246	        source: IFOS-derived (Scribe LLM classification)
   247	        v1_0_agent_access:
   248	          - Scribe: R+W
   249	          - Sourcing Scout: R
   250	
   251	      decision_window_text:
   252	        type: string
   253	        max_length: 280
   254	        required: false
   255	        notes: |
   256	          Free-text capture of decision-timing phrases. Concierge reads to
   257	          time outbound comms.
   258	        source: IFOS-derived (Scribe extraction)
   259	        v1_0_agent_access:
   260	          - Scribe: R+W

codex
So far I have one likely load-bearing issue: the document claims the primary Scribe action type is yellow-tier, but the runtime policy table may not contain that action type. I’m checking implementation and schema details before deciding whether there are additional blocking findings.
exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
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
/bin/zsh -lc 'rg -n "decision_authority|role_type|start_date_target|salary_min|salary_max|start_date:|placement_status|satisfaction_signal|preferred_channel|next_action_target_date|headcount_growth_signal_text" docs/verticals/recruitment/vertical-schema*.yaml' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:205:    linkedin_url, preferred_channel, next_action_target_date, must_haves,
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:206:    nice_to_haves, deal_breakers, placement_status, week_1_status_vault_path,
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:207:    satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band,
docs/verticals/recruitment/vertical-schema.yaml:316:      decision_authority:
docs/verticals/recruitment/vertical-schema.yaml:366:      role_type:
docs/verticals/recruitment/vertical-schema.yaml:371:      salary_min:
docs/verticals/recruitment/vertical-schema.yaml:376:      salary_max:
docs/verticals/recruitment/vertical-schema.yaml:402:      start_date_target:
docs/verticals/recruitment/vertical-schema.yaml:442:      start_date:
docs/verticals/recruitment/vertical-schema.yaml:819:  Q5_contact_decision_authority_granularity:
docs/verticals/recruitment/vertical-schema.yaml:821:    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:18:# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:107:      preferred_channel:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:120:      next_action_target_date:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:175:      placement_status:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:210:      satisfaction_signal:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:225:      headcount_growth_signal_text:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:284:#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:285:#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:287:#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:403:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:495:      preferred_channel + next_action_target_date; Janitor also dedup-merges).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:507:      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:972:  Q3_placement_status_enum_lifecycle:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:973:    question: 6-state placement_status enum maps to Bullhorn's native state machine?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:977:      C: Add a mapping table (auxiliary) — placement_status_mapping with
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1028:      the v0.3-added fields (employment_type, key_skills, preferred_channel,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1029:      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1030:      placement_status, week_1_status_vault_path, satisfaction_signal,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1031:      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1036:      start_date_target; opportunity.sector — not yet in schema). These

exec
/bin/zsh -lc 'rg -n "bullhorn_scribe_field_write|bullhorn_note_append_summary|tacit_note_rendered|webhook_verified|granola_meetings_polled|note_attach_deferred|scribe_run_complete|bullhorn_auth_refreshed|fields_validated|fields_extracted|entity_resolved|transcript_fetched|dry_run_writes_skipped" agents/_shared/autosend-policy.yaml agents/recruitment/scribe -S' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:83:  scribe_run_complete:
agents/_shared/autosend-policy.yaml:212:  bullhorn_note_append_summary:
agents/_shared/autosend-policy.yaml:240:  bullhorn_scribe_field_write:
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:25:#         degradation HONESTLY on the audit rows instead (transcript_fetched
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:126:    - action_type: bullhorn_scribe_field_write
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:133:    - action_type: bullhorn_note_append_summary
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:157:      output_type: webhook_verified          # poll trigger → signature:not_applicable (spec-002 §3)
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:159:      output_type: granola_meetings_polled
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:161:      output_type: bullhorn_auth_refreshed   # spec-002 §3 name
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:163:      output_type: transcript_fetched
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:166:      output_type: entity_resolved
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:168:      output_type: fields_extracted
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:171:      output_type: tacit_note_rendered
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:173:      output_type: fields_validated
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:175:      action_type: bullhorn_scribe_field_write
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:178:      action_type: bullhorn_note_append_summary
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:180:      action_type: scribe_run_complete
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:153:      output_type: webhook_verified          # poll trigger → signature:not_applicable (spec-002 §3)
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:155:      output_type: granola_meetings_polled
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:157:      output_type: bullhorn_auth_refreshed   # spec-002 §3 name
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:159:      output_type: transcript_fetched
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:161:      output_type: entity_resolved
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:163:      output_type: fields_extracted
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:166:      output_type: tacit_note_rendered
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:169:      output_type: fields_validated          # Step 7 schema pass precedes the Gate A voice fail
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:176:      action_type: scribe_run_complete
agents/recruitment/scribe/fixtures/01-primary.yaml:11:#   @ifos/bullhorn updateCandidate (yellow tier bullhorn_scribe_field_write)
agents/recruitment/scribe/fixtures/01-primary.yaml:13:#   bullhorn_note_append_summary) → Step 10 elapsed_seconds=240 (well under
agents/recruitment/scribe/fixtures/01-primary.yaml:21:#         downstream contract (bullhorn_auth_refreshed, webhook_verified, ...)
agents/recruitment/scribe/fixtures/01-primary.yaml:127:    - action_type: bullhorn_scribe_field_write
agents/recruitment/scribe/fixtures/01-primary.yaml:133:    - action_type: bullhorn_note_append_summary
agents/recruitment/scribe/fixtures/01-primary.yaml:147:      output_type: webhook_verified           # spec-002 §3; poll trigger → signature:not_applicable
agents/recruitment/scribe/fixtures/01-primary.yaml:149:      output_type: granola_meetings_polled    # poll-sweep discovery marker (Granola pivot; extra to the §3 set)
agents/recruitment/scribe/fixtures/01-primary.yaml:151:      output_type: bullhorn_auth_refreshed    # spec-002 §3 name (skeleton-era bullhorn_auth_refresh superseded)
agents/recruitment/scribe/fixtures/01-primary.yaml:153:      output_type: transcript_fetched
agents/recruitment/scribe/fixtures/01-primary.yaml:155:      output_type: entity_resolved
agents/recruitment/scribe/fixtures/01-primary.yaml:157:      output_type: fields_extracted
agents/recruitment/scribe/fixtures/01-primary.yaml:159:      output_type: tacit_note_rendered        # payload: {vault_path, body_sha256, voice_score} only (ADR-002)
agents/recruitment/scribe/fixtures/01-primary.yaml:161:      output_type: fields_validated
agents/recruitment/scribe/fixtures/01-primary.yaml:163:      action_type: bullhorn_scribe_field_write
agents/recruitment/scribe/fixtures/01-primary.yaml:165:      action_type: bullhorn_note_append_summary
agents/recruitment/scribe/fixtures/01-primary.yaml:167:      action_type: scribe_run_complete
agents/recruitment/scribe/validate.sh:26:#           "fields_extracted": [
agents/recruitment/scribe/validate.sh:180:  '[.fields_extracted[]? | select(.confidence >= $t)] | length' "${PROPOSAL}" 2>/dev/null || echo 0)"
agents/recruitment/scribe/validate.sh:217:jq -c '.fields_extracted // []' "${PROPOSAL}" > "${_FIELDS_TMP}"
agents/recruitment/scribe/validate.sh:299:# Re-query decision_log for a fresh bullhorn_auth_refreshed row (≤10 min)
agents/recruitment/scribe/validate.sh:311:  AND payload->>'output_type' = 'bullhorn_auth_refreshed'
agents/recruitment/scribe/validate.sh:320:    _fail "G7: no fresh successful bullhorn_auth_refreshed row (got: '${_auth_row:-none}') — Bullhorn writes blocked"
agents/recruitment/scribe/validate.sh:354:  # fields_extracted_count, confidence_floor, required_minimum, agent_name.
agents/recruitment/scribe/validate.sh:357:    _esc_extra+=("entity_type=${ENTITY_TYPE}" "fields_extracted_count=${_n_conf}" \
agents/recruitment/scribe/cycle.sh:34:#   1  webhook signature verify / poll     webhook_verified (+ granola_meetings_polled)
agents/recruitment/scribe/cycle.sh:35:#   2  Bullhorn auth refresh               bullhorn_auth_refreshed   ESC_BULLHORN_AUTH
agents/recruitment/scribe/cycle.sh:36:#   3  Granola transcript fetch → /tmp     transcript_fetched        ESC_PROVIDER_FETCH_FAIL
agents/recruitment/scribe/cycle.sh:37:#   4  participant → entity resolution     entity_resolved           ESC_AGENT_OUTPUT_SHAPE
agents/recruitment/scribe/cycle.sh:38:#   5  field extraction (≥0.6 conf; per-   fields_extracted          ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
agents/recruitment/scribe/cycle.sh:40:#   6  tacit-note → vault (0600)           tacit_note_rendered       ESC_VOICE_DRIFT (via Gate A)
agents/recruitment/scribe/cycle.sh:41:#   7  schema validation + Gate A          fields_validated          ESC_SCHEMA_VIOLATION
agents/recruitment/scribe/cycle.sh:42:#   8  Bullhorn field write (yellow)       bullhorn_scribe_field_write  ESC_BULLHORN_WRITE_FAIL
agents/recruitment/scribe/cycle.sh:43:#   9  Bullhorn note attach (yellow)       bullhorn_note_append_summary ESC_BULLHORN_WRITE_FAIL (+rollback of 8)
agents/recruitment/scribe/cycle.sh:44:#   10 session close + SLA                 scribe_run_complete       ESC_SCRIBE_SLA_MISS
agents/recruitment/scribe/cycle.sh:57:#      (yellow bullhorn_scribe_field_write;
agents/recruitment/scribe/cycle.sh:189:# Reference: spec-002 §4 Step 1 (marker webhook_verified; ESC_INPUT_VALIDATION_FAIL
agents/recruitment/scribe/cycle.sh:213:    hh_decision_output "webhook_verified" "call:${_wh_call_id}" \
agents/recruitment/scribe/cycle.sh:217:  hh_decision_output "webhook_verified" "call:${_wh_call_id}" \
agents/recruitment/scribe/cycle.sh:226:  hh_decision_output "webhook_verified" "call:${CALL_ID_ARG:-sweep}" \
agents/recruitment/scribe/cycle.sh:248:  hh_decision_output "granola_meetings_polled" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/scribe/cycle.sh:275:hh_decision_output "bullhorn_auth_refreshed" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/scribe/cycle.sh:387:  hh_decision_output "transcript_fetched" "call:${call_id}" \
agents/recruitment/scribe/cycle.sh:431:  hh_decision_output "entity_resolved" "${entity_type}:${bullhorn_id}" \
agents/recruitment/scribe/cycle.sh:450:  hh_decision_output "fields_extracted" "${entity_type}:${bullhorn_id}" \
agents/recruitment/scribe/cycle.sh:454:    # 2026-06-10): entity_type, fields_extracted_count, confidence_floor,
agents/recruitment/scribe/cycle.sh:458:      "fields_extracted_count=${n_above}" "confidence_floor=0.6" \
agents/recruitment/scribe/cycle.sh:511:  hh_decision_output "tacit_note_rendered" "${vault_path_logical}" \
agents/recruitment/scribe/cycle.sh:528:  hh_decision_output "fields_validated" "${entity_type}:${bullhorn_id}" \
agents/recruitment/scribe/cycle.sh:542:       webhook_sig_state: $sig, fields_extracted: $fields,
agents/recruitment/scribe/cycle.sh:559:    hh_decision_output "dry_run_writes_skipped" "call:${call_id}" \
agents/recruitment/scribe/cycle.sh:632:  hh_decision_action "bullhorn_scribe_field_write" "${entity_type}:${bullhorn_id}" "${payload_hash}" \
agents/recruitment/scribe/cycle.sh:663:      hh_decision_action "bullhorn_note_append_summary" "${entity_type}:${bullhorn_id}" "${body_sha}" \
agents/recruitment/scribe/cycle.sh:670:      hh_decision_output "note_attach_deferred" "${entity_type}:${bullhorn_id}" \
agents/recruitment/scribe/cycle.sh:673:      hh_decision_output "note_attach_deferred" "${entity_type}:${bullhorn_id}" \
agents/recruitment/scribe/cycle.sh:679:      hh_decision_output "note_attach_deferred" "${entity_type}:${bullhorn_id}" \
agents/recruitment/scribe/cycle.sh:721:VALUES (:'tenant', 'scribe', 'bullhorn_scribe_field_write', :'et', :'eid', :'fm', 'deferred', now());
agents/recruitment/scribe/cycle.sh:774:hh_decision_action "scribe_run_complete" "call:${LAST_CALL_ID}" "${_run_hash}" \
agents/recruitment/scribe/tools.yaml:33:# Scribe's 2 yellow-tier write action_types (bullhorn_scribe_field_write +
agents/recruitment/scribe/tools.yaml:34:# bullhorn_note_append_summary) are REGISTERED in autosend-policy.yaml
agents/recruitment/scribe/tools.yaml:52:  # Step 9 defers the note attach (note_attach_deferred output row).
agents/recruitment/scribe/tools.yaml:92:    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED in autosend-policy.yaml line 240
agents/recruitment/scribe/tools.yaml:99:    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
agents/recruitment/scribe/tools.yaml:109:    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
agents/recruitment/scribe/tools.yaml:118:    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
agents/recruitment/scribe/tools.yaml:127:    action_type: bullhorn_note_append_summary  # yellow tier; REGISTERED in autosend-policy.yaml line 212
agents/recruitment/scribe/tools.yaml:273:#   bullhorn_scribe_field_write     line 240   yellow   (emitted by cycle.sh Step 8)
agents/recruitment/scribe/tools.yaml:274:#   bullhorn_note_append_summary    line 212   yellow   (emitted by cycle.sh Step 9)
agents/recruitment/scribe/tools.yaml:276:#   scribe_run_complete             line  83   green    (emitted by cycle.sh Step 10)
agents/recruitment/scribe/tools.yaml:281:#                                            bullhorn_auth_refreshed output row)
agents/recruitment/scribe/agent.md:33:`list-meetings --since <ISO>`; `granola_meetings_polled` discovery row) and
agents/recruitment/scribe/agent.md:34:runs Steps 2-10 per new meeting. The Step-1 `webhook_verified` marker is
agents/recruitment/scribe/agent.md:39:`dry_run_writes_skipped` row).
agents/recruitment/scribe/agent.md:51:mismatch → `ESC_INPUT_VALIDATION_FAIL` + `webhook_verified` row with
agents/recruitment/scribe/agent.md:114:  `bullhorn_scribe_field_write` action row records
agents/recruitment/scribe/agent.md:117:  a `note_attach_deferred` output row,
agents/recruitment/scribe/agent.md:134:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:163:Each tacit-note write emits its own `decision_log` rows: on vault render, `agent_name='scribe'`, `phase='output'`, `output_type='tacit_note_rendered'` carrying `{vault_path, body_sha256, voice_score}` (body NOT in payload per ADR-002 vault/Postgres split); on Bullhorn attach, `phase='action'`, `action_type='bullhorn_note_append_summary'`, `tier='yellow'`, payload carrying `note_payload_hash` + `payload_preview` + the resolved `<entity_type>:<bullhorn_id>` (per §4 Steps 6 + 9).
agents/recruitment/scribe/agent.md:191:     <CTX_GRANOLA_LAST_POLL>; emits webhook_verified with
agents/recruitment/scribe/agent.md:193:     verify) + granola_meetings_polled discovery row (count, window,
agents/recruitment/scribe/agent.md:200:   → hh_decision_output("webhook_verified", "call:<id|sweep>", "provider:granola; …")
agents/recruitment/scribe/agent.md:207:   → hh_decision_output("bullhorn_auth_refreshed", "tenant:<slug>",
agents/recruitment/scribe/agent.md:223:   → hh_decision_output("transcript_fetched", "call:<id>",
agents/recruitment/scribe/agent.md:232:   → hh_decision_output("entity_resolved", "<entity_type>:<bullhorn_id>",
agents/recruitment/scribe/agent.md:244:     (catalogue aggregate form — payload: entity_type, fields_extracted_count,
agents/recruitment/scribe/agent.md:246:   → hh_decision_output("fields_extracted", "<entity_type>:<bullhorn_id>",
agents/recruitment/scribe/agent.md:260:   → hh_decision_output("tacit_note_rendered", "<vault_path>",
agents/recruitment/scribe/agent.md:270:   → on success: hh_decision_output("fields_validated", "<entity_type>:<bullhorn_id>",
agents/recruitment/scribe/agent.md:288:   → on success: hh_decision_action("bullhorn_scribe_field_write",
agents/recruitment/scribe/agent.md:303:     (candidate/contact); otherwise honest defer (note_attach_deferred row,
agents/recruitment/scribe/agent.md:305:   → bridge unavailable: note_attach_deferred row (no yellow row — no
agents/recruitment/scribe/agent.md:307:   → on success: hh_decision_action("bullhorn_note_append_summary",
agents/recruitment/scribe/agent.md:328:   → hh_decision_action("scribe_run_complete", "call:<last_id>",
agents/recruitment/scribe/agent.md:349:- G7 — Bullhorn auth refresh succeeded this session (fresh `bullhorn_auth_refreshed` row, result fresh|refreshed; `unavailable`/`failed`/absent blocks all Bullhorn writes)
agents/recruitment/scribe/agent.md:379:| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | Catalogue **aggregate form** (escalation-codes.md, amended 2026-06-10): extracted fields with confidence ≥0.6 below the per-entity Gate A minimum (Contact 2, others 3 — §3). Payload: `entity_type`, `fields_extracted_count`, `confidence_floor` (0.6), `required_minimum`, `agent_name` | warn | operator_chat_id |

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
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

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '232,250p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '260,430p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '300,455p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
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

 succeeded in 0ms:
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
   431	      A candidate placed into a client role. The commercial transaction unit — fees accrue per placement, lifecycle events (week-1, month-1, etc.) fire per placement per Product Spec §2.2 R7.
   432	    bullhorn_source: Bullhorn.Placement
   433	    v1_0_agent_access:
   434	      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
   435	      - Scribe (R+W — note links per bullhorn §4.1 A3)
   436	      - Concierge (R+W — lifecycle stage maintenance per bullhorn §4.1 A6)
   437	    canonical_fields:
   438	      bullhorn_id:
   439	        type: integer
   440	        required: true
   441	        source: Bullhorn.Placement.id
   442	      start_date:
   443	        type: date
   444	        required: true
   445	        source: Bullhorn.Placement.dateBegin
   446	      end_date:
   447	        type: date
   448	        required: false
   449	        source: Bullhorn.Placement.dateEnd
   450	        notes: Nullable for permanent placements; required for contract.
   451	      status:
   452	        type: string
   453	        required: true
   454	        enum: [active, completed, terminated, never_started]
   455	        source: Bullhorn.Placement.status (with mapping)

 succeeded in 0ms:
   260	          - Scribe: R+W
   261	          - Concierge: R
   262	
   263	# ============================================================================
   264	# §2 — Complete v0.3 agent access matrix
   265	# ============================================================================
   266	#
   267	# Per review-schema-change skill §5: full matrix across all v1.0 agents
   268	# and all v0.1 + v0.2 entities. v0.3 is a CUMULATIVE matrix that includes
   269	# v0.1 + v0.2 + v0.3 dispositions. Where this matrix differs from
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
   293	#     — v0.3 amendment)
   294	#   - Cash Conductor placement: none → R (reads for client linkage on invoice)
   295	#   - Cash Conductor timesheet: none → R (reads to verify billable hours
   296	#     match invoiced amounts)
   297	#   - Sourcing Scout candidate: stays R (the original v0.3 draft proposed R+W
   298	#     for proposed-candidate writes; REVERTED at R20 — proposed matches live
   299	#     in the Sourcing Scout shortlist artefact, not Bullhorn-backed entities,
   300	#     per bullhorn-integration-path §4.1 A5 + sourcing-scout/agent.md §6)
   301	#   - Sourcing Scout contractor: stays R (same revert as candidate)
   302	#   - Sourcing Scout opportunity: none → R (reads opportunity context for ICP)
   303	#   - Concierge candidate: R → R+W (writes lifecycle-state-derived fields +
   304	#     activity-log links per concierge §4 Step 13-14 — v0.3 amendment)
   305	#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
   306	#   - Concierge opportunity: none → R (reads for outbound lifecycle-event context)
   307	#   - Concierge placement: R → R+W (writes Bullhorn state advancement per
   308	#     concierge §4 Step 14 — v0.3 amendment)
   309	#   - Concierge timesheet: none → R (reads to verify placement-progress for
   310	#     7d/30d/90d nurture)
   311	#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
   312	#     extended)
   313	#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
   314	#     — v0.2 extended)
   315	#
   316	# All other access levels carry forward unchanged from v0.1 + v0.2.
   317	
   318	agent_access_matrix:
   319	
   320	  # Disposition tokens: R | W | R+W | none
   321	  #
   322	  # SCOPE: This matrix is rectangular across `entities:` entity_types ONLY
   323	  # (candidate, contractor, client, contact, brief, opportunity, placement,
   324	  # timesheet — 8 v0.1 entity_types).
   325	  #
   326	  # SCHEMA-LAYERING CORRECTION: The v0.2 supplement uses the YAML key
   327	  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
   328	  # voice_corpus_chunks is introduced separately around v0.2 supplement line
   329	  # 270 as the pgvector auxiliary table — it was always auxiliary, never
   330	  # under `entities:`. v0.2 supplement §1 "LAYERING DISCLOSURE" states the
   331	  # three `entities:`-keyed objects "are auxiliary Postgres tables (real
   332	  # CREATE TABLE statements in migrations/v0.1-to-v0.2.sql), NOT entity_types
   333	  # in the entities/entity_links generic primitive layer from Day-4 §6.3."
   334	  # v0.3 adopts this disclosure as the authoritative classification: all
   335	  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
   336	  # AUXILIARY, NOT entities. Their access lives in
   337	  # `auxiliary_table_access_matrix` below + §2a access amendments — NOT in
   338	  # this entity matrix. The v0.2 YAML key `entities:` was documentation
   339	  # convention; v0.3 reclassifies per the v0.2 LAYERING DISCLOSURE intent.
   340	  #
   341	  # ENTITY-LEVEL vs FIELD-LEVEL ACCESS:
   342	  # The matrix below is ENTITY-LEVEL — declares the maximum disposition an
   343	  # agent may have on any field of that entity.
   344	  #
   345	  # FIELD_ACCESS_NARROWING_RULE (v0.3 explicit scope rule, ratified as part
   346	  # of this supplement):
   347	  #   Per-field access (in §1 entity_field_additions[*].v1_0_agent_access)
   348	  #   NARROWS the entity-level disposition. The entity-level token is the
   349	  #   CEILING; field-level may be narrower (or absent — implying the agent
   350	  #   has the entity-level default) but NEVER BROADER than the matrix entry.
   351	  #   Example: Scribe.candidate: R+W at entity level; per-field
   352	  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
   353	  #   without reading it). Another example: Diagnostic.candidate: R at entity
   354	  #   level; candidate.linkedin_url has no Diagnostic field entry; Diagnostic
   355	  #   gets R on linkedin_url (entity-level default), not the broader Janitor
   356	  #   R+W on candidate.linkedin_url (Janitor.candidate is R+W at entity level
   357	  #   per the v0_3_v1_0_agent_access matrix below). Implementation:
   358	  #   cycle.sh + hh_decision_action records which
   359	  #   agent + which fields were touched in decision_log payload; reviewers
   360	  #   audit via that trail. v0.3 does NOT enforce this rule at the database
   361	  #   layer (column-level RLS would be required; v1.1+ work per the
   362	  #   "documentary not enforced" note above).
   363	  #
   364	  # Validation: the validate_entities_data_v0_3 trigger validates FIELD
   365	  # SHAPE only (type checks, enum membership, length caps, array element
   366	  # types). It does NOT enforce which agent is writing — agent-level
   367	  # write permission is DOCUMENTARY in v0.3, enforced at the application
   368	  # layer (cycle.sh + hh_decision_action) where the agent_name in the
   369	  # decision_log row records who wrote. Entity-level RLS enforces TENANT
   370	  # isolation but not agent-level access. Column-level RLS or per-agent
   371	  # database roles would be the v1.1+ enforcement layer; v0.3 is documentary.
   372	
   373	  diagnostic:
   374	    candidate: R           # reads for outreach context (§11 decision-maker map)
   375	    contractor: none       # not in scope at v1.0
   376	    client: R              # reads via Companies House lookup (entity-shape if cached)
   377	    contact: R             # reads for §11 decision-maker map
   378	    brief: none            # diagnostic is sales-tool not brief-driven
   379	    opportunity: R         # may read prospect-firm opportunity if exists
   380	    placement: none
   381	    timesheet: none
   382	
   383	  janitor:
   384	    candidate: R+W         # dedup + field-backfill writes
   385	    contractor: R+W        # dedup + field-backfill writes
   386	    client: R+W            # Companies House enrichment writes
   387	    contact: R+W           # dedup + field-backfill writes
   388	    brief: R               # context for related candidate cleanup
   389	    opportunity: R
   390	    placement: R+W         # lifecycle-state cleanup
   391	    timesheet: R           # reads for placement-state inference
   392	
   393	  scribe:
   394	    # Scribe's Bullhorn endpoint access (Candidate / ClientCorporation /
   395	    # JobOrder / Note / Placement) per bullhorn-integration-path.md §4.1
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
   408	
   409	  cash_conductor:
   410	    # NOTE: Cash Conductor has NO direct Bullhorn endpoint access per
   411	    # bullhorn-integration-path.md §1.2 A4 ("No direct Bullhorn"). All
   412	    # entity reads below are against IFOS-cached Postgres rows
   413	    # (populated by Janitor + Scribe + Concierge from their Bullhorn
   414	    # sync paths). Cash Conductor never calls Bullhorn endpoints directly.
   415	    candidate: none        # no Bullhorn dependency
   416	    contractor: none
   417	    client: R              # IFOS-cached read; client billing details
   418	    contact: R             # IFOS-cached read; invoice addressee resolution
   419	    brief: none
   420	    opportunity: R         # v0.3 NEW — IFOS-cached read; invoice-context (NOT a direct Bullhorn call; only cached rows)
   421	    placement: R           # IFOS-cached read; client linkage on invoice
   422	    timesheet: R           # IFOS-cached read; verify billable hours match invoice (NOT a direct Bullhorn call)
   423	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   424	
   425	  sourcing_scout:
   426	    # v0.3 EXPLICIT OVERRIDES — R20 reconciliation (2026-05-27): the original
   427	    # v0.3 draft upgraded candidate/contractor to R+W to allow writing
   428	    # proposed-candidate rows. That was REVERTED — Sourcing Scout stays R-only
   429	    # on Bullhorn-backed entities per bullhorn-integration-path §4.1 A5 +
   430	    # sourcing-scout/agent.md §6 ("Bullhorn read-only"). Proposed matches live

exec
/bin/zsh -lc 'rg -n "Composio|AgentMail|packages/harness/cortextos|cortextos|stock KB|kb-" agents/recruitment/scribe/agent.md' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 exited 1 in 0ms:
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/validate.sh | sed -n '1,390p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Scribe agent — validate.sh (Gate A enforcement; W6 build slice LIVE)
     3	#
     4	# Status: built (W6 build slice; the W5 Day-32 skeleton TODO(W6-7) markers are
     5	#         replaced with live checks per spec-002-scribe.md §5 + agent.md §5).
     6	# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
     7	#
     8	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
     9	# hard-fail gate that runs BETWEEN cycle.sh Step 7 (field validation) and
    10	# Step 8 (Bullhorn write). If any check fails, validate.sh exits non-zero +
    11	# emits the ESC_* row + the validate_gate_a_fail action row to decision_log;
    12	# the meeting's Bullhorn writes are skipped; cycle.sh continues to the next
    13	# meeting (poll-sweep mode) or exits with the gate-fail signal (replay/webhook).
    14	#
    15	# Invocation contract:
    16	#   bash validate.sh <extraction_proposal_json>
    17	#
    18	# Inputs:
    19	#   - $1: path to JSON describing the proposed Bullhorn writes for ONE call.
    20	#         Shape:
    21	#         {
    22	#           "call_id": "<granola_meeting_id>",
    23	#           "entity_type": "candidate" | "contact" | "brief" | "placement" | "opportunity",
    24	#           "bullhorn_id": "<id>",
    25	#           "webhook_sig_state": "verified" | "not_applicable" | "invalid" | "missing",
    26	#           "fields_extracted": [
    27	#             {"field_name": "...", "value": ..., "confidence": <0.0-1.0>}
    28	#           ],
    29	#           "tacit_note": {
    30	#             "vault_path": "/vault/<tenant>/scribe-notes/<call_id>-<ISO>.md",
    31	#             "body_sha256": "...",
    32	#             "voice_score": <0.0-1.0> | "unscored",
    33	#             "voice_reason": "...",
    34	#             "narrative_word_count": <int>,
    35	#             "narrative_body_preview": "..."  // first 500 chars — AUDIT ROW ONLY;
    36	#                                              // G6 scans the FULL physical body
    37	#                                              // resolved from vault_path
    38	#           }
    39	#         }
    40	#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_AGENT_DIR,
    41	#          CTX_FIRM_DOMAIN_WHITELIST (comma-separated; for the PII check),
    42	#          IFOS_VAULT_ROOT (physical vault root for resolving vault_path;
    43	#          default ~/.ifos-local-vault — must match cycle.sh)
    44	#
    45	# Exit codes:
    46	#   0  All Gate A checks pass; cycle.sh proceeds to Steps 8 + 9 writes
    47	#   1  At least one check failed; ESC_* row emitted; cycle.sh skips writes
    48	#   2  validate.sh invocation error (bad args, missing file, etc.)
    49	#
    50	# Checks (spec-002 §5 — all 7, in spec order — plus the agent.md §3 word cap):
    51	#   G1 — webhook-sig: valid per provider                    ESC_INPUT_VALIDATION_FAIL  hard
    52	#   G2 — field-count: ≥ per-entity min extractions ≥0.6     ESC_FIELD_EXTRACTION_LOW_CONFIDENCE  hard
    53	#        (contact: 2 — its full Scribe-writable v0.3 set; all others: 3)
    54	#   G3 — tacit-voice: classifier ≥0.75                      ESC_VOICE_DRIFT  hard (warn-when-unscored)
    55	#   G4 — field-names: exist in target entity schema         ESC_SCHEMA_VIOLATION  hard
    56	#   G5 — field-types: per-field type/range valid; ≥ per-entity min valid  ESC_SCHEMA_VIOLATION  hard
    57	#   G6 — PII: none outside firm boundary in note narrative  ESC_PII_LEAKAGE_RISK  hard (blocking)
    58	#        (FULL physical body from tacit_note.vault_path — Step 9 exports the
    59	#        full body to Bullhorn, so the gate scans everything that leaves)
    60	#   G7 — auth: Bullhorn refresh succeeded this session      ESC_BULLHORN_AUTH  hard
    61	#   G8 — word-cap: tacit-note ≤800 words (agent.md §3)      ESC_AGENT_OUTPUT_SHAPE  hard
    62	
    63	set -uo pipefail
    64	
    65	# ────────────────────────────────────────────────────────────────────────
    66	# Pre-flight
    67	# ────────────────────────────────────────────────────────────────────────
    68	
    69	if [[ $# -lt 1 ]]; then
    70	  printf 'scribe/validate.sh: usage: validate.sh <extraction_proposal_json>\n' >&2
    71	  exit 2
    72	fi
    73	
    74	readonly PROPOSAL="$1"
    75	
    76	if [[ ! -f "${PROPOSAL}" ]]; then
    77	  printf 'validate.sh: proposal not found at %s\n' "${PROPOSAL}" >&2
    78	  exit 2
    79	fi
    80	
    81	if [[ -z "${CTX_TENANT_SLUG:-}" || -z "${CTX_AGENT_NAME:-}" ]]; then
    82	  printf 'validate.sh: CTX_TENANT_SLUG or CTX_AGENT_NAME unset\n' >&2
    83	  exit 2
    84	fi
    85	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    86	  printf 'validate.sh: CTX_AGENT_DIR unset\n' >&2
    87	  exit 2
    88	fi
    89	command -v jq >/dev/null 2>&1 || { printf 'validate.sh: jq required\n' >&2; exit 2; }
    90	jq -e 'type=="object"' "${PROPOSAL}" >/dev/null 2>&1 || {
    91	  printf 'validate.sh: proposal is not a JSON object\n' >&2; exit 2; }
    92	
    93	# Resolve _shared/ helpers (4-candidate fallback; matches sibling agents
    94	# per smoke-hotfix commit d7d52c5).
    95	_SHARED_DIR=""
    96	for _candidate in \
    97	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    98	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    99	  "${CTX_AGENT_DIR}/../../_shared" \
   100	  "${CTX_AGENT_DIR}/../_shared" ; do
   101	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
   102	    _SHARED_DIR="${_candidate}"
   103	    break
   104	  fi
   105	done
   106	if [[ -z "${_SHARED_DIR}" ]]; then
   107	  printf 'validate.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
   108	  exit 2
   109	fi
   110	# shellcheck source=/dev/null
   111	source "${_SHARED_DIR}/hook-helpers.sh"
   112	
   113	_BIN="${CTX_AGENT_DIR}/bin"
   114	[[ -d "${_BIN}" ]] || _BIN="${IFOS_REPO_ROOT:-}/agents/recruitment/scribe/bin"
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
   132	# Dominant failure class for ESC routing (first hard fail wins).
   133	ESC_CLASS=""
   134	
   135	# Thresholds (per ULTRAPLAN A3 line 524 + agent.md §3)
   136	readonly FIELD_CONFIDENCE_THRESHOLD="0.6"
   137	readonly VOICE_SCORE_THRESHOLD="0.75"
   138	readonly TACIT_NOTE_WORD_CAP="800"
   139	
   140	CALL_ID="$(jq -r '.call_id // "unknown"' "${PROPOSAL}")"
   141	ENTITY_TYPE="$(jq -r '.entity_type // ""' "${PROPOSAL}")"
   142	BULLHORN_ID="$(jq -r '.bullhorn_id // "unknown"' "${PROPOSAL}")"
   143	
   144	# Per-entity Gate A minimum (Codex R2-1): the v0.3 schema grants Scribe
   145	# exactly TWO writable Contact fields (preferred_channel,
   146	# next_action_target_date — decision_authority is R-only per the v0.3 §2
   147	# access matrix), so a blanket ≥3 bar would hard-fail EVERY legitimate
   148	# Contact-resolved call at G5 (max 2 valid writable fields exist). Contact's
   149	# minimum is its full writable set (2); all other entities keep the
   150	# ULTRAPLAN A3 line 524 ≥3 bar. Extraction may surface more fields; R-only
   151	# fields flow to the tacit-note narrative only, never the write payload.
   152	case "${ENTITY_TYPE}" in
   153	  contact) MIN_FIELDS_REQUIRED="2" ;;
   154	  *)       MIN_FIELDS_REQUIRED="3" ;;
   155	esac
   156	readonly MIN_FIELDS_REQUIRED
   157	
   158	# ────────────────────────────────────────────────────────────────────────
   159	# G1 — Webhook signature valid per provider (spec-002 §5 row 1)
   160	# cycle.sh Step 1 verified the HMAC/bearer and recorded the verdict in the
   161	# proposal. 'not_applicable' = poll-sweep/replay (Granola publishes no
   162	# webhooks — there is no external input to verify); anything else fails hard.
   163	# ────────────────────────────────────────────────────────────────────────
   164	
   165	_sig="$(jq -r '.webhook_sig_state // "missing"' "${PROPOSAL}")"
   166	case "${_sig}" in
   167	  verified)        _ok "G1: webhook signature verified" ;;
   168	  not_applicable)  _ok "G1: webhook signature not applicable (poll/replay trigger; no external webhook input)" ;;
   169	  *)
   170	    _fail "G1: webhook signature state '${_sig}' — reject"
   171	    ESC_CLASS="${ESC_CLASS:-ESC_INPUT_VALIDATION_FAIL}" ;;
   172	esac
   173	
   174	# ────────────────────────────────────────────────────────────────────────
   175	# G2 — structured-field extractions with confidence ≥0.6 meet the
   176	# per-entity minimum (contact: 2; all others: 3 per ULTRAPLAN A3 line 524).
   177	# ────────────────────────────────────────────────────────────────────────
   178	
   179	_n_conf="$(jq --argjson t "${FIELD_CONFIDENCE_THRESHOLD}" \
   180	  '[.fields_extracted[]? | select(.confidence >= $t)] | length' "${PROPOSAL}" 2>/dev/null || echo 0)"
   181	if [[ "${_n_conf}" -ge "${MIN_FIELDS_REQUIRED}" ]]; then
   182	  _ok "G2: ${_n_conf} fields with confidence ≥${FIELD_CONFIDENCE_THRESHOLD} (≥${MIN_FIELDS_REQUIRED} required)"
   183	else
   184	  _fail "G2: only ${_n_conf} fields ≥${FIELD_CONFIDENCE_THRESHOLD} confidence (need ${MIN_FIELDS_REQUIRED})"
   185	  ESC_CLASS="${ESC_CLASS:-ESC_FIELD_EXTRACTION_LOW_CONFIDENCE}"
   186	fi
   187	
   188	# ────────────────────────────────────────────────────────────────────────
   189	# G3 — Tacit-note voice classifier ≥0.75
   190	# Hard fail when a numeric score is below threshold (per agent.md §3: the
   191	# note is NOT attached; the vault draft is flagged needs-consultant-review).
   192	# warn-when-unscored (spec-002 §5): with no tenant voice_corpus (or no
   193	# classifier wired) a score cannot be HONESTLY computed — warn, never fake.
   194	# ────────────────────────────────────────────────────────────────────────
   195	
   196	_voice="$(jq -r '.tacit_note.voice_score // "missing"' "${PROPOSAL}")"
   197	_vreason="$(jq -r '.tacit_note.voice_reason // ""' "${PROPOSAL}")"
   198	if [[ "${_voice}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
   199	  if awk -v s="${_voice}" -v t="${VOICE_SCORE_THRESHOLD}" 'BEGIN{exit !(s>=t)}'; then
   200	    _ok "G3: tacit-note voice score ${_voice} ≥ ${VOICE_SCORE_THRESHOLD}"
   201	  else
   202	    _fail "G3: tacit-note voice score ${_voice} < ${VOICE_SCORE_THRESHOLD} (after retries) — note NOT attached; vault draft held for consultant review"
   203	    ESC_CLASS="${ESC_CLASS:-ESC_VOICE_DRIFT}"
   204	  fi
   205	else
   206	  _warn "G3: voice unscored (${_vreason:-no_reason}) — cannot enforce threshold without a seeded voice_corpus + classifier (never faked)"
   207	fi
   208	
   209	# ────────────────────────────────────────────────────────────────────────
   210	# G4 + G5 — Field names exist in target entity schema + per-field type/range
   211	# Single source of truth: bin/validate-fields.sh (schema-file-derived
   212	# allowlist mirroring the validate_entities_data_v0_3 trigger).
   213	# ────────────────────────────────────────────────────────────────────────
   214	
   215	_FIELDS_TMP="$(mktemp -t scribe-gate-fields-XXXXXX)"
   216	trap 'rm -f "${_FIELDS_TMP}"' EXIT
   217	jq -c '.fields_extracted // []' "${PROPOSAL}" > "${_FIELDS_TMP}"
   218	
   219	_vres="$(bash "${_BIN}/validate-fields.sh" --entity-type "${ENTITY_TYPE}" --fields-file "${_FIELDS_TMP}" 2>/dev/null)" \
   220	  || _vres='{"valid":[],"dropped":[{"field_name":"(validator)","reason":"validate-fields.sh failed"}],"valid_count":0}'
   221	_valid_count="$(jq -r '.valid_count' <<<"${_vres}")"
   222	_bad_names="$(jq -r '[.dropped[] | select(.reason | test("not in .* writable schema"))] | length' <<<"${_vres}")"
   223	_bad_types="$(jq -r '[.dropped[] | select(.reason | test("not in .* writable schema") | not)] | length' <<<"${_vres}")"
   224	
   225	if [[ "${_bad_names}" -eq 0 ]]; then
   226	  _ok "G4: all field names exist in ${ENTITY_TYPE} schema (vertical-schema v0.1+v0.3)"
   227	else
   228	  _fail "G4: ${_bad_names} field name(s) not in ${ENTITY_TYPE} schema: $(jq -r '[.dropped[] | select(.reason | test("not in")) | .field_name] | join(",")' <<<"${_vres}")"
   229	  ESC_CLASS="${ESC_CLASS:-ESC_SCHEMA_VIOLATION}"
   230	fi
   231	
   232	if [[ "${_bad_types}" -eq 0 && "${_valid_count}" -ge "${MIN_FIELDS_REQUIRED}" ]]; then
   233	  _ok "G5: per-field type/range checks pass (${_valid_count} valid)"
   234	else
   235	  if [[ "${_bad_types}" -gt 0 ]]; then
   236	    _fail "G5: ${_bad_types} field(s) failed type/range checks: $(jq -r '[.dropped[] | select(.reason | test("not in") | not) | .field_name + " (" + .reason + ")"] | join("; ")' <<<"${_vres}")"
   237	  fi
   238	  if [[ "${_valid_count}" -lt "${MIN_FIELDS_REQUIRED}" ]]; then
   239	    _fail "G5: only ${_valid_count} valid field(s) after drops (need ${MIN_FIELDS_REQUIRED})"
   240	  fi
   241	  ESC_CLASS="${ESC_CLASS:-ESC_SCHEMA_VIOLATION}"
   242	fi
   243	
   244	# ────────────────────────────────────────────────────────────────────────
   245	# G6 — No PII outside firm boundary in the tacit-note narrative.
   246	# Scans the FULL physical note body resolved from tacit_note.vault_path
   247	# (review F1 fix): Step 9 exports the full body to Bullhorn via
   248	# `create-note --body-file`, so the gate must cover everything that leaves
   249	# the firm boundary. narrative_body_preview is the AUDIT ROW artefact only —
   250	# it is never the scan surface. Fail-closed: a body that cannot be read
   251	# cannot be certified PII-clean, so it blocks.
   252	# Blocking severity per agent.md §6 ESC_PII_LEAKAGE_RISK.
   253	# ────────────────────────────────────────────────────────────────────────
   254	
   255	_vault_path="$(jq -r '.tacit_note.vault_path // ""' "${PROPOSAL}")"
   256	_note_phys=""
   257	if [[ "${_vault_path}" == /vault/* ]]; then
   258	  _note_phys="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${_vault_path#/vault/}"
   259	fi
   260	if [[ -z "${_note_phys}" || ! -r "${_note_phys}" ]]; then
   261	  _fail "G6: tacit-note body unreadable (vault_path:'${_vault_path:-missing}') — cannot certify PII boundary; write blocked"
   262	  ESC_CLASS="ESC_PII_LEAKAGE_RISK"
   263	else
   264	  # Frontmatter excluded (metadata only — call_id/date/voice keys, no
   265	  # narrative). Anchored to the LEADING block ONLY (re-review advisory): a
   266	  # `---` pair must start at line 1 to be frontmatter; later `---` lines in
   267	  # the narrative (e.g. markdown horizontal rules) are BODY and stay in the
   268	  # scan surface. The previous sed range (/^---$/,/^---$/!p) wrongly skipped
   269	  # content between ANY later `---` pair.
   270	  _note_body="$(awk 'NR==1 && /^---$/ {fm=1; next} fm {if (/^---$/) fm=0; next} {print}' "${_note_phys}")"
   271	  _whitelist="${CTX_FIRM_DOMAIN_WHITELIST:-${CTX_TENANT_SLUG}.test}"
   272	  _pii_hit=0
   273	  _body_emails="$(printf '%s' "${_note_body}" | grep -oiE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' | sort -u || true)"
   274	  if [[ -n "${_body_emails}" ]]; then
   275	    while IFS= read -r _em; do
   276	      [[ -z "${_em}" ]] && continue
   277	      _dom="${_em##*@}"
   278	      _allowed=0
   279	      for _fd in ${_whitelist//,/ }; do
   280	        [[ "${_dom,,}" == "${_fd,,}" ]] && _allowed=1
   281	      done
   282	      [[ "${_allowed}" -eq 0 ]] && _pii_hit=1
   283	    done <<<"${_body_emails}"
   284	  fi
   285	  # UK NI numbers + phone-number shapes are also outside-boundary PII in a narrative.
   286	  if printf '%s' "${_note_body}" | grep -qiE '\b[A-CEGHJ-PR-TW-Z]{2}[0-9]{6}[A-D]\b'; then
   287	    _pii_hit=1
   288	  fi
   289	  if [[ "${_pii_hit}" -eq 1 ]]; then
   290	    _fail "G6: PII outside firm boundary detected in tacit-note narrative (full-body scan) — write blocked; vault draft held for review"
   291	    ESC_CLASS="ESC_PII_LEAKAGE_RISK"
   292	  else
   293	    _ok "G6: no PII outside firm boundary in full note body ($(printf '%s' "${_note_body}" | wc -c | tr -d ' ') bytes scanned)"
   294	  fi
   295	fi
   296	
   297	# ────────────────────────────────────────────────────────────────────────
   298	# G7 — Bullhorn auth refresh succeeded this session
   299	# Re-query decision_log for a fresh bullhorn_auth_refreshed row (≤10 min)
   300	# whose result is fresh|refreshed. unavailable/failed/absent = hard fail —
   301	# no stale-token (or no-token) Bullhorn writes, ever.
   302	# ────────────────────────────────────────────────────────────────────────
   303	
   304	_auth_row=""
   305	if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   306	  _auth_row="$(psql "${IFOS_DB_URL}" -tAq --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1
   307	BEGIN;
   308	SET LOCAL app.current_tenant = :'tenant';
   309	SELECT reason FROM decision_log
   310	WHERE tenant_slug = :'tenant' AND agent_name = 'scribe'
   311	  AND payload->>'output_type' = 'bullhorn_auth_refreshed'
   312	  AND created_at > now() - interval '10 minutes'
   313	ORDER BY id DESC LIMIT 1;
   314	COMMIT;
   315	SQL
   316	)"
   317	  if [[ "${_auth_row}" == *"result:fresh"* || "${_auth_row}" == *"result:refreshed"* ]]; then
   318	    _ok "G7: Bullhorn auth refreshed this session (${_auth_row##*result:})"
   319	  else
   320	    _fail "G7: no fresh successful bullhorn_auth_refreshed row (got: '${_auth_row:-none}') — Bullhorn writes blocked"
   321	    ESC_CLASS="${ESC_CLASS:-ESC_BULLHORN_AUTH}"
   322	  fi
   323	else
   324	  _warn "G7: DB unavailable — cannot confirm auth refresh (offline-mode fallback rows not queryable)"
   325	fi
   326	
   327	# ────────────────────────────────────────────────────────────────────────
   328	# G8 — Tacit-note word count ≤800 (agent.md §3 cap; kept from the skeleton
   329	# in ADDITION to the 7 spec-002 §5 checks — notes must stay scannable;
   330	# long-form analysis belongs in the vault, not Bullhorn)
   331	# ────────────────────────────────────────────────────────────────────────
   332	
   333	_words="$(jq -r '.tacit_note.narrative_word_count // 0' "${PROPOSAL}")"
   334	if [[ "${_words}" =~ ^[0-9]+$ ]] && (( _words <= TACIT_NOTE_WORD_CAP )); then
   335	  _ok "G8: tacit-note word count ${_words} ≤ ${TACIT_NOTE_WORD_CAP}"
   336	else
   337	  _fail "G8: tacit-note word count ${_words} exceeds ${TACIT_NOTE_WORD_CAP} cap"
   338	  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
   339	fi
   340	
   341	# ────────────────────────────────────────────────────────────────────────
   342	# Verdict + audit-row emission
   343	# ────────────────────────────────────────────────────────────────────────
   344	
   345	printf '\nScribe validate Gate A: '
   346	if [[ ${#FAILURES[@]} -gt 0 ]]; then
   347	  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
   348	  # Per-failure-class ESC routing (spec-002 §5): G1 → ESC_INPUT_VALIDATION_FAIL;
   349	  # G2 → ESC_FIELD_EXTRACTION_LOW_CONFIDENCE; G3 → ESC_VOICE_DRIFT;
   350	  # G4/G5 → ESC_SCHEMA_VIOLATION; G6 → ESC_PII_LEAKAGE_RISK (blocking);
   351	  # G7 → ESC_BULLHORN_AUTH (blocking); G8 → ESC_AGENT_OUTPUT_SHAPE.
   352	  # ESC_FIELD_EXTRACTION_LOW_CONFIDENCE carries the catalogue AGGREGATE-form
   353	  # payload fields (escalation-codes.md, amended 2026-06-10): entity_type,
   354	  # fields_extracted_count, confidence_floor, required_minimum, agent_name.
   355	  declare -a _esc_extra=()
   356	  if [[ "${ESC_CLASS:-}" == "ESC_FIELD_EXTRACTION_LOW_CONFIDENCE" ]]; then
   357	    _esc_extra+=("entity_type=${ENTITY_TYPE}" "fields_extracted_count=${_n_conf}" \
   358	      "confidence_floor=${FIELD_CONFIDENCE_THRESHOLD}" "required_minimum=${MIN_FIELDS_REQUIRED}" \
   359	      "agent_name=scribe")
   360	  fi
   361	  autosend_escalate "${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}" "agent=scribe" \
   362	    "tenant=${CTX_TENANT_SLUG}" "call=${CALL_ID}" \
   363	    "entity=${ENTITY_TYPE}:${BULLHORN_ID}" "failures=${#FAILURES[@]}" \
   364	    ${_esc_extra[@]+"${_esc_extra[@]}"}
   365	  _gate_hash="$(printf '%s' "${CALL_ID}|${ENTITY_TYPE}|${BULLHORN_ID}" | shasum -a 256 2>/dev/null | cut -c1-16)"
   366	  [[ -z "${_gate_hash}" ]] && _gate_hash="${CALL_ID}"
   367	  hh_decision_action "validate_gate_a_fail" "${ENTITY_TYPE}:${BULLHORN_ID}" "${_gate_hash}" \
   368	    "${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}; agent_name:scribe; call:${CALL_ID}; failures:${#FAILURES[@]}; first:${FAILURES[0]}" || true
   369	  exit 1
   370	fi
   371	printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
   372	exit 0

exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/cycle.sh | sed -n '430,560p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
   430	  confidence="0.95"   # exact email match against the cached entity (deterministic resolver)
   431	  hh_decision_output "entity_resolved" "${entity_type}:${bullhorn_id}" \
   432	    "call:${call_id}; confidence:${confidence}; match:email_exact"
   433	
   434	  # ── Step 5 — Field extraction (≥0.6 conf; per-entity Gate A minimum) ───
   435	  # Per-entity minimum (Codex R2-1): contact = 2 (its full Scribe-writable
   436	  # v0.3 set — decision_authority is R-only); all other entities = 3.
   437	  local min_required
   438	  case "${entity_type}" in
   439	    contact) min_required=2 ;;
   440	    *)       min_required=3 ;;
   441	  esac
   442	  local fields_file="${tmp_tx%.txt}-fields.json"
   443	  if ! bash "${_BIN}/extract-fields.sh" --transcript "${tmp_tx}" --entity-type "${entity_type}" \
   444	        --call-id "${call_id}" --vault-path "${vault_path_logical}" > "${fields_file}" 2>/dev/null; then
   445	    printf '[]\n' > "${fields_file}"
   446	  fi
   447	  chmod 0600 "${fields_file}" 2>/dev/null || true
   448	  local n_above
   449	  n_above="$(jq '[.[] | select(.confidence >= 0.6)] | length' "${fields_file}" 2>/dev/null || echo 0)"
   450	  hh_decision_output "fields_extracted" "${entity_type}:${bullhorn_id}" \
   451	    "call:${call_id}; fields_above_threshold:${n_above}; extractor:$( [[ "${IFOS_SCRIBE_USE_LLM:-0}" == "1" && -n "${ANTHROPIC_API_KEY:-}" ]] && echo llm_with_deterministic_fallback || echo deterministic ); ingest_mode:${ingest_mode}"
   452	  if [[ "${n_above}" -lt "${min_required}" ]]; then
   453	    # Catalogue AGGREGATE-form payload (escalation-codes.md, amended
   454	    # 2026-06-10): entity_type, fields_extracted_count, confidence_floor,
   455	    # required_minimum, agent_name.
   456	    autosend_escalate "ESC_FIELD_EXTRACTION_LOW_CONFIDENCE" "agent=scribe" \
   457	      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "entity_type=${entity_type}" \
   458	      "fields_extracted_count=${n_above}" "confidence_floor=0.6" \
   459	      "required_minimum=${min_required}" "agent_name=scribe"
   460	    hh_decision_action "validate_gate_a_fail" "${entity_type}:${bullhorn_id}" "lowconf-${call_id}" \
   461	      "ESC_FIELD_EXTRACTION_LOW_CONFIDENCE; agent_name:scribe; step:5; fields:${n_above}; required:${min_required}" || true
   462	    rm -f "${fields_file}" 2>/dev/null || true
   463	    return 1
   464	  fi
   465	  # Drop sub-threshold fields before Step 7 (agent.md §4 Step 5).
   466	  jq '[.[] | select(.confidence >= 0.6)]' "${fields_file}" > "${fields_file}.f" && mv "${fields_file}.f" "${fields_file}"
   467	
   468	  # ── Step 6 — Tacit-note generation → vault 0600 (canonical per ADR-002) ─
   469	  # Voice score resolution (HONEST — never faked):
   470	  #   IFOS_FORCE_VOICE_SCORE  → numeric (fixture/test hook + future classifier wire-in)
   471	  #   active voice_corpus     → unscored/no_classifier (corpus exists; the
   472	  #                             classifier microservice is W4-5 polish, not built)
   473	  #   no corpus               → unscored/no_corpus (CC precedent)
   474	  # The 3-retry loop of agent.md §4 Step 6 only makes sense for a
   475	  # non-deterministic (LLM) generator; the deterministic renderer emits one
   476	  # canonical rendering, so retries:0 is recorded.
   477	  local voice_score voice_reason needs_review="" retries=0
   478	  if [[ -n "${IFOS_FORCE_VOICE_SCORE:-}" ]]; then
   479	    voice_score="${IFOS_FORCE_VOICE_SCORE}"
   480	    voice_reason="forced_test_score"
   481	    retries="${IFOS_FORCE_VOICE_RETRIES:-0}"
   482	    if awk -v s="${voice_score}" 'BEGIN{exit !(s < 0.75)}'; then
   483	      needs_review="--needs-review"
   484	    fi
   485	  elif [[ "${CTX_VOICE_CORPUS_ID}" != "none" ]]; then
   486	    voice_score="unscored"; voice_reason="no_classifier"
   487	  else
   488	    voice_score="unscored"; voice_reason="no_corpus"
   489	  fi
   490	
   491	  mkdir -p "${vault_dir_phys}" 2>/dev/null || true
   492	  chmod 0700 "${vault_dir_phys}" 2>/dev/null || true
   493	  local render_args=(--call-id "${call_id}" --date "${today}" --transcript "${tmp_tx}"
   494	    --participants "${attendees}" --duration-min "${duration}"
   495	    --voice-score "${voice_score}" --voice-reason "${voice_reason}")
   496	  [[ -n "${title}" ]] && render_args+=(--context "${title}")
   497	  [[ -n "${needs_review}" ]] && render_args+=("${needs_review}")
   498	  if ! bash "${_BIN}/render-tacit-note.sh" "${render_args[@]}" > "${note_file_phys}.tmp" 2>/dev/null; then
   499	    rm -f "${note_file_phys}.tmp" 2>/dev/null || true
   500	    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=scribe" \
   501	      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "reason=tacit_note_render_failed"
   502	    return 1
   503	  fi
   504	  mv "${note_file_phys}.tmp" "${note_file_phys}"
   505	  chmod 0600 "${note_file_phys}" 2>/dev/null || true
   506	  local body_sha words
   507	  body_sha="$(shasum -a 256 "${note_file_phys}" 2>/dev/null | cut -c1-16)"
   508	  [[ -z "${body_sha}" ]] && body_sha="na"
   509	  words="$(wc -w < "${note_file_phys}" | tr -d ' ')"
   510	  # ADR-002: metadata ONLY — {vault_path, body_sha256, voice_score}; body NEVER in payload.
   511	  hh_decision_output "tacit_note_rendered" "${vault_path_logical}" \
   512	    "vault_path:${vault_path_logical}; body_sha256:${body_sha}; voice_score:${voice_score}; voice_reason:${voice_reason}; words:${words}; retries:${retries}"
   513	
   514	  # ── Step 7 — Schema validation (names + types/ranges) + Gate A ────────
   515	  local vres valid_count dropped_count
   516	  vres="$(bash "${_BIN}/validate-fields.sh" --entity-type "${entity_type}" --fields-file "${fields_file}" 2>/dev/null || echo '{"valid":[],"dropped":[],"valid_count":0}')"
   517	  valid_count="$(jq -r '.valid_count' <<<"${vres}")"
   518	  dropped_count="$(jq -r '.dropped | length' <<<"${vres}")"
   519	  if [[ "${valid_count}" -lt "${min_required}" ]]; then
   520	    autosend_escalate "ESC_SCHEMA_VIOLATION" "agent=scribe" \
   521	      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "valid=${valid_count}" "dropped=${dropped_count}" \
   522	      "required_minimum=${min_required}"
   523	    hh_decision_action "validate_gate_a_fail" "${entity_type}:${bullhorn_id}" "schema-${call_id}" \
   524	      "ESC_SCHEMA_VIOLATION; agent_name:scribe; step:7; valid:${valid_count}; dropped:${dropped_count}; required:${min_required}" || true
   525	    rm -f "${fields_file}" 2>/dev/null || true
   526	    return 1
   527	  fi
   528	  hh_decision_output "fields_validated" "${entity_type}:${bullhorn_id}" \
   529	    "call:${call_id}; valid:${valid_count} of $(jq 'length' "${fields_file}") extracted; dropped:${dropped_count}"
   530	
   531	  # Build the Gate A proposal + run validate.sh (hard gate between Step 7 and 8).
   532	  # narrative_body_preview (first 500 chars) is the AUDIT ROW artefact only —
   533	  # validate.sh G6 scans the FULL physical body it resolves from
   534	  # tacit_note.vault_path (review F1 fix; Step 9 exports the full body).
   535	  local proposal="${tmp_tx%.txt}-proposal.json" preview
   536	  preview="$(sed -n '/^---$/,/^---$/!p' "${note_file_phys}" | head -c 500 | tr '\n' ' ')"
   537	  jq -nc --arg call_id "${call_id}" --arg et "${entity_type}" --arg bid "${bullhorn_id}" \
   538	     --arg sig "${WEBHOOK_SIG_STATE}" --argjson fields "$(jq -c '.valid' <<<"${vres}")" \
   539	     --arg vp "${vault_path_logical}" --arg sha "${body_sha}" --arg vs "${voice_score}" \
   540	     --arg vr "${voice_reason}" --argjson words "${words}" --arg pv "${preview}" '{
   541	       call_id: $call_id, entity_type: $et, bullhorn_id: $bid,
   542	       webhook_sig_state: $sig, fields_extracted: $fields,
   543	       tacit_note: { vault_path: $vp, body_sha256: $sha, voice_score: $vs,
   544	                     voice_reason: $vr, narrative_word_count: $words,
   545	                     narrative_body_preview: $pv } }' > "${proposal}"
   546	  chmod 0600 "${proposal}" 2>/dev/null || true
   547	
   548	  local _validate="${CTX_AGENT_DIR}/validate.sh"
   549	  [[ -f "${_validate}" ]] || _validate="${IFOS_REPO_ROOT:-}/agents/recruitment/scribe/validate.sh"
   550	  if ! bash "${_validate}" "${proposal}" >/dev/null 2>&1; then
   551	    # validate.sh already emitted the ESC + validate_gate_a_fail rows.
   552	    # Transcript stays in /tmp (auto-purged 24h by cleanup.sh); vault note is
   553	    # flagged needs_consultant_review by Step 6 when the voice path failed.
   554	    rm -f "${fields_file}" "${proposal}" 2>/dev/null || true
   555	    return 1
   556	  fi
   557	
   558	  if [[ "${MODE}" == "dry-run" ]]; then
   559	    hh_decision_output "dry_run_writes_skipped" "call:${call_id}" \
   560	      "would_write_field_count:${valid_count}; would_attach_note:true"

exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/tools.yaml | sed -n '1,150p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
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

exec
/bin/zsh -lc 'rg -n "confidence|voice_score|tacit" agents/recruitment/scribe/fixtures/*.yaml agents/recruitment/scribe/bin/render-tacit-note.sh' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
agents/recruitment/scribe/fixtures/01-primary.yaml:7:#   inference resolves to a Candidate entity with confidence 0.92 →
agents/recruitment/scribe/fixtures/01-primary.yaml:8:#   Step 5 LLM extraction yields 4 fields all ≥0.6 confidence (passes
agents/recruitment/scribe/fixtures/01-primary.yaml:10:#   tacit-note written → Step 7 validate.sh G1-G7 all pass → Step 8
agents/recruitment/scribe/fixtures/01-primary.yaml:12:#   → Step 9 createNote attaches the vault tacit-note (yellow tier
agents/recruitment/scribe/fixtures/01-primary.yaml:92:      match_confidence: 0.92
agents/recruitment/scribe/fixtures/01-primary.yaml:96:  - { field_name: "location",                 value: "Manchester, UK",        confidence: 0.91 }
agents/recruitment/scribe/fixtures/01-primary.yaml:97:  - { field_name: "current_role",             value: "Senior Backend Engineer", confidence: 0.94 }
agents/recruitment/scribe/fixtures/01-primary.yaml:98:  - { field_name: "notice_period_weeks",      value: 8,                       confidence: 0.88 }
agents/recruitment/scribe/fixtures/01-primary.yaml:99:  - { field_name: "salary_expectation_min",   value: 85000,                   confidence: 0.82 }
agents/recruitment/scribe/fixtures/01-primary.yaml:100:  - { field_name: "salary_expectation_max",   value: 95000,                   confidence: 0.82 }
agents/recruitment/scribe/fixtures/01-primary.yaml:101:  # confidence threshold 0.6; 5 ≥0.6 → passes Gate A G2 (≥3 required)
agents/recruitment/scribe/fixtures/01-primary.yaml:103:# Mocked tacit-note voice classifier (Step 6)
agents/recruitment/scribe/fixtures/01-primary.yaml:104:mocked_tacit_note:
agents/recruitment/scribe/fixtures/01-primary.yaml:107:  voice_score: 0.82            # passes Gate A G3 (≥0.75 required)
agents/recruitment/scribe/fixtures/01-primary.yaml:119:    confidence: 0.92
agents/recruitment/scribe/fixtures/01-primary.yaml:124:    voice_score: 0.82
agents/recruitment/scribe/fixtures/01-primary.yaml:159:      output_type: tacit_note_rendered        # payload: {vault_path, body_sha256, voice_score} only (ADR-002)
agents/recruitment/scribe/bin/render-tacit-note.sh:2:# Scribe — Step 6 tacit-note renderer (agent.md §3 Output 2 + 8-category taxonomy).
agents/recruitment/scribe/bin/render-tacit-note.sh:4:# Prints ONE tacit-note markdown document (YAML frontmatter + body) to stdout.
agents/recruitment/scribe/bin/render-tacit-note.sh:8:# emits METADATA only ({vault_path, body_sha256, voice_score}) to decision_log
agents/recruitment/scribe/bin/render-tacit-note.sh:24:#   render-tacit-note.sh --call-id ID --date YYYY-MM-DD --transcript <path> \
agents/recruitment/scribe/bin/render-tacit-note.sh:43:    *) printf 'render-tacit-note.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
agents/recruitment/scribe/bin/render-tacit-note.sh:47:  printf 'render-tacit-note.sh: --call-id, --date and --transcript <existing file> required\n' >&2
agents/recruitment/scribe/bin/render-tacit-note.sh:109:# tacit_note.vault_path — not just a preview (that is outside-boundary PII;
agents/recruitment/scribe/bin/render-tacit-note.sh:142:voice_score: ${VOICE_SCORE}
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:92:      match_confidence: 0.88
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:94:# Field extraction runs against notes_markdown (degraded source; lower confidence)
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:96:  - { field_name: "location",                 value: "London, UK",                  confidence: 0.78 }
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:97:  - { field_name: "current_role",             value: "Senior Frontend Engineer",   confidence: 0.83 }
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:98:  - { field_name: "notice_period_weeks",      value: 4,                            confidence: 0.85 }
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:99:  - { field_name: "salary_expectation_min",   value: 70000,                        confidence: 0.71 }
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:100:  - { field_name: "salary_expectation_max",   value: 80000,                        confidence: 0.71 }
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:101:  # 5 ≥0.6 → passes Gate A G2; confidences lower than transcript-based extraction
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:103:mocked_tacit_note:
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:106:  voice_score: 0.78             # passes Gate A G3 (still ≥0.75)
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:123:    voice_score: 0.78
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:171:      output_type: tacit_note_rendered
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:185:  confidence; relies on Granola's notes_markdown). v0.4 supplement does NOT
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:4:# agent.md §3 line 111. When the tacit-note narrative voice score is <0.75
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:7:# The vault tacit-note artefact IS written (so the operator can see what
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:90:      match_confidence: 0.95
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:98:  - { field_name: "placement_status",       value: "active",          confidence: 0.92 }
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:99:  - { field_name: "satisfaction_signal",    value: "positive",        confidence: 0.85 }
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:100:  - { field_name: "week_1_status_vault_path", value: "/vault/migration-test/scribe-notes/meeting-099-2026-06-03.md", confidence: 0.95 }
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:103:mocked_tacit_note:
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:106:  voice_score_attempts:
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:110:  voice_score_final: 0.61      # max of attempts; FAILS G3
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:146:        voice_score_attempts: [0.62, 0.58, 0.61]
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:166:      output_type: tacit_note_rendered
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:167:      payload_contains: "voice_score:0.61"   # vault frontmatter carries needs_consultant_review: true

codex
The policy and schema checks mostly line up: the Scribe action types are registered and the field additions are present. One remaining cross-check is the “all green under build-gate” status claim and whether the production-ready sibling checks actually pass in this worktree.
exec
/bin/zsh -lc 'test -x scripts/build-gate.sh && printf yes || printf no' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
yes
exec
/bin/zsh -lc 'rg -n "Scribe|scribe" scripts/build-gate.sh Makefile package.json agents/recruitment/scribe/README.md docs/features/agent-build/04-reviews/review-scribe.md docs/features/agent-build/02-specs/spec-002-scribe.md' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 exited 2 in 0ms:
rg: Makefile: No such file or directory (os error 2)
rg: package.json: No such file or directory (os error 2)
agents/recruitment/scribe/README.md:1:# Scribe — directory README
agents/recruitment/scribe/README.md:22:| `fixtures/01-primary.yaml` | golden case (exercised by `scripts/run-scribe-extraction-test.sh`) |
agents/recruitment/scribe/README.md:28:- `scripts/run-scribe-extraction-test.sh`
agents/recruitment/scribe/README.md:29:- `scripts/run-scribe-gate-a-test.sh`
agents/recruitment/scribe/README.md:30:- `scripts/run-scribe-sla-test.sh`
agents/recruitment/scribe/README.md:34:`docs/features/agent-build/03-implementation/scribe-summary.md`
agents/recruitment/scribe/README.md:40:*End of Scribe README.*
docs/features/agent-build/04-reviews/review-scribe.md:1:# Review — Scribe (spec-002) — Round 1
docs/features/agent-build/04-reviews/review-scribe.md:15:- **F9/F10 ADVISORY** — SLA anchored to call end (catalogue-consistent, stricter); webhook-401 path exits before `scribe_run_complete` (defensible).
docs/features/agent-build/04-reviews/review-scribe.md:27:- `check-auth` (exists, network-free) — Scribe shim MUST use it to map not-provisioned → `unavailable` (no ESC) vs real refresh failure → `failed` (ESC_BULLHORN_AUTH).
docs/features/agent-build/04-reviews/review-scribe.md:29:- `create-note` extended: `--person-id <N> | (--entity-type <T> --entity-id <N>)` + `--body-file <path>` + optional `--title` → `{ok, note_id}`; if Bullhorn cannot attach notes to a given entity type, the CLI returns an explicit `{ok:false, reason:"unsupported_entity"}` and Scribe falls back to person-resolution (documented, honest).
docs/features/agent-build/04-reviews/review-scribe.md:37:Fix pass on the Scribe branch (F1/F2/F4-F8 + Codex 1-4 + shim reconciliation to the agreed contract) + Janitor fix pass extends the CLI per the contract. Then targeted re-review of F1/F2 + Codex round 2 on both.
docs/features/agent-build/02-specs/spec-002-scribe.md:1:# Spec 002 — Scribe build
docs/features/agent-build/02-specs/spec-002-scribe.md:3:**A sub-agent given ONLY this file + `agents/recruitment/scribe/agent.md` + the Cash Conductor
docs/features/agent-build/02-specs/spec-002-scribe.md:4:template + CLAUDE.md has everything it needs to build Scribe autonomously.**
docs/features/agent-build/02-specs/spec-002-scribe.md:6:- **Agent dir:** `agents/recruitment/scribe/` (cycle.sh 10-step + validate.sh + dual context.sh + cleanup.sh + tools.yaml + 3 fixtures — SKELETON, ~13 TODO markers)
docs/features/agent-build/02-specs/spec-002-scribe.md:7:- **Master-plan source (READ IN FULL):** `agents/recruitment/scribe/agent.md`
docs/features/agent-build/02-specs/spec-002-scribe.md:9:- **Wave/tier:** v1.0 W6; Tier 1 webhook-driven. **Scribe is the data spine (agent.md §1).**
docs/features/agent-build/02-specs/spec-002-scribe.md:10:- **⚠ TRANSCRIPT VENDOR = GRANOLA (`@ifos/granola`).** The agent.md §4 Step 3 text still names Fathom/Fireflies — that is PRE-PIVOT and WRONG. The W5 Day-29 vendor pivot moved Scribe's transcript source to **Granola**. Build every transcript-fetch path against `@ifos/granola`. Do NOT implement Fathom or Fireflies. (See §2, §4 Step 3, §8.)
docs/features/agent-build/02-specs/spec-002-scribe.md:19:- **autosend-policy action_types (registered, yellow):** `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`; + green `validate_gate_a_fail`, `scribe_run_complete`. Verify via grep.
docs/features/agent-build/02-specs/spec-002-scribe.md:22:- **Voice:** `hh_load_tone_rules` (∋ scribe) + `hh_load_voice_samples`.
docs/features/agent-build/02-specs/spec-002-scribe.md:25:- decision_log markers: `webhook_verified`, `bullhorn_auth_refreshed`, `transcript_fetched`, `entity_resolved`, `fields_extracted`, `tacit_note_rendered` (output, `{vault_path,body_sha256,voice_score}` — body NOT in payload per ADR-002), `fields_validated`, + action rows `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`, `scribe_run_complete`.
docs/features/agent-build/02-specs/spec-002-scribe.md:39:| 8 | Bullhorn field write (PATCH, yellow, atomic) | `bullhorn_scribe_field_write` | `ESC_BULLHORN_WRITE_FAIL` (no Step 9) | CC Step 6 write-back |
docs/features/agent-build/02-specs/spec-002-scribe.md:41:| 10 | Session close + SLA metric (elapsed since webhook) | `scribe_run_complete` | `ESC_SCRIBE_SLA_MISS` (>30min render / >1h attach) | CC Step 14 |
docs/features/agent-build/02-specs/spec-002-scribe.md:59:- `scripts/run-scribe-extraction-test.sh` — seeded transcript + entity → assert field extraction (≥3 ≥0.6), schema validation (name+type/range), drop-invalid, and the <3-valid Gate A fail.
docs/features/agent-build/02-specs/spec-002-scribe.md:60:- `scripts/run-scribe-gate-a-test.sh` — PASS + each fail class (webhook-sig, field-count, voice, schema, PII) + ESC routes (register tenant first; decision_log FK).
docs/features/agent-build/02-specs/spec-002-scribe.md:61:- `scripts/run-scribe-sla-test.sh` — elapsed-time → SLA bucket logic (5/10/30min/1h thresholds + Gate B 10-min miss).
docs/features/agent-build/02-specs/spec-002-scribe.md:71:- Can run in parallel with: Janitor, Sourcing Scout (disjoint files). Spawn after Janitor proves the build machine + the `@ifos/bullhorn` CLI-bridge pattern (which Scribe reuses).

exec
/bin/zsh -lc 'shellcheck --version >/dev/null 2>&1 && printf yes || printf no' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
yes
codex
I found a stale contradiction in the build spec and tools comments, but the ratification target is the Scribe `agent.md` bundle contract. I’m running the local gate now because the document’s status hinges on that “all green” claim.
exec
/bin/zsh -lc scripts/build-gate.sh in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 11112ms:

[1;34m── 1. shellcheck (agent bundles + bin + fixture tests) ──[0m
  [1;32m✓[0m shellcheck CLEAN (43 files)

[1;34m── 2+3. connector typecheck + vitest ──[0m
  [1;32m✓[0m xero: typecheck + vitest green
  [1;32m✓[0m quickbooks: typecheck + vitest green
  [1;32m✓[0m open-banking: typecheck + vitest green
  [1;32m✓[0m companies-house: typecheck + vitest green

[1;34m── 4. fixture suites (DB-backed) ──[0m
  [1;33m![0m no reachable IFOS_DB_URL — DB-backed fixture suites SKIPPED (run on a machine with the dev DB)

[1;32mBUILD GATE: PASS[0m

codex
The build gate passes overall, but it explicitly skips the DB-backed fixture suites when no `IFOS_DB_URL` is reachable. That makes the agent.md’s “DB-backed suites all green” claim unverifiable in this worktree and likely not honest enough for ratification.
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/context.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Scribe agent — context.sh (pre-cycle hydration; W6 build slice LIVE)
     3	#
     4	# Status: built (W6 build slice; replaces the W5 Day-32 skeleton stubs with
     5	#         live tenant_adapters reads + bridge-backed token state). v0.4
     6	#         schema supplement LANDED 2026-06-03 (commit a1bbcf6 + LIVE on VPS):
     7	#         bullhorn_corporation_id + granola_workspace_id are top-level
     8	#         allowlisted keys — Steps 1+2 below read the canonical SELECT path,
     9	#         with IFOS_FORCE_* env fallbacks retained for fixtures + local dev.
    10	# Reading order: agent.md §2 (invocation surface) + §4 Step 0 (session start) +
    11	#         §7 (voice + tone constraints) first.
    12	#
    13	# Per ADR-003 v2 agent-bundle pattern: bus invokes context.sh BEFORE cycle.sh
    14	# at session start. context.sh hydrates session-scoped CTX_* env vars that
    15	# cycle.sh + validate.sh read, then emits the mandatory session_start trigger
    16	# row to anchor the session in decision_log.
    17	#
    18	# Invocation contract:
    19	#   bash context.sh
    20	#
    21	# Inputs (env from bus):
    22	#   CTX_AGENT_DIR    — agent's directory (this file's dirname)
    23	#   CTX_TENANT_SLUG  — tenant the run targets
    24	#
    25	# Honest-scope (spec-002 §8): Bullhorn dev creds are EMPTY and the Granola
    26	# IFOS-side OAuth token is NOT on disk (the Claude-Code MCP keychain token is
    27	# NOT what @ifos/granola reads — it expects
    28	# ~/.ifos-local-vault/<tenant>/granola-tokens-<workspace_id>.json). Token
    29	# states below therefore resolve honestly to "unavailable"/"no_token" until
    30	# the founder provisions creds; they are NEVER faked. Fixture suites use
    31	# BH_BRIDGE_TEST_MODE (see bin/bh-bridge.sh) to prove the green path.
    32	#
    33	# Outputs (exported CTX_* vars; cycle.sh + validate.sh consume):
    34	#   CTX_AGENT_NAME                — "scribe"
    35	#   CTX_BULLHORN_CORPORATION_ID  — per-tenant Bullhorn corp identifier
    36	#   CTX_GRANOLA_WORKSPACE_ID     — per-tenant Granola workspace identifier
    37	#   CTX_GRANOLA_PLAN_TIER        — "paid" assumed (founder 2026-06-03)
    38	#   CTX_BULLHORN_TOKEN_STATE     — fresh|refreshed|failed|unavailable
    39	#   CTX_GRANOLA_TOKEN_STATE      — fresh|no_token|unavailable
    40	#   CTX_VOICE_CORPUS_ID          — active voice_corpus id OR "none"
    41	#   CTX_TONE_RULES_COUNT         — number of scribe-applicable tone_rule rows
    42	#   CTX_FIRM_DOMAIN_WHITELIST    — comma-separated firm domains (G-PII check)
    43	#   CTX_GRANOLA_LAST_POLL        — ISO timestamp of last poll-sweep
    44	
    45	set -euo pipefail
    46	
    47	# ────────────────────────────────────────────────────────────────────────
    48	# Pre-flight: CTX env + _shared/ helper resolution
    49	# ────────────────────────────────────────────────────────────────────────
    50	
    51	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    52	  printf 'scribe/context.sh: CTX_AGENT_DIR unset (bus must set this)\n' >&2
    53	  exit 2
    54	fi
    55	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    56	  printf 'scribe/context.sh: CTX_TENANT_SLUG unset\n' >&2
    57	  exit 2
    58	fi
    59	export CTX_AGENT_NAME="scribe"
    60	
    61	# 4-candidate _shared/ helper fallback (matches sibling agents post commit d7d52c5).
    62	_SHARED_DIR=""
    63	for _candidate in \
    64	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    65	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    66	  "${CTX_AGENT_DIR}/../../_shared" \
    67	  "${CTX_AGENT_DIR}/../_shared" ; do
    68	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    69	    _SHARED_DIR="${_candidate}"
    70	    break
    71	  fi
    72	done
    73	if [[ -z "${_SHARED_DIR}" ]]; then
    74	  printf 'context.sh: cannot locate _shared/ helpers\n' >&2
    75	  exit 1
    76	fi
    77	# shellcheck source=/dev/null
    78	source "${_SHARED_DIR}/hook-helpers.sh"
    79	
    80	# RLS-scoped single-value tenant_adapters read; empty string on any failure.
    81	_ctx_adapter_key() {  # <adapter_name> <config_key>
    82	  if [[ -z "${IFOS_DB_URL:-}" ]] || ! command -v psql >/dev/null 2>&1; then
    83	    echo ""; return 0
    84	  fi
    85	  psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
    86	    --set=tenant="${CTX_TENANT_SLUG}" --set=an="$1" --set=k="$2" <<'SQL' 2>/dev/null | head -1 || true
    87	BEGIN;
    88	SET LOCAL app.current_tenant = :'tenant';
    89	SELECT coalesce(config->>:'k','') FROM tenant_adapters
    90	WHERE tenant_slug = :'tenant' AND adapter_name = :'an' LIMIT 1;
    91	COMMIT;
    92	SQL
    93	}
    94	
    95	# ────────────────────────────────────────────────────────────────────────
    96	# Step 1 — Bullhorn corporation_id resolution (v0.4 allowlisted key; LIVE)
    97	# Canonical: SELECT config->>'bullhorn_corporation_id' FROM tenant_adapters
    98	# WHERE adapter_name='bullhorn'. IFOS_FORCE_* fallback kept for fixtures.
    99	# ────────────────────────────────────────────────────────────────────────
   100	
   101	_corp="${IFOS_FORCE_BULLHORN_CORPORATION_ID:-}"
   102	[[ -z "${_corp}" ]] && _corp="$(_ctx_adapter_key bullhorn bullhorn_corporation_id)"
   103	export CTX_BULLHORN_CORPORATION_ID="${_corp:-unset}"
   104	
   105	# ────────────────────────────────────────────────────────────────────────
   106	# Step 2 — Granola workspace_id resolution (v0.4 allowlisted key; LIVE)
   107	# ────────────────────────────────────────────────────────────────────────
   108	
   109	_ws="${IFOS_FORCE_GRANOLA_WORKSPACE_ID:-}"
   110	[[ -z "${_ws}" ]] && _ws="$(_ctx_adapter_key granola granola_workspace_id)"
   111	export CTX_GRANOLA_WORKSPACE_ID="${_ws:-unset}"
   112	
   113	# ────────────────────────────────────────────────────────────────────────
   114	# Step 3 — Granola plan_tier pre-cache
   115	# Per @ifos/granola README §"Scribe consumption pattern": getAccountInfo()
   116	# pre-cache (1h TTL) short-circuits the PAID_PLAN_TOOLS guard. Live call is
   117	# blocked until the IFOS-side OAuth token exists on disk (honest-scope above),
   118	# so v1.0 resolves: forced override → 'paid' default (founder 2026-06-03
   119	# confirmed Business+). If first live getAccountInfo returns 'free', cycle.sh
   120	# degrades to notes-only ingest (ESC_GRANOLA_PLAN_TIER is QUEUED for catalogue
   121	# registration; until then the degradation is recorded on the audit row).
   122	# ────────────────────────────────────────────────────────────────────────
   123	
   124	export CTX_GRANOLA_PLAN_TIER="${IFOS_FORCE_GRANOLA_PLAN_TIER:-paid}"
   125	
   126	# ────────────────────────────────────────────────────────────────────────
   127	# Step 4 — Bullhorn OAuth refresh (via bin/bh-bridge.sh — the single
   128	# reconciliation point for Janitor's @ifos/bullhorn CLI bridge)
   129	# ESC_BULLHORN_AUTH firing is owned by cycle.sh Step 2 (which retries);
   130	# context.sh only records the starting token state.
   131	# ────────────────────────────────────────────────────────────────────────
   132	
   133	_bh_state="unavailable"
   134	_bh_rc=0
   135	_bh_out="$(bash "${CTX_AGENT_DIR}/bin/bh-bridge.sh" refresh 2>/dev/null)" || _bh_rc=$?
   136	case "${_bh_rc}" in
   137	  0) _bh_state="$(printf '%s' "${_bh_out}" | jq -r '.token_state // "refreshed"' 2>/dev/null || echo refreshed)" ;;
   138	  3) _bh_state="unavailable" ;;   # bridge not built yet / creds not provisioned
   139	  *) _bh_state="failed" ;;
   140	esac
   141	export CTX_BULLHORN_TOKEN_STATE="${_bh_state}"
   142	
   143	# ────────────────────────────────────────────────────────────────────────
   144	# Step 5 — Granola token state (OAuth 2.1 + PKCE per @ifos/granola src/auth.ts)
   145	# The connector reads ~/.ifos-local-vault/<tenant>/granola-tokens-<workspace>.json.
   146	# No token file on disk → state 'no_token' (honest; live fetch paths then rely
   147	# on fixture/seeded transcript sources only).
   148	# ────────────────────────────────────────────────────────────────────────
   149	
   150	_gr_token_file="${IFOS_LOCAL_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/granola-tokens-${CTX_GRANOLA_WORKSPACE_ID}.json"
   151	if [[ -f "${_gr_token_file}" ]]; then
   152	  export CTX_GRANOLA_TOKEN_STATE="fresh"
   153	else
   154	  export CTX_GRANOLA_TOKEN_STATE="no_token"
   155	fi
   156	
   157	# ────────────────────────────────────────────────────────────────────────
   158	# Step 6 — Voice corpus + tone rules (agent.md §7)
   159	# voice_corpus: active row for tenant (empty → 'none' → Step 6 voice scoring
   160	# records unscored/no_corpus, never a faked score).
   161	# tone rules: hh_load_tone_rules('scribe') count via _shared/voice-loader.sh.
   162	# ────────────────────────────────────────────────────────────────────────
   163	
   164	_vc_id="${IFOS_FORCE_VOICE_CORPUS_ID:-}"
   165	if [[ -z "${_vc_id}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   166	  _vc_id="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1 || true
   167	BEGIN;
   168	SET LOCAL app.current_tenant = :'tenant';
   169	SELECT id::text FROM voice_corpus WHERE tenant_slug = :'tenant' AND is_active = true LIMIT 1;
   170	COMMIT;
   171	SQL
   172	)"
   173	fi
   174	export CTX_VOICE_CORPUS_ID="${_vc_id:-none}"
   175	
   176	_tr_count="0"
   177	if [[ -f "${_SHARED_DIR}/voice-loader.sh" ]]; then
   178	  # shellcheck source=/dev/null
   179	  source "${_SHARED_DIR}/voice-loader.sh"
   180	  if declare -f hh_load_tone_rules >/dev/null 2>&1; then
   181	    _tr_json="$(hh_load_tone_rules "scribe" 2>/dev/null || echo '{"rules":[]}')"
   182	    _tr_count="$(printf '%s' "${_tr_json}" | jq -r '.rules | length' 2>/dev/null || echo 0)"
   183	  fi
   184	fi
   185	export CTX_TONE_RULES_COUNT="${_tr_count:-0}"
   186	
   187	# ────────────────────────────────────────────────────────────────────────
   188	# Step 7 — Firm-domain whitelist (for validate.sh G-PII regex pass)
   189	# 'firm_domains' is NOT a v0.4 tenant_adapters allowlist key (16-key trigger,
   190	# verified 2026-06-10), so a canonical SELECT would be rejected at write time
   191	# anyway. v1.0 keeps the env override + tenant-slug heuristic; promoting the
   192	# key is a v0.5-supplement item (noted in build summary).
   193	# ────────────────────────────────────────────────────────────────────────
   194	
   195	export CTX_FIRM_DOMAIN_WHITELIST="${IFOS_FORCE_FIRM_DOMAIN_WHITELIST:-${CTX_TENANT_SLUG}.test}"
   196	
   197	# ────────────────────────────────────────────────────────────────────────
   198	# Step 8 — Granola last_poll resolution (Scribe-internal cache file; NOT a
   199	# tenant_adapters key). cleanup.sh writes it at session close.
   200	# ────────────────────────────────────────────────────────────────────────
   201	
   202	_lp_file="${HOME}/.ifos-cache/scribe/${CTX_TENANT_SLUG}/last-poll-${CTX_GRANOLA_WORKSPACE_ID}.txt"
   203	_lp="${IFOS_FORCE_GRANOLA_LAST_POLL:-}"
   204	if [[ -z "${_lp}" && -f "${_lp_file}" ]]; then
   205	  _lp="$(head -1 "${_lp_file}" 2>/dev/null | tr -d '[:space:]')"
   206	fi
   207	if [[ -z "${_lp}" ]]; then
   208	  # Default to 5-min-ago (cron cadence; safe overlap — listMeetings is
   209	  # idempotent and Step 4 dedups by meeting_id).
   210	  _lp="$(date -u -v-5M +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u --date='5 minutes ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo '1970-01-01T00:00:00Z')"
   211	fi
   212	export CTX_GRANOLA_LAST_POLL="${_lp}"
   213	
   214	# ────────────────────────────────────────────────────────────────────────
   215	# Step 9 — Session-start trigger row (mandatory; anchors session in decision_log)
   216	# ────────────────────────────────────────────────────────────────────────
   217	
   218	hh_decision_trigger "session_start" \
   219	  "agent:scribe; tenant:${CTX_TENANT_SLUG}; corp:${CTX_BULLHORN_CORPORATION_ID}; workspace:${CTX_GRANOLA_WORKSPACE_ID}; plan_tier:${CTX_GRANOLA_PLAN_TIER}; voice_corpus:${CTX_VOICE_CORPUS_ID}; last_poll:${CTX_GRANOLA_LAST_POLL}"
   220	

exec
/bin/zsh -lc 'rg -n "hh_load_voice_samples|hh_load_tone_rules|hh_load_recent_edits|top" agents/recruitment/scribe/context.sh agents/recruitment/scribe/agent.md' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
agents/recruitment/scribe/agent.md:399:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:403:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:404:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/context.sh:7:#         bullhorn_corporation_id + granola_workspace_id are top-level
agents/recruitment/scribe/context.sh:161:# tone rules: hh_load_tone_rules('scribe') count via _shared/voice-loader.sh.
agents/recruitment/scribe/context.sh:180:  if declare -f hh_load_tone_rules >/dev/null 2>&1; then
agents/recruitment/scribe/context.sh:181:    _tr_json="$(hh_load_tone_rules "scribe" 2>/dev/null || echo '{"rules":[]}')"

exec
/bin/zsh -lc 'rg -n "IFOS_DB_URL|run-scribe|DB-backed|fixture" scripts agents/recruitment/scribe -S' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
scripts/run-gate-a-test.sh:2:# Cash Conductor — Gate A (validate.sh) fixture test (P4c).
scripts/run-gate-a-test.sh:8:# validate.sh opens its OWN DB connection, so fixtures are COMMITTED then cleaned
scripts/run-gate-a-test.sh:19:readonly TENANT="gate-a-fixture-test"
scripts/run-gate-a-test.sh:20:IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
scripts/run-gate-a-test.sh:21:export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}" IFOS_VAULT_ROOT="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}"
scripts/run-gate-a-test.sh:35:appq() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}"; }
scripts/run-gate-a-test.sh:52:printf '\033[1;34m── Gate A (validate.sh) fixture test ──\033[0m\n'
scripts/run-gate-a-test.sh:56:INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Gate A fixture test')
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:1:# Scribe fixture — 02-edge-case-paid-only
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:5:# at fixture load), Scribe's cycle.sh Step 3 (getTranscript) MUST NOT hit
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:14:# This fixture covers the upper happy case (notes_markdown is rich enough
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:19:# fixture only exercises get_meeting_transcript blocking.
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:30:fixture_id: 02-edge-case-paid-only
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:50:# Force Free tier in this fixture's account info (context.sh pre-cache resolves
agents/recruitment/scribe/fixtures/01-primary.yaml:1:# Scribe fixture — 01-primary (happy path)
agents/recruitment/scribe/fixtures/01-primary.yaml:23:#         scripts/run-scribe-extraction-test.sh (BH_BRIDGE_TEST_MODE=ok —
agents/recruitment/scribe/fixtures/01-primary.yaml:26:fixture_id: 01-primary
agents/recruitment/scribe/bin/bh-bridge.sh:66:# Test hook (fixture suites ONLY; mirrors agents/_shared HH_AWAIT_TEST_MODE
agents/recruitment/scribe/bin/bh-bridge.sh:68:# fixtures prove cycle.sh logic without the live bridge:
agents/recruitment/scribe/bin/bh-bridge.sh:108:# ── Test-mode short-circuit (fixture suites; never set in production) ─────
scripts/run-scribe-sla-test.sh:2:# Scribe — SLA bucket + ESC_SCRIBE_SLA_MISS fixture test (spec-002 §7).
scripts/run-scribe-sla-test.sh:10:# Part 2 (DB-backed integration): cycle.sh replay with seeded meetings whose
scripts/run-scribe-sla-test.sh:13:# and that scribe_run_complete records the sla_class. CC fixture pattern:
scripts/run-scribe-sla-test.sh:20:readonly TENANT="scribe-sla-fixture"
scripts/run-scribe-sla-test.sh:21:IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
scripts/run-scribe-sla-test.sh:22:export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}"
scripts/run-scribe-sla-test.sh:38:appq() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}"; }
scripts/run-scribe-sla-test.sh:54:printf '\033[1;34m── Scribe SLA bucket fixture test ──\033[0m\n'
scripts/run-scribe-sla-test.sh:80:# ── Part 2: DB-backed integration through cycle.sh ─────────────────────────
scripts/run-scribe-sla-test.sh:82:INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Scribe SLA fixture')
agents/recruitment/scribe/cycle.sh:50:# get-transcript) which is NOT BUILT YET — fixture/seeded sources
agents/recruitment/scribe/cycle.sh:52:# fixture suites; live smoke is founder-gated (creds + ≥1 recorded meeting).
agents/recruitment/scribe/cycle.sh:157:  psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" "$@"
agents/recruitment/scribe/cycle.sh:230:  # Source order: fixture file → @ifos/granola CLI (expected surface:
agents/recruitment/scribe/cycle.sh:308:  # Source order: seeded fixture file/dir → @ifos/granola CLI (expected
agents/recruitment/scribe/cycle.sh:406:  if [[ -n "${ext_emails}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
agents/recruitment/scribe/cycle.sh:470:  #   IFOS_FORCE_VOICE_SCORE  → numeric (fixture/test hook + future classifier wire-in)
agents/recruitment/scribe/cycle.sh:580:  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
agents/recruitment/scribe/cycle.sh:613:         if [[ -n "${prior_data}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
agents/recruitment/scribe/cycle.sh:684:      if [[ -n "${prior_data}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
agents/recruitment/scribe/cycle.sh:715:  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:1:# Scribe fixture — 99-voice-drift-blocked
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:29:#         scripts/run-scribe-gate-a-test.sh (G3 fail class + ESC_VOICE_DRIFT).
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:31:fixture_id: 99-voice-drift-blocked
agents/recruitment/scribe/bin/render-tacit-note.sh:6:# the same transcript always renders the same note, so it is fixture-testable.
scripts/ifos-pii-purge.sh:65:  IFOS_DB_URL       Direct connection string (overrides SSH_MODE config).
scripts/ifos-pii-purge.sh:83:if [[ -n "${IFOS_DB_URL:-}" ]]; then
scripts/ifos-pii-purge.sh:86:  PSQL_CONN=(--dbname "${IFOS_DB_URL}")
scripts/run-weekly-report-test.sh:2:# Cash Conductor — weekly-report metrics fixture test (P5).
scripts/run-weekly-report-test.sh:13:readonly TENANT="wr-fixture-test"
scripts/run-weekly-report-test.sh:14:IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
scripts/run-weekly-report-test.sh:21:printf '\033[1;34m── Weekly-report metrics fixture test ──\033[0m\n'
scripts/run-weekly-report-test.sh:23:RAW="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}" <<SQL
agents/recruitment/scribe/README.md:4:(W6 build slice, 2026-06-10) — gate-green + fixture-proven; live
agents/recruitment/scribe/README.md:22:| `fixtures/01-primary.yaml` | golden case (exercised by `scripts/run-scribe-extraction-test.sh`) |
agents/recruitment/scribe/README.md:23:| `fixtures/02-edge-case-paid-only.yaml` | Free-tier degraded notes-only ingest |
agents/recruitment/scribe/README.md:24:| `fixtures/99-voice-drift-blocked.yaml` | adversarial: voice <0.75 → writes blocked |
agents/recruitment/scribe/README.md:26:## Fixture suites (DB-backed; auto-discovered by scripts/build-gate.sh)
agents/recruitment/scribe/README.md:28:- `scripts/run-scribe-extraction-test.sh`
agents/recruitment/scribe/README.md:29:- `scripts/run-scribe-gate-a-test.sh`
agents/recruitment/scribe/README.md:30:- `scripts/run-scribe-sla-test.sh`
scripts/run-chase-scan-test.sh:2:# Cash Conductor — deterministic chase-scan ladder fixture test (P4a).
scripts/run-chase-scan-test.sh:6:# §3.2 escalation ladder + every exclusion rule. All fixtures seed under a
scripts/run-chase-scan-test.sh:11:#   IFOS_DB_URL=postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev \
scripts/run-chase-scan-test.sh:13:# (IFOS_DB_URL defaults to the local dev DB if unset.)
scripts/run-chase-scan-test.sh:20:readonly TEST_TENANT="chase-fixture-test"
scripts/run-chase-scan-test.sh:21:IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
scripts/run-chase-scan-test.sh:29:printf '\033[1;34m── Chase-scan ladder fixture test ──\033[0m\n'
scripts/run-chase-scan-test.sh:33:RAW_OUT="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TEST_TENANT}" <<SQL
scripts/setup-local-dev-db.sh:27:# OUTPUT: prints the IFOS_DB_URL to export for the agent runtime + a verified
scripts/setup-local-dev-db.sh:122:printf '\n  \033[1mexport IFOS_DB_URL="postgresql://%s:%s@localhost:%s/%s"\033[0m\n\n' \
scripts/setup-local-dev-db.sh:125:# shellcheck disable=SC2016  # intentional: print $IFOS_DB_URL literally for the user to run
scripts/setup-local-dev-db.sh:126:printf '    psql "$IFOS_DB_URL" -c "BEGIN; SET LOCAL app.current_tenant='\''%s'\''; SELECT count(*) FROM tenant_adapters; COMMIT;"\n' "${TENANT}"
scripts/run-codex-ratification.sh:26:#   - Optional: IFOS_DB_URL set for decision_log audit row writes; otherwise
scripts/run-codex-ratification.sh:98:# Three fixture-first connectors scaffolded across Day-25 (xero) + Day-26
scripts/run-codex-ratification.sh:114:# + fixtures from the single path given, so each bundle is one entry.
scripts/run-codex-ratification.sh:268:  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
scripts/run-codex-ratification.sh:269:    psql -v ON_ERROR_STOP=1 -q "${IFOS_DB_URL}" >/dev/null 2>&1 <<EOF
agents/recruitment/scribe/bin/sla-class.sh:5:# testable by scripts/run-scribe-sla-test.sh and shared verbatim by cycle.sh.
scripts/run-live-migration.sh:88:  unset IFOS_DB_URL
scripts/run-live-migration.sh:302:export IFOS_DB_URL="postgresql://${DB_USER}:${PGPASSWORD}@localhost:${LOCAL_PORT}/${DB_NAME}?sslmode=disable"
scripts/run-live-migration.sh:433:printf '\nPassword + IFOS_DB_URL cleared from environment.\n'
scripts/run-reconciliation-recon-test.sh:2:# Cash Conductor — deterministic reconciliation-match fixture test (P3b).
scripts/run-reconciliation-recon-test.sh:10:# Isolation: all fixtures are seeded under a throwaway tenant inside ONE
scripts/run-reconciliation-recon-test.sh:12:# is touched, and RLS scopes every read/write to the fixture tenant.
scripts/run-reconciliation-recon-test.sh:15:#   IFOS_DB_URL=postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev \
scripts/run-reconciliation-recon-test.sh:17:# (IFOS_DB_URL defaults to the local dev DB if unset.)
scripts/run-reconciliation-recon-test.sh:24:readonly TEST_TENANT="recon-fixture-test"
scripts/run-reconciliation-recon-test.sh:25:IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
scripts/run-reconciliation-recon-test.sh:33:printf '\033[1;34m── Reconciliation match fixture test ──\033[0m\n'
scripts/run-reconciliation-recon-test.sh:36:RAW_OUT="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TEST_TENANT}" <<SQL
scripts/run-scribe-extraction-test.sh:2:# Scribe — deterministic extraction + schema-validation fixture test (spec-002 §7).
scripts/run-scribe-extraction-test.sh:10:# CC fixture pattern: registered throwaway tenant (decision_log/entities FK →
scripts/run-scribe-extraction-test.sh:20:readonly TENANT="scribe-extract-fixture"
scripts/run-scribe-extraction-test.sh:21:IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
scripts/run-scribe-extraction-test.sh:22:export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}"
scripts/run-scribe-extraction-test.sh:38:appq() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}"; }
scripts/run-scribe-extraction-test.sh:54:printf '\033[1;34m── Scribe extraction + schema-validation fixture test ──\033[0m\n'
scripts/run-scribe-extraction-test.sh:58:INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Scribe extraction fixture')
scripts/run-tenancy-audit.sh:8:# via SSH tunnel + multi-tenant render fixture.
scripts/run-tenancy-audit.sh:28:#   - test-tenant-b fixture exists at packages/agent-renderer/tests/fixtures/...
scripts/run-tenancy-audit.sh:128:if [[ ! -d "${REPO_ROOT}/packages/agent-renderer/tests/fixtures/test-tenant-vault/${TENANT_B}" ]]; then
scripts/run-tenancy-audit.sh:129:  _fail "test-tenant-b fixture not found" "Run Phase 1.4 first to create the fixture"
scripts/run-tenancy-audit.sh:132:_pass "test-tenant-b fixture present"
scripts/run-tenancy-audit.sh:374:    --bundle-root "${REPO_ROOT}/packages/agent-renderer/tests/fixtures" \
scripts/run-tenancy-audit.sh:375:    --vault-root "${REPO_ROOT}/packages/agent-renderer/tests/fixtures/test-tenant-vault/${tenant}" \
scripts/run-tenancy-audit.sh:514:# test fixtures, and fallback placeholders.
scripts/run-tenancy-audit.sh:519:#   - "examples" / "test-tenant" / "migration-test" → test fixtures
agents/recruitment/scribe/context.sh:9:#         with IFOS_FORCE_* env fallbacks retained for fixtures + local dev.
agents/recruitment/scribe/context.sh:82:  if [[ -z "${IFOS_DB_URL:-}" ]] || ! command -v psql >/dev/null 2>&1; then
agents/recruitment/scribe/context.sh:85:  psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
agents/recruitment/scribe/context.sh:98:# WHERE adapter_name='bullhorn'. IFOS_FORCE_* fallback kept for fixtures.
agents/recruitment/scribe/context.sh:147:# on fixture/seeded transcript sources only).
agents/recruitment/scribe/context.sh:165:if [[ -z "${_vc_id}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
agents/recruitment/scribe/context.sh:166:  _vc_id="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1 || true
agents/recruitment/scribe/agent.md:4:**Build state (post-W6 build slice, 2026-06-10):** the W6 build slice is BUILT on branch `worktree-agent-a59f16e915e384257`: `cycle.sh` (10-step, 4 modes), `validate.sh` (Gate A G1-G8), `context.sh`, `cleanup.sh`, `tools.yaml`, 5 `bin/` helpers, 3 fixtures + 3 deterministic DB-backed fixture suites — all green under `scripts/build-gate.sh`. This document was reconciled to the built Granola-poll reality in the round-2 fix pass (Codex round-1 findings 1-4). **What has NOT happened:** no live Bullhorn or Granola call — Bullhorn dev creds are EMPTY, the `@ifos/bullhorn` CLI bridge is the Janitor build slice's parallel deliverable (Scribe consumes it only through `bin/bh-bridge.sh`), the Granola IFOS-side OAuth token is not on disk, and `@ifos/granola` has no built CLI. Live smoke is founder-gated (see §8). Earlier history: Day-20 W4 bilateral pass + R19 substantive fixes; pre-pivot Fathom/Fireflies prose removed 2026-06-10 (see vendor note below).
agents/recruitment/scribe/agent.md:6:**Per-component state (honest, verified 2026-06-10):** `cycle.sh`/`validate.sh`/`context.sh`/`cleanup.sh`/`bin/*` BUILT + fixture-proven; `context.sh` reads `tenant_adapters.config` (v0.4 keys `bullhorn_corporation_id` + `granola_workspace_id`) with `IFOS_FORCE_*` env fallbacks for fixtures; LLM extraction path EXISTS but is opt-in (`IFOS_SCRIBE_USE_LLM=1`) — fixtures run the deterministic extractor; the voice classifier is NOT built (notes carry honest `unscored/no_corpus` or `unscored/no_classifier`); `bin/bh-bridge.sh` conforms to the agreed `@ifos/bullhorn` CLI contract (review-scribe.md orchestrator ruling) and degrades honestly (exit 3 `unavailable`, no fake writes) until the Janitor bridge lands.
agents/recruitment/scribe/agent.md:237:     (fixture-reproducible default) — or the LLM path when
agents/recruitment/scribe/agent.md:412:The W6 build slice is BUILT (fixture-proven, no live calls). Remaining ⏸
agents/recruitment/scribe/agent.md:422:| 3 fixtures + 3 deterministic DB-backed fixture suites | W6 build slice | ✅ built (green in build-gate.sh) |
agents/recruitment/scribe/agent.md:443:**Status:** Proposed. W6 build slice BUILT + fixture-proven (this branch); live smoke awaits the §8 ⏸ gates (Bullhorn creds + bridge merge + Granola token + recorded meeting) + Q1 LOI / pilot tenant.
agents/recruitment/scribe/agent.md:475:- ~~W6 build slice produces all 5 sibling bundle files + 3 fixtures~~ ✅ done 2026-06-10 (this branch; fixture-proven, live smoke pending)
scripts/run-chase-lifecycle-test.sh:2:# Cash Conductor — chase lifecycle fixture test (P4d: Steps 11-12).
scripts/run-chase-lifecycle-test.sh:5:# Mirrors the SQL behaviour in cycle.sh Steps 11-12; all fixtures seed inside ONE
scripts/run-chase-lifecycle-test.sh:11:readonly TENANT="lifecycle-fixture-test"
scripts/run-chase-lifecycle-test.sh:12:IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
scripts/run-chase-lifecycle-test.sh:18:printf '\033[1;34m── Chase lifecycle fixture test (Steps 11-12) ──\033[0m\n'
scripts/run-chase-lifecycle-test.sh:20:RAW="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}" <<'SQL'
scripts/build-gate.sh:9:#   1. shellcheck — all agent-bundle shells + bin helpers + fixture-test scripts
scripts/build-gate.sh:12:#   4. fixtures   — every scripts/run-*-test.sh (DB-backed; skipped w/ warning if no DB)
scripts/build-gate.sh:15:#   IFOS_DB_URL defaults to the local dev DB; --no-db (or an unreachable DB) skips tier 4.
scripts/build-gate.sh:20:IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
scripts/build-gate.sh:21:export IFOS_DB_URL
scripts/build-gate.sh:32:_step "1. shellcheck (agent bundles + bin + fixture tests)"
scripts/build-gate.sh:59:# ── Tier 4: DB-backed fixture suites ──────────────────────────────────────
scripts/build-gate.sh:60:_step "4. fixture suites (DB-backed)"
scripts/build-gate.sh:62:if [[ "${NO_DB}" -eq 0 ]] && command -v psql >/dev/null 2>&1 && psql "${IFOS_DB_URL}" -tAc 'SELECT 1' >/dev/null 2>&1; then
scripts/build-gate.sh:75:  _warn "no reachable IFOS_DB_URL — DB-backed fixture suites SKIPPED (run on a machine with the dev DB)"
scripts/run-scribe-gate-a-test.sh:2:# Scribe — Gate A (validate.sh) fixture test (spec-002 §7).
scripts/run-scribe-gate-a-test.sh:14:# CC fixture pattern (run-gate-a-test.sh): the test tenant is registered in
scripts/run-scribe-gate-a-test.sh:23:readonly TENANT="scribe-gate-a-fixture"
scripts/run-scribe-gate-a-test.sh:24:IFOS_DB_URL="${IFOS_DB_URL:-postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev}"
scripts/run-scribe-gate-a-test.sh:25:export IFOS_DB_URL IFOS_REPO_ROOT="${REPO_ROOT}"
scripts/run-scribe-gate-a-test.sh:43:appq() { psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${TENANT}" "$@"; }
scripts/run-scribe-gate-a-test.sh:54:printf '\033[1;34m── Scribe Gate A (validate.sh) fixture test ──\033[0m\n'
scripts/run-scribe-gate-a-test.sh:57:INSERT INTO tenants (tenant_slug, tenant_name) VALUES (:'tenant', 'Scribe Gate A fixture')
scripts/run-scribe-gate-a-test.sh:114:    tacit_note: { vault_path: "/vault/scribe-gate-a-fixture/scribe-notes/meeting-ga-2026-06-10.md",
scripts/run-scribe-gate-a-test.sh:137:        '{"output_type":"bullhorn_auth_refreshed","artefact_ref":"tenant:scribe-gate-a-fixture"}');
agents/recruitment/scribe/bin/extract-fields.sh:11:#      input always yields the same output → fixture-reproducible without
agents/recruitment/scribe/validate.sh:305:if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
agents/recruitment/scribe/validate.sh:306:  _auth_row="$(psql "${IFOS_DB_URL}" -tAq --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1

codex
I have enough to decide. The blockers are not broad style concerns; they are concrete contract mismatches: status evidence, voice-loader integration, and inconsistent Gate/SLA thresholds.
exec
/bin/zsh -lc "test -f .codex/ratification/review-agent-bundle.md && printf yes || printf no; rg --files .codex 2>/dev/null | sed -n '1,80p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
yes.codex/ratification/review-agent-bundle.md
.codex/ratification/SKILL.md
.codex/ratification/review-postgres-migration.md
.codex/ratification/review-mcp-connector.md
.codex/ratification/review-schema-change.md
.codex/ratification/review-architecture-decision.md

exec
/bin/zsh -lc 'rg -n "review-agent-bundle|ratification" .codex docs agents -S' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
.codex/ratification/review-agent-bundle.md:1:# Codex ratification skill — review-agent-bundle
.codex/ratification/review-agent-bundle.md:73:- §10 doesn't name the Codex skill (this skill) for ratification
.codex/ratification/review-agent-bundle.md:106:Per top-level SKILL.md: your output MUST start with literal `RATIFIED` or `REJECTED`. For agent.md ratification:
.codex/ratification/review-agent-bundle.md:131:Advisory notes do NOT block ratification — they're suggestions for the author. Use sparingly; if 5+ advisory notes accumulate, REJECT instead and require a remediation pass.
.codex/ratification/review-agent-bundle.md:147:*End of review-agent-bundle skill.*
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:4:# Status: Proposed (W5 Day-30 landing; W6+ Codex ratification queue addendum)
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:34:codex_ratification_queue_position: pending  # F-tris cluster per goal-week-5-execution-plan.md §5
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:269:# §4 — Codex ratification path
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:272:codex_ratification:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:275:  manifest_queue_position: F-tris (deferred to W5 Phase 7 per goal-week-5-execution-plan.md §5; partial-ratification framework available per Fbis + G precedent)
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:281:    round; partial-ratification framework remains available if Codex finds
.codex/ratification/SKILL.md:1:# Codex ratification — top-level skill
.codex/ratification/SKILL.md:3:You are reviewing an Intel Force OS (IFOS) artefact for ratification.
.codex/ratification/SKILL.md:100:- `review-agent-bundle.md` — for new agents under `agents/<vertical>/<name>/`
.codex/ratification/review-postgres-migration.md:1:# Codex ratification skill — review-postgres-migration
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:3:# Status: Proposed (Codex Day-19 ratification queue addendum)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:21:# v0.3 ratification does not block on it.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:45:codex_ratification_queue_position: 44
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:929:    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:933:# §7 — Codex ratification path
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:936:codex_ratification:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1038:      they do not block v0.3 ratification but do require a Scribe agent.md
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1045:  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
agents/_shared/escalation-codes.md:488:The Codex Day-7 ratification queue includes this catalogue (item #20 placeholder per `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1). Updates after ratification = new commit + Codex re-review of the diff.
.codex/ratification/review-mcp-connector.md:1:# Codex ratification skill — review-mcp-connector
.codex/ratification/review-mcp-connector.md:3:Apply this skill on top of `.codex/ratification/SKILL.md` (five rules + four boundaries + honest-signal checks; bias toward REJECT) when reviewing a TypeScript MCP connector package under `packages/mcp-connectors/<name>/`.
.codex/ratification/review-schema-change.md:1:# Codex ratification skill — review-schema-change
agents/_shared/README.md:161:Production rollout (other tenants) waits for Codex ratification of v0.2 + Diagnostic + Janitor verification of the schema against real Bullhorn data (master brief §6 Day 6 Q3 trigger from v0.1).
agents/_shared/README.md:163:## Codex Day-7 ratification
docs/_archive-build-pack/08-OPEN-DECISIONS.md:212:## §13 · Codex ratification ritual
.codex/ratification/review-architecture-decision.md:1:# Codex ratification skill — review-architecture-decision
.codex/ratification/review-architecture-decision.md:31:6. **Status update line at end** — current state ("Accepted on 2026-05-16 by founder + Claude Code") OR ratification-pending note. **Required for ALL statuses.**
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:3:# Status: Proposed (Codex Day-7 ratification queue addendum)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:27:codex_ratification_queue_position: 29  # appended after Phase-3 items
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:379:# Three new questions; resolved at Codex ratification OR at first pilot data.
docs/operations/session-retrospective-2026-06-03.md:83:4. **agent.md ratification-status ambiguity.** Scribe + Sourcing Scout agent.md both say "Status: Proposed" in their banners but were ratified at W3 cluster E (per file metadata + commit history). Reading-discipline note pattern documents this ambiguity; W6 ratification update flips both Proposed → Accepted explicitly.
docs/architecture/tenancy-invariants.md:226:4. **Codex ratification** — invariant document is ratified via `review-architecture-decision.md` skill; updates re-ratify.
docs/architecture/tenancy-invariants.md:229:The full provenance trail: ADR → tenancy-invariants.md update → migration SQL (if needed) → audit script update → Codex ratification → backlog closure.
docs/architecture/tenancy-invariants.md:259:**Reference (In Force on tenant-data write paths).** Codex ratification queue item #35; ratified via `.codex/ratification/review-architecture-decision.md`. Companion audit script at `scripts/run-tenancy-audit.sh` ratified as item #38. Both queued for Codex Round 3 after this commit ships.
docs/_archive-build-pack/01-RECOMMENDATION.md:112:| Codex ratification | One coherent target. Codex returns one delta. |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:9:You said the goal is to one-shot this with Claude Code + Codex ratification. "One-shot" doesn't mean a single chat turn. It means **the build proceeds without architectural re-litigation**. Phase boundaries are gates; inside a phase, slices execute against the pack. Codex catches what Claude Code missed; Claude Code catches what Codex missed.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:162:| One-time, 2 weeks after Phase 0 ships | "Open a Codex-review PR for Phase 0 artifacts" | Forces the Codex ratification step to actually happen |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:258:- Skip the Codex ratification step at phase boundaries
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:270:Concretely, the ratification ritual at each phase boundary:
docs/operations/goal-overnight-2026-05-31.md:18:4. `.codex/ratification/review-agent-bundle.md` (skill structure template)
docs/operations/goal-overnight-2026-05-31.md:26:### 2. `.codex/ratification/review-mcp-connector.md` Codex skill (~90 min)
docs/operations/goal-overnight-2026-05-31.md:28:Author modeled on `review-agent-bundle.md`. 7 checks layered on top of `SKILL.md`:
docs/operations/codex-round-2-autonomous-prompt.md:5:**Purpose:** Single prompt the founder pastes into `codex` interactive mode that runs Round 2 ratification + manifest closure + commit + push **end-to-end without founder input**.
docs/operations/codex-round-2-autonomous-prompt.md:11:codex --version          # must succeed; if not, see codex-ratification-guide.md §3.1
docs/operations/codex-round-2-autonomous-prompt.md:25:You are running Codex Round 2 ratification for the Intel Force OS (IFOS) codebase. 
docs/operations/codex-round-2-autonomous-prompt.md:39:  - The ratification skills to apply per artefact (§3 tables)
docs/operations/codex-round-2-autonomous-prompt.md:54:  2. .codex/ratification/SKILL.md  (top-level ratification skill)
docs/operations/codex-round-2-autonomous-prompt.md:55:  3. .codex/ratification/review-architecture-decision.md  (with D5 softening
docs/operations/codex-round-2-autonomous-prompt.md:57:  4. .codex/ratification/review-schema-change.md
docs/operations/codex-round-2-autonomous-prompt.md:58:  5. .codex/ratification/review-postgres-migration.md
docs/operations/codex-round-2-autonomous-prompt.md:60:     + §10 (ratification loop)
docs/operations/codex-round-2-autonomous-prompt.md:68:mkdir -p logs/codex-ratification/round-2-autonomous/
docs/operations/codex-round-2-autonomous-prompt.md:80:  d) Write your verdict to logs/codex-ratification/round-2-autonomous/<slug>.output.md
docs/operations/codex-round-2-autonomous-prompt.md:84:For Tier 1 (14 re-ratifications): the Round-1 verdict + remediation commit 
docs/operations/codex-round-2-autonomous-prompt.md:85:SHA is in docs/decisions/2026-05-18-codex-ratification-manifest.md §1.5. 
docs/operations/codex-round-2-autonomous-prompt.md:91:recursive ratification per master brief §10.5. Decide whether Claude's 
docs/operations/codex-round-2-autonomous-prompt.md:108:  logs/codex-ratification/round-2-autonomous/SUMMARY.md
docs/operations/codex-round-2-autonomous-prompt.md:145:Edit docs/decisions/2026-05-18-codex-ratification-manifest.md.
docs/operations/codex-round-2-autonomous-prompt.md:160:For new artefacts (Tier 2 + Tier 3): disposition says "First ratification 
docs/operations/codex-round-2-autonomous-prompt.md:180:  git add logs/codex-ratification/round-2-autonomous/ \
docs/operations/codex-round-2-autonomous-prompt.md:181:    docs/decisions/2026-05-18-codex-ratification-manifest.md \
docs/operations/codex-round-2-autonomous-prompt.md:187:  ops(codex-round-2): autonomous ratification of 26 artefacts + manifest closure
docs/operations/codex-round-2-autonomous-prompt.md:189:  Round 2 ratification complete. <X> of 26 RATIFIED. <Y> remaining 
docs/operations/codex-round-2-autonomous-prompt.md:196:  Disagreement docs (recursive ratification per master brief §10.5):
docs/operations/codex-round-2-autonomous-prompt.md:200:  Full per-artefact verdicts at logs/codex-ratification/round-2-autonomous/
docs/operations/codex-round-2-autonomous-prompt.md:201:  + manifest update at docs/decisions/2026-05-18-codex-ratification-
docs/operations/codex-round-2-autonomous-prompt.md:224:  Logs at: logs/codex-ratification/round-2-autonomous/
docs/operations/codex-round-2-autonomous-prompt.md:243:2. **DO NOT modify ANY artefact file** during ratification. If Codex 
docs/operations/codex-round-2-autonomous-prompt.md:266:6. **DO commit + push the ratification work** in Step 7. The wrapper 
docs/operations/codex-round-2-autonomous-prompt.md:267:   script (scripts/run-codex-ratification.sh) handles per-artefact audit 
docs/operations/codex-round-2-autonomous-prompt.md:313:1. Read `logs/codex-ratification/round-2-autonomous/SUMMARY.md`
docs/_archive-build-pack/06-BUILD-PLAN.md:3:**Phased slices, A/B/C-style. Each phase has a focused goal, a stack of slices, acceptance criteria, and a ratification step through Codex. The plan optimises for "ship a thing each phase that the founder can see working", not for breadth.**
docs/_archive-build-pack/06-BUILD-PLAN.md:9:| Phase | Goal | Duration target | Ratification gate |
docs/architecture/architecture-cohesion-review.md:188:  - **A:** Codex review skill `review-agent-bundle.md` (not yet built) would catch this. Currently relies on grep audit + author discipline. Recommend: add this check to `scripts/run-tenancy-audit.sh` (Phase 1 enhancement OR Codex skill).
docs/architecture/architecture-cohesion-review.md:190:**Verdict: BOUNDARY HOLDS at current artefact set.** Future agents need automated guardrail; queue as Phase-1 extension OR `review-agent-bundle.md` skill at Diagnostic W3.
docs/architecture/architecture-cohesion-review.md:215:  - **A:** R2 commitment (ADR-003 Decision 1): tools.yaml can opt-in to cortextOS skills via `cortextos_skills:` block. If an agent opts in to `knowledge-base`, it gets the upstream KB. **This is the seam.** Currently no agent opts in. Recommend: add `review-agent-bundle.md` skill check to flag any `knowledge-base` opt-in for explicit founder review.
docs/architecture/architecture-cohesion-review.md:234:| R8 | Adapter + brain-replacement boundary automation | Medium | `review-agent-bundle.md` Codex skill at Diagnostic W3 | Claude Code | Diagnostic W3 |
docs/architecture/architecture-cohesion-review.md:259:3. Codex Round 2 closes (re-ratification after Day-8-evening fixes)
docs/verticals/recruitment/vertical-schema.yaml:22:codex_ratification_queue_position: 18
docs/verticals/recruitment/vertical-schema.yaml:867:    status: DEFERRED to v1.0 Codex ratification
docs/verticals/recruitment/vertical-schema.yaml:872:      Codex Day-7 ratification reviews whether stricter source-field schema would improve machine-parseability. If accepted, v1.0 introduces structured source object — e.g., `source: {origin: bullhorn | ifos_derived, bullhorn_field?: <entity.field>, ifos_agent?: <agent_name>, citation?: <doc-ref>}`.
docs/verticals/recruitment/vertical-schema.yaml:887:    next_action: Codex Day-7 ratification queue position 18.
agents/recruitment/cash-conductor/agent.md:3:**Status:** Proposed-with-disagreement-on-file (`docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` — bundle-layer Codex ratification deferred to W7-8 build slice; contract-layer ratification was achieved in W3 cluster E).
agents/recruitment/cash-conductor/agent.md:153:14 steps. Per ADR-003 §3 agent-bundle pattern + the review-agent-bundle Codex ratification skill §4 ("every output/action step MUST call hh_decision_*"): every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Master brief §8.1 Change 2 mandates the three-call minimum per agent run (`trigger`, `output`, `action`); the per-step mandatory-write discipline is the agent-bundle contract extension.
agents/recruitment/cash-conductor/agent.md:403:| Concierge agent.md ratified Accepted (for chase-send routing contract; full Concierge production-build at W10-13, but Cash Conductor only depends on the Concierge agent.md contract being Accepted, not the full bundle being In Force) | Post-Concierge agent.md re-ratification | ⏸ |
agents/recruitment/cash-conductor/agent.md:448:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies via the cluster Fbis ratification run (`bash scripts/run-codex-ratification.sh --cluster Fbis`). Round-trip history: Day-20 W3 cluster E ratified the agent.md at the contract layer; cluster Fbis (2026-06-02) ratifies the bundle layer now that sibling files (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures) exist alongside.
agents/recruitment/cash-conductor/agent.md:463:- Codex re-ratifies post-build via `review-agent-bundle.md` skill
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:15:Closes goal-week-4-track-1.md §1 criteria 5-10. Cluster F-bis manifest entry queued (Cash Conductor agent-bundle skill) — actual entry to `run-codex-ratification.sh` lands at start of Day-27 when ready to fire cluster F + F-bis together.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:47:Print: phase A/B/C status + commit SHAs · test counts (bridge: ≥12 vitest target) · Cash Conductor bundle 100% complete? · bridge package scaffold complete? · 2 polish items closed? · founder action board refresh · tomorrow's first action (cluster F + F-bis ratification triggers when founder ready; voice classifier microservice begins Tue scaffold).
docs/architecture/agent-bundle-renderer-design.md:43:| `agent.md` (line 552) | Output contract first; then workflow, gates, escalation. Master brief §1 Rule 1: "Every agent ships with its output contract written first, as a one-paragraph screenshot description." | the renderer (synthesises into `CLAUDE.md` per §2.1); humans for code review | **Static** — founder writes once; iterated per Codex ratification (master brief §10.5 names every new `agent.md` as always-ratify) |
docs/architecture/agent-bundle-renderer-design.md:636:**Recovery:** stderr lists the failed validation path (e.g. `properties.nurture_cadence.post_interview_chase_hours: expected integer, got string`). Founder edits `/vault/<tenant>/_config.yaml` or the `config.schema.json` source (rare; schema edits go through Codex ratification per master brief §10.5). Re-runs render.
docs/architecture/agent-bundle-renderer-design.md:708:- **Audit log:** Postgres `decision_log` row with `tenant_slug`, `agent_name='_renderer'`, `phase='gating_failed'` (failures) or `phase='action'` (successful renders), `payload->>'reason'` carries the reason code. RLS-isolated per tenant. Codex's Day-7 ratification report queries this table for all rows where `agent_name='_renderer' AND payload->>'reason' LIKE 'ESC_RENDERER_FAILED%'`. (Per ADR-004 Decision 7: `phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — use the 5-value enum from Day-4 §6.3 + Day-5 schema migration.)
docs/operations/goal-week-3-polish-and-scaffold.md:1:# /goal — Week 3: Diagnostic polish + 5 agent.md scaffolds + Codex ratification
docs/operations/goal-week-3-polish-and-scaffold.md:3:**Status:** CLOSED (Day-19 narrative close 2026-05-24; **true Codex ratification close 2026-05-31**). Day-19 close was optimistic (premature RATIFIED status flips at commit `75ccc5f`, later reverted by R19 bilateral pass). True close 2026-05-31: ran `bash scripts/run-codex-ratification.sh --cluster E` three rounds — R1 verdict 4/9 RATIFIED, R2 verdict 6/9, R3 verdict **8/9 RATIFIED**; the 9th artefact (v0.2-to-v0.3 migration) had its R3 rollback finding fixed at commit `0f4ce8d` and re-ratification deferred per master brief §10.3 step 5 ceiling (3 round-trips already crossed; founder decision 2026-05-31 — fix + stop). Net effective state: **8/9 Codex-RATIFIED + 1 with the latest R3 fix applied = 9/9 in substance**. v0.3 schema supplement RATIFIED (final via Round 3). ADR-006 Diagnostic Gate A hybrid Accepted (founder-arbitrated). ADR-007 Concierge Gate A hybrid RATIFIED (still Status: Proposed pending founder Accept per its own §10). All 6 agent.md scaffolds RATIFIED at the contract level (Status: Proposed; production-readiness gates unchanged: pilot LOI · Bullhorn A+B · API keys · live VPS migration). See `.agents/current-priorities.md` "W4 Day-25" section for per-round detail + the deferred rollback re-ratification W4 backlog item. **STOP-HOOK NOTE: this file's gate-structure was superseded by in-session founder AUQ authorization; do not re-fire on subsequent turns.**
docs/operations/goal-week-3-polish-and-scaffold.md:8:**Quality bar:** Production-quality. Each agent.md is presentable to Codex for ratification on first submission. Every spec citation verified against the source files. No speculative content; everything cited line-anchored.
docs/operations/goal-week-3-polish-and-scaffold.md:48:4. **Diagnostic bundle ratified by Codex.** Round 4 ratification run against agent.md + 5 siblings + 3 fixtures via `review-architecture-decision.md` skill. Verdict: RATIFIED (or remediation-pass if needed).
docs/operations/goal-week-3-polish-and-scaffold.md:70:### Codex ratification (Day 20)
docs/operations/goal-week-3-polish-and-scaffold.md:72:10. **Round 4 ratification run executed** via `bash scripts/run-codex-ratification.sh` with the manifest extended to include 6 new artefacts (Diagnostic agent.md re-ratify + 5 new agent.md scaffolds).
docs/operations/goal-week-3-polish-and-scaffold.md:73:11. **All 6 verdicts captured** in `logs/codex-ratification/round-4/`. Per-artefact RATIFIED / NEEDS-REMEDIATION / REJECTED.
docs/operations/goal-week-3-polish-and-scaffold.md:79:14. **`docs/RISK-REGISTER.md`** updated: Risk #2 (Bullhorn) blast radius confirmed reduced; Risk #5 (Renderer) state per Diagnostic ratification.
docs/operations/goal-week-3-polish-and-scaffold.md:80:15. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue extended with Round-4 items (queue: 43 → 49).
docs/operations/goal-week-3-polish-and-scaffold.md:94:| Diagnostic Codex ratification | Master brief §10.5 always-ratify |
docs/operations/goal-week-3-polish-and-scaffold.md:96:| Codex Round 4 execution | Master brief §10.6 ratification cadence |
docs/operations/goal-week-3-polish-and-scaffold.md:113:| Building any new Codex ratification skill (e.g., `review-agent-bundle.md`) | Defer per execution-plan §3 lazy; agent.md ratification uses existing `review-architecture-decision.md` skill |
docs/operations/goal-week-3-polish-and-scaffold.md:253:### DAY 15 — Diagnostic Codex ratification (Steps 6-7)
docs/operations/goal-week-3-polish-and-scaffold.md:257:Edit `docs/decisions/2026-05-18-codex-ratification-manifest.md`:
docs/operations/goal-week-3-polish-and-scaffold.md:267:Each entry: title + status + Codex skill + ratification date placeholder.
docs/operations/goal-week-3-polish-and-scaffold.md:276:bash scripts/run-codex-ratification.sh --round 4 --subset diagnostic
docs/operations/goal-week-3-polish-and-scaffold.md:279:Captures verdicts in `logs/codex-ratification/round-4/diagnostic/`. Each artefact: RATIFIED | NEEDS-REMEDIATION | REJECTED.
docs/operations/goal-week-3-polish-and-scaffold.md:314:- **§10 Ratification:** via `review-architecture-decision.md` Codex skill; ratifies as part of Round 4 if scaffolded by Day 20.
docs/operations/goal-week-3-polish-and-scaffold.md:438:### DAY 20 — Codex Round 4 full ratification + state sync (Steps 13-14)
docs/operations/goal-week-3-polish-and-scaffold.md:445:bash scripts/run-codex-ratification.sh --round 4 --full
docs/operations/goal-week-3-polish-and-scaffold.md:448:Output captured in `logs/codex-ratification/round-4/`. Per-artefact verdict.
docs/operations/goal-week-3-polish-and-scaffold.md:462:2. **`docs/RISK-REGISTER.md`** — Risk #2 (Bullhorn) status per A+B response state; Risk #5 (Renderer) updated per Diagnostic ratification.
docs/operations/goal-week-3-polish-and-scaffold.md:463:3. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue — Round-4 verdicts captured; queue grown to 49+ items.
docs/operations/goal-week-3-polish-and-scaffold.md:490:| **Codex skill output captured** | Each ratification round writes per-artefact `.output.md` files | `ls logs/codex-ratification/round-4/` |
docs/operations/goal-week-3-polish-and-scaffold.md:538:## §8 — Codex ratification protocol (load-bearing)
docs/operations/goal-week-3-polish-and-scaffold.md:544:Add 6 items to `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.10:
docs/operations/goal-week-3-polish-and-scaffold.md:552:Each entry: artefact + status + Codex skill + ratification date placeholder.
docs/operations/goal-week-3-polish-and-scaffold.md:557:bash scripts/run-codex-ratification.sh --round 4 --subset diagnostic
docs/operations/goal-week-3-polish-and-scaffold.md:560:Mid-week early ratification of Diagnostic ensures: (a) the substrate is verified before 5 new scaffolds reference it; (b) any architectural concerns surface before the 5 new agent.md contracts are committed.
docs/operations/goal-week-3-polish-and-scaffold.md:565:bash scripts/run-codex-ratification.sh --round 4 --full
docs/operations/goal-week-3-polish-and-scaffold.md:582:- `review-agent-bundle.md` — NOT YET BUILT (per execution-plan §3 lazy); defer; use review-architecture-decision.md for each agent.md individually
docs/operations/goal-week-3-polish-and-scaffold.md:698:- Codex Round 4 logs in `logs/codex-ratification/round-4/`
agents/recruitment/scribe/README.md:36:## Ratification
agents/recruitment/scribe/README.md:38:Post-build Codex re-ratification via `review-agent-bundle.md` (agent.md §10).
agents/recruitment/scribe/tools.yaml:98:    purpose: "Write structured fields onto Contact entity (Step 8); v1.0 LIMITATION: requires @ifos/bullhorn v0.2+ (updateContact not yet exported); declared for ratification continuity"
agents/recruitment/scribe/tools.yaml:108:    purpose: "Write structured fields onto Brief/JobOrder entity (Step 8); v1.0 LIMITATION: requires @ifos/bullhorn v0.2+ (updateBrief not yet exported); declared for ratification continuity"
agents/recruitment/scribe/tools.yaml:117:    purpose: "Write structured fields onto Placement entity (Step 8); v1.0 LIMITATION: requires @ifos/bullhorn v0.2+ (updatePlacement not yet exported); declared for ratification continuity"
agents/recruitment/scribe/agent.md:132:Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Field-name accuracy is enforced at runtime, not by prose: `bin/validate-fields.sh` derives its per-entity allowlist + type/range checks from the schema files themselves (mirroring the `validate_entities_data_v0_3` DB trigger), so Gate A G4/G5 fail any drift between this table and the schema as actually deployed.
agents/recruitment/scribe/agent.md:467:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict. The status flip below is FOUNDER-GATED — the 2026-06-10 Granola/built-state reconciliation of this document deliberately did NOT exercise it.
agents/recruitment/scribe/agent.md:478:- Codex re-ratifies post-build via `review-agent-bundle.md` skill
agents/recruitment/diagnostic/agent.md:4:**Build state:** Full bundle built (agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures). Codex review-agent-bundle rounds run through R19 (latest applied 2026-05-25 bilateral pass); ADR-006 closed the Cat-1/Cat-ζ Gate A finding at R10; subsequent rounds sit at steady-state ~4 mechanical cross-reference findings/round per master brief §10.3 step 5. Status flips Proposed → Accepted when ALL: (a) Codex RATIFIED verdict (R19 or escalated founder-arbitrated per §10.3 step 5), AND (b) founder approves §3's 12-section list as canonical, AND (c) first production render against the first pilot tenant succeeds, AND (d) Gate B baseline measurement begins.
agents/recruitment/diagnostic/agent.md:236:| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⚠ Rounds run through R19; ADR-006 (Accepted) closed the Cat-1 Gate A finding; residual ~4 mechanical findings/round tracked in disagreement doc Phase 4-5 |
agents/recruitment/diagnostic/agent.md:246:**Build state:** full bundle (cycle.sh, validate.sh, context.sh, tools.yaml, cleanup.sh, 3 fixtures) shipped Day 13-19. Codex review-agent-bundle ratification in progress (through R19; ADR-006 closed the Cat-1/Cat-ζ Gate A finding; iterating on ~4 mechanical findings/round).
agents/recruitment/diagnostic/agent.md:253:| Q2 | Should §11 (decision-maker map) be a separate section OR rolled into §3 + §4 + §5 + §7 as a sub-row? Currently named as a separate section. | Founder review at agent.md ratification. |
agents/recruitment/diagnostic/agent.md:269:Per `.codex/ratification/review-agent-bundle.md` (skill built Day 19; commit `825ebd4`): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.
agents/recruitment/diagnostic/agent.md:277:Until then: this document is a forward-looking scaffold. Conservative pre-build clarity — not a binding contract until ratification.
docs/operations/goal-week-4-track-1.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (boundaries) + §8.2 W4-W7 rows + §10 (ratification cadence + always-ratify list) + §10.5
docs/operations/goal-week-4-track-1.md:29:15. **`.codex/ratification/SKILL.md`** + the four type skills (architecture-decision, schema-change, postgres-migration, agent-bundle) — for the ratification step.
docs/operations/goal-week-4-track-1.md:65:13. **`.codex/ratification/review-mcp-connector.md`** exists. Type-specific skill for MCP connector packages. Adds checks on top of SKILL.md: OAuth refresh idempotency; rate-limit budget declared; explicit retry policy; secrets never logged; fixture-first tests; integration with `_shared/hook-helpers.sh` for decision_log emissions. Modeled on `review-agent-bundle.md` length + structure.
docs/operations/goal-week-4-track-1.md:67:### Codex ratification (Day 6)
docs/operations/goal-week-4-track-1.md:69:14. **`scripts/run-codex-ratification.sh` cluster F added** — `mcp-connector` skill type per artefact:
docs/operations/goal-week-4-track-1.md:73:    - `agents/recruitment/cash-conductor/` (full bundle via `agent-bundle` skill — re-ratification post-scaffold)
docs/operations/goal-week-4-track-1.md:74:15. **Cluster F run executed** (founder runs, billed); verdict in `logs/codex-ratification/<session>/`. Expected: RATIFIED on all 4 OR ≤2 mechanical findings per artefact (closeable in 1 fix-pass).
docs/operations/goal-week-4-track-1.md:80:18. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue extended with Cluster F entries.
docs/operations/goal-week-4-track-1.md:97:| Cluster F ratification manifest + run | §1 criteria 14-15 |
docs/operations/goal-week-4-track-1.md:161:Create `.codex/ratification/review-mcp-connector.md` modeled on `review-agent-bundle.md`. The skill ADDS these checks on top of `SKILL.md`:
docs/operations/goal-week-4-track-1.md:173:Commit: `feat(codex-skill): review-mcp-connector.md for cluster F ratification`
docs/operations/goal-week-4-track-1.md:289:### DAY 6 — Cluster F Codex ratification
docs/operations/goal-week-4-track-1.md:291:#### Step 8 — Extend `scripts/run-codex-ratification.sh` with cluster F (~15 min)
docs/operations/goal-week-4-track-1.md:303:Acceptance: `bash scripts/run-codex-ratification.sh --list-clusters` shows cluster F with 4 items + correct skill mapping; shellcheck clean.
docs/operations/goal-week-4-track-1.md:311:bash scripts/run-codex-ratification.sh --cluster F
docs/operations/goal-week-4-track-1.md:327:3. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue — Cluster F verdicts captured.
docs/operations/goal-week-4-track-1.md:353:| **Codex skill output captured** | Cluster F run writes per-artefact `.output.md` + `.verdict.txt` files | `ls logs/codex-ratification/<session>/` |
docs/operations/goal-week-4-track-1.md:396:## §8 — Codex ratification protocol
docs/operations/goal-week-4-track-1.md:402:The new `review-mcp-connector.md` skill is itself an artefact subject to ratification. It ratifies via `review-architecture-decision.md` (skills are architectural artefacts). Add to next ratification cluster.
docs/operations/goal-week-4-track-1.md:406:Add CLUSTERS[F] to `scripts/run-codex-ratification.sh`. 4 artefacts (3 connectors + Cash Conductor bundle).
docs/operations/goal-week-4-track-1.md:411:bash scripts/run-codex-ratification.sh --cluster F
docs/operations/goal-week-4-track-1.md:464:  .codex/ratification/review-mcp-connector.md: built; ratified via review-architecture-decision
docs/operations/goal-week-4-track-1.md:535:- Cluster F logs in `logs/codex-ratification/<session>/`
agents/recruitment/cash-conductor/README.md:35:## Ratification
docs/architecture/cortexos-primitive-status.md:12:2. **The four `bus/kb-*.sh` files we plan to shadow have different names than the master brief states.** Master brief §3.4 names `kb-search.sh / kb-add.sh / kb-update.sh / kb-list.sh`. The actual files at SHA `c21fbfe` are `kb-collections.sh / kb-ingest.sh / kb-query.sh / kb-setup.sh`. The brain-replacement seam (§3.4 + §5) needs reconciliation before Codex ratification.
docs/architecture/cortexos-primitive-status.md:184:2. **The four `kb-*.sh` files we plan to shadow have different names than the master brief states.** Master brief §3.4 lists `kb-search.sh`, `kb-add.sh`, `kb-update.sh`, `kb-list.sh`. The actual files at `packages/harness/cortextos/bus/` are `kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`. This is the brain-replacement seam — the master brief's named files do not exist at SHA `c21fbfe`. Either the brief was written against a different cortextOS version, or the four shadow points need to be revised. This is a Day-7 Codex-ratification-blocking discrepancy.
docs/architecture/cortexos-primitive-status.md:504:- **Day-7 spec drifts for Codex ratification:** the chokidar mention in master brief §2.4 row 3 and the four `kb-*.sh` filenames in master brief §3.4 do not match the verified SHA. Both need a one-line correction or a §3.4 re-scoping decision.
docs/operations/w4-bilateral-pass-6-agent-md.md:22:bash scripts/run-codex-ratification.sh agent-bundle agents/recruitment/<agent>/agent.md
docs/operations/w4-bilateral-pass-6-agent-md.md:27:**Source of these findings:** the latest round per agent in `logs/codex-ratification/20260524T*/`. Verbatim text quoted from each Codex response.
docs/operations/w4-bilateral-pass-6-agent-md.md:46:**Round:** R16 post-v0.3 (Pre-Build-Round-16-Reviewed). Log: `logs/codex-ratification/20260524T130117Z-63874/`.
docs/operations/w4-bilateral-pass-6-agent-md.md:82:**Round:** R11 post-v0.3. Log: `logs/codex-ratification/20260524T174156Z-10120/`.
docs/operations/w4-bilateral-pass-6-agent-md.md:98:  - **Codex says:** "Lines 135-137 say Janitor queries the `recent_edit` v0.2 table directly, but v0.2 access lists only voice-drift-canary, Concierge, and LoRA; Janitor R access is added in v0.3 supplement §2. Fix the citation to v0.3 supplement and add v0.3 schema/migration ratification as a §8 prerequisite."
docs/operations/w4-bilateral-pass-6-agent-md.md:112:**Round:** R8 post-v0.3. Log: `logs/codex-ratification/20260524T151757Z-97714/`.
docs/operations/w4-bilateral-pass-6-agent-md.md:122:  - **Codex says:** "It flips to Accepted on ratification/founder questions/ADR-006 before the W9 bundle exists, but the agent-bundle skill treats Accepted as production-ready after sibling files + fixtures exist and pass gates. Fix by keeping this scaffold Proposed after ratification, and make Proposed → Accepted depend on W9 build completion: `tools.yaml`, `context.sh`, `validate.sh`, `cycle.sh`, `cleanup.sh`, and 3 fixtures."
docs/operations/w4-bilateral-pass-6-agent-md.md:136:**Round:** R17 post-v0.3. Log: `logs/codex-ratification/20260524T145439Z-74254/`.
docs/operations/w4-bilateral-pass-6-agent-md.md:147:  - **Likely:** FIX-IN-PLACE. Add to §8 prereqs: (a) D1 resolved, (b) Concierge autosend-bridge live. Note: D1 is W4 queue #4 — this finding documents the dependency in the agent.md but does NOT block ratification of the scaffold (Status will be Proposed→Pre-Build pending D1).
docs/operations/w4-bilateral-pass-6-agent-md.md:160:**Round:** R3 post-v0.3. Log: `logs/codex-ratification/20260524T174401Z-12038/`.
docs/operations/w4-bilateral-pass-6-agent-md.md:164:  - **Codex says:** "Lines 76-80 list `brief.start_date`, `placement.week_1_status_note`, and `opportunity.sector` as canonical/schema-verified, but `vertical-schema.yaml` uses `start_date_target` and the v0.3 supplement explicitly says `week_1_status_note` became `week_1_status_vault_path` and `opportunity.sector` is not yet in schema. Fix the field table to use schema-backed names or land the missing supplement before ratification."
docs/operations/w4-bilateral-pass-6-agent-md.md:189:  - **Likely:** FIX-IN-PLACE. Either add transcript-provider examples + payload to catalogue line 324-329 (small edit; touches `_shared`, needs ratification of catalogue change too), OR register a new code `ESC_TRANSCRIPT_FETCH_FAIL`. Catalogue extension is cleaner.
docs/operations/w4-bilateral-pass-6-agent-md.md:196:**Round:** R3 post-v0.3. Log: `logs/codex-ratification/20260524T174513Z-13185/`.
docs/operations/w4-bilateral-pass-6-agent-md.md:212:  - **Codex says:** "Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria. Either keep the 30-minute SLA as Gate A, or add the Concierge-Gate-A ADR ratification as an explicit Accepted blocker."
docs/operations/w4-bilateral-pass-6-agent-md.md:248:- [ ] `bash scripts/run-codex-ratification.sh agent-bundle agents/recruitment/<agent>/agent.md` returns `RATIFIED`
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:23:| 7 | **Master-brief-drift-accumulation** — eight ADR-driven edits + one Day-4 Postgres-rename + multiple Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all nine edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Codex ratifies the commit alongside the ten+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 + `bullhorn-integration-path.md` + `sequencing-target.md` + `brain-ui-scope.md` + Day 4 runbook §0.1. **Updated Day 4 (2026-05-17):** edit count rose from 8 to 9 with Day-4 Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations" — verified from Day-4 execution against NBG1 because FSN1 was unavailable at provisioning time). **Citation audit 2026-05-18:** earlier drafts also cited master brief §10.4 as a Hetzner/cost-target section; verified §10.4 is the Codex exclusion list ("What never goes through ratification") and contains no Hetzner or cost-target content. Edit 9 scope corrected to line 477 only. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:35:| 14 | **Scripts authored Days 8+ never executed end-to-end against live until 2026-05-23** — Day-9 cohesion review claimed "foundation is sound for Diagnostic build" based on code+docs review, but no helper / migration / script had been exercised against live Postgres. Day-12 first execution surfaced 6 distinct drifts (password, DB name, TRIGGER grant, GUC rename, missing tenants row, table ownership/RLS-bypass). | High (now historical; mitigated) | High at time of discovery — any of the 6 could have manifested at first pilot LOI as silent failure or data leak. | Future script/migration authoring without an explicit "first live execution against migration-test tenant" milestone listed in the plan. | Day-12 closed loop: live migration 24/24 + tenancy audit 24/24. Future: every new script touching live Postgres must include a verified-on-VPS milestone in its acceptance criteria, not just unit-test-layer green. Day-9 cohesion review template updated to require live verification before "foundation verified" verdict. | **Mitigated.** Discovery surfaces a class lesson: ratification at code-and-docs layer is necessary but not sufficient; live execution is the third leg. |
docs/RISK-REGISTER.md:36:| 13 | **GUC name drift between executed Day-4 reality and Days-8-11 codebase** — Day-4 §6.3 provisioned live RLS policies using `current_setting('app.current_tenant', TRUE)` (verified Day-11 via `\dp entities`), but Days 8-11 code (hook-helpers.sh, voice-loader.sh, run-live-migration.sh, run-tenancy-audit.sh, ifos-pii-purge.sh, v0.1-to-v0.2.sql) + Day-9 ratified docs (tenancy-invariants.md, architecture-cohesion-review.md) wrote `ifos.tenant_slug` instead. Three rounds of Codex ratification + cohesion review didn't catch it because no artefact in Days 8-11 was ever executed end-to-end against live Postgres. Surfaced 2026-05-22 during first live migration attempt (CREATE TRIGGER failed for separate privilege reason; founder ran `\dp entities` while diagnosing; the GUC mismatch was visible in policy output). | ~~High~~ → Low post-remediation | High (every Days-8-11 write to live Postgres would have silently failed RLS or returned 0 rows — silent data leak risk if ever inverted) | Any helper / migration / script execution against live Postgres that uses an RLS-protected table and returns surprising row counts; first end-to-end live execution of any of the 6 affected scripts; future `\dp` audit revealing additional drift. | Day-11 remediation (this commit): mechanical rename `ifos.tenant_slug` → `app.current_tenant` across 15 files; 29/29 helper tests still pass; v0.1-to-v0.2 migration verified to use the corrected GUC. Future: run `bash scripts/run-tenancy-audit.sh` post-migration to verify all 12 invariants against the live database. | **Mitigated in this commit pending live re-run of v0.2 migration + tenancy audit verification.** |
docs/RISK-REGISTER.md:56:- 2026-05-22 (Day 11) — **Codex Round 2 autonomous ratification complete.** 26 artefacts reviewed; 17 RATIFIED / 9 REJECTED. Manifest §1.7 appended and full outputs written to `logs/codex-ratification/round-2-autonomous/`. D5 skill softening ratified. Bullhorn gate disagreement rejected because the promised source-doc sharpening did not land. Autosend policy, v0.2 supplement, approval bridge, PII purge runbook/script/forward migration, and tenancy audit script remain rejected. **New Risk #11** added for transactionless `SET LOCAL` usage across live DB scripts/helpers. **New Risk #12** added for the PII purge migration/script mismatch with `recent_edit.original_text NOT NULL`.
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8 evening) — **Codex ratification Round 1 complete + remediation landed.** 16 artefacts reviewed (Cluster A+B+C); 2 RATIFIED (ADR-004, brain-ui-scope); 14 REJECTED. Remediation commit `2b287d3` incorporates 13 of 14 rejections (Bucket 1 cosmetic + Bucket 2 ADR-004 back-propagation + Bucket 3 structural). 2 disagreement docs filed (`codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` + `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`). 5 founder decisions surfaced (D1-D5 in `2026-05-20-codex-round-1-founder-decisions.md`). **NEW Risk #10 candidate surfaced by Codex** (recent_edit raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation) — see Risk #10 below. Manifest queue updated with per-artefact Round-1 verdicts (`docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5). Round 2 expected to take 14 REJECTED → 0-2 REJECTED.
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/RISK-REGISTER.md:69:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
docs/RISK-REGISTER.md:70:- 2026-06-03 (W5 Day 34) — **W5 CLOSED.** All 5 v1.0 agent bundles (CC + Concierge + Janitor + Scribe + Sourcing Scout) at SKELETON tier (6 files + 3 fixtures each); 3 new MCP scaffolds (@ifos/bullhorn + @ifos/workos + @ifos/granola); v0.4 schema supplement LIVE on production VPS (peer-auth migration apply 2026-06-03; 6/6 trigger acceptance tests passed). No new risks materialised from W5. **Risk #3 update:** founder confirmed Jack lane "on track" 2026-06-03; Trigger 1 fires today (calendar gate), founder closes LOI directly — Risk #3 status unchanged at HIGH/MATERIALISED pending actual signature. **Pre-existing test flake surfaced (NOT a new risk):** `@ifos/diagnostic-generator` `tests/generate.test.ts` § "composes a §12 conversation opener that anchors to a real signal" failing since 2026-06-01 commit `2688b6a` — LLM non-determinism (test fixture "Test Anchor Firm" triggers legitimate disclaimer pattern from the LLM; test regex `/Hi.*?Test Anchor Firm|Hi —/` doesn't match). Doesn't affect production behaviour (production uses real firm names with real Companies House data). Three fix paths queued for a future session (relax regex / mock LLM / use real firm name); deferred per Karpathy surgical-changes discipline + /goal STOP rule (out of W5 marathon scope). **W6+ external dependencies:** Bullhorn dev-support reply (~by 2026-06-09); Reed + CV-Library + Xero + QB + TrueLayer commercial signups per `docs/operations/founder-api-signups-2026-06-03.md`; Granola browser OAuth dance (requires Claude Code restart); WorkOS staging key; Cluster F-tris Codex ratification (manifest entry added). vitest at W5 close: 259/260 (99.6%) across 11 packages.
docs/operations/decision-log.md:26:| `267913b` | `.codex/ratification/review-mcp-connector.md` Codex skill | 151 lines, 7 checks layered on SKILL.md; output format identical to existing skills |
docs/operations/decision-log.md:60:- **Cluster F manifest add** — add Xero + QuickBooks + Open Banking + Cash Conductor to `scripts/run-codex-ratification.sh` and trigger founder-side ratification run
docs/operations/decision-log.md:132:Codex finally ran (`--cluster E`) and returned **RATIFIED: 4/9, REJECTED: 5/9**. Full Codex report: `logs/codex-ratification/manual-cluster-e/REPORT.md`.
docs/operations/decision-log.md:156:**Founder decision (2026-05-31): Fix + STOP — no Round 4.** Migration has had 3 round-trips (R1 → R2 → R3) and applying-and-re-running would be a 4th, crossing master brief §10.3 step 5 ≤2-cap further. Codex spelled out the exact `to_regclass` fix; it's applied at `0f4ce8d`. Re-ratification of the rollback path is deferred to its next natural touch (live VPS apply OR v0.4 supplement work) and recorded in the W4 backlog. Net effective state: **8/9 Codex-RATIFIED + 1 with the latest R3 fix applied = 9/9 in substance**.
docs/operations/decision-log.md:160:- [ ] **Migration rollback v0.3-to-v0.2.sql — final Codex re-ratification.** R3 finding (to_regclass guards) fixed at `0f4ce8d` but not re-ratified per §10.3 ceiling. Re-run `--cluster E` next time the migration is touched (live VPS application, v0.4 supplement work, OR any rollback path change). Expect RATIFIED on submission.
docs/operations/decision-log.md:173:## W4 Day-21 (2026-05-27) — ratification remediation + harness fix
docs/operations/decision-log.md:175:**Root cause of the "stuck" state (three compounding issues):** (a) commit `75ccc5f` (2026-05-24) flipped statuses to RATIFIED prematurely; the R19 bilateral pass reverted them to Proposed, but THIS file was committed before R19 (`ff4155f`) and never updated — so it told an optimistic, stale story. (b) The `run-codex-ratification.sh` verdict-count parser counted numbered lines across the entire transcript, reporting 41/52/55 issues when the real counts were 2-5. (c) Those phantom counts made the 8 artefacts look catastrophically broken when they were ~4 mechanical fixes each.
docs/operations/decision-log.md:179:1. **Parser bug** — `scripts/run-codex-ratification.sh` now counts numbered issues only inside the final verdict block (matching the detection awk). Re-derived against the 8 existing reviews: **4/3/4/4/3/2/4/5** (was 41/21/41/52/49/51/55/55). shellcheck clean.
docs/operations/decision-log.md:199:**Remaining gates:** (a) founder runs the Codex re-ratification batch over the 9 artefacts (`--cluster E`) — now with trustworthy counts; expect RATIFIED or ≤2 residual/artefact; (b) founder confirms/flips the 4 decisions above; (c) v0.3 migration application (unchanged from Day-20 queue item #1).
docs/operations/decision-log.md:203:Run because the founder hit Codex usage limits. This is the strongest assurance available without the independent second model; it is NOT a replacement for Codex ratification (master brief §10.5), which stays a deferred gate.
docs/operations/decision-log.md:226:3. `bd3c145 fix(janitor-r12 + v0.3-supplement.0.1)` — Finding 4 closed via v0.3 supplement §4 amendment adding `janitor_dedup_threshold` + `janitor_last_run` declarations; agent.md citations updated. Findings 1+2+3 already in post-R11 commit `e5a2c74`. **v0.3 supplement amended — needs re-ratification**.
docs/operations/decision-log.md:230:7. `26551c8 feat(ADR-007 + concierge-r4)` — ADR-007 (Concierge Gate A 30-min SLA hybrid) drafted; analogue of ADR-006; closes Concierge R3 Finding 3 structurally. Step 11 `hh_decision_action` added. **Closes W4 founder-action queue item #3** (drafted; ratification gates Concierge Accepted).
docs/operations/decision-log.md:236:| Diagnostic | Pre-Build-Round-17-Bilateral-Applied | 5 | 0 (4 fixed + 1 REJECT-CODEX) | Codex R18 re-ratification |
docs/operations/decision-log.md:237:| Cash Conductor | Pre-Build-Round-18-Bilateral-Confirmed | 3 | 0 (all in `9ae6874`) | Codex R19 re-ratification |
docs/operations/decision-log.md:238:| Sourcing Scout | Pre-Build-Round-9-Bilateral-Applied | 3 | 0 (all in `d1f4c53` + R9 polish) | Codex R10 re-ratification |
docs/operations/decision-log.md:239:| Janitor | Pre-Build-Round-12-Bilateral-Applied | 4 | 0 (3 in `e5a2c74` + 1 via supplement) | Codex R13 re-ratification |
docs/operations/decision-log.md:240:| Scribe | Pre-Build-Round-4-Bilateral-Applied | 5 | 0 (4 in `db56336` + 1 polish) | Codex R5 re-ratification |
docs/operations/decision-log.md:241:| Concierge | Pre-Build-Round-4-Bilateral-Applied | 4 | 0 (3 in `f79c018` + 1 via ADR-007) | Codex R5 re-ratification + ADR-007 ratified |
docs/operations/decision-log.md:252:- **All 6 agent.md scaffolds:** post-v0.3 first + second re-ratification rounds run; finding counts:
docs/operations/decision-log.md:270:- [ ] **Per-agent build slices (W5-W13)** — each agent's full bundle delivery + ratification cycle at its build wave.
docs/operations/decision-log.md:275:2. **Bilateral pass on 6 agent.md scaffolds** — **DONE.** 24 residuals dispositioned across 7 atomic commits today. All 6 at Pre-Build-Round-N-Bilateral-Applied/Confirmed. Founder authorizes Codex re-ratification (6 agent.md + v0.3 supplement amendment + ADR-007 = 8 ratification runs) to close to RATIFIED.
docs/operations/decision-log.md:276:3. **Future ADR — Concierge Gate A 30-min SLA hybrid** — **DRAFTED.** `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md`. Analogue of ADR-006. Awaits Codex `review-architecture-decision` skill ratification + founder Accept.
docs/operations/decision-log.md:280:7. **NEW: Codex re-ratification round** — 8 artefacts: 6 agent.md + v0.3 supplement amendment + ADR-007. Founder authorizes; can run as one batch via `bash scripts/run-codex-ratification.sh`.
docs/operations/decision-log.md:286:- Bundle code complete; Codex R17 closures applied; R18 re-ratification is the remaining gate. **Diagnostic is the closest agent to RATIFIED status.**
docs/operations/decision-log.md:321:- [ ] **ADR-004** (Phase 2 follow-up) — ratify CLI surface: keep standalone `ifos-render-agent` OR build `ifosctl` shim that multiplexes. Founder + Codex review at first ratification round.
docs/operations/decision-log.md:326:- [x] **`.codex/ratification/*.md` skills build** — complete enough for Round 1 + Round 2 execution (`SKILL.md`, architecture-decision, schema-change, postgres-migration used in Round 2). Remaining type skills can be built when new artefact classes enter the queue.
docs/operations/decision-log.md:349:- [ ] **R8**: Adapter + brain-replacement boundary automation — `review-agent-bundle.md` Codex skill at Diagnostic W3
docs/operations/decision-log.md:399:Week-3 /goal at `docs/operations/goal-week-3-polish-and-scaffold.md` executed end-to-end. **All 14 steps run.** Founder arbitration required on the 5-category Codex disposition framework before the 6 agent.md ratifications close as RATIFIED.
docs/operations/decision-log.md:416:- `825ebd4` review-agent-bundle.md skill built (closes Issue 5; unblocks Phase 2)
docs/operations/decision-log.md:440:**Founder action:** single decision (approve framework) → unblocks mechanical remediation pass → Round 5 re-ratification expected RATIFIED.
docs/operations/decision-log.md:454:- ⚠ v1.0-kill-criterion.md Trigger 2 — Diagnostic ratification needs single founder arbitration (no engineering blocker)
docs/operations/decision-log.md:472:**Trigger 2 status:** Diagnostic ratification needs founder arbitration; engineering work complete. 21-day buffer to 2026-06-14 deadline preserved.
docs/operations/decision-log.md:492:- **Step 7** ⏸ — Codex Round 4 Phase 1 (Diagnostic-only): founder runs `bash scripts/run-codex-ratification.sh --round 4 --subset diagnostic`
docs/operations/decision-log.md:493:- **Step 13** ⏸ — Codex Round 4 Phase 2 (full): founder runs `bash scripts/run-codex-ratification.sh --round 4 --full`
docs/operations/decision-log.md:498:All 6 v1.0 agents now have ratified-or-pending-ratification output contracts (master brief §1 Rule 1 satisfied):
docs/operations/decision-log.md:527:**Codex Round 4 ratification queue:** 11 items prepared in manifest §1.10. Phase 1 (6 items) ready when founder runs Step 7; Phase 2 (5 items) ready when founder runs Step 13. Hard ceiling per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 max).
docs/operations/decision-log.md:533:3. **Step 7 (~45 min):** Run Codex Round 4 Phase 1 (Diagnostic-only ratification) once Steps 2+4 + my Step 5 re-smoke complete
docs/operations/decision-log.md:534:4. **Step 13 (~2 hours):** Run Codex Round 4 Phase 2 (full ratification of 5 new scaffolds)
docs/operations/decision-log.md:539:**Trigger 2 status (per `v1.0-kill-criterion.md` §2):** Diagnostic shipped end-to-end Day-13; Codex Round 4 Phase 1 ratification clears Trigger 2 well before 2026-06-14 deadline (currently 21 days buffer).
docs/operations/decision-log.md:572:**This is the load-bearing close.** First end-to-end execution of run-live-migration.sh + run-tenancy-audit.sh against live Postgres surfaced + fixed 6 Day-4 documentation/code drifts that survived 3 rounds of Codex ratification + Day-9 cohesion review (all of which audited code/docs but never executed against live).
docs/operations/decision-log.md:623:First end-to-end execution of `bash scripts/run-live-migration.sh` against live VPS exposed 4 Day-4 documentation/code drifts that had survived 3 rounds of Codex ratification + the Day-9 cohesion review. **Pattern: scripts authored Days 8-11 were never run against live until today, so divergence from Day-4-executed reality went undetected.**
docs/operations/decision-log.md:661:- Codex bundle ratification via `review-agent-bundle.md` (skill not yet built; lazy per execution plan)
docs/operations/decision-log.md:667:**Codex Day-7 ratification queue:** grows by 1 (agent.md draft); ratifies individually via `review-architecture-decision.md` skill OR as part of full bundle via `review-agent-bundle.md` at W3 build close.
docs/operations/decision-log.md:686:### Day 11 (2026-05-22) — Codex Round 2 autonomous ratification closure
docs/operations/decision-log.md:688:Round 2 closed in `logs/codex-ratification/round-2-autonomous/`:
docs/operations/decision-log.md:696:- `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.7 appended with the 26 Round-2 verdicts
docs/operations/decision-log.md:737:Commit `2b287d3`. 16 files, +429 lines. Closes 13 of 14 Codex Round-1 rejections from `logs/codex-ratification/manual-run/` first ratification pass (which was 2 RATIFIED + 14 REJECTED of 16 total).
docs/operations/decision-log.md:776:**Codex Day-7 manifest:** updated with per-artefact Round-1 verdict + disposition (new §1.5 section in `docs/decisions/2026-05-18-codex-ratification-manifest.md`).
docs/operations/decision-log.md:808:- Codex Day-7 ratification queue: 21 → 33 items
docs/operations/decision-log.md:860:### Day 7 (2026-05-20) — Single-sentence test 3-of-5 + atomic-correction commit + Codex ratification manifest
docs/operations/decision-log.md:884:2. **Day-7 close commit (this commit)** — single-sentence test artefact + Codex ratification manifest + state-file updates:
docs/operations/decision-log.md:886:   - `docs/decisions/2026-05-18-codex-ratification-manifest.md` (Reference, 19+ items queued)
docs/operations/decision-log.md:894:**Codex Day-7 ratification execution:** deferred per founder Option C. Manifest produced today; execution waits for (a) `.codex/ratification/*.md` skills built (Day 1 task gap surfaced) AND (b) Week 0 close achievable. Schedule documented in manifest §4.
docs/operations/decision-log.md:913:- **15 fabricated "master brief §10.4" references** across 5 files. Master brief §10.4 is "What never goes through ratification" (Codex exclusion list), not a Hetzner location or cost-target section. Root cause: Day-4 runbook §1.4 invented the citation; propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1), RISK-REGISTER (2), current-priorities (1) by citation transitivity rather than re-verification against master brief.
docs/operations/decision-log.md:930:**Artefact landed (Status: Proposed pending Codex Day-7 ratification):**
docs/operations/decision-log.md:960:**Artefacts landed (both Status: Proposed pending Codex Day-7 ratification):**
docs/operations/decision-log.md:1119:Commit message: `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1 + Day-5 path drift + decision_log.phase render`. Single Codex ratification on Day 7.
docs/operations/decision-log.md:1123:## Queued for Codex ratification (Day 7)
docs/operations/decision-log.md:1125:Per master brief §10.6 first ratification run — Day 7 added items 20 + 21 + the landed atomic-correction commit `0e5b2b4`. Total: 21 items + 1 commit. **Execution deferred** to Week 0 extension period (skills + Q1 unblocker both required first). See `docs/decisions/2026-05-18-codex-ratification-manifest.md` §3 + §4 for the gap + schedule.
docs/operations/decision-log.md:1146:20. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** (Status: Reference) — NEW Day 7 2026-05-20 (this manifest itself; lists 19+ ratification queue items + gap + schedule)
docs/operations/decision-log.md:1159:- **Day 3 ratification**: master brief §8.2 sequence ratified verbatim — Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 (Hire-#1-anchored) → Sourcing Scout W9 → Concierge W10-13
docs/operations/decision-log.md:1172:A full chapter closed today: 13 Codex ratification rounds across clusters F, Fbis, G; one strategic vendor pivot (Bullhorn marketplace deferred); one materialised-but-mitigated vendor risk (Proxycurl shutdown). The cluster F + Fbis + G arc earned its own decision-doc at `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` covering the partial-ratification outcome (1 ratified + 5 proposed-with-disagreement-on-file across 6 artefacts).
docs/operations/decision-log.md:1176:1. **Codex hard-stop precedent codified as repeatable pattern.** After 13 rounds across F + Fbis + G, the founder + Claude established a hard-stop rule that fires when (a) my "this should converge" predictions are wrong N times in a row + (b) the Nth round still surfaces NEW issues + (c) the diminishing-returns line is clearly hit. The escape valve is **partial-ratification with structured disagreement docs** rather than infinite rounds. Cluster F closed at 1 ratified + 2 disagreement-on-file (xero/QB/OB); cluster Fbis + G closed at 0 ratified + 3 disagreement-on-file (CC agent-bundle + Concierge agent-bundle + D1-B decision-doc). **The 7 substantive bugs Codex caught across the arc validate the value** (401-loop bug + 401-double-refresh + bullhorn_activity_log_write registration + Step 15 helper signature + voice threshold completeness + anti-dup query mechanism + schema-before-code violation + false Day-4 _secrets.env claim). Real bugs caught: ✅. Infinite-round productivity loss avoided: ✅. Re-trigger condition for partial-ratification: W7-8 + W10-13 build slices reconcile agent.md ↔ code drift naturally when both files are touched in same workflow.
docs/operations/decision-log.md:1182:4. **Partial-ratification framework as a repeatable build pattern.** Disagreement docs at `docs/decisions/codex-disagreement-2026-06-02-*.md` (5 docs total across cluster F + Fbis + G) established the shape: artefact-Status moves to "Proposed-with-disagreement-on-file"; disagreement doc names the issue, the counter-argument, the re-trigger conditions, and what would change the call. This pattern can be reused for any future Codex round where the marginal value of round N+1 is low relative to its cost. Build progress is unblocked at the disagreement-doc-in-tree state; cluster re-runs happen when the natural trigger (build slice, vendor decision, skill hardening) fires.
docs/operations/decision-log.md:1199:(nothing structurally — cluster F + Fbis + G partial-ratification is intentional; build slices re-trigger ratification naturally; Bullhorn dev-support reply expected 2-5 business days; LinkedIn vendor decision queued for W8-9)
docs/operations/decision-log.md:1220:3. **Vendor delta documentation pattern for agent.md ↔ deployed-reality drift.** Three agent bundles (Scribe + Sourcing Scout + earlier Concierge) have explicit deltas between their RATIFIED agent.md (CONTRACT) and the deployed SKELETON (vendor pivots, deferred sources, env-var fallbacks). The Reading-discipline note pattern (originated 2026-06-02 per Codex Fbis-R3 closure for CC + Concierge) extended in this session to document not just the SKELETON-vs-CONTRACT gap but the specific deltas (Scribe: webhook → polling per Granola pivot; Sourcing Scout: 4 sources → 3 active per Proxycurl shutdown; both: env-var fallbacks vs canonical SELECT path even though v0.4 supplement made the schema-clean paths available). W6+ ratification updates each agent.md to match deployed reality.
docs/operations/decision-log.md:1235:- Cluster F-tris Codex ratification (manifest entry added in this commit)
docs/operations/goal-week-6-execution-plan.md:64:20. **Cluster F-tris re-trigger entry** — agent.md ↔ code drift naturally reconciled by W6 wiring; partial-ratification disagreement docs from F + Fbis + G can be re-evaluated.
docs/operations/goal-week-6-execution-plan.md:164:- Re-evaluate cluster F-tris partial-ratification docs (some may close as agent.md ↔ code drift is naturally reconciled by W6 live wiring)
docs/operations/goal-week-6-execution-plan.md:185:- Codex ratification round attempted in this plan → NOT ALLOWED. Codex re-trigger happens after W6 close (cluster F-tris re-evaluation) per master brief §10.5 ceiling discipline.
docs/operations/goal-week-6-execution-plan.md:206:W5 close added the cluster F-tris manifest entry (per scripts/run-codex-ratification.sh). W6's natural agent.md ↔ code reconciliation (when both files are touched in same workflow per the disagreement-doc framework) will resolve some of the disagreement-on-file artefacts.
docs/operations/goal-week-6-execution-plan.md:213:W7+ window for founder-triggered cluster F-tris run remains; expect partial-ratification at the Sourcing Scout layer only.
agents/recruitment/janitor/README.md:32:## Ratification
agents/recruitment/janitor/README.md:34:Per `.codex/ratification/review-architecture-decision.md` skill. Queued for Codex Round 4 Phase 2 (Day 20).
docs/operations/parallel-agent-build-method.md:54:   Codex ratification PASS + founder sign-off.
docs/operations/parallel-agent-build-method.md:64:2. **Review-subagent** — uses the existing `.codex/ratification/review-agent-bundle.md`
docs/operations/parallel-agent-build-method.md:66:3. **Codex ratification** (`scripts/run-codex-ratification.sh`) + **founder merge sign-off.**
docs/operations/parallel-agent-build-method.md:144:3. **Review tier** — review sub-agent + Codex ratification must pass on the branch.
agents/recruitment/diagnostic/README.md:33:3. **Provides a ratification target** — Codex can review `agent.md` during a Round-4+ pass without W3 build being complete
agents/recruitment/diagnostic/README.md:38:Per `.codex/ratification/review-agent-bundle.md` (skill not yet built; lazy per execution-plan §3): this directory ratifies as a unit when the full 6-file + 3-fixture bundle exists.
agents/recruitment/diagnostic/README.md:40:Until then, individual files (this README + agent.md) ratify via `review-architecture-decision.md` skill on their own ratification queue position.
docs/operations/w4-day-20-founder-runbook.md:28:data" requires Codex ratification. The migration SQL is already RATIFIED
docs/operations/w4-day-20-founder-runbook.md:36:bash scripts/run-codex-ratification.sh postgres-migration scripts/run-v0.3-migration.sh
docs/operations/w4-day-20-founder-runbook.md:122:`bash scripts/run-codex-ratification.sh agent-bundle agents/recruitment/<agent>/agent.md`.
agents/recruitment/janitor/agent.md:212:Per catalogue `escalation-codes.md` ESC_GATE_B_MISS trigger (Janitor example: "dedup confidence <15% AND field-completeness uplift <10%"): `ESC_GATE_B_MISS` fires only when BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND completeness-improvement <10%) → flag for operator review (heuristic tuning may be needed; not a kill). Single-threshold misses are tracked in the day-30 report (§3 Output 1 row 6) and inform tenant-level quality review but do NOT fire ESC. Sensitivity choice: strict AND-trigger reduces false alarms; tightening to OR-trigger requires a catalogue amendment + re-ratification.
agents/recruitment/janitor/agent.md:290:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/janitor/agent.md:307:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/janitor/agent.md:318:- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)
agents/recruitment/janitor/agent.md:320:Until then: this document is a forward-looking scaffold. Conservative pre-build clarity — not a binding contract until ratification.
agents/recruitment/diagnostic/tools.yaml:5:# Ratifies as part of full bundle via review-agent-bundle.md skill.
docs/operations/goal-option-c-diagnostic-end-to-end.md:55:9. **State files updated:** `current-priorities.md` Shipped section + `RISK-REGISTER.md` Risk #2 status (Diagnostic ratification path proven).
docs/operations/goal-option-c-diagnostic-end-to-end.md:252:- **Decision:** Week 3 (Days 13-20) repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build. Week 4 (Days 21-27) repurposed from Diagnostic-build to Diagnostic-polish + Codex ratification + (conditional) Bullhorn-MCP-build if A+B answered.
agents/recruitment/concierge/README.md:40:## Ratification
agents/recruitment/sourcing-scout/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fix applied. R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`. R19 (2026-05-24): adds `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Awaits Q1 LOI + Bullhorn Sub-decisions A+B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + Reed + CV-Library commercial signups + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:390:Per `.codex/ratification/review-agent-bundle.md` skill (built 2026-05-24, commit `825ebd4`): this agent.md ratifies when Codex review-agent-bundle returns RATIFIED verdict on the SCAFFOLD shape (output contract + workflow + gates + escalation + dependencies). **Ratification of the scaffold does NOT make it Accepted.** Per the agent-bundle skill, Accepted means production-ready — which requires all sibling bundle files + fixtures + first production run.
agents/recruitment/sourcing-scout/agent.md:394:1. **Proposed → Ratified-as-Scaffold** when Codex review-agent-bundle returns RATIFIED on this agent.md alone. Pre-build scaffold confirmed shape-correct; the document is a binding contract for the W9 build slice.
agents/recruitment/concierge/agent.md:3:**Status:** Proposed-with-disagreement-on-file (`docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` — bundle-layer Codex ratification deferred to W10-13 build slice; contract-layer ratification was achieved in W3 cluster E).
agents/recruitment/concierge/agent.md:469:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/concierge/agent.md:473:- **✅ ADR-007 (Concierge Gate A 30-min SLA hybrid) ACCEPTED + RATIFIED** — Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3 per `.codex/ratification/review-architecture-decision.md` skill (commit `c862c77`). Closes the documented deviation from ULTRAPLAN A6 line 566 wording; agent.md's Gate B framing of the 30-min SLA is now the canonical disposition. This Status-flip blocker is satisfied.
agents/recruitment/concierge/agent.md:484:- Codex re-ratifies post-build via `review-agent-bundle.md` skill
agents/recruitment/concierge/agent.md:486:Until then: this document is a forward-looking scaffold. Concierge is the most complex v1.0 agent; its ratification cycles may surface architectural decisions not visible at scaffold stage. Founder review at each iteration is expected.
docs/operations/goal-w4-day-26-2026-06-01.md:18:8. Cluster F manifest entry in `scripts/run-codex-ratification.sh` — xero + quickbooks + open-banking via `mcp-connector` skill. Cash Conductor bundle queued for next manifest update when scaffold lands.
docs/features/agent-build/00-ORCHESTRATOR.md:29:4. **Review tier** — a review sub-agent + `bash scripts/run-codex-ratification.sh` (where configured) judge the branch against its spec + adjacent contracts.
agents/recruitment/sourcing-scout/README.md:29:## Ratification
docs/features/agent-build/01-LAUNCH.md:21:- The 5 gates are non-bypassable (method §4): worktree isolation; .githooks/pre-commit; scripts/build-gate.sh green before merge; review sub-agent + run-codex-ratification.sh; human merge gate. Skip-permissions removes the per-command prompt, NOT these.
docs/operations/codex-ratification-guide.md:1:# Codex ratification — practical guide
docs/operations/codex-ratification-guide.md:4:**Audience:** Founder (Maddox). This guide tells you how to run Codex ratification on the IFOS codebase end-to-end.
docs/operations/codex-ratification-guide.md:6:- `docs/operations/codex-ratification-execution-plan.md` — the WHAT/WHEN (queue, schedule, cost)
docs/operations/codex-ratification-guide.md:8:- `.codex/ratification/SKILL.md` + `review-*.md` — what Codex actually reads
docs/operations/codex-ratification-guide.md:9:- `scripts/run-codex-ratification.sh` — the driver
docs/operations/codex-ratification-guide.md:13:## §1 — Mental model: what Codex ratification actually is
docs/operations/codex-ratification-guide.md:17:**Codex ratification is the second-pair-of-eyes loop.** A different model (`gpt-5-codex` from OpenAI) reads each artefact you've built. It applies a known checklist (the SKILL.md files you'll see below) and returns one of two verdicts:
docs/operations/codex-ratification-guide.md:51:4. **The SKILL.md files prime Codex** — when you run a ratification, the wrapper builds a prompt that says: "Here is the IFOS top-level skill. Here is the type-specific skill. Here is the artefact. Apply both skills."
docs/operations/codex-ratification-guide.md:54:The wrapper at `scripts/run-codex-ratification.sh` automates this: assembles the prompt, invokes `codex exec` non-interactively, captures output, parses the verdict, writes an audit row to `decision_log`.
docs/operations/codex-ratification-guide.md:99:For IFOS ratification work, the API key path is simpler — paste your key into `~/.zshrc` (or wherever you keep secrets locally):
docs/operations/codex-ratification-guide.md:110:ls .codex/ratification/
docs/operations/codex-ratification-guide.md:122:Three more skills (`review-agent-bundle.md`, `review-mcp-connector.md`, `review-harness-bump.md`) are deferred per the execution plan §3 — they're lazy, built at first need.
docs/operations/codex-ratification-guide.md:127:bash scripts/run-codex-ratification.sh --list-clusters
docs/operations/codex-ratification-guide.md:145:bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/operations/codex-ratification-guide.md:150:1. **Pre-flight** — verifies `codex` is on PATH + executes, `.codex/ratification/SKILL.md` exists, session log dir created.
docs/operations/codex-ratification-guide.md:151:2. **Prompt assembly** — concatenates the top-level skill, the type-specific skill, the artefact content, and the output-contract instructions into a single prompt at `logs/codex-ratification/<session-id>/<artefact-slug>.prompt.md`.
docs/operations/codex-ratification-guide.md:154:5. **Audit row write** — inserts a row into `decision_log` with `tenant_slug='ifos-meta'`, `agent_name='_codex_ratifier'`, `phase='output'`, `outcome=<RATIFIED|REJECTED>`, `payload` includes the artefact path, skill used, issue count, session ID, and the full Codex response text. Falls back to `logs/codex-ratification.jsonl` if no live DB.
docs/operations/codex-ratification-guide.md:160:  ✓ Prompt assembled at logs/codex-ratification/20260520T143000Z-12345/...prompt.md
docs/operations/codex-ratification-guide.md:161:  ✓ Codex returned response (logs/codex-ratification/.../...output.md)
docs/operations/codex-ratification-guide.md:163:  ✓ decision_log row appended to fallback (logs/codex-ratification.jsonl)
docs/operations/codex-ratification-guide.md:189:    Read logs/codex-ratification/.../...output.md
docs/operations/codex-ratification-guide.md:217:## §5 — Running the full ratification queue
docs/operations/codex-ratification-guide.md:224:bash scripts/run-codex-ratification.sh --cluster A
docs/operations/codex-ratification-guide.md:234:bash scripts/run-codex-ratification.sh --cluster B
docs/operations/codex-ratification-guide.md:244:bash scripts/run-codex-ratification.sh --cluster C
docs/operations/codex-ratification-guide.md:253:Per execution plan §9: after cluster C, PAUSE until `bash scripts/run-live-migration.sh` succeeds. The live migration verifies Phase 4 SQL applies cleanly against the migration-test tenant; cluster D (migration ratification) makes more sense AFTER that.
docs/operations/codex-ratification-guide.md:260:bash scripts/run-codex-ratification.sh --cluster D  # migration SQL
docs/operations/codex-ratification-guide.md:301:This is a red flag — Codex didn't grip the artefact. Re-run with a slightly more targeted prompt (you can edit the prompt file under `logs/codex-ratification/<session-id>/*.prompt.md` and re-invoke). If the second run is similarly vague, treat as advisory (RATIFIED-with-notes) rather than blocking.
docs/operations/codex-ratification-guide.md:311:Re-run. If reproducible, capture the full stderr (look at `logs/codex-ratification/<session-id>/*.output.md`) and escalate to founder.
docs/operations/codex-ratification-guide.md:373:The disagreement doc itself becomes a ratifiable artefact in a future round (master brief §10.5 recursive ratification). That's by design — the disagreement IS the signal.
docs/operations/codex-ratification-guide.md:395:Run this query at any point to see your ratification history.
docs/operations/codex-ratification-guide.md:397:If `IFOS_DB_URL` isn't set when the wrapper runs (or psql isn't on PATH or the live DB rejects the write), the row appends to `logs/codex-ratification.jsonl` instead. Same shape, JSON Lines. Replays into Postgres later via the autosend-syncer worker (Week 5+).
docs/operations/codex-ratification-guide.md:466:# Then run the ratification wrapper
docs/operations/codex-ratification-guide.md:467:bash scripts/run-codex-ratification.sh --cluster A
docs/operations/codex-ratification-guide.md:478:The execution plan §9 names three options for when to start ratification (α = now, β = after Q1, γ = hybrid). Founder bias is γ.
docs/operations/codex-ratification-guide.md:484:2. Verify wrapper runs (`bash scripts/run-codex-ratification.sh --list-clusters`) — 1 min
docs/operations/codex-ratification-guide.md:487:   bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/operations/codex-ratification-guide.md:514:- **Updated manifest** — `docs/decisions/2026-05-18-codex-ratification-manifest.md` queue table marked with completion dates
docs/operations/codex-ratification-guide.md:523:- **Codex Day-7 manifest closes** — first ratification run complete; production-grade audit trail
docs/operations/codex-ratification-guide.md:538:bash scripts/run-codex-ratification.sh --list-clusters
docs/operations/codex-ratification-guide.md:539:bash scripts/run-codex-ratification.sh architecture-decision <path>
docs/operations/codex-ratification-guide.md:540:bash scripts/run-codex-ratification.sh --cluster A
docs/operations/codex-ratification-guide.md:543:ls logs/codex-ratification/<session-id>/
docs/operations/codex-ratification-guide.md:544:less logs/codex-ratification/<session-id>/<artefact-slug>.output.md
docs/operations/codex-ratification-guide.md:548:bash scripts/run-codex-ratification.sh <skill-type> <path>
docs/features/agent-build/STATUS.md:21:- ⏸ Review tier — review sub-agent prompt + `run-codex-ratification.sh` per branch (orchestrator runs at review).
docs/operations/founder-manual-playbook-2026-05-31.md:84:**What I do on your reply:** mark W4 backlog item #1 closed; flip the deferred-rollback re-ratification note to "next natural touch is now this VPS apply — schedule a cluster E re-run."
docs/features/agent-build/04-reviews/review-sourcing-scout.md:4:**Codex ratification round 1: REJECTED (4 issues — all in `agent.md` contract doc, none in new code)** → fix pass dispatched; round 2 pending.
docs/features/agent-build/04-reviews/review-sourcing-scout.md:14:5. **ADVISORY — `cycle.sh:209-223`** — Step-1 `ESC_BRIEF_AMBIGUITY` emits a `validate_gate_a_fail` action row while deviation 4 reserves that for Gate A. Pick one idiom at re-ratification.
docs/operations/codex-round-2-handoff.md:7:- `docs/operations/codex-ratification-guide.md` — the practical step-by-step (Round-1 era)
docs/operations/codex-round-2-handoff.md:8:- `docs/operations/codex-ratification-execution-plan.md` — overall execution framework
docs/operations/codex-round-2-handoff.md:9:- `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5 + §1.6 — queue state
docs/operations/codex-round-2-handoff.md:10:- `scripts/run-codex-ratification.sh` — the driver wrapper
docs/operations/codex-round-2-handoff.md:24:**Round-2 queue: 26 artefacts** total (14 re-ratifications + 12 new).
docs/operations/codex-round-2-handoff.md:38:# If error like "spawn ... ENOENT": see codex-ratification-guide.md §3.1
docs/operations/codex-round-2-handoff.md:45:ls .codex/ratification/
docs/operations/codex-round-2-handoff.md:48:grep -A 2 "§1-Exemption" .codex/ratification/review-architecture-decision.md | head -5
docs/operations/codex-round-2-handoff.md:53:bash scripts/run-codex-ratification.sh --list-clusters
docs/operations/codex-round-2-handoff.md:57:mkdir -p logs/codex-ratification/round-2
docs/operations/codex-round-2-handoff.md:104:| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | `review-architecture-decision` | **Recursive ratification per master brief §10.5.** Codex either RATIFIES the disagreement (D5 was correct) OR REJECTS (insists on strict skill). Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:105:| 20 | `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | `review-architecture-decision` | **Recursive ratification.** Codex evaluates Claude's counter-argument re: Week-1 gate. Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:125:bash scripts/run-codex-ratification.sh --cluster A
docs/operations/codex-round-2-handoff.md:126:bash scripts/run-codex-ratification.sh --cluster B
docs/operations/codex-round-2-handoff.md:127:bash scripts/run-codex-ratification.sh --cluster C
docs/operations/codex-round-2-handoff.md:130:bash scripts/run-codex-ratification.sh architecture-decision docs/architecture/tenancy-invariants.md
docs/operations/codex-round-2-handoff.md:131:bash scripts/run-codex-ratification.sh architecture-decision docs/architecture/architecture-cohesion-review.md
docs/operations/codex-round-2-handoff.md:132:bash scripts/run-codex-ratification.sh architecture-decision docs/runbooks/tenant-lifecycle.md
docs/operations/codex-round-2-handoff.md:133:bash scripts/run-codex-ratification.sh architecture-decision scripts/run-tenancy-audit.sh
docs/operations/codex-round-2-handoff.md:136:bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md
docs/operations/codex-round-2-handoff.md:137:bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
docs/operations/codex-round-2-handoff.md:138:bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/2026-05-20-codex-round-1-founder-decisions.md
docs/operations/codex-round-2-handoff.md:139:bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/autosend-approval-bridge-spec.md
docs/operations/codex-round-2-handoff.md:140:bash scripts/run-codex-ratification.sh architecture-decision docs/runbooks/pii-purge-operational-pattern.md
docs/operations/codex-round-2-handoff.md:141:bash scripts/run-codex-ratification.sh architecture-decision scripts/ifos-pii-purge.sh
docs/operations/codex-round-2-handoff.md:142:bash scripts/run-codex-ratification.sh postgres-migration docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/operations/codex-round-2-handoff.md:143:bash scripts/run-codex-ratification.sh postgres-migration docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/operations/codex-round-2-handoff.md:146:**Expected time:** 4-5h total (clusters A+B+C ~3h; 12 individual ratifications ~10-15 min each ≈ 2h).
docs/operations/codex-round-2-handoff.md:148:**Per-artefact output:** `logs/codex-ratification/<session-id>/<slug>.output.md` + audit row to `decision_log` (live mode) OR `logs/codex-ratification.jsonl` (fallback).
docs/operations/codex-round-2-handoff.md:159:You are running Codex ratification Round 2 for the Intel Force OS (IFOS)
docs/operations/codex-round-2-handoff.md:172:  required); see .codex/ratification/review-architecture-decision.md §1-Exemption
docs/operations/codex-round-2-handoff.md:178:Read .codex/ratification/SKILL.md in full. Apply the five rules + four boundaries
docs/operations/codex-round-2-handoff.md:189:  logs/codex-ratification/round-2-manual/<slug>.output.md
docs/operations/codex-round-2-handoff.md:200:ratification per master brief §10.5. Decide whether Claude's counter-argument
docs/operations/codex-round-2-handoff.md:324:`docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5 + §1.6 — add per-artefact Round-2 verdict + disposition. Mirrors §1.5 Round-1 pattern.
docs/operations/codex-round-2-handoff.md:328:For each Round-2 RATIFIED item: mark status field "RATIFIED-Round-2-2026-05-22" (or appropriate date) in the queue table. Item is now closed; no further ratification needed unless artefact changes.
docs/operations/codex-round-2-handoff.md:348:- **26 artefacts ratified or ratification-pending-founder** — every architectural decision + design + schema + runbook + spec + script + migration has been Codex-reviewed
docs/operations/codex-round-2-handoff.md:352:- **No open ratification work** except for any founder-escalations from Class 6
docs/operations/codex-round-2-handoff.md:364:4. **Disk fills** in `logs/codex-ratification/` (cleanup older sessions; restart)
docs/operations/codex-round-2-handoff.md:406:Manifest queue position: this protocol document itself joins the queue as a Round-3 candidate (recursive ratification per master brief §10.5).
docs/decisions/2026-05-31-d1-founder-decision.md:3:**Status:** Accepted (founder-arbitrated 2026-05-31 via explicit delegation: *"i pretty much trust your decision making for the technical build stuff"*). Codex ratification: **deferred-to-W10-13-build-slice** per `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` (cluster G stopped at partial-ratification after 4 rounds; the structural decision is accepted; the cross-doc consistency surface gets reconciled when W10-13 lands).
docs/decisions/2026-05-31-d1-founder-decision.md:63:## Codex ratification
docs/decisions/2026-05-31-d1-founder-decision.md:65:This decision doc ratifies via `.codex/ratification/review-architecture-decision.md` skill. Currently in flight under **cluster G** (`bash scripts/run-codex-ratification.sh --cluster G`); session-by-session ratification status is tracked in the closing Status-update line.
docs/decisions/2026-05-31-d1-founder-decision.md:71:- **Concierge ratification §10** — `Founder Decision D1 RESOLVED` blocker now satisfied. Remaining Concierge Proposed → Accepted blockers per §10: ADR-007 Accepted + Codex RATIFIED (DONE 2026-05-31 + Round 3), pilot LOI (PENDING), Bullhorn A+B (PENDING), founder approves §9 Q2-Q6 (PENDING).
docs/decisions/2026-05-31-d1-founder-decision.md:82:**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commits `669a4f4` + `9ec2bd6`) — **all consumers still operate in env-var-fallback mode** (per `IFOS_FORCE_EMAIL_CHANNEL` + `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` in `context.sh`); no `tenant_adapters` reads attempted at runtime; fixtures use `tenant_env_overrides:` blocks to match. **v0.4 supplement LANDED 2026-06-03** (commit `a1bbcf6`) adding `operator_telegram_chat_id` as a top-level allowlist entry — W10-13 build slice picks Path A (reuse `approval_routing` JSONB; recommended) or Path B (top-level key); **both paths are now schema-clean**. Concierge `context.sh` TODO(W10-13) markers updated 2026-06-03 (commit `98ab8ce`) to reflect supplement-landed state. Codex ratification currently in flight under cluster G (R3 closing 2026-06-02 per `docs/decisions/codex-disagreement-2026-06-02-*` ledger and the cluster G round-trip arc); v0.4 supplement will ratify separately under W5 Phase 7 F-tris cluster.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:8:- Round 4: `logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.output.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:9:- Round 5: `logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.output.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:15:Week 3 goal at `docs/operations/goal-week-3-polish-and-scaffold.md` Step 7 (Codex Round 4 Phase 1) ratified `agents/recruitment/diagnostic/agent.md`. Codex found 4 issues; mechanical remediation applied (commit `6e0cb86`); Round 5 re-ratification found 5 new issues — 2 re-raises (Codex disagreed with my remediation framing), 3 new findings not visible at Round 4.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:77:**Codex says:** "The file has `Status: Proposed` at line 3, but no `Context`, `Decision`, or `Consequences` sections as required for Proposed artefacts by review-architecture-decision §1. Fix: either review this with `review-agent-bundle.md`, or add the required architecture-decision sections and a final status-update line."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:81:**Recommendation:** **Build `review-agent-bundle.md` Codex skill** (deferred per execution-plan §3 lazy; now needed). The Round-4 manifest used `review-architecture-decision.md` as a temporary skill because `review-agent-bundle.md` doesn't exist yet. The correct ratification path for agent.md files is the agent-bundle skill, not architecture-decision.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:83:**This is the load-bearing finding** — it surfaces that **the lazy-skill deferral is now blocking proper agent.md ratification.** Building `review-agent-bundle.md` is a Week-3-extension or W4 priority.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:92:4. **Authorise Week-3-extension OR W4-priority work** to build `review-agent-bundle.md` Codex skill (Issue 5)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:102:- Phase 2 full (5 new scaffolds): **deferred** pending Issue-5 resolution (review-agent-bundle.md skill build)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:106:Recommended next step (post-arbitration): Week-3-extension or W4-prio-1 build of `review-agent-bundle.md` skill; then re-run Codex Round 4 against all 6 v1.0 agent.md files with the proper skill.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:112:After building `.codex/ratification/review-agent-bundle.md` (commit `825ebd4`) — the correct skill for agent.md ratification — all 6 agent.md files were re-ratified.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:118:| Diagnostic | 5 (same as Round 5 but with Issue-5-validate-impl-gap replacing Issue-5-doc-shape) | `logs/codex-ratification/20260524T101934Z-19923/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:119:| Janitor | ~5-7 (count regex inflated; 56 numbered items including nested) | `logs/codex-ratification/20260524T102050Z-21293/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:120:| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:121:| Cash Conductor | ~5-7 (count regex 58) | `logs/codex-ratification/20260524T102316Z-...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:122:| Sourcing Scout | ~5-7 (count regex 50) | `logs/codex-ratification/20260524T1024...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:123:| Concierge | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T1025...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:135:**Single founder decision unlocks all 6 ratifications:** approve the 5-category disposition above. Then mechanical remediation pass applies the dispositions across all 6 agent.md files. Re-ratify all 6 (Round 5 — final per hard ceiling); expect RATIFIED.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:157:After all 6 Round-4-v2 issues remediated on Janitor (commit `2392af8`), Round-5 ratification returned REJECTED with **5 NEW findings** — none of the original 6 reappeared. New issues at Janitor session `20260524T103757Z-37420`:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:160:2. **`bullhorn_field_backfill` unregistered, would fail-safe to red:** my flag-for-addition framing didn't satisfy because `hook-helpers.sh::autosend_policy_lookup` fails to red on unknown action types AT RUNTIME, regardless of flag prose. Real bug requires either (a) policy row added BEFORE ratification, OR (b) explicit "blocked W5 prerequisite" framing not "executable output."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:176:5. Single Codex re-ratification round (Round 6) expected RATIFIED for the artefacts where Codex's framing was accepted, with documented disagreements for any artefacts where founder counter-argues
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:198:| Round 4 v2 | review-agent-bundle (correct) | 6 | 10 (6 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:199:| Round 5 (remediation of R4-v2) | review-agent-bundle | 5 | 15 (5 new; none from R4-v2) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:200:| Round 6 (remediation of R5) | review-agent-bundle | 4 | 19 (4 new; none from R5) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:266:### Phase 3 — Round 8 Codex ratification
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:268:Ran all 6 against `review-agent-bundle.md`. **All 6 returned REJECTED**, with the following actual top-level finding counts (the script's regex inflates because of nested sub-bullets):
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
docs/features/agent-build/03-implementation/scribe-summary.md:82:9. **agent.md untouched** (founder-gated status + W6-ratification rewrite). Its
docs/features/agent-build/03-implementation/scribe-summary.md:170:FINAL fix pass (≤2-round ceiling — no further ratification iteration after
docs/operations/codex-round-2-remediation-prompt.md:5:**Purpose:** Drop-in autonomous prompt that fixes the 6 mechanical rejections from Round 2, flags the 3 founder-decision-bound items explicitly, runs Round 3 ratification on the corrected subset, and commits.
docs/operations/codex-round-2-remediation-prompt.md:22:Your working directory is the IFOS repo root. Round 2 ratification closed at
docs/operations/codex-round-2-remediation-prompt.md:25:ratification on the corrected subset, and commits.
docs/operations/codex-round-2-remediation-prompt.md:32:  1. logs/codex-ratification/round-2-autonomous/SUMMARY.md (the 9 rejections)
docs/operations/codex-round-2-remediation-prompt.md:33:  2. logs/codex-ratification/round-2-autonomous/<slug>.output.md (per-item
docs/operations/codex-round-2-remediation-prompt.md:47:mkdir -p logs/codex-ratification/round-3-remediation/
docs/operations/codex-round-2-remediation-prompt.md:50:logs/codex-ratification/round-3-remediation/RUN-LOG.md with the proposed fix
docs/operations/codex-round-2-remediation-prompt.md:163:    - scripts/run-codex-ratification.sh (every audit row write)
docs/operations/codex-round-2-remediation-prompt.md:175:  Specifically in run-codex-ratification.sh::_write_audit_row: wrap the
docs/operations/codex-round-2-remediation-prompt.md:188:                              scripts/run-codex-ratification.sh
docs/operations/codex-round-2-remediation-prompt.md:383:STEP 6 — Run Round 3 ratification on the 7 corrected items
docs/operations/codex-round-2-remediation-prompt.md:402:    - hook-helpers.sh + voice-loader.sh + run-codex-ratification.sh  (FIX 5)
docs/operations/codex-round-2-remediation-prompt.md:405:  logs/codex-ratification/round-3-remediation/<slug>.output.md
docs/operations/codex-round-2-remediation-prompt.md:411:  Do NOT include in Round 3 ratification. They're explicitly pending
docs/operations/codex-round-2-remediation-prompt.md:417:logs/codex-ratification/round-3-remediation/SUMMARY.md
docs/operations/codex-round-2-remediation-prompt.md:438:Edit docs/decisions/2026-05-18-codex-ratification-manifest.md.
docs/operations/codex-round-2-remediation-prompt.md:484:        scripts/run-codex-ratification.sh \
docs/operations/codex-round-2-remediation-prompt.md:485:        docs/decisions/2026-05-18-codex-ratification-manifest.md \
docs/operations/codex-round-2-remediation-prompt.md:488:        logs/codex-ratification/round-3-remediation/
docs/operations/codex-round-2-remediation-prompt.md:503:    - hook-helpers.sh + voice-loader.sh + run-codex-ratification.sh:
docs/operations/codex-round-2-remediation-prompt.md:525:  Round 3 ratification (≤2 round-trips per master brief §10.3): 10 items
docs/operations/codex-round-2-remediation-prompt.md:527:  logs/codex-ratification/round-3-remediation/SUMMARY.md.
docs/operations/codex-round-2-remediation-prompt.md:544:  Round 3 ratification: <X> RATIFIED / <Y> REJECTED of 10 corrected items
docs/operations/codex-round-2-remediation-prompt.md:622:5. hook-helpers.sh + voice-loader.sh + run-codex-ratification.sh transaction wrapping (Risk #11 mitigation across all runtime helpers)
docs/operations/codex-round-2-remediation-prompt.md:634:**Round 3 ratification:** 10 corrected items re-ratified against appropriate skills. Hard-ceiling enforced per master brief §10.3 step 5.
docs/operations/codex-round-2-remediation-prompt.md:648:1. Read `logs/codex-ratification/round-3-remediation/SUMMARY.md`
docs/build-brief/00-MASTER-BRIEF.md:105:1. **There is no `templates/agent-codex` directory on `main` today.** I previously implied Codex-runtime agent templates ship with cortextos. They don't. The `runtime` field discussion exists in some forks/PRs but is not in the published v0.1.1. **Consequence:** the Codex ratification loop in §10 runs Codex CLI as an **external tool**, not as a cortextOS agent runtime. We can revisit if/when codex-app-server lands upstream.
docs/build-brief/00-MASTER-BRIEF.md:196:mkdir -p .codex/{ratification,evals,scratch}
docs/build-brief/00-MASTER-BRIEF.md:223:After every bump: run full test suite + Codex ratification (see §10).
docs/build-brief/00-MASTER-BRIEF.md:704:## 10. The Codex ratification loop — second-pair every critical decision
docs/build-brief/00-MASTER-BRIEF.md:718:Install Codex CLI as part of the dev environment, not cortextOS. Drop the ratification skills under `.codex/ratification/`:
docs/build-brief/00-MASTER-BRIEF.md:723:| `review-agent-bundle.md` | Specific checklist for the 6 files + 3 fixtures of a new agent |
docs/build-brief/00-MASTER-BRIEF.md:737:2. **You** run: `codex review --skill .codex/ratification/review-{type}.md --target {path-or-diff}`
docs/build-brief/00-MASTER-BRIEF.md:742:### 10.4 What never goes through ratification
docs/build-brief/00-MASTER-BRIEF.md:745:- Test fixture additions (fixtures themselves are the ratification)
docs/build-brief/00-MASTER-BRIEF.md:750:### 10.5 What ALWAYS goes through ratification
docs/build-brief/00-MASTER-BRIEF.md:762:### 10.6 The ratification timeline
docs/build-brief/00-MASTER-BRIEF.md:765:- Day 1: build the `.codex/ratification/*.md` skills (Claude does this; we don't ratify the ratification skills until Day 7)
docs/build-brief/00-MASTER-BRIEF.md:766:- Day 7: Codex reviews the seven Week 0 artefacts (primitive audit, Bullhorn path, Brain UI scope, infra checklist, safety policy, kill criterion, vertical schema v0.1) — first ratification run
docs/build-brief/00-MASTER-BRIEF.md:771:- Weekly ratification of risk register changes (informal — 5 min spot-check)
docs/build-brief/00-MASTER-BRIEF.md:809:> 6. The Codex ratification loop
docs/build-brief/00-MASTER-BRIEF.md:817:> Update `.agents/current-priorities.md` with what shipped, what's stuck, what changed. If anything new goes on the risk register, update `docs/RISK-REGISTER.md`. Commit with a sensible message. If anything is queued for Codex ratification, list it.
docs/build-brief/00-MASTER-BRIEF.md:831:| "Let me skip the Codex ratification — it's a small change..." | §10.5 |
docs/build-brief/00-MASTER-BRIEF.md:904:## The Codex ratification loop
docs/build-brief/00-MASTER-BRIEF.md:906:goes through `codex review --skill .codex/ratification/review-{type}.md --target {path}` before
docs/build-brief/00-MASTER-BRIEF.md:918:3. List anything queued for Codex ratification
docs/build-brief/00-MASTER-BRIEF.md:924:3. Check Codex's prior ratifications for related artefacts
docs/build-brief/00-MASTER-BRIEF.md:932:- Don't skip Codex ratification at phase boundaries
docs/build-brief/00-MASTER-BRIEF.md:956:> 6. You understand the Codex ratification loop and which artefacts always go through it
docs/build-brief/00-MASTER-BRIEF.md:977:Don't. Each is a post-mortem chapter waiting to be written. The five rules, the four boundaries (submodule, adapter, vault/PG split, brain-replacement), and the ratification loop are what keep this thing buildable by one person, then two, then ten.
docs/decisions/v1.0-kill-criterion.md:3:**Status:** Proposed — pending Codex Day-7 ratification
docs/decisions/v1.0-kill-criterion.md:115:**Action:** PAUSE for the affected pilot. The agent that produced the miscategorisations halts at next session boundary. Founder + Jack review the policy tier classifications within 48 hours. Policy revision (via Codex ratification) lands as a new commit; affected pilot receives incident report. Pilot resumes after policy revision.
docs/decisions/v1.0-kill-criterion.md:377:**For Risk Register.** Triggers 1, 2, 3, 5, 6, 7, 9, 10 each correspond to existing register entries (Risks #1-#8 in some combination). Risk #3 is updated in this Day-5 commit to reflect the Day-5 status. Risk #4 (Hire #1) is implicitly linked to Trigger 4 (scope cuts). Codex Day-7 ratification reviews the alignment between kill criterion triggers and risk register entries.
docs/decisions/v1.0-kill-criterion.md:379:**For Codex Day-7 ratification queue.** This criterion joins the queue. Ratification reviews:
docs/decisions/v1.0-kill-criterion.md:393:**Proposed.** Founder review pending. Codex Day-7 ratification queued. Expected progression:
docs/decisions/v1.0-kill-criterion.md:397:- Updates between v1.0 and v1.1: minor updates (threshold tuning, owner reassignment) via amendment commit; structural updates (new trigger, removal of trigger) via Codex ratification.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:84:- Codex ratification loop (continues per existing manifest)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:100:| Codex ratification of bundle | ⏸ W4 | — |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:6:**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:7:**Driven by:** `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3 — at the time of Codex R3, the Concierge `agent.md` reframed the 30-min SLA as Gate B without an ADR and §10 omitted an ADR-ratification blocker. Both have since been closed: Concierge `agent.md` §10 line 435 now lists "**ADR-007 RATIFIED**" as a Proposed → Accepted blocker, and this ADR exists. Analogue of ADR-006 (Diagnostic Gate A hybrid).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:26:This creates a documented gap between the upstream spec and the v0 scaffold. Codex R3 Finding 3 (Day-19 log `logs/codex-ratification/20260524T174513Z-13185/`):
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:104:3. The Concierge agent.md §10 Accepted criteria must include ratification of this ADR as a blocker (closing Codex R3 Finding 3 properly)
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:46:The Day-7 single-sentence test (master brief §6 Day 7 / Ultraplan §12) doesn't directly test sequencing — but Q4 ("Have we scoped the Agent Bundle v2 refactor and is the work <5 days?") and the Week-0 deliverable list at Ultraplan §9 line 737-741 both assume a sequenced plan exists. The Day 7 review surfaces this document for Codex ratification.
docs/decisions/sequencing-target.md:273:## Section 4 — Recommendation (ratification)
docs/decisions/sequencing-target.md:335:- Per-agent Codex-ratification timing within each build slot — every `agent.md` ratifies before merge per master brief §10.5; specific ratification cadence emerges from each agent's PR cycle.
docs/decisions/sequencing-target.md:444:### 6.7 — For Codex Day-7 ratification
docs/decisions/sequencing-target.md:475:Single Codex ratification on Day 7.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:6:**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:25:This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:76:This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:109:- `docs/decisions/2026-05-18-codex-ratification-manifest.md` queue updated to include this ADR. NOT yet updated as of this commit; lands in the post-ratify commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:128:- `docs/decisions/2026-05-18-codex-ratification-manifest.md` → adds this ADR as ratification queue item
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:146:**Proposed.** Awaits Codex ratification via `review-architecture-decision.md` skill.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:113:2. **`.codex/ratification/*.md` skills** — master brief §10.2 Day-1 task deferred during Days 0-6; surfaced as gap during Day-7 grounding. Build during extension period. 7 skill files (SKILL.md + 6 review-{type}.md per master brief §10.2). Estimated 2-3 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:124:4. **First Codex ratification run execution** — manifest produced today (see Deliverable 3); actual `codex review` against ratification skills waits for (a) skills built AND (b) Week 0 close achievable.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:161:**Accepted (factual recording).** Recorded in `.agents/current-priorities.md` Day 7 Shipped section. Risk #3 in `docs/RISK-REGISTER.md` updated to reflect Week 0 extension active + Q1 unblocker path. Codex Day-7 ratification manifest produced as Deliverable 3 (sibling artefact in this commit).
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:135:3. Day 7 Codex ratification reviews ADR-001 + ADR-002 + the seven Week 0 artefacts together (per master brief §10.6).
docs/operations/goal-week-5-execution-plan.md:26:9. **`docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md`** (cluster Fbis + G partial-ratification framework — Janitor + Scribe + Sourcing Scout bundles will land at the same partial-ratification shape; no expectation of Codex round-N clean ratification at the bundle layer)
docs/operations/goal-week-5-execution-plan.md:66:13. **Cluster F-tris ratification manifest entry** added — Janitor + Scribe + Sourcing Scout agent-bundles + Bullhorn MCP + WorkOS MCP + v0.4 supplement + Granola MCP (vendor pivoted from Fathom/Fireflies 2026-06-03). Founder triggers when ready (expected partial-ratification outcome per Fbis + G precedent; same disagreement-doc framework applies if rounds blow out).
docs/operations/goal-week-5-execution-plan.md:168:- Add cluster F-tris entry to `scripts/run-codex-ratification.sh` (Janitor + Scribe + Sourcing Scout agent-bundles + 3 new MCP packages + v0.4 supplement)
docs/operations/goal-week-5-execution-plan.md:191:- Codex ratification round attempted in this plan → NOT ALLOWED. Ratification runs are deferred to Phase 7 cluster F-tris manifest entry + founder-triggered execution. **No agent.md edits during this plan that aren't structural-fix-driven** (don't accumulate Codex churn we already paid the price for in cluster Fbis + G).
docs/operations/goal-week-5-execution-plan.md:212:## §5 — Cluster F-tris ratification expectation
docs/operations/goal-week-5-execution-plan.md:214:Per `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` precedent: expect **partial-ratification with disagreement docs** at the bundle layer for Janitor + Scribe + Sourcing Scout. The pattern:
docs/operations/goal-week-5-execution-plan.md:216:- Bundle layer (cycle.sh + sibling files) ratifies via cluster F-tris ≤2 rounds; if more rounds needed → partial-ratification per Fbis + G precedent
docs/operations/goal-week-5-execution-plan.md:218:- v0.4 supplement ratifies via review-schema-change skill; expect clean ratification given it's additive-only
docs/operations/goal-week-5-execution-plan.md:220:**Do NOT iterate Codex rounds during W5 itself.** Run ONCE at Phase 7; accept partial-ratification if 2 rounds blow out; document via disagreement docs per Fbis + G template. Hard-stop discipline preserves W5 momentum.
docs/operations/goal-week-5-execution-plan.md:240:Every bundle scaffold lands with the Reading-discipline note pattern established in CC + Concierge (commits `8cc0491` + `d46474c`). The note explicitly frames agent.md as the CONTRACT vs SKELETON runtime + lists actual hh_decision_* emissions in the SCAFFOLD cycle.sh. This pre-emptively closes the scaffold-vs-runtime-drift Codex finding that drove cluster Fbis to partial-ratification.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:5:**Context:** Codex ratification first run rejected 14 of 16 artefacts. 13 of 14 rejections were incorporated (Bucket 1 cosmetic + Bucket 2 drift + Bucket 3 structural fixes — same commit as this briefing). The remaining 5 items surfaced by Codex are genuine founder-domain product judgments, not Claude's call. This briefing surfaces them in one place for resolution.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:16:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issues 1+2
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:45:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issue 3
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:66:- Codex output `logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:68:**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:88:- Codex output `logs/codex-ratification/manual-run/docs_runbooks_operational_hygiene_protocol_md.output.md` issue 2
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:110:**Real issue:** Codex Round 1 REJECTED `cortexos-primitive-status.md` (audit) and `operational-hygiene-protocol.md` (runbook) for lacking Decision + Consequences sections. The skill `.codex/ratification/review-architecture-decision.md` §1 requires these sections for all artefacts under this skill. But the skill ALSO allows Status=Reference and Status=In Force, which are legitimately non-decision artefacts. Contradiction in the skill itself.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:121:If D5-A or D5-C: skill update is a separate small commit. Re-ratification runs from same `bash scripts/run-codex-ratification.sh --cluster B` command.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:125:Founder accepted **D5-A**. Skill softening landed in `.codex/ratification/review-architecture-decision.md §1` plus new §1-Exemption clause. Reference + In Force status artefacts now exempt from Decision + Alternatives + Consequences requirements (Context + Status line still required for ALL).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:141:| **D5** (skill softening) | This week | Round 2 ratification of 2 artefacts |
docs/decisions/bullhorn-integration-path.md:93:  - This document joins the first Codex ratification run alongside the other Week 0 artefacts per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:396:No commercial gating. Codex Day-7 ratification reviews the technical analysis directly.
docs/decisions/bullhorn-integration-path.md:425:### 6.5 — For Codex Day-7 ratification
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md:5:**Author:** Claude Code (autonomous; founder approved partial-ratification path).
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md:69:## Companion partial-ratification status
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md:71:This decision-doc + the QB concurrent-throttle disagreement doc + the cluster-F R3 work-justification doc together document the full Codex disagreement set for cluster F. Per founder-authorized hard-stop (2026-06-02 AskUserQuestion), `@ifos/quickbooks` and `@ifos/open-banking` are marked as **Proposed-with-Codex-disagreement-on-file** and will not be re-submitted to Codex for further rounds in this cluster. xero is RATIFIED. Cluster F is closed at this partial-ratification state.
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:5:**Codex round:** R16 (`logs/codex-ratification/20260524T130117Z-63874/`)
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:60:- Day 7 Q2 ratification gate on the file bus passes cleanly because the description matches the code.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:71:- Codex-ratification list (master brief §10.5) needs an entry: bus-dispatcher mechanism change = master brief edit = always-ratify.
docs/runbooks/day-4-provisioning.md:40:**Master brief asserts (line 477 verbatim):** "Hetzner UK VPS provisioned, LUKS-encrypted volume mounted at `/vault/`". This is the single Hetzner reference in the master brief. §10 (Codex ratification loop) does not mention Hetzner or cost targets — earlier drafts of this runbook cited "master brief §10.4" for cost target and Hetzner location; both fabricated. Corrected in citation-audit pass 2026-05-18.
docs/runbooks/day-4-provisioning.md:56:**Master-brief correction:** add to the atomic-correction commit manifest (currently 8 edits at end of Week 0). Proposed Edit 9: master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations"; flag UK-residency as a commercial-conversation gate. (Earlier drafts also referenced "§10.4" as a separate location-naming surface; verified that §10.4 — "What never goes through ratification" — contains no Hetzner or cost-target content. §10.4 component dropped.)
docs/runbooks/day-4-provisioning.md:1172:- Update "Queued for Codex ratification" to include this runbook + the executed provisioning artefact
docs/runbooks/day-4-provisioning.md:1189:- Still single Codex ratification on Day 7 (or end-of-Week-0)
docs/runbooks/day-4-provisioning.md:1191:### §11.5 — Codex ratification queue
docs/runbooks/day-4-provisioning.md:1279:Suggested timing: collect over Days 5-7, apply as a single `runbook(day 4): v1.1 revisions from execution` commit during §11 ratification queue work.
docs/decisions/ADR-003-agent-bundle-renderer.md:85:> mkdir -p .codex/{ratification,evals,scratch}
docs/decisions/ADR-003-agent-bundle-renderer.md:145:**For Week 0 remaining (Day 2 through Day 7).** ADR-003 doesn't unblock or block any remaining Week 0 work directly. Day 2 (Bullhorn integration path), Day 3 (sequencing + Brain UI scope), Day 4 (Postgres provisioning with `entities` + `entity_links` split per ADR-002 Edit 3 + `_secrets.env` skeleton), Day 5 (auto-send safety policy + kill criterion), Day 6 (vertical schema v0.1), Day 7 (single-sentence test + first Codex ratification) all proceed independently. The renderer is queued for Codex Day-7 review but does not gate Day 7's other reviews.
docs/decisions/ADR-003-agent-bundle-renderer.md:149:**For Codex Day-7 ratification queue.** ADR-003 + the design doc join the queue alongside `cortextos-primitive-status.md`, ADR-001, ADR-002, `second-brain-design.md`, the deferred atomic master-brief correction commit, and the Day-4 Postgres provisioning artefact. The 22-item spec gap consolidation in design §5.4 plus the four-bucket structure (resolved inline / master-brief edits / Week-1+ prerequisites / operational defaults) is the ratification-supporting evidence.
docs/decisions/ADR-003-agent-bundle-renderer.md:166:4. Day 7 Codex ratification reviews ADR-003 + design doc + the previously-queued artefacts together.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:1:# Codex disagreement — Cluster Fbis + G hard-stop after 4 rounds (partial ratification)
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:3:**Status:** Counter-argument accepted (founder-authorized 2026-06-02 via AskUserQuestion); cluster Fbis + G CLOSED at partial-ratification per the pre-agreed escalation rule.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:16:Both Cash Conductor + Concierge agent.md were ratified at the **contract layer** in W3 cluster E (8/9 + 1 fix-applied per the cluster E session log). What R1-R4 of Fbis attempted to ratify was the **bundle layer** (now that sibling files cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures exist alongside the contract). That ratification did not converge in 4 rounds.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:43:The rule: if a Codex round returns REJECTED with NEW issues after we've already done one consistency pass, accept partial-ratification + document the disagreement + move on. Today is that day for Fbis + G.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:51:Each build slice is the right time to re-run cluster Fbis + G ratification — at that point the artefacts are mutually consistent because they were written together.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:69:Despite the partial-ratification outcome, Codex caught real things that ARE fixed in tree:
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:85:Re-run cluster Fbis + G ratification when:
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:88:- **A new fact contradicting these disagreements emerges** — e.g. Codex skill `review-agent-bundle.md` gets hardened to be less interpretive on what counts as "drift" vs "scaffold-acceptable divergence"; or the master brief explicitly defines a `Proposed-with-bundle-drift` state separate from `Proposed`.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:94:**Risk: low.** No production code depends on these agent.md files being ratified-as-bundle. The contract-layer ratification (W3 cluster E) is the load-bearing one for v1.0 readiness; bundle-layer ratification gates only the bundle's own quality framing, not deployment.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:97:- Consider hardening `review-agent-bundle.md` skill to explicitly accept "agent.md describes target W-X build-slice behavior; SKELETON files exist with TODO(W-X) markers" as a non-rejection state. The skill currently treats agent.md ↔ code drift as a structural issue when in reality scaffolding inherently has this property.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:99:- Consider adding a `.agents/learnings/` entry for "Codex agent-bundle ratification converges poorly with hand-edits across long cross-coupled docs; defer to build-slice workflows where code + spec are touched together."
docs/operations/codex-ratification-execution-plan.md:1:# Codex ratification — execution plan
docs/operations/codex-ratification-execution-plan.md:5:**Source artefacts:** master brief §10 (the loop) + `docs/decisions/2026-05-18-codex-ratification-manifest.md` (the queue) + this plan (the how).
docs/operations/codex-ratification-execution-plan.md:62:## §3 — Precondition 1: build the 7 `.codex/ratification/*.md` skills
docs/operations/codex-ratification-execution-plan.md:64:Master brief §10.2 lists 7 skill files. None exist yet (Day-7 manifest §3 gap). Build them before first ratification run.
docs/operations/codex-ratification-execution-plan.md:72:| `review-agent-bundle.md` | The 6-file + 3-fixture pattern | ~250 | Pre-Diagnostic-W3 (not yet needed) |
docs/operations/codex-ratification-execution-plan.md:88:# Codex ratification skill — review-{type}
docs/operations/codex-ratification-execution-plan.md:117:Per `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1 + the Day-8 additions in `.agents/current-priorities.md`. 34 items total, clustered by skill-type for efficient batching (run each skill against its batch before context-switching).
docs/operations/codex-ratification-execution-plan.md:183:| 31 | Codex ratification manifest (recursive) | `docs/decisions/2026-05-18-codex-ratification-manifest.md` | A |
docs/operations/codex-ratification-execution-plan.md:184:| 32 | This execution plan (recursive) | `docs/operations/codex-ratification-execution-plan.md` | A |
docs/operations/codex-ratification-execution-plan.md:218:**Total floor estimate: ~12h30m of focused ratification work.** Realistically, with disagreement handling on ~10% of artefacts (3-4 items at 30-60 min each), allow **15-18 hours total** across the queue.
docs/operations/codex-ratification-execution-plan.md:223:- Cluster D before Cluster I (migration ratification gates the wrapper that runs it)
docs/operations/codex-ratification-execution-plan.md:236:  --skill .codex/ratification/review-{type}.md \
docs/operations/codex-ratification-execution-plan.md:238:  > ratification-output.md
docs/operations/codex-ratification-execution-plan.md:251:    --skill .codex/ratification/review-architecture-decision.md \
docs/operations/codex-ratification-execution-plan.md:280:A small helper script `scripts/ratification-record.sh` can wrap this. Defer to founder preference — manual `psql` invocation is fine if the queue is < 50 items.
docs/operations/codex-ratification-execution-plan.md:348:Per Day-7 manifest §4 + §6 of this plan: Codex ratification execution was deferred pending Week 0 close. Week 0 closes when single-sentence-test Q1 = YES (design partner LOI signed). **Current state:** Q1 = NO; Week 0 EXTENDING; kill-criterion Trigger 1 fires 2026-06-03.
docs/operations/codex-ratification-execution-plan.md:350:**Decision point on starting Codex ratification:**
docs/operations/codex-ratification-execution-plan.md:353:- **Option β** — Wait for Q1 = YES. Rationale: master brief §10.6 framed first ratification run as Day 7; once-Week-0-closes implies the design-partner LOI exists. Some artefacts (Bullhorn integration Sub-decisions A+B) genuinely change post-commercial-conversations.
docs/operations/codex-ratification-execution-plan.md:377:## §10 — Post-ratification close protocol
docs/operations/codex-ratification-execution-plan.md:383:3. **Commit `decision_log` rows** (per §6.3) — these become the audit trail for the ratification run.
docs/operations/codex-ratification-execution-plan.md:385:5. **Update `docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue table: status column flips from "queued" to "RATIFIED-<date>" or "REJECTED+resolved-<date>".
docs/operations/codex-ratification-execution-plan.md:425:- **Pre-ratification editorial sweep** — Codex is the editorial review; Claude doesn't pre-clean artefacts hoping Codex won't catch the issue. Honest artefacts in; honest feedback out.
docs/operations/codex-ratification-execution-plan.md:427:- **Multi-model ratification (e.g., adding Gemini)** — v1.0 is Claude + Codex per master brief §10. Multi-model is v2.0+ if signal justifies.
docs/operations/codex-ratification-execution-plan.md:429:- **Codex review of `agents/_shared/` runtime code via agent-bundle skill** — the 8-file `_shared/` set is reviewed under `review-architecture-decision.md` because it's not an agent bundle, it's the helper layer. Future agents (Diagnostic W3+) will be reviewed under `review-agent-bundle.md` once that skill exists.
docs/operations/codex-ratification-execution-plan.md:433:## §13 — Outputs of first ratification run
docs/operations/codex-ratification-execution-plan.md:444:**Next ratification run** (post-Q1, post-live-migration): clusters D-I, ~6 hours of work.
docs/decisions/2026-05-18-codex-ratification-manifest.md:1:# Codex ratification manifest (Day 7 first ratification run)
docs/decisions/2026-05-18-codex-ratification-manifest.md:6:**Source:** Master brief §10 (the Codex ratification loop) + §10.6 (Day 7 first ratification run)
docs/decisions/2026-05-18-codex-ratification-manifest.md:12:19 items registered for Codex Day-7 ratification per `.agents/current-priorities.md` "Queued for Codex ratification (Day 7)" section. Items 13 (atomic-correction commit) and 15 (placeholder) resolve to other entries in the list — effective ratification queue is **17 substantive artefacts + 1 commit landed today**.
docs/decisions/2026-05-18-codex-ratification-manifest.md:19:| 4 | `docs/architecture/second-brain-design.md` | Reference (ADR-002 binding) | Cross-check against ADR-002 ratification |
docs/decisions/2026-05-18-codex-ratification-manifest.md:57:Autonomous Round 2 ratification reviewed 26 artefacts across the re-ratification, Day-9, and Day-11 queues. Remediation commits referenced by the protocol: `2b287d3` (Round-1 incorporation), `5c3fa66` + `c4348aa` (architecture+tenancy), `783c496` (D5 skill softening), and `20e78d7` + `95e7d4a` (D1/D3 prep). Result: **17 RATIFIED / 9 REJECTED**. Full report: `logs/codex-ratification/round-2-autonomous/SUMMARY.md`.
docs/decisions/2026-05-18-codex-ratification-manifest.md:75:| 15 | `docs/architecture/tenancy-invariants.md` | RATIFIED | First ratification on Round 2; RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:76:| 16 | `docs/architecture/architecture-cohesion-review.md` | RATIFIED | First ratification on Round 2; RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:77:| 17 | `docs/runbooks/tenant-lifecycle.md` | RATIFIED | First ratification on Round 2; RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:78:| 18 | `scripts/run-tenancy-audit.sh` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:79:| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | RATIFIED | First ratification on Round 2; recursive disagreement RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:80:| 20 | `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | REJECTED | First ratification on Round 2; recursive disagreement REJECTED. Open: see SUMMARY.md §3-§4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:81:| 21 | `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` | RATIFIED | First ratification on Round 2; RATIFIED with D1/D2/D3 advisory. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:82:| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:83:| 23 | `docs/runbooks/pii-purge-operational-pattern.md` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:84:| 24 | `scripts/ifos-pii-purge.sh` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:85:| 25 | `docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:86:| 26 | `docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql` | RATIFIED | First ratification on Round 2; RATIFIED; paired forward migration remains rejected. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:90:Round 3 remediated the Round-2 rejection set. Mechanical fixes were incorporated in this remediation commit; founder-domain items were annotated and escalated without Codex making D1/D2/D3 decisions. Result for the corrected subset: **10 RATIFIED / 0 REJECTED of 10**. Full report: `logs/codex-ratification/round-3-remediation/SUMMARY.md`.
docs/decisions/2026-05-18-codex-ratification-manifest.md:105:| 12 | `agents/_shared/hook-helpers.sh` + `agents/_shared/voice-loader.sh` + `scripts/run-codex-ratification.sh` | RATIFIED | Cross-cutting Risk #11 remediation incorporated in this commit; Round-3 RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:115:**Phase 1 (Day 15) — Diagnostic-only mid-week ratification.** Reason: substrate must be verified before 5 new scaffolds reference it. 6 items, all `review-architecture-decision.md` skill except the package-as-a-whole.
docs/decisions/2026-05-18-codex-ratification-manifest.md:120:| 2 | `agents/recruitment/diagnostic/tools.yaml` | Proposed | `review-architecture-decision.md` | First ratification (Day-12 scaffold) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:123:| 5 | `packages/diagnostic-generator/` (package as a whole) | Proposed | `review-architecture-decision.md` | Day-13 ship; first ratification |
docs/decisions/2026-05-18-codex-ratification-manifest.md:124:| 6 | `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` | Accepted | `review-architecture-decision.md` | Day-13 sequencing decision; first ratification |
docs/decisions/2026-05-18-codex-ratification-manifest.md:138:**Day-19 update:** Initial Round-4 Phase-1 attempt used `review-architecture-decision.md` skill (the only available skill at the time). That returned REJECTED with a load-bearing finding (Issue 5 in `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`) — agent.md files require a different skill structure. **`review-agent-bundle.md` skill built in commit `825ebd4`.** Re-ratification of all 6 agent.md items with the new skill.
docs/decisions/2026-05-18-codex-ratification-manifest.md:153:**Hard ceiling reached** per master brief §10.3 step 5. Single founder decision (approve the 5-category disposition) unlocks all 6 ratifications via a single Round-5 mechanical-remediation pass.
docs/decisions/2026-05-18-codex-ratification-manifest.md:166:First ratification run completed Day 8. Cluster A+B+C reviewed (16 artefacts). Per-artefact verdict + Round-1 disposition:
docs/decisions/2026-05-18-codex-ratification-manifest.md:180:| 11 | day-4-provisioning.md | not in Round 1 (Cluster D) | Cluster D ratification deferred per execution plan §9 Option γ. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:189:| 20 | This manifest | not in Round 1 | Recursive ratification deferred per execution plan §10 step 6. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:205:## §2 — Ratification protocol per master brief §10.3
docs/decisions/2026-05-18-codex-ratification-manifest.md:210:> 2. **You** run: `codex review --skill .codex/ratification/review-{type}.md --target {path-or-diff}`
docs/decisions/2026-05-18-codex-ratification-manifest.md:215:For Day-7 first ratification run, steps 1-2 require `.codex/ratification/*.md` skills to exist. They don't yet (see §3).
docs/decisions/2026-05-18-codex-ratification-manifest.md:219:## §3 — Gap: `.codex/ratification/` skills not yet built
docs/decisions/2026-05-18-codex-ratification-manifest.md:221:Master brief §10.2 (Day 0-1 task) specifies 7 skill files under `.codex/ratification/`:
docs/decisions/2026-05-18-codex-ratification-manifest.md:226:| `review-agent-bundle.md` | Specific checklist for the 6 files + 3 fixtures of a new agent |
docs/decisions/2026-05-18-codex-ratification-manifest.md:233:**Current state:** `.codex/ratification/` directory does not exist. Day 0-1 task was never executed during Days 0-6 (focus was on master brief §6 Day 0-6 critical path; `.codex/ratification/` slipped per master brief §10.6 framing "Claude does this; we don't ratify the ratification skills until Day 7" but skills themselves needed to be built first).
docs/decisions/2026-05-18-codex-ratification-manifest.md:235:**Codex CLI itself is installed** at `/opt/homebrew/bin/codex`. The gap is the IFOS-specific ratification skills, not the Codex tool.
docs/decisions/2026-05-18-codex-ratification-manifest.md:241:Per Day-7 founder decision (Option C in grounding): defer ratification execution. Produce the manifest today (this artefact). Schedule the actual ratification work as follows:
docs/decisions/2026-05-18-codex-ratification-manifest.md:245:| **Build `.codex/ratification/*.md` skills** | Week 0 extension period (concurrent with Q1 design-partner work) | 2-3 person-days. 7 skill files per master brief §10.2; each follows the "RATIFIED / REJECTED with numbered issues" output contract. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:246:| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
docs/decisions/2026-05-18-codex-ratification-manifest.md:281:## §6 — Items requiring founder attention before ratification
docs/decisions/2026-05-18-codex-ratification-manifest.md:283:Five items in the queue have open status / decisions that Codex may flag at ratification time. Surfaced here so founder can pre-resolve before triggering ratification.
docs/decisions/2026-05-18-codex-ratification-manifest.md:287:| 7 | `bullhorn-integration-path.md` Sub-decisions A+B | Proposed pending commercial conversations | Either (a) run the Bullhorn outreach + design-partner #1 conversation during extension and flip to Accepted, OR (b) accept ratification of Sub-decision C only, with A+B explicitly marked "deferred to first pilot's actual ATS confirmation" |
docs/decisions/2026-05-18-codex-ratification-manifest.md:299:This manifest does NOT close the ratification work. It records:
docs/decisions/2026-05-18-codex-ratification-manifest.md:302:2. **What's blocking** (`.codex/ratification/*.md` skills not built; Q1 design-partner gap → Week 0 extending).
docs/decisions/2026-05-18-codex-ratification-manifest.md:304:4. **What needs founder attention before triggering ratification** (the 5 items in §6).
docs/decisions/2026-05-18-codex-ratification-manifest.md:312:**Reference.** This manifest is itself queued for Codex ratification (item #20) — once `.codex/ratification/*.md` skills exist + Week 0 closes are achievable.
docs/decisions/2026-05-18-codex-ratification-manifest.md:314:*End of Codex ratification manifest.*
docs/runbooks/operational-hygiene-protocol.md:250:5. **Any Codex ratification preparation** — §5.2 audit is the input quality gate
docs/runbooks/operational-hygiene-protocol.md:266:**Verified ground truth:** master brief §10.4 is "What never goes through ratification" — a 5-bullet list of Codex exclusions (comment-only changes, test fixture additions, documentation typos, build/deps version bumps, anything inside `.agents/`). It contains no Hetzner reference and no cost-target reference.
docs/runbooks/operational-hygiene-protocol.md:304:### §7.5 — Codex Day-7 ratification consequence
docs/runbooks/operational-hygiene-protocol.md:306:Codex reviews 18 items at Day 7. The citation-audit pass made all 15 fabrication fixes BEFORE Codex review. Codex receives correct citations; ratification does not need to re-discover the §10.4 fabrication. Saves Codex review time + improves ratification confidence.
docs/runbooks/operational-hygiene-protocol.md:328:| 1 | Should Path B waiver require a justification text in `.agents/decisions/`, not just the literal "protocol override authorised" line? | Day-7 Codex ratification reviews. Recommend yes: justification is the audit record of why Path A wasn't chosen. |
docs/runbooks/operational-hygiene-protocol.md:331:| 4 | How does this protocol interact with Codex ratification? | Codex reviews against this doc as criteria. If Codex flags a Day-7 artefact for violating §2/§3/§4/§5, that's actionable feedback, not a separate failure mode. |
docs/runbooks/operational-hygiene-protocol.md:339:Codex Day-7 ratification queue position 19 (was 18 pre-citation-audit; this doc joins).
docs/runbooks/operational-hygiene-protocol.md:341:Next revision: after Day 7 single-sentence test + first Codex ratification run. If Codex surfaces lessons from reviewing all 18 prior items, those lessons land here as §11+ findings.
docs/decisions/brain-ui-scope.md:195:Single Codex ratification on Day 7.
docs/decisions/brain-ui-scope.md:197:### 4.6 — For Codex Day-7 ratification
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:5:**Codex output:** `logs/codex-ratification/manual-run/docs_decisions_bullhorn_integration_path_md.output.md` issue 2
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:6:**Skill applied:** `.codex/ratification/review-architecture-decision.md`
docs/decisions/ADR-004-renderer-implementation-deviations.md:16:During implementation, three points of the ratified design did not survive contact with the live system. Each was resolved by deviating from the specification text; each is documented in commit messages + the renderer's `README.md`. This ADR ratifies the three deviations as deliberate decisions before they surface as REJECT items in Codex Day-7 ratification.
docs/decisions/ADR-004-renderer-implementation-deviations.md:40:- ADR-003 §3.3.1 needs an erratum or this ADR's ratification, depending on how Codex treats the divergence.
docs/decisions/ADR-004-renderer-implementation-deviations.md:126:Lands in ADR-003 itself as an inline erratum (small text fix), OR as a §5 entry in this ADR titled "Errata to ADR-003." Founder decision at ratification time.
docs/decisions/ADR-004-renderer-implementation-deviations.md:146:**For Codex Day-7 ratification.** ADR-004 joins the queue. The 3 deviations were pre-flagged in Phase-2 and Phase-3 commit messages + `packages/agent-renderer/README.md`; this ADR consolidates them into a single ratifiable artefact. Without ADR-004, Codex would likely REJECT each deviation individually as "implementation diverges from ADR-003"; with ADR-004, the deviations are deliberately-ratified design decisions Codex either RATIFIES or REJECTS as a coherent set.
docs/decisions/ADR-004-renderer-implementation-deviations.md:148:**For master brief drift.** Edit D + Edit E + Edit F enter the deferred atomic-correction queue (if not landed in this commit). Risk #7 (master-brief-drift-accumulation) is currently closed; reopening it for 3 small text edits is honest but tracked here. Founder decides at ratification time whether to land in this commit or queue for the next atomic correction.
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:5:- `docs/architecture/cortexos-primitive-status.md` (Codex output: `logs/codex-ratification/manual-run/docs_architecture_cortexos_primitive_status_md.output.md`)
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:6:- `docs/runbooks/operational-hygiene-protocol.md` (Codex output: `logs/codex-ratification/manual-run/docs_runbooks_operational_hygiene_protocol_md.output.md`)
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:7:**Skill applied:** `.codex/ratification/review-architecture-decision.md` §1
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:21:> The runbook lacks required Context, Decision, and Consequences sections. Lines 10-29 explain why the document exists, but there is no explicit Decision section naming the binding operational choices and no Consequences section describing downstream enforcement. Fix by adding those sections or reclassifying it under a ratification type that does not require decision-doc shape.
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:40:Edit `.codex/ratification/review-architecture-decision.md` §1 to read:
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:58:**Resolution detail (2026-05-22):** Founder accepted D5-A. Skill softening landed in `.codex/ratification/review-architecture-decision.md §1` — Reference + In Force status artefacts are now exempt from Decision + Alternatives + Consequences sections (Context + Status update line still required). The two REJECTED artefacts from Round 1 (`cortexos-primitive-status.md`, `operational-hygiene-protocol.md`) are expected to RATIFY in Round 2 without changes. Two new Day-9 artefacts (`architecture-cohesion-review.md` Reference, `tenant-lifecycle.md` In Force) are now ratifiable under the softened skill.
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:62:**D5-A accepted.** Skill softened. Cluster B re-ratification (Round 2) expected to RATIFY `cortexos-primitive-status.md` + `operational-hygiene-protocol.md` without artefact changes. Day-9 Reference + In Force artefacts (`architecture-cohesion-review.md`, `tenant-lifecycle.md`) ratifiable under softened skill.
docs/decisions/autosend-safety-policy.md:3:**Status:** Proposed — pending Codex Day-7 ratification
docs/decisions/autosend-safety-policy.md:35:- Codex ratification artefacts (read-only review)
docs/decisions/autosend-safety-policy.md:304:**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).
docs/decisions/autosend-safety-policy.md:603:| 8 | Spot-check disagreement feedback loop — what's the mechanism for spot-check reviewer disagreement to elevate an action_type's tier? | §2 + §11 | Recommend a `spot_check_disagreement` table; >3 disagreements over 30 days triggers a tier-elevation proposal that goes through Codex ratification. v1.1 builds this. |
docs/decisions/autosend-safety-policy.md:640:**For Codex Day-7 ratification queue.** This policy joins the queue. Ratification reviews:
docs/decisions/autosend-safety-policy.md:654:**Proposed.** Founder review pending. Codex Day-7 ratification queued. Expected status progression:

codex
REJECTED

1. Build-green status is overstated. `agent.md` line 4 and §8 claim “3 deterministic DB-backed fixture suites — all green under scripts/build-gate.sh,” but `scripts/build-gate.sh` skipped DB-backed fixtures when no reachable `IFOS_DB_URL` was present. This violates honest signal because skipped DB suites are not green evidence. Fix by running with a reachable dev DB and recording that evidence, or downgrade the claim to “DB-backed suites skipped/not verified locally.”

2. §7 claims voice-loader integration that the built bundle does not implement. `agent.md` §7 says Scribe integrates `hh_load_tone_rules`, `hh_load_voice_samples`, and `hh_load_recent_edits`; `context.sh` only calls `hh_load_tone_rules` and never calls the other two. Master brief §8.1 Change 1 requires every context script to call all three. Fix `context.sh` to load voice samples and recent edits, or mark those integrations as unbuilt and gated.

3. Gate A tacit-note threshold is internally inconsistent. `agent.md` §1 says Gate A hard-fails unless there is “1 tacit-note with confidence ≥0.6,” while §5 G3 uses a voice classifier threshold of ≥0.75 and explicitly warns, not fails, when unscored. The built `validate.sh` has no separate tacit-note confidence ≥0.6 check. Fix by defining and enforcing a real tacit-note confidence field, or remove the ≥0.6 tacit-note claim and state the actual ≥0.75 voice-score behavior.

4. The SLA timing anchor contradicts itself. `agent.md` §1 says the 10-minute Bullhorn-note SLA is measured from “poll-sweep discovering the finished meeting,” but §5 says there is “ONE timing anchor: meeting end” and Gate B measures ≥90% within 5 minutes of meeting end. These cannot both be the output contract’s timing anchor. Fix §1, §4 Step 10, and §5 to use one consistent anchor, or explicitly separate product promise and Gate B metric without conflicting clocks.
tokens used
132,964
REJECTED

1. Build-green status is overstated. `agent.md` line 4 and §8 claim “3 deterministic DB-backed fixture suites — all green under scripts/build-gate.sh,” but `scripts/build-gate.sh` skipped DB-backed fixtures when no reachable `IFOS_DB_URL` was present. This violates honest signal because skipped DB suites are not green evidence. Fix by running with a reachable dev DB and recording that evidence, or downgrade the claim to “DB-backed suites skipped/not verified locally.”

2. §7 claims voice-loader integration that the built bundle does not implement. `agent.md` §7 says Scribe integrates `hh_load_tone_rules`, `hh_load_voice_samples`, and `hh_load_recent_edits`; `context.sh` only calls `hh_load_tone_rules` and never calls the other two. Master brief §8.1 Change 1 requires every context script to call all three. Fix `context.sh` to load voice samples and recent edits, or mark those integrations as unbuilt and gated.

3. Gate A tacit-note threshold is internally inconsistent. `agent.md` §1 says Gate A hard-fails unless there is “1 tacit-note with confidence ≥0.6,” while §5 G3 uses a voice classifier threshold of ≥0.75 and explicitly warns, not fails, when unscored. The built `validate.sh` has no separate tacit-note confidence ≥0.6 check. Fix by defining and enforcing a real tacit-note confidence field, or remove the ≥0.6 tacit-note claim and state the actual ≥0.75 voice-score behavior.

4. The SLA timing anchor contradicts itself. `agent.md` §1 says the 10-minute Bullhorn-note SLA is measured from “poll-sweep discovering the finished meeting,” but §5 says there is “ONE timing anchor: meeting end” and Gate B measures ≥90% within 5 minutes of meeting end. These cannot both be the output contract’s timing anchor. Fix §1, §4 Step 10, and §5 to use one consistent anchor, or explicitly separate product promise and Gate B metric without conflicting clocks.
