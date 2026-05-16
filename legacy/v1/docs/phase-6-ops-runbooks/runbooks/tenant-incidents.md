# Tenant Incident Runbook

**Response procedures for single-tenant or small-set-of-tenants incidents. Cost runaways, container stalls, integration failures, agent misbehaviour, rogue workflows.**

> **Audience:** on-call operator when a specific customer's platform is acting up (rather than the platform itself).
>
> **Status:** v1.0. Tenant-scope incidents are the most common incident type in practice — usually SEV-3 — but some escalate fast and have disproportionate customer-relationship impact.

---

## 1. Common shape

Tenant incidents typically:
- Affect one or a handful of tenants, not all
- Start as a SEV-3 (low severity)
- Have a high-profile customer dimension — even a SEV-3 for Rigby Group has commercial stakes
- Require more finesse than platform incidents — the tenant is a real person with a business, not an abstract metric

### 1.1 Signals that it's a tenant incident, not a platform one

- Metric anomaly scoped to `tenant_id=X`
- Customer reports something broken but platform status is green
- Escalation Notifier shows escalation storm for one tenant
- One tenant's cost spike while others are flat

If multi-tenant: it's a platform incident — route to `platform-service-incidents.md`.

### 1.2 Customer comms escalate faster than severity

Even a SEV-3 that affects a major customer warrants:
- Direct message from the account owner (Maddox or Jack) within 30 min
- Proactive "we're on it" regardless of technical state
- No waiting for the customer to notice

This is commercial, not technical. The technical flow below coexists with the commercial flow.

---

## 2. Incident: Tenant container stalled / crashed

The tenant container runs the agent supervisor. When it dies, agents for that tenant stop running.

### 2.1 Symptoms

- `tenant_container_up{tenant_id="tnt_xxx"} == 0`
- No recent invocations for that tenant despite webhooks arriving
- Customer reports: "nothing is happening"

### 2.2 Severity

- Single tenant, recent outage (<1hr): SEV-3
- High-profile tenant or sustained outage: SEV-2

### 2.3 Diagnosis

```bash
# Check container status (assuming systemd unit-per-tenant pattern)
ssh tenant-host-01 'sudo systemctl status tenant@tnt_xxx'

# If crashed, check logs for crash cause
ssh tenant-host-01 'sudo journalctl -u tenant@tnt_xxx -n 500'

# Check resource pressure
ssh tenant-host-01 'docker stats --no-stream tnt_xxx'
```

### 2.4 Common causes

| Cause | Evidence | Fix |
|---|---|---|
| Container crashed on OOM | "Killed" in logs; exit code 137 | Increase memory limit; restart |
| Claude Code session died | Supervisor logs show session error | Restart supervisor; re-init session |
| Volume mount issue | "Cannot access /mnt/tenants/xxx" | Check NFS / volume mounts on host |
| Supervisor config invalid | Parse error on startup | Check `/mnt/tenants/xxx/config.yaml`; fix |
| Anthropic API auth failed | Logs: "invalid API key" | Secret rotation went wrong; investigate |

### 2.5 Fix

```bash
# Simple restart (most cases)
ssh tenant-host-01 'sudo systemctl restart tenant@tnt_xxx'

# Verify
ssh tenant-host-01 'sudo systemctl status tenant@tnt_xxx'

# Test: invoke a light agent via dashboard; watch for successful run
```

If restart loop (systemd restart-then-crash cycle):
- Check resource limits
- Check for corrupted state in `/mnt/tenants/xxx/.claude/` — may need to archive that dir and let supervisor regenerate

### 2.6 Customer comms

Even for SEV-3:
- Proactive message: "Hi [name], we noticed your agent supervisor stopped at [time]; restarting now. I'll confirm when it's back."
- On resolution: "All back up. [reason in plain language]. Postmortem details to follow."

---

## 3. Incident: Cost runaway

A single tenant's spend is spiking fast. Could be a looping agent, a misconfigured schedule, or genuine high-volume usage.

### 3.1 Symptoms

- Prometheus: `tenant_cost_gbp{tenant_id="X"}` rate > 10x normal
- Slack alert: "Cost budget 50% in first 3 days of month"
- Or: PagerDuty CRIT: "Tenant X hit 100% of budget"

### 3.2 Severity

- Within budget, unusual pattern: SEV-3
- Exceeding budget but tenant has `hard_stop`: SEV-3 (system contained it)
- Exceeding budget with `soft_alert`, costs climbing: SEV-2 (money being spent beyond expectation)
- Runaway 10x budget (e.g., £5,000 in an hour for a £550/mo tenant): SEV-1 financial emergency

