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
session id: 019e59f1-d0c0-7043-88ad-2592d5a815c2
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

**Status:** Proposed (2026-05-24, Day 19; ULTRAPLAN in-band amendment landed at commit `aed9d3b` as forward-looking placeholder text pending this ADR's ratification — if Codex REJECTS this ADR and founder doesn't accept it, the ULTRAPLAN line 496 inline parenthetical reverts in the rollback commit; Status flips to Accepted on Codex RATIFIED verdict per §Status criteria below)
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

(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract. Their v0 implementation in `validate.sh` is partial — `validate.sh` warns and emits `validate_check_skipped=true` when the voice-classifier URL is unreachable or the firm-domain whitelist is absent, rather than hard-failing; W4-polish closes these to hard-fail per `agents/recruitment/diagnostic/agent.md` §5 honesty note. These warn-only-paths exist in v0 but are not affected by this ADR; this ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)

This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:

1. NLP claim-extraction from the rendered Markdown report (sentence-level fact identification)
2. Per-claim evidence-link matching (semantic similarity between claim and cited URL content)
3. Confidence threshold tuning to avoid false rejections of well-cited paraphrases

This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.

Bilateral founder+Claude session on 2026-05-24 (Day 19) selected option **(b) — hybrid framing** as the disposition (Cat-1 in the disagreement doc). Founder authorization via AskUserQuestion accepted: "Hybrid (Recommended): v0 = per-section, W4 = per-claim spot-check".

This ADR formalises that disposition as a ratified architectural decision so future Codex rounds + agent.md §5 framing treat it as upstream-canonical, not as a downstream weakening.

---

## Decision

### Decision 1 — Diagnostic Gate A citation validation is per-section coverage ONLY (hard-fail)

Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **No warn-only paths in Gate A.** This satisfies Rule 4 (Quality gates before features) — Gate A is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted as "every section has at least one evidence link", consistent with the implementation.

### Decision 2 — Per-claim citation validation is a SEPARATE post-launch quality metric (NOT Gate A)

The per-claim citation pipeline (NLP claim-extraction + per-claim evidence-link matching + aggregate quality metric) is **explicitly outside Gate A** in v1.0. It lands as:

- A separate post-launch Diagnostic quality signal — analogous to Gate B's outcome threshold (30% discovery-call conversion) but for citation quality
- Authored as a separate W4 ADR (e.g. ADR-008 "Diagnostic per-claim citation quality metric") together with the schema supplements that define its payload key + per-tenant config field
- Sampling-based (1-in-N) post-launch quality monitoring; warn-level; never blocks v0 sends
- Activates after voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports

**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in ADR-008's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.

**Rule 4 (Quality gates before features) satisfied:** Gate A is exclusively hard-fail; nothing in Gate A is warn-only. Per-claim quality is a separate signal, not a weakening of Gate A.

---

## ULTRAPLAN amendment

