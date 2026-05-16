# Provisioning System Specification

**The orchestrator that takes a tenant from "Wizard just finished" to "container running, agents active, webhooks receiving, dashboard usable."**

> **Audience:** the engineer implementing CC4 (Provisioning System).
>
> **Status:** v1.0. Targets the Hetzner UK + AWS London deployment.
>
> **Language:** Node.js 20 + TypeScript + Temporal (for the orchestration workflow).

---

## 1. Why Temporal (and not a custom state machine)

Tenant provisioning is a long-running workflow with:
- External calls that can fail independently (GitHub, Postgres, KMS, Kubernetes, MCP provider OAuth)
- Human approval steps in some flows (enterprise tier)
- Retry semantics that must be right per step (some idempotent, some not)
- A need for observable state across minutes-to-hours

Writing this as a custom state machine with retries, timeouts, and crash recovery is a multi-week engineering project that ends up being a lower-quality version of Temporal. Temporal gives us all of it for free.

Trade-off: one more operational dependency. Acceptable — Temporal cloud is cheap at our volumes and the self-hosted option is a single Docker Compose.

---

## 2. What the Provisioning System does

Three top-level flows:

1. **`TenantOnboard`** — brand new tenant from Wizard output → fully active. Runs once per tenant, duration typically 3–10 minutes.
2. **`TenantReprovision`** — existing tenant picks up a new configuration version (new integration added, plan upgraded, etc.). Runs on demand, seconds to minutes.
3. **`TenantDecommission`** — archive a tenant (revoke access, preserve vault, drop from DB). Runs on request, minutes.

Each flow is a Temporal workflow with activities. Every activity is idempotent where possible, and has explicit retry and timeout policies.

---

## 3. `TenantOnboard` workflow

### 3.1 Input

The Wizard's output — a full `tenant-config.json` plus provisioning metadata:

```json
{
  "wizard_run_id": "wz_01JKDY8X5RQ4P2N6",
  "submitted_by": "operator@acme-agency.co.uk",
  "submitted_at": "2026-04-22T15:30:00Z",
  "tenant_config": { /* full config matching any agent's schema */ },
  "plan": "growth",
  "enabled_agents": ["proposal-builder","lead-hunter","follow-up-pilot","content-creator","repurposer","caption-writer","client-onboarder","reporting-engine","sop-writer","librarian"],
  "parent_tenant_id": null,
  "requires_manual_approval": false
}
```

### 3.2 Workflow steps

```
Step 1:  generate_tenant_id          — deterministic ULID, insert placeholder row
Step 2:  create_postgres_tenant_role — CREATE ROLE tenant_<id>; GRANT schema
Step 3:  create_pgvector_schema      — CREATE SCHEMA tenant_<id>; create chunks table + indexes
Step 4:  seed_secrets_vault          — wrap Anthropic key, generate webhook secrets
Step 5:  create_github_vault_repo    — POST to GitHub API, apply template, push seed
Step 6:  register_webhook_endpoints  — per integration, register URL with provider
Step 7:  oauth_handoff               — if OAuth integrations needed, handoff to dashboard for user consent
Step 8:  wait_for_oauth_completion   — (long-poll activity; max 7 days before timeout)
Step 9:  run_preflight_checks        — for each enabled agent, run its tools.yaml preflight
Step 10: provision_kubernetes_workload— create tenant pod/container, mount volumes
Step 11: verify_supervisor_healthy   — poll until /health returns 200
Step 12: verify_vault_synced         — check git-synced vault is present and readable
Step 13: activate_tenant             — UPDATE tenants SET status = 'active'
Step 14: send_welcome_email          — operator notified tenant is live
Step 15: emit_telemetry              — onboarding complete event
```

### 3.3 Per-activity contract

Every activity declares:
- Idempotency key (usually `tenant_id` + activity name)
- Max retry count
- Timeout
- Compensating action (what to do on workflow cancellation or fatal error)

Example — `create_github_vault_repo`:

```typescript
@Activity({
  idempotencyKey: (input) => `github-repo:${input.tenantId}`,
  retryPolicy: {
    initialInterval: '5s',
    maximumInterval: '60s',
    maximumAttempts: 5,
    nonRetryableErrorTypes: ['GitHubAuthError']
  },
  startToCloseTimeout: '60s'
})
async createGithubVaultRepo(input: { tenantId: string; clientSlug: string }): Promise<{ repoUrl: string }> {
  // 1. Check if repo already exists (idempotency)
  const existing = await github.getRepo(`intelforce-vaults/${input.clientSlug}`);
  if (existing) return { repoUrl: existing.html_url };

  // 2. Create repo
  const repo = await github.createRepo({
    org: 'intelforce-vaults',
    name: input.clientSlug,
    private: true,
    description: `Vault for ${input.clientSlug} — managed by IntelForce AI OS`
  });

  // 3. Seed with minimal-vault-structure
  await this.seedVaultFromTemplate(repo, input.tenantId);

  // 4. Create deploy key, store in secrets vault
  const deployKey = await crypto.generateSshKeyPair();
  await github.addDeployKey(repo.full_name, {
    title: `tnt-${input.tenantId}-readwrite`,
    key: deployKey.publicKey,
    read_only: false
  });
  await secrets.store(`secrets://${input.tenantId}/github/deploy_key`, deployKey.privateKey);

  return { repoUrl: repo.html_url };
}
```

Compensating action: `deleteGithubVaultRepo(tenantId)` — wipes the repo if a later workflow step fails and we abort.

### 3.4 Workflow diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                     TenantOnboard                                    │
│                                                                      │
│ generate_tenant_id ──▶ create_pg_role ──▶ create_pgvector_schema    │
│                                                    │                 │
│                                                    ▼                 │
│ seed_secrets_vault ◀── create_github_vault ──▶ register_webhooks    │
│       │                                                  │           │
│       └──────────────┬───────────────────────────────────┘           │
│                      ▼                                               │
│                oauth_handoff ──── (dashboard collects OAuth) ──┐    │
│                                                                │    │
│       ┌────────────────────────────────────────────────────────┘    │
│       ▼                                                              │
│ wait_for_oauth_completion (or timeout 7d)                           │
│       │                                                              │
│       ▼                                                              │
│ run_preflight_checks ──▶ provision_k8s_workload                     │
│       │                          │                                   │
│       │                          ▼                                   │
│       │                  verify_supervisor_healthy                   │
│       │                          │                                   │
│       │                          ▼                                   │
│       │                  verify_vault_synced                         │
│       │                          │                                   │
│       │                          ▼                                   │
│       └────────────────▶ activate_tenant                             │
│                                  │                                   │
│                                  ▼                                   │
│                          send_welcome_email                          │
│                                  │                                   │
│                                  ▼                                   │
│                          emit_telemetry                              │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### 3.5 Failure handling

Each activity failure is classified:

- **Transient (retriable)** — network blips, rate limits. Temporal retries with exponential backoff per the activity's policy.
- **Permanent (non-retriable)** — auth failures, invalid config, duplicate slug. Workflow fails. Compensating actions run in reverse order. Operator notified with specific error.
- **External waiting** — OAuth consent pending. Workflow suspends on a signal. Operator re-engages from dashboard.

On workflow failure:
- Tenant row stays with `status = 'provisioning'`
- `control.tenant_versions` records the failed config
- Operator sees the error on the dashboard's Onboarding view
- Operator can retry (new workflow invocation, same tenant_id) or abort (triggers `TenantDecommission` cleanup)

---

## 4. `TenantReprovision` workflow

Used when a tenant picks up a new configuration version. Common cases:
- Plan upgrade (Growth → Scale) enables new agents
- New integration added (e.g. tenant adds Notion)
- Vault sync target moved (rare)
- Platform image version upgrade

Simpler than onboarding because most of the setup already exists.

```
Step 1: load_existing_tenant       — read current state from control.tenants
Step 2: diff_configs               — compare old vs new tenant config
Step 3: plan_changes               — emit a list of required actions
Step 4: apply_changes              — execute each change idempotently
Step 5: restart_tenant_supervisor  — pick up new config via hot-reload, OR container restart if needed
Step 6: verify_post_reprovision    — run preflights for newly-enabled agents
Step 7: record_new_version         — insert into control.tenant_versions
```

Diff examples:
- New agent enabled → run its preflight, copy agent bundle into tenant container's `.claude/agents/`
- Integration OAuth token rotated → update `secrets_metadata`, notify supervisor
- Plan downgraded → disable agents not in new plan; keep their historical output untouched

Reprovisioning does NOT destroy data. Downgrades are soft — the agent files stay, they just stop being triggered by the supervisor.

---

## 5. `TenantDecommission` workflow

Used for:
- Cancelled subscriptions
- GDPR deletion requests (though GDPR deletion has a separate, more thorough flow; see §8)
- Test tenants being cleaned up

```
Step 1: suspend_tenant                    — UPDATE status = 'suspended'; immediate effect on webhook routing
Step 2: stop_tenant_container             — kubectl delete pod; data volume preserved
Step 3: revoke_github_deploy_key          — deploy key deleted from GitHub
Step 4: deregister_webhooks               — tell Fathom/HubSpot/etc. to stop sending to our endpoints
Step 5: revoke_oauth_tokens               — revoke via each provider's API
Step 6: export_final_vault_archive        — git bundle the repo, upload to long-term S3 storage
Step 7: delete_github_repo                — remove the GitHub vault (archive exported in step 6)
Step 8: mark_secrets_revoked              — secrets_metadata status → 'revoked' (actual deletion per §8)
Step 9: drop_pgvector_schema              — DROP SCHEMA tenant_<id> CASCADE
Step 10: archive_postgres_records         — move invocations/costs to a compressed archive table
Step 11: mark_archived                    — UPDATE status = 'archived', archived_at = now()
Step 12: notify_operator                  — confirmation email
```

Vault archive retention: 90 days at reduced-cost S3 tier, then deleted. This window lets a tenant change their mind about leaving without data loss.

---

## 6. OAuth handoff flow

Most integrations use OAuth, which requires user consent. We can't complete onboarding headlessly.

### 6.1 Handoff mechanism

1. `oauth_handoff` activity generates a unique `oauth_session_id` for each required integration
2. For each, writes a `pending_oauth_session` row in `control.integrations` with `status = 'pending_oauth'`
3. Workflow enters `wait_for_oauth_completion` — suspends on a Temporal signal
4. Dashboard's Onboarding view shows a grid of "Connect X" buttons per pending integration
5. Operator clicks "Connect Gmail" → redirected to Google's OAuth consent screen → redirected back to dashboard's callback URL
6. Dashboard callback handler:
   - Validates state + PKCE
   - Exchanges code for tokens
   - Stores tokens via `secrets.store()`
   - Updates `control.integrations` status → 'active'
   - Sends Temporal signal `oauth_completed:{integration}`
7. Once all required integrations have signalled completion, workflow resumes

### 6.2 Timeout and recovery

- Default timeout: 7 days from `oauth_handoff` start
- On timeout: workflow fails with `OAUTH_CONSENT_TIMEOUT`, operator can restart from dashboard
- If operator partially completes (3 of 5 integrations) then walks away, state is preserved — completing the remaining ones resumes the workflow

### 6.3 Why this pattern (not deeper automation)

Some teams try to automate OAuth consent with headless browser tricks or shared service accounts. Both break sooner or later:
- Headless consent automation breaks every time the provider tightens security
- Shared service accounts violate most providers' ToS and pool all tenants' data under one identity

The boring right answer is: make the human click the button. Our job is to make the dashboard UI make that button un-miss-able.

---

## 7. Idempotency and replayability

### 7.1 Replayability guarantee

Temporal's default: activity results are deterministic and workflow code is deterministic. This means workflows can be replayed from any point for debugging or recovery.

We honour this by:
- Never using `Date.now()` or `Math.random()` in workflow code (use Temporal's `currentTime()` and `randomUUID()`)
- Treating all activity results as the only source of new information
- Keeping business logic in activities, not in workflow orchestration

### 7.2 Idempotency keys

Every activity that makes an external call uses an idempotency key. Examples:
- GitHub repo creation: `github-repo-create:{tenant_id}` → if repo exists, return existing
- Stripe customer creation: `stripe-customer-create:{tenant_id}` → if exists, return existing
- Kubernetes pod creation: `k8s-pod-create:{tenant_id}` → if exists, return existing

For activities with no natural idempotency (e.g. sending a welcome email), we use a `one_time_action_log` table to record that the action was performed.

---

## 8. GDPR deletion request — separate flow

GDPR right-to-erasure requests go beyond tenant decommission:

1. Operator raises a GDPR deletion ticket via dashboard
2. Legal review (manual, 48h SLA) — confirms the request is valid and not overriding a legal hold
3. Run `TenantDecommission` first
4. Additionally, purge:
   - Temporal workflow history for this tenant
   - Loki log history for this tenant (Vector is configured to include tenant_id in every log line)
   - S3 vault archive (normally retained 90 days — GDPR request drops to immediate)
   - Stripe customer data (mark as deleted in Stripe, Stripe retains some for legal tax reasons)
   - Backup tapes (WAL archive retention drops to 7 days from that date)
5. Issue deletion certificate (PDF, signed with platform admin key)
6. Record in `ops.audit_log` with reason = `gdpr_deletion`

Full flow is documented separately in `dr/gdpr-deletion-runbook.md` (not shipped in this phase; Phase 6).

---

## 9. Observability

### 9.1 Per-workflow

Temporal UI shows every workflow's history. Operators can inspect:
- Which activity is currently running
- How many retries
- Input and output of each activity
- Full event timeline

### 9.2 Metrics

Prometheus metrics emitted by the Provisioning System:
- `provisioning_workflows_total{flow, status}`
- `provisioning_activity_duration_seconds{activity}`
- `provisioning_activity_retries_total{activity, reason}`
- `provisioning_oauth_pending_total{integration}`

### 9.3 Alerts

| Condition | Severity | Action |
|---|---|---|
| Any `TenantOnboard` in `pending_oauth` > 48h | WARN | Slack to #ops; operator to nudge tenant |
| Any `TenantOnboard` failed in last hour | WARN | Slack to #ops with workflow ID |
| Any `TenantDecommission` failed | CRIT | PagerDuty; manual cleanup required |
| `provisioning_activity_duration_seconds` p95 > 5min | WARN | Backend degraded, investigate |

---

## 10. Deployment

- **Service name:** `provisioning-system`
- **Replicas:** 2 (for HA)
- **Temporal namespace:** `intelforce-provisioning`
- **Database access:** `provisioning_system` role (BYPASSRLS — needs to write across tenants)
- **Secrets access:** read and write to the secrets vault
- **Network:** private only; accessed by the dashboard backend via gRPC

---

## 11. Test strategy

- **Unit tests:** every activity function tested with mocked external calls
- **Integration tests:** run `TenantOnboard` against staging with real GitHub, real Postgres, mock OAuth providers
- **End-to-end test:** once per week, spin up a full test tenant, run all 10 agents through fixture inputs, decommission at end. Budget: £2/week, 15min wall clock
- **Chaos test:** monthly, inject a 30% failure rate into random activities; verify workflows recover correctly (in staging only)

---

## 12. Implementation checklist (for CC4)

- [ ] Temporal server deployed (self-hosted Docker Compose for MVP, managed cloud if we outgrow)
- [ ] TypeScript workflow + activity scaffolding
- [ ] `TenantOnboard` workflow implementation
- [ ] `TenantReprovision` workflow implementation
- [ ] `TenantDecommission` workflow implementation
- [ ] Integration with Postgres via `pg` client
- [ ] Integration with KMS for secrets vault
- [ ] Integration with GitHub Enterprise API (or github.com API for free tier)
- [ ] Integration with Kubernetes API via `kubectl` or `@kubernetes/client-node`
- [ ] Integration with Stripe API for customer/subscription creation
- [ ] OAuth callback handler on dashboard backend (see Phase 4)
- [ ] Helm chart or Kubernetes manifest
- [ ] Runbook: how to manually intervene in a stuck workflow
- [ ] CI: lint, typecheck, unit tests, integration tests against staging

---

## 13. Known limitations (for v2)

- **Manual approval steps aren't UI-native yet.** For enterprise tenants with custom MSAs, we manually approve via dashboard — fine for our volumes. v2 could formalise this as a Temporal `awaitHumanApproval` pattern.
- **No per-tenant version pinning rollback.** If we upgrade a tenant to platform v1.3.0 and they want to stay on v1.2.0, we can pin them, but pinning happens out-of-band. v2 could bake pinning into the workflow.
- **No multi-region provisioning.** Single UK region. Adding US-East is a 2-month project including data residency decisions. Not on roadmap yet.
