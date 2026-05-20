# gstack install pin

**Installed:** 2026-05-20 (Day 7 morning)
**Installed by:** Claude Code (plan-mode approved; plan file at `~/.claude/plans/bubbly-snuggling-lantern.md`)
**Install location:** `~/.claude/skills/gstack/` (user scope; NOT repo-pinned per plan decision 1)

## Pin

| Field | Value |
|---|---|
| Branch at install | `main` |
| Commit SHA at install | `026751ea2012ec7cbedc149ba615929a20026501` |
| Latest tag at install | (no tag) |
| Skill count at install | 48 (per setup `[gen-llms-txt]` line: "48 skills, 75 browse commands") |
| Bun version | 1.3.14 |
| Node fallback version | v25.9.0 |

## Roll-forward policy

- **Mid-sprint roll-forward: forbidden.** Breaking changes mid-week disrupt IFOS engineering velocity.
- **Week-boundary roll-forward: deliberate only.** Run `git -C ~/.claude/skills/gstack pull` at Monday week-open. Review changelog/release notes BEFORE re-running `./setup`.
- **If roll-forward breaks:** rollback to this pinned SHA via `git -C ~/.claude/skills/gstack reset --hard 026751ea2012ec7cbedc149ba615929a20026501 && ./setup`.

## Skills installed (linked)

48 skills bundled per `./setup` output. Notable categories:

- **Planning/review:** `plan-ceo-review`, `plan-design-review`, `plan-devex-review`, `plan-eng-review`, `plan-tune`, `autoplan`, `review`, `retro`, `investigate`, `office-hours`
- **Build/ship:** `ship`, `land-and-deploy`, `setup-deploy`, `document-generate`, `document-release`
- **QA/browse:** `qa`, `qa-only`, `browse`, `open-gstack-browser`, `canary`, `setup-browser-cookies`
- **Design:** `design-consultation`, `design-html`, `design-review`, `design-shotgun`, `devex-review`
- **Memory (gbrain):** `setup-gbrain`, `sync-gbrain` (see §5 below for IFOS configuration)
- **Meta:** `gstack-upgrade`, `freeze`, `unfreeze`, `guard`, `careful`, `codex`, `pair-agent`, `skillify`, `context-save`, `context-restore`, `learn`, `scrape`, `make-pdf`, `landing-report`, `benchmark`, `benchmark-models`, `health`, `cso`

Full enumeration via `ls ~/.claude/skills/gstack/skills/`.

## Boundary preservation

Per the approved plan (`~/.claude/plans/bubbly-snuggling-lantern.md` §Boundary preservation):

- gstack writes nothing to IFOS repo paths autonomously
- Never invoke gstack against `packages/harness/cortextos/` (submodule read-only)
- gstack has no Composio/AgentMail adapter; no vault or Postgres writer
- GBrain MCP and IFOS wiki-brain are wholly separate (see operational-hygiene-protocol.md and ADR-002)

## Reference

- Plan file: `~/.claude/plans/bubbly-snuggling-lantern.md`
- gstack upstream: https://github.com/garrytan/gstack
- Operational hygiene protocol: `docs/runbooks/operational-hygiene-protocol.md` (commit `0020521`)
