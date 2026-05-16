# Privacy Policy & Terms of Service — Specification

**The two public-facing legal documents that live on the Clawd landing page. Different purpose from the MSA (which is between Clawd and a specific customer). These apply to anyone who visits clawd.ai or uses the Service.**

> **⚠️ STRUCTURAL TEMPLATES.**
>
> Privacy Policy language is regulated (GDPR Article 13/14). Terms of Service shape the legal relationship with everyone who touches the Service. Both must be reviewed by a UK commercial solicitor before going live on the landing page.
>
> **Audience:** founder producing the first draft; solicitor finalising; landing page designer linking these from the footer.
>
> **Status:** v1.0 templates.

---

## 1. Why these two documents exist (separate from MSA)

### Privacy Policy
Under GDPR Article 13, we must provide privacy information when we collect personal data from individuals. This applies to:
- Website visitors (via cookies, analytics)
- Prospects who fill out a contact form or request a demo
- People whose data is in our CRM, email marketing lists
- People whose data we process as a controller (not processor) — our own staff, contractors, financial records

This is separate from the DPA, which covers data we process on customers' behalf.

### Terms of Service (ToS)
Applies to everyone who uses the Service (including during trial periods before an MSA is signed) and to clawd.ai as a website. For paying customers who've signed an MSA, the MSA prevails.

### Why not combine them
They serve different legal purposes and different audiences. A prospect browsing clawd.ai wants a short, clear Privacy Policy. A 50-page combined document discourages signups. Separate + linked is the convention.

---

## 2. Privacy Policy template

The following is the template. Placeholders as usual.

---

---

# Clawd Privacy Policy

*Effective: {{effective_date}}*

*Last updated: {{last_updated_date}}*

