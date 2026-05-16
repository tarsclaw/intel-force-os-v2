# 04 — Per-Customer Deployment Guide

**How to onboard a new customer to Intel Force OS in Teams. 30–45 minutes of your time, 10 minutes of the customer's.**

This is the operational runbook you follow for customer 1, customer 2, and every customer until you automate onboarding in v2.

---

## 1. Who does what

| Role | Tasks | Time commitment |
|---|---|---|
| **You (Maddox)** | Pre-onboarding prep, running the install call, configuring tenant, smoke testing | 30-45 min |
| **Customer IT admin** | Approving app sideload, granting admin consent | 10 min |
| **Customer HR Lead** | Sharing handbook, installing app, first-time testing | 15 min (during kickoff call) |

---

## 2. Pre-onboarding checklist (do 24h before install call)

Send this to customer during scheduling:

```
Hi [HR Lead],

Ahead of our install call on [date/time], please make sure:

1. Your IT admin is available in the call (even briefly, for a 2-minute
   sideload approval) — OR they've pre-approved me to sideload via the
   Teams Admin Center and given me sideload permission.
   
2. Your company handbook is accessible as a PDF, DOCX, or Google Doc — 
   we'll upload it to index during the call.
   
3. You have admin access to your Breathe HR (or other HR system) for the 
   read-only integration — if not, get that sorted beforehand.

4. You know which Teams channel you want the bot to listen to — typically 
   it's #hr or a general HR channel. If you don't have one, we'll create 
   one during the call.

That's it. See you [time].

— Maddox
```

Your pre-call prep on your side:

- [ ] Create per-tenant Relevance AI agent (clone from template)
- [ ] Generate tenant config scaffold locally (script in `onboarding/new-tenant.ts`)
- [ ] Test account creation: a test user in your dev tenant impersonating the customer HR Lead
- [ ] Review their LinkedIn, company website for any contextual cues (tone, size, industry)

---

## 3. The install call — 45-minute script

### 3.1 Minutes 0–5: intros, context setting

- "Hi Sarah, thanks for jumping on. I'm going to walk us through the install. By the end of this call, the bot will be running in your Teams and you'll have handled a few test messages with it."
- Confirm participants: you, HR Lead, IT admin (even briefly)
- "I'll screen-share the whole time so you can see exactly what I'm doing."

### 3.2 Minutes 5–10: IT admin approval (the only time you need them)

Two paths, depending on what the IT admin has done:

**Path A — They can sideload during the call:**
- Share the `dist/intel-force-os-v{latest}.zip` via chat
- Walk them through Teams Admin Center → Manage Apps → Upload → approve for their tenant
- Confirm they've approved admin consent for the app permissions
- IT admin can leave after 5 minutes

**Path B — They've pre-approved you as a sideloader:**
- You sideload via Teams directly (IT admin has granted you Teams app upload rights)
- This is faster but requires prior trust and probably only works for agencies/small companies

### 3.3 Minutes 10–15: HR Lead installs the app

