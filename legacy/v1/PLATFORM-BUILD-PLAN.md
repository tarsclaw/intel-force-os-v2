# Intel Force OS — Full Platform Build Plan

_Written 2026-04-24. Derived from Phase 3 + Phase 4 spec packs. This is the complete picture._

---

## What the finished product is

Intel Force OS is two things:

1. **The Teams HR Agent** (built) — a Microsoft Teams bot that drafts HR replies and routes them through an approval loop. Runs on Cloudflare Workers. Deployed.

2. **The Platform** (building now) — the operational web app that operators and customers use to manage, monitor, and configure everything. Next.js dashboard + multi-tenant Postgres backend + supporting services.

The platform IS the core product. The Teams bot is the delivery surface. You sell the platform; the bot is how it shows up in the customer's day.

---

## Repository structure (target)

```
intel-force-os/
│
├── src/                          # Cloudflare Worker (Teams HR Agent) — DONE
├── migrations/                   # D1 schema for Worker — DONE
├── teams-app/                    # Teams manifest + icons — DONE
├── onboarding/                   # Tenant provisioning CLIs — DONE
├── tests/                        # Worker tests — DONE
│
├── apps/
│   └── dashboard/                # Next.js 15 web dashboard
│       ├── app/
│       │   ├── (auth)/           # Sign-in, sign-up (Clerk)
│       │   ├── (marketing)/      # Public pages
│       │   ├── admin/            # Platform operator routes
│       │   ├── t/[slug]/         # Tenant context routes
│       │   │   ├── page.tsx      # Operations Control
│       │   │   ├── brain/        # Vault browser
│       │   │   ├── activity/     # Activity log + audit
│       │   │   └── settings/     # Settings (7 panels)
│       │   └── agency/[slug]/    # Agency partner routes
│       ├── components/           # Dashboard-specific components
│       │   ├── operations/       # Operations Control modules
│       │   ├── brain/            # Brain view components
│       │   ├── activity/         # Activity log components
│       │   ├── settings/         # Settings panels
│       │   └── shared/           # Layout, nav, cards, etc.
│       ├── lib/                  # trpc client, utils, hooks
│       ├── public/
│       └── package.json
│
├── packages/
│   ├── db/                       # Prisma schema + client
│   │   ├── prisma/schema.prisma
│   │   ├── src/client.ts
│   │   └── package.json
│   ├── trpc/                     # tRPC routers (12 sub-routers)
│   │   ├── src/routers/
│   │   └── package.json
│   ├── ui/                       # shadcn/ui components + design tokens
│   │   ├── src/components/
│   │   └── package.json
│   └── schemas/                  # Zod validation schemas (shared)
│       ├── src/
│       └── package.json
│
├── turbo.json
├── pnpm-workspace.yaml
└── PLATFORM-BUILD-PLAN.md
```

---

## Phase 3 — Platform Infrastructure

**Trigger:** Building now (dashboard depends on it).
**Spec location:** `docs/phase-3-platform/`

### What Phase 3 is

The shared backend every tenant runs against. Postgres replaces Cloudflare D1 for the dashboard layer. The Worker (Teams bot) continues using Cloudflare KV/D1 for its hot path — the dashboard reads from Postgres.

### The Postgres schema (from `postgres/schema-spec.md`)

Three schema tiers:

**`control` schema** — platform-wide metadata
```sql
control.tenants          — tenant registry (id, slug, name, plan, status, parent_tenant_id)
control.users            — mirrored from Clerk
control.users_roles      — role assignments per tenant
control.invitations      — pending team invites
control.pending_approvals — 2-person approval queue (destructive actions)
control.agency_portfolio_summary — materialised view, refreshed 5min
```

**`ops` schema** — operational data (cross-tenant, written by agents/Worker)
```sql
ops.invocations          — every agent run (agent, trigger, started, duration, status, cost)
ops.escalations          — every escalation event (tenant, category, status, resolved_by)
ops.costs                — per-invocation cost attribution (tokens, GBP)
ops.audit_log            — immutable event log (actor, action, target, metadata)
ops.deployments          — Worker/dashboard deployment history
ops.webhook_registrations — registered webhook endpoints per tenant
```

