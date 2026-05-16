# Intel Force OS — Client Dashboard Design Plan
**For review before build. Do not write code until this is approved.**

> Created: 23 April 2026  
> Scope: Per-client portal accessible from intelforce.ai — full agent visibility, analytics, approval queue, and governance tools.

---

## 1. What We're Building

Every tenant onboarded through the wizard receives their own portal at:

```
app.intelforce.ai/t/[company-slug]
```

Examples:
- `app.intelforce.ai/t/elm-row-dental`
- `app.intelforce.ai/t/sterling-health`

The portal is the HR Lead's command centre. It shows everything their AI agent is doing, surfaces every pending decision requiring human approval, and provides full analytics and audit capability.

**The dashboard is already partially built** (`apps/dashboard/`). What this plan defines is the complete client-facing surface — the full navigation, all views, the design language, and how it feels to use it. This replaces the current placeholder page structure with a fully specified product.

---

## 2. Design System

### Extended from Phase 0 (intelforce-dashboard.jsx)

```
CANVAS ─────────────── #07090b   near-black, main background
SURFACE ────────────── #0d1014   cards, panels
SURFACE DEEP ──────── #080a0d   inset areas, inputs
BORDER ─────────────── #ffffff08  1px white/5 rings on cards
BORDER ACTIVE ──────── #10b981   emerald ring on selected/hover

ACCENT ─────────────── #10b981   emerald-400, primary action, live
ACCENT DIM ─────────── #10b98120  emerald/12, badge backgrounds
WARNING ────────────── #f59e0b   amber-400, pending, needs attention
WARNING DIM ────────── #f59e0b18  amber badges
CRITICAL ───────────── #ef4444   red-500, high sensitivity, urgent
CRITICAL DIM ──────── #ef444418  red badges
INFO ───────────────── #38bdf8   sky-400, scheduled, informational
MUTED ──────────────── #71717a   zinc-500, secondary text

TYPE DISPLAY ────────── Fraunces, serif, opsz 9–144, light/regular (headings)
TYPE BODY ───────────── Geist, sans-serif (all UI text)
TYPE MONO ───────────── JetBrains Mono (metrics, IDs, timestamps, code)

EFFECTS
  grain texture overlay (SVG fractalNoise, 0.4 opacity, mix-blend overlay)
  shimmer animation (emerald shimmer across card surfaces)
  pulse-dot (2s ease-in-out, for ACTIVE / LIVE indicators)
  flow-line (stroke-dasharray animated, for SVG hierarchy edges)
  backdrop-blur (8px, on sticky header + modals)
```

### New Components for This Build

| Component | Purpose | Visual |
|---|---|---|
| `<SensitivityBadge>` | severity pill on every query | CRITICAL/HIGH/MEDIUM/LOW rings |
| `<ApprovalCard>` | full-width pending-action unit | employee · query · draft · CTA |
| `<CommandPalette>` | ⌘K global search + nav | fullscreen overlay, emerald accent |
| `<SidebarNav>` | persistent left nav | 220px expanded / 56px collapsed |
| `<StatCard>` | KPI tile with sparkline | extends Phase 0 MetricCard |
| `<TimelineGroup>` | date-grouped activity | Today / Yesterday / This week |
| `<ChartPanel>` | analytics chart container | recharts inside Surface card |
| `<AgentStatusRow>` | table row for agent list | status dot · name · last run · output |

---

## 3. Shell Layout

Every page shares this layout:

```
┌────────────────────────────────────────────────────────────────────────────┐
│  [⌘] IntelForce.OS        [⌘K Search...]       Elm Row Dental  [🔔2] [JR] │  ← 56px top bar
├──────────────┬─────────────────────────────────────────────────────────────┤
│              │                                                              │
│  Overview    │                                                              │
│              │                                                              │
│  Approvals   │                                                              │
│  ·3·  ←badge │          MAIN CONTENT AREA                                  │
│              │                                                              │
│  Agents      │                                                              │
│              │                                                              │
│  Activity    │                                                              │
│              │                                                              │
│  Analytics   │                                                              │
│              │                                                              │
│  Knowledge   │                                                              │
│              │                                                              │
│  ──────────  │                                                              │
│              │                                                              │
│  Integrations│                                                              │
│              │                                                              │
│  Settings    │                                                              │
│              │                                                              │
│              │                                                              │
│  ──────────  │                                                              │
│  Growth plan │                                                              │
│  HR Agent v1 │                                                              │
│              │                                                              │
└──────────────┴─────────────────────────────────────────────────────────────┘
  220px sidebar                  fluid content area (min 900px)
```

