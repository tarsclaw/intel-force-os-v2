# Master Services Agreement — Template

**The commercial contract between Clawd (Intel Force Ltd) and a customer. Covers subscription, payment, IP, liability, term, and termination.**

> **⚠️ THIS IS A STRUCTURAL TEMPLATE, NOT A SIGNED LEGAL DOCUMENT.**
>
> Before this MSA is executed with any real customer, it MUST be reviewed and finalised by a UK commercial solicitor familiar with SaaS contracts. The template provides structure and first-pass language; a solicitor provides the judgement that makes it enforceable and the revisions that make it appropriate for each deal.
>
> **Audience:** founder; commercial solicitor drafting the final; sales lead using it in deal negotiation.
>
> **Status:** v1.0 template. Expect a solicitor to revise 20–40% of the language.

---

## 1. How this template is used

### 1.1 Starting point, not final document

This template:
- Provides the full structure and section coverage
- Reflects SaaS industry norms for UK commercial contracts
- Is written in plain English where possible, with legal precision where necessary
- Embeds the commercial decisions we've made (pricing model, term length, SLA position)

A solicitor's job is to:
- Harden language against specific UK/EU legal risks
- Add/revise clauses based on current case law
- Advise on what's negotiable and what's non-negotiable
- Produce the final signed version

### 1.2 Negotiation posture

For **Starter / Growth** tier (£1,800/month and below): this MSA is our standard. We don't negotiate material terms for deals of this size — the cost of legal negotiation exceeds the deal economics. If a prospect insists on their paper or material redlines, we politely decline and direct them to a larger vendor.

For **Scale** tier (£5,000+/month): minor redlines OK, escalate anything material to a solicitor for review.

For **Enterprise** tier (£10,000+/month or agency partnerships): the customer's legal may insist on their paper or substantial redlines. We engage our solicitor for these deals. Budget: ~£2,000–£5,000 in legal fees per enterprise deal; priced into the deal.

### 1.3 When to use a DPA alongside

This MSA handles commercial terms. The **Data Processing Agreement** (see `dpa-template.md`) handles GDPR-specific data-processing terms. Every customer signs both. For UK-only B2B customers, both can be combined into one document; for customers with EU or regulated-industry exposure, keep them separate.

---

## 2. Template

The following is the template. Placeholders in double curly braces (`{{like this}}`) get filled in per deal.

---

---

# Master Services Agreement

**Between:**

**Intel Force Ltd**, a company registered in England and Wales with company number {{company_number}} and registered office at {{registered_address}} (**"Clawd"**, "we", "us", "our")

**and:**

**{{customer_legal_name}}**, a {{customer_entity_type}} with {{customer_identifier_type}} number {{customer_identifier}} and registered/principal address at {{customer_address}} (**"Customer"**, "you", "your")

(each a "Party", together the "Parties")

**Effective Date:** {{effective_date}}

---

## 1. Definitions

In this Agreement:

- **"Agents"** means the automated software components provided as part of the Service, including but not limited to Proposal Builder, Lead Hunter, Client Onboarder, and those documented at {{documentation_url}}.
- **"Agreement"** means this Master Services Agreement, the attached Order Form, the Data Processing Agreement, the Acceptable Use Policy, and the Service Level Agreement, each as amended from time to time.
- **"Business Day"** means Monday to Friday excluding public holidays in England.
- **"Customer Data"** means data provided by Customer or generated through Customer's use of the Service, including content written to Customer's Vault.
- **"Confidential Information"** means any non-public information disclosed by one Party to the other, whether oral or written, that is identified as confidential or that a reasonable person would understand to be confidential.
- **"Documentation"** means the user and technical documentation for the Service made available at {{documentation_url}}.
- **"Effective Date"** has the meaning given on the cover page.
- **"Order Form"** means the ordering document attached to this Agreement or executed subsequently, referencing this Agreement.
- **"Service"** means the Clawd software-as-a-service platform, including the Agents, dashboard, APIs, and associated components.
- **"Subscription Fees"** means the fees set out in the Order Form.
- **"Subscription Term"** means the period set out in the Order Form.
- **"Tenant"** means Customer's isolated instance of the Service, including Customer's Vault, configurations, and data.
- **"Vault"** means the version-controlled repository of Customer's content maintained as part of the Service.

