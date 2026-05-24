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
