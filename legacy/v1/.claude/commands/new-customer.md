---
description: Onboard a new customer — creates tenant config, sets up Relevance AI clone, generates manifest, prepares install instructions.
---

# /new-customer

Run the customer onboarding script. This is the full technical onboarding flow that turns "signed contract" into "installed and working."

## Prerequisites

Before running this command, you must have:

- Customer signed MSA or Service Agreement (Phase 5 templates)
- Customer accepted DPA if applicable
- Payment method set up in Stripe (manual invoice OK for v1)
- Access to customer's M365 tenant admin for the install call
- Customer's employee handbook in a format we can index (PDF, docx, etc.)

## Usage

```
/new-customer                          # interactive wizard
/new-customer --company="Acme Ltd"     # start with company name
```

## What I do

Walks through the onboarding in the order specified in `docs/teams-hr-agent/04-deployment-guide.md`:

### Step 1: Gather customer info

Collect:
- Company legal name (for MSA reference)
- Company domain (for email addresses)
- M365 tenant ID (find via customer admin: `https://portal.azure.com/#home` → Microsoft Entra ID → Overview)
- Primary contact name, role, email
- HR Lead name, AAD object ID (for initial config)
- Company tone preference (warm / formal / casual)
- Handbook location (customer uploads to shared drive)

### Step 2: Create tenant config

Generate unique tenant ID (UUID), build initial config:

```json
{
  "tenantId": "abc-123",
  "companyName": "Acme Ltd",
  "companyTone": "Warm and professional",
  "primaryContact": {
    "name": "...",
    "email": "...",
    "aadObjectId": "..."
  },
  "hrLead": {
    "name": "Sarah Chen",
    "aadObjectId": "...",
    "conversationReference": null  // captured on first DM
  },
  "relevanceAgentId": "...",  // captured after clone
  "handbookKbId": "...",       // captured after indexing
  "enabledAgents": ["hr"],
  "createdAt": "2026-04-23T...",
  "tier": "founding" | "starter" | "growth" | "scale"
}
```

Save to KV:
```bash
wrangler kv:key put --binding=TENANT_CONFIG "tenant_config:abc-123" @config.json --env=production
```

### Step 3: Clone Relevance AI agent

```bash
# Clone the HR template agent for this customer
curl -X POST https://api-d7b62b.stack.tryrelevance.com/latest/agents/{template_id}/clone \
  -H "Authorization: $RELEVANCE_API_KEY" \
  -d '{ "name": "Acme Ltd HR Agent" }'

# Capture returned agent_id → save to config
```

### Step 4: Index customer handbook

```bash
# Upload handbook to Relevance AI knowledge base
# (Interactive: prompts for file path)
```

### Step 5: Update tenant config with agent + KB IDs

Merge the `relevanceAgentId` and `handbookKbId` into the tenant config, write back to KV.

### Step 6: Generate customer install package

Create a zip containing:
- Teams app manifest (`teams-app/manifest.json` — shared across all customers, unchanged)
- Install instructions PDF (Phase 5 template)
- Admin consent URL (constructed per customer tenant)

The admin consent URL:
```
https://login.microsoftonline.com/{customerTenantId}/adminconsent?client_id={MICROSOFT_APP_ID}&redirect_uri=https://api.intelforce.ai/consent-complete
```

### Step 7: Smoke test preparation

Print the test scenarios to run with HR Lead during install call:

```
Install call smoke tests:

1. Simple policy question
   - Test message: "What's the holiday policy for carry-over days?"
   - Expected: Relevance responds with handbook-based answer
   - HR Lead sees approval card
   - Approve works, reply appears in source channel

2. Semi-complex query
   - Test message: "I'm thinking about working from Spain next month, is that allowed?"
   - Expected: moderate sensitivity, with citations from handbook

3. Escalation scenario
   - Test message: "I want to raise a formal grievance about my manager"
   - Expected: sensitivity=1.0, escalation card (not approval card), 
     holding message sent to employee
```

### Step 8: Install call

During the live install call with the customer IT admin:

1. Share the manifest zip
2. Walk through upload in Teams Admin Center
3. Walk through admin consent URL (grants API permissions)
4. Verify app appears in customer's Teams as expected
5. Run smoke test 1 with HR Lead
6. Run smoke test 2
7. Run smoke test 3 (verify escalation doesn't auto-reply)
8. Configure weekly report schedule + recipients

### Step 9: Post-install checklist

- [ ] Add customer to active tenants list in internal tracker
- [ ] Send welcome email with first-week expectations (Phase 5 `sales-and-case-study-playbook.md` §2)
- [ ] Schedule 72-hour check-in call
- [ ] Schedule week 1 review call
- [ ] Activate Sentry tenant context
- [ ] Enable monitoring alerts for this tenant

### Step 10: Service delivery kickoff

Switch to `gtm-execution` skill's first-customer protocol:
- Daily check-ins for 72 hours
- Retune prompts aggressively based on feedback
- Capture quotable moments for case study

## Output

At the end:

```
NEW CUSTOMER ONBOARDING COMPLETE

Customer: Acme Ltd
Tenant ID: abc-123-def-456
Tier: Founding (£400/month)
Relevance agent: agent_xyz789
Handbook indexed: kb_xyz789

Tenant config saved to KV.
Install package ready: /Users/.../acme-ltd-install/
Smoke tests passed: 3/3
HR Lead (Sarah Chen) conversation reference captured.

Next steps:
1. Send welcome email (template in docs/phase-5-business-legal/sales-and-case-study-playbook.md §2)
2. Schedule 72-hour check-in (book now in your calendar)
3. Monitor first day's messages via /tail production --tenant=abc-123-def-456
4. On day 7: run first weekly report manually if cron hasn't fired (to verify)

Welcome aboard. Time to deliver.
```

## If something fails

### Tenant config save fails
Likely KV not set up correctly. Check binding in wrangler.toml.

### Relevance clone fails
- Rate limit? Wait 60s and retry
- Permissions? Check `RELEVANCE_API_KEY` has clone scope
- Template agent not found? Verify template ID

### Handbook indexing fails
- File format issue — convert to PDF
- File too large — split or summarise
- Encoding issue — re-save as UTF-8

### Install call smoke tests fail
- Scenario 1 fails: Worker/bot auth — check JWT audience + app ID
- Scenario 2 fails: handbook indexing — reindex and retest
- Scenario 3 fails: sensitivity classification — tune Relevance prompt (don't defer — escalations are non-negotiable)

## Cross-references

- Full deployment guide: `docs/teams-hr-agent/04-deployment-guide.md`
- Legal templates: `docs/phase-5-business-legal/`
- Service delivery: `docs/gtm-pack/05-manual-service-runbook.md`
- Ops runbooks active: Phase 6 is now live for this customer

## When NOT to use

- Customer hasn't signed MSA yet → not ready
- Technical scaffolding not complete (Worker not deployed) → build first
- You're experimenting or doing dev onboarding → this script is for real customers

## One-sentence summary

This is the "real customer goes live" runbook — every step from contract-signed to first-week-service.