`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):

> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data

After this ADR ratifies, the canonical interpretation is:

> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (see ADR-008 when authored at W4).

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

- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the original ULTRAPLAN line 496 prose alone)
- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (ADR-007 Janitor Gate A, ADR-008 Scribe Gate A, etc.) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed

### W4-polish slice (after voice-classifier microservice ships + first pilot tenant data accumulates)

- Per-claim spot-check pipeline lands as Tier 2 validate.sh extension
- Sample rate configurable per tenant via field landing in v0.3 vertical-schema supplement (concrete field name + type specified there, not in this ADR)
- Aggregate metric writes to `decision_log.payload` via key landing in autosend-safety-policy §7 supplement (concrete key name specified there, not in this ADR)
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

codex
I’ll verify the ADR structure and spot-check the live files it cites, especially ULTRAPLAN line 496, the kill criterion citation, and the diagnostic validator behavior.
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
/bin/zsh -lc 'rg -n "Gate A:|Trigger 2|DIAGNOSTIC-NO-RENDER|voice|validate_check_skipped|ESC_AGENT_OUTPUT_SHAPE|ADR-006|Status:" docs/specs/ULTRAPLAN.md docs/decisions/v1.0-kill-criterion.md agents/recruitment/diagnostic/validate.sh agents/recruitment/diagnostic/agent.md docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/specs/ULTRAPLAN.md:6:**Status:** Authoritative build plan. Supersedes any informal build sequencing in prior documents. Where this contradicts an earlier doc on *how to build*, this wins. The product spec wins on *what to build*.
docs/specs/ULTRAPLAN.md:34:**Rule 3 — Reuse before build.** Every agent uses the shared `_shared/` modules (voice loader, decision log writer, validate primitives, escalation router). No agent writes its own logging, its own voice handling, its own approval gate. If a shared module is missing, build the module first, then the agent.
docs/specs/ULTRAPLAN.md:73:- **The persistent PTY.** Agent process is *already running* with firm voice profile, ATS state, current pipeline, recent context pre-loaded. Sub-second to first useful action. Lambda cold starts are 3–8 seconds before the first token; Triage at that latency stops being magical.
docs/specs/ULTRAPLAN.md:137:        └── 99-voice-drift-canary/
docs/specs/ULTRAPLAN.md:142:The 99-voice-drift-canary fixture is new in v2. Every agent has one — a fixture designed to expose voice drift over time. Run weekly in CI; output diffed against historical baselines.
docs/specs/ULTRAPLAN.md:148:Phase 2 has each `context.sh` `cat` the voice profile inline. That works for nine agents; it's brittle at eighteen. v2 introduces `_shared/voice-loader.sh`:
docs/specs/ULTRAPLAN.md:152:source /tenant/.claude/bin/_shared/voice-loader.sh
docs/specs/ULTRAPLAN.md:157:# Retrieve top-N similar samples from voice corpus
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:164:Every agent's `context.sh` becomes 30 lines instead of 200. The voice loader is the canonical surface; agents never read the voice corpus directly.
docs/specs/ULTRAPLAN.md:182:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/specs/ULTRAPLAN.md:199:- `99-voice-drift-canary` — the structural canary.
docs/specs/ULTRAPLAN.md:220:- Inside: `_voice/`, `_playbooks/`, `_decisions/`, `candidates/`, `clients/`, `opportunities/`, `temp/` (if Temp tier active), `_config.yaml`.
docs/specs/ULTRAPLAN.md:230:- pgvector extension installed for the voice corpus embeddings (per-tenant, partitioned the same way).
docs/specs/ULTRAPLAN.md:300:## 6. The voice delivery system — how we technically deliver "in your voice" at 10/10
docs/specs/ULTRAPLAN.md:302:This is the answer to Q8, restated as a build specification. Voice is the single most important thing to get right. If voice fails, the product is a £49/month ChatGPT wrapper, not a £6,950/month operator.
docs/specs/ULTRAPLAN.md:306:**Layer 1 — The voice corpus (data).**
docs/specs/ULTRAPLAN.md:318:- Appended to the voice corpus weekly, with the edit's "lesson" extracted ("consultant shortened the opening", "consultant replaced 'I hope this finds you well' with nothing").
docs/specs/ULTRAPLAN.md:321:**Layer 2 — Runtime voice application (prompt assembly).**
docs/specs/ULTRAPLAN.md:323:Every agent's `context.sh` calls `_shared/voice-loader.sh`, which:
docs/specs/ULTRAPLAN.md:327:   You are writing in the voice of {firm name}. Hard rules:
docs/specs/ULTRAPLAN.md:348:- **Voice classifier score** — a small Sentence-BERT classifier trained on the tenant's voice corpus. Outputs a similarity score 0.0–1.0. Soft fail if < 0.75 (retry), hard fail if < 0.6 (escalate). Cost: ~200ms.
docs/specs/ULTRAPLAN.md:362:3. Eval the adapter against held-out drafts using the voice classifier — promote only if the adapter beats the RAG baseline by ≥5 percentage points on the voice score *and* doesn't regress on compliance or factual checks.
docs/specs/ULTRAPLAN.md:365:The LoRA improves voice score from ~80% (RAG + scaffolding) to ~90%+. This is what justifies the Scale tier at £6,950/mo.
docs/specs/ULTRAPLAN.md:369:### 6.2 The voice drift alerting
docs/specs/ULTRAPLAN.md:373:2. Run the voice classifier on each.
docs/specs/ULTRAPLAN.md:378:> "Your voice quality score has dropped from 0.83 to 0.76 over the last 4 weeks. This usually means new edit patterns we haven't absorbed. Can we book 30 minutes to review samples?"
docs/specs/ULTRAPLAN.md:380:We never silently accept voice drift. The structural commitment is that voice quality is measurable, measured, and surfaced.
docs/specs/ULTRAPLAN.md:382:### 6.3 The sales-floor demo of voice quality
docs/specs/ULTRAPLAN.md:388:3. Show the voice classifier score live on the screen: "0.84. Here's the draft."
docs/specs/ULTRAPLAN.md:434:- **Edit then send** — captures the diff for the voice corpus
docs/specs/ULTRAPLAN.md:494:- **Shared modules required:** Voice loader (uses Maddox's voice for the audit narrative), decision log writer
docs/specs/ULTRAPLAN.md:496:- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — Gate A = per-section hard-fail; per-claim quality signal is a separate post-launch metric outside Gate A)*
docs/specs/ULTRAPLAN.md:510:- **Gate A:** dedup confidence score ≥ 0.85 on every merge proposal; no merge proposed where candidate has had activity in last 90 days without explicit review flag
docs/specs/ULTRAPLAN.md:524:- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
docs/specs/ULTRAPLAN.md:533:- **Trigger type:** Webhook (payment received, invoice issued, invoice viewed) + cron sweep at 07:00 daily
docs/specs/ULTRAPLAN.md:538:- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
docs/specs/ULTRAPLAN.md:541:- **Gotchas:** Open Banking auth is a 90-day token; rotation logic is non-trivial. Bank feed reconciliation against invoice register is the hard logic; start with exact-amount matches and expand to fuzzy.
docs/specs/ULTRAPLAN.md:552:- **Gate A:** 5–15 candidates returned per brief; each has a working contact method; each has rationale ≥ 50 words; no candidate flagged "do not contact" in tenant vault
docs/specs/ULTRAPLAN.md:566:- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
docs/specs/ULTRAPLAN.md:582:- **Gate A:** draft generated within 60s of webhook receipt; classification has confidence ≥ 0.8; no auto-send on uncategorised messages
docs/specs/ULTRAPLAN.md:596:- **Gate A:** every brief produces 3 ambiguity flags OR an "unambiguous" signal; pre-shortlist contains 3–10 candidates; intake-call agenda has 5–8 items
docs/specs/ULTRAPLAN.md:614:- **Gate A:** detection latency <5 min from competitor posting; outreach references the specific role title AND the competitor agency by name (the firm needs to know we're not making this up)
docs/specs/ULTRAPLAN.md:628:- **Gate A:** 8–12 candidates per brief; each has rationale ≥ 50 words; drafts for each are valid (Gate A on the draft itself); no rate-limit exceptions raised
docs/specs/ULTRAPLAN.md:642:- **Gate A:** every red-flag pattern (e.g., FCSA accreditation lapsed, complaint volume spike, director change) produces an alert within 24 hours; quarterly audit pack contains all required sections
docs/specs/ULTRAPLAN.md:656:- **Gate A:** every active contractor has a live state with AWR week counter, RTW expiry, contract end, holiday pay year-to-date; deadline-imminent alerts fire ≥7 days ahead
docs/specs/ULTRAPLAN.md:671:| T2 Sunday-Evening Timesheet Ranger | M (1 week) | Bullhorn/Voyager + Microsoft Graph | The voice quality on per-contractor history is the work |
docs/specs/ULTRAPLAN.md:745:- Week 1: Agent Bundle v2 pattern refactor; `_shared/` module build; voice loader; escalation codes catalogue; vertical schema v0.1
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:1:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Proposed (2026-05-24, Day 19; ULTRAPLAN in-band amendment landed at commit `aed9d3b` as forward-looking placeholder text pending this ADR's ratification — if Codex REJECTS this ADR and founder doesn't accept it, the ULTRAPLAN line 496 inline parenthetical reverts in the rollback commit; Status flips to Accepted on Codex RATIFIED verdict per §Status criteria below)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:15:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:19:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:23:(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract. Their v0 implementation in `validate.sh` is partial — `validate.sh` warns and emits `validate_check_skipped=true` when the voice-classifier URL is unreachable or the firm-domain whitelist is absent, rather than hard-failing; W4-polish closes these to hard-fail per `agents/recruitment/diagnostic/agent.md` §5 honesty note. These warn-only-paths exist in v0 but are not affected by this ADR; this ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:31:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:43:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **No warn-only paths in Gate A.** This satisfies Rule 4 (Quality gates before features) — Gate A is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted as "every section has at least one evidence link", consistent with the implementation.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:52:- Activates after voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:54:**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in ADR-008's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:64:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:68:> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (see ADR-008 when authored at W4).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:72:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:74:This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:81:- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:101:- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:106:- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:### W4-polish slice (after voice-classifier microservice ships + first pilot tenant data accumulates)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:119:- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:123:- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:124:- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:125:- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:148:- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:150:*End of ADR-006.*
agents/recruitment/diagnostic/validate.sh:6:# Status: Proposed (pre-W3-build scaffold; Day-12 author).
agents/recruitment/diagnostic/validate.sh:31:#   V3 — Section 12 voice classifier score ≥ 0.75
agents/recruitment/diagnostic/validate.sh:128:# V3 — §12 voice classifier ≥ 0.75
agents/recruitment/diagnostic/validate.sh:148:      _pass "V3: §12 voice classifier score=${SCORE} (≥ 0.75)"
agents/recruitment/diagnostic/validate.sh:150:      _fail "V3: §12 voice classifier score=${SCORE} (< 0.75)"
agents/recruitment/diagnostic/validate.sh:153:    _warn "V3: IFOS_VOICE_CLASSIFIER_URL unset; voice classification SKIPPED (W3 build wires this)"
agents/recruitment/diagnostic/validate.sh:227:  printf '\nValidate Gate A: \033[1;32mPASS\033[0m (warnings=%d)\n' "${#WARNINGS[@]}"
agents/recruitment/diagnostic/validate.sh:230:  printf '\nValidate Gate A: \033[1;31mFAIL\033[0m (%d failures, %d warnings)\n' \
agents/recruitment/diagnostic/validate.sh:236:  #     length, voice-classifier miss) → ESC_AGENT_OUTPUT_SHAPE (warn)
agents/recruitment/diagnostic/validate.sh:251:    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"
agents/recruitment/diagnostic/agent.md:3:**Status:** Proposed (Day-11 pre-W3-build draft; awaits Q1 LOI + Codex ratification at first render).
agents/recruitment/diagnostic/agent.md:16:> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A hard-fails on any section missing its citation. (Per-claim citation validation is a W4 polish item; the v0 contract requires per-section coverage as a tractable Gate-A check.) The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
agents/recruitment/diagnostic/agent.md:29:  --tenant <slug>                       # which tenant's target_patch + voice corpus to use
agents/recruitment/diagnostic/agent.md:60:| 12 | **Conversation opener** | 2-3 sentence cold outreach pitch. Tailored to surfaced pain signals (§8). Written in consultant's voice (voice-classified). Includes specific evidence anchor (e.g., "I noticed you've doubled engineering headcount in 6 months based on your LinkedIn — congrats on the Series A. Curious how you're handling sourcing pressure at that pace.") | LLM-generated; voice-classified against tenant style guide |
agents/recruitment/diagnostic/agent.md:66:- Section 12 (conversation opener) failing voice-classifier with score < 0.75
agents/recruitment/diagnostic/agent.md:77:   → context.sh hydrates: voice corpus + tone rules + recent edits + target_patch.json
agents/recruitment/diagnostic/agent.md:82:     tenant_slug present, voice corpus reachable
agents/recruitment/diagnostic/agent.md:83:   → Gate A: hard-fail if any check fails
agents/recruitment/diagnostic/agent.md:129:                 constraint = consultant voice (hh_load_voice_samples for top-5 ANN match);
agents/recruitment/diagnostic/agent.md:132:   → voice classifier scores the output against tenant style guide
agents/recruitment/diagnostic/agent.md:158:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces the following SPEC. **Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements most of these checks today but warns-only on two upstream-unavailable cases (voice-classifier URL unreachable, firm-domain whitelist absent). Hard-fail behaviour on those two cases is a W4 polish item; current v0 honesty-flags them in `decision_log` payload with `validate_check_skipped=true` instead of hard-failing. The spec below describes the W4-complete contract; the W4 build slice closes the two gaps.
agents/recruitment/diagnostic/agent.md:162:- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3) — **v0: warns + flags `validate_check_skipped=true` if voice-classifier URL unreachable; W4 polish closes to hard-fail**
agents/recruitment/diagnostic/agent.md:165:- No PII outside the firm boundary (regex pass for emails/phones that don't match `{firm}.com` or known director email patterns) — fires `ESC_PII_LEAKAGE_RISK` immediately on hit — **v0: warns + flags `validate_check_skipped=true` if firm-domain whitelist absent; W4 polish closes to hard-fail**
agents/recruitment/diagnostic/agent.md:181:| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:185:| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:198:Section 12 (conversation opener) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/diagnostic/agent.md:204:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: top-5 chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker). Feeds LLM prompt as voice exemplars.
agents/recruitment/diagnostic/agent.md:205:- **`hh_load_recent_edits` last 30 days for `concierge` + `diagnostic`**: surfaces patterns of how consultant edits agent drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly.
agents/recruitment/diagnostic/agent.md:207:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/diagnostic/agent.md:228:| 3 fixtures with golden outputs (01-primary + 02-edge-case-no-online-footprint + 99-voice-drift-canary) | Build at W3 start (~1 day) | ⏸ Not built |
agents/recruitment/diagnostic/agent.md:237:**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + W3 build slice start.
docs/decisions/v1.0-kill-criterion.md:3:**Status:** Proposed — pending Codex Day-7 ratification
docs/decisions/v1.0-kill-criterion.md:61:### Trigger 2 — DIAGNOSTIC-NO-RENDER-W3 (KILL)
docs/decisions/v1.0-kill-criterion.md:355:**Defined in Week 4+ once v1.0 has at least one pilot operational.** v1.1 kill criterion will incorporate v1.0 learnings + v1.1-specific triggers (e.g., wiki UI usability scores, voice classifier drift rates, LoRA training cost-per-tenant).
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.

exec
/bin/zsh -lc "sed -n '480,505p' docs/specs/ULTRAPLAN.md" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "sed -n '55,70p' docs/decisions/v1.0-kill-criterion.md" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
**Action:** PAUSE state activated immediately. Agent code halts at end of current week's slice (rather than mid-slice). Founder pivots to full-time design-partner acquisition. Claude Code work limited to design-partner-supporting artefacts (sales decks, demo agents, pricing models).

**Unfreeze criterion:** **One signed pilot LOI** from a UK recruitment agency with stated pilot start date in Q3 2026. Unfreeze formal: Founder + Jack joint sign-off on the LOI; resume v1.0 from the slice that was active when paused.

**Escalation path if PAUSE extends:** if unfreeze not achieved within 4 weeks of PAUSE activation, strategic review reconvenes. Outcomes: (a) continue PAUSE if pipeline is materially active; (b) escalate to KILL if no pipeline activity; (c) escalate to PIVOT if pipeline rejection signals point to a different vertical/ATS.

### Trigger 2 — DIAGNOSTIC-NO-RENDER-W3 (KILL)

**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)

**Owner:** Claude Code (technical detection); founder review (decision authority). Weekly check during Weeks 1-3.

**Source:** `sequencing-target.md` §6.6 failure condition (i); Risk #5 in `docs/RISK-REGISTER.md`; ADR-003 §"Consequences" line 141 (renderer is load-bearing Week-1 deliverable).

**Action:** KILL state. Rationale: the renderer architecture (ADR-003) was ratified in Week 0 Day 1 evening as the load-bearing Week-1 prerequisite. If Week 3 ends with no clean Diagnostic render, the renderer has fundamental gaps that the design did not anticipate. The renderer cannot be "patched"; v1.0 cannot ship without working render. Continuing into Weeks 4+ without resolution is sunk-cost reasoning.


 succeeded in 0ms:
Gate B target (restated from §7.2)
Build complexity (S / M / L / XL where S=2 days, M=1 week, L=2 weeks, XL=4 weeks)
Gotchas (the things that will bite us)
```

