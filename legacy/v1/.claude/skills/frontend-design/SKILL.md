---
name: frontend-design
description: Premium frontend design for Intel Force OS dashboard. Apply when building, reviewing, or improving any UI component or page. Covers design system tokens, component patterns, what separates top-1% SaaS dashboards from average ones, and Intel Force OS aesthetic rules.
---

# Intel Force OS — Frontend Design Skill

**Aesthetic direction:** Dark luxury / editorial. Operates at the intersection of a premium SaaS tool (Linear, Vercel) and an editorial publication (Monocle, The FT). Every decision must be *earned* — if a visual element doesn't serve information hierarchy or navigation, remove it.

---

## The Top-1% Benchmark

What separates the best SaaS dashboards (Linear, Vercel, Raycast, Stripe) from the average:

| Average | Top 1% |
|---|---|
| Rounded cards everywhere, same size | Intentional elevation — deep/surface/raised creates depth |
| Color for decoration | Color only on elements that need attention (red = critical, amber = pending) |
| Inter/system font, 16px | Distinctive display font + tight body, aggressive size contrast |
| Placeholder charts | Real data, real charts, clear axis labels |
| Generic hover: `opacity: 0.8` | Hover reveals affordances: actions appear, borders shift colour |
| Empty states: "No data yet" | Empty states with context: why it's empty + what to do |
| Loading: spinner | Loading: skeleton with shimmer that matches layout |
| Mobile: responsive table | Mobile: purpose-built layout (bottom tab bar, stacked cards) |
| Notifications: bell with number | Notifications: contextual, actionable, grouped by urgency |

---

## Design Tokens (canonical — do not deviate)

```css
/* Backgrounds — dark-to-darker scale */
--canvas:   7 9 11      /* #07090b — page background */
--surface:  13 16 20    /* #0d1014 — primary cards */
--deep:     8 10 13     /* #080a0d — inset wells, inputs, code blocks */
--raised:   20 24 28    /* #14181c — hover state, elevated panels */

/* Semantic colours — use by role, not by preference */
--emerald:  16 185 129  /* #10b981 — ACTIVE, success, primary CTA */
--amber:    245 158 11  /* #f59e0b — PENDING, warning, needs attention */
--red:      239 68 68   /* #ef4444 — CRITICAL, error, destructive */
--sky:      56 189 248  /* #38bdf8 — SCHEDULED, informational */
--purple:   139 92 246  /* #8b5cf6 — Director nodes, secondary accent */

/* Text — three levels, used hierarchically */
--text:     250 250 250 /* Primary: headings, values, important labels */
--text-sec: 161 161 170 /* Secondary: body copy, descriptions */
--text-mut: 113 113 122 /* Muted: metadata, timestamps, placeholders */

/* Borders — extremely subtle */
--border:   255 255 255 /* Use at /5 opacity for cards, /8 for dividers */
```

---

## Typography — Non-Negotiable Rules

```
DISPLAY   Fraunces, opsz 9–144, weight 300 (Light)
          → Used for: page titles, greeting, metric values, modal headings
          → Letter-spacing: -0.02em
          → Sizes: 42px greeting | 28px page title | 24px section title | 20px card title

BODY      Geist, weight 400–500
          → Used for: all UI text, labels, descriptions, nav items, buttons
          → Sizes: 13px body | 12px small | 11px meta | 10px caps label

MONO      JetBrains Mono, weight 400–500
          → Used for: ALL numbers, timestamps, IDs, costs, percentages, code
          → Never use Geist for numeric data — always Mono
```

**Rules:**
1. Metric values (247, £18.40, 99.9%) are ALWAYS `font-display` with `font-mono` for the unit
2. Uppercase labels use `tracking-[0.14em]` minimum — wider is better
3. Mix weights aggressively: a 300-weight 42px display next to 400-weight 11px uppercase meta creates the premium contrast

---

## Component Patterns