## 2. Service

### 2.1 Provision

Clawd will provide the Service to Customer for the Subscription Term, in accordance with this Agreement, the Documentation, and the SLA.

### 2.2 Access

Clawd grants Customer a non-exclusive, non-transferable, non-sublicensable right to access and use the Service during the Subscription Term, solely for Customer's internal business operations and subject to the Acceptable Use Policy.

### 2.3 Scope of Service

The specific tier, enabled Agents, user seats, and other service parameters are as set out in the Order Form. Customer may upgrade or downgrade tiers in accordance with the Order Form and Documentation.

### 2.4 Service Level Agreement

The Service is subject to the SLA attached as Schedule 1. Service credits (as defined in the SLA) are Customer's sole and exclusive remedy for Clawd's failure to meet the service levels.

## 3. Use of the Service

### 3.1 Customer obligations

Customer will:
(a) use the Service in accordance with the Documentation and the Acceptable Use Policy;
(b) ensure that Customer's personnel who access the Service comply with this Agreement;
(c) maintain the security of access credentials and immediately notify Clawd of any unauthorised access;
(d) not reverse-engineer, decompile, or attempt to extract source code of the Service, except to the extent such restriction is prohibited by applicable law;
(e) not resell, sublicense, or otherwise make the Service available to third parties (other than Customer's agents, advisors, or contractors acting on Customer's behalf under confidentiality obligations), except under a specifically-agreed agency partner arrangement;
(f) not use the Service in a way that could harm, overload, or impair the Service;
(g) ensure that Customer Data does not infringe third-party rights and complies with applicable law.

### 3.2 Use with third-party integrations

The Service integrates with third-party services (including but not limited to Fathom, HubSpot, Gmail, Stripe). Customer acknowledges:
(a) third-party services are provided by their respective operators and are governed by their own terms;
(b) Clawd is not responsible for the availability, performance, or terms of third-party services;
(c) Customer is responsible for any fees owed directly to third-party service providers;
(d) disruption to third-party services may affect Customer's use of the Service.

### 3.3 AI output

Customer acknowledges that the Service uses artificial intelligence models (including Anthropic Claude) to generate output. Customer acknowledges:
(a) AI-generated output may contain errors, omissions, or inaccuracies;
(b) Customer is responsible for reviewing AI-generated output before relying on it for business decisions, publishing it, or transmitting it to third parties;
(c) Clawd operates the Service under an "Everything Drafts, Nothing Sends" principle — Customer retains final review and approval authority for outputs transmitted externally;
(d) Customer indemnifies Clawd against claims arising from Customer's use of AI-generated output that was not properly reviewed.

## 4. Fees and payment

### 4.1 Subscription Fees

Customer will pay the Subscription Fees set out in the Order Form. All amounts are stated exclusive of VAT, which will be added at the prevailing rate where applicable.

### 4.2 Payment terms

Invoices are payable by {{payment_terms}} from the invoice date. Payment is made via {{payment_method}}.

### 4.3 Usage-based fees

In addition to fixed Subscription Fees, Customer is responsible for usage-based fees as set out in the Order Form, including but not limited to:
(a) AI model inference costs (Anthropic Claude usage);
(b) Third-party data provider costs (e.g. Prospeo, Kaspr) incurred through Customer's use;
(c) Excess usage beyond tier allowances.

Usage-based fees are billed monthly in arrears.

### 4.4 Cost controls

Customer may set a cost budget in the Service. Where Customer has elected "hard stop" mode, Clawd will suspend usage-based operations when the budget is reached. Where Customer has elected "soft alert" mode, Clawd will notify Customer but continue to incur costs. Customer is responsible for all incurred usage regardless of mode.

### 4.5 Late payment

If any undisputed invoice is unpaid after the due date, Clawd may:
(a) charge interest at 4% above the Bank of England base rate under the Late Payment of Commercial Debts (Interest) Act 1998;
(b) after 30 days, suspend Service (with written notice);
(c) after 60 days, terminate this Agreement.

### 4.6 Price changes

Clawd may increase Subscription Fees with 60 days' written notice, not more than once per 12-month period. If the increase exceeds 10% within any 12-month period, Customer may terminate effective on the date of the increase, subject to payment of any outstanding Fees.

