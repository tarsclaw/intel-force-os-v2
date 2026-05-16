# On-Call Handbook

**Everything an on-call operator needs to know — from the moment they go on rotation to the moment they hand off. Rotation schedule, paging setup, first-responder checklist, handoff ritual.**

> **Audience:** whoever is on-call. First year that's Maddox and Jack.
>
> **Status:** v1.0. Small-team operational handbook; scales to proper multi-engineer rotation when headcount justifies.
>
> **Non-negotiables:**
> - The on-call person has priority decision rights during their shift
> - Acknowledging a page within 5 minutes is the only hard SLA internally
> - Every shift has a documented handoff — no "I assume you know"

---

## 1. Rotation model

### 1.1 V1 (small team)

Primary + secondary, weekly rotation. Current participants:
- Maddox
- Jack

Rotation is one week on, one week off. Primary carries the pager; secondary is the backup for SEV-1/SEV-2 incidents.

If only one human is available (early days, vacations, etc.) that person is both primary and secondary. When that's the case, lower severity thresholds apply — we auto-mail customers any SEV-1/2 incident notice with "Solo on-call; extended response times possible" honesty.

### 1.2 V1.5 — when we hire an operator

Becomes primary / secondary / tertiary. Shift stays weekly. Tertiary is a "break glass" third tier only for multi-hour SEV-1.

### 1.3 V2 — when we hit 3+ engineers

Separate rotations for:
- **Platform on-call** — infrastructure, dashboard, data
- **Agent on-call** — agent misbehaviour, escalation triage, cost anomalies

With 3+ engineers, shifts become 12-hour or 24-hour rotations, not weekly. Cognitive load of a week-long on-call is too high for larger teams.

### 1.4 Out of scope (for now)

We do not:
- Run 24/7 human coverage of *everything* — automated alerting escalates to a human when required
- Have shift pay (flat compensation; this is an investor-funded startup)
- Guarantee anyone a "no on-call" track (but we don't punish people for not wanting it, either — we just wouldn't hire them into an ops role)

---

## 2. Shift structure

### 2.1 Shift length

One calendar week (Monday 09:00 UK → Monday 09:00 UK).

### 2.2 Handoff meeting

30-minute video call every Monday at 09:00 UK between outgoing and incoming primary. Agenda:

1. Walk through all incidents from the week (resolved and open)
2. Walk through any open action items from postmortems
3. Surface anomalies that haven't escalated to incidents but feel off
4. Confirm next week's coverage (secondary, any known absences)
5. Acknowledge handoff formally: "I'm taking the pager as of 09:00 Monday"

Skipping handoff is not acceptable. If times don't work, async handoff via Loom recording + Slack — but default is live.

### 2.3 Pager transfer

PagerDuty auto-rotates per schedule. In addition, the outgoing primary manually confirms in Slack `#on-call` at 09:00 Monday: "Shift ending. @incoming, you're up."

Incoming primary confirms receipt within 15 minutes.

---

## 3. Being on-call — practical rules

### 3.1 Stay reachable

- Phone on, sound on, within reach
- PagerDuty mobile app installed and notifications enabled
- Laptop in reach of home / hotel / wherever (including yachts — plan for spotty connectivity)
- Travel notice: if you'll be >30min from laptop, tell secondary; arrange handoff if needed

### 3.2 Alcohol / impairment

You're allowed a drink. You're not allowed to be unable to respond. Know your limits and know when to hand off for the night. If you think you might not be able to respond, you've already lost — hand off preemptively.

### 3.3 Sleep expectations

Paging you in the middle of the night is expected for SEV-1. SEV-2 pages between 22:00 and 07:00 UK are handled at operator discretion — some can wait until morning; some can't. If in doubt, page.

### 3.4 Secondary responsibilities

Secondary is expected to:
- Respond within 15 minutes if paged
- Be available when primary asks for help (even without a formal page)
- Cover if primary becomes unreachable

### 3.5 Duration stress

Week-long on-call is tiring. Mitigations:
- Front-load low-priority work to the off-weeks
- Keep on-call weeks light on new feature work
- If you had an SEV-1 incident, the next week off is for recovery, not extra projects

---

## 4. First 5 minutes of a page — the checklist

When PagerDuty pages you, the first 5 minutes matter more than any other 5 minutes in the incident. This is your muscle memory.

