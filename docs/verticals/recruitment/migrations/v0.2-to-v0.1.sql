-- ============================================================================
-- IFOS recruitment vertical schema — v0.2 → v0.1 ROLLBACK
-- ============================================================================
-- Reverses every statement in v0.1-to-v0.2.sql. Strictly destructive: drops
-- all v0.2 tables + their data + the validation trigger. Run ONLY if v0.2
-- needs to be unwound (e.g., Codex rejects v0.2 + a clean revert is preferred
-- over patch-fix).
--
-- v0.1 data is untouched (v0.2 adds tables/keys; doesn't mutate v0.1 rows).
-- Post-rollback, v0.1 reads continue working identically.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- §1 — Drop entities validation trigger
-- ----------------------------------------------------------------------------

DROP TRIGGER IF EXISTS validate_voice_scores ON entities;
DROP FUNCTION IF EXISTS validate_voice_score_fields();

-- ----------------------------------------------------------------------------
-- §2 — Drop v0.2 tables (in reverse-dependency order)
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS recent_edit          CASCADE;
DROP TABLE IF EXISTS tone_rule            CASCADE;
DROP TABLE IF EXISTS voice_corpus_chunks  CASCADE;
DROP TABLE IF EXISTS voice_corpus         CASCADE;

-- ----------------------------------------------------------------------------
-- §3 — Optional: purge voice_classifier_score / voice_drift_at_close keys
--      from any entities.data JSONB blobs that wrote v0.2 fields.
--      Commented out by default — keys are nullable; orphan keys are harmless
--      and reverting the data preserves audit trail of what was written.
-- ----------------------------------------------------------------------------

-- UPDATE entities
-- SET data = data - 'voice_classifier_score' - 'voice_drift_at_close'
-- WHERE entity_type IN ('candidate', 'contractor', 'contact', 'brief', 'opportunity', 'placement')
--   AND (data ? 'voice_classifier_score' OR data ? 'voice_drift_at_close');

COMMIT;
