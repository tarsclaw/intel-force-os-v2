# Observability Stack Specification

**The shape of logs, metrics, traces, and alerts across the IntelForce AI OS platform.**

> **Audience:** the engineer implementing CC6 (observability stack) and the ops engineer designing alert thresholds.
>
> **Status:** v1.0. Targets self-hosted Loki + Grafana + Prometheus + Vector on the platform's Kubernetes cluster.
>
> **Non-negotiable principles:**
> - Every log line and every metric is tenant-tagged
> - Secrets never appear in logs (see §3)
> - Alerts are actionable — no paging on things the on-call can't fix at 3am
> - Dashboard observability is separate from client-facing analytics (clients see Reporting Engine output, not Grafana)

---

## 1. The three pillars

| Pillar | Tool | What it stores |
|---|---|---|
| Logs | Loki + Vector | Structured JSONL events from every service + agent invocation |
| Metrics | Prometheus | Time-series counts, latencies, rates |
| Traces | Tempo (optional v1.1) | Per-request spans across services — punted to later |

All three front-end through Grafana. One Grafana instance. One set of dashboards.

Tempo/tracing is deliberately punted — at our volume and architecture (discrete Claude Code invocations, not request-heavy microservices), traces add operational cost without clear value. Revisit at ~100 tenants.

---

## 2. Log architecture

### 2.1 Producers

Every service + tenant container produces structured JSONL logs:

- **Webhook receiver** → stdout (captured by Kubernetes)
- **Provisioning System** → stdout
- **Secrets Vault** → stdout
- **Dashboard backend** → stdout
- **Tenant containers** → `/tenant/logs/*.jsonl` files AND stdout
- **Agent hooks (`validate.sh`, `context.sh`)** → `/tenant/logs/{hook}-{YYYYMMDD}.jsonl` via `hh_log()` helper

### 2.2 Shipping via Vector

Vector runs as a DaemonSet on every Kubernetes node. Configuration:

```toml
# Vector config (TOML)

[sources.k8s_logs]
type = "kubernetes_logs"

[sources.tenant_log_files]
type = "file"
include = ["/mnt/tenants/*/logs/*.jsonl"]
read_from = "beginning"

[transforms.parse_json]
type = "remap"
inputs = ["k8s_logs", "tenant_log_files"]
source = '''
  parsed, err = parse_json(.message)
  if err == null {
    . = merge(., parsed)
  }
  .tenant_id = .tenant_id ?? parse_regex(.file, r'tenants/(?P<tid>[^/]+)/').tid
  .env = "production"
'''

[transforms.redact_secrets]
type = "remap"
inputs = ["parse_json"]
source = '''
  # Strip any fields that look like they might contain secrets
  del(.authorization)
  del(.token)
  del(.api_key)
  del(.bearer)
  del(.password)
  del(.secret)
  # Redact any string matching common secret patterns
  .message = replace(.message, r'sk-[A-Za-z0-9_-]{20,}', "[REDACTED-SECRET]")
  .message = replace(.message, r'xoxb-[A-Za-z0-9-]+', "[REDACTED-SLACK]")
  .message = replace(.message, r'ghp_[A-Za-z0-9]{36}', "[REDACTED-GITHUB]")
'''

[sinks.loki]
type = "loki"
inputs = ["redact_secrets"]
endpoint = "http://loki.observability.svc:3100"
labels.tenant_id = "{{ tenant_id }}"
labels.service = "{{ service }}"
labels.env = "{{ env }}"
labels.level = "{{ level }}"
```

### 2.3 Loki storage

- **Retention:** 30 days hot (in-cluster), 1 year cold (S3 Glacier)
- **Partitioning:** by tenant_id label + day
- **Query performance:** LogQL with tenant_id label pre-filters most queries
- **Costs:** ~£50/month for MVP (low log volume), scales linearly with tenants

### 2.4 Log structure (JSONL schema)

Every log line MUST conform to this shape:

```json
{
  "ts": "2026-04-22T15:47:12.123Z",
  "level": "info|warn|error|debug",
  "service": "webhook-receiver|provisioning-system|tenant-supervisor|agent|validate-hook|...",
  "tenant_id": "tnt_01JKDY8X5RQ4P2N6",
  "session_id": "sess_xxx",
  "invocation_id": 12345,
  "event": "short.snake_case.name",
  "message": "Human-readable description",
  "metadata": { /* arbitrary JSON — event-specific */ }
}
```

Missing fields (e.g. a webhook receiver log has no `session_id`) → omit the field, don't send `null`.

---

## 3. Secret redaction — two layers

