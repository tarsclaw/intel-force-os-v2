# Architecture Overview

**Purpose:** the 10-minute system tour. Anyone new to the project should read this before any other technical document.

---

## 1. The one-sentence version

A multi-tenant platform where each tenant runs a supervised Claude Code container with a curated set of sub-agents, a git-synced vault for context, and webhook-driven triggers — all configured through a dashboard that non-technical operators can use.

---

## 2. System diagram

```
┌───────────────────────────────────────────────────────────────────────────┐
│                           EXTERNAL ORIGINS                                │
│                                                                           │
│  Fathom webhooks   HubSpot webhooks   Stripe webhooks   Dashboard "Run"   │
└─────────────┬─────────────┬─────────────────┬────────────────┬────────────┘
              │             │                 │                │
              ▼             ▼                 ▼                ▼
        ┌─────────────────────────────────────────────────────────┐
        │   Cloudflare (DDoS, cert, WAF)                          │
        └────────────────────────┬────────────────────────────────┘
                                 │
                                 ▼
        ┌─────────────────────────────────────────────────────────┐
        │   Webhook Receiver (Fastify)                            │
        │   — HMAC signature verification                         │
        │   — Redis dedup (7-day TTL)                             │
        │   — Per-tenant filter rules                             │
        │   — Tenant registry lookup (Postgres + in-memory cache) │
        │   — Unix socket dispatch to supervisor                  │
        └────────────────────────┬────────────────────────────────┘
                                 │
                                 │ Unix socket per tenant
                                 ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │            TENANT CONTAINER (one per customer)                  │
  │                                                                 │
  │   ┌──────────────────────────────────────────────────────────┐  │
  │   │  tenant-supervisor (Node, long-running)                  │  │
  │   │  — Unix socket listener                                  │  │
  │   │  — cron scheduler                                        │  │
  │   │  — Worker pool (3 concurrent invocations)                │  │
  │   └─────┬─────────────────────────┬─────────────┬────────────┘  │
  │         │                         │             │               │
  │         ▼                         ▼             ▼               │
  │   ┌──────────┐            ┌──────────────┐  ┌─────────┐         │
  │   │ cc-invoke│            │ vault-syncer │  │ Vector  │         │
  │   │ (spawned │            │ (persistent, │  │ (log    │         │
  │   │ per job) │            │ git push/pull│  │ shipper)│         │
  │   └────┬─────┘            └──────┬───────┘  └────┬────┘         │
  │        │                         │               │              │
  │        ▼                         ▼               │              │
  │   ┌──────────────┐         ┌──────────┐          │              │
  │   │ Claude Code  │         │  GitHub  │          │              │
  │   │ (ANTHROPIC_  │         │  vault   │          │              │
  │   │  API_KEY)    │         │  repo    │          │              │
  │   └──────┬───────┘         └──────────┘          │              │
  │          │                                       │              │
  │     ┌────┴─────┬────────────┐                    │              │
  │     ▼          ▼            ▼                    │              │
  │  ┌─────┐   ┌─────┐      ┌──────┐                 │              │
  │  │.md  │   │.sh  │      │ MCP  │                 │              │
  │  │agent│   │hook │      │servers│                │              │
  │  └─────┘   └─────┘      └───┬──┘                 │              │
  │                             │                    │              │
  │                             ▼                    │              │
  │                    (Fathom, HubSpot,             │              │
  │                     Gmail, Notion,               │              │
  │                     DocuSign, Slack,             │              │
  │                     Cohere, etc.)                │              │
  │                                                  │              │
  │   ┌──────────────────────────────────────────────┴────────────┐ │
  │   │ /tenant/ filesystem (mounted volume)                       │ │
  │   │ ├── CLAUDE.md                                              │ │
  │   │ ├── .claude/agents/{name}/agent.md                         │ │
  │   │ ├── vault/                  ← the Obsidian vault           │ │
  │   │ ├── intake/{integration}/   ← trigger payloads             │ │
  │   │ ├── outbox/{kind}/          ← agent outputs                │ │
  │   │ └── logs/                   ← JSONL structured logs        │ │
  │   └────────────────────────────────────────────────────────────┘ │
  └─────────────────────────────────────────────────────────────────┘
                                 │
                                 │ (logs, metrics, telemetry)
                                 ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │            CONTROL PLANE (shared across all tenants)            │
  │                                                                 │
  │   — Postgres (tenant registry, metadata, pgvector embeddings)   │
  │   — Redis (dedup, rate limiting, session cache)                 │
  │   — Loki + Grafana (log aggregation, dashboards)                │
  │   — Prometheus (metrics)                                        │
  │   — Provisioning System (new-tenant onboarding orchestrator)    │
  │   — Secrets vault (KMS-wrapped, per-tenant encryption)          │
  │                                                                 │
  └────────────────────────┬────────────────────────────────────────┘
                           │
                           │ (HTTPS, authenticated)
                           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │            DASHBOARD (Next.js monorepo with tRPC)               │
  │                                                                 │
  │   — Configuration Wizard (per-tenant onboarding)                │
  │   — Brain view (the Obsidian vault, rendered)                   │
  │   — Operations Control (live feed, agent toggles, run-now)      │
  │   — Activity log                                                │
  │   — Agency Partner portal (white-label tenancy)                 │
  │                                                                 │
  └─────────────────────────────────────────────────────────────────┘
```

