# Stripe Integration Specification

**How Clawd collects money. Stripe subscription setup, webhooks, invoice flow, VAT handling, payment failure recovery.**

> **Audience:** engineer implementing CC20 (Stripe integration); founder understanding commercial flow; solicitor reviewing tax handling.
>
> **Status:** v1.0. Targets Stripe's Billing + Tax products. UK-first; EU reverse-charge supported; other regions flagged where work is needed.
>
> **Non-negotiables:**
> - Never store card numbers in our system (Stripe handles card data; we see tokens)
> - Invoice reconciliation must be automated; no monthly "who paid what" spreadsheet
> - Payment failures trigger graceful recovery flows; customers don't lose service silently
> - VAT handled correctly for UK + EU from day one

---

## 1. Scope

### 1.1 What Stripe does for us

- Stores payment methods (card; Direct Debit via Stripe Bacs)
- Creates and manages subscriptions per tier
- Generates and sends invoices (monthly)
- Handles VAT calculation and compliance (via Stripe Tax)
- Manages payment failure retry logic
- Provides a customer-facing portal (manage payment method, see invoices)

### 1.2 What we do in our own code

- Map Clawd tenants to Stripe customers + subscriptions (1:1)
- Listen to Stripe webhooks to update tenant state (active / past_due / cancelled)
- Handle tier changes (upgrade/downgrade triggers Stripe + our own reprovisioning)
- Calculate usage-based costs separately and push as line items to Stripe
- Send our own "payment failed" emails to tenant owners (in addition to Stripe's)
- Enforce service behaviour on payment state (suspend on `past_due > 14 days`, etc.)

### 1.3 What we do NOT use Stripe for

- **Credit card storage outside subscriptions** — we don't take card payments outside subscriptions
- **One-off invoices via Stripe Invoicing product** — we might for Enterprise deals, but default is subscription-based
- **Stripe Payment Links** — not our flow; everything goes through our signup + portal
- **Stripe Connect** — no marketplace; we're not paying anyone

---

## 2. Stripe account setup

### 2.1 Company account

- Stripe account registered to Intel Force Ltd, UK
- GBP as primary currency (EUR, USD available for international customers)
- Stripe Tax enabled (handles VAT automatically once configured)
- Products and Prices set up per tier (see §3)
- Webhooks pointed at our `webhook-receiver` service

### 2.2 Business verification

- Provide Companies House details
- Provide bank account for payouts
- Stripe verifies within a few business days

### 2.3 VAT configuration

- Configure UK VAT in Stripe Tax
- Enable automatic calculation for UK + EU customers
- Set up reverse charge for EU B2B customers (requires valid VAT number entered by customer)
- No VAT for non-UK, non-EU customers (their local tax is their problem per our Terms)

---

## 3. Product and Price model in Stripe

### 3.1 Products

One Stripe Product per tier. Products hold metadata (name, description, tax category).

| Stripe Product ID | Name | Tax category |
|---|---|---|
| `prod_starter` | Clawd Starter | `txcd_10103001` (Software as a service) |
| `prod_growth` | Clawd Growth | `txcd_10103001` |
| `prod_scale` | Clawd Scale | `txcd_10103001` |
| `prod_enterprise` | Clawd Enterprise | `txcd_10103001` |
| `prod_usage_ai` | AI inference overage | `txcd_10103001` |
| `prod_usage_data` | Data provider overage | `txcd_10103001` |

Each product has multiple **Prices** (different currencies, different billing intervals).

### 3.2 Prices

For a single tier like Growth, we have:

| Price ID | Tier | Interval | Amount | Currency |
|---|---|---|---|---|
| `price_growth_monthly_gbp` | Growth | month | £1,800 | GBP |
| `price_growth_annual_gbp` | Growth | year | £18,000 (2 months free) | GBP |
| `price_growth_monthly_eur` | Growth | month | €2,150 | EUR |
| `price_growth_annual_eur` | Growth | year | €21,500 | EUR |
| `price_growth_monthly_usd` | Growth | month | $2,300 | USD |
| `price_growth_annual_usd` | Growth | year | $23,000 | USD |

Similar set for Starter, Scale, Enterprise.

### 3.3 Usage-based items

Usage (AI inference, data provider cost) is added to subscriptions as **metered line items** or reported usage records:

- When a customer's usage for the month exceeds their tier allowance, overage is calculated
- We push a usage record to Stripe mid-month if threshold approaching, or at month-end via cron
- Stripe adds it to the next invoice

For simplicity in v1, we bill usage monthly in arrears as a **one-off invoice item** added before the next subscription renewal, rather than as a true metered subscription item. Less elegant but easier to reason about.

### 3.4 Coupons

For the "Founding Customer 30% off" programme and annual discount:

- Stripe Coupon `FOUNDING30` — 30% off, repeating for 12 months
- Stripe Coupon `ANNUAL2MONTHS` — applied automatically when customer selects annual billing (handled via separate annual price, not a coupon)

---

## 4. Customer and subscription lifecycle

### 4.1 Creating a customer + subscription at trial signup

Sequence when a user completes trial signup:

```
User submits trial signup
  ↓
Clerk creates user
  ↓
Our dashboard creates pending tenant (status=provisioning)
  ↓
Dashboard calls Stripe:
  1. POST /v1/customers  → create Stripe customer
     - email, name, metadata { tenant_id, clerk_user_id }
  2. POST /v1/setup_intents  → collect card details via Stripe Elements
  3. POST /v1/subscriptions  → create subscription
     - customer_id
     - items: [{ price: price_growth_monthly_gbp }]  (example)
     - trial_end: unix_timestamp + 14 days
     - payment_behaviour: default_incomplete  (doesn't error if card has issue; prompts user)
     - collection_method: charge_automatically
     - metadata { tenant_id }
  ↓
Subscription created in `trialing` state
  ↓
Dashboard updates tenant row with stripe_customer_id, stripe_subscription_id
  ↓
Provisioning workflow kicks off (Phase 3)
```

### 4.2 Database mapping

Phase 3 `control.tenants` table needs two additional columns (addendum migration):

```sql
ALTER TABLE control.tenants
  ADD COLUMN stripe_customer_id text,
  ADD COLUMN stripe_subscription_id text;

CREATE INDEX idx_tenants_stripe_customer ON control.tenants(stripe_customer_id);
CREATE INDEX idx_tenants_stripe_subscription ON control.tenants(stripe_subscription_id);
```

And a new table for usage tracking (if we bill usage-based at month-end):

```sql
CREATE TABLE control.usage_records (
  id             bigserial PRIMARY KEY,
  tenant_id      text NOT NULL REFERENCES control.tenants(id),
  period_start   date NOT NULL,
  period_end     date NOT NULL,
  category       text NOT NULL,  -- 'ai_inference', 'data_provider', etc.
  amount_gbp     decimal(10,2) NOT NULL,
  stripe_invoice_item_id text,  -- set when pushed to Stripe
  pushed_at      timestamptz,
  created_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_usage_records_tenant_period ON control.usage_records(tenant_id, period_start);
```

### 4.3 Trial conversion

At trial end (day 14):
- Stripe auto-charges the card
- Webhook `invoice.payment_succeeded` → we mark tenant as `active` (paid)
- If charge fails → webhook `invoice.payment_failed` → we mark tenant as `past_due` and start recovery (see §7)

### 4.4 Tier changes

When a customer upgrades/downgrades via Settings:

```
User confirms tier change
  ↓
Our dashboard:
  1. Call Stripe: POST /v1/subscriptions/{sub_id}
     - items: [{ id: current_item_id, price: new_price_id }]
     - proration_behaviour: 'create_prorations'
  2. Trigger TenantReprovision workflow (Phase 3) to enable/disable agents
  3. Update control.tenants.plan
  ↓
Stripe generates proration on next invoice
```

Proration happens automatically in Stripe. Our side just needs to tell Stripe about the price change.

### 4.5 Cancellation

When a customer cancels (or we terminate for cause):

```
Cancel action
  ↓
Dashboard:
  1. Call Stripe: DELETE /v1/subscriptions/{sub_id}
     - With parameter cancel_at_period_end=true  (for customer cancellation)
     OR
     - With parameter cancel_now=true  (for immediate termination)
  2. Update tenant.status to 'cancelled' or 'terminated'
  3. Schedule data retention per DPA §4.9 (90-day retention, then delete)
```

---

## 5. Webhook handling

### 5.1 Webhook endpoint

Stripe webhooks are received at `/webhooks/stripe` on our `webhook-receiver` service (Phase 1). Critical events update tenant state.

### 5.2 Critical events

| Stripe event | Our action |
|---|---|
| `customer.subscription.created` | No-op (we already know about it from our side) |
| `customer.subscription.updated` | Update tenant plan, status, current_period_end |
| `customer.subscription.deleted` | Mark tenant cancelled |
| `invoice.created` | Log invoice; add to tenant's invoice history |
| `invoice.finalized` | Log finalised invoice |
| `invoice.payment_succeeded` | Mark tenant as `active`; clear any `past_due` state |
| `invoice.payment_failed` | Mark tenant as `past_due`; trigger recovery flow (§7) |
| `customer.updated` | Update mirrored customer metadata |
| `charge.refunded` | Log refund; update tenant invoice history |
| `customer.subscription.trial_will_end` | 3 days before trial end; send reminder email |

### 5.3 Webhook signature verification

Every Stripe webhook includes a signature. Our handler:

```typescript
const signature = req.headers['stripe-signature'];
const event = stripe.webhooks.constructEvent(
  req.rawBody,
  signature,
  process.env.STRIPE_WEBHOOK_SECRET
);
// Process event
```

Rejects unsigned or mis-signed requests. Production webhook secret stored in Secrets Vault (see Phase 3).

### 5.4 Idempotency

Stripe sometimes retries webhooks. Our handler tracks processed event IDs:

```sql
CREATE TABLE control.stripe_events_processed (
  stripe_event_id text PRIMARY KEY,
  event_type      text NOT NULL,
  processed_at    timestamptz NOT NULL DEFAULT now()
);
```

Before processing, check if `stripe_event_id` exists; if yes, skip. If no, process and insert.

### 5.5 Failure handling

- Webhook processing errors → return 5xx to Stripe (Stripe retries)
- Unrecoverable errors → log to observability; page on-call if critical event
- Stuck webhook queue → alert (Prometheus metric: `stripe_webhooks_failed_total`)

---

## 6. Usage-based billing

### 6.1 When usage is charged

Each calendar month:
- Customer's tier subscription renews (fixed fee charged to card)
- During the month, AI inference and data provider costs accumulate (tracked in `control.costs` — Phase 3)
- At month-end (1st of next month, 03:00 UK), cron job computes usage for each tenant

### 6.2 Computation

```sql
SELECT
  tenant_id,
  SUM(cost_gbp) FILTER (WHERE category = 'ai_inference') AS ai_cost,
  SUM(cost_gbp) FILTER (WHERE category = 'data_provider') AS data_cost
FROM control.costs
WHERE period BETWEEN [last month's 1st] AND [last month's end]
GROUP BY tenant_id;
```

Compare to tier allowance:
- Starter: £150/mo allowance
- Growth: £550/mo allowance
- Scale: £1,200/mo allowance
- Enterprise: negotiated allowance

If total > allowance, push overage to Stripe as invoice item on the next subscription renewal.

### 6.3 Pushing to Stripe

```typescript
await stripe.invoiceItems.create({
  customer: stripe_customer_id,
  amount: overage_in_pence, // e.g., 4200 for £42
  currency: 'gbp',
  description: `AI & data usage overage — ${period_label}`,
  subscription: stripe_subscription_id,
  metadata: {
    tenant_id,
    period_start: period_start_iso,
    period_end: period_end_iso,
  }
});
```

Also record in our `control.usage_records` table with `stripe_invoice_item_id` set. Auditable.

### 6.4 Showing usage to customers

Customers see in dashboard Settings → Billing:
- Current month usage (updated daily)
- Projected end-of-month usage (simple projection)
- Historical overages, invoiced

No surprises: if usage is trending toward overage, we send an email at 80% of allowance.

---

## 7. Payment failure recovery

### 7.1 Retry sequence

Stripe handles card retry automatically per its configuration. Default schedule:
- Day 0: charge fails → webhook `invoice.payment_failed` received
- Day 3, 5, 7: Stripe retries automatically (Smart Retries)
- After 4 failed attempts: Stripe marks subscription `past_due` → `unpaid` → `cancelled`

### 7.2 Our communication during recovery

On first failure (Day 0):
- Send email to tenant owner: "Payment failed — we'll retry in 3 days. You can update your card now in settings."
- In-dashboard banner: "Payment issue — resolve before [date]"
- Tenant status: `past_due` (reduced-function mode — see §7.3)

Subsequent failures:
- Day 3: "Second attempt failed. Please update payment details."
- Day 7: "Service will be suspended in 7 days if payment isn't resolved."
- Day 14 (Stripe typically moves to `unpaid` by then): suspend tenant

### 7.3 What "past_due" means operationally

For the customer's tenant during past_due:
- Agents keep running (we don't cut them off on day 1)
- Dashboard shows warnings
- After 14 days of past_due: suspend agents (webhooks stopped, scheduled runs disabled)
- After 30 days of past_due: tenant marked as suspended; data retained per DPA

This is more lenient than some SaaS policies. Reasoning: we've built a relationship; the usual cause is an expired card, not abandonment; the commercial cost of recovering vs losing a customer favours patience.

### 7.4 Recovery

When payment succeeds:
- Webhook `invoice.payment_succeeded` → tenant status returns to `active`
- Agents resume normal operation
- Banner cleared
- Thank-you email sent

---

## 8. Customer-facing billing UI

### 8.1 Customer portal

Stripe provides a hosted customer portal at `billing.stripe.com`. We link customers to it from dashboard Settings → Billing. They can:
- Update payment method
- View invoices
- Cancel subscription (they'll be redirected back to our cancellation flow)

We don't build our own card-management UI. Stripe's is tested, PCI-compliant, and their problem.

### 8.2 What we build ourselves

In dashboard Settings → Billing (per `phase-4-dashboard/views/settings-spec.md §5`):
- Current plan display
- Current month spend tracker (this month's fixed + variable)
- Usage alerts
- Change plan flow (triggers Stripe + our reprovisioning)
- Budget settings (our own soft/hard-stop controls)
- Invoice list (pulled from Stripe, linked to Stripe-hosted PDFs)

---

## 9. VAT handling

### 9.1 UK customers

Stripe Tax automatically:
- Calculates VAT at the standard rate (20%) on invoices
- Adds VAT line item on the invoice
- Collects VAT as part of the charge
- Reports to HMRC via Stripe's tax reporting (we file our own returns using Stripe's data)

We need to:
- Enable UK VAT in Stripe Tax
- Register for VAT with HMRC once threshold reached (£90k turnover, current 2026 threshold — verify)
- File VAT returns quarterly using Stripe's VAT report as primary data

### 9.2 EU customers

B2B (the common case — we're selling to EU agencies, not consumers):
- Customer enters their VAT number during signup
- Stripe validates via VIES (VAT Information Exchange System)
- If valid: reverse charge applies (no VAT added by us; customer handles in their country)
- If invalid: VAT charged at their country's rate

B2C (edge case — individual consumers in EU):
- VAT charged at their country's rate (Stripe handles this too, via OSS scheme potentially)

### 9.3 Non-UK, non-EU

- No VAT added by us
- Customer handles their own local tax obligations per our Terms
- USD and EUR pricing available; check with accountant if we need to register in specific jurisdictions as volume grows

### 9.4 Getting VAT right

VAT is a solvable-once setup. Before launch:
- Engage accountant to confirm Stripe Tax config matches our obligations
- Test with a live EU customer invoice (even a £1 test) to verify VAT applies correctly
- Budget: £500–£1,000 one-off accountant review

---

## 10. Security

### 10.1 API keys

- **Secret key** (sk_live_...): stored in Secrets Vault, never logged, never in git
- **Publishable key** (pk_live_...): used in frontend Stripe Elements; safe to expose
- **Webhook secret** (whsec_...): stored in Secrets Vault; used to verify webhook signatures

### 10.2 Restricted keys

Different Stripe API keys for different services:
- Main key (full access) — used by billing service only
- Read-only key — for dashboard reads (e.g., fetching invoice PDFs)
- Webhook-only key — for receiving webhooks only

Principle: least privilege per service.

### 10.3 PCI

We're not PCI-in-scope because:
- Card numbers never touch our infrastructure
- Customers enter card details into Stripe Elements (iframe served by Stripe)
- We receive only tokens (e.g., `pi_...` payment intent)

Maintain via: never log request bodies containing card data; never accept card data in our APIs; verify no card numbers in error logs.

---

## 11. Reporting and reconciliation

### 11.1 Monthly reconciliation

First week of each month, run:
- Stripe invoices for previous month
- Our `control.usage_records` for previous month
- Cross-check: every Stripe invoice item should match a usage record; every tenant's usage record should be reflected in Stripe

Automate this. Discrepancies page Maddox (or whoever owns finance).

### 11.2 Dashboard visibility

Platform admin dashboard has a `Revenue` page (CC13 Admin Operations):
- MRR (Monthly Recurring Revenue) — aggregate
- Per-tier breakdown
- Growth/churn rate
- ARR (MRR × 12)
- Usage overages per tenant

### 11.3 Export for accountant

Monthly CSV export:
- Tenant, plan, subscription status, invoice amount, VAT, paid date, currency
- Sent automatically to accountant@clawd.ai (external) on 5th of month

---

## 12. Testing

### 12.1 Stripe test mode

Full dev + staging environments use Stripe test mode. Test cards:
- `4242 4242 4242 4242` → always succeeds
- `4000 0000 0000 0002` → always declines
- `4000 0025 0000 3155` → requires 3DS authentication
- `4000 0000 0000 9995` → charge succeeds, transfers later fail

### 12.2 Critical test flows

- Happy path: trial signup → trial end → first charge succeeds → monthly renewal
- Tier change: upgrade triggers Stripe + reprovisioning; proration correct
- Payment failure: declined card → retry → succeed; state transitions correct
- Cancellation: cancel_at_period_end → active through period → cancelled
- Usage billing: month-end cron → invoice items added → included in next invoice

### 12.3 Stripe webhooks in dev

Use Stripe CLI: `stripe listen --forward-to localhost:3001/webhooks/stripe`. Forwards events from Stripe to local dev.

---

## 13. Observability

Metrics (Prometheus):
- `stripe_api_calls_total{endpoint, status}` — calls to Stripe
- `stripe_webhook_received_total{event_type}` — webhooks arriving
- `stripe_webhook_processed_total{event_type, status}` — processing outcomes
- `stripe_payment_failures_total` — for alerting
- `subscription_status_changes_total{from, to}` — state transitions

Alerts:
- Webhook processing error rate > 1% → page
- Stripe API error rate > 5% → warn
- No successful `invoice.payment_succeeded` in 24 hours during a billing day → warn (maybe a problem)

---

## 14. Failure modes

| Scenario | Impact | Mitigation |
|---|---|---|
| Stripe API down | Billing operations pause | Cache subscription data; webhook queue flushes when Stripe recovers |
| Webhook delivery delayed | Tenant state lags Stripe | OK for short delays; alert if >1h |
| Our webhook handler bug | Events unprocessed | Dead letter queue; manual replay tool |
| Invoice dispute / chargeback | Funds withheld | Stripe notifies; we respond via Stripe's portal; rare |
| Double-charge bug | Customer charged twice | Webhook idempotency (§5.4) prevents; if it happens anyway, refund via Stripe |
| Card data logged accidentally | Compliance issue | Log-redaction hooks; regular log audits |

---

## 15. Implementation checklist (for CC20)

- [ ] Stripe account created, verified, UK-registered
- [ ] Stripe Tax enabled, UK + EU VAT configured
- [ ] Products + Prices created (all tiers, all currencies, monthly + annual)
- [ ] Webhook endpoint at `webhook-receiver/webhooks/stripe`
- [ ] Webhook signature verification
- [ ] Idempotency table + check
- [ ] Tenant-Stripe linkage (database columns)
- [ ] Usage records table + cron job
- [ ] Stripe SDK integration in dashboard (tRPC procedures for customer creation, tier change, cancellation)
- [ ] Customer portal link in Settings
- [ ] Payment failure recovery flow (emails, in-dashboard banner, service degradation rules)
- [ ] Monthly reconciliation script
- [ ] Admin revenue dashboard
- [ ] Test coverage: happy path, tier change, payment failure, usage billing
- [ ] Accountant review of VAT setup

---

## 16. Open decisions

**OD-P5-22:** Stripe Tax or manual VAT?
- **Recommendation:** Stripe Tax. Worth the ~0.5% surcharge; manual VAT at our scale is a distraction.

**OD-P5-23:** Annual billing — require full upfront, or spread?
- **Recommendation:** Full upfront. That's the whole point of annual pricing (cashflow benefit). Spreading annual across 12 is just a monthly plan with extra steps.

**OD-P5-24:** Grace period on past_due — 14 days or 7?
- **Recommendation:** 14 days. Most past_due is innocent card issues. 7 is too aggressive and will cost us customers.

**OD-P5-25:** Stripe Revenue Recognition (Stripe Sigma)?
- **Recommendation:** Skip for v1. Manual reconciliation is fine at our volume. Revisit at 50+ customers.

---

## 17. Related

- `pricing/pricing-spec.md` — the tiers this integrates with
- `msa-template.md` — billing terms referenced in §4
- `phase-4-dashboard/views/settings-spec.md` §5 — billing panel UI
- `phase-3-platform/postgres/schema-spec.md` — tables referenced (extension migration needed)
- `phase-1-poc-stack/platform-specs/webhook-receiver-spec.md` — the service that receives Stripe webhooks

---

*This spec defines a minimum-viable Stripe integration. Billing is a surface with many edge cases; expect iteration through the first few months as real-world scenarios surface.*
