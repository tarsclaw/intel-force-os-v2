-- ============================================================================
-- IFOS recruitment vertical schema — v0.1 → v0.2 migration
-- ============================================================================
-- Companion to: docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
-- Authored:     2026-05-20 (Phase 4 of bubbly-snuggling-lantern.md plan)
-- Status:       DRAFTED; NOT executed against production Hetzner Postgres yet.
--               Phase 5 executes against migration-test tenant first.
--
-- Closes Day-7-honest-read gap #1 (voice corpus schema). v0.2 additions:
--   - 3 new tables: voice_corpus, tone_rule, recent_edit
--   - 1 auxiliary table: voice_corpus_chunks (holds the pgvector index)
--   - 1 pgvector HNSW index: voice_samples_embedded
--   - 6 nullable score columns on existing entities table (via JSONB extension —
--     entities.data uses JSONB so no ALTER TABLE needed for the new keys)
--   - 2 entity_links link_type values (voice_corpus_governs_tone_rules,
--     recent_edit_drives_retraining); also JSONB-backed in entity_links.metadata
--
-- All v0.2 additions are STRICTLY ADDITIVE. Rollback path is documented in
-- companion v0.2-to-v0.1.sql (DROP TABLE + DELETE FROM patterns).
--
-- Prerequisites verified at Day-4 §6.5:
--   - pgvector >= 0.8.0 (HNSW indexes require >= 0.5.0; 0.8 ships at Day-4)
--   - RLS policies on entities + entity_links + decision_log already in place
--
-- Execution order: BEGIN; <each block>; COMMIT;   on success.
--                  BEGIN; <each block>; ROLLBACK; on any error.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- §1 — Verify prerequisite extensions
-- ----------------------------------------------------------------------------

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'vector') THEN
    RAISE EXCEPTION 'pgvector extension not installed; ensure Day-4 §6.5 provisioning ran';
  END IF;
END $$;

-- ----------------------------------------------------------------------------
-- §2 — Create voice_corpus table (per-tenant voice pack)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS voice_corpus (
  id                    BIGSERIAL PRIMARY KEY,
  tenant_slug           TEXT        NOT NULL,
  version               TEXT        NOT NULL,
  source_doc_count      INTEGER     NOT NULL CHECK (source_doc_count >= 0),
  source_doc_origin     TEXT[]      NOT NULL DEFAULT '{}',
  chunk_count           INTEGER     NOT NULL CHECK (chunk_count >= 0),
  chunking_strategy     TEXT        NOT NULL CHECK (chunking_strategy IN ('paragraph', 'sentence-window-5', 'semantic-segment-v1')),
  embedding_model       TEXT        NOT NULL,
  last_indexed_at       TIMESTAMPTZ NOT NULL,
  is_active             BOOLEAN     NOT NULL DEFAULT FALSE,
  ingest_completion_ms  INTEGER,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT voice_corpus_tenant_version_unique UNIQUE (tenant_slug, version)
);

-- Partial unique index: at most one active voice_corpus per tenant
CREATE UNIQUE INDEX IF NOT EXISTS voice_corpus_one_active_per_tenant
  ON voice_corpus (tenant_slug)
  WHERE is_active = TRUE;

CREATE INDEX IF NOT EXISTS voice_corpus_tenant_slug_idx ON voice_corpus (tenant_slug);

ALTER TABLE voice_corpus ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS voice_corpus_tenant_isolation ON voice_corpus;
CREATE POLICY voice_corpus_tenant_isolation ON voice_corpus
  USING (tenant_slug = current_setting('app.current_tenant', TRUE));

-- ----------------------------------------------------------------------------
-- §3 — Create voice_corpus_chunks table (pgvector substrate)
-- ----------------------------------------------------------------------------
-- One row per chunk produced from voice_corpus source docs. Embedding column
-- is the indexed surface for hh_load_voice_samples semantic retrieval.
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS voice_corpus_chunks (
  id                BIGSERIAL PRIMARY KEY,
  tenant_slug       TEXT        NOT NULL,
  voice_corpus_id   BIGINT      NOT NULL REFERENCES voice_corpus (id) ON DELETE CASCADE,
  chunk_index       INTEGER     NOT NULL,
  text_chunk        TEXT        NOT NULL,
  source_doc_ref    TEXT,
  embedding         vector(1536),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT voice_corpus_chunks_corpus_chunk_unique UNIQUE (voice_corpus_id, chunk_index)
);

CREATE INDEX IF NOT EXISTS voice_corpus_chunks_tenant_idx ON voice_corpus_chunks (tenant_slug);
CREATE INDEX IF NOT EXISTS voice_corpus_chunks_corpus_idx ON voice_corpus_chunks (voice_corpus_id);

