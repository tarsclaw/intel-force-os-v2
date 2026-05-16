# Postgres Schema Specification

**The shared Postgres 15+ cluster that underpins the entire platform.** Single DB. Multiple schemas. Row-level security enforcing tenant isolation.

> **Audience:** the engineer implementing CC11 (Postgres + pgvector setup) and CC12 (database migrations).
>
> **Status:** v1.0. Targets a single-region Hetzner UK deployment with hot standby replica.
>
> **Scope:** This spec covers the platform control-plane schema plus per-tenant pgvector schemas. It does NOT cover the webhook receiver's Redis dedup store (that's in `phase-1-poc-stack/platform-specs/webhook-receiver-spec.md`).

---

## 1. Why Postgres + pgvector, one cluster

- **Operational simplicity.** One cluster to back up, monitor, upgrade. We run one primary + one hot standby.
- **Strong isolation story.** Row-level security (RLS) enforces tenant boundaries at the database level, not at the application layer. Even a bug in application code can't leak across tenants.
- **pgvector is good enough.** For <10M chunks total (across all tenants), pgvector with IVFFlat or HNSW indices meets our retrieval latency target (<200ms p95). When we cross that threshold, we migrate specific high-traffic tenants to a dedicated vector DB — not before.
- **Blast-radius mitigation.** The trade-off: a Postgres incident affects all tenants. We mitigate with aggressive backups, read replicas, and an explicit DR runbook (see `dr/` in this phase).

---

## 2. Cluster configuration

| Setting | Value |
|---|---|
| Postgres version | 15.x (or 16.x if available at deploy time) |
| Hosting | Hetzner dedicated (primary) + Hetzner cloud hot standby |
| Primary role | Read-write, takes all writes |
| Standby role | Streaming replication, read-only queries allowed for reports |
| Connection pooling | PgBouncer in transaction mode, 200 connections → 2000 clients |
| Backups | pgBackRest — full weekly, incremental hourly, WAL archival continuous |
| Retention | 30 days of point-in-time recovery |
| Encryption | At-rest via full-disk encryption (LUKS); in-transit via TLS 1.3 |
| Extensions required | `pgcrypto`, `pgvector`, `pg_stat_statements`, `pg_trgm`, `uuid-ossp` |

---

## 3. Schema layout

```
postgres
├── control (schema)                        — shared platform data
│   ├── tenants
│   ├── tenant_versions
│   ├── secrets_metadata
│   ├── integrations
│   ├── webhook_registrations
│   ├── invocations
│   ├── costs
│   ├── escalations
│   ├── retrieval_queries (for pgvector access log)
│   └── migrations (applied migration tracker)
│
├── tenant_<tenant_id> (schema, per tenant) — per-tenant pgvector chunks
│   └── chunks
│
└── ops (schema)                            — platform-internal ops
    ├── audit_log
    ├── alerts
    └── deployments
```

One `control` schema for shared metadata, one `ops` schema for platform-internal observability, and one dynamically-created schema per tenant for their vector chunks. Tenant schemas are named `tenant_<ULID>` — e.g. `tenant_01JKDY8X5RQ4P2N6`.

---

## 4. `control` schema — the core tables

### 4.1 `control.tenants`

The single source of truth for tenant existence.

