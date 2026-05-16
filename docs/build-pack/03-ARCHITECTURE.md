# 03 · Architecture

**Tech stack, monorepo layout, runtime topology, the cortextOS integration shape, data flow, and the exact swap points. Every recommendation here points at a concrete file in `cortex-os-upstream/` or `intel-force-os/`.**

---

## 1. Tech stack (v2)

| Layer | Choice | Why |
|---|---|---|
| **Language** | TypeScript strict everywhere | cortextOS and v1 both already strict TS; preserve typing |
| **Runtime** | Node 20+ (cortextOS daemon + apps); browser for dashboard | cortextOS requires Node 20+ (install.mjs:84) |
| **Daemon manager** | PM2 | cortextOS depends on it (`ecosystem.config.js` upstream) |
| **Web framework** | Next.js 16, App Router | v1 dashboard is Next 15.5; cortextOS dashboard is Next 14. Standardise on 16. |
| **Bundler / Dev** | Turbopack (Next 16 default) | Fastest HMR; v1 already uses it |
| **Database** | Postgres 16 (Neon recommended) | v1 uses Postgres + Prisma; preserve. pgvector for embeddings. |
| **ORM** | Prisma 6 | v1's choice; works |
| **Graph store** | Postgres property-graph tables + pgvector | Avoids adding a second DB engine. See `04-DATA-MODEL.md` §4 for the schema. |
| **Job queue** | cortextOS's file-bus + crons (no separate Redis/BullMQ) | cortextOS already implements this; don't double-up |
| **Auth** | Clerk (v1 already uses) | Carry forward; works with Next 16 |
| **Styling** | Tailwind v4 + design tokens lifted from v1 | v1's `apps/dashboard/components/shared/` is the source |
| **Testing** | Vitest (unit) + Playwright (e2e) | cortextOS uses both; v1 uses Vitest |
| **Package manager** | pnpm workspaces | v1 uses pnpm; cortextOS uses npm — we standardise on pnpm for the monorepo |
| **Email** | Resend | v1 already uses |
| **Telemetry** | Plausible (marketing) + OpenTelemetry (product) | Privacy-friendly + standard server-side |

**Open decisions** (see `08-OPEN-DECISIONS.md`):
- Hosting: Vercel (apps) + Neon (DB) + Cloudflare R2 (vault files) vs. all-Cloudflare vs. Fly.io for the daemon
- Whether to keep tRPC (v1 has it; works) or move to Next Server Actions only

---

## 2. Monorepo layout

