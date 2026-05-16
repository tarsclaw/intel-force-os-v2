# Platform Service Incident Runbook

**Specific response procedures for incidents affecting platform services: Escalation Notifier, Secrets Vault, Provisioning System, Webhook Receiver, and Dashboard.**

> **Audience:** on-call operator during a platform-service incident.
>
> **Status:** v1.0. Each section assumes the service architecture documented in the corresponding Phase 3 or Phase 4 spec.
>
> **Design decision:** we keep all platform-service runbooks in one file (rather than one per service) because they share patterns (restart, backlog-replay, fallback-mode) and an operator under pressure should have them side-by-side rather than navigating between files.

---

## 1. Common patterns across all services

Before diving into specific services, these patterns apply broadly:

### 1.1 The "restart first, ask questions later" trap

For stateful services (Provisioning System, Escalation Notifier) restarting can cause problems:
- In-flight work is aborted mid-operation
- Backlog can build up during restart
- State machines may end up in unexpected states

Always check: is the service genuinely stuck, or just slow? Logs + metrics tell you. Restart as last resort unless the runbook explicitly says restart is safe.

### 1.2 Fallback-mode awareness

Most services have a degraded mode:
- Escalation Notifier: Slack-only (no DB writes) if Postgres is down
- Webhook Receiver: accept and queue (no immediate processing) if downstream is saturated
- Dashboard: read-only mode if Postgres primary is down (replica reads work)

Knowing which fallback mode is active matters — the service may be "up" from a monitoring perspective but not fully functional.

### 1.3 Backlog replay

Services process queues. When a service comes back from an outage, backlog replay is its own risk:
- Duplicate processing (idempotency is mandatory — most of Phase 3 is designed with this)
- Cascading load (100 escalations all firing Slack notifications in 10 seconds)
- Stale data (a webhook queued 2 hours ago may no longer be relevant)

Every runbook below considers the post-recovery replay step.

---

## 2. Escalation Notifier incidents

The Escalation Notifier watches `/mnt/tenants/*/outbox/escalations/` via `fsnotify`, writes to Postgres `control.escalations`, pushes to Slack via tenant-configured webhooks, and emits SSE events to the dashboard.

Spec reference: `phase-3-platform/services/escalation-notifier-spec.md`.

### 2.1 Incident: Notifier down

**Symptoms:**
- Prometheus: `escalation_notifier_up == 0`
- Customer complaint: "I'm not getting Slack alerts about escalations"
- No recent entries in `control.escalations` despite tenant outbox having files

**Severity:** SEV-2. Escalations pile up but tenants can still see them in the dashboard (if dashboard is up).

**Diagnosis:**
```bash
# SSH to notifier host
ssh notifier-primary

# Check service status
sudo systemctl status escalation-notifier

# Check recent logs
sudo journalctl -u escalation-notifier -n 200

# Check file handle health
sudo ls /proc/$(pidof escalation-notifier)/fd | wc -l  # should be stable
```

**Common causes:**
| Cause | Evidence | Fix |
|---|---|---|
| Process crashed | systemctl shows failed | Restart: `sudo systemctl restart escalation-notifier` |
| Postgres unreachable | Logs show "connection refused" | Fix Postgres first; notifier auto-recovers |
| Disk full on notifier host | `df -h` | Clean logs; expand volume |
| fsnotify watcher ran out of file handles | Logs: "too many open files" | Increase `ulimit`; restart |
| Slack webhook 404 for a specific tenant | Logs: repeated 404s for one URL | Mark tenant integration as broken; notify tenant |

**Recovery:**
1. Fix underlying cause
2. Restart service (safe — notifier is stateless; it re-scans outboxes on startup)
3. Verify: drop a test escalation file, watch it appear in dashboard
4. Monitor backlog — if 100+ files queued, expect Slack rate-limiting as it catches up

### 2.2 Incident: Slack delivery failing

**Symptoms:**
- Notifier logs: repeated Slack 429 (rate limit) or 500 errors
- Tenants reporting missing Slack notifications
- `control.escalations` is populated (DB writes OK) but `slack_delivered_at` is null

**Severity:** SEV-3 for one tenant; SEV-2 if platform-wide.

**Diagnosis:**
```bash
# On notifier host
sudo journalctl -u escalation-notifier -n 500 | grep slack
```

