# Cost Governance Runbook

**The routine operations that keep platform costs under control. Weekly reviews, alert thresholds, budget adjustments, per-tenant economics monitoring.**

> **Audience:** the platform operator running the weekly rhythm. For v1 that's Maddox; later whoever owns operations.
>
> **Status:** v1.0. Designed for the economics captured in `phase-5-business-legal/pricing/pricing-spec.md` — Starter 76% margin, Growth 74%, Scale 75%, Enterprise 52%+.
>
> **Philosophy:** cost anomalies compound fast in AI-heavy workloads. A tenant losing money quietly for 30 days is a real threat. Weekly reviews are the primary detection mechanism, plus real-time alerts for acute anomalies.

---

## 1. Why cost governance is a first-class routine

AI-heavy platforms differ from traditional SaaS in one key way: compute cost scales roughly with usage, not with headcount. A chatty customer on a £450/mo Starter tier can easily rack up £800/mo in inference if left unchecked. Margins evaporate silently.

We need three things:
1. **Visibility** — know what's happening
2. **Alerting** — know when something's wrong before it's a crisis
3. **Levers** — have the dials to pull when things go sideways

This runbook covers all three.

---

## 2. The weekly rhythm

Every Monday (after on-call handoff): 45-minute cost review. In the first year this is Maddox; as team grows, delegate to ops lead.

### 2.1 Weekly cost review checklist

```
□ 1. Open Grafana "Platform Economics" dashboard
□ 2. Top-level questions:
     → Total platform spend last 7d vs same 7d a month ago
     → Per-tenant margin (revenue - cost) for active tenants
     → Tenants trending towards budget exceedance
□ 3. Anomaly review:
     → Any tenant with >30% WoW cost change?
     → Any single agent run costing >£5?
     → Any scheduled jobs running more/less than expected?
□ 4. Provider cost review:
     → Anthropic vs Cohere vs Data providers split
     → Is any provider suddenly dominating cost?
□ 5. Forecast:
     → Projected end-of-month spend
     → Any tenants likely to exceed budget this month?
     → Platform-wide budget on track?
□ 6. Action items logged in Linear
```

### 2.2 Output: weekly cost report

Posted to `#ops` at end of each Monday review:

```
📊 Weekly cost review — Week of 2026-04-21

Platform spend: £4,231 (+8% WoW, within budget)
Active tenants: 12
Aggregate margin: £14,769 (77.7%)

Anomalies:
• tnt_meadowlane: Content Creator spend up 60% — investigating
• tnt_willowcrest: new tenant, ramp-up cost normal
• Anthropic share up to 72% (was 68%) — watching

Actions:
• Talk to Meadow Lane about Content Creator usage spike (owner: Jack, by Thu)
• Review cost alert threshold for new-tenant ramp (owner: Maddox, by Fri)

Next review: Mon 2026-04-28.
```

### 2.3 What "healthy" looks like

| Metric | Target |
|---|---|
| Per-tenant margin | >70% at Starter/Growth/Scale; >45% at Enterprise |
| WoW variance per tenant | <20% under normal use |
| Platform-wide provider split | Anthropic 65-75% typical; Cohere 10-15%; Data 5-15%; Other 5% |
| Tenants over 80% budget mid-month | 0-2 at most; more is an alert |
| Tenants exceeding budget end-of-month | <5% of tenants in a month |

---

## 3. Real-time alerts

Complementary to weekly reviews — catch things mid-week.

### 3.1 Alert catalogue

Lives in `phase-3-platform/observability/observability-spec.md`; cost-specific extract below.

| Alert | Condition | Severity | Routes to |
|---|---|---|---|
| `tenant_spend_rate_spike` | Rate 10x 24h avg, sustained 5 min | SEV-2 | PagerDuty + #alerts |
| `tenant_budget_70pct_by_day_10` | Hit 70% budget before day 10 of month | SEV-3 | #alerts + tenant Slack |
| `tenant_budget_exceeded_soft` | Tenant on soft_alert exceeded | SEV-2 | PagerDuty + #ops + tenant |
| `tenant_budget_exceeded_hard` | Tenant on hard_stop hit stop | SEV-3 (informational) | #ops + tenant |
| `platform_spend_daily_gt_budget` | Platform-wide daily spend exceeds plan | SEV-2 | PagerDuty + #ops |
| `single_invocation_cost_gt_5gbp` | Any single invocation > £5 | SEV-3 | #alerts |
| `anthropic_monthly_commit_85pct` | Anthropic monthly commit at 85% | SEV-3 | #ops |
| `tenant_idle_but_paid` | Paying tenant with zero invocations 14+ days | SEV-4 | #ops |