- HR Lead opens Teams, clicks Apps → Intel Force OS (it's now available in their catalogue)
- Click **Add**
- 1:1 chat with Intel Force OS bot opens automatically
- Bot sends its welcome card: *"Hi Sarah — I'm Intel Force OS. I'll read HR messages in the channels you point me at, draft replies, and flag anything sensitive. Let's get configured."*

### 3.4 Minutes 15–25: you configure the tenant (live via script)

You share screen and run the onboarding script from your terminal:

```bash
cd intel-force-os
npm run onboard:new-tenant
```

The script prompts for:

```
Customer M365 tenant ID: abc-123-acme-tenant
Customer name: Acme Consulting Ltd
Customer domain: acme.com
HR Lead email: sarah@acme.com
HR Lead Entra ID object ID: [Claude Code script can fetch this via Graph]
Backup HR Lead email (optional): jack@acme.com

Teams channel bot should listen to: #hr
Company tone description: "Warm and professional; we're a 60-person tech
                          consultancy in Bristol; first names are fine;
                          avoid corporate jargon."

Approval mode (all | sensitive_only | none) [all]: all
Sensitivity threshold [0.5]: 0.5

Weekly report enabled? (y/n) [y]: y
Weekly report time [monday_09:00_BST]: monday_09:00_BST

Relevance AI agent: [auto-clone from template or use existing ID]

Confirm and write to Cloudflare KV? (y/n) y
Writing tenant_config:abc-123-acme-tenant...
✅ Done.
```

Behind the scenes: script writes to Cloudflare KV, creates Relevance AI agent clone, creates handbook knowledge base.

### 3.5 Minutes 25–30: upload handbook + prime knowledge base

- Customer shares their handbook (PDF/DOCX/Google Doc)
- You drag-and-drop into Relevance AI knowledge base (or script automates via API)
- Indexing takes 2-5 minutes; continue call
- Do a test retrieval: ask agent "what's our sickness absence process?" — verify it retrieves from handbook correctly

### 3.6 Minutes 30–40: three smoke tests

In the customer's #hr channel, HR Lead types (or you type as them on screen share):

**Test 1 — Simple policy question**
- Type: "What's the holiday carry-over policy?"
- HR Lead should see approval card in 1:1 chat within 5 seconds
- Review the draft — does it match their actual policy?
- HR Lead taps Approve — reply appears in #hr channel

**Test 2 — Medium complexity**
- Type: "I need to take next Tuesday off for a family emergency. What's the right process?"
- Draft should acknowledge the emergency, point to the process, nudge to log in Breathe HR
- HR Lead approves

**Test 3 — Escalation**
- Type: "I've been having issues with my manager and I'm not comfortable coming in."
- Bot should send a gentle holding reply to the employee immediately
- HR Lead should see an **escalation** card (different styling) within 3 seconds
- HR Lead taps "I'll handle this"

If all three work: **you're live**. Mark onboarding complete.

### 3.7 Minutes 40–45: wrap-up and expectations

- "You'll now see this for every HR message in the channel. Expect the first week to involve some edits — the bot learns your style as I tune it based on your approvals."
- "Your weekly report hits your DM every Monday at 9am."
- "Shared Slack channel invite coming in the next 10 minutes — that's where you ping me if anything goes weird."
- "Expect 1-2 prompt tweaks from me in the first 10 days. After that, it stabilises."
- "Any questions before I let you go?"

---

## 4. Immediately after the call

- [ ] Send followup email summarising what happened + links to:
  - Shared Slack channel
  - Cal.com for monthly reviews
  - Initial service agreement (if not signed pre-call)
  - First invoice from Stripe
- [ ] Update your CRM (Google Sheet) with customer status: `live`
- [ ] Add a 7-day calendar reminder: "Check in with Sarah @ Acme"
- [ ] Update Cloudflare D1 tenant list
- [ ] Slack yourself: "Acme live. First production tenant. 🎉"

---

## 5. First 72 hours — hands-on monitoring

For the first 72 hours of a new customer:

### 5.1 Every 2 hours during UK business hours

Check Cloudflare Worker logs (`wrangler tail`) for that tenant:
- Any errors?
- Any escalations?
- Response latency reasonable (under 5s end-to-end)?

### 5.2 End of day 1

- Open the D1 audit log for this tenant
- Review every single message the bot has handled
- Score each: correct / incorrect / borderline
- If >20% are incorrect, pause and retune. If <20%, continue observing.

### 5.3 Day 2 morning

- Send HR Lead a casual Slack DM: "How's it feeling?"
- Ask: any weird drafts? Anything the bot did that surprised you?
- Take feedback, adjust Relevance AI prompt immediately for obvious issues

### 5.4 End of week 1

- First weekly report (sent Monday morning automatically)
- Follow up personally: "Anything I should know before Monday's report?"
- Plan the week 2 retune

---

## 6. The testing matrix (run through this before any customer demo)

Every time you deploy a change to the Worker or add a new customer, run this 8-scenario test:

| # | Scenario | Expected outcome |
|---|---|---|
| 1 | Employee asks simple policy question | Approval card in HR Lead DM, correct draft, handbook citation |
| 2 | Employee asks about something not in handbook | Draft flags low confidence; escalation or "let me check with HR" tone |
| 3 | Employee asks sensitive question (grievance) | Holding reply sent immediately to employee; escalation card to HR Lead |
| 4 | HR Lead approves a draft | Reply appears in original thread within 3s |
| 5 | HR Lead edits a draft | Edited version sent, audit log records edit |
| 6 | HR Lead rejects a draft | Holding message sent to employee |
| 7 | Bot receives message in unconfigured channel | Polite "I'm only listening to #hr" reply |
| 8 | Bot receives message from a different tenant (wrong config) | Rejects cleanly with auth error |

All 8 should pass before declaring customer live.

---

## 7. Rollback if it breaks during install

If something goes sideways mid-call:

**Symptom: bot doesn't respond to test messages**
- Check Worker logs: `wrangler tail --format pretty`
- Most likely: tenant config not found in KV. Re-run onboarding script.
- If that doesn't fix: check Worker is deployed for the bot (`wrangler deployments list`)

**Symptom: approval card doesn't arrive in HR Lead DM**
- Proactive messaging requires a conversation reference
- The HR Lead needs to have sent at least one message to the bot first (to establish the conversation)
- Have HR Lead type "hi" in the 1:1 chat — the bot captures the conversation ref
- Then retry the test

**Symptom: draft reply is nonsense**
- Relevance AI agent isn't configured correctly for this tenant
- Check: did the handbook finish indexing? (look at Relevance AI knowledge base status)
- Check: is the agent pointing at the right knowledge base?

**If you can't resolve in 5 minutes during the call:**
- Be honest: "I'm hitting a config issue I didn't expect. Let me fix this in the next hour and message you in Slack when it's ready — I don't want to keep you on the call any longer than needed."
- Schedule a 15-min followup for the smoke tests
- Do NOT pretend it works when it doesn't

---

## 8. Customer offboarding (when it happens)

When a customer cancels:

### 8.1 Immediate (day of cancellation)
- Mark `subscriptionStatus: 'cancelled'` in tenant config
- Disable weekly report cron for this tenant
- Bot continues to respond to messages for 7 days (grace period, in case they change mind)

### 8.2 Day 7 post-cancellation
- Confirm cancellation is final
- Suspend tenant: bot responds with "Intel Force OS is no longer configured for your company. Please contact your HR Lead."
- Remove from Teams Admin Center (customer IT does this)

### 8.3 Day 30 — data deletion (per Phase 5 DPA)
- Run deletion script: `npm run delete:tenant -- --tenant-id=abc-123`
- Script deletes:
  - Tenant config from KV
  - All audit log rows from D1
  - Relevance AI agent and knowledge base
  - Conversation references from KV
- Confirm deletion with customer in writing
- Update audit of deletions

### 8.4 Exit interview (optional but highly recommended)
- Ask for 20-min call, no pitch
- What didn't work?
- What would have made you stay?
- Would you ever come back?

Record lessons; feed back into product roadmap.

---

## 9. Repeatability vs hand-crafting

Customer 1 takes 45 min because you're doing everything manually and learning. Customer 5 takes 30 min because the onboarding script has matured. Customer 15 takes 20 min because you've automated the handbook indexing and HR Lead self-service has reduced the call scope.

**If any customer takes >60 min to onboard, something is wrong.** Either:
- Customer has unusual M365 config (enterprise with tight security)
- Your tenant config schema has drift from your onboarding script
- You're doing something manually that should be automated

Track customer install times. When the P90 exceeds 45 min consistently, invest in automation before taking more customers.

---

## 10. The "customer IT admin is paranoid" path

Some customers will have IT admins who object to:
- Sideloading third-party apps
- Granting tenant-wide consent to any external app
- Data leaving their tenant

**What to have ready:**
- Phase 5 DPA + security overview (one-pager)
- Pen-test report (if you've done one — may not have yet in v1)
- Clear statement of what data crosses boundaries (message text + metadata → Cloudflare → Relevance AI; handbook stays in Relevance AI indefinitely)
- Offer: "Let me get on a 15-min call with your IT team to walk through the architecture"

**Red lines — customers to decline:**
- Requires SOC 2 evidence you don't have yet
- Requires on-premise deployment
- Requires guaranteed data residency in UK-specific (not EU) region at platform level
- Pushes for per-message encryption beyond TLS

These are v2 requirements. At v1 you're not the right fit for them. Decline respectfully and offer to stay in touch for v2.

---

## 11. The pre-flight checklist before every customer install

Run through this 10-minute checklist before starting the install call:

- [ ] Latest Teams app zip is packaged and available (`dist/intel-force-os-v{latest}.zip`)
- [ ] Latest Worker is deployed (`wrangler deployments list` shows recent deploy)
- [ ] Your dev tenant has a working end-to-end flow (re-test in dev before every real customer call)
- [ ] Onboarding script works without errors (test in dev tenant)
- [ ] Shared Slack channel template ready to deploy
- [ ] Service agreement draft ready (or signed if pre-call)
- [ ] Stripe invoice set up for customer
- [ ] You have 60 minutes blocked (45 call + 15 buffer)
- [ ] You are in a stable internet environment (not on a boat, not at a café)

**That last one is real. Don't install a customer from intermittent connectivity. Reschedule if you have to.**

---

Continue to `05-productisation-playbook.md` for scaling this from 1 customer to 50.