-- HNSW index for cosine-distance ANN queries (Q11 default A: store both)
CREATE INDEX IF NOT EXISTS voice_samples_embedded
  ON voice_corpus_chunks
  USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

ALTER TABLE voice_corpus_chunks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks;
CREATE POLICY voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks
  USING (tenant_slug = current_setting('app.current_tenant', TRUE));

-- ----------------------------------------------------------------------------
-- §4 — Create tone_rule table
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tone_rule (
  id                  BIGSERIAL PRIMARY KEY,
  tenant_slug         TEXT        NOT NULL,
  rule_id             TEXT        NOT NULL,
  rule_text           TEXT        NOT NULL,
  severity            TEXT        NOT NULL CHECK (severity IN ('info', 'warn', 'block')),
  applies_to_agents   TEXT[]      NOT NULL DEFAULT '{}',
  enabled             BOOLEAN     NOT NULL DEFAULT TRUE,
  created_by          TEXT        NOT NULL CHECK (created_by IN ('founder', 'tenant-admin', 'ifos-csm')),
  examples_positive   TEXT[],
  examples_negative   TEXT[],
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT tone_rule_tenant_rule_id_unique UNIQUE (tenant_slug, rule_id)
);

CREATE INDEX IF NOT EXISTS tone_rule_tenant_enabled_idx ON tone_rule (tenant_slug, enabled);

ALTER TABLE tone_rule ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tone_rule_tenant_isolation ON tone_rule;
CREATE POLICY tone_rule_tenant_isolation ON tone_rule
  USING (tenant_slug = current_setting('app.current_tenant', TRUE));