### 3.3 Diagnosis

```bash
# Who's spending?
psql -h primary-db-01 -c "
SELECT agent, count(*) as invocations, sum(cost_gbp) as total_gbp
FROM tenant_xxx.invocations
WHERE started_at > now() - interval '1 hour'
GROUP BY agent ORDER BY total_gbp DESC;"

# Are invocations looping?
psql -h primary-db-01 -c "
SELECT correlation_id, count(*) as chain_length
FROM tenant_xxx.invocations
WHERE started_at > now() - interval '1 hour'
GROUP BY correlation_id
HAVING count(*) > 5
ORDER BY chain_length DESC;"
```

### 3.4 Containment (immediate)

**If runaway:**

```bash
# Dashboard: /admin/tenants/tnt_xxx → Suspend
# Or tRPC: tenants.suspend({ tenantId: 'tnt_xxx', reason: 'cost runaway' })
```

Suspend does:
- Disables webhook routing for that tenant
- Stops the supervisor
- In-flight invocations complete (up to 2 minutes) but no new ones start
- Customer sees a "suspended" banner on the dashboard

Alternative if less severe:
- Set the tenant's cost budget `mode=hard_stop` temporarily via Settings
- Agents stop when budget hits 100%; no suspension needed

### 3.5 Investigation

Look for:
- **Looping agents:** one invocation chains into another chains into another. Usually caused by an agent writing to a directory that triggers the `Librarian`, which triggers another agent that writes again. Fix: escalation loop detection in agents.
- **Misconfigured schedule:** agent scheduled to run every minute instead of every hour. Fix: update schedule config.
- **Runaway prompt:** agent is in a tool-use loop (call tool, call tool, call tool) without producing a final output. Fix: agent's system prompt needs better guardrails; Anthropic's new `stop_when` patterns help.
- **Genuine usage spike:** tenant suddenly has 100 Fathom calls where they usually have 5. Not a bug; commercial conversation about budget increase.

### 3.6 Remediation

After fix:
1. Resume the tenant (unsuspend)
2. Credit costs back if the runaway was our bug (platform bug, not tenant config): one-off credit to their Stripe account
3. Do NOT credit back if the runaway was tenant-side (they misconfigured a schedule): platform operated correctly; charge stands but have the conversation

### 3.7 Customer comms

- SEV-3 runaway contained (hard_stop worked): "Your budget hit its limit; we paused your agents. Here's why and what to do." Include a link to the Settings → Billing page.
- SEV-2 cost investigation: "We noticed unusual spend on your account starting [time]. We've paused agents to investigate. No charges yet above your budget. We'll update within an hour."
- SEV-1 financial emergency: urgent call. Maddox or Jack personally. Credit back anything above the agreed budget immediately if it was platform fault.

---

## 4. Incident: Agent misbehaviour

A specific agent is producing bad outputs, repeating itself, or generating content that shouldn't be published.

### 4.1 Symptoms

- Customer reports: "The proposals it's drafting don't make sense"
- Escalation storm: same escalation code firing repeatedly for one tenant / agent
- Content Creator outputs contain banned phrases despite filtering
- SOPs being written that don't match tenant's actual business

### 4.2 Severity

- Isolated bad output: SEV-4; investigate during business hours
- Repeated bad outputs: SEV-3
- Customer-visible harm (e.g., a banned phrase got included in a draft the customer almost sent): SEV-2

### 4.3 First step — stop the agent

Rather than debug while the agent is producing more bad output:

```bash
# Via dashboard Settings → Agents → toggle off the offending agent
# Or tRPC: agents.disable({ tenantId: 'tnt_xxx', agent: 'proposal-builder' })
```

Then investigate calmly.

### 4.4 Investigation

Pull the invocation logs + inputs + outputs for several recent runs:

```bash
# Last 10 invocations of the agent
psql -h primary-db-01 -c "
SELECT id, started_at, escalation_code, cost_gbp, output_path
FROM tenant_xxx.invocations
WHERE agent = 'proposal-builder'
ORDER BY started_at DESC
LIMIT 10;"

# For each, fetch the full log from Loki
# + the input context and output file from the tenant's vault
```

Common misbehaviour patterns:
- **Tenant config rot:** brand/voice-profile.md is missing or contaminated
- **Retrieval returning wrong context:** Librarian indexed a wrong file, now every invocation gets bad grounding
- **Agent prompt regression:** recent update to the agent's system prompt introduced a bug
- **Model drift:** Claude has updated; the agent's prompt no longer works as expected