**Top bar (56px, sticky, backdrop-blur):**
- Left: `[⌘]` logo + wordmark `IntelForce.OS`
- Centre: `⌘K` command palette trigger (search bar appearance)
- Right: tenant name + plan badge · notifications bell (badge) · user avatar

**Left sidebar (220px, always visible on ≥1280px, collapsible to 56px icon rail below):**
- `Overview` — LayoutDashboard icon
- `Approvals` — CheckCircle2 icon + amber badge with count
- `Agents` — Network icon
- `Activity` — ListTree icon
- `Analytics` — BarChart3 icon
- `Knowledge` — BookOpen icon
- [divider]
- `Integrations` — Puzzle icon
- `Settings` — Settings icon
- [bottom]
- Plan badge + agent version

**Active sidebar item:** left 2px emerald border + bg-emerald-400/8 + text-zinc-100

**Hover sidebar item:** bg-white/[0.02] + text-zinc-300

---

## 4. View Mockups

---

### VIEW 1: Overview  `/t/[slug]`

The daily landing page. HR Lead arrives here each morning.

```
┌────────────────────────────────────────────────────────────────────────┐
│  •  LIVE · 8s ago                                                       │
│                                                                         │
│  Good morning, Jordan.                    [▷ Review pending]  [⚡ Run]  │
│  Elm Row Dental · Edinburgh · Growth plan                               │
│                                                                         │
├──────────────┬──────────────┬──────────────┬───────────────────────────┤
│ Handled MTD  │ Pending       │ Escalated     │ Cost MTD                  │
│              │ approval      │              │                           │
│  247         │  3            │  1            │  £18.40                  │
│  +24%        │  ↑ 2 new      │  urgent       │  vs £22 budget           │
│  ▁▃▅▆▇▇▇▇  │               │               │  ▁▂▃▄▄▅▅▅               │
├──────────────┴──────────────┴──────────────┴───────────────────────────┤
│                                                                         │
│  PENDING APPROVALS                              [ View all (3) → ]      │
│  ─────────────────────────────────────────────────────────────────     │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  ● HIGH  │ Jane D. — Annual Leave Query          4m ago          │   │
│  │  ─────────────────────────────────────────────────────────────  │   │
│  │  "Do I have any remaining holiday this year?"                    │   │
│  │  Draft: "Based on your entitlement of 25 days and 18 taken..."  │   │
│  │                                              [Edit]  [Approve ✓] │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  ● MEDIUM │ Marcus T. — Sick Leave Policy         22m ago        │   │
│  │  Draft: "The company sick pay policy provides full pay for..."   │   │
│  │                                              [Edit]  [Approve ✓] │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  RECENT ACTIVITY                                                        │
│  ─────────────────────────────────────────────────────────────────     │
│  ✓  4m    Proposal sent to Jordan for approval — Jane D. holiday query  │
│  ✓  22m   Handbook lookup — sick leave entitlement                      │
│  ✓  1h    Employee info retrieved — Marcus T. (Breathe HR)              │
│  ✓  3h    Weekly HR report delivered to #hr-updates                    │
│  ✓  5h    Escalation resolved — Sarah K. grievance → HR Lead           │
│                                                                         │
│  SYSTEM STATUS                                                          │
│  ─────────────────────────────────────────────────────────────────     │
│  ● Teams bot      ACTIVE · last msg 4m ago                             │
│  ● Breathe HR     SYNCED · 34 employees · last sync 12m ago            │
│  ● Agent          ONLINE · claude-sonnet-4-6 · p50 latency 1.8s       │
└────────────────────────────────────────────────────────────────────────┘
```

**Design notes:**
- Greeting uses Fraunces display, 42px font-light
- KPI tiles are Phase 0 MetricCard components, sparkline at bottom
- Pending approval cards use amber-400 ring for HIGH, zinc for MEDIUM
- Only shows top 2 pending items — "View all" links to Approvals
- System status strip at bottom = persistent health check

---

### VIEW 2: Approvals Queue  `/t/[slug]/approvals`

**The most important view in the entire product.** This is where the "everything drafts, nothing sends without approval" principle is visible. Every drafted HR reply waits here.

