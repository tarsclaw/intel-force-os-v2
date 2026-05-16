# Phase 3 — Platform Implementation

**The shared infrastructure every tenant runs against.** Postgres schema, provisioning orchestration, secrets management, observability, and the services that glue agent output to operator attention.

> **Status:** v1.0, shipped 22 April 2026.
>
> **Prerequisites:** Phase 1 POC validated (Proposal Builder works end-to-end on a real Fathom call). Phase 2 agent bundles specified. Without those, this platform has nothing to run.

---

## What's in this phase

| # | Spec | Component | Builds |
|---|---|---|---|
| 1 | `postgres/schema-spec.md` | Postgres schema (control + ops + per-tenant pgvector) | CC11 |
| 2 | `postgres/migrations/20260422_001_initial.sql` | Ready-to-apply migration SQL | CC12 |
| 3 | `provisioning/provisioning-system-spec.md` | Tenant onboarding / reprovision / decommission workflows | CC4 |
| 4 | `secrets/secrets-vault-spec.md` | KMS + vault service + rotation | CC5 |
| 5 | `observability/observability-spec.md` | Loki + Prometheus + Grafana + Vector + alerts | CC6 |
| 6 | `services/escalation-notifier-spec.md` | Sidecar watching `/outbox/escalations/` | CC7 |
| 7 | `services/vault-search-spec.md` | Retrieval CLI every `context.sh` depends on | CC9 (part) |
| 8 | `dr/backup-and-dr-runbook.md` | Backup strategy + disaster recovery procedures | Ops |

---

## How these fit together

```
                         ┌─────────────────────────────────────┐
                         │   Postgres (schema-spec)            │
                         │   • control.tenants                 │
                         │   • control.invocations             │
                         │   • control.costs                   │
                         │   • control.escalations             │
                         │   • tenant_{id}.chunks (pgvector)   │
                         └───┬─────────────┬───────────────────┘
                             │             │
           ┌─────────────────┘             │
           ▼                               ▼
┌─────────────────────────┐       ┌───────────────────────────┐
│  Provisioning System    │       │  vault-search CLI         │
│  (Temporal workflows)   │       │  • Called by context.sh   │
│  • TenantOnboard        │       │  • Queries pgvector       │
│  • TenantReprovision    │       │  • Writes retrieval log   │
│  • TenantDecommission   │       └──────┬────────────────────┘
└─────┬───────────────────┘              │
      │                                  │
      │ creates/maintains                │ reads from
      ▼                                  ▼
┌─────────────────────────┐       ┌───────────────────────────┐
│  Secrets Vault          │       │  Tenant container         │
│  (per-tenant KMS CMKs)  │       │  (runs agents)            │
│  • Rotation scheduler   │       │  /outbox/escalations/ ───┐│
│  • mTLS from consumers  │       │                          ││
└─────────────────────────┘       └──────────────────────────┼┘
                                                              │
                                   ┌──────────────────────────▼┐
                                   │  Escalation Notifier      │
                                   │  • fsnotify watcher       │
                                   │  • Slack + DB + SSE       │
                                   └───────────────────────────┘

                ┌─────────────────────────────────────────┐
                │  Observability stack                    │
                │  • Vector ships logs from everywhere    │
                │  • Prometheus scrapes /metrics          │
                │  • Grafana unified dashboards           │
                │  • PagerDuty for CRIT alerts            │
                └─────────────────────────────────────────┘

                ┌─────────────────────────────────────────┐
                │  Backup + DR                            │
                │  • pgBackRest continuous WAL            │
                │  • DynamoDB PITR                        │
                │  • Nightly vault clones to S3           │
                │  • Quarterly DR drills                  │
                └─────────────────────────────────────────┘
```

---

## Key design decisions locked in this phase

### 1. One Postgres cluster, pgvector in-cluster, not a dedicated vector DB
Simpler ops, better-than-needed performance at our scale. Revisit past 200 tenants.

