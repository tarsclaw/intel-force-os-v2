# How to proceed — Intel Force OS execution strategy

You now have a Claude Code setup that covers the entire Intel Force OS system. 163 spec files are navigable. 13 skills route Claude Code to the right context. 8 slash commands give you workflow primitives. 2 subagents handle deep reviews and customer support.

The infrastructure is ready. Here's how to actually use it.

---

## The fundamental constraint

Intel Force OS has:
- ~40,600 lines of specifications
- 0 paying customers
- ~200 lines of production code

This is a classic founder trap: specification quality high, execution velocity low. The kit you just installed is *anti-drift infrastructure*. It's designed to make execution faster, not specification more elaborate.

The question that decides whether Intel Force OS becomes a real business is not "do we have enough architecture?" It's "are we executing?"

---

## The only priority that matters

**Get customer 1 live.** Everything else is secondary.

- £400/month from one real customer >> 40 more pages of specification
- A working Teams HR Agent that one customer uses >> a perfect architecture for 100 customers
- One case study >> three more deferred agent designs

This means: the Teams HR Agent (Pack 7) + GTM (Pack 8) are the active packs. All other packs are reference material until customer 1.

---

## The two tracks, executed in parallel

### Track 1: Build the Teams HR Agent

Follow `docs/teams-hr-agent/07-claude-code-prompts.md`. It has literal prompts for each build stage. In Claude Code:

```
/session-start
/load-phase teams-hr-agent
```

Then start Stage A. The prompts tell Claude Code exactly what to do for each stage. Don't skip ahead. Don't work on multiple stages at once.

Expected timeline:
- Stages A-D (scaffold + auth + handler): 1 week
- Stages E-F (Relevance AI + cards): 1 week  
- Stages G-H (storage + cron): 1 week
- Stages I-J (manifest + smoke tests): 1 week
- Stages K-L (onboarding + CI/CD): 1 week

Total: ~5 weeks to v1, including time for you to do other things (DJing, skiing, yacht, commercial work).

### Track 2: Get customers

In parallel with track 1. This is non-optional.

```
/load-phase gtm
```

The GTM pack has everything ready:
- Outreach templates (verbatim; start here)
- Landing page hero HTML (deploy today)
- Demo script (record it now)
- Pricing sheet (£400 Founding)
- Prospect tracker (CSV template)

Expected activity:
- Week 1: 10 outreach messages sent, landing page deployed, demo Loom recorded
- Week 2: 15 more outreach, 1-2 demos
- Week 3: 15 more outreach, 2-3 demos, 1 verbal commitment
- Week 4: close customer 1 (signed MSA, scheduled install)
- Week 5: install customer 1 (use `/new-customer` once Teams HR Agent build is ready)

---

## The sequencing

**The tracks converge at week 5.** Build finishes around then; customer 1 installs around then. This is by design — neither track bottlenecks the other.

If the build is faster: use the extra time for more outreach and demos.  
If commercial is slower: use the extra time to polish the Teams HR Agent and prepare for customer 2.

What kills founders is trying to sequence these serially — "let me finish building first, then I'll do sales." You'll finish building in December with no customers. Don't do that.

---

## The weekly rhythm

### Monday
- `/phase-status` — orient
- Review commercial pipeline (prospect tracker)
- Batch-send 5-10 outreach messages
- Start the week's build slice

### Tuesday
- Continue build work
- Follow-ups on outreach from last week
- 1-2 demos if booked

### Wednesday
- Deep build work (longer uninterrupted sessions)
- 1-2 demos

### Thursday
- Continue build
- Commercial calls + negotiation
- `/review-against-spec` on what you built this week

### Friday
- Deploy if ready (`/deploy preview` mid-week, `/deploy production` Friday morning only if confident)
- Weekly review: `/phase-status`, update CLAUDE.md tracker
- Plan next week

**Avoid:** Friday afternoon / evening deploys. Don't introduce risk heading into a weekend where you can't respond.

---

## The red flags (and what to do)

### Red flag: 7 days without a commit

Something's wrong. Either:
- You're stuck on something (ask for help — use `phase-architect` subagent or just a normal conversation with Claude Code)
- You're avoiding the work (address whatever's making you avoid it)
- You're over-planning (stop planning, start coding)

### Red flag: 7 days without outreach

Same pattern. Either:
- You're waiting for "the product to be ready" (it won't be; start now)
- You're avoiding rejection (every sales motion has rejection; the rate matters, not individual rejections)
- You're overthinking the message (use the templates; don't craft bespoke ones)

### Red flag: Multiple build stages "in progress"

You're context-switching. Pick one. Finish it. Commit. Then start the next.

### Red flag: You're editing spec files mid-implementation

You're drifting into "let me just improve the spec." Spec changes should be deliberate and separate from implementation work.

### Red flag: Planning another pack before customer 1

