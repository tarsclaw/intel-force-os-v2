# IntelForce AI OS — Technical Strategy v2
**Claude Code as the runtime. Obsidian as the brain. Verified against the top 1% power-user playbook.**

> *Supersedes the runtime recommendation in v1 of the strategic plan (§4).*
> *Keep v1 for positioning, pricing, GTM, and IP strategy — those still stand.*

---

## 0. What I got wrong in v1

I told you not to use Claude Code as your production runtime. Based on current docs and verified power-user patterns, that was the wrong call. Here is what I missed:

1. **Claude Code authenticates two different ways.** OAuth via the Max subscription (locked to personal use, the path I correctly warned against) — OR — `ANTHROPIC_API_KEY` environment variable, which bills at standard API rates. When `ANTHROPIC_API_KEY` is set, Claude Code uses it and ignores the OAuth subscription entirely. Anthropic's own docs confirm this. That is the legitimate multi-tenant path.

2. **Claude Code's sub-agents map 1:1 to Nick Puru's architecture.** Sub-agents are defined as markdown files in `.claude/agents/`, each with a YAML frontmatter declaring role, model, tool access, and system prompt. The "operator pattern" — one orchestrator delegating to specialized sub-agents — is a first-class supported workflow. Nick's director/sub-agent hierarchy is literally the stock Claude Code agent-teams pattern.

3. **Headless mode + cron is a proven 24/7 pattern.** The `-p` flag runs Claude Code as a one-shot command, no terminal, exit when done. Triggered on a schedule, it behaves like any other cron job. Public example in the wild: *"OpenClaw has 140k GitHub stars. I built the same thing with Claude Code, cron, and ~200 lines of shell scripts."* That's the pattern.

4. **Prompt caching makes the API economics very different to what I assumed.** Enterprise Claude Code users report roughly $150–250/developer/month in heavy use, because 90%+ of tokens in a repeated-context workload are cache reads at 10% of input price ($0.50/M for Opus, lower for Sonnet/Haiku). For a batch-style agent workload like ours, unit cost per tenant lands ~£100–300/mo, not the £400+ I budgeted.

5. **Hooks turn Claude Code from reactive to proactive.** `PreToolUse`, `PostToolUse`, and session-lifecycle hooks fire shell commands on events. Edit a file → tests run → output injected back as context. This is how agents become anticipatory rather than waiting-for-prompts. Same mechanism lets you wire arbitrary integrations without MCP.

Revised verdict: **Claude Code is the runtime.** Not OpenClaw yet. Not a bespoke orchestrator I told you to build in v1. Claude Code, running headless, per-tenant, with API-key auth.

---

## 1. The top 1% Claude Code power-user playbook

Before we design your stack, here is what the best Claude Code operators are actually doing. Every pattern below is documented in current Anthropic docs or proven in the wild by power users.

### 1.1 Sub-agents as your unit of productization

Sub-agents live in two scopes:

- **Project scope:** `.claude/agents/*.md` in a repo. Shipped alongside code. Tenant-specific.
- **User scope:** `~/.claude/agents/*.md` on the machine. Shared across all sessions. Your library.

Each sub-agent is a markdown file with YAML frontmatter:

```
---
name: proposal-builder
description: Drafts a fully-scoped proposal from a Fathom call transcript and past winning proposals. Invoke when a new call transcript lands in the intake folder.
model: sonnet
tools: Read, Write, Edit, mcp__hubspot__*, mcp__docusign__*
permission_mode: acceptEdits
---

You are a proposal builder for IntelForce clients. Your job is to take a
Fathom discovery call transcript and produce a professional proposal...
```

The main Claude session dispatches to sub-agents automatically based on their `description`. Critically: **sub-agents have their own context windows**. The orchestrator doesn't carry proposal-drafting clutter when it later dispatches to a follow-up agent. Context hygiene is built in.

**Constraint worth knowing:** sub-agents cannot spawn other sub-agents. One level of delegation only. That means your 9 agents sit flat under the orchestrator, not in nested departments. The "Sales Director / Operations Director" framing is for marketing, not for the runtime structure.

### 1.2 Model routing per agent

