# Risk register

Updated weekly. Honest naming. No hedging. The four that could kill v1.0 are at
the top. Full risk list is in master brief §12 and Ultraplan §10.

## The four

| # | Risk | Probability | Impact | Tripwire | Mitigation | Status |
|---|---|---|---|---|---|---|
| 1 | CortexOS primitives 3 or 4 are flaky in production | High | High | Daily orchestrator health check flags > 1 incident/week | Every Tier-1 agent has a degraded-mode fallback; manual file-bus handoff documented | Active — Day 1 audit pending |
| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7–8 | Active — Day 2 decision pending |
| 3 | First design partner not signed by end of Week 0 | Medium | High | Week 0 ends without LOI | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | Active — Day 1 conversation pending |
| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 to 4 agents; founder solo through end of v1.0 | Active — not yet at trigger |

## Day-0 surfaced risks

Day 0 surfaced three real cortextOS runtime risks that weren't in the original
register. Captured in `.agents/learnings/00-cortextos-quirks.md`. Resolved
structurally so they don't recur:

- Install ignoring `CTX_INSTANCE_ID` → fixed via `ifosctl-install` wrapper in `.envrc`
- node-pty needing rebuild on Node 25+ → fixed via `.nvmrc` pinning Node 22 LTS
- Two-instance PATH conflict for bus commands → deferred to Day 1 when first agent is scaffolded

## The rest

Full risk register per master brief §12 / Ultraplan §10. Port the remaining
risks in during Day 7 review.

## Update log

- 2026-05-16 — Initial register established. Four top risks identified, all active. Three Day-0 runtime risks surfaced and resolved.