Intel Force Ltd (trading as Clawd, "we", "us", "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your personal information.

This policy applies to:
- Visitors to clawd.ai and related websites
- Individuals who contact us or request a demo
- Users of the Clawd platform (the "Service")
- Our customers' designated contact persons (in our role as a controller for our own business purposes)

It does NOT apply to personal data processed by Clawd on behalf of our customers (where our customers are the data controllers and we're a processor). That relationship is governed by our Data Processing Agreement with the customer.

## 1. Who we are

Intel Force Ltd is a company registered in England and Wales, company number {{company_number}}, with registered office at {{registered_address}}.

For privacy matters, contact: privacy@clawd.ai

## 2. What data we collect

### 2.1 When you visit clawd.ai

- Device and browser information (IP address, user agent, screen resolution)
- Pages viewed, duration, navigation path
- Referrer (the page that sent you)
- Cookies and similar technologies (see §5)

### 2.2 When you contact us or request a demo

- Your name, business email, company, role
- The content of your inquiry
- Metadata of any calendar booking (time, meeting details)

### 2.3 When you become a customer or trial user

- Account information (email, name, organisation)
- Billing and payment information (processed by Stripe — we don't store full card details)
- Authentication data (multi-factor authentication status, session tokens)
- Usage data about your use of the Service (log-ins, feature usage, support interactions)

### 2.4 What we don't collect

- Data stored in your Vault or processed by agents in your tenant — that's your data; our role there is as a processor governed by the DPA
- Full payment card numbers (Stripe handles payment; we see only token references and masked last four digits)
- Special category data (Article 9 GDPR) — we don't solicit or process this in our own controller capacity

## 3. Why we collect it (lawful bases)

| Purpose | Data used | Lawful basis |
|---|---|---|
| Running the website | Device and browsing data | Legitimate interest (providing a functioning website) |
| Responding to your inquiry | Contact data, inquiry content | Legitimate interest (commercial relationship) or Contract (pre-contractual steps) |
| Providing the Service | Account, authentication, usage data | Contract (performing our contract with you) |
| Billing and payment | Billing data | Contract; Legal obligation (accounting) |
| Marketing (emails, events) | Contact data | Consent (you can opt out anytime) or Legitimate interest in B2B context |
| Analytics and service improvement | Aggregated usage data | Legitimate interest (improving the Service) |
| Security and fraud prevention | Authentication data, IPs, behavioural data | Legitimate interest; Legal obligation |
| Compliance with law | Whatever is needed for legal requests | Legal obligation |

## 4. Who we share it with

### 4.1 Service providers (processors)

We share data with service providers who help us run the Service:

- **Hosting:** Hetzner (UK), AWS (UK)
- **AI model provider:** Anthropic
- **Embeddings:** Cohere (EU)
- **Authentication:** Clerk (EU)
- **Payment:** Stripe (EU + US)
- **Analytics:** {{analytics_provider}} (to be chosen — privacy-focused tool like Plausible or Fathom)
- **Email:** {{email_provider}} (Resend, Postmark, or similar)
- **CRM and business operations:** our own use of tools (HubSpot, Linear, etc.)
- **Status page:** Statuspage.io

All service providers are bound by data-protection agreements.

### 4.2 Customers and their authorised users

If you're a designated contact of a Clawd customer, data about you (role, contact info, activity within the Service) is shared with your customer organisation.

### 4.3 Legal requests

We disclose data where:
- Required by law or valid legal process
- Necessary to investigate potential violations of our AUP
- Necessary to protect rights, property, or safety

### 4.4 Corporate events

If Clawd is sold, merged, or involved in a similar transaction, we may transfer data to the acquiring entity (subject to this Privacy Policy continuing to apply).

### 4.5 We don't sell your data

Plain statement: we do not sell personal data. We don't share personal data with third parties for marketing purposes other than our own.

## 5. Cookies

We use:
- **Strictly necessary cookies** (authentication, security, session management) — no consent needed under UK law
- **Functional cookies** (remembering preferences) — set with consent via cookie banner
- **Analytics cookies** (understanding aggregated usage) — set with consent via cookie banner

We do NOT use:
- Advertising cookies
- Third-party tracking cookies
- Fingerprinting technologies

You can manage cookies via your browser or our cookie banner. Rejecting analytics cookies doesn't affect the functionality of the Service.

## 6. Data retention

| Data | Retained |
|---|---|
| Website analytics | 12 months rolling (aggregated indefinitely) |
| Contact form inquiries | 2 years from last interaction |
| Customer account data | Duration of the contract + 90 days |
| Billing records | 7 years (UK accounting/tax requirements) |
| Security logs | 12 months hot, 6 years cold (for audit and legal purposes) |
| Marketing list | Until you unsubscribe, plus 6 months for suppression lists |

Data beyond these periods is deleted or irreversibly anonymised.

## 7. International transfers

Clawd primarily stores data in the UK. Where transfers outside the UK occur (e.g., Anthropic's US processing, Stripe's US processing), we use the UK International Data Transfer Agreement (IDTA) or the UK Addendum to the EU Standard Contractual Clauses to ensure appropriate protection.

## 8. Your rights

Under UK GDPR, you have the right to:
- **Access** your personal data
- **Rectify** inaccurate personal data
- **Erase** your personal data (subject to legal retention requirements)
- **Restrict** or **object** to processing
- **Data portability** — receive your data in a structured, commonly used format
- **Withdraw consent** for processing based on consent
- **Lodge a complaint** with the UK Information Commissioner's Office (ico.org.uk)

To exercise rights, email privacy@clawd.ai. We respond within 30 days (may extend to 60 days for complex requests, with notification).

## 9. Security

We protect personal data with:
- Encryption in transit (TLS 1.3)
- Encryption at rest (disk-level, and KMS-managed encryption for sensitive fields)
- Multi-factor authentication for all internal access
- Access controls aligned with least-privilege
- Regular security review and testing

See the DPA Annex A for the full technical and organisational measures applicable to customer data.

## 10. Children

The Service is not for children under 18. We don't knowingly collect data from children. If we discover we have, we delete it.

## 11. Changes

We may update this policy. Material changes are notified by email to registered users and announced on the website at least 30 days before taking effect.

## 12. Contact

- **Privacy questions:** privacy@clawd.ai
- **Data protection complaints:** privacy@clawd.ai; or to the UK ICO (ico.org.uk)
- **Postal:** Intel Force Ltd, {{registered_address}}

---

*This Privacy Policy is written to comply with UK GDPR. It does not substitute for professional legal advice on your specific circumstances.*

---

---

## 3. Terms of Service template

The following is the public Terms of Service template.

---

---

# Clawd Terms of Service

*Effective: {{effective_date}}*

*Last updated: {{last_updated_date}}*

These Terms of Service ("Terms") govern your use of clawd.ai and the Clawd Service (the "Service"), provided by Intel Force Ltd (trading as Clawd, "we", "us", "our").

By accessing clawd.ai, signing up for a trial, or otherwise using the Service, you agree to these Terms.

**If you are using the Service as a customer under a Master Services Agreement (MSA), the MSA takes precedence over these Terms to the extent of any inconsistency.**

## 1. Who we are

Intel Force Ltd, a company registered in England and Wales (company number {{company_number}}) with registered office at {{registered_address}}.

## 2. Accounts

### 2.1 Eligibility

You may use the Service if you:
- Are at least 18 years old
- Are acting on behalf of a business, not as a consumer
- Are legally able to form a binding contract
- Are not prohibited by applicable sanctions or export controls

### 2.2 Registration

To use the Service, you must create an account with accurate information and maintain it.

### 2.3 Account security

You're responsible for safeguarding your account credentials. Notify us immediately at security@clawd.ai of any unauthorised access.

### 2.4 Authorised users

If you register on behalf of an organisation, you represent that you have authority to bind that organisation. You're responsible for the actions of all users granted access through your organisation's account.

## 3. The Service

### 3.1 What we offer

Clawd is a platform that runs AI-assisted business operations — drafting, content creation, lead research, client reporting, etc. — on your behalf, subject to your review.

### 3.2 AI-generated output

The Service produces AI-generated output. You acknowledge:
- Output may contain errors or inaccuracies
- You are responsible for reviewing output before relying on it, publishing it, or sending it externally
- Our "Everything Drafts, Nothing Sends" principle means you control what leaves your account

### 3.3 Third-party integrations

The Service integrates with third-party services (Fathom, HubSpot, Gmail, etc.). Those services are operated by third parties under their own terms; we're not responsible for their performance or terms.

### 3.4 Changes to the Service

We may modify, suspend, or discontinue features of the Service. Material reductions in Service functionality are notified to customers in advance.

### 3.5 Availability

The Service is provided "as is" without guarantees of uninterrupted availability on clawd.ai or in trial accounts. Paid customers are entitled to service levels under their MSA's SLA.

## 4. Fees and billing

### 4.1 Pricing

Current pricing is shown on clawd.ai/pricing. Prices are in GBP exclusive of VAT unless stated. We may change pricing with notice.

### 4.2 Payment

Paid subscribers pay via Stripe or another method we offer. Billing terms are in the customer's Order Form under the MSA.

### 4.3 Trials

We may offer free trials. Trials are at our discretion, may be limited in duration or scope, and may require a credit card. We may convert trials to paid subscriptions unless cancelled before trial end; we'll notify you before conversion.

### 4.4 Refunds

Fees already paid are non-refundable except as required by law or expressly provided in the MSA.

## 5. Intellectual property

### 5.1 Our IP

We (and our licensors) own all rights in the Service, including software, documentation, branding, and related materials. These Terms don't grant you any IP rights other than the limited licence to use the Service.

### 5.2 Your content

You retain all rights in content you upload to or create using the Service ("Your Content"). You grant us a limited licence to host, process, and display Your Content as necessary to provide the Service.

### 5.3 Output

You own the output the Service generates from Your Content. We don't claim rights in that output beyond what's needed to provide the Service.

### 5.4 Feedback

We may use feedback you provide about the Service without restriction.

### 5.5 Anonymised improvements

We may use aggregated, anonymised, non-identifying data to improve the Service. We don't train AI models on identifiable customer data.

## 6. Acceptable use

You must use the Service in accordance with our Acceptable Use Policy, available at clawd.ai/aup. Breaches of the AUP may lead to suspension or termination.

## 7. Privacy

Your use of the Service is subject to our Privacy Policy. Data processed on your behalf as a customer is subject to our DPA.

## 8. Third-party content

The Service may display content from third parties. We're not responsible for third-party content.

## 9. Warranties

### 9.1 Our warranty

We warrant that the Service will materially conform to the documentation (available at {{documentation_url}}). We don't warrant that it's error-free or uninterrupted.

### 9.2 Disclaimers

Except as expressly stated, the Service is provided "as is" and we disclaim all other warranties, express or implied, including warranties of merchantability, fitness for a particular purpose, and non-infringement.

### 9.3 AI-specific

We don't warrant that AI-generated output is accurate, suitable for any particular purpose, or free from errors. You accept that AI-generated content requires human review.

## 10. Limitation of liability

### 10.1 Nothing excluded

Nothing in these Terms excludes liability for death, personal injury caused by negligence, fraud, or any other liability that can't be excluded under law.

### 10.2 Cap

Subject to 10.1, our total liability to you under these Terms in any 12-month period is limited to the greater of:
- The fees you've paid us in that period; or
- £1,000

This is lower than the MSA's cap because these Terms cover free/trial use and general-public visits. Paid customers' MSA terms govern.

### 10.3 Excluded losses

Subject to 10.1, we're not liable for loss of profit, revenue, business opportunity, goodwill, or consequential losses.

## 11. Termination

### 11.1 By you

You may stop using the Service at any time. If you're a paid subscriber, termination terms are in the MSA.

### 11.2 By us

We may suspend or terminate your access:
- For material breach of these Terms that's not remedied within 30 days
- For breach of the AUP (immediate in severe cases)
- If required by law

### 11.3 Effects

On termination:
- Your right to use the Service ends
- Paid subscribers retain rights under the MSA (including Vault export)
- Provisions that by nature survive (IP, confidentiality, liability, law) continue

## 12. Changes to these Terms

We may update these Terms. Material changes are notified by email (to registered users) and posted on clawd.ai at least 30 days before taking effect. Continued use after changes constitutes acceptance.

## 13. General

### 13.1 Entire agreement

These Terms (plus the Privacy Policy, AUP, and any MSA) are the entire agreement between us.

### 13.2 No waiver

Failure to enforce a right doesn't waive it.

### 13.3 Severability

If any provision is unenforceable, the rest continues in effect.

### 13.4 Assignment

You can't assign these Terms. We may assign them in a merger or sale.

### 13.5 Governing law

These Terms are governed by English law. Disputes are subject to the exclusive jurisdiction of English courts.

### 13.6 Contact

- **General:** hello@clawd.ai
- **Legal:** legal@clawd.ai
- **Security:** security@clawd.ai
- **Postal:** Intel Force Ltd, {{registered_address}}

---

*Thanks for reading.*

---

---

## 4. Cookie consent banner

### 4.1 Design

Minimal, non-dark-pattern. Rejects and accepts should be equally prominent:

```
┌──────────────────────────────────────────────────────────────┐
│  We use cookies to run the website and understand how it's    │
│  used. Strictly-necessary cookies are always on. You can      │
│  accept or reject analytics cookies.                         │
│                                                              │
│  [Accept all]  [Reject non-essential]  [Customise]           │
└──────────────────────────────────────────────────────────────┘
```

- Both primary buttons visually equal — don't hide "Reject" behind a sub-option
- "Customise" opens a panel for granular choice
- No pre-checked consent boxes (unlawful under UK GDPR / PECR)
- Choice persisted for 6 months; re-prompt after

### 4.2 Which cookies actually set

- **Strictly necessary** (always on): session cookie (Clerk), CSRF, functional prefs
- **Analytics** (consent required): Plausible or Fathom Analytics cookie (both are privacy-focused alternatives to Google Analytics — no cross-site tracking, EU-hosted, minimal data collection)
- **NO third-party tracking or advertising cookies**

### 4.3 Implementation

Use a simple open-source banner (e.g., `cookie-consent.js`) or hand-roll it. Don't use OneTrust or similar overkill vendors at our scale.

---

## 5. DSAR (Data Subject Access Request) process

For when someone invokes their GDPR rights against Clawd (controller capacity):

### 5.1 Triage (first 24 hours)

- Request arrives at privacy@clawd.ai
- Founder (initially, later a privacy lead) logs receipt with a ticket ID
- Verify identity (usually by asking them to email from a confirmed address on file)
- Acknowledge within 72 hours

### 5.2 Investigation

- Identify what data we have about the requester
- Determine whether the request is for access, rectification, erasure, portability, restriction, or objection
- Identify any legal bases that override (e.g., legitimate interest in retaining billing records)

### 5.3 Response (within 30 days)

- Provide the requested data (for access/portability) in CSV/JSON
- Confirm erasure or rectification
- Explain any refusals with legal reasoning
- Record the response in the DSAR log

### 5.4 Complex requests

If the request is complex (e.g., spanning multiple systems, large data volumes), we can extend response time to 60 days with notification to the requester.

### 5.5 Tooling

For MVP: manual process. As volume grows, build internal tooling. For now, a simple DSAR playbook + template email responses.

---

## 6. Notes for the solicitor

### 6.1 Priorities

Solicitor should focus on:
- GDPR Articles 13/14 completeness in Privacy Policy
- Valid-cookie-consent architecture (UK PECR compliance)
- Enforceable ToS for free/trial users (differs from MSA)
- Interaction between ToS and MSA precedence
- Liability caps for public Terms (separate from MSA caps)
- DSAR response obligations and practical compliance

### 6.2 Solicitor budget

- Privacy Policy finalisation: £800–£1,500
- ToS finalisation: £600–£1,200
- Cookie consent banner review: £200–£400
- DSAR playbook draft: £500–£1,000 (optional)

**Total for policy pack:** £2,100–£4,100. Often a solicitor will quote a bundle price for MSA + DPA + SLA + Privacy + ToS + AUP; aim for £4,000–£7,000 bundled.

---

## 7. Open decisions

**OD-P5-12:** Analytics provider?
- **Recommendation:** Plausible Analytics or Fathom Analytics. Both privacy-focused, EU-based options, no cookies needed (or minimal cookies). Avoids consent-banner complexity. £10–£25/month at our volumes.

**OD-P5-13:** Email provider for transactional + marketing?
- **Recommendation:** Resend or Postmark for transactional. Separate tool (Mailcoach or simple newsletter service) for marketing if needed — don't mix.

**OD-P5-14:** Cookie banner — build or buy?
- **Recommendation:** Build simple banner in-house. OneTrust-type products are overkill for our cookie usage. Budget: 4–8 hours of engineering.

---

## 8. Related

- `msa-template.md` — for paid customers
- `dpa-template.md` — for data processed on customer behalf
- `acceptable-use-policy.md` — linked from both ToS and MSA
- `marketing/landing-page-spec.md` — where these policies link from the footer

---

*These templates aren't legal advice. Engage a UK commercial solicitor with SaaS + privacy experience to finalise before publishing on the landing page.*