### Stat / KPI Card
```
┌─────────────────────────────────┐
│ LABEL (11px mono caps, muted)   │ ← Always uppercase, always muted
│                          Δ +24% │ ← Delta right-aligned, colour semantic
│                                 │
│  247                            │ ← Value: font-display, 32px, light weight
│                                 │
│  ▁▃▅▆▇▇▇▇  (sparkline SVG)    │ ← 28px tall, emerald or amber stroke
└─────────────────────────────────┘
Ring: ring-1 ring-white/5, hover: ring-emerald-400/20
Background: rgb(var(--surface))
Border-radius: rounded-2xl (16px)
```

### Approval Card — Premium Pattern
```
║ ← 3px left border, colour-coded by severity
┌─────────────────────────────────────────────┐
│ [CRITICAL] [Category]              [8m ago] │ ← Header strip, bg-deep
├─────────────────────────────────────────────┤
│ Employee query (11px caps label)            │
│ "Full quoted query text here..."            │ ← text-secondary, leading-relaxed
│                                             │
│ Draft reply (11px caps label)               │
│ ┌─────────────────────────────────────────┐ │
│ │ AI-drafted text in bg-deep box...       │ │ ← ring-white/8, bg-deep
│ └─────────────────────────────────────────┘ │
│                                             │
│ 📖 §4.3 Grievance Procedure                │ ← Handbook citation strip
│ 🗄 Entitlement 25d · Taken 18d · 7 remain  │ ← Breathe HR data strip
├─────────────────────────────────────────────┤
│ [Reject] [Edit] [Escalate]     [Approve ✓] │ ← bg-deep footer, CTA right
└─────────────────────────────────────────────┘
```

CRITICAL: 3px left border red-500/50 + red glow bg
HIGH: 2px left border amber-400/40
MEDIUM: 1px border white/8

### Empty State
```
                    [Large contextual icon, text-muted/30]
              
              Title: font-display, 18px, font-light, text-primary
              Body: 13px, text-secondary, max-w-xs, centered
              
                         [Primary CTA button]
```
Never just "No data yet." Always explain WHY and WHAT TO DO.

---

## Motion — Purposeful Only

```css
/* Page-level transitions */
.page-enter { animation: fadeSlideUp 0.2s ease both; }
@keyframes fadeSlideUp {
  from { opacity: 0; transform: translateY(4px); }
  to   { opacity: 1; transform: translateY(0); }
}

/* Card hover — reveal without jarring */
.card { transition: border-color 0.15s, box-shadow 0.15s; }
.card:hover { border-color: rgba(var(--emerald), 0.2); }

/* Status dots — always animate on active/running */
.pulse-dot { animation: pulse-dot 2s ease-in-out infinite; }

/* SVG flow lines on hierarchy canvas */
.flow-line { stroke-dasharray: 4 6; animation: flow 1.8s linear infinite; }

/* Never animate: layout shifts, font changes, color of non-interactive elements */
```

---

## Navigation Pattern

### Desktop Sidebar (220px)
- Logo: emerald gradient square + Fraunces wordmark
- Tenant chip: small icon + name + chevron
- Nav items: 8px padding, 4px radius, left 2px emerald border when active
- Badge on Approvals: amber-400/20 bg, amber-300 text, number only
- Footer: plan pill (emerald bg/5, ring) + UserButton

### Mobile Bottom Bar (5 items max)
- Fixed bottom, bg-surface/95 backdrop-blur
- Active: emerald top border (2px) + emerald icon
- Badge: amber circle overlapping icon, right-top positioned
- Items: Overview, Approvals, Agents, Activity, Settings

### Command Palette (⌘K)
- Fullscreen overlay, bg-canvas/90 backdrop-blur
- Search input: large (18px), Geist, no border, bg-surface
- Results grouped: Navigation / Actions / Recent
- Keyboard-first (arrow keys, Enter, Escape)

---

## Page-Specific Requirements

