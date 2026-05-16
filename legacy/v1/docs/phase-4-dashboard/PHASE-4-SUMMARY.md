# Phase 4 — Dashboard Specifications

**Everything needed to build the web app that makes the platform usable. Architecture, design system, auth, API contract, Wizard, and the five production views.**

> **Status:** v1.0, shipped 23 April 2026.
>
> **Prerequisites:** Phase 3 platform specs (Postgres schema, provisioning, secrets, observability, escalation notifier, vault-search). The dashboard is a consumer of those APIs.

---

## What's in this phase

| # | Spec | Builds |
|---|---|---|
| 1 | `architecture/dashboard-architecture-spec.md` | Tech stack, repo layout, rendering model, deployment | CC13 |
| 2 | `architecture/design-system-spec.md` | Tokens, components, brand, a11y rules | CC13 |
| 3 | `architecture/auth-and-authorization-spec.md` | Clerk, roles, sessions, step-up, impersonation | CC13 |
| 4 | `api/trpc-router-spec.md` | Every tRPC procedure — 12 sub-routers, ~80 procedures | CC13 |
| 5 | `wizard/configuration-wizard-spec.md` | 9-step onboarding flow | CC14 |
| 6 | `views/operations-control-spec.md` | Primary daily-use view (tiles + escalations + running + invocations + costs) | CC15 |
| 7 | `views/brain-view-spec.md` | Read-only vault browser with semantic search | CC16 |
| 8 | `views/activity-log-and-audit-spec.md` | Unified timeline + audit (8 event sources) | CC17 |
| 9 | `views/settings-spec.md` | 7 panels: integrations, secrets, billing, config, team, API keys, notifications | CC18 |
| 10 | `views/agency-partner-portal-spec.md` | Parent-tenant portfolio for agency partners | CC19 |
| 11 | `PHASE-4-SUMMARY.md` | This document |

**Total: 11 specs, ~4,500 lines of design decisions.**

---

## Architecture at a glance

```
                        ┌──────────────────────────────────┐
                        │           User browsers          │
                        └─────────────────┬────────────────┘
                                          │ HTTPS
                                          ▼
                        ┌──────────────────────────────────┐
                        │       Cloudflare (edge)          │
                        │  DNS · WAF · static CDN · TLS    │
                        └─────────────────┬────────────────┘
                                          │
                                          ▼
                        ┌──────────────────────────────────┐
                        │   Hetzner LB (UK, private)       │
                        └─────────────────┬────────────────┘
                                          │
                         ┌────────────────┴───────────────┐
                         ▼                                ▼
            ┌──────────────────────┐         ┌──────────────────────┐
            │  Next.js dashboard   │         │  Next.js dashboard   │
            │  (replica 1)         │         │  (replica 2)         │
            │                      │         │                      │
            │  RSC + tRPC + React  │         │  RSC + tRPC + React  │
            └────────┬─────────────┘         └─────────┬────────────┘
                     │                                 │
                     │  (tRPC procedures call these)  │
                     │                                 │
        ┌────────────┴────────┬────────────┬──────────┴───────┐
        ▼                     ▼            ▼                  ▼
  ┌──────────────┐    ┌─────────────┐  ┌───────────┐   ┌──────────────┐
  │  Postgres    │    │  Secrets    │  │  Temporal │   │  Escalation  │
  │  (control +  │    │  Vault      │  │  (workflows│   │  Notifier    │
  │   ops + per- │    │  service    │  │   status)  │   │  (SSE source)│
  │   tenant)    │    │             │  │            │   │              │
  │              │    │  KMS CMKs   │  │            │   │              │
  └──────────────┘    └─────────────┘  └────────────┘   └──────────────┘

                  ↑   All Phase 3 components — the dashboard is their UI   ↑
```

The dashboard is a **thin** layer over Phase 3. It doesn't store its own application state anywhere beyond session cookies + client-side query cache. Every canonical fact lives in the platform layer.

---

## Key design decisions locked in this phase

### 1. Next.js 15 + App Router + tRPC + Prisma + Tailwind
Typesafe end-to-end, React ecosystem for hiring, server components for fast first paint. Not Remix (smaller ecosystem), not plain SPA (no SSR), not separate backend (tRPC is the cleanest contract).

### 2. Monorepo via Turborepo + pnpm
Shared types between frontend, backend, and all platform services. Release atomicity matters — the dashboard's tRPC client must match the dashboard's tRPC server, always.

### 3. Clerk for auth (v1)
EU data option, org primitive matches our multi-tenant shape, fast to integrate, MFA built-in. Migrate specific enterprise partners to WorkOS when they require SAML.

### 4. Three-layer auth
Clerk session middleware → tRPC procedure guards → Postgres RLS. Belt-and-braces: an application bug can't leak tenants; a DB compromise can't bypass RLS.

### 5. Dark default with emerald/amber/black palette
Operators spend hours in this tool; dark reduces eye strain. Palette inherits from the Session 0 prototype. Light mode exists but isn't the focus.

