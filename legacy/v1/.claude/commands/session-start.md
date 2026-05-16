---
description: Scope the current session, load relevant context, identify goal and exit criteria. Prevents context drift across the full Intel Force OS system.
---

# /session-start

Start every session with this command. It prevents the two most common failure modes:

1. **Working on the wrong thing** (drift into a different pack than what's needed)
2. **Not knowing when you're done** (working past the sensible stopping point)

## What I do

1. Read the "Current build state tracker" section of `CLAUDE.md` — that's where the previous session left off
2. Skim `MASTER-INDEX.md` to refresh memory of what packs exist
3. Determine which pack is most likely relevant based on the session goal
4. Verify git state: show current branch, any uncommitted changes
5. Ask you three scoping questions

## The three scoping questions

1. **Which pack are we in?** (Teams HR Agent / GTM / Phase 5 legal / other — affects which skills load)
2. **What's the goal for this session?** (one sentence, concrete — "implement the approval card and wire up the handler" beats "work on the bot")
3. **What's the exit criteria?** (how will we know we're done — "approval card renders in dev tenant with real data" beats "it works")

## What I'll do after you answer

- State back the scope in my own words, so we're aligned
- Load the specific skills relevant to that pack
- Update the current build state tracker in `CLAUDE.md` (marking what we're about to do as in-progress)
- Propose the first concrete action
- Wait for your go-ahead before executing

## When NOT to use this command

- Middle of a session where scope is already clear
- Quick one-off questions (just ask)
- Ops emergencies (go to the relevant runbook)

## The scoping template I'll write out

After the three questions are answered, I'll produce this:

```
## Session scope

- **Pack:** [Teams HR Agent | GTM | ...]
- **Goal:** [one sentence]
- **Exit criteria:** [concrete completion signal]
- **Previous state:** [from Current build state tracker]
- **First action:** [specific next step]
- **Skills active:** [list]
- **Time budget:** [rough estimate, e.g. "1-2 hours"]
```

This becomes the session's north star. If work drifts away from the goal, I'll flag it.

## Remember

This project is over-specified and under-executed. Every session should end with one of:
- More code written and tested (shipped a slice)
- More customers engaged (outreach sent, demo done, install completed)

If a session ended with neither, we drifted. That's a signal, not a failure — act on it next session.

Let me know which pack, what the goal is, and what "done" looks like.
