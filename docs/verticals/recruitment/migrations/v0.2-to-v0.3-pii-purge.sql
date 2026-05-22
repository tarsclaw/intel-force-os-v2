-- ============================================================================
-- IFOS recruitment vertical schema — v0.2 → v0.3 PII purge audit column
-- ============================================================================
-- Companion to: docs/runbooks/pii-purge-operational-pattern.md
-- Authored:     2026-05-22 (Day 11, Founder Decision D3 pre-write)
-- Status:       DRAFTED; awaits D3 founder resolution + D2 SeedLegals advisor
--               input on retention period before live execution.
--
-- Surfaces: Codex Round 1 v0.2 supplement REJECTED issue 4 (PII retention)
--           + Founder Decision D3 (recommended D3-B: 90-day text purge +
--           indefinite metadata)
-- Risk register: #10 (recent_edit raw PII retention vs UK GDPR Art. 5(1)(e))
--
-- This migration is ADDITIVE. Adds one nullable column to recent_edit for
-- audit-trail purposes — when the text-body purge ran on each row. Does NOT
-- yet enact purge (that's the scripts/ifos-pii-purge.sh cron's job once
-- founder confirms retention window from D2 advisor input).
--
-- All v0.3 additions are strictly additive. Rollback at v0.3-to-v0.2.sql.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- §1 — Add text_purged_at audit column to recent_edit
-- ----------------------------------------------------------------------------

ALTER TABLE recent_edit
  ADD COLUMN IF NOT EXISTS text_purged_at TIMESTAMPTZ;

COMMENT ON COLUMN recent_edit.text_purged_at IS
  'NULL = text fields still present (within retention window OR retention disabled). '
  'NOT NULL = text fields NULLed by PII purge cron at the given timestamp. '
  'Per Founder Decision D3 (v1.0 default: 90-day window).';

CREATE INDEX IF NOT EXISTS recent_edit_text_purged_idx
  ON recent_edit (text_purged_at)
  WHERE text_purged_at IS NOT NULL;

-- ----------------------------------------------------------------------------
-- §2 — Optional defence-in-depth CHECK constraint
-- ----------------------------------------------------------------------------
-- If text_purged_at is NOT NULL, both text fields MUST be NULL.
-- Catches accidental writes to a purged row.
-- ----------------------------------------------------------------------------

ALTER TABLE recent_edit
  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;

ALTER TABLE recent_edit
  ADD CONSTRAINT recent_edit_text_purged_consistency CHECK (
    text_purged_at IS NULL
    OR (original_text IS NULL AND edited_text IS NULL)
  );

-- ----------------------------------------------------------------------------
-- §3 — Per-tenant retention override storage (tenant_adapters extension)
-- ----------------------------------------------------------------------------
-- D3-C compatibility: tenants can request extended retention via TOS
-- amendment. Storage is tenant_adapters.config.pii_retention_days
-- (existing JSONB shape; no new column needed). Value is integer in
-- [30, 365] OR null (use v1.0 default of 90).
--
-- No DDL required for this — it's a JSONB key in an existing column.
-- The PII purge cron reads tenant_adapters for the override per tenant.
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- §4 — Verification queries (run after COMMIT)
-- ----------------------------------------------------------------------------

-- SELECT column_name, data_type, is_nullable FROM information_schema.columns
--   WHERE table_name='recent_edit' AND column_name='text_purged_at';
-- → expect 1 row: text_purged_at | timestamp with time zone | YES
--
-- SELECT constraint_name FROM information_schema.table_constraints
--   WHERE table_name='recent_edit' AND constraint_name='recent_edit_text_purged_consistency';
-- → expect 1 row
--
-- SELECT indexname FROM pg_indexes
--   WHERE tablename='recent_edit' AND indexname='recent_edit_text_purged_idx';
-- → expect 1 row

COMMIT;

-- ============================================================================
-- End of v0.2-to-v0.3-pii-purge.sql
-- ============================================================================