**`tenant_{id}` schema** (one per customer) — per-tenant pgvector + config
```sql
tenant_{id}.chunks       — vault content chunks with Cohere embeddings (pgvector)
tenant_{id}.config       — current tenant configuration (JSON)
tenant_{id}.config_history — version-controlled config changes
```

**RLS enforcement:**
- All `control.*` and `ops.*` queries check `app.current_tenant_id` session variable
- Prisma sets this via `$executeRaw('SET app.current_tenant_id = $1', tenantId)` at start of each request
- `tenant_{id}.*` accessed via dynamic schema switching

### Phase 3 services

| Service | What it does | Runtime |
|---|---|---|
| Postgres cluster | Primary DB + RLS + pgvector | Hetzner UK dedicated |
| Temporal provisioning | `TenantOnboard`, `TenantReprovision`, `TenantDecommission` workflows | Temporal Cloud (start self-hosted, migrate if painful) |
| Secrets Vault | Per-tenant KMS CMK secrets with rotation | Node.js service + AWS KMS |
| Escalation Notifier | fsnotify watcher → Slack + DB + SSE | Node.js sidecar |
| vault-search CLI | pgvector semantic search for Brain view | Go CLI called by context.sh |
| Observability | Loki + Prometheus + Grafana + PagerDuty | Self-hosted on Hetzner |

### Phase 3 build order

```
Week 1:   Postgres schema + migrations (packages/db + Prisma)
Week 2:   Secrets Vault service (AWS KMS + rotation scheduler)
Week 2:   vault-search CLI (pgvector queries via Cohere embeddings)
Week 3-5: Temporal provisioning (TenantOnboard workflow — the critical path)
Week 5:   Escalation Notifier sidecar
Week 6:   Observability stack (Vector, Loki, Prometheus, Grafana)
Week 7:   DR drill #1
```

---

## Phase 4 — Dashboard

**Trigger:** Building now.
**Spec location:** `docs/phase-4-dashboard/`

### Tech stack (locked)

| Layer | Technology | Why |
|---|---|---|
| Framework | Next.js 15, App Router | RSC default, streaming, layouts |
| Language | TypeScript strict | Same as Worker |
| API | tRPC v11 | Type-safe, no codegen, works with RSC |
| ORM | Prisma 6 | Type-safe, works with Postgres + RLS |
| Auth | Clerk | EU data, org primitive, MFA, fast setup |
| UI | shadcn/ui + Tailwind v4 | Unstyled base, matches brand |
| Real-time | Server-Sent Events | Simpler than WebSockets, works with Next.js |
| Charts | Recharts | Lightweight, composable |
| Forms | React Hook Form + Zod | Same Zod schemas as packages/schemas |
| Monorepo | Turborepo + pnpm | Shared packages, parallel builds |
| Hosting | Cloudflare Pages (initially) | Same stack as Worker, free tier |

### Design system (from `design-system-spec.md`)

**Colour tokens:**
```
bg-canvas:         #09090b  (near-black — default background)
bg-surface:        #111113  (card surfaces)
bg-surface-raised: #18181b  (elevated elements)
border-subtle:     #27272a  (default borders)
brand-emerald:     #10b981  (primary action colour)
brand-amber:       #f59e0b  (attention/warning)
text-primary:      #fafafa
text-secondary:    #a1a1aa
text-muted:        #71717a
```

**Typography:** Inter variable (body), JetBrains Mono (code/data)
**Default:** dark mode. Light mode available but dark is the product.
**Density:** medium-dense. `text-sm` (14px) default. Operators are power users.

### Routes