```sql
CREATE TABLE control.tenants (
  id                  text PRIMARY KEY,              -- tnt_01JKDY8X5RQ4P2N6 (ULID prefixed with tnt_)
  client_name         text NOT NULL,
  client_slug         text NOT NULL UNIQUE,          -- meadowlane-dental
  legal_name          text,
  industry            text,
  sic_code            text,
  website             text,
  currency            text NOT NULL DEFAULT 'GBP',
  timezone            text NOT NULL DEFAULT 'Europe/London',
  vat_treatment       text NOT NULL DEFAULT 'ex-vat' CHECK (vat_treatment IN ('ex-vat','inc-vat','no-vat')),

  plan                text NOT NULL CHECK (plan IN ('starter','growth','scale','enterprise','agency_partner')),
  parent_tenant_id    text REFERENCES control.tenants(id),  -- for Agency Partner sub-tenants

  status              text NOT NULL CHECK (status IN ('provisioning','active','suspended','archived')),
  supervisor_sock     text NOT NULL,                 -- path to Unix socket, e.g. /mnt/tenants/tnt_xxx/.claude/tenant.sock
  deployed_version    text NOT NULL,                 -- image version, e.g. 1.2.0
  pinned_version      text,                          -- if enterprise client has pinned a specific version

  cost_budget_gbp     numeric(10,2) NOT NULL DEFAULT 150.00,
  cost_budget_mode    text NOT NULL DEFAULT 'soft_alert' CHECK (cost_budget_mode IN ('soft_alert','hard_stop')),

  created_at          timestamptz NOT NULL DEFAULT now(),
  activated_at        timestamptz,                   -- set when status first becomes 'active'
  suspended_at        timestamptz,
  archived_at         timestamptz,
  updated_at          timestamptz NOT NULL DEFAULT now(),

  -- Ownership / contact
  owner_email         text NOT NULL,                 -- primary contact for this tenant
  billing_email       text,
  support_email       text,

  -- Arbitrary metadata for future fields without migration
  metadata            jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX idx_tenants_status ON control.tenants(status) WHERE status = 'active';
CREATE INDEX idx_tenants_parent ON control.tenants(parent_tenant_id) WHERE parent_tenant_id IS NOT NULL;
CREATE INDEX idx_tenants_plan   ON control.tenants(plan);

-- Auto-update trigger
CREATE TRIGGER trg_tenants_updated_at
  BEFORE UPDATE ON control.tenants
  FOR EACH ROW EXECUTE FUNCTION control.touch_updated_at();
```

### 4.2 `control.tenant_versions`

Every material change to a tenant's configuration is versioned. Lets us roll back, audit, and replay.

```sql
CREATE TABLE control.tenant_versions (
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  version             integer NOT NULL,
  config_snapshot     jsonb NOT NULL,                -- full tenant-config.json at this version
  created_at          timestamptz NOT NULL DEFAULT now(),
  created_by          text NOT NULL,                 -- 'provisioning-system' | 'dashboard:{user_id}' | 'support:{user_id}'
  change_reason       text,
  PRIMARY KEY (tenant_id, version)
);

CREATE INDEX idx_tenant_versions_created ON control.tenant_versions(tenant_id, created_at DESC);
```

### 4.3 `control.integrations`

Which integrations a tenant has enabled. One row per (tenant, integration) pair.

```sql
CREATE TABLE control.integrations (
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  integration         text NOT NULL,                 -- fathom | hubspot | gmail | stripe | ga4 | ...
  status              text NOT NULL CHECK (status IN ('pending_oauth','active','error','disabled')),
  auth_type           text NOT NULL CHECK (auth_type IN ('api_key','oauth2','service_account')),
  secret_ref          text NOT NULL,                 -- 'secrets://tnt_xxx/fathom/api_key'
  scopes              text[] DEFAULT '{}',           -- granted scopes (OAuth)
  last_verified_at    timestamptz,                   -- last successful preflight
  last_error          text,
  last_error_at       timestamptz,
  expires_at          timestamptz,                   -- OAuth refresh target
  metadata            jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_id, integration)
);

CREATE INDEX idx_integrations_status ON control.integrations(status) WHERE status = 'error';
CREATE INDEX idx_integrations_expiring ON control.integrations(expires_at) WHERE expires_at IS NOT NULL;
```

### 4.4 `control.webhook_registrations`

The webhook receiver's tenant registry. Source for `receiver`'s in-memory cache.

