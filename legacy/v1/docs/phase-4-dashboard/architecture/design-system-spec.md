# Design System Specification

**The visual language every view uses. Tokens, components, brand guidelines, accessibility rules.**

> **Audience:** any engineer writing UI; designer reviewing consistency.
>
> **Status:** v1.0. Evolves with the product; this is the starting point derived from `intelforce-dashboard.jsx` (Session 0 prototype).
>
> **Philosophy:** utility-first with Tailwind; shadcn/ui components owned in our codebase; no design-by-committee — one decision-maker owns every token change until we scale beyond three engineers on the dashboard.

---

## 1. Brand direction

The platform has a product identity that reads:
- **Credible.** Operators will run their business on this. Toy aesthetics repel.
- **Dense.** Ops tools that spread content thin feel slow and patronising. Grids, tables, tight spacing.
- **Quiet.** The product is the agents. The UI gets out of the way.
- **Not-SaaS-generic.** Emerald/amber/black, not purple-gradient-logo-with-lava-lamp-hero.

The `intelforce-dashboard.jsx` prototype establishes this direction visually. Ship time will polish; this spec locks in what stays.

---

## 2. Colour tokens

### 2.1 Dark mode (default)

Every screen defaults to dark. Operators spend hours in the dashboard; dark reduces eye strain. Light mode exists for screenshotting and for users who prefer it.

| Token | Hex | Usage |
|---|---|---|
| `bg-canvas` | `#09090b` | Page background |
| `bg-surface` | `#18181b` | Card background |
| `bg-surface-raised` | `#27272a` | Modal, popover background |
| `bg-surface-hover` | `#3f3f46` | Hover state on surface |
| `border-subtle` | `#27272a` | Subtle divider |
| `border-default` | `#3f3f46` | Standard border |
| `border-strong` | `#52525b` | Emphasis border (selected state) |
| `text-primary` | `#fafafa` | Primary text |
| `text-secondary` | `#a1a1aa` | Secondary text (captions, metadata) |
| `text-tertiary` | `#71717a` | Tertiary text (disabled, very muted) |
| `text-inverse` | `#09090b` | Text on brand/accent backgrounds |

### 2.2 Brand / accent

| Token | Hex | Usage |
|---|---|---|
| `brand-emerald-50`  | `#ecfdf5` | Background tint (rare — used sparingly) |
| `brand-emerald-500` | `#10b981` | Primary accent, success state, "active" |
| `brand-emerald-600` | `#059669` | Primary button default |
| `brand-emerald-700` | `#047857` | Primary button hover |
| `brand-amber-500`   | `#f59e0b` | Warning state, budget-near-limit |
| `brand-amber-600`   | `#d97706` | Warning emphasis |

### 2.3 Semantic (status)

| Token | Hex | Usage |
|---|---|---|
| `status-info`    | `#3b82f6` | Informational |
| `status-success` | `#10b981` | Success (same as emerald-500) |
| `status-warning` | `#f59e0b` | Warning |
| `status-danger`  | `#ef4444` | Error, critical escalation |
| `status-neutral` | `#71717a` | Inactive, pending, neutral |

### 2.4 Light mode

Light mode mirrors dark. Token-identical structure. Implementation via CSS variables + `dark:` prefix.

| Token | Dark | Light |
|---|---|---|
| `bg-canvas` | `#09090b` | `#ffffff` |
| `bg-surface` | `#18181b` | `#fafafa` |
| `text-primary` | `#fafafa` | `#18181b` |
| `brand-emerald-500` (unchanged) | `#10b981` | `#10b981` |

Every colour combination tested for WCAG AA contrast. Failing pairs are caught by a `contrast-check` lint rule in CI.

---

## 3. Typography

Single typeface family: **Inter** (variable). Free, open-source, hinted for screens, comprehensive Unicode.

Headline font fallback: Inter at heavier weight. No display font — keeps the product feeling utilitarian.

Monospace: **JetBrains Mono** — for code, IDs, file paths, diffs.

### 3.1 Scale (Tailwind defaults, with adjustments)