```
┌────────────────────────────────────────────────────────────────────────┐
│  Approvals                                                              │
│  3 pending · 1 critical · sorted by age                                 │
│                                                             [Filter ▾] │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  CRITICAL · Sensitivity 0.91                           8m ago    │  │
│  │  ┌──────────────────────────────────────────────────────────┐   │  │
│  │  │ Employee     Jane D. (redacted)   Dept  Operations        │   │  │
│  │  │ Channel      #hr-queries          Query type  Grievance   │   │  │
│  │  └──────────────────────────────────────────────────────────┘   │  │
│  │                                                                  │  │
│  │  QUERY ──────────────────────────────────────────────────────   │  │
│  │  "I have a formal complaint about my line manager's behaviour    │  │
│  │   during last week's review. What are my rights?"               │  │
│  │                                                                  │  │
│  │  DRAFT ──────────────────────────────────────────────────────   │  │
│  │  "Thank you for raising this. The company's grievance procedure  │  │
│  │   gives you the right to raise a formal complaint in writing to  │  │
│  │   HR. A formal investigation will be opened within 5 working    │  │
│  │   days. I'd like to arrange a confidential call — does Friday   │  │
│  │   at 2pm work for you?"                                         │  │
│  │                                                                  │  │
│  │  HANDBOOK SOURCES ────────────────────────────────────────────  │  │
│  │  §4.3 Grievance Procedure · §4.4 Investigation Timeline        │  │
│  │                                                                  │  │
│  │  [Reject ✗]  [Edit draft ✎]  [Escalate ↑]  [Approve & Send ✓] │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  HIGH · Sensitivity 0.74                              4m ago     │  │
│  │  ┌──────────────────────────────────────────────────────────┐   │  │
│  │  │ Employee     Jane D. (redacted)   Dept  Ops               │   │  │
│  │  │ Channel      #hr-queries          Query type  Leave        │   │  │
│  │  └──────────────────────────────────────────────────────────┘   │  │
│  │                                                                  │  │
│  │  QUERY ──────────────────────────────────────────────────────   │  │
│  │  "Do I have any remaining annual leave for this year?"          │  │
│  │                                                                  │  │
│  │  DRAFT ──────────────────────────────────────────────────────   │  │
│  │  "Based on your 25-day entitlement and 18 days taken to date,   │  │
│  │   you have 7 days remaining. Note: the company's carry-forward  │  │
│  │   policy allows up to 5 days into the next holiday year..."     │  │
│  │                                                                  │  │
│  │  EMPLOYEE DATA (Breathe HR) ──────────────────────────────────  │  │
│  │  Entitlement 25d · Taken 18d · Remaining 7d · Carry-fwd 5d max │  │
│  │                                                                  │  │
│  │  [Reject ✗]  [Edit draft ✎]  [Escalate ↑]  [Approve & Send ✓] │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  MEDIUM · Sensitivity 0.48                            22m ago    │  │
│  │  Marcus T. · Sick Leave Policy · shorter card...                 │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ─── RESOLVED TODAY (12) ────────────────────────────────── [show] ─── │
└────────────────────────────────────────────────────────────────────────┘
```

**Design notes:**
- Cards sorted: CRITICAL first, then by age
- CRITICAL cards: red/4 ring + left 3px red border
- HIGH cards: amber/30 ring
- MEDIUM: zinc ring
- Sensitivity score shown as decimal (0.91) in monospace
- Employee name always redacted to first name + initial (PII protection, visible in UI)
- "HANDBOOK SOURCES" strip shows which policy sections the draft cited — builds trust
- "EMPLOYEE DATA" strip shows the Breathe HR pull that informed the draft
- Edit draft opens inline editor — same card expands, text becomes editable textarea
- "Resolve Today" collapsed section at bottom shows approved/rejected items
- Approve button: bg-emerald-400 text-emerald-950 font-semibold (primary CTA)
- Reject/Escalate: text-zinc buttons with ring

---

### VIEW 3: Agents  `/t/[slug]/agents`

Adapted from Phase 0 hierarchy. Shows the HR agent stack visually.