**Fixes:**
- 429 rate limit: built-in exponential backoff should handle; if persistent, contact Slack workspace admin
- 404 webhook URL: tenant's Slack webhook was deleted/rotated — mark integration broken
- 500 Slack side: wait; see Slack status page
- Platform-wide 500s: our webhook URL parsing might be corrupted; check recent deploys

**Workaround:** email fallback. For SEV-2 Slack-wide issue, manually email affected tenant admins with the queued escalation summaries until Slack recovers. Use the escalation note content verbatim.

### 2.3 Incident: Notifier consuming huge memory

**Symptoms:**
- Prometheus: `process_resident_memory_bytes{job="escalation-notifier"} > 1GB`
- OOM warnings

**Cause:** usually a queue backlog from a previous Postgres outage that's now being replayed.

**Fix:**
- Let it drain; memory drops as backlog processes
- If critical, restart the service — it re-reads from outboxes; duplicates are de-duplicated by (tenant_id, file_path) unique constraint

### 2.4 Incident: Duplicate notifications

**Symptoms:** tenants receive Slack notifications twice for the same escalation.

**Cause:** notifier process was restarted mid-send; didn't write `slack_delivered_at` before crash.

**Fix:** one-time; explain to affected tenants. Long-term: the notifier needs a pre-send lock (tracked as action item from first occurrence).

### 2.5 Incident: SSE stream dropping for dashboard

**Symptoms:** dashboard real-time escalation feed not updating; page refresh works.

**Cause:** network path between dashboard and notifier dropped long-lived connection (Cloudflare 100s timeout is common culprit).

**Fix:** dashboard should auto-reconnect. If not reconnecting, check dashboard client-side code. Separately, configure Cloudflare to allow long-lived connections on the `/sse/` path.

---

## 3. Secrets Vault incidents

The Secrets Vault is a Node service over DynamoDB, using per-tenant AWS KMS CMKs. Agents fetch secrets at invocation time; dashboard reads masked metadata only.

Spec reference: `phase-3-platform/secrets/secrets-vault-spec.md`.

### 3.1 Incident: Vault unreachable

**Symptoms:**
- Agent invocations failing with "unable to fetch secret" errors en masse
- `secrets_vault_up == 0`
- Dashboard Settings → Secrets panel spinning forever

**Severity:** SEV-1. Without vault, no agent can run — platform is effectively down.

**Diagnosis:**
```bash
# SSH to vault host
ssh secrets-vault-01

# Service status
sudo systemctl status secrets-vault
sudo journalctl -u secrets-vault -n 200

# DynamoDB connectivity
aws dynamodb describe-table --table-name clawd-secrets-vault
# If this fails → AWS connectivity issue, not our code

# KMS connectivity
aws kms describe-key --key-id <any-test-CMK>
```

**Common causes:**
| Cause | Fix |
|---|---|
| Process crash | Restart systemctl; check logs for panic root cause |
| AWS credentials expired | Rotate instance profile; restart |
| DynamoDB throttled | Increase provisioned capacity; consider on-demand mode |
| KMS API rate limited | Contact AWS support; spread decrypt calls |
| Network partition to AWS | Check VPN/direct-connect; fall back to secondary region if set up |

### 3.2 Incident: KMS CMK deleted

**Symptoms:** KMS `DescribeKey` returns "KeyUnavailableException" or "NotFoundException" for a specific tenant's CMK.

**Severity:** SEV-1 for that tenant. Every secret encrypted under that CMK is now unrecoverable.

**Why this happens:** accidental deletion (CMKs have a 7-day soft delete; deletion must be scheduled, not immediate). This is almost never "unexpected."

