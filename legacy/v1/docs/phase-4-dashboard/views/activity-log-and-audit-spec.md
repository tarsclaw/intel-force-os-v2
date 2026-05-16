# Activity Log + Audit Specification

**The chronological record of everything that happened in a tenant — or across the platform. Agents, users, integrations, configuration changes, escalations, all on one timeline.**

> **Audience:** engineer implementing CC17. Operators doing incident forensics. Tenants answering "what happened to my account last Tuesday?"
>
> **Status:** v1.0. Lives at `/t/[tenantSlug]/activity` (tenant context) and `/admin/ops/audit` (platform-wide).
>
> **Why combined:** in smaller products, "activity log" and "audit log" are different surfaces. For us, the distinction is artificial — a tenant seeing "agent ran" and "user changed integration" and "escalation resolved" as one stream is more useful than splitting them by category. We present one timeline, filterable.

---

## 1. Purpose

Three use cases:

1. **Tenant reassurance.** "What did you do for me last week?" answered by a timeline showing agent activity + integration health + escalations resolved.
2. **Operator forensics.** "When did the voice profile last change?" "Who rotated the Fathom secret?" — one searchable timeline.
3. **Compliance / audit.** For regulated clients (dental, finance), a defensible record of every configuration change, every secret access, every user action.

One view, three audiences, three filter presets.

---

## 2. Data sources

The view aggregates events from multiple Postgres tables:

| Source | Event types |
|---|---|
| `control.invocations` | Agent runs (started, completed, failed, escalated) |
| `control.escalations` | Escalation raised, acknowledged, resolved, won't-fix |
| `control.integrations` | Integration added, disabled, OAuth reconnected |
| `control.secrets_metadata` | Secret created, rotated, revoked |
| `control.tenant_versions` | Tenant config changes |
| `ops.audit_log` | User actions (sign-in, permission changes, destructive mutations) |
| `control.webhook_registrations` | Webhook added, removed |
| `ops.deployments` | Platform version deployed (affects all tenants; cross-cut on tenant timeline) |

Backend procedure `audit.list` does a UNION ALL with a projection to a common shape, ordered by time, paginated cursor-based.

### 2.1 Common event shape

```typescript
type ActivityEvent = {
  id: string;                         // concatenated source-id (e.g., "invocation:12345")
  ts: Date;
  tenantId: string;
  category: 'agent' | 'escalation' | 'integration' | 'secret' | 'config' | 'user' | 'webhook' | 'platform';
  type: string;                       // e.g., "agent.completed", "escalation.resolved"
  actor: {
    kind: 'agent' | 'user' | 'system' | 'scheduler';
    identifier: string;               // e.g., "proposal-builder@1.0.0", "priya@meadowlane.co.uk"
  };
  subject?: string;                   // what was acted on (file path, integration name, etc.)
  detail: string;                     // human-readable one-line summary
  metadata?: Record<string, unknown>; // event-specific structured data
  severity: 'info' | 'low' | 'medium' | 'high' | 'critical';
  links?: { label: string; href: string }[]; // deep links into other views
};
```

Every source projects into this shape via a SQL view or a backend mapper.

---

## 3. Layout

