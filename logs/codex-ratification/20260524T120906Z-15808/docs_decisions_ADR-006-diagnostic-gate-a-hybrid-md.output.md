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
session id: 019e59e3-9464-7621-a210-fc03426f8a1d
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

Path: docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md

--- BEGIN ARTEFACT ---

# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)

**Status:** Proposed (2026-05-24, Day 19)
**Author:** Founder (Maddox) + Claude Code
**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 497 — Gate A citation requirement
**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR

---

## Context

ULTRAPLAN §8.1 A1 line 497 specifies the Diagnostic Gate A citation requirement verbatim:

> Gate A: 12 sections present, each with sourced data link; no claims unsupported by source data; voice classifier score ≥ 0.75; no PII outside firm boundary.

The "no claims unsupported by source data" clause implies **per-claim citation validation** — every factual claim in the report must have a backing source link. The Diagnostic v0 implementation at `agents/recruitment/diagnostic/validate.sh` enforces **per-section citation** (regex `\[.+\]\(.+\)` requires ≥1 markdown link per section); per-claim validation is NOT implemented at v0.

This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:

1. NLP claim-extraction from the rendered Markdown report (sentence-level fact identification)
2. Per-claim evidence-link matching (semantic similarity between claim and cited URL content)
3. Confidence threshold tuning to avoid false rejections of well-cited paraphrases

This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.

Bilateral founder+Claude session on 2026-05-24 (Day 19) selected option **(b) — hybrid framing** as the disposition (Cat-1 in the disagreement doc). Founder authorization via AskUserQuestion accepted: "Hybrid (Recommended): v0 = per-section, W4 = per-claim spot-check".

This ADR formalises that disposition as a ratified architectural decision so future Codex rounds + agent.md §5 framing treat it as upstream-canonical, not as a downstream weakening.

---

## Decision

**Diagnostic Gate A citation validation is a two-tier policy:**

### Tier 1 (v0; hard-fail) — per-section citation coverage

Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`.

### Tier 2 (W4 polish; warn-only sampling) — per-claim citation spot-check

A statistical sample (1-in-N, configurable per tenant; default 1-in-10) of Diagnostic reports undergo post-render per-claim citation validation:

- NLP claim-extraction (sentence-level)
- Per-claim evidence-link matching (semantic similarity against cited URLs)
- Per-claim confidence score
- Aggregate report quality metric written to `decision_log.payload.per_claim_confidence_distribution`

Below threshold (e.g. <80% of claims with confidence ≥0.6) → warn (not block); operator review queue entry.

### W4 polish trigger

When the voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports, the per-claim spot-check pipeline activates. Until then, Tier 2 is documented intent only.

---

## ULTRAPLAN amendment

`docs/specs/ULTRAPLAN.md` §8.1 A1 line 497 reads (verbatim, before this ADR):

> Gate A: 12 sections present, each with sourced data link; no claims unsupported by source data; voice classifier score ≥ 0.75; no PII outside firm boundary.

After this ADR ratifies, the canonical reading is:

> Gate A: 12 sections present, each with sourced data link (per-section hard-fail at v0); per-claim citation spot-check via 1-in-N sampling (W4 polish; warn-only); voice classifier score ≥ 0.75; no PII outside firm boundary. See `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for the two-tier framing.

The ULTRAPLAN file itself is not edited (no rewriting of master specs in-place); ADR-006 is the binding authoritative interpretation. Reviewers consulting ULTRAPLAN §8.1 A1 see line 497 + the ADR-006 reference in commit history + the Diagnostic agent.md §5 explicit citation.

---

## Why hybrid not full-spec

**Why not (a) defer launch until per-claim lands?**
- Trigger 2 (Diagnostic-not-ratified-by-2026-06-14) fires in 21 days from Day 19; per-claim validation is ~6 weeks of work (NLP pipeline + tuning); deferral fires Trigger 2 with high confidence
- A working v0 with per-section validation has measurable Gate A coverage; deferring means no Gate A at all in the meantime, which is strictly worse
- The 30%-discovery-call Gate B target is independent of per-claim validation; pilot value is reachable without it

**Why not (c) amend ULTRAPLAN downward permanently?**
- The per-claim requirement is genuinely valuable for v1.1+ once the NLP pipeline exists
- Permanently removing it from ULTRAPLAN loses the documented quality bar
- Hybrid preserves the W4-polish path; permanent amendment closes that door

**Why hybrid is honest signal (Rule 5):**
- v0 implementation does what it says; W4 polish path is documented + scheduled
- Codex flags become explicit-disposition references (this ADR) not unaddressed weakening
- Pilot tenants reading Gate A spec see the v0 contract clearly + the W4 expansion plan

---

## Consequences

### Immediate (this ADR commit)

- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing now explicitly references ADR-006 (next commit after this ratifies)
- `agents/recruitment/diagnostic/validate.sh` retains current per-section enforcement (no implementation change)

### After Codex ratifies this ADR (Status flips Proposed → Accepted)

- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the unchanged ULTRAPLAN line 497 prose alone)
- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (ADR-007 Janitor Gate A, ADR-008 Scribe Gate A, etc.) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed

### W4-polish slice (after voice-classifier microservice ships + first pilot tenant data accumulates)

- Per-claim spot-check pipeline lands as Tier 2 validate.sh extension
- Sample rate configurable per tenant in `tenant_adapters.config.diagnostic_per_claim_sample_rate`
- Aggregate metric writes to `decision_log.payload.per_claim_confidence_distribution`
- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)

### Downstream artefact references

- `agents/recruitment/diagnostic/agent.md` §1 lines 16+ explicitly cite "Per ADR-006, Gate A is two-tier..."
- `agents/recruitment/diagnostic/agent.md` §5 lines 156+ explicitly cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section references ADR-006 as the closure mechanism
- `docs/decisions/2026-05-18-codex-ratification-manifest.md` adds this ADR as ratification queue item

---

## Open questions

| # | Question | Resolution path |
|---|---|---|
| Q1 | Default sample rate for Tier 2 spot-check? Recommend 1-in-10 (~10% of reports validated per-claim) for first pilot; adjust based on early signal | Founder review at first-pilot W4 polish landing |
| Q2 | NLP claim-extraction library — what's the right tool? (spaCy + custom rules / Claude API-based extraction / hosted service) | W4 polish technical investigation; cost vs accuracy tradeoff |
| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |

---

## Status

**Proposed.** Awaits Codex ratification via `review-architecture-decision.md` skill.

Status flips Proposed → Accepted when:
- Codex returns RATIFIED for this ADR
- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)

*End of ADR-006.*

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
I’m going to verify the ADR against the live repo: its filename/H1 sequence, cited ULTRAPLAN line/section, referenced disagreement doc, and any schema fields it relies on.
exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
     2	
     3	**Status:** Proposed (2026-05-24, Day 19)
     4	**Author:** Founder (Maddox) + Claude Code
     5	**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 497 — Gate A citation requirement
     6	**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
     7	**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
     8	
     9	---
    10	
    11	## Context
    12	
    13	ULTRAPLAN §8.1 A1 line 497 specifies the Diagnostic Gate A citation requirement verbatim:
    14	
    15	> Gate A: 12 sections present, each with sourced data link; no claims unsupported by source data; voice classifier score ≥ 0.75; no PII outside firm boundary.
    16	
    17	The "no claims unsupported by source data" clause implies **per-claim citation validation** — every factual claim in the report must have a backing source link. The Diagnostic v0 implementation at `agents/recruitment/diagnostic/validate.sh` enforces **per-section citation** (regex `\[.+\]\(.+\)` requires ≥1 markdown link per section); per-claim validation is NOT implemented at v0.
    18	
    19	This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
    20	
    21	1. NLP claim-extraction from the rendered Markdown report (sentence-level fact identification)
    22	2. Per-claim evidence-link matching (semantic similarity between claim and cited URL content)
    23	3. Confidence threshold tuning to avoid false rejections of well-cited paraphrases
    24	
    25	This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
    26	
    27	Bilateral founder+Claude session on 2026-05-24 (Day 19) selected option **(b) — hybrid framing** as the disposition (Cat-1 in the disagreement doc). Founder authorization via AskUserQuestion accepted: "Hybrid (Recommended): v0 = per-section, W4 = per-claim spot-check".
    28	
    29	This ADR formalises that disposition as a ratified architectural decision so future Codex rounds + agent.md §5 framing treat it as upstream-canonical, not as a downstream weakening.
    30	
    31	---
    32	
    33	## Decision
    34	
    35	**Diagnostic Gate A citation validation is a two-tier policy:**
    36	
    37	### Tier 1 (v0; hard-fail) — per-section citation coverage
    38	
    39	Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`.
    40	
    41	### Tier 2 (W4 polish; warn-only sampling) — per-claim citation spot-check
    42	
    43	A statistical sample (1-in-N, configurable per tenant; default 1-in-10) of Diagnostic reports undergo post-render per-claim citation validation:
    44	
    45	- NLP claim-extraction (sentence-level)
    46	- Per-claim evidence-link matching (semantic similarity against cited URLs)
    47	- Per-claim confidence score
    48	- Aggregate report quality metric written to `decision_log.payload.per_claim_confidence_distribution`
    49	
    50	Below threshold (e.g. <80% of claims with confidence ≥0.6) → warn (not block); operator review queue entry.
    51	
    52	### W4 polish trigger
    53	
    54	When the voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports, the per-claim spot-check pipeline activates. Until then, Tier 2 is documented intent only.
    55	
    56	---
    57	
    58	## ULTRAPLAN amendment
    59	
    60	`docs/specs/ULTRAPLAN.md` §8.1 A1 line 497 reads (verbatim, before this ADR):
    61	
    62	> Gate A: 12 sections present, each with sourced data link; no claims unsupported by source data; voice classifier score ≥ 0.75; no PII outside firm boundary.
    63	
    64	After this ADR ratifies, the canonical reading is:
    65	
    66	> Gate A: 12 sections present, each with sourced data link (per-section hard-fail at v0); per-claim citation spot-check via 1-in-N sampling (W4 polish; warn-only); voice classifier score ≥ 0.75; no PII outside firm boundary. See `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for the two-tier framing.
    67	
    68	The ULTRAPLAN file itself is not edited (no rewriting of master specs in-place); ADR-006 is the binding authoritative interpretation. Reviewers consulting ULTRAPLAN §8.1 A1 see line 497 + the ADR-006 reference in commit history + the Diagnostic agent.md §5 explicit citation.
    69	
    70	---
    71	
    72	## Why hybrid not full-spec
    73	
    74	**Why not (a) defer launch until per-claim lands?**
    75	- Trigger 2 (Diagnostic-not-ratified-by-2026-06-14) fires in 21 days from Day 19; per-claim validation is ~6 weeks of work (NLP pipeline + tuning); deferral fires Trigger 2 with high confidence
    76	- A working v0 with per-section validation has measurable Gate A coverage; deferring means no Gate A at all in the meantime, which is strictly worse
    77	- The 30%-discovery-call Gate B target is independent of per-claim validation; pilot value is reachable without it
    78	
    79	**Why not (c) amend ULTRAPLAN downward permanently?**
    80	- The per-claim requirement is genuinely valuable for v1.1+ once the NLP pipeline exists
    81	- Permanently removing it from ULTRAPLAN loses the documented quality bar
    82	- Hybrid preserves the W4-polish path; permanent amendment closes that door
    83	
    84	**Why hybrid is honest signal (Rule 5):**
    85	- v0 implementation does what it says; W4 polish path is documented + scheduled
    86	- Codex flags become explicit-disposition references (this ADR) not unaddressed weakening
    87	- Pilot tenants reading Gate A spec see the v0 contract clearly + the W4 expansion plan
    88	
    89	---
    90	
    91	## Consequences
    92	
    93	### Immediate (this ADR commit)
    94	
    95	- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
    96	- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing now explicitly references ADR-006 (next commit after this ratifies)
    97	- `agents/recruitment/diagnostic/validate.sh` retains current per-section enforcement (no implementation change)
    98	
    99	### After Codex ratifies this ADR (Status flips Proposed → Accepted)
   100	
   101	- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the unchanged ULTRAPLAN line 497 prose alone)
   102	- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (ADR-007 Janitor Gate A, ADR-008 Scribe Gate A, etc.) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
   103	
   104	### W4-polish slice (after voice-classifier microservice ships + first pilot tenant data accumulates)
   105	
   106	- Per-claim spot-check pipeline lands as Tier 2 validate.sh extension
   107	- Sample rate configurable per tenant in `tenant_adapters.config.diagnostic_per_claim_sample_rate`
   108	- Aggregate metric writes to `decision_log.payload.per_claim_confidence_distribution`
   109	- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
   110	
   111	### Downstream artefact references
   112	
   113	- `agents/recruitment/diagnostic/agent.md` §1 lines 16+ explicitly cite "Per ADR-006, Gate A is two-tier..."
   114	- `agents/recruitment/diagnostic/agent.md` §5 lines 156+ explicitly cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
   115	- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section references ADR-006 as the closure mechanism
   116	- `docs/decisions/2026-05-18-codex-ratification-manifest.md` adds this ADR as ratification queue item
   117	
   118	---
   119	
   120	## Open questions
   121	
   122	| # | Question | Resolution path |
   123	|---|---|---|
   124	| Q1 | Default sample rate for Tier 2 spot-check? Recommend 1-in-10 (~10% of reports validated per-claim) for first pilot; adjust based on early signal | Founder review at first-pilot W4 polish landing |
   125	| Q2 | NLP claim-extraction library — what's the right tool? (spaCy + custom rules / Claude API-based extraction / hosted service) | W4 polish technical investigation; cost vs accuracy tradeoff |
   126	| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |
   127	
   128	---
   129	
   130	## Status
   131	
   132	**Proposed.** Awaits Codex ratification via `review-architecture-decision.md` skill.
   133	
   134	Status flips Proposed → Accepted when:
   135	- Codex returns RATIFIED for this ADR
   136	- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
   137	
   138	*End of ADR-006.*

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '470,510p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   470	```
   471	Agent name + tier
   472	Build wave (v1.0 / v1.1 / v1.2 / v2.0)
   473	Always-on? (Tier 1 / Tier 2)
   474	Trigger type
   475	CortexOS primitives required
   476	MCP tools required
   477	Shared modules required
   478	External APIs / dependencies
   479	Gate A specifics
   480	Gate B target (restated from §7.2)
   481	Build complexity (S / M / L / XL where S=2 days, M=1 week, L=2 weeks, XL=4 weeks)
   482	Gotchas (the things that will bite us)
   483	```
   484	
   485	### 8.1 v1.0 agents (six)
   486	
   487	#### A1. The Diagnostic — the sales tool
   488	
   489	- **Build wave:** v1.0 (week 4–5)
   490	- **Always-on?** No — invoked on demand
   491	- **Trigger type:** Manual (run from CLI or sales-tool web page)
   492	- **CortexOS primitives required:** None — runs as a one-shot batch job
   493	- **MCP tools required:** Companies House, LinkedIn (read-only), web scraper for careers pages
   494	- **Shared modules required:** Voice loader (uses Maddox's voice for the audit narrative), decision log writer
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

exec
/bin/zsh -lc "rg --files docs/decisions docs/specs agents/recruitment/diagnostic migrations packages | sed -n '1,160p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
rg: migrations: No such file or directory (os error 2)
docs/specs/ULTRAPLAN.md
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/specs/_archive-build-handoff.md
docs/specs/PRODUCT-SPEC.md
docs/decisions/autosend-safety-policy.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/2026-05-18-day-7-single-sentence-test.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/decisions/sequencing-target.md
docs/decisions/bullhorn-integration-path.md
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md
docs/decisions/2026-05-18-codex-ratification-manifest.md
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
docs/decisions/README.md
docs/decisions/brain-ui-scope.md
docs/decisions/autosend-approval-bridge-spec.md
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md
agents/recruitment/diagnostic/cleanup.sh
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml
agents/recruitment/diagnostic/fixtures/01-primary.yaml
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml
agents/recruitment/diagnostic/cycle.sh
agents/recruitment/diagnostic/README.md
agents/recruitment/diagnostic/tools.yaml
agents/recruitment/diagnostic/validate.sh
agents/recruitment/diagnostic/context.sh
agents/recruitment/diagnostic/agent.md
packages/diagnostic-generator/README.md
packages/diagnostic-generator/src/generate.ts
packages/diagnostic-generator/src/cli.ts
packages/diagnostic-generator/src/firm-slug.ts
packages/diagnostic-generator/tests/conversation-opener.test.ts
packages/diagnostic-generator/tests/online-footprint.test.ts
packages/diagnostic-generator/tests/generate.test.ts
packages/diagnostic-generator/src/sections/online-footprint.ts
packages/diagnostic-generator/src/sections/firm-signal.ts
packages/diagnostic-generator/src/sections/recent-activity.ts
packages/diagnostic-generator/src/sections/pain-signals.ts
packages/diagnostic-generator/src/sections/stubs.ts
packages/diagnostic-generator/src/sections/conversation-opener.ts
packages/diagnostic-generator/src/sections/icp-fit.ts
packages/diagnostic-generator/vitest.config.ts
packages/diagnostic-generator/tsconfig.json
packages/diagnostic-generator/tsup.config.ts
packages/diagnostic-generator/package.json
packages/harness/PINNED-SHA.md
packages/agent-renderer/tsup.config.ts
packages/agent-renderer/package.json
packages/agent-renderer/README.md
packages/agent-renderer/pnpm-lock.yaml
packages/agent-renderer/src/renderer.ts
packages/agent-renderer/src/types.ts
packages/agent-renderer/src/atomicWrite.ts
packages/agent-renderer/src/fileMap.ts
packages/utilities/web-scraper/src/rate-limit.ts
packages/utilities/web-scraper/src/index.ts
packages/utilities/web-scraper/src/client.ts
packages/utilities/web-scraper/src/cache.ts
packages/utilities/web-scraper/src/errors.ts
packages/utilities/web-scraper/src/fetcher.ts
packages/utilities/web-scraper/src/robots.ts
packages/agent-renderer/src/synthesis/claudeMd.ts
packages/agent-renderer/src/synthesis/configJson.ts
packages/agent-renderer/src/synthesis/envFile.ts
packages/utilities/web-scraper/vitest.config.ts
packages/utilities/web-scraper/tsconfig.json
packages/utilities/web-scraper/tsup.config.ts
packages/utilities/web-scraper/package.json
packages/utilities/web-scraper/README.md
packages/agent-renderer/src/cli.ts
packages/agent-renderer/src/preflight.ts
packages/agent-renderer/vitest.config.ts
packages/agent-renderer/tsconfig.json
packages/agents-runtime/_shared/common-accounting.json
packages/agents-runtime/_shared/common-client.json
packages/agents-runtime/_shared/common-notifications.json
packages/agents-runtime/_shared/common-voice.json
packages/agents-runtime/_shared/common-vault.json
packages/agents-runtime/_shared/common-base.json
packages/agents-runtime/_shared/common-ats.json
packages/agents-runtime/_shared/common-target-patch.json
packages/utilities/web-scraper/pnpm-lock.yaml
packages/agent-renderer/templates/claude-md-preamble.md
packages/utilities/web-scraper/tests/fetcher.test.ts
packages/utilities/web-scraper/tests/scaffold.test.ts
packages/utilities/web-scraper/tests/cache.test.ts
packages/agent-renderer/tests/unit/fileMap.test.ts
packages/agent-renderer/tests/unit/preflight.test.ts
packages/agent-renderer/tests/unit/atomicWrite.test.ts
packages/agent-renderer/tests/unit/synthesis.test.ts
packages/mcp-connectors/companies-house/src/rate-limit.ts
packages/mcp-connectors/companies-house/src/index.ts
packages/mcp-connectors/companies-house/src/client.ts
packages/mcp-connectors/companies-house/src/cache.ts
packages/mcp-connectors/companies-house/src/types.ts
packages/mcp-connectors/companies-house/src/capabilities.ts
packages/mcp-connectors/companies-house/src/errors.ts
packages/mcp-connectors/companies-house/vitest.config.ts
packages/mcp-connectors/companies-house/tsconfig.json
packages/mcp-connectors/companies-house/tsup.config.ts
packages/mcp-connectors/companies-house/package.json
packages/mcp-connectors/companies-house/README.md
packages/agent-renderer/tests/fixtures/test-tenant-vault/test-tenant-b/_config.yaml
packages/agent-renderer/tests/fixtures/test-tenant-vault/test-tenant-b/_secrets.env
packages/mcp-connectors/companies-house/tests/scaffold.test.ts
packages/mcp-connectors/companies-house/tests/unit.test.ts
packages/mcp-connectors/companies-house/pnpm-lock.yaml
packages/agent-renderer/tests/fixtures/test-tenant-vault/migration-test/_config.yaml
packages/agent-renderer/tests/fixtures/test-agent/config.schema.json
packages/agent-renderer/tests/fixtures/test-tenant-vault/migration-test/_secrets.env
packages/agent-renderer/tests/fixtures/test-agent/validate.sh
packages/agent-renderer/tests/fixtures/test-agent/context.sh
packages/agent-renderer/tests/fixtures/test-agent/agent.md
packages/agent-renderer/tests/fixtures/test-agent/tools.yaml
packages/agent-renderer/tests/fixtures/test-agent/README.md
packages/agent-renderer/tests/fixtures/test-agent/tests/fixtures/01-primary/input.txt
packages/harness/cortextos/src/telegram/logging.ts
packages/harness/cortextos/src/telegram/media.ts
packages/harness/cortextos/src/telegram/index.ts
packages/harness/cortextos/src/telegram/api.ts
packages/harness/cortextos/src/telegram/poller.ts
packages/harness/cortextos/src/telegram/transcribe.ts
packages/agent-renderer/tests/fixtures/test-agent/tests/fixtures/02-edge-case-empty/input.txt
packages/agent-renderer/tests/fixtures/test-agent/tests/fixtures/99-voice-drift-canary/input.txt
packages/harness/cortextos/playwright.config.ts
packages/harness/cortextos/src/hooks/hook-idle-flag.ts
packages/harness/cortextos/src/hooks/index.ts
packages/harness/cortextos/src/hooks/hook-context-status.ts
packages/harness/cortextos/src/hooks/hook-planmode-telegram.ts
packages/harness/cortextos/src/hooks/hook-extract-facts.ts
packages/harness/cortextos/src/hooks/hook-crash-alert.ts
packages/harness/cortextos/src/hooks/hook-permission-telegram.ts
packages/harness/cortextos/src/hooks/hook-ask-telegram.ts
packages/harness/cortextos/src/hooks/hook-compact-telegram.ts
packages/harness/cortextos/src/daemon/fast-checker.ts
packages/harness/cortextos/src/daemon/index.ts
packages/harness/cortextos/src/daemon/ipc-server.ts
packages/harness/cortextos/src/daemon/cron-scheduler.ts
packages/harness/cortextos/src/daemon/cron-migration.ts
packages/harness/cortextos/src/daemon/agent-manager.ts
packages/harness/cortextos/src/daemon/cron-execution-log.ts
packages/harness/cortextos/src/daemon/worker-process.ts
packages/harness/cortextos/src/daemon/agent-process.ts
packages/harness/cortextos/skills/cron-management/SKILL.md
packages/harness/cortextos/src/cli/enable-agent.ts
packages/harness/cortextos/src/cli/index.ts
packages/harness/cortextos/src/cli/goals.ts
packages/harness/cortextos/src/cli/stop.ts
packages/harness/cortextos/src/cli/add-agent.ts
packages/harness/cortextos/src/cli/tunnel.ts
packages/harness/cortextos/src/cli/import-agent.ts
packages/harness/cortextos/src/cli/start.ts
packages/harness/cortextos/src/cli/dashboard.ts
packages/harness/cortextos/src/cli/bus.ts
packages/harness/cortextos/src/cli/restart.ts

codex
The live ULTRAPLAN citation already diverges: the claimed Gate A text is not at the cited line and includes requirements absent from the current spec. I’m checking the schema/policy references now because the ADR also introduces new payload/config fields.
exec
/bin/zsh -lc "rg --files | rg 'vertical-schema|schema|migration|decision_log|autosend-safety-policy|escalation-codes'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/harness/cortextos/src/daemon/cron-migration.ts
packages/harness/cortextos/src/bus/crons-schema.ts
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/decisions/autosend-safety-policy.md
agents/_shared/escalation-codes.md
logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_yaml.output.md
logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md
packages/agent-renderer/tests/fixtures/test-tenant-vault/migration-test/_config.yaml
packages/agent-renderer/tests/fixtures/test-tenant-vault/migration-test/_secrets.env
packages/agent-renderer/tests/fixtures/test-agent/config.schema.json
legacy/v1/packages/db/prisma/schema.prisma
legacy/v1/packages/db/prisma/migrations/20260426120000_brain_graph/README.md
legacy/v1/packages/db/prisma/migrations/20260426120000_brain_graph/migration.sql
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts
packages/harness/cortextos/tests/integration/migration-guide-references-upgrade-cmd.test.ts
packages/harness/cortextos/tests/integration/crons-migration.test.ts
legacy/v1/packages/db/prisma/migrations/20260426130000_brain_embeddings/README.md
legacy/v1/packages/db/prisma/migrations/20260426130000_brain_embeddings/migration.sql
scripts/run-live-migration.sh
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md
legacy/v1/packages/schemas/src/index.ts
legacy/v1/packages/schemas/package.json
packages/harness/cortextos/tests/unit/bus/crons-schema.test.ts
legacy/v1/migrations/0001_initial.sql
legacy/v1/docs/phase-1-poc-stack/proposal-builder/config.schema.json
logs/codex-ratification/round-3-remediation/docs_verticals_recruitment_migrations_v0-2-to-v0-3-pii-purge-sql.output.md
logs/codex-ratification/round-3-remediation/docs_verticals_recruitment_migrations_v0-1-to-v0-2-sql.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_migrations_v0-2-to-v0-3-pii-purge-sql.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_migrations_v0-3-to-v0-2-pii-purge-sql.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-v0-2-supplement-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
legacy/v1/docs/phase-3-platform/postgres/schema-spec.md
legacy/v1/docs/phase-2-agent-suite/reporting-engine/config.schema.json
legacy/v1/docs/phase-2-agent-suite/librarian/config.schema.json
legacy/v1/docs/phase-3-platform/postgres/migrations/20260422_001_initial.sql
legacy/v1/docs/phase-2-agent-suite/lead-hunter/config.schema.json
legacy/v1/docs/phase-2-agent-suite/hr-agent/config.schema.json
legacy/v1/docs/phase-2-agent-suite/content-creator/config.schema.json
legacy/v1/docs/phase-2-agent-suite/_shared/escalation-codes.md
legacy/v1/docs/phase-2-agent-suite/client-onboarder/config.schema.json
legacy/v1/docs/phase-2-agent-suite/repurposer/config.schema.json
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/config.schema.json
legacy/v1/docs/phase-2-agent-suite/sop-writer/config.schema.json
legacy/v1/docs/phase-2-agent-suite/caption-writer/config.schema.json

exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Auto-send safety policy
     2	
     3	**Status:** Proposed — pending Codex Day-7 ratification
     4	**Date:** 2026-05-18 (Week 0, Day 5)
     5	**Author:** Claude Code, with founder review pending
     6	**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
     7	**Surfaced by:** Master brief Day 5 spec; load-bearing for every `hh_decision_action` call across the v1.0 agent fleet.
     8	**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
     9	
    10	---
    11	
    12	## §1 — Scope
    13	
    14	This policy governs **every agent action that produces a side effect outside the IFOS-internal data layer**. The internal data layer is:
    15	
    16	- The vault (`/vault/<tenant>/`) — markdown + YAML, IFOS-controlled
    17	- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
    18	- The pgvector indexes over the above
    19	- The cortextOS file bus and PM2 process tree
    20	
    21	**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).
    22	
    23	**Actions that ARE governed:**
    24	
    25	1. Writes to any external system via MCP connector (Bullhorn, Companies House, Xero, Microsoft Graph, etc.) — every `tools.yaml`-declared write scope
    26	2. Sends to humans via any communication channel (email, SMS, Telegram, Slack, LinkedIn InMail, calendar invite, etc.) — both customer-facing and consultant-internal where the consultant is not the agent's directly-supervising user
    27	3. Reads from external systems that touch PII or have rate-limit/cost implications (LinkedIn profile lookups, Companies House director searches)
    28	4. Any action declared as side-effecting in `tools.yaml` for an agent, regardless of category
    29	
    30	**Out of scope:**
    31	
    32	- Read-only IFOS internal queries (entities, decision_log reads via context-assembly API)
    33	- Render-time renderer operations (writing rendered agent dirs to `${frameworkRoot}/orgs/<org>/agents/<name>/`)
    34	- Vault local writes by the agent's own validate.sh / context.sh / fixture runs
    35	- Codex ratification artefacts (read-only review)
    36	
    37	If an action's scope is ambiguous, default to **governed** and require classification.
    38	
    39	**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
    40	
    41	---
    42	
    43	## §2 — Tier model
    44	
    45	Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.
    46	
    47	### Green — auto-send allowed without review
    48	
    49	Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
    50	
    51	**Default characteristics:** idempotent OR internal-to-tenant OR read-only against external systems with rate-limit budget remaining OR low-cost-to-reverse (e.g., add a Bullhorn tag that can be removed in <30s).
    52	
    53	### Yellow — auto-send allowed with sampled spot-check
    54	
    55	Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
    56	
    57	**Default characteristics:** high-volume actions where systematic per-action review is too slow but where systematic blind trust is too risky; sampled review provides quality signal without operational drag.
    58	
    59	### Orange — requires human approval before send
    60	
    61	Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
    62	
    63	**Default characteristics:** moderate-to-high cost-to-reverse OR customer-facing comms OR irreversible state changes.
    64	
    65	### Red — blocked entirely
    66	
    67	Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
    68	
    69	**Default characteristics:** financial/legal/cross-tenant/PII boundaries; structural integrity of the IFOS multi-tenant model.
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
   126	---
   127	
   128	## §4 — Integration with the `hh_decision_action` contract
   129	
   130	Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
   131	
   132	- `hh_decision_trigger` — at session start; logs the trigger
   133	- `hh_decision_output` — when the agent produces its output artefact
   134	- `hh_decision_action` — when an action is taken (or blocked)
   135	
   136	The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.
   137	
   138	### Reference implementation (bash pseudocode for `_shared/hook-helpers.sh`)
   139	
   140	```bash
   141	# hh_decision_action — gate every side-effecting action through the policy
   142	# Args:
   143	#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
   144	#   $2 target        (entity reference, e.g., "candidate:john-smith")
   145	#   $3 payload_hash  (SHA-256 hex of the action payload)
   146	#   $4 payload_preview (human-readable summary, <=500 chars, NO raw PII)
   147	hh_decision_action() {
   148	  local action_type="$1"
   149	  local target="$2"
   150	  local payload_hash="$3"
   151	  local payload_preview="$4"
   152	
   153	  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
   154	  local tenant_slug="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   155	  local agent_name="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"
   156	
   157	  # 1. Policy lookup — read tier from the canonical policy table
   158	  local tier
   159	  tier=$(autosend_policy_lookup "$action_type") || {
   160	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
   161	    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
   162	    return 1
   163	  }
   164	
   165	  # 2. Apply tenant override (elevation only; red is floor)
   166	  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
   167	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
   168	    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
   169	    return 1
   170	  }
   171	
   172	  # 3. Tier dispatch
   173	  case "$tier" in
   174	    green)
   175	      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
   176	      return 0
   177	      ;;
   178	    yellow)
   179	      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
   180	      if autosend_should_sample "$action_type" "$tenant_slug"; then
   181	        autosend_spot_check_enqueue "$action_type" "$target" "$payload_hash" "$payload_preview" "$tenant_slug"
   182	      fi
   183	      return 0
   184	      ;;
   185	    orange)
   186	      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
   187	      autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW "$action_type" "$target" "$payload_hash" "$payload_preview"
   188	      # Blocks on cortextOS approval gate (master brief primitive 4). Returns 0 on approval, 1 on reject/timeout.
   189	      autosend_await_approval "$action_type" "$target" "$payload_hash"
   190	      return $?
   191	      ;;
   192	    red)
   193	      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
   194	      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
   195	      return 1
   196	      ;;
   197	    *)
   198	      # Fail-safe: unknown tier → red
   199	      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
   200	      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
   201	      return 1
   202	      ;;
   203	  esac
   204	}
   205	```
   206	
   207	### Where the policy check fires in the renderer pipeline
   208	
   209	The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
   210	
   211	**Policy hot-reload:** if the policy file changes mid-session (rare), the agent does NOT pick it up until the next session boundary (cortextOS PTY restart). Material policy changes must wait for the next 71-hour boundary or trigger a deliberate restart. Documented as an operational footgun in §11 open questions.
   212	
   213	### `tools.yaml` declaration
   214	
   215	Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
   216	
   217	```yaml
   218	# agents/recruitment/concierge/tools.yaml (excerpt)
   219	action_types:
   220	  - bullhorn_brief_read              # green
   221	  - bullhorn_candidate_query         # green
   222	  - bullhorn_note_draft_internal     # yellow (sample 1-in-10)
   223	  - bullhorn_note_customer_visible   # orange (CANONICAL — bullhorn-integration-path §4.1)
   224	  - gmail_outlook_send_to_candidate  # orange
   225	  - calendar_invite_send             # orange
   226	  - twilio_sms_send                  # orange
   227	```
   228	
   229	Agents cannot invoke action_types not declared in their `tools.yaml`. Renderer validates this at render time per ADR-003 §4 (`ESC_RENDERER_FAILED` reason `bundle-malformed` if a declared action_type isn't in the policy).
   230	
   231	---
   232	
   233	## §5 — Escalation codes
   234	
   235	Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.
   236	
   237	### `ESC_AUTOSEND_NEEDS_REVIEW`
   238	
   239	**Tier:** orange
   240	**Fires when:** an orange-tier action is invoked; opens cortextOS approval gate (primitive 4)
   241	**Payload (JSONB into `decision_log.payload`):**
   242	
   243	```json
   244	{
   245	  "action_type": "<enum from autosend-policy.yaml>",
   246	  "target": "<entity ref, e.g., 'candidate:john-smith'>",
   247	  "payload_hash": "<SHA-256 hex>",
   248	  "payload_preview": "<human summary, <=500 chars, NO raw PII>",
   249	  "tenant_slug": "<slug>",
   250	  "agent_name": "<agent identifier>",
   251	  "approval_deadline_at": "<ISO 8601 UTC, default trigger_time + 4h>",
   252	  "approval_gate_id": "<cortextOS approval gate primary key>"
   253	}
   254	```
   255	
   256	**Escalation path:**
   257	
   258	1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
   259	2. `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` opens the cortextOS approval gate
   260	3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`