Stop. That's the pattern this kit is designed to resist. The other packs are fine where they are. Execute the active ones.

---

## The customer 1 checklist

Before you can install customer 1, you need:

### Build side
- [ ] Teams HR Agent deployed to production Worker
- [ ] Smoke tests passing end-to-end (all 8 scenarios in `04-deployment-guide.md` §6)
- [ ] Admin consent URL tested with dev tenant
- [ ] `/new-customer` script tested with dummy tenant

### Legal side
- [ ] MSA template reviewed by solicitor (or Service Agreement for Founding tier)
- [ ] DPA ready (use Phase 5 template)
- [ ] Privacy Policy + ToS deployed to intelforce.ai
- [ ] Terms in the app manifest

### Commercial side
- [ ] Stripe account set up (manual invoicing fine for v1)
- [ ] Founding tier £400/month pricing agreed
- [ ] Welcome email drafted (Phase 5 `sales-and-case-study-playbook.md`)
- [ ] 72-hour follow-up cadence planned

### Ops side
- [ ] Status page live (`status.intelforce.ai`)
- [ ] Monitoring active (Better Uptime / Uptime Robot pinging `/health` every 60s)
- [ ] Sentry or equivalent error tracking on Worker
- [ ] GDPR DSAR/deletion scripts tested with dummy data
- [ ] Backup verification tested (restore from D1 backup)
- [ ] Rollback procedure tested (deploy, rollback, verify)
- [ ] Maddox's phone on for SEV1 alerts

Don't compromise on these. Each took thought to spec. They're the minimum bar.

---

## After customer 1

The playbook changes. Customer 1 gives you:
- Real usage data (the agent performs vs. how you imagined)
- A reference for sales
- Revenue (even just £400 changes the psychology)
- Validation that the product works in the wild

**First month after customer 1:**
- Daily check-ins for the first 72 hours
- Weekly check-ins through week 4
- Aggressive prompt tuning based on real feedback
- Case study construction (capture quotes, metrics)
- Outreach continues with "now serving" social proof

**Customers 2-5:**
- Use the case study in outreach
- Standardise onboarding (each one should take <45 min by customer 5)
- Find patterns in what works vs what doesn't
- Start considering: which agent is #2? (Usually Sales based on existing customer requests)

**Customers 5-10:**
- Velocity should accelerate — word of mouth, case studies, refined pitch
- Consider Teams App Store listing (self-serve onboarding)
- Start the Phase 5 pricing graduation (Starter tier, then Growth for multi-agent customers)
- Phase 6 runbooks become routine (not dormant anymore)

---

## The scale-out question (answered once, revisited later)

At what point should you activate Phase 3 (multi-tenant Postgres platform)?

**Answer:** at 30+ customers, or when a specific pain demands it, whichever comes first.

**Specific pains that would trigger earlier:**
- Enterprise customer (100+ employees in their org) wants per-tenant infra
- Data residency issue Cloudflare can't meet
- D1 performance degrading on queries
- Temporal needed for complex workflows
- SOC 2 / ISO 27001 requires per-tenant isolation

**Specific things that should NOT trigger it:**
- "It feels more enterprise-y"
- Imaginary future customers
- Boredom with current stack
- Maddox wanting to learn Postgres

At the right time, `/load-phase phase-3` and follow the migration sequence.

---

## The agent expansion question (answered once, revisited later)

At what point should you build agent 2 (Sales)?

**Answer:** at 3+ HR customers stable, with at least one explicitly asking for Sales.

**Criteria:**
- HR agent performs reliably (>90% approval rate, <5% customer complaints)
- Customer acquisition motion is working (closing at >30% demo-to-close)
- At least one customer has articulated a Sales need in writing
- Engineering bandwidth available (not bogged down in HR issues)

When these are true: `/load-phase phase-2` → scaffold Sales agent following Phase 2 patterns. Phase 7 `05-productisation-playbook.md` §3 has the full procedure.

---

## The question Maddox asks himself

"Am I building or am I planning?"

At the start of each day, each week, each session. If the answer is "planning" — stop and build. If the answer is "building" but no customers are being contacted — start contacting customers.

The Claude Code kit you just installed is infrastructure for building. Don't mistake it for progress. Progress is commits landing and outreach sent.

---

## Your next three actions

1. **Right now:** install this kit per `00-HOW-TO-USE-THIS-KIT.md`. Should take 15 minutes.

2. **Today:** `/session-start` in Claude Code. Scope the first session: "I want to finish Stage A environment setup." Do it.

3. **This week:** 
   - Stage A through Stage C of the Teams HR Agent build
   - 10 prospect outreach messages sent
   - Landing page hero deployed to intelforce.ai
   - One demo Loom recorded

Track 1 + Track 2 in parallel. Every week. Until customer 1.

You've got the specs. You've got the kit. You've got the competence.

Ship it.