**Fix:**
1. Check CMK deletion schedule: `aws kms list-keys` and `aws kms describe-key --key-id ...`
2. If within 7-day pending-delete window: `aws kms cancel-key-deletion --key-id ...` — recoverable
3. If past the window: **secrets are gone.** Emergency rotation runbook: tenant must re-provide all secrets (re-run Configuration Wizard's integration step)
4. SEV-1 incident; postmortem must identify how the deletion was initiated and by whom

### 3.3 Incident: Wrong secret returned

**Symptoms:** agent logs show wrong API key or OAuth token (e.g., agent for Tenant A using Tenant B's secret).

**Severity:** SEV-1. Cross-tenant data mixing suspected.

**First actions:**
```
□ 1. Declare SEV-1, invoke breach runbook
□ 2. Suspend both affected tenants (prevent further mixing)
□ 3. Investigate how the wrong secret was returned
   - Audit log check: what was requested? What was returned?
   - Bug? Cache poisoning? Environment variable leak?
□ 4. Rotate all secrets for the affected tenants
```

**Common causes:**
- Bug in secret-ref parsing (`secrets://tnt_A/...` somehow returning tnt_B)
- Cache returning stale result after a rotation
- Shared environment variable leaking across tenants (should never happen if tenant isolation is correct)

### 3.4 Incident: Rotation job failing

**Symptoms:**
- Prometheus: `secret_rotation_failures_total > 0`
- Slack alerts: "Rotation failed for secrets://tnt_X/provider/kind"

**Severity:** SEV-3 per rotation. SEV-2 if multiple.

**Diagnosis:**
```bash
# Check the rotation scheduler logs
ssh scheduler-host 'sudo journalctl -u scheduler -n 500 | grep rotate'
```

**Common causes:**
| Cause | Fix |
|---|---|
| Provider API change | Update rotation code for that provider; manual rotate tenant's secret |
| Dual-window already has 2 active secrets | Old one hasn't expired; wait for window to close |
| Network issue to provider | Retry automatically kicks in |
| Tenant's OAuth refresh token expired | Mark integration as `pending_reauth`; notify tenant |

Don't leave rotation failures unaddressed — eventually the old secret expires and the integration breaks.

### 3.5 Incident: Vault auto-scaling / cost anomaly

**Symptoms:**
- AWS bill spike on KMS or DynamoDB
- Many more `Decrypt` calls than expected

**Cause:** an agent in a loop, calling the vault repeatedly instead of caching within its invocation.

**Fix:** diagnose which tenant; suspend that tenant; file bug against the agent's code.

---

## 4. Provisioning System (Temporal) incidents

The Provisioning System runs Temporal workflows: `TenantOnboard` (15 steps), `TenantReprovision`, `TenantDecommission`. Hosted as a Temporal cluster with Node workers.

Spec reference: `phase-3-platform/provisioning/provisioning-system-spec.md`.

### 4.1 Incident: Temporal cluster down

**Symptoms:**
- New tenant onboarding stuck at "Initialising..."
- `temporal_frontend_up == 0`
- Temporal UI at https://temporal.clawd.ai shows red

**Severity:** SEV-2. Existing tenants unaffected; only new onboardings / reprovisions blocked.

**Diagnosis:**
```bash
# Temporal has multiple components: frontend, history, matching, worker
# Check them all
ssh temporal-cluster-01
sudo systemctl status temporal-*

# Check Temporal's own database (runs on shared Postgres)
psql -h primary-db-01 -U temporal -d temporal \
  -c "SELECT * FROM information_schema.tables WHERE table_schema = 'public' LIMIT 5;"
```

**Common causes:**
| Cause | Fix |
|---|---|
| Temporal-internal Postgres schema issue | Restore from backup; restart |
| Temporal version upgrade in progress | Wait for upgrade completion |
| Temporal frontend OOM | Restart; increase memory limit |
| Worker disconnected (but frontend up) | Restart workers; workflows queue until they reconnect |

### 4.2 Incident: Workflow stuck

**Symptoms:**
- Specific workflow in "Running" state for far longer than expected
- Wizard Step 9 stuck at a specific step

**Severity:** SEV-3 per workflow.

**Diagnosis:**
```bash
# Use Temporal CLI
temporal workflow describe --workflow-id <wf_id>
temporal workflow stack --workflow-id <wf_id>  # shows current activity
```

**Common causes:**
| Cause | Fix |
|---|---|
| Waiting on external (OAuth handoff, provider callback) | Check if external action completed; nudge tenant |
| Activity hit retry limit | Via dashboard: retry activity, or abort workflow |
| Activity worker is down | Restart worker; workflow resumes |
| Workflow hit timeout | Workflow will auto-fail; retry via dashboard |

### 4.3 Incident: Workflow signal not delivered

**Symptoms:** dashboard issued `signalWorkflow` but Temporal didn't process it.

**Fix:**
```bash
# Check signal queue
temporal workflow show --workflow-id <wf_id> --type signal
```

Signals can be lost if Temporal frontend is down at signal-time. Dashboard should queue signals locally and retry on connection restore (check dashboard → Temporal integration code).

### 4.4 Incident: Compensation failed

When a workflow aborts, compensations (undo steps) run. If compensations fail:
- Tenant may be left in an inconsistent state
- Leaks: KMS CMKs, GitHub repo, DB schema

**Fix:**
1. Identify what compensations ran and what didn't
2. Manually clean up the leaks:
   - KMS: schedule deletion of orphaned CMKs (7-day window)
   - GitHub: delete the repo manually
   - DB: drop the tenant schema manually
3. Mark workflow complete (with failure note)

Long-term: compensations should be idempotent and retryable; ensure this in code.

---

## 5. Webhook Receiver incidents

Fastify service that receives webhooks from integrations (Fathom, HubSpot, Calendly, etc.) and routes them to the appropriate tenant's agent queue.

Spec reference: `phase-1-poc-stack/platform-specs/webhook-receiver-spec.md`.

### 5.1 Incident: Receiver dropping webhooks

**Symptoms:**
- Tenant: "My Fathom call ended but no proposal draft was created"
- `webhook_receiver_requests_total - webhook_receiver_processed_total > 100`
- Loki: webhook requests arriving but not being queued

**Severity:** SEV-2. Agents don't run for affected tenants.

**Diagnosis:**
```bash
ssh webhook-receiver-01
sudo systemctl status webhook-receiver
sudo journalctl -u webhook-receiver -n 500 | grep -i error
```

**Common causes:**
| Cause | Fix |
|---|---|
| Downstream queue (NATS / Redis) full | Scale downstream; webhook receiver should return 503 and providers retry |
| HMAC signature verification failing | Tenant's webhook secret was rotated; integrations config out of sync |
| Malformed webhook from provider | Log and skip; don't crash the receiver |
| Memory leak | Restart; file bug |

### 5.2 Incident: Signature validation failures

**Symptoms:** all webhooks from one provider returning 401 "invalid signature".

**Cause:** either our secret is stale or provider rotated their signing key.

**Fix:**
1. Check provider's admin console — do they show a current webhook secret?
2. Compare with our secrets vault: `SELECT last_rotated FROM control.secrets_metadata WHERE tenant_id = 'tnt_xxx' AND kind = 'webhook_secret';`
3. If out of sync, manually rotate our secret to match provider's
4. If provider rotated their side: force provider to re-send recent webhooks (manual action via provider console) — our receiver will now accept

### 5.3 Incident: Receiver being flooded

**Symptoms:**
- Request rate 10x normal
- Loki shows same tenant's webhook endpoint being hit repeatedly

**Cause:** tenant's provider (e.g., misconfigured HubSpot workflow) is spamming us.

**Fix:**
1. Temporarily disable that tenant's webhook route in the receiver config
2. Notify tenant: "We've temporarily paused your HubSpot integration due to a flood of events. Please check your HubSpot workflow config."
3. Re-enable after tenant confirms fix

Receiver has per-tenant rate limits for exactly this — verify they're configured.

---

## 6. Dashboard (Next.js) incidents

The dashboard is the primary user interface. Two instances behind a Hetzner LB.

Spec reference: `phase-4-dashboard/architecture/dashboard-architecture-spec.md`.

### 6.1 Incident: Dashboard totally down

**Symptoms:** both Next.js instances returning 502 or timing out.

**Severity:** SEV-1.

**Diagnosis:**
```bash
# LB health check
curl https://app.clawd.ai/api/health

# Both instances
ssh dashboard-01 'sudo systemctl status dashboard'
ssh dashboard-02 'sudo systemctl status dashboard'

# Check if Postgres is reachable from both
ssh dashboard-01 'psql -h primary-db-01 -c "SELECT 1;"'
```

**Common causes:**
| Cause | Fix |
|---|---|
| Both instances crashed simultaneously (likely deploy) | Rollback via deploy runbook |
| Postgres down | Fix Postgres; dashboard will recover (but read-replica mode should cover reads) |
| Clerk outage | Dashboard is up but sign-ins fail (see auth subsection) |
| Redis down (for sessions) | Dashboard works but all users signed out |
| Cloudflare issue | Check Cloudflare status page; try bypassing (direct IP) to confirm |

### 6.2 Incident: Elevated error rate

**Symptoms:**
- `dashboard_tRPC_error_rate > 5%` for sustained period
- Some users reporting "things feel broken"

**Severity:** SEV-2 or SEV-3 depending on error rate.

**Diagnosis:**
```bash
# Loki query for recent errors
# Already saved as "dashboard-errors-last-hour" in Grafana

# Check which procedure is erroring
# Group by procedure name in the query
```

**Common patterns:**
- Single procedure erroring: likely bug in that procedure's code
- All procedures erroring: upstream dep (Postgres, Clerk, etc.) degraded
- Specific tenant's procedures erroring: that tenant has a config issue

### 6.3 Incident: Slow pages

**Symptoms:**
- Dashboard feels slow
- `dashboard_page_load_p95 > 3s`

**Diagnosis:**
```bash
# Check Postgres query performance
# Grafana "slow queries" dashboard

# Check Next.js instance resources
ssh dashboard-01 'top -b -n1 | head -20'
```

**Common causes:**
| Cause | Fix |
|---|---|
| Postgres queries slow | Missing index; check pg_stat_statements |
| Large data page (e.g., 10k invocations) | Pagination bug; enforce page size limits |
| Next.js instance CPU-bound | Scale up instance; or investigate hot code path |
| External API slow (Clerk, Anthropic) | Nothing we can do; inform tenant |

### 6.4 Incident: Sign-ins failing

**Symptoms:**
- New sign-ins: "Authentication error"
- Existing sessions still work

**Cause:** Clerk is down or our Clerk config changed.

**Fix:**
1. Check Clerk status page (https://status.clerk.com)
2. If Clerk down: status page update, wait
3. If not: check our Clerk config; recent changes? Environment variables right?
4. Longer outages: consider temporary Clerk session extension (dashboard middleware can fall back to longer session validity)

### 6.5 Incident: CSRF or session hijack suspicion

**Symptoms:**
- Customer reports: "I was suddenly signed out" or "I see someone else's account"
- Unusual Clerk session activity

**Severity:** SEV-1. Invoke breach runbook.

**First actions:**
1. Revoke all active sessions for the affected user via Clerk
2. Rotate any API keys associated with them (session-to-API-key linkage)
3. Full audit log review for their user_id
4. Notify user directly

---

## 7. Cross-service patterns

### 7.1 Cascading failure chain

Common chain: Postgres slow → Dashboard slow → User retries → More DB load → Postgres slower.

Break the chain by:
- Circuit breakers (if DB latency > X, return cached or 503 for Y seconds)
- Aggressive rate-limiting when system is stressed
- Load shedding (drop non-critical requests before they queue)

### 7.2 Provider outage compounding

When Anthropic is down, we see:
- Agents failing → escalations piling up → Slack notifications flooding → tenants asking "what's wrong"

Mitigation: preemptively post a status page update for known upstream provider incidents (Anthropic, Clerk, Stripe, major providers) so tenants self-serve the answer before paging us.

### 7.3 Load tests as incident simulations

Planned: quarterly load test where we simulate:
- 10x normal webhook rate
- Database failover under load
- Provider API failure

These surface incidents that might otherwise only appear during real customer load.

---

## 8. Never do during a platform-service incident

- Restart the whole platform at once (kill everything and pray) — amplifies damage; targeted restarts only
- Turn off monitoring to "reduce noise" — makes the next incident invisible
- Deploy a fix without testing locally first (emergency deploys still go through deploy runbook)
- Let a single engineer fight a SEV-1 for >2 hours alone — page someone else
- Skip postmortem because "we were busy"

---

## 9. Related

- `incident-response/incident-response-runbook.md` — the flow for every incident
- `runbooks/postgres-incidents.md` — DB-specific runbook
- `runbooks/tenant-incidents.md` — tenant-level runbook
- `runbooks/deploy-and-rollback.md` — deploy failure response
- Phase 3 service specs (observability, escalation-notifier, secrets-vault, provisioning-system)
- Phase 4 dashboard architecture spec
