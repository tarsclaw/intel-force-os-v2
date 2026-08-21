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
session id: 019e59eb-cb6a-7191-9afc-d6863d9aaad9
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

**Status:** Accepted (2026-05-24, Day 19; ULTRAPLAN in-band amendment landed at commit `aed9d3b`; awaiting Codex `review-architecture-decision` ratification confirmation)
**Author:** Founder (Maddox) + Claude Code
**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR

---

## Context

ULTRAPLAN §8.1 A1 line 496 (pre-amendment wording — before this ADR's in-band edit landed in commit `aed9d3b`):

> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data

Current line 496 (post-amendment; live as of commit `aed9d3b`):

> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish)*

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
- Aggregate report quality metric written to `decision_log.payload.per_claim_confidence_distribution` (NEW payload key — W4-polish schema work; not present in the `decision_log.payload` shape documented at `docs/decisions/autosend-safety-policy.md` §7 audit row schema today, which lists `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `override_applied`, approval fields, `block_reason`, and `policy_version_sha` only). **Owner:** Claude Code authors the autosend-safety-policy §7 supplement adding this key. **Trigger:** W4-polish work (after Diagnostic v0 first-pilot launch); estimated 2026-06-21 to 2026-06-28. Tier 2 sampling MUST NOT activate until this supplement lands + Codex ratifies it.

Below threshold (e.g. <80% of claims with confidence ≥0.6) → warn (not block); operator review queue entry.

The per-tenant sample-rate override (`tenant_adapters.config.diagnostic_per_claim_sample_rate`) is also a NEW config field — `tenant_adapters` schema does not include it today. **Owner:** Claude Code authors the v0.3 vertical-schema supplement adding this field. **Trigger:** W4-polish (same delivery window as the payload-schema supplement; 2026-06-21 to 2026-06-28). Tier 2 sampling MUST NOT activate until v0.3 supplement lands + Codex ratifies it.

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
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '480,505p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   496	- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish)*
   497	- **Gate B target:** ≥30% of diagnostics produced lead to a discovery call booked
   498	- **Build complexity:** **M** (1 week)
   499	- **Gotchas:** LinkedIn ToS — we cannot store profile data beyond the audit. Companies House rate limits — cache aggressively.
   500	
   501	#### A2. The Janitor — the wedge agent
   502	
   503	- **Build wave:** v1.0 (week 5–6)
   504	- **Always-on?** Tier 2 — scheduled nightly cron
   505	- **Trigger type:** Cron 02:00 UTC daily; manual full-cleanup on demand

exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
     2	
     3	**Status:** Accepted (2026-05-24, Day 19; ULTRAPLAN in-band amendment landed at commit `aed9d3b`; awaiting Codex `review-architecture-decision` ratification confirmation)
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
    19	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish)*
    20	
    21	The "no claims unsupported by source data" clause implies **per-claim citation validation** — every factual claim in the report must have a backing source link. The Diagnostic v0 implementation at `agents/recruitment/diagnostic/validate.sh` enforces **per-section citation** (regex `\[.+\]\(.+\)` requires ≥1 markdown link per section); per-claim validation is NOT implemented at v0.
    22	
    23	(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract — implemented separately in `validate.sh`; they're not affected by this ADR. This ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)
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
    41	### Decision 1 — Diagnostic Gate A citation validation is a two-tier policy (per-section v0 hard-fail + per-claim W4 spot-check warn)
    42	
    43	### Tier 1 (v0; hard-fail) — per-section citation coverage
    44	
    45	Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`.
    46	
    47	### Tier 2 (W4 polish; warn-only sampling) — per-claim citation spot-check
    48	
    49	A statistical sample (1-in-N, configurable per tenant; default 1-in-10) of Diagnostic reports undergo post-render per-claim citation validation:
    50	
    51	- NLP claim-extraction (sentence-level)
    52	- Per-claim evidence-link matching (semantic similarity against cited URLs)
    53	- Per-claim confidence score
    54	- Aggregate report quality metric written to `decision_log.payload.per_claim_confidence_distribution` (NEW payload key — W4-polish schema work; not present in the `decision_log.payload` shape documented at `docs/decisions/autosend-safety-policy.md` §7 audit row schema today, which lists `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `override_applied`, approval fields, `block_reason`, and `policy_version_sha` only). **Owner:** Claude Code authors the autosend-safety-policy §7 supplement adding this key. **Trigger:** W4-polish work (after Diagnostic v0 first-pilot launch); estimated 2026-06-21 to 2026-06-28. Tier 2 sampling MUST NOT activate until this supplement lands + Codex ratifies it.
    55	
    56	Below threshold (e.g. <80% of claims with confidence ≥0.6) → warn (not block); operator review queue entry.
    57	
    58	The per-tenant sample-rate override (`tenant_adapters.config.diagnostic_per_claim_sample_rate`) is also a NEW config field — `tenant_adapters` schema does not include it today. **Owner:** Claude Code authors the v0.3 vertical-schema supplement adding this field. **Trigger:** W4-polish (same delivery window as the payload-schema supplement; 2026-06-21 to 2026-06-28). Tier 2 sampling MUST NOT activate until v0.3 supplement lands + Codex ratifies it.
    59	
    60	### W4 polish trigger
    61	
    62	When the voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports, the per-claim spot-check pipeline activates. Until then, Tier 2 is documented intent only.
    63	
    64	---
    65	
    66	## ULTRAPLAN amendment
    67	
    68	`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):
    69	
    70	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
    71	
    72	After this ADR ratifies, the canonical interpretation is:
    73	
    74	> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link (per-section, Tier 1, hard-fail at v0 — already implemented); "no claims unsupported by source data" is enforced via per-claim citation spot-check sampling (Tier 2, W4 polish, warn-only). See `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for the two-tier framing.
    75	
    76	**In-band amendment (landed in commit `aed9d3b`):** `docs/specs/ULTRAPLAN.md` line 496 now reads verbatim:
    77	
    78	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish)*
    79	
    80	This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
    81	
    82	---
    83	
    84	## Why hybrid not full-spec
    85	
    86	**Why not (a) defer launch until per-claim lands?**
    87	- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
    88	- A working v0 with per-section validation has measurable Gate A coverage; deferring means no Gate A at all in the meantime, which is strictly worse
    89	- The 30%-discovery-call Gate B target is independent of per-claim validation; pilot value is reachable without it
    90	
    91	**Why not (c) amend ULTRAPLAN downward permanently?**
    92	- The per-claim requirement is genuinely valuable for v1.1+ once the NLP pipeline exists
    93	- Permanently removing it from ULTRAPLAN loses the documented quality bar
    94	- Hybrid preserves the W4-polish path; permanent amendment closes that door
    95	
    96	**Why hybrid is honest signal (Rule 5):**
    97	- v0 implementation does what it says; W4 polish path is documented + scheduled
    98	- Codex flags become explicit-disposition references (this ADR) not unaddressed weakening
    99	- Pilot tenants reading Gate A spec see the v0 contract clearly + the W4 expansion plan
   100	
   101	---
   102	
   103	## Consequences
   104	
   105	### Immediate (this ADR commit)
   106	
   107	- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
   108	- `agents/recruitment/diagnostic/validate.sh` retains current per-section enforcement (no implementation change)
   109	
   110	### Next commit (after this ADR ratifies)
   111	
   112	- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
   113	- `docs/decisions/2026-05-18-codex-ratification-manifest.md` queue updated to include this ADR. NOT yet updated as of this commit; lands in the post-ratify commit.
   114	
   115	### After Codex ratifies this ADR (Status flips Proposed → Accepted)
   116	
   117	- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the unchanged ULTRAPLAN line 497 prose alone)
   118	- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (ADR-007 Janitor Gate A, ADR-008 Scribe Gate A, etc.) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
   119	
   120	### W4-polish slice (after voice-classifier microservice ships + first pilot tenant data accumulates)
   121	
   122	- Per-claim spot-check pipeline lands as Tier 2 validate.sh extension
   123	- Sample rate configurable per tenant in `tenant_adapters.config.diagnostic_per_claim_sample_rate`
   124	- Aggregate metric writes to `decision_log.payload.per_claim_confidence_distribution`
   125	- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
   126	
   127	### Downstream artefact references (queued for post-ratify commit)
   128	
   129	- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
   130	- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
   131	- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
   132	- `docs/decisions/2026-05-18-codex-ratification-manifest.md` → adds this ADR as ratification queue item
   133	
   134	These edits all land in the next commit AFTER this ADR ratifies (no point updating agent.md to cite a Proposed ADR; cite once ratified).
   135	
   136	---
   137	
   138	## Open questions
   139	
   140	| # | Question | Resolution path |
   141	|---|---|---|
   142	| Q1 | Default sample rate for Tier 2 spot-check? Recommend 1-in-10 (~10% of reports validated per-claim) for first pilot; adjust based on early signal | Founder review at first-pilot W4 polish landing |
   143	| Q2 | NLP claim-extraction library — what's the right tool? (spaCy + custom rules / Claude API-based extraction / hosted service) | W4 polish technical investigation; cost vs accuracy tradeoff |
   144	| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |
   145	
   146	---
   147	
   148	## Status
   149	
   150	**Proposed.** Awaits Codex ratification via `review-architecture-decision.md` skill.
   151	
   152	Status flips Proposed → Accepted when:
   153	- Codex returns RATIFIED for this ADR
   154	- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
   155	
   156	*End of ADR-006.*

exec
/bin/zsh -lc 'ls docs/decisions/ADR-*.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md

exec
/bin/zsh -lc "nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '55,70p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc 'rg -n "''^##|''^###|audit row|payload|tier|action_type|policy_version_sha" docs/decisions/autosend-safety-policy.md' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "Round 9|Diagnostic finding|Cat-ζ|ADR-006|Phase 4" docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'git show --no-patch --oneline aed9d3b && git show --stat --oneline --name-only aed9d3b -- docs/specs/ULTRAPLAN.md docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md' in /Users/madsadmin/code/CortexOS
 succeeded in 107ms:
12:## §1 — Scope
39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
43:## §2 — Tier model
45:Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.
47:### Green — auto-send allowed without review
49:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
53:### Yellow — auto-send allowed with sampled spot-check
55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
59:### Orange — requires human approval before send
61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
65:### Red — blocked entirely
67:Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
73:## §3 — Examples per tier across the v1.0 agent surface
75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
77:### Green examples (auto-send without review)
79:| Agent | action_type | Why green |
88:### Yellow examples (auto-send with spot-check sampling)
90:| Agent | action_type | Sample rate | Why yellow |
98:### Orange examples (per-action human approval)
100:| Agent | action_type | Why orange |
113:### Red examples (blocked entirely; `ESC_AUTOSEND_BLOCKED`)
115:| action_type | block_reason | Why red |
128:## §4 — Integration with the `hh_decision_action` contract
138:### Reference implementation (bash pseudocode for `_shared/hook-helpers.sh`)
143:#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
145:#   $3 payload_hash  (SHA-256 hex of the action payload)
146:#   $4 payload_preview (human-readable summary, <=500 chars, NO raw PII)
148:  local action_type="$1"
150:  local payload_hash="$3"
151:  local payload_preview="$4"
157:  # 1. Policy lookup — read tier from the canonical policy table
158:  local tier
159:  tier=$(autosend_policy_lookup "$action_type") || {
160:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
161:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
166:  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
167:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
168:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
173:  case "$tier" in
175:      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
179:      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
180:      if autosend_should_sample "$action_type" "$tenant_slug"; then
181:        autosend_spot_check_enqueue "$action_type" "$target" "$payload_hash" "$payload_preview" "$tenant_slug"
186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
187:      autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW "$action_type" "$target" "$payload_hash" "$payload_preview"
189:      autosend_await_approval "$action_type" "$target" "$payload_hash"
193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
194:      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
198:      # Fail-safe: unknown tier → red
199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
200:      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
207:### Where the policy check fires in the renderer pipeline
213:### `tools.yaml` declaration
215:Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
219:action_types:
229:Agents cannot invoke action_types not declared in their `tools.yaml`. Renderer validates this at render time per ADR-003 §4 (`ESC_RENDERER_FAILED` reason `bundle-malformed` if a declared action_type isn't in the policy).
233:## §5 — Escalation codes
235:Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.
237:### `ESC_AUTOSEND_NEEDS_REVIEW`
240:**Fires when:** an orange-tier action is invoked; opens cortextOS approval gate (primitive 4)
241:**Payload (JSONB into `decision_log.payload`):**
245:  "action_type": "<enum from autosend-policy.yaml>",
247:  "payload_hash": "<SHA-256 hex>",
248:  "payload_preview": "<human summary, <=500 chars, NO raw PII>",
258:1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
262:5. On resolution, `decision_log` row is **appended** (not modified — append-only) with `phase='action'`, `payload.approval_status='approved'|'rejected'|'escalated'` and `payload.approval_resolution_at`
264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
280:### `ESC_AUTOSEND_BLOCKED`
283:**Fires when:** a red-tier action is invoked; blocked unconditionally
288:  "action_type": "<enum>",
290:  "payload_hash": "<SHA-256 hex>",
291:  "payload_preview": "<human summary, <=500 chars>",
292:  "block_reason": "<enum: red_tier_classification | blocked_recipient | unauthorized_adapter | cross_tenant_violation | payment_action | billing_modification | legal_artefact | pii_geographic_breach>",
302:3. Operator may file a `false-block` feedback report via Brain UI if the tier classification seems wrong; report becomes input to next policy review
304:**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).
314:Block reason: payment_action (red-tier; never auto-sent in v1.0)
318:### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
326:  "action_type": "<enum, may be unknown>",
328:  "payload_hash": "<SHA-256 hex>",
329:  "payload_preview": "<human summary>",
330:  "lookup_error": "<enum: unknown_action_type | policy_table_corrupt | override_resolution_failed | tenant_not_found | unknown_tier:<value>>",
338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
341:4. Root cause + fix applied (e.g., add missing `action_type` to policy, repair table corruption, fix override format)
348:## §6 — Failure modes
353:| Policy file references undefined tier | Tier dispatch hits `*)` default | `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` with `lookup_error='unknown_tier:<value>'` | Policy file fixed; Codex ratifies; redeploy |
354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
358:| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |
362:## §7 — Audit
366:### Row schema (within existing `decision_log` table from Day 4)
376:--   payload JSONB
382:--   payload structure:
384:--     "tier": "green|yellow|orange|red|fail-safe-red",
385:--     "action_type": "<enum>",
387:--     "payload_hash": "<SHA-256 hex>",
388:--     "payload_preview": "<<=500 chars, NO raw PII>",
394:--     "policy_version_sha": "<git SHA of autosend-policy.yaml at execution>"
398:### What audit answers
402:1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
406:### Privacy of payload
408:`payload_preview` is **explicitly required to exclude raw PII**. It is a human-readable summary that:
414:Full message content lives in the originating system (Bullhorn, Gmail, Twilio). Audit references the system's own audit log (e.g., Bullhorn note ID) via `payload.target`.
416:### Retention
422:## §8 — Per-tenant override
424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
432:    "tier_overrides": {
459:### Override rules
461:1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
462:2. **Red is absolute.** A red action_type cannot be elevated by tenant override (already at maximum) and cannot be relaxed (red is the floor).
464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
465:5. **`approval_timeouts`** allow per-action_type customisation within range [PT30M, PT72H]. Defaults to PT4H if unspecified.
466:6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
468:### Override propagation
470:Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.
474:## §9 — v1.0 vs v1.1+ phasing
476:### v1.0 ships with green + red only
481:- **Yellow** (sampled review) requires building the spot-check queue infrastructure (spot_check_queue table, Brain UI review interface, sampling-disagreement-feedback loop). Defers without operational risk: high-volume agent work can run as green at v1.0 without sampled review, with tier elevation to orange-in-v1.1 as a fallback if quality issues surface.
485:### v1.1 phases in
487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
488:- **Yellow tier:** spot-check sampling. Implementation tasks: `spot_check_queue` table, `autosend_should_sample` function, Brain UI spot-check review interface, sampling-disagreement feedback loop into policy review.
491:### v1.2+ phases in
493:- **Adaptive tiering:** ML-driven tier adjustment based on incident history. E.g., if `linkedin_connection_request` shows 0 false-blocks over 90 days, automatically propose downgrade from orange to yellow.
495:- **Pre-action policy simulation:** Brain UI feature — operator types proposed action; system shows tier, override impact, approval routing, expected resolution time. Reduces accidental tier-aware design.
500:## §10 — Pilot-agreement liability language (PLACEHOLDER — legal review required)
511:classifies each agent action into one of four tiers: green, yellow,
514:(decision_log.payload.policy_version_sha), is the authoritative record
526:  (d) any tier override defined in Tenant's tenant_adapters configuration
527:      that elevates or otherwise alters the policy default tier
536:      tier;
549:decision_log timestamps, payload_hash, and policy_version_sha.
555:payload.policy_version_sha field. Material changes to tier classification
580:### Open legal questions to resolve before first pilot LOI
586:5. **PII liability for `payload_preview` formatting.** If `payload_preview` accidentally leaks PII into `decision_log`, that's a Provider liability event. Tooling: linter on `payload_preview` strings at hook-helpers.sh layer.
592:## §11 — Open questions surfaced for future ADR work
596:| 1 | Formal `action_type` taxonomy enum — should this live in autosend-policy.yaml only, or also in a typed schema for tools.yaml validation? | §3 + §4 | Defer to ADR-005 in Week 1; recommend typed enum in JSON Schema mirrored to YAML |
599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
601:| 6 | v1.0 "would-be-orange" cases without orange tier implementation — how does the agent halt for ad-hoc Telegram approval without breaking the green/red binary? | §9 | Recommend a `hh_decision_action_ad_hoc_approval` helper that lives alongside `hh_decision_action`; agent explicitly calls it for known orange cases at v1.0; v1.1 deprecates as orange tier ships. |
603:| 8 | Spot-check disagreement feedback loop — what's the mechanism for spot-check reviewer disagreement to elevate an action_type's tier? | §2 + §11 | Recommend a `spot_check_disagreement` table; >3 disagreements over 30 days triggers a tier-elevation proposal that goes through Codex ratification. v1.1 builds this. |
604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
607:### Items NOT deferred (resolved inline above)
616:### Day-5 founder decisions on §11 questions
621:- **Q5 (sampling rate defaults for yellow tier):** ACCEPTED for v1.0 with explicit operational-guess flag. Real sampling rates need pilot data; current defaults (1-in-5 to 1-in-20 per `action_type` in §3) are operational guesses calibrated by analogy to typical CRM audit-sampling practice. Refinement happens once first pilot generates 4+ tenant-weeks of yellow-tier action volume.
622:- **Q6 (v1.0 ad-hoc orange handling without orange tier shipped):** ACCEPTED. `hh_decision_action_ad_hoc_approval` helper sits alongside `hh_decision_action` in `_shared/hook-helpers.sh` (Week-1 prereq 3). Agent explicitly calls `_ad_hoc_approval` for known orange cases at v1.0; v1.1 deprecates the helper as full orange tier ships through `hh_decision_action`'s case-orange branch.
624:Remaining open questions (Q1 action_type enum format, Q2 policy file format, Q4 multi-recipient batching, Q7 policy version pinning, Q8 spot-check disagreement feedback, Q9 cross-action coupling, Q10 Telegram SLA instrumentation) deferred for ADR-005 + Week-1+ work.
628:## Consequences
632:**For Week 1-2.** The `_shared/voice-loader.sh` + `hook-helpers.sh` Week-1 prerequisite (per ADR-002 §"For Week 1 work" + ADR-003 Decision 3) now has its `hh_decision_action` specification. Implementation work is well-defined: §4 pseudocode + §5 escalation payloads + §7 audit row schema.
634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
644:3. ESC code payload structures per §5
652:## Status
657:- v1.0 ship date: tier coverage is green + red. Yellow + orange phase in v1.1.

 succeeded in 106ms:
336:**Backlog landing items (queue Codex Round 9 ONLY after these land):**
348:## Phase 4 — Cat-γ widening + Cat-δ Diagnostic polish + Round 9 (2026-05-24, founder "proceed" instruction)
366:### Round 9 verdict — 30 findings (down from Round 8's 32; net −2)
380:### Round 9 finding samples (illustrative, not exhaustive)
383:1. Gate A per-claim vs per-section: STILL flagged despite Cat-1 hybrid disposition; this is a Codex–founder disagreement, not relitigation of Cat-1 (founder's hybrid stance documented but Codex doesn't accept the bilateral-disposition framing as an in-band acceptance of weakening). **Disposition: founder-decision; flagged as Cat-ζ "Cat-1 framing not auto-accepted by Codex".**
396:### Cat-ζ — new category surfaced by Round 9
398:**Cat-ζ — Codex does not accept bilateral-disposition framings as in-band Gate A acceptances.**
404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
405:- **C) Document as permanent Cat-ζ disagreement** — accept that Codex will continue flagging this; rely on the disagreement doc as the founder-authority record.
407:**Recommended: B (ADR-006).** Closes the disagreement properly; gives Cat-1 a ratified architectural home; future-proofs against Cat-1 re-litigation. ~1 hour Claude work + 1 Codex round to ratify the ADR.
411:The pattern (Round 4 → Round 9; 10 rounds; 75+ unique findings; ~10% net convergence per round) empirically confirms master brief §10.3 step 5. Each remediation pass surfaces new issues at roughly the same rate it closes old ones — because the document keeps changing.
413:**Stopping condition met:** founder's "proceed" → Cat-γ widening + Cat-δ Diagnostic polish + Round 9 + this categorization is the conclusive "RATIFY-or-document-disagreement" outcome per the bilateral disposition. No further autonomous remediation will be attempted.
416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
422:**Per-agent state at Phase 4 close:**
424:| Agent | Status | Round 9 findings | Path to RATIFIED |
426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*

 succeeded in 169ms:
aed9d3b fix(ADR-006-r2): apply Codex R2 3 findings + ULTRAPLAN in-band amendment
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md
docs/specs/ULTRAPLAN.md

codex
REJECTED

1. Status is internally contradictory. Line 3 says `**Status:** Accepted`, but lines 107, 115, and 150-154 say the ADR is Proposed and only flips to Accepted after Codex ratification plus follow-up agent.md edits. Type-specific §1 rejects status drift. Proposed fix: make the top status `Proposed` until ratification is complete, or remove the pending/proposed language and ensure the downstream acceptance conditions have already landed.

2. The ADR adds a new `decision_log.payload` key without current audit-shape support. Line 54 introduces `decision_log.payload.per_claim_confidence_distribution` and explicitly says it is “not present” in `autosend-safety-policy.md` §7 today. Type-specific §7 requires payload keys referenced by decisions to be confirmed in autosend-safety-policy §7. Proposed fix: either land and ratify the autosend-safety-policy §7 supplement in the same atomic change before accepting this ADR, or keep Tier 2 as a non-binding future ADR placeholder without naming a concrete payload key.

3. The ADR introduces a new tenant config field before schema support exists. Line 58 names `tenant_adapters.config.diagnostic_per_claim_sample_rate` and says the schema does not include it today. This violates top-level Rule 2 unless the schema supplement exists before any decision assumes the field shape. Proposed fix: remove the concrete field name from this ADR or land the v0.3 vertical-schema supplement first and cite it here.
tokens used
51,086
REJECTED

1. Status is internally contradictory. Line 3 says `**Status:** Accepted`, but lines 107, 115, and 150-154 say the ADR is Proposed and only flips to Accepted after Codex ratification plus follow-up agent.md edits. Type-specific §1 rejects status drift. Proposed fix: make the top status `Proposed` until ratification is complete, or remove the pending/proposed language and ensure the downstream acceptance conditions have already landed.

2. The ADR adds a new `decision_log.payload` key without current audit-shape support. Line 54 introduces `decision_log.payload.per_claim_confidence_distribution` and explicitly says it is “not present” in `autosend-safety-policy.md` §7 today. Type-specific §7 requires payload keys referenced by decisions to be confirmed in autosend-safety-policy §7. Proposed fix: either land and ratify the autosend-safety-policy §7 supplement in the same atomic change before accepting this ADR, or keep Tier 2 as a non-binding future ADR placeholder without naming a concrete payload key.

3. The ADR introduces a new tenant config field before schema support exists. Line 58 names `tenant_adapters.config.diagnostic_per_claim_sample_rate` and says the schema does not include it today. This violates top-level Rule 2 unless the schema supplement exists before any decision assumes the field shape. Proposed fix: remove the concrete field name from this ADR or land the v0.3 vertical-schema supplement first and cite it here.