**Layer 1 — at source.** Services use a redacting logger. The logger rejects any object containing keys named `password`, `token`, `api_key`, `secret`, `authorization`, `bearer`. Attempts to log these are replaced with `[REDACTED]` before the line ever hits stdout.

**Layer 2 — in Vector.** The `redact_secrets` transform above strips anything the source logger missed, using regex on known secret patterns.

Both layers are imperfect. The real defence is code review + no `console.log(entire_request_object)` patterns.

---

## 4. Metrics architecture

### 4.1 Producers

Every service exposes `/metrics` in Prometheus format. Scrape interval: 30s.

### 4.2 Core metrics

**Per-service (webhook receiver, provisioning, secrets vault, dashboard backend):**
```
{service}_requests_total{tenant_id, endpoint, status}
{service}_request_duration_seconds{tenant_id, endpoint, status}
{service}_errors_total{tenant_id, error_type}
```

**Tenant supervisor:**
```
supervisor_invocations_total{tenant_id, agent, status}
supervisor_invocation_duration_seconds{tenant_id, agent, status}
supervisor_queue_depth{tenant_id}
supervisor_concurrent_sessions{tenant_id}
```

**Per-agent (emitted from the supervisor based on invocation outcomes):**
```
agent_runs_total{tenant_id, agent, status}
agent_cost_gbp_total{tenant_id, agent, cost_type}
agent_escalations_total{tenant_id, agent, code}
agent_quality_gate_failures_total{tenant_id, agent, gate}
```

**Infrastructure:**
```
postgres_connection_pool_used{pool}
postgres_query_duration_seconds{query_type}
pgvector_retrieval_latency_seconds{tenant_id}
kms_decrypt_calls_total{tenant_id}
kms_decrypt_errors_total{tenant_id, reason}
```

### 4.3 Retention

Prometheus local retention: 15 days. Long-term storage: Thanos or Mimir — deferred to v1.1. For MVP, 15 days of metrics is enough; we've got Loki for longer-window log-based analysis.

### 4.4 Cardinality budget

High-cardinality labels kill Prometheus performance. Our hard rules:
- `tenant_id` is permitted (bounded: one per customer)
- `agent` is permitted (bounded: 10 values)
- User IDs, session IDs, invocation IDs are NEVER labels
- Error messages as labels → use `error_type` (a short classified string) not `error_message` (free text)

---

## 5. Alerts

### 5.1 Alert philosophy

Every alert must:
1. Indicate something the on-call can fix in the next 15 minutes, OR
2. Indicate something a client will notice in the next 60 minutes, OR
3. Be automatically silenced when the condition clears

Alerts that don't meet one of these three are not alerts — they're "interesting things to look at in office hours" and go to an Ops digest Slack channel, not PagerDuty.

### 5.2 Alert catalogue

| Alert | Severity | Condition | Action |
|---|---|---|---|
| Webhook receiver down | CRIT (page) | `up{service="webhook-receiver"} == 0` for 2min | On-call investigates |
| Webhook dispatch latency high | WARN (Slack) | p95 > 1s for 5min | Ops digest |
| Tenant supervisor unreachable | CRIT (page) | `supervisor_health == 0` for 5min | On-call investigates that tenant's container |
| Agent failure rate spike | WARN (Slack) | `rate(agent_runs{status="failed"}[5m]) > 3x baseline` | Ops digest |
| Tenant cost budget exceeded | WARN (Slack) | `(month_spend / cost_budget_gbp) > 1.0` for 10min | Slack to tenant's channel + ops digest |
| Escalation surge | WARN (Slack) | More than 10 escalations for one tenant in 1 hour | Slack to ops; probably a broken config |
| Postgres connection pool saturated | CRIT (page) | `pgbouncer_connections_used > 0.9 * max` for 5min | On-call |
| Postgres replica lag | WARN (Slack) | Replication lag > 60s for 5min | Ops digest |
| KMS decrypt failures | CRIT (page) | `rate(kms_decrypt_errors_total[5m]) > 1` | On-call; likely auth issue |
| Disk space | WARN (Slack) | Any volume > 85% | Ops digest |
| Disk space | CRIT (page) | Any volume > 95% | On-call |
| Certificate expiring | WARN (Slack) | Any TLS cert expires in < 7 days | Ops digest (auto-renewal should handle) |
| Secrets expiring | WARN (Slack) | Any tenant secret expires in < 7 days and rotation failed | Ops digest |
| Loki ingestion failing | WARN (Slack) | Vector reports dropped events | Ops digest |
| Prometheus scrape failures | WARN (Slack) | Any target down > 10min | Ops digest |

### 5.3 Alert routing

