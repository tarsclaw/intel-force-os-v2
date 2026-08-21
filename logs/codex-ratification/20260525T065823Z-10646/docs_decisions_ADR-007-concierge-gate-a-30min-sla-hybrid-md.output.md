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
session id: 019e5ded-7892-7290-8c9e-84c5ba6d3245
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

## Alternatives considered

**Alternative A — Keep ULTRAPLAN A6 line 566 verbatim: 30-min SLA is per-draft Gate A hard-fail.** Rejected because Bullhorn webhook coverage is patchy per the ULTRAPLAN A6 gotcha (the same source spec acknowledging the polling-fallback requirement); per-draft hard-fail would drop legitimate drafts whose Concierge generation IS within 30 min of detection but whose upstream detection latency exceeded 30 min. The product harm: candidate experiences "ghosted by recruiter" — exactly the pattern Concierge was designed to prevent.

**Alternative B — Remove the 30-minute SLA entirely.** Rejected because the SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Removing it would let drafts slip indefinitely with no quality signal — the "no candidate ghosted" goal becomes unmeasurable.

**Alternative C — Measure occurrence-time (Bullhorn state-change timestamp) rather than detection-time (webhook arrival or polling-cron tick).** Rejected because Bullhorn state-change timestamps are not always reliable (Bullhorn webhook gotcha; some state changes lack a clean timestamp). Detection-time is what Concierge actually observes; occurrence-time would require infrastructure Concierge doesn't own.

**Alternative D (selected) — Hybrid: voice + addressee checks stay Gate A; 30-min SLA moves to Gate B at 90% threshold.** Detection-time-based; population-level promise captured; per-draft outliers don't block.

## Decision

### Decision 1 — Move Concierge 30-minute SLA from Gate A hard-fail to Gate B leading metric (90% target)

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
- v0.4 schema work: Concierge cycle.sh will record upstream-detection-latency separately in the audit payload (`payload.detection_delay_seconds`) once the field is declared and validated in a v0.4 supplement. v0.3 + v1.0 do NOT introduce this payload key — it would violate review-schema-change §3 (bounded values require CHECK or trigger). The metric attribution distinction (Concierge generation latency vs upstream polling latency) IS the right product behavior but the schema authority lands later.

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

### In-band ULTRAPLAN amendment (applied with this ADR per master brief §10.3 step 4)

ULTRAPLAN §8.1 A6 line 566 amended in the same commit as this ADR. Pre-amendment / post-amendment text is captured in this ADR's body. The amendment also updated line 567 Gate B target to include the new ≥90% 30-min SLA hit rate threshold (per ADR-007). See commit history for the diff.

### Concierge §10 amendment

Add to Accepted blockers (after R3 commit `f79c018` baseline):

> - **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes R3 Finding 3 structural deviation; ratifies the agent.md §5 Gate A scope vs ULTRAPLAN A6 line 566 pre-amendment language.

### Audit payload extension (deferred to v0.4 supplement)

`decision_log.payload.detection_delay_seconds` is NOT introduced by this ADR. Queued for v0.4 supplement OR W10-13 build-slice schema addition (whichever ships first), with declaration + type validation landing together (per review-schema-change §3 — bounded values require CHECK or trigger). Concierge cycle.sh v0.0 does NOT write this key. Distinguishing Concierge generation latency from upstream polling latency in operational alerts is the v0.4 work item; v1.0 metrics use the elapsed (event-detection → draft-render) as a single number.

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

---

