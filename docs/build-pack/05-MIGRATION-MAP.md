# 05 · Migration Map

**Concept-by-concept inventory of v1 (`/Users/madsadmin/code/intel-force-os/`) and cortextOS (`/Users/madsadmin/code/cortex-os-upstream/`). For each: keep / rebuild / drop, with v1 paths and v2 destinations. This is the single most useful lookup during the build — when a Phase asks "lift the activity log", this file says exactly which v1 file to read and where it goes in v2.**

---

## How to use this file

Three columns matter:

| Column | Meaning |
|---|---|
| **Verdict** | KEEP (use as-is in v2) · REBUILD (re-implement in v2, concept lifted) · DROP (not relevant in v2) |
| **v1 / upstream path** | Where it lives today |
| **v2 destination** | Where it lands in `/Users/madsadmin/code/CortexOS/` |

The implementer reads down the verdict column and skips DROP rows. KEEP rows are direct lifts (copy file, fix imports, ship). REBUILD rows are conceptual lifts (read v1 implementation, write v2 implementation against v2 stack).

---

## 1. From Intel Force OS v1

### 1.1 Dashboard chrome (DEFINITE LIFTS)

| Concept | Verdict | v1 path | v2 destination |
|---|---|---|---|
| Design tokens (emerald, amber, dark mode) | KEEP | `apps/dashboard/app/globals.css` | `packages/ui/tailwind.tokens.css` |
| Card primitive | KEEP | `apps/dashboard/components/shared/card.tsx` | `packages/ui/src/card.tsx` |
| StatusPill (good/warn/info/muted/danger) | KEEP | `apps/dashboard/components/shared/status-pill.tsx` | `packages/ui/src/status-pill.tsx` |
| Eyebrow text component | KEEP | `apps/dashboard/components/shared/eyebrow.tsx` | `packages/ui/src/eyebrow.tsx` |
| PageHeader + LiveTag | KEEP | `apps/dashboard/components/shared/page-header.tsx` | `packages/ui/src/page-header.tsx` |
| StatTile + StatCard | KEEP | `apps/dashboard/components/shared/stat-tile.tsx` etc. | `packages/ui/src/stat-tile.tsx` |
| HealthBar | KEEP | `apps/dashboard/components/shared/health-bar.tsx` | `packages/ui/src/health-bar.tsx` |
| SensitivityBadge | KEEP | `apps/dashboard/components/shared/sensitivity-badge.tsx` | `packages/ui/src/sensitivity-badge.tsx` |
| RelativeTime + formatRelative | KEEP | `apps/dashboard/components/shared/relative-time.tsx` | `packages/ui/src/relative-time.tsx` |
| Skeleton + KbdHint + EmptyState | KEEP | `apps/dashboard/components/shared/{skeleton,kbd-hint,empty-state}.tsx` | `packages/ui/src/*` |
| Sidebar nav + sidebar context | KEEP | `apps/dashboard/components/shared/{nav,sidebar-context}.tsx` | `packages/ui/src/nav.tsx`, `apps/dashboard/lib/sidebar-context.tsx` |
| `cn()` className helper | KEEP | `apps/dashboard/lib/cn.ts` | `packages/ui/src/cn.ts` |

All lifts are pure presentational components. Direct copy, rewrite imports, run typecheck. No logic changes.

### 1.2 Agent system (CONCEPTUAL LIFTS)

| Concept | Verdict | v1 path | v2 destination |
|---|---|---|---|
| Agent catalogue (11 specs) | KEEP | `apps/dashboard/lib/agent-catalog.ts` | `packages/agents/catalog.ts` |
| Director colour map | KEEP | constants inside `lib/agent-catalog.ts` + `components/operations/agent-activity-log.tsx` | `packages/agents/directors.ts` |
| Per-agent descriptions, integrations, schedules | KEEP | `lib/agent-catalog.ts` | `packages/agents/catalog.ts` (same shape) |
| Agent activity log (the recent UI work) | KEEP | `apps/dashboard/components/operations/agent-activity-log.tsx` | `apps/dashboard/components/agents/activity-log.tsx` |
| Activity log server data layer | REBUILD | `apps/dashboard/lib/agent-activity.ts` | `apps/dashboard/lib/agent-activity.ts` — rewire to v2 invocation + cortextOS bus state |
| Agents `/agents` page (hierarchy + KPI tiles) | REBUILD | `apps/dashboard/app/t/[slug]/agents/page.tsx` | `apps/dashboard/app/t/[slug]/agents/page.tsx` — adapt to v2 schema |
| Agent web visualisation (Cosmograph) | KEEP | `apps/dashboard/components/agents/agent-web.tsx` | `apps/dashboard/components/agents/agent-web.tsx` |
| Per-agent prompts | REBUILD | `apps/dashboard/lib/agent-catalog.ts` (`description` field) → cortextOS agent template prompt | `packages/agents/templates/<key>/prompt.md` |

