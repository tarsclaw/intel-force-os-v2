# How to Proceed — From Plans to Paying Customer

**You have 163+ files of plans and zero paying customers. This document is the bridge. Read it once, then don't open it again until something in the build breaks.**

---

## The honest framing first

Before the tactics: a hard truth about your situation.

You have enough architecture to build a £10M platform. What you don't have is one customer whose problem you've solved for money. That gap is the entire game. Every day you spend elaborating plans without closing a customer, the gap widens.

The "ginormous system" feeling is real but misleading. Intel Force OS isn't one ginormous system — it's a sequence of small systems that connect to each other. The mistake is trying to build (or even plan) them all at once. The discipline is to build one vertical slice end-to-end, ship it to a real person, watch them use it, and let what you learn dictate what you build next.

**So the answer to "how do I build this" is: you don't build all of it. You build the thinnest possible slice that a customer will pay £400 for. Everything else waits.**

That slice exists already. It's the Teams HR agent in architecture pack stage E — a bot in Teams that takes a question, calls Relevance AI, and posts a draft with approval buttons. Strip even that down and the MVP is: employee types a question, HR lead gets a draft with an approve button, approve sends it. That's the product. Everything else is service layer, polish, and scaling — and all of it can be deferred until customer 1 is paying.

---

## The strategic approach — vertical slices, not horizontal layers

**Don't build:**
- ❌ All of the Worker first, then all the cards, then all the storage, then the manifest
- ❌ "The platform" in Phase 3 before the Teams app is live
- ❌ Three agents in parallel
- ❌ Polish and monitoring before the core flow works

**Do build:**
- ✓ **Slice 1**: Echo bot (Teams → Worker → reply). Proves the plumbing. ~2 days.
- ✓ **Slice 2**: Relevance AI integration. Now the reply is a real draft. ~1 day.
- ✓ **Slice 3**: Approval card → send on approve. This is the actual product. ~2 days.
- ✓ **Slice 4**: Audit log + tenant config. This is what lets you onboard customer 2. ~1 day.
- ✓ **Slice 5**: Escalation flow + weekly reports. This is what justifies £400/month. ~2 days.
- ✓ **Slice 6**: Manifest, packaging, onboarding script. Customer-ready. ~2 days.

Each slice produces something demonstrable. If slice 3 works, you can demo to a prospect even without slice 4-6 built. Slices are how you parallel-track customer conversations with building.

**The key discipline:** finish a slice before starting the next. Don't mix slices. Don't "while I'm in the Worker code let me also add X from slice 5." That's how the ginormous-system feeling starts.

---

## What you should do today (literally)

Before opening Claude Code, do these four things in order:

### 1. Decide what you're building this week (15 min)
Read `01-architecture-overview.md` §11 — the four questions to answer before starting. Write your yes/no for each. If you get four yeses, you're building. If not, resolve the "no" first.

### 2. Pick the first customer target (30 min)
Open the Intel Force OS GTM pack (`hr-agent-gtm-pack/03-prospecting-framework.md`). Pick 10 prospects from the ICP who are on Microsoft 365. Send the LinkedIn connection requests this evening. These are the people you'll demo the bot to in 5-10 days. If nobody commits to a demo, something is wrong with your positioning, not your tech — fix that before building.

### 3. Set up Claude Code properly (1 hour)
Follow "Claude Code setup" section below. This is a one-time cost that pays back every session.

### 4. Start Slice 1 (2-3 hours)
With Claude Code configured, run through Stages A-D from `07-claude-code-prompts.md`. You'll have an echo bot in Teams by end of day today.

**Total time investment today: ~4-5 hours. End state: prospects warmed up, environment ready, echo bot working.**

---

## Claude Code setup — the power-user configuration

This is the most important section. Skip it and you'll be miserable. Invest 1 hour now and every session after runs smoothly.

### How Claude Code actually works (the mental model)

Claude Code reads context from four places, in rough priority order:

1. **Your current message** — what you're asking for right now
2. **CLAUDE.md** at project root — always loaded; this is where stable project context lives
3. **Skills** (`.claude/skills/*/SKILL.md`) — loaded when their description matches what's happening
4. **Files it opens** — it can read files in the project; you guide it to the right ones

