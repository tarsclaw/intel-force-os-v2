-- ============================================================================
-- IFOS recruitment vertical schema — v0.3 → v0.4 migration
-- ============================================================================
-- Companion to: docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml
-- Authored:     2026-06-03 (W5 Day-30; post-MCP-sweep)
-- Status:       DRAFTED; NOT executed against production Hetzner Postgres yet.
--               Execute against migration-test tenant first via run-live-migration.sh.
--
-- ADDITIVE-ONLY. v0.4 extends the validate_tenant_adapters_config_v0_3 trigger
-- to v0_4 by adding 5 new allowlist entries + per-key type validators:
--   - operator_telegram_chat_id  (D1-B Path B; Telegram chat ID for autosend approvals)
--   - email_channel              (Concierge MS Graph vs Gmail selection)
--   - workos_org_id              (per-tenant WorkOS organisation identifier)
--   - granola_workspace_id       (per-tenant Granola workspace identifier; W6+ Scribe)
--   - bullhorn_corporation_id    (per-tenant Bullhorn corporation identifier)
--
-- TOTAL v0.4 allowlist: 16 keys (11 v0.1+v0.2+v0.3 + 5 v0.4).
--
-- ALL OTHER v0.3 STATE PRESERVED VERBATIM:
--   - cash_conductor_transactions + cash_conductor_invoices tables: unchanged
--   - validate_entities_data_v0_3 function + trigger: unchanged (NOT renamed)
--   - All v0.3 entity field validations: unchanged
--   - voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables: unchanged
--   - RLS policies + ifos_app grants: unchanged
--   - decision_log payload shape: unchanged
--
-- Rollback path: companion v0.4-to-v0.3.sql.
--
-- Prerequisites:
--   - v0.3 migration applied (validate_tenant_adapters_config_v0_3 trigger exists)
--   - cash_conductor_transactions + cash_conductor_invoices tables present
--   - RLS policies + ifos_app grants from Day-4 §6.3 in place
--
-- Execution order: BEGIN; <each block>; COMMIT;   on success.
--                  BEGIN; <each block>; ROLLBACK; on any error.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- §1 — Verify prerequisite v0.3 state
-- ----------------------------------------------------------------------------

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc WHERE proname = 'validate_tenant_adapters_config_v0_3'
  ) THEN
    RAISE EXCEPTION 'v0.3 validate_tenant_adapters_config_v0_3 function missing; run v0.2-to-v0.3.sql first';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'validate_tenant_adapters_config_v0_3'
  ) THEN
    RAISE EXCEPTION 'v0.3 validate_tenant_adapters_config_v0_3 trigger missing; run v0.2-to-v0.3.sql first';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'cash_conductor_transactions') THEN
    RAISE EXCEPTION 'v0.3 cash_conductor_transactions table missing; run v0.2-to-v0.3.sql first';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'cash_conductor_invoices') THEN
    RAISE EXCEPTION 'v0.3 cash_conductor_invoices table missing; run v0.2-to-v0.3.sql first';
  END IF;
  RAISE NOTICE 'v0.3 prerequisites verified (trigger + function + 2 tables present)';
END $$;

-- ----------------------------------------------------------------------------
-- §2 — Create v0.4 tenant_adapters.config validation function
-- ----------------------------------------------------------------------------
--
-- Preserves ALL v0.3 allowlist entries (11 keys) + adds 5 v0.4 keys (16 total).
-- Per-key type validation for each v0.4 entry mirrors the v0.3 pattern
-- (jsonb_typeof + format/pattern checks).
--
-- v0.4 keys validated below:
--   - operator_telegram_chat_id: string matching '^-?[0-9]+$'
--   - email_channel:             string in ('microsoft-graph', 'gmail')
--   - workos_org_id:             string matching '^org_[A-Z0-9]+$'
--   - granola_workspace_id:      string (no format constraint; opaque per-tenant identifier)
--   - bullhorn_corporation_id:   string matching '^[0-9]+$'

CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_4()
RETURNS TRIGGER AS $$
DECLARE
  c JSONB := NEW.config;
  k TEXT;
  elem JSONB;
  allowed_keys TEXT[] := ARRAY[
    -- v0.1 + v0.2 keys (forwarded; do not remove)
    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
    'janitor_last_run',
    'pii_retention_days',  -- v0.2 PII purge runbook key
    -- autosend-safety-policy.md keys
    'approval_routing', 'approval_timeouts', 'sampling_rates',
    -- v0.3 additions
    'cash_conductor_last_run',
    'concierge_last_poll',
    'concierge_send_window',
    -- v0.4 additions (5 new keys)
    'operator_telegram_chat_id',  -- D1-B Path B; autosend-bridge consumer
    'email_channel',              -- Concierge MS Graph vs Gmail
    'workos_org_id',              -- per-tenant WorkOS org (master brief §5.3 line 401)
    'granola_workspace_id',       -- per-tenant Granola workspace (W6+ Scribe)
    'bullhorn_corporation_id'     -- per-tenant Bullhorn corporation
  ];
BEGIN
  IF c IS NULL THEN
    RETURN NEW;
  END IF;

  FOR k IN SELECT jsonb_object_keys(c) LOOP
    IF NOT (k = ANY(allowed_keys)) THEN
      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
    END IF;
  END LOOP;

  -- ────────────────────────────────────────────────────────────────────────
  -- v0.3 type validations (preserved verbatim)
  -- ────────────────────────────────────────────────────────────────────────

  IF c ? 'concierge_send_window' THEN
    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
      RAISE EXCEPTION 'concierge_send_window must be object';
    END IF;
    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
      RAISE EXCEPTION 'concierge_send_window must include timezone';
    END IF;
    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
    END IF;
    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
    END IF;
  END IF;

  IF c ? 'cash_conductor_last_run' THEN
    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
    END IF;
  END IF;

  IF c ? 'concierge_last_poll' THEN
    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
    END IF;
  END IF;

  IF c ? 'janitor_dedup_threshold' THEN
    IF jsonb_typeof(c->'janitor_dedup_threshold') != 'number' THEN
      RAISE EXCEPTION 'janitor_dedup_threshold must be number';
    END IF;
    IF (c->>'janitor_dedup_threshold')::numeric < 0.75
       OR (c->>'janitor_dedup_threshold')::numeric > 0.95 THEN
      RAISE EXCEPTION 'janitor_dedup_threshold out of [0.75, 0.95] range: %', c->>'janitor_dedup_threshold';
    END IF;
  END IF;

  IF c ? 'janitor_last_run' THEN
    IF jsonb_typeof(c->'janitor_last_run') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'janitor_last_run must be ISO-8601 timestamp string or null';
    END IF;
  END IF;

  IF c ? 'blocked_recipients' THEN
    IF jsonb_typeof(c->'blocked_recipients') != 'array' THEN
      RAISE EXCEPTION 'blocked_recipients must be array';
    END IF;
    FOR elem IN SELECT * FROM jsonb_array_elements(c->'blocked_recipients') LOOP
      IF jsonb_typeof(elem) != 'string' THEN
        RAISE EXCEPTION 'blocked_recipients items must be strings; got %', jsonb_typeof(elem);
      END IF;
    END LOOP;
  END IF;

  -- ────────────────────────────────────────────────────────────────────────
  -- v0.4 type validations (5 new keys)
  -- ────────────────────────────────────────────────────────────────────────

  -- operator_telegram_chat_id: string matching signed integer pattern
  IF c ? 'operator_telegram_chat_id' THEN
    IF jsonb_typeof(c->'operator_telegram_chat_id') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'operator_telegram_chat_id must be string or null';
    END IF;
    IF c->>'operator_telegram_chat_id' IS NOT NULL
       AND c->>'operator_telegram_chat_id' !~ '^-?[0-9]+$' THEN
      RAISE EXCEPTION 'operator_telegram_chat_id must match ^-?[0-9]+$ (Telegram chat ID format); got: %', c->>'operator_telegram_chat_id';
    END IF;
  END IF;

  -- email_channel: enum
  IF c ? 'email_channel' THEN
    IF jsonb_typeof(c->'email_channel') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'email_channel must be string or null';
    END IF;
    IF c->>'email_channel' IS NOT NULL
       AND (c->>'email_channel') NOT IN ('microsoft-graph', 'gmail') THEN
      RAISE EXCEPTION 'email_channel must be one of (microsoft-graph, gmail); got: %', c->>'email_channel';
    END IF;
  END IF;

  -- workos_org_id: string matching WorkOS org pattern
  IF c ? 'workos_org_id' THEN
    IF jsonb_typeof(c->'workos_org_id') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'workos_org_id must be string or null';
    END IF;
    IF c->>'workos_org_id' IS NOT NULL
       AND c->>'workos_org_id' !~ '^org_[A-Z0-9]+$' THEN
      RAISE EXCEPTION 'workos_org_id must match ^org_[A-Z0-9]+$ (WorkOS org ID format); got: %', c->>'workos_org_id';
    END IF;
  END IF;

  -- granola_workspace_id: opaque string (no format constraint)
  IF c ? 'granola_workspace_id' THEN
    IF jsonb_typeof(c->'granola_workspace_id') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'granola_workspace_id must be string or null';
    END IF;
  END IF;

  -- bullhorn_corporation_id: string matching integer pattern
  IF c ? 'bullhorn_corporation_id' THEN
    IF jsonb_typeof(c->'bullhorn_corporation_id') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'bullhorn_corporation_id must be string or null';
    END IF;
    IF c->>'bullhorn_corporation_id' IS NOT NULL
       AND c->>'bullhorn_corporation_id' !~ '^[0-9]+$' THEN
      RAISE EXCEPTION 'bullhorn_corporation_id must match ^[0-9]+$ (Bullhorn corporation ID format); got: %', c->>'bullhorn_corporation_id';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- §3 — Rebind trigger to v0.4 function (drop v0.3 binding, create v0.4 binding)
