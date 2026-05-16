# Current priorities

**Week:** Week 0 (pre-build)
**Today's task:** Day 0 — scaffold reconciliation + spec import per master brief §4

## This week's gate

Clear all seven days of master brief §6 by Sunday. Five-of-five yeses on the
§6 Day 7 single-sentence test gates entry to Week 1.

## Open

- [x] Day 0: repo cloned at `~/code/CortexOS/`
- [x] Day 0: IFOS cortextOS runtime cloned at `~/code/cortex-os-ifos/`, linked as `cortextos-ifos`
- [x] Day 0: dedicated `ifos-v2` instance configured, isolated from personal install at `~/cortextos/`
- [x] Day 0: cortextOS vendored as reference-pin submodule at pinned SHA
- [x] Day 0: four operative specs in `docs/build-brief/` and `docs/specs/`
- [x] Day 0: six supplementary specs in `docs/_supplementary/`
- [x] Day 0: prior build pack archived to `docs/_archive-build-pack/`
- [x] Day 0: `.envrc` with safety guard + `ifosctl-install` wrapper
- [x] Day 0: six cortextOS quirks captured in `.agents/learnings/00-cortextos-quirks.md`
- [ ] Day 0: root `CLAUDE.md` replaced with master-brief-aligned version
- [ ] Day 0: Claude Code comprehension check completed (this is the Phase 5 step)
- [ ] Day 1: CortexOS primitive audit document (master brief §6 Day 1)
- [ ] Day 1: first design-partner sales conversation
- [ ] Day 2: Bullhorn integration path decision (`docs/decisions/bullhorn-integration-path.md`)
- [ ] Day 3: sequencing target + Brain UI scope decision (`docs/decisions/`)
- [ ] Day 4: Hetzner UK VPS + Postgres 16 + LUKS + RLS isolation test
- [ ] Day 5: auto-send safety policy + kill criterion
- [ ] Day 6: vertical schema v0.1 (`docs/verticals/recruitment/vertical-schema.yaml`)
- [ ] Day 7: single-sentence test review

## Shipped today

- Fully isolated IFOS cortextOS runtime
- Product repo scaffold with operative specs at predictable paths
- Reference-pin submodule
- Six cortextOS quirks documented (Day 1 primitive audit half-done early)

## Stuck

(nothing — Phase 4 + Phase 5 pending)

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
