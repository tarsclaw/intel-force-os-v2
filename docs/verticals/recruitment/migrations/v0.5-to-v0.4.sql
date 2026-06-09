-- ============================================================================
-- IFOS recruitment vertical schema — v0.5 → v0.4 rollback
-- ============================================================================
-- Companion to: v0.4-to-v0.5.sql
-- Authored:     2026-06-09 (W7 Cash Conductor P3 reconciliation build slice)
--
-- Reverses v0.5 by dropping the two reconciliation write-back tracking columns
-- and the write-queue partial index from cash_conductor_transactions. DESTRUCTIVE
-- for any data held in reconciliation_written_at / accounting_payment_id — only
-- run if no reconciliation writes have been recorded that you need to preserve.
--
-- Execution order: BEGIN; <each block>; COMMIT;   on success.
--                  BEGIN; <each block>; ROLLBACK; on any error.
-- ============================================================================

BEGIN;

DROP INDEX IF EXISTS idx_cct_tenant_writeable;

ALTER TABLE cash_conductor_transactions
  DROP COLUMN IF EXISTS reconciliation_written_at,
  DROP COLUMN IF EXISTS accounting_payment_id;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cash_conductor_transactions'
      AND column_name IN ('reconciliation_written_at', 'accounting_payment_id')
  ) THEN
    RAISE EXCEPTION 'v0.5 → v0.4 rollback: write-back columns still present after drop';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_cct_tenant_writeable') THEN
    RAISE EXCEPTION 'v0.5 → v0.4 rollback: idx_cct_tenant_writeable still present after drop';
  END IF;
  RAISE NOTICE 'v0.5 → v0.4 rollback verified: write-back columns + write-queue index dropped';
END $$;

COMMIT;

-- ============================================================================
-- End of v0.5 → v0.4 rollback
-- ============================================================================
