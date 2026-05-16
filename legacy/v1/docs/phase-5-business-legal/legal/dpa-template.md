# Data Processing Agreement — Template

**The schedule to the MSA that sets out how Clawd processes personal data on the customer's behalf, aligned with UK GDPR and EU GDPR.**

> **⚠️ THIS IS A STRUCTURAL TEMPLATE, NOT A FINAL LEGAL DOCUMENT.**
>
> GDPR-related contracts are legally material. Before executing any DPA with a real customer, this template MUST be reviewed by a UK commercial solicitor with specific data-protection experience. GDPR exposure is where amateur templates cost companies real money in enforcement.
>
> **Audience:** founder; solicitor producing the finalised DPA; customer's legal team reviewing.
>
> **Status:** v1.0. Reflects UK GDPR and EU GDPR at time of writing. Periodic review is required as guidance from the ICO and EDPB evolves.

---

## 1. Why this template takes GDPR seriously

- Fines under UK GDPR/EU GDPR can reach 4% of global turnover or £17.5M/€20M, whichever is higher
- Customers (especially regulated sectors — dental, finance, legal) will refuse to sign without a proper DPA
- A poor DPA is often more dangerous than no DPA — it commits us to obligations we can't meet
- The UK ICO actively enforces Article 28 requirements for processors

### 1.1 Position

Clawd is a **processor** of personal data under GDPR. Our customers are **controllers**. Clawd processes personal data on customers' instructions. This DPA documents the terms under which that processing happens.

### 1.2 Sub-processors

Clawd uses sub-processors (listed in Annex B). Most notably:
- **Anthropic** — AI model provider
- **Hetzner** (UK) — primary hosting
- **AWS** (London region) — secondary hosting, S3 storage, KMS
- **Cohere** (EU region) — embeddings
- **Clerk** (EU region) — authentication
- **Stripe** — billing
- Third-party integrations as directly connected by Customer (Fathom, HubSpot, Gmail, etc.)

Customer must consent to sub-processors; Clawd must give notice of new sub-processors and the right to object.

---

## 2. Template

The following is the DPA template. Placeholders are `{{like this}}`.

---

---

# Data Processing Agreement

**Schedule 2 to the Master Services Agreement between Intel Force Ltd (trading as Clawd) and {{customer_legal_name}}, effective {{effective_date}}.**

This DPA supplements the MSA. In case of conflict between this DPA and the MSA on matters of personal data, this DPA takes precedence.

## 1. Definitions

Capitalised terms used in this DPA but not defined have the meaning given in the MSA. In addition:

- **"Applicable Data Protection Law"** means the UK GDPR, the Data Protection Act 2018, and (where applicable to Customer's processing) the EU GDPR and member-state implementations.
- **"Controller", "Processor", "Data Subject", "Personal Data", "Processing", "Supervisory Authority"** have the meanings given in the UK GDPR.
- **"Customer Personal Data"** means Personal Data that Clawd processes on behalf of Customer in connection with the Service.
- **"Data Subject Request"** means a request from a Data Subject to exercise their rights under Applicable Data Protection Law.
- **"Personal Data Breach"** means a breach of security leading to accidental or unlawful destruction, loss, alteration, unauthorised disclosure of, or access to Customer Personal Data.
- **"Sub-processor"** means any third party engaged by Clawd to process Customer Personal Data on Customer's behalf.

## 2. Roles and scope

### 2.1 Roles

For processing Customer Personal Data: Customer is the Controller; Clawd is the Processor. Where Clawd acts as Controller (e.g. for its own billing and account-administration purposes in relation to Customer's contact persons), the terms of Clawd's Privacy Policy apply.

### 2.2 Scope

This DPA governs Clawd's Processing of Customer Personal Data as a Processor in the course of providing the Service.

### 2.3 Duration

This DPA applies for the term of the MSA and continues as long as Clawd Processes Customer Personal Data.

## 3. Processing details (Article 28(3))

### 3.1 Subject matter

Provision of the Service to Customer, including hosting, processing, and producing outputs from Customer Data.

### 3.2 Duration

For the term of the MSA, plus any retention period expressly set out in this DPA (e.g. backup retention, legal-hold periods).

### 3.3 Nature and purpose

Processing involves:
- Storing Customer Data in the Tenant (database, Vault, backups)
- Transmitting Customer Data to AI model providers for inference
- Transmitting Customer Data to integrated services (Fathom, HubSpot, etc.) as Customer directs
- Generating outputs from Customer Data
- Logging and monitoring for the purpose of providing and improving the Service

### 3.4 Categories of Data Subjects

Typically includes:
- Customer's employees and authorised users
- Customer's clients, prospects, and contacts whose data Customer processes through the Service
- Other Data Subjects whose Personal Data appears in Customer Data

### 3.5 Categories of Personal Data

Typically includes:
- Identity data (names, email addresses, phone numbers)
- Business contact data (company, role, address)
- Communications data (email content, call transcripts, meeting notes)
- Usage and interaction data with the Service
- As otherwise determined by Customer's choice of integrations and data

### 3.6 Special Category Data

Clawd does not expect to process Special Category Data (Article 9) or criminal conviction data (Article 10). Customer warrants that it will not upload such data to the Service without first consulting Clawd and executing any additional terms required.

## 4. Clawd's obligations

### 4.1 Documented instructions

Clawd processes Customer Personal Data only on Customer's documented instructions, which are set out in:
(a) the MSA;
(b) this DPA;
(c) Customer's configuration of the Service (e.g. which integrations are enabled);
(d) any additional written instructions Customer gives that are feasible within the Service.

If Clawd believes any instruction breaches Applicable Data Protection Law, Clawd will notify Customer.

### 4.2 Confidentiality

Clawd ensures that persons authorised to process Customer Personal Data are bound by appropriate confidentiality obligations.

### 4.3 Security

Clawd implements appropriate technical and organisational measures to protect Customer Personal Data (see Annex A — Technical and Organisational Measures).

### 4.4 Sub-processors

Clawd may engage Sub-processors to process Customer Personal Data, subject to this clause 4.4.

Customer gives general authorisation for Clawd to use the Sub-processors listed in Annex B.

Clawd will:
(a) maintain an up-to-date list of Sub-processors (Annex B);
(b) notify Customer of changes (additions, replacements) at least 30 days before the change takes effect;
(c) ensure each Sub-processor is bound by terms no less protective than this DPA;
(d) remain responsible to Customer for each Sub-processor's performance.

Customer may object to a new Sub-processor on reasonable data-protection grounds by written notice within the 30-day notice period. If the objection cannot be resolved, Customer may terminate the affected part of the Service with a pro-rata refund.

### 4.5 Data Subject Requests

Clawd will:
(a) where legally permitted, promptly forward any Data Subject Request received directly by Clawd to Customer;
(b) not respond to Data Subject Requests except on Customer's instructions or as required by law;
(c) provide reasonable assistance (taking into account the nature of processing) to help Customer respond to Data Subject Requests within statutory timeframes.

### 4.6 Assistance with regulatory obligations

Taking into account the nature of processing and the information available to Clawd, Clawd will provide reasonable assistance to Customer in meeting Customer's obligations under Articles 32–36 of the UK GDPR (security, breach notification, data protection impact assessments, prior consultation).

### 4.7 Personal Data Breaches

If Clawd becomes aware of a Personal Data Breach affecting Customer Personal Data, Clawd will:
(a) notify Customer without undue delay and in any event within 72 hours of becoming aware;
(b) provide information reasonably required for Customer to meet its notification obligations, including (to the extent known): nature of the breach, categories and approximate numbers of Data Subjects and records affected, likely consequences, measures taken or proposed;
(c) cooperate with Customer's investigation and response.

### 4.8 Audit rights

Clawd will make available to Customer all information reasonably necessary to demonstrate compliance with this DPA.

Clawd's audit-support practice:
(a) Clawd provides, annually and on request, a summary of security certifications, penetration-test results (redacted), and third-party audit reports;
(b) Customer may request additional audit information in writing; Clawd will respond within 30 days;
(c) On-site audits by Customer are permitted once per 12-month period, subject to: 60 days' prior written notice, agreed scope, Customer bearing its own costs, compliance with Clawd's confidentiality and security requirements, and no disruption to Clawd's other customers;
(d) Where Customer is a regulated entity, regulator-led audits are permitted as required by law.

### 4.9 Return and deletion

On termination of the MSA, Clawd will, at Customer's choice:
(a) return Customer Personal Data to Customer (typically via a Vault export); and/or
(b) delete Customer Personal Data,

within 90 days of termination, except to the extent retention is required by law or for legitimate audit purposes (in which case retained data remains subject to this DPA's confidentiality and security provisions).

On request, Clawd will provide a written confirmation of deletion.

## 5. International transfers

### 5.1 Position

Customer Personal Data is primarily stored and processed in the UK (Hetzner UK for primary hosting; AWS London for secondary hosting and backups).

Transfers outside the UK occur where:
(a) Anthropic APIs are called (Anthropic processes inference requests; location depends on Anthropic's then-current configuration);
(b) Cohere APIs are called (Cohere EU region, eu-west);
(c) Clerk authentication is used (EU region);
(d) Stripe billing (EU and US processing depending on Stripe's configuration);
(e) Customer directs integrations with services hosted outside the UK.

### 5.2 Transfer mechanism

For any transfer of Customer Personal Data to a country outside the UK without an adequacy decision, Clawd ensures one of the following:
(a) the recipient has a valid adequacy decision;
(b) the transfer is covered by the International Data Transfer Agreement (IDTA) or the UK Addendum to the EU Standard Contractual Clauses, as applicable;
(c) another valid transfer mechanism under UK GDPR Article 46 is in place.

Clawd makes available on request copies of the transfer mechanisms applying to each Sub-processor.

## 6. Customer obligations

### 6.1 Controller responsibilities

Customer is responsible for:
(a) having a lawful basis for processing under Article 6 (and where applicable Article 9) of UK GDPR;
(b) providing required information to Data Subjects about processing;
(c) responding to Data Subject Requests within statutory timeframes;
(d) maintaining records of processing activities under Article 30;
(e) notifying Supervisory Authorities and Data Subjects of Personal Data Breaches as required.

### 6.2 Accuracy and lawfulness

Customer warrants that:
(a) Customer Personal Data is accurate and up-to-date;
(b) Customer has the right to disclose Customer Personal Data to Clawd and have it processed as described in this DPA;
(c) Customer's instructions to Clawd comply with Applicable Data Protection Law.

### 6.3 Integrations

Where Customer connects third-party integrations (Fathom, HubSpot, Gmail, etc.), Customer:
(a) is responsible for ensuring its use of those integrations complies with Applicable Data Protection Law;
(b) acknowledges that those third parties are separate data processors/controllers with their own terms;
(c) instructs Clawd to transmit Customer Personal Data to those integrations.

## 7. Liability

### 7.1 Regulatory fines

Neither Party indemnifies the other against regulatory fines directly imposed on the other Party.

### 7.2 Cap

Liability under this DPA is subject to the limitation of liability in the MSA. Nothing in this DPA increases a Party's liability beyond what's already provided in the MSA.

## 8. Precedence and amendments

### 8.1 Precedence

In the event of conflict, this DPA prevails over the MSA on matters of Personal Data processing.

### 8.2 Regulatory changes

If Applicable Data Protection Law changes materially (e.g., new regulation, binding guidance from the ICO or EDPB that materially affects processing terms), the Parties will negotiate in good faith to amend this DPA accordingly.

## 9. Governing law

This DPA is governed by the laws of England and Wales and subject to the exclusive jurisdiction of the English courts.

---

## Annex A — Technical and Organisational Measures

Clawd implements the following measures to protect Customer Personal Data:

### A.1 Access control

- Multi-factor authentication required for all Clawd personnel
- Role-based access control; least-privilege principle
- Access to production systems requires dedicated credentials and is logged
- Quarterly review of access permissions
- Immediate revocation on personnel departure

### A.2 Encryption

- TLS 1.3 for all data in transit (externally-exposed endpoints)
- mTLS for service-to-service communication inside the platform
- Data at rest encrypted via full-disk encryption (LUKS) on Hetzner; AWS default encryption on AWS storage
- Per-tenant AWS KMS Customer Managed Keys (CMKs) for secret data; deletion of a tenant's CMK renders their ciphertexts unrecoverable
- TLS certificates rotated automatically via ACME

### A.3 Network security

- All externally-accessible surfaces behind Cloudflare WAF
- Private network for inter-service communication
- Ingress/egress firewall rules; default deny
- Regular network scans

### A.4 Application security

- Secure software development lifecycle
- Static analysis and dependency scanning in CI
- Secret scanning to prevent credentials in code
- Code review required for all production changes
- Penetration test annually (once we have engaged an external firm)

### A.5 Logical isolation

- Multi-tenancy with row-level security (RLS) in Postgres
- Per-tenant database schemas
- Per-tenant container workloads with filesystem isolation
- Per-tenant KMS CMK isolation (see A.2)

### A.6 Operational security

- Logs centralised; tenant-tagged; two-layer secret redaction
- Logs retained 30 days hot, 1 year cold, 7 years for audit log
- Alerting on suspicious patterns (failed authentication spikes, anomalous API usage)
- Incident response runbook; on-call rotation

### A.7 Backup and resilience

- Postgres: pgBackRest continuous WAL archival, 30-day PITR
- DynamoDB: point-in-time recovery enabled (35-day window)
- Vault repositories: nightly S3 archive (90-day retention)
- Weekly restore tests
- Quarterly DR drills

### A.8 Personnel

- Background checks for personnel with production access (once we hire; currently founder + contractors)
- Confidentiality and data-protection obligations in employment and contractor agreements
- Annual security awareness training (once team size warrants formal programme)

### A.9 Physical security

- All primary infrastructure in ISO 27001-certified data centres (Hetzner UK, AWS London)
- Clawd does not maintain physical servers outside these providers
- Office access (where Clawd has an office) controlled via building security

### A.10 Data minimisation

- Clawd collects only data needed to provide the Service
- Retention of operational data aligned to service provision
- Aggregate/anonymised data used for platform improvement; identifiable data not used to train general-purpose AI models

### A.11 Audit

- Every material action in the Service is logged to an append-only audit log
- Audit log retained 7 years in AWS S3 Object Lock (governance mode)
- Customer has read access to its own tenant's audit log via the dashboard

### A.12 Continuous improvement

- Annual review of these measures
- Updates published with 30 days' notice before material reduction in protection

---

## Annex B — Approved Sub-processors

The Sub-processors currently engaged to process Customer Personal Data:

| Sub-processor | Purpose | Location of processing | Transfer mechanism (if outside UK) |
|---|---|---|---|
| Anthropic PBC | AI model inference (Claude) | USA | IDTA / EU SCCs with UK Addendum |
| Hetzner Online GmbH | Primary hosting infrastructure | UK (EU fallback possible) | N/A (UK) |
| Amazon Web Services | Secondary hosting, S3 storage, KMS | UK (London region) | N/A (UK) |
| Cohere Inc. | Text embedding generation | EU region | EU SCCs with UK Addendum |
| Clerk Inc. | Authentication services | EU region | EU SCCs with UK Addendum |
| Stripe Payments Europe Ltd | Payment processing | EU + US (Stripe's own processing) | Stripe's own transfer mechanisms |
| Cloudflare Inc. | CDN, WAF, DNS | Global edge; metadata in US | EU SCCs with UK Addendum |
| Statuspage.io (Atlassian) | Service status page | US / EU (Atlassian's infrastructure) | EU SCCs with UK Addendum |
| PagerDuty Inc. | Incident paging | US | EU SCCs with UK Addendum |
| GitHub Inc. | Private repository hosting for Vault | US | EU SCCs with UK Addendum |

*Subject to revision per clause 4.4. Current version always available at {{sub_processor_list_url}}.*

Third-party services that Customer directly integrates with (e.g. Fathom, HubSpot, Gmail, Dentally) are separate data processors/controllers with their own terms and are not Sub-processors of Clawd. Customer is responsible for ensuring those integrations comply with Applicable Data Protection Law.

---

## Annex C — International Data Transfer Addendum

Where Clawd transfers Customer Personal Data to a Sub-processor located outside the UK:

- For transfers to recipients covered by a UK adequacy regulation: no additional mechanism required
- For other transfers: the UK Addendum to the EU Standard Contractual Clauses applies, incorporating the current EU SCCs (Commission Decision 2021/914) with UK-specific provisions
- Current versions of these documents are available from the ICO at ico.org.uk/for-organisations/guide-to-data-protection/international-data-transfer-agreement-and-guidance/

The full text of the UK Addendum is incorporated by reference. A signed copy is available on request.

---

---

## 3. Notes for the reviewing solicitor

### 3.1 Commercial-legal balance

This template prioritises:
- Customer's legal team able to say "this is standard and comprehensive" without changes for most deals
- Minimal surprising obligations for Clawd (e.g., we don't agree to custom audit frequencies)
- Clear, honest representation of our security posture — don't over-claim capabilities we don't have

### 3.2 Areas solicitor should particularly review

- **72-hour breach notification** — standard under GDPR but our internal detection + notification capability needs to actually meet this (operational concern, not just legal)
- **Audit support obligations** (clause 4.8) — solicitor may recommend tightening; customer counsel may want broader rights
- **Annex A TOMs** — we claim specific measures; each one must be provably true or removed
- **Sub-processor list** (Annex B) — verify current list; each entry needs its own transfer mechanism

### 3.3 Solicitor's scope of work

- Review template language against current UK GDPR case law and ICO guidance
- Finalise the transfer-mechanism wording (IDTA vs UK Addendum vs specific SCC version)
- Advise on whether Annex A claims are defensible (require operational confirmations from Clawd)
- Produce a final signable PDF with Clawd letterhead
- Draft a short executive-summary page for customer legal teams to speed review
- Advise on when a separate DPA (versus combined with MSA) is appropriate

Typical solicitor budget: £1,500–£3,500 one-time for template finalisation. £500–£1,500 per bespoke enterprise DPA thereafter.

### 3.4 When we'd need DPAs from customers

When Clawd is the controller (e.g., for our billing relationship with a customer's contact person, for marketing data), customers may ask Clawd to sign their DPAs. Treat these case-by-case; most are straightforward mirror-image documents.

---

## 4. Ongoing maintenance

This DPA is a living document:

- Review every 12 months against updated ICO guidance
- Update Annex B (Sub-processors) as infrastructure evolves
- Update Annex A (TOMs) honestly — if we lose a capability, we update; we don't hide
- Major ICO enforcement actions against similar-shaped companies should trigger review

Who owns this at Clawd: the founder initially; a compliance lead once team size warrants (post-Series A).

---

## 5. Related

- `msa-template.md` — the parent agreement
- `privacy-and-terms-spec.md` — Clawd's own privacy policy (Clawd as controller for its own data)
- `phase-3-platform/dr/backup-and-dr-runbook.md` — actual operational DR story that backs up Annex A claims
- `phase-3-platform/secrets/secrets-vault-spec.md` — actual CMK isolation implementation

---

*This template is not legal advice. Engage a UK commercial solicitor with specific data-protection expertise to finalise before signing any customer. GDPR exposure is material; amateur templates create liability.*
