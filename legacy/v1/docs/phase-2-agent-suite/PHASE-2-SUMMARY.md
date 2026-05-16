# Phase 2 — Agent Suite Summary

**Built:** 22 April 2026
**Total files shipped in this phase:** 70 files across 11 top-level directories
**Approximate line count:** ~8,200 lines across the phase

---

## What got built

### 9 agent bundles

Every agent is a complete 7-file bundle following the pattern in `00-PATTERN-REFERENCE.md`:

| # | Agent | Role in the system |
|---|---|---|
| 1 | **Lead Hunter** | Top-of-funnel prospecting using UK-native data sources (Companies House + Prospeo + Kaspr) |
| 2 | **Client Onboarder** | Week 1–2 kickoff packet (welcome email, agenda, Loom script, access checklist, first content brief, internal context) |
| 3 | **Content Creator** | Long-form content in client voice with cited sources |
| 4 | **Repurposer** | Atomises long-form into platform-specific short-form derivatives |
| 5 | **Caption Writer** | 3–5 caption variants for pre-existing visual assets |
| 6 | **Follow-Up Pilot** | 21-day nurture sequences for unconverted enquiries |
| 7 | **Reporting Engine** | Monthly client reports synthesising vault + integration data |
| 8 | **SOP Writer** | Formalises ad-hoc processes into versioned SOPs |
| 9 | **Librarian** | Nightly vault hygiene — infrastructure for every other agent's retrieval |

Plus Proposal Builder from Phase 1 = 10 agents total, matching the Strategic Plan's agent roster.

### Navigation scaffolding

- `README.md` — root entry point across the entire artifact set
- `MASTER-INDEX.md` — complete file catalogue
- `ARCHITECTURE-OVERVIEW.md` — system-level diagram + components
- `phase-2-agent-suite/README.md` — phase entry point + agent coverage matrix
- `phase-2-agent-suite/00-PATTERN-REFERENCE.md` — the template every agent bundle follows
- `phase-2-agent-suite/_shared/` — common hook helpers, escalation codes registry, universal banned phrases list

---

## The bundle pattern (used by all 9 agents, plus Proposal Builder)

```
{agent-name}/
├── README.md                    # 2-minute human overview
├── agent.md                     # The production prompt — workflow + output spec + quality gates + escalation
├── config.schema.json           # JSON Schema for the Configuration Wizard
├── tools.yaml                   # MCP servers + scopes + degraded-mode behaviour
├── validate.sh                  # PostToolUse hook (sources _shared/hook-helpers.sh)
├── context.sh                   # SessionStart hook (hydrates CONTEXT block)
└── tests/fixtures/01-primary/
    ├── input.json               # Sample trigger payload
    └── expected.md              # Golden output for directional validation
```

Every `validate.sh` and `context.sh` sources `_shared/hook-helpers.sh` for common functions (`hh_log`, `hh_config`, `hh_check_banned_phrases`, `hh_check_no_placeholders`, `hh_retrieve`, `hh_escalate`, etc.) — reducing per-agent boilerplate to ~100 lines each.

---

## Key design decisions locked in this phase

### 1. Shared hook library, not inheritance

Every agent's hooks `source /tenant/.claude/bin/hook-helpers.sh` rather than copy-paste common logic. Pros: bug-fix-once; cons: tight coupling. Acceptable for v1 — we own all agents.

### 2. Escalation codes registered centrally

Every escalation code an agent can raise is documented in `_shared/escalation-codes.md`. Dashboard's Escalations view renders from this catalogue. New codes require a PR to update three places: agent.md, the validation logic that raises it, and the registry. Deliberate friction — prevents escalation-code sprawl.

### 3. Universal banned phrases, client-specific bans layered

`_shared/universal-banned-phrases.txt` bans the classic AI-tell phrases ("cutting-edge solution", "leverage our", "In today's fast-paced world"). Client-specific bans live in `/vault/brand/voice-profile.md` §5. Both checked on every agent output.

