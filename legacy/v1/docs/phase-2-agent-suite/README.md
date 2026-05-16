# Phase 2 — Agent Suite

**Nine more agent bundles completing the core IntelForce AI OS offering.** Built on the same structural pattern as Proposal Builder (`phase-1-poc-stack/proposal-builder`). Every agent here has the same 5-file shape plus a README and a test fixture.

---

## What's included

| # | Agent | Purpose | Trigger | Tier availability |
|---|---|---|---|---|
| 1 | `lead-hunter` | Prospect list generator (UK stack: Companies House + Prospeo + Kaspr) | Cron + manual | Growth+ |
| 2 | `client-onboarder` | Week 1–2 kickoff collateral (welcome email, Loom script, agenda, access checklist) | HubSpot "Won" + manual | All |
| 3 | `content-creator` | Long-form pieces in client voice | Weekly cron + manual brief | Growth+ |
| 4 | `repurposer` | Atomises long-form into social/email/thread | Chained to `content-creator` | Growth+ |
| 5 | `caption-writer` | Short-form captions for existing assets (photos, videos) | Manual (dashboard upload) | All |
| 6 | `follow-up-pilot` | 21-day nurture sequences for unconverted enquiries | Weekly cron + HubSpot stage change | Growth+ |
| 7 | `reporting-engine` | Monthly client reports | Monthly cron (1st) + weekly snapshots | All |
| 8 | `sop-writer` | Formalises processes from chat into versioned SOPs | Manual | Scale+ |
| 9 | `librarian` | Nightly vault hygiene — tagging, embedding, archiving, daily rollups | Nightly cron (04:00 UTC) | All (hidden) |

Plus Proposal Builder (Phase 1) = 10 agents total, matching the Strategic Plan.

---

## Tier coverage matrix

Which agents are enabled per pricing tier:

| Agent | Starter (£1.5k/mo) | Growth (£1.8k/mo) | Scale (£3k/mo) | Enterprise (£5k+/mo) |
|---|:-:|:-:|:-:|:-:|
| Proposal Builder | ✓ | ✓ | ✓ | ✓ |
| Client Onboarder | ✓ | ✓ | ✓ | ✓ |
| Caption Writer | ✓ | ✓ | ✓ | ✓ |
| Reporting Engine | ✓ | ✓ | ✓ | ✓ |
| Librarian (hidden) | ✓ | ✓ | ✓ | ✓ |
| Lead Hunter | — | ✓ | ✓ | ✓ |
| Content Creator | — | ✓ | ✓ | ✓ |
| Repurposer | — | ✓ | ✓ | ✓ |
| Follow-Up Pilot | — | ✓ | ✓ | ✓ |
| SOP Writer | — | — | ✓ | ✓ |
| Voice Receptionist (Vapi, add-on) | — | — | Add-on | Add-on |
| Ad Manager (add-on) | — | — | Add-on | Add-on |

---

## Reading an agent bundle

Every agent directory follows the same layout:

```
{agent-name}/
├── README.md                    # What this agent does, at a glance
├── agent.md                     # The production prompt (YAML + workflow + output spec + quality gates + escalation)
├── config.schema.json           # JSON Schema for the Configuration Wizard to collect tenant config
├── tools.yaml                   # MCP server declarations + scopes + degraded-mode behaviour
├── validate.sh                  # PostToolUse hook (sourced from _shared/hook-helpers.sh + agent-specific checks)
├── context.sh                   # SessionStart hook (loads agent-specific retrieval + triggers)
└── tests/
    └── fixtures/
        └── 01-primary/
            ├── input.json       # Sample trigger payload
            └── expected.md      # Golden output the agent should produce
```

**Reading order if you're building one:**
1. `README.md` — 2-minute overview
2. `agent.md` — the prompt (this is where the thinking is)
3. `config.schema.json` — what you need to collect from the tenant
4. `tools.yaml` — which MCP servers you need to wire up
5. `tests/fixtures/01-primary/` — prove it works on the fixture before shipping
6. `validate.sh` + `context.sh` — supporting scripts (mostly calls to shared helpers)

