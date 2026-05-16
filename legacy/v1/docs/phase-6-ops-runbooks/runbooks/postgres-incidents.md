# Postgres Incident Runbook

**Specific response procedures for Postgres-related incidents: primary failure, suspected corruption, replication lag, vector index issues, connection exhaustion, and RLS bypass.**

> **Audience:** on-call operator during a database incident. Paired with `incident-response/incident-response-runbook.md` — this document covers the Postgres-specific steps; the general runbook handles the declaration, comms, and postmortem flow.
>
> **Status:** v1.0. Targets the Postgres cluster defined in `phase-3-platform/postgres/schema-spec.md`.
>
> **The one-rule warning:** Postgres incidents are almost always worse than they first appear. If you're uncertain about a destructive command, stop. Page secondary. Two brains on a database incident.

---

## 1. Cluster topology recap

From `phase-3-platform/postgres/schema-spec.md`:

- **Primary:** single writer, Hetzner UK (hetzner-uk-db-01)
- **Replica:** async streaming replica, Hetzner UK (hetzner-uk-db-02)
- **Vector-dedicated replica:** also async streaming, but queries route here for `pgvector` searches to isolate heavy reads (hetzner-uk-db-03)
- **Backup:** continuous WAL via pgBackRest to S3 eu-west-2 (`clawd-pg-backups`); full backup nightly; PITR to any 30-day point
- **Connection pool:** PgBouncer in session mode, per-application

Schemas per Phase 3:
- `control.*` — platform control data (tenants, users, etc.)
- `ops.*` — operational data (audit_log, alerts, etc.)
- `tenant_{ulid}.*` — per-tenant data

RLS policies enforce isolation via `app.current_tenant_id`.

---

## 2. Incident: Primary unreachable

### 2.1 Symptoms

- Dashboard returns 502s en masse
- Webhook receiver fails all inbound webhooks
- Prometheus alert: `postgres_primary_up == 0`
- Or: PgBouncer `pg_bouncer_pools` metric shows all pools draining

### 2.2 First 5 minutes

```
□ 1. Declare SEV-1 incident
□ 2. Ack PagerDuty, page secondary
□ 3. Open Grafana → Postgres dashboard
□ 4. Check: can Grafana query `pg_up{instance="hetzner-uk-db-01"}`?
     → If yes but value 0: primary is down
     → If no (Prometheus can't reach): might be network partition
□ 5. Try to SSH to primary via Tailscale bastion
     → If SSH works, primary host is alive but Postgres down
     → If SSH fails, primary host is dead (power, network, or kernel panic)
□ 6. Check Hetzner console for host status
□ 7. Decide: wait for primary, or failover?
```

### 2.3 Decision: wait vs failover

**Wait if:**
- Outage is < 5 minutes and signs of recovery (Postgres restarting itself)
- Primary host is alive (SSH works) and problem is clearly fixable (OOM, config error)
- Replica is more than 10 seconds behind in replication

**Failover if:**
- Outage >5 minutes with no recovery signal
- Primary host is dead or inaccessible
- Replication lag is < 5 seconds (minimal data loss risk)
- IC is confident enough to commit (if uncertain, wait and get second opinion from secondary)

### 2.4 Failover procedure

```bash
# From bastion, SSH to replica
ssh replica-db-02

# Promote replica to primary
sudo -u postgres pg_ctl promote -D /var/lib/postgresql/15/main

# Verify
sudo -u postgres psql -c "SELECT pg_is_in_recovery();"  # should return 'f'

# Update DNS / config
# PgBouncer config must point to new primary
# Update Consul (or our lightweight service discovery) with new primary IP

# From PgBouncer host
sudo systemctl reload pgbouncer  # reloads config without dropping connections
```

After failover:
1. Update status page: "Database failover completed; platform operational"
2. Begin recovery of old primary — do NOT bring it back as replica until investigated (could be corrupted)
3. Pre-announce: failover means some last-5-seconds-of-data may have been lost; affected invocations may need replay

### 2.5 Old primary recovery

Don't rush. Do only after the incident is resolved and you have time:

```bash
# SSH to old primary
ssh old-primary-db-01

# Check logs for cause
sudo journalctl -u postgresql -n 1000 > /tmp/postgres-failure-log.txt
sudo grep -i "fatal\|panic\|segmentation" /var/log/postgresql/postgresql-15-main.log

# Upload log for offline analysis
scp /tmp/postgres-failure-log.txt bastion:/incident-evidence/

# If cause is clear and recoverable (e.g., disk full):
#   - Resolve underlying issue
#   - Reconfigure as streaming replica of new primary
#   - Rejoin cluster

# If cause is unclear or data corruption suspected:
#   - Do NOT rejoin cluster
#   - Replace with fresh provision; rejoin as new replica
```

### 2.6 Data loss assessment

After failover, invoke WAL analysis to identify any transactions that were committed on old primary but not replicated:

```bash
# On new primary
sudo -u postgres pg_waldump \
  --start=0/[last_lsn_replicated] \
  /var/lib/postgresql/15/main/pg_wal/ \
  > /tmp/potential-lost-transactions.txt

# Review; typical losses are sub-second application writes
# For any lost transactions touching customer data, contact affected customer
```

---

## 3. Incident: Replica falling behind

### 3.1 Symptoms

- Prometheus alert: `postgres_replica_lag_seconds > 10`
- Dashboard users seeing slightly stale data
- Vector search results missing recent writes

### 3.2 Severity

- Lag < 60s: SEV-3, monitor
- Lag 60s–5min: SEV-3, investigate actively
- Lag > 5min and growing: SEV-2, risk to failover safety

### 3.3 Investigation

```bash
# Check replica status
psql -h replica-db-02 -c "SELECT * FROM pg_stat_wal_receiver;"

# Check replica's WAL apply position
psql -h replica-db-02 -c "SELECT pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();"

# On primary: are big writes hitting?
psql -h primary-db-01 -c "SELECT query, state, wait_event FROM pg_stat_activity WHERE state = 'active';"
```

### 3.4 Common causes and fixes

| Cause | Fix |
|---|---|
| Replica host CPU-bound | Scale up replica instance (Hetzner console) |
| Huge write on primary (e.g., backup index rebuild) | Wait; inform tenants of delay |
| Network bandwidth between primary and replica saturated | Contact Hetzner; check for noisy-neighbour issues |
| Vacuum on primary blocking replication | Wait; vacuum will complete |
| Replica out of disk | Expand replica volume |

### 3.5 Emergency replica re-seed

If lag is unrecoverable:

```bash
# Stop replica's Postgres
ssh replica-db-02 'sudo systemctl stop postgresql'

# Wipe replica data
ssh replica-db-02 'sudo rm -rf /var/lib/postgresql/15/main/*'

# Re-seed from pgBackRest
ssh replica-db-02 'sudo -u postgres pgbackrest \
  --stanza=primary --type=standby \
  restore'

# Start replica
ssh replica-db-02 'sudo systemctl start postgresql'
```

Takes ~45 minutes at current data sizes. During this time, the vector-dedicated replica covers read load.

---

## 4. Incident: Connection exhaustion

### 4.1 Symptoms

- Prometheus alert: `pg_bouncer_pools_active / pg_bouncer_pools_max > 0.9`
- Application logs full of "sorry, too many clients already" or PgBouncer's "no more connections allowed"

### 4.2 First steps

```bash
# Check PgBouncer status
psql -h pgbouncer-host -p 6432 -d pgbouncer -U pgbouncer \
  -c "SHOW POOLS;"

# Check Postgres connection count
psql -h primary-db-01 \
  -c "SELECT count(*) FROM pg_stat_activity;"

# Check longest-running queries
psql -h primary-db-01 -c "
  SELECT pid, state, age(now(), query_start) AS age, query
  FROM pg_stat_activity
  WHERE state != 'idle'
  ORDER BY age DESC
  LIMIT 20;"
```

### 4.3 Common causes

| Cause | Evidence | Fix |
|---|---|---|
| A tenant's agent looping | Many `tenant_*` queries from one tenant | Suspend the tenant via dashboard (contains damage) |
| Dashboard leaking connections | Many idle connections from dashboard host | Restart dashboard instances (rolling) |
| Scheduled job stuck | Long-running query age > 1hr | Cancel with `pg_cancel_backend(pid)`; investigate script |
| Legitimate traffic spike | Spread across tenants | Scale PgBouncer pool size; may need Postgres max_connections bump |

### 4.4 Emergency connection reset

If totally saturated and fix isn't immediate:

```sql
-- On primary, as superuser
-- Kill idle-in-transaction sessions older than 10 min (usually safe)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE state = 'idle in transaction'
  AND age(now(), state_change) > interval '10 minutes';

-- If still saturated, kill idle (safer than active)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE state = 'idle'
  AND age(now(), state_change) > interval '30 minutes';
```

