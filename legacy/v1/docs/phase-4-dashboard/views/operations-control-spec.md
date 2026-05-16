# Operations Control View Specification

**The primary daily-use view. Shows everything that's happening in a tenant's operations — invocations, escalations, costs — in one pane.**

> **Audience:** engineers building the view; operators and tenants who'll live in it.
>
> **Status:** v1.0. Lives at `/t/[tenantSlug]/operations` (tenant context) and `/admin/tenants/[tenantId]/operations` (operator context — same view, admin chrome).
>
> **Design goal:** a tenant owner opens this view once a day and gets everything they need in under 90 seconds. Operators glance at it multiple times an hour.

---

## 1. Purpose

This view answers four questions quickly:

1. What are my agents doing right now?
2. What needs my attention (escalations)?
3. What has cost me this month, and am I tracking to budget?
4. What just happened (last 24 hours)?

Nothing else. Each of those four questions gets its own module. No "everything everywhere" dashboard stuffed with graphs. Dense but curated.

---

## 2. Layout

Desktop (primary, `≥ 1024px`):

```
┌─────────────────────────────────────────────────────────────────────┐
│  Tenant chrome (nav, tenant switcher, search, user menu)            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Operations                                          [Period: ▼]    │
│                                                                      │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐    │
│  │ KPI TILE 1   │ KPI TILE 2   │ KPI TILE 3   │ KPI TILE 4   │    │
│  │ Open         │ Month spend  │ Invocations  │ Success rate │    │
│  │ escalations  │              │ this week    │              │    │
│  └──────────────┴──────────────┴──────────────┴──────────────┘    │
│                                                                      │
│  ┌────────────────────────────┬──────────────────────────────┐     │
│  │  Escalations               │  Running now (live)          │     │
│  │  (feed — scrollable)       │  (SSE-driven)                │     │
│  │                            │                              │     │
│  │  [escalation 1]            │  [Proposal Builder — 00:43]  │     │
│  │  [escalation 2]            │  [Content Creator — 01:12]   │     │
│  │  [...]                     │  [nothing else running]      │     │
│  │                            │                              │     │
│  │  [View all]                │                              │     │
│  └────────────────────────────┴──────────────────────────────┘     │
│                                                                      │
│  Recent invocations                                                 │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ TABLE: agent / trigger / started / duration / status / cost  │  │
│  │ [filterable, sortable, 20 rows with pagination]              │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  Costs this month                                                   │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  CHART: stacked daily cost (emerald + amber + blue)          │  │
│  │  Budget line (dotted)                                        │  │
│  │                                                              │  │
│  │  Per-agent breakdown: table + bar                            │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

Mobile (`< 1024px`): everything stacks vertically. Live ops module collapses into a badge; escalation feed becomes the primary content.

---

## 3. KPI tiles (top row)

Four tiles. All use `<CostTile>` / similar components from the design system.

### 3.1 Tile 1 — Open escalations

- Large number: count of escalations where `status IN ('open', 'acknowledged')`
- Colour: emerald if 0, amber if 1–4, red if ≥ 5
- Subtext: "↑ 2 since yesterday" or "↓ 1 since yesterday"
- Click: scroll to escalations feed

### 3.2 Tile 2 — Month spend

- Large number: `£{spent}` (e.g., `£243.12`)
- Secondary: `of £{budget}` (e.g., `of £550`)
- Progress bar: pct used
- Colour: emerald <70%, amber 70–90%, red >90% or over
- Subtext: estimated end-of-month projection "→ £510 at current pace"
- Click: scroll to costs module

### 3.3 Tile 3 — Invocations this week

- Large number: count of invocations in last 7 days
- Secondary: delta vs previous 7 days ("+12% vs last week")
- Subtext: "avg 34/day"
- Click: filter invocations table to last 7 days

### 3.4 Tile 4 — Success rate

- Large number: `{pct}%` (invocations with status `completed` out of total)
- Subtext: "12 escalated, 3 failed, 0 timed out" (specific breakdown)
- Click: filter invocations to non-completed

### 3.5 Period selector

Dropdown (default: current month) applies to all tiles simultaneously:
- This week
- This month (default)
- Last 30 days
- Last 90 days
- Custom range

Selection persists in URL query param (`?period=this_month`).

---

## 4. Escalations feed (left column)

### 4.1 What it shows

Vertical scrollable list of open + acknowledged escalations, newest first. Each item:

```
┌──────────────────────────────────────────────────┐
│ 🟠 MEDIUM  Lead Hunter                           │
│ ICP_CRITERIA_MISSING                             │
│ 3 minutes ago                                    │
│                                                  │
│ ICP file exists but only 2 of 5 required fields  │
│ are populated (geography and SIC codes; missing  │
│ size, tech signals, target roles).               │
│                                                  │
│ [View] [Resolve] [Won't fix]                     │
└──────────────────────────────────────────────────┘
```

Severity icon + colour (per design system §6.2):
- Critical → `AlertOctagon` + red
- High → `AlertTriangle` + red
- Medium → `AlertCircle` + amber
- Low → `Info` + blue
- Info → `Info` + neutral

### 4.2 Actions

- **View** — opens detail drawer (right-side sheet) showing full escalation note from `/outbox/escalations/...md`
- **Resolve** — modal: "What did you do?" textbox; on submit calls `escalations.resolve`; toast on success
- **Won't fix** — modal: "Why not fix?" textbox required; calls `escalations.wontFix`

### 4.3 Real-time

Subscribes to `escalations.stream` SSE endpoint. New escalations slide in from top with a 300ms animation. Resolved ones fade to the resolved tab (not visible in the default feed).

### 4.4 Filter

Header of the module has filter chips:
- Severity: all / critical+high / medium+ / low (default: all)
- Agent: dropdown to filter by agent

### 4.5 Empty state

"No open escalations. Your agents are healthy."

---

## 5. Running now (right column, smaller)

Shows invocations with `status='running'`. Expected to be mostly empty at any given moment (agents are short-lived). When an agent IS running, this gives the operator a live view.

Each row:
```
[Icon] Proposal Builder                 0:43
       Triggered by Fathom webhook
```

Timer increments every second. When the invocation completes, it fades out (status moves to recent invocations table below).

If nothing is running: subtle "No agents running right now" message.

Max 10 items visible; if more, summary ("5 more running").

---

## 6. Recent invocations (table)

Full invocations list with filters. Uses `<DataTable>` component.

### 6.1 Columns

| Column | Width | Content |
|---|---|---|
| Agent | 140px | `<AgentChip>` with icon + name |
| Trigger | 160px | e.g. "Fathom webhook", "Scheduled 09:00", "Chained from content-creator" |
| Started | 150px | Relative time ("3m ago") with exact on hover |
| Duration | 90px | `1.2s`, `4m 12s`, etc. |
| Status | 130px | `<InvocationStatusPill>` |
| Cost | 80px | £0.73 |
| Output | — | Link to primary output file (if any), otherwise em-dash |

Right-aligned action menu per row: "View details", "View logs", "Re-run (operator only)".

### 6.2 Filters

- Agent (multi-select)
- Status (multi-select)
- Date range (inherits period selector from top)
- Trigger type (dropdown: all / webhook / scheduled / manual / chained)

Filter state in URL query params.

### 6.3 Pagination

25 rows per page by default. Cursor-based.

### 6.4 Row click

Opens a detail drawer (right-side sheet):
- Full invocation metadata
- Links to output files (opens in Brain view)
- Inline log stream (Loki logs for this invocation, last 200 lines)
- Cost breakdown (anthropic / cohere / data providers)
- If escalated, link to the escalation

### 6.5 Empty state

"No invocations yet. Once a webhook or schedule triggers an agent, you'll see activity here."

---

## 7. Costs module

### 7.1 Daily stacked bar chart

X-axis: days of the selected period. Y-axis: cost in GBP.

Stacks: by provider (Anthropic, Cohere, data providers like Prospeo/Kaspr, other) — using the brand palette colours.

Overlay: a horizontal dotted line at `budget / days_in_period` (the straight-line daily target).

Hover: shows the exact breakdown for that day.

### 7.2 Per-agent breakdown

Sortable table below the chart:

| Agent | Invocations | Total cost | Avg cost | % of total |
|---|---|---|---|---|
| Proposal Builder | 12 | £8.47 | £0.71 | 34% |
| Content Creator | 5 | £6.23 | £1.25 | 25% |
| ... | | | | |

Horizontal bar chart next to the table showing the same data visually.

### 7.3 Budget status

Above the chart, a banner:

- **Under budget (<70%):** subtle emerald banner "On track: £243 of £550 used"
- **Approaching budget (70–90%):** amber banner "88% of budget used. Projected end-of-month: £520 (within budget)"
- **Exceeded:** red banner "Budget exceeded. £620 of £550. Consider raising budget or reviewing usage."

---

## 8. Differences between tenant and operator views

The underlying view is identical. Differences are in the chrome and permissions:

### 8.1 Tenant context (`/t/[slug]/operations`)

- Top nav shows tenant name prominently; tenant-scoped menu items
- Cost budget is shown but cannot be changed without owner role
- Re-running invocations is not available (read-only on historical runs)
- Viewing raw Loki logs is not available to tenant users

### 8.2 Operator context (`/admin/tenants/[tenantId]/operations`)

- Top nav shows admin chrome
- Additional module: "Provisioning history" (shows past provisioning workflows for this tenant)
- Re-running invocations available
- Loki logs available
- "Support actions" dropdown: impersonate, force restart supervisor, trigger reprovision

---

## 9. Performance considerations

### 9.1 Query strategy

- KPI tiles: four separate tRPC queries, each cached for 30s server-side, parallel
- Escalations feed: one query + one SSE subscription
- Running now: one SSE subscription
- Recent invocations: one query per page of results
- Costs module: one query for chart data, one for per-agent breakdown

Total initial load: ~6 parallel queries + 2 SSE subscriptions. Budget: < 500ms for server-side data aggregation.

### 9.2 Materialised views

Heavy queries use Postgres materialised views (refresh every 5 min):
- `control.costs_current_month` (per Phase 3 spec)
- `control.invocations_summary_24h` (NEW — add in a future migration)
- `control.invocations_weekly` (NEW)

Materialised views make KPI tiles near-instant at any tenant size.

### 9.3 Streaming

Page uses React Suspense boundaries so the shell renders immediately; each module streams in when its data resolves. LCP target: 1.5s on p75.

---

## 10. Keyboard shortcuts

| Shortcut | Action |
|---|---|
| `E` | Focus escalations feed |
| `R` | Focus recent invocations table |
| `C` | Focus costs module |
| `/` | Focus a search input (if present) |
| `J` / `K` | Down / Up in current list (escalations or invocations) |
| `Enter` | Open detail drawer for focused item |
| `Esc` | Close detail drawer |

Part of the broader dashboard shortcut map (see design-system §11).

---

## 11. Accessibility specifics

- KPI tiles are `<article>` with explicit `aria-label`
- Escalation feed uses `aria-live="polite"` so new items are announced
- Running-now timer uses `aria-live="off"` (announcing every second is noise)
- Every interactive element is keyboard-reachable
- Charts have an accessible table equivalent toggleable via "View as table" link

---

## 12. Testing

### 12.1 Unit tests

- Each module (KPIs, Escalations, Running, Invocations, Costs) as isolated components with mocked data
- Edge cases: 0 escalations, >100 invocations, budget exceeded, nothing running
- Filter state round-trips correctly with URL params

### 12.2 E2E tests

- Tenant visits view, sees their real data
- Escalation arrives via SSE, appears in feed without refresh
- Operator impersonates tenant; can re-run an invocation
- Filter by agent → table updates correctly

### 12.3 Visual regression

Playwright screenshots of the view in three states: empty, normal load, many-escalations. Detects unintended UI changes.

---

## 13. Implementation checklist (for CC15)

- [ ] Route `/t/[slug]/operations` set up
- [ ] Route `/admin/tenants/[tenantId]/operations` (same component, admin chrome)
- [ ] Four KPI tile components
- [ ] Escalations feed with SSE subscription
- [ ] Running-now live panel with SSE
- [ ] Invocations data table with filters, pagination, detail drawer
- [ ] Costs module (chart + table)
- [ ] Period selector propagating to all modules
- [ ] Empty states for every module
- [ ] Keyboard shortcuts
- [ ] Accessibility audit (Lighthouse + manual keyboard test)
- [ ] Performance budget met (LCP < 1.5s p75)
- [ ] E2E test suite per §12.2

---

## 14. Related

- `api/trpc-router-spec.md` — procedures consumed by this view
- `phase-3-platform/services/escalation-notifier-spec.md` — SSE endpoint details
- Design system spec — components used
- `intelforce-dashboard.jsx` — original prototype that hinted at this layout