```
□ 1. Acknowledge the PagerDuty alert (this stops escalation)
□ 2. Open the Slack #incidents channel
□ 3. Read the alert description fully — don't assume
□ 4. Check: is this a real incident or a false positive?
     → If false positive, mute + file a bug against the alert rule
     → If real, continue
□ 5. Declare in #incidents: "Declaring SEV-X: [one-line summary]"
□ 6. Open Grafana → the right dashboard for the affected component
□ 7. Open Loki → the right query for recent errors
□ 8. If SEV-1 or SEV-2: page secondary from PagerDuty
□ 9. Start the incident timeline thread
□ 10. If still assessing after 5 min, post update: "Still investigating; known scope is..."
```

Laminated wallet-size copy of this checklist should be in each on-call person's bag. Yes, really. A paper checklist read under stress beats trying to remember.

---

## 5. Tools on-call needs access to

An on-call person must have (verified before their first shift):

| Tool | Purpose | Access type |
|---|---|---|
| PagerDuty | Receiving pages, ack/resolve incidents | User account |
| Slack | `#incidents`, `#on-call`, tenant channels | Member |
| Statuspage.io | Update public status page | Editor role |
| Grafana | Metrics dashboards | Operator role |
| Loki (via Grafana) | Log queries | Operator role |
| AWS Console | KMS, DynamoDB, S3 | Restricted IAM role (see §5.1) |
| Hetzner Cloud Console | Server management, load balancer | Limited operator access |
| Cloudflare | WAF rules, DNS, under-attack mode | Operator role |
| Stripe | Incident-related refund/credit processing | Support role |
| Clerk | User session revocation, org management | Admin |
| GitHub | Rollback deploys, review suspicious commits | Admin for `intelforce-*` orgs |
| Temporal UI | Workflow debugging and manual retry | Operator |
| Dashboard `/admin/*` | Platform operator UI | `platform_admin` role |
| SSH to platform hosts | Emergency direct access | Bastion via Tailscale |
| 1Password shared vault | Shared credentials, TOTP backups | Team member |

### 5.1 Restricted AWS IAM role for on-call

Read-heavy; write-only for incident-response actions. Explicitly can:
- Read any CloudWatch log
- Read KMS key metadata (not key material)
- Read DynamoDB items, write to `secrets-vault` table only for emergency revocations
- Read S3 audit log buckets
- Trigger EBS snapshot restores

Explicitly cannot:
- Delete KMS keys
- Modify IAM policies
- Touch RDS instances destructively (cluster modifications require two-person approval)
- Exfiltrate large data (CloudTrail alerts on unusual query volume)

See Phase 3 secrets-vault spec §7 and observability spec §9 for the underlying policy.

---

## 6. First-day-on-call training

Before someone takes their first real shift, they must have:

- [ ] Shadowed at least one full week on-call with a current rotation member
- [ ] Responded to at least one practice incident (game day, see incident-response §15)
- [ ] Walked through every runbook in `runbooks/` and understood the decision points
- [ ] Access verified to every tool in §5
- [ ] PagerDuty test-paged themselves and confirmed receipt
- [ ] Met every member of the platform team (so "who do I call" is resolvable)
- [ ] Read the incident-response-runbook.md end-to-end
- [ ] Read `compliance/breach-response-runbook.md` end-to-end (even if never invoked)

Shadow week first, solo later. Never: "you're on-call starting tomorrow, here's the runbook, good luck."

---

## 7. Weekly review — operator house-keeping during an on-call week

On-call isn't just reactive. During the week, the primary should:

### 7.1 Monday: review the dashboard

- Platform-wide costs trending as expected?
- Any stale postmortem action items >30 days?
- Any tenants at >80% budget already (early-month)?
- Any integrations showing repeated errors in the Activity log?

30 minutes.

### 7.2 Throughout: triage non-paging alerts

Some alerts are WARN not CRIT — they arrive in Slack but don't page. The on-call primary is responsible for triaging them:
- Is the alert real? (Same "false positive?" filter as pages)
- Does it need action now, this week, or later?
- Does it warrant upgrading to CRIT?

Batched triage is fine — once a day is sufficient for WARN.

### 7.3 Friday: capacity check

30-minute review:
- Any systems trending toward capacity limits? (disk, RAM, Postgres connections)
- Any deployments queued for next week that could affect stability?
- Has the secondary been briefed on anything unusual?

Output: a short Slack message in `#on-call` summarising the state for the next primary. Reduces Monday handoff friction.

---

## 8. Compensation and sanity

### 8.1 What being on-call costs you

An honest accounting:
- ~3–5 hours of direct incident work per week on average (much less most weeks, much more during incidents)
- Mental overhead of "I could be paged any moment" — this is the real cost
- Reduced ability to travel, drink, or be off-grid during shift

