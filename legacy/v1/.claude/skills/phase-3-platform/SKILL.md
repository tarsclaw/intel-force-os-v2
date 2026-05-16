---
name: phase-3-platform
description: Phase 3 Platform Infrastructure — multi-tenant Postgres, Temporal provisioning workflows, AWS KMS secrets vault, observability spec, escalation notifier service, vault search, and DR runbook. Use this skill when planning the v2 architecture (customer 10+), designing enterprise-grade infrastructure, considering migration from Cloudflare-only to Postgres, or any scaling question beyond Cloudflare D1/KV. Also triggers on: multi-tenant, Postgres, Temporal, KMS, per-tenant isolation, enterprise, DR, scaling.
---

# Phase 3 — Platform Infrastructure Skill

**Pack status:** Deferred (v2 target). Activate when scaling beyond ~30 customers or first enterprise deal requires dedicated infra.

## Where the spec lives

`docs/phase-3-platform/` — 9 files, ~3,287 lines

| File | Covers | When to consult |
|---|---|---|
| `README.md` | Pack orientation | Starting Phase 3 work |
| `postgres-schema.md` | Per-tenant schemas, migrations, RLS | Implementing Postgres migration |
| `provisioning-via-temporal.md` | Temporal workflows for tenant setup | Automating customer onboarding at scale |
| `secrets-vault-with-aws-kms.md` | Per-tenant CMK secrets | Replacing Wrangler secrets |
| `observability-spec.md` | Structured logs, metrics, traces | Setting up Datadog/Grafana |
| `escalation-notifier-service.md` | Standalone escalation routing | When escalation outgrows Worker |
| `vault-search-spec.md` | FTS over customer vaults | Customers need history search |
| `disaster-recovery-runbook.md` | Backup + restore procedures | DR drill (cross-refs Phase 6) |
| `PHASE-3-SUMMARY.md` | Pack summary | Quick orientation |

## When to activate Phase 3

**Not yet.** The v1 architecture (Cloudflare Workers + KV + D1) covers the first ~20-30 customers comfortably.

Activation triggers (need any ONE to justify the migration):

1. **Scale** — 30+ customers and D1 query performance is degrading
2. **Enterprise deal** — customer requires dedicated infrastructure, specific region
3. **Compliance** — certification requirements (SOC 2 Type II, ISO 27001) demand per-tenant data isolation
4. **Multi-agent scale** — 5+ agents live per tenant, relationships between them get complex
5. **Feature requirement** — need capability Cloudflare can't support (long-running workflows, specific DBs, etc.)

**Activation anti-triggers** (do NOT migrate because of):
- "It feels more enterprise-y" — perception without pain
- "Maddox wants to learn Postgres" — wrong reason
- "What if we get a big customer?" — build for real customers, not imaginary
- "The current stack might fail someday" — every stack might

## The v2 architecture in one diagram

```
                    ┌────────────────────────────────┐
                    │  Teams app (customer-side)     │
                    │  — same as v1                  │
                    └──────────────┬─────────────────┘
                                   │
                                   ▼
                   ┌───────────────────────────────┐
                   │  API Gateway (Cloudflare)      │
                   │  Worker for routing + auth    │
                   └──────────────┬────────────────┘
                                  │
                  ┌───────────────┼───────────────┐
                  │               │               │
                  ▼               ▼               ▼
           ┌──────────┐    ┌─────────────┐   ┌──────────┐
           │ Postgres │    │  Temporal   │   │  KMS     │
           │ per-     │    │  Cloud      │   │  (secrets│
           │ tenant   │    │  (provisn,  │   │   per    │
           │ schemas  │    │  workflows) │   │   tenant)│
           └──────────┘    └─────────────┘   └──────────┘
                  │               │
                  ▼               ▼
           ┌──────────────────────────┐
           │  Agent runtimes          │
           │  — Workers for sync      │
           │  — Fly.io for long-run   │
           └──────────────────────────┘
                         │
                         ▼
              Observability: Datadog
              Escalation Notifier (standalone)
```

## Key architectural concepts in Phase 3

### Per-tenant Postgres schemas
Each customer gets a Postgres schema: `tenant_{id}.messages`, `tenant_{id}.users`, etc.

