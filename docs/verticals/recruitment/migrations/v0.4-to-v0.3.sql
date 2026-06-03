-- ============================================================================
-- IFOS recruitment vertical schema — v0.4 → v0.3 rollback
-- ============================================================================
-- Companion rollback for: v0.3-to-v0.4.sql
-- Authored:               2026-06-03 (W5 Day-30)
-- Status:                 DRAFTED; only execute if v0.4 changes break production.
--
-- Rolls back v0.4 additions:
--   - Drops validate_tenant_adapters_config_v0_4 trigger + function
--   - Re-creates validate_tenant_adapters_config_v0_3 trigger + function
--     (restoring the 11-key allowlist + v0.3 type validations verbatim)
--
-- DATA IMPACT: Any tenant_adapters.config row that has populated v0.4-only
-- keys (operator_telegram_chat_id, email_channel, workos_org_id,
-- granola_workspace_id, bullhorn_corporation_id) WILL BE BLOCKED at next
-- UPDATE by the restored v0.3 trigger (unknown-key hard-fail). Operator
-- must clear those sub-keys from existing config rows BEFORE rolling back,
-- OR accept that future updates to those rows fail until the keys are
-- removed. No data is dropped by this rollback itself — only the validator
-- is reverted.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- §1 — Pre-rollback assessment
-- ----------------------------------------------------------------------------
--
-- Surface (non-fatal) any tenant_adapters rows that have v0.4 keys set.
-- Operator can choose to abort + remediate before re-running.

DO $$
DECLARE
  v04_key_users INT := 0;
BEGIN
  -- to_regclass guards against second-rollback / partial state
  IF to_regclass('public.tenant_adapters') IS NOT NULL THEN
    SELECT count(*) INTO v04_key_users FROM tenant_adapters
      WHERE config ?| ARRAY[
        'operator_telegram_chat_id',
        'email_channel',
        'workos_org_id',
        'granola_workspace_id',
        'bullhorn_corporation_id'
      ];
  END IF;
  IF v04_key_users > 0 THEN
    RAISE NOTICE 'WARNING: % tenant_adapters row(s) have v0.4-only keys set; future UPDATEs to these rows will fail under restored v0.3 trigger until those keys are cleared', v04_key_users;
  END IF;
END $$;

-- ----------------------------------------------------------------------------
-- §2 — Drop v0.4 trigger + function
-- ----------------------------------------------------------------------------

DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_4 ON tenant_adapters;
DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_4();

-- ----------------------------------------------------------------------------
-- §3 — Re-create v0.3 function (verbatim from v0.2-to-v0.3.sql §5)
-- ----------------------------------------------------------------------------
--
-- Must be byte-identical to the v0.2-to-v0.3.sql original to ensure the
-- rollback restores the exact v0.3 state. If the original v0.3 function
-- definition changes, this rollback file must be updated in lockstep.

CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
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
    'concierge_send_window'
    -- diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
    -- (per ADR-006 Tier 2); v0.3 trigger does not allowlist this key
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

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- §4 — Re-bind v0.3 trigger
-- ----------------------------------------------------------------------------

DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;

CREATE TRIGGER validate_tenant_adapters_config_v0_3
  BEFORE INSERT OR UPDATE ON tenant_adapters
  FOR EACH ROW
  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();

-- ----------------------------------------------------------------------------
-- §5 — Smoke verification (read-only)
-- ----------------------------------------------------------------------------

DO $$
DECLARE
  v03_func_count INT;
  v03_trig_count INT;
  v04_func_count INT;
  v04_trig_count INT;
BEGIN
  -- v0.3 function + trigger MUST exist
  SELECT count(*) INTO v03_func_count FROM pg_proc
    WHERE proname = 'validate_tenant_adapters_config_v0_3';
  IF v03_func_count != 1 THEN
    RAISE EXCEPTION 'v0.3 function not restored';
  END IF;

  SELECT count(*) INTO v03_trig_count FROM pg_trigger
    WHERE tgname = 'validate_tenant_adapters_config_v0_3';
  IF v03_trig_count != 1 THEN
    RAISE EXCEPTION 'v0.3 trigger not re-bound';
  END IF;

  -- v0.4 function + trigger MUST be gone
  SELECT count(*) INTO v04_func_count FROM pg_proc
    WHERE proname = 'validate_tenant_adapters_config_v0_4';
  IF v04_func_count != 0 THEN
    RAISE EXCEPTION 'v0.4 function still present after rollback (expected drop)';
  END IF;

  SELECT count(*) INTO v04_trig_count FROM pg_trigger
    WHERE tgname = 'validate_tenant_adapters_config_v0_4';
  IF v04_trig_count != 0 THEN
    RAISE EXCEPTION 'v0.4 trigger still bound after rollback (expected drop)';
  END IF;

  RAISE NOTICE 'v0.4 → v0.3 rollback verified: v0.3 trigger + function restored; v0.4 dropped';
END $$;

COMMIT;

-- ============================================================================
-- End of v0.4 → v0.3 rollback
-- ============================================================================