The winning setup:
- **Put stable, always-true things in CLAUDE.md** (architecture, conventions, how to run stuff)
- **Put specialised knowledge in Skills** (e.g. Adaptive Card rules, Relevance AI contract)
- **Put long reference docs in `docs/`** (the architecture pack lives here; Claude Code reads when relevant)
- **Use slash commands for repetitive workflows** (deploy, tail logs, start new customer)

What you do NOT do:
- ❌ Dump all 163 files into Claude Code's context
- ❌ Paste long architecture docs into chat
- ❌ Ask Claude Code to "read everything we've planned"

Claude Code has a context window but it's not infinite. Blowing it out with architecture docs means it has no room to actually read your code. Instead, put files where Claude Code can find them when needed.

### Step 1: Scaffold the project properly

```bash
mkdir -p ~/dev/intel-force-os
cd ~/dev/intel-force-os
git init
```

Create these folders (structure matters for how Claude Code discovers context):
```
intel-force-os/
├── CLAUDE.md                    # project-level context, loaded always
├── .claude/
│   ├── skills/                  # project-specific skills
│   │   ├── intel-force-os/
│   │   │   └── SKILL.md         # product context
│   │   └── relevance-ai/
│   │       └── SKILL.md         # agent brain context
│   └── commands/                # project-specific slash commands
│       ├── session-start.md
│       ├── deploy.md
│       └── tail.md
├── docs/
│   └── architecture/            # drop the 8-file architecture pack here
├── src/                         # Worker code (from Stage C onwards)
├── teams-app/                   # Teams manifest + icons
├── migrations/                  # D1 migrations
├── onboarding/                  # customer onboarding scripts
├── tests/
└── dist/                        # build output
```

I've given you paste-ready templates for `CLAUDE.md`, the skills, and the commands. Copy them into your project — they're in this folder.

### Step 2: Install the Cloudflare Skills plugin

This is critical and most people miss it. Cloudflare publish an official Claude Code skills plugin that bundles:
- Wrangler skill (knows current CLI syntax)
- Workers best practices skill
- Cloudflare API access via MCP
- Docs MCP server

In Claude Code (run the CLI in your project):
```bash
claude
```

Then:
```
/plugin marketplace add cloudflare/skills
/plugin install cloudflare-skills@cloudflare-skills-marketplace
```

(Exact command may vary — check their GitHub at `github.com/cloudflare/skills` for current install instructions.)

After install, restart Claude Code. Now when you work on Workers/KV/D1, Claude Code pulls current Cloudflare best practices automatically. Massive quality improvement.

### Step 3: Add the Cloudflare docs MCP server

Add to your Claude Code config (either project-level `.claude/settings.json` or global `~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "cloudflare-docs": {
      "url": "https://docs.mcp.cloudflare.com/mcp"
    },
    "cloudflare-observability": {
      "url": "https://observability.mcp.cloudflare.com/mcp"
    }
  }
}
```

This gives Claude Code live access to Cloudflare documentation and observability data from your workers. When it's writing Worker code and hits an edge case, it fetches the current docs instead of hallucinating.

### Step 4: Run `/init` in your project

Once you've set up the folder structure, run in Claude Code:
```
/init
```

This creates/updates a baseline CLAUDE.md. Then REPLACE the generated content with the template I'm giving you (it's more specific to Intel Force OS than the generic init output).

### Step 5: Add the architecture pack to `docs/`

Copy the 8 files from the architecture pack into `docs/architecture/`. They're reference material. When Claude Code needs them, it reads them. You don't need to paste them into chat ever.

### Step 6: Test the setup

Start a new Claude Code session in the project:
```bash
cd ~/dev/intel-force-os
claude
```

Try a test prompt:
```
What's this project? Summarise in 3 sentences based on CLAUDE.md and the architecture docs.
```

If Claude Code gives you a coherent summary that includes the Teams-first approach, Cloudflare Workers, Relevance AI brain, and the stage-based build plan — your setup is working. If not, your CLAUDE.md needs more detail.

