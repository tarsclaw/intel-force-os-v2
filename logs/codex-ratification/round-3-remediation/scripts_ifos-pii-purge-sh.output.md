RATIFIED

Round-3 verdict: the script now has a schema-compatible purge path after the migration fix, wraps tenant-scoped count/update/audit operations in explicit transactions, checks the audit-row write, and exits non-zero if that audit write fails. Shellcheck passes.
