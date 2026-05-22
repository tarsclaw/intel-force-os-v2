REJECTED

1. The companion forward migration uses the removed PostgreSQL `pg_constraint.consrc` column. `vertical-schema.v0.2-supplement.yaml` cites `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` as its companion (lines 13-14 and 363-365), but that SQL selects `consrc` from `pg_constraint` (migration lines 231-234). On supported PostgreSQL 12+ this column no longer exists, so the migration can fail before v0.2 lands.
   Proposed fix: replace `consrc` with `pg_get_constraintdef(c.oid)` in `v0.1-to-v0.2.sql`, or remove the defensive CHECK probe if the Day-4 schema guarantees no link_type constraint.

2. The document still ratifies indefinite raw-text retention as the v0.2 default while admitting the field can contain PII. `original_text` is stored verbatim (lines 224-229), the note acknowledges names/salaries can appear (line 259), and Q13 keeps "Indefinite retention" as the v0.2 default until a later legal review (lines 403-411).
   Proposed fix: either update v0.2 to D3-B now by making text-body purge part of the schema contract, or mark production/pilot use blocked until D2/D3 are resolved and the purge migration/script are executable.