```
CortexOS/                                                     ← /Users/madsadmin/code/CortexOS/
├── pnpm-workspace.yaml
├── package.json                       (root, scripts only)
├── tsconfig.base.json
├── CLAUDE.md
├── .claude/
│   ├── settings.json
│   ├── skills/                        (lift relevant skills from ~/.claude/skills/)
│   ├── agents/                        (Plan, Explore, phase-architect subagent specs)
│   └── commands/                      (slash commands — /load-phase, /search-specs, etc.)
│
├── packages/
│   ├── harness/
│   │   ├── cortextos/                 ← VENDORED from cortex-os-upstream at pinned SHA
│   │   ├── .upstream-version          (text file: SHA + date)
│   │   └── README.md                  (vendor protocol — how to pull upstream)
│   │
│   ├── brain/                         ← NEW. Replaces cortextOS knowledge-base/.
│   │   ├── src/
│   │   │   ├── ingest.ts              (markdown vault → graph)
│   │   │   ├── query.ts               (semantic + graph traversal)
│   │   │   ├── graphify.ts            (entity + relationship extraction)
│   │   │   ├── embeddings.ts          (pgvector adapter)
│   │   │   ├── wiki.ts                (wiki rendering primitives)
│   │   │   └── types.ts
│   │   ├── cli/                       (mirrors cortextOS's bus/kb-*.sh shape)
│   │   │   ├── kb-ingest.ts
│   │   │   ├── kb-query.ts
│   │   │   ├── kb-setup.ts
│   │   │   └── kb-collections.ts
│   │   ├── bus/                       (drop-in shell wrappers that delegate to cli/)
│   │   │   ├── kb-ingest.sh
│   │   │   ├── kb-query.sh
│   │   │   ├── kb-setup.sh
│   │   │   └── kb-collections.sh
│   │   └── tests/
│   │
│   ├── agents/                        ← 11 agent templates, lifted in concept from v1
│   │   ├── templates/
│   │   │   ├── hr-assistant/          (CLAUDE.md + prompts)
│   │   │   ├── proposal-builder/
│   │   │   ├── lead-hunter/
│   │   │   ├── …                       (11 directories total)
│   │   │   └── orchestrator/          (the "Boss")
│   │   ├── catalog.ts                 (the AgentSpec[] from v1 lib/agent-catalog.ts, ported)
│   │   └── prompts/                   (per-agent prompt files)
│   │
│   ├── governance/                    ← draft/approve/escalate logic + audit
│   │   ├── src/
│   │   │   ├── sensitivity.ts         (score classifier)
│   │   │   ├── approvals.ts           (Prisma CRUD on Approval, Escalation)
│   │   │   ├── audit.ts               (audit-event writer)
│   │   │   └── escalations.ts
│   │   └── bus-shims/                 (replace cortextOS bus/create-approval.sh etc.)
│   │
│   ├── db/                            ← Prisma schema + client export
│   │   ├── prisma/schema.prisma
│   │   ├── migrations/
│   │   └── src/index.ts               (export prisma client)
│   │
│   ├── ui/                            ← design system, lifted from v1
│   │   ├── src/
│   │   │   ├── card.tsx
│   │   │   ├── status-pill.tsx
│   │   │   ├── eyebrow.tsx
│   │   │   ├── page-header.tsx
│   │   │   └── …                       (mirrors v1's components/shared/)
│   │   └── tailwind.tokens.css
│   │
│   ├── trpc/                          ← OPTIONAL. Decide in OD-3-2.
│   │   └── …
│   │
│   └── config/                        (shared TS configs, eslint, etc.)
│
├── apps/
│   ├── dashboard/                     ← Next.js 16 product dashboard
│   │   ├── app/
│   │   │   ├── t/[slug]/
│   │   │   │   ├── overview/page.tsx
│   │   │   │   ├── brain/page.tsx     ← THE wiki+graphify view
│   │   │   │   ├── agents/page.tsx
│   │   │   │   ├── approvals/page.tsx
│   │   │   │   ├── activity/page.tsx
│   │   │   │   ├── settings/…
│   │   │   │   └── …
│   │   │   └── layout.tsx
│   │   ├── components/
│   │   │   ├── brain/                 (graph view, wiki view, time-scrubber)
│   │   │   ├── agents/                (agent activity log — lifted from v1)
│   │   │   ├── approvals/
│   │   │   └── …
│   │   └── package.json
│   │
│   ├── daemon/                        ← thin wrapper that boots cortextOS with v2 config
│   │   ├── src/
│   │   │   ├── boot.ts                (loads packages/harness/cortextos and starts)
│   │   │   ├── config.ts              (v2 org + agent configuration)
│   │   │   └── bus-overrides.ts       (paths point bus/ scripts at our brain + governance)
│   │   └── ecosystem.config.js        (PM2 config — adapted from cortextOS upstream)
│   │
│   └── docs/                          ← public docs site (deferred to Phase 3)
│
├── docs/
│   ├── build-pack/                    (this pack)
│   └── adr/                           (architecture decision records)
│
├── infra/
│   ├── neon/                          (DB provisioning notes)
│   ├── pm2/                           (production PM2 config)
│   └── vault-storage/                 (S3 / R2 layout for per-tenant markdown vaults)
│
└── tests/
    ├── integration/
    └── e2e/
```

---

## 3. The cortextOS integration: vendor, don't fork, don't depend-via-npm

### 3.1 The vendor protocol