### 2. Temporal for tenant provisioning orchestration
Long-running workflows with external calls, retries, and human-approval waits — exactly what Temporal is for. Accept the operational cost.

### 3. Per-tenant KMS CMKs, NOT shared CMK
Contained blast radius, GDPR-clean deletion, regulatory story. Extra ops overhead accepted.

### 4. In-house Secrets Vault service, not raw AWS Secrets Manager
Secret refs (`secrets://tnt_xxx/...`) are platform-native citizens. Rotation orchestration is where most of the value lives.

### 5. Escalation Notifier as a separate sidecar, not baked into the supervisor
Single instance per region (dedup-friendly). Watches filesystem events across all tenants. File-based protocol means restarts recover automatically.

### 6. `vault-search` as a CLI, not a service
Called by every `context.sh` at session start. Short-lived, no warm state, simple to debug. Operators can run the same binary for debugging.

### 7. Self-hosted Loki + Prometheus, not SaaS
Keeps UK/EU data sovereignty clean. Grafana self-hosted is free. PagerDuty is the only SaaS dependency in observability.

### 8. Row-level security (RLS) + schema-level isolation, both on
Belt-and-braces. An application bug can't leak tenant data. A DB role compromise can only see that role's tenant.

### 9. 24-hour RTO for full regional failure
Honest trade-off. Hot multi-region would double infrastructure cost for a scenario that happens maybe once every 5 years. Not worth it for MVP.

### 10. 7-year audit log retention in S3 Object Lock
Regulatory hedge for dental/finance verticals. Cheap at our volumes. One-way; cannot be deleted even by platform admin.

---

## What this phase enables

With Phase 3 shipped:
- The Provisioning System can onboard a new tenant in ~5 minutes end-to-end
- Every agent invocation is logged, costed, and attributable to a tenant
- Every escalation surfaces to Slack within seconds
- Retrieval works for any agent's `context.sh` call
- Observability gives the on-call a single pane of glass across all tenants
- Backups are running; restore path is tested
- Per-tenant isolation is enforceable at both schema and row level
- GDPR deletion is mechanically possible (CMK schedule-delete = mathematical erasure)

---

## What Phase 3 does NOT deliver

- **Dashboard UI** — that's Phase 4. The platform is usable only via CLI/API today.
- **Configuration Wizard** — also Phase 4. Tenants can't self-onboard; operator-assisted only.
- **Billing integration** — Stripe connection specified in passing only. Full spec in Phase 5.
- **Legal & compliance artifacts** — MSA, DPA, SLA in Phase 5.
- **Ops runbooks beyond backup/DR** — incident response, on-call, cost governance in Phase 6.
- **Tempo / distributed tracing** — deferred to v1.1 (post-50-tenants).
- **Hot multi-region failover** — deferred indefinitely.

---

## Dependency ordering for build

If you're handing this spec to a dev team, the build order that minimises blockages:

1. **CC11 — Postgres schema** (1 week — apply migration, verify RLS, set up pgBackRest)
2. **CC5 — Secrets Vault** (2 weeks — service + KMS setup + basic rotation)
3. **CC9 — Platform helpers** (1 week — `vault-search` is the blocking one; others can follow)
4. **CC4 — Provisioning System** (3 weeks — Temporal workflows; heaviest task in this phase)
5. **CC7 — Escalation Notifier** (1 week — straightforward fsnotify sidecar)
6. **CC6 — Observability** (2 weeks — deploy stack + dashboards + alerts)
7. **DR drill** (1 week — first quarterly drill to validate the whole stack)

Total: ~10 dev-weeks for one senior engineer, or ~5 weeks with two engineers in parallel.

Parallel work items that don't block: Phase 4 dashboard can start after CC11 lands. Phase 5 legal work is entirely parallel.

---

## Cost envelope at 10 tenants