```sql
CREATE TABLE control.webhook_registrations (
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  integration         text NOT NULL,
  public_url          text NOT NULL UNIQUE,          -- https://hooks.intelforce.ai/tnt_xxx/fathom
  secret_ref          text NOT NULL,                 -- HMAC signing secret reference
  filter_rules        jsonb NOT NULL DEFAULT '{}'::jsonb,
  rate_limit_rpm      integer NOT NULL DEFAULT 10,
  rate_limit_burst    integer NOT NULL DEFAULT 20,
  status              text NOT NULL CHECK (status IN ('active','disabled')),
  registered_with_provider_at timestamptz,           -- when we told Fathom/etc. about this URL
  created_at          timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_id, integration)
);
```

### 4.5 `control.invocations`

Every agent run. The audit spine of the entire platform.

```sql
CREATE TABLE control.invocations (
  id                  bigserial PRIMARY KEY,
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  agent               text NOT NULL,                  -- proposal-builder | lead-hunter | ...
  agent_version       text NOT NULL,                  -- 1.0.0
  trigger_source      text NOT NULL,                  -- webhook:fathom | cron | manual:dashboard | chained:content-creator

  started_at          timestamptz NOT NULL,
  ended_at            timestamptz,
  duration_ms         integer,

  status              text NOT NULL CHECK (status IN ('running','completed','failed','escalated','cost_stopped','timed_out')),
  exit_code           integer,

  -- Input identifiers
  trigger_payload_ref text,                           -- path to /tenant/intake/.../file.json
  session_id          text,                           -- CLAUDE_SESSION_ID

  -- Output identifiers
  output_paths        text[] DEFAULT '{}',
  escalation_code     text,                           -- e.g. BUDGET_BELOW_MINIMUM

  -- Observability
  log_file_ref        text,                           -- /tenant/logs/...jsonl path

  created_at          timestamptz NOT NULL DEFAULT now()
);

-- Partitioning by month to keep queries fast as table grows
-- We partition manually (monthly) via a scheduled job rather than pg_partman to keep ops simple.
CREATE INDEX idx_invocations_tenant_started ON control.invocations(tenant_id, started_at DESC);
CREATE INDEX idx_invocations_agent_started  ON control.invocations(agent, started_at DESC);
CREATE INDEX idx_invocations_status_running ON control.invocations(status) WHERE status = 'running';
CREATE INDEX idx_invocations_escalations    ON control.invocations(escalation_code) WHERE escalation_code IS NOT NULL;
```

Target row count: ~30 invocations/tenant/day × 200 tenants × 365 days = ~2.2M rows/year. Comfortable for a single table with monthly partitioning when it reaches ~10M.

### 4.6 `control.costs`

Per-invocation cost attribution. One row per invocation, joined on `invocations.id`.

```sql
CREATE TABLE control.costs (
  invocation_id       bigint PRIMARY KEY REFERENCES control.invocations(id) ON DELETE CASCADE,
  tenant_id           text NOT NULL REFERENCES control.tenants(id),

  -- Anthropic (Sonnet)
  anthropic_input_tokens    integer NOT NULL DEFAULT 0,
  anthropic_output_tokens   integer NOT NULL DEFAULT 0,
  anthropic_cache_read_tokens  integer NOT NULL DEFAULT 0,
  anthropic_cache_write_tokens integer NOT NULL DEFAULT 0,
  anthropic_cost_usd        numeric(10,4) NOT NULL DEFAULT 0,

  -- Cohere (embeddings)
  cohere_embed_calls        integer NOT NULL DEFAULT 0,
  cohere_embed_tokens       integer NOT NULL DEFAULT 0,
  cohere_cost_usd           numeric(10,4) NOT NULL DEFAULT 0,

  -- Integration API costs (where they matter — Prospeo, Kaspr)
  prospeo_calls             integer NOT NULL DEFAULT 0,
  prospeo_cost_usd          numeric(10,4) NOT NULL DEFAULT 0,

  kaspr_calls               integer NOT NULL DEFAULT 0,
  kaspr_cost_usd            numeric(10,4) NOT NULL DEFAULT 0,

  -- Other (Gmail, HubSpot, etc. — mostly free at our volumes but tracked for audit)
  other_api_calls           integer NOT NULL DEFAULT 0,

  -- Totals (computed)
  total_cost_usd            numeric(10,4) NOT NULL DEFAULT 0,
  total_cost_gbp            numeric(10,4) NOT NULL DEFAULT 0,
  usd_gbp_rate              numeric(8,6) NOT NULL,    -- rate at time of calculation

  created_at                timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_costs_tenant_created ON control.costs(tenant_id, created_at DESC);

-- Monthly rollup view for dashboards
CREATE VIEW control.costs_monthly AS
SELECT
  tenant_id,
  date_trunc('month', created_at) AS month,
  SUM(total_cost_gbp) AS total_gbp,
  SUM(anthropic_cost_usd) AS anthropic_usd,
  SUM(cohere_cost_usd) AS cohere_usd,
  SUM(prospeo_cost_usd + kaspr_cost_usd) AS data_provider_usd,
  COUNT(*) AS invocation_count
FROM control.costs
GROUP BY tenant_id, date_trunc('month', created_at);
```

