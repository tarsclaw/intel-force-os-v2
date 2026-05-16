# GDPR DSAR and Deletion Runbook

**How we handle Data Subject Access Requests (DSARs), erasure requests, and tenant off-boarding deletion — within GDPR's 30-day statutory response window and across every system that holds customer data.**

> **Audience:** operator handling a DSAR or erasure request. Also: Maddox or Jack as the legally accountable party when the request involves edge cases.
>
> **Status:** v1.0. Matches the DPA in `phase-5-business-legal/legal/dpa-template.md` Annex A and the Privacy Policy in `phase-5-business-legal/legal/privacy-and-terms-spec.md`.
>
> **Non-negotiable:** 30 calendar days for response. No excuses. Missing the deadline is an ICO-reportable incident.

---

## 1. What counts as a DSAR

Any request from an individual asking us to:

### 1.1 Access (Article 15)
"What personal data do you have about me?" — we produce a copy of all personal data we hold, plus metadata (sources, sharing, retention).

### 1.2 Rectification (Article 16)
"This data about me is wrong; correct it." — we correct factual errors.

### 1.3 Erasure / "Right to be forgotten" (Article 17)
"Delete all my data." — we erase personal data, subject to legal-basis exceptions.

### 1.4 Restriction (Article 18)
"Stop processing my data" — we stop processing (but may retain).

### 1.5 Portability (Article 20)
"Give me my data in a portable format" — we export in structured, commonly-used format.

### 1.6 Objection (Article 21)
"Stop using my data for [specific purpose]" — we stop that specific processing.

### 1.7 Automated decision-making (Article 22)
"Don't subject me to solely-automated decisions" — not heavily relevant to us (our platform drafts; humans decide), but covered.

---

## 2. Who can make a DSAR

Under GDPR, any data subject can make a DSAR directly to us. In practice, we receive DSARs from three sources:

### 2.1 Our customers' end customers

Most DSARs reach us this way: a data subject contacts our customer (the tenant), who forwards it to us as the data processor.

The tenant is the data controller; they drive the response to the individual. We, as processor, do the work on their instruction per our DPA.

Timeline: tenant has 30 days from receipt. They typically ask us for data within the first 14 days so they have time to review and respond.

### 2.2 Platform users (tenant staff)

A person logged into the dashboard makes a request about their own Clawd account data (not customer data). We respond directly.

### 2.3 Direct external requests

Someone emails privacy@clawd.ai asking about data we hold. Unusual but possible — might be:
- Someone who thinks they're in our system but we're not processing their data
- Someone whose data we have via a tenant but they're going around the tenant

Route these to the correct tenant where applicable.

---

## 3. The DSAR intake flow

### 3.1 Receive the request

DSARs arrive via:
- `privacy@clawd.ai` — monitored by Maddox daily
- Dashboard contact form → routed to `privacy@`
- Direct email to any team member (must be forwarded to `privacy@` within 24 hours)

**The 30-day clock starts on receipt by Clawd**, not on assignment to a specific person. A DSAR sitting in someone's inbox for 5 days is 5 days lost.

### 3.2 Initial triage (day 1)

Within 24 hours of receipt:

```
□ 1. Log the DSAR in `ops.dsar_requests` table with:
   - Received timestamp
   - Requester email
   - Request type (access/erasure/etc.)
   - Originating channel (privacy@, dashboard, forwarded)
   - Assigned handler (usually Maddox by default)
   - Deadline (30 calendar days from receipt)
□ 2. Acknowledge receipt to requester within 72 hours
   - Template email: "We've received your request and will respond within 30 days"
   - If identity isn't obvious, ask for verification (see §4)
□ 3. Notify affected tenant (if request is tenant-routed) in #customer-privacy Slack
□ 4. Set a calendar reminder at day 21 (escalation trigger)
□ 5. Set a calendar reminder at day 27 (final push)
```

### 3.3 Acknowledgement email template

