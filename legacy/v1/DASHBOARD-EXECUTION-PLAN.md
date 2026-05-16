# Intel Force OS — Dashboard Execution Plan

**Status:** Active reference. Updated as we ship.
**Last updated:** 2026-04-26

This is the buildout plan for the customer-facing dashboard at `dashboard.intelforce.ai`. It covers both **page polish** (every page in `apps/dashboard/app/t/[slug]/*`) and **brain backend** (per-tenant brain storage + ingestion + semantic features). The validation test is: every customer-facing page is functional, polished, and tenant-scoped, and the brain is per-tenant real.

---

## Goal

A production-quality, multi-tenant Intel Force OS dashboard where:

- Every page has a clear purpose, looks impressive, and is fully functional.
- Each customer's brain is real (not demo) and is built automatically when the wizard finishes.
- "Ask the brain" returns answers grounded in *that customer's* graph with citations.
- The platform feels like one designed product, not a stitched-together demo.

---

## Definition of done — per page

A page is done when **all** of these are true:

1. **Functional**: every interaction does what the spec says — buttons work, forms submit, links go somewhere real.
2. **Visual**: matches the design system (see Quality Bar below). Looks like one product, not a grab bag.
3. **Real data**: connects to `db.*` queries — no hard-coded fixtures in the page itself.
4. **Tenant-scoped**: respects the tenant context, all queries filtered by `tenantId`, API routes auth-gated.
5. **States covered**: empty / loading / error states each have a real treatment, not just a default.
6. **Responsive**: works at 375px (mobile), 1024px (tablet), 1440px (laptop), 2560px (4K).
7. **Accessible**: keyboard nav works, focus rings visible, ARIA labels on icon buttons.
8. **Performant**: no jank on scroll, viz renders in <500ms, no layout shift.

---

## Definition of done — brain

The brain is done when **all** of these are true:

1. New customer wizard → upload handbook → brain builds in the background → dashboard shows their data within ~2 minutes of wizard completion.
2. **Ask-the-brain** returns answers grounded in the tenant's own graph, with citation node IDs that highlight on the canvas.
3. **Search** uses semantic similarity (embeddings), not substring matching.
4. **Surprises** tab lets the user approve/reject INFERRED edges, with rejections persisted so the brain learns.
5. Brain build failures don't leave customers stuck — there's a clear retry, and the dashboard works (with empty state) until the brain finishes.

---

## Quality bar — the design system

Every page must use these or have a documented reason not to.

### Surfaces and structure

- **Canvas:** `bg-[rgb(var(--bg-canvas))]` (rgb 7, 9, 11)
- **Card surface:** `bg-[rgb(var(--bg-surface))]` (rgb 13, 16, 20)
- **Card chrome:** `rounded-2xl`, `ring-1 ring-white/5`, hover `ring-emerald-400/20`
- **Card padding:** `px-5 py-5` for normal, `px-5 py-4` for headers
- **Section spacing:** `space-y-6` between sections
- **Page container:** layout already provides `max-w-7xl mx-auto px-4 sm:px-6 py-5 sm:py-6` — pages that need full width (Brain Map, Activity timeline, dense Analytics) escape with `fixed` positioning or self-managed full-bleed wrappers.

### Typography

- **Body:** Geist 14px (the default, no class needed)
- **Display headings:** `font-display` (Fraunces), weight `font-light` for hero scale, `font-medium` for h1
- **Numbers/code/IDs:** `font-mono` (JetBrains Mono)
- **Eyebrow labels:** `text-[10px] tracking-widest uppercase text-text-muted font-medium`
- **Page titles:** `font-display text-2xl sm:text-3xl font-light tracking-tight`

### Color usage

- **Emerald** is the only primary accent. Used for: active states, primary CTAs, "good" status, brand highlights.
- **Amber** for warnings, "needs attention", thin policy coverage, INFERRED edges.
- **Red** for danger, decommissioned, errors, AMBIGUOUS edges.
- **Violet** for AI/ML features (god nodes, brain features).
- **Text scale:** `text-text-primary` (white), `text-text-secondary` (zinc-400), `text-text-muted` (zinc-500).

