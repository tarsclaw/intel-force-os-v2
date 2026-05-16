# Current priorities

**Week:** Week 0 (pre-build)
**Today's task:** Day 1 — CortexOS primitive audit per master brief §6 Day 1

## This week's gate

Clear all seven days of master brief §6 by Sunday. Five-of-five yeses on the
§6 Day 7 single-sentence test gates entry to Week 1.

## Open

- [ ] Day 1: CortexOS primitive audit document (`docs/architecture/cortexos-primitive-status.md`) — formalise the seven §2.4 primitives (PTY/PM2, 71h context rotation, file bus, approval gates, Telegram/iOS surface, overnight autoresearch, multi-agent orchestrator) with one-line status per primitive: shipped and tested / shipped but flaky / documented not built / aspirational
- [ ] Day 1: first design-partner sales conversation (founder, parallel track)
- [ ] Day 2: Bullhorn integration path decision (`docs/decisions/bullhorn-integration-path.md`)
- [ ] Day 3: sequencing target + Brain UI scope decision (`docs/decisions/`)
- [ ] Day 4: Hetzner UK VPS + Postgres 16 + LUKS + RLS isolation test
- [ ] Day 5: auto-send safety policy + kill criterion
- [ ] Day 6: vertical schema v0.1 (`docs/verticals/recruitment/vertical-schema.yaml`)
- [ ] Day 7: single-sentence test review

## Shipped today

Day 0 complete:
- Repo cloned at `~/code/CortexOS/`
- IFOS cortextOS runtime cloned at `~/code/cortex-os-ifos/`, linked as `cortextos-ifos`
- Dedicated `ifos-v2` instance configured, isolated from personal install at `~/cortextos/`
- cortextOS vendored as reference-pin submodule at pinned SHA
- Four operative specs in `docs/build-brief/` and `docs/specs/`
- Six supplementary specs in `docs/_supplementary/`
- Prior build pack archived to `docs/_archive-build-pack/`
- `.envrc` with safety guard + `ifosctl-install` wrapper
- Six cortextOS quirks captured in `.agents/learnings/00-cortextos-quirks.md`
- Root `CLAUDE.md` replaced with isolated-instance, master-brief-aligned version
- Claude Code Day-0 comprehension check passed (eight-of-eight: five rules, four boundaries, brain-replacement seam, bundle pattern, ratification list, instance isolation, two-instance state table, today's task)

## Stuck

(nothing — Day 0 closed)

## Queued for Codex ratification

First ratification run is Day 7. The seven Week 0 artefacts go in together:
1. CortexOS primitive audit
2. Bullhorn integration path decision
3. Brain UI scope decision
4. Sequencing target decision
5. Auto-send safety policy
6. v1.0 kill criterion
7. Vertical schema v0.1

## Notes

- IFOS dashboard credentials: see `~/.cortextos/ifos-v2/dashboard.env`, password
  saved in 1Password as "IFOS dashboard admin" (per Day 0 setup)
- Personal install: undisturbed, password recovered as `orcinitrust2024` (backup
  at `~/.cortextos/default/dashboard.env.post-ifos-install-2026-05-16`)
- Day 0 head-start for Day 1 audit: `.agents/learnings/00-cortextos-quirks.md`
  already documents six primitives-related findings (install env-var bug,
  node-pty rebuild on Node 25+, npm-link benign warning, dashboard.env clobber
  via mis-routed install, two-instance state table, CTX_FRAMEWORK_ROOT cwd bug)