| Component | Monthly |
|---|---|
| Hetzner dedicated (Postgres primary) | £80 |
| Hetzner standby + app nodes | £120 |
| AWS — S3 backups + DynamoDB + KMS | £50 |
| Observability (Loki + metrics + logs storage) | £85 |
| PagerDuty (3 seats) | £25 |
| GitHub Enterprise (if we go that route; else £0) | £0 |
| **Total infrastructure at 10 tenants** | **£360/month** |

Per-tenant infrastructure cost: ~£36/month. At our pricing (Growth tier £1,800/month), infrastructure is 2% of revenue. Acceptable.

At 50 tenants, infrastructure scales to ~£700/month (mostly linear in Loki + Postgres RAM). Per-tenant drops to ~£14/month. Gross margin improves as we scale.

---

## Risks and open questions

### R1 — pgvector scaling
At ~100k chunks per tenant, retrieval latency will need tuning. We have headroom (HNSW parameters, index partitioning) but will need dedicated work when a tenant crosses that threshold.

### R2 — Cohere EU dependency
Cohere is a single point of failure for embeddings. If they have a prolonged outage, Librarian can't index. We have degraded-mode handling, but sustained outage would be painful. Mitigation: evaluate a secondary embedding provider (Voyage, OpenAI) by v1.1.

### R3 — Temporal ops burden
Self-hosting Temporal isn't zero-cost. If it becomes painful, we pay for Temporal Cloud (~£500/month at our workflow volume). Not urgent.

### R4 — GitHub dependency
Tenant vaults live on GitHub. An extended GitHub outage degrades the system (new content can't sync, but existing content on container volumes keeps working). Acceptable risk — GitHub's reliability is higher than most of our alternatives.

### R5 — First DR drill will find problems
Every first DR drill finds issues. We'll allocate a full week for the first one and schedule the second drill 30 days after the first.

---

## Open decision for operator review

**OD-P3-1:** Do we run Temporal self-hosted or pay for Temporal Cloud?
- **Self-hosted:** £0/month direct cost, ~1h/month ops time, occasional upgrade pain.
- **Cloud:** ~£500/month at our volumes, zero ops time, no upgrade concerns.
- **Recommendation:** Start self-hosted (single-server Docker Compose), migrate to Cloud if it causes more than 2h/month of ops work.

**OD-P3-2:** Do we launch with Hot standby only, or Hot + Warm (with warm in AWS London)?
- **Hot only:** Simpler, cheaper. Regional failure = 24h+ RTO.
- **Hot + Warm:** Adds ~£200/month for the warm instance. Regional failure = 4h RTO.
- **Recommendation:** Hot only for MVP. Add warm when we have >20 paying tenants or an enterprise client that requires it in their MSA.

**OD-P3-3:** Where do we host the status page?
- **statuspage.io:** ~£30/month, battle-tested. Clients know what to expect.
- **Self-hosted (Cachet, Uptime Kuma):** Free, but we're operating it during the same incidents we need it for.
- **Recommendation:** statuspage.io. Don't self-host your status page.

---

## What to do next

**Before starting CC4-CC11 work:**
1. Lock the Phase 3 open decisions above
2. Provision the Hetzner dedicated + AWS accounts
3. Set up Terraform repo for infrastructure-as-code
4. Sign up for statuspage.io (if chosen)

**While Phase 3 is being built:**
- Phase 4 (dashboard) specs can start — they depend on Phase 3 APIs but not on Phase 3 being deployed
- Phase 5 (legal/billing) work is fully parallel
- Continue running the Proposal Builder POC daily to keep the agent muscle sharp while infra is being built

**Phase 3 completion criteria:**
- All 8 specs implemented and deployed to staging
- First DR drill run successfully
- One new tenant onboarded end-to-end through Provisioning System, agents running
- Observability dashboards showing the test tenant's activity correctly
- Escalation Notifier correctly surfacing a test escalation to Slack and the dashboard

When those are all green, Phase 3 ships and CC4–CC11 are done. Phase 4 (dashboard) picks up the baton.