`packages/harness/cortextos/` is a literal copy of cortex-os-upstream at a pinned SHA. `packages/harness/.upstream-version` records:

```
upstream: https://github.com/grandamenium/cortextos
sha: <SHA>
pulled: 2026-05-16
notes: v0.1.1. First import. Replaced knowledge-base/ with packages/brain/ proxy.
```

**Pulling upstream changes** is an explicit, batched operation:
1. `cd /tmp && git clone https://github.com/grandamenium/cortextos.git`
2. Diff `/tmp/cortextos` against `packages/harness/cortextos/`
3. Cherry-pick the upstream commits we want; skip the ones that conflict with our brain swap
4. Update `.upstream-version` with the new SHA
5. Run v2's full test suite
6. Commit as a single `chore: pull cortextos to <SHA>` commit

Vendor is preferred over npm dependency because cortextOS isn't published as a stable npm package (v0.1.1, no semver guarantee), and we need to override `bus/kb-*.sh` files in place.

### 3.2 The shell-script override pattern

cortextOS agents call `bus/kb-query.sh` etc. After vendoring, our build replaces those files in `packages/harness/cortextos/bus/` with wrappers that delegate to `packages/brain/cli/`. Diff:

```bash
# Before (upstream bus/kb-query.sh): 100+ lines, sources knowledge-base/scripts/mmrag.py
# After (our override):

#!/usr/bin/env bash
# kb-query.sh — Intel Force OS v2 backend (graph + wiki).
# Drop-in replacement for upstream knowledge-base/scripts/mmrag.py interface.
exec node "$(dirname "$0")/../../../brain/cli/kb-query.js" "$@"
```

Same flags, same input, same output shape. Agents notice nothing.

Files to override on first vendor:
- `bus/kb-ingest.sh`
- `bus/kb-query.sh`
- `bus/kb-setup.sh`
- `bus/kb-collections.sh`

Files to *augment* (not replace — cortextOS-owned governance bus stays, but writes flow through to our Prisma):
- `bus/create-approval.sh` → still creates the approval in cortextOS state dir, but also calls a shim that mirrors to Prisma `Approval` table
- `bus/list-approvals.sh` → reads cortextOS state dir (unchanged)
- `bus/update-approval.sh` → same dual-write

### 3.3 Where cortextOS state lives

cortextOS writes state to `~/cortextos/orgs/<org>/<agent>/`. For v2 we override that root via `CTX_FRAMEWORK_ROOT` to a per-tenant directory: e.g. `/var/cortexos/tenants/<tenant-slug>/state/`. The brain vault for that tenant lives at `/var/cortexos/tenants/<tenant-slug>/vault/`.

---

## 4. Runtime topology

```
                  ┌──────────────────────┐
                  │  Telegram bot        │   ← cortextOS native
                  │  (per-org)           │
                  └──────────┬───────────┘
                             │
        ┌────────────────────┴────────────────────┐
        │                                          │
   ┌────▼─────┐                              ┌────▼──────┐
   │ Tenant   │   (cortextOS daemon          │ Web       │
   │ daemon   │    PM2-managed process)     │ Dashboard │
   │ process  │                              │ (Next 16) │
   │          │                              │           │
   │ ┌──────┐ │                              │ Reads:    │
   │ │Orch- │ │   (PTY: Claude Code)         │ - Prisma  │
   │ │estr- │ │                              │ - state   │
   │ │ator  │ │                              │   dirs    │
   │ └──┬───┘ │   ┌──────────────┐           │ - Brain   │
   │    │     ├──▶│ Specialist   │           │   API     │
   │    ├─────┤   │ agents (×11) │           └─────┬─────┘
   │    │     │   │ (PTY each)   │                 │
   │    │     │   └──────┬───────┘                 │
   │    │     │          │ bus/*.sh calls          │
   │    │     │          ▼                         │
   │    │     │   ┌──────────────┐                 │
   │    │     │   │ Brain CLI    │◀────────────────┤
   │    │     │   │ (Node)       │                 │
   │    │     │   └──────┬───────┘                 │
   │    │     │          │                         │
   │    │     │          ▼                         │
   │    │     │   ┌──────────────────────────────┐ │
   │    │     │   │ Postgres + pgvector + vault   │◀┘
   │    │     │   │ (per-tenant DB schemas;       │
   │    │     │   │  vault on R2/S3 + local fs)  │
   │    │     │   └──────────────────────────────┘
   │    │     │
   │    ▼     │
   │  Governance bus (creates Prisma rows + state files)
   └──────────┘
```

