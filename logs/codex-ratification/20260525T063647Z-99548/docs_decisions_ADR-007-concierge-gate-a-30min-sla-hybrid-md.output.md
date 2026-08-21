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
session id: 019e5dd9-b025-70d0-8230-8fccf788dffd
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

=== TYPE-SPECIFIC SKILL: architecture-decision ===

# Codex ratification skill — review-architecture-decision

Type-specific checks for: ADRs (`docs/decisions/ADR-*.md`), decision docs (`docs/decisions/*.md` other than ADRs), reference designs (`docs/architecture/*.md`), runbooks (`docs/runbooks/*.md`).

This skill ADDS to the top-level `SKILL.md`. Apply that first; everything below is incremental.

---

## §1 — Decision-doc shape requirements

Every artefact of this type MUST have:

1. **Status field** — one of `Proposed | Accepted | In Force | Reference | Superseded | Deprecated`. Match the file's content honestly:
   - `Proposed` = the decision exists but hasn't been ratified or actioned
   - `Accepted` = founder has approved + work is underway/done
   - `In Force` = the decision is binding operational policy right now
   - `Reference` = factual recording (audits, inventories, manifests)
   - `Superseded` = a later artefact replaces this one
   - `Deprecated` = the decision is no longer applied

   REJECT if status is missing, conflicts with content (e.g., "Accepted" but Sub-decisions are "Proposed pending commercial conversations"), or is "Accepted" without a Founder decision date.

2. **Context section** — explains the problem before the solution. Should be readable cold; if a new reader can't tell what this decision is about from the Context alone, REJECT. **Required for ALL statuses.**

3. **Decision section** — names the choice, not the deliberation. If the artefact is mostly deliberation with no clear decision, REJECT. **Required for `Proposed | Accepted`. EXEMPT for `Reference` (audits, inventories, manifests) and `In Force` (runbooks, operational standing policies) — those artefacts encode their "decisions" in the working content itself (audit findings table; runbook procedure steps); a separate Decision heading would be redundant ceremony.**

4. **Alternatives considered** — for ADRs, at least 2 alternatives MUST be named + rejected with reasons. If only one option is presented, REJECT — that's a memo, not a decision document. **Required for `Proposed | Accepted` ADRs only. EXEMPT for non-ADR Reference + In Force artefacts.**

5. **Consequences section** — what changes downstream. Includes risk register implications, master brief edits authorised (if any), downstream-artefact updates required. **Required for `Proposed | Accepted`. EXEMPT for `Reference` + `In Force` — downstream impact may be inline (e.g., "Day-7 single-sentence test Q2 references this audit") rather than under a dedicated heading; verify via cross-references in body text.**

6. **Status update line at end** — current state ("Accepted on 2026-05-16 by founder + Claude Code") OR ratification-pending note. **Required for ALL statuses.**

### §1-Exemption — Softening for Reference + In Force (Codex Round 1 D5)

The exemptions in items 3, 4, 5 above are the result of Founder Decision D5 (commit `2026-05-22`) resolving the disagreement at `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md`. Reference artefacts (e.g., `cortexos-primitive-status.md` audit, `architecture-cohesion-review.md`, `tenancy-invariants.md`) and In Force artefacts (e.g., `operational-hygiene-protocol.md` runbook, `tenant-lifecycle.md` runbook) legitimately do not have "decisions" or "alternatives weighed" — they document findings or procedures.

**The Context requirement (item 2) and Status update line (item 6) still apply to ALL artefacts under this skill.** Citation accuracy (§3) and boundary checks (top-level SKILL.md §2) also apply to all.

If a `Reference` or `In Force` artefact is making material architectural claims that warrant deliberation, RATIFY with an advisory note suggesting the author consider promoting parts to an ADR. Do not REJECT solely for the missing Decision/Consequences sections on these status types.

---

## §2 — ADR-specific structure (for files matching `ADR-*.md`)

In addition to §1, ADRs MUST:

- Have a numbered identifier in the filename matching the contents ("ADR-003" in filename → "# ADR-003 —" as the H1)
- Be sequentially numbered (no gaps — ADR-001 → 002 → 003 → 004)
- Link to predecessor ADRs if extending or referring to them
- Have at least one "Decision" heading + at least one explicit "Decision 1 — <terse summary>" subheading per distinct decision

REJECT if any of these are missing.

---

## §3 — Citation accuracy (heavily-tested area)

Past audits found 15 fabricated `§10.4` references in one batch. Recurrence is likely. Check:

For every cited section reference (e.g., "master brief §6 Day 7 line 502"):

1. Open the cited file
2. Find the cited section
3. Verify the citation matches the content the artefact claims it does

If even one citation is wrong, REJECT with the specific citation listed. Past pattern: `master brief §10.4 cost target` cited 15 times; §10.4 is actually the Codex exclusion list with no cost-target content.

For relative references ("per ADR-003 §3.3.3"), confirm the section exists in the predecessor.

For commit-SHA references (e.g., `c21fbfe`, `fec8872`), confirm the SHA matches the artefact's date + makes sense in context. Don't require running `git show` if the SHA is consistent with the narrative.

---

## §4 — Master brief edit authorisation

If the ADR authorises master brief edits (an "## Master brief edits authorised by this ADR" section):

1. The proposed text MUST be quoted verbatim — both current AND proposed.
2. The edit's line numbers MUST match the live master brief (sample-check at least one).
3. Edits MUST land in either (a) this commit, (b) the next atomic-correction commit, or (c) an explicit deferred queue. Vague "later" disposition = REJECT.
4. Risk #7 (master-brief-drift-accumulation) edit count MUST update if this ADR adds edits to the queue.

---

## §5 — Spec-gap surfacing

Reference design docs often surface spec gaps (`§N.M-A`, `§N.M-B` etc.). Each gap MUST:

- Be numbered uniquely within the design doc
- State the gap (what's missing in the upstream spec)
- Recommend a resolution OR be explicitly deferred to a named owner + week
- Not contradict each other (gap §2.1-A resolution must not break gap §2.1-B resolution)

REJECT if a gap is stated without a resolution path AND not explicitly deferred with owner + trigger.

---

## §6 — Implementation deviation acknowledgement

If the ADR ratifies deviations from a predecessor ADR (e.g., ADR-004 deviates from ADR-003):

1. Predecessor MUST be linked
2. Each deviation MUST be numbered + reasoned individually
3. Predecessor's text MUST be quoted to show what's being deviated from
4. Reason for deviation MUST be concrete (citing a boundary, a runtime constraint, a discovered bug — not "felt cleaner")
5. Rollback or alternative path MUST be named ("if rejected: build X shim instead")

REJECT if deviations are listed without quoting the predecessor or without concrete reasoning.

---

## §7 — Decision_log audit fields (master brief §8.1 Change 2)

Architecture decisions don't directly write to `decision_log` (the agent runtime does), but they MAY constrain what the runtime writes. Check:

- If the decision adds a `decision_log.phase` value: confirm Day-4 §6.3 schema CHECK constraint includes it (`trigger | output | action | gating_failed | agent_handoff`)
- If the decision adds a new ESC code: confirm `agents/_shared/escalation-codes.md` (Phase 1 of Day 8) has the code listed
- If the decision references `payload.tier` or `payload.<key>`: confirm autosend-safety-policy §7 documents the field shape
- If the decision restricts `agent_name` values: confirm sentinel names (`_renderer`, `_tenant_admin`, `_codex_ratifier`, `_shared`) are consistent with usage

REJECT if a decision adds an enum value or column to `decision_log` without confirming the schema supports it.

---

## §8 — Boundary-specific rejections for this artefact type

In addition to the four boundaries in `SKILL.md` §2:

- **Submodule reference** — decision docs MAY name cortextOS files for reference (e.g., `add-agent.ts:131-140`); they MUST NOT propose modifying them. If the ADR proposes a modification to `packages/harness/cortextos/*` outside the shadow points, REJECT.

- **Adapter boundary** — `Composio` and `AgentMail` may appear in INTERNAL discussion text (e.g., "we considered Composio") but MUST NOT appear in `tools.yaml` shape definitions, agent.md examples, or schema fixtures. If the ADR proposes including either in any of those locations, REJECT.

- **v1 source code** — `~/code/intel-force-os/` (the v1 codebase) MUST NOT be modified. ADRs MAY reference v1 for prior-art lessons; MUST NOT instruct edits.

---

## §9 — Common false-RATIFY traps to watch for

Past patterns that look RATIFIABLE but should REJECT:

- **"Trust me" architecture** — the artefact asserts a design works without alternatives weighed. Even simple decisions need at least one weighted alternative.

- **Over-elaborated worked examples** — a 200-line "Concierge worked example" inside an architecture decision is a red flag for masking a thin decision underneath. Skim the worked example; if the decision itself is < 50 lines, REJECT and demand more decision-content.

- **Status drift** — file says `Accepted` but content includes `TODO`, `pending`, `to be decided`. REJECT.

- **Hidden caveats** — major limitations buried at the bottom in a "Notes" section. Surface to the Decision or Consequences section. REJECT.

- **Cross-cite hallucination** — references "as documented in §X" but §X doesn't actually document it. Check.

- **Numbered options that omit the chosen one's reasoning** — "Options: A, B, C. Chose B." but no reasoning for WHY B. REJECT.

---

## §10 — When to RATIFY-with-notes

Use this sparingly. RATIFIED-with-notes is appropriate when:

- The artefact passes all required checks but has typos or wording suboptimalities
- A genuinely advisory observation worth surfacing but not blocking
- The author should fix-up at next touch but the merge is fine

Anything load-bearing — citation errors, spec gaps without resolution, status drift, boundary violations — is REJECTED, not RATIFIED-with-notes. If you find yourself adding more than 5 lines of notes, the artefact has structural issues and should be REJECTED.

---

## §11 — Quick checklist (run this for every ADR-type artefact)

- [ ] Has Status field with valid value matching content
- [ ] Has Context, Decision, Consequences sections
- [ ] (If ADR) Numbered + sequentially located + has alternatives weighed
- [ ] All citations verifiable (sample at least 3)
- [ ] No fabricated section references
- [ ] No submodule modifications proposed outside shadow points
- [ ] No Composio/AgentMail in `tools.yaml`/`agent.md` examples
- [ ] No v1-source modifications proposed
- [ ] Any master-brief edits include current+proposed text + line numbers + disposition
- [ ] Spec gaps (if any) have named resolution or deferred owner
- [ ] Status field matches content honesty (no Accepted-with-pending-sub-decisions unless explicitly noted)

If all clear: RATIFIED.
If any fail: REJECTED with numbered issues citing specifics.

=== ARTEFACT UNDER REVIEW ===

Path: docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md

--- BEGIN ARTEFACT ---

# ADR-007 — Concierge Gate A 30-minute draft SLA hybrid (Gate B leading metric, not per-draft hard-fail)

**Status:** Proposed (2026-05-25, Day 20; W4 bilateral pass on Concierge agent.md surfaced this as Codex R3 Finding 3 — current scaffold reframes ULTRAPLAN A6 line 566 Gate A "every lifecycle event has a draft generated within 30 minutes" as a Gate B leading metric without an authoritative ADR backing the deviation. Awaits Codex `review-architecture-decision` ratification + founder Accept.)
**Author:** Founder (Maddox) + Claude Code
**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A6 line 566 — Gate A 30-minute draft SLA clause
**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
**Driven by:** `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3 — Codex flags Concierge `agent.md` §5 line 278 reframes the 30-min SLA as Gate B without an ADR; §10 Accepted criteria omits any ADR-ratification blocker for this deviation. Analogue of ADR-006 (Diagnostic Gate A hybrid).

---

## Context

ULTRAPLAN §8.1 A6 line 566 (pre-amendment wording):

> - **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)

The clause implies three Gate A hard-fail conditions: (a) draft generated within 30 minutes of lifecycle event, (b) voice classifier ≥ 0.75, (c) addressee resolution correct.

Concierge `agent.md` (Day-19 R3 scaffold) reframes (a) — the 30-minute draft SLA — from per-draft Gate A hard-fail to a Gate B leading metric (90% of drafts within 30 min, not per-draft hard fail). The other two clauses (voice classifier + addressee resolution) remain Gate A hard-fails. The reframe is documented in:

- `agent.md` §1 output-contract (30-min framing as Gate B target)
- `agent.md` §4 Step 9 (`ESC_CONCIERGE_SLA_MISS` warn, aggregated to Gate B; not per-draft block)
- `agent.md` §5 lines 269-280 (Gate A excludes the 30-min SLA explicitly)
- `agent.md` §6 ESC table (`ESC_CONCIERGE_SLA_MISS` registered as warn, not blocking)

This creates a documented gap between the upstream spec and the v0 scaffold. Codex R3 Finding 3 (Day-19 log `logs/codex-ratification/20260524T174513Z-13185/`):

> The 30-minute SLA is weakened without a ratified status-flip blocker. Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria.

Per master brief §10.5 + Rule 4 (Quality gates before features), an upstream-spec amendment requires either (a) revert the scaffold to per-draft hard-fail, or (b) author an ADR ratifying the deviation. This ADR is option (b).

## The deviation in detail

### Why per-draft hard-fail is operationally problematic

The Concierge lifecycle-event trigger source is the Bullhorn ATS state-change webhook + a polling-fallback cron (per ULTRAPLAN A6 line 569 verbatim gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks").

Polling-fallback delays are not Concierge's fault — the polling cron runs at a configurable interval (likely 5-15 minutes per tenant) and a state change that happens at minute 1 of a 15-minute cycle has a 14-minute "blind spot" before Concierge ever sees it. A per-draft hard-fail Gate A would treat this as a Concierge failure even though the draft IS generated within 30 minutes of detection (just not within 30 minutes of the actual Bullhorn state change).

Treating this as Gate A hard-fail would cause Concierge to drop legitimate drafts whose timing was set by upstream-detection latency, not by Concierge generation latency. The product harm: a candidate experiences a "ghosted by recruiter" pattern that Concierge was designed to prevent.

### Why the metric is still load-bearing as Gate B

The 30-minute SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Treating it as Gate B at the 90% threshold:

- Captures the population-level SLA promise
- Tolerates the occasional polling-fallback-induced delay without blocking legitimate drafts
- Drives a measurable improvement signal: if 30-min-SLA-hit-rate drops below 90% across a tenant, the polling interval is too slow OR Bullhorn webhook coverage is degraded — both actionable signals
- Aggregate failures fire `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) when sustained — same operational lever as ADR-006's per-claim quality metric

This is structurally identical to ADR-006's Tier 1 (per-section, hard-fail at the agent level) vs Tier 2 (per-claim, quality metric over time) split — applied here to time (30-min threshold per draft = Tier 1; 90% within 30-min over rolling window = Tier 2).

## Decision

**Concierge Gate A is the subset of ULTRAPLAN A6 line 566 that is operationally enforceable per-draft:**

- ✅ Voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82) — Gate A hard-fail
- ✅ Correct addressee resolution (no candidates emailed under another's name) — Gate A hard-fail (`ESC_ADDRESSEE_MISMATCH`)
- ✅ No tone-rule block-severity violations — Gate A hard-fail (`ESC_TONE_RULE_VIOLATION`)
- ✅ No PII outside firm boundary — Gate A hard-fail (`ESC_PII_LEAKAGE_RISK`)
- ✅ Anti-duplicate guard passed — Gate A hard-fail
- ✅ All Bullhorn context fields present — Gate A hard-fail (`ESC_AGENT_OUTPUT_SHAPE`)

**The 30-minute draft SLA moves to Gate B leading metric:**

- 90% of drafts generated within 30 minutes of lifecycle-event DETECTION (not lifecycle-event occurrence)
- Per-draft SLA miss fires `ESC_CONCIERGE_SLA_MISS` (warn, aggregated to Gate B)
- Rolling 30-day per-tenant aggregate <90% fires `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) — actionable signal
- Concierge ALSO records the upstream-detection-latency separately in the audit payload (`payload.detection_delay_seconds`) so the metric attribution is clean (Concierge generation latency vs upstream polling latency)

**ULTRAPLAN §8.1 A6 line 566 is amended in-band per the master brief §10.3 step 4 pattern** (analogue of the in-band amendment ADR-006 made at line 496):

Pre-amendment:
> - **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)

Post-amendment:
> - **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*

## Consequences

**Positive:**

1. Concierge drafts are not dropped when upstream polling-fallback latency exceeds 30 minutes
2. The product UX promise of "post-state-change comms within 30 minutes" is captured at the population level
3. The metric attribution is clean — operators can distinguish Concierge generation latency from Bullhorn webhook/polling latency
4. Structural parity with ADR-006: per-event Gate A vs aggregate Gate B as the canonical Tier-1/Tier-2 split for time-based SLAs (replicable pattern for future agents)

**Negative:**

1. A per-tenant 30-minute SLA promise is harder to enforce contractually — pilot agreements must reflect that the SLA is at the population level not per-event
2. Tenants with high webhook coverage will see better than 90%; tenants with webhook-coverage gaps see worse — the metric reads as Concierge quality but is partly an upstream condition. Operator must look at `payload.detection_delay_seconds` distribution to disambiguate.
3. The Concierge agent.md §10 Accepted criteria must include ratification of this ADR as a blocker (closing Codex R3 Finding 3 properly)

**Neutral:**

4. No code or schema changes required at scaffold stage — `agent.md` already reflects the Gate B framing. Update is to ULTRAPLAN line 566 (in-band amendment) + Concierge §10 (add ADR blocker) + this ADR (new artefact).

## Implementation

### In-band ULTRAPLAN amendment (per master brief §10.3 step 4)

Edit `docs/specs/ULTRAPLAN.md` §8.1 A6 line 566:

```diff
- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
+ **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — 30-minute draft SLA is Gate B leading metric at 90%)*
```

Commit message: `amend(ULTRAPLAN A6 line 566): Gate A scope reduced; 30-min SLA → Gate B per ADR-007`

### Concierge §10 amendment

Add to Accepted blockers (after R3 commit `f79c018` baseline):

> - **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes R3 Finding 3 structural deviation; ratifies the agent.md §5 Gate A scope vs ULTRAPLAN A6 line 566 pre-amendment language.

### Audit payload extension (deferred)

`decision_log.payload.detection_delay_seconds` field for Concierge action rows is not in v0.3 schema; queued for v0.4 supplement OR W10-13 build-slice schema addition (whichever ships first). Concierge `cycle.sh` v0.0 records the field; absent the constraint, it's free-form JSONB.

## Open questions

| # | Question | Resolution path |
|---|---|---|
| ADR-007-Q1 | Should the 90% threshold be per-tenant configurable, or is 90% a v1.0 fixed bar? | Recommend fixed at v1.0; v1.1 add per-tenant override via `tenant_adapters.config.concierge_sla_threshold` (new key, v0.4-pending). |
| ADR-007-Q2 | Should `ESC_CONCIERGE_SLA_MISS` be a separate code, or should it reuse `ESC_GATE_B_MISS` with payload.metric='concierge_30min_sla'? | Recommend separate code for clean Telegram routing; `_GATE_B_MISS` is generic aggregate. Catalogue addition queued at W10-13 build start. |
| ADR-007-Q3 | What's the polling-fallback interval default? | Per-tenant; recommend 5 min as v1.0 default; 1 min for tenants with stable webhook coverage. Documented in tools.yaml at W10-13 build. |

## References

- ADR-006 — Diagnostic Gate A hybrid (structural template for Tier 1 vs Tier 2 split)
- ULTRAPLAN §8.1 A6 line 566 (pre-amendment authority)
- `agents/recruitment/concierge/agent.md` §1, §4 Step 9, §5, §6 (Gate B framing already implemented)
- `agents/_shared/escalation-codes.md` `ESC_CONCIERGE_SLA_MISS` (registered) + `ESC_GATE_B_MISS` (registered)
- `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3
- Master brief §1 Rule 4 (Quality gates before features) + §10.5 (ADRs are ratifiable artefacts)

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
I’ll verify the ADR against the live repo rather than relying on the embedded excerpt, focusing on cited sections, ADR numbering, status shape, schema/ESC support, and boundary claims.
exec
/bin/zsh -lc 'rg --files docs/decisions docs/specs agents docs/operations .codex | sort' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
.codex/ratification/SKILL.md
.codex/ratification/review-agent-bundle.md
.codex/ratification/review-architecture-decision.md
.codex/ratification/review-postgres-migration.md
.codex/ratification/review-schema-change.md
agents/_shared/README.md
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
agents/_shared/voice-loader.sh
agents/recruitment/cash-conductor/README.md
agents/recruitment/cash-conductor/agent.md
agents/recruitment/concierge/README.md
agents/recruitment/concierge/agent.md
agents/recruitment/diagnostic/README.md
agents/recruitment/diagnostic/agent.md
agents/recruitment/diagnostic/cleanup.sh
agents/recruitment/diagnostic/context.sh
agents/recruitment/diagnostic/cycle.sh
agents/recruitment/diagnostic/fixtures/01-primary.yaml
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml
agents/recruitment/diagnostic/tools.yaml
agents/recruitment/diagnostic/validate.sh
agents/recruitment/janitor/README.md
agents/recruitment/janitor/agent.md
agents/recruitment/scribe/README.md
agents/recruitment/scribe/agent.md
agents/recruitment/sourcing-scout/README.md
agents/recruitment/sourcing-scout/agent.md
docs/decisions/2026-05-18-codex-ratification-manifest.md
docs/decisions/2026-05-18-day-7-single-sentence-test.md
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md
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
docs/decisions/sequencing-target.md
docs/decisions/v1.0-kill-criterion.md
docs/operations/bullhorn-outreach-emails.md
docs/operations/codex-ratification-execution-plan.md
docs/operations/codex-ratification-guide.md
docs/operations/codex-round-2-autonomous-prompt.md
docs/operations/codex-round-2-handoff.md
docs/operations/codex-round-2-remediation-prompt.md
docs/operations/founder-legal-setup-guide.md
docs/operations/goal-option-c-diagnostic-end-to-end.md
docs/operations/goal-week-3-polish-and-scaffold.md
docs/operations/seedlegals-engagement-queries.md
docs/operations/w4-bilateral-pass-6-agent-md.md
docs/operations/w4-day-20-founder-runbook.md
docs/specs/PRODUCT-SPEC.md
docs/specs/ULTRAPLAN.md
docs/specs/_archive-build-handoff.md

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '540,585p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-006-diagnostic-gate-a-claim-coverage-hybrid.md | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
nl: docs/decisions/ADR-006-diagnostic-gate-a-claim-coverage-hybrid.md: No such file or directory

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
   573	#### A7. Inbound Triage (priority 1, 4 weeks)
   574	
   575	- **Build wave:** v1.1 (Q4 2026 weeks 1–4)
   576	- **Always-on?** Tier 1 — the highest 24/7 agent
   577	- **Trigger type:** Inbound email webhook (Microsoft Graph subscription or AgentMail webhook), LinkedIn InMail webhook, website contact form webhook
   578	- **CortexOS primitives required:** All except #6 — Persistent PTY (#1), context rotation (#2), file bus (#3, hands off to Concierge), approval gates (#4), Telegram (#5), orchestrator (#7)
   579	- **MCP tools required:** Microsoft Graph or Gmail (read + send), AgentMail (send, where agent-identity is needed), Bullhorn (read for candidate matching), LinkedIn (read)
   580	- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate, escalation router
   581	- **External APIs:** Microsoft Graph subscriptions, AgentMail
   582	- **Gate A:** draft generated within 60s of webhook receipt; classification has confidence ≥ 0.8; no auto-send on uncategorised messages
   583	- **Gate B target:** 95% within 60s; consultant edit-rate <30% on auto-sent categories; <2% wrong-classification rate
   584	- **Build complexity:** **XL** (4 weeks)
   585	- **Gotchas:** This is the most dangerous auto-send agent. Auto-send categories must be gated tightly (acknowledge-new-candidate only at v1.1 launch, expand after 30 days of clean data). Misclassification of a complaint as a routine inbound is a relationship killer. The deliverability test for AgentMail vs Microsoft Graph is the rate-limiting research.

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