-- ----------------------------------------------------------------------------

DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_4 ON tenant_adapters;

CREATE TRIGGER validate_tenant_adapters_config_v0_4
  BEFORE INSERT OR UPDATE ON tenant_adapters
  FOR EACH ROW
  EXECUTE FUNCTION validate_tenant_adapters_config_v0_4();

-- ----------------------------------------------------------------------------
-- §4 — Drop v0.3 function (no longer referenced; v0.4 supersedes cleanly)
-- ----------------------------------------------------------------------------
--
-- Order matters: §3 dropped the v0_3 trigger first, so this DROP FUNCTION
-- has no dependency to block it. If a downstream object still references
-- validate_tenant_adapters_config_v0_3, the DROP will fail and roll back
-- the migration — which is the intended fail-safe.

DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();

-- ----------------------------------------------------------------------------
-- §5 — Smoke verification (read-only)
-- ----------------------------------------------------------------------------

DO $$
DECLARE
  v04_func_count INT;
  v04_trig_count INT;
  v03_func_count INT;
  v03_trig_count INT;
BEGIN
  -- v0.4 function + trigger MUST exist
  SELECT count(*) INTO v04_func_count FROM pg_proc
    WHERE proname = 'validate_tenant_adapters_config_v0_4';
  IF v04_func_count != 1 THEN
    RAISE EXCEPTION 'v0.4 function not created';
  END IF;

  SELECT count(*) INTO v04_trig_count FROM pg_trigger
    WHERE tgname = 'validate_tenant_adapters_config_v0_4';
  IF v04_trig_count != 1 THEN
    RAISE EXCEPTION 'v0.4 trigger not bound';
  END IF;

  -- v0.3 function + trigger MUST be gone
  SELECT count(*) INTO v03_func_count FROM pg_proc
    WHERE proname = 'validate_tenant_adapters_config_v0_3';
  IF v03_func_count != 0 THEN
    RAISE EXCEPTION 'v0.3 function still present after migration (expected drop)';
  END IF;

  SELECT count(*) INTO v03_trig_count FROM pg_trigger
    WHERE tgname = 'validate_tenant_adapters_config_v0_3';
  IF v03_trig_count != 0 THEN
    RAISE EXCEPTION 'v0.3 trigger still bound after migration (expected drop)';
  END IF;

  RAISE NOTICE 'v0.4 migration smoke passed: validate_tenant_adapters_config_v0_4 active; v0.3 dropped cleanly';
END $$;

COMMIT;

-- ============================================================================
-- End of v0.3 → v0.4 migration
-- ============================================================================