### 4. Tier-aware enablement, not per-agent pricing

Tier gates which agents are enabled per tenant (see `phase-2-agent-suite/README.md` §Tier coverage matrix). Agents themselves don't know about tiers — the Provisioning System decides which ones show up in a tenant's `.claude/agents/` directory.

### 5. Everything drafts, nothing sends

Across all 10 agents, zero send-final-to-external-recipient automation. Every output routes through a human review step — Gmail drafts, Slack pings, vault drafts with `status: draft-awaiting-review`. This is the product's trust story in concrete form.

### 6. `{{client.name}}` templating throughout

Same `agent.md` file serves every tenant. Tenant-specific context (voice profile, pricing, past work) is layered in at session start via `context.sh`. Zero hard-coded client data in any agent bundle.

### 7. Librarian is hidden, not sold

Librarian runs on every tier but doesn't appear in the client-facing agent list. It's infrastructure. Selling "nightly vault tagging" to a dental practice owner is a losing pitch; giving them nightly vault tagging so the other agents work well is a winning product.

---

## What every agent pulls from the vault (cross-reference)

All agents assume these files exist on the tenant vault:

| File | Used by |
|---|---|
| `/vault/CLAUDE.md` | all (auto-loaded) |
| `/vault/brand/voice-profile.md` | all writing agents (Proposal Builder, Content Creator, Repurposer, Caption Writer, Follow-Up Pilot, Client Onboarder, Reporting Engine) |
| `/vault/brand/pricing.md` | Proposal Builder, Reporting Engine |
| `/vault/brand/service-catalogue.md` | Proposal Builder, Client Onboarder, Follow-Up Pilot |
| `/vault/brand/positioning.md` | Lead Hunter, Content Creator |
| `/vault/brand/icp.md` | Lead Hunter |
| `/vault/brand/suppression-list.md` | Lead Hunter, Follow-Up Pilot |
| `/vault/sops/_index.md` | SOP Writer, Librarian |
| Past agent outputs (via pgvector) | all (retrieval) |

Minimum vault structure for any agent to run: `minimal-vault-structure.md` from Phase 1 POC.

---

## Cross-agent chaining

Three chained flows are live in this phase:

1. **Proposal Builder → Client Onboarder** (when HubSpot deal moves to Won)
2. **Client Onboarder → Content Creator** (via first-content-brief file in `/vault/content/briefs/`)
3. **Content Creator → Repurposer** (on every new long-form save — trigger file written to `/tenant/intake/manual/`)