### 6. Dense UI — 14px body default, table-heavy layouts
Ops tools punish low information density. `text-sm` for body; tables are the primary surface; sticky headers; tabular-nums everywhere.

### 7. SSE for real-time (not WebSockets)
Real-time is broadcast-only in our shape (escalations arrive, invocations complete, provisioning progresses). SSE is simpler, HTTP/2-friendly, survives naive proxies.

### 8. tRPC with Zod — no REST for internal API
Procedures are the contract. Types flow from Prisma to Zod to tRPC to React. No schema drift. External API (for customers) is REST and documented separately.

### 9. RSC by default, `'use client'` only where needed
Interactive components marked explicitly. Most data-display views are server-rendered. Reduces client bundle size.

### 10. Wizard is operator-first, not self-serve
Onboarding is high-touch for v1. An IntelForce operator (or agency admin) runs the Wizard on behalf of the new tenant. Self-serve is a later feature — maybe v2.

### 11. Brain view renders vault natively (not via GitHub UI)
Tenants shouldn't know their vault is on GitHub. Dashboard reads from tenant container volumes (which git-sync) and renders markdown with markdoc + mermaid + shiki. Safer, nicer, searchable.

### 12. Agency portal as first-class, not afterthought
`parent_tenant_id` in schema, `/agency/[slug]/*` routes, dedicated RLS policies, roll-up billing. Rigby Group-shaped customers get a real product — not a hacky "invite me to everything" pattern.

### 13. Same codebase for tenant and operator chrome
The Operations view, Brain view, etc., are shared components. Operators see them in admin chrome (`/admin/tenants/[tenantId]/operations`); tenants see them in tenant chrome (`/t/[slug]/operations`). Less code to maintain; consistent UX.

### 14. Step-up auth for every destructive mutation
Decommission tenant, rotate secrets, change plan, remove owners — all require MFA re-challenge. Platform-admin grants require two-person approval.

### 15. WCAG AA, not AAA
Professional accessibility without paying the design tax of AAA. AA is industry standard for business tools.

---

## What this phase enables

With Phase 4 shipped:
- **Operators can onboard a tenant** without SSH or kubectl — full Wizard flow
- **Tenants can see** their agents working, draft outputs, escalations, and spend, live, without support hand-holding
- **Agency partners can manage** portfolios of sub-tenants with roll-up visibility
- **Support can debug** via impersonation + full activity/audit visibility
- **Compliance gets** a 7-year audit trail for every mutation
- **Real-time visibility** via SSE for escalations, invocations-running, provisioning workflows

---

## What Phase 4 does NOT deliver

- **Marketing site** (landing page, pricing) — Phase 5 (`apps/marketing/`)
- **Legal artifacts** (MSA, DPA, SLA, trademark filing) — Phase 5
- **External REST API for customers** — Phase 5 (API keys infrastructure exists; actual REST endpoints deferred)
- **White-label branding** for agency partners — deferred to v1.1
- **Mobile native app** — responsive only; no store app planned
- **Self-serve onboarding** — operator-first for v1
- **Ops runbooks** beyond what's inline in specs — Phase 6
- **i18n** — UK-English only for v1

---

## Dependency ordering for build

If handing this to a dev team, suggested sequence minimising blockage:

1. **Week 1–2: Foundation** (CC13 part 1)
   - Monorepo scaffolded with Turborepo
   - Next.js app with App Router
   - Design system package (`packages/ui/`)
   - Clerk integration + middleware
   - Prisma client generated from Phase 3 schema

2. **Week 3–4: API layer** (CC13 part 2)
   - `packages/trpc/` with context, middleware, procedure types
   - All 12 sub-routers scaffolded
   - Audit middleware working
   - SSE subscription infrastructure

3. **Week 5–6: Operations Control view** (CC15)
   - Highest-value view; validates architecture end-to-end
   - KPI tiles, escalations feed (SSE), invocations table, costs module
   - Once this ships, the pattern for other views is locked in

4. **Week 7: Activity Log + Audit** (CC17)
   - Reuses SSE and pagination patterns from Operations

5. **Week 8–9: Configuration Wizard** (CC14)
   - Heaviest frontend work; ties directly to Phase 3 Provisioning System

6. **Week 10: Brain view** (CC16)
   - Vault rendering, markdoc, semantic search

7. **Week 11: Settings** (CC18)
   - Seven panels; lots of mutations; careful permission enforcement

8. **Week 12: Agency Partner portal** (CC19)
   - Reuses most components from earlier views

**Total: ~12 dev-weeks for one senior engineer, ~6–7 weeks with two engineers in parallel.**

---

## Cost envelope

| Component | Monthly (MVP) | Monthly (50 tenants) |
|---|---|---|
| Hetzner (2x Next.js instances) | £60 | £90 |
| Redis (for sessions + rate limits) | £15 | £25 |
| Clerk (auth) | £40 | £150 |
| Cloudflare (pro tier) | £25 | £25 |
| **Dashboard infrastructure total** | **£140/mo** | **£290/mo** |