- PagerDuty for CRIT alerts → primary on-call rotation
- Slack `#intelforce-ops` for WARN alerts → async
- Slack `#intelforce-digest` for INFO-level summaries (daily)
- Each tenant optionally gets their own Slack channel for tenant-specific alerts (cost budget, escalation surge)

### 5.4 Runbook links

Every alert links to a runbook snippet. The snippet covers:
1. What this alert means
2. What the impact is
3. First 3 diagnostic queries (LogQL or PromQL)
4. Common causes + fixes
5. Escalation path if the fix doesn't work in 30 min

Runbooks live in `dr/runbooks/` (populated progressively as alerts fire in production — don't pre-write every runbook).

---

## 6. Dashboards (Grafana)

### 6.1 Platform overview

One-screen summary across all tenants:
- Total active tenants, new this week
- Aggregate invocations/day (7-day trend)
- Aggregate cost/day (7-day trend) + budget utilization histogram
- Open escalations count by agent
- Top 5 most active tenants by invocations

### 6.2 Per-tenant drilldown

For any selected tenant:
- Invocation timeline (agent-by-agent, last 7 days)
- Cost breakdown by agent and by provider (Anthropic / Cohere / data providers)
- Escalation feed
- Quality gate failure rate by agent
- Integration health (OAuth tokens, API reachability)

### 6.3 Per-agent drilldown

For any selected agent (platform-wide):
- Runs per day
- Success rate (successful / total)
- p50/p95/p99 duration
- Cost per run (distribution)
- Top escalation codes

### 6.4 Infrastructure

Standard Postgres, Redis, Kubernetes node dashboards.

### 6.5 What NOT to put in Grafana

- Client-facing metrics — those go in Reporting Engine monthly reports, not Grafana
- Individual user activity — for audit, query `ops.audit_log` directly
- Financial / billing numbers — Stripe dashboard is source of truth; mirror only to detect anomalies

---

## 7. Distributed tracing — deferred

Tempo/OpenTelemetry is a natural next step when:
- We have multi-hop request patterns that are hard to debug from logs alone
- We have > 10 internal services (currently 4: receiver, provisioning, secrets, dashboard)
- We have paying enterprise clients asking for specific SLAs

None of these are true yet. Add when they are.

When added, the pattern will be:
- OpenTelemetry SDK in Node services
- Trace IDs propagated via HTTP headers
- Trace context included in every log line (`trace_id`, `span_id` fields in the JSONL schema)

---

## 8. What the tenant sees

Tenants do NOT get Grafana access. Instead:

- **Dashboard's "Activity log" view** — a filtered, pretty version of their own tenant's invocations + escalations
- **Dashboard's "Cost" view** — month-to-date spend, budget status, per-agent breakdown
- **Monthly report from Reporting Engine** — narrative synthesis, not raw metrics
- **Email alerts on escalations** — Slack or email, per tenant preference

This separation matters. Giving tenants raw Grafana means they call support about metrics that make sense to operators but not to them ("what does p95 mean?"). The client-facing surface is curated; the ops-facing surface is raw.

---

## 9. Cost

| Component | Monthly estimate (MVP) | Monthly estimate (50 tenants) |
|---|---|---|
| Loki + Vector + 50GB object storage | £30 | £100 |
| Prometheus | £20 | £40 |
| Grafana (self-hosted OSS) | £0 | £0 |
| S3 for long-term log retention | £10 | £50 |
| PagerDuty (3 seats) | £25 | £50 |
| **Total observability stack** | **£85** | **£240** |

Cheap relative to the LLM and integration costs. Worth every penny when debugging a 3am incident.

---

## 10. Implementation checklist (for CC6)

- [ ] Deploy Loki + Grafana + Prometheus + Vector to the observability namespace
- [ ] Configure Vector DaemonSet with the sources + transforms + sinks above
- [ ] Deploy PagerDuty integration
- [ ] Create Grafana dashboards (platform overview, per-tenant, per-agent, infra)
- [ ] Configure Prometheus alert rules per §5.2
- [ ] Wire alert routing (CRIT → PagerDuty; WARN → Slack)
- [ ] Add redacting logger to every Node service
- [ ] Verify secret redaction with deliberate test (log a fake API key; confirm redaction)
- [ ] Runbook scaffolding in `dr/runbooks/`
- [ ] Dashboard backend emits per-tenant activity in the right shape for client-facing views
- [ ] Chaos test: kill Loki; verify Vector buffers and recovers; no log loss

---

## 11. Post-launch observability improvements (Phase 7)

- Trace propagation end-to-end (OpenTelemetry)
- SLO tracking per service (error budgets, burn rate alerts)
- Proactive anomaly detection (e.g. "this tenant's costs jumped 3x this week — surface for human review")
- Client-facing status page (statuspage.io or similar) showing platform health per integration
