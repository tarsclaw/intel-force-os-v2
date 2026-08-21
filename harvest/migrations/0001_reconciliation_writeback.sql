-- ============================================================================
-- IFOS recruitment vertical schema — v0.4 → v0.5 migration
-- ============================================================================
-- Authored:     2026-06-09 (W7 Cash Conductor P3 reconciliation build slice)
-- Status:       DRAFTED; NOT executed against production Hetzner Postgres yet.
--               Execute against migration-test tenant first via run-live-migration.sh.
--
-- ADDITIVE-ONLY. v0.5 adds two columns to cash_conductor_transactions so the
-- Cash Conductor §4 Step 6 reconciliation write can track write-back state
-- per transaction (idempotency / double-pay prevention):
--   - reconciliation_written_at  TIMESTAMPTZ  — set when the payment-received
--       row was successfully written to the tenant accounting system. NULL =
--       not yet written. match_status='matched' cannot carry this signal
--       because its CHECK constraint only permits unmatched|matched|ambiguous.
--   - accounting_payment_id      TEXT         — the provider payment id returned
--       by writePaymentReceived (Xero PaymentID / QB Payment.Id); the audit link
--       from a bank transaction to the accounting payment it created.
--
-- Plus one partial index supporting the Step 6 write-queue scan
-- (matched-but-not-yet-written rows per tenant).
--
-- ALL OTHER v0.4 STATE PRESERVED VERBATIM:
--   - cash_conductor_transactions existing columns + constraints: unchanged
--   - cash_conductor_invoices: unchanged
--   - validate_tenant_adapters_config_v0_4 function + trigger: unchanged
--   - voice_corpus / voice_corpus_chunks / tone_rule / recent_edit: unchanged
--   - RLS policies + ifos_app grants: unchanged
--   - decision_log payload shape: unchanged
--
-- Rollback path: companion v0.5-to-v0.4.sql.
--
-- Prerequisites:
--   - v0.4 migration applied (validate_tenant_adapters_config_v0_4 trigger exists)
--   - cash_conductor_transactions table present
--   - RLS policies + ifos_app grants from Day-4 §6.3 in place
--
-- Execution order: BEGIN; <each block>; COMMIT;   on success.
--                  BEGIN; <each block>; ROLLBACK; on any error.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- §1 — Verify prerequisite v0.4 state
-- ----------------------------------------------------------------------------

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'validate_tenant_adapters_config_v0_4'
  ) THEN
    RAISE EXCEPTION 'v0.4 validate_tenant_adapters_config_v0_4 trigger missing; run v0.3-to-v0.4.sql first';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'cash_conductor_transactions') THEN
    RAISE EXCEPTION 'cash_conductor_transactions table missing; run v0.2-to-v0.3.sql first';
  END IF;
END $$;

-- ----------------------------------------------------------------------------
-- §2 — Add reconciliation write-back tracking columns (additive)
-- ----------------------------------------------------------------------------

ALTER TABLE cash_conductor_transactions
  ADD COLUMN IF NOT EXISTS reconciliation_written_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS accounting_payment_id     TEXT;

COMMENT ON COLUMN cash_conductor_transactions.reconciliation_written_at IS
  'Cash Conductor §4 Step 6: timestamp the matched payment was written to the tenant accounting system; NULL = pending. Idempotency guard against double-pay.';
COMMENT ON COLUMN cash_conductor_transactions.accounting_payment_id IS
  'Cash Conductor §4 Step 6: provider payment id returned by writePaymentReceived (Xero PaymentID / QB Payment.Id).';

-- Write-queue scan index: matched transactions awaiting a reconciliation write,
-- per tenant (Step 6 selects exactly this set).
CREATE INDEX IF NOT EXISTS idx_cct_tenant_writeable
  ON cash_conductor_transactions (tenant_slug)
  WHERE match_status = 'matched' AND reconciliation_written_at IS NULL;

-- ----------------------------------------------------------------------------
-- §3 — Smoke: columns + index present
-- ----------------------------------------------------------------------------

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cash_conductor_transactions'
      AND column_name = 'reconciliation_written_at'
  ) THEN
    RAISE EXCEPTION 'v0.5: reconciliation_written_at column not added';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cash_conductor_transactions'
      AND column_name = 'accounting_payment_id'
  ) THEN
    RAISE EXCEPTION 'v0.5: accounting_payment_id column not added';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE indexname = 'idx_cct_tenant_writeable'
  ) THEN
    RAISE EXCEPTION 'v0.5: idx_cct_tenant_writeable index not created';
  END IF;
  RAISE NOTICE 'v0.5 migration smoke passed: reconciliation write-back columns + write-queue index present';
END $$;

COMMIT;

-- ============================================================================
-- End of v0.4 → v0.5 migration
-- ============================================================================