Benefits:
- Hard isolation: one tenant's queries can't touch another's data
- Per-tenant backup/restore
- Per-tenant migration control (useful for custom enterprise features)
- Row-level security (RLS) as belt-and-braces on top of schema isolation

Costs:
- Schema migrations run N times (one per tenant) — Temporal workflow handles this
- Monitoring per-tenant schemas needs tooling
- Cross-tenant analytics require a separate reporting schema

See `postgres-schema.md` for the DDL and migration approach.

### Temporal for provisioning
Customer onboarding becomes a Temporal workflow:

```
NewTenantWorkflow:
  1. Create Postgres schema (retry 3x on conflict)
  2. Run migrations on the new schema
  3. Clone Relevance AI template agent (retry on rate limit)
  4. Create per-tenant KMS key
  5. Encrypt customer secrets, store in vault
  6. Update central tenant registry
  7. Send welcome email
  8. On ANY failure: compensate (rollback every step)
```

Temporal handles retries, idempotency, compensation, timeouts — all the things that make manual onboarding flaky.

See `provisioning-via-temporal.md` for the workflow definitions.

### AWS KMS secrets vault
Each tenant has a unique Customer Master Key (CMK) in AWS KMS. Per-tenant secrets are encrypted under that CMK.

- Customer offboarding: delete the CMK → all that customer's secrets are cryptographically destroyed
- Key rotation: AWS KMS rotates annually, transparent to the app
- Access control: IAM policies restrict which services can decrypt which CMKs
- Audit: AWS CloudTrail logs every decrypt operation

Replaces v1's Wrangler secrets (which are global across tenants).

See `secrets-vault-with-aws-kms.md`.

### Observability spec
Three pillars: logs, metrics, traces.

- **Logs:** structured JSON, shipped to Datadog
- **Metrics:** request counts, latencies, error rates — per tenant, per agent, per endpoint
- **Traces:** OpenTelemetry spans across Worker → Relevance AI → Postgres

Alert rules: P95 latency > 5s, error rate > 1%, escalation queue depth > 10, etc.

See `observability-spec.md`.

### Escalation Notifier
Currently in v1: escalation card is sent inline by the Worker to HR Lead DM.

In v2: standalone service that:
- Receives escalation events from any source (not just Teams)
- Routes to the right human (HR Lead primary, backup, on-call rotation)
- Tracks SLA on acknowledgement time
- Sends follow-up pings if unacknowledged
- Supports multiple channels (Teams DM, email, SMS, phone call for SEV1)

See `escalation-notifier-service.md`.

## Migration from v1 to v2 — the sequence

If/when activation is triggered, the migration runs in phases:

1. **Shadow mode** (2-3 weeks) — run Postgres alongside D1; dual-write; compare reads
2. **Read migration** — shift reads to Postgres for new tenants only
3. **Write migration** — shift writes to Postgres for new tenants
4. **Backfill** — migrate existing tenants one at a time
5. **Deprecate D1** — remove D1 code, keep data for 90 days

Each phase has rollback criteria. See `disaster-recovery-runbook.md` for specifics.

## Cross-references

- **Phase 4 dashboard** — reads from same Postgres; shared data model
- **Phase 6 ops runbooks** — `postgres-incidents.md` (v2-specific) and `backup-verification-and-dr-drills.md` apply to Phase 3
- **Phase 2 agents** — agent runtime may move to Fly.io for long-running tasks that Workers can't handle
- **Phase 5 pricing** — Scale and Enterprise tiers include Phase 3 features as differentiators

## The honest stance on Phase 3

This pack was specified before v1 existed. It's thorough and correct at the enterprise-platform scale. But it's wildly premature for where Intel Force OS is now.

If a conversation drifts toward "let's start building Phase 3" before 20+ customers, push back:
- What's the specific customer-facing pain that Phase 3 solves?
- Can that pain be solved incrementally in v1?
- What does "ready for Phase 3" look like, concretely?

If there's no specific customer pain: we're not ready.

## When NOT to use this skill

- For v1 implementation: `teams-hr-agent` skill
- For current Cloudflare-specific patterns: `cloudflare-intel-force` skill
- For agent design: `phase-2-agents` skill
- For anything happening in the next 6 months: this skill is probably wrong

## One-sentence summary

Phase 3 is the blueprint for Intel Force OS at enterprise scale; it exists so that when we need it, we don't have to architect in a panic.
