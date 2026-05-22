REJECTED

1. The destructive UPDATE cannot work against the current schema. The script sets `original_text = NULL` (lines 176-187), but `recent_edit.original_text` is `TEXT NOT NULL` in `v0.1-to-v0.2.sql` lines 135-143. The v0.3 migration only adds `text_purged_at` and a CHECK; it never drops the NOT NULL constraint.
   Proposed fix: fix the v0.3 migration first, then keep the script's UPDATE; or change the script to overwrite with a non-PII sentinel value if the column intentionally remains NOT NULL.

2. The audit-row write uses `SET LOCAL` outside an explicit transaction and has no checked failure path. The script runs `SET LOCAL ifos.tenant_slug='ifos-meta'; INSERT ...` (lines 200-216) after the purge UPDATEs. If RLS rejects the audit insert, the script still prints success and exits 0 (lines 218-219).
   Proposed fix: wrap the audit row in `BEGIN; SET LOCAL ...; INSERT ...; COMMIT;`, check the `psql` exit code, and fail the cron if the audit row cannot be written.
