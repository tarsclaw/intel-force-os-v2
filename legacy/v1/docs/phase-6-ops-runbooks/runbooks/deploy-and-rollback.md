# Deploy & Rollback Runbook

**How we deploy code to production, what checks gate a deploy, how rollbacks work, and how to handle emergency hotfixes.**

> **Audience:** anyone shipping code. In v1 that's Maddox (+ occasional Jack) and anyone we hire.
>
> **Status:** v1.0. Matches the deployment infrastructure described in `phase-4-dashboard/architecture/dashboard-architecture-spec.md §9` and Phase 3 platform deployment implied by each service's spec.
>
> **Philosophy:** deploys should be boring. Exciting deploys are failed deploys. A production deploy is a routine event that any team member can run with confidence at any hour.

---

## 1. What counts as a deploy

Any change to production code or config:

- Merge to `main` triggering CI → deploy to staging automatically
- Manual approval → deploy to production
- Migration run (Prisma migrate) against production
- Config change deployed (environment variables, feature flags)
- Infrastructure change (new Hetzner node, LB config, Cloudflare rule)

Not all of these use the same flow, but all are "deploys" in the sense that they change production state and carry risk.

### 1.1 What's NOT a deploy

- Rotating a single tenant's secret (runbook elsewhere)
- Changing a tenant's config (platform operator action)
- A customer editing their tenant settings
- Ad-hoc database queries (but: destructive ones require two-person approval regardless)

---

## 2. Deploy environments

| Environment | Purpose | Traffic | Deploy trigger |
|---|---|---|---|
| `local` | Developer laptops | — | Every save |
| `preview-*` | PR-specific preview (subdomain per PR) | Internal team | Auto on PR open |
| `staging` | Pre-production; mirrors production schema | Internal team + test tenants | Auto on merge to `main` |
| `production` | Live customer traffic | Real customers | Manual approval post-staging-soak |

**Staging soak:** every change must sit in staging for at least 30 minutes before production deploy is allowed. Longer soak (24h) for database migrations.

---

## 3. The pre-deploy checklist

Before approving a production deploy, the deployer verifies:

```
□ 1. CI green on the commit being deployed (all tests pass)
□ 2. Change has been in staging at least 30 minutes
   (24 hours for DB migrations; 1 week for schema-changing migrations)
□ 3. Deploy is during business hours UK (Mon-Thu 09:00-17:00)
   unless genuinely emergency (see §8)
□ 4. On-call primary acknowledges the upcoming deploy in #ops
□ 5. No active SEV-1 or SEV-2 incident
□ 6. Cost budget for the deploy-window is normal
   (deploys during cost anomalies are risky)
□ 7. If DB migration: backup verified fresh (< 1 hour old)
□ 8. Rollback plan documented in PR description
□ 9. Deploy window announced in #ops 15 min ahead
```

Yes, that's a lot. Yes, they all matter. Yes, routine deploys hit all 9 in under 5 minutes once you're used to the flow.

### 3.1 Friday deploy policy

No deploys after 14:00 UK on Fridays (Thursday for risky changes). Weekend incidents from Friday-evening deploys are painful; we prevent them by policy.

Exception: security hotfix. See §8.

### 3.2 Holiday policy

No production deploys the day before or day of UK bank holidays. The team may be unavailable; avoid.

---

## 4. Regular production deploy

Full flow:

```
1. PR merged to main
   ↓
2. GitHub Actions: build + test + push Docker image tagged with Git SHA
   ↓
3. Staging deployment auto-triggers
   ↓
4. Staging smoke tests run (automated)
   ↓
5. 30-min soak period (longer for migrations)
   ↓
6. Deploy approver clicks "Deploy to production" in GitHub Actions
   (or via Slack slash command: /deploy production)
   ↓
7. Production deploy:
   a. Old instances drain traffic via LB (5 min)
   b. New instances come up, health checks pass
   c. Traffic switches to new instances
   d. Old instances terminate after 10 min safety window
   ↓
8. Post-deploy smoke tests run automatically
   ↓
9. Prometheus dashboard watched for 15 min post-deploy
   ↓
10. Deploy announced in #ops as complete
```

### 4.1 Deploy approver responsibilities

The approver is NOT the author of the PR (where possible). If one-person team, the same person can author + approve but should take a lunch break between PR author and deploy approver — fresh eyes.

The approver:
- Re-reads the PR description and diff
- Verifies each checklist item in §3
- Approves only if they'd be comfortable explaining the change at 03:00 during an incident

### 4.2 Smoke tests (automated)

Run against production immediately post-deploy:

- Dashboard `/api/health` returns 200
- Sign-in flow works (test account)
- A dummy tenant's test invocation succeeds
- tRPC procedures respond within SLA
- Cost ingestion from Anthropic still working (recent usage rows in DB)

Smoke tests fail → auto-rollback kicks in (see §6).

### 4.3 15-minute post-deploy watch

Deploy approver stays on the dashboard for 15 min after deploy. Watches:
- Error rate (`dashboard_trpc_error_rate`)
- Latency (`dashboard_page_load_p95`)
- Memory (`process_resident_memory_bytes`)
- Anthropic usage (`anthropic_requests_total` rate)