```
/                          → redirect → /t/[first-tenant-slug] or /admin
/(auth)/sign-in            → Clerk sign-in
/(auth)/sign-up            → Clerk sign-up

/admin                     → Platform operator dashboard
/admin/tenants             → All tenants list
/admin/tenants/new         → Configuration Wizard (operator starting)
/admin/activity            → Global activity log
/admin/system              → System health, deployments, MCP servers

/t/[slug]                  → Operations Control (default tenant view)
/t/[slug]/brain            → Brain view (vault browser)
/t/[slug]/activity         → Activity Log + Audit
/t/[slug]/settings         → Settings (7 panels)
/t/[slug]/wizard           → Configuration Wizard (tenant onboarding)

/agency/[slug]             → Agency partner overview
/agency/[slug]/tenants     → Sub-tenant list
/agency/[slug]/billing     → Consolidated billing
/agency/[slug]/activity    → Portfolio activity feed
/agency/[slug]/team        → Agency team management
```

### Build priority order for the dashboard

| Priority | View / Component | What it is | Spec |
|---|---|---|---|
| 1 | Auth + layout | Clerk setup, nav shell, tenant context | auth-and-authorization-spec.md |
| 2 | Operations Control | KPI tiles, escalations feed, running now, costs | operations-control-spec.md |
| 3 | Settings | 7 panels: integrations, secrets, billing, config, team, API keys, notifications | settings-spec.md |
| 4 | Activity Log | Event timeline with filters, export, real-time | activity-log-and-audit-spec.md |
| 5 | Configuration Wizard | 9-step onboarding for new tenants | configuration-wizard-spec.md |
| 6 | Brain view | Vault file tree, semantic search, Markdoc preview | brain-view-spec.md |
| 7 | Agency Portal | Multi-tenant management for partners | agency-partner-portal-spec.md |
| 8 | Admin views | Platform operator tools | dashboard-architecture-spec.md |

---

## What gets built in what order — the master sequence

### Now (can build immediately, no external credentials)

```
[ ] Monorepo setup (turbo.json, pnpm-workspace.yaml)
[ ] packages/db — Prisma schema (from Phase 3 spec)
[ ] packages/schemas — Zod schemas for all entities
[ ] packages/ui — shadcn/ui setup + design tokens
[ ] apps/dashboard — Next.js 15 scaffold
[ ] Auth shell — Clerk middleware + sign-in/up pages
[ ] Layout — nav shell, tenant switcher, breadcrumbs
[ ] Operations Control — layout + mock data → real tRPC
[ ] tRPC server setup (packages/trpc)
[ ] Settings view — 7 panels
[ ] Activity Log view
```

### Requires Postgres (Phase 3 prerequisite)

```
[ ] Prisma migrations applied to live Postgres
[ ] tRPC procedures with real Prisma queries
[ ] RLS enforcement (SET app.current_tenant_id)
[ ] ops.invocations populated by Worker (add write path)
[ ] ops.escalations populated by Worker
[ ] ops.audit_log populated by all actions
```

### Requires Temporal (provisioning)

```
[ ] TenantOnboard workflow (creates Postgres schemas, provisions secrets)
[ ] Configuration Wizard → triggers TenantOnboard
[ ] TenantDecommission workflow (GDPR deletion)
```

### Requires Clerk account

```
[ ] CLERK_SECRET_KEY + NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
[ ] Clerk org setup (tenant per org)
[ ] Role assignment via Clerk metadata
[ ] Invitation flow
```

---

## Tenancy model — how it actually works

### v1 (current — Cloudflare KV/D1)

```
One Cloudflare Worker handles ALL tenants.
Tenant isolation: KV key prefix (tenant_config:{tenantId})
Audit log: Single D1 table with tenant_id column + index
Config: JSON blob in KV per tenant
```

**Works for:** 1-10 tenants, low volume, manual provisioning

**Breaks at:** Postgres-level analytics, cross-tenant dashboard, self-serve

### v2 (building now — Postgres + Clerk)