```
┌────────────────────────────────────────────────────────────────────────┐
│  Agentic Hierarchy  · 5 agents configured · last activity 4m ago       │
│  ○ Gateway  ○ Director  ○ Sub-agent  ○ Human node      [Export JSON]   │
├────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  GATEWAYS                ORCHESTRATOR           HR AGENT STACK          │
│                                                                         │
│  ┌──────────────┐                              ┌───────────────────┐   │
│  │ 💬 MS Teams  │  ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ │ ◉ Policy Lookup   │   │
│  │  ACTIVE      │         ┌──────────┐    ┌──▶│  ACTIVE  2m ago   │   │
│  └──────────────┘  ──────▶│          │    │   └───────────────────┘   │
│                            │ Intel    │────┤                           │
│  ┌──────────────┐  ──────▶│ Force OS │    │   ┌───────────────────┐   │
│  │ 👥 Breathe HR│         │ Gateway  │    ├──▶│ ◉ Employee Info   │   │
│  │  SYNCED      │         └──────────┘    │   │  ACTIVE  3m ago   │   │
│  └──────────────┘                         │   └───────────────────┘   │
│                                            │                           │
│                                            │   ┌───────────────────┐  │
│                                            ├──▶│ ◎ Draft Composer  │  │
│                                            │   │  RUNNING  now     │  │
│                                            │   └───────────────────┘  │
│                                            │                           │
│                                            │   ┌───────────────────┐  │
│                                            ├──▶│ ◎ Approval Router │  │
│                                            │   │  ACTIVE  1m ago   │  │
│                                            │   └───────────────────┘  │
│                                            │                           │
│                                            │   ┌───────────────────┐  │
│                                            └──▶│ ◑ Weekly Reporter │  │
│                                                │  SCHEDULED  Fri7am│  │
│                                                └───────────────────┘  │
│                                                                         │
│                                       Human Approval ────────────────  │
│                                       Jordan R. · HR Lead              │
│                                       3 pending · avg 14m response     │
│                                                                         │
├────────────────────────────────────────────────────────────────────────┤
│  Agent details pane (click any agent to open)                           │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  ◉ RUNNING      Draft Composer                     claude-s-4.6 │   │
│  │  ─────────────────────────────────────────────────────────────  │   │
│  │  Writes HR reply drafts from Claude with handbook + employee    │   │
│  │  context. Calls lookup_handbook_policy and get_employee_info    │   │
│  │  then submit_draft_for_approval.                                │   │
│  │                                                                  │   │
│  │  Connected to:  ● Policy Lookup  ● Employee Info  ● Approval Router  │
│  │  Recent:  Draft for Jane D. holiday query — 4m ago              │   │
│  │           Draft for Marcus T. sick leave — 22m ago              │   │
│  │                                                                  │   │
│  │  Model: claude-sonnet-4-6  ·  p50 1.8s  ·  cost £0.003/query   │   │
│  │                                                                  │   │
│  │                         [Configure ⚙]  [View logs ↗]           │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────┘
```

**Design notes:**
- Full SVG canvas (same technique as Phase 0) — animated flow-line edges
- Gateways pulse when receiving messages (real-time via SSE)
- HR sub-agents on right — click to expand detail pane below
- Human approval node rendered differently — amber ring, person icon, shows pending count
- Detail pane appears below graph (not modal) — keeps hierarchy visible
- Status colours: ACTIVE = emerald pulse, RUNNING = amber pulse, SCHEDULED = sky, IDLE = zinc
- "configure" links to Settings › Agent Config panel

---

### VIEW 4: Activity  `/t/[slug]/activity`

Chronological log of everything the agent did. Already partially built.

```
┌────────────────────────────────────────────────────────────────────────┐
│  Activity Log                                                           │
│  All events · 8 sources · live auto-refresh                            │
│                                                                         │
│  [All types ▾]  [All agents ▾]  [Date range ▾]  [Search...]  [CSV ↓]  │
│                                                                         │
│  TODAY — Thursday 23 April                                              │
│  ──────────────────────────────────────────────────────────────────     │
│                                                                         │
│  09:14  ◈ DRAFT CREATED      Draft Composer                            │
│         Jane D. — Annual leave query — sent for approval                │
│         Sensitivity 0.74 · 2 handbook sections cited                   │
│                                                                         │
│  09:10  ◈ TOOL CALL          Policy Lookup                             │
│         Query: "annual leave carry forward policy"                      │
│         Found: §3.2 Holiday Entitlement, §3.5 Carry-forward Rules      │
│                                                                         │
│  09:10  ◈ TOOL CALL          Employee Info                             │
│         Breathe HR lookup: employee ref #A2841 (redacted)              │
│         Entitlement 25d · Taken 18d · Remaining 7d                     │
│                                                                         │
│  09:09  ◈ MESSAGE RECEIVED   Teams Gateway                             │
│         Channel: #hr-queries · employee query received                  │
│                                                                         │
│  08:47  ✓ APPROVAL SENT      Approval Router                           │
│         Marcus T. sick leave draft — approved by Jordan R.             │
│         Response delivered via Teams                                    │
│                                                                         │
│  07:02  ◎ REPORT DELIVERED   Weekly Reporter                           │
│         Weekly HR intelligence report — 34 employees · 28 queries MTD  │
│         Delivered to #hr-updates                                        │
│                                                                         │
│  YESTERDAY — Wednesday 22 April                                         │
│  ──────────────────────────────────────────────────────────────────     │
│                                                                         │
│  16:33  ↑ ESCALATION         Escalation Handler                        │
│         Sarah K. — Grievance query · sensitivity 0.89                  │
│         Routed to HR Lead direct message                                │
│                                                                         │
│  ·  ·  ·  24 more events yesterday  ·  ·  ·                            │
│                                                                         │
│  THIS WEEK                                                              │
│  ──────────────────────────────────────────────────────────────────     │
│  Monday · 18 events  ·  Tuesday · 11 events  ·  Wednesday · 25 events  │
└────────────────────────────────────────────────────────────────────────┘
```

