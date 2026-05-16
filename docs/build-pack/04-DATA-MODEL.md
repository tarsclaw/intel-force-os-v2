# 04 · Data Model

**The hybrid persistence model. Prisma for governance (tenants, users, approvals, audit, escalations). Postgres property-graph + pgvector for the brain. File-bus state directories for cortextOS-owned runtime telemetry. The vault on disk (R2 in prod). How they coexist, who owns what.**

---

## 1. The three stores

| Store | Owner | What lives here |
|---|---|---|
| **Postgres (Prisma)** | `packages/db/` | Tenants, users, approvals, audit events, escalations, invocations, costs. The governance backbone. |
| **Postgres (graph tables + pgvector)** | `packages/brain/` | Brain nodes, edges, embeddings, density snapshots. Same DB instance, separate concern. |
| **File-bus state directories** | cortextOS (vendored) | Real-time agent telemetry — tasks, heartbeats, conversation buffers, cron schedules. Lives at `/var/cortexos/tenants/<slug>/state/`. |
| **Markdown vault** | `packages/brain/` | Per-tenant Obsidian-shaped vault. Source of truth for human-readable content. Lives at `/var/cortexos/tenants/<slug>/vault/` (local fs) or R2 bucket in prod. |

The graph tables and the governance tables live in the **same Postgres instance** under different schemas (`governance`, `brain`). Single connection pool, single backup target, single migration tool. Simpler than running two databases.

---

## 2. Prisma schema (governance side)