### 4.5 Fix

- Config rot: regenerate voice profile from fresh samples
- Retrieval: force re-index by running `librarian` manually; check embeddings
- Prompt bug: revert to previous agent version; schedule prompt fix
- Model drift: update prompt to account for new model behaviour; test in staging first

### 4.6 Containment during fix

While the agent is disabled, does anything rely on it?
- Proposal Builder disabled → tenant won't get proposals from Fathom calls in the interim. Manual workaround: operator drafts proposals themselves using the retrieval context, deliver as usual until fixed.
- Content Creator disabled → no content being drafted. Depending on tenant contract, may warrant service credit.

Always tell the customer explicitly: "Your proposal-builder is paused. We're running the proposals manually for you while we fix this."

---

## 5. Incident: Integration provider outage

Tenant's integration (Fathom, HubSpot, Gmail) is down. Agents that depend on it fail.

### 5.1 Symptoms

- Multiple tenants' agents failing with similar `UPSTREAM_API_ERROR` escalations
- Specific provider API returning 500s
- Provider's own status page reporting issues

### 5.2 Severity

- Small-scope outage (one tenant affected): SEV-3
- Platform-wide (many tenants' same integration failing): SEV-2 (it's a tenant-facing platform issue even if the underlying cause is external)

### 5.3 Investigation

```bash
# Group escalations by code + recent time
psql -h primary-db-01 -c "
SELECT agent, code, count(*) as occurrences
FROM control.escalations
WHERE raised_at > now() - interval '30 minutes'
  AND code IN ('UPSTREAM_API_ERROR', 'INTEGRATION_TIMEOUT')
GROUP BY agent, code
ORDER BY occurrences DESC;"

# Check the provider's status page (manual)
```

### 5.4 Response

**If provider is genuinely down:**
- Don't debug on our side; it's their issue
- Post internal-only Slack: "Fathom is down; escalations expected"
- If widespread, update our status page: "Degraded performance due to upstream provider"
- Customer emails only if the outage affects them directly and lasts >1 hour

**If only we see issues (provider status page green):**
- Likely our side — maybe our API key is rate-limited, or our HMAC verify is broken
- Debug accordingly

### 5.5 Backlog handling