-- ----------------------------------------------------------------------------
-- §5 — Create recent_edit table
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS recent_edit (
  id                     BIGSERIAL PRIMARY KEY,
  tenant_slug            TEXT        NOT NULL,
  agent_name             TEXT        NOT NULL,
  action_type            TEXT        NOT NULL,
  target_entity_type     TEXT,
  target_entity_id       TEXT,
  original_text          TEXT        NOT NULL,
  edited_text            TEXT,
  edit_distance          INTEGER     CHECK (edit_distance IS NULL OR edit_distance >= 0),
  resolution             TEXT        NOT NULL CHECK (resolution IN ('approved_verbatim', 'approved_after_edit', 'rejected', 'deferred')),
  resolved_at            TIMESTAMPTZ NOT NULL,
  tone_rules_triggered   TEXT[]      NOT NULL DEFAULT '{}',
  created_at             TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Length caps enforced at insert time by operator UX, not DDL (Postgres TEXT
-- has no natural cap; the v0.2 schema doc declares 8192 chars + truncation).

CREATE INDEX IF NOT EXISTS recent_edit_tenant_agent_idx ON recent_edit (tenant_slug, agent_name, resolved_at DESC);
CREATE INDEX IF NOT EXISTS recent_edit_tenant_action_idx ON recent_edit (tenant_slug, action_type, resolved_at DESC);
CREATE INDEX IF NOT EXISTS recent_edit_lookback_idx ON recent_edit (tenant_slug, resolved_at DESC);

ALTER TABLE recent_edit ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS recent_edit_tenant_isolation ON recent_edit;
CREATE POLICY recent_edit_tenant_isolation ON recent_edit
  USING (tenant_slug = current_setting('app.current_tenant', TRUE));

-- ----------------------------------------------------------------------------
-- §6 — Grants for ifos_app role
-- ----------------------------------------------------------------------------
-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
-- Voice corpus + tone_rule are mutable (re-index + rule revisions).
-- ----------------------------------------------------------------------------

GRANT SELECT, INSERT, UPDATE        ON voice_corpus        TO ifos_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON voice_corpus_chunks TO ifos_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON tone_rule           TO ifos_app;
GRANT SELECT, INSERT                 ON recent_edit         TO ifos_app;

GRANT USAGE, SELECT ON SEQUENCE voice_corpus_id_seq        TO ifos_app;
GRANT USAGE, SELECT ON SEQUENCE voice_corpus_chunks_id_seq TO ifos_app;
GRANT USAGE, SELECT ON SEQUENCE tone_rule_id_seq           TO ifos_app;
GRANT USAGE, SELECT ON SEQUENCE recent_edit_id_seq         TO ifos_app;

-- ----------------------------------------------------------------------------
-- §7 — Extend entities.data JSONB with 6 voice-score keys
-- ----------------------------------------------------------------------------
-- entities.data is JSONB so the 6 new fields land as keys, no DDL needed for
-- the field additions themselves. We DO add validation triggers to ensure
-- the score values stay in [0.0, 1.0] when present.
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION validate_voice_score_fields()
RETURNS TRIGGER AS $$
DECLARE
  score_keys TEXT[] := ARRAY['voice_classifier_score', 'voice_drift_at_close'];
  k TEXT;
  v JSONB;
BEGIN
  FOREACH k IN ARRAY score_keys LOOP
    v := NEW.data -> k;
    IF v IS NOT NULL AND jsonb_typeof(v) != 'null' THEN
      IF jsonb_typeof(v) != 'number' THEN
        RAISE EXCEPTION 'entities.data.% must be number; got %', k, jsonb_typeof(v);
      END IF;
      IF (v::TEXT)::NUMERIC < 0.0 OR (v::TEXT)::NUMERIC > 1.0 THEN
        RAISE EXCEPTION 'entities.data.% out of range [0.0, 1.0]: %', k, v::TEXT;
      END IF;
    END IF;
  END LOOP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Postgres 14+ CREATE OR REPLACE TRIGGER is idempotent without requiring
-- table ownership. DROP TRIGGER would require ownership (entities is owned
-- by postgres; ifos_app has only TRIGGER privilege from Day-11 GRANT).
CREATE OR REPLACE TRIGGER validate_voice_scores
  BEFORE INSERT OR UPDATE ON entities
  FOR EACH ROW
  WHEN (NEW.entity_type IN ('candidate', 'contractor', 'contact', 'brief', 'opportunity', 'placement'))
  EXECUTE FUNCTION validate_voice_score_fields();

-- ----------------------------------------------------------------------------
-- §8 — Register v0.2 link_types in entity_links
-- ----------------------------------------------------------------------------
-- entity_links.link_type is TEXT; we add a soft-enum CHECK constraint update
-- only if a constraint exists. If link_type is unconstrained, no migration
-- needed — the new values land as data.
-- ----------------------------------------------------------------------------

-- Probe + extend the entity_links.link_type CHECK constraint if present.
-- (Day-4 §6.3 declares link_type as TEXT without CHECK by default; this DO
-- block is defensive for the case where v0.1 added a CHECK we need to widen.)
DO $$
DECLARE
  existing_check TEXT;
BEGIN
  SELECT pg_get_constraintdef(c.oid) INTO existing_check
  FROM pg_constraint c
  JOIN pg_class t ON c.conrelid = t.oid
  WHERE t.relname = 'entity_links' AND c.conname LIKE '%link_type%';
  -- If no CHECK exists, do nothing; new values insert freely.
  -- If CHECK exists, surface for manual review (DDL changes to CHECK
  -- constraints require recreation; out of scope for this migration).
  IF existing_check IS NOT NULL THEN
    RAISE NOTICE 'entity_links.link_type CHECK constraint exists: %; new link_types may need manual extension', existing_check;
  END IF;
END $$;

-- ----------------------------------------------------------------------------
-- §9 — Reference rows: seed migration-test tenant with a starter voice_corpus
-- ----------------------------------------------------------------------------
-- Inserts a single empty active voice_corpus row for migration-test only.
-- This lets Phase 5 voice-loader.sh return a defined-empty result rather
-- than failing on no-corpus-found.
-- ----------------------------------------------------------------------------

SET LOCAL app.current_tenant = 'migration-test';

INSERT INTO voice_corpus (
  tenant_slug, version, source_doc_count, source_doc_origin,
  chunk_count, chunking_strategy, embedding_model,
  last_indexed_at, is_active, ingest_completion_ms
) VALUES (
  'migration-test',
  'v0.2-seed',
  0,
  '{}',
  0,
  'paragraph',
  'text-embedding-3-small',
  now(),
  TRUE,
  0
) ON CONFLICT (tenant_slug, version) DO NOTHING;

-- ----------------------------------------------------------------------------
-- §10 — Verification queries (run after COMMIT)
-- ----------------------------------------------------------------------------
-- These are SELECTs for the operator to run post-migration to confirm shape.
-- Wrapped in comments so the migration script itself is idempotent + clean.
-- ----------------------------------------------------------------------------

-- SELECT count(*) FROM voice_corpus WHERE tenant_slug = 'migration-test';
--   → expect 1
-- SELECT indexname FROM pg_indexes WHERE tablename = 'voice_corpus_chunks';
--   → expect: voice_corpus_chunks_pkey, voice_corpus_chunks_tenant_idx,
--             voice_corpus_chunks_corpus_idx, voice_samples_embedded
-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');
--   → expect 4 rows
-- SELECT tgname FROM pg_trigger WHERE tgrelid = 'entities'::regclass;
--   → expect validate_voice_scores

COMMIT;

-- ============================================================================
-- End of v0.1-to-v0.2.sql
-- ============================================================================
