# 06 · Build Plan

**Phased slices, A/B/C-style. Each phase has a focused goal, a stack of slices, acceptance criteria, and a ratification step through Codex. The plan optimises for "ship a thing each phase that the founder can see working", not for breadth.**

---

## The phases at a glance

| Phase | Goal | Duration target | Ratification gate |
|---|---|---|---|
| **Phase 0** | Scaffold + vendor cortextOS + boot a single agent | 1 focused build session | Codex review of `03-ARCHITECTURE.md` deltas applied |
| **Phase 1** | Brain swap — replace mmrag with wiki+graphify behind the bus interface | 2–3 focused sessions | Codex review of the swap; vault ingest happy-path tested |
| **Phase 2** | Dashboard — lift v1 chrome, build brain views, build agent activity, wire approvals | 3–4 sessions | Founder review of UI; brain view passes "stunning" criteria |
| **Phase 3** | Parity + migration — port remaining v1 surfaces, run first v1→v2 migration | 2–3 sessions | A real (or simulated) v1 tenant migrated end-to-end |

Total: ~8–13 focused sessions if scope holds. The discipline is to not slip Phase 1 into Phase 2 or Phase 3 features upward.

---

## Phase 0 — Scaffold + vendor

**Goal:** A v2 codebase that boots a cortextOS daemon with one Orchestrator agent that can send a Telegram message saying "Phase 0 alive". No brain, no dashboard, no governance yet. Just the bones standing up.

### Slices

**P0.S1 — Monorepo scaffold**
- Initialise pnpm workspace at `/Users/madsadmin/code/CortexOS/`
- Top-level `package.json`, `pnpm-workspace.yaml`, `tsconfig.base.json`
- Empty `packages/{harness,brain,agents,governance,db,ui}/` and `apps/{dashboard,daemon}/`
- Each package has `package.json` + `tsconfig.json` + `src/index.ts` stub
- Root scripts: `pnpm dev`, `pnpm build`, `pnpm typecheck`
- Commit: `chore(phase-0): monorepo scaffold`