```prisma
// packages/db/prisma/schema.prisma

generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["multiSchema"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  schemas  = ["governance", "brain", "ops"]
}

// ── tenants + users ────────────────────────────────────────────────────────
model Tenant {
  id              String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  slug            String   @unique
  name            String
  plan            Plan     @default(STARTER)
  status          TenantStatus @default(ACTIVE)
  vaultPath       String   @map("vault_path")    // e.g. /var/cortexos/tenants/<slug>/vault
  statePath       String   @map("state_path")    // e.g. /var/cortexos/tenants/<slug>/state
  createdAt       DateTime @default(now()) @map("created_at")
  updatedAt       DateTime @updatedAt @map("updated_at")

  users           User[]
  approvals       Approval[]
  escalations     Escalation[]
  auditEvents     AuditEvent[]
  invocations     Invocation[]
  brainNodes      BrainNode[]
  brainEdges      BrainEdge[]

  @@map("tenants")
  @@schema("governance")
}

model User {
  id          String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  tenantId    String   @map("tenant_id") @db.Uuid
  clerkId     String   @unique @map("clerk_id")
  email       String
  name        String?
  role        Role     @default(MEMBER)
  createdAt   DateTime @default(now()) @map("created_at")

  tenant      Tenant   @relation(fields: [tenantId], references: [id])

  @@index([tenantId])
  @@map("users")
  @@schema("governance")
}

// ── approvals + escalations + audit ────────────────────────────────────────
model Approval {
  id              String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  tenantId        String   @map("tenant_id") @db.Uuid
  agentKey        String   @map("agent_key")            // matches catalog
  draftMarkdown   String   @map("draft_markdown")
  context         Json?                                 // trigger metadata
  sensitivityScore Float   @map("sensitivity_score")    // 0..1
  status          ApprovalStatus @default(PENDING)
  decidedById     String?  @map("decided_by_id") @db.Uuid
  decidedAt       DateTime? @map("decided_at")
  edits           String?                                // operator edits before send
  createdAt       DateTime @default(now()) @map("created_at")
  updatedAt       DateTime @updatedAt @map("updated_at")

  // back-link to cortextOS state-dir file path so we can reconcile if needed
  busFilePath     String?  @map("bus_file_path")

  tenant          Tenant   @relation(fields: [tenantId], references: [id])

  @@index([tenantId, status])
  @@index([tenantId, createdAt(sort: Desc)])
  @@map("approvals")
  @@schema("governance")
}

model Escalation {
  id              String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  tenantId        String   @map("tenant_id") @db.Uuid
  agentKey        String   @map("agent_key")
  category        String   // 'grievance' | 'resignation' | 'salary' | …
  severity        EscalationSeverity @default(MEDIUM)
  status          EscalationStatus @default(OPEN)
  originalMessage String   @map("original_message")
  reasoning       String?
  resolvedById    String?  @map("resolved_by_id") @db.Uuid
  resolvedAt      DateTime? @map("resolved_at")
  resolution      String?
  createdAt       DateTime @default(now()) @map("created_at")
  updatedAt       DateTime @updatedAt @map("updated_at")

  tenant          Tenant   @relation(fields: [tenantId], references: [id])

  @@index([tenantId, status])
  @@map("escalations")
  @@schema("governance")
}

model AuditEvent {
  id          String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  tenantId    String?  @map("tenant_id") @db.Uuid
  actorId     String?  @map("actor_id") @db.Uuid
  actorKind   ActorKind @map("actor_kind")
  actorLabel  String?  @map("actor_label")
  action      String                                    // 'approval.granted' | 'agent.invoked' | …
  targetKind  String?  @map("target_kind")
  targetId    String?  @map("target_id")
  targetLabel String?  @map("target_label")
  detail      String?
  metadata    Json?
  severity    AuditSeverity @default(INFO)
  createdAt   DateTime @default(now()) @map("created_at")

  tenant      Tenant?  @relation(fields: [tenantId], references: [id])

  @@index([tenantId, createdAt(sort: Desc)])
  @@index([severity, createdAt(sort: Desc)])
  @@map("audit_log")
  @@schema("ops")
}

// ── invocations (cortextOS agent runs, mirrored from file bus) ────────────
model Invocation {
  id           String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  tenantId     String   @map("tenant_id") @db.Uuid
  agentKey     String   @map("agent_key")
  trigger      String                                   // cron | message | webhook | manual
  status       InvocationStatus @default(RUNNING)
  startedAt    DateTime @default(now()) @map("started_at")
  completedAt  DateTime? @map("completed_at")
  durationMs   Int?     @map("duration_ms")
  inputTokens  Int?     @map("input_tokens")
  outputTokens Int?     @map("output_tokens")
  costGbp      Decimal? @map("cost_gbp") @db.Decimal(10, 6)
  model        String?
  runtime      String?                                  // 'claude-code' | 'codex-app-server'
  busTaskPath  String?  @map("bus_task_path")           // back-link to cortextOS state file
  metadata     Json?

  tenant       Tenant   @relation(fields: [tenantId], references: [id])

  @@index([tenantId, startedAt(sort: Desc)])
  @@index([tenantId, agentKey, startedAt(sort: Desc)])
  @@map("invocations")
  @@schema("ops")
}

// ── enums ─────────────────────────────────────────────────────────────────
enum Plan      { STARTER  GROWTH  SCALE  ENTERPRISE                  @@schema("governance") }
enum TenantStatus { ACTIVE  SUSPENDED  ARCHIVED                       @@schema("governance") }
enum Role      { OWNER  ADMIN  MEMBER  VIEWER                         @@schema("governance") }
enum ApprovalStatus { PENDING  APPROVED  EDITED_AND_SENT  REJECTED    @@schema("governance") }
enum EscalationSeverity { LOW  MEDIUM  HIGH  CRITICAL                 @@schema("governance") }
enum EscalationStatus   { OPEN  IN_PROGRESS  RESOLVED  CLOSED        @@schema("governance") }
enum ActorKind { USER  AGENT  SYSTEM                                  @@schema("ops") }
enum AuditSeverity { INFO  WARN  ERROR  CRITICAL                      @@schema("ops") }
enum InvocationStatus  { RUNNING  COMPLETED  FAILED  CANCELLED        @@schema("ops") }
```

---

## 3. Brain schema (graph + vectors)

Lives in the `brain` Postgres schema (same DB instance, different namespace). Not modelled in Prisma directly — Prisma's graph support is weak. Use raw SQL migrations + a thin TypeScript query layer in `packages/brain/src/`.