## 5. Intellectual property

### 5.1 Clawd IP

Clawd (and its licensors) owns all rights, title, and interest in the Service, including the Agents, the software, the underlying technology, and all improvements. This Agreement does not transfer any IP rights in the Service to Customer.

### 5.2 Customer Data

Customer owns all rights in Customer Data. Customer grants Clawd a non-exclusive licence to use, process, transmit, and store Customer Data solely to provide the Service in accordance with this Agreement and the DPA.

### 5.3 AI-generated output

The ownership position on AI-generated output is as follows:
(a) Customer owns the output generated by the Service using Customer Data as input;
(b) Clawd retains no rights in that output other than the limited rights needed to provide the Service;
(c) Customer acknowledges that the underlying AI models may produce similar outputs for other customers, and that Customer does not claim ownership over the AI models themselves, over outputs unrelated to Customer's inputs, or over generally-applicable techniques or structures common in AI-generated text.

### 5.4 Feedback

Any feedback, suggestions, or ideas Customer provides about the Service may be used by Clawd without obligation to Customer.

### 5.5 Platform improvements

Clawd may use aggregated, anonymised, and de-identified data (that cannot reasonably be linked back to Customer) to improve the Service, to develop new features, and for benchmarking. Clawd will not use identifiable Customer Data to train general-purpose AI models.

## 6. Confidentiality

### 6.1 Obligation

Each Party will:
(a) keep the other Party's Confidential Information confidential;
(b) use it only for the purposes of this Agreement;
(c) protect it with no less care than it uses for its own confidential information, and in any event with reasonable care.

### 6.2 Exceptions

The confidentiality obligations do not apply to information that:
(a) is or becomes publicly available through no fault of the receiving Party;
(b) was known to the receiving Party before disclosure;
(c) is independently developed without reference to Confidential Information;
(d) must be disclosed by law or regulatory authority, provided the receiving Party gives prompt notice (where legally permitted).

### 6.3 Duration

Confidentiality obligations survive termination of this Agreement for 3 years.

## 7. Data protection

### 7.1 DPA

The Parties' obligations regarding processing of personal data are set out in the Data Processing Agreement (Schedule 2). In the event of conflict between this Agreement and the DPA regarding personal data, the DPA takes precedence.

### 7.2 Compliance

Each Party will comply with applicable data protection laws in its performance of this Agreement, including the UK GDPR and the Data Protection Act 2018.

## 8. Warranties

### 8.1 Clawd warranties

Clawd warrants that:
(a) the Service will substantially conform to the Documentation;
(b) Clawd has the right to provide the Service to Customer;
(c) Clawd will perform its obligations with reasonable skill and care.

### 8.2 Customer warranties

Customer warrants that:
(a) it has full authority to enter into this Agreement;
(b) its use of the Service will comply with applicable law and the Acceptable Use Policy;
(c) Customer Data does not infringe third-party rights.

### 8.3 Disclaimer

Except as expressly set out in this Agreement, the Service is provided "as is" and Clawd disclaims all other warranties, express or implied, including warranties of merchantability, fitness for a particular purpose, and non-infringement. Clawd does not warrant that the Service will be error-free, uninterrupted, or that AI-generated output will be accurate or suitable for any specific purpose.

## 9. Indemnities

### 9.1 Clawd indemnity

Clawd will defend Customer against any third-party claim that the Service, as provided by Clawd, infringes a third party's UK intellectual property rights, and will pay the damages finally awarded or agreed in settlement, subject to:
(a) Customer promptly notifying Clawd of the claim;
(b) Customer giving Clawd sole control of the defence and settlement;
(c) Customer providing reasonable cooperation.

### 9.2 Clawd indemnity exceptions

The indemnity in 9.1 does not apply to claims arising from:
(a) combination of the Service with non-Clawd products;
(b) use of the Service in breach of this Agreement;
(c) Customer Data;
(d) AI-generated output that Customer used without adequate review.

### 9.3 Customer indemnity

Customer will defend Clawd against any third-party claim arising from:
(a) Customer Data;
(b) Customer's breach of the Acceptable Use Policy;
(c) Customer's use of AI-generated output.

### 9.4 Remedies