**Status:** Proposed; awaits Codex `review-architecture-decision` ratification (R19+) + founder Accept per master brief §10.3 step 5 if Codex still disagrees.

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
I’ll verify the ADR against the cited repo files and the decision-doc shape requirements, especially the ULTRAPLAN line references, escalation code claims, and master-brief references.
exec
/bin/zsh -lc "rg -n \"Gate A:|Gate B:|Lifecycle event detection|§10\\.3|§10\\.5|Quality gates before features|ESC_CONCIERGE_SLA_MISS|ESC_GATE_B_MISS|detection_delay_seconds|Concierge Finding 3|ADR-006|ADR-007|f79c018|Status:\" docs agents .codex -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
.codex/ratification/review-agent-bundle.md:22:| §5 | Gates | Gate A: validate.sh hard-fail conditions. Gate B: outcome success threshold + measurement mechanism | Missing; Gate A conditions not testable; Gate B threshold not cited to ULTRAPLAN/master brief; Gate A weaker than §1 output contract |
.codex/ratification/review-agent-bundle.md:61:**Pre-build scaffold (Status: Proposed)** — written BEFORE the sibling bundle files exist. The 5 W3-scaffold agents (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) are all pre-build scaffolds. Allowed gaps:
.codex/ratification/review-agent-bundle.md:75:**Production-ready (Status: Accepted OR In Force)** — written AFTER bundle files exist + pass tests. Diagnostic at Day-13 + Day-19 polish is production-ready. Additional requirements:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:3:# Status: Proposed (Codex Day-19 ratification queue addendum)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:842:  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:848:# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:853:  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:863:      Per ADR-006 Tier 2 disposition: per-claim citation analysis is a
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1010:  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1030:    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
agents/_shared/escalation-codes.md:3:**Status:** Reference — single source of truth for `ESC_*` codes used by any agent. Wired into `_shared/hook-helpers.sh` (Phase 3).
agents/_shared/escalation-codes.md:139:- **Status:** v1.0 placeholder; no agent fires this yet. Reserved name.
agents/_shared/escalation-codes.md:377:#### `ESC_GATE_B_MISS`
agents/_shared/escalation-codes.md:431:#### `ESC_CONCIERGE_SLA_MISS`
.codex/ratification/SKILL.md:26:4. **Quality gates before features** — Gate A (`validate.sh` hard-fails) + Gate B (`decision_log` mandatory writes) + autosend-safety-policy tier dispatch. Does this artefact bypass or weaken any gate?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:3:# Status: Proposed (Codex Day-7 ratification queue addendum)
docs/verticals/recruitment/vertical-schema.yaml:426:      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).
docs/verticals/recruitment/vertical-schema.yaml:838:    status: DEFERRED to v1.1 / ADR-006
agents/_shared/README.md:3:**Status:** Phase 5 complete (v0.1). All 4 phase deliverables landed; live VPS migration is a manual founder action (see §Live integration test).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:6:-- Status:       DRAFTED; NOT executed against production Hetzner Postgres yet.
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:18:--     + schema supplement (per ADR-006 Tier 2 + v0.3 supplement §5). v0.3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:407:    -- (per ADR-006 Tier 2); v0.3 trigger does not allowlist this key
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:6:-- Status:       DRAFTED; NOT executed against production Hetzner Postgres yet.
agents/recruitment/cash-conductor/README.md:3:**Status:** Proposed (Day-18 pre-W7-8-build scaffold).
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:6:-- Status:       DRAFTED; awaits D3 founder resolution + D2 SeedLegals advisor
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:6:-- Status:                 DRAFTED; only execute if v0.3 changes break production.
agents/recruitment/cash-conductor/agent.md:3:**Status:** Proposed.
agents/recruitment/cash-conductor/agent.md:325:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:346:| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
agents/recruitment/cash-conductor/agent.md:404:**ADR-005 framing:** ADR-005 (Week-3 Diagnostic acceleration) notes Cash Conductor is unaffected by Bullhorn slips because it has zero Bullhorn dependency. v0.3 supplement: Cash Conductor pull-forward (from W7-8 to W4-5) is NOT explicitly authorised by ADR-005 §5.1 (that section number doesn't exist; earlier draft mis-cited). Pull-forward would require a separate ADR (e.g. ADR-007 if/when needed); accounting + Open Banking commercial signups remain founder-action gates regardless of timing.
agents/recruitment/cash-conductor/agent.md:410:**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start.
agents/recruitment/scribe/README.md:3:**Status:** Proposed (Day-17 pre-W6-build scaffold).
docs/_archive-build-pack/08-OPEN-DECISIONS.md:9:**Status:** Resolved 16 May 2026.
agents/recruitment/scribe/agent.md:3:**Status:** Proposed.
agents/recruitment/scribe/agent.md:82:Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Scribe agent.md will re-verify field-name accuracy against the supplement-as-RATIFIED state at W6 Day-1.
agents/recruitment/scribe/agent.md:259:Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).
agents/recruitment/scribe/agent.md:333:**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
agents/recruitment/sourcing-scout/README.md:3:**Status:** Proposed (Day-19 pre-W9-build scaffold).
agents/recruitment/sourcing-scout/README.md:27:Per ULTRAPLAN A5 line 555 gotcha: source-abstraction layer designed for Night Sourcer reuse. Defer ADR-006 to W9 build start documenting the layer's interface.
agents/recruitment/sourcing-scout/agent.md:3:**Status:** Proposed.
agents/recruitment/sourcing-scout/agent.md:275:Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing) — operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
agents/recruitment/sourcing-scout/agent.md:296:| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
agents/recruitment/sourcing-scout/agent.md:357:**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:368:| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. New ADR-006 at W9 build start documenting source-abstraction interface. |
agents/recruitment/sourcing-scout/agent.md:392:   - Q6: source-abstraction-layer ADR drafted + ratified (new ADR — not the same as ADR-006 which is Diagnostic Gate A; number assigned at authoring time)
agents/recruitment/janitor/README.md:3:**Status:** Proposed (Day-16 pre-W5-build scaffold; awaits Bullhorn A+B + Q1 LOI + W5 build slice).
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
agents/recruitment/janitor/agent.md:3:**Status:** Proposed.
agents/recruitment/janitor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority. R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4. R19 fixes (today): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice.
agents/recruitment/janitor/agent.md:176:   → exit code 0 (or 1 if BOTH Gate-B thresholds missed for 3 consecutive runs per §5 + catalogue → ESC_GATE_B_MISS)
agents/recruitment/janitor/agent.md:211:Per catalogue `escalation-codes.md` ESC_GATE_B_MISS trigger (Janitor example: "dedup confidence <15% AND field-completeness uplift <10%"): `ESC_GATE_B_MISS` fires only when BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND completeness-improvement <10%) → flag for operator review (heuristic tuning may be needed; not a kill). Single-threshold misses are tracked in the day-30 report (§3 Output 1 row 6) and inform tenant-level quality review but do NOT fire ESC. Sensitivity choice: strict AND-trigger reduces false alarms; tightening to OR-trigger requires a catalogue amendment + re-ratification.
agents/recruitment/janitor/agent.md:228:| `ESC_GATE_B_MISS` | Per catalogue trigger: per-agent local Gate B metric threshold missed. For Janitor: BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND field-completeness-improvement <10%) per catalogue `ESC_GATE_B_MISS` Janitor example. Single-threshold misses do NOT fire (per §5 Gate B). Catalogue routing: operator_chat_id | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:283:**Status:** Proposed. Awaits Bullhorn A+B Accepted + Q1 LOI + W5 build slice start.
agents/recruitment/diagnostic/cleanup.sh:5:# Status: Proposed (pre-W3-build scaffold; Day-12 author).
docs/architecture/tenancy-invariants.md:3:**Status:** Reference (In Force on tenant-data write paths).
agents/recruitment/diagnostic/validate.sh:6:# Status: Proposed (pre-W3-build scaffold; Day-12 author).
agents/recruitment/diagnostic/validate.sh:228:  printf '\nValidate Gate A: \033[1;32mPASS\033[0m (warnings=%d)\n' "${#WARNINGS[@]}"
agents/recruitment/diagnostic/validate.sh:231:  printf '\nValidate Gate A: \033[1;31mFAIL\033[0m (%d failures, %d warnings)\n' \
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:13:# Status: Proposed (pre-W3-build; behaviour design verified).
docs/architecture/architecture-cohesion-review.md:4:**Status:** Reference (audit surfaces issues; does not resolve inline — remediation paths named).
docs/architecture/architecture-cohesion-review.md:127:- **Status:** This is by design — `recent_edit` is the SFT corpus source, not the operator-facing audit. But Codex Round 1 flagged it as a GDPR risk (now Risk #10).
docs/architecture/architecture-cohesion-review.md:129:- **Status: OPEN until D3 resolves.**
docs/architecture/architecture-cohesion-review.md:233:| R7 | G1: Voice corpus refresh cadence | Medium | New ADR-006 at Concierge build OR addendum to v0.2 supplement at v1.0 schema close | Claude Code | Week-9 (pre-Concierge) |
agents/recruitment/diagnostic/context.sh:6:# Status: Proposed (Day-19; voice + tone + recent_edits + target_patch hydration via voice-loader.sh + tone-loader + Postgres).
agents/recruitment/diagnostic/fixtures/01-primary.yaml:8:# Status: Proposed (pre-W3-build; data structure verified, content TBD).
docs/architecture/agent-bundle-renderer-design.md:4:**Status:** Reference. Recommendations become binding via ADR-003 (Accepted) + ADR-004 (errata on CLI name + symlink target).
docs/architecture/agent-bundle-renderer-design.md:43:| `agent.md` (line 552) | Output contract first; then workflow, gates, escalation. Master brief §1 Rule 1: "Every agent ships with its output contract written first, as a one-paragraph screenshot description." | the renderer (synthesises into `CLAUDE.md` per §2.1); humans for code review | **Static** — founder writes once; iterated per Codex ratification (master brief §10.5 names every new `agent.md` as always-ratify) |
docs/architecture/agent-bundle-renderer-design.md:307:# Gate A: hard-fail on missing hh_decision_* calls in this run
docs/architecture/agent-bundle-renderer-design.md:636:**Recovery:** stderr lists the failed validation path (e.g. `properties.nurture_cadence.post_interview_chase_hours: expected integer, got string`). Founder edits `/vault/<tenant>/_config.yaml` or the `config.schema.json` source (rare; schema edits go through Codex ratification per master brief §10.5). Re-runs render.
agents/recruitment/diagnostic/agent.md:3:**Status:** Proposed.
agents/recruitment/diagnostic/agent.md:4:**Build state:** Full bundle built (agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures). 18 Codex review-agent-bundle rounds run as of Day-20 W4 bilateral pass; ADR-006 closed Cat-1/Cat-ζ Gate A finding (R10); subsequent rounds reduce mechanical findings to steady-state ~4-5/round at the cross-reference-sync layer per master brief §10.3 step 5. R19 in progress today (this artefact). Status flips Proposed → Accepted when ALL: (a) Codex RATIFIED verdict (R19 or escalated founder-arbitrated per §10.3 step 5), AND (b) founder approves §3's 12-section list as canonical, AND (c) first production render against the first pilot tenant succeeds, AND (d) Gate B baseline measurement begins.
agents/recruitment/diagnostic/agent.md:17:> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A's per-section citation subcheck hard-fails on any section missing its citation, per `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). ADR-006 establishes Gate A as per-section hard-fail; per-claim citation analysis is a separate post-launch quality metric outside Gate A (future W4 ADR + schema supplements). The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (target voice-classifier ≥ 0.75 per `common-voice.json`; v0 implementation warns + exits 0 when `IFOS_VOICE_CLASSIFIER_URL` is unreachable per §5 honesty note — W4 polish closes this to unconditional hard-fail) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
agents/recruitment/diagnostic/agent.md:68:- Any section with zero citation links (per-section citation subcheck; ADR-006-canonical)
agents/recruitment/diagnostic/agent.md:121:   → per-section citation hard-fail (ADR-006 Tier 1; no warn-only path)
agents/recruitment/diagnostic/agent.md:153:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
agents/recruitment/diagnostic/agent.md:155:**Per ADR-006 (canonical interpretation of ULTRAPLAN §8.1 A1 line 496 Gate A clause "no claims unsupported by source data"):** Gate A's citation subcheck is per-section hard-fail (every one of the 12 sections has ≥1 evidence link). Per-claim citation analysis is a SEPARATE post-launch quality metric, NOT Gate A — to be authored as a future W4 ADR with schema supplements when the voice-classifier microservice ships + first pilot tenant accumulates ≥30 reports.
agents/recruitment/diagnostic/agent.md:157:**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
agents/recruitment/diagnostic/agent.md:225:| `validate.sh` Gate A logic (12-section check) | `agents/recruitment/diagnostic/validate.sh` | ✅ Built; per-section subcheck hard-fail per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per §5 honesty note (W4 polish closes) |
agents/recruitment/diagnostic/agent.md:229:| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⚠ 10 rounds attempted; ADR-006 (Accepted) closed Cat-1 Gate A finding; residual mechanical findings tracked in disagreement doc Phase 4-5 |
agents/recruitment/diagnostic/agent.md:237:**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + Codex RATIFIED verdict + first production render.
agents/recruitment/diagnostic/agent.md:239:**Build state:** full bundle (cycle.sh, validate.sh, context.sh, tools.yaml, cleanup.sh, 3 fixtures) shipped Day 13-19. Codex review-agent-bundle ratification in progress (10+ rounds; ADR-006 closed the Cat-1/Cat-ζ Gate A finding; iterating on smaller mechanical findings).
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:9:# Status: Proposed (pre-W3-build; data shape verified).
docs/architecture/cortexos-kb-surface-investigation.md:5:**Status:** Investigation **paused**. One of four files read. Resumes after `docs/architecture/second-brain-design.md` lands.
docs/architecture/vault-concurrency.md:3:**Status:** Reference (no Proposed/Accepted lifecycle). Synthesis of `docs/architecture/second-brain-design.md` §2.6 + `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` Decisions 2-3 + `docs/decisions/sequencing-target.md` §5-A `decision_log.phase` extension.
agents/recruitment/concierge/README.md:3:**Status:** Proposed (Day-19 pre-W10-13-build scaffold).
agents/recruitment/diagnostic/tools.yaml:3:# Status: Proposed (Day-19; @ifos/web-scraper + @ifos/companies-house MCP connectors shipped Day 13; LinkedIn via web-scraper page-fetch in v0; Proxycurl deferred to W4 polish).
docs/architecture/cortexos-primitive-status.md:4:**Status:** Reference (Week-0 audit of cortextOS submodule at pinned SHA; no Proposed/Accepted lifecycle).
docs/architecture/cortexos-primitive-status.md:38:**Status:** `shipped but flaky`
docs/architecture/cortexos-primitive-status.md:99:**Status:** `shipped and tested`
docs/architecture/cortexos-primitive-status.md:159:**Status:** `shipped and tested`
docs/architecture/cortexos-primitive-status.md:230:**Status:** `shipped and tested`
docs/architecture/cortexos-primitive-status.md:294:**Status:** `shipped and tested` (Telegram); **iOS surface is aspirational**
docs/architecture/cortexos-primitive-status.md:368:**Status:** `shipped and tested`
docs/architecture/cortexos-primitive-status.md:432:**Status:** `shipped and tested`
docs/architecture/second-brain-design.md:4:**Status:** Reference. Q3 recommendation non-binding; ADR-002 ratifies it.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/runbooks/day-4-provisioning.md:29:- **Rule 4 (Quality gates before features):** the §7 RLS isolation test is the binary gate. If it fails, the runbook execution stops at §7 and we debug before continuing.
docs/runbooks/day-4-provisioning.md:338:# Expected: Status: active, three ALLOW IN rules
docs/specs/ULTRAPLAN.md:6:**Status:** Authoritative build plan. Supersedes any informal build sequencing in prior documents. Where this contradicts an earlier doc on *how to build*, this wins. The product spec wins on *what to build*.
docs/specs/ULTRAPLAN.md:36:**Rule 4 — Quality gates before features.** An agent that ships with a working Gate A and a measurement plan for Gate B/C is shippable. An agent that ships with extra features but a flaky Gate A is not. Every weekly review checks gates before features.
docs/specs/ULTRAPLAN.md:496:- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/specs/ULTRAPLAN.md:510:- **Gate A:** dedup confidence score ≥ 0.85 on every merge proposal; no merge proposed where candidate has had activity in last 90 days without explicit review flag
docs/specs/ULTRAPLAN.md:524:- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
docs/specs/ULTRAPLAN.md:538:- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
docs/specs/ULTRAPLAN.md:552:- **Gate A:** 5–15 candidates returned per brief; each has a working contact method; each has rationale ≥ 50 words; no candidate flagged "do not contact" in tenant vault
docs/specs/ULTRAPLAN.md:566:- **Gate A:** voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82 per escalation_position); correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
docs/specs/ULTRAPLAN.md:567:- **Gate B target:** <5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate (per ADR-007)
docs/specs/ULTRAPLAN.md:569:- **Gotchas:** Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks. Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship.
docs/specs/ULTRAPLAN.md:582:- **Gate A:** draft generated within 60s of webhook receipt; classification has confidence ≥ 0.8; no auto-send on uncategorised messages
docs/specs/ULTRAPLAN.md:596:- **Gate A:** every brief produces 3 ambiguity flags OR an "unambiguous" signal; pre-shortlist contains 3–10 candidates; intake-call agenda has 5–8 items
docs/specs/ULTRAPLAN.md:614:- **Gate A:** detection latency <5 min from competitor posting; outreach references the specific role title AND the competitor agency by name (the firm needs to know we're not making this up)
docs/specs/ULTRAPLAN.md:628:- **Gate A:** 8–12 candidates per brief; each has rationale ≥ 50 words; drafts for each are valid (Gate A on the draft itself); no rate-limit exceptions raised
docs/specs/ULTRAPLAN.md:642:- **Gate A:** every red-flag pattern (e.g., FCSA accreditation lapsed, complaint volume spike, director change) produces an alert within 24 hours; quarterly audit pack contains all required sections
docs/specs/ULTRAPLAN.md:656:- **Gate A:** every active contractor has a live state with AWR week counter, RTW expiry, contract end, holiday pay year-to-date; deadline-imminent alerts fire ≥7 days ahead
agents/recruitment/diagnostic/README.md:3:**Status:** Proposed (Day-11 pre-build scaffold; awaits W3-4 build slice).
agents/recruitment/diagnostic/cycle.sh:5:# Status: Proposed (Day-19; v0 implementation using @ifos/diagnostic-generator + web-scraper + companies-house MCP connectors all wired).
agents/recruitment/diagnostic/cycle.sh:39:#     per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per
docs/build-brief/00-MASTER-BRIEF.md:57:4. **Quality gates before features.** Gate A (per-run `validate.sh`) working + decision-log writes (`hh_decision_trigger / output / action`) present > extra features. `validate.sh` hard-fails on missing decision-log calls. No exceptions.
docs/build-brief/00-MASTER-BRIEF.md:448:- [ ] Write `docs/architecture/cortexos-primitive-status.md`. One line per primitive (1–7 from §2.4). Status: `shipped and tested` / `shipped but flaky` / `documented not built` / `aspirational`. Method:
docs/build-brief/00-MASTER-BRIEF.md:831:| "Let me skip the Codex ratification — it's a small change..." | §10.5 |
docs/build-brief/00-MASTER-BRIEF.md:874:4. Quality gates before features
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:4:**Status:** Awaiting founder arbitration
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:5:**Codex rounds completed:** Round 4 (initial REJECTED, 4 issues) + Round 5 (remediation REJECTED, 5 issues including 2 re-raises and 3 new findings) — **hard ceiling per master brief §10.3 step 5 reached**.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:17:Per master brief §10.3 step 5: **≤2 round-trips max per artefact**. Round 5 was the second round-trip. **Hard ceiling reached.** Founder arbitration required to close the artefact.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:77:**Codex says:** "The file has `Status: Proposed` at line 3, but no `Context`, `Decision`, or `Consequences` sections as required for Proposed artefacts by review-architecture-decision §1. Fix: either review this with `review-agent-bundle.md`, or add the required architecture-decision sections and a final status-update line."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:165:**Empirical confirmation of the pattern documented in master brief §10.3 step 5:** Codex finds new issues at each round. Hard ceiling of ≤2 round-trips is the right structural protocol. Further autonomous Claude remediation passes will continue surfacing new issues that may not have been visible at earlier rounds (each fix changes the document, exposing different inconsistencies).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:186:Despite master brief §10.3 step 5 protocol saying founder review after Round 5, Round 6 attempted with all Round-5 issues remediated (commit `aaa376d`). Round 6 returned REJECTED with **4 new findings**, none of which appeared in any prior round:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:202:**21 unique issues across 4 rounds, ZERO repeats.** Master brief §10.3 step 5 hard ceiling exists for exactly this reason — each remediation pass surfaces issues that weren't visible at prior rounds because the document changes.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:216:3. `ESC_GATE_B_MISS` definition in §6 still says "Composite Gate-B score <12.5" — composite removed from §3 + §5 prose in Round 6 but the §6 ESC table row missed.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:229:**Round 7 findings 1 + 2 + 3 + 4 are all CAUSED BY my Round 6 fixes.** When I fixed one section, I introduced inconsistencies between it and other sections referencing the same concept. This is the perfect illustration of why master brief §10.3 step 5 caps round-trips: each fix changes the document, and the changed document has new inconsistencies between the fixed-section and the related-but-unfixed sections.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:235:Master brief §10.3 step 5 cap = 2 round-trips. The hook has requested 5 rounds. Each beyond round 2 has produced 4-5 new findings. The protocol is right; the hook contradicts it.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:298:- `ESC_CONCIERGE_SLA_MISS` — agent uses for draft >30 min; catalogue defines for inbound brief/customer reply SLAs. Resolution: widen to include draft-generation SLA.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:326:**Phase 1 + Phase 2 + Phase 3 (Round 8 + Cat-α inline fixes) constitute the documented "Path A — bilateral session per master brief protocol" outcome.** No further autonomous remediation rounds will be attempted per the master brief §10.3 step 5 hard ceiling and founder's "no more rounds" authorization.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:356:- `ESC_CONCIERGE_SLA_MISS` — three sla_types: brief_ack / customer_reply / draft_generation
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:378:**Cumulative empirical (10 rounds total):** ~75 unique findings catalogued; ~7 closed via Cat-α + Cat-γ + Cat-δ inline this session; convergence rate ~10% per round. The pattern documented in master brief §10.3 step 5 holds.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:407:**Recommended: B (ADR-006).** Closes the disagreement properly; gives Cat-1 a ratified architectural home; future-proofs against Cat-1 re-litigation. ~1 hour Claude work + 1 Codex round to ratify the ADR.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:409:### Decision — stop Codex looping per master brief §10.3 step 5
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:411:The pattern (Round 4 → Round 9; 10 rounds; 75+ unique findings; ~10% net convergence per round) empirically confirms master brief §10.3 step 5. Each remediation pass surfaces new issues at roughly the same rate it closes old ones — because the document keeps changing.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*
agents/recruitment/concierge/agent.md:3:**Status:** Proposed.
agents/recruitment/concierge/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (today): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) drafted at `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md`; Concierge Status flip Proposed → Accepted requires ADR-007 RATIFIED. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + ADR-007 RATIFIED + W10 build slice.
agents/recruitment/concierge/agent.md:17:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts (both per ULTRAPLAN A6 line 567); + ≥90% 30-min SLA hit rate (per ADR-007 — the 90% threshold is NOT in ULTRAPLAN line 567; it is the Gate B reframe of ULTRAPLAN line 566's per-draft 30-min hard-fail, introduced by ADR-007 and amended into ULTRAPLAN line 567 in the same commit). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:214:   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
agents/recruitment/concierge/agent.md:265:    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
agents/recruitment/concierge/agent.md:285:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
agents/recruitment/concierge/agent.md:293:Per ULTRAPLAN A6 line 567 + ADR-007 amendment: **"<5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate"**. The third metric is ADR-007's Gate B reframe of ULTRAPLAN line 566's per-draft 30-min hard-fail (NOT in original line 567 wording).
agents/recruitment/concierge/agent.md:298:- **30-min SLA hit rate:** % of drafts generated within 30 minutes of lifecycle-event DETECTION. Target ≥90%. Per-draft misses fire `ESC_CONCIERGE_SLA_MISS`; rolling-window aggregate <90% fires `ESC_GATE_B_MISS`. (per ADR-007 + amended ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:300:Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
agents/recruitment/concierge/agent.md:320:| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |
agents/recruitment/concierge/agent.md:324:| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% for 30 consecutive days | warn | founder + operator |
agents/recruitment/concierge/agent.md:397:**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + D1 founder decision + Q1 LOI + W10-13 build slice.
agents/recruitment/concierge/agent.md:416:1. **Lifecycle event detection from Bullhorn is the unreliable bit.** Bullhorn's webhook coverage is patchy; polling fallbacks are required. Step 1 polling at 5-min cycle + anti-duplicate guard at Step 2 is the architecture.
agents/recruitment/concierge/agent.md:429:- **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes the documented deviation from ULTRAPLAN A6 line 566 wording. ADR drafted at `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` (Day 20 W4 bilateral pass); ratifies via `.codex/ratification/review-architecture-decision.md` skill. Until RATIFIED, agent.md's Gate B framing of the 30-min SLA is documented disposition only.
docs/operations/bullhorn-outreach-emails.md:3:**Status:** Reference (operations playbook for Bullhorn commercial conversations)
docs/operations/bullhorn-outreach-emails.md:73:- If they confirm direct-tier works for pilot scale → Sub-decision A flips to **Direct API**; Status: Accepted. Update `bullhorn-integration-path.md` §5.
docs/runbooks/operational-hygiene-protocol.md:3:**Status:** In force (Day 6, 2026-05-18). All sections from Week 0 onwards reference this document at section-gate moments.
docs/specs/_archive-build-handoff.md:194:4. Quality gates before features — Gate A working > extra features.
docs/specs/_archive-build-handoff.md:420:4. **Quality gates before features** — an agent that ships with a working Gate A and a measurement plan for Gate B/C is shippable. An agent that ships with extra features but a flaky Gate A is not.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:1:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:15:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:19:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:43:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:56:**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:58:**Rule 4 (Quality gates before features) satisfied for the per-section citation subcheck:** it is hard-fail at v0 with no warn-only paths. (Other Gate A subchecks — voice classifier + PII — retain v0 warn-only paths when upstream services are unreachable per Context note; W4-polish closes those. ADR-006 addresses only the per-section subcheck.) Per-claim quality is a separate signal, not a weakening of Gate A's per-section subcheck.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:66:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:70:> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — per-section citation subcheck is hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (a W4 ADR to be authored at first-pilot polish time).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:74:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:76:This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:103:- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:108:- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:125:- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:126:- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:127:- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:150:- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:152:*End of ADR-006.*
docs/runbooks/tenant-lifecycle.md:3:**Status:** In Force
docs/specs/PRODUCT-SPEC.md:6:**Status:** Final. Supersedes the agent specs scattered across the internal business plan, the CortexOS 24/7 directive, and the temp deep dive on points of conflict. Where this contradicts an earlier doc, this wins.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:4:**Status:** Proposed
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:167:OR open a follow-on ADR if the decision warrants more substantive recording (e.g., ADR-005 for D1; ADR-006 for D2 + D3 bundle).
docs/runbooks/pii-purge-operational-pattern.md:3:**Status:** Proposed (pending Founder Decision D3 final retention period + D2 external advisor input)
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/operations/goal-option-c-diagnostic-end-to-end.md:250:- **Status:** Accepted
docs/operations/goal-option-c-diagnostic-end-to-end.md:384:Gate A:            PASS (V3 warning — voice classifier skipped per scaffold)
docs/decisions/brain-ui-scope.md:4:**Status:** Proposed — revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch)
docs/decisions/brain-ui-scope.md:201:- §1 (forward-deferral framing — Status: Proposed is structurally appropriate because v1.0 actual-usage evidence is the input v1.1 planning needs).
docs/operations/seedlegals-engagement-queries.md:3:**Status:** Reference (operations playbook for D2 founder action)
docs/operations/founder-legal-setup-guide.md:3:**Status:** Reference (operations playbook for a founder who has never done business legal before)
docs/operations/codex-round-2-autonomous-prompt.md:3:**Status:** Reference (operations artefact).
docs/operations/codex-round-2-autonomous-prompt.md:91:recursive ratification per master brief §10.5. Decide whether Claude's 
docs/operations/codex-round-2-autonomous-prompt.md:196:  Disagreement docs (recursive ratification per master brief §10.5):
docs/operations/codex-round-2-autonomous-prompt.md:320:**If SUMMARY.md shows unexpected REJECTED items:** Codex caught something. Read the per-artefact output file. Decide whether to incorporate or counter-argue. Then Round 3 (~limited; ≤2 round-trips per master brief §10.3).
docs/operations/codex-ratification-execution-plan.md:3:**Status:** Reference (operations runbook).
docs/operations/codex-ratification-execution-plan.md:97:- [ ] Quality gates before features
docs/operations/codex-ratification-execution-plan.md:274:    'round_trip', $5,                     -- 1 or 2 per §10.3
docs/operations/codex-ratification-execution-plan.md:317:Per master brief §10.3 step 5:
docs/decisions/autosend-approval-bridge-spec.md:3:**Status:** Proposed
docs/operations/goal-week-3-polish-and-scaffold.md:3:**Status:** CLOSED (2026-05-24 Day 19) — executed end-to-end with founder bilateral disposition. v0.3 schema supplement RATIFIED. ADR-006 Diagnostic Gate A hybrid Accepted. 6 agent.md scaffolds at Pre-Build-Round-N-Reviewed. Catalogue extended 24→52 ESC codes + 29→47 action_types. Final state pushed at `75ccc5f`. Founder explicitly authorized Codex ratification execution within this session via AUQ ("Authorize one final Codex round...RATIFY-or-document-disagreement") + repeated "proceed" instructions, which override the original §0 "Steps 7+13 — I run those" reservation in this file. Week 3 close documented in `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` + `.agents/current-priorities.md`. **STOP-HOOK NOTE: this file's gate-structure was superseded by in-session founder AUQ authorization; do not re-fire on subsequent turns.**
docs/operations/goal-week-3-polish-and-scaffold.md:20:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (boundaries) + §6 Day 4-7 (foundation state) + §8 (build sequence) + §10.5 (always-ratify artefacts)
docs/operations/goal-week-3-polish-and-scaffold.md:52:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:53:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:54:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:55:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:56:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:94:| Diagnostic Codex ratification | Master brief §10.5 always-ratify |
docs/operations/goal-week-3-polish-and-scaffold.md:111:| Modifying ratified ADRs 001-005 | Audit trail; ADR-006+ if new architectural decisions surface during Week 3 |
docs/operations/goal-week-3-polish-and-scaffold.md:302:- **Status:** Proposed (pre-W5-build; awaits Bullhorn A+B + first pilot LOI)
docs/operations/goal-week-3-polish-and-scaffold.md:308:- **§5 Gate A:** validate.sh hard-fails on missing CTX env, dedup-rate >20% (suggests bad heuristic), field-write-error-rate >5%, schema-violation rows.
docs/operations/goal-week-3-polish-and-scaffold.md:309:- **§5 Gate B:** ≥15% dedup improvement + ≥10% field-completeness improvement per ULTRAPLAN line 512.
docs/operations/goal-week-3-polish-and-scaffold.md:343:- **§5 Gate A:** validate.sh hard-fails on missing transcript, field-extraction confidence <0.6, Bullhorn write FK-violation, voice-classifier <0.75 on tacit note.
docs/operations/goal-week-3-polish-and-scaffold.md:344:- **§5 Gate B:** ≥80% field-extraction accuracy (per consultant spot-check) + ≥90% within-10-min SLA.
docs/operations/goal-week-3-polish-and-scaffold.md:372:- **§5 Gate A:** validate.sh hard-fails on accounting API auth failure, bank API auth failure, reconciliation false-positive rate >2%, chase-draft content failing voice classifier.
docs/operations/goal-week-3-polish-and-scaffold.md:373:- **§5 Gate B:** ≥95% invoice match accuracy (vs human spot-check) + ≥15% reduction in days-sales-outstanding (DSO) after 60 days operation.
docs/operations/goal-week-3-polish-and-scaffold.md:400:- **§5 Gate A:** validate.sh hard-fails on empty match list, low average confidence (<0.5), schema violation.
docs/operations/goal-week-3-polish-and-scaffold.md:401:- **§5 Gate B:** ≥3 high-confidence (>0.7) matches per brief.
docs/operations/goal-week-3-polish-and-scaffold.md:427:- **§5 Gate A:** validate.sh hard-fails on missing approval-bridge auth (if D1-A bridge), voice classifier <0.75, tone-rule block-severity hit, schema violation, orange-tier-spot-check sample selected.
docs/operations/goal-week-3-polish-and-scaffold.md:428:- **§5 Gate B:** <5% incorrect-send rate (per consultant feedback loop) + ≥90% lifecycle-event coverage (no missed transitions).
docs/operations/goal-week-3-polish-and-scaffold.md:450:Triage protocol (master brief §10.3 step 5 hard ceiling: ≤2 round-trips):
docs/operations/goal-week-3-polish-and-scaffold.md:502:| Codex Round 4 returns >2 REJECTED on any single artefact | Founder review; do NOT remediate-and-resubmit beyond hard ceiling (per master brief §10.3 step 5); write founder-decision doc; defer |
docs/operations/goal-week-3-polish-and-scaffold.md:540:Per master brief §10 + §10.3 step 5 hard ceiling + Day-11 Round-2/3 pattern.
docs/operations/goal-week-3-polish-and-scaffold.md:573:- **Mechanical REJECTIONS (citation drift, line-anchor error, formatting):** Round 4 remediation prompt; expect Round 5 final. Hard ceiling per master brief §10.3 step 5: 2 round-trips MAX. Round 5 RATIFIED → close. Round 5 STILL REJECTED → founder review.
docs/operations/goal-week-3-polish-and-scaffold.md:614:  Gate A:             PASS (V1-V6 green; V3 warning per scaffold)
docs/operations/codex-ratification-guide.md:3:**Status:** Reference (operations guide).
docs/operations/codex-ratification-guide.md:373:The disagreement doc itself becomes a ratifiable artefact in a future round (master brief §10.5 recursive ratification). That's by design — the disagreement IS the signal.
docs/operations/w4-day-20-founder-runbook.md:4:**Status:** DRAFT — awaiting founder authorization to execute Steps A & B
docs/operations/w4-day-20-founder-runbook.md:27:**Why:** Per master brief §10.5, "every Postgres migration touching tenant
docs/operations/w4-day-20-founder-runbook.md:31:read of §10.5 (it executes DDL against live data).
docs/operations/codex-round-2-remediation-prompt.md:3:**Status:** Reference (operations artefact)
docs/operations/codex-round-2-remediation-prompt.md:36:  4. docs/build-brief/00-MASTER-BRIEF.md §10.3 (≤2 round-trip ceiling —
docs/operations/codex-round-2-remediation-prompt.md:201:      **Status: Sub-decisions A+B can remain Proposed without blocking
docs/operations/codex-round-2-remediation-prompt.md:369:  Status: Mitigated in this commit; verify after Round 3 close.
docs/operations/codex-round-2-remediation-prompt.md:377:  Status: Mitigated in this commit; remains pending D2/D3 founder
docs/operations/codex-round-2-remediation-prompt.md:407:Per master brief §10.3 step 5: Round 3 is the LAST automated round.
docs/operations/codex-round-2-remediation-prompt.md:433:     Per master brief §10.3, this is the last automated round. Confirm
docs/operations/codex-round-2-remediation-prompt.md:525:  Round 3 ratification (≤2 round-trips per master brief §10.3): 10 items
docs/operations/codex-round-2-remediation-prompt.md:634:**Round 3 ratification:** 10 corrected items re-ratified against appropriate skills. Hard-ceiling enforced per master brief §10.3 step 5.
docs/operations/w4-bilateral-pass-6-agent-md.md:105:  - **Likely:** **REJECT-CODEX** with rationale, OR small schema supplement edit. The migration allowlist IS the v0.3 supplement enforcement (per ADR-006 + the v0.3 trigger). But Codex's point is that they should also appear in the YAML schema definition (`tenant_adapters_config_additions`) for documentation completeness. Founder call: edit the YAML supplement to declare them explicitly, OR write disagreement claiming migration-allowlist is sufficient single-source-of-truth.
docs/operations/w4-bilateral-pass-6-agent-md.md:122:  - **Codex says:** "It flips to Accepted on ratification/founder questions/ADR-006 before the W9 bundle exists, but the agent-bundle skill treats Accepted as production-ready after sibling files + fixtures exist and pass gates. Fix by keeping this scaffold Proposed after ratification, and make Proposed → Accepted depend on W9 build completion: `tools.yaml`, `context.sh`, `validate.sh`, `cycle.sh`, `cleanup.sh`, and 3 fixtures."
docs/operations/w4-bilateral-pass-6-agent-md.md:213:  - **Likely:** **SCOPE-EXPAND**. This is the analogue of ADR-006 for Diagnostic. W4 queue #3 already plans this ADR ("Future ADR — Concierge Gate A 30-min SLA hybrid"). Disposition options:
docs/operations/w4-bilateral-pass-6-agent-md.md:234:4. **Concierge Gate-A ADR** (Concierge #3) — only structural finding. Recommend writing the ADR before flipping Concierge to RATIFIED (analogue of ADR-006 process).
docs/operations/codex-round-2-handoff.md:3:**Status:** Reference (operations protocol).
docs/operations/codex-round-2-handoff.md:104:| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | `review-architecture-decision` | **Recursive ratification per master brief §10.5.** Codex either RATIFIES the disagreement (D5 was correct) OR REJECTS (insists on strict skill). Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:200:ratification per master brief §10.5. Decide whether Claude's counter-argument
docs/operations/codex-round-2-handoff.md:292:Hard ceiling: 2 round-trips (master brief §10.3 step 5). After Round 2, no Round 3 — escalate to founder for explicit decision.
docs/operations/codex-round-2-handoff.md:332:Any Round-2 REJECTED items get their own row in the manifest queue updated to "REJECTED→ROUND-3-pending OR founder-escalated". Per §10.3 master brief: no Round 3 until founder decides.
docs/operations/codex-round-2-handoff.md:406:Manifest queue position: this protocol document itself joins the queue as a Round-3 candidate (recursive ratification per master brief §10.5).
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:29:**Counter:** `cortexos-primitive-status.md` is an **audit artefact** (Status: Reference per the Day-8 Codex Round 1 cosmetic incorporation). `operational-hygiene-protocol.md` is an **operational runbook** (Status: In Force per Day-6 close `0020521`). Neither is a decision document.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:3:**Status:** Accepted (2026-05-24, Day 13)
docs/decisions/ADR-004-renderer-implementation-deviations.md:8:**Status:** Proposed
docs/decisions/ADR-004-renderer-implementation-deviations.md:18:The three deviations are individually small. The reason this ADR exists rather than three inline `errata` notes in ADR-003 is master brief §10.5 ("Always-ratify list"): renderer architectural decisions go through Codex review, and a single coherent ADR is the audit-trail-friendly path. Reading ADR-003 + ADR-004 together gives the full ratified renderer surface.
docs/decisions/2026-05-18-codex-ratification-manifest.md:5:**Status:** Reference
docs/decisions/2026-05-18-codex-ratification-manifest.md:111:Round 4 scheduled across Week 3 (Days 14-20) per `docs/operations/goal-week-3-polish-and-scaffold.md` Steps 7 (Diagnostic-only, Day 15) + 13 (full run, Day 20). Per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 remediation max).
docs/decisions/2026-05-18-codex-ratification-manifest.md:153:**Hard ceiling reached** per master brief §10.3 step 5. Single founder decision (approve the 5-category disposition) unlocks all 6 ratifications via a single Round-5 mechanical-remediation pass.
docs/decisions/2026-05-18-codex-ratification-manifest.md:205:## §2 — Ratification protocol per master brief §10.3
docs/decisions/2026-05-18-codex-ratification-manifest.md:207:Verbatim from master brief §10.3 (post-Edit 7 path correction):
docs/decisions/2026-05-18-codex-ratification-manifest.md:246:| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
docs/decisions/2026-05-18-codex-ratification-manifest.md:247:| **Disagreement artefacts** | If Codex REJECTS or disagrees with any artefact | `docs/decisions/codex-disagreement-<date>.md` per master brief §10.3 step 4. Founder decides on escalations. |
docs/decisions/autosend-safety-policy.md:3:**Status:** Proposed — pending Codex Day-7 ratification
docs/decisions/autosend-safety-policy.md:604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:5:**Status:** Accepted (factual recording — not a Proposed decision)
docs/decisions/2026-05-18-day-7-single-sentence-test.md:56:- **Auth path cleared: NO.** Sub-decisions A (marketplace vs direct API) and B (OAuth flow specifics — authorization-code grant against IFOS-owned dev tenant) remain Status: Proposed in `bullhorn-integration-path.md`. The technical path is documented but the commercial gates have not passed:
docs/decisions/2026-05-18-day-7-single-sentence-test.md:77:- **Artefact:** `docs/verticals/recruitment/vertical-schema.yaml` Status: Proposed, shipped Day 6 commit `fec8872`.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:65:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:1:# ADR-007 — Concierge Gate A 30-minute draft SLA hybrid (Gate B leading metric, not per-draft hard-fail)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:3:**Status:** Proposed (2026-05-25, Day 20; W4 bilateral pass on Concierge agent.md surfaced this as Codex R3 Finding 3 — current scaffold reframes ULTRAPLAN A6 line 566 Gate A "every lifecycle event has a draft generated within 30 minutes" as a Gate B leading metric without an authoritative ADR backing the deviation. Awaits Codex `review-architecture-decision` ratification + founder Accept.)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:7:**Driven by:** `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3 — Codex flags Concierge `agent.md` §5 line 278 reframes the 30-min SLA as Gate B without an ADR; §10 Accepted criteria omits any ADR-ratification blocker for this deviation. Analogue of ADR-006 (Diagnostic Gate A hybrid).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:15:> - **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:22:- `agent.md` §4 Step 9 (`ESC_CONCIERGE_SLA_MISS` warn, aggregated to Gate B; not per-draft block)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:24:- `agent.md` §6 ESC table (`ESC_CONCIERGE_SLA_MISS` registered as warn, not blocking)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:30:Per master brief §10.5 + Rule 4 (Quality gates before features), an upstream-spec amendment requires either (a) revert the scaffold to per-draft hard-fail, or (b) author an ADR ratifying the deviation. This ADR is option (b).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:36:The Concierge lifecycle-event trigger source is the Bullhorn ATS state-change webhook + a polling-fallback cron (per ULTRAPLAN A6 line 569 verbatim gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks").
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:49:- Aggregate failures fire `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) when sustained — same operational lever as ADR-006's per-claim quality metric
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:51:This is structurally identical to ADR-006's Tier 1 (per-section, hard-fail at the agent level) vs Tier 2 (per-claim, quality metric over time) split — applied here to time (30-min threshold per draft = Tier 1; 90% within 30-min over rolling window = Tier 2).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:79:- Per-draft SLA miss fires `ESC_CONCIERGE_SLA_MISS` (warn, aggregated to Gate B)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:80:- Rolling 30-day per-tenant aggregate <90% fires `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) — actionable signal
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:81:- v0.4 schema work: Concierge cycle.sh will record upstream-detection-latency separately in the audit payload (`payload.detection_delay_seconds`) once the field is declared and validated in a v0.4 supplement. v0.3 + v1.0 do NOT introduce this payload key — it would violate review-schema-change §3 (bounded values require CHECK or trigger). The metric attribution distinction (Concierge generation latency vs upstream polling latency) IS the right product behavior but the schema authority lands later.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:83:**ULTRAPLAN §8.1 A6 line 566 is amended in-band per the master brief §10.3 step 4 pattern** (analogue of the in-band amendment ADR-006 made at line 496):
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:86:> - **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:89:> - **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:98:4. Structural parity with ADR-006: per-event Gate A vs aggregate Gate B as the canonical Tier-1/Tier-2 split for time-based SLAs (replicable pattern for future agents)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:103:2. Tenants with high webhook coverage will see better than 90%; tenants with webhook-coverage gaps see worse — the metric reads as Concierge quality but is partly an upstream condition. Operator must look at `payload.detection_delay_seconds` distribution to disambiguate.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:112:### In-band ULTRAPLAN amendment (applied with this ADR per master brief §10.3 step 4)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:114:ULTRAPLAN §8.1 A6 line 566 amended in the same commit as this ADR. Pre-amendment / post-amendment text is captured in this ADR's body. The amendment also updated line 567 Gate B target to include the new ≥90% 30-min SLA hit rate threshold (per ADR-007). See commit history for the diff.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:118:Add to Accepted blockers (after R3 commit `f79c018` baseline):
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:120:> - **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes R3 Finding 3 structural deviation; ratifies the agent.md §5 Gate A scope vs ULTRAPLAN A6 line 566 pre-amendment language.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:124:`decision_log.payload.detection_delay_seconds` is NOT introduced by this ADR. Queued for v0.4 supplement OR W10-13 build-slice schema addition (whichever ships first), with declaration + type validation landing together (per review-schema-change §3 — bounded values require CHECK or trigger). Concierge cycle.sh v0.0 does NOT write this key. Distinguishing Concierge generation latency from upstream polling latency in operational alerts is the v0.4 work item; v1.0 metrics use the elapsed (event-detection → draft-render) as a single number.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:130:| ADR-007-Q1 | Should the 90% threshold be per-tenant configurable, or is 90% a v1.0 fixed bar? | Recommend fixed at v1.0; v1.1 add per-tenant override via `tenant_adapters.config.concierge_sla_threshold` (new key, v0.4-pending). |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:131:| ADR-007-Q2 | Should `ESC_CONCIERGE_SLA_MISS` be a separate code, or should it reuse `ESC_GATE_B_MISS` with payload.metric='concierge_30min_sla'? | Recommend separate code for clean Telegram routing; `_GATE_B_MISS` is generic aggregate. Catalogue addition queued at W10-13 build start. |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:132:| ADR-007-Q3 | What's the polling-fallback interval default? | Per-tenant; recommend 5 min as v1.0 default; 1 min for tenants with stable webhook coverage. Documented in tools.yaml at W10-13 build. |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:136:- ADR-006 — Diagnostic Gate A hybrid (structural template for Tier 1 vs Tier 2 split)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:139:- `agents/_shared/escalation-codes.md` `ESC_CONCIERGE_SLA_MISS` (registered) + `ESC_GATE_B_MISS` (registered)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:140:- `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:141:- Master brief §1 Rule 4 (Quality gates before features) + §10.5 (ADRs are ratifiable artefacts)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:145:**Status:** Proposed; awaits Codex `review-architecture-decision` ratification (R19+) + founder Accept per master brief §10.3 step 5 if Codex still disagrees.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:7:**Status:** Accepted — Option A. Founder decision logged 2026-05-16.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:71:- Codex-ratification list (master brief §10.5) needs an entry: bus-dispatcher mechanism change = master brief edit = always-ratify.
docs/decisions/ADR-003-agent-bundle-renderer.md:7:**Status:** Accepted. Founder decision logged 2026-05-16.
docs/decisions/sequencing-target.md:4:**Status:** Accepted (Day 3 session close, 2026-05-16). Single-pass technical decision, no commercial gating.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:110:| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
docs/decisions/sequencing-target.md:165:| 3. Risk de-risking | **High (secondary)** | Second Tier-1 always-on agent (after Cash Conductor at W7-8) — provides Risk #1 secondary exercise. Exercises Bullhorn webhook coverage gaps per Ultraplan §8.1 line 569 verbatim ("Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks") |
docs/decisions/sequencing-target.md:277:### 4.1 — Ratified sequence (Status: Accepted)
docs/decisions/sequencing-target.md:288:**Status: Accepted** as the v1.0 plan of record. Binds Week 3-13 build cadence subject to §4.3 revisit conditions.
docs/decisions/sequencing-target.md:323:**Binds (Status: Accepted, no further sub-decision needed at this level of granularity):**
docs/decisions/sequencing-target.md:335:- Per-agent Codex-ratification timing within each build slot — every `agent.md` ratifies before merge per master brief §10.5; specific ratification cadence emerges from each agent's PR cycle.
docs/decisions/bullhorn-integration-path.md:4:**Status:** Proposed (Sub-decision C Accepted technically; Sub-decisions A + B Proposed pending commercial verification per §1.3)
docs/decisions/bullhorn-integration-path.md:81:  - Sub-decision C in full — technical analysis, per-agent endpoint table, webhook-vs-poll decisions, rate-limit budget allocation. **Status: Accepted** on Sub-decision C alone, no commercial gating.
docs/decisions/bullhorn-integration-path.md:82:  - Sub-decisions A and B — full technical analysis (Sections 2 and 3 of this document), with explicit Status: Proposed flags pointing at the §1.3 commercial-blocker table.
docs/decisions/bullhorn-integration-path.md:90:  - Document is re-committed with Status: Accepted on A and B once founder logs the decision.
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:196:**Status: Proposed.** Status flips to Accepted on either: (a) partnerships@bullhorn confirms marketplace is not required for v1.0 production tenant access AND first design partner uses Bullhorn; OR (b) founder explicitly accepts the documented fallback if marketplace turns out required, and re-cuts the v1.0 timeline to absorb the marketplace certification window.
docs/decisions/bullhorn-integration-path.md:271:**Status: Proposed.** Status flips to Accepted on commercial verification answers to the four questions above. Most likely outcome: confirmation of the §3.4 recommendation as stated, with one or two clarifications absorbed into the renderer's auth-module implementation.
docs/decisions/bullhorn-integration-path.md:277:Fully technical. **Status: Accepted** on first pass — no commercial gating.
docs/decisions/bullhorn-integration-path.md:310:| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
docs/decisions/bullhorn-integration-path.md:367:**Sub-decision A — Marketplace vs direct API. Status: Proposed.**
docs/decisions/bullhorn-integration-path.md:379:**Sub-decision B — OAuth flow. Status: Proposed.**
docs/decisions/bullhorn-integration-path.md:392:**Sub-decision C — v1.0 endpoint surface. Status: Accepted.**
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:30:No edit to the agent.md or validate.sh. R17 dispositions cover the other 4 findings; this disagreement is recorded per master brief §10.3 step 4 ("Claude Code reads Codex's feedback; incorporates it or counter-argues explicitly in `docs/decisions/codex-disagreement-{date}.md` (the disagreement IS the signal — write it down, don't dissolve it)").
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:32:If Codex repeats this same finding at R18 against the unchanged text, escalate to founder per §10.3 step 5.
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:36:- ADR-006 — Diagnostic Gate A hybrid (Accepted Day 19, Cat-1/Cat-ζ structural close)
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:7:**Status:** Accepted — Option α. Founder decision logged 2026-05-16.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:133:1. ADR-001 + ADR-002 master-brief edits LANDED in atomic-correction commit `0e5b2b4` (Day 7 2026-05-20). Status: closed.
docs/decisions/v1.0-kill-criterion.md:3:**Status:** Proposed — pending Codex Day-7 ratification

exec
/bin/zsh -lc "rg -n \"master brief|Master brief|§10\\.3|§10\\.5|Risk #7|master-brief-drift\" docs -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:75:          Semver tag (e.g. "v0.1", "v0.2-2026-06-15"). Bump on re-index. Live pack is the row with `is_active: true`; historical packs preserved for audit + rollback per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:168:          Provenance: "founder" (default tenant-onboarding rules), "tenant-admin" (added via Brain UI), "ifos-csm" (added during CSM intervention per master brief §10 CSM workflow).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:191:      Human edit to an agent's output captured at the point the consultant approves/edits/rejects a draft. Drives (a) the voice-drift-canary nightly cron, (b) future LoRA SFT pair generation per Ultraplan §6.1, (c) classifier retraining queue. Append-only per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.yaml:10:# Source: master brief §6 Day 6 line 490 (8 core entities)
docs/verticals/recruitment/vertical-schema.yaml:26:  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
docs/verticals/recruitment/vertical-schema.yaml:27:  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:36:#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
docs/verticals/recruitment/vertical-schema.yaml:216:      - IR35 classification is regulatory-bearing; v0.1 captures the field but T4 IR35 agent (v2.0 per master brief §9) is the canonical reasoner.
docs/verticals/recruitment/vertical-schema.yaml:223:      A company that hires through the recruitment agency. Master brief canonical vocabulary at §3.2 line 155 ("candidate, placement, brief") implicitly assumes client as the holder of briefs. Bullhorn calls this `ClientCorporation`.
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:289:      - (v1.1+) Inbound Triage — R+W expansion per master brief §9
docs/verticals/recruitment/vertical-schema.yaml:343:      A role being recruited for. Master brief canonical vocabulary uses `brief`; §6 Day 6 line 490 lists "Role/Brief" — `brief` is the canonical entity_type slug; `role` is documented alias. Bullhorn calls this `JobOrder`.
docs/verticals/recruitment/vertical-schema.yaml:537:      A contractor's weekly hours record. v2.0 entity — exercised by T2 Timesheet agent + T6 Pay & Bill agent per master brief §9. v0.1 captures placeholder shape only.
docs/verticals/recruitment/vertical-schema.yaml:822:    revisit_trigger: v1.1 Inbound Triage agent build per master brief §9 expands decision-authority modelling.
docs/verticals/recruitment/vertical-schema.yaml:829:    rationale: T2 + T6 builds are v2.0 per master brief §9; full schema requires pay/bill modelling not yet designed.
docs/verticals/recruitment/vertical-schema.yaml:896:    expected_date: post first-pilot operations (Q4 2026 if pilot lands per master brief §6 Day 7 question 1)
docs/verticals/recruitment/vertical-schema.yaml:901:    expected_date: 2027+ per master brief §9 build sequence
docs/RISK-REGISTER.md:4:the top. Full risk list is in master brief §12 and Ultraplan §10.
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:23:| 7 | **Master-brief-drift-accumulation** — eight ADR-driven edits + one Day-4 Postgres-rename + multiple Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all nine edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Codex ratifies the commit alongside the ten+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 + `bullhorn-integration-path.md` + `sequencing-target.md` + `brain-ui-scope.md` + Day 4 runbook §0.1. **Updated Day 4 (2026-05-17):** edit count rose from 8 to 9 with Day-4 Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations" — verified from Day-4 execution against NBG1 because FSN1 was unavailable at provisioning time). **Citation audit 2026-05-18:** earlier drafts also cited master brief §10.4 as a Hetzner/cost-target section; verified §10.4 is the Codex exclusion list ("What never goes through ratification") and contains no Hetzner or cost-target content. Edit 9 scope corrected to line 477 only. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:50:Full risk register per master brief §12 / Ultraplan §10. Port the remaining
docs/RISK-REGISTER.md:58:- 2026-05-16 (Day 1) — Risk #1 severity revised down (primitives 3 + 4 confirmed shipped and tested per `cortextos-primitive-status.md`; only primitive 1 carries Day-0 brittleness). Three new risks added (#5 renderer-not-built, #6 concurrency-doc-prereq, #7 master-brief-drift-accumulation) from Day-1 audit + design work.
docs/RISK-REGISTER.md:59:- 2026-05-16 (Day 1 evening extension) — Risk #5 severity revised from **Blocking** to **High** (ADR-003 + design doc Accepted; staged reductions to Medium and Low named). Risk #7 edit count revised from 3 to 5 (ADR-003 Edit C added). Day-0 quirk 3 (PATH conflict) updated: no longer a Week-1 risk — folds into renderer preamble responsibility per ADR-003 design §2.3. No new risks surfaced from renderer design work.
docs/RISK-REGISTER.md:60:- 2026-05-16 (Day 2) — Risk #2 status entry updated: Sub-decision C **Accepted** per `bullhorn-integration-path.md` §4 + §5; Sub-decisions A and B **Proposed** with named reduction triggers (Sunday/Monday commercial conversations). Two staged severity reductions specified (High → Medium on commercial answers; Medium → Low on first Week 3-4 Bullhorn write landing clean). Risk #7 edit count revised from 5 to 6 (Bullhorn decision §6.6 sixth edit added — master brief §6 Day 2 line 466 `service-account for dev` correction). No new risks surfaced from Day 2 — Sub-decisions A and B Proposed is the intended honest state pending commercial verification, not a new risk surface.
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:62:- 2026-05-16 (Day 3 evening) — **Risk #6 closed.** `docs/architecture/vault-concurrency.md` shipped (455 lines, reference document). 4 mechanisms specified with worked examples; 5 new `ESC_VAULT_*` codes consolidated for `_shared/hook-helpers.sh` Week-1 prereq wiring (`ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_VERSION_MISMATCH`, `ESC_VAULT_HUMAN_EDIT_BLOCKED`, `ESC_VAULT_CASCADE_PARTIAL_FAILURE`, `ESC_VAULT_CASCADE_TIMEOUT`). Risk #7 edit count unchanged at 8 — `vault-concurrency.md` is reference synthesis, surfaces no new master-brief drifts. Surfaces one new Day-4 tightening (`entities.version` column per §3.1) — Day 4 now has 4 consolidated tightenings.
docs/RISK-REGISTER.md:63:- 2026-05-17 (Day 4) — **Day 4 provisioning executed end-to-end against Hetzner Cloud NBG1 VPS (178.105.87.24).** All 9 runbook sections complete; §7 RLS isolation gate passed all 5 conditions (cross-tenant data access structurally impossible for `ifos_app` regardless of application bugs); 22 of 22 §9 automated checks passed. **Risk #7 edit count revised from 8 to 9** with new Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations"). **One new risk added (#8 LUKS manual unlock single-point-of-failure)** — Low probability, Medium-High impact, v1.2+ TPM/key-server mitigation path named. Two non-blocking operational items deferred to founder convenience: (a) Hetzner Console snapshot of `ifos-v2-prod-01`; (b) ifos_app password retrieval from `/vault/.ifos_app_password.tmp` → 1Password → temp file delete; (c) **high-priority** LUKS new-passphrase retrieval from `/root/.new_luks_passphrase.tmp` → 1Password → temp file delete (must be done before next reboot — old leaked passphrase already invalidated by Day-4 §11 rotation). Path B protocol gap (LUKS passphrase entered chat for `ifos-unlock` end-to-end test) closed via `cryptsetup luksChangeKey` rotation: OLD (leaked) rejected by `--test-passphrase`, NEW accepted; leaked passphrase in chat transcript is cryptographically invalid. v1.1 runbook revisions catalogued (8 items) for collection during Days 5-7. Codex Day-7 queue grows from 13 to 15 (Day 4 runbook + executed version).
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
docs/architecture/architecture-cohesion-review.md:5:**Method:** Read all 4 ADRs + 4 reference designs end-to-end as a coherent set. Walk each of the 4 boundaries from master brief §3 with adversarial questions. Identify gaps, contradictions, implicit assumptions.
docs/architecture/architecture-cohesion-review.md:58:| ADR-001 | bus mechanism (chokidar→FastChecker) | master brief §2.4 row 3 (Edit) | ✓ landed atomic `0e5b2b4` |
docs/architecture/architecture-cohesion-review.md:114:- **master brief §3.1 boundary 1** read-only submodule
docs/architecture/architecture-cohesion-review.md:155:| G9 | **The cortextOS `4 bus/kb-*.sh` shadow points override path.** Master brief §3.1 boundary 4 says ONLY these 4 files override. But: WHERE does the override land? `packages/brain/bus-overrides/`? It doesn't exist. | Medium (Brain UI v1.1+ dependency) | Brain UI Week-10 design ADR resolves. Currently no agent depends on this. |
docs/architecture/architecture-cohesion-review.md:162:## §7 — Per-boundary adversarial walk (master brief §3 boundaries)
docs/architecture/agent-bundle-renderer-design.md:6:**Prior work referenced:** master brief §8 (bundle spec); `docs/architecture/second-brain-design.md` §1.7 (R2 inheritance recommendation); `docs/architecture/cortexos-primitive-status.md` Primitive 1 (PTY/PM2 spawn mechanism).
docs/architecture/agent-bundle-renderer-design.md:17:Master brief §8 (lines 545-568) specifies the bundle verbatim:
docs/architecture/agent-bundle-renderer-design.md:43:| `agent.md` (line 552) | Output contract first; then workflow, gates, escalation. Master brief §1 Rule 1: "Every agent ships with its output contract written first, as a one-paragraph screenshot description." | the renderer (synthesises into `CLAUDE.md` per §2.1); humans for code review | **Static** — founder writes once; iterated per Codex ratification (master brief §10.5 names every new `agent.md` as always-ratify) |
docs/architecture/agent-bundle-renderer-design.md:45:| `tools.yaml` (line 554) | MCP servers + scopes + degraded modes for external execution backends (Bullhorn, Companies House, Microsoft Graph etc. per master brief §3.2 first-party MCP list) | the renderer (passes through to rendered agent dir); agent uses it via Claude Code's MCP loading at PTY spawn time | **Static** — founder writes once per agent |
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:48:| `tests/fixtures/01-primary/` (line 559) | Happy-path input.json + expected.md. The demo example. | CI fixture runner (master brief §8.3 line 628 "Test against fixtures"); not read at runtime | **Static** — author once, regenerate `expected.md` after intentional behaviour changes |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:54:- **§1.1-A:** master brief §8.1 names `validate.sh` and `context.sh` at the bundle root but does not specify the **invocation mechanism** — i.e. how does the agent invoke them from within its Claude Code session? Claude Code's hooks convention is `.claude/hooks/*.sh`; cortextOS templates don't use that path (they use `.claude/skills/` for skill scripts but not `.claude/hooks/` for lifecycle hooks). Recommended resolution in §2.1: render the two scripts to `.claude/hooks/` so they integrate with Claude Code's hook discovery; CLAUDE.md preamble (synthesised from agent.md per §2.1) references them by name.
docs/architecture/agent-bundle-renderer-design.md:55:- **§1.1-B:** master brief §8.1 mentions `_shared/hook-helpers.sh` and `_shared/voice-loader.sh` but does not specify where `_shared/` lives in the rendered output. The bundle's `validate.sh` and `context.sh` `source` these helpers — the renderer needs to materialise the path. Recommended resolution: place `_shared/` at `${projectRoot}/orgs/<org>/agents/_shared/` (one per org, symlinked into every agent dir's `.claude/hooks/_shared/`); rendered hook scripts source via `${CTX_AGENT_DIR}/.claude/hooks/_shared/<helper>.sh`.
docs/architecture/agent-bundle-renderer-design.md:97:The two layouts share no files by name except `tools.yaml` (which the IFOS bundle uses for MCP servers and which Claude Code consumes at PTY spawn). cortextOS expects `config.json` (runtime config), `CLAUDE.md` (Claude Code's entry point), `.env` (Telegram credentials + secrets); IFOS provides `config.schema.json` (a *schema* for per-tenant config, not the materialised config itself), `agent.md` (the output contract + workflow, not a Claude Code entry point), and no `.env` (credentials live per-tenant). The bundle's `validate.sh` and `context.sh` have no cortextOS analogue — they implement IFOS-side Gate A and context-assembly per master brief §8.1 Changes 1+2, and need a defined invocation mechanism (Spec gap §1.1-A). The bundle's `tests/fixtures/` are CI-only and have no runtime counterpart in cortextOS. **Translation is required for three of the six bundle files** (`agent.md` → `CLAUDE.md` with cortextOS-required preamble synthesised in; `config.schema.json` → `config.json` materialised with per-tenant values from `/vault/{tenant}/_config.yaml`; `validate.sh` + `context.sh` → rendered into a hook location the agent can invoke). `README.md` and `tools.yaml` pass through. Fixtures stay in the source repo.
docs/architecture/agent-bundle-renderer-design.md:115:| `agents/recruitment/<name>/tests/fixtures/{01-primary,02-edge-case-*,99-voice-drift-canary}/` | **Not rendered** | **Stays in source** | n/a | n/a — fixtures live in the IFOS repo at `agents/recruitment/<name>/tests/fixtures/`; CI fixture runner (master brief §8.3 line 628) reads them there; runtime does not need them |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:123:- **§2.1-A:** master brief §8.1 does not specify what the **cortextOS preamble template** looks like — the wrapper around `agent.md` that becomes `CLAUDE.md`. Recommended resolution: pin a canonical preamble at `packages/agent-renderer/templates/claude-md-preamble.md` (rendered with tenant + agent variables); preamble content must (a) tell Claude Code to source `.claude/hooks/context.sh` at session start, (b) tell Claude Code to call `.claude/hooks/validate.sh` before any tool invocation (Gate A), (c) list the env vars the agent should expect (`CTX_TENANT_SLUG`, `CTX_AGENT_NAME`, `CTX_ORCHESTRATOR_AGENT`, etc.), (d) reference `agent.md` body verbatim, (e) **not** reference IDENTITY.md / SOUL.md / MEMORY.md / GOALS.md / etc. because they will not exist. A draft preamble lives in §2.3 worked example below.
docs/architecture/agent-bundle-renderer-design.md:124:- **§2.1-B:** master brief §8.1 line 553 says `config.schema.json` extends "`common-*.json`" but doesn't say where the `common-*.json` shared schemas live. Recommended resolution: `packages/agents-runtime/_shared/common-{client, voice, notifications, vault, ats, accounting, target-patch}.json` per Ultraplan §5.3 line 357-364 enumeration. The renderer resolves `$ref` to these paths during schema materialisation.
docs/architecture/agent-bundle-renderer-design.md:134:- **Master brief §1 Rule 3 (Reuse before build)** — "Every agent uses `agents/_shared/` modules… No agent writes its own logging, voice handling, or approval gate." `_shared/` is the IFOS reuse surface. Inheriting a parallel reuse surface (cortextOS's `.claude/skills/`) creates two reuse vocabularies — confusing and error-prone.
docs/architecture/agent-bundle-renderer-design.md:135:- **Master brief §3.1 (submodule boundary stays intact)** — the §3.1 exception for the four `bus/kb-*.sh` shadow points is already a dead clause per ADR-002. Inheriting cortextOS skills would introduce a new implicit "shadow" — IFOS agents would carry skill documentation that points back into cortextOS's surface — undoing the cleanliness ADR-002 established.
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:143:| `approvals` | cortextOS's per-action approval-gate skill — agent creates an approval entry, blocks until human resolves via Telegram inline buttons | IFOS uses the same primitive 4 approval gates (cortextOS primitive — `src/bus/approval.ts`), but the approval *categories* and *escalation routing* are declared in `tools.yaml` + `agent.md` per master brief §3.2, not via inherited skill documentation |
docs/architecture/agent-bundle-renderer-design.md:153:**Spec gap §2.2-A:** master brief §8.1 doesn't specify the opt-in syntax in `tools.yaml`. Recommended resolution: add a top-level `cortextos_skills:` block in `tools.yaml` with a list of skill names. Example:
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:326:# Hydrate via context-assembly API per master brief §9
docs/architecture/agent-bundle-renderer-design.md:367:A non-zero exit from validate.sh blocks the action (Gate A; master brief §1 Rule 4).
docs/architecture/agent-bundle-renderer-design.md:369:Decision-log calls are mandatory per master brief §8.1 Change 2:
docs/architecture/agent-bundle-renderer-design.md:465:Rationale: matches existing IFOS package convention. Master brief §4.1 line 195-204 enumerates the operative package directories (`packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}/`); the renderer is a distinct concern (bundle → runtime translation) that doesn't belong inside any of those. It's not the brain (wiki content, per ADR-002), not the harness (read-only submodule per master brief §3.1), not agents-runtime/_shared/ (the shared helper *content*, not the *tooling* that materialises agents). Standalone `packages/agent-renderer/` keeps the surface clean.
docs/architecture/agent-bundle-renderer-design.md:477:- Brand new top-level dir — rejected for cohesion with master brief §4.1's existing `packages/` convention.
docs/architecture/agent-bundle-renderer-design.md:493:- **Daemon auto-renders on bundle change (filesystem watcher inside cortextOS daemon):** rejected because cortextOS daemon is read-only on the submodule (master brief §3.1), and adding render logic to the daemon would couple bundle synthesis to runtime supervision. Two concerns, one process — wrong.
docs/architecture/agent-bundle-renderer-design.md:503:(CLI name per ADR-004 Decision 1; earlier drafts of this design named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1. The corrected standalone `ifos-render-agent` Node binary ships from `packages/agent-renderer/package.json` `bin`.)
docs/architecture/agent-bundle-renderer-design.md:597:- **Merge with conflict markers:** rejected for v1.0. Renderer doesn't have a three-way-merge semantic (source bundle, last-render, current rendered output). Building it adds substantial complexity for a workflow nobody asked for; the master brief §1 Rule 1 ("output before architecture") favours the simple overwrite model.
docs/architecture/agent-bundle-renderer-design.md:622:The v1.0 minimum keeps the renderer's CLI surface small (one mode, two required args) and defers cross-tenant orchestration to bash. The Postgres `tenants` table dependency (v1.0 Day 4 per master brief §6) is what unblocks `--all-tenants`; until then there's no programmatic source of truth for "the list of active tenants."
docs/architecture/agent-bundle-renderer-design.md:636:**Recovery:** stderr lists the failed validation path (e.g. `properties.nurture_cadence.post_interview_chase_hours: expected integer, got string`). Founder edits `/vault/<tenant>/_config.yaml` or the `config.schema.json` source (rare; schema edits go through Codex ratification per master brief §10.5). Re-runs render.
docs/architecture/agent-bundle-renderer-design.md:702:New escalation code added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3:
docs/architecture/agent-bundle-renderer-design.md:764:| Postgres `decision_log` table live (per master brief §6 Day 4) | founder | Day 4 of Week 0 (already scheduled) |
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/agent-bundle-renderer-design.md:769:### 5.3 — Master brief edits authorised
docs/architecture/agent-bundle-renderer-design.md:773:**Edit A — Master brief §4.1 directory listing:**
docs/architecture/agent-bundle-renderer-design.md:775:**Current** (master brief §4.1 line 195-204): "Create the operative directory structure" followed by an `mkdir -p` command listing `packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}`.
docs/architecture/agent-bundle-renderer-design.md:785:**Edit B — Master brief §8.3 working pattern:**
docs/architecture/agent-bundle-renderer-design.md:787:**Current** (master brief §8.3 lines 614-630): the `bash` block showing the bundle authoring workflow ends with: "Test against fixtures; iterate; commit; PR; merge."
docs/architecture/agent-bundle-renderer-design.md:800:**Edit C — Master brief §8.1 add renderer reference:**
docs/architecture/agent-bundle-renderer-design.md:802:**Current** (master brief §8 lines 545-568): bundle file list with no reference to renderer.
docs/architecture/agent-bundle-renderer-design.md:820:**Master brief edits needed** (per §5.3 above):
docs/architecture/cortexos-kb-surface-investigation.md:12:Day-1 audit of cortextOS Primitive 3 (`docs/architecture/cortexos-primitive-status.md`) surfaced that master brief §3.4 names four shadow files (`kb-search.sh / kb-add.sh / kb-update.sh / kb-list.sh`) that **do not exist** at the verified SHA. The real files at `packages/harness/cortextos/bus/` are `kb-collections.sh / kb-ingest.sh / kb-query.sh / kb-setup.sh`.
docs/architecture/cortexos-kb-surface-investigation.md:14:Drafting ADR-002 began with the plan to read all four real files and pick one of three outcomes (full shadow / mixed shadow + new wrappers / abandon shadow). After reading **only `kb-setup.sh`**, the substrate of cortextOS's KB became clear, and that substrate is incompatible with the IFOS wiki data model in master brief §5. The ADR's scope is too narrow to absorb that finding — it would be designing the second brain inside an architectural decision record, on the side of an audit.
docs/architecture/cortexos-kb-surface-investigation.md:35:- **Per-instance isolation:** the KB root path includes `$CTX_INSTANCE_ID`, so IFOS's `ifos-v2` install and the personal install at `default` have **separate** KB indexes by construction. This is already correct against the master brief §3.1 submodule boundary.
docs/architecture/cortexos-kb-surface-investigation.md:83:**cortextOS's KB is a chunked-vector RAG store; the IFOS wiki in master brief §5 is an entity-document store. These data models do not compose without an adapter layer, and the adapter layer is large enough to be a design decision rather than a shadow-wrapper detail.**
docs/architecture/cortexos-kb-surface-investigation.md:88:- **IFOS wiki unit of storage:** one markdown file per entity (Candidate, Client, Brief, Placement…) with structured YAML frontmatter (`id / entity_type / tenant_id / created_at / updated_at / provenance / importance_score / linked_entities`) and `[[wiki-link]]` references in body — per master brief §5.2 example at lines 357-369. The natural read pattern is "give me the canonical page for this entity, plus its backlinks".
docs/architecture/cortexos-kb-surface-investigation.md:97:  - **Indexing of ingested raw email/transcript chunks** (master brief §5.1 `raw/` directory tree). The chunked-vector model fits the "raw inbox-emails / calls / briefs" surface well; it only stops fitting at the `compiled/` entity-document boundary.
docs/architecture/cortexos-kb-surface-investigation.md:98:- **What this means for §3.4:** the master brief calls the seam between cortextOS and IFOS "the four `bus/kb-*.sh` shadow points." That framing assumed the same data model on both sides of the seam. With the substrate now known, the seam is not a four-file shadow but a much smaller boundary — to be defined in the second-brain design.
docs/architecture/cortexos-primitive-status.md:7:**Method:** read code under `src/daemon/`, `src/pty/`, `src/bus/`, `src/telegram/`, `src/cli/`; cross-reference with `README.md`, `CHANGELOG.md`, `CRONS_MIGRATION_GUIDE.md`, `templates/{orchestrator,analyst,agent,m2c1-worker,agent-codex}/`; line-cite `tests/unit/**` and `tests/integration/**`; cross-check Day-0 findings in `.agents/learnings/00-cortextos-quirks.md`; classify per the four-status scheme from master brief §6 Day 1.
docs/architecture/cortexos-primitive-status.md:9:Two findings need founder review before the Day 7 single-sentence test (master brief §6 / Ultraplan §12). Both are master-brief drifts against the verified SHA, surfaced in Primitive 3:
docs/architecture/cortexos-primitive-status.md:11:1. **No `chokidar` watcher in the bus** — master brief §2.4 row 3 says "bus/ shell wrappers + chokidar watcher in daemon", but the bus is poll-based (`FastChecker` default 1000ms). `chokidar` is only used by the dashboard's UI file-feed.
docs/architecture/cortexos-primitive-status.md:12:2. **The four `bus/kb-*.sh` files we plan to shadow have different names than the master brief states.** Master brief §3.4 names `kb-search.sh / kb-add.sh / kb-update.sh / kb-list.sh`. The actual files at SHA `c21fbfe` are `kb-collections.sh / kb-ingest.sh / kb-query.sh / kb-setup.sh`. The brain-replacement seam (§3.4 + §5) needs reconciliation before Codex ratification.
docs/architecture/cortexos-primitive-status.md:36:**Master-brief description:** `node-pty` + `ecosystem.config.js` regen via `cortextos ecosystem`; agents run as PM2-managed PTY processes that auto-restart on crash or after the 71-hour context rotation (master brief §2.4 row 1).
docs/architecture/cortexos-primitive-status.md:61:- Master brief §2.4 row 1: used by Triage, Concierge, Pulse, Watchtower, Cash Conductor.
docs/architecture/cortexos-primitive-status.md:97:**Master-brief description:** The daemon auto-restarts a session before the context limit; pre-rotation hook checkpoints state to vault (master brief §2.4 row 2).
docs/architecture/cortexos-primitive-status.md:120:- Master brief §2.4 row 2: Concierge (cross-week candidate conversations), Watchtower (per-contractor state), Pulse (multi-source watching).
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:157:**Master-brief description:** `bus/` shell wrappers + `chokidar` watcher in the daemon; agents drop typed files for inter-agent handoff (master brief §2.4 row 3).
docs/architecture/cortexos-primitive-status.md:182:1. **No `chokidar` watcher in the bus.** The bus is poll-based, not push-based. `grep -rn chokidar src/` returns zero hits; `chokidar@^5.0.0` in `package.json:47` is used only by `dashboard/src/lib/watcher.ts:5` for the dashboard UI's file change feed, not for inter-agent message delivery. Master brief §2.4 row 3's "chokidar watcher in daemon" is incorrect against the verified SHA. The actual dispatcher is `FastChecker` polling at `pollInterval` (default 1000ms, configurable). Operational impact: message-delivery latency is bounded by the poll interval, not zero-latency event-driven; relevant for the Brief Decoder → Sourcing Scout → Concierge "four-agent pipelines complete in seconds" claim (Ultraplan §3.2). With 1s polling per hop and 3 hops, end-to-end is ≥3s, not sub-second.
docs/architecture/cortexos-primitive-status.md:184:2. **The four `kb-*.sh` files we plan to shadow have different names than the master brief states.** Master brief §3.4 lists `kb-search.sh`, `kb-add.sh`, `kb-update.sh`, `kb-list.sh`. The actual files at `packages/harness/cortextos/bus/` are `kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`. This is the brain-replacement seam — the master brief's named files do not exist at SHA `c21fbfe`. Either the brief was written against a different cortextOS version, or the four shadow points need to be revised. This is a Day-7 Codex-ratification-blocking discrepancy.
docs/architecture/cortexos-primitive-status.md:188:- Master brief §2.4 row 3: "Our agents drop typed files into the bus; we override `kb-*` to point at the wiki". §3.4 brain-replacement boundary is built on these shadow points.
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:228:**Master-brief description:** Daemon enforces explicit approval before external action; `manualFireDisabled` flag on crons; standing authorisations per agent (master brief §2.4 row 4).
docs/architecture/cortexos-primitive-status.md:255:- Master brief §2.4 row 4 + §3.4 + Product Spec §6.1 row 4: every agent that auto-sends. Triage, Concierge, Cash Conductor, Competitor Interception, Spec Pitcher, T1 Onboarding Concierge — all depend on the approval gate to graduate from drafts-only.
docs/architecture/cortexos-primitive-status.md:292:**Master-brief description:** Bot per agent, `.env` carries `BOT_TOKEN / CHAT_ID / ALLOWED_USER`; the escalation path for every Tier-1 agent (master brief §2.4 row 5).
docs/architecture/cortexos-primitive-status.md:324:- Master brief §2.4 row 5: every Tier-1 agent's escalation path. Triage, Concierge, Cash Conductor, Pulse, Watchtower, Brief Decoder, Competitor Interception, Night Sourcer, T5, Timesheet Ranger — they all escalate via Telegram and approve via Telegram inline buttons.
docs/architecture/cortexos-primitive-status.md:366:**Master-brief description:** Analyst-template agents schedule overnight experiments, evaluate results, surface findings for review (master brief §2.4 row 6).
docs/architecture/cortexos-primitive-status.md:388:- Master brief §2.4 row 6: Night Sourcer + Spec Pitcher (Product Spec R4 + R11).
docs/architecture/cortexos-primitive-status.md:430:**Master-brief description:** Orchestrator template + file-bus handoff contract; supervisor agent watches the others, escalates jams, balances load (master brief §2.4 row 7).
docs/architecture/cortexos-primitive-status.md:455:- Master brief §2.4 row 7: Brief Decoder's 4-agent pipeline; T5 Supply Chain Auditor's daily recalc.
docs/architecture/cortexos-primitive-status.md:504:- **Day-7 spec drifts for Codex ratification:** the chokidar mention in master brief §2.4 row 3 and the four `kb-*.sh` filenames in master brief §3.4 do not match the verified SHA. Both need a one-line correction or a §3.4 re-scoping decision.
docs/architecture/cortexos-primitive-status.md:505:- **Standing authorisations** (master brief §2.4 row 4) are not a cortextOS primitive at this SHA. We build them in our layer — confirm scope in the Day 5 auto-send safety policy artefact.
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/architecture/vault-concurrency.md:427:### Bucket 2 — Master brief edits needed
docs/architecture/second-brain-design.md:14:The goal: confirm what cortextOS uses its own KB for, so we know what we are deliberately leaving alone — and verify the master brief §3.1 submodule boundary is not in tension with the plan in Q3.
docs/architecture/second-brain-design.md:52:**IFOS agents do not run cortextOS's heartbeat-memory pattern.** The IFOS Agent Bundle v2 (master brief §8.1) specifies six files per agent:
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:76:- This respects master brief §3.1 ("never edit `packages/harness/cortextos/*` except the four `bus/kb-*.sh` shadow points") without exercising the exception — we don't shadow them at all.
docs/architecture/second-brain-design.md:110:**But IFOS Agent Bundle v2 is a different shape.** Master brief §8.1 specifies six files plus three fixture directories:
docs/architecture/second-brain-design.md:123:No `CLAUDE.md`, no `AGENTS.md`, no `MEMORY.md`, no `.claude/skills/` tree. The bundle lives at `${repo}/agents/recruitment/<name>/` (in the IFOS repo, not under cortextOS's `orgs/<org>/agents/`). Master brief §8.3 shows the working pattern is hand-`mkdir` of this layout in Claude Code, not `cortextos-ifos add-agent`.
docs/architecture/second-brain-design.md:125:**The spec gap.** The cortextOS daemon's `AgentManager.discoverAndStart()` (Primitive 1 evidence, `src/daemon/agent-manager.ts:47-78`) bootstraps agents from `${projectRoot}/orgs/<org>/agents/<name>/` with a cortextOS-shaped layout (`config.json`, `.env`, `CLAUDE.md` or `AGENTS.md`, etc.). The IFOS Agent Bundle v2 lives at a different path with a different shape. **Master brief §8 does not specify how the v2 bundle becomes a runnable cortextOS agent.** There is no "renderer" that translates the bundle into a cortextOS-compatible directory. This is a real spec gap and goes in the "Spec gaps surfaced" section at the end of this design.
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:136:1. **It honours the §3.1 boundary cleanly.** The §3.1 exception in master brief is "the four `bus/kb-*.sh` shadow points." If we don't shadow them (per §1.5), inheriting skills that call them invites confusion — the inherited skills point at cortextOS's KB, and we'd need to remember that IFOS-owned agents must not invoke them. R2 removes the question entirely.
docs/architecture/second-brain-design.md:137:2. **It matches the Rule 3 vocabulary.** Master brief §1 Rule 3 is "Reuse before build" — every agent uses `agents/_shared/` modules. R2 makes `_shared/` the only shared surface; the 24 inherited cortextOS skills would be a parallel shared surface in tension with the IFOS one.
docs/architecture/second-brain-design.md:140:**Until the renderer is built** (Week 0 has no agent code per master brief §6 Day 7; the renderer is a Week 1+ concern), the inherited-skills risk only matters for any debug/probe agents scaffolded via `cortextos-ifos add-agent` during Week 0 verification. Those probe agents will inherit the kb-* calls and write to cortextOS's KB — which is fine, because cortextOS's KB stays in place per §1.5.
docs/architecture/second-brain-design.md:154:Two source documents touch on vault structure. Master brief §5.1 (lines 297-349) and Ultraplan §5.1 (line 220) **disagree** — flagged as **Spec gap 2.1-A** in the final section. Master brief wins per §0; this design merges the two so nothing is lost.
docs/architecture/second-brain-design.md:161:/vault/{tenant-slug}/                               ← path per master brief §3.3 line 217, Ultraplan §5.1 line 217
docs/architecture/second-brain-design.md:163:│   ├── style-guide.md                              ← master brief §5.5 footnote, Ultraplan §5.2 wizard Day 3
docs/architecture/second-brain-design.md:169:├── wiki/                                           ← the second brain (master brief §5.1 line 306)
docs/architecture/second-brain-design.md:170:│   ├── raw/                                        ← append-only ingestion (master brief §5.1 lines 316-321)
docs/architecture/second-brain-design.md:171:│   │   ├── inbox-emails/                           ← from email ingestion (master brief §5.1 line 317)
docs/architecture/second-brain-design.md:172:│   │   ├── calls/                                  ← Fathom/Fireflies transcripts (master brief §5.1 line 318)
docs/architecture/second-brain-design.md:173:│   │   ├── briefs/                                 ← inbound brief detection (master brief §5.1 line 319)
docs/architecture/second-brain-design.md:174:│   │   ├── notes/                                  ← freeform consultant notes (master brief §5.1 line 320)
docs/architecture/second-brain-design.md:175:│   │   └── ats-snapshots/                          ← Bullhorn entity snapshots (master brief §5.1 line 321)
docs/architecture/second-brain-design.md:176:│   ├── compiled/                                   ← LLM-owned, agent-managed (master brief §5.1 line 323)
docs/architecture/second-brain-design.md:177:│   │   ├── index.md                                ← master index, one-line per page (master brief §5.1 line 324)
docs/architecture/second-brain-design.md:178:│   │   ├── candidates/                             ← one .md per Candidate (master brief §5.1 line 325)
docs/architecture/second-brain-design.md:179:│   │   ├── clients/                                ← one .md per Client (master brief §5.1 line 326)
docs/architecture/second-brain-design.md:180:│   │   ├── briefs/                                 ← one .md per Brief (master brief §5.1 line 327)
docs/architecture/second-brain-design.md:181:│   │   ├── placements/                             ← one .md per Placement (master brief §5.1 line 328)
docs/architecture/second-brain-design.md:182:│   │   ├── people/                                 ← Contacts at clients (master brief §5.1 line 329)
docs/architecture/second-brain-design.md:183:│   │   ├── concepts/                               ← firm domain concepts (master brief §5.1 line 330) — v1.2+ deferred
docs/architecture/second-brain-design.md:185:│   │   └── archive/                                ← absorbed/deleted pages (master brief §5.1 line 332)
docs/architecture/second-brain-design.md:186:│   └── .wiki/                                      ← compilation state (master brief §5.1 line 334)
docs/architecture/second-brain-design.md:187:│       ├── manifest.json                           ← per-raw-file compilation status (master brief §5.1 line 335)
docs/architecture/second-brain-design.md:188:│       ├── reflect-state.json                      ← reflect cycle state (master brief §5.1 line 336)
docs/architecture/second-brain-design.md:189:│       └── graph.json                              ← cached graph for fast UI loads (master brief §5.1 line 337) — v1.2 graph view
docs/architecture/second-brain-design.md:227:Eight canonical entities exist per master brief §6 Day 6 / Ultraplan §11 Day 6 line 490:
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:246:**Frontmatter schema** (master brief §5.2 lines 357-369 starting example; extended for v1.0 completeness):
docs/architecture/second-brain-design.md:389:Master brief §5.2 line 367 and §5.4 line 412 both use the display-name format:
docs/architecture/second-brain-design.md:394:**Decision: adopt `[[Entity-Type: Display Name]]` verbatim** as master brief specifies. Rationale: matches master brief decision, Obsidian-compatible, human-readable in raw markdown. Cost: rename safety is fragile — renaming "Sarah Bowen" to "Sarah Bowen-Smith" breaks all links unless an explicit rewrite step runs.
docs/architecture/second-brain-design.md:398:**Spec gap 2.2-A:** master brief §5 does not specify the rewrite-backlinks mechanism. Recommended resolution: implement as part of `update-entity` in `packages/brain/wiki/lib/update.ts` v1.0.
docs/architecture/second-brain-design.md:402:Master brief §5.1 lines 325-332 shows directories like `candidates/` but does not specify filename format. **Spec gap 2.2-B.**
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:432:| `delete-entity` | any agent + human override; soft via `archive/` move | **v1.2+ deferred** | `(id: str, mode: 'soft'\|'hard', tenant_id: str)` | `EntityRef` (with `status: archived`) | few seconds | Master brief §5.1 line 332 implies soft via archive/; hard delete is GDPR-driven (Ultraplan §5.5 line 275 day-60 cryptographic erase) but operates at tenant level, not entity level |
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:437:- Graph multi-hop traversal — v1.2 graph view (master brief §5.5 line 423)
docs/architecture/second-brain-design.md:438:- Wiki health reflect (orphan detection, contradiction detection) — v1.1 (master brief §5.2 lines 371)
docs/architecture/second-brain-design.md:439:- Per-firm LoRA query — v2.0 (master brief §5.5 line 424)
docs/architecture/second-brain-design.md:456:- **Obsidian compatibility:** frontmatter restricted to YAML 1.2 features Obsidian's `gray-matter` parser accepts — strings, ints, floats, ISO 8601 strings, flow-style and block-style sequences, flow-style and block-style mappings (one level of nesting only). **No anchors, no aliases, no merge keys, no custom tags.** Wiki-links in body use Obsidian's `[[Display Name]]` and `[[Type: Display Name]]` syntax — both render. Frontmatter `linked_entities` is a list of strings that *look like* wiki-links; Obsidian doesn't render frontmatter strings as links by default, but the master brief §5.2 example uses this form and we adopt it.
docs/architecture/second-brain-design.md:459:  - **Git:** **Spec gap 2.4-A.** Neither master brief nor Ultraplan specifies whether `/vault/{tenant}/` is also a git repo. Obsidian users typically git-init their vaults. **Recommendation:** yes — initialize `/vault/{tenant}/.git/` at tenant provisioning (Ultraplan §5.5 step 2). Founder gets free history, blame, and rollback via Obsidian Git plugin. Agents do NOT commit; the founder commits manually or via a scheduled cron run by Janitor's nightly sweep. **Blocks v1.0 build:** no — git init is one line in `provision-tenant.sh`; commit cadence can be decided in Week 1.
docs/architecture/second-brain-design.md:465:**Table: `tenants`** (master brief §3.3 + Ultraplan §5.1)
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:569:**Spec gap 2.4-B:** Ultraplan §5.1 line 227 groups entity index + adjacency under "`entity_graph`". This design splits them into `entities` + `entity_links` for clearer indexing semantics. **Recommended resolution:** adopt the split; update master brief §3.3 or Ultraplan §5.1 to reflect the two-table model. Codex-ratifiable on Day 7 by reading this section.
docs/architecture/second-brain-design.md:602:3. **Master brief is silent on model choice** (Spec gap 2.4-C, recommended resolution: adopt gemini-embedding-001; revisit if Anthropic or OpenAI ships a sharply better embedding model before Week 11).
docs/architecture/second-brain-design.md:672:| `search-by-name` | Postgres `entities` trigram on `display_name` (`gin_trgm_ops`) | Filesystem grep over `wiki/compiled/{type}/*.md` frontmatter | Hot path; sub-second target. Fuzzy match returns top-N by similarity score; tie-break by `importance_score DESC` then `updated_at DESC`. Fallback only fires if Postgres unhealthy (per master brief §3.5 RLS / Ultraplan §3.5 degraded-mode contingency). |
docs/architecture/second-brain-design.md:692:Master brief §5 is silent on concurrency. This entire section is a recommended default with one spec gap (**Spec gap 2.6**) covering all three scenarios.
docs/architecture/second-brain-design.md:701:- If the file lock times out (5 seconds), the operation fails with `ESC_VAULT_LOCK_TIMEOUT` per master brief §8.1 Change 3 vocabulary (new code; goes in `_shared/escalation-codes.md` v0.1).
docs/architecture/second-brain-design.md:727:**Spec gap 2.6:** none of this is in the master brief. **Recommended resolution:** adopt the mechanism above verbatim; document in a `docs/architecture/vault-concurrency.md` companion file in Week 1 (before agent code starts). **Blocks v1.0 build:** no — concurrency code is a v1.0 build artefact, not a Week 0 prerequisite, but the design needs to land before the first multi-agent test in week 5.
docs/architecture/second-brain-design.md:747:**Why not atomic across all files:** filesystems aren't transactional across files. Atomic-by-emulation (write all to `.tmp` then rename all) is brittle and doesn't compose with `flock`. Eventually-consistent with Postgres-as-truth is the realistic choice and matches master brief §3.3's "Postgres is the source of truth for state and provenance."
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:890:| **Multi-tenancy enforcement** — how `tenant_slug` is validated at the entry point (master brief §3.5) | Wrapper reads `CTX_TENANT_SLUG` env var (set by PM2 ecosystem per-tenant process group); CLI handler validates that the arg `--tenant` matches the env or fails with `ESC_PII_LEAKAGE_RISK`. Kernel-enforced isolation underneath (POSIX 0700 per Ultraplan §5.1) means a wrong tenant fails at filesystem read. | Server receives `CTX_TENANT_SLUG` at connection setup via MCP server args; rejects any tool call whose `tenant_slug` mismatches the connection identity. Filesystem isolation underneath same as α. One enforcement site. | Library validates `tenant_slug` against env var. Same enforcement model as α, but agent-side discipline depends on skill docs being followed. |
docs/architecture/second-brain-design.md:892:| **Agent ergonomics** — what `tools.yaml` / `agent.md` looks like | `agent.md` references wiki ops as bus commands: `cortextos-ifos bus wiki-search "..."`. No `tools.yaml` entry needed (bus commands are implicit). Pattern is identical to how `bus send-message`, `bus create-task` already work in cortextOS. | `tools.yaml` has a dedicated `mcp_servers.wiki` block + tool list (sketched in §3.1). Adds a section per agent. Aligns with how vertical-adapter MCP connectors work in master brief §3.2. | `agent.md` would have to reference the skill explicitly (e.g. "When you need to query the wiki, invoke `.claude/skills/wiki/SKILL.md`"). Under R2, agents don't have a `.claude/skills/` tree, so the agent.md has to describe a one-off invocation pattern. Awkward. |
docs/architecture/second-brain-design.md:893:| **Consistency with cortextOS bus convention** | Identical pattern: 47 existing bus wrappers under `packages/harness/cortextos/bus/` all do `exec node dist/cli.js bus <command>`. Option α uses the same 3-line shim shape. Zero cognitive tax for an engineer who already understands cortextOS. | New surface (MCP). Aligns with the vertical-adapter pattern (master brief §3.2) where Bullhorn / Companies House etc. are MCP servers — so consistent with that pattern, not with the bus pattern. | Aligns with cortextOS's skill convention (each template ships `.claude/skills/` with kb / memory / tasks / heartbeat / etc.). Inconsistent with the bus pattern; consistent with the skill pattern; awkward under R2. |
docs/architecture/second-brain-design.md:896:| **Lock-in cost** — how hard to switch to a different option later | Low. Wrappers are 3-line shims; replace with calls to a different backend (MCP server, library) by changing the `exec` line. Library is reusable. Agents see the same `cortextos-ifos bus wiki-search` invocation regardless of backend — interface stable. | Medium. Agents have MCP `tools.yaml` entries committed; migration to α means rewriting `agent.md` and `tools.yaml` for every agent (18 in full strength per master brief §0). Library is reusable. | High. Skill-installation path is per-agent; migration requires per-agent skill removal + new wrapper/MCP declaration. Also under R2 the original installation path was a hack, which makes "switch away from γ" the cleanup of that hack. |
docs/architecture/second-brain-design.md:904:**Rationale anchored to three master brief sections:**
docs/architecture/second-brain-design.md:906:1. **Master brief §3.1 (submodule boundary).** The §3.1 exception is "shadow four `bus/kb-*.sh` points." Per Q1.5 we don't shadow those — but the **pattern** §3.1 authorises (parallel `bus-overrides/` directory housing shell wrappers that match cortextOS's bus convention) is exactly what Option α uses. We use the boundary's *vocabulary* without exercising its kb-* exception. Option β would require introducing a new vertical surface (MCP server alongside daemon and dashboard) that §3.1 doesn't anticipate. Option γ would require modifying the renderer's skill-installation path, contradicting §1.7's R2 recommendation.
docs/architecture/second-brain-design.md:907:2. **Master brief §8 (Agent Bundle v2 pattern + `tools.yaml` contract).** §8.1 specifies the bundle has `tools.yaml` for "MCP servers + scopes + degraded modes" — i.e. external MCP connectors (Bullhorn, Companies House, Xero). The wiki is **internal** to IFOS, not an external execution backend. Treating wiki ops as bus commands (Option α) keeps `tools.yaml` clean of internal-surface declarations; treating them as MCP tools (Option β) conflates internal-data-access with external-tool-invocation in the same `tools.yaml`.
docs/architecture/second-brain-design.md:908:3. **Master brief §3.5 + §5.5 (multi-tenancy + onboarding wizard 5-day flow).** §3.5's "100 customers by end of 2027" stress test (Product Spec §5.4) demands zero per-customer operational drag. Option α adds no per-customer infrastructure. Option β at Sovereign tier (Ultraplan §5.4 per-tenant cluster slice) means one `ifos-wiki-mcp` process per Sovereign tenant — a new operational surface to monitor at scale.
docs/architecture/second-brain-design.md:920:- **v1.2 graph view (master brief §5.5):** add `wiki-graph-traverse.sh` and a `graphify` subcommand. Surface grows by N scripts, not by architecture.
docs/architecture/second-brain-design.md:921:- **v2.0 LoRA scale (master brief §5.5):** the LoRA pipeline operates on the `decision_log` table, not on the wiki. Wiki ops from LoRA-enhanced agents are unchanged. Both options work.
docs/architecture/second-brain-design.md:924:**v1.0 build day estimate for Option α: 11-13 days.** Fits master brief §5.5's weeks 11-13 allocation. Detail in §3.4 below.
docs/architecture/second-brain-design.md:926:### 3.4 — Impact on master brief §5.5 build sequence
docs/architecture/second-brain-design.md:928:Master brief §5.5 currently says (lines 416-420):
docs/architecture/second-brain-design.md:934:| Master brief §5.5 wording (current) | Proposed wording (post-design) |
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:950:3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
docs/architecture/second-brain-design.md:956:- **Scope:** larger than master brief §5.5 currently states (9 ops + 4 Postgres tables + concurrency machinery, vs. the original "2 ts files"). Still fits the 11-13 day budget because the bulk of the surface area is small Postgres operations with thin shell wrappers; the heavy code is in `concurrency.ts` and `update.ts` which together are ~400-600 lines.
docs/architecture/second-brain-design.md:958:- **Earlier work needed:** Postgres schema and the entity_graph→entities+entity_links rename move to Week 0 Day 4 (this week, already planned per master brief §6).
docs/architecture/second-brain-design.md:966:| **§1.7-A** | Master brief §8 silent on renderer | No mechanism for translating the IFOS Agent Bundle v2 layout (`${repo}/agents/recruitment/<name>/`) into the cortextOS-shaped per-agent directory the daemon reads from (`${projectRoot}/orgs/<org>/agents/<name>/`) | ADR-003 in Week 1 + companion `docs/architecture/agent-bundle-renderer-design.md`. Adopt R2 (bundle-only, no `.claude/skills/` tree). | **Yes** — without it, no IFOS agent can run. Week 1 prerequisite. |
docs/architecture/second-brain-design.md:967:| **2.1-A** | Master brief §5.1 lines 297-349 vs Ultraplan §5.1 line 220 disagree on vault layout | Two vault structures specified in different docs | Adopt the merged tree in §2.1 of this design: `/vault/{slug}/` top-level (`_voice/ _playbooks/ _decisions/ _config.yaml wiki/ temp/`) with the master brief's `wiki/{raw,compiled,.wiki}/` subtree underneath. Codex ratifies on Day 7 by reading §2.1. | No |
docs/architecture/second-brain-design.md:969:| **2.1-C** | `wiki/compiled/playbooks/` (master brief §5.1 line 331) collides with `/vault/{tenant}/_playbooks/` (Ultraplan §5.1) | Same folder name at two paths with different intended uses | **Recommendation:** drop `wiki/compiled/playbooks/`. Playbooks live at `/vault/{tenant}/_playbooks/` only. Update master brief §5.1 to remove the `playbooks/` line from the `wiki/compiled/` tree. | No |
docs/architecture/second-brain-design.md:970:| **2.2-A** | Master brief §5 silent on rename safety | No mechanism for keeping wiki-links stable when an entity's display_name changes | Resolved in §2.6.3: `update-entity` triggers eventually-consistent `rewrite-backlinks` cascade with Postgres as truth, per-file optimistic concurrency. Documented in companion vault-concurrency.md. | No |
docs/architecture/second-brain-design.md:971:| **2.2-B** | Master brief §5.1 lines 325-332 silent on filename format under each directory | No file-naming convention specified | Resolved in §2.2.7: `{slug}.md` where slug = id minus entity-type prefix; numeric suffix for collisions. | No |
docs/architecture/second-brain-design.md:972:| **2.4-A** | Master brief / Ultraplan silent on git for tenant vault | No backup-via-git mechanism specified | `git init` at tenant provisioning (`provision-tenant.sh` Ultraplan §5.5 step 2). Founder commits via Obsidian Git plugin; agents don't commit. | No — commit cadence can be decided Week 1+. |
docs/architecture/second-brain-design.md:973:| **2.4-B** | Ultraplan §5.1 line 227 groups entity index + adjacency under "`entity_graph`" | Single-table model insufficient for the JSONB GIN + trigram + adjacency mix v1.0 needs | Split into `entities` + `entity_links` per §2.4.2. Update master brief §3.3 / Ultraplan §5.1 wording. **Roll into Week 0 Day 4 Postgres provisioning.** | **Tight** — Day 4 of Week 0 (this week). |
docs/architecture/second-brain-design.md:974:| **2.4-C** | Master brief / Ultraplan silent on embedding model | No model specified for voice_samples_embedded or future compiled/ embeddings | Adopt `gemini-embedding-001` (3072 dims) — matches cortextOS's KB substrate per kb-setup.sh migration target. Same `GEMINI_API_KEY` serves both. Revisit if a sharply better model ships before Week 11. | No |
docs/architecture/second-brain-design.md:975:| **2.6** | Master brief §5 silent on concurrency | No mechanism for agent×agent, agent×human-in-Obsidian, or rewrite-backlinks cascade | Resolved in §2.6.1, §2.6.2, §2.6.3 of this design. Companion document `docs/architecture/vault-concurrency.md` LANDED (Day 3, commit `78680cc`). New escalation codes (`ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_CONCURRENCY`, `ESC_HUMAN_EDITING_LOCK`, `ESC_VAULT_RENAME_RACE`) CATALOGUED at `agents/_shared/escalation-codes.md` §2.2 (Day 8 commit `a279226`) + WIRED into `agents/_shared/hook-helpers.sh::autosend_escalate` (Day 8 commit `e6e9df1`). | **Closed 2026-05-20.** Catalogue + wiring complete; ESC codes callable from any rendered agent. |
docs/architecture/second-brain-design.md:976:| **3.4-A** | Master brief §5.5 (lines 416-420) v1.0 brain wording | Says "shadow four files" — incorrect per Q1.5 | Rewrite per §3.4 of this design: "9 `wiki-*.sh` parallel wrappers + Postgres entities/entity_links/decision_log + pgvector voice." Bundles with ADR-002 atomic correction commit. | No — wording change, not work change. |
docs/architecture/second-brain-design.md:977:| **3.4-B** | Master brief §6 Day 4 (line 478) Postgres table list | Lists `entity_graph` as a single table | Update wording: "`tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`." Bundles with Day 4 provisioning. | **Tight** — Day 4 of Week 0 (this week). |
docs/architecture/second-brain-design.md:981:## Impact on master brief §5.5 build sequence — closing paragraph
docs/architecture/second-brain-design.md:983:**Master brief §5.5's v1.0 minimum brain build stays at weeks 11-13, but the scope is materially clarified.** The "shadow four files + 2 .ts files" framing is replaced by "9 wiki-*.sh parallel wrappers + 9 wiki/lib/*.ts modules + 4 Postgres tables with RLS + pgvector for voice samples." Total v1.0 effort: ~11-13 person-days, fitting the 15-day budget. **Three Week-1 prerequisites move into focus:** ADR-003 renderer design (without it, no IFOS agent can run), `vault-concurrency.md` companion document (without it, the `flock`+Postgres-optimistic-concurrency code can't be reviewed), and `agents/_shared/{voice-loader,hook-helpers}.sh` (without these, the wiki library has no calling conventions). **One Day-4 (this week) tightening:** the Postgres schema migration from `entity_graph` (single table) to `entities` + `entity_links` (two tables) is part of the master brief §6 Day 4 infra task, not deferred. v1.2 graph view and v2.0 LoRA scale-tier are forward-compatible under the chosen Option α with no architectural changes.
docs/operations/w4-bilateral-pass-6-agent-md.md:236:5. **Status semantics** (Sourcing Scout #2) — confirm with founder: "Ratified at Round-N" is not "Accepted"; Accepted requires bundle completion. Likely a one-line clarification in the agent-bundle skill or master brief §8 to prevent this drift in future agents.
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-option-c-diagnostic-end-to-end.md:297:| **Master plan citations** | Every architectural decision cites master brief / ULTRAPLAN line numbers | grep diff for citation strings |
docs/operations/codex-round-2-handoff.md:104:| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | `review-architecture-decision` | **Recursive ratification per master brief §10.5.** Codex either RATIFIES the disagreement (D5 was correct) OR REJECTS (insists on strict skill). Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:200:ratification per master brief §10.5. Decide whether Claude's counter-argument
docs/operations/codex-round-2-handoff.md:292:Hard ceiling: 2 round-trips (master brief §10.3 step 5). After Round 2, no Round 3 — escalate to founder for explicit decision.
docs/operations/codex-round-2-handoff.md:332:Any Round-2 REJECTED items get their own row in the manifest queue updated to "REJECTED→ROUND-3-pending OR founder-escalated". Per §10.3 master brief: no Round 3 until founder decides.
docs/operations/codex-round-2-handoff.md:373:Per master brief §10.6 + execution plan §5:
docs/operations/codex-round-2-handoff.md:406:Manifest queue position: this protocol document itself joins the queue as a Round-3 candidate (recursive ratification per master brief §10.5).
docs/build-brief/00-MASTER-BRIEF.md:15:If anything in `docs/build-pack/` conflicts with this brief, **this brief wins**. The build pack stays in-tree as historical record; the master brief is operative.
docs/build-brief/00-MASTER-BRIEF.md:238:git commit -m "chore: reconcile scaffold against master brief; vendor cortextos@${HARNESS_SHA:0:7}"
docs/build-brief/00-MASTER-BRIEF.md:260:git commit -m "docs: import authoritative specs + master brief"
docs/build-brief/00-MASTER-BRIEF.md:831:| "Let me skip the Codex ratification — it's a small change..." | §10.5 |
docs/build-brief/00-MASTER-BRIEF.md:852:Drop this verbatim at `~/code/CortexOS/CLAUDE.md`. It supersedes the existing CLAUDE.md (which keeps the path table and red lines, but defers all build-pack references to this master brief).
docs/build-brief/00-MASTER-BRIEF.md:865:## Master brief
docs/build-brief/00-MASTER-BRIEF.md:867:start. The build pack at `docs/_archive-build-pack/` is historical; the master brief wins on
docs/build-brief/00-MASTER-BRIEF.md:907:merge. See master brief §10.
docs/build-brief/00-MASTER-BRIEF.md:910:1. Read this file, then master brief §1, §3, §6, §8, §10
docs/build-brief/00-MASTER-BRIEF.md:922:1. Check the master brief §-references first
docs/build-brief/00-MASTER-BRIEF.md:931:- Don't add features without a corresponding slice in the master brief
docs/build-brief/00-MASTER-BRIEF.md:933:- Don't relitigate the master brief without writing the disagreement to `docs/decisions/`
docs/build-brief/00-MASTER-BRIEF.md:998:*End of master brief. Drop at `docs/build-brief/00-MASTER-BRIEF.md`. Re-read §1, §3, §6, and §10 weekly.*
docs/operations/codex-round-2-remediation-prompt.md:36:  4. docs/build-brief/00-MASTER-BRIEF.md §10.3 (≤2 round-trip ceiling —
docs/operations/codex-round-2-remediation-prompt.md:407:Per master brief §10.3 step 5: Round 3 is the LAST automated round.
docs/operations/codex-round-2-remediation-prompt.md:433:     Per master brief §10.3, this is the last automated round. Confirm
docs/operations/codex-round-2-remediation-prompt.md:525:  Round 3 ratification (≤2 round-trips per master brief §10.3): 10 items
docs/operations/codex-round-2-remediation-prompt.md:634:**Round 3 ratification:** 10 corrected items re-ratified against appropriate skills. Hard-ceiling enforced per master brief §10.3 step 5.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:13:Master brief §3.4 (line 167) frames the cortextOS / IFOS seam as a shadow:
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:15:> "We replace the stock knowledge base without forking by **shadowing the four `bus/kb-*.sh` shell entry points**." (master brief §3.4 line 167)
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:17:Master brief §5.1 line 304-308 names the four files: `kb-search.sh`, `kb-add.sh`, `kb-update.sh`, `kb-list.sh`.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:19:The Day-1 cortextOS primitive audit (`docs/architecture/cortexos-primitive-status.md` — Primitive 3) surfaced that **none of those four files exist at SHA `c21fbfe`**. The real files at `packages/harness/cortextos/bus/` are `kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`. Reading `kb-setup.sh` revealed the substrate underneath: `mmrag.py` over ChromaDB with Gemini embeddings and 1000-char chunks (`docs/architecture/cortexos-kb-surface-investigation.md` §"What is cortextOS's KB substrate"). That data model is incompatible with the IFOS wiki's entity-document model in master brief §5.2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:21:The subsequent design pass (`docs/architecture/second-brain-design.md`) went further. Q1.4 found that **no IFOS agent calls `kb-*`** — the IFOS Agent Bundle v2 (master brief §8.1) has no `MEMORY.md`, no heartbeat memory file, and uses Postgres `decision_log` for the persistence role cortextOS's KB fills. The §3.4 seam was designed to shadow calls our agents don't make. Q3 evaluated three interface options against the post-design constraints (§3.2 rubric) and recommended Option α — a parallel `packages/brain/bus-overrides/wiki-*.sh` surface with no shadowing of cortextOS's bus.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:27:cortextOS's `bus/kb-*.sh` surface and the `mmrag.py` / ChromaDB / Gemini stack at `packages/harness/cortextos/knowledge-base/` remain **untouched**. IFOS agents do **not** invoke `kb-query`, `kb-ingest`, `kb-collections`, or `kb-setup`. The §3.1 "edit-exception for four `bus/kb-*.sh` shadow points" in the master brief becomes a **dead clause**: there is no shadowing, the exception is never exercised, and §3.1's "never edit `packages/harness/cortextos/*`" stands without qualifier.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:54:- **Master brief §3.1** — Option α uses the boundary's vocabulary (parallel `bus-overrides/` directory) without exercising its kb-* exception.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:55:- **Master brief §8** — wiki ops are internal to IFOS; treating them as bus commands keeps `tools.yaml` clean of internal-surface declarations, reserving it for external MCP execution backends per §3.2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:56:- **Master brief §3.5 + Product Spec §5.4** — α adds zero per-customer infrastructure; the 100-customer stress test passes without operational drag.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:73:## Master brief edits authorised by this ADR
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:75:**Disposition update 2026-05-20 (Day 8 Codex Round 1):** all three edits landed in the atomic-correction commit **`0e5b2b4`** ("docs: master brief reconciliation — 11 edits batch-applied", Day 7 2026-05-20). Manifest-of-record below — each edit's "where it landed" is `0e5b2b4`.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:79:### Edit 1 — Master brief §3.4 brain-replacement seam wording
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:81:**Current** (master brief §3.4 line 167-176): "We replace the stock knowledge base without forking by **shadowing the four `bus/kb-*.sh` shell entry points**. … 1. Vendored copy at `packages/harness/cortextos/bus/kb-*.sh` is left untouched. 2. Our overrides live at `packages/brain/bus-overrides/kb-*.sh`. 3. PM2 `ecosystem.config.js` sets `PATH` so our overrides are picked up first…"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:85:### Edit 2 — Master brief §5.5 v1.0 brain build wording
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:87:**Current** (master brief §5.5 lines 416-420):
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:95:### Edit 3 — Master brief §6 Day 4 Postgres table list
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:97:**Current** (master brief §6 Day 4 line 478):
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:105:This edit lands on **Day 4 of Week 0 (this week)** as part of the Postgres provisioning task per master brief §6 Day 4, **not** in the brain-ADR atomic commit. ADR-002 authorises the split; Day 4 implements it.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:119:**For cortextOS upstream.** No PR upstreamable from this ADR. cortextOS code is untouched; the submodule pin (`c21fbfe991a0030ea055bd8e2389a0801a424383`) stays. The brain-replacement boundary in master brief §3.1 simply isn't exercised — that's not a bug in cortextOS, it's an IFOS-side decision to use a parallel surface.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:121:**For the master brief atomic correction commit.** ADR-001 (Edit: `chokidar watcher` → `FastChecker poll loop` in §2.4 row 3 + §3.2 latency reframe in Ultraplan) and ADR-002 (Edits 1, 2, 3 above — §3.4 wording, §5.5 v1.0 brain build wording, §6 Day 4 Postgres table list) **all landed together in commit `0e5b2b4` on 2026-05-20** ("docs: master brief reconciliation — 11 edits batch-applied"). Ratified by Codex on Day 7 along with ADR-001 + ADR-003 per master brief §10.6.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:127:- **Future v1.1+ ADR (Brain UI implementation choice)** — Next.js routes extending the cortextOS dashboard per master brief §5.3 vs. standalone — out of scope for Q3.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:135:3. Day 7 Codex ratification reviews ADR-001 + ADR-002 + the seven Week 0 artefacts together (per master brief §10.6).
docs/operations/codex-round-2-autonomous-prompt.md:91:recursive ratification per master brief §10.5. Decide whether Claude's 
docs/operations/codex-round-2-autonomous-prompt.md:196:  Disagreement docs (recursive ratification per master brief §10.5):
docs/operations/codex-round-2-autonomous-prompt.md:320:**If SUMMARY.md shows unexpected REJECTED items:** Codex caught something. Read the per-artefact output file. Decide whether to incorporate or counter-argue. Then Round 3 (~limited; ≤2 round-trips per master brief §10.3).
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:13:Master brief §2.4 row 3 describes Primitive 3 (Inter-agent file bus) as:
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:26:This drift surfaced during the Day-1 primitive audit. It has no Day-0 quirk attached and no real-world brittleness — the bus itself ships and is tested (`tests/unit/bus/message.test.ts`, `tests/integration/multi-agent-crons.test.ts`, `tests/e2e/lifecycle.test.ts`). Only the master brief's mechanism description is wrong.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:32:**1. Correct master brief §2.4 row 3.** Replace:
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:47:| **B. Reduce to 250ms** | Set `pollInterval: 250` in the IFOS agent template's `config.json`. Re-measure daemon CPU on a 6-agent fleet under load (master brief §6 Day 4 stress-test addition). Keep the existing "complete in seconds" framing | ~0.5 day to add the config + re-baseline; ongoing 4× CPU per FastChecker poll (still negligible — `readdirSync` on a typically-empty inbox dir is sub-millisecond, so 4× sub-ms is still sub-ms). The risk is `bus-signing-key` HMAC verification cost × 4 if inbox traffic spikes | Pipeline floor drops to ~750ms — restores headroom for the sales narrative while leaving CPU comfortable. |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:51:1. The honest-signal Rule 5 (master brief §1) makes "rewrite the claim" cheaper than "tune the substrate to fit the claim".
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:58:- Single edit to master brief §2.4 row 3 (the correction itself).
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:65:- Master brief §2.4 row 3 still gets corrected — but says "poll loop (250ms in IFOS, 1000ms cortextOS default)".
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:66:- Day 4 infra stress-test (master brief §6) gains a new sub-task: measure daemon CPU on a synthetic 6-agent fleet at 250ms poll vs 1000ms baseline.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:71:- Codex-ratification list (master brief §10.5) needs an entry: bus-dispatcher mechanism change = master brief edit = always-ratify.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:76:**Accepted — Option A.** Founder decision logged 2026-05-16. The master brief §2.4 row 3 + Ultraplan §3.2 edits are deferred to a single atomic "spec drift reconciliation" commit that lands alongside whatever ADR-002 dictates for §3.4. Codex ratifies the combined commit on Day 7 with the other Week 0 artefacts.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:30:Per master brief §10.5 + Rule 4 (Quality gates before features), an upstream-spec amendment requires either (a) revert the scaffold to per-draft hard-fail, or (b) author an ADR ratifying the deviation. This ADR is option (b).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:83:**ULTRAPLAN §8.1 A6 line 566 is amended in-band per the master brief §10.3 step 4 pattern** (analogue of the in-band amendment ADR-006 made at line 496):
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:112:### In-band ULTRAPLAN amendment (applied with this ADR per master brief §10.3 step 4)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:141:- Master brief §1 Rule 4 (Quality gates before features) + §10.5 (ADRs are ratifiable artefacts)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:145:**Status:** Proposed; awaits Codex `review-architecture-decision` ratification (R19+) + founder Accept per master brief §10.3 step 5 if Codex still disagrees.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:5:**Codex rounds completed:** Round 4 (initial REJECTED, 4 issues) + Round 5 (remediation REJECTED, 5 issues including 2 re-raises and 3 new findings) — **hard ceiling per master brief §10.3 step 5 reached**.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:17:Per master brief §10.3 step 5: **≤2 round-trips max per artefact**. Round 5 was the second round-trip. **Hard ceiling reached.** Founder arbitration required to close the artefact.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:147:- §5 honesty (Issue 5) is exactly the kind of "honest signal" the master brief §1 Rule 5 demands; framing §5 as "intended behaviour, build slice will deliver" is more honest than asserting Gate A as already-implemented.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:165:**Empirical confirmation of the pattern documented in master brief §10.3 step 5:** Codex finds new issues at each round. Hard ceiling of ≤2 round-trips is the right structural protocol. Further autonomous Claude remediation passes will continue surfacing new issues that may not have been visible at earlier rounds (each fix changes the document, exposing different inconsistencies).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:186:Despite master brief §10.3 step 5 protocol saying founder review after Round 5, Round 6 attempted with all Round-5 issues remediated (commit `aaa376d`). Round 6 returned REJECTED with **4 new findings**, none of which appeared in any prior round:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:202:**21 unique issues across 4 rounds, ZERO repeats.** Master brief §10.3 step 5 hard ceiling exists for exactly this reason — each remediation pass surfaces issues that weren't visible at prior rounds because the document changes.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:206:This document now contains 4 rounds of empirical evidence supporting the master brief's documented hard-ceiling protocol. Founder Sunday review session is the right next step.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:229:**Round 7 findings 1 + 2 + 3 + 4 are all CAUSED BY my Round 6 fixes.** When I fixed one section, I introduced inconsistencies between it and other sections referencing the same concept. This is the perfect illustration of why master brief §10.3 step 5 caps round-trips: each fix changes the document, and the changed document has new inconsistencies between the fixed-section and the related-but-unfixed sections.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:235:Master brief §10.3 step 5 cap = 2 round-trips. The hook has requested 5 rounds. Each beyond round 2 has produced 4-5 new findings. The protocol is right; the hook contradicts it.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:283:- Concierge AgentMail adapter-boundary violation (master brief §3 red line) — replaced all 5 references with "agent-identity email adapter (deferred)"
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:326:**Phase 1 + Phase 2 + Phase 3 (Round 8 + Cat-α inline fixes) constitute the documented "Path A — bilateral session per master brief protocol" outcome.** No further autonomous remediation rounds will be attempted per the master brief §10.3 step 5 hard ceiling and founder's "no more rounds" authorization.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:378:**Cumulative empirical (10 rounds total):** ~75 unique findings catalogued; ~7 closed via Cat-α + Cat-γ + Cat-δ inline this session; convergence rate ~10% per round. The pattern documented in master brief §10.3 step 5 holds.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:400:When founder authorizes a Cat-1 hybrid disposition (per-section v0 + per-claim W4), the agent.md prose explicitly documents this. Codex re-flags it as "Gate A weakens upstream requirement" regardless. This is structural — Codex reviews agent.md against ULTRAPLAN/master brief, and bilateral disposition documents at `docs/decisions/codex-disagreement-*.md` are downstream artefacts Codex doesn't auto-trust.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:409:### Decision — stop Codex looping per master brief §10.3 step 5
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:411:The pattern (Round 4 → Round 9; 10 rounds; 75+ unique findings; ~10% net convergence per round) empirically confirms master brief §10.3 step 5. Each remediation pass surfaces new issues at roughly the same rate it closes old ones — because the document keeps changing.
docs/decisions/sequencing-target.md:6:**Surfaced by:** Master brief §6 Day 3 (lines 469-473) — "Confirm or revise Ultraplan §9's 'close first 3 pilots fastest' → `.agents/decisions/sequencing-target.md`" (note: master brief §6 names `.agents/decisions/`; this document lives at `docs/decisions/sequencing-target.md` matching the convention established by ADR-001 through ADR-003 + bullhorn-integration-path.md — **Spec gap §1-A** flagged for atomic correction).
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:46:The Day-7 single-sentence test (master brief §6 Day 7 / Ultraplan §12) doesn't directly test sequencing — but Q4 ("Have we scoped the Agent Bundle v2 refactor and is the work <5 days?") and the Week-0 deliverable list at Ultraplan §9 line 737-741 both assume a sequenced plan exists. The Day 7 review surfaces this document for Codex ratification.
docs/decisions/sequencing-target.md:50:Six criteria to evaluate each agent against in §2. Each criterion scored High / Medium / Low or with a concrete number; substantive cells in §2 must justify the score by reference to master brief / Ultraplan / Product Spec / Day-2 Bullhorn decision.
docs/decisions/sequencing-target.md:65:Per master brief §12 / Ultraplan §10 row #2 (the four-risks-that-kill-v1.0 table), the **documented v1.0 scope-cut contingency** is verbatim:
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:84:**Section 4's recommendation evaluates both orderings** (founder-prompt-Alpha and master-brief-Alpha) against the §1.3 criteria, picks whichever wins on the merits, and explicitly aligns with the master brief by default unless rationale exists to revise it. This document is the "confirm or revise" decision per master brief §6 Day 3 line 471 — both options are on the table.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:166:| 4. Commercial value | **Highest** | Per master brief §8.2 line 606: "First Tier-1 always-on closing demo; 4-week build." Product Spec §2.2 R7: 15-25% lift in placement-driven referral revenue ("post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table"). The flagship v1.0 closing demo |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:335:- Per-agent Codex-ratification timing within each build slot — every `agent.md` ratifies before merge per master brief §10.5; specific ratification cadence emerges from each agent's PR cycle.
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:374:4. **If scope-cut activates twice in one v1.0 cycle, escalate to v1.0 kill criterion** — the Day 5 work (master brief §6 Day 5) defines the kill-criterion threshold; sequencing failures count toward that threshold.
docs/decisions/sequencing-target.md:389:- `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` per master brief §8.1 Changes 1+2.
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:455:Per §1.5 Spec gap §1-A finding: master brief §6 Day 3 line 471 names the path `.agents/decisions/sequencing-target.md` but the convention established by Days 1-2 is `docs/decisions/`. Same path-convention drift applies to line 472 (Brain UI scope decision; will be flagged in `brain-ui-scope.md` separately if needed).
docs/decisions/sequencing-target.md:457:**Current** (master brief §6 Day 3 line 471 verbatim):
docs/decisions/sequencing-target.md:477:Master brief §6 Day 3 line 472 (Brain UI scope path) — same `.agents/decisions/` drift; will be folded into the brain-ui-scope.md §X consequences section as part of the Day-3 brain-ui artefact, or rolled into this same 7th edit if both lines fix together.
docs/decisions/sequencing-target.md:489:| §1-A | §6.8 + atomic correction commit edit 7 | Path convention `.agents/decisions/` → `docs/decisions/` for master brief §6 Day 3 line 471 (and likely line 472 per brain-ui-scope.md) |
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:496:### Bucket 2 — Master brief edits needed
docs/decisions/sequencing-target.md:500:| 7th edit | Master brief §6 Day 3 line 471 | `.agents/decisions/` → `docs/decisions/` (per §6.8) | Joins atomic correction commit at end of Week 0 / early Week 1, alongside ADR-001 + ADR-002 + ADR-003 Edit C + `bullhorn-integration-path.md` §6.6 |
docs/decisions/sequencing-target.md:501:| Day-3 commit edit (optional) | Master brief §6 Day 3 line 472 | Same `.agents/decisions/` path drift; resolves with brain-ui-scope.md authoring | May fold into same 7th edit or separate — decided in brain-ui-scope.md §X |
docs/operations/w4-day-20-founder-runbook.md:27:**Why:** Per master brief §10.5, "every Postgres migration touching tenant
docs/operations/w4-day-20-founder-runbook.md:31:read of §10.5 (it executes DDL against live data).
docs/operations/goal-week-3-polish-and-scaffold.md:7:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:20:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (boundaries) + §6 Day 4-7 (foundation state) + §8 (build sequence) + §10.5 (always-ratify artefacts)
docs/operations/goal-week-3-polish-and-scaffold.md:52:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:53:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:54:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:55:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:56:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §1 Output contract (one-paragraph screenshot per master brief §1 Rule 1)
docs/operations/goal-week-3-polish-and-scaffold.md:94:| Diagnostic Codex ratification | Master brief §10.5 always-ratify |
docs/operations/goal-week-3-polish-and-scaffold.md:95:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:96:| Codex Round 4 execution | Master brief §10.6 ratification cadence |
docs/operations/goal-week-3-polish-and-scaffold.md:294:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **Build wave:** W5 per master brief §8.2 line 596
docs/operations/goal-week-3-polish-and-scaffold.md:322:- §1 reads as a complete one-paragraph screenshot per master brief §1 Rule 1
docs/operations/goal-week-3-polish-and-scaffold.md:332:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:360:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:361:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:367:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:389:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:395:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:415:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:450:Triage protocol (master brief §10.3 step 5 hard ceiling: ≤2 round-trips):
docs/operations/goal-week-3-polish-and-scaffold.md:487:| **Master plan citations** | Every architectural claim cites master brief / ULTRAPLAN line numbers | grep diff for citation strings |
docs/operations/goal-week-3-polish-and-scaffold.md:502:| Codex Round 4 returns >2 REJECTED on any single artefact | Founder review; do NOT remediate-and-resubmit beyond hard ceiling (per master brief §10.3 step 5); write founder-decision doc; defer |
docs/operations/goal-week-3-polish-and-scaffold.md:540:Per master brief §10 + §10.3 step 5 hard ceiling + Day-11 Round-2/3 pattern.
docs/operations/goal-week-3-polish-and-scaffold.md:573:- **Mechanical REJECTIONS (citation drift, line-anchor error, formatting):** Round 4 remediation prompt; expect Round 5 final. Hard ceiling per master brief §10.3 step 5: 2 round-trips MAX. Round 5 RATIFIED → close. Round 5 STILL REJECTED → founder review.
docs/operations/goal-week-3-polish-and-scaffold.md:590:1. **Every claim cites a master plan section.** No bare assertions. Every paragraph either cites the master brief / ULTRAPLAN / sequencing-target / kill-criterion / specific ADR, OR is explicitly stated as "scaffold inference; founder review required."
docs/operations/goal-week-3-polish-and-scaffold.md:591:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:642:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/decisions/bullhorn-integration-path.md:6:**Surfaced by:** Master brief §6 Day 2 (lines 466-467) — "Decision: Bullhorn Marketplace vs Direct API. OAuth model: browser dance for production, service-account for dev." Plus Ultraplan §11 Day 2 (lines 847-849).
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:17:Three sub-decisions, named in master brief §6 Day 2 line 466 and extended in Ultraplan §11 Day 2 lines 847-849.
docs/decisions/bullhorn-integration-path.md:19:**Sub-decision A — Bullhorn integration path.** Marketplace partner programme membership (with its access tier, scope, certification, ongoing fees) versus direct API access (per-tenant Bullhorn-account-admin authorisation of IFOS as a connected app). Master brief §6 Day 2 line 466 explicitly names this as the day's decision. The path chosen determines whether `packages/mcp-connectors/bullhorn/` ships as a marketplace-registered connector or a direct-API connector — the *code* in either case is similar OAuth + REST plumbing, but the *operational, commercial, and rate-limit* surfaces differ materially.
docs/decisions/bullhorn-integration-path.md:21:**Sub-decision B — OAuth flow.** Master brief §6 Day 2 line 466 pre-states a recommendation: "browser dance for production, service-account for dev." This is the authorization-code grant (per-tenant browser dance, refresh-token cycle) for production tenants, plus client-credentials grant (service account) for IFOS-internal sandbox/dev work. Sub-decision B verifies that recommendation against Bullhorn's actual OAuth implementation and pins the per-tenant token storage path (per `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution: `/vault/<tenant>/_secrets.env`, mode `0600`).
docs/decisions/bullhorn-integration-path.md:27:Master brief §12 Risk #2 (Bullhorn auth path) — "Bullhorn MCP build takes longer than 1 week" — names this as one of the four risks that could kill v1.0. Tripwire: "End of week 3 status not 'core read endpoints working'" (master brief §12 row #2, Ultraplan §10 row #2). The mitigation is "Week 0 Day 2 on Bullhorn auth research" — i.e. this document. Without Sub-decisions A and B answered, Week 1 cannot begin scaffolding `packages/mcp-connectors/bullhorn/` because the connector's authentication path determines its scope and shape.
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:42:This is also the Day 2 critical-path artefact for the §6 Day 7 single-sentence test (master brief §6 lines 494-502, Ultraplan §12 lines 887-895), question 3: "Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?" A Yes answer requires this document plus the Sub-decision A and B confirmations to land before Sunday review.
docs/decisions/bullhorn-integration-path.md:48:**Technically grounded (Claude Code can analyse tonight from Bullhorn public documentation + master brief / Ultraplan / product spec context):**
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:62:- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
docs/decisions/bullhorn-integration-path.md:70:| A + C | "Which ATS does design partner #1 use — Bullhorn, Vincere, Voyager Infinity, or another?" | **Founder** — Sunday design-partner conversation 2 per master brief §6 Day 2 line 467 | Sunday/Monday | If Bullhorn: Sub-decision A path proceeds as analysed. If non-Bullhorn: the v1.0 ATS anchor changes, this document's Sub-decisions are scoped to "Bullhorn is the second-tenant ATS" rather than "v1.0 first-tenant ATS" |
docs/decisions/bullhorn-integration-path.md:74:The Sunday design-partner conversation 2 is the most time-sensitive: it can flip the entire premise of Sub-decisions A and C. Founder cadence per master brief §6 Day 2 (line 467) and §11.2 line 791 ("Day 2 — Tuesday — Bullhorn integration path... — Design-partner conversation 2") puts this as a parallel-to-Claude-Code track.
docs/decisions/bullhorn-integration-path.md:91:- **Day 7 review (master brief §6 Day 7 Sunday):**
docs/decisions/bullhorn-integration-path.md:93:  - This document joins the first Codex ratification run alongside the other Week 0 artefacts per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:191:| Marketplace tier is **required** for production tenant onboarding (partnerships@bullhorn answer) | Connector scaffolds against direct-API on a Bullhorn-sandbox tenant for IFOS internal dev; marketplace registration becomes Week-1 critical-path commercial work; v1.0 build slips by the marketplace certification timeline (potentially 4-12 weeks per §2.3 row 1 inference). This is a v1.0 blocker scenario and feeds master brief §12 Risk #2 directly. |
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:226:**Scope of permissions requested at first auth:** Bullhorn's OAuth docs surveyed do not specify per-scope strings (e.g. `read:candidate`, `write:note`). REST API access appears to be at-tenant-admin-discretion — the admin authorises the connected app for "API access" generally, and the corpToken-scoped session inherits whatever entity permissions the admin's account holds. **Spec gap §3.1-B:** confirm with Bullhorn developer support that there is no per-entity-type scope granularity at the OAuth layer — i.e. IFOS cannot request "read-only" auth and get a token that can't write. If this is correct, then Gate A in `validate.sh` (per master brief §1 Rule 4) becomes the only enforcement layer for "this agent should never write" — the OAuth token itself does not protect.
docs/decisions/bullhorn-integration-path.md:230:- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
docs/decisions/bullhorn-integration-path.md:239:This forecloses one option that the master brief §6 Day 2 line 466 pre-statement contemplated — "service-account for dev." The closest substitute is one of:
docs/decisions/bullhorn-integration-path.md:256:**Recommendation:** authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement "browser dance for production"). For IFOS dev: authorization-code grant against an IFOS-owned Bullhorn dev tenant; service-account / client_credentials grant deferred (because Bullhorn doesn't document support for it per §3.2).
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
docs/decisions/bullhorn-integration-path.md:375:3. First design partner ATS confirmed as Bullhorn (Sunday design-partner conversation 2 per master brief §6 Day 2 line 467).
docs/decisions/bullhorn-integration-path.md:381:Recommendation: authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement); authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (client_credentials grant **foreclosed** by Bullhorn OAuth docs per §3.2 — Bullhorn does not support client_credentials grant for tenant-scoped data). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:411:- **`ESC_BULLHORN_AUTH` escalation code wired** into `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3 line 587 — code already named in master brief; wiring lands with `_shared/hook-helpers.sh` Week-1 prereq.
docs/decisions/bullhorn-integration-path.md:442:§3.2 finding (Bullhorn does NOT support client_credentials grant for tenant-scoped data per public OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`) forecloses the master brief §6 Day 2 line 466 pre-statement. New sixth edit for the atomic correction commit alongside ADR-001 + ADR-002 + ADR-003 Edit C.
docs/decisions/bullhorn-integration-path.md:444:**Current** (master brief §6 Day 2 line 466 verbatim):
docs/decisions/bullhorn-integration-path.md:452:Joins the atomic correction commit at end of Week 0 / early Week 1. Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:460:**Reduction trigger 2 (Medium → Low):** first Bullhorn write lands cleanly in Week 3-4 Janitor agent build (the master brief §12 / Ultraplan §10 row #2 tripwire test "core read endpoints working" passes).
docs/decisions/bullhorn-integration-path.md:488:### Bucket 2 — Master brief edits needed
docs/decisions/bullhorn-integration-path.md:492:| 6th edit | Master brief §6 Day 2 line 466 | `service-account for dev` → `authorization-code grant against an IFOS-owned Bullhorn dev tenant` (per §6.6) | Joins atomic correction commit at end of Week 0 / early Week 1, alongside ADR-001 + ADR-002 + ADR-003 Edit C |
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |
docs/runbooks/tenant-lifecycle.md:173:Per ADR-003 §"Master brief edits authorised" Edit B (post-ADR-004 corrected to `ifos-render-agent`).
docs/runbooks/tenant-lifecycle.md:363:  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
docs/runbooks/day-4-provisioning.md:6:target: Master brief §6 Day 4 + four consolidated tightenings
docs/runbooks/day-4-provisioning.md:15:This runbook is the **reviewable plan** for Day 4 of Week 0 per master brief §6 Day 4. It is **not executed by writing it.** Execution happens in a separate session against a real VPS after this document is reviewed and ratified.
docs/runbooks/day-4-provisioning.md:30:- **Rule 5 (Honest signal before optimistic projection):** §0 surfaces every drift between the master brief and reality (notably: Hetzner has no UK data centre).
docs/runbooks/day-4-provisioning.md:38:### §0.1 — DRIFT: Hetzner has no UK data centre (master brief §6 Day 4 line 477)
docs/runbooks/day-4-provisioning.md:40:**Master brief asserts (line 477 verbatim):** "Hetzner UK VPS provisioned, LUKS-encrypted volume mounted at `/vault/`". This is the single Hetzner reference in the master brief. §10 (Codex ratification loop) does not mention Hetzner or cost targets — earlier drafts of this runbook cited "master brief §10.4" for cost target and Hetzner location; both fabricated. Corrected in citation-audit pass 2026-05-18.
docs/runbooks/day-4-provisioning.md:51:| £20/mo target (Day-4 runbook §1.4 founder-set budget; not specified in master brief) | ✅ well under | ✅ within budget |
docs/runbooks/day-4-provisioning.md:56:**Master-brief correction:** add to the atomic-correction commit manifest (currently 8 edits at end of Week 0). Proposed Edit 9: master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations"; flag UK-residency as a commercial-conversation gate. (Earlier drafts also referenced "§10.4" as a separate location-naming surface; verified that §10.4 — "What never goes through ratification" — contains no Hetzner or cost-target content. §10.4 component dropped.)
docs/runbooks/day-4-provisioning.md:58:### §0.2 — DRIFT: master brief §6 Day 4 table list says `entity_graph`, ADR-002 Edit 3 split this to `entities` + `entity_links`
docs/runbooks/day-4-provisioning.md:60:**Master brief asserts (§6 Day 4 line 478):** "Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`"
docs/runbooks/day-4-provisioning.md:64:**This runbook follows the corrected list.** The atomic correction commit manifest covers the master brief §6 wording.
docs/runbooks/day-4-provisioning.md:70:- Master brief §8.1 Change 2: three values — `trigger`, `output`, `action`
docs/runbooks/day-4-provisioning.md:75:The runbook applies exactly these. **Do not invent additional phase values during execution** (e.g., `session_start`, `tool_call`, `escalation`) unless a Codex-ratified change to either master brief §8.1 or `sequencing-target.md` §5-A pre-dates the migration. Speculative additions break the schema-before-code rule.
docs/runbooks/day-4-provisioning.md:100:- v1.1+ multi-user: sudo password may be revisited when Hire #1 onboards (master brief Risk #4)
docs/runbooks/day-4-provisioning.md:171:| Instance type | CX22 (2 vCPU, 4 GB RAM, 40 GB NVMe) | Fits v1.0 pilot scale per founder-set budget in this section §1.4; master brief does not specify a numeric cost target |
docs/runbooks/day-4-provisioning.md:178:Estimated monthly cost: ~€5/mo VPS + ~€2.40/mo (50 GB volume at €0.0476/GB/mo) ≈ €7.40/mo ≈ £6.40/mo. Well under the £20/mo founder-set budget for v1.0 pilot scale (this section §1.4; master brief does not specify a numeric cost target).
docs/runbooks/day-4-provisioning.md:766:-- Note: NO UPDATE/DELETE grant. Decision log is append-only per master brief §5.7.
docs/runbooks/day-4-provisioning.md:768:-- tenant_eval_sets (per master brief §6 Day 4 line 478; v1.0 placeholder)
docs/runbooks/day-4-provisioning.md:783:-- tenant_adapters (per master brief §6 Day 4 line 478; tracks per-tenant adapter binding)
docs/runbooks/day-4-provisioning.md:806:Per `sequencing-target.md` §5-A + master brief §8.1 Change 2 + `current-priorities.md` line 16. **Exactly 5 values. No additions.**
docs/runbooks/day-4-provisioning.md:1090:The vault per ADR-002 + master brief §3.3 is markdown, git-backed. Initial baseline:
docs/runbooks/day-4-provisioning.md:1187:- Add Edit 9: master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations"; document UK-residency as commercial-conversation gate. (§10.4 reference dropped per 2026-05-18 citation audit; §10.4 is Codex exclusion list, not a Hetzner or cost-target section.)
docs/runbooks/day-4-provisioning.md:1212:3. **§2 location — NBG1 substituted for FSN1:** FSN1 unavailable at provisioning time. Substituted Nuremberg (NBG1) — same Hetzner eu-central zone, identical Schrems II EU jurisdiction (German court orders only), latency to UK ~25-30ms vs FSN1 ~20-25ms (functionally equivalent). **Triggers §11.4 master-brief Edit 9:** master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations". (Earlier drafts of Edit 9 also referenced master brief §10.4; verified during 2026-05-18 citation audit that §10.4 is the Codex exclusion list, not a Hetzner or cost-target section. §10.4 component dropped.)
docs/operations/codex-ratification-execution-plan.md:5:**Source artefacts:** master brief §10 (the loop) + `docs/decisions/2026-05-18-codex-ratification-manifest.md` (the queue) + this plan (the how).
docs/operations/codex-ratification-execution-plan.md:10:## §1 — Why this loop matters (re-statement from master brief §10.1)
docs/operations/codex-ratification-execution-plan.md:64:Master brief §10.2 lists 7 skill files. None exist yet (Day-7 manifest §3 gap). Build them before first ratification run.
docs/operations/codex-ratification-execution-plan.md:78:### Skill shape (per master brief §10.2 last paragraph)
docs/operations/codex-ratification-execution-plan.md:93:## Five-rule pass (master brief §1)
docs/operations/codex-ratification-execution-plan.md:100:## Four-boundary pass (master brief §3)
docs/operations/codex-ratification-execution-plan.md:204:Per master brief §10.6 — mean cost is 20-30 min per artefact including the round-trip. Cluster batching reduces context-switching cost.
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
docs/operations/codex-ratification-execution-plan.md:274:    'round_trip', $5,                     -- 1 or 2 per §10.3
docs/operations/codex-ratification-execution-plan.md:317:Per master brief §10.3 step 5:
docs/operations/codex-ratification-execution-plan.md:331:**The disagreement IS the signal.** Master brief §10.1 explicitly: "Disagreements between [Claude and Codex] are the most valuable signal — that's where the spec is ambiguous and needs founder decision."
docs/operations/codex-ratification-execution-plan.md:338:4. **Spec drift** — Codex reviews an artefact that's based on a now-stale version of the master brief. Disagreement → update the master brief OR the artefact; re-review. Moderately expensive.
docs/operations/codex-ratification-execution-plan.md:340:**Worth tracking for retro:** category mix on first run. If category 1 dominates, the master brief needs sharpening. If category 4 dominates, the atomic-correction discipline is failing.
docs/operations/codex-ratification-execution-plan.md:353:- **Option β** — Wait for Q1 = YES. Rationale: master brief §10.6 framed first ratification run as Day 7; once-Week-0-closes implies the design-partner LOI exists. Some artefacts (Bullhorn integration Sub-decisions A+B) genuinely change post-commercial-conversations.
docs/operations/codex-ratification-execution-plan.md:390:7. **Master brief §10.6 timeline updated** with actual cost vs estimate. Founder-facing artefact.
docs/operations/codex-ratification-execution-plan.md:427:- **Multi-model ratification (e.g., adding Gemini)** — v1.0 is Claude + Codex per master brief §10. Multi-model is v2.0+ if signal justifies.
docs/operations/codex-ratification-execution-plan.md:439:3. **`decision_log` rows** for every artefact reviewed — audit trail per master brief §10.6.
docs/operations/codex-ratification-execution-plan.md:441:5. **Master brief edits queued** — if Codex flags spec drift, the next atomic-correction commit picks them up.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/runbooks/operational-hygiene-protocol.md:27:- **Citation accuracy B** — Day 5 §4.1 should have been §4.1 + §6.3 (caught in review); Day 6 "30+" action_type claim was actually 29 (caught in review); **15 fabricated "master brief §10.4" references propagated across 5 files** (caught in Day-6-evening citation audit; see §7 below)
docs/runbooks/operational-hygiene-protocol.md:229:### §5.4 — Master brief / cross-artefact citation discipline
docs/runbooks/operational-hygiene-protocol.md:231:**Day-6 lesson (§7 below):** 15 fabricated "master brief §10.4" references propagated across 5 files. The root cause: Day-4 runbook drafting invented a citation that didn't exist, and subsequent artefacts cited the Day-4 runbook citation without re-verifying against master brief.
docs/runbooks/operational-hygiene-protocol.md:234:- When citing master brief, verify against master brief — never against an intermediate artefact's citation of master brief
docs/runbooks/operational-hygiene-protocol.md:262:### §7.1 — Finding: master brief §10.4 fabrication
docs/runbooks/operational-hygiene-protocol.md:264:**Scope:** 15 references to "master brief §10.4" across 5 files, claiming §10.4 contains either (a) a Hetzner UK / FSN1 location reference or (b) a £20/mo cost target.
docs/runbooks/operational-hygiene-protocol.md:266:**Verified ground truth:** master brief §10.4 is "What never goes through ratification" — a 5-bullet list of Codex exclusions (comment-only changes, test fixture additions, documentation typos, build/deps version bumps, anything inside `.agents/`). It contains no Hetzner reference and no cost-target reference.
docs/runbooks/operational-hygiene-protocol.md:268:**Root cause:** Day-4 runbook §1.4 invented "master brief §10.4 cost target" during drafting. The citation propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1 instance), RISK-REGISTER (2 instances), current-priorities (1 instance) by trusting the Day-4 runbook citation rather than re-verifying against master brief. Citation transitivity, not master-brief drift.
docs/runbooks/operational-hygiene-protocol.md:274:| `docs/runbooks/day-4-provisioning.md` | 8 | "+§10.4" dropped from Edit 9 scope (was about Hetzner UK); "§10.4 cost target" replaced with "Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target)" |
docs/runbooks/operational-hygiene-protocol.md:277:| `docs/RISK-REGISTER.md` | 2 | Risk #7 Edit 9 scope corrected; log entry annotated |
docs/runbooks/operational-hygiene-protocol.md:296:- `master brief §3.2 line 155` (canonical vocabulary "candidate, placement, brief") — ✅ verified line 155 matches
docs/runbooks/operational-hygiene-protocol.md:297:- `master brief §5.1 lines 325-329` (vault directory structure) — ✅ verified
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
docs/decisions/autosend-safety-policy.md:6:**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
docs/decisions/autosend-safety-policy.md:7:**Surfaced by:** Master brief Day 5 spec; load-bearing for every `hh_decision_action` call across the v1.0 agent fleet.
docs/decisions/autosend-safety-policy.md:8:**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
docs/decisions/autosend-safety-policy.md:21:**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:188:      # Blocks on cortextOS approval gate (master brief primitive 4). Returns 0 on approval, 1 on reject/timeout.
docs/decisions/autosend-safety-policy.md:235:Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:585:4. **Cyber insurance.** IFOS Limited needs cyber insurance covering policy miscategorisation events. Quote requests pending; budget impact on v1.0 founder-set cost budget (Day-4 runbook §1.4 — £20/mo for infrastructure at single-tenant pilot scale; master brief does not specify a numeric cost target).
docs/decisions/autosend-safety-policy.md:620:- **Q3 (lookup latency / 71-hour cache lifetime):** ACCEPTED for v1.0. Policy hot-reload deliberately deferred to v1.1+; v1.0 accepts up-to-71-hour delay on policy changes taking effect at agent layer. Material policy changes must wait for next 71-hour boundary (cortextOS context rotation per master brief §2.4 primitive 2) or trigger deliberate cortextOS PTY restart. Operational footgun documented in §4.
docs/decisions/autosend-safety-policy.md:648:**For atomic-correction manifest.** Edit 10 adds the path drift correction (master brief §6 Day 5 line 484-485 → docs/decisions/). Manifest grows from 9 to 10.
docs/decisions/autosend-safety-policy.md:660:**Path drift logged for atomic correction Edit 10:** master brief §6 Day 5 line 484-485 paths to live at `docs/decisions/`.
docs/_supplementary/README.md:5:- `docs/build-brief/00-MASTER-BRIEF.md` — the master brief Claude Code reads first
docs/operations/codex-ratification-guide.md:30:- Citation drift — `master brief §10.4` quoted 15 times in one batch, all wrong (real past incident)
docs/operations/codex-ratification-guide.md:200:2. Citation §10.4 incorrect — master brief §10.4 is the Codex exclusion list, not the cost target the ADR cites. Past pattern of 15 fabricated §10.4 references; verify line numbers before citing. Citation: ADR-001 line 47.
docs/operations/codex-ratification-guide.md:373:The disagreement doc itself becomes a ratifiable artefact in a future round (master brief §10.5 recursive ratification). That's by design — the disagreement IS the signal.
docs/operations/codex-ratification-guide.md:516:- **Possibly updated master brief** — Codex may flag spec drifts requiring atomic correction
docs/decisions/v1.0-kill-criterion.md:6:**Master brief §:** §6 Day 5 (line 486) + §12 Risk Register + §1 Rule 5 (honest signal before optimistic projection)
docs/decisions/v1.0-kill-criterion.md:7:**Surfaced by:** Master brief Day 5 spec; folds carry-forwards from `sequencing-target.md` §6.6 + `bullhorn-integration-path.md` §4.1 + Day-4 §11 closing-commit work.
docs/decisions/v1.0-kill-criterion.md:8:**Path drift logged:** Master brief §6 Day 5 line 486 specifies `docs/v1-kill-criterion.md` (docs/ root). This artefact lives at `docs/decisions/v1.0-kill-criterion.md` per repo convention. Recorded as **Edit 10** in atomic-correction manifest (shared with autosend-safety-policy.md path drift).
docs/decisions/v1.0-kill-criterion.md:37:**v1.0 commitments to existing pilots are honoured under original scope.** New v1.0 contracts under rescoped terms. The master brief and Ultraplan are amended by atomic-correction commit; Codex ratifies before v1.0 resumption.
docs/decisions/v1.0-kill-criterion.md:47:**Threshold:** No design partner has confirmed pilot intent (signed LOI or equivalent written commitment to pilot in Q3 2026 per master brief §6 Day 7 question 1) by end of Week 2.
docs/decisions/v1.0-kill-criterion.md:53:**Source:** Risk #3 in `docs/RISK-REGISTER.md` (escalating status); Day-5 Risk #3 update reflects "zero design partners in pipeline" as of this commit; master brief §6 Day 7 question 1.
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:89:**Recovery path:** PIVOT is structural; resumption is via rescoped v1.0 under new ATS assumption. Pivoted v1.0 continues with adjusted master brief / Ultraplan; atomic-correction commit lands the rescope.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:97:**Source:** `sequencing-target.md` §6.6 failure condition (iii); master brief §12 Risk #4 (Hire #1 mitigation calls for scope cut from 6 → 4 agents but explicitly warns against further cuts).
docs/decisions/v1.0-kill-criterion.md:134:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 pilot scale; master brief does not specify a numeric cost target); emerging from v1.0 pilot operations.
docs/decisions/v1.0-kill-criterion.md:148:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 single-tenant pilot; master brief does not specify a numeric cost target); Risk #4 in `docs/RISK-REGISTER.md` (Hire #1 delays compound infrastructure spend if architecture sprawls).
docs/decisions/v1.0-kill-criterion.md:156:**Recovery path:** Rescoped infrastructure plan; pivoted v1.0 continues with adjusted Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target; budget adjustment is a runbook revision, not a master-brief edit).
docs/decisions/v1.0-kill-criterion.md:164:**Source:** Master brief §6 Day 5 line 486 — canonical example trigger from master brief.
docs/decisions/v1.0-kill-criterion.md:178:**Source:** Master brief §12 Risk #1; Day-1 audit results in `cortexos-primitive-status.md` (primitive 1 PTY/PM2 is "shipped but flaky"; primitives 3 + 4 confirmed "shipped and tested" but field evidence may diverge).
docs/decisions/v1.0-kill-criterion.md:182:**Unfreeze criterion:** Either (1) cortextOS upstream PR lands the fix (per master brief §3.1 cross-vertical primitive process), OR (2) IFOS vendor-patches via `packages/harness-patches/` per master brief §3.1 fallback path. Unfreeze after **2 consecutive incident-free weeks** (matched to tightened threshold).
docs/decisions/v1.0-kill-criterion.md:194:**Source:** Master brief §1 Rule 5 (honest signal before optimistic projection); UK GDPR statutory obligations; Risk #3 in `docs/RISK-REGISTER.md` (multi-tenant trust foundation).
docs/decisions/v1.0-kill-criterion.md:306:1. Rescope plan replaces affected slices of master brief and Ultraplan. New atomic-correction commit lands the rescope edits (separate from the existing 10-edit atomic-correction manifest — pivot is a wholly new manifest event).
docs/decisions/v1.0-kill-criterion.md:322:4. v1.1 — if launched — is a wholly new initiative under different premises. Not a continuation of v1.0. Has its own master brief, Ultraplan, kill criterion.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:338:- The vertical assumption: UK recruitment agencies (per master brief §0 + Product Spec)
docs/decisions/v1.0-kill-criterion.md:345:v1.1 begins when v1.0 is operationally stable with ≥1 pilot operational. v1.1 scope per master brief §9 build sequence + Product Spec:
docs/decisions/v1.0-kill-criterion.md:350:- Adds AgentMail integration (Inbound Triage only) per master brief §3.2
docs/decisions/v1.0-kill-criterion.md:399:**Path drift logged for atomic correction Edit 10:** master brief §6 Day 5 line 486 path to live at `docs/decisions/`.
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:30:No edit to the agent.md or validate.sh. R17 dispositions cover the other 4 findings; this disagreement is recorded per master brief §10.3 step 4 ("Claude Code reads Codex's feedback; incorporates it or counter-argues explicitly in `docs/decisions/codex-disagreement-{date}.md` (the disagreement IS the signal — write it down, don't dissolve it)").
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:32:If Codex repeats this same finding at R18 against the unchanged text, escalate to founder per §10.3 step 5.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:82:- Master brief five rules + four boundaries (no architectural deviation)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/decisions/2026-05-18-day-7-single-sentence-test.md:3:**Date:** 2026-05-18 (per master brief §6 Day 7 calendar position; actual execution 2026-05-20)
docs/decisions/2026-05-18-day-7-single-sentence-test.md:6:**Source:** Master brief §6 Day 7 lines 492-501 + Ultraplan §12
docs/decisions/2026-05-18-day-7-single-sentence-test.md:12:From master brief §6 Day 7 lines 494-501 verbatim:
docs/decisions/2026-05-18-day-7-single-sentence-test.md:22:Master brief §6 Day 7 line 502 verbatim:
docs/decisions/2026-05-18-day-7-single-sentence-test.md:37:- **Master brief §6 Day 7 question 1 cannot be answered yes** until at least one UK recruitment-agency design partner has expressed pilot intent for Q3 2026 with a signed LOI or equivalent written commitment. None exists.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:43:- **Primitive 1 (Persistent PTY via PM2):** functional per Day-1 audit `docs/architecture/cortexos-primitive-status.md` — "shipped but flaky" per master brief §12 Risk #1. Day-1 audit found the substrate is operational for development workloads. Quirks 2-3 + 2026-04-22 restart-storm evidence document occasional instability under load, not broken.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:45:- **Primitive 5 (Telegram + iOS approval surface):** confirmed shipped per `cortexos-primitive-status.md` audit. Two-poller mechanism (`agent-manager.ts:478-575`, `maybeStartActivityChannelPoller()`) integrates with primitive 4 approval gates. Per master brief §12 Risk #1 framing: "Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5."
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:61:- **"Cleared the auth path" interpretation:** strict — "cleared" means the technical and commercial gates have both passed. Technical path documented (auth-code-against-IFOS-dev-tenant; `client_credentials` foreclosed per master brief §6 Day 2 atomic-correction Edit 6 verified at `0e5b2b4`). Commercial gates not passed. Q3 = NO.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:78:- **8 entities per master brief §6 Day 6 line 490:** `candidate`, `contractor`, `client`, `contact`, `brief` (with `role` alias), `placement`, `opportunity`, `timesheet`.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:100:**Week 0 EXTENDS per master brief §6 line 502.**
docs/decisions/2026-05-18-day-7-single-sentence-test.md:113:2. **`.codex/ratification/*.md` skills** — master brief §10.2 Day-1 task deferred during Days 0-6; surfaced as gap during Day-7 grounding. Build during extension period. 7 skill files (SKILL.md + 6 review-{type}.md per master brief §10.2). Estimated 2-3 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:114:3. **Master brief atomic-correction commit** — **landed today** at `0e5b2b4`. No further action.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:133:- If re-run produces 4 of 5 YES (Q3 still NO because Bullhorn commercial conversations haven't completed), founder may accept Q3 as risk-noted and declare Week 0 closed with Week 1 starting under that accepted risk. This is a founder-discretion call, not automatic from the master brief test.
docs/decisions/2026-05-18-codex-ratification-manifest.md:3:**Date:** 2026-05-18 (per master brief §6 Day 7 calendar; actual execution 2026-05-20)
docs/decisions/2026-05-18-codex-ratification-manifest.md:6:**Source:** Master brief §10 (the Codex ratification loop) + §10.6 (Day 7 first ratification run)
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:111:Round 4 scheduled across Week 3 (Days 14-20) per `docs/operations/goal-week-3-polish-and-scaffold.md` Steps 7 (Diagnostic-only, Day 15) + 13 (full run, Day 20). Per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 remediation max).
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:153:**Hard ceiling reached** per master brief §10.3 step 5. Single founder decision (approve the 5-category disposition) unlocks all 6 ratifications via a single Round-5 mechanical-remediation pass.
docs/decisions/2026-05-18-codex-ratification-manifest.md:157:**Round-4 disagreement protocol** (per master brief §10 + Day-8 pattern):
docs/decisions/2026-05-18-codex-ratification-manifest.md:205:## §2 — Ratification protocol per master brief §10.3
docs/decisions/2026-05-18-codex-ratification-manifest.md:207:Verbatim from master brief §10.3 (post-Edit 7 path correction):
docs/decisions/2026-05-18-codex-ratification-manifest.md:221:Master brief §10.2 (Day 0-1 task) specifies 7 skill files under `.codex/ratification/`:
docs/decisions/2026-05-18-codex-ratification-manifest.md:233:**Current state:** `.codex/ratification/` directory does not exist. Day 0-1 task was never executed during Days 0-6 (focus was on master brief §6 Day 0-6 critical path; `.codex/ratification/` slipped per master brief §10.6 framing "Claude does this; we don't ratify the ratification skills until Day 7" but skills themselves needed to be built first).
docs/decisions/2026-05-18-codex-ratification-manifest.md:245:| **Build `.codex/ratification/*.md` skills** | Week 0 extension period (concurrent with Q1 design-partner work) | 2-3 person-days. 7 skill files per master brief §10.2; each follows the "RATIFIED / REJECTED with numbered issues" output contract. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:246:| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
docs/decisions/2026-05-18-codex-ratification-manifest.md:247:| **Disagreement artefacts** | If Codex REJECTS or disagrees with any artefact | `docs/decisions/codex-disagreement-<date>.md` per master brief §10.3 step 4. Founder decides on escalations. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:253:**LANDED TODAY at `0e5b2b4`** — `docs: master brief reconciliation — 11 edits batch-applied`.
docs/decisions/2026-05-18-codex-ratification-manifest.md:277:**Master brief is fully reconciled** as of `0e5b2b4`. No further atomic-correction edits queued.
docs/decisions/2026-05-18-codex-ratification-manifest.md:288:| 9 | `brain-ui-scope.md` | Proposed pending v1.1 phase | Likely Codex ratifies as-is post-Edit 8 atomic correction (master brief §6 Day 3 line 472 + §5.5 now consistent). No founder action needed. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:303:3. **What landed today** (atomic-correction commit `0e5b2b4`; master brief fully reconciled).
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:20:**Counter:** Codex is applying the Day-7 single-sentence-test Q3 quality gate ("ATS decided + auth cleared") as if it were a Week-1 implementation gate. The Q3 gate is correct as a closing-of-Week-0 gate per master brief §6 line 502, and Q3 = NO is exactly why Week 0 EXTENDS per the Day-7 single-sentence-test result. But the Q3 gate governs **named v1.0 agent-build slices** (Diagnostic W3-4, Janitor W5, etc.), NOT Week-1 prerequisite code.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/brain-ui-scope.md:6:**Surfaced by:** Master brief §6 Day 3 line 472 — "Brain UI v1.0 scope decision" + ADR-002 §3.4 closing paragraph (Brain UI explicitly forward-deferred to v1.1) + `second-brain-design.md` §3.4 ("Brain UI minimal v1 is built as a thin read-only page over `decision_log` — no new wiki API needed").
docs/decisions/brain-ui-scope.md:9:**Reading order:** master brief §5.5 (Brain UI build sequence stages) + ADR-002 (parallel-not-shadow + v1.0 brain build wording correction) + `second-brain-design.md` §3.4 closing paragraph (Brain UI v1.0+ scope) first; then this document end-to-end.
docs/decisions/brain-ui-scope.md:15:Per master brief §5.5 (lines 416-424) after ADR-002 Edit 2 applies in the atomic correction commit, the staged Brain UI build is:
docs/decisions/brain-ui-scope.md:19:- **v1.2:** graph view (cytoscape force-directed, master brief §5.3 line 396).
docs/decisions/brain-ui-scope.md:20:- **v2.0:** second-brain-at-scale features (reflect-driven hygiene, voice-trend analytics, LoRA-version comparison views per master brief §5.5).
docs/decisions/brain-ui-scope.md:34:Three features named in master brief §5.5 (post-ADR-002-Edit-2 wording) + `second-brain-design.md` §3.4. Each feature scoped here without implementation commitment.
docs/decisions/brain-ui-scope.md:51:- No mobile-optimised layout (desktop-first per master brief §5.3 line 397 framework choice).
docs/decisions/brain-ui-scope.md:68:- No graph visualisation (text / list format only — graph view is v1.2 per master brief §5.5).
docs/decisions/brain-ui-scope.md:102:Add `/brain/*` routes to the existing cortextOS Next.js 14 dashboard at `packages/harness/cortextos/dashboard/`. Master brief §5.3 lines 380-403 already names this pattern: "**same Next.js app, additional routes in a sibling folder**, mounted via the dashboard's `dashboard-ext` integration point" at `packages/dashboard-ext/src/app/(dashboard)/brain/`.
docs/decisions/brain-ui-scope.md:105:- Tight coupling to cortextOS submodule (`packages/harness/cortextos/dashboard/`) — submodule boundary per master brief §3.1 must hold; the `dashboard-ext` integration point is the cortextOS-blessed extension surface, not a fork.
docs/decisions/brain-ui-scope.md:112:- Needs IFOS-owned auth — WorkOS AuthKit per master brief §5.3 line 401 ("Auth: WorkOS AuthKit (per memory: founder already uses this)").
docs/decisions/brain-ui-scope.md:121:| Auth model | cortextOS dashboard auth | WorkOS AuthKit per master brief §5.3 line 401 |
docs/decisions/brain-ui-scope.md:126:**Recommendation deferred to v1.1 planning.** Master brief §5.3 lines 379-380 currently favours Option α: "**The strategy: same Next.js app, additional routes in a sibling folder**, mounted via the dashboard's `dashboard-ext` integration point." That's the canonical-master-brief stance and is the default unless v1.0 ops surface a reason to deviate. This document does not bind the decision in v1.0 — it's revisited with v1.0-actual-usage evidence.
docs/decisions/brain-ui-scope.md:134:No UI work. Wiki API + Postgres + pgvector + filesystem is the v1.0 deliverable per ADR-002 Edit 2 + `second-brain-design.md` §3.4 closing paragraph. Master brief §5.5 already correctly scopes this (post-Edit-2). No new constraint from this document.
docs/decisions/brain-ui-scope.md:148:The v1.0 demo per master brief §10.6 live-demo pattern + Product Spec §10 closing-demo asset shows:
docs/decisions/brain-ui-scope.md:154:**No Brain UI tour in v1.0 sales motion.** Brain UI is a forward-feature, not a v1.0 sales asset. The closing demo is the agent outputs landing in the design partner's existing tools — the wedge per master brief §0 paragraph 1. Brain UI joins the sales asset list at v1.1.
docs/decisions/brain-ui-scope.md:168:Per pre-write check: master brief §6 Day 3 line 472 contains **three drifts** bundled into a single-line rewrite.
docs/decisions/brain-ui-scope.md:170:**Current** (master brief §6 Day 3 line 472 verbatim):
docs/decisions/brain-ui-scope.md:220:| Graph visualisation for backlinks panel (cytoscape force-directed) | v1.2 per master brief §5.5 — explicitly v1.2 milestone, not v1.1 |
docs/decisions/ADR-003-agent-bundle-renderer.md:13:ADR-002 §1.7-A surfaced the spec gap. Master brief §8 (lines 545-568) specifies the IFOS Agent Bundle v2 — six files plus three fixtures at `agents/recruitment/<name>/` — but is silent on how the bundle becomes a runnable cortextOS agent. The cortextOS daemon's `AgentManager.discoverAndStart()` (`packages/harness/cortextos/src/daemon/agent-manager.ts:906-941` `discoverAgents()`) reads from `${frameworkRoot}/orgs/<org>/agents/<name>/` with a cortextOS-shaped layout (`config.json`, `CLAUDE.md`, `.env`). The two layouts are incompatible without translation.
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:23:Per design §5.1: the cortextOS `cortextos-ifos add-agent` command is **unchanged**. IFOS does not use it for IFOS-owned agents. The renderer is a **new** command at `packages/agent-renderer/`, invoked via `ifos-render-agent <agent-name> --tenant <slug>` (standalone Node binary per `package.json` `bin`; **errata via ADR-004 Decision 1** — earlier drafts named this `cortextos-ifos render-agent` which would have required modifying the read-only submodule per master brief §3.1 boundary 1).
docs/decisions/ADR-003-agent-bundle-renderer.md:37:Three alternatives rejected per design §3.1: `packages/brain/agent-cli/` (wrong cohesion — brain is wiki, renderer is not a wiki concern); `scripts/render-agent.sh` (JSON Schema validation + YAML parsing harder in shell); new top-level directory (loses master brief §4.1 line 195-204 `packages/` convention).
docs/decisions/ADR-003-agent-bundle-renderer.md:39:**Invocation mode** per design §3.2: manual developer invocation. Day-1 cadence (founder + Claude Code), per-tenant scope explicit, hand-off boundary clean. Three alternatives rejected per design §3.2: pre-push hook (wrong filesystem — tenant vault on Hetzner UK VPS, hook on dev laptop), CI on merge (same reachability problem), daemon auto-watcher (wrong coupling — daemon is read-only on submodule per master brief §3.1).
docs/decisions/ADR-003-agent-bundle-renderer.md:60:Two alternatives rejected per design §3.4: merge-with-conflict-markers (premature complexity — master brief §1 Rule 1 "output before architecture" favours simple); refuse-if-exists (friction without benefit — Decision 1's marker-file check handles the actual risk).
docs/decisions/ADR-003-agent-bundle-renderer.md:66:## Master brief edits authorised by this ADR
docs/decisions/ADR-003-agent-bundle-renderer.md:68:**Errata 2026-05-20 (ADR-004):** Edit B's CLI command text was revised post-ADR-004 from `cortextos-ifos render-agent` to `ifos-render-agent`. The proposed text block below reflects the corrected name. See ADR-004 §"Master brief edits authorised" Edit D for the full disposition.
docs/decisions/ADR-003-agent-bundle-renderer.md:72:### Edit A — Master brief §4.1 directory list
docs/decisions/ADR-003-agent-bundle-renderer.md:74:**Current** (master brief §4.1 lines 195-204):
docs/decisions/ADR-003-agent-bundle-renderer.md:94:Lands in this ADR's commit. Edit A is the minimum required to make `packages/agent-renderer/` a canonical IFOS package per master brief §4.1; Week-1 renderer implementation depends on the path existing.
docs/decisions/ADR-003-agent-bundle-renderer.md:96:### Edit B — Master brief §8.3 working pattern
docs/decisions/ADR-003-agent-bundle-renderer.md:98:**Current** (master brief §8.3 lines 614-630):
docs/decisions/ADR-003-agent-bundle-renderer.md:131:### Edit C — Master brief §8 footnote referencing the renderer
docs/decisions/ADR-003-agent-bundle-renderer.md:133:**Current** (master brief §8 lines 545-568): bundle file list followed immediately by §8.1 ("The three v2 changes"). No footnote between §8 and §8.1.
docs/decisions/ADR-003-agent-bundle-renderer.md:139:Joins the deferred atomic correction commit (parallel to ADR-002 Edit 1 + Edit 2). Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/ADR-003-agent-bundle-renderer.md:151:**For the master brief atomic correction commit.** Edit C (the §8 footnote) joins ADR-001 + ADR-002 edits in the deferred single commit at end of Week 0 / early Week 1. Edits A and B land in this batch's commit because (a) Edit A is needed live before Week-1 renderer implementation can scaffold the package path, (b) Edit B is a small wording add to a code block, (c) neither is substantive enough to warrant the atomic-correction overhead.
docs/decisions/ADR-003-agent-bundle-renderer.md:163:1. Edits A and B applied to master brief §4.1 and §8.3 in this batch's commit.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/ADR-004-renderer-implementation-deviations.md:18:The three deviations are individually small. The reason this ADR exists rather than three inline `errata` notes in ADR-003 is master brief §10.5 ("Always-ratify list"): renderer architectural decisions go through Codex review, and a single coherent ADR is the audit-trail-friendly path. Reading ADR-003 + ADR-004 together gives the full ratified renderer surface.
docs/decisions/ADR-004-renderer-implementation-deviations.md:30:**Why the deviation:** `cortextos-ifos` is the upstream CLI shipped from the cortextOS submodule at `/opt/homebrew/bin/cortextos-ifos`. Adding a `render-agent` subcommand to that binary requires modifying source in `packages/harness/cortextos/`, which violates master brief §3.1 boundary 1 (cortextOS submodule read-only). The boundary is non-negotiable per master brief §3.1 + the build-pack discipline that the submodule is a "reference pin, not the runtime."
docs/decisions/ADR-004-renderer-implementation-deviations.md:41:- Master brief §8.3 Edit B (the `cortextos-ifos render-agent {name} --tenant <slug>` invocation line in the agent-development working pattern) needs an update — see §"Master brief edits authorised" below.
docs/decisions/ADR-004-renderer-implementation-deviations.md:79:- **Prefix `_shared/` with a dotfile** (`.shared/`) to make the listAgents scan skip it. Rejected — Bash glob conventions + Postgres conventions both treat dot-prefix as "hidden", and we'd lose the discoverable convention that `_shared/` follows IFOS naming rules. Also drifts further from the master brief vocabulary.
docs/decisions/ADR-004-renderer-implementation-deviations.md:80:- **File an upstream issue / PR against cortextOS** to filter out `_shared/` (and other underscore-prefixed names) in `listAgents()`. **Recommended path** — open an issue on the cortextOS repo per master brief §3 boundary 1 ("the submodule is a reference pin, not the runtime; upstream changes go upstream"). Phase 2 ships the deviation as documented; founder + upstream maintainer fix it on their schedule.
docs/decisions/ADR-004-renderer-implementation-deviations.md:89:## Master brief edits authorised by this ADR
docs/decisions/ADR-004-renderer-implementation-deviations.md:91:**Edit D — Master brief §8.3 working pattern line 121 (post-ADR-003 Edit B).**
docs/decisions/ADR-004-renderer-implementation-deviations.md:93:Current (post-ADR-003 Edit B at master brief §8.3 lines 614-630):
docs/decisions/ADR-004-renderer-implementation-deviations.md:136:> "invoked via `ifos-render-agent <agent-name> --tenant <slug>` (CLI signature per design §3.3.1 + ADR-004 Decision 1; standalone Node binary per `packages/agent-renderer/package.json` `bin`. The `cortextos-ifos render-agent` form named in earlier drafts requires modifying the read-only submodule and was rejected per master brief §3.1 boundary 1)."
docs/decisions/ADR-004-renderer-implementation-deviations.md:148:**For master brief drift.** Edit D + Edit E + Edit F enter the deferred atomic-correction queue (if not landed in this commit). Risk #7 (master-brief-drift-accumulation) is currently closed; reopening it for 3 small text edits is honest but tracked here. Founder decides at ratification time whether to land in this commit or queue for the next atomic correction.
docs/decisions/ADR-004-renderer-implementation-deviations.md:150:**For future Diagnostic builds.** Decision 1 means agents/runbooks/onboarding-wizard documentation references `ifos-render-agent`, not `cortextos-ifos render-agent`. Cheap to update everywhere because no documentation has shipped yet — only ADR-003 + master brief §8.3 reference the old name, and both are addressed in §"Master brief edits authorised."
docs/decisions/ADR-004-renderer-implementation-deviations.md:160:- Land ADR-004 commit with the three §"Master brief edits authorised" applied verbatim
docs/decisions/ADR-004-renderer-implementation-deviations.md:162:- Reopen Risk #7 with edit count = 3 (Edits D + E + F) for tracking
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:33:// EXISTS in upstream — read-only submodule per master brief §3.1 boundary 1
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
docs/decisions/autosend-approval-bridge-spec.md:261:**Founder decision:** schedule for Week 9 (sequential with master brief) OR insert now (parallel with Diagnostic prep).

exec
/bin/zsh -lc 'ls docs/decisions && rg -n "''^# ADR-00|''^## Context|''^## Decision|''^## Alternatives|''^## Consequences|Status:" docs/decisions/ADR-*.md -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
2026-05-18-codex-ratification-manifest.md
2026-05-18-day-7-single-sentence-test.md
2026-05-20-codex-round-1-founder-decisions.md
ADR-001-bus-dispatcher-poll-not-chokidar.md
ADR-002-brain-system-as-parallel-not-shadow.md
ADR-003-agent-bundle-renderer.md
ADR-004-renderer-implementation-deviations.md
ADR-005-week-3-diagnostic-acceleration.md
ADR-006-diagnostic-gate-a-hybrid.md
ADR-007-concierge-gate-a-30min-sla-hybrid.md
README.md
autosend-approval-bridge-spec.md
autosend-safety-policy.md
brain-ui-scope.md
bullhorn-integration-path.md
codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md
codex-disagreement-2026-05-24-diagnostic-gate-a.md
codex-disagreement-2026-05-25-diagnostic-r17.md
sequencing-target.md
v1.0-kill-criterion.md
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:1:# ADR-007 — Concierge Gate A 30-minute draft SLA hybrid (Gate B leading metric, not per-draft hard-fail)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:3:**Status:** Proposed (2026-05-25, Day 20; W4 bilateral pass on Concierge agent.md surfaced this as Codex R3 Finding 3 — current scaffold reframes ULTRAPLAN A6 line 566 Gate A "every lifecycle event has a draft generated within 30 minutes" as a Gate B leading metric without an authoritative ADR backing the deviation. Awaits Codex `review-architecture-decision` ratification + founder Accept.)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:11:## Context
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:53:## Alternatives considered
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:63:## Decision
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:91:## Consequences
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:145:**Status:** Proposed; awaits Codex `review-architecture-decision` ratification (R19+) + founder Accept per master brief §10.3 step 5 if Codex still disagrees.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:1:# ADR-005 — Week-3 Diagnostic acceleration (Bullhorn MCP deferred)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:3:**Status:** Accepted (2026-05-24, Day 13)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:11:## Context
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:33:## Decision
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:54:## Consequences
docs/decisions/ADR-003-agent-bundle-renderer.md:1:# ADR-003 — Agent Bundle v2 renderer
docs/decisions/ADR-003-agent-bundle-renderer.md:7:**Status:** Accepted. Founder decision logged 2026-05-16.
docs/decisions/ADR-003-agent-bundle-renderer.md:11:## Context
docs/decisions/ADR-003-agent-bundle-renderer.md:19:## Decision
docs/decisions/ADR-003-agent-bundle-renderer.md:141:## Consequences
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:1:# ADR-002 — Brain system as parallel, not shadow
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:7:**Status:** Accepted — Option α. Founder decision logged 2026-05-16.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:11:## Context
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:23:## Decision
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:107:## Consequences
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:133:1. ADR-001 + ADR-002 master-brief edits LANDED in atomic-correction commit `0e5b2b4` (Day 7 2026-05-20). Status: closed.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:1:# ADR-001 — Bus dispatcher is poll-based, not chokidar-watched
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:7:**Status:** Accepted — Option A. Founder decision logged 2026-05-16.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:11:## Context
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:28:## Decision
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:55:## Consequences
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:1:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:11:## Context
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:39:## Decision
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:99:## Consequences
docs/decisions/ADR-004-renderer-implementation-deviations.md:1:# ADR-004 — Renderer implementation deviations from ADR-003
docs/decisions/ADR-004-renderer-implementation-deviations.md:8:**Status:** Proposed
docs/decisions/ADR-004-renderer-implementation-deviations.md:12:## Context
docs/decisions/ADR-004-renderer-implementation-deviations.md:22:## Decision
docs/decisions/ADR-004-renderer-implementation-deviations.md:142:## Consequences

codex
The first pass found the ADR file and the referenced shared escalation catalogue entries. I’m narrowing on citation accuracy now, because this artefact makes several line/section claims that are load-bearing.
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/agent.md | sed -n '1,40p;190,225p;260,290p;400,435p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Concierge — no candidate ghosted
     2	
     3	**Status:** Proposed.
     4	**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (today): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) drafted at `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md`; Concierge Status flip Proposed → Accepted requires ADR-007 RATIFIED. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + ADR-007 RATIFIED + W10 build slice.
     5	**Date:** 2026-05-24.
     6	**Author:** Founder (Maddox) + Claude Code.
     7	**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
     8	**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
     9	**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).
    10	
    11	---
    12	
    13	## §1 — Output contract (one-paragraph screenshot)
    14	
    15	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    16	
    17	> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts (both per ULTRAPLAN A6 line 567); + ≥90% 30-min SLA hit rate (per ADR-007 — the 90% threshold is NOT in ULTRAPLAN line 567; it is the Gate B reframe of ULTRAPLAN line 566's per-draft 30-min hard-fail, introduced by ADR-007 and amended into ULTRAPLAN line 567 in the same commit). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
    18	
    19	---
    20	
    21	## §2 — Invocation surface
    22	
    23	### Lifecycle webhook (v1.0 primary)
    24	
    25	```http
    26	# Bullhorn placement state-change webhook → Concierge handler
    27	POST https://<tenant>.ifos.app/agents/concierge/webhook
    28	Authorization: Bearer <bullhorn-shared-secret>
    29	Content-Type: application/json
    30	
    31	{
    32	  "event_type": "placement.state_changed" | "candidate.state_changed",
    33	  "entity_id": "<bullhorn-id>",
    34	  "from_state": "interview_scheduled",
    35	  "to_state": "interview_completed",
    36	  "timestamp": "<ISO>"
    37	}
    38	```
    39	
    40	Bullhorn webhook coverage is patchy per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha — see Step 1 polling fallback.
   190	     ANN-matched on event_type + tone rules filtered for concierge +
   191	     comms-template structure)
   192	   → output = email body + subject + recommended_send_time
   193	   → write to /vault/<tenant>/concierge-drafts/<draft_id>.md
   194	   → hh_decision_output("concierge_draft_rendered",
   195	     "candidate:<bullhorn_id>:<event_type>", "vault_path:<path>; voice_score:<N>; words:<N>")
   196	   → ESC_VOICE_DRIFT if classifier score below the escalation_position-specific
   197	     threshold (position 1 ≥0.75; position 2 ≥0.78; position 3 ≥0.82 per Step 8)
   198	     after 3 retries — the position is set in Step 6 and is the per-draft Gate A
   199	     threshold. Generic <0.75 floor would understate position 2-3 sensitivity.
   200	
   201	8. Voice + tone validation
   202	   → voice classifier scores the draft
   203	   → minimum threshold by escalation_position:
   204	     position 1: ≥0.75
   205	     position 2: ≥0.78
   206	     position 3 (rejections / sensitive): ≥0.82
   207	   → tone-rule check (block-severity rules → ESC_TONE_RULE_VIOLATION)
   208	   → on success: hh_decision_action("concierge_email_draft",
   209	     "<candidate_bullhorn_id>:<event_type>", payload_hash, payload_preview);
   210	     tier=yellow per autosend-policy.yaml
   211	
   212	9. SLA timing check (Gate B leading metric — NOT Gate A hard-fail)
   213	   → elapsed = now() - event_timestamp
   214	   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
   215	   → per ULTRAPLAN A6 line 566 verbatim "every lifecycle event has a draft
   216	     generated within 30 minutes" — interpreted as a Gate B leading metric
   217	     (90% of drafts within 30 min) rather than per-draft hard fail (legitimate
   218	     polling-fallback delays would otherwise block drafts entirely)
   219	
   220	10. PII boundary check
   221	    → no PII from other candidates referenced in body
   222	    → no PII from competitor clients referenced
   223	    → no compensation specifics outside what's already in candidate's record
   224	    → ESC_PII_LEAKAGE_RISK on hit (blocking)
   225	    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
   260	
   261	15. Session close + Gate B metric
   262	    → compute elapsed (event → send) for Gate B SLA tracking
   263	    → check ghosted-rate metric (any candidate with no Concierge action in
   264	      14 days post-state-change → contributes to ghosted-rate)
   265	    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
   266	    → hh_decision_action("concierge_run_complete", session_id, run_mode)
   267	    → exit code 0
   268	```
   269	
   270	---
   271	
   272	## §5 — Gates
   273	
   274	### Gate A — validate.sh (hard-fail before action)
   275	
   276	Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
   277	
   278	- **"voice classifier score ≥ position-specific threshold"** (≥0.75 position 1, ≥0.78 position 2, ≥0.82 position 3) — hard-fail
   279	- **"correct addressee resolution (no candidates emailed under another's name)"** — hard-fail (Step 4 critical; ESC_ADDRESSEE_MISMATCH)
   280	- No tone-rule block-severity violations — hard-fail (ESC_TONE_RULE_VIOLATION)
   281	- No PII outside firm boundary — hard-fail (ESC_PII_LEAKAGE_RISK)
   282	- Anti-duplicate guard passed (Step 2) — hard-fail (skip if true duplicate)
   283	- All Bullhorn context fields present (no missing candidate name / no missing email) — hard-fail (ESC_AGENT_OUTPUT_SHAPE; ESC_CANDIDATE_DATA_INCOMPLETE is Sourcing Scout's per catalogue §2.10)
   284	
   285	The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
   286	
   287	Gate A failures fire `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` or `ESC_PII_LEAKAGE_RISK` or `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint — missing Bullhorn context OR voice threshold misses persistently) — all blocking; draft to `/tmp`; operator notified immediately.
   288	
   289	**Honesty note (per bilateral-disposition Cat-5):** Concierge `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W10-13 build slice. The W10-13 build delivers `agents/recruitment/concierge/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   290	
   400	
   401	| # | Question | Resolution path |
   402	|---|---|---|
   403	| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
   404	| Q2 | Lifecycle event taxonomy — 12 events proposed in §3. Founder confidence each is correct + complete? Missing: "candidate referred to another role internally"? "Client cancelled brief"? | Founder review with first pilot consultants. Recommend: ship 12-event v1.0; expand v1.1+ based on real patterns. |
   405	| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
   406	| Q4 | Rejection emails (event 6) — Position 3 (voice ≥0.82). Is this enough, or should rejections route to consultant for full draft (not just approve)? | Founder review with first pilot consultant. Recommend: Concierge drafts; consultant approves; never bypasses voice gate. |
   407	| Q5 | Comms-template customisation — every tenant edits these. Per-event-type, per-recipient-role × per-tenant = 24+ templates each. Authoring tool? | v1.0: Markdown files at `/vault/<slug>/concierge-templates/<event>-<role>.md`. v1.1: Brain UI WYSIWYG editor. |
   408	| Q6 | Send-as-is rate (Gate B ≥60%) — measurement requires consultant to differentiate "approve" from "edit-and-approve". Brain UI v1.0 has no such control yet. Telegram-based approval? | Telegram-based for v1.0: `/approve <draft-id>` vs `/approve-edit <draft-id> <revised-body>`. Brain UI v1.1+ adds inline edit UX. |
   409	| Q7 | Anti-duplicate guard window — 24h proposed in Step 2. Edge case: webhook + poll cycle both fire same event within 5 min → second skipped. What if first failed silently? | Anti-duplicate also checks decision_log for `phase='action'` not just `phase='trigger'` — if first didn't send, second can attempt. |
   410	| Q8 | agent-identity email adapter (deferred) (v1.1+) — agent-identity sends. Should Concierge use agent-identity email adapter (deferred) for rejection emails (less personal pressure on consultant approving) or always tenant-identity? | v1.0: tenant-identity (Microsoft Graph / Gmail). v1.1+: agent-identity email adapter (deferred) experiment per tenant opt-in. |
   411	| Q9 | Cross-tenant lifecycle handling — what if a candidate placed at Tenant A's client interviews at Tenant B 6 weeks later? Bullhorn has separate tenant slugs; no cross-tenant leak. But operator visibility? | v1.0: strict tenant isolation (no cross-tenant data visibility). v1.1+: separate agent for tenant-network-graph if commercial demand. |
   412	| Q10 | 90-day check-in (event 12) — relationship-building tone. Should Concierge also surface "anyone in your network looking?" referral request? | Founder review with first pilot consultant + tenant brand voice. Recommend: opt-in via tenant config. |
   413	
   414	### Gotchas (carried forward from ULTRAPLAN A6 line 569-570)
   415	
   416	1. **Lifecycle event detection from Bullhorn is the unreliable bit.** Bullhorn's webhook coverage is patchy; polling fallbacks are required. Step 1 polling at 5-min cycle + anti-duplicate guard at Step 2 is the architecture.
   417	2. **Voice quality on rejections is the hardest test case.** Position-3 threshold (≥0.82) + sensitive-event escalation routing (Step 6). Get this wrong and it costs the tenant a candidate relationship.
   418	3. **Comms-template library is per-tenant, per-event-type, per-recipient-role.** 24+ templates per tenant minimum. Authoring effort is significant; consider this in pilot onboarding scoping.
   419	4. **Microsoft Graph vs Gmail per-tenant** — each tenant chooses based on their existing email stack. v1.0 supports both; v1.1+ may add agent-identity email adapter (deferred).
   420	
   421	---
   422	
   423	## §10 — When this document ratifies
   424	
   425	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   426	
   427	Status flips Proposed → Accepted when:
   428	- Codex Round 4 Phase 2 ratifies
   429	- **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes the documented deviation from ULTRAPLAN A6 line 566 wording. ADR drafted at `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` (Day 20 W4 bilateral pass); ratifies via `.codex/ratification/review-architecture-decision.md` skill. Until RATIFIED, agent.md's Gate B framing of the 30-min SLA is documented disposition only.
   430	- **Founder Decision D1 RESOLVED** (Q1 above) — without this, Concierge build cannot start
   431	- Founder approves §9 Q2 (lifecycle taxonomy) + Q3 (send window) + Q4 (rejection routing) + Q5 (template authoring UX) + Q6 (Gate B UX)
   432	- Q7-Q9 documented decisions captured
   433	
   434	Status flips Accepted → In Force when:
   435	- W10-13 build slice produces all 5 sibling bundle files + 5 fixtures (broader fixture coverage warranted by XL complexity)

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '360,450p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   441	#### `ESC_SCRIBE_SLA_MISS`
   442	- **Severity:** warn
   443	- **Trigger:** Scribe SLA breached (default: call summary rendered within 30 min of call end; Bullhorn note attached within 1h)
   444	- **Phase:** `gating_failed`
   445	- **Routing:** `operator_chat_id`
   446	- **Payload fields:** `call_id`, `sla_type` (`summary_render` | `note_attach`), `sla_threshold_seconds`, `actual_elapsed_seconds`, `tenant_slug`
   447	
   448	#### `ESC_LIFECYCLE_STATE_UNKNOWN`
   449	- **Severity:** warn — agent cannot determine entity state for downstream action
   450	- **Trigger:** Lifecycle state is ambiguous or outside the agent's known taxonomy. Two canonical use cases:

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '550,575p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   566	- **Gate A:** voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82 per escalation_position); correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
   567	- **Gate B target:** <5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate (per ADR-007)
   568	- **Build complexity:** **XL** (4 weeks) — this is the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)
   569	- **Gotchas:** Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks. Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship.
   570	
   571	### 8.2 v1.1 agents (seven, in build order)
   572	
   573	#### A7. Inbound Triage (priority 1, 4 weeks)
   574	
   575	- **Build wave:** v1.1 (Q4 2026 weeks 1–4)