One daemon process per tenant in production. Each daemon manages its agents' PTY sessions. Multi-tenancy is process-level isolation, not row-level — same pattern v1 was moving toward in Phase 3 spec.

---

## 5. Data flow examples

### 5.1 An employee asks an HR question (Teams or Telegram)

```
User → Telegram (or Teams via bus/teams-receive.sh which we add later)
     → cortextOS daemon catches inbound, routes to HR Assistant PTY
     → HR Assistant agent calls bus/kb-query.sh "carry-over policy"
       → packages/brain/cli/kb-query.js
         → packages/brain/src/query.ts
           → semantic search (pgvector) + graph traversal
           → returns ranked wiki snippets with paths
     → agent drafts reply, calls bus/create-approval.sh
       → cortextOS state-dir write + our shim mirrors to Prisma Approval
     → bus/send-message.sh notifies the operator (Telegram + dashboard)
Operator → opens dashboard /approvals OR replies "approve" in Telegram
        → bus/update-approval.sh → Prisma write + state-dir write
        → HR Assistant sends final reply through the original channel
```

### 5.2 The customer uploads a new handbook section

```
Dashboard upload → packages/brain/cli/kb-ingest.js
                 → graphify pipeline extracts entities + relationships
                 → markdown page written to vault: /vault/handbook/leave-policy.md
                 → graph nodes + edges written to Postgres
                 → embeddings computed + stored
                 → "+47 facts, +12% density" growth event broadcast
                 → dashboard /brain view refreshes; graph visually densifies
```

### 5.3 A 9am cron fires "morning inbox sweep"

```
PM2 + cortextOS cron triggers Orchestrator
Orchestrator decomposes: "review overnight HR inbox, surface needs-judgement items"
Orchestrator routes tasks to:
  - HR Assistant (read + draft pending replies)
  - Email Handler (classify + flag escalations)
Both write outputs through bus/create-task.sh + bus/create-approval.sh
Reporting agent runs at 9:05: bus/send-message.sh Telegram with morning brief
Operator gets a single Telegram message:
  "Overnight: 12 routine HR queries drafted (low sensitivity). 1 grievance
  escalated — no draft. 0 errors. Open /approvals to review."
```

---

## 6. The wiki+graphify brain — internal architecture

### 6.1 The vault (filesystem)

Per-tenant markdown vault on disk (mounted from R2/S3 in prod, local fs in dev):

```
/vault/<tenant-slug>/
├── README.md                          (auto-generated index)
├── handbook/
│   ├── leave-policy.md
│   ├── sickness-policy.md
│   └── …
├── proposals/
│   ├── 2026-04-slate-acquisitions.md
│   └── …
├── people/
│   ├── sarah-stevens.md               (one page per person in the org)
│   └── …
├── voice/
│   └── voice-profile.md
└── _meta/
    ├── graph.json                     (cached graph for fast cold reads)
    └── stats.json                     (density, fact-count, weekly delta)
```

Round-trip safe: a power user can edit any .md file in Obsidian and the next `kb-ingest` run picks up the changes.

### 6.2 The graph (Postgres)

Three tables in addition to standard relational data:

```sql
-- nodes: anything graphify extracts. Person, Policy, Account, Concept, etc.
CREATE TABLE brain_nodes (
  id          UUID PRIMARY KEY,
  tenant_id   UUID NOT NULL REFERENCES tenants(id),
  kind        TEXT NOT NULL,            -- 'person' | 'policy' | 'concept' | …
  label       TEXT NOT NULL,
  page_path   TEXT,                     -- /vault/<tenant>/handbook/leave-policy.md
  attrs       JSONB NOT NULL DEFAULT '{}',
  embedding   VECTOR(1536),
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- edges: directed relationships between nodes
CREATE TABLE brain_edges (
  id           UUID PRIMARY KEY,
  tenant_id    UUID NOT NULL REFERENCES tenants(id),
  src_id       UUID NOT NULL REFERENCES brain_nodes(id) ON DELETE CASCADE,
  dst_id       UUID NOT NULL REFERENCES brain_nodes(id) ON DELETE CASCADE,
  kind         TEXT NOT NULL,           -- 'mentions' | 'governs' | 'replaces' | …
  weight       FLOAT NOT NULL DEFAULT 1.0,
  attrs        JSONB NOT NULL DEFAULT '{}',
  created_at   TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX brain_edges_src_idx ON brain_edges(src_id);
CREATE INDEX brain_edges_dst_idx ON brain_edges(dst_id);
CREATE INDEX brain_nodes_tenant_kind_idx ON brain_nodes(tenant_id, kind);
CREATE INDEX brain_nodes_embedding_idx ON brain_nodes USING hnsw (embedding vector_cosine_ops);
```

Plus a weekly density snapshot table for the "+12% denser this week" stat:

```sql
CREATE TABLE brain_density_snapshots (
  tenant_id   UUID NOT NULL,
  taken_at    DATE NOT NULL,
  node_count  INT NOT NULL,
  edge_count  INT NOT NULL,
  PRIMARY KEY (tenant_id, taken_at)
);
```

### 6.3 The graphify pipeline (ingest flow)

```typescript
// packages/brain/src/ingest.ts
export async function ingest(tenantId: string, pagePath: string, markdown: string) {
  // 1. Parse markdown → AST
  const ast = parseMarkdown(markdown);

  // 2. Extract entities via Claude (or local NER for cost)
  //    Persons, policies, concepts, accounts mentioned in the page
  const entities = await extractEntities(ast);

  // 3. Extract relationships
  //    "Sarah governs leave-policy"; "leave-policy replaces 2024-policy"
  const relationships = await extractRelationships(ast, entities);

  // 4. Compute embedding for the page + each entity
  const embeddings = await embed([markdown, ...entities.map(e => e.label)]);

  // 5. Upsert nodes + edges in a single transaction
  await db.$transaction(async (tx) => {
    for (const entity of entities) {
      await tx.brainNode.upsert({ … });
    }
    for (const rel of relationships) {
      await tx.brainEdge.upsert({ … });
    }
  });

  // 6. Emit growth event for the dashboard
  await emit('brain.densified', { tenantId, addedNodes, addedEdges });
}
```

### 6.4 The query interface

```typescript
// packages/brain/src/query.ts
export async function query(tenantId: string, question: string, opts: QueryOpts) {
  // 1. Embed the question
  const qEmb = await embedOne(question);

  // 2. ANN search for top-K nodes
  const candidates = await pgvectorSearch(tenantId, qEmb, opts.topK ?? 5);

  // 3. Expand via graph neighbours (1-hop) to enrich context
  const enriched = await expandGraph(candidates, { hops: 1 });

  // 4. Pull the markdown pages for the surviving nodes
  const pages = await loadPages(enriched);

  // 5. Return either: structured JSON (--json flag) or formatted text
  return opts.json ? { results: enriched, pages } : formatText(enriched, pages);
}
```

This is what `bus/kb-query.sh` ultimately calls. Drop-in compatible with cortextOS's expected interface.

---

## 7. Dashboard architecture

### 7.1 Routes

