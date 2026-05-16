# Breach Response Runbook

**The procedure for responding to a confirmed or suspected data breach — 72-hour GDPR clock, ICO notification, customer communication, evidence preservation, legal coordination.**

> **Audience:** Incident Commander during a suspected or confirmed breach. Jack, Maddox, and legal counsel are always looped in for breach incidents.
>
> **Status:** v1.0. Extends the general incident response runbook with breach-specific steps. Legal disclaimer: this runbook is ops guidance, not legal advice. Legal counsel drives the regulatory response.
>
> **Non-negotiable:** the 72-hour ICO notification clock starts when we become aware a breach has occurred, not when we finish investigating. Do not delay notification to gather more facts. Partial notification followed by detailed follow-up is acceptable and expected.

---

## 1. What counts as a breach

Under UK GDPR Article 4(12), a personal data breach is:

> "A breach of security leading to the accidental or unlawful destruction, loss, alteration, unauthorised disclosure of, or access to, personal data transmitted, stored or otherwise processed."

In our context:
- Unauthorised access to another tenant's data (RLS bypass, cross-tenant leak)
- Credentials stolen and used to access customer data
- Backup media lost (physical or digital)
- Ransomware or destructive malware touching customer data
- Accidental email containing other customers' data
- Employee accessing customer data without legitimate reason
- Third-party (sub-processor) notifying us of a breach affecting our customers
- Accidental public exposure (e.g., S3 bucket made public)