**Design notes:**
- TimelineGroup component: date header in zinc-500, 10px tracking-wider uppercase
- Event rows: icon (◈ tool call, ✓ approval, ↑ escalation, ◎ scheduled) + bold action label + description
- Sensitivity scores inline, monospace
- Employee names always redacted
- Filters row: pill-style dropdowns matching Phase 0 button style
- CSV export calls `trpc.audit.export`
- Clicking any row expands full invocation detail (same tRPC data as Operations Control)

---

### VIEW 5: Analytics  `/t/[slug]/analytics`

```
┌────────────────────────────────────────────────────────────────────────┐
│  Analytics                                                              │
│  April 2026 · 28-day view                                [Period ▾]    │
│                                                                         │
│  ┌──────────────┬──────────────┬──────────────┬───────────────────┐   │
│  │ Queries MTD  │ Approval rate│ Avg response  │ Cost MTD          │   │
│  │              │              │               │                   │   │
│  │  247         │  94.3%       │  1.8s         │  £18.40          │   │
│  │  +24% vs Mar │  (7 edited)  │  p50 latency  │  £3.60 under bdg  │   │
│  │  ▁▃▅▆▇▇▇▇  │  ▂▅▇▇▇▆▇▇  │  ▆▅▆▄▅▆▅▆    │  ▁▂▃▄▄▅▅▅        │   │
│  └──────────────┴──────────────┴──────────────┴───────────────────┘   │
│                                                                         │
│  ┌──────────────────────────────────┬───────────────────────────────┐  │
│  │  QUERY VOLUME (28 days)           │  SENSITIVITY DISTRIBUTION     │  │
│  │                                   │                               │  │
│  │  15 ┤       ╭─╮                  │   LOW        ████░░░░  41%   │  │
│  │  10 ┤   ╭───╯ ╰─╮               │   MEDIUM     █████░░░  47%   │  │
│  │   5 ┤───╯       ╰───────────    │   HIGH       ██░░░░░░   9%   │  │
│  │   0 ┴────────────────────────   │   CRITICAL   █░░░░░░░   3%   │  │
│  │     Mar 27           Apr 23      │                               │  │
│  └──────────────────────────────────┴───────────────────────────────┘  │
│                                                                         │
│  ┌──────────────────────────────────┬───────────────────────────────┐  │
│  │  APPROVAL OUTCOMES               │  QUERY CATEGORIES             │  │
│  │                                   │                               │  │
│  │         ┌─────────────────┐       │  Leave & Holiday     ██████  │  │
│  │    approved  ████  88.3%  │       │  Sick Leave          ████    │  │
│  │    edited    ██     7.3%  │       │  Policy Lookup       ████    │  │
│  │    rejected  █      2.0%  │       │  Grievance           ██      │  │
│  │    escalated █      2.4%  │       │  Pay & Benefits      ██      │  │
│  │                            │       │  Onboarding          █       │  │
│  └──────────────────────────────────┴───────────────────────────────┘  │
│                                                                         │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │  COST BREAKDOWN (April)                           [Breakdown ▾] │    │
│  │                                                                  │    │
│  │  ·········  £22.00  budget                                      │    │
│  │  ━━━━━━━━   £18.40  actual (18 days)                            │    │
│  │                                                                  │    │
│  │  Projection: £24.30 at current rate · £2.30 over budget        │    │
│  │                                                                  │    │
│  │  Per query:  £0.074 avg  ·  Anthropic API: £14.20  ·  Infra: £4.20 │  │
│  └────────────────────────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────────────────┘
```

**Design notes:**
- KPI tiles reuse Phase 0 MetricCard component
- Charts: `recharts` (already industry standard for React, no Tailwind conflicts)
- Volume chart: `<AreaChart>` with emerald fill
- Sensitivity: `<BarChart>` horizontal with colour-coded fills (emerald/amber/red)
- Approval outcomes: `<PieChart>` with custom tooltip
- Query categories: horizontal `<BarChart>`
- Cost section: dual-line chart (budget vs actual) + projection in amber if over
- All chart panels use Surface card bg + ring-white/5

---

### VIEW 6: Knowledge  `/t/[slug]/knowledge`