Every sub-agent declares its own `model`. Use this aggressively to control cost:

- **Haiku 4.5** — Lead Hunter (qualification is pattern-matching), Caption Writer (short output), Repurposer (format transforms)
- **Sonnet 4.6** — Proposal Builder, Content Creator, Follow-Up Pilot, Reporting Engine, Client Onboarder (most general work)
- **Opus 4.7** — SOP Writer (complex extraction from Loom), reserved tier — only when the output visibly needs it

Rough cost profile: an 80/15/5 split between Haiku/Sonnet/Opus lands per-tenant spend in the £80–180/mo range, well inside your retainer margins.

### 1.3 MCP as the integration layer

Model Context Protocol servers are first-class in Claude Code. Standard SaaS tools have native MCP servers now: HubSpot, Slack, Gmail (via Gmail MCP), Notion, DocuSign, Stripe. Where a tool doesn't have an official MCP server, two fallbacks:

1. **Your own MCP server** — a Node or Python wrapper around their REST API. Takes half a day per integration once you've done one.
2. **n8n as a bridge** — fire a webhook to an n8n workflow that does the actual integration work. Crude but fast.

Each tenant gets their MCP servers listed in `.claude/mcp.json`, with their OAuth tokens scoped to their tenant directory. Your provisioning system templates this file at deployment time.

### 1.4 Hooks — where Claude Code becomes proactive

Two patterns you'll use constantly:

**PostToolUse hook → loop closure.** After Claude writes a proposal file, a hook runs your validation script (did it include a price? a timeline? a signature block?). Output of the hook is injected back as context. If validation fails, Claude self-corrects without a human in the loop.

**SessionStart hook → memory hydration.** When a new session boots, a hook runs a script that pulls the last 24 hours of relevant notes from the Obsidian vault and stuffs them into context. No prompt engineering needed — the agent always starts with fresh memory.

Hooks are shell commands configured in `~/.claude/settings.json`:

```
{
  "hooks": {
    "SessionStart": [{ "hooks": [{ "type": "command", "command": "/opt/intelforce/hydrate-memory.sh" }] }],
    "PostToolUse": [{ "matcher": "Write", "hooks": [{ "type": "command", "command": "/opt/intelforce/validate-output.sh" }] }]
  }
}
```

### 1.5 Headless mode is the default production interface

```
claude -p "Pick up any Fathom transcripts dropped in /intake/fathom/ in the last hour. For each: draft a proposal using the Proposal Builder sub-agent, save to /outbox/proposals/, send to the assigned sales lead via Slack." --output-format json
```

One command. Fires from cron, a webhook receiver, a file-watcher, or a dashboard button. Exits when done. stdout → logs. JSON output → parsed by your dashboard for activity-log updates.

### 1.6 CLAUDE.md as the persistent brain stem

CLAUDE.md in the project root is auto-loaded on every session. It's not memory in the traditional sense — it's the *always-present* context. Use it for:

- Who this client is, their industry, their ICP
- Voice/tone guidelines (extracted from brand docs at onboarding)
- Key people (so agents @-mention the right person)
- Links into the Obsidian vault (`See /vault/clients/acme-dental/` for historical context)

CLAUDE.md stays short — under 4KB. It's the primer. The bulk of memory lives in the Obsidian vault (see §4).

### 1.7 Agent teams vs. operator pattern — pick operator

Claude Code supports two multi-agent patterns:

- **Operator (orchestrator + sub-agents):** one main session delegates to specialized sub-agents. Low context overhead. Deterministic dispatch.
- **Agent teams:** multiple peer Claude instances collaborate (researcher ↔ writer ↔ reviewer). Burns ~7x the tokens. Powerful but expensive.

**You want operator.** Your 9 agents are specialists with clear boundaries, not peers. Agent teams is a feature to keep in your back pocket for premium enterprise custom work where cost is less of a concern than quality.

### 1.8 The `/loop` command and Routines (worth knowing, probably not adopting)

Two newer features that sound relevant but aren't quite the right fit for you:

- **`/loop`** — session-bound continuous execution. Great for "keep iterating on this until it's right" inside one session. Not suitable for 24/7 because it dies with the session.
- **Routines** — Anthropic-hosted scheduled agent execution. Cron, but in Anthropic's cloud. Requires Max plan. Interesting but it locks you to Anthropic infrastructure and the economics only work if your tenant has their own Max plan. For multi-tenant SaaS, self-hosted cron on your VPS remains cheaper and more controllable.

Keep both in the back pocket for a future "IntelForce Cloud" tier where you can charge a premium for fully-managed scheduled execution with no client infrastructure.

---

## 2. The IntelForce AI OS runtime architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│ CONTROL PLANE (Next.js + Node · your infra · multi-tenant)           │
│                                                                      │
│  - Auth, tenant mgmt, billing (Stripe)                              │
│  - Configuration wizard (the 72-hour onboarder)                      │
│  - Tenant provisioning service                                       │
│  - Real-time dashboard (WebSocket)                                   │
│  - Usage metering & cost allocation                                  │
└──────────────────────┬───────────────────────────────────────────────┘
                       │ provisions →
                       ▼
┌──────────────────────────────────────────────────────────────────────┐
│ PER-TENANT RUNTIME CONTAINER (Docker · one per client · UK VPS)      │
│                                                                      │
│  /tenant                                                             │
│    /.claude                                                          │
│      settings.json              ← hooks, permissions, model defaults │
│      mcp.json                   ← tenant-specific integration creds  │
│      /agents                                                         │
│        lead-hunter.md           ← templated from your library        │
│        proposal-builder.md                                           │
│        follow-up-pilot.md                                            │
│        content-creator.md                                            │
│        repurposer.md                                                 │
│        caption-writer.md                                             │
│        client-onboarder.md                                           │
│        reporting-engine.md                                           │
│        sop-writer.md                                                 │
│    CLAUDE.md                    ← the brain stem (client identity)   │
│    /vault                       ← Obsidian vault (the brain)         │
│    /intake                      ← landing zone for triggers          │
│    /outbox                      ← agent outputs                      │
│    /logs                        ← activity logs for dashboard        │
│                                                                      │
│  ENV: ANTHROPIC_API_KEY=sk-ant-... (tenant-scoped)                   │
│  cron jobs running `claude -p "..." --output-format json`            │
│  webhook receiver (Node, port-bound per tenant)                      │
│                                                                      │
└──────────────────────┬───────────────────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────────────────┐
│ ANTHROPIC API (api.anthropic.com) · billed per-tenant                │
│   Sonnet 4.6 · Haiku 4.5 · Opus 4.7 (reserved)                       │
└──────────────────────────────────────────────────────────────────────┘

                              ↑ ↓
                              
