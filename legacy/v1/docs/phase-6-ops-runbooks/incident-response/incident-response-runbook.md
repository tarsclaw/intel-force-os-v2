# Incident Response Runbook

**The general pattern for responding to a platform incident — regardless of which component is affected. Every specific runbook (Postgres, platform service, tenant incident) builds on this flow.**

> **Audience:** whoever is on-call when something breaks. In v1 that's Maddox or Jack; later, whoever we hire into operator roles.
>
> **Status:** v1.0. Small-team pragmatic. Scales up to a proper SRE-style process when headcount justifies it.
>
> **Philosophy:** minimise blast radius, communicate early and honestly, learn from every incident. Ops maturity comes from writing things down and reading them under pressure — that's why this document exists.

---

## 1. What counts as an incident

An **incident** is any unplanned event that degrades or threatens to degrade the platform's operation for customers. Not every problem is an incident:

| Situation | Incident? |
|---|---|
| A single agent invocation failed with escalation code `UPSTREAM_API_ERROR` | No. Escalation, not incident. |
| The escalation was from a recurring failure affecting one tenant | Maybe — monitor; if pattern continues, declare. |
| Five tenants report their webhooks aren't firing | Yes. Declare. |
| Postgres primary is unreachable | Yes. Declare immediately. |
| PagerDuty fired CRIT on `dashboard_trpc_error_rate > 5%` | Yes. Declare. |
| A single Grafana panel shows a weird spike last week | No. Investigate calmly; not time-sensitive. |
| GDPR DSAR received | Yes — but use the DSAR runbook, not this one. |
| Suspected data breach | Yes — declare AND invoke breach response runbook immediately. |

When in doubt: **declare.** Declaring an incident you later discover is minor has near-zero cost. Not declaring a real one costs trust, money, and potentially regulatory exposure.

---

## 2. Severity classification

Four severities, used consistently across PagerDuty, Slack, status page, and postmortems. Full mapping in `severity-classification-and-comms.md`.

| Severity | Examples | Response |
|---|---|---|
| **SEV-1** | Platform down; data loss; confirmed breach | Immediate page; all-hands; status page red; customer comms within 15min |
| **SEV-2** | Major feature broken (e.g., dashboard login); multi-tenant impact; near-breach | Immediate page; IC assigned; status page orange; customer comms within 1h |
| **SEV-3** | Single-tenant impact; degraded but usable; elevated errors | Page during business hours; ticket otherwise; status page yellow if customer-visible |
| **SEV-4** | No customer impact; investigating unusual metrics | No page; tracked as an issue; investigated within SLA |

Severity can be upgraded or downgraded mid-incident. If upgrading, announce explicitly: "**Severity upgraded to SEV-1. [reason].**"

---

## 3. Roles during an incident

### 3.1 Incident Commander (IC)

- Owns the incident end-to-end
- Makes decisions on actions (rollback, failover, escalate)
- Coordinates comms
- Ends the incident when resolved

**Who's IC:** the on-call operator who receives the page. If more senior people join, IC can hand off explicitly ("Jack, you're IC now. Confirming."). One IC at a time — always. Never two.

### 3.2 Comms lead

- Drafts status page updates
- Drafts customer emails if needed
- Pushes updates to Slack
- Keeps the #incidents channel informed

**Who's comms lead:** by default, the IC. If the incident is long-running or customer-facing enough that comms becomes a full job, a second person takes this role so IC can focus on fixing.

### 3.3 Technical lead

- Owns the fix itself
- Runs commands on infrastructure
- Writes code if a fix requires it

**Who's technical lead:** whichever engineer knows the affected system best. Often the IC, but can be delegated.

### 3.4 Scribe (SEV-1/SEV-2 only)

- Logs a timeline as the incident unfolds
- Records decisions, commands run, reasoning
- Feeds directly into the postmortem

**Who's scribe:** anyone not otherwise occupied. In a small team this may be someone pulled in specifically.

### 3.5 Small team reality

For the first year, roles will often collapse onto one person. That's fine as long as:
- The IC explicitly acknowledges they're wearing multiple hats
- The scribe role is not skipped (use a Slack thread as the timeline if no one else is available)
- A second person is pulled in for SEV-1 incidents — even if it's Maddox calling Jack from a ski lift

---

## 4. The incident flow