Chaining is file-based, not API-based. Each agent writes an intake file; the supervisor picks up the next invocation from its worker queue. Clean separation of concerns; easy to debug (there's a file).

---

## What's NOT in Phase 2

- **Voice Receptionist** — runs on Vapi, not Claude Code. Different bundle shape (Vapi flow JSON + post-call webhook handler). Separate spec arrives in Phase 3.
- **Ad Manager** — continuous optimisation loop doesn't fit the one-shot session model. Persistent service, not a Claude Code agent. Separate spec arrives in Phase 3 or 4.
- **Voice profile extraction** — the one-time onboarding task that generates the voice profile from 20–50 sample writings. Currently treated as a wizard step with a human-in-the-loop review; could become its own agent in v1.1 if demand justifies.

---

## Total artifact set so far (Phase 1 + Phase 2)

| Category | Files |
|---|---|
| Navigation & meta | 3 |
| Strategic & business planning | 6 |
| Phase 1 POC stack | 16 |
| Phase 2 agent suite | 70 |
| **Grand total shipped** | **95** |

Future phases (3–7) add approximately 90 more artifacts per `intelforce-execution-plan.md`.

---

## How to validate the whole suite

There's no "test every agent against all fixtures" runner yet — that's a Phase 3 item (CC3: the CI harness). For now, each agent's fixture is validated by running it in a POC mode similar to `phase-1-poc-stack/runbooks/week-1-experiment-runbook.md`:

1. Put the agent bundle into `~/intelforce-poc/tenant/.claude/agents/{name}/`
2. Seed the vault with the minimum files the agent needs (see each agent's README §"What it needs")
3. Drop the fixture's `input.json` into the appropriate intake folder
4. Invoke Claude Code with `Use the {name} agent to process this trigger`
5. Compare the produced output against `expected.md` — directional match, not pixel-perfect

The fixtures are deliberately synthetic but specific enough to test the hard cases (escalations, missing data, ambiguous briefs). A full CI harness would loop this for all 10 agents nightly; manual validation works for the next few weeks of build.

---

## The sequence for rolling out

If I'm briefing a developer on what to do first with this set:

1. **Week 1** — Run the Proposal Builder POC runbook (Phase 1). Validates the whole thesis before engineering anything.
2. **Week 2** — If POC passes, the dev builds CC2 (Webhook Receiver) from the spec in Phase 1.
3. **Week 3** — CC8 (Tenant Container Image) from the Phase 1 spec. This is what Phase 2 agents run inside.
4. **Week 4** — Deploy the second agent (Client Onboarder — easier than Lead Hunter because inputs are under your control). Validate it produces good output for a real signed deal.
5. **Weeks 5–8** — Roll out the remaining agents in this order: Librarian (infrastructure), Reporting Engine (retention), Lead Hunter (new business), Content Creator + Repurposer (content bundle), Follow-Up Pilot (nurture), Caption Writer (quick win), SOP Writer (ops tool).
6. **Weeks 9–12** — Dashboard (Phase 4 work), multi-tenant provisioning (Phase 3), legal + billing (Phase 5).

This is risk-reduction order, not tier order. Ship the highest-impact, lowest-integration-risk agents first. Get to a "single-tenant all-agents-working" state before investing in the multi-tenant control plane.

---

## What this phase proves

- The bundle pattern scales — 10 agents produced, all conforming to the same structure, all using the same shared library.
- The `{{client.name}}` templating works at the agent.md level — no per-tenant `agent.md` files needed.
- Validation via shared helpers produces tight per-agent hooks (each validate.sh is ~100 lines vs Proposal Builder's original 293).
- Escalation-first design — every agent has explicit failure modes with codes, not silent degraded output.

---

## What this phase doesn't prove (yet)

- That Claude Code actually runs all 9 agents reliably in production — we have specs, not deployed systems. Phase 1's POC runbook covered Proposal Builder; a similar runbook per agent is warranted before full rollout, or a consolidated CI harness.
- That the cost envelopes hold at scale — each agent's `cost_budget_per_invocation` in `tools.yaml` is estimated, not measured.
- That the degraded-mode behaviours actually degrade gracefully — tested in theory, not in a chaos-testing setup. Phase 6 (ops runbooks) will cover this.
- That clients find the vault structure intuitive to edit via Obsidian — that's an onboarding feedback loop we'll get in Phase 7.

---

## Where to go next from here

Ship the navigation and artifact set. Next planning sessions should cover:

- **Phase 3** — platform implementation specs (Postgres schema for tenant registry + invocation logs + cost attribution, Provisioning System orchestrator, observability stack, secret rotation flows)
- **Phase 4** — dashboard specs (Configuration Wizard wizard steps, Brain view, Operations Control, Activity log, Agency Partner portal)
- **Phase 5** — business & legal (MSA, DPA, SLA, pricing page copy, landing page copy, trademark filing — pending the C3a naming decision)
- **Phase 6** — ops runbooks (incident response, on-call rotation, cost governance, secret rotation, tenant lifecycle)
- **Phase 7** — post-launch (case study capture, onboarding feedback loops, version migration procedures)

The C3a naming decision (IntelForce vs Clawd) remains unresolved and continues to block trademark filing, domain registration, identity design, and pricing-page copy.
