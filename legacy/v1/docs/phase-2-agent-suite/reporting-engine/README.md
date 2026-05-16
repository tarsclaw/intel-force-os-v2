# Reporting Engine

**Purpose:** Produce monthly client reports synthesising vault activity + integration data (HubSpot, GA4, Stripe, etc.) into a narrative + numbers package.

**Trigger:** Monthly cron (1st of month 06:00 UTC) + manual (weekly snapshot for mid-month check-ins).

**Output:** Markdown report per client in `/vault/reports/monthly/` + PDF export + Gmail draft to sales lead.

**Tier availability:** All tiers.

---

## What it does

Monthly reports are the retention weapon. A client who receives a clean, specific, on-brand monthly report feels their money is being earned — even when the month was uneventful. Reporting Engine builds this report from the ground up every month:

- Pulls what was actually delivered this month (from the vault — proposals drafted, content published, follow-up sequences sent, captions produced)
- Pulls external metrics from integrations (GA4 visits, HubSpot deal movement, Stripe revenue if relevant)
- Compares to last month and to the commitments made in the signed proposal
- Writes a narrative — not a spreadsheet dump — in the client's voice

The agent produces a first draft. The sales lead reviews, adds any relational context (wins, concerns, plans for next month), then sends.

## What it needs

- `/vault/clients/{slug}/00-context.md` — who this client is, what was sold
- `/vault/clients/{slug}/proposals/*.md` with status=signed — baseline commitments
- `/vault/reports/monthly/` — last month's report for comparative phrasing
- Integration MCPs: HubSpot, GA4, Stripe (tenant-configurable)
- `/vault/brand/voice-profile.md`

## What it doesn't do

- Invent numbers — every number must be sourced from an integration or the vault
- Report on clients with <30 days of data (escalates as `RETENTION_CONTEXT_MISSING`)
- Explain underperformance — flags it for the human; never tries to spin KPI misses
- Send the report automatically — always drafts, human sends

## Cost per run

~£0.80 per report. Runs 10–50 times/month per tenant depending on client portfolio.

## Related

- **Client Onboarder** (establishes baseline proposal commitments this agent reports against)
- **Librarian** (pre-indexes vault content so this agent's retrieval is fast)
