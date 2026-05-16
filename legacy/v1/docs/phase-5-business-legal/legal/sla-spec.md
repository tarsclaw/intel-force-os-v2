# Service Level Agreement — Specification

**The service levels Clawd commits to, how they're measured, what happens when they're missed.**

> **⚠️ Commercial commitment with real money at stake.**
>
> Every SLA number in this document is a promise Clawd is prepared to back with service credits. Don't promise availability we can't deliver. The numbers below align with what Phase 3 infrastructure actually supports (single-region, hot + standby, no multi-region HA for v1).
>
> **Audience:** founder pricing SLA commitments; solicitor finalising terms; customer reviewing proposals.
>
> **Status:** v1.0. Reflects MVP infrastructure capability. Will tighten as reliability history accumulates.

---

## 1. How this SLA is used

### 1.1 Attached to the MSA

This SLA is Schedule 1 to the Master Services Agreement. Every customer receives the same baseline SLA unless explicitly negotiated in their Order Form (typically only for Enterprise tier).

### 1.2 Service credits are the remedy

The SLA's remedy is service credits applied to the following month's invoice. It is not:
- A full refund of fees paid during an outage
- A right to terminate (except as in the MSA's material breach clause)
- A waiver of usage fees
- Compensation for business losses (that's in the MSA liability cap)

### 1.3 Honest posture

We don't promise more than infrastructure supports. Better to commit to 99.5% and hit 99.9% than commit to 99.99% and hit 99.5% — the second scenario produces outraged customers and unwinnable disputes.

---

## 2. Template SLA

The following is the SLA template, structured to attach to the MSA as Schedule 1.

---

---

# Schedule 1 — Service Level Agreement

## 1. Definitions

In this SLA:
- **"Available"** means the Service is responding to user requests consistent with documented functionality.
- **"Monthly Service Availability"** means, for a calendar month, `(Total Minutes in Month − Unavailable Minutes) / Total Minutes in Month × 100%`.
- **"Scheduled Maintenance"** means maintenance announced at least 48 hours in advance, during an agreed maintenance window, for a reasonable duration.
- **"Service Credit"** means a credit applied to a future invoice as provided in this SLA.
- **"Unavailable Minutes"** means minutes during which the Service is not Available, excluding time attributable to:
  - Scheduled Maintenance
  - Emergency Maintenance necessary to prevent imminent harm (notified as soon as reasonably possible)
  - Force majeure events (as defined in the MSA)
  - Outages caused by Customer's equipment, network, or misuse
  - Outages caused by third-party integrations or services not operated by Clawd (e.g., Fathom API outage, GitHub outage affecting Vault sync)
  - Suspension under the MSA (e.g., for AUP violation or non-payment)

## 2. Service levels

### 2.1 Monthly Service Availability

Clawd commits to the following Monthly Service Availability for each tier:

| Tier | Committed Availability | Target (internal) |
|---|---|---|
| Starter | 99.0% | 99.5% |
| Growth | 99.5% | 99.9% |
| Scale | 99.5% | 99.9% |
| Enterprise | 99.9% (or as negotiated) | 99.95% |

Internal "Target" is what we aim for; "Committed" is what we pay service credits against.

### 2.2 Availability calculation

The Service is considered Available if:
- The dashboard is responding with HTTP 2xx or 3xx from the primary domain
- Tenant webhook receivers accept webhooks (HTTP 2xx response)
- Tenant-scoped API endpoints (if in use) respond

The Service is considered Unavailable if:
- Sustained HTTP 5xx from the dashboard or webhook receiver endpoints
- Tenant containers cannot be provisioned or are consistently unresponsive
- Postgres primary is unreachable from the application tier

Brief degradation (individual requests failing, <5% error rate over any 5-minute window) is not Unavailable.

### 2.3 Service Credits

If Monthly Service Availability falls below the commitment, Customer is entitled to the following Service Credits on the next month's invoice:

| Monthly Service Availability | Starter | Growth | Scale | Enterprise |
|---|---|---|---|---|
| Below commitment (e.g., < 99.0% Starter) but ≥ 98% | 5% | 10% | 10% | 10% |
| < 98% but ≥ 95% | 10% | 15% | 15% | 20% |
| < 95% but ≥ 90% | 20% | 25% | 25% | 35% |
| < 90% | 30% | 40% | 40% | 50% |

Service Credits are calculated as a percentage of the fixed Subscription Fees (not usage-based fees) paid for the affected month.

### 2.4 Maximum credit

Service Credits in any month are capped at 50% of the fixed Subscription Fees for that month.

## 3. Performance levels

Beyond availability, Clawd aims to (but does not commit service credits against):

| Metric | Target |
|---|---|
| Dashboard p95 page load | < 2.5 seconds |
| Webhook receiver dispatch latency p95 | < 500 ms |
| Webhook → tenant container dispatch p95 | < 2 seconds |
| Agent invocation start time from trigger | < 30 seconds |
| Agent invocation completion time (typical run) | < 3 minutes |
| Escalation surface latency (raised → visible in dashboard and Slack) | < 10 seconds |
| Vault search response p95 | < 500 ms |

These targets are communicated transparently to customers via the status page and periodic reviews. Missing them for sustained periods would be a sign of systemic issues warranting service credits, even absent an outright availability failure.

## 4. Support response times

| Severity | Definition | Response time (Growth and above) | Response time (Starter) |
|---|---|---|---|
| P1 — Critical | Service completely unavailable or data-integrity compromised | 1 hour | 4 hours |
| P2 — High | Major feature not working; workaround available | 4 hours | 1 business day |
| P3 — Medium | Non-critical bug or usability issue | 1 business day | 3 business days |
| P4 — Low | Question, enhancement request | 3 business days | Best effort |

Support is provided via email at support@clawd.ai and Slack for Growth+ customers.

Support hours: Monday–Friday, 09:00–18:00 UK time for standard severity; P1 supported on a 24/7 basis for Growth and above via the out-of-hours contact method provided.

**Enterprise** tier customers may negotiate different response times, dedicated support contacts, and scheduled account reviews as part of their Order Form.

## 5. Scheduled maintenance

### 5.1 Maintenance window

Scheduled Maintenance is typically performed:
- Saturday 22:00 UK time to Sunday 08:00 UK time, as needed, OR
- Weekday 23:00 UK time to 01:00 UK time for short (≤15 min) routine updates

### 5.2 Notification

Notification provided at least 48 hours in advance via:
- Email to designated tenant admins
- Status page at status.clawd.ai
- In-dashboard banner

### 5.3 Emergency maintenance

Clawd reserves the right to perform emergency maintenance without notice where necessary to address security vulnerabilities, prevent imminent service degradation, or comply with legal requirements. Notification is provided as soon as reasonably possible.

## 6. How to claim service credits

### 6.1 Claim process

To claim a Service Credit, Customer must:
(a) notify Clawd in writing (to billing@clawd.ai) within 30 days of the end of the month in which the Unavailability occurred;
(b) provide enough detail to identify the Unavailability (time, duration, symptoms);
(c) reference any incident identifiers from the status page if available.

### 6.2 Clawd review

Clawd will review the claim, compare against internal availability records, and respond within 15 business days.

### 6.3 Application

Approved Service Credits are applied to the next invoice.

### 6.4 No cash refund

Service Credits are not payable in cash. If Customer terminates before Service Credits can be applied, Service Credits are forfeited except as required by law.

## 7. Availability reporting

Clawd publishes:
- Real-time status at status.clawd.ai
- Monthly availability report to all customers within 5 business days of month end (for any month where availability fell below commitment)
- Annual summary to customers

## 8. Business continuity and disaster recovery

### 8.1 Commitments

- **RPO (Recovery Point Objective):** 15 minutes maximum data loss
- **RTO (Recovery Time Objective):**
  - Common failures (service crash, single-node outage): 1 hour
  - Postgres primary failure with standby failover: 4 hours
  - Full regional unavailability: 24 hours

### 8.2 DR testing

Clawd conducts quarterly DR drills. On request, Clawd will provide the drill report (redacted for security-sensitive content) to Customer.

### 8.3 Business-threatening incidents

If Clawd experiences an incident that materially threatens Clawd's ability to continue providing the Service (including Clawd's insolvency), Clawd will:
(a) notify Customer within 24 hours;
(b) provide Customer with a Vault export within 5 business days;
(c) cooperate reasonably with Customer's migration to an alternative.

## 9. Security incidents

### 9.1 Commitment

Notification to Customer of any Personal Data Breach affecting Customer's data within 72 hours of becoming aware (see DPA clause 4.7).

### 9.2 Security-only incidents (no data breach)

Notification of security incidents that don't involve Customer Personal Data (e.g., detected intrusion attempts without evidence of data access) within 5 business days.

### 9.3 Post-incident report

Within 10 business days of any material security incident, Clawd will provide a post-incident report covering: what happened, impact, remediation, and prevention measures.

## 10. Third-party dependencies

The Service depends on several third-party services (see DPA Annex B — Sub-processors). Outages in those services may affect Customer's use of the Service:

- **Anthropic API outage:** agents cannot run. Historical reliability of Anthropic's service is tracked at status.anthropic.com. We do not service-credit for Anthropic outages (outside our control).
- **Cohere API outage:** semantic search and indexing degraded. Same position.
- **Hetzner or AWS outage:** may affect hosting or backups. Same position.
- **GitHub outage:** Vault sync may be delayed (existing vault content still accessible on tenant containers). Same position.
- **Third-party integration outage** (Fathom, HubSpot, Gmail, etc.): affected integration unavailable. Customer must raise support with the integration provider.

Clawd works to minimise the impact of third-party outages where possible (e.g., graceful degradation, queuing) but does not service-credit against them.

## 11. Review

This SLA is reviewed annually. Any material change to service levels requires 60 days' notice to Customer. If the change materially reduces Customer's service levels, Customer may terminate on 30 days' notice, subject to payment of outstanding fees.

---

---

## 3. Internal operational notes

### 3.1 How these numbers tie to Phase 3 infrastructure

The availability commitments are calibrated to what our Phase 3 infrastructure (`phase-3-platform/dr/backup-and-dr-runbook.md`) actually supports:

- **99.0% (Starter):** 7.3 hours/month downtime permitted. Comfortably achievable with single-region hot + standby. Worst-case scenario (regional outage) would exceed this, but regional outages happen rarely; we accept the hit in the rare cases they happen (our DR runbook notes 24h RTO for regional failure).
- **99.5% (Growth, Scale):** 3.65 hours/month. Achievable assuming Postgres failover works as designed (~1 hour RTO). Regional failure would exhaust this budget; acceptable because regional failures are infrequent.
- **99.9% (Enterprise):** 43 minutes/month. Tight for our current infrastructure. Enterprise-tier customers who need 99.9% should trigger a discussion about upgrading to hot multi-region (doubles infra cost) — typically priced into the Enterprise tier uplift. Alternatively, negotiate a lower SLA on a specific Order Form.

### 3.2 Measurement in practice

We measure availability via:
- External synthetic monitoring (from multiple geographic points) hitting the dashboard and webhook-receiver endpoints every 60 seconds
- Internal health checks from Prometheus
- Cross-reference against the status page's recorded incidents

A month's availability is computed once at month-end from these sources. Any disagreement with a customer's own measurements is resolved via the external monitoring data (Clawd's chosen monitoring service — e.g., Pingdom, Better Uptime).

### 3.3 Status page

`status.clawd.ai` is publicly accessible and shows:
- Current service component statuses (dashboard, webhook receiver, Postgres, integrations health, etc.)
- Historical uptime for each component (30 days, 90 days)
- Active incidents
- Subscribe-to-updates widget for customers

We use a hosted status page service (recommendation: statuspage.io via Atlassian — ~£30/month). We do NOT self-host the status page; an incident affecting the platform often affects self-hosted status pages too.

### 3.4 Scheduled maintenance philosophy

- Avoid scheduled maintenance during customer business hours (primary hours: weekdays 07:00–20:00 UK)
- Prefer rolling deploys over scheduled windows — most platform updates happen with zero customer-visible downtime
- Reserve scheduled windows for genuinely disruptive changes (Postgres major-version upgrade, KMS migration)
- Communicate early and clearly; send the 48-hour notice even when we're fairly sure maintenance will be transparent

### 3.5 When to accept SLA redlines

**Standard tiers (Starter/Growth):** no redlines. If a prospect insists, politely decline. The cost of SLA negotiation exceeds the value of most sub-Scale deals.

**Scale:** minor redlines okay (e.g., adjusting support response times, not availability commitments).

**Enterprise:** substantial SLA negotiation is expected. Common requests:
- Higher availability commitment (we can sometimes offer 99.9% via dedicated infrastructure; price accordingly)
- Faster response times for P1 (can offer 30 min with named support contacts)
- Uptime tied to business hours (we can offer "99.9% during agreed business hours, 99.0% otherwise")
- Custom RPO/RTO commitments (more expensive; requires hot multi-region)
- On-call rotation with named contacts (requires enterprise support team investment)

Enterprise SLAs are negotiated on a per-deal basis with input from our solicitor.

### 3.6 When to propose a refund instead of service credits

Service credits are the default remedy. In severe, well-documented outages (e.g., >24-hour unavailability during a critical period for the customer), offering a direct refund as a gesture of goodwill may be commercially smarter than forcing the service credit mechanic. This is a case-by-case judgement call by the founder.

### 3.7 Tracking: the "SLA ledger"

We maintain an internal SLA ledger (a simple spreadsheet):

| Month | Tenant | Committed | Actual | Delta | Service credit owed | Notes |
|---|---|---|---|---|---|---|

Review monthly. Proactively surface negative deltas to customers before they notice (which builds trust). Avoid being surprised at end of quarter by unclaimed credits.

### 3.8 Over-performing the SLA

Hitting 99.99% when we've promised 99.5% is good, but:
- Don't communicate this as a promise; it becomes an implied commitment
- Do communicate it in quarterly reviews ("We hit 99.97% this quarter — comfortably above our 99.5% commitment")
- Do let the data influence future SLA tightening (e.g., raising Growth's committed availability if we consistently hit 99.9% for 12 months)

---

## 4. Open decisions

**OD-P5-8:** Commit to 99.5% on Growth, or start at 99.0%?
- **Recommendation:** Start at 99.0% for first 3 months post-launch (learn actual reliability), then raise to 99.5% once data supports it. Can always tighten; painful to loosen.

**OD-P5-9:** Offer 99.9% SLA on Enterprise tier?
- **Recommendation:** Yes, but only with dedicated infrastructure (hot multi-region, costs ~£500/month additional). Price the Enterprise tier to include this capability.

**OD-P5-10:** 24/7 P1 support on Starter tier?
- **Recommendation:** No. Starter gets business-hours response only; if a P1 comes in outside hours, we respond next business morning. Out-of-hours P1 is a Growth+ benefit.

**OD-P5-11:** Status page: statuspage.io or self-host?
- **Recommendation:** statuspage.io. ~£30/month. Don't self-host your status page.

---

## 5. Related

- `msa-template.md` — the parent agreement
- `dpa-template.md` — data-protection-specific provisions
- `phase-3-platform/dr/backup-and-dr-runbook.md` — the operational runbook this SLA's RPO/RTO numbers are calibrated against
- `phase-3-platform/observability/observability-spec.md` — the monitoring that measures SLA compliance
- `pricing/pricing-spec.md` — tier definitions and pricing

---

*This SLA is not a finalised contractual document; it's a template. A UK commercial solicitor should finalise before it's signed with any customer. The SLA numbers must be defensible against our infrastructure's actual capability — don't commit to what we can't deliver.*