### Interaction

- **Transitions:** 120ms standard, 250ms for layout
- **Hover:** ring color step up + slight bg change, never scale
- **Focus:** visible ring on all interactive elements
- **Loading skeletons:** match the actual layout, no spinners except for ambient activity
- **Keyboard:** `/` focuses search, `⌘K` opens command palette, `Esc` clears selection/closes overlays

### Reusable primitives (build once in `components/shared/`)

- `<StatTile>` — KPI card with label, value, hint, optional tone (good/warn/neutral)
- `<SectionCard>` — the standard card wrapper with header
- `<HealthBar>` — labeled progress bar with status text
- `<Eyebrow>` — uppercase label
- `<EmptyState>` — icon + primary + secondary + CTA
- `<RelativeTime>` — "12 minutes ago" formatter
- `<StatusPill>` — colored pill (emerald/amber/red/muted variants)
- `<KbdHint>` — keyboard shortcut chip

These already partially exist (`stat-card.tsx`, `empty-state.tsx`, `sensitivity-badge.tsx`) — consolidate them and use everywhere in Phase 1.

---

## Workstreams

### A. Page polish

| ID | Page | Purpose | Effort |
|---|---|---|---|
| A1 | **Overview** (`/t/[slug]`) | Customer's daily briefing — what happened today, what needs attention | ½ day |
| A2 | **Approvals** (`/t/[slug]/approvals`) | The HR Lead's daily workflow — review/edit/reject/escalate drafts | 1 day |
| A3 | **Agents** (`/t/[slug]/agents`) | Show the platform's value — what each agent does, when, with what cost | 1 day |
| A4 | **Activity** (`/t/[slug]/activity`) | Audit trail — what the agents did, why, when, how to inspect | ½ day |
| A5 | **Analytics** (`/t/[slug]/analytics`) | ROI proof — volume, cost, response time, severity trends | ½ day |
| A6 | **Wizard** (`/t/[slug]/wizard`) | Activation — 7 steps, polished, triggers brain build on completion | 1 day |
| A7 | **Settings** (`/t/[slug]/settings`) | 7 panels — consistency pass to the quality bar | ½ day |
| A8 | **Knowledge** (`/t/[slug]/knowledge`) | ✅ Done 2026-04-26 | — |
| A9 | **Brain Map** (`/t/[slug]/brain`) | ✅ Done 2026-04-26 (frontend) | — |

### B. Brain backend

| ID | Slice | What it unlocks | Effort |
|---|---|---|---|
| B1 | **Per-tenant graph storage** | Each tenant's graph isolated; demo data swap is a one-line API change | ½ day |
| B2 | **Wizard auto-init** | New customer wizard → handbook upload → brain builds → dashboard shows their data | 1 day |
| B3 | **Real Ask the brain** | ⌘K palette becomes the killer feature — grounded answers with citations | 1 day |
| B4 | **Real semantic search** | `/` search matches by meaning, not substring | 1 day |
| B5 | **Edit/verify INFERRED** | Customer reviews surprises, rejections persist, brain self-corrects | ½ day |

### C. Cross-cutting

| ID | Concern | Effort |
|---|---|---|
| C1 | **Design tokens + shared primitives** — extract from current Knowledge/Brain into `components/shared/`, refactor existing pages to use them | ½ day (must land first) |
| C2 | **Wide-screen layout audit** — relax `max-w-7xl` on viz-heavy pages, keep narrow on read-heavy | ½ day |
| C3 | **Tenant access guard** — central helper for "user has role on this tenant?", used by every API route | ½ day |
| C4 | **Performance pass** — bundle weights, lazy-load heavy components, image optimization | ½ day |
| C5 | **Type-check + lint** — clear pre-existing errors not caused by us, get CI green | ½ day |

---

## Phases

Each phase ends with a validation gate. Don't move to the next until the gate passes.

### Phase 1 — Foundation (Day 1) ✅