```
┌─────────────────────────────────────────────────────────────────────┐
│  Tenant chrome                                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Activity log                                          [Export]     │
│                                                                      │
│  ┌───────────────┬──────────────────────────────────────────────┐  │
│  │  FILTERS      │  TIMELINE                                     │  │
│  │               │                                               │  │
│  │  [Period ▼]   │  ── Today ──                                  │  │
│  │  [Category ▼] │                                               │  │
│  │  [Actor ▼]    │  09:47  🟢 proposal-builder completed        │  │
│  │  [Severity ▼] │         "Loopcatch proposal" (4.2s, £0.68)    │  │
│  │  [Search]     │                                               │  │
│  │               │  09:47  ⚪ fathom webhook received             │  │
│  │  Quick views: │         call_id fathom_xxx, session 12min    │  │
│  │  [Agent runs] │                                               │  │
│  │  [My actions] │  08:32  🔷 priya resolved escalation          │  │
│  │  [Escalations]│         "High-value proposal — Loopcatch"    │  │
│  │  [Integrations]│                                              │  │
│  │  [Secrets]    │  08:15  🟠 proposal-builder escalated          │  │
│  │               │         BUYER_SKEPTICISM — Loopcatch         │  │
│  │               │                                               │  │
│  │               │  04:00  ⚙️  librarian completed nightly sweep │  │
│  │               │         Indexed 17 files, archived 3         │  │
│  │               │                                               │  │
│  │               │  ── Yesterday ──                              │  │
│  │               │                                               │  │
│  │               │  ...                                          │  │
│  │               │                                               │  │
│  │               │  [Load more]                                  │  │
│  │               │                                               │  │
│  └───────────────┴──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

Mobile: filters become a drawer; timeline is full-width.

---

## 4. Timeline rendering

### 4.1 Entry structure

Each entry is one row with:
- **Time** — relative at small size, hover for exact
- **Icon** — colour + shape per severity/category (see §4.4)
- **Primary line** — actor + verb + subject (bold actor, regular verb)
- **Secondary line** — context details (duration, cost, file path, etc.)
- **Trailing links** — deep links when applicable (e.g., "View proposal →")

### 4.2 Day headers

Entries grouped by calendar day (tenant's timezone). Day headers separate groups:

```
── Today ──
── Yesterday ──
── Thursday, 22 April ──
── Wednesday, 21 April ──
```

### 4.3 Expandable entries

Clicking an entry expands it inline to show:
- Full metadata as a key-value list
- All available links
- "View full record" button (opens detail drawer with the raw database row + logs if available)

### 4.4 Icon legend

| Category | Colour | Icon |
|---|---|---|
| Agent run (success) | Emerald | `CheckCircle` |
| Agent run (failed) | Red | `XCircle` |
| Agent run (escalated) | Amber | `AlertTriangle` |
| Agent run (running) | Emerald pulse | `Loader` |
| Escalation raised | Amber | `AlertCircle` |
| Escalation resolved | Blue | `CheckSquare` |
| Integration added/reconnected | Emerald | `Plug` |
| Integration disabled | Neutral | `Unplug` |
| Secret rotated | Blue | `KeyRound` |
| Secret revoked | Red | `XSquare` |
| Config change | Blue | `Settings` |
| User action (sign-in) | Neutral | `User` |
| User action (destructive) | Amber | `ShieldAlert` |
| Webhook received | Neutral | `Webhook` |
| Platform deploy | Neutral | `Package` |

---

## 5. Filters

### 5.1 Quick views (presets)

One-click filters in the sidebar:

- **All activity** (default) — everything
- **Agent runs** — only `category=agent`
- **My actions** — only `actor.kind=user AND actor.identifier=currentUser`
- **Escalations** — `category=escalation`
- **Integrations** — `category=integration`
- **Secrets** — `category=secret`
- **Destructive actions** — `metadata.destructive=true` (spans categories)
- **This week** — `ts > now() - 7 days`

### 5.2 Filter controls

- **Period** — same dropdown as Operations view (today / this week / last 7 / last 30 / custom range)
- **Category** — multi-select checkboxes per category
- **Actor** — dropdown with agents + users that have activity in the current period
- **Severity** — multi-select (info / low / medium / high / critical)
- **Search** — free-text; searches `detail` field + subject

Filter state in URL query params for shareable links.

### 5.3 Active filter display

Above the timeline, current filters shown as chips: `[Category: agent, escalation] [Period: last 7 days]`. Click the `×` on any chip to remove.

---

## 6. Pagination

Cursor-based, infinite scroll. Initial load: 50 entries. Scroll to bottom → load next 50. Caps at 500 loaded in one session (beyond that, "Load more" button becomes manual).

URL updates with a `fromTs` param on scroll, so refreshing doesn't lose position.

---

## 7. Export

"Export" button top-right:

- **JSON** — full structured export (for programmatic consumers)
- **CSV** — flattened (for spreadsheets)
- **PDF** — prettified timeline (for client-facing "here's everything we did this month" reports)

Export respects current filters. Client-side export for < 1000 rows; server-side generation with signed URL for larger exports (time-bounded).

---

## 8. Differences — tenant vs operator view

### 8.1 Tenant context (`/t/[slug]/activity`)

- Shows their own tenant's events
- Events involving other tenants are not visible
- Some event types hidden (e.g., platform-level deploys that don't specifically affect them)
- Export available

### 8.2 Operator context (`/admin/ops/audit`)

- Can scope to a specific tenant OR see platform-wide
- Sees additional event types: cross-tenant deploys, impersonation events, internal role changes
- "Actor" filter includes all platform operators, not just those tied to a single tenant
- Export includes extra fields (IP addresses, user agents — present in audit log but hidden from tenant view)

### 8.3 Operator context (agency)

- `/agency/[slug]/activity` — shows activity across ALL sub-tenants of the agency, with tenant identifier as an extra column
- Agency admin can drill into any specific sub-tenant

---

## 9. Real-time

The timeline subscribes to a live stream (SSE) of new events. New events slide in at the top with a subtle highlight that fades over 3 seconds.

Backing procedure: `audit.stream({ tenantId, categories? })`. Uses same pattern as `escalations.stream`.

Users can disable real-time updates from a toggle in the sidebar ("Pause live updates" → subsequent activity queues until resumed).

---

## 10. Correlation

Every event includes a `correlationId` when applicable. Clicking this in the detail drawer surfaces all related events:

Example: a Fathom webhook received → triggered Proposal Builder → which escalated with BUYER_SKEPTICISM → which was resolved by priya. Four events, same correlation ID, visible together in "Related events" section of the detail drawer.

Correlation IDs are propagated through:
- Webhook receiver → tenant container invocation
- Agent invocation → escalation it raised
- Escalation → resolution action
- Provisioning workflow steps

---

## 11. Performance

| Target | Metric |
|---|---|
| Initial timeline load | < 600ms p95 |
| Filter change | < 400ms p95 |
| Infinite scroll (load next page) | < 300ms |
| SSE event latency (event → UI) | < 2s |
| Export < 1000 rows | Client-side instant |
| Export 10,000+ rows | Signed URL, < 30s generation |

Optimisations:
- `audit.list` uses a materialised view `ops.activity_timeline` (refreshed every minute) that pre-joins the event tables into the common shape. Queries hit an index on `(tenant_id, ts DESC)`.
- Entries beyond 90 days are lazy-fetched from archive storage (slower but rare access)

---

## 12. Retention

- Hot data (queryable via this view) — 90 days
- Archive (still queryable, slower) — 2 years
- Long-term audit log (for 7-year compliance) — S3 Object Lock, queryable via export only

---

## 13. What the audit log in `ops.audit_log` captures

Detailed spec in `auth-and-authorization-spec.md §11`. Summary:

Every mutation through tRPC, every auth event, every destructive action, every impersonation session. Retained 7 years.

This view surfaces the relevant subset — we don't show every `tRPC procedure call` event (far too noisy); we show the ones that correspond to business-meaningful actions.

---

## 14. Privacy considerations

For the tenant view:
- IP addresses never shown
- User agents never shown
- Operator impersonation sessions ARE shown to the tenant ("Support accessed your account at 15:30 — 12 minutes" with operator name)
- Secret values are never shown (only refs + metadata)

For the operator view:
- Everything in tenant view PLUS IPs, user agents, full metadata
- Operators are reminded: accessing customer data is logged; audit log of audit log access is visible to super-admin only

---

## 15. Accessibility

- Timeline uses `<ol>` with one `<li>` per entry; screen readers navigate naturally
- Day headers are `<h2>` with `aria-level="2"` within the list region
- New entries via SSE announced via `aria-live="polite"` with throttling (max 1 announcement per 5s)
- Every icon has `aria-label`; severity conveyed through text not colour alone
- Filter changes update `aria-live` region to announce the new result count

---

## 16. Implementation checklist (for CC17)

- [ ] Route `/t/[slug]/activity` + `/admin/ops/audit` + `/agency/[slug]/activity`
- [ ] `audit.list` and `audit.stream` tRPC procedures per router spec
- [ ] Materialised view `ops.activity_timeline` (add to Phase 3 schema as addendum migration)
- [ ] Event projection functions (one per source table)
- [ ] Timeline component with day grouping
- [ ] Infinite scroll with cursor pagination
- [ ] Quick-view preset buttons
- [ ] Filter UI with URL state
- [ ] Real-time event injection via SSE
- [ ] Correlation link surfacing in detail drawer
- [ ] Export (JSON/CSV client-side, PDF server-side)
- [ ] E2E tests: browse, filter, export, real-time injection
- [ ] Performance test: 10,000-row period query completes in budget

---

## 17. What's explicitly not here

- **A full audit of who viewed this view** — accessing audit logs is itself auditable, but that meta-audit is platform-admin-only (in a separate view we don't ship in v1)
- **Editing past records** — the log is append-only; no UI to modify historical events
- **Comments or annotations on events** — useful but deferred to v1.1

---

## 18. Related

- `auth-and-authorization-spec.md` — what's in the underlying audit log
- `api/trpc-router-spec.md` §5.11 (audit procedures)
- `phase-3-platform/postgres/schema-spec.md` — data sources
- Operations Control view — complementary ("what's happening now" vs this "what has happened")
