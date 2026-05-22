REJECTED

1. The audit-row write uses `SET LOCAL` outside an explicit transaction. The script writes the final audit row with `SET LOCAL ifos.tenant_slug='ifos-meta';` followed by INSERT (lines 524-535). In PostgreSQL, `SET LOCAL` only has transaction-local effect; outside `BEGIN ... COMMIT`, it is not a reliable session guard for the subsequent INSERT. This can make the live decision_log audit row fail under RLS while the script still reports the audit as complete.
   Proposed fix: wrap the audit-row block in `BEGIN; SET LOCAL ifos.tenant_slug='ifos-meta'; INSERT ...; COMMIT;`, or use a single helper that always emits `BEGIN/COMMIT` around `SET LOCAL` + tenant-data writes.

2. T4 is documented as an adversarial missing-SET-LOCAL write test, but it only performs a SELECT. The test case list says "INSERT without setting" (line 14), the section heading says "adversarial write" (line 259), but the actual probe is `SELECT count(*) FROM decision_log` (lines 261-265). This verifies read isolation, not write rejection.
   Proposed fix: add a harmless INSERT/ROLLBACK probe without `SET LOCAL` and require it to fail, while keeping the existing SELECT as the T11 read-isolation check.