### 4.7 `control.escalations`

Every escalation an agent raises. The dashboard's Escalations view reads from here.

```sql
CREATE TABLE control.escalations (
  id                  bigserial PRIMARY KEY,
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  invocation_id       bigint REFERENCES control.invocations(id),
  agent               text NOT NULL,
  code                text NOT NULL,                  -- BUDGET_BELOW_MINIMUM, etc.
  severity            text NOT NULL DEFAULT 'medium' CHECK (severity IN ('info','low','medium','high','critical')),

  prospect_slug       text,                           -- when escalation relates to a specific prospect
  file_ref            text,                           -- path to /outbox/escalations/...md

  raised_at           timestamptz NOT NULL,
  acknowledged_at     timestamptz,
  acknowledged_by     text,
  resolved_at         timestamptz,
  resolved_by         text,
  resolution_note     text,

  status              text NOT NULL DEFAULT 'open' CHECK (status IN ('open','acknowledged','resolved','won_t_fix')),

  metadata            jsonb NOT NULL DEFAULT '{}'::jsonb,

  created_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_escalations_tenant_open ON control.escalations(tenant_id, raised_at DESC) WHERE status = 'open';
CREATE INDEX idx_escalations_agent ON control.escalations(agent);
CREATE INDEX idx_escalations_code ON control.escalations(code);
```

### 4.8 `control.retrieval_queries`

Tracks every pgvector query — for the Librarian's "orphan detection" (files never retrieved → archive candidate) and for retrieval debugging.

```sql
CREATE TABLE control.retrieval_queries (
  id                  bigserial PRIMARY KEY,
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  invocation_id       bigint REFERENCES control.invocations(id),
  agent               text NOT NULL,
  query_text          text NOT NULL,
  tag_filter          text,
  top_k               integer NOT NULL,
  result_count        integer NOT NULL,
  result_chunk_ids    bigint[] DEFAULT '{}',
  latency_ms          integer,
  created_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_retrieval_tenant_created ON control.retrieval_queries(tenant_id, created_at DESC);
-- Used by Librarian: find chunks never retrieved
-- SELECT DISTINCT unnest(result_chunk_ids) FROM control.retrieval_queries WHERE tenant_id = $1 AND created_at > now() - interval '60 days'
```

Retention: 90 days rolling. A scheduled job prunes older rows nightly.

### 4.9 `control.secrets_metadata`

We do NOT store secret values in Postgres — those live in the KMS-wrapped secrets vault (see `secrets/`). This table tracks metadata about secrets so the dashboard can show "last rotated," "expires in X days," etc.