Do NOT terminate `state = 'active'` backends blindly — you kill in-flight work.

---

## 5. Incident: Suspected data corruption

### 5.1 Symptoms

- Query errors: `ERROR: invalid page in block X`
- Query returning obviously-wrong data
- `pg_stat_database.xact_rollback` spiking
- Checksum failures in logs

### 5.2 Severity

**SEV-1 immediately.** Data corruption is always SEV-1, even if small scope, because undetected corruption spreads.

### 5.3 First actions

```
□ 1. Declare SEV-1
□ 2. Stop all writes to the affected database/schema immediately
     (suspend tenants; pause provisioning system; pause scheduler)
□ 3. DO NOT let VACUUM FULL run — can make corruption worse
□ 4. Run pg_amcheck on affected relation
□ 5. Document WHICH rows/indexes are affected before taking action
```

### 5.4 Corruption triage

```sql
-- Identify affected relation from error
-- Error: "ERROR: invalid page in block 123 of relation base/16384/16425"
-- 16384 = database OID, 16425 = relation OID

SELECT datname FROM pg_database WHERE oid = 16384;
SELECT relname, nspname FROM pg_class c
  JOIN pg_namespace n ON c.relnamespace = n.oid
  WHERE c.oid = 16425;

-- Check table
SELECT * FROM pg_amcheck('schema.table_name');

-- Check indexes
SELECT amname, bt_index_check('schema.index_name'::regclass)
  FROM pg_stat_user_indexes
  WHERE relname = 'table_name';
```

### 5.5 Recovery decision tree

**Index corruption only:**
- Drop and recreate the index from scratch
- If covered by a primary key, use `REINDEX CONCURRENTLY`

**Table corruption with clean replica:**
- Compare primary vs replica for the affected rows
- If replica is clean, re-import affected rows from replica

**Table corruption on both primary and replica:**
- Restore from pgBackRest PITR to the last known-good timestamp
- Major undertaking — requires customer comms about data loss window

**Unclear scope of corruption:**
- Take whole-database restore from last known-good backup as the safest path
- Extended downtime; customer comms immediately

Do NOT try to "fix" corruption with direct UPDATE statements. Restore is cleaner.

### 5.6 Point-in-time restore

```bash
# On a spare host (never restore into production cluster directly)
pgbackrest \
  --stanza=primary \
  --type=time \
  --target="2026-04-23 14:00:00+00" \
  restore

# Verify restored database
psql -c "SELECT max(created_at) FROM control.audit_log;"

# Export the affected tables
pg_dump -Fc -t affected_table_name > /tmp/recovered.dump

# Import into production (after coordination with IC)
pg_restore -d clawd_prod /tmp/recovered.dump
```

### 5.7 Post-corruption

- Postmortem mandatory with external postmortem for customers who had data restored or lost
- Review what caused corruption: hardware (disk, RAM), Postgres bug, or software bug writing bad data
- Hardware cause: replace the disk/host
- Bug cause: patch, file upstream if Postgres bug

---

## 6. Incident: RLS policy bypass suspected

### 6.1 Symptoms

- Customer reports seeing another tenant's data
- Audit log shows `ops.audit_log.actor_tenant_id != subject_tenant_id` where it shouldn't

### 6.2 Severity

**SEV-1 immediately.** Cross-tenant data leak is a confirmed breach until proven otherwise. Invoke `compliance/breach-response-runbook.md` in parallel with this runbook.

### 6.3 First actions

```
□ 1. Declare SEV-1
□ 2. Invoke breach runbook — 72hr GDPR notification clock starts
□ 3. Quarantine: if you can identify the affected user/session, suspend it
□ 4. Collect evidence before anything else changes
   - Snapshot pg_stat_activity
   - Copy affected audit_log entries
   - Capture tRPC request logs from Loki for the session
```

### 6.4 Investigation queries

```sql
-- Check whether RLS was even active for the connection
-- (run in a sample connection using the same role)
SHOW row_security;
-- Should be 'on' for all application roles except platform_admin

-- Verify current tenant setting
SHOW app.current_tenant_id;
-- Should match the logged-in tenant

-- Check policies on a suspected table
SELECT polname, polcmd, polqual, polroles::regrole[]
FROM pg_policy p
JOIN pg_class c ON p.polrelid = c.oid
WHERE c.relname = 'invocations';
```