Where the HR Lead manages what the agent knows.

```
┌────────────────────────────────────────────────────────────────────────┐
│  Knowledge Base                                                         │
│  What your HR agent knows · Handbook + employee context               │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  COMPANY HANDBOOK                                                  │  │
│  │  ──────────────────────────────────────────────────────────────  │  │
│  │                                                                    │  │
│  │  Current version:  Elm_Row_Dental_HR_Handbook_2025.pdf            │  │
│  │  Uploaded:         14 March 2026 · by Jordan R.                   │  │
│  │  Size:             2.4 MB · 48 pages                              │  │
│  │  Policy sections:  §1–§9 detected                                 │  │
│  │                                                                    │  │
│  │  HEALTH ──────────────────────────────────────────────────────   │  │
│  │  ● Leave & Holiday          ████████████  GOOD                   │  │
│  │  ● Sick Leave               ████████████  GOOD                   │  │
│  │  ● Grievance Procedure      ████████████  GOOD                   │  │
│  │  ● Pay & Benefits           ████████░░░░  PARTIAL (§7 thin)      │  │
│  │  ● Disciplinary             ████████████  GOOD                   │  │
│  │                                                                    │  │
│  │  [Upload new version]  [Download current]  [View policy index]   │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  LIVE EMPLOYEE DATA (Breathe HR)                                   │  │
│  │  ──────────────────────────────────────────────────────────────  │  │
│  │                                                                    │  │
│  │  34 employees synced  ·  Last sync 12 minutes ago  ·  Auto every 4h │  │
│  │                                                                    │  │
│  │  Leave data availability:    ████████████  100%                   │  │
│  │  Department mapping:         ████████████  100%                   │  │
│  │  Absence history (90d):      ████████████  100%                   │  │
│  │                                                                    │  │
│  │  [Force sync]  [View integration settings →]                      │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  BRAIN / SEMANTIC VAULT                                ○ LOCKED   │  │
│  │  ──────────────────────────────────────────────────────────────  │  │
│  │  Semantic search across handbook + past decisions.               │  │
│  │  Requires Growth plan + pgvector database.                       │  │
│  │                                                                    │  │
│  │  You're on Growth plan ✓ · Enable Brain to unlock                │  │
│  │                              [Enable Brain →]                     │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

**Design notes:**
- Handbook upload card: dropzone when no file uploaded; metadata + health when file exists
- Health bars: colour-coded (emerald = good, amber = partial, red = thin/missing)
- "Policy sections detected" — runs a quick scan on upload, reports section coverage
- Breathe HR sync status: live check via `trpc.integrations.testConnection`
- Brain card: shows as LOCKED with soft emerald CTA when not enabled
- Upload calls `trpc.tenants.update` (sets handbookKvKey) + KV write

---

### VIEW 7: Integrations  `/t/[slug]/integrations`

```
┌────────────────────────────────────────────────────────────────────────┐
│  Integrations                                                           │
│  2 connected · 4 available                                              │
│                                                                         │
│  CONNECTED                                                              │
│  ─────────────────────────────────────────────────────────────────     │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  💬 Microsoft Teams                              ● ACTIVE        │  │
│  │  ──────────────────────────────────────────────────────────────  │  │
│  │  Bot registered · Elm Row Dental workspace                       │  │
│  │  Channels: #hr-queries (primary) · #hr-updates (reports)        │  │
│  │  Last message: 4 minutes ago                                     │  │
│  │                                                [Test] [Settings] │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  👥 Breathe HR                                   ● ACTIVE        │  │
│  │  ──────────────────────────────────────────────────────────────  │  │
│  │  API key: bre_live_[REDACTED]                                    │  │
│  │  34 employees · 3 departments                                    │  │
│  │  Syncs every 4h · Last sync 12m ago                              │  │
│  │                                                [Test] [Rotate key]│  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  AVAILABLE                                                              │
│  ─────────────────────────────────────────────────────────────────     │
│                                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌───────────┐  │
│  │  📧 Slack     │  │  📅 Google   │  │  📊 HiBob    │  │  + More   │  │
│  │              │  │  Calendar    │  │              │  │           │  │
│  │  Report      │  │              │  │  Alternative │  │ Coming    │  │
│  │  delivery    │  │  OOO aware   │  │  to Breathe  │  │ soon      │  │
│  │  [Connect]   │  │  [Connect]   │  │  [Connect]   │  │           │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  └───────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

**Design notes:**
- Connected cards: full-width, emerald status pill, test + settings actions
- Available cards: 2-col grid, lighter styling, [Connect] CTA
- "Rotate key" → `trpc.secrets.rotate` with confirmation modal
- "Test" → `trpc.integrations.testConnection` inline result
- API keys always displayed as masked (bre_live_[REDACTED])