```
Postgres control schema: tenant registry
One Postgres schema per tenant: tenant_{id}.config, tenant_{id}.chunks
Worker writes to Postgres ops.* tables (adds Postgres client to Worker)
Dashboard reads from Postgres via Prisma + tRPC
Tenant isolation: Postgres RLS (app.current_tenant_id session var)
Auth: Clerk orgs = tenants
Provisioning: Temporal TenantOnboard workflow
```

**Migration path from v1:**
1. Add Postgres write to Worker (alongside D1) — dual-write period
2. Dashboard reads from Postgres
3. Migrate D1 data to Postgres
4. Remove D1 write from Worker (Postgres only)
5. D1 kept for emergency fallback 90 days

### Multi-tenant isolation guarantees

| Layer | Mechanism |
|---|---|
| Auth | Clerk org membership — wrong org = no session |
| API | tRPC `tenantProcedure` checks org membership + sets tenant scope |
| DB | Postgres RLS — `SET app.current_tenant_id` + policy-based row filter |
| Schema | Per-tenant schemas (tenant_{id}) — app bugs can't cross-contaminate |
| Secrets | Per-tenant KMS CMK — mathematical erasure on offboarding |

---

## External services required (with purpose)

| Service | Purpose | When needed | Cost est. |
|---|---|---|---|
| **Clerk** | Auth + org management | Dashboard launch | £25/mo |
| **Hetzner** (or Neon/Supabase) | Postgres cluster | Dashboard launch | £80/mo |
| **AWS KMS** | Per-tenant secret encryption | Secrets Vault | £5-20/mo |
| **Temporal Cloud** | Provisioning workflow orchestration | When onboarding needs automation | £0 at low volume |
| **Cloudflare Pages** | Dashboard hosting | Dashboard launch | £0 (free tier) |
| **Cohere** | Embeddings for vault search (Brain view) | Brain view | £20-100/mo |
| **Upstash Redis** | Rate limiting + SSE pub/sub | tRPC rate limits | £0-10/mo |
| **Resend** | Transactional email (invitations, alerts) | Auth/notifications | £0-10/mo |

---

## Dashboard build — section by section

### Operations Control (highest priority)

The daily-use view. What an HR Lead or operator sees when they open the dashboard.