```
apps/dashboard/app/t/[slug]/
├── page.tsx                  (overview)
├── brain/
│   ├── page.tsx              (graph view — the centrepiece)
│   ├── wiki/[…path]/page.tsx (wiki view)
│   └── search/page.tsx
├── agents/
│   ├── page.tsx              (agent fleet + activity)
│   └── [key]/page.tsx        (per-agent inspector)
├── approvals/page.tsx
├── activity/page.tsx         (the agent activity log we just shipped in v1 — lift it)
├── analytics/page.tsx
├── knowledge/page.tsx        (legacy alias for /brain)
└── settings/
    └── …
```

### 7.2 The Brain graph view (`/brain`)

Stack: **Cosmograph** (v1 already uses it — `@cosmograph/cosmograph` and `@cosmograph/react`). Reuse.

```tsx
// apps/dashboard/components/brain/graph-view.tsx
import { Cosmograph } from '@cosmograph/react';
// fetch nodes + edges via server action that hits packages/brain/
// pass to Cosmograph with cluster colouring + click handlers
```

Acceptance criteria for "looks stunning" in `02-PRODUCT-VISION.md` §7.

### 7.3 The wiki view (`/brain/wiki/<path>`)

Stack: **MDX + custom Obsidian-style renderer.** Backlink computation done server-side from the graph table; wiki page renders with sidebars showing inbound/outbound links.

### 7.4 The activity log (`/activity`)

**Lift directly from v1.** `intel-force-os/apps/dashboard/components/operations/agent-activity-log.tsx` is exactly what we want. Migrate to v2 with imports rewired (Director colours, status pills, expand-in-place all stay). One refactor: data source becomes `packages/brain/` + Prisma instead of v1's invocation table.

---

## 8. Telegram + iOS

cortextOS ships native Telegram bot per-org. v2 inherits this. Telegram becomes the primary mobile-control surface — see `02-PRODUCT-VISION.md` §Cortex.

iOS app is **out of scope** for v1 of v2 (see `08-OPEN-DECISIONS.md` §4). cortextOS's roadmap mentions it; we defer until v2 has paying customers asking.

---

## 9. Hosting recommendation

| Component | Where |
|---|---|
| Daemon process (cortextOS PM2) | **Fly.io** dedicated VM per tenant (or k8s later). Cloudflare Workers can't run PM2; Vercel can't run long-lived PTY. |
| Web dashboard (Next 16) | **Vercel** (or Cloudflare Pages — Next 16 SSR works on both) |
| Postgres + pgvector | **Neon** |
| Vault file storage | **Cloudflare R2** (cheaper egress than S3; UK presence) |
| Email | Resend |
| Telegram | cortextOS-native (uses Telegram Bot API directly) |

Alternative: all-Cloudflare (Pages + Workers + R2 + D1) — possible if daemon moves to a separate Fly.io / fly machine and the dashboard stays simple. See `08-OPEN-DECISIONS.md` §6.

---

## 10. What this architecture intentionally does NOT do

- Does not run cortextOS daemons in serverless. They're long-lived PTY processes; serverless is wrong.
- Does not duplicate the bus interface. Same shell scripts cortextOS uses; only backends differ.
- Does not introduce a separate graph database (Neo4j etc.). Postgres + property tables is sufficient at our scale; revisit at 1M+ nodes per tenant, which is years away.
- Does not preserve v1's Cloudflare Worker bot runtime. It's not portable.
- Does not preserve v1's Teams-first channel posture. Teams comes in Phase 3 if a customer demands it.
- Does not lift v1's tRPC server unchanged. Default is yes (re-adopt), but the schema layer is rebuilt.

---

## 11. Acceptance for this architecture

Before Phase 0 starts:

- [ ] Founder accepts the four-pillar model from `02-PRODUCT-VISION.md`
- [ ] Vendor-not-fork is accepted (`01-RECOMMENDATION.md`)
- [ ] Postgres + pgvector + property-graph tables is accepted (vs. Neo4j alternative)
- [ ] Cosmograph for the graph view is accepted (vs. d3 / vis.js / Sigma)
- [ ] Fly.io for the daemon is accepted (vs. all-Cloudflare with separate runner)
- [ ] Codex reviews this file and returns a delta — applied before Phase 0 codes