exec
/bin/zsh -lc "rg -n \"per_claim_confidence_distribution|diagnostic_per_claim_sample_rate|tenant_adapters|payload\\.|decision_log|phase|ESC_AGENT_OUTPUT_SHAPE\" docs agents packages -g '*.md' -g '*.yaml' -g '*.yml' -g '*.sql' -g '*.sh'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:19:# Schema version stamps decision_log.payload.policy_version_sha at write time.
agents/_shared/autosend-policy.yaml:68:    reason: "Internal operator-only Telegram notification (escalations + run-complete markers); not customer-facing; idempotent within decision_log payload_hash dedup window"
agents/_shared/autosend-policy.yaml:74:    reason: "Internal run-complete status marker written to decision_log; no external comms; informational"
agents/_shared/autosend-policy.yaml:98:    reason: "Status marker recorded AFTER an external send completes (the send itself was a different orange/yellow action_type with its own decision_log row); this row closes the workflow trace"
agents/_shared/autosend-policy.yaml:129:    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
agents/_shared/autosend-policy.yaml:306:    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
agents/_shared/autosend-policy.yaml:317:# Defaults applied when override fields are absent in tenant_adapters
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:18:phase             — one of {trigger, output, action, gating_failed, agent_handoff}; per decision_log CHECK constraint at Day-4 §6.3
agents/_shared/escalation-codes.md:115:- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7
agents/_shared/escalation-codes.md:184:#### `ESC_AGENT_OUTPUT_SHAPE`
agents/_shared/escalation-codes.md:346:- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`
agents/_shared/escalation-codes.md:353:- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:359:  - **Duplicate-payload race:** two agents attempted to send the same `payload_hash` within same tenant within `race_window_seconds` (default 60s); second attempt detected by `decision_log` UPSERT-conflict; second wins-suppressed (first sends; idempotency by payload_hash)
agents/_shared/escalation-codes.md:371:- **Payload fields:** `action_type`, `original_decision_log_id`, `sample_rate`, `sampling_reason`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:426:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
agents/_shared/escalation-codes.md:474:1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
agents/_shared/escalation-codes.md:476:3. Resolve `phase` from this catalogue's `Phase:` line (table-driven, not freeform)
agents/_shared/hook-helpers.sh:10:# Live-mode writes:        Postgres decision_log via psql + IFOS_DB_URL
agents/_shared/hook-helpers.sh:19:# Side-effects: appends to decision_log table OR fallback JSONL; never reads
agents/_shared/hook-helpers.sh:100:# _hh_emit_row <phase> <outcome> <reason> <payload_json>
agents/_shared/hook-helpers.sh:102:# Writes one row to decision_log. Live mode (IFOS_DB_URL set + psql available):
agents/_shared/hook-helpers.sh:106:  local phase="$1"
agents/_shared/hook-helpers.sh:121:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
agents/_shared/hook-helpers.sh:125:  '$(_hh_sql_escape "${phase}")',
agents/_shared/hook-helpers.sh:149:  row=$(printf '{"tenant_slug":"%s","agent_name":"%s","phase":"%s","outcome":%s,"reason":%s,"payload":%s,"created_at":"%s","_hh_version":"%s"}' \
agents/_shared/hook-helpers.sh:152:    "$(_hh_json_escape "${phase}")" \
agents/_shared/hook-helpers.sh:167:# Writes phase='trigger' row at session start. Required first call of every run.
agents/_shared/hook-helpers.sh:178:# Writes phase='output' row per artefact produced. Required before producing
agents/_shared/hook-helpers.sh:191:# Writes phase='action' or phase='gating_failed' row depending on tier.
agents/_shared/hook-helpers.sh:203:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:211:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:220:      autosend_emit_decision_log "action" "green" "${action_type}" \
agents/_shared/hook-helpers.sh:225:      autosend_emit_decision_log "action" "yellow" "${action_type}" \
agents/_shared/hook-helpers.sh:234:      autosend_emit_decision_log "action" "orange" "${action_type}" \
agents/_shared/hook-helpers.sh:242:      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
agents/_shared/hook-helpers.sh:249:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:286:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
agents/_shared/hook-helpers.sh:329:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
agents/_shared/hook-helpers.sh:330:# Emits the standard autosend decision_log row with payload.tier set.
agents/_shared/hook-helpers.sh:331:autosend_emit_decision_log() {
agents/_shared/hook-helpers.sh:332:  local phase="$1"
agents/_shared/hook-helpers.sh:350:  _hh_emit_row "${phase}" "${tier}" "${reason_or_status}" "${payload}"
agents/_shared/hook-helpers.sh:355:# lookup is permissive — unknown codes are emitted with phase='gating_failed'
agents/_shared/hook-helpers.sh:393:# tenant override via tenant_adapters.config.sampling_rates.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
packages/harness/cortextos/templates/agent-codex/AGENTS.md:349:**Media injections** arrive with the file path already extracted into a structured payload. The codex extractor surfaces:
packages/agent-renderer/templates/claude-md-preamble.md:44:- `memory/` — replaced by Postgres `decision_log` (writes via `hh_decision_*` helpers).
agents/_shared/README.md:3:**Status:** Phase 5 complete (v0.1). All 4 phase deliverables landed; live VPS migration is a manual founder action (see §Live integration test).
agents/_shared/README.md:24:`hook-helpers.sh` writes to `decision_log` via two paths:
agents/_shared/README.md:44:| `HH_POLICY_VERSION_SHA` | no | Git SHA stamped into `decision_log.payload.policy_version_sha` per §7 | `unknown` |
agents/_shared/README.md:56:`hh_decision_action` is the **gated** call. Returns `0` if action allowed, `1` if blocked or approval rejected. All three write a `decision_log` row before returning.
agents/_shared/README.md:63:autosend_emit_decision_log    <phase> <tier> <action_type> <target> <hash> <preview> <reason>
agents/_shared/README.md:76:| **green** | Emit `phase=action`, return 0 immediately | 0 |
agents/_shared/README.md:77:| **yellow** | Emit `phase=action`, draw 1-in-N spot-check sample, return 0 | 0 |
agents/_shared/README.md:78:| **orange** | Emit `phase=action` + escalate `ESC_AUTOSEND_NEEDS_REVIEW`, block on approval gate, return 0/1 | depends on approval |
agents/_shared/README.md:79:| **red** | Emit `phase=gating_failed` + escalate `ESC_AUTOSEND_BLOCKED`, return 1 | 1 |
agents/_shared/README.md:80:| _unknown_ | Emit `phase=gating_failed` (`fail-safe-red`) + escalate `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`, return 1 | 1 |
agents/_shared/README.md:122:3. Founder verifies via `psql` that one new row landed in `decision_log` with `phase='trigger'` + `tenant_slug='migration-test'`.
agents/_shared/README.md:125:   SELECT count(*) FROM decision_log
agents/_shared/README.md:181:- `~/.claude/plans/bubbly-snuggling-lantern.md` — active 5-phase plan
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
packages/agent-renderer/README.md:124:Hand-edits to the rendered output are **lost on next render** (Decision 4: overwrite-no-merge per ADR-003 §3.4). Edit the bundle, then re-render. Decision-log row written with `agent_name='_renderer'` + `phase='render'` per ADR-003 §4 audit policy (Phase 3 wires this via `hook-helpers.sh`).
packages/agent-renderer/README.md:166:- `~/.claude/plans/bubbly-snuggling-lantern.md` — active 5-phase plan
agents/_shared/tests/test-hook-helpers.sh:95:printf '\n[1] hh_decision_trigger writes a phase=trigger row\n'
agents/_shared/tests/test-hook-helpers.sh:101:  _assert_contains "${row}" '"phase":"trigger"' \
agents/_shared/tests/test-hook-helpers.sh:104:_test_run "phase=trigger row written" test_trigger
agents/_shared/tests/test-hook-helpers.sh:106:printf '\n[2] hh_decision_output writes a phase=output row\n'
agents/_shared/tests/test-hook-helpers.sh:112:  _assert_contains "${row}" '"phase":"output"' \
agents/_shared/tests/test-hook-helpers.sh:115:_test_run "phase=output row written" test_output
agents/_shared/tests/test-hook-helpers.sh:138:    && _assert_contains "${row}" '"phase":"action"'
agents/_shared/tests/test-hook-helpers.sh:140:_test_run "green action: rc=0 + phase=action + tier=green" test_action_green
agents/_shared/tests/test-hook-helpers.sh:151:    && _assert_contains "${row}" '"phase":"gating_failed"' \
agents/_shared/tests/test-hook-helpers.sh:154:_test_run "red action: rc=1 + phase=gating_failed + ESC_AUTOSEND_BLOCKED" test_action_red
agents/_shared/tests/test-hook-helpers.sh:279:    && _assert_contains "${row}" '"phase":"action"'
agents/_shared/tests/test-hook-helpers.sh:281:_test_run "yellow action: rc=0 + phase=action + tier=yellow" test_action_yellow
agents/_shared/tests/test-hook-helpers.sh:286:  # (a) the autosend_emit_decision_log audit row with payload.tier='red'
agents/_shared/tests/test-hook-helpers.sh:288:  # Kill-criterion Trigger 5 monitoring query filters by payload.tier='red'
agents/_shared/tests/test-hook-helpers.sh:297:  gating_failed_count=$(grep -c '"phase":"gating_failed"' "${IFOS_DECISION_LOG_FALLBACK}")
agents/_shared/tests/test-hook-helpers.sh:303:_test_run "kill-criterion Trigger 5: red-tier rows queryable by tier+phase" test_kill_criterion_trigger5
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:23:--   - RLS policies on entities + entity_links + decision_log already in place
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:173:-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
agents/recruitment/cash-conductor/agent.md:86:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:107:Each draft: `decision_log` row `agent_name='cash_conductor'`, `phase='output'`, `action_type='xero_reminder_draft_internal'` (registered yellow tier — but Cash Conductor escalates to orange-tier `xero_reminder_send_customer` for the actual customer-facing send routed via Concierge; this row is the draft itself, not the send), payload includes the draft.
agents/recruitment/cash-conductor/agent.md:193:     sent (counted from decision_log decision_log.payload.position)
agents/recruitment/cash-conductor/agent.md:210:   → ESC_AGENT_OUTPUT_SHAPE on any miss (output-shape violation: chase cannot
agents/recruitment/cash-conductor/agent.md:241:    → query decision_log + accounting + bank feed for the 7-day window
agents/recruitment/cash-conductor/agent.md:249:    → update tenant_adapters.config.cash_conductor_last_run = now()
agents/recruitment/cash-conductor/agent.md:271:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint: chase cannot meet its Gate A contract); draft stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/cash-conductor/agent.md:301:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss (invoice/amount/contact validation OR paid-invoice precondition violated) — output-shape constraint per catalogue line 184 | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:309:- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:61:-- §3 — Per-tenant retention override storage (tenant_adapters extension)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
docs/_archive-build-pack/08-OPEN-DECISIONS.md:3:**Questions only the founder can answer. Each has a recommendation, a recommended decision deadline (relative to Phase 0 start), and a "what blocks if undecided" note. Resolve these before the corresponding phase starts.**
docs/_archive-build-pack/08-OPEN-DECISIONS.md:158:**Recommendation:** Update the sub-processor list in `intel-force-os/docs/phase-5-business-legal/legal/dpa-template.md` before v2 launches. Notify all v1 customers in writing (email is fine — DPA standard practice).
docs/_archive-build-pack/08-OPEN-DECISIONS.md:218:1. At each phase boundary, bundle the phase's git diff + the relevant build-pack files
docs/_archive-build-pack/08-OPEN-DECISIONS.md:219:2. Hand to Codex with the prompt: *"Pressure-test this phase's implementation against the build pack. Surface deviations, weak abstractions, missing tests, latent bugs. Return a delta document."*
docs/_archive-build-pack/08-OPEN-DECISIONS.md:220:3. Apply Codex's delta as a final commit on the phase (with a co-author tag)
docs/_archive-build-pack/08-OPEN-DECISIONS.md:221:4. Move to the next phase
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
agents/recruitment/scribe/agent.md:82:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:157:   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
agents/recruitment/scribe/agent.md:224:Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/scribe/agent.md:255:| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:96:Per `decision_log`: one row per source query + one row per candidate proposed + one final aggregate row.
agents/recruitment/sourcing-scout/agent.md:126:   → if 2+ sources fail auth: ESC_AGENT_OUTPUT_SHAPE (Sourcing Scout cannot
agents/recruitment/sourcing-scout/agent.md:141:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn')
agents/recruitment/sourcing-scout/agent.md:149:   → ESC_RATE_LIMIT_HIT on Proxycurl quota hit (payload.upstream='linkedin')
agents/recruitment/sourcing-scout/agent.md:156:     (payload.upstream='reed')
agents/recruitment/sourcing-scout/agent.md:163:     (payload.upstream='cv-library')
agents/recruitment/sourcing-scout/agent.md:198:    → if any condition fails: ESC_AGENT_OUTPUT_SHAPE (output-shape violation
agents/recruitment/sourcing-scout/agent.md:229:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation per catalogue line 184); draft to `/tmp`; operator review.
agents/recruitment/sourcing-scout/agent.md:255:| `ESC_RATE_LIMIT_HIT` | Any source 429 (payload.upstream identifies which: bullhorn / linkedin / reed / cv-library) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:260:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:267:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
packages/harness/cortextos/community/skills/worker-agents/SKILL.md:107:cortextos inject-worker <worker-name> "Continue with phase 3. What's blocking you?"
docs/_archive-build-pack/03-ARCHITECTURE.md:44:│   ├── agents/                        (Plan, Explore, phase-architect subagent specs)
docs/_archive-build-pack/03-ARCHITECTURE.md:45:│   └── commands/                      (slash commands — /load-phase, /search-specs, etc.)
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/worker-agents/SKILL.md:105:cortextos inject-worker <worker-name> "Continue with phase 3. What's blocking you?"
packages/agent-renderer/tests/fixtures/test-agent/agent.md:5:Test-agent emits one structured `decision_log` row per invocation with phase
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:9:You said the goal is to one-shot this with Claude Code + Codex ratification. "One-shot" doesn't mean a single chat turn. It means **the build proceeds without architectural re-litigation**. Phase boundaries are gates; inside a phase, slices execute against the pack. Codex catches what Claude Code missed; Claude Code catches what Codex missed.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:44:| `phase-3-platform` | Reference for multi-tenancy patterns — informs §3 of architecture |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:45:| `phase-4-dashboard` | Reference for dashboard build — informs Phase 2 |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:67:| **Plan** | At every phase boundary. Before P1, run a Plan agent to scope the brain swap. Before P2, run Plan for the dashboard. Plan returns a structured slice list — compare against the build pack's slices to catch what's missing. |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:69:| **phase-architect** | Use at phase boundaries to pressure-test your implementation against the spec. "Phase-architect: review Phase 1's brain package against `03-ARCHITECTURE.md` and `04-DATA-MODEL.md`. Surface deviations." Equivalent of Codex internal to Claude Code. |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:109:- `/load-phase <n>` — load phase-specific context
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:122:- **`/codex-bundle <phase>`** — bundle the phase's git diff + relevant build-pack files into a single text file ready to paste into Codex.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:123:- **`/phase-gate <n>`** — runs all acceptance criteria checks for Phase n. Output: which check passed, which failed, what to fix.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:147:- At each phase boundary, add a `project_phase_<n>_outcome.md` recording what shipped + what slipped + the Codex delta applied
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:171:Use Plan mode at every phase boundary. Concretely:
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:241:## Current phase
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:251:- Codex review at every phase boundary
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:258:- Skip the Codex ratification step at phase boundaries
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:264:Update CLAUDE.md at every phase boundary to reflect the new state.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:270:Concretely, the ratification ritual at each phase boundary:
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:273:1. Claude Code finishes the phase's slices, commits.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:274:2. Run /codex-bundle <phase> (slash command from §4.2) → produces docs/codex-bundles/phase-<n>.md
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:275:   Contents: git diff for the phase + relevant build-pack sections
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:276:3. Paste docs/codex-bundles/phase-<n>.md into Codex (web or CLI)
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:279:6. Apply the changes — typically a single commit `chore(phase-<n>): codex review delta`
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:280:7. Update CLAUDE.md to mark the phase complete
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:281:8. Move to next phase
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:42:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold`)
agents/recruitment/janitor/agent.md:59:| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:70:2. **Field backfill** (`PATCH /Candidate/{id}` or `/Client/{id}`) — fills missing canonical schema fields (per `vertical-schema.yaml`): `candidate.location` (line 124), `client.industry` (line 238), `client.size_employees` (line 243), `client.companies_house_number` (line 252), `contractor.day_rate_min/day_rate_max` (lines 193-197), `brief.salary_min/salary_max` (lines 371-376) from Companies House (for clients) or LinkedIn/derivation (for candidates). Sources logged in payload. Action type: **`bullhorn_field_backfill`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:73:Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.
agents/recruitment/janitor/agent.md:95:     tenant_adapters.config.janitor_last_run)
agents/recruitment/janitor/agent.md:138:   → join to decision_log only if action-context lookups needed
agents/recruitment/janitor/agent.md:151:   → SELECT from decision_log WHERE agent_name='janitor' AND created_at >
agents/recruitment/janitor/agent.md:166:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:187:Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint; per Day-19 catalogue add at `escalation-codes.md` line 184) OR `ESC_DUPLICATE_DETECTED` (merge-confidence reject; existing line 127) per the failed condition. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (line 163) is NOT used by Janitor — that code is reserved for vertical-schema field-constraint violations at write-time.
agents/recruitment/janitor/agent.md:212:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (section count or per-section citation missing in day-30 report) | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:222:- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction
agents/recruitment/janitor/agent.md:275:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
packages/harness/cortextos/community/skills/morning-review/SKILL.md:37:Execute each phase in order.
packages/harness/cortextos/community/skills/morning-review/SKILL.md:127:Already implicitly validated by the boot message in Phase 0. If the boot message failed to send, the agent would not have reached this phase.
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:77:### Founding-phase (first 10 customers)
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:247:- The MSA, DPA, SLA, AUP, Privacy Policy, Terms of Service templates from `intel-force-os/docs/phase-5-business-legal/legal/`
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:248:- The pricing FAQ from `intel-force-os/docs/phase-5-business-legal/pricing/pricing-spec.md`
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:249:- The sales playbook from `intel-force-os/docs/phase-5-business-legal/playbooks/sales-playbook.md`
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:250:- The case-study playbook from `intel-force-os/docs/phase-5-business-legal/playbooks/case-study-playbook.md`
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:260:From `intel-force-os/docs/phase-0-strategic/intelforce-ai-os-strategic-plan.md`:
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:8:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:118:You are the M2C1 orchestrator. Follow the 12-phase workflow in plugins/cortextos-agent-skills/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:192:5. Continue autonomously through all phases
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:285:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:287:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:324:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:425:- Worker is in a research subagent phase
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:446:After each phase of execution, verify:
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:459:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:496:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:501:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:511:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:10:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:120:You are the M2C1 orchestrator. Follow the 12-phase workflow in .claude/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:147:5. Continue autonomously through all phases
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:216:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:218:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:226:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:324:- Worker is in a research subagent phase
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:345:After each phase of execution, verify:
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:358:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:395:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:400:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:410:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.
docs/_archive-build-pack/05-MIGRATION-MAP.md:106:| Phase 0 strategic | KEEP (reference) | `docs/phase-0-strategic/` | Reference from `07-V1-INHERITED-CONTEXT.md`; don't copy |
docs/_archive-build-pack/05-MIGRATION-MAP.md:107:| Phase 1 POC stack | DROP | `docs/phase-1-poc-stack/` | Already retired |
docs/_archive-build-pack/05-MIGRATION-MAP.md:108:| Phase 2 agent suite (10 agent specs) | KEEP (mine for prompts) | `docs/phase-2-agent-suite/` | Source for `packages/agents/templates/<key>/prompt.md` |
docs/_archive-build-pack/05-MIGRATION-MAP.md:109:| Phase 3 platform | KEEP (lifts informed) | `docs/phase-3-platform/` | Informs `03-ARCHITECTURE.md` decisions on multi-tenancy, secrets, observability |
docs/_archive-build-pack/05-MIGRATION-MAP.md:110:| Phase 4 dashboard | KEEP (lifts informed) | `docs/phase-4-dashboard/` | Informs the dashboard rebuild |
docs/_archive-build-pack/05-MIGRATION-MAP.md:111:| Phase 5 business/legal | KEEP (as-is) | `docs/phase-5-business-legal/` | Intel Force Ltd legal docs unchanged; v2 reuses MSA/DPA/SLA/AUP/Privacy/ToS |
docs/_archive-build-pack/05-MIGRATION-MAP.md:112:| Phase 6 ops runbooks | KEEP (adapt) | `docs/phase-6-ops-runbooks/` | Adapt incident + DR runbooks for v2 topology |
docs/_archive-build-pack/05-MIGRATION-MAP.md:123:| Logo, palette, typography | KEEP | `WEBSITE-CONTEXT.md` §6 + `intel-force-os/docs/phase-5-business-legal/marketing/brand-identity-spec.md` | `packages/ui/tailwind.tokens.css` |
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:78:  decision_log_rows_min: 4  # trigger + output + validate_gate_a_fail action + cleanup
packages/harness/cortextos/templates/orchestrator/.claude/skills/worker-agents/SKILL.md:106:cortextos inject-worker <worker-name> "Continue with phase 3. What's blocking you?"
agents/recruitment/diagnostic/fixtures/01-primary.yaml:97:expected_decision_log_rows:
agents/recruitment/diagnostic/fixtures/01-primary.yaml:98:  - phase: trigger
agents/recruitment/diagnostic/fixtures/01-primary.yaml:101:  - phase: output
agents/recruitment/diagnostic/fixtures/01-primary.yaml:104:  - phase: action
agents/recruitment/diagnostic/fixtures/01-primary.yaml:108:  - phase: action
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:95:expected_decision_log_rows:
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:96:  - phase: trigger
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:98:  - phase: output
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:100:  - phase: action
docs/RISK-REGISTER.md:33:| 11 | **Tenant-context guard failure due transactionless `SET LOCAL` usage** — scripts and helpers used `SET LOCAL ifos.tenant_slug` in psql heredocs/strings without visible `BEGIN/COMMIT`. If PostgreSQL treats the setting as transaction-local with no active transaction, RLS-protected reads/writes can return zero rows, fail audit inserts, or silently fall back to JSONL. | ~~High~~ → Low post-remediation | High | Any psql call with `SET LOCAL` not bracketed by `BEGIN/COMMIT`, or a successful operation whose decision_log row falls back because RLS rejected the insert. | Round-2 remediation Fix 3-5 wraps every `SET LOCAL` psql call in a transaction. Verified by shellcheck + 29 helper tests + Round 3. | **Mitigated in this commit; Round-3 verified.** |
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:9:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:119:You are the M2C1 orchestrator. Follow the 12-phase workflow in .claude/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:146:5. Continue autonomously through all phases
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:215:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:217:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:225:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:324:- Worker is in a research subagent phase
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:345:After each phase of execution, verify:
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:358:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:395:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:400:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:410:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.
agents/recruitment/diagnostic/cycle.sh:20:#   - Audit rows to decision_log (trigger + output + action)
agents/recruitment/diagnostic/cycle.sh:197:    # Emit decision_log row BEFORE the send per agent.md §4 Step 11 spec —
docs/architecture/tenancy-invariants.md:24:- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/tenancy-invariants.md:86:### T5 — `ifos_app` role has no DELETE on `decision_log` or `recent_edit` (append-only audit tables)
docs/architecture/tenancy-invariants.md:88:- **Definition:** The two audit tables (`decision_log` from Day-4 + `recent_edit` from v0.2) are structurally append-only. Even if app code attempted DELETE, the role lacks permission.
docs/architecture/tenancy-invariants.md:90:- **Documentation source:** Day-4 §6.3 line 764 (`GRANT SELECT, INSERT ON decision_log TO ifos_app`) + v0.2 §6 line 172 (`GRANT SELECT, INSERT ON recent_edit TO ifos_app`).
docs/architecture/tenancy-invariants.md:94:  WHERE grantee='ifos_app' AND table_name IN ('decision_log','recent_edit')
docs/architecture/tenancy-invariants.md:97:  Expected: 4 rows total — `decision_log` × {SELECT, INSERT}, `recent_edit` × {SELECT, INSERT}. No UPDATE or DELETE.
docs/architecture/tenancy-invariants.md:177:  SELECT count(*) FROM decision_log WHERE agent_name='test-agent';  -- expect 0
packages/harness/cortextos/templates/analyst/.claude/skills/worker-agents/SKILL.md:106:cortextos inject-worker <worker-name> "Continue with phase 3. What's blocking you?"
docs/architecture/architecture-cohesion-review.md:68:| ADR-003 | phase enum for renderer | Day-4 §6.3 CHECK constraint | **✓ landed but with deviation per ADR-004 Decision 7** — phase='render' NOT in enum; uses agent_name='_renderer' + existing phase |
docs/architecture/architecture-cohesion-review.md:71:| ADR-004 | phase enum pattern | `agents/_shared/hook-helpers.sh::hh_decision_action` | ✓ landed Phase 3 |
docs/architecture/architecture-cohesion-review.md:105:### C1 — Renderer phase enum (RESOLVED post-Round-1)
docs/architecture/architecture-cohesion-review.md:107:- **agent-bundle-renderer-design.md** (pre-Round-1) said `phase='render'` written to decision_log on renderer failure
docs/architecture/architecture-cohesion-review.md:109:- **Resolution:** ADR-004 Decision 7 (Codex Round 1 RATIFIED) + Day-8-evening remediation `2b287d3` corrected both renderer-design + ADR-003 to use `agent_name='_renderer'` + existing `phase=gating_failed|action`. **RESOLVED.**
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:236:| R10 | G5: Multi-tenant connection pool sizing | Low | v1.1+ scale exercise | Claude Code | v1.1 design phase |
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
agents/recruitment/diagnostic/validate.sh:13:# decision_log; the report does NOT land in the vault.
agents/recruitment/diagnostic/validate.sh:236:  #     length, voice-classifier miss) → ESC_AGENT_OUTPUT_SHAPE (warn)
agents/recruitment/diagnostic/validate.sh:251:    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:9:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:119:You are the M2C1 orchestrator. Follow the 12-phase workflow in .claude/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:146:5. Continue autonomously through all phases
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:215:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:217:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:225:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:325:- Worker is in a research subagent phase
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:346:After each phase of execution, verify:
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:359:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:396:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:401:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:411:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.
docs/architecture/agent-bundle-renderer-design.md:109:| `agents/recruitment/<name>/agent.md` | `orgs/<org>/agents/<name>/CLAUDE.md` | **Synthesis** | (1) `agent.md` body verbatim; (2) **cortextOS preamble template** — spec gap §2.1-A; (3) per-tenant footer (resolved tenant_slug, current `_voice/style-guide.md` path, decision_log Postgres role); (4) hook invocation block referencing `.claude/hooks/{validate,context}.sh` paths | Lint pass: no unresolved `{{tenant_slug}}` / `{{...}}` placeholders survive; preamble matches the renderer's canonical preamble version (hash check); CLAUDE.md is non-empty and parses as valid markdown |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:144:| `tasks` | cortextOS task management — `create-task` / `update-task` / `complete-task` against the `orgs/{org}/tasks/` directory | IFOS uses Postgres `decision_log` for the "what did this agent do" trail and the wiki for the "what's the state of this entity" view. The cortextOS task store is unused by IFOS agents (parallel to the KB-untouched decision per ADR-002 Decision 1) |
docs/architecture/agent-bundle-renderer-design.md:638:**Escalation:** `ESC_RENDERER_FAILED` row written to `decision_log` Postgres table with `agent_name='_renderer'`, `phase='gating_failed'`, `payload->>'reason'='schema-validation-failure'`. (`phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — see ADR-004 Decision 7; the 5-value enum is `trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 schema migration.) If `--notify-on-failure` (default true), Telegram message to the operator with the validation path.
docs/architecture/agent-bundle-renderer-design.md:708:- **Audit log:** Postgres `decision_log` row with `tenant_slug`, `agent_name='_renderer'`, `phase='gating_failed'` (failures) or `phase='action'` (successful renders), `payload->>'reason'` carries the reason code. RLS-isolated per tenant. Codex's Day-7 ratification report queries this table for all rows where `agent_name='_renderer' AND payload->>'reason' LIKE 'ESC_RENDERER_FAILED%'`. (Per ADR-004 Decision 7: `phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — use the 5-value enum from Day-4 §6.3 + Day-5 schema migration.)
docs/architecture/agent-bundle-renderer-design.md:764:| Postgres `decision_log` table live (per master brief §6 Day 4) | founder | Day 4 of Week 0 (already scheduled) |
agents/recruitment/diagnostic/agent.md:158:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces the following SPEC. **Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements most of these checks today but warns-only on two upstream-unavailable cases (voice-classifier URL unreachable, firm-domain whitelist absent). Hard-fail behaviour on those two cases is a W4 polish item; current v0 honesty-flags them in `decision_log` payload with `validate_check_skipped=true` instead of hard-failing. The spec below describes the W4-complete contract; the W4 build slice closes the two gaps.
agents/recruitment/diagnostic/agent.md:169:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `payload.action_type='consultant_feedback'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with a payload action_type marker rather than a new sentinel.
agents/recruitment/diagnostic/agent.md:185:| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing | warn | operator_chat_id |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:43:**Disposition:** **Codex is correct.** Real bug. Step 11 sends a Telegram notification (an action with external side-effect) but doesn't emit a `decision_log` row. Mechanical fix: add `hh_decision_action("operator_notify_telegram", ...)` call to Step 11.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:71:Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:91:3. **Accept Issue 4 fix per Option B** (use `agent_name='diagnostic'` with payload.action_type)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:130:4. **Sentinel agent_name usage** — _consultant_feedback (Diagnostic) is the clear case; other agents likely have similar invented sentinels. Disposition: prefer `agent_name='<agent>'` with `payload.action_type` markers; reserve sentinels for system actors (_renderer, _tenant_admin, _codex_ratifier).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:146:- Sentinel hygiene (Issue 4) is a real architectural concern; agent_name=agent + payload.action_type is the cleaner pattern; no reason to proliferate sentinels.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:189:2. `recent_edit` schema confusion — it's a v0.2 separate table, not a decision_log field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:217:4. Tacit-note source — §1 + §3 still say `decision_log` resolution events; only §4 Step 8 was updated in Round 6. Same `recent_edit` table confusion in different sections.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:259:- Cat-4 (sentinel hygiene): Diagnostic `_consultant_feedback` → agent_name='diagnostic' + payload.action_type
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:363:- `validate.sh` emits specific §6 ESC codes (ESC_PII_LEAKAGE_RISK or ESC_AGENT_OUTPUT_SHAPE) not generic ESC_SCHEMA_VIOLATION
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:390:1. Step 9 per-candidate decision_log row missing — Cat-ε
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
agents/recruitment/concierge/README.md:24:- `cleanup.sh` — token rotation + 14-day decision_log retention check
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:39:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:48:- Aggregate report quality metric written to `decision_log.payload.per_claim_confidence_distribution`
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:107:- Sample rate configurable per tenant in `tenant_adapters.config.diagnostic_per_claim_sample_rate`
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:108:- Aggregate metric writes to `decision_log.payload.per_claim_confidence_distribution`
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:109:- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
agents/recruitment/concierge/agent.md:102:Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).
agents/recruitment/concierge/agent.md:129:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:138:   → query decision_log for prior `concierge_email_draft` row for same
agents/recruitment/concierge/agent.md:139:     (candidate_id, payload.event_type) in last 24h with phase IN
agents/recruitment/concierge/agent.md:153:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
agents/recruitment/concierge/agent.md:275:Gate A failures fire `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` or `ESC_PII_LEAKAGE_RISK` or `ESC_CANDIDATE_DATA_INCOMPLETE` or `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint when voice threshold misses persistently) — all blocking; draft to `/tmp`; operator notified immediately.
agents/recruitment/concierge/agent.md:297:| `ESC_BULLHORN_AUTH` | OAuth refresh fails (payload.failure_type='refresh_failed' or 'revoked_401' covers the 6+ consecutive failure case) | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:298:| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:310:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:319:- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
agents/recruitment/concierge/agent.md:392:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
agents/recruitment/concierge/agent.md:396:| Q7 | Anti-duplicate guard window — 24h proposed in Step 2. Edge case: webhook + poll cycle both fire same event within 5 min → second skipped. What if first failed silently? | Anti-duplicate also checks decision_log for `phase='action'` not just `phase='trigger'` — if first didn't send, second can attempt. |
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:36:Execute each phase in order.
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:126:Already implicitly validated by the boot message. If it failed, the agent would not have reached this phase.
docs/architecture/cortexos-primitive-status.md:370:Full experiment lifecycle code, dedicated sprint-3 test file, fully-documented 8-phase theta-wave skill shipped in the `analyst` template. Approval-gate integration ties it back into primitive 4. Not on the v1.0 critical path — Ultraplan §3.1 row 6 already defers it to v1.1 Night Sourcer.
docs/architecture/cortexos-primitive-status.md:376:- `templates/analyst/.claude/skills/theta-wave/SKILL.md` (156 lines) — fully fleshed-out 8-phase cycle (Initiate → Deep System Scan → Evaluate Previous → Evaluate Agent Cycles → External Research → Conversation with Orchestrator → Hypothesis and Action → Score+Log+Report). References `cortextos bus manage-cycle create/modify/remove` for cycle CRUD.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:9:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:119:You are the M2C1 orchestrator. Follow the 12-phase workflow in .claude/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:193:5. Continue autonomously through all phases
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:286:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:288:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:325:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:425:- Worker is in a research subagent phase
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:446:After each phase of execution, verify:
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:459:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:496:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:501:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:511:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.
docs/decisions/brain-ui-scope.md:4:**Status:** Proposed — revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch)
docs/decisions/brain-ui-scope.md:6:**Surfaced by:** Master brief §6 Day 3 line 472 — "Brain UI v1.0 scope decision" + ADR-002 §3.4 closing paragraph (Brain UI explicitly forward-deferred to v1.1) + `second-brain-design.md` §3.4 ("Brain UI minimal v1 is built as a thin read-only page over `decision_log` — no new wiki API needed").
docs/decisions/brain-ui-scope.md:17:- **v1.0 minimum (weeks 11-13):** wiki API + Postgres tables (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector voice samples + 9 `wiki-*.sh` parallel wrappers + 9 `wiki/lib/*.ts` modules. **No Brain UI** — operational access via Obsidian + CLI + psql.
docs/decisions/brain-ui-scope.md:22:This document scopes the **v1.1 Brain UI work without committing to implementation details.** The decision deferral is by design — at v1.1 phase start, founder + Claude Code will have observed v1.0 actual wiki usage patterns and can scope sub-features and implementation choices against real evidence rather than speculation.
docs/decisions/brain-ui-scope.md:24:**Revisit trigger:** start of v1.1 phase (estimated Q4 2026 post-v1.0 launch per Ultraplan §9 line 725 + Product Spec §9.2 v1.1 timing). Three v1.0 observations will inform the v1.1 scoping session:
docs/decisions/brain-ui-scope.md:26:1. Which wiki operations get hit hardest in v1.0 (decision_log queries vs entity reads vs entity_links traversals) — informs which feature lands first in v1.1.
docs/decisions/brain-ui-scope.md:41:- Shows recent `decision_log` entries with phase + outcome filtering (`trigger | output | action | gating_failed | agent_handoff` per `sequencing-target.md` §5.3 + §6.5 enum extension).
docs/decisions/brain-ui-scope.md:53:**Likely implementation surface:** Next.js route at `/brain/today` (or equivalent), reading Postgres `decision_log` + `entities` + filesystem mtime on `/vault/<tenant>/wiki/raw/`. Auth model deferred to §3.
docs/decisions/brain-ui-scope.md:55:**Dependency on v1.0:** wiki API live + `decision_log` populated per ADR-002 §3 Decision 3 + extended phase enum per `sequencing-target.md` §6.5.
docs/decisions/brain-ui-scope.md:92:**Dependency on v1.0:** `wiki-find.sh` shipped in v1.1 itself (the wrapper isn't a v1.0 deliverable per ADR-003 §"Decision 3" wrapper table); `decision_log` + `entities` populated in v1.0.
docs/decisions/brain-ui-scope.md:142:- **`psql` against Postgres `decision_log`** for escalation review + audit trail — direct SQL queries, no UI layer.
docs/decisions/brain-ui-scope.md:152:- **`decision_log` audit trail** if asked — `psql` query showing per-agent decisions over time.
docs/decisions/brain-ui-scope.md:158:This document is the input to v1.1 phase planning. At start of v1.1 phase:
docs/decisions/brain-ui-scope.md:229:**Proposed.** Revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch per Ultraplan §9 line 725 + Product Spec §9.2). At revisit, founder + Claude Code:
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:21:The subsequent design pass (`docs/architecture/second-brain-design.md`) went further. Q1.4 found that **no IFOS agent calls `kb-*`** — the IFOS Agent Bundle v2 (master brief §8.1) has no `MEMORY.md`, no heartbeat memory file, and uses Postgres `decision_log` for the persistence role cortextOS's KB fills. The §3.4 seam was designed to shadow calls our agents don't make. Q3 evaluated three interface options against the post-design constraints (§3.2 rubric) and recommended Option α — a parallel `packages/brain/bus-overrides/wiki-*.sh` surface with no shadowing of cortextOS's bus.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:46:| `wiki-history.sh` | entity-history (reads `decision_log`) | v1.1 |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:63:- **Postgres tables (v1.0):** `tenants`, `entities`, `entity_links`, `decision_log` — schemas in design §2.4.2. RLS by tenant_slug on every table except `tenants`. The Ultraplan §5.1 line 227 single `entity_graph` table is **split** into `entities` (one row per entity) and `entity_links` (adjacency) — see Spec gap 2.4-B in the design doc.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:93:> "v1.0 minimum (weeks 11-13) — 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; no Brain UI yet. Total v1.0 effort ~11-13 person-days. v1.1 adds `wiki-find.sh` + `wiki-history.sh` + Brain UI today-view and backlinks panel."
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:99:> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:103:> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."
docs/architecture/vault-concurrency.md:3:**Status:** Reference (no Proposed/Accepted lifecycle). Synthesis of `docs/architecture/second-brain-design.md` §2.6 + `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` Decisions 2-3 + `docs/decisions/sequencing-target.md` §5-A `decision_log.phase` extension.
docs/architecture/vault-concurrency.md:192:- If second attempt also fails: raise `ESC_VAULT_VERSION_MISMATCH`, record in `decision_log` with `phase='gating_failed'` per `sequencing-target.md` §5-A enum extension, log human-readable error to operator Telegram per primitive 5 escalation surface.
docs/architecture/vault-concurrency.md:381:**V1.0 mitigation:** surface partial failure as `ESC_VAULT_CASCADE_PARTIAL_FAILURE` carrying the list of `failures` (referencing entities whose markdown bodies were not rewritten). Record in `decision_log` with `phase='gating_failed'`, `metadata` containing the failures list. **Founder reviews and manually reconciles** — for each failure, run the rewrite by hand (most edits are small) or accept temporary inconsistency until next operation through that entity.
docs/architecture/vault-concurrency.md:389:**V1.0 cascade timeout: 30 seconds** (`CASCADE_TIMEOUT_MS = 30_000`). If exceeded, raise `ESC_VAULT_CASCADE_TIMEOUT` with `failures.length` (entities not yet rewritten) and `refs.length` (total cascade size). Decision_log entry per `phase='gating_failed'`. **Founder reviews** — for large cascades (>30s), the rename is structurally expensive and may warrant rescheduling to off-hours.
docs/architecture/vault-concurrency.md:401:| Code | Trigger | Decision_log phase | Operator surface |
docs/architecture/vault-concurrency.md:406:| `ESC_VAULT_CASCADE_PARTIAL_FAILURE` | §5: rewrite-backlinks cascade completed but ≥1 referencing entity failed to rewrite | `gating_failed` | Telegram operator chat, plus `failures` list in decision_log metadata |
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/architecture/vault-concurrency.md:424:| Cascade atomicity gap (v1.0 mitigation via `ESC_VAULT_CASCADE_PARTIAL_FAILURE` + decision_log + manual reconciliation; full atomicity via write-ahead-log deferred to v1.2+) | §5.4 |
docs/architecture/vault-concurrency.md:441:The `entities.version` column is a new Day-4 tightening — joins the three already on the list per `sequencing-target.md` §6.5 (entity_graph split + `_secrets.env` + `decision_log.phase` enum extension). Day-4 task now has **4 consolidated tightenings**.
docs/decisions/autosend-approval-bridge-spec.md:185:| Postgres unreachable | Write bridge state to fallback JSONL at `/vault/_meta/autosend-bridge.jsonl`; same replay pattern as decision_log fallback |
docs/decisions/sequencing-target.md:32:- **A. First agent.** Which agent ships first in Week 3-4? Anchors the renderer (ADR-003) + `_shared/` helpers (Week-1-2 prereqs from ADR-002) + Postgres `decision_log` (Day 4 Week 0) end-to-end test. Affects how risk surfaces — first agent is the smoke test for every substrate dependency.
docs/decisions/sequencing-target.md:40:**Week 3 needs a starting agent.** The renderer (ADR-003) lands Week 1-2; `_shared/voice-loader.sh` + `hook-helpers.sh` land Week 1-2; Postgres `decision_log` lands Day 4 Week 0. By Week 3 the substrate is live and waiting for its first user. Without §A (first agent), Week 3 doesn't have a build target.
docs/decisions/sequencing-target.md:55:| 2 | **Substrate exercise** | Fraction of Week-1-2 substrate (renderer / `_shared/voice-loader.sh` / `_shared/hook-helpers.sh` / Postgres `decision_log` / `_secrets.env` / Bullhorn auth refresh-loop) the agent exercises | Higher substrate exercise = more value as smoke test for the substrate, but also higher risk of substrate-bug-attributed-to-agent confusion |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:101:| 6. Tenant-onboarding readiness | **High** | Runnable from end of Week 2 with renderer + `_shared/` + Postgres decision_log. No vault `_secrets.env` complexity (no per-tenant Bullhorn OAuth needed), no wiki API needed. Single-tenant deployable immediately |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:110:| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:348:2. **First production run lands clean** for at least one tenant — no `ESC_*` escalation rows in `decision_log` for agent N's run.
docs/decisions/sequencing-target.md:351:5. **Founder explicit sign-off** recorded in `decision_log` with `phase='agent_handoff'`, `agent_name='_sequencing'`, `entity_id='<N>->_<N+1>'`, `metadata` carrying the §5.2-row evidence summary.
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:371:1. **Surface** in `decision_log` with `phase='gating_failed'`, `agent_name='_sequencing'`, `entity_id='<N>->_<N+1>'`, `metadata` carrying which gate(s) failed.
docs/decisions/sequencing-target.md:376:**New `decision_log` `phase` values introduced by this document:** `gating_failed`, `agent_handoff`. The Postgres decision_log table column `phase` (per `second-brain-design.md` §2.4.2 schema) currently lists only `trigger | output | action` per ADR-002 Decision 3. **Spec gap §5-A** flagged for Day 4 Postgres provisioning: extend the `phase` column's accepted values to include the two new ones. Schema migration is a one-line `CHECK` constraint update.
docs/decisions/sequencing-target.md:390:- Postgres provisioning Day 4 with `entities` + `entity_links` split + `_secrets.env` skeleton + (now) extended `phase` enum.
docs/decisions/sequencing-target.md:399:- Smallest viable Diagnostic exercising renderer + `_shared/` + `decision_log` end-to-end per §2.1 substrate-exercise column.
docs/decisions/sequencing-target.md:424:The `decision_log` schema must support `phase='gating_failed'` and `phase='agent_handoff'` per §5.3 Spec gap §5-A. Day 4 Postgres provisioning script needs the extended `CHECK` constraint:
docs/decisions/sequencing-target.md:427:ALTER TABLE decision_log
docs/decisions/sequencing-target.md:428:  ADD CONSTRAINT decision_log_phase_check
docs/decisions/sequencing-target.md:429:  CHECK (phase IN ('trigger', 'output', 'action', 'gating_failed', 'agent_handoff'));
docs/decisions/sequencing-target.md:451:- Spec gap §5-A (decision_log phase enum extension) is queued for Day 4 implementation, not deferred.
docs/decisions/sequencing-target.md:507:| Substrate readiness for W3 Diagnostic build (renderer + `_shared/` + `decision_log`) | Claude Code | End of W2 | Already tracked from ADR-002 + ADR-003 |
docs/decisions/sequencing-target.md:509:| `decision_log.phase` enum extended to include `gating_failed` + `agent_handoff` per §5.3 / §6.5 | Claude Code | Day 4 Postgres provisioning | **NEW from this document** Spec gap §5-A |
docs/build-brief/00-MASTER-BRIEF.md:396:| Realtime | SSE from `decision_log` writes | No websocket complexity |
docs/build-brief/00-MASTER-BRIEF.md:413:| **v1.0 minimum** | Weeks 11–13 (Ultraplan §9) | 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; **no Brain UI yet**. Total v1.0 effort ~11-13 person-days. |
docs/build-brief/00-MASTER-BRIEF.md:470:- [ ] Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per ADR-002 Edit 3 + `docs/architecture/second-brain-design.md` §2.4.2).
docs/build-brief/00-MASTER-BRIEF.md:508:| `phase-2-agent-suite/_shared/hook-helpers.sh` | Common validate/telemetry shell fns | `packages/agents-runtime/_shared/hooks/hook-helpers.sh` | Add `hh_decision_trigger/output/action` per Ultraplan §4.2 |
docs/build-brief/00-MASTER-BRIEF.md:509:| `phase-2-agent-suite/_shared/escalation-codes.md` | Escalation codes | `packages/agents-runtime/_shared/escalation-codes.md` | Expand to recruitment vocabulary |
docs/build-brief/00-MASTER-BRIEF.md:510:| `phase-2-agent-suite/_shared/universal-banned-phrases.txt` | AI-tell phrases | `packages/agents-runtime/_shared/universal-banned-phrases.txt` | Verbatim |
docs/build-brief/00-MASTER-BRIEF.md:511:| `phase-1-poc-stack/platform-specs/minimal-vault-structure.md` | Vault layout | `docs/architecture/vault-structure.md` | Update to recruitment frontmatter schema |
docs/build-brief/00-MASTER-BRIEF.md:512:| `phase-1-poc-stack/platform-specs/webhook-receiver-spec.md` | Fastify webhook router | `packages/webhook-receiver/` | Routing logic adapted to bus-drop instead of Unix socket |
docs/build-brief/00-MASTER-BRIEF.md:663:        │ (raw + compiled)│                  │ RLS-isolated           │                  │ tenant_adapters    │
docs/build-brief/00-MASTER-BRIEF.md:932:- Don't skip Codex ratification at phase boundaries
docs/_supplementary/PRD-autonomous-agent.md:40:18. [Build Phases & Task Checklist](#18-build-phases--task-checklist)
docs/_supplementary/planning-phase-brief.md:2:**The split between what you produce in chat with me (planning) and what Claude Code builds against the plans (building), plus the exact sequence for completing the planning phase.**
docs/_supplementary/planning-phase-brief.md:10:**Planning phase (you + me, in chat) produces 89 of the 95 artifacts:**
docs/_supplementary/planning-phase-brief.md:18:**Building phase (Claude Code + dev hire) takes those specs and writes ~11 substantial codebases.** Claude Code doesn't write the agent prompts or the legal contracts; it writes the *software that runs the prompts and enforces the contracts*.
docs/_supplementary/planning-phase-brief.md:48:## 3. The 95-artifact bucket (per phase)
docs/_supplementary/planning-phase-brief.md:133:**Total from now to first paying client:** ~5–6 months of serious work. That aligns with your 14-week build target *if* you parallelise: planning runs ahead 4–5 weeks, then build starts while planning continues for later-phase artifacts.
docs/_supplementary/planning-phase-brief.md:137:## 5. The planning phase, session by session
docs/_supplementary/planning-phase-brief.md:222:**End state of week 10:** planning phase 100% complete for v1 launch. Phase 7 (post-launch) produced as needed.
docs/decisions/2026-05-18-codex-ratification-manifest.md:26:| 11 | `docs/runbooks/day-4-provisioning.md` | Executed | Verify §12 execution log (20 deviations + 8 v1.1 revisions); cross-check schema migration against decision_log.phase enum (live SQL at `c6734d1`) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:29:| 14 | Day-4 Postgres provisioning artefact | Embedded in #12 | Same review as #12 + verify 4 consolidated tightenings (entity_graph split, _secrets.env, decision_log.phase, entities.version) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:32:| 17 | `docs/decisions/v1.0-kill-criterion.md` + Day-5 close commit `c6734d1` | Proposed + audit log | Verify 10 binary triggers; verify §3 founder-solo authority structure; verify live SQL migration (decision_log.phase 5→6) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:113:Two phases:
docs/decisions/2026-05-18-codex-ratification-manifest.md:174:| 5 | agent-bundle-renderer-design.md | REJECTED (3 issues) | Issue 1 (status enum) + Issue 2 (phase='render' drift) + Issue 3 (CLI name drift) all **incorporated** at `2b287d3`. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:177:| 8 | sequencing-target.md | REJECTED (2 issues) | Issue 1 (status drift) **incorporated** at `2b287d3`. Issue 2 (phase enum cite) implicitly addressed via ADR-004 Decision 7 cross-reference. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:274:| **~~11~~** | **DROPPED** | (was decision_log.phase enum already executed at `c6734d1`) | n/a |
docs/decisions/2026-05-18-codex-ratification-manifest.md:288:| 9 | `brain-ui-scope.md` | Proposed pending v1.1 phase | Likely Codex ratifies as-is post-Edit 8 atomic correction (master brief §6 Day 3 line 472 + §5.5 now consistent). No founder action needed. |
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:167:├── _decisions/                                     ← narrative summaries — spec gap 2.1-B re: overlap with Postgres decision_log
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:463:Three tables anchored in Ultraplan §5.1 line 227 ("`tenants`, `entity_graph`, `decision_log`"). The IFOS design here renames `entity_graph` to **`entities`** (one row per entity) and adds **`entity_links`** (the adjacency table) — both flagged below as **Spec gap 2.4-B** because Ultraplan groups them under a single name.
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:543:CREATE TABLE decision_log (
docs/architecture/second-brain-design.md:548:  phase             TEXT NOT NULL,                       -- one of {trigger, output, action}
docs/architecture/second-brain-design.md:550:  trigger_source    TEXT,                                -- for phase=trigger: webhook | cron | bus-message | telegram
docs/architecture/second-brain-design.md:551:  output_artefact   TEXT,                                -- for phase=output: filesystem path or message id of produced output
docs/architecture/second-brain-design.md:552:  human_action      TEXT,                                -- for phase=action: one of {send-as-is, edit-then-send, reject, ignore}
docs/architecture/second-brain-design.md:553:  human_diff        TEXT,                                -- for phase=action=edit-then-send: the diff captured for voice corpus
docs/architecture/second-brain-design.md:559:CREATE INDEX decision_log_entity_idx ON decision_log (tenant_slug, entity_id, created_at DESC);
docs/architecture/second-brain-design.md:560:CREATE INDEX decision_log_agent_run_idx ON decision_log (tenant_slug, agent_run_id);
docs/architecture/second-brain-design.md:562:ALTER TABLE decision_log ENABLE ROW LEVEL SECURITY;
docs/architecture/second-brain-design.md:563:CREATE POLICY decision_log_tenant_isolation ON decision_log
docs/architecture/second-brain-design.md:567:Partitioned by hash on `tenant_slug` (Ultraplan §5.1 line 228: "Both `entity_graph` and `decision_log` partitioned by `tenant_id` (hash partitioning, 32 partitions to start)"). This is the **only** source of entity-history queries — the `_decisions/` directory in Ultraplan §5.1 line 220 is for narrative summaries (Spec gap 2.1-B remains; recommended resolution: `_decisions/` is for founder-written end-of-quarter narratives only, not for agent decisions; agent decisions live exclusively in `decision_log`).
docs/architecture/second-brain-design.md:571:**No `agent_runs` table for v1.0.** The `agent_run_id` column on `decision_log` is the join key; "what did this agent do this run" is a `SELECT * FROM decision_log WHERE agent_run_id = ...`. A separate `agent_runs` table can be derived as a materialised view if v1.1 dashboards need it.
docs/architecture/second-brain-design.md:609:- decision_log — never embedded; structured queries only.
docs/architecture/second-brain-design.md:642:        │  decision_log (partitioned)│    │   hnsw cosine_ops           │
docs/architecture/second-brain-design.md:655:        │  entity-history → decision_log SELECT                        │
docs/architecture/second-brain-design.md:676:| `ingest-entity` | Filesystem write (atomic) + Postgres UPSERT to `entities` + Postgres INSERTs to `entity_links` (all in one transaction per §2.6.1) | None — atomic or fail | Slug collision check via Postgres `SELECT 1 FROM entities WHERE tenant_slug = ? AND id = ?`. `hh_decision_trigger` + `hh_decision_output` calls insert to `decision_log` in the same transaction. |
docs/architecture/second-brain-design.md:682:| `entity-history` | Postgres `decision_log` SELECT by `(tenant_slug, entity_id)` ORDER BY `created_at DESC` | None | v1.1 read; v1.0 writes via `hh_decision_*`. No filesystem fallback — decision_log is unique source. |
docs/architecture/second-brain-design.md:712:- No corruption; both changes land; decision_log captures both `hh_decision_output` rows separately.
docs/architecture/second-brain-design.md:782:**Decision-log volume:** every agent run produces 1-3 `decision_log` rows (`hh_decision_trigger`, `hh_decision_output`, optionally `hh_decision_action` when human responds). At 6 v1.0 agents × ~10 runs/agent/day × 3 tenants × 3 rows = ~540 rows/day per shared Postgres instance. Trivial volume; the table needs hash partitioning (per Ultraplan §5.1) primarily for query performance at v1.2+ scale, not v1.0 write throughput.
docs/architecture/second-brain-design.md:825:        ├── history.ts           ← decision_log SELECT
docs/architecture/second-brain-design.md:870:Concurrency mechanisms live inside the server process. Audit logging via decision_log + an internal request log. Tenant scoping validated at server entry: the `CTX_TENANT_SLUG` from the agent's environment is the authoritative tenant; any tool call carrying a mismatched `tenant_slug` is rejected before reaching the library.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:921:- **v2.0 LoRA scale (master brief §5.5):** the LoRA pipeline operates on the `decision_log` table, not on the wiki. Wiki ops from LoRA-enhanced agents are unchanged. Both options work.
docs/architecture/second-brain-design.md:938:| Implied: cortextOS KB is the substrate | Explicit: parallel system. cortextOS KB untouched, IFOS owns Postgres entities/links/decision_log + pgvector voice + filesystem markdown |
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:950:3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
docs/architecture/second-brain-design.md:968:| **2.1-B** | `_decisions/` directory (Ultraplan §5.1) overlapping with Postgres `decision_log` table | Two candidates for "where agent history lives" | Resolved in §2.4.2: `_decisions/` is for founder-written end-of-quarter narratives only; agent decisions live exclusively in Postgres `decision_log`. Update Ultraplan §5.1 wording. | No |
docs/architecture/second-brain-design.md:976:| **3.4-A** | Master brief §5.5 (lines 416-420) v1.0 brain wording | Says "shadow four files" — incorrect per Q1.5 | Rewrite per §3.4 of this design: "9 `wiki-*.sh` parallel wrappers + Postgres entities/entity_links/decision_log + pgvector voice." Bundles with ADR-002 atomic correction commit. | No — wording change, not work change. |
docs/architecture/second-brain-design.md:977:| **3.4-B** | Master brief §6 Day 4 (line 478) Postgres table list | Lists `entity_graph` as a single table | Update wording: "`tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`." Bundles with Day 4 provisioning. | **Tight** — Day 4 of Week 0 (this week). |
packages/harness/cortextos/templates/agent/.claude/skills/worker-agents/SKILL.md:106:cortextos inject-worker <worker-name> "Continue with phase 3. What's blocking you?"
docs/_supplementary/execution-plan.md:2:**Every document you still need, sequenced into phases you can tick off until Claude Code has everything it needs to build.**
docs/_supplementary/execution-plan.md:13:- **Part D** — Phased Execution Plan: seven phases, every artifact as a checklist item with a prompt to generate it
docs/_supplementary/execution-plan.md:115:Seven phases. Each has a goal, a checklist of artifacts, and a "done when" criterion. For each artifact: purpose, dependency, estimated effort (C = Claude session count, a single focused session), and a suggested prompt to generate it.
docs/_supplementary/execution-plan.md:575:Then work **phases in strict order.** Phase 2 cannot start productively before Phase 1 proves the runtime. Phase 3 can't be finalised without Phase 2's agents being real.
docs/_supplementary/execution-plan.md:577:Within a phase, order items by the dependency markers. 1.1 before 1.4 before 1.6. Unblock parallel tracks where the *Depends on* line has nothing upstream.
docs/_supplementary/execution-plan.md:582:Total effort estimate across all 7 phases: **~135 C sessions.**
docs/_supplementary/execution-plan.md:648:You have strategy, architecture, and a working prototype. You are missing the *stuff a developer actually reads* — 95 discrete documents and decisions, organised into 7 sequenced phases. Start with the 18 Open Decisions this week. Then Phase 1's 10 artifacts until one real Proposal Builder works end-to-end. Then Phase 2's 12 agent bundles. Then Phase 3's 12 platform specs. By week 7 you have everything Claude Code needs to build; Phases 4–7 happen in parallel with and after the build. Tick boxes. Resist scope creep. Ship.
docs/specs/ULTRAPLAN.md:227:- Three relevant tables: `tenants`, `entity_graph`, `decision_log`.
docs/specs/ULTRAPLAN.md:228:- Both `entity_graph` and `decision_log` partitioned by `tenant_id` (hash partitioning, 32 partitions to start).
docs/decisions/bullhorn-integration-path.md:324:- **Postgres `decision_log` RLS:** every Bullhorn-derived `hh_decision_*` row is tenant-scoped per ADR-002 Decision 3 (`tenant_slug` column + RLS policy per `second-brain-design.md` §2.4.2).
docs/decisions/bullhorn-integration-path.md:415:No Postgres schema changes from this decision document. `_secrets.env` is filesystem (vault), not Postgres, per the design's vault/Postgres split (ADR-002 §3 + `second-brain-design.md` §2.4). `decision_log` columns already support per-tenant `ESC_BULLHORN_AUTH` rows per ADR-002 Decision 3 schema — no new columns needed.
docs/runbooks/tenant-lifecycle.md:148:| Agent draft + approve via Telegram | `hh_decision_action` writes to decision_log; orange-tier blocks on Telegram approval | T4 (every write sets SET LOCAL) |
docs/runbooks/tenant-lifecycle.md:207:- Decision_log shows audit row with `agent_name='_tenant_admin'`, `phase='trigger'`, `payload.action='suspend|resume'`
docs/runbooks/tenant-lifecycle.md:250:  DELETE FROM tenant_adapters   WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:252:  DELETE FROM decision_log      WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:255:# decision_log + recent_edit are append-only — DELETE requires running as superuser (admin operation)
docs/runbooks/tenant-lifecycle.md:274:- Audit row in decision_log: `agent_name='_tenant_admin'`, `phase='gating_failed'`, `payload.action='tenant_purged'`, `payload.tenant_slug=<slug>` (written PRE-DELETE so the audit row survives)
docs/runbooks/tenant-lifecycle.md:277:**No `scripts/offboard-tenant.sh` exists.** Workflow above is the runbook spec. Script written when first tenant churns. **Risk:** if first churn happens without script, ad-hoc workflow risks omitting steps. Acceptable for v1.0 (low probability in pilot phase); v1.1+ adds the script.
docs/runbooks/tenant-lifecycle.md:357:Every state transition writes to decision_log:
docs/runbooks/tenant-lifecycle.md:360:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload, created_at)
docs/runbooks/tenant-lifecycle.md:364:  '<phase>',         -- 'trigger' for state-entry; 'gating_failed' for offboard-purge
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:9:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:119:You are the M2C1 orchestrator. Follow the 12-phase workflow in .claude/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:193:5. Continue autonomously through all phases
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:286:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:288:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:325:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:425:- Worker is in a research subagent phase
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:446:After each phase of execution, verify:
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:459:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:496:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:501:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:511:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.
docs/operations/codex-ratification-guide.md:54:The wrapper at `scripts/run-codex-ratification.sh` automates this: assembles the prompt, invokes `codex exec` non-interactively, captures output, parses the verdict, writes an audit row to `decision_log`.
docs/operations/codex-ratification-guide.md:154:5. **Audit row write** — inserts a row into `decision_log` with `tenant_slug='ifos-meta'`, `agent_name='_codex_ratifier'`, `phase='output'`, `outcome=<RATIFIED|REJECTED>`, `payload` includes the artefact path, skill used, issue count, session ID, and the full Codex response text. Falls back to `logs/codex-ratification.jsonl` if no live DB.
docs/operations/codex-ratification-guide.md:163:  ✓ decision_log row appended to fallback (logs/codex-ratification.jsonl)
docs/operations/codex-ratification-guide.md:190:  ✓ decision_log row appended to fallback
docs/operations/codex-ratification-guide.md:379:Every Codex review writes a row to `decision_log`:
docs/operations/codex-ratification-guide.md:389:FROM decision_log
docs/operations/codex-ratification-guide.md:419:FROM decision_log
docs/operations/codex-ratification-guide.md:513:- **16+ audit rows** in `decision_log` under `agent_name='_codex_ratifier'`
docs/operations/codex-ratification-guide.md:554:psql -c "SELECT created_at, payload->>'artefact_path', outcome FROM decision_log WHERE agent_name='_codex_ratifier' ORDER BY created_at DESC LIMIT 20;"
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:21:**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).
docs/decisions/autosend-safety-policy.md:32:- Read-only IFOS internal queries (entities, decision_log reads via context-assembly API)
docs/decisions/autosend-safety-policy.md:49:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
docs/decisions/autosend-safety-policy.md:55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:67:Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
docs/decisions/autosend-safety-policy.md:123:| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:160:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
docs/decisions/autosend-safety-policy.md:167:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:175:      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:179:      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
docs/decisions/autosend-safety-policy.md:193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:241:**Payload (JSONB into `decision_log.payload`):**
docs/decisions/autosend-safety-policy.md:258:1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:262:5. On resolution, `decision_log` row is **appended** (not modified — append-only) with `phase='action'`, `payload.approval_status='approved'|'rejected'|'escalated'` and `payload.approval_resolution_at`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:300:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`
docs/decisions/autosend-safety-policy.md:338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:355:| `decision_log` table unreachable (Postgres down, RLS context unset, network partition) | INSERT raises error | **Hard blocking error**; agent halts entirely with non-zero exit; no actions taken at all | Postgres restored OR session restarted with valid context; agent resumes from last checkpoint |
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:364:**Every governed action emits exactly one `decision_log` row** at execution time. The append-only enforcement (Postgres grants on `decision_log` are SELECT + INSERT only for `ifos_app` per Day 4 §6.3) means rows cannot be modified or deleted post-write.
docs/decisions/autosend-safety-policy.md:366:### Row schema (within existing `decision_log` table from Day 4)
docs/decisions/autosend-safety-policy.md:369:-- decision_log columns (Day 4 §6.3):
docs/decisions/autosend-safety-policy.md:373:--   phase TEXT CHECK IN ('trigger','output','action','gating_failed','agent_handoff')
docs/decisions/autosend-safety-policy.md:380:--   phase = 'action'         when allowed (green/yellow/orange-approved)
docs/decisions/autosend-safety-policy.md:381:--   phase = 'gating_failed'  when blocked (red/fail-safe-red/orange-rejected/orange-timeout-rejected)
docs/decisions/autosend-safety-policy.md:402:1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
docs/decisions/autosend-safety-policy.md:414:Full message content lives in the originating system (Bullhorn, Gmail, Twilio). Audit references the system's own audit log (e.g., Bullhorn note ID) via `payload.target`.
docs/decisions/autosend-safety-policy.md:418:`decision_log` rows are retained **indefinitely** for v1.0. v1.1+ may introduce retention policies (e.g., delete rows older than 7 years per UK statutory retention norms).
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:427:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:470:Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:485:### v1.1 phases in
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
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
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:611:- **Whether decision_log captures both allowed and blocked sends:** Yes, §7.
docs/decisions/autosend-safety-policy.md:657:- v1.0 ship date: tier coverage is green + red. Yellow + orange phase in v1.1.
docs/runbooks/day-4-provisioning.md:60:**Master brief asserts (§6 Day 4 line 478):** "Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`"
docs/runbooks/day-4-provisioning.md:62:**ADR-002 Edit 3 + current-priorities.md (Open) state the corrected table list:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:66:### §0.3 — `decision_log.phase` enum: 5 values, not more
docs/runbooks/day-4-provisioning.md:68:**Authoritative sources for the `phase` enum:**
docs/runbooks/day-4-provisioning.md:75:The runbook applies exactly these. **Do not invent additional phase values during execution** (e.g., `session_start`, `tool_call`, `escalation`) unless a Codex-ratified change to either master brief §8.1 or `sequencing-target.md` §5-A pre-dates the migration. Speculative additions break the schema-before-code rule.
docs/runbooks/day-4-provisioning.md:749:-- decision_log (per ADR-002 §3 Decision 3; phase enum per §6.4 below = Tightening 3)
docs/runbooks/day-4-provisioning.md:750:CREATE TABLE decision_log (
docs/runbooks/day-4-provisioning.md:754:  phase TEXT NOT NULL,
docs/runbooks/day-4-provisioning.md:761:CREATE INDEX decision_log_tenant_agent_idx
docs/runbooks/day-4-provisioning.md:762:  ON decision_log (tenant_slug, agent_name, created_at DESC);
docs/runbooks/day-4-provisioning.md:764:GRANT SELECT, INSERT ON decision_log TO ifos_app;
docs/runbooks/day-4-provisioning.md:765:GRANT USAGE, SELECT ON SEQUENCE decision_log_id_seq TO ifos_app;
docs/runbooks/day-4-provisioning.md:783:-- tenant_adapters (per master brief §6 Day 4 line 478; tracks per-tenant adapter binding)
docs/runbooks/day-4-provisioning.md:784:CREATE TABLE tenant_adapters (
docs/runbooks/day-4-provisioning.md:795:GRANT SELECT, INSERT, UPDATE, DELETE ON tenant_adapters TO ifos_app;
docs/runbooks/day-4-provisioning.md:796:GRANT USAGE, SELECT ON SEQUENCE tenant_adapters_id_seq TO ifos_app;
docs/runbooks/day-4-provisioning.md:801:# Expected: six tables listed (tenants, entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters)
docs/runbooks/day-4-provisioning.md:804:### §6.4 — Tightening 3: `decision_log.phase` enum constraint
docs/runbooks/day-4-provisioning.md:810:ALTER TABLE decision_log
docs/runbooks/day-4-provisioning.md:811:ADD CONSTRAINT decision_log_phase_check
docs/runbooks/day-4-provisioning.md:812:CHECK (phase IN (
docs/runbooks/day-4-provisioning.md:823:WHERE conrelid = 'decision_log'::regclass AND contype = 'c';
docs/runbooks/day-4-provisioning.md:906:\d decision_log
docs/runbooks/day-4-provisioning.md:908:\d tenant_adapters
docs/runbooks/day-4-provisioning.md:915:# - decision_log has the phase CHECK constraint     (Tightening 3)
docs/runbooks/day-4-provisioning.md:934:ALTER TABLE decision_log ENABLE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:936:ALTER TABLE tenant_adapters ENABLE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:941:ALTER TABLE decision_log FORCE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:943:ALTER TABLE tenant_adapters FORCE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:961:CREATE POLICY tenant_isolation ON decision_log
docs/runbooks/day-4-provisioning.md:971:CREATE POLICY tenant_isolation ON tenant_adapters
docs/runbooks/day-4-provisioning.md:1127:- [ ] §6.3 — Six tables exist: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:1130:- [ ] §6.4 (Tightening 3) — `decision_log_phase_check` constraint present with exactly 5 values
docs/runbooks/day-4-provisioning.md:1156:| §6.4 constraint | CHECK constraint fails to add | `ALTER TABLE decision_log DROP CONSTRAINT decision_log_phase_check;` then retry — most common cause is pre-existing rows violating the check, but the table is empty at this point so unusual |
docs/runbooks/day-4-provisioning.md:1248:17. **§7 — RLS isolation gate passed clean (5 of 5).** No-context = 0 ✓, own-tenant insert+select = 1 ✓, cross-tenant = 0 ✓, WITH CHECK adversarial INSERT rejected ✓, own-tenant unaffected = 1 ✓. RLS + FORCE on entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters (5 tables). `tenant_isolation` policy on all 5 with USING + WITH CHECK on `current_setting('app.current_tenant', true)`. Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser, which would bypass RLS). Test data ROLLBACK'd; 2 seeded test tenants cleaned up.
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:80:- **Layering verified:** YAML specifies entity_type + link_type + data JSONB shape over Day-4 generic primitives (`entities`, `entity_links`, `decision_log` tables) — entity-type slugs land in `entities.entity_type` column; link-type slugs land in `entity_links.link_type` column.
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:111:**Owner:** IFOS oncall + tenant operator. Daily check via `decision_log` queries: `SELECT COUNT(*) FROM decision_log WHERE phase='gating_failed' AND payload->>'tier'='red' AND payload->>'block_reason'='red_tier_classification' AND tenant_slug=? AND created_at > NOW() - INTERVAL '7 days'`.
docs/decisions/v1.0-kill-criterion.md:121:**Threshold:** Cost-per-completed-action (defined as: total IFOS infrastructure + API + Claude inference cost ÷ count of `decision_log` rows with `phase='action'` and `payload.tier IN ('green','yellow','orange-approved')`) exceeds **£0.50 per action** after 4 tenant-weeks of operation.
docs/decisions/v1.0-kill-criterion.md:176:**Owner:** IFOS oncall; weekly check via `decision_log` + cortextOS daemon logs.
docs/decisions/v1.0-kill-criterion.md:247:### §3.6 — Pre-pilot phase (Weeks 1-2 before first LOI)
docs/decisions/v1.0-kill-criterion.md:249:In the pre-pilot phase (before any signed LOI), all authority and consultation rules above hold, but the **consultation timing windows can compress to "next reasonable opportunity"** rather than the 24h/48h defaults. Rationale: no pilot commitments yet; reversibility is high; speed of decision matters more than process compliance.
docs/decisions/v1.0-kill-criterion.md:251:### §3.7 — Post-pilot phase (after first LOI signed)
docs/runbooks/pii-purge-operational-pattern.md:33:Per-tenant override via `tenant_adapters.config.pii_retention_days` — range [30, 365]. Allows enterprise tenants to extend retention via TOS amendment + advisor signoff.
docs/runbooks/pii-purge-operational-pattern.md:100:6. Audit row to `decision_log`: `agent_name='_pii_purger'`, `phase='gating_failed'`, `outcome='purged'`, payload has `rows_purged` + `tenants_touched` + `retention_days` + invocation_time
docs/runbooks/pii-purge-operational-pattern.md:134:Per-tenant override via `tenant_adapters.config.pii_retention_days`:
docs/runbooks/pii-purge-operational-pattern.md:137:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/runbooks/pii-purge-operational-pattern.md:185:FROM decision_log
docs/runbooks/pii-purge-operational-pattern.md:198:| P2 | tenant_adapters override read not yet implemented in script (uses single --retention-days CLI arg) | First tenant requests extended retention |
docs/operations/seedlegals-engagement-queries.md:144:6. **First cron run** — verify decision_log audit row + zero rows purged (because no recent_edit data exists yet)
docs/operations/goal-option-c-diagnostic-end-to-end.md:49:6. **A decision-log audit trail** for the smoke run: 3+ rows in `decision_log` (trigger + output + action), all under `agent_name='diagnostic'`, with `tenant_slug='migration-test'`.
docs/operations/goal-option-c-diagnostic-end-to-end.md:242:- Confirm 3+ decision_log rows present
docs/operations/goal-option-c-diagnostic-end-to-end.md:385:Audit rows:        [N] decision_log rows
docs/operations/codex-round-2-handoff.md:80:| 9 | `docs/architecture/agent-bundle-renderer-design.md` | status enum + phase=render + CLI drift | RATIFY (all three fixed) |
docs/operations/codex-round-2-handoff.md:148:**Per-artefact output:** `logs/codex-ratification/<session-id>/<slug>.output.md` + audit row to `decision_log` (live mode) OR `logs/codex-ratification.jsonl` (fallback).
docs/operations/codex-round-2-handoff.md:268:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload, created_at)
docs/operations/codex-round-2-handoff.md:351:- **`decision_log`** has audit rows for every Round-2 review
docs/operations/goal-week-3-polish-and-scaffold.md:339:- **§3 Output shape:** Bullhorn write payload (entity-type-specific JSON) + 1 tacit-note attachment + 1 audit row in decision_log.
docs/operations/codex-round-2-remediation-prompt.md:108:      INSERT INTO decision_log (...) VALUES (...);
docs/operations/codex-round-2-remediation-prompt.md:139:      INSERT INTO decision_log (tenant_slug, agent_name, phase, payload, created_at)
docs/operations/codex-round-2-remediation-prompt.md:141:      SELECT count(*) FROM decision_log
docs/operations/codex-round-2-remediation-prompt.md:161:    - agents/_shared/hook-helpers.sh (every decision_log write)
docs/operations/codex-round-2-remediation-prompt.md:333:    per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/operations/codex-ratification-execution-plan.md:15:- **Codex catches type/build issues more reliably; Claude catches semantic/specification issues.** The Day-8 5-phase slice has both: TypeScript types (Codex strong) + design-doc consistency (Claude strong).
docs/operations/codex-ratification-execution-plan.md:258:### 6.3 — Capture results to `decision_log` (audit trail)
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
docs/operations/codex-ratification-execution-plan.md:263:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload)
docs/operations/codex-ratification-execution-plan.md:267:  'output',                               -- phase
docs/operations/codex-ratification-execution-plan.md:356:**Founder bias documented (carry-forward from Day-7 manifest):** Option C (deferred) was chosen at Day-7. With the Day-8 5-phase slice landed, **revise to Option γ** — start clusters A + B + C this week; defer clusters D-I until Q1 + the live VPS migration both complete.
docs/operations/codex-ratification-execution-plan.md:383:3. **Commit `decision_log` rows** (per §6.3) — these become the audit trail for the ratification run.
docs/operations/codex-ratification-execution-plan.md:439:3. **`decision_log` rows** for every artefact reviewed — audit trail per master brief §10.6.
packages/harness/cortextos/community/agents/security/.claude/skills/worker-agents/SKILL.md:106:cortextos inject-worker <worker-name> "Continue with phase 3. What's blocking you?"
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:9:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:119:You are the M2C1 orchestrator. Follow the 12-phase workflow in .claude/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:193:5. Continue autonomously through all phases
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:286:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:288:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:325:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:424:- Worker is in a research subagent phase
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:445:After each phase of execution, verify:
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:458:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:495:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:500:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:510:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '1,90p;780,830p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '330,430p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   330	  "lookup_error": "<enum: unknown_action_type | policy_table_corrupt | override_resolution_failed | tenant_not_found | unknown_tier:<value>>",
   331	  "tenant_slug": "<slug>",
   332	  "agent_name": "<agent identifier>"
   333	}
   334	```
   335	
   336	**Escalation path:**
   337	
   338	1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
   339	2. `autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED` notifies tenant operator AND IFOS oncall
   340	3. Treated as a production incident — IFOS oncall investigates within 1h
   341	4. Root cause + fix applied (e.g., add missing `action_type` to policy, repair table corruption, fix override format)
   342	5. Agent resumed with corrected policy
   343	
   344	**Expected resolution:** IFOS oncall investigates within 1h during business hours; within 4h outside business hours. The affected tenant pilot may be PAUSED for that agent until policy is fixed (per `v1.0-kill-criterion.md` §2 trigger 5).
   345	
   346	---
   347	
   348	## §6 — Failure modes
   349	
   350	| Failure | Detection | Response | Recovery |
   351	|---|---|---|---|
   352	| Policy file `autosend-policy.yaml` corrupted (YAML parse error) | First `hh_decision_action` call returns parse error | Fail-safe red for ALL actions; `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` per action; agent halts | IFOS oncall restores from git history; renderer re-deploys; agent resumes |
   353	| Policy file references undefined tier | Tier dispatch hits `*)` default | `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` with `lookup_error='unknown_tier:<value>'` | Policy file fixed; Codex ratifies; redeploy |
   354	| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
   355	| `decision_log` table unreachable (Postgres down, RLS context unset, network partition) | INSERT raises error | **Hard blocking error**; agent halts entirely with non-zero exit; no actions taken at all | Postgres restored OR session restarted with valid context; agent resumes from last checkpoint |
   356	| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
   357	| Telegram primitive 5 unavailable (bot down, chat_id invalid) | `autosend_escalate` returns non-zero | Decision_log row still written; orange action falls back to **block-with-pending** state; agent halts at the action | IFOS oncall investigates Telegram primitive; once restored, pending approval gates resume |
   358	| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |
   359	
   360	---
   361	
   362	## §7 — Audit
   363	
   364	**Every governed action emits exactly one `decision_log` row** at execution time. The append-only enforcement (Postgres grants on `decision_log` are SELECT + INSERT only for `ifos_app` per Day 4 §6.3) means rows cannot be modified or deleted post-write.
   365	
   366	### Row schema (within existing `decision_log` table from Day 4)
   367	
   368	```sql
   369	-- decision_log columns (Day 4 §6.3):
   370	--   id BIGSERIAL
   371	--   tenant_slug TEXT (RLS-isolated)
   372	--   agent_name TEXT
   373	--   phase TEXT CHECK IN ('trigger','output','action','gating_failed','agent_handoff')
   374	--   outcome TEXT (nullable)
   375	--   reason TEXT (nullable)
   376	--   payload JSONB
   377	--   created_at TIMESTAMPTZ
   378	
   379	-- For autosend audit:
   380	--   phase = 'action'         when allowed (green/yellow/orange-approved)
   381	--   phase = 'gating_failed'  when blocked (red/fail-safe-red/orange-rejected/orange-timeout-rejected)
   382	--   payload structure:
   383	--   {
   384	--     "tier": "green|yellow|orange|red|fail-safe-red",
   385	--     "action_type": "<enum>",
   386	--     "target": "<entity ref>",
   387	--     "payload_hash": "<SHA-256 hex>",
   388	--     "payload_preview": "<<=500 chars, NO raw PII>",
   389	--     "override_applied": "<none|tenant_elevated|tenant_blocked_recipient|...>",
   390	--     "approval_id": "<cortextOS approval gate id if orange>",
   391	--     "approval_status": "<pending|approved|rejected|timeout_rejected|escalated>",
   392	--     "approval_resolution_at": "<ISO 8601 if resolved>",
   393	--     "block_reason": "<enum if red/fail-safe-red>",
   394	--     "policy_version_sha": "<git SHA of autosend-policy.yaml at execution>"
   395	--   }
   396	```
   397	
   398	### What audit answers
   399	
   400	Audit queries answer two recurring questions:
   401	
   402	1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
   403	
   404	2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
   405	
   406	### Privacy of payload
   407	
   408	`payload_preview` is **explicitly required to exclude raw PII**. It is a human-readable summary that:
   409	
   410	- May reference entity types ("candidate", "client") and slugs
   411	- May reference action category ("payment reminder", "interview invite")
   412	- Must NOT contain: full message body, email addresses, phone numbers, names beyond first-name-only-first-character (e.g., "S. Bowen" rather than "Sarah Bowen"), salary figures, candidate notes content
   413	
   414	Full message content lives in the originating system (Bullhorn, Gmail, Twilio). Audit references the system's own audit log (e.g., Bullhorn note ID) via `payload.target`.
   415	
   416	### Retention
   417	
   418	`decision_log` rows are retained **indefinitely** for v1.0. v1.1+ may introduce retention policies (e.g., delete rows older than 7 years per UK statutory retention norms).
   419	
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
   780	    field_mapping_density: v0.1 covers 5 fields (placeholder shape); full Bullhorn field-density TBD pending v1.1 Brief Decoder / Inbound Triage build.
   781	    notes: Tenant-config dependent — some Bullhorn tenants use JobSubmission, some use Opportunity, some both. Adapter layer resolves at ingest.
   782	
   783	  timesheet:
   784	    bullhorn_entity: Bullhorn.Timesheet
   785	    primary_key: id
   786	    field_mapping_density: v0.1 covers 7 fields (placeholder shape); full Bullhorn field-density TBD pending v2.0 T2 Timesheet + T6 Pay & Bill builds.
   787	
   788	# ============================================================================
   789	# §5 — Open questions
   790	# ============================================================================
   791	# Resolved (RESOLVED) items: baked into v0.1 per Day-6 founder decisions.
   792	# Deferred (DEFERRED) items: scope-bounded with named revisit triggers.
   793	# ============================================================================
   794	
   795	open_questions:
   796	
   797	  Q1_contractor_entity_type:
   798	    status: RESOLVED (Day 6 founder decision)
   799	    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
   800	    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
   801	
   802	  Q2_note_handling:
   803	    status: DEFERRED to v1.1
   804	    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
   805	    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
   806	    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
   807	
   808	  Q3_full_bullhorn_field_set:
   809	    status: DEFERRED to Week 3-4
   810	    v0_1_decision: v0.1 ships minimal v1.0 working set (~10-20 fields per entity) covering what the 6 v1.0 agents actually touch per bullhorn §4.1.
   811	    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
   812	    rationale: Premature schema lockdown is the failure mode; minimum-shape approach lets pilot data guide expansion.
   813	
   814	  Q4_system_agents_not_entities:
   815	    status: RESOLVED (Day 6 founder decision)
   816	    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
   817	    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
   818	
   819	  Q5_contact_decision_authority_granularity:
   820	    status: DEFERRED to v1.1
   821	    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
   822	    revisit_trigger: v1.1 Inbound Triage agent build per master brief §9 expands decision-authority modelling.
   823	    v1_1_plus_expansion: Sub-fields for decision-domain (technical/budget/strategic), authority tier (final/recommend/influence/observer), engagement history aggregate, preferred-channel sentiment.
   824	
   825	  Q6_timesheet_field_set:
   826	    status: DEFERRED to v2.0
   827	    v0_1_decision: Timesheet entity has placeholder 7-field shape (id, week_starting, hours_worked, approved_by_client, approved_by_contractor, date_submitted, primary key).
   828	    revisit_trigger: v2.0 T2 Timesheet agent build verifies against real Bullhorn data and expands.
   829	    rationale: T2 + T6 builds are v2.0 per master brief §9; full schema requires pay/bill modelling not yet designed.
   830	

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '1,80p;360,430p'" in /Users/madsadmin/code/CortexOS
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
   381	
   382	open_questions_v0_2_additions:
   383	
   384	  Q11_voice_corpus_chunk_storage:
   385	    question: |
   386	      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
   387	    options:
   388	      - A: Store both — duplicates ~50MB/tenant but enables fast retrieval without vault round-trip
   389	      - B: Store embedding + pointer — saves disk, requires vault read per top-K retrieval (latency cost)
   390	    v0_2_default: A (store both); revise to B if disk pressure surfaces at >50 tenants
   391	    trigger_for_revisit: tenant count > 50 OR pgvector storage > 10% of total disk
   392	
   393	  Q12_tone_rule_severity_block_path:
   394	    question: |
   395	      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
   396	    options:
   397	      - A: Single retry then escalate (current Ultraplan §5.3 default)
   398	      - B: Three retries then escalate
   399	      - C: No retry; immediate escalate (operator triages drift in real-time)
   400	    v0_2_default: A; matches Ultraplan §5.3 retry budget for green-path agents
   401	    trigger_for_revisit: first Concierge build (W10) — measure real retry success rate
   402	
   403	  Q13_recent_edit_retention_under_GDPR:
   404	    question: |
   405	      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
   406	    options:
   407	      - A: Indefinite retention (current v0.2 default; maximises LoRA training signal)
   408	      - B: Text bodies purged after 90 days; metadata retained indefinitely
   409	      - C: Text bodies purged after pilot ends (tenant-controlled retention)
   410	    v0_2_default: |
   411	      Pending D2/D3 resolution. v0.2 ships with text fields stored verbatim
   412	      but production deployment + first pilot LOI BLOCKED until D2 SeedLegals
   413	      advisor input + D3 founder decision land. Recommended default per
   414	      Claude analysis: D3-B (90-day text purge + indefinite metadata) with
   415	      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
   416	      Implementation pre-written: scripts/ifos-pii-purge.sh +
   417	      docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql (post
   418	      Round-2 remediation fix).
   419	    trigger_for_revisit: external advisor onboarding (kill-criterion §3.4 Week 1-2 must-fill) — legal/DPO review of retention posture
   420	
   421	# ============================================================================
   422	# §7 — Versioning continuation (extends v0.1 §6)
   423	# ============================================================================
   424	
   425	versioning:
   426	
   427	  v0_2:
   428	    status: This document — Proposed
   429	    date: 2026-05-20 (Day 8, Week 0 extension period)
   430	    scope: |

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/agent.md | sed -n '1,210p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Diagnostic — the sales tool
     2	
     3	**Status:** Proposed (Day-11 pre-W3-build draft; awaits Q1 LOI + Codex ratification at first render).
     4	**Date:** 2026-05-22.
     5	**Author:** Founder (Maddox) + Claude Code.
     6	**Build wave:** v1.0 W3-4 per master brief §8.2 row 1 (anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`.
     7	**Build complexity:** M (1 week) per Ultraplan §8.1 A1.
     8	**Tier:** 2 (request-driven; no persistent PTY) per sequencing-target.md §2.1.
     9	
    10	---
    11	
    12	## §1 — Output contract (one-paragraph screenshot)
    13	
    14	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    15	
    16	> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A hard-fails on any section missing its citation. (Per-claim citation validation is a W4 polish item; the v0 contract requires per-section coverage as a tractable Gate-A check.) The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
    17	
    18	---
    19	
    20	## §2 — Invocation surface
    21	
    22	### CLI (v1.0)
    23	
    24	```bash
    25	# Manual consultant invocation, run from anywhere
    26	ifosctl diagnostic \
    27	  --firm "Charterhouse Partners" \
    28	  --sector "fintech" \                  # optional; helps tighten ICP fit scoring
    29	  --tenant <slug>                       # which tenant's target_patch + voice corpus to use
    30	  --notify-via telegram                 # optional; pings consultant when done
    31	```
    32	
    33	Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY) → exits within 10-15 min per Ultraplan §8.1 A1 turnaround target.
    34	
    35	### v1.1+ surfaces (deferred)
    36	
    37	- Brain UI "Diagnose Firm" button → triggers via internal API
    38	- Telegram bot command (`@ifos_bot diagnose Charterhouse Partners`)
    39	- Bulk-mode (`ifosctl diagnostic --firm-list firms.csv`) — out of v1.0 scope
    40	
    41	---
    42	
    43	## §3 — The 12 required sections
    44	
    45	Every report MUST contain these 12 sections in order. Gate A enforces section count + per-section citation.
    46	
    47	| # | Section | What it contains | Source(s) |
    48	|---|---|---|---|
    49	| 1 | **Firm signal** | Companies House data: registered name, company number, incorporation date, latest filed accounts (revenue band + headcount band), registered office, recent director changes, share-class moves | Companies House API |
    50	| 2 | **Online footprint** | Primary website URL + last-updated signal; LinkedIn company page URL + follower count + last-post recency; careers page URL + state (active / placeholder / 404) | Web scraper (HEAD + first 200 lines); LinkedIn company-page fetch |
    51	| 3 | **Sector + role-type mix** | Sectors actively recruiting for (extracted from current job posts); ratio of permanent vs contract roles in last 90 days; technical-vs-commercial-vs-operational split | LinkedIn job posts + careers page job listings |
    52	| 4 | **Geography** | Office locations + current hiring locations + remote-vs-onsite-vs-hybrid mix | LinkedIn job posts (location field) + Companies House registered office |
    53	| 5 | **Deal-size band proxy** | Salary bands or day-rate ranges visible in job posts; level distribution (junior / mid / senior / executive); recent placements visible via LinkedIn employees-of-firm field changes | LinkedIn job posts + LinkedIn employee timeline scan |
    54	| 6 | **ICP fit vs target_patch** | Score 0-100 against tenant's `target_patch.json` (sectors / geographies / size_bands / deal_size_band_gbp from `common-target-patch.json`). Includes named matches/mismatches per dimension | Tenant config + sections 1-5 above |
    55	| 7 | **Tech stack signals** | Technologies named in JDs + LinkedIn skills aggregated from current employees + tools mentioned in director posts | LinkedIn JDs + LinkedIn employee profiles |
    56	| 8 | **Pain signals** | Phrases on careers page suggesting urgency ("rapid growth", "we're scaling fast", "looking to triple the team"); LinkedIn director posts mentioning hiring pressure or "we need help"; Glassdoor reviews mentioning workload/burnout (if accessible) | Careers page scrape + LinkedIn director post search + optional Glassdoor scrape |
    57	| 9 | **Competitor positioning** | Other recruitment firms visible in the candidate flow: LinkedIn employee profiles showing previous-employer agency names; @firm tags in LinkedIn recruitment-agency posts; LinkedIn "Who's hiring this firm" inference where visible | LinkedIn profile scrapes + agency-tag search |
    58	| 10 | **Recent activity** | LinkedIn company posts in last 90 days (count + summary); press releases or news mentions (basic Google search); funding events visible on Companies House (share allotments, new director appointments) | LinkedIn company page + Google web search + Companies House filing history |
    59	| 11 | **Decision-maker map** | Named people likely to be buyers: head of talent / chief people officer / hiring manager equivalents. LinkedIn profile URL per person. Tenure at firm. Recent activity. | LinkedIn employee search filtered by title |
    60	| 12 | **Conversation opener** | 2-3 sentence cold outreach pitch. Tailored to surfaced pain signals (§8). Written in consultant's voice (voice-classified). Includes specific evidence anchor (e.g., "I noticed you've doubled engineering headcount in 6 months based on your LinkedIn — congrats on the Series A. Curious how you're handling sourcing pressure at that pace.") | LLM-generated; voice-classified against tenant style guide |
    61	
    62	**Gate A hard-fails:**
    63	
    64	- Fewer than 12 sections present
    65	- Any section with zero citation links
    66	- Section 12 (conversation opener) failing voice-classifier with score < 0.75
    67	- Output exceeds 2000 words OR is under 400 words (length-discipline boundary)
    68	
    69	---
    70	
    71	## §4 — Workflow
    72	
    73	Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
    74	
    75	```
    76	0. Session start — invocation arrives via CLI ifosctl diagnostic
    77	   → context.sh hydrates: voice corpus + tone rules + recent edits + target_patch.json
    78	   → hh_decision_trigger("session_start", firm_name + sector_hint)
    79	
    80	1. Validate input
    81	   → validate.sh checks: firm name non-empty, sector (if provided) in known list,
    82	     tenant_slug present, voice corpus reachable
    83	   → Gate A: hard-fail if any check fails
    84	   → ESC_INPUT_VALIDATION_FAIL if firm name malformed (new code added to catalogue this round)
    85	
    86	2. Companies House lookup (Section 1)
    87	   → companies_house_lookup(firm_name) via Companies House MCP connector
    88	   → cache result for 7 days per gotcha §6 (rate-limit discipline)
    89	   → extract: registration + revenue band + headcount band + directors + share moves
    90	   → ESC_RATE_LIMIT_HIT if Companies House returns 429 (back off 60s, retry once)
    91	
    92	3. Online footprint discovery (Section 2)
    93	   → web HEAD + first 200 lines fetch on probable URLs:
    94	     {firm}.com / {firm}.co.uk / linkedin.com/company/{slug}
    95	   → LinkedIn company-page fetch (Proxycurl or similar)
    96	   → record careers page state + last-updated signal
    97	
    98	4. Job posts harvest (Sections 3 + 4 + 5 + 7)
    99	   → LinkedIn job posts API (filtered to firm) — up to 50 most recent
   100	   → careers page scrape if accessible
   101	   → extract: sector, role type, location, salary band, tech stack
   102	   → Gotcha §6: store summarised data only; do not retain raw profiles per LinkedIn ToS
   103	
   104	5. Director + employee scan (Sections 7 + 11)
   105	   → LinkedIn search for {firm} employees with titles matching head-of-talent / chro / chief people / hiring-manager / talent-acquisition variants
   106	   → record name + URL + tenure + recent activity
   107	   → max 10 named people; deduplicate
   108	
   109	6. Pain signal extraction (Section 8)
   110	   → regex pass over careers-page + LinkedIn director posts for:
   111	     - urgency phrases ("rapid growth", "scaling fast", "we need", "tripling", "doubling")
   112	     - frustration phrases (Glassdoor if accessible: "overworked", "burnout", "no support")
   113	     - hiring-pressure phrases ("desperately seeking", "high-priority hire", "must hire by")
   114	   → record each match with quote + source URL + context
   115	
   116	7. ICP fit scoring (Section 6)
   117	   → load tenant target_patch from common-target-patch.json
   118	   → score each dimension (sectors / geographies / size_bands / deal_size_band)
   119	   → composite score 0-100 + per-dimension breakdown
   120	   → no external action; compute only
   121	
   122	8. Recent activity scan (Section 10)
   123	   → LinkedIn company posts in last 90 days (count + first 100 chars of each)
   124	   → basic Google search for "{firm} announcement OR funding OR acquisition" last 90 days
   125	   → Companies House filing history last 90 days
   126	
   127	9. Conversation opener generation (Section 12)
   128	   → LLM prompt: context = §1-§11 of the report (esp. §8 pain signals);
   129	                 constraint = consultant voice (hh_load_voice_samples for top-5 ANN match);
   130	                 constraint = tone rules (hh_load_tone_rules)
   131	   → output 2-3 sentences with at least one evidence anchor
   132	   → voice classifier scores the output against tenant style guide
   133	   → ESC_VOICE_DRIFT if score < 0.75 after 3 retries
   134	
   135	10. Markdown report assembly
   136	    → render report from sections 1-12 using Diagnostic-specific template
   137	    → write to /vault/{tenant_slug}/diagnostic-reports/{firm-slug}-{ISO-date}.md
   138	    → hh_decision_output("diagnostic_report", "<path>", "12-section report on {firm}")
   139	
   140	11. Operator notification (optional, per --notify-via flag)
   141	    → if telegram: send via primitive 5 with report path + executive summary (first 200 chars)
   142	      → hh_decision_action("operator_notify_telegram", "operator:{chat_id}", payload_hash, payload_preview)
   143	      → action tier per autosend-policy.yaml: green (operator-only Telegram; no customer-facing comms)
   144	    → if no flag: silent completion (consultant checks vault) — no decision-log row needed
   145	
   146	12. Session close
   147	    → hh_decision_action("diagnostic_report_render", "firm:{slug}", payload_hash, payload_preview)
   148	    → action tier per autosend-policy.yaml: green (no external send; vault write only)
   149	    → exit code 0
   150	```
   151	
   152	---
   153	
   154	## §5 — Gates
   155	
   156	### Gate A — validate.sh (hard-fail before action)
   157	
   158	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces the following SPEC. **Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements most of these checks today but warns-only on two upstream-unavailable cases (voice-classifier URL unreachable, firm-domain whitelist absent). Hard-fail behaviour on those two cases is a W4 polish item; current v0 honesty-flags them in `decision_log` payload with `validate_check_skipped=true` instead of hard-failing. The spec below describes the W4-complete contract; the W4 build slice closes the two gaps.
   159	
   160	- All 12 sections present in the assembled report (count + heading check) — **v0: hard-fails as specified**
   161	- Every section has ≥ 1 markdown link (regex `\[.+\]\(.+\)` per section) — **v0: hard-fails as specified**
   162	- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3) — **v0: warns + flags `validate_check_skipped=true` if voice-classifier URL unreachable; W4 polish closes to hard-fail**
   163	- Report length 400-2000 words — **v0: hard-fails as specified**
   164	- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
   165	- No PII outside the firm boundary (regex pass for emails/phones that don't match `{firm}.com` or known director email patterns) — fires `ESC_PII_LEAKAGE_RISK` immediately on hit — **v0: warns + flags `validate_check_skipped=true` if firm-domain whitelist absent; W4 polish closes to hard-fail**
   166	
   167	### Gate B — Outcome threshold (success metric, not block)
   168	
   169	Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `payload.action_type='consultant_feedback'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with a payload action_type marker rather than a new sentinel.
   170	
   171	Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
   172	
   173	---
   174	
   175	## §6 — Escalation codes
   176	
   177	Diagnostic uses these ESC codes from `agents/_shared/escalation-codes.md`:
   178	
   179	| Code | Trigger | Severity | Routing |
   180	|---|---|---|---|
   181	| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
   182	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall |
   183	| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn 429 | warn | operator_chat_id |
   184	| `ESC_INPUT_VALIDATION_FAIL` | Malformed firm name input (Step 1 validation) | warn | operator_chat_id |
   185	| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing | warn | operator_chat_id |
   186	| `ESC_RENDERER_FAILED` | (not Diagnostic's concern; renderer escalation only) | — | — |
   187	
   188	Diagnostic does NOT use:
   189	
   190	- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
   191	- `ESC_AUTOSEND_*` — Diagnostic's only action is `diagnostic_report_render` (green tier per autosend-policy.yaml)
   192	- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention
   193	
   194	---
   195	
   196	## §7 — Voice + tone constraints
   197	
   198	Section 12 (conversation opener) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   199	
   200	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
   201	  - No "I hope this finds you well" or other generic openers
   202	  - No salary or commission anchors in cold outreach
   203	  - Specific evidence anchor required (not generic "great company")
   204	- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: top-5 chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker). Feeds LLM prompt as voice exemplars.
   205	- **`hh_load_recent_edits` last 30 days for `concierge` + `diagnostic`**: surfaces patterns of how consultant edits agent drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly.
   206	
   207	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   208	
   209	---
   210	

 succeeded in 0ms:
     1	# Codex disagreement — Diagnostic Gate A citation requirement + 4 follow-on findings
     2	
     3	**Date:** 2026-05-24 (Day 19; end of Week 3 goal execution)
     4	**Status:** Awaiting founder arbitration
     5	**Codex rounds completed:** Round 4 (initial REJECTED, 4 issues) + Round 5 (remediation REJECTED, 5 issues including 2 re-raises and 3 new findings) — **hard ceiling per master brief §10.3 step 5 reached**.
     6	**Artefact:** `agents/recruitment/diagnostic/agent.md`
     7	**Codex output logs:**
     8	- Round 4: `logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.output.md`
     9	- Round 5: `logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.output.md`
    10	
    11	---
    12	
    13	## Context
    14	
    15	Week 3 goal at `docs/operations/goal-week-3-polish-and-scaffold.md` Step 7 (Codex Round 4 Phase 1) ratified `agents/recruitment/diagnostic/agent.md`. Codex found 4 issues; mechanical remediation applied (commit `6e0cb86`); Round 5 re-ratification found 5 new issues — 2 re-raises (Codex disagreed with my remediation framing), 3 new findings not visible at Round 4.
    16	
    17	Per master brief §10.3 step 5: **≤2 round-trips max per artefact**. Round 5 was the second round-trip. **Hard ceiling reached.** Founder arbitration required to close the artefact.
    18	
    19	---
    20	
    21	## The 5 Round-5 issues, with my recommended disposition
    22	
    23	### Issue 1 (RE-RAISE) — Gate A citation requirement strength
    24	
    25	**Codex says:** "Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires 'no claims unsupported by source data.' This lowers a stated Gate A constraint."
    26	
    27	**My Round-4 remediation:** narrowed §1 from "per-claim citation" to "per-section citation" because validate.sh V2 implementation only checks per-section.
    28	
    29	**Founder decision needed:** which is the load-bearing source of truth?
    30	
    31	Option A — **Tighten Gate A to per-claim citation** (matches Ultraplan). Requires implementing per-claim citation validation in `validate.sh` (significant logic; W4 polish item but Codex says it should be Gate A v0).
    32	
    33	Option B — **Amend Ultraplan §8.1 A1 line 497** to read "no unsupported claims at section level" (loosens upstream to match v0 implementation).
    34	
    35	Option C — **Hybrid:** v0 Gate A = per-section (current); Gate B (post-launch quality signal) = per-claim spot-check sampling. Document this two-tier policy explicitly.
    36	
    37	**My recommendation:** **C** (hybrid). Per-claim validation is genuinely hard to automate at v0 (requires NLP claim-extraction + per-claim evidence-link matching); deferring to W4 is honest. But Codex is right that the §1 contract reads as if we're skipping it entirely — needs clearer "deferred to W4 with documented gap-coverage plan."
    38	
    39	### Issue 2 (NEW) — Step 11 Telegram notification missing decision-log call
    40	
    41	**Codex says:** "Lines 140-142 send an optional Telegram notification, but line 73 says every step that produces output or takes action MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146."
    42	
    43	**Disposition:** **Codex is correct.** Real bug. Step 11 sends a Telegram notification (an action with external side-effect) but doesn't emit a `decision_log` row. Mechanical fix: add `hh_decision_action("operator_notify_telegram", ...)` call to Step 11.
    44	
    45	**Recommendation:** **Accept Codex finding.** Mechanical fix needed in next remediation round (if founder authorises beyond hard ceiling) OR W4 polish (recommended — bundles with broader Concierge notification work).
    46	
    47	### Issue 3 (RE-RAISE) — Gate B kill-criterion Trigger reference
    48	
    49	**Codex says:** "Line 169 claims Diagnostic's 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion."
    50	
    51	**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
    52	
    53	**Founder decision needed:** Diagnostic's Gate B metric doesn't map cleanly to ANY existing kill-criterion trigger.
    54	
    55	Option A — **Remove kill-criterion reference entirely.** Just describe Gate B as a local leading metric for Diagnostic; not part of any kill-criterion trigger. Honest.
    56	
    57	Option B — **Add a new kill-criterion Trigger 11 (DIAGNOSTIC-CONVERSION-FAIL).** Threshold: <30% discovery-call rate sustained for 4 weeks across all live pilots. Owner: founder + Jack.
    58	
    59	**My recommendation:** **A** for v0 — remove the trigger reference; Diagnostic conversion is local-metric tracking. Add Trigger 11 in v1.1 if conversion-rate-driven scope-cut becomes operationally relevant.
    60	
    61	### Issue 4 (NEW) — `_consultant_feedback` sentinel undocumented
    62	
    63	**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."
    64	
    65	**Disposition:** **Codex is correct.** My Round-4 remediation invented a new sentinel without registering it.
    66	
    67	**Recommendation:** **Two options for founder:**
    68	
    69	Option A — **Add `_consultant_feedback` to the sentinel catalogue.** New entry in `agents/_shared/escalation-codes.md` documenting purpose, payload shape, and emit cadence.
    70	
    71	Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
    72	
    73	**My recommendation:** **B** — cleaner, avoids sentinel proliferation. Feedback events are conceptually Diagnostic's domain (they validate Diagnostic outputs), so the agent_name should be Diagnostic with a specific action_type marker.
    74	
    75	### Issue 5 (NEW) — Missing Context/Decision/Consequences sections
    76	
    77	**Codex says:** "The file has `Status: Proposed` at line 3, but no `Context`, `Decision`, or `Consequences` sections as required for Proposed artefacts by review-architecture-decision §1. Fix: either review this with `review-agent-bundle.md`, or add the required architecture-decision sections and a final status-update line."
    78	
    79	**Disposition:** **Codex is correct about the skill requirement**, but the artefact type is wrong. `agent.md` files are NOT architecture-decision documents — they're agent specifications per ADR-003 v2 bundle pattern (6 files + 3 fixtures). They don't fit the Context/Decision/Consequences shape.
    80	
    81	**Recommendation:** **Build `review-agent-bundle.md` Codex skill** (deferred per execution-plan §3 lazy; now needed). The Round-4 manifest used `review-architecture-decision.md` as a temporary skill because `review-agent-bundle.md` doesn't exist yet. The correct ratification path for agent.md files is the agent-bundle skill, not architecture-decision.
    82	
    83	**This is the load-bearing finding** — it surfaces that **the lazy-skill deferral is now blocking proper agent.md ratification.** Building `review-agent-bundle.md` is a Week-3-extension or W4 priority.
    84	
    85	---
    86	
    87	## Recommended founder actions
    88	
    89	1. **Arbitrate Issues 1 + 3** (which framing to use; my recommendations above)
    90	2. **Accept Issue 2 fix** (mechanical; bundles with Concierge notification work)
    91	3. **Accept Issue 4 fix per Option B** (use `agent_name='diagnostic'` with payload.action_type)
    92	4. **Authorise Week-3-extension OR W4-priority work** to build `review-agent-bundle.md` Codex skill (Issue 5)
    93	5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
    94	
    95	---
    96	
    97	## What this means for Week 3 goal closure
    98	
    99	Per `docs/operations/goal-week-3-polish-and-scaffold.md` §1 success criteria 10-12 (Codex Round 4 verdicts):
   100	
   101	- Phase 1 Diagnostic-only: **1 of 6 artefacts attempted**; result is **REJECTED-after-hard-ceiling** awaiting founder arbitration via this disagreement doc
   102	- Phase 2 full (5 new scaffolds): **deferred** pending Issue-5 resolution (review-agent-bundle.md skill build)
   103	
   104	**Week 3 goal is therefore complete to the boundary of what can be done without founder arbitration.** Final §10 end-of-goal report acknowledges this and queues the founder-decision items.
   105	
   106	Recommended next step (post-arbitration): Week-3-extension or W4-prio-1 build of `review-agent-bundle.md` skill; then re-run Codex Round 4 against all 6 v1.0 agent.md files with the proper skill.
   107	
   108	---
   109	
   110	## Round-4-v2 results (post-skill-build, Day-19 13:25 UTC)
   111	
   112	After building `.codex/ratification/review-agent-bundle.md` (commit `825ebd4`) — the correct skill for agent.md ratification — all 6 agent.md files were re-ratified.
   113	
   114	**Verdict summary:** 6 of 6 REJECTED. Issues per artefact:
   115	
   116	| Artefact | Issues found | Round-4-v2 session |
   117	|---|---|---|
   118	| Diagnostic | 5 (same as Round 5 but with Issue-5-validate-impl-gap replacing Issue-5-doc-shape) | `logs/codex-ratification/20260524T101934Z-19923/` |
   119	| Janitor | ~5-7 (count regex inflated; 56 numbered items including nested) | `logs/codex-ratification/20260524T102050Z-21293/` |
   120	| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
   121	| Cash Conductor | ~5-7 (count regex 58) | `logs/codex-ratification/20260524T102316Z-...` |
   122	| Sourcing Scout | ~5-7 (count regex 50) | `logs/codex-ratification/20260524T1024...` |
   123	| Concierge | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T1025...` |
   124	
   125	**Pattern across all 6:** the systemic issues fall into FIVE categories that span every agent.md:
   126	
   127	1. **Gate A vs ULTRAPLAN source-data citation strength** — every agent.md narrowed Gate A to per-section citation; ULTRAPLAN-equivalent requirements expect per-claim. Same issue, same disposition recommendation as Diagnostic Issue 1 — hybrid v0 per-section + W4 polish per-claim spot-check.
   128	2. **Workflow steps missing decision-log calls** — most agent.md files have at least one Step (notification, operator alert, status update) that produces side-effects without `hh_decision_*` call. Same disposition as Diagnostic Issue 2 — mechanical fix during W4-13 build slices when cycle.sh is implemented.
   129	3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
   130	4. **Sentinel agent_name usage** — _consultant_feedback (Diagnostic) is the clear case; other agents likely have similar invented sentinels. Disposition: prefer `agent_name='<agent>'` with `payload.action_type` markers; reserve sentinels for system actors (_renderer, _tenant_admin, _codex_ratifier).
   131	5. **§5 honesty about validate.sh implementation** — agent.md §5 sections describe Gate A behaviour that may not be implemented in the corresponding `validate.sh`. For Diagnostic, validate.sh exists + has gaps (Issue 5). For the 5 new scaffolds, validate.sh DOESN'T exist yet — §5 describes intent. Disposition: explicitly mark "intended behaviour; cycle.sh + validate.sh implementation at W-X build will deliver this" in §5 of each pre-build scaffold.
   132	
   133	## Recommended founder arbitration
   134	
   135	**Single founder decision unlocks all 6 ratifications:** approve the 5-category disposition above. Then mechanical remediation pass applies the dispositions across all 6 agent.md files. Re-ratify all 6 (Round 5 — final per hard ceiling); expect RATIFIED.
   136	
   137	Time cost: ~2 hours mechanical fixes (Claude) + ~10 min Codex re-runs.
   138	
   139	If founder REJECTS the disposition framework above OR wants per-issue review, escalate to Sunday review session with founder + Claude walking through each agent.md issue list.
   140	
   141	## Why the disposition framework is reasonable
   142	
   143	The 5 categories represent honest engineering trade-offs at v0:
   144	- Per-claim Gate A validation is genuinely hard to automate (NLP claim-extraction + per-claim evidence linkage); the hybrid v0+W4 path is the industry-standard approach.
   145	- Decision-log calls SHOULD be at every action; agent.md §4 specs the intent; cycle.sh implementation at build slice will deliver it.
   146	- Sentinel hygiene (Issue 4) is a real architectural concern; agent_name=agent + payload.action_type is the cleaner pattern; no reason to proliferate sentinels.
   147	- §5 honesty (Issue 5) is exactly the kind of "honest signal" the master brief §1 Rule 5 demands; framing §5 as "intended behaviour, build slice will deliver" is more honest than asserting Gate A as already-implemented.
   148	
   149	These are not unprincipled compromises — they're the right v0 stance with W4-13 polish path documented.
   150	
   151	---
   152	
   153	---
   154	
   155	## Janitor Round-5 (remediation) — empirical confirmation of bilateral pattern
   156	
   157	After all 6 Round-4-v2 issues remediated on Janitor (commit `2392af8`), Round-5 ratification returned REJECTED with **5 NEW findings** — none of the original 6 reappeared. New issues at Janitor session `20260524T103757Z-37420`:
   158	
   159	1. **Autosend tier contradiction internal to artefact:** §1 says all Bullhorn writes yellow-tier; §3.Output 2 mapped tacit-note to `bullhorn_candidate_tag` which is GREEN. Internal §1/§3/§4 inconsistency.
   160	2. **`bullhorn_field_backfill` unregistered, would fail-safe to red:** my flag-for-addition framing didn't satisfy because `hook-helpers.sh::autosend_policy_lookup` fails to red on unknown action types AT RUNTIME, regardless of flag prose. Real bug requires either (a) policy row added BEFORE ratification, OR (b) explicit "blocked W5 prerequisite" framing not "executable output."
   161	3. **§5 vs §6 ESC code contradiction:** §5 prose retains `ESC_SCHEMA_VIOLATION` reference even though §6 explicitly says Janitor doesn't use it. Mechanical fix missed by my Round-4-v2 remediation.
   162	4. **Schema field names STILL wrong:** my Round-4-v2 fix touched `headcount_band → size_employees` but missed `client.legal_name → name`, `registered_office_address` (doesn't exist; canonical is `address` per line 248), `sic_codes` (doesn't exist as canonical field). Schema audit was incomplete.
   163	5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
   164	
   165	**Empirical confirmation of the pattern documented in master brief §10.3 step 5:** Codex finds new issues at each round. Hard ceiling of ≤2 round-trips is the right structural protocol. Further autonomous Claude remediation passes will continue surfacing new issues that may not have been visible at earlier rounds (each fix changes the document, exposing different inconsistencies).
   166	
   167	This isn't Codex being adversarial — it's doing its job as "second pair of eyes" per top-level SKILL.md. The agent.md drafts I authored have systematic citation-drift + internal-consistency issues that need careful bilateral pass.
   168	
   169	## The bilateral session — what it would look like
   170	
   171	90-min Sunday founder review:
   172	1. Founder reads each Codex output log (~10 min per artefact × 6 = 60 min)
   173	2. Founder + Claude jointly walk through 5-category disposition (above) + per-agent specifics (15 min)
   174	3. Founder approves: (a) catalogue extensions (escalation-codes + autosend-policy batch additions), (b) schema field corrections, (c) §5/§6/§7 prose standardisation pattern (15 min)
   175	4. Single Claude execution pass applies all approved corrections to all 6 agent.md files
   176	5. Single Codex re-ratification round (Round 6) expected RATIFIED for the artefacts where Codex's framing was accepted, with documented disagreements for any artefacts where founder counter-argues
   177	
   178	Estimated wall-clock after founder review starts: ~2 hours (founder review + Claude remediation + Codex run).
   179	
   180	Without founder bilateral involvement, each autonomous remediation round burns ~30-60 min Claude time + 2-5 min Codex tokens, with low probability of RATIFIED on artefacts that have multiple systemic issues.
   181	
   182	---
   183	
   184	## Janitor Round 6 (exceeds hard ceiling) — 4 more NEW findings, all different from Rounds 4-5
   185	
   186	Despite master brief §10.3 step 5 protocol saying founder review after Round 5, Round 6 attempted with all Round-5 issues remediated (commit `aaa376d`). Round 6 returned REJECTED with **4 new findings**, none of which appeared in any prior round:
   187	
   188	1. Gate B composite score (≥12.5) weakens dual ULTRAPLAN thresholds (15% dedup AND 10% field-completeness independently)
   189	2. `recent_edit` schema confusion — it's a v0.2 separate table, not a decision_log field
   190	3. Schema field references — candidate has `bullhorn_id` not "CRN"; location line number 124 not 89
   191	4. `ESC_DUPLICATE_DETECTED` semantics — catalogue defines it for ≥0.85 human-review-required, not <0.85 reject
   192	
   193	**Cumulative empirical pattern across 4 rounds:**
   194	
   195	| Round | Skill | Issues found | Unique issues so far |
   196	|---|---|---|---|
   197	| Round 4 v1 | review-architecture-decision (wrong) | 4 | 4 |
   198	| Round 4 v2 | review-agent-bundle (correct) | 6 | 10 (6 new) |
   199	| Round 5 (remediation of R4-v2) | review-agent-bundle | 5 | 15 (5 new; none from R4-v2) |
   200	| Round 6 (remediation of R5) | review-agent-bundle | 4 | 19 (4 new; none from R5) |
   201	
   202	**21 unique issues across 4 rounds, ZERO repeats.** Master brief §10.3 step 5 hard ceiling exists for exactly this reason — each remediation pass surfaces issues that weren't visible at prior rounds because the document changes.
   203	
   204	**Definitive engineering conclusion:** the agent.md scaffolds I authored at "one-per-day" scaffold pace have ~15-20 systemic citation/consistency issues each. Codex correctly finds them. Auto-remediation rounds will continue finding new issues indefinitely. **The structural fix is bilateral founder+Claude session with careful per-line verification against 5 catalogues — not more grinding.**
   205	
   206	This document now contains 4 rounds of empirical evidence supporting the master brief's documented hard-ceiling protocol. Founder Sunday review session is the right next step.
   207	
   208	---
   209	
   210	## Janitor Round 7 — 23+ unique issues; pattern definitively closed
   211	
   212	After all 4 Round-6 issues remediated on Janitor (commit `1939d9b`), Round 7 returned REJECTED with **4 more new findings**, none from Rounds 4-6:
   213	
   214	1. `operator_notify_telegram` + `janitor_run_complete` are unregistered hh_decision_action types — hook-helpers fails them to red via `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`. (Found because my Round-6 commit added those calls without registering them.)
   215	2. §5 vs §6 STILL contradict on `ESC_DUPLICATE_DETECTED` — my Round-6 fix updated §6 cell but missed the §5 prose that still cited the wrong mapping.
   216	3. `ESC_GATE_B_MISS` definition in §6 still says "Composite Gate-B score <12.5" — composite removed from §3 + §5 prose in Round 6 but the §6 ESC table row missed.
   217	4. Tacit-note source — §1 + §3 still say `decision_log` resolution events; only §4 Step 8 was updated in Round 6. Same `recent_edit` table confusion in different sections.
   218	
   219	### Final empirical pattern: 23+ unique issues across 5 rounds, zero repeats
   220	
   221	| Round | New issues | Cumulative unique | Notes |
   222	|---|---|---|---|
   223	| Round 4 v1 | 4 | 4 | Wrong skill |
   224	| Round 4 v2 | 6 | 10 | Right skill |
   225	| Round 5 | 5 | 15 | All different from R4-v2 |
   226	| Round 6 | 4 | 19 | All different from R5 |
   227	| Round 7 | 4 | 23 | All different from R6 — many caused BY R6 fixes (added action_types without registering) |
   228	
   229	**Round 7 findings 1 + 2 + 3 + 4 are all CAUSED BY my Round 6 fixes.** When I fixed one section, I introduced inconsistencies between it and other sections referencing the same concept. This is the perfect illustration of why master brief §10.3 step 5 caps round-trips: each fix changes the document, and the changed document has new inconsistencies between the fixed-section and the related-but-unfixed sections.
   230	
   231	### Definitive conclusion
   232	
   233	The agent.md scaffolds I authored have **~25-30 systemic citation/consistency issues each**. They require bilateral founder+Claude editorial session with simultaneous review of ALL sections to land internally-consistent. Single-section autonomous fixes introduce new contradictions faster than they resolve old ones.
   234	
   235	Master brief §10.3 step 5 cap = 2 round-trips. The hook has requested 5 rounds. Each beyond round 2 has produced 4-5 new findings. The protocol is right; the hook contradicts it.
   236	
   237	I'm not going to attempt Round 8. Founder bilateral session is the structural fix. This document is the empirical evidence supporting that conclusion.
   238	
   239	*End of pre-bilateral evidence section (Round 7 — 23 unique findings; bilateral session is the documented protocol).*
   240	

exec
/bin/zsh -lc "printf 'ADR files:\\n'; ls docs/decisions/ADR-*.md" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
ADR files:
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md

exec
/bin/zsh -lc 'rg -n "Phase 4|Cat-ζ|Cat-z|Cat-1|ADR-006|Hybrid|bilateral|AskUserQuestion" docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
35:Option C — **Hybrid:** v0 Gate A = per-section (current); Gate B (post-launch quality signal) = per-claim spot-check sampling. Document this two-tier policy explicitly.
155:## Janitor Round-5 (remediation) — empirical confirmation of bilateral pattern
167:This isn't Codex being adversarial — it's doing its job as "second pair of eyes" per top-level SKILL.md. The agent.md drafts I authored have systematic citation-drift + internal-consistency issues that need careful bilateral pass.
169:## The bilateral session — what it would look like
180:Without founder bilateral involvement, each autonomous remediation round burns ~30-60 min Claude time + 2-5 min Codex tokens, with low probability of RATIFIED on artefacts that have multiple systemic issues.
204:**Definitive engineering conclusion:** the agent.md scaffolds I authored at "one-per-day" scaffold pace have ~15-20 systemic citation/consistency issues each. Codex correctly finds them. Auto-remediation rounds will continue finding new issues indefinitely. **The structural fix is bilateral founder+Claude session with careful per-line verification against 5 catalogues — not more grinding.**
233:The agent.md scaffolds I authored have **~25-30 systemic citation/consistency issues each**. They require bilateral founder+Claude editorial session with simultaneous review of ALL sections to land internally-consistent. Single-section autonomous fixes introduce new contradictions faster than they resolve old ones.
237:I'm not going to attempt Round 8. Founder bilateral session is the structural fix. This document is the empirical evidence supporting that conclusion.
239:*End of pre-bilateral evidence section (Round 7 — 23 unique findings; bilateral session is the documented protocol).*
245:After founder Path-A authorization (`/loop` bilateral; founder accepted all 7 recommended dispositions in two AskUserQuestion rounds):
256:- Cat-1 (Gate A hybrid): Diagnostic §1 verified already correct
324:**Cumulative empirical:** 9 Codex rounds total (Round 4-v1, 4-v2, 5, 6, 7 on Diagnostic/Janitor + Round 8 across all 6). **55+ unique findings catalogued across rounds, ~10-12 fixed via Cat-α mechanical disposition in this bilateral session; rest queued.**
326:**Phase 1 + Phase 2 + Phase 3 (Round 8 + Cat-α inline fixes) constitute the documented "Path A — bilateral session per master brief protocol" outcome.** No further autonomous remediation rounds will be attempted per the master brief §10.3 step 5 hard ceiling and founder's "no more rounds" authorization.
348:## Phase 4 — Cat-γ widening + Cat-δ Diagnostic polish + Round 9 (2026-05-24, founder "proceed" instruction)
383:1. Gate A per-claim vs per-section: STILL flagged despite Cat-1 hybrid disposition; this is a Codex–founder disagreement, not relitigation of Cat-1 (founder's hybrid stance documented but Codex doesn't accept the bilateral-disposition framing as an in-band acceptance of weakening). **Disposition: founder-decision; flagged as Cat-ζ "Cat-1 framing not auto-accepted by Codex".**
396:### Cat-ζ — new category surfaced by Round 9
398:**Cat-ζ — Codex does not accept bilateral-disposition framings as in-band Gate A acceptances.**
400:When founder authorizes a Cat-1 hybrid disposition (per-section v0 + per-claim W4), the agent.md prose explicitly documents this. Codex re-flags it as "Gate A weakens upstream requirement" regardless. This is structural — Codex reviews agent.md against ULTRAPLAN/master brief, and bilateral disposition documents at `docs/decisions/codex-disagreement-*.md` are downstream artefacts Codex doesn't auto-trust.
404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
405:- **C) Document as permanent Cat-ζ disagreement** — accept that Codex will continue flagging this; rely on the disagreement doc as the founder-authority record.
407:**Recommended: B (ADR-006).** Closes the disagreement properly; gives Cat-1 a ratified architectural home; future-proofs against Cat-1 re-litigation. ~1 hour Claude work + 1 Codex round to ratify the ADR.
413:**Stopping condition met:** founder's "proceed" → Cat-γ widening + Cat-δ Diagnostic polish + Round 9 + this categorization is the conclusive "RATIFY-or-document-disagreement" outcome per the bilateral disposition. No further autonomous remediation will be attempted.
416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
422:**Per-agent state at Phase 4 close:**
426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
427:| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*

