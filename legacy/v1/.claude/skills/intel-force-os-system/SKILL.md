---
name: intel-force-os-system
description: The top-level system knowledge skill for Intel Force OS. Use this skill whenever you're working on Intel Force OS broadly — architectural decisions spanning multiple phases, cross-pack questions, strategic planning, prioritisation, or when you need to understand how different parts of the 163-file specification system relate to each other. Also triggers on "Intel Force OS", "the platform", "the product", "which pack", "cross-phase", or any question about what exists vs what's deferred.
---

# Intel Force OS — System-Level Skill

This is the master navigational skill for Intel Force OS. When active, it means you're working on something that spans or touches multiple parts of the system.

## What Intel Force OS is (at system level)

Intel Force OS is a Teams-delivered multi-agent AI platform for UK SMEs. The system comprises 9 packs of specifications totalling ~40,600 lines across 163 files, covering strategic foundation, POC experimentation, 10 agents, platform infrastructure, dashboard, business/legal, ops runbooks, and the Teams HR Agent v1 build.

Full catalog: `MASTER-INDEX.md` at project root.

## The 9-pack mental model

```
 STRATEGIC (Phase 0)
      │
      ├─── POC experimentation (Phase 1) — dormant, superseded
      │
      ├─── AGENTS (Phase 2) ──────────────┐
      │    10 agents, HR first            │
      │                                   │
      ├─── PLATFORM (Phase 3) ────────────┤──→ What gets built v2+
      │    Postgres, Temporal, vault      │
      │                                   │
      ├─── DASHBOARD (Phase 4) ───────────┤
      │    Web/Teams Tab UI               │
      │                                   │
      ├─── BUSINESS/LEGAL (Phase 5) ──────┼──→ Active reference per customer
      │    MSA, DPA, SLA, pricing         │
      │                                   │
      └─── OPS (Phase 6) ─────────────────┘──→ Activates when customer 1 live

 ACTIVE BUILD
      ├─── TEAMS HR AGENT (Pack 7) ─────────→ What gets built v1
      │    Architecture + build stages
      │
      └─── GTM (Pack 8) ────────────────────→ Active customer acquisition
           Prospecting, demos, onboarding
```

## Current project reality check

Before any architectural discussion, these are the ground facts:

- **0 paying customers**
- **Existing Relevance AI HR agent works** for email-based handling
- **Teams HR Agent v1 is the current build target** (Pack 7)
- **Customer acquisition is the active commercial motion** (Pack 8)
- **All other packs are reference material**

If a conversation drifts toward "let's build Phase 3 / Phase 4 / a second agent" before the Teams HR Agent has customers, flag it as scope creep.

## Navigation patterns

### When asked "where does X live?"

1. Check `MASTER-INDEX.md` first — it has topic → file mapping
2. If the topic is architectural: likely Pack 7 (Teams) or Phase 0 (Strategic)
3. If the topic is agent-specific (prompts, escalation codes): Phase 2 bundle for that agent
4. If the topic is operational (incident, deployment): Phase 6
5. If the topic is commercial (pricing, sales): Pack 5 + Pack 8
6. If the topic is infrastructure (database, secrets): Phase 3

### When asked "should we build X now?"

Apply the readiness test:
- Does X block or materially accelerate getting customer 1? → build now
- Does X serve current customer needs? → build now
- Does X extend the product in a direction we haven't validated? → defer
- Does X replicate something already specced? → read the spec first, don't re-spec

### When asked "what's our position on X?"

Check in this order:
1. Invariants in root `CLAUDE.md` (the six non-negotiables)
2. Strategic plan in `docs/phase-0-strategic/strategic-plan.md`
3. Specific pack README for topic-relevant position
4. Open Decisions in `docs/phase-0-strategic/execution-plan.md`

If no position documented: it's an open decision. Flag it as such; don't invent one.

## Cross-pack invariants (apply everywhere)

1. **"Everything drafts, nothing sends without approval"** — enforced in every agent, every code path, every UI
2. **One Teams app, many agents** — all agents share one install, one manifest, one admin consent
3. **Customer-side zero-Azure** — no customer ever touches Azure Portal
4. **British English throughout** — copy, docs, UI
5. **GDPR baseline** — every data touch has deletion + export procedures
6. **Audit everything** — every decision logged with actor, timestamp, rationale

## The Open Decisions framework

Open Decisions are tracked with codes: **OD-P{phase}-{number}**.

Example codes you'll encounter:
- **OD-P0-1:** primary channel (email vs Teams) — RESOLVED: Teams
- **OD-P1-3:** POC methodology — SUPERSEDED by Teams HR Agent
- **OD-P3-7:** per-tenant isolation model — OPEN (decide at 30+ customers)
- **OD-P5-2:** pricing structure — RESOLVED: 4 tiers
- **OD-P7-1:** Teams app registration approach — RESOLVED: Dev Portal not Azure Portal
- **OD-P8-3:** cold outreach channel — OPEN (testing)

When a new decision arises, check `docs/phase-0-strategic/execution-plan.md` for its status. Don't resolve OPEN decisions unilaterally; surface to Maddox.

## The "which pack is this?" quick reference

| Work type | Primary pack | Secondary |
|---|---|---|
| Writing Worker code | 7 (Teams HR Agent) | 3 (for patterns) |
| Designing an Adaptive Card | 7 | none |
| Adjusting agent prompt | 2 (HR bundle) | — |
| Pricing conversation | 5 (pricing-spec) | 8 (pricing-sheet) |
| Customer install | 7 (deployment-guide) | 5 (MSA, SLA) |
| Incident response | 6 | — |
| Demo | 8 (demo-script) | 7 (for technical Q&A) |
| New agent design | 2 (_shared + agent bundle) | 7 (for Teams delivery) |
| Scaling to Postgres | 3 | 6 (for DR implications) |
| Dashboard work | 4 | 7 (for Tab integration) |
| Roadmap planning | 0 (strategic-plan) | pack-specific |

## The honest posture on specs

Maddox has over-specified the system. The risk is not a missing spec — it's paralysis from specification abundance. When in doubt:

1. **Do not create new specification files.** They exist.
2. **Do not elaborate existing specs.** Specifications are inputs to execution, not an end state.
3. **Do reference specs when implementing** — that's what they're for.
4. **Do flag inconsistencies between specs and reality** — as questions, not as new docs.

## When to invoke other skills

This system skill is for broad navigational questions. For deeper work, the specific skills are:

- `teams-hr-agent` — when implementing the Teams build
- `gtm-execution` — for customer acquisition work
- `phase-{N}-{name}` — for deep dives into a specific pack
- `relevance-ai` — for agent integration work
- `adaptive-cards` — for card UI work
- `bot-framework-teams` — for Bot Framework protocol
- `cloudflare-intel-force` — for Worker/KV/D1 implementation

Usually you don't need to manually invoke — skills load when their description matches the current task.

## The meta-question

When Maddox asks a broad strategic question that could span packs, the right response pattern is:

1. Identify which packs the question touches
2. Summarise what each relevant pack says
3. Identify conflicts or open decisions
4. Offer 2-3 concrete next actions

**Don't:** write a new multi-page strategic brief. That pattern is the problem.  
**Do:** answer from what exists, flag gaps, recommend action.