exec
/bin/zsh -lc "rg --files | rg 'master|MASTER|brief|BRIEF'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
legacy/v1/docs/phase-5-business-legal/marketing/trademark-filing-brief.md
docs/build-brief/00-MASTER-BRIEF.md
docs/_supplementary/planning-phase-brief.md
legacy/v1/MASTER-INDEX.md
legacy/v1/docs/phase-0-strategic/intelforce-planning-phase-brief.md

exec
/bin/zsh -lc "nl -ba .codex/ratification/review-schema-change.md | sed -n '1,80p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Codex ratification skill — review-schema-change
     2	
     3	Type-specific checks for: `docs/verticals/recruitment/vertical-schema.yaml` + any v0.X supplement file (`vertical-schema.vN.M-supplement.yaml`).
     4	
     5	This skill ADDS to the top-level `SKILL.md`. Apply that first; everything below is incremental.
     6	
     7	---
     8	
     9	## §1 — Schema layering invariant
    10	
    11	IFOS vertical schemas layer above Day-4 §6.3 generic Postgres primitives:
    12	
    13	```
    14	entities (id, tenant_slug, entity_type, entity_id, data JSONB, version, ...)
    15	entity_links (..., source_entity_type, source_entity_id, target_entity_type, target_entity_id, link_type, ...)
    16	decision_log (..., agent_name, phase, payload JSONB, ...)
    17	```
    18	
    19	The vertical schema specifies (a) which `entity_type` slugs are valid, (b) what JSON shape `entities.data` takes per entity_type, (c) which `link_type` slugs are valid. **Schemas DO NOT create new Postgres tables in v0.X** — supplements that propose new tables (e.g., `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`) MUST be paired with explicit `docs/verticals/recruitment/migrations/vN.M-to-vN.M+1.sql` companion files OR explicitly mark the new tables as "auxiliary v0.X tables, not entities".
    20	
    21	REJECT if a schema declares a new entity_type without naming whether it lives in `entities.data` JSONB OR in a new auxiliary table; the layering should be explicit.
    22	
    23	---
    24	
    25	## §2 — Per-entity required fields
    26	
    27	Every entity_type definition MUST include:
    28	
    29	- `description` — 1-2 sentence canonical definition in IFOS vocabulary
    30	- `bullhorn_source` — exactly one of:
    31	  - `Bullhorn.<Entity>` (with optional `where` clause)
    32	  - `none (IFOS-derived from <source>)`
    33	  - `none (IFOS-internal; not synced to ATS)`
    34	- `v1_0_agent_access` — list of agents from master brief §8.2 with R / W / R+W disposition, OR explicit "none (v1.1+ exercise)"
    35	- `canonical_fields` — at least 5 fields with type + required + source (Bullhorn path OR IFOS-derived)
    36	
    37	REJECT if any of these are missing.
    38	
    39	For each field within `canonical_fields`:
    40	
    41	- `type` — one of `string | integer | number | boolean | array | object | timestamp | date`
    42	- `required` — boolean
    43	- `source` — `Bullhorn.<Entity>.<field>` OR `IFOS-derived` (with note on how)
    44	- `notes` — optional but recommended for non-obvious fields
    45	
    46	REJECT if any field lacks `type`, `required`, or `source`.
    47	
    48	---
    49	
    50	## §3 — JSON Schema compatibility (for entities.data shape)
    51	
    52	Field types declared in the YAML must round-trip to valid JSON Schema. Cross-check against `packages/agents-runtime/_shared/common-*.json`:
    53	
    54	- If a field's `type: array`, the YAML must imply item type (via `notes: Items: <type>`)
    55	- If a field's `type: object`, the YAML must imply nested shape OR be explicitly free-form
    56	- If a field references a `voice_classifier_score` or similar [0.0, 1.0] bounded value, confirm the migration SQL adds a CHECK constraint OR a trigger
    57	
    58	REJECT if YAML field types cannot be expressed as JSON Schema for entities.data.
    59	
    60	---
    61	
    62	## §4 — Relationship definitions
    63	
    64	`relationships:` (or `additional_relationships:` in supplements) defines `entity_links.link_type` values. Each MUST include:
    65	
    66	- `source` — entity_type
    67	- `target` — entity_type
    68	- `cardinality` — `1:1 | 1:N | N:1 | M:N`
    69	- `description` — 1-2 sentences
    70	- `v1_0_exercise` — which agents use this link OR explicit "none (v1.1+)"
    71	
    72	REJECT if cardinality is missing or contradicts the agent_access_matrix (e.g., cardinality says `1:N` from candidate → placement but matrix has both as R+W to placement, implying M:N).
    73	
    74	Cross-referenced entities MUST exist in this schema OR a previous version (v0.1 for v0.2 supplement). REJECT if relationship references an undefined entity_type.
    75	
    76	---
    77	
    78	## §5 — Agent access matrix consistency
    79	
    80	`agent_access_matrix:` must list every v1.0 agent (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) + state R / W / R+W / none for every entity_type.

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '1,40p;650,735p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Intel Force OS v2 — Master Brief for Claude Code
     2	
     3	**Drop location:** `~/code/CortexOS/CLAUDE.md` (the working repo) and `~/code/CortexOS/docs/build-brief/00-MASTER-BRIEF.md`.
     4	
     5	**Synthesis stance:** First principles. The build pack in `docs/build-pack/` is **ignored** per founder instruction. The CLAUDE.md currently in the repo describes paths, remotes, and red lines — those are kept. Everything else in this brief is rebuilt from the verified state of the two upstream repos (`grandamenium/cortextos`, `tarsclaw/intel-force-os-v2`), Karpathy's LLM-wiki pattern, and the recruitment product spec, ultraplan, and 24/7 directive.
     6	
     7	**Verified on:** 16 May 2026 against `cortextos@0.1.1` and the `intel-force-os-v2` repo HEAD.
     8	
     9	**Reading order in Claude Code:**
    10	1. This document — read in full at session start
    11	2. `docs/specs/PRODUCT-SPEC.md` — what gets built (the 18-agent suite)
    12	3. `docs/specs/ULTRAPLAN.md` — how, in what order
    13	4. The §-references below to other primary docs
    14	
    15	If anything in `docs/build-pack/` conflicts with this brief, **this brief wins**. The build pack stays in-tree as historical record; the master brief is operative.
    16	
    17	---
    18	
    19	## 0. The thirty-second version
    20	
    21	You are building **Intel Force OS v2 (IFOS)**, an operations product for UK recruitment agencies, on top of **cortextOS** — the persistent 24/7 Claude Code agent runtime by `grandamenium/cortextos`.
    22	
    23	Three repositories are in play:
    24	
    25	```
    26	~/code/CortexOS/                     ← v2 codebase (this one). The product.
    27	├── packages/harness/cortextos/      ← cortextOS vendored at a pinned SHA. READ-ONLY.
    28	│                                       Only the four bus/kb-*.sh files are overridable
    29	│                                       per §3.4. Everything else: hands off.
    30	├── packages/...                     ← Our product code lives here.
    31	└── docs/...
    32	
    33	~/code/intel-force-os/               ← v1 codebase. ALIVE, do not modify.
    34	                                       Source of inheritance only. Read it,
    35	                                       lift the artefacts named in §7.
    36	
    37	~/code/cortex-os-upstream/           ← Upstream cortextOS clone, read-only.
    38	                                       For reference grep when the vendored copy
    39	                                       isn't enough. Tracks main.
    40	```
   650	                                            ┌──────────────────────────────────────┐
   651	                                            │  CONTEXT-ASSEMBLY API                │
   652	                                            │  packages/context-assembly/          │
   653	                                            │  Only thing that reads data layer.   │
   654	                                            │  Audit-logged. RLS-aware.            │
   655	                                            └──┬──────────┬──────────┬─────────────┘
   656	                                               │          │          │
   657	                  ┌────────────────────────────┘          │          └────────────────────────────┐
   658	                  ▼                                       ▼                                       ▼
   659	        ┌─────────────────┐                  ┌────────────────────────┐                  ┌────────────────────┐
   660	        │ THE VAULT       │                  │ ENTITY GRAPH (PG)      │                  │ DECISION LOG (PG)  │
   661	        │ /vault/{tenant}/│                  │ entities +             │                  │ tenant_decisions   │
   662	        │ Includes wiki/  │                  │ entity_relationships   │                  │ tenant_eval_sets   │
   663	        │ (raw + compiled)│                  │ RLS-isolated           │                  │ tenant_adapters    │
   664	        │ Obsidian-       │                  │ pgvector embeddings    │                  │ RLS-isolated       │
   665	        │ compatible MD + │                  └─────────┬──────────────┘                  └─────────┬──────────┘
   666	        │ frontmatter     │                            │                                           │
   667	        │ POSIX 0700      │                            │                                           │
   668	        │ git-backed      │                            │                                           │
   669	        └────────┬────────┘                            │                                           │
   670	                 │                                     │                                           │
   671	                 │ writes via kb-add                   │ writes via                                │ writes via
   672	                 │  → bus-overrides                    │   entity-graph svc                        │   hh_decision_*
   673	                 │                                     │                                           │
   674	        ┌────────┴─────────────────────────────────────┴───────────────────────────────────────────┴────────┐
   675	        │                                                                                                  │
   676	        │                                         AGENTS                                                   │
   677	        │   Run under PM2 process groups managed by cortextOS daemon                                       │
   678	        │                                                                                                  │
   679	        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
   680	        │   v1.1 (+7): Inbound Triage, Brief Decoder, Night Sourcer, Competitor Interception,              │
   681	        │              Client Hunter digest, T5 Supply Chain Auditor, T3 Compliance Watchtower             │
   682	        │   v1.2 (+5): Real-Time Pulse, Spec Pitcher, Reporting, T1 Onboarding Concierge, T2 Timesheet     │
   683	        │   v2.0 (+3): T4 IR35, T6 Pay & Bill, per-firm LoRA pipeline                                      │
   684	        │                                                                                                  │
   685	        └────────┬─────────────────────────────────────────────────────────────────────────────────────────┘
   686	                 │ tools via tools.yaml
   687	                 ▼
   688	        ┌────────────────────────────────────────────────────────────────────────────────────────────┐
   689	        │  VERTICAL ADAPTERS   packages/vertical-adapters/recruitment/                               │
   690	        │  Speak canonical vocabulary (candidate, placement, brief). Translate to backends.          │
   691	        └────────┬───────────────────────────────────────────────────────────────────────────────────┘
   692	                 ▼
   693	        ┌────────────────────────────────────────────────────────────────────────────────────────────┐
   694	        │  EXECUTION BACKENDS                                                                        │
   695	        │  • First-party MCP  packages/mcp-connectors/: Bullhorn, Companies House, Xero, etc.        │
   696	        │  • Composio (commodity SaaS): Gmail, Outlook, Slack, HubSpot                               │
   697	        │  • AgentMail (v1.1 Triage only): agent-identity inbox                                      │
   698	        │  • Direct vendor API: Microsoft Graph delegated send, Proxycurl LinkedIn                   │
   699	        └────────────────────────────────────────────────────────────────────────────────────────────┘
   700	```
   701	
   702	---
   703	
   704	## 10. The Codex ratification loop — second-pair every critical decision
   705	
   706	The founder asked specifically to ratify work through Codex and feed back to Claude Code. Because cortextOS does not (yet) have a first-class Codex runtime upstream, we run Codex as an **external CLI tool**, not as a cortextOS agent.
   707	
   708	### 10.1 Why this loop matters
   709	
   710	For a one-shot build of this size, single-model reasoning is risky. Claude and Codex (`gpt-5-codex`) catch different classes of mistakes:
   711	
   712	- Claude tends to over-elaborate on architecture; Codex is more conservative
   713	- Codex catches type/build issues more reliably; Claude catches semantic/specification issues
   714	- **Disagreements between them are the most valuable signal** — that's where the spec is ambiguous and needs founder decision
   715	
   716	### 10.2 Setup (Day 0–1)
   717	
   718	Install Codex CLI as part of the dev environment, not cortextOS. Drop the ratification skills under `.codex/ratification/`:
   719	
   720	| File | Purpose |
   721	|---|---|
   722	| `SKILL.md` | Top-level "what does ratify mean" — checks against the five rules + the boundary |
   723	| `review-agent-bundle.md` | Specific checklist for the 6 files + 3 fixtures of a new agent |
   724	| `review-mcp-connector.md` | Specific checklist for a new MCP connector |
   725	| `review-schema-change.md` | Specific checklist for `vertical-schema.yaml` edits |
   726	| `review-postgres-migration.md` | Specific checklist for new tables, RLS policy changes |
   727	| `review-architecture-decision.md` | Specific checklist for ADRs in `docs/decisions/` |
   728	| `review-harness-bump.md` | Specific checklist when bumping the pinned cortextos SHA |
   729	
   730	Each skill has the same shape: takes a diff or file set, checks against the five rules + the relevant spec doc, returns either `RATIFIED` (with optional minor notes) or `REJECTED` (with concrete issues numbered).
   731	
   732	### 10.3 The working loop
   733	
   734	Per change of meaningful size:
   735	

exec
/bin/zsh -lc 'rg -n "ESC_CONCIERGE_SLA_MISS|concierge_sla_threshold|detection_delay_seconds|concierge_30min|concierge_sla" docs/verticals agents docs/decisions/autosend-safety-policy.md agents/_shared/autosend-policy.yaml -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/escalation-codes.md:431:#### `ESC_CONCIERGE_SLA_MISS`
agents/recruitment/concierge/agent.md:214:   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
agents/recruitment/concierge/agent.md:285:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
agents/recruitment/concierge/agent.md:298:- **30-min SLA hit rate:** % of drafts generated within 30 minutes of lifecycle-event DETECTION. Target ≥90%. Per-draft misses fire `ESC_CONCIERGE_SLA_MISS`; rolling-window aggregate <90% fires `ESC_GATE_B_MISS`. (per ADR-007 + amended ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:320:| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |

exec
/bin/zsh -lc 'git rev-parse --verify f79c018''^{commit} && git show -s --format='"'%h %ci %s' f79c018" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
f79c0183732f4a3f925cd874255bec385341b444
f79c018 2026-05-24 18:48:01 +0100 update(concierge-r3-postv03): yellow draft tier + Step 7 decision-log + ULTRAPLAN line removed

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '732,790p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   732	### 10.3 The working loop
   733	
   734	Per change of meaningful size:
   735	
   736	1. **Claude Code** produces the artefact on a feature branch
   737	2. **You** run: `codex review --skill .codex/ratification/review-{type}.md --target {path-or-diff}`
   738	3. **Codex** returns RATIFIED or REJECTED with concrete issues
   739	4. **Claude Code** reads Codex's feedback; incorporates it or counter-argues explicitly in `docs/decisions/codex-disagreement-{date}.md` (the disagreement IS the signal — write it down, don't dissolve it)
   740	5. After ≤ 2 round-trips, merge. Still disagreeing? Escalate to founder to decide.
   741	
   742	### 10.4 What never goes through ratification
   743	
   744	- Comment-only changes
   745	- Test fixture additions (fixtures themselves are the ratification)
   746	- Documentation typos
   747	- Build/deps version bumps
   748	- Anything entirely inside `.agents/` (working notes)
   749	
   750	### 10.5 What ALWAYS goes through ratification
   751	
   752	- Every new `agent.md` before merge
   753	- Every change to `docs/verticals/recruitment/vertical-schema.yaml`
   754	- Every new MCP connector
   755	- Every Postgres migration touching tenant data
   756	- Every change to `agents/_shared/`
   757	- Every change to `packages/brain/bus-overrides/`
   758	- Every architectural decision record
   759	- Every bump of the pinned cortextos SHA
   760	- Every change to this brief itself (yes, recursive — Codex reviews changes to its own instructions)
   761	
   762	### 10.6 The ratification timeline
   763	
   764	For Week 0:
   765	- Day 1: build the `.codex/ratification/*.md` skills (Claude does this; we don't ratify the ratification skills until Day 7)
   766	- Day 7: Codex reviews the seven Week 0 artefacts (primitive audit, Bullhorn path, Brain UI scope, infra checklist, safety policy, kill criterion, vertical schema v0.1) — first ratification run
   767	
   768	After Week 0:
   769	- Every agent bundle is ratified before merge (mean cost: 20–30 min including round-trip)
   770	- Every schema change is ratified before merge (mean cost: 10–15 min)
   771	- Weekly ratification of risk register changes (informal — 5 min spot-check)
   772	
   773	---
   774	
   775	## 11. Working patterns in Claude Code
   776	
   777	### 11.1 What Claude Code is good at on this project
   778	
   779	- `agent.md` files given an output contract — long, structured, opinionated prompts are its sweet spot
   780	- `_shared/` shell helpers (voice loader, decision-log writer, validate primitives)
   781	- MCP connectors given OpenAPI spec + `tools.yaml` shape
   782	- Test fixtures (input.json + expected.md pairs)
   783	- YAML schema review for consistency with `vertical-schema.yaml`
   784	- Postgres migrations from `CREATE TABLE` in `docs/architecture/postgres-schema.sql`
   785	- Runbooks (`docs/runbooks/`) for operational scenarios
   786	- Customer-facing docs once agents are stable
   787	- `packages/brain/wiki/lib/*.ts` — the wiki ingest/compile/reflect pipeline
   788	
   789	### 11.2 What Claude Code is NOT good at on this project
   790	

exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md | sed -n '1,150p'" in /Users/madsadmin/code/CortexOS
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
    53	## Alternatives considered
    54	
    55	**Alternative A — Keep ULTRAPLAN A6 line 566 verbatim: 30-min SLA is per-draft Gate A hard-fail.** Rejected because Bullhorn webhook coverage is patchy per the ULTRAPLAN A6 gotcha (the same source spec acknowledging the polling-fallback requirement); per-draft hard-fail would drop legitimate drafts whose Concierge generation IS within 30 min of detection but whose upstream detection latency exceeded 30 min. The product harm: candidate experiences "ghosted by recruiter" — exactly the pattern Concierge was designed to prevent.
    56	
    57	**Alternative B — Remove the 30-minute SLA entirely.** Rejected because the SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Removing it would let drafts slip indefinitely with no quality signal — the "no candidate ghosted" goal becomes unmeasurable.
    58	
    59	**Alternative C — Measure occurrence-time (Bullhorn state-change timestamp) rather than detection-time (webhook arrival or polling-cron tick).** Rejected because Bullhorn state-change timestamps are not always reliable (Bullhorn webhook gotcha; some state changes lack a clean timestamp). Detection-time is what Concierge actually observes; occurrence-time would require infrastructure Concierge doesn't own.
    60	
    61	**Alternative D (selected) — Hybrid: voice + addressee checks stay Gate A; 30-min SLA moves to Gate B at 90% threshold.** Detection-time-based; population-level promise captured; per-draft outliers don't block.
    62	
    63	## Decision
    64	
    65	### Decision 1 — Move Concierge 30-minute SLA from Gate A hard-fail to Gate B leading metric (90% target)
    66	
    67	**Concierge Gate A is the subset of ULTRAPLAN A6 line 566 that is operationally enforceable per-draft:**
    68	
    69	- ✅ Voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82) — Gate A hard-fail
    70	- ✅ Correct addressee resolution (no candidates emailed under another's name) — Gate A hard-fail (`ESC_ADDRESSEE_MISMATCH`)
    71	- ✅ No tone-rule block-severity violations — Gate A hard-fail (`ESC_TONE_RULE_VIOLATION`)
    72	- ✅ No PII outside firm boundary — Gate A hard-fail (`ESC_PII_LEAKAGE_RISK`)
    73	- ✅ Anti-duplicate guard passed — Gate A hard-fail
    74	- ✅ All Bullhorn context fields present — Gate A hard-fail (`ESC_AGENT_OUTPUT_SHAPE`)
    75	
    76	**The 30-minute draft SLA moves to Gate B leading metric:**
    77	
    78	- 90% of drafts generated within 30 minutes of lifecycle-event DETECTION (not lifecycle-event occurrence)
    79	- Per-draft SLA miss fires `ESC_CONCIERGE_SLA_MISS` (warn, aggregated to Gate B)
    80	- Rolling 30-day per-tenant aggregate <90% fires `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) — actionable signal
    81	- v0.4 schema work: Concierge cycle.sh will record upstream-detection-latency separately in the audit payload (`payload.detection_delay_seconds`) once the field is declared and validated in a v0.4 supplement. v0.3 + v1.0 do NOT introduce this payload key — it would violate review-schema-change §3 (bounded values require CHECK or trigger). The metric attribution distinction (Concierge generation latency vs upstream polling latency) IS the right product behavior but the schema authority lands later.
    82	
    83	**ULTRAPLAN §8.1 A6 line 566 is amended in-band per the master brief §10.3 step 4 pattern** (analogue of the in-band amendment ADR-006 made at line 496):
    84	
    85	Pre-amendment:
    86	> - **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
    87	
    88	Post-amendment:
    89	> - **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
    90	
    91	## Consequences
    92	
    93	**Positive:**
    94	
    95	1. Concierge drafts are not dropped when upstream polling-fallback latency exceeds 30 minutes
    96	2. The product UX promise of "post-state-change comms within 30 minutes" is captured at the population level
    97	3. The metric attribution is clean — operators can distinguish Concierge generation latency from Bullhorn webhook/polling latency
    98	4. Structural parity with ADR-006: per-event Gate A vs aggregate Gate B as the canonical Tier-1/Tier-2 split for time-based SLAs (replicable pattern for future agents)
    99	
   100	**Negative:**
   101	
   102	1. A per-tenant 30-minute SLA promise is harder to enforce contractually — pilot agreements must reflect that the SLA is at the population level not per-event
   103	2. Tenants with high webhook coverage will see better than 90%; tenants with webhook-coverage gaps see worse — the metric reads as Concierge quality but is partly an upstream condition. Operator must look at `payload.detection_delay_seconds` distribution to disambiguate.
   104	3. The Concierge agent.md §10 Accepted criteria must include ratification of this ADR as a blocker (closing Codex R3 Finding 3 properly)
   105	
   106	**Neutral:**
   107	
   108	4. No code or schema changes required at scaffold stage — `agent.md` already reflects the Gate B framing. Update is to ULTRAPLAN line 566 (in-band amendment) + Concierge §10 (add ADR blocker) + this ADR (new artefact).
   109	
   110	## Implementation
   111	
   112	### In-band ULTRAPLAN amendment (applied with this ADR per master brief §10.3 step 4)
   113	
   114	ULTRAPLAN §8.1 A6 line 566 amended in the same commit as this ADR. Pre-amendment / post-amendment text is captured in this ADR's body. The amendment also updated line 567 Gate B target to include the new ≥90% 30-min SLA hit rate threshold (per ADR-007). See commit history for the diff.
   115	
   116	### Concierge §10 amendment
   117	
   118	Add to Accepted blockers (after R3 commit `f79c018` baseline):
   119	
   120	> - **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes R3 Finding 3 structural deviation; ratifies the agent.md §5 Gate A scope vs ULTRAPLAN A6 line 566 pre-amendment language.
   121	
   122	### Audit payload extension (deferred to v0.4 supplement)
   123	
   124	`decision_log.payload.detection_delay_seconds` is NOT introduced by this ADR. Queued for v0.4 supplement OR W10-13 build-slice schema addition (whichever ships first), with declaration + type validation landing together (per review-schema-change §3 — bounded values require CHECK or trigger). Concierge cycle.sh v0.0 does NOT write this key. Distinguishing Concierge generation latency from upstream polling latency in operational alerts is the v0.4 work item; v1.0 metrics use the elapsed (event-detection → draft-render) as a single number.
   125	
   126	## Open questions
   127	
   128	| # | Question | Resolution path |
   129	|---|---|---|
   130	| ADR-007-Q1 | Should the 90% threshold be per-tenant configurable, or is 90% a v1.0 fixed bar? | Recommend fixed at v1.0; v1.1 add per-tenant override via `tenant_adapters.config.concierge_sla_threshold` (new key, v0.4-pending). |
   131	| ADR-007-Q2 | Should `ESC_CONCIERGE_SLA_MISS` be a separate code, or should it reuse `ESC_GATE_B_MISS` with payload.metric='concierge_30min_sla'? | Recommend separate code for clean Telegram routing; `_GATE_B_MISS` is generic aggregate. Catalogue addition queued at W10-13 build start. |
   132	| ADR-007-Q3 | What's the polling-fallback interval default? | Per-tenant; recommend 5 min as v1.0 default; 1 min for tenants with stable webhook coverage. Documented in tools.yaml at W10-13 build. |
   133	
   134	## References
   135	
   136	- ADR-006 — Diagnostic Gate A hybrid (structural template for Tier 1 vs Tier 2 split)
   137	- ULTRAPLAN §8.1 A6 line 566 (pre-amendment authority)
   138	- `agents/recruitment/concierge/agent.md` §1, §4 Step 9, §5, §6 (Gate B framing already implemented)
   139	- `agents/_shared/escalation-codes.md` `ESC_CONCIERGE_SLA_MISS` (registered) + `ESC_GATE_B_MISS` (registered)
   140	- `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3
   141	- Master brief §1 Rule 4 (Quality gates before features) + §10.5 (ADRs are ratifiable artefacts)
   142	
   143	---
   144	
   145	**Status:** Proposed; awaits Codex `review-architecture-decision` ratification (R19+) + founder Accept per master brief §10.3 step 5 if Codex still disagrees.

exec
/bin/zsh -lc 'rg -n "Concierge Finding 3|Finding 3|30-minute|30-min|ADR-007" docs/operations/w4-bilateral-pass-6-agent-md.md logs/codex-ratification/20260524T174513Z-13185 -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/operations/w4-bilateral-pass-6-agent-md.md:60:### Finding 3. Gate A failure signature incomplete
docs/operations/w4-bilateral-pass-6-agent-md.md:96:### Finding 3. Wrong schema authority for recent_edit access
docs/operations/w4-bilateral-pass-6-agent-md.md:126:### Finding 3. v1.0 Bullhorn webhook path active despite blocked config
docs/operations/w4-bilateral-pass-6-agent-md.md:150:### Finding 3. Impossible draft audit-row shape (output phase with action_type)
docs/operations/w4-bilateral-pass-6-agent-md.md:174:### Finding 3. Ringover declared v1.0 without build dependencies
docs/operations/w4-bilateral-pass-6-agent-md.md:210:### Finding 3. Gate-A→Gate-B reframe omitted from §10 status-flip criteria
docs/operations/w4-bilateral-pass-6-agent-md.md:212:  - **Codex says:** "Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria. Either keep the 30-minute SLA as Gate A, or add the Concierge-Gate-A ADR ratification as an explicit Accepted blocker."
docs/operations/w4-bilateral-pass-6-agent-md.md:213:  - **Likely:** **SCOPE-EXPAND**. This is the analogue of ADR-006 for Diagnostic. W4 queue #3 already plans this ADR ("Future ADR — Concierge Gate A 30-min SLA hybrid"). Disposition options:
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.prompt.md:308:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.prompt.md:568:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md:321:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md:581:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md:1295:docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:46:| **A. Accept the floor** | Leave `pollInterval` at the 1000ms default. Rewrite Ultraplan §3.2's "four-agent pipelines complete in seconds" to "four-agent pipelines complete in 3-5 seconds end-to-end" and remove any "sub-second handoff" framing from the closing-demo deck | Zero engineering | Honest signal; Concierge's "30-min lifecycle event → drafted comms" SLA is unaffected (3-5s is rounding error against 30 minutes); Brief Decoder's "90-min brief-to-shortlist" is also unaffected. Only sales narrative changes. |
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md:1296:docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:52:2. The user-visible SLAs (Concierge 30-min lifecycle event, Brief Decoder 90-min shortlist, Triage 60-second response) all have ≥30× headroom against a 3-5 second pipeline floor. The pipeline-latency claim is sales narrative, not product SLA.
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md:2262:docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:46:| **A. Accept the floor** | Leave `pollInterval` at the 1000ms default. Rewrite Ultraplan §3.2's "four-agent pipelines complete in seconds" to "four-agent pipelines complete in 3-5 seconds end-to-end" and remove any "sub-second handoff" framing from the closing-demo deck | Zero engineering | Honest signal; Concierge's "30-min lifecycle event → drafted comms" SLA is unaffected (3-5s is rounding error against 30 minutes); Brief Decoder's "90-min brief-to-shortlist" is also unaffected. Only sales narrative changes. |
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md:2263:docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:52:2. The user-visible SLAs (Concierge 30-min lifecycle event, Brief Decoder 90-min shortlist, Triage 60-second response) all have ≥30× headroom against a 3-5 second pipeline floor. The pipeline-latency claim is sales narrative, not product SLA.
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md:2458:agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md:2489:agents/recruitment/concierge/agent.md:276:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md:2796:    16	> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md:3056:   276	The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md:3535:3. The 30-minute SLA is weakened without a ratified status-flip blocker. Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria. Either keep the 30-minute SLA as Gate A, or add the Concierge-Gate-A ADR ratification as an explicit Accepted blocker.
logs/codex-ratification/20260524T174513Z-13185/agents_recruitment_concierge_agent-md.output.md:3546:3. The 30-minute SLA is weakened without a ratified status-flip blocker. Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria. Either keep the 30-minute SLA as Gate A, or add the Concierge-Gate-A ADR ratification as an explicit Accepted blocker.

codex
REJECTED

1. Status is dishonest for an actioned decision. Line 3 and line 145 say `Status: Proposed` and awaiting founder Accept, but lines 83-89 and 112-114 say the ULTRAPLAN amendment is applied with this ADR; live `docs/specs/ULTRAPLAN.md` line 566 is already amended to point at ADR-007. Proposed means not ratified/actioned under the decision-doc skill. Fix by either reverting/defer-queuing the ULTRAPLAN amendment until Accept, or marking the ADR Accepted with a founder decision date.

2. Fabricated master-brief citation for the amendment process. Lines 83 and 112 cite “master brief §10.3 step 4” as the pattern for an in-band ULTRAPLAN amendment, but `docs/build-brief/00-MASTER-BRIEF.md` §10.3 step 4 only says Claude incorporates Codex feedback or writes a disagreement doc; it does not authorize in-band spec amendments. Fix by citing the actual authority for same-commit spec amendments or removing the claim.

3. Consequences rely on a payload key the ADR explicitly says does not exist in v1.0. Line 103 says operators “must look at `payload.detection_delay_seconds` distribution,” but lines 81 and 124 say v0.3/v1.0 do not introduce that key and v1.0 uses a single elapsed metric. This assumes an undeclared field and violates schema-before-code/honest-signal discipline. Fix line 103 to say this disambiguation is only available after the v0.4 schema supplement lands, and name the v1.0 fallback.

4. `ESC_CONCIERGE_SLA_MISS` status contradicts the live catalogue. Line 131 says the catalogue addition is “queued at W10-13 build start,” while line 139 says it is registered, and `agents/_shared/escalation-codes.md` lines 431-439 already define it. Fix Q2 to state the code is already registered, or remove the registered-code claims if the intended state is deferred.
tokens used
76,865
REJECTED

1. Status is dishonest for an actioned decision. Line 3 and line 145 say `Status: Proposed` and awaiting founder Accept, but lines 83-89 and 112-114 say the ULTRAPLAN amendment is applied with this ADR; live `docs/specs/ULTRAPLAN.md` line 566 is already amended to point at ADR-007. Proposed means not ratified/actioned under the decision-doc skill. Fix by either reverting/defer-queuing the ULTRAPLAN amendment until Accept, or marking the ADR Accepted with a founder decision date.

2. Fabricated master-brief citation for the amendment process. Lines 83 and 112 cite “master brief §10.3 step 4” as the pattern for an in-band ULTRAPLAN amendment, but `docs/build-brief/00-MASTER-BRIEF.md` §10.3 step 4 only says Claude incorporates Codex feedback or writes a disagreement doc; it does not authorize in-band spec amendments. Fix by citing the actual authority for same-commit spec amendments or removing the claim.

3. Consequences rely on a payload key the ADR explicitly says does not exist in v1.0. Line 103 says operators “must look at `payload.detection_delay_seconds` distribution,” but lines 81 and 124 say v0.3/v1.0 do not introduce that key and v1.0 uses a single elapsed metric. This assumes an undeclared field and violates schema-before-code/honest-signal discipline. Fix line 103 to say this disambiguation is only available after the v0.4 schema supplement lands, and name the v1.0 fallback.

4. `ESC_CONCIERGE_SLA_MISS` status contradicts the live catalogue. Line 131 says the catalogue addition is “queued at W10-13 build start,” while line 139 says it is registered, and `agents/_shared/escalation-codes.md` lines 431-439 already define it. Fix Q2 to state the code is already registered, or remove the registered-code claims if the intended state is deferred.