### 3.2 Alert fatigue prevention

Don't add alerts that fire more than once a month on average. Noisy alerts get ignored; the signal gets lost.

Quarterly review: look at alerts that fired; any that were false positives or acted-upon routinely should be tuned or removed.

---

## 4. Cost anomaly investigation

When an alert fires or a weekly review surfaces something odd:

### 4.1 Three-level drill-down

```
Level 1: Platform-wide
  → Is this affecting multiple tenants?
  → Is one provider's cost suddenly spiking?

Level 2: Per-tenant
  → Which agent(s) are driving the cost?
  → Invocation rate up, or per-invocation cost up?

Level 3: Per-invocation
  → Look at specific invocations
  → Token usage — prompt vs completion split
  → Tool calls — how many? which tools?
  → Did the agent loop?
```

### 4.2 Investigation queries

```sql
-- Platform-wide last 24h cost by provider
SELECT provider, sum(cost_gbp) as total_gbp
FROM control.costs
WHERE created_at > now() - interval '24 hours'
GROUP BY provider
ORDER BY total_gbp DESC;

-- Top 20 most expensive invocations in last 7 days
SELECT tenant_id, agent, cost_gbp, duration_ms, started_at
FROM control.invocations
WHERE started_at > now() - interval '7 days'
ORDER BY cost_gbp DESC
LIMIT 20;

-- Per-tenant spend vs budget this month
SELECT
  t.client_slug,
  t.cost_budget_gbp,
  sum(i.cost_gbp) as spent,
  round(sum(i.cost_gbp)::numeric / t.cost_budget_gbp * 100, 1) as pct_used
FROM control.tenants t
LEFT JOIN control.invocations i
  ON i.tenant_id = t.id
  AND i.started_at >= date_trunc('month', now())
WHERE t.status = 'active'
GROUP BY t.id, t.client_slug, t.cost_budget_gbp
ORDER BY pct_used DESC;

-- Invocations per agent per tenant last 7 days
SELECT tenant_id, agent, count(*) as invocations, sum(cost_gbp) as gbp
FROM control.invocations
WHERE started_at > now() - interval '7 days'
GROUP BY tenant_id, agent
HAVING count(*) > 5
ORDER BY gbp DESC;
```

### 4.3 Common anomaly patterns

| Pattern | Likely cause | Fix |
|---|---|---|
| One tenant's invocation count 10x normal | Misconfigured schedule; looping agent | Suspend tenant; investigate; see tenant-incidents runbook |
| One agent's avg cost per invocation 5x normal | Agent prompt regression (more tokens needed) | Revert prompt; investigate version |
| Anthropic share jumped 20% | Changed model (e.g., agent switched from Sonnet to Opus) | Audit agent config; pin model |
| One invocation >£5 | Tool-use loop; huge context; retrieval returned too much | Check logs; may need agent-level guardrails |
| Platform cost up but tenant costs flat | Overhead cost (Librarian nightly sweeps, embeddings) growing | Review embedding ROI; reduce Librarian frequency if warranted |
| New tenant onboarding cost (one-time) high | Expected — voice-profile-extraction + initial indexing | No action; document "ramp-up cost" in their first month |

---

## 5. Per-tenant budget enforcement

### 5.1 Two budget modes

Defined in Phase 3 schema and Phase 4 Settings view:
- **soft_alert** (default) — agents continue; Slack alerts at 80%, 100%, 120%
- **hard_stop** — agents pause when budget hits 100%; resume next calendar month or manual increase

Most tenants start on soft_alert. Tenants who've had a previous runaway, or risk-averse ones, move to hard_stop.

### 5.2 When to move a tenant to hard_stop

- After a confirmed runaway incident (automatically recommended in postmortem)
- Customer requests it (often risk-averse tenants on Starter tier)
- Platform-wide cost pressure (temporarily, to protect margins)

### 5.3 Budget increases

When a tenant genuinely needs more capacity:
- Commercial review: upgrade to next tier, or raise budget on current tier?
- Tier upgrade: renewal or mid-cycle prorated — depends on Stripe config
- Budget raise within tier: supported; document rationale in tenant notes

Budget cuts:
- Less common but sometimes requested (tenant going dormant)
- Confirm in writing; take effect next calendar month

### 5.4 Month-boundary handling

Budgets reset on the 1st of each calendar month (UTC). Running totals carry no rollover — you don't accumulate "unused" budget.