```
Hello {{name}},

We've received your data subject request dated {{date}} regarding
{{request type}}.

We'll respond fully within 30 calendar days. If we need more time
(permitted under GDPR Article 12 for complex requests), we'll let
you know before the 30-day deadline.

If we need to verify your identity before we can proceed, we'll
follow up within 5 business days.

If you have any questions in the meantime, reply to this email.

Best regards,
Clawd Privacy Team
privacy@clawd.ai
```

### 3.4 Identity verification

Before producing any data, we verify the requester is who they say they are.

**Simple cases (email match):** the request comes from an email address already associated with the data subject in our system.

**Harder cases:** requester emails from a different address. We ask for one of:
- A copy of identification (passport / driver's licence, with sensitive numbers redacted)
- Confirmation from a known email address associated with the account
- Answer to a security question only the account holder would know

Never produce data to a requester whose identity we can't reasonably verify. Article 12(6) explicitly allows us to refuse requests where identity is unclear.

---

## 4. Handling an Access (Article 15) request

Most common DSAR type. "What data do you have about me?"

### 4.1 Gather the data

Personal data about the requester may be in:

| System | What to check |
|---|---|
| Postgres control.* | Users, tenants, audit_log entries, invocations (if they were a requester) |
| Postgres tenant_*.* | Tenant-specific data where their info appears |
| Secrets vault | Very rare; usually tenant-owned |
| S3 audit logs | Search for their user_id, email |
| Tenant vault repos | Content mentioning them (sales notes, emails drafted) |
| Anthropic logs | Requests that may have included their name (see §5 about third parties) |
| Cohere logs | Same |
| Stripe | If they're a billing contact |
| Clerk | If they had a dashboard account |
| Postmark / email provider | Emails sent to/from them |
| Cal.com | Meeting bookings |

This is a lot of systems. We have a semi-automated DSAR search tool that runs SQL queries + S3 searches for a given identifier.

### 4.2 DSAR search tool

`scripts/dsar/gather.sh` takes a requester email and outputs:
- A structured JSON report of all matching data
- Supporting files (vault entries mentioning them, audit log entries, etc.) in a ZIP
- A completion checklist showing which systems were searched

Runtime: 15-30 minutes for a typical request. Longer if the person appears in many tenants' vaults.

### 4.3 Review and redact

Before sending, a human reviews the output. Checks:

- Data about OTHER people mixed in? Redact those bits. An email where requester is just copied on doesn't entitle them to the full thread.
- Sensitive metadata? Usually fine to include but flag any surprises.
- Data the requester WOULDN'T recognise as about them? Explain with context.

### 4.4 Third-party data concerns

If data exists because a tenant uploaded it (e.g., Proposal Builder drafts that mention the requester):
- Notify the tenant: "We've received a DSAR; some data about this individual exists in your tenant"
- Coordinate on response (who discloses what)
- Their DPA with us covers this scenario

### 4.5 Response format

Data provided in:
- JSON (machine-readable, for portability)
- PDF (human-readable, with plain-language explanation)
- Included: a cover letter explaining where data came from, how we used it, who we shared it with, retention schedule

Delivered via encrypted email or secure download link.

---

## 5. Handling an Erasure (Article 17) request

### 5.1 Evaluate eligibility

Erasure is NOT absolute. We can refuse if:
- We need the data for legitimate legal obligations (e.g., invoices for HMRC 6-year retention)
- The data is needed for establishing, exercising, or defending legal claims
- The individual hasn't verified identity

Default position: err on the side of erasing unless there's a clear reason not to.

### 5.2 Scope of erasure

When erasing, we cover:
- Postgres control.* rows (user, audit entries, etc.)
- Postgres tenant_*.* rows where requester is directly identified
- S3 audit logs (marking for deletion, see §5.4)
- Secrets vault entries (if any)
- Vault content (git repos) — git history re-written to remove
- Third-party providers (see §5.5)
- Clerk user account (if they had one)
- Stripe customer (if they were a billing contact — but NOT if they're an end customer of our tenant; that's the tenant's responsibility)
- Email provider — past emails remain (immutable) but they're removed from active lists

### 5.3 Cross-system erasure checklist

```
□ 1. Postgres main DB — delete/anonymise
□ 2. Postgres tenant schemas — delete/anonymise
□ 3. S3 audit logs — queue deletion (7-year retention exception may apply)
□ 4. Secrets vault — identify and delete relevant entries
□ 5. Vault git repos — rewrite history to remove
□ 6. Third-party: Anthropic, Cohere logs (request their deletion)
□ 7. Clerk user — delete via API
□ 8. Stripe customer — delete via API (if applicable)
□ 9. Postmark / email provider — remove from audiences
□ 10. Local backups — mark for natural expiration (see §5.7)
□ 11. Offline backups — log for future re-process at restore time
□ 12. Confirm all with requester
```

### 5.4 S3 audit logs

Audit logs may have 7-year retention for compliance reasons. We can't just delete them. Approach:
- Anonymise the requester's identifiers where present (replace with hash-of-id)
- Keep the log structure intact (still proves our audit trail)
- Document the anonymisation in the DSAR response

### 5.5 Third-party providers

Our DPA requires sub-processors to support erasure. In practice:

| Provider | Erasure mechanism |
|---|---|
| Anthropic | API: data deletion request; retention SLA per their DPA |
| Cohere | Same; via their privacy team |
| Clerk | `clerkClient.users.deleteUser(userId)` |
| Stripe | `stripe.customers.del(customerId)` — note: transaction records remain for tax/fraud purposes |
| Postmark | Remove from audiences + request data deletion |
| PagerDuty | We rarely have end-user data here |
| Cloudflare | Request zone-level log deletion |

Each provider has its own timeline. Most complete within 30 days.

### 5.6 Git repo history rewrite

If a vault repo contains content mentioning the requester (e.g., Proposal Builder drafts):

```bash
# Approach 1: git filter-repo (preferred for small-scale removal)
git filter-repo --replace-text replacements.txt

# Approach 2: BFG Repo-Cleaner for bulk
bfg --replace-text passwords.txt

# After either: force-push to GitHub
git push --force
```

After rewrite, existing clones of the repo retain old data. Tenant operators need to fresh-clone. Document in the DSAR response.

### 5.7 Backup handling

Backups are the hardest part of erasure. Options per GDPR guidance:

1. **Delete from backups:** usually impractical; backups are immutable artifacts
2. **Natural expiration:** the backup rolls out of retention window; data is gone
3. **Re-process on restore:** if we ever restore that backup, apply deletion rules at restore time

We use approach 2 + 3. Document in DSAR response:
> "Your data has been removed from our active systems. Existing encrypted backups will retain data until their retention period expires (up to 35 days for PITR, 90 days for vault archives). If we ever need to restore those backups, your deletion will be re-applied."

ICO guidance accepts this pattern.

### 5.8 Confirmation to requester

When erasure is complete:
- Email confirming completion
- List of systems where data was erased
- List of systems where data remains with legal basis (e.g., tax records)
- Expected timeline for backup expiration

---

## 6. Handling a Rectification (Article 16) request

Simpler than erasure. "This field about me is wrong."

### 6.1 Evaluate

Is the requester correct? Sometimes not — they may be misremembering, or the data IS accurate and they don't like it.

### 6.2 If correction is warranted

```sql
-- Direct SQL update with audit
BEGIN;
UPDATE control.users
  SET email = 'new.email@example.com',
      updated_at = now()
  WHERE id = 'usr_xxx';

INSERT INTO ops.audit_log (source, event_type, actor, subject, reason)
VALUES ('dsar', 'rectification', 'privacy-operator', 'usr_xxx', 'DSAR ticket #123');
COMMIT;
```

Propagate to third parties where applicable (Clerk, Stripe).

### 6.3 Notify downstream

If we've already shared the incorrect data with third parties (per DPA), notify them of the correction.

---

## 7. Handling Restriction (Article 18)

"Stop processing my data while I figure something out."

### 7.1 Mark the data as restricted

- Add a `processing_restricted = true` flag to the relevant records
- Platform code respects the flag (agents skip processing restricted data; analytics exclude)
- Flag remains until requester lifts or erasure is invoked

### 7.2 Processing that's still allowed

Per Article 18(2):
- With the individual's consent
- For establishing, exercising, or defending legal claims
- To protect the rights of another person
- For important public interest reasons

Document which of these applies if we continue any processing.

---

## 8. Handling Portability (Article 20)

"Give me my data in a portable format."

### 8.1 Scope

Portability applies to data:
- Provided by the individual (they typed it, uploaded it)
- Processed based on consent or contract
- Processed by automated means

Doesn't apply to:
- Data we inferred about them (derived data)
- Data we got from other sources

### 8.2 Format

Deliver in structured formats:
- JSON or CSV for structured data
- Originals for files (PDFs, images, documents they uploaded)

Use the same DSAR gather tool as Article 15 but filter for in-scope data.

### 8.3 Direct transmission (Article 20(2))

The individual may ask us to send their data directly to another controller. Technically possible but rare. Case-by-case via privacy@.

---

## 9. Handling Objection (Article 21)

"Stop using my data for [specific purpose]."

### 9.1 Common objections

- Marketing emails — honour immediately; unsubscribe processes handle most of this
- Direct marketing — cease
- Profiling for marketing — cease
- Legitimate-interest processing — we evaluate against our original LIA (Legitimate Interest Assessment)

### 9.2 Evaluation

If our original basis was legitimate interest (not consent), we reassess:
- Does our interest still outweigh the individual's right to object?
- Usually, no — honour the objection

Document the decision either way.

---

## 10. Tenant off-boarding — bulk deletion

When a tenant terminates their contract, all their data must be deleted (per MSA, Phase 5 Section 11.3).

### 10.1 Data export first (if requested)

Before deleting, the tenant can request an export of their data. Format:
- JSON dump of structured data
- ZIP of vault content
- Invoice history from Stripe
- Audit log excerpts relevant to their account

### 10.2 Decommission workflow

Provisioning System runs `TenantDecommission` workflow (per Phase 3 provisioning spec):

```
1. Agent containers stopped
2. Tenant schema dropped from Postgres
3. Vault git repo archived (tenant can download for 30 days)
4. Secrets CMK scheduled for deletion (7-day AWS window)
5. Clerk organisation deleted
6. Stripe subscription cancelled (already done pre-decommission)
7. Audit records retained per retention schedule
8. Tenant's domain/subdomain released
```

### 10.3 Grace period

30-day grace period after decommission:
- Archived vault still downloadable
- Resumable within 30 days (rare but possible)
- After 30 days: all data is gone

### 10.4 Confirmation

Tenant receives final confirmation: "Your account and data have been deleted. Some audit records retained as described. Archive download link valid for 30 days."

---

## 11. Complex DSAR scenarios

### 11.1 Requester data is mixed with other tenants' data

Example: requester was a prospect at 3 different tenants. Their data exists in 3 tenant vaults.

- Coordinate with each tenant separately
- Each tenant may respond independently (they're separate controllers)
- We handle our processor-level processing (deletion confirmation per tenant)

### 11.2 Requester is deceased

Privacy rights don't transfer at death in UK GDPR (different from some EU jurisdictions). Requests from family members are handled case-by-case:
- Accommodate reasonable requests (erasure of obviously-unnecessary data)
- Legal basis discussions for more complex requests
- Maddox or legal counsel involved

### 11.3 Law enforcement request

Entirely separate flow. Never to be confused with DSAR:
- Formal request with warrant
- Legal counsel coordinates response
- Runbook in legal counsel's remit, not in this ops runbook

### 11.4 Requester is asking about a third party

"Give me data about my ex-spouse" — we decline. DSAR applies only to the requester's own data.

### 11.5 Requester is an adversary

Sometimes DSARs are used as litigation tools or to harass. We still respond — but:
- Strict identity verification
- Legal counsel consulted
- Response is minimal (just what's required; no extras)

### 11.6 Volume DSAR (many at once)

If we receive many DSARs in a short period (breach-related, or class-action driven), timeline can be extended under Article 12(3) with notification to requesters.

---

## 12. Specific extension to 90 days

Under Article 12(3), we can extend the 30-day response to 90 days if the request is "complex or numerous." We must inform the requester within the first 30 days.

Use sparingly. Genuine complexity examples:
- Data spans many tenants; coordination takes time
- Identity verification is ongoing
- Legal review required
- System-wide data gathering involves non-standard archives

Email template for extension:

```
Hello {{name}},

Due to the complexity of your request [specific reason], we need an
additional 60 days to respond fully, in accordance with Article 12(3)
of GDPR.

We'll respond by {{extended deadline}}.

We apologise for the delay. If you have questions, reply to this
email.

Best regards,
Clawd Privacy Team
```

Do not use extensions as slack for being late.

---

## 13. ICO notification

Most DSARs don't involve ICO. However:

### 13.1 Individual complains to ICO

If the individual complains to the ICO that we didn't respond adequately, ICO contacts us:
- Response within ICO's deadline (usually 14 days)
- Legal counsel involved
- Full cooperation

### 13.2 We notify ICO of a breach (separate runbook)

If a DSAR surfaces a data incident (e.g., "I noticed someone else's data in my export"), invoke breach response runbook.

---

## 14. Evidence and record-keeping

### 14.1 Per-DSAR file

For each DSAR:
- Original request
- Identity verification artifacts
- System search outputs
- Response sent
- Confirmation correspondence
- Any extensions granted

Stored in `/vault/ops/dsar-records/YYYY/` — encrypted, 6-year retention.

### 14.2 Aggregate metrics

Annually:
- Number of DSARs received
- Breakdown by type (access/erasure/etc.)
- Median response time
- Any extensions used
- Any refusals (with reasons)

Useful for audits and for internal process improvement.

---

## 15. The "Everything drafts, nothing sends" principle and DSARs

A differentiator: because our platform drafts content for humans to review (never auto-sends), DSARs about Clawd-generated content are usually about drafts that were never actioned.

Advantage: less data has left the customer's control. A "Proposal Builder draft about {{requester}}" is typically:
- A file in the tenant's vault
- Reviewed by the tenant's operator
- Usually not sent to the requester at all

Easy to erase. Compared to systems that do auto-send, we have fewer downstream copies to track.

---

## 16. Automation roadmap

v1: largely manual. DSARs are rare (probably 1-2/month in year 1).

v1.5: semi-automated gather tool (as described in §4.2) + response templates.

v2: self-service DSAR portal for data subjects — they log in, verify, get their data automatically. Probably after first 50 tenants when volume justifies.

v3: automated erasure confirmation with per-system rollup.

---

## 17. Never do during a DSAR

- Miss the 30-day deadline (extension is allowed; ignoring is not)
- Produce data to an unverified requester
- Include third-party data in a response without redaction
- Confirm erasure before actually completing erasure across all systems
- Treat a DSAR as an inconvenience in the Slack conversation (always professional)
- Delete beyond what was asked (erasure is scoped to personal data; don't delete tenant's business data by mistake)

---

## 18. Related

- `compliance/breach-response-runbook.md` — if DSAR uncovers a breach
- `phase-5-business-legal/legal/dpa-template.md` — DPA obligations this implements
- `phase-5-business-legal/legal/privacy-and-terms-spec.md` — privacy policy DSAR commitments
- `routines/backup-verification-and-dr-drills.md` — backup handling for erasure scope
- `phase-3-platform/postgres/schema-spec.md` — where most data lives
- `phase-4-dashboard/views/settings-spec.md` — tenant-facing privacy controls