### 6.5 Common RLS bypass causes

| Cause | Evidence | Fix |
|---|---|---|
| Code connected with `platform_admin` role accidentally | Application logs show platform admin creds | Review connection config; enforce non-admin roles |
| `set_config('app.current_tenant_id', ...)` not called | Queries run without tenant context | Enforce middleware; fail-closed |
| Policy missing on a new table | New migration added table without RLS | Audit every table; add RLS as part of migration template |
| Policy written wrong (e.g., `OR` where `AND` should be) | Policy logic allows escape | Correct policy; verify with test |

### 6.6 Containment

If RLS bypass is confirmed:
1. Immediately revoke the offending role's access OR shut down the service that's using it
2. Analyse all audit log entries for the session(s) that escaped to identify affected tenants
3. Customer comms to affected tenants per breach runbook

---

## 7. Incident: pgvector query degradation

### 7.1 Symptoms

- Vault search (calls `vault-search` CLI) returning slowly or timing out
- Prometheus: `vault_search_latency_p95 > 2s`
- Users report "search is broken"

### 7.2 Severity

- Intermittent: SEV-3
- Sustained across all tenants: SEV-2

### 7.3 Common causes

| Cause | Fix |
|---|---|
| HNSW index bloat after many writes | `REINDEX CONCURRENTLY` the index |
| Wrong `ef_search` parameter at query time | Tune; typically `ef_search=40` for good recall/perf tradeoff |
| Vector dimension mismatch (new embeddings model) | Re-embed vault content at new dimension |
| pgvector lock contention during heavy writes | Move reads to vector-dedicated replica |
| Cohere API slowness (upstream) | Not our problem; cache embeddings aggressively |

### 7.4 Re-indexing safely

```sql
-- Check index health
SELECT schemaname, relname, indexrelname, pg_size_pretty(pg_relation_size(indexrelid))
FROM pg_stat_user_indexes
WHERE indexrelname LIKE '%vector%'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Reindex concurrently (no lock; slower)
REINDEX INDEX CONCURRENTLY tenant_xxx.vault_embeddings_hnsw_idx;

-- Verify
EXPLAIN ANALYZE SELECT * FROM tenant_xxx.vault_embeddings
ORDER BY embedding <=> '[...]'::vector
LIMIT 10;
```

Reindexing at large data sizes can take an hour+ — don't do during active incident unless there's no alternative.

---

## 8. Incident: Disk full

### 8.1 Symptoms

- Prometheus alert: `node_filesystem_avail_bytes{mountpoint="/var/lib/postgresql"} / node_filesystem_size_bytes < 0.1`
- Postgres starts failing writes
- Replication breaks

### 8.2 Severity

- <20% free: SEV-3, plan expansion
- <10% free: SEV-2, act now
- <5% free: SEV-1, immediate action

### 8.3 First actions

```
□ 1. Identify what's eating the disk
   → du -sh /var/lib/postgresql/15/main/* | sort -h
   → Likely: WAL, temp files, or table growth
□ 2. If WAL: check replication; if replica is behind, WAL accumulates
□ 3. If temp: a query gone wild; find and terminate
□ 4. If table growth: long-term — bigger disk; short-term — delete old non-critical data
```

### 8.4 Quick wins (can buy hours)

```bash
# Remove old log files
sudo truncate -s 0 /var/log/postgresql/postgresql-15-main.log.old*

# Check for hung replication slots holding WAL
psql -c "SELECT slot_name, active, restart_lsn FROM pg_replication_slots;"
# If a slot is inactive and old, drop it to free WAL

# Vacuum old partitions if using partitioned tables
VACUUM (ANALYZE, VERBOSE) ops.audit_log_2025q4;
```

### 8.5 Disk expansion (Hetzner)

Hetzner cloud volumes can be grown live:

```bash
# From Hetzner console, increase volume size
# Then on the host:
sudo resize2fs /dev/disk/by-id/<volume-id>

# Confirm:
df -h /var/lib/postgresql
```

Postgres doesn't need restarting after disk expansion.

---

## 9. Incident: Migration gone wrong

### 9.1 Symptoms

- Deploy runbook migration step failed
- Dashboard / other services can't query because schema is in an unexpected state

### 9.2 First actions