---

### VIEW 8: Settings  `/t/[slug]/settings`

Already fully built (7 panels). Navigation stays the same.
Panels: Configuration · Team · Integrations · Secrets · Billing · API Keys · Notifications

The only change from what's built: **add the left sidebar nav** wrapping these pages so they feel continuous with the rest of the portal.

---

## 5. Command Palette (`⌘K`)

A global command palette accessible from any view. Essential for power users.

```
┌────────────────────────────────────────────────────────────────────────┐
│  ████████████████████████████████████████████████████████████████████  │
│  █                                                                    █  │
│  █  ┌──────────────────────────────────────────────────────────────┐  █  │
│  █  │ ⌘  Search or type a command...                               │  █  │
│  █  └──────────────────────────────────────────────────────────────┘  █  │
│  █                                                                    █  │
│  █  NAVIGATION                                                        █  │
│  █  → Overview                        ⌘1                             █  │
│  █  → Approvals (3 pending)           ⌘2                             █  │
│  █  → Agents                          ⌘3                             █  │
│  █  → Activity                        ⌘4                             █  │
│  █  → Analytics                       ⌘5                             █  │
│  █                                                                    █  │
│  █  ACTIONS                                                           █  │
│  █  ⚡ Approve all low-sensitivity drafts                             █  │
│  █  ↑  Escalate to backup HR lead                                    █  │
│  █  📤 Export audit log (CSV)                                         █  │
│  █  🔄 Force Breathe HR sync                                          █  │
│  █  📤 Upload new handbook                                            █  │
│  █                                                                    █  │
│  █  RECENT                                                            █  │
│  █  Jane D. — leave query (4m ago)                                   █  │
│  █  Marcus T. — sick leave (22m ago)                                  █  │
│  ████████████████████████████████████████████████████████████████████  │
└────────────────────────────────────────────────────────────────────────┘
```

**Implementation:** `cmdk` package (from shadcn/ui). Styled with Phase 0 tokens. Opens with `⌘K`, closes on `Escape` or outside click.

---

## 6. Per-Client Portal Access Model

```
Wizard completes
      │
      ▼
Temporal workflow creates tenant
      │
      ├─► Creates Clerk organisation (orgId = tenantId)
      ├─► Provisions Postgres schema
      └─► Sends invite email to hrLeadEmail
               │
               ▼
         HR Lead receives: "Your Intel Force OS dashboard is ready"
         Link: app.intelforce.ai/t/elm-row-dental
               │
               ▼
         Creates Clerk account (or signs in)
         → Auto-joined to org via Clerk invitation
               │
               ▼
         Lands on Overview page
         Their tenant slug = URL segment
               │
               ▼
         Can invite team members via Settings → Team
         Role options: hr_lead (full access), viewer (read-only)
```

**URL structure:**
```
app.intelforce.ai/                    → redirect to first tenant or sign-in
app.intelforce.ai/sign-in             → Clerk hosted sign-in
app.intelforce.ai/t/[slug]            → Overview
app.intelforce.ai/t/[slug]/approvals  → Approval Queue
app.intelforce.ai/t/[slug]/agents     → Agent Hierarchy
app.intelforce.ai/t/[slug]/activity   → Activity Log
app.intelforce.ai/t/[slug]/analytics  → Analytics
app.intelforce.ai/t/[slug]/knowledge  → Knowledge Base
app.intelforce.ai/t/[slug]/integrations → Integrations
app.intelforce.ai/t/[slug]/settings   → Settings

app.intelforce.ai/agency/[slug]       → Agency partner portal
app.intelforce.ai/admin               → Platform admin (tarsclaw only)
```

**Deployment target:** The `apps/dashboard` Next.js app deploys to Vercel (or Hetzner as per Phase 3 spec). Domain: `app.intelforce.ai` (CNAME to deploy target).

The intelforce.ai marketing site links to `app.intelforce.ai` for sign-in/access. The portals are not embedded in the marketing site — they're a separate Next.js app.

---

## 7. Recommended Packages to Add

| Package | Purpose | Already in? |
|---|---|---|
| `recharts` | Analytics charts (AreaChart, BarChart, PieChart) | No — add |
| `cmdk` | Command palette (`⌘K`) | No — add via shadcn/ui |
| `framer-motion` | SVG hierarchy animations, page transitions | No — add |
| `nuqs` | URL state for filters (date range, sensitivity level) | No — add |
| `@vercel/analytics` | Page-level analytics for our own visibility | No — add |
| `react-dropzone` | Handbook file upload zone | No — add |

