---
description: Start a new Claude Code session by establishing scope. Forces narrow focus on one build slice at a time. Use at the beginning of every working session.
---

# Session Start

You're beginning a new focused work session on Intel Force OS.

Before doing anything else, establish scope by asking the user these three questions in a single message:

## Questions to ask

1. **Which build slice are you on today?** Options:
   - Slice 1: Echo bot
   - Slice 2: Relevance AI integration
   - Slice 3: Approval card + approve/edit/reject flow
   - Slice 4: Audit log + tenant config
   - Slice 5: Escalation + weekly reports
   - Slice 6: Manifest + onboarding script
   - Maintenance / bug fix (specify what)
   - Customer support (specify tenant and issue)

2. **What's the specific goal of this session?** (e.g., "Get `/api/messages` returning 200 OK with JWT verification" — concrete enough that you can test it at the end)

3. **How much time do you have?** (1h / 2h / half-day / full-day — affects ambition)

## After the user answers

Once they answer:

1. **Summarise the scope back to them** in 2-3 sentences so there's no ambiguity.

2. **Tell them what you're going to read first** based on the slice. For example:
   - Slice 1: "I'll read `docs/architecture/02-component-design.md` §2 and `.claude/skills/intel-force-os/SKILL.md` before writing any code."
   - Slice 3: "I'll read `docs/architecture/06-adaptive-card-examples.json` and §3 of the component design."

3. **State the acceptance test** — how will we know this session was successful? This should be something the user can verify (a test passes, a demo works, a file exists).

4. **Propose a first action** — the smallest concrete step. Don't start work yet; wait for the user to confirm.

## Principles for this session

Once the user confirms and you begin:

- **Stay in scope.** If you notice a problem or opportunity outside this slice, note it but do not work on it. Add it to a "next session" list.

- **Small commits.** After each working unit (typically 20-40 min of work), commit with a conventional commit message. Offer to commit; don't just do it.

- **Run tests frequently.** After non-trivial code changes, run `npm run typecheck && npm test` before continuing.

- **Push back on scope creep.** If the user asks for something outside this slice, ask them: "Is this actually for today, or should we add it to the next-session list?"

- **Reference docs, don't invent.** For Cloudflare questions, use the Cloudflare docs MCP. For Bot Framework, fetch from Microsoft Learn. For architecture questions, read `docs/architecture/`. For product questions, the `intel-force-os` skill has it.

- **End-of-session wrap-up.** When the user says they're stopping, do a quick 4-line summary:
  1. What we achieved
  2. What we didn't get to
  3. What state the code is in (tests passing? things committed?)
  4. Suggested first action for next session

---

**Now: ask the three questions above. Do not start work until the user confirms scope.**
