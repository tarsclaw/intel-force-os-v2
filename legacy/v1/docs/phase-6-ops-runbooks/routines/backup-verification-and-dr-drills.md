# Backup Verification & DR Drills

**The routine operations that prove our backups work. Weekly restore tests, quarterly disaster recovery drills, and the evidence capture that makes DR real rather than aspirational.**

> **Audience:** platform operator responsible for DR readiness.
>
> **Status:** v1.0. Works with the backup infrastructure in `phase-3-platform/dr/backup-and-dr-runbook.md` (RPO 15 minutes, RTO 1-4 hours depending on scope).
>
> **Principle:** an untested backup is a wish. A restore procedure not run in the last 90 days may as well not exist. Evidence from drills is what lets us confidently tell customers we can recover.

---

## 1. Why this routine matters

Backup systems fail silently. The common pattern:
- Daily backups run successfully for months
- Nobody has tried to restore from them
- One day we need to restore
- We discover the backups have been empty for 6 months because of a config drift

The only defence is regular verification. Weekly for critical paths, quarterly for full DR.

### 1.1 What customers are paying for

Per `phase-5-business-legal/legal/sla-spec.md`, we commit to:
- RPO (max data loss): 15 minutes
- RTO (max recovery time): 4 hours (Enterprise tier) to 1 business day (Starter tier)

We make those commitments because Phase 3 DR architecture supports them. This runbook proves we can actually deliver them.

---

## 2. What we back up

### 2.1 Postgres

- **Continuous WAL** via pgBackRest to S3 eu-west-2 (`clawd-pg-backups`)
- **Full nightly backup** (compressed, encrypted) at 02:00 UTC
- **Incremental every 6 hours**
- **Retention:** 30 days full + 7 days incremental + continuous WAL for 30 days
- **Cross-region replication:** S3 bucket replicated to eu-central-1

### 2.2 Tenant vault content (git repos)