Relative to revenue: at 10 tenants on Growth tier, this is ~0.3% of revenue. Dashboard cost is immaterial.

Clerk scales with monthly active users (MAU). At ~5 users per tenant × 50 tenants = 250 MAU, we're comfortably in Clerk's paid tier.

---

## Risks and open questions

### R1 — Clerk dependency
Clerk is central to the auth story. If Clerk has a prolonged outage, users can't sign in. Existing sessions keep working. We fall back to extended session validity (24h) during outages. Not a business-threatening risk, but worth monitoring.

### R2 — Real-time SSE at scale
Each tenant page opens ~2 SSE connections. 50 tenants × 3 concurrent users × 2 connections = 300 connections. Fine. At 500 tenants = 3,000 concurrent. Still fine for Next.js. At 5,000+ we revisit.

### R3 — Vault rendering performance
Large markdown files (> 500KB) slow down markdoc rendering. We cap preview at 1MB. Very large files get a download link. Unlikely to be a problem in practice — most vault files are < 50KB.

### R4 — Design system debt
Every spec references design tokens and components. If the design system evolves substantively, every view needs revisiting. Mitigation: strict review on token/component additions; Storybook catalogue to visualise changes.

### R5 — Operator Wizard fatigue
Operators will run the Wizard many times. If it's annoying, they'll skip steps or batch-submit sloppy configs. Mitigation: analytics per step, user-test with early operators, keep ruthlessly editing copy and defaults.

---

## Open decisions (recap from individual specs)

**OD-P4-A:** Clerk vs WorkOS for auth
- Recommendation: Clerk now; WorkOS for enterprise SAML later

**OD-P4-B:** Marketing site same app or separate
- Recommendation: separate (`apps/marketing/`)

**OD-P4-C:** Mobile native vs responsive only
- Recommendation: responsive only; revisit post-launch

**OD-P4-D:** Admin and tenant URLs — same domain or separate
- Recommendation: same domain, role-based routing

**OD-P4-E:** Add WorkOS alongside Clerk now, or wait
- Recommendation: wait for first deal requirement

**OD-P4-F:** Password vs passwordless primary
- Recommendation: passwordless; password as secondary

**OD-P4-G:** Social sign-in allowed?
- Recommendation: disabled for operators; Google only for tenant users (optional)

These are recommendations. Final lock happens before CC13 build starts.

---

## What to do next

### Before starting CC13:
1. Lock open decisions OD-P4-A through OD-P4-G
2. Buy the `intelforce.ai` production domain (if we're still landing on this name — see Open Decision C3a below)
3. Sign up for Clerk; verify EU data region
4. Sign up for PagerDuty (for Phase 3 alerts; reused by dashboard)

### While Phase 4 is being built:
- Phase 5 (legal, landing page, trademark, billing) is entirely parallel
- Phase 3 platform components must be ready before Operations view can load real data
- Run early Wizard walkthroughs with Maddox + Jack before formal build — catches usability issues before they're coded

### Phase 4 completion criteria:
- All 11 specs implemented and deployed to staging
- A real tenant (test or first-customer) onboarded end-to-end via the Wizard
- That tenant's operator successfully completes one full daily workflow (check escalations, view a draft, resolve, check costs)
- At least one agency partner tested the portfolio view with 2+ sub-tenants
- Accessibility audit passes WCAG AA on all primary views
- Performance targets met (LCP < 1.5s p75 for Operations view)

When those are green, Phase 4 ships and CC13–CC19 are done. Phase 5 (legal, marketing, billing) picks up the baton.

---

## The three persistent blockers (unchanged from Phase 3)

Nothing in Phase 4 resolves these. All still need attention:

### 1. POC runbook still unrun
The Phase 1 Week-1 experiment runbook needs a real-world run before platform engineering starts. If Proposal Builder fails on a real Fathom call, much of Phase 3/4 is designing infrastructure for the wrong thing. Highest priority.

### 2. Product naming (C3a)
"IntelForce" has trademark conflicts (intelforce.org cyber co, IntelForce GPT on ChatGPT, intelforce.com for sale). **Recommendation remains: rename to Clawd.** This blocks:
- Trademark filing
- `clawd.ai` domain registration
- Landing page copy
- Logo + identity design
- This entire planning set using `IntelForce AI OS` as placeholder

Decision needed before Phase 5 (legal + marketing).

### 3. First customer dev trial
Referenced in Phase 1. The webhook receiver spec remains the best dev-trial brief when hiring — 5 days, binary pass/fail.

---

## The artifact set so far

At end of Phase 4:

| Category | Files |
|---|---|
| Navigation & meta | 3 |
| Strategic & business | 6 |
| Phase 1 POC | 16 |
| Phase 2 agent suite | 78 |
| Phase 3 platform | 9 |
| Phase 4 dashboard | 11 |
| **Total shipped** | **123** |
| Future phases pending | ~70 |

Phase 5 (legal, billing, marketing) and Phase 6 (ops runbooks) are next. Phase 5 can start now in parallel with Phase 4 build. Phase 6 waits until Phase 3+4 are shipping.