If any anomaly: evaluate whether to rollback. Err on side of rollback — we can always redeploy.

---

## 5. Database migrations

Migrations are the highest-risk deploys. They can be irreversible (dropping a column) and can take the DB offline (locking a large table).

### 5.1 Migration rules

- Migrations are forward-only; no down migrations
- Migrations must be idempotent (check state before acting)
- Schema changes are deployed in isolation (one migration per deploy; no code + migration in same deploy unless trivial)
- Adding a column: always nullable or with default; never NOT NULL without default
- Renaming a column: two-deploy flow (add new name, deprecate old; remove old in later deploy)
- Dropping a column: two-deploy minimum (code stops reading; confirm; then drop)
- Adding an index: use `CREATE INDEX CONCURRENTLY`
- Large table changes: off-hours (staging soak: 1 week minimum)

### 5.2 Migration deploy process

```
1. Migration PR opened
2. Staging deploys the migration
3. Wait at least 24 hours; confirm staging runs normally
4. Production pre-migration backup snapshot (verify fresh)
5. Deploy approver approves migration separately from code changes
6. Migration runs:
   a. `npx prisma migrate deploy` against production
   b. Verify schema matches expected state
   c. If migration is fast (<1s), continue
   d. If migration is slow or risky, monitor pg_stat_activity in parallel
7. Code that depends on migration deploys AFTER migration completes
8. 15-min post-migration watch for unusual query errors
```

### 5.3 Long migrations

For migrations expected to take >1 min:
- Announce in #ops 1 hour ahead
- Run during low-traffic window (early UK morning)
- Have rollback plan rehearsed (PITR to pre-migration timestamp)
- IC-style coordination during the migration

---

## 6. Rollback

When something goes wrong, rollback is the first option. It should be fast and boring.

### 6.1 Application-level rollback

For code changes (no migration):

```bash
# Via GitHub Actions UI:
# - Navigate to Actions → "Deploy production" workflow
# - Re-run with the previous Git SHA as the image tag

# Or via Slack:
# /deploy production sha=abc1234   (the previous sha)

# Or via command line:
bash scripts/deploy-production.sh --tag=abc1234
```

Blue-green deployment means rollback is fast:
- LB starts routing to the old image tag's instances (which we kept for 10 min post-deploy)
- If the 10-min window has expired, trigger a fresh deploy of the old tag
- Old deploy spins up in 2-3 min

### 6.2 Rollback timing targets

- Detect need to rollback: < 15 min from deploy (the 15-min watch)
- Execute rollback: < 5 min
- Total incident duration: < 30 min ideally, < 60 min cap

If you're over an hour into a broken deploy without rolling back, you've made the wrong decision — rollback and then debug in staging.

### 6.3 When NOT to rollback