---

## 3. Component descriptions

### 3.1 Webhook Receiver
Stateless Fastify service. Public internet-facing. Catches webhooks from Fathom/HubSpot/Stripe/DocuSign/Calendly, verifies signatures, deduplicates, and dispatches to the relevant tenant's supervisor via Unix socket. One public endpoint per tenant per integration. Spec: `phase-1-poc-stack/platform-specs/webhook-receiver-spec.md`.

### 3.2 Tenant Container
One Docker container per customer. Shared base image (Debian slim + Node 20 + Python 3.11 + Claude Code + helpers). Per-tenant config mounted at `/tenant/`. Runs a long-lived supervisor process that listens for triggers and spawns Claude Code sessions on demand. Container does not hold persistent Claude Code state — every invocation is a fresh session with hydrated context. Spec: `phase-1-poc-stack/platform-specs/tenant-container-spec.md`.

### 3.3 Tenant Supervisor
Thin Node process. The container's entrypoint. Responsibilities:
- Unix socket listener (accepts triggers from webhook receiver)
- Cron scheduler (fires scheduled jobs like Librarian's nightly sweep)
- Worker pool (runs up to N concurrent Claude Code sessions, N = plan-dependent)
- Health endpoint
- Log rotation + graceful shutdown

### 3.4 cc-invoke
Wrapper around the Claude Code CLI. Called by supervisor for each trigger. Handles:
- Trigger payload path resolution
- Environment variable injection (ANTHROPIC_API_KEY from secrets vault)
- Exit code capture + structured logging
- Per-invocation cost attribution

### 3.5 Claude Code (the runtime)
Anthropic's official CLI. Runs as the primary agent runtime. Auth: `ANTHROPIC_API_KEY` environment variable with per-tenant metadata tags (C2a default). Loads the relevant `agent.md` as its system prompt, runs the 9-step workflow, uses MCP tools, writes to vault, exits.

### 3.6 MCP Servers
Model Context Protocol servers that give Claude Code access to external tools. Configured per-tenant in `.claude/mcp.json`. Each server authenticates with tenant-specific OAuth tokens or API keys stored in the secrets vault. Full catalogue in each agent's `tools.yaml`.

### 3.7 Vault Syncer
Persistent sidecar process inside the tenant container. Watches `/tenant/vault/` for filesystem writes (via inotify), debounces 30s, commits with attribution (`agent: {name} — {summary}`), pushes to tenant's private GitHub repo under `intelforce-vaults` org. Every 15 minutes, pulls to pick up client-side Obsidian edits.

### 3.8 Vault
Each tenant has a dedicated Obsidian vault. Structure defined in `phase-1-poc-stack/platform-specs/minimal-vault-structure.md`. The vault is:
- The source of truth for voice profile, pricing framework, service catalogue, case studies, SOPs
- The target for agent outputs (proposals, reports, content)
- The source for pgvector retrieval (via the Librarian's continuous indexer)
- A genuine Obsidian-compatible directory — clients can open it in the Obsidian app if they want

### 3.9 Control Plane — Postgres
Single shared Postgres 15+ cluster. Hosts:
- `tenants` table (registry)
- `invocations` table (every agent run, for attribution)
- `costs` table (per-invocation token counts + GBP equivalent)
- `pgvector` extension — per-tenant embedding indices for retrieval

### 3.10 Control Plane — Secrets Vault
KMS-wrapped per-tenant secrets. Stored at rest as encrypted blobs. Decrypted in-memory at tenant container startup only. Contains: Anthropic API keys, Fathom API keys, HubSpot OAuth tokens, Gmail OAuth tokens, Cohere API keys, webhook secrets, GitHub deploy keys.

### 3.11 Provisioning System
When a new tenant signs up via the Dashboard:
1. Creates their GitHub vault repo under `intelforce-vaults`
2. Pushes the seed vault skeleton (from `minimal-vault-structure.md`)
3. Provisions OAuth flows for required integrations
4. Generates webhook secrets and registers them with providers
5. Creates the tenant record in Postgres
6. Provisions a tenant container, attaches the volume
7. Runs pre-flight checks per `tools.yaml` of each enabled agent
8. Marks the tenant as "Ready" when all checks pass

### 3.12 Dashboard
Next.js monorepo with tRPC. The client's interface. Lets them:
- Complete the Configuration Wizard to onboard
- View their vault as the "Brain"
- Toggle agents on/off
- Manually trigger an agent run
- See the live activity feed
- Configure per-agent settings

Agency Partner tier includes a multi-tenant manager that lets agencies onboard and manage their own sub-tenants.

---

## 4. Data flows

### 4.1 Proposal Builder flow (webhook-triggered)
1. Fathom call ends, `meeting.processed` webhook fires
2. Webhook Receiver verifies + dedups + persists payload to `/tenant/intake/fathom/{id}.json`
3. Receiver fires Unix socket to supervisor with `{agent: "proposal-builder", payload_path: ...}`
4. Supervisor spawns `cc-invoke proposal-builder --trigger {path}`
5. Claude Code starts. `context.sh` SessionStart hook runs — hydrates agent.md with voice profile, pricing, retrieved past proposals, Fathom transcript
6. Agent executes 9-step workflow
7. Agent writes proposal to `/tenant/vault/clients/{slug}/proposals/`
8. `validate.sh` PostToolUse hook runs — enforces Quality Gates 3, 4, 5
9. Agent creates Gmail draft for sales lead (via Gmail MCP)
10. Agent updates HubSpot deal stage (via HubSpot MCP)
11. Vault syncer commits and pushes to GitHub
12. Supervisor logs completion, cost, duration; control plane ingests telemetry

### 4.2 Lead Hunter flow (cron-triggered)
1. Supervisor fires at configured cadence (e.g. nightly 02:00 UTC)
2. Supervisor spawns `cc-invoke lead-hunter`
3. `context.sh` loads ICP criteria, existing CRM state, previous run's deduplication log
4. Agent queries Companies House + Prospeo + Kaspr via MCP
5. Agent ranks, dedupes, scores prospects
6. Agent writes `/tenant/vault/clients/_prospects/{YYYY-MM-DD}-prospect-list.md`
7. Agent creates HubSpot deals in "New — Unreviewed" stage
8. Daily rollup picks this up for morning review

### 4.3 Content Creator flow (weekly cron + manual)
1. Supervisor fires weekly, OR dashboard "Run Now" fires ad-hoc with a topic brief
2. `context.sh` loads voice profile + brand brief + content calendar + past high-performing pieces
3. Agent drafts outline → researches (web search) → writes → voice-checks
4. `validate.sh` enforces voice-match + no-hallucination + source-citation checks
5. Agent writes to `/tenant/vault/content/long-form/{YYYY-MM-DD}-{slug}.md`
6. Agent creates Gmail draft to sales lead for review
7. Repurposer fires automatically on new long-form write (chained agent)

### 4.4 Librarian flow (nightly cron)
1. Supervisor fires at 04:00 UTC
2. `context.sh` loads vault state snapshot
3. Agent scans new content since last run, applies tags, embeds via Cohere, pushes to pgvector
4. Agent writes daily rollup to `/tenant/vault/daily/{YYYY-MM-DD}.md`
5. Agent archives content older than 90d without access events
6. Agent updates `/tenant/vault/_meta/agent-outputs.md` (rolling summary)
7. Agent flags items needing human review in `/tenant/outbox/librarian/`

---

## 5. What crosses tenant boundaries

Tenant isolation is the whole product's credibility story. Things that do cross tenant boundaries:

- **Webhook Receiver** is shared, but routes exclusively by `tenant_id` in the URL path and verifies signatures per tenant.
- **Postgres** is shared, but every query is scoped by `tenant_id`. Row-level security enforces this at the DB level.
- **pgvector indices** are per-tenant (separate schema per tenant); no cross-tenant embedding retrieval.
- **Secrets vault** wraps each tenant's secrets with a distinct KMS key. Tenant container only receives its own KMS key at startup.
- **Log aggregation** tags every line with `tenant_id`; dashboards filter by tenant.

Things that do NOT cross tenant boundaries:

- Tenant containers — own network namespace, own mounted volume, egress whitelist
- Vaults — each in its own GitHub repo with its own deploy key
- API keys — never mixed, never logged in clear, never written to disk outside the secrets vault

---

## 6. What's NOT in the architecture (deliberate exclusions)

- **No client-facing multi-user authentication yet.** v1 ships with a single operator account per tenant (the sales lead). SSO + multi-seat comes in v1.5.
- **No on-premises or air-gapped deployment mode.** All tenants run on our infrastructure. Enterprise customers who need on-prem are a separate product conversation.
- **No regional failover.** Single UK region (Hetzner UK primary). Disaster recovery is backup-based, not active-active. Documented RTO: 4 hours, RPO: 15 minutes.
- **No LLM-as-judge in v1.** Quality evaluation is structural (`validate.sh`) plus human review. LLM-as-judge gets added in v1.1 after we have baseline data.

---

## 7. Key design decisions (and trade-offs)

| Decision | Rationale | Trade-off |
|---|---|---|
| Claude Code as runtime (not custom) | Ships with subagents, hooks, MCP — covers 80% of our needs for free | Tied to Anthropic's release cadence; outages affect us |
| Shared container image | Fast tenant provisioning, simple upgrades | Less isolation than per-tenant image (mitigated by volume scoping) |
| Git-synced vaults | Free audit trail, familiar to clients, restorable | Git has rough concurrency story; we mitigate with agent-write priority rules |
| Webhook receiver as separate service | Stays responsive even if tenant containers are scaling | One more thing to operate |
| Cohere EU embeddings | UK/EU data sovereignty sales story | 5x cost vs OpenAI (acceptable at our token volumes) |
| Postgres single-cluster with RLS | Operational simplicity, pgvector in one place | Blast radius for a Postgres incident is wide |
| Next.js monorepo dashboard | Fast dev, shared types, one deploy | Larger bundle than split frontend |

---

## 8. Where to go next

- For agent-level detail → `phase-2-agent-suite/README.md`
- For platform-level detail → `phase-1-poc-stack/platform-specs/`
- For what to build first → `phase-1-poc-stack/runbooks/week-1-experiment-runbook.md`
- For pricing and GTM → `intelforce-ai-os-strategic-plan.md`
