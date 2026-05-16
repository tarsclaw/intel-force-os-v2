-- =============================================================================
-- Migration: 20260422_001_initial
-- Description: Initial IntelForce AI OS platform schema — control + ops schemas
-- Author: intelforce-platform
-- =============================================================================
-- This migration creates the full v1 schema as documented in
-- /postgres/schema-spec.md.
--
-- Per-tenant schemas (tenant_<id>) are NOT created here — they're created by
-- the Provisioning System on tenant activation (see provisioning-system-spec.md).
--
-- Idempotent: safe to re-run on a fresh database. Use `IF NOT EXISTS` and
-- `CREATE OR REPLACE FUNCTION` liberally.

BEGIN;

-- -----------------------------------------------------------------------------
-- Extensions
-- -----------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- -----------------------------------------------------------------------------
-- Schemas
-- -----------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS control;
CREATE SCHEMA IF NOT EXISTS ops;

-- -----------------------------------------------------------------------------
-- Shared functions
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION control.touch_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- Roles (created idempotently)
-- -----------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'platform_admin') THEN
    CREATE ROLE platform_admin BYPASSRLS;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'platform_readonly') THEN
    CREATE ROLE platform_readonly;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'provisioning_system') THEN
    CREATE ROLE provisioning_system BYPASSRLS;
  END IF;
END
$$;

-- -----------------------------------------------------------------------------
-- control.tenants
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS control.tenants (
  id                  text PRIMARY KEY,
  client_name         text NOT NULL,
  client_slug         text NOT NULL UNIQUE,
  legal_name          text,
  industry            text,
  sic_code            text,
  website             text,
  currency            text NOT NULL DEFAULT 'GBP',
  timezone            text NOT NULL DEFAULT 'Europe/London',
  vat_treatment       text NOT NULL DEFAULT 'ex-vat' CHECK (vat_treatment IN ('ex-vat','inc-vat','no-vat')),
  plan                text NOT NULL CHECK (plan IN ('starter','growth','scale','enterprise','agency_partner')),
  parent_tenant_id    text REFERENCES control.tenants(id),
  status              text NOT NULL CHECK (status IN ('provisioning','active','suspended','archived')),
  supervisor_sock     text NOT NULL,
  deployed_version    text NOT NULL,
  pinned_version      text,
  cost_budget_gbp     numeric(10,2) NOT NULL DEFAULT 150.00,
  cost_budget_mode    text NOT NULL DEFAULT 'soft_alert' CHECK (cost_budget_mode IN ('soft_alert','hard_stop')),
  created_at          timestamptz NOT NULL DEFAULT now(),
  activated_at        timestamptz,
  suspended_at        timestamptz,
  archived_at         timestamptz,
  updated_at          timestamptz NOT NULL DEFAULT now(),
  owner_email         text NOT NULL,
  billing_email       text,
  support_email       text,
  metadata            jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_tenants_status ON control.tenants(status) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_tenants_parent ON control.tenants(parent_tenant_id) WHERE parent_tenant_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tenants_plan   ON control.tenants(plan);

DROP TRIGGER IF EXISTS trg_tenants_updated_at ON control.tenants;
CREATE TRIGGER trg_tenants_updated_at
  BEFORE UPDATE ON control.tenants
  FOR EACH ROW EXECUTE FUNCTION control.touch_updated_at();

-- -----------------------------------------------------------------------------
-- control.tenant_versions
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS control.tenant_versions (
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  version             integer NOT NULL,
  config_snapshot     jsonb NOT NULL,
  created_at          timestamptz NOT NULL DEFAULT now(),
  created_by          text NOT NULL,
  change_reason       text,
  PRIMARY KEY (tenant_id, version)
);

CREATE INDEX IF NOT EXISTS idx_tenant_versions_created ON control.tenant_versions(tenant_id, created_at DESC);

-- -----------------------------------------------------------------------------
-- control.integrations
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS control.integrations (
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  integration         text NOT NULL,
  status              text NOT NULL CHECK (status IN ('pending_oauth','active','error','disabled')),
  auth_type           text NOT NULL CHECK (auth_type IN ('api_key','oauth2','service_account')),
  secret_ref          text NOT NULL,
  scopes              text[] DEFAULT '{}',
  last_verified_at    timestamptz,
  last_error          text,
  last_error_at       timestamptz,
  expires_at          timestamptz,
  metadata            jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_id, integration)
);

CREATE INDEX IF NOT EXISTS idx_integrations_status ON control.integrations(status) WHERE status = 'error';
CREATE INDEX IF NOT EXISTS idx_integrations_expiring ON control.integrations(expires_at) WHERE expires_at IS NOT NULL;

-- -----------------------------------------------------------------------------
-- control.webhook_registrations
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS control.webhook_registrations (
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  integration         text NOT NULL,
  public_url          text NOT NULL UNIQUE,
  secret_ref          text NOT NULL,
  filter_rules        jsonb NOT NULL DEFAULT '{}'::jsonb,
  rate_limit_rpm      integer NOT NULL DEFAULT 10,
  rate_limit_burst    integer NOT NULL DEFAULT 20,
  status              text NOT NULL CHECK (status IN ('active','disabled')),
  registered_with_provider_at timestamptz,
  created_at          timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_id, integration)
);