- Rollback would break migrations that ran forward (DB schema can't go back without PITR)
- Customer data has been written that depends on the new code (rollback would lose that data)
- The new code is better than the old code at everything except one minor issue — might be better to hotfix forward

### 6.4 Migration rollback

If a migration itself went wrong (not the code after):

Option A — forward fix:
- Write a new migration that corrects the state
- Deploy it
- Preferred when possible (no data loss risk)

Option B — PITR:
- Restore DB to the timestamp just before migration
- Covered in `runbooks/postgres-incidents.md` §9
- Last resort (data loss risk)

Option C — schema surgery:
- Manually fix the schema state with psql
- Requires two-person approval
- Document commands in the incident timeline

---

## 7. Hotfix flow (emergency fixes)

Sometimes a critical bug needs deploying outside business hours. The hotfix flow makes this explicit and careful.

### 7.1 When hotfix is warranted

- Security vulnerability being actively exploited (rare but real)
- Active SEV-1 where a code change is the fix
- Compliance deadline (e.g., must ship by end of day to meet a regulator ask)

NOT warranted:
- Feature customer is waiting for (can wait until business hours)
- Bug that's annoying but not customer-visible
- Performance improvement

### 7.2 Hotfix process

```
1. Declare the situation in #ops
2. Two-person sign-off — author + reviewer (same person can't do both)
3. PR opened against main with clear commit message "HOTFIX: ..."
4. CI runs (do NOT skip)
5. Deploy to staging for at least 10 min (shortened soak)
6. Staging smoke tests pass
7. Production deploy with 15-min watch
8. Post-incident (if relevant): normal postmortem covering the hotfix
```

The 10-min staging soak is non-negotiable even for emergencies. Direct-to-production deploys cause more incidents than they resolve.

### 7.3 Hotfix rules

- Smallest possible change (no "while we're in here" additions)
- Documented in the Slack thread as it happens (scribe-style)
- Postmortem covers both the original bug and the hotfix decision

---

## 8. Infrastructure deploys

Changes to Hetzner, Cloudflare, or AWS infrastructure.

### 8.1 Immutable infrastructure principle

Where possible, infrastructure is defined in Terraform / Pulumi and deployed through PRs same as code. In practice for v1, some Cloudflare and Hetzner changes are UI-only; we document them in `infrastructure-changelog.md` at a minimum.

### 8.2 Dangerous infrastructure changes

Changes that need extra scrutiny:
- DNS changes (can cause outages; SSL cert issues)
- Cloudflare WAF rule changes (can block legitimate traffic)
- Hetzner LB config (routing changes affect all tenants)
- AWS IAM policies (over-grants are breach risk; under-grants are outages)
- KMS key policy changes (can make existing secrets unrecoverable)
- Production host reimages (lose local state)

All require:
- PR (or documented change proposal if UI-only)
- Two-person sign-off
- Staging rehearsal where possible
- Rollback plan documented

---

## 9. Feature flags

For gradual rollouts and quick-kill switches:

### 9.1 Flag types

- **Kill switches:** on/off per feature (quick disable if bug discovered)
- **Gradual rollouts:** percentage or tenant-allowlist based
- **Experiments:** A/B tests (rare in v1; mostly for pricing page variants)

### 9.2 Flag storage

Simple v1: JSON config in `control.platform_config` table. Read by dashboard on each request (cached 60s).

v2 consideration: Unleash or LaunchDarkly if experiments grow.

### 9.3 Flag rules

- Every flag has an owner
- Flags have a kill-by date (no permanent flags — they become permanent config after validation)
- Rolling out a feature behind a flag: Starter tenants first, then Growth, then Scale (risk tolerance ladder)
- Turning off a flag in an emergency: the IC can override the owner; document in #ops

---

## 10. Agent deploys

Agents (Proposal Builder, Lead Hunter, etc.) are special:
- Their "code" is the system prompts + tool configs in their bundle
- Deploys happen when we rev an agent's version
- Tenants pin to agent versions; they don't automatically upgrade

### 10.1 Agent version rollout

```
1. New agent version (e.g., proposal-builder@2.0.0) PR'd to intelforce-vaults/agents
2. Deployed to staging; internal test tenants get version 2.0.0 enabled
3. Run in staging for at least 1 week; compare output quality vs 1.x
4. Gradual production rollout:
   a. Staging test tenants: v2.0.0 (Week 1)
   b. Starter tenants: v2.0.0 (Week 2)
   c. Growth tenants: v2.0.0 (Week 3)
   d. Scale + Enterprise tenants: v2.0.0 (Week 4)
5. Deprecate v1.x after 30 days (tenants still on v1.x get an email to upgrade)
```

### 10.2 Agent rollback

If v2.0.0 is worse than v1.x for some tenants:
- They can pin back to v1.x in their tenant config
- Platform supports multiple versions running simultaneously during transition

---

## 11. Specific tooling

### 11.1 GitHub Actions

- Workflow files in `.github/workflows/`
- Required checks on PRs: lint, typecheck, unit tests, build
- Deploy workflow: `deploy-production.yml` (requires manual approval)
- Secrets stored in GitHub Secrets; referenced by deploy workflow

### 11.2 Deploy scripts

`scripts/deploy-production.sh` — orchestrates the blue-green deploy. Key steps:
1. Pull new image tag
2. Start new containers
3. Health check new containers
4. LB config update (routes to new)
5. Wait 10 min
6. Terminate old containers

### 11.3 Rollback scripts

`scripts/rollback-production.sh` — reverse of deploy. Flags:
- `--fast` (LB flip only; for within-10-min rollback)
- `--full` (redeploy old image; for beyond-10-min)

### 11.4 Migrate tooling

Prisma migrate. `npx prisma migrate deploy` against production uses a dedicated migrate-only DB role that has schema-modification rights but cannot read/write data tables.

---

## 12. Observability during deploys

Every deploy emits events:
- `deploy_started` → Prometheus counter
- `deploy_completed` → Prometheus counter with `status=success|failure`
- `rollback_triggered` → Prometheus counter

Grafana "Deploys" dashboard shows these alongside error-rate and latency panels. Correlating a post-deploy error spike to the specific deploy is one glance.

---

## 13. Testing rollbacks — quarterly exercise

Every quarter, run a deliberate rollback exercise:
- Announce in #ops
- Deploy a trivial change to staging
- Rollback within 10 minutes
- Verify rollback succeeded
- Document any friction discovered

Rollbacks rust. Exercising them keeps the muscle warm.

---

## 14. Never do during a deploy

- Skip CI (even if "it's just a one-liner")
- Deploy during a SEV-1 incident (unless the deploy IS the fix)
- Deploy and leave (stay through the 15-min watch)
- Approve your own PR for production deploy
- Run migrations without a fresh backup
- Deploy multiple unrelated changes together (obscures cause if something breaks)
- Deploy on Friday afternoon or the day before a holiday (see §3.1, §3.2)

---

## 15. Related

- `incident-response/incident-response-runbook.md` — if deploy breaks things
- `runbooks/postgres-incidents.md` §9 — if migration goes wrong
- `phase-4-dashboard/architecture/dashboard-architecture-spec.md §9` — deployment architecture
- `phase-3-platform/postgres/schema-spec.md` — migration templates
- `routines/backup-verification-and-dr-drills.md` — pre-migration backup verification