All are production-stable, zero conflicts with Tailwind v4 + shadcn/ui.

**Do NOT add:** D3 (recharts handles everything we need), Framer (full Framer platform), Chart.js (recharts is better for React).

---

## 8. Claude Code Plugin Install

Install the official frontend-design plugin before building the UI:

```bash
claude mcp add --scope project frontend-design \
  "https://raw.githubusercontent.com/anthropics/claude-code/main/plugins/frontend-design/MANIFEST.json"
```

This gives Claude Code access to:
- Design critique skill (reviews components against your design system)
- Aesthetic iteration skill (refines colour, spacing, typography on request)
- Pattern library (accessible interactive components)

Use it during build by running `/frontend-design` before each major component.

---

## 9. Build Roadmap (After Approval)

This assumes the plan is approved as-is. Build in this order — each step is independently shippable.

### Phase A — Shell + Navigation (1 session)
1. Add `<SidebarNav>` component wrapping all `/t/[slug]/*` routes
2. Update shell layout in `app/t/[slug]/layout.tsx` — sidebar + top bar
3. Wire notifications bell to `trpc.escalations.listGlobal` (badge count)
4. Add `cmdk` command palette component
5. Add `Fraunces` font to `app/layout.tsx`

**Deliverable:** Every existing page now has the correct nav shell.

### Phase B — Overview Page (1 session)
1. Rewrite `app/t/[slug]/page.tsx` with the Overview layout
2. KPI tiles: real data from `trpc.invocations.list` + `trpc.costs.currentMonth` + `trpc.escalations.list`
3. Mini approval queue (top 2 pending) from `trpc.escalations.list { status: OPEN }`
4. Recent activity feed: last 5 events from `trpc.audit.list`
5. System status strip: Teams + Breathe HR ping via `trpc.integrations.testConnection`

**Deliverable:** Overview page is live with real data.

### Phase C — Approvals Queue (1 session)
1. Create `app/t/[slug]/approvals/page.tsx`
2. `<ApprovalCard>` component with full layout from mockup
3. Sensitivity badge component
4. Approve / Edit / Reject / Escalate actions wired to existing bot API
5. "Resolved today" collapsed section

**Deliverable:** HR Lead can manage approvals from the web portal (mirrors Teams card actions).

### Phase D — Analytics (1 session)
1. Create `app/t/[slug]/analytics/page.tsx`
2. Install `recharts`
3. Volume chart, sensitivity donut, approval outcomes pie, query categories bar
4. Cost breakdown panel with projection

**Deliverable:** Full analytics view.

### Phase E — Knowledge + Agents (1 session)
1. Create `app/t/[slug]/knowledge/page.tsx` — handbook upload + Breathe HR status
2. Rewrite `app/t/[slug]/agents/page.tsx` (currently placeholder) with SVG hierarchy
3. Agent detail panel below hierarchy
4. Wire handbook upload to KV via `trpc.tenants.update`

**Deliverable:** Knowledge and Agents views live.

### Phase F — Polish Pass (1 session)
1. Add `framer-motion` page transitions
2. Grain texture on SVG hierarchy
3. Flow-line animations on agent hierarchy edges
4. Mobile responsive (sidebar collapses at <1280px)
5. `nuqs` for filter state in Activity and Analytics

**Deliverable:** Dashboard feels premium, matches Phase 0 aesthetic bar.

---

## 10. What Is NOT Changing

- The `apps/dashboard` tech stack (Next.js 15, tRPC, Clerk, Prisma) — stays exactly as built
- The 13 tRPC routers — no new procedures needed for Phase A–D
- The Teams HR Agent Worker (`src/`) — dashboard only reads from the same D1/Postgres database
- The onboarding wizard — already at `/t/[slug]/wizard/` and working
- The Settings panels — already fully wired, just get the sidebar wrapper

---

## Decision Needed Before Build

1. **app.intelforce.ai vs dashboard.intelforce.ai** — which subdomain?
2. **Approvals from web portal**: when the HR Lead approves on the web, it needs to also send the Teams reply. The existing `handleCardAction` in `src/bot/handler.ts` handles Teams card presses. For web approval, we'd call the same Worker endpoint via a new `POST /api/approve` route. Confirm this approach before Phase C.
3. **Analytics period**: start with 28-day rolling window or calendar month? (Calendar month shown in mockup.)
4. **Mobile**: bottom tab bar or collapsed sidebar icons for <768px?

---

*Plan complete. No code written. Awaiting approval to proceed with Phase A — Shell + Navigation.*