The 11 agents themselves stay identical — same names, same directors, same descriptions, same integrations. Implementation moves from "static catalogue + Worker invocation" to "cortextOS agent templates running in PTY sessions".

### 1.3 Governance + Approvals

| Concept | Verdict | v1 path | v2 destination |
|---|---|---|---|
| Approvals UI page | REBUILD | `apps/dashboard/app/t/[slug]/approvals/page.tsx` | `apps/dashboard/app/t/[slug]/approvals/page.tsx` — adapt to read Prisma + cortextOS state |
| Approval card components | KEEP | `apps/dashboard/components/approvals/*.tsx` | `apps/dashboard/components/approvals/*.tsx` |
| Filter chips | KEEP | `apps/dashboard/components/approvals/filter-chips.tsx` | `apps/dashboard/components/approvals/filter-chips.tsx` |
| Sensitivity classifier | REBUILD | wherever v1 has it (likely `packages/trpc/src/routers/` or worker side) | `packages/governance/src/sensitivity.ts` |
| Audit-event writer | REBUILD | v1's worker writes AuditEvent rows | `packages/governance/src/audit.ts` |
| Audit-event log UI (Activity page audit section) | KEEP | `apps/dashboard/app/t/[slug]/activity/page.tsx` (the audit log half) | `apps/dashboard/app/t/[slug]/activity/page.tsx` |
| Escalation feed | KEEP | `apps/dashboard/components/operations/escalations-feed.tsx` | `apps/dashboard/components/operations/escalations-feed.tsx` |
| 7-year retention policy | KEEP | enforced in v1 docs | enforce in `packages/db/prisma/schema.prisma` + Neon retention |

### 1.4 Brain / Knowledge

| Concept | Verdict | v1 path | v2 destination |
|---|---|---|---|
| `/brain` page concept | KEEP (radically upgrade) | `apps/dashboard/app/t/[slug]/brain/page.tsx` | `apps/dashboard/app/t/[slug]/brain/page.tsx` |
| Cosmograph-based agent map | KEEP | `apps/dashboard/components/agents/agent-web.tsx` (use as graph view reference) | `apps/dashboard/components/brain/graph-view.tsx` |
| Knowledge page (handbook, integrations) | REBUILD | `apps/dashboard/app/t/[slug]/knowledge/page.tsx` | `apps/dashboard/app/t/[slug]/brain/wiki/[...path]/page.tsx` |
| BrainGraph Prisma model | DROP | v1 `packages/db/prisma/schema.prisma` | v2 has its own `brain.nodes` + `brain.edges` (see `04-DATA-MODEL.md`) |

### 1.5 Other dashboard surfaces

| Concept | Verdict | v1 path | v2 destination |
|---|---|---|---|
| Overview page (KPIs + activity preview) | REBUILD | `apps/dashboard/app/t/[slug]/page.tsx` | `apps/dashboard/app/t/[slug]/page.tsx` |
| Analytics page (recharts) | KEEP | `apps/dashboard/app/t/[slug]/analytics/page.tsx` + period-selector | `apps/dashboard/app/t/[slug]/analytics/page.tsx` |
| Settings panels (7) | KEEP | `apps/dashboard/components/settings/*.tsx` | `apps/dashboard/components/settings/*.tsx` |
| Wizard (onboarding flow) | REBUILD | `apps/dashboard/app/t/[slug]/wizard/page.tsx` + `components/wizard/steps/` | `apps/dashboard/app/t/[slug]/wizard/page.tsx` — adapt to v2 provisioning |
| Error / loading / not-found pages | KEEP | `apps/dashboard/app/t/[slug]/{error,loading,not-found}.tsx` | `apps/dashboard/app/t/[slug]/{error,loading,not-found}.tsx` |