-- -----------------------------------------------------------------------------
-- control.invocations
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS control.invocations (
  id                  bigserial PRIMARY KEY,
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  agent               text NOT NULL,
  agent_version       text NOT NULL,
  trigger_source      text NOT NULL,
  started_at          timestamptz NOT NULL,
  ended_at            timestamptz,
  duration_ms         integer,
  status              text NOT NULL CHECK (status IN ('running','completed','failed','escalated','cost_stopped','timed_out')),
  exit_code           integer,
  trigger_payload_ref text,
  session_id          text,
  output_paths        text[] DEFAULT '{}',
  escalation_code     text,
  log_file_ref        text,
  created_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_invocations_tenant_started ON control.invocations(tenant_id, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_invocations_agent_started  ON control.invocations(agent, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_invocations_status_running ON control.invocations(status) WHERE status = 'running';
CREATE INDEX IF NOT EXISTS idx_invocations_escalations    ON control.invocations(escalation_code) WHERE escalation_code IS NOT NULL;

-- -----------------------------------------------------------------------------
-- control.costs
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS control.costs (
  invocation_id       bigint PRIMARY KEY REFERENCES control.invocations(id) ON DELETE CASCADE,
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  anthropic_input_tokens    integer NOT NULL DEFAULT 0,
  anthropic_output_tokens   integer NOT NULL DEFAULT 0,
  anthropic_cache_read_tokens  integer NOT NULL DEFAULT 0,
  anthropic_cache_write_tokens integer NOT NULL DEFAULT 0,
  anthropic_cost_usd        numeric(10,4) NOT NULL DEFAULT 0,
  cohere_embed_calls        integer NOT NULL DEFAULT 0,
  cohere_embed_tokens       integer NOT NULL DEFAULT 0,
  cohere_cost_usd           numeric(10,4) NOT NULL DEFAULT 0,
  prospeo_calls             integer NOT NULL DEFAULT 0,
  prospeo_cost_usd          numeric(10,4) NOT NULL DEFAULT 0,
  kaspr_calls               integer NOT NULL DEFAULT 0,
  kaspr_cost_usd            numeric(10,4) NOT NULL DEFAULT 0,
  other_api_calls           integer NOT NULL DEFAULT 0,
  total_cost_usd            numeric(10,4) NOT NULL DEFAULT 0,
  total_cost_gbp            numeric(10,4) NOT NULL DEFAULT 0,
  usd_gbp_rate              numeric(8,6) NOT NULL,
  created_at                timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_costs_tenant_created ON control.costs(tenant_id, created_at DESC);

CREATE OR REPLACE VIEW control.costs_monthly AS
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

-- -----------------------------------------------------------------------------
-- control.escalations
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS control.escalations (
  id                  bigserial PRIMARY KEY,
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  invocation_id       bigint REFERENCES control.invocations(id),
  agent               text NOT NULL,
  code                text NOT NULL,
  severity            text NOT NULL DEFAULT 'medium' CHECK (severity IN ('info','low','medium','high','critical')),
  prospect_slug       text,
  file_ref            text,
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

CREATE INDEX IF NOT EXISTS idx_escalations_tenant_open ON control.escalations(tenant_id, raised_at DESC) WHERE status = 'open';
CREATE INDEX IF NOT EXISTS idx_escalations_agent ON control.escalations(agent);
CREATE INDEX IF NOT EXISTS idx_escalations_code ON control.escalations(code);

-- -----------------------------------------------------------------------------
-- control.retrieval_queries
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS control.retrieval_queries (
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

CREATE INDEX IF NOT EXISTS idx_retrieval_tenant_created ON control.retrieval_queries(tenant_id, created_at DESC);

-- -----------------------------------------------------------------------------
-- control.secrets_metadata
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS control.secrets_metadata (
  tenant_id           text NOT NULL REFERENCES control.tenants(id),
  secret_ref          text NOT NULL,
  secret_kind         text NOT NULL,
  created_at          timestamptz NOT NULL DEFAULT now(),
  last_rotated_at     timestamptz,
  expires_at          timestamptz,
  rotation_policy_days integer,
  last_accessed_at    timestamptz,
  status              text NOT NULL CHECK (status IN ('active','rotating','revoked','expired')),
  metadata            jsonb NOT NULL DEFAULT '{}'::jsonb,
  PRIMARY KEY (tenant_id, secret_ref)
);

CREATE INDEX IF NOT EXISTS idx_secrets_expiring ON control.secrets_metadata(expires_at) WHERE expires_at IS NOT NULL AND status = 'active';

-- -----------------------------------------------------------------------------
-- control.migrations (migration tracker)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS control.migrations (
  id                  serial PRIMARY KEY,
  version             text NOT NULL UNIQUE,
  name                text NOT NULL,
  applied_at          timestamptz NOT NULL DEFAULT now(),
  applied_by          text NOT NULL,
  checksum            text NOT NULL
);

-- -----------------------------------------------------------------------------
-- ops schema — platform observability
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ops.audit_log (
  id                  bigserial PRIMARY KEY,
  actor               text NOT NULL,                  -- user email / system identifier
  action              text NOT NULL,                  -- tenant.suspend, secret.rotate, migration.apply, etc.
  target              text,                           -- affected entity
  metadata            jsonb NOT NULL DEFAULT '{}'::jsonb,
  ip_address          inet,
  user_agent          text,
  created_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_actor ON ops.audit_log(actor, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_target ON ops.audit_log(target, created_at DESC);

CREATE TABLE IF NOT EXISTS ops.alerts (
  id                  bigserial PRIMARY KEY,
  severity            text NOT NULL CHECK (severity IN ('info','warn','crit')),
  source              text NOT NULL,                  -- prometheus, provisioning-system, etc.
  alert_name          text NOT NULL,
  tenant_id           text REFERENCES control.tenants(id),
  message             text NOT NULL,
  metadata            jsonb NOT NULL DEFAULT '{}'::jsonb,
  fired_at            timestamptz NOT NULL,
  resolved_at         timestamptz,
  created_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_alerts_open ON ops.alerts(severity, fired_at DESC) WHERE resolved_at IS NULL;

CREATE TABLE IF NOT EXISTS ops.deployments (
  id                  bigserial PRIMARY KEY,
  component           text NOT NULL,                  -- webhook-receiver, tenant-image, dashboard, ...
  version             text NOT NULL,
  deployed_at         timestamptz NOT NULL DEFAULT now(),
  deployed_by         text NOT NULL,
  commit_sha          text,
  notes               text
);

CREATE INDEX IF NOT EXISTS idx_deployments_component ON ops.deployments(component, deployed_at DESC);

-- -----------------------------------------------------------------------------
-- Enable RLS on all tenant-scoped tables
-- -----------------------------------------------------------------------------
ALTER TABLE control.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.tenant_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.integrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.webhook_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.invocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.costs ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.escalations ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.retrieval_queries ENABLE ROW LEVEL SECURITY;
ALTER TABLE control.secrets_metadata ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if re-running
DROP POLICY IF EXISTS tenant_scoped_read ON control.tenants;
DROP POLICY IF EXISTS tenant_scoped_read ON control.invocations;
DROP POLICY IF EXISTS tenant_scoped_read ON control.costs;
DROP POLICY IF EXISTS tenant_scoped_read ON control.escalations;
DROP POLICY IF EXISTS tenant_scoped_read ON control.integrations;
DROP POLICY IF EXISTS tenant_scoped_read ON control.webhook_registrations;
DROP POLICY IF EXISTS tenant_scoped_read ON control.retrieval_queries;
DROP POLICY IF EXISTS tenant_scoped_read ON control.secrets_metadata;
DROP POLICY IF EXISTS tenant_scoped_read ON control.tenant_versions;

-- Tenant-scoped read: every query is filtered by the session-level tenant_id
CREATE POLICY tenant_scoped_read ON control.tenants         FOR ALL USING (id = current_setting('app.current_tenant_id', true));
CREATE POLICY tenant_scoped_read ON control.invocations     FOR ALL USING (tenant_id = current_setting('app.current_tenant_id', true));
CREATE POLICY tenant_scoped_read ON control.costs           FOR ALL USING (tenant_id = current_setting('app.current_tenant_id', true));
CREATE POLICY tenant_scoped_read ON control.escalations     FOR ALL USING (tenant_id = current_setting('app.current_tenant_id', true));
CREATE POLICY tenant_scoped_read ON control.integrations    FOR ALL USING (tenant_id = current_setting('app.current_tenant_id', true));
CREATE POLICY tenant_scoped_read ON control.webhook_registrations FOR ALL USING (tenant_id = current_setting('app.current_tenant_id', true));
CREATE POLICY tenant_scoped_read ON control.retrieval_queries FOR ALL USING (tenant_id = current_setting('app.current_tenant_id', true));
CREATE POLICY tenant_scoped_read ON control.secrets_metadata FOR ALL USING (tenant_id = current_setting('app.current_tenant_id', true));
CREATE POLICY tenant_scoped_read ON control.tenant_versions FOR ALL USING (tenant_id = current_setting('app.current_tenant_id', true));

-- Grant appropriate privileges to platform roles
GRANT USAGE ON SCHEMA control, ops TO platform_admin, provisioning_system, platform_readonly;
GRANT ALL ON ALL TABLES IN SCHEMA control, ops TO platform_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA control, ops TO platform_readonly;
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA control TO provisioning_system;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA control TO platform_admin, provisioning_system;

-- -----------------------------------------------------------------------------
-- Record this migration
-- -----------------------------------------------------------------------------
INSERT INTO control.migrations (version, name, applied_by, checksum)
VALUES (
  '20260422_001_initial',
  'Initial platform schema',
  'provisioning-system',
  encode(digest('20260422_001_initial', 'sha256'), 'hex')
)
ON CONFLICT (version) DO NOTHING;

COMMIT;
