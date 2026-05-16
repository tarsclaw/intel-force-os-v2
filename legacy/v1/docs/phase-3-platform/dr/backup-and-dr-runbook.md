# Backup and Disaster Recovery Runbook

**What's backed up, how it's recovered, how bad it can get, and what we promise the tenant.**

> **Audience:** on-call engineer handling a production incident, plus the ops engineer setting up backups initially.
>
> **Status:** v1.0. Targets Hetzner UK primary + AWS London for S3-compatible secondary storage.
>
> **Stance:** we optimise for recovery time for likely failures (single-service outages, accidental data loss) and recoverability at all for unlikely-but-catastrophic failures (multi-AZ loss, tenant CMK loss).

---

## 1. SLAs we commit to

| Metric | Target | Note |
|---|---|---|
| RPO (Recovery Point Objective) | 15 minutes | Max data loss after an incident |
| RTO (Recovery Time Objective) — common failures | 1 hour | Service crashes, deploy rollbacks |
| RTO — Postgres primary loss | 4 hours | Failover to hot standby + restore |
| RTO — full region loss | 24 hours | Restore from off-region S3 backups |
| Backup retention | 30 days PITR, 1 year cold | Point-in-time for a month, yearly archival |

These are targets — they turn into real commitments in the customer MSA (Phase 5).

---

## 2. What we back up, where, and how often

| Asset | Primary storage | Backup method | Backup frequency | Backup location | Retention |
|---|---|---|---|---|---|
| **Postgres cluster** (control + ops + all tenant schemas) | Hetzner UK dedicated | pgBackRest — full weekly, incremental hourly, WAL archival continuous | 1h incremental, continuous WAL | S3 (AWS London) | 30d PITR + 1y monthly full |
| **DynamoDB secrets table** | AWS UK | PITR enabled (35 days) + daily on-demand backup | Continuous PITR | AWS multi-AZ | 35d PITR + 1y monthly |
| **Tenant vaults** (GitHub repos) | GitHub Enterprise / github.com | Nightly clone of every tenant repo → S3 | Daily | S3 (AWS London) | 90d |
| **Tenant volumes** (/mnt/tenants/...) | Hetzner block storage | Block-level snapshot | 4× daily | Hetzner snapshot storage | 7d |
| **Tenant container images** | ghcr.io | N/A (registry is authoritative) + immutable tags | Per-deploy | ghcr.io + S3 archive | Forever |
| **Loki log data** | Object storage (in-cluster MinIO) | S3 replication to AWS London | Daily | AWS S3 Glacier | 30d hot, 1y cold |
| **Audit log (`ops.audit_log`)** | Postgres + continuous replication to S3 | Append-only S3 Object Lock | Continuous | AWS S3 Object Lock | 7 years |
| **Prometheus metrics** | In-cluster | Not backed up (reconstructable) | N/A | N/A | 15 days rolling |
| **Temporal workflow history** | Temporal cluster | Temporal cluster's own backups | Hourly | Same region as Temporal | 30d |
| **KMS CMKs** | AWS KMS | AWS manages durability | N/A | AWS multi-AZ | Indefinite (never auto-delete) |

---

## 3. Backup validation

A backup you haven't restored is not a backup. We validate:

### 3.1 Weekly: restore test

- Every Sunday 02:00 UTC, an automated job:
  - Spins up an ephemeral Postgres from the latest pgBackRest full
  - Applies last week's WAL segments
  - Runs a smoke SQL query (`SELECT count(*) FROM control.tenants; SELECT count(*) FROM control.invocations WHERE created_at > now() - interval '1 day';`)
  - Verifies row counts are plausible
  - Destroys the ephemeral instance
- Results posted to #intelforce-ops Slack channel
- Failure = PagerDuty alert

### 3.2 Quarterly: full DR drill

Every quarter, a scheduled DR drill:
- Restore Postgres to a staging cluster from the latest backup
- Restore a sample tenant vault from GitHub nightly-clone S3 archive
- Restore tenant volume snapshots to a new Hetzner node
- Boot a tenant container against the restored state
- Run one agent invocation end-to-end
- Measure actual recovery time vs RTO target
- Document findings; update runbooks

### 3.3 What the drill has found so far

*(This section populated as drills happen — starts empty. Phase 7 retrospective adds the first entries.)*

---

## 4. Incident response by failure mode

### 4.1 Webhook receiver pod crash

**Detection:** Prometheus alert `up{service="webhook-receiver"} == 0` fires after 2 minutes.

**Impact:** Incoming Fathom webhooks return 503; Fathom retries for up to 24 hours.

**Recovery:**
1. Check Kubernetes events: `kubectl describe pod -n intelforce-hooks`
2. If OOM: scale memory in Helm chart, redeploy
3. If crash loop: check logs, identify recent change, roll back via `kubectl rollout undo`
4. RTO: 10 minutes typical