### 1.6 Backend infrastructure

| Concept | Verdict | v1 path | v2 destination |
|---|---|---|---|
| Cloudflare Worker bot runtime | DROP | `src/index.ts`, `src/bot/`, `src/cards/`, `src/agents/`, `src/storage/`, `src/utils/`, `wrangler.toml`, `migrations/` | Not ported. cortextOS daemon replaces. |
| Teams app manifest + icons | DEFER | `teams-app/` | Phase 3 if/when a customer demands Teams. |
| tRPC router | REBUILD | `packages/trpc/src/routers/*.ts` | `packages/trpc/src/routers/*.ts` (or move to Server Actions; see `08-OPEN-DECISIONS.md`) |
| Prisma schema | REBUILD | `packages/db/prisma/schema.prisma` | `packages/db/prisma/schema.prisma` — see `04-DATA-MODEL.md` §2 |
| DB package itself | KEEP (structure) | `packages/db/` | `packages/db/` |
| Onboarding CLI | DROP | `onboarding/` | cortextOS has its own org setup; we wrap it. |
| Tests folder structure | KEEP (pattern) | `tests/` | `tests/` |
| Build/deploy scripts | DROP | `scripts/` (mostly Worker-specific) | New scripts for PM2 + Fly.io |

### 1.7 Specifications (docs/)

| Concept | Verdict | v1 path | v2 destination |
|---|---|---|---|
| Phase 0 strategic | KEEP (reference) | `docs/phase-0-strategic/` | Reference from `07-V1-INHERITED-CONTEXT.md`; don't copy |
| Phase 1 POC stack | DROP | `docs/phase-1-poc-stack/` | Already retired |
| Phase 2 agent suite (10 agent specs) | KEEP (mine for prompts) | `docs/phase-2-agent-suite/` | Source for `packages/agents/templates/<key>/prompt.md` |
| Phase 3 platform | KEEP (lifts informed) | `docs/phase-3-platform/` | Informs `03-ARCHITECTURE.md` decisions on multi-tenancy, secrets, observability |
| Phase 4 dashboard | KEEP (lifts informed) | `docs/phase-4-dashboard/` | Informs the dashboard rebuild |
| Phase 5 business/legal | KEEP (as-is) | `docs/phase-5-business-legal/` | Intel Force Ltd legal docs unchanged; v2 reuses MSA/DPA/SLA/AUP/Privacy/ToS |
| Phase 6 ops runbooks | KEEP (adapt) | `docs/phase-6-ops-runbooks/` | Adapt incident + DR runbooks for v2 topology |
| GTM pack | KEEP (as-is) | `docs/gtm-pack/` | Inherits unchanged |
| Teams HR Agent | DROP | `docs/teams-hr-agent/` | v1-specific |

### 1.8 Brand / marketing

| Concept | Verdict | v1 / location | v2 destination |
|---|---|---|---|
| Marketing site | DEFER | `/Users/madsadmin/Projects/proposal-video-generator/Intelforce Website/` | Migrates last, after product migration |
| Website context pack | KEEP (reference) | `/Users/madsadmin/Projects/proposal-video-generator/Intelforce Website/WEBSITE-CONTEXT.md` | Reference when v2 marketing site rewrites |
| Brand voice rules | KEEP | `WEBSITE-CONTEXT.md` §brand-identity-spec | `packages/agents/voice.md` — used by every agent that drafts customer-facing content |
| Logo, palette, typography | KEEP | `WEBSITE-CONTEXT.md` §6 + `intel-force-os/docs/phase-5-business-legal/marketing/brand-identity-spec.md` | `packages/ui/tailwind.tokens.css` |

---

## 2. From cortextOS upstream

### 2.1 Core harness (VENDORED AS-IS)