codex
The first pass already found one material citation risk: the ADR names an ADR-006 path that does not exist in the repo listing. I’m checking whether that is just shorthand or a real broken reference, and whether the ESC and master-brief citations support the claimed decision.
exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# ADR-007 — Concierge Gate A 30-minute draft SLA hybrid (Gate B leading metric, not per-draft hard-fail)
     2	
     3	**Status:** Proposed (2026-05-25, Day 20; W4 bilateral pass on Concierge agent.md surfaced this as Codex R3 Finding 3 — current scaffold reframes ULTRAPLAN A6 line 566 Gate A "every lifecycle event has a draft generated within 30 minutes" as a Gate B leading metric without an authoritative ADR backing the deviation. Awaits Codex `review-architecture-decision` ratification + founder Accept.)
     4	**Author:** Founder (Maddox) + Claude Code
     5	**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A6 line 566 — Gate A 30-minute draft SLA clause
     6	**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
     7	**Driven by:** `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3 — Codex flags Concierge `agent.md` §5 line 278 reframes the 30-min SLA as Gate B without an ADR; §10 Accepted criteria omits any ADR-ratification blocker for this deviation. Analogue of ADR-006 (Diagnostic Gate A hybrid).
     8	
     9	---
    10	
    11	## Context
    12	
    13	ULTRAPLAN §8.1 A6 line 566 (pre-amendment wording):
    14	
    15	> - **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
    16	
    17	The clause implies three Gate A hard-fail conditions: (a) draft generated within 30 minutes of lifecycle event, (b) voice classifier ≥ 0.75, (c) addressee resolution correct.
    18	
    19	Concierge `agent.md` (Day-19 R3 scaffold) reframes (a) — the 30-minute draft SLA — from per-draft Gate A hard-fail to a Gate B leading metric (90% of drafts within 30 min, not per-draft hard fail). The other two clauses (voice classifier + addressee resolution) remain Gate A hard-fails. The reframe is documented in:
    20	
    21	- `agent.md` §1 output-contract (30-min framing as Gate B target)
    22	- `agent.md` §4 Step 9 (`ESC_CONCIERGE_SLA_MISS` warn, aggregated to Gate B; not per-draft block)
    23	- `agent.md` §5 lines 269-280 (Gate A excludes the 30-min SLA explicitly)
    24	- `agent.md` §6 ESC table (`ESC_CONCIERGE_SLA_MISS` registered as warn, not blocking)
    25	
    26	This creates a documented gap between the upstream spec and the v0 scaffold. Codex R3 Finding 3 (Day-19 log `logs/codex-ratification/20260524T174513Z-13185/`):
    27	
    28	> The 30-minute SLA is weakened without a ratified status-flip blocker. Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria.
    29	
    30	Per master brief §10.5 + Rule 4 (Quality gates before features), an upstream-spec amendment requires either (a) revert the scaffold to per-draft hard-fail, or (b) author an ADR ratifying the deviation. This ADR is option (b).
    31	
    32	## The deviation in detail
    33	
    34	### Why per-draft hard-fail is operationally problematic
    35	
    36	The Concierge lifecycle-event trigger source is the Bullhorn ATS state-change webhook + a polling-fallback cron (per ULTRAPLAN A6 line 569 verbatim gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks").
    37	
    38	Polling-fallback delays are not Concierge's fault — the polling cron runs at a configurable interval (likely 5-15 minutes per tenant) and a state change that happens at minute 1 of a 15-minute cycle has a 14-minute "blind spot" before Concierge ever sees it. A per-draft hard-fail Gate A would treat this as a Concierge failure even though the draft IS generated within 30 minutes of detection (just not within 30 minutes of the actual Bullhorn state change).
    39	
    40	Treating this as Gate A hard-fail would cause Concierge to drop legitimate drafts whose timing was set by upstream-detection latency, not by Concierge generation latency. The product harm: a candidate experiences a "ghosted by recruiter" pattern that Concierge was designed to prevent.
    41	
    42	### Why the metric is still load-bearing as Gate B
    43	
    44	The 30-minute SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Treating it as Gate B at the 90% threshold:
    45	
    46	- Captures the population-level SLA promise
    47	- Tolerates the occasional polling-fallback-induced delay without blocking legitimate drafts
    48	- Drives a measurable improvement signal: if 30-min-SLA-hit-rate drops below 90% across a tenant, the polling interval is too slow OR Bullhorn webhook coverage is degraded — both actionable signals
    49	- Aggregate failures fire `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) when sustained — same operational lever as ADR-006's per-claim quality metric
    50	
    51	This is structurally identical to ADR-006's Tier 1 (per-section, hard-fail at the agent level) vs Tier 2 (per-claim, quality metric over time) split — applied here to time (30-min threshold per draft = Tier 1; 90% within 30-min over rolling window = Tier 2).
    52	
    53	## Decision
    54	
    55	**Concierge Gate A is the subset of ULTRAPLAN A6 line 566 that is operationally enforceable per-draft:**
    56	
    57	- ✅ Voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82) — Gate A hard-fail
    58	- ✅ Correct addressee resolution (no candidates emailed under another's name) — Gate A hard-fail (`ESC_ADDRESSEE_MISMATCH`)
    59	- ✅ No tone-rule block-severity violations — Gate A hard-fail (`ESC_TONE_RULE_VIOLATION`)
    60	- ✅ No PII outside firm boundary — Gate A hard-fail (`ESC_PII_LEAKAGE_RISK`)
    61	- ✅ Anti-duplicate guard passed — Gate A hard-fail
    62	- ✅ All Bullhorn context fields present — Gate A hard-fail (`ESC_AGENT_OUTPUT_SHAPE`)
    63	
    64	**The 30-minute draft SLA moves to Gate B leading metric:**
    65	
    66	- 90% of drafts generated within 30 minutes of lifecycle-event DETECTION (not lifecycle-event occurrence)
    67	- Per-draft SLA miss fires `ESC_CONCIERGE_SLA_MISS` (warn, aggregated to Gate B)
    68	- Rolling 30-day per-tenant aggregate <90% fires `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) — actionable signal
    69	- Concierge ALSO records the upstream-detection-latency separately in the audit payload (`payload.detection_delay_seconds`) so the metric attribution is clean (Concierge generation latency vs upstream polling latency)
    70	
    71	**ULTRAPLAN §8.1 A6 line 566 is amended in-band per the master brief §10.3 step 4 pattern** (analogue of the in-band amendment ADR-006 made at line 496):
    72	
    73	Pre-amendment:
    74	> - **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
    75	
    76	Post-amendment:
    77	> - **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
    78	
    79	## Consequences
    80	
    81	**Positive:**
    82	
    83	1. Concierge drafts are not dropped when upstream polling-fallback latency exceeds 30 minutes
    84	2. The product UX promise of "post-state-change comms within 30 minutes" is captured at the population level
    85	3. The metric attribution is clean — operators can distinguish Concierge generation latency from Bullhorn webhook/polling latency
    86	4. Structural parity with ADR-006: per-event Gate A vs aggregate Gate B as the canonical Tier-1/Tier-2 split for time-based SLAs (replicable pattern for future agents)
    87	
    88	**Negative:**
    89	
    90	1. A per-tenant 30-minute SLA promise is harder to enforce contractually — pilot agreements must reflect that the SLA is at the population level not per-event
    91	2. Tenants with high webhook coverage will see better than 90%; tenants with webhook-coverage gaps see worse — the metric reads as Concierge quality but is partly an upstream condition. Operator must look at `payload.detection_delay_seconds` distribution to disambiguate.
    92	3. The Concierge agent.md §10 Accepted criteria must include ratification of this ADR as a blocker (closing Codex R3 Finding 3 properly)
    93	
    94	**Neutral:**
    95	
    96	4. No code or schema changes required at scaffold stage — `agent.md` already reflects the Gate B framing. Update is to ULTRAPLAN line 566 (in-band amendment) + Concierge §10 (add ADR blocker) + this ADR (new artefact).
    97	
    98	## Implementation
    99	
   100	### In-band ULTRAPLAN amendment (per master brief §10.3 step 4)
   101	
   102	Edit `docs/specs/ULTRAPLAN.md` §8.1 A6 line 566:
   103	
   104	```diff
   105	- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
   106	+ **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — 30-minute draft SLA is Gate B leading metric at 90%)*
   107	```
   108	
   109	Commit message: `amend(ULTRAPLAN A6 line 566): Gate A scope reduced; 30-min SLA → Gate B per ADR-007`
   110	
   111	### Concierge §10 amendment
   112	
   113	Add to Accepted blockers (after R3 commit `f79c018` baseline):
   114	
   115	> - **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes R3 Finding 3 structural deviation; ratifies the agent.md §5 Gate A scope vs ULTRAPLAN A6 line 566 pre-amendment language.
   116	
   117	### Audit payload extension (deferred)
   118	
   119	`decision_log.payload.detection_delay_seconds` field for Concierge action rows is not in v0.3 schema; queued for v0.4 supplement OR W10-13 build-slice schema addition (whichever ships first). Concierge `cycle.sh` v0.0 records the field; absent the constraint, it's free-form JSONB.
   120	
   121	## Open questions
   122	
   123	| # | Question | Resolution path |
   124	|---|---|---|
   125	| ADR-007-Q1 | Should the 90% threshold be per-tenant configurable, or is 90% a v1.0 fixed bar? | Recommend fixed at v1.0; v1.1 add per-tenant override via `tenant_adapters.config.concierge_sla_threshold` (new key, v0.4-pending). |
   126	| ADR-007-Q2 | Should `ESC_CONCIERGE_SLA_MISS` be a separate code, or should it reuse `ESC_GATE_B_MISS` with payload.metric='concierge_30min_sla'? | Recommend separate code for clean Telegram routing; `_GATE_B_MISS` is generic aggregate. Catalogue addition queued at W10-13 build start. |
   127	| ADR-007-Q3 | What's the polling-fallback interval default? | Per-tenant; recommend 5 min as v1.0 default; 1 min for tenants with stable webhook coverage. Documented in tools.yaml at W10-13 build. |
   128	
   129	## References
   130	
   131	- ADR-006 — Diagnostic Gate A hybrid (structural template for Tier 1 vs Tier 2 split)
   132	- ULTRAPLAN §8.1 A6 line 566 (pre-amendment authority)
   133	- `agents/recruitment/concierge/agent.md` §1, §4 Step 9, §5, §6 (Gate B framing already implemented)
   134	- `agents/_shared/escalation-codes.md` `ESC_CONCIERGE_SLA_MISS` (registered) + `ESC_GATE_B_MISS` (registered)
   135	- `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3
   136	- Master brief §1 Rule 4 (Quality gates before features) + §10.5 (ADRs are ratifiable artefacts)

 succeeded in 0ms:
     1	# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
     2	
     3	**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
     4	**Author:** Founder (Maddox) + Claude Code
     5	**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
     6	**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
     7	**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
     8	
     9	---
    10	
    11	## Context
    12	
    13	ULTRAPLAN §8.1 A1 line 496 (pre-amendment wording — before this ADR's in-band edit landed in commit `aed9d3b`):
    14	
    15	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
    16	
    17	Current line 496 (post-amendment; live as of commit `aed9d3b`):
    18	
    19	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
    20	
    21	The "no claims unsupported by source data" clause implies **per-claim citation validation** — every factual claim in the report must have a backing source link. The Diagnostic v0 implementation at `agents/recruitment/diagnostic/validate.sh` enforces **per-section citation** (regex `\[.+\]\(.+\)` requires ≥1 markdown link per section); per-claim validation is NOT implemented at v0.
    22	
    23	(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract. Their v0 implementation in `validate.sh` is partial — `validate.sh` warns and emits `validate_check_skipped=true` when the voice-classifier URL is unreachable or the firm-domain whitelist is absent, rather than hard-failing; W4-polish closes these to hard-fail per `agents/recruitment/diagnostic/agent.md` §5 honesty note. These warn-only-paths exist in v0 but are not affected by this ADR; this ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)
    24	
    25	This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
    26	
    27	1. NLP claim-extraction from the rendered Markdown report (sentence-level fact identification)
    28	2. Per-claim evidence-link matching (semantic similarity between claim and cited URL content)
    29	3. Confidence threshold tuning to avoid false rejections of well-cited paraphrases
    30	
    31	This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
    32	
    33	Bilateral founder+Claude session on 2026-05-24 (Day 19) selected option **(b) — hybrid framing** as the disposition (Cat-1 in the disagreement doc). Founder authorization via AskUserQuestion accepted: "Hybrid (Recommended): v0 = per-section, W4 = per-claim spot-check".
    34	
    35	This ADR formalises that disposition as a ratified architectural decision so future Codex rounds + agent.md §5 framing treat it as upstream-canonical, not as a downstream weakening.
    36	
    37	---
    38	
    39	## Decision
    40	
    41	### Decision 1 — Diagnostic Gate A citation validation is per-section coverage ONLY (hard-fail)
    42	
    43	Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
    44	
    45	The OTHER Gate A subchecks (voice classifier ≥ 0.75 and PII boundary) have v0 warn-only paths when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these are honesty-flagged with `validate_check_skipped=true` per the Context section above. W4-polish closes those subchecks to hard-fail. This ADR addresses only the per-section citation subcheck of Gate A; it does NOT modify the voice classifier or PII subchecks.
    46	
    47	### Decision 2 — Per-claim citation validation is a SEPARATE post-launch quality metric (NOT Gate A)
    48	
    49	The per-claim citation pipeline (NLP claim-extraction + per-claim evidence-link matching + aggregate quality metric) is **explicitly outside Gate A** in v1.0. It lands as:
    50	
    51	- A separate post-launch Diagnostic quality signal — analogous to Gate B's outcome threshold (30% discovery-call conversion) but for citation quality
    52	- Authored as a separate W4 ADR (number to be assigned at W4-polish authoring time; this ADR does NOT pre-assign a number) together with the schema supplements that define its payload key + per-tenant config field
    53	- Sampling-based (1-in-N) post-launch quality monitoring; warn-level; never blocks v0 sends
    54	- Activates after voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports
    55	
    56	**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
    57	
    58	**Rule 4 (Quality gates before features) satisfied for the per-section citation subcheck:** it is hard-fail at v0 with no warn-only paths. (Other Gate A subchecks — voice classifier + PII — retain v0 warn-only paths when upstream services are unreachable per Context note; W4-polish closes those. ADR-006 addresses only the per-section subcheck.) Per-claim quality is a separate signal, not a weakening of Gate A's per-section subcheck.
    59	
    60	---
    61	
    62	## ULTRAPLAN amendment
    63	
    64	`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):
    65	
    66	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
    67	
    68	After this ADR ratifies, the canonical interpretation is:
    69	
    70	> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — per-section citation subcheck is hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (a W4 ADR to be authored at first-pilot polish time).
    71	
    72	**In-band amendment (landed in commit `aed9d3b`):** `docs/specs/ULTRAPLAN.md` line 496 now reads verbatim:
    73	
    74	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
    75	
    76	This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
    77	
    78	---
    79	
    80	## Why hybrid not full-spec
    81	
    82	**Why not (a) defer launch until per-claim lands?**
    83	- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
    84	- A working v0 with per-section validation has measurable Gate A coverage; deferring means no Gate A at all in the meantime, which is strictly worse
    85	- The 30%-discovery-call Gate B target is independent of per-claim validation; pilot value is reachable without it
    86	
    87	**Why not (c) amend ULTRAPLAN downward permanently?**
    88	- The per-claim requirement is genuinely valuable for v1.1+ once the NLP pipeline exists
    89	- Permanently removing it from ULTRAPLAN loses the documented quality bar
    90	- Hybrid preserves the W4-polish path; permanent amendment closes that door
    91	
    92	**Why hybrid is honest signal (Rule 5):**
    93	- v0 implementation does what it says; W4 polish path is documented + scheduled
    94	- Codex flags become explicit-disposition references (this ADR) not unaddressed weakening
    95	- Pilot tenants reading Gate A spec see the v0 contract clearly + the W4 expansion plan
    96	
    97	---
    98	
    99	## Consequences
   100	
   101	### Immediate (this ADR commit)
   102	
   103	- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
   104	- `agents/recruitment/diagnostic/validate.sh` retains current per-section enforcement (no implementation change)
   105	
   106	### Next commit (after this ADR ratifies)
   107	
   108	- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
   109	- `docs/decisions/2026-05-18-codex-ratification-manifest.md` queue updated to include this ADR. NOT yet updated as of this commit; lands in the post-ratify commit.
   110	
   111	### After Codex ratifies this ADR (Status flips Proposed → Accepted)
   112	
   113	- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the original ULTRAPLAN line 496 prose alone)
   114	- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
   115	
   116	### W4-polish slice (after voice-classifier microservice ships + first pilot tenant data accumulates)
   117	
   118	- Per-claim spot-check pipeline lands as Tier 2 validate.sh extension
   119	- Sample rate configurable per tenant via field landing in the future W4-polish vertical-schema supplement (concrete field name + type specified there alongside the Tier 2 writer + sampling-activation work; NOT in v0.3 supplement — v0.3 explicitly defers per its §5 `deferred_to_future_adr` block to avoid speculative schema without a current consumer)
   120	- Aggregate metric writes to `decision_log.payload` via key landing in autosend-safety-policy §7 supplement (concrete key name specified there, not in this ADR)
   121	- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
   122	
   123	### Downstream artefact references (queued for post-ratify commit)
   124	
   125	- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
   126	- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
   127	- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
   128	- `docs/decisions/2026-05-18-codex-ratification-manifest.md` → adds this ADR as ratification queue item
   129	
   130	These edits all land in the next commit AFTER this ADR ratifies (no point updating agent.md to cite a Proposed ADR; cite once ratified).
   131	
   132	---
   133	
   134	## Open questions
   135	
   136	| # | Question | Resolution path |
   137	|---|---|---|
   138	| Q1 | Default sample rate for Tier 2 spot-check? Recommend 1-in-10 (~10% of reports validated per-claim) for first pilot; adjust based on early signal | Founder review at first-pilot W4 polish landing |
   139	| Q2 | NLP claim-extraction library — what's the right tool? (spaCy + custom rules / Claude API-based extraction / hosted service) | W4 polish technical investigation; cost vs accuracy tradeoff |
   140	| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |
   141	
   142	---
   143	
   144	## Status
   145	
   146	**Proposed.** Awaits Codex ratification via `review-architecture-decision.md` skill.
   147	
   148	Status flips Proposed → Accepted when:
   149	- Codex returns RATIFIED for this ADR
   150	- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
   151	
   152	*End of ADR-006.*

exec
/bin/zsh -lc "rg -n \"ESC_CONCIERGE_SLA_MISS|ESC_GATE_B_MISS|2\\.10|Gate B|Concierge\" agents/_shared/escalation-codes.md" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
265:- **Severity:** **blocking** — Concierge cannot send candidate emails; falls back to draft-only
273:- **Severity:** **blocking** — Concierge Outlook send disabled; drafts-only
374:### 2.10 — Agent workflow (10 codes)
375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
377:#### `ESC_GATE_B_MISS`
379:- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
383:- **Note:** Local Gate B is a leading metric for agent quality; consecutive misses inform per-agent quality review. Not tied to a kill-criterion trigger in v1.0 (per disagreement-doc Cat-3 disposition).
411:  - **Concierge:** lifecycle-event email recipient does not match the candidate_id whose state is changing (per ULTRAPLAN A6 line 566 verbatim "no candidates emailed under another's name")
414:- **Payload fields:** `agent_name`, `mismatch_class` (one of `cash_conductor_xero_bullhorn` | `concierge_candidate_email` | future variant), plus class-specific fields: Cash Conductor → `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`); Concierge → `expected_candidate_bullhorn_id`, `actual_recipient_email`, `event_type`
431:#### `ESC_CONCIERGE_SLA_MISS`
432:- **Severity:** warn — aggregated to Gate B (not a per-event block)
433:- **Trigger:** Concierge SLA breached. Three canonical sla_types:
436:  - `draft_generation`: lifecycle event → draft generated >30 min (per ULTRAPLAN A6 line 566; aggregated to Gate B per Concierge §1 disposition rather than per-event hard fail)
452:  - **Concierge:** Bullhorn state transition is outside the 12-event v1.0 taxonomy (acknowledgement / prep / debrief / placement / rejection / withdrawal / on-hold / start-confirm / 7d-checkin / 30d-checkin / 90d-checkin / nurture); handler logs + skips draft
455:- **Payload fields:** `agent_name`, `entity_type` (`placement` | `candidate_lifecycle_event`), `entity_id`, `ambiguity_class` (Janitor: e.g. `missing_end_date`, `stale_activity`; Concierge: e.g. `unknown_transition`, `out_of_taxonomy`), plus class-specific fields

exec
/bin/zsh -lc "rg -n \"§10\\.3|§10\\.5|Quality gates|Rule 4|Gate A|30 minutes|Concierge|line 566|cost target|Codex exclusion\" docs .codex README.md" in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: README.md: No such file or directory (os error 2)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1:# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:9:# Concierge schema gaps) per docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:90:          than name+email); Concierge reads for outreach context (NOT for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:96:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:107:          Concierge reads to route outbound lifecycle comms.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:111:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:118:          is in transcript. Concierge respects this when scheduling lifecycle
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:123:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:181:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:195:          to the vault file content; Concierge reads the vault file directly
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:201:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:210:          Concierge reads to adjust nurture tone.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:214:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:249:          Free-text capture of decision-timing phrases. Concierge reads to
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:254:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:294:#   - Concierge candidate: R → R+W (writes lifecycle-state-derived fields +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:296:#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:297:#   - Concierge opportunity: none → R (reads for outbound lifecycle-event context)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:298:#   - Concierge placement: R → R+W (writes Bullhorn state advancement per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:300:#   - Concierge timesheet: none → R (reads to verify placement-progress for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:302:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:304:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:402:    # (populated by Janitor + Scribe + Concierge from their Bullhorn
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:430:    # Concierge's Bullhorn endpoint access (Candidate / ClientCorporation /
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:458:    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:465:      - Concierge (R)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:478:      - Concierge (R)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:490:      - Concierge (R)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:504:      - Concierge (R)      # v0.3 NEW — reads for outbound lifecycle context
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:508:      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:512:    v0_1_v1_0_agent_access: [Janitor (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:517:      - Concierge (R+W)    # v0.3 UPGRADED — writes Bullhorn state advancement
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:519:      v0.3 upgrades Janitor + Concierge to R+W (lifecycle-state writes per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:528:      - Concierge (R)      # v0.3 NEW — reads to verify placement-progress for nurture
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:531:      Scribe + Concierge (each reads timesheet for their respective
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:535:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:541:      - Concierge (R+W)    # v0.3 UPGRADED — writes lifecycle-state-derived fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:544:      multi-source aggregation) + Concierge (writes lifecycle-state and
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:548:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:553:      - Concierge (R+W)    # v0.3 UPGRADED — lifecycle states for contractor placements
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:561:    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:562:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:568:      granted Scribe + Concierge; v0.3 extends to all 6.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:571:    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:572:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:581:    v0_2_v1_0_agent_access: [voice-drift-canary (W), Concierge (R), LoRA (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:584:      - Concierge (R)            # v0.2 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:713:    # Per §2a amendment: v0.3 expands access (Concierge R from v0.2;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:762:      Concierge polling cron updates at end of each cycle. Next poll queries
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:788:      Per-tenant outbound sending hours. Concierge respects when scheduling
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:841:      separate post-launch quality metric outside Gate A. The payload key,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:891:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:983:  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1005:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:62:      - Concierge (R — voice samples for outbound message generation)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:130:      - Concierge (R — every outbound message)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:257:          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:309:        Most-recent voice classifier score from Concierge outbound messages addressed to this contact. Drives addressee-specific drift detection (some contacts' tone preferences may differ from firm baseline).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:317:        Aggregate (last-7-day mean) voice classifier score across all Concierge messages about this brief. Drives "this brief is producing voice-drift messages — investigate" alerting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:333:        Snapshot of mean voice classifier score across all Concierge messages for the candidate during the 30 days BEFORE placement close. Captures voice quality at the moment of commercial success — drives "did voice quality predict deal close" reporting + v2.0 LoRA pipeline label generation.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:401:    trigger_for_revisit: first Concierge build (W10) — measure real retry success rate
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:441:    expected_date: post-Concierge build (W10-13) — first agent to heavily exercise voice corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.yaml:56:      - Concierge (R+W — lifecycle state per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
docs/verticals/recruitment/vertical-schema.yaml:147:          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
docs/verticals/recruitment/vertical-schema.yaml:161:      - Concierge (R+W — lifecycle state; week-1/month-1 check-ins differ for contractors per Product Spec §2.2 R7)
docs/verticals/recruitment/vertical-schema.yaml:191:        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
docs/verticals/recruitment/vertical-schema.yaml:204:        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
docs/verticals/recruitment/vertical-schema.yaml:205:        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
docs/verticals/recruitment/vertical-schema.yaml:214:        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
docs/verticals/recruitment/vertical-schema.yaml:217:      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
docs/verticals/recruitment/vertical-schema.yaml:228:      - Concierge (R — relationship context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:288:      - Concierge (R — decision-maker context per bullhorn §4.1 A6; thin in v1.0)
docs/verticals/recruitment/vertical-schema.yaml:321:        notes: v0.1 is essentially a tag for Concierge addressee-resolution gating; v1.1 Triage agent owns expansion (sub-fields for decision-domain, budget authority, etc.).
docs/verticals/recruitment/vertical-schema.yaml:334:        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:337:      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
docs/verticals/recruitment/vertical-schema.yaml:350:      - Concierge (R — linked-brief context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:410:        source: IFOS-derived (Concierge maintains based on client check-in cadence)
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:436:      - Concierge (R+W — lifecycle stage maintenance per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:480:        source: IFOS-derived (Concierge maintains per Product Spec §2.2 R7 lifecycle cadence)
docs/verticals/recruitment/vertical-schema.yaml:481:        notes: Drives Concierge nurture-event firing.
docs/verticals/recruitment/vertical-schema.yaml:492:      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
docs/verticals/recruitment/vertical-schema.yaml:592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
docs/verticals/recruitment/vertical-schema.yaml:599:    v1_0_exercise: Concierge reads to anchor lifecycle communications; Scribe reads for write-context resolution.
docs/verticals/recruitment/vertical-schema.yaml:615:    v1_0_exercise: Concierge reads for addressee-resolution per bullhorn §4.1 A6 Voice gate; addressee = primary decision-maker contact.
docs/verticals/recruitment/vertical-schema.yaml:623:    v1_0_exercise: Concierge addressee context.
docs/verticals/recruitment/vertical-schema.yaml:630:    v1_0_exercise: Concierge reads for outbound-message addressee correctness; thin in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:686:    contact: R       # read-only (Concierge owns writes)
docs/verticals/recruitment/vertical-schema.yaml:722:  Concierge:
docs/verticals/recruitment/vertical-schema.yaml:775:    notes: lifecycle_stage is IFOS-derived (Concierge maintains); Bullhorn does not natively store IFOS's nurture-cadence stages.
docs/verticals/recruitment/vertical-schema.yaml:805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
docs/verticals/recruitment/vertical-schema.yaml:835:    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.
docs/verticals/recruitment/vertical-schema.yaml:856:    rationale: v1.0 Concierge addressee-resolution uses primary-decision-maker; panel modelling adds value when v1.1 Triage handles inbound brief queries from multiple stakeholders.
docs/verticals/recruitment/vertical-schema.yaml:862:    revisit_trigger: Any Product Spec revision touching R7 nurture cadence (e.g., adding week_2 checkpoint, removing month_24, splitting month_12 into quarterly checkpoints) requires schema migration. Migration steps — (1) ALTER TABLE add new enum value(s) to entities.data JSONB validator; (2) backfill existing placement rows if semantic change (e.g., week_1 → week_1_check_in renaming); (3) Concierge nurture-event firing logic updated to match new cadence.
.codex/ratification/review-agent-bundle.md:18:| §1 | Output contract | One-paragraph screenshot per master brief §1 Rule 1. Names WHAT the agent produces in a single paragraph, readable cold | Missing; >3 paragraphs; doesn't name vault write path; doesn't name Gate A + Gate B thresholds |
.codex/ratification/review-agent-bundle.md:22:| §5 | Gates | Gate A: validate.sh hard-fail conditions. Gate B: outcome success threshold + measurement mechanism | Missing; Gate A conditions not testable; Gate B threshold not cited to ULTRAPLAN/master brief; Gate A weaker than §1 output contract |
.codex/ratification/review-agent-bundle.md:25:| §8 | Build dependencies | Prerequisites that must clear before W-X build slice can begin. Table with Status (✅ ⏸ ❌) per dep | Missing; doesn't name Bullhorn / accounting / LinkedIn commercial gates where applicable; doesn't cite Trigger 3 (Bullhorn-touching agents) or D1 (Concierge) where applicable |
.codex/ratification/review-agent-bundle.md:38:2. **ULTRAPLAN §8.1 A-N lines X-Y** for spec detail (Diagnostic = A1 lines 487+; Janitor = A2 lines 501+; Scribe = A3 lines 515+; Cash Conductor = A4 lines 529+; Sourcing Scout = A5 lines 543+; Concierge = A6 lines 557+). Verify the cited lines contain the cited content.
.codex/ratification/review-agent-bundle.md:61:**Pre-build scaffold (Status: Proposed)** — written BEFORE the sibling bundle files exist. The 5 W3-scaffold agents (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) are all pre-build scaffolds. Allowed gaps:
.codex/ratification/review-agent-bundle.md:84:- §5 Gate A conditions don't match validate.sh implementation
.codex/ratification/review-agent-bundle.md:121:- Output contract doesn't name vault path OR Gate A/B thresholds
.codex/ratification/review-agent-bundle.md:124:- Gate A weaker than §1 output contract claims
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:10:-- Concierge). v0.3 additions:
.codex/ratification/SKILL.md:26:4. **Quality gates before features** — Gate A (`validate.sh` hard-fails) + Gate B (`decision_log` mandatory writes) + autosend-safety-policy tier dispatch. Does this artefact bypass or weaken any gate?
.codex/ratification/SKILL.md:50:- **Citation accuracy** — section references like "§X.Y" MUST be verifiable. Open the cited file at the cited line/section; does the citation hold? Past violations: a Day-6 audit found 15 fabricated "master brief §10.4 cost target" references; §10.4 is actually the Codex exclusion list.
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:223:DEMO CALL         → 30 minutes with founder
docs/RISK-REGISTER.md:23:| 7 | **Master-brief-drift-accumulation** — eight ADR-driven edits + one Day-4 Postgres-rename + multiple Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all nine edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Codex ratifies the commit alongside the ten+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 + `bullhorn-integration-path.md` + `sequencing-target.md` + `brain-ui-scope.md` + Day 4 runbook §0.1. **Updated Day 4 (2026-05-17):** edit count rose from 8 to 9 with Day-4 Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations" — verified from Day-4 execution against NBG1 because FSN1 was unavailable at provisioning time). **Citation audit 2026-05-18:** earlier drafts also cited master brief §10.4 as a Hetzner/cost-target section; verified §10.4 is the Codex exclusion list ("What never goes through ratification") and contains no Hetzner or cost-target content. Edit 9 scope corrected to line 477 only. |
docs/RISK-REGISTER.md:24:| 8 | **LUKS manual unlock single-point-of-failure** — `/dev/mapper/ifos_data` is `noauto` per Day-4 §4.7; every server reboot requires founder to SSH in and run `sudo /usr/local/bin/ifos-unlock` with the LUKS passphrase. Postgres + vault are unavailable until that happens. If founder is unavailable during an unplanned reboot, the server runs but no agent work can proceed. | Low | Medium-High (Postgres dead until founder unlocks; acceptable for pilot, unacceptable at scale) | Any unplanned reboot during pilot operations where the founder is unreachable for >30 minutes | **Documented mitigation in `ifos-unlock` script at `/usr/local/bin/ifos-unlock` (Day-4 §4.7) + this risk register entry.** v1.0 accepts the trade-off — reboots rare, founder solo, single-server. **v1.2+ improvement (named):** investigate TPM-bound LUKS unsealing OR key-server-based auto-unlock (cloud-init-style retrieval from an off-box keystore). Tripwire for v1.2 work: first pilot at >1 tenant scale, or any unplanned reboot incident where Postgres downtime hurt operations. **Owner:** founder for incident detection, Claude Code for v1.2+ design. **Source:** Day-4 §0.4 LUKS Option β decision; runbook §11.2 future-risk note. |
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/architecture-cohesion-review.md:147:| G1 | **Concierge "voice corpus refresh" cadence is undefined.** When does a tenant re-index? Operator triggers? Scheduled cron? Re-index on N% recent_edit drift? | Medium (Concierge W10 dependency) | New ADR at Concierge build time OR addendum to v0.2 supplement at v1.0 schema close. Owner: Claude Code, trigger: Week-9. |
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
docs/architecture/architecture-cohesion-review.md:228:| R2 | G8: Autosend v1.0 tier enforcement | High | Founder Decision D1 | Founder | Pre-Concierge W10 |
docs/architecture/architecture-cohesion-review.md:233:| R7 | G1: Voice corpus refresh cadence | Medium | New ADR-006 at Concierge build OR addendum to v0.2 supplement at v1.0 schema close | Claude Code | Week-9 (pre-Concierge) |
docs/architecture/architecture-cohesion-review.md:257:1. Founder Decisions D1 + D2 + D3 resolve before Concierge W10 + first pilot LOI signing
docs/architecture/agent-bundle-renderer-design.md:25:├── validate.sh                         # Gate A — sources _shared/hook-helpers.sh
docs/architecture/agent-bundle-renderer-design.md:43:| `agent.md` (line 552) | Output contract first; then workflow, gates, escalation. Master brief §1 Rule 1: "Every agent ships with its output contract written first, as a one-paragraph screenshot description." | the renderer (synthesises into `CLAUDE.md` per §2.1); humans for code review | **Static** — founder writes once; iterated per Codex ratification (master brief §10.5 names every new `agent.md` as always-ratify) |
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:97:The two layouts share no files by name except `tools.yaml` (which the IFOS bundle uses for MCP servers and which Claude Code consumes at PTY spawn). cortextOS expects `config.json` (runtime config), `CLAUDE.md` (Claude Code's entry point), `.env` (Telegram credentials + secrets); IFOS provides `config.schema.json` (a *schema* for per-tenant config, not the materialised config itself), `agent.md` (the output contract + workflow, not a Claude Code entry point), and no `.env` (credentials live per-tenant). The bundle's `validate.sh` and `context.sh` have no cortextOS analogue — they implement IFOS-side Gate A and context-assembly per master brief §8.1 Changes 1+2, and need a defined invocation mechanism (Spec gap §1.1-A). The bundle's `tests/fixtures/` are CI-only and have no runtime counterpart in cortextOS. **Translation is required for three of the six bundle files** (`agent.md` → `CLAUDE.md` with cortextOS-required preamble synthesised in; `config.schema.json` → `config.json` materialised with per-tenant values from `/vault/{tenant}/_config.yaml`; `validate.sh` + `context.sh` → rendered into a hook location the agent can invoke). `README.md` and `tools.yaml` pass through. Fixtures stay in the source repo.
docs/architecture/agent-bundle-renderer-design.md:123:- **§2.1-A:** master brief §8.1 does not specify what the **cortextOS preamble template** looks like — the wrapper around `agent.md` that becomes `CLAUDE.md`. Recommended resolution: pin a canonical preamble at `packages/agent-renderer/templates/claude-md-preamble.md` (rendered with tenant + agent variables); preamble content must (a) tell Claude Code to source `.claude/hooks/context.sh` at session start, (b) tell Claude Code to call `.claude/hooks/validate.sh` before any tool invocation (Gate A), (c) list the env vars the agent should expect (`CTX_TENANT_SLUG`, `CTX_AGENT_NAME`, `CTX_ORCHESTRATOR_AGENT`, etc.), (d) reference `agent.md` body verbatim, (e) **not** reference IDENTITY.md / SOUL.md / MEMORY.md / GOALS.md / etc. because they will not exist. A draft preamble lives in §2.3 worked example below.
docs/architecture/agent-bundle-renderer-design.md:145:| `heartbeat` | cortextOS heartbeat cadence — periodic `update-heartbeat` writes to `${ctxRoot}/heartbeats/{name}.json` so the dashboard sees "alive" status | IFOS agents emit heartbeats too (the daemon's fast-checker writes them per `agent-process.ts:597-639` session timer), but the *cadence* and *what the agent does at each heartbeat* is specced per-agent in `agent.md` (Concierge always-on; Janitor cron-driven; etc.). The cortextOS-template `heartbeat/SKILL.md` is a default playbook — IFOS replaces with per-agent specifics |
docs/architecture/agent-bundle-renderer-design.md:163:### 2.3 — Worked example: rendering Concierge (A6)
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:186:# Concierge
docs/architecture/agent-bundle-renderer-design.md:192:Every lifecycle event → draft within 30 minutes, voice score ≥ 0.75, correct
docs/architecture/agent-bundle-renderer-design.md:207:  within 30 minutes in firm voice (classifier score ≥ 0.75), addressed to
docs/architecture/agent-bundle-renderer-design.md:224:# Concierge — agent definition
docs/architecture/agent-bundle-renderer-design.md:243:  "title": "Concierge per-tenant configuration",
docs/architecture/agent-bundle-renderer-design.md:307:# Gate A: hard-fail on missing hh_decision_* calls in this run
docs/architecture/agent-bundle-renderer-design.md:354:# Concierge — Acme Recruitment
docs/architecture/agent-bundle-renderer-design.md:367:A non-zero exit from validate.sh blocks the action (Gate A; master brief §1 Rule 4).
docs/architecture/agent-bundle-renderer-design.md:431:# Telegram (per Concierge's per-agent bot per cortextOS Primitive 5)
docs/architecture/agent-bundle-renderer-design.md:615:`ifos-render-agent render <agent-name> --tenant <slug>` — one render per call. To render Concierge across three tenants, three invocations. Scriptable via bash `for tenant in acme bravo charlie; do ifos-render-agent render concierge --tenant "$tenant"; done`.
docs/architecture/agent-bundle-renderer-design.md:636:**Recovery:** stderr lists the failed validation path (e.g. `properties.nurture_cadence.post_interview_chase_hours: expected integer, got string`). Founder edits `/vault/<tenant>/_config.yaml` or the `config.schema.json` source (rare; schema edits go through Codex ratification per master brief §10.5). Re-runs render.
docs/architecture/agent-bundle-renderer-design.md:729:6. The agent runs as a **cortextOS-template agent**, NOT as IFOS Concierge. It has `MEMORY.md`, `IDENTITY.md`, `knowledge-base` skill, etc. — none of which IFOS expects.
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/cortexos-primitive-status.md:22:| 1 | Persistent PTY via PM2 | **shipped but flaky** | Cash Conductor (A4), Concierge (A6) |
docs/architecture/cortexos-primitive-status.md:23:| 2 | 71-hour context rotation | **shipped and tested** | Concierge (A6) |
docs/architecture/cortexos-primitive-status.md:25:| 4 | Approval gates | **shipped and tested** | Cash Conductor (A4), Concierge (A6); standing-auth not in cortextOS — IFOS-layer concept |
docs/architecture/cortexos-primitive-status.md:61:- Master brief §2.4 row 1: used by Triage, Concierge, Pulse, Watchtower, Cash Conductor.
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:66:**Risk if flaky:** Tier-1 always-on agents collapse to scheduled cron with cold-start latency, eliminating the "sub-second to first useful action" claim that justifies pricing the Triage/Concierge/Pulse demos above point-tool parity (Ultraplan §3.2). Per Ultraplan §3.1 row 1, the documented contingency is: "Ship the v1.0 agents as scheduled cron with a documented migration path. Loses the Triage closing demo but keeps the build moving." Quirk 2 (`.agents/learnings/00-cortextos-quirks.md`) — `node-pty` requires `npm rebuild` on Node 25+ — is the most likely re-trip wire because the Mac Studio cluster nodes for the v2.0 Sovereign tier may not run Node 22 LTS by default.
docs/architecture/cortexos-primitive-status.md:109:- `src/daemon/fast-checker.ts:898-908` — circuit breaker (`ctxCircuitRestarts`, `ctxCircuitBrokenAt`) pauses auto-restarts for 30 minutes if context-triggered restarts pile up (persisted to disk so it survives `--continue` restarts per line 994).
docs/architecture/cortexos-primitive-status.md:120:- Master brief §2.4 row 2: Concierge (cross-week candidate conversations), Watchtower (per-contractor state), Pulse (multi-source watching).
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:124:**Risk if flaky:** Concierge loses cross-week candidate conversation context at the 71-hour boundary or at API overflow; rejection drafts lose the prior-state nuance that defines Gate A voice quality on the hardest test case (Ultraplan §8.1 A6 gotcha: "Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship"). Per Ultraplan §3.1 row 2, the documented contingency is: "Manual restart cadence acceptable for v1.0 pilots; flag as known limitation in pilot agreement."
docs/architecture/cortexos-primitive-status.md:182:1. **No `chokidar` watcher in the bus.** The bus is poll-based, not push-based. `grep -rn chokidar src/` returns zero hits; `chokidar@^5.0.0` in `package.json:47` is used only by `dashboard/src/lib/watcher.ts:5` for the dashboard UI's file change feed, not for inter-agent message delivery. Master brief §2.4 row 3's "chokidar watcher in daemon" is incorrect against the verified SHA. The actual dispatcher is `FastChecker` polling at `pollInterval` (default 1000ms, configurable). Operational impact: message-delivery latency is bounded by the poll interval, not zero-latency event-driven; relevant for the Brief Decoder → Sourcing Scout → Concierge "four-agent pipelines complete in seconds" claim (Ultraplan §3.2). With 1s polling per hop and 3 hops, end-to-end is ≥3s, not sub-second.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:255:- Master brief §2.4 row 4 + §3.4 + Product Spec §6.1 row 4: every agent that auto-sends. Triage, Concierge, Cash Conductor, Competitor Interception, Spec Pitcher, T1 Onboarding Concierge — all depend on the approval gate to graduate from drafts-only.
docs/architecture/cortexos-primitive-status.md:256:- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
docs/architecture/cortexos-primitive-status.md:324:- Master brief §2.4 row 5: every Tier-1 agent's escalation path. Triage, Concierge, Cash Conductor, Pulse, Watchtower, Brief Decoder, Competitor Interception, Night Sourcer, T5, Timesheet Ranger — they all escalate via Telegram and approve via Telegram inline buttons.
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:30:Four mechanisms address these four failure modes in §2-§5. **All four mechanisms must be implemented in `wiki/lib/concurrency.ts`** for the wiki API to ship in v1.0 weeks 11-13 per `sequencing-target.md` §4.1 row 6 (Concierge, the heaviest concurrency stressor).
docs/architecture/second-brain-design.md:197:| `_voice/style-guide.md` | one file | markdown | fixed name | Onboarding wizard Day 3 (founder); Concierge edits via Brain UI v1.1+ | every agent's `context.sh` via `_shared/voice-loader.sh` (Ultraplan §6.1 line 322) |
docs/architecture/second-brain-design.md:204:| `wiki/raw/calls/` | one file per call | markdown with frontmatter | `{epoch}-{call-id}.md` | Scribe (v1.0) on Fathom/Fireflies webhook | Brief Decoder (v1.1), Concierge (v1.0) |
docs/architecture/second-brain-design.md:207:| `wiki/raw/ats-snapshots/` | one file per entity sync | JSON | `{epoch}-{bullhorn-entity-type}-{bullhorn-id}.json` | Janitor (v1.0) on nightly sweep | Janitor itself (diff vs previous), Concierge (v1.0) for entity reconciliation |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:210:| `wiki/compiled/clients/{slug}.md` | one per Client | same | same | Janitor (v1.0) on first contact | Cash Conductor + Concierge (v1.0) |
docs/architecture/second-brain-design.md:212:| `wiki/compiled/placements/{slug}.md` | one per Placement | same | same | Concierge (v1.0) on placement event | Cash Conductor (v1.0) for invoice context; future Pulse |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:236:| Client | **v1.0** | Janitor + Cash Conductor + Concierge all require it |
docs/architecture/second-brain-design.md:238:| Placement | **v1.0** | Concierge (v1.0 A6) produces; Cash Conductor (v1.0 A4) reads for invoice context |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:266:do_not_contact: false                                # required; defaults to false; respected by Concierge
docs/architecture/second-brain-design.md:277:{auto-appended by Concierge / Scribe — chronological, agent-attributed}
docs/architecture/second-brain-design.md:422:| `search-by-name` | Concierge (v1.0): name → Candidate page on inbound message | v1.0 | `(entity_type: str, name_query: str, tenant_id: str)` | `List[EntityRef]` ranked by match score | sub-second | Fuzzy match (Levenshtein + token set); falls through to `search-by-attribute(display_name=...)` for exact. Postgres `entity_graph` indexed read. |
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:427:| `update-entity` | Concierge (v1.0): append conversation note to Candidate page | v1.0 | `(id: str, section: str, content: str, tenant_id: str)` | `EntityRef` | few seconds | Targets the `<!-- BEGIN auto:{section} -->` block per §2.2.1; preserves frontmatter; rewrites backlinks if `display_name` changes; `hh_decision_*` called |
docs/architecture/second-brain-design.md:428:| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
docs/architecture/second-brain-design.md:708:- t=0: Concierge calls `append-to-narrative(candidate_sarah_bowen, "Sent follow-up email")`. Acquires `sarah_bowen.md.lock`. Reads file. Reads `updated_at = T0` from Postgres.
docs/architecture/second-brain-design.md:710:- t=0+300ms: Concierge releases flock after writing the narrative line and updating Postgres (`updated_at = T1`). The atomic file rename completes.
docs/architecture/second-brain-design.md:711:- t=0+301ms: Janitor acquires flock. Reads file (now contains Concierge's append). Reads Postgres (`updated_at = T1`). Computes new frontmatter. Writes file atomically. Postgres UPDATE `WHERE updated_at = T1` succeeds (`updated_at = T2`).
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:755:- `search-by-name` — Concierge inbound message processing; the customer-facing latency claim ("60-second response" per Product Spec §2.2 R1) depends on this returning in <100ms.
docs/architecture/second-brain-design.md:757:- `append-to-narrative` — Concierge / Scribe logging; tolerates few-hundred-ms.
docs/architecture/second-brain-design.md:771:| Concierge | 20:1 | reads candidate state on every lifecycle event; writes only on event transitions |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:913:- **Persistent server state.** Option β's long-running process could cache hot reads, hold prepared statements, maintain pgvector connection pools. Option α pays a fresh Node startup per call (~80-200ms). For v1.0 expected volume (Concierge ~10 lifecycle events/day per tenant × 3 tenants × 5 wiki reads each = 150 calls/day per machine), the cumulative startup cost is ~30 seconds/day. Acceptable. **If hot-path latency becomes a constraint at v1.2+**, we can introduce a persistent CLI daemon (`wiki-cli --daemon`) that pre-warms — a future optimisation without changing the agent surface.
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
.codex/ratification/review-schema-change.md:80:`agent_access_matrix:` must list every v1.0 agent (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) + state R / W / R+W / none for every entity_type.
.codex/ratification/review-schema-change.md:89:- `Concierge` must have R+W on `candidate` + `placement` per §4.1 A6
docs/operations/bullhorn-outreach-emails.md:44:> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
docs/operations/w4-bilateral-pass-6-agent-md.md:40:| 6 | Concierge | 4 | Depends on Concierge-Gate-A ADR (W4 #3) — may defer to that ADR. |
docs/operations/w4-bilateral-pass-6-agent-md.md:60:### Finding 3. Gate A failure signature incomplete
docs/operations/w4-bilateral-pass-6-agent-md.md:84:### Finding 1. Gate A failures misrouted to single ESC code
docs/operations/w4-bilateral-pass-6-agent-md.md:86:  - **Codex says:** "Line 187 says `ESC_AGENT_OUTPUT_SHAPE` applies to 'ALL Gate A conditions,' including voice classifier, PII, and write-batch size. The catalogue defines `ESC_VOICE_DRIFT` for classifier failures and `ESC_PII_LEAKAGE_RISK` as blocking for PII leakage; downgrading PII to `ESC_AGENT_OUTPUT_SHAPE` weakens Gate A routing. Fix §5 so each Gate A condition maps to its catalogue code, reserving `ESC_AGENT_OUTPUT_SHAPE` for report/output-shape failures only."
docs/operations/w4-bilateral-pass-6-agent-md.md:98:  - **Codex says:** "Lines 135-137 say Janitor queries the `recent_edit` v0.2 table directly, but v0.2 access lists only voice-drift-canary, Concierge, and LoRA; Janitor R access is added in v0.3 supplement §2. Fix the citation to v0.3 supplement and add v0.3 schema/migration ratification as a §8 prerequisite."
docs/operations/w4-bilateral-pass-6-agent-md.md:144:### Finding 2. Concierge/D1 dependency under-specified
docs/operations/w4-bilateral-pass-6-agent-md.md:146:  - **Codex says:** "Line 380 says Cash Conductor only depends on Concierge `agent.md` being Accepted, but lines 235-253 require Concierge to receive drafts, run the approval bridge, transport sends, and callback; line 244 also cites the unresolved D1 path. Add Founder Decision D1 resolved + autosend bridge/Concierge transport availability as explicit prerequisites, or rewrite §4 to use the existing shared autosend approval helper without Concierge."
docs/operations/w4-bilateral-pass-6-agent-md.md:147:  - **Likely:** FIX-IN-PLACE. Add to §8 prereqs: (a) D1 resolved, (b) Concierge autosend-bridge live. Note: D1 is W4 queue #4 — this finding documents the dependency in the agent.md but does NOT block ratification of the scaffold (Status will be Proposed→Pre-Build pending D1).
docs/operations/w4-bilateral-pass-6-agent-md.md:194:## 6. Concierge — `agents/recruitment/concierge/agent.md`
docs/operations/w4-bilateral-pass-6-agent-md.md:206:  - **Codex says:** "Line 67 says 'an email draft (orange tier)', but lines 102 and autosend-policy define `concierge_email_draft` as yellow; only the send actions are orange. This creates an internal contract conflict for Gate A/B and decision_log rows. Change line 67 to 'email draft (yellow tier); send is separate orange-tier action'."
docs/operations/w4-bilateral-pass-6-agent-md.md:211:  - **Cite:** §10 lines 417-421; cross-ref ULTRAPLAN A6 line 566 + lines 206-212/276
docs/operations/w4-bilateral-pass-6-agent-md.md:212:  - **Codex says:** "Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria. Either keep the 30-minute SLA as Gate A, or add the Concierge-Gate-A ADR ratification as an explicit Accepted blocker."
docs/operations/w4-bilateral-pass-6-agent-md.md:213:  - **Likely:** **SCOPE-EXPAND**. This is the analogue of ADR-006 for Diagnostic. W4 queue #3 already plans this ADR ("Future ADR — Concierge Gate A 30-min SLA hybrid"). Disposition options:
docs/operations/w4-bilateral-pass-6-agent-md.md:214:    - (a) Add Concierge-Gate-A-ADR to §10 Accepted blockers; flip Concierge agent.md → RATIFIED (but Status stays Proposed pending ADR). W4 #3 then writes the ADR + closes the loop.
docs/operations/w4-bilateral-pass-6-agent-md.md:228:1. **Hh_decision_* coverage** (Scribe #2, Concierge #1) — workflow narratives are dropping the decision-log writes between numbered steps. After this pass, recommend a one-shot grep on all 6 agent.md to confirm every workflow step that produces output/action has an `hh_decision_*` annotation.
docs/operations/w4-bilateral-pass-6-agent-md.md:234:4. **Concierge Gate-A ADR** (Concierge #3) — only structural finding. Recommend writing the ADR before flipping Concierge to RATIFIED (analogue of ADR-006 process).
docs/operations/w4-bilateral-pass-6-agent-md.md:255:- [ ] Remaining agents have concrete blockers documented (e.g., "Concierge pending Concierge-Gate-A ADR")
docs/operations/w4-day-20-founder-runbook.md:27:**Why:** Per master brief §10.5, "every Postgres migration touching tenant
docs/operations/w4-day-20-founder-runbook.md:31:read of §10.5 (it executes DDL against live data).
docs/operations/w4-day-20-founder-runbook.md:113:6. Concierge (4 findings) — depends on Concierge-Gate-A ADR (W4 item #3)
docs/operations/w4-day-20-founder-runbook.md:119:- **SCOPE-EXPAND** — finding reveals new ADR-worthy decision (e.g., Concierge-Gate-A)
docs/operations/w4-day-20-founder-runbook.md:131:W4 queue items #3 + #4. Concierge-Gate-A 30-min SLA hybrid ADR is needed
docs/operations/w4-day-20-founder-runbook.md:132:before Concierge agent.md can flip Status to Accepted. D1 founder decision
docs/operations/w4-day-20-founder-runbook.md:133:on autosend orange-tier path blocks Concierge build slice. Both are session
docs/operations/w4-day-20-founder-runbook.md:134:prerequisites for the Concierge bundle render; neither blocks Diagnostic.
docs/operations/goal-option-c-diagnostic-end-to-end.md:34:2. **The report passes Gate A (validate.sh)** clean: 12 sections present, ≥1 citation per section, word count 400-2000, no banned phrases (V3 voice classifier passes OR skipped with explicit warning if `IFOS_VOICE_CLASSIFIER_URL` unset for v0).
docs/operations/goal-option-c-diagnostic-end-to-end.md:210:Acceptance: `bash agents/recruitment/diagnostic/cycle.sh --firm "Test Firm Name" --tenant migration-test` produces a draft at /tmp/... and Gate A passes (V3 warning only).
docs/operations/goal-option-c-diagnostic-end-to-end.md:241:- Confirm Gate A passed
docs/operations/goal-option-c-diagnostic-end-to-end.md:281:- Gate A verdict
docs/operations/goal-option-c-diagnostic-end-to-end.md:308:| Web scraper hits a JS-heavy site that returns no text | Expected (gotcha §6.1); §2 reports "site requires JS, signal unavailable"; counts as graceful degradation (fixture 02 already verifies this); no Gate A impact. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:312:| Real run reveals Gate A V3 voice classifier was actually needed (skipped warning was too lenient) | Surface as W4 polish item; do not block the milestone. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:332:- Any reduction in Gate A strictness
docs/operations/goal-option-c-diagnostic-end-to-end.md:341:- [ ] Gate A passes (V3 warning only, all others pass)
docs/operations/goal-option-c-diagnostic-end-to-end.md:384:Gate A:            PASS (V3 warning — voice classifier skipped per scaffold)
docs/operations/codex-ratification-guide.md:200:2. Citation §10.4 incorrect — master brief §10.4 is the Codex exclusion list, not the cost target the ADR cites. Past pattern of 15 fabricated §10.4 references; verify line numbers before citing. Citation: ADR-001 line 47.
docs/operations/codex-ratification-guide.md:373:The disagreement doc itself becomes a ratifiable artefact in a future round (master brief §10.5 recursive ratification). That's by design — the disagreement IS the signal.
.codex/ratification/review-architecture-decision.md:66:If even one citation is wrong, REJECT with the specific citation listed. Past pattern: `master brief §10.4 cost target` cited 15 times; §10.4 is actually the Codex exclusion list with no cost-target content.
.codex/ratification/review-architecture-decision.md:143:- **Over-elaborated worked examples** — a 200-line "Concierge worked example" inside an architecture decision is a red flag for masking a thin decision underneath. Skim the worked example; if the decision itself is < 50 lines, REJECT and demand more decision-content.
docs/operations/codex-round-2-remediation-prompt.md:36:  4. docs/build-brief/00-MASTER-BRIEF.md §10.3 (≤2 round-trip ceiling —
docs/operations/codex-round-2-remediation-prompt.md:407:Per master brief §10.3 step 5: Round 3 is the LAST automated round.
docs/operations/codex-round-2-remediation-prompt.md:433:     Per master brief §10.3, this is the last automated round. Confirm
docs/operations/codex-round-2-remediation-prompt.md:525:  Round 3 ratification (≤2 round-trips per master brief §10.3): 10 items
docs/operations/codex-round-2-remediation-prompt.md:634:**Round 3 ratification:** 10 corrected items re-ratified against appropriate skills. Hard-ceiling enforced per master brief §10.3 step 5.
docs/operations/codex-round-2-handoff.md:104:| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | `review-architecture-decision` | **Recursive ratification per master brief §10.5.** Codex either RATIFIES the disagreement (D5 was correct) OR REJECTS (insists on strict skill). Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:200:ratification per master brief §10.5. Decide whether Claude's counter-argument
docs/operations/codex-round-2-handoff.md:292:Hard ceiling: 2 round-trips (master brief §10.3 step 5). After Round 2, no Round 3 — escalate to founder for explicit decision.
docs/operations/codex-round-2-handoff.md:332:Any Round-2 REJECTED items get their own row in the manifest queue updated to "REJECTED→ROUND-3-pending OR founder-escalated". Per §10.3 master brief: no Round 3 until founder decides.
docs/operations/codex-round-2-handoff.md:406:Manifest queue position: this protocol document itself joins the queue as a Round-3 candidate (recursive ratification per master brief §10.5).
docs/operations/codex-ratification-execution-plan.md:97:- [ ] Quality gates before features
docs/operations/codex-ratification-execution-plan.md:274:    'round_trip', $5,                     -- 1 or 2 per §10.3
docs/operations/codex-ratification-execution-plan.md:317:Per master brief §10.3 step 5:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:1:# Codex disagreement — Diagnostic Gate A citation requirement + 4 follow-on findings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:5:**Codex rounds completed:** Round 4 (initial REJECTED, 4 issues) + Round 5 (remediation REJECTED, 5 issues including 2 re-raises and 3 new findings) — **hard ceiling per master brief §10.3 step 5 reached**.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:17:Per master brief §10.3 step 5: **≤2 round-trips max per artefact**. Round 5 was the second round-trip. **Hard ceiling reached.** Founder arbitration required to close the artefact.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:23:### Issue 1 (RE-RAISE) — Gate A citation requirement strength
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:25:**Codex says:** "Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires 'no claims unsupported by source data.' This lowers a stated Gate A constraint."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:31:Option A — **Tighten Gate A to per-claim citation** (matches Ultraplan). Requires implementing per-claim citation validation in `validate.sh` (significant logic; W4 polish item but Codex says it should be Gate A v0).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:35:Option C — **Hybrid:** v0 Gate A = per-section (current); Gate B (post-launch quality signal) = per-claim spot-check sampling. Document this two-tier policy explicitly.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:45:**Recommendation:** **Accept Codex finding.** Mechanical fix needed in next remediation round (if founder authorises beyond hard ceiling) OR W4 polish (recommended — bundles with broader Concierge notification work).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:90:2. **Accept Issue 2 fix** (mechanical; bundles with Concierge notification work)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:123:| Concierge | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T1025...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:127:1. **Gate A vs ULTRAPLAN source-data citation strength** — every agent.md narrowed Gate A to per-section citation; ULTRAPLAN-equivalent requirements expect per-claim. Same issue, same disposition recommendation as Diagnostic Issue 1 — hybrid v0 per-section + W4 polish per-claim spot-check.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:131:5. **§5 honesty about validate.sh implementation** — agent.md §5 sections describe Gate A behaviour that may not be implemented in the corresponding `validate.sh`. For Diagnostic, validate.sh exists + has gaps (Issue 5). For the 5 new scaffolds, validate.sh DOESN'T exist yet — §5 describes intent. Disposition: explicitly mark "intended behaviour; cycle.sh + validate.sh implementation at W-X build will deliver this" in §5 of each pre-build scaffold.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:144:- Per-claim Gate A validation is genuinely hard to automate (NLP claim-extraction + per-claim evidence linkage); the hybrid v0+W4 path is the industry-standard approach.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:147:- §5 honesty (Issue 5) is exactly the kind of "honest signal" the master brief §1 Rule 5 demands; framing §5 as "intended behaviour, build slice will deliver" is more honest than asserting Gate A as already-implemented.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:165:**Empirical confirmation of the pattern documented in master brief §10.3 step 5:** Codex finds new issues at each round. Hard ceiling of ≤2 round-trips is the right structural protocol. Further autonomous Claude remediation passes will continue surfacing new issues that may not have been visible at earlier rounds (each fix changes the document, exposing different inconsistencies).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:186:Despite master brief §10.3 step 5 protocol saying founder review after Round 5, Round 6 attempted with all Round-5 issues remediated (commit `aaa376d`). Round 6 returned REJECTED with **4 new findings**, none of which appeared in any prior round:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:202:**21 unique issues across 4 rounds, ZERO repeats.** Master brief §10.3 step 5 hard ceiling exists for exactly this reason — each remediation pass surfaces issues that weren't visible at prior rounds because the document changes.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:229:**Round 7 findings 1 + 2 + 3 + 4 are all CAUSED BY my Round 6 fixes.** When I fixed one section, I introduced inconsistencies between it and other sections referencing the same concept. This is the perfect illustration of why master brief §10.3 step 5 caps round-trips: each fix changes the document, and the changed document has new inconsistencies between the fixed-section and the related-but-unfixed sections.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:235:Master brief §10.3 step 5 cap = 2 round-trips. The hook has requested 5 rounds. Each beyond round 2 has produced 4-5 new findings. The protocol is right; the hook contradicts it.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:250:- autosend-policy.yaml: 29 → 41 action_types (8 status markers + 1 Cash Conductor reconciliation + 1 Concierge email draft + 2 added during Phase 2)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:256:- Cat-1 (Gate A hybrid): Diagnostic §1 verified already correct
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:264:- §1 vault path additions: Scribe + Concierge
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:277:| Concierge | 7 | `20260524T113247Z-86019` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:283:- Concierge AgentMail adapter-boundary violation (master brief §3 red line) — replaced all 5 references with "agent-identity email adapter (deferred)"
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:284:- Sourcing Scout ULTRAPLAN A5 line refs: Gate A 553→552, Gate B 554→553 (4 citation sites)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:297:- `ESC_ADDRESSEE_MISMATCH` — Concierge uses for candidate email mismatch; catalogue defines for Cash Conductor invoice mismatch. Resolution: widen catalogue definition to cover both use cases (candidate vs invoice addressee resolution).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:299:- `ESC_LIFECYCLE_STATE_UNKNOWN` — Concierge uses for taxonomy misses; catalogue defines for Janitor placement ambiguity. Resolution: widen.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:319:  - Concierge Steps 7, 11
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:326:**Phase 1 + Phase 2 + Phase 3 (Round 8 + Cat-α inline fixes) constitute the documented "Path A — bilateral session per master brief protocol" outcome.** No further autonomous remediation rounds will be attempted per the master brief §10.3 step 5 hard ceiling and founder's "no more rounds" authorization.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:355:- `ESC_ADDRESSEE_MISMATCH` — now covers both Cash Conductor xero/bullhorn + Concierge candidate-email (mismatch_class field)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:357:- `ESC_LIFECYCLE_STATE_UNKNOWN` — both Janitor placement + Concierge taxonomy out-of-bounds
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:375:| Concierge | 7 | 5 | −2 (AgentMail boundary + ESC widening) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:378:**Cumulative empirical (10 rounds total):** ~75 unique findings catalogued; ~7 closed via Cat-α + Cat-γ + Cat-δ inline this session; convergence rate ~10% per round. The pattern documented in master brief §10.3 step 5 holds.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:383:1. Gate A per-claim vs per-section: STILL flagged despite Cat-1 hybrid disposition; this is a Codex–founder disagreement, not relitigation of Cat-1 (founder's hybrid stance documented but Codex doesn't accept the bilateral-disposition framing as an in-band acceptance of weakening). **Disposition: founder-decision; flagged as Cat-ζ "Cat-1 framing not auto-accepted by Codex".**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:384:2. §1/§3 vs §5 internal inconsistency on Gate A hard-fail vs warn+skip — Cat-α (Diagnostic's hybrid framing introduced §1/§5 contradictions that need explicit reconciliation)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:398:**Cat-ζ — Codex does not accept bilateral-disposition framings as in-band Gate A acceptances.**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:400:When founder authorizes a Cat-1 hybrid disposition (per-section v0 + per-claim W4), the agent.md prose explicitly documents this. Codex re-flags it as "Gate A weakens upstream requirement" regardless. This is structural — Codex reviews agent.md against ULTRAPLAN/master brief, and bilateral disposition documents at `docs/decisions/codex-disagreement-*.md` are downstream artefacts Codex doesn't auto-trust.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:409:### Decision — stop Codex looping per master brief §10.3 step 5
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:411:The pattern (Round 4 → Round 9; 10 rounds; 75+ unique findings; ~10% net convergence per round) empirically confirms master brief §10.3 step 5. Each remediation pass surfaces new issues at roughly the same rate it closes old ones — because the document keeps changing.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/decisions/sequencing-target.md:26:| A6 | Concierge | 10-13 | Bullhorn + MS Graph + AgentMail | "First Tier-1 always-on closing demo; 4-week build" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:71:- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
docs/decisions/sequencing-target.md:74:Recommended sequence in §4 must remain **operationally coherent under both contingencies.** A sequence that breaks (e.g. one that ships Concierge before Janitor) would lose the Risk #2 contingency because dropping Janitor would orphan the already-shipped Concierge's data flow. The §4 recommendation explicitly validates against both contingencies.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:110:| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
docs/decisions/sequencing-target.md:113:| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:126:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Concierge consumes Scribe-generated Notes for context per `bullhorn-integration-path.md` §4.1 row 4 ("Note (prior-comms history)"). Scribe must ship before Concierge | Medium-High criticality |
docs/decisions/sequencing-target.md:137:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #1** (cortextOS primitives 1, 4, 5 — the three flagged "shipped but flaky" per cortextos-primitive-status.md). Critical gate for the v1.0 always-on agents that follow (Concierge) — if Cash Conductor surfaces primitive flakiness, the v1.0 scope-cut contingency (Ultraplan §10 row #1: degraded-mode fallback) activates before Concierge invests 4 weeks |
docs/decisions/sequencing-target.md:153:| 4. Commercial value | **Medium** | Per Product Spec §2.2 R5: "Shortlist in 15 minutes instead of by end of week." Less commercially load-bearing than Janitor/Scribe/Concierge — request-response not always-on, so less of a closing-demo asset. Sales narrative is "cuts intake-call-to-first-shortlist time from same-week to same-hour" |
docs/decisions/sequencing-target.md:159:### 2.6 — A6 Concierge
docs/decisions/sequencing-target.md:164:| 2. Substrate exercise | **Maximum** | **All** of cortextOS Primitives 1+2+4+5 exercised. **First exercise of Primitive 2** (71-hour context rotation per Day 1 cortextos-primitive-status.md) — Concierge holds long-running state across 24+ months of candidate lifecycle. First Bullhorn webhook exercise per Day 2 §4.2 (with 5-minute polling fallback). Per `bullhorn-integration-path.md` §4.1 row 4: reads Candidate, ClientCorporation, JobOrder, Placement, Note + writes Note, Candidate state-fields, Placement state-fields |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:186:W10-13: Concierge (A6)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:197:- Risk #5 final reduction (all 5 bundles render cleanly) waits for Concierge W10-13.
docs/decisions/sequencing-target.md:198:- Bullhorn webhook coverage gaps surface only at Concierge W10-13 (Ultraplan §8.1 line 569 caveat).
docs/decisions/sequencing-target.md:200:**Cost if deferred risk materialises late:** if Bullhorn webhook coverage is worse than expected (Risk #2 secondary), Concierge polling cadence increases (per Day 2 §4.2 fallback) — connector-internal change, no agent rework. Bounded.
docs/decisions/sequencing-target.md:208:W5-8: Concierge (A6) — front-load the flagship (XL/4 weeks)
docs/decisions/sequencing-target.md:215:**Why this ordering:** Get the flagship demoable agent (Concierge) live earliest to accelerate first-pilot conversion per Ultraplan §9 line 725 target Week 12.
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:220:2. **Risk #1 derisk pushed to W12-13.** Cash Conductor's Tier-1 Primitives 1+4+5 first-exercise happens after Concierge's 4-week XL build. If Risk #1 materialises at W12-13, the entire v1.0 production-critical surface is at risk with no Hire-#1-takeover slot for Cash Conductor.
docs/decisions/sequencing-target.md:221:3. **Hire-#1 anchor broken.** Cash Conductor at W12-13 means Hire #1 (W7 start) has nothing to take on for 5 weeks. Hire #1's first sprint becomes "help with Concierge" — wrong scope for an onboarding sprint (Concierge is XL and founder-led).
docs/decisions/sequencing-target.md:230:W6-9: Concierge (A6) — Risk #1 derisk via Tier-1 + Primitive 2 first exercise
docs/decisions/sequencing-target.md:236:**Why this ordering:** Front-load risk-de-risking by building Concierge (the most Primitive-heavy agent) early. Cash Conductor's Risk #1 exercise becomes redundant if Concierge already exercises Primitives 1+2+4+5.
docs/decisions/sequencing-target.md:240:1. **Concierge depends on Scribe** for Notes-for-context (per `bullhorn-integration-path.md` §4.1 row 4 — Concierge reads Notes Scribe wrote). Building Concierge at W6-9 before Scribe (W10) means Concierge's first-month operation has empty Note context. Materially degrades the Tier-1 always-on demo.
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:253:| 2. Substrate exercise (sequential build-up) | **Wins** — each agent extends the substrate of the prior (renderer → Bullhorn auth → voice → Tier-1 primitives → multi-source → full Tier-1 lifecycle) | Loses — Concierge has to build its own Bullhorn auth + voice substrate inline | Loses — Concierge built before its substrate dependencies (Scribe's Notes-for-context not yet available) |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:255:| 4. Commercial value | Tied (Diagnostic substrate, then flagship Concierge last; closing demo at W12-13 per Ultraplan §9 line 781) | Wins on raw timing (Concierge W5-8 demoable earlier) — but loses on substrate quality (Concierge ships with degraded Notes-for-context) | Tied — Concierge W6-9 marginally earlier than Alpha but with same substrate gaps as Beta |
docs/decisions/sequencing-target.md:256:| 5. Dependencies on other agents | **Wins** — Janitor's Bullhorn auth → Scribe reuses → Sourcing Scout reuses → Concierge reuses, all in dependency order | Loses — Concierge before Janitor + Scribe breaks the upstream chain | Loses — Concierge before Scribe breaks the upstream chain |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:269:**Alpha is the only sequence that survives both documented contingencies cleanly.** Beta and Gamma each forces a Concierge rewrite if their respective trigger fires.
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:283:| 3 | W6 | **Scribe** (A3) | voice-loader-for-tacit-notes first exercise; Concierge-upstream Notes-for-context |
docs/decisions/sequencing-target.md:286:| 6 | W10-13 | **Concierge** (A6) | XL build; flagship closing demo; first Primitive-2 (71h context rotation) exercise |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:310:- **Activation:** v1.0 scope cut from 6 to 4 agents per Ultraplan §10 row #4 — drop Concierge + Sourcing Scout to v1.1; founder solo through end of v1.0.
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:319:- **Cascade:** Sourcing Scout W10 (shifted right from W9), Concierge W11-14 (shifted right from W10-13).
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:332:- Concierge W10-13's four-week build broken into specific weekly sub-tasks — deferred to Week 9 Concierge-build-planning session (just-in-time scoping).
docs/decisions/sequencing-target.md:333:- v1.1 Triage agent's relationship to v1.0 Concierge's auto-send categories — deferred to v1.1 planning.
docs/decisions/sequencing-target.md:335:- Per-agent Codex-ratification timing within each build slot — every `agent.md` ratifies before merge per master brief §10.5; specific ratification cadence emerges from each agent's PR cycle.
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:418:- W13 Concierge final-render-clean → **Low** (all 5 v1.0 bundles render and pass validation per RISK-REGISTER #5 final reduction trigger).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:24:| 10-13 | Concierge |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:59:- ✅ Real end-to-end pipeline verified Day 13 (Gate A PASS on fake-firm smoke test)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:76:- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/_supplementary/build-plan-original.md:110:# Quality gates (self-check before completing)
docs/_supplementary/build-plan-original.md:228:Total context per invocation: 10–25k tokens typical. With prompt caching on the Tier 1 + Tier 2 stuff that's shared across invocations, effective cost is ~10% of input rate. This is how the £80–180/mo per tenant cost target holds.
docs/_supplementary/build-plan-original.md:302:- **Quality gates** — no duplicates, no disqualifiers, every field populated
docs/_supplementary/build-plan-original.md:348:**Sonnet 4.6** default. Allow escalation to Opus 4.7 via a `--complex` flag the agent can set itself if the call transcript exceeds 30 minutes or includes >3 distinct workstreams (multi-project scope is Opus territory).
docs/_supplementary/build-plan-original.md:434:# Quality gates (self-check)
docs/_supplementary/build-plan-original.md:543:- **Quality gates** — <60 words, no "just checking in", specific ask, linked asset if relevant
docs/_supplementary/build-plan-original.md:615:- **Quality gates** — length within 10% of brief, no banned phrases from voice profile, no obvious AI tells ("In today's fast-paced world", "Let's dive in", etc.)
docs/decisions/2026-05-18-codex-ratification-manifest.md:111:Round 4 scheduled across Week 3 (Days 14-20) per `docs/operations/goal-week-3-polish-and-scaffold.md` Steps 7 (Diagnostic-only, Day 15) + 13 (full run, Day 20). Per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 remediation max).
docs/decisions/2026-05-18-codex-ratification-manifest.md:144:| 1 | `agents/recruitment/diagnostic/agent.md` | **REJECTED** | 5 real findings (Gate A strength + Step 11 decision-log + Trigger 8 mismap + sentinel + validate.sh gap) | `20260524T101934Z-19923` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:153:**Hard ceiling reached** per master brief §10.3 step 5. Single founder decision (approve the 5-category disposition) unlocks all 6 ratifications via a single Round-5 mechanical-remediation pass.
docs/decisions/2026-05-18-codex-ratification-manifest.md:205:## §2 — Ratification protocol per master brief §10.3
docs/decisions/2026-05-18-codex-ratification-manifest.md:207:Verbatim from master brief §10.3 (post-Edit 7 path correction):
docs/decisions/2026-05-18-codex-ratification-manifest.md:246:| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
docs/decisions/2026-05-18-codex-ratification-manifest.md:247:| **Disagreement artefacts** | If Codex REJECTS or disagrees with any artefact | `docs/decisions/codex-disagreement-<date>.md` per master brief §10.3 step 4. Founder decides on escalations. |
docs/operations/goal-week-3-polish-and-scaffold.md:3:**Status:** CLOSED (2026-05-24 Day 19) — executed end-to-end with founder bilateral disposition. v0.3 schema supplement RATIFIED. ADR-006 Diagnostic Gate A hybrid Accepted. 6 agent.md scaffolds at Pre-Build-Round-N-Reviewed. Catalogue extended 24→52 ESC codes + 29→47 action_types. Final state pushed at `75ccc5f`. Founder explicitly authorized Codex ratification execution within this session via AUQ ("Authorize one final Codex round...RATIFY-or-document-disagreement") + repeated "proceed" instructions, which override the original §0 "Steps 7+13 — I run those" reservation in this file. Week 3 close documented in `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` + `.agents/current-priorities.md`. **STOP-HOOK NOTE: this file's gate-structure was superseded by in-session founder AUQ authorization; do not re-fire on subsequent turns.**
docs/operations/goal-week-3-polish-and-scaffold.md:20:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (boundaries) + §6 Day 4-7 (foundation state) + §8 (build sequence) + §10.5 (always-ratify artefacts)
docs/operations/goal-week-3-polish-and-scaffold.md:61:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:94:| Diagnostic Codex ratification | Master brief §10.5 always-ratify |
docs/operations/goal-week-3-polish-and-scaffold.md:308:- **§5 Gate A:** validate.sh hard-fails on missing CTX env, dedup-rate >20% (suggests bad heuristic), field-write-error-rate >5%, schema-violation rows.
docs/operations/goal-week-3-polish-and-scaffold.md:343:- **§5 Gate A:** validate.sh hard-fails on missing transcript, field-extraction confidence <0.6, Bullhorn write FK-violation, voice-classifier <0.75 on tacit note.
docs/operations/goal-week-3-polish-and-scaffold.md:370:- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
docs/operations/goal-week-3-polish-and-scaffold.md:372:- **§5 Gate A:** validate.sh hard-fails on accounting API auth failure, bank API auth failure, reconciliation false-positive rate >2%, chase-draft content failing voice classifier.
docs/operations/goal-week-3-polish-and-scaffold.md:383:### DAY 19 — Sourcing Scout + Concierge agent.md scaffolds (Steps 11-12)
docs/operations/goal-week-3-polish-and-scaffold.md:400:- **§5 Gate A:** validate.sh hard-fails on empty match list, low average confidence (<0.5), schema violation.
docs/operations/goal-week-3-polish-and-scaffold.md:414:- ULTRAPLAN §8.1 A6 lines 561-570 (Concierge spec)
docs/operations/goal-week-3-polish-and-scaffold.md:415:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:416:- `autosend-safety-policy.md` §4 (orange-tier model) + §3 (29 action types — Concierge's are bullhorn_note_customer_visible, candidate_state_change_email, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:418:- `bullhorn-integration-path.md` §4.1 (Concierge's Bullhorn write surface)
docs/operations/goal-week-3-polish-and-scaffold.md:427:- **§5 Gate A:** validate.sh hard-fails on missing approval-bridge auth (if D1-A bridge), voice classifier <0.75, tone-rule block-severity hit, schema violation, orange-tier-spot-check sample selected.
docs/operations/goal-week-3-polish-and-scaffold.md:450:Triage protocol (master brief §10.3 step 5 hard ceiling: ≤2 round-trips):
docs/operations/goal-week-3-polish-and-scaffold.md:502:| Codex Round 4 returns >2 REJECTED on any single artefact | Founder review; do NOT remediate-and-resubmit beyond hard ceiling (per master brief §10.3 step 5); write founder-decision doc; defer |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:533:- Any reduction in Gate A strictness
docs/operations/goal-week-3-polish-and-scaffold.md:540:Per master brief §10 + §10.3 step 5 hard ceiling + Day-11 Round-2/3 pattern.
docs/operations/goal-week-3-polish-and-scaffold.md:573:- **Mechanical REJECTIONS (citation drift, line-anchor error, formatting):** Round 4 remediation prompt; expect Round 5 final. Hard ceiling per master brief §10.3 step 5: 2 round-trips MAX. Round 5 RATIFIED → close. Round 5 STILL REJECTED → founder review.
docs/operations/goal-week-3-polish-and-scaffold.md:594:5. **Every Gate A condition is operationally testable.** A future validate.sh implementer can read §5 and write the bash logic without inventing rules.
docs/operations/goal-week-3-polish-and-scaffold.md:614:  Gate A:             PASS (V1-V6 green; V3 warning per scaffold)
docs/operations/goal-week-3-polish-and-scaffold.md:622:  Concierge (W10-13):     <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:685:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:86:| Concierge | `bullhorn_brief_read` | Read of inbound brief; idempotent; no comms |
docs/decisions/autosend-safety-policy.md:96:| Concierge | `bullhorn_note_draft_internal` | 1-in-10 | Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate |
docs/decisions/autosend-safety-policy.md:102:| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
docs/decisions/autosend-safety-policy.md:103:| Concierge | `gmail_outlook_send_to_candidate` | Outbound email to candidate; customer-facing; reputation effects |
docs/decisions/autosend-safety-policy.md:104:| Concierge | `twilio_sms_send` | Outbound SMS; high-trust channel; cost-per-send; irreversible |
docs/decisions/autosend-safety-policy.md:105:| Concierge | `calendar_invite_send` | Creates calendar event with attendee notification; visible to attendee |
docs/decisions/autosend-safety-policy.md:215:Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
docs/decisions/autosend-safety-policy.md:585:4. **Cyber insurance.** IFOS Limited needs cyber insurance covering policy miscategorisation events. Quote requests pending; budget impact on v1.0 founder-set cost budget (Day-4 runbook §1.4 — £20/mo for infrastructure at single-tenant pilot scale; master brief does not specify a numeric cost target).
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:642:1. Tier classifications per §3 (especially canonical orange = Concierge Bullhorn Note)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:1:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:5:**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:7:**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:15:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:19:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:23:(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract. Their v0 implementation in `validate.sh` is partial — `validate.sh` warns and emits `validate_check_skipped=true` when the voice-classifier URL is unreachable or the firm-domain whitelist is absent, rather than hard-failing; W4-polish closes these to hard-fail per `agents/recruitment/diagnostic/agent.md` §5 honesty note. These warn-only-paths exist in v0 but are not affected by this ADR; this ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:25:This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:41:### Decision 1 — Diagnostic Gate A citation validation is per-section coverage ONLY (hard-fail)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:43:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:45:The OTHER Gate A subchecks (voice classifier ≥ 0.75 and PII boundary) have v0 warn-only paths when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these are honesty-flagged with `validate_check_skipped=true` per the Context section above. W4-polish closes those subchecks to hard-fail. This ADR addresses only the per-section citation subcheck of Gate A; it does NOT modify the voice classifier or PII subchecks.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:47:### Decision 2 — Per-claim citation validation is a SEPARATE post-launch quality metric (NOT Gate A)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:49:The per-claim citation pipeline (NLP claim-extraction + per-claim evidence-link matching + aggregate quality metric) is **explicitly outside Gate A** in v1.0. It lands as:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:56:**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:58:**Rule 4 (Quality gates before features) satisfied for the per-section citation subcheck:** it is hard-fail at v0 with no warn-only paths. (Other Gate A subchecks — voice classifier + PII — retain v0 warn-only paths when upstream services are unreachable per Context note; W4-polish closes those. ADR-006 addresses only the per-section subcheck.) Per-claim quality is a separate signal, not a weakening of Gate A's per-section subcheck.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:66:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:70:> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — per-section citation subcheck is hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (a W4 ADR to be authored at first-pilot polish time).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:74:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:84:- A working v0 with per-section validation has measurable Gate A coverage; deferring means no Gate A at all in the meantime, which is strictly worse
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:95:- Pilot tenants reading Gate A spec see the v0 contract clearly + the W4 expansion plan
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:113:- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the original ULTRAPLAN line 496 prose alone)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:125:- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/autosend-approval-bridge-spec.md:4:**Date:** 2026-05-22 (Day 11, pre-Concierge W10 prerequisite)
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:14:Autosend-safety-policy §3 declares 10 v1.0 action_types as **orange tier** — most importantly the canonical orange `bullhorn_note_customer_visible` (Concierge's primary outbound action). Orange-tier actions require per-action human approval via Telegram before executing.
docs/decisions/autosend-approval-bridge-spec.md:154:🔔 Approval request: Concierge bullhorn_note_customer_visible
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
docs/decisions/autosend-approval-bridge-spec.md:257:- Day 4 (Concierge W10 start): Concierge uses bridge from day 1
docs/decisions/autosend-approval-bridge-spec.md:259:**Alternative:** as the next IFOS Claude slice (now). Pre-builds the prerequisite before Diagnostic W3-4 starts, so it's not blocking Concierge. ~2-3 days inserted before Diagnostic.
docs/decisions/autosend-approval-bridge-spec.md:308:- Unblocks Concierge build (W10-13) — without this, Concierge can only ship as drafts-only (D1-A) which loses the demo value prop
docs/operations/codex-round-2-autonomous-prompt.md:91:recursive ratification per master brief §10.5. Decide whether Claude's 
docs/operations/codex-round-2-autonomous-prompt.md:196:  Disagreement docs (recursive ratification per master brief §10.5):
docs/operations/codex-round-2-autonomous-prompt.md:320:**If SUMMARY.md shows unexpected REJECTED items:** Codex caught something. Read the per-artefact output file. Decide whether to incorporate or counter-argue. Then Round 3 (~limited; ≤2 round-trips per master brief §10.3).
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:46:| **A. Accept the floor** | Leave `pollInterval` at the 1000ms default. Rewrite Ultraplan §3.2's "four-agent pipelines complete in seconds" to "four-agent pipelines complete in 3-5 seconds end-to-end" and remove any "sub-second handoff" framing from the closing-demo deck | Zero engineering | Honest signal; Concierge's "30-min lifecycle event → drafted comms" SLA is unaffected (3-5s is rounding error against 30 minutes); Brief Decoder's "90-min brief-to-shortlist" is also unaffected. Only sales narrative changes. |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:52:2. The user-visible SLAs (Concierge 30-min lifecycle event, Brief Decoder 90-min shortlist, Triage 60-second response) all have ≥30× headroom against a 3-5 second pipeline floor. The pipeline-latency claim is sales narrative, not product SLA.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:71:- Codex-ratification list (master brief §10.5) needs an entry: bus-dispatcher mechanism change = master brief edit = always-ratify.
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:62:- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:226:**Scope of permissions requested at first auth:** Bullhorn's OAuth docs surveyed do not specify per-scope strings (e.g. `read:candidate`, `write:note`). REST API access appears to be at-tenant-admin-discretion — the admin authorises the connected app for "API access" generally, and the corpToken-scoped session inherits whatever entity permissions the admin's account holds. **Spec gap §3.1-B:** confirm with Bullhorn developer support that there is no per-entity-type scope granularity at the OAuth layer — i.e. IFOS cannot request "read-only" auth and get a token that can't write. If this is correct, then Gate A in `validate.sh` (per master brief §1 Rule 4) becomes the only enforcement layer for "this agent should never write" — the OAuth token itself does not protect.
docs/decisions/bullhorn-integration-path.md:268:- Confirm there is no per-entity-type OAuth scope granularity at the OAuth layer (Spec gap §3.1-B) — required so IFOS's Gate A enforcement model (validate.sh) is the correct safeguard.
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:310:| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
docs/decisions/bullhorn-integration-path.md:311:| Concierge time-based nurture cadence | Cron (week-1, month-1, month-3, month-6, month-12, month-24) | Per Placement-creation anchor date | No Bullhorn webhook needed — IFOS-side cron fires; IFOS reads Bullhorn for current state then writes the comm Note back |
docs/decisions/bullhorn-integration-path.md:313:**v1.1+ upgrade path:** if Sub-decision A commercial verification reveals marketplace-tier event subscriptions, Concierge upgrades from 5-minute polling to webhook-primary with polling fallback. The polling cycle becomes a heartbeat-style consistency check. No agent-bundle-content changes; only `tools.yaml` MCP scope declaration and the connector's auth/subscription module.
docs/decisions/bullhorn-integration-path.md:337:| Concierge (real-time + 5-min poll) | 100-300 distributed | Two streams: lifecycle-event-driven writes (low volume) + polling-cycle reads (continuous, bounded by entity-count) |
docs/decisions/bullhorn-integration-path.md:346:**Emerged from §3.1 finding:** Bullhorn's 10-minute access token TTL is short enough that v1.0 needs an explicit refresh-loop pattern. Lazy refresh on 401 alone is insufficient for two reasons: (a) it would cause every 10-minute window's first call to take a refresh round-trip's worth of latency, breaking sub-second SLAs on Concierge real-time paths; (b) 401 detection on burst writes (Scribe's per-call sequence of 5-15 REST writes) means burst-mid-flight refresh failures lose write ordering.
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:419:Concierge's write capability to Bullhorn (Note auto-send, status updates per §4.1) interacts with Day 5's auto-send safety policy artefact. Day 5 should reference this document's §4.1 Concierge row for the specific entities Concierge will be writing — Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI.
docs/decisions/bullhorn-integration-path.md:509:| §3.1-B: assume no per-entity OAuth scope granularity → `validate.sh` Gate A is the only enforcement layer | Bullhorn dev support confirms different — adjust connector auth-module to request scoped tokens |
docs/decisions/bullhorn-integration-path.md:511:| §4.2-A: assume v1.0 pull-only (no webhook coverage) per public REST docs | Sub-decision A commercial verification reveals marketplace-tier event subscriptions — Concierge upgrades to webhook-primary in v1.1+ |
docs/decisions/ADR-004-renderer-implementation-deviations.md:18:The three deviations are individually small. The reason this ADR exists rather than three inline `errata` notes in ADR-003 is master brief §10.5 ("Always-ratify list"): renderer architectural decisions go through Codex review, and a single coherent ADR is the audit-trail-friendly path. Reading ADR-003 + ADR-004 together gives the full ratified renderer surface.
docs/decisions/ADR-004-renderer-implementation-deviations.md:68:- ADR-003 §2.3 worked-Concierge-example output diagram says `_shared/` lives at `orgs/acme/agents/_shared/` — that's correct, the bug is only in the symlink-target text. Diagram is right; symlink string is wrong.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:20:**Real issue:** 10 action_types (including the canonical orange `bullhorn_note_customer_visible` — Concierge's primary outbound action) are classified as orange. v1.0 ships green+red only. In v1.0, those orange action_types must either:
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:23:- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:26:**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:32:**Alternative timing:** Insert as next IFOS Claude slice now (post-Diagnostic-build, ~Week 8). Marginal benefit: D1 becomes a closed item earlier; bridge gets stress-tested before Concierge needs it. Cost: 2-3 days inserted before Concierge.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:34:**Cost of deferral:** Concierge W10 build risks slipping if bridge isn't ready. Concrete delay: ~3 days. Risk #2 (Bullhorn) is the bigger blocker for Concierge (auth path); D1 is downstream of that.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:142:| **D1** (autosend v1.0 tier) | This week | Concierge build scope (W10-13) |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:147:**Recommended order:** D5 (quickest, unblocks Round 2) → D1 (Concierge planning) → D2 + D3 (legal bundle) → D4 (no-rush).
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:30:No edit to the agent.md or validate.sh. R17 dispositions cover the other 4 findings; this disagreement is recorded per master brief §10.3 step 4 ("Claude Code reads Codex's feedback; incorporates it or counter-argues explicitly in `docs/decisions/codex-disagreement-{date}.md` (the disagreement IS the signal — write it down, don't dissolve it)").
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:32:If Codex repeats this same finding at R18 against the unchanged text, escalate to founder per §10.3 step 5.
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:36:- ADR-006 — Diagnostic Gate A hybrid (Accepted Day 19, Cat-1/Cat-ζ structural close)
docs/decisions/ADR-003-agent-bundle-renderer.md:17:The design document (`docs/architecture/agent-bundle-renderer-design.md`) specified the renderer across five sections: source vs target layout (§1), the 12-row file mapping + R2 commitment + Concierge worked example (§2), six concrete mechanism decisions including TypeScript Node at `packages/agent-renderer/` (§3.1), manual developer invocation (§3.2), Option γ for `_shared/` origination (§3.3.3), and overwrite-no-merge re-render policy (§3.4), seven failure modes with exit codes (§4), and integration with the broader build (§5). 22 spec gaps surfaced and bucketed. This ADR ratifies the design's recommendations.
docs/decisions/ADR-003-agent-bundle-renderer.md:54:The Concierge worked example in design §2.3 demonstrates end-to-end render: source bundle layout, CLAUDE.md preamble draft (resolves spec gap §2.1-A), materialised `config.json`, synthesised `.env`, hook files verbatim, `_shared/` symlink resolution.
docs/decisions/ADR-003-agent-bundle-renderer.md:109:> # 5. validate.sh (Gate A; sources _shared/hook-helpers.sh)
docs/decisions/v1.0-kill-criterion.md:85:- **Option C:** ATS-agnostic with manual data sync. Reduces v1.0 to read-only agent operation against ATS export files; loses much of the Janitor + Concierge value but unblocks pilot acquisition.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:134:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 pilot scale; master brief does not specify a numeric cost target); emerging from v1.0 pilot operations.
docs/decisions/v1.0-kill-criterion.md:148:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 single-tenant pilot; master brief does not specify a numeric cost target); Risk #4 in `docs/RISK-REGISTER.md` (Hire #1 delays compound infrastructure spend if architecture sprawls).
docs/decisions/v1.0-kill-criterion.md:156:**Recovery path:** Rescoped infrastructure plan; pivoted v1.0 continues with adjusted Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target; budget adjustment is a runbook revision, not a master-brief edit).
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/build-brief/00-MASTER-BRIEF.md:57:4. **Quality gates before features.** Gate A (per-run `validate.sh`) working + decision-log writes (`hh_decision_trigger / output / action`) present > extra features. `validate.sh` hard-fails on missing decision-log calls. No exceptions.
docs/build-brief/00-MASTER-BRIEF.md:119:| 7 | Multi-agent orchestrator | `orchestrator` template + file-bus handoff contract | Brief Decoder → Sourcing Scout → Concierge pipeline lives here |
docs/build-brief/00-MASTER-BRIEF.md:547:├── validate.sh                         # Gate A — sources _shared/hook-helpers.sh
docs/build-brief/00-MASTER-BRIEF.md:600:| 6 | Concierge | 10–13 | Bullhorn + MS Graph + AgentMail | First Tier-1 always-on closing demo; 4-week build |
docs/build-brief/00-MASTER-BRIEF.md:602:After Concierge ships, week 14 milestone: first pilot converts to paid.
docs/build-brief/00-MASTER-BRIEF.md:619:# 5. validate.sh (Gate A; sources _shared/hook-helpers.sh)
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:682:        │   v1.2 (+5): Real-Time Pulse, Spec Pitcher, Reporting, T1 Onboarding Concierge, T2 Timesheet     │
docs/build-brief/00-MASTER-BRIEF.md:831:| "Let me skip the Codex ratification — it's a small change..." | §10.5 |
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
docs/build-brief/00-MASTER-BRIEF.md:874:4. Quality gates before features
docs/build-brief/00-MASTER-BRIEF.md:986:6. **The quality gates** — Gate A binary per-run, Gate B 90-day, Gate C weekly voice classifier
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:1:# ADR-007 — Concierge Gate A 30-minute draft SLA hybrid (Gate B leading metric, not per-draft hard-fail)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:3:**Status:** Proposed (2026-05-25, Day 20; W4 bilateral pass on Concierge agent.md surfaced this as Codex R3 Finding 3 — current scaffold reframes ULTRAPLAN A6 line 566 Gate A "every lifecycle event has a draft generated within 30 minutes" as a Gate B leading metric without an authoritative ADR backing the deviation. Awaits Codex `review-architecture-decision` ratification + founder Accept.)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:5:**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A6 line 566 — Gate A 30-minute draft SLA clause
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:7:**Driven by:** `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3 — Codex flags Concierge `agent.md` §5 line 278 reframes the 30-min SLA as Gate B without an ADR; §10 Accepted criteria omits any ADR-ratification blocker for this deviation. Analogue of ADR-006 (Diagnostic Gate A hybrid).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:13:ULTRAPLAN §8.1 A6 line 566 (pre-amendment wording):
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:15:> - **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:17:The clause implies three Gate A hard-fail conditions: (a) draft generated within 30 minutes of lifecycle event, (b) voice classifier ≥ 0.75, (c) addressee resolution correct.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:19:Concierge `agent.md` (Day-19 R3 scaffold) reframes (a) — the 30-minute draft SLA — from per-draft Gate A hard-fail to a Gate B leading metric (90% of drafts within 30 min, not per-draft hard fail). The other two clauses (voice classifier + addressee resolution) remain Gate A hard-fails. The reframe is documented in:
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:23:- `agent.md` §5 lines 269-280 (Gate A excludes the 30-min SLA explicitly)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:28:> The 30-minute SLA is weakened without a ratified status-flip blocker. Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:30:Per master brief §10.5 + Rule 4 (Quality gates before features), an upstream-spec amendment requires either (a) revert the scaffold to per-draft hard-fail, or (b) author an ADR ratifying the deviation. This ADR is option (b).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:36:The Concierge lifecycle-event trigger source is the Bullhorn ATS state-change webhook + a polling-fallback cron (per ULTRAPLAN A6 line 569 verbatim gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks").
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:38:Polling-fallback delays are not Concierge's fault — the polling cron runs at a configurable interval (likely 5-15 minutes per tenant) and a state change that happens at minute 1 of a 15-minute cycle has a 14-minute "blind spot" before Concierge ever sees it. A per-draft hard-fail Gate A would treat this as a Concierge failure even though the draft IS generated within 30 minutes of detection (just not within 30 minutes of the actual Bullhorn state change).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:40:Treating this as Gate A hard-fail would cause Concierge to drop legitimate drafts whose timing was set by upstream-detection latency, not by Concierge generation latency. The product harm: a candidate experiences a "ghosted by recruiter" pattern that Concierge was designed to prevent.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:44:The 30-minute SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Treating it as Gate B at the 90% threshold:
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:55:**Concierge Gate A is the subset of ULTRAPLAN A6 line 566 that is operationally enforceable per-draft:**
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:57:- ✅ Voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82) — Gate A hard-fail
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:58:- ✅ Correct addressee resolution (no candidates emailed under another's name) — Gate A hard-fail (`ESC_ADDRESSEE_MISMATCH`)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:59:- ✅ No tone-rule block-severity violations — Gate A hard-fail (`ESC_TONE_RULE_VIOLATION`)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:60:- ✅ No PII outside firm boundary — Gate A hard-fail (`ESC_PII_LEAKAGE_RISK`)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:61:- ✅ Anti-duplicate guard passed — Gate A hard-fail
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:62:- ✅ All Bullhorn context fields present — Gate A hard-fail (`ESC_AGENT_OUTPUT_SHAPE`)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:66:- 90% of drafts generated within 30 minutes of lifecycle-event DETECTION (not lifecycle-event occurrence)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:69:- Concierge ALSO records the upstream-detection-latency separately in the audit payload (`payload.detection_delay_seconds`) so the metric attribution is clean (Concierge generation latency vs upstream polling latency)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:71:**ULTRAPLAN §8.1 A6 line 566 is amended in-band per the master brief §10.3 step 4 pattern** (analogue of the in-band amendment ADR-006 made at line 496):
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:74:> - **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:77:> - **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:83:1. Concierge drafts are not dropped when upstream polling-fallback latency exceeds 30 minutes
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:84:2. The product UX promise of "post-state-change comms within 30 minutes" is captured at the population level
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:85:3. The metric attribution is clean — operators can distinguish Concierge generation latency from Bullhorn webhook/polling latency
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:86:4. Structural parity with ADR-006: per-event Gate A vs aggregate Gate B as the canonical Tier-1/Tier-2 split for time-based SLAs (replicable pattern for future agents)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:91:2. Tenants with high webhook coverage will see better than 90%; tenants with webhook-coverage gaps see worse — the metric reads as Concierge quality but is partly an upstream condition. Operator must look at `payload.detection_delay_seconds` distribution to disambiguate.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:92:3. The Concierge agent.md §10 Accepted criteria must include ratification of this ADR as a blocker (closing Codex R3 Finding 3 properly)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:96:4. No code or schema changes required at scaffold stage — `agent.md` already reflects the Gate B framing. Update is to ULTRAPLAN line 566 (in-band amendment) + Concierge §10 (add ADR blocker) + this ADR (new artefact).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:100:### In-band ULTRAPLAN amendment (per master brief §10.3 step 4)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:102:Edit `docs/specs/ULTRAPLAN.md` §8.1 A6 line 566:
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:105:- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:106:+ **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — 30-minute draft SLA is Gate B leading metric at 90%)*
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:109:Commit message: `amend(ULTRAPLAN A6 line 566): Gate A scope reduced; 30-min SLA → Gate B per ADR-007`
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:111:### Concierge §10 amendment
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:115:> - **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes R3 Finding 3 structural deviation; ratifies the agent.md §5 Gate A scope vs ULTRAPLAN A6 line 566 pre-amendment language.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:119:`decision_log.payload.detection_delay_seconds` field for Concierge action rows is not in v0.3 schema; queued for v0.4 supplement OR W10-13 build-slice schema addition (whichever ships first). Concierge `cycle.sh` v0.0 records the field; absent the constraint, it's free-form JSONB.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:131:- ADR-006 — Diagnostic Gate A hybrid (structural template for Tier 1 vs Tier 2 split)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:132:- ULTRAPLAN §8.1 A6 line 566 (pre-amendment authority)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:135:- `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:136:- Master brief §1 Rule 4 (Quality gates before features) + §10.5 (ADRs are ratifiable artefacts)
docs/_supplementary/PRD-autonomous-agent.md:194:- Every 30 minutes: check Telegram, process messages, update memory
docs/_supplementary/PRD-autonomous-agent.md:1863:## Every 30 minutes — Heartbeat
docs/_supplementary/PRD-autonomous-agent.md:2287:- [ ] Test: heartbeat reads Telegram every 30 minutes
docs/decisions/brain-ui-scope.md:28:3. What the first paying design partner asks for after Concierge ships in v1.0 — direct user-research input.
docs/decisions/brain-ui-scope.md:42:- Highlights pending approvals (Concierge auto-send escalations per `bullhorn-integration-path.md` §4.1 row 4).
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/runbooks/pii-purge-operational-pattern.md:123:- Audit queries ("how often did Concierge's drafts get edited vs approved?")
docs/runbooks/day-4-provisioning.md:29:- **Rule 4 (Quality gates before features):** the §7 RLS isolation test is the binary gate. If it fails, the runbook execution stops at §7 and we debug before continuing.
docs/runbooks/day-4-provisioning.md:40:**Master brief asserts (line 477 verbatim):** "Hetzner UK VPS provisioned, LUKS-encrypted volume mounted at `/vault/`". This is the single Hetzner reference in the master brief. §10 (Codex ratification loop) does not mention Hetzner or cost targets — earlier drafts of this runbook cited "master brief §10.4" for cost target and Hetzner location; both fabricated. Corrected in citation-audit pass 2026-05-18.
docs/runbooks/day-4-provisioning.md:171:| Instance type | CX22 (2 vCPU, 4 GB RAM, 40 GB NVMe) | Fits v1.0 pilot scale per founder-set budget in this section §1.4; master brief does not specify a numeric cost target |
docs/runbooks/day-4-provisioning.md:178:Estimated monthly cost: ~€5/mo VPS + ~€2.40/mo (50 GB volume at €0.0476/GB/mo) ≈ €7.40/mo ≈ £6.40/mo. Well under the £20/mo founder-set budget for v1.0 pilot scale (this section §1.4; master brief does not specify a numeric cost target).
docs/runbooks/day-4-provisioning.md:1187:- Add Edit 9: master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations"; document UK-residency as commercial-conversation gate. (§10.4 reference dropped per 2026-05-18 citation audit; §10.4 is Codex exclusion list, not a Hetzner or cost-target section.)
docs/runbooks/day-4-provisioning.md:1212:3. **§2 location — NBG1 substituted for FSN1:** FSN1 unavailable at provisioning time. Substituted Nuremberg (NBG1) — same Hetzner eu-central zone, identical Schrems II EU jurisdiction (German court orders only), latency to UK ~25-30ms vs FSN1 ~20-25ms (functionally equivalent). **Triggers §11.4 master-brief Edit 9:** master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations". (Earlier drafts of Edit 9 also referenced master brief §10.4; verified during 2026-05-18 citation audit that §10.4 is the Codex exclusion list, not a Hetzner or cost-target section. §10.4 component dropped.)
docs/runbooks/operational-hygiene-protocol.md:76:**Day-4 incident (reference example of a correctly-handled Path B use):** Path B was authorised once for §4.8 ifos-unlock end-to-end test. Founder rotated WITHIN THE SAME SESSION via `cryptsetup luksChangeKey`; `--test-passphrase` verified OLD rejected + NEW accepted. The leaked passphrase in the transcript became cryptographically invalid against the LUKS volume. **Cost:** ~30 minutes of rotation work + permanent transcript-history annotation. Audit record: Day-4 close commit `98c79b2` + `.agents/decisions/2026-05-17-path-b-rotation-1.md`.
docs/runbooks/operational-hygiene-protocol.md:264:**Scope:** 15 references to "master brief §10.4" across 5 files, claiming §10.4 contains either (a) a Hetzner UK / FSN1 location reference or (b) a £20/mo cost target.
docs/runbooks/operational-hygiene-protocol.md:266:**Verified ground truth:** master brief §10.4 is "What never goes through ratification" — a 5-bullet list of Codex exclusions (comment-only changes, test fixture additions, documentation typos, build/deps version bumps, anything inside `.agents/`). It contains no Hetzner reference and no cost-target reference.
docs/runbooks/operational-hygiene-protocol.md:268:**Root cause:** Day-4 runbook §1.4 invented "master brief §10.4 cost target" during drafting. The citation propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1 instance), RISK-REGISTER (2 instances), current-priorities (1 instance) by trusting the Day-4 runbook citation rather than re-verifying against master brief. Citation transitivity, not master-brief drift.
docs/runbooks/operational-hygiene-protocol.md:274:| `docs/runbooks/day-4-provisioning.md` | 8 | "+§10.4" dropped from Edit 9 scope (was about Hetzner UK); "§10.4 cost target" replaced with "Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target)" |
docs/runbooks/operational-hygiene-protocol.md:284:Day-5 autosend policy §3 + §10 cited `bullhorn-integration-path.md §4.1` as the canonical-orange anchor for Concierge `bullhorn_note_customer_visible`. Verified §4.1 establishes the action exists but does not explicitly frame as sensitive auto-send. Sensitivity framing lives in §6.3 ("Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI").
docs/specs/_archive-build-handoff.md:194:4. Quality gates before features — Gate A working > extra features.
docs/specs/_archive-build-handoff.md:214:- Decision log writes are required (Rule 4)
docs/specs/_archive-build-handoff.md:338:# 5. validate.sh (Gate A structural checks; sources _shared/hook-helpers.sh)
docs/specs/_archive-build-handoff.md:382:| 6 | **Concierge** | 10–13 | Bullhorn + Microsoft Graph + AgentMail | First Tier 1 always-on closing demo; 4-week build |
docs/specs/_archive-build-handoff.md:384:After Concierge ships, the first pilot converts to paid (Week 14 milestone). v1.1 then layers Triage, Brief Decoder, Competitor Interception, Night Sourcer, and the Temp agents T5 + T3.
docs/specs/_archive-build-handoff.md:420:4. **Quality gates before features** — an agent that ships with a working Gate A and a measurement plan for Gate B/C is shippable. An agent that ships with extra features but a flaky Gate A is not.
docs/specs/ULTRAPLAN.md:36:**Rule 4 — Quality gates before features.** An agent that ships with a working Gate A and a measurement plan for Gate B/C is shippable. An agent that ships with extra features but a flaky Gate A is not. Every weekly review checks gates before features.
docs/specs/ULTRAPLAN.md:72:- **The file bus.** Inter-agent handoff via shared filesystem directories. No queue, no API, no serialisation tax. Brief Decoder writes a parsed-brief file; Sourcing Scout's `FastChecker` polls it up at the configured cadence (default 1000ms `pollInterval`, configurable per agent); result lands in a sub-directory the Concierge is polling. Four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound.
docs/specs/ULTRAPLAN.md:127:├── validate.sh                    # Output validation hook (Gate A)
docs/specs/ULTRAPLAN.md:352:Total Gate A latency: <500ms. Acceptable.
docs/specs/ULTRAPLAN.md:378:> "Your voice quality score has dropped from 0.83 to 0.76 over the last 4 weeks. This usually means new edit patterns we haven't absorbed. Can we book 30 minutes to review samples?"
docs/specs/ULTRAPLAN.md:400:### 7.1 Gate A — Output gate (per single run, automated, binary)
docs/specs/ULTRAPLAN.md:402:Already specified in §4 and §6. Every agent's `validate.sh` enforces Gate A. Pass = output ships. Fail = output quarantined, retry up to 3 times, then escalate.
docs/specs/ULTRAPLAN.md:404:Gate A measurements stored in `gate_a_results` Postgres table:
docs/specs/ULTRAPLAN.md:409:Dashboard query: per-agent Gate A pass rate, weekly trend.
docs/specs/ULTRAPLAN.md:421:| Concierge | <5% candidate-ghosted rate (drafts produced for every lifecycle event) | Lifecycle-event audit against decision log monthly |
docs/specs/ULTRAPLAN.md:447:- Gate A pass rate (target: 100%; alert at <99%)
docs/specs/ULTRAPLAN.md:479:Gate A specifics
docs/specs/ULTRAPLAN.md:496:- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/specs/ULTRAPLAN.md:510:- **Gate A:** dedup confidence score ≥ 0.85 on every merge proposal; no merge proposed where candidate has had activity in last 90 days without explicit review flag
docs/specs/ULTRAPLAN.md:524:- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
docs/specs/ULTRAPLAN.md:538:- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
docs/specs/ULTRAPLAN.md:552:- **Gate A:** 5–15 candidates returned per brief; each has a working contact method; each has rationale ≥ 50 words; no candidate flagged "do not contact" in tenant vault
docs/specs/ULTRAPLAN.md:557:#### A6. The Concierge — no candidate ghosted
docs/specs/ULTRAPLAN.md:566:- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
docs/specs/ULTRAPLAN.md:578:- **CortexOS primitives required:** All except #6 — Persistent PTY (#1), context rotation (#2), file bus (#3, hands off to Concierge), approval gates (#4), Telegram (#5), orchestrator (#7)
docs/specs/ULTRAPLAN.md:582:- **Gate A:** draft generated within 60s of webhook receipt; classification has confidence ≥ 0.8; no auto-send on uncategorised messages
docs/specs/ULTRAPLAN.md:594:- **Shared modules required:** Voice loader, decision log writer, the Brief Decoder→Sourcing Scout→Concierge orchestration template
docs/specs/ULTRAPLAN.md:596:- **Gate A:** every brief produces 3 ambiguity flags OR an "unambiguous" signal; pre-shortlist contains 3–10 candidates; intake-call agenda has 5–8 items
docs/specs/ULTRAPLAN.md:614:- **Gate A:** detection latency <5 min from competitor posting; outreach references the specific role title AND the competitor agency by name (the firm needs to know we're not making this up)
docs/specs/ULTRAPLAN.md:628:- **Gate A:** 8–12 candidates per brief; each has rationale ≥ 50 words; drafts for each are valid (Gate A on the draft itself); no rate-limit exceptions raised
docs/specs/ULTRAPLAN.md:642:- **Gate A:** every red-flag pattern (e.g., FCSA accreditation lapsed, complaint volume spike, director change) produces an alert within 24 hours; quarterly audit pack contains all required sections
docs/specs/ULTRAPLAN.md:656:- **Gate A:** every active contractor has a live state with AWR week counter, RTW expiry, contract end, holiday pay year-to-date; deadline-imminent alerts fire ≥7 days ahead
docs/specs/ULTRAPLAN.md:668:| Spec Pitcher | M (1 week) | Reuses Client Hunter + Concierge primitives | Bundles, never sold standalone |
docs/specs/ULTRAPLAN.md:670:| T1 Onboarding Concierge | M (1 week) | Bullhorn (write), DocuSign, Microsoft Graph | Tracks onboarding tasks; less reasoning-heavy |
docs/specs/ULTRAPLAN.md:690:| Concierge | ✓ | ✓ | ✓ | | | | | | ✓ | ✓ | |
docs/specs/ULTRAPLAN.md:700:| T1 Onb. Concierge | ✓ | ✓ | ✓ | | | ✓ | | | | ✓ | DocuSign |
docs/specs/ULTRAPLAN.md:748:Milestone: a tenant can be provisioned in <30 minutes by a script.
docs/specs/ULTRAPLAN.md:771:### Weeks 9–10 — Sourcing Scout + Concierge start
docs/specs/ULTRAPLAN.md:774:- Week 10: Concierge build starts (4-week build); first pilot landed for shadow-mode trial
docs/specs/ULTRAPLAN.md:778:### Weeks 11–14 — Concierge completion + first pilot conversion
docs/specs/ULTRAPLAN.md:780:- Weeks 11–13: Concierge build continues; Brain UI minimal v1 (the "what did the agents do today" view); auto-send graduation for Triage-eligible categories (initially Concierge-only candidate-acknowledgement)
docs/specs/ULTRAPLAN.md:801:6. Concierge's deep nurture sequence (months 12 and 24 check-ins) — can be added in v1.1
docs/specs/ULTRAPLAN.md:805:- Decision log writes (Rule 4 — required for the LoRA pipeline later)
docs/specs/ULTRAPLAN.md:806:- Voice classifier and Gate A enforcement (Rule 4)
docs/specs/ULTRAPLAN.md:818:| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/specs/ULTRAPLAN.md:820:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
docs/specs/PRODUCT-SPEC.md:119:#### R7. The Concierge — no candidate ghosted, no client check-in missed
docs/specs/PRODUCT-SPEC.md:184:#### T1. Onboarding Concierge — contractor onboarding done right, once
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:297:The story for the customer: **"Every agent makes every other agent smarter. The Scribe captures your senior consultant's judgement → the Concierge writes in that judgement's voice → the Client Hunter pitches BD using that judgement's framing → the Pulse watches relationships through that judgement's lens. After 6 months, the system writes in your firm's voice better than your second-best consultant does."**
docs/specs/PRODUCT-SPEC.md:347:- End-of-day call: 30 minutes, walk through outputs, confirm voice quality.
docs/specs/PRODUCT-SPEC.md:398:| 1 | Persistent PTY via PM2 — agent process pre-loaded with firm voice, ATS state, recent context | Triage, Concierge, Pulse, Watchtower, Cash Conductor |
docs/specs/PRODUCT-SPEC.md:399:| 2 | 71-hour context rotation with auto-restart | Concierge (cross-week candidate conversations), Watchtower (per-contractor state), Pulse (multi-source watching) |
docs/specs/PRODUCT-SPEC.md:400:| 3 | Inter-agent file bus — agents hand work to each other via shared directories | Brief Decoder → Sourcing Scout → Concierge handoff; Triage → specialist-agent routing |
docs/specs/PRODUCT-SPEC.md:401:| 4 | Approval gates with standing authorisations | Every agent that auto-sends — Triage, Concierge, Cash Conductor, Competitor Interception |
docs/specs/PRODUCT-SPEC.md:475:- Concierge (Solo drafts-only, Boutique auto-send)
docs/specs/PRODUCT-SPEC.md:502:- T1 Onboarding Concierge
docs/specs/PRODUCT-SPEC.md:528:7. **Concierge** — "No candidate ghosted, no client check-in missed, every comms in your voice."
docs/specs/PRODUCT-SPEC.md:534:13. **T1 Onboarding Concierge** — "First 2 weeks of every contract done correctly, every time."

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '830,910p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   830	| 14 | A regulatory change (a sixth JSL rule, an Acturis API change) invalidates a Temp agent's logic | Low | High | Compliance team change notification (UK Gov) | Compliance Watchtower has its own meta-agent that watches UK Gov regulatory pages weekly |
   831	
   832	Risks #1, #2, #3, #4 are the four that could kill v1.0. Everything below them is recoverable.
   833	
   834	---
   835	
   836	## 11. The 7-day pre-build checklist
   837	
   838	These are the questions and decisions that must be cleared before any code is written. Each has an owner and a deadline. If any are still open at end of day 7, the v1.0 build start slips by the same number of days.
   839	
   840	### Day 1 — Monday
   841	
   842	- [ ] CortexOS primitive status audit. One line per primitive: "shipped and tested" / "shipped but flaky" / "documented not built" / "aspirational". **Owner:** Maddox. **Output:** `cortexos-primitive-status.md` committed to repo.
   843	- [ ] Design-partner sales conversation 1 (pilot candidate A). **Owner:** Maddox.
   844	
   845	### Day 2 — Tuesday
   846	
   847	- [ ] Bullhorn integration path decision: marketplace vs direct API. **Owner:** Maddox. **Output:** decision documented in `decisions/bullhorn-integration-path.md`.
   848	- [ ] OAuth model decision (browser dance for production, service-account for dev). **Owner:** Maddox.
   849	- [ ] Design-partner conversation 2 (pilot candidate B). **Owner:** Maddox.
   850	
   851	### Day 3 — Wednesday
   852	
   853	- [ ] v1.0 sequence optimisation target: Maddox confirms (b) "close first 3 pilots fastest" or revises. **Owner:** Maddox.
   854	- [ ] Brain UI v1.0 scope: confirm "minimal what-did-the-agents-do-today view" or revise. **Owner:** Maddox (after at least one pilot conversation).
   855	- [ ] Hire #1 status one-liner. **Owner:** Maddox.
   856	
   857	### Day 4 — Thursday
   858	
   859	- [ ] Hetzner UK VPS provisioned; LUKS volume mounted; Postgres 16 installed; basic RLS policy template tested. **Owner:** Maddox (engineering work).
   860	- [ ] First MCP server scoped: tools.yaml schema for Bullhorn integration documented.
   861	
   862	### Day 5 — Friday
   863	
   864	- [ ] Auto-Send Safety Policy artefact drafted (Q11). **Owner:** Maddox. **Output:** `auto-send-safety-policy.md`.
   865	- [ ] v1.0 kill criterion documented (Q12). **Owner:** Maddox. **Output:** `v1-kill-criterion.md`.
   866	
   867	### Day 6 — Saturday (light day)
   868	
   869	- [ ] Vertical schema v0.1 draft started. **Owner:** Maddox. **Output:** `docs/verticals/recruitment/vertical-schema.yaml` with the 8 core entities.
   870	
   871	### Day 7 — Sunday (review)
   872	
   873	- [ ] First design-partner LOI signed (non-binding pilot commitment). **Owner:** Maddox.
   874	- [ ] Sprint week 1 ticket-by-ticket plan written. **Owner:** Maddox.
   875	- [ ] Risk register reviewed; tripwires set for week 1. **Owner:** Maddox.
   876	
   877	End-of-week-0 review:
   878	- If ≥1 of: design-partner LOI signed + CortexOS primitives 1, 4, 5 working + Bullhorn auth working → proceed to week 1
   879	- If <1: extend pre-build by 1 week and clear the blocker
   880	
   881	This is the structural protection against building something nobody will pay for.
   882	
   883	---
   884	
   885	## 12. The single-sentence test
   886	
   887	If Maddox can't answer each of the following with a confident yes by end of week 0, the build does not start.
   888	
   889	1. Do we have at least one design partner who has said "yes I will pilot this in Q3 2026"?
   890	2. Does the CortexOS submodule give us primitives 1, 4, and 5 working today?
   891	3. Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?
   892	4. Have we scoped the Agent Bundle v2 refactor and is the work <5 days?
   893	5. Have we drafted the vertical schema v0.1 with the 8 core entities?
   894	
   895	If yes-yes-yes-yes-yes, week 1 starts.
   896	
   897	Otherwise, week 0 extends, and we say so honestly.
   898	
   899	---
   900	
   901	## 13. Document control
   902	
   903	| Version | Date | Author | Notes |
   904	|---|---|---|---|
   905	| 1.0 | 14 May 2026 | Maddox + Claude | Initial ultraplan synthesising spec + Q&A answers |
   906	
   907	This document is authoritative on the v1.0 → v2.0 build sequence and the technical architecture for delivering the recruitment product. Where it conflicts with prior plans on *how to build*, this wins. The product spec wins on *what to build*. The Internal Business Plan wins on commercial trajectory and ICP.
   908	
   909	End of ultraplan.

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '374,440p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   431	#### `ESC_CONCIERGE_SLA_MISS`
   432	- **Severity:** warn — aggregated to Gate B (not a per-event block)
   433	- **Trigger:** Concierge SLA breached. Three canonical sla_types:
   434	  - `brief_ack`: inbound brief not acknowledged within 4h (default)
   435	  - `customer_reply`: customer reply not actioned within 24h (default)
   436	  - `draft_generation`: lifecycle event → draft generated >30 min (per ULTRAPLAN A6 line 566; aggregated to Gate B per Concierge §1 disposition rather than per-event hard fail)
   437	- **Phase:** `gating_failed`
   438	- **Routing:** `operator_chat_id`
   439	- **Payload fields:** `brief_id` or `candidate_bullhorn_id` or `lifecycle_event_id` (per sla_type), `sla_type` (one of the three above), `sla_threshold_seconds`, `actual_elapsed_seconds`, `tenant_slug`
   440	

exec
/bin/zsh -lc "nl -ba docs/operations/w4-bilateral-pass-6-agent-md.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/agent.md | sed -n '1,460p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# W4 bilateral pass — 6 agent.md scaffolds → RATIFIED
     2	
     3	**Date:** 2026-05-25 (Day 20)
     4	**Goal:** disposition 24 residual Codex findings across 6 agent.md scaffolds and drive all 6 to **RATIFIED** in a single coordinated pass.
     5	**Time-box:** 60-90 minutes founder + Claude.
     6	**Trigger 2:** DIAGNOSTIC-NO-RENDER-W3 fires 2026-06-14 — 20 days runway. Diagnostic is pass-order #1.
     7	
     8	## How to read this doc
     9	
    10	Each finding has the same 4-line shape:
    11	
    12	```
    13	Finding N. <one-line summary>
    14	  Cite:       <file + line range>
    15	  Codex says: <verbatim quote of the issue>
    16	  Disposition: [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
    17	```
    18	
    19	We tick a box per finding, do the edit (or write the disagreement), then rerun:
    20	
    21	```bash
    22	bash scripts/run-codex-ratification.sh agent-bundle agents/recruitment/<agent>/agent.md
    23	```
    24	
    25	When that returns `RATIFIED`, flip Status in the agent.md §10 from Pre-Build-Round-N-Reviewed → RATIFIED, commit, move to next agent.
    26	
    27	**Source of these findings:** the latest round per agent in `logs/codex-ratification/20260524T*/`. Verbatim text quoted from each Codex response.
    28	
    29	---
    30	
    31	## Pass order
    32	
    33	| # | Agent | Findings | Why this position |
    34	|---|---|---|---|
    35	| 1 | Diagnostic | 5 | Trigger 2 runway (20 days). Bundle code is complete; only RATIFIED is missing. |
    36	| 2 | Janitor | 4 | All mechanical schema-citation fixes; cleanest pass. |
    37	| 3 | Sourcing Scout | 3 | Lowest residual; one scope question (webhook auto-source). |
    38	| 4 | Cash Conductor | 3 | Blocked partially by D1 (W4 #4) — pre-resolve docs-only items. |
    39	| 5 | Scribe | 5 | Ringover scope question is the only non-mechanical. |
    40	| 6 | Concierge | 4 | Depends on Concierge-Gate-A ADR (W4 #3) — may defer to that ADR. |
    41	
    42	---
    43	
    44	## 1. Diagnostic — `agents/recruitment/diagnostic/agent.md`
    45	
    46	**Round:** R16 post-v0.3 (Pre-Build-Round-16-Reviewed). Log: `logs/codex-ratification/20260524T130117Z-63874/`.
    47	
    48	### Finding 1. Voice escalation overstated for v0
    49	  - **Cite:** §4 line 109; cross-ref generator README + `validate.sh` lines 253-255
    50	  - **Codex says:** "Line 109 says `ESC_VOICE_DRIFT` is 'raised internally by §12 LLM step if classifier <0.75 after 3 retries,' but the generator README says v0 has 'No LLM-driven §12' and 'No voice classifier gate,' and `validate.sh` only calls the classifier once when `IFOS_VOICE_CLASSIFIER_URL` is set. Fix §4 to say voice drift is a `validate.sh` V3 concern in v0, with retries deferred to W4 if intended."
    51	  - **Likely:** FIX-IN-PLACE. Rewrite §4 line 109 to scope to v0 (single-pass classifier on V3, no retries, no LLM §12). Add W4 forward-look as a parenthetical.
    52	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
    53	
    54	### Finding 2. ESC_RATE_LIMIT_HIT claimed but not implemented
    55	  - **Cite:** §4 line 108 + §6 line 173; cross-ref `cycle.sh` (no 429 catch)
    56	  - **Codex says:** "Lines 108 and 173 say `ESC_RATE_LIMIT_HIT` is raised for Companies House or LinkedIn 429s, but `cycle.sh` has no 429 catch or `hh_decision_action` path for that code; the generator CLI just exits generic on thrown errors. Fix by either implementing a 429 catch that emits `ESC_RATE_LIMIT_HIT`, or marking this as a W4/planned tools.yaml mapping rather than current v0 behaviour."
    57	  - **Likely:** FIX-IN-PLACE + DEFER. Re-label both lines as W4-planned (mark with planned-W4 tag); implementation deferred to bundle-build slice.
    58	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
    59	
    60	### Finding 3. Gate A failure signature incomplete
    61	  - **Cite:** §4 lines 117-119 vs §6 line 171 + `validate.sh` lines 253-255
    62	  - **Codex says:** "Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature."
    63	  - **Likely:** FIX-IN-PLACE. Add `ESC_VOICE_DRIFT` to the §4 line 117-119 signature list.
    64	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
    65	
    66	### Finding 4. Citation drift in §3
    67	  - **Cite:** §3 line 45 citing `validate.sh` lines 89-97
    68	  - **Codex says:** "Line 45 cites `validate.sh` lines 89-97 as saying 'W4 polish adds title + order check,' but those lines say only that exact heading matching is not implemented and 'At W3 build' it should tighten. Fix the citation wording to match the live file or remove the quoted claim."
    69	  - **Likely:** FIX-IN-PLACE. Verify lines 89-97 of `validate.sh`, rewrite the quote to match exactly OR remove the quotation marks and rephrase as paraphrase.
    70	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
    71	
    72	### Finding 5. Stale Q3 resolution path
    73	  - **Cite:** §9 line 238; cross-ref §8 lines 213-215
    74	  - **Codex says:** "Line 238 says Proxycurl/API choice is 'Resolved at W3 start before Companies House + LinkedIn MCP connectors authored,' while this Day-19 artefact and §8 lines 213-215 say the connector/web-scraper work is already shipped and Proxycurl is deferred. Fix Q3 to describe the current W4 Proxycurl/commercial decision path."
    75	  - **Likely:** FIX-IN-PLACE. Rewrite Q3 to describe the actual Day-19 disposition (Proxycurl deferred; current W4 decision is whether to re-evaluate before pilot).
    76	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
    77	
    78	---
    79	
    80	## 2. Janitor — `agents/recruitment/janitor/agent.md`
    81	
    82	**Round:** R11 post-v0.3. Log: `logs/codex-ratification/20260524T174156Z-10120/`.
    83	
    84	### Finding 1. Gate A failures misrouted to single ESC code
    85	  - **Cite:** §5 line 187
    86	  - **Codex says:** "Line 187 says `ESC_AGENT_OUTPUT_SHAPE` applies to 'ALL Gate A conditions,' including voice classifier, PII, and write-batch size. The catalogue defines `ESC_VOICE_DRIFT` for classifier failures and `ESC_PII_LEAKAGE_RISK` as blocking for PII leakage; downgrading PII to `ESC_AGENT_OUTPUT_SHAPE` weakens Gate A routing. Fix §5 so each Gate A condition maps to its catalogue code, reserving `ESC_AGENT_OUTPUT_SHAPE` for report/output-shape failures only."
    87	  - **Likely:** FIX-IN-PLACE. Split §5 line 187 into per-condition routing: voice → VOICE_DRIFT; PII → PII_LEAKAGE_RISK; batch-size → AGENT_OUTPUT_SHAPE.
    88	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
    89	
    90	### Finding 2. `decision_log.outcome='approved_after_edit'` is wrong field
    91	  - **Cite:** §3 line 59; cross-ref v0.2 supplement §1.3 (recent_edit.resolution)
    92	  - **Codex says:** "Line 59 says tacit notes are harvested from `decision_log` rows with `outcome='approved_after_edit'`, but the schema only documents `decision_log` as `agent_name`, `phase`, and `payload JSONB`; `approved_after_edit` is the `recent_edit.resolution` enum in v0.2 supplement §1.3. Fix §3 to harvest from `recent_edit.resolution='approved_after_edit'` and use `decision_log` only for action-context joins."
    93	  - **Likely:** FIX-IN-PLACE. Rewrite §3 line 59 to source from `recent_edit.resolution`. Note that `decision_log.outcome` was added in `recent_edit`'s sister table in v0.3; verify this hasn't changed Codex's read.
    94	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
    95	
    96	### Finding 3. Wrong schema authority for recent_edit access
    97	  - **Cite:** §4 lines 135-137; cross-ref v0.3 supplement §2
    98	  - **Codex says:** "Lines 135-137 say Janitor queries the `recent_edit` v0.2 table directly, but v0.2 access lists only voice-drift-canary, Concierge, and LoRA; Janitor R access is added in v0.3 supplement §2. Fix the citation to v0.3 supplement and add v0.3 schema/migration ratification as a §8 prerequisite."
    99	  - **Likely:** FIX-IN-PLACE. Update citation to "v0.3 supplement §2"; add v0.3 migration RATIFIED as §8 build prereq.
   100	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   101	
   102	### Finding 4. `janitor_dedup_threshold` + `janitor_last_run` keys absent from schema supplement
   103	  - **Cite:** §2 + §4 lines 42, 95, 166; cross-ref v0.3 migration §5 allowlist
   104	  - **Codex says:** "Lines 42, 95, and 166 rely on `janitor_dedup_threshold` and `janitor_last_run`; `rg` finds these only in the v0.2-to-v0.3 migration allowlist, not in `vertical-schema.yaml` or the v0.3 supplement's `tenant_adapters_config_additions`. Fix by adding both keys with type/owner/read-write semantics to the schema supplement, then cite that schema section instead of only the migration allowlist."
   105	  - **Likely:** **REJECT-CODEX** with rationale, OR small schema supplement edit. The migration allowlist IS the v0.3 supplement enforcement (per ADR-006 + the v0.3 trigger). But Codex's point is that they should also appear in the YAML schema definition (`tenant_adapters_config_additions`) for documentation completeness. Founder call: edit the YAML supplement to declare them explicitly, OR write disagreement claiming migration-allowlist is sufficient single-source-of-truth.
   106	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   107	
   108	---
   109	
   110	## 3. Sourcing Scout — `agents/recruitment/sourcing-scout/agent.md`
   111	
   112	**Round:** R8 post-v0.3. Log: `logs/codex-ratification/20260524T151757Z-97714/`.
   113	
   114	### Finding 1. False schema-status claim for `blocked_recipients`
   115	  - **Cite:** §4 Step 8; cross-ref `v0.2-to-v0.3.sql` line 397
   116	  - **Codex says:** "It says 'the actual config-key SCHEMA registration is v0.4-supplement-pending' and that v0.3 only registers other keys, but `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` §5 allowlists `blocked_recipients` at line 397. Fix by removing the v0.4-pending claim for `blocked_recipients`; keep v0.4-pending only for `auto_source_on_brief_create`."
   117	  - **Likely:** FIX-IN-PLACE. Remove v0.4-pending claim for `blocked_recipients`; keep it only for `auto_source_on_brief_create`. (Verify: v0.3 migration line 397 does include `blocked_recipients` in allowlist? Confirmed in our earlier read: "tier_overrides, blocked_recipients, janitor_dedup_threshold..." — yes.)
   118	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   119	
   120	### Finding 2. Wrong Proposed→Accepted criteria for pre-build scaffold
   121	  - **Cite:** §10
   122	  - **Codex says:** "It flips to Accepted on ratification/founder questions/ADR-006 before the W9 bundle exists, but the agent-bundle skill treats Accepted as production-ready after sibling files + fixtures exist and pass gates. Fix by keeping this scaffold Proposed after ratification, and make Proposed → Accepted depend on W9 build completion: `tools.yaml`, `context.sh`, `validate.sh`, `cycle.sh`, `cleanup.sh`, and 3 fixtures."
   123	  - **Likely:** FIX-IN-PLACE. Edit §10 to gate Accepted on W9 bundle completion (sibling files + fixtures + gate A). Ratified scaffold stays at "Proposed (Ratified at Round-N)" until W9.
   124	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   125	
   126	### Finding 3. v1.0 Bullhorn webhook path active despite blocked config
   127	  - **Cite:** §1 + §2; cross-ref `auto_source_on_brief_create` v0.4-pending
   128	  - **Codex says:** "The output contract lists the webhook trigger as an active trigger, and §2 labels it 'Webhook (v1.0)', but §2 also says `auto_source_on_brief_create` is v0.4-supplement-pending and the code path is blocked. Fix by either moving webhook auto-source to deferred/v0.4+ surfaces, or add the v0.4 schema supplement as a hard §8 prerequisite and make the §1 contract explicitly conditional."
   129	  - **Likely:** FIX-IN-PLACE. Either tag webhook trigger as "v0.4+" or condition §1 on the v0.4 supplement landing. Founder preference: scope question — is the webhook trigger part of v1.0 surface or deferred?
   130	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   131	
   132	---
   133	
   134	## 4. Cash Conductor — `agents/recruitment/cash-conductor/agent.md`
   135	
   136	**Round:** R17 post-v0.3. Log: `logs/codex-ratification/20260524T145439Z-74254/`.
   137	
   138	### Finding 1. §8 sibling bundle list incomplete; capability names missing
   139	  - **Cite:** §8 lines 382-385; §4 various
   140	  - **Codex says:** "Lines 382-385 list `validate.sh`, `context.sh`, `cycle.sh`, and fixtures, but omit `tools.yaml` and `cleanup.sh`; meanwhile lines 36 and 54 explicitly rely on `tools.yaml`, and §4 invokes accounting/Open Banking capabilities without declared planned capability names. Add `tools.yaml` and `cleanup.sh` to §8 and name the planned `tools.yaml` capability for each §4 provider step."
   141	  - **Likely:** FIX-IN-PLACE. Add `tools.yaml` + `cleanup.sh` to §8 sibling list. Annotate §4 with planned capability names (`xero.invoices.list`, `truelayer.transactions.fetch`, etc.).
   142	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   143	
   144	### Finding 2. Concierge/D1 dependency under-specified
   145	  - **Cite:** §8 line 380; cross-ref §4 lines 235-253 + line 244 (D1)
   146	  - **Codex says:** "Line 380 says Cash Conductor only depends on Concierge `agent.md` being Accepted, but lines 235-253 require Concierge to receive drafts, run the approval bridge, transport sends, and callback; line 244 also cites the unresolved D1 path. Add Founder Decision D1 resolved + autosend bridge/Concierge transport availability as explicit prerequisites, or rewrite §4 to use the existing shared autosend approval helper without Concierge."
   147	  - **Likely:** FIX-IN-PLACE. Add to §8 prereqs: (a) D1 resolved, (b) Concierge autosend-bridge live. Note: D1 is W4 queue #4 — this finding documents the dependency in the agent.md but does NOT block ratification of the scaffold (Status will be Proposed→Pre-Build pending D1).
   148	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   149	
   150	### Finding 3. Impossible draft audit-row shape (output phase with action_type)
   151	  - **Cite:** §3 line 114; cross-ref §4 line 237
   152	  - **Codex says:** "Line 114 says each draft writes `phase='output'` with `action_type='xero_reminder_draft_internal'`, but `xero_reminder_draft_internal` is an autosend action type and §4 line 237 correctly routes it through `hh_decision_action`; `hh_decision_output` rows use output-type payloads, not autosend tier dispatch. Change §3 so draft generation is an output row such as `output_type='chase_draft_generated'`, and the queued draft is a separate `phase='action'` row with `action_type='xero_reminder_draft_internal'`."
   153	  - **Likely:** FIX-IN-PLACE. Split §3 line 114 into two rows: (a) `phase='output'` with `output_type='chase_draft_generated'`; (b) `phase='action'` with `action_type='xero_reminder_draft_internal'`.
   154	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   155	
   156	---
   157	
   158	## 5. Scribe — `agents/recruitment/scribe/agent.md`
   159	
   160	**Round:** R3 post-v0.3. Log: `logs/codex-ratification/20260524T174401Z-12038/`.
   161	
   162	### Finding 1. Schema-source field names mismatched
   163	  - **Cite:** §3 lines 76-80; cross-ref `vertical-schema.yaml` + v0.3 supplement
   164	  - **Codex says:** "Lines 76-80 list `brief.start_date`, `placement.week_1_status_note`, and `opportunity.sector` as canonical/schema-verified, but `vertical-schema.yaml` uses `start_date_target` and the v0.3 supplement explicitly says `week_1_status_note` became `week_1_status_vault_path` and `opportunity.sector` is not yet in schema. Fix the field table to use schema-backed names or land the missing supplement before ratification."
   165	  - **Likely:** FIX-IN-PLACE. Replace field names: `start_date` → `start_date_target`; `week_1_status_note` → `week_1_status_vault_path`. For `opportunity.sector`: drop from canonical, or escalate to "v0.4-pending" tag.
   166	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   167	
   168	### Finding 2. Output/action steps missing `hh_decision_*` calls
   169	  - **Cite:** §4 lines 141-149 (transcript fetch) + lines 180-184 (field extract/mutate)
   170	  - **Codex says:** "Lines 141-149 refresh Bullhorn auth and fetch/store a transcript in `/tmp` without any decision-log write; lines 180-184 validate and mutate the extracted field set without a `hh_decision_output` or Gate-A failure action. Add decision-log calls for each output/action/failure point or mark the steps as purely internal with no side effect."
   171	  - **Likely:** FIX-IN-PLACE. Add `hh_decision_output transcript_fetched` after line 149; add `hh_decision_output extraction_complete` + `hh_decision_action gate_a_passed/failed` after line 184.
   172	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   173	
   174	### Finding 3. Ringover declared v1.0 without build dependencies
   175	  - **Cite:** §3 lines 16, 30, 39; cross-ref §8 lines 295-298 + ULTRAPLAN A3 lines 521-523
   176	  - **Codex says:** "Lines 16, 30, and 39 include Ringover as a provider, but §8 lines 295-298 only gate Fathom/Fireflies signup and connector work; ULTRAPLAN A3 lines 521-523 require Bullhorn, Fathom, and Fireflies tools/APIs, not Ringover. Either remove Ringover from v1.0 surfaces or add the Ringover commercial/API/connector prerequisites explicitly."
   177	  - **Likely:** SCOPE question. Was Ringover ever in scope or is this a transcription? Founder call: drop Ringover from v1.0 (clean delete) OR add Ringover as a planned v1.1 surface (tag with v1.1-pending). Memory note: `feedback_cold_outreach_dont_overstate.md` and `feedback_verify_urls_before_claiming.md` suggest the founder prefers not overstating capabilities → recommend **drop Ringover** unless there's a specific pilot need.
   178	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   179	
   180	### Finding 4. autosend-policy YAML citation wrong
   181	  - **Cite:** §3 lines 16, 214
   182	  - **Codex says:** "Line 16 cites `autosend-safety-policy.yaml` and line 214 cites `autosend-safety-policy §4`, but the runtime YAML in the repo is `agents/_shared/autosend-policy.yaml`; `autosend-safety-policy` exists as a decision `.md`, not YAML. Replace the YAML citation with `agents/_shared/autosend-policy.yaml` and cite the decision doc only when referring to policy rationale."
   183	  - **Likely:** FIX-IN-PLACE. Replace `autosend-safety-policy.yaml` → `agents/_shared/autosend-policy.yaml` (runtime) where mechanical; keep `autosend-safety-policy §4` where it's the decision-doc rationale citation, but fix to `docs/decisions/autosend-safety-policy.md §4`.
   184	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   185	
   186	### Finding 5. ESC_PROVIDER_FETCH_FAIL used outside catalogue definition
   187	  - **Cite:** §6 line 250; cross-ref `agents/_shared/escalation-codes.md` lines 324-329
   188	  - **Codex says:** "Line 250 defines it for Fathom/Fireflies/Ringover transcript fetches, but `agents/_shared/escalation-codes.md` lines 324-329 define a generic upstream read failure with examples that do not include transcript providers and no transcript-specific payload. Either update the catalogue to register transcript-provider usage and payload fields, or use/register a Scribe-specific transcript fetch code."
   189	  - **Likely:** FIX-IN-PLACE. Either add transcript-provider examples + payload to catalogue line 324-329 (small edit; touches `_shared`, needs ratification of catalogue change too), OR register a new code `ESC_TRANSCRIPT_FETCH_FAIL`. Catalogue extension is cleaner.
   190	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   191	
   192	---
   193	
   194	## 6. Concierge — `agents/recruitment/concierge/agent.md`
   195	
   196	**Round:** R3 post-v0.3. Log: `logs/codex-ratification/20260524T174513Z-13185/`.
   197	
   198	### Finding 1. Output/action steps missing `hh_decision_*` calls
   199	  - **Cite:** §4 lines 187-193 (draft write) + lines 222-228 (approval routing)
   200	  - **Codex says:** "Lines 187-193 write the draft to `/vault/<tenant>/concierge-drafts/<draft_id>.md` but do not log the output; lines 222-228 route approval via autosend-bridge but do not log the approval-routing action. Type-specific §1 requires every output/action step to call `hh_decision_*`. Add explicit `hh_decision_output` for draft creation and `hh_decision_action` or `hh_decision_output` for approval routing."
   201	  - **Likely:** FIX-IN-PLACE. Add `hh_decision_output concierge_email_draft` after line 193; add `hh_decision_action approval_routed` after line 228.
   202	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   203	
   204	### Finding 2. Draft mis-classified as orange tier
   205	  - **Cite:** §3 line 67; cross-ref line 102 + `autosend-policy.yaml`
   206	  - **Codex says:** "Line 67 says 'an email draft (orange tier)', but lines 102 and autosend-policy define `concierge_email_draft` as yellow; only the send actions are orange. This creates an internal contract conflict for Gate A/B and decision_log rows. Change line 67 to 'email draft (yellow tier); send is separate orange-tier action'."
   207	  - **Likely:** FIX-IN-PLACE. Edit §3 line 67 verbatim per Codex's suggested phrasing.
   208	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   209	
   210	### Finding 3. Gate-A→Gate-B reframe omitted from §10 status-flip criteria
   211	  - **Cite:** §10 lines 417-421; cross-ref ULTRAPLAN A6 line 566 + lines 206-212/276
   212	  - **Codex says:** "Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria. Either keep the 30-minute SLA as Gate A, or add the Concierge-Gate-A ADR ratification as an explicit Accepted blocker."
   213	  - **Likely:** **SCOPE-EXPAND**. This is the analogue of ADR-006 for Diagnostic. W4 queue #3 already plans this ADR ("Future ADR — Concierge Gate A 30-min SLA hybrid"). Disposition options:
   214	    - (a) Add Concierge-Gate-A-ADR to §10 Accepted blockers; flip Concierge agent.md → RATIFIED (but Status stays Proposed pending ADR). W4 #3 then writes the ADR + closes the loop.
   215	    - (b) Write the ADR NOW in this session (15-30 min) and then close both at once.
   216	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   217	
   218	### Finding 4. ULTRAPLAN line-citation drift
   219	  - **Cite:** §3 lines 16, 39, 76, 333, 345; cross-ref ULTRAPLAN A6
   220	  - **Codex says:** "Lines 16, 39, 76, 333, and 345 cite line 570 for lifecycle/rejection gotchas, but verified ULTRAPLAN has the gotcha text on line 569 and line 570 is blank. Update these citations to ULTRAPLAN A6 line 569."
   221	  - **Likely:** FIX-IN-PLACE. Find-and-replace `ULTRAPLAN A6 line 570` → `ULTRAPLAN A6 line 569`. Verify count: 5 sites.
   222	  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
   223	
   224	---
   225	
   226	## Cross-cutting observations
   227	
   228	1. **Hh_decision_* coverage** (Scribe #2, Concierge #1) — workflow narratives are dropping the decision-log writes between numbered steps. After this pass, recommend a one-shot grep on all 6 agent.md to confirm every workflow step that produces output/action has an `hh_decision_*` annotation.
   229	
   230	2. **Schema-citation hygiene** (Janitor #2, #3, #4; Sourcing Scout #1; Scribe #1) — v0.2/v0.3 supplement boundary is the single most-failed cross-reference. After this pass, recommend a CI grep that flags any `agent.md` field reference whose name doesn't appear in `vertical-schema.yaml` OR `vertical-schema.v0.3-supplement.yaml`.
   231	
   232	3. **Catalogue completeness** (Diagnostic #2, Janitor #1, Scribe #5) — `escalation-codes.md` is the canonical mapping; agent.md narratives drift from it. After this pass, recommend a CI grep verifying every `ESC_*` reference in `agent.md` exists in the catalogue with at least the agent_name in `used_by`.
   233	
   234	4. **Concierge Gate-A ADR** (Concierge #3) — only structural finding. Recommend writing the ADR before flipping Concierge to RATIFIED (analogue of ADR-006 process).
   235	
   236	5. **Status semantics** (Sourcing Scout #2) — confirm with founder: "Ratified at Round-N" is not "Accepted"; Accepted requires bundle completion. Likely a one-line clarification in the agent-bundle skill or master brief §8 to prevent this drift in future agents.
   237	
   238	---
   239	
   240	## Acceptance checklist (per agent)
   241	
   242	For each of the 6 agents, the bilateral pass produces:
   243	
   244	- [ ] All findings dispositioned (FIX-IN-PLACE / DEFER / REJECT-CODEX / SCOPE-EXPAND)
   245	- [ ] FIX-IN-PLACE edits applied to agent.md (or sibling files)
   246	- [ ] REJECT-CODEX disagreements written to `docs/decisions/codex-disagreement-2026-05-25.md`
   247	- [ ] SCOPE-EXPAND items moved to W4 backlog with concrete next-action
   248	- [ ] `bash scripts/run-codex-ratification.sh agent-bundle agents/recruitment/<agent>/agent.md` returns `RATIFIED`
   249	- [ ] §10 Status flipped Pre-Build-Round-N-Reviewed → **RATIFIED**
   250	- [ ] Commit with `bilateral-pass(w4): <agent> → RATIFIED + N residuals dispositioned`
   251	
   252	## Session-close acceptance
   253	
   254	- [ ] 4-6 of 6 agents RATIFIED in this session
   255	- [ ] Remaining agents have concrete blockers documented (e.g., "Concierge pending Concierge-Gate-A ADR")
   256	- [ ] Diagnostic is RATIFIED (Trigger 2 burn-down)
   257	- [ ] `.agents/current-priorities.md` updated with W4 Day-20 close

 succeeded in 0ms:
     1	# Concierge — no candidate ghosted
     2	
     3	**Status:** Pre-Build-Round-4-Bilateral-Applied (Day-20; W4 bilateral pass applied + ADR-007 drafted). All 4 R3 residuals addressed: Findings 1 + 2 + 4 closed by post-R3 commit `f79c018` (yellow draft tier + Step 7 decision-log + ULTRAPLAN line citations removed where stale); R4 polish today adds Step 11 `hh_decision_action("concierge_approval_routed"...)` for the autosend-bridge routing (closes the remaining Step-11 gap in Finding 1); Finding 3 (structural — Gate-A 30-min SLA deviation) closed by drafting `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` + adding ADR-007 to §10 Accepted blockers. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + ADR-007 RATIFIED + W10 build slice.
     4	**Date:** 2026-05-24.
     5	**Author:** Founder (Maddox) + Claude Code.
     6	**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
     7	**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
     8	**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).
     9	
    10	---
    11	
    12	## §1 — Output contract (one-paragraph screenshot)
    13	
    14	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    15	
    16	> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
    17	
    18	---
    19	
    20	## §2 — Invocation surface
    21	
    22	### Lifecycle webhook (v1.0 primary)
    23	
    24	```http
    25	# Bullhorn placement state-change webhook → Concierge handler
    26	POST https://<tenant>.ifos.app/agents/concierge/webhook
    27	Authorization: Bearer <bullhorn-shared-secret>
    28	Content-Type: application/json
    29	
    30	{
    31	  "event_type": "placement.state_changed" | "candidate.state_changed",
    32	  "entity_id": "<bullhorn-id>",
    33	  "from_state": "interview_scheduled",
    34	  "to_state": "interview_completed",
    35	  "timestamp": "<ISO>"
    36	}
    37	```
    38	
    39	Bullhorn webhook coverage is patchy per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha — see Step 1 polling fallback.
    40	
    41	### Cron (polling fallback + time-elapsed nurture)
    42	
    43	```bash
    44	# Every 5 min: poll Bullhorn for missed state transitions
    45	*/5 * * * * sudo -u ifos_user /usr/local/bin/ifos-concierge.sh --tenant <slug> --mode poll
    46	# Daily 09:00 UTC: time-elapsed nurture sweeps (7d / 30d / 90d check-ins)
    47	0 9 * * * sudo -u ifos_user /usr/local/bin/ifos-concierge.sh --tenant <slug> --mode nurture-sweep
    48	```
    49	
    50	### Manual (debugging)
    51	
    52	```bash
    53	ifosctl concierge generate --tenant <slug> --candidate <id> --event <event-type>
    54	ifosctl concierge replay --tenant <slug> --webhook-id <id>
    55	```
    56	
    57	### v1.1+ surfaces (deferred)
    58	
    59	- agent-identity email adapter (deferred) integration (agent-identity sends for non-rejection comms)
    60	- Brain UI lifecycle-event timeline viewer per candidate
    61	- Per-tenant comms-type taxonomy customisation
    62	
    63	---
    64	
    65	## §3 — Output shape
    66	
    67	One output per lifecycle event: an email draft (yellow tier `concierge_email_draft` per autosend-policy.yaml; only the customer-facing SEND is orange tier — `gmail_outlook_send_to_candidate` / `bullhorn_note_customer_visible` / `twilio_sms_send` / `calendar_invite_send` per channel). 12 lifecycle events × per-tenant comms-template variants:
    68	
    69	| # | Event | Comms type | Recipient | Tone |
    70	|---|---|---|---|---|
    71	| 1 | Application received | Acknowledgement | Candidate | Warm, professional, sets expectations on response timeline |
    72	| 2 | Interview booked | Prep | Candidate | Practical (date, time, format, interviewers) + role context |
    73	| 3 | Interview completed | Debrief | Candidate | Thank-you + next-step clarity OR "we'll be in touch by X" |
    74	| 4 | Offer extended | Placement-positive | Candidate | Excited, clear on terms, addressee-resolution-critical |
    75	| 5 | Offer accepted | Placement-confirm | Candidate + Client (separate drafts) | Reassurance + practical next steps |
    76	| 6 | Rejected (post-interview) | Rejection | Candidate | THE HARDEST CASE per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) — respectful, specific, leaves door open |
    77	| 7 | Withdrawn (candidate-initiated) | Acknowledgement | Candidate | Respectful, no pressure, leaves door open |
    78	| 8 | On-hold | Status-update | Candidate | Honest about timeline, sets expectations on next update |
    79	| 9 | Start date confirmed | Placement-pre-start | Candidate + Client | Practical (HR forms, IT setup, day-1 logistics) |
    80	| 10 | 7-day check-in (post-start) | Nurture-check-in | Candidate | "How's it going? Any blockers?" — short, low-pressure |
    81	| 11 | 30-day check-in | Nurture-check-in | Candidate + Client | Slightly longer; both sides; reads for placement-risk signals |
    82	| 12 | 90-day check-in | Nurture-check-in + relationship | Candidate + Client | Establishes ongoing relationship; offers "is there anyone in your network looking?" |
    83	
    84	Draft structure per event:
    85	
    86	```yaml
    87	draft_id: <uuid>
    88	event_type: <one of 12 above>
    89	candidate_id: <bullhorn-id>
    90	placement_id: <bullhorn-id or null>
    91	recipient: <candidate-email | client-contact-email>
    92	recipient_role: candidate | client_contact
    93	subject: <subject line; voice-classified>
    94	body_markdown: <body; voice-classified>
    95	voice_score: <0-1>
    96	addressee_resolution_check: passed | failed
    97	attached_documents: <list — e.g., feedback summary, prep guide, comms history>
    98	escalation_position: 1-3 (for sensitive sends like rejection)
    99	expected_send_window: <ISO; respects sending-hours per tenant config>
   100	```
   101	
   102	Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).
   103	
   104	The actual SEND is a separate orange-tier action_type:
   105	- `gmail_outlook_send_to_candidate` (orange tier per autosend-policy.yaml §ORANGE) when channel=email
   106	- `bullhorn_note_customer_visible` (orange tier; canonical orange per autosend-policy.yaml §ORANGE) when channel=Bullhorn note with isExternal=true
   107	- `twilio_sms_send` (orange tier per autosend-policy.yaml §ORANGE) when channel=SMS (v1.1+)
   108	- `calendar_invite_send` (orange tier per autosend-policy.yaml §ORANGE) when event includes calendar attachment
   109	
   110	Consultant approves via autosend-bridge (D1 path) → orange-tier send executes → Bullhorn activity-log entry written post-send.
   111	
   112	---
   113	
   114	## §4 — Workflow
   115	
   116	15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
   117	
   118	```
   119	0. Session start (webhook OR poll OR cron)
   120	   → context.sh hydrates: tenant config + Bullhorn auth refresh +
   121	     Microsoft Graph / Gmail auth + agent-identity email adapter (deferred) (if v1.1+ enabled) +
   122	     voice corpus + tone rules + recent_edits + tenant comms-template
   123	     library + addressee-resolution data
   124	   → hh_decision_trigger("session_start", "<webhook|poll|cron-nurture>")
   125	
   126	1. Source detection (mode-dependent)
   127	   → mode=webhook: parse Bullhorn payload → resolve entity + state transition
   128	   → mode=poll: query Bullhorn for placements/candidates with state_changed_at
   129	     > tenant_adapters.config.concierge_last_poll AND not in decision_log
   130	     (anti-duplicate)
   131	   → mode=nurture-sweep: query Bullhorn placements for time-elapsed events
   132	     (7d/30d/90d post-start with no concierge action in last 14d)
   133	   → ESC_LIFECYCLE_STATE_UNKNOWN if state transition not in 12-event taxonomy
   134	   → hh_decision_output("lifecycle_event_detected",
   135	     "<entity_type>:<bullhorn_id>", "<from>→<to>")
   136	
   137	2. Anti-duplicate guard
   138	   → query decision_log for prior `concierge_email_draft` row for same
   139	     (candidate_id, payload.event_type) in last 24h with phase IN
   140	     ('output', 'action') — if a prior draft was emitted AND either sent OR
   141	     is still pending consultant action, the new event is a duplicate trigger
   142	   → if found AND send-completed: skip (true duplicate)
   143	   → if found BUT prior draft never sent (no `gmail_outlook_send_to_candidate`
   144	     follow-up action row): allow the new draft attempt (per Q7 disposition)
   145	   → hh_decision_output("anti_duplicate_check", "<entity_type>:<bullhorn_id>",
   146	     "<duplicate_status>")
   147	
   148	3. Bullhorn context fetch
   149	   → bullhorn.get_candidate(candidate_id) → name, current state, comms history
   150	   → bullhorn.get_placement(placement_id) → role, client, dates
   151	   → bullhorn.get_client(client_id) → company name, primary contact
   152	   → bullhorn.get_contact(contact_id) → name, email
   153	   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
   154	     ESC_BULLHORN_AUTH on auth fail
   155	   → ESC_AGENT_OUTPUT_SHAPE if critical Bullhorn context fields missing
   156	     (no email, no name) — Concierge cannot produce its declared output
   157	     shape (lifecycle-event draft) without a resolvable target candidate.
   158	     NOTE: ESC_CANDIDATE_DATA_INCOMPLETE is reserved for Sourcing Scout
   159	     shortlist completeness per catalogue §2.10.
   160	   → hh_decision_output("bullhorn_context_fetched",
   161	     "candidate:<bullhorn_id>", "fields_present:<N>")
   162	
   163	4. Addressee resolution (Gate A critical)
   164	   → recipient = candidate.email OR client_contact.email per event_type
   165	   → verify recipient matches the candidate_id whose lifecycle is changing
   166	     (NOT another candidate's email — per ULTRAPLAN A6 line 566 verbatim
   167	     "correct addressee resolution; no candidates emailed under another's name")
   168	   → ESC_ADDRESSEE_MISMATCH if check fails (blocking); draft aborted
   169	   → hh_decision_output("addressee_resolved", "candidate:<bullhorn_id>",
   170	     "recipient_role:<role>")
   171	
   172	5. Comms-template selection
   173	   → tenant comms-template library at /vault/<slug>/concierge-templates/
   174	   → per event_type: select template; per recipient_role: candidate vs client
   175	   → fallback: shared/common-comms-templates.yaml if tenant has no override
   176	   → hh_decision_output("template_selected", "<event_type>:<recipient_role>",
   177	     "template_id:<id>")
   178	
   179	6. Sensitive-event escalation routing
   180	   → if event_type=rejection (event 6) OR event_type=withdrawal (event 7)
   181	     OR (event_type=on-hold AND placement value >£10k): set escalation_position=3
   182	     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
   183	   → else: escalation_position=1 (standard orange tier)
   184	   → hh_decision_output("escalation_position_set", "candidate:<bullhorn_id>",
   185	     "position:<N>")
   186	
   187	7. LLM draft generation
   188	   → prompt = (event context + candidate state history + voice corpus
   189	     ANN-matched on event_type + tone rules filtered for concierge +
   190	     comms-template structure)
   191	   → output = email body + subject + recommended_send_time
   192	   → write to /vault/<tenant>/concierge-drafts/<draft_id>.md
   193	   → hh_decision_output("concierge_draft_rendered",
   194	     "candidate:<bullhorn_id>:<event_type>", "vault_path:<path>; voice_score:<N>; words:<N>")
   195	   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries
   196	
   197	8. Voice + tone validation
   198	   → voice classifier scores the draft
   199	   → minimum threshold by escalation_position:
   200	     position 1: ≥0.75
   201	     position 2: ≥0.78
   202	     position 3 (rejections / sensitive): ≥0.82
   203	   → tone-rule check (block-severity rules → ESC_TONE_RULE_VIOLATION)
   204	   → on success: hh_decision_action("concierge_email_draft",
   205	     "<candidate_bullhorn_id>:<event_type>", payload_hash, payload_preview);
   206	     tier=yellow per autosend-policy.yaml
   207	
   208	9. SLA timing check (Gate B leading metric — NOT Gate A hard-fail)
   209	   → elapsed = now() - event_timestamp
   210	   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
   211	   → per ULTRAPLAN A6 line 566 verbatim "every lifecycle event has a draft
   212	     generated within 30 minutes" — interpreted as a Gate B leading metric
   213	     (90% of drafts within 30 min) rather than per-draft hard fail (legitimate
   214	     polling-fallback delays would otherwise block drafts entirely)
   215	
   216	10. PII boundary check
   217	    → no PII from other candidates referenced in body
   218	    → no PII from competitor clients referenced
   219	    → no compensation specifics outside what's already in candidate's record
   220	    → ESC_PII_LEAKAGE_RISK on hit (blocking)
   221	    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
   222	     "result:passed")
   223	
   224	11. Autosend-bridge routing (D1 path)
   225	    → per Founder Decision D1 (final selection at W10 design):
   226	      D1-A (bridge to cortextOS approval system): POST internal API
   227	      D1-B (lightweight Telegram shim): send approval prompt to operator
   228	      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
   229	    → per autosend-policy.yaml: orange-tier; consultant approves
   230	    → ESC_APPROVAL_BRIDGE_TIMEOUT if no approval within 24h (D1-A/B)
   231	    → hh_decision_action("concierge_approval_routed",
   232	      "candidate:<bullhorn_id>:<event_type>", payload_hash,
   233	      "d1_path:<A|B|C>; bridge_target:<approval_id_or_vault_path>")
   234	
   235	12. (After operator approval) Send execution — orange-tier
   236	    → microsoft-graph.send_email() OR gmail.send_email() per tenant config
   237	    → BCC: tenant's archive address (per tenant config)
   238	    → hh_decision_action("gmail_outlook_send_to_candidate",
   239	      "candidate:<bullhorn_id>", payload_hash, payload_preview)
   240	      [or `bullhorn_note_customer_visible` if channel=Bullhorn-note]
   241	    → ESC_SEND_FAIL on 4xx/5xx; retry once 30s backoff
   242	
   243	13. Bullhorn activity-log write
   244	    → bullhorn.create_activity_log(candidate_id, "concierge: <event_type>
   245	      sent at <ISO>")
   246	    → maintains audit trail in Bullhorn itself
   247	    → hh_decision_output("bullhorn_activity_logged",
   248	      "candidate:<bullhorn_id>", "event_type:<type>")
   249	
   250	14. Lifecycle state advance (Bullhorn write, conditional)
   251	    → some events trigger Bullhorn state changes (e.g., interview-completed
   252	      sent → advances state to "post-interview" if tenant policy says so)
   253	    → per-tenant policy; opt-in; not all tenants want this
   254	    → hh_decision_action("concierge_send_complete", "candidate:<bullhorn_id>",
   255	      payload_hash, "event=<type> elapsed=<seconds>")
   256	
   257	15. Session close + Gate B metric
   258	    → compute elapsed (event → send) for Gate B SLA tracking
   259	    → check ghosted-rate metric (any candidate with no Concierge action in
   260	      14 days post-state-change → contributes to ghosted-rate)
   261	    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
   262	    → hh_decision_action("concierge_run_complete", session_id, run_mode)
   263	    → exit code 0
   264	```
   265	
   266	---
   267	
   268	## §5 — Gates
   269	
   270	### Gate A — validate.sh (hard-fail before action)
   271	
   272	Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
   273	
   274	- **"voice classifier score ≥ position-specific threshold"** (≥0.75 position 1, ≥0.78 position 2, ≥0.82 position 3) — hard-fail
   275	- **"correct addressee resolution (no candidates emailed under another's name)"** — hard-fail (Step 4 critical; ESC_ADDRESSEE_MISMATCH)
   276	- No tone-rule block-severity violations — hard-fail (ESC_TONE_RULE_VIOLATION)
   277	- No PII outside firm boundary — hard-fail (ESC_PII_LEAKAGE_RISK)
   278	- Anti-duplicate guard passed (Step 2) — hard-fail (skip if true duplicate)
   279	- All Bullhorn context fields present (no missing candidate name / no missing email) — hard-fail (ESC_AGENT_OUTPUT_SHAPE; ESC_CANDIDATE_DATA_INCOMPLETE is Sourcing Scout's per catalogue §2.10)
   280	
   281	The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
   282	
   283	Gate A failures fire `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` or `ESC_PII_LEAKAGE_RISK` or `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint — missing Bullhorn context OR voice threshold misses persistently) — all blocking; draft to `/tmp`; operator notified immediately.
   284	
   285	**Honesty note (per bilateral-disposition Cat-5):** Concierge `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W10-13 build slice. The W10-13 build delivers `agents/recruitment/concierge/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   286	
   287	### Gate B — Outcome thresholds (success metrics, not block)
   288	
   289	Per ULTRAPLAN A6 line 567 verbatim: **"<5% candidate-ghosted rate; ≥60% send-as-is rate on drafts"**.
   290	
   291	Two metrics:
   292	- **Ghosted-rate:** % of candidates with a lifecycle state change in the last 30 days who received no Concierge comm within 14 days of that change. Target <5%.
   293	- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`.
   294	
   295	Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
   296	
   297	---
   298	
   299	## §6 — Escalation codes
   300	
   301	Concierge uses these ESC codes from `agents/_shared/escalation-codes.md`:
   302	
   303	| Code | Trigger | Severity | Routing |
   304	|---|---|---|---|
   305	| `ESC_BULLHORN_AUTH` | OAuth refresh fails (payload.failure_type='refresh_failed' or 'revoked_401' covers the 6+ consecutive failure case) | **blocking** | operator + ifos_oncall |
   306	| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
   307	| `ESC_MS_GRAPH_AUTH` | Microsoft Graph OAuth fail | **blocking** | operator + ifos_oncall + tenant-admin (token re-auth required) |
   308	| `ESC_GMAIL_AUTH` | Gmail OAuth fail | **blocking** | operator + ifos_oncall + tenant-admin |
   309	| `ESC_LIFECYCLE_STATE_UNKNOWN` | Bullhorn state transition not in 12-event taxonomy | warn (handler logs + skips draft) | operator_chat_id |
   310	| (Concierge does NOT use `ESC_CANDIDATE_DATA_INCOMPLETE` — per catalogue §2.10 that code is reserved for Sourcing Scout shortlist completeness. Concierge's missing-Bullhorn-context case fires `ESC_AGENT_OUTPUT_SHAPE` per Gate A discipline below.) | — | — |
   311	| `ESC_ADDRESSEE_MISMATCH` | Step 4 critical — wrong recipient | **blocking** | operator + ifos_oncall |
   312	| `ESC_VOICE_DRIFT` | Voice classifier below position-specific threshold after 3 retries | warn (position 1-2) or **blocking** (position 3) | operator_chat_id (1-2) / operator + ifos_oncall (position 3) |
   313	| `ESC_TONE_RULE_VIOLATION` | Block-severity tone rule hit | **blocking** | operator + ifos_oncall |
   314	| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary | **blocking** | operator + ifos_oncall |
   315	| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |
   316	| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within 24h | warn | operator + tenant-admin |
   317	| `ESC_SEND_FAIL` | Email provider 4xx/5xx | warn | operator_chat_id |
   318	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
   319	| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% for 30 consecutive days | warn | founder + operator |
   320	| `ESC_AUTOSEND_ORANGE_PENDING` | Draft awaiting approval (info — heartbeat reminder when ≥50% of timeout elapsed) | info | (logged) |
   321	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow/orange-tier sample row selected for audit | info | operator_chat_id |
   322	
   323	Concierge has the largest escalation surface of any v1.0 agent — appropriate for the highest-stakes customer-facing comms.
   324	
   325	Concierge does NOT use:
   326	
   327	- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
   328	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Concierge's Gate A failures are output-shape or addressee-resolution failures.
   329	- `ESC_VOICE_DRIFT_TENANT` (direct firing) — that's fired by the nightly voice-drift cron per catalogue §2.5; Concierge fires only per-run `ESC_VOICE_DRIFT`.
   330	
   331	---
   332	
   333	## §7 — Voice + tone constraints
   334	
   335	Steps 7-8 (draft generation + voice/tone validation) are the load-bearing voice surface of v1.0. The agent integrates with `_shared/voice-loader.sh`:
   336	
   337	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
   338	  - No "We regret to inform you" boilerplate (rejection emails are the hardest test case per ULTRAPLAN A6 §gotchas (line numbers vary; see live file); demand specificity)
   339	  - No "Per our previous conversation" without referencing the actual conversation context
   340	  - No urgency language ("URGENT", "ACT NOW") unless the lifecycle event genuinely requires it
   341	  - No mention of other candidates by name
   342	  - No salary/rate specifics outside what's already on the candidate's record
   343	  - No competing-agency references
   344	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
   345	- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
   346	
   347	**Position-specific thresholds:**
   348	- Position 1 (standard sends — acknowledgement, prep, debrief, nurture): voice ≥0.75
   349	- Position 2 (placement-positive, status-update): voice ≥0.78
   350	- Position 3 (rejections, sensitive on-hold): voice ≥0.82 (ULTRAPLAN A6 §gotchas (line numbers vary; see live file) explicitly names rejection voice as the hardest case)
   351	
   352	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   353	
   354	---
   355	
   356	## §8 — Build dependencies (W10-13 prerequisites)
   357	
   358	Concierge build cannot start until ALL of the following are confirmed:
   359	
   360	| Dependency | Source | Status |
   361	|---|---|---|
   362	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   363	| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
   364	| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
   365	| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
   366	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   367	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   368	| Bullhorn MCP R+W capability | W3-W4-W5 build chain | ⏸ |
   369	| **Microsoft Graph commercial signup** (per tenant) | Tenant onboarding | ⏸ |
   370	| **Gmail / Google Workspace signup** (alternative per tenant) | Tenant onboarding | ⏸ |
   371	| Microsoft Graph MCP connector | W10 build start (~3 days) | ⏸ |
   372	| Gmail MCP connector | W10 build start (~3 days) | ⏸ |
   373	| **Founder Decision D1 (autosend orange-tier path)** RESOLVED | Founder decision; awaits review of D1-A/B/C spec | ⏸ |
   374	| Autosend bridge built (per D1 outcome) | W10 build start (~2 days for D1-A; less for D1-B/C) | ⏸ |
   375	| Voice classifier microservice live | W4-5 polish | ⏸ |
   376	| Per-tenant comms-template library at `/vault/<slug>/concierge-templates/` | Tenant onboarding | ⏸ |
   377	| Tenant tone_rule table seeded for concierge | Tenant-admin | ⏸ |
   378	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   379	| `validate.sh` Gate A logic | Build at W10 start (~2 days; most complex of v1.0 validators) | ⏸ |
   380	| `context.sh` hydration | Build at W10 start (~1 day) | ⏸ |
   381	| `cycle.sh` orchestration (15-step) | Build at W10-11 (~5 days; lifecycle state machine + 12 event types) | ⏸ |
   382	| Lifecycle event-detection polling fallback | Build at W11-12 (~3 days; Bullhorn webhook coverage gaps) | ⏸ |
   383	| Comms-template library v0.1 (12 event types × 2 recipient roles = 24 templates minimum) | Build at W12-13 (~5 days) | ⏸ |
   384	| 5 fixtures with golden outputs (broader than 3 for other agents; XL complexity warrants) | Build at W13 (~2 days) | ⏸ |
   385	
   386	**Until ALL ⏸ items resolve to ✅, W10 build slice does not start.** XL build complexity = 4-week duration not negotiable.
   387	
   388	---
   389	
   390	## §9 — Status + open questions
   391	
   392	**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + D1 founder decision + Q1 LOI + W10-13 build slice.
   393	
   394	### Open questions for founder review
   395	
   396	| # | Question | Resolution path |
   397	|---|---|---|
   398	| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
   399	| Q2 | Lifecycle event taxonomy — 12 events proposed in §3. Founder confidence each is correct + complete? Missing: "candidate referred to another role internally"? "Client cancelled brief"? | Founder review with first pilot consultants. Recommend: ship 12-event v1.0; expand v1.1+ based on real patterns. |
   400	| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
   401	| Q4 | Rejection emails (event 6) — Position 3 (voice ≥0.82). Is this enough, or should rejections route to consultant for full draft (not just approve)? | Founder review with first pilot consultant. Recommend: Concierge drafts; consultant approves; never bypasses voice gate. |
   402	| Q5 | Comms-template customisation — every tenant edits these. Per-event-type, per-recipient-role × per-tenant = 24+ templates each. Authoring tool? | v1.0: Markdown files at `/vault/<slug>/concierge-templates/<event>-<role>.md`. v1.1: Brain UI WYSIWYG editor. |
   403	| Q6 | Send-as-is rate (Gate B ≥60%) — measurement requires consultant to differentiate "approve" from "edit-and-approve". Brain UI v1.0 has no such control yet. Telegram-based approval? | Telegram-based for v1.0: `/approve <draft-id>` vs `/approve-edit <draft-id> <revised-body>`. Brain UI v1.1+ adds inline edit UX. |
   404	| Q7 | Anti-duplicate guard window — 24h proposed in Step 2. Edge case: webhook + poll cycle both fire same event within 5 min → second skipped. What if first failed silently? | Anti-duplicate also checks decision_log for `phase='action'` not just `phase='trigger'` — if first didn't send, second can attempt. |
   405	| Q8 | agent-identity email adapter (deferred) (v1.1+) — agent-identity sends. Should Concierge use agent-identity email adapter (deferred) for rejection emails (less personal pressure on consultant approving) or always tenant-identity? | v1.0: tenant-identity (Microsoft Graph / Gmail). v1.1+: agent-identity email adapter (deferred) experiment per tenant opt-in. |
   406	| Q9 | Cross-tenant lifecycle handling — what if a candidate placed at Tenant A's client interviews at Tenant B 6 weeks later? Bullhorn has separate tenant slugs; no cross-tenant leak. But operator visibility? | v1.0: strict tenant isolation (no cross-tenant data visibility). v1.1+: separate agent for tenant-network-graph if commercial demand. |
   407	| Q10 | 90-day check-in (event 12) — relationship-building tone. Should Concierge also surface "anyone in your network looking?" referral request? | Founder review with first pilot consultant + tenant brand voice. Recommend: opt-in via tenant config. |
   408	
   409	### Gotchas (carried forward from ULTRAPLAN A6 line 569-570)
   410	
   411	1. **Lifecycle event detection from Bullhorn is the unreliable bit.** Bullhorn's webhook coverage is patchy; polling fallbacks are required. Step 1 polling at 5-min cycle + anti-duplicate guard at Step 2 is the architecture.
   412	2. **Voice quality on rejections is the hardest test case.** Position-3 threshold (≥0.82) + sensitive-event escalation routing (Step 6). Get this wrong and it costs the tenant a candidate relationship.
   413	3. **Comms-template library is per-tenant, per-event-type, per-recipient-role.** 24+ templates per tenant minimum. Authoring effort is significant; consider this in pilot onboarding scoping.
   414	4. **Microsoft Graph vs Gmail per-tenant** — each tenant chooses based on their existing email stack. v1.0 supports both; v1.1+ may add agent-identity email adapter (deferred).
   415	
   416	---
   417	
   418	## §10 — When this document ratifies
   419	
   420	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   421	
   422	Status flips Proposed → Accepted when:
   423	- Codex Round 4 Phase 2 ratifies
   424	- **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes the documented deviation from ULTRAPLAN A6 line 566 wording. ADR drafted at `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` (Day 20 W4 bilateral pass); ratifies via `.codex/ratification/review-architecture-decision.md` skill. Until RATIFIED, agent.md's Gate B framing of the 30-min SLA is documented disposition only.
   425	- **Founder Decision D1 RESOLVED** (Q1 above) — without this, Concierge build cannot start
   426	- Founder approves §9 Q2 (lifecycle taxonomy) + Q3 (send window) + Q4 (rejection routing) + Q5 (template authoring UX) + Q6 (Gate B UX)
   427	- Q7-Q9 documented decisions captured
   428	
   429	Status flips Accepted → In Force when:
   430	- W10-13 build slice produces all 5 sibling bundle files + 5 fixtures (broader fixture coverage warranted by XL complexity)
   431	- First production lifecycle webhook processed end-to-end against migration-test tenant
   432	- 12-event taxonomy validated against first pilot tenant's actual Bullhorn state-change patterns
   433	- Voice classifier microservice production-ready (per-tenant; position-3 ≥0.82 sustained)
   434	- Gate B feedback loop operational (consultant approve/edit distinguishable)
   435	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   436	
   437	Until then: this document is a forward-looking scaffold. Concierge is the most complex v1.0 agent; its ratification cycles may surface architectural decisions not visible at scaffold stage. Founder review at each iteration is expected.
   438	
   439	*End of Concierge agent.md draft.*

exec
/bin/zsh -lc 'rg -n "decision_log|phase|payload|detection_delay_seconds|concierge_sla_threshold|tenant_adapters.config" docs/verticals/recruitment docs/decisions/autosend-safety-policy.md agents/recruitment/concierge/agent.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:17:--   - decision_log.payload extension is DEFERRED to a future W4-polish ADR
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:19:--     does NOT extend the payload shape; the W4 ADR will add both the new
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:20:--     payload key and its enforcement (CHECK constraint or trigger).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:77:  raw_payload        JSONB,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:130:  raw_payload              JSONB,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:383:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:390:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:416:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:458:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:460:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:463:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:75:        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
docs/verticals/recruitment/vertical-schema.yaml:149:      - PII handling — fields email, phone, mobile, location are PII per UK GDPR Art. 4(1). Autosend-policy.md §7 `payload_preview` rules apply.
docs/verticals/recruitment/vertical-schema.yaml:365:        notes: Free-text JD body. Subject to autosend-policy.md §7 — payload_preview must summarise, not embed full JD.
docs/verticals/recruitment/vertical-schema.yaml:629:    description: Candidates engage with multiple contacts during the interview process (panel interviews, multiple stakeholders). Captures the relationship for autosend-policy `payload_preview` addressee verification.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:71:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:72:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:76:-- tenant_adapters config validation trigger.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 3 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:348:  #   agent + which fields were touched in decision_log payload; reviewers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:358:  # decision_log row records who wrote. Entity-level RLS enforces TENANT
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:625:      raw_payload: {type: object, required: false, source: Open Banking provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific. Full Open Banking response cached for audit; pseudonymized at year 7"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:632:      description, raw_payload). Aligned with Q4 v0_3_default. The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:663:      raw_payload: {type: object, required: false, source: Accounting provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific (Xero / QuickBooks / Sage). Full provider response cached for audit"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:738:# §4 — tenant_adapters.config new keys (3 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:741:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:742:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:745:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:825:# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:828:decision_log_payload_extension:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:829:  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:832:  # that ships alongside Tier 2 activation. v0.3 introducing the payload
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:841:      separate post-launch quality metric outside Gate A. The payload key,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:846:      payload shape to avoid declaring schema without enforcement.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:880:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:920:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:955:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:967:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:985:  per_claim_confidence_distribution payload key originally planned for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:987:  §5 of this supplement); v0.3 is silent on payload schema extensions.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1005:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:23:--   - RLS policies on entities + entity_links + decision_log already in place
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:173:-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
agents/recruitment/concierge/agent.md:102:Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).
agents/recruitment/concierge/agent.md:127:   → mode=webhook: parse Bullhorn payload → resolve entity + state transition
agents/recruitment/concierge/agent.md:129:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:138:   → query decision_log for prior `concierge_email_draft` row for same
agents/recruitment/concierge/agent.md:139:     (candidate_id, payload.event_type) in last 24h with phase IN
agents/recruitment/concierge/agent.md:153:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
agents/recruitment/concierge/agent.md:205:     "<candidate_bullhorn_id>:<event_type>", payload_hash, payload_preview);
agents/recruitment/concierge/agent.md:232:      "candidate:<bullhorn_id>:<event_type>", payload_hash,
agents/recruitment/concierge/agent.md:239:      "candidate:<bullhorn_id>", payload_hash, payload_preview)
agents/recruitment/concierge/agent.md:255:      payload_hash, "event=<type> elapsed=<seconds>")
agents/recruitment/concierge/agent.md:305:| `ESC_BULLHORN_AUTH` | OAuth refresh fails (payload.failure_type='refresh_failed' or 'revoked_401' covers the 6+ consecutive failure case) | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:306:| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:400:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
agents/recruitment/concierge/agent.md:404:| Q7 | Anti-duplicate guard window — 24h proposed in Step 2. Edge case: webhook + poll cycle both fire same event within 5 min → second skipped. What if first failed silently? | Anti-duplicate also checks decision_log for `phase='action'` not just `phase='trigger'` — if first didn't send, second can attempt. |
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:21:**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).
docs/decisions/autosend-safety-policy.md:32:- Read-only IFOS internal queries (entities, decision_log reads via context-assembly API)
docs/decisions/autosend-safety-policy.md:49:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
docs/decisions/autosend-safety-policy.md:55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:67:Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:145:#   $3 payload_hash  (SHA-256 hex of the action payload)
docs/decisions/autosend-safety-policy.md:146:#   $4 payload_preview (human-readable summary, <=500 chars, NO raw PII)
docs/decisions/autosend-safety-policy.md:150:  local payload_hash="$3"
docs/decisions/autosend-safety-policy.md:151:  local payload_preview="$4"
docs/decisions/autosend-safety-policy.md:160:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
docs/decisions/autosend-safety-policy.md:161:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
docs/decisions/autosend-safety-policy.md:167:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:168:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:175:      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:179:      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:181:        autosend_spot_check_enqueue "$action_type" "$target" "$payload_hash" "$payload_preview" "$tenant_slug"
docs/decisions/autosend-safety-policy.md:186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
docs/decisions/autosend-safety-policy.md:187:      autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW "$action_type" "$target" "$payload_hash" "$payload_preview"
docs/decisions/autosend-safety-policy.md:189:      autosend_await_approval "$action_type" "$target" "$payload_hash"
docs/decisions/autosend-safety-policy.md:193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:194:      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:200:      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:235:Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.
docs/decisions/autosend-safety-policy.md:241:**Payload (JSONB into `decision_log.payload`):**
docs/decisions/autosend-safety-policy.md:247:  "payload_hash": "<SHA-256 hex>",
docs/decisions/autosend-safety-policy.md:248:  "payload_preview": "<human summary, <=500 chars, NO raw PII>",
docs/decisions/autosend-safety-policy.md:258:1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
docs/decisions/autosend-safety-policy.md:262:5. On resolution, `decision_log` row is **appended** (not modified — append-only) with `phase='action'`, `payload.approval_status='approved'|'rejected'|'escalated'` and `payload.approval_resolution_at`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:290:  "payload_hash": "<SHA-256 hex>",
docs/decisions/autosend-safety-policy.md:291:  "payload_preview": "<human summary, <=500 chars>",
docs/decisions/autosend-safety-policy.md:300:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`
docs/decisions/autosend-safety-policy.md:328:  "payload_hash": "<SHA-256 hex>",
docs/decisions/autosend-safety-policy.md:329:  "payload_preview": "<human summary>",
docs/decisions/autosend-safety-policy.md:338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:355:| `decision_log` table unreachable (Postgres down, RLS context unset, network partition) | INSERT raises error | **Hard blocking error**; agent halts entirely with non-zero exit; no actions taken at all | Postgres restored OR session restarted with valid context; agent resumes from last checkpoint |
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:364:**Every governed action emits exactly one `decision_log` row** at execution time. The append-only enforcement (Postgres grants on `decision_log` are SELECT + INSERT only for `ifos_app` per Day 4 §6.3) means rows cannot be modified or deleted post-write.
docs/decisions/autosend-safety-policy.md:366:### Row schema (within existing `decision_log` table from Day 4)
docs/decisions/autosend-safety-policy.md:369:-- decision_log columns (Day 4 §6.3):
docs/decisions/autosend-safety-policy.md:373:--   phase TEXT CHECK IN ('trigger','output','action','gating_failed','agent_handoff')
docs/decisions/autosend-safety-policy.md:376:--   payload JSONB
docs/decisions/autosend-safety-policy.md:380:--   phase = 'action'         when allowed (green/yellow/orange-approved)
docs/decisions/autosend-safety-policy.md:381:--   phase = 'gating_failed'  when blocked (red/fail-safe-red/orange-rejected/orange-timeout-rejected)
docs/decisions/autosend-safety-policy.md:382:--   payload structure:
docs/decisions/autosend-safety-policy.md:387:--     "payload_hash": "<SHA-256 hex>",
docs/decisions/autosend-safety-policy.md:388:--     "payload_preview": "<<=500 chars, NO raw PII>",
docs/decisions/autosend-safety-policy.md:402:1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
docs/decisions/autosend-safety-policy.md:404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
docs/decisions/autosend-safety-policy.md:406:### Privacy of payload
docs/decisions/autosend-safety-policy.md:408:`payload_preview` is **explicitly required to exclude raw PII**. It is a human-readable summary that:
docs/decisions/autosend-safety-policy.md:414:Full message content lives in the originating system (Bullhorn, Gmail, Twilio). Audit references the system's own audit log (e.g., Bullhorn note ID) via `payload.target`.
docs/decisions/autosend-safety-policy.md:418:`decision_log` rows are retained **indefinitely** for v1.0. v1.1+ may introduce retention policies (e.g., delete rows older than 7 years per UK statutory retention norms).
docs/decisions/autosend-safety-policy.md:470:Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.
docs/decisions/autosend-safety-policy.md:485:### v1.1 phases in
docs/decisions/autosend-safety-policy.md:491:### v1.2+ phases in
docs/decisions/autosend-safety-policy.md:513:recorded in the decision_log table by reference to the policy git SHA
docs/decisions/autosend-safety-policy.md:514:(decision_log.payload.policy_version_sha), is the authoritative record
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:537:  (b) failure of the policy lookup mechanism (decision_log fail-safe-red
docs/decisions/autosend-safety-policy.md:544:The decision_log table within IFOS's Postgres instance, isolated to
docs/decisions/autosend-safety-policy.md:549:decision_log timestamps, payload_hash, and policy_version_sha.
docs/decisions/autosend-safety-policy.md:554:of docs/decisions/autosend-safety-policy.md in the decision_log row's
docs/decisions/autosend-safety-policy.md:555:payload.policy_version_sha field. Material changes to tier classification
docs/decisions/autosend-safety-policy.md:586:5. **PII liability for `payload_preview` formatting.** If `payload_preview` accidentally leaks PII into `decision_log`, that's a Provider liability event. Tooling: linter on `payload_preview` strings at hook-helpers.sh layer.
docs/decisions/autosend-safety-policy.md:611:- **Whether decision_log captures both allowed and blocked sends:** Yes, §7.
docs/decisions/autosend-safety-policy.md:632:**For Week 1-2.** The `_shared/voice-loader.sh` + `hook-helpers.sh` Week-1 prerequisite (per ADR-002 §"For Week 1 work" + ADR-003 Decision 3) now has its `hh_decision_action` specification. Implementation work is well-defined: §4 pseudocode + §5 escalation payloads + §7 audit row schema.
docs/decisions/autosend-safety-policy.md:644:3. ESC code payload structures per §5
docs/decisions/autosend-safety-policy.md:657:- v1.0 ship date: tier coverage is green + red. Yellow + orange phase in v1.1.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days

exec
/bin/zsh -lc 'rg -n "''^## 10|''^### 10|§10'"\\.3|§10\\.5|What never goes|ratifiable artefacts|in-band\" docs .codex .agents 2>/dev/null" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:5:**Codex rounds completed:** Round 4 (initial REJECTED, 4 issues) + Round 5 (remediation REJECTED, 5 issues including 2 re-raises and 3 new findings) — **hard ceiling per master brief §10.3 step 5 reached**.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:17:Per master brief §10.3 step 5: **≤2 round-trips max per artefact**. Round 5 was the second round-trip. **Hard ceiling reached.** Founder arbitration required to close the artefact.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:165:**Empirical confirmation of the pattern documented in master brief §10.3 step 5:** Codex finds new issues at each round. Hard ceiling of ≤2 round-trips is the right structural protocol. Further autonomous Claude remediation passes will continue surfacing new issues that may not have been visible at earlier rounds (each fix changes the document, exposing different inconsistencies).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:186:Despite master brief §10.3 step 5 protocol saying founder review after Round 5, Round 6 attempted with all Round-5 issues remediated (commit `aaa376d`). Round 6 returned REJECTED with **4 new findings**, none of which appeared in any prior round:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:202:**21 unique issues across 4 rounds, ZERO repeats.** Master brief §10.3 step 5 hard ceiling exists for exactly this reason — each remediation pass surfaces issues that weren't visible at prior rounds because the document changes.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:229:**Round 7 findings 1 + 2 + 3 + 4 are all CAUSED BY my Round 6 fixes.** When I fixed one section, I introduced inconsistencies between it and other sections referencing the same concept. This is the perfect illustration of why master brief §10.3 step 5 caps round-trips: each fix changes the document, and the changed document has new inconsistencies between the fixed-section and the related-but-unfixed sections.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:235:Master brief §10.3 step 5 cap = 2 round-trips. The hook has requested 5 rounds. Each beyond round 2 has produced 4-5 new findings. The protocol is right; the hook contradicts it.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:326:**Phase 1 + Phase 2 + Phase 3 (Round 8 + Cat-α inline fixes) constitute the documented "Path A — bilateral session per master brief protocol" outcome.** No further autonomous remediation rounds will be attempted per the master brief §10.3 step 5 hard ceiling and founder's "no more rounds" authorization.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:378:**Cumulative empirical (10 rounds total):** ~75 unique findings catalogued; ~7 closed via Cat-α + Cat-γ + Cat-δ inline this session; convergence rate ~10% per round. The pattern documented in master brief §10.3 step 5 holds.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:383:1. Gate A per-claim vs per-section: STILL flagged despite Cat-1 hybrid disposition; this is a Codex–founder disagreement, not relitigation of Cat-1 (founder's hybrid stance documented but Codex doesn't accept the bilateral-disposition framing as an in-band acceptance of weakening). **Disposition: founder-decision; flagged as Cat-ζ "Cat-1 framing not auto-accepted by Codex".**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:398:**Cat-ζ — Codex does not accept bilateral-disposition framings as in-band Gate A acceptances.**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:409:### Decision — stop Codex looping per master brief §10.3 step 5
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:411:The pattern (Round 4 → Round 9; 10 rounds; 75+ unique findings; ~10% net convergence per round) empirically confirms master brief §10.3 step 5. Each remediation pass surfaces new issues at roughly the same rate it closes old ones — because the document keeps changing.
docs/specs/ULTRAPLAN.md:811:## 10. The risk register
docs/build-brief/00-MASTER-BRIEF.md:704:## 10. The Codex ratification loop — second-pair every critical decision
docs/build-brief/00-MASTER-BRIEF.md:708:### 10.1 Why this loop matters
docs/build-brief/00-MASTER-BRIEF.md:716:### 10.2 Setup (Day 0–1)
docs/build-brief/00-MASTER-BRIEF.md:732:### 10.3 The working loop
docs/build-brief/00-MASTER-BRIEF.md:742:### 10.4 What never goes through ratification
docs/build-brief/00-MASTER-BRIEF.md:750:### 10.5 What ALWAYS goes through ratification
docs/build-brief/00-MASTER-BRIEF.md:762:### 10.6 The ratification timeline
docs/build-brief/00-MASTER-BRIEF.md:831:| "Let me skip the Codex ratification — it's a small change..." | §10.5 |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:7:**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:13:ULTRAPLAN §8.1 A1 line 496 (pre-amendment wording — before this ADR's in-band edit landed in commit `aed9d3b`):
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:76:This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
.agents/current-priorities.md:49:**Empirical convergence pattern (consistent across 4 deep-iterated artefacts):** architectural substance closes 5-10 rounds; last-mile cross-reference sync stays at ~3 findings/round steady-state. Master brief §10.3 step 5 hard-ceiling empirically correct.
.agents/current-priorities.md:57:- [x] **ADR-006 Diagnostic Gate A hybrid** — Accepted founder-arbitrated at commit `6d2d43e`; ULTRAPLAN line 496 in-band amendment at `aed9d3b`.
.agents/current-priorities.md:316:**Codex Round 4 ratification queue:** 11 items prepared in manifest §1.10. Phase 1 (6 items) ready when founder runs Step 7; Phase 2 (5 items) ready when founder runs Step 13. Hard ceiling per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 max).
.agents/current-priorities.md:702:- **15 fabricated "master brief §10.4" references** across 5 files. Master brief §10.4 is "What never goes through ratification" (Codex exclusion list), not a Hetzner location or cost-target section. Root cause: Day-4 runbook §1.4 invented the citation; propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1), RISK-REGISTER (2), current-priorities (1) by citation transitivity rather than re-verification against master brief.
docs/specs/PRODUCT-SPEC.md:518:## 10. The single sentence each agent earns the right to be in this suite
docs/RISK-REGISTER.md:23:| 7 | **Master-brief-drift-accumulation** — eight ADR-driven edits + one Day-4 Postgres-rename + multiple Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all nine edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Codex ratifies the commit alongside the ten+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 + `bullhorn-integration-path.md` + `sequencing-target.md` + `brain-ui-scope.md` + Day 4 runbook §0.1. **Updated Day 4 (2026-05-17):** edit count rose from 8 to 9 with Day-4 Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations" — verified from Day-4 execution against NBG1 because FSN1 was unavailable at provisioning time). **Citation audit 2026-05-18:** earlier drafts also cited master brief §10.4 as a Hetzner/cost-target section; verified §10.4 is the Codex exclusion list ("What never goes through ratification") and contains no Hetzner or cost-target content. Edit 9 scope corrected to line 477 only. |
docs/specs/_archive-build-handoff.md:457:## 10. The single command that starts everything
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:30:Per master brief §10.5 + Rule 4 (Quality gates before features), an upstream-spec amendment requires either (a) revert the scaffold to per-draft hard-fail, or (b) author an ADR ratifying the deviation. This ADR is option (b).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:71:**ULTRAPLAN §8.1 A6 line 566 is amended in-band per the master brief §10.3 step 4 pattern** (analogue of the in-band amendment ADR-006 made at line 496):
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:96:4. No code or schema changes required at scaffold stage — `agent.md` already reflects the Gate B framing. Update is to ULTRAPLAN line 566 (in-band amendment) + Concierge §10 (add ADR blocker) + this ADR (new artefact).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:100:### In-band ULTRAPLAN amendment (per master brief §10.3 step 4)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:136:- Master brief §1 Rule 4 (Quality gates before features) + §10.5 (ADRs are ratifiable artefacts)
docs/_supplementary/PRD-autonomous-agent.md:1238:## 10. Avatar Generation (HeyGen)
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:30:No edit to the agent.md or validate.sh. R17 dispositions cover the other 4 findings; this disagreement is recorded per master brief §10.3 step 4 ("Claude Code reads Codex's feedback; incorporates it or counter-argues explicitly in `docs/decisions/codex-disagreement-{date}.md` (the disagreement IS the signal — write it down, don't dissolve it)").
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:32:If Codex repeats this same finding at R18 against the unchanged text, escalate to founder per §10.3 step 5.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:335:- Per-agent Codex-ratification timing within each build slot — every `agent.md` ratifies before merge per master brief §10.5; specific ratification cadence emerges from each agent's PR cycle.
docs/runbooks/day-4-provisioning.md:56:**Master-brief correction:** add to the atomic-correction commit manifest (currently 8 edits at end of Week 0). Proposed Edit 9: master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations"; flag UK-residency as a commercial-conversation gate. (Earlier drafts also referenced "§10.4" as a separate location-naming surface; verified that §10.4 — "What never goes through ratification" — contains no Hetzner or cost-target content. §10.4 component dropped.)
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:71:- Codex-ratification list (master brief §10.5) needs an entry: bus-dispatcher mechanism change = master brief edit = always-ratify.
docs/_archive-build-pack/04-DATA-MODEL.md:426:## 10. Open data-model decisions
docs/_supplementary/build-plan-original.md:709:## 10. Caption Writer
docs/architecture/agent-bundle-renderer-design.md:43:| `agent.md` (line 552) | Output contract first; then workflow, gates, escalation. Master brief §1 Rule 1: "Every agent ships with its output contract written first, as a one-paragraph screenshot description." | the renderer (synthesises into `CLAUDE.md` per §2.1); humans for code review | **Static** — founder writes once; iterated per Codex ratification (master brief §10.5 names every new `agent.md` as always-ratify) |
docs/architecture/agent-bundle-renderer-design.md:636:**Recovery:** stderr lists the failed validation path (e.g. `properties.nurture_cadence.post_interview_chase_hours: expected integer, got string`). Founder edits `/vault/<tenant>/_config.yaml` or the `config.schema.json` source (rare; schema edits go through Codex ratification per master brief §10.5). Re-runs render.
docs/decisions/ADR-004-renderer-implementation-deviations.md:18:The three deviations are individually small. The reason this ADR exists rather than three inline `errata` notes in ADR-003 is master brief §10.5 ("Always-ratify list"): renderer architectural decisions go through Codex review, and a single coherent ADR is the audit-trail-friendly path. Reading ADR-003 + ADR-004 together gives the full ratified renderer surface.
docs/runbooks/operational-hygiene-protocol.md:266:**Verified ground truth:** master brief §10.4 is "What never goes through ratification" — a 5-bullet list of Codex exclusions (comment-only changes, test fixture additions, documentation typos, build/deps version bumps, anything inside `.agents/`). It contains no Hetzner reference and no cost-target reference.
docs/decisions/2026-05-18-codex-ratification-manifest.md:111:Round 4 scheduled across Week 3 (Days 14-20) per `docs/operations/goal-week-3-polish-and-scaffold.md` Steps 7 (Diagnostic-only, Day 15) + 13 (full run, Day 20). Per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 remediation max).
docs/decisions/2026-05-18-codex-ratification-manifest.md:153:**Hard ceiling reached** per master brief §10.3 step 5. Single founder decision (approve the 5-category disposition) unlocks all 6 ratifications via a single Round-5 mechanical-remediation pass.
docs/decisions/2026-05-18-codex-ratification-manifest.md:205:## §2 — Ratification protocol per master brief §10.3
docs/decisions/2026-05-18-codex-ratification-manifest.md:207:Verbatim from master brief §10.3 (post-Edit 7 path correction):
docs/decisions/2026-05-18-codex-ratification-manifest.md:246:| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
docs/decisions/2026-05-18-codex-ratification-manifest.md:247:| **Disagreement artefacts** | If Codex REJECTS or disagrees with any artefact | `docs/decisions/codex-disagreement-<date>.md` per master brief §10.3 step 4. Founder decides on escalations. |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:193:## 10. Integrations expected at GA
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/_archive-build-pack/03-ARCHITECTURE.md:510:## 10. What this architecture intentionally does NOT do
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:268:## 10. The Codex ↔ Claude Code loop
docs/operations/codex-ratification-execution-plan.md:14:- **Claude tends to over-elaborate on architecture; Codex is more conservative.** I produce ratifiable artefacts; Codex reads them with fresh eyes.
docs/operations/codex-ratification-execution-plan.md:274:    'round_trip', $5,                     -- 1 or 2 per §10.3
docs/operations/codex-ratification-execution-plan.md:317:Per master brief §10.3 step 5:
docs/_supplementary/strategic-plan.md:432:## 10. Risks and reality checks
docs/_supplementary/strategic-plan.md:436:### 10.1 Technical risks
docs/_supplementary/strategic-plan.md:443:### 10.2 Business risks
docs/_supplementary/strategic-plan.md:450:### 10.3 The thing that will actually kill this
docs/operations/codex-round-2-autonomous-prompt.md:91:recursive ratification per master brief §10.5. Decide whether Claude's 
docs/operations/codex-round-2-autonomous-prompt.md:196:  Disagreement docs (recursive ratification per master brief §10.5):
docs/operations/codex-round-2-autonomous-prompt.md:320:**If SUMMARY.md shows unexpected REJECTED items:** Codex caught something. Read the per-artefact output file. Decide whether to incorporate or counter-argue. Then Round 3 (~limited; ≤2 round-trips per master brief §10.3).
docs/operations/codex-ratification-guide.md:373:The disagreement doc itself becomes a ratifiable artefact in a future round (master brief §10.5 recursive ratification). That's by design — the disagreement IS the signal.
docs/operations/w4-day-20-founder-runbook.md:27:**Why:** Per master brief §10.5, "every Postgres migration touching tenant
docs/operations/w4-day-20-founder-runbook.md:31:read of §10.5 (it executes DDL against live data).
docs/operations/codex-round-2-remediation-prompt.md:36:  4. docs/build-brief/00-MASTER-BRIEF.md §10.3 (≤2 round-trip ceiling —
docs/operations/codex-round-2-remediation-prompt.md:407:Per master brief §10.3 step 5: Round 3 is the LAST automated round.
docs/operations/codex-round-2-remediation-prompt.md:433:     Per master brief §10.3, this is the last automated round. Confirm
docs/operations/codex-round-2-remediation-prompt.md:525:  Round 3 ratification (≤2 round-trips per master brief §10.3): 10 items
docs/operations/codex-round-2-remediation-prompt.md:634:**Round 3 ratification:** 10 corrected items re-ratified against appropriate skills. Hard-ceiling enforced per master brief §10.3 step 5.
docs/operations/goal-week-3-polish-and-scaffold.md:20:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (boundaries) + §6 Day 4-7 (foundation state) + §8 (build sequence) + §10.5 (always-ratify artefacts)
docs/operations/goal-week-3-polish-and-scaffold.md:94:| Diagnostic Codex ratification | Master brief §10.5 always-ratify |
docs/operations/goal-week-3-polish-and-scaffold.md:450:Triage protocol (master brief §10.3 step 5 hard ceiling: ≤2 round-trips):
docs/operations/goal-week-3-polish-and-scaffold.md:502:| Codex Round 4 returns >2 REJECTED on any single artefact | Founder review; do NOT remediate-and-resubmit beyond hard ceiling (per master brief §10.3 step 5); write founder-decision doc; defer |
docs/operations/goal-week-3-polish-and-scaffold.md:540:Per master brief §10 + §10.3 step 5 hard ceiling + Day-11 Round-2/3 pattern.
docs/operations/goal-week-3-polish-and-scaffold.md:573:- **Mechanical REJECTIONS (citation drift, line-anchor error, formatting):** Round 4 remediation prompt; expect Round 5 final. Hard ceiling per master brief §10.3 step 5: 2 round-trips MAX. Round 5 RATIFIED → close. Round 5 STILL REJECTED → founder review.
docs/operations/codex-round-2-handoff.md:104:| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | `review-architecture-decision` | **Recursive ratification per master brief §10.5.** Codex either RATIFIES the disagreement (D5 was correct) OR REJECTS (insists on strict skill). Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:200:ratification per master brief §10.5. Decide whether Claude's counter-argument
docs/operations/codex-round-2-handoff.md:292:Hard ceiling: 2 round-trips (master brief §10.3 step 5). After Round 2, no Round 3 — escalate to founder for explicit decision.
docs/operations/codex-round-2-handoff.md:332:Any Round-2 REJECTED items get their own row in the manifest queue updated to "REJECTED→ROUND-3-pending OR founder-escalated". Per §10.3 master brief: no Round 3 until founder decides.
docs/operations/codex-round-2-handoff.md:406:Manifest queue position: this protocol document itself joins the queue as a Round-3 candidate (recursive ratification per master brief §10.5).

exec
/bin/zsh -lc 'git rev-parse --show-toplevel && git show --stat --oneline --decorate f79c018 --' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
/Users/madsadmin/code/CortexOS
f79c018 update(concierge-r3-postv03): yellow draft tier + Step 7 decision-log + ULTRAPLAN line removed
 agents/recruitment/concierge/agent.md | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

exec
/bin/zsh -lc "find logs/codex-ratification/20260524T174513Z-13185 -maxdepth 2 -type f -print 2>/dev/null | sort | xargs -I{} sh -c 'printf \"%s\\n\" \""'$1"; rg -n "30-minute|Finding 3|ADR|Accepted criteria|Line 16|206-212|276|417-421" "$1"'"' sh {}" in /Users/madsadmin/code/CortexOS
 exited 1 in 0ms:
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md
35:1. **Output before architecture** — Every agent ships with its output contract written first as a one-paragraph screenshot description. Does this artefact name what it produces before what it is built from? For non-agent artefacts (ADRs, schemas, runbooks): does the artefact name its goal/output before its mechanism?
112:- `review-architecture-decision.md` — for ADRs, decision docs, design docs
158:**Distinction from review-architecture-decision:** agent.md files are NOT architecture-decision documents. They follow the ADR-003 v2 bundle pattern (6 files + 3 fixtures) and have their own structural requirements documented below. Do NOT REJECT an agent.md for missing Context/Decision/Consequences sections — those belong in ADRs (which live at `docs/decisions/ADR-*.md`).
162:## §1 — agent.md required-section structure (per ADR-003 + Diagnostic precedent)
321:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
581:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
851:docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
948:docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
960:docs/decisions/autosend-safety-policy.md:604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
964:docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
1001:docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
1030:docs/architecture/agent-bundle-renderer-design.md:804:**Proposed:** add a one-paragraph footnote at the end of §8 (before §8.1): "The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly. The renderer (`packages/agent-renderer/`, per ADR-003) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant)."
1121:docs/decisions/2026-05-18-codex-ratification-manifest.md:268:| 5 | §8 renderer footnote (before §8.1) | ADR-003 Edit C | ✓ verbatim |
1122:docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
1123:docs/decisions/ADR-003-agent-bundle-renderer.md:17:The design document (`docs/architecture/agent-bundle-renderer-design.md`) specified the renderer across five sections: source vs target layout (§1), the 12-row file mapping + R2 commitment + Concierge worked example (§2), six concrete mechanism decisions including TypeScript Node at `packages/agent-renderer/` (§3.1), manual developer invocation (§3.2), Option γ for `_shared/` origination (§3.3.3), and overwrite-no-merge re-render policy (§3.4), seven failure modes with exit codes (§4), and integration with the broader build (§5). 22 spec gaps surfaced and bucketed. This ADR ratifies the design's recommendations.
1124:docs/decisions/ADR-003-agent-bundle-renderer.md:54:The Concierge worked example in design §2.3 demonstrates end-to-end render: source bundle layout, CLAUDE.md preamble draft (resolves spec gap §2.1-A), materialised `config.json`, synthesised `.env`, hook files verbatim, `_shared/` symlink resolution.
1125:docs/decisions/ADR-003-agent-bundle-renderer.md:133:**Current** (master brief §8 lines 545-568): bundle file list followed immediately by §8.1 ("The three v2 changes"). No footnote between §8 and §8.1.
1126:docs/decisions/ADR-003-agent-bundle-renderer.md:135:**Proposed:** insert a one-paragraph footnote at the end of §8 (before §8.1):
1127:docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
1128:docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:25:**Codex says:** "Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires 'no claims unsupported by source data.' This lowers a stated Gate A constraint."
1195:docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
1252:docs/architecture/architecture-cohesion-review.md:147:| G1 | **Concierge "voice corpus refresh" cadence is undefined.** When does a tenant re-index? Operator triggers? Scheduled cron? Re-index on N% recent_edit drift? | Medium (Concierge W10 dependency) | New ADR at Concierge build time OR addendum to v0.2 supplement at v1.0 schema close. Owner: Claude Code, trigger: Week-9. |
1255:docs/architecture/architecture-cohesion-review.md:233:| R7 | G1: Voice corpus refresh cadence | Medium | New ADR-006 at Concierge build OR addendum to v0.2 supplement at v1.0 schema close | Claude Code | Week-9 (pre-Concierge) |
1257:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:13:ULTRAPLAN.md §8.1 specifies the v1.0 build sequence:
1258:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:24:| 10-13 | Concierge |
1259:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
1260:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
1261:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
1262:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
1263:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
1264:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:76:- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
1265:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
1266:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
1267:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
1268:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:106:- ULTRAPLAN §8.1 line 753-755 (Week-4 milestone definition)
1269:docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:5:**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
1270:docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:13:ULTRAPLAN §8.1 A1 line 496 (pre-amendment wording — before this ADR's in-band edit landed in commit `aed9d3b`):
1271:docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:64:`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):
1272:docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:76:This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
1273:docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
1274:docs/decisions/ADR-004-renderer-implementation-deviations.md:68:- ADR-003 §2.3 worked-Concierge-example output diagram says `_shared/` lives at `orgs/acme/agents/_shared/` — that's correct, the bug is only in the symlink-target text. Diagram is right; symlink string is wrong.
1276:docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:21:The subsequent design pass (`docs/architecture/second-brain-design.md`) went further. Q1.4 found that **no IFOS agent calls `kb-*`** — the IFOS Agent Bundle v2 (master brief §8.1) has no `MEMORY.md`, no heartbeat memory file, and uses Postgres `decision_log` for the persistence role cortextOS's KB fills. The §3.4 seam was designed to shadow calls our agents don't make. Q3 evaluated three interface options against the post-design constraints (§3.2 rubric) and recommended Option α — a parallel `packages/brain/bus-overrides/wiki-*.sh` surface with no shadowing of cortextOS's bus.
1277:docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
1294:docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
1295:docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:46:| **A. Accept the floor** | Leave `pollInterval` at the 1000ms default. Rewrite Ultraplan §3.2's "four-agent pipelines complete in seconds" to "four-agent pipelines complete in 3-5 seconds end-to-end" and remove any "sub-second handoff" framing from the closing-demo deck | Zero engineering | Honest signal; Concierge's "30-min lifecycle event → drafted comms" SLA is unaffected (3-5s is rounding error against 30 minutes); Brief Decoder's "90-min brief-to-shortlist" is also unaffected. Only sales narrative changes. |
1296:docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:52:2. The user-visible SLAs (Concierge 30-min lifecycle event, Brief Decoder 90-min shortlist, Triage 60-second response) all have ≥30× headroom against a 3-5 second pipeline floor. The pipeline-latency claim is sales narrative, not product SLA.
1341:docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
1375:docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
1389:docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
1390:docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
1466:docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
1475:docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
1497:docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
1498:docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
1501:docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
1529:docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
1534:docs/operations/goal-week-3-polish-and-scaffold.md:52:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
1552:docs/operations/goal-week-3-polish-and-scaffold.md:365:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
1763:docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
1764:docs/RISK-REGISTER.md:65:- 2026-05-20 (Day 9 evening) — **Architecture + tenancy verification slice complete.** 3 commits (`5c3fa66` + `c4348aa` + this commit). 4 new artefacts: tenancy-invariants.md (Reference; 12 invariants T1-T12 single source of truth), run-tenancy-audit.sh (multi-tenant adversarial smoke), architecture-cohesion-review.md (8-artefact cohesion + 14 remediation items + 4-boundary adversarial walk), tenant-lifecycle.md (Provision/Operate/Suspend/Offboard/Migrate). All 4 master-brief §3 boundaries verified HOLD at current artefact set. 3 of 5 contradictions in the ratified artefact set RESOLVED via ADR-004 + Day-8 remediation; 1 RESOLVED via consolidation in tenancy-invariants.md; 1 OPEN pending Founder Decision D3 (PII retention). 8 implicit assumptions documented; 3 catastrophic-if-false verified empirically. No new risks added — cohesion review's 14 remediation items + lifecycle's 8 gaps are all variance bounded by existing risks (#5 renderer + #10 PII + others) or low-severity lazy specs. Foundation deemed sound for Diagnostic build conditional on founder-decision bundle (D1+D2+D3) + Codex Round 2 closure + live tenancy audit pass.
1765:docs/RISK-REGISTER.md:66:- 2026-05-20 (Day 8 evening) — **Codex ratification Round 1 complete + remediation landed.** 16 artefacts reviewed (Cluster A+B+C); 2 RATIFIED (ADR-004, brain-ui-scope); 14 REJECTED. Remediation commit `2b287d3` incorporates 13 of 14 rejections (Bucket 1 cosmetic + Bucket 2 ADR-004 back-propagation + Bucket 3 structural). 2 disagreement docs filed (`codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` + `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`). 5 founder decisions surfaced (D1-D5 in `2026-05-20-codex-round-1-founder-decisions.md`). **NEW Risk #10 candidate surfaced by Codex** (recent_edit raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation) — see Risk #10 below. Manifest queue updated with per-artefact Round-1 verdicts (`docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5). Round 2 expected to take 14 REJECTED → 0-2 REJECTED.
1777:agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 257; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 182-187 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 257-262; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
1805:agents/recruitment/scribe/agent.md:276:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
1910:docs/architecture/architecture-cohesion-review.md:147:| G1 | **Concierge "voice corpus refresh" cadence is undefined.** When does a tenant re-index? Operator triggers? Scheduled cron? Re-index on N% recent_edit drift? | Medium (Concierge W10 dependency) | New ADR at Concierge build time OR addendum to v0.2 supplement at v1.0 schema close. Owner: Claude Code, trigger: Week-9. |
1916:docs/architecture/architecture-cohesion-review.md:233:| R7 | G1: Voice corpus refresh cadence | Medium | New ADR-006 at Concierge build OR addendum to v0.2 supplement at v1.0 schema close | Claude Code | Week-9 (pre-Concierge) |
2059:agents/recruitment/sourcing-scout/agent.md:6:- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist; canonical Postgres-backed v1.0 DNC source per ADR-002.
2061:agents/recruitment/sourcing-scout/agent.md:20:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
2064:agents/recruitment/sourcing-scout/agent.md:255:- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
2068:agents/recruitment/sourcing-scout/agent.md:342:| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
2069:agents/recruitment/sourcing-scout/agent.md:363:| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
2117:docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
2137:docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:167:OR open a follow-on ADR if the decision warrants more substantive recording (e.g., ADR-005 for D1; ADR-006 for D2 + D3 bundle).
2198:docs/decisions/2026-05-18-codex-ratification-manifest.md:194:**Round-1 totals:** 16 reviewed | **2 RATIFIED** (ADR-004 + brain-ui-scope) | **14 REJECTED** | **13 of 14 incorporated** at commit `2b287d3` | **2 disagreement docs filed** | **5 founder decisions surfaced** (D1-D5).
2199:docs/decisions/ADR-004-renderer-implementation-deviations.md:68:- ADR-003 §2.3 worked-Concierge-example output diagram says `_shared/` lives at `orgs/acme/agents/_shared/` — that's correct, the bug is only in the symlink-target text. Diagram is right; symlink string is wrong.
2237:docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
2241:docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
2243:docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
2253:docs/decisions/ADR-003-agent-bundle-renderer.md:17:The design document (`docs/architecture/agent-bundle-renderer-design.md`) specified the renderer across five sections: source vs target layout (§1), the 12-row file mapping + R2 commitment + Concierge worked example (§2), six concrete mechanism decisions including TypeScript Node at `packages/agent-renderer/` (§3.1), manual developer invocation (§3.2), Option γ for `_shared/` origination (§3.3.3), and overwrite-no-merge re-render policy (§3.4), seven failure modes with exit codes (§4), and integration with the broader build (§5). 22 spec gaps surfaced and bucketed. This ADR ratifies the design's recommendations.
2254:docs/decisions/ADR-003-agent-bundle-renderer.md:54:The Concierge worked example in design §2.3 demonstrates end-to-end render: source bundle layout, CLAUDE.md preamble draft (resolves spec gap §2.1-A), materialised `config.json`, synthesised `.env`, hook files verbatim, `_shared/` symlink resolution.
2255:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:24:| 10-13 | Concierge |
2256:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
2257:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:76:- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
2258:docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
2259:docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:99:> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"
2260:docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:103:> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."
2261:docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
2262:docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:46:| **A. Accept the floor** | Leave `pollInterval` at the 1000ms default. Rewrite Ultraplan §3.2's "four-agent pipelines complete in seconds" to "four-agent pipelines complete in 3-5 seconds end-to-end" and remove any "sub-second handoff" framing from the closing-demo deck | Zero engineering | Honest signal; Concierge's "30-min lifecycle event → drafted comms" SLA is unaffected (3-5s is rounding error against 30 minutes); Brief Decoder's "90-min brief-to-shortlist" is also unaffected. Only sales narrative changes. |
2263:docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:52:2. The user-visible SLAs (Concierge 30-min lifecycle event, Brief Decoder 90-min shortlist, Triage 60-second response) all have ≥30× headroom against a 3-5 second pipeline floor. The pipeline-latency claim is sales narrative, not product SLA.
2347:docs/runbooks/day-4-provisioning.md:62:**ADR-002 Edit 3 + current-priorities.md (Open) state the corrected table list:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
2359:docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
2409:docs/build-brief/00-MASTER-BRIEF.md:470:- [ ] Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per ADR-002 Edit 3 + `docs/architecture/second-brain-design.md` §2.4.2).
2444:packages/mcp-connectors/companies-house/pnpm-lock.yaml:276:    resolution: {integrity: sha512-bc0FE9wWeC0WBm49IQMPSPILRocGTQt3j5KPCA8os6VprfuJ7KD+5PzESSrJ6GmPIPJK965ZJHTUlSA6GNYEhg==}
2458:agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
2489:agents/recruitment/concierge/agent.md:276:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
2680:   562	**The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly.** The renderer (`packages/agent-renderer/`, per `docs/decisions/ADR-003-agent-bundle-renderer.md` and `docs/architecture/agent-bundle-renderer-design.md`) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant). The `cortextos-ifos add-agent` command is **NOT** the IFOS path — it inherits 24 cortextOS template skills the IFOS bundle does not want.
2796:    16	> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
3056:   276	The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
3321:   110	- **Trigger:** Renderer exited non-zero. Mid-render atomic-rename per ADR-003 §3.3.4 means the prior agent dir at target is preserved (`.prev.<timestamp>/`) — no half-rendered state visible to daemon discovery
3326:   115	- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7
3406:   276	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
3535:3. The 30-minute SLA is weakened without a ratified status-flip blocker. Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria. Either keep the 30-minute SLA as Gate A, or add the Concierge-Gate-A ADR ratification as an explicit Accepted blocker.
3546:3. The 30-minute SLA is weakened without a ratified status-flip blocker. Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria. Either keep the 30-minute SLA as Gate A, or add the Concierge-Gate-A ADR ratification as an explicit Accepted blocker.
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.prompt.md
22:1. **Output before architecture** — Every agent ships with its output contract written first as a one-paragraph screenshot description. Does this artefact name what it produces before what it is built from? For non-agent artefacts (ADRs, schemas, runbooks): does the artefact name its goal/output before its mechanism?
99:- `review-architecture-decision.md` — for ADRs, decision docs, design docs
145:**Distinction from review-architecture-decision:** agent.md files are NOT architecture-decision documents. They follow the ADR-003 v2 bundle pattern (6 files + 3 fixtures) and have their own structural requirements documented below. Do NOT REJECT an agent.md for missing Context/Decision/Consequences sections — those belong in ADRs (which live at `docs/decisions/ADR-*.md`).
149:## §1 — agent.md required-section structure (per ADR-003 + Diagnostic precedent)
308:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
568:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.verdict.txt

