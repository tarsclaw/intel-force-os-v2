# Phase 1 POC Stack — Session Summary

**Built:** 22 April 2026
**Sessions covered:** 2–6 of the Execution Plan
**Total files:** 13 across 4 directories
**Approximate line count:** ~3,800 lines of production-grade specs and code

---

## What you have now

This bundle is the **POC stack** — the minimum viable set of artifacts to prove that the Proposal Builder agent pattern actually works on a real Fathom discovery call, before any platform infrastructure (dashboard, webhook receiver, containers, control plane) gets built.

The logic is deliberately front-loaded: **if the agent prompt + config + validation layer doesn't produce sendable output on real data, every other piece of the platform is wasted effort.** Week 1 of the build plan is the validation week for the whole thesis.

---

## The 10 files

### The Proposal Builder agent bundle (5 files)

This is the flagship. Every subsequent agent (Lead Hunter, Follow-Up Pilot, Content Creator, etc.) follows the same structural pattern: `agent.md` + `config.schema.json` + `tools.yaml` + `validate.sh` + `context.sh`. Get this one right and the others become template work.

**1. `proposal-builder/agent.md`** — the production prompt
The full v1 agent definition. YAML frontmatter with tool permissions, 9-step workflow, 9-section output specification, 7 quality gates, 8 escalation conditions, internal quality notes. All client references use `{{client.name}}` templating so this same agent.md serves every tenant with different voice/pricing layered in via context.sh.

**2. `proposal-builder/config.schema.json`** — what the Wizard collects
JSON Schema draft-07 defining the exact per-tenant configuration shape. The Configuration Wizard walks the client through this, validating each field before allowing activation. Includes Fathom auth, pricing framework pointers, vault paths, Slack channels, HubSpot pipeline stage, optional DocuSign/Notion integrations.

**3. `proposal-builder/tools.yaml`** — MCP server declarations
Catalogues every MCP integration: Fathom (required, community fork), HubSpot (required, official), Gmail (required, community), DocuSign (optional v1.1), Notion (optional). Includes scopes, rate limits, degraded-mode behaviour per integration, and the pre-flight checks the Provisioning System runs before activating this agent for a tenant.

