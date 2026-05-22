-- ============================================================================
-- IFOS recruitment vertical schema — v0.3 → v0.2 PII purge audit column ROLLBACK
-- ============================================================================
-- Reverses v0.2-to-v0.3-pii-purge.sql. Strictly destructive on the audit
-- column; v0.2 data unaffected (text_purged_at column drops away with no
-- side effects on existing recent_edit data).
-- ============================================================================

BEGIN;

ALTER TABLE recent_edit
  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;

DROP INDEX IF EXISTS recent_edit_text_purged_idx;

ALTER TABLE recent_edit
  DROP COLUMN IF EXISTS text_purged_at;

COMMIT;

-- ============================================================================
-- End of v0.3-to-v0.2-pii-purge.sql
-- ============================================================================
