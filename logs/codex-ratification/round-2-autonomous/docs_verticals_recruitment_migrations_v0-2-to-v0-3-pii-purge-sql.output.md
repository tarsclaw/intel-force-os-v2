REJECTED

1. The migration does not make `recent_edit.original_text` nullable, so the companion purge cron cannot satisfy its own redaction contract. Existing v0.2 DDL declares `original_text TEXT NOT NULL` (`v0.1-to-v0.2.sql` lines 135-143). This migration adds `text_purged_at` and a CHECK requiring `original_text IS NULL` when purged (lines 28-54), but never drops the NOT NULL constraint. Any purge UPDATE that sets `original_text = NULL` will fail.
   Proposed fix: add `ALTER TABLE recent_edit ALTER COLUMN original_text DROP NOT NULL;` before the CHECK constraint, and update verification queries to assert `original_text` is nullable after migration.

2. The migration comment claims the cron reads per-tenant overrides from `tenant_adapters` (lines 57-65), but the current script does not implement per-tenant override reads; it uses one global `--retention-days` value.
   Proposed fix: either implement override reads before ratifying the migration/runbook bundle, or change the migration comment to reserve the JSONB key for a later migration.