When the provider recovers:
- Missed events (webhooks during outage): ask provider to replay if they support it (Fathom and HubSpot do; Gmail doesn't)
- Agents that failed during outage: re-run them manually via dashboard, or let the tenant's daily digest catch up

---

## 6. Incident: OAuth token expired / revoked

Tenant granted us OAuth access, then their admin revoked it (intentional or accidental) — or the refresh token expired and we didn't catch it.

### 6.1 Symptoms

- Specific tenant's integration failing with `401 Unauthorized`
- Secrets Vault logs: "refresh token no longer valid"
- Dashboard Settings → Integration shows "status: reauth needed"

### 6.2 Severity

- SEV-3. Tenant-contained.

### 6.3 Fix

Via dashboard:
1. Operator or tenant admin clicks "Reconnect" on the Settings → Integrations page
2. Runs the OAuth flow again
3. New tokens stored in Secrets Vault
4. Agents resume

Notify the tenant:
- "Your [provider] integration needs re-authorisation. Click here to reconnect: [link]. Your agents will resume once connected."

This is routine operations, not really an incident. Tracked at SEV-3 only to ensure customer comms happens.

---

## 7. Incident: Tenant's webhook URL misconfigured

Tenant's provider (e.g., HubSpot) is configured with the wrong webhook URL, so we're not receiving their events.

### 7.1 Symptoms

- Customer: "Calls are being logged in Fathom but nothing triggers on your side"
- No webhook requests for that tenant in webhook-receiver logs

### 7.2 Severity

- SEV-4 (no platform issue; tenant config issue)

### 7.3 Fix

- Confirm the correct webhook URL per tenant: lives in their `integrations` table
- Walk tenant through provider-side config:
  - Fathom: Settings → Integrations → Custom Webhook URL
  - HubSpot: Settings → Integrations → Webhooks → Edit subscription
  - etc. (per-provider config)
- Verify: test webhook from provider's admin UI; confirm it lands

Document the fix in a support ticket; not a real incident.

---

## 8. Incident: Suspicious tenant activity

A tenant's usage pattern looks like abuse: attempting to extract training data, running the platform against terms of service, or attempting to access another tenant's data.

### 8.1 Symptoms

- Unusual pattern in audit log (many failed RLS attempts, repeated calls to unusual procedures)
- Agent outputs suggesting the tenant is trying to exfiltrate model weights or prompts
- Vault content suddenly includes content clearly not authored by the tenant (scraped data?)

### 8.2 Severity

- SEV-2 while investigating (customer-affecting action coming)
- SEV-1 if confirmed malicious (invoke breach runbook — this is adjacent)

### 8.3 First actions

1. Suspend the tenant (dashboard → Suspend)
2. Freeze their Clerk sessions
3. Preserve evidence: snapshot their vault, snapshot audit log for their user_ids, snapshot recent invocations
4. Legal / commercial review: is this a misunderstanding or a deliberate ToS violation?

### 8.4 Resolution

- Misunderstanding: unsuspend with a conversation about appropriate use
- Deliberate ToS violation: invoke AUP enforcement procedure (see Phase 5 AUP spec §6)
- Potential criminal activity (e.g., attempted extraction of other tenants' data): legal counsel involved immediately; preserve full evidence; law enforcement contact if appropriate

### 8.5 Legal / commercial coordination

This is one of the few tenant-incident types where Maddox or Jack (commercial lead) AND legal counsel need to be pulled in from the start.

---

## 9. Pattern: Escalation storm

Not a specific incident type, but a common pattern: escalation notifications flooding one tenant's Slack.

### 9.1 Symptoms

- Slack rate-limit hits on the tenant's channel
- Customer: "my Slack is being spammed"
- Escalation Notifier logs: 50+ escalations for one tenant in 10 minutes

### 9.2 Fix immediate

Via dashboard (or Temporal if needed), temporarily disable Slack notifications for that tenant:
- Settings → Notifications → Mute all (with a confirmation dialog)

### 9.3 Investigate

Escalation storms come from:
- Agent in a loop (each run fails and escalates)
- Integration provider returning errors (each invocation escalates with UPSTREAM_API_ERROR)
- Retrieval repeatedly missing, so every agent escalates with RETRIEVAL_EMPTY

Fix the underlying cause. Then re-enable notifications.

### 9.4 Post-storm

- Send tenant a digest email summarising the escalations (so they don't miss anything)
- Resolve the escalations in bulk once addressed

---

## 10. Pattern: "My tenant is slow"

Vague but common. Customer reports "the platform feels slow" for their tenant specifically.

### 10.1 Investigate

```bash
# Recent invocation times for that tenant
psql -c "
SELECT agent, avg(duration_ms), p95(duration_ms)
FROM tenant_xxx.invocations
WHERE started_at > now() - interval '24 hours'
GROUP BY agent;"

# Dashboard page load times for that tenant (Loki query)
```

### 10.2 Common causes

- Tenant's vault has grown large → slower Librarian sweeps, slower retrieval
- Tenant's integration(s) are slow on provider side → agents wait longer per invocation
- Retrieval returning large chunks (top_k too high)
- Platform is genuinely slow for everyone (not tenant-specific; investigate platform-wide)

### 10.3 Fixes

Per cause:
- Archive older vault content
- Investigate provider latency
- Tune retrieval parameters
- Platform issue → platform-service-incidents runbook

---

## 11. Commercial layer — who owns the customer relationship during incidents

For tenant incidents, there's always a commercial dimension. Roles:

| Role | Responsibility |
|---|---|
| IC / on-call | Technical diagnosis and fix |
| Account owner (Maddox / Jack) | Customer communication, commercial implications |
| Product owner (Maddox) | Decisions about refunds, credits, suspensions |

For high-profile customers (Rigby Group, top 5 revenue), account owner is automatically looped in even for SEV-3.

---

## 12. Never do during a tenant incident

- Discuss the incident with the wrong customer (tenant isolation in conversations too)
- Decide on service credits without commercial approval
- Assume the tenant's config is correct — check it; many "incidents" are misconfigurations
- Restart their container repeatedly without investigating why it's crashing
- Blame the tenant externally even when it IS their fault — professional comms always

---

## 13. Related

- `incident-response/incident-response-runbook.md` — general flow
- `incident-response/severity-classification-and-comms.md` — severity rules
- `runbooks/platform-service-incidents.md` — when to suspect platform-wide
- `runbooks/postgres-incidents.md` — DB-scoped issues
- `routines/cost-governance-runbook.md` — proactive cost monitoring (prevents many cost-runaway incidents)
- `phase-5-business-legal/legal/acceptable-use-policy.md` — enforcement framework for suspicious-activity cases
- `phase-5-business-legal/legal/sla-spec.md` — SLA credit rules
