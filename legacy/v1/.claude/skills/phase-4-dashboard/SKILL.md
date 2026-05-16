---
name: phase-4-dashboard
description: Phase 4 Dashboard — Next.js 15 web dashboard (deliverable as Teams Tab and/or standalone web app) covering operations control view, brain view, agency partner portal, admin panel, and reporting. Use this skill when planning or building customer-facing visibility outside Teams DMs, designing Tab integrations, or building admin/agency views. Also triggers on: dashboard, Tab, web UI, Next.js, tRPC, Prisma, Clerk, operations view, brain view, admin panel, reporting view.
---

# Phase 4 — Dashboard Skill

**Pack status:** Deferred (v1.5 target). Activate when customers ask for visibility outside the Teams approval flow.

## Where the spec lives

`docs/phase-4-dashboard/` — 11 files, ~4,543 lines

| File | Covers | Consult when |
|---|---|---|
| `README.md` | Pack orientation | Starting Phase 4 work |
| `tech-stack.md` | Next.js 15 + tRPC + Prisma + Clerk | Scaffolding the dashboard |
| `operations-control-view.md` | "What's pending my approval" view | Primary HR Lead UI |
| `brain-view.md` | Agent reasoning + tuning | Power-user tier |
| `agency-partner-portal.md` | Multi-tenant view for agencies | Agency Partner plan |
| `auth-and-sso.md` | Teams SSO + OAuth | Setting up auth |
| `database-access-patterns.md` | How dashboard reads from shared D1/Postgres | Data access layer |
| `ui-components-library.md` | Component spec | Design system |
| `admin-panel.md` | Intel Force-side customer management | Internal ops portal |
| `reporting-views.md` | Metrics, SLA tracking, billing | Subscription management |
| `PHASE-4-SUMMARY.md` | Pack summary | Orientation |

## When to activate Phase 4

**Activation triggers (need ONE to justify building):**
- 3+ customers ask "can I see this outside Teams?" in the same month
- An Agency Partner customer signs (Rigby Group-shaped); they need a central view
- HR Lead starts forwarding Teams screenshots to their manager for reporting — sign they need a real report surface
- Sales team (at Growth/Scale tier) wants pipeline visibility outside Teams

**Activation anti-triggers:**
- "It would look more professional with a dashboard" — without specific pain, no
- "Our competitors have a dashboard" — we're not competing on parity
- "I want to build the dashboard because it's fun" — wrong reason

## The dashboard in two forms

### Form 1: Teams Tab (priority)
Embedded inside the Intel Force OS Teams app as an additional Tab. Advantages:
- Customer never leaves Teams
- SSO is automatic (Teams passes the identity token)
- Minimal new infrastructure (Tab hosts the Next.js app via iframe)
- Feels like a native feature, not a separate product

### Form 2: Standalone web app (secondary)
At `app.intelforce.ai`. For:
- Agency Partners managing multiple tenants
- Admin/internal use
- Customers who want dashboard access for people not in Teams

## The three primary views

### Operations Control View (HR Lead's main page)
Key sections:
- Pending approvals queue (replaces the DM approval cards for high-volume HR leads)
- Recent activity stream
- Quick stats: messages handled today, approval rate this week, escalations this month
- Filters by channel, employee, sensitivity

This is the default page when HR Lead opens the Tab.

Spec: `operations-control-view.md`

### Brain View (power-user)
Shows the agent's reasoning behind each draft:
- Why the agent chose this sensitivity classification
- Which handbook sections were retrieved
- Confidence score with justification
- Option to mark as "agent got this right" or "agent got this wrong" (feedback loop)

For customers who want to understand and tune the agent. Growth tier and above.

Spec: `brain-view.md`

### Agency Partner Portal
For agencies / multi-company customers. Shows:
- All customer entities in the agency group
- Cross-entity reporting
- Per-entity drill-down
- Billing split across entities

Required if/when Rigby Group or similar signs.

Spec: `agency-partner-portal.md`

## The tech stack

From `tech-stack.md`:

| Layer | Choice | Why |
|---|---|---|
| Framework | Next.js 15 (App Router) | React Server Components, modern patterns |
| API layer | tRPC | Type-safe end-to-end, no REST/GraphQL boilerplate |
| ORM | Prisma | Best DX for Postgres/D1 |
| Auth | Clerk (web) + Teams SSO (Tab) | Managed auth; Teams SSO is free |
| Styling | Tailwind CSS | Consistent with landing page |
| Components | Shadcn/ui | Accessible, copy-paste |
| Hosting | Cloudflare Pages | Stays in the Cloudflare ecosystem |
| Database | Same as v1 Worker (D1 in v1.5, Postgres in v2) | Consistency |

## The build sequence (when activated)

1. Scaffold Next.js 15 project
2. Set up Clerk for standalone web auth
3. Set up Teams SSO for Tab (via Teams AI Library helpers)
4. Build data access layer (tRPC routes reading from D1/Postgres)
5. Build Operations Control View first (highest customer value)
6. Add Brain View
7. Deploy as standalone web app
8. Integrate as Teams Tab in the Intel Force OS manifest
9. Update manifest to include Tab scope

Full sequence: `tech-stack.md` §5.

## Cross-references

- **Auth strategy** depends on Phase 3 identity model (if Phase 3 is live)
- **Admin panel** operates on Intel Force's own Postgres; reads all tenants (with proper RBAC)
- **Reporting views** power per-customer billing (integrate with Phase 5 Stripe integration)
- **Teams Tab integration** requires manifest updates; cross-ref `teams-hr-agent` skill

## The agency partner question

The Agency Partner play (Rigby Group-style) is a meaningful revenue opportunity that would accelerate Phase 4 activation. One agency partner could represent £3,000-£8,000 MRR across multiple group entities.

If Rigby Group (or similar) commits:
- Phase 4 Agency Partner Portal becomes a priority
- Can be run manually in the interim (hand-built reporting)
- Full portal build: 3-4 weeks

See Phase 0 strategic plan §6 and Phase 5 pricing spec §5 for the Agency Partner model.

## The v1.5 vs v2 tension

Phase 4 targets v1.5 (before Phase 3). But some dashboard features depend on Phase 3 (multi-tenant Postgres, richer agent telemetry).

Resolution:
- **v1.5 dashboard** is minimal: Operations Control View reading from D1
- **v2 dashboard** (post-Phase 3) adds Brain View, Agency Portal, full Admin Panel
- Don't try to build the full Phase 4 spec before Phase 3 unless a specific customer pain justifies it

## When NOT to use this skill

- For current v1 Teams work: `teams-hr-agent` skill
- For commercial motion: `gtm-execution` skill
- For landing page / marketing site: Phase 5 `landing-page-spec.md`

The dashboard is an app for customers who are already customers. Not a marketing asset.

## One-sentence summary

Phase 4 is the web/Tab dashboard; you build it when customers specifically ask for out-of-Teams visibility, usually around customer 15.
