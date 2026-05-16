# How to use this Intel Force OS Claude Code build kit

This kit turns your Claude Code into an effective Intel Force OS engineer. It covers the entire system — 163 spec files, 40,600 lines of specification across 8 packs — without trying to stuff any of that into context at once.

## What's in the kit

```
build-kit/
├── 00-HOW-TO-USE-THIS-KIT.md          ← This file
├── 01-HOW-TO-PROCEED.md               ← Execution strategy and the path to customer 1
├── CLAUDE.md                          ← System-level project context (always loaded)
├── MASTER-INDEX.md                    ← Complete catalog of 163 spec files
└── .claude/
    ├── settings.json                  ← MCP server config + permission rules
    ├── skills/                        ← 13 skills covering navigation + domains
    │   ├── intel-force-os-system/     ← Top-level system navigation
    │   ├── teams-hr-agent/            ← Current v1 build target
    │   ├── gtm-execution/             ← Customer acquisition
    │   ├── phase-1-poc/               ← POC pack (dormant)
    │   ├── phase-2-agents/            ← 10 agent designs
    │   ├── phase-3-platform/          ← v2 infrastructure
    │   ├── phase-4-dashboard/         ← Web/Tab dashboard
    │   ├── phase-5-business-legal/    ← MSA, DPA, pricing
    │   ├── phase-6-ops-runbooks/      ← Incidents, DR, GDPR
    │   ├── relevance-ai/              ← Agent integration
    │   ├── adaptive-cards/            ← Teams card UI
    │   ├── bot-framework-teams/       ← Bot protocol
    │   └── cloudflare-intel-force/    ← Our Cloudflare patterns
    ├── commands/                      ← 8 slash commands
    │   ├── session-start.md
    │   ├── phase-status.md
    │   ├── load-phase.md
    │   ├── search-specs.md
    │   ├── review-against-spec.md
    │   ├── deploy.md
    │   ├── tail.md
    │   └── new-customer.md
    └── agents/                        ← 2 subagents
        ├── phase-architect.md
        └── customer-support-copilot.md
```

---

## Installation

### Step 1: Create the Intel Force OS project root

If you don't have a repo yet:
```bash
mkdir intel-force-os
cd intel-force-os
git init
```

### Step 2: Copy this kit into the project root

Copy all files and the `.claude/` directory into your project root:
```bash
# From wherever this kit lives, e.g. ~/Downloads/build-kit/
cp -r build-kit/. intel-force-os/
cd intel-force-os

# Verify .claude/ directory came through (hidden)
ls -la
```

You should see `CLAUDE.md`, `MASTER-INDEX.md`, the two HOW-TO files, and `.claude/` all at the project root.

### Step 3: Place your docs/ folder

Copy your existing 163 spec files into a `docs/` directory at the project root:
```bash
# If your existing outputs are at /mnt/user-data/outputs:
mkdir docs
cp -r /path/to/phase-0-strategic/ docs/
cp -r /path/to/phase-1-poc-stack/ docs/
cp -r /path/to/phase-2-agent-suite/ docs/
cp -r /path/to/phase-3-platform/ docs/
cp -r /path/to/phase-4-dashboard/ docs/
cp -r /path/to/phase-5-business-legal/ docs/
cp -r /path/to/phase-6-ops-runbooks/ docs/
cp -r /path/to/teams-hr-agent-architecture/ docs/teams-hr-agent/
cp -r /path/to/hr-agent-gtm-pack/ docs/gtm-pack/
```

Adjust paths based on where your existing artifacts are. The result should be:
```
intel-force-os/docs/
├── phase-0-strategic/
├── phase-1-poc-stack/
├── phase-2-agent-suite/
├── phase-3-platform/
├── phase-4-dashboard/
├── phase-5-business-legal/
├── phase-6-ops-runbooks/
├── teams-hr-agent/
└── gtm-pack/
```

### Step 4: Open the project in Claude Code

```bash
cd intel-force-os
claude
```

Claude Code will:
1. Auto-load `CLAUDE.md` (always)
2. See the `.claude/skills/` directory and register all 13 skills
3. See the `.claude/commands/` directory and register the slash commands
4. See the `.claude/agents/` directory and register subagents
5. Connect to MCP servers from `.claude/settings.json`

### Step 5: Verify

In Claude Code, type:
```
/session-start
```

You should see the scoping prompt from `.claude/commands/session-start.md`. If you see that, the kit is installed correctly.

---

## First-time setup beyond this kit

The kit itself is just documentation and Claude Code configuration. For the Teams HR Agent build to actually run, you also need:

### Development environment (a one-time setup, maybe 1-2 hours)

- Node.js 22+ installed
- TypeScript ≥ 5.4
- Wrangler CLI: `npm install -g wrangler`
- Authenticate: `wrangler login`
- Git hooks / commit message template (optional)

### Cloudflare account

- Signed up at cloudflare.com
- Domain added (`intelforce.ai` — purchase if not already)
- Workers Paid plan ($5/month) — required before customer 1

### Microsoft 365 developer tenant

- Sign up at developer.microsoft.com/microsoft-365/dev-program (free, 90-day renewable)
- Enable sandbox
- This is your dev tenant for testing — never demo or use with real customer data

### Entra ID app + bot registration

Follow `docs/teams-hr-agent/03-azure-bootstrap-via-claude-code.md` for the one-time setup (30 min).

### Relevance AI

- You already have an account with the HR template agent
- Get API key: `RELEVANCE_API_KEY`
- Note the template agent ID for cloning

### Stripe

