# Intel Force OS — Full Setup Guide
**Run this whenever you're on a new machine or need to recreate the brain from scratch.**

---

## Prerequisites

- macOS (Apple Silicon or Intel)
- Homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- Node.js 22: `brew install node@22`
- pnpm: `npm install -g pnpm`
- Python 3.12+: already on macOS with Homebrew
- Claude Code CLI: `npm install -g @anthropic-ai/claude-code`

---

## Step 1 — Clone and install dependencies

```bash
git clone <your-repo-url> ~/code/intel-force-os
cd ~/code/intel-force-os
pnpm install
pnpm --filter @intelforce/db exec prisma generate
```

---

## Step 2 — Install the brain tools (Graphify + wiki-brain)

```bash
# Install pipx if not present
brew install pipx
pipx ensurepath
source ~/.zshrc   # reload PATH

# Install Graphify
pipx install graphifyy

# Install graphify skill into Claude Code
graphify install --platform claude

# Install wiki-brain skill
git clone https://github.com/tenfoldmarc/wiki-brain-skill ~/.claude/skills/wiki-brain

# Create brain vault directories
mkdir -p ~/.claude/brain/intel-force-os/{raw,wiki,memory,sessions}
```

---

## Step 3 — Configure wiki-brain

Create `~/.claude/skills/wiki-brain/config.json`:

```json
{
  "setupComplete": true,
  "vaultPath": "~/.claude/brain/intel-force-os",
  "rawDir": "~/.claude/brain/intel-force-os/raw",
  "wikiDir": "~/.claude/brain/intel-force-os/wiki",
  "logPath": "~/.claude/brain/intel-force-os/sessions/log.md",
  "graphPath": "~/code/intel-force-os/graphify-out/graph.json",
  "wikiIndexPath": "~/code/intel-force-os/graphify-out/wiki/index.md",
  "rebuildSchedule": "on-change",
  "projectPath": "~/code/intel-force-os",
  "obsidianVault": "~/.claude/brain/intel-force-os",
  "sessionEndHook": true,
  "lintEnabled": true
}
```

---

## Step 4 — Build the initial knowledge graph

```bash
cd ~/code/intel-force-os

# Code-only graph (fast, no LLM tokens, good baseline)
graphify update .

# Then open Claude Code and run the full AI-enhanced build:
# /graphify /Users/madsadmin/code/intel-force-os --wiki
```

The full `/graphify` run uses Claude to enrich the graph with semantic relationships and generates wiki pages. Run it once — after that, `graphify update .` keeps it current.

---

## Step 5 — Set up global CLAUDE.md

`~/.claude/CLAUDE.md` should contain:

```markdown
# graphify
- **graphify** — Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"`.

# wiki-brain  
- **wiki-brain** — Trigger: `/wiki-brain`
When the user types `/wiki-brain`, invoke the Skill tool with `skill: "wiki-brain"`.

## Context Navigation
When you need to understand any project, codebase, docs, or files:
1. ALWAYS query the knowledge graph first: `/graphify query "your question"`
2. Only read raw files if the user explicitly says "read the file"
3. For Intel Force OS, use `graphify-out/wiki/index.md` as navigation entrypoint
4. For cross-session memory, check `~/.claude/brain/intel-force-os/sessions/log.md`
```

---

## Step 6 — Set up Obsidian 3D visualization (optional but spectacular)

1. Download Obsidian from obsidian.md
2. Open `~/.claude/brain/intel-force-os` as a vault
3. Settings → Community Plugins → Turn off Restricted Mode
4. Install BRAT plugin
5. Via BRAT: add 3D Graph plugin (version 2.4.1 by Aryan Gupta)
6. Enable the plugin, open command palette → "3D Graph: Open 3D Graph View"

**Node settings:**
- Base size: 7
- Scale by connections: ON (hub nodes grow visually)

**Group colours:**
| Group | Purpose | Colour |
|---|---|---|
| 0 | Bot handler | Electric blue `#3B82F6` |
| 1 | Worker entrypoint | Emerald `#10B981` |
| 4 | Agent runtime | Amber `#F59E0B` |
| 8 | Provisioning | Hot pink `#EC4899` |
| 10 | MarkItDown | Purple `#8B5CF6` |
| 15–25 | Dashboard/tRPC | Cyan `#06B6D4` |
| 5–7 | Observability | Lime `#84CC16` |

**Link settings:** opacity 0.15, thickness 1  
**Background:** dark/black  
**Bloom/glow:** ON

---

## Step 7 — Set up MarkItDown service (for handbook ingestion)

```bash
# Start the full observability + markitdown stack
cd ~/code/intel-force-os/observability
docker compose up -d

# Verify markitdown is running
curl http://localhost:8181/health
# → {"status": "ok", "service": "markitdown"}
```

---

## Step 8 — Agent protocol (for every Claude Code session)

At the START of every session, run:
```
/graphify query "what is the current state of intel-force-os and what needs to be done"
```

At the END of every session, save key decisions:
```
/graphify save-result
```
Then append a brief summary to `~/.claude/brain/intel-force-os/sessions/log.md`.

---

## Daily graph refresh

Graphify updates automatically when you use the `/graphify --update` flag.
Or add a git hook (already set up if you ran wiki-brain setup):

```bash
# .git/hooks/post-commit  (auto-created by wiki-brain)
#!/bin/bash
cd ~/code/intel-force-os && graphify update . 2>/dev/null &
```

---

## Verify everything is working

```bash
# 1. Graphify installed
graphify --help | head -3

# 2. Graph exists
ls ~/code/intel-force-os/graphify-out/graph.json

# 3. Brain vault exists
ls ~/.claude/brain/intel-force-os/

# 4. Skills installed
ls ~/.claude/skills/

# 5. Global CLAUDE.md has context navigation
grep "Context Navigation" ~/.claude/CLAUDE.md

# 6. Test a graph query
graphify query "how does the HR agent handle sensitive queries" --budget 500
```

All 6 checks pass → brain is fully operational.