Enterprise tenants can negotiate rolling 12-month budgets instead. Handled in their bespoke contract.

---

## 6. Platform-level cost levers

When platform-wide costs need adjusting:

### 6.1 Immediate levers (can act this week)

- **Increase retrieval result caching TTL** — reduces vault-search calls to embed-queries
- **Reduce Librarian sweep frequency** — from nightly to every-other-night
- **Model routing** — use Haiku for cheap-to-draft content, Sonnet for critical outputs, Opus only where explicitly warranted
- **Turn off non-essential embeddings** — for tenants with small vaults, skip embedding content until vault grows
- **Aggressive prompt caching (Anthropic)** — ensure every long system prompt uses cache breakpoints

### 6.2 Medium-term levers (next 1-2 months)

- **Quarterly Anthropic commit renegotiation** — if we're hitting monthly commits, negotiate larger commits for better per-token rate
- **Cohere alternative embedding models** — cheaper variants for smaller tenants
- **Self-host embeddings** — if Cohere spend passes £500/mo; self-hosted bge-m3 or similar on Hetzner GPU
- **Tier pricing adjustment** — if consistent margin pressure, pricing review

### 6.3 Long-term levers (6+ months)

- **Build our own fine-tuned models for common patterns** — if Proposal Builder is 50% of platform cost, a fine-tuned specialist might win
- **Platform consolidation** — combine tenant containers, share state more aggressively
- **Regional arbitrage** — run inference in cheapest regions (only if data-residency allows)

---

## 7. Unit economics tracking

### 7.1 Per-tenant P&L

Maintained in the Grafana "Platform Economics" dashboard or (manually, for v1) a spreadsheet:

| Tenant | Plan | MRR | Variable cost | Support cost | Margin | Margin % |
|---|---|---|---|---|---|---|
| Meadow Lane | Growth | £1,800 | £240 | £150 | £1,410 | 78% |
| ... | | | | | | |

**MRR** — net of discounts, excluding one-time setup
**Variable cost** — AI inference + providers + per-tenant storage
**Support cost** — allocated per plan tier (Starter £30/mo, Growth £100/mo, Scale £300/mo, Enterprise £1,000/mo)
**Margin %** — (MRR - variable - support) / MRR

### 7.2 Outliers

Each review, flag:
- Margin <50% — why? high-touch support? misconfigured budget? commercial conversation needed
- Margin >90% — are we undercharging? or is tenant inactive? potential churn signal
- Negative margin — action required: raise budget, raise price, or off-board

### 7.3 First-month anomaly

New tenants usually have low margin their first month (ramp-up costs). Don't panic. Track as a separate bucket; the margin stabilises by month 3.

---

## 8. Platform-wide cost budget

### 8.1 The budget itself

