---
name: phase-1-poc
description: Phase 1 POC stack — proposal builder agent, minimal platform components, and the never-executed Week 1 experiment runbook. Use this skill when working on the proposal builder agent, reviewing the original POC methodology, or considering whether to retire Phase 1 in favour of Teams HR Agent. Also triggers on: POC, Fathom, proposal builder, Week 1 experiment, minimal vault, tenant container.
---

# Phase 1 — POC Stack Skill

**Pack status:** Dormant. The Week 1 experiment was never executed. The POC role is now filled by the Teams HR Agent v1.

## Where the spec lives

`docs/phase-1-poc-stack/` — 16 files, ~4,800 lines

| Component | Location |
|---|---|
| Proposal Builder agent | `docs/phase-1-poc-stack/proposal-builder/` (7-file bundle) |
| Minimal platform specs | `docs/phase-1-poc-stack/platform/` (3 files) |
| Week 1 experiment runbook | `docs/phase-1-poc-stack/week-1-experiment-runbook.md` |

## When to consult this pack

**Rarely.** Specifically:

1. **When building the Proposal Builder agent** (deferred, not current priority) — the bundle is the spec
2. **When Maddox decides to execute the original POC** (unlikely now given Teams HR Agent exists)
3. **When designing future agent webhook receivers** — `platform/webhook-receiver-spec.md` has the pattern

## What this pack contains (summary)

### Proposal Builder agent
Generates sales proposals from raw Fathom call transcripts. The 7-file bundle:
- `proposal-builder-spec.md` — what it does
- `proposal-builder-prompt.md` — Relevance AI system prompt
- `proposal-builder-input-schema.md` — Fathom transcript format
- `proposal-builder-output-schema.md` — structured proposal output
- `proposal-builder-example-inputs.md` — test transcripts
- `proposal-builder-example-outputs.md` — expected proposals
- `proposal-builder-escalation-codes.md` — sensitivity categories

This agent is specced but not implemented. If building it later, the pattern closely mirrors the HR agent — same governance, same approval loop.

### Minimal platform
Early designs for:
- `tenant-container-spec.md` — per-tenant isolated environment (conceptual, superseded by multi-tenant single-Worker)
- `webhook-receiver-spec.md` — generic agent input path (useful pattern; partially implemented as Teams bot messaging endpoint)
- `minimal-vault-spec.md` — per-tenant secrets (superseded by Wrangler secrets for v1, AWS KMS for Phase 3)

### Week 1 experiment runbook
The unfulfilled POC: real Fathom call → auto-generated proposal. Never executed because:
- Maddox didn't have a live Fathom call with a real prospect
- The pivot to HR-first via Teams superseded the proposal-first approach
- The Teams HR Agent covers the "does the approach work?" question more directly

## The retirement question

There's an open architectural question: should Phase 1 be formally retired?

**Arguments for retiring:**
- Week 1 experiment is unlikely to happen
- Teams HR Agent supersedes the POC role
- Keeping dormant specs alive creates cognitive overhead

**Arguments against retiring:**
- Proposal Builder is a legitimate future agent
- The minimal platform specs are still referenced for patterns
- Retirement is destructive; mothballing is reversible

**Recommendation:** don't retire. Label as "deferred — patterns still useful." Revisit if/when Proposal Builder becomes a priority.

This is an Open Decision: **OD-P1-3** in `docs/phase-0-strategic/execution-plan.md`.

## Cross-references

- The webhook receiver pattern lives on in Teams HR Agent's `/api/messages` endpoint
- The tenant container concept evolves into Phase 3's per-tenant Postgres schemas
- The escalation codes pattern becomes the shared `phase-2-agent-suite/_shared/escalation-codes.md`

## When NOT to use this pack

- Don't consult for current Teams HR Agent work (that's Pack 7)
- Don't consult for Phase 3 platform work (Phase 3 supersedes)
- Don't look here for GTM (Pack 8)
- Don't use the proposal builder bundle as a template for new agents without reading Pack 2's `_shared/` first

## One-sentence summary

Phase 1 was the original plan before the Teams pivot; it's legitimate reference material for future agents but not active work.