| Token | Tailwind class | Size / LH | Usage |
|---|---|---|---|
| `text-xs` | `text-xs` | 12px / 1.4 | Labels, metadata |
| `text-sm` | `text-sm` | 14px / 1.5 | Body default |
| `text-base` | `text-base` | 16px / 1.5 | Long-form reading (vault preview) |
| `text-lg` | `text-lg` | 18px / 1.4 | Card titles |
| `text-xl` | `text-xl` | 20px / 1.4 | Section headings |
| `text-2xl` | `text-2xl` | 24px / 1.3 | Page titles (tenant context) |
| `text-3xl` | `text-3xl` | 30px / 1.2 | Page titles (landing) |

Body default is `text-sm` (14px), not 16px. Ops tools punish low information density; 14px with good line-height (1.5) stays readable and lets us show more without horizontal scroll.

### 3.2 Weight scale

- `font-normal` (400) — body
- `font-medium` (500) — emphasis, UI labels
- `font-semibold` (600) — headings, table headers
- `font-bold` (700) — rare; numbers in KPI tiles

### 3.3 Numeric tabular

Tables, metrics, and timestamps use `font-variant-numeric: tabular-nums` to keep digit widths consistent. One Tailwind utility: `tabular-nums`.

---

## 4. Spacing & layout

### 4.1 Base unit

4px. Every spacing decision is `4px × n`. Tailwind's default scale aligns.

### 4.2 Density

Dashboard layouts are medium-dense. Examples:
- Card padding: `p-6` (24px) on desktop, `p-4` (16px) on narrow
- Section spacing: `space-y-8` (32px) between sections
- Table row height: `h-10` (40px) for default, `h-9` (36px) for dense
- Form input height: `h-10` (40px) — large enough for thick fingers on touch devices

### 4.3 Breakpoints

Tailwind defaults:
- `sm`: 640px
- `md`: 768px
- `lg`: 1024px (primary breakpoint for dashboard)
- `xl`: 1280px
- `2xl`: 1536px

The dashboard is designed for `lg` and up. Mobile (`<640px`) is usable but restricted to read-only viewing for v1.

### 4.4 Container widths

| Context | Max width |
|---|---|
| Tenant-context pages | `max-w-screen-xl` (1280px) centred |
| Operator admin tables | `max-w-none` (full width) |
| Wizard / form pages | `max-w-2xl` (672px) |
| Vault preview | `max-w-3xl` (768px) centred |

---

## 5. Components

### 5.1 Core components (from shadcn/ui)

These are copy-pasted into `packages/ui/` and owned by us. We customise freely — no upstream sync pressure.

| Component | Our delta |
|---|---|
| `Button` | Adds `variant="danger-subtle"` for soft-destructive actions |
| `Input` | Default size is `h-10`, not `h-11` |
| `Select` (Radix Select) | Used only for small, stable enum lists |
| `Combobox` (cmdk) | Used for searchable lists (tenants, integrations, etc.) |
| `Dialog` (Radix) | Large modal uses `max-w-3xl`; confirmation modal uses `max-w-md` |
| `Sheet` (Radix Drawer) | Right-side slide-over for edit actions |
| `Popover`, `Tooltip`, `DropdownMenu` | Standard |
| `Tabs` (Radix) | Used for switching between related views |
| `Toast` (sonner) | Position: bottom-right, not top-right |
| `Badge` | 7 variants: `default`, `outline`, `emerald`, `amber`, `red`, `blue`, `neutral` |
| `Avatar` | Initials fallback when no image |
| `Skeleton` | Matches the shape of content it replaces |

### 5.2 Custom components (IntelForce-specific)

Lives in `packages/ui/src/composite/`:

| Component | Purpose |
|---|---|
| `<TenantBadge tenantId />` | Renders a tenant's slug + plan tier; hoverable for full name |
| `<EscalationSeverityBadge severity />` | Coloured badge matching `severity` field from Escalation Notifier |
| `<CostTile period agent />` | KPI tile showing spend in pounds, delta vs previous period |
| `<InvocationStatusPill status />` | Running/completed/failed/escalated/cost_stopped/timed_out with appropriate colour |
| `<VaultFileLink path />` | Link to a vault file with icon by file extension |
| `<AgentChip agent />` | Small chip showing agent name + icon (consistent across views) |
| `<EmptyState title description action />` | Scaffolded empty-state component |
| `<DataTable columns data />` | TanStack Table wrapper with our defaults (dense, sortable, filterable) |
| `<CodeBlock language children />` | Shiki-syntax-highlighted code block (used in Brain view for agent outputs) |
| `<DateRangePicker />` | For filtering by period |
| `<KeyboardShortcut keys />` | Visual rendering of shortcut keys (e.g., `⌘K`) |