```
  ┌─────────────────┐
  │ ALERT RECEIVED  │  (PagerDuty, customer report, Slack mention, etc.)
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │ DECLARE         │  → Post to #incidents: "Declaring SEV-X: [1-line summary]"
  │                 │  → Create timeline thread
  │                 │  → Page co-responder if SEV-1 or SEV-2
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │ ASSESS          │  → Scope: what's affected? how many tenants?
  │                 │  → Severity confirmed or adjusted
  │                 │  → Initial hypothesis of cause
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │ COMMUNICATE     │  → Status page update (SEV-1/2)
  │                 │  → Customer email (SEV-1 with visible impact)
  │                 │  → Internal channel update
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │ CONTAIN         │  → Stop further harm before fully fixing
  │                 │    (e.g., suspend bad tenant, failover DB,
  │                 │     disable broken webhook, rollback deploy)
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │ RESOLVE         │  → Apply fix
  │                 │  → Verify via metrics + user-facing check
  │                 │  → Update status page to "Monitoring"
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │ MONITOR         │  → Watch metrics for 30min-2h (sev-dependent)
  │                 │  → If stable, resolve; if regresses, repeat
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │ CLOSE           │  → Status page → Resolved
  │                 │  → Final customer comms if applicable
  │                 │  → Schedule postmortem
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │ POSTMORTEM      │  → 72h for SEV-1/2, 1 week for SEV-3
  │                 │  → Blameless template
  │                 │  → Actions tracked to completion
  └─────────────────┘
```

---

## 5. Declaring an incident

The moment you suspect an incident, post to `#incidents` Slack channel:

```
🚨 Declaring SEV-2 incident: dashboard login failing for multiple tenants

IC: @maddox
Started: 14:32 UK
Scope: at least 3 tenants reporting sign-in failures
Hypothesis: Clerk outage? Investigating.
Thread below for updates.
```

That's it. Don't wait to have full picture. Declaring starts the clock on comms and mobilises response.

### 5.1 Slack conventions

- `#incidents` channel is the primary operational room during an incident
- Every incident gets a thread — all timeline updates go in the thread
- Top-level messages reserved for declaration, severity changes, and resolution
- At SEV-1, pin the declaration message

### 5.2 PagerDuty conventions

- Incidents auto-create in PagerDuty from alert sources (Prometheus, Loki-alerts, statuspage-external-monitor)
- IC acknowledges the PagerDuty incident within 5 minutes — this stops the paging escalation tree
- When resolved, mark PagerDuty incident resolved with a one-line summary

---

## 6. The comms rules

### 6.1 Status page

Any incident with SEV-1 or SEV-2 severity, AND any SEV-3 with visible customer impact, MUST be reflected on the status page (status.clawd.ai via Statuspage.io).

Statuspage update cadence:
- SEV-1: every 30 minutes, even if "still investigating"
- SEV-2: every 60 minutes
- SEV-3: at declaration + resolution

### 6.2 Status page update template

```
[Investigating] 14:35 UTC — We're investigating reports of dashboard
sign-in failures. Updates as we learn more.

[Identified] 14:48 UTC — Issue identified: upstream authentication
provider is experiencing degraded performance. Existing sessions
are unaffected. New sign-ins may fail.

[Monitoring] 15:12 UTC — Upstream provider has recovered. Sign-ins
are succeeding again. Monitoring for stability.

[Resolved] 15:45 UTC — Incident resolved. Postmortem to follow within 72h.
```

No jargon. No apology in every update (one at resolution is enough). Timestamps always in UTC for unambiguity. "Upstream authentication provider" is fine — we don't need to name Clerk on the public page.

### 6.3 Customer email

For SEV-1 with customer-visible impact (lasted >15min), email affected customers:
- Subject: "[Incident] Clawd — [brief description]"
- What happened, when, who was affected
- What you did
- What you're doing next
- Who to contact with questions

Draft lives in `/vault/ops/templates/incident-email.md`. Comms lead adapts it.

### 6.4 Internal comms

Keep the team up to date every 15–30 minutes via Slack thread. No radio silence. "Still investigating, no new info" is a valid update — it tells the team you're still on it.

---

## 7. Containment before resolution

A core incident-response principle: **stop making things worse before you make them better.** Examples:

| Incident | Containment (immediate) | Resolution (later) |
|---|---|---|
| Tenant runaway cost (£1,000 in 10 min) | Suspend that tenant's agents via dashboard | Investigate why the cost budget's hard-stop failed |
| Postgres primary corruption suspected | Failover to replica; stop all writes | Identify corrupt data; restore from backup |
| Bad deploy causing errors | Rollback to previous image tag | Investigate the bug in the new version |
| Escalation notifier down | Disable customer escalation notifications temporarily; prevent cascading Slack/email spam on recovery | Restart service, catch up backlog |
| DDoS on dashboard | Enable Cloudflare under-attack mode | Identify and block source; tune WAF rules |

Containment is often "partial fix with known side effects." That's fine — a degraded platform is better than a broken one. Make the trade-off consciously and note it in the timeline.

---

## 8. Resolution verification

Before declaring resolved, verify through AT LEAST TWO independent signals:

1. **Metric** — Prometheus / Grafana shows the error rate has normalised
2. **User-facing check** — the IC manually performs the broken action (log in, trigger a webhook, view a dashboard) and it works
3. **Customer confirmation** (if customer reported the issue) — ask them to retry and confirm

For SEV-1, all three are required. For SEV-2, two are required. Claiming "fixed" based on a single flaky signal is how incidents re-open two hours later.

---

## 9. Post-incident monitoring

After resolution, stay in the incident for a period based on severity:
- SEV-1: 2 hours of quiet monitoring
- SEV-2: 1 hour
- SEV-3: 30 minutes

Monitor means: IC is still on the incident, dashboards open, alerting subscribed. If metrics regress, reopen the incident at the same severity or higher.

Only after the monitoring window elapses cleanly can the status page go to "Resolved."

---

## 10. Closing an incident

Close the incident in this order:
1. Status page → Resolved
2. PagerDuty incident → Resolved
3. Slack declaration thread → "🟢 Resolved at [time]"
4. Final customer email (if one was sent during) — "Incident resolved. Postmortem to follow within 72h."
5. Create postmortem document (see §11)

---

## 11. Postmortem

Every SEV-1 and SEV-2 gets a postmortem. SEV-3 gets one if there's meaningful learning.

### 11.1 Timeline

- SEV-1: postmortem draft within 72 hours; review meeting within 1 week; action items tracked in Linear
- SEV-2: postmortem draft within 1 week
- SEV-3: postmortem draft within 2 weeks if produced

### 11.2 Template

```markdown
# Postmortem: [Incident title]

**Date:** YYYY-MM-DD
**Duration:** HH:MM – HH:MM UTC
**Severity:** SEV-X
**Impact:** [Who was affected, for how long, how badly]
**IC:** [Name]

## Summary
[3-5 sentences: what happened in plain language]

## Timeline
[UTC timestamps, key events only. Copy from Slack thread + PagerDuty log.]

## Root cause
[The actual cause, not the trigger. A bug was introduced in commit abc1234 because…
Use "5 whys" if causality is unclear.]

## Resolution
[What fixed it. What was tried that didn't work, briefly, for learning.]

## What went well
[Detection speed, comms clarity, containment effectiveness — anything we'd do the same.]

## What went poorly
[Gaps we hit. Knowledge missing. Tools slow. Comms confused.]

## Action items
[Concrete, assigned, with dates. Not "improve alerting" — "Add Prometheus alert for X, owner: Priya, by 2026-05-10".]

## Prevention
[What change makes this class of incident harder to recur.]
```

### 11.3 Blameless

The culture rule: postmortems focus on systems and processes, not individuals. "Engineer pushed a breaking change" is not a useful finding; "Our pre-deploy checks don't catch this class of regression" is.

If someone made a mistake, the useful question is "how did our systems let that mistake reach production?" — not "who's to blame?"

### 11.4 Action items

Action items are tracked in Linear, linked to the postmortem. Each has:
- Owner (one person, not "the team")
- Due date
- Done / Not done status

At the weekly platform review (see cost governance runbook), we look at open action items and their ages. An open action item older than 30 days is a meta-incident — surfaces in the weekly review.

---

## 12. Incident tooling checklist

These must be in place before v1 launch — not during the first incident:

- [ ] PagerDuty account with on-call schedule
- [ ] Slack `#incidents` channel
- [ ] Statuspage.io public status page at status.clawd.ai
- [ ] Prometheus + Grafana with alert rules (Phase 3 observability spec)
- [ ] Loki with standard queries saved as "Incident investigation" dashboards
- [ ] Customer email list in Postmark (or equivalent) with segmentation by affected tenant
- [ ] Runbook index accessible offline (printed cheat sheet for IC bag — literally; laptop-less scenarios happen)
- [ ] This document and all the specific runbooks in `/vault/ops/` and synced to at least one human's local machine

---

## 13. Anti-patterns to avoid

### 13.1 "I'll just ssh in and fix it real quick"

Every manual command on production should be logged in the timeline. Context for future you: what commands you ran, in what order, and what responded. If you skip the log, the postmortem becomes "I did... something? And then it worked?" which is useless for learning.

### 13.2 "Let's not declare, it's probably fine"

See §1 — when in doubt, declare. The Slack declaration is cheap.

### 13.3 Heroics without handoff

If you've been IC for 4+ hours on a SEV-1, you're exhausted and making bad decisions. Hand off to someone else, even if it means paging them off-hours. Fatigued ICs prolong incidents.

### 13.4 Premature "resolved"

See §8 — verify with two independent signals. Do not close a status page update to "Resolved" based on hope.

### 13.5 No postmortem

"We were busy" is not a reason to skip. Postmortems are the compounding asset — each one makes the next incident shorter.

### 13.6 Skipping comms to focus on the fix

If the IC is also doing comms and feels under pressure, pull a second person in to do comms. Silent status pages erode customer trust faster than the incident itself.

---

## 14. Specific runbooks index

When an incident affects a specific component, use the corresponding specific runbook alongside this one:

| Affected component | Specific runbook |
|---|---|
| Postgres (primary/replica/vector) | `runbooks/postgres-incidents.md` |
| Escalation Notifier | `runbooks/platform-service-incidents.md` §2 |
| Secrets Vault | `runbooks/platform-service-incidents.md` §3 |
| Provisioning System / Temporal | `runbooks/platform-service-incidents.md` §4 |
| Webhook receiver | `runbooks/platform-service-incidents.md` §5 |
| Dashboard (Next.js) | `runbooks/platform-service-incidents.md` §6 |
| Tenant container | `runbooks/tenant-incidents.md` §2 |
| Cost runaway | `runbooks/tenant-incidents.md` §3 |
| Integration provider outage | `runbooks/tenant-incidents.md` §4 |
| Deploy failure | `runbooks/deploy-and-rollback.md` |
| Suspected data breach | `compliance/breach-response-runbook.md` |

---

## 15. Incident practice — game days

Twice per year, run a scheduled game day: simulate an incident, practice response. Participants: whole platform team.

Scenarios to rotate:
- "Postgres primary is unreachable" (trigger: block network to primary in staging)
- "Anthropic API is returning 500s" (trigger: flip a feature flag that forces Anthropic calls to fail in staging)
- "Escalation Notifier stopped writing to Slack" (trigger: kill the service in staging)
- "A tenant has exceeded budget by 5x in 10 minutes" (trigger: simulate runaway invocations)

Game days are low-stakes (staging, announced ahead) but force participants to exercise the muscle. First real SEV-1 is easier if you've already rehearsed.

---

## 16. Single-person on-call constraints

For the first year, on-call is likely Maddox + Jack rotating (or just Maddox). Small-team implications:

- **SEV-1 requires a second human.** One-person SEV-1 is a recipe for errors. Even if the second person just watches and keeps the timeline, the extra set of eyes matters.
- **Business hours SEV-3 is fine to handle solo.**
- **Off-hours SEV-3 is handled same-day but not necessarily at 3am.** Customer expectations (set in the SLA) allow this.
- **Vacation coverage.** When the one on-call person is on vacation (or on a yacht in Carriacou), someone else must be explicitly covering. This MUST be arranged before departure, not after.

---

## 17. Related

- `incident-response/on-call-handbook.md` — rotation schedule, paging setup, first-responder checklist
- `incident-response/severity-classification-and-comms.md` — severity decisions + comms templates
- `runbooks/*.md` — specific-component response
- `compliance/breach-response-runbook.md` — breach-specific flow (extends this runbook)
- `phase-5-business-legal/legal/sla-spec.md` — SLA commitments we're measuring against during incidents
- `phase-3-platform/observability/observability-spec.md` — where alerts come from
- `phase-3-platform/dr/backup-and-dr-runbook.md` — recovery procedures for data incidents