### Overview (Landing)
**Must have:**
- "Good [time of day]" greeting in Fraunces 42px
- Live pulse indicator + last sync time
- 4 KPI tiles with sparklines
- Pending approvals: show top 2, badge count
- System status strip (Teams / Breathe HR / Agent)
- Recent activity feed (last 5-6 events)

**Premium touches:**
- Ambient emerald radial gradient behind greeting area (subtle, 20% opacity)
- KPI tiles alternate emerald/amber sparkline colour
- Status strip uses semantic colours per-service

### Approvals Queue
**Must have:**
- Sorted CRITICAL→HIGH→MEDIUM
- Full approval card per item (query + draft + sources + actions)
- Approve/Edit/Reject/Escalate for each
- Resolved-today collapsed section
- Badge count in nav + page header

**Premium touches:**
- CRITICAL cards have ambient red left-glow effect
- Edit mode expands inline (no modal)
- Bulk-approve affordance at top when 3+ pending
- Approval sends → card animates out (dismissed: true)

### Agents Hierarchy
**Must have:**
- SVG canvas: Gateways → Gateway node → HR Director → 5 Sub-agents → Human approval
- Animated flow-line edges
- Click agent → detail panel slides up
- Status dots animate on active/running nodes

**Premium touches:**
- Grid background on SVG canvas
- Radial glow around Gateway node
- Sub-agents show their last output inline
- Human approval node styled differently (amber, person icon)

### Activity Timeline
**Must have:**
- Date groups: Today / Yesterday / This week
- Event icon per type (tool call, approval, escalation, report)
- Full event description + metadata
- Time shown as HH:MM for today, relative for older

**Premium touches:**
- Timeline connector line running down left side
- Colour-coded event type icons
- Expandable rows for full invocation detail
- Filter chips at top (All / Approvals / Escalations / System)

### Analytics
**Must have:**
- Period selector: 7d / 30d / Calendar month
- Volume area chart (AreaChart, real SVG bezier)
- Cost line chart with budget reference
- Sensitivity distribution bars
- Approval outcomes breakdown

**Premium touches:**
- Charts use `<defs>` gradients for fill areas
- Hover tooltip shows exact values
- Trend arrows (↑↓) next to percentage deltas
- "On track for £X this month" projection text

### Knowledge
**Must have:**
- Handbook upload/status card
- Policy section health bars (5 policies)
- Breathe HR sync status
- Brain/vault placeholder

**Premium touches:**
- Upload zone with drag-and-drop visual affordance
- Health bars animate on mount
- "Last cited" timestamp per policy section
- Sync button shows loading state

---

## Anti-Patterns — Never Do These

1. **Purple gradients on dark backgrounds** — clichéd AI aesthetic
2. **Borders on every element** — use elevation (shadow/bg difference) instead
3. **Spinners for loading** — use skeletons
4. **Generic hover: `opacity: 0.8`** — hover should reveal affordances
5. **Numbers in Geist/sans** — always JetBrains Mono for data
6. **Centred body text beyond 65 characters** — left-align prose
7. **All-caps for everything** — only for labels (10-11px), never for body
8. **3+ accent colours on one screen** — one dominant, one supporting
9. **Empty states without action** — always tell user what to do
10. **Animations on every element** — animate only what earns it

---

## Quality Checklist Before Shipping Any UI

- [ ] Every number/metric uses JetBrains Mono
- [ ] Display text (headings, big values) uses Fraunces
- [ ] Colour is semantic: emerald = active/good, amber = pending/warning, red = critical
- [ ] Every interactive element has a visible hover state that reveals affordances
- [ ] Empty states explain why + what to do
- [ ] Mobile layout tested (bottom tab bar visible, cards stack correctly)
- [ ] No decorative elements that don't earn their space
- [ ] Approval cards show all 4 actions (approve/edit/reject/escalate)
- [ ] Status indicators animate (pulse-dot) on live/active states
- [ ] Grain texture applied to SVG hierarchy canvas
