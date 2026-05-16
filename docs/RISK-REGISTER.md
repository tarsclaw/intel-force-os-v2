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

Three risks emerged from the Day-1 audit + design work. Each has a named owner, a tripwire, and a mitigation that is actionable, not aspirational.

| # | Risk | Probability | Impact | Tripwire | Mitigation | Status |
|---|---|---|---|---|---|---|
| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High | High | Week-4 Diagnostic render fails or doesn't run | **Severity revised 2026-05-16 evening:** ADR-003 + design doc **Accepted** this session. Severity drops from **Blocking** to **High** (design exists, ratified; just needs implementing). **Next severity reduction trigger:** renderer code committed AND Diagnostic agent renders cleanly (target Week 4) → **Medium**. **Final reduction trigger:** all 5 v1.0 agent bundles render and pass validation → **Low**. **Owner:** Claude Code, Week 1-2 for impl. **Source:** Spec gap §1.7-A in `second-brain-design.md`; resolved structurally by `docs/architecture/agent-bundle-renderer-design.md` + `docs/decisions/ADR-003-agent-bundle-renderer.md`. |
| 6 | **Concurrency-document-prerequisite** — without `docs/architecture/vault-concurrency.md`, the wiki/lib/concurrency.ts code can't be reviewed; week-5 first multi-agent test runs against unreviewed concurrency machinery | Medium | Medium (caught at multi-agent test, not at production) | End of Week 2 without `vault-concurrency.md` | Companion document lands Week 1-2 — content already drafted in `second-brain-design.md` §2.6.1-§2.6.3 (extract + format). **Owner:** Claude Code Week 1-2. **Source:** Spec gap 2.6 in design doc. |
| 7 | **Master-brief-drift-accumulation** — five ADR-driven edits (ADR-001 §2.4 chokidar→FastChecker + Ultraplan §3.2 latency; ADR-002 Edit 1 §3.4 brain-replacement + Edit 2 §5.5 v1.0 brain build; ADR-003 Edit C §8 footnote) plus one Day-4 Postgres-rename plus two Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all five edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 spec drifts`. Codex ratifies the commit alongside the seven+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 consequences sections. **Updated 2026-05-16 evening:** edit count rose from 3 to 5 with ADR-003 Edit C addition. |

## Day-0 surfaced risks (carried forward)

Day-0 surfaced three real cortextOS runtime risks. Captured in
`.agents/learnings/00-cortextos-quirks.md`. Resolved structurally so they
don't recur:

- Install ignoring `CTX_INSTANCE_ID` → fixed via `ifosctl-install` wrapper in `.envrc`
- node-pty needing rebuild on Node 25+ → fixed via `.nvmrc` pinning Node 22 LTS
- Two-instance PATH conflict for bus commands → **Updated 2026-05-16 evening:** folds into the renderer's CLAUDE.md preamble responsibility (ADR-003 design §2.1-A). The preamble draft in design §2.3 sets `CTX_AGENT_DIR` explicitly; rendered hook scripts source `_shared/` helpers via `${CTX_AGENT_DIR}/.claude/hooks/_shared/` rather than relying on `PATH` resolution. Quirk 3 is no longer a Week-1 risk — it's a renderer test case.

## The rest

Full risk register per master brief §12 / Ultraplan §10. Port the remaining
risks in during Day 7 review.

## Update log

- 2026-05-16 (Day 0) — Initial register established. Four top risks identified, all active. Three Day-0 runtime risks surfaced and resolved.
- 2026-05-16 (Day 1) — Risk #1 severity revised down (primitives 3 + 4 confirmed shipped and tested per `cortextos-primitive-status.md`; only primitive 1 carries Day-0 brittleness). Three new risks added (#5 renderer-not-built, #6 concurrency-doc-prereq, #7 master-brief-drift-accumulation) from Day-1 audit + design work.
- 2026-05-16 (Day 1 evening extension) — Risk #5 severity revised from **Blocking** to **High** (ADR-003 + design doc Accepted; staged reductions to Medium and Low named). Risk #7 edit count revised from 3 to 5 (ADR-003 Edit C added). Day-0 quirk 3 (PATH conflict) updated: no longer a Week-1 risk — folds into renderer preamble responsibility per ADR-003 design §2.3. No new risks surfaced from renderer design work.