### 8.1 v1.0 agents (six)

#### A1. The Diagnostic — the sales tool

- **Build wave:** v1.0 (week 4–5)
- **Always-on?** No — invoked on demand
- **Trigger type:** Manual (run from CLI or sales-tool web page)
- **CortexOS primitives required:** None — runs as a one-shot batch job
- **MCP tools required:** Companies House, LinkedIn (read-only), web scraper for careers pages
- **Shared modules required:** Voice loader (uses Maddox's voice for the audit narrative), decision log writer
- **External APIs:** Companies House API (free), LinkedIn (via Proxycurl or similar), basic HTTP fetch
- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — Gate A = per-section hard-fail; per-claim quality signal is a separate post-launch metric outside Gate A)*
- **Gate B target:** ≥30% of diagnostics produced lead to a discovery call booked
- **Build complexity:** **M** (1 week)
- **Gotchas:** LinkedIn ToS — we cannot store profile data beyond the audit. Companies House rate limits — cache aggressively.

#### A2. The Janitor — the wedge agent

- **Build wave:** v1.0 (week 5–6)
- **Always-on?** Tier 2 — scheduled nightly cron
- **Trigger type:** Cron 02:00 UTC daily; manual full-cleanup on demand

codex
The first citation check already found a material mismatch: the ADR quotes the live ULTRAPLAN amendment differently from the file currently in the repo. I’m checking whether there are additional blocking issues so the rejection is complete rather than piecemeal.
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '492,498p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   492	- **CortexOS primitives required:** None — runs as a one-shot batch job
   493	- **MCP tools required:** Companies House, LinkedIn (read-only), web scraper for careers pages
   494	- **Shared modules required:** Voice loader (uses Maddox's voice for the audit narrative), decision log writer
   495	- **External APIs:** Companies House API (free), LinkedIn (via Proxycurl or similar), basic HTTP fetch
   496	- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — Gate A = per-section hard-fail; per-claim quality signal is a separate post-launch metric outside Gate A)*
   497	- **Gate B target:** ≥30% of diagnostics produced lead to a discovery call booked
   498	- **Build complexity:** **M** (1 week)

exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md | sed -n '1,155p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
     2	
     3	**Status:** Proposed (2026-05-24, Day 19; ULTRAPLAN in-band amendment landed at commit `aed9d3b` as forward-looking placeholder text pending this ADR's ratification — if Codex REJECTS this ADR and founder doesn't accept it, the ULTRAPLAN line 496 inline parenthetical reverts in the rollback commit; Status flips to Accepted on Codex RATIFIED verdict per §Status criteria below)
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
    43	Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **No warn-only paths in Gate A.** This satisfies Rule 4 (Quality gates before features) — Gate A is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted as "every section has at least one evidence link", consistent with the implementation.
    44	
    45	### Decision 2 — Per-claim citation validation is a SEPARATE post-launch quality metric (NOT Gate A)
    46	
    47	The per-claim citation pipeline (NLP claim-extraction + per-claim evidence-link matching + aggregate quality metric) is **explicitly outside Gate A** in v1.0. It lands as:
    48	
    49	- A separate post-launch Diagnostic quality signal — analogous to Gate B's outcome threshold (30% discovery-call conversion) but for citation quality
    50	- Authored as a separate W4 ADR (e.g. ADR-008 "Diagnostic per-claim citation quality metric") together with the schema supplements that define its payload key + per-tenant config field
    51	- Sampling-based (1-in-N) post-launch quality monitoring; warn-level; never blocks v0 sends
    52	- Activates after voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports
    53	
    54	**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in ADR-008's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
    55	
    56	**Rule 4 (Quality gates before features) satisfied:** Gate A is exclusively hard-fail; nothing in Gate A is warn-only. Per-claim quality is a separate signal, not a weakening of Gate A.
    57	
    58	---
    59	
    60	## ULTRAPLAN amendment
    61	
    62	`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):
    63	
    64	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
    65	
    66	After this ADR ratifies, the canonical interpretation is:
    67	
    68	> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (see ADR-008 when authored at W4).
    69	
    70	**In-band amendment (landed in commit `aed9d3b`):** `docs/specs/ULTRAPLAN.md` line 496 now reads verbatim:
    71	
    72	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish)*
    73	
    74	This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
    75	
    76	---
    77	
    78	## Why hybrid not full-spec
    79	
    80	**Why not (a) defer launch until per-claim lands?**
    81	- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
    82	- A working v0 with per-section validation has measurable Gate A coverage; deferring means no Gate A at all in the meantime, which is strictly worse
    83	- The 30%-discovery-call Gate B target is independent of per-claim validation; pilot value is reachable without it
    84	
    85	**Why not (c) amend ULTRAPLAN downward permanently?**
    86	- The per-claim requirement is genuinely valuable for v1.1+ once the NLP pipeline exists
    87	- Permanently removing it from ULTRAPLAN loses the documented quality bar
    88	- Hybrid preserves the W4-polish path; permanent amendment closes that door
    89	
    90	**Why hybrid is honest signal (Rule 5):**
    91	- v0 implementation does what it says; W4 polish path is documented + scheduled
    92	- Codex flags become explicit-disposition references (this ADR) not unaddressed weakening
    93	- Pilot tenants reading Gate A spec see the v0 contract clearly + the W4 expansion plan
    94	
    95	---
    96	
    97	## Consequences
    98	
    99	### Immediate (this ADR commit)
   100	
   101	- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
   102	- `agents/recruitment/diagnostic/validate.sh` retains current per-section enforcement (no implementation change)
   103	
   104	### Next commit (after this ADR ratifies)
   105	
   106	- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
   107	- `docs/decisions/2026-05-18-codex-ratification-manifest.md` queue updated to include this ADR. NOT yet updated as of this commit; lands in the post-ratify commit.
   108	
   109	### After Codex ratifies this ADR (Status flips Proposed → Accepted)
   110	
   111	- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the original ULTRAPLAN line 496 prose alone)
   112	- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (ADR-007 Janitor Gate A, ADR-008 Scribe Gate A, etc.) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
   113	
   114	### W4-polish slice (after voice-classifier microservice ships + first pilot tenant data accumulates)
   115	
   116	- Per-claim spot-check pipeline lands as Tier 2 validate.sh extension
   117	- Sample rate configurable per tenant via field landing in v0.3 vertical-schema supplement (concrete field name + type specified there, not in this ADR)
   118	- Aggregate metric writes to `decision_log.payload` via key landing in autosend-safety-policy §7 supplement (concrete key name specified there, not in this ADR)
   119	- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
   120	
   121	### Downstream artefact references (queued for post-ratify commit)
   122	
   123	- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
   124	- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
   125	- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
   126	- `docs/decisions/2026-05-18-codex-ratification-manifest.md` → adds this ADR as ratification queue item
   127	
   128	These edits all land in the next commit AFTER this ADR ratifies (no point updating agent.md to cite a Proposed ADR; cite once ratified).
   129	
   130	---
   131	
   132	## Open questions
   133	
   134	| # | Question | Resolution path |
   135	|---|---|---|
   136	| Q1 | Default sample rate for Tier 2 spot-check? Recommend 1-in-10 (~10% of reports validated per-claim) for first pilot; adjust based on early signal | Founder review at first-pilot W4 polish landing |
   137	| Q2 | NLP claim-extraction library — what's the right tool? (spaCy + custom rules / Claude API-based extraction / hosted service) | W4 polish technical investigation; cost vs accuracy tradeoff |
   138	| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |
   139	
   140	---
   141	
   142	## Status
   143	
   144	**Proposed.** Awaits Codex ratification via `review-architecture-decision.md` skill.
   145	
   146	Status flips Proposed → Accepted when:
   147	- Codex returns RATIFIED for this ADR
   148	- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
   149	
   150	*End of ADR-006.*

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/validate.sh | sed -n '128,170p' && nl -ba agents/recruitment/diagnostic/validate.sh | sed -n '210,255p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   128	# V3 — §12 voice classifier ≥ 0.75
   129	# ────────────────────────────────────────────────────────────────────────
   130	
   131	# Extract §12 (conversation opener)
   132	SECTION_12=$(awk '/^## .*[Cc]onversation [Oo]pener/{flag=1; next} /^## /{flag=0} flag' "${DRAFT}")
   133	
   134	if [[ -z "${SECTION_12}" ]]; then
   135	  _fail "V3: §12 (Conversation opener) section not found or empty"
   136	else
   137	  # Voice classifier microservice call (W3 build wires this up)
   138	  # For scaffold: assume IFOS_VOICE_CLASSIFIER_URL set; fail gracefully if not
   139	  if [[ -n "${IFOS_VOICE_CLASSIFIER_URL:-}" ]]; then
   140	    SCORE=$(curl -sS -X POST "${IFOS_VOICE_CLASSIFIER_URL}/classify" \
   141	      -H "Content-Type: application/json" \
   142	      -d "$(printf '{"text":%s,"tenant_slug":"%s"}' \
   143	        "$(printf '%s' "${SECTION_12}" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))")" \
   144	        "${CTX_TENANT_SLUG}")" \
   145	      2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('score', 0))" 2>/dev/null || echo "0")
   146	
   147	    if [[ -n "${SCORE}" ]] && python3 -c "import sys; sys.exit(0 if float('${SCORE}') >= 0.75 else 1)" 2>/dev/null; then
   148	      _pass "V3: §12 voice classifier score=${SCORE} (≥ 0.75)"
   149	    else
   150	      _fail "V3: §12 voice classifier score=${SCORE} (< 0.75)"
   151	    fi
   152	  else
   153	    _warn "V3: IFOS_VOICE_CLASSIFIER_URL unset; voice classification SKIPPED (W3 build wires this)"
   154	  fi
   155	fi
   156	
   157	# ────────────────────────────────────────────────────────────────────────
   158	# V4 — Length 400-2000 words
   159	# ────────────────────────────────────────────────────────────────────────
   160	
   161	WORD_COUNT=$(wc -w < "${DRAFT}" | tr -d ' ')
   162	if (( WORD_COUNT >= 400 && WORD_COUNT <= 2000 )); then
   163	  _pass "V4: word count=${WORD_COUNT} (400-2000)"
   164	elif (( WORD_COUNT < 400 )); then
   165	  _fail "V4: report too short (${WORD_COUNT} words; min 400)"
   166	else
   167	  _fail "V4: report too long (${WORD_COUNT} words; max 2000)"
   168	fi
   169	
   170	# ────────────────────────────────────────────────────────────────────────
   210	# Find all emails in the report
   211	ALL_EMAILS=$(grep -oE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "${DRAFT}" | sort -u || echo "")
   212	
   213	# This is a coarse check — true PII boundary requires firm-domain enumeration
   214	# at W3 build. For scaffold: warn if any email present (rather than fail)
   215	# since we don't yet have the firm-domain whitelist mechanism.
   216	if [[ -n "${ALL_EMAILS}" ]]; then
   217	  _warn "V6: emails present in report (verify they belong to ${FIRM_NAME}): $(echo "${ALL_EMAILS}" | tr '\n' ' ')"
   218	else
   219	  _pass "V6: no emails embedded (firm-boundary PII check trivially passes)"
   220	fi
   221	
   222	# ────────────────────────────────────────────────────────────────────────
   223	# Verdict + escalation emission
   224	# ────────────────────────────────────────────────────────────────────────
   225	
   226	if (( ${#FAILURES[@]} == 0 )); then
   227	  printf '\nValidate Gate A: \033[1;32mPASS\033[0m (warnings=%d)\n' "${#WARNINGS[@]}"
   228	  exit 0
   229	else
   230	  printf '\nValidate Gate A: \033[1;31mFAIL\033[0m (%d failures, %d warnings)\n' \
   231	    "${#FAILURES[@]}" "${#WARNINGS[@]}"
   232	
   233	  # Emit the specific ESC code per agent.md §6 mapping:
   234	  #   - PII detected outside firm boundary → ESC_PII_LEAKAGE_RISK (blocking)
   235	  #   - Output-shape violation (section count, per-section citation,
   236	  #     length, voice-classifier miss) → ESC_AGENT_OUTPUT_SHAPE (warn)
   237	  # ESC_SCHEMA_VIOLATION is reserved for vertical-schema field-constraint
   238	  # violations at write time per catalogue line 163 — not for Diagnostic's
   239	  # output-shape failures.
   240	  PII_FAILURE_PRESENT=0
   241	  for failure in "${FAILURES[@]}"; do
   242	    if [[ "${failure}" == *"PII"* || "${failure}" == *"pii"* ]]; then
   243	      PII_FAILURE_PRESENT=1
   244	      break
   245	    fi
   246	  done
   247	
   248	  if (( PII_FAILURE_PRESENT == 1 )); then
   249	    ESC_CODE="ESC_PII_LEAKAGE_RISK"
   250	  else
   251	    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"
   252	  fi
   253	
   254	  ESC_PAYLOAD=$(printf '{"escalation_code":"%s","draft_path":"%s","failures":%s}' \
   255	    "${ESC_CODE}" \

exec
/bin/zsh -lc 'git show --stat --oneline --no-renames aed9d3b -- docs/specs/ULTRAPLAN.md docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
aed9d3b fix(ADR-006-r2): apply Codex R2 3 findings + ULTRAPLAN in-band amendment
 docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md | 6 +++---
 docs/specs/ULTRAPLAN.md                            | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

codex
REJECTED

1. ULTRAPLAN line 496 is quoted inaccurately. ADR-006 lines 17-19 and 70-72 claim the live text says `"for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish"`, but `docs/specs/ULTRAPLAN.md` line 496 actually says `"Gate A = per-section hard-fail; per-claim quality signal is a separate post-launch metric outside Gate A"`. Fix the quoted live amendment to match ULTRAPLAN verbatim.

2. The ADR overclaims that Gate A has no warn-only paths. ADR-006 line 23 admits v0 Gate A warns on missing voice-classifier URL and absent firm-domain whitelist, while lines 43 and 56 state `"No warn-only paths in Gate A"` and `"nothing in Gate A is warn-only"`; `agents/recruitment/diagnostic/validate.sh` confirms warnings still exit PASS at lines 153, 217, and 226-228. Fix by scoping the hard-fail claim to the per-section citation subcheck, or make the cited Gate A checks hard-fail before ratification.

3. Future ADR numbering is internally inconsistent. ADR-006 line 50 says the Diagnostic per-claim quality metric will be authored as ADR-008, but line 112 says ADR-008 may be the Scribe Gate A ADR. This breaks ADR sequencing/planning clarity for downstream artefacts. Fix by not assigning future ADR numbers here, or reserve unique numbers consistently.
tokens used
19,651
REJECTED

1. ULTRAPLAN line 496 is quoted inaccurately. ADR-006 lines 17-19 and 70-72 claim the live text says `"for two-tier framing — per-section hard-fail at v0; per-claim spot-check at W4 polish"`, but `docs/specs/ULTRAPLAN.md` line 496 actually says `"Gate A = per-section hard-fail; per-claim quality signal is a separate post-launch metric outside Gate A"`. Fix the quoted live amendment to match ULTRAPLAN verbatim.

2. The ADR overclaims that Gate A has no warn-only paths. ADR-006 line 23 admits v0 Gate A warns on missing voice-classifier URL and absent firm-domain whitelist, while lines 43 and 56 state `"No warn-only paths in Gate A"` and `"nothing in Gate A is warn-only"`; `agents/recruitment/diagnostic/validate.sh` confirms warnings still exit PASS at lines 153, 217, and 226-228. Fix by scoping the hard-fail claim to the per-section citation subcheck, or make the cited Gate A checks hard-fail before ratification.

3. Future ADR numbering is internally inconsistent. ADR-006 line 50 says the Diagnostic per-claim quality metric will be authored as ADR-008, but line 112 says ADR-008 may be the Scribe Gate A ADR. This breaks ADR sequencing/planning clarity for downstream artefacts. Fix by not assigning future ADR numbers here, or reserve unique numbers consistently.