**Left column:**
- 4 KPI tiles: Open escalations (colour-coded by count), Month spend, Invocations this week, Success rate
- Escalations feed: newest first, severity icon, employee + channel + category, [View/Resolve/Won't fix] inline actions, SSE real-time

**Right column:**
- Running now: active agent invocations with timer
- Recent invocations table: 25 rows, filters, row → detail drawer

**Bottom:**
- Costs: stacked daily bar chart by provider, budget line, per-agent breakdown

### Brain view (vault browser)

The customer sees their HR data as an Obsidian vault rendered natively.

**Sidebar:** file tree (lazy-loaded), recent files, search
**Main:** Markdoc file preview with YAML frontmatter, Mermaid diagrams, Shiki code highlight
**Semantic search:** Cohere embeddings + pgvector, 200ms target

### Settings (7 panels)

1. **Integrations** — connect/disconnect provider cards, reauth flow
2. **Secrets** — ref inventory (never values), rotate, emergency rotation
3. **Billing** — Stripe portal embed, plan info, spend, invoices
4. **Config** — editable tenant fields (name, tone, budget), read-only (slug, agents)
5. **Team** — member table, invite modal, role management
6. **API Keys** — generate, scope, reveal-once, revoke
7. **Notifications** — Slack webhook + severity, email digest, mute per-code

### Configuration Wizard (9 steps)

The operator-driven onboarding flow. Creates a new tenant.

1. Basics (name, slug, industry, owner email, timezone)
2. Plan + agents (tier selection, agent toggles)
3. Voice profile (sample upload → async extraction)
4. Brand + positioning (ICP, services, suppression list)
5. Per-agent config (dynamic from config.schema.json)
6. Integrations (OAuth + API key setup)
7. Review + submit (validation, slug confirmation)
8. OAuth handoff (async integration completion)
9. Provisioning status (SSE workflow progress)

---

## Postgres schema — the 12 tables you build first

These are the foundation everything else reads from.

```sql
-- control schema
control.tenants (id, slug, name, plan, status, parent_tenant_id, clerk_org_id, ...)
control.users (id, clerk_user_id, email, name, ...)
control.users_roles (user_id, tenant_id, role, granted_by, ...)
control.invitations (id, email, tenant_id, role, token, expires_at, ...)
control.pending_approvals (id, action, requester_id, approver_id, payload, status, ...)
control.agency_portfolio_summary (materialised view)

-- ops schema  
ops.invocations (id, tenant_id, agent, trigger, started_at, duration_ms, status, cost_gbp, ...)
ops.escalations (id, tenant_id, category, severity, status, original_message, resolved_by, ...)
ops.costs (id, tenant_id, invocation_id, provider, model, input_tokens, output_tokens, cost_gbp, ...)
ops.audit_log (id, tenant_id, actor_id, actor_kind, action, target_kind, target_id, metadata, ip, ...)
ops.webhook_registrations (id, tenant_id, provider, endpoint, secret_hash, status, ...)
ops.deployments (id, env, component, version, deployed_by, deployed_at, sha, ...)

-- per-tenant (one schema per tenant)
tenant_{id}.chunks (id, vault_path, chunk_index, content, embedding vector(1024), tags, ...)
tenant_{id}.config (current JSON config snapshot)
tenant_{id}.config_history (version, config_json, changed_by, changed_at, diff, ...)
```

---

## What the dashboard reads right now (pre-Postgres)

While Postgres is being set up, the dashboard can read from Cloudflare's REST APIs:

```typescript
// apps/dashboard/lib/cloudflare-data.ts

// Read tenant config
GET https://api.cloudflare.com/client/v4/accounts/{account_id}/storage/kv/namespaces/{kv_id}/values/tenant_config:{tenantId}

// Query D1 audit log
POST https://api.cloudflare.com/client/v4/accounts/{account_id}/d1/database/{db_id}/query
{ sql: "SELECT * FROM audit_log WHERE tenant_id = ? ORDER BY created_at DESC LIMIT 25" }
```

This lets the dashboard be useful on day 1 without waiting for the Postgres migration.

---

## The honest timeline

| Week | What gets built |
|---|---|
| 1 | Monorepo + dashboard scaffold + Clerk auth + design system |
| 2 | Prisma schema + packages/db + packages/trpc structure |
| 2 | Operations Control view (mock data, then real Cloudflare REST API) |
| 3 | Settings view (7 panels, mock data) |
| 3 | Activity Log view |
| 4 | Configuration Wizard (steps 1-7) |
| 4 | Postgres + Prisma migrations applied to real instance |
| 5 | tRPC procedures with real Prisma queries + RLS |
| 6 | Worker writes to Postgres (dual-write period starts) |
| 6 | Brain view (vault browser, Markdoc, search) |
| 7 | Temporal provisioning (TenantOnboard workflow) |
| 8 | Agency Partner Portal |
| 8-10 | Secrets Vault service, Escalation Notifier, Observability |

---

## Secrets needed (add to your notes)

```
# Clerk (dashboard auth)
CLERK_SECRET_KEY=sk_live_...
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_...
CLERK_WEBHOOK_SECRET=whsec_...

# Postgres
DATABASE_URL=postgresql://user:pass@host:5432/intel_force_os

# Cloudflare REST API (for reading KV/D1 before Postgres migration)
CF_API_TOKEN=...
CF_ACCOUNT_ID=...
CF_KV_NAMESPACE_ID=...
CF_D1_DATABASE_ID=...

# AWS KMS (Phase 3 secrets vault)
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_KMS_REGION=eu-west-2

# Cohere (brain view embeddings)
COHERE_API_KEY=...

# Resend (transactional email)
RESEND_API_KEY=...
```
