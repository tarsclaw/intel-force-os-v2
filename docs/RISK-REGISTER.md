# Risk register

Updated weekly. Honest naming. No hedging. The four that could kill v1.0 are at
the top. Full risk list is in master brief §12 and Ultraplan §10.

## The four

| # | Risk | Probability | Impact | Tripwire | Mitigation | Status |
|---|---|---|---|---|---|---|
| 1 | CortexOS primitives 3 or 4 are flaky in production | High | High | Daily orchestrator health check flags > 1 incident/week | Every Tier-1 agent has a degraded-mode fallback; manual file-bus handoff documented | **Updated Day 1** — primitive 3 (bus) is **shipped and tested**; primitive 4 (approval gates) is **shipped and tested**; only primitive 1 (PTY/PM2) is **shipped but flaky** per quirks 2-3 + 2026-04-22 restart-storm evidence in `cortextos-primitive-status.md`. Risk severity revised down. |
| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7–8 | Active — Day 2 decision pending |
| 3 | First design partner not signed by end of Week 0 | Medium | High | Week 0 ends without LOI | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | Active — Day 1 founder conversation pending |
| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 to 4 agents; founder solo through end of v1.0 | Active — not yet at trigger |

## Day-1 surfaced risks (new, 2026-05-16)

Three risks emerged from the Day-1 audit and design work. Each has a named owner, a tripwire, and a mitigation that is actionable, not aspirational.

| # | Risk | Probability | Impact | Tripwire | Mitigation | Status |
|---|---|---|---|---|---|---|
| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High | **Blocking** for v1.0 (week 11+ agent code cannot ship) | End of Week 1 without ADR-003 + companion `agent-bundle-renderer-design.md` landed | ADR-003 by end of Week 1; renderer code by mid-Week 2 at latest; Day-1 design doc §1.7 already recommends R2 (bundle-only, no `.claude/skills/` inheritance). **Owner:** founder + Claude Code. **Source:** Spec gap §1.7-A in `second-brain-design.md`. |
| 6 | **Concurrency-document-prerequisite** — without `docs/architecture/vault-concurrency.md`, the wiki/lib/concurrency.ts code can't be reviewed; week-5 first multi-agent test runs against unreviewed concurrency machinery | Medium | Medium (caught at multi-agent test, not at production) | End of Week 2 without `vault-concurrency.md` | Companion document lands Week 1-2 — content already drafted in `second-brain-design.md` §2.6.1-§2.6.3 (extract + format). **Owner:** Claude Code Week 1-2. **Source:** Spec gap 2.6 in design doc. |
| 7 | **Master-brief-drift-accumulation** — three ADR-driven edits (ADR-001 §2.4 chokidar→FastChecker + Ultraplan §3.2 latency; ADR-002 Edit 1 §3.4 brain-replacement; ADR-002 Edit 2 §5.5 v1.0 brain build) + one Day-4 Postgres-rename + two Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all edits into one atomic correction commit at end of Week 0 or early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 spec drifts`. Codex ratifies the commit alongside the seven Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 consequences sections. |

## Day-0 surfaced risks (carried forward)

Day-0 surfaced three real cortextOS runtime risks. Captured in
`.agents/learnings/00-cortextos-quirks.md`. Resolved structurally so they
don't recur:

- Install ignoring `CTX_INSTANCE_ID` → fixed via `ifosctl-install` wrapper in `.envrc`
- node-pty needing rebuild on Node 25+ → fixed via `.nvmrc` pinning Node 22 LTS
- Two-instance PATH conflict for bus commands → deferred to Day 1 when first agent is scaffolded (still deferred — folds into the renderer design ADR-003 per Risk #5 above; the IFOS agent renderer should set PATH explicitly to resolve `cortextos-ifos` before plain `cortextos`)

## The rest

Full risk register per master brief §12 / Ultraplan §10. Port the remaining
risks in during Day 7 review.

## Update log

- 2026-05-16 (Day 0) — Initial register established. Four top risks identified, all active. Three Day-0 runtime risks surfaced and resolved.
- 2026-05-16 (Day 1) — Risk #1 severity revised down (primitives 3 + 4 confirmed shipped and tested per `cortextos-primitive-status.md`; only primitive 1 carries Day-0 brittleness). Three new risks added (#5 renderer-not-built, #6 concurrency-doc-prereq, #7 master-brief-drift-accumulation) from Day-1 audit + design work.