codex
REJECTED

1. Missing ADR decision subheading. `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` has `## Decision` at line 53, but no required `Decision 1 — <terse summary>` subheading. ADR-specific skill §2 requires at least one explicit numbered decision subheading. Add `### Decision 1 — Move Concierge 30-minute SLA from Gate A hard-fail to Gate B leading metric`.

2. Missing alternatives considered section. Lines 30-31 name the broad options, but the ADR does not include the required ADR alternatives section with at least two alternatives named and rejected with reasons. The closest material is embedded in Context / “Why per-draft hard-fail is operationally problematic,” which does not satisfy the ADR shape requirement. Add `## Alternatives considered` with at least two rejected alternatives, e.g. keep per-draft Gate A hard-fail, remove the 30-minute SLA entirely, or measure occurrence-time instead of detection-time.

3. Missing status update line at end. The artefact ends at `## References` lines 129-136 and has no final status line. Type-specific §1 requires a status update line for all statuses, such as “Status: Proposed; awaits Codex ratification + founder Accept.” Add the required final line after References.

4. Master brief / ULTRAPLAN edit disposition is not honest. Lines 71 and 100-109 say ULTRAPLAN line 566 “is amended in-band” and provide a commit message, but live `docs/specs/ULTRAPLAN.md` line 566 still contains the original Gate A wording. The master-brief edit rule requires the edit to land in this commit, the next atomic-correction commit, or an explicit deferred queue. Either apply the ULTRAPLAN edit with this ADR, or mark it as explicitly deferred with owner/commit queue.

