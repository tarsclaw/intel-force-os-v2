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
session id: 019e59e9-bbee-7fa0-b0cb-74caa8956557
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
**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR

---

## Context

ULTRAPLAN §8.1 A1 line 496 specifies the Diagnostic Gate A citation requirement verbatim:

> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data

The "no claims unsupported by source data" clause implies **per-claim citation validation** — every factual claim in the report must have a backing source link. The Diagnostic v0 implementation at `agents/recruitment/diagnostic/validate.sh` enforces **per-section citation** (regex `\[.+\]\(.+\)` requires ≥1 markdown link per section); per-claim validation is NOT implemented at v0.

(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract — implemented separately in `validate.sh`; they're not affected by this ADR. This ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)

This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:

1. NLP claim-extraction from the rendered Markdown report (sentence-level fact identification)
2. Per-claim evidence-link matching (semantic similarity between claim and cited URL content)
3. Confidence threshold tuning to avoid false rejections of well-cited paraphrases

This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.

Bilateral founder+Claude session on 2026-05-24 (Day 19) selected option **(b) — hybrid framing** as the disposition (Cat-1 in the disagreement doc). Founder authorization via AskUserQuestion accepted: "Hybrid (Recommended): v0 = per-section, W4 = per-claim spot-check".

This ADR formalises that disposition as a ratified architectural decision so future Codex rounds + agent.md §5 framing treat it as upstream-canonical, not as a downstream weakening.

---

## Decision

### Decision 1 — Diagnostic Gate A citation validation is a two-tier policy (per-section v0 hard-fail + per-claim W4 spot-check warn)

### Tier 1 (v0; hard-fail) — per-section citation coverage

Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`.

### Tier 2 (W4 polish; warn-only sampling) — per-claim citation spot-check

A statistical sample (1-in-N, configurable per tenant; default 1-in-10) of Diagnostic reports undergo post-render per-claim citation validation:

- NLP claim-extraction (sentence-level)
- Per-claim evidence-link matching (semantic similarity against cited URLs)
- Per-claim confidence score
- Aggregate report quality metric written to `decision_log.payload.per_claim_confidence_distribution` (NEW payload key — W4-polish schema work; not present in the `decision_log.payload` shape documented at `docs/decisions/autosend-safety-policy.md` §7 audit row schema today, which lists `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `override_applied`, approval fields, `block_reason`, and `policy_version_sha` only; W4-polish lands a payload-schema supplement that adds this key before any write)

Below threshold (e.g. <80% of claims with confidence ≥0.6) → warn (not block); operator review queue entry.

The per-tenant sample-rate override (`tenant_adapters.config.diagnostic_per_claim_sample_rate`) is also a NEW config field — W4-polish-blocked: `tenant_adapters` schema does not include it today; v0.3 vertical-schema supplement work needs to add it before Tier 2 activates.

### W4 polish trigger

When the voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports, the per-claim spot-check pipeline activates. Until then, Tier 2 is documented intent only.

---

## ULTRAPLAN amendment

`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):

> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data

After this ADR ratifies, the canonical interpretation is:

> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link (per-section, Tier 1, hard-fail at v0 — already implemented); "no claims unsupported by source data" is enforced via per-claim citation spot-check sampling (Tier 2, W4 polish, warn-only). See `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for the two-tier framing.

**In-band amendment (landed in commit `aed9d3b`):** `docs/specs/ULTRAPLAN.md` line 496 now reads verbatim:

> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish)*

This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.

---

## Why hybrid not full-spec

**Why not (a) defer launch until per-claim lands?**
- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
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
- `agents/recruitment/diagnostic/validate.sh` retains current per-section enforcement (no implementation change)

### Next commit (after this ADR ratifies)

- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
- `docs/decisions/2026-05-18-codex-ratification-manifest.md` queue updated to include this ADR. NOT yet updated as of this commit; lands in the post-ratify commit.

### After Codex ratifies this ADR (Status flips Proposed → Accepted)

- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the unchanged ULTRAPLAN line 497 prose alone)
- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (ADR-007 Janitor Gate A, ADR-008 Scribe Gate A, etc.) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed

### W4-polish slice (after voice-classifier microservice ships + first pilot tenant data accumulates)

- Per-claim spot-check pipeline lands as Tier 2 validate.sh extension
- Sample rate configurable per tenant in `tenant_adapters.config.diagnostic_per_claim_sample_rate`
- Aggregate metric writes to `decision_log.payload.per_claim_confidence_distribution`
- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)