```sql
-- packages/brain/migrations/0001_init.sql
CREATE SCHEMA IF NOT EXISTS brain;
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE brain.nodes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   UUID NOT NULL,
  kind        TEXT NOT NULL,           -- 'person' | 'policy' | 'concept' | 'product' | 'account' | …
  label       TEXT NOT NULL,
  page_path   TEXT,                    -- relative path inside vault, e.g. handbook/leave-policy.md
  attrs       JSONB NOT NULL DEFAULT '{}',
  embedding   VECTOR(1536),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX nodes_tenant_kind_idx ON brain.nodes(tenant_id, kind);
CREATE INDEX nodes_page_path_idx ON brain.nodes(tenant_id, page_path);
CREATE INDEX nodes_embedding_idx ON brain.nodes USING hnsw (embedding vector_cosine_ops);

CREATE TABLE brain.edges (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    UUID NOT NULL,
  src_id       UUID NOT NULL REFERENCES brain.nodes(id) ON DELETE CASCADE,
  dst_id       UUID NOT NULL REFERENCES brain.nodes(id) ON DELETE CASCADE,
  kind         TEXT NOT NULL,          -- 'mentions' | 'governs' | 'replaces' | 'owns' | 'reports-to' | …
  weight       REAL NOT NULL DEFAULT 1.0,
  attrs        JSONB NOT NULL DEFAULT '{}',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX edges_src_idx ON brain.edges(src_id);
CREATE INDEX edges_dst_idx ON brain.edges(dst_id);
CREATE INDEX edges_tenant_kind_idx ON brain.edges(tenant_id, kind);

CREATE TABLE brain.density_snapshots (
  tenant_id    UUID NOT NULL,
  taken_at     DATE NOT NULL,
  node_count   INT NOT NULL,
  edge_count   INT NOT NULL,
  PRIMARY KEY (tenant_id, taken_at)
);

CREATE TABLE brain.ingestion_log (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    UUID NOT NULL,
  page_path    TEXT NOT NULL,
  ran_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  added_nodes  INT NOT NULL DEFAULT 0,
  added_edges  INT NOT NULL DEFAULT 0,
  removed_nodes INT NOT NULL DEFAULT 0,
  removed_edges INT NOT NULL DEFAULT 0,
  duration_ms  INT,
  error        TEXT
);
```

### 3.1 Why not Neo4j

- Neo4j adds another DB engine. Operationally heavier.
- pgvector + property tables handles our scale (target: 1M nodes / 10M edges per tenant is years out).
- Migrations are easier in one DB.
- If we hit a wall, the data is portable — `brain.nodes` and `brain.edges` are graph-shaped already.

### 3.2 Why not Cosmograph as storage

Cosmograph is a *rendering* library (force-directed graph in WebGL). It's an in-memory client-side view. The storage layer is Postgres; Cosmograph just receives JSON from a server action and renders it. v1 already uses Cosmograph for the Brain view — same pattern continues.

---

## 4. File-bus state directories (cortextOS-owned)

Layout under `/var/cortexos/tenants/<slug>/state/`:

```
state/
├── orgs/<org>/
│   ├── config.json
│   ├── agents/
│   │   ├── orchestrator/
│   │   │   ├── inbox.jsonl
│   │   │   ├── outbox.jsonl
│   │   │   ├── heartbeat
│   │   │   ├── tasks/
│   │   │   │   ├── 2026-05-16T09-17-42__draft-rebecca-reply.json
│   │   │   │   └── …
│   │   │   ├── experiments/
│   │   │   └── approvals/
│   │   │       └── 2026-05-16T09-17-44__rebecca-reply.json
│   │   ├── hr-assistant/
│   │   ├── proposal-builder/
│   │   └── …
│   └── crons.json
```

**v2 does not own this schema.** cortextOS does. We override the root path via `CTX_FRAMEWORK_ROOT` env var when booting the daemon. We **read** these files from the dashboard for real-time telemetry, and we **mirror approvals into Prisma** via shim scripts so the dashboard's `/approvals` view has a queryable source. But we never reshape the state-dir layout.

Source of upstream layout to grep when curious: `/Users/madsadmin/code/cortex-os-upstream/src/bus/` and `/Users/madsadmin/code/cortex-os-upstream/templates/orchestrator/`.

---

## 5. The vault (markdown source of truth)

Per-tenant layout on disk:

```
/var/cortexos/tenants/<slug>/vault/
├── README.md                          (auto-generated index)
├── handbook/
│   ├── leave-policy.md
│   ├── sickness-policy.md
│   └── …
├── proposals/
│   ├── 2026-04-slate-acquisitions.md
│   └── …
├── people/
│   ├── sarah-stevens.md
│   └── …
├── voice/
│   └── voice-profile.md
├── decisions/                         (ADR-style)
└── _meta/
    ├── graph.json                     (cached graph snapshot)
    └── stats.json                     (density, deltas)
```

In production, the vault is **mounted from R2** via rclone or stored on a Fly volume. In dev, it's local fs. Round-trip safe: edits in Obsidian propagate via filesystem watch → `bus/kb-ingest.sh` re-runs on the changed file.

---

## 6. The dual-write pattern for approvals

