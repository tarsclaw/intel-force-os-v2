---
description: Load context for a specific phase / pack. Example — /load-phase teams-hr-agent, or /load-phase phase-3, or /load-phase gtm
---

# /load-phase {pack}

Load the full context for a specific pack so I can work on it effectively.

## Usage

```
/load-phase teams-hr-agent     # Pack 7
/load-phase gtm                # Pack 8
/load-phase phase-0            # Strategic
/load-phase phase-1            # POC (dormant)
/load-phase phase-2            # Agent Suite
/load-phase phase-3            # Platform v2
/load-phase phase-4            # Dashboard
/load-phase phase-5            # Business/Legal
/load-phase phase-6            # Ops Runbooks
```

## What I do

For the specified pack:

1. Activate the corresponding skill (`.claude/skills/{pack}/SKILL.md`)
2. List the files in that pack's `docs/` folder
3. Read the pack's README or SUMMARY if not already in context
4. If the pack has active sub-components, load their primary spec file headings (structure only, not full content)
5. Report back: what's in the pack, what's the status, what's the first likely action

## Example invocations

### `/load-phase teams-hr-agent`

I'll:
- Activate `teams-hr-agent` skill
- List `docs/teams-hr-agent/*.md` (8 files)
- Read `docs/teams-hr-agent/README.md` and `01-architecture-overview.md` §1-§5
- Check the build stage tracker in `CLAUDE.md`
- Propose the next build slice

### `/load-phase gtm`

I'll:
- Activate `gtm-execution` skill
- List `docs/gtm-pack/*` (9 files)
- Check the GTM milestone tracker in `CLAUDE.md` (prospects contacted, demos booked, etc.)
- Propose the next commercial action (likely outreach or follow-up)

### `/load-phase phase-3`

I'll:
- Activate `phase-3-platform` skill
- List `docs/phase-3-platform/*.md` (9 files)
- Confirm activation triggers aren't met ("Phase 3 is deferred — here's why...")
- Ask if you want to continue planning anyway or re-scope

## Behaviour notes

- **Don't load everything at once.** Progressive disclosure. Load the overview + relevant sections, not every file.
- **Flag status conflicts.** If you `/load-phase phase-3` and we're not at the activation trigger, I'll say so.
- **Update build state.** If you're switching pack mid-session, I'll note the switch.

## Pack aliases

| Alias | Full name |
|---|---|
| `teams`, `teams-hr`, `pack-7` | teams-hr-agent |
| `gtm`, `sales`, `pack-8` | gtm (gtm-execution) |
| `strategic`, `strategy`, `phase-0` | phase-0 |
| `poc`, `phase-1` | phase-1 |
| `agents`, `phase-2`, `agent-suite` | phase-2 |
| `platform`, `phase-3`, `v2` | phase-3 |
| `dashboard`, `phase-4`, `ui` | phase-4 |
| `business`, `legal`, `phase-5` | phase-5 |
| `ops`, `runbooks`, `phase-6` | phase-6 |

If I'm unclear which pack you mean, I'll ask.

## After loading

Once loaded, I'll state:
```
Loaded: {pack name}
Status: {active / reference / deferred / dormant}
Files available: {count}
Current open work in this pack: {from CLAUDE.md}
Recommended next action: {suggested}
```

Then wait for your direction.