It's NOT a breach just because:
- We had a security alert that turned out to be false positive
- A tenant lost a password and asked for reset (their user's action)
- A non-customer-data system was accessed

### 1.1 Suspected vs confirmed

**Suspected breach:** signals exist but confirmation is pending.
Examples: unusual access pattern in audit log; customer reports seeing data that looks like another tenant's; employee reports a phishing attempt succeeded.

**Confirmed breach:** evidence establishes a breach occurred.

Both get SEV-1. Both invoke this runbook. The 72-hour clock starts at "aware of the breach" which is typically somewhere between suspicion and confirmation — err on the side of treating suspicion as awareness.

---

## 2. The 72-hour clock

Article 33 GDPR requires notification to the ICO (UK supervisory authority) within **72 hours** of becoming aware of a breach, where feasible. If later than 72 hours, reasons for the delay must accompany the notification.

### 2.1 What "aware" means

Per ICO guidance, "aware" = we have a reasonable degree of certainty that a security incident has occurred and led to personal data being compromised.

- An anomaly in the audit log: not yet aware
- Customer report of seeing another tenant's data: aware (strong signal)
- Forensic confirmation: definitely aware

### 2.2 The clock in practice

Capture the `aware_at` timestamp the moment someone on the team has reasonable belief. Don't shop around for a later timestamp. Document the reasoning:

```
aware_at: 2026-04-23 14:32 UTC
reason: customer support ticket from [tenant A] reporting seeing
a draft containing [tenant B]'s client names; preliminary check
of audit_log shows [specific event]; high confidence this is real.
```

The 72 hours runs from that moment.

### 2.3 If we're late

Article 33(1) permits later notification if we explain why. "We were investigating thoroughly" is NOT a valid reason — GDPR expects preliminary notification within 72h even if details are incomplete.

Valid reasons (rare):
- System downtime prevented us from submitting
- Legal counsel required 24-hour review before submission

If we're going to be late, document why in the notification itself.

---

## 3. First hour — stabilise and preserve

### 3.1 Declare SEV-1

Per incident response runbook. Additionally:

```
□ 1. IC declares SEV-1 breach
□ 2. Invoke breach runbook (this document)
□ 3. Page Maddox AND Jack AND legal counsel (via 1Password emergency contact)
□ 4. Create private Slack channel: #breach-YYYY-MM-DD
     (separate from #incidents so breach-specific comms are contained)
□ 5. Start timeline document
□ 6. Pin #breach channel's declaration message
```

### 3.2 Evidence preservation — before anything else

The instinct is to fix the problem. Fight that instinct. For 5-10 minutes, preserve evidence first:

```
□ 1. Snapshot audit_log tables for the relevant time period
   → SELECT * FROM ops.audit_log WHERE created_at > X INTO OUTFILE ...
□ 2. Snapshot pg_stat_activity if process-level investigation matters
□ 3. Dump relevant Loki logs for the time window
   → These have 90-day retention; still, copy to preservation folder
□ 4. Copy relevant systemd journal from platform hosts
□ 5. Note the affected user sessions (Clerk session IDs)
□ 6. Screenshot the reporting customer's original complaint
□ 7. Note any running processes on affected hosts (ps output)
□ 8. Store all of the above in /vault/breach-evidence/YYYY-MM-DD/
   → Encrypted; hash-verified; read-only after capture
```

Why this matters: during containment, logs age out and processes change. Evidence captured in the first 10 minutes is often the only record of what actually happened.

### 3.3 Containment

After evidence preservation:

```
□ 1. If attacker access is ongoing, shut it down:
   - Revoke compromised credentials
   - Disable affected user accounts (Clerk)
   - Suspend tenants where compromise involves their data
   - Block suspicious IPs at Cloudflare
□ 2. If tenant data is spreading, stop the spread:
   - Disable affected agents
   - Quarantine webhooks
   - Suspend the leaking outputs
□ 3. If backups are compromised:
   - Isolate backup infrastructure
   - Use Backblaze cold copies for reference
```

---

## 4. First 24 hours — assess and notify

### 4.1 Assess scope

Work with legal counsel and technical lead to determine:

- **Nature of breach:** what happened? (confidentiality, integrity, or availability?)
- **Personal data categories:** names, emails, messages, financial, special categories?
- **Data subjects affected:** how many? who? (approximate if exact counts take time)
- **Likely consequences:** what can bad actors do with this data?
- **Measures taken:** how have we stopped further damage?

These map directly to ICO notification fields.

### 4.2 Legal counsel drives regulatory response

Legal counsel (our retained UK commercial / data protection solicitor) decides:
- Whether ICO notification is required
- Whether notification to individuals is required
- Whether notification to specific customers is required (outside ICO)

Our job: provide accurate technical facts quickly. Their job: interpret the regulatory requirements.

### 4.3 ICO notification (within 72 hours)

Done by legal counsel using ICO's online notification form. Required content (per Article 33(3)):
- Nature of the breach
- Categories and approximate number of data subjects
- Categories and approximate number of records
- Name and contact of DPO (if any) or the person who can provide info (Maddox)
- Likely consequences
- Measures taken or proposed

If not all information is available within 72 hours, submit what we have and update later (Article 33(4) allows phased notification).

### 4.4 Do we notify affected individuals?

Article 34 requires notification to affected data subjects when the breach is "likely to result in a high risk" to them. High risk = could lead to discrimination, identity theft, fraud, financial loss, damage to reputation, loss of confidentiality of professional secrets.

Legal counsel decides. General framework:
- Leak of names + emails: usually not high risk
- Leak of financial info, ID numbers, sensitive business info: usually high risk
- Leak that could identify protected categories: almost always high risk

If notification is required, timeline is "without undue delay" — typically within 72 hours of the breach, same as ICO.

### 4.5 Customer (tenant) notification

Beyond GDPR, our DPA obligates us to notify tenants of breaches affecting their data without undue delay. Per the DPA template Section 9:
- Notification within 24 hours of awareness
- Written notice with available details
- Periodic updates as investigation progresses

This is separate from (and usually quicker than) regulatory notification.

---

## 5. Notification templates

### 5.1 ICO notification (drafted by legal counsel)

Template provided by legal counsel; submitted via ICO's online form. Not reproduced here — the form is self-guiding.

### 5.2 Initial tenant notification (for DPA compliance)

Subject: **[URGENT] Data incident involving your Clawd account**

```
Dear {{tenant admin}},

We are writing under our Data Processing Agreement to inform you
that a data incident may affect data processed on your behalf.

What we know right now:

- Time we became aware: {{time}} UTC
- Nature of incident: {{high-level description, no speculation}}
- Preliminary assessment of scope: {{what data may be involved,
  approximate count}}
- Measures taken: {{specific actions: suspension, rotation, etc.}}
- Current status: {{ongoing investigation}}

What we don't yet know:
{{honestly list the unknowns}}

We're investigating urgently and will update you within 24 hours.

If you are obligated to notify end-customers or regulators, use the
information above as your factual basis. We'll support your response
as required.

Questions: reply to this email or call {{emergency number}}.

- {{name}}, Clawd
```

Short, factual, no minimisation language, no legal hedging beyond what's strictly necessary.

### 5.3 Individual notification (if required by Article 34)

Usually done by the tenant (as data controller) with our support. Their customer relationship; their message. We provide facts.

If we're required to notify individuals directly (rare; usually only when we can't identify them through tenants):

```
Hello,

We are writing to notify you of a data incident that may have involved
personal data about you.

What happened: {{plain language}}
When: {{date range}}
What data was involved: {{specifics}}
What we've done about it: {{containment}}
What we recommend you do: {{specific actions if any - e.g., monitor
  for phishing attempts}}

If you have questions, contact us at privacy@clawd.ai.

If you'd like to make a formal complaint about this incident, you
can contact the Information Commissioner's Office (ICO) at
ico.org.uk or 0303 123 1113.

- The Clawd team
```

