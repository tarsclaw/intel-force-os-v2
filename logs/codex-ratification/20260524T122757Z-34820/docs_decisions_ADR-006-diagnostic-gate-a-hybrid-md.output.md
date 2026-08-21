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
session id: 019e59f4-d326-7970-8c0e-79216b8503dd
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

**Status:** Proposed (2026-05-24, Day 19; ULTRAPLAN in-band amendment landed at commit `aed9d3b` as forward-looking placeholder text pending this ADR's ratification — if Codex REJECTS and founder doesn't accept, the ULTRAPLAN line 496 inline parenthetical reverts in the rollback commit; Status flips to Accepted when BOTH (a) Codex RATIFIED verdict AND (b) Diagnostic agent.md §1 + §5 explicitly cite ADR-006 — both conditions per §Status criteria below)
**Author:** Founder (Maddox) + Claude Code
**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR

---

## Context

ULTRAPLAN §8.1 A1 line 496 (pre-amendment wording — before this ADR's in-band edit landed in commit `aed9d3b`):

> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data

Current line 496 (post-amendment; live as of commit `aed9d3b`):

> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*

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

Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.

The OTHER Gate A subchecks (voice classifier ≥ 0.75 and PII boundary) have v0 warn-only paths when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these are honesty-flagged with `validate_check_skipped=true` per the Context section above. W4-polish closes those subchecks to hard-fail. This ADR addresses only the per-section citation subcheck of Gate A; it does NOT modify the voice classifier or PII subchecks.

### Decision 2 — Per-claim citation validation is a SEPARATE post-launch quality metric (NOT Gate A)

The per-claim citation pipeline (NLP claim-extraction + per-claim evidence-link matching + aggregate quality metric) is **explicitly outside Gate A** in v1.0. It lands as:

- A separate post-launch Diagnostic quality signal — analogous to Gate B's outcome threshold (30% discovery-call conversion) but for citation quality
- Authored as a separate W4 ADR (number to be assigned at W4-polish authoring time; this ADR does NOT pre-assign a number) together with the schema supplements that define its payload key + per-tenant config field
- Sampling-based (1-in-N) post-launch quality monitoring; warn-level; never blocks v0 sends
- Activates after voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports

**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.

**Rule 4 (Quality gates before features) satisfied for the per-section citation subcheck:** it is hard-fail at v0 with no warn-only paths. (Other Gate A subchecks — voice classifier + PII — retain v0 warn-only paths when upstream services are unreachable per Context note; W4-polish closes those. ADR-006 addresses only the per-section subcheck.) Per-claim quality is a separate signal, not a weakening of Gate A's per-section subcheck.

---

## ULTRAPLAN amendment

`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):

> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data

After this ADR ratifies, the canonical interpretation is:

> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — per-section citation subcheck is hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (a W4 ADR to be authored at first-pilot polish time).

**In-band amendment (landed in commit `aed9d3b`):** `docs/specs/ULTRAPLAN.md` line 496 now reads verbatim:

> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*

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
- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed

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
I’ll verify the ADR against the live files it cites, especially ULTRAPLAN line 496, the kill criterion trigger, existing ADR numbering, and the diagnostic validator/agent references before issuing the ratification verdict.
exec
/bin/zsh -lc "nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '55,70p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/validate.sh | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# shellcheck disable=SC2155
     3	#
     4	# Diagnostic agent — validate.sh (Gate A enforcement)
     5	#
     6	# Status: Proposed (pre-W3-build scaffold; Day-12 author).
     7	# Reading order: agent.md §5 (Gates) + §6 (Escalation codes) first.
     8	#
     9	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
    10	# is the hard-fail gate that runs AFTER cycle.sh produces a draft report
    11	# but BEFORE the vault write + operator notify. If any check fails,
    12	# validate.sh exits non-zero and emits an ESC_* escalation row to
    13	# decision_log; the report does NOT land in the vault.
    14	#
    15	# Invocation contract:
    16	#   bash validate.sh <draft_report_path>
    17	#
    18	# Inputs:
    19	#   - $1: path to the draft Markdown report (cycle.sh writes it to /tmp first)
    20	#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_VOICE_CORPUS_ID,
    21	#          CTX_TONE_RULES (json string)
    22	#
    23	# Exit codes:
    24	#   0  All Gate A checks pass; cycle.sh proceeds to vault write
    25	#   1  At least one check failed; ESC_* row emitted; cycle.sh aborts
    26	#   2  validate.sh invocation error (bad args, missing draft, etc.)
    27	#
    28	# Checks (per agent.md §5 Gate A):
    29	#   V1 — All 12 sections present (count + heading regex)
    30	#   V2 — Each section has ≥1 markdown link (regex)
    31	#   V3 — Section 12 voice classifier score ≥ 0.75
    32	#   V4 — Report length 400-2000 words
    33	#   V5 — No banned phrases per tone_rule table
    34	#   V6 — No PII outside firm boundary (regex pass)
    35	
    36	set -uo pipefail
    37	
    38	# ────────────────────────────────────────────────────────────────────────
    39	# Pre-flight
    40	# ────────────────────────────────────────────────────────────────────────
    41	
    42	if [[ $# -lt 1 ]]; then
    43	  printf 'validate.sh: usage: validate.sh <draft_report_path>\n' >&2
    44	  exit 2
    45	fi
    46	
    47	readonly DRAFT="$1"
    48	
    49	if [[ ! -f "${DRAFT}" ]]; then
    50	  printf 'validate.sh: draft not found at %s\n' "${DRAFT}" >&2
    51	  exit 2
    52	fi
    53	
    54	if [[ -z "${CTX_TENANT_SLUG:-}" || -z "${CTX_AGENT_NAME:-}" ]]; then
    55	  printf 'validate.sh: CTX_TENANT_SLUG or CTX_AGENT_NAME unset\n' >&2
    56	  exit 2
    57	fi
    58	
    59	# Source helpers for escalation emission
    60	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    61	  printf 'validate.sh: CTX_AGENT_DIR unset\n' >&2
    62	  exit 2
    63	fi
    64	# shellcheck source=/dev/null
    65	source "${CTX_AGENT_DIR}/.claude/hooks/_shared/hook-helpers.sh"
    66	
    67	# Track failures across all checks; collect all before exit (richer audit)
    68	declare -a FAILURES=()
    69	declare -a WARNINGS=()
    70	
    71	_fail() {
    72	  FAILURES+=("$1")
    73	  printf '  ✗ %s\n' "$1" >&2
    74	}
    75	
    76	_pass() {
    77	  printf '  ✓ %s\n' "$1"
    78	}
    79	
    80	_warn() {
    81	  WARNINGS+=("$1")
    82	  printf '  ! %s\n' "$1" >&2
    83	}
    84	
    85	# ────────────────────────────────────────────────────────────────────────
    86	# V1 — 12 sections present
    87	# ────────────────────────────────────────────────────────────────────────
    88	
    89	# Section labels documented for reference; not currently regex-matched
    90	# individually because count + per-section citation check covers V1+V2.
    91	# At W3 build: tighten to enforce exact-heading match per EXPECTED_SECTIONS.
    92	SECTION_COUNT=$(grep -cE '^##[[:space:]]' "${DRAFT}" || echo 0)
    93	if (( SECTION_COUNT == 12 )); then
    94	  _pass "V1: 12 sections present"
    95	else
    96	  _fail "V1: expected 12 sections, found ${SECTION_COUNT}"
    97	fi
    98	
    99	# ────────────────────────────────────────────────────────────────────────
   100	# V2 — Each section has ≥1 markdown link
   101	# ────────────────────────────────────────────────────────────────────────
   102	
   103	# Per-section citation check: single awk pass tracks current section
   104	# index, sets has_link[i]=1 when a Markdown link is found within a
   105	# section's body, then prints the indices of sections with no link.
   106	MISSING_INDICES=$(awk '
   107	  /^## / { sec_num++; next }
   108	  sec_num > 0 && /\[[^]]+\]\([^)]+\)/ { has_link[sec_num]=1 }
   109	  END {
   110	    for (i=1; i<=sec_num; i++) {
   111	      if (!has_link[i]) printf "%d ", i
   112	    }
   113	  }
   114	' "${DRAFT}")
   115	
   116	MISSING_CITATION=()
   117	for idx in ${MISSING_INDICES}; do
   118	  MISSING_CITATION+=("section ${idx}")
   119	done
   120	
   121	if (( ${#MISSING_CITATION[@]} == 0 )); then
   122	  _pass "V2: every section has ≥1 citation link"
   123	else
   124	  _fail "V2: missing citation in: ${MISSING_CITATION[*]}"
   125	fi
   126	
   127	# ────────────────────────────────────────────────────────────────────────
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
   171	# V5 — Banned phrases per tone_rule
   172	# ────────────────────────────────────────────────────────────────────────
   173	
   174	if [[ -n "${CTX_TONE_RULES:-}" ]]; then
   175	  BANNED_HITS=$(printf '%s' "${CTX_TONE_RULES}" | python3 -c "
   176	import json, sys, re
   177	data = json.loads(sys.stdin.read() or '{}')
   178	rules = data.get('rules', [])
   179	with open('${DRAFT}', 'r') as f:
   180	    text = f.read()
   181	hits = []
   182	for r in rules:
   183	    if r.get('severity') == 'block':
   184	        for phrase in r.get('examples_negative', []):
   185	            if phrase and phrase.lower() in text.lower():
   186	                hits.append(f\"rule={r.get('rule_id')} phrase='{phrase}'\")
   187	print('|'.join(hits))
   188	" 2>/dev/null || echo "")
   189	
   190	  if [[ -z "${BANNED_HITS}" ]]; then
   191	    _pass "V5: no banned phrases detected"
   192	  else
   193	    _fail "V5: banned phrases detected: ${BANNED_HITS}"
   194	  fi
   195	else
   196	  _warn "V5: CTX_TONE_RULES empty; banned-phrase check skipped"
   197	fi
   198	
   199	# ────────────────────────────────────────────────────────────────────────
   200	# V6 — No PII outside firm boundary
   201	# ────────────────────────────────────────────────────────────────────────
   202	#
   203	# Detect emails/phones in the report that DON'T belong to the firm being
   204	# diagnosed. Simple regex pass; production W3 build adds NER pass.
   205	
   206	FIRM_NAME="${IFOS_DIAGNOSTIC_FIRM_NAME:-unknown}"
   207	# At W3 build: extract firm domain from Companies House link to scope
   208	# the PII-boundary check. Stub for scaffold.
   209	
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
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '485,505p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc 'rg --files docs/decisions docs/specs agents/recruitment/diagnostic | sort' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
docs/decisions/2026-05-18-codex-ratification-manifest.md
docs/decisions/2026-05-18-day-7-single-sentence-test.md
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md
docs/decisions/README.md
docs/decisions/autosend-approval-bridge-spec.md
docs/decisions/autosend-safety-policy.md
docs/decisions/brain-ui-scope.md
docs/decisions/bullhorn-integration-path.md
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/decisions/sequencing-target.md
docs/decisions/v1.0-kill-criterion.md
docs/specs/PRODUCT-SPEC.md
docs/specs/ULTRAPLAN.md
docs/specs/_archive-build-handoff.md

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/validate.sh | sed -n '240,320p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   256	    "${DRAFT}" \
   257	    "$(printf '%s\n' "${FAILURES[@]}" | python3 -c "import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))" 2>/dev/null || echo '[]')")
   258	
   259	  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \
   260	    "$(echo "${ESC_PAYLOAD}" | shasum | awk '{print $1}')" \
   261	    "${ESC_PAYLOAD}" 2>/dev/null || true
   262	
   263	  exit 1
   264	fi

 succeeded in 0ms:
     1	# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
     2	
     3	**Status:** Proposed (2026-05-24, Day 19; ULTRAPLAN in-band amendment landed at commit `aed9d3b` as forward-looking placeholder text pending this ADR's ratification — if Codex REJECTS and founder doesn't accept, the ULTRAPLAN line 496 inline parenthetical reverts in the rollback commit; Status flips to Accepted when BOTH (a) Codex RATIFIED verdict AND (b) Diagnostic agent.md §1 + §5 explicitly cite ADR-006 — both conditions per §Status criteria below)
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
   119	- Sample rate configurable per tenant via field landing in v0.3 vertical-schema supplement (concrete field name + type specified there, not in this ADR)
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
/bin/zsh -lc 'rg -n "''^# ADR-|''^### Decision|Alternatives|## Consequences|## Context|## Decision|Status" docs/decisions/ADR-00*.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:1:# ADR-005 — Week-3 Diagnostic acceleration (Bullhorn MCP deferred)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:3:**Status:** Accepted (2026-05-24, Day 13)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:11:## Context
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:33:## Decision
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:54:## Consequences
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:90:| Step | Status | Commit |
docs/decisions/ADR-004-renderer-implementation-deviations.md:1:# ADR-004 — Renderer implementation deviations from ADR-003
docs/decisions/ADR-004-renderer-implementation-deviations.md:8:**Status:** Proposed
docs/decisions/ADR-004-renderer-implementation-deviations.md:12:## Context
docs/decisions/ADR-004-renderer-implementation-deviations.md:22:## Decision
docs/decisions/ADR-004-renderer-implementation-deviations.md:24:### Decision 1 — Standalone `ifos-render-agent` Node binary, NOT `cortextos-ifos render-agent` subcommand
docs/decisions/ADR-004-renderer-implementation-deviations.md:44:### Decision 2 — Symlink target is `../../../_shared`, not `../../_shared`
docs/decisions/ADR-004-renderer-implementation-deviations.md:70:### Decision 3 — `_shared/` listed as phantom agent in `cortextos-ifos list-agents` is accepted as upstream concern
docs/decisions/ADR-004-renderer-implementation-deviations.md:142:## Consequences
docs/decisions/ADR-004-renderer-implementation-deviations.md:156:## Status
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:1:# ADR-002 — Brain system as parallel, not shadow
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:7:**Status:** Accepted — Option α. Founder decision logged 2026-05-16.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:11:## Context
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:23:## Decision
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:25:### Decision 1 — Brain system is parallel to cortextOS, not shadowed
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:31:### Decision 2 — Interface is Option α (shell wrappers at `packages/brain/bus-overrides/wiki-*.sh`)
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:60:### Decision 3 — Storage substrate per `second-brain-design.md` §2.4
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:67:### Decision 4 — v1.2+ semantic-search-over-raw hook is left open
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:107:## Consequences
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:129:## Status
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:133:1. ADR-001 + ADR-002 master-brief edits LANDED in atomic-correction commit `0e5b2b4` (Day 7 2026-05-20). Status: closed.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:1:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Proposed (2026-05-24, Day 19; ULTRAPLAN in-band amendment landed at commit `aed9d3b` as forward-looking placeholder text pending this ADR's ratification — if Codex REJECTS and founder doesn't accept, the ULTRAPLAN line 496 inline parenthetical reverts in the rollback commit; Status flips to Accepted when BOTH (a) Codex RATIFIED verdict AND (b) Diagnostic agent.md §1 + §5 explicitly cite ADR-006 — both conditions per §Status criteria below)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:11:## Context
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:39:## Decision
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:41:### Decision 1 — Diagnostic Gate A citation validation is per-section coverage ONLY (hard-fail)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:47:### Decision 2 — Per-claim citation validation is a SEPARATE post-launch quality metric (NOT Gate A)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:99:## Consequences
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:111:### After Codex ratifies this ADR (Status flips Proposed → Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:144:## Status
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:148:Status flips Proposed → Accepted when:
docs/decisions/ADR-003-agent-bundle-renderer.md:1:# ADR-003 — Agent Bundle v2 renderer
docs/decisions/ADR-003-agent-bundle-renderer.md:7:**Status:** Accepted. Founder decision logged 2026-05-16.
docs/decisions/ADR-003-agent-bundle-renderer.md:11:## Context
docs/decisions/ADR-003-agent-bundle-renderer.md:19:## Decision
docs/decisions/ADR-003-agent-bundle-renderer.md:21:### Decision 1 — Renderer is a new command, not a wrapper around `cortextos-ifos add-agent`
docs/decisions/ADR-003-agent-bundle-renderer.md:29:### Decision 2 — Renderer lives at `packages/agent-renderer/`
docs/decisions/ADR-003-agent-bundle-renderer.md:43:### Decision 3 — Translation contract per design §2.1
docs/decisions/ADR-003-agent-bundle-renderer.md:56:### Decision 4 — Re-render policy: overwrite, no merge
docs/decisions/ADR-003-agent-bundle-renderer.md:141:## Consequences
docs/decisions/ADR-003-agent-bundle-renderer.md:159:## Status
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:1:# ADR-001 — Bus dispatcher is poll-based, not chokidar-watched
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:7:**Status:** Accepted — Option A. Founder decision logged 2026-05-16.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:11:## Context
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:28:## Decision
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:55:## Consequences
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:74:## Status

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/agent.md | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
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

codex
The live validator confirms the per-section citation check is hard-fail, but I’m seeing a mismatch around the claimed `validate_check_skipped=true` signalling. I’m checking the supporting decision/disagreement and escalation references now so the final verdict cites only load-bearing defects.
exec
/bin/zsh -lc 'rg -n "ESC_AGENT_OUTPUT_SHAPE|ESC_PII_LEAKAGE_RISK|ESC_VOICE_DRIFT|ESC_INPUT_VALIDATION_FAIL" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
120:#### `ESC_VOICE_DRIFT`
148:#### `ESC_PII_LEAKAGE_RISK`
170:#### `ESC_VOICE_DRIFT_TENANT`
172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`

exec
/bin/zsh -lc 'rg -n "validate_check_skipped|Round 9|Diagnostic finding #1|Phase 4|Cat-ζ|ADR-006|Cat-1|Cat-5" docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md agents/recruitment/diagnostic/validate.sh agents/recruitment/diagnostic/agent.md docs/decisions/autosend-safety-policy.md agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/autosend-safety-policy.md:604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:256:- Cat-1 (Gate A hybrid): Diagnostic §1 verified already correct
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:260:- Cat-5 (§5 honesty): 5 pre-build scaffolds gained explicit "validate.sh does NOT exist yet — W-X build slice delivers this contract" framing; Diagnostic gained warn-only-paths honesty note
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:336:**Backlog landing items (queue Codex Round 9 ONLY after these land):**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:348:## Phase 4 — Cat-γ widening + Cat-δ Diagnostic polish + Round 9 (2026-05-24, founder "proceed" instruction)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:366:### Round 9 verdict — 30 findings (down from Round 8's 32; net −2)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:380:### Round 9 finding samples (illustrative, not exhaustive)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:383:1. Gate A per-claim vs per-section: STILL flagged despite Cat-1 hybrid disposition; this is a Codex–founder disagreement, not relitigation of Cat-1 (founder's hybrid stance documented but Codex doesn't accept the bilateral-disposition framing as an in-band acceptance of weakening). **Disposition: founder-decision; flagged as Cat-ζ "Cat-1 framing not auto-accepted by Codex".**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:396:### Cat-ζ — new category surfaced by Round 9
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:398:**Cat-ζ — Codex does not accept bilateral-disposition framings as in-band Gate A acceptances.**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:400:When founder authorizes a Cat-1 hybrid disposition (per-section v0 + per-claim W4), the agent.md prose explicitly documents this. Codex re-flags it as "Gate A weakens upstream requirement" regardless. This is structural — Codex reviews agent.md against ULTRAPLAN/master brief, and bilateral disposition documents at `docs/decisions/codex-disagreement-*.md` are downstream artefacts Codex doesn't auto-trust.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:405:- **C) Document as permanent Cat-ζ disagreement** — accept that Codex will continue flagging this; rely on the disagreement doc as the founder-authority record.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:407:**Recommended: B (ADR-006).** Closes the disagreement properly; gives Cat-1 a ratified architectural home; future-proofs against Cat-1 re-litigation. ~1 hour Claude work + 1 Codex round to ratify the ADR.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:411:The pattern (Round 4 → Round 9; 10 rounds; 75+ unique findings; ~10% net convergence per round) empirically confirms master brief §10.3 step 5. Each remediation pass surfaces new issues at roughly the same rate it closes old ones — because the document keeps changing.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:413:**Stopping condition met:** founder's "proceed" → Cat-γ widening + Cat-δ Diagnostic polish + Round 9 + this categorization is the conclusive "RATIFY-or-document-disagreement" outcome per the bilateral disposition. No further autonomous remediation will be attempted.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:422:**Per-agent state at Phase 4 close:**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:424:| Agent | Status | Round 9 findings | Path to RATIFIED |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*
agents/recruitment/diagnostic/agent.md:158:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces the following SPEC. **Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements most of these checks today but warns-only on two upstream-unavailable cases (voice-classifier URL unreachable, firm-domain whitelist absent). Hard-fail behaviour on those two cases is a W4 polish item; current v0 honesty-flags them in `decision_log` payload with `validate_check_skipped=true` instead of hard-failing. The spec below describes the W4-complete contract; the W4 build slice closes the two gaps.
agents/recruitment/diagnostic/agent.md:162:- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3) — **v0: warns + flags `validate_check_skipped=true` if voice-classifier URL unreachable; W4 polish closes to hard-fail**
agents/recruitment/diagnostic/agent.md:165:- No PII outside the firm boundary (regex pass for emails/phones that don't match `{firm}.com` or known director email patterns) — fires `ESC_PII_LEAKAGE_RISK` immediately on hit — **v0: warns + flags `validate_check_skipped=true` if firm-domain whitelist absent; W4 polish closes to hard-fail**

exec
/bin/zsh -lc 'git show --stat --oneline --no-renames aed9d3b -- docs/specs/ULTRAPLAN.md docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
aed9d3b fix(ADR-006-r2): apply Codex R2 3 findings + ULTRAPLAN in-band amendment
 docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md | 6 +++---
 docs/specs/ULTRAPLAN.md                            | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

exec
/bin/zsh -lc 'git show --stat --oneline --no-renames 1f8c92f -- docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
1f8c92f decision(codex-r9): Phase 4 + Cat-ζ surfaced + final stop per §10.3 step 5
 ...ex-disagreement-2026-05-24-diagnostic-gate-a.md | 91 +++++++++++++++++++++-
 1 file changed, 90 insertions(+), 1 deletion(-)

exec
/bin/zsh -lc "rg -n \"§5\\.3|voice classifier|voice-classifier|classifier\" docs/specs/ULTRAPLAN.md docs/specs/PRODUCT-SPEC.md docs/MASTER* docs/*.md" in /Users/madsadmin/code/CortexOS
 exited 1 in 0ms:
zsh:1: no matches found: docs/MASTER*

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '176,200p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "git grep -n \"hh_decision_.*validate\\|validate_gate_a\\|WARNINGS\\|validate_check\" agents/_shared agents/recruitment/diagnostic packages | head -80" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/diagnostic/agent.md:158:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces the following SPEC. **Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements most of these checks today but warns-only on two upstream-unavailable cases (voice-classifier URL unreachable, firm-domain whitelist absent). Hard-fail behaviour on those two cases is a W4 polish item; current v0 honesty-flags them in `decision_log` payload with `validate_check_skipped=true` instead of hard-failing. The spec below describes the W4-complete contract; the W4 build slice closes the two gaps.
agents/recruitment/diagnostic/agent.md:162:- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3) — **v0: warns + flags `validate_check_skipped=true` if voice-classifier URL unreachable; W4 polish closes to hard-fail**
agents/recruitment/diagnostic/agent.md:165:- No PII outside the firm boundary (regex pass for emails/phones that don't match `{firm}.com` or known director email patterns) — fires `ESC_PII_LEAKAGE_RISK` immediately on hit — **v0: warns + flags `validate_check_skipped=true` if firm-domain whitelist absent; W4 polish closes to hard-fail**
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:78:  decision_log_rows_min: 4  # trigger + output + validate_gate_a_fail action + cleanup
agents/recruitment/diagnostic/validate.sh:69:declare -a WARNINGS=()
agents/recruitment/diagnostic/validate.sh:81:  WARNINGS+=("$1")
agents/recruitment/diagnostic/validate.sh:227:  printf '\nValidate Gate A: \033[1;32mPASS\033[0m (warnings=%d)\n' "${#WARNINGS[@]}"
agents/recruitment/diagnostic/validate.sh:231:    "${#FAILURES[@]}" "${#WARNINGS[@]}"
agents/recruitment/diagnostic/validate.sh:259:  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \

exec
/bin/zsh -lc 'git grep -n "validate_check_skipped"' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
.agents/current-priorities.md:21:- [ ] **Diagnostic validate.sh + cycle.sh polish (W3-W4)** — emit specific ESC codes per §6; write validate_check_skipped row; add operator_notify_telegram hh_decision_action call.
agents/recruitment/diagnostic/agent.md:158:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces the following SPEC. **Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements most of these checks today but warns-only on two upstream-unavailable cases (voice-classifier URL unreachable, firm-domain whitelist absent). Hard-fail behaviour on those two cases is a W4 polish item; current v0 honesty-flags them in `decision_log` payload with `validate_check_skipped=true` instead of hard-failing. The spec below describes the W4-complete contract; the W4 build slice closes the two gaps.
agents/recruitment/diagnostic/agent.md:162:- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3) — **v0: warns + flags `validate_check_skipped=true` if voice-classifier URL unreachable; W4 polish closes to hard-fail**
agents/recruitment/diagnostic/agent.md:165:- No PII outside the firm boundary (regex pass for emails/phones that don't match `{firm}.com` or known director email patterns) — fires `ESC_PII_LEAKAGE_RISK` immediately on hit — **v0: warns + flags `validate_check_skipped=true` if firm-domain whitelist absent; W4 polish closes to hard-fail**
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:23:(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract. Their v0 implementation in `validate.sh` is partial — `validate.sh` warns and emits `validate_check_skipped=true` when the voice-classifier URL is unreachable or the firm-domain whitelist is absent, rather than hard-failing; W4-polish closes these to hard-fail per `agents/recruitment/diagnostic/agent.md` §5 honesty note. These warn-only-paths exist in v0 but are not affected by this ADR; this ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:45:The OTHER Gate A subchecks (voice classifier ≥ 0.75 and PII boundary) have v0 warn-only paths when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these are honesty-flagged with `validate_check_skipped=true` per the Context section above. W4-polish closes those subchecks to hard-fail. This ADR addresses only the per-section citation subcheck of Gate A; it does NOT modify the voice classifier or PII subchecks.

codex
REJECTED

1. False claim that skipped Gate A checks are audit-logged. Lines 23 and 45 say `validate.sh` emits or honesty-flags `validate_check_skipped=true`, citing `agents/recruitment/diagnostic/agent.md` §5, but the live validator only prints warnings at `validate.sh` lines 153 and 217; it exits 0 on warnings at lines 226-228 and only writes `hh_decision_action` on failures at lines 259-261. Fix by either implementing the skipped-check `decision_log` write before ratification or rewriting ADR-006 to state the current warn-only paths are console-only and queued for W4.
tokens used
35,915
REJECTED

1. False claim that skipped Gate A checks are audit-logged. Lines 23 and 45 say `validate.sh` emits or honesty-flags `validate_check_skipped=true`, citing `agents/recruitment/diagnostic/agent.md` §5, but the live validator only prints warnings at `validate.sh` lines 153 and 217; it exits 0 on warnings at lines 226-228 and only writes `hh_decision_action` on failures at lines 259-261. Fix by either implementing the skipped-check `decision_log` write before ratification or rewriting ADR-006 to state the current warn-only paths are console-only and queued for W4.