**4. `proposal-builder/validate.sh`** — the PostToolUse structural hook
Runs after every Write or Edit under `vault/clients/**/proposals/`. Enforces Quality Gates 3, 4, 5 structurally. Checks file path convention, YAML frontmatter, 9-section presence and order, placeholder absence (hard ban on TBD/INSERT/{{/XXX/FIXME/TODO), word count 800–2500, price format, verbatim quote indicators, banned AI-tell phrases, signature block presence. Returns stdout feedback that Claude Code injects into the session for self-correction.

**5. `proposal-builder/context.sh`** — the SessionStart hydration hook
Runs when Claude Code spawns a session for this agent. Reads the trigger payload from `/tenant/intake/fathom/`, extracts prospect identity, retrieves the top-3 most-similar past winning proposals via pgvector + Cohere embeddings, loads voice profile + pricing framework, then populates the CONTEXT block in agent.md with everything the agent needs to work. All templating happens here — agent.md becomes agent.working.md per session.

### Test fixtures (6 files — 3 pairs)

**6. `tests/fixtures/01-dental-clear-fit/`** — transcript.json + expected.md
The easy path. Dr Priya Shah at Meadow Lane Dental — clear problem (missed calls, low conversion, no follow-up), clear budget (£2–3k/month), sole decision-maker, pre-summer timeline. Tests that the agent produces a clean tiered proposal with Growth recommended, uses Priya's verbatim quotes, and references the Crescent Dental case study she mentioned.

**7. `tests/fixtures/02-multi-service-ambiguous/`** — transcript.json + expected.md
The harder path. Marcus Okafor at Loopcatch SaaS — four workstreams discussed (content, outbound, CS, hiring), ambiguous priority, explicit "wary of agencies" framing, broad £5–15k/mo budget range. Tests that the agent proposes three distinct shapes matching different interpretations, explicitly excludes the hiring workstream as out-of-catalogue, and leads with voice profile extraction as the trust-builder.

**8. `tests/fixtures/03-budget-mismatch/`** — transcript.json + expected.md
The escalation test. Sam Whitley at Whitley Lawn Care — small sole trader, £200–300/month ceiling, below minimum engagement value. Tests that the agent produces an ESCALATION NOTE (not a proposal), cites code `BUDGET_BELOW_MINIMUM`, references Sam's verbatim budget statement, and recommends self-serve alternatives. If the agent produces a watered-down Starter proposal here, it's failed the test — the whole point is that our minimums are real.

### Platform specs (3 files)

**9. `platform-specs/tenant-container-spec.md`**
The Docker image + filesystem layout every tenant runs in. Shared base image (Debian slim + Node 20 + Python 3.11 + Claude Code + jq + git + helpers), per-tenant volume mount at `/tenant/`. Full filesystem layout for `.claude/`, `vault/`, `intake/`, `outbox/`, `logs/`, `secrets/`. Permissions matrix. Tenant-config.json schema with hot-reload behaviour. Git-backed vault sync architecture. Supervisor process design (long-running thin Node process that holds a Unix socket for triggers and spawns `cc-invoke` on each trigger). Egress whitelist (UK/EU only destinations). Resource limits per tier. Startup/shutdown/upgrade/rollback flows.

**10. `platform-specs/webhook-receiver-spec.md`**
The internet-facing Fastify service that catches Fathom webhooks and dispatches them to tenant supervisors. HMAC-SHA256 signature verification with raw-body capture, Redis-backed dedup (7-day TTL on delivery IDs), per-tenant filter rules (meeting type, duration, external attendees), token-bucket rate limiting, hot-reloading tenant registry from Postgres NOTIFY, structured logging, Prometheus metrics, alert conditions, Kubernetes deployment topology. Same pattern extends to HubSpot/DocuSign/Stripe/Calendly in v1.1+ — adding a new integration is a single file under `/src/integrations/`.

**11. `platform-specs/minimal-vault-structure.md`**
The starting directory tree + seed templates every new tenant vault ships with. Provisioning System clones this skeleton as the initial commit on the tenant's GitHub vault repo. Full tree with 10 top-level folders, seed content for `CLAUDE.md` (brain stem), `brand/voice-profile.md`, `brand/pricing.md`, `brand/service-catalogue.md`, `clients/_template/00-context.md`, SOP structure, Obsidian templates. Defines completeness minimums: `voice_profile_completeness` under 30% triggers warnings on all agent runs.

### Runbook (1 file)

**12. `runbooks/week-1-experiment-runbook.md`**
Day-by-day execution plan for the POC. Five days, four hard PASS gates (3 fixtures + 1 real Fathom call), ~30 hours of work, £50 API budget. Day 1 setup (local filesystem mimicking tenant structure, Claude Code wiring, manual vault seeding). Day 2 fixture 01 (easy path validation). Day 3 fixtures 02 + 03 (hard cases + escalation). Day 4 real Fathom call (the real validation). Day 5 Gmail MCP integration + POC report. Includes common problems and fixes, escape-hatch conditions (when to stop and redesign), explicit scope (what the POC proves vs doesn't prove), and the end-of-week deliverable (1-page report that unlocks or blocks the CC2+ platform build).

### This file (1 file)

**13. `SESSION-SUMMARY.md`** — this document

---

## How these fit together — data flow end to end

```
  [ Fathom call ends, meeting.processed webhook fires ]
                    │
                    ▼
  [ webhook-receiver — verify signature, dedup, filter, persist ]
                    │
                    │ writes JSON to /tenant/intake/fathom/{id}.json
                    │ fires /tenant/.claude/tenant.sock
                    ▼
  [ tenant-supervisor inside the tenant container ]
                    │
                    │ spawns cc-invoke proposal-builder --trigger {path}
                    ▼
  [ Claude Code starts, loads agent.md ]
                    │
                    ▼
  [ context.sh runs (SessionStart hook) ]
                    │
                    │ hydrates CONTEXT block:
                    │   - voice-profile.md (from vault)
                    │   - pricing.md (from vault)
                    │   - top-3 past winning proposals (pgvector + Cohere)
                    │   - Fathom summary + action items + full transcript
                    │
                    ▼
  [ Claude Code session reads agent.working.md ]
                    │
                    │ executes 9-step workflow
                    ▼
  [ Agent writes proposal to /vault/clients/{slug}/proposals/ ]
                    │
                    ▼
  [ validate.sh runs (PostToolUse hook) ]
                    │
                    │ enforces Quality Gates 3, 4, 5 structurally
                    │ fails → feedback in context → Claude revises
                    │ passes → proceeds
                    ▼
  [ Agent creates Gmail draft for sales lead via MCP ]
                    │
                    ▼
  [ Agent updates HubSpot deal stage to "Proposal Drafted" ]
                    │
                    ▼
  [ vault-syncer commits + pushes the new proposal to GitHub ]
                    │
                    ▼
  [ Sales lead opens Gmail draft, reviews, sends — or edits first ]
```

Every numbered step maps to an artifact in this bundle:
- Step 1 (webhook) → spec #10
- Step 2 (tenant container) → spec #9
- Step 3 (agent) → #1
- Step 4 (context hydration) → #5
- Step 5 (workflow) → #1 §Workflow
- Step 6 (vault write path) → #11
- Step 7 (validation) → #4
- Step 8 (Gmail) → #1 Step 8 + #3 gmail section
- Step 9 (HubSpot) → #1 Step 9 + #3 hubspot section
- Step 10 (vault sync) → #9 §5

---

## What this bundle is NOT

- **Not a dashboard.** The Next.js control plane, configuration wizard UI, and client-facing pages come in Phase 4 (Sessions 26–34).
- **Not a multi-tenant platform.** Postgres schema, tenant provisioning orchestrator, and lifecycle management come in Phase 3 (Sessions 17–25).
- **Not the other 9 agents.** Lead Hunter, Follow-Up Pilot, Content Creator, Repurposer, Caption Writer, Client Onboarder, Reporting Engine, SOP Writer, Librarian all follow this same 5-file bundle pattern and come in Phase 2 (Sessions 7–16).
- **Not business/legal material.** MSA, DPA, SLA, pricing-page content, landing-page copy, trademark filing come in Phase 5 (Sessions 35–44).
- **Not ops runbooks.** Incident response, on-call rotation, cost-governance procedures come in Phase 6 (Sessions 45–52).

The 90 remaining artifacts across Phases 2–7 are planned in detail in `intelforce-execution-plan.md` from earlier in our conversation. What this POC proves enables those. What this POC fails would stop them.

---

## Five defaulted decisions still to formally lock

I built the bundle assuming these. Flag to me if you want to change any:

1. **C3a — Product name placeholder.** I used "IntelForce AI OS" where I had to name the platform, but the client-facing agent.md uses `{{client.name}}` templating throughout. Swap to "Clawd" if you take my recommendation (still my view — the trademark conflict is real). Find-replace of "IntelForce AI OS" across files 9, 10, 11, 12 covers it.

2. **C2a — API tenancy.** Your Anthropic Org with per-tenant metadata tags. Config schema at file #2 has `anthropic.metadata_tags` reflecting this. Baked into tenant-config.json at file #9.

3. **C2b — Tenant isolation.** Shared Docker image with mounted tenant config. File #9 spec is built around this. Per-tenant images would require restructuring §2 and §12 of that spec.

4. **C2c — Vault sync.** Git-backed via tenant's own GitHub repo under `intelforce-vaults` org. File #9 §5 and file #11 §4 rely on this.

5. **C2d — Embedding provider.** Cohere EU (`embed-v3`, `eu-west-1` region). File #5 and file #9 §4 use this. Swap to OpenAI by changing two fields in tenant-config.json + one line in the vault-search helper.

---

## What to do next

**Immediate (this week):**
Execute the Week-1 Experiment Runbook (file #12). Five days. Real Fathom call on Day 4. 1-page POC report on Day 5.

**Based on POC result:**
- **4/4 PASS** → commission CC2 (Webhook Receiver) build starting Monday of Week 2. Your dev trial (C1d) becomes: "build CC2 per `webhook-receiver-spec.md`".
- **3/4 PASS** → iterate on agent.md for 2–3 days, rerun failing gate, reassess.
- **≤2/4 PASS** → pause. We restructure the prompt pattern before spending engineering effort on scaffolding.

**In parallel (not blocked by POC):**
- Register domain per C3b (clawd.ai + clawd.co.uk if you take my rec, or your alternative).
- Brief a solicitor on C4a (MSA/DPA review).
- Get insurance quotes per C4b.
- File trademark per C4c — specifically DO NOT file "IntelForce AI OS" given the trademark risk; file whatever name you lock in C3a.
- Start on the founding-customer conversations from C1c.

**Next Claude sessions (when you're ready):**
- Sessions 7–11: Phase 2 — the other 9 agents follow the same bundle pattern. Lead Hunter is the second-most-important (feeds the pipeline). Client Onboarder is third (reduces churn risk). Content Creator + Repurposer are the highest-volume-use bundle for agency clients.
- Session 17 onwards: Phase 3 — Postgres schema, Provisioning System, observability stack.

---

## One honest note

You skipped the Session 1 Open Decisions workshop and told me to proceed. I did, with sensible defaults flagged above. That's fine for POC-velocity reasons — the defaults don't corrupt the work, and every one of them is a 1-line config change if you decide differently.

**But C3a (the IntelForce trademark conflict) genuinely needs your decision before you file a trademark, buy a domain at scale, print business cards, or design an identity system.** The other four decisions are low-stakes. C3a is the one I'd push back on again if you haven't thought about it. Domain availability checks from earlier found `intelforce.com` for sale (pricey), `intelforce.org` operating as a cyber-intel company, and a live IntelForce GPT on the ChatGPT store for law enforcement. Fighting that SEO battle while also building a startup is not free.

Reply with:
1. Go/no-go on the POC runbook this week
2. Decision on C3a product naming
3. Anything in the bundle you want changed before the dev gets hands on it

Standing by for the next batch of sessions when you are.