- [x] **C1**: Design tokens + shared primitives in `components/shared/` — Card, StatTile, HealthBar, StatusPill, Eyebrow, KbdHint, RelativeTime, PageHeader/LiveTag, barrel export
- [x] **C2**: Wide-screen layout — content container bumped to `max-w-[1600px]`; Brain Map full-bleed via `fixed`
- [x] **A1**: Overview redesigned — hero PageHeader, sparkline KPIs, two-column approvals + activity, system status row

### Phase 2 — Daily workflow (Days 2–3) ✅

- [x] **A2**: Approvals — KPI strip, severity filter chips, polished resolved-today section
- [x] **A4**: Activity — KPI strip, severity filter chips, date-grouped timeline with severity per-row chips
- [x] **A5**: Analytics — period selector (7d/30d/90d/MTD), KPI tiles with deltas, 4 chart panels, intelligent summary banner

### Phase 3 — Platform surface (Days 4–5) ✅

- [x] **A3**: Agents — KPI strip, hierarchy SVG framed in Card, per-agent grid with real db.invocation stats
- [x] **A6**: Wizard — page header upgraded, operator-first banner, shell wrapped in Card (logic untouched)
- [x] **A7**: Settings — page header upgraded with plan + status pills (panels untouched)

### Phase 4 — Brain becomes real (Days 6–7) 🟡 (foundation landed; runtime wiring outstanding)

- [x] **B1**: `BrainGraph` + `BrainEdgeReview` Prisma models, migration SQL written, API route swapped to read from `ops.brain_graphs` with demo fallback driven by `_meta.source`
- [x] **B2**: `services/brain-builder/` scaffold — CLI entrypoint, `buildTenantBrain()` orchestrator with `BUILDING → READY/FAILED` state machine, source collector with sha256 hashing, graphify runner shell-out (stub mode for dev)
- [x] **B3 partial**: Real BFS over persisted graph in `lib/brain-query.ts` (token-overlap starting nodes, depth-2 expansion, subgraph render) wired into `/api/brain/[slug]/ask`. Anthropic streaming swap-in is the only piece remaining.
- [x] **C3**: `requireTenantAccess()` helper in `lib/tenant-access.ts`, applied to both brain API routes
- [x] BrainMap UI: `_meta.source/status` drives banner — `BUILDING / FAILED` empty states added

**Outstanding for Phase 4 → "real" close-out:**
- [ ] Apply migration: `pnpm --filter @intelforce/db prisma db push` (needs DB)
- [ ] Decide Python-runtime strategy for graphify-on-the-server (Docker bundle vs HTTP service)
- [ ] Wizard step 7 → enqueue brain build (Cloudflare Queue or trpc mutation)
- [ ] Real Anthropic streaming swap-in for `composeAnswerFromSubgraph()` in `/api/brain/[slug]/ask`
- [ ] Cost logging to `ops.invocations` + `ops.costs` for brain queries

### Phase 5 — Brain becomes smart (Days 8–9) ✅

- [x] **B4**: `BrainNodeEmbedding` table on `ops` schema (pgvector vector(1024) + HNSW index), `lib/embeddings.ts` Cohere embed-v3 client via raw fetch, `services/brain-builder/src/embed-nodes.ts` runs after each graph build, `findStartingNodesSemantic()` in `lib/brain-query.ts` does pgvector cosine-distance lookup with substring fallback
- [x] **B5**: `/api/brain/[slug]/edges` GET+POST routes, `BrainEdgeReview` writes audit row on every decision, Surprises tab shows approve/reject buttons per edge with optimistic UI + rollback. Rejected edges filtered from BFS in `/ask`
- [x] **C4**: `BrainMap.lazy.tsx` dynamic-import (Brain page only loads canvas + 313KB graph data when user navigates there)

### Phase 6 — Polish & ship 🟢 (substantial)

