---
description: Show the current implementation status of every phase and pack. Quick way to see where the whole Intel Force OS system stands.
---

# /phase-status

Gives a single view of where every phase/pack stands. Useful when you've been away from the project or want to plan the next priority.

## What I do

1. Read the "Current build state tracker" in `CLAUDE.md`
2. Check git log for recent commits
3. Check `dist/` for recent build
4. Run `wrangler deployments list --env=production 2>/dev/null` if in Teams HR Agent repo
5. Report status in this format:

## Output template

```
INTEL FORCE OS — PHASE STATUS REPORT
Generated: {timestamp}
Git: {branch} @ {short-sha}

=== v1 BUILD (active) ===
Teams HR Agent (Pack 7)
  Stage A (Environment setup)         [x] | done {date}
  Stage B (Azure bootstrap)            [x] | done {date}
  Stage C (Worker scaffold)            [ ] | in progress
  Stage D (Bot auth + handler)         [ ] |
  Stage E (Relevance AI integration)   [ ] |
  Stage F (Cards + approval flow)      [ ] |
  Stage G (Storage KV + D1)            [ ] |
  Stage H (Weekly cron)                [ ] |
  Stage I (Manifest + sideload)        [ ] |
  Stage J (E2E smoke tests)            [ ] |
  Stage K (Onboarding script)          [ ] |
  Stage L (CI/CD + monitoring)         [ ] |
  
  Latest production deploy: {date} or "never"
  Last commit: {message} ({age})

=== COMMERCIAL (active) ===
GTM Pack 8
  Prospects contacted (target 10):    X / 10
  Demos booked (target 3):             X / 3  
  First customer closed:               [no / YES: {date}]
  MRR: £{amount}

Landing page (intelforce.ai):         [deployed / pending]
Stripe account set up:                [yes / no]

=== REFERENCE PACKS ===
  Phase 0 (Strategic)          complete, reference
  Phase 1 (POC)                dormant
  Phase 2 (Agent Suite)        reference
  Phase 3 (Platform v2)        deferred — trigger: 30+ customers
  Phase 4 (Dashboard)          deferred — trigger: 15+ customers
  Phase 5 (Business/Legal)     active reference
  Phase 6 (Ops Runbooks)       dormant — activates at customer 1

=== BLOCKERS ===
  {list any items marked blocker in CLAUDE.md}

=== RECENT ACTIVITY ===
  Last 5 commits
  Last ops event (deploy, incident, customer install)

=== SUGGESTED NEXT ACTION ===
  {based on current state}
```

## The suggested next action logic

- If 0 commits in last 7 days and 0 customers: **recommend GTM activity** (outreach, not code)
- If build stage in progress for >3 days: **recommend unblocking or dropping**
- If customer install pending: **recommend completing onboarding**
- If deploy failed recently: **recommend investigating**
- Default: **recommend continuing current stage**

## Reading the report

- **Stages with dates** — done, moved on
- **Stages with "in progress"** — active focus; should be the only in-progress row
- **Multiple rows "in progress"** — sign of drift; pick one

## When to use this command

- Start of each session (alongside or instead of `/session-start` for quick orientation)
- When considering a context switch (new pack, new priority)
- Weekly review (Friday or Monday)
- Before a commercial call where you need to state build status

Run it now if you'd like.
