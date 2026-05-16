# Dashboard Architecture Specification

**The technology choices, repository shape, rendering model, and deployment story for the IntelForce AI OS dashboard.**

> **Audience:** the engineer implementing the dashboard (CC13) and everyone reviewing it.
>
> **Status:** v1.0. Targets Next.js 15 + tRPC + Prisma + Tailwind CSS, deployed to Hetzner UK behind Cloudflare.
>
> **Non-negotiables:**
> - Typesafe end-to-end (TypeScript across backend + frontend, tRPC between them)
> - Server-rendered where it matters (initial page loads, SEO-visible content)
> - UK/EU data residency — no dashboard state lives in a US-only SaaS unless we've verified the data region
> - Accessible to keyboard-only operators (WCAG 2.1 AA target)

---

## 1. Scope

What the dashboard is:
- The single web app operators use to manage tenants
- The single web app tenants use to see their agents' activity, read drafts, approve escalations
- The single web app agency partners use to see across their sub-tenants

What the dashboard is NOT:
- A mobile app (we don't build one; the dashboard is responsive and that's the mobile story for v1)
- A tenant's Obsidian replacement (tenants edit their vault in Obsidian; the dashboard shows read-only vault views)
- Claude Code itself (operators don't run agents from the dashboard; agents run in tenant containers triggered by webhooks or cron)

---

## 2. Tech stack (decisions and why)

| Layer | Choice | Alternatives considered | Why this one |
|---|---|---|---|
| Framework | Next.js 15 (App Router) | Remix, SvelteKit, plain React SPA | Mature; SSR + client components; React ecosystem; hiring |
| Language | TypeScript | Plain JS, Rust/Axum for backend | Type-safety end-to-end; pairs with tRPC |
| API layer | tRPC | REST + OpenAPI, GraphQL | Typesafe without codegen; no schema drift; small API surface |
| ORM | Prisma | Drizzle, raw SQL, Knex | First-class TS types from Postgres schema; migrations out of scope (done by platform migrations) |
| Styling | Tailwind CSS | CSS Modules, CSS-in-JS, Panda | Fast iteration; aligns with prototype; utility-first scales in team contexts |
| Components | shadcn/ui (copy-paste) | Radix Themes, MUI, Ant Design | We own the code; Radix underneath; no vendor lock |
| State | React Server Components + TanStack Query (via tRPC) | Redux, Zustand, MobX | Server state via queries; client state stays minimal |
| Forms | React Hook Form + Zod | Formik, custom | Fast; integrates with tRPC's Zod schemas |
| Auth | Clerk | WorkOS, Ory, Supabase Auth, custom | See `auth-and-authorization-spec.md` §2 — short version: fast to integrate, EU data option, org support |
| Icons | Lucide | Heroicons, Phosphor | Matches prototype |
| Charts | Recharts + d3 for custom | Chart.js, Visx, Nivo | Matches prototype; flexible enough |
| Editor (vault preview) | Markdoc + Shiki for syntax | MDX, Remark | Read-only preview; Markdoc is safer for user-generated content |
| Testing | Vitest + Playwright | Jest, Cypress | Faster; ESM-native; built for modern Vite toolchains |
| Deployment | Self-hosted on Hetzner behind Cloudflare | Vercel, AWS Amplify | Data residency; predictable pricing; no vendor surprise |

### Decisions deliberately deferred

- **Feature flags** — LaunchDarkly vs Unleash vs simple config flags. Deferred until we have >1 production environment (Phase 6).
- **Real-time transport** — SSE works for Phase 4 (escalations feed). WebSockets considered only if we add bi-directional features like collaborative vault editing. Not on roadmap.
- **Internationalisation** — UK-English only for v1. i18n wiring added in v2 when first non-UK market opens.

---

## 3. Repository shape — monorepo via Turborepo

```
intelforce/
├── apps/
│   ├── dashboard/              ← Next.js 15 app (this spec)
│   ├── marketing/              ← Separate Next.js site for landing/pricing (Phase 5)
│   ├── webhook-receiver/       ← Fastify service (see Phase 1)
│   ├── provisioning-system/    ← Temporal workflows (see Phase 3)
│   ├── secrets-vault/          ← Node service (see Phase 3)
│   ├── escalation-notifier/    ← Go/Node sidecar (see Phase 3)
│   └── scheduler/              ← Rotation + cron scheduler
│
├── packages/
│   ├── db/                     ← Prisma schema + generated client
│   ├── trpc/                   ← tRPC router + procedures (consumed by dashboard + internal tools)
│   ├── ui/                     ← shadcn/ui components + design tokens
│   ├── icons/                  ← Re-exported Lucide icons with our conventions
│   ├── schemas/                ← Shared Zod schemas (tenant config, agent outputs)
│   ├── secrets-client/         ← Node client for the Secrets Vault HTTP API
│   ├── telemetry/              ← Structured logging + metrics helpers
│   └── config/                 ← ESLint, TSConfig, Prettier shared configs
│
├── tools/
│   ├── cli/                    ← `intelforce` operator CLI (vault-search, cost-report, etc.)
│   └── scripts/                ← Deploy, one-off migrations, DR scripts
│
├── turbo.json
├── package.json                ← pnpm workspaces
└── pnpm-workspace.yaml
```

Package manager: **pnpm**. Fastest install, stable workspace support, smaller node_modules.

Why monorepo, not multi-repo:
- Shared types across frontend + backend (tRPC, Zod schemas, Prisma types) must be in lockstep
- Platform services consume the same database schema definitions
- One CI pipeline runs lint + typecheck across everything
- Release atomicity — the dashboard and the tRPC router ship together

Trade-off: monorepo tooling has a learning curve. Turborepo's caching makes CI fast; once set up, the overhead is worth it.

---

## 4. Rendering model

Next.js App Router, with deliberate boundaries between server and client components.

### 4.1 Default: React Server Components

Pages, layouts, and most data-display components are RSCs. They fetch data server-side via tRPC's server-caller pattern, render to HTML, and stream to the browser.

Benefits:
- First paint is HTML, not a loading spinner
- Database queries happen once per navigation, not per component
- Client bundle stays small

### 4.2 Client components only where needed

A component becomes `'use client'` when it:
- Uses state (`useState`, `useReducer`)
- Uses effects (`useEffect`)
- Uses browser APIs (clipboard, fetch-streams, etc.)
- Subscribes to real-time events (SSE)
- Is an interactive form

Examples of client components:
- The escalation feed (SSE subscription)
- The Configuration Wizard's step navigation
- Any `<Combobox>`, `<DatePicker>`, modal dialog
- Charts (Recharts needs a browser)

Example structure for a typical page:

```
app/tenants/[tenantId]/operations/page.tsx        ← RSC, fetches summary
  ├── <CostCard />                                ← RSC, data already in props
  ├── <EscalationFeed />                          ← client component, subscribes to SSE
  └── <InvocationsTable />                        ← client component (sortable, filterable)
```

### 4.3 Streaming

Pages use React Suspense with `<Suspense>` boundaries so the shell renders immediately and data-loading segments stream in. Feels fast even on slow queries.

### 4.4 Caching

Three layers:
1. **Server-side fetch cache** — tRPC procedures that are pure reads with low change rate are cached 10s by default; mutation-tagged invalidation for anything touched by the user
2. **React Query cache (client-side)** — populated by tRPC; stale-while-revalidate for nav-between-pages speed
3. **Cloudflare cache** — static assets; never caches authenticated pages

We explicitly DO NOT cache `tenants.list`, `costs.current`, or anything that changes frequently and matters for operator decisions.

---

## 5. The request path

```
User browser
   │
   │ HTTPS
   ▼
Cloudflare (edge)
   │
   │ TLS re-encrypted; WAF checks
   ▼
Hetzner load balancer (private IP)
   │
   ▼
Next.js server (dashboard app, ≥2 instances)
   │
   ├── tRPC procedure call
   │     ├── Prisma → Postgres (control + ops schemas)
   │     ├── fetch → Secrets Vault (for masked display only, never values)
   │     ├── fetch → Escalation Notifier SSE (for subscriptions)
   │     └── fetch → Temporal (for workflow status when wizard completes)
   │
   └── HTML streams back to browser
```

Every service-to-service call is over a private network, mTLS where the target supports it.

---

## 6. Navigation and information architecture

Three top-level contexts the dashboard shows:

### 6.1 Operator context (`/admin/*`)

For IntelForce staff and agency-partner operators. Multi-tenant scope.

- `/admin/tenants` — list every tenant, filter by status/plan/owner
- `/admin/tenants/[tenantId]/*` — drill into a specific tenant (same views as tenant context but in admin chrome)
- `/admin/ops/escalations` — global escalation queue across all tenants
- `/admin/ops/incidents` — active incident management (reads `ops.audit_log`, `ops.alerts`)
- `/admin/ops/costs` — platform-wide cost overview
- `/admin/ops/deployments` — recent component deployments

### 6.2 Tenant context (`/t/[tenantSlug]/*`)

For the client's sales lead / principal. Single-tenant scope, RLS-enforced.

- `/t/[slug]` — landing overview (current month numbers, open escalations count, recent activity)
- `/t/[slug]/operations` — invocations + escalations + costs for this tenant
- `/t/[slug]/brain` — read-only vault browser
- `/t/[slug]/activity` — chronological activity log
- `/t/[slug]/settings` — integrations, billing, config

### 6.3 Agency-partner context (`/agency/[partnerSlug]/*`)

For Rigby-Group-style partners that have multiple sub-tenants. See the Agency Partner Portal spec.

- `/agency/[partnerSlug]` — portfolio dashboard across all sub-tenants
- `/agency/[partnerSlug]/tenants` — sub-tenant list
- `/agency/[partnerSlug]/onboarding` — queue of new tenants being provisioned
- `/agency/[partnerSlug]/billing` — roll-up billing

Full IA diagram in `dashboard-architecture-spec.md` §appendix is deferred — the above list is the buildable scope.

---

## 7. URLs, slugs, and IDs

| Context | URL identifier | Why |
|---|---|---|
| Tenants in user-facing URLs | `client_slug` (e.g., `meadowlane-dental`) | Memorable, shareable |
| Tenants in admin URLs | `tenant_id` (e.g., `tnt_01JKDY...`) | Stable, ULID-sorted |
| Agency partners in URLs | `agency_slug` | Memorable |
| Invocation IDs | numeric (from `invocations.id`) | Primary key |
| Escalations | numeric (from `escalations.id`) | Primary key |
| Vault files | full relative path (URL-encoded) | Matches the filesystem path |

Never expose database row IDs in public URLs that might leak. Admin URLs are fine with internal IDs. Tenant-context URLs always use slugs.

---

## 8. Cross-cutting concerns

### 8.1 Error boundaries

Every view has a Next.js `error.tsx` fallback. Fallback shows the error message, a correlation ID, and a "Try again" button. Correlation ID lets operators link a user-visible error to a server-side log entry via Loki.

### 8.2 Loading states

Every view has a `loading.tsx` with a skeleton matching the real layout. No spinners — they feel cheap. Skeletons feel intentional.

### 8.3 Empty states

Every list view (tenants, escalations, invocations, etc.) has a first-class empty state with copy that helps the operator:
- "No tenants yet. Start with 'New tenant'."
- "No escalations — your agents are healthy."
- "No invocations in the last 7 days. That's unusual — check webhook receiver status?"

Empty states are written, not auto-generated. They're as important as full states.

### 8.4 Keyboard shortcuts

| Shortcut | Action |
|---|---|
| `Cmd/Ctrl + K` | Open command palette (jump to tenant, search escalations, navigate) |
| `G` then `T` | Go to tenants list |
| `G` then `E` | Go to escalations |
| `G` then `O` | Go to operations |
| `?` | Show shortcut help |
| `Esc` | Close modal/drawer |

### 8.5 Command palette

Inspired by Linear/Raycast. Accessible via `Cmd/Ctrl + K`:
- Fuzzy search across tenants
- Fuzzy search across recent escalations
- Navigate to specific pages ("brain view for Meadow Lane")
- Actions ("create new tenant", "rotate secrets for...")

Built with `cmdk` library on top of Radix primitives.

---

## 9. Deployment

### 9.1 Environments

| Environment | Purpose | Traffic |
|---|---|---|
| `dev` | Local development; each engineer | Local only |
| `preview-*` | Pull request previews (per-PR subdomains) | Internal team only |
| `staging` | Pre-production; mirror of production schema | Internal team + test tenants |
| `production` | Live | Real customers |

### 9.2 Infrastructure

- 2x Next.js server instances (for HA) behind a Hetzner load balancer
- Shared Postgres cluster (the same one covered in Phase 3)
- Redis instance for session storage and short-lived caches
- Cloudflare in front of everything (DNS, WAF, CDN for static assets)

### 9.3 Deploy process

1. Merge to main triggers GitHub Actions
2. Action builds Docker image for the dashboard app, pushes to ghcr.io with Git SHA tag
3. Staging auto-deploys from main
4. Production deploy requires manual approval (Slack button or `/deploy production` slash command)
5. Production deploy is blue-green: new instances come up behind the LB, old drain, switch, old terminate

### 9.4 Rollback

Instant rollback available — LB flips back to previous image tag. Any pending DB migrations stay (we never auto-revert migrations; forward-only policy).

### 9.5 Secrets at deploy time

The dashboard needs to authenticate to several services (Postgres, Secrets Vault, Clerk, etc.). Deploy-time secrets come from a minimal bootstrap KMS-protected blob loaded by the container entrypoint. Never from environment variables baked into the image.

---

## 10. Observability

Every request to the dashboard emits:
- **Access log** — via Vector to Loki (see Phase 3 observability spec) — tenant_id when known, user_id, path, status, duration
- **Tracing span** (deferred to Phase 7 when Tempo ships)
- **tRPC telemetry** — procedure name, duration, error class

Custom dashboard metrics (Prometheus):
- `dashboard_page_views_total{route}`
- `dashboard_tRPC_calls_total{procedure, status}`
- `dashboard_trpc_duration_seconds{procedure}`
- `dashboard_sse_active_connections{tenant_id}`

Alerts:
- p95 page load > 3s → warn
- tRPC error rate > 1% → warn
- SSE connections dropping rapidly → warn

---

## 11. Security model — high-level

Full treatment in `auth-and-authorization-spec.md`. Summary:

- Clerk handles auth (email + magic link primary; SSO for agency partners)
- Dashboard backend verifies Clerk session on every request
- Row-level security in Postgres enforces tenant isolation — even if application code has a bug, a user cannot read another tenant's data
- Every mutation is logged to `ops.audit_log`
- 2FA required for all operators (Clerk enforces)
- Destructive actions (decommission tenant, rotate all secrets, delete invocations) require a confirmation step-up

---

## 12. Performance targets

| Metric | Target |
|---|---|
| Time to first byte (TTFB) | < 200ms (p95) |
| Largest Contentful Paint | < 2.5s (p75) |
| Interaction to Next Paint | < 200ms (p75) |
| Tenant list page load | < 500ms (p95), with 100+ tenants |
| Escalation feed latency | < 1s from raised to visible |
| Vault file preview | < 1s for files < 500KB |

These are targets, not hard blocks. The first DR drill / load test (Phase 6) will confirm whether we actually hit them.

---

## 13. Accessibility

- WCAG 2.1 AA target
- All interactive elements reachable by keyboard
- Focus visible on every control
- ARIA labels on icon-only buttons
- Colour contrast ≥ 4.5:1 for normal text, ≥ 3:1 for large text
- No colour-only signals — always pair with icon or text
- Tested with VoiceOver (macOS) and NVDA (Windows) at each milestone

Trade-off we accept: we don't target AAA. Full AAA compliance has real design costs (contrast restrictions, no underlines in body copy, etc.). AA is the right bar for a professional tool.

---

## 14. Implementation checklist (for CC13)

- [ ] Turborepo + pnpm workspace scaffolded
- [ ] Next.js 15 app with App Router
- [ ] TypeScript strict mode, path aliases
- [ ] Tailwind config with design tokens (see `design-system-spec.md`)
- [ ] shadcn/ui components added via CLI
- [ ] tRPC router package scaffolded (see `api/trpc-router-spec.md`)
- [ ] Prisma client generated from Phase 3 schema
- [ ] Clerk integration (see `auth-and-authorization-spec.md`)
- [ ] First page (tenants list) end-to-end with real data
- [ ] Error boundary + loading state patterns established
- [ ] Command palette wired
- [ ] Vitest + Playwright test scaffolding
- [ ] GitHub Actions: lint, typecheck, test, build
- [ ] Dockerfile for production deploy
- [ ] Staging deployment pipeline
- [ ] Production deployment with manual approval gate

---

## 15. Open decisions

**OD-P4-A:** Clerk vs WorkOS for auth
- **Clerk:** faster to integrate, good UI components, has EU data option
- **WorkOS:** stronger SSO story, better for enterprise agency partners, more expensive for small tenants
- **Recommendation:** Clerk for v1. Migrate specific agency partners to WorkOS if they require SAML SSO in their MSA.

**OD-P4-B:** Marketing site same Next.js app or separate?
- **Same:** shared components, one deployment
- **Separate (`apps/marketing/`):** marketing can ship marketing without revving the dashboard; marketing can use different perf characteristics (ISR, edge caching aggressively)
- **Recommendation:** separate. Marketing needs its own deploy cadence and its own SEO discipline.

**OD-P4-C:** Mobile — responsive only, or dedicated app?
- **Responsive only (v1):** dashboard works on tablet/mobile browsers; no store app
- **Dedicated app (later):** React Native or similar
- **Recommendation:** responsive only for the foreseeable future. The people using the dashboard do so from desktops during work hours; mobile is for checking notifications, not drafting proposals.

**OD-P4-D:** Admin and tenant URLs — same domain or separate?
- **Same domain (`dashboard.intelforce.ai`)** with role-based routing
- **Separate (`admin.intelforce.ai`, `app.intelforce.ai`)** for clarity and different auth setup
- **Recommendation:** same domain, role-based routing. Separate domains add friction without security benefit (the real isolation is in RLS + Clerk organisation scope).

---

## 16. Related specs

- `design-system-spec.md` — tokens, components, brand direction
- `auth-and-authorization-spec.md` — roles, sessions, permissions
- `api/trpc-router-spec.md` — every API procedure the frontend calls
- `wizard/configuration-wizard-spec.md` — Configuration Wizard (one of the biggest views)
- `views/*-spec.md` — individual view specs

Older references:
- `intelforce-dashboard.jsx` (Session 0) — visual prototype; establishes palette and navigation feel but not production-ready
- `phase-3-platform/services/escalation-notifier-spec.md` — SSE endpoint the dashboard subscribes to
- `phase-3-platform/postgres/schema-spec.md` — the data model the dashboard renders