### 8.2 What you get

- Equity in the company that benefits from your reliability work
- Relatively low baseline — most weeks will have zero incidents
- First dibs on the off-week for recovery
- Direct influence on incident-prevention and runbook improvements

### 8.3 If on-call is unsustainable

If a rotation member is burning out, the signal is clear: their response quality drops, they miss handoff meetings, they describe the week as "awful."

Action: reduce their rotation frequency immediately. This is a warning sign to address directly, not something to push through for sprint dates.

Long-term, we budget for a dedicated platform engineer hire somewhere between tenant #20 and tenant #40 to reduce rotation load per person.

---

## 9. Paging someone who's off

### 9.1 Escalation tree (PagerDuty)

1. Primary (5 min to ack)
2. Secondary (5 more min)
3. Tertiary if exists (5 more min)
4. CTO / founder fallback (5 more min)
5. External SRE contractor (if on retainer; v1 we don't have this)

Total from first alert to founder page: ~20 minutes. Usually resolved at step 1.

### 9.2 When to call someone's personal phone

When PagerDuty has paged without ack, and the incident severity warrants. Personal phone numbers are in 1Password shared vault, not in PagerDuty (so they don't leak in PagerDuty breaches).

### 9.3 When to wake someone up

SEV-1: always wake up. Leaving a SEV-1 unattended for hours is worse than a groggy operator.

SEV-2: operator discretion. If it's 02:00 UK and the incident isn't deteriorating, it can often wait until 07:00.

SEV-3: never wake up. Handle in business hours.

---

## 10. Shift boundaries — what on-call does NOT include

Being on-call does NOT mean:
- You're the only person who can touch production during the week. Engineers making planned changes do their own changes; on-call is reactive.
- You're expected to be chained to your desk. Normal life continues; reachability is the commitment, not continuous desk time.
- You take on all project work for the week. Dial project work back so you have capacity for incidents.
- You respond to every tenant Slack message. Tenant comms go through normal channels; on-call is for platform incidents.

---

## 11. Solo on-call scenarios

Unavoidable in v1: one person is the whole rotation. Adjustments:

### 11.1 Vacation

Arrange before departure:
- Coverage person explicitly named (Maddox covers while Jack is away, or vice versa)
- Handoff notes posted to `#on-call`
- PagerDuty schedule updated for the vacation dates
- A trusted friend / contractor on retainer for true emergencies — even if they only know "how to reach [name]"

### 11.2 Illness

Post in `#on-call` as soon as you know you won't be functional. Coverage person takes over.

### 11.3 Connectivity loss (yacht, remote travel)

Known connectivity gaps must be scheduled:
- Pre-announce in `#on-call`
- Transfer pager to secondary for the gap
- Return pager when reconnected

Unscheduled connectivity loss is an incident in itself — if you fail to ack a page because the hotel wifi dropped, that's a lesson to learn (buy a backup 4G hotspot, etc.).

---

## 12. When an incident requires the whole team

Some incidents can't be handled by one on-call operator — they require every engineer plus decision-makers. Examples:
- Confirmed data breach
- Multi-hour SEV-1 without resolution in sight
- Regulatory escalation (ICO, court order)
- High-profile customer in crisis

In these cases, the IC calls "all hands" in `#incidents`. Everyone drops what they're doing and joins. Project work pauses until the incident resolves.

All-hands calls should be rare — probably 1-2 times per year. If they're happening monthly, the platform is in worse shape than the ops rotation can fix, and we need to reassess.

---

## 13. Psychological safety

Incidents are stressful. Mistakes during incidents are inevitable. The culture rule:

- No-one is punished for making a reasonable judgement call that turned out wrong
- No-one is punished for declaring an incident that turned out minor
- No-one is punished for escalating to the founder / CTO when unsure
- Mistakes are surfaced in postmortems without naming blame (see incident-response §11.3)

The only things we'd ever push back on hard:
- Not declaring an incident that should have been declared
- Skipping a handoff
- Hiding or obscuring what happened to avoid looking bad (makes the next incident worse)

Honesty beats heroics.

---

## 14. Related

- `incident-response/incident-response-runbook.md` — the flow itself
- `incident-response/severity-classification-and-comms.md` — severity rules + templates
- `runbooks/*.md` — specific component responses
- `phase-3-platform/observability/observability-spec.md` — alert sources
- `phase-5-business-legal/legal/sla-spec.md` — commitments we're measuring against