**Reading order if you're selling it:**
1. `README.md` — what it does and for whom
2. `tests/fixtures/01-primary/expected.md` — the output that gets produced

---

## Shared infrastructure (`_shared/`)

| File | Purpose |
|---|---|
| `hook-helpers.sh` | Common bash functions sourced by every agent's hooks (logging, config access, retrieval, escalation, universal content checks) |
| `universal-banned-phrases.txt` | The AI-tell phrases banned on every agent's output, enforced by `hh_check_banned_phrases` |
| `escalation-codes.md` | Registry of every escalation code used across all agents |

The Provisioning System copies `hook-helpers.sh` + `universal-banned-phrases.txt` into every tenant's `/tenant/.claude/bin/` on first deployment and on upgrade. Agents then `source /tenant/.claude/bin/hook-helpers.sh` at the top of their hook scripts.

---

## The pattern every agent follows

See `00-PATTERN-REFERENCE.md` for the template definition. In short:

1. **Workflow is numbered, no skipping.** Agents execute steps 1–N in order.
2. **Output specification is structured.** A markdown template with specific required sections, enforced structurally by `validate.sh`.
3. **Quality gates are explicit.** 5–8 gates per agent, checked structurally where possible, semantically where not.
4. **Escalation conditions short-circuit the workflow.** If any trigger, agent stops and writes an escalation note instead of producing output.
5. **Everything drafts, nothing sends.** Every agent output goes to a human before reaching the prospect/client.
6. **Templating uses `{{client.name}}`, `{{sales_lead.email}}`, etc.** so the same `agent.md` serves every tenant with context layered in.

---

## What each agent assumes exists

Every agent assumes the tenant has these vault files populated (minimum):

- `/tenant/CLAUDE.md` — the brain stem
- `/tenant/vault/brand/voice-profile.md` — voice definition
- `/tenant/vault/brand/pricing.md` — pricing framework (relevant for Proposal Builder, Reporting Engine)
- `/tenant/vault/brand/service-catalogue.md` — what the client actually sells
- `/tenant/.claude/tenant-config.json` — per-tenant config (collected by the Wizard)

And these secrets in the tenant's secrets vault:

- `secrets://{tenant_id}/anthropic/api_key` — required by all
- Integration-specific OAuth tokens per the agent's `tools.yaml`

---

## Build & test order

If you're building the platform and want to sequence the agent rollout, recommended order:

1. **Proposal Builder** (already POC-validated) — the money maker
2. **Client Onboarder** — reduces churn risk; easy to validate because you have control of the input
3. **Reporting Engine** — retention tool; every client needs this monthly
4. **Librarian** — infrastructure; everything else degrades without it
5. **Lead Hunter** — top-of-funnel; unlocks the prospect volume story
6. **Content Creator + Repurposer** — the content bundle; these ship together
7. **Follow-Up Pilot** — bottom-of-funnel recovery
8. **Caption Writer** — simple; fills a gap
9. **SOP Writer** — the ops tool; lowest urgency

This isn't tier order — it's risk-reduction order. Ship the highest-impact, lowest-integration-risk agents first.

---

## What's NOT in Phase 2

- **Voice Receptionist** — this runs on Vapi, not Claude Code. Bundle structure is different (config is a Vapi flow JSON, not an agent.md). Separate spec in Phase 3.
- **Ad Manager** — this is an add-on that orchestrates Google Ads + Meta Ads APIs. Some of it can run in Claude Code but the optimisation loop needs a dedicated service. Separate spec in Phase 3 or 4.

These two are premium add-ons per the Strategic Plan and are sold as distinct upgrades, not part of the base multi-agent platform.

---

## Where the thinking lives

- **Strategic "why these agents" and pricing:** `intelforce-ai-os-strategic-plan.md`
- **How these agents fit in the container/vault/webhook architecture:** `ARCHITECTURE-OVERVIEW.md`
- **The pattern itself:** `00-PATTERN-REFERENCE.md` (this directory)
- **What was built vs what's still to come:** `MASTER-INDEX.md`