Not a hard limit (we're not on metered cloud); but a planning number. For the first year:

| Month (from launch) | Tenants (target) | Platform cost budget | Revenue target | Margin target |
|---|---|---|---|---|
| M1-M3 | 3-5 | £800 | £5,000 | 80%+ |
| M4-M6 | 10 | £2,500 | £15,000 | 83% |
| M7-M9 | 20 | £5,500 | £30,000 | 82% |
| M10-M12 | 30-40 | £10,000 | £50,000 | 80% |

Budget pressure signals we're over-serving or under-pricing.

### 8.2 Monthly budget review

End of each month:
- Actual spend vs budget
- Revenue vs target
- Adjustments to next month's budget based on patterns

Documented in `/vault/ops/finance/monthly-budget-reviews/YYYY-MM.md`.

---

## 9. Anthropic-specific cost management

Anthropic is our biggest cost line item. Dedicated attention warranted.

### 9.1 Anthropic usage dashboard

Anthropic's own usage console shows:
- Requests per day
- Tokens in vs out
- Cache hit rate
- Spend by model

Cross-reference with our internal tracking. Any discrepancy >2% triggers investigation (billing error, our cost ingestion bug, or undetected traffic).

### 9.2 Monthly commits

We have an organisation-level monthly commit with Anthropic. Rules:
- Commit is usage-or-lose-it; unused commit doesn't carry over
- Exceeding commit charges at higher on-demand rate
- Renegotiate every 3-6 months as usage grows

### 9.3 Prompt caching

Every agent's system prompt uses cache breakpoints for the stable portion. Cache hit rate target: >60% on system-prompt tokens.

Dashboard panel: `anthropic_cache_hit_rate` by tenant + agent. Low hit rate for a specific agent = investigate.

### 9.4 Model selection economics

Current model pricing (verify quarterly as Anthropic updates):

| Model | Input / 1M | Output / 1M | Use case |
|---|---|---|---|
| Claude Haiku 4.5 | low | low | Caption Writer, simple content, classification |
| Claude Sonnet 4.6 | medium | medium | Most agents — default |
| Claude Opus 4.7 | high | high | High-stakes creative (complex proposals, strategic docs) |

Agent config specifies default model + fallback. Reviews surface agents that could drop from Opus to Sonnet without quality loss.

---

## 10. Customer-facing cost comms

### 10.1 Budget alerts to tenants

Tenant receives Slack + email when:
- 70% of budget used (informational)
- 90% of budget used (warning)
- 100% reached (for hard_stop: agents paused; for soft_alert: continuing but flagged)
- 120% reached (for soft_alert: requires acknowledgement)

Language: factual, non-alarming. Example:

> "Your Clawd account hit 90% of this month's budget (£1,620 of £1,800). At current pace, you'll finish the month around £1,750. No action needed unless you'd like to adjust. [Raise budget] [View usage]"

### 10.2 Cost reports

Monthly email to each tenant's owner (1st of each month):

> "Hi {{name}},
>
> Your Clawd usage for March 2026:
>
> — Total spend: £1,423 of £1,800 budget (79%)
> — Invocations: 484
> — Top agent: Proposal Builder (43% of spend)
>
> Full detail in your dashboard: {{link}}
>
> Your April budget is £1,800. [Adjust budget] if you'd like to change it."

### 10.3 Cost surprises

If a tenant is surprised by their bill:
- Apologise once; don't make it 5 paragraphs of sorry
- Show them the data; link to the invocation-level detail
- Offer a credit if any part of the spend was platform-caused (e.g., agent bug)
- Discuss next-month budget adjustment

Never hide cost detail. Full transparency is a core part of the product experience.

---

## 11. Quarterly cost optimisations

Every quarter, schedule a 2-hour optimisation review:

### 11.1 Prompt efficiency audit

- Are system prompts as short as possible while maintaining quality?
- Are we passing unnecessary context?
- Are tool descriptions as concise as possible?

Often saves 10-30% on token counts.

### 11.2 Cache hit rate audit

- Per-agent cache hit rate trending
- Opportunities to move static content to earlier in prompt (before cache breakpoint)

### 11.3 Model routing audit

- Are we using the right model for each agent?
- Any agents overusing Opus that Sonnet could handle?
- Any agents stuck on Sonnet that Haiku could do?

### 11.4 Tool usage audit

- Which tools are called most? Most expensive?
- Are we calling retrieval too eagerly?
- Any tool doing work we could cache?

### 11.5 Data provider audit

- Prospeo / Kaspr / Apollo costs vs value
- Any provider that could be swapped for cheaper alternative?
- Per-record cost trending

---

## 12. Budget forecasting

### 12.1 Simple forecast model

For end-of-month forecast per tenant:
```
projected_month_spend = current_spend + (daily_avg_spend × days_remaining)

where:
  daily_avg_spend = current_spend / days_elapsed
```

Simple, conservative (assumes constant rate). Good enough for v1.

### 12.2 Red flags in forecasts

- Projected > budget: alert the tenant early
- Projected < 50% of budget: tenant may be inactive — check in
- Projected much higher than previous months: usage change; investigate
- Projected much lower: signal of disengagement; commercial check-in

### 12.3 Platform forecast

Sum across tenants; compare to monthly budget. Weekly review includes this projection.

---

## 13. Who decides what

| Decision | Who | When |
|---|---|---|
| Raise/lower a tenant's budget | Account owner (Maddox/Jack) | Weekly review or customer request |
| Move tenant to hard_stop | Operator | Post-runaway incident or customer request |
| Suspend tenant for cost reasons | IC during incident | Acute runaway |
| Change platform-wide model routing | Platform lead (Maddox) | Quarterly review |
| Adjust pricing tier | Commercial lead (Maddox) + whole team review | Semi-annually, not ad hoc |
| Off-board a loss-making tenant | Commercial lead + CEO (Maddox) | After two failed commercial conversations |

---

## 14. Related

- `routines/secret-rotation-runbook.md` — routine ops work
- `runbooks/tenant-incidents.md` §3 — cost runaway as an incident
- `phase-3-platform/observability/observability-spec.md` — alert definitions
- `phase-4-dashboard/views/operations-control-spec.md` — dashboard cost module
- `phase-4-dashboard/views/settings-spec.md` §5 — budget management UI
- `phase-5-business-legal/pricing/pricing-spec.md` — pricing model that cost governance protects
