---
name: phase-6-ops-runbooks
description: Phase 6 Operations Runbooks — incident response, on-call handbook, severity classification, platform incidents (Postgres, Workers, tenants), deployment and rollback, cost governance, secret rotation, backup verification, DR drills, GDPR DSAR and deletion, breach response. Use this skill when responding to incidents, planning on-call coverage, handling a customer DSAR, rotating secrets, running DR drills, investigating cost spikes, or dealing with any operational concern. Also triggers on: incident, outage, SEV1, rollback, on-call, DR, disaster recovery, breach, GDPR, DSAR, deletion request, secret rotation.
---

# Phase 6 — Operations Runbooks Skill

**Pack status:** Dormant until customer 1 live. Activates immediately on first paid customer.

## Where the spec lives

`docs/phase-6-ops-runbooks/` — 13 files, ~6,366 lines

| File | When to use |
|---|---|
| `incident-response-runbook.md` | Something's broken in production |
| `on-call-handbook.md` | Setting up / maintaining on-call coverage |
| `severity-classification-and-comms.md` | During incident — SEV1/2/3 definitions + customer comms |
| `postgres-incidents.md` | Postgres-specific issue (v2) |
| `platform-service-incidents.md` | Cloudflare Worker/KV/D1 issue |
| `tenant-incidents.md` | Single customer broken, rest fine |
| `deploy-and-rollback.md` | Every deploy + rollback |
| `cost-governance-runbook.md` | Monthly cost review, unexpected spike |
| `secret-rotation-runbook.md` | Quarterly rotation + breach response |
| `backup-verification-and-dr-drills.md` | Quarterly DR drill |
| `gdpr-dsar-and-deletion-runbook.md` | Customer DSAR or deletion request |
| `breach-response-runbook.md` | Suspected or confirmed breach |
| `PHASE-6-SUMMARY.md` | Pack overview |

## When to activate Phase 6

The moment customer 1 goes live. Before that, these runbooks are reference material for a single-operator (Maddox) running a dev tenant — most don't apply.

Once a paying customer is live:
- `incident-response-runbook.md` — print or bookmark, check quarterly
- `deploy-and-rollback.md` — every deploy follows this
- `gdpr-dsar-and-deletion-runbook.md` — triggered by customer request (typically within 30 days)

Later (as more customers come in):
- `on-call-handbook.md` — need a coverage plan, even if solo
- `cost-governance-runbook.md` — monthly
- `secret-rotation-runbook.md` — quarterly
- `backup-verification-and-dr-drills.md` — quarterly

## The incident response frame

From `incident-response-runbook.md`:

### Severity levels

**SEV1 — Complete outage or data loss risk**
- Response: immediate, drop everything
- Customer comms: proactive, every 30 min
- Examples: Worker returning 500 for all tenants; D1 corruption; suspected data breach

**SEV2 — Significant degradation or single-customer outage**
- Response: within 1 hour during business hours, next morning after hours
- Customer comms: notify affected customers within 2 hours
- Examples: one customer's bot down; weekly report cron failed; Relevance AI slow

**SEV3 — Partial degradation, workaround exists**
- Response: within 24 hours
- Customer comms: if customer-facing, notify in next check-in
- Examples: one Adaptive Card renders wrong on mobile; minor prompt drift

### Incident response sequence (SEV1)

1. **Acknowledge** (public status page: investigating)
2. **Assess** (what's broken, who's affected, can we bound it)
3. **Mitigate** (stop the bleeding — rollback, feature flag, disable tenant)
4. **Communicate** (all affected customers notified)
5. **Resolve** (root cause fixed, verified)
6. **Post-mortem** (within 48h, customer-facing summary if external impact)

Don't skip steps. The post-mortem habit is what distinguishes founders who scale from founders who don't.

## The solo on-call reality

`on-call-handbook.md` assumes you have a rotation. At v1 scale, you have Maddox. This means:

- **Maddox is always on-call** during customer business hours (UK 9-6 baseline)
- **Outside hours:** monitoring alerts to phone; SEV1 wakes you, others wait till morning
- **Backup:** Jack (business partner) for business escalation, not technical
- **When you take time off:** customers are notified in advance; auto-escalation pauses; acknowledge SLA generously stated

This isn't scalable, but it's honest for v1. Don't pretend you have 24/7 coverage when you don't.

## GDPR operations — critical for UK customers

