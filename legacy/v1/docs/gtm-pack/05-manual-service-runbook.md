# 05 — Manual-Service Runbook

**What you actually do, week by week, for a paying customer — while the platform spec waits its turn. This is the wizard-of-oz MVP made operational.**

---

## The mental model

**You are not running a SaaS product. You are running a managed service that happens to use AI.**

The customer experience you're selling is:
- "The AI reads your messages"
- "The AI drafts replies"
- "You approve, edit, or reject"
- "It flags sensitive stuff to me, your HR lead"

What you're actually doing behind that experience:
- The agent runs on Relevance AI (which they don't see)
- You monitor every draft for quality
- You tune prompts manually when things go wrong
- You manually compile weekly reports
- You're the escalation layer when the agent flags something complex
- You're also the support channel when the customer has questions

**This is fine. It works. It's how Zapier, Stripe, DoorDash, and a hundred other now-huge companies started. The trick is knowing the break-point.**

### The break-point

| Condition | What it means |
|---|---|
| You're spending >6 hours/week per customer | Manual service is no longer profitable at £400/mo |
| You have 3 paying customers | You've run out of evenings; must automate |
| You catch yourself making the same prompt fix across 2+ customers | There's a platform feature waiting to be built |
| A customer churns because of a slow response | Manual service lag is a business risk |

**When ANY of these happen, start Phase 3 platform work. Before then, don't.**

---

## The weekly rhythm (per customer)

Target: **3–4 hours per customer per week.** If you consistently run over, diagnose and fix. If consistently under, you're probably being inattentive.

### Monday — Setup the week (45 min)
- Review weekend queue in Relevance AI
- Check any escalations the agent flagged
- Scan agent outputs for the past 3 days — look for any that went wrong
- Update your tracking sheet (below) with last week's metrics
- Send Monday morning "good morning, here's what I saw this weekend" Slack/email to customer

### Tuesday–Thursday — Active operations (15–30 min/day)
- Morning: scan agent outputs from previous day, flag anomalies
- Respond to customer Slack pings/emails within 2 hours during UK business hours
- Handle any escalations that require your input
- Tune prompts when you see a pattern of the agent getting something wrong
- Do NOT re-check the agent every hour. Twice a day (morning + mid-afternoon) is enough.

### Friday — Weekly report (60 min)
- Compile metrics for the week
- Write the weekly report using the template below
- Send to customer before 4pm UK time
- Note: Friday afternoon reports feel more professional than Monday morning reports — it closes the week for them

### Saturday/Sunday — Passive monitoring (15 min total)
- Check escalation flags once on Saturday, once on Sunday
- If nothing is flagged, don't touch anything
- If something's flagged, respond by end of day — escalation means something sensitive

---

## Daily task: Checking agent outputs

### What you're looking for

For every reply the agent drafted (or sent, if the customer approved it):
- **Factual correctness:** did it answer the actual question?
- **Policy accuracy:** did it pull the right policy from the handbook?
- **Tone match:** does it sound like the customer's company, or does it sound generic/American/stiff?
- **Over-reach:** did it try to handle something it shouldn't have?

### Red flags that require immediate action
- Agent provided a specific answer to a question it didn't actually know the answer to (i.e. hallucination)
- Agent handled a sensitive topic (grievance, resignation, mental health, harassment) without escalating
- Agent quoted a policy that's incorrect or outdated
- Agent used a tone inappropriate for the audience (e.g. too casual for a senior employee, too formal for a friendly one)

### Amber flags (log and fix next prompt tune)
- Agent drafted a reply that was technically correct but 3× longer than needed
- Agent repeatedly handled similar questions in subtly different ways
- Agent didn't pull from the handbook when it should have

### Green (no action needed)
- Agent drafted a clear, tone-matched, accurate reply
- Agent escalated appropriately
- Customer approved the draft with no edit

### The weekly quality sample

Once a week (Friday, as part of the report), manually review a random 10 agent outputs from the week. Score each 1-5 on:
- Correctness
- Tone
- Appropriateness of escalation decision

Average your scores. Target: 4.5+/5. If below 4.0, something's drifting — investigate before Monday.

---

## Prompt tuning — the operational loop

### When to tune
- 2+ occurrences of the same kind of error in a week
- Customer says "the replies have been feeling off lately"
- You notice a new category of question the agent isn't handling well

### How to tune (Relevance AI workflow)
1. Identify the failure pattern with 3+ concrete examples
2. Open the agent prompt in Relevance AI
3. Add specific guidance: *"If the question is about X, do Y. If Z, escalate."*
4. Test against the 3+ examples that failed
5. If all 3 now work correctly, save and deploy
6. Monitor next day to see if the fix holds

### What NOT to do
- Don't rewrite the whole prompt in one go. Surgical edits, tracked carefully.
- Don't remove old instructions to make room — Relevance AI agents handle long prompts fine
- Don't "improve" the prompt without a specific failure driving it — you'll regress more than you fix

### Keep a prompt changelog
Separate file per customer:
```
2026-05-03: Added instruction for handling bereavement leave questions — 
            escalate to human, don't quote specific policy (varies by case)
2026-05-07: Added tone guidance — customer flagged "too formal" for their 
            tech startup vibe. Added examples of casual-but-professional tone.
```

**Without the changelog, 6 weeks in, you won't remember why you added any particular instruction. You'll break things by undoing old fixes.**

---

## The weekly customer report (template)

Save as a Google Doc template, duplicate every Friday. Customise per customer.

```
Weekly Report — Intel Force OS
[Customer name]
Week of [dates, e.g. 27 Apr – 3 May]

Volume
  - Messages handled: 47
  - Drafts approved as-is: 32 (68%)
  - Drafts edited before approval: 10 (21%)
  - Drafts rejected: 2 (4%)
  - Escalations flagged to human: 3 (6%)

Quality sample (random 10 reviewed)
  - Average correctness: 4.7/5
  - Average tone match: 4.5/5
  - Escalation decisions correct: 10/10

What went well
  - Onboarding policy questions handled cleanly — zero edits on all 8 drafts
  - Escalation on Tuesday's bereavement message was timely and appropriate

Where I tuned the agent
  - Added guidance on Tuesday for handling flexible working requests more carefully — prompts now ask clarifying questions before drafting
  - Noticed the tone was skewing slightly formal on Thursday; adjusted tone examples in prompt

Sensitive issues flagged for you
  - Tue 29 Apr — message from [employee name], redirected to you (you handled same day)
  - Thu 1 May — grievance-adjacent message from [employee name], flagged and held for your reply

Questions for you
  - The holiday carry-over policy seems to have changed recently — is the updated version now in the handbook? A couple of messages referenced uncertainty this week.
  - Your office manager Caitlin asked twice about updating the sickness return-to-work form — worth putting this in the handbook so the agent can handle directly?

Looking ahead (next week)
  - Will add handling for upcoming bank holiday — employees often ask about pay implications in May
  - Monitoring: the tone adjustment from this week will need a few days to see if it's landed

Hours I spent on your account this week: 4.2h
(Baseline target is 3–4h; over slightly because of Tuesday's prompt tuning. Normal.)

Any questions or feedback, reply here or message me directly.

— Maddox
Intel Force OS
```

**Notes on the report:**
- **Be transparent about hours.** Customers respect it, and it sets the right expectation that you're providing a premium managed service, not a cheap SaaS
- **Always have "questions for you"** — keeps the customer engaged in the co-production of quality, signals you're paying attention
- **Always have "looking ahead"** — shows you're proactive, not just reactive
- **Don't pad metrics.** If only 23 messages came in this week, say so. Volume fluctuates naturally.
- Customers will come to look forward to the Friday report. Don't miss it.

---

## Customer Slack / email communication patterns

### Response times

| Channel | Target response time |
|---|---|
| Slack (customer-shared channel or direct) | 2 hours during UK business hours |
| Email | 4 hours during UK business hours |
| Weekends | 24 hours for non-urgent, same-day for escalations |

**Faster than this and you're over-investing. Slower and you're breaking the premium-service perception.**

### Communication frequency
- **Daily:** only if escalation triggered — don't manufacture reasons to DM
- **Weekly:** Monday check-in (2 sentences), Friday report
- **Monthly:** 30-min "how's it going" call (first Friday of the month, 11am recurring)

### Set a shared Slack channel
If customer uses Slack, request a shared channel at onboarding. `#intel-force-os-[customer-name-short]`. All comms happen here. Avoids the "email vs DM vs WhatsApp" confusion.

### Do NOT use WhatsApp
It's tempting — customers will ask. Decline politely: *"I keep customer comms in one place to make sure nothing drops. Slack or email works best — WhatsApp gets buried."* It preserves your life and your professionalism.

---

## Escalation handling — the sensitive stuff

### When the agent escalates, what you do

1. **Immediately:** check the escalation notification (Slack/email from Relevance AI)
2. **Within 30 min:** review the incoming message + what the agent sent as the holding reply
3. **Decide:** does this need the customer's HR lead right now, or can it wait until next morning?
4. **If urgent:** ping customer via Slack DM with context: *"[Employee] sent something sensitive 20 mins ago. Agent held with a warm acknowledgement. You'll want to look at this today — here's the full message for context: [screenshot/quote]"*
5. **If not urgent:** add to Monday morning summary, flag in next weekly report

### Categories you MUST escalate (agent should be trained for these, but verify)
- Any mention of harassment, discrimination, bullying
- Mental health concerns
- Physical safety
- Resignation or notice of departure
- Grievance filings
- Disciplinary process anything
- Health issues (employee or family)
- Anything legal/regulatory (employment tribunal mentions, etc.)
- Anything mentioning a specific person in a negative way
- Pay/salary disputes

### Categories the agent can probably handle
- Holiday requests and policy questions
- Sickness absence logging (just the process, not the situation)
- Handbook lookups
- Payroll date questions
- Benefits clarification
- Training and development policy
- General "what's the process for X" questions

---

## The customer onboarding week (one-time, per customer)

### Day 0 (signature) — kickoff email
Send within 1 hour of contract signature. Template:
```
Welcome aboard, [Customer name].

Quick rundown of what happens next:

This week (onboarding)
  - Today: I'll set up a shared Slack channel and our Cal.com monthly sync
  - Tomorrow: 60-min onboarding call — I'll need you to share your handbook, give me Breathe HR access (read-only is fine), and walk me through your voice/tone so I can tune the agent
  - Day 3-4: I'll configure the agent and run test queries
  - Day 5: First live week starts — I'll monitor closely

Every week from then
  - Monday: quick check-in from me
  - Friday: weekly report with metrics and what I learned

Shared channel setup link: [Slack shared channel invite]
Monthly sync: first Friday each month, 11am. Calendar invite coming through now.

Any questions before the onboarding call tomorrow?

— Maddox
```

### Day 1 — Onboarding call (60 min)
- Access handoff: Breathe HR read-only, handbook, tone examples
- Question: what does "done well" look like for you? What makes you think this is working?
- Question: what would make you cancel?
- Technical setup begins

### Days 2–4 — Configuration
- Load handbook into Relevance AI knowledge base
- Configure agent prompt with customer voice/tone
- Run 20 test queries from realistic scenarios
- Review tests with customer via Loom video (10 min)

### Day 5 — Go live
- Agent starts reading real messages
- You monitor hourly for the first day, then every few hours
- First Friday report goes out with heavy commentary

### Week 2–4 — Tuning
- Expect 2–3 prompt tunes per week in this period
- Expect some customer frustration around week 2 when novelty wears off but reliability isn't yet perfect
- **Honest moment at week 3:** "Week 2 was bumpy on [X specific thing]. Here's what I changed. Here's what the next 2 weeks will look like." Owning this builds trust.

### End of month 1 — Review meeting
- 60 min Zoom or Meet
- Show: volume handled, quality scores, escalation handling, time saved (estimate together)
- Ask: renew for month 2? (They will — but the explicit ask signals you take their decision seriously)

---

## Tracking your customer success

Create a Google Sheet per customer, with these tabs:

### Tab 1: Weekly metrics
| Week | Messages handled | Approved as-is | Edited | Rejected | Escalations | Quality avg | Your hours |
|---|---|---|---|---|---|---|---|

### Tab 2: Prompt changelog
| Date | Issue observed | Change made | Result |
|---|---|---|---|

### Tab 3: Escalations
| Date | Trigger message (redacted) | Sensitivity category | Response time | Outcome |
|---|---|---|---|---|

### Tab 4: Customer requests / issues
| Date | Request | Status | Resolution |
|---|---|---|---|

**This is your evidence base when it's time to:**
- Write a case study (metrics are right there)
- Raise pricing on renewal (show value delivered)
- Argue internally with yourself about whether Phase 3 platform work is overdue (tab 1 hours/week column)

---

## When it breaks — common failures and how to handle

### Failure 1: Agent hallucinated a policy
- **Action:** Send correction to affected employee immediately, with apology from the customer's HR lead
- **Message to customer:** *"Agent got [X] wrong today, here's the fix I've deployed, here's what I'm going to monitor for the next week to ensure it doesn't recur"*
- **Blame:** take it. Don't blame the customer's handbook, don't blame Relevance AI. You're accountable.

### Failure 2: Agent sent something sensitive without escalating
- **Action:** Stop the agent for 2 hours, audit what happened, write up root cause
- **Customer message:** *"Serious issue today — [summary]. I've paused the agent. Can we get on a call in the next hour?"*
- **Action after call:** deploy fix, resume agent, write up the incident in the weekly report
- **This is the kind of incident that can end the customer relationship.** Overcommunicate.

### Failure 3: You missed a customer ping
- **Action:** Respond with apology, be honest — don't invent an excuse
- **Message:** *"Sorry for the slow reply on this — was heads-down on [legitimate thing] and it got buried. Back to you now."*
- **If it happens more than once:** something is wrong with your system. Fix it.

### Failure 4: Customer wants to cancel at end of month 1
- **Response:** take the cancellation gracefully, don't negotiate too hard
- **Ask:** *"Before we process the cancellation, can we do a 20-min call next week? No sales pitch, just trying to understand what didn't work so I can do better for the next customers."*
- **The feedback from an early-churn customer is worth more than the £400/mo you lost.**
- **Refund:** offer a partial refund if you feel the service underdelivered. £200 back on a £400 month shows you mean it.

### Failure 5: Your life explodes and you can't cover the account for a week
- **Backup plan:** Jack is your partner. Jack gets emergency on-call coverage for the manual service layer. Even if he doesn't know prompts as well as you, he can respond to customer pings and escalate to you when you surface.
- **If Jack is also unavailable:** auto-reply set on the customer Slack/email channel saying "brief absence through [date], for urgent HR escalations only please respond with URGENT and I'll respond." **Tell the customer in advance**, never retroactively.
- **Never ghost the customer.** Graceful communication of unavailability is acceptable; silence is not.

---

## When to graduate from manual service

The signals (any two of these, stop everything and start Phase 3 platform work):

1. **Hours per customer per week consistently exceeds 6**
2. **You have 3 customers and you're working >18 hours/week on delivery**
3. **You've made the same prompt fix across 2+ customer accounts**
4. **A customer has complained about response time and you know it's because you're stretched**
5. **You can't confidently promise the 4th customer the same experience as the 1st**

**When 2+ of these are true, your job changes:**
- Stop taking new customers for 6–8 weeks
- Build Phase 3 platform (postgres schema + provisioning + secrets vault + observability) — you have the spec
- Migrate existing customers to the platform
- Resume sales

**This is the single most important judgement call in the next 12 months.** Too early and you waste infrastructure on 1 customer; too late and you burn out or lose a customer to slow delivery.

**My suggestion: plan to hit this break-point around month 3–4 with 2–3 customers live. That's the spec's target.**

---

## A closing thought

The manual service layer feels unglamorous next to the 40,000 lines of platform spec. It is unglamorous. But it's the bit that converts a beautiful plan into a real business.

Every hour you spend reading one customer's agent outputs is an hour you learn what the platform actually needs to automate. Every prompt tune becomes a platform feature. Every weekly report becomes the dashboard view. Every escalation pattern becomes the escalation notifier logic.

**The manual service layer is not a cheap imitation of the platform. It is the research that makes the platform correct.**

Do it well. Ship the platform when the customer count demands it — not before, not after.