```sql
CREATE TABLE control.secrets_metadata (
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  secret_ref          text NOT NULL,                  -- 'secrets://tnt_xxx/fathom/api_key'
  secret_kind         text NOT NULL,                  -- api_key | oauth_token | webhook_secret | deploy_key
  created_at          timestamptz NOT NULL DEFAULT now(),
  last_rotated_at     timestamptz,
  expires_at          timestamptz,                    -- for OAuth tokens
  rotation_policy_days integer,                       -- 0 = never auto-rotate
  last_accessed_at    timestamptz,                    -- for detecting unused secrets
  status              text NOT NULL CHECK (status IN ('active','rotating','revoked','expired')),
  metadata            jsonb NOT NULL DEFAULT '{}'::jsonb,
  PRIMARY KEY (tenant_id, secret_ref)
);

CREATE INDEX idx_secrets_expiring ON control.secrets_metadata(expires_at) WHERE expires_at IS NOT NULL AND status = 'active';
```

### 4.10 `control.migrations`

Tracks applied schema migrations. Managed by a migration tool (sqitch, goose, or just a custom Node runner).

```sql
CREATE TABLE control.migrations (
  id                  serial PRIMARY KEY,
  version             text NOT NULL UNIQUE,           -- 20260422_001_initial
  name                text NOT NULL,
  applied_at          timestamptz NOT NULL DEFAULT now(),
  applied_by          text NOT NULL,
  checksum            text NOT NULL                   -- SHA256 of the migration SQL
);
```

---

## 5. Per-tenant schemas — pgvector chunks

Each tenant gets a dedicated schema. Provisioning System creates it on tenant activation.

```sql
-- Executed at tenant provisioning time (substituting {tenant_id})
CREATE SCHEMA IF NOT EXISTS tenant_{tenant_id};

CREATE TABLE tenant_{tenant_id}.chunks (
  id                  bigserial PRIMARY KEY,
  source_path         text NOT NULL,                  -- /vault/content/long-form/2026-04-22-foo.md
  chunk_index         integer NOT NULL,
  content             text NOT NULL,
  embedding           vector(1024),                   -- Cohere embed-v3 dimensions
  tags                text[] DEFAULT '{}',
  frontmatter         jsonb NOT NULL DEFAULT '{}'::jsonb,
  embedded_at         timestamptz NOT NULL DEFAULT now(),
  embedding_model     text NOT NULL DEFAULT 'cohere-embed-v3',
  content_hash        text NOT NULL,                  -- SHA256 of content for dedup
  UNIQUE (source_path, chunk_index)
);

-- HNSW index for fast approximate nearest-neighbour
CREATE INDEX idx_chunks_embedding ON tenant_{tenant_id}.chunks
  USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- Tag filter index
CREATE INDEX idx_chunks_tags ON tenant_{tenant_id}.chunks USING gin (tags);

-- Frontmatter filter index (jsonb)
CREATE INDEX idx_chunks_frontmatter ON tenant_{tenant_id}.chunks USING gin (frontmatter);

-- Source-path lookup (for re-indexing on file change)
CREATE INDEX idx_chunks_source_path ON tenant_{tenant_id}.chunks(source_path);
```

**Schema creation is part of the Provisioning System's activation flow — see `provisioning/provisioning-system-spec.md` §6.**

---

## 6. Row-level security (RLS)

RLS is the cheapest possible way to enforce tenant isolation at the database layer. Every query automatically filters by `tenant_id` based on the session variable `app.current_tenant_id`.

### 6.1 Enable RLS

```sql
-- For every table with a tenant_id column
ALTER TABLE control.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.invocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.costs ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.escalations ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.integrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.webhook_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.retrieval_queries ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.secrets_metadata ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.tenant_versions ENABLE ROW LEVEL SECURITY;
```

### 6.2 Policies