### Downstream artefact references (queued for post-ratify commit)

- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
- `docs/decisions/2026-05-18-codex-ratification-manifest.md` → adds this ADR as ratification queue item

These edits all land in the next commit AFTER this ADR ratifies (no point updating agent.md to cite a Proposed ADR; cite once ratified).

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

exec
/bin/zsh -lc 'rg -n "Gate A:|Trigger 2|Status:|# ADR-006|ADR-005|ADR-00|decision_log.payload|tenant_adapters|per_claim|Composio|AgentMail" docs/specs/ULTRAPLAN.md docs/decisions/v1.0-kill-criterion.md docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md docs/decisions/autosend-safety-policy.md docs/verticals/recruitment/vertical-schema.yaml agents/recruitment/diagnostic/validate.sh agents/recruitment/diagnostic/agent.md docs/decisions/2026-05-18-codex-ratification-manifest.md docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/diagnostic/validate.sh:6:# Status: Proposed (pre-W3-build scaffold; Day-12 author).
agents/recruitment/diagnostic/validate.sh:227:  printf '\nValidate Gate A: \033[1;32mPASS\033[0m (warnings=%d)\n' "${#WARNINGS[@]}"
agents/recruitment/diagnostic/validate.sh:230:  printf '\nValidate Gate A: \033[1;31mFAIL\033[0m (%d failures, %d warnings)\n' \
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:1:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Proposed (2026-05-24, Day 19)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:15:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:27:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:50:- Aggregate report quality metric written to `decision_log.payload.per_claim_confidence_distribution` (NEW payload key — W4-polish schema work; not present in the `decision_log.payload` shape documented at `docs/decisions/autosend-safety-policy.md` §7 audit row schema today, which lists `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `override_applied`, approval fields, `block_reason`, and `policy_version_sha` only; W4-polish lands a payload-schema supplement that adds this key before any write)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:54:The per-tenant sample-rate override (`tenant_adapters.config.diagnostic_per_claim_sample_rate`) is also a NEW config field — W4-polish-blocked: `tenant_adapters` schema does not include it today; v0.3 vertical-schema supplement work needs to add it before Tier 2 activates.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:66:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:70:> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link (per-section, Tier 1, hard-fail at v0 — already implemented); "no claims unsupported by source data" is enforced via per-claim citation spot-check sampling (Tier 2, W4 polish, warn-only). See `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for the two-tier framing.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:74:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:76:This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:83:- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:103:- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:108:- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (ADR-007 Janitor Gate A, ADR-008 Scribe Gate A, etc.) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:119:- Sample rate configurable per tenant in `tenant_adapters.config.diagnostic_per_claim_sample_rate`
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:120:- Aggregate metric writes to `decision_log.payload.per_claim_confidence_distribution`
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:125:- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:126:- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:127:- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:150:- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:152:*End of ADR-006.*
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:426:      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:838:    status: DEFERRED to v1.1 / ADR-006
docs/decisions/2026-05-18-codex-ratification-manifest.md:5:**Status:** Reference
docs/decisions/2026-05-18-codex-ratification-manifest.md:17:| 2 | `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` | Accepted | Verify Option A reasoning + edits applied (chokidar → FastChecker landed in atomic-correction commit `0e5b2b4`) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:18:| 3 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | Accepted | Verify Option α reasoning + Edits 1+2+3 all applied (3, 4, 12 in atomic-correction manifest) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:19:| 4 | `docs/architecture/second-brain-design.md` | Reference (ADR-002 binding) | Cross-check against ADR-002 ratification |
docs/decisions/2026-05-18-codex-ratification-manifest.md:20:| 5 | `docs/architecture/agent-bundle-renderer-design.md` | Reference (ADR-003 binding) | Cross-check 22 spec gaps + 4 buckets against ADR-003 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:21:| 6 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | Accepted | Verify 4 decisions + Edits A+B+C applied (5 in atomic-correction; A+B landed Day 1 evening) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:51:**Cross-cutting reference:** these 4 artefacts ratify the layered defence model documented across Day-4 §7 (RLS isolation gate) + ADR-002 (parallel brain) + ADR-003 (renderer) + ADR-004 (deviations). They are downstream of, not redundant with, the existing 21+ queue items.
docs/decisions/2026-05-18-codex-ratification-manifest.md:61:| 1 | `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` | RATIFIED | Incorporated remediation verified clean. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:62:| 2 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | RATIFIED | Incorporated remediation verified clean. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:63:| 3 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | RATIFIED | Incorporated remediation verified clean. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:124:| 6 | `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` | Accepted | `review-architecture-decision.md` | Day-13 sequencing decision; first ratification |
docs/decisions/2026-05-18-codex-ratification-manifest.md:155:Remaining Phase-1 items (tools.yaml + cycle.sh + validate.sh + package + ADR-005) NOT yet attempted because they would have inherited the same skill-mismatch issue. ADR-005 should ratify cleanly under `review-architecture-decision.md` (it IS a decision doc); .sh + .yaml files may need their own skills built (defer).
docs/decisions/2026-05-18-codex-ratification-manifest.md:171:| 2 | ADR-001 | REJECTED (2 issues) | Issue 1 (Decision-subheading format) advisory only; Issue 2 (status drift "review pending") **incorporated** at `2b287d3`. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:172:| 3 | ADR-002 | REJECTED (2 issues) | Issue 1 (status drift) + Issue 2 (master-brief-edit disposition) both **incorporated** at `2b287d3` — disposition now cites commit `0e5b2b4`. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:175:| 6 | ADR-003 | REJECTED (2 issues) | Issue 1 (status drift) + Issue 2 (CLI surface drift) both **incorporated** at `2b287d3` with inline ADR-004 erratum reference. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:177:| 8 | sequencing-target.md | REJECTED (2 issues) | Issue 1 (status drift) **incorporated** at `2b287d3`. Issue 2 (phase enum cite) implicitly addressed via ADR-004 Decision 7 cross-reference. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:186:| 17 | v1.0-kill-criterion.md | REJECTED (3 issues) | All three (Trigger 1 date / Trigger 2 CLI / Trigger 4 threshold) **incorporated** at `2b287d3`. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:192:**Plus Round-1 ADR-004** (item not in original 21-queue but added Day 8): **RATIFIED**.
docs/decisions/2026-05-18-codex-ratification-manifest.md:194:**Round-1 totals:** 16 reviewed | **2 RATIFIED** (ADR-004 + brain-ui-scope) | **14 REJECTED** | **13 of 14 incorporated** at commit `2b287d3` | **2 disagreement docs filed** | **5 founder decisions surfaced** (D1-D5).
docs/decisions/2026-05-18-codex-ratification-manifest.md:264:| 1 | §2.4 row 3 chokidar → FastChecker (+ col 4 wiki-* reframe) | ADR-001 line 38 | ✓ verbatim |
docs/decisions/2026-05-18-codex-ratification-manifest.md:265:| 2 | Ultraplan §3.2 watcher → FastChecker + 3-5s reframe | ADR-001 §Consequences line 59 | ✓ verbatim |
docs/decisions/2026-05-18-codex-ratification-manifest.md:266:| 3 | §3.4 shadow → parallel (full rewrite) | ADR-002 Edit 1 line 81 | ✓ verbatim |
docs/decisions/2026-05-18-codex-ratification-manifest.md:267:| 4 | §5.5 v1.0 minimum row + v1.0+/v1.1 row merge | ADR-002 Edit 2 line 91 | ✓ verbatim (with side effect documented) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:268:| 5 | §8 renderer footnote (before §8.1) | ADR-003 Edit C | ✓ verbatim |
docs/decisions/2026-05-18-codex-ratification-manifest.md:275:| 12 | §6 Day 4 line 478 table list (entity_graph split) | ADR-002 Edit 3 | ✓ verbatim |
agents/recruitment/diagnostic/agent.md:3:**Status:** Proposed (Day-11 pre-W3-build draft; awaits Q1 LOI + Codex ratification at first render).
agents/recruitment/diagnostic/agent.md:83:   → Gate A: hard-fail if any check fails
agents/recruitment/diagnostic/agent.md:169:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `payload.action_type='consultant_feedback'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with a payload action_type marker rather than a new sentinel.
agents/recruitment/diagnostic/agent.md:237:**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + W3 build slice start.
agents/recruitment/diagnostic/agent.md:267:- First production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
docs/decisions/v1.0-kill-criterion.md:3:**Status:** Proposed — pending Codex Day-7 ratification
docs/decisions/v1.0-kill-criterion.md:61:### Trigger 2 — DIAGNOSTIC-NO-RENDER-W3 (KILL)
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:67:**Source:** `sequencing-target.md` §6.6 failure condition (i); Risk #5 in `docs/RISK-REGISTER.md`; ADR-003 §"Consequences" line 141 (renderer is load-bearing Week-1 deliverable).
docs/decisions/v1.0-kill-criterion.md:69:**Action:** KILL state. Rationale: the renderer architecture (ADR-003) was ratified in Week 0 Day 1 evening as the load-bearing Week-1 prerequisite. If Week 3 ends with no clean Diagnostic render, the renderer has fundamental gaps that the design did not anticipate. The renderer cannot be "patched"; v1.0 cannot ship without working render. Continuing into Weeks 4+ without resolution is sunk-cost reasoning.
docs/decisions/v1.0-kill-criterion.md:336:- The renderer architecture per ADR-003
docs/decisions/v1.0-kill-criterion.md:350:- Adds AgentMail integration (Inbound Triage only) per master brief §3.2
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:4:**Status:** Awaiting founder arbitration
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:77:**Codex says:** "The file has `Status: Proposed` at line 3, but no `Context`, `Decision`, or `Consequences` sections as required for Proposed artefacts by review-architecture-decision §1. Fix: either review this with `review-agent-bundle.md`, or add the required architecture-decision sections and a final status-update line."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:79:**Disposition:** **Codex is correct about the skill requirement**, but the artefact type is wrong. `agent.md` files are NOT architecture-decision documents — they're agent specifications per ADR-003 v2 bundle pattern (6 files + 3 fixtures). They don't fit the Context/Decision/Consequences shape.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:283:- Concierge AgentMail adapter-boundary violation (master brief §3 red line) — replaced all 5 references with "agent-identity email adapter (deferred)"
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:375:| Concierge | 7 | 5 | −2 (AgentMail boundary + ESC widening) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:407:**Recommended: B (ADR-006).** Closes the disagreement properly; gives Cat-1 a ratified architectural home; future-proofs against Cat-1 re-litigation. ~1 hour Claude work + 1 Codex round to ratify the ADR.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*
docs/decisions/autosend-safety-policy.md:3:**Status:** Proposed — pending Codex Day-7 ratification
docs/decisions/autosend-safety-policy.md:8:**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:123:| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:136:The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:209:The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
docs/decisions/autosend-safety-policy.md:229:Agents cannot invoke action_types not declared in their `tools.yaml`. Renderer validates this at render time per ADR-003 §4 (`ESC_RENDERER_FAILED` reason `bundle-malformed` if a declared action_type isn't in the policy).
docs/decisions/autosend-safety-policy.md:241:**Payload (JSONB into `decision_log.payload`):**
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:358:| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:427:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:514:(decision_log.payload.policy_version_sha), is the authoritative record
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:596:| 1 | Formal `action_type` taxonomy enum — should this live in autosend-policy.yaml only, or also in a typed schema for tools.yaml validation? | §3 + §4 | Defer to ADR-005 in Week 1; recommend typed enum in JSON Schema mirrored to YAML |
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
docs/decisions/autosend-safety-policy.md:624:Remaining open questions (Q1 action_type enum format, Q2 policy file format, Q4 multi-recipient batching, Q7 policy version pinning, Q8 spot-check disagreement feedback, Q9 cross-action coupling, Q10 Telegram SLA instrumentation) deferred for ADR-005 + Week-1+ work.
docs/decisions/autosend-safety-policy.md:632:**For Week 1-2.** The `_shared/voice-loader.sh` + `hook-helpers.sh` Week-1 prerequisite (per ADR-002 §"For Week 1 work" + ADR-003 Decision 3) now has its `hh_decision_action` specification. Implementation work is well-defined: §4 pseudocode + §5 escalation payloads + §7 audit row schema.
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:658:- v1.0 implementation prerequisite: this policy + the Week-1 `_shared/` helpers + ADR-003 renderer + Day-4 Postgres schema (all four are present after this commit lands).
docs/specs/ULTRAPLAN.md:6:**Status:** Authoritative build plan. Supersedes any informal build sequencing in prior documents. Where this contradicts an earlier doc on *how to build*, this wins. The product spec wins on *what to build*.
docs/specs/ULTRAPLAN.md:90:- MCP connectors (Bullhorn, Vincere, Voyager Infinity, Companies House, Microsoft Graph, Xero, Fathom, LinkedIn, AgentMail)
docs/specs/ULTRAPLAN.md:496:- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish)*
docs/specs/ULTRAPLAN.md:510:- **Gate A:** dedup confidence score ≥ 0.85 on every merge proposal; no merge proposed where candidate has had activity in last 90 days without explicit review flag
docs/specs/ULTRAPLAN.md:524:- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
docs/specs/ULTRAPLAN.md:538:- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
docs/specs/ULTRAPLAN.md:552:- **Gate A:** 5–15 candidates returned per brief; each has a working contact method; each has rationale ≥ 50 words; no candidate flagged "do not contact" in tenant vault
docs/specs/ULTRAPLAN.md:563:- **MCP tools required:** Bullhorn (read for state, write for activity log), Microsoft Graph / Gmail (send), AgentMail (optional for agent-identity sends)
docs/specs/ULTRAPLAN.md:565:- **External APIs:** Microsoft Graph or Google Workspace per tenant; AgentMail for v1.1+
docs/specs/ULTRAPLAN.md:566:- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
docs/specs/ULTRAPLAN.md:577:- **Trigger type:** Inbound email webhook (Microsoft Graph subscription or AgentMail webhook), LinkedIn InMail webhook, website contact form webhook
docs/specs/ULTRAPLAN.md:579:- **MCP tools required:** Microsoft Graph or Gmail (read + send), AgentMail (send, where agent-identity is needed), Bullhorn (read for candidate matching), LinkedIn (read)
docs/specs/ULTRAPLAN.md:581:- **External APIs:** Microsoft Graph subscriptions, AgentMail
docs/specs/ULTRAPLAN.md:582:- **Gate A:** draft generated within 60s of webhook receipt; classification has confidence ≥ 0.8; no auto-send on uncategorised messages
docs/specs/ULTRAPLAN.md:585:- **Gotchas:** This is the most dangerous auto-send agent. Auto-send categories must be gated tightly (acknowledge-new-candidate only at v1.1 launch, expand after 30 days of clean data). Misclassification of a complaint as a routine inbound is a relationship killer. The deliverability test for AgentMail vs Microsoft Graph is the rate-limiting research.
docs/specs/ULTRAPLAN.md:596:- **Gate A:** every brief produces 3 ambiguity flags OR an "unambiguous" signal; pre-shortlist contains 3–10 candidates; intake-call agenda has 5–8 items
docs/specs/ULTRAPLAN.md:614:- **Gate A:** detection latency <5 min from competitor posting; outreach references the specific role title AND the competitor agency by name (the firm needs to know we're not making this up)
docs/specs/ULTRAPLAN.md:628:- **Gate A:** 8–12 candidates per brief; each has rationale ≥ 50 words; drafts for each are valid (Gate A on the draft itself); no rate-limit exceptions raised
docs/specs/ULTRAPLAN.md:642:- **Gate A:** every red-flag pattern (e.g., FCSA accreditation lapsed, complaint volume spike, director change) produces an alert within 24 hours; quarterly audit pack contains all required sections
docs/specs/ULTRAPLAN.md:656:- **Gate A:** every active contractor has a live state with AWR week counter, RTW expiry, contract end, holiday pay year-to-date; deadline-imminent alerts fire ≥7 days ahead
docs/specs/ULTRAPLAN.md:683:| Agent | Voice | Bullhorn | MSGraph | Xero/Sage | LinkedIn | CoHouse | Reed/CVLib | Fathom | AgentMail | Telegram | Special |

exec
/bin/zsh -lc "rg --files docs/decisions | sort | rg 'ADR-[0-9]+'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md

exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
     2	
     3	**Status:** Proposed (2026-05-24, Day 19)
     4	**Author:** Founder (Maddox) + Claude Code
     5	**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
     6	**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
     7	**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
     8	
     9	---
    10	
    11	## Context
    12	
    13	ULTRAPLAN §8.1 A1 line 496 specifies the Diagnostic Gate A citation requirement verbatim:
    14	
    15	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
    16	
    17	The "no claims unsupported by source data" clause implies **per-claim citation validation** — every factual claim in the report must have a backing source link. The Diagnostic v0 implementation at `agents/recruitment/diagnostic/validate.sh` enforces **per-section citation** (regex `\[.+\]\(.+\)` requires ≥1 markdown link per section); per-claim validation is NOT implemented at v0.
    18	
    19	(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract — implemented separately in `validate.sh`; they're not affected by this ADR. This ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)
    20	
    21	This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
    22	
    23	1. NLP claim-extraction from the rendered Markdown report (sentence-level fact identification)
    24	2. Per-claim evidence-link matching (semantic similarity between claim and cited URL content)
    25	3. Confidence threshold tuning to avoid false rejections of well-cited paraphrases
    26	
    27	This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
    28	
    29	Bilateral founder+Claude session on 2026-05-24 (Day 19) selected option **(b) — hybrid framing** as the disposition (Cat-1 in the disagreement doc). Founder authorization via AskUserQuestion accepted: "Hybrid (Recommended): v0 = per-section, W4 = per-claim spot-check".
    30	
    31	This ADR formalises that disposition as a ratified architectural decision so future Codex rounds + agent.md §5 framing treat it as upstream-canonical, not as a downstream weakening.
    32	
    33	---
    34	
    35	## Decision
    36	
    37	### Decision 1 — Diagnostic Gate A citation validation is a two-tier policy (per-section v0 hard-fail + per-claim W4 spot-check warn)
    38	
    39	### Tier 1 (v0; hard-fail) — per-section citation coverage
    40	
    41	Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`.
    42	
    43	### Tier 2 (W4 polish; warn-only sampling) — per-claim citation spot-check
    44	
    45	A statistical sample (1-in-N, configurable per tenant; default 1-in-10) of Diagnostic reports undergo post-render per-claim citation validation:
    46	
    47	- NLP claim-extraction (sentence-level)
    48	- Per-claim evidence-link matching (semantic similarity against cited URLs)
    49	- Per-claim confidence score
    50	- Aggregate report quality metric written to `decision_log.payload.per_claim_confidence_distribution` (NEW payload key — W4-polish schema work; not present in the `decision_log.payload` shape documented at `docs/decisions/autosend-safety-policy.md` §7 audit row schema today, which lists `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `override_applied`, approval fields, `block_reason`, and `policy_version_sha` only; W4-polish lands a payload-schema supplement that adds this key before any write)
    51	
    52	Below threshold (e.g. <80% of claims with confidence ≥0.6) → warn (not block); operator review queue entry.
    53	
    54	The per-tenant sample-rate override (`tenant_adapters.config.diagnostic_per_claim_sample_rate`) is also a NEW config field — W4-polish-blocked: `tenant_adapters` schema does not include it today; v0.3 vertical-schema supplement work needs to add it before Tier 2 activates.
    55	
    56	### W4 polish trigger
    57	
    58	When the voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports, the per-claim spot-check pipeline activates. Until then, Tier 2 is documented intent only.
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
    70	> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link (per-section, Tier 1, hard-fail at v0 — already implemented); "no claims unsupported by source data" is enforced via per-claim citation spot-check sampling (Tier 2, W4 polish, warn-only). See `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for the two-tier framing.
    71	
    72	**In-band amendment (landed in commit `aed9d3b`):** `docs/specs/ULTRAPLAN.md` line 496 now reads verbatim:
    73	
    74	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish)*
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
   113	- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the unchanged ULTRAPLAN line 497 prose alone)
   114	- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (ADR-007 Janitor Gate A, ADR-008 Scribe Gate A, etc.) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
   115	
   116	### W4-polish slice (after voice-classifier microservice ships + first pilot tenant data accumulates)
   117	
   118	- Per-claim spot-check pipeline lands as Tier 2 validate.sh extension
   119	- Sample rate configurable per tenant in `tenant_adapters.config.diagnostic_per_claim_sample_rate`
   120	- Aggregate metric writes to `decision_log.payload.per_claim_confidence_distribution`
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
/bin/zsh -lc "nl -ba docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md | sed -n '390,412p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '488,500p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   488	
   489	- **Build wave:** v1.0 (week 4–5)
   490	- **Always-on?** No — invoked on demand
   491	- **Trigger type:** Manual (run from CLI or sales-tool web page)
   492	- **CortexOS primitives required:** None — runs as a one-shot batch job
   493	- **MCP tools required:** Companies House, LinkedIn (read-only), web scraper for careers pages
   494	- **Shared modules required:** Voice loader (uses Maddox's voice for the audit narrative), decision log writer
   495	- **External APIs:** Companies House API (free), LinkedIn (via Proxycurl or similar), basic HTTP fetch
   496	- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish)*
   497	- **Gate B target:** ≥30% of diagnostics produced lead to a discovery call booked
   498	- **Build complexity:** **M** (1 week)
   499	- **Gotchas:** LinkedIn ToS — we cannot store profile data beyond the audit. Companies House rate limits — cache aggressively.
   500	

exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '232,270p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   261	4. Operator responds via Telegram inline button: `approve` / `reject` / `escalate-up`
   262	5. On resolution, `decision_log` row is **appended** (not modified — append-only) with `phase='action'`, `payload.approval_status='approved'|'rejected'|'escalated'` and `payload.approval_resolution_at`
   263	
   264	**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
   265	
   266	**Telegram message template:**
   267	
   268	```
   269	🟠 IFOS approval needed
   270	Tenant: acme-fintech

exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '390,455p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc 'rg -n "''^## §7|payload'"\\.tier|policy_version_sha|approval fields|audit row\" docs/decisions/autosend-safety-policy.md" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "tenant_adapters:|config:|diagnostic_per_claim_sample_rate|entities:|decision_log" docs/verticals/recruitment/vertical-schema.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
49:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
67:Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
362:## §7 — Audit
394:--     "policy_version_sha": "<git SHA of autosend-policy.yaml at execution>"
402:1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
514:(decision_log.payload.policy_version_sha), is the authoritative record
549:decision_log timestamps, payload_hash, and policy_version_sha.
555:payload.policy_version_sha field. Material changes to tier classification
632:**For Week 1-2.** The `_shared/voice-loader.sh` + `hook-helpers.sh` Week-1 prerequisite (per ADR-002 §"For Week 1 work" + ADR-003 Decision 3) now has its `hh_decision_action` specification. Implementation work is well-defined: §4 pseudocode + §5 escalation payloads + §7 audit row schema.

 succeeded in 0ms:
6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
45:entities:
804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
814:  Q4_system_agents_not_entities:
816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.

exec
/bin/zsh -lc 'git cat-file -t aed9d3b && git show --stat --oneline --no-renames aed9d3b -- docs/specs/ULTRAPLAN.md docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
commit
aed9d3b fix(ADR-006-r2): apply Codex R2 3 findings + ULTRAPLAN in-band amendment
 docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md | 6 +++---
 docs/specs/ULTRAPLAN.md                            | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '362,389p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc 'rg -n "Round 9|Diagnostic finding|Gate A weakens|source-data" docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
127:1. **Gate A vs ULTRAPLAN source-data citation strength** — every agent.md narrowed Gate A to per-section citation; ULTRAPLAN-equivalent requirements expect per-claim. Same issue, same disposition recommendation as Diagnostic Issue 1 — hybrid v0 per-section + W4 polish per-claim spot-check.
336:**Backlog landing items (queue Codex Round 9 ONLY after these land):**
348:## Phase 4 — Cat-γ widening + Cat-δ Diagnostic polish + Round 9 (2026-05-24, founder "proceed" instruction)
366:### Round 9 verdict — 30 findings (down from Round 8's 32; net −2)
380:### Round 9 finding samples (illustrative, not exhaustive)
396:### Cat-ζ — new category surfaced by Round 9
400:When founder authorizes a Cat-1 hybrid disposition (per-section v0 + per-claim W4), the agent.md prose explicitly documents this. Codex re-flags it as "Gate A weakens upstream requirement" regardless. This is structural — Codex reviews agent.md against ULTRAPLAN/master brief, and bilateral disposition documents at `docs/decisions/codex-disagreement-*.md` are downstream artefacts Codex doesn't auto-trust.
411:The pattern (Round 4 → Round 9; 10 rounds; 75+ unique findings; ~10% net convergence per round) empirically confirms master brief §10.3 step 5. Each remediation pass surfaces new issues at roughly the same rate it closes old ones — because the document keeps changing.
413:**Stopping condition met:** founder's "proceed" → Cat-γ widening + Cat-δ Diagnostic polish + Round 9 + this categorization is the conclusive "RATIFY-or-document-disagreement" outcome per the bilateral disposition. No further autonomous remediation will be attempted.
424:| Agent | Status | Round 9 findings | Path to RATIFIED |

exec
/bin/zsh -lc "nl -ba docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md | sed -n '360,386p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "rg -n \"voice|0\\.75|PII|evidence link|markdown link|ESC_AGENT_OUTPUT_SHAPE\" agents/recruitment/diagnostic/validate.sh" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
30:#   V2 — Each section has ≥1 markdown link (regex)
31:#   V3 — Section 12 voice classifier score ≥ 0.75
34:#   V6 — No PII outside firm boundary (regex pass)
100:# V2 — Each section has ≥1 markdown link
128:# V3 — §12 voice classifier ≥ 0.75
147:    if [[ -n "${SCORE}" ]] && python3 -c "import sys; sys.exit(0 if float('${SCORE}') >= 0.75 else 1)" 2>/dev/null; then
148:      _pass "V3: §12 voice classifier score=${SCORE} (≥ 0.75)"
150:      _fail "V3: §12 voice classifier score=${SCORE} (< 0.75)"
153:    _warn "V3: IFOS_VOICE_CLASSIFIER_URL unset; voice classification SKIPPED (W3 build wires this)"
200:# V6 — No PII outside firm boundary
208:# the PII-boundary check. Stub for scaffold.
213:# This is a coarse check — true PII boundary requires firm-domain enumeration
219:  _pass "V6: no emails embedded (firm-boundary PII check trivially passes)"
234:  #   - PII detected outside firm boundary → ESC_PII_LEAKAGE_RISK (blocking)
236:  #     length, voice-classifier miss) → ESC_AGENT_OUTPUT_SHAPE (warn)
240:  PII_FAILURE_PRESENT=0
242:    if [[ "${failure}" == *"PII"* || "${failure}" == *"pii"* ]]; then
243:      PII_FAILURE_PRESENT=1
248:  if (( PII_FAILURE_PRESENT == 1 )); then
249:    ESC_CODE="ESC_PII_LEAKAGE_RISK"
251:    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"

codex
REJECTED

1. Status is `Proposed` even though the ADR has already actioned its amendment. Lines 3 and 146 say the decision is still Proposed / awaiting ratification, but lines 72-76 state the ULTRAPLAN amendment already landed in commit `aed9d3b`; the type skill defines `Proposed` as not ratified or actioned. Fix: either defer the ULTRAPLAN edit until post-ratification, or mark the ADR `Accepted` with an explicit founder decision date and update the status-update line.

2. The ULTRAPLAN citation is no longer verbatim against the live file. Line 13 says ULTRAPLAN §8.1 A1 line 496 “specifies” the quoted original text, but live `docs/specs/ULTRAPLAN.md` line 496 now includes the ADR-006 parenthetical. Fix: distinguish “pre-amendment wording” from the current live wording in Context, and quote the current line where claiming current/verbatim text.

3. New schema fields are deferred without a named owner. Lines 50 and 54 introduce `decision_log.payload.per_claim_confidence_distribution` and `tenant_adapters.config.diagnostic_per_claim_sample_rate`, but only say W4/v0.3 supplement work will add them before use; type-specific §5 requires spec gaps to have a resolution or explicit deferral to a named owner + week. Fix: add a named owner and exact W4/v0.3 delivery trigger for both schema additions, or remove the fields from the decision until the schema supplement exists.
tokens used
36,951
REJECTED

1. Status is `Proposed` even though the ADR has already actioned its amendment. Lines 3 and 146 say the decision is still Proposed / awaiting ratification, but lines 72-76 state the ULTRAPLAN amendment already landed in commit `aed9d3b`; the type skill defines `Proposed` as not ratified or actioned. Fix: either defer the ULTRAPLAN edit until post-ratification, or mark the ADR `Accepted` with an explicit founder decision date and update the status-update line.

2. The ULTRAPLAN citation is no longer verbatim against the live file. Line 13 says ULTRAPLAN §8.1 A1 line 496 “specifies” the quoted original text, but live `docs/specs/ULTRAPLAN.md` line 496 now includes the ADR-006 parenthetical. Fix: distinguish “pre-amendment wording” from the current live wording in Context, and quote the current line where claiming current/verbatim text.

3. New schema fields are deferred without a named owner. Lines 50 and 54 introduce `decision_log.payload.per_claim_confidence_distribution` and `tenant_adapters.config.diagnostic_per_claim_sample_rate`, but only say W4/v0.3 supplement work will add them before use; type-specific §5 requires spec gaps to have a resolution or explicit deferral to a named owner + week. Fix: add a named owner and exact W4/v0.3 delivery trigger for both schema additions, or remove the fields from the decision until the schema supplement exists.