---

## How to run Claude Code sessions well

### The "session-start" pattern

Every new Claude Code session, start with:

```
/session-start
```

(This is the slash command I've given you. It prompts Claude Code to establish context for what you're about to work on.)

The command has it ask you:
- What slice are you on?
- What's the goal of this session?
- What files are you likely to touch?

This forces you to scope the session, which keeps Claude Code focused and reduces context waste.

### Scope each session narrowly

**Bad:** "Let's build the Teams HR agent."  
**Good:** "Today we're on slice 1. I need `/api/messages` returning 200 to any Bot Framework request, with basic JWT verification. No agent logic yet. Files: src/index.ts, src/bot/handler.ts, src/bot/auth.ts. Let's start by scaffolding handler.ts with a stub."

The narrow scope makes Claude Code 3× more effective. You can always widen later.

### Use Plan Mode for anything ambiguous

Before Claude Code makes big changes, switch to Plan Mode:
```
/plan
```

It will outline what it's going to do without doing it. You approve, then it executes. This prevents the "Claude Code wrote 200 lines before I realised it misunderstood" failure mode.

### Commit after every working slice

After each slice works end-to-end:
```
/commit
```

(Or just `git add . && git commit -m "..."` yourself.)

Small commits = easy rollback when something breaks. Big commits = nightmare debugging.

### Run tests before Claude Code moves on