### 5.3 Page-level patterns

| Pattern | When to use |
|---|---|
| **Stat-cards-row + table** | Operator overview pages (per-tenant ops, global costs) |
| **Filters-rail + list** | Browsing escalations, invocations, audit log |
| **Detail pane** | When selecting a row opens a right-side sheet (preview without navigation) |
| **Full-page drill** | When selecting navigates to a full-page view (escalation detail, vault file) |
| **Wizard (stepped)** | Onboarding, reprovisioning, decommissioning — anything multi-step |
| **Form + preview** | Settings pages — form on left, live preview on right |

---

## 6. Icons

Single icon set: **Lucide**. Accessed via our `packages/icons/` re-export. Naming convention: match Lucide's PascalCase names.

No custom icons unless genuinely unavoidable (agent icons qualify — see below). Saves us the design debt of a homegrown set.

### 6.1 Agent icons

Each of the 10 agents gets a consistent glyph used wherever the agent is shown:

| Agent | Icon |
|---|---|
| Proposal Builder | `FileCheck` |
| Lead Hunter | `Target` |
| Client Onboarder | `HandshakeIcon` (custom SVG; Lucide doesn't have one) |
| Content Creator | `FileText` |
| Repurposer | `Recycle` |
| Caption Writer | `Quote` |
| Follow-Up Pilot | `MailCheck` |
| Reporting Engine | `LineChart` |
| SOP Writer | `BookOpen` |
| Librarian | `Library` |

One custom SVG (`HandshakeIcon`) lives in `packages/icons/src/custom/`.

### 6.2 Status icons

Status colours are paired with icons — never colour alone:

| Status | Icon | Colour |
|---|---|---|
| Running | `Loader` (animated) | `brand-emerald-500` |
| Completed | `CheckCircle` | `brand-emerald-500` |
| Failed | `XCircle` | `status-danger` |
| Escalated | `AlertTriangle` | `brand-amber-500` |
| Cost stopped | `CircleDollarSign` | `status-warning` |
| Timed out | `Clock` | `status-neutral` |

---

## 7. Motion

- **Transitions:** `transition-colors`, `transition-opacity` — 150ms ease
- **Enter/exit:** Radix's default animations, customised via Tailwind's CSS variables
- **Page transitions:** none (intentional — ops tools that animate page changes feel slow)
- **Loading animations:** skeleton shimmer, no spinners
- **Reduced motion:** respects `prefers-reduced-motion`; skeletons become static, Radix animations disabled

---

## 8. Data visualisation

### 8.1 Charts

Recharts for standard charts. d3 directly when we need something non-standard (sparklines, heatmaps).

### 8.2 Chart defaults

| Axis labels | `text-xs`, `text-tertiary` |
| Grid lines | `border-subtle` |
| Default series colour | `brand-emerald-500` |
| Secondary series | `brand-amber-500`, then `status-info`, then `status-neutral` |
| Tooltips | `bg-surface-raised`, `border-default`, `text-sm` |
| Legends | Below chart, left-aligned |

### 8.3 What to avoid

- Pie charts (only with 2–3 slices; otherwise bars)
- 3D charts (ever)
- More than 5 colours in a single chart
- Grid backgrounds that compete with data

---

## 9. Tables

Tables are the dashboard's primary surface. We invest in table polish.

| Property | Default |
|---|---|
| Header style | `text-xs`, `font-medium`, `text-tertiary`, `uppercase`, `tracking-wider` |
| Row divider | `border-subtle` |
| Row hover | `bg-surface-hover` |
| Row selection | `bg-brand-emerald-500/10`, left border `brand-emerald-500` |
| Numeric columns | right-aligned, `tabular-nums` |
| Sticky header | on tables >15 rows |
| Sorting | click column header; active sort indicated with `ArrowUp`/`ArrowDown` |
| Pagination | "10 of 847" in bottom-left, controls in bottom-right |
| Empty row height | `h-10` — matches filled rows |

### 9.1 Dense mode toggle

Operator admin tables default to dense (`h-9` rows). Tenant-context tables default to standard (`h-10`).

---

## 10. Forms

### 10.1 Layout

Vertical label-above-input pattern. Labels are `text-sm`, `font-medium`, `text-primary`. Help text is `text-xs`, `text-secondary`, below the input.

### 10.2 Validation

- Inline after blur or submit
- Error message below input in `text-xs`, `status-danger`
- Red border only on error; no red background
- Success states (green check) only for async verification (e.g., "Email verified")

### 10.3 Required fields

Marked with an asterisk in the label `<span class="text-status-danger">*</span>`. Not required fields get "(optional)" appended — explicit > implicit.

### 10.4 Submit buttons

- Primary action right-aligned
- Cancel/back left-aligned
- Primary action disabled only when form is invalid AND submitted once (reduces anxiety on first tab-through)
- Loading state: disabled + spinner + label changes to "Saving..."

---

## 11. Accessibility rules

1. **Contrast** — every text colour meets 4.5:1 on its background
2. **Focus rings** — visible 2px `brand-emerald-500` ring on every interactive element
3. **Keyboard** — every action reachable without a mouse
4. **Screen readers** — every icon-only button has `aria-label`; every dynamic region has `aria-live`
5. **Motion** — `prefers-reduced-motion` respected
6. **Headings** — one `<h1>` per page; headings don't skip levels
7. **Forms** — every input associated with a `<label>` (no placeholder-as-label)
8. **Tables** — use `<caption>` or `aria-labelledby`

---

## 12. Responsive behaviour

| Breakpoint | Strategy |
|---|---|
| `< 640px` | Single-column; primary actions sticky at bottom; tables become cards |
| `640–1024px` | Two-column forms become stacked; sidebar becomes hamburger |
| `≥ 1024px` | Full layouts as designed |

Some views are gated behind `≥ 1024px`:
- Admin escalation queue with filters-rail
- Wizard with live preview pane

Below the threshold, the view shows a friendly message: "This view works best on desktop. Open on a larger screen."

---

## 13. Content / voice

The dashboard's microcopy is:
- **Direct.** "Tenant suspended." Not "We've gone ahead and suspended the tenant for you."
- **Specific.** "Cost budget exceeded by £42 (108% of £550)." Not "Budget exceeded."
- **Kind on errors.** "We couldn't reach HubSpot. Retrying automatically in 30 seconds." Not "ERROR: API failure."
- **Button verbs.** "Save changes", "Rotate secret", "Resume tenant" — never "OK", never "Submit".
- **Never apologetic on our own bugs.** "Something broke. [Retry]" — save the big apology for the email, not every error state.

Full voice notes to be owned by the product copywriter (post-hire). For now, these rules.

---

## 14. Design tokens as CSS variables

Implementation detail — the tokens live in `packages/ui/src/tokens.css`:

```css
:root {
  --bg-canvas: 9 9 11;
  --bg-surface: 24 24 27;
  --text-primary: 250 250 250;
  --brand-emerald-500: 16 185 129;
  /* ...etc */
}

[data-theme='light'] {
  --bg-canvas: 255 255 255;
  --bg-surface: 250 250 250;
  --text-primary: 24 24 27;
  /* ... */
}
```

Tailwind config references these:

```js
colors: {
  canvas: 'rgb(var(--bg-canvas) / <alpha-value>)',
  surface: 'rgb(var(--bg-surface) / <alpha-value>)',
  /* ... */
}
```

Space-separated RGB values let us use Tailwind's alpha-channel modifiers (`bg-canvas/80`).

---

## 15. Review process

Design changes that touch the system require review from the design-system owner (one person; v1 that's the founding engineer) before merge. Review criteria:
- Does this token/component need to exist, or is there already a fit?
- Is the change consistent with existing tokens?
- Does it introduce accessibility regressions?
- Is the change worth the cognitive cost of another variant?

Answering "no" to the first question is fine; better to notice and not add than to add for the sake of completeness.

---

## 16. Implementation checklist (for CC13, design system portion)

- [ ] `packages/ui/` scaffolded with tokens.css
- [ ] Tailwind config in `packages/config/`
- [ ] shadcn/ui components added and customised per §5
- [ ] Agent icons (`HandshakeIcon` custom; others re-exported)
- [ ] Dark/light theme toggle wired
- [ ] Storybook for component catalog (optional but strongly recommended — saves downstream design debates)
- [ ] Visual regression tests via Playwright screenshots
- [ ] Accessibility linting via `eslint-plugin-jsx-a11y`

---

## 17. Related

- `dashboard-architecture-spec.md` — stack decisions
- `intelforce-dashboard.jsx` — original visual prototype
- Individual view specs reference components from this document