File: `gdpr-dsar-and-deletion-runbook.md`

### DSAR (Article 15 — right of access)
Customer employee requests their data. Response:
1. Confirm identity of requester
2. Run export script: `npm run dsar-export -- --tenant-id=X --employee-aad=Y`
3. Review output for third-party PII (other employees mentioned in messages)
4. Redact third-party PII before delivery
5. Deliver within 30 days of request (GDPR mandate)

### Article 17 — right to erasure
Similar process but:
1. Verify deletion won't conflict with legal retention obligations
2. Run deletion: `npm run dsar-delete -- --tenant-id=X --employee-aad=Y`
3. Confirm deletion in writing to customer
4. Audit log the deletion itself (meta-audit)

### Customer offboarding deletion
30 days after cancellation:
1. Full tenant data deletion
2. Relevance AI agent clone + knowledge base deleted
3. Confirmation sent to customer main contact

All procedures fully documented in `gdpr-dsar-and-deletion-runbook.md`.

## Cost governance

File: `cost-governance-runbook.md`

### Monthly review (first Friday of month)
- Cloudflare Workers: requests, CPU ms, egress
- Cloudflare KV: reads, writes, storage
- Cloudflare D1: rows, queries, storage
- Relevance AI: API calls, LLM tokens (dominant cost)
- Azure: minimal (Entra ID + bot registration)

### Alert thresholds
- Any single tenant > £50/month Relevance AI cost → investigate
- Total cost > 30% of MRR → action required
- Unexpected >2x increase MoM → incident

### Cost optimisation actions (in order of preference)
1. Better caching (Worker-level cache for repeated queries)
2. Reduce Relevance AI token usage (tighter system prompts)
3. Batch operations where possible
4. Move heavy tenants to paid tier
5. Migrate agent brain from Relevance AI to direct Claude (Phase 3 trigger)

## Secret rotation

File: `secret-rotation-runbook.md`

### Quarterly rotation (every 90 days)
- `MICROSOFT_APP_PASSWORD` — Entra ID app secret
- `RELEVANCE_API_KEY` — Relevance AI API key
- Customer-specific secrets (if any)

### Process
1. Create new secret (don't delete old yet)
2. Deploy Worker with new secret
3. Verify Worker works with new secret (smoke test)
4. Delete old secret
5. Document rotation in audit log

### Breach response rotation
If a secret is suspected compromised:
1. Rotate IMMEDIATELY (skip verification steps; accept brief downtime)
2. Audit log all access during the suspected exposure window
3. Customer notification if required under contract
4. Post-mortem

## The meta-runbook priorities

When something breaks, the priority order is:

1. **Customer data integrity** — no data loss, no data leakage
2. **Customer service continuity** — bot available, approvals workable
3. **Recovery time** — restore normal operations
4. **Communication** — customers know what's happening
5. **Root cause** — fix it so it doesn't happen again

Don't optimise for speed over data safety. Don't optimise for blame-avoidance over honest post-mortems.

## Things to set up before customer 1

Before you put any real customer on Intel Force OS:

- [ ] Status page live (statuspage.io or similar) at `status.intelforce.ai`
- [ ] Better Uptime / Uptime Robot monitoring `/health` every 60s
- [ ] Error tracking (Sentry) integrated with Worker
- [ ] Slack/phone alerting set up
- [ ] Backup verification tested at least once in dev
- [ ] Rollback tested at least once in dev
- [ ] GDPR DSAR export script tested
- [ ] GDPR deletion script tested
- [ ] Audit log retention confirmed (7 years per SLA)
- [ ] Incident response plan shared with Jack (backup human)

**Don't skip these.** Each item took thought to spec in Phase 6. They're the minimum ops maturity for paid customers.

## Cross-references

- **Platform specific incidents** reference Phase 3 when Postgres is live
- **Deploy and rollback** references the `/deploy` slash command
- **GDPR runbook** references Phase 5 DPA terms
- **Cost governance** references Phase 5 pricing for tier-appropriate usage limits

## When NOT to use this skill

- For new feature design: wrong skill
- For customer acquisition: `gtm-execution` skill
- For architectural questions: `teams-hr-agent` or `phase-3-platform` skill

This skill is specifically for "what do I do when X breaks" or "what do I do when customer asks for Y (legal/data) thing."

## One-sentence summary

Phase 6 is the "what to do when things go wrong" library — consult reactively when something breaks or proactively when setting up ops maturity.
