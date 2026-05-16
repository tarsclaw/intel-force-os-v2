# Severity Classification & Comms

**The shared language for classifying incidents and communicating about them. Every operator uses these severities consistently so that a SEV-2 means the same thing in PagerDuty, Slack, the status page, and the customer email.**

> **Audience:** every operator. Memorised, not looked up, by anyone who might go on-call.
>
> **Status:** v1.0. Designed to match industry conventions (SEV-1 is the worst) so new hires from other companies have the right instincts.
>
> **Why consistency matters:** under pressure, operators reach for the label they've drilled into. If one person declares "SEV-2" meaning "major" and another means "medium", comms are broken and decisions are wrong.

---

## 1. The four severities

### 1.1 SEV-1 — Critical

**Definition:** Platform-wide outage, data loss, confirmed security breach, or regulatory incident.

**Examples:**
- Dashboard is completely unreachable for all tenants
- Postgres primary has failed AND failover hasn't completed
- Suspected or confirmed customer data exposure
- Confirmed unauthorised access to production systems
- Ransomware or similar active attack
- Complete cost hemorrhaging (>£10k/hour platform-wide)
- All escalations stopped reaching customers; platform is running blind
- A published vulnerability in a dependency we're running, being actively exploited

**Response:**
- Immediate PagerDuty page; auto-page secondary within 5 min if primary unack'd
- Status page red
- Customer email within 15 minutes of declaration
- IC engaged full-time
- All-hands call warranted
- Postmortem mandatory; external stakeholders (regulator, major customers) may need briefing

**SLA impact:** SEV-1 minutes count directly against tier availability commitments. 99.0% tier = 7 hours/mo downtime budget; 99.5% = 3.6 hours/mo; 99.9% = 43 min/mo. A single SEV-1 can exhaust the budget for a month.

### 1.2 SEV-2 — Major

**Definition:** Significant functional degradation. Multi-tenant impact but not total outage. No data loss. No confirmed breach.

**Examples:**
- Dashboard sign-in failing for new sessions (existing sessions unaffected)
- Multi-tenant webhook delivery delayed / failing
- Integration with a core provider (Clerk, Stripe, Anthropic) degraded
- Cost spike that's contained but investigating
- Significant subset of agents failing a specific escalation type
- Provisioning System stalled (new onboardings blocked; existing tenants unaffected)
- Escalation notifier dropping notifications (fall-back Slack direct messages possible but nothing automated)
- Performance degradation (p95 > 3x normal) across the dashboard

**Response:**
- Immediate PagerDuty page
- Status page orange
- Customer email within 1 hour if customer-visible
- IC engaged; secondary on standby
- Postmortem within 1 week

**SLA impact:** customer-visible SEV-2 counts against tier availability. Internal-only SEV-2 (e.g., observability down, but customer workflows still working) typically doesn't.

### 1.3 SEV-3 — Minor

**Definition:** Single-tenant impact OR degraded-but-functional platform state OR elevated error rates without clear customer harm.

**Examples:**
- One tenant's webhook endpoint returning errors; investigating whether platform or tenant-side
- Single agent failing repeatedly for one tenant
- A non-critical internal service is degraded
- Prometheus alert firing on an unusual metric pattern
- A backup job failed (one-off; next job will retry)
- A Temporal workflow is stuck but not customer-facing
- Rate of failed sign-ins from one IP spike but not successful (probably attempted brute force; auto-blocked)

**Response:**
- Page during business hours; ticket outside business hours
- Status page yellow if customer-visible; otherwise no status page update
- Customer contact only if the affected customer already reported (respond + investigate)
- IC designation lighter — whoever picks it up owns it
- Postmortem optional; produced if meaningful learning

**SLA impact:** rarely counts unless escalated to SEV-2.

### 1.4 SEV-4 — Informational

**Definition:** No customer impact. Investigating unusual metrics, anomalies, or low-priority bugs.

**Examples:**
- Grafana shows an interesting spike in a metric last week
- A non-critical alert fired outside expected range
- A staging environment bug is found
- A dependency has a new CVE (low severity; no active exploit)
- An operator noticed a weird Loki log pattern

**Response:**
- No page
- Slack `#ops` thread or ticket
- Investigated within normal work rhythm
- Postmortem not applicable

**SLA impact:** none.

---

## 2. Severity decision — the three-question test

When declaring, if you're unsure between two severities, ask:

1. **Is data at risk?** (customer data integrity, availability, confidentiality) → if yes, minimum SEV-2. If confirmed or high probability, SEV-1.
2. **How many tenants are affected?** → multi-tenant = SEV-2 floor. Platform-wide = SEV-1 floor.
3. **Is the platform's trust at risk?** (confirmed security event, regulator involvement, high-profile customer crisis) → SEV-1.

If the answer is "no" to all three, you're probably looking at SEV-3. If unsure, round up — over-classifying a single incident is cheaper than under-classifying.

---

## 3. Severity upgrades and downgrades