Always include ICO contact details — it's a regulatory requirement.

### 5.4 Public statement (if warranted)

Most breaches don't warrant public statements. High-profile ones might (especially if media coverage is possible).

Done by legal counsel + Maddox. Characteristics:
- Acknowledges the incident
- Doesn't minimise
- Describes what we're doing
- Avoids blame
- Points affected people to where they can get help

Template in `/vault/breach/public-statement-template.md`.

### 5.5 What NOT to put in any breach communication

- Minimising language ("small incident", "might have affected a few records")
- Blame (employees, providers, anyone)
- Uncertain scope presented as certain
- Legal dismissiveness ("no data was lost" when we don't know)
- Apologies as boilerplate (one sincere apology at the right moment is enough)
- Technical jargon (postgres, RLS, etc.)
- Promises we can't keep ("this will never happen again")

---

## 6. Internal comms during a breach

### 6.1 #breach-YYYY-MM-DD channel

Everything breach-related stays in this private channel:
- Limited membership: IC, technical lead, Maddox, Jack, legal counsel, commercial lead
- Never forwarded / screenshot outside
- Archived after incident resolution

### 6.2 Team-at-large

Team members outside the breach channel know "there's an incident; don't ask" until the IC briefs them. Common sense principle, but explicit.

### 6.3 Slack hygiene

- Don't discuss the breach in general channels
- Don't tag customers in DMs with breach news
- Don't share screenshots of investigation in informal channels

### 6.4 Commercial / customer team

Account owners (Maddox / Jack) are briefed on what to say to customers who ask. Key messages consistent across channels. Detailed pointer: "we can confirm the incident but cannot share details that might affect our investigation."

---

## 7. Forensics

For confirmed breaches, proper forensic investigation is warranted. For v1 we don't have in-house forensics expertise; we engage a retained forensics firm.

### 7.1 Retained forensics firm

On retainer (lightweight — a few hours of availability per year) with a UK digital forensics firm. Engagement terms pre-negotiated to reduce mobilisation time.

### 7.2 When to engage

- Confirmed breach with any data subject impact
- Ransomware or destructive attack
- Suspected insider threat

### 7.3 What forensics provides

- Preserving evidence in court-admissible form
- Technical analysis of attack method
- Identifying extent of access
- Recommendations for remediation
- Expert witness if litigation results

Their work feeds the postmortem and any regulatory response.

### 7.4 Cost

Expect £5,000-£20,000 for a moderate breach engagement. Larger for complex ones. Budget allocated in annual ops budget.

---

## 8. Rotation after breach

After breach containment:

### 8.1 Emergency rotation of all potentially-exposed secrets

Per `routines/secret-rotation-runbook.md` §5. Skip dual-window; accept brief outage.

- All platform-level API keys
- Postgres passwords
- Clerk secret keys
- Stripe keys
- Cloudflare tokens
- Hetzner tokens
- Any tenant secret potentially exposed (coordinated with tenant)

### 8.2 Credential stripping

- Revoke all active sessions (Clerk bulk revoke)
- Force password reset for all users
- SSH keys on platform hosts reviewed / rotated
- MFA factor reset for affected accounts

### 8.3 Vault content review

- Was any content in vault repos exposed?
- If yes: tenants are notified; content is reviewed for sensitivity
- git-filter-repo if vault history needs rewriting

---

## 9. Post-breach — the long tail

### 9.1 Detailed postmortem

Per incident response runbook, but with additional depth for breaches:
- Complete attack timeline
- Root cause with 5-whys
- Controls that failed (and why)
- Controls that could have prevented
- Detection gaps — how did this get past monitoring?
- Recovery assessment

Legal counsel reviews before publication (internal or external).

### 9.2 Remediation tracking

Action items from the postmortem are tracked in Linear with:
- Owner + due date (per normal)
- Also: approved by legal counsel (for any that relate to regulatory commitments)
- Reviewed monthly until complete

### 9.3 Regulator follow-up

ICO may request updates beyond the initial 72-hour notification. Legal counsel handles:
- 30-day update (common)
- Additional information as scope becomes clear
- Technical questions from ICO staff
- Formal response to any investigation

### 9.4 Customer relationship work

Beyond the immediate notification, the commercial team:
- Personal outreach to affected customers
- Compensation discussions (service credits, free months, commercial goodwill)
- Trust rebuilding (especially for customers considering churn)

Some customers will churn regardless. Handle graciously. Don't fight unreasonable refund requests from visibly-affected customers.

### 9.5 Media / PR

Most breaches won't attract media attention. Large ones might:
- Reactive, not proactive PR
- Spokesperson: Maddox or external PR firm
- Response consistent with public statement (§5.4)
- Media inquiries routed through legal counsel first

### 9.6 Insurance

Cyber liability insurance (budgeted for year 2; v1 is uncovered). When active:
- Notify insurer within policy-specified timeframe (usually 48-72 hours)
- Insurer may provide forensics, PR, legal services
- Their playbook supersedes ours in some scenarios

### 9.7 Learn and harden

The most valuable output: specific, concrete changes that make the same class of breach harder.

Not: "be more careful"
But: "add specific alert when X pattern occurs", "restrict Y access to require two-person approval", "deploy Z technical control"

---

## 10. Special breach scenarios

### 10.1 Ransomware

Rare but high-impact. Approach:
1. Immediate: isolate affected systems (network disconnect)
2. Do NOT pay ransom without legal counsel + law enforcement + insurance input
3. Activate DR from Backblaze B2 cold backups (pre-ransomware)
4. Contact NCA (National Crime Agency) or National Cyber Security Centre (NCSC)
5. Forensics engagement mandatory
6. Expect multi-day recovery

### 10.2 Insider threat

Employee or contractor acting maliciously:
1. HR consulted immediately
2. Revoke all access (IT + physical)
3. Forensics engagement
4. Legal counsel for employment-law angle + criminal-law referral if appropriate
5. Notify law enforcement if criminal activity

### 10.3 Sub-processor breach

A sub-processor (Anthropic, Clerk, etc.) notifies us of their breach affecting our data:
1. Invoke this runbook
2. Assess which of our tenants' data was affected
3. Notify affected tenants per DPA timelines
4. If our ICO notification is required (possible), we notify
5. Evaluate whether sub-processor's handling was adequate; consider relationship impact

### 10.4 Physical security incident

Laptop with data stolen:
1. Figure out what was on the laptop (hopefully nothing sensitive — laptop hygiene)
2. Revoke credentials the laptop had access to
3. If sensitive data was local + unencrypted: treat as breach per §1
4. Crime report (for insurance and potential recovery)

Our laptop hygiene policy: encrypted disk, no local copies of sensitive data, session-based auth for platform access. With these, laptop theft is usually NOT a breach.

---

## 11. What makes this runbook work

Three things:

### 11.1 Preservation before fix

Without evidence, we can't investigate honestly, notify accurately, or learn fully. First 10 minutes of evidence capture pay off for years.

### 11.2 Clock discipline

The 72-hour clock is a forcing function. It prevents "we'll investigate a bit more first" paralysis. Pre-drafted notification templates + pre-engaged legal counsel mean we CAN meet it.

### 11.3 Separation of concerns

- IC handles the technical fix
- Legal handles the regulatory response
- Commercial handles the customer relationship
- No single person does all three under breach stress

---

## 12. Preventive — what makes breach less likely

This runbook is the emergency; prevention is the primary defence:

- Tenant isolation via RLS (Phase 3)
- Secrets vault with per-tenant CMKs (Phase 3)
- Defence-in-depth access controls (Phase 4 auth spec)
- Weekly restore tests confirming backup integrity
- Quarterly secret rotation
- Penetration testing (annually; roadmap item for post-launch)
- Security training for team (onboarding + annual)
- Public bug bounty (v2 consideration; post-launch)

Most of these show up in other Phase 3/4/6 documents. They're why most breaches never happen.

---

## 13. Never do during a breach response

- Delay ICO notification past 72 hours without explicit legal basis
- Send minimising language to customers or regulators
- Delete evidence (even "unrelated" logs)
- Discuss breach in public channels / social media
- Apologise through personal channels without coordinating with legal
- Admit fault in writing without legal review (common-law "apology" = admissible)
- Accept an attacker's offer of "keep paying us, we won't release"
- Inform competitors or public before regulators
- Wing notification content without legal review

---

## 14. Related

- `incident-response/incident-response-runbook.md` — extended by this document
- `incident-response/severity-classification-and-comms.md` — severity flow
- `compliance/gdpr-dsar-and-deletion-runbook.md` — if a DSAR surfaces a breach
- `routines/secret-rotation-runbook.md` — emergency rotation called from here
- `phase-5-business-legal/legal/dpa-template.md` — DPA obligations this implements
- `phase-5-business-legal/legal/msa-template.md` — MSA breach-related clauses (liability, notification)
- `phase-3-platform/postgres/schema-spec.md` — audit_log schema for evidence
- `phase-3-platform/observability/observability-spec.md` — log retention for evidence