Add this to your CLAUDE.md (it's in the template):

> After any change to Worker code, run `npm run typecheck` and `npm test`. Do not move to the next task until both pass.

Claude Code respects this. It'll run the checks itself and fix issues before declaring a task done.

### When Claude Code hallucinates

It will occasionally insist on outdated APIs or make up SDK methods that don't exist. The cure is always the same: point it at the docs. Either:

```
That's not right. Please fetch https://docs.claude.com/... and verify before writing more code.
```

Or with the Cloudflare docs MCP installed:
```
Check the current Cloudflare docs for [specific API]. I don't think that method signature is right.
```

---

## The week 1 build plan, concretely

### Monday — Foundation

**Morning (3 hours):**
- 9:00: Set up Claude Code (Step 1-6 above)
- 10:00: Read architecture overview one more time (`01-architecture-overview.md`)
- 10:30: Run Stage A prompt from `07-claude-code-prompts.md` — installs tooling, auths Azure + Cloudflare
- 11:30: Run Stage B — Azure bootstrap. By lunch you have an Entra ID app + bot registration.

**Afternoon (3 hours):**
- 13:30: Run Stage C — Worker scaffold. By 16:30 you have a Worker deployed with a health endpoint.
- 16:30: Run Stage D — echo bot. By end of day the bot echoes messages.

**Evening (1 hour):**
- Send 10 LinkedIn connection requests per GTM prospecting framework
- Reply to any inbound from last week

**End of Monday:** scaffolding deployed, echo bot live in your dev tenant. You can DM the bot and it replies. This is more than most SaaS founders ship in week 1.

### Tuesday — Intelligence

**Morning:** Stage E — Relevance AI integration. The bot now returns real HR drafts.

**Afternoon:** Stage F part 1 — approval card design and rendering. You can see the approval card in Teams.

**Evening:** 2 discovery calls booked from yesterday's outreach (book at 30 min each).

### Wednesday — Approval flow

**Morning:** Stage F part 2 — wire up approve/edit/reject buttons. The full core flow works: question → draft → approve → reply.

**Afternoon:** Test the 8 scenarios from `04-deployment-guide.md` §6. Document any failures.

**Evening:** Demo prep. Screen-record a 90-second walkthrough of the flow working.

### Thursday — Demos

**All day:** Focus on customer conversations. Send the 90-second demo to the prospects who responded this week. Book install calls.

**Claude Code work:** slice 4 (audit log + tenant config) — if time permits. Don't force it.

### Friday — First install

**Morning:** If you have a committed first customer (£400/mo), schedule install for today or Monday. Run through the deployment guide.

**If no committed customer yet:** this week was still successful — you have a working product. Keep prospecting. Week 2 you close.

**Afternoon:** Clean up what you built. Document anything weird. Write a short Loom for prospects who didn't reply.

---

## How to know if you're on track or drifting

### Healthy signals
- End of Monday: echo bot works
- End of Wednesday: approval flow works in dev tenant
- End of Friday: either installed customer 1 OR scheduled install for next week
- Each day: ≥3 meaningful customer conversations (LinkedIn, email, call, demo)
- No day has ≥6 hours of Claude Code without a customer conversation

### Drift signals (STOP, regroup)
- You're 3 days in and still on slice 1
- You've built a feature that isn't in the 6 slices above
- You're debating architecture in Claude Code chat instead of building
- You've added a new file to the architecture pack instead of working from it
- You've had zero customer conversations this week

If you hit a drift signal, close Claude Code, re-read the honest framing at the top of this doc, and reset.

---

## When to come back to the architecture pack

The 8-file architecture pack is reference material. You return to it when:

- You hit a specific implementation question ("how does the proactive messaging pattern work?" → `02-component-design.md` §7)
- You need to explain the product to a prospect ("what's the security model?" → `02-component-design.md` §11 + `01-architecture-overview.md` §7)
- A customer IT admin has questions ("where does our data go?" → `01-architecture-overview.md` §7)
- You're about to build something and want to re-read the component spec (e.g. opening `02-component-design.md` §3 before writing the card code)

You do NOT return to it to:
- Re-read everything "to remind yourself"
- Add new sections
- Review whether the architecture is right (it's been reviewed enough)

The pack is a map. You consult it to navigate, not to redraw.

---

## When to expand beyond v1

Don't expand until:
- 3 paying customers live for ≥30 days
- You're spending <15 hours/week on all customer delivery combined
- A new customer conversation surfaces the same missing feature 3+ times

Only then does it make sense to read the Phase 3 platform spec, add a second agent, build the Tab dashboard, or submit to Teams App Store.

Until then, the answer to every "should we add X?" is "not yet."

---

## The meta-rule

**You do not need more planning. You need customer 1.**

If at any point while building this you feel the urge to generate another architecture document, another strategic plan, or another prospectus — that urge is the enemy. The work that matters is in Teams, talking to humans, and in Claude Code writing the Worker code. Everything else is procrastination wearing a smart jacket.

Close this doc. Open Claude Code. Start Monday morning's Stage A prompt. Ship by Friday.

---

## Troubleshooting

### "Claude Code keeps losing context between sessions"
You haven't put enough in CLAUDE.md. The file should be sufficient that a new Claude Code session without any prior context can understand the project in one read. If you're re-explaining things each session, add them to CLAUDE.md.

### "Claude Code is writing code that doesn't match my patterns"
Add your patterns to CLAUDE.md under a "Code conventions" section. Be specific — "we use functional components, not class components" rather than "write modern code."

### "Claude Code can't find the architecture docs"
They need to be in `docs/` within the project (or reachable from the CWD). If they're somewhere else, Claude Code can't read them. Reference paths in CLAUDE.md: "Architecture docs are in `docs/architecture/`."

### "I'm overwhelmed by how much there is to build"
You're looking at the whole map. Look at only today's slice. Close the map if needed. One slice, 4-8 hours of focused work, demonstrable outcome. That's the only scope you need to think about.

### "Claude Code is working but the result feels fragile"
Add tests. Not elaborate ones — just enough that running `npm test` catches regressions. This becomes your safety net as the codebase grows. Without it, you'll break things and not notice until customer 1 sees it.

---

## Final check before Monday

Before you start Monday morning:
- [ ] You've picked 10 prospects and sent connection requests
- [ ] You have 60 uninterrupted minutes to set up Claude Code properly
- [ ] You have a Microsoft 365 dev tenant ready (or signing up for one is step 1)
- [ ] You've decided which day this week is "customer conversation priority" day (suggested: Thursday)
- [ ] You've forgiven yourself for the 163 files of plans — they're the foundation, not a burden

Go. Ship something small. Come back to the map only when you're lost.