| Component | Verdict | Upstream path | v2 destination |
|---|---|---|---|
| TypeScript source | KEEP | `src/{bus,cli,daemon,hooks,pty,telegram,types,utils}/` | `packages/harness/cortextos/src/` |
| CLI entry | KEEP | `dist/cli.js` (after `npm run build`) | `packages/harness/cortextos/dist/cli.js` |
| Daemon entry | KEEP | `dist/daemon.js` | `packages/harness/cortextos/dist/daemon.js` |
| Agent templates (Orchestrator, Analyst, Specialist, Hermes, M2C1) | KEEP | `templates/` | `packages/harness/cortextos/templates/` |
| Org template | KEEP | `templates/org/` | `packages/harness/cortextos/templates/org/` |
| PM2 ecosystem config | ADAPT | `ecosystem.config.js` | `infra/pm2/ecosystem.config.js` — adapted with v2 paths |
| Test infra (Vitest + Playwright configs) | REFERENCE | `vitest.config.ts`, `playwright.config.ts` | v2 has its own configs; cortextOS's stays in the vendored copy |

### 2.2 Bus scripts (47 files)

The full inventory of `bus/*.sh` from upstream. For each: keep upstream (no override) · override (we provide our own implementation) · augment (run original + our shim).

| Bus script | Action | Why |
|---|---|---|
| `kb-ingest.sh` | OVERRIDE | Backend swap — delegates to `packages/brain/cli/kb-ingest.js` |
| `kb-query.sh` | OVERRIDE | Backend swap — delegates to `packages/brain/cli/kb-query.js` |
| `kb-setup.sh` | OVERRIDE | Backend swap — sets up Postgres + vault dir instead of mmrag |
| `kb-collections.sh` | OVERRIDE | Backend swap — lists graph scopes instead of mmrag collections |
| `create-approval.sh` | AUGMENT | Run original + mirror to Prisma |
| `list-approvals.sh` | AUGMENT | Defer to dashboard query layer (reads Prisma) for UI; keep CLI path for agent use |
| `update-approval.sh` | AUGMENT | Run original + mirror to Prisma + write AuditEvent |
| `create-task.sh` | KEEP | cortextOS-native, no v2 override |
| `complete-task.sh` | KEEP | cortextOS-native |
| `update-task.sh` | KEEP | cortextOS-native |
| `archive-tasks.sh` | KEEP | cortextOS-native |
| `list-tasks.sh` | KEEP | cortextOS-native |
| `check-stale-tasks.sh` | KEEP | cortextOS-native |
| `check-human-tasks.sh` | KEEP | cortextOS-native |
| `check-goal-staleness.sh` | KEEP | cortextOS-native |
| `create-experiment.sh` | KEEP | "theta wave" feature; no v2 changes initially |
| `run-experiment.sh` | KEEP | Same |
| `evaluate-experiment.sh` | KEEP | Same |
| `list-experiments.sh` | KEEP | Same |
| `send-message.sh` | AUGMENT | Mirror outbound messages to AuditEvent table |
| `send-telegram.sh` | KEEP | cortextOS-native |
| `edit-message.sh` | KEEP | cortextOS-native |
| `answer-callback.sh` | KEEP | cortextOS-native Telegram callback |
| `check-inbox.sh` | KEEP | cortextOS-native |
| `ack-inbox.sh` | KEEP | cortextOS-native |
| `update-heartbeat.sh` | KEEP | cortextOS-native |
| `read-all-heartbeats.sh` | KEEP | cortextOS-native |
| `log-event.sh` | AUGMENT | Also write to AuditEvent |
| `post-activity.sh` | AUGMENT | Mirror to AuditEvent |
| `collect-metrics.sh` | AUGMENT | Mirror to Invocation table |
| `check-usage-api.sh` | KEEP | cortextOS-native |
| `gather-context.sh` | KEEP | cortextOS-native |
| `manage-cycle.sh` | KEEP | cortextOS-native (71-hour rotation) |
| `self-restart.sh` | KEEP | cortextOS-native |
| `soft-restart.sh` | KEEP | cortextOS-native |
| `hard-restart.sh` | KEEP | cortextOS-native |
| `auto-commit.sh` | KEEP | cortextOS-native |
| `sync-org-config.sh` | KEEP | cortextOS-native |
| `list-agents.sh` | KEEP | cortextOS-native |
| `list-skills.sh` | KEEP | cortextOS-native |
| `prepare-submission.sh` | KEEP | community submission flow |
| `submit-community-item.sh` | KEEP | community |
| `browse-catalog.sh` | KEEP | community |
| `install-community-item.sh` | KEEP | community |
| `hook-ask-telegram.sh` | KEEP | hook integration |
| `hook-permission-telegram.sh` | KEEP | hook |
| `hook-planmode-telegram.sh` | KEEP | hook |
| `check-upstream.sh` | KEEP | cortextOS-native (now points at our vendored copy's `.upstream-version`) |
| `_ctx-env.sh` | KEEP | shared |
| `_telegram-curl.sh` | KEEP | shared |

### 2.3 Dashboard (cortextOS's own)

| Component | Verdict | Why |
|---|---|---|
| `dashboard/` (Next 14 app) | REFERENCE | We don't use it. v2 builds its own dashboard with lifted v1 chrome. cortextOS's dashboard is harness-shaped; v2's is product-shaped. |
| `dashboard/AGENTS.md`, `dashboard/CLAUDE.md` | REFERENCE | Useful to understand what cortextOS's UI does so v2 can subsume the right behaviours |

### 2.4 Knowledge base

| Component | Verdict | Why |
|---|---|---|
| `knowledge-base/scripts/mmrag.py` | REPLACE | The whole point of the brain swap. v2's `packages/brain/` ships an equivalent CLI behind the same shell-script interface. |
| `knowledge-base/scripts/requirements.txt` | DROP | Python dep tree not needed in v2 |
| `knowledge-base/scripts/_test_clients` | REFERENCE | Useful for understanding upstream's API; v2 implements its own |

### 2.5 Skills + Community

| Component | Verdict | Why |
|---|---|---|
| `skills/` (claude-api-helper, comms, cron-management, mcp-integration, prompt-engineering, tasks, tool-use-patterns, web-research) | KEEP | These are cortextOS-native agent skills. Used by agents at runtime. Keep in vendored copy. |
| `community/` (community catalogue) | KEEP | cortextOS community submission system. Stays. |

### 2.6 Hooks + Scripts

| Component | Verdict | Why |
|---|---|---|
| `hooks/` | KEEP | cortextOS-native Claude Code hooks. v2 inherits them. |
| `scripts/` | KEEP (in vendored copy) | Build + maintenance scripts |
| `install.mjs` | REFERENCE | Not used in v2 install path; v2 has its own `infra/install/` flow |

### 2.7 Docs

| Component | Verdict | Why |
|---|---|---|
| `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `CRONS_MIGRATION_GUIDE.md`, `docs/` | REFERENCE | Read once to understand upstream. Not lifted. |

---

## 3. Things explicitly created new in v2 (no v1/upstream source)

| New thing | v2 path | Why |
|---|---|---|
| Wiki+Graphify brain backend | `packages/brain/` | The whole product upgrade |
| Per-tenant vault filesystem layout | `/var/cortexos/tenants/<slug>/vault/` | New storage convention |
| Brain graph view (Cosmograph + Obsidian-quality) | `apps/dashboard/components/brain/graph-view.tsx` | New UI |
| Brain wiki view | `apps/dashboard/components/brain/wiki-view.tsx` | New UI |
| Time-scrubber for graph growth | `apps/dashboard/components/brain/time-scrubber.tsx` | New UI |
| Daemon boot wrapper | `apps/daemon/src/boot.ts` | New entry point |
| Governance bus shims | `packages/governance/bus-shims/*.sh` | Dual-write pattern |
| v1→v2 migration script | `infra/migrate/v1-to-v2.ts` | Built in Phase 3 |
| Per-tenant PM2 spawn logic | `infra/pm2/ecosystem.config.js` (adapted) | Per-tenant process model |

---

## 4. The lookup procedure for the implementer

When a build slice mentions "lift the agent activity log":

1. Open this file (§1.2)
2. Find the row: `Agent activity log (the recent UI work)` → `apps/dashboard/components/operations/agent-activity-log.tsx` → `apps/dashboard/components/agents/activity-log.tsx`
3. Open the v1 file with Read
4. Create the v2 file at the destination, paste, fix imports against `packages/ui/` and `packages/db/`
5. Run typecheck
6. Move on

Every concept worth lifting has a row. If the implementer can't find the row, the concept either isn't worth lifting or should be added to this file (then lifted). Don't lift undocumented things; if you find yourself doing it, document the row first.

---

## 5. Open migration decisions

See `08-OPEN-DECISIONS.md`:

- §5 — Which v1 customer (if any) is the migration test pilot
- §6 — Whether to lift v1's wizard or replace with a cortextOS-aware onboarding
- §7 — Whether to lift v1's tRPC stack or move to Server Actions
