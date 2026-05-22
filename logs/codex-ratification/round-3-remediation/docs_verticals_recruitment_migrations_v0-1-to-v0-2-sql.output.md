RATIFIED

Round-3 verdict: the PostgreSQL 12+ compatibility issue is fixed. The migration now uses `pg_get_constraintdef(c.oid)` instead of removed `pg_constraint.consrc`, with no remaining `consrc` hits.