If the Service is found to infringe third-party rights, Clawd may at its option:
(a) procure Customer's right to continue using the Service;
(b) modify the Service to eliminate the infringement;
(c) terminate the affected portion of the Service and refund prepaid fees for the unused portion.

## 10. Limitation of liability

### 10.1 Nothing excluded

Nothing in this Agreement limits either Party's liability for:
(a) death or personal injury caused by negligence;
(b) fraud or fraudulent misrepresentation;
(c) any other liability that cannot be excluded under law.

### 10.2 Excluded losses

Subject to clause 10.1, neither Party is liable for:
(a) loss of profit;
(b) loss of revenue;
(c) loss of business opportunity;
(d) loss of goodwill;
(e) loss or corruption of data beyond Clawd's backup obligations in the SLA;
(f) indirect or consequential loss.

### 10.3 Cap on liability

Subject to clauses 10.1 and 10.2, each Party's total aggregate liability under or in connection with this Agreement (whether in contract, tort, breach of statutory duty, or otherwise) is limited to the Subscription Fees paid or payable by Customer in the 12 months preceding the event giving rise to the claim, or £10,000, whichever is greater.

### 10.4 AI-specific liability

Without limiting the above, Clawd has no liability for:
(a) errors, omissions, or inaccuracies in AI-generated output;
(b) Customer's decisions made in reliance on AI-generated output;
(c) reputational, regulatory, or commercial harm arising from Customer's publication or transmission of AI-generated output without adequate human review.

## 11. Term and termination

### 11.1 Term

This Agreement begins on the Effective Date and continues for the initial Subscription Term set out in the Order Form. It automatically renews for successive periods equal to the initial Subscription Term unless either Party gives 30 days' written notice prior to the end of the current period.

### 11.2 Termination for convenience

Customer may terminate at the end of the current Subscription Term by giving notice under clause 11.1. Mid-term termination by Customer does not trigger a refund unless expressly stated.

### 11.3 Termination for cause

Either Party may terminate this Agreement with immediate written notice if the other Party:
(a) commits a material breach that is not remedied within 30 days of written notice;
(b) becomes insolvent, enters administration, liquidation, or analogous proceedings.

### 11.4 Effects of termination

On termination:
(a) Customer's access to the Service ends;
(b) Customer may request a Vault export within 30 days (see DPA §X);
(c) Clawd will, within 90 days, delete Customer Data except as required by law or legitimate audit purposes;
(d) fees accrued up to termination remain payable;
(e) provisions that by their nature survive (confidentiality, IP, liability, governing law) continue in force.

### 11.5 Suspension

Clawd may suspend the Service without terminating this Agreement if:
(a) Customer materially breaches the Acceptable Use Policy;
(b) Customer's use poses a security risk to the Service or other customers;
(c) required by law or regulatory direction.

Clawd will give Customer written notice of suspension and, where feasible, an opportunity to remedy.

## 12. General

### 12.1 Order of precedence

In the event of conflict, the order of precedence is:
1. The Order Form
2. The Data Processing Agreement
3. This Master Services Agreement
4. The Service Level Agreement
5. The Acceptable Use Policy

### 12.2 Assignment

Neither Party may assign its rights or obligations without the other Party's written consent, not to be unreasonably withheld. Clawd may assign to an affiliate or to a successor in a merger or sale of substantially all assets with written notice.

### 12.3 Notices

Notices must be in writing and sent to:
- For Clawd: legal@clawd.ai, copy to {{registered_address}}
- For Customer: as set out in the Order Form

Notice is deemed received on confirmation of email delivery or, for physical delivery, on proof of delivery.

### 12.4 Entire agreement

This Agreement (including all schedules and Order Forms) is the entire agreement between the Parties on its subject and supersedes any prior arrangement.

### 12.5 Variation

No variation is effective unless in writing signed by both Parties.

### 12.6 Waiver

A failure or delay in exercising a right is not a waiver.

### 12.7 Severability

If any provision is found unenforceable, the remainder of this Agreement continues in effect.

### 12.8 Third-party rights

A person not a party to this Agreement has no right under the Contracts (Rights of Third Parties) Act 1999 to enforce it.

### 12.9 Force majeure

Neither Party is liable for failure to perform due to circumstances beyond reasonable control (including natural disaster, war, pandemic, internet infrastructure failure, cloud-provider outage). The affected Party will notify promptly and resume performance as soon as reasonably possible.