- [x] **C5**: Type-check 9 → 2 errors. Remaining 2 require dep installs (`@clerk/themes`, `superjson` in @intelforce/trpc) — documented in PRODUCTION-CHECKLIST.md §8a
- [x] Empty/loading/error: `app/t/[slug]/loading.tsx`, `error.tsx`, `not-found.tsx` provide automatic boundaries for the entire tenant segment. Pages already have inline empty states.
- [x] Accessibility (TenantNav): aria-label, aria-current, focus-visible rings, aria-hidden on decorative icons
- [ ] Mobile audit at 375px on every page (deferred — Tailwind responsive classes already cover the structural layout; needs visual verification)
- [ ] Extend ARIA pass beyond TenantNav (deferred — bulk pattern apply across icon buttons)
- [ ] Performance budget per page (deferred — only Brain Map has measured load profile so far)

---

## Decisions to make before each phase

These shape later work. Resolve before the dependent phase starts.

| # | Decision | Default recommendation | Resolves before |
|---|---|---|---|
| D1 | Wide-screen strategy: full-width on viz pages? | Yes — Brain/Activity/Analytics full-width, others stay narrow | Phase 1 |
| D2 | Add Brain Map to mobile bottom bar? | No — keep mobile nav at 5 items, Brain stays desktop-only | Phase 1 |
| D3 | Demo data fallback when brain is empty? | Empty state with "Start wizard" CTA — drop the demo banner once B2 ships | Phase 4 |
| D4 | Embedding provider | Cohere `embed-v3` (UK/EU residency aligns with DPA) | Phase 5 |
| D5 | Brain-build queue | Cloudflare Queues (already in stack); fallback to Trigger.dev if Queues hits limits | Phase 4 |
| D6 | Agency Partner portal in scope? | Out for v1 dashboard — scaffolded only | Phase 3 |
| D7 | Per-tenant Claude Code instance interpretation | Confirmed: per-tenant *brain*, not literal CLI process per customer | (resolved 2026-04-26) |

---

## Risk register

| Risk | Mitigation |
|---|---|
| Visual drift across pages | C1 lands first; every page imports from `components/shared/`, not raw colors |
| DB migration breaks existing data | Reversible migrations, test on a dev branch, no destructive ops in shared schemas |
| Embedding API cost spirals per tenant | Per-tenant cost cap in `Cost` table, hard-stop at budget |
| Brain build hangs forever | 5-min timeout, retry button, "skip brain build" escape hatch in wizard, status polling |
| Wide-screen breakage from `max-w-7xl` removal | Opt-in per page, smoke test at 4K before merging |
| `pnpm typecheck` already failing before we started | Phase 6 includes C5 to clear unrelated errors; track them separately, don't block on them |

---

## Files this plan touches

### New
- `apps/dashboard/components/shared/{stat-tile,section-card,health-bar,eyebrow,status-pill,kbd-hint,relative-time}.tsx`
- `services/brain-builder/` (service)
- `packages/db/prisma/migrations/<timestamp>_brain_graph/migration.sql`
- `apps/dashboard/app/api/brain/[slug]/edges/route.ts` (B5)

### Modified
- `apps/dashboard/app/t/[slug]/{page,approvals,agents,activity,analytics,wizard,settings/page}.tsx`
- `apps/dashboard/app/api/brain/[slug]/{graph,ask}/route.ts` (swap demo for tenant graph)
- `apps/dashboard/components/shared/nav.tsx` (already has Brain Map)
- `apps/dashboard/app/t/[slug]/layout.tsx` (wide-screen escape hatches)
- `packages/db/prisma/schema.prisma` (BrainGraph + BrainEdgeReview models)

### Frozen (already done)
- `apps/dashboard/app/t/[slug]/knowledge/page.tsx`
- `apps/dashboard/app/t/[slug]/brain/page.tsx`
- `apps/dashboard/components/brain/BrainMap.tsx`
- `apps/dashboard/app/api/brain/[slug]/graph/route.ts` (stub returns demo, ready for Phase 4 swap)
- `apps/dashboard/app/api/brain/[slug]/ask/route.ts` (stub returns canned, ready for Phase 4 swap)

---

## Working agreement

- One phase at a time. No parallel phases.
- Phase ends with the validation gate, not "I'm tired of working on it".
- Pre-existing typecheck errors are tracked but don't block phases that don't touch the affected files. Cleared in Phase 6.
- This file is the reference. When we deviate, update this file *first*, then the code.