**P0.S2 — Vendor cortextOS**
- Copy `/Users/madsadmin/code/cortex-os-upstream/` → `packages/harness/cortextos/`
- Write `packages/harness/.upstream-version` (SHA + date)
- Strip `dashboard/` and `knowledge-base/scripts/mmrag.py` from the vendored copy (saves repo size; we don't use them)
- Run `npm install && npm run build` inside `packages/harness/cortextos/` to produce `dist/`
- Add `packages/harness/cortextos` to root `.gitignore` for `node_modules/`
- Commit: `chore(phase-0): vendor cortextos at <SHA>`

**P0.S3 — Daemon wrapper (apps/daemon)**
- `apps/daemon/src/boot.ts` — loads vendored cortextOS, applies env overrides for `CTX_FRAMEWORK_ROOT`
- `apps/daemon/src/config.ts` — defines a hard-coded "dev" tenant for Phase 0 (no DB yet)
- `apps/daemon/ecosystem.config.js` — PM2 config that runs `node dist/boot.js`
- Commit: `feat(phase-0): daemon wrapper boots cortextos`

**P0.S4 — One agent, one message**
- Create a single Orchestrator agent for the dev tenant via cortextOS's CLI
- Wire Telegram bot token via `.env.local`
- Boot daemon: `pnpm pm2 start apps/daemon/ecosystem.config.js`
- Verify: Orchestrator sends a Telegram message "Phase 0 alive — <timestamp>"
- Commit: `feat(phase-0): orchestrator sends hello message`

**P0.S5 — Empty Postgres + Prisma scaffold**
- Spin up local Postgres 16 (Docker compose at `infra/docker-compose.dev.yml`)
- `packages/db/prisma/schema.prisma` with just `Tenant` + `User` models for now
- Run `prisma migrate dev --name init`
- Commit: `feat(phase-0): db scaffold + tenants`

### Acceptance for Phase 0

- [ ] `pnpm typecheck` passes across the monorepo
- [ ] `pnpm pm2 start` boots the daemon
- [ ] Orchestrator sends one Telegram message visible in the configured chat
- [ ] `prisma migrate dev` cleanly creates Tenant + User tables
- [ ] Repository has 1 commit per slice + Codex review delta applied as a final commit
- [ ] CLAUDE.md updated with "Phase 0 complete, Phase 1 next"

**Time check:** if Phase 0 is approaching 2 sessions, stop and ask why. Likely cause is environmental (PM2 setup, Telegram bot creation). Don't push through; debug the environment, then resume.

---

## Phase 1 — Brain swap (the centrepiece)

**Goal:** Replace the cortextOS knowledge-base subsystem with the wiki+graphify brain. Same shell-script interface. Any cortextOS agent that calls `bus/kb-query.sh` gets results from our backend.

### Slices

**P1.S1 — Brain package skeleton**
- `packages/brain/src/{ingest,query,graphify,embeddings,wiki,types}.ts` — stubs that compile
- `packages/brain/cli/{kb-ingest,kb-query,kb-setup,kb-collections}.ts` — CLI entry points using a small `commander` setup
- `packages/brain/tsup.config.ts` — bundles CLI to `dist/`
- Commit: `feat(brain): package skeleton`

**P1.S2 — Brain schema migration**
- SQL migration `packages/brain/migrations/0001_init.sql` creating `brain.nodes`, `brain.edges`, `brain.density_snapshots`, `brain.ingestion_log`
- Install pgvector extension
- Apply via `psql` (Prisma doesn't manage this schema)
- Commit: `feat(brain): graph schema + pgvector`

**P1.S3 — Vault layout + ingest pipeline**
- `packages/brain/src/ingest.ts` — full implementation per `03-ARCHITECTURE.md` §6.3
- Wire to Claude API for entity + relationship extraction (use Anthropic SDK already in v1)
- Wire to OpenAI text-embedding-3-small (or Voyage — decide in `08-OPEN-DECISIONS.md` §6)
- Idempotent: re-running on the same page produces the same nodes/edges
- Tests: ingest a hand-crafted handbook.md, assert expected nodes + edges
- Commit: `feat(brain): ingest pipeline`

**P1.S4 — Query layer**
- `packages/brain/src/query.ts` — full implementation per `03-ARCHITECTURE.md` §6.4
- pgvector ANN search + 1-hop graph expansion
- Output formats: `--json` (structured) and default (text)
- Tests: query against ingested fixture, assert top-K plausibility
- Commit: `feat(brain): query layer`

**P1.S5 — Shell-script overrides**
- Wrappers at `packages/brain/bus/kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`, `kb-collections.sh`
- Each one is 5-line bash that delegates to `node packages/brain/cli/<cmd>.js "$@"`
- Symlink (or copy) into `packages/harness/cortextos/bus/` overriding the upstream files
- Test: run `bash packages/harness/cortextos/bus/kb-query.sh "carry-over policy"` and get a valid response
- Commit: `feat(brain): bus override scripts`

**P1.S6 — Wiki rendering primitives**
- `packages/brain/src/wiki.ts` — markdown → rendered HTML with backlinks, callouts, footnotes
- Used both server-side (when the dashboard renders a wiki page) and CLI-side (for `kb-query --json` to include rendered context)
- Commit: `feat(brain): wiki rendering`

**P1.S7 — Density snapshots cron**
- Daily job (cortextOS cron via `bus/create-task.sh` with schedule) that runs `packages/brain/cli/snapshot-density.ts`
- Writes a row to `brain.density_snapshots`
- Computes the "+12% this week" stat by diffing latest vs 7-days-ago
- Commit: `feat(brain): density tracking`

### Acceptance for Phase 1

- [ ] An agent in cortextOS can call `bus/kb-query.sh "<question>"` and receive valid results
- [ ] `bus/kb-ingest.sh /path/to/handbook.md` adds nodes + edges visible in Postgres
- [ ] `brain.density_snapshots` has at least 2 entries (today + simulated last-week)
- [ ] All four kb-* shell scripts pass interface-compatibility tests vs upstream signatures
- [ ] No upstream cortextOS code is modified outside the four bus overrides
- [ ] Codex reviews the brain package and returns a delta — applied
- [ ] CLAUDE.md updated: "Phase 1 complete, Phase 2 next"

---

## Phase 2 — Dashboard

**Goal:** A functional Next.js 16 dashboard at `apps/dashboard/` with: Overview, Brain (graph + wiki views), Agents (activity log), Approvals, Activity (audit log), Analytics, Settings. Lifted chrome from v1, new brain visualisations.

### Slices

**P2.S1 — Next.js 16 app scaffold + auth**
- `pnpm dlx create-next-app@latest apps/dashboard` (or manual)
- Wire Clerk (lift from v1's setup)
- Tenant-slug routing: `app/t/[slug]/layout.tsx`
- Commit: `feat(dashboard): scaffold + auth`

**P2.S2 — UI primitives package**
- Lift every component listed in `05-MIGRATION-MAP.md` §1.1 (KEEP rows)
- Mount `packages/ui/` and re-export from `@cortex/ui`
- Tailwind v4 config in dashboard imports from `packages/ui/tailwind.tokens.css`
- Commit: `feat(ui): lift primitives from v1`

**P2.S3 — Sidebar nav + tenant chrome**
- Lift `apps/dashboard/components/shared/nav.tsx` and sidebar context
- Adapt route list for v2: Overview, Brain, Agents, Approvals, Activity, Analytics, Settings
- Commit: `feat(dashboard): nav + chrome`

**P2.S4 — Brain graph view (the centrepiece)**
- Install `@cosmograph/react`, `@cosmograph/cosmograph`
- `apps/dashboard/components/brain/graph-view.tsx` — fetches nodes + edges via server action that calls `packages/brain/src/query.ts`
- Acceptance criteria from `02-PRODUCT-VISION.md` §"What 'looks stunning' means": force-directed, community clustering, zoomable, hover tooltip, click → side drawer, search bar, growth stat, time scrubber
- Commit: `feat(dashboard): brain graph view`

**P2.S5 — Brain wiki view**
- `apps/dashboard/app/t/[slug]/brain/wiki/[...path]/page.tsx`
- Reads markdown from the vault filesystem, renders with `packages/brain/src/wiki.ts`
- Sidebars: inbound backlinks (left), outbound links (right)
- Edit-in-place writes back to the .md file
- Commit: `feat(dashboard): brain wiki view`

**P2.S6 — Agent activity log**
- Lift `apps/dashboard/components/operations/agent-activity-log.tsx` from v1 (the recent UI work)
- Lift `apps/dashboard/lib/agent-activity.ts` — rewire to read Prisma `invocations` + cortextOS state dir
- Mount on `apps/dashboard/app/t/[slug]/agents/page.tsx`
- Commit: `feat(dashboard): agent activity log`

**P2.S7 — Approvals queue**
- Lift `apps/dashboard/app/t/[slug]/approvals/page.tsx` + supporting components
- Server actions for approve/edit/reject — call `packages/governance/src/approvals.ts` → Prisma + cortextOS bus dual-write
- Commit: `feat(dashboard): approvals queue`

**P2.S8 — Activity (audit log)**
- Lift the audit-log half of v1's `apps/dashboard/app/t/[slug]/activity/page.tsx`
- The agent activity log section from §P2.S6 sits above it (same v1 pattern)
- Commit: `feat(dashboard): audit log view`

**P2.S9 — Analytics page**
- Lift `apps/dashboard/app/t/[slug]/analytics/page.tsx` + recharts components
- Adapt queries to v2 schema (`Invocation`, `Approval`, `Escalation` rollups)
- Commit: `feat(dashboard): analytics`

**P2.S10 — Settings panels (7)**
- Lift all panels from v1
- API keys, notifications, integrations, tenant, billing, security, advanced
- Commit: `feat(dashboard): settings`

**P2.S11 — Overview page**
- KPI tiles + greeting + approvals preview + activity preview
- Commit: `feat(dashboard): overview`

### Acceptance for Phase 2

- [ ] All seven routes render with real data from v2 backend
- [ ] Brain graph view passes the 10-item "stunning" checklist from `02-PRODUCT-VISION.md`
- [ ] Approvals UI: approve from web → cortextOS state dir reflects the change (dual-write working)
- [ ] Agent activity log shows 11 agents grouped by director (HR / Sales / Marketing / Operations)
- [ ] Founder reviews the UI in person; signs off on visual + interaction quality
- [ ] CLAUDE.md updated: "Phase 2 complete, Phase 3 next"

---

## Phase 3 — Parity + migration

**Goal:** Whatever's left for feature parity with v1 + the first end-to-end v1→v2 customer migration (real or simulated).

### Slices

**P3.S1 — Onboarding wizard**
- Lift v1's wizard structure (`apps/dashboard/app/t/[slug]/wizard/`)
- Adapt steps for v2: tool connections, voice profile capture, agent selection (which of the 11 to enable), Telegram bot creation, first ingest
- Commit: `feat(onboarding): wizard`

**P3.S2 — Per-tenant daemon spawning**
- `infra/pm2/ecosystem.config.js` generator — accepts a tenant slug, produces a PM2 config that spawns a tenant-isolated daemon
- Trigger: when a tenant moves from PROVISIONING to ACTIVE, spawn its daemon
- Commit: `feat(infra): per-tenant daemon`

**P3.S3 — Migration script**
- `infra/migrate/v1-to-v2.ts` per `04-DATA-MODEL.md` §8
- Inputs: v1 tenant slug; v2 destination
- Steps: export v1 data → provision v2 tenant → ingest into brain → boot daemon → cutover DNS
- Idempotent + resumable
- Tests: migrate a fixture v1 tenant end-to-end
- Commit: `feat(migrate): v1-to-v2 pipeline`

**P3.S4 — Teams adapter (deferred to here)**
- If a v1 customer relies on Teams (likely yes for HR Agent), implement a Teams-receive script that puts inbound Teams messages on the cortextOS bus
- Lift `intel-force-os/src/bot/` logic conceptually; rewrite as a cortextOS-native handler
- Commit: `feat(channels): teams adapter`

**P3.S5 — First migration**
- Choose a v1 tenant (a demo or a real founding customer who's opted in)
- Run the migration script
- Verify: customer can log in to v2, sees their brain populated, agents drafting, approvals queue populated, Telegram works
- Commit: `chore(migrate): first customer on v2`

### Acceptance for Phase 3

- [ ] One real v1 tenant fully migrated to v2 and operating
- [ ] Migration script is rerunnable on the same tenant without breaking
- [ ] Per-tenant daemon spawning works (verify with 3 fake tenants spawned simultaneously)
- [ ] CLAUDE.md updated: "Phase 3 complete. v2 live."

---

## Beyond Phase 3 (not in scope of this pack)

- Marketing site rewrite (port v1 marketing copy to v2 brand if rebranded)
- iOS app (cortextOS roadmap item)
- Theta-wave autoresearch integration in product UX
- Multi-region deployment (Fly.io regions)
- SOC 2 audit prep
- Stripe billing flow

These are real, but not Phase 0–3. Calling them out so the implementer doesn't sneak them in.

---

## How phases interact with Codex

After each Phase's slices are committed:

1. Bundle the changed files (or just the PR diff) + the relevant build-pack files (`03-`, `04-`, `05-` mostly)
2. Hand to Codex with the prompt: *"Pressure-test this phase's implementation against the build pack. Surface deviations, weak abstractions, missing tests, latent bugs. Return a delta document."*
3. Apply Codex's delta as a final commit on the phase
4. Move to the next phase

This is the "ratify through Codex" ritual the founder wants. It catches things Claude Code missed; Claude Code catches things Codex missed. Both together = the closest thing to a one-shot.

---

## Working agreements during the build

- **One phase at a time.** No starting Phase 2 work while Phase 1 is in flight.
- **One slice at a time.** No starting P2.S5 while P2.S4 is half-written.
- **Commit per slice.** Each slice closes with a passing typecheck + at least minimal test + commit.
- **Reference, don't re-spec.** When implementing P2.S4, open `02-PRODUCT-VISION.md` §7 and `03-ARCHITECTURE.md` §7.2 — implement against them. Don't relitigate.
- **Update CLAUDE.md at phase boundaries.** Future Claude Code sessions need to see "Phase X complete" to orient.
- **Stop when blocked, don't sprawl.** If a slice can't ship, capture the blocker in `08-OPEN-DECISIONS.md` and pause. Better than half-done slices.