**Data loss:** None — Fathom retries; our receiver's dedup handles any double-deliveries.

---

### 4.2 Postgres primary failure

**Detection:** `postgres_primary_up == 0` alert + replica lag stops advancing.

**Impact:** All tenant agents fail on startup (can't read tenant-config metadata); dashboard read-only.

**Recovery:**
1. Confirm primary is actually dead (not just unreachable from Prometheus)
2. Failover to hot standby:
   ```bash
   # On standby
   pg_ctl promote -D /var/lib/postgresql/15/data
   ```
3. Update connection string in `control.webhook_registrations` and dashboard config to point to new primary
4. Restart all tenant containers (they'll reconnect via new DSN)
5. Provision new standby from former primary (now decommissioned) — use pgBackRest streaming backup
6. RTO: 1–4 hours depending on whether standby was current

**Data loss:** Up to 15 seconds of transactions (streaming replication lag window). Accepted.

---

### 4.3 Full Postgres cluster loss (primary + standby)

**Detection:** Both primary and standby unreachable.

**Impact:** Complete platform outage for all tenants.

**Recovery:**
1. Declare incident. Page senior engineer. Status page updated.
2. Provision new Postgres cluster in AWS (pre-existing Terraform script, pre-tested in drills)
3. Restore from latest pgBackRest full + WAL apply: `pgbackrest --stanza=main restore --type=time --target='2026-04-22 15:30:00'`
4. Update DNS + connection strings
5. Restart all tenant containers
6. Communicate to all tenants (pre-drafted email template)
7. RTO: 8–24 hours depending on backup size

**Data loss:** Up to 1 hour (last incremental backup). Accepted as catastrophic scenario.

---

### 4.4 Tenant vault (GitHub repo) loss

**Detection:** vault-syncer logs show "remote not reachable" OR GitHub API returns 404 for the repo.

**Impact:** That tenant's agents can still run on existing vault (container has local clone) but can't sync new changes.

**Recovery:**
1. Check if it's genuinely deleted or just access lost
2. If deleted: restore from S3 nightly-clone archive
   ```bash
   ./scripts/restore-tenant-vault.sh --tenant tnt_xxx --from 2026-04-21
   ```
3. Recreate GitHub repo, push restored content, re-add deploy key via Secrets Vault rotation
4. Verify tenant supervisor picks up new remote on next sync
5. RTO: 2 hours

**Data loss:** Up to 24 hours of changes (since last nightly archive). Client edits in that window are lost from GitHub but present on the tenant's container volume — merge back manually.

---

### 4.5 Tenant CMK catastrophic loss

**Detection:** Secrets Vault returns `KMSInvalidKeyUsageException` when trying to decrypt for that tenant.

**Impact:** That tenant's agents cannot authenticate any integration. All agents fail.

**Recovery:**
- **If CMK is in scheduled-delete state** (within 30-day window):
  1. Cancel the deletion: `aws kms cancel-key-deletion --key-id alias/intelforce/tenant/tnt_xxx`
  2. Normal operations resume; RTO 15 minutes
- **If CMK is truly deleted:**
  1. All ciphertexts for that tenant are unrecoverable
  2. Suspend tenant (webhook off, supervisor down)
  3. Notify tenant operator, work with them to re-authenticate every integration manually
  4. Generate new CMK, re-store all secrets fresh
  5. RTO: 24–72 hours (blocked on operator availability)

This is why §8 of the Secrets spec hammers on NEVER setting a short deletion window.

---

### 4.6 Accidental data deletion via platform bug

**Scenario:** a buggy deploy issues a destructive SQL or deletes tenant data.

**Detection:** Alert from data integrity checks OR customer complaint.

**Recovery:**
1. Stop the deploy immediately; roll back
2. Use Postgres PITR to restore the affected tables to just before the damage:
   ```bash
   pgbackrest --stanza=main restore --target-time='2026-04-22 15:29:00' --type=time
   ```
3. Selective restore — we restore to a staging DB, extract only the affected rows, merge back to production
4. Verify with tenant: "We restored X records to the state they were in at Y time. Confirm OK."
5. Post-mortem. Add integration tests to prevent recurrence.

**Data loss:** Depends on how fast detected. Aim for <1 hour from deploy to detection; <4 hours to full recovery.

---

### 4.7 Tenant requests urgent restore ("we deleted our vault by mistake")

**Scenario:** A client, via their Obsidian app, deletes an important folder.

**Recovery path (tenant-triggered self-service ideally, operator-assisted today):**
1. Git history on their vault repo retains deleted files — `git log` shows the deletion commit
2. Operator runs: `intelforce vault-restore --tenant tnt_xxx --file /path/to/deleted.md --at "2 hours ago"`
3. Tool finds the deletion commit, extracts the previous version, pushes a restore commit
4. vault-syncer pulls on next cycle; tenant's Obsidian refresh shows the file back

RTO: minutes. No actual data loss — git retains everything.

Later (v1.1): self-service restore UI in dashboard.

---

### 4.8 Regional failure (Hetzner UK unavailable)

**Detection:** Hetzner status page + loss of Prometheus scrape from UK nodes.

**Impact:** Full platform down.

**Recovery:**
1. This is the scenario where we trigger multi-region failover.
2. For MVP, we don't have a hot multi-region setup. We have backups in AWS London. Failover is effectively "stand up the platform fresh in AWS":
   - Terraform `apply` against the disaster recovery AWS environment
   - Restore Postgres from off-region backup
   - Restore tenant vaults from S3 nightly archives
   - Re-provision tenant containers
3. RTO: 18–36 hours
4. Communicate to all tenants with regular updates

This is the scenario the 24-hour RTO row in §1 covers. It's a genuine risk; we accept it as a trade-off against the cost of hot multi-region (would roughly double infrastructure cost).

---

## 5. Backup ops runbook

### 5.1 Daily checks

- [ ] Overnight pgBackRest full backup completed: `pgbackrest info`
- [ ] WAL archive shipping current: check latest WAL file age < 10 minutes
- [ ] Tenant vault nightly clones completed: check S3 for today's archive prefix
- [ ] Volume snapshots completed: Hetzner dashboard
- [ ] Restore test passed (Sunday only)

If any of these fail, page the on-call.

### 5.2 Before a risky deploy

- [ ] Manual full pgBackRest backup: `pgbackrest --stanza=main backup --type=full`
- [ ] Manual DynamoDB on-demand backup: `aws dynamodb create-backup --table-name secrets --backup-name "pre-deploy-$(date +%s)"`
- [ ] Note deploy timestamp in `#intelforce-ops` for PITR reference

### 5.3 Monthly

- [ ] DR drill (quarterly, but calendar reminder monthly)
- [ ] Review retention policies — anything we're keeping that we don't need?
- [ ] Review backup costs — trending up faster than tenant count?

---

## 6. What we don't back up (and why)

- **Prometheus metrics** — reconstructable from logs; pure time-series data
- **Redis (webhook dedup)** — ephemeral; loss means some webhooks may double-process for up to 7 days, which is unpleasant but not catastrophic
- **In-memory caches in receiver/dashboard** — regenerated on restart
- **Ephemeral container state** — everything important is on mounted volumes
- **LLM API call records at Anthropic** — Anthropic keeps these for 30 days per ToS; we query their API if we need detail

---

## 7. What's new compared to MVP and what's aspirational

**Already in MVP (Phase 3 shipping):**
- pgBackRest + WAL archival
- DynamoDB PITR
- Nightly vault clones
- Volume snapshots
- Weekly restore test

**Aspirational (Phase 6 or 7):**
- Automated quarterly DR drills (currently manual)
- Self-service tenant restore UI
- Hot multi-region failover
- 99.9% SLA commitment (currently best-effort ~99.5%)

---

## 8. Customer communication

On any sev-1 incident:
1. Status page updated within 5 minutes (statuspage.io or equivalent)
2. Email to affected tenants within 15 minutes (pre-drafted templates per scenario)
3. Slack message to each tenant's Slack channel (if configured) within 15 minutes
4. Hourly updates until resolved
5. Post-mortem published within 5 business days

Templates live in `dr/communication-templates/` — covers: Postgres outage, vault sync issue, integration provider down, full outage, security incident.

---

## 9. Incident commander checklist (for sev-1)

1. [ ] Declare incident in `#intelforce-incident` channel
2. [ ] Open Zoom/Meet bridge (link in channel topic)
3. [ ] Status page → investigating
4. [ ] Assign roles: Incident Commander, Comms, Technical Lead
5. [ ] Page necessary on-calls
6. [ ] Start incident doc (template in `dr/incident-template.md`)
7. [ ] Send initial customer email (from template)
8. [ ] Begin regular comms cadence (Slack every 15 min, email every 60 min)
9. [ ] On resolution: status page → resolved
10. [ ] Schedule post-mortem for next business day
11. [ ] File incident report; update runbooks with any new knowledge

---

## 10. Contact and escalation

- **Platform on-call** — PagerDuty rotation
- **Escalation (senior engineer):** via PagerDuty secondary
- **AWS support:** Enterprise support plan (when we upgrade), currently Developer plan
- **Hetzner support:** ticket + phone (SLA response 1h)
- **GitHub Enterprise support:** via dashboard ticket (SLA response 4h)
- **Anthropic support:** via dashboard ticket (SLA response 24h — plan ahead for any Anthropic-side issue)
- **Cohere support:** via dashboard ticket (SLA response 24h)