- **Source:** GitHub (github.com/intelforce-vaults/*)
- **Backup:** nightly mirror to S3 bucket (tar.gz of git repo) + weekly offline archive to separate cloud provider (Backblaze B2)
- **Retention:** 90 days S3; 1 year Backblaze

### 2.3 Secrets vault (DynamoDB)

- **Continuous backups** (AWS-managed; 35-day PITR)
- **Daily export** to S3 (encrypted with vault-level key)
- **Retention:** 90 days S3

### 2.4 S3 audit logs

- **Source:** observability S3 bucket
- **Backup:** Already in S3 with versioning + cross-region replication
- **Retention:** 7 years (compliance requirement for some tenants)

### 2.5 Platform configuration (infrastructure-as-code)

- **Source:** GitHub (terraform repos, deploy configs)
- **Backup:** GitHub itself + nightly mirror to S3
- **Retention:** forever (git history)

### 2.6 What we don't back up

- Claude Code session state inside tenant containers (ephemeral; recreatable)
- PgBouncer state (connection pool; recreatable)
- Loki/Prometheus data (historical metrics; 90-day retention in-place, not separately backed up — lossy rebuild acceptable)
- CI/CD intermediate artifacts (rebuildable)

---

## 3. Weekly routine — automated restore test

Every Monday at 09:30 UTC (post-maintenance window), an automated job:

### 3.1 The automated test

```
1. Provision a fresh Hetzner server (restore-test-weekly)
2. Install Postgres 15
3. Configure pgBackRest
4. Trigger restore from the most recent backup to a "last hour" PITR target
5. Verify:
   a. Postgres starts cleanly
   b. Schema exists (information_schema query)
   c. Row counts in expected ranges for each table
   d. Most recent control.audit_log entry is from <1 hour ago
6. Tear down the server
7. Write outcome to ops.restore_test_results table
8. If failure: alert SEV-3 in #ops
```

Total runtime: 45-60 minutes. Takes a small chunk of S3 egress budget (~1-2 GB per test).

### 3.2 Why weekly

We could do daily — but:
- Daily is noisy; failures would fatigue the team
- Weekly catches config drift within 7 days (acceptable window)
- Monday mornings align with human-in-the-loop review

### 3.3 Weekly review of test results

Part of the Monday cost-governance review: glance at the `ops.restore_test_results` for the past 4 weeks. Ensure:
- All 4 passed
- Restore time hasn't crept up (early warning of backup bloat)
- Restored row counts match expectations (sanity check on backup completeness)

---

## 4. Quarterly DR drill

Once a quarter (first Wednesday of Jan/Apr/Jul/Oct), run a full DR drill.

### 4.1 What a drill does

Simulates a realistic disaster and executes the recovery as if it were real:
- Announced internally 1 week ahead
- Not announced to customers (internal exercise only, unless involving customer data)
- Happens in a dedicated DR environment (not production)
- Measured against RPO/RTO targets

### 4.2 Scenarios to rotate

Quarterly cycles through:

**Q1:** Postgres primary catastrophic failure
- Simulate: kill primary host; recover via failover + WAL replay

**Q2:** AWS region outage (eu-west-2 fully unavailable)
- Simulate: treat eu-west-2 as lost; restore from eu-central-1 replicas

**Q3:** Single-tenant recovery
- Simulate: one tenant's schema corrupted; restore just that schema from backup

**Q4:** Full platform rebuild
- Simulate: "everything is gone except source code and backups"
- This is the big one — run annually

Full-platform rebuild is the drill that matters most; it exposes unwritten assumptions.

### 4.3 Drill roles

- **Drill lead** — designs the scenario, runs the exercise, writes the after-action report
- **Responders** — execute recovery as they would in real incident
- **Observer** — watches, times, notes what goes wrong (doesn't help; observes only)

All full-time ops team members participate at least once per year.

### 4.4 Drill agenda (half-day)

```
09:00 — Kickoff: Drill lead explains scenario (details vague; no cheat sheet)
09:15 — Responders work the problem as if real
        Observer captures everything: actions taken, tools used,
        confusions, time-to-milestones
11:00 — Hard stop: even if not resolved, we stop at 2h mark
11:15 — Walk-through: what did and didn't work
12:00 — After-action report drafting
12:30 — Wrap
```

Post-drill: after-action report published within 1 week.

### 4.5 After-action report template

```markdown
# DR Drill After-Action — YYYY-QX

**Date:** YYYY-MM-DD
**Scenario:** [one-line summary]
**Drill lead:** [name]
**Responders:** [names]
**Duration:** HH:MM actual vs HH:MM RTO target

## Scenario details
[Longer description]

## Actions taken (timeline)
[Minute-by-minute log from observer]

## What worked
[Things that went smoothly]

## What didn't work
[Friction; errors; confusions; missing tools; ambiguous docs]

## RPO/RTO assessment
- RPO actual: _____
- RPO target: 15 min
- Met: yes/no
- RTO actual: _____
- RTO target: (tier-dependent)
- Met: yes/no

## Action items
[Concrete changes. Each with owner + due date.]
```

---

## 5. Evidence capture

For compliance and for customer audits, we need evidence that DR works.

### 5.1 What counts as evidence

- Weekly restore test results (`ops.restore_test_results` table with pass/fail, times)
- Quarterly drill after-action reports
- Signed attestations from drill observer
- Screenshots / logs of key milestones (Postgres back up, row counts verified, etc.)

### 5.2 Evidence storage

`/vault/ops/dr-evidence/YYYY/QX/` — organised by quarter:
- `weekly-tests-summary.md` — rollup of the quarter's weekly tests
- `drill-YYYY-MM-DD.md` — after-action report
- `drill-YYYY-MM-DD-logs/` — subfolder with supporting artifacts

All evidence is encrypted (git-crypt on the vault repo, or separate encrypted S3 bucket for S3-stored evidence).

### 5.3 Customer audit responses

When a customer asks for DR evidence in due diligence:
- Starter/Growth tier: share SLA, RPO/RTO commitments, confirm we run drills
- Scale/Enterprise tier: share summary of drill outcomes (redacted for specific incident details)
- Formal audit: full evidence pack with NDA

Evidence is never public; it's shared under confidentiality.

---

## 6. Full platform rebuild — the annual stress test

The Q4 full-rebuild drill is the most valuable. It asks: if we lost everything except source code and backups, could we be back up in 24 hours?

### 6.1 Starting state

- All production infrastructure is "gone"
- Source code is available (GitHub)
- Backups are available (S3 + Backblaze)
- Credentials are available (1Password)
- Domain registrations are intact

### 6.2 Target end state

- Platform is running
- One test tenant can log in and see their data
- One test agent can run an invocation successfully

### 6.3 Procedure (rough)

```
1. Provision Hetzner infrastructure (manual or terraform)
2. Deploy Postgres cluster
3. Restore Postgres from pgBackRest
4. Deploy platform services (dashboard, notifier, provisioning, etc.)
5. Restore DynamoDB from snapshots
6. Restore vault repos from Backblaze
7. Configure Cloudflare DNS
8. Deploy at least one tenant's runtime
9. Verify dashboard access
10. Verify a single agent invocation
```

### 6.4 Target time

Stretch: 8 hours. Realistic: 24 hours.

Comparing to SLA RTOs:
- Starter RTO is "1 business day" — roughly matches the full rebuild scenario
- Enterprise RTO is 4 hours — NOT achievable with full rebuild; Enterprise RTO is for common scenarios (single DB failure) not catastrophic loss

If an Enterprise customer hit catastrophic loss, their 4h RTO is a best-effort commitment with honest explanation that rebuild from zero takes longer.

### 6.5 First-time drill expectations

First full rebuild drill will be slow and messy. Expect 48-72 hours, not 24. Subsequent drills are faster as we fix gaps.

The gap list from first drill probably includes:
- Some platform service required manual config not in code
- Some environment variable was in 1Password but not documented which
- Some script assumed DNS propagation that didn't happen in the drill
- Some backup was encrypted with a key nobody had documented access to

These are the discoveries that matter. Finding them during a drill beats finding them during a real incident.

---

## 7. Tenant-level restore

Most real incidents don't require full DR; they require restoring one tenant's data.

### 7.1 Scenarios

- Tenant accidentally deletes important content from their vault
- Tenant's schema got corrupted
- Customer requests restore to a previous state (rare; usually a paid service)

### 7.2 Vault content restore

Git-based content is just `git revert` or `git checkout <sha>` — straightforward. No dedicated runbook needed.

### 7.3 Postgres per-tenant restore

```bash
# Restore a specific tenant's schema from PITR

# Step 1: Provision a spare Postgres host
ssh restore-test-host

# Step 2: Restore full cluster to PITR target
pgbackrest --stanza=primary --type=time \
  --target="YYYY-MM-DD HH:MM:SS+00" restore

# Step 3: Start Postgres; extract just the tenant schema
pg_dump -Fc -n tenant_xxx -f /tmp/tenant_xxx.dump

# Step 4: Restore into production (after coordination)
pg_restore -d clawd_prod --no-owner /tmp/tenant_xxx.dump
```

Takes 1-2 hours depending on data size. Coordinated with the tenant (they'll see brief disruption).

### 7.4 Chargeable?

- If tenant-caused (their action deleted data): chargeable as a Data Recovery service (flat £500 per restore for Starter/Growth; included free annually for Scale/Enterprise)
- If platform-caused (our bug corrupted data): free; service credit as appropriate

Policy in SLA spec.

---

## 8. Backup integrity checks

Beyond the weekly restore test, we run lighter checks more frequently.

### 8.1 Daily automated checks

- Backup job completed (pgBackRest reports success)
- Backup size within ±20% of last 7d average (catches unexpected truncations)
- WAL archive is current (no gap >5 min)
- S3 cross-region replication is current

All via Prometheus + alerts. Failures route to `#alerts` SEV-3.

### 8.2 Monthly spot-checks

- Pick a random recent backup
- Do a minimal restore verification (faster than weekly full test)
- Confirm no gradual drift in backup health

### 8.3 Quarterly deep audit

- Full inventory of what we're backing up vs what we should be
- Review retention — are we keeping too much? too little?
- Review restore procedures — still accurate?
- Update this runbook

---

## 9. Offline / cold backups

Most of our backups live in AWS. What if AWS account is compromised?

### 9.1 Mitigation: Backblaze B2 cold copies

- Weekly mirror of critical backups to Backblaze (separate cloud provider)
- Different credentials (no IAM overlap with AWS)
- Encrypted with a key stored in 1Password, not rotated with other secrets

### 9.2 Access to cold backups

- 1Password entry: "DR - Backblaze B2 cold backups"
- Access requires 1Password + MFA
- Restoring from cold: intentionally slow (~1 day to re-download full backup)

### 9.3 Drill scenario

One quarterly drill (rotated into Q4 rebuild sometimes) specifically exercises cold backup restore:
- Assume AWS account compromised or lost
- Restore Postgres from Backblaze B2 copy
- Measure time

### 9.4 Why this matters

Ransomware attacks in 2024-2025 have occasionally targeted backup systems (deleting backups same time as encrypting primary). Separate provider + offline-ish copy makes that attack much harder.

---

## 10. Service-specific DR considerations

### 10.1 Postgres cluster

Primary architecture: primary + streaming replica + vector replica (Phase 3 schema spec). DR:
- Single-server failure: automatic failover (minutes)
- Both servers failed: restore from S3 (hour scale)
- Both servers + region gone: restore from Backblaze (day scale)

### 10.2 Temporal cluster

Temporal state lives in Postgres (same cluster). Rebuilding Temporal means:
- Restore Postgres (as above)
- Redeploy Temporal cluster (automated)
- Workflows resume from their last checkpoint (built into Temporal)

### 10.3 Secrets vault (DynamoDB + KMS)

- DynamoDB PITR (35 days) + daily S3 exports
- KMS CMKs have automatic key-material rotation; key IDs stable
- DR target: 1 hour to restore DynamoDB from PITR; data is useless without CMKs (in AWS custody)

### 10.4 Tenant container hosts

- Hosts are ephemeral; state is in `/mnt/tenants/xxx` volumes
- Volumes are NFS-mounted from a central NAS (Hetzner or S3-backed)
- Host failure: spin up new host, NFS mount, tenant resumes
- NAS failure: bigger problem; NAS itself has failover + daily snapshot

### 10.5 Dashboard (Next.js)

Stateless. Deploy restores everything. Config is in env vars (1Password + deploy system).

---

## 11. Communications during real DR

When something is actually down and DR is happening:

### 11.1 Internal

- Incident response runbook flow applies
- Scribe captures the DR timeline minute-by-minute (this is gold for next drill)

### 11.2 External

- Status page: honest, plain, no promises
- Customer email for SEV-1: "We're executing a planned recovery; will update when complete"
- Do not promise specific ETAs during DR; they're almost always wrong

### 11.3 Post-DR

- Postmortem includes the DR procedure itself
- Compare actual vs target RTO; honest assessment
- Update this runbook with lessons

---

## 12. Tooling

### 12.1 Scripts we maintain

- `scripts/dr/provision-fresh-restore-env.sh` — stands up a clean Hetzner host ready for restore
- `scripts/dr/full-platform-rebuild.sh` — step-by-step semi-automated rebuild (used in drills)
- `scripts/dr/tenant-schema-restore.sh` — single-tenant restore helper
- `scripts/dr/verify-backup.sh` — checks integrity of a given backup

All live in `infrastructure/dr-scripts` repo. Tested in every drill.

### 12.2 Prometheus alerts

- `backup_job_failed` — daily backup didn't complete (SEV-2)
- `backup_size_anomaly` — size deviation >20% from recent average (SEV-3)
- `wal_archive_lag` — WAL archive is behind (SEV-2)
- `restore_test_failed` — weekly restore test failed (SEV-3)
- `s3_replication_stalled` — cross-region replication not current (SEV-3)

### 12.3 Grafana dashboards

- "Backup Health" — all backup jobs, sizes, status
- "DR Readiness" — restore test history, time-to-restore trend
- "Capacity Planning" — storage used for backups over time

---

## 13. Roadmap for DR maturity

v1 (launch):
- Weekly restore tests, quarterly drills, annual full rebuild drill
- Single region primary with multi-region backup replication
- Backblaze B2 cold backups

v1.5 (by tenant 20):
- Hot standby in secondary region (faster RTO for regional outages)
- Chaos engineering: intentional failure injection in staging

v2 (by tenant 50):
- Multi-region active-active (for Enterprise data-residency)
- Automated failover beyond Postgres level (load balancer aware of regions)

Each step increases cost; each step's benefit is paid for by the tenant tier that needs it.

---

## 14. Never do during DR

- Run a drill in production (always in dedicated DR environment)
- Restore over top of a healthy production without manual override (scripts should refuse)
- Skip the verification step ("it looks restored")
- Shortcut the procedure because "it's slow" — the slow procedure is the tested one
- Assume backups exist without verifying (that's literally why this runbook exists)
- Delete old backups for "space reasons" (storage is cheap; history is irreplaceable)

---

## 15. Related

- `phase-3-platform/dr/backup-and-dr-runbook.md` — architectural spec for backups + DR
- `phase-5-business-legal/legal/sla-spec.md` — RPO/RTO commitments we're proving
- `routines/secret-rotation-runbook.md` — sibling routine
- `runbooks/postgres-incidents.md` — real incident procedures
- `compliance/gdpr-dsar-and-deletion-runbook.md` — related compliance operations