- Create Stripe account
- For now, manual invoicing is fine (v1)

---

## Daily workflow

### Starting a session

```
/session-start
```

Claude asks three scoping questions. Answer concretely. It then loads the right skills and proposes the first action.

### Knowing where you are

```
/phase-status
```

Shows build progress, commercial progress, deferred work, and suggested next action.

### Loading a specific pack

```
/load-phase teams-hr-agent
```

Loads the Teams HR Agent spec pack and activates its skill.

### Searching for something

```
/search-specs "escalation"
```

Finds mentions across all 163 spec files.

### Reviewing work

```
/review-against-spec src/cards/approval.ts
```

Compares the named file against its relevant spec section.

### Deploying

```
/deploy production
```

Runs pre-flight checks, asks for confirmation, deploys, verifies.

### Watching live traffic

```
/tail production
```

Live Worker logs with sensible filtering.

### Invoking subagents

```
/agents phase-architect
```

Then state what you want reviewed. The phase-architect reads specs deeply and returns a structured verdict.

---

## How skills work (the magic behind the kit)

You won't usually invoke skills directly. They load automatically when their description matches what you're doing.

### Example 1: You start typing about a card

You say: "Let me update the escalation card to include the holding message timestamp."

Claude Code:
1. Scans available skills' descriptions
2. Sees `adaptive-cards` skill with "escalation card" in the description
3. Loads that skill's content
4. Responds with the skill's context in mind

### Example 2: You ask a strategic question

You say: "Should we start building Phase 3 now?"

Claude Code:
1. Loads `intel-force-os-system` (broad system knowledge) + `phase-3-platform` (the specific pack)
2. Responds applying both skills' guidance, including the "activation triggers aren't met" check

### Example 3: A customer issue

You say: "Acme Ltd's bot isn't responding, can you help?"

Claude Code:
1. Loads `teams-hr-agent` + `phase-6-ops-runbooks` + `customer-support-copilot` subagent
2. Walks through structured triage

**You don't need to manage this.** Just describe what you're doing and the kit routes correctly.

---

## The MCP servers

Two external MCP servers are configured:

1. **cloudflare-docs** — authoritative Cloudflare documentation (newer than Claude's training data)
2. **cloudflare-observability** — query your Worker logs and metrics

Claude Code can consult these directly when needed, without you having to fetch URLs or paste docs.

### Recommended additions (install manually if desired)

Cloudflare Skills plugin (separate from this kit):
```
/plugin marketplace add cloudflare/skills
/plugin install cloudflare-skills@cloudflare-skills-marketplace
```

This adds the wrangler skill and Workers best-practice guidance from Cloudflare directly. Complements (doesn't duplicate) this kit.

---

## The permissions model

`.claude/settings.json` defines what Claude Code can do without asking:

- **Allow (no prompt):** read-only ops — `grep`, `git log`, `wrangler tail`, test runs
- **Ask (prompt first):** writes — deploys, secret changes, KV writes, git push
- **Deny (never):** `rm -rf`, force-push, editing `.env*` or spec files

This protects against accidental damage while not gating you on every read operation.

Tune to your comfort level. The defaults are conservative; relax or tighten as needed.

---

## Maintaining the kit

As the project evolves:

### When a build stage completes
Update `CLAUDE.md` — mark the stage `[x]` with date.

### When a pack's status changes
Update `CLAUDE.md` and `MASTER-INDEX.md`.

### When a new skill is needed
Add to `.claude/skills/` following the existing pattern. Keep descriptions "pushy" (include enough keywords that related tasks trigger the skill).

### When the spec changes
Update the relevant file in `docs/`. The skills point at the spec, not the other way around, so skills usually don't need updating unless structure changes.

### When you switch to a new computer
Copy `.claude/` + `CLAUDE.md` + `MASTER-INDEX.md` + `docs/`. Don't copy `node_modules`, `.env*`, or `dist/`.

---

## Troubleshooting

### "Skills aren't loading"
- Check `.claude/skills/{name}/SKILL.md` exists with YAML frontmatter (`---` delimiters)
- Skill description must be non-trivially worded (not just 5 words)
- Restart Claude Code after adding a new skill

### "Slash commands aren't working"
- Check `.claude/commands/{name}.md` has YAML frontmatter with `description:`
- File name becomes the command name (`deploy.md` → `/deploy`)

### "MCP servers aren't connected"
- Check Claude Code version (recent versions have MCP built-in)
- Check `.claude/settings.json` syntax (valid JSON)
- Check network — MCP servers are HTTP-based

### "Too much context loaded"
- Skills load progressively; only relevant ones activate
- If overwhelmed, start fresh: exit Claude Code, reopen
- Use `/load-phase` to explicitly scope

### "Skills giving outdated info"
- Skills reflect specs as of kit creation (April 2026)
- If specs change, the skill may need updating
- Source of truth is always `docs/`, not the skill

---

## What this kit is NOT

- **Not a replacement for actually building.** It makes the build easier; you still need to do the build.
- **Not a replacement for customer work.** It helps you execute; you still need to talk to customers.
- **Not a magic AI that ships the product.** It's Claude Code with good documentation and configuration.
- **Not a spec authoring tool.** Specs exist already. The kit helps you execute against them.

---

## One final thing

The primary risk in Intel Force OS is not under-planning — it's over-planning. This kit's purpose is to **accelerate execution**, not enable more planning. Every session should end with:

- More code shipped, OR
- More customers engaged

If you spend a session refining this kit instead of either, you've defeated its purpose.

See `01-HOW-TO-PROCEED.md` for the execution strategy from here.
