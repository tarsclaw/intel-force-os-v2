# Codex ratification skill — review-postgres-migration

Type-specific checks for: `.sql` files under `docs/verticals/recruitment/migrations/`, Day-4 provisioning runbook (`docs/runbooks/day-4-provisioning.md` §6 schema sections), any DDL/DML proposed in artefacts.

This skill ADDS to the top-level `SKILL.md`. Apply that first; everything below is incremental.

---

## §1 — Transaction discipline

Every migration MUST be wrapped in a single transaction:

```sql
BEGIN;
-- DDL + DML
COMMIT;
```

REJECT if:
- The migration is missing `BEGIN`/`COMMIT`
- The migration has multiple `COMMIT` statements (partial-failure risk)
- DDL is interleaved with `COMMIT` (each statement should be atomic with prior + later operations)
- The rollback SQL is just `-- TODO`

For PostgreSQL, DDL (`CREATE TABLE`, `ALTER TABLE`, `CREATE INDEX`) IS transactional. Use this.

---

## §2 — RLS policy invariant

IFOS is multi-tenant with RLS isolation per tenant_slug (Day-4 §6.3, §7). Every NEW table that holds tenant data MUST:

1. Have a `tenant_slug TEXT NOT NULL` column
2. `ALTER TABLE <name> ENABLE ROW LEVEL SECURITY`
3. `CREATE POLICY <name>_tenant_isolation ON <name> USING (tenant_slug = current_setting('ifos.tenant_slug', TRUE))`

REJECT if a new table omits any of these three. (Day-4 §7 RLS isolation gate passed all 5 conditions; new tables must extend that posture, not weaken it.)

Auxiliary tables that are scoped per-tenant (e.g., `voice_corpus_chunks` referencing `voice_corpus(id)`) MUST also carry their OWN `tenant_slug` column + RLS policy — not rely on the parent table's RLS. (Joins with FK can be subverted; per-table RLS cannot.)

---

## §3 — Idempotency

Migrations MUST be idempotent — running twice produces the same end state. Required patterns:

- `CREATE TABLE IF NOT EXISTS` (not bare `CREATE TABLE`)
- `CREATE INDEX IF NOT EXISTS` (not bare `CREATE INDEX`)
- `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` (where supported) OR a DO block that probes for existence
- INSERTs of seed data MUST use `ON CONFLICT ... DO NOTHING` or `ON CONFLICT ... DO UPDATE`
- Triggers: `DROP TRIGGER IF EXISTS` before `CREATE TRIGGER` (re-creating with new definition)

REJECT if any DDL statement is non-idempotent (`CREATE TABLE foo`) — re-running the migration will fail with "table already exists".

Sample-check: does the migration script run successfully ON A FRESH DATABASE AND ON A DATABASE WHERE IT'S ALREADY APPLIED? If the second case fails, REJECT.

---

## §4 — pgvector index correctness

For `voice_samples_embedded` and similar pgvector ANN indexes:

- Extension `vector` must be verified present BEFORE creating the index (DO block probe is acceptable; bare `CREATE EXTENSION IF NOT EXISTS vector` is fine if grants allow)
- Index type SHOULD be `hnsw` (preferred for < 100k chunks/tenant) or `ivfflat` (better for > 1M chunks)
- Distance metric MUST be specified explicitly: `vector_cosine_ops`, `vector_l2_ops`, or `vector_ip_ops` — NEVER use the default
- Index params (`m`, `ef_construction` for HNSW; `lists` for IVFFlat) MUST be set explicitly with documented reasoning

REJECT if any of these are missing.

Cross-check the embedding dimensions:
- `embedding vector(N)` where N matches the embedding model's output dimensions
- For `text-embedding-3-small`: N = 1536 ✓
- For `text-embedding-3-large`: N = 3072
- For `text-embedding-ada-002` (deprecated): N = 1536

REJECT if the dimension doesn't match the embedding model named in the supplement YAML.

---

## §5 — GRANT discipline

IFOS uses two Postgres roles per Day-4 §6.3: `ifos_app` (app role) and the migration runner (DDL role; typically `postgres` or a dedicated migrator).