cortextOS owns the approval bus interface. v2 owns the dashboard view of approvals. To avoid divergence:

```bash
# packages/governance/bus-shims/create-approval.sh
# Overrides upstream bus/create-approval.sh

#!/usr/bin/env bash
# Call the original (writes to state dir):
ORIG_RESULT=$("${CORTEXTOS_DIR}/bus/_create-approval-original.sh" "$@")
APPROVAL_ID=$(echo "$ORIG_RESULT" | jq -r '.id')
STATE_FILE=$(echo "$ORIG_RESULT" | jq -r '.path')

# Mirror to Prisma (single source of truth for the dashboard query):
node "${V2_ROOT}/packages/governance/cli/mirror-approval.js" \
  --bus-file "$STATE_FILE" \
  --approval-id "$APPROVAL_ID"

echo "$ORIG_RESULT"
```

The reverse direction — operator approves in dashboard → cortextOS state must reflect — works similarly:

```typescript
// packages/governance/src/approvals.ts
export async function approveFromDashboard(approvalId: string, userId: string) {
  await db.$transaction(async (tx) => {
    const approval = await tx.approval.update({
      where: { id: approvalId },
      data: { status: 'APPROVED', decidedById: userId, decidedAt: new Date() },
    });
    await tx.auditEvent.create({ /* … */ });

    // Mirror back to cortextOS state dir
    await execCortextBus('update-approval.sh', [
      '--id', approval.id,
      '--status', 'approved',
    ]);
  });
}
```

This pattern is the entire reason the integration works. Bus interface preserved; data warehoused in Prisma; reconciliation is `bus_file_path` round-trip.

---

## 7. Multi-tenancy

v1 was approaching multi-tenancy with row-level filters (tenantId on every row). v2 takes a step further: **one cortextOS daemon process per tenant** (PM2 spawns a separate process per `pm2 start ... --name cortex-<tenant>`). Shared Postgres, isolated runtime.

Trade-offs:
- ✅ Process isolation: a crashing agent in tenant A doesn't affect tenant B
- ✅ Per-tenant `CTX_FRAMEWORK_ROOT` is clean
- ⚠️ Memory cost: each daemon needs ~150–300 MB resident
- ⚠️ At 50+ tenants, this becomes a multi-machine fleet (Fly.io scales horizontally; that's the plan)

For dev / small scale: single daemon, multi-org config inside cortextOS. Production: per-tenant process.

---

## 8. Per-tenant migration from v1

When a v1 customer migrates to v2:

```
v1 export → v2 import flow:

1. Export v1 customer:
   - Audit log → CSV
   - Brain content (whatever's in v1's BrainGraph + Knowledge tables) → markdown files
   - Approvals history → CSV
   - Agent config → JSON

2. Provision v2 tenant:
   - Insert Tenant row, vault_path + state_path set
   - Create vault dir, dump markdown files
   - Run packages/brain/cli/kb-ingest.ts on every page → populates nodes/edges/embeddings
   - Insert historical audit + approval rows for traceability

3. Boot per-tenant daemon:
   - pm2 start daemon --name cortex-<slug> with CTX_FRAMEWORK_ROOT=/var/cortexos/tenants/<slug>/state
   - Daemon reads org config, creates Orchestrator + Specialist agent PTY sessions
   - Telegram bot is registered to the tenant org

4. Cutover:
   - DNS / Teams app manifest points the customer at the v2 daemon URL
   - v1 customer record marked ARCHIVED in v1 Prisma
   - Customer keeps everything they had + gets the v2 brain view, Telegram control, persistent agents
```

Migration script lives at `infra/migrate/v1-to-v2.ts` (built in Phase 3).

---

## 9. Backups

- Postgres: Neon's automated PITR + nightly logical dump to R2
- Vault: R2 native versioning + nightly snapshot
- File-bus state: nightly tar to R2, retention 30 days (state is short-lived; tasks complete and archive)
- Audit log: 7-year retention enforced in Postgres + immutable archive to R2 (write-once bucket)

---

## 10. Open data-model decisions

See `08-OPEN-DECISIONS.md` §6 and §7:

- Embedding model (OpenAI `text-embedding-3-small` vs Voyage vs Cohere)
- Entity extraction model (Claude Haiku for cost vs full Sonnet)
- Whether to store the markdown vault in Postgres TOAST as a fallback to fs-only

These don't block Phase 0. They're tuned in Phase 1.
