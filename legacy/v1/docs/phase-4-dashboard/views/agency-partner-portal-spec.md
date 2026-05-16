# Agency Partner Portal Specification

**The parent-tenant view for agency partners (think Rigby Group) managing multiple sub-tenants under one umbrella.**

> **Audience:** engineer implementing CC19. Agency partner admins and members. Jack-and-Maddox-style operators running a portfolio.
>
> **Status:** v1.0. Lives at `/agency/[partnerSlug]/*`.
>
> **Why this exists:** Phase 1–4 so far assumes one tenant per account. But agencies and holding companies want one login to see across N sub-tenants — aggregated metrics, shared onboarding queue, roll-up billing. This view is the delta.

---

## 1. Agency partner mental model

An **agency partner** is a parent entity (e.g. Rigby Group, or a marketing agency) that manages multiple **sub-tenants** (e.g. SCC, Allect, Eden Hotel Collection; or the agency's client list).

Each sub-tenant is a first-class tenant — it has its own vault, its own agents, its own invocations, its own billing (optionally rolled up). The agency partner gets a bird's-eye view across all sub-tenants.

### 1.1 Data model recap

Per `phase-3-platform/postgres/schema-spec.md`:

- `control.tenants.parent_tenant_id` — set for sub-tenants, references the agency's parent tenant row
- Agency itself is a tenant row with `plan='agency_partner'`
- Clerk organisation for the agency; separate Clerk organisations for each sub-tenant (OR agency admins are members of every sub-tenant org — see §4)

### 1.2 When an agency partner is warranted

- Customer has > 3 related tenants
- Customer wants aggregate reporting
- Customer wants roll-up billing (single invoice)
- Customer wants to delegate staff to manage some sub-tenants without access to others

When any of those is false, regular tenants suffice. Don't force the agency model on single-tenant customers.

### 1.3 Pricing

Agency partner tier pricing is bespoke (enterprise-style). Typically: a platform fee + per-sub-tenant cost. Negotiated in MSA (Phase 5). Not on the public pricing page.

---

## 2. Routes

```
/agency/[partnerSlug]                                — portfolio overview (landing)
/agency/[partnerSlug]/tenants                        — sub-tenant list + management
/agency/[partnerSlug]/tenants/[subTenantSlug]        — drills into that sub-tenant (reuses tenant context views)
/agency/[partnerSlug]/onboarding                     — queue of wizards in-progress for new sub-tenants
/agency/[partnerSlug]/activity                       — rolled-up activity feed (all sub-tenants)
/agency/[partnerSlug]/billing                        — consolidated billing
/agency/[partnerSlug]/team                           — agency-level team management
/agency/[partnerSlug]/settings                       — agency-level settings (notifications, white-label)
```

Drilling from `/agency/[partnerSlug]/tenants/[subTenantSlug]` into a sub-tenant reuses the standard tenant views (`/t/[slug]/operations` patterns) but in agency chrome — breadcrumb shows the agency, easy "Back to portfolio" link.

---

## 3. Portfolio overview (`/agency/[partnerSlug]`)

The landing page when an agency admin logs in.

### 3.1 Layout

```
┌─────────────────────────────────────────────────────────────────────┐
│  Rigby Group  •  Agency portal                                       │
│  Jack Rigby (admin)  •  3 sub-tenants                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Portfolio — current month                                          │
│                                                                      │
│  ┌──────────┬──────────┬──────────┬──────────┬──────────┐         │
│  │ TENANTS  │ SPEND    │ INVOCATIONS │ OPEN ESCAL │ SUCCESS │      │
│  │   3      │ £4,890  │  1,247     │    12     │  94.3%   │      │
│  │ 3 active │ of £6k  │ ↑ 23%      │           │          │      │
│  └──────────┴──────────┴──────────┴──────────┴──────────┘         │
│                                                                      │
│  Sub-tenants                                                        │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  TABLE                                                         │  │
│  │  Name  │ Plan  │ Status │ Month spend │ Escalations │ Actions │  │
│  │  ─────────────────────────────────────────────────────────   │  │
│  │  SCC   │ Scale │ ✓ live │ £2,140/3k   │ 4 open      │ →       │  │
│  │  Allect│ Growth│ ✓ live │ £1,340/1.5k │ 3 open      │ →       │  │
│  │  Eden  │ Growth│ ✓ live │ £1,410/1.5k │ 5 open      │ →       │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  Portfolio activity (last 24h)                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ 09:47  SCC — proposal-builder completed "Deloitte proposal"  │  │
│  │ 08:32  Eden — priya resolved escalation "brand-guidelines"   │  │
│  │ 04:00  All — librarian nightly sweeps completed              │  │
│  │ ...                                                            │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  Quick actions:  [+ Add sub-tenant]  [Export portfolio report]     │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 KPI tiles (row 1)

- **Tenants** — count; "X active, Y provisioning, Z suspended"
- **Spend** — aggregate across all sub-tenants this month; vs total aggregate budget
- **Invocations** — aggregate invocations this week; delta vs previous
- **Open escalations** — aggregate open across sub-tenants
- **Success rate** — weighted-by-invocation across sub-tenants

Click any tile → filters downstream tables to match.

### 3.3 Sub-tenant table

| Column | Content |
|---|---|
| Name | Tenant name + slug (smaller) |
| Plan | Badge |
| Status | `active`, `suspended`, `provisioning`, etc. |
| Month spend | £ used / £ budget + progress bar |
| Escalations | Count of open, colour-coded |
| Last activity | Relative time of most recent invocation |
| Actions | `→` to drill in |

Sortable on every column. Filter: by plan, by status, by escalation count.

Row click: navigates to `/agency/[partnerSlug]/tenants/[subTenantSlug]` (drill into that tenant in agency chrome).

### 3.4 Portfolio activity feed

Same event shape as the Activity Log view (Phase 4 activity-log-and-audit-spec), but aggregated across all sub-tenants with tenant identifier on each row. Last 24 hours. Click "View all activity" → `/agency/[partnerSlug]/activity`.

---

## 4. Permissions and Clerk model

### 4.1 Agency admin access to sub-tenants

Two plausible models:

**Model A — Membership in every sub-tenant org.**
- Agency admins are automatically added as members of every sub-tenant's Clerk organisation
- Pros: simple — same auth check as tenant context
- Cons: Clerk membership count balloons; harder to audit

**Model B — Agency-scoped access via parent relationship.**
- Agency admins are members of the agency Clerk org only
- Backend checks: user in agency org AND sub-tenant's `parent_tenant_id = agency's tenant_id`
- Pros: cleaner; sub-tenant membership is accurate (only direct team members)
- Cons: extra logic in `tenantProcedure`

**Recommendation: Model B.** Cleaner semantics at a small code cost. `tenantProcedure` becomes: "User is in this tenant's org OR in this tenant's parent's org."

### 4.2 Role matrix (recap from auth spec)

- `agency_admin` — full access to agency view + any sub-tenant
- `agency_member` — view agency view + any sub-tenant (no destructive actions)

Sub-tenant-level roles (tenant_owner / tenant_member / tenant_viewer) are separate from agency roles. A person can be both: `agency_admin` at the Rigby Group agency AND `tenant_owner` at SCC specifically.

### 4.3 Sub-tenant isolation

Sub-tenants of the same agency do NOT see each other. If two agency members happen to not be agency admins, they only see the sub-tenants they have direct tenant-level membership in.

Agencies can optionally elect "transparent mode" (all sub-tenants visible to all agency members) — toggle in agency settings. Default: opaque.

---

## 5. Sub-tenant management

### 5.1 Add sub-tenant

`+ Add sub-tenant` button top-right:
- Opens the Configuration Wizard (Phase 4 wizard spec) scoped to this agency
- Wizard's step 1 pre-fills `parent_tenant_id = <agency tenant_id>`
- On submit, the new sub-tenant is created with the agency as its parent
- Agency admin sees it immediately in the portfolio view (in `provisioning` state)

### 5.2 Sub-tenant list (`/agency/[partnerSlug]/tenants`)

Full-width table with all sub-tenants:
- Extended columns vs the portfolio preview: plan, status, owner contact, cost budget, last invocation, monthly spend, actions
- Filters: plan, status, created date range
- Search: by name or slug
- Bulk actions: `Export CSV`, `Compare` (side-by-side metrics)

### 5.3 Drilling in

Click a sub-tenant → `/agency/[partnerSlug]/tenants/[subTenantSlug]`. This is the tenant context but with agency chrome. The user sees:
- Breadcrumb: "Rigby Group > SCC > Operations"
- Easy "Back to portfolio" in the nav
- All the standard tenant views work (Operations, Brain, Activity, Settings)

From here, the agency admin can do everything a `tenant_owner` could do for that sub-tenant.

---

## 6. Onboarding queue (`/agency/[partnerSlug]/onboarding`)

Shows sub-tenants currently in provisioning — wizard drafts + active workflows.

### 6.1 Drafts table

| Slug | Created by | Progress | Last saved | Actions |
|---|---|---|---|---|
| new-client-co | jack@ | Step 4 of 7 | 2h ago | Resume / Delete |
| ... | ... | ... | ... | ... |

### 6.2 Active workflows

| Slug | Step | Started | Blocked on? | Actions |
|---|---|---|---|---|
| acme-corp | Awaiting OAuth completion | 3h ago | HubSpot connection | View workflow / Nudge tenant |
| ... | | | | |

Nudging sends a branded email to the tenant admin: "Hi — we're ready to finalise your setup. Just need you to connect HubSpot. [Connect now]."

### 6.3 Stuck workflows

Workflows in error or stalled > 24h highlighted at top. One-click `Retry` or `Abort` via the standard provisioning procedures.

---

## 7. Portfolio activity (`/agency/[partnerSlug]/activity`)

Same data model as tenant-level activity log (Phase 4 activity-log-and-audit-spec), but:
- Includes a `tenant` column (which sub-tenant the event belongs to)
- Additional filter: by sub-tenant
- Preset view: "All sub-tenants" (default), or scoped to any specific one
- Export includes tenant identifier

Aggregated view helps answer: "What happened across my portfolio this morning?"

---

## 8. Consolidated billing (`/agency/[partnerSlug]/billing`)

### 8.1 Billing model choice

Agencies choose at setup:
- **Per-sub-tenant billing** — each sub-tenant's owner pays; agency doesn't see invoices
- **Roll-up billing** — agency pays one invoice for all sub-tenants

Roll-up is the common case for agencies; per-sub-tenant is for holding-company patterns where each sub owns its own budget.

### 8.2 Roll-up billing view

Table:

| Sub-tenant | Plan fee | Variable usage | Total |
|---|---|---|---|
| SCC | £2,500 | £240 | £2,740 |
| Allect | £1,800 | £180 | £1,980 |
| Eden | £1,800 | £220 | £2,020 |
| — | — | — | — |
| **Total** | **£6,100** | **£640** | **£6,740** |

Monthly invoice covers all sub-tenants as line items. Delivered as a single Stripe invoice + PDF with detailed breakdown.

### 8.3 Agency-level payment method

Single payment method on file for the agency. Each sub-tenant doesn't need its own card.

### 8.4 Invoice history

List of past aggregate invoices with PDF downloads.

### 8.5 Cost allocation reports

`Export cost allocation` button:
- CSV showing per-sub-tenant, per-agent costs for a selected period
- Used by agencies to charge clients back or run internal cost-centre reporting

---

## 9. Team (`/agency/[partnerSlug]/team`)

Agency-level team, separate from sub-tenant teams.

### 9.1 Member list

Table similar to tenant Settings Team panel:

| Name | Email | Agency role | Sub-tenant memberships |
|---|---|---|---|
| Jack Rigby | jack@ | admin | (all, via admin) |
| Maddox | maddox@ | admin | (all, via admin) |
| Dana | dana@ | member | SCC, Allect |
| ... | | | |

Last column: which sub-tenants this user has direct membership in (relevant for non-admin agency members).

### 9.2 Invitation

Invite with role (admin / member) and optional sub-tenant assignments.

### 9.3 White-label branding (deferred note)

Agency may want to white-label the dashboard for their sub-tenants (custom logo, custom email sender domain, custom support URL). Listed in agency settings panel but implementation deferred to v1.1.

---

## 10. Agency settings (`/agency/[partnerSlug]/settings`)

Analogous to tenant Settings but scoped to the agency:

- **Config**: agency name, billing email, payment method, default timezone for new sub-tenants
- **Notifications**: agency-level escalation digest (e.g., "daily digest of all portfolio escalations"), Slack routing per severity
- **Sub-tenant defaults**: default plan tier for new sub-tenants, default cost budget, default enabled agents (used as Wizard pre-fill)
- **White-label** (v1.1): logo, colours, custom domain, email sender
- **Transparent mode**: toggle whether agency members see all sub-tenants or only those they have direct membership in

---

## 11. Rigby Group specifically — use case

Context: Maddox has Rigby Group access. SCC, Allect, Eden Hotel Collection are the three sub-tenants explored in earlier conversations.

The agency portal is built for exactly this shape. Rigby Group's agency admins (Maddox, Sir Peter Rigby perhaps, plus ops staff) see:
- Portfolio overview showing SCC / Allect / Eden
- Drill into SCC for its ops view (which is the SCC IT services deployment of the AI OS)
- Roll-up billing at the Rigby Group level
- Add new sub-tenants when Rigby acquires or spins up new divisions

The model scales to other Rigby-Group-style customers without product changes.

---

## 12. Performance considerations

- Portfolio queries aggregate across N sub-tenants. For N < 20, straightforward UNION. For N > 50, use a dedicated materialised view `control.agency_portfolio_summary` refreshed every 5 min.
- Sub-tenant table with all columns populated: < 800ms for 50 sub-tenants.
- Activity feed: same pagination strategy as tenant-level; just wider query surface.

RLS still applies — the agency's Postgres role sees its own tenant plus sub-tenants via parent relationship. Explicit RLS policy:

```sql
CREATE POLICY agency_scoped_read ON control.invocations
  FOR SELECT
  USING (
    tenant_id = current_setting('app.current_tenant_id', true)
    OR tenant_id IN (
      SELECT id FROM control.tenants
      WHERE parent_tenant_id = current_setting('app.current_tenant_id', true)
    )
  );
```

Similar policies on every tenant-scoped table. Added to the Phase 3 schema as an addendum migration when the agency view ships.

---

## 13. Accessibility

- Landing page tiles: same `<article aria-label>` pattern as Operations
- Sub-tenant table: caption, sortable headers announced correctly
- Drilldown nav: breadcrumbs with proper `aria-label="Breadcrumb"`
- Screen reader announces which tenant context is active at any time

---

## 14. Implementation checklist (for CC19)

- [ ] Routes `/agency/[partnerSlug]/*`
- [ ] `agencies.*` tRPC procedures (partially scaffolded in router spec §5.10)
- [ ] `agencyProcedure` middleware enforcing parent-tenant relationship
- [ ] RLS policies for agency-scoped reads (addendum migration)
- [ ] Portfolio overview with aggregate queries
- [ ] Sub-tenant table with filters
- [ ] Drilldown into sub-tenant context with breadcrumbs
- [ ] Onboarding queue (wizards + provisioning)
- [ ] Portfolio activity feed (reuses Activity view's components with tenant column)
- [ ] Consolidated billing view + Stripe invoice aggregation
- [ ] Agency-level team management
- [ ] Agency-level settings
- [ ] E2E tests: agency admin onboards a new sub-tenant; drilldown; roll-up billing
- [ ] Performance benchmark: 50-sub-tenant portfolio loads < 800ms

---

## 15. What's deferred to v1.1

- **White-label branding** — custom logo, colours, domain, email sender for sub-tenants under this agency
- **Cross-sub-tenant search** — "find all proposals about dentistry across my portfolio"
- **Portfolio-level SOPs** — shared standard operating procedures that apply to all sub-tenants
- **Benchmarking** — "your SCC is in the top 20% of IT-services tenants for conversion rate"
- **Granular sub-tenant membership assignment** during invitation (currently: admin or sub-tenant-scoped manually)

---

## 16. Related

- `auth-and-authorization-spec.md` — `agency_admin`, `agency_member` roles, the parent-tenant access pattern
- `api/trpc-router-spec.md` §5.10 (agency procedures)
- `wizard/configuration-wizard-spec.md` — onboarding a sub-tenant reuses the Wizard
- `views/activity-log-and-audit-spec.md` — shared data model with agency-scoped filter
- `phase-3-platform/postgres/schema-spec.md` — `control.tenants.parent_tenant_id` is the linkage
- Rigby Group strategic context (Session 0 docs) — the motivating use case