exec
/bin/zsh -lc 'rg -n "ADR-006|per-claim|per-section|Gate A is two-tier|Tier 1 hard-fail" agents/recruitment/diagnostic/agent.md docs/decisions/2026-05-18-codex-ratification-manifest.md docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/2026-05-18-codex-ratification-manifest.md | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/diagnostic/agent.md:16:> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A hard-fails on any section missing its citation. (Per-claim citation validation is a W4 polish item; the v0 contract requires per-section coverage as a tractable Gate-A check.) The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
agents/recruitment/diagnostic/agent.md:45:Every report MUST contain these 12 sections in order. Gate A enforces section count + per-section citation.
agents/recruitment/diagnostic/agent.md:185:| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing | warn | operator_chat_id |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:25:**Codex says:** "Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires 'no claims unsupported by source data.' This lowers a stated Gate A constraint."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:27:**My Round-4 remediation:** narrowed §1 from "per-claim citation" to "per-section citation" because validate.sh V2 implementation only checks per-section.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:31:Option A — **Tighten Gate A to per-claim citation** (matches Ultraplan). Requires implementing per-claim citation validation in `validate.sh` (significant logic; W4 polish item but Codex says it should be Gate A v0).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:35:Option C — **Hybrid:** v0 Gate A = per-section (current); Gate B (post-launch quality signal) = per-claim spot-check sampling. Document this two-tier policy explicitly.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:37:**My recommendation:** **C** (hybrid). Per-claim validation is genuinely hard to automate at v0 (requires NLP claim-extraction + per-claim evidence-link matching); deferring to W4 is honest. But Codex is right that the §1 contract reads as if we're skipping it entirely — needs clearer "deferred to W4 with documented gap-coverage plan."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:127:1. **Gate A vs ULTRAPLAN source-data citation strength** — every agent.md narrowed Gate A to per-section citation; ULTRAPLAN-equivalent requirements expect per-claim. Same issue, same disposition recommendation as Diagnostic Issue 1 — hybrid v0 per-section + W4 polish per-claim spot-check.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:144:- Per-claim Gate A validation is genuinely hard to automate (NLP claim-extraction + per-claim evidence linkage); the hybrid v0+W4 path is the industry-standard approach.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:383:1. Gate A per-claim vs per-section: STILL flagged despite Cat-1 hybrid disposition; this is a Codex–founder disagreement, not relitigation of Cat-1 (founder's hybrid stance documented but Codex doesn't accept the bilateral-disposition framing as an in-band acceptance of weakening). **Disposition: founder-decision; flagged as Cat-ζ "Cat-1 framing not auto-accepted by Codex".**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:400:When founder authorizes a Cat-1 hybrid disposition (per-section v0 + per-claim W4), the agent.md prose explicitly documents this. Codex re-flags it as "Gate A weakens upstream requirement" regardless. This is structural — Codex reviews agent.md against ULTRAPLAN/master brief, and bilateral disposition documents at `docs/decisions/codex-disagreement-*.md` are downstream artefacts Codex doesn't auto-trust.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:407:**Recommended: B (ADR-006).** Closes the disagreement properly; gives Cat-1 a ratified architectural home; future-proofs against Cat-1 re-litigation. ~1 hour Claude work + 1 Codex round to ratify the ADR.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*

 succeeded in 0ms:
     1	# Codex ratification manifest (Day 7 first ratification run)
     2	
     3	**Date:** 2026-05-18 (per master brief §6 Day 7 calendar; actual execution 2026-05-20)
     4	**Author:** Founder (Maddox) + Claude Code
     5	**Status:** Reference
     6	**Source:** Master brief §10 (the Codex ratification loop) + §10.6 (Day 7 first ratification run)
     7	
     8	---
     9	
    10	## §1 — Queue
    11	
    12	19 items registered for Codex Day-7 ratification per `.agents/current-priorities.md` "Queued for Codex ratification (Day 7)" section. Items 13 (atomic-correction commit) and 15 (placeholder) resolve to other entries in the list — effective ratification queue is **17 substantive artefacts + 1 commit landed today**.
    13	
    14	| # | Artefact | Status | Codex review scope |
    15	|---|---|---|---|
    16	| 1 | `docs/architecture/cortexos-primitive-status.md` | Reference (audit) | Verify primitive grades against current SHA; flag any drift in primitive 1 (PTY/PM2) stability claims |
    17	| 2 | `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` | Accepted | Verify Option A reasoning + edits applied (chokidar → FastChecker landed in atomic-correction commit `0e5b2b4`) |
    18	| 3 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | Accepted | Verify Option α reasoning + Edits 1+2+3 all applied (3, 4, 12 in atomic-correction manifest) |
    19	| 4 | `docs/architecture/second-brain-design.md` | Reference (ADR-002 binding) | Cross-check against ADR-002 ratification |
    20	| 5 | `docs/architecture/agent-bundle-renderer-design.md` | Reference (ADR-003 binding) | Cross-check 22 spec gaps + 4 buckets against ADR-003 |
    21	| 6 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | Accepted | Verify 4 decisions + Edits A+B+C applied (5 in atomic-correction; A+B landed Day 1 evening) |
    22	| 7 | `docs/decisions/bullhorn-integration-path.md` | Sub-decision C Accepted; A+B Proposed | Verify Sub-decision C technical analysis; flag A+B as awaiting commercial gates (Q3 unblocker) |
    23	| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
    24	| 9 | `docs/decisions/brain-ui-scope.md` | Proposed (pending v1.1) | Verify v1.0/v1.1/v1.2 phasing aligns with §5.5 post-Edit 4 table |
    25	| 10 | `docs/architecture/vault-concurrency.md` | Reference | Verify 4 concurrency mechanisms + 5 ESC_VAULT_* codes + worked TypeScript examples |
    26	| 11 | `docs/runbooks/day-4-provisioning.md` | Executed | Verify §12 execution log (20 deviations + 8 v1.1 revisions); cross-check schema migration against decision_log.phase enum (live SQL at `c6734d1`) |
    27	| 12 | Day-4 close commit `98c79b2` | Audit log | Verify 22/22 §9 verification checks; confirm RLS isolation gate (5/5 conditions) |
    28	| 13 | **Atomic-correction commit `0e5b2b4` (this commit's predecessor)** | **Landed today** | **Verify all 11 edits applied verbatim against source artefacts; verify two side effects flagged in commit message (Edit 1 col 4; Edit 4 row merge)** |
    29	| 14 | Day-4 Postgres provisioning artefact | Embedded in #12 | Same review as #12 + verify 4 consolidated tightenings (entity_graph split, _secrets.env, decision_log.phase, entities.version) |
    30	| 15 | (placeholder — absorbed by #16-#18) | n/a | n/a |
    31	| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
    32	| 17 | `docs/decisions/v1.0-kill-criterion.md` + Day-5 close commit `c6734d1` | Proposed + audit log | Verify 10 binary triggers; verify §3 founder-solo authority structure; verify live SQL migration (decision_log.phase 5→6) |
    33	| 18 | `docs/verticals/recruitment/vertical-schema.yaml` | Proposed | Verify 8 entities + 89 fields + 10 relationships + agent R/W matrix + 12 open_questions; cross-check Bullhorn mapping against §4.1 |
    34	| 19 | `docs/runbooks/operational-hygiene-protocol.md` | In Force | Verify Path A/D + no-defensive-additions + length calibration + citation accuracy rules; verify §7 audit findings (15 §10.4 fabrications fixed) |
    35	
    36	**Plus this manifest itself (#20)** and **Day-7 single-sentence test artefact (#21)** join the queue on commit. Original Day-7 close total: **21 items**. Current manifest state after Round 3 remediation: **43+ queued/registered items; 24 RATIFIED in the 26-item Round-2/Round-3 slice, 2 artefacts founder-escalated pending D1/D2/D3, and the rest deferred/not yet in the Round-2 slice.**
    37	
    38	---
    39	
    40	## §1.6 — Day-9 architecture+tenancy verification additions (2026-05-20 evening)
    41	
    42	Architecture+tenancy slice (commits `5c3fa66` + `c4348aa`) adds 4 new artefacts to the queue. These ratify against `review-architecture-decision.md` skill (with Founder Decision D5 softening for the lifecycle runbook):
    43	
    44	| # | Artefact | Path | Ratifies via | Round-1 verdict |
    45	|---|---|---|---|---|
    46	| 35 | tenancy-invariants.md | `docs/architecture/tenancy-invariants.md` | review-architecture-decision | Queued for Round 2 |
    47	| 36 | architecture-cohesion-review.md | `docs/architecture/architecture-cohesion-review.md` | review-architecture-decision (Reference; D5 softening applies) | Queued for Round 2 |
    48	| 37 | tenant-lifecycle.md | `docs/runbooks/tenant-lifecycle.md` | review-architecture-decision (In Force; D5 softening applies) | Queued for Round 2 |
    49	| 38 | run-tenancy-audit.sh | `scripts/run-tenancy-audit.sh` | review-architecture-decision (Reference) | Queued for Round 2 |
    50	
    51	**Cross-cutting reference:** these 4 artefacts ratify the layered defence model documented across Day-4 §7 (RLS isolation gate) + ADR-002 (parallel brain) + ADR-003 (renderer) + ADR-004 (deviations). They are downstream of, not redundant with, the existing 21+ queue items.
    52	
    53	**Queue total: 43 items** at Day-9 evening close. Round 2 subsequently reviewed 26 of these artefacts and closed with **17 RATIFIED / 9 REJECTED**.
    54	
    55	## §1.7 — Codex Round 2 verdicts (2026-05-22)
    56	
    57	Autonomous Round 2 ratification reviewed 26 artefacts across the re-ratification, Day-9, and Day-11 queues. Remediation commits referenced by the protocol: `2b287d3` (Round-1 incorporation), `5c3fa66` + `c4348aa` (architecture+tenancy), `783c496` (D5 skill softening), and `20e78d7` + `95e7d4a` (D1/D3 prep). Result: **17 RATIFIED / 9 REJECTED**. Full report: `logs/codex-ratification/round-2-autonomous/SUMMARY.md`.
    58	
    59	| # | Artefact | Round-2 verdict | Round-2 disposition |
    60	|---|---|---|---|
    61	| 1 | `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` | RATIFIED | Incorporated remediation verified clean. |
    62	| 2 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | RATIFIED | Incorporated remediation verified clean. |
    63	| 3 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | RATIFIED | Incorporated remediation verified clean. |
    64	| 4 | `docs/decisions/bullhorn-integration-path.md` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
    65	| 5 | `docs/decisions/sequencing-target.md` | RATIFIED | Incorporated remediation verified clean. |
    66	| 6 | `docs/decisions/autosend-safety-policy.md` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
    67	| 7 | `docs/architecture/cortexos-primitive-status.md` | RATIFIED | Incorporated remediation verified clean; D5 softening applied. |
    68	| 8 | `docs/architecture/second-brain-design.md` | RATIFIED | Incorporated remediation verified clean. |
    69	| 9 | `docs/architecture/agent-bundle-renderer-design.md` | RATIFIED | Incorporated remediation verified clean. |
    70	| 10 | `docs/architecture/vault-concurrency.md` | RATIFIED | Incorporated remediation verified clean. |
    71	| 11 | `docs/decisions/v1.0-kill-criterion.md` | RATIFIED | Incorporated remediation verified clean. |
    72	| 12 | `docs/runbooks/operational-hygiene-protocol.md` | RATIFIED | Incorporated remediation verified clean; D5 softening applied. |
    73	| 13 | `docs/verticals/recruitment/vertical-schema.yaml` | RATIFIED | Incorporated remediation verified clean. |
    74	| 14 | `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
    75	| 15 | `docs/architecture/tenancy-invariants.md` | RATIFIED | First ratification on Round 2; RATIFIED. |
    76	| 16 | `docs/architecture/architecture-cohesion-review.md` | RATIFIED | First ratification on Round 2; RATIFIED. |
    77	| 17 | `docs/runbooks/tenant-lifecycle.md` | RATIFIED | First ratification on Round 2; RATIFIED. |
    78	| 18 | `scripts/run-tenancy-audit.sh` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
    79	| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | RATIFIED | First ratification on Round 2; recursive disagreement RATIFIED. |
    80	| 20 | `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | REJECTED | First ratification on Round 2; recursive disagreement REJECTED. Open: see SUMMARY.md §3-§4. |
    81	| 21 | `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` | RATIFIED | First ratification on Round 2; RATIFIED with D1/D2/D3 advisory. |
    82	| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
    83	| 23 | `docs/runbooks/pii-purge-operational-pattern.md` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
    84	| 24 | `scripts/ifos-pii-purge.sh` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
    85	| 25 | `docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
    86	| 26 | `docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql` | RATIFIED | First ratification on Round 2; RATIFIED; paired forward migration remains rejected. |
    87	
    88	## §1.8 — Codex Round 3 remediation verdicts (2026-05-22)
    89	
    90	Round 3 remediated the Round-2 rejection set. Mechanical fixes were incorporated in this remediation commit; founder-domain items were annotated and escalated without Codex making D1/D2/D3 decisions. Result for the corrected subset: **10 RATIFIED / 0 REJECTED of 10**. Full report: `logs/codex-ratification/round-3-remediation/SUMMARY.md`.
    91	
    92	| # | Artefact | Round-3 verdict | Round-3 disposition |
    93	|---|---|---|---|
    94	| 1 | `docs/decisions/bullhorn-integration-path.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
    95	| 2 | `docs/decisions/autosend-safety-policy.md` | FOUNDER-ESCALATED | Founder-escalated pending D1 / D2 / D3; annotations added only. |
    96	| 3 | `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml` | FOUNDER-ESCALATED | Founder-escalated pending D3; `consrc` companion-migration issue fixed separately. |
    97	| 4 | `scripts/run-tenancy-audit.sh` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
    98	| 5 | `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
    99	| 6 | `docs/decisions/autosend-approval-bridge-spec.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
   100	| 7 | `docs/runbooks/pii-purge-operational-pattern.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
   101	| 8 | `scripts/ifos-pii-purge.sh` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
   102	| 9 | `docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
   103	| 10 | `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
   104	| 11 | `docs/architecture/tenancy-invariants.md` | RATIFIED | Auxiliary update incorporated in this commit; Round-3 RATIFIED. |
   105	| 12 | `agents/_shared/hook-helpers.sh` + `agents/_shared/voice-loader.sh` + `scripts/run-codex-ratification.sh` | RATIFIED | Cross-cutting Risk #11 remediation incorporated in this commit; Round-3 RATIFIED. |
   106	
   107	---
   108	
   109	## §1.10 — Codex Round 4 queue (Week 3 Diagnostic + 5 agent.md scaffolds)
   110	
   111	Round 4 scheduled across Week 3 (Days 14-20) per `docs/operations/goal-week-3-polish-and-scaffold.md` Steps 7 (Diagnostic-only, Day 15) + 13 (full run, Day 20). Per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 remediation max).
   112	
   113	Two phases:
   114	
   115	**Phase 1 (Day 15) — Diagnostic-only mid-week ratification.** Reason: substrate must be verified before 5 new scaffolds reference it. 6 items, all `review-architecture-decision.md` skill except the package-as-a-whole.
   116	
   117	| # | Artefact | Status | Codex skill | Reason for re-ratify |
   118	|---|---|---|---|---|
   119	| 1 | `agents/recruitment/diagnostic/agent.md` | Proposed → Accepted (post-W3 polish) | `review-architecture-decision.md` | Was Round-3 RATIFIED at scaffold form; re-ratify after Day-13 + Step-3 fixes (firm-slug, suffix-strip) + Step-4 LLM §12 wiring |
   120	| 2 | `agents/recruitment/diagnostic/tools.yaml` | Proposed | `review-architecture-decision.md` | First ratification (Day-12 scaffold) |
   121	| 3 | `agents/recruitment/diagnostic/cycle.sh` | Proposed | `review-architecture-decision.md` | Post-Day-13 generator wiring (commit `fd38254`) |
   122	| 4 | `agents/recruitment/diagnostic/validate.sh` | Proposed | `review-architecture-decision.md` | Post-Day-13 V2 awk-pass fix (commit `97a57a2`) |
   123	| 5 | `packages/diagnostic-generator/` (package as a whole) | Proposed | `review-architecture-decision.md` | Day-13 ship; first ratification |
   124	| 6 | `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` | Accepted | `review-architecture-decision.md` | Day-13 sequencing decision; first ratification |
   125	
   126	**Phase 2 (Day 20) — Full Round 4: 5 new agent.md scaffolds.** Each authored Days 16-19 per goal-week-3 Steps 8-12. All `review-architecture-decision.md` skill.
   127	
   128	| # | Artefact | Status | Codex skill | Master plan citation |
   129	|---|---|---|---|---|
   130	| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
   131	| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
   132	| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
   133	| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
   134	| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
   135	
   136	**Total Round 4 items: 11** (6 Phase 1 + 5 Phase 2). Queue grown 43 → 54 with the Day-9 + Day-11 additions counted.
   137	
   138	**Day-19 update:** Initial Round-4 Phase-1 attempt used `review-architecture-decision.md` skill (the only available skill at the time). That returned REJECTED with a load-bearing finding (Issue 5 in `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`) — agent.md files require a different skill structure. **`review-agent-bundle.md` skill built in commit `825ebd4`.** Re-ratification of all 6 agent.md items with the new skill.
   139	
   140	**Round-4-v2 verdicts (post-skill-build, Day-19 13:25 UTC):**
   141	
   142	| # | Artefact | Verdict | Issues | Session log |
   143	|---|---|---|---|---|
   144	| 1 | `agents/recruitment/diagnostic/agent.md` | **REJECTED** | 5 real findings (Gate A strength + Step 11 decision-log + Trigger 8 mismap + sentinel + validate.sh gap) | `20260524T101934Z-19923` |
   145	| 2 | `agents/recruitment/janitor/agent.md` | **REJECTED** | ~5-7 real findings (count regex 56 inflated by nested lists) | `20260524T102050Z-21293` |
   146	| 3 | `agents/recruitment/scribe/agent.md` | **REJECTED** | ~5-7 real findings (count regex 59) | `20260524T102202Z-22338` |
   147	| 4 | `agents/recruitment/cash-conductor/agent.md` | **REJECTED** | ~5-7 real findings (count regex 58) | session log in tree |
   148	| 5 | `agents/recruitment/sourcing-scout/agent.md` | **REJECTED** | ~5-7 real findings (count regex 50) | session log in tree |
   149	| 6 | `agents/recruitment/concierge/agent.md` | **REJECTED** | ~5-7 real findings (count regex 59) | session log in tree |
   150	
   151	**Total: 0 RATIFIED / 6 REJECTED of 6** — all agent.md files require founder arbitration on the systemic 5-category disposition framework documented in the codex-disagreement doc Round-4-v2 update section.
   152	
   153	**Hard ceiling reached** per master brief §10.3 step 5. Single founder decision (approve the 5-category disposition) unlocks all 6 ratifications via a single Round-5 mechanical-remediation pass.
   154	
   155	Remaining Phase-1 items (tools.yaml + cycle.sh + validate.sh + package + ADR-005) NOT yet attempted because they would have inherited the same skill-mismatch issue. ADR-005 should ratify cleanly under `review-architecture-decision.md` (it IS a decision doc); .sh + .yaml files may need their own skills built (defer).
   156	
   157	**Round-4 disagreement protocol** (per master brief §10 + Day-8 pattern):
   158	- Codex challenges a master-plan-cited decision → write `docs/decisions/codex-disagreement-YYYY-MM-DD-<topic>.md` per Day-8 pattern; founder arbitrates at next Sunday review
   159	- Codex flags a citation drift → mechanical fix; re-submit; counts as Round 5 remediation
   160	- Codex requires a founder decision (D-class) → annotate; defer to founder; do NOT auto-remediate
   161	
   162	---
   163	
   164	## §1.5 — Codex Round 1 verdicts (2026-05-20)
   165	
   166	First ratification run completed Day 8. Cluster A+B+C reviewed (16 artefacts). Per-artefact verdict + Round-1 disposition:
   167	
   168	| # | Artefact | Round-1 verdict | Round-1 disposition |
   169	|---|---|---|---|
   170	| 1 | cortexos-primitive-status.md | REJECTED (2 issues) | Issue 1 (missing Status field) **incorporated** at commit `2b287d3`. Issue 2 (missing Decision/Consequences) **counter-argued** in `codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md`; resolution pending Founder Decision D5. |
   171	| 2 | ADR-001 | REJECTED (2 issues) | Issue 1 (Decision-subheading format) advisory only; Issue 2 (status drift "review pending") **incorporated** at `2b287d3`. |
   172	| 3 | ADR-002 | REJECTED (2 issues) | Issue 1 (status drift) + Issue 2 (master-brief-edit disposition) both **incorporated** at `2b287d3` — disposition now cites commit `0e5b2b4`. |
   173	| 4 | second-brain-design.md | REJECTED (2 issues) | Issue 1 (status enum) + Issue 2 (ESC catalogue cite) both **incorporated** at `2b287d3`. |
   174	| 5 | agent-bundle-renderer-design.md | REJECTED (3 issues) | Issue 1 (status enum) + Issue 2 (phase='render' drift) + Issue 3 (CLI name drift) all **incorporated** at `2b287d3`. |
   175	| 6 | ADR-003 | REJECTED (2 issues) | Issue 1 (status drift) + Issue 2 (CLI surface drift) both **incorporated** at `2b287d3` with inline ADR-004 erratum reference. |
   176	| 7 | bullhorn-integration-path.md | REJECTED (3 issues) | Issue 1 (status enum) + Issue 3 (rate-limit speculation note) **incorporated** at `2b287d3`. Issue 2 (Week-1 gate) **counter-argued** in `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`; line 95 wording sharpened. |
   177	| 8 | sequencing-target.md | REJECTED (2 issues) | Issue 1 (status drift) **incorporated** at `2b287d3`. Issue 2 (phase enum cite) implicitly addressed via ADR-004 Decision 7 cross-reference. |
   178	| 9 | brain-ui-scope.md | **RATIFIED** | Advisory only (v1.1 revisit estimate may need refresh if launch calendar moves). |
   179	| 10 | vault-concurrency.md | REJECTED (2 issues) | Issue 1 (migration cite for `entities.version`) advisory; Issue 2 (ESC wiring) **incorporated** at `2b287d3` with cross-references to commits `a279226` + `e6e9df1`. |
   180	| 11 | day-4-provisioning.md | not in Round 1 (Cluster D) | Cluster D ratification deferred per execution plan §9 Option γ. |
   181	| 12 | Day-4 close commit `98c79b2` | not in Round 1 | Same — Cluster D. |
   182	| 13 | Atomic-correction commit `0e5b2b4` | not in Round 1 | Same — Cluster F. |
   183	| 14 | Day-4 Postgres artefact | not in Round 1 | Same. |
   184	| 15 | placeholder | — | — |
   185	| 16 | autosend-safety-policy.md | REJECTED (3 issues) | Issues 1+2 (tier contradiction) → **Founder Decision D1** in `2026-05-20-codex-round-1-founder-decisions.md`. Issue 3 (legal placeholder) → **Founder Decision D2 + D3** in same briefing. No inline incorporation; founder picks. |
   186	| 17 | v1.0-kill-criterion.md | REJECTED (3 issues) | All three (Trigger 1 date / Trigger 2 CLI / Trigger 4 threshold) **incorporated** at `2b287d3`. |
   187	| 18 | vertical-schema.yaml v0.1 | REJECTED (3 issues) | Issue 1 (voice_classifier_score CHECK) **incorporated** with v0.2 trigger reference. Issue 2 (empty access arrays) **incorporated**. Issue 3 (versioning count) **incorporated**. Plus pre-existing YAML parse errors fixed. |
   188	| 19 | operational-hygiene-protocol.md | REJECTED (2 issues) | Issue 1 (missing Decision/Consequences) **counter-argued** in disagreement doc; resolution pending Founder Decision D5. Issue 2 (Path B contradiction) **incorporated** at `2b287d3` — Path B language tightened. |
   189	| 20 | This manifest | not in Round 1 | Recursive ratification deferred per execution plan §10 step 6. |
   190	| 21 | Day-7 single-sentence test | not in Round 1 | Cluster G. |
   191	
   192	**Plus Round-1 ADR-004** (item not in original 21-queue but added Day 8): **RATIFIED**.
   193	
   194	**Round-1 totals:** 16 reviewed | **2 RATIFIED** (ADR-004 + brain-ui-scope) | **14 REJECTED** | **13 of 14 incorporated** at commit `2b287d3` | **2 disagreement docs filed** | **5 founder decisions surfaced** (D1-D5).
   195	
   196	**Round-2 expected:** re-run Cluster A+B+C after `2b287d3` lands. Expected 14 → 0-2 REJECTED (0-2 being the disagreement-resolution artefacts pending founder D5 verdict).
   197	
   198	**New artefacts added to queue post-Round-1** (will be ratified in Round 2 or later):
   199	- `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md`
   200	- `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`
   201	- `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md`
   202	
   203	---
   204	
   205	## §2 — Ratification protocol per master brief §10.3
   206	
   207	Verbatim from master brief §10.3 (post-Edit 7 path correction):
   208	
   209	> 1. **Claude Code** produces the artefact on a feature branch
   210	> 2. **You** run: `codex review --skill .codex/ratification/review-{type}.md --target {path-or-diff}`
   211	> 3. **Codex** returns RATIFIED or REJECTED with concrete issues
   212	> 4. **Claude Code** reads Codex's feedback; incorporates it or counter-argues explicitly in `docs/decisions/codex-disagreement-{date}.md` (the disagreement IS the signal — write it down, don't dissolve it)
   213	> 5. After ≤ 2 round-trips, merge. Still disagreeing? Escalate to founder to decide.
   214	
   215	For Day-7 first ratification run, steps 1-2 require `.codex/ratification/*.md` skills to exist. They don't yet (see §3).
   216	
   217	---
   218	
   219	## §3 — Gap: `.codex/ratification/` skills not yet built
   220	
   221	Master brief §10.2 (Day 0-1 task) specifies 7 skill files under `.codex/ratification/`:
   222	
   223	| File | Purpose |
   224	|---|---|
   225	| `SKILL.md` | Top-level "what does ratify mean" — checks against the five rules + the four boundaries |
   226	| `review-agent-bundle.md` | Specific checklist for the 6 files + 3 fixtures of a new agent |
   227	| `review-mcp-connector.md` | Specific checklist for a new MCP connector |
   228	| `review-schema-change.md` | Specific checklist for `vertical-schema.yaml` edits |
   229	| `review-postgres-migration.md` | Specific checklist for new tables, RLS policy changes |
   230	| `review-architecture-decision.md` | Specific checklist for ADRs in `docs/decisions/` |
   231	| `review-harness-bump.md` | Specific checklist when bumping the pinned cortextos SHA |
   232	
   233	**Current state:** `.codex/ratification/` directory does not exist. Day 0-1 task was never executed during Days 0-6 (focus was on master brief §6 Day 0-6 critical path; `.codex/ratification/` slipped per master brief §10.6 framing "Claude does this; we don't ratify the ratification skills until Day 7" but skills themselves needed to be built first).
   234	
   235	**Codex CLI itself is installed** at `/opt/homebrew/bin/codex`. The gap is the IFOS-specific ratification skills, not the Codex tool.
   236	
   237	---
   238	
   239	## §4 — Schedule
   240	

exec
/bin/zsh -lc 'rg -n "voice classifier|PII outside|no PII|Gate A: 12 sections|sourced data link|unsupported by source data" docs/specs/ULTRAPLAN.md' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md | sed -n '240,435p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
182:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
187:- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
350:- **PII boundary check** — does the draft reference any PII outside the firm boundary (e.g., another tenant's candidate's name)? Hard fail. Cost: <100ms.
362:3. Eval the adapter against held-out drafts using the voice classifier — promote only if the adapter beats the RAG baseline by ≥5 percentage points on the voice score *and* doesn't regress on compliance or factual checks.
373:2. Run the voice classifier on each.
388:3. Show the voice classifier score live on the screen: "0.84. Here's the draft."
496:- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
566:- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)

 succeeded in 0ms:
   240	
   241	---
   242	
   243	## Bilateral session execution — Round 8 close (2026-05-24, post-founder-authorization)
   244	
   245	After founder Path-A authorization (`/loop` bilateral; founder accepted all 7 recommended dispositions in two AskUserQuestion rounds):
   246	
   247	### Phase 1 — Catalogue extensions (commit `151d4fe`)
   248	
   249	- escalation-codes.md: 24 → 52 active codes (26 added across §2.7-§2.10)
   250	- autosend-policy.yaml: 29 → 41 action_types (8 status markers + 1 Cash Conductor reconciliation + 1 Concierge email draft + 2 added during Phase 2)
   251	- §2.5 header count corrected (stale 8 → actual 10 after earlier INPUT_VALIDATION_FAIL + AGENT_OUTPUT_SHAPE adds)
   252	
   253	### Phase 2 — Agent.md remediation (commit `1ff1569`)
   254	
   255	All 6 v1.0 agent.md files coordinated single-pass remediation:
   256	- Cat-1 (Gate A hybrid): Diagnostic §1 verified already correct
   257	- Cat-2 (decision-log calls): added hh_decision_output / hh_decision_action calls across all §4 sections; pre-registered action_types via Phase 1
   258	- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
   259	- Cat-4 (sentinel hygiene): Diagnostic `_consultant_feedback` → agent_name='diagnostic' + payload.action_type
   260	- Cat-5 (§5 honesty): 5 pre-build scaffolds gained explicit "validate.sh does NOT exist yet — W-X build slice delivers this contract" framing; Diagnostic gained warn-only-paths honesty note
   261	- Cross-section consistency: removed (new — W-X catalogue add) annotations; ESC_AUTOSEND_BLOCKED kept red-tier-only; ESC_SCHEMA_VIOLATION kept schema-field-violation-only; ESC_VOICE_DRIFT_TENANT removed from direct firing across all agents; ESC_AUTOSEND_YELLOW_SPOT_CHECK → ESC_AUTOSEND_SAMPLED_SPOT_CHECK
   262	- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
   263	- ULTRAPLAN line-number corrections: Cash Conductor A4 538/539/540/541 (not 539/540/541/542)
   264	- §1 vault path additions: Scribe + Concierge
   265	
   266	### Phase 3 — Round 8 Codex ratification
   267	
   268	Ran all 6 against `review-agent-bundle.md`. **All 6 returned REJECTED**, with the following actual top-level finding counts (the script's regex inflates because of nested sub-bullets):
   269	
   270	| Agent | Round 8 findings | Sessions |
   271	|---|---|---|
   272	| Diagnostic | 5 | `20260524T112636Z-79455` |
   273	| Janitor | 6 | `20260524T112807Z-81339` |
   274	| Scribe | 5 | `20260524T112917Z-82352` |
   275	| Cash Conductor | 5 | `20260524T113038Z-83732` |
   276	| Sourcing Scout | 4 | `20260524T113139Z-84869` |
   277	| Concierge | 7 | `20260524T113247Z-86019` |
   278	
   279	**Round 8 finding categorization** (32 total findings):
   280	
   281	#### Category α — Mechanical (fixed inline; commit appended to Phase 2)
   282	
   283	- Concierge AgentMail adapter-boundary violation (master brief §3 red line) — replaced all 5 references with "agent-identity email adapter (deferred)"
   284	- Sourcing Scout ULTRAPLAN A5 line refs: Gate A 553→552, Gate B 554→553 (4 citation sites)
   285	- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
   286	
   287	#### Category β — Schema-supplement-needed (v0.3 supplement is a founder-action gate before W4-W13 builds)
   288	
   289	- Janitor: `candidate.linkedin_url` not in schema
   290	- Scribe: ~12 new entity fields (current_role_title, employment_type, key_skills, preferred_channel, next_action_target_date, must_haves, nice_to_haves, deal_breakers, placement_status, week_1_status_note, satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band, decision_window_text); Scribe access matrix expansion to Contact / Brief / Opportunity write paths
   291	- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
   292	- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
   293	- All five are blocked on v0.3 supplement landing (founder review at first-pilot-onboarding) — DOCUMENTED IN W4 BACKLOG
   294	
   295	#### Category γ — Catalogue widening (semantic conflicts between ESC code definitions I authored and agent usage)
   296	
   297	- `ESC_ADDRESSEE_MISMATCH` — Concierge uses for candidate email mismatch; catalogue defines for Cash Conductor invoice mismatch. Resolution: widen catalogue definition to cover both use cases (candidate vs invoice addressee resolution).
   298	- `ESC_CONCIERGE_SLA_MISS` — agent uses for draft >30 min; catalogue defines for inbound brief/customer reply SLAs. Resolution: widen to include draft-generation SLA.
   299	- `ESC_LIFECYCLE_STATE_UNKNOWN` — Concierge uses for taxonomy misses; catalogue defines for Janitor placement ambiguity. Resolution: widen.
   300	- `ESC_OPEN_BANKING_TOKEN_AGING` — Cash Conductor uses <30 days warn / <7 days blocking staged; catalogue defines ≤14 days info. Resolution: align catalogue to Cash Conductor's actual staged definition.
   301	- `ESC_AUTOSEND_RACE` — Cash Conductor uses for payment-received-during-chase race; catalogue defines for two-agents-same-payload_hash race. Resolution: widen to cover both.
   302	- DOCUMENTED IN W4 BACKLOG (catalogue v2 amendments)
   303	
   304	#### Category δ — Implementation gaps (validate.sh / cycle.sh)
   305	
   306	- Diagnostic validate.sh: emits `ESC_SCHEMA_VIOLATION` not the specific codes declared in §6; doesn't write skip rows when honesty-flagging
   307	- Diagnostic cycle.sh: sends Telegram directly via curl with no `hh_decision_action` row
   308	- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
   309	- All five build-slice items (W4-W13) DOCUMENTED IN BUILD-SLICE BACKLOG
   310	
   311	#### Category ε — Hh_decision_* still missing at some steps
   312	
   313	- Despite Phase-2 adding ~20 calls, additional steps missing:
   314	  - Diagnostic Step 11 cycle.sh-vs-agent.md mismatch (above)
   315	  - Janitor Step 1 auth refresh emits ESC without decision row
   316	  - Scribe Steps 2-3, 7 partial coverage
   317	  - Cash Conductor Steps 7-8, 11
   318	  - Sourcing Scout per-candidate decision rows (claimed in §3 but not in §4 cycle)
   319	  - Concierge Steps 7, 11
   320	- DOCUMENTED IN W4 BACKLOG (cycle.sh build slices deliver these calls per agent §4 specs)
   321	
   322	### Week-3 close status (honest signal per Rule 5)
   323	
   324	**Cumulative empirical:** 9 Codex rounds total (Round 4-v1, 4-v2, 5, 6, 7 on Diagnostic/Janitor + Round 8 across all 6). **55+ unique findings catalogued across rounds, ~10-12 fixed via Cat-α mechanical disposition in this bilateral session; rest queued.**
   325	
   326	**Phase 1 + Phase 2 + Phase 3 (Round 8 + Cat-α inline fixes) constitute the documented "Path A — bilateral session per master brief protocol" outcome.** No further autonomous remediation rounds will be attempted per the master brief §10.3 step 5 hard ceiling and founder's "no more rounds" authorization.
   327	
   328	**Status of 6 agent.md scaffolds:**
   329	- Diagnostic: pre-build-with-honesty-notes; Round-8-reviewed; ~3 implementation-gap findings (Cat-δ) queued for W3-4 polish slice
   330	- Janitor: pre-build-scaffold; Round-8-reviewed; ~3 schema-supplement findings (Cat-β) + ~2 catalogue-widening (Cat-γ) queued
   331	- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
   332	- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
   333	- Sourcing Scout: pre-build-scaffold; Round-8-reviewed; minimal residual (catalogue-widening + per-candidate decision rows)
   334	- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
   335	
   336	**Backlog landing items (queue Codex Round 9 ONLY after these land):**
   337	1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
   338	2. ESC catalogue v2 amendments (widen 5 codes per Cat-γ list above)
   339	3. Per-agent validate.sh + cycle.sh + tools.yaml + cleanup.sh build slices (W3-W13)
   340	4. Re-ratify per agent.md at end of its build wave; not in Week-3 close
   341	
   342	**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
   343	
   344	*End of Phase 1+2+3 narrative.*
   345	
   346	---
   347	
   348	## Phase 4 — Cat-γ widening + Cat-δ Diagnostic polish + Round 9 (2026-05-24, founder "proceed" instruction)
   349	
   350	After Round 8 + Cat-α inline fixes, founder authorized continued work via "confirm everything and prepare us for the codex ratify" then "proceed" instructions.
   351	
   352	### Cat-γ catalogue widening (commit `5e59f9c`)
   353	
   354	Broadened 5 ESC codes to cover multiple agent use cases:
   355	- `ESC_ADDRESSEE_MISMATCH` — now covers both Cash Conductor xero/bullhorn + Concierge candidate-email (mismatch_class field)
   356	- `ESC_CONCIERGE_SLA_MISS` — three sla_types: brief_ack / customer_reply / draft_generation
   357	- `ESC_LIFECYCLE_STATE_UNKNOWN` — both Janitor placement + Concierge taxonomy out-of-bounds
   358	- `ESC_OPEN_BANKING_TOKEN_AGING` — three staged behaviors aligned to Cash Conductor §6
   359	- `ESC_AUTOSEND_RACE` — duplicate-payload + state-change race classes
   360	
   361	### Cat-δ Diagnostic polish (commit `cbef6b5`)
   362	
   363	- `validate.sh` emits specific §6 ESC codes (ESC_PII_LEAKAGE_RISK or ESC_AGENT_OUTPUT_SHAPE) not generic ESC_SCHEMA_VIOLATION
   364	- `cycle.sh` adds `hh_decision_action("operator_notify_telegram", ...)` call before Step 14 Telegram send
   365	
   366	### Round 9 verdict — 30 findings (down from Round 8's 32; net −2)
   367	
   368	| Agent | R8 | R9 | Δ |
   369	|---|---|---|---|
   370	| Diagnostic | 5 | 5 | 0 (different findings; 2 Cat-δ closed, 2 new internal-consistency surfaced) |
   371	| Janitor | 6 | 6 | 0 (different findings; 1 Cat-γ closed, 1 new) |
   372	| Scribe | 5 | 4 | −1 |
   373	| Cash Conductor | 5 | 5 | 0 (different findings; 1 Cat-γ closed, 1 new) |
   374	| Sourcing Scout | 4 | 5 | +1 (Q7 enum claim missed by my Round-8 fix; Bullhorn webhook conflict newly surfaced) |
   375	| Concierge | 7 | 5 | −2 (AgentMail boundary + ESC widening) |
   376	| **Total** | **32** | **30** | **−2** |
   377	
   378	**Cumulative empirical (10 rounds total):** ~75 unique findings catalogued; ~7 closed via Cat-α + Cat-γ + Cat-δ inline this session; convergence rate ~10% per round. The pattern documented in master brief §10.3 step 5 holds.
   379	
   380	### Round 9 finding samples (illustrative, not exhaustive)
   381	
   382	**Diagnostic R9:**
   383	1. Gate A per-claim vs per-section: STILL flagged despite Cat-1 hybrid disposition; this is a Codex–founder disagreement, not relitigation of Cat-1 (founder's hybrid stance documented but Codex doesn't accept the bilateral-disposition framing as an in-band acceptance of weakening). **Disposition: founder-decision; flagged as Cat-ζ "Cat-1 framing not auto-accepted by Codex".**
   384	2. §1/§3 vs §5 internal inconsistency on Gate A hard-fail vs warn+skip — Cat-α (Diagnostic's hybrid framing introduced §1/§5 contradictions that need explicit reconciliation)
   385	3. §8 build-dependency table says validate.sh "Not built" but file exists — Cat-α; 30s fix
   386	4. §6 includes ESC_RENDERER_FAILED in "Diagnostic uses" table — Cat-α; remove
   387	5. §6 says only one action_type but cycle.sh now has operator_notify_telegram (Round-9 introduced by Cat-δ commit) — Cat-α; align §6
   388	
   389	**Sourcing Scout R9:**
   390	1. Step 9 per-candidate decision_log row missing — Cat-ε
   391	2. ESC auth severity downgrade vs catalogue — Codex–founder disagreement (Sourcing Scout intentionally allows single-source auth failure as warn-only when 2+ sources remain; catalogue defines blocking. Real semantic divergence; needs catalogue widening OR Sourcing Scout agent.md realignment)
   392	3. ESC_DNC_FILTER_HIT used for shortlist filtering (pre-outbound), catalogue defines for outbound refusal — Cat-γ widening needed (similar to other 5 widened)
   393	4. Bullhorn webhook v1.0 trigger conflicts with bullhorn-integration-path.md (webhooks v1.1+ only) — Cat-β-adjacent; agent.md should remove v1.0 webhook trigger
   394	5. Q7 passive-status enum claim (line 333) — Cat-α; my Round-8 fix updated Step 3 prose but missed Q7
   395	
   396	### Cat-ζ — new category surfaced by Round 9
   397	
   398	**Cat-ζ — Codex does not accept bilateral-disposition framings as in-band Gate A acceptances.**
   399	
   400	When founder authorizes a Cat-1 hybrid disposition (per-section v0 + per-claim W4), the agent.md prose explicitly documents this. Codex re-flags it as "Gate A weakens upstream requirement" regardless. This is structural — Codex reviews agent.md against ULTRAPLAN/master brief, and bilateral disposition documents at `docs/decisions/codex-disagreement-*.md` are downstream artefacts Codex doesn't auto-trust.
   401	
   402	**Disposition options:**
   403	- **A) Amend ULTRAPLAN §8.1 A1 line 497** — change "no claims unsupported by source data" to "no claims unsupported at section level" to match v0 reality. Aggressive; rewrites upstream spec.
   404	- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
   405	- **C) Document as permanent Cat-ζ disagreement** — accept that Codex will continue flagging this; rely on the disagreement doc as the founder-authority record.
   406	
   407	**Recommended: B (ADR-006).** Closes the disagreement properly; gives Cat-1 a ratified architectural home; future-proofs against Cat-1 re-litigation. ~1 hour Claude work + 1 Codex round to ratify the ADR.
   408	
   409	### Decision — stop Codex looping per master brief §10.3 step 5
   410	
   411	The pattern (Round 4 → Round 9; 10 rounds; 75+ unique findings; ~10% net convergence per round) empirically confirms master brief §10.3 step 5. Each remediation pass surfaces new issues at roughly the same rate it closes old ones — because the document keeps changing.
   412	
   413	**Stopping condition met:** founder's "proceed" → Cat-γ widening + Cat-δ Diagnostic polish + Round 9 + this categorization is the conclusive "RATIFY-or-document-disagreement" outcome per the bilateral disposition. No further autonomous remediation will be attempted.
   414	
   415	**Next structural unblocks (founder-action queue):**
   416	1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
   417	2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
   418	3. **Per-agent build-slice delivery** (W5-W13) — closes Cat-δ + Cat-ε per agent at its build wave
   419	4. **Catalogue v2 widening for ESC_DNC_FILTER_HIT + Sourcing Scout auth severity** — Cat-γ continuations
   420	5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
   421	
   422	**Per-agent state at Phase 4 close:**
   423	
   424	| Agent | Status | Round 9 findings | Path to RATIFIED |
   425	|---|---|---|---|
   426	| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
   427	| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
   428	| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
   429	| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
   430	| Sourcing Scout | Pre-Build-Round-9-Reviewed | 5 (Cat-α Q7 + bullhorn-path conflict + Cat-γ DNC + Cat-ε per-candidate row + auth severity disagreement) | Mechanical Q7 fix + Bullhorn-path realignment + ESC widening 2 |
   431	| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
   432	
   433	*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*

exec
/bin/zsh -lc "rg -n \"diagnostic_per_claim_sample_rate|per_claim_confidence_distribution|per_claim\" docs/verticals/recruitment docs/decisions agents/_shared agents/recruitment -g '"'!docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md'"'" in /Users/madsadmin/code/CortexOS
 exited 1 in 0ms:
codex
REJECTED

1. ULTRAPLAN citation is inaccurate. Lines 5, 13, and 60 cite `docs/specs/ULTRAPLAN.md` §8.1 A1 line 497 as the Gate A requirement and quote text including `voice classifier score ≥ 0.75; no PII outside firm boundary`; live ULTRAPLAN line 496 is the Gate A line and it does not contain those clauses, while line 497 is Gate B. Fix the line reference and quote the live text exactly before proposing any amended reading.

2. Downstream-reference claims are false in the current tree. Lines 113-116 claim `agents/recruitment/diagnostic/agent.md` §1/§5 explicitly cite ADR-006 and that the ratification manifest adds this ADR; live `agent.md` lines 16 and 156-165 contain no ADR-006 reference, and the manifest has no ADR-006 queue entry. Fix by changing these to explicit future tasks or landing the referenced edits in the same/next atomic commit.

3. New structured fields are introduced without schema/policy support. Lines 48 and 108 add `decision_log.payload.per_claim_confidence_distribution`, but autosend-safety-policy §7 only documents the existing payload shape and does not include that key; line 107 adds `tenant_adapters.config.diagnostic_per_claim_sample_rate`, which is not defined in the vertical schema/supplement. Add the fields to the appropriate schema/policy artefact or mark them as blocked future schema work.

4. ADR-specific decision structure is missing. The file is `ADR-006...`, but its Decision section at lines 33-54 has no explicit `Decision 1 — <terse summary>` subheading as required for ADRs. Add a numbered decision subheading under `## Decision`.
tokens used
105,408
REJECTED

1. ULTRAPLAN citation is inaccurate. Lines 5, 13, and 60 cite `docs/specs/ULTRAPLAN.md` §8.1 A1 line 497 as the Gate A requirement and quote text including `voice classifier score ≥ 0.75; no PII outside firm boundary`; live ULTRAPLAN line 496 is the Gate A line and it does not contain those clauses, while line 497 is Gate B. Fix the line reference and quote the live text exactly before proposing any amended reading.

2. Downstream-reference claims are false in the current tree. Lines 113-116 claim `agents/recruitment/diagnostic/agent.md` §1/§5 explicitly cite ADR-006 and that the ratification manifest adds this ADR; live `agent.md` lines 16 and 156-165 contain no ADR-006 reference, and the manifest has no ADR-006 queue entry. Fix by changing these to explicit future tasks or landing the referenced edits in the same/next atomic commit.

3. New structured fields are introduced without schema/policy support. Lines 48 and 108 add `decision_log.payload.per_claim_confidence_distribution`, but autosend-safety-policy §7 only documents the existing payload shape and does not include that key; line 107 adds `tenant_adapters.config.diagnostic_per_claim_sample_rate`, which is not defined in the vertical schema/supplement. Add the fields to the appropriate schema/policy artefact or mark them as blocked future schema work.

4. ADR-specific decision structure is missing. The file is `ADR-006...`, but its Decision section at lines 33-54 has no explicit `Decision 1 — <terse summary>` subheading as required for ADRs. Add a numbered decision subheading under `## Decision`.