Severity can change during an incident. When it does:

### 3.1 Upgrade

Announce clearly in Slack:
```
🔺 Upgrading to SEV-1: [reason]
```
- Page additional responders per PagerDuty escalation
- Update status page if needed
- Update customer email if one was sent

### 3.2 Downgrade

Announce clearly in Slack:
```
🔽 Downgrading to SEV-3: [reason]
```
- Page additional responders stand down
- Status page remains at higher level until resolved (don't backtrack on customer-visible language)

Downgrades are fine and normal. Many SEV-2s turn out to be SEV-3 once investigated.

---

## 4. Special cases

### 4.1 Single very-high-value customer affected

Rigby Group or another large tenant has a problem that would be SEV-3 for a small customer. Do we upgrade?

- Functional impact: the correct severity is based on platform behaviour, not customer importance
- Customer relationship: comms responsibility is elevated regardless of severity — the account owner should be direct-messaged, not just reliant on the standard email queue
- Escalation internally: whoever owns the commercial relationship (Maddox, Jack) is informed in Slack regardless of severity

So: don't inflate severity. Do inflate comms.

### 4.2 Suspected vs confirmed breach

- **Suspected:** SEV-2 while investigating. Page security-savvy engineer. Follow `compliance/breach-response-runbook.md` §3.
- **Confirmed:** automatic SEV-1. 72-hour GDPR breach notification clock starts.

Never delay investigation hoping "it's probably nothing" — investigate at SEV-2 pace and escalate the moment signals firm up.

### 4.3 Provider outages (Anthropic, Clerk, Stripe)

When a provider we depend on has an outage:

- If the provider's outage affects our customers directly → declare an incident at the severity matching customer impact (usually SEV-2)
- Comms pattern: "We're experiencing degraded performance due to an upstream provider issue. We're monitoring their status and will update." (Don't name-and-blame the provider on the public status page — they're working the issue too.)
- Internal name them freely in Slack for coordination

---

## 5. Status page updates

Status page is the single source of truth for customers about platform state.

### 5.1 Status page states

Matches Statuspage.io defaults:

| Platform state | Page colour | Description |
|---|---|---|
| `Operational` | Green | Everything working |
| `Degraded Performance` | Yellow | Platform working but slower or partial |
| `Partial Outage` | Orange | Specific feature or region affected |
| `Major Outage` | Red | Widespread unavailability |
| `Under Maintenance` | Blue | Planned maintenance window |

### 5.2 Mapping severity to status page state

| Severity | Typical status page state |
|---|---|
| SEV-1 with total outage | Major Outage (red) |
| SEV-1 with partial outage | Partial Outage (orange) |
| SEV-2 customer-visible | Partial Outage or Degraded Performance |
| SEV-2 internal-only | No status page update (or subtle "Investigating" notice) |
| SEV-3 single-tenant | No public update |

### 5.3 Update templates

Keep the language plain and factual. Templates:

**Declaration template:**
```
[INVESTIGATING] HH:MM UTC — We're investigating reports of [one-line
description of what users are experiencing]. More updates to follow.
```

**Identified template:**
```
[IDENTIFIED] HH:MM UTC — We've identified the cause of the [feature/area]
issue: [one-line plain description, no jargon]. [What we're doing: e.g.,
"Working with the provider on restoration" or "Deploying a fix now"].
```

**Monitoring template:**
```
[MONITORING] HH:MM UTC — A fix has been applied. [Feature/area] is
responding normally. We're monitoring the system for continued stability.
```

**Resolved template:**
```
[RESOLVED] HH:MM UTC — The [feature/area] issue is resolved. Normal
service has been restored. A postmortem will be published within 72 hours.
```

### 5.4 Update cadence during incident

| Severity | Minimum update frequency |
|---|---|
| SEV-1 | Every 30 minutes while active |
| SEV-2 | Every 60 minutes while active |
| SEV-3 visible | At declaration and resolution only |

"No update in 30 minutes" is worse than "still investigating" — customers assume the worst without signal.

### 5.5 What NOT to put on the status page

- Customer names or identifiers
- Specific provider names (Anthropic, Clerk etc.) — use "upstream provider"
- Internal hypothesis or speculation
- Individual engineer names
- Root-cause detail before postmortem (detail belongs in postmortem, not timeline)
- Apologies in every update (once at resolution is enough)

---

## 6. Customer email templates

When SEV-1 or SEV-2 customer-visible incidents last long enough to warrant email, use one of these.

### 6.1 SEV-1 — incident in progress

Subject: **[Clawd] Incident in progress — [feature/area]**

```
Hi {{first_name}},

We're writing to let you know we're currently experiencing an issue
affecting {{affected area}}.

What's happening: {{brief description}}

Started: {{time}} UTC

Who's affected: {{scope — e.g., "all customers", "customers using Feature X"}}

What we're doing: {{containment and ongoing work}}

What we need from you: {{nothing or specific action — usually nothing}}

Follow live updates at status.clawd.ai. We'll email you again when
the incident is resolved.

— The Clawd team
```

### 6.2 SEV-1 — incident resolved

Subject: **[Clawd] Incident resolved — [feature/area]**

```
Hi {{first_name}},

The issue affecting {{area}} is now resolved.

Duration: {{start}} to {{end}} UTC

What happened: {{2-3 sentence plain-language summary}}

What we're doing to prevent recurrence: {{1-2 sentences; or "full
postmortem within 72h"}}

Impact on you: {{specific impact for this customer if known, else
"please check your data if you have any concerns, and reach out to
support if you see anything unexpected"}}

We're sorry for the disruption. If you have questions, email
support@clawd.ai.

— The Clawd team
```

### 6.3 SEV-2 — if warranted (longer-running or customer-visible)

Similar to SEV-1 template but language is calmer. Don't over-alarm for SEV-2.

### 6.4 What NOT to put in customer emails

- Technical jargon (Postgres, Temporal, RLS — none of these mean anything to customers)
- Detailed postmortem content (that belongs in the postmortem)
- Blame (engineer names, provider names unless they've already gone public about their own issue)
- False reassurance ("this will never happen again" — we don't know that)

### 6.5 Post-incident compensation

For SLA breaches that trigger service credits (per `phase-5-business-legal/legal/sla-spec.md`), the customer must claim within 30 days. We don't automatically credit — too many edge cases — but we proactively notify affected customers in the resolution email:

> "This incident may qualify you for service credits under your SLA. Reply to this email within 30 days if you'd like us to process."

Minimises disputes; respects customers' right to claim.

---

## 7. Internal Slack comms conventions

### 7.1 Channel purposes

| Channel | Purpose |
|---|---|
| `#incidents` | Live incident activity; declarations, thread updates, resolution |
| `#on-call` | On-call handoffs, weekly triage summaries, non-urgent operator chat |
| `#ops` | Non-incident platform discussion (deploys, capacity, tool changes) |
| `#alerts` | Automated alert firehose from Prometheus / Loki |
| `#status-page` | Mirror of status page updates (auto-posted by Statuspage) |
| `#c-team` | Commercial / customer-facing team — notify them when incidents affect customer experience |

### 7.2 Internal vs external language

Internal Slack: direct, specific, technical. "Postgres primary is OOM'ing; failover triggered at 14:32."

External (status page, email): plain language. "We're experiencing a database issue; automatic failover is in progress."

Keep these separate. Don't copy internal Slack verbatim to a customer. Don't sanitise internal Slack for external — internal is for speed.

### 7.3 @here and @channel etiquette

- Declaration in `#incidents`: `@here` is fine to use (pulls attention)
- Thread updates in `#incidents`: no mentions unless paging a specific person
- `@channel` reserved for SEV-1 mass mobilisation

---

## 8. Post-incident communication

After resolution, the comms tail:

### 8.1 First 24 hours

- Status page: final "Resolved" update posted
- Customer email: incident-resolved email sent
- Internal Slack: "thanks everyone" post — acknowledges the team
- If SLA breach: service credit notification in resolution email

### 8.2 72 hours (SEV-1) / 1 week (SEV-2)

- Postmortem published internally (`/vault/ops/postmortems/YYYY-MM-DD-slug.md`)
- Summary shared in `#ops`
- Action items created in Linear

### 8.3 Customer-facing postmortem

For SEV-1 only, consider publishing an external postmortem. Rules:

- Factual; no blame
- Explains what customers need to know, not internal mechanics
- Includes what we're doing to prevent recurrence
- Published on status page as a post-resolution update
- Linked to from the customer-facing email if appropriate

External postmortems are a trust-building tool if done well. Templates in `/vault/ops/templates/external-postmortem.md`.

### 8.4 When NOT to publish externally

- Breach incidents: legal counsel drives comms; no operator-drafted external postmortem
- Incidents exposing specific vulnerabilities: delay publication until the vulnerability is fully remediated
- Incidents where the cause was another customer's action (privacy)

---

## 9. Measuring comms quality

Every postmortem (SEV-1/2) includes a "comms quality" review:

- Did the first status page update go out within the target?
- Did customer emails land at the right time, with the right content?
- Did internal comms keep the team coordinated?
- Any customer ask "why didn't you tell me?"

These reviews feed back into improving this document.

---

## 10. Changes to this document

- Any change to severity definitions requires team review — not one-person commit
- Changes proposed via pull request to the runbook repo
- Review cadence: at every major postmortem + at least quarterly

---

## 11. Related

- `incident-response/incident-response-runbook.md` — the flow using these severities
- `incident-response/on-call-handbook.md` — rotation and shift mechanics
- `compliance/breach-response-runbook.md` — breach-specific comms
- `phase-5-business-legal/legal/sla-spec.md` — tier commitments measured against incident duration
- Statuspage.io docs — tool we're using (linked in `#ops` channel bookmarks)