```
□ 1. Do NOT deploy over top of broken migration
□ 2. Check migration tool state (we use Prisma migrate)
     → npx prisma migrate status
□ 3. Identify: partially applied, fully failed, or corrupted migrations table
□ 4. Decision: roll forward (fix the migration) or roll back (restore previous state)
```

### 9.3 Roll forward

```bash
# Fix the migration SQL
# Re-run migrate deploy
npx prisma migrate deploy
```

Only works for idempotent migrations (ones that check state before applying). This is why migration templates in Phase 3 use idempotent patterns.

### 9.4 Roll back

```bash
# For non-idempotent failed migrations, restore from pre-deploy snapshot
# (We take a snapshot before every deploy; see deploy-and-rollback runbook)

# OR: manually revert the partial migration
psql -f /path/to/revert-script.sql

# OR: PITR restore to 5 minutes before deploy
pgbackrest --stanza=primary --type=time \
  --target="YYYY-MM-DD HH:MM:SS+00" restore
```

PITR is nuclear — only if lighter options don't work.

---

## 10. Incident: VACUUM disaster (autovacuum runaway)

### 10.1 Symptoms

- Autovacuum is running on many tables simultaneously
- CPU spikes on primary
- Query latency spikes
- I/O saturated

### 10.2 Fix

```sql
-- See what autovacuum is doing
SELECT pid, relation::regclass, phase, heap_blks_scanned, heap_blks_total
FROM pg_stat_progress_vacuum;

-- Cancel a specific autovacuum (Postgres will restart it; but you get a break)
SELECT pg_cancel_backend(pid) FROM pg_stat_progress_vacuum;

-- Tune autovacuum (global)
ALTER SYSTEM SET autovacuum_vacuum_cost_delay = '10ms';  -- slow it down
SELECT pg_reload_conf();
```

### 10.3 Longer-term fix

Vacuum hotspots usually mean a specific table is getting heavy updates. Solutions:
- Partition that table by time or tenant
- Reduce update churn (e.g., don't UPDATE when INSERT-only pattern works)
- Dedicated autovacuum tuning for that table

---

## 11. Monitoring queries — keep these saved

Saved in Grafana as "Incident investigation" dashboards:

```sql
-- Active queries sorted by runtime
SELECT pid, usename, datname, state,
       age(now(), query_start) AS runtime,
       left(query, 100) AS query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY runtime DESC
LIMIT 20;

-- Locks and blocked queries
SELECT blocked.pid AS blocked_pid, blocked.query AS blocked_query,
       blocking.pid AS blocking_pid, blocking.query AS blocking_query,
       blocked.wait_event_type, blocked.wait_event
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking ON blocking.pid = ANY(pg_blocking_pids(blocked.pid))
WHERE blocked.wait_event_type = 'Lock';

-- Top tables by write activity
SELECT schemaname, relname,
       n_tup_ins + n_tup_upd + n_tup_del AS total_writes,
       n_live_tup, n_dead_tup
FROM pg_stat_user_tables
ORDER BY total_writes DESC
LIMIT 20;

-- Index bloat estimation
-- (Full query is 50+ lines; saved as `pg-index-bloat.sql` in /vault/ops/queries/)

-- Per-tenant cost of storage
SELECT
  regexp_match(nspname, '^tenant_(.+)$')[1] AS tenant_id,
  pg_size_pretty(sum(pg_total_relation_size(c.oid))) AS total_size
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE nspname LIKE 'tenant_%'
GROUP BY nspname
ORDER BY sum(pg_total_relation_size(c.oid)) DESC;
```

---

## 12. Never do during an incident

- `DROP DATABASE` anything — always taking backup first
- `TRUNCATE` a table with customer data — always export first
- `VACUUM FULL` — it takes exclusive lock; will make things worse
- Take the whole DB down to "restart" without understanding why — restart thrash makes investigation impossible
- Promote a replica while primary is still writing (split-brain)
- Connect as `postgres` superuser from production hosts (use operator roles; superuser for emergencies only and always logged)

---

## 13. Related

- `incident-response/incident-response-runbook.md` — incident declaration + comms + postmortem
- `incident-response/severity-classification-and-comms.md` — severity rules
- `compliance/breach-response-runbook.md` — if RLS bypass or cross-tenant leak
- `routines/backup-verification-and-dr-drills.md` — proactive work to make these incidents less likely
- `phase-3-platform/postgres/schema-spec.md` — cluster topology and schema design
- `phase-3-platform/dr/backup-and-dr-runbook.md` — recovery procedures (more detail on PITR)