Every new table MUST have explicit GRANTs to `ifos_app`:

- `SELECT, INSERT, UPDATE` for mutable tables (`voice_corpus`, `tone_rule`)
- `SELECT, INSERT, UPDATE, DELETE` for append-and-purge (`voice_corpus_chunks`)
- `SELECT, INSERT` for append-only (`recent_edit`, `decision_log`)

REJECT if a table is created without explicit GRANTs.

For sequences (BIGSERIAL columns auto-create them), `GRANT USAGE, SELECT ON SEQUENCE <table>_id_seq TO ifos_app` is required for `ifos_app` to insert rows.

REJECT if BIGSERIAL columns are added without granting sequence access.

---

## §6 — Append-only enforcement (decision_log + recent_edit)

`decision_log` is append-only per Day-4 §6.3 + master brief §3.3 audit discipline. `recent_edit` extends this pattern per v0.2 supplement.

Required: `ifos_app` has NO `DELETE` or `UPDATE` on these tables. Migration MUST NOT issue:

```sql
GRANT UPDATE, DELETE ON decision_log TO ifos_app;  -- REJECT
GRANT UPDATE, DELETE ON recent_edit  TO ifos_app;  -- REJECT
```

REJECT immediately if these grants are present.

---

## §7 — CHECK constraint validity

Enums in IFOS are encoded as CHECK constraints (not Postgres ENUM types — too rigid for schema evolution). Verify:

- `decision_log.phase` CHECK constraint matches Day-4 §6.3 + Day-5 schema migration:
  - v1.0 set: `('trigger', 'output', 'action', 'gating_failed', 'agent_handoff')` — 5 values
  - REJECT if migration ADDS to this CHECK constraint without explicitly stating which values it adds
  - REJECT if migration REPLACES the constraint with a smaller set (data integrity loss)

- Status / severity / tier enums use the same pattern:
  - `tone_rule.severity` CHECK IN ('info', 'warn', 'block')
  - `voice_corpus.chunking_strategy` CHECK IN ('paragraph', 'sentence-window-5', 'semantic-segment-v1')
  - `recent_edit.resolution` CHECK IN ('approved_verbatim', 'approved_after_edit', 'rejected', 'deferred')

REJECT if a CHECK constraint is missing OR if its allowed values don't match the schema YAML's enum.

---

## §8 — Trigger correctness (entity validators)

For triggers that validate JSONB content (e.g., `validate_voice_scores` from v0.2):