5. `payload.detection_delay_seconds` is introduced without the required payload-shape authority. Lines 69 and 119 reference `decision_log.payload.detection_delay_seconds`, while line 119 admits it is not in v0.3 schema and says `cycle.sh` records it as free-form JSONB. Type-specific §7 requires payload keys to be documented in autosend-safety-policy §7 before use. Remove the field from this ADR until v0.4 defines it, or add the payload-shape supplement before Concierge writes it.
tokens used
150,929
REJECTED

1. Missing ADR decision subheading. `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` has `## Decision` at line 53, but no required `Decision 1 — <terse summary>` subheading. ADR-specific skill §2 requires at least one explicit numbered decision subheading. Add `### Decision 1 — Move Concierge 30-minute SLA from Gate A hard-fail to Gate B leading metric`.

2. Missing alternatives considered section. Lines 30-31 name the broad options, but the ADR does not include the required ADR alternatives section with at least two alternatives named and rejected with reasons. The closest material is embedded in Context / “Why per-draft hard-fail is operationally problematic,” which does not satisfy the ADR shape requirement. Add `## Alternatives considered` with at least two rejected alternatives, e.g. keep per-draft Gate A hard-fail, remove the 30-minute SLA entirely, or measure occurrence-time instead of detection-time.

3. Missing status update line at end. The artefact ends at `## References` lines 129-136 and has no final status line. Type-specific §1 requires a status update line for all statuses, such as “Status: Proposed; awaits Codex ratification + founder Accept.” Add the required final line after References.

4. Master brief / ULTRAPLAN edit disposition is not honest. Lines 71 and 100-109 say ULTRAPLAN line 566 “is amended in-band” and provide a commit message, but live `docs/specs/ULTRAPLAN.md` line 566 still contains the original Gate A wording. The master-brief edit rule requires the edit to land in this commit, the next atomic-correction commit, or an explicit deferred queue. Either apply the ULTRAPLAN edit with this ADR, or mark it as explicitly deferred with owner/commit queue.

5. `payload.detection_delay_seconds` is introduced without the required payload-shape authority. Lines 69 and 119 reference `decision_log.payload.detection_delay_seconds`, while line 119 admits it is not in v0.3 schema and says `cycle.sh` records it as free-form JSONB. Type-specific §7 requires payload keys to be documented in autosend-safety-policy §7 before use. Remove the field from this ADR until v0.4 defines it, or add the payload-shape supplement before Concierge writes it.