```sql
-- Tenant-scoped read access
CREATE POLICY tenant_read ON control.invocations
  FOR SELECT
  USING (tenant_id = current_setting('app.current_tenant_id', true));

-- Tenant-scoped write access (typically the agent runtime)
CREATE POLICY tenant_write ON control.invocations
  FOR INSERT
  WITH CHECK (tenant_id = current_setting('app.current_tenant_id', true));

-- Platform admin — a separate role that bypasses RLS
-- (used by the dashboard's admin views, the provisioning system, and ops tooling)
CREATE ROLE platform_admin BYPASSRLS;
```

### 6.3 Session pattern

Every application connection sets `app.current_tenant_id` at the start:

```sql
SET LOCAL app.current_tenant_id = 'tnt_01JKDY8X5RQ4P2N6';
```

If the session variable is unset, queries against RLS tables return zero rows rather than all rows. This is the fail-safe default.

### 6.4 Per-tenant schema isolation

Even with RLS on the control schema, the per-tenant `tenant_<id>` schemas add a second layer: the tenant's database role only has `USAGE` on its own schema.

```sql
-- At tenant provisioning time
CREATE ROLE tenant_{tenant_id} LOGIN PASSWORD :'generated_password';
GRANT USAGE ON SCHEMA tenant_{tenant_id} TO tenant_{tenant_id};
GRANT ALL ON ALL TABLES IN SCHEMA tenant_{tenant_id} TO tenant_{tenant_id};
-- NO grant on any other tenant schema or the control schema.
```

Tenant containers connect as their own `tenant_<id>` role. Even if a container is compromised, the DB role can only see that tenant's pgvector chunks plus their own RLS-filtered control-schema rows.

---

## 7. Functions and triggers

### 7.1 Generic `updated_at` trigger

```sql
CREATE OR REPLACE FUNCTION control.touch_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 7.2 Cost rollup materialised view (refresh every 5 minutes)

```sql
CREATE MATERIALIZED VIEW control.costs_current_month AS
SELECT
  tenant_id,
  SUM(total_cost_gbp) AS spent_gbp,
  COUNT(*) AS invocation_count
FROM control.costs
WHERE created_at >= date_trunc('month', now())
GROUP BY tenant_id;

CREATE UNIQUE INDEX idx_costs_current_month_tenant ON control.costs_current_month(tenant_id);

-- Refreshed by a scheduled job every 5 minutes.
-- Dashboard reads from this for "current month spend" tiles.
```

---

## 8. Scaling plan

| Stage | Tenants | Tactic |
|---|---|---|
| MVP | 1–10 | Single primary, single standby. Small Hetzner dedicated. |
| Early growth | 10–50 | Scale up primary (add RAM for buffer cache). Add read replicas. |
| Real scale | 50–200 | Partition invocations/costs by month. Move to dedicated ops replica for dashboards. |
| Multi-region | 200+ | Consider Citus for horizontal sharding, or migrate heavy-retrieval tenants to a dedicated vector DB. |

The schema is designed so the first 200 tenants fit on one primary without architectural change. Beyond that, we redesign — not now.

---

## 9. What's NOT in this schema (deliberate)

- **No vault file contents.** Vault is git-backed in GitHub. Postgres only indexes metadata and embeddings.
- **No user/operator accounts.** Dashboard auth goes to a separate identity provider (Clerk or similar) in Phase 4.
- **No billing/Stripe data.** Stripe is source of truth for billing; we mirror read-only subscription status into `tenants.metadata.stripe_subscription_id`.
- **No application logs.** Those go to Loki (see `observability/`). Postgres holds structured business events, not log streams.

---

## 10. Migration strategy

- Every schema change is a forward-only migration.
- Destructive changes (DROP TABLE, DROP COLUMN) are always two-step: v1 deprecates, v2 drops (minimum 30 days apart).
- Migrations are applied by CI during the deployment of a new platform version.
- `control.migrations` table records every applied migration with a checksum. Re-running is idempotent.
- Rollbacks are NOT supported for destructive migrations. For additive migrations, rollback = drop the added column/table.

See `dr/backup-and-dr-runbook.md` for recovery-from-migration-disaster procedures.
