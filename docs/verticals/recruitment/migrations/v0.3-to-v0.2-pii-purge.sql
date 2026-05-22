-- ============================================================================
-- IFOS recruitment vertical schema — v0.3 → v0.2 PII purge audit column ROLLBACK
-- ============================================================================
-- Reverses v0.2-to-v0.3-pii-purge.sql. Strictly destructive on the audit
-- column; v0.2 data unaffected (text_purged_at column drops away with no
-- side effects on existing recent_edit data).
--
-- WARNING: rollback must run BEFORE any PII purge has set original_text=NULL,
-- or after text has been backfilled from snapshots. Reinstating v0.2's
-- NOT NULL constraint will fail if any purged rows remain NULL.
-- ============================================================================

BEGIN;

ALTER TABLE recent_edit
  ALTER COLUMN original_text SET NOT NULL;

ALTER TABLE recent_edit
  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;

DROP INDEX IF EXISTS recent_edit_text_purged_idx;

ALTER TABLE recent_edit
  DROP COLUMN IF EXISTS text_purged_at;

COMMIT;

-- ============================================================================
-- End of v0.3-to-v0.2-pii-purge.sql
-- ============================================================================