### 12.10 Governing law and jurisdiction

This Agreement is governed by the laws of England and Wales. The courts of England and Wales have exclusive jurisdiction over any dispute arising out of or in connection with this Agreement.

---

**Signed for Intel Force Ltd (Clawd):**

Name: _____________________________
Position: _____________________________
Signature: _____________________________
Date: _____________________________

**Signed for Customer:**

Name: _____________________________
Position: _____________________________
Signature: _____________________________
Date: _____________________________

---

## Schedule 1 — Service Level Agreement

*(See separate file: `sla-spec.md`)*

## Schedule 2 — Data Processing Agreement

*(See separate file: `dpa-template.md`)*

## Schedule 3 — Acceptable Use Policy

*(See separate file: `acceptable-use-policy.md`)*

## Schedule 4 — Order Form

*(Executed per-deal; see the Order Form template attached to the executed MSA)*

---

---

## 3. Notes for the solicitor reviewing this template

### 3.1 Commercial decisions baked in

- **12-month default term** — renews automatically, 30-day notice to stop renewal
- **Monthly billing** in arrears for usage-based portions; monthly or annual for fixed
- **Liability cap** at greater of 12 months' fees or £10,000 — on the higher side for the Starter/Growth tier
- **Governing law** England and Wales (Scotland/NI customers not a concern at MVP)
- **No exclusivity clause** — we may sell to competitors of Customer
- **No non-compete** from Clawd — we won't agree to avoid serving competing products
- **Automatic price uplift** capped at 10% per 12-month period without termination right

### 3.2 Provisions likely to attract customer redlines

- **Liability cap** — larger customers push for higher caps; we hold firm except in Enterprise tier
- **AI output disclaimer** (clause 10.4) — some customers will try to strike this; we don't budge, this is existential
- **Training data / platform improvements** (clause 5.5) — customers sensitive about their data being used for anything will push back; we can narrow the language but shouldn't remove it entirely
- **Indemnity scope** (clause 9) — mutual indemnities typical; customer counsel may want expanded Clawd indemnity

### 3.3 Provisions we expect to negotiate in Enterprise tier

- **Dedicated infrastructure / isolation** — not in MSA template; add as a schedule for Enterprise
- **Data residency** guarantees beyond UK/EU default — schedule addition
- **Custom SLA** — Enterprise deals often negotiate the SLA terms; see SLA spec

### 3.4 Items specifically NOT in this template (intentionally)

- **Automatic price decrease** clauses — we don't offer
- **Most-favoured-nation** pricing — we don't agree to
- **Source-code escrow** — we'd decline unless material to an Enterprise deal
- **Uptime warranty beyond SLA service credits** — remedies are SLA service credits, full stop
- **Parent-company guarantee** — we don't offer; we're a small company
- **Insurance covenants** requiring us to hold specific insurance — add if we have PI insurance to point to; otherwise politely decline

### 3.5 Clauses that may need UK regulatory addenda

- **Financial services customers:** may need an Outsourcing schedule aligned with FCA outsourcing rules (SYSC)
- **Healthcare / dental with NHS exposure:** DSP toolkit reference
- **Public sector:** G-Cloud framework compliance, procurement rules
- **Regulated accountancy:** ICAEW outsourcing guidance

None of these are MVP customers. Flag to solicitor if they arrive.

### 3.6 Solicitor's job beyond finalising this template

- Produce the executed version with our letterhead/branding
- Draft the matching Order Form template
- Draft short versions for Starter-tier quick sign-off (if Starter warrants its own simplified agreement)
- Advise on signing authority — who at Intel Force Ltd has authority to sign
- Advise on notification/record-keeping once signed

Typical solicitor budget for finalising this set: £2,000–£5,000 one-time, then £500–£1,500 per bespoke Enterprise deal.

---

## 4. Related

- `dpa-template.md` — the GDPR schedule
- `sla-spec.md` — service-level commitments
- `acceptable-use-policy.md` — usage boundaries
- `pricing/pricing-spec.md` — the commercial terms this MSA embeds

---

*This template is not legal advice. Engage a UK commercial solicitor with SaaS experience to finalise before signing any customer.*