- Trigger function MUST be created BEFORE the trigger references it
- Trigger MUST be `DROP TRIGGER IF EXISTS` first, then `CREATE TRIGGER`
- Trigger SHOULD be `BEFORE INSERT OR UPDATE` (not `AFTER`) for validation
- `FOR EACH ROW` (validating per-row); not `STATEMENT`
- WHEN clause SHOULD restrict to relevant entity_types (don't validate every row in `entities`)

REJECT if any of these are missing.

Validate the function body:

- Raises `EXCEPTION` (not `WARNING`) on validation failure — must block bad writes
- Uses `RAISE EXCEPTION` with a clear message including the offending field name + value
- Returns `NEW` from `BEFORE` triggers (otherwise the row is silently dropped)

REJECT if the function uses `RAISE WARNING` instead of `RAISE EXCEPTION`, or returns wrong/missing value.

---

## §9 — Rollback SQL must work

The companion rollback file (e.g., `v0.2-to-v0.1.sql`) MUST:

1. Be the SQL inverse of the forward migration
2. Drop in reverse dependency order (e.g., `recent_edit` → `tone_rule` → `voice_corpus_chunks` → `voice_corpus`)
3. Use `DROP TABLE IF EXISTS ... CASCADE` (CASCADE drops dependent FKs/triggers cleanly)
4. Drop triggers + trigger functions
5. Drop indexes (usually auto-dropped with their table; CASCADE handles this)
6. NOT delete v0.1 data — supplement is additive; rollback only removes what was added

REJECT if:
- Rollback drops tables that pre-existed before the forward migration (catastrophic)
- Rollback contains `TRUNCATE` instead of `DROP TABLE`
- Rollback omits trigger function drops (leaves orphaned PL/pgSQL functions)
- Rollback references tables not present in the forward migration

---

## §10 — Seed data discipline

Seed INSERT rows in migrations MUST:

- Be scoped to test/non-production tenants only (e.g., `migration-test`)
- Use `ON CONFLICT DO NOTHING` for idempotency
- Be minimal — one row to verify schema shape, not real data

REJECT if:
- A migration seeds rows under a production tenant_slug
- Seed data lacks `ON CONFLICT DO NOTHING`
- Seed data attempts to bypass NOT NULL constraints (writing `NULL` to required fields)

---

## §11 — Common false-RATIFY traps

- **Missing pgvector extension verify** — migration uses `vector(1536)` but doesn't check `pg_extension WHERE extname='vector'`. If extension is missing, migration fails midway with cryptic error. REJECT and demand a DO block probe.

- **CASCADE in CREATE FOREIGN KEY** — `REFERENCES voice_corpus(id) ON DELETE CASCADE` is fine; `ON UPDATE CASCADE` is suspicious for tenant_slug FKs (tenant slugs are pseudo-immutable; UPDATE cascade implies they change). Check that ON UPDATE CASCADE is intentional.

- **Index on JSONB without GIN/GIST** — `CREATE INDEX foo_data_key_idx ON entities (data->>'voice_classifier_score')` works but is suboptimal for non-equality queries. Either use a GIN index OR the JSONB key extraction must be cast appropriately. Advisory; not a hard reject.

- **Index without partial WHERE clause** — for `is_active`-flag-style tables, queries usually filter `WHERE is_active=TRUE`. A partial index on the active subset is more efficient than a full index. Advisory; not a hard reject.

- **Trigger on every row in entities** — entities can grow to millions of rows; a trigger that fires on every entity row instead of WHEN-clause-restricted to relevant entity_types is a performance disaster. REJECT.

- **Missing session variable for RLS** — RLS policies reference `current_setting('ifos.tenant_slug')`. If the migration script itself executes RLS-protected operations without `SET LOCAL ifos.tenant_slug`, those operations fail silently (return 0 rows) or fail loudly. REJECT if the migration's own seed INSERTs lack `SET LOCAL ifos.tenant_slug = '<slug>'` before the INSERT.

---

## §12 — Multi-tenant safety sample check

Run mentally through this scenario:

```
Tenant A sets ifos.tenant_slug='acme'; SELECT * FROM voice_corpus_chunks;
Tenant B sets ifos.tenant_slug='globex'; SELECT * FROM voice_corpus_chunks;
```

Both queries must return only their own tenant's rows. If the migration's RLS policy uses `current_setting('ifos.tenant_slug', TRUE)` (the TRUE = missing_ok), check that:

- When the setting is missing, the query returns 0 rows (NOT all rows)
- When the setting is `'acme'`, only Acme rows are returned

If the policy text could be misread as "return all rows when setting missing" (i.e., uses `OR current_setting(...) IS NULL`), REJECT — this is a cross-tenant leak.

---

## §13 — Quick checklist

- [ ] Wrapped in BEGIN ... COMMIT
- [ ] Every new tenant-data table has tenant_slug + RLS ENABLE + tenant_isolation policy
- [ ] CREATE TABLE / INDEX use IF NOT EXISTS
- [ ] BIGSERIAL columns have GRANT USAGE on the sequence
- [ ] decision_log + recent_edit GRANTs are SELECT, INSERT only (no UPDATE/DELETE)
- [ ] pgvector indexes have explicit ops class + params + dimensions match embedding model
- [ ] CHECK constraints match the schema YAML's enums
- [ ] Triggers DROP IF EXISTS first; validate via RAISE EXCEPTION; return NEW
- [ ] Rollback SQL is the inverse + drops in reverse dependency order + uses CASCADE
- [ ] Seed data scoped to test tenants + uses ON CONFLICT DO NOTHING
- [ ] No catastrophic patterns (truncate, drop unrelated tables, missing RLS on new tables)

If all clear: RATIFIED.
If any fail: REJECTED with numbered issues citing specific SQL lines.