┌──────────────────────────────────────────────────────────────────────┐
│ CLIENT INTEGRATIONS (OAuth'd at onboarding)                          │
│   HubSpot · Fathom · Gmail · Slack · Notion · DocuSign · Stripe      │
│   via MCP servers (official where available, your wrappers elsewhere)│
└──────────────────────────────────────────────────────────────────────┘
```

### 2.1 Why this architecture works at scale

- **One Claude Code install per tenant** in its own container. Complete isolation. Tenant A's MCP creds never touch Tenant B. Tenant A's vault never leaks.
- **API-key auth** (not OAuth). Each tenant has their own Anthropic API key (provisioned under your organisation account, or — better — under *their* organisation account if they want full sovereignty). You can revoke a tenant's key without touching any other tenant.
- **Your agent library is versioned separately** from any single tenant. You push an update to `proposal-builder@v2.1`, CI redeploys it across all tenants who are on auto-update. The Configuration Center has a "pin agent version" toggle for conservative clients.
- **The container is fungible.** Kill it, respawn it. Configuration is declarative (the JSON/markdown files) and data is in the vault. Nothing is stuck in process memory.

### 2.2 The single most important file: the agent template library

This is your IP. This is what you guard.

```
/intelforce-agents (private repo)
  /agents
    /lead-hunter
      lead-hunter.md           ← the prompt template
      tools.yaml               ← required MCP servers
      config-schema.json       ← what the wizard collects
      validation.sh            ← hook script for output checks
      README.md                ← docs
    /proposal-builder
      ...
  /addons
    /voice-receptionist
    /hr-agent
    /seo-brief
    /ads-copywriter
  /verticals
    /dental
      extends: [base]
      overrides: content-creator.md  ← dental-specific tone
      extra-agents: [dentally-sync.md]
    /agency
      ...
```

Every client deployment is `base + vertical + addons`. You never write a bespoke agent — if a client needs something new, it becomes a new entry in `/addons` and goes into the library.

### 2.3 The provisioning flow (the "scaling IP")

When a client finishes the 72-hour wizard:

1. Control plane reads their `config.json` (answers from the wizard)
2. Picks the right `/verticals/{industry}` recipe
3. Layers on their selected `/addons`
4. Templates each agent's markdown with their specifics (their ICP, their tools, their names)
5. Encrypts and writes their integration OAuth tokens into `mcp.json`
6. Bakes a tenant Docker image (or writes to an existing shared image with tenant config mounted)
7. Starts the container, registers webhook endpoints, installs cron entries
8. Fires smoke tests across all 9 agents
9. Flips the dashboard to "Live" and notifies you

End-to-end under 15 minutes of compute time. Your human time: approve the voice profile in the wizard, review smoke-test outputs, kickoff call. Target: under 4 hours of your time per client.

This is the IP. Not the agents. Not the dashboard. **The provisioning system that deploys 9 perfectly-configured agents in 15 minutes.**

---

## 3. How 24/7 operation actually works

Three trigger modes cover every use case. Every IntelForce agent invocation flows through one of these.

### 3.1 Scheduled (cron)

Example: **Reporting Engine** runs every Friday 07:00 UK time.

```
0 7 * * 5 cd /tenant && claude -p "Run the Reporting Engine. Pull last 7 days from Stripe, GA4, Meta Ads, and HubSpot. Produce the weekly briefing. Save to /outbox/reports/. Post the summary to #leadership in Slack." --output-format json >> /logs/reporting-$(date +\%Y\%m\%d).log 2>&1
```

Simple. Robust. If the cron job fails, systemd restarts it. If Claude errors mid-task, `--output-format json` gives you a structured error that the dashboard surfaces as an alert.

Per-tenant cron table:
- Lead Hunter: every 2 hours during business hours
- Follow-Up Pilot: daily at 10:00 and 15:00
- Reporting Engine: weekly Friday 07:00
- Caption Writer: daily at 16:00 (queues next-day content)
- Content Creator: on brief submission (no cron — webhook)
- Repurposer: on new pillar content published (no cron — webhook)
- Client Onboarder: on contract signature (no cron — webhook)
- Proposal Builder: on Fathom call end (no cron — webhook)
- SOP Writer: daily sweep at 03:00 for new Loom recordings

### 3.2 Event-driven (webhooks)

Example: **Proposal Builder** fires when a Fathom call ends.

A small webhook receiver per tenant (Node, Fastify, 80 lines) listens on a tenant-specific URL (`hooks.intelforce.ai/{tenant-id}/fathom`). Incoming payload is written to `/intake/fathom/{call-id}.json`, which triggers:

```
claude -p "A new Fathom call transcript is at /intake/fathom/{call-id}.json. Use the Proposal Builder sub-agent to draft a proposal. Save to /outbox/proposals/. Email {assigned-rep} for review." --output-format json
```

The receiver is also where you'd handle:
- HubSpot: new lead marked hot → Follow-Up Pilot drafts outreach
- DocuSign: contract signed → Client Onboarder fires
- YouTube: new video published → Repurposer kicks off
- Loom: new recording ready → SOP Writer adds to queue

### 3.3 Manual (dashboard "Run now" button)

The dashboard Run Now button (the one in the prototype I sent) POSTs to the tenant's control-plane endpoint, which writes a trigger file into `/intake/manual/`. A file-watcher fires `claude -p`. Result streams back to the dashboard via WebSocket and updates the activity log in real time.

### 3.4 The observation loop

Every `claude -p` invocation writes structured JSON to `/logs/`. A lightweight log shipper (Vector, or just a tail-and-forward script) streams these to your control plane, which:

1. Writes to Postgres for long-term audit
2. Pushes to the tenant's dashboard via WebSocket for real-time activity log
3. Alerts on errors (Slack to you for now, eventually per-client Slack)

You see every agent action across every tenant in one pane. This is also the substrate for your future "IntelForce Copilot" — an observability agent that watches the other 9 and raises issues proactively.

### 3.5 What does NOT run 24/7 (and why that's fine)

Claude Code sessions do not sit idle waiting for work. Each invocation is ephemeral: spawn → execute → exit. This is a feature, not a limitation:

- No memory leaks, no drifting state
- No rate limit accumulation from keep-alives
- Cost only flows when work flows
- Failed sessions don't take down a whole tenant — next invocation is clean

The "always-on" in "24/7 agentic workforce" is a property of the *triggers*, not the runtime. Cron and webhooks are always on. The agents wake up, do their work, go back to sleep. This is genuinely how Anthropic themselves architect their own automations.

---

## 4. The memory architecture — the brain

This is where the Obsidian question gets answered. First, the layered model, then Obsidian specifically.

### 4.1 Four memory layers

| Layer | What it stores | How it's read | Where it lives |
|---|---|---|---|
| **CLAUDE.md (brain stem)** | Client identity, voice, key people, pointers into the vault | Auto-loaded every session | Project root |
| **Obsidian vault (cortex)** | All structured knowledge: clients, deals, SOPs, content, past proposals, brand docs, call transcripts | Read on-demand by agents via file tools | `/vault/` |
| **Structured DB (working memory)** | Per-agent state, job queues, deduplication keys, tenant metadata | Read/written by the control plane | Postgres (shared, tenant-scoped) |
| **Vector index (recall)** | Semantic search across the vault for agents to "remember similar past work" | Queried via MCP vector-search server | pgvector on the same Postgres |

### 4.2 The Obsidian vault — how it actually works inside the runtime

The vault is just a directory of markdown files with a particular set of conventions (`[[links]]`, frontmatter, daily notes, tags). Claude Code natively reads markdown. There is no integration layer to build. The integration IS the filesystem.

```
/vault
  /clients
    /{client-name}
      profile.md              ← one-pager on the client
      deals.md                ← pipeline, updated by Lead Hunter
      conversations/
        2026-04-22-discovery.md  ← Fathom transcripts, tagged
      proposals/
        2026-04-22-acme.md    ← output from Proposal Builder
  /sops
    new-patient-intake.md     ← output from SOP Writer
    proposal-review.md
  /content
    pillars/
      2026-04-pricing-article.md
    derivatives/
      2026-04-pricing-linkedin.md
      2026-04-pricing-instagram.md
  /brand
    voice-profile.md          ← core doc; referenced in CLAUDE.md
    past-winning-proposals/
  /daily
    2026-04-22.md             ← auto-generated daily rollup
```

### 4.3 Why Obsidian specifically (and it's not overkill)

Claude could use any directory of markdown. But the Obsidian wrapper buys you four things that justify the choice:

1. **The graph view.** Clients can open their vault in Obsidian and literally *see* their business brain. Notes linked by `[[wikilinks]]` render as a force-directed graph. A new proposal auto-links to the client, which links to past deals, which links to brand voice. The graph grows visibly over time. This is a pure wow-factor feature for sophisticated buyers.

2. **Client-editable memory.** A dental practice manager can open their vault, edit `profile.md` ("We stopped offering veneers in March"), save. Next time any agent runs, it reads the updated profile. Memory becomes a two-way channel — the client trains the AI by editing their notes, not by "fine-tuning" or "prompt engineering." This is enormous for UK small-business buyers who are suspicious of opaque AI.

3. **Portability & sovereignty.** The vault is a folder of text files. Client churns? Give them a zip. Regulator asks what data you hold on a practice? It's visible, greppable, auditable markdown. This feeds directly into your UK-sovereign positioning.

4. **Mobile & offline consult.** Obsidian Mobile lets a client browse their brain on their phone on the train. No app to build. No "connect your account." Just the vault synced via iCloud/Obsidian Sync/git.

### 4.4 Is it overkill? Here's the honest split

**For dental practices and other non-technical SMEs:** probably yes as a default. Don't force Obsidian on them. Build a "Brain" tab in the dashboard that renders the vault as a graph (server-side — there are open-source libs for this; you can pull directly from the markdown files). They see the brain inside your dashboard. If they're curious, they can install Obsidian and point it at the synced vault. Most won't. That's fine.

**For agency owners, course sellers, consultants, knowledge workers:** hell no it's not overkill. These are people who already have Obsidian or Notion setups. They understand and value the graph. Sell it hard. Include it on the pricing page. *"Your AI workforce has a brain you own, in a format you control, that you can edit directly. Open it in Obsidian. Browse it on your phone. Export it any time."*

**The hybrid build:** the vault is always there on the backend. The dashboard renders a "Brain" view of it. Obsidian client-side is optional, positioned as a premium self-serve feature, zero extra work for you to support.

### 4.5 Memory hygiene — the risk nobody talks about

A vault that grows unchecked becomes noise. Three patterns to enforce from day one:

- **Daily notes auto-compaction.** An agent (your hidden 10th agent — "The Librarian") runs nightly, rolls up the day's activity into a daily note, archives raw logs older than 30 days into `/vault/archive/`.
- **Tag hygiene.** Enforce frontmatter at write time via a `PostToolUse` hook. Every generated note must have `client`, `agent`, `date`, `status` tags. No free-form dumping.
- **Retrieval, not recall.** When an agent needs to remember, it doesn't load the whole vault — it uses the vector index to pull the 3–5 most relevant notes. Context window stays tight, cost stays low, outputs stay focused.

Skip this and in 6 months the vault is a swamp and agents start producing worse outputs because they're drowning in their own history.

---

## 5. ICP expansion — agencies and course sellers

You were right to push back on v1. I was snobby about this ICP. Reality check: agency owners and info-product sellers are the buyers most likely to *understand* what you're building, to *have budget*, and to *tell other agencies about you*. Here's the revised ICP.

### 5.1 Agency owners — the single highest-leverage ICP

UK marketing / SEO / paid / content / web-design agencies, £300k–2M revenue, 3–20 staff.

Why they're perfect:
- They understand AI and automation — no education cost
- They have operational pain that maps exactly to the 9 agents (proposals, client reporting, content production, lead gen)
- They have budget (£1–5k/mo on tooling is normal)
- They will tell other agencies if it works
- **They can resell.** See §5.3 below.

Pain points the 9 agents solve for them:
- Proposal Builder → they do 5+ proposals a week, currently manual
- Reporting Engine → client reporting is 20% of their week, pure deadweight
- Lead Hunter → their own new-business pipeline
- Content Creator / Repurposer → they sell this to clients but can't scale their own content
- Client Onboarder → they onboard 2–4 clients a month and it's always chaos
- SOP Writer → they have tribal knowledge that never gets documented

Pitch: *"Stop selling AI workflows you can't build. Start using — and white-labelling — a platform that runs your agency AND runs your clients' businesses."*

Pricing for agency direct: £7.5k setup + £2k/mo (Growth plan). Sell it as "saves 40 hours a week in your own ops, and you'll pay for it in one recovered proposal."

### 5.2 Course sellers / info-product owners

UK (and some international) info-product businesses, £200k–5M, often solo or <5 staff, building around a personal brand.

Why they fit:
- They live on content production — Content Creator, Repurposer, Caption Writer are gold
- They run email-heavy funnels — Follow-Up Pilot
- They need student onboarding — Client Onboarder
- They want reporting dashboards they can screenshot for their own content
- **They are YOU.** The yacht content, the personal brand, the lifestyle-first positioning — that's the exact market. You're selling to your own tribe. That is the single biggest distribution unlock you have.

Pricing: £5k setup + £1.5k/mo (they lean content-heavy so the Marketing trio plus Reporting Engine plus Client Onboarder is the core value). Some will go Growth tier for the full 9.

### 5.3 The agency white-label play — this changes the business model

Here is the unlock I completely missed in v1.

An agency buys IntelForce AI OS for themselves. They love it. They say: "I want to sell this to my 12 clients."

Build this as a formal tier: **Agency Partner**.

| Feature | Standard | Agency Partner |
|---|---|---|
| Setup | £7.5k | £15k |
| Monthly | £2k | £5k |
| Sub-tenants | 1 | up to 10 (then +£300/mo each) |
| White-label | No | Yes — their logo, their domain, their colours |
| Revenue share | N/A | They charge clients, keep margin |
| Support | Business hours | Priority + dedicated Slack |

What this unlocks:
- **Sales velocity.** One agency partner = 10 sub-tenants at once. You land one partner, you've landed 10 clients without doing 10 sales cycles.
- **Distribution.** Agencies talk to agencies. Land 3 agency partners, you're in the network.
- **Better unit economics.** Agency partners are low-touch — they onboard their own sub-tenants using your wizard, they do first-line support, you handle L2/L3.
- **Defensibility.** An agency that's built a book of IntelForce sub-tenants isn't switching. Churn plummets.

Technical lift to support this: the Configuration Center already handles tenants. White-label is a CSS/domain layer plus a "parent tenant" concept in the DB. Maybe two weeks of work. Do it in v1.2, pitch it at v1.0.

**This is probably how Nick Puru actually makes his money.** Not 1:1 client sales. Agency partners reselling at scale.

### 5.4 Revised ICP tiers

```
Tier 0 — Founding customers (first 5)                     £2.5k setup · £800/mo
   Any fit. Deeply discounted. Case study required.

Tier 1 — SME direct                                       £3–7.5k · £800–2k/mo
   Dental practices, clinics, law firms, accountants
   Design/creative studios, boutique hotels
   B2B SaaS, consultancies

Tier 2 — Operator direct (highest-ROI ICP)                £5–15k · £1.5–3k/mo
   Marketing/SEO/paid agencies (direct use, not reselling)
   Course sellers and info-product businesses
   Coaches and consultancies with £500k+ revenue

Tier 3 — Agency Partner (the distribution lever)          £15k · £5k/mo + seats
   Agencies reselling IntelForce to their clients
   White-labelled, sub-tenant model

Tier 4 — Enterprise                                       £50k+ · £5k+/mo
   Rigby Group divisions (SCC, Eden, Allect)
   PE portfolio companies
   Government adjacencies

Kill list
   E-commerce, solo creators <£100k, crypto, US-only, anyone who won't pay retainer
```

Sell Tier 1 for volume. Sell Tier 2 for fit. Sell Tier 3 for leverage. Sell Tier 4 for the brand.

---

## 6. Failure modes, and the reality of running this

Honest catalogue of what breaks and how you handle it.

### 6.1 API provider risk

Anthropic changes API pricing, rate limits, or Claude Code behaviour. You are single-vendor locked.

- **Mitigation:** abstract model selection per-agent. If Sonnet doubles in price, flip Content Creator to a cheaper model in config without touching orchestration.
- **Longer-term:** Kimi K2.5 or similar as a fallback runtime for non-critical agents. You've already explored this. Keep it warm.

### 6.2 MCP server fragility

MCP is early. Servers break. Rate limits bite. Versions drift.

- **Mitigation:** every MCP server your tenants depend on runs with a health check. Dashboard shows integration status. Failed MCP calls retry twice, then flip to "needs attention" on the agent's detail card.
- **Fallback:** for any critical integration where MCP is unstable, build a direct API wrapper yourself. Takes a day per integration; pays back forever.

### 6.3 Memory decay

The vault grows. Agents lose focus. Outputs get mediocre. You won't notice until a client does.

- **Mitigation:** the Librarian sub-agent (nightly rollup). Quarterly vault audits where you run a "vault health" report.
- **Tell:** if the average number of context notes per agent invocation climbs above ~8, the vault is getting noisy. Instrument this.

### 6.4 Cost blowout per tenant

A client's HubSpot has 200k records. Lead Hunter tries to process them all. Bill spikes.

- **Mitigation:** hard-cap per-tenant daily API spend. Throttle at 80% of monthly budget. Kill switch at 100%. Alert immediately.
- **Contractual:** your pricing explicitly includes "up to £X in API consumption, overages billed at cost". This protects both sides.

### 6.5 The bus factor

You are one person. The dev you're hiring is one person. One illness, one holiday, and 20 live tenants break.

- **Mitigation:** from week one, every deployment is one-command reproducible. Runbooks in the vault (meta-eat your own food). Rotate the on-call (when there's anyone to rotate with).
- **By client #15:** hire an ops person. £40–50k salary (UK) for a decent junior. Their only job is monitoring and L1 client support. Your gross margin supports this easily.

### 6.6 The thing that actually kills the business

Not infrastructure. Not cost. Not Anthropic policy changes.

**You ship something that works 80% of the time and a single high-profile client screws up a proposal because Proposal Builder hallucinated a price, and they post about it.** Trust is the moat and the liability.

Mitigation: **human-in-the-loop at the trust boundary.** Every proposal gets reviewed by the sales lead before it sends. Every invoice-adjacent action requires a human click. Every external-facing piece of content goes to a "review" inbox before posting. Agents draft and queue. Humans approve. This is not a limitation — it's a feature. You are augmenting the team, not replacing them. Sell it that way from day one.

---

## 7. What you build in week 1 to prove this works

Nothing above matters if it doesn't run. Week 1 is a single experiment:

**The Proposal Builder, end-to-end, in one tenant, fully real.**

Concretely:
1. Spin up a Docker container with Claude Code + `ANTHROPIC_API_KEY`
2. Drop in a single `proposal-builder.md` sub-agent
3. Connect Fathom (MCP or API wrapper) and a Notion output
4. Wire one webhook endpoint that fires on Fathom call end
5. Run a real discovery call (you, with a friendly prospect or Jack)
6. Watch the proposal land in Notion within 90 seconds of the call ending

If this works, you have validated:
- API-key auth path
- Sub-agent definitions
- MCP/webhook trigger
- The 72-hour onboarding is feasible
- The cost economics are real (you can see the exact tokens burned)

If it doesn't work, you find out in week 1, not week 9. The rest of the build is mechanical repetition of the same pattern.

Do not start on the dashboard. Do not start on the wizard. Do not start on the vault. One agent. One container. One webhook. One real output.

Everything else is v1.1.

---

## 8. Where this leaves OpenClaw

OpenClaw is not dead in this strategy. It stays in the narrative:

- **Marketing story:** *"IntelForce AI OS runs on Claude Code with the OpenClaw orchestration layer for enterprise-grade governance and UK-sovereign deployment."* Vague enough to be true (OpenClaw is your sovereignty thesis), specific enough to sound serious.
- **Enterprise tier:** the Rigby Group / government-adjacent pitch is where OpenClaw as *infrastructure* makes sense. SCC won't deploy on Claude Code; they'll deploy on a governance-wrapped orchestration layer that happens to route to Claude models. That's the OpenClaw story.
- **Product roadmap:** v2 (Q3+) has an "OpenClaw runtime" option for clients who need fully on-prem / air-gapped deployments. You build this later, when enterprise demand justifies the engineering cost.

Meanwhile for v1: Claude Code, because it ships.

---

## 9. The TL;DR decisions this doc commits you to

1. **Runtime:** Claude Code, per-tenant Docker container, API-key auth. Not Max OAuth. Not custom orchestrator. Not OpenClaw (yet).
2. **Architecture:** operator pattern — one session orchestrates, 9 sub-agents specialise. Flat hierarchy (sub-agents can't nest). Model routing per agent for cost.
3. **24/7:** cron + webhooks + manual triggers. Agents are ephemeral; triggers are always-on.
4. **Memory:** four layers — CLAUDE.md / Obsidian vault / Postgres / pgvector. Vault is the cortex. Librarian sub-agent keeps it tidy.
5. **Obsidian:** yes, not overkill. Hidden behind dashboard for SMEs; sold hard to agencies/operators; always present on the backend.
6. **ICP expansion:** agencies and course sellers are added as Tier 2. Agency Partner white-label becomes the Tier 3 distribution lever.
7. **Week 1 experiment:** Proposal Builder end-to-end in one container. Everything else waits.

---

*Revised from v1. Commit to this and start building the proof point. Everything else — dashboard polish, wizard flow, pricing page — is assembly once the runtime is proven.*
